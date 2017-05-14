; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown-unknown -mattr=avx | FileCheck %s --check-prefix=X86
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=avx | FileCheck %s --check-prefix=X64

; Insertion/shuffles of all-zero/all-bits/constants into v8i32->v8f32 sitofp conversion.

define <8 x float> @sitofp_insert_zero_v8i32(<8 x i32> %a0) {
; X86-LABEL: sitofp_insert_zero_v8i32:
; X86:       # BB#0:
; X86-NEXT:    vxorps %ymm1, %ymm1, %ymm1
; X86-NEXT:    vblendps {{.*#+}} ymm0 = ymm1[0],ymm0[1],ymm1[2],ymm0[3],ymm1[4,5],ymm0[6,7]
; X86-NEXT:    vcvtdq2ps %ymm0, %ymm0
; X86-NEXT:    retl
;
; X64-LABEL: sitofp_insert_zero_v8i32:
; X64:       # BB#0:
; X64-NEXT:    vxorps %ymm1, %ymm1, %ymm1
; X64-NEXT:    vblendps {{.*#+}} ymm0 = ymm1[0],ymm0[1],ymm1[2],ymm0[3],ymm1[4,5],ymm0[6,7]
; X64-NEXT:    vcvtdq2ps %ymm0, %ymm0
; X64-NEXT:    retq
  %1 = insertelement <8 x i32> %a0, i32 0, i32 0
  %2 = insertelement <8 x i32>  %1, i32 0, i32 2
  %3 = insertelement <8 x i32>  %2, i32 0, i32 4
  %4 = insertelement <8 x i32>  %3, i32 0, i32 5
  %5 = sitofp <8 x i32> %4 to <8 x float>
  ret <8 x float> %5
}

define <8 x float> @sitofp_shuffle_zero_v8i32(<8 x i32> %a0) {
; X86-LABEL: sitofp_shuffle_zero_v8i32:
; X86:       # BB#0:
; X86-NEXT:    vxorps %ymm1, %ymm1, %ymm1
; X86-NEXT:    vblendps {{.*#+}} ymm0 = ymm1[0],ymm0[1],ymm1[2],ymm0[3],ymm1[4],ymm0[5],ymm1[6],ymm0[7]
; X86-NEXT:    vcvtdq2ps %ymm0, %ymm0
; X86-NEXT:    retl
;
; X64-LABEL: sitofp_shuffle_zero_v8i32:
; X64:       # BB#0:
; X64-NEXT:    vxorps %ymm1, %ymm1, %ymm1
; X64-NEXT:    vblendps {{.*#+}} ymm0 = ymm1[0],ymm0[1],ymm1[2],ymm0[3],ymm1[4],ymm0[5],ymm1[6],ymm0[7]
; X64-NEXT:    vcvtdq2ps %ymm0, %ymm0
; X64-NEXT:    retq
  %1 = shufflevector <8 x i32> %a0, <8 x i32> <i32 0, i32 undef, i32 0, i32 undef, i32 0, i32 undef, i32 0, i32 undef>, <8 x i32> <i32 8, i32 1, i32 10, i32 3, i32 12, i32 5, i32 14, i32 7>
  %2 = sitofp <8 x i32> %1 to <8 x float>
  ret <8 x float> %2
}

define <8 x float> @sitofp_insert_allbits_v8i32(<8 x i32> %a0) {
; X86-LABEL: sitofp_insert_allbits_v8i32:
; X86:       # BB#0:
; X86-NEXT:    vxorps %ymm1, %ymm1, %ymm1
; X86-NEXT:    vcmptrueps %ymm1, %ymm1, %ymm1
; X86-NEXT:    vblendps {{.*#+}} ymm0 = ymm1[0],ymm0[1],ymm1[2],ymm0[3],ymm1[4,5],ymm0[6,7]
; X86-NEXT:    vcvtdq2ps %ymm0, %ymm0
; X86-NEXT:    retl
;
; X64-LABEL: sitofp_insert_allbits_v8i32:
; X64:       # BB#0:
; X64-NEXT:    vxorps %ymm1, %ymm1, %ymm1
; X64-NEXT:    vcmptrueps %ymm1, %ymm1, %ymm1
; X64-NEXT:    vblendps {{.*#+}} ymm0 = ymm1[0],ymm0[1],ymm1[2],ymm0[3],ymm1[4,5],ymm0[6,7]
; X64-NEXT:    vcvtdq2ps %ymm0, %ymm0
; X64-NEXT:    retq
  %1 = insertelement <8 x i32> %a0, i32 -1, i32 0
  %2 = insertelement <8 x i32>  %1, i32 -1, i32 2
  %3 = insertelement <8 x i32>  %2, i32 -1, i32 4
  %4 = insertelement <8 x i32>  %3, i32 -1, i32 5
  %5 = sitofp <8 x i32> %4 to <8 x float>
  ret <8 x float> %5
}

define <8 x float> @sitofp_shuffle_allbits_v8i32(<8 x i32> %a0) {
; X86-LABEL: sitofp_shuffle_allbits_v8i32:
; X86:       # BB#0:
; X86-NEXT:    vxorps %ymm1, %ymm1, %ymm1
; X86-NEXT:    vcmptrueps %ymm1, %ymm1, %ymm1
; X86-NEXT:    vblendps {{.*#+}} ymm0 = ymm1[0],ymm0[1],ymm1[2],ymm0[3],ymm1[4],ymm0[5],ymm1[6],ymm0[7]
; X86-NEXT:    vcvtdq2ps %ymm0, %ymm0
; X86-NEXT:    retl
;
; X64-LABEL: sitofp_shuffle_allbits_v8i32:
; X64:       # BB#0:
; X64-NEXT:    vxorps %ymm1, %ymm1, %ymm1
; X64-NEXT:    vcmptrueps %ymm1, %ymm1, %ymm1
; X64-NEXT:    vblendps {{.*#+}} ymm0 = ymm1[0],ymm0[1],ymm1[2],ymm0[3],ymm1[4],ymm0[5],ymm1[6],ymm0[7]
; X64-NEXT:    vcvtdq2ps %ymm0, %ymm0
; X64-NEXT:    retq
  %1 = shufflevector <8 x i32> %a0, <8 x i32> <i32 -1, i32 undef, i32 -1, i32 undef, i32 -1, i32 undef, i32 -1, i32 undef>, <8 x i32> <i32 8, i32 1, i32 10, i32 3, i32 12, i32 5, i32 14, i32 7>
  %2 = sitofp <8 x i32> %1 to <8 x float>
  ret <8 x float> %2
}

define <8 x float> @sitofp_insert_constants_v8i32(<8 x i32> %a0) {
; X86-LABEL: sitofp_insert_constants_v8i32:
; X86:       # BB#0:
; X86-NEXT:    vxorps %ymm1, %ymm1, %ymm1
; X86-NEXT:    vblendps {{.*#+}} ymm0 = ymm1[0],ymm0[1,2,3,4,5,6,7]
; X86-NEXT:    vcmptrueps %ymm1, %ymm1, %ymm1
; X86-NEXT:    vblendps {{.*#+}} ymm0 = ymm0[0,1],ymm1[2],ymm0[3,4,5,6,7]
; X86-NEXT:    vextractf128 $1, %ymm0, %xmm1
; X86-NEXT:    movl $2, %eax
; X86-NEXT:    vpinsrd $0, %eax, %xmm1, %xmm1
; X86-NEXT:    movl $-3, %eax
; X86-NEXT:    vpinsrd $1, %eax, %xmm1, %xmm1
; X86-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; X86-NEXT:    vcvtdq2ps %ymm0, %ymm0
; X86-NEXT:    retl
;
; X64-LABEL: sitofp_insert_constants_v8i32:
; X64:       # BB#0:
; X64-NEXT:    vxorps %ymm1, %ymm1, %ymm1
; X64-NEXT:    vblendps {{.*#+}} ymm0 = ymm1[0],ymm0[1,2,3,4,5,6,7]
; X64-NEXT:    vcmptrueps %ymm1, %ymm1, %ymm1
; X64-NEXT:    vblendps {{.*#+}} ymm0 = ymm0[0,1],ymm1[2],ymm0[3,4,5,6,7]
; X64-NEXT:    vextractf128 $1, %ymm0, %xmm1
; X64-NEXT:    movl $2, %eax
; X64-NEXT:    vpinsrd $0, %eax, %xmm1, %xmm1
; X64-NEXT:    movl $-3, %eax
; X64-NEXT:    vpinsrd $1, %eax, %xmm1, %xmm1
; X64-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; X64-NEXT:    vcvtdq2ps %ymm0, %ymm0
; X64-NEXT:    retq
  %1 = insertelement <8 x i32> %a0, i32  0, i32 0
  %2 = insertelement <8 x i32>  %1, i32 -1, i32 2
  %3 = insertelement <8 x i32>  %2, i32  2, i32 4
  %4 = insertelement <8 x i32>  %3, i32 -3, i32 5
  %5 = sitofp <8 x i32> %4 to <8 x float>
  ret <8 x float> %5
}

define <8 x float> @sitofp_shuffle_constants_v8i32(<8 x i32> %a0) {
; X86-LABEL: sitofp_shuffle_constants_v8i32:
; X86:       # BB#0:
; X86-NEXT:    vblendps {{.*#+}} ymm0 = mem[0],ymm0[1],mem[2],ymm0[3],mem[4],ymm0[5],mem[6],ymm0[7]
; X86-NEXT:    vcvtdq2ps %ymm0, %ymm0
; X86-NEXT:    retl
;
; X64-LABEL: sitofp_shuffle_constants_v8i32:
; X64:       # BB#0:
; X64-NEXT:    vblendps {{.*#+}} ymm0 = mem[0],ymm0[1],mem[2],ymm0[3],mem[4],ymm0[5],mem[6],ymm0[7]
; X64-NEXT:    vcvtdq2ps %ymm0, %ymm0
; X64-NEXT:    retq
  %1 = shufflevector <8 x i32> %a0, <8 x i32> <i32 0, i32 undef, i32 -1, i32 undef, i32 2, i32 undef, i32 -3, i32 undef>, <8 x i32> <i32 8, i32 1, i32 10, i32 3, i32 12, i32 5, i32 14, i32 7>
  %2 = sitofp <8 x i32> %1 to <8 x float>
  ret <8 x float> %2
}
