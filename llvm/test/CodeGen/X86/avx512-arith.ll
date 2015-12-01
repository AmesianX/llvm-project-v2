; RUN: llc < %s -mtriple=x86_64-apple-darwin -mattr=+avx512f | FileCheck --check-prefix=CHECK --check-prefix=AVX512F %s
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mattr=+avx512vl | FileCheck --check-prefix=CHECK --check-prefix=AVX512VL %s
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mattr=+avx512bw | FileCheck --check-prefix=CHECK --check-prefix=AVX512BW %s
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mattr=+avx512dq | FileCheck --check-prefix=CHECK --check-prefix=AVX512DQ %s
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mattr=+avx512dq -mattr=+avx512bw -mattr=+avx512vl| FileCheck --check-prefix=CHECK --check-prefix=SKX %s

define <8 x double> @addpd512(<8 x double> %y, <8 x double> %x) {
; CHECK-LABEL: addpd512:
; CHECK:       ## BB#0: ## %entry
; CHECK-NEXT:    vaddpd %zmm0, %zmm1, %zmm0
; CHECK-NEXT:    retq
entry:
  %add.i = fadd <8 x double> %x, %y
  ret <8 x double> %add.i
}

define <8 x double> @addpd512fold(<8 x double> %y) {
; CHECK-LABEL: addpd512fold:
; CHECK:       ## BB#0: ## %entry
; CHECK-NEXT:    vaddpd {{.*}}(%rip), %zmm0, %zmm0
; CHECK-NEXT:    retq
entry:
  %add.i = fadd <8 x double> %y, <double 4.500000e+00, double 3.400000e+00, double 2.300000e+00, double 1.200000e+00, double 4.500000e+00, double 3.800000e+00, double 2.300000e+00, double 1.200000e+00>
  ret <8 x double> %add.i
}

define <16 x float> @addps512(<16 x float> %y, <16 x float> %x) {
; CHECK-LABEL: addps512:
; CHECK:       ## BB#0: ## %entry
; CHECK-NEXT:    vaddps %zmm0, %zmm1, %zmm0
; CHECK-NEXT:    retq
entry:
  %add.i = fadd <16 x float> %x, %y
  ret <16 x float> %add.i
}

define <16 x float> @addps512fold(<16 x float> %y) {
; CHECK-LABEL: addps512fold:
; CHECK:       ## BB#0: ## %entry
; CHECK-NEXT:    vaddps {{.*}}(%rip), %zmm0, %zmm0
; CHECK-NEXT:    retq
entry:
  %add.i = fadd <16 x float> %y, <float 4.500000e+00, float 0x400B333340000000, float 0x4002666660000000, float 0x3FF3333340000000, float 4.500000e+00, float 0x400B333340000000, float 0x4002666660000000, float 0x3FF3333340000000, float 4.500000e+00, float 0x400B333340000000, float 0x4002666660000000, float 4.500000e+00, float 4.500000e+00, float 0x400B333340000000,  float 0x4002666660000000, float 0x3FF3333340000000>
  ret <16 x float> %add.i
}

define <8 x double> @subpd512(<8 x double> %y, <8 x double> %x) {
; CHECK-LABEL: subpd512:
; CHECK:       ## BB#0: ## %entry
; CHECK-NEXT:    vsubpd %zmm0, %zmm1, %zmm0
; CHECK-NEXT:    retq
entry:
  %sub.i = fsub <8 x double> %x, %y
  ret <8 x double> %sub.i
}

define <8 x double> @subpd512fold(<8 x double> %y, <8 x double>* %x) {
; CHECK-LABEL: subpd512fold:
; CHECK:       ## BB#0: ## %entry
; CHECK-NEXT:    vsubpd (%rdi), %zmm0, %zmm0
; CHECK-NEXT:    retq
entry:
  %tmp2 = load <8 x double>, <8 x double>* %x, align 8
  %sub.i = fsub <8 x double> %y, %tmp2
  ret <8 x double> %sub.i
}

define <16 x float> @subps512(<16 x float> %y, <16 x float> %x) {
; CHECK-LABEL: subps512:
; CHECK:       ## BB#0: ## %entry
; CHECK-NEXT:    vsubps %zmm0, %zmm1, %zmm0
; CHECK-NEXT:    retq
entry:
  %sub.i = fsub <16 x float> %x, %y
  ret <16 x float> %sub.i
}

define <16 x float> @subps512fold(<16 x float> %y, <16 x float>* %x) {
; CHECK-LABEL: subps512fold:
; CHECK:       ## BB#0: ## %entry
; CHECK-NEXT:    vsubps (%rdi), %zmm0, %zmm0
; CHECK-NEXT:    retq
entry:
  %tmp2 = load <16 x float>, <16 x float>* %x, align 4
  %sub.i = fsub <16 x float> %y, %tmp2
  ret <16 x float> %sub.i
}

