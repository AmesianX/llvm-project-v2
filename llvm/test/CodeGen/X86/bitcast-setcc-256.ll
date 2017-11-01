; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+SSE2 | FileCheck %s --check-prefixes=SSE2-SSSE3,SSE2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+SSSE3 | FileCheck %s --check-prefixes=SSE2-SSSE3,SSSE3
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx | FileCheck %s --check-prefixes=AVX12,AVX1
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx2 | FileCheck %s --check-prefixes=AVX12,AVX2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512f,+avx512vl | FileCheck %s --check-prefixes=AVX512 --check-prefixes=AVX512F
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512f,+avx512vl,+avx512bw | FileCheck %s --check-prefixes=AVX512 --check-prefixes=AVX512BW

define i16 @v16i16(<16 x i16> %a, <16 x i16> %b) {
; SSE2-SSSE3-LABEL: v16i16:
; SSE2-SSSE3:       # BB#0:
; SSE2-SSSE3-NEXT:    pcmpgtw %xmm3, %xmm1
; SSE2-SSSE3-NEXT:    pcmpgtw %xmm2, %xmm0
; SSE2-SSSE3-NEXT:    packsswb %xmm1, %xmm0
; SSE2-SSSE3-NEXT:    pmovmskb %xmm0, %eax
; SSE2-SSSE3-NEXT:    # kill: %AX<def> %AX<kill> %EAX<kill>
; SSE2-SSSE3-NEXT:    retq
;
; AVX1-LABEL: v16i16:
; AVX1:       # BB#0:
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpcmpgtw %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpcmpgtw %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpacksswb %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vpmovmskb %xmm0, %eax
; AVX1-NEXT:    # kill: %AX<def> %AX<kill> %EAX<kill>
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: v16i16:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpcmpgtw %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vextracti128 $1, %ymm0, %xmm1
; AVX2-NEXT:    vpacksswb %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vpmovmskb %xmm0, %eax
; AVX2-NEXT:    # kill: %AX<def> %AX<kill> %EAX<kill>
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: v16i16:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    vpcmpgtw %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    vpmovsxwd %ymm0, %zmm0
; AVX512F-NEXT:    vpslld $31, %zmm0, %zmm0
; AVX512F-NEXT:    vptestmd %zmm0, %zmm0, %k0
; AVX512F-NEXT:    kmovw %k0, %eax
; AVX512F-NEXT:    # kill: %AX<def> %AX<kill> %EAX<kill>
; AVX512F-NEXT:    vzeroupper
; AVX512F-NEXT:    retq
;
; AVX512BW-LABEL: v16i16:
; AVX512BW:       # BB#0:
; AVX512BW-NEXT:    vpcmpgtw %ymm1, %ymm0, %k0
; AVX512BW-NEXT:    kmovd %k0, %eax
; AVX512BW-NEXT:    # kill: %AX<def> %AX<kill> %EAX<kill>
; AVX512BW-NEXT:    vzeroupper
; AVX512BW-NEXT:    retq
  %x = icmp sgt <16 x i16> %a, %b
  %res = bitcast <16 x i1> %x to i16
  ret i16 %res
}

