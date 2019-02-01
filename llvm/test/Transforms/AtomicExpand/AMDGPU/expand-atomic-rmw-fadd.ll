; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -mtriple=amdgcn-amd-amdhsa -mcpu=hawaii -atomic-expand %s | FileCheck -check-prefix=CI %s
; RUN: opt -S -mtriple=amdgcn-amd-amdhsa -mcpu=gfx900 -atomic-expand %s | FileCheck -check-prefix=GFX9 %s

define float @test_atomicrmw_fadd_f32_flat(float* %ptr, float %value) {
; CI-LABEL: @test_atomicrmw_fadd_f32_flat(
; CI-NEXT:    [[TMP1:%.*]] = load float, float* [[PTR:%.*]], align 4
; CI-NEXT:    br label [[ATOMICRMW_START:%.*]]
; CI:       atomicrmw.start:
; CI-NEXT:    [[LOADED:%.*]] = phi float [ [[TMP1]], [[TMP0:%.*]] ], [ [[TMP6:%.*]], [[ATOMICRMW_START]] ]
; CI-NEXT:    [[NEW:%.*]] = fadd float [[LOADED]], [[VALUE:%.*]]
; CI-NEXT:    [[TMP2:%.*]] = bitcast float* [[PTR]] to i32*
; CI-NEXT:    [[TMP3:%.*]] = bitcast float [[NEW]] to i32
; CI-NEXT:    [[TMP4:%.*]] = bitcast float [[LOADED]] to i32
; CI-NEXT:    [[TMP5:%.*]] = cmpxchg i32* [[TMP2]], i32 [[TMP4]], i32 [[TMP3]] seq_cst seq_cst
; CI-NEXT:    [[SUCCESS:%.*]] = extractvalue { i32, i1 } [[TMP5]], 1
; CI-NEXT:    [[NEWLOADED:%.*]] = extractvalue { i32, i1 } [[TMP5]], 0
; CI-NEXT:    [[TMP6]] = bitcast i32 [[NEWLOADED]] to float
; CI-NEXT:    br i1 [[SUCCESS]], label [[ATOMICRMW_END:%.*]], label [[ATOMICRMW_START]]
; CI:       atomicrmw.end:
; CI-NEXT:    ret float [[TMP6]]
;
; GFX9-LABEL: @test_atomicrmw_fadd_f32_flat(
; GFX9-NEXT:    [[TMP1:%.*]] = load float, float* [[PTR:%.*]], align 4
; GFX9-NEXT:    br label [[ATOMICRMW_START:%.*]]
; GFX9:       atomicrmw.start:
; GFX9-NEXT:    [[LOADED:%.*]] = phi float [ [[TMP1]], [[TMP0:%.*]] ], [ [[TMP6:%.*]], [[ATOMICRMW_START]] ]
; GFX9-NEXT:    [[NEW:%.*]] = fadd float [[LOADED]], [[VALUE:%.*]]
; GFX9-NEXT:    [[TMP2:%.*]] = bitcast float* [[PTR]] to i32*
; GFX9-NEXT:    [[TMP3:%.*]] = bitcast float [[NEW]] to i32
; GFX9-NEXT:    [[TMP4:%.*]] = bitcast float [[LOADED]] to i32
; GFX9-NEXT:    [[TMP5:%.*]] = cmpxchg i32* [[TMP2]], i32 [[TMP4]], i32 [[TMP3]] seq_cst seq_cst
; GFX9-NEXT:    [[SUCCESS:%.*]] = extractvalue { i32, i1 } [[TMP5]], 1
; GFX9-NEXT:    [[NEWLOADED:%.*]] = extractvalue { i32, i1 } [[TMP5]], 0
; GFX9-NEXT:    [[TMP6]] = bitcast i32 [[NEWLOADED]] to float
; GFX9-NEXT:    br i1 [[SUCCESS]], label [[ATOMICRMW_END:%.*]], label [[ATOMICRMW_START]]
; GFX9:       atomicrmw.end:
; GFX9-NEXT:    ret float [[TMP6]]
;
  %res = atomicrmw fadd float* %ptr, float %value seq_cst
  ret float %res
}

define float @test_atomicrmw_fadd_f32_global(float addrspace(1)* %ptr, float %value) {
; CI-LABEL: @test_atomicrmw_fadd_f32_global(
; CI-NEXT:    [[TMP1:%.*]] = load float, float addrspace(1)* [[PTR:%.*]], align 4
; CI-NEXT:    br label [[ATOMICRMW_START:%.*]]
; CI:       atomicrmw.start:
; CI-NEXT:    [[LOADED:%.*]] = phi float [ [[TMP1]], [[TMP0:%.*]] ], [ [[TMP6:%.*]], [[ATOMICRMW_START]] ]
; CI-NEXT:    [[NEW:%.*]] = fadd float [[LOADED]], [[VALUE:%.*]]
; CI-NEXT:    [[TMP2:%.*]] = bitcast float addrspace(1)* [[PTR]] to i32 addrspace(1)*
; CI-NEXT:    [[TMP3:%.*]] = bitcast float [[NEW]] to i32
; CI-NEXT:    [[TMP4:%.*]] = bitcast float [[LOADED]] to i32
; CI-NEXT:    [[TMP5:%.*]] = cmpxchg i32 addrspace(1)* [[TMP2]], i32 [[TMP4]], i32 [[TMP3]] seq_cst seq_cst
; CI-NEXT:    [[SUCCESS:%.*]] = extractvalue { i32, i1 } [[TMP5]], 1
; CI-NEXT:    [[NEWLOADED:%.*]] = extractvalue { i32, i1 } [[TMP5]], 0
; CI-NEXT:    [[TMP6]] = bitcast i32 [[NEWLOADED]] to float
; CI-NEXT:    br i1 [[SUCCESS]], label [[ATOMICRMW_END:%.*]], label [[ATOMICRMW_START]]
; CI:       atomicrmw.end:
; CI-NEXT:    ret float [[TMP6]]
;
; GFX9-LABEL: @test_atomicrmw_fadd_f32_global(
; GFX9-NEXT:    [[TMP1:%.*]] = load float, float addrspace(1)* [[PTR:%.*]], align 4
; GFX9-NEXT:    br label [[ATOMICRMW_START:%.*]]
; GFX9:       atomicrmw.start:
; GFX9-NEXT:    [[LOADED:%.*]] = phi float [ [[TMP1]], [[TMP0:%.*]] ], [ [[TMP6:%.*]], [[ATOMICRMW_START]] ]
; GFX9-NEXT:    [[NEW:%.*]] = fadd float [[LOADED]], [[VALUE:%.*]]
; GFX9-NEXT:    [[TMP2:%.*]] = bitcast float addrspace(1)* [[PTR]] to i32 addrspace(1)*
; GFX9-NEXT:    [[TMP3:%.*]] = bitcast float [[NEW]] to i32
; GFX9-NEXT:    [[TMP4:%.*]] = bitcast float [[LOADED]] to i32
; GFX9-NEXT:    [[TMP5:%.*]] = cmpxchg i32 addrspace(1)* [[TMP2]], i32 [[TMP4]], i32 [[TMP3]] seq_cst seq_cst
; GFX9-NEXT:    [[SUCCESS:%.*]] = extractvalue { i32, i1 } [[TMP5]], 1
; GFX9-NEXT:    [[NEWLOADED:%.*]] = extractvalue { i32, i1 } [[TMP5]], 0
; GFX9-NEXT:    [[TMP6]] = bitcast i32 [[NEWLOADED]] to float
; GFX9-NEXT:    br i1 [[SUCCESS]], label [[ATOMICRMW_END:%.*]], label [[ATOMICRMW_START]]
; GFX9:       atomicrmw.end:
; GFX9-NEXT:    ret float [[TMP6]]
;
  %res = atomicrmw fadd float addrspace(1)* %ptr, float %value seq_cst
  ret float %res
}

define float @test_atomicrmw_fadd_f32_local(float addrspace(3)* %ptr, float %value) {
; CI-LABEL: @test_atomicrmw_fadd_f32_local(
; CI-NEXT:    [[TMP1:%.*]] = load float, float addrspace(3)* [[PTR:%.*]], align 4
; CI-NEXT:    br label [[ATOMICRMW_START:%.*]]
; CI:       atomicrmw.start:
; CI-NEXT:    [[LOADED:%.*]] = phi float [ [[TMP1]], [[TMP0:%.*]] ], [ [[TMP6:%.*]], [[ATOMICRMW_START]] ]
; CI-NEXT:    [[NEW:%.*]] = fadd float [[LOADED]], [[VALUE:%.*]]
; CI-NEXT:    [[TMP2:%.*]] = bitcast float addrspace(3)* [[PTR]] to i32 addrspace(3)*
; CI-NEXT:    [[TMP3:%.*]] = bitcast float [[NEW]] to i32
; CI-NEXT:    [[TMP4:%.*]] = bitcast float [[LOADED]] to i32
; CI-NEXT:    [[TMP5:%.*]] = cmpxchg i32 addrspace(3)* [[TMP2]], i32 [[TMP4]], i32 [[TMP3]] seq_cst seq_cst
; CI-NEXT:    [[SUCCESS:%.*]] = extractvalue { i32, i1 } [[TMP5]], 1
; CI-NEXT:    [[NEWLOADED:%.*]] = extractvalue { i32, i1 } [[TMP5]], 0
; CI-NEXT:    [[TMP6]] = bitcast i32 [[NEWLOADED]] to float
; CI-NEXT:    br i1 [[SUCCESS]], label [[ATOMICRMW_END:%.*]], label [[ATOMICRMW_START]]
; CI:       atomicrmw.end:
; CI-NEXT:    ret float [[TMP6]]
;
; GFX9-LABEL: @test_atomicrmw_fadd_f32_local(
; GFX9-NEXT:    [[RES:%.*]] = atomicrmw fadd float addrspace(3)* [[PTR:%.*]], float [[VALUE:%.*]] seq_cst
; GFX9-NEXT:    ret float [[RES]]
;
  %res = atomicrmw fadd float addrspace(3)* %ptr, float %value seq_cst
  ret float %res
}

define half @test_atomicrmw_fadd_f16_flat(half* %ptr, half %value) {
; CI-LABEL: @test_atomicrmw_fadd_f16_flat(
; CI-NEXT:    [[RES:%.*]] = atomicrmw fadd half* [[PTR:%.*]], half [[VALUE:%.*]] seq_cst
; CI-NEXT:    ret half [[RES]]
;
; GFX9-LABEL: @test_atomicrmw_fadd_f16_flat(
; GFX9-NEXT:    [[RES:%.*]] = atomicrmw fadd half* [[PTR:%.*]], half [[VALUE:%.*]] seq_cst
; GFX9-NEXT:    ret half [[RES]]
;
  %res = atomicrmw fadd half* %ptr, half %value seq_cst
  ret half %res
}

define half @test_atomicrmw_fadd_f16_global(half addrspace(1)* %ptr, half %value) {
; CI-LABEL: @test_atomicrmw_fadd_f16_global(
; CI-NEXT:    [[RES:%.*]] = atomicrmw fadd half addrspace(1)* [[PTR:%.*]], half [[VALUE:%.*]] seq_cst
; CI-NEXT:    ret half [[RES]]
;
; GFX9-LABEL: @test_atomicrmw_fadd_f16_global(
; GFX9-NEXT:    [[RES:%.*]] = atomicrmw fadd half addrspace(1)* [[PTR:%.*]], half [[VALUE:%.*]] seq_cst
; GFX9-NEXT:    ret half [[RES]]
;
  %res = atomicrmw fadd half addrspace(1)* %ptr, half %value seq_cst
  ret half %res
}

define half @test_atomicrmw_fadd_f16_local(half addrspace(3)* %ptr, half %value) {
; CI-LABEL: @test_atomicrmw_fadd_f16_local(
; CI-NEXT:    [[RES:%.*]] = atomicrmw fadd half addrspace(3)* [[PTR:%.*]], half [[VALUE:%.*]] seq_cst
; CI-NEXT:    ret half [[RES]]
;
; GFX9-LABEL: @test_atomicrmw_fadd_f16_local(
; GFX9-NEXT:    [[RES:%.*]] = atomicrmw fadd half addrspace(3)* [[PTR:%.*]], half [[VALUE:%.*]] seq_cst
; GFX9-NEXT:    ret half [[RES]]
;
  %res = atomicrmw fadd half addrspace(3)* %ptr, half %value seq_cst
  ret half %res
}

define double @test_atomicrmw_fadd_f64_flat(double* %ptr, double %value) {
; CI-LABEL: @test_atomicrmw_fadd_f64_flat(
; CI-NEXT:    [[TMP1:%.*]] = load double, double* [[PTR:%.*]], align 8
; CI-NEXT:    br label [[ATOMICRMW_START:%.*]]
; CI:       atomicrmw.start:
; CI-NEXT:    [[LOADED:%.*]] = phi double [ [[TMP1]], [[TMP0:%.*]] ], [ [[TMP6:%.*]], [[ATOMICRMW_START]] ]
; CI-NEXT:    [[NEW:%.*]] = fadd double [[LOADED]], [[VALUE:%.*]]
; CI-NEXT:    [[TMP2:%.*]] = bitcast double* [[PTR]] to i64*
; CI-NEXT:    [[TMP3:%.*]] = bitcast double [[NEW]] to i64
; CI-NEXT:    [[TMP4:%.*]] = bitcast double [[LOADED]] to i64
; CI-NEXT:    [[TMP5:%.*]] = cmpxchg i64* [[TMP2]], i64 [[TMP4]], i64 [[TMP3]] seq_cst seq_cst
; CI-NEXT:    [[SUCCESS:%.*]] = extractvalue { i64, i1 } [[TMP5]], 1
; CI-NEXT:    [[NEWLOADED:%.*]] = extractvalue { i64, i1 } [[TMP5]], 0
; CI-NEXT:    [[TMP6]] = bitcast i64 [[NEWLOADED]] to double
; CI-NEXT:    br i1 [[SUCCESS]], label [[ATOMICRMW_END:%.*]], label [[ATOMICRMW_START]]
; CI:       atomicrmw.end:
; CI-NEXT:    ret double [[TMP6]]
;
; GFX9-LABEL: @test_atomicrmw_fadd_f64_flat(
; GFX9-NEXT:    [[TMP1:%.*]] = load double, double* [[PTR:%.*]], align 8
; GFX9-NEXT:    br label [[ATOMICRMW_START:%.*]]
; GFX9:       atomicrmw.start:
; GFX9-NEXT:    [[LOADED:%.*]] = phi double [ [[TMP1]], [[TMP0:%.*]] ], [ [[TMP6:%.*]], [[ATOMICRMW_START]] ]
; GFX9-NEXT:    [[NEW:%.*]] = fadd double [[LOADED]], [[VALUE:%.*]]
; GFX9-NEXT:    [[TMP2:%.*]] = bitcast double* [[PTR]] to i64*
; GFX9-NEXT:    [[TMP3:%.*]] = bitcast double [[NEW]] to i64
; GFX9-NEXT:    [[TMP4:%.*]] = bitcast double [[LOADED]] to i64
; GFX9-NEXT:    [[TMP5:%.*]] = cmpxchg i64* [[TMP2]], i64 [[TMP4]], i64 [[TMP3]] seq_cst seq_cst
; GFX9-NEXT:    [[SUCCESS:%.*]] = extractvalue { i64, i1 } [[TMP5]], 1
; GFX9-NEXT:    [[NEWLOADED:%.*]] = extractvalue { i64, i1 } [[TMP5]], 0
; GFX9-NEXT:    [[TMP6]] = bitcast i64 [[NEWLOADED]] to double
; GFX9-NEXT:    br i1 [[SUCCESS]], label [[ATOMICRMW_END:%.*]], label [[ATOMICRMW_START]]
; GFX9:       atomicrmw.end:
; GFX9-NEXT:    ret double [[TMP6]]
;
  %res = atomicrmw fadd double* %ptr, double %value seq_cst
  ret double %res
}

define double @test_atomicrmw_fadd_f64_global(double addrspace(1)* %ptr, double %value) {
; CI-LABEL: @test_atomicrmw_fadd_f64_global(
; CI-NEXT:    [[TMP1:%.*]] = load double, double addrspace(1)* [[PTR:%.*]], align 8
; CI-NEXT:    br label [[ATOMICRMW_START:%.*]]
; CI:       atomicrmw.start:
; CI-NEXT:    [[LOADED:%.*]] = phi double [ [[TMP1]], [[TMP0:%.*]] ], [ [[TMP6:%.*]], [[ATOMICRMW_START]] ]
; CI-NEXT:    [[NEW:%.*]] = fadd double [[LOADED]], [[VALUE:%.*]]
; CI-NEXT:    [[TMP2:%.*]] = bitcast double addrspace(1)* [[PTR]] to i64 addrspace(1)*
; CI-NEXT:    [[TMP3:%.*]] = bitcast double [[NEW]] to i64
; CI-NEXT:    [[TMP4:%.*]] = bitcast double [[LOADED]] to i64
; CI-NEXT:    [[TMP5:%.*]] = cmpxchg i64 addrspace(1)* [[TMP2]], i64 [[TMP4]], i64 [[TMP3]] seq_cst seq_cst
; CI-NEXT:    [[SUCCESS:%.*]] = extractvalue { i64, i1 } [[TMP5]], 1
; CI-NEXT:    [[NEWLOADED:%.*]] = extractvalue { i64, i1 } [[TMP5]], 0
; CI-NEXT:    [[TMP6]] = bitcast i64 [[NEWLOADED]] to double
; CI-NEXT:    br i1 [[SUCCESS]], label [[ATOMICRMW_END:%.*]], label [[ATOMICRMW_START]]
; CI:       atomicrmw.end:
; CI-NEXT:    ret double [[TMP6]]
;
; GFX9-LABEL: @test_atomicrmw_fadd_f64_global(
; GFX9-NEXT:    [[TMP1:%.*]] = load double, double addrspace(1)* [[PTR:%.*]], align 8
; GFX9-NEXT:    br label [[ATOMICRMW_START:%.*]]
; GFX9:       atomicrmw.start:
; GFX9-NEXT:    [[LOADED:%.*]] = phi double [ [[TMP1]], [[TMP0:%.*]] ], [ [[TMP6:%.*]], [[ATOMICRMW_START]] ]
; GFX9-NEXT:    [[NEW:%.*]] = fadd double [[LOADED]], [[VALUE:%.*]]
; GFX9-NEXT:    [[TMP2:%.*]] = bitcast double addrspace(1)* [[PTR]] to i64 addrspace(1)*
; GFX9-NEXT:    [[TMP3:%.*]] = bitcast double [[NEW]] to i64
; GFX9-NEXT:    [[TMP4:%.*]] = bitcast double [[LOADED]] to i64
; GFX9-NEXT:    [[TMP5:%.*]] = cmpxchg i64 addrspace(1)* [[TMP2]], i64 [[TMP4]], i64 [[TMP3]] seq_cst seq_cst
; GFX9-NEXT:    [[SUCCESS:%.*]] = extractvalue { i64, i1 } [[TMP5]], 1
; GFX9-NEXT:    [[NEWLOADED:%.*]] = extractvalue { i64, i1 } [[TMP5]], 0
; GFX9-NEXT:    [[TMP6]] = bitcast i64 [[NEWLOADED]] to double
; GFX9-NEXT:    br i1 [[SUCCESS]], label [[ATOMICRMW_END:%.*]], label [[ATOMICRMW_START]]
; GFX9:       atomicrmw.end:
; GFX9-NEXT:    ret double [[TMP6]]
;
  %res = atomicrmw fadd double addrspace(1)* %ptr, double %value seq_cst
  ret double %res
}

define double @test_atomicrmw_fadd_f64_local(double addrspace(3)* %ptr, double %value) {
; CI-LABEL: @test_atomicrmw_fadd_f64_local(
; CI-NEXT:    [[TMP1:%.*]] = load double, double addrspace(3)* [[PTR:%.*]], align 8
; CI-NEXT:    br label [[ATOMICRMW_START:%.*]]
; CI:       atomicrmw.start:
; CI-NEXT:    [[LOADED:%.*]] = phi double [ [[TMP1]], [[TMP0:%.*]] ], [ [[TMP6:%.*]], [[ATOMICRMW_START]] ]
; CI-NEXT:    [[NEW:%.*]] = fadd double [[LOADED]], [[VALUE:%.*]]
; CI-NEXT:    [[TMP2:%.*]] = bitcast double addrspace(3)* [[PTR]] to i64 addrspace(3)*
; CI-NEXT:    [[TMP3:%.*]] = bitcast double [[NEW]] to i64
; CI-NEXT:    [[TMP4:%.*]] = bitcast double [[LOADED]] to i64
; CI-NEXT:    [[TMP5:%.*]] = cmpxchg i64 addrspace(3)* [[TMP2]], i64 [[TMP4]], i64 [[TMP3]] seq_cst seq_cst
; CI-NEXT:    [[SUCCESS:%.*]] = extractvalue { i64, i1 } [[TMP5]], 1
; CI-NEXT:    [[NEWLOADED:%.*]] = extractvalue { i64, i1 } [[TMP5]], 0
; CI-NEXT:    [[TMP6]] = bitcast i64 [[NEWLOADED]] to double
; CI-NEXT:    br i1 [[SUCCESS]], label [[ATOMICRMW_END:%.*]], label [[ATOMICRMW_START]]
; CI:       atomicrmw.end:
; CI-NEXT:    ret double [[TMP6]]
;
; GFX9-LABEL: @test_atomicrmw_fadd_f64_local(
; GFX9-NEXT:    [[TMP1:%.*]] = load double, double addrspace(3)* [[PTR:%.*]], align 8
; GFX9-NEXT:    br label [[ATOMICRMW_START:%.*]]
; GFX9:       atomicrmw.start:
; GFX9-NEXT:    [[LOADED:%.*]] = phi double [ [[TMP1]], [[TMP0:%.*]] ], [ [[TMP6:%.*]], [[ATOMICRMW_START]] ]
; GFX9-NEXT:    [[NEW:%.*]] = fadd double [[LOADED]], [[VALUE:%.*]]
; GFX9-NEXT:    [[TMP2:%.*]] = bitcast double addrspace(3)* [[PTR]] to i64 addrspace(3)*
; GFX9-NEXT:    [[TMP3:%.*]] = bitcast double [[NEW]] to i64
; GFX9-NEXT:    [[TMP4:%.*]] = bitcast double [[LOADED]] to i64
; GFX9-NEXT:    [[TMP5:%.*]] = cmpxchg i64 addrspace(3)* [[TMP2]], i64 [[TMP4]], i64 [[TMP3]] seq_cst seq_cst
; GFX9-NEXT:    [[SUCCESS:%.*]] = extractvalue { i64, i1 } [[TMP5]], 1
; GFX9-NEXT:    [[NEWLOADED:%.*]] = extractvalue { i64, i1 } [[TMP5]], 0
; GFX9-NEXT:    [[TMP6]] = bitcast i64 [[NEWLOADED]] to double
; GFX9-NEXT:    br i1 [[SUCCESS]], label [[ATOMICRMW_END:%.*]], label [[ATOMICRMW_START]]
; GFX9:       atomicrmw.end:
; GFX9-NEXT:    ret double [[TMP6]]
;
  %res = atomicrmw fadd double addrspace(3)* %ptr, double %value seq_cst
  ret double %res
}

