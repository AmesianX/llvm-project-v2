; Test lib call simplification of __memset_chk calls with various values
; for dstlen and len.
;
; RUN: opt < %s -instcombine -S | FileCheck %s
; rdar://7719085

target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64"

%struct.T = type { [100 x i32], [100 x i32], [1024 x i8] }
@t = common global %struct.T zeroinitializer

; Check cases where dstlen >= len.

define i8* @test_simplify1() {
; CHECK-LABEL: @test_simplify1(
  %dst = bitcast %struct.T* @t to i8*

; CHECK-NEXT: call void @llvm.memset.p0i8.i64(i8* align 4 bitcast (%struct.T* @t to i8*), i8 0, i64 1824, i1 false)
; CHECK-NEXT: ret i8* bitcast (%struct.T* @t to i8*)
  %ret = call i8* @__memset_chk(i8* %dst, i32 0, i64 1824, i64 1824)
  ret i8* %ret
}

define i8* @test_simplify2() {
; CHECK-LABEL: @test_simplify2(
  %dst = bitcast %struct.T* @t to i8*

; CHECK-NEXT: call void @llvm.memset.p0i8.i64(i8* align 4 bitcast (%struct.T* @t to i8*), i8 0, i64 1824, i1 false)
; CHECK-NEXT: ret i8* bitcast (%struct.T* @t to i8*)
  %ret = call i8* @__memset_chk(i8* %dst, i32 0, i64 1824, i64 3648)
  ret i8* %ret
}

define i8* @test_simplify3() {
; CHECK-LABEL: @test_simplify3(
  %dst = bitcast %struct.T* @t to i8*

; CHECK-NEXT: call void @llvm.memset.p0i8.i64(i8* align 4 bitcast (%struct.T* @t to i8*), i8 0, i64 1824, i1 false)
; CHECK-NEXT: ret i8* bitcast (%struct.T* @t to i8*)
  %ret = call i8* @__memset_chk(i8* %dst, i32 0, i64 1824, i64 -1)
  ret i8* %ret
}

; Check cases where dstlen < len.

define i8* @test_no_simplify1() {
; CHECK-LABEL: @test_no_simplify1(
  %dst = bitcast %struct.T* @t to i8*

; CHECK-NEXT: %ret = call i8* @__memset_chk(i8* bitcast (%struct.T* @t to i8*), i32 0, i64 1824, i64 400)
; CHECK-NEXT: ret i8* %ret
  %ret = call i8* @__memset_chk(i8* %dst, i32 0, i64 1824, i64 400)
  ret i8* %ret
}

define i8* @test_no_simplify2() {
; CHECK-LABEL: @test_no_simplify2(
  %dst = bitcast %struct.T* @t to i8*

; CHECK-NEXT: %ret = call i8* @__memset_chk(i8* bitcast (%struct.T* @t to i8*), i32 0, i64 1824, i64 0)
; CHECK-NEXT: ret i8* %ret
  %ret = call i8* @__memset_chk(i8* %dst, i32 0, i64 1824, i64 0)
  ret i8* %ret
}

; Test that RAUW in SimplifyLibCalls for __memset_chk generates valid IR
define i32 @test_rauw(i8* %a, i8* %b, i8** %c) {
; CHECK-LABEL: test_rauw
entry:
  %call49 = call i64 @strlen(i8* %a)
  %add180 = add i64 %call49, 1
  %yo107 = call i64 @llvm.objectsize.i64.p0i8(i8* %b, i1 false)
  %call50 = call i8* @__memmove_chk(i8* %b, i8* %a, i64 %add180, i64 %yo107)
; CHECK: %strlen = call i64 @strlen(i8* %b)
; CHECK-NEXT: %strchr2 = getelementptr i8, i8* %b, i64 %strlen
  %call51i = call i8* @strrchr(i8* %b, i32 0)
  %d = load i8*, i8** %c, align 8
  %sub182 = ptrtoint i8* %d to i64
  %sub183 = ptrtoint i8* %b to i64
  %sub184 = sub i64 %sub182, %sub183
  %add52.i.i = add nsw i64 %sub184, 1
; CHECK: call void @llvm.memset.p0i8.i64(i8* align 1 %strchr2
  %call185 = call i8* @__memset_chk(i8* %call51i, i32 0, i64 %add52.i.i, i64 -1)
  ret i32 4
}

declare i8* @__memmove_chk(i8*, i8*, i64, i64)
declare i8* @strrchr(i8*, i32)
declare i64 @strlen(i8* nocapture)
declare i64 @llvm.objectsize.i64.p0i8(i8*, i1)

declare i8* @__memset_chk(i8*, i32, i64, i64)
