; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=x86-64 -mattr=+tbm | FileCheck %s --check-prefix=GENERIC
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=bdver2 | FileCheck %s --check-prefix=BDVER --check-prefix=BDVER2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=bdver3 | FileCheck %s --check-prefix=BDVER --check-prefix=BDVER3
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=bdver4 | FileCheck %s --check-prefix=BDVER --check-prefix=BDVER4

define i32 @test_x86_tbm_bextri_u32(i32 %a0, i32* nocapture %p1) nounwind {
; GENERIC-LABEL: test_x86_tbm_bextri_u32:
; GENERIC:       # %bb.0:
; GENERIC-NEXT:    bextrl $3076, %edi, %ecx # imm = 0xC04
; GENERIC-NEXT:    # sched: [2:1.00]
; GENERIC-NEXT:    bextrl $3076, (%rsi), %eax # imm = 0xC04
; GENERIC-NEXT:    # sched: [7:1.00]
; GENERIC-NEXT:    addl %ecx, %eax # sched: [1:0.33]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; BDVER-LABEL: test_x86_tbm_bextri_u32:
; BDVER:       # %bb.0:
; BDVER-NEXT:    bextrl $3076, %edi, %ecx # imm = 0xC04
; BDVER-NEXT:    bextrl $3076, (%rsi), %eax # imm = 0xC04
; BDVER-NEXT:    addl %ecx, %eax
; BDVER-NEXT:    retq
  %a1 = load i32, i32* %p1
  %r0 = lshr i32 %a0, 4
  %m0 = lshr i32 %a1, 4
  %r1 = and i32 %r0, 4095
  %m1 = and i32 %m0, 4095
  %res = add i32 %r1, %m1
  ret i32 %res
}

define i64 @test_x86_tbm_bextri_u64(i64 %a0, i64* nocapture %p1) nounwind {
; GENERIC-LABEL: test_x86_tbm_bextri_u64:
; GENERIC:       # %bb.0:
; GENERIC-NEXT:    bextrl $3076, %edi, %ecx # imm = 0xC04
; GENERIC-NEXT:    # sched: [2:1.00]
; GENERIC-NEXT:    bextrl $3076, (%rsi), %eax # imm = 0xC04
; GENERIC-NEXT:    # sched: [7:1.00]
; GENERIC-NEXT:    addq %rcx, %rax # sched: [1:0.33]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; BDVER-LABEL: test_x86_tbm_bextri_u64:
; BDVER:       # %bb.0:
; BDVER-NEXT:    bextrl $3076, %edi, %ecx # imm = 0xC04
; BDVER-NEXT:    bextrl $3076, (%rsi), %eax # imm = 0xC04
; BDVER-NEXT:    addq %rcx, %rax
; BDVER-NEXT:    retq
  %a1 = load i64, i64* %p1
  %r0 = lshr i64 %a0, 4
  %m0 = lshr i64 %a1, 4
  %r1 = and i64 %r0, 4095
  %m1 = and i64 %m0, 4095
  %res = add i64 %r1, %m1
  ret i64 %res
}

define i32 @test_x86_tbm_blcfill_u32(i32 %a0, i32* nocapture %p1) nounwind {
; GENERIC-LABEL: test_x86_tbm_blcfill_u32:
; GENERIC:       # %bb.0:
; GENERIC-NEXT:    blcfilll %edi, %ecx # sched: [1:0.33]
; GENERIC-NEXT:    blcfilll (%rsi), %eax # sched: [6:0.50]
; GENERIC-NEXT:    addl %ecx, %eax # sched: [1:0.33]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; BDVER-LABEL: test_x86_tbm_blcfill_u32:
; BDVER:       # %bb.0:
; BDVER-NEXT:    blcfilll %edi, %ecx
; BDVER-NEXT:    blcfilll (%rsi), %eax
; BDVER-NEXT:    addl %ecx, %eax
; BDVER-NEXT:    retq
  %a1 = load i32, i32* %p1
  %r0 = add i32 %a0, 1
  %m0 = add i32 %a1, 1
  %r1 = and i32 %r0, %a0
  %m1 = and i32 %m0, %a1
  %res = add i32 %r1, %m1
  ret i32 %res
}

