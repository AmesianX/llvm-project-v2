; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+sse4.1 | FileCheck %s --check-prefix=SSE --check-prefix=SSE41
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+avx | FileCheck %s --check-prefix=AVX --check-prefix=AVX1
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+avx2 | FileCheck %s --check-prefix=AVX --check-prefix=AVX2

define <8 x i16> @sdiv_vec8x16(<8 x i16> %var) {
; SSE-LABEL: sdiv_vec8x16:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    movdqa %xmm0, %xmm1
; SSE-NEXT:    psraw $15, %xmm1
; SSE-NEXT:    psrlw $11, %xmm1
; SSE-NEXT:    paddw %xmm0, %xmm1
; SSE-NEXT:    psraw $5, %xmm1
; SSE-NEXT:    movdqa %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: sdiv_vec8x16:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpsraw $15, %xmm0, %xmm1
; AVX-NEXT:    vpsrlw $11, %xmm1, %xmm1
; AVX-NEXT:    vpaddw %xmm1, %xmm0, %xmm0
; AVX-NEXT:    vpsraw $5, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %0 = sdiv <8 x i16> %var, <i16 32, i16 32, i16 32, i16 32, i16 32, i16 32, i16 32, i16 32>
  ret <8 x i16> %0
}

define <8 x i16> @sdiv_vec8x16_minsize(<8 x i16> %var) minsize {
; SSE-LABEL: sdiv_vec8x16_minsize:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    movdqa %xmm0, %xmm1
; SSE-NEXT:    psraw $15, %xmm1
; SSE-NEXT:    psrlw $11, %xmm1
; SSE-NEXT:    paddw %xmm0, %xmm1
; SSE-NEXT:    psraw $5, %xmm1
; SSE-NEXT:    movdqa %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: sdiv_vec8x16_minsize:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpsraw $15, %xmm0, %xmm1
; AVX-NEXT:    vpsrlw $11, %xmm1, %xmm1
; AVX-NEXT:    vpaddw %xmm1, %xmm0, %xmm0
; AVX-NEXT:    vpsraw $5, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
  %0 = sdiv <8 x i16> %var, <i16 32, i16 32, i16 32, i16 32, i16 32, i16 32, i16 32, i16 32>
  ret <8 x i16> %0
}

define <4 x i32> @sdiv_zero(<4 x i32> %var) {
; SSE-LABEL: sdiv_zero:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    pextrd $1, %xmm0, %eax
; SSE-NEXT:    xorl %esi, %esi
; SSE-NEXT:    cltd
; SSE-NEXT:    idivl %esi
; SSE-NEXT:    movl %eax, %ecx
; SSE-NEXT:    movd %xmm0, %eax
; SSE-NEXT:    cltd
; SSE-NEXT:    idivl %esi
; SSE-NEXT:    movd %eax, %xmm1
; SSE-NEXT:    pinsrd $1, %ecx, %xmm1
; SSE-NEXT:    pextrd $2, %xmm0, %eax
; SSE-NEXT:    cltd
; SSE-NEXT:    idivl %esi
; SSE-NEXT:    pinsrd $2, %eax, %xmm1
; SSE-NEXT:    pextrd $3, %xmm0, %eax
; SSE-NEXT:    cltd
; SSE-NEXT:    idivl %esi
; SSE-NEXT:    pinsrd $3, %eax, %xmm1
; SSE-NEXT:    movdqa %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: sdiv_zero:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpextrd $1, %xmm0, %eax
; AVX-NEXT:    xorl %esi, %esi
; AVX-NEXT:    cltd
; AVX-NEXT:    idivl %esi
; AVX-NEXT:    movl %eax, %ecx
; AVX-NEXT:    vmovd %xmm0, %eax
; AVX-NEXT:    cltd
; AVX-NEXT:    idivl %esi
; AVX-NEXT:    vmovd %eax, %xmm1
; AVX-NEXT:    vpinsrd $1, %ecx, %xmm1, %xmm1
; AVX-NEXT:    vpextrd $2, %xmm0, %eax
; AVX-NEXT:    cltd
; AVX-NEXT:    idivl %esi
; AVX-NEXT:    vpinsrd $2, %eax, %xmm1, %xmm1
; AVX-NEXT:    vpextrd $3, %xmm0, %eax
; AVX-NEXT:    cltd
; AVX-NEXT:    idivl %esi
; AVX-NEXT:    vpinsrd $3, %eax, %xmm1, %xmm0
; AVX-NEXT:    retq
entry:
  %0 = sdiv <4 x i32> %var, <i32 0, i32 0, i32 0, i32 0>
  ret <4 x i32> %0
}

