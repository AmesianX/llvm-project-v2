; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -fast-isel -mtriple=i686-unknown-unknown -mattr=+avx,+fma4,+xop | FileCheck %s --check-prefix=ALL --check-prefix=X32
; RUN: llc < %s -fast-isel -mtriple=x86_64-unknown-unknown -mattr=+avx,+fma4,+xop | FileCheck %s --check-prefix=ALL --check-prefix=X64

; NOTE: This should use IR equivalent to what is generated by clang/test/CodeGen/xop-builtins.c

define <2 x i64> @test_mm_maccs_epi16(<2 x i64> %a0, <2 x i64> %a1, <2 x i64> %a2) nounwind {
; ALL-LABEL: test_mm_maccs_epi16:
; ALL:       # %bb.0:
; ALL-NEXT:    vpmacssww %xmm2, %xmm1, %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <8 x i16>
  %arg1 = bitcast <2 x i64> %a1 to <8 x i16>
  %arg2 = bitcast <2 x i64> %a2 to <8 x i16>
  %res = call <8 x i16> @llvm.x86.xop.vpmacssww(<8 x i16> %arg0, <8 x i16> %arg1, <8 x i16> %arg2)
  %bc = bitcast <8 x i16> %res to <2 x i64>
  ret <2 x i64> %bc
}
declare <8 x i16> @llvm.x86.xop.vpmacssww(<8 x i16>, <8 x i16>, <8 x i16>) nounwind readnone

define <2 x i64> @test_mm_macc_epi16(<2 x i64> %a0, <2 x i64> %a1, <2 x i64> %a2) nounwind {
; ALL-LABEL: test_mm_macc_epi16:
; ALL:       # %bb.0:
; ALL-NEXT:    vpmacsww %xmm2, %xmm1, %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <8 x i16>
  %arg1 = bitcast <2 x i64> %a1 to <8 x i16>
  %arg2 = bitcast <2 x i64> %a2 to <8 x i16>
  %res = call <8 x i16> @llvm.x86.xop.vpmacsww(<8 x i16> %arg0, <8 x i16> %arg1, <8 x i16> %arg2)
  %bc = bitcast <8 x i16> %res to <2 x i64>
  ret <2 x i64> %bc
}
declare <8 x i16> @llvm.x86.xop.vpmacsww(<8 x i16>, <8 x i16>, <8 x i16>) nounwind readnone

define <2 x i64> @test_mm_maccsd_epi16(<2 x i64> %a0, <2 x i64> %a1, <2 x i64> %a2) nounwind {
; ALL-LABEL: test_mm_maccsd_epi16:
; ALL:       # %bb.0:
; ALL-NEXT:    vpmacsswd %xmm2, %xmm1, %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <8 x i16>
  %arg1 = bitcast <2 x i64> %a1 to <8 x i16>
  %arg2 = bitcast <2 x i64> %a2 to <4 x i32>
  %res = call <4 x i32> @llvm.x86.xop.vpmacsswd(<8 x i16> %arg0, <8 x i16> %arg1, <4 x i32> %arg2)
  %bc = bitcast <4 x i32> %res to <2 x i64>
  ret <2 x i64> %bc
}
declare <4 x i32> @llvm.x86.xop.vpmacsswd(<8 x i16>, <8 x i16>, <4 x i32>) nounwind readnone

define <2 x i64> @test_mm_maccd_epi16(<2 x i64> %a0, <2 x i64> %a1, <2 x i64> %a2) nounwind {
; ALL-LABEL: test_mm_maccd_epi16:
; ALL:       # %bb.0:
; ALL-NEXT:    vpmacswd %xmm2, %xmm1, %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <8 x i16>
  %arg1 = bitcast <2 x i64> %a1 to <8 x i16>
  %arg2 = bitcast <2 x i64> %a2 to <4 x i32>
  %res = call <4 x i32> @llvm.x86.xop.vpmacswd(<8 x i16> %arg0, <8 x i16> %arg1, <4 x i32> %arg2)
  %bc = bitcast <4 x i32> %res to <2 x i64>
  ret <2 x i64> %bc
}
declare <4 x i32> @llvm.x86.xop.vpmacswd(<8 x i16>, <8 x i16>, <4 x i32>) nounwind readnone

define <2 x i64> @test_mm_maccs_epi32(<2 x i64> %a0, <2 x i64> %a1, <2 x i64> %a2) nounwind {
; ALL-LABEL: test_mm_maccs_epi32:
; ALL:       # %bb.0:
; ALL-NEXT:    vpmacssdd %xmm2, %xmm1, %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <4 x i32>
  %arg1 = bitcast <2 x i64> %a1 to <4 x i32>
  %arg2 = bitcast <2 x i64> %a2 to <4 x i32>
  %res = call <4 x i32> @llvm.x86.xop.vpmacssdd(<4 x i32> %arg0, <4 x i32> %arg1, <4 x i32> %arg2)
  %bc = bitcast <4 x i32> %res to <2 x i64>
  ret <2 x i64> %bc
}
declare <4 x i32> @llvm.x86.xop.vpmacssdd(<4 x i32>, <4 x i32>, <4 x i32>) nounwind readnone

