; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -codegenprepare -S < %s | FileCheck %s
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

declare void @use(i32) local_unnamed_addr
declare void @useptr([2 x i8*]*) local_unnamed_addr

; CHECK: @simple.targets = constant [2 x i8*] [i8* blockaddress(@simple, %bb0), i8* blockaddress(@simple, %bb1)], align 16
@simple.targets = constant [2 x i8*] [i8* blockaddress(@simple, %bb0), i8* blockaddress(@simple, %bb1)], align 16

; CHECK: @multi.targets = constant [2 x i8*] [i8* blockaddress(@multi, %bb0), i8* blockaddress(@multi, %bb1)], align 16
@multi.targets = constant [2 x i8*] [i8* blockaddress(@multi, %bb0), i8* blockaddress(@multi, %bb1)], align 16

; CHECK: @loop.targets = constant [2 x i8*] [i8* blockaddress(@loop, %bb0), i8* blockaddress(@loop, %bb1)], align 16
@loop.targets = constant [2 x i8*] [i8* blockaddress(@loop, %bb0), i8* blockaddress(@loop, %bb1)], align 16

; CHECK: @nophi.targets = constant [2 x i8*] [i8* blockaddress(@nophi, %bb0), i8* blockaddress(@nophi, %bb1)], align 16
@nophi.targets = constant [2 x i8*] [i8* blockaddress(@nophi, %bb0), i8* blockaddress(@nophi, %bb1)], align 16

; CHECK: @noncritical.targets = constant [2 x i8*] [i8* blockaddress(@noncritical, %bb0), i8* blockaddress(@noncritical, %bb1)], align 16
@noncritical.targets = constant [2 x i8*] [i8* blockaddress(@noncritical, %bb0), i8* blockaddress(@noncritical, %bb1)], align 16

