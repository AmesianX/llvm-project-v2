; RUN: opt %loadPolly  -polly-codegen -polly-invariant-load-hoisting=true -polly-ignore-aliasing -polly-process-unprofitable -S < %s | FileCheck %s
;
; CHECK-LABEL: polly.preload.begin:
; CHECK-NEXT:    %polly.access.BPLoc = getelementptr i32*, i32** %BPLoc, i64 0
; CHECK-NEXT:    %polly.access.BPLoc.load = load i32*, i32** %polly.access.BPLoc
;
; CHECK-LABEL: polly.stmt.bb2:
; CHECK-NEXT:    %scevgep = getelementptr i32, i32* %polly.access.BPLoc.load, i64 %polly.indvar
;
;    void f(int **BPLoc) {
;      for (int i = 0; i < 1024; i++)
;        (*BPLoc)[i] = 0;
;    }
;
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

define void @f(i32** %BPLoc) {
bb:
  br label %bb1

bb1:                                              ; preds = %bb4, %bb
  %indvars.iv = phi i64 [ %indvars.iv.next, %bb4 ], [ 0, %bb ]
  %exitcond = icmp ne i64 %indvars.iv, 1024
  br i1 %exitcond, label %bb2, label %bb5

bb2:                                              ; preds = %bb1
  %tmp = load i32*, i32** %BPLoc, align 8
  %tmp3 = getelementptr inbounds i32, i32* %tmp, i64 %indvars.iv
  store i32 0, i32* %tmp3, align 4
  br label %bb4

bb4:                                              ; preds = %bb2
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  br label %bb1

bb5:                                              ; preds = %bb1
  ret void
}