define i64 @test_x86_tbm_blcfill_u64(i64 %a0, i64* nocapture %p1) nounwind {
; GENERIC-LABEL: test_x86_tbm_blcfill_u64:
; GENERIC:       # %bb.0:
; GENERIC-NEXT:    blcfillq %rdi, %rcx # sched: [1:0.33]
; GENERIC-NEXT:    blcfillq (%rsi), %rax # sched: [6:0.50]
; GENERIC-NEXT:    addq %rcx, %rax # sched: [1:0.33]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; BDVER-LABEL: test_x86_tbm_blcfill_u64:
; BDVER:       # %bb.0:
; BDVER-NEXT:    blcfillq %rdi, %rcx
; BDVER-NEXT:    blcfillq (%rsi), %rax
; BDVER-NEXT:    addq %rcx, %rax
; BDVER-NEXT:    retq
  %a1 = load i64, i64* %p1
  %r0 = add i64 %a0, 1
  %m0 = add i64 %a1, 1
  %r1 = and i64 %r0, %a0
  %m1 = and i64 %m0, %a1
  %res = add i64 %r1, %m1
  ret i64 %res
}

define i32 @test_x86_tbm_blci_u32(i32 %a0, i32* nocapture %p1) nounwind {
; GENERIC-LABEL: test_x86_tbm_blci_u32:
; GENERIC:       # %bb.0:
; GENERIC-NEXT:    blcil %edi, %ecx # sched: [1:0.33]
; GENERIC-NEXT:    blcil (%rsi), %eax # sched: [6:0.50]
; GENERIC-NEXT:    addl %ecx, %eax # sched: [1:0.33]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; BDVER-LABEL: test_x86_tbm_blci_u32:
; BDVER:       # %bb.0:
; BDVER-NEXT:    blcil %edi, %ecx
; BDVER-NEXT:    blcil (%rsi), %eax
; BDVER-NEXT:    addl %ecx, %eax
; BDVER-NEXT:    retq
  %a1 = load i32, i32* %p1
  %r0 = add i32 1, %a0
  %m0 = add i32 1, %a1
  %r1 = xor i32 %r0, -1
  %m1 = xor i32 %m0, -1
  %r2 = or i32 %r1, %a0
  %m2 = or i32 %m1, %a1
  %res = add i32 %r2, %m2
  ret i32 %res
}

define i64 @test_x86_tbm_blci_u64(i64 %a0, i64* nocapture %p1) nounwind {
; GENERIC-LABEL: test_x86_tbm_blci_u64:
; GENERIC:       # %bb.0:
; GENERIC-NEXT:    blciq %rdi, %rcx # sched: [1:0.33]
; GENERIC-NEXT:    blciq (%rsi), %rax # sched: [6:0.50]
; GENERIC-NEXT:    addq %rcx, %rax # sched: [1:0.33]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; BDVER-LABEL: test_x86_tbm_blci_u64:
; BDVER:       # %bb.0:
; BDVER-NEXT:    blciq %rdi, %rcx
; BDVER-NEXT:    blciq (%rsi), %rax
; BDVER-NEXT:    addq %rcx, %rax
; BDVER-NEXT:    retq
  %a1 = load i64, i64* %p1
  %r0 = add i64 1, %a0
  %m0 = add i64 1, %a1
  %r1 = xor i64 %r0, -1
  %m1 = xor i64 %m0, -1
  %r2 = or i64 %r1, %a0
  %m2 = or i64 %m1, %a1
  %res = add i64 %r2, %m2
  ret i64 %res
}

