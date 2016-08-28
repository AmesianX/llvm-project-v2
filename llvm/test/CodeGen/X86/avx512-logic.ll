; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mcpu=knl | FileCheck %s --check-prefix=ALL --check-prefix=KNL
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mcpu=skx | FileCheck %s --check-prefix=ALL --check-prefix=SKX


define <16 x i32> @vpandd(<16 x i32> %a, <16 x i32> %b) nounwind uwtable readnone ssp {
; ALL-LABEL: vpandd:
; ALL:       ## BB#0: ## %entry
; ALL-NEXT:    vpaddd {{.*}}(%rip){1to16}, %zmm0, %zmm0
; ALL-NEXT:    vpandd %zmm1, %zmm0, %zmm0
; ALL-NEXT:    retq
entry:
  ; Force the execution domain with an add.
  %a2 = add <16 x i32> %a, <i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1,
                            i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1>
  %x = and <16 x i32> %a2, %b
  ret <16 x i32> %x
}

define <16 x i32> @vpandnd(<16 x i32> %a, <16 x i32> %b) nounwind uwtable readnone ssp {
; ALL-LABEL: vpandnd:
; ALL:       ## BB#0: ## %entry
; ALL-NEXT:    vpaddd {{.*}}(%rip){1to16}, %zmm0, %zmm0
; ALL-NEXT:    vpandnd %zmm0, %zmm1, %zmm0
; ALL-NEXT:    retq
entry:
  ; Force the execution domain with an add.
  %a2 = add <16 x i32> %a, <i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1,
                            i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1>
  %b2 = xor <16 x i32> %b, <i32 -1, i32 -1, i32 -1, i32 -1, i32 -1, i32 -1, i32 -1, i32 -1,
                            i32 -1, i32 -1, i32 -1, i32 -1, i32 -1, i32 -1, i32 -1, i32 -1>
  %x = and <16 x i32> %a2, %b2
  ret <16 x i32> %x
}

define <16 x i32> @vpord(<16 x i32> %a, <16 x i32> %b) nounwind uwtable readnone ssp {
; ALL-LABEL: vpord:
; ALL:       ## BB#0: ## %entry
; ALL-NEXT:    vpaddd {{.*}}(%rip){1to16}, %zmm0, %zmm0
; ALL-NEXT:    vpord %zmm1, %zmm0, %zmm0
; ALL-NEXT:    retq
entry:
  ; Force the execution domain with an add.
  %a2 = add <16 x i32> %a, <i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1,
                            i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1>
  %x = or <16 x i32> %a2, %b
  ret <16 x i32> %x
}

define <16 x i32> @vpxord(<16 x i32> %a, <16 x i32> %b) nounwind uwtable readnone ssp {
; ALL-LABEL: vpxord:
; ALL:       ## BB#0: ## %entry
; ALL-NEXT:    vpaddd {{.*}}(%rip){1to16}, %zmm0, %zmm0
; ALL-NEXT:    vpxord %zmm1, %zmm0, %zmm0
; ALL-NEXT:    retq
entry:
  ; Force the execution domain with an add.
  %a2 = add <16 x i32> %a, <i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1,
                            i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1>
  %x = xor <16 x i32> %a2, %b
  ret <16 x i32> %x
}

define <8 x i64> @vpandq(<8 x i64> %a, <8 x i64> %b) nounwind uwtable readnone ssp {
; ALL-LABEL: vpandq:
; ALL:       ## BB#0: ## %entry
; ALL-NEXT:    vpaddq {{.*}}(%rip){1to8}, %zmm0, %zmm0
; ALL-NEXT:    vpandq %zmm1, %zmm0, %zmm0
; ALL-NEXT:    retq
entry:
  ; Force the execution domain with an add.
  %a2 = add <8 x i64> %a, <i64 1, i64 1, i64 1, i64 1, i64 1, i64 1, i64 1, i64 1>
  %x = and <8 x i64> %a2, %b
  ret <8 x i64> %x
}

