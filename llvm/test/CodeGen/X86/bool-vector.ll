; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown-unknown -mattr=-sse2 | FileCheck %s --check-prefix=X32
; RUN: llc < %s -mtriple=i686-unknown-unknown -mattr=+sse2 | FileCheck %s --check-prefix=X32-SSE2
; RUN: llc < %s -mtriple=i686-unknown-unknown -mattr=+avx2 | FileCheck %s --check-prefix=X32-AVX2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=-sse2 | FileCheck %s --check-prefix=X64
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse2 | FileCheck %s --check-prefix=X64-SSE2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx2 | FileCheck %s --check-prefix=X64-AVX2

define i32 @PR15215_bad(<4 x i32> %input) {
; X32-LABEL: PR15215_bad:
; X32:       # %bb.0: # %entry
; X32-NEXT:    movb {{[0-9]+}}(%esp), %al
; X32-NEXT:    movb {{[0-9]+}}(%esp), %cl
; X32-NEXT:    movb {{[0-9]+}}(%esp), %dl
; X32-NEXT:    movb {{[0-9]+}}(%esp), %ah
; X32-NEXT:    addb %ah, %ah
; X32-NEXT:    andb $1, %dl
; X32-NEXT:    orb %ah, %dl
; X32-NEXT:    shlb $2, %dl
; X32-NEXT:    addb %cl, %cl
; X32-NEXT:    andb $1, %al
; X32-NEXT:    orb %cl, %al
; X32-NEXT:    andb $3, %al
; X32-NEXT:    orb %dl, %al
; X32-NEXT:    movzbl %al, %eax
; X32-NEXT:    andl $15, %eax
; X32-NEXT:    retl
;
; X32-SSE2-LABEL: PR15215_bad:
; X32-SSE2:       # %bb.0: # %entry
; X32-SSE2-NEXT:    pslld $31, %xmm0
; X32-SSE2-NEXT:    psrad $31, %xmm0
; X32-SSE2-NEXT:    movmskps %xmm0, %eax
; X32-SSE2-NEXT:    retl
;
; X32-AVX2-LABEL: PR15215_bad:
; X32-AVX2:       # %bb.0: # %entry
; X32-AVX2-NEXT:    vpslld $31, %xmm0, %xmm0
; X32-AVX2-NEXT:    vpsrad $31, %xmm0, %xmm0
; X32-AVX2-NEXT:    vmovmskps %xmm0, %eax
; X32-AVX2-NEXT:    retl
;
; X64-LABEL: PR15215_bad:
; X64:       # %bb.0: # %entry
; X64-NEXT:    addb %cl, %cl
; X64-NEXT:    andb $1, %dl
; X64-NEXT:    orb %cl, %dl
; X64-NEXT:    shlb $2, %dl
; X64-NEXT:    addb %sil, %sil
; X64-NEXT:    andb $1, %dil
; X64-NEXT:    orb %sil, %dil
; X64-NEXT:    andb $3, %dil
; X64-NEXT:    orb %dl, %dil
; X64-NEXT:    movzbl %dil, %eax
; X64-NEXT:    andl $15, %eax
; X64-NEXT:    retq
;
; X64-SSE2-LABEL: PR15215_bad:
; X64-SSE2:       # %bb.0: # %entry
; X64-SSE2-NEXT:    pslld $31, %xmm0
; X64-SSE2-NEXT:    psrad $31, %xmm0
; X64-SSE2-NEXT:    movmskps %xmm0, %eax
; X64-SSE2-NEXT:    retq
;
; X64-AVX2-LABEL: PR15215_bad:
; X64-AVX2:       # %bb.0: # %entry
; X64-AVX2-NEXT:    vpslld $31, %xmm0, %xmm0
; X64-AVX2-NEXT:    vpsrad $31, %xmm0, %xmm0
; X64-AVX2-NEXT:    vmovmskps %xmm0, %eax
; X64-AVX2-NEXT:    retq
entry:
  %0 = trunc <4 x i32> %input to <4 x i1>
  %1 = bitcast <4 x i1> %0 to i4
  %2 = zext i4 %1 to i32
  ret i32 %2
}

