; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc  -O0 -mtriple=mipsel-linux-gnu -global-isel  -verify-machineinstrs %s -o -| FileCheck %s -check-prefixes=MIPS32

; sdiv
define signext i8 @sdiv_i8(i8 signext %a, i8 signext %b) {
; MIPS32-LABEL: sdiv_i8:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    sll $1, $5, 24
; MIPS32-NEXT:    sra $1, $1, 24
; MIPS32-NEXT:    sll $2, $4, 24
; MIPS32-NEXT:    sra $2, $2, 24
; MIPS32-NEXT:    div $zero, $1, $2
; MIPS32-NEXT:    teq $2, $zero, 7
; MIPS32-NEXT:    mflo $1
; MIPS32-NEXT:    sll $1, $1, 24
; MIPS32-NEXT:    sra $2, $1, 24
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %div = sdiv i8 %b, %a
  ret i8 %div
}

define signext i16 @sdiv_i16(i16 signext %a, i16 signext %b) {
; MIPS32-LABEL: sdiv_i16:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    sll $1, $5, 16
; MIPS32-NEXT:    sra $1, $1, 16
; MIPS32-NEXT:    sll $2, $4, 16
; MIPS32-NEXT:    sra $2, $2, 16
; MIPS32-NEXT:    div $zero, $1, $2
; MIPS32-NEXT:    teq $2, $zero, 7
; MIPS32-NEXT:    mflo $1
; MIPS32-NEXT:    sll $1, $1, 16
; MIPS32-NEXT:    sra $2, $1, 16
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %div = sdiv i16 %b, %a
  ret i16 %div
}

define signext i32 @sdiv_i32(i32 signext %a, i32 signext %b) {
; MIPS32-LABEL: sdiv_i32:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    div $zero, $5, $4
; MIPS32-NEXT:    teq $4, $zero, 7
; MIPS32-NEXT:    mflo $2
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %div = sdiv i32 %b, %a
  ret i32 %div
}

define signext i64 @sdiv_i64(i64 signext %a, i64 signext %b) {
; MIPS32-LABEL: sdiv_i64:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addiu $sp, $sp, -32
; MIPS32-NEXT:    .cfi_def_cfa_offset 32
; MIPS32-NEXT:    sw $ra, 28($sp) # 4-byte Folded Spill
; MIPS32-NEXT:    .cfi_offset 31, -4
; MIPS32-NEXT:    sw $4, 24($sp) # 4-byte Folded Spill
; MIPS32-NEXT:    move $4, $6
; MIPS32-NEXT:    sw $5, 20($sp) # 4-byte Folded Spill
; MIPS32-NEXT:    move $5, $7
; MIPS32-NEXT:    lw $6, 24($sp) # 4-byte Folded Reload
; MIPS32-NEXT:    lw $7, 20($sp) # 4-byte Folded Reload
; MIPS32-NEXT:    jal __divdi3
; MIPS32-NEXT:    nop
; MIPS32-NEXT:    lw $ra, 28($sp) # 4-byte Folded Reload
; MIPS32-NEXT:    addiu $sp, $sp, 32
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %div = sdiv i64 %b, %a
  ret i64 %div
}

; srem
define signext i8 @srem_i8(i8 signext %a, i8 signext %b) {
; MIPS32-LABEL: srem_i8:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    sll $1, $5, 24
; MIPS32-NEXT:    sra $1, $1, 24
; MIPS32-NEXT:    sll $2, $4, 24
; MIPS32-NEXT:    sra $2, $2, 24
; MIPS32-NEXT:    div $zero, $1, $2
; MIPS32-NEXT:    teq $2, $zero, 7
; MIPS32-NEXT:    mflo $1
; MIPS32-NEXT:    sll $1, $1, 24
; MIPS32-NEXT:    sra $2, $1, 24
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %div = sdiv i8 %b, %a
  ret i8 %div
}