define i8 @v8i32(<8 x i32> %a, <8 x i32> %b) {
; SSE2-SSSE3-LABEL: v8i32:
; SSE2-SSSE3:       # BB#0:
; SSE2-SSSE3-NEXT:    pcmpgtd %xmm3, %xmm1
; SSE2-SSSE3-NEXT:    pcmpgtd %xmm2, %xmm0
; SSE2-SSSE3-NEXT:    packssdw %xmm1, %xmm0
; SSE2-SSSE3-NEXT:    packsswb %xmm0, %xmm0
; SSE2-SSSE3-NEXT:    pmovmskb %xmm0, %eax
; SSE2-SSSE3-NEXT:    # kill: %AL<def> %AL<kill> %EAX<kill>
; SSE2-SSSE3-NEXT:    retq
;
; AVX1-LABEL: v8i32:
; AVX1:       # BB#0:
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpcmpgtd %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpcmpgtd %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    vmovmskps %ymm0, %eax
; AVX1-NEXT:    # kill: %AL<def> %AL<kill> %EAX<kill>
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: v8i32:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpcmpgtd %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vmovmskps %ymm0, %eax
; AVX2-NEXT:    # kill: %AL<def> %AL<kill> %EAX<kill>
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: v8i32:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    vpcmpgtd %ymm1, %ymm0, %k0
; AVX512F-NEXT:    kmovw %k0, %eax
; AVX512F-NEXT:    # kill: %AL<def> %AL<kill> %EAX<kill>
; AVX512F-NEXT:    vzeroupper
; AVX512F-NEXT:    retq
;
; AVX512BW-LABEL: v8i32:
; AVX512BW:       # BB#0:
; AVX512BW-NEXT:    vpcmpgtd %ymm1, %ymm0, %k0
; AVX512BW-NEXT:    kmovd %k0, %eax
; AVX512BW-NEXT:    # kill: %AL<def> %AL<kill> %EAX<kill>
; AVX512BW-NEXT:    vzeroupper
; AVX512BW-NEXT:    retq
  %x = icmp sgt <8 x i32> %a, %b
  %res = bitcast <8 x i1> %x to i8
  ret i8 %res
}

define i8 @v8f32(<8 x float> %a, <8 x float> %b) {
; SSE2-SSSE3-LABEL: v8f32:
; SSE2-SSSE3:       # BB#0:
; SSE2-SSSE3-NEXT:    cmpltps %xmm1, %xmm3
; SSE2-SSSE3-NEXT:    cmpltps %xmm0, %xmm2
; SSE2-SSSE3-NEXT:    packssdw %xmm3, %xmm2
; SSE2-SSSE3-NEXT:    packsswb %xmm0, %xmm2
; SSE2-SSSE3-NEXT:    pmovmskb %xmm2, %eax
; SSE2-SSSE3-NEXT:    # kill: %AL<def> %AL<kill> %EAX<kill>
; SSE2-SSSE3-NEXT:    retq
;
; AVX12-LABEL: v8f32:
; AVX12:       # BB#0:
; AVX12-NEXT:    vcmpltps %ymm0, %ymm1, %ymm0
; AVX12-NEXT:    vmovmskps %ymm0, %eax
; AVX12-NEXT:    # kill: %AL<def> %AL<kill> %EAX<kill>
; AVX12-NEXT:    vzeroupper
; AVX12-NEXT:    retq
;
; AVX512F-LABEL: v8f32:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    vcmpltps %ymm0, %ymm1, %k0
; AVX512F-NEXT:    kmovw %k0, %eax
; AVX512F-NEXT:    # kill: %AL<def> %AL<kill> %EAX<kill>
; AVX512F-NEXT:    vzeroupper
; AVX512F-NEXT:    retq
;
; AVX512BW-LABEL: v8f32:
; AVX512BW:       # BB#0:
; AVX512BW-NEXT:    vcmpltps %ymm0, %ymm1, %k0
; AVX512BW-NEXT:    kmovd %k0, %eax
; AVX512BW-NEXT:    # kill: %AL<def> %AL<kill> %EAX<kill>
; AVX512BW-NEXT:    vzeroupper
; AVX512BW-NEXT:    retq
  %x = fcmp ogt <8 x float> %a, %b
  %res = bitcast <8 x i1> %x to i8
  ret i8 %res
}

