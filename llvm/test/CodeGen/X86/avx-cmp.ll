; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx | FileCheck %s

define <8 x i32> @cmp00(<8 x float> %a, <8 x float> %b) nounwind {
; CHECK-LABEL: cmp00:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vcmpltps %ymm1, %ymm0, %ymm0
; CHECK-NEXT:    retq
  %bincmp = fcmp olt <8 x float> %a, %b
  %s = sext <8 x i1> %bincmp to <8 x i32>
  ret <8 x i32> %s
}

define <4 x i64> @cmp01(<4 x double> %a, <4 x double> %b) nounwind {
; CHECK-LABEL: cmp01:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vcmpltpd %ymm1, %ymm0, %ymm0
; CHECK-NEXT:    retq
  %bincmp = fcmp olt <4 x double> %a, %b
  %s = sext <4 x i1> %bincmp to <4 x i64>
  ret <4 x i64> %s
}

declare void @scale() nounwind

define void @render() nounwind {
; CHECK-LABEL: render:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    pushq %rbp
; CHECK-NEXT:    pushq %rbx
; CHECK-NEXT:    pushq %rax
; CHECK-NEXT:    xorl %eax, %eax
; CHECK-NEXT:    testb %al, %al
; CHECK-NEXT:    jne .LBB2_6
; CHECK-NEXT:  # %bb.1: # %for.cond5.preheader
; CHECK-NEXT:    xorl %ebx, %ebx
; CHECK-NEXT:    movb $1, %bpl
; CHECK-NEXT:    .p2align 4, 0x90
; CHECK-NEXT:  .LBB2_2: # %for.cond5
; CHECK-NEXT:    # =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    testb %bl, %bl
; CHECK-NEXT:    jne .LBB2_2
; CHECK-NEXT:  # %bb.3: # %for.cond5
; CHECK-NEXT:    # in Loop: Header=BB2_2 Depth=1
; CHECK-NEXT:    testb %bpl, %bpl
; CHECK-NEXT:    jne .LBB2_2
; CHECK-NEXT:  # %bb.4: # %for.body33
; CHECK-NEXT:    # in Loop: Header=BB2_2 Depth=1
; CHECK-NEXT:    vucomisd {{\.LCPI.*}}, %xmm0
; CHECK-NEXT:    jne .LBB2_5
; CHECK-NEXT:    jnp .LBB2_2
; CHECK-NEXT:  .LBB2_5: # %if.then
; CHECK-NEXT:   # in Loop: Header=BB2_2 Depth=1
; CHECK-NEXT:    callq   scale
; CHECK-NEXT:    jmp .LBB2_2
; CHECK-NEXT:  .LBB2_6: # %for.end52
; CHECK-NEXT:    addq $8, %rsp
; CHECK-NEXT:    popq %rbx
; CHECK-NEXT:    popq %rbp
; CHECK-NEXT:    retq
entry:
  br i1 undef, label %for.cond5, label %for.end52

for.cond5:
  %or.cond = and i1 undef, false
  br i1 %or.cond, label %for.body33, label %for.cond5

for.cond30:
  br i1 false, label %for.body33, label %for.cond5

for.body33:
  %tobool = fcmp une double undef, 0.000000e+00
  br i1 %tobool, label %if.then, label %for.cond30

if.then:
  call void @scale()
  br label %for.cond30

for.end52:
  ret void
}

define <8 x i32> @int256_cmp(<8 x i32> %i, <8 x i32> %j) nounwind {
; CHECK-LABEL: int256_cmp:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vextractf128 $1, %ymm0, %xmm2
; CHECK-NEXT:    vextractf128 $1, %ymm1, %xmm3
; CHECK-NEXT:    vpcmpgtd %xmm2, %xmm3, %xmm2
; CHECK-NEXT:    vpcmpgtd %xmm0, %xmm1, %xmm0
; CHECK-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; CHECK-NEXT:    retq
  %bincmp = icmp slt <8 x i32> %i, %j
  %x = sext <8 x i1> %bincmp to <8 x i32>
  ret <8 x i32> %x
}

define <4 x i64> @v4i64_cmp(<4 x i64> %i, <4 x i64> %j) nounwind {
; CHECK-LABEL: v4i64_cmp:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vextractf128 $1, %ymm0, %xmm2
; CHECK-NEXT:    vextractf128 $1, %ymm1, %xmm3
; CHECK-NEXT:    vpcmpgtq %xmm2, %xmm3, %xmm2
; CHECK-NEXT:    vpcmpgtq %xmm0, %xmm1, %xmm0
; CHECK-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; CHECK-NEXT:    retq
  %bincmp = icmp slt <4 x i64> %i, %j
  %x = sext <4 x i1> %bincmp to <4 x i64>
  ret <4 x i64> %x
}

define <16 x i16> @v16i16_cmp(<16 x i16> %i, <16 x i16> %j) nounwind {
; CHECK-LABEL: v16i16_cmp:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vextractf128 $1, %ymm0, %xmm2
; CHECK-NEXT:    vextractf128 $1, %ymm1, %xmm3
; CHECK-NEXT:    vpcmpgtw %xmm2, %xmm3, %xmm2
; CHECK-NEXT:    vpcmpgtw %xmm0, %xmm1, %xmm0
; CHECK-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; CHECK-NEXT:    retq
  %bincmp = icmp slt <16 x i16> %i, %j
  %x = sext <16 x i1> %bincmp to <16 x i16>
  ret <16 x i16> %x
}

