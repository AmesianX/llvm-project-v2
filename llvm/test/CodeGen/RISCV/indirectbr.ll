; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=riscv32 -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV32I

define i32 @indirectbr(i8* %target) nounwind {
; RV32I-LABEL: indirectbr:
; RV32I:       # %bb.0:
; RV32I-NEXT:    sw ra, 0(s0)
; RV32I-NEXT:    jalr zero, a0, 0
; RV32I-NEXT:  .LBB0_1: # %ret
; RV32I-NEXT:    addi a0, zero, 0
; RV32I-NEXT:    lw ra, 0(s0)
; RV32I-NEXT:    jalr zero, ra, 0
  indirectbr i8* %target, [label %test_label]
test_label:
  br label %ret
ret:
  ret i32 0
}

define i32 @indirectbr_with_offset(i8* %a) nounwind {
; RV32I-LABEL: indirectbr_with_offset:
; RV32I:       # %bb.0:
; RV32I-NEXT:    sw ra, 0(s0)
; RV32I-NEXT:    jalr zero, a0, 1380
; RV32I-NEXT:  .LBB1_1: # %ret
; RV32I-NEXT:    addi a0, zero, 0
; RV32I-NEXT:    lw ra, 0(s0)
; RV32I-NEXT:    jalr zero, ra, 0
  %target = getelementptr inbounds i8, i8* %a, i32 1380
  indirectbr i8* %target, [label %test_label]
test_label:
  br label %ret
ret:
  ret i32 0
}
