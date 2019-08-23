; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=thumbv8.1m.main-arm-none-eabi -mattr=+mve,+fullfp16 -verify-machineinstrs %s -o - | FileCheck %s --check-prefix=CHECK --check-prefix=CHECK-MVE
; RUN: llc -mtriple=thumbv8.1m.main-arm-none-eabi -mattr=+mve.fp -verify-machineinstrs %s -o - | FileCheck %s --check-prefix=CHECK --check-prefix=CHECK-MVEFP

define arm_aapcs_vfpcc <4 x i32> @udiv_i32(<4 x i32> %in1, <4 x i32> %in2) {
; CHECK-LABEL: udiv_i32:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmov r0, s4
; CHECK-NEXT:    vmov r1, s0
; CHECK-NEXT:    udiv r0, r1, r0
; CHECK-NEXT:    vmov r1, s5
; CHECK-NEXT:    vmov r2, s1
; CHECK-NEXT:    vmov.32 q2[0], r0
; CHECK-NEXT:    udiv r1, r2, r1
; CHECK-NEXT:    vmov r0, s6
; CHECK-NEXT:    vmov.32 q2[1], r1
; CHECK-NEXT:    vmov r1, s2
; CHECK-NEXT:    udiv r0, r1, r0
; CHECK-NEXT:    vmov r1, s3
; CHECK-NEXT:    vmov.32 q2[2], r0
; CHECK-NEXT:    vmov r0, s7
; CHECK-NEXT:    udiv r0, r1, r0
; CHECK-NEXT:    vmov.32 q2[3], r0
; CHECK-NEXT:    vmov q0, q2
; CHECK-NEXT:    bx lr
entry:
  %out = udiv <4 x i32> %in1, %in2
  ret <4 x i32> %out
}

define arm_aapcs_vfpcc <4 x i32> @sdiv_i32(<4 x i32> %in1, <4 x i32> %in2) {
; CHECK-LABEL: sdiv_i32:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmov r0, s4
; CHECK-NEXT:    vmov r1, s0
; CHECK-NEXT:    sdiv r0, r1, r0
; CHECK-NEXT:    vmov r1, s5
; CHECK-NEXT:    vmov r2, s1
; CHECK-NEXT:    vmov.32 q2[0], r0
; CHECK-NEXT:    sdiv r1, r2, r1
; CHECK-NEXT:    vmov r0, s6
; CHECK-NEXT:    vmov.32 q2[1], r1
; CHECK-NEXT:    vmov r1, s2
; CHECK-NEXT:    sdiv r0, r1, r0
; CHECK-NEXT:    vmov r1, s3
; CHECK-NEXT:    vmov.32 q2[2], r0
; CHECK-NEXT:    vmov r0, s7
; CHECK-NEXT:    sdiv r0, r1, r0
; CHECK-NEXT:    vmov.32 q2[3], r0
; CHECK-NEXT:    vmov q0, q2
; CHECK-NEXT:    bx lr
entry:
  %out = sdiv <4 x i32> %in1, %in2
  ret <4 x i32> %out
}

define arm_aapcs_vfpcc <4 x i32> @urem_i32(<4 x i32> %in1, <4 x i32> %in2) {
; CHECK-LABEL: urem_i32:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r7, lr}
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    vmov r0, s4
; CHECK-NEXT:    vmov r1, s0
; CHECK-NEXT:    udiv r2, r1, r0
; CHECK-NEXT:    mls r12, r2, r0, r1
; CHECK-NEXT:    vmov r1, s5
; CHECK-NEXT:    vmov r2, s1
; CHECK-NEXT:    udiv r3, r2, r1
; CHECK-NEXT:    mls lr, r3, r1, r2
; CHECK-NEXT:    vmov r2, s6
; CHECK-NEXT:    vmov r3, s2
; CHECK-NEXT:    udiv r0, r3, r2
; CHECK-NEXT:    mls r0, r0, r2, r3
; CHECK-NEXT:    vmov r2, s7
; CHECK-NEXT:    vmov r3, s3
; CHECK-NEXT:    vmov.32 q0[0], r12
; CHECK-NEXT:    udiv r1, r3, r2
; CHECK-NEXT:    vmov.32 q0[1], lr
; CHECK-NEXT:    vmov.32 q0[2], r0
; CHECK-NEXT:    mls r1, r1, r2, r3
; CHECK-NEXT:    vmov.32 q0[3], r1
; CHECK-NEXT:    pop {r7, pc}
entry:
  %out = urem <4 x i32> %in1, %in2
  ret <4 x i32> %out
}

define arm_aapcs_vfpcc <4 x i32> @srem_i32(<4 x i32> %in1, <4 x i32> %in2) {
; CHECK-LABEL: srem_i32:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r7, lr}
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    vmov r0, s4
; CHECK-NEXT:    vmov r1, s0
; CHECK-NEXT:    sdiv r2, r1, r0
; CHECK-NEXT:    mls r12, r2, r0, r1
; CHECK-NEXT:    vmov r1, s5
; CHECK-NEXT:    vmov r2, s1
; CHECK-NEXT:    sdiv r3, r2, r1
; CHECK-NEXT:    mls lr, r3, r1, r2
; CHECK-NEXT:    vmov r2, s6
; CHECK-NEXT:    vmov r3, s2
; CHECK-NEXT:    sdiv r0, r3, r2
; CHECK-NEXT:    mls r0, r0, r2, r3
; CHECK-NEXT:    vmov r2, s7
; CHECK-NEXT:    vmov r3, s3
; CHECK-NEXT:    vmov.32 q0[0], r12
; CHECK-NEXT:    sdiv r1, r3, r2
; CHECK-NEXT:    vmov.32 q0[1], lr
; CHECK-NEXT:    vmov.32 q0[2], r0
; CHECK-NEXT:    mls r1, r1, r2, r3
; CHECK-NEXT:    vmov.32 q0[3], r1
; CHECK-NEXT:    pop {r7, pc}
entry:
  %out = srem <4 x i32> %in1, %in2
  ret <4 x i32> %out
}


define arm_aapcs_vfpcc <8 x i16> @udiv_i16(<8 x i16> %in1, <8 x i16> %in2) {
; CHECK-LABEL: udiv_i16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmov.u16 r0, q1[0]
; CHECK-NEXT:    vmov.u16 r1, q0[0]
; CHECK-NEXT:    udiv r0, r1, r0
; CHECK-NEXT:    vmov.u16 r1, q1[1]
; CHECK-NEXT:    vmov.u16 r2, q0[1]
; CHECK-NEXT:    vmov.16 q2[0], r0
; CHECK-NEXT:    udiv r1, r2, r1
; CHECK-NEXT:    vmov.u16 r0, q1[2]
; CHECK-NEXT:    vmov.16 q2[1], r1
; CHECK-NEXT:    vmov.u16 r1, q0[2]
; CHECK-NEXT:    udiv r0, r1, r0
; CHECK-NEXT:    vmov.u16 r1, q0[3]
; CHECK-NEXT:    vmov.16 q2[2], r0
; CHECK-NEXT:    vmov.u16 r0, q1[3]
; CHECK-NEXT:    udiv r0, r1, r0
; CHECK-NEXT:    vmov.u16 r1, q0[4]
; CHECK-NEXT:    vmov.16 q2[3], r0
; CHECK-NEXT:    vmov.u16 r0, q1[4]
; CHECK-NEXT:    udiv r0, r1, r0
; CHECK-NEXT:    vmov.u16 r1, q0[5]
; CHECK-NEXT:    vmov.16 q2[4], r0
; CHECK-NEXT:    vmov.u16 r0, q1[5]
; CHECK-NEXT:    udiv r0, r1, r0
; CHECK-NEXT:    vmov.u16 r1, q0[6]
; CHECK-NEXT:    vmov.16 q2[5], r0
; CHECK-NEXT:    vmov.u16 r0, q1[6]
; CHECK-NEXT:    udiv r0, r1, r0
; CHECK-NEXT:    vmov.u16 r1, q0[7]
; CHECK-NEXT:    vmov.16 q2[6], r0
; CHECK-NEXT:    vmov.u16 r0, q1[7]
; CHECK-NEXT:    udiv r0, r1, r0
; CHECK-NEXT:    vmov.16 q2[7], r0
; CHECK-NEXT:    vmov q0, q2
; CHECK-NEXT:    bx lr
entry:
  %out = udiv <8 x i16> %in1, %in2
  ret <8 x i16> %out
}