define <4 x i32> @sdiv_vec4x32(<4 x i32> %var) {
; SSE-LABEL: sdiv_vec4x32:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    movdqa %xmm0, %xmm1
; SSE-NEXT:    psrad $31, %xmm1
; SSE-NEXT:    psrld $28, %xmm1
; SSE-NEXT:    paddd %xmm0, %xmm1
; SSE-NEXT:    psrad $4, %xmm1
; SSE-NEXT:    movdqa %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: sdiv_vec4x32:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpsrad $31, %xmm0, %xmm1
; AVX-NEXT:    vpsrld $28, %xmm1, %xmm1
; AVX-NEXT:    vpaddd %xmm1, %xmm0, %xmm0
; AVX-NEXT:    vpsrad $4, %xmm0, %xmm0
; AVX-NEXT:    retq
entry:
%0 = sdiv <4 x i32> %var, <i32 16, i32 16, i32 16, i32 16>
ret <4 x i32> %0
}

define <4 x i32> @sdiv_negative(<4 x i32> %var) {
; SSE-LABEL: sdiv_negative:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    movdqa %xmm0, %xmm1
; SSE-NEXT:    psrad $31, %xmm1
; SSE-NEXT:    psrld $28, %xmm1
; SSE-NEXT:    paddd %xmm0, %xmm1
; SSE-NEXT:    psrad $4, %xmm1
; SSE-NEXT:    pxor %xmm0, %xmm0
; SSE-NEXT:    psubd %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: sdiv_negative:
; AVX:       # BB#0: # %entry
; AVX-NEXT:    vpsrad $31, %xmm0, %xmm1
; AVX-NEXT:    vpsrld $28, %xmm1, %xmm1
; AVX-NEXT:    vpaddd %xmm1, %xmm0, %xmm0
; AVX-NEXT:    vpsrad $4, %xmm0, %xmm0
; AVX-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX-NEXT:    vpsubd %xmm0, %xmm1, %xmm0
; AVX-NEXT:    retq
entry:
%0 = sdiv <4 x i32> %var, <i32 -16, i32 -16, i32 -16, i32 -16>
ret <4 x i32> %0
}

define <8 x i32> @sdiv8x32(<8 x i32> %var) {
; SSE-LABEL: sdiv8x32:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    movdqa %xmm0, %xmm2
; SSE-NEXT:    psrad $31, %xmm2
; SSE-NEXT:    psrld $26, %xmm2
; SSE-NEXT:    paddd %xmm0, %xmm2
; SSE-NEXT:    psrad $6, %xmm2
; SSE-NEXT:    movdqa %xmm1, %xmm3
; SSE-NEXT:    psrad $31, %xmm3
; SSE-NEXT:    psrld $26, %xmm3
; SSE-NEXT:    paddd %xmm1, %xmm3
; SSE-NEXT:    psrad $6, %xmm3
; SSE-NEXT:    movdqa %xmm2, %xmm0
; SSE-NEXT:    movdqa %xmm3, %xmm1
; SSE-NEXT:    retq
;
; AVX1-LABEL: sdiv8x32:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vpsrad $31, %xmm0, %xmm1
; AVX1-NEXT:    vpsrld $26, %xmm1, %xmm1
; AVX1-NEXT:    vpaddd %xmm1, %xmm0, %xmm1
; AVX1-NEXT:    vpsrad $6, %xmm1, %xmm1
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX1-NEXT:    vpsrad $31, %xmm0, %xmm2
; AVX1-NEXT:    vpsrld $26, %xmm2, %xmm2
; AVX1-NEXT:    vpaddd %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vpsrad $6, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: sdiv8x32:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpsrad $31, %ymm0, %ymm1
; AVX2-NEXT:    vpsrld $26, %ymm1, %ymm1
; AVX2-NEXT:    vpaddd %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vpsrad $6, %ymm0, %ymm0
; AVX2-NEXT:    retq
entry:
%0 = sdiv <8 x i32> %var, <i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64, i32 64>
ret <8 x i32> %0
}

