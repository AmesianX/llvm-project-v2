; RUN: opt < %s -correlated-propagation -S | FileCheck %s

; CHECK-LABEL: @test0(
define void @test0(i32 %a) {
entry:
  %cmp = icmp slt i32 %a, 100
  br i1 %cmp, label %bb, label %exit

bb:
; CHECK: %add = add nsw i32 %a, 1
  %add = add i32 %a, 1
  br label %exit

exit:
  ret void
}

; CHECK-LABEL: @test1(
define void @test1(i32 %a) {
entry:
  %cmp = icmp ult i32 %a, 100
  br i1 %cmp, label %bb, label %exit

bb:
; CHECK: %add = add nuw nsw i32 %a, 1
  %add = add i32 %a, 1
  br label %exit

exit:
  ret void
}

; CHECK-LABEL: @test2(
define void @test2(i32 %a) {
entry:
  %cmp = icmp ult i32 %a, -1
  br i1 %cmp, label %bb, label %exit

bb:
; CHECK: %add = add nuw i32 %a, 1
  %add = add i32 %a, 1
  br label %exit

exit:
  ret void
}

; CHECK-LABEL: @test3(
define void @test3(i32 %a) {
entry:
  %cmp = icmp ule i32 %a, -1
  br i1 %cmp, label %bb, label %exit

bb:
; CHECK: %add = add i32 %a, 1
  %add = add i32 %a, 1
  br label %exit

exit:
  ret void
}

; CHECK-LABEL: @test4(
define void @test4(i32 %a) {
entry:
  %cmp = icmp slt i32 %a, 2147483647
  br i1 %cmp, label %bb, label %exit

bb:
; CHECK: %add = add nsw i32 %a, 1
  %add = add i32 %a, 1
  br label %exit

exit:
  ret void
}

; CHECK-LABEL: @test5(
define void @test5(i32 %a) {
entry:
  %cmp = icmp sle i32 %a, 2147483647
  br i1 %cmp, label %bb, label %exit

bb:
; CHECK: %add = add i32 %a, 1
  %add = add i32 %a, 1
  br label %exit

exit:
  ret void
}

; Check for a corner case where an integer value is represented with a constant
; LVILatticeValue instead of constantrange. Check that we don't fail with an
; assertion in this case.
@b = global i32 0, align 4
define void @test6(i32 %a) {
bb:
  %add = add i32 %a, ptrtoint (i32* @b to i32)
  ret void
}

; Check that we can gather information for conditions is the form of
;   and ( i s< 100, Unknown )
; CHECK-LABEL: @test7(
define void @test7(i32 %a, i1 %flag) {
entry:
  %cmp.1 = icmp slt i32 %a, 100
  %cmp = and i1 %cmp.1, %flag
  br i1 %cmp, label %bb, label %exit

bb:
; CHECK: %add = add nsw i32 %a, 1
  %add = add i32 %a, 1
  br label %exit

exit:
  ret void
}

; Check that we can gather information for conditions is the form of
;   and ( i s< 100, i s> 0 )
; CHECK-LABEL: @test8(
define void @test8(i32 %a) {
entry:
  %cmp.1 = icmp slt i32 %a, 100
  %cmp.2 = icmp sgt i32 %a, 0
  %cmp = and i1 %cmp.1, %cmp.2
  br i1 %cmp, label %bb, label %exit

bb:
; CHECK: %add = add nuw nsw i32 %a, 1
  %add = add i32 %a, 1
  br label %exit

exit:
  ret void
}

; Check that for conditions is the form of cond1 && cond2 we don't mistakenly
; assume that !cond1 && !cond2 holds down to false path.
; CHECK-LABEL: @test8_neg(
define void @test8_neg(i32 %a) {
entry:
  %cmp.1 = icmp sge i32 %a, 100
  %cmp.2 = icmp sle i32 %a, 0
  %cmp = and i1 %cmp.1, %cmp.2
  br i1 %cmp, label %exit, label %bb

bb:
; CHECK: %add = add i32 %a, 1
  %add = add i32 %a, 1
  br label %exit

exit:
  ret void
}

; Check that we can gather information for conditions is the form of
;   and ( i s< 100, and (i s> 0, Unknown )
; CHECK-LABEL: @test9(
define void @test9(i32 %a, i1 %flag) {
entry:
  %cmp.1 = icmp slt i32 %a, 100
  %cmp.2 = icmp sgt i32 %a, 0
  %cmp.3 = and i1 %cmp.2, %flag
  %cmp = and i1 %cmp.1, %cmp.3
  br i1 %cmp, label %bb, label %exit

bb:
; CHECK: %add = add nuw nsw i32 %a, 1
  %add = add i32 %a, 1
  br label %exit

exit:
  ret void
}

; Check that we can gather information for conditions is the form of
;   and ( i s< Unknown, ... )
; CHECK-LABEL: @test10(
define void @test10(i32 %a, i32 %b, i1 %flag) {
entry:
  %cmp.1 = icmp slt i32 %a, %b
  %cmp = and i1 %cmp.1, %flag
  br i1 %cmp, label %bb, label %exit

bb:
; CHECK: %add = add nsw i32 %a, 1
  %add = add i32 %a, 1
  br label %exit

exit:
  ret void
}