define <32 x i8> @v32i8_cmp(<32 x i8> %i, <32 x i8> %j) nounwind {
; CHECK-LABEL: v32i8_cmp:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vextractf128 $1, %ymm0, %xmm2
; CHECK-NEXT:    vextractf128 $1, %ymm1, %xmm3
; CHECK-NEXT:    vpcmpgtb %xmm2, %xmm3, %xmm2
; CHECK-NEXT:    vpcmpgtb %xmm0, %xmm1, %xmm0
; CHECK-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; CHECK-NEXT:    retq
  %bincmp = icmp slt <32 x i8> %i, %j
  %x = sext <32 x i1> %bincmp to <32 x i8>
  ret <32 x i8> %x
}

define <8 x i32> @int256_cmpeq(<8 x i32> %i, <8 x i32> %j) nounwind {
; CHECK-LABEL: int256_cmpeq:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vextractf128 $1, %ymm1, %xmm2
; CHECK-NEXT:    vextractf128 $1, %ymm0, %xmm3
; CHECK-NEXT:    vpcmpeqd %xmm2, %xmm3, %xmm2
; CHECK-NEXT:    vpcmpeqd %xmm1, %xmm0, %xmm0
; CHECK-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; CHECK-NEXT:    retq
  %bincmp = icmp eq <8 x i32> %i, %j
  %x = sext <8 x i1> %bincmp to <8 x i32>
  ret <8 x i32> %x
}

define <4 x i64> @v4i64_cmpeq(<4 x i64> %i, <4 x i64> %j) nounwind {
; CHECK-LABEL: v4i64_cmpeq:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vextractf128 $1, %ymm1, %xmm2
; CHECK-NEXT:    vextractf128 $1, %ymm0, %xmm3
; CHECK-NEXT:    vpcmpeqq %xmm2, %xmm3, %xmm2
; CHECK-NEXT:    vpcmpeqq %xmm1, %xmm0, %xmm0
; CHECK-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; CHECK-NEXT:    retq
  %bincmp = icmp eq <4 x i64> %i, %j
  %x = sext <4 x i1> %bincmp to <4 x i64>
  ret <4 x i64> %x
}

define <16 x i16> @v16i16_cmpeq(<16 x i16> %i, <16 x i16> %j) nounwind {
; CHECK-LABEL: v16i16_cmpeq:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vextractf128 $1, %ymm1, %xmm2
; CHECK-NEXT:    vextractf128 $1, %ymm0, %xmm3
; CHECK-NEXT:    vpcmpeqw %xmm2, %xmm3, %xmm2
; CHECK-NEXT:    vpcmpeqw %xmm1, %xmm0, %xmm0
; CHECK-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; CHECK-NEXT:    retq
  %bincmp = icmp eq <16 x i16> %i, %j
  %x = sext <16 x i1> %bincmp to <16 x i16>
  ret <16 x i16> %x
}

define <32 x i8> @v32i8_cmpeq(<32 x i8> %i, <32 x i8> %j) nounwind {
; CHECK-LABEL: v32i8_cmpeq:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vextractf128 $1, %ymm1, %xmm2
; CHECK-NEXT:    vextractf128 $1, %ymm0, %xmm3
; CHECK-NEXT:    vpcmpeqb %xmm2, %xmm3, %xmm2
; CHECK-NEXT:    vpcmpeqb %xmm1, %xmm0, %xmm0
; CHECK-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; CHECK-NEXT:    retq
  %bincmp = icmp eq <32 x i8> %i, %j
  %x = sext <32 x i1> %bincmp to <32 x i8>
  ret <32 x i8> %x
}

;; Scalar comparison

define i32 @scalarcmpA() uwtable ssp {
; CHECK-LABEL: scalarcmpA:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vxorpd %xmm0, %xmm0, %xmm0
; CHECK-NEXT:    vcmpeqsd %xmm0, %xmm0, %xmm0
; CHECK-NEXT:    vmovq %xmm0, %rax
; CHECK-NEXT:    andl $1, %eax
; CHECK-NEXT:    # kill: def $eax killed $eax killed $rax
; CHECK-NEXT:    retq
  %cmp29 = fcmp oeq double undef, 0.000000e+00
  %res = zext i1 %cmp29 to i32
  ret i32 %res
}

define i32 @scalarcmpB() uwtable ssp {
; CHECK-LABEL: scalarcmpB:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vxorps %xmm0, %xmm0, %xmm0
; CHECK-NEXT:    vcmpeqss %xmm0, %xmm0, %xmm0
; CHECK-NEXT:    vmovd %xmm0, %eax
; CHECK-NEXT:    andl $1, %eax
; CHECK-NEXT:    retq
  %cmp29 = fcmp oeq float undef, 0.000000e+00
  %res = zext i1 %cmp29 to i32
  ret i32 %res
}

