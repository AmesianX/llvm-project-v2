; RUN: opt %loadPolly -polly-scops -analyze < %s | FileCheck %s --check-prefix=SCOP
; RUN: opt %loadPolly -polly-codegen -S < %s | FileCheck %s
;
; This caused the code generation to emit a broken module as there are two
; dependences that need to be considered, thus code has to be emitted in a
; certain order:
;   1) To preload A[N * M] the expression N * M [p0] is needed (both for the
;      condition under which A[N * M] is executed as well as to compute the
;      index).
;   2) To generate (A[N * M] / 2) [p1] the preloaded value is needed.
;
; SCOP: p0: (%N * %M)
; SCOP: p1: (%tmp4 /u 2)
;
; CHECK: polly.preload.merge:
; CHECK:   %polly.preload.tmp4.merge = phi i32 [ %polly.access.A.load, %polly.preload.exec ], [ 0, %polly.preload.cond ]
; CHECK:   %3 = lshr i32 %polly.preload.tmp4.merge, 1
; CHECK:   %4 = sext i32 %0 to i64
;
;    void f(int *restrict A, int *restrict B, int N, int M) {
;
;      for (int i = 0; i < N * M; i++)
;        for (int j = 0; j < A[N * M] / 2; j++)
;          B[i + j]++;
;    }
;
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

define void @f(i32* noalias %A, i32* noalias %B, i32 %N, i32 %M) {
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc.8, %entry
  %indvars.iv2 = phi i64 [ %indvars.iv.next3, %for.inc.8 ], [ 0, %entry ]
  %mul = mul nsw i32 %N, %M
  %tmp = sext i32 %mul to i64
  %cmp = icmp slt i64 %indvars.iv2, %tmp
  br i1 %cmp, label %for.body, label %for.end.10

for.body:                                         ; preds = %for.cond
  br label %for.cond.1

for.cond.1:                                       ; preds = %for.inc, %for.body
  %indvars.iv = phi i64 [ %indvars.iv.next, %for.inc ], [ 0, %for.body ]
  %mul2 = mul nsw i32 %N, %M
  %idxprom = sext i32 %mul2 to i64
  %arrayidx = getelementptr inbounds i32, i32* %A, i64 %idxprom
  %tmp4 = load i32, i32* %arrayidx, align 4
  %div = udiv i32 %tmp4, 2
  %tmp5 = sext i32 %div to i64
  %cmp3 = icmp slt i64 %indvars.iv, %tmp5
  br i1 %cmp3, label %for.body.4, label %for.end

for.body.4:                                       ; preds = %for.cond.1
  %tmp6 = add nsw i64 %indvars.iv2, %indvars.iv
  %arrayidx6 = getelementptr inbounds i32, i32* %B, i64 %tmp6
  %tmp7 = load i32, i32* %arrayidx6, align 4
  %inc = add nsw i32 %tmp7, 1
  store i32 %inc, i32* %arrayidx6, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body.4
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  br label %for.cond.1

for.end:                                          ; preds = %for.cond.1
  br label %for.inc.8

for.inc.8:                                        ; preds = %for.end
  %indvars.iv.next3 = add nuw nsw i64 %indvars.iv2, 1
  br label %for.cond

for.end.10:                                       ; preds = %for.cond
  ret void
}
