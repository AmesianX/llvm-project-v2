; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=amdgcn-- -mcpu=pitcairn -verify-machineinstrs < %s | FileCheck -check-prefix=GCN %s

define amdgpu_kernel void @zext_shl64_to_32(i64 addrspace(1)* nocapture %out, i32 %x) {
; GCN-LABEL: zext_shl64_to_32:
; GCN:       ; %bb.0:
; GCN-NEXT:    s_load_dwordx2 s[4:5], s[0:1], 0x9
; GCN-NEXT:    s_load_dword s0, s[0:1], 0xb
; GCN-NEXT:    s_mov_b32 s7, 0xf000
; GCN-NEXT:    s_mov_b32 s6, -1
; GCN-NEXT:    v_mov_b32_e32 v1, 0
; GCN-NEXT:    s_waitcnt lgkmcnt(0)
; GCN-NEXT:    s_lshl_b32 s0, s0, 2
; GCN-NEXT:    v_mov_b32_e32 v0, s0
; GCN-NEXT:    buffer_store_dwordx2 v[0:1], off, s[4:7], 0
; GCN-NEXT:    s_endpgm
  %and = and i32 %x, 1073741823
  %ext = zext i32 %and to i64
  %shl = shl i64 %ext, 2
  store i64 %shl, i64 addrspace(1)* %out, align 4
  ret void
}

define amdgpu_kernel void @sext_shl64_to_32(i64 addrspace(1)* nocapture %out, i32 %x) {
; GCN-LABEL: sext_shl64_to_32:
; GCN:       ; %bb.0:
; GCN-NEXT:    s_load_dwordx2 s[4:5], s[0:1], 0x9
; GCN-NEXT:    s_load_dword s0, s[0:1], 0xb
; GCN-NEXT:    s_mov_b32 s7, 0xf000
; GCN-NEXT:    s_mov_b32 s6, -1
; GCN-NEXT:    v_mov_b32_e32 v1, 0
; GCN-NEXT:    s_waitcnt lgkmcnt(0)
; GCN-NEXT:    s_and_b32 s0, s0, 0x1fffffff
; GCN-NEXT:    s_lshl_b32 s0, s0, 2
; GCN-NEXT:    v_mov_b32_e32 v0, s0
; GCN-NEXT:    buffer_store_dwordx2 v[0:1], off, s[4:7], 0
; GCN-NEXT:    s_endpgm
  %and = and i32 %x, 536870911
  %ext = sext i32 %and to i64
  %shl = shl i64 %ext, 2
  store i64 %shl, i64 addrspace(1)* %out, align 4
  ret void
}

define amdgpu_kernel void @zext_shl64_overflow(i64 addrspace(1)* nocapture %out, i32 %x) {
; GCN-LABEL: zext_shl64_overflow:
; GCN:       ; %bb.0:
; GCN-NEXT:    s_load_dwordx2 s[4:5], s[0:1], 0x9
; GCN-NEXT:    s_load_dword s0, s[0:1], 0xb
; GCN-NEXT:    s_mov_b32 s1, 0
; GCN-NEXT:    s_mov_b32 s7, 0xf000
; GCN-NEXT:    s_mov_b32 s6, -1
; GCN-NEXT:    s_waitcnt lgkmcnt(0)
; GCN-NEXT:    s_bitset0_b32 s0, 31
; GCN-NEXT:    s_lshl_b64 s[0:1], s[0:1], 2
; GCN-NEXT:    v_mov_b32_e32 v0, s0
; GCN-NEXT:    v_mov_b32_e32 v1, s1
; GCN-NEXT:    buffer_store_dwordx2 v[0:1], off, s[4:7], 0
; GCN-NEXT:    s_endpgm
  %and = and i32 %x, 2147483647
  %ext = zext i32 %and to i64
  %shl = shl i64 %ext, 2
  store i64 %shl, i64 addrspace(1)* %out, align 4
  ret void
}

