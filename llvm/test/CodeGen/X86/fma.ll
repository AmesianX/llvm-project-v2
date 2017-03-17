; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i386-apple-darwin10  -mattr=+sse2,+fma,-fma4 -show-mc-encoding | FileCheck %s --check-prefix=FMA32
; RUN: llc < %s -mtriple=i386-apple-darwin10  -mattr=+sse2,-fma,-fma4 -show-mc-encoding | FileCheck %s --check-prefix=FMACALL32
; RUN: llc < %s -mtriple=x86_64-apple-darwin10 -mattr=+fma,-fma4 -show-mc-encoding | FileCheck %s --check-prefix=FMA64
; RUN: llc < %s -mtriple=x86_64-apple-darwin10  -mattr=-fma,-fma4 -show-mc-encoding | FileCheck %s --check-prefix=FMACALL64
; RUN: llc < %s -mtriple=x86_64-apple-darwin10  -mattr=+avx512f,-fma,-fma4 -show-mc-encoding | FileCheck %s --check-prefix=AVX51264NOFMA
; RUN: llc < %s -mtriple=x86_64-apple-darwin10  -mattr=+avx512f,fma,-fma4 -show-mc-encoding | FileCheck %s --check-prefix=AVX51264
; RUN: llc < %s -mtriple=i386-apple-darwin10 -mcpu=bdver2 -mattr=-fma4 -show-mc-encoding | FileCheck %s --check-prefix=FMA32
; RUN: llc < %s -mtriple=i386-apple-darwin10 -mcpu=bdver2 -mattr=-fma,-fma4 -show-mc-encoding | FileCheck %s --check-prefix=FMACALL32

define float @test_f32(float %a, float %b, float %c) #0 {
; FMA32-LABEL: test_f32:
; FMA32:       ## BB#0: ## %entry
; FMA32-NEXT:    pushl %eax ## encoding: [0x50]
; FMA32-NEXT:    vmovss {{[0-9]+}}(%esp), %xmm0 ## encoding: [0xc5,0xfa,0x10,0x44,0x24,0x08]
; FMA32-NEXT:    ## xmm0 = mem[0],zero,zero,zero
; FMA32-NEXT:    vmovss {{[0-9]+}}(%esp), %xmm1 ## encoding: [0xc5,0xfa,0x10,0x4c,0x24,0x0c]
; FMA32-NEXT:    ## xmm1 = mem[0],zero,zero,zero
; FMA32-NEXT:    vfmadd213ss {{[0-9]+}}(%esp), %xmm0, %xmm1 ## encoding: [0xc4,0xe2,0x79,0xa9,0x4c,0x24,0x10]
; FMA32-NEXT:    vmovss %xmm1, (%esp) ## encoding: [0xc5,0xfa,0x11,0x0c,0x24]
; FMA32-NEXT:    flds (%esp) ## encoding: [0xd9,0x04,0x24]
; FMA32-NEXT:    popl %eax ## encoding: [0x58]
; FMA32-NEXT:    retl ## encoding: [0xc3]
;
; FMACALL32-LABEL: test_f32:
; FMACALL32:       ## BB#0: ## %entry
; FMACALL32-NEXT:    jmp _fmaf ## TAILCALL
; FMACALL32-NEXT:    ## encoding: [0xeb,A]
; FMACALL32-NEXT:    ## fixup A - offset: 1, value: _fmaf-1, kind: FK_PCRel_1
;
; FMA64-LABEL: test_f32:
; FMA64:       ## BB#0: ## %entry
; FMA64-NEXT:    vfmadd213ss %xmm2, %xmm1, %xmm0 ## encoding: [0xc4,0xe2,0x71,0xa9,0xc2]
; FMA64-NEXT:    retq ## encoding: [0xc3]
;
; FMACALL64-LABEL: test_f32:
; FMACALL64:       ## BB#0: ## %entry
; FMACALL64-NEXT:    jmp _fmaf ## TAILCALL
; FMACALL64-NEXT:    ## encoding: [0xeb,A]
; FMACALL64-NEXT:    ## fixup A - offset: 1, value: _fmaf-1, kind: FK_PCRel_1
;
; AVX51264NOFMA-LABEL: test_f32:
; AVX51264NOFMA:       ## BB#0: ## %entry
; AVX51264NOFMA-NEXT:    vfmadd213ss %xmm2, %xmm1, %xmm0 ## EVEX TO VEX Compression encoding: [0xc4,0xe2,0x71,0xa9,0xc2]
; AVX51264NOFMA-NEXT:    retq ## encoding: [0xc3]
;
; AVX51264-LABEL: test_f32:
; AVX51264:       ## BB#0: ## %entry
; AVX51264-NEXT:    vfmadd213ss %xmm2, %xmm1, %xmm0 ## EVEX TO VEX Compression encoding: [0xc4,0xe2,0x71,0xa9,0xc2]
; AVX51264-NEXT:    retq ## encoding: [0xc3]
entry:
  %call = call float @llvm.fma.f32(float %a, float %b, float %c)
  ret float %call
}