define <2 x i64> @test_mm_macc_epi32(<2 x i64> %a0, <2 x i64> %a1, <2 x i64> %a2) nounwind {
; ALL-LABEL: test_mm_macc_epi32:
; ALL:       # %bb.0:
; ALL-NEXT:    vpmacsdd %xmm2, %xmm1, %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <4 x i32>
  %arg1 = bitcast <2 x i64> %a1 to <4 x i32>
  %arg2 = bitcast <2 x i64> %a2 to <4 x i32>
  %res = call <4 x i32> @llvm.x86.xop.vpmacsdd(<4 x i32> %arg0, <4 x i32> %arg1, <4 x i32> %arg2)
  %bc = bitcast <4 x i32> %res to <2 x i64>
  ret <2 x i64> %bc
}
declare <4 x i32> @llvm.x86.xop.vpmacsdd(<4 x i32>, <4 x i32>, <4 x i32>) nounwind readnone

define <2 x i64> @test_mm_maccslo_epi32(<2 x i64> %a0, <2 x i64> %a1, <2 x i64> %a2) nounwind {
; ALL-LABEL: test_mm_maccslo_epi32:
; ALL:       # %bb.0:
; ALL-NEXT:    vpmacssdql %xmm2, %xmm1, %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <4 x i32>
  %arg1 = bitcast <2 x i64> %a1 to <4 x i32>
  %res = call <2 x i64> @llvm.x86.xop.vpmacssdql(<4 x i32> %arg0, <4 x i32> %arg1, <2 x i64> %a2)
  ret <2 x i64> %res
}
declare <2 x i64> @llvm.x86.xop.vpmacssdql(<4 x i32>, <4 x i32>, <2 x i64>) nounwind readnone

define <2 x i64> @test_mm_macclo_epi32(<2 x i64> %a0, <2 x i64> %a1, <2 x i64> %a2) nounwind {
; ALL-LABEL: test_mm_macclo_epi32:
; ALL:       # %bb.0:
; ALL-NEXT:    vpmacsdql %xmm2, %xmm1, %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <4 x i32>
  %arg1 = bitcast <2 x i64> %a1 to <4 x i32>
  %res = call <2 x i64> @llvm.x86.xop.vpmacsdql(<4 x i32> %arg0, <4 x i32> %arg1, <2 x i64> %a2)
  ret <2 x i64> %res
}
declare <2 x i64> @llvm.x86.xop.vpmacsdql(<4 x i32>, <4 x i32>, <2 x i64>) nounwind readnone

define <2 x i64> @test_mm_maccshi_epi32(<2 x i64> %a0, <2 x i64> %a1, <2 x i64> %a2) nounwind {
; ALL-LABEL: test_mm_maccshi_epi32:
; ALL:       # %bb.0:
; ALL-NEXT:    vpmacssdqh %xmm2, %xmm1, %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <4 x i32>
  %arg1 = bitcast <2 x i64> %a1 to <4 x i32>
  %res = call <2 x i64> @llvm.x86.xop.vpmacssdqh(<4 x i32> %arg0, <4 x i32> %arg1, <2 x i64> %a2)
  ret <2 x i64> %res
}
declare <2 x i64> @llvm.x86.xop.vpmacssdqh(<4 x i32>, <4 x i32>, <2 x i64>) nounwind readnone

define <2 x i64> @test_mm_macchi_epi32(<2 x i64> %a0, <2 x i64> %a1, <2 x i64> %a2) nounwind {
; ALL-LABEL: test_mm_macchi_epi32:
; ALL:       # %bb.0:
; ALL-NEXT:    vpmacsdqh %xmm2, %xmm1, %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <4 x i32>
  %arg1 = bitcast <2 x i64> %a1 to <4 x i32>
  %res = call <2 x i64> @llvm.x86.xop.vpmacsdqh(<4 x i32> %arg0, <4 x i32> %arg1, <2 x i64> %a2)
  ret <2 x i64> %res
}
declare <2 x i64> @llvm.x86.xop.vpmacsdqh(<4 x i32>, <4 x i32>, <2 x i64>) nounwind readnone

define <2 x i64> @test_mm_maddsd_epi16(<2 x i64> %a0, <2 x i64> %a1, <2 x i64> %a2) nounwind {
; ALL-LABEL: test_mm_maddsd_epi16:
; ALL:       # %bb.0:
; ALL-NEXT:    vpmadcsswd %xmm2, %xmm1, %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <8 x i16>
  %arg1 = bitcast <2 x i64> %a1 to <8 x i16>
  %arg2 = bitcast <2 x i64> %a2 to <4 x i32>
  %res = call <4 x i32> @llvm.x86.xop.vpmadcsswd(<8 x i16> %arg0, <8 x i16> %arg1, <4 x i32> %arg2)
  %bc = bitcast <4 x i32> %res to <2 x i64>
  ret <2 x i64> %bc
}
declare <4 x i32> @llvm.x86.xop.vpmadcsswd(<8 x i16>, <8 x i16>, <4 x i32>) nounwind readnone

define <2 x i64> @test_mm_maddd_epi16(<2 x i64> %a0, <2 x i64> %a1, <2 x i64> %a2) nounwind {
; ALL-LABEL: test_mm_maddd_epi16:
; ALL:       # %bb.0:
; ALL-NEXT:    vpmadcswd %xmm2, %xmm1, %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <8 x i16>
  %arg1 = bitcast <2 x i64> %a1 to <8 x i16>
  %arg2 = bitcast <2 x i64> %a2 to <4 x i32>
  %res = call <4 x i32> @llvm.x86.xop.vpmadcswd(<8 x i16> %arg0, <8 x i16> %arg1, <4 x i32> %arg2)
  %bc = bitcast <4 x i32> %res to <2 x i64>
  ret <2 x i64> %bc
}
declare <4 x i32> @llvm.x86.xop.vpmadcswd(<8 x i16>, <8 x i16>, <4 x i32>) nounwind readnone

