#ifndef SOFTMAX_FUSION_H
#define SOFTMAX_FUSION_H

#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Pass/Pass.h"
#include <memory>
#include <mlir/Pass/PassRegistry.h>
#include <mlir/Support/TypeID.h>

struct SoftmaxFusion
    : public mlir::PassWrapper<SoftmaxFusion,
                               mlir::OperationPass<mlir::func::FuncOp>> {

  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(SoftmaxFusion);

  /* cmd line argument for pass */
  llvm::StringRef getArgument() const override { return "softmax-fusion"; }

  /* description help menus */
  llvm::StringRef getDescription() const override {
    return "Fuses adjacent loops in softmax kernels";
  };

  /* main pass logic */
  void runOnOperation() override;

  /* register pass */
  void registerSoftmaxFusionPass() {
    mlir::PassRegistration<SoftmaxFusion>([]() -> std::unique_ptr<mlir::Pass> {
      std::unique_ptr<mlir::Pass> p = std::make_unique<SoftmaxFusion>();
      return p;
    });
  }
};

std::unique_ptr<mlir::Pass> createSoftmaxFusionPass();

#endif
