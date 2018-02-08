; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=aarch64-unknown-linux-gnu -O3 %s -o - | FileCheck %s

define void @foo(i32 %In1, <2 x i128> %In2, <2 x i128> %In3, <2 x i128> *%Out) {
; CHECK-LABEL: foo:
; CHECK:       // %bb.0:
; CHECK-NEXT:    and w9, w0, #0x1
; CHECK-NEXT:    fmov s0, wzr
; CHECK-NEXT:    ldp x10, x8, [sp, #8]
; CHECK-NEXT:    fmov s1, w9
; CHECK-NEXT:    ldr x9, [sp]
; CHECK-NEXT:    cmeq v0.4s, v1.4s, v0.4s
; CHECK-NEXT:    fmov w11, s0
; CHECK-NEXT:    tst w11, #0x1
; CHECK-NEXT:    csel x11, x2, x6, ne
; CHECK-NEXT:    csel x12, x3, x7, ne
; CHECK-NEXT:    csel x9, x4, x9, ne
; CHECK-NEXT:    csel x10, x5, x10, ne
; CHECK-NEXT:    stp x9, x10, [x8, #16]
; CHECK-NEXT:    stp x11, x12, [x8]
; CHECK-NEXT:    ret
  %cond = and i32 %In1, 1
  %cbool = icmp eq i32 %cond, 0
  %res = select i1 %cbool, <2 x i128> %In2, <2 x i128> %In3
  store <2 x i128> %res, <2 x i128> *%Out

  ret void
}

; Check case when scalar size is not power of 2.
define void @bar(i32 %In1, <2 x i96> %In2, <2 x i96> %In3, <2 x i96> *%Out) {
; CHECK-LABEL: bar:
; CHECK:       // %bb.0:
; CHECK-NEXT:    and w10, w0, #0x1
; CHECK-NEXT:    fmov s0, wzr
; CHECK-NEXT:    fmov s1, w10
; CHECK-NEXT:    cmeq v0.4s, v1.4s, v0.4s
; CHECK-NEXT:    ldp x11, x8, [sp, #8]
; CHECK-NEXT:    ldr x9, [sp]
; CHECK-NEXT:    dup v1.4s, v0.s[0]
; CHECK-NEXT:    mov x10, v1.d[1]
; CHECK-NEXT:    lsr x10, x10, #32
; CHECK-NEXT:    tst w10, #0x1
; CHECK-NEXT:    fmov w10, s0
; CHECK-NEXT:    csel x11, x5, x11, ne
; CHECK-NEXT:    csel x9, x4, x9, ne
; CHECK-NEXT:    tst w10, #0x1
; CHECK-NEXT:    csel x10, x3, x7, ne
; CHECK-NEXT:    csel x12, x2, x6, ne
; CHECK-NEXT:    stur x9, [x8, #12]
; CHECK-NEXT:    str x12, [x8]
; CHECK-NEXT:    str w10, [x8, #8]
; CHECK-NEXT:    str w11, [x8, #20]
; CHECK-NEXT:    ret
  %cond = and i32 %In1, 1
  %cbool = icmp eq i32 %cond, 0
  %res = select i1 %cbool, <2 x i96> %In2, <2 x i96> %In3
  store <2 x i96> %res, <2 x i96> *%Out

  ret void
}
