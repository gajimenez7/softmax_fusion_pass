module attributes {dlti.dl_spec = #dlti.dl_spec<#dlti.dl_entry<f16, dense<16> : vector<2xi32>>, #dlti.dl_entry<i32, dense<32> : vector<2xi32>>, #dlti.dl_entry<f128, dense<128> : vector<2xi32>>, #dlti.dl_entry<!llvm.ptr<270>, dense<32> : vector<4xi32>>, #dlti.dl_entry<f64, dense<64> : vector<2xi32>>, #dlti.dl_entry<!llvm.ptr, dense<64> : vector<4xi32>>, #dlti.dl_entry<i1, dense<8> : vector<2xi32>>, #dlti.dl_entry<i8, dense<8> : vector<2xi32>>, #dlti.dl_entry<i16, dense<16> : vector<2xi32>>, #dlti.dl_entry<f80, dense<128> : vector<2xi32>>, #dlti.dl_entry<!llvm.ptr<271>, dense<32> : vector<4xi32>>, #dlti.dl_entry<!llvm.ptr<272>, dense<64> : vector<4xi32>>, #dlti.dl_entry<i64, dense<64> : vector<2xi32>>, #dlti.dl_entry<"dlti.endianness", "little">, #dlti.dl_entry<"dlti.stack_alignment", 128 : i32>>, llvm.data_layout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128", llvm.target_triple = "x86_64-unknown-linux-gnu", "polygeist.target-cpu" = "x86-64", "polygeist.target-features" = "+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87", "polygeist.tune-cpu" = "generic"} {
  llvm.func @softmax(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: i64, %arg3: i64, %arg4: i64, %arg5: !llvm.ptr, %arg6: !llvm.ptr, %arg7: i64, %arg8: i64, %arg9: i64, %arg10: i32) {
    %0 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %1 = llvm.insertvalue %arg0, %0[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %2 = llvm.insertvalue %arg1, %1[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %3 = llvm.insertvalue %arg2, %2[2] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %4 = llvm.insertvalue %arg3, %3[3, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %5 = llvm.insertvalue %arg4, %4[4, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %6 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %7 = llvm.insertvalue %arg5, %6[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %8 = llvm.insertvalue %arg6, %7[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %9 = llvm.insertvalue %arg7, %8[2] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %10 = llvm.insertvalue %arg8, %9[3, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %11 = llvm.insertvalue %arg9, %10[4, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %12 = llvm.mlir.constant(0.000000e+00 : f32) : f32
    %13 = llvm.mlir.constant(-1.000000e+09 : f32) : f32
    %14 = llvm.sext %arg10 : i32 to i64
    %15 = llvm.mlir.constant(0 : index) : i64
    %16 = llvm.mlir.constant(1 : index) : i64
    llvm.br ^bb1(%15, %13 : i64, f32)
  ^bb1(%17: i64, %18: f32):  // 2 preds: ^bb0, ^bb6
    %19 = llvm.icmp "slt" %17, %14 : i64
    llvm.cond_br %19, ^bb2, ^bb7
  ^bb2:  // pred: ^bb1
    %20 = llvm.getelementptr %arg1[%17] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %21 = llvm.load %20 : !llvm.ptr -> f32
    %22 = llvm.fpext %21 : f32 to f64
    %23 = llvm.fpext %18 : f32 to f64
    %24 = llvm.fcmp "ogt" %22, %23 : f64
    llvm.cond_br %24, ^bb3, ^bb4
  ^bb3:  // pred: ^bb2
    %25 = llvm.fptrunc %22 : f64 to f32
    llvm.br ^bb5(%25 : f32)
  ^bb4:  // pred: ^bb2
    llvm.br ^bb5(%18 : f32)
  ^bb5(%26: f32):  // 2 preds: ^bb3, ^bb4
    llvm.br ^bb6
  ^bb6:  // pred: ^bb5
    %27 = llvm.add %17, %16  : i64
    llvm.br ^bb1(%27, %26 : i64, f32)
  ^bb7:  // pred: ^bb1
    %28 = llvm.mlir.constant(0 : index) : i64
    %29 = llvm.mlir.constant(1 : index) : i64
    llvm.br ^bb8(%28, %12 : i64, f32)
  ^bb8(%30: i64, %31: f32):  // 2 preds: ^bb7, ^bb9
    %32 = llvm.icmp "slt" %30, %14 : i64
    llvm.cond_br %32, ^bb9, ^bb10
  ^bb9:  // pred: ^bb8
    %33 = llvm.getelementptr %arg1[%30] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %34 = llvm.load %33 : !llvm.ptr -> f32
    %35 = llvm.fsub %34, %18  : f32
    %36 = llvm.intr.exp(%35)  : (f32) -> f32
    %37 = llvm.getelementptr %arg6[%30] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %36, %37 : f32, !llvm.ptr
    %38 = llvm.fadd %31, %36  : f32
    %39 = llvm.add %30, %29  : i64
    llvm.br ^bb8(%39, %38 : i64, f32)
  ^bb10:  // pred: ^bb8
    %40 = llvm.mlir.constant(0 : index) : i64
    %41 = llvm.mlir.constant(1 : index) : i64
    llvm.br ^bb11(%40 : i64)
  ^bb11(%42: i64):  // 2 preds: ^bb10, ^bb12
    %43 = llvm.icmp "slt" %42, %14 : i64
    llvm.cond_br %43, ^bb12, ^bb13
  ^bb12:  // pred: ^bb11
    %44 = llvm.getelementptr %arg6[%42] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %45 = llvm.load %44 : !llvm.ptr -> f32
    %46 = llvm.fdiv %45, %31  : f32
    %47 = llvm.getelementptr %arg6[%42] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %46, %47 : f32, !llvm.ptr
    %48 = llvm.add %42, %41  : i64
    llvm.br ^bb11(%48 : i64)
  ^bb13:  // pred: ^bb11
    llvm.return
  }
}