define signext i16 @srem_i16(i16 signext %a, i16 signext %b) {
; MIPS32-LABEL: srem_i16:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    sll $1, $5, 16
; MIPS32-NEXT:    sra $1, $1, 16
; MIPS32-NEXT:    sll $2, $4, 16
; MIPS32-NEXT:    sra $2, $2, 16
; MIPS32-NEXT:    div $zero, $1, $2
; MIPS32-NEXT:    teq $2, $zero, 7
; MIPS32-NEXT:    mfhi $1
; MIPS32-NEXT:    sll $1, $1, 16
; MIPS32-NEXT:    sra $2, $1, 16
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %rem = srem i16 %b, %a
  ret i16 %rem
}

define signext i32 @srem_i32(i32 signext %a, i32 signext %b) {
; MIPS32-LABEL: srem_i32:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    div $zero, $5, $4
; MIPS32-NEXT:    teq $4, $zero, 7
; MIPS32-NEXT:    mfhi $2
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %rem = srem i32 %b, %a
  ret i32 %rem
}

define signext i64 @srem_i64(i64 signext %a, i64 signext %b) {
; MIPS32-LABEL: srem_i64:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addiu $sp, $sp, -32
; MIPS32-NEXT:    .cfi_def_cfa_offset 32
; MIPS32-NEXT:    sw $ra, 28($sp) # 4-byte Folded Spill
; MIPS32-NEXT:    .cfi_offset 31, -4
; MIPS32-NEXT:    sw $4, 24($sp) # 4-byte Folded Spill
; MIPS32-NEXT:    move $4, $6
; MIPS32-NEXT:    sw $5, 20($sp) # 4-byte Folded Spill
; MIPS32-NEXT:    move $5, $7
; MIPS32-NEXT:    lw $6, 24($sp) # 4-byte Folded Reload
; MIPS32-NEXT:    lw $7, 20($sp) # 4-byte Folded Reload
; MIPS32-NEXT:    jal __moddi3
; MIPS32-NEXT:    nop
; MIPS32-NEXT:    lw $ra, 28($sp) # 4-byte Folded Reload
; MIPS32-NEXT:    addiu $sp, $sp, 32
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %rem = srem i64 %b, %a
  ret i64 %rem
}

; udiv
define signext i8 @udiv_i8(i8 signext %a, i8 signext %b) {
; MIPS32-LABEL: udiv_i8:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    ori $1, $zero, 255
; MIPS32-NEXT:    and $1, $5, $1
; MIPS32-NEXT:    ori $2, $zero, 255
; MIPS32-NEXT:    and $2, $4, $2
; MIPS32-NEXT:    divu $zero, $1, $2
; MIPS32-NEXT:    teq $2, $zero, 7
; MIPS32-NEXT:    mflo $1
; MIPS32-NEXT:    sll $1, $1, 24
; MIPS32-NEXT:    sra $2, $1, 24
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %div = udiv i8 %b, %a
  ret i8 %div
}

define signext i16 @udiv_i16(i16 signext %a, i16 signext %b) {
; MIPS32-LABEL: udiv_i16:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    ori $1, $zero, 65535
; MIPS32-NEXT:    and $1, $5, $1
; MIPS32-NEXT:    ori $2, $zero, 65535
; MIPS32-NEXT:    and $2, $4, $2
; MIPS32-NEXT:    divu $zero, $1, $2
; MIPS32-NEXT:    teq $2, $zero, 7
; MIPS32-NEXT:    mflo $1
; MIPS32-NEXT:    sll $1, $1, 16
; MIPS32-NEXT:    sra $2, $1, 16
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %div = udiv i16 %b, %a
  ret i16 %div
}

define signext i32 @udiv_i32(i32 signext %a, i32 signext %b) {
; MIPS32-LABEL: udiv_i32:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    divu $zero, $5, $4
; MIPS32-NEXT:    teq $4, $zero, 7
; MIPS32-NEXT:    mflo $2
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %div = udiv i32 %b, %a
  ret i32 %div
}

