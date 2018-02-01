; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i386-unknown -mattr=+sse2,+ssse3 | FileCheck %s --check-prefix=X32
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+sse2,+ssse3 | FileCheck %s --check-prefix=X64

; There are no MMX operations in @t1

define void  @t1(i32 %a, x86_mmx* %P) nounwind {
; X32-LABEL: t1:
; X32:       # %bb.0:
; X32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X32-NEXT:    shll $12, %ecx
; X32-NEXT:    movd %ecx, %xmm0
; X32-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[1,0,1,1]
; X32-NEXT:    movq %xmm0, (%eax)
; X32-NEXT:    retl
;
; X64-LABEL: t1:
; X64:       # %bb.0:
; X64-NEXT:    # kill: def $edi killed $edi def $rdi
; X64-NEXT:    shll $12, %edi
; X64-NEXT:    movq %rdi, %xmm0
; X64-NEXT:    pslldq {{.*#+}} xmm0 = zero,zero,zero,zero,zero,zero,zero,zero,xmm0[0,1,2,3,4,5,6,7]
; X64-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,2,2,3]
; X64-NEXT:    movq %xmm0, (%rsi)
; X64-NEXT:    retq
 %tmp12 = shl i32 %a, 12
 %tmp21 = insertelement <2 x i32> undef, i32 %tmp12, i32 1
 %tmp22 = insertelement <2 x i32> %tmp21, i32 0, i32 0
 %tmp23 = bitcast <2 x i32> %tmp22 to x86_mmx
 store x86_mmx %tmp23, x86_mmx* %P
 ret void
}

define <4 x float> @t2(<4 x float>* %P) nounwind {
; X32-LABEL: t2:
; X32:       # %bb.0:
; X32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    movaps (%eax), %xmm1
; X32-NEXT:    xorps %xmm0, %xmm0
; X32-NEXT:    shufps {{.*#+}} xmm1 = xmm1[0,0],xmm0[2,0]
; X32-NEXT:    shufps {{.*#+}} xmm0 = xmm0[0,1],xmm1[2,0]
; X32-NEXT:    retl
;
; X64-LABEL: t2:
; X64:       # %bb.0:
; X64-NEXT:    movaps (%rdi), %xmm1
; X64-NEXT:    xorps %xmm0, %xmm0
; X64-NEXT:    shufps {{.*#+}} xmm1 = xmm1[0,0],xmm0[2,0]
; X64-NEXT:    shufps {{.*#+}} xmm0 = xmm0[0,1],xmm1[2,0]
; X64-NEXT:    retq
  %tmp1 = load <4 x float>, <4 x float>* %P
  %tmp2 = shufflevector <4 x float> %tmp1, <4 x float> zeroinitializer, <4 x i32> < i32 4, i32 4, i32 4, i32 0 >
  ret <4 x float> %tmp2
}

define <4 x float> @t3(<4 x float>* %P) nounwind {
; X32-LABEL: t3:
; X32:       # %bb.0:
; X32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    xorps %xmm0, %xmm0
; X32-NEXT:    movlps {{.*#+}} xmm0 = mem[0,1],xmm0[2,3]
; X32-NEXT:    retl
;
; X64-LABEL: t3:
; X64:       # %bb.0:
; X64-NEXT:    xorps %xmm0, %xmm0
; X64-NEXT:    movlps {{.*#+}} xmm0 = mem[0,1],xmm0[2,3]
; X64-NEXT:    retq
  %tmp1 = load <4 x float>, <4 x float>* %P
  %tmp2 = shufflevector <4 x float> %tmp1, <4 x float> zeroinitializer, <4 x i32> < i32 2, i32 3, i32 4, i32 4 >
  ret <4 x float> %tmp2
}

define <4 x float> @t4(<4 x float>* %P) nounwind {
; X32-LABEL: t4:
; X32:       # %bb.0:
; X32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    movaps (%eax), %xmm0
; X32-NEXT:    xorps %xmm1, %xmm1
; X32-NEXT:    shufps {{.*#+}} xmm0 = xmm0[3,0],xmm1[1,0]
; X32-NEXT:    shufps {{.*#+}} xmm0 = xmm0[0,2],xmm1[2,3]
; X32-NEXT:    retl
;
; X64-LABEL: t4:
; X64:       # %bb.0:
; X64-NEXT:    movaps (%rdi), %xmm0
; X64-NEXT:    xorps %xmm1, %xmm1
; X64-NEXT:    shufps {{.*#+}} xmm0 = xmm0[3,0],xmm1[1,0]
; X64-NEXT:    shufps {{.*#+}} xmm0 = xmm0[0,2],xmm1[2,3]
; X64-NEXT:    retq
  %tmp1 = load <4 x float>, <4 x float>* %P
  %tmp2 = shufflevector <4 x float> zeroinitializer, <4 x float> %tmp1, <4 x i32> < i32 7, i32 0, i32 0, i32 0 >
  ret <4 x float> %tmp2
}

define <16 x i8> @t5(<16 x i8> %x) nounwind {
; X32-LABEL: t5:
; X32:       # %bb.0:
; X32-NEXT:    psrlw $8, %xmm0
; X32-NEXT:    retl
;
; X64-LABEL: t5:
; X64:       # %bb.0:
; X64-NEXT:    psrlw $8, %xmm0
; X64-NEXT:    retq
  %s = shufflevector <16 x i8> %x, <16 x i8> zeroinitializer, <16 x i32> <i32 1, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 17>
  ret <16 x i8> %s
}

define <16 x i8> @t6(<16 x i8> %x) nounwind {
; X32-LABEL: t6:
; X32:       # %bb.0:
; X32-NEXT:    psrlw $8, %xmm0
; X32-NEXT:    retl
;
; X64-LABEL: t6:
; X64:       # %bb.0:
; X64-NEXT:    psrlw $8, %xmm0
; X64-NEXT:    retq
  %s = shufflevector <16 x i8> %x, <16 x i8> undef, <16 x i32> <i32 1, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  ret <16 x i8> %s
}

define <16 x i8> @t7(<16 x i8> %x) nounwind {
; X32-LABEL: t7:
; X32:       # %bb.0:
; X32-NEXT:    pslldq {{.*#+}} xmm0 = zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,xmm0[0,1,2]
; X32-NEXT:    retl
;
; X64-LABEL: t7:
; X64:       # %bb.0:
; X64-NEXT:    pslldq {{.*#+}} xmm0 = zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,zero,xmm0[0,1,2]
; X64-NEXT:    retq
  %s = shufflevector <16 x i8> %x, <16 x i8> undef, <16 x i32> <i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 1, i32 2>
  ret <16 x i8> %s
}

define <16 x i8> @t8(<16 x i8> %x) nounwind {
; X32-LABEL: t8:
; X32:       # %bb.0:
; X32-NEXT:    psrldq {{.*#+}} xmm0 = xmm0[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15],zero
; X32-NEXT:    retl
;
; X64-LABEL: t8:
; X64:       # %bb.0:
; X64-NEXT:    psrldq {{.*#+}} xmm0 = xmm0[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15],zero
; X64-NEXT:    retq
  %s = shufflevector <16 x i8> %x, <16 x i8> zeroinitializer, <16 x i32> <i32 1, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 8, i32 9, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 17>
  ret <16 x i8> %s
}

define <16 x i8> @t9(<16 x i8> %x) nounwind {
; X32-LABEL: t9:
; X32:       # %bb.0:
; X32-NEXT:    psrldq {{.*#+}} xmm0 = xmm0[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15],zero
; X32-NEXT:    retl
;
; X64-LABEL: t9:
; X64:       # %bb.0:
; X64-NEXT:    psrldq {{.*#+}} xmm0 = xmm0[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15],zero
; X64-NEXT:    retq
  %s = shufflevector <16 x i8> %x, <16 x i8> undef, <16 x i32> <i32 1, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 7, i32 8, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 14, i32 undef, i32 undef>
  ret <16 x i8> %s
}
