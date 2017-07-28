; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mcpu=knl | FileCheck --check-prefixes=ALL,KNL %s
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mcpu=skx | FileCheck --check-prefixes=ALL,SKX %s

target triple = "x86_64-unknown-unknown"

define <32 x i16> @shuffle_v32i16(<32 x i16> %a)  {
; KNL-LABEL: shuffle_v32i16:
; KNL:       ## BB#0:
; KNL-NEXT:    vpbroadcastw %xmm0, %ymm0
; KNL-NEXT:    vmovdqa %ymm0, %ymm1
; KNL-NEXT:    retq
;
; SKX-LABEL: shuffle_v32i16:
; SKX:       ## BB#0:
; SKX-NEXT:    vpbroadcastw %xmm0, %zmm0
; SKX-NEXT:    retq
  %c = shufflevector <32 x i16> %a, <32 x i16> undef, <32 x i32> zeroinitializer
  ret <32 x i16> %c
}

define <32 x i16> @shuffle_v32i16_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08(<32 x i16> %a)  {
; KNL-LABEL: shuffle_v32i16_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08:
; KNL:       ## BB#0:
; KNL-NEXT:    vextracti128 $1, %ymm0, %xmm0
; KNL-NEXT:    vpbroadcastw %xmm0, %ymm0
; KNL-NEXT:    vmovdqa %ymm0, %ymm1
; KNL-NEXT:    retq
;
; SKX-LABEL: shuffle_v32i16_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08_08:
; SKX:       ## BB#0:
; SKX-NEXT:    vextracti32x4 $1, %zmm0, %xmm0
; SKX-NEXT:    vpbroadcastw %xmm0, %zmm0
; SKX-NEXT:    retq
  %c = shufflevector <32 x i16> %a, <32 x i16> undef, <32 x i32> <i32 8, i32 8, i32 8, i32 8, i32 8, i32 8, i32 8, i32 8, i32 8, i32 8, i32 8, i32 8, i32 8, i32 8, i32 8, i32 8, i32 8, i32 8, i32 8, i32 8, i32 8, i32 8, i32 8, i32 8, i32 8, i32 8, i32 8, i32 8, i32 8, i32 8, i32 8, i32 8>
  ret <32 x i16> %c
}