define signext i64 @udiv_i64(i64 signext %a, i64 signext %b) {
; MIPS32-LABEL: udiv_i64:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addiu $sp, $sp, -32
; MIPS32-NEXT:    .cfi_def_cfa_offset 32
; MIPS32-NEXT:    sw $ra, 28($sp) # 4-byte Folded Spill
; MIPS32-NEXT:    .cfi_offset 31, -4
; MIPS32-NEXT:    sw $4, 24($sp) # 4-byte Folded Spill
; MIPS32-NEXT:    move $4, $6
; MIPS32-NEXT:    sw $5, 20($sp) # 4-byte Folded Spill
; MIPS32-NEXT:    move $5, $7
; MIPS32-NEXT:    lw $6, 24($sp) # 4-byte Folded Reload
; MIPS32-NEXT:    lw $7, 20($sp) # 4-byte Folded Reload
; MIPS32-NEXT:    jal __udivdi3
; MIPS32-NEXT:    nop
; MIPS32-NEXT:    lw $ra, 28($sp) # 4-byte Folded Reload
; MIPS32-NEXT:    addiu $sp, $sp, 32
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %div = udiv i64 %b, %a
  ret i64 %div
}

; urem
define signext i8 @urem_i8(i8 signext %a, i8 signext %b) {
; MIPS32-LABEL: urem_i8:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    ori $1, $zero, 255
; MIPS32-NEXT:    and $1, $5, $1
; MIPS32-NEXT:    ori $2, $zero, 255
; MIPS32-NEXT:    and $2, $4, $2
; MIPS32-NEXT:    divu $zero, $1, $2
; MIPS32-NEXT:    teq $2, $zero, 7
; MIPS32-NEXT:    mfhi $1
; MIPS32-NEXT:    sll $1, $1, 24
; MIPS32-NEXT:    sra $2, $1, 24
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %rem = urem i8 %b, %a
  ret i8 %rem
}

define signext i16 @urem_i16(i16 signext %a, i16 signext %b) {
; MIPS32-LABEL: urem_i16:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    ori $1, $zero, 65535
; MIPS32-NEXT:    and $1, $5, $1
; MIPS32-NEXT:    ori $2, $zero, 65535
; MIPS32-NEXT:    and $2, $4, $2
; MIPS32-NEXT:    divu $zero, $1, $2
; MIPS32-NEXT:    teq $2, $zero, 7
; MIPS32-NEXT:    mfhi $1
; MIPS32-NEXT:    sll $1, $1, 16
; MIPS32-NEXT:    sra $2, $1, 16
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %rem = urem i16 %b, %a
  ret i16 %rem
}

define signext i32 @urem_i32(i32 signext %a, i32 signext %b) {
; MIPS32-LABEL: urem_i32:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    divu $zero, $5, $4
; MIPS32-NEXT:    teq $4, $zero, 7
; MIPS32-NEXT:    mfhi $2
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %rem = urem i32 %b, %a
  ret i32 %rem
}

define signext i64 @urem_i64(i64 signext %a, i64 signext %b) {
; MIPS32-LABEL: urem_i64:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addiu $sp, $sp, -32
; MIPS32-NEXT:    .cfi_def_cfa_offset 32
; MIPS32-NEXT:    sw $ra, 28($sp) # 4-byte Folded Spill
; MIPS32-NEXT:    .cfi_offset 31, -4
; MIPS32-NEXT:    sw $4, 24($sp) # 4-byte Folded Spill
; MIPS32-NEXT:    move $4, $6
; MIPS32-NEXT:    sw $5, 20($sp) # 4-byte Folded Spill
; MIPS32-NEXT:    move $5, $7
; MIPS32-NEXT:    lw $6, 24($sp) # 4-byte Folded Reload
; MIPS32-NEXT:    lw $7, 20($sp) # 4-byte Folded Reload
; MIPS32-NEXT:    jal __umoddi3
; MIPS32-NEXT:    nop
; MIPS32-NEXT:    lw $ra, 28($sp) # 4-byte Folded Reload
; MIPS32-NEXT:    addiu $sp, $sp, 32
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %rem = urem i64 %b, %a
  ret i64 %rem
}
