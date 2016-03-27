; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx | FileCheck %s --check-prefix=AVX --check-prefix=AVX1
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx2 | FileCheck %s --check-prefix=AVX --check-prefix=AVX2

;
; udiv by 7
;

define <4 x i64> @test_div7_4i64(<4 x i64> %a) nounwind {
; AVX1-LABEL: test_div7_4i64:
; AVX1:       # BB#0:
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX1-NEXT:    vpextrq $1, %xmm1, %rcx
; AVX1-NEXT:    movabsq $2635249153387078803, %rsi # imm = 0x2492492492492493
; AVX1-NEXT:    movq %rcx, %rax
; AVX1-NEXT:    mulq %rsi
; AVX1-NEXT:    subq %rdx, %rcx
; AVX1-NEXT:    shrq %rcx
; AVX1-NEXT:    addq %rdx, %rcx
; AVX1-NEXT:    shrq $2, %rcx
; AVX1-NEXT:    vmovq %rcx, %xmm2
; AVX1-NEXT:    vmovq %xmm1, %rcx
; AVX1-NEXT:    movq %rcx, %rax
; AVX1-NEXT:    mulq %rsi
; AVX1-NEXT:    subq %rdx, %rcx
; AVX1-NEXT:    shrq %rcx
; AVX1-NEXT:    addq %rdx, %rcx
; AVX1-NEXT:    shrq $2, %rcx
; AVX1-NEXT:    vmovq %rcx, %xmm1
; AVX1-NEXT:    vpunpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm2[0]
; AVX1-NEXT:    vpextrq $1, %xmm0, %rcx
; AVX1-NEXT:    movq %rcx, %rax
; AVX1-NEXT:    mulq %rsi
; AVX1-NEXT:    subq %rdx, %rcx
; AVX1-NEXT:    shrq %rcx
; AVX1-NEXT:    addq %rdx, %rcx
; AVX1-NEXT:    shrq $2, %rcx
; AVX1-NEXT:    vmovq %rcx, %xmm2
; AVX1-NEXT:    vmovq %xmm0, %rcx
; AVX1-NEXT:    movq %rcx, %rax
; AVX1-NEXT:    mulq %rsi
; AVX1-NEXT:    subq %rdx, %rcx
; AVX1-NEXT:    shrq %rcx
; AVX1-NEXT:    addq %rdx, %rcx
; AVX1-NEXT:    shrq $2, %rcx
; AVX1-NEXT:    vmovq %rcx, %xmm0
; AVX1-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm2[0]
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test_div7_4i64:
; AVX2:       # BB#0:
; AVX2-NEXT:    vextracti128 $1, %ymm0, %xmm1
; AVX2-NEXT:    vpextrq $1, %xmm1, %rcx
; AVX2-NEXT:    movabsq $2635249153387078803, %rsi # imm = 0x2492492492492493
; AVX2-NEXT:    movq %rcx, %rax
; AVX2-NEXT:    mulq %rsi
; AVX2-NEXT:    subq %rdx, %rcx
; AVX2-NEXT:    shrq %rcx
; AVX2-NEXT:    addq %rdx, %rcx
; AVX2-NEXT:    shrq $2, %rcx
; AVX2-NEXT:    vmovq %rcx, %xmm2
; AVX2-NEXT:    vmovq %xmm1, %rcx
; AVX2-NEXT:    movq %rcx, %rax
; AVX2-NEXT:    mulq %rsi
; AVX2-NEXT:    subq %rdx, %rcx
; AVX2-NEXT:    shrq %rcx
; AVX2-NEXT:    addq %rdx, %rcx
; AVX2-NEXT:    shrq $2, %rcx
; AVX2-NEXT:    vmovq %rcx, %xmm1
; AVX2-NEXT:    vpunpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm2[0]
; AVX2-NEXT:    vpextrq $1, %xmm0, %rcx
; AVX2-NEXT:    movq %rcx, %rax
; AVX2-NEXT:    mulq %rsi
; AVX2-NEXT:    subq %rdx, %rcx
; AVX2-NEXT:    shrq %rcx
; AVX2-NEXT:    addq %rdx, %rcx
; AVX2-NEXT:    shrq $2, %rcx
; AVX2-NEXT:    vmovq %rcx, %xmm2
; AVX2-NEXT:    vmovq %xmm0, %rcx
; AVX2-NEXT:    movq %rcx, %rax
; AVX2-NEXT:    mulq %rsi
; AVX2-NEXT:    subq %rdx, %rcx
; AVX2-NEXT:    shrq %rcx
; AVX2-NEXT:    addq %rdx, %rcx
; AVX2-NEXT:    shrq $2, %rcx
; AVX2-NEXT:    vmovq %rcx, %xmm0
; AVX2-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm2[0]
; AVX2-NEXT:    vinserti128 $1, %xmm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
  %res = udiv <4 x i64> %a, <i64 7, i64 7, i64 7, i64 7>
  ret <4 x i64> %res
}

