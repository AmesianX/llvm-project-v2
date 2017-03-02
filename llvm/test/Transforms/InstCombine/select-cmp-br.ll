; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; Replace a 'select' with 'or' in 'select - cmp [eq|ne] - br' sequence
; RUN: opt -instcombine -S < %s | FileCheck %s

%struct.S = type { i64*, i32, i32 }
%C = type <{ %struct.S }>

declare void @bar(%struct.S*)
declare void @foobar()

define void @test1(%C* %arg) {
; CHECK-LABEL: @test1(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP:%.*]] = getelementptr inbounds [[C:%.*]], %C* [[ARG:%.*]], i64 0, i32 0, i32 0
; CHECK-NEXT:    [[M:%.*]] = load i64*, i64** [[TMP]], align 8
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr inbounds [[C]], %C* [[ARG]], i64 1, i32 0, i32 0
; CHECK-NEXT:    [[N:%.*]] = load i64*, i64** [[TMP1]], align 8
; CHECK-NEXT:    [[TMP71:%.*]] = icmp eq %C* [[ARG]], null
; CHECK-NEXT:    [[NOT_TMP5:%.*]] = icmp ne i64* [[M]], [[N]]
; CHECK-NEXT:    [[TMP7:%.*]] = or i1 [[TMP71]], [[NOT_TMP5]]
; CHECK-NEXT:    br i1 [[TMP7]], label [[BB10:%.*]], label [[BB8:%.*]]
; CHECK:       bb:
; CHECK-NEXT:    ret void
; CHECK:       bb8:
; CHECK-NEXT:    [[TMP9:%.*]] = getelementptr inbounds [[C]], %C* [[ARG]], i64 0, i32 0
; CHECK-NEXT:    tail call void @bar(%struct.S* [[TMP9]])
; CHECK-NEXT:    br label [[BB:%.*]]
; CHECK:       bb10:
; CHECK-NEXT:    [[TMP2:%.*]] = getelementptr inbounds i64, i64* [[M]], i64 9
; CHECK-NEXT:    [[TMP3:%.*]] = bitcast i64* [[TMP2]] to i64 (%C*)**
; CHECK-NEXT:    [[TMP4:%.*]] = load i64 (%C*)*, i64 (%C*)** [[TMP3]], align 8
; CHECK-NEXT:    [[TMP11:%.*]] = tail call i64 [[TMP4]](%C* [[ARG]])
; CHECK-NEXT:    br label [[BB]]
;
entry:
  %tmp = getelementptr inbounds %C, %C* %arg, i64 0, i32 0, i32 0
  %m = load i64*, i64** %tmp, align 8
  %tmp1 = getelementptr inbounds %C, %C* %arg, i64 1, i32 0, i32 0
  %n = load i64*, i64** %tmp1, align 8
  %tmp2 = getelementptr inbounds i64, i64* %m, i64 9
  %tmp3 = bitcast i64* %tmp2 to i64 (%C*)**
  %tmp4 = load i64 (%C*)*, i64 (%C*)** %tmp3, align 8
  %tmp5 = icmp eq i64* %m, %n
  %tmp6 = select i1 %tmp5, %C* %arg, %C* null
  %tmp7 = icmp eq %C* %tmp6, null
  br i1 %tmp7, label %bb10, label %bb8

bb:                                               ; preds = %bb10, %bb8
  ret void

bb8:                                              ; preds = %entry
  %tmp9 = getelementptr inbounds %C, %C* %tmp6, i64 0, i32 0
  tail call void @bar(%struct.S* %tmp9)
  br label %bb

bb10:                                             ; preds = %entry
  %tmp11 = tail call i64 %tmp4(%C* %arg)
  br label %bb
}

