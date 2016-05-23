; NOTE: Assertions have been autogenerated by update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mcpu=skx | FileCheck --check-prefix=SKX %s


define <8 x i16> @extract_subvector128_v32i16(<32 x i16> %x) nounwind {
; SKX-LABEL: extract_subvector128_v32i16:
; SKX:       ## BB#0:
; SKX-NEXT:    vextracti32x4 $2, %zmm0, %xmm0
; SKX-NEXT:    retq
  %r1 = shufflevector <32 x i16> %x, <32 x i16> undef, <8 x i32> <i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23>
  ret <8 x i16> %r1
}

define <8 x i16> @extract_subvector128_v32i16_first_element(<32 x i16> %x) nounwind {
; SKX-LABEL: extract_subvector128_v32i16_first_element:
; SKX:       ## BB#0:
; SKX-NEXT:    retq
  %r1 = shufflevector <32 x i16> %x, <32 x i16> undef, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  ret <8 x i16> %r1
}

define <16 x i8> @extract_subvector128_v64i8(<64 x i8> %x) nounwind {
; SKX-LABEL: extract_subvector128_v64i8:
; SKX:       ## BB#0:
; SKX-NEXT:    vextracti32x4 $2, %zmm0, %xmm0
; SKX-NEXT:    retq
  %r1 = shufflevector <64 x i8> %x, <64 x i8> undef, <16 x i32> <i32 32, i32 33, i32 34, i32 35, i32 36, i32 37, i32 38,i32 39, i32 40, i32 41, i32 42, i32 43, i32 44, i32 45, i32 46, i32 47>
  ret <16 x i8> %r1
}

define <16 x i8> @extract_subvector128_v64i8_first_element(<64 x i8> %x) nounwind {
; SKX-LABEL: extract_subvector128_v64i8_first_element:
; SKX:       ## BB#0:
; SKX-NEXT:    retq
  %r1 = shufflevector <64 x i8> %x, <64 x i8> undef, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  ret <16 x i8> %r1
}


define <16 x i16> @extract_subvector256_v32i16(<32 x i16> %x) nounwind {
; SKX-LABEL: extract_subvector256_v32i16:
; SKX:       ## BB#0:
; SKX-NEXT:    vextracti64x4 $1, %zmm0, %ymm0
; SKX-NEXT:    retq
  %r1 = shufflevector <32 x i16> %x, <32 x i16> undef, <16 x i32> <i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31>
  ret <16 x i16> %r1
}

define <32 x i8> @extract_subvector256_v64i8(<64 x i8> %x) nounwind {
; SKX-LABEL: extract_subvector256_v64i8:
; SKX:       ## BB#0:
; SKX-NEXT:    vextracti64x4 $1, %zmm0, %ymm0
; SKX-NEXT:    retq
  %r1 = shufflevector <64 x i8> %x, <64 x i8> undef, <32 x i32> <i32 32, i32 33, i32 34, i32 35, i32 36, i32 37, i32 38, i32 39, i32 40, i32 41, i32 42, i32 43, i32 44, i32 45, i32 46, i32 47, i32 48, i32 49, i32 50, i32 51, i32 52, i32 53, i32 54, i32 55, i32 56, i32 57, i32 58, i32 59, i32 60, i32 61, i32 62, i32 63>
  ret <32 x i8> %r1
}

define void @extract_subvector256_v8f64_store(double* nocapture %addr, <4 x double> %a) nounwind uwtable ssp {
; SKX-LABEL: extract_subvector256_v8f64_store:
; SKX:       ## BB#0: ## %entry
; SKX-NEXT:    vextractf64x2 $1, %ymm0, (%rdi)
; SKX-NEXT:    retq
entry:
  %0 = shufflevector <4 x double> %a, <4 x double> undef, <2 x i32> <i32 2, i32 3>
  %1 = bitcast double* %addr to <2 x double>*
  store <2 x double> %0, <2 x double>* %1, align 1
  ret void
}

define void @extract_subvector256_v8f32_store(float* nocapture %addr, <8 x float> %a) nounwind uwtable ssp {
; SKX-LABEL: extract_subvector256_v8f32_store:
; SKX:       ## BB#0: ## %entry
; SKX-NEXT:    vextractf32x4 $1, %ymm0, (%rdi)
; SKX-NEXT:    retq
entry:
  %0 = shufflevector <8 x float> %a, <8 x float> undef, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %1 = bitcast float* %addr to <4 x float>*
  store <4 x float> %0, <4 x float>* %1, align 1
  ret void
}

