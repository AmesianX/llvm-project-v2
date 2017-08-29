; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown-linux-gnu -mattr=+avx | FileCheck %s --check-prefix=X32
; RUN: llc < %s -mtriple=x86_64-unknown-linux-gnu -mattr=+avx | FileCheck %s --check-prefix=X64

; Verify that the backend correctly folds a sign/zero extend of a vector where
; elements are all constant values or UNDEFs.
; The backend should be able to optimize all the test functions below into
; simple loads from constant pool of the result. That is because the resulting
; vector should be known at static time.

define <4 x i16> @test_sext_4i8_4i16() {
; X32-LABEL: test_sext_4i8_4i16:
; X32:       # BB#0:
; X32-NEXT:    vmovaps {{.*#+}} xmm0 = [0,4294967295,2,4294967293]
; X32-NEXT:    retl
;
; X64-LABEL: test_sext_4i8_4i16:
; X64:       # BB#0:
; X64-NEXT:    vmovaps {{.*#+}} xmm0 = [0,4294967295,2,4294967293]
; X64-NEXT:    retq
  %1 = insertelement <4 x i8> undef, i8 0, i32 0
  %2 = insertelement <4 x i8> %1, i8 -1, i32 1
  %3 = insertelement <4 x i8> %2, i8 2, i32 2
  %4 = insertelement <4 x i8> %3, i8 -3, i32 3
  %5 = sext <4 x i8> %4 to <4 x i16>
  ret <4 x i16> %5
}

define <4 x i16> @test_sext_4i8_4i16_undef() {
; X32-LABEL: test_sext_4i8_4i16_undef:
; X32:       # BB#0:
; X32-NEXT:    vmovaps {{.*#+}} xmm0 = <u,4294967295,u,4294967293>
; X32-NEXT:    retl
;
; X64-LABEL: test_sext_4i8_4i16_undef:
; X64:       # BB#0:
; X64-NEXT:    vmovaps {{.*#+}} xmm0 = <u,4294967295,u,4294967293>
; X64-NEXT:    retq
  %1 = insertelement <4 x i8> undef, i8 undef, i32 0
  %2 = insertelement <4 x i8> %1, i8 -1, i32 1
  %3 = insertelement <4 x i8> %2, i8 undef, i32 2
  %4 = insertelement <4 x i8> %3, i8 -3, i32 3
  %5 = sext <4 x i8> %4 to <4 x i16>
  ret <4 x i16> %5
}

define <4 x i32> @test_sext_4i8_4i32() {
; X32-LABEL: test_sext_4i8_4i32:
; X32:       # BB#0:
; X32-NEXT:    vmovaps {{.*#+}} xmm0 = [0,4294967295,2,4294967293]
; X32-NEXT:    retl
;
; X64-LABEL: test_sext_4i8_4i32:
; X64:       # BB#0:
; X64-NEXT:    vmovaps {{.*#+}} xmm0 = [0,4294967295,2,4294967293]
; X64-NEXT:    retq
  %1 = insertelement <4 x i8> undef, i8 0, i32 0
  %2 = insertelement <4 x i8> %1, i8 -1, i32 1
  %3 = insertelement <4 x i8> %2, i8 2, i32 2
  %4 = insertelement <4 x i8> %3, i8 -3, i32 3
  %5 = sext <4 x i8> %4 to <4 x i32>
  ret <4 x i32> %5
}

define <4 x i32> @test_sext_4i8_4i32_undef() {
; X32-LABEL: test_sext_4i8_4i32_undef:
; X32:       # BB#0:
; X32-NEXT:    vmovaps {{.*#+}} xmm0 = <u,4294967295,u,4294967293>
; X32-NEXT:    retl
;
; X64-LABEL: test_sext_4i8_4i32_undef:
; X64:       # BB#0:
; X64-NEXT:    vmovaps {{.*#+}} xmm0 = <u,4294967295,u,4294967293>
; X64-NEXT:    retq
  %1 = insertelement <4 x i8> undef, i8 undef, i32 0
  %2 = insertelement <4 x i8> %1, i8 -1, i32 1
  %3 = insertelement <4 x i8> %2, i8 undef, i32 2
  %4 = insertelement <4 x i8> %3, i8 -3, i32 3
  %5 = sext <4 x i8> %4 to <4 x i32>
  ret <4 x i32> %5
}

define <4 x i64> @test_sext_4i8_4i64() {
; X32-LABEL: test_sext_4i8_4i64:
; X32:       # BB#0:
; X32-NEXT:    vmovaps {{.*#+}} ymm0 = [0,0,4294967295,4294967295,2,0,4294967293,4294967295]
; X32-NEXT:    retl
;
; X64-LABEL: test_sext_4i8_4i64:
; X64:       # BB#0:
; X64-NEXT:    vmovaps {{.*#+}} ymm0 = [0,18446744073709551615,2,18446744073709551613]
; X64-NEXT:    retq
  %1 = insertelement <4 x i8> undef, i8 0, i32 0
  %2 = insertelement <4 x i8> %1, i8 -1, i32 1
  %3 = insertelement <4 x i8> %2, i8 2, i32 2
  %4 = insertelement <4 x i8> %3, i8 -3, i32 3
  %5 = sext <4 x i8> %4 to <4 x i64>
  ret <4 x i64> %5
}

define <4 x i64> @test_sext_4i8_4i64_undef() {
; X32-LABEL: test_sext_4i8_4i64_undef:
; X32:       # BB#0:
; X32-NEXT:    vmovaps {{.*#+}} ymm0 = <u,u,4294967295,4294967295,u,u,4294967293,4294967295>
; X32-NEXT:    retl
;
; X64-LABEL: test_sext_4i8_4i64_undef:
; X64:       # BB#0:
; X64-NEXT:    vmovaps {{.*#+}} ymm0 = <u,18446744073709551615,u,18446744073709551613>
; X64-NEXT:    retq
  %1 = insertelement <4 x i8> undef, i8 undef, i32 0
  %2 = insertelement <4 x i8> %1, i8 -1, i32 1
  %3 = insertelement <4 x i8> %2, i8 undef, i32 2
  %4 = insertelement <4 x i8> %3, i8 -3, i32 3
  %5 = sext <4 x i8> %4 to <4 x i64>
  ret <4 x i64> %5
}

define <8 x i16> @test_sext_8i8_8i16() {
; X32-LABEL: test_sext_8i8_8i16:
; X32:       # BB#0:
; X32-NEXT:    vmovaps {{.*#+}} xmm0 = <0,65535,2,65533,u,u,u,u>
; X32-NEXT:    retl
;
; X64-LABEL: test_sext_8i8_8i16:
; X64:       # BB#0:
; X64-NEXT:    vmovaps {{.*#+}} xmm0 = <0,65535,2,65533,u,u,u,u>
; X64-NEXT:    retq
  %1 = insertelement <8 x i8> undef, i8 0, i32 0
  %2 = insertelement <8 x i8> %1, i8 -1, i32 1
  %3 = insertelement <8 x i8> %2, i8 2, i32 2
  %4 = insertelement <8 x i8> %3, i8 -3, i32 3
  %5 = insertelement <8 x i8> %4, i8 4, i32 4
  %6 = insertelement <8 x i8> %5, i8 -5, i32 5
  %7 = insertelement <8 x i8> %6, i8 6, i32 6
  %8 = insertelement <8 x i8> %7, i8 -7, i32 7
  %9 = sext <8 x i8> %4 to <8 x i16>
  ret <8 x i16> %9
}

define <8 x i32> @test_sext_8i8_8i32() {
; X32-LABEL: test_sext_8i8_8i32:
; X32:       # BB#0:
; X32-NEXT:    vmovaps {{.*#+}} ymm0 = <0,4294967295,2,4294967293,u,u,u,u>
; X32-NEXT:    retl
;
; X64-LABEL: test_sext_8i8_8i32:
; X64:       # BB#0:
; X64-NEXT:    vmovaps {{.*#+}} ymm0 = <0,4294967295,2,4294967293,u,u,u,u>
; X64-NEXT:    retq
  %1 = insertelement <8 x i8> undef, i8 0, i32 0
  %2 = insertelement <8 x i8> %1, i8 -1, i32 1
  %3 = insertelement <8 x i8> %2, i8 2, i32 2
  %4 = insertelement <8 x i8> %3, i8 -3, i32 3
  %5 = insertelement <8 x i8> %4, i8 4, i32 4
  %6 = insertelement <8 x i8> %5, i8 -5, i32 5
  %7 = insertelement <8 x i8> %6, i8 6, i32 6
  %8 = insertelement <8 x i8> %7, i8 -7, i32 7
  %9 = sext <8 x i8> %4 to <8 x i32>
  ret <8 x i32> %9
}

define <8 x i16> @test_sext_8i8_8i16_undef() {
; X32-LABEL: test_sext_8i8_8i16_undef:
; X32:       # BB#0:
; X32-NEXT:    vmovaps {{.*#+}} xmm0 = <u,65535,u,65533,u,u,u,u>
; X32-NEXT:    retl
;
; X64-LABEL: test_sext_8i8_8i16_undef:
; X64:       # BB#0:
; X64-NEXT:    vmovaps {{.*#+}} xmm0 = <u,65535,u,65533,u,u,u,u>
; X64-NEXT:    retq
  %1 = insertelement <8 x i8> undef, i8 undef, i32 0
  %2 = insertelement <8 x i8> %1, i8 -1, i32 1
  %3 = insertelement <8 x i8> %2, i8 undef, i32 2
  %4 = insertelement <8 x i8> %3, i8 -3, i32 3
  %5 = insertelement <8 x i8> %4, i8 undef, i32 4
  %6 = insertelement <8 x i8> %5, i8 -5, i32 5
  %7 = insertelement <8 x i8> %6, i8 undef, i32 6
  %8 = insertelement <8 x i8> %7, i8 -7, i32 7
  %9 = sext <8 x i8> %4 to <8 x i16>
  ret <8 x i16> %9
}

define <8 x i32> @test_sext_8i8_8i32_undef() {
; X32-LABEL: test_sext_8i8_8i32_undef:
; X32:       # BB#0:
; X32-NEXT:    vmovaps {{.*#+}} ymm0 = <0,u,2,u,u,u,u,u>
; X32-NEXT:    retl
;
; X64-LABEL: test_sext_8i8_8i32_undef:
; X64:       # BB#0:
; X64-NEXT:    vmovaps {{.*#+}} ymm0 = <0,u,2,u,u,u,u,u>
; X64-NEXT:    retq
  %1 = insertelement <8 x i8> undef, i8 0, i32 0
  %2 = insertelement <8 x i8> %1, i8 undef, i32 1
  %3 = insertelement <8 x i8> %2, i8 2, i32 2
  %4 = insertelement <8 x i8> %3, i8 undef, i32 3
  %5 = insertelement <8 x i8> %4, i8 4, i32 4
  %6 = insertelement <8 x i8> %5, i8 undef, i32 5
  %7 = insertelement <8 x i8> %6, i8 6, i32 6
  %8 = insertelement <8 x i8> %7, i8 undef, i32 7
  %9 = sext <8 x i8> %4 to <8 x i32>
  ret <8 x i32> %9
}

define <4 x i16> @test_zext_4i8_4i16() {
; X32-LABEL: test_zext_4i8_4i16:
; X32:       # BB#0:
; X32-NEXT:    vmovaps {{.*#+}} xmm0 = [0,255,2,253]
; X32-NEXT:    retl
;
; X64-LABEL: test_zext_4i8_4i16:
; X64:       # BB#0:
; X64-NEXT:    vmovaps {{.*#+}} xmm0 = [0,255,2,253]
; X64-NEXT:    retq
  %1 = insertelement <4 x i8> undef, i8 0, i32 0
  %2 = insertelement <4 x i8> %1, i8 -1, i32 1
  %3 = insertelement <4 x i8> %2, i8 2, i32 2
  %4 = insertelement <4 x i8> %3, i8 -3, i32 3
  %5 = zext <4 x i8> %4 to <4 x i16>
  ret <4 x i16> %5
}

define <4 x i32> @test_zext_4i8_4i32() {
; X32-LABEL: test_zext_4i8_4i32:
; X32:       # BB#0:
; X32-NEXT:    vmovaps {{.*#+}} xmm0 = [0,255,2,253]
; X32-NEXT:    retl
;
; X64-LABEL: test_zext_4i8_4i32:
; X64:       # BB#0:
; X64-NEXT:    vmovaps {{.*#+}} xmm0 = [0,255,2,253]
; X64-NEXT:    retq
  %1 = insertelement <4 x i8> undef, i8 0, i32 0
  %2 = insertelement <4 x i8> %1, i8 -1, i32 1
  %3 = insertelement <4 x i8> %2, i8 2, i32 2
  %4 = insertelement <4 x i8> %3, i8 -3, i32 3
  %5 = zext <4 x i8> %4 to <4 x i32>
  ret <4 x i32> %5
}

define <4 x i64> @test_zext_4i8_4i64() {
; X32-LABEL: test_zext_4i8_4i64:
; X32:       # BB#0:
; X32-NEXT:    vmovaps {{.*#+}} ymm0 = [0,0,255,0,2,0,253,0]
; X32-NEXT:    retl
;
; X64-LABEL: test_zext_4i8_4i64:
; X64:       # BB#0:
; X64-NEXT:    vmovaps {{.*#+}} ymm0 = [0,255,2,253]
; X64-NEXT:    retq
  %1 = insertelement <4 x i8> undef, i8 0, i32 0
  %2 = insertelement <4 x i8> %1, i8 -1, i32 1
  %3 = insertelement <4 x i8> %2, i8 2, i32 2
  %4 = insertelement <4 x i8> %3, i8 -3, i32 3
  %5 = zext <4 x i8> %4 to <4 x i64>
  ret <4 x i64> %5
}

define <4 x i16> @test_zext_4i8_4i16_undef() {
; X32-LABEL: test_zext_4i8_4i16_undef:
; X32:       # BB#0:
; X32-NEXT:    vmovaps {{.*#+}} xmm0 = <u,255,u,253>
; X32-NEXT:    retl
;
; X64-LABEL: test_zext_4i8_4i16_undef:
; X64:       # BB#0:
; X64-NEXT:    vmovaps {{.*#+}} xmm0 = <u,255,u,253>
; X64-NEXT:    retq
  %1 = insertelement <4 x i8> undef, i8 undef, i32 0
  %2 = insertelement <4 x i8> %1, i8 -1, i32 1
  %3 = insertelement <4 x i8> %2, i8 undef, i32 2
  %4 = insertelement <4 x i8> %3, i8 -3, i32 3
  %5 = zext <4 x i8> %4 to <4 x i16>
  ret <4 x i16> %5
}

define <4 x i32> @test_zext_4i8_4i32_undef() {
; X32-LABEL: test_zext_4i8_4i32_undef:
; X32:       # BB#0:
; X32-NEXT:    vmovaps {{.*#+}} xmm0 = <0,u,2,u>
; X32-NEXT:    retl
;
; X64-LABEL: test_zext_4i8_4i32_undef:
; X64:       # BB#0:
; X64-NEXT:    vmovaps {{.*#+}} xmm0 = <0,u,2,u>
; X64-NEXT:    retq
  %1 = insertelement <4 x i8> undef, i8 0, i32 0
  %2 = insertelement <4 x i8> %1, i8 undef, i32 1
  %3 = insertelement <4 x i8> %2, i8 2, i32 2
  %4 = insertelement <4 x i8> %3, i8 undef, i32 3
  %5 = zext <4 x i8> %4 to <4 x i32>
  ret <4 x i32> %5
}

define <4 x i64> @test_zext_4i8_4i64_undef() {
; X32-LABEL: test_zext_4i8_4i64_undef:
; X32:       # BB#0:
; X32-NEXT:    vmovaps {{.*#+}} ymm0 = <u,u,255,0,2,0,u,u>
; X32-NEXT:    retl
;
; X64-LABEL: test_zext_4i8_4i64_undef:
; X64:       # BB#0:
; X64-NEXT:    vmovaps {{.*#+}} ymm0 = <u,255,2,u>
; X64-NEXT:    retq
  %1 = insertelement <4 x i8> undef, i8 undef, i32 0
  %2 = insertelement <4 x i8> %1, i8 -1, i32 1
  %3 = insertelement <4 x i8> %2, i8 2, i32 2
  %4 = insertelement <4 x i8> %3, i8 undef, i32 3
  %5 = zext <4 x i8> %4 to <4 x i64>
  ret <4 x i64> %5
}

define <8 x i16> @test_zext_8i8_8i16() {
; X32-LABEL: test_zext_8i8_8i16:
; X32:       # BB#0:
; X32-NEXT:    vmovaps {{.*#+}} xmm0 = [0,255,2,253,4,251,6,249]
; X32-NEXT:    retl
;
; X64-LABEL: test_zext_8i8_8i16:
; X64:       # BB#0:
; X64-NEXT:    vmovaps {{.*#+}} xmm0 = [0,255,2,253,4,251,6,249]
; X64-NEXT:    retq
  %1 = insertelement <8 x i8> undef, i8 0, i32 0
  %2 = insertelement <8 x i8> %1, i8 -1, i32 1
  %3 = insertelement <8 x i8> %2, i8 2, i32 2
  %4 = insertelement <8 x i8> %3, i8 -3, i32 3
  %5 = insertelement <8 x i8> %4, i8 4, i32 4
  %6 = insertelement <8 x i8> %5, i8 -5, i32 5
  %7 = insertelement <8 x i8> %6, i8 6, i32 6
  %8 = insertelement <8 x i8> %7, i8 -7, i32 7
  %9 = zext <8 x i8> %8 to <8 x i16>
  ret <8 x i16> %9
}

define <8 x i32> @test_zext_8i8_8i32() {
; X32-LABEL: test_zext_8i8_8i32:
; X32:       # BB#0:
; X32-NEXT:    vmovaps {{.*#+}} ymm0 = [0,255,2,253,4,251,6,249]
; X32-NEXT:    retl
;
; X64-LABEL: test_zext_8i8_8i32:
; X64:       # BB#0:
; X64-NEXT:    vmovaps {{.*#+}} ymm0 = [0,255,2,253,4,251,6,249]
; X64-NEXT:    retq
  %1 = insertelement <8 x i8> undef, i8 0, i32 0
  %2 = insertelement <8 x i8> %1, i8 -1, i32 1
  %3 = insertelement <8 x i8> %2, i8 2, i32 2
  %4 = insertelement <8 x i8> %3, i8 -3, i32 3
  %5 = insertelement <8 x i8> %4, i8 4, i32 4
  %6 = insertelement <8 x i8> %5, i8 -5, i32 5
  %7 = insertelement <8 x i8> %6, i8 6, i32 6
  %8 = insertelement <8 x i8> %7, i8 -7, i32 7
  %9 = zext <8 x i8> %8 to <8 x i32>
  ret <8 x i32> %9
}

define <8 x i16> @test_zext_8i8_8i16_undef() {
; X32-LABEL: test_zext_8i8_8i16_undef:
; X32:       # BB#0:
; X32-NEXT:    vmovaps {{.*#+}} xmm0 = <u,255,u,253,u,251,u,249>
; X32-NEXT:    retl
;
; X64-LABEL: test_zext_8i8_8i16_undef:
; X64:       # BB#0:
; X64-NEXT:    vmovaps {{.*#+}} xmm0 = <u,255,u,253,u,251,u,249>
; X64-NEXT:    retq
  %1 = insertelement <8 x i8> undef, i8 undef, i32 0
  %2 = insertelement <8 x i8> %1, i8 -1, i32 1
  %3 = insertelement <8 x i8> %2, i8 undef, i32 2
  %4 = insertelement <8 x i8> %3, i8 -3, i32 3
  %5 = insertelement <8 x i8> %4, i8 undef, i32 4
  %6 = insertelement <8 x i8> %5, i8 -5, i32 5
  %7 = insertelement <8 x i8> %6, i8 undef, i32 6
  %8 = insertelement <8 x i8> %7, i8 -7, i32 7
  %9 = zext <8 x i8> %8 to <8 x i16>
  ret <8 x i16> %9
}

define <8 x i32> @test_zext_8i8_8i32_undef() {
; X32-LABEL: test_zext_8i8_8i32_undef:
; X32:       # BB#0:
; X32-NEXT:    vmovaps {{.*#+}} ymm0 = <0,u,2,253,4,u,6,u>
; X32-NEXT:    retl
;
; X64-LABEL: test_zext_8i8_8i32_undef:
; X64:       # BB#0:
; X64-NEXT:    vmovaps {{.*#+}} ymm0 = <0,u,2,253,4,u,6,u>
; X64-NEXT:    retq
  %1 = insertelement <8 x i8> undef, i8 0, i32 0
  %2 = insertelement <8 x i8> %1, i8 undef, i32 1
  %3 = insertelement <8 x i8> %2, i8 2, i32 2
  %4 = insertelement <8 x i8> %3, i8 -3, i32 3
  %5 = insertelement <8 x i8> %4, i8 4, i32 4
  %6 = insertelement <8 x i8> %5, i8 undef, i32 5
  %7 = insertelement <8 x i8> %6, i8 6, i32 6
  %8 = insertelement <8 x i8> %7, i8 undef, i32 7
  %9 = zext <8 x i8> %8 to <8 x i32>
  ret <8 x i32> %9
}