; Check that we break the critical edge when an jump table has only one use.
define void @simple(i32* nocapture readonly %p) {
; CHECK-LABEL: @simple(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[INCDEC_PTR:%.*]] = getelementptr inbounds i32, i32* [[P:%.*]], i64 1
; CHECK-NEXT:    [[INITVAL:%.*]] = load i32, i32* [[P]], align 4
; CHECK-NEXT:    [[INITOP:%.*]] = load i32, i32* [[INCDEC_PTR]], align 4
; CHECK-NEXT:    switch i32 [[INITOP]], label [[EXIT:%.*]] [
; CHECK-NEXT:    i32 0, label [[BB0_CLONE:%.*]]
; CHECK-NEXT:    i32 1, label [[BB1_CLONE:%.*]]
; CHECK-NEXT:    ]
; CHECK:       bb0:
; CHECK-NEXT:    br label [[DOTSPLIT:%.*]]
; CHECK:       .split:
; CHECK-NEXT:    [[MERGE:%.*]] = phi i32* [ [[PTR:%.*]], [[BB0:%.*]] ], [ [[INCDEC_PTR]], [[BB0_CLONE]] ]
; CHECK-NEXT:    [[MERGE2:%.*]] = phi i32 [ 0, [[BB0]] ], [ [[INITVAL]], [[BB0_CLONE]] ]
; CHECK-NEXT:    tail call void @use(i32 [[MERGE2]])
; CHECK-NEXT:    br label [[INDIRECTGOTO:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    br label [[DOTSPLIT3:%.*]]
; CHECK:       .split3:
; CHECK-NEXT:    [[MERGE5:%.*]] = phi i32* [ [[PTR]], [[BB1:%.*]] ], [ [[INCDEC_PTR]], [[BB1_CLONE]] ]
; CHECK-NEXT:    [[MERGE7:%.*]] = phi i32 [ 1, [[BB1]] ], [ [[INITVAL]], [[BB1_CLONE]] ]
; CHECK-NEXT:    tail call void @use(i32 [[MERGE7]])
; CHECK-NEXT:    br label [[INDIRECTGOTO]]
; CHECK:       indirectgoto:
; CHECK-NEXT:    [[P_ADDR_SINK:%.*]] = phi i32* [ [[MERGE5]], [[DOTSPLIT3]] ], [ [[MERGE]], [[DOTSPLIT]] ]
; CHECK-NEXT:    [[PTR]] = getelementptr inbounds i32, i32* [[P_ADDR_SINK]], i64 1
; CHECK-NEXT:    [[NEWP:%.*]] = load i32, i32* [[P_ADDR_SINK]], align 4
; CHECK-NEXT:    [[IDX:%.*]] = sext i32 [[NEWP]] to i64
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds [2 x i8*], [2 x i8*]* @simple.targets, i64 0, i64 [[IDX]]
; CHECK-NEXT:    [[NEWOP:%.*]] = load i8*, i8** [[ARRAYIDX]], align 8
; CHECK-NEXT:    indirectbr i8* [[NEWOP]], [label [[BB0]], label %bb1]
; CHECK:       exit:
; CHECK-NEXT:    ret void
; CHECK:       bb0.clone:
; CHECK-NEXT:    br label [[DOTSPLIT]]
; CHECK:       bb1.clone:
; CHECK-NEXT:    br label [[DOTSPLIT3]]
;
entry:
  %incdec.ptr = getelementptr inbounds i32, i32* %p, i64 1
  %initval = load i32, i32* %p, align 4
  %initop = load i32, i32* %incdec.ptr, align 4
  switch i32 %initop, label %exit [
  i32 0, label %bb0
  i32 1, label %bb1
  ]

bb0:
  %p.addr.0 = phi i32* [ %incdec.ptr, %entry ], [ %ptr, %indirectgoto ]
  %opcode.0 = phi i32 [ %initval, %entry ], [ 0, %indirectgoto ]
  tail call void @use(i32 %opcode.0)
  br label %indirectgoto

bb1:
  %p.addr.1 = phi i32* [ %incdec.ptr, %entry ], [ %ptr, %indirectgoto ]
  %opcode.1 = phi i32 [ %initval, %entry ], [ 1, %indirectgoto ]
  tail call void @use(i32 %opcode.1)
  br label %indirectgoto

indirectgoto:
  %p.addr.sink = phi i32* [ %p.addr.1, %bb1 ], [ %p.addr.0, %bb0 ]
  %ptr = getelementptr inbounds i32, i32* %p.addr.sink, i64 1
  %newp = load i32, i32* %p.addr.sink, align 4
  %idx = sext i32 %newp to i64
  %arrayidx = getelementptr inbounds [2 x i8*], [2 x i8*]* @simple.targets, i64 0, i64 %idx
  %newop = load i8*, i8** %arrayidx, align 8
  indirectbr i8* %newop, [label %bb0, label %bb1]

exit:
  ret void
}

; Don't try to break critical edges when several indirectbr point to a single block
define void @multi(i32* nocapture readonly %p) {
; CHECK-LABEL: @multi(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[INCDEC_PTR:%.*]] = getelementptr inbounds i32, i32* [[P:%.*]], i64 1
; CHECK-NEXT:    [[INITVAL:%.*]] = load i32, i32* [[P]], align 4
; CHECK-NEXT:    [[INITOP:%.*]] = load i32, i32* [[INCDEC_PTR]], align 4
; CHECK-NEXT:    switch i32 [[INITOP]], label [[EXIT:%.*]] [
; CHECK-NEXT:    i32 0, label [[BB0:%.*]]
; CHECK-NEXT:    i32 1, label [[BB1:%.*]]
; CHECK-NEXT:    ]
; CHECK:       bb0:
; CHECK-NEXT:    [[P_ADDR_0:%.*]] = phi i32* [ [[INCDEC_PTR]], [[ENTRY:%.*]] ], [ [[NEXT0:%.*]], [[BB0]] ], [ [[NEXT1:%.*]], [[BB1]] ]
; CHECK-NEXT:    [[OPCODE_0:%.*]] = phi i32 [ [[INITVAL]], [[ENTRY]] ], [ 0, [[BB0]] ], [ 1, [[BB1]] ]
; CHECK-NEXT:    tail call void @use(i32 [[OPCODE_0]])
; CHECK-NEXT:    [[NEXT0]] = getelementptr inbounds i32, i32* [[P_ADDR_0]], i64 1
; CHECK-NEXT:    [[NEWP0:%.*]] = load i32, i32* [[P_ADDR_0]], align 4
; CHECK-NEXT:    [[IDX0:%.*]] = sext i32 [[NEWP0]] to i64
; CHECK-NEXT:    [[ARRAYIDX0:%.*]] = getelementptr inbounds [2 x i8*], [2 x i8*]* @multi.targets, i64 0, i64 [[IDX0]]
; CHECK-NEXT:    [[NEWOP0:%.*]] = load i8*, i8** [[ARRAYIDX0]], align 8
; CHECK-NEXT:    indirectbr i8* [[NEWOP0]], [label [[BB0]], label %bb1]
; CHECK:       bb1:
; CHECK-NEXT:    [[P_ADDR_1:%.*]] = phi i32* [ [[INCDEC_PTR]], [[ENTRY]] ], [ [[NEXT0]], [[BB0]] ], [ [[NEXT1]], [[BB1]] ]
; CHECK-NEXT:    [[OPCODE_1:%.*]] = phi i32 [ [[INITVAL]], [[ENTRY]] ], [ 0, [[BB0]] ], [ 1, [[BB1]] ]
; CHECK-NEXT:    tail call void @use(i32 [[OPCODE_1]])
; CHECK-NEXT:    [[NEXT1]] = getelementptr inbounds i32, i32* [[P_ADDR_1]], i64 1
; CHECK-NEXT:    [[NEWP1:%.*]] = load i32, i32* [[P_ADDR_1]], align 4
; CHECK-NEXT:    [[IDX1:%.*]] = sext i32 [[NEWP1]] to i64
; CHECK-NEXT:    [[ARRAYIDX1:%.*]] = getelementptr inbounds [2 x i8*], [2 x i8*]* @multi.targets, i64 0, i64 [[IDX1]]
; CHECK-NEXT:    [[NEWOP1:%.*]] = load i8*, i8** [[ARRAYIDX1]], align 8
; CHECK-NEXT:    indirectbr i8* [[NEWOP1]], [label [[BB0]], label %bb1]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  %incdec.ptr = getelementptr inbounds i32, i32* %p, i64 1
  %initval = load i32, i32* %p, align 4
  %initop = load i32, i32* %incdec.ptr, align 4
  switch i32 %initop, label %exit [
  i32 0, label %bb0
  i32 1, label %bb1
  ]

bb0:
  %p.addr.0 = phi i32* [ %incdec.ptr, %entry ], [ %next0, %bb0 ], [ %next1, %bb1 ]
  %opcode.0 = phi i32 [ %initval, %entry ], [ 0, %bb0 ], [ 1, %bb1 ]
  tail call void @use(i32 %opcode.0)
  %next0 = getelementptr inbounds i32, i32* %p.addr.0, i64 1
  %newp0 = load i32, i32* %p.addr.0, align 4
  %idx0 = sext i32 %newp0 to i64
  %arrayidx0 = getelementptr inbounds [2 x i8*], [2 x i8*]* @multi.targets, i64 0, i64 %idx0
  %newop0 = load i8*, i8** %arrayidx0, align 8
  indirectbr i8* %newop0, [label %bb0, label %bb1]

bb1:
  %p.addr.1 = phi i32* [ %incdec.ptr, %entry ], [ %next0, %bb0 ], [ %next1, %bb1 ]
  %opcode.1 = phi i32 [ %initval, %entry ], [ 0, %bb0 ], [ 1, %bb1 ]
  tail call void @use(i32 %opcode.1)
  %next1 = getelementptr inbounds i32, i32* %p.addr.1, i64 1
  %newp1 = load i32, i32* %p.addr.1, align 4
  %idx1 = sext i32 %newp1 to i64
  %arrayidx1 = getelementptr inbounds [2 x i8*], [2 x i8*]* @multi.targets, i64 0, i64 %idx1
  %newop1 = load i8*, i8** %arrayidx1, align 8
  indirectbr i8* %newop1, [label %bb0, label %bb1]

exit:
  ret void
}

; Make sure we do the right thing for cases where the indirectbr branches to
; the block it terminates.
define void @loop(i64* nocapture readonly %p) {
; CHECK-LABEL: @loop(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[DOTSPLIT:%.*]]
; CHECK:       bb0:
; CHECK-NEXT:    br label [[DOTSPLIT]]
; CHECK:       .split:
; CHECK-NEXT:    [[MERGE:%.*]] = phi i64 [ [[I_NEXT:%.*]], [[BB0:%.*]] ], [ 0, [[BB0_CLONE:%.*]] ]
; CHECK-NEXT:    [[TMP0:%.*]] = getelementptr inbounds i64, i64* [[P:%.*]], i64 [[MERGE]]
; CHECK-NEXT:    store i64 [[MERGE]], i64* [[TMP0]], align 4
; CHECK-NEXT:    [[I_NEXT]] = add nuw nsw i64 [[MERGE]], 1
; CHECK-NEXT:    [[IDX:%.*]] = srem i64 [[MERGE]], 2
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds [2 x i8*], [2 x i8*]* @loop.targets, i64 0, i64 [[IDX]]
; CHECK-NEXT:    [[TARGET:%.*]] = load i8*, i8** [[ARRAYIDX]], align 8
; CHECK-NEXT:    indirectbr i8* [[TARGET]], [label [[BB0]], label %bb1]
; CHECK:       bb1:
; CHECK-NEXT:    ret void
;
entry:
  br label %bb0

bb0:
  %i = phi i64 [ %i.next, %bb0 ], [ 0, %entry ]
  %tmp0 = getelementptr inbounds i64, i64* %p, i64 %i
  store i64 %i, i64* %tmp0, align 4
  %i.next = add nuw nsw i64 %i, 1
  %idx = srem i64 %i, 2
  %arrayidx = getelementptr inbounds [2 x i8*], [2 x i8*]* @loop.targets, i64 0, i64 %idx
  %target = load i8*, i8** %arrayidx, align 8
  indirectbr i8* %target, [label %bb0, label %bb1]

bb1:
  ret void
}

; Don't do anything for cases that contain no phis.
define void @nophi(i32* %p) {
; CHECK-LABEL: @nophi(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[INCDEC_PTR:%.*]] = getelementptr inbounds i32, i32* [[P:%.*]], i64 1
; CHECK-NEXT:    [[INITOP:%.*]] = load i32, i32* [[INCDEC_PTR]], align 4
; CHECK-NEXT:    switch i32 [[INITOP]], label [[EXIT:%.*]] [
; CHECK-NEXT:    i32 0, label [[BB0:%.*]]
; CHECK-NEXT:    i32 1, label [[BB1:%.*]]
; CHECK-NEXT:    ]
; CHECK:       bb0:
; CHECK-NEXT:    tail call void @use(i32 0)
; CHECK-NEXT:    br label [[INDIRECTGOTO:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    tail call void @use(i32 1)
; CHECK-NEXT:    br label [[INDIRECTGOTO]]
; CHECK:       indirectgoto:
; CHECK-NEXT:    [[TMP0:%.*]] = bitcast i32* [[P]] to i8*
; CHECK-NEXT:    [[SUNKADDR:%.*]] = getelementptr i8, i8* [[TMP0]], i64 4
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast i8* [[SUNKADDR]] to i32*
; CHECK-NEXT:    [[NEWP:%.*]] = load i32, i32* [[TMP1]], align 4
; CHECK-NEXT:    [[IDX:%.*]] = sext i32 [[NEWP]] to i64
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds [2 x i8*], [2 x i8*]* @nophi.targets, i64 0, i64 [[IDX]]
; CHECK-NEXT:    [[NEWOP:%.*]] = load i8*, i8** [[ARRAYIDX]], align 8
; CHECK-NEXT:    indirectbr i8* [[NEWOP]], [label [[BB0]], label %bb1]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  %incdec.ptr = getelementptr inbounds i32, i32* %p, i64 1
  %initop = load i32, i32* %incdec.ptr, align 4
  switch i32 %initop, label %exit [
  i32 0, label %bb0
  i32 1, label %bb1
  ]

bb0:
  tail call void @use(i32 0)  br label %indirectgoto

bb1:
  tail call void @use(i32 1)
  br label %indirectgoto

indirectgoto:
  %newp = load i32, i32* %incdec.ptr, align 4
  %idx = sext i32 %newp to i64
  %arrayidx = getelementptr inbounds [2 x i8*], [2 x i8*]* @nophi.targets, i64 0, i64 %idx
  %newop = load i8*, i8** %arrayidx, align 8
  indirectbr i8* %newop, [label %bb0, label %bb1]

exit:
  ret void
}

; Don't do anything if the edge isn't critical.
define i32 @noncritical(i32 %k, i8* %p)
; CHECK-LABEL: @noncritical(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[D:%.*]] = add i32 [[K:%.*]], 1
; CHECK-NEXT:    indirectbr i8* [[P:%.*]], [label [[BB0:%.*]], label %bb1]
; CHECK:       bb0:
; CHECK-NEXT:    [[R0:%.*]] = sub i32 [[K]], [[D]]
; CHECK-NEXT:    br label [[EXIT:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    [[R1:%.*]] = sub i32 [[D]], [[K]]
; CHECK-NEXT:    br label [[EXIT]]
; CHECK:       exit:
; CHECK-NEXT:    [[V:%.*]] = phi i32 [ [[R0]], [[BB0]] ], [ [[R1]], [[BB1:%.*]] ]
; CHECK-NEXT:    ret i32 0
;
{
entry:
  %d = add i32 %k, 1
  indirectbr i8* %p, [label %bb0, label %bb1]

bb0:
  %v00 = phi i32 [%k, %entry]
  %v01 = phi i32 [%d, %entry]
  %r0 = sub i32 %v00, %v01
  br label %exit

bb1:
  %v10 = phi i32 [%d, %entry]
  %v11 = phi i32 [%k, %entry]
  %r1 = sub i32 %v10, %v11
  br label %exit

exit:
  %v = phi i32 [%r0, %bb0], [%r1, %bb1]
  ret i32 0
}