define <16 x i16> @sdiv16x16(<16 x i16> %var) {
; SSE-LABEL: sdiv16x16:
; SSE:       # BB#0: # %entry
; SSE-NEXT:    movdqa %xmm0, %xmm2
; SSE-NEXT:    psraw $15, %xmm2
; SSE-NEXT:    psrlw $14, %xmm2
; SSE-NEXT:    paddw %xmm0, %xmm2
; SSE-NEXT:    psraw $2, %xmm2
; SSE-NEXT:    movdqa %xmm1, %xmm3
; SSE-NEXT:    psraw $15, %xmm3
; SSE-NEXT:    psrlw $14, %xmm3
; SSE-NEXT:    paddw %xmm1, %xmm3
; SSE-NEXT:    psraw $2, %xmm3
; SSE-NEXT:    movdqa %xmm2, %xmm0
; SSE-NEXT:    movdqa %xmm3, %xmm1
; SSE-NEXT:    retq
;
; AVX1-LABEL: sdiv16x16:
; AVX1:       # BB#0: # %entry
; AVX1-NEXT:    vpsraw $15, %xmm0, %xmm1
; AVX1-NEXT:    vpsrlw $14, %xmm1, %xmm1
; AVX1-NEXT:    vpaddw %xmm1, %xmm0, %xmm1
; AVX1-NEXT:    vpsraw $2, %xmm1, %xmm1
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX1-NEXT:    vpsraw $15, %xmm0, %xmm2
; AVX1-NEXT:    vpsrlw $14, %xmm2, %xmm2
; AVX1-NEXT:    vpaddw %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vpsraw $2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: sdiv16x16:
; AVX2:       # BB#0: # %entry
; AVX2-NEXT:    vpsraw $15, %ymm0, %ymm1
; AVX2-NEXT:    vpsrlw $14, %ymm1, %ymm1
; AVX2-NEXT:    vpaddw %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vpsraw $2, %ymm0, %ymm0
; AVX2-NEXT:    retq
entry:
  %a0 = sdiv <16 x i16> %var, <i16 4, i16 4, i16 4, i16 4, i16 4, i16 4, i16 4, i16 4, i16 4, i16 4, i16 4, i16 4, i16 4, i16 4, i16 4, i16 4>
  ret <16 x i16> %a0
}

define <4 x i32> @sdiv_non_splat(<4 x i32> %x) {
; SSE-LABEL: sdiv_non_splat:
; SSE:       # BB#0:
; SSE-NEXT:    pextrd $1, %xmm0, %eax
; SSE-NEXT:    xorl %ecx, %ecx
; SSE-NEXT:    cltd
; SSE-NEXT:    idivl %ecx
; SSE-NEXT:    movd %xmm0, %edx
; SSE-NEXT:    movl %edx, %esi
; SSE-NEXT:    shrl $31, %esi
; SSE-NEXT:    addl %edx, %esi
; SSE-NEXT:    sarl %esi
; SSE-NEXT:    movd %esi, %xmm1
; SSE-NEXT:    pinsrd $1, %eax, %xmm1
; SSE-NEXT:    pextrd $2, %xmm0, %eax
; SSE-NEXT:    cltd
; SSE-NEXT:    idivl %ecx
; SSE-NEXT:    pinsrd $2, %eax, %xmm1
; SSE-NEXT:    pextrd $3, %xmm0, %eax
; SSE-NEXT:    cltd
; SSE-NEXT:    idivl %ecx
; SSE-NEXT:    pinsrd $3, %eax, %xmm1
; SSE-NEXT:    movdqa %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: sdiv_non_splat:
; AVX:       # BB#0:
; AVX-NEXT:    vpextrd $1, %xmm0, %eax
; AVX-NEXT:    xorl %ecx, %ecx
; AVX-NEXT:    cltd
; AVX-NEXT:    idivl %ecx
; AVX-NEXT:    vmovd %xmm0, %edx
; AVX-NEXT:    movl %edx, %esi
; AVX-NEXT:    shrl $31, %esi
; AVX-NEXT:    addl %edx, %esi
; AVX-NEXT:    sarl %esi
; AVX-NEXT:    vmovd %esi, %xmm1
; AVX-NEXT:    vpinsrd $1, %eax, %xmm1, %xmm1
; AVX-NEXT:    vpextrd $2, %xmm0, %eax
; AVX-NEXT:    cltd
; AVX-NEXT:    idivl %ecx
; AVX-NEXT:    vpinsrd $2, %eax, %xmm1, %xmm1
; AVX-NEXT:    vpextrd $3, %xmm0, %eax
; AVX-NEXT:    cltd
; AVX-NEXT:    idivl %ecx
; AVX-NEXT:    vpinsrd $3, %eax, %xmm1, %xmm0
; AVX-NEXT:    retq
  %y = sdiv <4 x i32> %x, <i32 2, i32 0, i32 0, i32 0>
  ret <4 x i32> %y
}
