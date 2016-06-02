; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mcpu=knl | FileCheck %s

define void @test_store1(<16 x float> %data, i8* %ptr, i8* %ptr2, i16 %mask) {
; CHECK-LABEL: test_store1:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw %edx, %k1
; CHECK-NEXT:    vmovups %zmm0, (%rdi) {%k1}
; CHECK-NEXT:    vmovups %zmm0, (%rsi)
; CHECK-NEXT:    retq
  call void @llvm.x86.avx512.mask.storeu.ps.512(i8* %ptr, <16 x float> %data, i16 %mask)
  call void @llvm.x86.avx512.mask.storeu.ps.512(i8* %ptr2, <16 x float> %data, i16 -1)
  ret void
}

declare void @llvm.x86.avx512.mask.storeu.ps.512(i8*, <16 x float>, i16 )

define void @test_store2(<8 x double> %data, i8* %ptr, i8* %ptr2, i8 %mask) {
; CHECK-LABEL: test_store2:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw %edx, %k1
; CHECK-NEXT:    vmovupd %zmm0, (%rdi) {%k1}
; CHECK-NEXT:    vmovupd %zmm0, (%rsi)
; CHECK-NEXT:    retq
  call void @llvm.x86.avx512.mask.storeu.pd.512(i8* %ptr, <8 x double> %data, i8 %mask)
  call void @llvm.x86.avx512.mask.storeu.pd.512(i8* %ptr2, <8 x double> %data, i8 -1)
  ret void
}

declare void @llvm.x86.avx512.mask.storeu.pd.512(i8*, <8 x double>, i8)

define void @test_mask_store_aligned_ps(<16 x float> %data, i8* %ptr, i8* %ptr2, i16 %mask) {
; CHECK-LABEL: test_mask_store_aligned_ps:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw %edx, %k1
; CHECK-NEXT:    vmovaps %zmm0, (%rdi) {%k1}
; CHECK-NEXT:    vmovaps %zmm0, (%rsi)
; CHECK-NEXT:    retq
  call void @llvm.x86.avx512.mask.store.ps.512(i8* %ptr, <16 x float> %data, i16 %mask)
  call void @llvm.x86.avx512.mask.store.ps.512(i8* %ptr2, <16 x float> %data, i16 -1)
  ret void
}

declare void @llvm.x86.avx512.mask.store.ps.512(i8*, <16 x float>, i16 )

define void @test_mask_store_aligned_pd(<8 x double> %data, i8* %ptr, i8* %ptr2, i8 %mask) {
; CHECK-LABEL: test_mask_store_aligned_pd:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw %edx, %k1
; CHECK-NEXT:    vmovapd %zmm0, (%rdi) {%k1}
; CHECK-NEXT:    vmovapd %zmm0, (%rsi)
; CHECK-NEXT:    retq
  call void @llvm.x86.avx512.mask.store.pd.512(i8* %ptr, <8 x double> %data, i8 %mask)
  call void @llvm.x86.avx512.mask.store.pd.512(i8* %ptr2, <8 x double> %data, i8 -1)
  ret void
}

declare void @llvm.x86.avx512.mask.store.pd.512(i8*, <8 x double>, i8)

define void@test_int_x86_avx512_mask_storeu_q_512(i8* %ptr1, i8* %ptr2, <8 x i64> %x1, i8 %x2) {
; CHECK-LABEL: test_int_x86_avx512_mask_storeu_q_512:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw %edx, %k1
; CHECK-NEXT:    vmovdqu64 %zmm0, (%rdi) {%k1}
; CHECK-NEXT:    vmovdqu64 %zmm0, (%rsi)
; CHECK-NEXT:    retq
  call void @llvm.x86.avx512.mask.storeu.q.512(i8* %ptr1, <8 x i64> %x1, i8 %x2)
  call void @llvm.x86.avx512.mask.storeu.q.512(i8* %ptr2, <8 x i64> %x1, i8 -1)
  ret void
}

declare void @llvm.x86.avx512.mask.storeu.q.512(i8*, <8 x i64>, i8)