define amdgpu_kernel void @sext_shl64_overflow(i64 addrspace(1)* nocapture %out, i32 %x) {
; GCN-LABEL: sext_shl64_overflow:
; GCN:       ; %bb.0:
; GCN-NEXT:    s_load_dwordx2 s[4:5], s[0:1], 0x9
; GCN-NEXT:    s_load_dword s0, s[0:1], 0xb
; GCN-NEXT:    s_mov_b32 s1, 0
; GCN-NEXT:    s_mov_b32 s7, 0xf000
; GCN-NEXT:    s_mov_b32 s6, -1
; GCN-NEXT:    s_waitcnt lgkmcnt(0)
; GCN-NEXT:    s_bitset0_b32 s0, 31
; GCN-NEXT:    s_lshl_b64 s[0:1], s[0:1], 2
; GCN-NEXT:    v_mov_b32_e32 v0, s0
; GCN-NEXT:    v_mov_b32_e32 v1, s1
; GCN-NEXT:    buffer_store_dwordx2 v[0:1], off, s[4:7], 0
; GCN-NEXT:    s_endpgm
  %and = and i32 %x, 2147483647
  %ext = sext i32 %and to i64
  %shl = shl i64 %ext, 2
  store i64 %shl, i64 addrspace(1)* %out, align 4
  ret void
}

define amdgpu_kernel void @mulu24_shl64(i32 addrspace(1)* nocapture %arg) {
; GCN-LABEL: mulu24_shl64:
; GCN:       ; %bb.0: ; %bb
; GCN-NEXT:    s_load_dwordx2 s[0:1], s[0:1], 0x9
; GCN-NEXT:    v_and_b32_e32 v0, 6, v0
; GCN-NEXT:    v_mul_u32_u24_e32 v0, 7, v0
; GCN-NEXT:    s_mov_b32 s3, 0xf000
; GCN-NEXT:    s_mov_b32 s2, 0
; GCN-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; GCN-NEXT:    v_mov_b32_e32 v1, 0
; GCN-NEXT:    s_waitcnt lgkmcnt(0)
; GCN-NEXT:    buffer_store_dword v1, v[0:1], s[0:3], 0 addr64
; GCN-NEXT:    s_endpgm
bb:
  %tmp = tail call i32 @llvm.amdgcn.workitem.id.x()
  %tmp1 = and i32 %tmp, 6
  %mulconv = mul nuw nsw i32 %tmp1, 7
  %tmp2 = zext i32 %mulconv to i64
  %tmp3 = getelementptr inbounds i32, i32 addrspace(1)* %arg, i64 %tmp2
  store i32 0, i32 addrspace(1)* %tmp3, align 4
  ret void
}

define amdgpu_kernel void @muli24_shl64(i64 addrspace(1)* nocapture %arg, i32 addrspace(1)* nocapture readonly %arg1) {
; GCN-LABEL: muli24_shl64:
; GCN:       ; %bb.0: ; %bb
; GCN-NEXT:    s_load_dwordx4 s[0:3], s[0:1], 0x9
; GCN-NEXT:    v_mov_b32_e32 v2, 0
; GCN-NEXT:    s_mov_b32 s7, 0xf000
; GCN-NEXT:    s_mov_b32 s6, 0
; GCN-NEXT:    v_lshlrev_b32_e32 v1, 2, v0
; GCN-NEXT:    s_waitcnt lgkmcnt(0)
; GCN-NEXT:    s_mov_b64 s[4:5], s[2:3]
; GCN-NEXT:    buffer_load_dword v1, v[1:2], s[4:7], 0 addr64
; GCN-NEXT:    v_lshlrev_b32_e32 v3, 3, v0
; GCN-NEXT:    s_mov_b64 s[2:3], s[6:7]
; GCN-NEXT:    v_mov_b32_e32 v4, v2
; GCN-NEXT:    s_waitcnt vmcnt(0)
; GCN-NEXT:    v_or_b32_e32 v0, 0x800000, v1
; GCN-NEXT:    v_mul_i32_i24_e32 v0, 0xfffff9, v0
; GCN-NEXT:    v_lshlrev_b32_e32 v1, 3, v0
; GCN-NEXT:    buffer_store_dwordx2 v[1:2], v[3:4], s[0:3], 0 addr64
; GCN-NEXT:    s_endpgm
bb:
  %tmp = tail call i32 @llvm.amdgcn.workitem.id.x()
  %tmp2 = sext i32 %tmp to i64
  %tmp3 = getelementptr inbounds i32, i32 addrspace(1)* %arg1, i64 %tmp2
  %tmp4 = load i32, i32 addrspace(1)* %tmp3, align 4
  %tmp5 = or i32 %tmp4, -8388608
  %tmp6 = mul nsw i32 %tmp5, -7
  %tmp7 = zext i32 %tmp6 to i64
  %tmp8 = shl nuw nsw i64 %tmp7, 3
  %tmp9 = getelementptr inbounds i64, i64 addrspace(1)* %arg, i64 %tmp2
  store i64 %tmp8, i64 addrspace(1)* %tmp9, align 8
  ret void
}

declare i32 @llvm.amdgcn.workitem.id.x()