define <2 x i64> @test_mm_haddw_epi8(<2 x i64> %a0) {
; ALL-LABEL: test_mm_haddw_epi8:
; ALL:       # %bb.0:
; ALL-NEXT:    vphaddbw %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <16 x i8>
  %res = call <8 x i16> @llvm.x86.xop.vphaddbw(<16 x i8> %arg0)
  %bc = bitcast <8 x i16> %res to <2 x i64>
  ret <2 x i64> %bc
}
declare <8 x i16> @llvm.x86.xop.vphaddbw(<16 x i8>) nounwind readnone

define <2 x i64> @test_mm_haddd_epi8(<2 x i64> %a0) {
; ALL-LABEL: test_mm_haddd_epi8:
; ALL:       # %bb.0:
; ALL-NEXT:    vphaddbd %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <16 x i8>
  %res = call <4 x i32> @llvm.x86.xop.vphaddbd(<16 x i8> %arg0)
  %bc = bitcast <4 x i32> %res to <2 x i64>
  ret <2 x i64> %bc
}
declare <4 x i32> @llvm.x86.xop.vphaddbd(<16 x i8>) nounwind readnone

define <2 x i64> @test_mm_haddq_epi8(<2 x i64> %a0) {
; ALL-LABEL: test_mm_haddq_epi8:
; ALL:       # %bb.0:
; ALL-NEXT:    vphaddbq %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <16 x i8>
  %res = call <2 x i64> @llvm.x86.xop.vphaddbq(<16 x i8> %arg0)
  ret <2 x i64> %res
}
declare <2 x i64> @llvm.x86.xop.vphaddbq(<16 x i8>) nounwind readnone

define <2 x i64> @test_mm_haddd_epi16(<2 x i64> %a0) {
; ALL-LABEL: test_mm_haddd_epi16:
; ALL:       # %bb.0:
; ALL-NEXT:    vphaddwd %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <8 x i16>
  %res = call <4 x i32> @llvm.x86.xop.vphaddwd(<8 x i16> %arg0)
  %bc = bitcast <4 x i32> %res to <2 x i64>
  ret <2 x i64> %bc
}
declare <4 x i32> @llvm.x86.xop.vphaddwd(<8 x i16>) nounwind readnone

define <2 x i64> @test_mm_haddq_epi16(<2 x i64> %a0) {
; ALL-LABEL: test_mm_haddq_epi16:
; ALL:       # %bb.0:
; ALL-NEXT:    vphaddwq %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <8 x i16>
  %res = call <2 x i64> @llvm.x86.xop.vphaddwq(<8 x i16> %arg0)
  ret <2 x i64> %res
}
declare <2 x i64> @llvm.x86.xop.vphaddwq(<8 x i16>) nounwind readnone

define <2 x i64> @test_mm_haddq_epi32(<2 x i64> %a0) {
; ALL-LABEL: test_mm_haddq_epi32:
; ALL:       # %bb.0:
; ALL-NEXT:    vphadddq %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <4 x i32>
  %res = call <2 x i64> @llvm.x86.xop.vphadddq(<4 x i32> %arg0)
  ret <2 x i64> %res
}
declare <2 x i64> @llvm.x86.xop.vphadddq(<4 x i32>) nounwind readnone

define <2 x i64> @test_mm_haddw_epu8(<2 x i64> %a0) {
; ALL-LABEL: test_mm_haddw_epu8:
; ALL:       # %bb.0:
; ALL-NEXT:    vphaddubw %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <16 x i8>
  %res = call <8 x i16> @llvm.x86.xop.vphaddubw(<16 x i8> %arg0)
  %bc = bitcast <8 x i16> %res to <2 x i64>
  ret <2 x i64> %bc
}
declare <8 x i16> @llvm.x86.xop.vphaddubw(<16 x i8>) nounwind readnone

define <2 x i64> @test_mm_haddd_epu8(<2 x i64> %a0) {
; ALL-LABEL: test_mm_haddd_epu8:
; ALL:       # %bb.0:
; ALL-NEXT:    vphaddubd %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <16 x i8>
  %res = call <4 x i32> @llvm.x86.xop.vphaddubd(<16 x i8> %arg0)
  %bc = bitcast <4 x i32> %res to <2 x i64>
  ret <2 x i64> %bc
}
declare <4 x i32> @llvm.x86.xop.vphaddubd(<16 x i8>) nounwind readnone

define <2 x i64> @test_mm_haddq_epu8(<2 x i64> %a0) {
; ALL-LABEL: test_mm_haddq_epu8:
; ALL:       # %bb.0:
; ALL-NEXT:    vphaddubq %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <16 x i8>
  %res = call <2 x i64> @llvm.x86.xop.vphaddubq(<16 x i8> %arg0)
  ret <2 x i64> %res
}
declare <2 x i64> @llvm.x86.xop.vphaddubq(<16 x i8>) nounwind readnone

define <2 x i64> @test_mm_haddd_epu16(<2 x i64> %a0) {
; ALL-LABEL: test_mm_haddd_epu16:
; ALL:       # %bb.0:
; ALL-NEXT:    vphadduwd %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <8 x i16>
  %res = call <4 x i32> @llvm.x86.xop.vphadduwd(<8 x i16> %arg0)
  %bc = bitcast <4 x i32> %res to <2 x i64>
  ret <2 x i64> %bc
}
declare <4 x i32> @llvm.x86.xop.vphadduwd(<8 x i16>) nounwind readnone


