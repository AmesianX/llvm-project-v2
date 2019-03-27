; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown | FileCheck %s


; FIXME: masked extend should be folded into and.
define i64 @test1(i8* %data) {
; CHECK-LABEL: test1:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movb (%rdi), %al
; CHECK-NEXT:    shlb $2, %al
; CHECK-NEXT:    movzbl %al, %eax
; CHECK-NEXT:    andl $60, %eax
; CHECK-NEXT:    retq
entry:
  %bf.load = load i8, i8* %data, align 4
  %bf.clear = shl i8 %bf.load, 2
  %0 = and i8 %bf.clear, 60
  %mul = zext i8 %0 to i64
  ret i64 %mul
}

; FIXME: masked extend should be folded into and.
define i8* @test2(i8* %data) {
; CHECK-LABEL: test2:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movb (%rdi), %al
; CHECK-NEXT:    shlb $2, %al
; CHECK-NEXT:    movzbl %al, %eax
; CHECK-NEXT:    andl $60, %eax
; CHECK-NEXT:    addq %rdi, %rax
; CHECK-NEXT:    retq
entry:
  %bf.load = load i8, i8* %data, align 4
  %bf.clear = shl i8 %bf.load, 2
  %0 = and i8 %bf.clear, 60
  %mul = zext i8 %0 to i64
  %add.ptr = getelementptr inbounds i8, i8* %data, i64 %mul
  ret i8* %add.ptr
}

; If the shift op is SHL, the logic op can only be AND.
define i64 @test3(i8* %data) {
; CHECK-LABEL: test3:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movb (%rdi), %al
; CHECK-NEXT:    shlb $2, %al
; CHECK-NEXT:    xorb $60, %al
; CHECK-NEXT:    movzbl %al, %eax
; CHECK-NEXT:    retq
entry:
  %bf.load = load i8, i8* %data, align 4
  %bf.clear = shl i8 %bf.load, 2
  %0 = xor i8 %bf.clear, 60
  %mul = zext i8 %0 to i64
  ret i64 %mul
}

define i64 @test4(i8* %data) {
; CHECK-LABEL: test4:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movzbl (%rdi), %eax
; CHECK-NEXT:    shrq $2, %rax
; CHECK-NEXT:    andl $60, %eax
; CHECK-NEXT:    retq
entry:
  %bf.load = load i8, i8* %data, align 4
  %bf.clear = lshr i8 %bf.load, 2
  %0 = and i8 %bf.clear, 60
  %1 = zext i8 %0 to i64
  ret i64 %1
}

define i64 @test5(i8* %data) {
; CHECK-LABEL: test5:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movzbl (%rdi), %eax
; CHECK-NEXT:    shrq $2, %rax
; CHECK-NEXT:    xorq $60, %rax
; CHECK-NEXT:    retq
entry:
  %bf.load = load i8, i8* %data, align 4
  %bf.clear = lshr i8 %bf.load, 2
  %0 = xor i8 %bf.clear, 60
  %1 = zext i8 %0 to i64
  ret i64 %1
}

define i64 @test6(i8* %data) {
; CHECK-LABEL: test6:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movzbl (%rdi), %eax
; CHECK-NEXT:    shrq $2, %rax
; CHECK-NEXT:    orq $60, %rax
; CHECK-NEXT:    retq
entry:
  %bf.load = load i8, i8* %data, align 4
  %bf.clear = lshr i8 %bf.load, 2
  %0 = or i8 %bf.clear, 60
  %1 = zext i8 %0 to i64
  ret i64 %1
}

; Load is folded with sext.
define i64 @test8(i8* %data) {
; CHECK-LABEL: test8:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movsbl (%rdi), %eax
; CHECK-NEXT:    movzwl %ax, %eax
; CHECK-NEXT:    shrl $2, %eax
; CHECK-NEXT:    orl $60, %eax
; CHECK-NEXT:    retq
entry:
  %bf.load = load i8, i8* %data, align 4
  %ext = sext i8 %bf.load to i16
  %bf.clear = lshr i16 %ext, 2
  %0 = or i16 %bf.clear, 60
  %1 = zext i16 %0 to i64
  ret i64 %1
}

