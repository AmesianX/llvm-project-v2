; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: opt < %s -loop-reduce -mcpu=btver2  -S | FileCheck %s --check-prefix=JAG
; RUN: opt < %s -loop-reduce -mcpu=haswell -S | FileCheck %s --check-prefix=HSW

; RUN: llc < %s                    | FileCheck %s --check-prefix=BASE
; RUN: llc < %s -mattr=macrofusion | FileCheck %s --check-prefix=FUSE

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-unknown"

; PR35681 - https://bugs.llvm.org/show_bug.cgi?id=35681
; FIXME: If a CPU can macro-fuse a compare and branch, then we discount that
; cost in LSR and avoid generating large offsets in each memory access.
; This reduces code size and may improve decode throughput.

define void @maxArray(double* noalias nocapture %x, double* noalias nocapture readonly %y) {
; JAG-LABEL: @maxArray(
; JAG-NEXT:  entry:
; JAG-NEXT:    [[Y1:%.*]] = bitcast double* [[Y:%.*]] to i8*
; JAG-NEXT:    [[X3:%.*]] = bitcast double* [[X:%.*]] to i8*
; JAG-NEXT:    br label [[VECTOR_BODY:%.*]]
; JAG:       vector.body:
; JAG-NEXT:    [[LSR_IV:%.*]] = phi i64 [ [[LSR_IV_NEXT:%.*]], [[VECTOR_BODY]] ], [ -524288, [[ENTRY:%.*]] ]
; JAG-NEXT:    [[UGLYGEP7:%.*]] = getelementptr i8, i8* [[X3]], i64 [[LSR_IV]]
; JAG-NEXT:    [[UGLYGEP78:%.*]] = bitcast i8* [[UGLYGEP7]] to <2 x double>*
; JAG-NEXT:    [[SCEVGEP9:%.*]] = getelementptr <2 x double>, <2 x double>* [[UGLYGEP78]], i64 32768
; JAG-NEXT:    [[UGLYGEP:%.*]] = getelementptr i8, i8* [[Y1]], i64 [[LSR_IV]]
; JAG-NEXT:    [[UGLYGEP2:%.*]] = bitcast i8* [[UGLYGEP]] to <2 x double>*
; JAG-NEXT:    [[SCEVGEP:%.*]] = getelementptr <2 x double>, <2 x double>* [[UGLYGEP2]], i64 32768
; JAG-NEXT:    [[XVAL:%.*]] = load <2 x double>, <2 x double>* [[SCEVGEP9]], align 8
; JAG-NEXT:    [[YVAL:%.*]] = load <2 x double>, <2 x double>* [[SCEVGEP]], align 8
; JAG-NEXT:    [[CMP:%.*]] = fcmp ogt <2 x double> [[YVAL]], [[XVAL]]
; JAG-NEXT:    [[MAX:%.*]] = select <2 x i1> [[CMP]], <2 x double> [[YVAL]], <2 x double> [[XVAL]]
; JAG-NEXT:    [[UGLYGEP4:%.*]] = getelementptr i8, i8* [[X3]], i64 [[LSR_IV]]
; JAG-NEXT:    [[UGLYGEP45:%.*]] = bitcast i8* [[UGLYGEP4]] to <2 x double>*
; JAG-NEXT:    [[SCEVGEP6:%.*]] = getelementptr <2 x double>, <2 x double>* [[UGLYGEP45]], i64 32768
; JAG-NEXT:    store <2 x double> [[MAX]], <2 x double>* [[SCEVGEP6]], align 8
; JAG-NEXT:    [[LSR_IV_NEXT]] = add nsw i64 [[LSR_IV]], 16
; JAG-NEXT:    [[DONE:%.*]] = icmp eq i64 [[LSR_IV_NEXT]], 0
; JAG-NEXT:    br i1 [[DONE]], label [[EXIT:%.*]], label [[VECTOR_BODY]]
; JAG:       exit:
; JAG-NEXT:    ret void
;
; HSW-LABEL: @maxArray(
; HSW-NEXT:  entry:
; HSW-NEXT:    [[Y1:%.*]] = bitcast double* [[Y:%.*]] to i8*
; HSW-NEXT:    [[X3:%.*]] = bitcast double* [[X:%.*]] to i8*
; HSW-NEXT:    br label [[VECTOR_BODY:%.*]]
; HSW:       vector.body:
; HSW-NEXT:    [[LSR_IV:%.*]] = phi i64 [ [[LSR_IV_NEXT:%.*]], [[VECTOR_BODY]] ], [ -524288, [[ENTRY:%.*]] ]
; HSW-NEXT:    [[UGLYGEP7:%.*]] = getelementptr i8, i8* [[X3]], i64 [[LSR_IV]]
; HSW-NEXT:    [[UGLYGEP78:%.*]] = bitcast i8* [[UGLYGEP7]] to <2 x double>*
; HSW-NEXT:    [[SCEVGEP9:%.*]] = getelementptr <2 x double>, <2 x double>* [[UGLYGEP78]], i64 32768
; HSW-NEXT:    [[UGLYGEP:%.*]] = getelementptr i8, i8* [[Y1]], i64 [[LSR_IV]]
; HSW-NEXT:    [[UGLYGEP2:%.*]] = bitcast i8* [[UGLYGEP]] to <2 x double>*
; HSW-NEXT:    [[SCEVGEP:%.*]] = getelementptr <2 x double>, <2 x double>* [[UGLYGEP2]], i64 32768
; HSW-NEXT:    [[XVAL:%.*]] = load <2 x double>, <2 x double>* [[SCEVGEP9]], align 8
; HSW-NEXT:    [[YVAL:%.*]] = load <2 x double>, <2 x double>* [[SCEVGEP]], align 8
; HSW-NEXT:    [[CMP:%.*]] = fcmp ogt <2 x double> [[YVAL]], [[XVAL]]
; HSW-NEXT:    [[MAX:%.*]] = select <2 x i1> [[CMP]], <2 x double> [[YVAL]], <2 x double> [[XVAL]]
; HSW-NEXT:    [[UGLYGEP4:%.*]] = getelementptr i8, i8* [[X3]], i64 [[LSR_IV]]
; HSW-NEXT:    [[UGLYGEP45:%.*]] = bitcast i8* [[UGLYGEP4]] to <2 x double>*
; HSW-NEXT:    [[SCEVGEP6:%.*]] = getelementptr <2 x double>, <2 x double>* [[UGLYGEP45]], i64 32768
; HSW-NEXT:    store <2 x double> [[MAX]], <2 x double>* [[SCEVGEP6]], align 8
; HSW-NEXT:    [[LSR_IV_NEXT]] = add nsw i64 [[LSR_IV]], 16
; HSW-NEXT:    [[DONE:%.*]] = icmp eq i64 [[LSR_IV_NEXT]], 0
; HSW-NEXT:    br i1 [[DONE]], label [[EXIT:%.*]], label [[VECTOR_BODY]]
; HSW:       exit:
; HSW-NEXT:    ret void
;
; BASE-LABEL: maxArray:
; BASE:       # %bb.0: # %entry
; BASE-NEXT:    movq $-524288, %rax # imm = 0xFFF80000
; BASE-NEXT:    .p2align 4, 0x90
; BASE-NEXT:  .LBB0_1: # %vector.body
; BASE-NEXT:    # =>This Inner Loop Header: Depth=1
; BASE-NEXT:    movupd 524288(%rdi,%rax), %xmm0
; BASE-NEXT:    movupd 524288(%rsi,%rax), %xmm1
; BASE-NEXT:    maxpd %xmm0, %xmm1
; BASE-NEXT:    movupd %xmm1, 524288(%rdi,%rax)
; BASE-NEXT:    addq $16, %rax
; BASE-NEXT:    jne .LBB0_1
; BASE-NEXT:  # %bb.2: # %exit
; BASE-NEXT:    retq
;
; FUSE-LABEL: maxArray:
; FUSE:       # %bb.0: # %entry
; FUSE-NEXT:    movq $-524288, %rax # imm = 0xFFF80000
; FUSE-NEXT:    .p2align 4, 0x90
; FUSE-NEXT:  .LBB0_1: # %vector.body
; FUSE-NEXT:    # =>This Inner Loop Header: Depth=1
; FUSE-NEXT:    movupd 524288(%rdi,%rax), %xmm0
; FUSE-NEXT:    movupd 524288(%rsi,%rax), %xmm1
; FUSE-NEXT:    maxpd %xmm0, %xmm1
; FUSE-NEXT:    movupd %xmm1, 524288(%rdi,%rax)
; FUSE-NEXT:    addq $16, %rax
; FUSE-NEXT:    jne .LBB0_1
; FUSE-NEXT:  # %bb.2: # %exit
; FUSE-NEXT:    retq
entry:
  br label %vector.body

vector.body:
  %index = phi i64 [ 0, %entry ], [ %index.next, %vector.body ]
  %gepx = getelementptr inbounds double, double* %x, i64 %index
  %gepy = getelementptr inbounds double, double* %y, i64 %index
  %xptr = bitcast double* %gepx to <2 x double>*
  %yptr = bitcast double* %gepy to <2 x double>*
  %xval = load <2 x double>, <2 x double>* %xptr, align 8
  %yval = load <2 x double>, <2 x double>* %yptr, align 8
  %cmp = fcmp ogt <2 x double> %yval, %xval
  %max = select <2 x i1> %cmp, <2 x double> %yval, <2 x double> %xval
  %xptr_again = bitcast double* %gepx to <2 x double>*
  store <2 x double> %max, <2 x double>* %xptr_again, align 8
  %index.next = add i64 %index, 2
  %done = icmp eq i64 %index.next, 65536
  br i1 %done, label %exit, label %vector.body

exit:
  ret void
}

