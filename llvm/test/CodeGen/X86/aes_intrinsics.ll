; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i386-unknown-unknown   -mattr=+aes,-avx -show-mc-encoding | FileCheck %s --check-prefix=SSE
; RUN: llc < %s -mtriple=i386-unknown-unknown   -mattr=+aes,+avx -show-mc-encoding | FileCheck %s --check-prefix=AVX
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+aes,-avx -show-mc-encoding | FileCheck %s --check-prefix=SSE
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+aes,+avx -show-mc-encoding | FileCheck %s --check-prefix=AVX

define <2 x i64> @test_x86_aesni_aesdec(<2 x i64> %a0, <2 x i64> %a1) {
; SSE-LABEL: test_x86_aesni_aesdec:
; SSE:       # %bb.0:
; SSE-NEXT:    aesdec %xmm1, %xmm0 # encoding: [0x66,0x0f,0x38,0xde,0xc1]
; SSE-NEXT:    ret{{[l|q]}} # encoding: [0xc3]
;
; AVX-LABEL: test_x86_aesni_aesdec:
; AVX:       # %bb.0:
; AVX-NEXT:    vaesdec %xmm1, %xmm0, %xmm0 # encoding: [0xc4,0xe2,0x79,0xde,0xc1]
; AVX-NEXT:    ret{{[l|q]}} # encoding: [0xc3]
  %res = call <2 x i64> @llvm.x86.aesni.aesdec(<2 x i64> %a0, <2 x i64> %a1) ; <<2 x i64>> [#uses=1]
  ret <2 x i64> %res
}
declare <2 x i64> @llvm.x86.aesni.aesdec(<2 x i64>, <2 x i64>) nounwind readnone


define <2 x i64> @test_x86_aesni_aesdeclast(<2 x i64> %a0, <2 x i64> %a1) {
; SSE-LABEL: test_x86_aesni_aesdeclast:
; SSE:       # %bb.0:
; SSE-NEXT:    aesdeclast %xmm1, %xmm0 # encoding: [0x66,0x0f,0x38,0xdf,0xc1]
; SSE-NEXT:    ret{{[l|q]}} # encoding: [0xc3]
;
; AVX-LABEL: test_x86_aesni_aesdeclast:
; AVX:       # %bb.0:
; AVX-NEXT:    vaesdeclast %xmm1, %xmm0, %xmm0 # encoding: [0xc4,0xe2,0x79,0xdf,0xc1]
; AVX-NEXT:    ret{{[l|q]}} # encoding: [0xc3]
  %res = call <2 x i64> @llvm.x86.aesni.aesdeclast(<2 x i64> %a0, <2 x i64> %a1) ; <<2 x i64>> [#uses=1]
  ret <2 x i64> %res
}
declare <2 x i64> @llvm.x86.aesni.aesdeclast(<2 x i64>, <2 x i64>) nounwind readnone


define <2 x i64> @test_x86_aesni_aesenc(<2 x i64> %a0, <2 x i64> %a1) {
; SSE-LABEL: test_x86_aesni_aesenc:
; SSE:       # %bb.0:
; SSE-NEXT:    aesenc %xmm1, %xmm0 # encoding: [0x66,0x0f,0x38,0xdc,0xc1]
; SSE-NEXT:    ret{{[l|q]}} # encoding: [0xc3]
;
; AVX-LABEL: test_x86_aesni_aesenc:
; AVX:       # %bb.0:
; AVX-NEXT:    vaesenc %xmm1, %xmm0, %xmm0 # encoding: [0xc4,0xe2,0x79,0xdc,0xc1]
; AVX-NEXT:    ret{{[l|q]}} # encoding: [0xc3]
  %res = call <2 x i64> @llvm.x86.aesni.aesenc(<2 x i64> %a0, <2 x i64> %a1) ; <<2 x i64>> [#uses=1]
  ret <2 x i64> %res
}
declare <2 x i64> @llvm.x86.aesni.aesenc(<2 x i64>, <2 x i64>) nounwind readnone


define <2 x i64> @test_x86_aesni_aesenclast(<2 x i64> %a0, <2 x i64> %a1) {
; SSE-LABEL: test_x86_aesni_aesenclast:
; SSE:       # %bb.0:
; SSE-NEXT:    aesenclast %xmm1, %xmm0 # encoding: [0x66,0x0f,0x38,0xdd,0xc1]
; SSE-NEXT:    ret{{[l|q]}} # encoding: [0xc3]
;
; AVX-LABEL: test_x86_aesni_aesenclast:
; AVX:       # %bb.0:
; AVX-NEXT:    vaesenclast %xmm1, %xmm0, %xmm0 # encoding: [0xc4,0xe2,0x79,0xdd,0xc1]
; AVX-NEXT:    ret{{[l|q]}} # encoding: [0xc3]
  %res = call <2 x i64> @llvm.x86.aesni.aesenclast(<2 x i64> %a0, <2 x i64> %a1) ; <<2 x i64>> [#uses=1]
  ret <2 x i64> %res
}
declare <2 x i64> @llvm.x86.aesni.aesenclast(<2 x i64>, <2 x i64>) nounwind readnone


define <2 x i64> @test_x86_aesni_aesimc(<2 x i64> %a0) {
; SSE-LABEL: test_x86_aesni_aesimc:
; SSE:       # %bb.0:
; SSE-NEXT:    aesimc %xmm0, %xmm0 # encoding: [0x66,0x0f,0x38,0xdb,0xc0]
; SSE-NEXT:    ret{{[l|q]}} # encoding: [0xc3]
;
; AVX-LABEL: test_x86_aesni_aesimc:
; AVX:       # %bb.0:
; AVX-NEXT:    vaesimc %xmm0, %xmm0 # encoding: [0xc4,0xe2,0x79,0xdb,0xc0]
; AVX-NEXT:    ret{{[l|q]}} # encoding: [0xc3]
  %res = call <2 x i64> @llvm.x86.aesni.aesimc(<2 x i64> %a0) ; <<2 x i64>> [#uses=1]
  ret <2 x i64> %res
}
declare <2 x i64> @llvm.x86.aesni.aesimc(<2 x i64>) nounwind readnone


define <2 x i64> @test_x86_aesni_aeskeygenassist(<2 x i64> %a0) {
; SSE-LABEL: test_x86_aesni_aeskeygenassist:
; SSE:       # %bb.0:
; SSE-NEXT:    aeskeygenassist $7, %xmm0, %xmm0 # encoding: [0x66,0x0f,0x3a,0xdf,0xc0,0x07]
; SSE-NEXT:    ret{{[l|q]}} # encoding: [0xc3]
;
; AVX-LABEL: test_x86_aesni_aeskeygenassist:
; AVX:       # %bb.0:
; AVX-NEXT:    vaeskeygenassist $7, %xmm0, %xmm0 # encoding: [0xc4,0xe3,0x79,0xdf,0xc0,0x07]
; AVX-NEXT:    ret{{[l|q]}} # encoding: [0xc3]
  %res = call <2 x i64> @llvm.x86.aesni.aeskeygenassist(<2 x i64> %a0, i8 7) ; <<2 x i64>> [#uses=1]
  ret <2 x i64> %res
}
declare <2 x i64> @llvm.x86.aesni.aeskeygenassist(<2 x i64>, i8) nounwind readnone
