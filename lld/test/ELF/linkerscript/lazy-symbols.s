# REQUIRES: x86
# RUN: llvm-mc -filetype=obj -triple=x86_64-unknown-linux %S/Inputs/lazy-symbols.s -o %t1
# RUN: llvm-ar rcs %tar %t1
# RUN: llvm-mc -filetype=obj -triple=x86_64-unknown-linux /dev/null -o %t2
# RUN: ld.lld %t2 %tar --script %s -o %tout
# RUN: llvm-readobj -symbols %tout | FileCheck %s

foo = 1;

# This test is to ensure a linker script can define a symbol which have the same
# name as a lazy symbol.

# CHECK: Name: foo
# CHECK-NEXT: Value: 0x1
