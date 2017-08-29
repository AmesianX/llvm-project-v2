; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mcpu=skx | FileCheck %s --check-prefix=CHECK --check-prefix=VLX
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mcpu=knl | FileCheck %s --check-prefix=CHECK --check-prefix=NoVLX

define <4 x i64> @test256_1(<4 x i64> %x, <4 x i64> %y) nounwind {
; VLX-LABEL: test256_1:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpeqq %ymm1, %ymm0, %k1
; VLX-NEXT:    vpblendmq %ymm0, %ymm1, %ymm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test256_1:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    vpcmpeqq %ymm1, %ymm0, %ymm2
; NoVLX-NEXT:    vblendvpd %ymm2, %ymm0, %ymm1, %ymm0
; NoVLX-NEXT:    retq
  %mask = icmp eq <4 x i64> %x, %y
  %max = select <4 x i1> %mask, <4 x i64> %x, <4 x i64> %y
  ret <4 x i64> %max
}

define <4 x i64> @test256_2(<4 x i64> %x, <4 x i64> %y, <4 x i64> %x1) nounwind {
; VLX-LABEL: test256_2:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpgtq %ymm1, %ymm0, %k1
; VLX-NEXT:    vpblendmq %ymm2, %ymm1, %ymm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test256_2:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    vpcmpgtq %ymm1, %ymm0, %ymm0
; NoVLX-NEXT:    vblendvpd %ymm0, %ymm2, %ymm1, %ymm0
; NoVLX-NEXT:    retq
  %mask = icmp sgt <4 x i64> %x, %y
  %max = select <4 x i1> %mask, <4 x i64> %x1, <4 x i64> %y
  ret <4 x i64> %max
}

define <8 x i32> @test256_3(<8 x i32> %x, <8 x i32> %y, <8 x i32> %x1) nounwind {
; VLX-LABEL: test256_3:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpled %ymm0, %ymm1, %k1
; VLX-NEXT:    vpblendmd %ymm2, %ymm1, %ymm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test256_3:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    # kill: %YMM2<def> %YMM2<kill> %ZMM2<def>
; NoVLX-NEXT:    # kill: %YMM1<def> %YMM1<kill> %ZMM1<def>
; NoVLX-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<def>
; NoVLX-NEXT:    vpcmpled %zmm0, %zmm1, %k1
; NoVLX-NEXT:    vpblendmd %zmm2, %zmm1, %zmm0 {%k1}
; NoVLX-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<kill>
; NoVLX-NEXT:    retq
  %mask = icmp sge <8 x i32> %x, %y
  %max = select <8 x i1> %mask, <8 x i32> %x1, <8 x i32> %y
  ret <8 x i32> %max
}