define i32 @test_x86_tbm_blcic_u32(i32 %a0, i32* nocapture %p1) nounwind {
; GENERIC-LABEL: test_x86_tbm_blcic_u32:
; GENERIC:       # %bb.0:
; GENERIC-NEXT:    blcicl %edi, %ecx # sched: [1:0.33]
; GENERIC-NEXT:    blcicl (%rsi), %eax # sched: [6:0.50]
; GENERIC-NEXT:    addl %ecx, %eax # sched: [1:0.33]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; BDVER-LABEL: test_x86_tbm_blcic_u32:
; BDVER:       # %bb.0:
; BDVER-NEXT:    blcicl %edi, %ecx
; BDVER-NEXT:    blcicl (%rsi), %eax
; BDVER-NEXT:    addl %ecx, %eax
; BDVER-NEXT:    retq
  %a1 = load i32, i32* %p1
  %r0 = xor i32 %a0, -1
  %m0 = xor i32 %a1, -1
  %r1 = add i32 %a0, 1
  %m1 = add i32 %a1, 1
  %r2 = and i32 %r1, %r0
  %m2 = and i32 %m1, %m0
  %res = add i32 %r2, %m2
  ret i32 %res
}

define i64 @test_x86_tbm_blcic_u64(i64 %a0, i64* nocapture %p1) nounwind {
; GENERIC-LABEL: test_x86_tbm_blcic_u64:
; GENERIC:       # %bb.0:
; GENERIC-NEXT:    blcicq %rdi, %rcx # sched: [1:0.33]
; GENERIC-NEXT:    blcicq (%rsi), %rax # sched: [6:0.50]
; GENERIC-NEXT:    addq %rcx, %rax # sched: [1:0.33]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; BDVER-LABEL: test_x86_tbm_blcic_u64:
; BDVER:       # %bb.0:
; BDVER-NEXT:    blcicq %rdi, %rcx
; BDVER-NEXT:    blcicq (%rsi), %rax
; BDVER-NEXT:    addq %rcx, %rax
; BDVER-NEXT:    retq
  %a1 = load i64, i64* %p1
  %r0 = xor i64 %a0, -1
  %m0 = xor i64 %a1, -1
  %r1 = add i64 %a0, 1
  %m1 = add i64 %a1, 1
  %r2 = and i64 %r1, %r0
  %m2 = and i64 %m1, %m0
  %res = add i64 %r2, %m2
  ret i64 %res
}

define i32 @test_x86_tbm_blcmsk_u32(i32 %a0, i32* nocapture %p1) nounwind {
; GENERIC-LABEL: test_x86_tbm_blcmsk_u32:
; GENERIC:       # %bb.0:
; GENERIC-NEXT:    blcmskl %edi, %ecx # sched: [1:0.33]
; GENERIC-NEXT:    blcmskl (%rsi), %eax # sched: [6:0.50]
; GENERIC-NEXT:    addl %ecx, %eax # sched: [1:0.33]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; BDVER-LABEL: test_x86_tbm_blcmsk_u32:
; BDVER:       # %bb.0:
; BDVER-NEXT:    blcmskl %edi, %ecx
; BDVER-NEXT:    blcmskl (%rsi), %eax
; BDVER-NEXT:    addl %ecx, %eax
; BDVER-NEXT:    retq
  %a1 = load i32, i32* %p1
  %r0 = add i32 %a0, 1
  %m0 = add i32 %a1, 1
  %r1 = xor i32 %r0, %a0
  %m1 = xor i32 %m0, %a1
  %res = add i32 %r1, %m1
  ret i32 %res
}

define i64 @test_x86_tbm_blcmsk_u64(i64 %a0, i64* nocapture %p1) nounwind {
; GENERIC-LABEL: test_x86_tbm_blcmsk_u64:
; GENERIC:       # %bb.0:
; GENERIC-NEXT:    blcmskq %rdi, %rcx # sched: [1:0.33]
; GENERIC-NEXT:    blcmskq (%rsi), %rax # sched: [6:0.50]
; GENERIC-NEXT:    addq %rcx, %rax # sched: [1:0.33]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; BDVER-LABEL: test_x86_tbm_blcmsk_u64:
; BDVER:       # %bb.0:
; BDVER-NEXT:    blcmskq %rdi, %rcx
; BDVER-NEXT:    blcmskq (%rsi), %rax
; BDVER-NEXT:    addq %rcx, %rax
; BDVER-NEXT:    retq
  %a1 = load i64, i64* %p1
  %r0 = add i64 %a0, 1
  %m0 = add i64 %a1, 1
  %r1 = xor i64 %r0, %a0
  %m1 = xor i64 %m0, %a1
  %res = add i64 %r1, %m1
  ret i64 %res
}

