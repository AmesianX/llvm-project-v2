; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown-unknown | FileCheck %s

define i64 @test1(i32 %xx, i32 %test) nounwind {
; CHECK-LABEL: test1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %edx
; CHECK-NEXT:    movb {{[0-9]+}}(%esp), %cl
; CHECK-NEXT:    andb $7, %cl
; CHECK-NEXT:    movl %edx, %eax
; CHECK-NEXT:    shll %cl, %eax
; CHECK-NEXT:    shrl %edx
; CHECK-NEXT:    xorb $31, %cl
; CHECK-NEXT:    shrl %cl, %edx
; CHECK-NEXT:    retl
  %conv = zext i32 %xx to i64
  %and = and i32 %test, 7
  %sh_prom = zext i32 %and to i64
  %shl = shl i64 %conv, %sh_prom
  ret i64 %shl
}

define i64 @test2(i64 %xx, i32 %test) nounwind {
; CHECK-LABEL: test2:
; CHECK:       # %bb.0:
; CHECK-NEXT:    pushl %esi
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %esi
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %edx
; CHECK-NEXT:    movb {{[0-9]+}}(%esp), %cl
; CHECK-NEXT:    andb $7, %cl
; CHECK-NEXT:    movl %esi, %eax
; CHECK-NEXT:    shll %cl, %eax
; CHECK-NEXT:    shldl %cl, %esi, %edx
; CHECK-NEXT:    popl %esi
; CHECK-NEXT:    retl
  %and = and i32 %test, 7
  %sh_prom = zext i32 %and to i64
  %shl = shl i64 %xx, %sh_prom
  ret i64 %shl
}

define i64 @test3(i64 %xx, i32 %test) nounwind {
; CHECK-LABEL: test3:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %edx
; CHECK-NEXT:    movb {{[0-9]+}}(%esp), %cl
; CHECK-NEXT:    andb $7, %cl
; CHECK-NEXT:    shrdl %cl, %edx, %eax
; CHECK-NEXT:    shrl %cl, %edx
; CHECK-NEXT:    retl
  %and = and i32 %test, 7
  %sh_prom = zext i32 %and to i64
  %shr = lshr i64 %xx, %sh_prom
  ret i64 %shr
}

define i64 @test4(i64 %xx, i32 %test) nounwind {
; CHECK-LABEL: test4:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %edx
; CHECK-NEXT:    movb {{[0-9]+}}(%esp), %cl
; CHECK-NEXT:    andb $7, %cl
; CHECK-NEXT:    shrdl %cl, %edx, %eax
; CHECK-NEXT:    sarl %cl, %edx
; CHECK-NEXT:    retl
  %and = and i32 %test, 7
  %sh_prom = zext i32 %and to i64
  %shr = ashr i64 %xx, %sh_prom
  ret i64 %shr
}

; PR14668
define <2 x i64> @test5(<2 x i64> %A, <2 x i64> %B) {
; CHECK-LABEL: test5:
; CHECK:       # %bb.0:
; CHECK-NEXT:    pushl %ebp
; CHECK-NEXT:    .cfi_def_cfa_offset 8
; CHECK-NEXT:    pushl %ebx
; CHECK-NEXT:    .cfi_def_cfa_offset 12
; CHECK-NEXT:    pushl %edi
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    pushl %esi
; CHECK-NEXT:    .cfi_def_cfa_offset 20
; CHECK-NEXT:    .cfi_offset %esi, -20
; CHECK-NEXT:    .cfi_offset %edi, -16
; CHECK-NEXT:    .cfi_offset %ebx, -12
; CHECK-NEXT:    .cfi_offset %ebp, -8
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    movb {{[0-9]+}}(%esp), %cl
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %ebx
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %esi
; CHECK-NEXT:    movl %ebx, %edi
; CHECK-NEXT:    shll %cl, %edi
; CHECK-NEXT:    shldl %cl, %ebx, %esi
; CHECK-NEXT:    testb $32, %cl
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %ebp
; CHECK-NEXT:    je .LBB4_2
; CHECK-NEXT:  # %bb.1:
; CHECK-NEXT:    movl %edi, %esi
; CHECK-NEXT:    xorl %edi, %edi
; CHECK-NEXT:  .LBB4_2:
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %edx
; CHECK-NEXT:    movl %edx, %ebx
; CHECK-NEXT:    movb {{[0-9]+}}(%esp), %cl
; CHECK-NEXT:    shll %cl, %ebx
; CHECK-NEXT:    shldl %cl, %edx, %ebp
; CHECK-NEXT:    testb $32, %cl
; CHECK-NEXT:    je .LBB4_4
; CHECK-NEXT:  # %bb.3:
; CHECK-NEXT:    movl %ebx, %ebp
; CHECK-NEXT:    xorl %ebx, %ebx
; CHECK-NEXT:  .LBB4_4:
; CHECK-NEXT:    movl %ebp, 12(%eax)
; CHECK-NEXT:    movl %ebx, 8(%eax)
; CHECK-NEXT:    movl %esi, 4(%eax)
; CHECK-NEXT:    movl %edi, (%eax)
; CHECK-NEXT:    popl %esi
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    popl %edi
; CHECK-NEXT:    .cfi_def_cfa_offset 12
; CHECK-NEXT:    popl %ebx
; CHECK-NEXT:    .cfi_def_cfa_offset 8
; CHECK-NEXT:    popl %ebp
; CHECK-NEXT:    .cfi_def_cfa_offset 4
; CHECK-NEXT:    retl $4
  %shl = shl <2 x i64> %A, %B
  ret <2 x i64> %shl
}

; PR16108
define i32 @test6() {
; CHECK-LABEL: test6:
; CHECK:       # %bb.0:
; CHECK-NEXT:    pushl %ebp
; CHECK-NEXT:    .cfi_def_cfa_offset 8
; CHECK-NEXT:    .cfi_offset %ebp, -8
; CHECK-NEXT:    movl %esp, %ebp
; CHECK-NEXT:    .cfi_def_cfa_register %ebp
; CHECK-NEXT:    andl $-8, %esp
; CHECK-NEXT:    subl $16, %esp
; CHECK-NEXT:    movl $1, {{[0-9]+}}(%esp)
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    xorl %eax, %eax
; CHECK-NEXT:    orl $0, %eax
; CHECK-NEXT:    je .LBB5_3
; CHECK-NEXT:  # %bb.1: # %if.then
; CHECK-NEXT:    movl $1, %eax
; CHECK-NEXT:    jmp .LBB5_2
; CHECK-NEXT:  .LBB5_3: # %if.end
; CHECK-NEXT:    xorl %eax, %eax
; CHECK-NEXT:  .LBB5_2: # %if.then
; CHECK-NEXT:    movl %ebp, %esp
; CHECK-NEXT:    popl %ebp
; CHECK-NEXT:    .cfi_def_cfa %esp, 4
; CHECK-NEXT:    retl
  %x = alloca i32, align 4
  %t = alloca i64, align 8
  store volatile i32 1, i32* %x, align 4
  %load = load volatile i32, i32* %x, align 4
  %shl = shl i32 %load, 8
  %add = add i32 %shl, -224
  %sh_prom = zext i32 %add to i64
  %shl1 = shl i64 1, %sh_prom
  %cmp = icmp ne i64 %shl1, 4294967296
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  ret i32 1

if.end:                                           ; preds = %entry
  ret i32 0

}
