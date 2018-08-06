; RUN: opt < %s -instcombine -S | FileCheck %s
; RUN: opt -debugify -instcombine -S < %s | FileCheck %s -check-prefix DBGINFO

target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32"

define i32 @mul(i32 %x, i32 %y) {
; CHECK-LABEL: @mul(
; CHECK-NEXT:    [[C:%.*]] = mul i32 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[D:%.*]] = and i32 [[C]], 255
; CHECK-NEXT:    ret i32 [[D]]

; Test that when zext is evaluated in different type
; we preserve the debug information in the resulting
; instruction.
; DBGINFO-LABEL: @mul(
; DBGINFO-NEXT:    [[C:%.*]] = mul i32 {{.*}}
; DBGINFO-NEXT:    [[D:%.*]] = and i32 {{.*}}
; DBGINFO-NEXT:    call void @llvm.dbg.value(metadata i32 [[C]]
; DBGINFO-NEXT:    call void @llvm.dbg.value(metadata i32 [[D]]

  %A = trunc i32 %x to i8
  %B = trunc i32 %y to i8
  %C = mul i8 %A, %B
  %D = zext i8 %C to i32
  ret i32 %D
}

define i32 @select1(i1 %cond, i32 %x, i32 %y, i32 %z) {
; CHECK-LABEL: @select1(
; CHECK-NEXT:    [[D:%.*]] = add i32 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[E:%.*]] = select i1 [[COND:%.*]], i32 [[Z:%.*]], i32 [[D]]
; CHECK-NEXT:    [[F:%.*]] = and i32 [[E]], 255
; CHECK-NEXT:    ret i32 [[F]]
;
  %A = trunc i32 %x to i8
  %B = trunc i32 %y to i8
  %C = trunc i32 %z to i8
  %D = add i8 %A, %B
  %E = select i1 %cond, i8 %C, i8 %D
  %F = zext i8 %E to i32
  ret i32 %F
}

define i8 @select2(i1 %cond, i8 %x, i8 %y, i8 %z) {
; CHECK-LABEL: @select2(
; CHECK-NEXT:    [[D:%.*]] = add i8 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[E:%.*]] = select i1 [[COND:%.*]], i8 [[Z:%.*]], i8 [[D]]
; CHECK-NEXT:    ret i8 [[E]]
;
  %A = zext i8 %x to i32
  %B = zext i8 %y to i32
  %C = zext i8 %z to i32
  %D = add i32 %A, %B
  %E = select i1 %cond, i32 %C, i32 %D
  %F = trunc i32 %E to i8
  ret i8 %F
}

; The next 3 tests could be handled in instcombine, but evaluating values
; with multiple uses may be very slow. Let some other pass deal with it.

define i32 @eval_trunc_multi_use_in_one_inst(i32 %x) {
; CHECK-LABEL: @eval_trunc_multi_use_in_one_inst(
; CHECK-NEXT:    [[Z:%.*]] = zext i32 [[X:%.*]] to i64
; CHECK-NEXT:    [[A:%.*]] = add nuw nsw i64 [[Z]], 15
; CHECK-NEXT:    [[M:%.*]] = mul i64 [[A]], [[A]]
; CHECK-NEXT:    [[T:%.*]] = trunc i64 [[M]] to i32
; CHECK-NEXT:    ret i32 [[T]]
;
  %z = zext i32 %x to i64
  %a = add nsw nuw i64 %z, 15
  %m = mul i64 %a, %a
  %t = trunc i64 %m to i32
  ret i32 %t
}

define i32 @eval_zext_multi_use_in_one_inst(i32 %x) {
; CHECK-LABEL: @eval_zext_multi_use_in_one_inst(
; CHECK-NEXT:    [[T:%.*]] = trunc i32 [[X:%.*]] to i16
; CHECK-NEXT:    [[A:%.*]] = and i16 [[T]], 5
; CHECK-NEXT:    [[M:%.*]] = mul nuw nsw i16 [[A]], [[A]]
; CHECK-NEXT:    [[R:%.*]] = zext i16 [[M]] to i32
; CHECK-NEXT:    ret i32 [[R]]
;
  %t = trunc i32 %x to i16
  %a = and i16 %t, 5
  %m = mul nuw nsw i16 %a, %a
  %r = zext i16 %m to i32
  ret i32 %r
}

define i32 @eval_sext_multi_use_in_one_inst(i32 %x) {
; CHECK-LABEL: @eval_sext_multi_use_in_one_inst(
; CHECK-NEXT:    [[T:%.*]] = trunc i32 [[X:%.*]] to i16
; CHECK-NEXT:    [[A:%.*]] = and i16 [[T]], 14
; CHECK-NEXT:    [[M:%.*]] = mul nuw nsw i16 [[A]], [[A]]
; CHECK-NEXT:    [[O:%.*]] = or i16 [[M]], -32768
; CHECK-NEXT:    [[R:%.*]] = sext i16 [[O]] to i32
; CHECK-NEXT:    ret i32 [[R]]
;
  %t = trunc i32 %x to i16
  %a = and i16 %t, 14
  %m = mul nuw nsw i16 %a, %a
  %o = or i16 %m, 32768
  %r = sext i16 %o to i32
  ret i32 %r
}

; If we have a transform to shrink the above 3 cases, make sure it's not
; also trying to look through multiple uses in this test and crashing.

define void @PR36225(i32 %a, i32 %b) {
; CHECK-LABEL: @PR36225(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[WHILE_BODY:%.*]]
; CHECK:       while.body:
; CHECK-NEXT:    br i1 undef, label [[FOR_BODY3_US:%.*]], label [[FOR_BODY3:%.*]]
; CHECK:       for.body3.us:
; CHECK-NEXT:    [[TOBOOL:%.*]] = icmp eq i32 [[B:%.*]], 0
; CHECK-NEXT:    [[SPEC_SELECT:%.*]] = select i1 [[TOBOOL]], i8 0, i8 4
; CHECK-NEXT:    switch i3 undef, label [[EXIT:%.*]] [
; CHECK-NEXT:    i3 0, label [[FOR_END:%.*]]
; CHECK-NEXT:    i3 -1, label [[FOR_END]]
; CHECK-NEXT:    ]
; CHECK:       for.body3:
; CHECK-NEXT:    switch i3 undef, label [[EXIT]] [
; CHECK-NEXT:    i3 0, label [[FOR_END]]
; CHECK-NEXT:    i3 -1, label [[FOR_END]]
; CHECK-NEXT:    ]
; CHECK:       for.end:
; CHECK-NEXT:    [[H:%.*]] = phi i8 [ [[SPEC_SELECT]], [[FOR_BODY3_US]] ], [ [[SPEC_SELECT]], [[FOR_BODY3_US]] ], [ 0, [[FOR_BODY3]] ], [ 0, [[FOR_BODY3]] ]
; CHECK-NEXT:    [[TMP0:%.*]] = zext i8 [[H]] to i32
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i32 [[TMP0]], [[A:%.*]]
; CHECK-NEXT:    br i1 [[CMP]], label [[EXIT]], label [[EXIT2:%.*]]
; CHECK:       exit2:
; CHECK-NEXT:    unreachable
; CHECK:       exit:
; CHECK-NEXT:    unreachable
;
entry:
  br label %while.body

while.body:
  %tobool = icmp eq i32 %b, 0
  br i1 undef, label %for.body3.us, label %for.body3

for.body3.us:
  %spec.select = select i1 %tobool, i8 0, i8 4
  switch i3 undef, label %exit [
  i3 0, label %for.end
  i3 -1, label %for.end
  ]

for.body3:
  switch i3 undef, label %exit [
  i3 0, label %for.end
  i3 -1, label %for.end
  ]

for.end:
  %h = phi i8 [ %spec.select, %for.body3.us ], [ %spec.select, %for.body3.us ], [ 0, %for.body3 ], [ 0, %for.body3 ]
  %conv = sext i8 %h to i32
  %cmp = icmp sgt i32 %a, %conv
  br i1 %cmp, label %exit, label %exit2

exit2:
  unreachable

exit:
  unreachable
}