define <8 x i64> @vpandnq(<8 x i64> %a, <8 x i64> %b) nounwind uwtable readnone ssp {
; ALL-LABEL: vpandnq:
; ALL:       ## BB#0: ## %entry
; ALL-NEXT:    vpaddq {{.*}}(%rip){1to8}, %zmm0, %zmm0
; ALL-NEXT:    vpandnq %zmm0, %zmm1, %zmm0
; ALL-NEXT:    retq
entry:
  ; Force the execution domain with an add.
  %a2 = add <8 x i64> %a, <i64 1, i64 1, i64 1, i64 1, i64 1, i64 1, i64 1, i64 1>
  %b2 = xor <8 x i64> %b, <i64 -1, i64 -1, i64 -1, i64 -1, i64 -1, i64 -1, i64 -1, i64 -1>
  %x = and <8 x i64> %a2, %b2
  ret <8 x i64> %x
}

define <8 x i64> @vporq(<8 x i64> %a, <8 x i64> %b) nounwind uwtable readnone ssp {
; ALL-LABEL: vporq:
; ALL:       ## BB#0: ## %entry
; ALL-NEXT:    vpaddq {{.*}}(%rip){1to8}, %zmm0, %zmm0
; ALL-NEXT:    vporq %zmm1, %zmm0, %zmm0
; ALL-NEXT:    retq
entry:
  ; Force the execution domain with an add.
  %a2 = add <8 x i64> %a, <i64 1, i64 1, i64 1, i64 1, i64 1, i64 1, i64 1, i64 1>
  %x = or <8 x i64> %a2, %b
  ret <8 x i64> %x
}

define <8 x i64> @vpxorq(<8 x i64> %a, <8 x i64> %b) nounwind uwtable readnone ssp {
; ALL-LABEL: vpxorq:
; ALL:       ## BB#0: ## %entry
; ALL-NEXT:    vpaddq {{.*}}(%rip){1to8}, %zmm0, %zmm0
; ALL-NEXT:    vpxorq %zmm1, %zmm0, %zmm0
; ALL-NEXT:    retq
entry:
  ; Force the execution domain with an add.
  %a2 = add <8 x i64> %a, <i64 1, i64 1, i64 1, i64 1, i64 1, i64 1, i64 1, i64 1>
  %x = xor <8 x i64> %a2, %b
  ret <8 x i64> %x
}


define <8 x i64> @orq_broadcast(<8 x i64> %a) nounwind {
; ALL-LABEL: orq_broadcast:
; ALL:       ## BB#0:
; ALL-NEXT:    vporq {{.*}}(%rip){1to8}, %zmm0, %zmm0
; ALL-NEXT:    retq
  %b = or <8 x i64> %a, <i64 2, i64 2, i64 2, i64 2, i64 2, i64 2, i64 2, i64 2>
  ret <8 x i64> %b
}

define <16 x i32> @andd512fold(<16 x i32> %y, <16 x i32>* %x) {
; KNL-LABEL: andd512fold:
; KNL:       ## BB#0: ## %entry
; KNL-NEXT:    vpandd (%rdi), %zmm0, %zmm0
; KNL-NEXT:    retq
;
; SKX-LABEL: andd512fold:
; SKX:       ## BB#0: ## %entry
; SKX-NEXT:    vandps (%rdi), %zmm0, %zmm0
; SKX-NEXT:    retq
entry:
  %a = load <16 x i32>, <16 x i32>* %x, align 4
  %b = and <16 x i32> %y, %a
  ret <16 x i32> %b
}

define <8 x i64> @andqbrst(<8 x i64> %p1, i64* %ap) {
; ALL-LABEL: andqbrst:
; ALL:       ## BB#0: ## %entry
; ALL-NEXT:    vpandq (%rdi){1to8}, %zmm0, %zmm0
; ALL-NEXT:    retq
entry:
  %a = load i64, i64* %ap, align 8
  %b = insertelement <8 x i64> undef, i64 %a, i32 0
  %c = shufflevector <8 x i64> %b, <8 x i64> undef, <8 x i32> zeroinitializer
  %d = and <8 x i64> %p1, %c
  ret <8 x i64>%d
}

define <64 x i8> @and_v64i8(<64 x i8> %a, <64 x i8> %b) {
; KNL-LABEL: and_v64i8:
; KNL:       ## BB#0:
; KNL-NEXT:    vandps %ymm2, %ymm0, %ymm0
; KNL-NEXT:    vandps %ymm3, %ymm1, %ymm1
; KNL-NEXT:    retq
;
; SKX-LABEL: and_v64i8:
; SKX:       ## BB#0:
; SKX-NEXT:    vandps %zmm1, %zmm0, %zmm0
; SKX-NEXT:    retq
  %res = and <64 x i8> %a, %b
  ret <64 x i8> %res
}