define <8 x i64> @imulq512(<8 x i64> %y, <8 x i64> %x) {
; AVX512F-LABEL: imulq512:
; AVX512F:       ## BB#0:
; AVX512F-NEXT:    vpmuludq %zmm0, %zmm1, %zmm2
; AVX512F-NEXT:    vpsrlq $32, %zmm0, %zmm3
; AVX512F-NEXT:    vpmuludq %zmm3, %zmm1, %zmm3
; AVX512F-NEXT:    vpsllq $32, %zmm3, %zmm3
; AVX512F-NEXT:    vpaddq %zmm3, %zmm2, %zmm2
; AVX512F-NEXT:    vpsrlq $32, %zmm1, %zmm1
; AVX512F-NEXT:    vpmuludq %zmm0, %zmm1, %zmm0
; AVX512F-NEXT:    vpsllq $32, %zmm0, %zmm0
; AVX512F-NEXT:    vpaddq %zmm0, %zmm2, %zmm0
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: imulq512:
; AVX512VL:       ## BB#0:
; AVX512VL-NEXT:    vpmuludq %zmm0, %zmm1, %zmm2
; AVX512VL-NEXT:    vpsrlq $32, %zmm0, %zmm3
; AVX512VL-NEXT:    vpmuludq %zmm3, %zmm1, %zmm3
; AVX512VL-NEXT:    vpsllq $32, %zmm3, %zmm3
; AVX512VL-NEXT:    vpaddq %zmm3, %zmm2, %zmm2
; AVX512VL-NEXT:    vpsrlq $32, %zmm1, %zmm1
; AVX512VL-NEXT:    vpmuludq %zmm0, %zmm1, %zmm0
; AVX512VL-NEXT:    vpsllq $32, %zmm0, %zmm0
; AVX512VL-NEXT:    vpaddq %zmm0, %zmm2, %zmm0
; AVX512VL-NEXT:    retq
;
; AVX512BW-LABEL: imulq512:
; AVX512BW:       ## BB#0:
; AVX512BW-NEXT:    vpmuludq %zmm0, %zmm1, %zmm2
; AVX512BW-NEXT:    vpsrlq $32, %zmm0, %zmm3
; AVX512BW-NEXT:    vpmuludq %zmm3, %zmm1, %zmm3
; AVX512BW-NEXT:    vpsllq $32, %zmm3, %zmm3
; AVX512BW-NEXT:    vpaddq %zmm3, %zmm2, %zmm2
; AVX512BW-NEXT:    vpsrlq $32, %zmm1, %zmm1
; AVX512BW-NEXT:    vpmuludq %zmm0, %zmm1, %zmm0
; AVX512BW-NEXT:    vpsllq $32, %zmm0, %zmm0
; AVX512BW-NEXT:    vpaddq %zmm0, %zmm2, %zmm0
; AVX512BW-NEXT:    retq
;
; AVX512DQ-LABEL: imulq512:
; AVX512DQ:       ## BB#0:
; AVX512DQ-NEXT:    vpmullq %zmm0, %zmm1, %zmm0
; AVX512DQ-NEXT:    retq
;
; SKX-LABEL: imulq512:
; SKX:       ## BB#0:
; SKX-NEXT:    vpmullq %zmm0, %zmm1, %zmm0
; SKX-NEXT:    retq
  %z = mul <8 x i64>%x, %y
  ret <8 x i64>%z
}

define <8 x double> @mulpd512(<8 x double> %y, <8 x double> %x) {
; CHECK-LABEL: mulpd512:
; CHECK:       ## BB#0: ## %entry
; CHECK-NEXT:    vmulpd %zmm0, %zmm1, %zmm0
; CHECK-NEXT:    retq
entry:
  %mul.i = fmul <8 x double> %x, %y
  ret <8 x double> %mul.i
}

define <8 x double> @mulpd512fold(<8 x double> %y) {
; CHECK-LABEL: mulpd512fold:
; CHECK:       ## BB#0: ## %entry
; CHECK-NEXT:    vmulpd {{.*}}(%rip), %zmm0, %zmm0
; CHECK-NEXT:    retq
entry:
  %mul.i = fmul <8 x double> %y, <double 4.500000e+00, double 3.400000e+00, double 2.300000e+00, double 1.200000e+00, double 4.500000e+00, double 3.400000e+00, double 2.300000e+00, double 1.200000e+00>
  ret <8 x double> %mul.i
}

define <16 x float> @mulps512(<16 x float> %y, <16 x float> %x) {
; CHECK-LABEL: mulps512:
; CHECK:       ## BB#0: ## %entry
; CHECK-NEXT:    vmulps %zmm0, %zmm1, %zmm0
; CHECK-NEXT:    retq
entry:
  %mul.i = fmul <16 x float> %x, %y
  ret <16 x float> %mul.i
}

define <16 x float> @mulps512fold(<16 x float> %y) {
; CHECK-LABEL: mulps512fold:
; CHECK:       ## BB#0: ## %entry
; CHECK-NEXT:    vmulps {{.*}}(%rip), %zmm0, %zmm0
; CHECK-NEXT:    retq
entry:
  %mul.i = fmul <16 x float> %y, <float 4.500000e+00, float 0x400B333340000000, float 0x4002666660000000, float 0x3FF3333340000000, float 4.500000e+00, float 0x400B333340000000, float 0x4002666660000000, float 0x3FF3333340000000, float 4.500000e+00, float 0x400B333340000000, float 0x4002666660000000, float 0x3FF3333340000000, float 4.500000e+00, float 0x400B333340000000, float 0x4002666660000000, float 0x3FF3333340000000>
  ret <16 x float> %mul.i
}

define <8 x double> @divpd512(<8 x double> %y, <8 x double> %x) {
; CHECK-LABEL: divpd512:
; CHECK:       ## BB#0: ## %entry
; CHECK-NEXT:    vdivpd %zmm0, %zmm1, %zmm0
; CHECK-NEXT:    retq
entry:
  %div.i = fdiv <8 x double> %x, %y
  ret <8 x double> %div.i
}

