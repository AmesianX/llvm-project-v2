; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown-unknown | FileCheck %s --check-prefixes=X86
; RUN: llc < %s -mtriple=x86_64-unknown-unknown | FileCheck %s --check-prefixes=X64

%WideUInt32 = type { i32, i32 }

define void @PR25858_i32(%WideUInt32* sret, %WideUInt32*, %WideUInt32*) nounwind {
; X86-LABEL: PR25858_i32:
; X86:       # %bb.0: # %top
; X86-NEXT:    pushl %esi
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    movl (%ecx), %esi
; X86-NEXT:    movl 4(%ecx), %ecx
; X86-NEXT:    subl (%edx), %esi
; X86-NEXT:    sbbl 4(%edx), %ecx
; X86-NEXT:    movl %ecx, 4(%eax)
; X86-NEXT:    movl %esi, (%eax)
; X86-NEXT:    popl %esi
; X86-NEXT:    retl $4
;
; X64-LABEL: PR25858_i32:
; X64:       # %bb.0: # %top
; X64-NEXT:    movq %rdi, %rax
; X64-NEXT:    movl (%rsi), %ecx
; X64-NEXT:    movl 4(%rsi), %esi
; X64-NEXT:    subl (%rdx), %ecx
; X64-NEXT:    sbbl 4(%rdx), %esi
; X64-NEXT:    movl %esi, 4(%rdi)
; X64-NEXT:    movl %ecx, (%rdi)
; X64-NEXT:    retq
top:
  %3 = bitcast %WideUInt32* %1 to i32*
  %4 = load i32, i32* %3, align 4
  %5 = bitcast %WideUInt32* %2 to i32*
  %6 = load i32, i32* %5, align 4
  %7 = sub i32 %4, %6
  %8 = call { i32, i1 } @llvm.usub.with.overflow.i32(i32 %4, i32 %6)
  %9 = extractvalue { i32, i1 } %8, 1
  %10 = getelementptr inbounds %WideUInt32, %WideUInt32* %1, i32 0, i32 1
  %11 = load i32, i32* %10, align 8
  %12 = getelementptr inbounds %WideUInt32, %WideUInt32* %2, i32 0, i32 1
  %13 = load i32, i32* %12, align 8
  %14 = sub i32 %11, %13
  %.neg1 = sext i1 %9 to i32
  %15 = add i32 %14, %.neg1
  %16 = insertvalue %WideUInt32 undef, i32 %7, 0
  %17 = insertvalue %WideUInt32 %16, i32 %15, 1
  store %WideUInt32 %17, %WideUInt32* %0, align 4
  ret void
}

declare  { i32, i1 } @llvm.usub.with.overflow.i32(i32, i32)

%WideUInt64 = type { i64, i64 }

define void @PR25858_i64(%WideUInt64* sret, %WideUInt64*, %WideUInt64*) nounwind {
; X86-LABEL: PR25858_i64:
; X86:       # %bb.0: # %top
; X86-NEXT:    pushl %ebp
; X86-NEXT:    pushl %ebx
; X86-NEXT:    pushl %edi
; X86-NEXT:    pushl %esi
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    movl (%edx), %esi
; X86-NEXT:    movl 4(%edx), %edi
; X86-NEXT:    subl (%ecx), %esi
; X86-NEXT:    sbbl 4(%ecx), %edi
; X86-NEXT:    setb %bl
; X86-NEXT:    movl 12(%edx), %ebp
; X86-NEXT:    movl 8(%edx), %edx
; X86-NEXT:    subl 8(%ecx), %edx
; X86-NEXT:    sbbl 12(%ecx), %ebp
; X86-NEXT:    movzbl %bl, %ecx
; X86-NEXT:    subl %ecx, %edx
; X86-NEXT:    sbbl $0, %ebp
; X86-NEXT:    movl %edi, 4(%eax)
; X86-NEXT:    movl %esi, (%eax)
; X86-NEXT:    movl %edx, 8(%eax)
; X86-NEXT:    movl %ebp, 12(%eax)
; X86-NEXT:    popl %esi
; X86-NEXT:    popl %edi
; X86-NEXT:    popl %ebx
; X86-NEXT:    popl %ebp
; X86-NEXT:    retl $4
;
; X64-LABEL: PR25858_i64:
; X64:       # %bb.0: # %top
; X64-NEXT:    movq %rdi, %rax
; X64-NEXT:    movq (%rsi), %rcx
; X64-NEXT:    movq 8(%rsi), %rsi
; X64-NEXT:    subq (%rdx), %rcx
; X64-NEXT:    sbbq 8(%rdx), %rsi
; X64-NEXT:    movq %rsi, 8(%rdi)
; X64-NEXT:    movq %rcx, (%rdi)
; X64-NEXT:    retq
top:
  %3 = bitcast %WideUInt64* %1 to i64*
  %4 = load i64, i64* %3, align 8
  %5 = bitcast %WideUInt64* %2 to i64*
  %6 = load i64, i64* %5, align 8
  %7 = sub i64 %4, %6
  %8 = call { i64, i1 } @llvm.usub.with.overflow.i64(i64 %4, i64 %6)
  %9 = extractvalue { i64, i1 } %8, 1
  %10 = getelementptr inbounds %WideUInt64, %WideUInt64* %1, i64 0, i32 1
  %11 = load i64, i64* %10, align 8
  %12 = getelementptr inbounds %WideUInt64, %WideUInt64* %2, i64 0, i32 1
  %13 = load i64, i64* %12, align 8
  %14 = sub i64 %11, %13
  %.neg1 = sext i1 %9 to i64
  %15 = add i64 %14, %.neg1
  %16 = insertvalue %WideUInt64 undef, i64 %7, 0
  %17 = insertvalue %WideUInt64 %16, i64 %15, 1
  store %WideUInt64 %17, %WideUInt64* %0, align 8
  ret void
}

