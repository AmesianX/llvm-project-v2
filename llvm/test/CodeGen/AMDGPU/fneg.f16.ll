; RUN: llc -march=amdgcn -mcpu=kaveri -mtriple=amdgcn--amdhsa -verify-machineinstrs < %s | FileCheck -check-prefix=CI -check-prefix=CIVI -check-prefix=GCN %s
; RUN: llc -march=amdgcn -mcpu=tonga -mtriple=amdgcn--amdhsa -verify-machineinstrs < %s | FileCheck -check-prefix=VI -check-prefix=CIVI -check-prefix=GCN %s
; RUN: llc -march=amdgcn -mcpu=gfx901 -mtriple=amdgcn--amdhsa -verify-machineinstrs < %s | FileCheck -check-prefix=GFX9 -check-prefix=GCN %s

; FIXME: Should be able to do scalar op
; GCN-LABEL: {{^}}s_fneg_f16:
define void @s_fneg_f16(half addrspace(1)* %out, half %in) #0 {
  %fneg = fsub half -0.0, %in
  store half %fneg, half addrspace(1)* %out
  ret void
}

; FIXME: Should be able to use bit operations when illegal type as
; well.

; GCN-LABEL: {{^}}v_fneg_f16:
; GCN: flat_load_ushort [[VAL:v[0-9]+]],
; GCN: v_xor_b32_e32 [[XOR:v[0-9]+]], 0x8000, [[VAL]]
; VI: flat_store_short v{{\[[0-9]+:[0-9]+\]}}, [[XOR]]
; SI: buffer_store_short [[XOR]]
define void @v_fneg_f16(half addrspace(1)* %out, half addrspace(1)* %in) #0 {
  %tid = call i32 @llvm.amdgcn.workitem.id.x()
  %gep.in = getelementptr inbounds half, half addrspace(1)* %in, i32 %tid
  %gep.out = getelementptr inbounds half, half addrspace(1)* %in, i32 %tid
  %val = load half, half addrspace(1)* %gep.in, align 2
  %fneg = fsub half -0.0, %val
  store half %fneg, half addrspace(1)* %gep.out
  ret void
}

; GCN-LABEL: {{^}}fneg_free_f16:
; GCN: flat_load_ushort [[NEG_VALUE:v[0-9]+]],

; XCI: s_xor_b32 [[XOR:s[0-9]+]], [[NEG_VALUE]], 0x8000{{$}}
; CI: v_xor_b32_e32 [[XOR:v[0-9]+]], 0x8000, [[NEG_VALUE]]
; CI: flat_store_short v{{\[[0-9]+:[0-9]+\]}}, [[XOR]]
define void @fneg_free_f16(half addrspace(1)* %out, i16 %in) #0 {
  %bc = bitcast i16 %in to half
  %fsub = fsub half -0.0, %bc
  store half %fsub, half addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}v_fneg_fold_f16:
; GCN: flat_load_ushort [[NEG_VALUE:v[0-9]+]]

; CI-DAG: v_cvt_f32_f16_e32 [[CVT_VAL:v[0-9]+]], [[NEG_VALUE]]
; CI-DAG: v_cvt_f32_f16_e64 [[NEG_CVT0:v[0-9]+]], -[[NEG_VALUE]]
; CI: v_mul_f32_e32 [[MUL:v[0-9]+]], [[CVT_VAL]], [[NEG_CVT0]]
; CI: v_cvt_f16_f32_e32 [[CVT1:v[0-9]+]], [[MUL]]
; CI: flat_store_short v{{\[[0-9]+:[0-9]+\]}}, [[CVT1]]

; VI-NOT: [[NEG_VALUE]]
; VI: v_mul_f16_e64 v{{[0-9]+}}, -[[NEG_VALUE]], [[NEG_VALUE]]
define void @v_fneg_fold_f16(half addrspace(1)* %out, half addrspace(1)* %in) #0 {
  %val = load half, half addrspace(1)* %in
  %fsub = fsub half -0.0, %val
  %fmul = fmul half %fsub, %val
  store half %fmul, half addrspace(1)* %out
  ret void
}

; FIXME: Terrible code with VI and even worse with SI/CI
; GCN-LABEL: {{^}}s_fneg_v2f16:
; CI: s_mov_b32 [[MASK:s[0-9]+]], 0x8000{{$}}
; CI: v_xor_b32_e32 v{{[0-9]+}}, [[MASK]], v{{[0-9]+}}
; CI: v_lshlrev_b32_e32 v{{[0-9]+}}, 16, v{{[0-9]+}}
; CI: v_xor_b32_e32 v{{[0-9]+}}, [[MASK]], v{{[0-9]+}}
; CI: v_or_b32_e32

