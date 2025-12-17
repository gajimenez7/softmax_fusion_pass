; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

declare ptr @malloc(i64)

declare void @free(ptr)

define void @softmax(ptr %0, ptr %1, i64 %2, i64 %3, i64 %4, ptr %5, ptr %6, i64 %7, i64 %8, i64 %9, i32 %10) {
  %12 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } undef, ptr %0, 0
  %13 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %12, ptr %1, 1
  %14 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %13, i64 %2, 2
  %15 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %14, i64 %3, 3, 0
  %16 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %15, i64 %4, 4, 0
  %17 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } undef, ptr %5, 0
  %18 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %17, ptr %6, 1
  %19 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %18, i64 %7, 2
  %20 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %19, i64 %8, 3, 0
  %21 = insertvalue { ptr, ptr, i64, [1 x i64], [1 x i64] } %20, i64 %9, 4, 0
  %22 = sext i32 %10 to i64
  br label %23

23:                                               ; preds = %38, %11
  %24 = phi i64 [ %39, %38 ], [ 0, %11 ]
  %25 = phi float [ %37, %38 ], [ -1.000000e+09, %11 ]
  %26 = icmp slt i64 %24, %22
  br i1 %26, label %27, label %40

27:                                               ; preds = %23
  %28 = getelementptr float, ptr %1, i64 %24
  %29 = load float, ptr %28, align 4
  %30 = fpext float %29 to double
  %31 = fpext float %25 to double
  %32 = fcmp ogt double %30, %31
  br i1 %32, label %33, label %35

33:                                               ; preds = %27
  %34 = fptrunc double %30 to float
  br label %36

35:                                               ; preds = %27
  br label %36

36:                                               ; preds = %33, %35
  %37 = phi float [ %25, %35 ], [ %34, %33 ]
  br label %38

38:                                               ; preds = %36
  %39 = add i64 %24, 1
  br label %23

40:                                               ; preds = %23
  %41 = sext i32 %10 to i64
  br label %42

42:                                               ; preds = %45, %40
  %43 = phi i64 [ %51, %45 ], [ 0, %40 ]
  %44 = icmp slt i64 %43, %41
  br i1 %44, label %45, label %52

45:                                               ; preds = %42
  %46 = getelementptr float, ptr %1, i64 %43
  %47 = load float, ptr %46, align 4
  %48 = fsub float %47, %25
  %49 = call float @llvm.exp.f32(float %48)
  %50 = getelementptr float, ptr %6, i64 %43
  store float %49, ptr %50, align 4
  %51 = add i64 %43, 1
  br label %42

52:                                               ; preds = %42
  %53 = sext i32 %10 to i64
  br label %54

54:                                               ; preds = %58, %52
  %55 = phi i64 [ %62, %58 ], [ 0, %52 ]
  %56 = phi float [ %61, %58 ], [ 0.000000e+00, %52 ]
  %57 = icmp slt i64 %55, %53
  br i1 %57, label %58, label %63

58:                                               ; preds = %54
  %59 = getelementptr float, ptr %6, i64 %55
  %60 = load float, ptr %59, align 4
  %61 = fadd float %56, %60
  %62 = add i64 %55, 1
  br label %54

63:                                               ; preds = %54
  %64 = sext i32 %10 to i64
  br label %65

65:                                               ; preds = %68, %63
  %66 = phi i64 [ %73, %68 ], [ 0, %63 ]
  %67 = icmp slt i64 %66, %64
  br i1 %67, label %68, label %74

68:                                               ; preds = %65
  %69 = getelementptr float, ptr %6, i64 %66
  %70 = load float, ptr %69, align 4
  %71 = fdiv float %70, %56
  %72 = getelementptr float, ptr %6, i64 %66
  store float %71, ptr %72, align 4
  %73 = add i64 %66, 1
  br label %65

74:                                               ; preds = %65
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare float @llvm.exp.f32(float) #0

attributes #0 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
