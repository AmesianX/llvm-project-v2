; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=x86-64 | FileCheck %s --check-prefix=CHECK --check-prefix=GENERIC
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=atom | FileCheck %s --check-prefix=CHECK --check-prefix=ATOM
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=slm | FileCheck %s --check-prefix=CHECK --check-prefix=SLM
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=sandybridge | FileCheck %s --check-prefix=CHECK --check-prefix=SANDY
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=ivybridge | FileCheck %s --check-prefix=CHECK --check-prefix=SANDY
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=haswell | FileCheck %s --check-prefix=CHECK --check-prefix=HASWELL
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=broadwell | FileCheck %s --check-prefix=CHECK --check-prefix=BROADWELL
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=skylake | FileCheck %s --check-prefix=CHECK --check-prefix=SKYLAKE
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=skx | FileCheck %s --check-prefix=CHECK --check-prefix=SKX
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=btver2 | FileCheck %s --check-prefix=CHECK --check-prefix=BTVER2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -print-schedule -mcpu=znver1 | FileCheck %s --check-prefix=CHECK --check-prefix=ZNVER1

define i16 @test_bsf16(i16 %a0, i16* %a1) optsize {
; GENERIC-LABEL: test_bsf16:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    #APP
; GENERIC-NEXT:    bsfw %di, %ax # sched: [3:1.00]
; GENERIC-NEXT:    bsfw (%rsi), %cx # sched: [8:1.00]
; GENERIC-NEXT:    #NO_APP
; GENERIC-NEXT:    orl %ecx, %eax # sched: [1:0.33]
; GENERIC-NEXT:    # kill: %AX<def> %AX<kill> %EAX<kill>
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; ATOM-LABEL: test_bsf16:
; ATOM:       # BB#0:
; ATOM-NEXT:    #APP
; ATOM-NEXT:    bsfw %di, %ax # sched: [16:8.00]
; ATOM-NEXT:    bsfw (%rsi), %cx # sched: [16:8.00]
; ATOM-NEXT:    #NO_APP
; ATOM-NEXT:    orl %ecx, %eax # sched: [1:0.50]
; ATOM-NEXT:    # kill: %AX<def> %AX<kill> %EAX<kill>
; ATOM-NEXT:    retq # sched: [79:39.50]
;
; SLM-LABEL: test_bsf16:
; SLM:       # BB#0:
; SLM-NEXT:    #APP
; SLM-NEXT:    bsfw %di, %ax # sched: [1:1.00]
; SLM-NEXT:    bsfw (%rsi), %cx # sched: [4:1.00]
; SLM-NEXT:    #NO_APP
; SLM-NEXT:    orl %ecx, %eax # sched: [1:0.50]
; SLM-NEXT:    # kill: %AX<def> %AX<kill> %EAX<kill>
; SLM-NEXT:    retq # sched: [4:1.00]
;
; SANDY-LABEL: test_bsf16:
; SANDY:       # BB#0:
; SANDY-NEXT:    #APP
; SANDY-NEXT:    bsfw %di, %ax # sched: [3:1.00]
; SANDY-NEXT:    bsfw (%rsi), %cx # sched: [8:1.00]
; SANDY-NEXT:    #NO_APP
; SANDY-NEXT:    orl %ecx, %eax # sched: [1:0.33]
; SANDY-NEXT:    # kill: %AX<def> %AX<kill> %EAX<kill>
; SANDY-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_bsf16:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    #APP
; HASWELL-NEXT:    bsfw %di, %ax # sched: [3:1.00]
; HASWELL-NEXT:    bsfw (%rsi), %cx # sched: [3:1.00]
; HASWELL-NEXT:    #NO_APP
; HASWELL-NEXT:    orl %ecx, %eax # sched: [1:0.25]
; HASWELL-NEXT:    # kill: %AX<def> %AX<kill> %EAX<kill>
; HASWELL-NEXT:    retq # sched: [2:1.00]
;
; BROADWELL-LABEL: test_bsf16:
; BROADWELL:       # BB#0:
; BROADWELL-NEXT:    #APP
; BROADWELL-NEXT:    bsfw %di, %ax # sched: [3:1.00]
; BROADWELL-NEXT:    bsfw (%rsi), %cx # sched: [8:1.00]
; BROADWELL-NEXT:    #NO_APP
; BROADWELL-NEXT:    orl %ecx, %eax # sched: [1:0.25]
; BROADWELL-NEXT:    # kill: %AX<def> %AX<kill> %EAX<kill>
; BROADWELL-NEXT:    retq # sched: [7:1.00]
;
; SKYLAKE-LABEL: test_bsf16:
; SKYLAKE:       # BB#0:
; SKYLAKE-NEXT:    #APP
; SKYLAKE-NEXT:    bsfw %di, %ax # sched: [3:1.00]
; SKYLAKE-NEXT:    bsfw (%rsi), %cx # sched: [8:1.00]
; SKYLAKE-NEXT:    #NO_APP
; SKYLAKE-NEXT:    orl %ecx, %eax # sched: [1:0.25]
; SKYLAKE-NEXT:    # kill: %AX<def> %AX<kill> %EAX<kill>
; SKYLAKE-NEXT:    retq # sched: [7:1.00]
;
; SKX-LABEL: test_bsf16:
; SKX:       # BB#0:
; SKX-NEXT:    #APP
; SKX-NEXT:    bsfw %di, %ax # sched: [3:1.00]
; SKX-NEXT:    bsfw (%rsi), %cx # sched: [8:1.00]
; SKX-NEXT:    #NO_APP
; SKX-NEXT:    orl %ecx, %eax # sched: [1:0.25]
; SKX-NEXT:    # kill: %AX<def> %AX<kill> %EAX<kill>
; SKX-NEXT:    retq # sched: [7:1.00]
;
; BTVER2-LABEL: test_bsf16:
; BTVER2:       # BB#0:
; BTVER2-NEXT:    #APP
; BTVER2-NEXT:    bsfw %di, %ax # sched: [1:0.50]
; BTVER2-NEXT:    bsfw (%rsi), %cx # sched: [4:1.00]
; BTVER2-NEXT:    #NO_APP
; BTVER2-NEXT:    orl %ecx, %eax # sched: [1:0.50]
; BTVER2-NEXT:    # kill: %AX<def> %AX<kill> %EAX<kill>
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; ZNVER1-LABEL: test_bsf16:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    #APP
; ZNVER1-NEXT:    bsfw %di, %ax # sched: [3:0.25]
; ZNVER1-NEXT:    bsfw (%rsi), %cx # sched: [7:0.50]
; ZNVER1-NEXT:    #NO_APP
; ZNVER1-NEXT:    orl %ecx, %eax # sched: [1:0.25]
; ZNVER1-NEXT:    # kill: %AX<def> %AX<kill> %EAX<kill>
; ZNVER1-NEXT:    retq # sched: [1:0.50]
  %1 = call { i16, i16 } asm sideeffect "bsf $2, $0 \0A\09 bsf $3, $1", "=r,=r,r,*m,~{dirflag},~{fpsr},~{flags}"(i16 %a0, i16* %a1)
  %2 = extractvalue { i16, i16 } %1, 0
  %3 = extractvalue { i16, i16 } %1, 1
  %4 = or i16 %2, %3
  ret i16 %4
}
define i32 @test_bsf32(i32 %a0, i32* %a1) optsize {
; GENERIC-LABEL: test_bsf32:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    #APP
; GENERIC-NEXT:    bsfl %edi, %eax # sched: [3:1.00]
; GENERIC-NEXT:    bsfl (%rsi), %ecx # sched: [8:1.00]
; GENERIC-NEXT:    #NO_APP
; GENERIC-NEXT:    orl %ecx, %eax # sched: [1:0.33]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; ATOM-LABEL: test_bsf32:
; ATOM:       # BB#0:
; ATOM-NEXT:    #APP
; ATOM-NEXT:    bsfl %edi, %eax # sched: [16:8.00]
; ATOM-NEXT:    bsfl (%rsi), %ecx # sched: [16:8.00]
; ATOM-NEXT:    #NO_APP
; ATOM-NEXT:    orl %ecx, %eax # sched: [1:0.50]
; ATOM-NEXT:    retq # sched: [79:39.50]
;
; SLM-LABEL: test_bsf32:
; SLM:       # BB#0:
; SLM-NEXT:    #APP
; SLM-NEXT:    bsfl %edi, %eax # sched: [1:1.00]
; SLM-NEXT:    bsfl (%rsi), %ecx # sched: [4:1.00]
; SLM-NEXT:    #NO_APP
; SLM-NEXT:    orl %ecx, %eax # sched: [1:0.50]
; SLM-NEXT:    retq # sched: [4:1.00]
;
; SANDY-LABEL: test_bsf32:
; SANDY:       # BB#0:
; SANDY-NEXT:    #APP
; SANDY-NEXT:    bsfl %edi, %eax # sched: [3:1.00]
; SANDY-NEXT:    bsfl (%rsi), %ecx # sched: [8:1.00]
; SANDY-NEXT:    #NO_APP
; SANDY-NEXT:    orl %ecx, %eax # sched: [1:0.33]
; SANDY-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_bsf32:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    #APP
; HASWELL-NEXT:    bsfl %edi, %eax # sched: [3:1.00]
; HASWELL-NEXT:    bsfl (%rsi), %ecx # sched: [3:1.00]
; HASWELL-NEXT:    #NO_APP
; HASWELL-NEXT:    orl %ecx, %eax # sched: [1:0.25]
; HASWELL-NEXT:    retq # sched: [2:1.00]
;
; BROADWELL-LABEL: test_bsf32:
; BROADWELL:       # BB#0:
; BROADWELL-NEXT:    #APP
; BROADWELL-NEXT:    bsfl %edi, %eax # sched: [3:1.00]
; BROADWELL-NEXT:    bsfl (%rsi), %ecx # sched: [8:1.00]
; BROADWELL-NEXT:    #NO_APP
; BROADWELL-NEXT:    orl %ecx, %eax # sched: [1:0.25]
; BROADWELL-NEXT:    retq # sched: [7:1.00]
;
; SKYLAKE-LABEL: test_bsf32:
; SKYLAKE:       # BB#0:
; SKYLAKE-NEXT:    #APP
; SKYLAKE-NEXT:    bsfl %edi, %eax # sched: [3:1.00]
; SKYLAKE-NEXT:    bsfl (%rsi), %ecx # sched: [8:1.00]
; SKYLAKE-NEXT:    #NO_APP
; SKYLAKE-NEXT:    orl %ecx, %eax # sched: [1:0.25]
; SKYLAKE-NEXT:    retq # sched: [7:1.00]
;
; SKX-LABEL: test_bsf32:
; SKX:       # BB#0:
; SKX-NEXT:    #APP
; SKX-NEXT:    bsfl %edi, %eax # sched: [3:1.00]
; SKX-NEXT:    bsfl (%rsi), %ecx # sched: [8:1.00]
; SKX-NEXT:    #NO_APP
; SKX-NEXT:    orl %ecx, %eax # sched: [1:0.25]
; SKX-NEXT:    retq # sched: [7:1.00]
;
; BTVER2-LABEL: test_bsf32:
; BTVER2:       # BB#0:
; BTVER2-NEXT:    #APP
; BTVER2-NEXT:    bsfl %edi, %eax # sched: [1:0.50]
; BTVER2-NEXT:    bsfl (%rsi), %ecx # sched: [4:1.00]
; BTVER2-NEXT:    #NO_APP
; BTVER2-NEXT:    orl %ecx, %eax # sched: [1:0.50]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; ZNVER1-LABEL: test_bsf32:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    #APP
; ZNVER1-NEXT:    bsfl %edi, %eax # sched: [3:0.25]
; ZNVER1-NEXT:    bsfl (%rsi), %ecx # sched: [7:0.50]
; ZNVER1-NEXT:    #NO_APP
; ZNVER1-NEXT:    orl %ecx, %eax # sched: [1:0.25]
; ZNVER1-NEXT:    retq # sched: [1:0.50]
  %1 = call { i32, i32 } asm sideeffect "bsf $2, $0 \0A\09 bsf $3, $1", "=r,=r,r,*m,~{dirflag},~{fpsr},~{flags}"(i32 %a0, i32* %a1)
  %2 = extractvalue { i32, i32 } %1, 0
  %3 = extractvalue { i32, i32 } %1, 1
  %4 = or i32 %2, %3
  ret i32 %4
}
define i64 @test_bsf64(i64 %a0, i64* %a1) optsize {
; GENERIC-LABEL: test_bsf64:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    #APP
; GENERIC-NEXT:    bsfq %rdi, %rax # sched: [3:1.00]
; GENERIC-NEXT:    bsfq (%rsi), %rcx # sched: [8:1.00]
; GENERIC-NEXT:    #NO_APP
; GENERIC-NEXT:    orq %rcx, %rax # sched: [1:0.33]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; ATOM-LABEL: test_bsf64:
; ATOM:       # BB#0:
; ATOM-NEXT:    #APP
; ATOM-NEXT:    bsfq %rdi, %rax # sched: [16:8.00]
; ATOM-NEXT:    bsfq (%rsi), %rcx # sched: [16:8.00]
; ATOM-NEXT:    #NO_APP
; ATOM-NEXT:    orq %rcx, %rax # sched: [1:0.50]
; ATOM-NEXT:    retq # sched: [79:39.50]
;
; SLM-LABEL: test_bsf64:
; SLM:       # BB#0:
; SLM-NEXT:    #APP
; SLM-NEXT:    bsfq %rdi, %rax # sched: [1:1.00]
; SLM-NEXT:    bsfq (%rsi), %rcx # sched: [4:1.00]
; SLM-NEXT:    #NO_APP
; SLM-NEXT:    orq %rcx, %rax # sched: [1:0.50]
; SLM-NEXT:    retq # sched: [4:1.00]
;
; SANDY-LABEL: test_bsf64:
; SANDY:       # BB#0:
; SANDY-NEXT:    #APP
; SANDY-NEXT:    bsfq %rdi, %rax # sched: [3:1.00]
; SANDY-NEXT:    bsfq (%rsi), %rcx # sched: [8:1.00]
; SANDY-NEXT:    #NO_APP
; SANDY-NEXT:    orq %rcx, %rax # sched: [1:0.33]
; SANDY-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_bsf64:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    #APP
; HASWELL-NEXT:    bsfq %rdi, %rax # sched: [3:1.00]
; HASWELL-NEXT:    bsfq (%rsi), %rcx # sched: [3:1.00]
; HASWELL-NEXT:    #NO_APP
; HASWELL-NEXT:    orq %rcx, %rax # sched: [1:0.25]
; HASWELL-NEXT:    retq # sched: [2:1.00]
;
; BROADWELL-LABEL: test_bsf64:
; BROADWELL:       # BB#0:
; BROADWELL-NEXT:    #APP
; BROADWELL-NEXT:    bsfq %rdi, %rax # sched: [3:1.00]
; BROADWELL-NEXT:    bsfq (%rsi), %rcx # sched: [8:1.00]
; BROADWELL-NEXT:    #NO_APP
; BROADWELL-NEXT:    orq %rcx, %rax # sched: [1:0.25]
; BROADWELL-NEXT:    retq # sched: [7:1.00]
;
; SKYLAKE-LABEL: test_bsf64:
; SKYLAKE:       # BB#0:
; SKYLAKE-NEXT:    #APP
; SKYLAKE-NEXT:    bsfq %rdi, %rax # sched: [3:1.00]
; SKYLAKE-NEXT:    bsfq (%rsi), %rcx # sched: [8:1.00]
; SKYLAKE-NEXT:    #NO_APP
; SKYLAKE-NEXT:    orq %rcx, %rax # sched: [1:0.25]
; SKYLAKE-NEXT:    retq # sched: [7:1.00]
;
; SKX-LABEL: test_bsf64:
; SKX:       # BB#0:
; SKX-NEXT:    #APP
; SKX-NEXT:    bsfq %rdi, %rax # sched: [3:1.00]
; SKX-NEXT:    bsfq (%rsi), %rcx # sched: [8:1.00]
; SKX-NEXT:    #NO_APP
; SKX-NEXT:    orq %rcx, %rax # sched: [1:0.25]
; SKX-NEXT:    retq # sched: [7:1.00]
;
; BTVER2-LABEL: test_bsf64:
; BTVER2:       # BB#0:
; BTVER2-NEXT:    #APP
; BTVER2-NEXT:    bsfq %rdi, %rax # sched: [1:0.50]
; BTVER2-NEXT:    bsfq (%rsi), %rcx # sched: [4:1.00]
; BTVER2-NEXT:    #NO_APP
; BTVER2-NEXT:    orq %rcx, %rax # sched: [1:0.50]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; ZNVER1-LABEL: test_bsf64:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    #APP
; ZNVER1-NEXT:    bsfq %rdi, %rax # sched: [3:0.25]
; ZNVER1-NEXT:    bsfq (%rsi), %rcx # sched: [7:0.50]
; ZNVER1-NEXT:    #NO_APP
; ZNVER1-NEXT:    orq %rcx, %rax # sched: [1:0.25]
; ZNVER1-NEXT:    retq # sched: [1:0.50]
  %1 = call { i64, i64 } asm sideeffect "bsf $2, $0 \0A\09 bsf $3, $1", "=r,=r,r,*m,~{dirflag},~{fpsr},~{flags}"(i64 %a0, i64* %a1)
  %2 = extractvalue { i64, i64 } %1, 0
  %3 = extractvalue { i64, i64 } %1, 1
  %4 = or i64 %2, %3
  ret i64 %4
}

