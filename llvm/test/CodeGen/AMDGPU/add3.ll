; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=amdgcn-amd-mesa3d -mcpu=fiji -verify-machineinstrs | FileCheck -check-prefix=VI %s
; RUN: llc < %s -mtriple=amdgcn-amd-mesa3d -mcpu=gfx900 -verify-machineinstrs | FileCheck -check-prefix=GFX9 %s

; ===================================================================================
; V_ADD3_U32
; ===================================================================================

define amdgpu_ps float @add3(i32 %a, i32 %b, i32 %c) {
; VI-LABEL: add3:
; VI:       ; %bb.0:
; VI-NEXT:    v_add_u32_e32 v0, vcc, v0, v1
; VI-NEXT:    v_add_u32_e32 v0, vcc, v0, v2
; VI-NEXT:    ; return to shader part epilog
;
; GFX9-LABEL: add3:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    v_add3_u32 v0, v0, v1, v2
; GFX9-NEXT:    ; return to shader part epilog
  %x = add i32 %a, %b
  %result = add i32 %x, %c
  %bc = bitcast i32 %result to float
  ret float %bc
}

; V_MAD_U32_U24 is given higher priority.
define amdgpu_ps float @mad_no_add3(i32 %a, i32 %b, i32 %c, i32 %d, i32 %e) {
; GFX9-LABEL: mad_no_add3:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    v_mad_u32_u24 v0, v0, v1, v4
; GFX9-NEXT:    v_mad_u32_u24 v0, v2, v3, v0
; GFX9-NEXT:    ; return to shader part epilog
  %a0 = shl i32 %a, 8
  %a1 = lshr i32 %a0, 8
  %b0 = shl i32 %b, 8
  %b1 = lshr i32 %b0, 8
  %mul1 = mul i32 %a1, %b1

  %c0 = shl i32 %c, 8
  %c1 = lshr i32 %c0, 8
  %d0 = shl i32 %d, 8
  %d1 = lshr i32 %d0, 8
  %mul2 = mul i32 %c1, %d1

  %add0 = add i32 %e, %mul1
  %add1 = add i32 %mul2, %add0

  %bc = bitcast i32 %add1 to float
  ret float %bc
}

; ThreeOp instruction variant not used due to Constant Bus Limitations
; TODO: with reassociation it is possible to replace a v_add_u32_e32 with a s_add_i32
define amdgpu_ps float @add3_vgpr_b(i32 inreg %a, i32 %b, i32 inreg %c) {
; VI-LABEL: add3_vgpr_b:
; VI:       ; %bb.0:
; VI-NEXT:    v_add_u32_e32 v0, vcc, s2, v0
; VI-NEXT:    v_add_u32_e32 v0, vcc, s3, v0
; VI-NEXT:    ; return to shader part epilog
;
; GFX9-LABEL: add3_vgpr_b:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    v_add_u32_e32 v0, s2, v0
; GFX9-NEXT:    v_add_u32_e32 v0, s3, v0
; GFX9-NEXT:    ; return to shader part epilog
  %x = add i32 %a, %b
  %result = add i32 %x, %c
  %bc = bitcast i32 %result to float
  ret float %bc
}

define amdgpu_ps float @add3_vgpr_all2(i32 %a, i32 %b, i32 %c) {
; VI-LABEL: add3_vgpr_all2:
; VI:       ; %bb.0:
; VI-NEXT:    v_add_u32_e32 v1, vcc, v1, v2
; VI-NEXT:    v_add_u32_e32 v0, vcc, v0, v1
; VI-NEXT:    ; return to shader part epilog
;
; GFX9-LABEL: add3_vgpr_all2:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    v_add3_u32 v0, v1, v2, v0
; GFX9-NEXT:    ; return to shader part epilog
  %x = add i32 %b, %c
  %result = add i32 %a, %x
  %bc = bitcast i32 %result to float
  ret float %bc
}

define amdgpu_ps float @add3_vgpr_bc(i32 inreg %a, i32 %b, i32 %c) {
; VI-LABEL: add3_vgpr_bc:
; VI:       ; %bb.0:
; VI-NEXT:    v_add_u32_e32 v0, vcc, s2, v0
; VI-NEXT:    v_add_u32_e32 v0, vcc, v0, v1
; VI-NEXT:    ; return to shader part epilog
;
; GFX9-LABEL: add3_vgpr_bc:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    v_add3_u32 v0, s2, v0, v1
; GFX9-NEXT:    ; return to shader part epilog
  %x = add i32 %a, %b
  %result = add i32 %x, %c
  %bc = bitcast i32 %result to float
  ret float %bc
}

