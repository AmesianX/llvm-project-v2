; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+sse2 | FileCheck %s --check-prefix=SSE --check-prefix=SSE2
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+sse4.1 | FileCheck %s --check-prefix=SSE --check-prefix=SSE41
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+avx | FileCheck %s --check-prefix=AVX

define void @extract_i8_0(i8* nocapture %dst, <16 x i8> %foo) {
; SSE2-LABEL: extract_i8_0:
; SSE2:       # BB#0:
; SSE2-NEXT:    movaps %xmm0, -{{[0-9]+}}(%rsp)
; SSE2-NEXT:    movb -{{[0-9]+}}(%rsp), %al
; SSE2-NEXT:    movb %al, (%rdi)
; SSE2-NEXT:    retq
;
; SSE41-LABEL: extract_i8_0:
; SSE41:       # BB#0:
; SSE41-NEXT:    pextrb $0, %xmm0, (%rdi)
; SSE41-NEXT:    retq
;
; AVX-LABEL: extract_i8_0:
; AVX:       # BB#0:
; AVX-NEXT:    vpextrb $0, %xmm0, (%rdi)
; AVX-NEXT:    retq
  %vecext = extractelement <16 x i8> %foo, i32 0
  store i8 %vecext, i8* %dst, align 1
  ret void
}

define void @extract_i8_15(i8* nocapture %dst, <16 x i8> %foo) {
; SSE2-LABEL: extract_i8_15:
; SSE2:       # BB#0:
; SSE2-NEXT:    movaps %xmm0, -{{[0-9]+}}(%rsp)
; SSE2-NEXT:    movb -{{[0-9]+}}(%rsp), %al
; SSE2-NEXT:    movb %al, (%rdi)
; SSE2-NEXT:    retq
;
; SSE41-LABEL: extract_i8_15:
; SSE41:       # BB#0:
; SSE41-NEXT:    pextrb $15, %xmm0, (%rdi)
; SSE41-NEXT:    retq
;
; AVX-LABEL: extract_i8_15:
; AVX:       # BB#0:
; AVX-NEXT:    vpextrb $15, %xmm0, (%rdi)
; AVX-NEXT:    retq
  %vecext = extractelement <16 x i8> %foo, i32 15
  store i8 %vecext, i8* %dst, align 1
  ret void
}

define void @extract_i16_0(i16* nocapture %dst, <8 x i16> %foo) {
; SSE2-LABEL: extract_i16_0:
; SSE2:       # BB#0:
; SSE2-NEXT:    movd %xmm0, %eax
; SSE2-NEXT:    movw %ax, (%rdi)
; SSE2-NEXT:    retq
;
; SSE41-LABEL: extract_i16_0:
; SSE41:       # BB#0:
; SSE41-NEXT:    pextrw $0, %xmm0, (%rdi)
; SSE41-NEXT:    retq
;
; AVX-LABEL: extract_i16_0:
; AVX:       # BB#0:
; AVX-NEXT:    vpextrw $0, %xmm0, (%rdi)
; AVX-NEXT:    retq
  %vecext = extractelement <8 x i16> %foo, i32 0
  store i16 %vecext, i16* %dst, align 1
  ret void
}

define void @extract_i16_7(i16* nocapture %dst, <8 x i16> %foo) {
; SSE2-LABEL: extract_i16_7:
; SSE2:       # BB#0:
; SSE2-NEXT:    pextrw $7, %xmm0, %eax
; SSE2-NEXT:    movw %ax, (%rdi)
; SSE2-NEXT:    retq
;
; SSE41-LABEL: extract_i16_7:
; SSE41:       # BB#0:
; SSE41-NEXT:    pextrw $7, %xmm0, (%rdi)
; SSE41-NEXT:    retq
;
; AVX-LABEL: extract_i16_7:
; AVX:       # BB#0:
; AVX-NEXT:    vpextrw $7, %xmm0, (%rdi)
; AVX-NEXT:    retq
  %vecext = extractelement <8 x i16> %foo, i32 7
  store i16 %vecext, i16* %dst, align 1
  ret void
}

define void @extract_i8_undef(i8* nocapture %dst, <16 x i8> %foo) {
; SSE-LABEL: extract_i8_undef:
; SSE:       # BB#0:
; SSE-NEXT:    retq
;
; AVX-LABEL: extract_i8_undef:
; AVX:       # BB#0:
; AVX-NEXT:    retq
  %vecext = extractelement <16 x i8> %foo, i32 16 ; undef
  store i8 %vecext, i8* %dst, align 1
  ret void
}

define void @extract_i16_undef(i16* nocapture %dst, <8 x i16> %foo) {
; SSE-LABEL: extract_i16_undef:
; SSE:       # BB#0:
; SSE-NEXT:    retq
;
; AVX-LABEL: extract_i16_undef:
; AVX:       # BB#0:
; AVX-NEXT:    retq
  %vecext = extractelement <8 x i16> %foo, i32 9 ; undef
  store i16 %vecext, i16* %dst, align 1
  ret void
}
