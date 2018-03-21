; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=riscv32 -mattr=+f -verify-machineinstrs < %s \
; RUN:   | FileCheck -check-prefix=RV32IF %s

define float @float_imm() nounwind {
; RV32IF-LABEL: float_imm:
; RV32IF:       # %bb.0:
; RV32IF-NEXT:    lui a0, 263313
; RV32IF-NEXT:    addi a0, a0, -37
; RV32IF-NEXT:    ret
  ret float 3.14159274101257324218750
}

define float @float_imm_op(float %a) nounwind {
; TODO: addi should be folded in to the flw
; RV32IF-LABEL: float_imm_op:
; RV32IF:       # %bb.0:
; RV32IF-NEXT:    fmv.w.x ft0, a0
; RV32IF-NEXT:    lui a0, %hi(.LCPI1_0)
; RV32IF-NEXT:    addi a0, a0, %lo(.LCPI1_0)
; RV32IF-NEXT:    flw ft1, 0(a0)
; RV32IF-NEXT:    fadd.s ft0, ft0, ft1
; RV32IF-NEXT:    fmv.x.w a0, ft0
; RV32IF-NEXT:    ret
  %1 = fadd float %a, 1.0
  ret float %1
}
