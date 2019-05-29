; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -passes=spec-phis < %s | FileCheck %s
; Make sure convergent and noduplicate calls aren't duplicated.

declare i32 @llvm.convergent(i32) #0
declare i32 @llvm.noduplicate(i32) #1
declare i32 @llvm.regular(i32) #2

define i32 @test_convergent(i1 %flag, i32 %arg) #0 {
; CHECK-LABEL: @test_convergent(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br i1 [[FLAG:%.*]], label [[A:%.*]], label [[B:%.*]]
; CHECK:       a:
; CHECK-NEXT:    br label [[EXIT:%.*]]
; CHECK:       b:
; CHECK-NEXT:    br label [[EXIT]]
; CHECK:       exit:
; CHECK-NEXT:    [[P:%.*]] = phi i32 [ 7, [[A]] ], [ 11, [[B]] ]
; CHECK-NEXT:    [[SUM:%.*]] = call i32 @llvm.convergent(i32 [[P]])
; CHECK-NEXT:    ret i32 [[SUM]]
;
entry:
  br i1 %flag, label %a, label %b

a:
  br label %exit

b:
  br label %exit

exit:
  %p = phi i32 [ 7, %a ], [ 11, %b ]
  %sum = call i32 @llvm.convergent(i32 %p)
  ret i32 %sum
}

define i32 @test_noduplicate(i1 %flag, i32 %arg) #1 {
; CHECK-LABEL: @test_noduplicate(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br i1 [[FLAG:%.*]], label [[A:%.*]], label [[B:%.*]]
; CHECK:       a:
; CHECK-NEXT:    br label [[EXIT:%.*]]
; CHECK:       b:
; CHECK-NEXT:    br label [[EXIT]]
; CHECK:       exit:
; CHECK-NEXT:    [[P:%.*]] = phi i32 [ 7, [[A]] ], [ 11, [[B]] ]
; CHECK-NEXT:    [[SUM:%.*]] = call i32 @llvm.noduplicate(i32 [[P]])
; CHECK-NEXT:    ret i32 [[SUM]]
;
entry:
  br i1 %flag, label %a, label %b

a:
  br label %exit

b:
  br label %exit

exit:
  %p = phi i32 [ 7, %a ], [ 11, %b ]
  %sum = call i32 @llvm.noduplicate(i32 %p)
  ret i32 %sum
}

; Otherwise identical function which should be transformed.
define i32 @test_reference(i1 %flag, i32 %arg) #2 {
; CHECK-LABEL: @test_reference(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br i1 [[FLAG:%.*]], label [[A:%.*]], label [[B:%.*]]
; CHECK:       a:
; CHECK-NEXT:    [[SUM_0:%.*]] = call i32 @llvm.regular(i32 7)
; CHECK-NEXT:    br label [[EXIT:%.*]]
; CHECK:       b:
; CHECK-NEXT:    [[SUM_1:%.*]] = call i32 @llvm.regular(i32 11)
; CHECK-NEXT:    br label [[EXIT]]
; CHECK:       exit:
; CHECK-NEXT:    [[SUM_PHI:%.*]] = phi i32 [ [[SUM_0]], [[A]] ], [ [[SUM_1]], [[B]] ]
; CHECK-NEXT:    ret i32 [[SUM_PHI]]
;
entry:
  br i1 %flag, label %a, label %b

a:
  br label %exit

b:
  br label %exit

exit:
  %p = phi i32 [ 7, %a ], [ 11, %b ]
  %sum = call i32 @llvm.regular(i32 %p)
  ret i32 %sum
}


attributes #0 = { nounwind readnone convergent speculatable }
attributes #1 = { nounwind readnone noduplicate speculatable }
attributes #2 = { nounwind readnone speculatable }
