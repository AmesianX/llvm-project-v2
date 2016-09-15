; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: llc < %s -mtriple=x86_64-apple-darwin10 -mcpu=generic | FileCheck %s --check-prefix=CHECK --check-prefix=GENERIC
; RUN: llc < %s -mtriple=x86_64-apple-darwin10 -mcpu=atom    | FileCheck %s --check-prefix=CHECK --check-prefix=ATOM

; PR5757
%0 = type { i64, i32 }

define i32 @test1(%0* %p, %0* %q, i1 %r) nounwind {
; CHECK-LABEL: test1:
; CHECK:       ## BB#0:
; CHECK-NEXT:    addq $8, %rdi
; CHECK-NEXT:    addq $8, %rsi
; CHECK-NEXT:    testb $1, %dl
; CHECK-NEXT:    cmovneq %rdi, %rsi
; CHECK-NEXT:    movl (%rsi), %eax
; CHECK-NEXT:    retq
;
  %t0 = load %0, %0* %p
  %t1 = load %0, %0* %q
  %t4 = select i1 %r, %0 %t0, %0 %t1
  %t5 = extractvalue %0 %t4, 1
  ret i32 %t5
}

; PR2139
define i32 @test2() nounwind {
; CHECK-LABEL: test2:
; CHECK:       ## BB#0: ## %entry
; CHECK-NEXT:    pushq %rax
; CHECK-NEXT:    callq _return_false
; CHECK-NEXT:    xorl %ecx, %ecx
; CHECK-NEXT:    testb $1, %al
; CHECK-NEXT:    movw $-480, %ax ## imm = 0xFE20
; CHECK-NEXT:    cmovnew %cx, %ax
; CHECK-NEXT:    cwtl
; CHECK-NEXT:    shll $3, %eax
; CHECK-NEXT:    cmpl $32768, %eax ## imm = 0x8000
; CHECK-NEXT:    jge LBB1_1
; CHECK-NEXT:  ## BB#2: ## %bb91
; CHECK-NEXT:    xorl %eax, %eax
; CHECK-NEXT:    popq %rcx
; CHECK-NEXT:    retq
; CHECK-NEXT:  LBB1_1: ## %bb90
;
entry:
  %tmp73 = tail call i1 @return_false()
  %g.0 = select i1 %tmp73, i16 0, i16 -480
  %tmp7778 = sext i16 %g.0 to i32
  %tmp80 = shl i32 %tmp7778, 3
  %tmp87 = icmp sgt i32 %tmp80, 32767
  br i1 %tmp87, label %bb90, label %bb91
bb90:
  unreachable
bb91:
  ret i32 0
}

declare i1 @return_false()

;; Select between two floating point constants.
define float @test3(i32 %x) nounwind readnone {
; CHECK-LABEL: test3:
; CHECK:       ## BB#0: ## %entry
; CHECK-NEXT:    xorl %eax, %eax
; CHECK-NEXT:    testl %edi, %edi
; CHECK-NEXT:    sete %al
; CHECK-NEXT:    leaq {{.*}}(%rip), %rcx
; CHECK-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-NEXT:    retq
;
entry:
  %0 = icmp eq i32 %x, 0
  %iftmp.0.0 = select i1 %0, float 4.200000e+01, float 2.300000e+01
  ret float %iftmp.0.0
}

define signext i8 @test4(i8* nocapture %P, double %F) nounwind readonly {
; CHECK-LABEL: test4:
; CHECK:       ## BB#0: ## %entry
; CHECK-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; CHECK-NEXT:    xorl %eax, %eax
; CHECK-NEXT:    ucomisd %xmm0, %xmm1
; CHECK-NEXT:    seta %al
; CHECK-NEXT:    movsbl (%rdi,%rax,4), %eax
; CHECK-NEXT:    retq
;
entry:
  %0 = fcmp olt double %F, 4.200000e+01
  %iftmp.0.0 = select i1 %0, i32 4, i32 0
  %1 = getelementptr i8, i8* %P, i32 %iftmp.0.0
  %2 = load i8, i8* %1, align 1
  ret i8 %2
}