define <2 x i64> @test_mm_haddq_epu16(<2 x i64> %a0) {
; ALL-LABEL: test_mm_haddq_epu16:
; ALL:       # %bb.0:
; ALL-NEXT:    vphadduwq %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <8 x i16>
  %res = call <2 x i64> @llvm.x86.xop.vphadduwq(<8 x i16> %arg0)
  ret <2 x i64> %res
}
declare <2 x i64> @llvm.x86.xop.vphadduwq(<8 x i16>) nounwind readnone

define <2 x i64> @test_mm_haddq_epu32(<2 x i64> %a0) {
; ALL-LABEL: test_mm_haddq_epu32:
; ALL:       # %bb.0:
; ALL-NEXT:    vphaddudq %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <4 x i32>
  %res = call <2 x i64> @llvm.x86.xop.vphaddudq(<4 x i32> %arg0)
  ret <2 x i64> %res
}
declare <2 x i64> @llvm.x86.xop.vphaddudq(<4 x i32>) nounwind readnone

define <2 x i64> @test_mm_hsubw_epi8(<2 x i64> %a0) {
; ALL-LABEL: test_mm_hsubw_epi8:
; ALL:       # %bb.0:
; ALL-NEXT:    vphsubbw %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <16 x i8>
  %res = call <8 x i16> @llvm.x86.xop.vphsubbw(<16 x i8> %arg0)
  %bc = bitcast <8 x i16> %res to <2 x i64>
  ret <2 x i64> %bc
}
declare <8 x i16> @llvm.x86.xop.vphsubbw(<16 x i8>) nounwind readnone

define <2 x i64> @test_mm_hsubd_epi16(<2 x i64> %a0) {
; ALL-LABEL: test_mm_hsubd_epi16:
; ALL:       # %bb.0:
; ALL-NEXT:    vphsubwd %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <8 x i16>
  %res = call <4 x i32> @llvm.x86.xop.vphsubwd(<8 x i16> %arg0)
  %bc = bitcast <4 x i32> %res to <2 x i64>
  ret <2 x i64> %bc
}
declare <4 x i32> @llvm.x86.xop.vphsubwd(<8 x i16>) nounwind readnone

define <2 x i64> @test_mm_hsubq_epi32(<2 x i64> %a0) {
; ALL-LABEL: test_mm_hsubq_epi32:
; ALL:       # %bb.0:
; ALL-NEXT:    vphsubdq %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <4 x i32>
  %res = call <2 x i64> @llvm.x86.xop.vphsubdq(<4 x i32> %arg0)
  ret <2 x i64> %res
}
declare <2 x i64> @llvm.x86.xop.vphsubdq(<4 x i32>) nounwind readnone

define <2 x i64> @test_mm_cmov_si128(<2 x i64> %a0, <2 x i64> %a1, <2 x i64> %a2) {
; ALL-LABEL: test_mm_cmov_si128:
; ALL:       # %bb.0:
; ALL-NEXT:    vpcmpeqd %xmm3, %xmm3, %xmm3
; ALL-NEXT:    vpxor %xmm3, %xmm2, %xmm3
; ALL-NEXT:    vpand %xmm2, %xmm0, %xmm0
; ALL-NEXT:    vpand %xmm3, %xmm1, %xmm1
; ALL-NEXT:    vpor %xmm1, %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %res = call <2 x i64> @llvm.x86.xop.vpcmov(<2 x i64> %a0, <2 x i64> %a1, <2 x i64> %a2)
  ret <2 x i64> %res
}
declare <2 x i64> @llvm.x86.xop.vpcmov(<2 x i64>, <2 x i64>, <2 x i64>) nounwind readnone

define <4 x i64> @test_mm256_cmov_si256(<4 x i64> %a0, <4 x i64> %a1, <4 x i64> %a2) {
; ALL-LABEL: test_mm256_cmov_si256:
; ALL:       # %bb.0:
; ALL-NEXT:    vxorps %xmm3, %xmm3, %xmm3
; ALL-NEXT:    vcmptrueps %ymm3, %ymm3, %ymm3
; ALL-NEXT:    vxorps %ymm3, %ymm2, %ymm3
; ALL-NEXT:    vandps %ymm2, %ymm0, %ymm0
; ALL-NEXT:    vandps %ymm3, %ymm1, %ymm1
; ALL-NEXT:    vorps %ymm1, %ymm0, %ymm0
; ALL-NEXT:    ret{{[l|q]}}
  %res = call <4 x i64> @llvm.x86.xop.vpcmov.256(<4 x i64> %a0, <4 x i64> %a1, <4 x i64> %a2)
  ret <4 x i64> %res
}
declare <4 x i64> @llvm.x86.xop.vpcmov.256(<4 x i64>, <4 x i64>, <4 x i64>) nounwind readnone

define <2 x i64> @test_mm_perm_epi8(<2 x i64> %a0, <2 x i64> %a1, <2 x i64> %a2) {
; ALL-LABEL: test_mm_perm_epi8:
; ALL:       # %bb.0:
; ALL-NEXT:    vpperm %xmm2, %xmm1, %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <16 x i8>
  %arg1 = bitcast <2 x i64> %a1 to <16 x i8>
  %arg2 = bitcast <2 x i64> %a2 to <16 x i8>
  %res = call <16 x i8> @llvm.x86.xop.vpperm(<16 x i8> %arg0, <16 x i8> %arg1, <16 x i8> %arg2)
  %bc = bitcast <16 x i8> %res to <2 x i64>
  ret <2 x i64> %bc
}
declare <16 x i8> @llvm.x86.xop.vpperm(<16 x i8>, <16 x i8>, <16 x i8>) nounwind readnone

