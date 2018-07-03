; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -instcombine -S < %s | FileCheck %s

; Test that presence of range does not cause unprofitable transforms with bit
; arithmetics. InstCombine needs to be smart about dealing with range-annotated
; values.

define i1 @without_range(i32* %A) {
; CHECK-LABEL: @without_range(
; CHECK-NEXT:    [[A_VAL:%.*]] = load i32, i32* [[A:%.*]], align 8
; CHECK-NEXT:    [[C:%.*]] = icmp slt i32 [[A_VAL]], 2
; CHECK-NEXT:    ret i1 [[C]]
;
  %A.val = load i32, i32* %A, align 8
  %B = sdiv i32 %A.val, 2
  %C = icmp sge i32 0, %B
  ret i1 %C
}

define i1 @with_range(i32* %A) {
; CHECK-LABEL: @with_range(
; CHECK-NEXT:    [[A_VAL:%.*]] = load i32, i32* [[A:%.*]], align 8, !range !0
; CHECK-NEXT:    [[C:%.*]] = icmp ult i32 [[A_VAL]], 2
; CHECK-NEXT:    ret i1 [[C]]
;
  %A.val = load i32, i32* %A, align 8, !range !0
  %B = sdiv i32 %A.val, 2
  %C = icmp sge i32 0, %B
  ret i1 %C
}

!0 = !{i32 0, i32 2147483647}