define void @test2(%C* %arg) {
; CHECK-LABEL: @test2(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP:%.*]] = getelementptr inbounds [[C:%.*]], %C* [[ARG:%.*]], i64 0, i32 0, i32 0
; CHECK-NEXT:    [[M:%.*]] = load i64*, i64** [[TMP]], align 8
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr inbounds [[C]], %C* [[ARG]], i64 1, i32 0, i32 0
; CHECK-NEXT:    [[N:%.*]] = load i64*, i64** [[TMP1]], align 8
; CHECK-NEXT:    [[TMP5:%.*]] = icmp eq i64* [[M]], [[N]]
; CHECK-NEXT:    [[TMP71:%.*]] = icmp eq %C* [[ARG]], null
; CHECK-NEXT:    [[TMP7:%.*]] = or i1 [[TMP5]], [[TMP71]]
; CHECK-NEXT:    br i1 [[TMP7]], label [[BB10:%.*]], label [[BB8:%.*]]
; CHECK:       bb:
; CHECK-NEXT:    ret void
; CHECK:       bb8:
; CHECK-NEXT:    [[TMP9:%.*]] = getelementptr inbounds [[C]], %C* [[ARG]], i64 0, i32 0
; CHECK-NEXT:    tail call void @bar(%struct.S* [[TMP9]])
; CHECK-NEXT:    br label [[BB:%.*]]
; CHECK:       bb10:
; CHECK-NEXT:    [[TMP2:%.*]] = getelementptr inbounds i64, i64* [[M]], i64 9
; CHECK-NEXT:    [[TMP3:%.*]] = bitcast i64* [[TMP2]] to i64 (%C*)**
; CHECK-NEXT:    [[TMP4:%.*]] = load i64 (%C*)*, i64 (%C*)** [[TMP3]], align 8
; CHECK-NEXT:    [[TMP11:%.*]] = tail call i64 [[TMP4]](%C* [[ARG]])
; CHECK-NEXT:    br label [[BB]]
;
entry:
  %tmp = getelementptr inbounds %C, %C* %arg, i64 0, i32 0, i32 0
  %m = load i64*, i64** %tmp, align 8
  %tmp1 = getelementptr inbounds %C, %C* %arg, i64 1, i32 0, i32 0
  %n = load i64*, i64** %tmp1, align 8
  %tmp2 = getelementptr inbounds i64, i64* %m, i64 9
  %tmp3 = bitcast i64* %tmp2 to i64 (%C*)**
  %tmp4 = load i64 (%C*)*, i64 (%C*)** %tmp3, align 8
  %tmp5 = icmp eq i64* %m, %n
  %tmp6 = select i1 %tmp5, %C* null, %C* %arg
  %tmp7 = icmp eq %C* %tmp6, null
  br i1 %tmp7, label %bb10, label %bb8

bb:                                               ; preds = %bb10, %bb8
  ret void

bb8:                                              ; preds = %entry
  %tmp9 = getelementptr inbounds %C, %C* %tmp6, i64 0, i32 0
  tail call void @bar(%struct.S* %tmp9)
  br label %bb

bb10:                                             ; preds = %entry
  %tmp11 = tail call i64 %tmp4(%C* %arg)
  br label %bb
}