define <2 x i64> @test_mm_rot_epi8(<2 x i64> %a0, <2 x i64> %a1) {
; ALL-LABEL: test_mm_rot_epi8:
; ALL:       # %bb.0:
; ALL-NEXT:    vprotb %xmm1, %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <16 x i8>
  %arg1 = bitcast <2 x i64> %a1 to <16 x i8>
  %res = call <16 x i8> @llvm.x86.xop.vprotb(<16 x i8> %arg0, <16 x i8> %arg1)
  %bc = bitcast <16 x i8> %res to <2 x i64>
  ret <2 x i64> %bc
}
declare <16 x i8> @llvm.x86.xop.vprotb(<16 x i8>, <16 x i8>) nounwind readnone

define <2 x i64> @test_mm_rot_epi16(<2 x i64> %a0, <2 x i64> %a1) {
; ALL-LABEL: test_mm_rot_epi16:
; ALL:       # %bb.0:
; ALL-NEXT:    vprotw %xmm1, %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <8 x i16>
  %arg1 = bitcast <2 x i64> %a1 to <8 x i16>
  %res = call <8 x i16> @llvm.x86.xop.vprotw(<8 x i16> %arg0, <8 x i16> %arg1)
  %bc = bitcast <8 x i16> %res to <2 x i64>
  ret <2 x i64> %bc
}
declare <8 x i16> @llvm.x86.xop.vprotw(<8 x i16>, <8 x i16>) nounwind readnone

define <2 x i64> @test_mm_rot_epi32(<2 x i64> %a0, <2 x i64> %a1) {
; ALL-LABEL: test_mm_rot_epi32:
; ALL:       # %bb.0:
; ALL-NEXT:    vprotd %xmm1, %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <4 x i32>
  %arg1 = bitcast <2 x i64> %a1 to <4 x i32>
  %res = call <4 x i32> @llvm.x86.xop.vprotd(<4 x i32> %arg0, <4 x i32> %arg1)
  %bc = bitcast <4 x i32> %res to <2 x i64>
  ret <2 x i64> %bc
}
declare <4 x i32> @llvm.x86.xop.vprotd(<4 x i32>, <4 x i32>) nounwind readnone

define <2 x i64> @test_mm_rot_epi64(<2 x i64> %a0, <2 x i64> %a1) {
; ALL-LABEL: test_mm_rot_epi64:
; ALL:       # %bb.0:
; ALL-NEXT:    vprotq %xmm1, %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %res = call <2 x i64> @llvm.x86.xop.vprotq(<2 x i64> %a0, <2 x i64> %a1)
  ret <2 x i64> %res
}
declare <2 x i64> @llvm.x86.xop.vprotq(<2 x i64>, <2 x i64>) nounwind readnone

define <2 x i64> @test_mm_roti_epi8(<2 x i64> %a0) {
; ALL-LABEL: test_mm_roti_epi8:
; ALL:       # %bb.0:
; ALL-NEXT:    vprotb $1, %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <16 x i8>
  %res = call <16 x i8> @llvm.x86.xop.vprotbi(<16 x i8> %arg0, i8 1)
  %bc = bitcast <16 x i8> %res to <2 x i64>
  ret <2 x i64> %bc
}
declare <16 x i8> @llvm.x86.xop.vprotbi(<16 x i8>, i8) nounwind readnone

define <2 x i64> @test_mm_roti_epi16(<2 x i64> %a0) {
; ALL-LABEL: test_mm_roti_epi16:
; ALL:       # %bb.0:
; ALL-NEXT:    vprotw $50, %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <8 x i16>
  %res = call <8 x i16> @llvm.x86.xop.vprotwi(<8 x i16> %arg0, i8 50)
  %bc = bitcast <8 x i16> %res to <2 x i64>
  ret <2 x i64> %bc
}
declare <8 x i16> @llvm.x86.xop.vprotwi(<8 x i16>, i8) nounwind readnone

define <2 x i64> @test_mm_roti_epi32(<2 x i64> %a0) {
; ALL-LABEL: test_mm_roti_epi32:
; ALL:       # %bb.0:
; ALL-NEXT:    vprotd $226, %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <4 x i32>
  %res = call <4 x i32> @llvm.x86.xop.vprotdi(<4 x i32> %arg0, i8 -30)
  %bc = bitcast <4 x i32> %res to <2 x i64>
  ret <2 x i64> %bc
}
declare <4 x i32> @llvm.x86.xop.vprotdi(<4 x i32>, i8) nounwind readnone

define <2 x i64> @test_mm_roti_epi64(<2 x i64> %a0) {
; ALL-LABEL: test_mm_roti_epi64:
; ALL:       # %bb.0:
; ALL-NEXT:    vprotq $100, %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %res = call <2 x i64> @llvm.x86.xop.vprotqi(<2 x i64> %a0, i8 100)
  ret <2 x i64> %res
}
declare <2 x i64> @llvm.x86.xop.vprotqi(<2 x i64>, i8) nounwind readnone

define <2 x i64> @test_mm_shl_epi8(<2 x i64> %a0, <2 x i64> %a1) {
; ALL-LABEL: test_mm_shl_epi8:
; ALL:       # %bb.0:
; ALL-NEXT:    vpshlb %xmm1, %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <16 x i8>
  %arg1 = bitcast <2 x i64> %a1 to <16 x i8>
  %res = call <16 x i8> @llvm.x86.xop.vpshlb(<16 x i8> %arg0, <16 x i8> %arg1)
  %bc = bitcast <16 x i8> %res to <2 x i64>
  ret <2 x i64> %bc
}
declare <16 x i8> @llvm.x86.xop.vpshlb(<16 x i8>, <16 x i8>) nounwind readnone