define <8 x double> @divpd512fold(<8 x double> %y) {
; CHECK-LABEL: divpd512fold:
; CHECK:       ## BB#0: ## %entry
; CHECK-NEXT:    vdivpd {{.*}}(%rip), %zmm0, %zmm0
; CHECK-NEXT:    retq
entry:
  %div.i = fdiv <8 x double> %y, <double 4.500000e+00, double 3.400000e+00, double 2.300000e+00, double 1.200000e+00, double 4.500000e+00, double 3.400000e+00, double 2.300000e+00, double 1.200000e+00>
  ret <8 x double> %div.i
}

define <16 x float> @divps512(<16 x float> %y, <16 x float> %x) {
; CHECK-LABEL: divps512:
; CHECK:       ## BB#0: ## %entry
; CHECK-NEXT:    vdivps %zmm0, %zmm1, %zmm0
; CHECK-NEXT:    retq
entry:
  %div.i = fdiv <16 x float> %x, %y
  ret <16 x float> %div.i
}

define <16 x float> @divps512fold(<16 x float> %y) {
; CHECK-LABEL: divps512fold:
; CHECK:       ## BB#0: ## %entry
; CHECK-NEXT:    vdivps {{.*}}(%rip), %zmm0, %zmm0
; CHECK-NEXT:    retq
entry:
  %div.i = fdiv <16 x float> %y, <float 4.500000e+00, float 0x400B333340000000, float 0x4002666660000000, float 0x3FF3333340000000, float 4.500000e+00, float 4.500000e+00, float 0x4002666660000000, float 0x3FF3333340000000, float 4.500000e+00, float 0x400B333340000000, float 0x4002666660000000, float 0x3FF3333340000000, float 4.500000e+00, float 4.500000e+00, float 0x4002666660000000, float 0x3FF3333340000000>
  ret <16 x float> %div.i
}

define <8 x i64> @vpaddq_test(<8 x i64> %i, <8 x i64> %j) nounwind readnone {
; CHECK-LABEL: vpaddq_test:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpaddq %zmm1, %zmm0, %zmm0
; CHECK-NEXT:    retq
  %x = add <8 x i64> %i, %j
  ret <8 x i64> %x
}

define <8 x i64> @vpaddq_fold_test(<8 x i64> %i, <8 x i64>* %j) nounwind {
; CHECK-LABEL: vpaddq_fold_test:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpaddq (%rdi), %zmm0, %zmm0
; CHECK-NEXT:    retq
  %tmp = load <8 x i64>, <8 x i64>* %j, align 4
  %x = add <8 x i64> %i, %tmp
  ret <8 x i64> %x
}

define <8 x i64> @vpaddq_broadcast_test(<8 x i64> %i) nounwind {
; CHECK-LABEL: vpaddq_broadcast_test:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpaddq {{.*}}(%rip){1to8}, %zmm0, %zmm0
; CHECK-NEXT:    retq
  %x = add <8 x i64> %i, <i64 1, i64 1, i64 1, i64 1, i64 1, i64 1, i64 1, i64 1>
  ret <8 x i64> %x
}

define <8 x i64> @vpaddq_broadcast2_test(<8 x i64> %i, i64* %j) nounwind {
; CHECK-LABEL: vpaddq_broadcast2_test:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpaddq (%rdi){1to8}, %zmm0, %zmm0
; CHECK-NEXT:    retq
  %tmp = load i64, i64* %j
  %j.0 = insertelement <8 x i64> undef, i64 %tmp, i32 0
  %j.1 = insertelement <8 x i64> %j.0, i64 %tmp, i32 1
  %j.2 = insertelement <8 x i64> %j.1, i64 %tmp, i32 2
  %j.3 = insertelement <8 x i64> %j.2, i64 %tmp, i32 3
  %j.4 = insertelement <8 x i64> %j.3, i64 %tmp, i32 4
  %j.5 = insertelement <8 x i64> %j.4, i64 %tmp, i32 5
  %j.6 = insertelement <8 x i64> %j.5, i64 %tmp, i32 6
  %j.7 = insertelement <8 x i64> %j.6, i64 %tmp, i32 7
  %x = add <8 x i64> %i, %j.7
  ret <8 x i64> %x
}

define <16 x i32> @vpaddd_test(<16 x i32> %i, <16 x i32> %j) nounwind readnone {
; CHECK-LABEL: vpaddd_test:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpaddd %zmm1, %zmm0, %zmm0
; CHECK-NEXT:    retq
  %x = add <16 x i32> %i, %j
  ret <16 x i32> %x
}

define <16 x i32> @vpaddd_fold_test(<16 x i32> %i, <16 x i32>* %j) nounwind {
; CHECK-LABEL: vpaddd_fold_test:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpaddd (%rdi), %zmm0, %zmm0
; CHECK-NEXT:    retq
  %tmp = load <16 x i32>, <16 x i32>* %j, align 4
  %x = add <16 x i32> %i, %tmp
  ret <16 x i32> %x
}

define <16 x i32> @vpaddd_broadcast_test(<16 x i32> %i) nounwind {
; CHECK-LABEL: vpaddd_broadcast_test:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpaddd {{.*}}(%rip){1to16}, %zmm0, %zmm0
; CHECK-NEXT:    retq
  %x = add <16 x i32> %i, <i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1>
  ret <16 x i32> %x
}

define <16 x i32> @vpaddd_mask_test(<16 x i32> %i, <16 x i32> %j, <16 x i32> %mask1) nounwind readnone {
; CHECK-LABEL: vpaddd_mask_test:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpxord %zmm3, %zmm3, %zmm3
; CHECK-NEXT:    vpcmpneqd %zmm3, %zmm2, %k1
; CHECK-NEXT:    vpaddd %zmm1, %zmm0, %zmm0 {%k1}
; CHECK-NEXT:    retq
  %mask = icmp ne <16 x i32> %mask1, zeroinitializer
  %x = add <16 x i32> %i, %j
  %r = select <16 x i1> %mask, <16 x i32> %x, <16 x i32> %i
  ret <16 x i32> %r
}