define void@test_int_x86_avx512_mask_storeu_d_512(i8* %ptr1, i8* %ptr2, <16 x i32> %x1, i16 %x2) {
; CHECK-LABEL: test_int_x86_avx512_mask_storeu_d_512:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw %edx, %k1
; CHECK-NEXT:    vmovdqu32 %zmm0, (%rdi) {%k1}
; CHECK-NEXT:    vmovdqu32 %zmm0, (%rsi)
; CHECK-NEXT:    retq
  call void @llvm.x86.avx512.mask.storeu.d.512(i8* %ptr1, <16 x i32> %x1, i16 %x2)
  call void @llvm.x86.avx512.mask.storeu.d.512(i8* %ptr2, <16 x i32> %x1, i16 -1)
  ret void
}

declare void @llvm.x86.avx512.mask.storeu.d.512(i8*, <16 x i32>, i16)

define void@test_int_x86_avx512_mask_store_q_512(i8* %ptr1, i8* %ptr2, <8 x i64> %x1, i8 %x2) {
; CHECK-LABEL: test_int_x86_avx512_mask_store_q_512:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw %edx, %k1
; CHECK-NEXT:    vmovdqa64 %zmm0, (%rdi) {%k1}
; CHECK-NEXT:    vmovdqa64 %zmm0, (%rsi)
; CHECK-NEXT:    retq
  call void @llvm.x86.avx512.mask.store.q.512(i8* %ptr1, <8 x i64> %x1, i8 %x2)
  call void @llvm.x86.avx512.mask.store.q.512(i8* %ptr2, <8 x i64> %x1, i8 -1)
  ret void
}

declare void @llvm.x86.avx512.mask.store.q.512(i8*, <8 x i64>, i8)

define void@test_int_x86_avx512_mask_store_d_512(i8* %ptr1, i8* %ptr2, <16 x i32> %x1, i16 %x2) {
; CHECK-LABEL: test_int_x86_avx512_mask_store_d_512:
; CHECK:       ## BB#0:
; CHECK-NEXT:    kmovw %edx, %k1
; CHECK-NEXT:    vmovdqa32 %zmm0, (%rdi) {%k1}
; CHECK-NEXT:    vmovdqa32 %zmm0, (%rsi)
; CHECK-NEXT:    retq
  call void @llvm.x86.avx512.mask.store.d.512(i8* %ptr1, <16 x i32> %x1, i16 %x2)
  call void @llvm.x86.avx512.mask.store.d.512(i8* %ptr2, <16 x i32> %x1, i16 -1)
  ret void
}

declare void @llvm.x86.avx512.mask.store.d.512(i8*, <16 x i32>, i16)

define <16 x float> @test_mask_load_aligned_ps(<16 x float> %data, i8* %ptr, i16 %mask) {
; CHECK-LABEL: test_mask_load_aligned_ps:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vmovaps (%rdi), %zmm0
; CHECK-NEXT:    kmovw %esi, %k1
; CHECK-NEXT:    vmovaps (%rdi), %zmm0 {%k1}
; CHECK-NEXT:    vmovaps (%rdi), %zmm1 {%k1} {z}
; CHECK-NEXT:    vaddps %zmm0, %zmm1, %zmm0
; CHECK-NEXT:    retq
  %res = call <16 x float> @llvm.x86.avx512.mask.load.ps.512(i8* %ptr, <16 x float> zeroinitializer, i16 -1)
  %res1 = call <16 x float> @llvm.x86.avx512.mask.load.ps.512(i8* %ptr, <16 x float> %res, i16 %mask)
  %res2 = call <16 x float> @llvm.x86.avx512.mask.load.ps.512(i8* %ptr, <16 x float> zeroinitializer, i16 %mask)
  %res4 = fadd <16 x float> %res2, %res1
  ret <16 x float> %res4
}

declare <16 x float> @llvm.x86.avx512.mask.load.ps.512(i8*, <16 x float>, i16)

define <16 x float> @test_mask_load_unaligned_ps(<16 x float> %data, i8* %ptr, i16 %mask) {
; CHECK-LABEL: test_mask_load_unaligned_ps:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vmovups (%rdi), %zmm0
; CHECK-NEXT:    kmovw %esi, %k1
; CHECK-NEXT:    vmovups (%rdi), %zmm0 {%k1}
; CHECK-NEXT:    vmovups (%rdi), %zmm1 {%k1} {z}
; CHECK-NEXT:    vaddps %zmm0, %zmm1, %zmm0
; CHECK-NEXT:    retq
  %res = call <16 x float> @llvm.x86.avx512.mask.loadu.ps.512(i8* %ptr, <16 x float> zeroinitializer, i16 -1)
  %res1 = call <16 x float> @llvm.x86.avx512.mask.loadu.ps.512(i8* %ptr, <16 x float> %res, i16 %mask)
  %res2 = call <16 x float> @llvm.x86.avx512.mask.loadu.ps.512(i8* %ptr, <16 x float> zeroinitializer, i16 %mask)
  %res4 = fadd <16 x float> %res2, %res1
  ret <16 x float> %res4
}

