; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s  -slp-vectorizer -S -mtriple=i386--netbsd -mcpu=i486 | FileCheck %s
target datalayout = "e-p:32:32:32-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:32:64-f32:32:32-f64:32:64-v64:64:64-v128:128:128-a0:0:64-f80:32:32-n8:16:32-S128"
target triple = "i386--netbsd"

@a = common global i32* null, align 4

; Function Attrs: noreturn nounwind readonly
define i32 @fn1() #0 {
; CHECK-LABEL: @fn1(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = load i32*, i32** @a, align 4, !tbaa !0
; CHECK-NEXT:    [[TMP1:%.*]] = load i32, i32* [[TMP0]], align 4, !tbaa !4
; CHECK-NEXT:    [[ARRAYIDX1:%.*]] = getelementptr inbounds i32, i32* [[TMP0]], i32 1
; CHECK-NEXT:    [[TMP2:%.*]] = load i32, i32* [[ARRAYIDX1]], align 4, !tbaa !4
; CHECK-NEXT:    br label [[DO_BODY:%.*]]
; CHECK:       do.body:
; CHECK-NEXT:    [[C_0:%.*]] = phi i32 [ [[TMP2]], [[ENTRY:%.*]] ], [ [[ADD2:%.*]], [[DO_BODY]] ]
; CHECK-NEXT:    [[B_0:%.*]] = phi i32 [ [[TMP1]], [[ENTRY]] ], [ [[ADD:%.*]], [[DO_BODY]] ]
; CHECK-NEXT:    [[ADD]] = add nsw i32 [[B_0]], [[C_0]]
; CHECK-NEXT:    [[ADD2]] = add nsw i32 [[ADD]], 1
; CHECK-NEXT:    br label [[DO_BODY]]
;
entry:
  %0 = load i32*, i32** @a, align 4, !tbaa !4
  %1 = load i32, i32* %0, align 4, !tbaa !5
  %arrayidx1 = getelementptr inbounds i32, i32* %0, i32 1
  %2 = load i32, i32* %arrayidx1, align 4, !tbaa !5
  br label %do.body

do.body:                                          ; preds = %do.body, %entry
  %c.0 = phi i32 [ %2, %entry ], [ %add2, %do.body ]
  %b.0 = phi i32 [ %1, %entry ], [ %add, %do.body ]
  %add = add nsw i32 %b.0, %c.0
  %add2 = add nsw i32 %add, 1
  br label %do.body
}

attributes #0 = { noreturn nounwind readonly "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }

!0 = !{!"any pointer", !1}
!1 = !{!"omnipotent char", !2}
!2 = !{!"Simple C/C++ TBAA"}
!3 = !{!"int", !1}
!4 = !{!0, !0, i64 0}
!5 = !{!3, !3, i64 0}