define i32 @v32i8(<32 x i8> %a, <32 x i8> %b) {
; SSE2-SSSE3-LABEL: v32i8:
; SSE2-SSSE3:       # BB#0:
; SSE2-SSSE3-NEXT:    pcmpgtb %xmm2, %xmm0
; SSE2-SSSE3-NEXT:    pmovmskb %xmm0, %ecx
; SSE2-SSSE3-NEXT:    pcmpgtb %xmm3, %xmm1
; SSE2-SSSE3-NEXT:    pmovmskb %xmm1, %eax
; SSE2-SSSE3-NEXT:    shll $16, %eax
; SSE2-SSSE3-NEXT:    orl %ecx, %eax
; SSE2-SSSE3-NEXT:    retq
;
; AVX1-LABEL: v32i8:
; AVX1:       # BB#0:
; AVX1-NEXT:    vpcmpgtb %xmm1, %xmm0, %xmm2
; AVX1-NEXT:    vpmovmskb %xmm2, %ecx
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm1
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX1-NEXT:    vpcmpgtb %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpmovmskb %xmm0, %eax
; AVX1-NEXT:    shll $16, %eax
; AVX1-NEXT:    orl %ecx, %eax
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: v32i8:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpcmpgtb %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vpmovmskb %ymm0, %eax
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: v32i8:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    pushq %rbp
; AVX512F-NEXT:    .cfi_def_cfa_offset 16
; AVX512F-NEXT:    .cfi_offset %rbp, -16
; AVX512F-NEXT:    movq %rsp, %rbp
; AVX512F-NEXT:    .cfi_def_cfa_register %rbp
; AVX512F-NEXT:    andq $-32, %rsp
; AVX512F-NEXT:    subq $32, %rsp
; AVX512F-NEXT:    vpcmpgtb %ymm1, %ymm0, %ymm0
; AVX512F-NEXT:    vextracti128 $1, %ymm0, %xmm1
; AVX512F-NEXT:    vpmovsxbd %xmm1, %zmm1
; AVX512F-NEXT:    vpslld $31, %zmm1, %zmm1
; AVX512F-NEXT:    vptestmd %zmm1, %zmm1, %k0
; AVX512F-NEXT:    kmovw %k0, {{[0-9]+}}(%rsp)
; AVX512F-NEXT:    vpmovsxbd %xmm0, %zmm0
; AVX512F-NEXT:    vpslld $31, %zmm0, %zmm0
; AVX512F-NEXT:    vptestmd %zmm0, %zmm0, %k0
; AVX512F-NEXT:    kmovw %k0, (%rsp)
; AVX512F-NEXT:    movl (%rsp), %eax
; AVX512F-NEXT:    movq %rbp, %rsp
; AVX512F-NEXT:    popq %rbp
; AVX512F-NEXT:    vzeroupper
; AVX512F-NEXT:    retq
;
; AVX512BW-LABEL: v32i8:
; AVX512BW:       # BB#0:
; AVX512BW-NEXT:    vpcmpgtb %ymm1, %ymm0, %k0
; AVX512BW-NEXT:    kmovd %k0, %eax
; AVX512BW-NEXT:    vzeroupper
; AVX512BW-NEXT:    retq
  %x = icmp sgt <32 x i8> %a, %b
  %res = bitcast <32 x i1> %x to i32
  ret i32 %res
}

