; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-pc-linux | FileCheck %s

define i64 @and1(i64 %x) {
; CHECK-LABEL: and1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movabsq $-2147483649, %rax # imm = 0xFFFFFFFF7FFFFFFF
; CHECK-NEXT:    andq %rdi, %rax
; CHECK-NEXT:    retq
  %a = and i64 %x, 18446744071562067967 ; clear bit 31
  ret i64 %a
}

define i64 @and2(i64 %x) {
; CHECK-LABEL: and2:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movabsq $-4294967297, %rax # imm = 0xFFFFFFFEFFFFFFFF
; CHECK-NEXT:    andq %rdi, %rax
; CHECK-NEXT:    retq
  %a = and i64 %x, 18446744069414584319 ; clear bit 32
  ret i64 %a
}

define i64 @and3(i64 %x) {
; CHECK-LABEL: and3:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movabsq $-4611686018427387905, %rax # imm = 0xBFFFFFFFFFFFFFFF
; CHECK-NEXT:    andq %rdi, %rax
; CHECK-NEXT:    retq
  %a = and i64 %x, 13835058055282163711 ; clear bit 62
  ret i64 %a
}

define i64 @and4(i64 %x) {
; CHECK-LABEL: and4:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movabsq $9223372036854775807, %rax # imm = 0x7FFFFFFFFFFFFFFF
; CHECK-NEXT:    andq %rdi, %rax
; CHECK-NEXT:    retq
  %a = and i64 %x, 9223372036854775807 ; clear bit 63
  ret i64 %a
}

define i64 @or1(i64 %x) {
; CHECK-LABEL: or1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl $2147483648, %eax # imm = 0x80000000
; CHECK-NEXT:    orq %rdi, %rax
; CHECK-NEXT:    retq
  %a = or i64 %x, 2147483648 ; set bit 31
  ret i64 %a
}

define i64 @or2(i64 %x) {
; CHECK-LABEL: or2:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movabsq $4294967296, %rax # imm = 0x100000000
; CHECK-NEXT:    orq %rdi, %rax
; CHECK-NEXT:    retq
  %a = or i64 %x, 4294967296 ; set bit 32
  ret i64 %a
}

define i64 @or3(i64 %x) {
; CHECK-LABEL: or3:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movabsq $4611686018427387904, %rax # imm = 0x4000000000000000
; CHECK-NEXT:    orq %rdi, %rax
; CHECK-NEXT:    retq
  %a = or i64 %x, 4611686018427387904 ; set bit 62
  ret i64 %a
}

define i64 @or4(i64 %x) {
; CHECK-LABEL: or4:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movabsq $-9223372036854775808, %rax # imm = 0x8000000000000000
; CHECK-NEXT:    orq %rdi, %rax
; CHECK-NEXT:    retq
  %a = or i64 %x, 9223372036854775808 ; set bit 63
  ret i64 %a
}

define i64 @xor1(i64 %x) {
; CHECK-LABEL: xor1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl $2147483648, %eax # imm = 0x80000000
; CHECK-NEXT:    xorq %rdi, %rax
; CHECK-NEXT:    retq
  %a = xor i64 %x, 2147483648 ; toggle bit 31
  ret i64 %a
}

define i64 @xor2(i64 %x) {
; CHECK-LABEL: xor2:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movabsq $4294967296, %rax # imm = 0x100000000
; CHECK-NEXT:    xorq %rdi, %rax
; CHECK-NEXT:    retq
  %a = xor i64 %x, 4294967296 ; toggle bit 32
  ret i64 %a
}

define i64 @xor3(i64 %x) {
; CHECK-LABEL: xor3:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movabsq $4611686018427387904, %rax # imm = 0x4000000000000000
; CHECK-NEXT:    xorq %rdi, %rax
; CHECK-NEXT:    retq
  %a = xor i64 %x, 4611686018427387904 ; toggle bit 62
  ret i64 %a
}

define i64 @xor4(i64 %x) {
; CHECK-LABEL: xor4:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movabsq $-9223372036854775808, %rax # imm = 0x8000000000000000
; CHECK-NEXT:    xorq %rdi, %rax
; CHECK-NEXT:    retq
  %a = xor i64 %x, 9223372036854775808 ; toggle bit 63
  ret i64 %a
}

