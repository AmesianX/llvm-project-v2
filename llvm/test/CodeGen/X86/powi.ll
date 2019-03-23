; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown-unknown | FileCheck %s --check-prefixes=CHECK,X86,X86-X87
; RUN: llc < %s -mtriple=i686-unknown-unknown -mattr=+sse2 | FileCheck %s --check-prefixes=CHECK,X86,X86-SSE
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse2 | FileCheck %s --check-prefixes=CHECK,X64

; Ideally this would compile to 5 multiplies.

define double @pow_wrapper(double %a) nounwind readonly ssp noredzone {
; X86-X87-LABEL: pow_wrapper:
; X86-X87:       # %bb.0:
; X86-X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X86-X87-NEXT:    fld %st(0)
; X86-X87-NEXT:    fmul %st(1), %st
; X86-X87-NEXT:    fmul %st, %st(1)
; X86-X87-NEXT:    fmul %st, %st(0)
; X86-X87-NEXT:    fmul %st, %st(1)
; X86-X87-NEXT:    fmul %st, %st(0)
; X86-X87-NEXT:    fmulp %st, %st(1)
; X86-X87-NEXT:    retl
;
; X86-SSE-LABEL: pow_wrapper:
; X86-SSE:       # %bb.0:
; X86-SSE-NEXT:    pushl %ebp
; X86-SSE-NEXT:    movl %esp, %ebp
; X86-SSE-NEXT:    andl $-8, %esp
; X86-SSE-NEXT:    subl $8, %esp
; X86-SSE-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; X86-SSE-NEXT:    movapd %xmm0, %xmm1
; X86-SSE-NEXT:    mulsd %xmm0, %xmm1
; X86-SSE-NEXT:    mulsd %xmm1, %xmm0
; X86-SSE-NEXT:    mulsd %xmm1, %xmm1
; X86-SSE-NEXT:    mulsd %xmm1, %xmm0
; X86-SSE-NEXT:    mulsd %xmm1, %xmm1
; X86-SSE-NEXT:    mulsd %xmm0, %xmm1
; X86-SSE-NEXT:    movsd %xmm1, (%esp)
; X86-SSE-NEXT:    fldl (%esp)
; X86-SSE-NEXT:    movl %ebp, %esp
; X86-SSE-NEXT:    popl %ebp
; X86-SSE-NEXT:    retl
;
; X64-LABEL: pow_wrapper:
; X64:       # %bb.0:
; X64-NEXT:    movapd %xmm0, %xmm1
; X64-NEXT:    mulsd %xmm0, %xmm1
; X64-NEXT:    mulsd %xmm1, %xmm0
; X64-NEXT:    mulsd %xmm1, %xmm1
; X64-NEXT:    mulsd %xmm1, %xmm0
; X64-NEXT:    mulsd %xmm1, %xmm1
; X64-NEXT:    mulsd %xmm0, %xmm1
; X64-NEXT:    movapd %xmm1, %xmm0
; X64-NEXT:    retq
  %ret = tail call double @llvm.powi.f64(double %a, i32 15) nounwind ; <double> [#uses=1]
  ret double %ret
}

define double @pow_wrapper_optsize(double %a) optsize {
; X86-X87-LABEL: pow_wrapper_optsize:
; X86-X87:       # %bb.0:
; X86-X87-NEXT:    subl $12, %esp
; X86-X87-NEXT:    .cfi_def_cfa_offset 16
; X86-X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X86-X87-NEXT:    fstpl (%esp)
; X86-X87-NEXT:    movl $15, {{[0-9]+}}(%esp)
; X86-X87-NEXT:    calll __powidf2
; X86-X87-NEXT:    addl $12, %esp
; X86-X87-NEXT:    .cfi_def_cfa_offset 4
; X86-X87-NEXT:    retl
;
; X86-SSE-LABEL: pow_wrapper_optsize:
; X86-SSE:       # %bb.0:
; X86-SSE-NEXT:    subl $12, %esp
; X86-SSE-NEXT:    .cfi_def_cfa_offset 16
; X86-SSE-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; X86-SSE-NEXT:    movsd %xmm0, (%esp)
; X86-SSE-NEXT:    movl $15, {{[0-9]+}}(%esp)
; X86-SSE-NEXT:    calll __powidf2
; X86-SSE-NEXT:    addl $12, %esp
; X86-SSE-NEXT:    .cfi_def_cfa_offset 4
; X86-SSE-NEXT:    retl
;
; X64-LABEL: pow_wrapper_optsize:
; X64:       # %bb.0:
; X64-NEXT:    movl $15, %edi
; X64-NEXT:    jmp __powidf2 # TAILCALL
  %ret = tail call double @llvm.powi.f64(double %a, i32 15) nounwind ; <double> [#uses=1]
  ret double %ret
}

define double @pow_wrapper_minsize(double %a) minsize {
; X86-X87-LABEL: pow_wrapper_minsize:
; X86-X87:       # %bb.0:
; X86-X87-NEXT:    subl $12, %esp
; X86-X87-NEXT:    .cfi_def_cfa_offset 16
; X86-X87-NEXT:    fldl {{[0-9]+}}(%esp)
; X86-X87-NEXT:    fstpl (%esp)
; X86-X87-NEXT:    movl $15, {{[0-9]+}}(%esp)
; X86-X87-NEXT:    calll __powidf2
; X86-X87-NEXT:    addl $12, %esp
; X86-X87-NEXT:    .cfi_def_cfa_offset 4
; X86-X87-NEXT:    retl
;
; X86-SSE-LABEL: pow_wrapper_minsize:
; X86-SSE:       # %bb.0:
; X86-SSE-NEXT:    subl $12, %esp
; X86-SSE-NEXT:    .cfi_def_cfa_offset 16
; X86-SSE-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; X86-SSE-NEXT:    movsd %xmm0, (%esp)
; X86-SSE-NEXT:    movl $15, {{[0-9]+}}(%esp)
; X86-SSE-NEXT:    calll __powidf2
; X86-SSE-NEXT:    addl $12, %esp
; X86-SSE-NEXT:    .cfi_def_cfa_offset 4
; X86-SSE-NEXT:    retl
;
; X64-LABEL: pow_wrapper_minsize:
; X64:       # %bb.0:
; X64-NEXT:    pushq $15
; X64-NEXT:    .cfi_adjust_cfa_offset 8
; X64-NEXT:    popq %rdi
; X64-NEXT:    .cfi_adjust_cfa_offset -8
; X64-NEXT:    jmp __powidf2 # TAILCALL
  %ret = tail call double @llvm.powi.f64(double %a, i32 15) nounwind ; <double> [#uses=1]
  ret double %ret
}

declare double @llvm.powi.f64(double, i32) nounwind readonly