define <64 x i8> @andn_v64i8(<64 x i8> %a, <64 x i8> %b) {
; KNL-LABEL: andn_v64i8:
; KNL:       ## BB#0:
; KNL-NEXT:    vandnps %ymm0, %ymm2, %ymm0
; KNL-NEXT:    vandnps %ymm1, %ymm3, %ymm1
; KNL-NEXT:    retq
;
; SKX-LABEL: andn_v64i8:
; SKX:       ## BB#0:
; SKX-NEXT:    vandnps %zmm0, %zmm1, %zmm0
; SKX-NEXT:    retq
  %b2 = xor <64 x i8> %b, <i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1,
                           i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1,
                           i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1,
                           i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1>
  %res = and <64 x i8> %a, %b2
  ret <64 x i8> %res
}

define <64 x i8> @or_v64i8(<64 x i8> %a, <64 x i8> %b) {
; KNL-LABEL: or_v64i8:
; KNL:       ## BB#0:
; KNL-NEXT:    vorps %ymm2, %ymm0, %ymm0
; KNL-NEXT:    vorps %ymm3, %ymm1, %ymm1
; KNL-NEXT:    retq
;
; SKX-LABEL: or_v64i8:
; SKX:       ## BB#0:
; SKX-NEXT:    vorps %zmm1, %zmm0, %zmm0
; SKX-NEXT:    retq
  %res = or <64 x i8> %a, %b
  ret <64 x i8> %res
}

define <64 x i8> @xor_v64i8(<64 x i8> %a, <64 x i8> %b) {
; KNL-LABEL: xor_v64i8:
; KNL:       ## BB#0:
; KNL-NEXT:    vxorps %ymm2, %ymm0, %ymm0
; KNL-NEXT:    vxorps %ymm3, %ymm1, %ymm1
; KNL-NEXT:    retq
;
; SKX-LABEL: xor_v64i8:
; SKX:       ## BB#0:
; SKX-NEXT:    vxorps %zmm1, %zmm0, %zmm0
; SKX-NEXT:    retq
  %res = xor <64 x i8> %a, %b
  ret <64 x i8> %res
}

define <32 x i16> @and_v32i16(<32 x i16> %a, <32 x i16> %b) {
; KNL-LABEL: and_v32i16:
; KNL:       ## BB#0:
; KNL-NEXT:    vandps %ymm2, %ymm0, %ymm0
; KNL-NEXT:    vandps %ymm3, %ymm1, %ymm1
; KNL-NEXT:    retq
;
; SKX-LABEL: and_v32i16:
; SKX:       ## BB#0:
; SKX-NEXT:    vandps %zmm1, %zmm0, %zmm0
; SKX-NEXT:    retq
  %res = and <32 x i16> %a, %b
  ret <32 x i16> %res
}

define <32 x i16> @andn_v32i16(<32 x i16> %a, <32 x i16> %b) {
; KNL-LABEL: andn_v32i16:
; KNL:       ## BB#0:
; KNL-NEXT:    vandnps %ymm0, %ymm2, %ymm0
; KNL-NEXT:    vandnps %ymm1, %ymm3, %ymm1
; KNL-NEXT:    retq
;
; SKX-LABEL: andn_v32i16:
; SKX:       ## BB#0:
; SKX-NEXT:    vandnps %zmm0, %zmm1, %zmm0
; SKX-NEXT:    retq
  %b2 = xor <32 x i16> %b, <i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1,
                            i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1>
  %res = and <32 x i16> %a, %b2
  ret <32 x i16> %res
}

define <32 x i16> @or_v32i16(<32 x i16> %a, <32 x i16> %b) {
; KNL-LABEL: or_v32i16:
; KNL:       ## BB#0:
; KNL-NEXT:    vorps %ymm2, %ymm0, %ymm0
; KNL-NEXT:    vorps %ymm3, %ymm1, %ymm1
; KNL-NEXT:    retq
;
; SKX-LABEL: or_v32i16:
; SKX:       ## BB#0:
; SKX-NEXT:    vorps %zmm1, %zmm0, %zmm0
; SKX-NEXT:    retq
  %res = or <32 x i16> %a, %b
  ret <32 x i16> %res
}