define i32 @test_x86_tbm_blcs_u32(i32 %a0, i32* nocapture %p1) nounwind {
; GENERIC-LABEL: test_x86_tbm_blcs_u32:
; GENERIC:       # %bb.0:
; GENERIC-NEXT:    blcsl %edi, %ecx # sched: [1:0.33]
; GENERIC-NEXT:    blcsl (%rsi), %eax # sched: [6:0.50]
; GENERIC-NEXT:    addl %ecx, %eax # sched: [1:0.33]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; BDVER-LABEL: test_x86_tbm_blcs_u32:
; BDVER:       # %bb.0:
; BDVER-NEXT:    blcsl %edi, %ecx
; BDVER-NEXT:    blcsl (%rsi), %eax
; BDVER-NEXT:    addl %ecx, %eax
; BDVER-NEXT:    retq
  %a1 = load i32, i32* %p1
  %r0 = add i32 %a0, 1
  %m0 = add i32 %a1, 1
  %r1 = or i32 %r0, %a0
  %m1 = or i32 %m0, %a1
  %res = add i32 %r1, %m1
  ret i32 %res
}

define i64 @test_x86_tbm_blcs_u64(i64 %a0, i64* nocapture %p1) nounwind {
; GENERIC-LABEL: test_x86_tbm_blcs_u64:
; GENERIC:       # %bb.0:
; GENERIC-NEXT:    blcsq %rdi, %rcx # sched: [1:0.33]
; GENERIC-NEXT:    blcsq (%rsi), %rax # sched: [6:0.50]
; GENERIC-NEXT:    addq %rcx, %rax # sched: [1:0.33]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; BDVER-LABEL: test_x86_tbm_blcs_u64:
; BDVER:       # %bb.0:
; BDVER-NEXT:    blcsq %rdi, %rcx
; BDVER-NEXT:    blcsq (%rsi), %rax
; BDVER-NEXT:    addq %rcx, %rax
; BDVER-NEXT:    retq
  %a1 = load i64, i64* %p1
  %r0 = add i64 %a0, 1
  %m0 = add i64 %a1, 1
  %r1 = or i64 %r0, %a0
  %m1 = or i64 %m0, %a1
  %res = add i64 %r1, %m1
  ret i64 %res
}

define i32 @test_x86_tbm_blsfill_u32(i32 %a0, i32* nocapture %p1) nounwind {
; GENERIC-LABEL: test_x86_tbm_blsfill_u32:
; GENERIC:       # %bb.0:
; GENERIC-NEXT:    blsfilll %edi, %ecx # sched: [1:0.33]
; GENERIC-NEXT:    blsfilll (%rsi), %eax # sched: [6:0.50]
; GENERIC-NEXT:    addl %ecx, %eax # sched: [1:0.33]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; BDVER-LABEL: test_x86_tbm_blsfill_u32:
; BDVER:       # %bb.0:
; BDVER-NEXT:    blsfilll %edi, %ecx
; BDVER-NEXT:    blsfilll (%rsi), %eax
; BDVER-NEXT:    addl %ecx, %eax
; BDVER-NEXT:    retq
  %a1 = load i32, i32* %p1
  %r0 = add i32 %a0, -1
  %m0 = add i32 %a1, -1
  %r1 = or i32 %r0, %a0
  %m1 = or i32 %m0, %a1
  %res = add i32 %r1, %m1
  ret i32 %res
}

