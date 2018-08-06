; RUN: opt < %s -S -slp-vectorizer -instcombine -pass-remarks-output=%t | FileCheck %s
; RUN: cat %t | FileCheck -check-prefix=REMARK %s
; RUN: opt < %s -S -passes='slp-vectorizer,instcombine' -pass-remarks-output=%t | FileCheck %s
; RUN: cat %t | FileCheck -check-prefix=REMARK %s

target datalayout = "e-m:e-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128"
target triple = "aarch64--linux-gnu"

; CHECK-LABEL:  @gather_multiple_use(
; CHECK-NEXT:     [[TMP1:%.*]] = insertelement <4 x i32> undef, i32 [[C:%.*]], i32 0
; CHECK-NEXT:     [[TMP2:%.*]] = insertelement <4 x i32> [[TMP1]], i32 [[A:%.*]], i32 1
; CHECK-NEXT:     [[TMP3:%.*]] = insertelement <4 x i32> [[TMP2]], i32 [[B:%.*]], i32 2
; CHECK-NEXT:     [[TMP4:%.*]] = insertelement <4 x i32> [[TMP3]], i32 [[D:%.*]], i32 3
; CHECK-NEXT:     [[TMP5:%.*]] = lshr <4 x i32> [[TMP4]], <i32 15, i32 15, i32 15, i32 15>
; CHECK-NEXT:     [[TMP6:%.*]] = and <4 x i32> [[TMP5]], <i32 65537, i32 65537, i32 65537, i32 65537>
; CHECK-NEXT:     [[TMP7:%.*]] = mul nuw <4 x i32> [[TMP6]], <i32 65535, i32 65535, i32 65535, i32 65535>
; CHECK-NEXT:     [[TMP8:%.*]] = add <4 x i32> [[TMP4]], [[TMP7]]
; CHECK-NEXT:     [[TMP9:%.*]] = xor <4 x i32> [[TMP8]], [[TMP7]]
; CHECK-NEXT:     [[TMP10:%.*]] = call i32 @llvm.experimental.vector.reduce.add.i32.v4i32(<4 x i32> [[TMP9]])
; CHECK-NEXT:     ret i32 [[TMP10]]
;
; REMARK-LABEL: Function: gather_multiple_use
; REMARK:       Args:
; REMARK-NEXT:    - String: 'Vectorized horizontal reduction with cost '
; REMARK-NEXT:    - Cost: '-7'
;
define internal i32 @gather_multiple_use(i32 %a, i32 %b, i32 %c, i32 %d) {
  %tmp00 = lshr i32 %a, 15
  %tmp01 = and i32 %tmp00, 65537
  %tmp02 = mul nuw i32 %tmp01, 65535
  %tmp03 = add i32 %tmp02, %a
  %tmp04 = xor i32 %tmp03, %tmp02
  %tmp05 = lshr i32 %c, 15
  %tmp06 = and i32 %tmp05, 65537
  %tmp07 = mul nuw i32 %tmp06, 65535
  %tmp08 = add i32 %tmp07, %c
  %tmp09 = xor i32 %tmp08, %tmp07
  %tmp10 = lshr i32 %b, 15
  %tmp11 = and i32 %tmp10, 65537
  %tmp12 = mul nuw i32 %tmp11, 65535
  %tmp13 = add i32 %tmp12, %b
  %tmp14 = xor i32 %tmp13, %tmp12
  %tmp15 = lshr i32 %d, 15
  %tmp16 = and i32 %tmp15, 65537
  %tmp17 = mul nuw i32 %tmp16, 65535
  %tmp18 = add i32 %tmp17, %d
  %tmp19 = xor i32 %tmp18, %tmp17
  %tmp20 = add i32 %tmp09, %tmp04
  %tmp21 = add i32 %tmp20, %tmp14
  %tmp22 = add i32 %tmp21, %tmp19
  ret i32 %tmp22
}
