; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S | FileCheck %s

define i32 @test([1024 x i8]* %target) {
; CHECK-LABEL: @test(
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr inbounds [1024 x i8], [1024 x i8]* [[TARGET:%.*]], i64 0, i64 0
; CHECK-NEXT:    store i8 1, i8* [[TMP1]], align 1
; CHECK-NEXT:    [[TMP2:%.*]] = bitcast [1024 x i8]* [[TARGET]] to i16*
; CHECK-NEXT:    store i16 257, i16* [[TMP2]], align 2
; CHECK-NEXT:    [[TMP3:%.*]] = bitcast [1024 x i8]* [[TARGET]] to i32*
; CHECK-NEXT:    store i32 16843009, i32* [[TMP3]], align 4
; CHECK-NEXT:    [[TMP4:%.*]] = bitcast [1024 x i8]* [[TARGET]] to i64*
; CHECK-NEXT:    store i64 72340172838076673, i64* [[TMP4]], align 8
; CHECK-NEXT:    ret i32 0
;
  %target_p = getelementptr [1024 x i8], [1024 x i8]* %target, i32 0, i32 0
  call void @llvm.memset.p0i8.i32(i8* %target_p, i8 1, i32 0, i1 false)
  call void @llvm.memset.p0i8.i32(i8* %target_p, i8 1, i32 1, i1 false)
  call void @llvm.memset.p0i8.i32(i8* align 2 %target_p, i8 1, i32 2, i1 false)
  call void @llvm.memset.p0i8.i32(i8* align 4 %target_p, i8 1, i32 4, i1 false)
  call void @llvm.memset.p0i8.i32(i8* align 8 %target_p, i8 1, i32 8, i1 false)
  ret i32 0
}

@Unknown = external constant i128

define void @memset_to_constant() {
; CHECK-LABEL: @memset_to_constant(
; CHECK-NEXT:    call void @llvm.memset.p0i8.i32(i8* align 4 bitcast (i128* @Unknown to i8*), i8 0, i32 16, i1 false)
; CHECK-NEXT:    ret void
;
  %p = bitcast i128* @Unknown to i8*
  call void @llvm.memset.p0i8.i32(i8* %p, i8 0, i32 16, i1 false)
  ret void
}

declare void @llvm.memset.p0i8.i32(i8* nocapture writeonly, i8, i32, i1) argmemonly nounwind
