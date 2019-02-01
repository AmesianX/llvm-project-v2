; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; REQUIRES: asserts
; RUN: llc < %s -mattr=+sse3,+sse4.1 -mcpu=penryn -stats 2>&1 | grep "6 machinelicm"
; RUN: llc < %s -mattr=+sse3,+sse4.1 -mcpu=penryn | FileCheck %s
; rdar://6627786
; rdar://7792037

target triple = "x86_64-apple-darwin10.0"
	%struct.Key = type { i64 }
	%struct.__Rec = type opaque
	%struct.__vv = type {  }

define %struct.__vv* @t(%struct.Key* %desc, i64 %p) nounwind ssp {
; CHECK-LABEL: t:
; CHECK:       ## %bb.0: ## %entry
; CHECK-NEXT:    pushq %r14
; CHECK-NEXT:    pushq %rbx
; CHECK-NEXT:    pushq %rax
; CHECK-NEXT:    movq %rsi, %r14
; CHECK-NEXT:    movq %rdi, %rbx
; CHECK-NEXT:    orq $2097152, %r14 ## imm = 0x200000
; CHECK-NEXT:    andl $15728640, %r14d ## imm = 0xF00000
; CHECK-NEXT:    .p2align 4, 0x90
; CHECK-NEXT:  LBB0_1: ## %bb4
; CHECK-NEXT:    ## =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    xorl %eax, %eax
; CHECK-NEXT:    callq _xxGetOffsetForCode
; CHECK-NEXT:    movq %rbx, %rdi
; CHECK-NEXT:    xorl %esi, %esi
; CHECK-NEXT:    xorl %eax, %eax
; CHECK-NEXT:    callq _xxCalculateMidType
; CHECK-NEXT:    cmpl $1, %eax
; CHECK-NEXT:    jne LBB0_1
; CHECK-NEXT:  ## %bb.2: ## %bb26
; CHECK-NEXT:    ## in Loop: Header=BB0_1 Depth=1
; CHECK-NEXT:    cmpq $1048576, %r14 ## imm = 0x100000
; CHECK-NEXT:    jne LBB0_1
; CHECK-NEXT:  ## %bb.3: ## %bb.i
; CHECK-NEXT:    ## in Loop: Header=BB0_1 Depth=1
; CHECK-NEXT:    movl 0, %eax
; CHECK-NEXT:    xorps %xmm0, %xmm0
; CHECK-NEXT:    cvtsi2ssq %rax, %xmm0
; CHECK-NEXT:    movl 4, %eax
; CHECK-NEXT:    xorps %xmm1, %xmm1
; CHECK-NEXT:    cvtsi2ssq %rax, %xmm1
; CHECK-NEXT:    movl 8, %eax
; CHECK-NEXT:    xorps %xmm2, %xmm2
; CHECK-NEXT:    cvtsi2ssq %rax, %xmm2
; CHECK-NEXT:    insertps {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[2,3]
; CHECK-NEXT:    insertps {{.*#+}} xmm0 = xmm0[0,1],xmm2[0],xmm0[3]
; CHECK-NEXT:    movaps %xmm0, 0
; CHECK-NEXT:    jmp LBB0_1
entry:
	br label %bb4

bb4:		; preds = %bb.i, %bb26, %bb4, %entry

	%0 = call i32 (...) @xxGetOffsetForCode(i32 undef) nounwind		; <i32> [#uses=0]
	%ins = or i64 %p, 2097152		; <i64> [#uses=1]
	%1 = call i32 (...) @xxCalculateMidType(%struct.Key* %desc, i32 0) nounwind		; <i32> [#uses=1]
	%cond = icmp eq i32 %1, 1		; <i1> [#uses=1]
	br i1 %cond, label %bb26, label %bb4

bb26:		; preds = %bb4
	%2 = and i64 %ins, 15728640		; <i64> [#uses=1]
	%cond.i = icmp eq i64 %2, 1048576		; <i1> [#uses=1]
	br i1 %cond.i, label %bb.i, label %bb4

bb.i:		; preds = %bb26
	%3 = load i32, i32* null, align 4		; <i32> [#uses=1]
	%4 = uitofp i32 %3 to float		; <float> [#uses=1]
	%.sum13.i = add i64 0, 4		; <i64> [#uses=1]
	%5 = getelementptr i8, i8* null, i64 %.sum13.i		; <i8*> [#uses=1]
	%6 = bitcast i8* %5 to i32*		; <i32*> [#uses=1]
	%7 = load i32, i32* %6, align 4		; <i32> [#uses=1]
	%8 = uitofp i32 %7 to float		; <float> [#uses=1]
	%.sum.i = add i64 0, 8		; <i64> [#uses=1]
	%9 = getelementptr i8, i8* null, i64 %.sum.i		; <i8*> [#uses=1]
	%10 = bitcast i8* %9 to i32*		; <i32*> [#uses=1]
	%11 = load i32, i32* %10, align 4		; <i32> [#uses=1]
	%12 = uitofp i32 %11 to float		; <float> [#uses=1]
	%13 = insertelement <4 x float> undef, float %4, i32 0		; <<4 x float>> [#uses=1]
	%14 = insertelement <4 x float> %13, float %8, i32 1		; <<4 x float>> [#uses=1]
	%15 = insertelement <4 x float> %14, float %12, i32 2		; <<4 x float>> [#uses=1]
	store <4 x float> %15, <4 x float>* null, align 16
	br label %bb4
}

declare i32 @xxGetOffsetForCode(...)

declare i32 @xxCalculateMidType(...)