define i4 @v4i64(<4 x i64> %a, <4 x i64> %b) {
; SSE2-SSSE3-LABEL: v4i64:
; SSE2-SSSE3:       # BB#0:
; SSE2-SSSE3-NEXT:    movdqa {{.*#+}} xmm4 = [2147483648,0,2147483648,0]
; SSE2-SSSE3-NEXT:    pxor %xmm4, %xmm3
; SSE2-SSSE3-NEXT:    pxor %xmm4, %xmm1
; SSE2-SSSE3-NEXT:    movdqa %xmm1, %xmm5
; SSE2-SSSE3-NEXT:    pcmpgtd %xmm3, %xmm5
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm6 = xmm5[0,0,2,2]
; SSE2-SSSE3-NEXT:    pcmpeqd %xmm3, %xmm1
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[1,1,3,3]
; SSE2-SSSE3-NEXT:    pand %xmm6, %xmm1
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm3 = xmm5[1,1,3,3]
; SSE2-SSSE3-NEXT:    por %xmm1, %xmm3
; SSE2-SSSE3-NEXT:    pxor %xmm4, %xmm2
; SSE2-SSSE3-NEXT:    pxor %xmm4, %xmm0
; SSE2-SSSE3-NEXT:    movdqa %xmm0, %xmm1
; SSE2-SSSE3-NEXT:    pcmpgtd %xmm2, %xmm1
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm4 = xmm1[0,0,2,2]
; SSE2-SSSE3-NEXT:    pcmpeqd %xmm2, %xmm0
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[1,1,3,3]
; SSE2-SSSE3-NEXT:    pand %xmm4, %xmm0
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[1,1,3,3]
; SSE2-SSSE3-NEXT:    por %xmm0, %xmm1
; SSE2-SSSE3-NEXT:    packssdw %xmm3, %xmm1
; SSE2-SSSE3-NEXT:    movmskps %xmm1, %eax
; SSE2-SSSE3-NEXT:    # kill: %AL<def> %AL<kill> %EAX<kill>
; SSE2-SSSE3-NEXT:    retq
;
; AVX1-LABEL: v4i64:
; AVX1:       # BB#0:
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpcmpgtq %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpcmpgtq %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    vmovmskpd %ymm0, %eax
; AVX1-NEXT:    # kill: %AL<def> %AL<kill> %EAX<kill>
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: v4i64:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpcmpgtq %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vmovmskpd %ymm0, %eax
; AVX2-NEXT:    # kill: %AL<def> %AL<kill> %EAX<kill>
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: v4i64:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    vpcmpgtq %ymm1, %ymm0, %k0
; AVX512F-NEXT:    kmovw %k0, %eax
; AVX512F-NEXT:    movb %al, -{{[0-9]+}}(%rsp)
; AVX512F-NEXT:    movb -{{[0-9]+}}(%rsp), %al
; AVX512F-NEXT:    vzeroupper
; AVX512F-NEXT:    retq
;
; AVX512BW-LABEL: v4i64:
; AVX512BW:       # BB#0:
; AVX512BW-NEXT:    vpcmpgtq %ymm1, %ymm0, %k0
; AVX512BW-NEXT:    kmovd %k0, %eax
; AVX512BW-NEXT:    movb %al, -{{[0-9]+}}(%rsp)
; AVX512BW-NEXT:    movb -{{[0-9]+}}(%rsp), %al
; AVX512BW-NEXT:    vzeroupper
; AVX512BW-NEXT:    retq
  %x = icmp sgt <4 x i64> %a, %b
  %res = bitcast <4 x i1> %x to i4
  ret i4 %res
}

define i4 @v4f64(<4 x double> %a, <4 x double> %b) {
; SSE2-SSSE3-LABEL: v4f64:
; SSE2-SSSE3:       # BB#0:
; SSE2-SSSE3-NEXT:    cmpltpd %xmm1, %xmm3
; SSE2-SSSE3-NEXT:    cmpltpd %xmm0, %xmm2
; SSE2-SSSE3-NEXT:    packssdw %xmm3, %xmm2
; SSE2-SSSE3-NEXT:    movmskps %xmm2, %eax
; SSE2-SSSE3-NEXT:    # kill: %AL<def> %AL<kill> %EAX<kill>
; SSE2-SSSE3-NEXT:    retq
;
; AVX12-LABEL: v4f64:
; AVX12:       # BB#0:
; AVX12-NEXT:    vcmpltpd %ymm0, %ymm1, %ymm0
; AVX12-NEXT:    vmovmskpd %ymm0, %eax
; AVX12-NEXT:    # kill: %AL<def> %AL<kill> %EAX<kill>
; AVX12-NEXT:    vzeroupper
; AVX12-NEXT:    retq
;
; AVX512F-LABEL: v4f64:
; AVX512F:       # BB#0:
; AVX512F-NEXT:    vcmpltpd %ymm0, %ymm1, %k0
; AVX512F-NEXT:    kmovw %k0, %eax
; AVX512F-NEXT:    movb %al, -{{[0-9]+}}(%rsp)
; AVX512F-NEXT:    movb -{{[0-9]+}}(%rsp), %al
; AVX512F-NEXT:    vzeroupper
; AVX512F-NEXT:    retq
;
; AVX512BW-LABEL: v4f64:
; AVX512BW:       # BB#0:
; AVX512BW-NEXT:    vcmpltpd %ymm0, %ymm1, %k0
; AVX512BW-NEXT:    kmovd %k0, %eax
; AVX512BW-NEXT:    movb %al, -{{[0-9]+}}(%rsp)
; AVX512BW-NEXT:    movb -{{[0-9]+}}(%rsp), %al
; AVX512BW-NEXT:    vzeroupper
; AVX512BW-NEXT:    retq
  %x = fcmp ogt <4 x double> %a, %b
  %res = bitcast <4 x i1> %x to i4
  ret i4 %res
}
