# REQUIRES: x86
# REQUIRES: zlib

# RUN: llvm-mc -filetype=obj -triple=i386-pc-linux %s -o %t.o
# RUN: ld.lld %t.o -o %t1 --compress-debug-sections=zlib

# RUN: llvm-objdump -s %t1 | FileCheck %s --check-prefix=ZLIBCONTENT
# ZLIBCONTENT:     Contents of section .debug_str:
# ZLIBCONTENT-NOT: AAAAAAAAA

# RUN: llvm-readobj -s %t1 | FileCheck %s --check-prefix=ZLIBFLAGS
# ZLIBFLAGS:       Section {
# ZLIBFLAGS:         Index:
# ZLIBFLAGS:         Name: .debug_str
# ZLIBFLAGS-NEXT:    Type: SHT_PROGBITS
# ZLIBFLAGS-NEXT:    Flags [
# ZLIBFLAGS-NEXT:      SHF_COMPRESSED

# RUN: llvm-dwarfdump %t1 -debug-dump=str | \
# RUN:   FileCheck %s --check-prefix=DEBUGSTR
# DEBUGSTR:     .debug_str contents:
# DEBUGSTR-NEXT:  AAAAAAAAAAAAAAAAAAAAAAAAAAA
# DEBUGSTR-NEXT:  BBBBBBBBBBBBBBBBBBBBBBBBBBB

.section .debug_str,"MS",@progbits,1
.Linfo_string0:
  .asciz "AAAAAAAAAAAAAAAAAAAAAAAAAAA"
.Linfo_string1:
  .asciz "BBBBBBBBBBBBBBBBBBBBBBBBBBB"