define <16 x i32> @vpaddd_maskz_test(<16 x i32> %i, <16 x i32> %j, <16 x i32> %mask1) nounwind readnone {
; CHECK-LABEL: vpaddd_maskz_test:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpxord %zmm3, %zmm3, %zmm3
; CHECK-NEXT:    vpcmpneqd %zmm3, %zmm2, %k1
; CHECK-NEXT:    vpaddd %zmm1, %zmm0, %zmm0 {%k1} {z}
; CHECK-NEXT:    retq
  %mask = icmp ne <16 x i32> %mask1, zeroinitializer
  %x = add <16 x i32> %i, %j
  %r = select <16 x i1> %mask, <16 x i32> %x, <16 x i32> zeroinitializer
  ret <16 x i32> %r
}

define <16 x i32> @vpaddd_mask_fold_test(<16 x i32> %i, <16 x i32>* %j.ptr, <16 x i32> %mask1) nounwind readnone {
; CHECK-LABEL: vpaddd_mask_fold_test:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpxord %zmm2, %zmm2, %zmm2
; CHECK-NEXT:    vpcmpneqd %zmm2, %zmm1, %k1
; CHECK-NEXT:    vpaddd (%rdi), %zmm0, %zmm0 {%k1}
; CHECK-NEXT:    retq
  %mask = icmp ne <16 x i32> %mask1, zeroinitializer
  %j = load <16 x i32>, <16 x i32>* %j.ptr
  %x = add <16 x i32> %i, %j
  %r = select <16 x i1> %mask, <16 x i32> %x, <16 x i32> %i
  ret <16 x i32> %r
}

define <16 x i32> @vpaddd_mask_broadcast_test(<16 x i32> %i, <16 x i32> %mask1) nounwind readnone {
; CHECK-LABEL: vpaddd_mask_broadcast_test:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpxord %zmm2, %zmm2, %zmm2
; CHECK-NEXT:    vpcmpneqd %zmm2, %zmm1, %k1
; CHECK-NEXT:    vpaddd {{.*}}(%rip){1to16}, %zmm0, %zmm0 {%k1}
; CHECK-NEXT:    retq
  %mask = icmp ne <16 x i32> %mask1, zeroinitializer
  %x = add <16 x i32> %i, <i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1>
  %r = select <16 x i1> %mask, <16 x i32> %x, <16 x i32> %i
  ret <16 x i32> %r
}

define <16 x i32> @vpaddd_maskz_fold_test(<16 x i32> %i, <16 x i32>* %j.ptr, <16 x i32> %mask1) nounwind readnone {
; CHECK-LABEL: vpaddd_maskz_fold_test:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpxord %zmm2, %zmm2, %zmm2
; CHECK-NEXT:    vpcmpneqd %zmm2, %zmm1, %k1
; CHECK-NEXT:    vpaddd (%rdi), %zmm0, %zmm0 {%k1} {z}
; CHECK-NEXT:    retq
  %mask = icmp ne <16 x i32> %mask1, zeroinitializer
  %j = load <16 x i32>, <16 x i32>* %j.ptr
  %x = add <16 x i32> %i, %j
  %r = select <16 x i1> %mask, <16 x i32> %x, <16 x i32> zeroinitializer
  ret <16 x i32> %r
}

define <16 x i32> @vpaddd_maskz_broadcast_test(<16 x i32> %i, <16 x i32> %mask1) nounwind readnone {
; CHECK-LABEL: vpaddd_maskz_broadcast_test:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpxord %zmm2, %zmm2, %zmm2
; CHECK-NEXT:    vpcmpneqd %zmm2, %zmm1, %k1
; CHECK-NEXT:    vpaddd {{.*}}(%rip){1to16}, %zmm0, %zmm0 {%k1} {z}
; CHECK-NEXT:    retq
  %mask = icmp ne <16 x i32> %mask1, zeroinitializer
  %x = add <16 x i32> %i, <i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1>
  %r = select <16 x i1> %mask, <16 x i32> %x, <16 x i32> zeroinitializer
  ret <16 x i32> %r
}

define <8 x i64> @vpsubq_test(<8 x i64> %i, <8 x i64> %j) nounwind readnone {
; CHECK-LABEL: vpsubq_test:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpsubq %zmm1, %zmm0, %zmm0
; CHECK-NEXT:    retq
  %x = sub <8 x i64> %i, %j
  ret <8 x i64> %x
}

define <16 x i32> @vpsubd_test(<16 x i32> %i, <16 x i32> %j) nounwind readnone {
; CHECK-LABEL: vpsubd_test:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpsubd %zmm1, %zmm0, %zmm0
; CHECK-NEXT:    retq
  %x = sub <16 x i32> %i, %j
  ret <16 x i32> %x
}

define <16 x i32> @vpmulld_test(<16 x i32> %i, <16 x i32> %j) {
; CHECK-LABEL: vpmulld_test:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpmulld %zmm1, %zmm0, %zmm0
; CHECK-NEXT:    retq
  %x = mul <16 x i32> %i, %j
  ret <16 x i32> %x
}

declare float @sqrtf(float) readnone
define float @sqrtA(float %a) nounwind uwtable readnone ssp {
; CHECK-LABEL: sqrtA:
; CHECK:       ## BB#0: ## %entry
; CHECK-NEXT:    vsqrtss %xmm0, %xmm0, %xmm0
; CHECK-NEXT:    retq
entry:
  %conv1 = tail call float @sqrtf(float %a) nounwind readnone
  ret float %conv1
}