define <32 x i16> @shuffle_v32i16_02_05_u_u_07_u_0a_01_00_05_u_04_07_u_0a_01_02_05_u_u_07_u_0a_01_00_05_u_04_07_u_0a_1f(<32 x i16> %a)  {
; KNL-LABEL: shuffle_v32i16_02_05_u_u_07_u_0a_01_00_05_u_04_07_u_0a_01_02_05_u_u_07_u_0a_01_00_05_u_04_07_u_0a_1f:
; KNL:       ## BB#0:
; KNL-NEXT:    vperm2i128 {{.*#+}} ymm2 = ymm0[2,3,0,1]
; KNL-NEXT:    vpshufb {{.*#+}} ymm3 = ymm2[0,1,10,11,8,9,8,9,14,15,2,3,4,5,2,3,16,17,26,27,24,25,24,25,30,31,18,19,20,21,18,19]
; KNL-NEXT:    vpshufb {{.*#+}} ymm4 = ymm0[4,5,10,11,4,5,6,7,14,15,2,3,4,5,2,3,20,21,26,27,20,21,22,23,30,31,18,19,20,21,18,19]
; KNL-NEXT:    vmovdqa {{.*#+}} ymm0 = <0,0,0,0,u,u,u,u,0,0,u,u,255,255,0,0,255,255,255,255,u,u,255,255,255,255,u,u,0,0,255,255>
; KNL-NEXT:    vpblendvb %ymm0, %ymm3, %ymm4, %ymm0
; KNL-NEXT:    vpshufb {{.*#+}} ymm2 = ymm2[0,1,10,11,8,9,8,9,14,15,6,7,4,5,14,15,16,17,26,27,24,25,24,25,30,31,22,23,20,21,30,31]
; KNL-NEXT:    vmovdqa {{.*#+}} ymm3 = <255,255,255,255,u,u,u,u,255,255,u,u,0,0,255,255,0,0,0,0,u,u,0,0,0,0,u,u,255,255,u,u>
; KNL-NEXT:    vpblendvb %ymm3, %ymm4, %ymm2, %ymm2
; KNL-NEXT:    vmovdqa {{.*#+}} ymm3 = <255,255,255,255,u,u,u,u,255,255,u,u,255,255,255,255,255,255,255,255,u,u,255,255,255,255,u,u,255,255,0,0>
; KNL-NEXT:    vpblendvb %ymm3, %ymm2, %ymm1, %ymm1
; KNL-NEXT:    retq
;
; SKX-LABEL: shuffle_v32i16_02_05_u_u_07_u_0a_01_00_05_u_04_07_u_0a_01_02_05_u_u_07_u_0a_01_00_05_u_04_07_u_0a_1f:
; SKX:       ## BB#0:
; SKX-NEXT:    vmovdqu16 {{.*#+}} zmm1 = <2,5,u,u,7,u,10,1,0,5,u,4,7,u,10,1,2,5,u,u,7,u,10,1,0,5,u,4,7,u,10,31>
; SKX-NEXT:    vpermw %zmm0, %zmm1, %zmm0
; SKX-NEXT:    retq
  %c = shufflevector <32 x i16> %a, <32 x i16> undef, <32 x i32> <i32 2, i32 5, i32 undef, i32 undef, i32 7, i32 undef, i32 10, i32 1,  i32 0, i32 5, i32 undef, i32 4, i32 7, i32 undef, i32 10, i32 1, i32 2, i32 5, i32 undef, i32 undef, i32 7, i32 undef, i32 10, i32 1,  i32 0, i32 5, i32 undef, i32 4, i32 7, i32 undef, i32 10, i32 31>
  ret <32 x i16> %c
}

define <32 x i16> @shuffle_v32i16_0f_1f_0e_16_0d_1d_04_1e_0b_1b_0a_1a_09_19_08_18_0f_1f_0e_16_0d_1d_04_1e_0b_1b_0a_1a_09_19_08_38(<32 x i16> %a, <32 x i16> %b)  {
; KNL-LABEL: shuffle_v32i16_0f_1f_0e_16_0d_1d_04_1e_0b_1b_0a_1a_09_19_08_18_0f_1f_0e_16_0d_1d_04_1e_0b_1b_0a_1a_09_19_08_38:
; KNL:       ## BB#0:
; KNL-NEXT:    vextracti128 $1, %ymm1, %xmm2
; KNL-NEXT:    vpunpckhwd {{.*#+}} xmm1 = xmm2[4],xmm1[4],xmm2[5],xmm1[5],xmm2[6],xmm1[6],xmm2[7],xmm1[7]
; KNL-NEXT:    vpshufb {{.*#+}} xmm4 = xmm1[8,9,12,13,12,13,10,11,0,1,4,5,4,5,0,1]
; KNL-NEXT:    vpshufd {{.*#+}} xmm1 = xmm2[0,1,0,3]
; KNL-NEXT:    vpshuflw {{.*#+}} xmm2 = xmm1[0,3,2,2,4,5,6,7]
; KNL-NEXT:    vinserti128 $1, %xmm2, %ymm4, %ymm1
; KNL-NEXT:    vextracti128 $1, %ymm0, %xmm5
; KNL-NEXT:    vpunpckhwd {{.*#+}} xmm0 = xmm5[4],xmm0[4],xmm5[5],xmm0[5],xmm5[6],xmm0[6],xmm5[7],xmm0[7]
; KNL-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[12,13,10,11,8,9,14,15,4,5,2,3,2,3,6,7]
; KNL-NEXT:    vpshufb {{.*#+}} xmm5 = xmm5[6,7,2,3,4,5,6,7,2,3,2,3,0,1,14,15]
; KNL-NEXT:    vinserti128 $1, %xmm5, %ymm0, %ymm0
; KNL-NEXT:    vpblendw {{.*#+}} ymm1 = ymm0[0],ymm1[1],ymm0[2],ymm1[3],ymm0[4],ymm1[5],ymm0[6],ymm1[7],ymm0[8],ymm1[9],ymm0[10],ymm1[11],ymm0[12],ymm1[13],ymm0[14],ymm1[15]
; KNL-NEXT:    vextracti128 $1, %ymm3, %xmm3
; KNL-NEXT:    vpbroadcastw %xmm3, %ymm3
; KNL-NEXT:    vmovdqa {{.*#+}} ymm5 = [255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,0,0]
; KNL-NEXT:    vpblendvb %ymm5, %ymm1, %ymm3, %ymm1
; KNL-NEXT:    vpshufhw {{.*#+}} xmm2 = xmm2[0,1,2,3,4,5,6,4]
; KNL-NEXT:    vinserti128 $1, %xmm2, %ymm4, %ymm2
; KNL-NEXT:    vpblendw {{.*#+}} ymm0 = ymm0[0],ymm2[1],ymm0[2],ymm2[3],ymm0[4],ymm2[5],ymm0[6],ymm2[7],ymm0[8],ymm2[9],ymm0[10],ymm2[11],ymm0[12],ymm2[13],ymm0[14],ymm2[15]
; KNL-NEXT:    retq
;
; SKX-LABEL: shuffle_v32i16_0f_1f_0e_16_0d_1d_04_1e_0b_1b_0a_1a_09_19_08_18_0f_1f_0e_16_0d_1d_04_1e_0b_1b_0a_1a_09_19_08_38:
; SKX:       ## BB#0:
; SKX-NEXT:    vmovdqu16 {{.*#+}} zmm2 = [15,31,14,22,13,29,4,28,11,27,10,26,9,25,8,24,15,31,14,22,13,29,4,28,11,27,10,26,9,25,8,56]
; SKX-NEXT:    vpermt2w %zmm1, %zmm2, %zmm0
; SKX-NEXT:    retq
  %c = shufflevector <32 x i16> %a, <32 x i16> %b, <32 x i32> <i32 15, i32 31, i32 14, i32 22, i32 13, i32 29, i32 4, i32 28, i32 11, i32 27, i32 10, i32 26, i32 9, i32 25, i32 8, i32 24, i32 15, i32 31, i32 14, i32 22, i32 13, i32 29, i32 4, i32 28, i32 11, i32 27, i32 10, i32 26, i32 9, i32 25, i32 8, i32 56>
  ret <32 x i16> %c
}

define <32 x i16> @shuffle_v16i32_0_32_1_33_2_34_3_35_8_40_9_41_u_u_u_u(<32 x i16> %a, <32 x i16> %b)  {
; KNL-LABEL: shuffle_v16i32_0_32_1_33_2_34_3_35_8_40_9_41_u_u_u_u:
; KNL:       ## BB#0:
; KNL-NEXT:    vpunpcklwd {{.*#+}} ymm0 = ymm0[0],ymm2[0],ymm0[1],ymm2[1],ymm0[2],ymm2[2],ymm0[3],ymm2[3],ymm0[8],ymm2[8],ymm0[9],ymm2[9],ymm0[10],ymm2[10],ymm0[11],ymm2[11]
; KNL-NEXT:    retq
;
; SKX-LABEL: shuffle_v16i32_0_32_1_33_2_34_3_35_8_40_9_41_u_u_u_u:
; SKX:       ## BB#0:
; SKX-NEXT:    vpunpcklwd {{.*#+}} zmm0 = zmm0[0],zmm1[0],zmm0[1],zmm1[1],zmm0[2],zmm1[2],zmm0[3],zmm1[3],zmm0[8],zmm1[8],zmm0[9],zmm1[9],zmm0[10],zmm1[10],zmm0[11],zmm1[11],zmm0[16],zmm1[16],zmm0[17],zmm1[17],zmm0[18],zmm1[18],zmm0[19],zmm1[19],zmm0[24],zmm1[24],zmm0[25],zmm1[25],zmm0[26],zmm1[26],zmm0[27],zmm1[27]
; SKX-NEXT:    retq
  %c = shufflevector <32 x i16> %a, <32 x i16> %b, <32 x i32> <i32 0, i32 32, i32 1, i32 33, i32 2, i32 34, i32 3, i32 35, i32 8, i32 40, i32 9, i32 41, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  ret <32 x i16> %c
}

define <32 x i16> @shuffle_v16i32_4_36_5_37_6_38_7_39_12_44_13_45_u_u_u_u(<32 x i16> %a, <32 x i16> %b)  {
; KNL-LABEL: shuffle_v16i32_4_36_5_37_6_38_7_39_12_44_13_45_u_u_u_u:
; KNL:       ## BB#0:
; KNL-NEXT:    vpunpckhwd {{.*#+}} ymm0 = ymm0[4],ymm2[4],ymm0[5],ymm2[5],ymm0[6],ymm2[6],ymm0[7],ymm2[7],ymm0[12],ymm2[12],ymm0[13],ymm2[13],ymm0[14],ymm2[14],ymm0[15],ymm2[15]
; KNL-NEXT:    retq
;
; SKX-LABEL: shuffle_v16i32_4_36_5_37_6_38_7_39_12_44_13_45_u_u_u_u:
; SKX:       ## BB#0:
; SKX-NEXT:    vpunpckhwd {{.*#+}} zmm0 = zmm0[4],zmm1[4],zmm0[5],zmm1[5],zmm0[6],zmm1[6],zmm0[7],zmm1[7],zmm0[12],zmm1[12],zmm0[13],zmm1[13],zmm0[14],zmm1[14],zmm0[15],zmm1[15],zmm0[20],zmm1[20],zmm0[21],zmm1[21],zmm0[22],zmm1[22],zmm0[23],zmm1[23],zmm0[28],zmm1[28],zmm0[29],zmm1[29],zmm0[30],zmm1[30],zmm0[31],zmm1[31]
; SKX-NEXT:    retq
  %c = shufflevector <32 x i16> %a, <32 x i16> %b, <32 x i32> <i32 4, i32 36, i32 5, i32 37, i32 6, i32 38, i32 7, i32 39, i32 12, i32 44, i32 13, i32 45, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef, i32 undef>
  ret <32 x i16> %c
}

define <32 x i16> @shuffle_v32i16_1_z_3_z_5_z_7_z_9_z_11_z_13_z_15_z_17_z_19_z_21_z_23_z_25_z_27_z_29_z_31_z(<32 x i16> %a, <32 x i16> %b)  {
; KNL-LABEL: shuffle_v32i16_1_z_3_z_5_z_7_z_9_z_11_z_13_z_15_z_17_z_19_z_21_z_23_z_25_z_27_z_29_z_31_z:
; KNL:       ## BB#0:
; KNL-NEXT:    vpsrld $16, %ymm0, %ymm0
; KNL-NEXT:    vpsrld $16, %ymm1, %ymm1
; KNL-NEXT:    retq
;
; SKX-LABEL: shuffle_v32i16_1_z_3_z_5_z_7_z_9_z_11_z_13_z_15_z_17_z_19_z_21_z_23_z_25_z_27_z_29_z_31_z:
; SKX:       ## BB#0:
; SKX-NEXT:    vpsrld $16, %zmm0, %zmm0
; SKX-NEXT:    retq
  %c = shufflevector <32 x i16> %a, <32 x i16> zeroinitializer, <32 x i32> <i32 1, i32 34, i32 3, i32 34, i32 5, i32 34, i32 7, i32 34, i32 9, i32 34, i32 11, i32 34, i32 13, i32 34, i32 15, i32 34, i32 17, i32 34, i32 19, i32 34, i32 21, i32 34, i32 23, i32 34, i32 25, i32 34, i32 27, i32 34, i32 29, i32 34, i32 31, i32 34>
  ret <32 x i16> %c
}

define <32 x i16> @shuffle_v32i16_z_0_z_2_z_4_z_6_z_8_z_10_z_12_z_14_z_16_z_18_z_20_z_22_z_24_z_26_z_28_z_30(<32 x i16> %a, <32 x i16> %b)  {
; KNL-LABEL: shuffle_v32i16_z_0_z_2_z_4_z_6_z_8_z_10_z_12_z_14_z_16_z_18_z_20_z_22_z_24_z_26_z_28_z_30:
; KNL:       ## BB#0:
; KNL-NEXT:    vpslld $16, %ymm0, %ymm0
; KNL-NEXT:    vpslld $16, %ymm1, %ymm1
; KNL-NEXT:    retq
;
; SKX-LABEL: shuffle_v32i16_z_0_z_2_z_4_z_6_z_8_z_10_z_12_z_14_z_16_z_18_z_20_z_22_z_24_z_26_z_28_z_30:
; SKX:       ## BB#0:
; SKX-NEXT:    vpslld $16, %zmm0, %zmm0
; SKX-NEXT:    retq
  %c = shufflevector <32 x i16> %a, <32 x i16> zeroinitializer, <32 x i32> <i32 34, i32 0, i32 34, i32 2, i32 34, i32 4, i32 34, i32 6, i32 34, i32 8, i32 34, i32 10, i32 34, i32 12, i32 34, i32 14, i32 34, i32 16, i32 34, i32 18, i32 34, i32 20, i32 34, i32 22, i32 34, i32 24, i32 34, i32 26, i32 34, i32 28, i32 34, i32 30>
  ret <32 x i16> %c
}

define <32 x i16> @shuffle_v32i16_1_1_0_0_4_5_6_7_9_9_8_8_12_13_14_15_17_17_16_16_20_21_22_23_25_25_24_24_28_29_30_31(<32 x i16> %a, <32 x i16> %b)  {
; KNL-LABEL: shuffle_v32i16_1_1_0_0_4_5_6_7_9_9_8_8_12_13_14_15_17_17_16_16_20_21_22_23_25_25_24_24_28_29_30_31:
; KNL:       ## BB#0:
; KNL-NEXT:    vpshuflw {{.*#+}} ymm0 = ymm0[1,1,0,0,4,5,6,7,9,9,8,8,12,13,14,15]
; KNL-NEXT:    vpshuflw {{.*#+}} ymm1 = ymm1[1,1,0,0,4,5,6,7,9,9,8,8,12,13,14,15]
; KNL-NEXT:    retq
;
; SKX-LABEL: shuffle_v32i16_1_1_0_0_4_5_6_7_9_9_8_8_12_13_14_15_17_17_16_16_20_21_22_23_25_25_24_24_28_29_30_31:
; SKX:       ## BB#0:
; SKX-NEXT:    vpshuflw {{.*#+}} zmm0 = zmm0[1,1,0,0,4,5,6,7,9,9,8,8,12,13,14,15,17,17,16,16,20,21,22,23,25,25,24,24,28,29,30,31]
; SKX-NEXT:    retq
  %c = shufflevector <32 x i16> %a, <32 x i16> zeroinitializer, <32 x i32> <i32 1, i32 1, i32 0, i32 0, i32 4, i32 5, i32 6, i32 7, i32 9, i32 9, i32 8, i32 8, i32 12, i32 13, i32 14, i32 15, i32 17, i32 17, i32 16, i32 16, i32 20, i32 21, i32 22, i32 23, i32 25, i32 25, i32 24, i32 24, i32 28, i32 29, i32 30, i32 31>
  ret <32 x i16> %c
}

define <32 x i16> @shuffle_v32i16_0_1_2_3_5_5_4_4_8_9_10_11_13_13_12_12_16_17_18_19_21_21_20_20_24_25_26_27_29_29_28_28(<32 x i16> %a, <32 x i16> %b)  {
; KNL-LABEL: shuffle_v32i16_0_1_2_3_5_5_4_4_8_9_10_11_13_13_12_12_16_17_18_19_21_21_20_20_24_25_26_27_29_29_28_28:
; KNL:       ## BB#0:
; KNL-NEXT:    vpshufhw {{.*#+}} ymm0 = ymm0[0,1,2,3,5,5,4,4,8,9,10,11,13,13,12,12]
; KNL-NEXT:    vpshufhw {{.*#+}} ymm1 = ymm1[0,1,2,3,5,5,4,4,8,9,10,11,13,13,12,12]
; KNL-NEXT:    retq
;
; SKX-LABEL: shuffle_v32i16_0_1_2_3_5_5_4_4_8_9_10_11_13_13_12_12_16_17_18_19_21_21_20_20_24_25_26_27_29_29_28_28:
; SKX:       ## BB#0:
; SKX-NEXT:    vpshufhw {{.*#+}} zmm0 = zmm0[0,1,2,3,5,5,4,4,8,9,10,11,13,13,12,12,16,17,18,19,21,21,20,20,24,25,26,27,29,29,28,28]
; SKX-NEXT:    retq
  %c = shufflevector <32 x i16> %a, <32 x i16> zeroinitializer, <32 x i32> <i32 0, i32 1, i32 2, i32 3, i32 5, i32 5, i32 4, i32 4, i32 8, i32 9, i32 10, i32 11, i32 13, i32 13, i32 12, i32 12, i32 16, i32 17, i32 18, i32 19, i32 21, i32 21, i32 20, i32 20, i32 24, i32 25, i32 26, i32 27, i32 29, i32 29, i32 28, i32 28>
  ret <32 x i16> %c
}

define <32 x i16> @shuffle_v32i16_1_1_0_0_5_5_4_4_9_9_11_11_13_13_12_12_17_17_19_19_21_21_20_20_25_25_27_27_29_29_28_28(<32 x i16> %a, <32 x i16> %b)  {
; KNL-LABEL: shuffle_v32i16_1_1_0_0_5_5_4_4_9_9_11_11_13_13_12_12_17_17_19_19_21_21_20_20_25_25_27_27_29_29_28_28:
; KNL:       ## BB#0:
; KNL-NEXT:    vpshuflw {{.*#+}} ymm0 = ymm0[1,1,0,0,4,5,6,7,9,9,8,8,12,13,14,15]
; KNL-NEXT:    vpshufhw {{.*#+}} ymm0 = ymm0[0,1,2,3,5,5,4,4,8,9,10,11,13,13,12,12]
; KNL-NEXT:    vpshuflw {{.*#+}} ymm1 = ymm1[1,1,0,0,4,5,6,7,9,9,8,8,12,13,14,15]
; KNL-NEXT:    vpshufhw {{.*#+}} ymm1 = ymm1[0,1,2,3,5,5,4,4,8,9,10,11,13,13,12,12]
; KNL-NEXT:    retq
;
; SKX-LABEL: shuffle_v32i16_1_1_0_0_5_5_4_4_9_9_11_11_13_13_12_12_17_17_19_19_21_21_20_20_25_25_27_27_29_29_28_28:
; SKX:       ## BB#0:
; SKX-NEXT:    vpshuflw {{.*#+}} zmm0 = zmm0[1,1,0,0,4,5,6,7,9,9,8,8,12,13,14,15,17,17,16,16,20,21,22,23,25,25,24,24,28,29,30,31]
; SKX-NEXT:    vpshufhw {{.*#+}} zmm0 = zmm0[0,1,2,3,5,5,4,4,8,9,10,11,13,13,12,12,16,17,18,19,21,21,20,20,24,25,26,27,29,29,28,28]
; SKX-NEXT:    retq
  %c = shufflevector <32 x i16> %a, <32 x i16> zeroinitializer, <32 x i32> <i32 1, i32 1, i32 0, i32 0, i32 5, i32 5, i32 4, i32 4, i32 9, i32 9, i32 8, i32 8, i32 13, i32 13, i32 12, i32 12, i32 17, i32 17, i32 16, i32 16, i32 21, i32 21, i32 20, i32 20, i32 25, i32 25, i32 24, i32 24, i32 29, i32 29, i32 28, i32 28>
  ret <32 x i16> %c
}

define <32 x i16> @shuffle_v32i16_0zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz(<32 x i16> %a) {
; KNL-LABEL: shuffle_v32i16_0zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz:
; KNL:       ## BB#0:
; KNL-NEXT:    movl $65535, %eax ## imm = 0xFFFF
; KNL-NEXT:    vmovd %eax, %xmm1
; KNL-NEXT:    vpand %ymm1, %ymm0, %ymm0
; KNL-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; KNL-NEXT:    retq
;
; SKX-LABEL: shuffle_v32i16_0zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz:
; SKX:       ## BB#0:
; SKX-NEXT:    movl $1, %eax
; SKX-NEXT:    kmovd %eax, %k1
; SKX-NEXT:    vmovdqu16 %zmm0, %zmm0 {%k1} {z}
; SKX-NEXT:    retq
  %shuffle = shufflevector <32 x i16> %a, <32 x i16> zeroinitializer, <32 x i32> <i32 0, i32 32, i32 32, i32 32, i32 32, i32 32, i32 32, i32 32, i32 32, i32 32, i32 32, i32 32, i32 32, i32 32, i32 32, i32 32, i32 32, i32 32, i32 32, i32 32, i32 32, i32 32, i32 32, i32 32, i32 32, i32 32, i32 32, i32 32, i32 32, i32 32, i32 32, i32 32>
  ret <32 x i16> %shuffle
}

define <32 x i16> @insert_dup_mem_v32i16_i32(i32* %ptr) {
; KNL-LABEL: insert_dup_mem_v32i16_i32:
; KNL:       ## BB#0:
; KNL-NEXT:    vpbroadcastw (%rdi), %ymm0
; KNL-NEXT:    vmovdqa %ymm0, %ymm1
; KNL-NEXT:    retq
;
; SKX-LABEL: insert_dup_mem_v32i16_i32:
; SKX:       ## BB#0:
; SKX-NEXT:    movl (%rdi), %eax
; SKX-NEXT:    vpbroadcastw %ax, %zmm0
; SKX-NEXT:    retq
  %tmp = load i32, i32* %ptr, align 4
  %tmp1 = insertelement <4 x i32> zeroinitializer, i32 %tmp, i32 0
  %tmp2 = bitcast <4 x i32> %tmp1 to <8 x i16>
  %tmp3 = shufflevector <8 x i16> %tmp2, <8 x i16> undef, <32 x i32> zeroinitializer
  ret <32 x i16> %tmp3
}

define <32 x i16> @insert_dup_mem_v32i16_sext_i16(i16* %ptr) {
; KNL-LABEL: insert_dup_mem_v32i16_sext_i16:
; KNL:       ## BB#0:
; KNL-NEXT:    movswl (%rdi), %eax
; KNL-NEXT:    vmovd %eax, %xmm0
; KNL-NEXT:    vpbroadcastw %xmm0, %ymm0
; KNL-NEXT:    vmovdqa %ymm0, %ymm1
; KNL-NEXT:    retq
;
; SKX-LABEL: insert_dup_mem_v32i16_sext_i16:
; SKX:       ## BB#0:
; SKX-NEXT:    movswl (%rdi), %eax
; SKX-NEXT:    vpbroadcastw %ax, %zmm0
; SKX-NEXT:    retq
  %tmp = load i16, i16* %ptr, align 2
  %tmp1 = sext i16 %tmp to i32
  %tmp2 = insertelement <4 x i32> zeroinitializer, i32 %tmp1, i32 0
  %tmp3 = bitcast <4 x i32> %tmp2 to <8 x i16>
  %tmp4 = shufflevector <8 x i16> %tmp3, <8 x i16> undef, <32 x i32> zeroinitializer
  ret <32 x i16> %tmp4
}

define <32 x i16> @insert_dup_elt1_mem_v32i16_i32(i32* %ptr) #0 {
; KNL-LABEL: insert_dup_elt1_mem_v32i16_i32:
; KNL:       ## BB#0:
; KNL-NEXT:    vpbroadcastw 2(%rdi), %ymm0
; KNL-NEXT:    vmovdqa %ymm0, %ymm1
; KNL-NEXT:    retq
;
; SKX-LABEL: insert_dup_elt1_mem_v32i16_i32:
; SKX:       ## BB#0:
; SKX-NEXT:    movzwl 2(%rdi), %eax
; SKX-NEXT:    vpbroadcastw %ax, %zmm0
; SKX-NEXT:    retq
  %tmp = load i32, i32* %ptr, align 4
  %tmp1 = insertelement <4 x i32> zeroinitializer, i32 %tmp, i32 0
  %tmp2 = bitcast <4 x i32> %tmp1 to <8 x i16>
  %tmp3 = shufflevector <8 x i16> %tmp2, <8 x i16> undef, <32 x i32> <i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1>
  ret <32 x i16> %tmp3
}

define <32 x i16> @insert_dup_elt3_mem_v32i16_i32(i32* %ptr) #0 {
; KNL-LABEL: insert_dup_elt3_mem_v32i16_i32:
; KNL:       ## BB#0:
; KNL-NEXT:    vpbroadcastw 2(%rdi), %ymm0
; KNL-NEXT:    vmovdqa %ymm0, %ymm1
; KNL-NEXT:    retq
;
; SKX-LABEL: insert_dup_elt3_mem_v32i16_i32:
; SKX:       ## BB#0:
; SKX-NEXT:    movzwl 2(%rdi), %eax
; SKX-NEXT:    vpbroadcastw %ax, %zmm0
; SKX-NEXT:    retq
  %tmp = load i32, i32* %ptr, align 4
  %tmp1 = insertelement <4 x i32> zeroinitializer, i32 %tmp, i32 1
  %tmp2 = bitcast <4 x i32> %tmp1 to <8 x i16>
  %tmp3 = shufflevector <8 x i16> %tmp2, <8 x i16> undef, <32 x i32> <i32 3, i32 3, i32 3, i32 3, i32 3, i32 3, i32 3, i32 3, i32 3, i32 3, i32 3, i32 3, i32 3, i32 3, i32 3, i32 3, i32 3, i32 3, i32 3, i32 3, i32 3, i32 3, i32 3, i32 3, i32 3, i32 3, i32 3, i32 3, i32 3, i32 3, i32 3, i32 3>
  ret <32 x i16> %tmp3
}

define <32 x i16> @shuffle_v32i16_32_zz_zz_zz_33_zz_zz_zz_34_zz_zz_zz_35_zz_zz_zz_36_zz_zz_zz_37_zz_zz_zz_38_zz_zz_zz_39_zz_zz_zz(<32 x i16> %a) {
; KNL-LABEL: shuffle_v32i16_32_zz_zz_zz_33_zz_zz_zz_34_zz_zz_zz_35_zz_zz_zz_36_zz_zz_zz_37_zz_zz_zz_38_zz_zz_zz_39_zz_zz_zz:
; KNL:       ## BB#0:
; KNL-NEXT:    vpmovzxwq {{.*#+}} ymm2 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero,xmm0[2],zero,zero,zero,xmm0[3],zero,zero,zero
; KNL-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[2,3,0,1]
; KNL-NEXT:    vpmovzxwq {{.*#+}} ymm1 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero,xmm0[2],zero,zero,zero,xmm0[3],zero,zero,zero
; KNL-NEXT:    vmovdqa %ymm2, %ymm0
; KNL-NEXT:    retq
;
; SKX-LABEL: shuffle_v32i16_32_zz_zz_zz_33_zz_zz_zz_34_zz_zz_zz_35_zz_zz_zz_36_zz_zz_zz_37_zz_zz_zz_38_zz_zz_zz_39_zz_zz_zz:
; SKX:       ## BB#0:
; SKX-NEXT:    vpmovzxwq {{.*#+}} zmm0 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero,xmm0[2],zero,zero,zero,xmm0[3],zero,zero,zero,xmm0[4],zero,zero,zero,xmm0[5],zero,zero,zero,xmm0[6],zero,zero,zero,xmm0[7],zero,zero,zero
; SKX-NEXT:    retq
  %shuffle = shufflevector <32 x i16> zeroinitializer, <32 x i16> %a, <32 x i32> <i32 32, i32 0, i32 0, i32 0, i32 33, i32 0, i32 0, i32 0, i32 34, i32 0, i32 0, i32 0, i32 35, i32 0, i32 0, i32 0, i32 36, i32 0, i32 0, i32 0, i32 37, i32 0, i32 0, i32 0, i32 38, i32 0, i32 0, i32 0, i32 39, i32 0, i32 0, i32 0>
  ret <32 x i16> %shuffle
}

define <32 x i16> @shuffle_v32i16_32_zz_33_zz_34_zz_35_zz_36_zz_37_zz_38_zz_39_zz_40_zz_41_zz_42_zz_43_zz_44_zz_45_zz_46_zz_47_zz(<32 x i16> %a) {
; KNL-LABEL: shuffle_v32i16_32_zz_33_zz_34_zz_35_zz_36_zz_37_zz_38_zz_39_zz_40_zz_41_zz_42_zz_43_zz_44_zz_45_zz_46_zz_47_zz:
; KNL:       ## BB#0:
; KNL-NEXT:    vpmovzxwd {{.*#+}} ymm2 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; KNL-NEXT:    vextracti128 $1, %ymm0, %xmm0
; KNL-NEXT:    vpmovzxwd {{.*#+}} ymm1 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; KNL-NEXT:    vmovdqa %ymm2, %ymm0
; KNL-NEXT:    retq
;
; SKX-LABEL: shuffle_v32i16_32_zz_33_zz_34_zz_35_zz_36_zz_37_zz_38_zz_39_zz_40_zz_41_zz_42_zz_43_zz_44_zz_45_zz_46_zz_47_zz:
; SKX:       ## BB#0:
; SKX-NEXT:    vpmovzxwd {{.*#+}} zmm0 = ymm0[0],zero,ymm0[1],zero,ymm0[2],zero,ymm0[3],zero,ymm0[4],zero,ymm0[5],zero,ymm0[6],zero,ymm0[7],zero,ymm0[8],zero,ymm0[9],zero,ymm0[10],zero,ymm0[11],zero,ymm0[12],zero,ymm0[13],zero,ymm0[14],zero,ymm0[15],zero
; SKX-NEXT:    retq
  %shuffle = shufflevector <32 x i16> zeroinitializer, <32 x i16> %a, <32 x i32> <i32 32, i32 0, i32 33, i32 0, i32 34, i32 0, i32 35, i32 0, i32 36, i32 0, i32 37, i32 0, i32 38, i32 0, i32 39, i32 0, i32 40, i32 0, i32 41, i32 0, i32 42, i32 0, i32 43, i32 0, i32 44, i32 0, i32 45, i32 0, i32 46, i32 0, i32 47, i32 0>
  ret <32 x i16> %shuffle
}

define <8 x i16> @pr32967(<32 x i16> %v) {
; KNL-LABEL: pr32967:
; KNL:       ## BB#0:
; KNL-NEXT:    vextracti128 $1, %ymm1, %xmm2
; KNL-NEXT:    vpshufd {{.*#+}} xmm2 = xmm2[0,2,2,3]
; KNL-NEXT:    vpshuflw {{.*#+}} xmm2 = xmm2[0,1,1,3,4,5,6,7]
; KNL-NEXT:    vpshufd {{.*#+}} xmm1 = xmm1[0,2,2,3]
; KNL-NEXT:    vpshuflw {{.*#+}} xmm1 = xmm1[0,1,1,3,4,5,6,7]
; KNL-NEXT:    vpunpckldq {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1]
; KNL-NEXT:    vextracti128 $1, %ymm0, %xmm2
; KNL-NEXT:    vpshufd {{.*#+}} xmm2 = xmm2[0,2,2,3]
; KNL-NEXT:    vpshuflw {{.*#+}} xmm2 = xmm2[1,3,2,3,4,5,6,7]
; KNL-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[0,2,2,3]
; KNL-NEXT:    vpshuflw {{.*#+}} xmm0 = xmm0[1,3,2,3,4,5,6,7]
; KNL-NEXT:    vpunpckldq {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1]
; KNL-NEXT:    vpblendd {{.*#+}} xmm0 = xmm0[0,1],xmm1[2,3]
; KNL-NEXT:    retq
;
; SKX-LABEL: pr32967:
; SKX:       ## BB#0:
; SKX-NEXT:    vpsrld $16, %zmm0, %zmm0
; SKX-NEXT:    vpmovqw %zmm0, %xmm0
; SKX-NEXT:    vzeroupper
; SKX-NEXT:    retq
 %shuffle = shufflevector <32 x i16> %v, <32 x i16> undef, <8 x i32> <i32 1,i32 5,i32 9,i32 13,i32 17,i32 21,i32 25,i32 29>
 ret <8 x i16> %shuffle
}