define arm_aapcs_vfpcc <8 x i16> @sdiv_i16(<8 x i16> %in1, <8 x i16> %in2) {
; CHECK-LABEL: sdiv_i16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r4, r5, r6, lr}
; CHECK-NEXT:    push {r4, r5, r6, lr}
; CHECK-NEXT:    vmov.u16 r0, q1[3]
; CHECK-NEXT:    vmov.u16 r1, q0[3]
; CHECK-NEXT:    sxth r0, r0
; CHECK-NEXT:    sxth r1, r1
; CHECK-NEXT:    vmov.u16 r2, q0[2]
; CHECK-NEXT:    sdiv r12, r1, r0
; CHECK-NEXT:    vmov.u16 r1, q1[2]
; CHECK-NEXT:    sxth r2, r2
; CHECK-NEXT:    sxth r1, r1
; CHECK-NEXT:    vmov.u16 r4, q1[6]
; CHECK-NEXT:    sdiv r3, r2, r1
; CHECK-NEXT:    vmov.u16 r1, q1[1]
; CHECK-NEXT:    vmov.u16 r2, q0[1]
; CHECK-NEXT:    sxth r1, r1
; CHECK-NEXT:    sxth r2, r2
; CHECK-NEXT:    vmov.u16 r5, q0[6]
; CHECK-NEXT:    sdiv r0, r2, r1
; CHECK-NEXT:    vmov.u16 r1, q1[0]
; CHECK-NEXT:    vmov.u16 r2, q0[0]
; CHECK-NEXT:    sxth r1, r1
; CHECK-NEXT:    sxth r2, r2
; CHECK-NEXT:    sxth r4, r4
; CHECK-NEXT:    sdiv r1, r2, r1
; CHECK-NEXT:    vmov.u16 r2, q1[7]
; CHECK-NEXT:    vmov.16 q2[0], r1
; CHECK-NEXT:    sxth.w lr, r2
; CHECK-NEXT:    vmov.16 q2[1], r0
; CHECK-NEXT:    vmov.u16 r2, q0[7]
; CHECK-NEXT:    vmov.16 q2[2], r3
; CHECK-NEXT:    vmov.u16 r3, q1[4]
; CHECK-NEXT:    sxth r6, r2
; CHECK-NEXT:    vmov.u16 r2, q0[4]
; CHECK-NEXT:    vmov.u16 r1, q1[5]
; CHECK-NEXT:    vmov.u16 r0, q0[5]
; CHECK-NEXT:    sxth r3, r3
; CHECK-NEXT:    sxth r2, r2
; CHECK-NEXT:    sxth r1, r1
; CHECK-NEXT:    sxth r0, r0
; CHECK-NEXT:    vmov.16 q2[3], r12
; CHECK-NEXT:    sdiv r2, r2, r3
; CHECK-NEXT:    sxth r5, r5
; CHECK-NEXT:    vmov.16 q2[4], r2
; CHECK-NEXT:    sdiv r0, r0, r1
; CHECK-NEXT:    vmov.16 q2[5], r0
; CHECK-NEXT:    sdiv r0, r5, r4
; CHECK-NEXT:    vmov.16 q2[6], r0
; CHECK-NEXT:    sdiv r0, r6, lr
; CHECK-NEXT:    vmov.16 q2[7], r0
; CHECK-NEXT:    vmov q0, q2
; CHECK-NEXT:    pop {r4, r5, r6, pc}
entry:
  %out = sdiv <8 x i16> %in1, %in2
  ret <8 x i16> %out
}

define arm_aapcs_vfpcc <8 x i16> @urem_i16(<8 x i16> %in1, <8 x i16> %in2) {
; CHECK-LABEL: urem_i16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r4, r5, r6, r7, lr}
; CHECK-NEXT:    push {r4, r5, r6, r7, lr}
; CHECK-NEXT:    vmov.u16 r0, q1[6]
; CHECK-NEXT:    vmov.u16 r1, q0[6]
; CHECK-NEXT:    udiv r2, r1, r0
; CHECK-NEXT:    mls r12, r2, r0, r1
; CHECK-NEXT:    vmov.u16 r1, q1[7]
; CHECK-NEXT:    vmov.u16 r2, q0[7]
; CHECK-NEXT:    udiv r3, r2, r1
; CHECK-NEXT:    mls lr, r3, r1, r2
; CHECK-NEXT:    vmov.u16 r2, q1[4]
; CHECK-NEXT:    vmov.u16 r3, q0[4]
; CHECK-NEXT:    udiv r0, r3, r2
; CHECK-NEXT:    mls r2, r0, r2, r3
; CHECK-NEXT:    vmov.u16 r0, q1[5]
; CHECK-NEXT:    vmov.u16 r3, q0[5]
; CHECK-NEXT:    udiv r1, r3, r0
; CHECK-NEXT:    mls r0, r1, r0, r3
; CHECK-NEXT:    vmov.u16 r1, q1[2]
; CHECK-NEXT:    vmov.u16 r3, q0[2]
; CHECK-NEXT:    udiv r4, r3, r1
; CHECK-NEXT:    mls r1, r4, r1, r3
; CHECK-NEXT:    vmov.u16 r3, q1[3]
; CHECK-NEXT:    vmov.u16 r4, q0[3]
; CHECK-NEXT:    udiv r5, r4, r3
; CHECK-NEXT:    mls r3, r5, r3, r4
; CHECK-NEXT:    vmov.u16 r4, q1[0]
; CHECK-NEXT:    vmov.u16 r5, q0[0]
; CHECK-NEXT:    udiv r6, r5, r4
; CHECK-NEXT:    mls r4, r6, r4, r5
; CHECK-NEXT:    vmov.u16 r6, q0[1]
; CHECK-NEXT:    vmov.u16 r5, q1[1]
; CHECK-NEXT:    udiv r7, r6, r5
; CHECK-NEXT:    vmov.16 q0[0], r4
; CHECK-NEXT:    mls r5, r7, r5, r6
; CHECK-NEXT:    vmov.16 q0[1], r5
; CHECK-NEXT:    vmov.16 q0[2], r1
; CHECK-NEXT:    vmov.16 q0[3], r3
; CHECK-NEXT:    vmov.16 q0[4], r2
; CHECK-NEXT:    vmov.16 q0[5], r0
; CHECK-NEXT:    vmov.16 q0[6], r12
; CHECK-NEXT:    vmov.16 q0[7], lr
; CHECK-NEXT:    pop {r4, r5, r6, r7, pc}
entry:
  %out = urem <8 x i16> %in1, %in2
  ret <8 x i16> %out
}

