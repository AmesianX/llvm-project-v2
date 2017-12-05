; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-apple-macosx10.10.0 -mattr=+avx512vl | FileCheck %s --check-prefix=CHECK --check-prefix=AVX512VL
; RUN: llc < %s -mtriple=x86_64-apple-macosx10.10.0 -mattr=+avx512vl,+avx512dq | FileCheck %s --check-prefix=CHECK --check-prefix=AVX512VLDQ

define <4 x float> @v4f32(<4 x float> %a, <4 x float> %b) nounwind {
; AVX512VL-LABEL: v4f32:
; AVX512VL:       ## %bb.0:
; AVX512VL-NEXT:    vpandd {{.*}}(%rip){1to4}, %xmm1, %xmm1
; AVX512VL-NEXT:    vpandd {{.*}}(%rip){1to4}, %xmm0, %xmm0
; AVX512VL-NEXT:    vpor %xmm1, %xmm0, %xmm0
; AVX512VL-NEXT:    retq
;
; AVX512VLDQ-LABEL: v4f32:
; AVX512VLDQ:       ## %bb.0:
; AVX512VLDQ-NEXT:    vandps {{.*}}(%rip){1to4}, %xmm1, %xmm1
; AVX512VLDQ-NEXT:    vandps {{.*}}(%rip){1to4}, %xmm0, %xmm0
; AVX512VLDQ-NEXT:    vorps %xmm1, %xmm0, %xmm0
; AVX512VLDQ-NEXT:    retq
  %tmp = tail call <4 x float> @llvm.copysign.v4f32( <4 x float> %a, <4 x float> %b )
  ret <4 x float> %tmp
}

define <8 x float> @v8f32(<8 x float> %a, <8 x float> %b) nounwind {
; AVX512VL-LABEL: v8f32:
; AVX512VL:       ## %bb.0:
; AVX512VL-NEXT:    vpandd {{.*}}(%rip){1to8}, %ymm1, %ymm1
; AVX512VL-NEXT:    vpandd {{.*}}(%rip){1to8}, %ymm0, %ymm0
; AVX512VL-NEXT:    vpor %ymm1, %ymm0, %ymm0
; AVX512VL-NEXT:    retq
;
; AVX512VLDQ-LABEL: v8f32:
; AVX512VLDQ:       ## %bb.0:
; AVX512VLDQ-NEXT:    vandps {{.*}}(%rip){1to8}, %ymm1, %ymm1
; AVX512VLDQ-NEXT:    vandps {{.*}}(%rip){1to8}, %ymm0, %ymm0
; AVX512VLDQ-NEXT:    vorps %ymm1, %ymm0, %ymm0
; AVX512VLDQ-NEXT:    retq
  %tmp = tail call <8 x float> @llvm.copysign.v8f32( <8 x float> %a, <8 x float> %b )
  ret <8 x float> %tmp
}

define <16 x float> @v16f32(<16 x float> %a, <16 x float> %b) nounwind {
; AVX512VL-LABEL: v16f32:
; AVX512VL:       ## %bb.0:
; AVX512VL-NEXT:    vpandd {{.*}}(%rip){1to16}, %zmm1, %zmm1
; AVX512VL-NEXT:    vpandd {{.*}}(%rip){1to16}, %zmm0, %zmm0
; AVX512VL-NEXT:    vporq %zmm1, %zmm0, %zmm0
; AVX512VL-NEXT:    retq
;
; AVX512VLDQ-LABEL: v16f32:
; AVX512VLDQ:       ## %bb.0:
; AVX512VLDQ-NEXT:    vandps {{.*}}(%rip){1to16}, %zmm1, %zmm1
; AVX512VLDQ-NEXT:    vandps {{.*}}(%rip){1to16}, %zmm0, %zmm0
; AVX512VLDQ-NEXT:    vorps %zmm1, %zmm0, %zmm0
; AVX512VLDQ-NEXT:    retq
  %tmp = tail call <16 x float> @llvm.copysign.v16f32( <16 x float> %a, <16 x float> %b )
  ret <16 x float> %tmp
}