define double @test_f64(double %a, double %b, double %c) #0 {
; FMA32-LABEL: test_f64:
; FMA32:       ## BB#0: ## %entry
; FMA32-NEXT:    subl $12, %esp ## encoding: [0x83,0xec,0x0c]
; FMA32-NEXT:    vmovsd {{[0-9]+}}(%esp), %xmm0 ## encoding: [0xc5,0xfb,0x10,0x44,0x24,0x10]
; FMA32-NEXT:    ## xmm0 = mem[0],zero
; FMA32-NEXT:    vmovsd {{[0-9]+}}(%esp), %xmm1 ## encoding: [0xc5,0xfb,0x10,0x4c,0x24,0x18]
; FMA32-NEXT:    ## xmm1 = mem[0],zero
; FMA32-NEXT:    vfmadd213sd {{[0-9]+}}(%esp), %xmm0, %xmm1 ## encoding: [0xc4,0xe2,0xf9,0xa9,0x4c,0x24,0x20]
; FMA32-NEXT:    vmovsd %xmm1, (%esp) ## encoding: [0xc5,0xfb,0x11,0x0c,0x24]
; FMA32-NEXT:    fldl (%esp) ## encoding: [0xdd,0x04,0x24]
; FMA32-NEXT:    addl $12, %esp ## encoding: [0x83,0xc4,0x0c]
; FMA32-NEXT:    retl ## encoding: [0xc3]
;
; FMACALL32-LABEL: test_f64:
; FMACALL32:       ## BB#0: ## %entry
; FMACALL32-NEXT:    jmp _fma ## TAILCALL
; FMACALL32-NEXT:    ## encoding: [0xeb,A]
; FMACALL32-NEXT:    ## fixup A - offset: 1, value: _fma-1, kind: FK_PCRel_1
;
; FMA64-LABEL: test_f64:
; FMA64:       ## BB#0: ## %entry
; FMA64-NEXT:    vfmadd213sd %xmm2, %xmm1, %xmm0 ## encoding: [0xc4,0xe2,0xf1,0xa9,0xc2]
; FMA64-NEXT:    retq ## encoding: [0xc3]
;
; FMACALL64-LABEL: test_f64:
; FMACALL64:       ## BB#0: ## %entry
; FMACALL64-NEXT:    jmp _fma ## TAILCALL
; FMACALL64-NEXT:    ## encoding: [0xeb,A]
; FMACALL64-NEXT:    ## fixup A - offset: 1, value: _fma-1, kind: FK_PCRel_1
;
; AVX51264NOFMA-LABEL: test_f64:
; AVX51264NOFMA:       ## BB#0: ## %entry
; AVX51264NOFMA-NEXT:    vfmadd213sd %xmm2, %xmm1, %xmm0 ## EVEX TO VEX Compression encoding: [0xc4,0xe2,0xf1,0xa9,0xc2]
; AVX51264NOFMA-NEXT:    retq ## encoding: [0xc3]
;
; AVX51264-LABEL: test_f64:
; AVX51264:       ## BB#0: ## %entry
; AVX51264-NEXT:    vfmadd213sd %xmm2, %xmm1, %xmm0 ## EVEX TO VEX Compression encoding: [0xc4,0xe2,0xf1,0xa9,0xc2]
; AVX51264-NEXT:    retq ## encoding: [0xc3]
entry:
  %call = call double @llvm.fma.f64(double %a, double %b, double %c)
  ret double %call
}