define arm_aapcs_vfpcc <8 x i16> @srem_i16(<8 x i16> %in1, <8 x i16> %in2) {
; CHECK-LABEL: srem_i16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r4, r5, r6, r7, r8, lr}
; CHECK-NEXT:    push.w {r4, r5, r6, r7, r8, lr}
; CHECK-NEXT:    vmov.u16 r5, q1[6]
; CHECK-NEXT:    vmov.u16 r6, q0[6]
; CHECK-NEXT:    sxth r5, r5
; CHECK-NEXT:    sxth r6, r6
; CHECK-NEXT:    vmov.u16 r0, q1[0]
; CHECK-NEXT:    sdiv r7, r6, r5
; CHECK-NEXT:    vmov.u16 r2, q1[7]
; CHECK-NEXT:    sxth.w r8, r0
; CHECK-NEXT:    vmov.u16 r0, q1[3]
; CHECK-NEXT:    mls r12, r7, r5, r6
; CHECK-NEXT:    vmov.u16 r7, q0[7]
; CHECK-NEXT:    sxth r3, r0
; CHECK-NEXT:    vmov.u16 r0, q1[2]
; CHECK-NEXT:    sxth r2, r2
; CHECK-NEXT:    sxth r7, r7
; CHECK-NEXT:    sxth r4, r0
; CHECK-NEXT:    vmov.u16 r0, q1[5]
; CHECK-NEXT:    sdiv r6, r7, r2
; CHECK-NEXT:    mls lr, r6, r2, r7
; CHECK-NEXT:    vmov.u16 r2, q0[4]
; CHECK-NEXT:    sxth r1, r0
; CHECK-NEXT:    vmov.u16 r0, q1[4]
; CHECK-NEXT:    sxth r0, r0
; CHECK-NEXT:    sxth r2, r2
; CHECK-NEXT:    sdiv r5, r2, r0
; CHECK-NEXT:    vmov.u16 r6, q0[1]
; CHECK-NEXT:    mls r0, r5, r0, r2
; CHECK-NEXT:    vmov.u16 r2, q0[5]
; CHECK-NEXT:    sxth r2, r2
; CHECK-NEXT:    sdiv r5, r2, r1
; CHECK-NEXT:    sxth r6, r6
; CHECK-NEXT:    mls r1, r5, r1, r2
; CHECK-NEXT:    vmov.u16 r2, q0[2]
; CHECK-NEXT:    sxth r2, r2
; CHECK-NEXT:    sdiv r5, r2, r4
; CHECK-NEXT:    mls r2, r5, r4, r2
; CHECK-NEXT:    vmov.u16 r4, q0[3]
; CHECK-NEXT:    sxth r4, r4
; CHECK-NEXT:    sdiv r5, r4, r3
; CHECK-NEXT:    mls r3, r5, r3, r4
; CHECK-NEXT:    vmov.u16 r4, q0[0]
; CHECK-NEXT:    sxth r4, r4
; CHECK-NEXT:    sdiv r5, r4, r8
; CHECK-NEXT:    mls r4, r5, r8, r4
; CHECK-NEXT:    vmov.u16 r5, q1[1]
; CHECK-NEXT:    sxth r5, r5
; CHECK-NEXT:    sdiv r7, r6, r5
; CHECK-NEXT:    vmov.16 q0[0], r4
; CHECK-NEXT:    mls r5, r7, r5, r6
; CHECK-NEXT:    vmov.16 q0[1], r5
; CHECK-NEXT:    vmov.16 q0[2], r2
; CHECK-NEXT:    vmov.16 q0[3], r3
; CHECK-NEXT:    vmov.16 q0[4], r0
; CHECK-NEXT:    vmov.16 q0[5], r1
; CHECK-NEXT:    vmov.16 q0[6], r12
; CHECK-NEXT:    vmov.16 q0[7], lr
; CHECK-NEXT:    pop.w {r4, r5, r6, r7, r8, pc}
entry:
  %out = srem <8 x i16> %in1, %in2
  ret <8 x i16> %out
}


define arm_aapcs_vfpcc <16 x i8> @udiv_i8(<16 x i8> %in1, <16 x i8> %in2) {
; CHECK-LABEL: udiv_i8:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmov.u8 r0, q1[0]
; CHECK-NEXT:    vmov.u8 r1, q0[0]
; CHECK-NEXT:    udiv r0, r1, r0
; CHECK-NEXT:    vmov.u8 r1, q1[1]
; CHECK-NEXT:    vmov.u8 r2, q0[1]
; CHECK-NEXT:    vmov.8 q2[0], r0
; CHECK-NEXT:    udiv r1, r2, r1
; CHECK-NEXT:    vmov.u8 r0, q1[2]
; CHECK-NEXT:    vmov.8 q2[1], r1
; CHECK-NEXT:    vmov.u8 r1, q0[2]
; CHECK-NEXT:    udiv r0, r1, r0
; CHECK-NEXT:    vmov.u8 r1, q0[3]
; CHECK-NEXT:    vmov.8 q2[2], r0
; CHECK-NEXT:    vmov.u8 r0, q1[3]
; CHECK-NEXT:    udiv r0, r1, r0
; CHECK-NEXT:    vmov.u8 r1, q0[4]
; CHECK-NEXT:    vmov.8 q2[3], r0
; CHECK-NEXT:    vmov.u8 r0, q1[4]
; CHECK-NEXT:    udiv r0, r1, r0
; CHECK-NEXT:    vmov.u8 r1, q0[5]
; CHECK-NEXT:    vmov.8 q2[4], r0
; CHECK-NEXT:    vmov.u8 r0, q1[5]
; CHECK-NEXT:    udiv r0, r1, r0
; CHECK-NEXT:    vmov.u8 r1, q0[6]
; CHECK-NEXT:    vmov.8 q2[5], r0
; CHECK-NEXT:    vmov.u8 r0, q1[6]
; CHECK-NEXT:    udiv r0, r1, r0
; CHECK-NEXT:    vmov.u8 r1, q0[7]
; CHECK-NEXT:    vmov.8 q2[6], r0
; CHECK-NEXT:    vmov.u8 r0, q1[7]
; CHECK-NEXT:    udiv r0, r1, r0
; CHECK-NEXT:    vmov.u8 r1, q0[8]
; CHECK-NEXT:    vmov.8 q2[7], r0
; CHECK-NEXT:    vmov.u8 r0, q1[8]
; CHECK-NEXT:    udiv r0, r1, r0
; CHECK-NEXT:    vmov.u8 r1, q0[9]
; CHECK-NEXT:    vmov.8 q2[8], r0
; CHECK-NEXT:    vmov.u8 r0, q1[9]
; CHECK-NEXT:    udiv r0, r1, r0
; CHECK-NEXT:    vmov.u8 r1, q0[10]
; CHECK-NEXT:    vmov.8 q2[9], r0
; CHECK-NEXT:    vmov.u8 r0, q1[10]
; CHECK-NEXT:    udiv r0, r1, r0
; CHECK-NEXT:    vmov.u8 r1, q0[11]
; CHECK-NEXT:    vmov.8 q2[10], r0
; CHECK-NEXT:    vmov.u8 r0, q1[11]
; CHECK-NEXT:    udiv r0, r1, r0
; CHECK-NEXT:    vmov.u8 r1, q0[12]
; CHECK-NEXT:    vmov.8 q2[11], r0
; CHECK-NEXT:    vmov.u8 r0, q1[12]
; CHECK-NEXT:    udiv r0, r1, r0
; CHECK-NEXT:    vmov.u8 r1, q0[13]
; CHECK-NEXT:    vmov.8 q2[12], r0
; CHECK-NEXT:    vmov.u8 r0, q1[13]
; CHECK-NEXT:    udiv r0, r1, r0
; CHECK-NEXT:    vmov.u8 r1, q0[14]
; CHECK-NEXT:    vmov.8 q2[13], r0
; CHECK-NEXT:    vmov.u8 r0, q1[14]
; CHECK-NEXT:    udiv r0, r1, r0
; CHECK-NEXT:    vmov.u8 r1, q0[15]
; CHECK-NEXT:    vmov.8 q2[14], r0
; CHECK-NEXT:    vmov.u8 r0, q1[15]
; CHECK-NEXT:    udiv r0, r1, r0
; CHECK-NEXT:    vmov.8 q2[15], r0
; CHECK-NEXT:    vmov q0, q2
; CHECK-NEXT:    bx lr
entry:
  %out = udiv <16 x i8> %in1, %in2
  ret <16 x i8> %out
}