define i16 @test_bsr16(i16 %a0, i16* %a1) optsize {
; GENERIC-LABEL: test_bsr16:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    #APP
; GENERIC-NEXT:    bsrw %di, %ax # sched: [3:1.00]
; GENERIC-NEXT:    bsrw (%rsi), %cx # sched: [8:1.00]
; GENERIC-NEXT:    #NO_APP
; GENERIC-NEXT:    orl %ecx, %eax # sched: [1:0.33]
; GENERIC-NEXT:    # kill: %AX<def> %AX<kill> %EAX<kill>
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; ATOM-LABEL: test_bsr16:
; ATOM:       # BB#0:
; ATOM-NEXT:    #APP
; ATOM-NEXT:    bsrw %di, %ax # sched: [16:8.00]
; ATOM-NEXT:    bsrw (%rsi), %cx # sched: [16:8.00]
; ATOM-NEXT:    #NO_APP
; ATOM-NEXT:    orl %ecx, %eax # sched: [1:0.50]
; ATOM-NEXT:    # kill: %AX<def> %AX<kill> %EAX<kill>
; ATOM-NEXT:    retq # sched: [79:39.50]
;
; SLM-LABEL: test_bsr16:
; SLM:       # BB#0:
; SLM-NEXT:    #APP
; SLM-NEXT:    bsrw %di, %ax # sched: [1:1.00]
; SLM-NEXT:    bsrw (%rsi), %cx # sched: [4:1.00]
; SLM-NEXT:    #NO_APP
; SLM-NEXT:    orl %ecx, %eax # sched: [1:0.50]
; SLM-NEXT:    # kill: %AX<def> %AX<kill> %EAX<kill>
; SLM-NEXT:    retq # sched: [4:1.00]
;
; SANDY-LABEL: test_bsr16:
; SANDY:       # BB#0:
; SANDY-NEXT:    #APP
; SANDY-NEXT:    bsrw %di, %ax # sched: [3:1.00]
; SANDY-NEXT:    bsrw (%rsi), %cx # sched: [8:1.00]
; SANDY-NEXT:    #NO_APP
; SANDY-NEXT:    orl %ecx, %eax # sched: [1:0.33]
; SANDY-NEXT:    # kill: %AX<def> %AX<kill> %EAX<kill>
; SANDY-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_bsr16:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    #APP
; HASWELL-NEXT:    bsrw %di, %ax # sched: [3:1.00]
; HASWELL-NEXT:    bsrw (%rsi), %cx # sched: [3:1.00]
; HASWELL-NEXT:    #NO_APP
; HASWELL-NEXT:    orl %ecx, %eax # sched: [1:0.25]
; HASWELL-NEXT:    # kill: %AX<def> %AX<kill> %EAX<kill>
; HASWELL-NEXT:    retq # sched: [2:1.00]
;
; BROADWELL-LABEL: test_bsr16:
; BROADWELL:       # BB#0:
; BROADWELL-NEXT:    #APP
; BROADWELL-NEXT:    bsrw %di, %ax # sched: [3:1.00]
; BROADWELL-NEXT:    bsrw (%rsi), %cx # sched: [8:1.00]
; BROADWELL-NEXT:    #NO_APP
; BROADWELL-NEXT:    orl %ecx, %eax # sched: [1:0.25]
; BROADWELL-NEXT:    # kill: %AX<def> %AX<kill> %EAX<kill>
; BROADWELL-NEXT:    retq # sched: [7:1.00]
;
; SKYLAKE-LABEL: test_bsr16:
; SKYLAKE:       # BB#0:
; SKYLAKE-NEXT:    #APP
; SKYLAKE-NEXT:    bsrw %di, %ax # sched: [3:1.00]
; SKYLAKE-NEXT:    bsrw (%rsi), %cx # sched: [8:1.00]
; SKYLAKE-NEXT:    #NO_APP
; SKYLAKE-NEXT:    orl %ecx, %eax # sched: [1:0.25]
; SKYLAKE-NEXT:    # kill: %AX<def> %AX<kill> %EAX<kill>
; SKYLAKE-NEXT:    retq # sched: [7:1.00]
;
; SKX-LABEL: test_bsr16:
; SKX:       # BB#0:
; SKX-NEXT:    #APP
; SKX-NEXT:    bsrw %di, %ax # sched: [3:1.00]
; SKX-NEXT:    bsrw (%rsi), %cx # sched: [8:1.00]
; SKX-NEXT:    #NO_APP
; SKX-NEXT:    orl %ecx, %eax # sched: [1:0.25]
; SKX-NEXT:    # kill: %AX<def> %AX<kill> %EAX<kill>
; SKX-NEXT:    retq # sched: [7:1.00]
;
; BTVER2-LABEL: test_bsr16:
; BTVER2:       # BB#0:
; BTVER2-NEXT:    #APP
; BTVER2-NEXT:    bsrw %di, %ax # sched: [1:0.50]
; BTVER2-NEXT:    bsrw (%rsi), %cx # sched: [4:1.00]
; BTVER2-NEXT:    #NO_APP
; BTVER2-NEXT:    orl %ecx, %eax # sched: [1:0.50]
; BTVER2-NEXT:    # kill: %AX<def> %AX<kill> %EAX<kill>
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; ZNVER1-LABEL: test_bsr16:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    #APP
; ZNVER1-NEXT:    bsrw %di, %ax # sched: [3:0.25]
; ZNVER1-NEXT:    bsrw (%rsi), %cx # sched: [7:0.50]
; ZNVER1-NEXT:    #NO_APP
; ZNVER1-NEXT:    orl %ecx, %eax # sched: [1:0.25]
; ZNVER1-NEXT:    # kill: %AX<def> %AX<kill> %EAX<kill>
; ZNVER1-NEXT:    retq # sched: [1:0.50]
  %1 = call { i16, i16 } asm sideeffect "bsr $2, $0 \0A\09 bsr $3, $1", "=r,=r,r,*m,~{dirflag},~{fpsr},~{flags}"(i16 %a0, i16* %a1)
  %2 = extractvalue { i16, i16 } %1, 0
  %3 = extractvalue { i16, i16 } %1, 1
  %4 = or i16 %2, %3
  ret i16 %4
}
define i32 @test_bsr32(i32 %a0, i32* %a1) optsize {
; GENERIC-LABEL: test_bsr32:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    #APP
; GENERIC-NEXT:    bsrl %edi, %eax # sched: [3:1.00]
; GENERIC-NEXT:    bsrl (%rsi), %ecx # sched: [8:1.00]
; GENERIC-NEXT:    #NO_APP
; GENERIC-NEXT:    orl %ecx, %eax # sched: [1:0.33]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; ATOM-LABEL: test_bsr32:
; ATOM:       # BB#0:
; ATOM-NEXT:    #APP
; ATOM-NEXT:    bsrl %edi, %eax # sched: [16:8.00]
; ATOM-NEXT:    bsrl (%rsi), %ecx # sched: [16:8.00]
; ATOM-NEXT:    #NO_APP
; ATOM-NEXT:    orl %ecx, %eax # sched: [1:0.50]
; ATOM-NEXT:    retq # sched: [79:39.50]
;
; SLM-LABEL: test_bsr32:
; SLM:       # BB#0:
; SLM-NEXT:    #APP
; SLM-NEXT:    bsrl %edi, %eax # sched: [1:1.00]
; SLM-NEXT:    bsrl (%rsi), %ecx # sched: [4:1.00]
; SLM-NEXT:    #NO_APP
; SLM-NEXT:    orl %ecx, %eax # sched: [1:0.50]
; SLM-NEXT:    retq # sched: [4:1.00]
;
; SANDY-LABEL: test_bsr32:
; SANDY:       # BB#0:
; SANDY-NEXT:    #APP
; SANDY-NEXT:    bsrl %edi, %eax # sched: [3:1.00]
; SANDY-NEXT:    bsrl (%rsi), %ecx # sched: [8:1.00]
; SANDY-NEXT:    #NO_APP
; SANDY-NEXT:    orl %ecx, %eax # sched: [1:0.33]
; SANDY-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_bsr32:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    #APP
; HASWELL-NEXT:    bsrl %edi, %eax # sched: [3:1.00]
; HASWELL-NEXT:    bsrl (%rsi), %ecx # sched: [3:1.00]
; HASWELL-NEXT:    #NO_APP
; HASWELL-NEXT:    orl %ecx, %eax # sched: [1:0.25]
; HASWELL-NEXT:    retq # sched: [2:1.00]
;
; BROADWELL-LABEL: test_bsr32:
; BROADWELL:       # BB#0:
; BROADWELL-NEXT:    #APP
; BROADWELL-NEXT:    bsrl %edi, %eax # sched: [3:1.00]
; BROADWELL-NEXT:    bsrl (%rsi), %ecx # sched: [8:1.00]
; BROADWELL-NEXT:    #NO_APP
; BROADWELL-NEXT:    orl %ecx, %eax # sched: [1:0.25]
; BROADWELL-NEXT:    retq # sched: [7:1.00]
;
; SKYLAKE-LABEL: test_bsr32:
; SKYLAKE:       # BB#0:
; SKYLAKE-NEXT:    #APP
; SKYLAKE-NEXT:    bsrl %edi, %eax # sched: [3:1.00]
; SKYLAKE-NEXT:    bsrl (%rsi), %ecx # sched: [8:1.00]
; SKYLAKE-NEXT:    #NO_APP
; SKYLAKE-NEXT:    orl %ecx, %eax # sched: [1:0.25]
; SKYLAKE-NEXT:    retq # sched: [7:1.00]
;
; SKX-LABEL: test_bsr32:
; SKX:       # BB#0:
; SKX-NEXT:    #APP
; SKX-NEXT:    bsrl %edi, %eax # sched: [3:1.00]
; SKX-NEXT:    bsrl (%rsi), %ecx # sched: [8:1.00]
; SKX-NEXT:    #NO_APP
; SKX-NEXT:    orl %ecx, %eax # sched: [1:0.25]
; SKX-NEXT:    retq # sched: [7:1.00]
;
; BTVER2-LABEL: test_bsr32:
; BTVER2:       # BB#0:
; BTVER2-NEXT:    #APP
; BTVER2-NEXT:    bsrl %edi, %eax # sched: [1:0.50]
; BTVER2-NEXT:    bsrl (%rsi), %ecx # sched: [4:1.00]
; BTVER2-NEXT:    #NO_APP
; BTVER2-NEXT:    orl %ecx, %eax # sched: [1:0.50]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; ZNVER1-LABEL: test_bsr32:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    #APP
; ZNVER1-NEXT:    bsrl %edi, %eax # sched: [3:0.25]
; ZNVER1-NEXT:    bsrl (%rsi), %ecx # sched: [7:0.50]
; ZNVER1-NEXT:    #NO_APP
; ZNVER1-NEXT:    orl %ecx, %eax # sched: [1:0.25]
; ZNVER1-NEXT:    retq # sched: [1:0.50]
  %1 = call { i32, i32 } asm sideeffect "bsr $2, $0 \0A\09 bsr $3, $1", "=r,=r,r,*m,~{dirflag},~{fpsr},~{flags}"(i32 %a0, i32* %a1)
  %2 = extractvalue { i32, i32 } %1, 0
  %3 = extractvalue { i32, i32 } %1, 1
  %4 = or i32 %2, %3
  ret i32 %4
}
define i64 @test_bsr64(i64 %a0, i64* %a1) optsize {
; GENERIC-LABEL: test_bsr64:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    #APP
; GENERIC-NEXT:    bsrq %rdi, %rax # sched: [3:1.00]
; GENERIC-NEXT:    bsrq (%rsi), %rcx # sched: [8:1.00]
; GENERIC-NEXT:    #NO_APP
; GENERIC-NEXT:    orq %rcx, %rax # sched: [1:0.33]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; ATOM-LABEL: test_bsr64:
; ATOM:       # BB#0:
; ATOM-NEXT:    #APP
; ATOM-NEXT:    bsrq %rdi, %rax # sched: [16:8.00]
; ATOM-NEXT:    bsrq (%rsi), %rcx # sched: [16:8.00]
; ATOM-NEXT:    #NO_APP
; ATOM-NEXT:    orq %rcx, %rax # sched: [1:0.50]
; ATOM-NEXT:    retq # sched: [79:39.50]
;
; SLM-LABEL: test_bsr64:
; SLM:       # BB#0:
; SLM-NEXT:    #APP
; SLM-NEXT:    bsrq %rdi, %rax # sched: [1:1.00]
; SLM-NEXT:    bsrq (%rsi), %rcx # sched: [4:1.00]
; SLM-NEXT:    #NO_APP
; SLM-NEXT:    orq %rcx, %rax # sched: [1:0.50]
; SLM-NEXT:    retq # sched: [4:1.00]
;
; SANDY-LABEL: test_bsr64:
; SANDY:       # BB#0:
; SANDY-NEXT:    #APP
; SANDY-NEXT:    bsrq %rdi, %rax # sched: [3:1.00]
; SANDY-NEXT:    bsrq (%rsi), %rcx # sched: [8:1.00]
; SANDY-NEXT:    #NO_APP
; SANDY-NEXT:    orq %rcx, %rax # sched: [1:0.33]
; SANDY-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_bsr64:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    #APP
; HASWELL-NEXT:    bsrq %rdi, %rax # sched: [3:1.00]
; HASWELL-NEXT:    bsrq (%rsi), %rcx # sched: [3:1.00]
; HASWELL-NEXT:    #NO_APP
; HASWELL-NEXT:    orq %rcx, %rax # sched: [1:0.25]
; HASWELL-NEXT:    retq # sched: [2:1.00]
;
; BROADWELL-LABEL: test_bsr64:
; BROADWELL:       # BB#0:
; BROADWELL-NEXT:    #APP
; BROADWELL-NEXT:    bsrq %rdi, %rax # sched: [3:1.00]
; BROADWELL-NEXT:    bsrq (%rsi), %rcx # sched: [8:1.00]
; BROADWELL-NEXT:    #NO_APP
; BROADWELL-NEXT:    orq %rcx, %rax # sched: [1:0.25]
; BROADWELL-NEXT:    retq # sched: [7:1.00]
;
; SKYLAKE-LABEL: test_bsr64:
; SKYLAKE:       # BB#0:
; SKYLAKE-NEXT:    #APP
; SKYLAKE-NEXT:    bsrq %rdi, %rax # sched: [3:1.00]
; SKYLAKE-NEXT:    bsrq (%rsi), %rcx # sched: [8:1.00]
; SKYLAKE-NEXT:    #NO_APP
; SKYLAKE-NEXT:    orq %rcx, %rax # sched: [1:0.25]
; SKYLAKE-NEXT:    retq # sched: [7:1.00]
;
; SKX-LABEL: test_bsr64:
; SKX:       # BB#0:
; SKX-NEXT:    #APP
; SKX-NEXT:    bsrq %rdi, %rax # sched: [3:1.00]
; SKX-NEXT:    bsrq (%rsi), %rcx # sched: [8:1.00]
; SKX-NEXT:    #NO_APP
; SKX-NEXT:    orq %rcx, %rax # sched: [1:0.25]
; SKX-NEXT:    retq # sched: [7:1.00]
;
; BTVER2-LABEL: test_bsr64:
; BTVER2:       # BB#0:
; BTVER2-NEXT:    #APP
; BTVER2-NEXT:    bsrq %rdi, %rax # sched: [1:0.50]
; BTVER2-NEXT:    bsrq (%rsi), %rcx # sched: [4:1.00]
; BTVER2-NEXT:    #NO_APP
; BTVER2-NEXT:    orq %rcx, %rax # sched: [1:0.50]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; ZNVER1-LABEL: test_bsr64:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    #APP
; ZNVER1-NEXT:    bsrq %rdi, %rax # sched: [3:0.25]
; ZNVER1-NEXT:    bsrq (%rsi), %rcx # sched: [7:0.50]
; ZNVER1-NEXT:    #NO_APP
; ZNVER1-NEXT:    orq %rcx, %rax # sched: [1:0.25]
; ZNVER1-NEXT:    retq # sched: [1:0.50]
  %1 = call { i64, i64 } asm sideeffect "bsr $2, $0 \0A\09 bsr $3, $1", "=r,=r,r,*m,~{dirflag},~{fpsr},~{flags}"(i64 %a0, i64* %a1)
  %2 = extractvalue { i64, i64 } %1, 0
  %3 = extractvalue { i64, i64 } %1, 1
  %4 = or i64 %2, %3
  ret i64 %4
}

