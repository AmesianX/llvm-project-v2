; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-apple-darwin -mcpu=core-avx2 -mattr=+avx2 | FileCheck %s --check-prefix=X32
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mcpu=core-avx2 -mattr=+avx2 | FileCheck %s --check-prefix=X64

define <4 x i64> @test_vpaddq(<4 x i64> %i, <4 x i64> %j) nounwind readnone {
; X32-LABEL: test_vpaddq:
; X32:       ## BB#0:
; X32-NEXT:    vpaddq %ymm1, %ymm0, %ymm0
; X32-NEXT:    retl
;
; X64-LABEL: test_vpaddq:
; X64:       ## BB#0:
; X64-NEXT:    vpaddq %ymm1, %ymm0, %ymm0
; X64-NEXT:    retq
  %x = add <4 x i64> %i, %j
  ret <4 x i64> %x
}

define <8 x i32> @test_vpaddd(<8 x i32> %i, <8 x i32> %j) nounwind readnone {
; X32-LABEL: test_vpaddd:
; X32:       ## BB#0:
; X32-NEXT:    vpaddd %ymm1, %ymm0, %ymm0
; X32-NEXT:    retl
;
; X64-LABEL: test_vpaddd:
; X64:       ## BB#0:
; X64-NEXT:    vpaddd %ymm1, %ymm0, %ymm0
; X64-NEXT:    retq
  %x = add <8 x i32> %i, %j
  ret <8 x i32> %x
}

define <16 x i16> @test_vpaddw(<16 x i16> %i, <16 x i16> %j) nounwind readnone {
; X32-LABEL: test_vpaddw:
; X32:       ## BB#0:
; X32-NEXT:    vpaddw %ymm1, %ymm0, %ymm0
; X32-NEXT:    retl
;
; X64-LABEL: test_vpaddw:
; X64:       ## BB#0:
; X64-NEXT:    vpaddw %ymm1, %ymm0, %ymm0
; X64-NEXT:    retq
  %x = add <16 x i16> %i, %j
  ret <16 x i16> %x
}

define <32 x i8> @test_vpaddb(<32 x i8> %i, <32 x i8> %j) nounwind readnone {
; X32-LABEL: test_vpaddb:
; X32:       ## BB#0:
; X32-NEXT:    vpaddb %ymm1, %ymm0, %ymm0
; X32-NEXT:    retl
;
; X64-LABEL: test_vpaddb:
; X64:       ## BB#0:
; X64-NEXT:    vpaddb %ymm1, %ymm0, %ymm0
; X64-NEXT:    retq
  %x = add <32 x i8> %i, %j
  ret <32 x i8> %x
}

define <4 x i64> @test_vpsubq(<4 x i64> %i, <4 x i64> %j) nounwind readnone {
; X32-LABEL: test_vpsubq:
; X32:       ## BB#0:
; X32-NEXT:    vpsubq %ymm1, %ymm0, %ymm0
; X32-NEXT:    retl
;
; X64-LABEL: test_vpsubq:
; X64:       ## BB#0:
; X64-NEXT:    vpsubq %ymm1, %ymm0, %ymm0
; X64-NEXT:    retq
  %x = sub <4 x i64> %i, %j
  ret <4 x i64> %x
}

define <8 x i32> @test_vpsubd(<8 x i32> %i, <8 x i32> %j) nounwind readnone {
; X32-LABEL: test_vpsubd:
; X32:       ## BB#0:
; X32-NEXT:    vpsubd %ymm1, %ymm0, %ymm0
; X32-NEXT:    retl
;
; X64-LABEL: test_vpsubd:
; X64:       ## BB#0:
; X64-NEXT:    vpsubd %ymm1, %ymm0, %ymm0
; X64-NEXT:    retq
  %x = sub <8 x i32> %i, %j
  ret <8 x i32> %x
}

define <16 x i16> @test_vpsubw(<16 x i16> %i, <16 x i16> %j) nounwind readnone {
; X32-LABEL: test_vpsubw:
; X32:       ## BB#0:
; X32-NEXT:    vpsubw %ymm1, %ymm0, %ymm0
; X32-NEXT:    retl
;
; X64-LABEL: test_vpsubw:
; X64:       ## BB#0:
; X64-NEXT:    vpsubw %ymm1, %ymm0, %ymm0
; X64-NEXT:    retq
  %x = sub <16 x i16> %i, %j
  ret <16 x i16> %x
}

define <32 x i8> @test_vpsubb(<32 x i8> %i, <32 x i8> %j) nounwind readnone {
; X32-LABEL: test_vpsubb:
; X32:       ## BB#0:
; X32-NEXT:    vpsubb %ymm1, %ymm0, %ymm0
; X32-NEXT:    retl
;
; X64-LABEL: test_vpsubb:
; X64:       ## BB#0:
; X64-NEXT:    vpsubb %ymm1, %ymm0, %ymm0
; X64-NEXT:    retq
  %x = sub <32 x i8> %i, %j
  ret <32 x i8> %x
}