declare  { i64, i1 } @llvm.usub.with.overflow.i64(i64, i64)

; PR24545 less_than_ideal()
define i8 @PR24545(i32, i32, i32* nocapture readonly) {
; X86-LABEL: PR24545:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    cmpl (%ecx), %edx
; X86-NEXT:    sbbl 4(%ecx), %eax
; X86-NEXT:    setb %al
; X86-NEXT:    retl
;
; X64-LABEL: PR24545:
; X64:       # %bb.0:
; X64-NEXT:    cmpl (%rdx), %edi
; X64-NEXT:    sbbl 4(%rdx), %esi
; X64-NEXT:    setb %al
; X64-NEXT:    retq
  %4 = load i32, i32* %2
  %5 = icmp ugt i32 %4, %0
  %6 = zext i1 %5 to i8
  %7 = getelementptr inbounds i32, i32* %2, i32 1
  %8 = load i32, i32* %7
  %9 = tail call { i8, i32 } @llvm.x86.subborrow.32(i8 %6, i32 %1, i32 %8)
  %10 = extractvalue { i8, i32 } %9, 0
  %11 = icmp ne i8 %10, 0
  %12 = zext i1 %11 to i8
  ret i8 %12
}

define i32 @PR40483_sub1(i32*, i32) nounwind {
; X86-LABEL: PR40483_sub1:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    subl %eax, (%ecx)
; X86-NEXT:    xorl %eax, %eax
; X86-NEXT:    retl
;
; X64-LABEL: PR40483_sub1:
; X64:       # %bb.0:
; X64-NEXT:    subl %esi, (%rdi)
; X64-NEXT:    xorl %eax, %eax
; X64-NEXT:    retq
  %3 = load i32, i32* %0, align 4
  %4 = tail call { i8, i32 } @llvm.x86.subborrow.32(i8 0, i32 %3, i32 %1)
  %5 = extractvalue { i8, i32 } %4, 1
  store i32 %5, i32* %0, align 4
  %6 = sub i32 %1, %3
  %7 = add i32 %6, %5
  ret i32 %7
}

define i32 @PR40483_sub2(i32*, i32) nounwind {
; X86-LABEL: PR40483_sub2:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    subl %eax, (%ecx)
; X86-NEXT:    xorl %eax, %eax
; X86-NEXT:    retl
;
; X64-LABEL: PR40483_sub2:
; X64:       # %bb.0:
; X64-NEXT:    subl %esi, (%rdi)
; X64-NEXT:    xorl %eax, %eax
; X64-NEXT:    retq
  %3 = load i32, i32* %0, align 4
  %4 = sub i32 %3, %1
  %5 = tail call { i8, i32 } @llvm.x86.subborrow.32(i8 0, i32 %3, i32 %1)
  %6 = extractvalue { i8, i32 } %5, 1
  store i32 %6, i32* %0, align 4
  %7 = sub i32 %4, %6
  ret i32 %7
}

