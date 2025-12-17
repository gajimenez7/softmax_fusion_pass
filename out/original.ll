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
  br label %41

41:                                               ; preds = %44, %40
  %42 = phi i64 [ %50, %44 ], [ 0, %40 ]
  %43 = icmp slt i64 %42, %22
  br i1 %43, label %44, label %51

44:                                               ; preds = %41
  %45 = getelementptr float, ptr %1, i64 %42
  %46 = load float, ptr %45, align 4
  %47 = fsub float %46, %25
  %48 = call float @llvm.exp.f32(float %47)
  %49 = getelementptr float, ptr %6, i64 %42
  store float %48, ptr %49, align 4
  %50 = add i64 %42, 1
  br label %41

51:                                               ; preds = %41
  br label %52

52:                                               ; preds = %56, %51
  %53 = phi i64 [ %60, %56 ], [ 0, %51 ]
  %54 = phi float [ %59, %56 ], [ 0.000000e+00, %51 ]
  %55 = icmp slt i64 %53, %22
  br i1 %55, label %56, label %61

56:                                               ; preds = %52
  %57 = getelementptr float, ptr %6, i64 %53
  %58 = load float, ptr %57, align 4
  %59 = fadd float %54, %58
  %60 = add i64 %53, 1
  br label %52

61:                                               ; preds = %52
  br label %62

62:                                               ; preds = %65, %61
  %63 = phi i64 [ %70, %65 ], [ 0, %61 ]
  %64 = icmp slt i64 %63, %22
  br i1 %64, label %65, label %71

65:                                               ; preds = %62
  %66 = getelementptr float, ptr %6, i64 %63
  %67 = load float, ptr %66, align 4
  %68 = fdiv float %67, %54
  %69 = getelementptr float, ptr %6, i64 %63
  store float %68, ptr %69, align 4
  %70 = add i64 %63, 1
  br label %62

71:                                               ; preds = %62
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare float @llvm.exp.f32(float) #0

attributes #0 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
