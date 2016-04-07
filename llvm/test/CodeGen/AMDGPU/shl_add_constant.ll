; RUN: llc -march=amdgcn -mcpu=SI -verify-machineinstrs < %s | FileCheck -check-prefix=SI %s

declare i32 @llvm.r600.read.tidig.x() #1

; Test with inline immediate

; FUNC-LABEL: {{^}}shl_2_add_9_i32:
; SI: v_lshlrev_b32_e32  [[REG:v[0-9]+]], 2, {{v[0-9]+}}
; SI: v_add_i32_e32 [[RESULT:v[0-9]+]], vcc, 36, [[REG]]
; SI: buffer_store_dword [[RESULT]]
; SI: s_endpgm
define void @shl_2_add_9_i32(i32 addrspace(1)* %out, i32 addrspace(1)* %in) #0 {
  %tid.x = tail call i32 @llvm.r600.read.tidig.x() #1
  %ptr = getelementptr i32, i32 addrspace(1)* %in, i32 %tid.x
  %val = load i32, i32 addrspace(1)* %ptr, align 4
  %add = add i32 %val, 9
  %result = shl i32 %add, 2
  store i32 %result, i32 addrspace(1)* %out, align 4
  ret void
}

; FUNC-LABEL: {{^}}shl_2_add_9_i32_2_add_uses:
; SI-DAG: v_add_i32_e32 [[ADDREG:v[0-9]+]], vcc, 9, {{v[0-9]+}}
; SI-DAG: v_lshlrev_b32_e32 [[SHLREG:v[0-9]+]], 2, {{v[0-9]+}}
; SI-DAG: buffer_store_dword [[ADDREG]]
; SI-DAG: buffer_store_dword [[SHLREG]]
; SI: s_endpgm
define void @shl_2_add_9_i32_2_add_uses(i32 addrspace(1)* %out0, i32 addrspace(1)* %out1, i32 addrspace(1)* %in) #0 {
  %tid.x = tail call i32 @llvm.r600.read.tidig.x() #1
  %ptr = getelementptr i32, i32 addrspace(1)* %in, i32 %tid.x
  %val = load i32, i32 addrspace(1)* %ptr, align 4
  %add = add i32 %val, 9
  %result = shl i32 %add, 2
  store i32 %result, i32 addrspace(1)* %out0, align 4
  store i32 %add, i32 addrspace(1)* %out1, align 4
  ret void
}

; Test with add literal constant

; FUNC-LABEL: {{^}}shl_2_add_999_i32:
; SI: v_lshlrev_b32_e32  [[REG:v[0-9]+]], 2, {{v[0-9]+}}
; SI: v_add_i32_e32 [[RESULT:v[0-9]+]], vcc, 0xf9c, [[REG]]
; SI: buffer_store_dword [[RESULT]]
; SI: s_endpgm
define void @shl_2_add_999_i32(i32 addrspace(1)* %out, i32 addrspace(1)* %in) #0 {
  %tid.x = tail call i32 @llvm.r600.read.tidig.x() #1
  %ptr = getelementptr i32, i32 addrspace(1)* %in, i32 %tid.x
  %val = load i32, i32 addrspace(1)* %ptr, align 4
  %shl = add i32 %val, 999
  %result = shl i32 %shl, 2
  store i32 %result, i32 addrspace(1)* %out, align 4
  ret void
}

; FUNC-LABEL: {{^}}test_add_shl_add_constant:
; SI-DAG: s_load_dword [[X:s[0-9]+]], s{{\[[0-9]+:[0-9]+\]}}, 0xb
; SI-DAG: s_load_dword [[Y:s[0-9]+]], s{{\[[0-9]+:[0-9]+\]}}, 0xc
; SI: s_lshl_b32 [[SHL3:s[0-9]+]], [[X]], 3
; SI: s_add_i32 [[TMP:s[0-9]+]], [[SHL3]], [[Y]]
; SI: s_add_i32 [[RESULT:s[0-9]+]], [[TMP]], 0x3d8
; SI: v_mov_b32_e32 [[VRESULT:v[0-9]+]], [[RESULT]]
; SI: buffer_store_dword [[VRESULT]]
define void @test_add_shl_add_constant(i32 addrspace(1)* %out, i32 %x, i32 %y) #0 {
  %add.0 = add i32 %x, 123
  %shl = shl i32 %add.0, 3
  %add.1 = add i32 %shl, %y
   store i32 %add.1, i32 addrspace(1)* %out, align 4
  ret void
}

; FUNC-LABEL: {{^}}test_add_shl_add_constant_inv:
; SI-DAG: s_load_dword [[X:s[0-9]+]], s{{\[[0-9]+:[0-9]+\]}}, 0xb
; SI-DAG: s_load_dword [[Y:s[0-9]+]], s{{\[[0-9]+:[0-9]+\]}}, 0xc
; SI: s_lshl_b32 [[SHL3:s[0-9]+]], [[X]], 3
; SI: s_add_i32 [[TMP:s[0-9]+]], [[SHL3]], [[Y]]
; SI: s_add_i32 [[RESULT:s[0-9]+]], [[TMP]], 0x3d8
; SI: v_mov_b32_e32 [[VRESULT:v[0-9]+]], [[RESULT]]
; SI: buffer_store_dword [[VRESULT]]

define void @test_add_shl_add_constant_inv(i32 addrspace(1)* %out, i32 %x, i32 %y) #0 {
  %add.0 = add i32 %x, 123
  %shl = shl i32 %add.0, 3
  %add.1 = add i32 %y, %shl
  store i32 %add.1, i32 addrspace(1)* %out, align 4
  ret void
}

attributes #0 = { nounwind }
attributes #1 = { nounwind readnone }