define void @extract_subvector256_v4i64_store(i64* nocapture %addr, <4 x i64> %a) nounwind uwtable ssp {
; SKX-LABEL: extract_subvector256_v4i64_store:
; SKX:       ## BB#0: ## %entry
; SKX-NEXT:    vextracti64x2 $1, %ymm0, (%rdi)
; SKX-NEXT:    retq
entry:
  %0 = shufflevector <4 x i64> %a, <4 x i64> undef, <2 x i32> <i32 2, i32 3>
  %1 = bitcast i64* %addr to <2 x i64>*
  store <2 x i64> %0, <2 x i64>* %1, align 1
  ret void
}

define void @extract_subvector256_v8i32_store(i32* nocapture %addr, <8 x i32> %a) nounwind uwtable ssp {
; SKX-LABEL: extract_subvector256_v8i32_store:
; SKX:       ## BB#0: ## %entry
; SKX-NEXT:    vextracti32x4 $1, %ymm0, (%rdi)
; SKX-NEXT:    retq
entry:
  %0 = shufflevector <8 x i32> %a, <8 x i32> undef, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %1 = bitcast i32* %addr to <4 x i32>*
  store <4 x i32> %0, <4 x i32>* %1, align 1
  ret void
}

define void @extract_subvector256_v16i16_store(i16* nocapture %addr, <16 x i16> %a) nounwind uwtable ssp {
; SKX-LABEL: extract_subvector256_v16i16_store:
; SKX:       ## BB#0: ## %entry
; SKX-NEXT:    vextracti32x4 $1, %ymm0, (%rdi)
; SKX-NEXT:    retq
entry:
  %0 = shufflevector <16 x i16> %a, <16 x i16> undef, <8 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %1 = bitcast i16* %addr to <8 x i16>*
  store <8 x i16> %0, <8 x i16>* %1, align 1
  ret void
}

define void @extract_subvector256_v32i8_store(i8* nocapture %addr, <32 x i8> %a) nounwind uwtable ssp {
; SKX-LABEL: extract_subvector256_v32i8_store:
; SKX:       ## BB#0: ## %entry
; SKX-NEXT:    vextracti32x4 $1, %ymm0, (%rdi)
; SKX-NEXT:    retq
entry:
  %0 = shufflevector <32 x i8> %a, <32 x i8> undef, <16 x i32> <i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31>
  %1 = bitcast i8* %addr to <16 x i8>*
  store <16 x i8> %0, <16 x i8>* %1, align 1
  ret void
}

define void @extract_subvector256_v4f64_store_lo(double* nocapture %addr, <4 x double> %a) nounwind uwtable ssp {
; SKX-LABEL: extract_subvector256_v4f64_store_lo:
; SKX:       ## BB#0: ## %entry
; SKX-NEXT:    vmovupd %xmm0, (%rdi)
; SKX-NEXT:    retq
entry:
  %0 = shufflevector <4 x double> %a, <4 x double> undef, <2 x i32> <i32 0, i32 1>
  %1 = bitcast double* %addr to <2 x double>*
  store <2 x double> %0, <2 x double>* %1, align 1
  ret void
}

define void @extract_subvector256_v4f32_store_lo(float* nocapture %addr, <8 x float> %a) nounwind uwtable ssp {
; SKX-LABEL: extract_subvector256_v4f32_store_lo:
; SKX:       ## BB#0: ## %entry
; SKX-NEXT:    vmovups %xmm0, (%rdi)
; SKX-NEXT:    retq
entry:
  %0 = shufflevector <8 x float> %a, <8 x float> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %1 = bitcast float* %addr to <4 x float>*
  store <4 x float> %0, <4 x float>* %1, align 1
  ret void
}

define void @extract_subvector256_v2i64_store_lo(i64* nocapture %addr, <4 x i64> %a) nounwind uwtable ssp {
; SKX-LABEL: extract_subvector256_v2i64_store_lo:
; SKX:       ## BB#0: ## %entry
; SKX-NEXT:    vmovdqu64 %xmm0, (%rdi)
; SKX-NEXT:    retq
entry:
  %0 = shufflevector <4 x i64> %a, <4 x i64> undef, <2 x i32> <i32 0, i32 1>
  %1 = bitcast i64* %addr to <2 x i64>*
  store <2 x i64> %0, <2 x i64>* %1, align 1
  ret void
}

