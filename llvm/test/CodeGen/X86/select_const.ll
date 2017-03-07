; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown | FileCheck %s

; Select of constants: control flow / conditional moves can always be replaced by logic+math (but may not be worth it?).
; Test the zeroext/signext variants of each pattern to see if that makes a difference.

; select Cond, 0, 1 --> zext (!Cond)

define i32 @select_0_or_1(i1 %cond) {
; CHECK-LABEL: select_0_or_1:
; CHECK:       # BB#0:
; CHECK-NEXT:    notb %dil
; CHECK-NEXT:    movzbl %dil, %eax
; CHECK-NEXT:    andl $1, %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 0, i32 1
  ret i32 %sel
}

define i32 @select_0_or_1_zeroext(i1 zeroext %cond) {
; CHECK-LABEL: select_0_or_1_zeroext:
; CHECK:       # BB#0:
; CHECK-NEXT:    xorb $1, %dil
; CHECK-NEXT:    movzbl %dil, %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 0, i32 1
  ret i32 %sel
}

define i32 @select_0_or_1_signext(i1 signext %cond) {
; CHECK-LABEL: select_0_or_1_signext:
; CHECK:       # BB#0:
; CHECK-NEXT:    notb %dil
; CHECK-NEXT:    movzbl %dil, %eax
; CHECK-NEXT:    andl $1, %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 0, i32 1
  ret i32 %sel
}

; select Cond, 1, 0 --> zext (Cond)

define i32 @select_1_or_0(i1 %cond) {
; CHECK-LABEL: select_1_or_0:
; CHECK:       # BB#0:
; CHECK-NEXT:    andl $1, %edi
; CHECK-NEXT:    movl %edi, %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 1, i32 0
  ret i32 %sel
}

define i32 @select_1_or_0_zeroext(i1 zeroext %cond) {
; CHECK-LABEL: select_1_or_0_zeroext:
; CHECK:       # BB#0:
; CHECK-NEXT:    movzbl %dil, %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 1, i32 0
  ret i32 %sel
}

define i32 @select_1_or_0_signext(i1 signext %cond) {
; CHECK-LABEL: select_1_or_0_signext:
; CHECK:       # BB#0:
; CHECK-NEXT:    andb $1, %dil
; CHECK-NEXT:    movzbl %dil, %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 1, i32 0
  ret i32 %sel
}

; select Cond, 0, -1 --> sext (!Cond)

define i32 @select_0_or_neg1(i1 %cond) {
; CHECK-LABEL: select_0_or_neg1:
; CHECK:       # BB#0:
; CHECK-NEXT:    # kill: %EDI<def> %EDI<kill> %RDI<def>
; CHECK-NEXT:    andl $1, %edi
; CHECK-NEXT:    leal -1(%rdi), %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 0, i32 -1
  ret i32 %sel
}

define i32 @select_0_or_neg1_zeroext(i1 zeroext %cond) {
; CHECK-LABEL: select_0_or_neg1_zeroext:
; CHECK:       # BB#0:
; CHECK-NEXT:    movzbl %dil, %eax
; CHECK-NEXT:    decl %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 0, i32 -1
  ret i32 %sel
}

define i32 @select_0_or_neg1_signext(i1 signext %cond) {
; CHECK-LABEL: select_0_or_neg1_signext:
; CHECK:       # BB#0:
; CHECK-NEXT:    andb $1, %dil
; CHECK-NEXT:    movzbl %dil, %eax
; CHECK-NEXT:    decl %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 0, i32 -1
  ret i32 %sel
}

; select Cond, -1, 0 --> sext (Cond)

define i32 @select_neg1_or_0(i1 %cond) {
; CHECK-LABEL: select_neg1_or_0:
; CHECK:       # BB#0:
; CHECK-NEXT:    andl $1, %edi
; CHECK-NEXT:    negl %edi
; CHECK-NEXT:    movl %edi, %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 -1, i32 0
  ret i32 %sel
}

define i32 @select_neg1_or_0_zeroext(i1 zeroext %cond) {
; CHECK-LABEL: select_neg1_or_0_zeroext:
; CHECK:       # BB#0:
; CHECK-NEXT:    movzbl %dil, %eax
; CHECK-NEXT:    negl %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 -1, i32 0
  ret i32 %sel
}