define arm_aapcs_vfpcc <16 x i8> @sdiv_i8(<16 x i8> %in1, <16 x i8> %in2) {
; CHECK-LABEL: sdiv_i8:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r4, r5, r6, r7, lr}
; CHECK-NEXT:    push {r4, r5, r6, r7, lr}
; CHECK-NEXT:    vmov.u8 r0, q1[1]
; CHECK-NEXT:    vmov.u8 r1, q0[1]
; CHECK-NEXT:    sxtb r0, r0
; CHECK-NEXT:    sxtb r1, r1
; CHECK-NEXT:    vmov.u8 r2, q0[0]
; CHECK-NEXT:    sdiv r0, r1, r0
; CHECK-NEXT:    vmov.u8 r1, q1[0]
; CHECK-NEXT:    sxtb r2, r2
; CHECK-NEXT:    sxtb r1, r1
; CHECK-NEXT:    vmov.u8 r4, q1[3]
; CHECK-NEXT:    sdiv r1, r2, r1
; CHECK-NEXT:    vmov.u8 r5, q0[3]
; CHECK-NEXT:    vmov.8 q2[0], r1
; CHECK-NEXT:    vmov.u8 r1, q1[2]
; CHECK-NEXT:    vmov.8 q2[1], r0
; CHECK-NEXT:    vmov.u8 r0, q0[2]
; CHECK-NEXT:    vmov.u8 r2, q1[11]
; CHECK-NEXT:    vmov.u8 r3, q0[11]
; CHECK-NEXT:    sxtb r1, r1
; CHECK-NEXT:    sxtb r0, r0
; CHECK-NEXT:    sdiv r0, r0, r1
; CHECK-NEXT:    sxtb.w r12, r2
; CHECK-NEXT:    sxtb.w lr, r3
; CHECK-NEXT:    vmov.u8 r2, q1[4]
; CHECK-NEXT:    vmov.u8 r3, q0[4]
; CHECK-NEXT:    sxtb r4, r4
; CHECK-NEXT:    sxtb r5, r5
; CHECK-NEXT:    vmov.8 q2[2], r0
; CHECK-NEXT:    sdiv r0, r5, r4
; CHECK-NEXT:    sxtb r2, r2
; CHECK-NEXT:    sxtb r3, r3
; CHECK-NEXT:    vmov.8 q2[3], r0
; CHECK-NEXT:    sdiv r0, r3, r2
; CHECK-NEXT:    vmov.u8 r1, q0[10]
; CHECK-NEXT:    vmov.8 q2[4], r0
; CHECK-NEXT:    vmov.u8 r0, q1[10]
; CHECK-NEXT:    sxtb r0, r0
; CHECK-NEXT:    sxtb r1, r1
; CHECK-NEXT:    sdiv r12, lr, r12
; CHECK-NEXT:    sdiv lr, r1, r0
; CHECK-NEXT:    vmov.u8 r0, q1[9]
; CHECK-NEXT:    vmov.u8 r1, q0[9]
; CHECK-NEXT:    sxtb r0, r0
; CHECK-NEXT:    sxtb r1, r1
; CHECK-NEXT:    sdiv r2, r1, r0
; CHECK-NEXT:    vmov.u8 r0, q1[8]
; CHECK-NEXT:    vmov.u8 r1, q0[8]
; CHECK-NEXT:    sxtb r0, r0
; CHECK-NEXT:    sxtb r1, r1
; CHECK-NEXT:    vmov.u8 r3, q0[7]
; CHECK-NEXT:    sdiv r1, r1, r0
; CHECK-NEXT:    vmov.u8 r0, q1[7]
; CHECK-NEXT:    sxtb r0, r0
; CHECK-NEXT:    sxtb r3, r3
; CHECK-NEXT:    sdiv r4, r3, r0
; CHECK-NEXT:    vmov.u8 r0, q1[6]
; CHECK-NEXT:    vmov.u8 r3, q0[6]
; CHECK-NEXT:    sxtb r0, r0
; CHECK-NEXT:    sxtb r3, r3
; CHECK-NEXT:    vmov.u8 r6, q0[12]
; CHECK-NEXT:    sdiv r5, r3, r0
; CHECK-NEXT:    vmov.u8 r0, q1[5]
; CHECK-NEXT:    vmov.u8 r3, q0[5]
; CHECK-NEXT:    sxtb r0, r0
; CHECK-NEXT:    sxtb r3, r3
; CHECK-NEXT:    sxtb r6, r6
; CHECK-NEXT:    sdiv r0, r3, r0
; CHECK-NEXT:    vmov.u8 r3, q1[15]
; CHECK-NEXT:    vmov.8 q2[5], r0
; CHECK-NEXT:    sxtb r7, r3
; CHECK-NEXT:    vmov.8 q2[6], r5
; CHECK-NEXT:    vmov.u8 r3, q1[12]
; CHECK-NEXT:    vmov.8 q2[7], r4
; CHECK-NEXT:    sxtb r3, r3
; CHECK-NEXT:    vmov.8 q2[8], r1
; CHECK-NEXT:    vmov.u8 r1, q1[13]
; CHECK-NEXT:    vmov.8 q2[9], r2
; CHECK-NEXT:    vmov.u8 r2, q0[13]
; CHECK-NEXT:    vmov.8 q2[10], lr
; CHECK-NEXT:    vmov.u8 r5, q1[14]
; CHECK-NEXT:    vmov.u8 r4, q0[14]
; CHECK-NEXT:    sxtb r1, r1
; CHECK-NEXT:    sxtb r2, r2
; CHECK-NEXT:    vmov.8 q2[11], r12
; CHECK-NEXT:    sdiv r3, r6, r3
; CHECK-NEXT:    vmov.u8 r0, q0[15]
; CHECK-NEXT:    sxtb r5, r5
; CHECK-NEXT:    sxtb r4, r4
; CHECK-NEXT:    vmov.8 q2[12], r3
; CHECK-NEXT:    sdiv r1, r2, r1
; CHECK-NEXT:    sxtb r0, r0
; CHECK-NEXT:    vmov.8 q2[13], r1
; CHECK-NEXT:    sdiv r1, r4, r5
; CHECK-NEXT:    sdiv r0, r0, r7
; CHECK-NEXT:    vmov.8 q2[14], r1
; CHECK-NEXT:    vmov.8 q2[15], r0
; CHECK-NEXT:    vmov q0, q2
; CHECK-NEXT:    pop {r4, r5, r6, r7, pc}
entry:
  %out = sdiv <16 x i8> %in1, %in2
  ret <16 x i8> %out
}