define <2 x double> @v2f64(<2 x double> %a, <2 x double> %b) nounwind {
; AVX512VL-LABEL: v2f64:
; AVX512VL:       ## %bb.0:
; AVX512VL-NEXT:    vpand {{.*}}(%rip), %xmm1, %xmm1
; AVX512VL-NEXT:    vpand {{.*}}(%rip), %xmm0, %xmm0
; AVX512VL-NEXT:    vpor %xmm1, %xmm0, %xmm0
; AVX512VL-NEXT:    retq
;
; AVX512VLDQ-LABEL: v2f64:
; AVX512VLDQ:       ## %bb.0:
; AVX512VLDQ-NEXT:    vandps {{.*}}(%rip), %xmm1, %xmm1
; AVX512VLDQ-NEXT:    vandps {{.*}}(%rip), %xmm0, %xmm0
; AVX512VLDQ-NEXT:    vorps %xmm1, %xmm0, %xmm0
; AVX512VLDQ-NEXT:    retq
  %tmp = tail call <2 x double> @llvm.copysign.v2f64( <2 x double> %a, <2 x double> %b )
  ret <2 x double> %tmp
}

define <4 x double> @v4f64(<4 x double> %a, <4 x double> %b) nounwind {
; AVX512VL-LABEL: v4f64:
; AVX512VL:       ## %bb.0:
; AVX512VL-NEXT:    vpandq {{.*}}(%rip){1to4}, %ymm1, %ymm1
; AVX512VL-NEXT:    vpandq {{.*}}(%rip){1to4}, %ymm0, %ymm0
; AVX512VL-NEXT:    vpor %ymm1, %ymm0, %ymm0
; AVX512VL-NEXT:    retq
;
; AVX512VLDQ-LABEL: v4f64:
; AVX512VLDQ:       ## %bb.0:
; AVX512VLDQ-NEXT:    vandpd {{.*}}(%rip){1to4}, %ymm1, %ymm1
; AVX512VLDQ-NEXT:    vandpd {{.*}}(%rip){1to4}, %ymm0, %ymm0
; AVX512VLDQ-NEXT:    vorpd %ymm1, %ymm0, %ymm0
; AVX512VLDQ-NEXT:    retq
  %tmp = tail call <4 x double> @llvm.copysign.v4f64( <4 x double> %a, <4 x double> %b )
  ret <4 x double> %tmp
}

define <8 x double> @v8f64(<8 x double> %a, <8 x double> %b) nounwind {
; AVX512VL-LABEL: v8f64:
; AVX512VL:       ## %bb.0:
; AVX512VL-NEXT:    vpandq {{.*}}(%rip){1to8}, %zmm1, %zmm1
; AVX512VL-NEXT:    vpandq {{.*}}(%rip){1to8}, %zmm0, %zmm0
; AVX512VL-NEXT:    vporq %zmm1, %zmm0, %zmm0
; AVX512VL-NEXT:    retq
;
; AVX512VLDQ-LABEL: v8f64:
; AVX512VLDQ:       ## %bb.0:
; AVX512VLDQ-NEXT:    vandpd {{.*}}(%rip){1to8}, %zmm1, %zmm1
; AVX512VLDQ-NEXT:    vandpd {{.*}}(%rip){1to8}, %zmm0, %zmm0
; AVX512VLDQ-NEXT:    vorpd %zmm1, %zmm0, %zmm0
; AVX512VLDQ-NEXT:    retq
  %tmp = tail call <8 x double> @llvm.copysign.v8f64( <8 x double> %a, <8 x double> %b )
  ret <8 x double> %tmp
}

declare <4 x float>     @llvm.copysign.v4f32(<4 x float>  %Mag, <4 x float>  %Sgn)
declare <8 x float>     @llvm.copysign.v8f32(<8 x float>  %Mag, <8 x float>  %Sgn)
declare <16 x float>    @llvm.copysign.v16f32(<16 x float>  %Mag, <16 x float>  %Sgn)
declare <2 x double>    @llvm.copysign.v2f64(<2 x double> %Mag, <2 x double> %Sgn)
declare <4 x double>    @llvm.copysign.v4f64(<4 x double> %Mag, <4 x double> %Sgn)
declare <8 x double>    @llvm.copysign.v8f64(<8 x double> %Mag, <8 x double> %Sgn)