define <4 x i64> @test256_4(<4 x i64> %x, <4 x i64> %y, <4 x i64> %x1) nounwind {
; VLX-LABEL: test256_4:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpnleuq %ymm1, %ymm0, %k1
; VLX-NEXT:    vpblendmq %ymm2, %ymm1, %ymm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test256_4:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    vpbroadcastq {{.*#+}} ymm3 = [9223372036854775808,9223372036854775808,9223372036854775808,9223372036854775808]
; NoVLX-NEXT:    vpxor %ymm3, %ymm1, %ymm4
; NoVLX-NEXT:    vpxor %ymm3, %ymm0, %ymm0
; NoVLX-NEXT:    vpcmpgtq %ymm4, %ymm0, %ymm0
; NoVLX-NEXT:    vblendvpd %ymm0, %ymm2, %ymm1, %ymm0
; NoVLX-NEXT:    retq
  %mask = icmp ugt <4 x i64> %x, %y
  %max = select <4 x i1> %mask, <4 x i64> %x1, <4 x i64> %y
  ret <4 x i64> %max
}

define <8 x i32> @test256_5(<8 x i32> %x, <8 x i32> %x1, <8 x i32>* %yp) nounwind {
; VLX-LABEL: test256_5:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpeqd (%rdi), %ymm0, %k1
; VLX-NEXT:    vpblendmd %ymm0, %ymm1, %ymm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test256_5:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    # kill: %YMM1<def> %YMM1<kill> %ZMM1<def>
; NoVLX-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<def>
; NoVLX-NEXT:    vmovdqu (%rdi), %ymm2
; NoVLX-NEXT:    vpcmpeqd %zmm2, %zmm0, %k1
; NoVLX-NEXT:    vpblendmd %zmm0, %zmm1, %zmm0 {%k1}
; NoVLX-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<kill>
; NoVLX-NEXT:    retq
  %y = load <8 x i32>, <8 x i32>* %yp, align 4
  %mask = icmp eq <8 x i32> %x, %y
  %max = select <8 x i1> %mask, <8 x i32> %x, <8 x i32> %x1
  ret <8 x i32> %max
}

define <8 x i32> @test256_5b(<8 x i32> %x, <8 x i32> %x1, <8 x i32>* %yp) nounwind {
; VLX-LABEL: test256_5b:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpeqd (%rdi), %ymm0, %k1
; VLX-NEXT:    vpblendmd %ymm0, %ymm1, %ymm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test256_5b:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    # kill: %YMM1<def> %YMM1<kill> %ZMM1<def>
; NoVLX-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<def>
; NoVLX-NEXT:    vmovdqu (%rdi), %ymm2
; NoVLX-NEXT:    vpcmpeqd %zmm0, %zmm2, %k1
; NoVLX-NEXT:    vpblendmd %zmm0, %zmm1, %zmm0 {%k1}
; NoVLX-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<kill>
; NoVLX-NEXT:    retq
  %y = load <8 x i32>, <8 x i32>* %yp, align 4
  %mask = icmp eq <8 x i32> %y, %x
  %max = select <8 x i1> %mask, <8 x i32> %x, <8 x i32> %x1
  ret <8 x i32> %max
}

define <8 x i32> @test256_6(<8 x i32> %x, <8 x i32> %x1, <8 x i32>* %y.ptr) nounwind {
; VLX-LABEL: test256_6:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpgtd (%rdi), %ymm0, %k1
; VLX-NEXT:    vpblendmd %ymm0, %ymm1, %ymm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test256_6:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    # kill: %YMM1<def> %YMM1<kill> %ZMM1<def>
; NoVLX-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<def>
; NoVLX-NEXT:    vmovdqu (%rdi), %ymm2
; NoVLX-NEXT:    vpcmpgtd %zmm2, %zmm0, %k1
; NoVLX-NEXT:    vpblendmd %zmm0, %zmm1, %zmm0 {%k1}
; NoVLX-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<kill>
; NoVLX-NEXT:    retq
  %y = load <8 x i32>, <8 x i32>* %y.ptr, align 4
  %mask = icmp sgt <8 x i32> %x, %y
  %max = select <8 x i1> %mask, <8 x i32> %x, <8 x i32> %x1
  ret <8 x i32> %max
}

define <8 x i32> @test256_6b(<8 x i32> %x, <8 x i32> %x1, <8 x i32>* %y.ptr) nounwind {
; VLX-LABEL: test256_6b:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpgtd (%rdi), %ymm0, %k1
; VLX-NEXT:    vpblendmd %ymm0, %ymm1, %ymm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test256_6b:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    # kill: %YMM1<def> %YMM1<kill> %ZMM1<def>
; NoVLX-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<def>
; NoVLX-NEXT:    vmovdqu (%rdi), %ymm2
; NoVLX-NEXT:    vpcmpgtd %zmm2, %zmm0, %k1
; NoVLX-NEXT:    vpblendmd %zmm0, %zmm1, %zmm0 {%k1}
; NoVLX-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<kill>
; NoVLX-NEXT:    retq
  %y = load <8 x i32>, <8 x i32>* %y.ptr, align 4
  %mask = icmp slt <8 x i32> %y, %x
  %max = select <8 x i1> %mask, <8 x i32> %x, <8 x i32> %x1
  ret <8 x i32> %max
}

define <8 x i32> @test256_7(<8 x i32> %x, <8 x i32> %x1, <8 x i32>* %y.ptr) nounwind {
; VLX-LABEL: test256_7:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpled (%rdi), %ymm0, %k1
; VLX-NEXT:    vpblendmd %ymm0, %ymm1, %ymm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test256_7:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    # kill: %YMM1<def> %YMM1<kill> %ZMM1<def>
; NoVLX-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<def>
; NoVLX-NEXT:    vmovdqu (%rdi), %ymm2
; NoVLX-NEXT:    vpcmpled %zmm2, %zmm0, %k1
; NoVLX-NEXT:    vpblendmd %zmm0, %zmm1, %zmm0 {%k1}
; NoVLX-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<kill>
; NoVLX-NEXT:    retq
  %y = load <8 x i32>, <8 x i32>* %y.ptr, align 4
  %mask = icmp sle <8 x i32> %x, %y
  %max = select <8 x i1> %mask, <8 x i32> %x, <8 x i32> %x1
  ret <8 x i32> %max
}

define <8 x i32> @test256_7b(<8 x i32> %x, <8 x i32> %x1, <8 x i32>* %y.ptr) nounwind {
; VLX-LABEL: test256_7b:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpled (%rdi), %ymm0, %k1
; VLX-NEXT:    vpblendmd %ymm0, %ymm1, %ymm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test256_7b:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    # kill: %YMM1<def> %YMM1<kill> %ZMM1<def>
; NoVLX-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<def>
; NoVLX-NEXT:    vmovdqu (%rdi), %ymm2
; NoVLX-NEXT:    vpcmpled %zmm2, %zmm0, %k1
; NoVLX-NEXT:    vpblendmd %zmm0, %zmm1, %zmm0 {%k1}
; NoVLX-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<kill>
; NoVLX-NEXT:    retq
  %y = load <8 x i32>, <8 x i32>* %y.ptr, align 4
  %mask = icmp sge <8 x i32> %y, %x
  %max = select <8 x i1> %mask, <8 x i32> %x, <8 x i32> %x1
  ret <8 x i32> %max
}

define <8 x i32> @test256_8(<8 x i32> %x, <8 x i32> %x1, <8 x i32>* %y.ptr) nounwind {
; VLX-LABEL: test256_8:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpleud (%rdi), %ymm0, %k1
; VLX-NEXT:    vpblendmd %ymm0, %ymm1, %ymm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test256_8:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    # kill: %YMM1<def> %YMM1<kill> %ZMM1<def>
; NoVLX-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<def>
; NoVLX-NEXT:    vmovdqu (%rdi), %ymm2
; NoVLX-NEXT:    vpcmpleud %zmm2, %zmm0, %k1
; NoVLX-NEXT:    vpblendmd %zmm0, %zmm1, %zmm0 {%k1}
; NoVLX-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<kill>
; NoVLX-NEXT:    retq
  %y = load <8 x i32>, <8 x i32>* %y.ptr, align 4
  %mask = icmp ule <8 x i32> %x, %y
  %max = select <8 x i1> %mask, <8 x i32> %x, <8 x i32> %x1
  ret <8 x i32> %max
}

define <8 x i32> @test256_8b(<8 x i32> %x, <8 x i32> %x1, <8 x i32>* %y.ptr) nounwind {
; VLX-LABEL: test256_8b:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpleud (%rdi), %ymm0, %k1
; VLX-NEXT:    vpblendmd %ymm0, %ymm1, %ymm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test256_8b:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    # kill: %YMM1<def> %YMM1<kill> %ZMM1<def>
; NoVLX-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<def>
; NoVLX-NEXT:    vmovdqu (%rdi), %ymm2
; NoVLX-NEXT:    vpcmpnltud %zmm0, %zmm2, %k1
; NoVLX-NEXT:    vpblendmd %zmm0, %zmm1, %zmm0 {%k1}
; NoVLX-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<kill>
; NoVLX-NEXT:    retq
  %y = load <8 x i32>, <8 x i32>* %y.ptr, align 4
  %mask = icmp uge <8 x i32> %y, %x
  %max = select <8 x i1> %mask, <8 x i32> %x, <8 x i32> %x1
  ret <8 x i32> %max
}

define <8 x i32> @test256_9(<8 x i32> %x, <8 x i32> %y, <8 x i32> %x1, <8 x i32> %y1) nounwind {
; VLX-LABEL: test256_9:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpeqd %ymm1, %ymm0, %k1
; VLX-NEXT:    vpcmpeqd %ymm3, %ymm2, %k1 {%k1}
; VLX-NEXT:    vpblendmd %ymm0, %ymm1, %ymm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test256_9:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    # kill: %YMM3<def> %YMM3<kill> %ZMM3<def>
; NoVLX-NEXT:    # kill: %YMM2<def> %YMM2<kill> %ZMM2<def>
; NoVLX-NEXT:    # kill: %YMM1<def> %YMM1<kill> %ZMM1<def>
; NoVLX-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<def>
; NoVLX-NEXT:    vpcmpeqd %zmm3, %zmm2, %k0
; NoVLX-NEXT:    vpcmpeqd %zmm1, %zmm0, %k1
; NoVLX-NEXT:    kandw %k0, %k1, %k1
; NoVLX-NEXT:    vpblendmd %zmm0, %zmm1, %zmm0 {%k1}
; NoVLX-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<kill>
; NoVLX-NEXT:    retq
  %mask1 = icmp eq <8 x i32> %x1, %y1
  %mask0 = icmp eq <8 x i32> %x, %y
  %mask = select <8 x i1> %mask0, <8 x i1> %mask1, <8 x i1> zeroinitializer
  %max = select <8 x i1> %mask, <8 x i32> %x, <8 x i32> %y
  ret <8 x i32> %max
}

define <4 x i64> @test256_10(<4 x i64> %x, <4 x i64> %y, <4 x i64> %x1, <4 x i64> %y1) nounwind {
; VLX-LABEL: test256_10:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpleq %ymm1, %ymm0, %k1
; VLX-NEXT:    vpcmpleq %ymm2, %ymm3, %k1 {%k1}
; VLX-NEXT:    vpblendmq %ymm0, %ymm2, %ymm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test256_10:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    vpcmpgtq %ymm2, %ymm3, %ymm3
; NoVLX-NEXT:    vpcmpeqd %ymm4, %ymm4, %ymm4
; NoVLX-NEXT:    vpxor %ymm4, %ymm3, %ymm3
; NoVLX-NEXT:    vpcmpgtq %ymm1, %ymm0, %ymm1
; NoVLX-NEXT:    vpandn %ymm3, %ymm1, %ymm1
; NoVLX-NEXT:    vblendvpd %ymm1, %ymm0, %ymm2, %ymm0
; NoVLX-NEXT:    retq
  %mask1 = icmp sge <4 x i64> %x1, %y1
  %mask0 = icmp sle <4 x i64> %x, %y
  %mask = select <4 x i1> %mask0, <4 x i1> %mask1, <4 x i1> zeroinitializer
  %max = select <4 x i1> %mask, <4 x i64> %x, <4 x i64> %x1
  ret <4 x i64> %max
}

define <4 x i64> @test256_11(<4 x i64> %x, <4 x i64>* %y.ptr, <4 x i64> %x1, <4 x i64> %y1) nounwind {
; VLX-LABEL: test256_11:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpgtq %ymm2, %ymm1, %k1
; VLX-NEXT:    vpcmpgtq (%rdi), %ymm0, %k1 {%k1}
; VLX-NEXT:    vpblendmq %ymm0, %ymm1, %ymm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test256_11:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    vpcmpgtq (%rdi), %ymm0, %ymm3
; NoVLX-NEXT:    vpcmpgtq %ymm2, %ymm1, %ymm2
; NoVLX-NEXT:    vpand %ymm2, %ymm3, %ymm2
; NoVLX-NEXT:    vblendvpd %ymm2, %ymm0, %ymm1, %ymm0
; NoVLX-NEXT:    retq
  %mask1 = icmp sgt <4 x i64> %x1, %y1
  %y = load <4 x i64>, <4 x i64>* %y.ptr, align 4
  %mask0 = icmp sgt <4 x i64> %x, %y
  %mask = select <4 x i1> %mask0, <4 x i1> %mask1, <4 x i1> zeroinitializer
  %max = select <4 x i1> %mask, <4 x i64> %x, <4 x i64> %x1
  ret <4 x i64> %max
}

define <8 x i32> @test256_12(<8 x i32> %x, <8 x i32>* %y.ptr, <8 x i32> %x1, <8 x i32> %y1) nounwind {
; VLX-LABEL: test256_12:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpled %ymm1, %ymm2, %k1
; VLX-NEXT:    vpcmpleud (%rdi), %ymm0, %k1 {%k1}
; VLX-NEXT:    vpblendmd %ymm0, %ymm1, %ymm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test256_12:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    # kill: %YMM2<def> %YMM2<kill> %ZMM2<def>
; NoVLX-NEXT:    # kill: %YMM1<def> %YMM1<kill> %ZMM1<def>
; NoVLX-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<def>
; NoVLX-NEXT:    vpcmpled %zmm1, %zmm2, %k0
; NoVLX-NEXT:    vmovdqu (%rdi), %ymm2
; NoVLX-NEXT:    vpcmpleud %zmm2, %zmm0, %k1
; NoVLX-NEXT:    kandw %k0, %k1, %k1
; NoVLX-NEXT:    vpblendmd %zmm0, %zmm1, %zmm0 {%k1}
; NoVLX-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<kill>
; NoVLX-NEXT:    retq
  %mask1 = icmp sge <8 x i32> %x1, %y1
  %y = load <8 x i32>, <8 x i32>* %y.ptr, align 4
  %mask0 = icmp ule <8 x i32> %x, %y
  %mask = select <8 x i1> %mask0, <8 x i1> %mask1, <8 x i1> zeroinitializer
  %max = select <8 x i1> %mask, <8 x i32> %x, <8 x i32> %x1
  ret <8 x i32> %max
}

define <4 x i64> @test256_13(<4 x i64> %x, <4 x i64> %x1, i64* %yb.ptr) nounwind {
; VLX-LABEL: test256_13:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpeqq (%rdi){1to4}, %ymm0, %k1
; VLX-NEXT:    vpblendmq %ymm0, %ymm1, %ymm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test256_13:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    vpbroadcastq (%rdi), %ymm2
; NoVLX-NEXT:    vpcmpeqq %ymm2, %ymm0, %ymm2
; NoVLX-NEXT:    vblendvpd %ymm2, %ymm0, %ymm1, %ymm0
; NoVLX-NEXT:    retq
  %yb = load i64, i64* %yb.ptr, align 4
  %y.0 = insertelement <4 x i64> undef, i64 %yb, i32 0
  %y = shufflevector <4 x i64> %y.0, <4 x i64> undef, <4 x i32> zeroinitializer
  %mask = icmp eq <4 x i64> %x, %y
  %max = select <4 x i1> %mask, <4 x i64> %x, <4 x i64> %x1
  ret <4 x i64> %max
}

define <8 x i32> @test256_14(<8 x i32> %x, i32* %yb.ptr, <8 x i32> %x1) nounwind {
; VLX-LABEL: test256_14:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpled (%rdi){1to8}, %ymm0, %k1
; VLX-NEXT:    vpblendmd %ymm0, %ymm1, %ymm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test256_14:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    # kill: %YMM1<def> %YMM1<kill> %ZMM1<def>
; NoVLX-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<def>
; NoVLX-NEXT:    vpbroadcastd (%rdi), %ymm2
; NoVLX-NEXT:    vpcmpled %zmm2, %zmm0, %k1
; NoVLX-NEXT:    vpblendmd %zmm0, %zmm1, %zmm0 {%k1}
; NoVLX-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<kill>
; NoVLX-NEXT:    retq
  %yb = load i32, i32* %yb.ptr, align 4
  %y.0 = insertelement <8 x i32> undef, i32 %yb, i32 0
  %y = shufflevector <8 x i32> %y.0, <8 x i32> undef, <8 x i32> zeroinitializer
  %mask = icmp sle <8 x i32> %x, %y
  %max = select <8 x i1> %mask, <8 x i32> %x, <8 x i32> %x1
  ret <8 x i32> %max
}

define <8 x i32> @test256_15(<8 x i32> %x, i32* %yb.ptr, <8 x i32> %x1, <8 x i32> %y1) nounwind {
; VLX-LABEL: test256_15:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpled %ymm1, %ymm2, %k1
; VLX-NEXT:    vpcmpgtd (%rdi){1to8}, %ymm0, %k1 {%k1}
; VLX-NEXT:    vpblendmd %ymm0, %ymm1, %ymm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test256_15:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    # kill: %YMM2<def> %YMM2<kill> %ZMM2<def>
; NoVLX-NEXT:    # kill: %YMM1<def> %YMM1<kill> %ZMM1<def>
; NoVLX-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<def>
; NoVLX-NEXT:    vpcmpled %zmm1, %zmm2, %k0
; NoVLX-NEXT:    vpbroadcastd (%rdi), %ymm2
; NoVLX-NEXT:    vpcmpgtd %zmm2, %zmm0, %k1
; NoVLX-NEXT:    kandw %k0, %k1, %k1
; NoVLX-NEXT:    vpblendmd %zmm0, %zmm1, %zmm0 {%k1}
; NoVLX-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<kill>
; NoVLX-NEXT:    retq
  %mask1 = icmp sge <8 x i32> %x1, %y1
  %yb = load i32, i32* %yb.ptr, align 4
  %y.0 = insertelement <8 x i32> undef, i32 %yb, i32 0
  %y = shufflevector <8 x i32> %y.0, <8 x i32> undef, <8 x i32> zeroinitializer
  %mask0 = icmp sgt <8 x i32> %x, %y
  %mask = select <8 x i1> %mask0, <8 x i1> %mask1, <8 x i1> zeroinitializer
  %max = select <8 x i1> %mask, <8 x i32> %x, <8 x i32> %x1
  ret <8 x i32> %max
}

define <4 x i64> @test256_16(<4 x i64> %x, i64* %yb.ptr, <4 x i64> %x1, <4 x i64> %y1) nounwind {
; VLX-LABEL: test256_16:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpleq %ymm1, %ymm2, %k1
; VLX-NEXT:    vpcmpgtq (%rdi){1to4}, %ymm0, %k1 {%k1}
; VLX-NEXT:    vpblendmq %ymm0, %ymm1, %ymm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test256_16:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    vpcmpgtq %ymm1, %ymm2, %ymm2
; NoVLX-NEXT:    vpbroadcastq (%rdi), %ymm3
; NoVLX-NEXT:    vpcmpgtq %ymm3, %ymm0, %ymm3
; NoVLX-NEXT:    vpandn %ymm3, %ymm2, %ymm2
; NoVLX-NEXT:    vblendvpd %ymm2, %ymm0, %ymm1, %ymm0
; NoVLX-NEXT:    retq
  %mask1 = icmp sge <4 x i64> %x1, %y1
  %yb = load i64, i64* %yb.ptr, align 4
  %y.0 = insertelement <4 x i64> undef, i64 %yb, i32 0
  %y = shufflevector <4 x i64> %y.0, <4 x i64> undef, <4 x i32> zeroinitializer
  %mask0 = icmp sgt <4 x i64> %x, %y
  %mask = select <4 x i1> %mask0, <4 x i1> %mask1, <4 x i1> zeroinitializer
  %max = select <4 x i1> %mask, <4 x i64> %x, <4 x i64> %x1
  ret <4 x i64> %max
}

define <8 x i32> @test256_17(<8 x i32> %x, <8 x i32> %x1, <8 x i32>* %yp) nounwind {
; VLX-LABEL: test256_17:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpneqd (%rdi), %ymm0, %k1
; VLX-NEXT:    vpblendmd %ymm0, %ymm1, %ymm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test256_17:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    # kill: %YMM1<def> %YMM1<kill> %ZMM1<def>
; NoVLX-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<def>
; NoVLX-NEXT:    vmovdqu (%rdi), %ymm2
; NoVLX-NEXT:    vpcmpneqd %zmm2, %zmm0, %k1
; NoVLX-NEXT:    vpblendmd %zmm0, %zmm1, %zmm0 {%k1}
; NoVLX-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<kill>
; NoVLX-NEXT:    retq
  %y = load <8 x i32>, <8 x i32>* %yp, align 4
  %mask = icmp ne <8 x i32> %x, %y
  %max = select <8 x i1> %mask, <8 x i32> %x, <8 x i32> %x1
  ret <8 x i32> %max
}

define <8 x i32> @test256_18(<8 x i32> %x, <8 x i32> %x1, <8 x i32>* %yp) nounwind {
; VLX-LABEL: test256_18:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpneqd (%rdi), %ymm0, %k1
; VLX-NEXT:    vpblendmd %ymm0, %ymm1, %ymm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test256_18:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    # kill: %YMM1<def> %YMM1<kill> %ZMM1<def>
; NoVLX-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<def>
; NoVLX-NEXT:    vmovdqu (%rdi), %ymm2
; NoVLX-NEXT:    vpcmpneqd %zmm0, %zmm2, %k1
; NoVLX-NEXT:    vpblendmd %zmm0, %zmm1, %zmm0 {%k1}
; NoVLX-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<kill>
; NoVLX-NEXT:    retq
  %y = load <8 x i32>, <8 x i32>* %yp, align 4
  %mask = icmp ne <8 x i32> %y, %x
  %max = select <8 x i1> %mask, <8 x i32> %x, <8 x i32> %x1
  ret <8 x i32> %max
}

define <8 x i32> @test256_19(<8 x i32> %x, <8 x i32> %x1, <8 x i32>* %yp) nounwind {
; VLX-LABEL: test256_19:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpnltud (%rdi), %ymm0, %k1
; VLX-NEXT:    vpblendmd %ymm0, %ymm1, %ymm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test256_19:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    # kill: %YMM1<def> %YMM1<kill> %ZMM1<def>
; NoVLX-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<def>
; NoVLX-NEXT:    vmovdqu (%rdi), %ymm2
; NoVLX-NEXT:    vpcmpnltud %zmm2, %zmm0, %k1
; NoVLX-NEXT:    vpblendmd %zmm0, %zmm1, %zmm0 {%k1}
; NoVLX-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<kill>
; NoVLX-NEXT:    retq
  %y = load <8 x i32>, <8 x i32>* %yp, align 4
  %mask = icmp uge <8 x i32> %x, %y
  %max = select <8 x i1> %mask, <8 x i32> %x, <8 x i32> %x1
  ret <8 x i32> %max
}

define <8 x i32> @test256_20(<8 x i32> %x, <8 x i32> %x1, <8 x i32>* %yp) nounwind {
; VLX-LABEL: test256_20:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpleud (%rdi), %ymm0, %k1
; VLX-NEXT:    vpblendmd %ymm0, %ymm1, %ymm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test256_20:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    # kill: %YMM1<def> %YMM1<kill> %ZMM1<def>
; NoVLX-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<def>
; NoVLX-NEXT:    vmovdqu (%rdi), %ymm2
; NoVLX-NEXT:    vpcmpnltud %zmm0, %zmm2, %k1
; NoVLX-NEXT:    vpblendmd %zmm0, %zmm1, %zmm0 {%k1}
; NoVLX-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<kill>
; NoVLX-NEXT:    retq
  %y = load <8 x i32>, <8 x i32>* %yp, align 4
  %mask = icmp uge <8 x i32> %y, %x
  %max = select <8 x i1> %mask, <8 x i32> %x, <8 x i32> %x1
  ret <8 x i32> %max
}

define <2 x i64> @test128_1(<2 x i64> %x, <2 x i64> %y) nounwind {
; VLX-LABEL: test128_1:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpeqq %xmm1, %xmm0, %k1
; VLX-NEXT:    vpblendmq %xmm0, %xmm1, %xmm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test128_1:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    vpcmpeqq %xmm1, %xmm0, %xmm2
; NoVLX-NEXT:    vblendvpd %xmm2, %xmm0, %xmm1, %xmm0
; NoVLX-NEXT:    retq
  %mask = icmp eq <2 x i64> %x, %y
  %max = select <2 x i1> %mask, <2 x i64> %x, <2 x i64> %y
  ret <2 x i64> %max
}

define <2 x i64> @test128_2(<2 x i64> %x, <2 x i64> %y, <2 x i64> %x1) nounwind {
; VLX-LABEL: test128_2:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpgtq %xmm1, %xmm0, %k1
; VLX-NEXT:    vpblendmq %xmm2, %xmm1, %xmm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test128_2:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    vpcmpgtq %xmm1, %xmm0, %xmm0
; NoVLX-NEXT:    vblendvpd %xmm0, %xmm2, %xmm1, %xmm0
; NoVLX-NEXT:    retq
  %mask = icmp sgt <2 x i64> %x, %y
  %max = select <2 x i1> %mask, <2 x i64> %x1, <2 x i64> %y
  ret <2 x i64> %max
}

define <4 x i32> @test128_3(<4 x i32> %x, <4 x i32> %y, <4 x i32> %x1) nounwind {
; VLX-LABEL: test128_3:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpled %xmm0, %xmm1, %k1
; VLX-NEXT:    vpblendmd %xmm2, %xmm1, %xmm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test128_3:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    vpcmpgtd %xmm0, %xmm1, %xmm0
; NoVLX-NEXT:    vpcmpeqd %xmm3, %xmm3, %xmm3
; NoVLX-NEXT:    vpxor %xmm3, %xmm0, %xmm0
; NoVLX-NEXT:    vblendvps %xmm0, %xmm2, %xmm1, %xmm0
; NoVLX-NEXT:    retq
  %mask = icmp sge <4 x i32> %x, %y
  %max = select <4 x i1> %mask, <4 x i32> %x1, <4 x i32> %y
  ret <4 x i32> %max
}

define <2 x i64> @test128_4(<2 x i64> %x, <2 x i64> %y, <2 x i64> %x1) nounwind {
; VLX-LABEL: test128_4:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpnleuq %xmm1, %xmm0, %k1
; VLX-NEXT:    vpblendmq %xmm2, %xmm1, %xmm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test128_4:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    vmovdqa {{.*#+}} xmm3 = [9223372036854775808,9223372036854775808]
; NoVLX-NEXT:    vpxor %xmm3, %xmm1, %xmm4
; NoVLX-NEXT:    vpxor %xmm3, %xmm0, %xmm0
; NoVLX-NEXT:    vpcmpgtq %xmm4, %xmm0, %xmm0
; NoVLX-NEXT:    vblendvpd %xmm0, %xmm2, %xmm1, %xmm0
; NoVLX-NEXT:    retq
  %mask = icmp ugt <2 x i64> %x, %y
  %max = select <2 x i1> %mask, <2 x i64> %x1, <2 x i64> %y
  ret <2 x i64> %max
}

define <4 x i32> @test128_5(<4 x i32> %x, <4 x i32> %x1, <4 x i32>* %yp) nounwind {
; VLX-LABEL: test128_5:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpeqd (%rdi), %xmm0, %k1
; VLX-NEXT:    vpblendmd %xmm0, %xmm1, %xmm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test128_5:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    vpcmpeqd (%rdi), %xmm0, %xmm2
; NoVLX-NEXT:    vblendvps %xmm2, %xmm0, %xmm1, %xmm0
; NoVLX-NEXT:    retq
  %y = load <4 x i32>, <4 x i32>* %yp, align 4
  %mask = icmp eq <4 x i32> %x, %y
  %max = select <4 x i1> %mask, <4 x i32> %x, <4 x i32> %x1
  ret <4 x i32> %max
}

define <4 x i32> @test128_5b(<4 x i32> %x, <4 x i32> %x1, <4 x i32>* %yp) nounwind {
; VLX-LABEL: test128_5b:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpeqd (%rdi), %xmm0, %k1
; VLX-NEXT:    vpblendmd %xmm0, %xmm1, %xmm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test128_5b:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    vpcmpeqd (%rdi), %xmm0, %xmm2
; NoVLX-NEXT:    vblendvps %xmm2, %xmm0, %xmm1, %xmm0
; NoVLX-NEXT:    retq
  %y = load <4 x i32>, <4 x i32>* %yp, align 4
  %mask = icmp eq <4 x i32> %y, %x
  %max = select <4 x i1> %mask, <4 x i32> %x, <4 x i32> %x1
  ret <4 x i32> %max
}

define <4 x i32> @test128_6(<4 x i32> %x, <4 x i32> %x1, <4 x i32>* %y.ptr) nounwind {
; VLX-LABEL: test128_6:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpgtd (%rdi), %xmm0, %k1
; VLX-NEXT:    vpblendmd %xmm0, %xmm1, %xmm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test128_6:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    vpcmpgtd (%rdi), %xmm0, %xmm2
; NoVLX-NEXT:    vblendvps %xmm2, %xmm0, %xmm1, %xmm0
; NoVLX-NEXT:    retq
  %y = load <4 x i32>, <4 x i32>* %y.ptr, align 4
  %mask = icmp sgt <4 x i32> %x, %y
  %max = select <4 x i1> %mask, <4 x i32> %x, <4 x i32> %x1
  ret <4 x i32> %max
}

define <4 x i32> @test128_6b(<4 x i32> %x, <4 x i32> %x1, <4 x i32>* %y.ptr) nounwind {
; VLX-LABEL: test128_6b:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpgtd (%rdi), %xmm0, %k1
; VLX-NEXT:    vpblendmd %xmm0, %xmm1, %xmm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test128_6b:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    vpcmpgtd (%rdi), %xmm0, %xmm2
; NoVLX-NEXT:    vblendvps %xmm2, %xmm0, %xmm1, %xmm0
; NoVLX-NEXT:    retq
  %y = load <4 x i32>, <4 x i32>* %y.ptr, align 4
  %mask = icmp slt <4 x i32> %y, %x
  %max = select <4 x i1> %mask, <4 x i32> %x, <4 x i32> %x1
  ret <4 x i32> %max
}

define <4 x i32> @test128_7(<4 x i32> %x, <4 x i32> %x1, <4 x i32>* %y.ptr) nounwind {
; VLX-LABEL: test128_7:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpled (%rdi), %xmm0, %k1
; VLX-NEXT:    vpblendmd %xmm0, %xmm1, %xmm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test128_7:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    vpcmpgtd (%rdi), %xmm0, %xmm2
; NoVLX-NEXT:    vpcmpeqd %xmm3, %xmm3, %xmm3
; NoVLX-NEXT:    vpxor %xmm3, %xmm2, %xmm2
; NoVLX-NEXT:    vblendvps %xmm2, %xmm0, %xmm1, %xmm0
; NoVLX-NEXT:    retq
  %y = load <4 x i32>, <4 x i32>* %y.ptr, align 4
  %mask = icmp sle <4 x i32> %x, %y
  %max = select <4 x i1> %mask, <4 x i32> %x, <4 x i32> %x1
  ret <4 x i32> %max
}

define <4 x i32> @test128_7b(<4 x i32> %x, <4 x i32> %x1, <4 x i32>* %y.ptr) nounwind {
; VLX-LABEL: test128_7b:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpled (%rdi), %xmm0, %k1
; VLX-NEXT:    vpblendmd %xmm0, %xmm1, %xmm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test128_7b:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    vpcmpgtd (%rdi), %xmm0, %xmm2
; NoVLX-NEXT:    vpcmpeqd %xmm3, %xmm3, %xmm3
; NoVLX-NEXT:    vpxor %xmm3, %xmm2, %xmm2
; NoVLX-NEXT:    vblendvps %xmm2, %xmm0, %xmm1, %xmm0
; NoVLX-NEXT:    retq
  %y = load <4 x i32>, <4 x i32>* %y.ptr, align 4
  %mask = icmp sge <4 x i32> %y, %x
  %max = select <4 x i1> %mask, <4 x i32> %x, <4 x i32> %x1
  ret <4 x i32> %max
}

define <4 x i32> @test128_8(<4 x i32> %x, <4 x i32> %x1, <4 x i32>* %y.ptr) nounwind {
; VLX-LABEL: test128_8:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpleud (%rdi), %xmm0, %k1
; VLX-NEXT:    vpblendmd %xmm0, %xmm1, %xmm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test128_8:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    vpminud (%rdi), %xmm0, %xmm2
; NoVLX-NEXT:    vpcmpeqd %xmm2, %xmm0, %xmm2
; NoVLX-NEXT:    vblendvps %xmm2, %xmm0, %xmm1, %xmm0
; NoVLX-NEXT:    retq
  %y = load <4 x i32>, <4 x i32>* %y.ptr, align 4
  %mask = icmp ule <4 x i32> %x, %y
  %max = select <4 x i1> %mask, <4 x i32> %x, <4 x i32> %x1
  ret <4 x i32> %max
}

define <4 x i32> @test128_8b(<4 x i32> %x, <4 x i32> %x1, <4 x i32>* %y.ptr) nounwind {
; VLX-LABEL: test128_8b:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpleud (%rdi), %xmm0, %k1
; VLX-NEXT:    vpblendmd %xmm0, %xmm1, %xmm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test128_8b:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    vmovdqu (%rdi), %xmm2
; NoVLX-NEXT:    vpmaxud %xmm0, %xmm2, %xmm3
; NoVLX-NEXT:    vpcmpeqd %xmm3, %xmm2, %xmm2
; NoVLX-NEXT:    vblendvps %xmm2, %xmm0, %xmm1, %xmm0
; NoVLX-NEXT:    retq
  %y = load <4 x i32>, <4 x i32>* %y.ptr, align 4
  %mask = icmp uge <4 x i32> %y, %x
  %max = select <4 x i1> %mask, <4 x i32> %x, <4 x i32> %x1
  ret <4 x i32> %max
}

define <4 x i32> @test128_9(<4 x i32> %x, <4 x i32> %y, <4 x i32> %x1, <4 x i32> %y1) nounwind {
; VLX-LABEL: test128_9:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpeqd %xmm1, %xmm0, %k1
; VLX-NEXT:    vpcmpeqd %xmm3, %xmm2, %k1 {%k1}
; VLX-NEXT:    vpblendmd %xmm0, %xmm1, %xmm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test128_9:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    vpcmpeqd %xmm3, %xmm2, %xmm2
; NoVLX-NEXT:    vpcmpeqd %xmm1, %xmm0, %xmm3
; NoVLX-NEXT:    vpand %xmm2, %xmm3, %xmm2
; NoVLX-NEXT:    vblendvps %xmm2, %xmm0, %xmm1, %xmm0
; NoVLX-NEXT:    retq
  %mask1 = icmp eq <4 x i32> %x1, %y1
  %mask0 = icmp eq <4 x i32> %x, %y
  %mask = select <4 x i1> %mask0, <4 x i1> %mask1, <4 x i1> zeroinitializer
  %max = select <4 x i1> %mask, <4 x i32> %x, <4 x i32> %y
  ret <4 x i32> %max
}

define <2 x i64> @test128_10(<2 x i64> %x, <2 x i64> %y, <2 x i64> %x1, <2 x i64> %y1) nounwind {
; VLX-LABEL: test128_10:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpleq %xmm1, %xmm0, %k1
; VLX-NEXT:    vpcmpleq %xmm2, %xmm3, %k1 {%k1}
; VLX-NEXT:    vpblendmq %xmm0, %xmm2, %xmm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test128_10:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    vpcmpgtq %xmm2, %xmm3, %xmm3
; NoVLX-NEXT:    vpcmpeqd %xmm4, %xmm4, %xmm4
; NoVLX-NEXT:    vpxor %xmm4, %xmm3, %xmm3
; NoVLX-NEXT:    vpcmpgtq %xmm1, %xmm0, %xmm1
; NoVLX-NEXT:    vpandn %xmm3, %xmm1, %xmm1
; NoVLX-NEXT:    vblendvpd %xmm1, %xmm0, %xmm2, %xmm0
; NoVLX-NEXT:    retq
  %mask1 = icmp sge <2 x i64> %x1, %y1
  %mask0 = icmp sle <2 x i64> %x, %y
  %mask = select <2 x i1> %mask0, <2 x i1> %mask1, <2 x i1> zeroinitializer
  %max = select <2 x i1> %mask, <2 x i64> %x, <2 x i64> %x1
  ret <2 x i64> %max
}

define <2 x i64> @test128_11(<2 x i64> %x, <2 x i64>* %y.ptr, <2 x i64> %x1, <2 x i64> %y1) nounwind {
; VLX-LABEL: test128_11:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpgtq %xmm2, %xmm1, %k1
; VLX-NEXT:    vpcmpgtq (%rdi), %xmm0, %k1 {%k1}
; VLX-NEXT:    vpblendmq %xmm0, %xmm1, %xmm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test128_11:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    vpcmpgtq (%rdi), %xmm0, %xmm3
; NoVLX-NEXT:    vpcmpgtq %xmm2, %xmm1, %xmm2
; NoVLX-NEXT:    vpand %xmm2, %xmm3, %xmm2
; NoVLX-NEXT:    vblendvpd %xmm2, %xmm0, %xmm1, %xmm0
; NoVLX-NEXT:    retq
  %mask1 = icmp sgt <2 x i64> %x1, %y1
  %y = load <2 x i64>, <2 x i64>* %y.ptr, align 4
  %mask0 = icmp sgt <2 x i64> %x, %y
  %mask = select <2 x i1> %mask0, <2 x i1> %mask1, <2 x i1> zeroinitializer
  %max = select <2 x i1> %mask, <2 x i64> %x, <2 x i64> %x1
  ret <2 x i64> %max
}

define <4 x i32> @test128_12(<4 x i32> %x, <4 x i32>* %y.ptr, <4 x i32> %x1, <4 x i32> %y1) nounwind {
; VLX-LABEL: test128_12:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpled %xmm1, %xmm2, %k1
; VLX-NEXT:    vpcmpleud (%rdi), %xmm0, %k1 {%k1}
; VLX-NEXT:    vpblendmd %xmm0, %xmm1, %xmm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test128_12:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    vpcmpgtd %xmm1, %xmm2, %xmm2
; NoVLX-NEXT:    vpminud (%rdi), %xmm0, %xmm3
; NoVLX-NEXT:    vpcmpeqd %xmm3, %xmm0, %xmm3
; NoVLX-NEXT:    vpandn %xmm3, %xmm2, %xmm2
; NoVLX-NEXT:    vblendvps %xmm2, %xmm0, %xmm1, %xmm0
; NoVLX-NEXT:    retq
  %mask1 = icmp sge <4 x i32> %x1, %y1
  %y = load <4 x i32>, <4 x i32>* %y.ptr, align 4
  %mask0 = icmp ule <4 x i32> %x, %y
  %mask = select <4 x i1> %mask0, <4 x i1> %mask1, <4 x i1> zeroinitializer
  %max = select <4 x i1> %mask, <4 x i32> %x, <4 x i32> %x1
  ret <4 x i32> %max
}

define <2 x i64> @test128_13(<2 x i64> %x, <2 x i64> %x1, i64* %yb.ptr) nounwind {
; VLX-LABEL: test128_13:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpeqq (%rdi){1to2}, %xmm0, %k1
; VLX-NEXT:    vpblendmq %xmm0, %xmm1, %xmm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test128_13:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    vpbroadcastq (%rdi), %xmm2
; NoVLX-NEXT:    vpcmpeqq %xmm2, %xmm0, %xmm2
; NoVLX-NEXT:    vblendvpd %xmm2, %xmm0, %xmm1, %xmm0
; NoVLX-NEXT:    retq
  %yb = load i64, i64* %yb.ptr, align 4
  %y.0 = insertelement <2 x i64> undef, i64 %yb, i32 0
  %y = insertelement <2 x i64> %y.0, i64 %yb, i32 1
  %mask = icmp eq <2 x i64> %x, %y
  %max = select <2 x i1> %mask, <2 x i64> %x, <2 x i64> %x1
  ret <2 x i64> %max
}

define <4 x i32> @test128_14(<4 x i32> %x, i32* %yb.ptr, <4 x i32> %x1) nounwind {
; VLX-LABEL: test128_14:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpled (%rdi){1to4}, %xmm0, %k1
; VLX-NEXT:    vpblendmd %xmm0, %xmm1, %xmm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test128_14:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    vpbroadcastd (%rdi), %xmm2
; NoVLX-NEXT:    vpcmpgtd %xmm2, %xmm0, %xmm2
; NoVLX-NEXT:    vpcmpeqd %xmm3, %xmm3, %xmm3
; NoVLX-NEXT:    vpxor %xmm3, %xmm2, %xmm2
; NoVLX-NEXT:    vblendvps %xmm2, %xmm0, %xmm1, %xmm0
; NoVLX-NEXT:    retq
  %yb = load i32, i32* %yb.ptr, align 4
  %y.0 = insertelement <4 x i32> undef, i32 %yb, i32 0
  %y = shufflevector <4 x i32> %y.0, <4 x i32> undef, <4 x i32> zeroinitializer
  %mask = icmp sle <4 x i32> %x, %y
  %max = select <4 x i1> %mask, <4 x i32> %x, <4 x i32> %x1
  ret <4 x i32> %max
}

define <4 x i32> @test128_15(<4 x i32> %x, i32* %yb.ptr, <4 x i32> %x1, <4 x i32> %y1) nounwind {
; VLX-LABEL: test128_15:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpled %xmm1, %xmm2, %k1
; VLX-NEXT:    vpcmpgtd (%rdi){1to4}, %xmm0, %k1 {%k1}
; VLX-NEXT:    vpblendmd %xmm0, %xmm1, %xmm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test128_15:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    vpcmpgtd %xmm1, %xmm2, %xmm2
; NoVLX-NEXT:    vpbroadcastd (%rdi), %xmm3
; NoVLX-NEXT:    vpcmpgtd %xmm3, %xmm0, %xmm3
; NoVLX-NEXT:    vpandn %xmm3, %xmm2, %xmm2
; NoVLX-NEXT:    vblendvps %xmm2, %xmm0, %xmm1, %xmm0
; NoVLX-NEXT:    retq
  %mask1 = icmp sge <4 x i32> %x1, %y1
  %yb = load i32, i32* %yb.ptr, align 4
  %y.0 = insertelement <4 x i32> undef, i32 %yb, i32 0
  %y = shufflevector <4 x i32> %y.0, <4 x i32> undef, <4 x i32> zeroinitializer
  %mask0 = icmp sgt <4 x i32> %x, %y
  %mask = select <4 x i1> %mask0, <4 x i1> %mask1, <4 x i1> zeroinitializer
  %max = select <4 x i1> %mask, <4 x i32> %x, <4 x i32> %x1
  ret <4 x i32> %max
}

define <2 x i64> @test128_16(<2 x i64> %x, i64* %yb.ptr, <2 x i64> %x1, <2 x i64> %y1) nounwind {
; VLX-LABEL: test128_16:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpleq %xmm1, %xmm2, %k1
; VLX-NEXT:    vpcmpgtq (%rdi){1to2}, %xmm0, %k1 {%k1}
; VLX-NEXT:    vpblendmq %xmm0, %xmm1, %xmm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test128_16:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    vpcmpgtq %xmm1, %xmm2, %xmm2
; NoVLX-NEXT:    vpbroadcastq (%rdi), %xmm3
; NoVLX-NEXT:    vpcmpgtq %xmm3, %xmm0, %xmm3
; NoVLX-NEXT:    vpandn %xmm3, %xmm2, %xmm2
; NoVLX-NEXT:    vblendvpd %xmm2, %xmm0, %xmm1, %xmm0
; NoVLX-NEXT:    retq
  %mask1 = icmp sge <2 x i64> %x1, %y1
  %yb = load i64, i64* %yb.ptr, align 4
  %y.0 = insertelement <2 x i64> undef, i64 %yb, i32 0
  %y = insertelement <2 x i64> %y.0, i64 %yb, i32 1
  %mask0 = icmp sgt <2 x i64> %x, %y
  %mask = select <2 x i1> %mask0, <2 x i1> %mask1, <2 x i1> zeroinitializer
  %max = select <2 x i1> %mask, <2 x i64> %x, <2 x i64> %x1
  ret <2 x i64> %max
}

define <4 x i32> @test128_17(<4 x i32> %x, <4 x i32> %x1, <4 x i32>* %y.ptr) nounwind {
; VLX-LABEL: test128_17:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpneqd (%rdi), %xmm0, %k1
; VLX-NEXT:    vpblendmd %xmm0, %xmm1, %xmm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test128_17:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    vpcmpeqd (%rdi), %xmm0, %xmm2
; NoVLX-NEXT:    vpcmpeqd %xmm3, %xmm3, %xmm3
; NoVLX-NEXT:    vpxor %xmm3, %xmm2, %xmm2
; NoVLX-NEXT:    vblendvps %xmm2, %xmm0, %xmm1, %xmm0
; NoVLX-NEXT:    retq
  %y = load <4 x i32>, <4 x i32>* %y.ptr, align 4
  %mask = icmp ne <4 x i32> %x, %y
  %max = select <4 x i1> %mask, <4 x i32> %x, <4 x i32> %x1
  ret <4 x i32> %max
}

define <4 x i32> @test128_18(<4 x i32> %x, <4 x i32> %x1, <4 x i32>* %y.ptr) nounwind {
; VLX-LABEL: test128_18:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpneqd (%rdi), %xmm0, %k1
; VLX-NEXT:    vpblendmd %xmm0, %xmm1, %xmm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test128_18:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    vpcmpeqd (%rdi), %xmm0, %xmm2
; NoVLX-NEXT:    vpcmpeqd %xmm3, %xmm3, %xmm3
; NoVLX-NEXT:    vpxor %xmm3, %xmm2, %xmm2
; NoVLX-NEXT:    vblendvps %xmm2, %xmm0, %xmm1, %xmm0
; NoVLX-NEXT:    retq
  %y = load <4 x i32>, <4 x i32>* %y.ptr, align 4
  %mask = icmp ne <4 x i32> %y, %x
  %max = select <4 x i1> %mask, <4 x i32> %x, <4 x i32> %x1
  ret <4 x i32> %max
}

define <4 x i32> @test128_19(<4 x i32> %x, <4 x i32> %x1, <4 x i32>* %y.ptr) nounwind {
; VLX-LABEL: test128_19:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpnltud (%rdi), %xmm0, %k1
; VLX-NEXT:    vpblendmd %xmm0, %xmm1, %xmm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test128_19:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    vpmaxud (%rdi), %xmm0, %xmm2
; NoVLX-NEXT:    vpcmpeqd %xmm2, %xmm0, %xmm2
; NoVLX-NEXT:    vblendvps %xmm2, %xmm0, %xmm1, %xmm0
; NoVLX-NEXT:    retq
  %y = load <4 x i32>, <4 x i32>* %y.ptr, align 4
  %mask = icmp uge <4 x i32> %x, %y
  %max = select <4 x i1> %mask, <4 x i32> %x, <4 x i32> %x1
  ret <4 x i32> %max
}

define <4 x i32> @test128_20(<4 x i32> %x, <4 x i32> %x1, <4 x i32>* %y.ptr) nounwind {
; VLX-LABEL: test128_20:
; VLX:       # BB#0:
; VLX-NEXT:    vpcmpleud (%rdi), %xmm0, %k1
; VLX-NEXT:    vpblendmd %xmm0, %xmm1, %xmm0 {%k1}
; VLX-NEXT:    retq
;
; NoVLX-LABEL: test128_20:
; NoVLX:       # BB#0:
; NoVLX-NEXT:    vmovdqu (%rdi), %xmm2
; NoVLX-NEXT:    vpmaxud %xmm0, %xmm2, %xmm3
; NoVLX-NEXT:    vpcmpeqd %xmm3, %xmm2, %xmm2
; NoVLX-NEXT:    vblendvps %xmm2, %xmm0, %xmm1, %xmm0
; NoVLX-NEXT:    retq
  %y = load <4 x i32>, <4 x i32>* %y.ptr, align 4
  %mask = icmp uge <4 x i32> %y, %x
  %max = select <4 x i1> %mask, <4 x i32> %x, <4 x i32> %x1
  ret <4 x i32> %max
}