define amdgpu_ps float @add3_vgpr_const(i32 %a, i32 %b) {
; VI-LABEL: add3_vgpr_const:
; VI:       ; %bb.0:
; VI-NEXT:    v_add_u32_e32 v0, vcc, v0, v1
; VI-NEXT:    v_add_u32_e32 v0, vcc, 16, v0
; VI-NEXT:    ; return to shader part epilog
;
; GFX9-LABEL: add3_vgpr_const:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    v_add3_u32 v0, v0, v1, 16
; GFX9-NEXT:    ; return to shader part epilog
  %x = add i32 %a, %b
  %result = add i32 %x, 16
  %bc = bitcast i32 %result to float
  ret float %bc
}

define amdgpu_ps <2 x float> @add3_multiuse_outer(i32 %a, i32 %b, i32 %c, i32 %x) {
; VI-LABEL: add3_multiuse_outer:
; VI:       ; %bb.0:
; VI-NEXT:    v_add_u32_e32 v0, vcc, v0, v1
; VI-NEXT:    v_add_u32_e32 v0, vcc, v0, v2
; VI-NEXT:    v_mul_lo_i32 v1, v0, v3
; VI-NEXT:    ; return to shader part epilog
;
; GFX9-LABEL: add3_multiuse_outer:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    v_add3_u32 v0, v0, v1, v2
; GFX9-NEXT:    v_mul_lo_i32 v1, v0, v3
; GFX9-NEXT:    ; return to shader part epilog
  %inner = add i32 %a, %b
  %outer = add i32 %inner, %c
  %x1 = mul i32 %outer, %x
  %r1 = insertelement <2 x i32> undef, i32 %outer, i32 0
  %r0 = insertelement <2 x i32> %r1, i32 %x1, i32 1
  %bc = bitcast <2 x i32> %r0 to <2 x float>
  ret <2 x float> %bc
}

define amdgpu_ps <2 x float> @add3_multiuse_inner(i32 %a, i32 %b, i32 %c) {
; VI-LABEL: add3_multiuse_inner:
; VI:       ; %bb.0:
; VI-NEXT:    v_add_u32_e32 v0, vcc, v0, v1
; VI-NEXT:    v_add_u32_e32 v1, vcc, v0, v2
; VI-NEXT:    ; return to shader part epilog
;
; GFX9-LABEL: add3_multiuse_inner:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    v_add_u32_e32 v0, v0, v1
; GFX9-NEXT:    v_add_u32_e32 v1, v0, v2
; GFX9-NEXT:    ; return to shader part epilog
  %inner = add i32 %a, %b
  %outer = add i32 %inner, %c
  %r1 = insertelement <2 x i32> undef, i32 %inner, i32 0
  %r0 = insertelement <2 x i32> %r1, i32 %outer, i32 1
  %bc = bitcast <2 x i32> %r0 to <2 x float>
  ret <2 x float> %bc
}

; A case where uniform values end up in VGPRs -- we could use v_add3_u32 here,
; but we don't.
define amdgpu_ps float @add3_uniform_vgpr(float inreg %a, float inreg %b, float inreg %c) {
; VI-LABEL: add3_uniform_vgpr:
; VI:       ; %bb.0:
; VI-NEXT:    v_mov_b32_e32 v2, 0x40400000
; VI-NEXT:    v_add_f32_e64 v0, s2, 1.0
; VI-NEXT:    v_add_f32_e64 v1, s3, 2.0
; VI-NEXT:    v_add_f32_e32 v2, s4, v2
; VI-NEXT:    v_add_u32_e32 v0, vcc, v1, v0
; VI-NEXT:    v_add_u32_e32 v0, vcc, v2, v0
; VI-NEXT:    ; return to shader part epilog
;
; GFX9-LABEL: add3_uniform_vgpr:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    v_mov_b32_e32 v2, 0x40400000
; GFX9-NEXT:    v_add_f32_e64 v0, s2, 1.0
; GFX9-NEXT:    v_add_f32_e64 v1, s3, 2.0
; GFX9-NEXT:    v_add_f32_e32 v2, s4, v2
; GFX9-NEXT:    v_add_u32_e32 v0, v0, v1
; GFX9-NEXT:    v_add_u32_e32 v0, v0, v2
; GFX9-NEXT:    ; return to shader part epilog
  %a1 = fadd float %a, 1.0
  %b2 = fadd float %b, 2.0
  %c3 = fadd float %c, 3.0
  %bc.a = bitcast float %a1 to i32
  %bc.b = bitcast float %b2 to i32
  %bc.c = bitcast float %c3 to i32
  %x = add i32 %bc.a, %bc.b
  %result = add i32 %x, %bc.c
  %bc = bitcast i32 %result to float
  ret float %bc
}