define void @test3(%C* %arg) {
; CHECK-LABEL: @test3(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP:%.*]] = getelementptr inbounds [[C:%.*]], %C* [[ARG:%.*]], i64 0, i32 0, i32 0
; CHECK-NEXT:    [[M:%.*]] = load i64*, i64** [[TMP]], align 8
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr inbounds [[C]], %C* [[ARG]], i64 1, i32 0, i32 0
; CHECK-NEXT:    [[N:%.*]] = load i64*, i64** [[TMP1]], align 8
; CHECK-NEXT:    [[TMP71:%.*]] = icmp eq %C* [[ARG]], null
; CHECK-NEXT:    [[NOT_TMP5:%.*]] = icmp ne i64* [[M]], [[N]]
; CHECK-NEXT:    [[TMP7:%.*]] = or i1 [[TMP71]], [[NOT_TMP5]]
; CHECK-NEXT:    br i1 [[TMP7]], label [[BB10:%.*]], label [[BB8:%.*]]
; CHECK:       bb:
; CHECK-NEXT:    ret void
; CHECK:       bb8:
; CHECK-NEXT:    [[TMP9:%.*]] = getelementptr inbounds [[C]], %C* [[ARG]], i64 0, i32 0
; CHECK-NEXT:    tail call void @bar(%struct.S* [[TMP9]])
; CHECK-NEXT:    br label [[BB:%.*]]
; CHECK:       bb10:
; CHECK-NEXT:    [[TMP2:%.*]] = getelementptr inbounds i64, i64* [[M]], i64 9
; CHECK-NEXT:    [[TMP3:%.*]] = bitcast i64* [[TMP2]] to i64 (%C*)**
; CHECK-NEXT:    [[TMP4:%.*]] = load i64 (%C*)*, i64 (%C*)** [[TMP3]], align 8
; CHECK-NEXT:    [[TMP11:%.*]] = tail call i64 [[TMP4]](%C* [[ARG]])
; CHECK-NEXT:    br label [[BB]]
;
entry:
  %tmp = getelementptr inbounds %C, %C* %arg, i64 0, i32 0, i32 0
  %m = load i64*, i64** %tmp, align 8
  %tmp1 = getelementptr inbounds %C, %C* %arg, i64 1, i32 0, i32 0
  %n = load i64*, i64** %tmp1, align 8
  %tmp2 = getelementptr inbounds i64, i64* %m, i64 9
  %tmp3 = bitcast i64* %tmp2 to i64 (%C*)**
  %tmp4 = load i64 (%C*)*, i64 (%C*)** %tmp3, align 8
  %tmp5 = icmp eq i64* %m, %n
  %tmp6 = select i1 %tmp5, %C* %arg, %C* null
  %tmp7 = icmp ne %C* %tmp6, null
  br i1 %tmp7, label %bb8, label %bb10

bb:                                               ; preds = %bb10, %bb8
  ret void

bb8:                                              ; preds = %entry
  %tmp9 = getelementptr inbounds %C, %C* %tmp6, i64 0, i32 0
  tail call void @bar(%struct.S* %tmp9)
  br label %bb

bb10:                                             ; preds = %entry
  %tmp11 = tail call i64 %tmp4(%C* %arg)
  br label %bb
}

define void @test4(%C* %arg) {
; CHECK-LABEL: @test4(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP:%.*]] = getelementptr inbounds [[C:%.*]], %C* [[ARG:%.*]], i64 0, i32 0, i32 0
; CHECK-NEXT:    [[M:%.*]] = load i64*, i64** [[TMP]], align 8
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr inbounds [[C]], %C* [[ARG]], i64 1, i32 0, i32 0
; CHECK-NEXT:    [[N:%.*]] = load i64*, i64** [[TMP1]], align 8
; CHECK-NEXT:    [[TMP5:%.*]] = icmp eq i64* [[M]], [[N]]
; CHECK-NEXT:    [[TMP71:%.*]] = icmp eq %C* [[ARG]], null
; CHECK-NEXT:    [[TMP7:%.*]] = or i1 [[TMP5]], [[TMP71]]
; CHECK-NEXT:    br i1 [[TMP7]], label [[BB10:%.*]], label [[BB8:%.*]]
; CHECK:       bb:
; CHECK-NEXT:    ret void
; CHECK:       bb8:
; CHECK-NEXT:    [[TMP9:%.*]] = getelementptr inbounds [[C]], %C* [[ARG]], i64 0, i32 0
; CHECK-NEXT:    tail call void @bar(%struct.S* [[TMP9]])
; CHECK-NEXT:    br label [[BB:%.*]]
; CHECK:       bb10:
; CHECK-NEXT:    [[TMP2:%.*]] = getelementptr inbounds i64, i64* [[M]], i64 9
; CHECK-NEXT:    [[TMP3:%.*]] = bitcast i64* [[TMP2]] to i64 (%C*)**
; CHECK-NEXT:    [[TMP4:%.*]] = load i64 (%C*)*, i64 (%C*)** [[TMP3]], align 8
; CHECK-NEXT:    [[TMP11:%.*]] = tail call i64 [[TMP4]](%C* [[ARG]])
; CHECK-NEXT:    br label [[BB]]
;
entry:
  %tmp = getelementptr inbounds %C, %C* %arg, i64 0, i32 0, i32 0
  %m = load i64*, i64** %tmp, align 8
  %tmp1 = getelementptr inbounds %C, %C* %arg, i64 1, i32 0, i32 0
  %n = load i64*, i64** %tmp1, align 8
  %tmp2 = getelementptr inbounds i64, i64* %m, i64 9
  %tmp3 = bitcast i64* %tmp2 to i64 (%C*)**
  %tmp4 = load i64 (%C*)*, i64 (%C*)** %tmp3, align 8
  %tmp5 = icmp eq i64* %m, %n
  %tmp6 = select i1 %tmp5, %C* null, %C* %arg
  %tmp7 = icmp ne %C* %tmp6, null
  br i1 %tmp7, label %bb8, label %bb10