define i64 @test_x86_tbm_blsfill_u64(i64 %a0, i64* nocapture %p1) nounwind {
; GENERIC-LABEL: test_x86_tbm_blsfill_u64:
; GENERIC:       # %bb.0:
; GENERIC-NEXT:    blsfillq %rdi, %rcx # sched: [1:0.33]
; GENERIC-NEXT:    blsfillq (%rsi), %rax # sched: [6:0.50]
; GENERIC-NEXT:    addq %rcx, %rax # sched: [1:0.33]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; BDVER-LABEL: test_x86_tbm_blsfill_u64:
; BDVER:       # %bb.0:
; BDVER-NEXT:    blsfillq %rdi, %rcx
; BDVER-NEXT:    blsfillq (%rsi), %rax
; BDVER-NEXT:    addq %rcx, %rax
; BDVER-NEXT:    retq
  %a1 = load i64, i64* %p1
  %r0 = add i64 %a0, -1
  %m0 = add i64 %a1, -1
  %r1 = or i64 %r0, %a0
  %m1 = or i64 %m0, %a1
  %res = add i64 %r1, %m1
  ret i64 %res
}

define i32 @test_x86_tbm_blsic_u32(i32 %a0, i32* nocapture %p1) nounwind {
; GENERIC-LABEL: test_x86_tbm_blsic_u32:
; GENERIC:       # %bb.0:
; GENERIC-NEXT:    blsicl %edi, %ecx # sched: [1:0.33]
; GENERIC-NEXT:    blsicl (%rsi), %eax # sched: [6:0.50]
; GENERIC-NEXT:    addl %ecx, %eax # sched: [1:0.33]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; BDVER-LABEL: test_x86_tbm_blsic_u32:
; BDVER:       # %bb.0:
; BDVER-NEXT:    blsicl %edi, %ecx
; BDVER-NEXT:    blsicl (%rsi), %eax
; BDVER-NEXT:    addl %ecx, %eax
; BDVER-NEXT:    retq
  %a1 = load i32, i32* %p1
  %r0 = xor i32 %a0, -1
  %m0 = xor i32 %a1, -1
  %r1 = add i32 %a0, -1
  %m1 = add i32 %a1, -1
  %r2 = or i32 %r0, %r1
  %m2 = or i32 %m0, %m1
  %res = add i32 %r2, %m2
  ret i32 %res
}

define i64 @test_x86_tbm_blsic_u64(i64 %a0, i64* nocapture %p1) nounwind {
; GENERIC-LABEL: test_x86_tbm_blsic_u64:
; GENERIC:       # %bb.0:
; GENERIC-NEXT:    blsicq %rdi, %rcx # sched: [1:0.33]
; GENERIC-NEXT:    blsicq (%rsi), %rax # sched: [6:0.50]
; GENERIC-NEXT:    addq %rcx, %rax # sched: [1:0.33]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; BDVER-LABEL: test_x86_tbm_blsic_u64:
; BDVER:       # %bb.0:
; BDVER-NEXT:    blsicq %rdi, %rcx
; BDVER-NEXT:    blsicq (%rsi), %rax
; BDVER-NEXT:    addq %rcx, %rax
; BDVER-NEXT:    retq
  %a1 = load i64, i64* %p1
  %r0 = xor i64 %a0, -1
  %m0 = xor i64 %a1, -1
  %r1 = add i64 %a0, -1
  %m1 = add i64 %a1, -1
  %r2 = or i64 %r0, %r1
  %m2 = or i64 %m0, %m1
  %res = add i64 %r2, %m2
  ret i64 %res
}

define i32 @test_x86_tbm_t1mskc_u32(i32 %a0, i32* nocapture %p1) nounwind {
; GENERIC-LABEL: test_x86_tbm_t1mskc_u32:
; GENERIC:       # %bb.0:
; GENERIC-NEXT:    t1mskcl %edi, %ecx # sched: [1:0.33]
; GENERIC-NEXT:    t1mskcl (%rsi), %eax # sched: [6:0.50]
; GENERIC-NEXT:    addl %ecx, %eax # sched: [1:0.33]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; BDVER-LABEL: test_x86_tbm_t1mskc_u32:
; BDVER:       # %bb.0:
; BDVER-NEXT:    t1mskcl %edi, %ecx
; BDVER-NEXT:    t1mskcl (%rsi), %eax
; BDVER-NEXT:    addl %ecx, %eax
; BDVER-NEXT:    retq
  %a1 = load i32, i32* %p1
  %r0 = xor i32 %a0, -1
  %m0 = xor i32 %a1, -1
  %r1 = add i32 %a0, 1
  %m1 = add i32 %a1, 1
  %r2 = or i32 %r0, %r1
  %m2 = or i32 %m0, %m1
  %res = add i32 %r2, %m2
  ret i32 %res
}

