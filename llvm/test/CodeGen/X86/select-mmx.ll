; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=x86_64-unknown-unknown -mattr=+mmx < %s | FileCheck %s --check-prefix=X64
; RUN: llc -mtriple=i686-unknown-unknown -mattr=+mmx < %s | FileCheck %s --check-prefix=I32


; From source: clang -02
;__m64 test47(int a)
;{
;    __m64 x = (a)? (__m64)(7): (__m64)(0);
; return __builtin_ia32_psllw(x, x);
;}

define i64 @test47(i64 %arg)  {
;
; X64-LABEL: test47:
; X64:       # BB#0:
; X64-NEXT:    xorl %eax, %eax
; X64-NEXT:    testq %rdi, %rdi
; X64-NEXT:    movl $7, %ecx
; X64-NEXT:    cmoveq %rcx, %rax
; X64-NEXT:    movd %rax, %mm0
; X64-NEXT:    psllw %mm0, %mm0
; X64-NEXT:    movd %mm0, %rax
; X64-NEXT:    retq
;
; I32-LABEL: test47:
; I32:       # BB#0:
; I32-NEXT:    pushl %ebp
; I32-NEXT:  .Lcfi0:
; I32-NEXT:    .cfi_def_cfa_offset 8
; I32-NEXT:  .Lcfi1:
; I32-NEXT:    .cfi_offset %ebp, -8
; I32-NEXT:    movl %esp, %ebp
; I32-NEXT:  .Lcfi2:
; I32-NEXT:    .cfi_def_cfa_register %ebp
; I32-NEXT:    andl $-8, %esp
; I32-NEXT:    subl $16, %esp
; I32-NEXT:    movl 8(%ebp), %eax
; I32-NEXT:    orl 12(%ebp), %eax
; I32-NEXT:    movl $7, %eax
; I32-NEXT:    je .LBB0_2
; I32-NEXT:  # BB#1:
; I32-NEXT:    xorl %eax, %eax
; I32-NEXT:  .LBB0_2:
; I32-NEXT:    movl %eax, {{[0-9]+}}(%esp)
; I32-NEXT:    movl $0, {{[0-9]+}}(%esp)
; I32-NEXT:    movq {{[0-9]+}}(%esp), %mm0
; I32-NEXT:    psllw %mm0, %mm0
; I32-NEXT:    movq %mm0, (%esp)
; I32-NEXT:    movl (%esp), %eax
; I32-NEXT:    movl {{[0-9]+}}(%esp), %edx
; I32-NEXT:    movl %ebp, %esp
; I32-NEXT:    popl %ebp
; I32-NEXT:    retl
  %cond = icmp eq i64 %arg, 0
  %slct = select i1 %cond, x86_mmx bitcast (i64 7 to x86_mmx), x86_mmx bitcast (i64 0 to x86_mmx)
  %psll = tail call x86_mmx @llvm.x86.mmx.psll.w(x86_mmx %slct, x86_mmx %slct)
  %retc = bitcast x86_mmx %psll to i64
  ret i64 %retc
}


; From source: clang -O2
;__m64 test49(int a, long long n, long long m)
;{
;    __m64 x = (a)? (__m64)(n): (__m64)(m);
; return __builtin_ia32_psllw(x, x);
;}

define i64 @test49(i64 %arg, i64 %x, i64 %y) {
;
; X64-LABEL: test49:
; X64:       # BB#0:
; X64-NEXT:    testq %rdi, %rdi
; X64-NEXT:    cmovneq %rdx, %rsi
; X64-NEXT:    movd %rsi, %mm0
; X64-NEXT:    psllw %mm0, %mm0
; X64-NEXT:    movd %mm0, %rax
; X64-NEXT:    retq
;
; I32-LABEL: test49:
; I32:       # BB#0:
; I32-NEXT:    pushl %ebp
; I32-NEXT:  .Lcfi3:
; I32-NEXT:    .cfi_def_cfa_offset 8
; I32-NEXT:  .Lcfi4:
; I32-NEXT:    .cfi_offset %ebp, -8
; I32-NEXT:    movl %esp, %ebp
; I32-NEXT:  .Lcfi5:
; I32-NEXT:    .cfi_def_cfa_register %ebp
; I32-NEXT:    andl $-8, %esp
; I32-NEXT:    subl $8, %esp
; I32-NEXT:    movl 8(%ebp), %eax
; I32-NEXT:    orl 12(%ebp), %eax
; I32-NEXT:    je .LBB1_1
; I32-NEXT:  # BB#2:
; I32-NEXT:    leal 24(%ebp), %eax
; I32-NEXT:    jmp .LBB1_3
; I32-NEXT:  .LBB1_1:
; I32-NEXT:    leal 16(%ebp), %eax
; I32-NEXT:  .LBB1_3:
; I32-NEXT:    movq (%eax), %mm0
; I32-NEXT:    psllw %mm0, %mm0
; I32-NEXT:    movq %mm0, (%esp)
; I32-NEXT:    movl (%esp), %eax
; I32-NEXT:    movl {{[0-9]+}}(%esp), %edx
; I32-NEXT:    movl %ebp, %esp
; I32-NEXT:    popl %ebp
; I32-NEXT:    retl
  %cond = icmp eq i64 %arg, 0
  %xmmx = bitcast i64 %x to x86_mmx
  %ymmx = bitcast i64 %y to x86_mmx
  %slct = select i1 %cond, x86_mmx %xmmx, x86_mmx %ymmx
  %psll = tail call x86_mmx @llvm.x86.mmx.psll.w(x86_mmx %slct, x86_mmx %slct)
  %retc = bitcast x86_mmx %psll to i64
  ret i64 %retc
}

declare x86_mmx @llvm.x86.mmx.psll.w(x86_mmx, x86_mmx)

