; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=aarch64-none-linux-gnu -mattr=+neon | FileCheck %s --check-prefix=CHECK

declare half @llvm.experimental.vector.reduce.fmax.f16.v1f16(<1 x half> %a)
declare float @llvm.experimental.vector.reduce.fmax.f32.v1f32(<1 x float> %a)
declare double @llvm.experimental.vector.reduce.fmax.f64.v1f64(<1 x double> %a)
declare fp128 @llvm.experimental.vector.reduce.fmax.f128.v1f128(<1 x fp128> %a)

declare float @llvm.experimental.vector.reduce.fmax.f32.v3f32(<3 x float> %a)
declare fp128 @llvm.experimental.vector.reduce.fmax.f128.v2f128(<2 x fp128> %a)
declare float @llvm.experimental.vector.reduce.fmax.f32.v16f32(<16 x float> %a)

define half @test_v1f16(<1 x half> %a) nounwind {
; CHECK-LABEL: test_v1f16:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ret
  %b = call nnan half @llvm.experimental.vector.reduce.fmax.f16.v1f16(<1 x half> %a)
  ret half %b
}

define float @test_v1f32(<1 x float> %a) nounwind {
; CHECK-LABEL: test_v1f32:
; CHECK:       // %bb.0:
; CHECK-NEXT:    // kill: def $d0 killed $d0 def $q0
; CHECK-NEXT:    // kill: def $s0 killed $s0 killed $q0
; CHECK-NEXT:    ret
  %b = call nnan float @llvm.experimental.vector.reduce.fmax.f32.v1f32(<1 x float> %a)
  ret float %b
}

define double @test_v1f64(<1 x double> %a) nounwind {
; CHECK-LABEL: test_v1f64:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ret
  %b = call nnan double @llvm.experimental.vector.reduce.fmax.f64.v1f64(<1 x double> %a)
  ret double %b
}

define fp128 @test_v1f128(<1 x fp128> %a) nounwind {
; CHECK-LABEL: test_v1f128:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ret
  %b = call nnan fp128 @llvm.experimental.vector.reduce.fmax.f128.v1f128(<1 x fp128> %a)
  ret fp128 %b
}

define float @test_v3f32(<3 x float> %a) nounwind {
; CHECK-LABEL: test_v3f32:
; CHECK:       // %bb.0:
; CHECK-NEXT:    orr w8, wzr, #0x7f800000
; CHECK-NEXT:    fmov s1, w8
; CHECK-NEXT:    mov v0.s[3], v1.s[0]
; CHECK-NEXT:    fmaxnmv s0, v0.4s
; CHECK-NEXT:    ret
  %b = call nnan float @llvm.experimental.vector.reduce.fmax.f32.v3f32(<3 x float> %a)
  ret float %b
}

define fp128 @test_v2f128(<2 x fp128> %a) nounwind {
; CHECK-LABEL: test_v2f128:
; CHECK:       // %bb.0:
; CHECK-NEXT:    b fmaxl
  %b = call nnan fp128 @llvm.experimental.vector.reduce.fmax.f128.v2f128(<2 x fp128> %a)
  ret fp128 %b
}

define float @test_v16f32(<16 x float> %a) nounwind {
; CHECK-LABEL: test_v16f32:
; CHECK:       // %bb.0:
; CHECK-NEXT:    fmaxnm v1.4s, v1.4s, v3.4s
; CHECK-NEXT:    fmaxnm v0.4s, v0.4s, v2.4s
; CHECK-NEXT:    fmaxnm v0.4s, v0.4s, v1.4s
; CHECK-NEXT:    fmaxnmv s0, v0.4s
; CHECK-NEXT:    ret
  %b = call nnan float @llvm.experimental.vector.reduce.fmax.f32.v16f32(<16 x float> %a)
  ret float %b
}
