; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=avx2 -O0 | FileCheck %s

define <16 x i64> @pluto(<16 x i64> %arg, <16 x i64> %arg1, <16 x i64> %arg2, <16 x i64> %arg3, <16 x i64> %arg4) {
; CHECK-LABEL: pluto:
; CHECK:       # %bb.0: # %bb
; CHECK-NEXT:    pushq %rbp
; CHECK-NEXT:    .cfi_def_cfa_offset 16
; CHECK-NEXT:    .cfi_offset %rbp, -16
; CHECK-NEXT:    movq %rsp, %rbp
; CHECK-NEXT:    .cfi_def_cfa_register %rbp
; CHECK-NEXT:    andq $-32, %rsp
; CHECK-NEXT:    subq $288, %rsp # imm = 0x120
; CHECK-NEXT:    vmovaps 240(%rbp), %ymm8
; CHECK-NEXT:    vmovaps 208(%rbp), %ymm9
; CHECK-NEXT:    vmovaps 176(%rbp), %ymm10
; CHECK-NEXT:    vmovaps 144(%rbp), %ymm11
; CHECK-NEXT:    vmovaps 112(%rbp), %ymm12
; CHECK-NEXT:    vmovaps 80(%rbp), %ymm13
; CHECK-NEXT:    vmovaps 48(%rbp), %ymm14
; CHECK-NEXT:    vmovaps 16(%rbp), %ymm15
; CHECK-NEXT:    vmovaps %ymm0, {{[0-9]+}}(%rsp) # 32-byte Spill
; CHECK-NEXT:    vmovaps {{.*#+}} ymm0 = [0,0,18446744071562067968,18446744071562067968]
; CHECK-NEXT:    vblendvpd %ymm0, %ymm2, %ymm6, %ymm0
; CHECK-NEXT:    vxorps %xmm2, %xmm2, %xmm2
; CHECK-NEXT:    vpblendd {{.*#+}} ymm6 = ymm2[0,1],ymm13[2,3],ymm2[4,5,6,7]
; CHECK-NEXT:    vpblendd {{.*#+}} ymm2 = ymm2[0,1],ymm8[2,3,4,5,6,7]
; CHECK-NEXT:    vmovaps {{.*#+}} ymm8 = [18446744071562067968,18446744071562067968,0,0]
; CHECK-NEXT:    vblendvpd %ymm8, %ymm9, %ymm6, %ymm6
; CHECK-NEXT:    vpblendd {{.*#+}} ymm8 = ymm15[0,1],ymm11[2,3,4,5,6,7]
; CHECK-NEXT:    vpalignr {{.*#+}} ymm8 = ymm0[8,9,10,11,12,13,14,15],ymm8[0,1,2,3,4,5,6,7],ymm0[24,25,26,27,28,29,30,31],ymm8[16,17,18,19,20,21,22,23]
; CHECK-NEXT:    vpermq {{.*#+}} ymm8 = ymm8[2,3,2,0]
; CHECK-NEXT:    vmovaps %xmm6, %xmm9
; CHECK-NEXT:    # implicit-def: %ymm11
; CHECK-NEXT:    vinserti128 $1, %xmm9, %ymm11, %ymm11
; CHECK-NEXT:    vpblendd {{.*#+}} ymm8 = ymm8[0,1,2,3],ymm11[4,5],ymm8[6,7]
; CHECK-NEXT:    vmovaps %xmm0, %xmm9
; CHECK-NEXT:    # implicit-def: %ymm0
; CHECK-NEXT:    vinserti128 $1, %xmm9, %ymm0, %ymm0
; CHECK-NEXT:    vpunpcklqdq {{.*#+}} ymm11 = ymm7[0],ymm2[0],ymm7[2],ymm2[2]
; CHECK-NEXT:    vpermq {{.*#+}} ymm11 = ymm11[2,1,2,3]
; CHECK-NEXT:    vpblendd {{.*#+}} ymm0 = ymm11[0,1,2,3],ymm0[4,5,6,7]
; CHECK-NEXT:    vpblendd {{.*#+}} ymm2 = ymm7[0,1],ymm2[2,3],ymm7[4,5,6,7]
; CHECK-NEXT:    vpermq {{.*#+}} ymm2 = ymm2[2,1,1,3]
; CHECK-NEXT:    vpshufd {{.*#+}} ymm11 = ymm5[0,1,0,1,4,5,4,5]
; CHECK-NEXT:    vpblendd {{.*#+}} ymm2 = ymm2[0,1,2,3,4,5],ymm11[6,7]
; CHECK-NEXT:    vpalignr {{.*#+}} ymm5 = ymm6[8,9,10,11,12,13,14,15],ymm5[0,1,2,3,4,5,6,7],ymm6[24,25,26,27,28,29,30,31],ymm5[16,17,18,19,20,21,22,23]
; CHECK-NEXT:    vpermq {{.*#+}} ymm5 = ymm5[0,1,0,3]
; CHECK-NEXT:    vpslldq {{.*#+}} ymm6 = zero,zero,zero,zero,zero,zero,zero,zero,ymm7[0,1,2,3,4,5,6,7],zero,zero,zero,zero,zero,zero,zero,zero,ymm7[16,17,18,19,20,21,22,23]
; CHECK-NEXT:    vpblendd {{.*#+}} ymm5 = ymm6[0,1,2,3],ymm5[4,5,6,7]
; CHECK-NEXT:    vmovaps %ymm0, {{[0-9]+}}(%rsp) # 32-byte Spill
; CHECK-NEXT:    vmovaps %ymm8, %ymm0
; CHECK-NEXT:    vmovaps %ymm1, {{[0-9]+}}(%rsp) # 32-byte Spill
; CHECK-NEXT:    vmovaps %ymm2, %ymm1
; CHECK-NEXT:    vmovaps {{[0-9]+}}(%rsp), %ymm2 # 32-byte Reload
; CHECK-NEXT:    vmovaps %ymm3, {{[0-9]+}}(%rsp) # 32-byte Spill
; CHECK-NEXT:    vmovaps %ymm5, %ymm3
; CHECK-NEXT:    vmovaps %ymm10, {{[0-9]+}}(%rsp) # 32-byte Spill
; CHECK-NEXT:    vmovaps %ymm12, {{[0-9]+}}(%rsp) # 32-byte Spill
; CHECK-NEXT:    vmovaps %ymm4, {{[0-9]+}}(%rsp) # 32-byte Spill
; CHECK-NEXT:    vmovaps %ymm14, (%rsp) # 32-byte Spill
; CHECK-NEXT:    movq %rbp, %rsp
; CHECK-NEXT:    popq %rbp
; CHECK-NEXT:    retq
bb:
  %tmp = select <16 x i1> <i1 false, i1 false, i1 false, i1 false, i1 false, i1 false, i1 false, i1 false, i1 false, i1 false, i1 true, i1 true, i1 false, i1 false, i1 false, i1 false>, <16 x i64> %arg, <16 x i64> %arg1
  %tmp5 = select <16 x i1> <i1 true, i1 false, i1 false, i1 true, i1 true, i1 false, i1 false, i1 true, i1 false, i1 true, i1 false, i1 false, i1 false, i1 false, i1 false, i1 false>, <16 x i64> %arg2, <16 x i64> zeroinitializer
  %tmp6 = select <16 x i1> <i1 false, i1 true, i1 true, i1 true, i1 false, i1 false, i1 false, i1 false, i1 true, i1 true, i1 false, i1 false, i1 false, i1 true, i1 true, i1 true>, <16 x i64> %arg3, <16 x i64> %tmp5
  %tmp7 = shufflevector <16 x i64> %tmp, <16 x i64> %tmp6, <16 x i32> <i32 11, i32 18, i32 24, i32 9, i32 14, i32 29, i32 29, i32 6, i32 14, i32 28, i32 8, i32 9, i32 22, i32 12, i32 25, i32 6>
  ret <16 x i64> %tmp7
}
