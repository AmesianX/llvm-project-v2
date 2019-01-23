; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -mtriple=mips64-mti-linux-gnu -atomic-expand %s | FileCheck %s

define float @test_atomicrmw_fadd_f32(float* %ptr, float %value) {
; CHECK-LABEL: @test_atomicrmw_fadd_f32(
; CHECK-NEXT:    fence seq_cst
; CHECK-NEXT:    [[TMP1:%.*]] = load float, float* [[PTR:%.*]], align 4
; CHECK-NEXT:    br label [[ATOMICRMW_START:%.*]]
; CHECK:       atomicrmw.start:
; CHECK-NEXT:    [[LOADED:%.*]] = phi float [ [[TMP1]], [[TMP0:%.*]] ], [ [[TMP6:%.*]], [[ATOMICRMW_START]] ]
; CHECK-NEXT:    [[NEW:%.*]] = fadd float [[LOADED]], [[VALUE:%.*]]
; CHECK-NEXT:    [[TMP2:%.*]] = bitcast float* [[PTR]] to i32*
; CHECK-NEXT:    [[TMP3:%.*]] = bitcast float [[NEW]] to i32
; CHECK-NEXT:    [[TMP4:%.*]] = bitcast float [[LOADED]] to i32
; CHECK-NEXT:    [[TMP5:%.*]] = cmpxchg i32* [[TMP2]], i32 [[TMP4]], i32 [[TMP3]] monotonic monotonic
; CHECK-NEXT:    [[SUCCESS:%.*]] = extractvalue { i32, i1 } [[TMP5]], 1
; CHECK-NEXT:    [[NEWLOADED:%.*]] = extractvalue { i32, i1 } [[TMP5]], 0
; CHECK-NEXT:    [[TMP6]] = bitcast i32 [[NEWLOADED]] to float
; CHECK-NEXT:    br i1 [[SUCCESS]], label [[ATOMICRMW_END:%.*]], label [[ATOMICRMW_START]]
; CHECK:       atomicrmw.end:
; CHECK-NEXT:    fence seq_cst
; CHECK-NEXT:    ret float [[TMP6]]
;
  %res = atomicrmw fadd float* %ptr, float %value seq_cst
  ret float %res
}

define float @test_atomicrmw_fsub_f32(float* %ptr, float %value) {
; CHECK-LABEL: @test_atomicrmw_fsub_f32(
; CHECK-NEXT:    fence seq_cst
; CHECK-NEXT:    [[TMP1:%.*]] = load float, float* [[PTR:%.*]], align 4
; CHECK-NEXT:    br label [[ATOMICRMW_START:%.*]]
; CHECK:       atomicrmw.start:
; CHECK-NEXT:    [[LOADED:%.*]] = phi float [ [[TMP1]], [[TMP0:%.*]] ], [ [[TMP6:%.*]], [[ATOMICRMW_START]] ]
; CHECK-NEXT:    [[NEW:%.*]] = fsub float [[LOADED]], [[VALUE:%.*]]
; CHECK-NEXT:    [[TMP2:%.*]] = bitcast float* [[PTR]] to i32*
; CHECK-NEXT:    [[TMP3:%.*]] = bitcast float [[NEW]] to i32
; CHECK-NEXT:    [[TMP4:%.*]] = bitcast float [[LOADED]] to i32
; CHECK-NEXT:    [[TMP5:%.*]] = cmpxchg i32* [[TMP2]], i32 [[TMP4]], i32 [[TMP3]] monotonic monotonic
; CHECK-NEXT:    [[SUCCESS:%.*]] = extractvalue { i32, i1 } [[TMP5]], 1
; CHECK-NEXT:    [[NEWLOADED:%.*]] = extractvalue { i32, i1 } [[TMP5]], 0
; CHECK-NEXT:    [[TMP6]] = bitcast i32 [[NEWLOADED]] to float
; CHECK-NEXT:    br i1 [[SUCCESS]], label [[ATOMICRMW_END:%.*]], label [[ATOMICRMW_START]]
; CHECK:       atomicrmw.end:
; CHECK-NEXT:    fence seq_cst
; CHECK-NEXT:    ret float [[TMP6]]
;
  %res = atomicrmw fsub float* %ptr, float %value seq_cst
  ret float %res
}