declare double @sqrt(double) readnone
define double @sqrtB(double %a) nounwind uwtable readnone ssp {
; CHECK-LABEL: sqrtB:
; CHECK:       ## BB#0: ## %entry
; CHECK-NEXT:    vsqrtsd %xmm0, %xmm0, %xmm0
; CHECK-NEXT:    retq
entry:
  %call = tail call double @sqrt(double %a) nounwind readnone
  ret double %call
}

declare float @llvm.sqrt.f32(float)
define float @sqrtC(float %a) nounwind {
; CHECK-LABEL: sqrtC:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vsqrtss %xmm0, %xmm0, %xmm0
; CHECK-NEXT:    retq
  %b = call float @llvm.sqrt.f32(float %a)
  ret float %b
}

declare <16 x float> @llvm.sqrt.v16f32(<16 x float>)
define <16 x float> @sqrtD(<16 x float> %a) nounwind {
; CHECK-LABEL: sqrtD:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vsqrtps %zmm0, %zmm0
; CHECK-NEXT:    retq
  %b = call <16 x float> @llvm.sqrt.v16f32(<16 x float> %a)
  ret <16 x float> %b
}

declare <8 x double> @llvm.sqrt.v8f64(<8 x double>)
define <8 x double> @sqrtE(<8 x double> %a) nounwind {
; CHECK-LABEL: sqrtE:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vsqrtpd %zmm0, %zmm0
; CHECK-NEXT:    retq
  %b = call <8 x double> @llvm.sqrt.v8f64(<8 x double> %a)
  ret <8 x double> %b
}

define <16 x float> @fadd_broadcast(<16 x float> %a) nounwind {
; CHECK-LABEL: fadd_broadcast:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vaddps {{.*}}(%rip){1to16}, %zmm0, %zmm0
; CHECK-NEXT:    retq
  %b = fadd <16 x float> %a, <float 0x3FB99999A0000000, float 0x3FB99999A0000000, float 0x3FB99999A0000000, float 0x3FB99999A0000000, float 0x3FB99999A0000000, float 0x3FB99999A0000000, float 0x3FB99999A0000000, float 0x3FB99999A0000000, float 0x3FB99999A0000000, float 0x3FB99999A0000000, float 0x3FB99999A0000000, float 0x3FB99999A0000000, float 0x3FB99999A0000000, float 0x3FB99999A0000000, float 0x3FB99999A0000000, float 0x3FB99999A0000000>
  ret <16 x float> %b
}

define <8 x i64> @addq_broadcast(<8 x i64> %a) nounwind {
; CHECK-LABEL: addq_broadcast:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpaddq {{.*}}(%rip){1to8}, %zmm0, %zmm0
; CHECK-NEXT:    retq
  %b = add <8 x i64> %a, <i64 2, i64 2, i64 2, i64 2, i64 2, i64 2, i64 2, i64 2>
  ret <8 x i64> %b
}

define <8 x i64> @orq_broadcast(<8 x i64> %a) nounwind {
; CHECK-LABEL: orq_broadcast:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vporq {{.*}}(%rip){1to8}, %zmm0, %zmm0
; CHECK-NEXT:    retq
  %b = or <8 x i64> %a, <i64 2, i64 2, i64 2, i64 2, i64 2, i64 2, i64 2, i64 2>
  ret <8 x i64> %b
}

define <16 x i32> @andd512fold(<16 x i32> %y, <16 x i32>* %x) {
; CHECK-LABEL: andd512fold:
; CHECK:       ## BB#0: ## %entry
; CHECK-NEXT:    vpandd (%rdi), %zmm0, %zmm0
; CHECK-NEXT:    retq
entry:
  %a = load <16 x i32>, <16 x i32>* %x, align 4
  %b = and <16 x i32> %y, %a
  ret <16 x i32> %b
}

define <8 x i64> @andqbrst(<8 x i64> %p1, i64* %ap) {
; CHECK-LABEL: andqbrst:
; CHECK:       ## BB#0: ## %entry
; CHECK-NEXT:    vpandq (%rdi){1to8}, %zmm0, %zmm0
; CHECK-NEXT:    retq
entry:
  %a = load i64, i64* %ap, align 8
  %b = insertelement <8 x i64> undef, i64 %a, i32 0
  %c = shufflevector <8 x i64> %b, <8 x i64> undef, <8 x i32> zeroinitializer
  %d = and <8 x i64> %p1, %c
  ret <8 x i64>%d
}

define <16 x float> @test_mask_vaddps(<16 x float> %dst, <16 x float> %i,
; CHECK-LABEL: test_mask_vaddps:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpxord %zmm4, %zmm4, %zmm4
; CHECK-NEXT:    vpcmpneqd %zmm4, %zmm3, %k1
; CHECK-NEXT:    vaddps %zmm2, %zmm1, %zmm0 {%k1}
; CHECK-NEXT:    retq
                                     <16 x float> %j, <16 x i32> %mask1)
                                     nounwind readnone {
  %mask = icmp ne <16 x i32> %mask1, zeroinitializer
  %x = fadd <16 x float> %i, %j
  %r = select <16 x i1> %mask, <16 x float> %x, <16 x float> %dst
  ret <16 x float> %r
}

