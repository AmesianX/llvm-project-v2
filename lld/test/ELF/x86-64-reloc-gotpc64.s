// REQUIRES: x86
// RUN: llvm-mc -filetype=obj -triple=x86_64-pc-linux %s -o %t.o
// RUN: ld.lld %t.o -shared -o %t.so
// RUN: llvm-readelf -S %t.so | FileCheck %s -check-prefix=SECTION
// RUN: llvm-objdump -d %t.so | FileCheck %s

// SECTION: .got PROGBITS 0000000000002070 002070 000000

// 0x2070 (.got end) - 0x1000 = 4208
// CHECK: gotpc64:
// CHECK-NEXT: 1000: {{.*}} movabsq $4208, %r11
.global gotpc64
gotpc64:
  movabsq $_GLOBAL_OFFSET_TABLE_-., %r11
