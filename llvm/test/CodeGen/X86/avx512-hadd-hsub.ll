; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
;RUN: llc < %s -mtriple=x86_64-unknown-unknown -mcpu=knl | FileCheck %s --check-prefix=KNL
;RUN: llc < %s -mtriple=x86_64-unknown-unknown -mcpu=skx | FileCheck %s --check-prefix=SKX

define i32 @hadd_16(<16 x i32> %x225) {
; KNL-LABEL: hadd_16:
; KNL:       # %bb.0:
; KNL-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[2,3,0,1]
; KNL-NEXT:    vpaddd %zmm1, %zmm0, %zmm0
; KNL-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[1,1,2,3]
; KNL-NEXT:    vpaddd %zmm1, %zmm0, %zmm0
; KNL-NEXT:    vmovd %xmm0, %eax
; KNL-NEXT:    retq
;
; SKX-LABEL: hadd_16:
; SKX:       # %bb.0:
; SKX-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[2,3,0,1]
; SKX-NEXT:    vpaddd %zmm1, %zmm0, %zmm0
; SKX-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[1,1,2,3]
; SKX-NEXT:    vpaddd %zmm1, %zmm0, %zmm0
; SKX-NEXT:    vmovd %xmm0, %eax
; SKX-NEXT:    vzeroupper
; SKX-NEXT:    retq
  %x226 = shufflevector <16 x i32> %x225, <16 x i32> undef, <16 x i32> <i32 2, i32 3, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %x227 = add <16 x i32> %x225, %x226
  %x228 = shufflevector <16 x i32> %x227, <16 x i32> undef, <16 x i32> <i32 1, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %x229 = add <16 x i32> %x227, %x228
  %x230 = extractelement <16 x i32> %x229, i32 0
  ret i32 %x230
}

