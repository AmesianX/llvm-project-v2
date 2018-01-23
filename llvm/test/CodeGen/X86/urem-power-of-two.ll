; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown-unknown -mattr=+sse2 | FileCheck %s --check-prefix=X86
; RUN: llc < %s -mtriple=x86_64-unknown-unknown | FileCheck %s --check-prefix=X64

; The easy case: a constant power-of-2 divisor.

define i64 @const_pow_2(i64 %x) {
; X86-LABEL: const_pow_2:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    andl $31, %eax
; X86-NEXT:    xorl %edx, %edx
; X86-NEXT:    retl
;
; X64-LABEL: const_pow_2:
; X64:       # %bb.0:
; X64-NEXT:    andl $31, %edi
; X64-NEXT:    movq %rdi, %rax
; X64-NEXT:    retq
  %urem = urem i64 %x, 32
  ret i64 %urem
}

; A left-shifted power-of-2 divisor. Use a weird type for wider coverage.

define i25 @shift_left_pow_2(i25 %x, i25 %y) {
; X86-LABEL: shift_left_pow_2:
; X86:       # %bb.0:
; X86-NEXT:    movb {{[0-9]+}}(%esp), %cl
; X86-NEXT:    movl $1, %eax
; X86-NEXT:    shll %cl, %eax
; X86-NEXT:    addl $33554431, %eax # imm = 0x1FFFFFF
; X86-NEXT:    andl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    retl
;
; X64-LABEL: shift_left_pow_2:
; X64:       # %bb.0:
; X64-NEXT:    movl $1, %eax
; X64-NEXT:    movl %esi, %ecx
; X64-NEXT:    shll %cl, %eax
; X64-NEXT:    addl $33554431, %eax # imm = 0x1FFFFFF
; X64-NEXT:    andl %edi, %eax
; X64-NEXT:    retq
  %shl = shl i25 1, %y
  %urem = urem i25 %x, %shl
  ret i25 %urem
}

; A logically right-shifted sign bit is a power-of-2 or UB.

define i16 @shift_right_pow_2(i16 %x, i16 %y) {
; X86-LABEL: shift_right_pow_2:
; X86:       # %bb.0:
; X86-NEXT:    movb {{[0-9]+}}(%esp), %cl
; X86-NEXT:    movl $32768, %eax # imm = 0x8000
; X86-NEXT:    shrl %cl, %eax
; X86-NEXT:    decl %eax
; X86-NEXT:    andw {{[0-9]+}}(%esp), %ax
; X86-NEXT:    # kill: def %ax killed %ax killed %eax
; X86-NEXT:    retl
;
; X64-LABEL: shift_right_pow_2:
; X64:       # %bb.0:
; X64-NEXT:    movl $32768, %eax # imm = 0x8000
; X64-NEXT:    movl %esi, %ecx
; X64-NEXT:    shrl %cl, %eax
; X64-NEXT:    decl %eax
; X64-NEXT:    andl %edi, %eax
; X64-NEXT:    # kill: def %ax killed %ax killed %eax
; X64-NEXT:    retq
  %shr = lshr i16 -32768, %y
  %urem = urem i16 %x, %shr
  ret i16 %urem
}

; FIXME: A zero divisor would be UB, so this could be reduced to an 'and' with 3.

define i8 @and_pow_2(i8 %x, i8 %y) {
; X86-LABEL: and_pow_2:
; X86:       # %bb.0:
; X86-NEXT:    movb {{[0-9]+}}(%esp), %cl
; X86-NEXT:    andb $4, %cl
; X86-NEXT:    movzbl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    # kill: def %eax killed %eax def %ax
; X86-NEXT:    divb %cl
; X86-NEXT:    movzbl %ah, %eax
; X86-NEXT:    # kill: def %al killed %al killed %eax
; X86-NEXT:    retl
;
; X64-LABEL: and_pow_2:
; X64:       # %bb.0:
; X64-NEXT:    andb $4, %sil
; X64-NEXT:    movzbl %dil, %eax
; X64-NEXT:    # kill: def %eax killed %eax def %ax
; X64-NEXT:    divb %sil
; X64-NEXT:    movzbl %ah, %eax
; X64-NEXT:    # kill: def %al killed %al killed %eax
; X64-NEXT:    retq
  %and = and i8 %y, 4
  %urem = urem i8 %x, %and
  ret i8 %urem
}

; A vector constant divisor should get the same treatment as a scalar.

define <4 x i32> @vec_const_uniform_pow_2(<4 x i32> %x) {
; X86-LABEL: vec_const_uniform_pow_2:
; X86:       # %bb.0:
; X86-NEXT:    andps {{\.LCPI.*}}, %xmm0
; X86-NEXT:    retl
;
; X64-LABEL: vec_const_uniform_pow_2:
; X64:       # %bb.0:
; X64-NEXT:    andps {{.*}}(%rip), %xmm0
; X64-NEXT:    retq
  %urem = urem <4 x i32> %x, <i32 16, i32 16, i32 16, i32 16>
  ret <4 x i32> %urem
}

define <4 x i32> @vec_const_nonuniform_pow_2(<4 x i32> %x) {
; X86-LABEL: vec_const_nonuniform_pow_2:
; X86:       # %bb.0:
; X86-NEXT:    andps {{\.LCPI.*}}, %xmm0
; X86-NEXT:    retl
;
; X64-LABEL: vec_const_nonuniform_pow_2:
; X64:       # %bb.0:
; X64-NEXT:    andps {{.*}}(%rip), %xmm0
; X64-NEXT:    retq
  %urem = urem <4 x i32> %x, <i32 2, i32 4, i32 8, i32 16>
  ret <4 x i32> %urem
}