define i64 @and1_optsize(i64 %x) optsize {
; CHECK-LABEL: and1_optsize:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movq %rdi, %rax
; CHECK-NEXT:    btrq $31, %rax
; CHECK-NEXT:    retq
  %a = and i64 %x, 18446744071562067967 ; clear bit 31
  ret i64 %a
}

define i64 @and2_optsize(i64 %x) optsize {
; CHECK-LABEL: and2_optsize:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movq %rdi, %rax
; CHECK-NEXT:    btrq $32, %rax
; CHECK-NEXT:    retq
  %a = and i64 %x, 18446744069414584319 ; clear bit 32
  ret i64 %a
}

define i64 @and3_optsize(i64 %x) optsize {
; CHECK-LABEL: and3_optsize:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movq %rdi, %rax
; CHECK-NEXT:    btrq $62, %rax
; CHECK-NEXT:    retq
  %a = and i64 %x, 13835058055282163711 ; clear bit 62
  ret i64 %a
}

define i64 @and4_optsize(i64 %x) optsize {
; CHECK-LABEL: and4_optsize:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movq %rdi, %rax
; CHECK-NEXT:    btrq $63, %rax
; CHECK-NEXT:    retq
  %a = and i64 %x, 9223372036854775807 ; clear bit 63
  ret i64 %a
}

define i64 @or1_optsize(i64 %x) optsize {
; CHECK-LABEL: or1_optsize:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movq %rdi, %rax
; CHECK-NEXT:    btsq $31, %rax
; CHECK-NEXT:    retq
  %a = or i64 %x, 2147483648 ; set bit 31
  ret i64 %a
}

define i64 @or2_optsize(i64 %x) optsize {
; CHECK-LABEL: or2_optsize:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movq %rdi, %rax
; CHECK-NEXT:    btsq $32, %rax
; CHECK-NEXT:    retq
  %a = or i64 %x, 4294967296 ; set bit 32
  ret i64 %a
}

define i64 @or3_optsize(i64 %x) optsize {
; CHECK-LABEL: or3_optsize:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movq %rdi, %rax
; CHECK-NEXT:    btsq $62, %rax
; CHECK-NEXT:    retq
  %a = or i64 %x, 4611686018427387904 ; set bit 62
  ret i64 %a
}

define i64 @or4_optsize(i64 %x) optsize {
; CHECK-LABEL: or4_optsize:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movq %rdi, %rax
; CHECK-NEXT:    btsq $63, %rax
; CHECK-NEXT:    retq
  %a = or i64 %x, 9223372036854775808 ; set bit 63
  ret i64 %a
}

define i64 @xor1_optsize(i64 %x) optsize {
; CHECK-LABEL: xor1_optsize:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movq %rdi, %rax
; CHECK-NEXT:    btcq $31, %rax
; CHECK-NEXT:    retq
  %a = xor i64 %x, 2147483648 ; toggle bit 31
  ret i64 %a
}

define i64 @xor2_optsize(i64 %x) optsize {
; CHECK-LABEL: xor2_optsize:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movq %rdi, %rax
; CHECK-NEXT:    btcq $32, %rax
; CHECK-NEXT:    retq
  %a = xor i64 %x, 4294967296 ; toggle bit 32
  ret i64 %a
}

define i64 @xor3_optsize(i64 %x) optsize {
; CHECK-LABEL: xor3_optsize:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movq %rdi, %rax
; CHECK-NEXT:    btcq $62, %rax
; CHECK-NEXT:    retq
  %a = xor i64 %x, 4611686018427387904 ; toggle bit 62
  ret i64 %a
}

define i64 @xor4_optsize(i64 %x) optsize {
; CHECK-LABEL: xor4_optsize:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movq %rdi, %rax
; CHECK-NEXT:    btcq $63, %rax
; CHECK-NEXT:    retq
  %a = xor i64 %x, 9223372036854775808 ; toggle bit 63
  ret i64 %a
}