define i32 @hsub_16(<16 x i32> %x225) {
; KNL-LABEL: hsub_16:
; KNL:       # %bb.0:
; KNL-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[2,3,0,1]
; KNL-NEXT:    vpaddd %zmm1, %zmm0, %zmm0
; KNL-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[1,1,2,3]
; KNL-NEXT:    vpsubd %zmm1, %zmm0, %zmm0
; KNL-NEXT:    vmovd %xmm0, %eax
; KNL-NEXT:    retq
;
; SKX-LABEL: hsub_16:
; SKX:       # %bb.0:
; SKX-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[2,3,0,1]
; SKX-NEXT:    vpaddd %zmm1, %zmm0, %zmm0
; SKX-NEXT:    vpshufd {{.*#+}} xmm1 = xmm0[1,1,2,3]
; SKX-NEXT:    vpsubd %zmm1, %zmm0, %zmm0
; SKX-NEXT:    vmovd %xmm0, %eax
; SKX-NEXT:    vzeroupper
; SKX-NEXT:    retq
  %x226 = shufflevector <16 x i32> %x225, <16 x i32> undef, <16 x i32> <i32 2, i32 3, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %x227 = add <16 x i32> %x225, %x226
  %x228 = shufflevector <16 x i32> %x227, <16 x i32> undef, <16 x i32> <i32 1, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %x229 = sub <16 x i32> %x227, %x228
  %x230 = extractelement <16 x i32> %x229, i32 0
  ret i32 %x230
}

define float @fhadd_16(<16 x float> %x225) {
; KNL-LABEL: fhadd_16:
; KNL:       # %bb.0:
; KNL-NEXT:    vpermilpd {{.*#+}} xmm1 = xmm0[1,0]
; KNL-NEXT:    vaddps %zmm1, %zmm0, %zmm0
; KNL-NEXT:    vmovshdup {{.*#+}} xmm1 = xmm0[1,1,3,3]
; KNL-NEXT:    vaddps %zmm1, %zmm0, %zmm0
; KNL-NEXT:    # kill: def $xmm0 killed $xmm0 killed $zmm0
; KNL-NEXT:    retq
;
; SKX-LABEL: fhadd_16:
; SKX:       # %bb.0:
; SKX-NEXT:    vpermilpd {{.*#+}} xmm1 = xmm0[1,0]
; SKX-NEXT:    vaddps %zmm1, %zmm0, %zmm0
; SKX-NEXT:    vmovshdup {{.*#+}} xmm1 = xmm0[1,1,3,3]
; SKX-NEXT:    vaddps %zmm1, %zmm0, %zmm0
; SKX-NEXT:    # kill: def $xmm0 killed $xmm0 killed $zmm0
; SKX-NEXT:    vzeroupper
; SKX-NEXT:    retq
  %x226 = shufflevector <16 x float> %x225, <16 x float> undef, <16 x i32> <i32 2, i32 3, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %x227 = fadd <16 x float> %x225, %x226
  %x228 = shufflevector <16 x float> %x227, <16 x float> undef, <16 x i32> <i32 1, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %x229 = fadd <16 x float> %x227, %x228
  %x230 = extractelement <16 x float> %x229, i32 0
  ret float %x230
}

define float @fhsub_16(<16 x float> %x225) {
; KNL-LABEL: fhsub_16:
; KNL:       # %bb.0:
; KNL-NEXT:    vpermilpd {{.*#+}} xmm1 = xmm0[1,0]
; KNL-NEXT:    vaddps %zmm1, %zmm0, %zmm0
; KNL-NEXT:    vmovshdup {{.*#+}} xmm1 = xmm0[1,1,3,3]
; KNL-NEXT:    vsubps %zmm1, %zmm0, %zmm0
; KNL-NEXT:    # kill: def $xmm0 killed $xmm0 killed $zmm0
; KNL-NEXT:    retq
;
; SKX-LABEL: fhsub_16:
; SKX:       # %bb.0:
; SKX-NEXT:    vpermilpd {{.*#+}} xmm1 = xmm0[1,0]
; SKX-NEXT:    vaddps %zmm1, %zmm0, %zmm0
; SKX-NEXT:    vmovshdup {{.*#+}} xmm1 = xmm0[1,1,3,3]
; SKX-NEXT:    vsubps %zmm1, %zmm0, %zmm0
; SKX-NEXT:    # kill: def $xmm0 killed $xmm0 killed $zmm0
; SKX-NEXT:    vzeroupper
; SKX-NEXT:    retq
  %x226 = shufflevector <16 x float> %x225, <16 x float> undef, <16 x i32> <i32 2, i32 3, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %x227 = fadd <16 x float> %x225, %x226
  %x228 = shufflevector <16 x float> %x227, <16 x float> undef, <16 x i32> <i32 1, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %x229 = fsub <16 x float> %x227, %x228
  %x230 = extractelement <16 x float> %x229, i32 0
  ret float %x230
}

define <16 x i32> @hadd_16_3(<16 x i32> %x225, <16 x i32> %x227) {
; KNL-LABEL: hadd_16_3:
; KNL:       # %bb.0:
; KNL-NEXT:    vshufps {{.*#+}} ymm2 = ymm0[0,2],ymm1[0,2],ymm0[4,6],ymm1[4,6]
; KNL-NEXT:    vshufps {{.*#+}} ymm0 = ymm0[1,3],ymm1[1,3],ymm0[5,7],ymm1[5,7]
; KNL-NEXT:    vpaddd %zmm0, %zmm2, %zmm0
; KNL-NEXT:    retq
;
; SKX-LABEL: hadd_16_3:
; SKX:       # %bb.0:
; SKX-NEXT:    vshufps {{.*#+}} ymm2 = ymm0[0,2],ymm1[0,2],ymm0[4,6],ymm1[4,6]
; SKX-NEXT:    vshufps {{.*#+}} ymm0 = ymm0[1,3],ymm1[1,3],ymm0[5,7],ymm1[5,7]
; SKX-NEXT:    vpaddd %zmm0, %zmm2, %zmm0
; SKX-NEXT:    retq
  %x226 = shufflevector <16 x i32> %x225, <16 x i32> %x227, <16 x i32> <i32 0, i32 2, i32 16, i32 18
, i32 4, i32 6, i32 20, i32 22, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %x228 = shufflevector <16 x i32> %x225, <16 x i32> %x227, <16 x i32> <i32 1, i32 3, i32 17, i32 19
, i32 5 , i32 7, i32 21,   i32 23, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef,
 i32 undef, i32 undef>
  %x229 = add <16 x i32> %x226, %x228
  ret <16 x i32> %x229
}

define <16 x float> @fhadd_16_3(<16 x float> %x225, <16 x float> %x227) {
; KNL-LABEL: fhadd_16_3:
; KNL:       # %bb.0:
; KNL-NEXT:    vshufps {{.*#+}} ymm2 = ymm0[0,2],ymm1[0,2],ymm0[4,6],ymm1[4,6]
; KNL-NEXT:    vshufps {{.*#+}} ymm0 = ymm0[1,3],ymm1[1,3],ymm0[5,7],ymm1[5,7]
; KNL-NEXT:    vaddps %zmm0, %zmm2, %zmm0
; KNL-NEXT:    retq
;
; SKX-LABEL: fhadd_16_3:
; SKX:       # %bb.0:
; SKX-NEXT:    vshufps {{.*#+}} ymm2 = ymm0[0,2],ymm1[0,2],ymm0[4,6],ymm1[4,6]
; SKX-NEXT:    vshufps {{.*#+}} ymm0 = ymm0[1,3],ymm1[1,3],ymm0[5,7],ymm1[5,7]
; SKX-NEXT:    vaddps %zmm0, %zmm2, %zmm0
; SKX-NEXT:    retq
  %x226 = shufflevector <16 x float> %x225, <16 x float> %x227, <16 x i32> <i32 0, i32 2, i32 16, i32 18
, i32 4, i32 6, i32 20, i32 22, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %x228 = shufflevector <16 x float> %x225, <16 x float> %x227, <16 x i32> <i32 1, i32 3, i32 17, i32 19
, i32 5 , i32 7, i32 21,   i32 23, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  %x229 = fadd <16 x float> %x226, %x228
  ret <16 x float> %x229
}

define <8 x double> @fhadd_16_4(<8 x double> %x225, <8 x double> %x227) {
; KNL-LABEL: fhadd_16_4:
; KNL:       # %bb.0:
; KNL-NEXT:    vunpcklpd {{.*#+}} ymm2 = ymm0[0],ymm1[0],ymm0[2],ymm1[2]
; KNL-NEXT:    vunpckhpd {{.*#+}} ymm0 = ymm0[1],ymm1[1],ymm0[3],ymm1[3]
; KNL-NEXT:    vaddpd %zmm0, %zmm2, %zmm0
; KNL-NEXT:    retq
;
; SKX-LABEL: fhadd_16_4:
; SKX:       # %bb.0:
; SKX-NEXT:    vunpcklpd {{.*#+}} ymm2 = ymm0[0],ymm1[0],ymm0[2],ymm1[2]
; SKX-NEXT:    vunpckhpd {{.*#+}} ymm0 = ymm0[1],ymm1[1],ymm0[3],ymm1[3]
; SKX-NEXT:    vaddpd %zmm0, %zmm2, %zmm0
; SKX-NEXT:    retq
  %x226 = shufflevector <8 x double> %x225, <8 x double> %x227, <8 x i32> <i32 0, i32 8, i32 2, i32 10, i32 undef, i32 undef, i32 undef, i32 undef>
  %x228 = shufflevector <8 x double> %x225, <8 x double> %x227, <8 x i32> <i32 1, i32 9, i32 3, i32 11, i32 undef ,i32 undef, i32 undef, i32 undef>
  %x229 = fadd <8 x double> %x226, %x228
  ret <8 x double> %x229
}

define <4 x double> @fadd_noundef_low(<8 x double> %x225, <8 x double> %x227) {
; KNL-LABEL: fadd_noundef_low:
; KNL:       # %bb.0:
; KNL-NEXT:    vunpcklpd {{.*#+}} zmm2 = zmm0[0],zmm1[0],zmm0[2],zmm1[2],zmm0[4],zmm1[4],zmm0[6],zmm1[6]
; KNL-NEXT:    vunpckhpd {{.*#+}} zmm0 = zmm0[1],zmm1[1],zmm0[3],zmm1[3],zmm0[5],zmm1[5],zmm0[7],zmm1[7]
; KNL-NEXT:    vaddpd %zmm0, %zmm2, %zmm0
; KNL-NEXT:    # kill: def $ymm0 killed $ymm0 killed $zmm0
; KNL-NEXT:    retq
;
; SKX-LABEL: fadd_noundef_low:
; SKX:       # %bb.0:
; SKX-NEXT:    vunpcklpd {{.*#+}} zmm2 = zmm0[0],zmm1[0],zmm0[2],zmm1[2],zmm0[4],zmm1[4],zmm0[6],zmm1[6]
; SKX-NEXT:    vunpckhpd {{.*#+}} zmm0 = zmm0[1],zmm1[1],zmm0[3],zmm1[3],zmm0[5],zmm1[5],zmm0[7],zmm1[7]
; SKX-NEXT:    vaddpd %zmm0, %zmm2, %zmm0
; SKX-NEXT:    # kill: def $ymm0 killed $ymm0 killed $zmm0
; SKX-NEXT:    retq
  %x226 = shufflevector <8 x double> %x225, <8 x double> %x227, <8 x i32> <i32 0, i32 8, i32 2, i32 10, i32 4, i32 12, i32 6, i32 14>
  %x228 = shufflevector <8 x double> %x225, <8 x double> %x227, <8 x i32> <i32 1, i32 9, i32 3, i32 11, i32 5 ,i32 13, i32 7, i32 15>
  %x229 = fadd <8 x double> %x226, %x228
  %x230 = shufflevector <8 x double> %x229, <8 x double> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  ret <4 x double> %x230
}

define <4 x double> @fadd_noundef_high(<8 x double> %x225, <8 x double> %x227) {
; KNL-LABEL: fadd_noundef_high:
; KNL:       # %bb.0:
; KNL-NEXT:    vunpcklpd {{.*#+}} zmm2 = zmm0[0],zmm1[0],zmm0[2],zmm1[2],zmm0[4],zmm1[4],zmm0[6],zmm1[6]
; KNL-NEXT:    vunpckhpd {{.*#+}} zmm0 = zmm0[1],zmm1[1],zmm0[3],zmm1[3],zmm0[5],zmm1[5],zmm0[7],zmm1[7]
; KNL-NEXT:    vaddpd %zmm0, %zmm2, %zmm0
; KNL-NEXT:    vextractf64x4 $1, %zmm0, %ymm0
; KNL-NEXT:    retq
;
; SKX-LABEL: fadd_noundef_high:
; SKX:       # %bb.0:
; SKX-NEXT:    vunpcklpd {{.*#+}} zmm2 = zmm0[0],zmm1[0],zmm0[2],zmm1[2],zmm0[4],zmm1[4],zmm0[6],zmm1[6]
; SKX-NEXT:    vunpckhpd {{.*#+}} zmm0 = zmm0[1],zmm1[1],zmm0[3],zmm1[3],zmm0[5],zmm1[5],zmm0[7],zmm1[7]
; SKX-NEXT:    vaddpd %zmm0, %zmm2, %zmm0
; SKX-NEXT:    vextractf64x4 $1, %zmm0, %ymm0
; SKX-NEXT:    retq
  %x226 = shufflevector <8 x double> %x225, <8 x double> %x227, <8 x i32> <i32 0, i32 8, i32 2, i32 10, i32 4, i32 12, i32 6, i32 14>
  %x228 = shufflevector <8 x double> %x225, <8 x double> %x227, <8 x i32> <i32 1, i32 9, i32 3, i32 11, i32 5 ,i32 13, i32 7, i32 15>
  %x229 = fadd <8 x double> %x226, %x228
  %x230 = shufflevector <8 x double> %x229, <8 x double> undef, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  ret <4 x double> %x230
}


define <8 x i32> @hadd_16_3_sv(<16 x i32> %x225, <16 x i32> %x227) {
; KNL-LABEL: hadd_16_3_sv:
; KNL:       # %bb.0:
; KNL-NEXT:    vshufps {{.*#+}} zmm2 = zmm0[0,2],zmm1[0,2],zmm0[4,6],zmm1[4,6],zmm0[8,10],zmm1[8,10],zmm0[12,14],zmm1[12,14]
; KNL-NEXT:    vshufps {{.*#+}} zmm0 = zmm0[1,3],zmm1[1,3],zmm0[5,7],zmm1[5,7],zmm0[9,11],zmm1[9,11],zmm0[13,15],zmm1[13,15]
; KNL-NEXT:    vpaddd %zmm0, %zmm2, %zmm0
; KNL-NEXT:    # kill: def $ymm0 killed $ymm0 killed $zmm0
; KNL-NEXT:    retq
;
; SKX-LABEL: hadd_16_3_sv:
; SKX:       # %bb.0:
; SKX-NEXT:    vshufps {{.*#+}} zmm2 = zmm0[0,2],zmm1[0,2],zmm0[4,6],zmm1[4,6],zmm0[8,10],zmm1[8,10],zmm0[12,14],zmm1[12,14]
; SKX-NEXT:    vshufps {{.*#+}} zmm0 = zmm0[1,3],zmm1[1,3],zmm0[5,7],zmm1[5,7],zmm0[9,11],zmm1[9,11],zmm0[13,15],zmm1[13,15]
; SKX-NEXT:    vpaddd %zmm0, %zmm2, %zmm0
; SKX-NEXT:    # kill: def $ymm0 killed $ymm0 killed $zmm0
; SKX-NEXT:    retq
  %x226 = shufflevector <16 x i32> %x225, <16 x i32> %x227, <16 x i32> <i32 0, i32 2, i32 16, i32 18
, i32 4, i32 6, i32 20, i32 22, i32 8, i32 10, i32 24, i32 26, i32 12, i32 14, i32 28, i32 30>
  %x228 = shufflevector <16 x i32> %x225, <16 x i32> %x227, <16 x i32> <i32 1, i32 3, i32 17, i32 19
, i32 5 , i32 7, i32 21,   i32 23, i32 9, i32 11, i32 25, i32 27, i32 13, i32 15,
 i32 29, i32 31>
  %x229 = add <16 x i32> %x226, %x228
  %x230 = shufflevector <16 x i32> %x229, <16 x i32> undef, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4 ,i32 5, i32 6, i32 7>
  ret <8 x i32> %x230
}


define double @fadd_noundef_eel(<8 x double> %x225, <8 x double> %x227) {
; KNL-LABEL: fadd_noundef_eel:
; KNL:       # %bb.0:
; KNL-NEXT:    vunpcklpd {{.*#+}} zmm2 = zmm0[0],zmm1[0],zmm0[2],zmm1[2],zmm0[4],zmm1[4],zmm0[6],zmm1[6]
; KNL-NEXT:    vunpckhpd {{.*#+}} zmm0 = zmm0[1],zmm1[1],zmm0[3],zmm1[3],zmm0[5],zmm1[5],zmm0[7],zmm1[7]
; KNL-NEXT:    vaddpd %zmm0, %zmm2, %zmm0
; KNL-NEXT:    # kill: def $xmm0 killed $xmm0 killed $zmm0
; KNL-NEXT:    retq
;
; SKX-LABEL: fadd_noundef_eel:
; SKX:       # %bb.0:
; SKX-NEXT:    vunpcklpd {{.*#+}} zmm2 = zmm0[0],zmm1[0],zmm0[2],zmm1[2],zmm0[4],zmm1[4],zmm0[6],zmm1[6]
; SKX-NEXT:    vunpckhpd {{.*#+}} zmm0 = zmm0[1],zmm1[1],zmm0[3],zmm1[3],zmm0[5],zmm1[5],zmm0[7],zmm1[7]
; SKX-NEXT:    vaddpd %zmm0, %zmm2, %zmm0
; SKX-NEXT:    # kill: def $xmm0 killed $xmm0 killed $zmm0
; SKX-NEXT:    vzeroupper
; SKX-NEXT:    retq
  %x226 = shufflevector <8 x double> %x225, <8 x double> %x227, <8 x i32> <i32 0, i32 8, i32 2, i32 10, i32 4, i32 12, i32 6, i32 14>
  %x228 = shufflevector <8 x double> %x225, <8 x double> %x227, <8 x i32> <i32 1, i32 9, i32 3, i32 11, i32 5 ,i32 13, i32 7, i32 15>
  %x229 = fadd <8 x double> %x226, %x228
  %x230 = extractelement <8 x double> %x229, i32 0
  ret double %x230
}



define double @fsub_noundef_ee (<8 x double> %x225, <8 x double> %x227) {
; KNL-LABEL: fsub_noundef_ee:
; KNL:       # %bb.0:
; KNL-NEXT:    vunpcklpd {{.*#+}} zmm2 = zmm0[0],zmm1[0],zmm0[2],zmm1[2],zmm0[4],zmm1[4],zmm0[6],zmm1[6]
; KNL-NEXT:    vunpckhpd {{.*#+}} zmm0 = zmm0[1],zmm1[1],zmm0[3],zmm1[3],zmm0[5],zmm1[5],zmm0[7],zmm1[7]
; KNL-NEXT:    vsubpd %zmm0, %zmm2, %zmm0
; KNL-NEXT:    vextractf32x4 $2, %zmm0, %xmm0
; KNL-NEXT:    vpermilpd {{.*#+}} xmm0 = xmm0[1,0]
; KNL-NEXT:    retq
;
; SKX-LABEL: fsub_noundef_ee:
; SKX:       # %bb.0:
; SKX-NEXT:    vunpcklpd {{.*#+}} zmm2 = zmm0[0],zmm1[0],zmm0[2],zmm1[2],zmm0[4],zmm1[4],zmm0[6],zmm1[6]
; SKX-NEXT:    vunpckhpd {{.*#+}} zmm0 = zmm0[1],zmm1[1],zmm0[3],zmm1[3],zmm0[5],zmm1[5],zmm0[7],zmm1[7]
; SKX-NEXT:    vsubpd %zmm0, %zmm2, %zmm0
; SKX-NEXT:    vextractf32x4 $2, %zmm0, %xmm0
; SKX-NEXT:    vpermilpd {{.*#+}} xmm0 = xmm0[1,0]
; SKX-NEXT:    vzeroupper
; SKX-NEXT:    retq
  %x226 = shufflevector <8 x double> %x225, <8 x double> %x227, <8 x i32> <i32 0, i32 8, i32 2, i32 10, i32 4, i32 12, i32 6, i32 14>
  %x228 = shufflevector <8 x double> %x225, <8 x double> %x227, <8 x i32> <i32 1, i32 9, i32 3, i32 11, i32 5 ,i32 13, i32 7, i32 15>
  %x229 = fsub <8 x double> %x226, %x228
  %x230 = extractelement <8 x double> %x229, i32 5
  ret double %x230
}