define i32 @PR15215_good(<4 x i32> %input) {
; X32-LABEL: PR15215_good:
; X32:       # %bb.0: # %entry
; X32-NEXT:    pushl %esi
; X32-NEXT:    .cfi_def_cfa_offset 8
; X32-NEXT:    .cfi_offset %esi, -8
; X32-NEXT:    movzbl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    andl $1, %eax
; X32-NEXT:    movzbl {{[0-9]+}}(%esp), %ecx
; X32-NEXT:    andl $1, %ecx
; X32-NEXT:    movzbl {{[0-9]+}}(%esp), %edx
; X32-NEXT:    andl $1, %edx
; X32-NEXT:    movzbl {{[0-9]+}}(%esp), %esi
; X32-NEXT:    andl $1, %esi
; X32-NEXT:    leal (%eax,%ecx,2), %eax
; X32-NEXT:    leal (%eax,%edx,4), %eax
; X32-NEXT:    leal (%eax,%esi,8), %eax
; X32-NEXT:    popl %esi
; X32-NEXT:    retl
;
; X32-SSE2-LABEL: PR15215_good:
; X32-SSE2:       # %bb.0: # %entry
; X32-SSE2-NEXT:    pushl %esi
; X32-SSE2-NEXT:    .cfi_def_cfa_offset 8
; X32-SSE2-NEXT:    .cfi_offset %esi, -8
; X32-SSE2-NEXT:    movd %xmm0, %eax
; X32-SSE2-NEXT:    andl $1, %eax
; X32-SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm0[1,1,2,3]
; X32-SSE2-NEXT:    movd %xmm1, %ecx
; X32-SSE2-NEXT:    andl $1, %ecx
; X32-SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm0[2,3,0,1]
; X32-SSE2-NEXT:    movd %xmm1, %edx
; X32-SSE2-NEXT:    andl $1, %edx
; X32-SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[3,1,2,3]
; X32-SSE2-NEXT:    movd %xmm0, %esi
; X32-SSE2-NEXT:    andl $1, %esi
; X32-SSE2-NEXT:    leal (%eax,%ecx,2), %eax
; X32-SSE2-NEXT:    leal (%eax,%edx,4), %eax
; X32-SSE2-NEXT:    leal (%eax,%esi,8), %eax
; X32-SSE2-NEXT:    popl %esi
; X32-SSE2-NEXT:    retl
;
; X32-AVX2-LABEL: PR15215_good:
; X32-AVX2:       # %bb.0: # %entry
; X32-AVX2-NEXT:    pushl %esi
; X32-AVX2-NEXT:    .cfi_def_cfa_offset 8
; X32-AVX2-NEXT:    .cfi_offset %esi, -8
; X32-AVX2-NEXT:    vmovd %xmm0, %eax
; X32-AVX2-NEXT:    andl $1, %eax
; X32-AVX2-NEXT:    vpextrd $1, %xmm0, %ecx
; X32-AVX2-NEXT:    andl $1, %ecx
; X32-AVX2-NEXT:    vpextrd $2, %xmm0, %edx
; X32-AVX2-NEXT:    andl $1, %edx
; X32-AVX2-NEXT:    vpextrd $3, %xmm0, %esi
; X32-AVX2-NEXT:    andl $1, %esi
; X32-AVX2-NEXT:    leal (%eax,%ecx,2), %eax
; X32-AVX2-NEXT:    leal (%eax,%edx,4), %eax
; X32-AVX2-NEXT:    leal (%eax,%esi,8), %eax
; X32-AVX2-NEXT:    popl %esi
; X32-AVX2-NEXT:    retl
;
; X64-LABEL: PR15215_good:
; X64:       # %bb.0: # %entry
; X64-NEXT:    # kill: %ecx<def> %ecx<kill> %rcx<def>
; X64-NEXT:    # kill: %edx<def> %edx<kill> %rdx<def>
; X64-NEXT:    # kill: %esi<def> %esi<kill> %rsi<def>
; X64-NEXT:    # kill: %edi<def> %edi<kill> %rdi<def>
; X64-NEXT:    andl $1, %edi
; X64-NEXT:    andl $1, %esi
; X64-NEXT:    andl $1, %edx
; X64-NEXT:    andl $1, %ecx
; X64-NEXT:    leal (%rdi,%rsi,2), %eax
; X64-NEXT:    leal (%rax,%rdx,4), %eax
; X64-NEXT:    leal (%rax,%rcx,8), %eax
; X64-NEXT:    retq
;
; X64-SSE2-LABEL: PR15215_good:
; X64-SSE2:       # %bb.0: # %entry
; X64-SSE2-NEXT:    movd %xmm0, %eax
; X64-SSE2-NEXT:    andl $1, %eax
; X64-SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm0[1,1,2,3]
; X64-SSE2-NEXT:    movd %xmm1, %ecx
; X64-SSE2-NEXT:    andl $1, %ecx
; X64-SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm0[2,3,0,1]
; X64-SSE2-NEXT:    movd %xmm1, %edx
; X64-SSE2-NEXT:    andl $1, %edx
; X64-SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[3,1,2,3]
; X64-SSE2-NEXT:    movd %xmm0, %esi
; X64-SSE2-NEXT:    andl $1, %esi
; X64-SSE2-NEXT:    leal (%rax,%rcx,2), %eax
; X64-SSE2-NEXT:    leal (%rax,%rdx,4), %eax
; X64-SSE2-NEXT:    leal (%rax,%rsi,8), %eax
; X64-SSE2-NEXT:    retq
;
; X64-AVX2-LABEL: PR15215_good:
; X64-AVX2:       # %bb.0: # %entry
; X64-AVX2-NEXT:    vmovd %xmm0, %eax
; X64-AVX2-NEXT:    andl $1, %eax
; X64-AVX2-NEXT:    vpextrd $1, %xmm0, %ecx
; X64-AVX2-NEXT:    andl $1, %ecx
; X64-AVX2-NEXT:    vpextrd $2, %xmm0, %edx
; X64-AVX2-NEXT:    andl $1, %edx
; X64-AVX2-NEXT:    vpextrd $3, %xmm0, %esi
; X64-AVX2-NEXT:    andl $1, %esi
; X64-AVX2-NEXT:    leal (%rax,%rcx,2), %eax
; X64-AVX2-NEXT:    leal (%rax,%rdx,4), %eax
; X64-AVX2-NEXT:    leal (%rax,%rsi,8), %eax
; X64-AVX2-NEXT:    retq
entry:
  %0 = trunc <4 x i32> %input to <4 x i1>
  %1 = extractelement <4 x i1> %0, i32 0
  %e1 = select i1 %1, i32 1, i32 0
  %2 = extractelement <4 x i1> %0, i32 1
  %e2 = select i1 %2, i32 2, i32 0
  %3 = extractelement <4 x i1> %0, i32 2
  %e3 = select i1 %3, i32 4, i32 0
  %4 = extractelement <4 x i1> %0, i32 3
  %e4 = select i1 %4, i32 8, i32 0
  %5 = or i32 %e1, %e2
  %6 = or i32 %5, %e3
  %7 = or i32 %6, %e4
  ret i32 %7
}