define <32 x i16> @xor_v32i16(<32 x i16> %a, <32 x i16> %b) {
; KNL-LABEL: xor_v32i16:
; KNL:       ## BB#0:
; KNL-NEXT:    vxorps %ymm2, %ymm0, %ymm0
; KNL-NEXT:    vxorps %ymm3, %ymm1, %ymm1
; KNL-NEXT:    retq
;
; SKX-LABEL: xor_v32i16:
; SKX:       ## BB#0:
; SKX-NEXT:    vxorps %zmm1, %zmm0, %zmm0
; SKX-NEXT:    retq
  %res = xor <32 x i16> %a, %b
  ret <32 x i16> %res
}

define <16 x float> @masked_and_v16f32(<16 x float> %a, <16 x float> %b, <16 x float> %passThru, i16 %mask, <16 x float> %c) {
; KNL-LABEL: masked_and_v16f32:
; KNL:       ## BB#0:
; KNL-NEXT:    kmovw %edi, %k1
; KNL-NEXT:    vpandd %zmm1, %zmm0, %zmm2 {%k1}
; KNL-NEXT:    vaddps %zmm2, %zmm3, %zmm0
; KNL-NEXT:    retq
;
; SKX-LABEL: masked_and_v16f32:
; SKX:       ## BB#0:
; SKX-NEXT:    kmovw %edi, %k1
; SKX-NEXT:    vandps %zmm1, %zmm0, %zmm2 {%k1}
; SKX-NEXT:    vaddps %zmm2, %zmm3, %zmm0
; SKX-NEXT:    retq
  %a1 = bitcast <16 x float> %a to <16 x i32>
  %b1 = bitcast <16 x float> %b to <16 x i32>
  %passThru1 = bitcast <16 x float> %passThru to <16 x i32>
  %mask1 = bitcast i16 %mask to <16 x i1>
  %op = and <16 x i32> %a1, %b1
  %select = select <16 x i1> %mask1, <16 x i32> %op, <16 x i32> %passThru1
  %cast = bitcast <16 x i32> %select to <16 x float>
  %add = fadd <16 x float> %c, %cast
  ret <16 x float> %add
}

define <16 x float> @masked_or_v16f32(<16 x float> %a, <16 x float> %b, <16 x float> %passThru, i16 %mask, <16 x float> %c) {
; KNL-LABEL: masked_or_v16f32:
; KNL:       ## BB#0:
; KNL-NEXT:    kmovw %edi, %k1
; KNL-NEXT:    vpandd %zmm1, %zmm0, %zmm2 {%k1}
; KNL-NEXT:    vaddps %zmm2, %zmm3, %zmm0
; KNL-NEXT:    retq
;
; SKX-LABEL: masked_or_v16f32:
; SKX:       ## BB#0:
; SKX-NEXT:    kmovw %edi, %k1
; SKX-NEXT:    vandps %zmm1, %zmm0, %zmm2 {%k1}
; SKX-NEXT:    vaddps %zmm2, %zmm3, %zmm0
; SKX-NEXT:    retq
  %a1 = bitcast <16 x float> %a to <16 x i32>
  %b1 = bitcast <16 x float> %b to <16 x i32>
  %passThru1 = bitcast <16 x float> %passThru to <16 x i32>
  %mask1 = bitcast i16 %mask to <16 x i1>
  %op = and <16 x i32> %a1, %b1
  %select = select <16 x i1> %mask1, <16 x i32> %op, <16 x i32> %passThru1
  %cast = bitcast <16 x i32> %select to <16 x float>
  %add = fadd <16 x float> %c, %cast
  ret <16 x float> %add
}

define <16 x float> @masked_xor_v16f32(<16 x float> %a, <16 x float> %b, <16 x float> %passThru, i16 %mask, <16 x float> %c) {
; KNL-LABEL: masked_xor_v16f32:
; KNL:       ## BB#0:
; KNL-NEXT:    kmovw %edi, %k1
; KNL-NEXT:    vpandd %zmm1, %zmm0, %zmm2 {%k1}
; KNL-NEXT:    vaddps %zmm2, %zmm3, %zmm0
; KNL-NEXT:    retq
;
; SKX-LABEL: masked_xor_v16f32:
; SKX:       ## BB#0:
; SKX-NEXT:    kmovw %edi, %k1
; SKX-NEXT:    vandps %zmm1, %zmm0, %zmm2 {%k1}
; SKX-NEXT:    vaddps %zmm2, %zmm3, %zmm0
; SKX-NEXT:    retq
  %a1 = bitcast <16 x float> %a to <16 x i32>
  %b1 = bitcast <16 x float> %b to <16 x i32>
  %passThru1 = bitcast <16 x float> %passThru to <16 x i32>
  %mask1 = bitcast i16 %mask to <16 x i1>
  %op = and <16 x i32> %a1, %b1
  %select = select <16 x i1> %mask1, <16 x i32> %op, <16 x i32> %passThru1
  %cast = bitcast <16 x i32> %select to <16 x float>
  %add = fadd <16 x float> %c, %cast
  ret <16 x float> %add
}