define <2 x i64> @test_mm_shl_epi16(<2 x i64> %a0, <2 x i64> %a1) {
; ALL-LABEL: test_mm_shl_epi16:
; ALL:       # %bb.0:
; ALL-NEXT:    vpshlw %xmm1, %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <8 x i16>
  %arg1 = bitcast <2 x i64> %a1 to <8 x i16>
  %res = call <8 x i16> @llvm.x86.xop.vpshlw(<8 x i16> %arg0, <8 x i16> %arg1)
  %bc = bitcast <8 x i16> %res to <2 x i64>
  ret <2 x i64> %bc
}
declare <8 x i16> @llvm.x86.xop.vpshlw(<8 x i16>, <8 x i16>) nounwind readnone

define <2 x i64> @test_mm_shl_epi32(<2 x i64> %a0, <2 x i64> %a1) {
; ALL-LABEL: test_mm_shl_epi32:
; ALL:       # %bb.0:
; ALL-NEXT:    vpshld %xmm1, %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <4 x i32>
  %arg1 = bitcast <2 x i64> %a1 to <4 x i32>
  %res = call <4 x i32> @llvm.x86.xop.vpshld(<4 x i32> %arg0, <4 x i32> %arg1)
  %bc = bitcast <4 x i32> %res to <2 x i64>
  ret <2 x i64> %bc
}
declare <4 x i32> @llvm.x86.xop.vpshld(<4 x i32>, <4 x i32>) nounwind readnone

define <2 x i64> @test_mm_shl_epi64(<2 x i64> %a0, <2 x i64> %a1) {
; ALL-LABEL: test_mm_shl_epi64:
; ALL:       # %bb.0:
; ALL-NEXT:    vpshlq %xmm1, %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %res = call <2 x i64> @llvm.x86.xop.vpshlq(<2 x i64> %a0, <2 x i64> %a1)
  ret <2 x i64> %res
}
declare <2 x i64> @llvm.x86.xop.vpshlq(<2 x i64>, <2 x i64>) nounwind readnone

define <2 x i64> @test_mm_sha_epi8(<2 x i64> %a0, <2 x i64> %a1) {
; ALL-LABEL: test_mm_sha_epi8:
; ALL:       # %bb.0:
; ALL-NEXT:    vpshab %xmm1, %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <16 x i8>
  %arg1 = bitcast <2 x i64> %a1 to <16 x i8>
  %res = call <16 x i8> @llvm.x86.xop.vpshab(<16 x i8> %arg0, <16 x i8> %arg1)
  %bc = bitcast <16 x i8> %res to <2 x i64>
  ret <2 x i64> %bc
}
declare <16 x i8> @llvm.x86.xop.vpshab(<16 x i8>, <16 x i8>) nounwind readnone

define <2 x i64> @test_mm_sha_epi16(<2 x i64> %a0, <2 x i64> %a1) {
; ALL-LABEL: test_mm_sha_epi16:
; ALL:       # %bb.0:
; ALL-NEXT:    vpshaw %xmm1, %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <8 x i16>
  %arg1 = bitcast <2 x i64> %a1 to <8 x i16>
  %res = call <8 x i16> @llvm.x86.xop.vpshaw(<8 x i16> %arg0, <8 x i16> %arg1)
  %bc = bitcast <8 x i16> %res to <2 x i64>
  ret <2 x i64> %bc
}
declare <8 x i16> @llvm.x86.xop.vpshaw(<8 x i16>, <8 x i16>) nounwind readnone

define <2 x i64> @test_mm_sha_epi32(<2 x i64> %a0, <2 x i64> %a1) {
; ALL-LABEL: test_mm_sha_epi32:
; ALL:       # %bb.0:
; ALL-NEXT:    vpshad %xmm1, %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <4 x i32>
  %arg1 = bitcast <2 x i64> %a1 to <4 x i32>
  %res = call <4 x i32> @llvm.x86.xop.vpshad(<4 x i32> %arg0, <4 x i32> %arg1)
  %bc = bitcast <4 x i32> %res to <2 x i64>
  ret <2 x i64> %bc
}
declare <4 x i32> @llvm.x86.xop.vpshad(<4 x i32>, <4 x i32>) nounwind readnone

define <2 x i64> @test_mm_sha_epi64(<2 x i64> %a0, <2 x i64> %a1) {
; ALL-LABEL: test_mm_sha_epi64:
; ALL:       # %bb.0:
; ALL-NEXT:    vpshaq %xmm1, %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %res = call <2 x i64> @llvm.x86.xop.vpshaq(<2 x i64> %a0, <2 x i64> %a1)
  ret <2 x i64> %res
}
declare <2 x i64> @llvm.x86.xop.vpshaq(<2 x i64>, <2 x i64>) nounwind readnone

define <2 x i64> @test_mm_com_epu8(<2 x i64> %a0, <2 x i64> %a1) {
; ALL-LABEL: test_mm_com_epu8:
; ALL:       # %bb.0:
; ALL-NEXT:    vpcomltub %xmm1, %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <16 x i8>
  %arg1 = bitcast <2 x i64> %a1 to <16 x i8>
  %res = call <16 x i8> @llvm.x86.xop.vpcomub(<16 x i8> %arg0, <16 x i8> %arg1, i8 0)
  %bc = bitcast <16 x i8> %res to <2 x i64>
  ret <2 x i64> %bc
}
declare <16 x i8> @llvm.x86.xop.vpcomub(<16 x i8>, <16 x i8>, i8) nounwind readnone