bb:                                               ; preds = %bb10, %bb8
  ret void

bb8:                                              ; preds = %entry
  %tmp9 = getelementptr inbounds %C, %C* %tmp6, i64 0, i32 0
  tail call void @bar(%struct.S* %tmp9)
  br label %bb

bb10:                                             ; preds = %entry
  %tmp11 = tail call i64 %tmp4(%C* %arg)
  br label %bb
}

define void @test5(%C* %arg, i1 %arg1) {
; CHECK-LABEL: @test5(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP21:%.*]] = icmp eq %C* [[ARG:%.*]], null
; CHECK-NEXT:    [[TMP2:%.*]] = or i1 [[TMP21]], [[ARG1:%.*]]
; CHECK-NEXT:    br i1 [[TMP2]], label [[BB5:%.*]], label [[BB3:%.*]]
; CHECK:       bb:
; CHECK-NEXT:    ret void
; CHECK:       bb3:
; CHECK-NEXT:    [[TMP4:%.*]] = getelementptr inbounds [[C:%.*]], %C* [[ARG]], i64 0, i32 0
; CHECK-NEXT:    tail call void @bar(%struct.S* [[TMP4]])
; CHECK-NEXT:    br label [[BB:%.*]]
; CHECK:       bb5:
; CHECK-NEXT:    tail call void @foobar()
; CHECK-NEXT:    br label [[BB]]
;
entry:
  %tmp = select i1 %arg1, %C* null, %C* %arg
  %tmp2 = icmp ne %C* %tmp, null
  br i1 %tmp2, label %bb3, label %bb5

bb:                                               ; preds = %bb5, %bb3
  ret void

bb3:                                              ; preds = %entry
  %tmp4 = getelementptr inbounds %C, %C* %tmp, i64 0, i32 0
  tail call void @bar(%struct.S* %tmp4)
  br label %bb

bb5:                                              ; preds = %entry
  tail call void @foobar()
  br label %bb
}

; Negative test. Must not trigger the select-cmp-br combine because the result
; of the select is used in both flows following the br (the special case where
; the conditional branch has the same target for both flows).
define i32 @test6(i32 %arg, i1 %arg1) {
; CHECK-LABEL: @test6(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br i1 undef, label [[BB:%.*]], label [[BB]]
; CHECK:       bb:
; CHECK-NEXT:    [[TMP:%.*]] = select i1 [[ARG1:%.*]], i32 [[ARG:%.*]], i32 0
; CHECK-NEXT:    ret i32 [[TMP]]
;
entry:
  %tmp = select i1 %arg1, i32 %arg, i32 0
  %tmp2 = icmp eq i32 %tmp, 0
  br i1 %tmp2, label %bb, label %bb

bb:                                               ; preds = %entry, %entry
  ret i32 %tmp
}
