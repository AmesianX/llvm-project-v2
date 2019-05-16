; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown             | FileCheck %s
; RUN: llc < %s -mtriple=i686-unknown -mattr=sse2 | FileCheck %s --check-prefix=SSE2

define i32 @testmsws_builtin(float %x) {
; CHECK-LABEL: testmsws_builtin:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    jmp lroundf # TAILCALL
;
; SSE2-LABEL: testmsws_builtin:
; SSE2:       # %bb.0: # %entry
; SSE2-NEXT:    jmp lroundf # TAILCALL
entry:
  %0 = tail call i32 @llvm.lround.i32.f32(float %x)
  ret i32 %0
}

define i32 @testmswd_builtin(double %x) {
; CHECK-LABEL: testmswd_builtin:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    jmp lround # TAILCALL
;
; SSE2-LABEL: testmswd_builtin:
; SSE2:       # %bb.0: # %entry
; SSE2-NEXT:    jmp lround # TAILCALL
entry:
  %0 = tail call i32 @llvm.lround.i32.f64(double %x)
  ret i32 %0
}

declare i32 @llvm.lround.i32.f32(float) nounwind readnone
declare i32 @llvm.lround.i32.f64(double) nounwind readnone