define arm_aapcs_vfpcc <16 x i8> @urem_i8(<16 x i8> %in1, <16 x i8> %in2) {
; CHECK-LABEL: urem_i8:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r4, r5, r6, r7, r8, lr}
; CHECK-NEXT:    push.w {r4, r5, r6, r7, r8, lr}
; CHECK-NEXT:    vmov.u8 r0, q1[14]
; CHECK-NEXT:    vmov.u8 r1, q0[14]
; CHECK-NEXT:    udiv r2, r1, r0
; CHECK-NEXT:    mls r12, r2, r0, r1
; CHECK-NEXT:    vmov.u8 r0, q1[15]
; CHECK-NEXT:    vmov.u8 r1, q0[15]
; CHECK-NEXT:    udiv r2, r1, r0
; CHECK-NEXT:    mls lr, r2, r0, r1
; CHECK-NEXT:    vmov.u8 r0, q1[12]
; CHECK-NEXT:    vmov.u8 r1, q0[12]
; CHECK-NEXT:    udiv r2, r1, r0
; CHECK-NEXT:    mls r8, r2, r0, r1
; CHECK-NEXT:    vmov.u8 r0, q1[13]
; CHECK-NEXT:    vmov.u8 r1, q0[13]
; CHECK-NEXT:    udiv r3, r1, r0
; CHECK-NEXT:    mls r3, r3, r0, r1
; CHECK-NEXT:    vmov.u8 r0, q1[10]
; CHECK-NEXT:    vmov.u8 r1, q0[10]
; CHECK-NEXT:    udiv r4, r1, r0
; CHECK-NEXT:    mls r0, r4, r0, r1
; CHECK-NEXT:    vmov.u8 r1, q1[11]
; CHECK-NEXT:    vmov.u8 r4, q0[11]
; CHECK-NEXT:    udiv r5, r4, r1
; CHECK-NEXT:    mls r1, r5, r1, r4
; CHECK-NEXT:    vmov.u8 r4, q1[8]
; CHECK-NEXT:    vmov.u8 r5, q0[8]
; CHECK-NEXT:    udiv r6, r5, r4
; CHECK-NEXT:    mls r4, r6, r4, r5
; CHECK-NEXT:    vmov.u8 r5, q1[0]
; CHECK-NEXT:    vmov.u8 r6, q0[0]
; CHECK-NEXT:    udiv r7, r6, r5
; CHECK-NEXT:    mls r5, r7, r5, r6
; CHECK-NEXT:    vmov.u8 r6, q1[1]
; CHECK-NEXT:    vmov.u8 r7, q0[1]
; CHECK-NEXT:    udiv r2, r7, r6
; CHECK-NEXT:    vmov.8 q2[0], r5
; CHECK-NEXT:    mls r2, r2, r6, r7
; CHECK-NEXT:    vmov.u8 r5, q0[2]
; CHECK-NEXT:    vmov.8 q2[1], r2
; CHECK-NEXT:    vmov.u8 r2, q1[2]
; CHECK-NEXT:    udiv r6, r5, r2
; CHECK-NEXT:    mls r2, r6, r2, r5
; CHECK-NEXT:    vmov.u8 r5, q0[3]
; CHECK-NEXT:    vmov.8 q2[2], r2
; CHECK-NEXT:    vmov.u8 r2, q1[3]
; CHECK-NEXT:    udiv r6, r5, r2
; CHECK-NEXT:    mls r2, r6, r2, r5
; CHECK-NEXT:    vmov.u8 r5, q0[4]
; CHECK-NEXT:    vmov.8 q2[3], r2
; CHECK-NEXT:    vmov.u8 r2, q1[4]
; CHECK-NEXT:    udiv r6, r5, r2
; CHECK-NEXT:    mls r2, r6, r2, r5
; CHECK-NEXT:    vmov.u8 r5, q0[5]
; CHECK-NEXT:    vmov.8 q2[4], r2
; CHECK-NEXT:    vmov.u8 r2, q1[5]
; CHECK-NEXT:    udiv r6, r5, r2
; CHECK-NEXT:    mls r2, r6, r2, r5
; CHECK-NEXT:    vmov.u8 r5, q0[6]
; CHECK-NEXT:    vmov.8 q2[5], r2
; CHECK-NEXT:    vmov.u8 r2, q1[6]
; CHECK-NEXT:    udiv r6, r5, r2
; CHECK-NEXT:    mls r2, r6, r2, r5
; CHECK-NEXT:    vmov.u8 r5, q0[7]
; CHECK-NEXT:    vmov.8 q2[6], r2
; CHECK-NEXT:    vmov.u8 r2, q1[7]
; CHECK-NEXT:    udiv r6, r5, r2
; CHECK-NEXT:    mls r2, r6, r2, r5
; CHECK-NEXT:    vmov.u8 r5, q0[9]
; CHECK-NEXT:    vmov.8 q2[7], r2
; CHECK-NEXT:    vmov.u8 r2, q1[9]
; CHECK-NEXT:    udiv r6, r5, r2
; CHECK-NEXT:    vmov.8 q2[8], r4
; CHECK-NEXT:    mls r2, r6, r2, r5
; CHECK-NEXT:    vmov.8 q2[9], r2
; CHECK-NEXT:    vmov.8 q2[10], r0
; CHECK-NEXT:    vmov.8 q2[11], r1
; CHECK-NEXT:    vmov.8 q2[12], r8
; CHECK-NEXT:    vmov.8 q2[13], r3
; CHECK-NEXT:    vmov.8 q2[14], r12
; CHECK-NEXT:    vmov.8 q2[15], lr
; CHECK-NEXT:    vmov q0, q2
; CHECK-NEXT:    pop.w {r4, r5, r6, r7, r8, pc}
entry:
  %out = urem <16 x i8> %in1, %in2
  ret <16 x i8> %out
}

define arm_aapcs_vfpcc <16 x i8> @srem_i8(<16 x i8> %in1, <16 x i8> %in2) {
; CHECK-LABEL: srem_i8:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r4, r5, r6, r7, r8, r9, lr}
; CHECK-NEXT:    push.w {r4, r5, r6, r7, r8, r9, lr}
; CHECK-NEXT:    vmov.u8 r5, q1[14]
; CHECK-NEXT:    vmov.u8 r6, q0[14]
; CHECK-NEXT:    sxtb r5, r5
; CHECK-NEXT:    sxtb r6, r6
; CHECK-NEXT:    sdiv r7, r6, r5
; CHECK-NEXT:    vmov.u8 r4, q1[15]
; CHECK-NEXT:    mls r12, r7, r5, r6
; CHECK-NEXT:    vmov.u8 r7, q0[15]
; CHECK-NEXT:    sxtb r4, r4
; CHECK-NEXT:    vmov.u8 r2, q1[13]
; CHECK-NEXT:    sxtb r7, r7
; CHECK-NEXT:    sxtb r3, r2
; CHECK-NEXT:    sdiv r6, r7, r4
; CHECK-NEXT:    vmov.u8 r2, q1[12]
; CHECK-NEXT:    mls lr, r6, r4, r7
; CHECK-NEXT:    vmov.u8 r4, q0[12]
; CHECK-NEXT:    sxtb r2, r2
; CHECK-NEXT:    vmov.u8 r0, q1[8]
; CHECK-NEXT:    sxtb r4, r4
; CHECK-NEXT:    sxtb.w r8, r0
; CHECK-NEXT:    sdiv r5, r4, r2
; CHECK-NEXT:    vmov.u8 r0, q1[11]
; CHECK-NEXT:    mls r9, r5, r2, r4
; CHECK-NEXT:    vmov.u8 r4, q0[13]
; CHECK-NEXT:    sxtb r4, r4
; CHECK-NEXT:    vmov.u8 r6, q0[0]
; CHECK-NEXT:    sdiv r5, r4, r3
; CHECK-NEXT:    sxtb r1, r0
; CHECK-NEXT:    vmov.u8 r0, q1[10]
; CHECK-NEXT:    mls r3, r5, r3, r4
; CHECK-NEXT:    vmov.u8 r4, q0[10]
; CHECK-NEXT:    sxtb r0, r0
; CHECK-NEXT:    sxtb r4, r4
; CHECK-NEXT:    sxtb r6, r6
; CHECK-NEXT:    sdiv r5, r4, r0
; CHECK-NEXT:    mls r0, r5, r0, r4
; CHECK-NEXT:    vmov.u8 r4, q0[11]
; CHECK-NEXT:    sxtb r4, r4
; CHECK-NEXT:    sdiv r5, r4, r1
; CHECK-NEXT:    mls r1, r5, r1, r4
; CHECK-NEXT:    vmov.u8 r4, q0[8]
; CHECK-NEXT:    sxtb r4, r4
; CHECK-NEXT:    sdiv r5, r4, r8
; CHECK-NEXT:    mls r4, r5, r8, r4
; CHECK-NEXT:    vmov.u8 r5, q1[0]
; CHECK-NEXT:    sxtb r5, r5
; CHECK-NEXT:    sdiv r7, r6, r5
; CHECK-NEXT:    mls r5, r7, r5, r6
; CHECK-NEXT:    vmov.u8 r6, q1[1]
; CHECK-NEXT:    vmov.u8 r7, q0[1]
; CHECK-NEXT:    sxtb r6, r6
; CHECK-NEXT:    sxtb r7, r7
; CHECK-NEXT:    vmov.8 q2[0], r5
; CHECK-NEXT:    sdiv r2, r7, r6
; CHECK-NEXT:    vmov.u8 r5, q0[2]
; CHECK-NEXT:    mls r2, r2, r6, r7
; CHECK-NEXT:    sxtb r5, r5
; CHECK-NEXT:    vmov.8 q2[1], r2
; CHECK-NEXT:    vmov.u8 r2, q1[2]
; CHECK-NEXT:    sxtb r2, r2
; CHECK-NEXT:    sdiv r6, r5, r2
; CHECK-NEXT:    mls r2, r6, r2, r5
; CHECK-NEXT:    vmov.u8 r5, q0[3]
; CHECK-NEXT:    sxtb r5, r5
; CHECK-NEXT:    vmov.8 q2[2], r2
; CHECK-NEXT:    vmov.u8 r2, q1[3]
; CHECK-NEXT:    sxtb r2, r2
; CHECK-NEXT:    sdiv r6, r5, r2
; CHECK-NEXT:    mls r2, r6, r2, r5
; CHECK-NEXT:    vmov.u8 r5, q0[4]
; CHECK-NEXT:    sxtb r5, r5
; CHECK-NEXT:    vmov.8 q2[3], r2
; CHECK-NEXT:    vmov.u8 r2, q1[4]
; CHECK-NEXT:    sxtb r2, r2
; CHECK-NEXT:    sdiv r6, r5, r2
; CHECK-NEXT:    mls r2, r6, r2, r5
; CHECK-NEXT:    vmov.u8 r5, q0[5]
; CHECK-NEXT:    sxtb r5, r5
; CHECK-NEXT:    vmov.8 q2[4], r2
; CHECK-NEXT:    vmov.u8 r2, q1[5]
; CHECK-NEXT:    sxtb r2, r2
; CHECK-NEXT:    sdiv r6, r5, r2
; CHECK-NEXT:    mls r2, r6, r2, r5
; CHECK-NEXT:    vmov.u8 r5, q0[6]
; CHECK-NEXT:    sxtb r5, r5
; CHECK-NEXT:    vmov.8 q2[5], r2
; CHECK-NEXT:    vmov.u8 r2, q1[6]
; CHECK-NEXT:    sxtb r2, r2
; CHECK-NEXT:    sdiv r6, r5, r2
; CHECK-NEXT:    mls r2, r6, r2, r5
; CHECK-NEXT:    vmov.u8 r5, q0[7]
; CHECK-NEXT:    sxtb r5, r5
; CHECK-NEXT:    vmov.8 q2[6], r2
; CHECK-NEXT:    vmov.u8 r2, q1[7]
; CHECK-NEXT:    sxtb r2, r2
; CHECK-NEXT:    sdiv r6, r5, r2
; CHECK-NEXT:    mls r2, r6, r2, r5
; CHECK-NEXT:    vmov.u8 r5, q0[9]
; CHECK-NEXT:    sxtb r5, r5
; CHECK-NEXT:    vmov.8 q2[7], r2
; CHECK-NEXT:    vmov.u8 r2, q1[9]
; CHECK-NEXT:    sxtb r2, r2
; CHECK-NEXT:    vmov.8 q2[8], r4
; CHECK-NEXT:    sdiv r6, r5, r2
; CHECK-NEXT:    mls r2, r6, r2, r5
; CHECK-NEXT:    vmov.8 q2[9], r2
; CHECK-NEXT:    vmov.8 q2[10], r0
; CHECK-NEXT:    vmov.8 q2[11], r1
; CHECK-NEXT:    vmov.8 q2[12], r9
; CHECK-NEXT:    vmov.8 q2[13], r3
; CHECK-NEXT:    vmov.8 q2[14], r12
; CHECK-NEXT:    vmov.8 q2[15], lr
; CHECK-NEXT:    vmov q0, q2
; CHECK-NEXT:    pop.w {r4, r5, r6, r7, r8, r9, pc}
entry:
  %out = srem <16 x i8> %in1, %in2
  ret <16 x i8> %out
}

