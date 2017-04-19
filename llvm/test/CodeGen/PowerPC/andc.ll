; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -verify-machineinstrs < %s -mtriple=powerpc64le-unknown-unknown | FileCheck %s

define i1 @and_cmp1(i32 %x, i32 %y) {
; CHECK-LABEL: and_cmp1:
; CHECK:       # BB#0:
; CHECK-NEXT:    andc 3, 4, 3
; CHECK-NEXT:    cntlzw 3, 3
; CHECK-NEXT:    rlwinm 3, 3, 27, 31, 31
; CHECK-NEXT:    blr
  %and = and i32 %x, %y
  %cmp = icmp eq i32 %and, %y
  ret i1 %cmp
}

define i1 @and_cmp_const(i32 %x) {
; CHECK-LABEL: and_cmp_const:
; CHECK:       # BB#0:
; CHECK-NEXT:    li 4, 43
; CHECK-NEXT:    andc 3, 4, 3
; CHECK-NEXT:    cntlzw 3, 3
; CHECK-NEXT:    rlwinm 3, 3, 27, 31, 31
; CHECK-NEXT:    blr
  %and = and i32 %x, 43
  %cmp = icmp eq i32 %and, 43
  ret i1 %cmp
}

define i1 @foo(i32 %i) {
; CHECK-LABEL: foo:
; CHECK:       # BB#0:
; CHECK-NEXT:    lis 4, 4660
; CHECK-NEXT:    ori 4, 4, 22136
; CHECK-NEXT:    andc 3, 4, 3
; CHECK-NEXT:    cntlzw 3, 3
; CHECK-NEXT:    rlwinm 3, 3, 27, 31, 31
; CHECK-NEXT:    blr
  %and = and i32 %i, 305419896
  %cmp = icmp eq i32 %and, 305419896
  ret i1 %cmp
}

define <4 x i32> @hidden_not_v4i32(<4 x i32> %x) {
; CHECK-LABEL: hidden_not_v4i32:
; CHECK:       # BB#0:
; CHECK-NEXT:    vspltisw 3, 15
; CHECK-NEXT:    vspltisw 4, 6
; CHECK-NEXT:    xxlxor 0, 34, 35
; CHECK-NEXT:    xxland 34, 0, 36
; CHECK-NEXT:    blr
  %xor = xor <4 x i32> %x, <i32 15, i32 15, i32 15, i32 15>
  %and = and <4 x i32> %xor, <i32 6, i32 6, i32 6, i32 6>
  ret <4 x i32> %and
}