define <8 x i32> @test_vpmulld(<8 x i32> %i, <8 x i32> %j) nounwind readnone {
; X32-LABEL: test_vpmulld:
; X32:       ## BB#0:
; X32-NEXT:    vpmulld %ymm1, %ymm0, %ymm0
; X32-NEXT:    retl
;
; X64-LABEL: test_vpmulld:
; X64:       ## BB#0:
; X64-NEXT:    vpmulld %ymm1, %ymm0, %ymm0
; X64-NEXT:    retq
  %x = mul <8 x i32> %i, %j
  ret <8 x i32> %x
}

define <16 x i16> @test_vpmullw(<16 x i16> %i, <16 x i16> %j) nounwind readnone {
; X32-LABEL: test_vpmullw:
; X32:       ## BB#0:
; X32-NEXT:    vpmullw %ymm1, %ymm0, %ymm0
; X32-NEXT:    retl
;
; X64-LABEL: test_vpmullw:
; X64:       ## BB#0:
; X64-NEXT:    vpmullw %ymm1, %ymm0, %ymm0
; X64-NEXT:    retq
  %x = mul <16 x i16> %i, %j
  ret <16 x i16> %x
}

define <16 x i8> @mul-v16i8(<16 x i8> %i, <16 x i8> %j) nounwind readnone {
  %x = mul <16 x i8> %i, %j
  ret <16 x i8> %x
}

define <32 x i8> @mul-v32i8(<32 x i8> %i, <32 x i8> %j) nounwind readnone {
  %x = mul <32 x i8> %i, %j
  ret <32 x i8> %x
}

define <4 x i64> @mul-v4i64(<4 x i64> %i, <4 x i64> %j) nounwind readnone {
  %x = mul <4 x i64> %i, %j
  ret <4 x i64> %x
}

define <8 x i32> @mul_const1(<8 x i32> %x) {
; X32-LABEL: mul_const1:
; X32:       ## BB#0:
; X32-NEXT:    vpaddd %ymm0, %ymm0, %ymm0
; X32-NEXT:    retl
;
; X64-LABEL: mul_const1:
; X64:       ## BB#0:
; X64-NEXT:    vpaddd %ymm0, %ymm0, %ymm0
; X64-NEXT:    retq
  %y = mul <8 x i32> %x, <i32 2, i32 2, i32 2, i32 2, i32 2, i32 2, i32 2, i32 2>
  ret <8 x i32> %y
}

define <4 x i64> @mul_const2(<4 x i64> %x) {
; X32-LABEL: mul_const2:
; X32:       ## BB#0:
; X32-NEXT:    vpsllq $2, %ymm0, %ymm0
; X32-NEXT:    retl
;
; X64-LABEL: mul_const2:
; X64:       ## BB#0:
; X64-NEXT:    vpsllq $2, %ymm0, %ymm0
; X64-NEXT:    retq
  %y = mul <4 x i64> %x, <i64 4, i64 4, i64 4, i64 4>
  ret <4 x i64> %y
}

define <16 x i16> @mul_const3(<16 x i16> %x) {
; X32-LABEL: mul_const3:
; X32:       ## BB#0:
; X32-NEXT:    vpsllw $3, %ymm0, %ymm0
; X32-NEXT:    retl
;
; X64-LABEL: mul_const3:
; X64:       ## BB#0:
; X64-NEXT:    vpsllw $3, %ymm0, %ymm0
; X64-NEXT:    retq
  %y = mul <16 x i16> %x, <i16 8, i16 8, i16 8, i16 8, i16 8, i16 8, i16 8, i16 8, i16 8, i16 8, i16 8, i16 8, i16 8, i16 8, i16 8, i16 8>
  ret <16 x i16> %y
}

define <4 x i64> @mul_const4(<4 x i64> %x) {
; X32-LABEL: mul_const4:
; X32:       ## BB#0:
; X32-NEXT:    vpxor %ymm1, %ymm1, %ymm1
; X32-NEXT:    vpsubq %ymm0, %ymm1, %ymm0
; X32-NEXT:    retl
;
; X64-LABEL: mul_const4:
; X64:       ## BB#0:
; X64-NEXT:    vpxor %ymm1, %ymm1, %ymm1
; X64-NEXT:    vpsubq %ymm0, %ymm1, %ymm0
; X64-NEXT:    retq
  %y = mul <4 x i64> %x, <i64 -1, i64 -1, i64 -1, i64 -1>
  ret <4 x i64> %y
}

