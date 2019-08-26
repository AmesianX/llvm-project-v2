; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-apple-darwin | FileCheck %s

define void @redundant_add(i64 %n) {
; Check that we don't create two additions for the sadd.with.overflow.
; CHECK-LABEL: redundant_add:
; CHECK:       ## %bb.0: ## %entry
; CHECK-NEXT:    xorl %eax, %eax
; CHECK-NEXT:    .p2align 4, 0x90
; CHECK-NEXT:  LBB0_1: ## %exit_check
; CHECK-NEXT:    ## =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    cmpq %rdi, %rax
; CHECK-NEXT:    jge LBB0_4
; CHECK-NEXT:  ## %bb.2: ## %loop
; CHECK-NEXT:    ## in Loop: Header=BB0_1 Depth=1
; CHECK-NEXT:    incq %rax
; CHECK-NEXT:    jno LBB0_1
; CHECK-NEXT:  ## %bb.3: ## %overflow
; CHECK-NEXT:    ud2
; CHECK-NEXT:  LBB0_4: ## %exit
; CHECK-NEXT:    retq
entry:
  br label %exit_check

exit_check:
  %i = phi i64 [ 0, %entry ], [ %i.next, %loop ]
  %c = icmp slt i64 %i, %n
  br i1 %c, label %loop, label %exit

loop:
  %i.o = tail call { i64, i1 } @llvm.sadd.with.overflow.i64(i64 %i, i64 1)
  %i.next = extractvalue { i64, i1 } %i.o, 0
  %o = extractvalue { i64, i1 } %i.o, 1
  br i1 %o, label %overflow, label %exit_check

exit:
  ret void

overflow:
  tail call void @llvm.trap()
  unreachable
}

declare { i64, i1 } @llvm.sadd.with.overflow.i64(i64, i64)
declare void @llvm.trap()