define i32 @select_neg1_or_0_signext(i1 signext %cond) {
; CHECK-LABEL: select_neg1_or_0_signext:
; CHECK:       # BB#0:
; CHECK-NEXT:    movsbl %dil, %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 -1, i32 0
  ret i32 %sel
}

; select Cond, C+1, C --> add (zext Cond), C

define i32 @select_Cplus1_C(i1 %cond) {
; CHECK-LABEL: select_Cplus1_C:
; CHECK:       # BB#0:
; CHECK-NEXT:    # kill: %EDI<def> %EDI<kill> %RDI<def>
; CHECK-NEXT:    andl $1, %edi
; CHECK-NEXT:    leal 41(%rdi), %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 42, i32 41
  ret i32 %sel
}

define i32 @select_Cplus1_C_zeroext(i1 zeroext %cond) {
; CHECK-LABEL: select_Cplus1_C_zeroext:
; CHECK:       # BB#0:
; CHECK-NEXT:    movzbl %dil, %eax
; CHECK-NEXT:    addl $41, %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 42, i32 41
  ret i32 %sel
}

define i32 @select_Cplus1_C_signext(i1 signext %cond) {
; CHECK-LABEL: select_Cplus1_C_signext:
; CHECK:       # BB#0:
; CHECK-NEXT:    andb $1, %dil
; CHECK-NEXT:    movzbl %dil, %eax
; CHECK-NEXT:    addl $41, %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 42, i32 41
  ret i32 %sel
}

; select Cond, C, C+1 --> add (sext Cond), C

define i32 @select_C_Cplus1(i1 %cond) {
; CHECK-LABEL: select_C_Cplus1:
; CHECK:       # BB#0:
; CHECK-NEXT:    andl $1, %edi
; CHECK-NEXT:    movl $42, %eax
; CHECK-NEXT:    subl %edi, %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 41, i32 42
  ret i32 %sel
}

define i32 @select_C_Cplus1_zeroext(i1 zeroext %cond) {
; CHECK-LABEL: select_C_Cplus1_zeroext:
; CHECK:       # BB#0:
; CHECK-NEXT:    movzbl %dil, %ecx
; CHECK-NEXT:    movl $42, %eax
; CHECK-NEXT:    subl %ecx, %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 41, i32 42
  ret i32 %sel
}

define i32 @select_C_Cplus1_signext(i1 signext %cond) {
; CHECK-LABEL: select_C_Cplus1_signext:
; CHECK:       # BB#0:
; CHECK-NEXT:    andb $1, %dil
; CHECK-NEXT:    movzbl %dil, %ecx
; CHECK-NEXT:    movl $42, %eax
; CHECK-NEXT:    subl %ecx, %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 41, i32 42
  ret i32 %sel
}

; In general, select of 2 constants could be:
; select Cond, C1, C2 --> add (mul (zext Cond), C1-C2), C2 --> add (and (sext Cond), C1-C2), C2

define i32 @select_C1_C2(i1 %cond) {
; CHECK-LABEL: select_C1_C2:
; CHECK:       # BB#0:
; CHECK-NEXT:    testb $1, %dil
; CHECK-NEXT:    movl $421, %ecx # imm = 0x1A5
; CHECK-NEXT:    movl $42, %eax
; CHECK-NEXT:    cmovnel %ecx, %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 421, i32 42
  ret i32 %sel
}

define i32 @select_C1_C2_zeroext(i1 zeroext %cond) {
; CHECK-LABEL: select_C1_C2_zeroext:
; CHECK:       # BB#0:
; CHECK-NEXT:    testb %dil, %dil
; CHECK-NEXT:    movl $421, %ecx # imm = 0x1A5
; CHECK-NEXT:    movl $42, %eax
; CHECK-NEXT:    cmovnel %ecx, %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 421, i32 42
  ret i32 %sel
}

