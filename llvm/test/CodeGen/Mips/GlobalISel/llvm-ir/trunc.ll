; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc  -O0 -mtriple=mipsel-linux-gnu -global-isel  -verify-machineinstrs %s -o -| FileCheck %s -check-prefixes=MIPS32

define i32 @trunc(i64 %x) {
; MIPS32-LABEL: trunc:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    move $2, $4
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %conv = trunc i64 %x to i32
  ret i32 %conv
}