define void @extract_subvector256_v4i32_store_lo(i32* nocapture %addr, <8 x i32> %a) nounwind uwtable ssp {
; SKX-LABEL: extract_subvector256_v4i32_store_lo:
; SKX:       ## BB#0: ## %entry
; SKX-NEXT:    vmovdqu32 %xmm0, (%rdi)
; SKX-NEXT:    retq
entry:
  %0 = shufflevector <8 x i32> %a, <8 x i32> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %1 = bitcast i32* %addr to <4 x i32>*
  store <4 x i32> %0, <4 x i32>* %1, align 1
  ret void
}

define void @extract_subvector256_v8i16_store_lo(i16* nocapture %addr, <16 x i16> %a) nounwind uwtable ssp {
; SKX-LABEL: extract_subvector256_v8i16_store_lo:
; SKX:       ## BB#0: ## %entry
; SKX-NEXT:    vmovdqu32 %xmm0, (%rdi)
; SKX-NEXT:    retq
entry:
  %0 = shufflevector <16 x i16> %a, <16 x i16> undef, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %1 = bitcast i16* %addr to <8 x i16>*
  store <8 x i16> %0, <8 x i16>* %1, align 1
  ret void
}

define void @extract_subvector256_v16i8_store_lo(i8* nocapture %addr, <32 x i8> %a) nounwind uwtable ssp {
; SKX-LABEL: extract_subvector256_v16i8_store_lo:
; SKX:       ## BB#0: ## %entry
; SKX-NEXT:    vmovdqu32 %xmm0, (%rdi)
; SKX-NEXT:    retq
entry:
  %0 = shufflevector <32 x i8> %a, <32 x i8> undef, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %1 = bitcast i8* %addr to <16 x i8>*
  store <16 x i8> %0, <16 x i8>* %1, align 1
  ret void
}

define void @extract_subvector512_v2f64_store_lo(double* nocapture %addr, <8 x double> %a) nounwind uwtable ssp {
; SKX-LABEL: extract_subvector512_v2f64_store_lo:
; SKX:       ## BB#0: ## %entry
; SKX-NEXT:    vmovupd %xmm0, (%rdi)
; SKX-NEXT:    retq
entry:
  %0 = shufflevector <8 x double> %a, <8 x double> undef, <2 x i32> <i32 0, i32 1>
  %1 = bitcast double* %addr to <2 x double>*
  store <2 x double> %0, <2 x double>* %1, align 1
  ret void
}

define void @extract_subvector512_v4f32_store_lo(float* nocapture %addr, <16 x float> %a) nounwind uwtable ssp {
; SKX-LABEL: extract_subvector512_v4f32_store_lo:
; SKX:       ## BB#0: ## %entry
; SKX-NEXT:    vmovups %xmm0, (%rdi)
; SKX-NEXT:    retq
entry:
  %0 = shufflevector <16 x float> %a, <16 x float> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %1 = bitcast float* %addr to <4 x float>*
  store <4 x float> %0, <4 x float>* %1, align 1
  ret void
}

define void @extract_subvector512_v2i64_store_lo(i64* nocapture %addr, <8 x i64> %a) nounwind uwtable ssp {
; SKX-LABEL: extract_subvector512_v2i64_store_lo:
; SKX:       ## BB#0: ## %entry
; SKX-NEXT:    vmovdqu64 %xmm0, (%rdi)
; SKX-NEXT:    retq
entry:
  %0 = shufflevector <8 x i64> %a, <8 x i64> undef, <2 x i32> <i32 0, i32 1>
  %1 = bitcast i64* %addr to <2 x i64>*
  store <2 x i64> %0, <2 x i64>* %1, align 1
  ret void
}

define void @extract_subvector512_v4i32_store_lo(i32* nocapture %addr, <16 x i32> %a) nounwind uwtable ssp {
; SKX-LABEL: extract_subvector512_v4i32_store_lo:
; SKX:       ## BB#0: ## %entry
; SKX-NEXT:    vmovdqu32 %xmm0, (%rdi)
; SKX-NEXT:    retq
entry:
  %0 = shufflevector <16 x i32> %a, <16 x i32> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %1 = bitcast i32* %addr to <4 x i32>*
  store <4 x i32> %0, <4 x i32>* %1, align 1
  ret void
}

define void @extract_subvector512_v8i16_store_lo(i16* nocapture %addr, <32 x i16> %a) nounwind uwtable ssp {
; SKX-LABEL: extract_subvector512_v8i16_store_lo:
; SKX:       ## BB#0: ## %entry
; SKX-NEXT:    vmovdqu32 %xmm0, (%rdi)
; SKX-NEXT:    retq
entry:
  %0 = shufflevector <32 x i16> %a, <32 x i16> undef, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %1 = bitcast i16* %addr to <8 x i16>*
  store <8 x i16> %0, <8 x i16>* %1, align 1
  ret void
}