define arm_aapcs_vfpcc <2 x i64> @udiv_i64(<2 x i64> %in1, <2 x i64> %in2) {
; CHECK-LABEL: udiv_i64:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r7, lr}
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    .vsave {d8, d9, d10, d11}
; CHECK-NEXT:    vpush {d8, d9, d10, d11}
; CHECK-NEXT:    vmov q4, q1
; CHECK-NEXT:    vmov q5, q0
; CHECK-NEXT:    vmov r0, s20
; CHECK-NEXT:    vmov r1, s21
; CHECK-NEXT:    vmov r2, s16
; CHECK-NEXT:    vmov r3, s17
; CHECK-NEXT:    bl __aeabi_uldivmod
; CHECK-NEXT:    vmov r12, s22
; CHECK-NEXT:    vmov lr, s23
; CHECK-NEXT:    vmov r2, s18
; CHECK-NEXT:    vmov r3, s19
; CHECK-NEXT:    vmov.32 q4[0], r0
; CHECK-NEXT:    vmov.32 q4[1], r1
; CHECK-NEXT:    mov r0, r12
; CHECK-NEXT:    mov r1, lr
; CHECK-NEXT:    bl __aeabi_uldivmod
; CHECK-NEXT:    vmov.32 q4[2], r0
; CHECK-NEXT:    vmov.32 q4[3], r1
; CHECK-NEXT:    vmov q0, q4
; CHECK-NEXT:    vpop {d8, d9, d10, d11}
; CHECK-NEXT:    pop {r7, pc}
entry:
  %out = udiv <2 x i64> %in1, %in2
  ret <2 x i64> %out
}

define arm_aapcs_vfpcc <2 x i64> @sdiv_i64(<2 x i64> %in1, <2 x i64> %in2) {
; CHECK-LABEL: sdiv_i64:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r7, lr}
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    .vsave {d8, d9, d10, d11}
; CHECK-NEXT:    vpush {d8, d9, d10, d11}
; CHECK-NEXT:    vmov q4, q1
; CHECK-NEXT:    vmov q5, q0
; CHECK-NEXT:    vmov r0, s20
; CHECK-NEXT:    vmov r1, s21
; CHECK-NEXT:    vmov r2, s16
; CHECK-NEXT:    vmov r3, s17
; CHECK-NEXT:    bl __aeabi_ldivmod
; CHECK-NEXT:    vmov r12, s22
; CHECK-NEXT:    vmov lr, s23
; CHECK-NEXT:    vmov r2, s18
; CHECK-NEXT:    vmov r3, s19
; CHECK-NEXT:    vmov.32 q4[0], r0
; CHECK-NEXT:    vmov.32 q4[1], r1
; CHECK-NEXT:    mov r0, r12
; CHECK-NEXT:    mov r1, lr
; CHECK-NEXT:    bl __aeabi_ldivmod
; CHECK-NEXT:    vmov.32 q4[2], r0
; CHECK-NEXT:    vmov.32 q4[3], r1
; CHECK-NEXT:    vmov q0, q4
; CHECK-NEXT:    vpop {d8, d9, d10, d11}
; CHECK-NEXT:    pop {r7, pc}
entry:
  %out = sdiv <2 x i64> %in1, %in2
  ret <2 x i64> %out
}

define arm_aapcs_vfpcc <2 x i64> @urem_i64(<2 x i64> %in1, <2 x i64> %in2) {
; CHECK-LABEL: urem_i64:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r7, lr}
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    .vsave {d8, d9, d10, d11}
; CHECK-NEXT:    vpush {d8, d9, d10, d11}
; CHECK-NEXT:    vmov q4, q1
; CHECK-NEXT:    vmov q5, q0
; CHECK-NEXT:    vmov r0, s20
; CHECK-NEXT:    vmov r1, s21
; CHECK-NEXT:    vmov r2, s16
; CHECK-NEXT:    vmov r3, s17
; CHECK-NEXT:    bl __aeabi_uldivmod
; CHECK-NEXT:    vmov r12, s18
; CHECK-NEXT:    vmov lr, s19
; CHECK-NEXT:    vmov.32 q4[0], r2
; CHECK-NEXT:    vmov r0, s22
; CHECK-NEXT:    vmov.32 q4[1], r3
; CHECK-NEXT:    vmov r1, s23
; CHECK-NEXT:    mov r2, r12
; CHECK-NEXT:    mov r3, lr
; CHECK-NEXT:    bl __aeabi_uldivmod
; CHECK-NEXT:    vmov.32 q4[2], r2
; CHECK-NEXT:    vmov.32 q4[3], r3
; CHECK-NEXT:    vmov q0, q4
; CHECK-NEXT:    vpop {d8, d9, d10, d11}
; CHECK-NEXT:    pop {r7, pc}
entry:
  %out = urem <2 x i64> %in1, %in2
  ret <2 x i64> %out
}

