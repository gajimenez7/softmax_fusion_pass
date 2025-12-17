module attributes {dlti.dl_spec = #dlti.dl_spec<#dlti.dl_entry<f16, dense<16> : vector<2xi32>>, #dlti.dl_entry<i32, dense<32> : vector<2xi32>>, #dlti.dl_entry<f128, dense<128> : vector<2xi32>>, #dlti.dl_entry<!llvm.ptr<270>, dense<32> : vector<4xi32>>, #dlti.dl_entry<f64, dense<64> : vector<2xi32>>, #dlti.dl_entry<!llvm.ptr, dense<64> : vector<4xi32>>, #dlti.dl_entry<i1, dense<8> : vector<2xi32>>, #dlti.dl_entry<i8, dense<8> : vector<2xi32>>, #dlti.dl_entry<i16, dense<16> : vector<2xi32>>, #dlti.dl_entry<f80, dense<128> : vector<2xi32>>, #dlti.dl_entry<!llvm.ptr<271>, dense<32> : vector<4xi32>>, #dlti.dl_entry<!llvm.ptr<272>, dense<64> : vector<4xi32>>, #dlti.dl_entry<i64, dense<64> : vector<2xi32>>, #dlti.dl_entry<"dlti.endianness", "little">, #dlti.dl_entry<"dlti.stack_alignment", 128 : i32>>, llvm.data_layout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128", llvm.target_triple = "x86_64-unknown-linux-gnu", "polygeist.target-cpu" = "x86-64", "polygeist.target-features" = "+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87", "polygeist.tune-cpu" = "generic"} {
  func.func @softmax(%arg0: memref<?xf32>, %arg1: memref<?xf32>, %arg2: i32) attributes {llvm.linkage = #llvm.linkage<external>} {
    %cst = arith.constant 0.000000e+00 : f32
    %cst_0 = arith.constant -1.000000e+09 : f32
    %0 = arith.index_cast %arg2 : i32 to index
    %1 = affine.for %arg3 = 0 to %0 iter_args(%arg4 = %cst_0) -> (f32) {
      %3 = affine.load %arg0[%arg3] : memref<?xf32>
      %4 = arith.extf %3 : f32 to f64
      %5 = arith.extf %arg4 : f32 to f64
      %6 = arith.cmpf ogt, %4, %5 : f64
      %7 = scf.if %6 -> (f32) {
        %8 = arith.truncf %4 : f64 to f32
        scf.yield %8 : f32
      } else {
        scf.yield %arg4 : f32
      }
      affine.yield %7 : f32
    }
    %2 = affine.for %arg3 = 0 to %0 iter_args(%arg4 = %cst) -> (f32) {
      %3 = affine.load %arg0[%arg3] : memref<?xf32>
      %4 = arith.subf %3, %1 : f32
      %5 = math.exp %4 : f32
      affine.store %5, %arg1[%arg3] : memref<?xf32>
      %6 = arith.addf %arg4, %5 : f32
      affine.yield %6 : f32
    }
    affine.for %arg3 = 0 to %0 {
      %3 = affine.load %arg1[%arg3] : memref<?xf32>
      %4 = arith.divf %3, %2 : f32
      affine.store %4, %arg1[%arg3] : memref<?xf32>
    }
    return
  }
}