define <16 x float> @test_mask_vmulps(<16 x float> %dst, <16 x float> %i,
; CHECK-LABEL: test_mask_vmulps:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpxord %zmm4, %zmm4, %zmm4
; CHECK-NEXT:    vpcmpneqd %zmm4, %zmm3, %k1
; CHECK-NEXT:    vmulps %zmm2, %zmm1, %zmm0 {%k1}
; CHECK-NEXT:    retq
                                     <16 x float> %j, <16 x i32> %mask1)
                                     nounwind readnone {
  %mask = icmp ne <16 x i32> %mask1, zeroinitializer
  %x = fmul <16 x float> %i, %j
  %r = select <16 x i1> %mask, <16 x float> %x, <16 x float> %dst
  ret <16 x float> %r
}

define <16 x float> @test_mask_vminps(<16 x float> %dst, <16 x float> %i,
; CHECK-LABEL: test_mask_vminps:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpxord %zmm4, %zmm4, %zmm4
; CHECK-NEXT:    vpcmpneqd %zmm4, %zmm3, %k1
; CHECK-NEXT:    vminps %zmm2, %zmm1, %zmm0 {%k1}
; CHECK-NEXT:    retq
                                     <16 x float> %j, <16 x i32> %mask1)
                                     nounwind readnone {
  %mask = icmp ne <16 x i32> %mask1, zeroinitializer
  %cmp_res = fcmp olt <16 x float> %i, %j
  %min = select <16 x i1> %cmp_res, <16 x float> %i, <16 x float> %j
  %r = select <16 x i1> %mask, <16 x float> %min, <16 x float> %dst
  ret <16 x float> %r
}

define <8 x double> @test_mask_vminpd(<8 x double> %dst, <8 x double> %i,
; AVX512F-LABEL: test_mask_vminpd:
; AVX512F:       ## BB#0:
; AVX512F-NEXT:    vpxor %ymm4, %ymm4, %ymm4
; AVX512F-NEXT:    vpcmpneqd %zmm4, %zmm3, %k1
; AVX512F-NEXT:    vminpd %zmm2, %zmm1, %zmm0 {%k1}
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: test_mask_vminpd:
; AVX512VL:       ## BB#0:
; AVX512VL-NEXT:    vpxor %ymm4, %ymm4, %ymm4
; AVX512VL-NEXT:    vpcmpneqd %ymm4, %ymm3, %k1
; AVX512VL-NEXT:    vminpd %zmm2, %zmm1, %zmm0 {%k1}
; AVX512VL-NEXT:    retq
;
; AVX512BW-LABEL: test_mask_vminpd:
; AVX512BW:       ## BB#0:
; AVX512BW-NEXT:    vpxor %ymm4, %ymm4, %ymm4
; AVX512BW-NEXT:    vpcmpneqd %zmm4, %zmm3, %k1
; AVX512BW-NEXT:    vminpd %zmm2, %zmm1, %zmm0 {%k1}
; AVX512BW-NEXT:    retq
;
; AVX512DQ-LABEL: test_mask_vminpd:
; AVX512DQ:       ## BB#0:
; AVX512DQ-NEXT:    vpxor %ymm4, %ymm4, %ymm4
; AVX512DQ-NEXT:    vpcmpneqd %zmm4, %zmm3, %k1
; AVX512DQ-NEXT:    vminpd %zmm2, %zmm1, %zmm0 {%k1}
; AVX512DQ-NEXT:    retq
;
; SKX-LABEL: test_mask_vminpd:
; SKX:       ## BB#0:
; SKX-NEXT:    vpxor %ymm4, %ymm4, %ymm4
; SKX-NEXT:    vpcmpneqd %ymm4, %ymm3, %k1
; SKX-NEXT:    vminpd %zmm2, %zmm1, %zmm0 {%k1}
; SKX-NEXT:    retq
                                     <8 x double> %j, <8 x i32> %mask1)
                                     nounwind readnone {
  %mask = icmp ne <8 x i32> %mask1, zeroinitializer
  %cmp_res = fcmp olt <8 x double> %i, %j
  %min = select <8 x i1> %cmp_res, <8 x double> %i, <8 x double> %j
  %r = select <8 x i1> %mask, <8 x double> %min, <8 x double> %dst
  ret <8 x double> %r
}

define <16 x float> @test_mask_vmaxps(<16 x float> %dst, <16 x float> %i,
; CHECK-LABEL: test_mask_vmaxps:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpxord %zmm4, %zmm4, %zmm4
; CHECK-NEXT:    vpcmpneqd %zmm4, %zmm3, %k1
; CHECK-NEXT:    vmaxps %zmm2, %zmm1, %zmm0 {%k1}
; CHECK-NEXT:    retq
                                     <16 x float> %j, <16 x i32> %mask1)
                                     nounwind readnone {
  %mask = icmp ne <16 x i32> %mask1, zeroinitializer
  %cmp_res = fcmp ogt <16 x float> %i, %j
  %max = select <16 x i1> %cmp_res, <16 x float> %i, <16 x float> %j
  %r = select <16 x i1> %mask, <16 x float> %max, <16 x float> %dst
  ret <16 x float> %r
}

