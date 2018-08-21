; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -constprop -S -o - | FileCheck %s

; When both operands are undef in a lane, that lane should produce an undef result.

define <3 x i8> @shl() {
; CHECK-LABEL: @shl(
; CHECK-NEXT:    ret <3 x i8> <i8 undef, i8 0, i8 0>
;
  %c = shl <3 x i8> undef, <i8 undef, i8 4, i8 1>
  ret <3 x i8> %c
}

define <3 x i8> @and() {
; CHECK-LABEL: @and(
; CHECK-NEXT:    ret <3 x i8> <i8 undef, i8 0, i8 undef>
;
  %c = and <3 x i8> <i8 undef, i8 42, i8 undef>, undef
  ret <3 x i8> %c
}

define <3 x i8> @and_commute() {
; CHECK-LABEL: @and_commute(
; CHECK-NEXT:    ret <3 x i8> <i8 0, i8 0, i8 undef>
;
  %c = and <3 x i8> undef, <i8 -42, i8 42, i8 undef>
  ret <3 x i8> %c
}

define <3 x i8> @or() {
; CHECK-LABEL: @or(
; CHECK-NEXT:    ret <3 x i8> <i8 undef, i8 -1, i8 undef>
;
  %c = or <3 x i8> <i8 undef, i8 42, i8 undef>, undef
  ret <3 x i8> %c
}

define <3 x i8> @or_commute() {
; CHECK-LABEL: @or_commute(
; CHECK-NEXT:    ret <3 x i8> <i8 -1, i8 -1, i8 undef>
;
  %c = or <3 x i8> undef, <i8 -42, i8 42, i8 undef>
  ret <3 x i8> %c
}

define <3 x float> @fadd() {
; CHECK-LABEL: @fadd(
; CHECK-NEXT:    ret <3 x float> <float undef, float 0x7FF8000000000000, float undef>
;
  %c = fadd <3 x float> <float undef, float 42.0, float undef>, undef
  ret <3 x float> %c
}

define <3 x float> @fadd_commute() {
; CHECK-LABEL: @fadd_commute(
; CHECK-NEXT:    ret <3 x float> <float 0x7FF8000000000000, float 0x7FF8000000000000, float undef>
;
  %c = fadd <3 x float> undef, <float -42.0, float 42.0, float undef>
  ret <3 x float> %c
}

