#include "../SoftmaxFusion.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/Affine/Passes.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/DLTI/DLTI.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Dialect/Math/IR/Math.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Pass/PassRegistry.h"
#include "mlir/Tools/mlir-opt/MlirOptMain.h"
#include "mlir/Transforms/Passes.h"
#include <mlir/IR/DialectRegistry.h>
#include <mlir/Transforms/Passes.h>

int main(int argc, char **argv) {

  mlir::registerCanonicalizerPass();
  mlir::registerCSEPass();
  mlir::affine::registerAffinePasses();
  mlir::DialectRegistry registry;

  registry.insert<mlir::affine::AffineDialect, mlir::func::FuncDialect,
                  mlir::memref::MemRefDialect, mlir::scf::SCFDialect,
                  mlir::arith::ArithDialect, mlir::math::MathDialect,
                  mlir::DLTIDialect, mlir::LLVM::LLVMDialect>();

  mlir::PassRegistration<SoftmaxFusion>();

  return mlir::asMainReturnCode(
      mlir::MlirOptMain(argc, argv, "Softmax Optimzer Driver", registry));
}