declare <16 x float> @llvm.x86.avx512.mask.loadu.ps.512(i8*, <16 x float>, i16)

define <8 x double> @test_mask_load_aligned_pd(<8 x double> %data, i8* %ptr, i8 %mask) {
; CHECK-LABEL: test_mask_load_aligned_pd:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vmovapd (%rdi), %zmm0
; CHECK-NEXT:    kmovw %esi, %k1
; CHECK-NEXT:    vmovapd (%rdi), %zmm0 {%k1}
; CHECK-NEXT:    vmovapd (%rdi), %zmm1 {%k1} {z}
; CHECK-NEXT:    vaddpd %zmm0, %zmm1, %zmm0
; CHECK-NEXT:    retq
  %res = call <8 x double> @llvm.x86.avx512.mask.load.pd.512(i8* %ptr, <8 x double> zeroinitializer, i8 -1)
  %res1 = call <8 x double> @llvm.x86.avx512.mask.load.pd.512(i8* %ptr, <8 x double> %res, i8 %mask)
  %res2 = call <8 x double> @llvm.x86.avx512.mask.load.pd.512(i8* %ptr, <8 x double> zeroinitializer, i8 %mask)
  %res4 = fadd <8 x double> %res2, %res1
  ret <8 x double> %res4
}

declare <8 x double> @llvm.x86.avx512.mask.load.pd.512(i8*, <8 x double>, i8)

define <8 x double> @test_mask_load_unaligned_pd(<8 x double> %data, i8* %ptr, i8 %mask) {
; CHECK-LABEL: test_mask_load_unaligned_pd:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vmovupd (%rdi), %zmm0
; CHECK-NEXT:    kmovw %esi, %k1
; CHECK-NEXT:    vmovupd (%rdi), %zmm0 {%k1}
; CHECK-NEXT:    vmovupd (%rdi), %zmm1 {%k1} {z}
; CHECK-NEXT:    vaddpd %zmm0, %zmm1, %zmm0
; CHECK-NEXT:    retq
  %res = call <8 x double> @llvm.x86.avx512.mask.loadu.pd.512(i8* %ptr, <8 x double> zeroinitializer, i8 -1)
  %res1 = call <8 x double> @llvm.x86.avx512.mask.loadu.pd.512(i8* %ptr, <8 x double> %res, i8 %mask)
  %res2 = call <8 x double> @llvm.x86.avx512.mask.loadu.pd.512(i8* %ptr, <8 x double> zeroinitializer, i8 %mask)
  %res4 = fadd <8 x double> %res2, %res1
  ret <8 x double> %res4
}

declare <8 x double> @llvm.x86.avx512.mask.loadu.pd.512(i8*, <8 x double>, i8)

declare <16 x i32> @llvm.x86.avx512.mask.loadu.d.512(i8*, <16 x i32>, i16)

define <16 x i32> @test_mask_load_unaligned_d(i8* %ptr, i8* %ptr2, <16 x i32> %data, i16 %mask) {
; CHECK-LABEL: test_mask_load_unaligned_d:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vmovdqu32 (%rdi), %zmm0
; CHECK-NEXT:    kmovw %edx, %k1
; CHECK-NEXT:    vmovdqu32 (%rsi), %zmm0 {%k1}
; CHECK-NEXT:    vmovdqu32 (%rdi), %zmm1 {%k1} {z}
; CHECK-NEXT:    vpaddd %zmm0, %zmm1, %zmm0
; CHECK-NEXT:    retq
  %res = call <16 x i32> @llvm.x86.avx512.mask.loadu.d.512(i8* %ptr, <16 x i32> zeroinitializer, i16 -1)
  %res1 = call <16 x i32> @llvm.x86.avx512.mask.loadu.d.512(i8* %ptr2, <16 x i32> %res, i16 %mask)
  %res2 = call <16 x i32> @llvm.x86.avx512.mask.loadu.d.512(i8* %ptr, <16 x i32> zeroinitializer, i16 %mask)
  %res4 = add <16 x i32> %res2, %res1
  ret <16 x i32> %res4
}

