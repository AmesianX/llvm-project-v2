; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown-unknown -mattr=+avx2 | FileCheck %s --check-prefix=X32
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx2 | FileCheck %s --check-prefix=X64

define <4 x i64> @vpandn(<4 x i64> %a, <4 x i64> %b) nounwind uwtable readnone ssp {
; X32-LABEL: vpandn:
; X32:       # %bb.0: # %entry
; X32-NEXT:    vpcmpeqd %ymm1, %ymm1, %ymm1
; X32-NEXT:    vpsubq %ymm1, %ymm0, %ymm1
; X32-NEXT:    vpandn %ymm0, %ymm1, %ymm0
; X32-NEXT:    retl
;
; X64-LABEL: vpandn:
; X64:       # %bb.0: # %entry
; X64-NEXT:    vpcmpeqd %ymm1, %ymm1, %ymm1
; X64-NEXT:    vpsubq %ymm1, %ymm0, %ymm1
; X64-NEXT:    vpandn %ymm0, %ymm1, %ymm0
; X64-NEXT:    retq
entry:
  ; Force the execution domain with an add.
  %a2 = add <4 x i64> %a, <i64 1, i64 1, i64 1, i64 1>
  %y = xor <4 x i64> %a2, <i64 -1, i64 -1, i64 -1, i64 -1>
  %x = and <4 x i64> %a, %y
  ret <4 x i64> %x
}

define <4 x i64> @vpand(<4 x i64> %a, <4 x i64> %b) nounwind uwtable readnone ssp {
; X32-LABEL: vpand:
; X32:       # %bb.0: # %entry
; X32-NEXT:    vpcmpeqd %ymm2, %ymm2, %ymm2
; X32-NEXT:    vpsubq %ymm2, %ymm0, %ymm0
; X32-NEXT:    vpand %ymm1, %ymm0, %ymm0
; X32-NEXT:    retl
;
; X64-LABEL: vpand:
; X64:       # %bb.0: # %entry
; X64-NEXT:    vpcmpeqd %ymm2, %ymm2, %ymm2
; X64-NEXT:    vpsubq %ymm2, %ymm0, %ymm0
; X64-NEXT:    vpand %ymm1, %ymm0, %ymm0
; X64-NEXT:    retq
entry:
  ; Force the execution domain with an add.
  %a2 = add <4 x i64> %a, <i64 1, i64 1, i64 1, i64 1>
  %x = and <4 x i64> %a2, %b
  ret <4 x i64> %x
}

define <4 x i64> @vpor(<4 x i64> %a, <4 x i64> %b) nounwind uwtable readnone ssp {
; X32-LABEL: vpor:
; X32:       # %bb.0: # %entry
; X32-NEXT:    vpcmpeqd %ymm2, %ymm2, %ymm2
; X32-NEXT:    vpsubq %ymm2, %ymm0, %ymm0
; X32-NEXT:    vpor %ymm1, %ymm0, %ymm0
; X32-NEXT:    retl
;
; X64-LABEL: vpor:
; X64:       # %bb.0: # %entry
; X64-NEXT:    vpcmpeqd %ymm2, %ymm2, %ymm2
; X64-NEXT:    vpsubq %ymm2, %ymm0, %ymm0
; X64-NEXT:    vpor %ymm1, %ymm0, %ymm0
; X64-NEXT:    retq
entry:
  ; Force the execution domain with an add.
  %a2 = add <4 x i64> %a, <i64 1, i64 1, i64 1, i64 1>
  %x = or <4 x i64> %a2, %b
  ret <4 x i64> %x
}

define <4 x i64> @vpxor(<4 x i64> %a, <4 x i64> %b) nounwind uwtable readnone ssp {
; X32-LABEL: vpxor:
; X32:       # %bb.0: # %entry
; X32-NEXT:    vpcmpeqd %ymm2, %ymm2, %ymm2
; X32-NEXT:    vpsubq %ymm2, %ymm0, %ymm0
; X32-NEXT:    vpxor %ymm1, %ymm0, %ymm0
; X32-NEXT:    retl
;
; X64-LABEL: vpxor:
; X64:       # %bb.0: # %entry
; X64-NEXT:    vpcmpeqd %ymm2, %ymm2, %ymm2
; X64-NEXT:    vpsubq %ymm2, %ymm0, %ymm0
; X64-NEXT:    vpxor %ymm1, %ymm0, %ymm0
; X64-NEXT:    retq
entry:
  ; Force the execution domain with an add.
  %a2 = add <4 x i64> %a, <i64 1, i64 1, i64 1, i64 1>
  %x = xor <4 x i64> %a2, %b
  ret <4 x i64> %x
}

define <32 x i8> @vpblendvb(<32 x i1> %cond, <32 x i8> %x, <32 x i8> %y) {
; X32-LABEL: vpblendvb:
; X32:       # %bb.0:
; X32-NEXT:    vpsllw $7, %ymm0, %ymm0
; X32-NEXT:    vpblendvb %ymm0, %ymm1, %ymm2, %ymm0
; X32-NEXT:    retl
;
; X64-LABEL: vpblendvb:
; X64:       # %bb.0:
; X64-NEXT:    vpsllw $7, %ymm0, %ymm0
; X64-NEXT:    vpblendvb %ymm0, %ymm1, %ymm2, %ymm0
; X64-NEXT:    retq
  %min = select <32 x i1> %cond, <32 x i8> %x, <32 x i8> %y
  ret <32 x i8> %min
}

define <8 x i32> @allOnes() nounwind {
; X32-LABEL: allOnes:
; X32:       # %bb.0:
; X32-NEXT:    vpcmpeqd %ymm0, %ymm0, %ymm0
; X32-NEXT:    retl
;
; X64-LABEL: allOnes:
; X64:       # %bb.0:
; X64-NEXT:    vpcmpeqd %ymm0, %ymm0, %ymm0
; X64-NEXT:    retq
        ret <8 x i32> <i32 -1, i32 -1, i32 -1, i32 -1, i32 -1, i32 -1, i32 -1, i32 -1>
}

define <16 x i16> @allOnes2() nounwind {
; X32-LABEL: allOnes2:
; X32:       # %bb.0:
; X32-NEXT:    vpcmpeqd %ymm0, %ymm0, %ymm0
; X32-NEXT:    retl
;
; X64-LABEL: allOnes2:
; X64:       # %bb.0:
; X64-NEXT:    vpcmpeqd %ymm0, %ymm0, %ymm0
; X64-NEXT:    retq
        ret <16 x i16> <i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1>
}