define <8 x double> @test_mask_vmaxpd(<8 x double> %dst, <8 x double> %i,
; AVX512F-LABEL: test_mask_vmaxpd:
; AVX512F:       ## BB#0:
; AVX512F-NEXT:    vpxor %ymm4, %ymm4, %ymm4
; AVX512F-NEXT:    vpcmpneqd %zmm4, %zmm3, %k1
; AVX512F-NEXT:    vmaxpd %zmm2, %zmm1, %zmm0 {%k1}
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: test_mask_vmaxpd:
; AVX512VL:       ## BB#0:
; AVX512VL-NEXT:    vpxor %ymm4, %ymm4, %ymm4
; AVX512VL-NEXT:    vpcmpneqd %ymm4, %ymm3, %k1
; AVX512VL-NEXT:    vmaxpd %zmm2, %zmm1, %zmm0 {%k1}
; AVX512VL-NEXT:    retq
;
; AVX512BW-LABEL: test_mask_vmaxpd:
; AVX512BW:       ## BB#0:
; AVX512BW-NEXT:    vpxor %ymm4, %ymm4, %ymm4
; AVX512BW-NEXT:    vpcmpneqd %zmm4, %zmm3, %k1
; AVX512BW-NEXT:    vmaxpd %zmm2, %zmm1, %zmm0 {%k1}
; AVX512BW-NEXT:    retq
;
; AVX512DQ-LABEL: test_mask_vmaxpd:
; AVX512DQ:       ## BB#0:
; AVX512DQ-NEXT:    vpxor %ymm4, %ymm4, %ymm4
; AVX512DQ-NEXT:    vpcmpneqd %zmm4, %zmm3, %k1
; AVX512DQ-NEXT:    vmaxpd %zmm2, %zmm1, %zmm0 {%k1}
; AVX512DQ-NEXT:    retq
;
; SKX-LABEL: test_mask_vmaxpd:
; SKX:       ## BB#0:
; SKX-NEXT:    vpxor %ymm4, %ymm4, %ymm4
; SKX-NEXT:    vpcmpneqd %ymm4, %ymm3, %k1
; SKX-NEXT:    vmaxpd %zmm2, %zmm1, %zmm0 {%k1}
; SKX-NEXT:    retq
                                     <8 x double> %j, <8 x i32> %mask1)
                                     nounwind readnone {
  %mask = icmp ne <8 x i32> %mask1, zeroinitializer
  %cmp_res = fcmp ogt <8 x double> %i, %j
  %max = select <8 x i1> %cmp_res, <8 x double> %i, <8 x double> %j
  %r = select <8 x i1> %mask, <8 x double> %max, <8 x double> %dst
  ret <8 x double> %r
}

define <16 x float> @test_mask_vsubps(<16 x float> %dst, <16 x float> %i,
; CHECK-LABEL: test_mask_vsubps:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpxord %zmm4, %zmm4, %zmm4
; CHECK-NEXT:    vpcmpneqd %zmm4, %zmm3, %k1
; CHECK-NEXT:    vsubps %zmm2, %zmm1, %zmm0 {%k1}
; CHECK-NEXT:    retq
                                     <16 x float> %j, <16 x i32> %mask1)
                                     nounwind readnone {
  %mask = icmp ne <16 x i32> %mask1, zeroinitializer
  %x = fsub <16 x float> %i, %j
  %r = select <16 x i1> %mask, <16 x float> %x, <16 x float> %dst
  ret <16 x float> %r
}

define <16 x float> @test_mask_vdivps(<16 x float> %dst, <16 x float> %i,
; CHECK-LABEL: test_mask_vdivps:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpxord %zmm4, %zmm4, %zmm4
; CHECK-NEXT:    vpcmpneqd %zmm4, %zmm3, %k1
; CHECK-NEXT:    vdivps %zmm2, %zmm1, %zmm0 {%k1}
; CHECK-NEXT:    retq
                                     <16 x float> %j, <16 x i32> %mask1)
                                     nounwind readnone {
  %mask = icmp ne <16 x i32> %mask1, zeroinitializer
  %x = fdiv <16 x float> %i, %j
  %r = select <16 x i1> %mask, <16 x float> %x, <16 x float> %dst
  ret <16 x float> %r
}

define <8 x double> @test_mask_vaddpd(<8 x double> %dst, <8 x double> %i,
; CHECK-LABEL: test_mask_vaddpd:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpxord %zmm4, %zmm4, %zmm4
; CHECK-NEXT:    vpcmpneqq %zmm4, %zmm3, %k1
; CHECK-NEXT:    vaddpd %zmm2, %zmm1, %zmm0 {%k1}
; CHECK-NEXT:    retq
                                     <8 x double> %j, <8 x i64> %mask1)
                                     nounwind readnone {
  %mask = icmp ne <8 x i64> %mask1, zeroinitializer
  %x = fadd <8 x double> %i, %j
  %r = select <8 x i1> %mask, <8 x double> %x, <8 x double> %dst
  ret <8 x double> %r
}

define <8 x double> @test_maskz_vaddpd(<8 x double> %i, <8 x double> %j,
; CHECK-LABEL: test_maskz_vaddpd:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpxord %zmm3, %zmm3, %zmm3
; CHECK-NEXT:    vpcmpneqq %zmm3, %zmm2, %k1
; CHECK-NEXT:    vaddpd %zmm1, %zmm0, %zmm0 {%k1} {z}
; CHECK-NEXT:    retq
                                      <8 x i64> %mask1) nounwind readnone {
  %mask = icmp ne <8 x i64> %mask1, zeroinitializer
  %x = fadd <8 x double> %i, %j
  %r = select <8 x i1> %mask, <8 x double> %x, <8 x double> zeroinitializer
  ret <8 x double> %r
}

define <8 x double> @test_mask_fold_vaddpd(<8 x double> %dst, <8 x double> %i,
; CHECK-LABEL: test_mask_fold_vaddpd:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpxord %zmm3, %zmm3, %zmm3
; CHECK-NEXT:    vpcmpneqq %zmm3, %zmm2, %k1
; CHECK-NEXT:    vaddpd (%rdi), %zmm1, %zmm0 {%k1}
; CHECK-NEXT:    retq
                                     <8 x double>* %j,  <8 x i64> %mask1)
                                     nounwind {
  %mask = icmp ne <8 x i64> %mask1, zeroinitializer
  %tmp = load <8 x double>, <8 x double>* %j, align 8
  %x = fadd <8 x double> %i, %tmp
  %r = select <8 x i1> %mask, <8 x double> %x, <8 x double> %dst
  ret <8 x double> %r
}