define i32 @test_bswap32(i32 %a0) optsize {
; GENERIC-LABEL: test_bswap32:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    bswapl %edi # sched: [2:1.00]
; GENERIC-NEXT:    movl %edi, %eax # sched: [1:0.33]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; ATOM-LABEL: test_bswap32:
; ATOM:       # BB#0:
; ATOM-NEXT:    bswapl %edi # sched: [1:1.00]
; ATOM-NEXT:    movl %edi, %eax # sched: [1:0.50]
; ATOM-NEXT:    retq # sched: [79:39.50]
;
; SLM-LABEL: test_bswap32:
; SLM:       # BB#0:
; SLM-NEXT:    bswapl %edi # sched: [1:0.50]
; SLM-NEXT:    movl %edi, %eax # sched: [1:0.50]
; SLM-NEXT:    retq # sched: [4:1.00]
;
; SANDY-LABEL: test_bswap32:
; SANDY:       # BB#0:
; SANDY-NEXT:    bswapl %edi # sched: [2:1.00]
; SANDY-NEXT:    movl %edi, %eax # sched: [1:0.33]
; SANDY-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_bswap32:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    bswapl %edi # sched: [2:0.50]
; HASWELL-NEXT:    movl %edi, %eax # sched: [1:0.25]
; HASWELL-NEXT:    retq # sched: [2:1.00]
;
; BROADWELL-LABEL: test_bswap32:
; BROADWELL:       # BB#0:
; BROADWELL-NEXT:    bswapl %edi # sched: [2:0.50]
; BROADWELL-NEXT:    movl %edi, %eax # sched: [1:0.25]
; BROADWELL-NEXT:    retq # sched: [7:1.00]
;
; SKYLAKE-LABEL: test_bswap32:
; SKYLAKE:       # BB#0:
; SKYLAKE-NEXT:    bswapl %edi # sched: [2:0.50]
; SKYLAKE-NEXT:    movl %edi, %eax # sched: [1:0.25]
; SKYLAKE-NEXT:    retq # sched: [7:1.00]
;
; SKX-LABEL: test_bswap32:
; SKX:       # BB#0:
; SKX-NEXT:    bswapl %edi # sched: [2:0.50]
; SKX-NEXT:    movl %edi, %eax # sched: [1:0.25]
; SKX-NEXT:    retq # sched: [7:1.00]
;
; BTVER2-LABEL: test_bswap32:
; BTVER2:       # BB#0:
; BTVER2-NEXT:    bswapl %edi # sched: [1:0.50]
; BTVER2-NEXT:    movl %edi, %eax # sched: [1:0.17]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; ZNVER1-LABEL: test_bswap32:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    bswapl %edi # sched: [1:1.00]
; ZNVER1-NEXT:    movl %edi, %eax # sched: [1:0.25]
; ZNVER1-NEXT:    retq # sched: [1:0.50]
  %1 = tail call i32 asm "bswap $0", "=r,0"(i32 %a0) nounwind
  ret i32 %1
}
define i64 @test_bswap64(i64 %a0) optsize {
; GENERIC-LABEL: test_bswap64:
; GENERIC:       # BB#0:
; GENERIC-NEXT:    bswapq %rdi # sched: [2:1.00]
; GENERIC-NEXT:    movq %rdi, %rax # sched: [1:0.33]
; GENERIC-NEXT:    retq # sched: [1:1.00]
;
; ATOM-LABEL: test_bswap64:
; ATOM:       # BB#0:
; ATOM-NEXT:    bswapq %rdi # sched: [1:1.00]
; ATOM-NEXT:    movq %rdi, %rax # sched: [1:0.50]
; ATOM-NEXT:    retq # sched: [79:39.50]
;
; SLM-LABEL: test_bswap64:
; SLM:       # BB#0:
; SLM-NEXT:    bswapq %rdi # sched: [1:0.50]
; SLM-NEXT:    movq %rdi, %rax # sched: [1:0.50]
; SLM-NEXT:    retq # sched: [4:1.00]
;
; SANDY-LABEL: test_bswap64:
; SANDY:       # BB#0:
; SANDY-NEXT:    bswapq %rdi # sched: [2:1.00]
; SANDY-NEXT:    movq %rdi, %rax # sched: [1:0.33]
; SANDY-NEXT:    retq # sched: [1:1.00]
;
; HASWELL-LABEL: test_bswap64:
; HASWELL:       # BB#0:
; HASWELL-NEXT:    bswapq %rdi # sched: [2:0.50]
; HASWELL-NEXT:    movq %rdi, %rax # sched: [1:0.25]
; HASWELL-NEXT:    retq # sched: [2:1.00]
;
; BROADWELL-LABEL: test_bswap64:
; BROADWELL:       # BB#0:
; BROADWELL-NEXT:    bswapq %rdi # sched: [2:0.50]
; BROADWELL-NEXT:    movq %rdi, %rax # sched: [1:0.25]
; BROADWELL-NEXT:    retq # sched: [7:1.00]
;
; SKYLAKE-LABEL: test_bswap64:
; SKYLAKE:       # BB#0:
; SKYLAKE-NEXT:    bswapq %rdi # sched: [2:0.50]
; SKYLAKE-NEXT:    movq %rdi, %rax # sched: [1:0.25]
; SKYLAKE-NEXT:    retq # sched: [7:1.00]
;
; SKX-LABEL: test_bswap64:
; SKX:       # BB#0:
; SKX-NEXT:    bswapq %rdi # sched: [2:0.50]
; SKX-NEXT:    movq %rdi, %rax # sched: [1:0.25]
; SKX-NEXT:    retq # sched: [7:1.00]
;
; BTVER2-LABEL: test_bswap64:
; BTVER2:       # BB#0:
; BTVER2-NEXT:    bswapq %rdi # sched: [1:0.50]
; BTVER2-NEXT:    movq %rdi, %rax # sched: [1:0.17]
; BTVER2-NEXT:    retq # sched: [4:1.00]
;
; ZNVER1-LABEL: test_bswap64:
; ZNVER1:       # BB#0:
; ZNVER1-NEXT:    bswapq %rdi # sched: [1:1.00]
; ZNVER1-NEXT:    movq %rdi, %rax # sched: [1:0.25]
; ZNVER1-NEXT:    retq # sched: [1:0.50]
  %1 = tail call i64 asm "bswap $0", "=r,0"(i64 %a0) nounwind
  ret i64 %1
}