define x86_fp80 @test_f80(x86_fp80 %a, x86_fp80 %b, x86_fp80 %c) #0 {
; FMA32-LABEL: test_f80:
; FMA32:       ## BB#0: ## %entry
; FMA32-NEXT:    subl $60, %esp ## encoding: [0x83,0xec,0x3c]
; FMA32-NEXT:    fldt {{[0-9]+}}(%esp) ## encoding: [0xdb,0x6c,0x24,0x40]
; FMA32-NEXT:    fldt {{[0-9]+}}(%esp) ## encoding: [0xdb,0x6c,0x24,0x50]
; FMA32-NEXT:    fldt {{[0-9]+}}(%esp) ## encoding: [0xdb,0x6c,0x24,0x60]
; FMA32-NEXT:    fstpt {{[0-9]+}}(%esp) ## encoding: [0xdb,0x7c,0x24,0x20]
; FMA32-NEXT:    fstpt {{[0-9]+}}(%esp) ## encoding: [0xdb,0x7c,0x24,0x10]
; FMA32-NEXT:    fstpt (%esp) ## encoding: [0xdb,0x3c,0x24]
; FMA32-NEXT:    calll _fmal ## encoding: [0xe8,A,A,A,A]
; FMA32-NEXT:    ## fixup A - offset: 1, value: _fmal-4, kind: FK_PCRel_4
; FMA32-NEXT:    addl $60, %esp ## encoding: [0x83,0xc4,0x3c]
; FMA32-NEXT:    retl ## encoding: [0xc3]
;
; FMACALL32-LABEL: test_f80:
; FMACALL32:       ## BB#0: ## %entry
; FMACALL32-NEXT:    subl $60, %esp ## encoding: [0x83,0xec,0x3c]
; FMACALL32-NEXT:    fldt {{[0-9]+}}(%esp) ## encoding: [0xdb,0x6c,0x24,0x40]
; FMACALL32-NEXT:    fldt {{[0-9]+}}(%esp) ## encoding: [0xdb,0x6c,0x24,0x50]
; FMACALL32-NEXT:    fldt {{[0-9]+}}(%esp) ## encoding: [0xdb,0x6c,0x24,0x60]
; FMACALL32-NEXT:    fstpt {{[0-9]+}}(%esp) ## encoding: [0xdb,0x7c,0x24,0x20]
; FMACALL32-NEXT:    fstpt {{[0-9]+}}(%esp) ## encoding: [0xdb,0x7c,0x24,0x10]
; FMACALL32-NEXT:    fstpt (%esp) ## encoding: [0xdb,0x3c,0x24]
; FMACALL32-NEXT:    calll _fmal ## encoding: [0xe8,A,A,A,A]
; FMACALL32-NEXT:    ## fixup A - offset: 1, value: _fmal-4, kind: FK_PCRel_4
; FMACALL32-NEXT:    addl $60, %esp ## encoding: [0x83,0xc4,0x3c]
; FMACALL32-NEXT:    retl ## encoding: [0xc3]
;
; FMA64-LABEL: test_f80:
; FMA64:       ## BB#0: ## %entry
; FMA64-NEXT:    subq $56, %rsp ## encoding: [0x48,0x83,0xec,0x38]
; FMA64-NEXT:    fldt {{[0-9]+}}(%rsp) ## encoding: [0xdb,0x6c,0x24,0x40]
; FMA64-NEXT:    fldt {{[0-9]+}}(%rsp) ## encoding: [0xdb,0x6c,0x24,0x50]
; FMA64-NEXT:    fldt {{[0-9]+}}(%rsp) ## encoding: [0xdb,0x6c,0x24,0x60]
; FMA64-NEXT:    fstpt {{[0-9]+}}(%rsp) ## encoding: [0xdb,0x7c,0x24,0x20]
; FMA64-NEXT:    fstpt {{[0-9]+}}(%rsp) ## encoding: [0xdb,0x7c,0x24,0x10]
; FMA64-NEXT:    fstpt (%rsp) ## encoding: [0xdb,0x3c,0x24]
; FMA64-NEXT:    callq _fmal ## encoding: [0xe8,A,A,A,A]
; FMA64-NEXT:    ## fixup A - offset: 1, value: _fmal-4, kind: FK_PCRel_4
; FMA64-NEXT:    addq $56, %rsp ## encoding: [0x48,0x83,0xc4,0x38]
; FMA64-NEXT:    retq ## encoding: [0xc3]
;
; FMACALL64-LABEL: test_f80:
; FMACALL64:       ## BB#0: ## %entry
; FMACALL64-NEXT:    subq $56, %rsp ## encoding: [0x48,0x83,0xec,0x38]
; FMACALL64-NEXT:    fldt {{[0-9]+}}(%rsp) ## encoding: [0xdb,0x6c,0x24,0x40]
; FMACALL64-NEXT:    fldt {{[0-9]+}}(%rsp) ## encoding: [0xdb,0x6c,0x24,0x50]
; FMACALL64-NEXT:    fldt {{[0-9]+}}(%rsp) ## encoding: [0xdb,0x6c,0x24,0x60]
; FMACALL64-NEXT:    fstpt {{[0-9]+}}(%rsp) ## encoding: [0xdb,0x7c,0x24,0x20]
; FMACALL64-NEXT:    fstpt {{[0-9]+}}(%rsp) ## encoding: [0xdb,0x7c,0x24,0x10]
; FMACALL64-NEXT:    fstpt (%rsp) ## encoding: [0xdb,0x3c,0x24]
; FMACALL64-NEXT:    callq _fmal ## encoding: [0xe8,A,A,A,A]
; FMACALL64-NEXT:    ## fixup A - offset: 1, value: _fmal-4, kind: FK_PCRel_4
; FMACALL64-NEXT:    addq $56, %rsp ## encoding: [0x48,0x83,0xc4,0x38]
; FMACALL64-NEXT:    retq ## encoding: [0xc3]
;
; AVX51264NOFMA-LABEL: test_f80:
; AVX51264NOFMA:       ## BB#0: ## %entry
; AVX51264NOFMA-NEXT:    subq $56, %rsp ## encoding: [0x48,0x83,0xec,0x38]
; AVX51264NOFMA-NEXT:    fldt {{[0-9]+}}(%rsp) ## encoding: [0xdb,0x6c,0x24,0x40]
; AVX51264NOFMA-NEXT:    fldt {{[0-9]+}}(%rsp) ## encoding: [0xdb,0x6c,0x24,0x50]
; AVX51264NOFMA-NEXT:    fldt {{[0-9]+}}(%rsp) ## encoding: [0xdb,0x6c,0x24,0x60]
; AVX51264NOFMA-NEXT:    fstpt {{[0-9]+}}(%rsp) ## encoding: [0xdb,0x7c,0x24,0x20]
; AVX51264NOFMA-NEXT:    fstpt {{[0-9]+}}(%rsp) ## encoding: [0xdb,0x7c,0x24,0x10]
; AVX51264NOFMA-NEXT:    fstpt (%rsp) ## encoding: [0xdb,0x3c,0x24]
; AVX51264NOFMA-NEXT:    callq _fmal ## encoding: [0xe8,A,A,A,A]
; AVX51264NOFMA-NEXT:    ## fixup A - offset: 1, value: _fmal-4, kind: FK_PCRel_4
; AVX51264NOFMA-NEXT:    addq $56, %rsp ## encoding: [0x48,0x83,0xc4,0x38]
; AVX51264NOFMA-NEXT:    retq ## encoding: [0xc3]
;
; AVX51264-LABEL: test_f80:
; AVX51264:       ## BB#0: ## %entry
; AVX51264-NEXT:    subq $56, %rsp ## encoding: [0x48,0x83,0xec,0x38]
; AVX51264-NEXT:    fldt {{[0-9]+}}(%rsp) ## encoding: [0xdb,0x6c,0x24,0x40]
; AVX51264-NEXT:    fldt {{[0-9]+}}(%rsp) ## encoding: [0xdb,0x6c,0x24,0x50]
; AVX51264-NEXT:    fldt {{[0-9]+}}(%rsp) ## encoding: [0xdb,0x6c,0x24,0x60]
; AVX51264-NEXT:    fstpt {{[0-9]+}}(%rsp) ## encoding: [0xdb,0x7c,0x24,0x20]
; AVX51264-NEXT:    fstpt {{[0-9]+}}(%rsp) ## encoding: [0xdb,0x7c,0x24,0x10]
; AVX51264-NEXT:    fstpt (%rsp) ## encoding: [0xdb,0x3c,0x24]
; AVX51264-NEXT:    callq _fmal ## encoding: [0xe8,A,A,A,A]
; AVX51264-NEXT:    ## fixup A - offset: 1, value: _fmal-4, kind: FK_PCRel_4
; AVX51264-NEXT:    addq $56, %rsp ## encoding: [0x48,0x83,0xc4,0x38]
; AVX51264-NEXT:    retq ## encoding: [0xc3]
entry:
  %call = call x86_fp80 @llvm.fma.f80(x86_fp80 %a, x86_fp80 %b, x86_fp80 %c)
  ret x86_fp80 %call
}