define i32 @PR40483_sub3(i32*, i32) nounwind {
; X86-LABEL: PR40483_sub3:
; X86:       # %bb.0:
; X86-NEXT:    pushl %edi
; X86-NEXT:    pushl %esi
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %esi
; X86-NEXT:    movl (%esi), %edx
; X86-NEXT:    movl %edx, %eax
; X86-NEXT:    subl %ecx, %eax
; X86-NEXT:    movl %edx, %edi
; X86-NEXT:    subl %ecx, %edi
; X86-NEXT:    movl %edi, (%esi)
; X86-NEXT:    jae .LBB5_1
; X86-NEXT:  # %bb.2:
; X86-NEXT:    xorl %eax, %eax
; X86-NEXT:    jmp .LBB5_3
; X86-NEXT:  .LBB5_1:
; X86-NEXT:    subl %edx, %ecx
; X86-NEXT:    orl %ecx, %eax
; X86-NEXT:  .LBB5_3:
; X86-NEXT:    popl %esi
; X86-NEXT:    popl %edi
; X86-NEXT:    retl
;
; X64-LABEL: PR40483_sub3:
; X64:       # %bb.0:
; X64-NEXT:    movl (%rdi), %ecx
; X64-NEXT:    movl %ecx, %eax
; X64-NEXT:    subl %esi, %eax
; X64-NEXT:    movl %esi, %edx
; X64-NEXT:    subl %ecx, %edx
; X64-NEXT:    orl %eax, %edx
; X64-NEXT:    xorl %eax, %eax
; X64-NEXT:    subl %esi, %ecx
; X64-NEXT:    movl %ecx, (%rdi)
; X64-NEXT:    cmovael %edx, %eax
; X64-NEXT:    retq
  %3 = load i32, i32* %0, align 8
  %4 = tail call { i8, i32 } @llvm.x86.subborrow.32(i8 0, i32 %3, i32 %1)
  %5 = extractvalue { i8, i32 } %4, 1
  store i32 %5, i32* %0, align 8
  %6 = extractvalue { i8, i32 } %4, 0
  %7 = icmp eq i8 %6, 0
  %8 = sub i32 %1, %3
  %9 = or i32 %5, %8
  %10 = select i1 %7, i32 %9, i32 0
  ret i32 %10
}

define i32 @PR40483_sub4(i32*, i32) nounwind {
; X86-LABEL: PR40483_sub4:
; X86:       # %bb.0:
; X86-NEXT:    pushl %edi
; X86-NEXT:    pushl %esi
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %esi
; X86-NEXT:    movl (%esi), %edi
; X86-NEXT:    movl %edi, %ecx
; X86-NEXT:    subl %edx, %ecx
; X86-NEXT:    xorl %eax, %eax
; X86-NEXT:    subl %edx, %edi
; X86-NEXT:    movl %edi, (%esi)
; X86-NEXT:    jae .LBB6_2
; X86-NEXT:  # %bb.1:
; X86-NEXT:    orl %ecx, %ecx
; X86-NEXT:    movl %ecx, %eax
; X86-NEXT:  .LBB6_2:
; X86-NEXT:    popl %esi
; X86-NEXT:    popl %edi
; X86-NEXT:    retl
;
; X64-LABEL: PR40483_sub4:
; X64:       # %bb.0:
; X64-NEXT:    movl (%rdi), %ecx
; X64-NEXT:    movl %ecx, %edx
; X64-NEXT:    subl %esi, %edx
; X64-NEXT:    orl %edx, %edx
; X64-NEXT:    xorl %eax, %eax
; X64-NEXT:    subl %esi, %ecx
; X64-NEXT:    movl %ecx, (%rdi)
; X64-NEXT:    cmovbl %edx, %eax
; X64-NEXT:    retq
  %3 = load i32, i32* %0, align 8
  %4 = tail call { i8, i32 } @llvm.x86.subborrow.32(i8 0, i32 %3, i32 %1)
  %5 = extractvalue { i8, i32 } %4, 1
  store i32 %5, i32* %0, align 8
  %6 = extractvalue { i8, i32 } %4, 0
  %7 = icmp eq i8 %6, 0
  %8 = sub i32 %3, %1
  %9 = or i32 %5, %8
  %10 = select i1 %7, i32 0, i32 %9
  ret i32 %10
}

declare { i8, i32 } @llvm.x86.subborrow.32(i8, i32, i32)