define <8 x double> @masked_and_v8f64(<8 x double> %a, <8 x double> %b, <8 x double> %passThru, i8 %mask, <8 x double> %c) {
; KNL-LABEL: masked_and_v8f64:
; KNL:       ## BB#0:
; KNL-NEXT:    kmovw %edi, %k1
; KNL-NEXT:    vpandq %zmm1, %zmm0, %zmm2 {%k1}
; KNL-NEXT:    vaddpd %zmm2, %zmm3, %zmm0
; KNL-NEXT:    retq
;
; SKX-LABEL: masked_and_v8f64:
; SKX:       ## BB#0:
; SKX-NEXT:    kmovb %edi, %k1
; SKX-NEXT:    vandpd %zmm1, %zmm0, %zmm2 {%k1}
; SKX-NEXT:    vaddpd %zmm2, %zmm3, %zmm0
; SKX-NEXT:    retq
  %a1 = bitcast <8 x double> %a to <8 x i64>
  %b1 = bitcast <8 x double> %b to <8 x i64>
  %passThru1 = bitcast <8 x double> %passThru to <8 x i64>
  %mask1 = bitcast i8 %mask to <8 x i1>
  %op = and <8 x i64> %a1, %b1
  %select = select <8 x i1> %mask1, <8 x i64> %op, <8 x i64> %passThru1
  %cast = bitcast <8 x i64> %select to <8 x double>
  %add = fadd <8 x double> %c, %cast
  ret <8 x double> %add
}

define <8 x double> @masked_or_v8f64(<8 x double> %a, <8 x double> %b, <8 x double> %passThru, i8 %mask, <8 x double> %c) {
; KNL-LABEL: masked_or_v8f64:
; KNL:       ## BB#0:
; KNL-NEXT:    kmovw %edi, %k1
; KNL-NEXT:    vpandq %zmm1, %zmm0, %zmm2 {%k1}
; KNL-NEXT:    vaddpd %zmm2, %zmm3, %zmm0
; KNL-NEXT:    retq
;
; SKX-LABEL: masked_or_v8f64:
; SKX:       ## BB#0:
; SKX-NEXT:    kmovb %edi, %k1
; SKX-NEXT:    vandpd %zmm1, %zmm0, %zmm2 {%k1}
; SKX-NEXT:    vaddpd %zmm2, %zmm3, %zmm0
; SKX-NEXT:    retq
  %a1 = bitcast <8 x double> %a to <8 x i64>
  %b1 = bitcast <8 x double> %b to <8 x i64>
  %passThru1 = bitcast <8 x double> %passThru to <8 x i64>
  %mask1 = bitcast i8 %mask to <8 x i1>
  %op = and <8 x i64> %a1, %b1
  %select = select <8 x i1> %mask1, <8 x i64> %op, <8 x i64> %passThru1
  %cast = bitcast <8 x i64> %select to <8 x double>
  %add = fadd <8 x double> %c, %cast
  ret <8 x double> %add
}

define <8 x double> @masked_xor_v8f64(<8 x double> %a, <8 x double> %b, <8 x double> %passThru, i8 %mask, <8 x double> %c) {
; KNL-LABEL: masked_xor_v8f64:
; KNL:       ## BB#0:
; KNL-NEXT:    kmovw %edi, %k1
; KNL-NEXT:    vpandq %zmm1, %zmm0, %zmm2 {%k1}
; KNL-NEXT:    vaddpd %zmm2, %zmm3, %zmm0
; KNL-NEXT:    retq
;
; SKX-LABEL: masked_xor_v8f64:
; SKX:       ## BB#0:
; SKX-NEXT:    kmovb %edi, %k1
; SKX-NEXT:    vandpd %zmm1, %zmm0, %zmm2 {%k1}
; SKX-NEXT:    vaddpd %zmm2, %zmm3, %zmm0
; SKX-NEXT:    retq
  %a1 = bitcast <8 x double> %a to <8 x i64>
  %b1 = bitcast <8 x double> %b to <8 x i64>
  %passThru1 = bitcast <8 x double> %passThru to <8 x i64>
  %mask1 = bitcast i8 %mask to <8 x i1>
  %op = and <8 x i64> %a1, %b1
  %select = select <8 x i1> %mask1, <8 x i64> %op, <8 x i64> %passThru1
  %cast = bitcast <8 x i64> %select to <8 x double>
  %add = fadd <8 x double> %c, %cast
  ret <8 x double> %add
}

