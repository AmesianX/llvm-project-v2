; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=x86_64-linux-gnu -global-isel -verify-machineinstrs < %s -o - | FileCheck %s --check-prefix=ALL --check-prefix=X64
define float @test_fadd_float(float %arg1, float %arg2) {
; ALL-LABEL: test_fadd_float:
; ALL:       # %bb.0:
; ALL-NEXT:    addss %xmm1, %xmm0
; ALL-NEXT:    retq
  %ret = fadd float %arg1, %arg2
  ret float %ret
}

define double @test_fadd_double(double %arg1, double %arg2) {
; ALL-LABEL: test_fadd_double:
; ALL:       # %bb.0:
; ALL-NEXT:    addsd %xmm1, %xmm0
; ALL-NEXT:    retq
  %ret = fadd double %arg1, %arg2
  ret double %ret
}