define arm_aapcs_vfpcc <2 x i64> @srem_i64(<2 x i64> %in1, <2 x i64> %in2) {
; CHECK-LABEL: srem_i64:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r7, lr}
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    .vsave {d8, d9, d10, d11}
; CHECK-NEXT:    vpush {d8, d9, d10, d11}
; CHECK-NEXT:    vmov q4, q1
; CHECK-NEXT:    vmov q5, q0
; CHECK-NEXT:    vmov r0, s20
; CHECK-NEXT:    vmov r1, s21
; CHECK-NEXT:    vmov r2, s16
; CHECK-NEXT:    vmov r3, s17
; CHECK-NEXT:    bl __aeabi_ldivmod
; CHECK-NEXT:    vmov r12, s18
; CHECK-NEXT:    vmov lr, s19
; CHECK-NEXT:    vmov.32 q4[0], r2
; CHECK-NEXT:    vmov r0, s22
; CHECK-NEXT:    vmov.32 q4[1], r3
; CHECK-NEXT:    vmov r1, s23
; CHECK-NEXT:    mov r2, r12
; CHECK-NEXT:    mov r3, lr
; CHECK-NEXT:    bl __aeabi_ldivmod
; CHECK-NEXT:    vmov.32 q4[2], r2
; CHECK-NEXT:    vmov.32 q4[3], r3
; CHECK-NEXT:    vmov q0, q4
; CHECK-NEXT:    vpop {d8, d9, d10, d11}
; CHECK-NEXT:    pop {r7, pc}
entry:
  %out = srem <2 x i64> %in1, %in2
  ret <2 x i64> %out
}




define arm_aapcs_vfpcc <4 x float> @fdiv_f32(<4 x float> %in1, <4 x float> %in2) {
; CHECK-LABEL: fdiv_f32:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vdiv.f32 s11, s3, s7
; CHECK-NEXT:    vdiv.f32 s10, s2, s6
; CHECK-NEXT:    vdiv.f32 s9, s1, s5
; CHECK-NEXT:    vdiv.f32 s8, s0, s4
; CHECK-NEXT:    vmov q0, q2
; CHECK-NEXT:    bx lr
entry:
  %out = fdiv <4 x float> %in1, %in2
  ret <4 x float> %out
}

