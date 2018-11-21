; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=avx512f | FileCheck %s

define void @foo(<16 x float> %x) {
; CHECK-LABEL: foo:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vaddps %xmm0, %xmm0, %xmm0
; CHECK-NEXT:    vinsertf128 $1, %xmm0, %ymm0, %ymm0
; CHECK-NEXT:    vinsertf64x4 $1, %ymm0, %zmm0, %zmm0
; CHECK-NEXT:    vmovups %zmm0, (%rax)
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
  %1 = fadd <16 x float> %x, %x
  %bc256 = bitcast <16 x float> %1 to <4 x i128>
  %2 = extractelement <4 x i128> %bc256, i32 0
  %3 = bitcast i128 %2 to <4 x float>
  %4 = shufflevector <4 x float> %3, <4 x float> undef, <16 x i32> <i32 0, i32
1, i32 2, i32 3, i32 0, i32 1, i32 2, i32 3, i32 0, i32 1, i32 2, i32 3, i32 0,
i32 1, i32 2, i32 3>
  store <16 x float> %4, <16 x float>* undef, align 4
  ret void
}
