; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -hotcoldsplit -hotcoldsplit-threshold=0 < %s 2>&1 | FileCheck %s

declare void @llvm.lifetime.start.p0i8(i64, i8* nocapture)

declare void @llvm.lifetime.end.p0i8(i64, i8* nocapture)

declare void @cold_use(i8*) cold

; In this CFG, splitting will extract the blocks extract{1,2}. I.e., it will
; extract a lifetime.start marker, but not the corresponding lifetime.end
; marker. Make sure that a lifetime.start marker is emitted before the call to
; the split function, and *only* that marker.
;
;            entry
;          /       \
;      extract1  no-extract1
;     (lt.start)    |
;    /              |
; extract2          |
;    \_____         |
;          \      /
;            exit
;          (lt.end)
;
; After splitting, we should see:
;
;            entry
;          /       \
;      codeRepl  no-extract1
;     (lt.start)   |
;          \      /
;            exit
;          (lt.end)
define void @only_lifetime_start_is_cold() {
; CHECK-LABEL: @only_lifetime_start_is_cold(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[LOCAL1:%.*]] = alloca i256
; CHECK-NEXT:    [[LOCAL1_CAST:%.*]] = bitcast i256* [[LOCAL1]] to i8*
; CHECK-NEXT:    br i1 undef, label [[CODEREPL:%.*]], label [[NO_EXTRACT1:%.*]]
; CHECK:       codeRepl:
; CHECK-NEXT:    [[LT_CAST:%.*]] = bitcast i256* [[LOCAL1]] to i8*
; CHECK-NEXT:    call void @llvm.lifetime.start.p0i8(i64 -1, i8* [[LT_CAST]])
; CHECK-NEXT:    [[TARGETBLOCK:%.*]] = call i1 @only_lifetime_start_is_cold.cold.1(i8* [[LOCAL1_CAST]]) #3
; CHECK-NEXT:    br i1 [[TARGETBLOCK]], label [[NO_EXTRACT1]], label [[EXIT:%.*]]
; CHECK:       no-extract1:
; CHECK-NEXT:    br label [[EXIT]]
; CHECK:       exit:
; CHECK-NEXT:    call void @llvm.lifetime.end.p0i8(i64 1, i8* [[LOCAL1_CAST]])
; CHECK-NEXT:    ret void
;
entry:
  %local1 = alloca i256
  %local1_cast = bitcast i256* %local1 to i8*
  br i1 undef, label %extract1, label %no-extract1

extract1:
  ; lt.start
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %local1_cast)
  call void @cold_use(i8* %local1_cast)
  br i1 undef, label %extract2, label %no-extract1

extract2:
  br label %exit

no-extract1:
  br label %exit

exit:
  ; lt.end
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %local1_cast)
  ret void
}

; In this CFG, splitting will extract the block extract1. I.e., it will extract
; a lifetime.end marker, but not the corresponding lifetime.start marker. Make
; sure that a lifetime.end marker is emitted after the call to the split
; function, and *only* that marker.
;
;            entry
;         (lt.start)
;        /          \
;   no-extract1  extract1
;    (lt.end)    (lt.end)
;        \         /
;            exit
;
; After splitting, we should see:
;
;            entry
;         (lt.start)
;        /          \
;   no-extract1  codeRepl
;    (lt.end)    (lt.end)
;        \         /
;            exit
define void @only_lifetime_end_is_cold() {
; CHECK-LABEL: @only_lifetime_end_is_cold(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[LOCAL1:%.*]] = alloca i256
; CHECK-NEXT:    [[LOCAL1_CAST:%.*]] = bitcast i256* [[LOCAL1]] to i8*
; CHECK-NEXT:    call void @llvm.lifetime.start.p0i8(i64 1, i8* [[LOCAL1_CAST]])
; CHECK-NEXT:    br i1 undef, label [[NO_EXTRACT1:%.*]], label [[CODEREPL:%.*]]
; CHECK:       no-extract1:
; CHECK-NEXT:    call void @llvm.lifetime.end.p0i8(i64 1, i8* [[LOCAL1_CAST]])
; CHECK-NEXT:    br label [[EXIT:%.*]]
; CHECK:       codeRepl:
; CHECK-NEXT:    [[LT_CAST:%.*]] = bitcast i256* [[LOCAL1]] to i8*
; CHECK-NEXT:    call void @only_lifetime_end_is_cold.cold.1(i8* [[LOCAL1_CAST]]) #3
; CHECK-NEXT:    call void @llvm.lifetime.end.p0i8(i64 -1, i8* [[LT_CAST]])
; CHECK-NEXT:    br label [[EXIT]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  ; lt.start
  %local1 = alloca i256
  %local1_cast = bitcast i256* %local1 to i8*
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %local1_cast)
  br i1 undef, label %no-extract1, label %extract1

no-extract1:
  ; lt.end
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %local1_cast)
  br label %exit

extract1:
  ; lt.end
  call void @cold_use(i8* %local1_cast)
  call void @llvm.lifetime.end.p0i8(i64 1, i8* %local1_cast)
  br label %exit

exit:
  ret void
}
