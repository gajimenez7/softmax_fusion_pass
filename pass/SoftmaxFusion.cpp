#include "SoftmaxFusion.h"
#include "mlir/Dialect/Affine/Analysis/Utils.h"
#include "mlir/Dialect/Affine/LoopFusionUtils.h"
#include "mlir/Dialect/Affine/LoopUtils.h"
#include <llvm/Support/Casting.h>
#include <llvm/Support/raw_ostream.h>
#include <mlir/Analysis/Presburger/Utils.h>
#include <mlir/Dialect/Affine/IR/AffineOps.h>
#include <mlir/Dialect/Arith/IR/Arith.h>
#include <mlir/Dialect/Func/IR/FuncOps.h>
#include <mlir/Dialect/Math/IR/Math.h>
#include <mlir/Dialect/SCF/IR/SCF.h>
#include <mlir/IR/BuiltinAttributes.h>
#include <mlir/IR/Dominance.h>

namespace {

/* helper struct to identify loop patterns */
struct LoopInfo {
  mlir::affine::AffineForOp loop;
  enum LoopType {
    MAX_REDUCTION,
    EXP_COMPUTE,
    SUM_REDUCTION,
    DIV_NORMALIZE,
    UNKNOWN
  } type;
  mlir::Value scalarAccumulator; /* for reductions */
  mlir::Value inputMemref;
  mlir::Value outputMemref;
};

/* classify loop based on operations inside */
LoopInfo::LoopType classifyLoop(mlir::affine::AffineForOp loop) {
  bool hasMax = false;
  bool hasExp = false;
  bool hasSum = false;
  bool hasDiv = false;

  loop.walk([&](mlir::Operation *op) {
    if (auto cmpOp = llvm::dyn_cast<mlir::arith::CmpFOp>(op)) {
      for (auto user : op->getUsers()) {
        if (llvm::isa<mlir::scf::IfOp>(user)) {
          hasMax = true;
        }
      }
    }
    if (llvm::isa<mlir::math::ExpOp>(op)) {
      hasExp = true;
    }
    if (llvm::isa<mlir::arith::AddFOp>(op)) {
      hasSum = true;
    }
    if (llvm::isa<mlir::arith::DivFOp>(op)) {
      hasDiv = true;
    }
  });

  if (hasDiv)
    return LoopInfo::DIV_NORMALIZE;
  if (hasExp)
    return LoopInfo::EXP_COMPUTE;
  if (hasSum && !hasExp)
    return LoopInfo::SUM_REDUCTION;
  if (hasMax)
    return LoopInfo::MAX_REDUCTION;
  return LoopInfo::UNKNOWN;
}

/* manually fuse exp and sum loops by creating a new fused loop */
mlir::affine::AffineForOp fuseExpAndSumLoops(mlir::affine::AffineForOp expLoop,
                                             mlir::affine::AffineForOp sumLoop,
                                             mlir::OpBuilder &builder) {

  llvm::outs() << "[manual fusion] fusing EXP+SUM loops\n";

  /* get the sum loop's initial value (iter_args initial) */
  mlir::Value sumInit;
  if (sumLoop.getNumIterOperands() > 0) {
    /* get initial value from iter operands */
    auto iterOperands = sumLoop.getInits();
    sumInit = iterOperands[0];
  } else {
    llvm::outs() << "[error] sum loop has no iter_args\n";
    return nullptr;
  }

  /* create new fused loop with iter_args for reduction */
  builder.setInsertionPoint(expLoop);
  auto fusedLoop = builder.create<mlir::affine::AffineForOp>(
      expLoop.getLoc(), expLoop.getLowerBoundOperands(),
      expLoop.getLowerBoundMap(), expLoop.getUpperBoundOperands(),
      expLoop.getUpperBoundMap(), expLoop.getStep(),
      sumInit); /* initialize with sum's initial value */

  /* build the fused loop body */
  mlir::Block *fusedBody = fusedLoop.getBody();
  builder.setInsertionPointToStart(fusedBody);

  mlir::IRMapping mapping;
  mapping.map(expLoop.getInductionVar(), fusedLoop.getInductionVar());
  mapping.map(sumLoop.getInductionVar(), fusedLoop.getInductionVar());

  /* map sum loop's iter_arg to fused loop's iter_arg */
  if (sumLoop.getNumRegionIterArgs() > 0) {
    auto sumIterArgs = sumLoop.getRegionIterArgs();
    auto fusedIterArgs = fusedLoop.getRegionIterArgs();
    mapping.map(sumIterArgs[0], fusedIterArgs[0]);
  }

  /* clone exp loop body (load, compute, store) */
  mlir::Value expResult;
  for (auto &op : expLoop.getBody()->without_terminator()) {
    auto *cloned = builder.clone(op, mapping);

    /* capture the exp result before it's stored */
    if (auto storeOp = llvm::dyn_cast<mlir::affine::AffineStoreOp>(cloned)) {
      expResult = storeOp.getValue();
    }
  }

  /* now add the sum reduction: current_sum + exp_result */
  auto fusedIterArgs = fusedLoop.getRegionIterArgs();
  mlir::Value currentSum = fusedIterArgs[0];
  auto addOp = builder.create<mlir::arith::AddFOp>(fusedLoop.getLoc(),
                                                   currentSum, expResult);

  /* yield the new sum */
  builder.create<mlir::affine::AffineYieldOp>(fusedLoop.getLoc(),
                                              addOp.getResult());

  return fusedLoop;
}

/* manually fuse sum and div loops */
mlir::affine::AffineForOp fuseSumAndDivLoops(mlir::affine::AffineForOp sumLoop,
                                             mlir::affine::AffineForOp divLoop,
                                             mlir::Value sumValue,
                                             mlir::OpBuilder &builder) {

  llvm::outs() << "[manual fusion] fusing SUM+DIV loops\n";

  /* create new loop */
  builder.setInsertionPoint(sumLoop);
  auto fusedLoop = builder.create<mlir::affine::AffineForOp>(
      sumLoop.getLoc(), sumLoop.getLowerBoundOperands(),
      sumLoop.getLowerBoundMap(), sumLoop.getUpperBoundOperands(),
      sumLoop.getUpperBoundMap(), sumLoop.getStep());

  builder.setInsertionPointToStart(fusedLoop.getBody());
  mlir::IRMapping mapping;
  mapping.map(sumLoop.getInductionVar(), fusedLoop.getInductionVar());
  mapping.map(divLoop.getInductionVar(), fusedLoop.getInductionVar());

  /* clone sum loop body */
  for (auto &op : sumLoop.getBody()->without_terminator()) {
    builder.clone(op, mapping);
  }

  /* clone div loop body */
  for (auto &op : divLoop.getBody()->without_terminator()) {
    builder.clone(op, mapping);
  }

  return fusedLoop;
}

} /* anonymous namespace */