define i64 @test_x86_tbm_t1mskc_u64(i64 %a0, i64* nocapture %p1) nounwind {
; GENERIC-LABEL: test_x86_tbm_t1mskc_u64:
; GENERIC:       # %bb.0:
; GENERIC-NEXT:    t1mskcq %rdi, %rcx # sched: [1:0.33]
; GENERIC-NEXT:    t1mskcq (%rsi), %rax # sched: [6:0.50]
; GENERIC-NEXT:    addq %rcx, %rax # sched: [1:0.33]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; BDVER-LABEL: test_x86_tbm_t1mskc_u64:
; BDVER:       # %bb.0:
; BDVER-NEXT:    t1mskcq %rdi, %rcx
; BDVER-NEXT:    t1mskcq (%rsi), %rax
; BDVER-NEXT:    addq %rcx, %rax
; BDVER-NEXT:    retq
  %a1 = load i64, i64* %p1
  %r0 = xor i64 %a0, -1
  %m0 = xor i64 %a1, -1
  %r1 = add i64 %a0, 1
  %m1 = add i64 %a1, 1
  %r2 = or i64 %r0, %r1
  %m2 = or i64 %m0, %m1
  %res = add i64 %r2, %m2
  ret i64 %res
}

define i32 @test_x86_tbm_tzmsk_u32(i32 %a0, i32* nocapture %p1) nounwind {
; GENERIC-LABEL: test_x86_tbm_tzmsk_u32:
; GENERIC:       # %bb.0:
; GENERIC-NEXT:    tzmskl %edi, %ecx # sched: [1:0.33]
; GENERIC-NEXT:    tzmskl (%rsi), %eax # sched: [6:0.50]
; GENERIC-NEXT:    addl %ecx, %eax # sched: [1:0.33]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; BDVER-LABEL: test_x86_tbm_tzmsk_u32:
; BDVER:       # %bb.0:
; BDVER-NEXT:    tzmskl %edi, %ecx
; BDVER-NEXT:    tzmskl (%rsi), %eax
; BDVER-NEXT:    addl %ecx, %eax
; BDVER-NEXT:    retq
  %a1 = load i32, i32* %p1
  %r0 = xor i32 %a0, -1
  %m0 = xor i32 %a1, -1
  %r1 = add i32 %a0, -1
  %m1 = add i32 %a1, -1
  %r2 = and i32 %r0, %r1
  %m2 = and i32 %m0, %m1
  %res = add i32 %r2, %m2
  ret i32 %res
}

define i64 @test_x86_tbm_tzmsk_u64(i64 %a0, i64* nocapture %p1) nounwind {
; GENERIC-LABEL: test_x86_tbm_tzmsk_u64:
; GENERIC:       # %bb.0:
; GENERIC-NEXT:    tzmskq %rdi, %rcx # sched: [1:0.33]
; GENERIC-NEXT:    tzmskq (%rsi), %rax # sched: [6:0.50]
; GENERIC-NEXT:    addq %rcx, %rax # sched: [1:0.33]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; BDVER-LABEL: test_x86_tbm_tzmsk_u64:
; BDVER:       # %bb.0:
; BDVER-NEXT:    tzmskq %rdi, %rcx
; BDVER-NEXT:    tzmskq (%rsi), %rax
; BDVER-NEXT:    addq %rcx, %rax
; BDVER-NEXT:    retq
  %a1 = load i64, i64* %p1
  %r0 = xor i64 %a0, -1
  %m0 = xor i64 %a1, -1
  %r1 = add i64 %a0, -1
  %m1 = add i64 %a1, -1
  %r2 = and i64 %r0, %r1
  %m2 = and i64 %m0, %m1
  %res = add i64 %r2, %m2
  ret i64 %res
}