define void @test5(i1 %c, <2 x i16> %a, <2 x i16> %b, <2 x i16>* %p) nounwind {
; CHECK-LABEL: test5:
; CHECK:       ## BB#0:
; CHECK-NEXT:    testb $1, %dil
; CHECK-NEXT:    jne LBB4_2
; CHECK-NEXT:  ## BB#1:
; CHECK-NEXT:    movdqa %xmm1, %xmm0
; CHECK-NEXT:  LBB4_2:
; CHECK-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,2,2,3]
; CHECK-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[0,2,2,3,4,5,6,7]
; CHECK-NEXT:    movd %xmm0, (%rsi)
; CHECK-NEXT:    retq
;
  %x = select i1 %c, <2 x i16> %a, <2 x i16> %b
  store <2 x i16> %x, <2 x i16>* %p
  ret void
}

; Verify that the fmul gets sunk into the one part of the diamond where it is needed.
define void @test6(i32 %C, <4 x float>* %A, <4 x float>* %B) nounwind {
; CHECK-LABEL: test6:
; CHECK:       ## BB#0:
; CHECK-NEXT:    testl %edi, %edi
; CHECK-NEXT:    je LBB5_1
; CHECK-NEXT:  ## BB#2:
; CHECK-NEXT:    movaps (%rsi), %xmm0
; CHECK-NEXT:    movaps %xmm0, (%rsi)
; CHECK-NEXT:    retq
; CHECK-NEXT:  LBB5_1:
; CHECK-NEXT:    movaps (%rdx), %xmm0
; CHECK-NEXT:    mulps %xmm0, %xmm0
; CHECK-NEXT:    movaps %xmm0, (%rsi)
; CHECK-NEXT:    retq
;
  %tmp = load <4 x float>, <4 x float>* %A
  %tmp3 = load <4 x float>, <4 x float>* %B
  %tmp9 = fmul <4 x float> %tmp3, %tmp3
  %tmp.upgrd.1 = icmp eq i32 %C, 0
  %iftmp.38.0 = select i1 %tmp.upgrd.1, <4 x float> %tmp9, <4 x float> %tmp
  store <4 x float> %iftmp.38.0, <4 x float>* %A
  ret void
}

; Select with fp80's
define x86_fp80 @test7(i32 %tmp8) nounwind {
; CHECK-LABEL: test7:
; CHECK:       ## BB#0:
; CHECK-NEXT:    xorl %eax, %eax
; CHECK-NEXT:    testl %edi, %edi
; CHECK-NEXT:    setns %al
; CHECK-NEXT:    shlq $4, %rax
; CHECK-NEXT:    leaq {{.*}}(%rip), %rcx
; CHECK-NEXT:    fldt (%rax,%rcx)
; CHECK-NEXT:    retq
;
  %tmp9 = icmp sgt i32 %tmp8, -1
  %retval = select i1 %tmp9, x86_fp80 0xK4005B400000000000000, x86_fp80 0xK40078700000000000000
  ret x86_fp80 %retval
}