define arm_aapcs_vfpcc <4 x float> @frem_f32(<4 x float> %in1, <4 x float> %in2) {
; CHECK-LABEL: frem_f32:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r4, r5, r6, lr}
; CHECK-NEXT:    push {r4, r5, r6, lr}
; CHECK-NEXT:    .vsave {d8, d9}
; CHECK-NEXT:    vpush {d8, d9}
; CHECK-NEXT:    .pad #32
; CHECK-NEXT:    sub sp, #32
; CHECK-NEXT:    vstr s0, [sp]
; CHECK-NEXT:    ldr r4, [sp]
; CHECK-NEXT:    vstr s2, [sp, #16]
; CHECK-NEXT:    vstr s6, [sp, #20]
; CHECK-NEXT:    vstr s3, [sp, #24]
; CHECK-NEXT:    vstr s7, [sp, #28]
; CHECK-NEXT:    vstr s4, [sp, #4]
; CHECK-NEXT:    vstr s1, [sp, #8]
; CHECK-NEXT:    vstr s5, [sp, #12]
; CHECK-NEXT:    ldrd r0, r1, [sp, #16]
; CHECK-NEXT:    bl fmodf
; CHECK-NEXT:    mov r5, r0
; CHECK-NEXT:    ldrd r0, r1, [sp, #24]
; CHECK-NEXT:    bl fmodf
; CHECK-NEXT:    ldr r1, [sp, #12]
; CHECK-NEXT:    vmov s19, r0
; CHECK-NEXT:    ldrd r6, r2, [sp, #4]
; CHECK-NEXT:    vmov s18, r5
; CHECK-NEXT:    mov r0, r2
; CHECK-NEXT:    bl fmodf
; CHECK-NEXT:    vmov s17, r0
; CHECK-NEXT:    mov r0, r4
; CHECK-NEXT:    mov r1, r6
; CHECK-NEXT:    bl fmodf
; CHECK-NEXT:    vmov s16, r0
; CHECK-NEXT:    vmov q0, q4
; CHECK-NEXT:    add sp, #32
; CHECK-NEXT:    vpop {d8, d9}
; CHECK-NEXT:    pop {r4, r5, r6, pc}
entry:
  %out = frem <4 x float> %in1, %in2
  ret <4 x float> %out
}


define arm_aapcs_vfpcc <8 x half> @fdiv_f16(<8 x half> %in1, <8 x half> %in2) {
; CHECK-LABEL: fdiv_f16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmov.u16 r0, q1[0]
; CHECK-NEXT:    vmov.u16 r1, q1[1]
; CHECK-NEXT:    vmov s8, r0
; CHECK-NEXT:    vmov.u16 r0, q0[0]
; CHECK-NEXT:    vmov s10, r0
; CHECK-NEXT:    vmov.u16 r2, q0[1]
; CHECK-NEXT:    vdiv.f16 s8, s10, s8
; CHECK-NEXT:    vmov s10, r2
; CHECK-NEXT:    vmov r0, s8
; CHECK-NEXT:    vmov s8, r1
; CHECK-NEXT:    vdiv.f16 s8, s10, s8
; CHECK-NEXT:    vmov r1, s8
; CHECK-NEXT:    vmov.16 q2[0], r0
; CHECK-NEXT:    vmov.u16 r0, q1[2]
; CHECK-NEXT:    vmov.16 q2[1], r1
; CHECK-NEXT:    vmov s12, r0
; CHECK-NEXT:    vmov.u16 r0, q0[2]
; CHECK-NEXT:    vmov s14, r0
; CHECK-NEXT:    vdiv.f16 s12, s14, s12
; CHECK-NEXT:    vmov r0, s12
; CHECK-NEXT:    vmov.16 q2[2], r0
; CHECK-NEXT:    vmov.u16 r0, q1[3]
; CHECK-NEXT:    vmov s12, r0
; CHECK-NEXT:    vmov.u16 r0, q0[3]
; CHECK-NEXT:    vmov s14, r0
; CHECK-NEXT:    vdiv.f16 s12, s14, s12
; CHECK-NEXT:    vmov r0, s12
; CHECK-NEXT:    vmov.16 q2[3], r0
; CHECK-NEXT:    vmov.u16 r0, q1[4]
; CHECK-NEXT:    vmov s12, r0
; CHECK-NEXT:    vmov.u16 r0, q0[4]
; CHECK-NEXT:    vmov s14, r0
; CHECK-NEXT:    vdiv.f16 s12, s14, s12
; CHECK-NEXT:    vmov r0, s12
; CHECK-NEXT:    vmov.16 q2[4], r0
; CHECK-NEXT:    vmov.u16 r0, q1[5]
; CHECK-NEXT:    vmov s12, r0
; CHECK-NEXT:    vmov.u16 r0, q0[5]
; CHECK-NEXT:    vmov s14, r0
; CHECK-NEXT:    vdiv.f16 s12, s14, s12
; CHECK-NEXT:    vmov r0, s12
; CHECK-NEXT:    vmov.16 q2[5], r0
; CHECK-NEXT:    vmov.u16 r0, q1[6]
; CHECK-NEXT:    vmov s12, r0
; CHECK-NEXT:    vmov.u16 r0, q0[6]
; CHECK-NEXT:    vmov s14, r0
; CHECK-NEXT:    vdiv.f16 s12, s14, s12
; CHECK-NEXT:    vmov r0, s12
; CHECK-NEXT:    vmov.16 q2[6], r0
; CHECK-NEXT:    vmov.u16 r0, q1[7]
; CHECK-NEXT:    vmov s4, r0
; CHECK-NEXT:    vmov.u16 r0, q0[7]
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vdiv.f16 s0, s0, s4
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    vmov.16 q2[7], r0
; CHECK-NEXT:    vmov q0, q2
; CHECK-NEXT:    bx lr
entry:
  %out = fdiv <8 x half> %in1, %in2
  ret <8 x half> %out
}

define arm_aapcs_vfpcc <8 x half> @frem_f16(<8 x half> %in1, <8 x half> %in2) {
; CHECK-LABEL: frem_f16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r4, lr}
; CHECK-NEXT:    push {r4, lr}
; CHECK-NEXT:    .vsave {d8, d9, d10, d11, d12, d13}
; CHECK-NEXT:    vpush {d8, d9, d10, d11, d12, d13}
; CHECK-NEXT:    .pad #64
; CHECK-NEXT:    sub sp, #64
; CHECK-NEXT:    vmov q4, q0
; CHECK-NEXT:    vmov.u16 r0, q1[0]
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vmov.u16 r0, q4[0]
; CHECK-NEXT:    vmov s2, r0
; CHECK-NEXT:    vmov q5, q1
; CHECK-NEXT:    vcvtb.f32.f16 s2, s2
; CHECK-NEXT:    vstr s2, [sp, #56]
; CHECK-NEXT:    vcvtb.f32.f16 s0, s0
; CHECK-NEXT:    vstr s0, [sp, #60]
; CHECK-NEXT:    ldrd r0, r1, [sp, #56]
; CHECK-NEXT:    bl fmodf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vmov.u16 r0, q5[1]
; CHECK-NEXT:    vcvtb.f16.f32 s0, s0
; CHECK-NEXT:    vmov r4, s0
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vmov.u16 r0, q4[1]
; CHECK-NEXT:    vmov s2, r0
; CHECK-NEXT:    vcvtb.f32.f16 s2, s2
; CHECK-NEXT:    vstr s2, [sp, #48]
; CHECK-NEXT:    vcvtb.f32.f16 s0, s0
; CHECK-NEXT:    vstr s0, [sp, #52]
; CHECK-NEXT:    ldrd r0, r1, [sp, #48]
; CHECK-NEXT:    bl fmodf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vmov.16 q6[0], r4
; CHECK-NEXT:    vcvtb.f16.f32 s0, s0
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    vmov.16 q6[1], r0
; CHECK-NEXT:    vmov.u16 r0, q5[2]
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vmov.u16 r0, q4[2]
; CHECK-NEXT:    vmov s2, r0
; CHECK-NEXT:    vcvtb.f32.f16 s2, s2
; CHECK-NEXT:    vstr s2, [sp, #40]
; CHECK-NEXT:    vcvtb.f32.f16 s0, s0
; CHECK-NEXT:    vstr s0, [sp, #44]
; CHECK-NEXT:    ldrd r0, r1, [sp, #40]
; CHECK-NEXT:    bl fmodf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtb.f16.f32 s0, s0
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    vmov.16 q6[2], r0
; CHECK-NEXT:    vmov.u16 r0, q5[3]
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vmov.u16 r0, q4[3]
; CHECK-NEXT:    vmov s2, r0
; CHECK-NEXT:    vcvtb.f32.f16 s2, s2
; CHECK-NEXT:    vstr s2, [sp, #32]
; CHECK-NEXT:    vcvtb.f32.f16 s0, s0
; CHECK-NEXT:    vstr s0, [sp, #36]
; CHECK-NEXT:    ldrd r0, r1, [sp, #32]
; CHECK-NEXT:    bl fmodf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtb.f16.f32 s0, s0
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    vmov.16 q6[3], r0
; CHECK-NEXT:    vmov.u16 r0, q5[4]
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vmov.u16 r0, q4[4]
; CHECK-NEXT:    vmov s2, r0
; CHECK-NEXT:    vcvtb.f32.f16 s2, s2
; CHECK-NEXT:    vstr s2, [sp, #24]
; CHECK-NEXT:    vcvtb.f32.f16 s0, s0
; CHECK-NEXT:    vstr s0, [sp, #28]
; CHECK-NEXT:    ldrd r0, r1, [sp, #24]
; CHECK-NEXT:    bl fmodf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtb.f16.f32 s0, s0
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    vmov.16 q6[4], r0
; CHECK-NEXT:    vmov.u16 r0, q5[5]
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vmov.u16 r0, q4[5]
; CHECK-NEXT:    vmov s2, r0
; CHECK-NEXT:    vcvtb.f32.f16 s2, s2
; CHECK-NEXT:    vstr s2, [sp, #16]
; CHECK-NEXT:    vcvtb.f32.f16 s0, s0
; CHECK-NEXT:    vstr s0, [sp, #20]
; CHECK-NEXT:    ldrd r0, r1, [sp, #16]
; CHECK-NEXT:    bl fmodf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtb.f16.f32 s0, s0
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    vmov.16 q6[5], r0
; CHECK-NEXT:    vmov.u16 r0, q5[6]
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vmov.u16 r0, q4[6]
; CHECK-NEXT:    vmov s2, r0
; CHECK-NEXT:    vcvtb.f32.f16 s2, s2
; CHECK-NEXT:    vstr s2, [sp, #8]
; CHECK-NEXT:    vcvtb.f32.f16 s0, s0
; CHECK-NEXT:    vstr s0, [sp, #12]
; CHECK-NEXT:    ldrd r0, r1, [sp, #8]
; CHECK-NEXT:    bl fmodf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtb.f16.f32 s0, s0
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    vmov.16 q6[6], r0
; CHECK-NEXT:    vmov.u16 r0, q5[7]
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vmov.u16 r0, q4[7]
; CHECK-NEXT:    vmov s2, r0
; CHECK-NEXT:    vcvtb.f32.f16 s2, s2
; CHECK-NEXT:    vstr s2, [sp]
; CHECK-NEXT:    vcvtb.f32.f16 s0, s0
; CHECK-NEXT:    vstr s0, [sp, #4]
; CHECK-NEXT:    ldrd r0, r1, [sp]
; CHECK-NEXT:    bl fmodf
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vcvtb.f16.f32 s0, s0
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    vmov.16 q6[7], r0
; CHECK-NEXT:    vmov q0, q6
; CHECK-NEXT:    add sp, #64
; CHECK-NEXT:    vpop {d8, d9, d10, d11, d12, d13}
; CHECK-NEXT:    pop {r4, pc}
entry:
  %out = frem <8 x half> %in1, %in2
  ret <8 x half> %out
}

define arm_aapcs_vfpcc <2 x double> @fdiv_f64(<2 x double> %in1, <2 x double> %in2) {
; CHECK-LABEL: fdiv_f64:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r7, lr}
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    .vsave {d8, d9, d10, d11}
; CHECK-NEXT:    vpush {d8, d9, d10, d11}
; CHECK-NEXT:    vmov q4, q1
; CHECK-NEXT:    vmov q5, q0
; CHECK-NEXT:    vmov r0, r1, d11
; CHECK-NEXT:    vmov r2, r3, d9
; CHECK-NEXT:    bl __aeabi_ddiv
; CHECK-NEXT:    vmov lr, r12, d10
; CHECK-NEXT:    vmov r2, r3, d8
; CHECK-NEXT:    vmov d9, r0, r1
; CHECK-NEXT:    mov r0, lr
; CHECK-NEXT:    mov r1, r12
; CHECK-NEXT:    bl __aeabi_ddiv
; CHECK-NEXT:    vmov d8, r0, r1
; CHECK-NEXT:    vmov q0, q4
; CHECK-NEXT:    vpop {d8, d9, d10, d11}
; CHECK-NEXT:    pop {r7, pc}
entry:
  %out = fdiv <2 x double> %in1, %in2
  ret <2 x double> %out
}

define arm_aapcs_vfpcc <2 x double> @frem_f64(<2 x double> %in1, <2 x double> %in2) {
; CHECK-LABEL: frem_f64:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r7, lr}
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    .vsave {d8, d9, d10, d11}
; CHECK-NEXT:    vpush {d8, d9, d10, d11}
; CHECK-NEXT:    vmov q4, q1
; CHECK-NEXT:    vmov q5, q0
; CHECK-NEXT:    vmov r0, r1, d11
; CHECK-NEXT:    vmov r2, r3, d9
; CHECK-NEXT:    bl fmod
; CHECK-NEXT:    vmov lr, r12, d10
; CHECK-NEXT:    vmov r2, r3, d8
; CHECK-NEXT:    vmov d9, r0, r1
; CHECK-NEXT:    mov r0, lr
; CHECK-NEXT:    mov r1, r12
; CHECK-NEXT:    bl fmod
; CHECK-NEXT:    vmov d8, r0, r1
; CHECK-NEXT:    vmov q0, q4
; CHECK-NEXT:    vpop {d8, d9, d10, d11}
; CHECK-NEXT:    pop {r7, pc}
entry:
  %out = frem <2 x double> %in1, %in2
  ret <2 x double> %out
}