void SoftmaxFusion::runOnOperation() {
  mlir::func::FuncOp func = getOperation();
  mlir::OpBuilder builder(func.getContext());

  llvm::outs() << "\n--- analyzing function: " << func.getName() << " ---\n\n";

  /* collect and classify all loops */
  llvm::SmallVector<LoopInfo, 4> loopInfos;

  for (auto &block : func.getBody()) {
    for (auto &op : block) {
      if (auto loop = llvm::dyn_cast<mlir::affine::AffineForOp>(&op)) {
        LoopInfo info;
        info.loop = loop;
        info.type = classifyLoop(loop);
        loopInfos.push_back(info);

        /* print classification */
        switch (info.type) {
        case LoopInfo::MAX_REDUCTION:
          llvm::outs() << "[loop " << loopInfos.size() << "] MAX REDUCTION\n";
          break;
        case LoopInfo::EXP_COMPUTE:
          llvm::outs() << "[loop " << loopInfos.size() << "] EXP COMPUTE\n";
          break;
        case LoopInfo::SUM_REDUCTION:
          llvm::outs() << "[loop " << loopInfos.size() << "] SUM REDUCTION\n";
          break;
        case LoopInfo::DIV_NORMALIZE:
          llvm::outs() << "[loop " << loopInfos.size() << "] DIV NORMALIZE\n";
          break;
        default:
          llvm::outs() << "[loop " << loopInfos.size() << "] UNKNOWN\n";
        }
      }
    }
  }

  llvm::outs() << "\n--- [attempting loop fusion] ---\n";

  bool madeChanges = false;

  /* strategy 1: fuse EXP + SUM (loops 2 and 3) */
  /* this is the most important fusion for softmax performance */
  for (size_t i = 0; i < loopInfos.size() - 1; i++) {
    if (loopInfos[i].type == LoopInfo::EXP_COMPUTE &&
        loopInfos[i + 1].type == LoopInfo::SUM_REDUCTION) {

      llvm::outs() << "[fusion attempt] EXP (loop " << (i + 1)
                   << ") + SUM (loop " << (i + 2) << ")\n";

      /* try standard fusion first */
      mlir::affine::ComputationSliceState sliceState;
      mlir::affine::FusionResult result = mlir::affine::canFuseLoops(
          loopInfos[i].loop, loopInfos[i + 1].loop, 0, &sliceState);

      if (result.value == mlir::affine::FusionResult::Success) {
        llvm::outs() << "[success] using standard fusion\n";
        mlir::affine::fuseLoops(loopInfos[i].loop, loopInfos[i + 1].loop,
                                sliceState);
        loopInfos[i].loop->erase();
        madeChanges = true;
      } else {
        /* standard fusion failed, try manual fusion */
        llvm::outs() << "[info] standard fusion failed (code " << result.value
                     << "), attempting manual fusion\n";

        auto fusedLoop = fuseExpAndSumLoops(loopInfos[i].loop,
                                            loopInfos[i + 1].loop, builder);

        if (fusedLoop) {
          llvm::outs() << "[success] manual fusion completed\n";

          /* replace uses of sum loop result with fused loop result */
          loopInfos[i + 1].loop.getResult(0).replaceAllUsesWith(
              fusedLoop.getResult(0));

          /* erase old loops */
          loopInfos[i].loop->erase();
          loopInfos[i + 1].loop->erase();

          /* update loop info */
          loopInfos[i].loop = fusedLoop;
          loopInfos.erase(loopInfos.begin() + i + 1);
          madeChanges = true;
        } else {
          llvm::outs() << "[error] manual fusion failed\n";
        }
      }
      break;
    }
  }

  if (madeChanges) {
    llvm::outs() << "\n--- fusion successful ---\n";
  } else {
    llvm::outs() << "\n--- no fusion ---\n";
  }
  llvm::outs() << "\n";
}

std::unique_ptr<mlir::Pass> createSoftmaxFusionPass() {
  return std::make_unique<SoftmaxFusion>();
}