define <8 x i32> @mul_const5(<8 x i32> %x) {
; X32-LABEL: mul_const5:
; X32:       ## BB#0:
; X32-NEXT:    vxorps %ymm0, %ymm0, %ymm0
; X32-NEXT:    retl
;
; X64-LABEL: mul_const5:
; X64:       ## BB#0:
; X64-NEXT:    vxorps %ymm0, %ymm0, %ymm0
; X64-NEXT:    retq
  %y = mul <8 x i32> %x, <i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0>
  ret <8 x i32> %y
}

define <8 x i32> @mul_const6(<8 x i32> %x) {
; X32-LABEL: mul_const6:
; X32:       ## BB#0:
; X32-NEXT:    vpmulld LCPI18_0, %ymm0, %ymm0
; X32-NEXT:    retl
;
; X64-LABEL: mul_const6:
; X64:       ## BB#0:
; X64-NEXT:    vpmulld {{.*}}(%rip), %ymm0, %ymm0
; X64-NEXT:    retq
  %y = mul <8 x i32> %x, <i32 0, i32 0, i32 0, i32 2, i32 0, i32 2, i32 0, i32 0>
  ret <8 x i32> %y
}

define <8 x i64> @mul_const7(<8 x i64> %x) {
; X32-LABEL: mul_const7:
; X32:       ## BB#0:
; X32-NEXT:    vpaddq %ymm0, %ymm0, %ymm0
; X32-NEXT:    vpaddq %ymm1, %ymm1, %ymm1
; X32-NEXT:    retl
;
; X64-LABEL: mul_const7:
; X64:       ## BB#0:
; X64-NEXT:    vpaddq %ymm0, %ymm0, %ymm0
; X64-NEXT:    vpaddq %ymm1, %ymm1, %ymm1
; X64-NEXT:    retq
  %y = mul <8 x i64> %x, <i64 2, i64 2, i64 2, i64 2, i64 2, i64 2, i64 2, i64 2>
  ret <8 x i64> %y
}

define <8 x i16> @mul_const8(<8 x i16> %x) {
; X32-LABEL: mul_const8:
; X32:       ## BB#0:
; X32-NEXT:    vpsllw $3, %xmm0, %xmm0
; X32-NEXT:    retl
;
; X64-LABEL: mul_const8:
; X64:       ## BB#0:
; X64-NEXT:    vpsllw $3, %xmm0, %xmm0
; X64-NEXT:    retq
  %y = mul <8 x i16> %x, <i16 8, i16 8, i16 8, i16 8, i16 8, i16 8, i16 8, i16 8>
  ret <8 x i16> %y
}

define <8 x i32> @mul_const9(<8 x i32> %x) {
; X32-LABEL: mul_const9:
; X32:       ## BB#0:
; X32-NEXT:    movl $2, %eax
; X32-NEXT:    vmovd %eax, %xmm1
; X32-NEXT:    vpmulld %ymm1, %ymm0, %ymm0
; X32-NEXT:    retl
;
; X64-LABEL: mul_const9:
; X64:       ## BB#0:
; X64-NEXT:    movl $2, %eax
; X64-NEXT:    vmovd %eax, %xmm1
; X64-NEXT:    vpmulld %ymm1, %ymm0, %ymm0
; X64-NEXT:    retq
  %y = mul <8 x i32> %x, <i32 2, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0>
  ret <8 x i32> %y
}

define <4 x i32> @mul_const10(<4 x i32> %x) {
  ; %x * 0x01010101
; X32-LABEL: mul_const10:
; X32:       ## BB#0:
; X32-NEXT:    vpbroadcastd LCPI22_0, %xmm1
; X32-NEXT:    vpmulld %xmm1, %xmm0, %xmm0
; X32-NEXT:    retl
;
; X64-LABEL: mul_const10:
; X64:       ## BB#0:
; X64-NEXT:    vpbroadcastd {{.*}}(%rip), %xmm1
; X64-NEXT:    vpmulld %xmm1, %xmm0, %xmm0
; X64-NEXT:    retq
  %m = mul <4 x i32> %x, <i32 16843009, i32 16843009, i32 16843009, i32 16843009>
  ret <4 x i32> %m
}

define <4 x i32> @mul_const11(<4 x i32> %x) {
  ; %x * 0x80808080
; X32-LABEL: mul_const11:
; X32:       ## BB#0:
; X32-NEXT:    vpbroadcastd LCPI23_0, %xmm1
; X32-NEXT:    vpmulld %xmm1, %xmm0, %xmm0
; X32-NEXT:    retl
;
; X64-LABEL: mul_const11:
; X64:       ## BB#0:
; X64-NEXT:    vpbroadcastd {{.*}}(%rip), %xmm1
; X64-NEXT:    vpmulld %xmm1, %xmm0, %xmm0
; X64-NEXT:    retq
  %m = mul <4 x i32> %x, <i32 2155905152, i32 2155905152, i32 2155905152, i32 2155905152>
  ret <4 x i32> %m
}