; VI: v_mov_b32_e32 [[MASK:v[0-9]+]], 0x8000{{$}}
; VI: v_xor_b32_e32 v{{[0-9]+}}, v{{[0-9]+}}, [[MASK]]
; VI: v_xor_b32_e32 v{{[0-9]+}}, v{{[0-9]+}}, [[MASK]]

; GFX9: v_xor_b32_e32 v{{[0-9]+}}, 0x80008000, v{{[0-9]+}}
define void @s_fneg_v2f16(<2 x half> addrspace(1)* %out, <2 x half> %in) #0 {
  %fneg = fsub <2 x half> <half -0.0, half -0.0>, %in
  store <2 x half> %fneg, <2 x half> addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}v_fneg_v2f16:
; GCN: flat_load_dword [[VAL:v[0-9]+]]
; GCN: v_xor_b32_e32 v{{[0-9]+}}, 0x80008000, [[VAL]]
define void @v_fneg_v2f16(<2 x half> addrspace(1)* %out, <2 x half> addrspace(1)* %in) #0 {
  %tid = call i32 @llvm.amdgcn.workitem.id.x()
  %gep.in = getelementptr inbounds <2 x half>, <2 x half> addrspace(1)* %in, i32 %tid
  %gep.out = getelementptr inbounds <2 x half>, <2 x half> addrspace(1)* %in, i32 %tid
  %val = load <2 x half>, <2 x half> addrspace(1)* %gep.in, align 2
  %fneg = fsub <2 x half> <half -0.0, half -0.0>, %val
  store <2 x half> %fneg, <2 x half> addrspace(1)* %gep.out
  ret void
}

; GCN-LABEL: {{^}}fneg_free_v2f16:
; GCN: s_load_dword [[VAL:s[0-9]+]]
; CIVI: s_xor_b32 s{{[0-9]+}}, [[VAL]], 0x80008000

; GFX9: v_mov_b32_e32 [[VVAL:v[0-9]+]], [[VAL]]
; GFX9: v_xor_b32_e32 v{{[0-9]+}}, 0x80008000, [[VVAL]]
define void @fneg_free_v2f16(<2 x half> addrspace(1)* %out, i32 %in) #0 {
  %bc = bitcast i32 %in to <2 x half>
  %fsub = fsub <2 x half> <half -0.0, half -0.0>, %bc
  store <2 x half> %fsub, <2 x half> addrspace(1)* %out
  ret void
}

; GCN-LABEL: {{^}}v_fneg_fold_v2f16:
; GCN: flat_load_dword [[VAL:v[0-9]+]]

; CI: v_cvt_f32_f16_e64 v{{[0-9]+}}, -v{{[0-9]+}}
; CI: v_cvt_f32_f16_e64 v{{[0-9]+}}, -v{{[0-9]+}}
; CI: v_mul_f32_e32 v{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
; CI: v_cvt_f16_f32
; CI: v_mul_f32_e32 v{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}}
; CI: v_cvt_f16_f32

; VI: v_lshrrev_b32_e32 v{{[0-9]+}}, 16,
; VI: v_mul_f16_e64 v{{[0-9]+}}, -v{{[0-9]+}}, v{{[0-9]+}}
; VI: v_mul_f16_e64 v{{[0-9]+}}, -v{{[0-9]+}}, v{{[0-9]+}}

; GFX9: v_pk_mul_f16 v{{[0-9]+}}, v{{[0-9]+}}, v{{[0-9]+}} neg_lo:[1,0] neg_hi:[1,0]{{$}}
define void @v_fneg_fold_v2f16(<2 x half> addrspace(1)* %out, <2 x half> addrspace(1)* %in) #0 {
  %val = load <2 x half>, <2 x half> addrspace(1)* %in
  %fsub = fsub <2 x half> <half -0.0, half -0.0>, %val
  %fmul = fmul <2 x half> %fsub, %val
  store <2 x half> %fmul, <2 x half> addrspace(1)* %out
  ret void
}

declare i32 @llvm.amdgcn.workitem.id.x() #1

attributes #0 = { nounwind }
attributes #1 = { nounwind readnone }