declare <8 x i64> @llvm.x86.avx512.mask.loadu.q.512(i8*, <8 x i64>, i8)

define <8 x i64> @test_mask_load_unaligned_q(i8* %ptr, i8* %ptr2, <8 x i64> %data, i8 %mask) {
; CHECK-LABEL: test_mask_load_unaligned_q:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vmovdqu64 (%rdi), %zmm0
; CHECK-NEXT:    kmovw %edx, %k1
; CHECK-NEXT:    vmovdqu64 (%rsi), %zmm0 {%k1}
; CHECK-NEXT:    vmovdqu64 (%rdi), %zmm1 {%k1} {z}
; CHECK-NEXT:    vpaddq %zmm0, %zmm1, %zmm0
; CHECK-NEXT:    retq
  %res = call <8 x i64> @llvm.x86.avx512.mask.loadu.q.512(i8* %ptr, <8 x i64> zeroinitializer, i8 -1)
  %res1 = call <8 x i64> @llvm.x86.avx512.mask.loadu.q.512(i8* %ptr2, <8 x i64> %res, i8 %mask)
  %res2 = call <8 x i64> @llvm.x86.avx512.mask.loadu.q.512(i8* %ptr, <8 x i64> zeroinitializer, i8 %mask)
  %res4 = add <8 x i64> %res2, %res1
  ret <8 x i64> %res4
}

declare <16 x i32> @llvm.x86.avx512.mask.load.d.512(i8*, <16 x i32>, i16)

define <16 x i32> @test_mask_load_aligned_d(<16 x i32> %data, i8* %ptr, i16 %mask) {
; CHECK-LABEL: test_mask_load_aligned_d:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vmovdqa32 (%rdi), %zmm0
; CHECK-NEXT:    kmovw %esi, %k1
; CHECK-NEXT:    vmovdqa32 (%rdi), %zmm0 {%k1}
; CHECK-NEXT:    vmovdqa32 (%rdi), %zmm1 {%k1} {z}
; CHECK-NEXT:    vpaddd %zmm0, %zmm1, %zmm0
; CHECK-NEXT:    retq
  %res = call <16 x i32> @llvm.x86.avx512.mask.load.d.512(i8* %ptr, <16 x i32> zeroinitializer, i16 -1)
  %res1 = call <16 x i32> @llvm.x86.avx512.mask.load.d.512(i8* %ptr, <16 x i32> %res, i16 %mask)
  %res2 = call <16 x i32> @llvm.x86.avx512.mask.load.d.512(i8* %ptr, <16 x i32> zeroinitializer, i16 %mask)
  %res4 = add <16 x i32> %res2, %res1
  ret <16 x i32> %res4
}

declare <8 x i64> @llvm.x86.avx512.mask.load.q.512(i8*, <8 x i64>, i8)

define <8 x i64> @test_mask_load_aligned_q(<8 x i64> %data, i8* %ptr, i8 %mask) {
; CHECK-LABEL: test_mask_load_aligned_q:
; CHECK:       ## BB#0:
; CHECK-NEXT:    vmovdqa64 (%rdi), %zmm0
; CHECK-NEXT:    kmovw %esi, %k1
; CHECK-NEXT:    vmovdqa64 (%rdi), %zmm0 {%k1}
; CHECK-NEXT:    vmovdqa64 (%rdi), %zmm1 {%k1} {z}
; CHECK-NEXT:    vpaddq %zmm0, %zmm1, %zmm0
; CHECK-NEXT:    retq
  %res = call <8 x i64> @llvm.x86.avx512.mask.load.q.512(i8* %ptr, <8 x i64> zeroinitializer, i8 -1)
  %res1 = call <8 x i64> @llvm.x86.avx512.mask.load.q.512(i8* %ptr, <8 x i64> %res, i8 %mask)
  %res2 = call <8 x i64> @llvm.x86.avx512.mask.load.q.512(i8* %ptr, <8 x i64> zeroinitializer, i8 %mask)
  %res4 = add <8 x i64> %res2, %res1
  ret <8 x i64> %res4
}

