# REQUIRES: x86

# RUN: echo '.section .text,"ax"; .quad 0' > %t.s
# RUN: echo '.section .foo,"ax"; .quad 0' >> %t.s
# RUN: llvm-mc -filetype=obj -triple=x86_64-pc-linux %t.s -o %t.o
# RUN: ld.lld --hash-style=sysv -o %t1 --script %s  \
# RUN:   %t.o -shared
# RUN: llvm-readobj -elf-output-style=GNU -l %t1 | FileCheck %s

# CHECK:      Segment Sections...
# CHECK-NEXT:   00     .text .dynsym .hash .dynstr .dynamic
# CHECK-NEXT:   01     .bar .foo

PHDRS {
  ph_write PT_LOAD FLAGS(2);
  ph_exec  PT_LOAD FLAGS(1);
}

SECTIONS {
  .bar : { *(.bar) } : ph_exec
  .foo : { *(.foo) }
  .text : { *(.text) } : ph_write
}
