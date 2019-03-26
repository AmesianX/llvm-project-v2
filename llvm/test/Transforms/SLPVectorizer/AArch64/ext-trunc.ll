; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -slp-vectorizer -mtriple=aarch64--linux-gnu < %s | FileCheck %s

target datalayout = "e-m:e-i32:64-i128:128-n32:64-S128"

declare void @foo(i64, i64, i64, i64)

define void @test1(<4 x i16> %a, <4 x i16> %b, i64* %p) {
; Make sure types of sub and its sources are not extended.
; CHECK-LABEL: @test1(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[Z0:%.*]] = zext <4 x i16> [[A:%.*]] to <4 x i32>
; CHECK-NEXT:    [[Z1:%.*]] = zext <4 x i16> [[B:%.*]] to <4 x i32>
; CHECK-NEXT:    [[SUB0:%.*]] = sub <4 x i32> [[Z0]], [[Z1]]
; CHECK-NEXT:    [[E0:%.*]] = extractelement <4 x i32> [[SUB0]], i32 0
; CHECK-NEXT:    [[S0:%.*]] = sext i32 [[E0]] to i64
; CHECK-NEXT:    [[GEP0:%.*]] = getelementptr inbounds i64, i64* [[P:%.*]], i64 [[S0]]
; CHECK-NEXT:    [[LOAD0:%.*]] = load i64, i64* [[GEP0]]
; CHECK-NEXT:    [[E1:%.*]] = extractelement <4 x i32> [[SUB0]], i32 1
; CHECK-NEXT:    [[S1:%.*]] = sext i32 [[E1]] to i64
; CHECK-NEXT:    [[GEP1:%.*]] = getelementptr inbounds i64, i64* [[P]], i64 [[S1]]
; CHECK-NEXT:    [[LOAD1:%.*]] = load i64, i64* [[GEP1]]
; CHECK-NEXT:    [[E2:%.*]] = extractelement <4 x i32> [[SUB0]], i32 2
; CHECK-NEXT:    [[S2:%.*]] = sext i32 [[E2]] to i64
; CHECK-NEXT:    [[GEP2:%.*]] = getelementptr inbounds i64, i64* [[P]], i64 [[S2]]
; CHECK-NEXT:    [[LOAD2:%.*]] = load i64, i64* [[GEP2]]
; CHECK-NEXT:    [[E3:%.*]] = extractelement <4 x i32> [[SUB0]], i32 3
; CHECK-NEXT:    [[S3:%.*]] = sext i32 [[E3]] to i64
; CHECK-NEXT:    [[GEP3:%.*]] = getelementptr inbounds i64, i64* [[P]], i64 [[S3]]
; CHECK-NEXT:    [[LOAD3:%.*]] = load i64, i64* [[GEP3]]
; CHECK-NEXT:    call void @foo(i64 [[LOAD0]], i64 [[LOAD1]], i64 [[LOAD2]], i64 [[LOAD3]])
; CHECK-NEXT:    ret void
;
entry:
  %z0 = zext <4 x i16> %a to <4 x i32>
  %z1 = zext <4 x i16> %b to <4 x i32>
  %sub0 = sub <4 x i32> %z0, %z1
  %e0 = extractelement <4 x i32> %sub0, i32 0
  %s0 = sext i32 %e0 to i64
  %gep0 = getelementptr inbounds i64, i64* %p, i64 %s0
  %load0 = load i64, i64* %gep0
  %e1 = extractelement <4 x i32> %sub0, i32 1
  %s1 = sext i32 %e1 to i64
  %gep1 = getelementptr inbounds i64, i64* %p, i64 %s1
  %load1 = load i64, i64* %gep1
  %e2 = extractelement <4 x i32> %sub0, i32 2
  %s2 = sext i32 %e2 to i64
  %gep2 = getelementptr inbounds i64, i64* %p, i64 %s2
  %load2 = load i64, i64* %gep2
  %e3 = extractelement <4 x i32> %sub0, i32 3
  %s3 = sext i32 %e3 to i64
  %gep3 = getelementptr inbounds i64, i64* %p, i64 %s3
  %load3 = load i64, i64* %gep3
  call void @foo(i64 %load0, i64 %load1, i64 %load2, i64 %load3)
  ret void
}

