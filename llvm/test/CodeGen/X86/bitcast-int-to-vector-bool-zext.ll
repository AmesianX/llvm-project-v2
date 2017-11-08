; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse2 | FileCheck %s --check-prefixes=SSE2-SSSE3,SSE2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+ssse3 | FileCheck %s --check-prefixes=SSE2-SSSE3,SSSE3
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx | FileCheck %s --check-prefixes=AVX12,AVX1
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx2 | FileCheck %s --check-prefixes=AVX12,AVX2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512f,+avx512vl,+avx512bw | FileCheck %s --check-prefixes=AVX512

;
; 128-bit vectors
;

define <2 x i64> @ext_i2_2i64(i2 %a0) {
; SSE2-SSSE3-LABEL: ext_i2_2i64:
; SSE2-SSSE3:       # BB#0:
; SSE2-SSSE3-NEXT:    # kill: %EDI<def> %EDI<kill> %RDI<def>
; SSE2-SSSE3-NEXT:    movq %rdi, %xmm0
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm1 = xmm0[0,1,0,1]
; SSE2-SSSE3-NEXT:    movdqa {{.*#+}} xmm0 = [1,2]
; SSE2-SSSE3-NEXT:    pand %xmm0, %xmm1
; SSE2-SSSE3-NEXT:    pcmpeqd %xmm0, %xmm1
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm0 = xmm1[1,0,3,2]
; SSE2-SSSE3-NEXT:    pand %xmm1, %xmm0
; SSE2-SSSE3-NEXT:    psrlq $63, %xmm0
; SSE2-SSSE3-NEXT:    retq
;
; AVX1-LABEL: ext_i2_2i64:
; AVX1:       # BB#0:
; AVX1-NEXT:    # kill: %EDI<def> %EDI<kill> %RDI<def>
; AVX1-NEXT:    vmovq %rdi, %xmm0
; AVX1-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[0,1,0,1]
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm1 = [1,2]
; AVX1-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpcmpeqq %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpsrlq $63, %xmm0, %xmm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: ext_i2_2i64:
; AVX2:       # BB#0:
; AVX2-NEXT:    # kill: %EDI<def> %EDI<kill> %RDI<def>
; AVX2-NEXT:    vmovq %rdi, %xmm0
; AVX2-NEXT:    vpbroadcastq %xmm0, %xmm0
; AVX2-NEXT:    vmovdqa {{.*#+}} xmm1 = [1,2]
; AVX2-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vpcmpeqq %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vpsrlq $63, %xmm0, %xmm0
; AVX2-NEXT:    retq
;
; AVX512-LABEL: ext_i2_2i64:
; AVX512:       # BB#0:
; AVX512-NEXT:    andb $3, %dil
; AVX512-NEXT:    movb %dil, -{{[0-9]+}}(%rsp)
; AVX512-NEXT:    movzbl -{{[0-9]+}}(%rsp), %eax
; AVX512-NEXT:    kmovd %eax, %k1
; AVX512-NEXT:    vpbroadcastq {{.*}}(%rip), %zmm0 {%k1} {z}
; AVX512-NEXT:    # kill: %XMM0<def> %XMM0<kill> %ZMM0<kill>
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = bitcast i2 %a0 to <2 x i1>
  %2 = zext <2 x i1> %1 to <2 x i64>
  ret <2 x i64> %2
}

define <4 x i32> @ext_i4_4i32(i4 %a0) {
; SSE2-SSSE3-LABEL: ext_i4_4i32:
; SSE2-SSSE3:       # BB#0:
; SSE2-SSSE3-NEXT:    movd %edi, %xmm0
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,0,0,0]
; SSE2-SSSE3-NEXT:    movdqa {{.*#+}} xmm1 = [1,2,4,8]
; SSE2-SSSE3-NEXT:    pand %xmm1, %xmm0
; SSE2-SSSE3-NEXT:    pcmpeqd %xmm1, %xmm0
; SSE2-SSSE3-NEXT:    psrld $31, %xmm0
; SSE2-SSSE3-NEXT:    retq
;
; AVX1-LABEL: ext_i4_4i32:
; AVX1:       # BB#0:
; AVX1-NEXT:    vmovd %edi, %xmm0
; AVX1-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[0,0,0,0]
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm1 = [1,2,4,8]
; AVX1-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpcmpeqd %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpsrld $31, %xmm0, %xmm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: ext_i4_4i32:
; AVX2:       # BB#0:
; AVX2-NEXT:    vmovd %edi, %xmm0
; AVX2-NEXT:    vpbroadcastd %xmm0, %xmm0
; AVX2-NEXT:    vmovdqa {{.*#+}} xmm1 = [1,2,4,8]
; AVX2-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vpcmpeqd %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vpsrld $31, %xmm0, %xmm0
; AVX2-NEXT:    retq
;
; AVX512-LABEL: ext_i4_4i32:
; AVX512:       # BB#0:
; AVX512-NEXT:    andb $15, %dil
; AVX512-NEXT:    movb %dil, -{{[0-9]+}}(%rsp)
; AVX512-NEXT:    movzbl -{{[0-9]+}}(%rsp), %eax
; AVX512-NEXT:    kmovd %eax, %k1
; AVX512-NEXT:    vpbroadcastd {{.*}}(%rip), %ymm0 {%k1} {z}
; AVX512-NEXT:    # kill: %XMM0<def> %XMM0<kill> %YMM0<kill>
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = bitcast i4 %a0 to <4 x i1>
  %2 = zext <4 x i1> %1 to <4 x i32>
  ret <4 x i32> %2
}

define <8 x i16> @ext_i8_8i16(i8 %a0) {
; SSE2-SSSE3-LABEL: ext_i8_8i16:
; SSE2-SSSE3:       # BB#0:
; SSE2-SSSE3-NEXT:    movd %edi, %xmm0
; SSE2-SSSE3-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[0,0,0,0,4,5,6,7]
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,0,1,1]
; SSE2-SSSE3-NEXT:    movdqa {{.*#+}} xmm1 = [1,2,4,8,16,32,64,128]
; SSE2-SSSE3-NEXT:    pand %xmm1, %xmm0
; SSE2-SSSE3-NEXT:    pcmpeqw %xmm1, %xmm0
; SSE2-SSSE3-NEXT:    psrlw $15, %xmm0
; SSE2-SSSE3-NEXT:    retq
;
; AVX1-LABEL: ext_i8_8i16:
; AVX1:       # BB#0:
; AVX1-NEXT:    vmovd %edi, %xmm0
; AVX1-NEXT:    vpshuflw {{.*#+}} xmm0 = xmm0[0,0,0,0,4,5,6,7]
; AVX1-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[0,0,1,1]
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm1 = [1,2,4,8,16,32,64,128]
; AVX1-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpcmpeqw %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpsrlw $15, %xmm0, %xmm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: ext_i8_8i16:
; AVX2:       # BB#0:
; AVX2-NEXT:    vmovd %edi, %xmm0
; AVX2-NEXT:    vpbroadcastw %xmm0, %xmm0
; AVX2-NEXT:    vmovdqa {{.*#+}} xmm1 = [1,2,4,8,16,32,64,128]
; AVX2-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vpcmpeqw %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vpsrlw $15, %xmm0, %xmm0
; AVX2-NEXT:    retq
;
; AVX512-LABEL: ext_i8_8i16:
; AVX512:       # BB#0:
; AVX512-NEXT:    kmovd %edi, %k5
; AVX512-NEXT:    kshiftlw $8, %k5, %k0
; AVX512-NEXT:    kshiftrw $15, %k0, %k0
; AVX512-NEXT:    kshiftlw $9, %k5, %k1
; AVX512-NEXT:    kshiftrw $15, %k1, %k1
; AVX512-NEXT:    kshiftlw $10, %k5, %k2
; AVX512-NEXT:    kshiftrw $15, %k2, %k2
; AVX512-NEXT:    kshiftlw $11, %k5, %k3
; AVX512-NEXT:    kshiftrw $15, %k3, %k3
; AVX512-NEXT:    kshiftlw $12, %k5, %k4
; AVX512-NEXT:    kshiftrw $15, %k4, %k4
; AVX512-NEXT:    kshiftlw $13, %k5, %k6
; AVX512-NEXT:    kshiftrw $15, %k6, %k6
; AVX512-NEXT:    kshiftlw $15, %k5, %k7
; AVX512-NEXT:    kshiftrw $15, %k7, %k7
; AVX512-NEXT:    kshiftlw $14, %k5, %k5
; AVX512-NEXT:    kshiftrw $15, %k5, %k5
; AVX512-NEXT:    kmovd %k5, %eax
; AVX512-NEXT:    andl $1, %eax
; AVX512-NEXT:    kmovd %k7, %ecx
; AVX512-NEXT:    andl $1, %ecx
; AVX512-NEXT:    vmovd %ecx, %xmm0
; AVX512-NEXT:    vpinsrw $1, %eax, %xmm0, %xmm0
; AVX512-NEXT:    kmovd %k6, %eax
; AVX512-NEXT:    andl $1, %eax
; AVX512-NEXT:    vpinsrw $2, %eax, %xmm0, %xmm0
; AVX512-NEXT:    kmovd %k4, %eax
; AVX512-NEXT:    andl $1, %eax
; AVX512-NEXT:    vpinsrw $3, %eax, %xmm0, %xmm0
; AVX512-NEXT:    kmovd %k3, %eax
; AVX512-NEXT:    andl $1, %eax
; AVX512-NEXT:    vpinsrw $4, %eax, %xmm0, %xmm0
; AVX512-NEXT:    kmovd %k2, %eax
; AVX512-NEXT:    andl $1, %eax
; AVX512-NEXT:    vpinsrw $5, %eax, %xmm0, %xmm0
; AVX512-NEXT:    kmovd %k1, %eax
; AVX512-NEXT:    andl $1, %eax
; AVX512-NEXT:    vpinsrw $6, %eax, %xmm0, %xmm0
; AVX512-NEXT:    kmovd %k0, %eax
; AVX512-NEXT:    andl $1, %eax
; AVX512-NEXT:    vpinsrw $7, %eax, %xmm0, %xmm0
; AVX512-NEXT:    retq
  %1 = bitcast i8 %a0 to <8 x i1>
  %2 = zext <8 x i1> %1 to <8 x i16>
  ret <8 x i16> %2
}

define <16 x i8> @ext_i16_16i8(i16 %a0) {
; SSE2-LABEL: ext_i16_16i8:
; SSE2:       # BB#0:
; SSE2-NEXT:    movd %edi, %xmm0
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[0,0,1,1,4,5,6,7]
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,0,1,1]
; SSE2-NEXT:    movdqa {{.*#+}} xmm1 = [1,2,4,8,16,32,64,128,1,2,4,8,16,32,64,128]
; SSE2-NEXT:    pand %xmm1, %xmm0
; SSE2-NEXT:    pcmpeqb %xmm1, %xmm0
; SSE2-NEXT:    psrlw $7, %xmm0
; SSE2-NEXT:    pand {{.*}}(%rip), %xmm0
; SSE2-NEXT:    retq
;
; SSSE3-LABEL: ext_i16_16i8:
; SSSE3:       # BB#0:
; SSSE3-NEXT:    movd %edi, %xmm0
; SSSE3-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1]
; SSSE3-NEXT:    movdqa {{.*#+}} xmm1 = [1,2,4,8,16,32,64,128,1,2,4,8,16,32,64,128]
; SSSE3-NEXT:    pand %xmm1, %xmm0
; SSSE3-NEXT:    pcmpeqb %xmm1, %xmm0
; SSSE3-NEXT:    psrlw $7, %xmm0
; SSSE3-NEXT:    pand {{.*}}(%rip), %xmm0
; SSSE3-NEXT:    retq
;
; AVX1-LABEL: ext_i16_16i8:
; AVX1:       # BB#0:
; AVX1-NEXT:    vmovd %edi, %xmm0
; AVX1-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1]
; AVX1-NEXT:    vmovddup {{.*#+}} xmm1 = mem[0,0]
; AVX1-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpcmpeqb %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpsrlw $7, %xmm0, %xmm0
; AVX1-NEXT:    vpand {{.*}}(%rip), %xmm0, %xmm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: ext_i16_16i8:
; AVX2:       # BB#0:
; AVX2-NEXT:    vmovd %edi, %xmm0
; AVX2-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1]
; AVX2-NEXT:    vpbroadcastq {{.*#+}} xmm1 = [9241421688590303745,9241421688590303745]
; AVX2-NEXT:    vpand %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vpcmpeqb %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vpsrlw $7, %xmm0, %xmm0
; AVX2-NEXT:    vpand {{.*}}(%rip), %xmm0, %xmm0
; AVX2-NEXT:    retq
;
; AVX512-LABEL: ext_i16_16i8:
; AVX512:       # BB#0:
; AVX512-NEXT:    pushq %rbp
; AVX512-NEXT:    .cfi_def_cfa_offset 16
; AVX512-NEXT:    pushq %r15
; AVX512-NEXT:    .cfi_def_cfa_offset 24
; AVX512-NEXT:    pushq %r14
; AVX512-NEXT:    .cfi_def_cfa_offset 32
; AVX512-NEXT:    pushq %r13
; AVX512-NEXT:    .cfi_def_cfa_offset 40
; AVX512-NEXT:    pushq %r12
; AVX512-NEXT:    .cfi_def_cfa_offset 48
; AVX512-NEXT:    pushq %rbx
; AVX512-NEXT:    .cfi_def_cfa_offset 56
; AVX512-NEXT:    .cfi_offset %rbx, -56
; AVX512-NEXT:    .cfi_offset %r12, -48
; AVX512-NEXT:    .cfi_offset %r13, -40
; AVX512-NEXT:    .cfi_offset %r14, -32
; AVX512-NEXT:    .cfi_offset %r15, -24
; AVX512-NEXT:    .cfi_offset %rbp, -16
; AVX512-NEXT:    kmovd %edi, %k0
; AVX512-NEXT:    kshiftlw $14, %k0, %k1
; AVX512-NEXT:    kshiftrw $15, %k1, %k1
; AVX512-NEXT:    kmovd %k1, %r8d
; AVX512-NEXT:    kshiftlw $15, %k0, %k1
; AVX512-NEXT:    kshiftrw $15, %k1, %k1
; AVX512-NEXT:    kmovd %k1, %r9d
; AVX512-NEXT:    kshiftlw $13, %k0, %k1
; AVX512-NEXT:    kshiftrw $15, %k1, %k1
; AVX512-NEXT:    kmovd %k1, %r10d
; AVX512-NEXT:    kshiftlw $12, %k0, %k1
; AVX512-NEXT:    kshiftrw $15, %k1, %k1
; AVX512-NEXT:    kmovd %k1, %r11d
; AVX512-NEXT:    kshiftlw $11, %k0, %k1
; AVX512-NEXT:    kshiftrw $15, %k1, %k1
; AVX512-NEXT:    kmovd %k1, %r14d
; AVX512-NEXT:    kshiftlw $10, %k0, %k1
; AVX512-NEXT:    kshiftrw $15, %k1, %k1
; AVX512-NEXT:    kmovd %k1, %r15d
; AVX512-NEXT:    kshiftlw $9, %k0, %k1
; AVX512-NEXT:    kshiftrw $15, %k1, %k1
; AVX512-NEXT:    kmovd %k1, %r12d
; AVX512-NEXT:    kshiftlw $8, %k0, %k1
; AVX512-NEXT:    kshiftrw $15, %k1, %k1
; AVX512-NEXT:    kmovd %k1, %r13d
; AVX512-NEXT:    kshiftlw $7, %k0, %k1
; AVX512-NEXT:    kshiftrw $15, %k1, %k1
; AVX512-NEXT:    kmovd %k1, %esi
; AVX512-NEXT:    kshiftlw $6, %k0, %k1
; AVX512-NEXT:    kshiftrw $15, %k1, %k1
; AVX512-NEXT:    kmovd %k1, %ebx
; AVX512-NEXT:    kshiftlw $5, %k0, %k1
; AVX512-NEXT:    kshiftrw $15, %k1, %k1
; AVX512-NEXT:    kmovd %k1, %ebp
; AVX512-NEXT:    kshiftlw $4, %k0, %k1
; AVX512-NEXT:    kshiftrw $15, %k1, %k1
; AVX512-NEXT:    kmovd %k1, %edi
; AVX512-NEXT:    kshiftlw $3, %k0, %k1
; AVX512-NEXT:    kshiftrw $15, %k1, %k1
; AVX512-NEXT:    kmovd %k1, %eax
; AVX512-NEXT:    kshiftlw $2, %k0, %k1
; AVX512-NEXT:    kshiftrw $15, %k1, %k1
; AVX512-NEXT:    kmovd %k1, %ecx
; AVX512-NEXT:    kshiftlw $1, %k0, %k1
; AVX512-NEXT:    kshiftrw $15, %k1, %k1
; AVX512-NEXT:    kmovd %k1, %edx
; AVX512-NEXT:    kshiftrw $15, %k0, %k0
; AVX512-NEXT:    vmovd %r9d, %xmm0
; AVX512-NEXT:    kmovd %k0, %r9d
; AVX512-NEXT:    vpinsrb $1, %r8d, %xmm0, %xmm0
; AVX512-NEXT:    vpinsrb $2, %r10d, %xmm0, %xmm0
; AVX512-NEXT:    vpinsrb $3, %r11d, %xmm0, %xmm0
; AVX512-NEXT:    vpinsrb $4, %r14d, %xmm0, %xmm0
; AVX512-NEXT:    vpinsrb $5, %r15d, %xmm0, %xmm0
; AVX512-NEXT:    vpinsrb $6, %r12d, %xmm0, %xmm0
; AVX512-NEXT:    vpinsrb $7, %r13d, %xmm0, %xmm0
; AVX512-NEXT:    vpinsrb $8, %esi, %xmm0, %xmm0
; AVX512-NEXT:    vpinsrb $9, %ebx, %xmm0, %xmm0
; AVX512-NEXT:    vpinsrb $10, %ebp, %xmm0, %xmm0
; AVX512-NEXT:    vpinsrb $11, %edi, %xmm0, %xmm0
; AVX512-NEXT:    vpinsrb $12, %eax, %xmm0, %xmm0
; AVX512-NEXT:    vpinsrb $13, %ecx, %xmm0, %xmm0
; AVX512-NEXT:    vpinsrb $14, %edx, %xmm0, %xmm0
; AVX512-NEXT:    vpinsrb $15, %r9d, %xmm0, %xmm0
; AVX512-NEXT:    vpand {{.*}}(%rip), %xmm0, %xmm0
; AVX512-NEXT:    popq %rbx
; AVX512-NEXT:    .cfi_def_cfa_offset 48
; AVX512-NEXT:    popq %r12
; AVX512-NEXT:    .cfi_def_cfa_offset 40
; AVX512-NEXT:    popq %r13
; AVX512-NEXT:    .cfi_def_cfa_offset 32
; AVX512-NEXT:    popq %r14
; AVX512-NEXT:    .cfi_def_cfa_offset 24
; AVX512-NEXT:    popq %r15
; AVX512-NEXT:    .cfi_def_cfa_offset 16
; AVX512-NEXT:    popq %rbp
; AVX512-NEXT:    .cfi_def_cfa_offset 8
; AVX512-NEXT:    retq
  %1 = bitcast i16 %a0 to <16 x i1>
  %2 = zext <16 x i1> %1 to <16 x i8>
  ret <16 x i8> %2
}

;
; 256-bit vectors
;

define <4 x i64> @ext_i4_4i64(i4 %a0) {
; SSE2-SSSE3-LABEL: ext_i4_4i64:
; SSE2-SSSE3:       # BB#0:
; SSE2-SSSE3-NEXT:    # kill: %EDI<def> %EDI<kill> %RDI<def>
; SSE2-SSSE3-NEXT:    movq %rdi, %xmm0
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm2 = xmm0[0,1,0,1]
; SSE2-SSSE3-NEXT:    movdqa {{.*#+}} xmm0 = [1,2]
; SSE2-SSSE3-NEXT:    movdqa %xmm2, %xmm1
; SSE2-SSSE3-NEXT:    pand %xmm0, %xmm1
; SSE2-SSSE3-NEXT:    pcmpeqd %xmm0, %xmm1
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm0 = xmm1[1,0,3,2]
; SSE2-SSSE3-NEXT:    pand %xmm1, %xmm0
; SSE2-SSSE3-NEXT:    psrlq $63, %xmm0
; SSE2-SSSE3-NEXT:    movdqa {{.*#+}} xmm1 = [4,8]
; SSE2-SSSE3-NEXT:    pand %xmm1, %xmm2
; SSE2-SSSE3-NEXT:    pcmpeqd %xmm1, %xmm2
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm1 = xmm2[1,0,3,2]
; SSE2-SSSE3-NEXT:    pand %xmm2, %xmm1
; SSE2-SSSE3-NEXT:    psrlq $63, %xmm1
; SSE2-SSSE3-NEXT:    retq
;
; AVX1-LABEL: ext_i4_4i64:
; AVX1:       # BB#0:
; AVX1-NEXT:    # kill: %EDI<def> %EDI<kill> %RDI<def>
; AVX1-NEXT:    vmovq %rdi, %xmm0
; AVX1-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[0,1,0,1]
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm0, %ymm0
; AVX1-NEXT:    vandps {{.*}}(%rip), %ymm0, %ymm0
; AVX1-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX1-NEXT:    vpcmpeqq %xmm1, %xmm0, %xmm2
; AVX1-NEXT:    vpcmpeqd %xmm3, %xmm3, %xmm3
; AVX1-NEXT:    vpxor %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vpsrlq $63, %xmm2, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX1-NEXT:    vpcmpeqq %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpxor %xmm3, %xmm0, %xmm0
; AVX1-NEXT:    vpsrlq $63, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm2, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: ext_i4_4i64:
; AVX2:       # BB#0:
; AVX2-NEXT:    # kill: %EDI<def> %EDI<kill> %RDI<def>
; AVX2-NEXT:    vmovq %rdi, %xmm0
; AVX2-NEXT:    vpbroadcastq %xmm0, %ymm0
; AVX2-NEXT:    vmovdqa {{.*#+}} ymm1 = [1,2,4,8]
; AVX2-NEXT:    vpand %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vpcmpeqq %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vpsrlq $63, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512-LABEL: ext_i4_4i64:
; AVX512:       # BB#0:
; AVX512-NEXT:    andb $15, %dil
; AVX512-NEXT:    movb %dil, -{{[0-9]+}}(%rsp)
; AVX512-NEXT:    movzbl -{{[0-9]+}}(%rsp), %eax
; AVX512-NEXT:    kmovd %eax, %k1
; AVX512-NEXT:    vpbroadcastq {{.*}}(%rip), %zmm0 {%k1} {z}
; AVX512-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<kill>
; AVX512-NEXT:    retq
  %1 = bitcast i4 %a0 to <4 x i1>
  %2 = zext <4 x i1> %1 to <4 x i64>
  ret <4 x i64> %2
}

define <8 x i32> @ext_i8_8i32(i8 %a0) {
; SSE2-SSSE3-LABEL: ext_i8_8i32:
; SSE2-SSSE3:       # BB#0:
; SSE2-SSSE3-NEXT:    movd %edi, %xmm0
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm1 = xmm0[0,0,0,0]
; SSE2-SSSE3-NEXT:    movdqa {{.*#+}} xmm2 = [1,2,4,8]
; SSE2-SSSE3-NEXT:    movdqa %xmm1, %xmm0
; SSE2-SSSE3-NEXT:    pand %xmm2, %xmm0
; SSE2-SSSE3-NEXT:    pcmpeqd %xmm2, %xmm0
; SSE2-SSSE3-NEXT:    psrld $31, %xmm0
; SSE2-SSSE3-NEXT:    movdqa {{.*#+}} xmm2 = [16,32,64,128]
; SSE2-SSSE3-NEXT:    pand %xmm2, %xmm1
; SSE2-SSSE3-NEXT:    pcmpeqd %xmm2, %xmm1
; SSE2-SSSE3-NEXT:    psrld $31, %xmm1
; SSE2-SSSE3-NEXT:    retq
;
; AVX1-LABEL: ext_i8_8i32:
; AVX1:       # BB#0:
; AVX1-NEXT:    vmovd %edi, %xmm0
; AVX1-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[0,0,0,0]
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm0, %ymm0
; AVX1-NEXT:    vandps {{.*}}(%rip), %ymm0, %ymm0
; AVX1-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX1-NEXT:    vpcmpeqd %xmm1, %xmm0, %xmm2
; AVX1-NEXT:    vpcmpeqd %xmm3, %xmm3, %xmm3
; AVX1-NEXT:    vpxor %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vpsrld $31, %xmm2, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX1-NEXT:    vpcmpeqd %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpxor %xmm3, %xmm0, %xmm0
; AVX1-NEXT:    vpsrld $31, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm2, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: ext_i8_8i32:
; AVX2:       # BB#0:
; AVX2-NEXT:    vmovd %edi, %xmm0
; AVX2-NEXT:    vpbroadcastd %xmm0, %ymm0
; AVX2-NEXT:    vmovdqa {{.*#+}} ymm1 = [1,2,4,8,16,32,64,128]
; AVX2-NEXT:    vpand %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vpcmpeqd %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vpsrld $31, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512-LABEL: ext_i8_8i32:
; AVX512:       # BB#0:
; AVX512-NEXT:    kmovd %edi, %k1
; AVX512-NEXT:    vpbroadcastd {{.*}}(%rip), %ymm0 {%k1} {z}
; AVX512-NEXT:    retq
  %1 = bitcast i8 %a0 to <8 x i1>
  %2 = zext <8 x i1> %1 to <8 x i32>
  ret <8 x i32> %2
}

define <16 x i16> @ext_i16_16i16(i16 %a0) {
; SSE2-SSSE3-LABEL: ext_i16_16i16:
; SSE2-SSSE3:       # BB#0:
; SSE2-SSSE3-NEXT:    movd %edi, %xmm0
; SSE2-SSSE3-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[0,0,0,0,4,5,6,7]
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm1 = xmm0[0,0,1,1]
; SSE2-SSSE3-NEXT:    movdqa {{.*#+}} xmm2 = [1,2,4,8,16,32,64,128]
; SSE2-SSSE3-NEXT:    movdqa %xmm1, %xmm0
; SSE2-SSSE3-NEXT:    pand %xmm2, %xmm0
; SSE2-SSSE3-NEXT:    pcmpeqw %xmm2, %xmm0
; SSE2-SSSE3-NEXT:    psrlw $15, %xmm0
; SSE2-SSSE3-NEXT:    movdqa {{.*#+}} xmm2 = [256,512,1024,2048,4096,8192,16384,32768]
; SSE2-SSSE3-NEXT:    pand %xmm2, %xmm1
; SSE2-SSSE3-NEXT:    pcmpeqw %xmm2, %xmm1
; SSE2-SSSE3-NEXT:    psrlw $15, %xmm1
; SSE2-SSSE3-NEXT:    retq
;
; AVX1-LABEL: ext_i16_16i16:
; AVX1:       # BB#0:
; AVX1-NEXT:    vmovd %edi, %xmm0
; AVX1-NEXT:    vpshuflw {{.*#+}} xmm0 = xmm0[0,0,0,0,4,5,6,7]
; AVX1-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[0,0,1,1]
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm0, %ymm0
; AVX1-NEXT:    vandps {{.*}}(%rip), %ymm0, %ymm0
; AVX1-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX1-NEXT:    vpcmpeqw %xmm1, %xmm0, %xmm2
; AVX1-NEXT:    vpcmpeqd %xmm3, %xmm3, %xmm3
; AVX1-NEXT:    vpxor %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vpsrlw $15, %xmm2, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX1-NEXT:    vpcmpeqw %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpxor %xmm3, %xmm0, %xmm0
; AVX1-NEXT:    vpsrlw $15, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm2, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: ext_i16_16i16:
; AVX2:       # BB#0:
; AVX2-NEXT:    vmovd %edi, %xmm0
; AVX2-NEXT:    vpbroadcastw %xmm0, %ymm0
; AVX2-NEXT:    vmovdqa {{.*#+}} ymm1 = [1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768]
; AVX2-NEXT:    vpand %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vpcmpeqw %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vpsrlw $15, %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512-LABEL: ext_i16_16i16:
; AVX512:       # BB#0:
; AVX512-NEXT:    kmovd %edi, %k1
; AVX512-NEXT:    vmovdqu16 {{.*}}(%rip), %ymm0 {%k1} {z}
; AVX512-NEXT:    retq
  %1 = bitcast i16 %a0 to <16 x i1>
  %2 = zext <16 x i1> %1 to <16 x i16>
  ret <16 x i16> %2
}

define <32 x i8> @ext_i32_32i8(i32 %a0) {
; SSE2-SSSE3-LABEL: ext_i32_32i8:
; SSE2-SSSE3:       # BB#0:
; SSE2-SSSE3-NEXT:    movd %edi, %xmm1
; SSE2-SSSE3-NEXT:    punpcklbw {{.*#+}} xmm1 = xmm1[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE2-SSSE3-NEXT:    pshuflw {{.*#+}} xmm0 = xmm1[0,0,1,1,4,5,6,7]
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,0,1,1]
; SSE2-SSSE3-NEXT:    movdqa {{.*#+}} xmm2 = [1,2,4,8,16,32,64,128,1,2,4,8,16,32,64,128]
; SSE2-SSSE3-NEXT:    pand %xmm2, %xmm0
; SSE2-SSSE3-NEXT:    pcmpeqb %xmm2, %xmm0
; SSE2-SSSE3-NEXT:    psrlw $7, %xmm0
; SSE2-SSSE3-NEXT:    movdqa {{.*#+}} xmm3 = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
; SSE2-SSSE3-NEXT:    pand %xmm3, %xmm0
; SSE2-SSSE3-NEXT:    pshuflw {{.*#+}} xmm1 = xmm1[2,2,3,3,4,5,6,7]
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[0,0,1,1]
; SSE2-SSSE3-NEXT:    pand %xmm2, %xmm1
; SSE2-SSSE3-NEXT:    pcmpeqb %xmm2, %xmm1
; SSE2-SSSE3-NEXT:    psrlw $7, %xmm1
; SSE2-SSSE3-NEXT:    pand %xmm3, %xmm1
; SSE2-SSSE3-NEXT:    retq
;
; AVX1-LABEL: ext_i32_32i8:
; AVX1:       # BB#0:
; AVX1-NEXT:    vmovd %edi, %xmm0
; AVX1-NEXT:    vpunpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; AVX1-NEXT:    vpshuflw {{.*#+}} xmm1 = xmm0[0,0,1,1,4,5,6,7]
; AVX1-NEXT:    vpshufd {{.*#+}} xmm1 = xmm1[0,0,1,1]
; AVX1-NEXT:    vpshuflw {{.*#+}} xmm0 = xmm0[2,2,3,3,4,5,6,7]
; AVX1-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[0,0,1,1]
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; AVX1-NEXT:    vandps {{.*}}(%rip), %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX1-NEXT:    vpxor %xmm2, %xmm2, %xmm2
; AVX1-NEXT:    vpcmpeqb %xmm2, %xmm1, %xmm1
; AVX1-NEXT:    vpcmpeqd %xmm3, %xmm3, %xmm3
; AVX1-NEXT:    vpxor %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vpsrlw $7, %xmm1, %xmm1
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm4 = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
; AVX1-NEXT:    vpand %xmm4, %xmm1, %xmm1
; AVX1-NEXT:    vpcmpeqb %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vpxor %xmm3, %xmm0, %xmm0
; AVX1-NEXT:    vpsrlw $7, %xmm0, %xmm0
; AVX1-NEXT:    vpand %xmm4, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: ext_i32_32i8:
; AVX2:       # BB#0:
; AVX2-NEXT:    vmovd %edi, %xmm0
; AVX2-NEXT:    vpunpcklbw {{.*#+}} xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; AVX2-NEXT:    vpshuflw {{.*#+}} xmm1 = xmm0[0,0,1,1,4,5,6,7]
; AVX2-NEXT:    vpshufd {{.*#+}} xmm1 = xmm1[0,0,1,1]
; AVX2-NEXT:    vpshuflw {{.*#+}} xmm0 = xmm0[2,2,3,3,4,5,6,7]
; AVX2-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[0,0,1,1]
; AVX2-NEXT:    vinserti128 $1, %xmm0, %ymm1, %ymm0
; AVX2-NEXT:    vpbroadcastq {{.*#+}} ymm1 = [9241421688590303745,9241421688590303745,9241421688590303745,9241421688590303745]
; AVX2-NEXT:    vpand %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vpcmpeqb %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vpsrlw $7, %ymm0, %ymm0
; AVX2-NEXT:    vpand {{.*}}(%rip), %ymm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512-LABEL: ext_i32_32i8:
; AVX512:       # BB#0:
; AVX512-NEXT:    kmovd %edi, %k1
; AVX512-NEXT:    vmovdqu8 {{.*}}(%rip), %ymm0 {%k1} {z}
; AVX512-NEXT:    retq
  %1 = bitcast i32 %a0 to <32 x i1>
  %2 = zext <32 x i1> %1 to <32 x i8>
  ret <32 x i8> %2
}

;
; 512-bit vectors
;

define <8 x i64> @ext_i8_8i64(i8 %a0) {
; SSE2-SSSE3-LABEL: ext_i8_8i64:
; SSE2-SSSE3:       # BB#0:
; SSE2-SSSE3-NEXT:    # kill: %EDI<def> %EDI<kill> %RDI<def>
; SSE2-SSSE3-NEXT:    movq %rdi, %xmm0
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm4 = xmm0[0,1,0,1]
; SSE2-SSSE3-NEXT:    movdqa {{.*#+}} xmm0 = [1,2]
; SSE2-SSSE3-NEXT:    movdqa %xmm4, %xmm1
; SSE2-SSSE3-NEXT:    pand %xmm0, %xmm1
; SSE2-SSSE3-NEXT:    pcmpeqd %xmm0, %xmm1
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm0 = xmm1[1,0,3,2]
; SSE2-SSSE3-NEXT:    pand %xmm1, %xmm0
; SSE2-SSSE3-NEXT:    psrlq $63, %xmm0
; SSE2-SSSE3-NEXT:    movdqa {{.*#+}} xmm1 = [4,8]
; SSE2-SSSE3-NEXT:    movdqa %xmm4, %xmm2
; SSE2-SSSE3-NEXT:    pand %xmm1, %xmm2
; SSE2-SSSE3-NEXT:    pcmpeqd %xmm1, %xmm2
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm1 = xmm2[1,0,3,2]
; SSE2-SSSE3-NEXT:    pand %xmm2, %xmm1
; SSE2-SSSE3-NEXT:    psrlq $63, %xmm1
; SSE2-SSSE3-NEXT:    movdqa {{.*#+}} xmm2 = [16,32]
; SSE2-SSSE3-NEXT:    movdqa %xmm4, %xmm3
; SSE2-SSSE3-NEXT:    pand %xmm2, %xmm3
; SSE2-SSSE3-NEXT:    pcmpeqd %xmm2, %xmm3
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm2 = xmm3[1,0,3,2]
; SSE2-SSSE3-NEXT:    pand %xmm3, %xmm2
; SSE2-SSSE3-NEXT:    psrlq $63, %xmm2
; SSE2-SSSE3-NEXT:    movdqa {{.*#+}} xmm3 = [64,128]
; SSE2-SSSE3-NEXT:    pand %xmm3, %xmm4
; SSE2-SSSE3-NEXT:    pcmpeqd %xmm3, %xmm4
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm3 = xmm4[1,0,3,2]
; SSE2-SSSE3-NEXT:    pand %xmm4, %xmm3
; SSE2-SSSE3-NEXT:    psrlq $63, %xmm3
; SSE2-SSSE3-NEXT:    retq
;
; AVX1-LABEL: ext_i8_8i64:
; AVX1:       # BB#0:
; AVX1-NEXT:    # kill: %EDI<def> %EDI<kill> %RDI<def>
; AVX1-NEXT:    vmovq %rdi, %xmm0
; AVX1-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[0,1,0,1]
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm0, %ymm1
; AVX1-NEXT:    vandps {{.*}}(%rip), %ymm1, %ymm0
; AVX1-NEXT:    vpxor %xmm2, %xmm2, %xmm2
; AVX1-NEXT:    vpcmpeqq %xmm2, %xmm0, %xmm3
; AVX1-NEXT:    vpcmpeqd %xmm4, %xmm4, %xmm4
; AVX1-NEXT:    vpxor %xmm4, %xmm3, %xmm3
; AVX1-NEXT:    vpsrlq $63, %xmm3, %xmm3
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX1-NEXT:    vpcmpeqq %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vpxor %xmm4, %xmm0, %xmm0
; AVX1-NEXT:    vpsrlq $63, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm3, %ymm0
; AVX1-NEXT:    vandps {{.*}}(%rip), %ymm1, %ymm1
; AVX1-NEXT:    vpcmpeqq %xmm2, %xmm1, %xmm3
; AVX1-NEXT:    vpxor %xmm4, %xmm3, %xmm3
; AVX1-NEXT:    vpsrlq $63, %xmm3, %xmm3
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm1
; AVX1-NEXT:    vpcmpeqq %xmm2, %xmm1, %xmm1
; AVX1-NEXT:    vpxor %xmm4, %xmm1, %xmm1
; AVX1-NEXT:    vpsrlq $63, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm3, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: ext_i8_8i64:
; AVX2:       # BB#0:
; AVX2-NEXT:    # kill: %EDI<def> %EDI<kill> %RDI<def>
; AVX2-NEXT:    vmovq %rdi, %xmm0
; AVX2-NEXT:    vpbroadcastq %xmm0, %ymm1
; AVX2-NEXT:    vmovdqa {{.*#+}} ymm0 = [1,2,4,8]
; AVX2-NEXT:    vpand %ymm0, %ymm1, %ymm2
; AVX2-NEXT:    vpcmpeqq %ymm0, %ymm2, %ymm0
; AVX2-NEXT:    vpsrlq $63, %ymm0, %ymm0
; AVX2-NEXT:    vmovdqa {{.*#+}} ymm2 = [16,32,64,128]
; AVX2-NEXT:    vpand %ymm2, %ymm1, %ymm1
; AVX2-NEXT:    vpcmpeqq %ymm2, %ymm1, %ymm1
; AVX2-NEXT:    vpsrlq $63, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512-LABEL: ext_i8_8i64:
; AVX512:       # BB#0:
; AVX512-NEXT:    kmovd %edi, %k1
; AVX512-NEXT:    vpbroadcastq {{.*}}(%rip), %zmm0 {%k1} {z}
; AVX512-NEXT:    retq
  %1 = bitcast i8 %a0 to <8 x i1>
  %2 = zext <8 x i1> %1 to <8 x i64>
  ret <8 x i64> %2
}

define <16 x i32> @ext_i16_16i32(i16 %a0) {
; SSE2-SSSE3-LABEL: ext_i16_16i32:
; SSE2-SSSE3:       # BB#0:
; SSE2-SSSE3-NEXT:    movd %edi, %xmm0
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm3 = xmm0[0,0,0,0]
; SSE2-SSSE3-NEXT:    movdqa {{.*#+}} xmm1 = [1,2,4,8]
; SSE2-SSSE3-NEXT:    movdqa %xmm3, %xmm0
; SSE2-SSSE3-NEXT:    pand %xmm1, %xmm0
; SSE2-SSSE3-NEXT:    pcmpeqd %xmm1, %xmm0
; SSE2-SSSE3-NEXT:    psrld $31, %xmm0
; SSE2-SSSE3-NEXT:    movdqa {{.*#+}} xmm2 = [16,32,64,128]
; SSE2-SSSE3-NEXT:    movdqa %xmm3, %xmm1
; SSE2-SSSE3-NEXT:    pand %xmm2, %xmm1
; SSE2-SSSE3-NEXT:    pcmpeqd %xmm2, %xmm1
; SSE2-SSSE3-NEXT:    psrld $31, %xmm1
; SSE2-SSSE3-NEXT:    movdqa {{.*#+}} xmm4 = [256,512,1024,2048]
; SSE2-SSSE3-NEXT:    movdqa %xmm3, %xmm2
; SSE2-SSSE3-NEXT:    pand %xmm4, %xmm2
; SSE2-SSSE3-NEXT:    pcmpeqd %xmm4, %xmm2
; SSE2-SSSE3-NEXT:    psrld $31, %xmm2
; SSE2-SSSE3-NEXT:    movdqa {{.*#+}} xmm4 = [4096,8192,16384,32768]
; SSE2-SSSE3-NEXT:    pand %xmm4, %xmm3
; SSE2-SSSE3-NEXT:    pcmpeqd %xmm4, %xmm3
; SSE2-SSSE3-NEXT:    psrld $31, %xmm3
; SSE2-SSSE3-NEXT:    retq
;
; AVX1-LABEL: ext_i16_16i32:
; AVX1:       # BB#0:
; AVX1-NEXT:    vmovd %edi, %xmm0
; AVX1-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[0,0,0,0]
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm0, %ymm1
; AVX1-NEXT:    vandps {{.*}}(%rip), %ymm1, %ymm0
; AVX1-NEXT:    vpxor %xmm2, %xmm2, %xmm2
; AVX1-NEXT:    vpcmpeqd %xmm2, %xmm0, %xmm3
; AVX1-NEXT:    vpcmpeqd %xmm4, %xmm4, %xmm4
; AVX1-NEXT:    vpxor %xmm4, %xmm3, %xmm3
; AVX1-NEXT:    vpsrld $31, %xmm3, %xmm3
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX1-NEXT:    vpcmpeqd %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vpxor %xmm4, %xmm0, %xmm0
; AVX1-NEXT:    vpsrld $31, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm3, %ymm0
; AVX1-NEXT:    vandps {{.*}}(%rip), %ymm1, %ymm1
; AVX1-NEXT:    vpcmpeqd %xmm2, %xmm1, %xmm3
; AVX1-NEXT:    vpxor %xmm4, %xmm3, %xmm3
; AVX1-NEXT:    vpsrld $31, %xmm3, %xmm3
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm1
; AVX1-NEXT:    vpcmpeqd %xmm2, %xmm1, %xmm1
; AVX1-NEXT:    vpxor %xmm4, %xmm1, %xmm1
; AVX1-NEXT:    vpsrld $31, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm3, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: ext_i16_16i32:
; AVX2:       # BB#0:
; AVX2-NEXT:    vmovd %edi, %xmm0
; AVX2-NEXT:    vpbroadcastd %xmm0, %ymm1
; AVX2-NEXT:    vmovdqa {{.*#+}} ymm0 = [1,2,4,8,16,32,64,128]
; AVX2-NEXT:    vpand %ymm0, %ymm1, %ymm2
; AVX2-NEXT:    vpcmpeqd %ymm0, %ymm2, %ymm0
; AVX2-NEXT:    vpsrld $31, %ymm0, %ymm0
; AVX2-NEXT:    vmovdqa {{.*#+}} ymm2 = [256,512,1024,2048,4096,8192,16384,32768]
; AVX2-NEXT:    vpand %ymm2, %ymm1, %ymm1
; AVX2-NEXT:    vpcmpeqd %ymm2, %ymm1, %ymm1
; AVX2-NEXT:    vpsrld $31, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512-LABEL: ext_i16_16i32:
; AVX512:       # BB#0:
; AVX512-NEXT:    kmovd %edi, %k1
; AVX512-NEXT:    vpbroadcastd {{.*}}(%rip), %zmm0 {%k1} {z}
; AVX512-NEXT:    retq
  %1 = bitcast i16 %a0 to <16 x i1>
  %2 = zext <16 x i1> %1 to <16 x i32>
  ret <16 x i32> %2
}

define <32 x i16> @ext_i32_32i16(i32 %a0) {
; SSE2-SSSE3-LABEL: ext_i32_32i16:
; SSE2-SSSE3:       # BB#0:
; SSE2-SSSE3-NEXT:    movd %edi, %xmm2
; SSE2-SSSE3-NEXT:    pshuflw {{.*#+}} xmm0 = xmm2[0,0,0,0,4,5,6,7]
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm1 = xmm0[0,0,1,1]
; SSE2-SSSE3-NEXT:    movdqa {{.*#+}} xmm4 = [1,2,4,8,16,32,64,128]
; SSE2-SSSE3-NEXT:    movdqa %xmm1, %xmm0
; SSE2-SSSE3-NEXT:    pand %xmm4, %xmm0
; SSE2-SSSE3-NEXT:    pcmpeqw %xmm4, %xmm0
; SSE2-SSSE3-NEXT:    psrlw $15, %xmm0
; SSE2-SSSE3-NEXT:    movdqa {{.*#+}} xmm5 = [256,512,1024,2048,4096,8192,16384,32768]
; SSE2-SSSE3-NEXT:    pand %xmm5, %xmm1
; SSE2-SSSE3-NEXT:    pcmpeqw %xmm5, %xmm1
; SSE2-SSSE3-NEXT:    psrlw $15, %xmm1
; SSE2-SSSE3-NEXT:    pshuflw {{.*#+}} xmm2 = xmm2[1,1,1,1,4,5,6,7]
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm3 = xmm2[0,0,1,1]
; SSE2-SSSE3-NEXT:    movdqa %xmm3, %xmm2
; SSE2-SSSE3-NEXT:    pand %xmm4, %xmm2
; SSE2-SSSE3-NEXT:    pcmpeqw %xmm4, %xmm2
; SSE2-SSSE3-NEXT:    psrlw $15, %xmm2
; SSE2-SSSE3-NEXT:    pand %xmm5, %xmm3
; SSE2-SSSE3-NEXT:    pcmpeqw %xmm5, %xmm3
; SSE2-SSSE3-NEXT:    psrlw $15, %xmm3
; SSE2-SSSE3-NEXT:    retq
;
; AVX1-LABEL: ext_i32_32i16:
; AVX1:       # BB#0:
; AVX1-NEXT:    vmovd %edi, %xmm1
; AVX1-NEXT:    vpshuflw {{.*#+}} xmm0 = xmm1[0,0,0,0,4,5,6,7]
; AVX1-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[0,0,1,1]
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm0, %ymm0
; AVX1-NEXT:    vmovaps {{.*#+}} ymm2 = [1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768]
; AVX1-NEXT:    vandps %ymm2, %ymm0, %ymm0
; AVX1-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX1-NEXT:    vpcmpeqw %xmm3, %xmm0, %xmm4
; AVX1-NEXT:    vpcmpeqd %xmm5, %xmm5, %xmm5
; AVX1-NEXT:    vpxor %xmm5, %xmm4, %xmm4
; AVX1-NEXT:    vpsrlw $15, %xmm4, %xmm4
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX1-NEXT:    vpcmpeqw %xmm3, %xmm0, %xmm0
; AVX1-NEXT:    vpxor %xmm5, %xmm0, %xmm0
; AVX1-NEXT:    vpsrlw $15, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm4, %ymm0
; AVX1-NEXT:    vpshuflw {{.*#+}} xmm1 = xmm1[1,1,1,1,4,5,6,7]
; AVX1-NEXT:    vpshufd {{.*#+}} xmm1 = xmm1[0,0,1,1]
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm1, %ymm1
; AVX1-NEXT:    vandps %ymm2, %ymm1, %ymm1
; AVX1-NEXT:    vpcmpeqw %xmm3, %xmm1, %xmm2
; AVX1-NEXT:    vpxor %xmm5, %xmm2, %xmm2
; AVX1-NEXT:    vpsrlw $15, %xmm2, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm1
; AVX1-NEXT:    vpcmpeqw %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vpxor %xmm5, %xmm1, %xmm1
; AVX1-NEXT:    vpsrlw $15, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm2, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: ext_i32_32i16:
; AVX2:       # BB#0:
; AVX2-NEXT:    vmovd %edi, %xmm0
; AVX2-NEXT:    vpbroadcastw %xmm0, %ymm0
; AVX2-NEXT:    vmovdqa {{.*#+}} ymm1 = [1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768]
; AVX2-NEXT:    vpand %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vpcmpeqw %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vpsrlw $15, %ymm0, %ymm0
; AVX2-NEXT:    shrl $16, %edi
; AVX2-NEXT:    vmovd %edi, %xmm2
; AVX2-NEXT:    vpbroadcastw %xmm2, %ymm2
; AVX2-NEXT:    vpand %ymm1, %ymm2, %ymm2
; AVX2-NEXT:    vpcmpeqw %ymm1, %ymm2, %ymm1
; AVX2-NEXT:    vpsrlw $15, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512-LABEL: ext_i32_32i16:
; AVX512:       # BB#0:
; AVX512-NEXT:    kmovd %edi, %k1
; AVX512-NEXT:    vmovdqu16 {{.*}}(%rip), %zmm0 {%k1} {z}
; AVX512-NEXT:    retq
  %1 = bitcast i32 %a0 to <32 x i1>
  %2 = zext <32 x i1> %1 to <32 x i16>
  ret <32 x i16> %2
}

define <64 x i8> @ext_i64_64i8(i64 %a0) {
; SSE2-SSSE3-LABEL: ext_i64_64i8:
; SSE2-SSSE3:       # BB#0:
; SSE2-SSSE3-NEXT:    movq %rdi, %xmm3
; SSE2-SSSE3-NEXT:    punpcklbw {{.*#+}} xmm3 = xmm3[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; SSE2-SSSE3-NEXT:    pshuflw {{.*#+}} xmm0 = xmm3[0,0,1,1,4,5,6,7]
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,0,1,1]
; SSE2-SSSE3-NEXT:    movdqa {{.*#+}} xmm4 = [1,2,4,8,16,32,64,128,1,2,4,8,16,32,64,128]
; SSE2-SSSE3-NEXT:    pand %xmm4, %xmm0
; SSE2-SSSE3-NEXT:    pcmpeqb %xmm4, %xmm0
; SSE2-SSSE3-NEXT:    psrlw $7, %xmm0
; SSE2-SSSE3-NEXT:    movdqa {{.*#+}} xmm5 = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
; SSE2-SSSE3-NEXT:    pand %xmm5, %xmm0
; SSE2-SSSE3-NEXT:    pshuflw {{.*#+}} xmm1 = xmm3[2,2,3,3,4,5,6,7]
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[0,0,1,1]
; SSE2-SSSE3-NEXT:    pand %xmm4, %xmm1
; SSE2-SSSE3-NEXT:    pcmpeqb %xmm4, %xmm1
; SSE2-SSSE3-NEXT:    psrlw $7, %xmm1
; SSE2-SSSE3-NEXT:    pand %xmm5, %xmm1
; SSE2-SSSE3-NEXT:    pshufhw {{.*#+}} xmm2 = xmm3[0,1,2,3,4,4,5,5]
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm2 = xmm2[2,2,3,3]
; SSE2-SSSE3-NEXT:    pand %xmm4, %xmm2
; SSE2-SSSE3-NEXT:    pcmpeqb %xmm4, %xmm2
; SSE2-SSSE3-NEXT:    psrlw $7, %xmm2
; SSE2-SSSE3-NEXT:    pand %xmm5, %xmm2
; SSE2-SSSE3-NEXT:    pshufhw {{.*#+}} xmm3 = xmm3[0,1,2,3,6,6,7,7]
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm3 = xmm3[2,2,3,3]
; SSE2-SSSE3-NEXT:    pand %xmm4, %xmm3
; SSE2-SSSE3-NEXT:    pcmpeqb %xmm4, %xmm3
; SSE2-SSSE3-NEXT:    psrlw $7, %xmm3
; SSE2-SSSE3-NEXT:    pand %xmm5, %xmm3
; SSE2-SSSE3-NEXT:    retq
;
; AVX1-LABEL: ext_i64_64i8:
; AVX1:       # BB#0:
; AVX1-NEXT:    vmovq %rdi, %xmm0
; AVX1-NEXT:    vpunpcklbw {{.*#+}} xmm1 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; AVX1-NEXT:    vpshuflw {{.*#+}} xmm0 = xmm1[0,0,1,1,4,5,6,7]
; AVX1-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[0,0,1,1]
; AVX1-NEXT:    vpshuflw {{.*#+}} xmm2 = xmm1[2,2,3,3,4,5,6,7]
; AVX1-NEXT:    vpshufd {{.*#+}} xmm2 = xmm2[0,0,1,1]
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    vmovaps {{.*#+}} ymm2 = [1,2,4,8,16,32,64,128,1,2,4,8,16,32,64,128,1,2,4,8,16,32,64,128,1,2,4,8,16,32,64,128]
; AVX1-NEXT:    vandps %ymm2, %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpxor %xmm4, %xmm4, %xmm4
; AVX1-NEXT:    vpcmpeqb %xmm4, %xmm3, %xmm3
; AVX1-NEXT:    vpcmpeqd %xmm5, %xmm5, %xmm5
; AVX1-NEXT:    vpxor %xmm5, %xmm3, %xmm3
; AVX1-NEXT:    vpsrlw $7, %xmm3, %xmm3
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm6 = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
; AVX1-NEXT:    vpand %xmm6, %xmm3, %xmm3
; AVX1-NEXT:    vpcmpeqb %xmm4, %xmm0, %xmm0
; AVX1-NEXT:    vpxor %xmm5, %xmm0, %xmm0
; AVX1-NEXT:    vpsrlw $7, %xmm0, %xmm0
; AVX1-NEXT:    vpand %xmm6, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm3, %ymm0, %ymm0
; AVX1-NEXT:    vpshufhw {{.*#+}} xmm3 = xmm1[0,1,2,3,4,4,5,5]
; AVX1-NEXT:    vpshufd {{.*#+}} xmm3 = xmm3[2,2,3,3]
; AVX1-NEXT:    vpshufhw {{.*#+}} xmm1 = xmm1[0,1,2,3,6,6,7,7]
; AVX1-NEXT:    vpshufd {{.*#+}} xmm1 = xmm1[2,2,3,3]
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm3, %ymm1
; AVX1-NEXT:    vandps %ymm2, %ymm1, %ymm1
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vpcmpeqb %xmm4, %xmm2, %xmm2
; AVX1-NEXT:    vpxor %xmm5, %xmm2, %xmm2
; AVX1-NEXT:    vpsrlw $7, %xmm2, %xmm2
; AVX1-NEXT:    vpand %xmm6, %xmm2, %xmm2
; AVX1-NEXT:    vpcmpeqb %xmm4, %xmm1, %xmm1
; AVX1-NEXT:    vpxor %xmm5, %xmm1, %xmm1
; AVX1-NEXT:    vpsrlw $7, %xmm1, %xmm1
; AVX1-NEXT:    vpand %xmm6, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm1, %ymm1
; AVX1-NEXT:    retq
;
; AVX2-LABEL: ext_i64_64i8:
; AVX2:       # BB#0:
; AVX2-NEXT:    vmovq %rdi, %xmm0
; AVX2-NEXT:    vpunpcklbw {{.*#+}} xmm1 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
; AVX2-NEXT:    vpshuflw {{.*#+}} xmm0 = xmm1[0,0,1,1,4,5,6,7]
; AVX2-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[0,0,1,1]
; AVX2-NEXT:    vpshuflw {{.*#+}} xmm2 = xmm1[2,2,3,3,4,5,6,7]
; AVX2-NEXT:    vpshufd {{.*#+}} xmm2 = xmm2[0,0,1,1]
; AVX2-NEXT:    vinserti128 $1, %xmm2, %ymm0, %ymm0
; AVX2-NEXT:    vpbroadcastq {{.*#+}} ymm2 = [9241421688590303745,9241421688590303745,9241421688590303745,9241421688590303745]
; AVX2-NEXT:    vpand %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpcmpeqb %ymm2, %ymm0, %ymm0
; AVX2-NEXT:    vpsrlw $7, %ymm0, %ymm0
; AVX2-NEXT:    vmovdqa {{.*#+}} ymm3 = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
; AVX2-NEXT:    vpand %ymm3, %ymm0, %ymm0
; AVX2-NEXT:    vpshufhw {{.*#+}} xmm4 = xmm1[0,1,2,3,4,4,5,5]
; AVX2-NEXT:    vpshufd {{.*#+}} xmm4 = xmm4[2,2,3,3]
; AVX2-NEXT:    vpshufhw {{.*#+}} xmm1 = xmm1[0,1,2,3,6,6,7,7]
; AVX2-NEXT:    vpshufd {{.*#+}} xmm1 = xmm1[2,2,3,3]
; AVX2-NEXT:    vinserti128 $1, %xmm1, %ymm4, %ymm1
; AVX2-NEXT:    vpand %ymm2, %ymm1, %ymm1
; AVX2-NEXT:    vpcmpeqb %ymm2, %ymm1, %ymm1
; AVX2-NEXT:    vpsrlw $7, %ymm1, %ymm1
; AVX2-NEXT:    vpand %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    retq
;
; AVX512-LABEL: ext_i64_64i8:
; AVX512:       # BB#0:
; AVX512-NEXT:    kmovq %rdi, %k1
; AVX512-NEXT:    vmovdqu8 {{.*}}(%rip), %zmm0 {%k1} {z}
; AVX512-NEXT:    retq
  %1 = bitcast i64 %a0 to <64 x i1>
  %2 = zext <64 x i1> %1 to <64 x i8>
  ret <64 x i8> %2
}