define <2 x i64> @test_mm_com_epu16(<2 x i64> %a0, <2 x i64> %a1) {
; ALL-LABEL: test_mm_com_epu16:
; ALL:       # %bb.0:
; ALL-NEXT:    vpcomltuw %xmm1, %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <8 x i16>
  %arg1 = bitcast <2 x i64> %a1 to <8 x i16>
  %res = call <8 x i16> @llvm.x86.xop.vpcomuw(<8 x i16> %arg0, <8 x i16> %arg1, i8 0)
  %bc = bitcast <8 x i16> %res to <2 x i64>
  ret <2 x i64> %bc
}
declare <8 x i16> @llvm.x86.xop.vpcomuw(<8 x i16>, <8 x i16>, i8) nounwind readnone

define <2 x i64> @test_mm_com_epu32(<2 x i64> %a0, <2 x i64> %a1) {
; ALL-LABEL: test_mm_com_epu32:
; ALL:       # %bb.0:
; ALL-NEXT:    vpcomltud %xmm1, %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <4 x i32>
  %arg1 = bitcast <2 x i64> %a1 to <4 x i32>
  %res = call <4 x i32> @llvm.x86.xop.vpcomud(<4 x i32> %arg0, <4 x i32> %arg1, i8 0)
  %bc = bitcast <4 x i32> %res to <2 x i64>
  ret <2 x i64> %bc
}
declare <4 x i32> @llvm.x86.xop.vpcomud(<4 x i32>, <4 x i32>, i8) nounwind readnone

define <2 x i64> @test_mm_com_epu64(<2 x i64> %a0, <2 x i64> %a1) {
; ALL-LABEL: test_mm_com_epu64:
; ALL:       # %bb.0:
; ALL-NEXT:    vpcomltuq %xmm1, %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %res = call <2 x i64> @llvm.x86.xop.vpcomuq(<2 x i64> %a0, <2 x i64> %a1, i8 0)
  ret <2 x i64> %res
}
declare <2 x i64> @llvm.x86.xop.vpcomuq(<2 x i64>, <2 x i64>, i8) nounwind readnone

define <2 x i64> @test_mm_com_epi8(<2 x i64> %a0, <2 x i64> %a1) {
; ALL-LABEL: test_mm_com_epi8:
; ALL:       # %bb.0:
; ALL-NEXT:    vpcomltb %xmm1, %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <16 x i8>
  %arg1 = bitcast <2 x i64> %a1 to <16 x i8>
  %res = call <16 x i8> @llvm.x86.xop.vpcomb(<16 x i8> %arg0, <16 x i8> %arg1, i8 0)
  %bc = bitcast <16 x i8> %res to <2 x i64>
  ret <2 x i64> %bc
}
declare <16 x i8> @llvm.x86.xop.vpcomb(<16 x i8>, <16 x i8>, i8) nounwind readnone

define <2 x i64> @test_mm_com_epi16(<2 x i64> %a0, <2 x i64> %a1) {
; ALL-LABEL: test_mm_com_epi16:
; ALL:       # %bb.0:
; ALL-NEXT:    vpcomltw %xmm1, %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <8 x i16>
  %arg1 = bitcast <2 x i64> %a1 to <8 x i16>
  %res = call <8 x i16> @llvm.x86.xop.vpcomw(<8 x i16> %arg0, <8 x i16> %arg1, i8 0)
  %bc = bitcast <8 x i16> %res to <2 x i64>
  ret <2 x i64> %bc
}
declare <8 x i16> @llvm.x86.xop.vpcomw(<8 x i16>, <8 x i16>, i8) nounwind readnone

define <2 x i64> @test_mm_com_epi32(<2 x i64> %a0, <2 x i64> %a1) {
; ALL-LABEL: test_mm_com_epi32:
; ALL:       # %bb.0:
; ALL-NEXT:    vpcomltd %xmm1, %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg0 = bitcast <2 x i64> %a0 to <4 x i32>
  %arg1 = bitcast <2 x i64> %a1 to <4 x i32>
  %res = call <4 x i32> @llvm.x86.xop.vpcomd(<4 x i32> %arg0, <4 x i32> %arg1, i8 0)
  %bc = bitcast <4 x i32> %res to <2 x i64>
  ret <2 x i64> %bc
}
declare <4 x i32> @llvm.x86.xop.vpcomd(<4 x i32>, <4 x i32>, i8) nounwind readnone

define <2 x i64> @test_mm_com_epi64(<2 x i64> %a0, <2 x i64> %a1) {
; ALL-LABEL: test_mm_com_epi64:
; ALL:       # %bb.0:
; ALL-NEXT:    vpcomltq %xmm1, %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %res = call <2 x i64> @llvm.x86.xop.vpcomq(<2 x i64> %a0, <2 x i64> %a1, i8 0)
  ret <2 x i64> %res
}
declare <2 x i64> @llvm.x86.xop.vpcomq(<2 x i64>, <2 x i64>, i8) nounwind readnone

define <2 x double> @test_mm_permute2_pd(<2 x double> %a0, <2 x double> %a1, <2 x i64> %a2) {
; ALL-LABEL: test_mm_permute2_pd:
; ALL:       # %bb.0:
; ALL-NEXT:    vpermil2pd $0, %xmm2, %xmm1, %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %res = call <2 x double> @llvm.x86.xop.vpermil2pd(<2 x double> %a0, <2 x double> %a1, <2 x i64> %a2, i8 0)
  ret <2 x double> %res
}
declare <2 x double> @llvm.x86.xop.vpermil2pd(<2 x double>, <2 x double>, <2 x i64>, i8) nounwind readnone