define void @extract_subvector512_v16i8_store_lo(i8* nocapture %addr, <64 x i8> %a) nounwind uwtable ssp {
; SKX-LABEL: extract_subvector512_v16i8_store_lo:
; SKX:       ## BB#0: ## %entry
; SKX-NEXT:    vmovdqu32 %xmm0, (%rdi)
; SKX-NEXT:    retq
entry:
  %0 = shufflevector <64 x i8> %a, <64 x i8> undef, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %1 = bitcast i8* %addr to <16 x i8>*
  store <16 x i8> %0, <16 x i8>* %1, align 1
  ret void
}

define void @extract_subvector512_v4f64_store_lo(double* nocapture %addr, <8 x double> %a) nounwind uwtable ssp {
; SKX-LABEL: extract_subvector512_v4f64_store_lo:
; SKX:       ## BB#0: ## %entry
; SKX-NEXT:    vmovupd %ymm0, (%rdi)
; SKX-NEXT:    retq
entry:
  %0 = shufflevector <8 x double> %a, <8 x double> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %1 = bitcast double* %addr to <4 x double>*
  store <4 x double> %0, <4 x double>* %1, align 1
  ret void
}

define void @extract_subvector512_v8f32_store_lo(float* nocapture %addr, <16 x float> %a) nounwind uwtable ssp {
; SKX-LABEL: extract_subvector512_v8f32_store_lo:
; SKX:       ## BB#0: ## %entry
; SKX-NEXT:    vmovups %ymm0, (%rdi)
; SKX-NEXT:    retq
entry:
  %0 = shufflevector <16 x float> %a, <16 x float> undef, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %1 = bitcast float* %addr to <8 x float>*
  store <8 x float> %0, <8 x float>* %1, align 1
  ret void
}

define void @extract_subvector512_v4i64_store_lo(i64* nocapture %addr, <8 x i64> %a) nounwind uwtable ssp {
; SKX-LABEL: extract_subvector512_v4i64_store_lo:
; SKX:       ## BB#0: ## %entry
; SKX-NEXT:    vmovdqu64 %ymm0, (%rdi)
; SKX-NEXT:    retq
entry:
  %0 = shufflevector <8 x i64> %a, <8 x i64> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %1 = bitcast i64* %addr to <4 x i64>*
  store <4 x i64> %0, <4 x i64>* %1, align 1
  ret void
}

define void @extract_subvector512_v8i32_store_lo(i32* nocapture %addr, <16 x i32> %a) nounwind uwtable ssp {
; SKX-LABEL: extract_subvector512_v8i32_store_lo:
; SKX:       ## BB#0: ## %entry
; SKX-NEXT:    vmovdqu32 %ymm0, (%rdi)
; SKX-NEXT:    retq
entry:
  %0 = shufflevector <16 x i32> %a, <16 x i32> undef, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %1 = bitcast i32* %addr to <8 x i32>*
  store <8 x i32> %0, <8 x i32>* %1, align 1
  ret void
}

define void @extract_subvector512_v16i16_store_lo(i16* nocapture %addr, <32 x i16> %a) nounwind uwtable ssp {
; SKX-LABEL: extract_subvector512_v16i16_store_lo:
; SKX:       ## BB#0: ## %entry
; SKX-NEXT:    vmovdqu32 %ymm0, (%rdi)
; SKX-NEXT:    retq
entry:
  %0 = shufflevector <32 x i16> %a, <32 x i16> undef, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %1 = bitcast i16* %addr to <16 x i16>*
  store <16 x i16> %0, <16 x i16>* %1, align 1
  ret void
}

define void @extract_subvector512_v32i8_store_lo(i8* nocapture %addr, <64 x i8> %a) nounwind uwtable ssp {
; SKX-LABEL: extract_subvector512_v32i8_store_lo:
; SKX:       ## BB#0: ## %entry
; SKX-NEXT:    vmovdqu32 %ymm0, (%rdi)
; SKX-NEXT:    retq
entry:
  %0 = shufflevector <64 x i8> %a, <64 x i8> undef, <32 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31>
  %1 = bitcast i8* %addr to <32 x i8>*
  store <32 x i8> %0, <32 x i8>* %1, align 1
  ret void
}