; widening select v6i32 and then a sub
define void @test8(i1 %c, <6 x i32>* %dst.addr, <6 x i32> %src1,<6 x i32> %src2) nounwind {
; CHECK-LABEL: test8:
; CHECK:       ## BB#0:
; CHECK-NEXT:    andb $1, %dil
; CHECK-NEXT:    jne LBB7_1
; CHECK-NEXT:  ## BB#2:
; CHECK-NEXT:    movd {{.*#+}} xmm1 = mem[0],zero,zero,zero
; CHECK-NEXT:    movd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-NEXT:    jmp LBB7_3
; CHECK-NEXT:  LBB7_1:
; CHECK-NEXT:    movd {{.*#+}} xmm1 = mem[0],zero,zero,zero
; CHECK-NEXT:    movd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; CHECK-NEXT:  LBB7_3:
; CHECK-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; CHECK-NEXT:    testb %dil, %dil
; CHECK-NEXT:    jne LBB7_4
; CHECK-NEXT:  ## BB#5:
; CHECK-NEXT:    movd {{.*#+}} xmm2 = mem[0],zero,zero,zero
; CHECK-NEXT:    movd {{.*#+}} xmm3 = mem[0],zero,zero,zero
; CHECK-NEXT:    movd {{.*#+}} xmm4 = mem[0],zero,zero,zero
; CHECK-NEXT:    movd {{.*#+}} xmm1 = mem[0],zero,zero,zero
; CHECK-NEXT:    jmp LBB7_6
; CHECK-NEXT:  LBB7_4:
; CHECK-NEXT:    movd %r9d, %xmm2
; CHECK-NEXT:    movd %ecx, %xmm3
; CHECK-NEXT:    movd %r8d, %xmm4
; CHECK-NEXT:    movd %edx, %xmm1
; CHECK-NEXT:  LBB7_6:
; CHECK-NEXT:    punpckldq {{.*#+}} xmm3 = xmm3[0],xmm2[0],xmm3[1],xmm2[1]
; CHECK-NEXT:    punpckldq {{.*#+}} xmm1 = xmm1[0],xmm4[0],xmm1[1],xmm4[1]
; CHECK-NEXT:    punpckldq {{.*#+}} xmm1 = xmm1[0],xmm3[0],xmm1[1],xmm3[1]
; CHECK-NEXT:    psubd {{.*}}(%rip), %xmm
; CHECK-NEXT:    psubd {{.*}}(%rip), %xmm
; CHECK-NEXT:    movq %xmm0, 16(%rsi)
; CHECK-NEXT:    movdqa %xmm1, (%rsi)
; CHECK-NEXT:    retq
;
  %x = select i1 %c, <6 x i32> %src1, <6 x i32> %src2
  %val = sub <6 x i32> %x, < i32 1, i32 1, i32 1, i32 1, i32 1, i32 1 >
  store <6 x i32> %val, <6 x i32>* %dst.addr
  ret void
}


;; Test integer select between values and constants.

define i64 @test9(i64 %x, i64 %y) nounwind readnone ssp noredzone {
; GENERIC-LABEL: test9:
; GENERIC:       ## BB#0:
; GENERIC-NEXT:    cmpq $1, %rdi
; GENERIC-NEXT:    sbbq %rax, %rax
; GENERIC-NEXT:    orq %rsi, %rax
; GENERIC-NEXT:    retq
;
; ATOM-LABEL: test9:
; ATOM:       ## BB#0:
; ATOM-NEXT:    cmpq $1, %rdi
; ATOM-NEXT:    sbbq %rax, %rax
; ATOM-NEXT:    orq %rsi, %rax
; ATOM-NEXT:    nop
; ATOM-NEXT:    nop
; ATOM-NEXT:    retq
;
  %cmp = icmp ne i64 %x, 0
  %cond = select i1 %cmp, i64 %y, i64 -1
  ret i64 %cond
}

;; Same as test9
define i64 @test9a(i64 %x, i64 %y) nounwind readnone ssp noredzone {
; GENERIC-LABEL: test9a:
; GENERIC:       ## BB#0:
; GENERIC-NEXT:    cmpq $1, %rdi
; GENERIC-NEXT:    sbbq %rax, %rax
; GENERIC-NEXT:    orq %rsi, %rax
; GENERIC-NEXT:    retq
;
; ATOM-LABEL: test9a:
; ATOM:       ## BB#0:
; ATOM-NEXT:    cmpq $1, %rdi
; ATOM-NEXT:    sbbq %rax, %rax
; ATOM-NEXT:    orq %rsi, %rax
; ATOM-NEXT:    nop
; ATOM-NEXT:    nop
; ATOM-NEXT:    retq
;
  %cmp = icmp eq i64 %x, 0
  %cond = select i1 %cmp, i64 -1, i64 %y
  ret i64 %cond
}

define i64 @test9b(i64 %x, i64 %y) nounwind readnone ssp noredzone {
; GENERIC-LABEL: test9b:
; GENERIC:       ## BB#0:
; GENERIC-NEXT:    cmpq $1, %rdi
; GENERIC-NEXT:    sbbq %rax, %rax
; GENERIC-NEXT:    orq %rsi, %rax
; GENERIC-NEXT:    retq
;
; ATOM-LABEL: test9b:
; ATOM:       ## BB#0:
; ATOM-NEXT:    cmpq $1, %rdi
; ATOM-NEXT:    sbbq %rax, %rax
; ATOM-NEXT:    orq %rsi, %rax
; ATOM-NEXT:    nop
; ATOM-NEXT:    nop
; ATOM-NEXT:    retq
;
  %cmp = icmp eq i64 %x, 0
  %A = sext i1 %cmp to i64
  %cond = or i64 %y, %A
  ret i64 %cond
}

;; Select between -1 and 1.
define i64 @test10(i64 %x, i64 %y) nounwind readnone ssp noredzone {
; GENERIC-LABEL: test10:
; GENERIC:       ## BB#0:
; GENERIC-NEXT:    cmpq $1, %rdi
; GENERIC-NEXT:    sbbq %rax, %rax
; GENERIC-NEXT:    orq $1, %rax
; GENERIC-NEXT:    retq
;
; ATOM-LABEL: test10:
; ATOM:       ## BB#0:
; ATOM-NEXT:    cmpq $1, %rdi
; ATOM-NEXT:    sbbq %rax, %rax
; ATOM-NEXT:    orq $1, %rax
; ATOM-NEXT:    nop
; ATOM-NEXT:    nop
; ATOM-NEXT:    retq
;
  %cmp = icmp eq i64 %x, 0
  %cond = select i1 %cmp, i64 -1, i64 1
  ret i64 %cond
}

define i64 @test11(i64 %x, i64 %y) nounwind readnone ssp noredzone {
; CHECK-LABEL: test11:
; CHECK:       ## BB#0:
; CHECK-NEXT:    cmpq $1, %rdi
; CHECK-NEXT:    sbbq %rax, %rax
; CHECK-NEXT:    notq %rax
; CHECK-NEXT:    orq %rsi, %rax
; CHECK-NEXT:    retq
;
  %cmp = icmp eq i64 %x, 0
  %cond = select i1 %cmp, i64 %y, i64 -1
  ret i64 %cond
}

define i64 @test11a(i64 %x, i64 %y) nounwind readnone ssp noredzone {
; CHECK-LABEL: test11a:
; CHECK:       ## BB#0:
; CHECK-NEXT:    cmpq $1, %rdi
; CHECK-NEXT:    sbbq %rax, %rax
; CHECK-NEXT:    notq %rax
; CHECK-NEXT:    orq %rsi, %rax
; CHECK-NEXT:    retq
;
  %cmp = icmp ne i64 %x, 0
  %cond = select i1 %cmp, i64 -1, i64 %y
  ret i64 %cond
}


declare noalias i8* @_Znam(i64) noredzone

define noalias i8* @test12(i64 %count) nounwind ssp noredzone {
; GENERIC-LABEL: test12:
; GENERIC:       ## BB#0: ## %entry
; GENERIC-NEXT:    movl $4, %ecx
; GENERIC-NEXT:    movq %rdi, %rax
; GENERIC-NEXT:    mulq %rcx
; GENERIC-NEXT:    movq $-1, %rdi
; GENERIC-NEXT:    cmovnoq %rax, %rdi
; GENERIC-NEXT:    jmp __Znam ## TAILCALL
;
; ATOM-LABEL: test12:
; ATOM:       ## BB#0: ## %entry
; ATOM-NEXT:    movq %rdi, %rax
; ATOM-NEXT:    movl $4, %ecx
; ATOM-NEXT:    mulq %rcx
; ATOM-NEXT:    movq $-1, %rdi
; ATOM-NEXT:    cmovnoq %rax, %rdi
; ATOM-NEXT:    jmp __Znam ## TAILCALL
;
entry:
  %A = tail call { i64, i1 } @llvm.umul.with.overflow.i64(i64 %count, i64 4)
  %B = extractvalue { i64, i1 } %A, 1
  %C = extractvalue { i64, i1 } %A, 0
  %D = select i1 %B, i64 -1, i64 %C
  %call = tail call noalias i8* @_Znam(i64 %D) nounwind noredzone
  ret i8* %call
}

declare { i64, i1 } @llvm.umul.with.overflow.i64(i64, i64) nounwind readnone

define i32 @test13(i32 %a, i32 %b) nounwind {
; GENERIC-LABEL: test13:
; GENERIC:       ## BB#0:
; GENERIC-NEXT:    cmpl %esi, %edi
; GENERIC-NEXT:    sbbl %eax, %eax
; GENERIC-NEXT:    retq
;
; ATOM-LABEL: test13:
; ATOM:       ## BB#0:
; ATOM-NEXT:    cmpl %esi, %edi
; ATOM-NEXT:    sbbl %eax, %eax
; ATOM-NEXT:    nop
; ATOM-NEXT:    nop
; ATOM-NEXT:    nop
; ATOM-NEXT:    nop
; ATOM-NEXT:    retq
;
  %c = icmp ult i32 %a, %b
  %d = sext i1 %c to i32
  ret i32 %d
}

define i32 @test14(i32 %a, i32 %b) nounwind {
; GENERIC-LABEL: test14:
; GENERIC:       ## BB#0:
; GENERIC-NEXT:    cmpl %esi, %edi
; GENERIC-NEXT:    sbbl %eax, %eax
; GENERIC-NEXT:    notl %eax
; GENERIC-NEXT:    retq
;
; ATOM-LABEL: test14:
; ATOM:       ## BB#0:
; ATOM-NEXT:    cmpl %esi, %edi
; ATOM-NEXT:    sbbl %eax, %eax
; ATOM-NEXT:    notl %eax
; ATOM-NEXT:    nop
; ATOM-NEXT:    nop
; ATOM-NEXT:    retq
;
  %c = icmp uge i32 %a, %b
  %d = sext i1 %c to i32
  ret i32 %d
}

; rdar://10961709
define i32 @test15(i32 %x) nounwind {
; GENERIC-LABEL: test15:
; GENERIC:       ## BB#0: ## %entry
; GENERIC-NEXT:    negl %edi
; GENERIC-NEXT:    sbbl %eax, %eax
; GENERIC-NEXT:    retq
;
; ATOM-LABEL: test15:
; ATOM:       ## BB#0: ## %entry
; ATOM-NEXT:    negl %edi
; ATOM-NEXT:    sbbl %eax, %eax
; ATOM-NEXT:    nop
; ATOM-NEXT:    nop
; ATOM-NEXT:    nop
; ATOM-NEXT:    nop
; ATOM-NEXT:    retq
;
entry:
  %cmp = icmp ne i32 %x, 0
  %sub = sext i1 %cmp to i32
  ret i32 %sub
}

define i64 @test16(i64 %x) nounwind uwtable readnone ssp {
; GENERIC-LABEL: test16:
; GENERIC:       ## BB#0: ## %entry
; GENERIC-NEXT:    negq %rdi
; GENERIC-NEXT:    sbbq %rax, %rax
; GENERIC-NEXT:    retq
;
; ATOM-LABEL: test16:
; ATOM:       ## BB#0: ## %entry
; ATOM-NEXT:    negq %rdi
; ATOM-NEXT:    sbbq %rax, %rax
; ATOM-NEXT:    nop
; ATOM-NEXT:    nop
; ATOM-NEXT:    nop
; ATOM-NEXT:    nop
; ATOM-NEXT:    retq
;
entry:
  %cmp = icmp ne i64 %x, 0
  %conv1 = sext i1 %cmp to i64
  ret i64 %conv1
}

define i16 @test17(i16 %x) nounwind {
; GENERIC-LABEL: test17:
; GENERIC:       ## BB#0: ## %entry
; GENERIC-NEXT:    negw %di
; GENERIC-NEXT:    sbbw %ax, %ax
; GENERIC-NEXT:    retq
;
; ATOM-LABEL: test17:
; ATOM:       ## BB#0: ## %entry
; ATOM-NEXT:    negw %di
; ATOM-NEXT:    sbbw %ax, %ax
; ATOM-NEXT:    nop
; ATOM-NEXT:    nop
; ATOM-NEXT:    nop
; ATOM-NEXT:    nop
; ATOM-NEXT:    retq
;
entry:
  %cmp = icmp ne i16 %x, 0
  %sub = sext i1 %cmp to i16
  ret i16 %sub
}

define i8 @test18(i32 %x, i8 zeroext %a, i8 zeroext %b) nounwind {
; GENERIC-LABEL: test18:
; GENERIC:       ## BB#0:
; GENERIC-NEXT:    cmpl $15, %edi
; GENERIC-NEXT:    cmovgel %edx, %esi
; GENERIC-NEXT:    movl %esi, %eax
; GENERIC-NEXT:    retq
;
; ATOM-LABEL: test18:
; ATOM:       ## BB#0:
; ATOM-NEXT:    cmpl $15, %edi
; ATOM-NEXT:    cmovgel %edx, %esi
; ATOM-NEXT:    movl %esi, %eax
; ATOM-NEXT:    nop
; ATOM-NEXT:    nop
; ATOM-NEXT:    retq
;
  %cmp = icmp slt i32 %x, 15
  %sel = select i1 %cmp, i8 %a, i8 %b
  ret i8 %sel
}

define i32 @trunc_select_miscompile(i32 %a, i1 zeroext %cc) {
; CHECK-LABEL: trunc_select_miscompile:
; CHECK:       ## BB#0:
; CHECK-NEXT:    orb $2, %sil
; CHECK-NEXT:    movl %esi, %ecx
; CHECK-NEXT:    shll %cl, %edi
; CHECK-NEXT:    movl %edi, %eax
; CHECK-NEXT:    retq
;
  %tmp1 = select i1 %cc, i32 3, i32 2
  %tmp2 = shl i32 %a, %tmp1
  ret i32 %tmp2
}

define void @test19() {
; This is a massive reduction of an llvm-stress test case that generates
; interesting chains feeding setcc and eventually a f32 select operation. This
; is intended to exercise the SELECT formation in the DAG combine simplifying
; a simplified select_cc node. If it it regresses and is no longer triggering
; that code path, it can be deleted.
;
; CHECK-LABEL: test19:
; CHECK:       ## BB#0: ## %BB
; CHECK-NEXT:    movl $-1, %eax
; CHECK-NEXT:    movb $1, %cl
; CHECK-NEXT:    .p2align 4, 0x90
; CHECK-NEXT:  LBB22_1: ## %CF
; CHECK-NEXT:    ## 
; CHECK-NEXT:    testb %cl, %cl
; CHECK-NEXT:    jne LBB22_1
; CHECK-NEXT:  ## BB#2: ## %CF250
; CHECK-NEXT:    ## 
; CHECK-NEXT:    jne LBB22_1
; CHECK-NEXT:    .p2align 4, 0x90
; CHECK-NEXT:  LBB22_3: ## %CF242
; CHECK-NEXT:    ## 
; CHECK-NEXT:    cmpl %eax, %eax
; CHECK-NEXT:    ucomiss %xmm0, %xmm0
; CHECK-NEXT:    jp LBB22_3
; CHECK-NEXT:  ## BB#4: 
; CHECK-NEXT:    retq
;
BB:
  br label %CF

CF:
  %Cmp10 = icmp ule i8 undef, undef
  br i1 %Cmp10, label %CF, label %CF250

CF250:
  %E12 = extractelement <4 x i32> <i32 -1, i32 -1, i32 -1, i32 -1>, i32 2
  %Cmp32 = icmp ugt i1 %Cmp10, false
  br i1 %Cmp32, label %CF, label %CF242

CF242:
  %Cmp38 = icmp uge i32 %E12, undef
  %FC = uitofp i1 %Cmp38 to float
  %Sl59 = select i1 %Cmp32, float %FC, float undef
  %Cmp60 = fcmp ugt float undef, undef
  br i1 %Cmp60, label %CF242, label %CF244

CF244:
  %B122 = fadd float %Sl59, undef
  ret void
}
