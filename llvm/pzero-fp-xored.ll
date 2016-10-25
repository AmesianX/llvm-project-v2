; RUN: llc -mtriple=powerpc-unknown-linux-gnu -mattr=+vsx < %s |  \
; RUN:   FileCheck %s --implicit-check-not lxvd2x --implicit-check-not lfs
; RUN: llc -mtriple=powerpc-unknown-linux-gnu -mattr=-vsx -mattr=-p8altivec < %s | \
; RUN:   FileCheck %s --check-prefix=CHECK-NVSXP8A --implicit-check-not xxlxor \
; RUN:                                             --implicit-check-not vxor

define signext i32 @t1(float %x) local_unnamed_addr #0 {
entry:
  %cmp = fcmp ogt float %x, 0.000000e+00
  %tmp = select i1 %cmp, i32 43, i32 11
  ret i32 %tmp

; CHECK-LABEL: t1:
; CHECK: xxlxor [[REG1:[0-9]+]], [[REG1]], [[REG1]]
; CHECK: fcmpu {{[0-9]+}}, {{[0-9]+}}, [[REG1]]
; CHECK: blr
; CHECK-NVSXP8A: lfs [[REG1:[0-9]+]]
; CHECK-NVSXP8A: fcmpu {{[0-9]+}}, {{[0-9]+}}, [[REG1]]
; CHECK-NVSXP8A: blr
}

define signext i32 @t2(double %x) local_unnamed_addr #0 {
entry:
  %cmp = fcmp ogt double %x, 0.000000e+00
  %tmp = select i1 %cmp, i32 43, i32 11
  ret i32 %tmp

; CHECK-LABEL: t2:
; CHECK: xxlxor [[REG2:[0-9]+]], [[REG2]], [[REG2]]
; CHECK: xscmpudp {{[0-9]+}}, {{[0-9]+}}, [[REG2]]
; CHECK: blr
; CHECK-NVSXP8A: lfs [[REG2:[0-9]+]]
; CHECK-NVSXP8A: fcmpu {{[0-9]+}}, {{[0-9]+}}, [[REG2]]
; CHECK-NVSXP8A: blr
}

define signext i32 @t3(ppc_fp128 %x) local_unnamed_addr #0 {
entry:
  %cmp = fcmp ogt ppc_fp128 %x, 0xM00000000000000000000000000000000
  %tmp = select i1 %cmp, i32 43, i32 11
  ret i32 %tmp

; CHECK-LABEL: t3:
; CHECK: xxlxor [[REG3:[0-9]+]], [[REG3]], [[REG3]]
; CHECK: fcmpu {{[0-9]+}}, {{[0-9]+}}, [[REG3]]
; CHECK: fcmpu {{[0-9]+}}, {{[0-9]+}}, [[REG3]]
; CHECK: blr
; CHECK-NVSXP8A: lfs [[REG3:[0-9]+]]
; CHECK-NVSXP8A: fcmpu {{[0-9]+}}, {{[0-9]+}}, [[REG3]]
; CHECK-NVSXP8A: blr
}

define <2 x double> @t4() local_unnamed_addr #0 {
  ret <2 x double> zeroinitializer
; CHECK-LABEL: t4:
; CHECK: vxor [[REG4:[0-9]+]], [[REG4]], [[REG4]]
; CHECK: blr
; CHECK-NVSXP8A: lfs [[REG4:[0-9]+]]
; CHECK-NVSXP8A: fmr {{[0-9]+}}, [[REG4:[0-9]+]]
; CHECK-NVSXP8A: blr
}

define <2 x i64> @t5() local_unnamed_addr #0 {
  ret <2 x i64> zeroinitializer
; CHECK-LABEL: t5:
; CHECK: vxor [[REG5:[0-9]+]], [[REG5]], [[REG5]]
; CHECK: blr
; CHECK-NVSXP8A: lvx
; CHECK-NVSXP8A: blr
}

