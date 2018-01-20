; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i386-unknown-linux-gnu | FileCheck %s --check-prefix=X86
; RUN: llc < %s -mtriple=x86_64-unknown-linux-gnu | FileCheck %s --check-prefix=X64

@a = common global i32 0, align 4
@b = common global i32 0, align 4
@c = common global i32 0, align 4
@e = common global i32 0, align 4
@x = common global i32 0, align 4
@f = common global i32 0, align 4
@h = common global i32 0, align 4
@i = common global i32 0, align 4

; Test -Os to make sure immediates with multiple users don't get pulled in to
; instructions.
define i32 @foo() optsize {
; X86-LABEL: foo:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl $1234, %eax # imm = 0x4D2
; X86-NEXT:    movl %eax, a
; X86-NEXT:    movl %eax, b
; X86-NEXT:    movl $12, %eax
; X86-NEXT:    movl %eax, c
; X86-NEXT:    cmpl %eax, e
; X86-NEXT:    jne .LBB0_2
; X86-NEXT:  # %bb.1: # %if.then
; X86-NEXT:    movl $1, x
; X86-NEXT:  .LBB0_2: # %if.end
; X86-NEXT:    movl $1234, f # imm = 0x4D2
; X86-NEXT:    movl $555, %eax # imm = 0x22B
; X86-NEXT:    movl %eax, h
; X86-NEXT:    addl %eax, i
; X86-NEXT:    xorl %eax, %eax
; X86-NEXT:    retl
;
; X64-LABEL: foo:
; X64:       # %bb.0: # %entry
; X64-NEXT:    movl $1234, %eax # imm = 0x4D2
; X64-NEXT:    movl %eax, {{.*}}(%rip)
; X64-NEXT:    movl %eax, {{.*}}(%rip)
; X64-NEXT:    movl $12, %eax
; X64-NEXT:    movl %eax, {{.*}}(%rip)
; X64-NEXT:    cmpl %eax, {{.*}}(%rip)
; X64-NEXT:    jne .LBB0_2
; X64-NEXT:  # %bb.1: # %if.then
; X64-NEXT:    movl $1, {{.*}}(%rip)
; X64-NEXT:  .LBB0_2: # %if.end
; X64-NEXT:    movl $1234, {{.*}}(%rip) # imm = 0x4D2
; X64-NEXT:    movl $555, %eax # imm = 0x22B
; X64-NEXT:    movl %eax, {{.*}}(%rip)
; X64-NEXT:    addl %eax, {{.*}}(%rip)
; X64-NEXT:    xorl %eax, %eax
; X64-NEXT:    retq
entry:
  store i32 1234, i32* @a
  store i32 1234, i32* @b
  store i32 12, i32* @c
  %0 = load i32, i32* @e
  %cmp = icmp eq i32 %0, 12
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  store i32 1, i32* @x
  br label %if.end

; New block.. Make sure 1234 isn't live across basic blocks from before.
if.end:                                           ; preds = %if.then, %entry
  store i32 1234, i32* @f
  store i32 555, i32* @h
  %1 = load i32, i32* @i
  %add1 = add nsw i32 %1, 555
  store i32 %add1, i32* @i
  ret i32 0
}

; Test -O2 to make sure that all immediates get pulled in to their users.
define i32 @foo2() {
; X86-LABEL: foo2:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl $1234, a # imm = 0x4D2
; X86-NEXT:    movl $1234, b # imm = 0x4D2
; X86-NEXT:    xorl %eax, %eax
; X86-NEXT:    retl
;
; X64-LABEL: foo2:
; X64:       # %bb.0: # %entry
; X64-NEXT:    movl $1234, {{.*}}(%rip) # imm = 0x4D2
; X64-NEXT:    movl $1234, {{.*}}(%rip) # imm = 0x4D2
; X64-NEXT:    xorl %eax, %eax
; X64-NEXT:    retq
entry:
  store i32 1234, i32* @a
  store i32 1234, i32* @b
  ret i32 0
}

declare void @llvm.memset.p0i8.i32(i8* nocapture, i8, i32, i1) #1

@AA = common global [100 x i8] zeroinitializer, align 1

; memset gets lowered in DAG. Constant merging should hoist all the
; immediates used to store to the individual memory locations. Make
; sure we don't directly store the immediates.
define void @foomemset() optsize {
; X86-LABEL: foomemset:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl $555819297, %eax # imm = 0x21212121
; X86-NEXT:    movl %eax, AA+20
; X86-NEXT:    movl %eax, AA+16
; X86-NEXT:    movl %eax, AA+12
; X86-NEXT:    movl %eax, AA+8
; X86-NEXT:    movl %eax, AA+4
; X86-NEXT:    movl %eax, AA
; X86-NEXT:    retl
;
; X64-LABEL: foomemset:
; X64:       # %bb.0: # %entry
; X64-NEXT:    movabsq $2387225703656530209, %rax # imm = 0x2121212121212121
; X64-NEXT:    movq %rax, AA+{{.*}}(%rip)
; X64-NEXT:    movq %rax, AA+{{.*}}(%rip)
; X64-NEXT:    movq %rax, {{.*}}(%rip)
; X64-NEXT:    retq
entry:
  call void @llvm.memset.p0i8.i32(i8* getelementptr inbounds ([100 x i8], [100 x i8]* @AA, i32 0, i32 0), i8 33, i32 24, i1 false)
  ret void
}
