// RUN: llvm-mc -filetype=obj -triple=x86_64-pc-linux %s -o %t.o
// RUN: ld.lld -static %t.o -o %tout
// RUN: llvm-readobj -symbols %tout | FileCheck %s
// REQUIRES: x86

// Check that no __rela_iplt_end/__rela_iplt_start
// appear in symtab if there is no references to them.
// CHECK:      Symbols [
// CHECK-NEXT-NOT: __rela_iplt_end
// CHECK-NEXT-NOT: __rela_iplt_start
// CHECK: ]

.text
.type foo STT_GNU_IFUNC
.globl foo
.type foo, @function
foo:
 ret

.type bar STT_GNU_IFUNC
.globl bar
.type bar, @function
bar:
 ret

.globl _start
_start:
 call foo
 call bar
