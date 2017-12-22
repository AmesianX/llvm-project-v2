; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-linux -mattr=-bmi | FileCheck %s --check-prefix=CHECK
; RUN: llc < %s -mtriple=x86_64-linux-gnux32 -mattr=-bmi | FileCheck %s --check-prefix=GNUX32

; LLVM creates virtual registers for values live across blocks
; based on the type of the value. Make sure that the extracts
; here use the GR64_NOREX register class for their result,
; instead of plain GR64.

define i64 @foo(i64 %a, i64 %b, i64 %c, i64 %d, i64 %e, i64 %f, i64 %g, i64 %h) {
; CHECK-LABEL: foo:
; CHECK:       # %bb.0:
; CHECK-NEXT:    pushq %rbp
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    pushq %rbx
; CHECK-NEXT:    .cfi_def_cfa_offset 24
; CHECK-NEXT:    .cfi_offset %rbx, -24
; CHECK-NEXT:    .cfi_offset %rbp, -16
; CHECK-NEXT:    movq %rsi, %rax
; CHECK-NEXT:    movq %rdi, %rbx
; CHECK-NEXT:    movzbl %bh, %esi # NOREX
; CHECK-NEXT:    movzbl %ah, %eax # NOREX
; CHECK-NEXT:    movq %rax, %r10
; CHECK-NEXT:    movzbl %dh, %edx # NOREX
; CHECK-NEXT:    movzbl %ch, %eax # NOREX
; CHECK-NEXT:    movq %rax, %r11
; CHECK-NEXT:    movq %r8, %rax
; CHECK-NEXT:    movzbl %ah, %ecx # NOREX
; CHECK-NEXT:    movq %r9, %rax
; CHECK-NEXT:    movzbl %ah, %ebp # NOREX
; CHECK-NEXT:    movl {{[0-9]+}}(%rsp), %eax
; CHECK-NEXT:    movzbl %ah, %eax # NOREX
; CHECK-NEXT:    movl {{[0-9]+}}(%rsp), %ebx
; CHECK-NEXT:    movzbl %bh, %edi # NOREX
; CHECK-NEXT:    movq %r10, %r8
; CHECK-NEXT:    addq %r8, %rsi
; CHECK-NEXT:    addq %r11, %rdx
; CHECK-NEXT:    addq %rsi, %rdx
; CHECK-NEXT:    addq %rbp, %rcx
; CHECK-NEXT:    addq %rdi, %rax
; CHECK-NEXT:    addq %rcx, %rax
; CHECK-NEXT:    addq %rdx, %rax
; CHECK-NEXT:    popq %rbx
; CHECK-NEXT:    popq %rbp
; CHECK-NEXT:    retq
;
; GNUX32-LABEL: foo:
; GNUX32:       # %bb.0:
; GNUX32-NEXT:    pushq %rbp
; GNUX32-NEXT:    .cfi_def_cfa_offset 16
; GNUX32-NEXT:    pushq %rbx
; GNUX32-NEXT:    .cfi_def_cfa_offset 24
; GNUX32-NEXT:    .cfi_offset %rbx, -24
; GNUX32-NEXT:    .cfi_offset %rbp, -16
; GNUX32-NEXT:    movq %rsi, %rax
; GNUX32-NEXT:    movq %rdi, %rbx
; GNUX32-NEXT:    movzbl %bh, %esi # NOREX
; GNUX32-NEXT:    movzbl %ah, %eax # NOREX
; GNUX32-NEXT:    movq %rax, %r10
; GNUX32-NEXT:    movzbl %dh, %edx # NOREX
; GNUX32-NEXT:    movzbl %ch, %eax # NOREX
; GNUX32-NEXT:    movq %rax, %r11
; GNUX32-NEXT:    movq %r8, %rax
; GNUX32-NEXT:    movzbl %ah, %ecx # NOREX
; GNUX32-NEXT:    movq %r9, %rax
; GNUX32-NEXT:    movzbl %ah, %ebp # NOREX
; GNUX32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; GNUX32-NEXT:    movzbl %ah, %eax # NOREX
; GNUX32-NEXT:    movl {{[0-9]+}}(%esp), %ebx
; GNUX32-NEXT:    movzbl %bh, %edi # NOREX
; GNUX32-NEXT:    movq %r10, %r8
; GNUX32-NEXT:    addq %r8, %rsi
; GNUX32-NEXT:    addq %r11, %rdx
; GNUX32-NEXT:    addq %rsi, %rdx
; GNUX32-NEXT:    addq %rbp, %rcx
; GNUX32-NEXT:    addq %rdi, %rax
; GNUX32-NEXT:    addq %rcx, %rax
; GNUX32-NEXT:    addq %rdx, %rax
; GNUX32-NEXT:    popq %rbx
; GNUX32-NEXT:    popq %rbp
; GNUX32-NEXT:    retq
  %sa = lshr i64 %a, 8
  %A = and i64 %sa, 255
  %sb = lshr i64 %b, 8
  %B = and i64 %sb, 255
  %sc = lshr i64 %c, 8
  %C = and i64 %sc, 255
  %sd = lshr i64 %d, 8
  %D = and i64 %sd, 255
  %se = lshr i64 %e, 8
  %E = and i64 %se, 255
  %sf = lshr i64 %f, 8
  %F = and i64 %sf, 255
  %sg = lshr i64 %g, 8
  %G = and i64 %sg, 255
  %sh = lshr i64 %h, 8
  %H = and i64 %sh, 255
  br label %next

next:
  %u = add i64 %A, %B
  %v = add i64 %C, %D
  %w = add i64 %E, %F
  %x = add i64 %G, %H
  %y = add i64 %u, %v
  %z = add i64 %w, %x
  %t = add i64 %y, %z
  ret i64 %t
}