define i32 @select_C1_C2_signext(i1 signext %cond) {
; CHECK-LABEL: select_C1_C2_signext:
; CHECK:       # BB#0:
; CHECK-NEXT:    testb $1, %dil
; CHECK-NEXT:    movl $421, %ecx # imm = 0x1A5
; CHECK-NEXT:    movl $42, %eax
; CHECK-NEXT:    cmovnel %ecx, %eax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i32 421, i32 42
  ret i32 %sel
}

; select (x == 2), 2, (x + 1) --> select (x == 2), x, (x + 1)

define i64 @select_2_or_inc(i64 %x) {
; CHECK-LABEL: select_2_or_inc:
; CHECK:       # BB#0:
; CHECK-NEXT:    leaq 1(%rdi), %rax
; CHECK-NEXT:    cmpq $2, %rdi
; CHECK-NEXT:    cmoveq %rdi, %rax
; CHECK-NEXT:    retq
  %cmp = icmp eq i64 %x, 2
  %add = add i64 %x, 1
  %retval.0 = select i1 %cmp, i64 2, i64 %add
  ret i64 %retval.0
}

define <4 x i32> @sel_constants_add_constant_vec(i1 %cond) {
; CHECK-LABEL: sel_constants_add_constant_vec:
; CHECK:       # BB#0:
; CHECK-NEXT:    testb $1, %dil
; CHECK-NEXT:    jne .LBB22_1
; CHECK-NEXT:  # BB#2:
; CHECK-NEXT:    movaps {{.*#+}} xmm0 = [12,13,14,15]
; CHECK-NEXT:    retq
; CHECK-NEXT:  .LBB22_1:
; CHECK-NEXT:    movaps {{.*#+}} xmm0 = [4294967293,14,4,4]
; CHECK-NEXT:    retq
  %sel = select i1 %cond, <4 x i32> <i32 -4, i32 12, i32 1, i32 0>, <4 x i32> <i32 11, i32 11, i32 11, i32 11>
  %bo = add <4 x i32> %sel, <i32 1, i32 2, i32 3, i32 4>
  ret <4 x i32> %bo
}

define <2 x double> @sel_constants_fmul_constant_vec(i1 %cond) {
; CHECK-LABEL: sel_constants_fmul_constant_vec:
; CHECK:       # BB#0:
; CHECK-NEXT:    testb $1, %dil
; CHECK-NEXT:    jne .LBB23_1
; CHECK-NEXT:  # BB#2:
; CHECK-NEXT:    movaps {{.*#+}} xmm0 = [1.188300e+02,3.454000e+01]
; CHECK-NEXT:    retq
; CHECK-NEXT:  .LBB23_1:
; CHECK-NEXT:    movaps {{.*#+}} xmm0 = [-2.040000e+01,3.768000e+01]
; CHECK-NEXT:    retq
  %sel = select i1 %cond, <2 x double> <double -4.0, double 12.0>, <2 x double> <double 23.3, double 11.0>
  %bo = fmul <2 x double> %sel, <double 5.1, double 3.14>
  ret <2 x double> %bo
}

; 4294967297 = 0x100000001.
; This becomes an opaque constant via ConstantHoisting, so we don't fold it into the select.

define i64 @opaque_constant(i1 %cond, i64 %x) {
; CHECK-LABEL: opaque_constant:
; CHECK:       # BB#0:
; CHECK-NEXT:    testb $1, %dil
; CHECK-NEXT:    movl $23, %ecx
; CHECK-NEXT:    movq $-4, %rax
; CHECK-NEXT:    cmoveq %rcx, %rax
; CHECK-NEXT:    movabsq $4294967297, %rcx # imm = 0x100000001
; CHECK-NEXT:    andq %rcx, %rax
; CHECK-NEXT:    xorl %edx, %edx
; CHECK-NEXT:    cmpq %rcx, %rsi
; CHECK-NEXT:    sete %dl
; CHECK-NEXT:    subq %rdx, %rax
; CHECK-NEXT:    retq
  %sel = select i1 %cond, i64 -4, i64 23
  %bo = and i64 %sel, 4294967297
  %cmp = icmp eq i64 %x, 4294967297
  %sext = sext i1 %cmp to i64
  %add = add i64 %bo, %sext
  ret i64 %add
}

