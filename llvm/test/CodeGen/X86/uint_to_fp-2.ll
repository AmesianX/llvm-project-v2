; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i386-unknown-unknown -mattr=+sse2 | FileCheck %s

; rdar://6504833
define float @test1(i32 %x) nounwind readnone {
; CHECK-LABEL: test1:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    pushl %eax
; CHECK-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-NEXT:    movss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; CHECK-NEXT:    orpd %xmm0, %xmm1
; CHECK-NEXT:    subsd %xmm0, %xmm1
; CHECK-NEXT:    xorps %xmm0, %xmm0
; CHECK-NEXT:    cvtsd2ss %xmm1, %xmm0
; CHECK-NEXT:    movss %xmm0, (%esp)
; CHECK-NEXT:    flds (%esp)
; CHECK-NEXT:    popl %eax
; CHECK-NEXT:    retl
entry:
  %0 = uitofp i32 %x to float
  ret float %0
}

; PR10802
define float @test2(<4 x i32> %x) nounwind readnone ssp {
; CHECK-LABEL: test2:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    pushl %eax
; CHECK-NEXT:    xorps %xmm1, %xmm1
; CHECK-NEXT:    movss {{.*#+}} xmm1 = xmm0[0],xmm1[1,2,3]
; CHECK-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-NEXT:    orps %xmm0, %xmm1
; CHECK-NEXT:    subsd %xmm0, %xmm1
; CHECK-NEXT:    xorps %xmm0, %xmm0
; CHECK-NEXT:    cvtsd2ss %xmm1, %xmm0
; CHECK-NEXT:    movss %xmm0, (%esp)
; CHECK-NEXT:    flds (%esp)
; CHECK-NEXT:    popl %eax
; CHECK-NEXT:    retl
entry:
  %vecext = extractelement <4 x i32> %x, i32 0
  %conv = uitofp i32 %vecext to float
  ret float %conv
}
