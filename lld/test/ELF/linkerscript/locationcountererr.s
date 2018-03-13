# REQUIRES: x86
# RUN: llvm-mc -filetype=obj -triple=x86_64-unknown-linux /dev/null -o %t
# RUN: not ld.lld %t --script %s -o %t1 2>&1 | FileCheck %s
# CHECK: {{.*}}.s:8: unable to move location counter backward for: .text

SECTIONS {
  .text 0x2000 : {
    . = 0x10;
    *(.text)
  }
}
