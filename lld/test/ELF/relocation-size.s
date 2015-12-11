// RUN: llvm-mc -filetype=obj -triple=x86_64-unknown-linux %s -o %t.o
// RUN: ld.lld %t.o -o %t1
// RUN: llvm-readobj -r %t1 | FileCheck --check-prefix=NORELOC %s
// RUN: llvm-objdump -d %t1 | FileCheck --check-prefix=DISASM %s
// RUN: ld.lld -shared %t.o -o %t1
// RUN: llvm-readobj -r %t1 | FileCheck --check-prefix=RELOCSHARED %s
// RUN: llvm-objdump -d %t1 | FileCheck --check-prefix=DISASMSHARED %s

// NORELOC:      Relocations [
// NORELOC-NEXT: ]

// DISASM:      Disassembly of section .text:
// DISASM-NEXT: _data:
// DISASM-NEXT: 11000: 19 00
// DISASM-NEXT: 11002: 00 00
// DISASM-NEXT: 11004: 00 00
// DISASM-NEXT: 11006: 00 00
// DISASM-NEXT: 11008: 1a 00
// DISASM-NEXT: 1100a: 00 00
// DISASM-NEXT: 1100c: 00 00
// DISASM-NEXT: 1100e: 00 00
// DISASM-NEXT: 11010: 1b 00
// DISASM-NEXT: 11012: 00 00
// DISASM-NEXT: 11014: 00 00
// DISASM-NEXT: 11016: 00 00
// DISASM-NEXT: 11018: 19 00
// DISASM-NEXT: 1101a: 00 00
// DISASM-NEXT: 1101c: 00 00
// DISASM-NEXT: 1101e: 00 00
// DISASM-NEXT: 11020: 1a 00
// DISASM-NEXT: 11022: 00 00
// DISASM-NEXT: 11024: 00 00
// DISASM-NEXT: 11026: 00 00
// DISASM-NEXT: 11028: 1b 00
// DISASM-NEXT: 1102a: 00 00
// DISASM-NEXT: 1102c: 00 00
// DISASM-NEXT: 1102e: 00 00
// DISASM:      _start:
// DISASM-NEXT: 11030: 8b 04 25 19 00 00 00 movl 25, %eax
// DISASM-NEXT: 11037: 8b 04 25 1a 00 00 00 movl 26, %eax
// DISASM-NEXT: 1103e: 8b 04 25 1b 00 00 00 movl 27, %eax
// DISASM-NEXT: 11045: 8b 04 25 19 00 00 00 movl 25, %eax
// DISASM-NEXT: 1104c: 8b 04 25 1a 00 00 00 movl 26, %eax
// DISASM-NEXT: 11053: 8b 04 25 1b 00 00 00 movl 27, %eax

// RELOCSHARED:      Relocations [
// RELOCSHARED-NEXT: Section ({{.*}}) .rela.dyn {
// RELOCSHARED-NEXT:    0x1000 R_X86_64_SIZE64 foo 0xFFFFFFFFFFFFFFFF
// RELOCSHARED-NEXT:    0x1008 R_X86_64_SIZE64 foo 0x0
// RELOCSHARED-NEXT:    0x1010 R_X86_64_SIZE64 foo 0x1
// RELOCSHARED-NEXT:    0x1033 R_X86_64_SIZE32 foo 0xFFFFFFFFFFFFFFFF
// RELOCSHARED-NEXT:    0x103A R_X86_64_SIZE32 foo 0x0
// RELOCSHARED-NEXT:    0x1041 R_X86_64_SIZE32 foo 0x1
// RELOCSHARED-NEXT:  }
// RELOCSHARED-NEXT: ]

// DISASMSHARED:      Disassembly of section .text:
// DISASMSHARED-NEXT: _data:
// DISASMSHARED-NEXT: 1000: 00 00
// DISASMSHARED-NEXT: 1002: 00 00
// DISASMSHARED-NEXT: 1004: 00 00
// DISASMSHARED-NEXT: 1006: 00 00
// DISASMSHARED-NEXT: 1008: 00 00
// DISASMSHARED-NEXT: 100a: 00 00
// DISASMSHARED-NEXT: 100c: 00 00
// DISASMSHARED-NEXT: 100e: 00 00
// DISASMSHARED-NEXT: 1010: 00 00
// DISASMSHARED-NEXT: 1012: 00 00
// DISASMSHARED-NEXT: 1014: 00 00
// DISASMSHARED-NEXT: 1016: 00 00
// DISASMSHARED-NEXT: 1018: 19 00
// DISASMSHARED-NEXT: 101a: 00 00
// DISASMSHARED-NEXT: 101c: 00 00
// DISASMSHARED-NEXT: 101e: 00 00
// DISASMSHARED-NEXT: 1020: 1a 00
// DISASMSHARED-NEXT: 1022: 00 00
// DISASMSHARED-NEXT: 1024: 00 00
// DISASMSHARED-NEXT: 1026: 00 00
// DISASMSHARED-NEXT: 1028: 1b 00
// DISASMSHARED-NEXT: 102a: 00 00
// DISASMSHARED-NEXT: 102c: 00 00
// DISASMSHARED-NEXT: 102e: 00 00
// DISASMSHARED:      _start:
// DISASMSHARED-NEXT: 1030: 8b 04 25 00 00 00 00 movl 0, %eax
// DISASMSHARED-NEXT: 1037: 8b 04 25 00 00 00 00 movl 0, %eax
// DISASMSHARED-NEXT: 103e: 8b 04 25 00 00 00 00 movl 0, %eax
// DISASMSHARED-NEXT: 1045: 8b 04 25 19 00 00 00 movl 25, %eax
// DISASMSHARED-NEXT: 104c: 8b 04 25 1a 00 00 00 movl 26, %eax
// DISASMSHARED-NEXT: 1053: 8b 04 25 1b 00 00 00 movl 27, %eax

.data
.global foo
.type foo,%object
.size foo,26
foo:
.zero 26

.data
.global foohidden
.hidden foohidden
.type foohidden,%object
.size foohidden,26
foohidden:
.zero 26

.text
_data:
  // R_X86_64_SIZE64:
  .quad foo@SIZE-1
  .quad foo@SIZE
  .quad foo@SIZE+1
  .quad foohidden@SIZE-1
  .quad foohidden@SIZE
  .quad foohidden@SIZE+1
.globl _start
_start:
  // R_X86_64_SIZE32:
  movl foo@SIZE-1,%eax
  movl foo@SIZE,%eax
  movl foo@SIZE+1,%eax
  movl foohidden@SIZE-1,%eax
  movl foohidden@SIZE,%eax
  movl foohidden@SIZE+1,%eax