define <8 x i64> @test_mm512_mask_and_epi32(<8 x i64> %__src, i16 zeroext %__k, <8 x i64> %__a, <8 x i64> %__b) {
; KNL-LABEL: test_mm512_mask_and_epi32:
; KNL:       ## BB#0: ## %entry
; KNL-NEXT:    kmovw %edi, %k1
; KNL-NEXT:    vpandd %zmm2, %zmm1, %zmm0 {%k1}
; KNL-NEXT:    retq
;
; SKX-LABEL: test_mm512_mask_and_epi32:
; SKX:       ## BB#0: ## %entry
; SKX-NEXT:    kmovw %edi, %k1
; SKX-NEXT:    vandps %zmm2, %zmm1, %zmm0 {%k1}
; SKX-NEXT:    retq
entry:
  %and1.i.i = and <8 x i64> %__a, %__b
  %0 = bitcast <8 x i64> %and1.i.i to <16 x i32>
  %1 = bitcast <8 x i64> %__src to <16 x i32>
  %2 = bitcast i16 %__k to <16 x i1>
  %3 = select <16 x i1> %2, <16 x i32> %0, <16 x i32> %1
  %4 = bitcast <16 x i32> %3 to <8 x i64>
  ret <8 x i64> %4
}

define <8 x i64> @test_mm512_mask_or_epi32(<8 x i64> %__src, i16 zeroext %__k, <8 x i64> %__a, <8 x i64> %__b) {
; KNL-LABEL: test_mm512_mask_or_epi32:
; KNL:       ## BB#0: ## %entry
; KNL-NEXT:    kmovw %edi, %k1
; KNL-NEXT:    vpord %zmm2, %zmm1, %zmm0 {%k1}
; KNL-NEXT:    retq
;
; SKX-LABEL: test_mm512_mask_or_epi32:
; SKX:       ## BB#0: ## %entry
; SKX-NEXT:    kmovw %edi, %k1
; SKX-NEXT:    vorps %zmm2, %zmm1, %zmm0 {%k1}
; SKX-NEXT:    retq
entry:
  %or1.i.i = or <8 x i64> %__a, %__b
  %0 = bitcast <8 x i64> %or1.i.i to <16 x i32>
  %1 = bitcast <8 x i64> %__src to <16 x i32>
  %2 = bitcast i16 %__k to <16 x i1>
  %3 = select <16 x i1> %2, <16 x i32> %0, <16 x i32> %1
  %4 = bitcast <16 x i32> %3 to <8 x i64>
  ret <8 x i64> %4
}

define <8 x i64> @test_mm512_mask_xor_epi32(<8 x i64> %__src, i16 zeroext %__k, <8 x i64> %__a, <8 x i64> %__b) {
; KNL-LABEL: test_mm512_mask_xor_epi32:
; KNL:       ## BB#0: ## %entry
; KNL-NEXT:    kmovw %edi, %k1
; KNL-NEXT:    vpxord %zmm2, %zmm1, %zmm0 {%k1}
; KNL-NEXT:    retq
;
; SKX-LABEL: test_mm512_mask_xor_epi32:
; SKX:       ## BB#0: ## %entry
; SKX-NEXT:    kmovw %edi, %k1
; SKX-NEXT:    vxorps %zmm2, %zmm1, %zmm0 {%k1}
; SKX-NEXT:    retq
entry:
  %xor1.i.i = xor <8 x i64> %__a, %__b
  %0 = bitcast <8 x i64> %xor1.i.i to <16 x i32>
  %1 = bitcast <8 x i64> %__src to <16 x i32>
  %2 = bitcast i16 %__k to <16 x i1>
  %3 = select <16 x i1> %2, <16 x i32> %0, <16 x i32> %1
  %4 = bitcast <16 x i32> %3 to <8 x i64>
  ret <8 x i64> %4
}
