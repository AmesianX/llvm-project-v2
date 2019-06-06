; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -loop-vectorize -S -mtriple=aarch64-unknown-linux-gnu -force-vector-interleave=1 -force-vector-width=4 < %s | FileCheck %s

; The test checks that there is no assert caused by issue described in PR36032

target datalayout = "e-m:e-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128"

%struct.anon = type { i8 }

@c = local_unnamed_addr global [6 x i8] zeroinitializer, align 1
@b = internal global %struct.anon zeroinitializer, align 1

; Function Attrs: noreturn nounwind
define void @_Z1dv() local_unnamed_addr #0 {
; CHECK-LABEL: @_Z1dv(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CALL:%.*]] = tail call i8* @"_ZN3$_01aEv"(%struct.anon* nonnull @b)
; CHECK-NEXT:    [[SCEVGEP1:%.*]] = getelementptr i8, i8* [[CALL]], i64 4
; CHECK-NEXT:    br label [[FOR_COND:%.*]]
; CHECK:       for.cond:
; CHECK-NEXT:    [[F_0:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[ADD5:%.*]], [[FOR_COND_CLEANUP:%.*]] ]
; CHECK-NEXT:    [[G_0:%.*]] = phi i32 [ undef, [[ENTRY]] ], [ [[G_1_LCSSA:%.*]], [[FOR_COND_CLEANUP]] ]
; CHECK-NEXT:    [[CMP12:%.*]] = icmp ult i32 [[G_0]], 4
; CHECK-NEXT:    [[CONV:%.*]] = and i32 [[F_0]], 65535
; CHECK-NEXT:    br i1 [[CMP12]], label [[FOR_BODY_LR_PH:%.*]], label [[FOR_COND_CLEANUP]]
; CHECK:       for.body.lr.ph:
; CHECK-NEXT:    [[TMP0:%.*]] = zext i32 [[G_0]] to i64
; CHECK-NEXT:    [[TMP1:%.*]] = sub i64 4, [[TMP0]]
; CHECK-NEXT:    [[MIN_ITERS_CHECK:%.*]] = icmp ult i64 [[TMP1]], 4
; CHECK-NEXT:    br i1 [[MIN_ITERS_CHECK]], label [[SCALAR_PH:%.*]], label [[VECTOR_SCEVCHECK:%.*]]
; CHECK:       vector.scevcheck:
; CHECK-NEXT:    [[TMP2:%.*]] = sub nsw i64 3, [[TMP0]]
; CHECK-NEXT:    [[TMP3:%.*]] = add i32 [[G_0]], [[CONV]]
; CHECK-NEXT:    [[TMP4:%.*]] = trunc i64 [[TMP2]] to i32
; CHECK-NEXT:    [[MUL:%.*]] = call { i32, i1 } @llvm.umul.with.overflow.i32(i32 1, i32 [[TMP4]])
; CHECK-NEXT:    [[MUL_RESULT:%.*]] = extractvalue { i32, i1 } [[MUL]], 0
; CHECK-NEXT:    [[MUL_OVERFLOW:%.*]] = extractvalue { i32, i1 } [[MUL]], 1
; CHECK-NEXT:    [[TMP5:%.*]] = add i32 [[TMP3]], [[MUL_RESULT]]
; CHECK-NEXT:    [[TMP6:%.*]] = sub i32 [[TMP3]], [[MUL_RESULT]]
; CHECK-NEXT:    [[TMP7:%.*]] = icmp ugt i32 [[TMP6]], [[TMP3]]
; CHECK-NEXT:    [[TMP8:%.*]] = icmp ult i32 [[TMP5]], [[TMP3]]
; CHECK-NEXT:    [[TMP9:%.*]] = select i1 false, i1 [[TMP7]], i1 [[TMP8]]
; CHECK-NEXT:    [[TMP10:%.*]] = icmp ugt i64 [[TMP2]], 4294967295
; CHECK-NEXT:    [[TMP11:%.*]] = or i1 [[TMP9]], [[TMP10]]
; CHECK-NEXT:    [[TMP12:%.*]] = or i1 [[TMP11]], [[MUL_OVERFLOW]]
; CHECK-NEXT:    [[TMP13:%.*]] = or i1 false, [[TMP12]]
; CHECK-NEXT:    br i1 [[TMP13]], label [[SCALAR_PH]], label [[VECTOR_MEMCHECK:%.*]]
; CHECK:       vector.memcheck:
; CHECK-NEXT:    [[SCEVGEP:%.*]] = getelementptr i8, i8* [[CALL]], i64 [[TMP0]]
; CHECK-NEXT:    [[TMP14:%.*]] = add i32 [[G_0]], [[CONV]]
; CHECK-NEXT:    [[TMP15:%.*]] = zext i32 [[TMP14]] to i64
; CHECK-NEXT:    [[SCEVGEP2:%.*]] = getelementptr [6 x i8], [6 x i8]* @c, i64 0, i64 [[TMP15]]
; CHECK-NEXT:    [[TMP16:%.*]] = sub i64 [[TMP15]], [[TMP0]]
; CHECK-NEXT:    [[SCEVGEP3:%.*]] = getelementptr i8, i8* getelementptr inbounds ([6 x i8], [6 x i8]* @c, i64 0, i64 4), i64 [[TMP16]]
; CHECK-NEXT:    [[BOUND0:%.*]] = icmp ult i8* [[SCEVGEP]], [[SCEVGEP3]]
; CHECK-NEXT:    [[BOUND1:%.*]] = icmp ult i8* [[SCEVGEP2]], [[SCEVGEP1]]
; CHECK-NEXT:    [[FOUND_CONFLICT:%.*]] = and i1 [[BOUND0]], [[BOUND1]]
; CHECK-NEXT:    [[MEMCHECK_CONFLICT:%.*]] = and i1 [[FOUND_CONFLICT]], true
; CHECK-NEXT:    br i1 [[MEMCHECK_CONFLICT]], label [[SCALAR_PH]], label [[VECTOR_PH:%.*]]
; CHECK:       vector.ph:
; CHECK-NEXT:    [[N_MOD_VF:%.*]] = urem i64 [[TMP1]], 4
; CHECK-NEXT:    [[N_VEC:%.*]] = sub i64 [[TMP1]], [[N_MOD_VF]]
; CHECK-NEXT:    [[IND_END:%.*]] = add i64 [[TMP0]], [[N_VEC]]
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[OFFSET_IDX:%.*]] = add i64 [[TMP0]], [[INDEX]]
; CHECK-NEXT:    [[BROADCAST_SPLATINSERT:%.*]] = insertelement <4 x i64> undef, i64 [[OFFSET_IDX]], i32 0
; CHECK-NEXT:    [[BROADCAST_SPLAT:%.*]] = shufflevector <4 x i64> [[BROADCAST_SPLATINSERT]], <4 x i64> undef, <4 x i32> zeroinitializer
; CHECK-NEXT:    [[INDUCTION:%.*]] = add <4 x i64> [[BROADCAST_SPLAT]], <i64 0, i64 1, i64 2, i64 3>
; CHECK-NEXT:    [[TMP17:%.*]] = add i64 [[OFFSET_IDX]], 0
; CHECK-NEXT:    [[OFFSET_IDX4:%.*]] = add i64 [[TMP0]], [[INDEX]]
; CHECK-NEXT:    [[TMP18:%.*]] = trunc i64 [[OFFSET_IDX4]] to i32
; CHECK-NEXT:    [[BROADCAST_SPLATINSERT5:%.*]] = insertelement <4 x i32> undef, i32 [[TMP18]], i32 0
; CHECK-NEXT:    [[BROADCAST_SPLAT6:%.*]] = shufflevector <4 x i32> [[BROADCAST_SPLATINSERT5]], <4 x i32> undef, <4 x i32> zeroinitializer
; CHECK-NEXT:    [[INDUCTION7:%.*]] = add <4 x i32> [[BROADCAST_SPLAT6]], <i32 0, i32 1, i32 2, i32 3>
; CHECK-NEXT:    [[TMP19:%.*]] = add i32 [[TMP18]], 0
; CHECK-NEXT:    [[TMP20:%.*]] = add i32 [[CONV]], [[TMP19]]
; CHECK-NEXT:    [[TMP21:%.*]] = zext i32 [[TMP20]] to i64
; CHECK-NEXT:    [[TMP22:%.*]] = getelementptr inbounds [6 x i8], [6 x i8]* @c, i64 0, i64 [[TMP21]]
; CHECK-NEXT:    [[TMP23:%.*]] = getelementptr inbounds i8, i8* [[TMP22]], i32 0
; CHECK-NEXT:    [[TMP24:%.*]] = bitcast i8* [[TMP23]] to <4 x i8>*
; CHECK-NEXT:    [[WIDE_LOAD:%.*]] = load <4 x i8>, <4 x i8>* [[TMP24]], align 1, !alias.scope !0
; CHECK-NEXT:    [[TMP25:%.*]] = getelementptr inbounds i8, i8* [[CALL]], i64 [[TMP17]]
; CHECK-NEXT:    [[TMP26:%.*]] = getelementptr inbounds i8, i8* [[TMP25]], i32 0
; CHECK-NEXT:    [[TMP27:%.*]] = bitcast i8* [[TMP26]] to <4 x i8>*
; CHECK-NEXT:    store <4 x i8> [[WIDE_LOAD]], <4 x i8>* [[TMP27]], align 1, !alias.scope !3, !noalias !0
; CHECK-NEXT:    [[INDEX_NEXT]] = add i64 [[INDEX]], 4
; CHECK-NEXT:    [[TMP28:%.*]] = icmp eq i64 [[INDEX_NEXT]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[TMP28]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop !5
; CHECK:       middle.block:
; CHECK-NEXT:    [[CMP_N:%.*]] = icmp eq i64 [[TMP1]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[CMP_N]], label [[FOR_COND_CLEANUP_LOOPEXIT:%.*]], label [[SCALAR_PH]]
; CHECK:       scalar.ph:
; CHECK-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i64 [ [[IND_END]], [[MIDDLE_BLOCK]] ], [ [[TMP0]], [[FOR_BODY_LR_PH]] ], [ [[TMP0]], [[VECTOR_SCEVCHECK]] ], [ [[TMP0]], [[VECTOR_MEMCHECK]] ]
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.cond.cleanup.loopexit:
; CHECK-NEXT:    br label [[FOR_COND_CLEANUP]]
; CHECK:       for.cond.cleanup:
; CHECK-NEXT:    [[G_1_LCSSA]] = phi i32 [ [[G_0]], [[FOR_COND]] ], [ 4, [[FOR_COND_CLEANUP_LOOPEXIT]] ]
; CHECK-NEXT:    [[ADD5]] = add nuw nsw i32 [[CONV]], 4
; CHECK-NEXT:    br label [[FOR_COND]]
; CHECK:       for.body:
; CHECK-NEXT:    [[INDVARS_IV:%.*]] = phi i64 [ [[BC_RESUME_VAL]], [[SCALAR_PH]] ], [ [[INDVARS_IV_NEXT:%.*]], [[FOR_BODY]] ]
; CHECK-NEXT:    [[TMP29:%.*]] = trunc i64 [[INDVARS_IV]] to i32
; CHECK-NEXT:    [[ADD:%.*]] = add i32 [[CONV]], [[TMP29]]
; CHECK-NEXT:    [[IDXPROM:%.*]] = zext i32 [[ADD]] to i64
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds [6 x i8], [6 x i8]* @c, i64 0, i64 [[IDXPROM]]
; CHECK-NEXT:    [[TMP30:%.*]] = load i8, i8* [[ARRAYIDX]], align 1
; CHECK-NEXT:    [[ARRAYIDX3:%.*]] = getelementptr inbounds i8, i8* [[CALL]], i64 [[INDVARS_IV]]
; CHECK-NEXT:    store i8 [[TMP30]], i8* [[ARRAYIDX3]], align 1
; CHECK-NEXT:    [[INDVARS_IV_NEXT]] = add nuw nsw i64 [[INDVARS_IV]], 1
; CHECK-NEXT:    [[EXITCOND:%.*]] = icmp eq i64 [[INDVARS_IV_NEXT]], 4
; CHECK-NEXT:    br i1 [[EXITCOND]], label [[FOR_COND_CLEANUP_LOOPEXIT]], label [[FOR_BODY]], !llvm.loop !7
;
entry:
  %call = tail call i8* @"_ZN3$_01aEv"(%struct.anon* nonnull @b) #2
  br label %for.cond

for.cond:                                         ; preds = %for.cond.cleanup, %entry
  %f.0 = phi i32 [ 0, %entry ], [ %add5, %for.cond.cleanup ]
  %g.0 = phi i32 [ undef, %entry ], [ %g.1.lcssa, %for.cond.cleanup ]
  %cmp12 = icmp ult i32 %g.0, 4
  %conv = and i32 %f.0, 65535
  br i1 %cmp12, label %for.body.lr.ph, label %for.cond.cleanup

for.body.lr.ph:                                   ; preds = %for.cond
  %0 = zext i32 %g.0 to i64
  br label %for.body

for.cond.cleanup.loopexit:                        ; preds = %for.body
  br label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.cond.cleanup.loopexit, %for.cond
  %g.1.lcssa = phi i32 [ %g.0, %for.cond ], [ 4, %for.cond.cleanup.loopexit ]
  %add5 = add nuw nsw i32 %conv, 4
  br label %for.cond

for.body:                                         ; preds = %for.body, %for.body.lr.ph
  %indvars.iv = phi i64 [ %0, %for.body.lr.ph ], [ %indvars.iv.next, %for.body ]
  %1 = trunc i64 %indvars.iv to i32
  %add = add i32 %conv, %1
  %idxprom = zext i32 %add to i64
  %arrayidx = getelementptr inbounds [6 x i8], [6 x i8]* @c, i64 0, i64 %idxprom
  %2 = load i8, i8* %arrayidx, align 1
  %arrayidx3 = getelementptr inbounds i8, i8* %call, i64 %indvars.iv
  store i8 %2, i8* %arrayidx3, align 1
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond = icmp eq i64 %indvars.iv.next, 4
  br i1 %exitcond, label %for.cond.cleanup.loopexit, label %for.body
}

declare i8* @"_ZN3$_01aEv"(%struct.anon*) local_unnamed_addr #1