define void @test2(<4 x i16> %a, <4 x i16> %b, i64 %c0, i64 %c1, i64 %c2, i64 %c3, i64* %p) {
; CHECK-LABEL: @test2(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[Z0:%.*]] = zext <4 x i16> [[A:%.*]] to <4 x i32>
; CHECK-NEXT:    [[Z1:%.*]] = zext <4 x i16> [[B:%.*]] to <4 x i32>
; CHECK-NEXT:    [[SUB0:%.*]] = sub <4 x i32> [[Z0]], [[Z1]]
; CHECK-NEXT:    [[TMP0:%.*]] = sext <4 x i32> [[SUB0]] to <4 x i64>
; CHECK-NEXT:    [[TMP1:%.*]] = insertelement <4 x i64> undef, i64 [[C0:%.*]], i32 0
; CHECK-NEXT:    [[TMP2:%.*]] = insertelement <4 x i64> [[TMP1]], i64 [[C1:%.*]], i32 1
; CHECK-NEXT:    [[TMP3:%.*]] = insertelement <4 x i64> [[TMP2]], i64 [[C2:%.*]], i32 2
; CHECK-NEXT:    [[TMP4:%.*]] = insertelement <4 x i64> [[TMP3]], i64 [[C3:%.*]], i32 3
; CHECK-NEXT:    [[TMP5:%.*]] = add <4 x i64> [[TMP0]], [[TMP4]]
; CHECK-NEXT:    [[TMP6:%.*]] = extractelement <4 x i64> [[TMP5]], i32 0
; CHECK-NEXT:    [[GEP0:%.*]] = getelementptr inbounds i64, i64* [[P:%.*]], i64 [[TMP6]]
; CHECK-NEXT:    [[LOAD0:%.*]] = load i64, i64* [[GEP0]]
; CHECK-NEXT:    [[TMP7:%.*]] = extractelement <4 x i64> [[TMP5]], i32 1
; CHECK-NEXT:    [[GEP1:%.*]] = getelementptr inbounds i64, i64* [[P]], i64 [[TMP7]]
; CHECK-NEXT:    [[LOAD1:%.*]] = load i64, i64* [[GEP1]]
; CHECK-NEXT:    [[TMP8:%.*]] = extractelement <4 x i64> [[TMP5]], i32 2
; CHECK-NEXT:    [[GEP2:%.*]] = getelementptr inbounds i64, i64* [[P]], i64 [[TMP8]]
; CHECK-NEXT:    [[LOAD2:%.*]] = load i64, i64* [[GEP2]]
; CHECK-NEXT:    [[TMP9:%.*]] = extractelement <4 x i64> [[TMP5]], i32 3
; CHECK-NEXT:    [[GEP3:%.*]] = getelementptr inbounds i64, i64* [[P]], i64 [[TMP9]]
; CHECK-NEXT:    [[LOAD3:%.*]] = load i64, i64* [[GEP3]]
; CHECK-NEXT:    call void @foo(i64 [[LOAD0]], i64 [[LOAD1]], i64 [[LOAD2]], i64 [[LOAD3]])
; CHECK-NEXT:    ret void
;
entry:
  %z0 = zext <4 x i16> %a to <4 x i32>
  %z1 = zext <4 x i16> %b to <4 x i32>
  %sub0 = sub <4 x i32> %z0, %z1
  %e0 = extractelement <4 x i32> %sub0, i32 0
  %s0 = sext i32 %e0 to i64
  %a0 = add i64 %s0, %c0
  %gep0 = getelementptr inbounds i64, i64* %p, i64 %a0
  %load0 = load i64, i64* %gep0
  %e1 = extractelement <4 x i32> %sub0, i32 1
  %s1 = sext i32 %e1 to i64
  %a1 = add i64 %s1, %c1
  %gep1 = getelementptr inbounds i64, i64* %p, i64 %a1
  %load1 = load i64, i64* %gep1
  %e2 = extractelement <4 x i32> %sub0, i32 2
  %s2 = sext i32 %e2 to i64
  %a2 = add i64 %s2, %c2
  %gep2 = getelementptr inbounds i64, i64* %p, i64 %a2
  %load2 = load i64, i64* %gep2
  %e3 = extractelement <4 x i32> %sub0, i32 3
  %s3 = sext i32 %e3 to i64
  %a3 = add i64 %s3, %c3
  %gep3 = getelementptr inbounds i64, i64* %p, i64 %a3
  %load3 = load i64, i64* %gep3
  call void @foo(i64 %load0, i64 %load1, i64 %load2, i64 %load3)
  ret void
}