define <4 x double> @test_mm256_permute2_pd(<4 x double> %a0, <4 x double> %a1, <4 x i64> %a2) {
; ALL-LABEL: test_mm256_permute2_pd:
; ALL:       # %bb.0:
; ALL-NEXT:    vpermil2pd $0, %ymm2, %ymm1, %ymm0, %ymm0
; ALL-NEXT:    ret{{[l|q]}}
  %res = call <4 x double> @llvm.x86.xop.vpermil2pd.256(<4 x double> %a0, <4 x double> %a1, <4 x i64> %a2, i8 0)
  ret <4 x double> %res
}
declare <4 x double> @llvm.x86.xop.vpermil2pd.256(<4 x double>, <4 x double>, <4 x i64>, i8) nounwind readnone

define <4 x float> @test_mm_permute2_ps(<4 x float> %a0, <4 x float> %a1, <2 x i64> %a2) {
; ALL-LABEL: test_mm_permute2_ps:
; ALL:       # %bb.0:
; ALL-NEXT:    vpermil2ps $0, %xmm2, %xmm1, %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg2 = bitcast <2 x i64> %a2 to <4 x i32>
  %res = call <4 x float> @llvm.x86.xop.vpermil2ps(<4 x float> %a0, <4 x float> %a1, <4 x i32> %arg2, i8 0)
  ret <4 x float> %res
}
declare <4 x float> @llvm.x86.xop.vpermil2ps(<4 x float>, <4 x float>, <4 x i32>, i8) nounwind readnone

define <8 x float> @test_mm256_permute2_ps(<8 x float> %a0, <8 x float> %a1, <4 x i64> %a2) {
; ALL-LABEL: test_mm256_permute2_ps:
; ALL:       # %bb.0:
; ALL-NEXT:    vpermil2ps $0, %ymm2, %ymm1, %ymm0, %ymm0
; ALL-NEXT:    ret{{[l|q]}}
  %arg2 = bitcast <4 x i64> %a2 to <8 x i32>
  %res = call <8 x float> @llvm.x86.xop.vpermil2ps.256(<8 x float> %a0, <8 x float> %a1, <8 x i32> %arg2, i8 0)
  ret <8 x float> %res
}
declare <8 x float> @llvm.x86.xop.vpermil2ps.256(<8 x float>, <8 x float>, <8 x i32>, i8) nounwind readnone

define <4 x float> @test_mm_frcz_ss(<4 x float> %a0) {
; ALL-LABEL: test_mm_frcz_ss:
; ALL:       # %bb.0:
; ALL-NEXT:    vfrczss %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %res = call <4 x float> @llvm.x86.xop.vfrcz.ss(<4 x float> %a0)
  ret <4 x float> %res
}
declare <4 x float> @llvm.x86.xop.vfrcz.ss(<4 x float>) nounwind readnone

define <2 x double> @test_mm_frcz_sd(<2 x double> %a0) {
; ALL-LABEL: test_mm_frcz_sd:
; ALL:       # %bb.0:
; ALL-NEXT:    vfrczsd %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %res = call <2 x double> @llvm.x86.xop.vfrcz.sd(<2 x double> %a0)
  ret <2 x double> %res
}
declare <2 x double> @llvm.x86.xop.vfrcz.sd(<2 x double>) nounwind readnone

define <4 x float> @test_mm_frcz_ps(<4 x float> %a0) {
; ALL-LABEL: test_mm_frcz_ps:
; ALL:       # %bb.0:
; ALL-NEXT:    vfrczps %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %res = call <4 x float> @llvm.x86.xop.vfrcz.ps(<4 x float> %a0)
  ret <4 x float> %res
}
declare <4 x float> @llvm.x86.xop.vfrcz.ps(<4 x float>) nounwind readnone

define <2 x double> @test_mm_frcz_pd(<2 x double> %a0) {
; ALL-LABEL: test_mm_frcz_pd:
; ALL:       # %bb.0:
; ALL-NEXT:    vfrczpd %xmm0, %xmm0
; ALL-NEXT:    ret{{[l|q]}}
  %res = call <2 x double> @llvm.x86.xop.vfrcz.pd(<2 x double> %a0)
  ret <2 x double> %res
}
declare <2 x double> @llvm.x86.xop.vfrcz.pd(<2 x double>) nounwind readnone

define <8 x float> @test_mm256_frcz_ps(<8 x float> %a0) {
; ALL-LABEL: test_mm256_frcz_ps:
; ALL:       # %bb.0:
; ALL-NEXT:    vfrczps %ymm0, %ymm0
; ALL-NEXT:    ret{{[l|q]}}
  %res = call <8 x float> @llvm.x86.xop.vfrcz.ps.256(<8 x float> %a0)
  ret <8 x float> %res
}
declare <8 x float> @llvm.x86.xop.vfrcz.ps.256(<8 x float>) nounwind readnone

define <4 x double> @test_mm256_frcz_pd(<4 x double> %a0) {
; ALL-LABEL: test_mm256_frcz_pd:
; ALL:       # %bb.0:
; ALL-NEXT:    vfrczpd %ymm0, %ymm0
; ALL-NEXT:    ret{{[l|q]}}
  %res = call <4 x double> @llvm.x86.xop.vfrcz.pd.256(<4 x double> %a0)
  ret <4 x double> %res
}
declare <4 x double> @llvm.x86.xop.vfrcz.pd.256(<4 x double>) nounwind readnone

