define float @test_f32_cst() #0 {
; FMA32-LABEL: test_f32_cst:
; FMA32:       ## BB#0: ## %entry
; FMA32-NEXT:    flds LCPI3_0 ## encoding: [0xd9,0x05,A,A,A,A]
; FMA32-NEXT:    ## fixup A - offset: 2, value: LCPI3_0, kind: FK_Data_4
; FMA32-NEXT:    retl ## encoding: [0xc3]
;
; FMACALL32-LABEL: test_f32_cst:
; FMACALL32:       ## BB#0: ## %entry
; FMACALL32-NEXT:    flds LCPI3_0 ## encoding: [0xd9,0x05,A,A,A,A]
; FMACALL32-NEXT:    ## fixup A - offset: 2, value: LCPI3_0, kind: FK_Data_4
; FMACALL32-NEXT:    retl ## encoding: [0xc3]
;
; FMA64-LABEL: test_f32_cst:
; FMA64:       ## BB#0: ## %entry
; FMA64-NEXT:    vmovss {{.*}}(%rip), %xmm0 ## encoding: [0xc5,0xfa,0x10,0x05,A,A,A,A]
; FMA64-NEXT:    ## fixup A - offset: 4, value: LCPI3_0-4, kind: reloc_riprel_4byte
; FMA64-NEXT:    ## xmm0 = mem[0],zero,zero,zero
; FMA64-NEXT:    retq ## encoding: [0xc3]
;
; FMACALL64-LABEL: test_f32_cst:
; FMACALL64:       ## BB#0: ## %entry
; FMACALL64-NEXT:    movss {{.*}}(%rip), %xmm0 ## encoding: [0xf3,0x0f,0x10,0x05,A,A,A,A]
; FMACALL64-NEXT:    ## fixup A - offset: 4, value: LCPI3_0-4, kind: reloc_riprel_4byte
; FMACALL64-NEXT:    ## xmm0 = mem[0],zero,zero,zero
; FMACALL64-NEXT:    retq ## encoding: [0xc3]
;
; AVX51264NOFMA-LABEL: test_f32_cst:
; AVX51264NOFMA:       ## BB#0: ## %entry
; AVX51264NOFMA-NEXT:    vmovss {{.*}}(%rip), %xmm0 ## EVEX TO VEX Compression encoding: [0xc5,0xfa,0x10,0x05,A,A,A,A]
; AVX51264NOFMA-NEXT:    ## fixup A - offset: 4, value: LCPI3_0-4, kind: reloc_riprel_4byte
; AVX51264NOFMA-NEXT:    ## xmm0 = mem[0],zero,zero,zero
; AVX51264NOFMA-NEXT:    retq ## encoding: [0xc3]
;
; AVX51264-LABEL: test_f32_cst:
; AVX51264:       ## BB#0: ## %entry
; AVX51264-NEXT:    vmovss {{.*}}(%rip), %xmm0 ## EVEX TO VEX Compression encoding: [0xc5,0xfa,0x10,0x05,A,A,A,A]
; AVX51264-NEXT:    ## fixup A - offset: 4, value: LCPI3_0-4, kind: reloc_riprel_4byte
; AVX51264-NEXT:    ## xmm0 = mem[0],zero,zero,zero
; AVX51264-NEXT:    retq ## encoding: [0xc3]
entry:
  %call = call float @llvm.fma.f32(float 3.0, float 3.0, float 3.0)
  ret float %call
}

declare float @llvm.fma.f32(float, float, float)
declare double @llvm.fma.f64(double, double, double)
declare x86_fp80 @llvm.fma.f80(x86_fp80, x86_fp80, x86_fp80)

attributes #0 = { nounwind }