define <8 x double> @test_maskz_fold_vaddpd(<8 x double> %i, <8 x double>* %j,
; CHECK-LABEL: test_maskz_fold_vaddpd:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpxord %zmm2, %zmm2, %zmm2
; CHECK-NEXT:    vpcmpneqq %zmm2, %zmm1, %k1
; CHECK-NEXT:    vaddpd (%rdi), %zmm0, %zmm0 {%k1} {z}
; CHECK-NEXT:    retq
                                      <8 x i64> %mask1) nounwind {
  %mask = icmp ne <8 x i64> %mask1, zeroinitializer
  %tmp = load <8 x double>, <8 x double>* %j, align 8
  %x = fadd <8 x double> %i, %tmp
  %r = select <8 x i1> %mask, <8 x double> %x, <8 x double> zeroinitializer
  ret <8 x double> %r
}

define <8 x double> @test_broadcast_vaddpd(<8 x double> %i, double* %j) nounwind {
; CHECK-LABEL: test_broadcast_vaddpd:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vaddpd (%rdi){1to8}, %zmm0, %zmm0
; CHECK-NEXT:    retq
  %tmp = load double, double* %j
  %b = insertelement <8 x double> undef, double %tmp, i32 0
  %c = shufflevector <8 x double> %b, <8 x double> undef,
                     <8 x i32> zeroinitializer
  %x = fadd <8 x double> %c, %i
  ret <8 x double> %x
}

define <8 x double> @test_mask_broadcast_vaddpd(<8 x double> %dst, <8 x double> %i,
; CHECK-LABEL: test_mask_broadcast_vaddpd:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpxord %zmm0, %zmm0, %zmm0
; CHECK-NEXT:    vpcmpneqq %zmm0, %zmm2, %k1
; CHECK-NEXT:    vaddpd (%rdi){1to8}, %zmm1, %zmm1 {%k1}
; CHECK-NEXT:    vmovaps %zmm1, %zmm0
; CHECK-NEXT:    retq
                                      double* %j, <8 x i64> %mask1) nounwind {
  %mask = icmp ne <8 x i64> %mask1, zeroinitializer
  %tmp = load double, double* %j
  %b = insertelement <8 x double> undef, double %tmp, i32 0
  %c = shufflevector <8 x double> %b, <8 x double> undef,
                     <8 x i32> zeroinitializer
  %x = fadd <8 x double> %c, %i
  %r = select <8 x i1> %mask, <8 x double> %x, <8 x double> %i
  ret <8 x double> %r
}

define <8 x double> @test_maskz_broadcast_vaddpd(<8 x double> %i, double* %j,
; CHECK-LABEL: test_maskz_broadcast_vaddpd:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vpxord %zmm2, %zmm2, %zmm2
; CHECK-NEXT:    vpcmpneqq %zmm2, %zmm1, %k1
; CHECK-NEXT:    vaddpd (%rdi){1to8}, %zmm0, %zmm0 {%k1} {z}
; CHECK-NEXT:    retq
                                       <8 x i64> %mask1) nounwind {
  %mask = icmp ne <8 x i64> %mask1, zeroinitializer
  %tmp = load double, double* %j
  %b = insertelement <8 x double> undef, double %tmp, i32 0
  %c = shufflevector <8 x double> %b, <8 x double> undef,
                     <8 x i32> zeroinitializer
  %x = fadd <8 x double> %c, %i
  %r = select <8 x i1> %mask, <8 x double> %x, <8 x double> zeroinitializer
  ret <8 x double> %r
}

define <16 x float>  @test_fxor(<16 x float> %a) {
; AVX512F-LABEL: test_fxor:
; AVX512F:       ## BB#0:
; AVX512F-NEXT:    vpxord {{.*}}(%rip), %zmm0, %zmm0
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: test_fxor:
; AVX512VL:       ## BB#0:
; AVX512VL-NEXT:    vpxord {{.*}}(%rip), %zmm0, %zmm0
; AVX512VL-NEXT:    retq
;
; AVX512BW-LABEL: test_fxor:
; AVX512BW:       ## BB#0:
; AVX512BW-NEXT:    vpxord {{.*}}(%rip), %zmm0, %zmm0
; AVX512BW-NEXT:    retq
;
; AVX512DQ-LABEL: test_fxor:
; AVX512DQ:       ## BB#0:
; AVX512DQ-NEXT:    vxorps {{.*}}(%rip), %zmm0, %zmm0
; AVX512DQ-NEXT:    retq
;
; SKX-LABEL: test_fxor:
; SKX:       ## BB#0:
; SKX-NEXT:    vxorps {{.*}}(%rip), %zmm0, %zmm0
; SKX-NEXT:    retq

  %res = fsub <16 x float> <float -0.000000e+00, float -0.000000e+00, float -0.000000e+00, float -0.000000e+00, float -0.000000e+00, float -0.000000e+00, float -0.000000e+00, float -0.000000e+00, float -0.000000e+00, float -0.000000e+00, float -0.000000e+00, float -0.000000e+00, float -0.000000e+00, float -0.000000e+00, float -0.000000e+00, float -0.000000e+00>, %a
  ret <16 x float>%res
}