define <8 x i32> @test_div7_8i32(<8 x i32> %a) nounwind {
; AVX1-LABEL: test_div7_8i32:
; AVX1:       # BB#0:
; AVX1-NEXT:    vmovdqa {{.*#+}} ymm1 = [613566757,613566757,613566757,613566757,613566757,613566757,613566757,613566757]
; AVX1-NEXT:    vpshufd {{.*#+}} xmm2 = xmm1[1,1,3,3]
; AVX1-NEXT:    vpshufd {{.*#+}} xmm3 = xmm0[1,1,3,3]
; AVX1-NEXT:    vpmuludq %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpmuludq %xmm1, %xmm0, %xmm3
; AVX1-NEXT:    vpshufd {{.*#+}} xmm3 = xmm3[1,1,3,3]
; AVX1-NEXT:    vpblendw {{.*#+}} xmm2 = xmm3[0,1],xmm2[2,3],xmm3[4,5],xmm2[6,7]
; AVX1-NEXT:    vpsubd %xmm2, %xmm0, %xmm3
; AVX1-NEXT:    vpsrld $1, %xmm3, %xmm3
; AVX1-NEXT:    vpaddd %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpsrld $2, %xmm2, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm1
; AVX1-NEXT:    vpshufd {{.*#+}} xmm3 = xmm1[1,1,3,3]
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX1-NEXT:    vpshufd {{.*#+}} xmm4 = xmm0[1,1,3,3]
; AVX1-NEXT:    vpmuludq %xmm3, %xmm4, %xmm3
; AVX1-NEXT:    vpmuludq %xmm1, %xmm0, %xmm1
; AVX1-NEXT:    vpshufd {{.*#+}} xmm1 = xmm1[1,1,3,3]
; AVX1-NEXT:    vpblendw {{.*#+}} xmm1 = xmm1[0,1],xmm3[2,3],xmm1[4,5],xmm3[6,7]
; AVX1-NEXT:    vpsubd %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpsrld $1, %xmm0, %xmm0
; AVX1-NEXT:    vpaddd %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpsrld $2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm2, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test_div7_8i32:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpbroadcastd {{.*}}(%rip), %ymm1
; AVX2-NEXT:    vpshufd {{.*#+}} ymm2 = ymm1[1,1,3,3,5,5,7,7]
; AVX2-NEXT:    vpshufd {{.*#+}} ymm3 = ymm0[1,1,3,3,5,5,7,7]
; AVX2-NEXT:    vpmuludq %ymm2, %ymm3, %ymm2
; AVX2-NEXT:    vpmuludq %ymm1, %ymm0, %ymm1
; AVX2-NEXT:    vpshufd {{.*#+}} ymm1 = ymm1[1,1,3,3,5,5,7,7]
; AVX2-NEXT:    vpblendd {{.*#+}} ymm1 = ymm1[0],ymm2[1],ymm1[2],ymm2[3],ymm1[4],ymm2[5],ymm1[6],ymm2[7]
; AVX2-NEXT:    vpsubd %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vpsrld $1, %ymm0, %ymm0
; AVX2-NEXT:    vpaddd %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vpsrld $2, %ymm0, %ymm0
; AVX2-NEXT:    retq
  %res = udiv <8 x i32> %a, <i32 7, i32 7, i32 7, i32 7, i32 7, i32 7, i32 7, i32 7>
  ret <8 x i32> %res
}

define <16 x i16> @test_div7_16i16(<16 x i16> %a) nounwind {
; AVX1-LABEL: test_div7_16i16:
; AVX1:       # BB#0:
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm1 = [9363,9363,9363,9363,9363,9363,9363,9363]
; AVX1-NEXT:    vpmulhuw %xmm1, %xmm0, %xmm2
; AVX1-NEXT:    vpsubw %xmm2, %xmm0, %xmm3
; AVX1-NEXT:    vpsrlw $1, %xmm3, %xmm3
; AVX1-NEXT:    vpaddw %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpsrlw $2, %xmm2, %xmm2
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX1-NEXT:    vpmulhuw %xmm1, %xmm0, %xmm1
; AVX1-NEXT:    vpsubw %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpsrlw $1, %xmm0, %xmm0
; AVX1-NEXT:    vpaddw %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpsrlw $2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm2, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test_div7_16i16:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpmulhuw {{.*}}(%rip), %ymm0, %ymm1
; AVX2-NEXT:    vpsubw %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vpsrlw $1, %ymm0, %ymm0
; AVX2-NEXT:    vpaddw %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vpsrlw $2, %ymm0, %ymm0
; AVX2-NEXT:    retq
  %res = udiv <16 x i16> %a, <i16 7, i16 7, i16 7, i16 7, i16 7, i16 7, i16 7, i16 7, i16 7, i16 7, i16 7, i16 7, i16 7, i16 7, i16 7, i16 7>
  ret <16 x i16> %res
}

define <32 x i8> @test_div7_32i8(<32 x i8> %a) nounwind {
; AVX1-LABEL: test_div7_32i8:
; AVX1:       # BB#0:
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX1-NEXT:    vpmovzxbw {{.*#+}} xmm2 = xmm1[0],zero,xmm1[1],zero,xmm1[2],zero,xmm1[3],zero,xmm1[4],zero,xmm1[5],zero,xmm1[6],zero,xmm1[7],zero
; AVX1-NEXT:    vpmovzxbw {{.*#+}} xmm3 = mem[0],zero,mem[1],zero,mem[2],zero,mem[3],zero,mem[4],zero,mem[5],zero,mem[6],zero,mem[7],zero
; AVX1-NEXT:    vpmullw %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vpsrlw $8, %xmm2, %xmm2
; AVX1-NEXT:    vpshufd {{.*#+}} xmm4 = xmm1[2,3,0,1]
; AVX1-NEXT:    vpmovzxbw {{.*#+}} xmm4 = xmm4[0],zero,xmm4[1],zero,xmm4[2],zero,xmm4[3],zero,xmm4[4],zero,xmm4[5],zero,xmm4[6],zero,xmm4[7],zero
; AVX1-NEXT:    vpmullw %xmm3, %xmm4, %xmm4
; AVX1-NEXT:    vpsrlw $8, %xmm4, %xmm4
; AVX1-NEXT:    vpackuswb %xmm4, %xmm2, %xmm2
; AVX1-NEXT:    vpsubb %xmm2, %xmm1, %xmm1
; AVX1-NEXT:    vpsrlw $1, %xmm1, %xmm1
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm4 = [127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127]
; AVX1-NEXT:    vpand %xmm4, %xmm1, %xmm1
; AVX1-NEXT:    vpaddb %xmm2, %xmm1, %xmm1
; AVX1-NEXT:    vpsrlw $2, %xmm1, %xmm1
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm2 = [63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63]
; AVX1-NEXT:    vpand %xmm2, %xmm1, %xmm1
; AVX1-NEXT:    vpmovzxbw {{.*#+}} xmm5 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; AVX1-NEXT:    vpmullw %xmm3, %xmm5, %xmm5
; AVX1-NEXT:    vpsrlw $8, %xmm5, %xmm5
; AVX1-NEXT:    vpshufd {{.*#+}} xmm6 = xmm0[2,3,0,1]
; AVX1-NEXT:    vpmovzxbw {{.*#+}} xmm6 = xmm6[0],zero,xmm6[1],zero,xmm6[2],zero,xmm6[3],zero,xmm6[4],zero,xmm6[5],zero,xmm6[6],zero,xmm6[7],zero
; AVX1-NEXT:    vpmullw %xmm3, %xmm6, %xmm3
; AVX1-NEXT:    vpsrlw $8, %xmm3, %xmm3
; AVX1-NEXT:    vpackuswb %xmm3, %xmm5, %xmm3
; AVX1-NEXT:    vpsubb %xmm3, %xmm0, %xmm0
; AVX1-NEXT:    vpsrlw $1, %xmm0, %xmm0
; AVX1-NEXT:    vpand %xmm4, %xmm0, %xmm0
; AVX1-NEXT:    vpaddb %xmm3, %xmm0, %xmm0
; AVX1-NEXT:    vpsrlw $2, %xmm0, %xmm0
; AVX1-NEXT:    vpand %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test_div7_32i8:
; AVX2:       # BB#0:
; AVX2-NEXT:    vmovdqa {{.*#+}} ymm1 = [37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37]
; AVX2-NEXT:    vextracti128 $1, %ymm1, %xmm2
; AVX2-NEXT:    vpmovzxbw {{.*#+}} ymm2 = xmm2[0],zero,xmm2[1],zero,xmm2[2],zero,xmm2[3],zero,xmm2[4],zero,xmm2[5],zero,xmm2[6],zero,xmm2[7],zero,xmm2[8],zero,xmm2[9],zero,xmm2[10],zero,xmm2[11],zero,xmm2[12],zero,xmm2[13],zero,xmm2[14],zero,xmm2[15],zero
; AVX2-NEXT:    vextracti128 $1, %ymm0, %xmm3
; AVX2-NEXT:    vpmovzxbw {{.*#+}} ymm3 = xmm3[0],zero,xmm3[1],zero,xmm3[2],zero,xmm3[3],zero,xmm3[4],zero,xmm3[5],zero,xmm3[6],zero,xmm3[7],zero,xmm3[8],zero,xmm3[9],zero,xmm3[10],zero,xmm3[11],zero,xmm3[12],zero,xmm3[13],zero,xmm3[14],zero,xmm3[15],zero
; AVX2-NEXT:    vpmullw %ymm2, %ymm3, %ymm2
; AVX2-NEXT:    vpsrlw $8, %ymm2, %ymm2
; AVX2-NEXT:    vpmovzxbw {{.*#+}} ymm1 = xmm1[0],zero,xmm1[1],zero,xmm1[2],zero,xmm1[3],zero,xmm1[4],zero,xmm1[5],zero,xmm1[6],zero,xmm1[7],zero,xmm1[8],zero,xmm1[9],zero,xmm1[10],zero,xmm1[11],zero,xmm1[12],zero,xmm1[13],zero,xmm1[14],zero,xmm1[15],zero
; AVX2-NEXT:    vpmovzxbw {{.*#+}} ymm3 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero,xmm0[8],zero,xmm0[9],zero,xmm0[10],zero,xmm0[11],zero,xmm0[12],zero,xmm0[13],zero,xmm0[14],zero,xmm0[15],zero
; AVX2-NEXT:    vpmullw %ymm1, %ymm3, %ymm1
; AVX2-NEXT:    vpsrlw $8, %ymm1, %ymm1
; AVX2-NEXT:    vperm2i128 {{.*#+}} ymm3 = ymm1[2,3],ymm2[2,3]
; AVX2-NEXT:    vinserti128 $1, %xmm2, %ymm1, %ymm1
; AVX2-NEXT:    vpackuswb %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    vpsubb %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vpsrlw $1, %ymm0, %ymm0
; AVX2-NEXT:    vpand {{.*}}(%rip), %ymm0, %ymm0
; AVX2-NEXT:    vpaddb %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vpsrlw $2, %ymm0, %ymm0
; AVX2-NEXT:    vpand {{.*}}(%rip), %ymm0, %ymm0
; AVX2-NEXT:    retq
  %res = udiv <32 x i8> %a, <i8 7, i8 7, i8 7, i8 7,i8 7, i8 7, i8 7, i8 7, i8 7, i8 7, i8 7, i8 7,i8 7, i8 7, i8 7, i8 7, i8 7, i8 7, i8 7, i8 7,i8 7, i8 7, i8 7, i8 7, i8 7, i8 7, i8 7, i8 7,i8 7, i8 7, i8 7, i8 7>
  ret <32 x i8> %res
}

;
; urem by 7
;

define <4 x i64> @test_rem7_4i64(<4 x i64> %a) nounwind {
; AVX1-LABEL: test_rem7_4i64:
; AVX1:       # BB#0:
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX1-NEXT:    vpextrq $1, %xmm1, %rcx
; AVX1-NEXT:    movabsq $2635249153387078803, %rsi # imm = 0x2492492492492493
; AVX1-NEXT:    movq %rcx, %rax
; AVX1-NEXT:    mulq %rsi
; AVX1-NEXT:    movq %rcx, %rax
; AVX1-NEXT:    subq %rdx, %rax
; AVX1-NEXT:    shrq %rax
; AVX1-NEXT:    addq %rdx, %rax
; AVX1-NEXT:    shrq $2, %rax
; AVX1-NEXT:    leaq (,%rax,8), %rdx
; AVX1-NEXT:    subq %rax, %rdx
; AVX1-NEXT:    subq %rdx, %rcx
; AVX1-NEXT:    vmovq %rcx, %xmm2
; AVX1-NEXT:    vmovq %xmm1, %rcx
; AVX1-NEXT:    movq %rcx, %rax
; AVX1-NEXT:    mulq %rsi
; AVX1-NEXT:    movq %rcx, %rax
; AVX1-NEXT:    subq %rdx, %rax
; AVX1-NEXT:    shrq %rax
; AVX1-NEXT:    addq %rdx, %rax
; AVX1-NEXT:    shrq $2, %rax
; AVX1-NEXT:    leaq (,%rax,8), %rdx
; AVX1-NEXT:    subq %rax, %rdx
; AVX1-NEXT:    subq %rdx, %rcx
; AVX1-NEXT:    vmovq %rcx, %xmm1
; AVX1-NEXT:    vpunpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm2[0]
; AVX1-NEXT:    vpextrq $1, %xmm0, %rcx
; AVX1-NEXT:    movq %rcx, %rax
; AVX1-NEXT:    mulq %rsi
; AVX1-NEXT:    movq %rcx, %rax
; AVX1-NEXT:    subq %rdx, %rax
; AVX1-NEXT:    shrq %rax
; AVX1-NEXT:    addq %rdx, %rax
; AVX1-NEXT:    shrq $2, %rax
; AVX1-NEXT:    leaq (,%rax,8), %rdx
; AVX1-NEXT:    subq %rax, %rdx
; AVX1-NEXT:    subq %rdx, %rcx
; AVX1-NEXT:    vmovq %rcx, %xmm2
; AVX1-NEXT:    vmovq %xmm0, %rcx
; AVX1-NEXT:    movq %rcx, %rax
; AVX1-NEXT:    mulq %rsi
; AVX1-NEXT:    movq %rcx, %rax
; AVX1-NEXT:    subq %rdx, %rax
; AVX1-NEXT:    shrq %rax
; AVX1-NEXT:    addq %rdx, %rax
; AVX1-NEXT:    shrq $2, %rax
; AVX1-NEXT:    leaq (,%rax,8), %rdx
; AVX1-NEXT:    subq %rax, %rdx
; AVX1-NEXT:    subq %rdx, %rcx
; AVX1-NEXT:    vmovq %rcx, %xmm0
; AVX1-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm2[0]
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test_rem7_4i64:
; AVX2:       # BB#0:
; AVX2-NEXT:    vextracti128 $1, %ymm0, %xmm1
; AVX2-NEXT:    vpextrq $1, %xmm1, %rcx
; AVX2-NEXT:    movabsq $2635249153387078803, %rsi # imm = 0x2492492492492493
; AVX2-NEXT:    movq %rcx, %rax
; AVX2-NEXT:    mulq %rsi
; AVX2-NEXT:    movq %rcx, %rax
; AVX2-NEXT:    subq %rdx, %rax
; AVX2-NEXT:    shrq %rax
; AVX2-NEXT:    addq %rdx, %rax
; AVX2-NEXT:    shrq $2, %rax
; AVX2-NEXT:    leaq (,%rax,8), %rdx
; AVX2-NEXT:    subq %rax, %rdx
; AVX2-NEXT:    subq %rdx, %rcx
; AVX2-NEXT:    vmovq %rcx, %xmm2
; AVX2-NEXT:    vmovq %xmm1, %rcx
; AVX2-NEXT:    movq %rcx, %rax
; AVX2-NEXT:    mulq %rsi
; AVX2-NEXT:    movq %rcx, %rax
; AVX2-NEXT:    subq %rdx, %rax
; AVX2-NEXT:    shrq %rax
; AVX2-NEXT:    addq %rdx, %rax
; AVX2-NEXT:    shrq $2, %rax
; AVX2-NEXT:    leaq (,%rax,8), %rdx
; AVX2-NEXT:    subq %rax, %rdx
; AVX2-NEXT:    subq %rdx, %rcx
; AVX2-NEXT:    vmovq %rcx, %xmm1
; AVX2-NEXT:    vpunpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm2[0]
; AVX2-NEXT:    vpextrq $1, %xmm0, %rcx
; AVX2-NEXT:    movq %rcx, %rax
; AVX2-NEXT:    mulq %rsi
; AVX2-NEXT:    movq %rcx, %rax
; AVX2-NEXT:    subq %rdx, %rax
; AVX2-NEXT:    shrq %rax
; AVX2-NEXT:    addq %rdx, %rax
; AVX2-NEXT:    shrq $2, %rax
; AVX2-NEXT:    leaq (,%rax,8), %rdx
; AVX2-NEXT:    subq %rax, %rdx
; AVX2-NEXT:    subq %rdx, %rcx
; AVX2-NEXT:    vmovq %rcx, %xmm2
; AVX2-NEXT:    vmovq %xmm0, %rcx
; AVX2-NEXT:    movq %rcx, %rax
; AVX2-NEXT:    mulq %rsi
; AVX2-NEXT:    movq %rcx, %rax
; AVX2-NEXT:    subq %rdx, %rax
; AVX2-NEXT:    shrq %rax
; AVX2-NEXT:    addq %rdx, %rax
; AVX2-NEXT:    shrq $2, %rax
; AVX2-NEXT:    leaq (,%rax,8), %rdx
; AVX2-NEXT:    subq %rax, %rdx
; AVX2-NEXT:    subq %rdx, %rcx
; AVX2-NEXT:    vmovq %rcx, %xmm0
; AVX2-NEXT:    vpunpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm2[0]
; AVX2-NEXT:    vinserti128 $1, %xmm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
  %res = urem <4 x i64> %a, <i64 7, i64 7, i64 7, i64 7>
  ret <4 x i64> %res
}

define <8 x i32> @test_rem7_8i32(<8 x i32> %a) nounwind {
; AVX1-LABEL: test_rem7_8i32:
; AVX1:       # BB#0:
; AVX1-NEXT:    vmovaps {{.*#+}} ymm1 = [613566757,613566757,613566757,613566757,613566757,613566757,613566757,613566757]
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vpshufd {{.*#+}} xmm3 = xmm2[1,1,3,3]
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm4
; AVX1-NEXT:    vpshufd {{.*#+}} xmm5 = xmm4[1,1,3,3]
; AVX1-NEXT:    vpmuludq %xmm3, %xmm5, %xmm3
; AVX1-NEXT:    vpmuludq %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpshufd {{.*#+}} xmm2 = xmm2[1,1,3,3]
; AVX1-NEXT:    vpblendw {{.*#+}} xmm2 = xmm2[0,1],xmm3[2,3],xmm2[4,5],xmm3[6,7]
; AVX1-NEXT:    vpsubd %xmm2, %xmm4, %xmm3
; AVX1-NEXT:    vpsrld $1, %xmm3, %xmm3
; AVX1-NEXT:    vpaddd %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpsrld $2, %xmm2, %xmm2
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm3 = [7,7,7,7]
; AVX1-NEXT:    vpmulld %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vpsubd %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vpshufd {{.*#+}} xmm4 = xmm1[1,1,3,3]
; AVX1-NEXT:    vpshufd {{.*#+}} xmm5 = xmm0[1,1,3,3]
; AVX1-NEXT:    vpmuludq %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpmuludq %xmm1, %xmm0, %xmm1
; AVX1-NEXT:    vpshufd {{.*#+}} xmm1 = xmm1[1,1,3,3]
; AVX1-NEXT:    vpblendw {{.*#+}} xmm1 = xmm1[0,1],xmm4[2,3],xmm1[4,5],xmm4[6,7]
; AVX1-NEXT:    vpsubd %xmm1, %xmm0, %xmm4
; AVX1-NEXT:    vpsrld $1, %xmm4, %xmm4
; AVX1-NEXT:    vpaddd %xmm1, %xmm4, %xmm1
; AVX1-NEXT:    vpsrld $2, %xmm1, %xmm1
; AVX1-NEXT:    vpmulld %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vpsubd %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test_rem7_8i32:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpbroadcastd {{.*}}(%rip), %ymm1
; AVX2-NEXT:    vpshufd {{.*#+}} ymm2 = ymm1[1,1,3,3,5,5,7,7]
; AVX2-NEXT:    vpshufd {{.*#+}} ymm3 = ymm0[1,1,3,3,5,5,7,7]
; AVX2-NEXT:    vpmuludq %ymm2, %ymm3, %ymm2
; AVX2-NEXT:    vpmuludq %ymm1, %ymm0, %ymm1
; AVX2-NEXT:    vpshufd {{.*#+}} ymm1 = ymm1[1,1,3,3,5,5,7,7]
; AVX2-NEXT:    vpblendd {{.*#+}} ymm1 = ymm1[0],ymm2[1],ymm1[2],ymm2[3],ymm1[4],ymm2[5],ymm1[6],ymm2[7]
; AVX2-NEXT:    vpsubd %ymm1, %ymm0, %ymm2
; AVX2-NEXT:    vpsrld $1, %ymm2, %ymm2
; AVX2-NEXT:    vpaddd %ymm1, %ymm2, %ymm1
; AVX2-NEXT:    vpsrld $2, %ymm1, %ymm1
; AVX2-NEXT:    vpbroadcastd {{.*}}(%rip), %ymm2
; AVX2-NEXT:    vpmulld %ymm2, %ymm1, %ymm1
; AVX2-NEXT:    vpsubd %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
  %res = urem <8 x i32> %a, <i32 7, i32 7, i32 7, i32 7, i32 7, i32 7, i32 7, i32 7>
  ret <8 x i32> %res
}

define <16 x i16> @test_rem7_16i16(<16 x i16> %a) nounwind {
; AVX1-LABEL: test_rem7_16i16:
; AVX1:       # BB#0:
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm2 = [9363,9363,9363,9363,9363,9363,9363,9363]
; AVX1-NEXT:    vpmulhuw %xmm2, %xmm1, %xmm3
; AVX1-NEXT:    vpsubw %xmm3, %xmm1, %xmm4
; AVX1-NEXT:    vpsrlw $1, %xmm4, %xmm4
; AVX1-NEXT:    vpaddw %xmm3, %xmm4, %xmm3
; AVX1-NEXT:    vpsrlw $2, %xmm3, %xmm3
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm4 = [7,7,7,7,7,7,7,7]
; AVX1-NEXT:    vpmullw %xmm4, %xmm3, %xmm3
; AVX1-NEXT:    vpsubw %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vpmulhuw %xmm2, %xmm0, %xmm2
; AVX1-NEXT:    vpsubw %xmm2, %xmm0, %xmm3
; AVX1-NEXT:    vpsrlw $1, %xmm3, %xmm3
; AVX1-NEXT:    vpaddw %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpsrlw $2, %xmm2, %xmm2
; AVX1-NEXT:    vpmullw %xmm4, %xmm2, %xmm2
; AVX1-NEXT:    vpsubw %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test_rem7_16i16:
; AVX2:       # BB#0:
; AVX2-NEXT:    vpmulhuw {{.*}}(%rip), %ymm0, %ymm1
; AVX2-NEXT:    vpsubw %ymm1, %ymm0, %ymm2
; AVX2-NEXT:    vpsrlw $1, %ymm2, %ymm2
; AVX2-NEXT:    vpaddw %ymm1, %ymm2, %ymm1
; AVX2-NEXT:    vpsrlw $2, %ymm1, %ymm1
; AVX2-NEXT:    vpmullw {{.*}}(%rip), %ymm1, %ymm1
; AVX2-NEXT:    vpsubw %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
  %res = urem <16 x i16> %a, <i16 7, i16 7, i16 7, i16 7, i16 7, i16 7, i16 7, i16 7, i16 7, i16 7, i16 7, i16 7, i16 7, i16 7, i16 7, i16 7>
  ret <16 x i16> %res
}

define <32 x i8> @test_rem7_32i8(<32 x i8> %a) nounwind {
; AVX1-LABEL: test_rem7_32i8:
; AVX1:       # BB#0:
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm2
; AVX1-NEXT:    vpmovzxbw {{.*#+}} xmm3 = xmm2[0],zero,xmm2[1],zero,xmm2[2],zero,xmm2[3],zero,xmm2[4],zero,xmm2[5],zero,xmm2[6],zero,xmm2[7],zero
; AVX1-NEXT:    vpmovzxbw {{.*#+}} xmm1 = mem[0],zero,mem[1],zero,mem[2],zero,mem[3],zero,mem[4],zero,mem[5],zero,mem[6],zero,mem[7],zero
; AVX1-NEXT:    vpmullw %xmm1, %xmm3, %xmm3
; AVX1-NEXT:    vpsrlw $8, %xmm3, %xmm3
; AVX1-NEXT:    vpshufd {{.*#+}} xmm4 = xmm2[2,3,0,1]
; AVX1-NEXT:    vpmovzxbw {{.*#+}} xmm4 = xmm4[0],zero,xmm4[1],zero,xmm4[2],zero,xmm4[3],zero,xmm4[4],zero,xmm4[5],zero,xmm4[6],zero,xmm4[7],zero
; AVX1-NEXT:    vpmullw %xmm1, %xmm4, %xmm4
; AVX1-NEXT:    vpsrlw $8, %xmm4, %xmm4
; AVX1-NEXT:    vpackuswb %xmm4, %xmm3, %xmm3
; AVX1-NEXT:    vpsubb %xmm3, %xmm2, %xmm4
; AVX1-NEXT:    vpsrlw $1, %xmm4, %xmm4
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm8 = [127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127]
; AVX1-NEXT:    vpand %xmm8, %xmm4, %xmm4
; AVX1-NEXT:    vpaddb %xmm3, %xmm4, %xmm3
; AVX1-NEXT:    vpsrlw $2, %xmm3, %xmm3
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm4 = [63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63]
; AVX1-NEXT:    vpand %xmm4, %xmm3, %xmm3
; AVX1-NEXT:    vpmovsxbw %xmm3, %xmm6
; AVX1-NEXT:    vpmovsxbw {{.*}}(%rip), %xmm7
; AVX1-NEXT:    vpmullw %xmm7, %xmm6, %xmm6
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm5 = [255,255,255,255,255,255,255,255]
; AVX1-NEXT:    vpand %xmm5, %xmm6, %xmm6
; AVX1-NEXT:    vpshufd {{.*#+}} xmm3 = xmm3[2,3,0,1]
; AVX1-NEXT:    vpmovsxbw %xmm3, %xmm3
; AVX1-NEXT:    vpmullw %xmm7, %xmm3, %xmm3
; AVX1-NEXT:    vpand %xmm5, %xmm3, %xmm3
; AVX1-NEXT:    vpackuswb %xmm3, %xmm6, %xmm3
; AVX1-NEXT:    vpsubb %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vpmovzxbw {{.*#+}} xmm3 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; AVX1-NEXT:    vpmullw %xmm1, %xmm3, %xmm3
; AVX1-NEXT:    vpsrlw $8, %xmm3, %xmm3
; AVX1-NEXT:    vpshufd {{.*#+}} xmm6 = xmm0[2,3,0,1]
; AVX1-NEXT:    vpmovzxbw {{.*#+}} xmm6 = xmm6[0],zero,xmm6[1],zero,xmm6[2],zero,xmm6[3],zero,xmm6[4],zero,xmm6[5],zero,xmm6[6],zero,xmm6[7],zero
; AVX1-NEXT:    vpmullw %xmm1, %xmm6, %xmm1
; AVX1-NEXT:    vpsrlw $8, %xmm1, %xmm1
; AVX1-NEXT:    vpackuswb %xmm1, %xmm3, %xmm1
; AVX1-NEXT:    vpsubb %xmm1, %xmm0, %xmm3
; AVX1-NEXT:    vpsrlw $1, %xmm3, %xmm3
; AVX1-NEXT:    vpand %xmm8, %xmm3, %xmm3
; AVX1-NEXT:    vpaddb %xmm1, %xmm3, %xmm1
; AVX1-NEXT:    vpsrlw $2, %xmm1, %xmm1
; AVX1-NEXT:    vpand %xmm4, %xmm1, %xmm1
; AVX1-NEXT:    vpmovsxbw %xmm1, %xmm3
; AVX1-NEXT:    vpmullw %xmm7, %xmm3, %xmm3
; AVX1-NEXT:    vpand %xmm5, %xmm3, %xmm3
; AVX1-NEXT:    vpshufd {{.*#+}} xmm1 = xmm1[2,3,0,1]
; AVX1-NEXT:    vpmovsxbw %xmm1, %xmm1
; AVX1-NEXT:    vpmullw %xmm7, %xmm1, %xmm1
; AVX1-NEXT:    vpand %xmm5, %xmm1, %xmm1
; AVX1-NEXT:    vpackuswb %xmm1, %xmm3, %xmm1
; AVX1-NEXT:    vpsubb %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test_rem7_32i8:
; AVX2:       # BB#0:
; AVX2-NEXT:    vmovdqa {{.*#+}} ymm1 = [37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37,37]
; AVX2-NEXT:    vextracti128 $1, %ymm1, %xmm2
; AVX2-NEXT:    vpmovzxbw {{.*#+}} ymm2 = xmm2[0],zero,xmm2[1],zero,xmm2[2],zero,xmm2[3],zero,xmm2[4],zero,xmm2[5],zero,xmm2[6],zero,xmm2[7],zero,xmm2[8],zero,xmm2[9],zero,xmm2[10],zero,xmm2[11],zero,xmm2[12],zero,xmm2[13],zero,xmm2[14],zero,xmm2[15],zero
; AVX2-NEXT:    vextracti128 $1, %ymm0, %xmm3
; AVX2-NEXT:    vpmovzxbw {{.*#+}} ymm3 = xmm3[0],zero,xmm3[1],zero,xmm3[2],zero,xmm3[3],zero,xmm3[4],zero,xmm3[5],zero,xmm3[6],zero,xmm3[7],zero,xmm3[8],zero,xmm3[9],zero,xmm3[10],zero,xmm3[11],zero,xmm3[12],zero,xmm3[13],zero,xmm3[14],zero,xmm3[15],zero
; AVX2-NEXT:    vpmullw %ymm2, %ymm3, %ymm2
; AVX2-NEXT:    vpsrlw $8, %ymm2, %ymm2
; AVX2-NEXT:    vpmovzxbw {{.*#+}} ymm1 = xmm1[0],zero,xmm1[1],zero,xmm1[2],zero,xmm1[3],zero,xmm1[4],zero,xmm1[5],zero,xmm1[6],zero,xmm1[7],zero,xmm1[8],zero,xmm1[9],zero,xmm1[10],zero,xmm1[11],zero,xmm1[12],zero,xmm1[13],zero,xmm1[14],zero,xmm1[15],zero
; AVX2-NEXT:    vpmovzxbw {{.*#+}} ymm3 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero,xmm0[8],zero,xmm0[9],zero,xmm0[10],zero,xmm0[11],zero,xmm0[12],zero,xmm0[13],zero,xmm0[14],zero,xmm0[15],zero
; AVX2-NEXT:    vpmullw %ymm1, %ymm3, %ymm1
; AVX2-NEXT:    vpsrlw $8, %ymm1, %ymm1
; AVX2-NEXT:    vperm2i128 {{.*#+}} ymm3 = ymm1[2,3],ymm2[2,3]
; AVX2-NEXT:    vinserti128 $1, %xmm2, %ymm1, %ymm1
; AVX2-NEXT:    vpackuswb %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    vpsubb %ymm1, %ymm0, %ymm2
; AVX2-NEXT:    vpsrlw $1, %ymm2, %ymm2
; AVX2-NEXT:    vpand {{.*}}(%rip), %ymm2, %ymm2
; AVX2-NEXT:    vpaddb %ymm1, %ymm2, %ymm1
; AVX2-NEXT:    vpsrlw $2, %ymm1, %ymm1
; AVX2-NEXT:    vpand {{.*}}(%rip), %ymm1, %ymm1
; AVX2-NEXT:    vextracti128 $1, %ymm1, %xmm2
; AVX2-NEXT:    vpmovsxbw %xmm2, %ymm2
; AVX2-NEXT:    vpmovsxbw {{.*}}(%rip), %ymm3
; AVX2-NEXT:    vpmullw %ymm3, %ymm2, %ymm2
; AVX2-NEXT:    vextracti128 $1, %ymm2, %xmm4
; AVX2-NEXT:    vmovdqa {{.*#+}} xmm5 = <0,2,4,6,8,10,12,14,u,u,u,u,u,u,u,u>
; AVX2-NEXT:    vpshufb %xmm5, %xmm4, %xmm4
; AVX2-NEXT:    vpshufb %xmm5, %xmm2, %xmm2
; AVX2-NEXT:    vpunpcklqdq {{.*#+}} xmm2 = xmm2[0],xmm4[0]
; AVX2-NEXT:    vpmovsxbw %xmm1, %ymm1
; AVX2-NEXT:    vpmullw %ymm3, %ymm1, %ymm1
; AVX2-NEXT:    vextracti128 $1, %ymm1, %xmm3
; AVX2-NEXT:    vpshufb %xmm5, %xmm3, %xmm3
; AVX2-NEXT:    vpshufb %xmm5, %xmm1, %xmm1
; AVX2-NEXT:    vpunpcklqdq {{.*#+}} xmm1 = xmm1[0],xmm3[0]
; AVX2-NEXT:    vinserti128 $1, %xmm2, %ymm1, %ymm1
; AVX2-NEXT:    vpsubb %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    retq
  %res = urem <32 x i8> %a, <i8 7, i8 7, i8 7, i8 7,i8 7, i8 7, i8 7, i8 7, i8 7, i8 7, i8 7, i8 7,i8 7, i8 7, i8 7, i8 7, i8 7, i8 7, i8 7, i8 7,i8 7, i8 7, i8 7, i8 7, i8 7, i8 7, i8 7, i8 7,i8 7, i8 7, i8 7, i8 7>
  ret <32 x i8> %res
}
