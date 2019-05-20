; This test checks that the !llvm.loop metadata has been updated after inlining
; so that the start and end locations refer to the inlined DILocations.

; RUN: opt -loop-vectorize -inline %s -S 2>&1 | FileCheck %s
; CHECK: br i1 %{{.*}}, label %middle.block.i, label %vector.body.i, !dbg !{{[0-9]+}}, !llvm.loop [[VECTOR:![0-9]+]]
; CHECK: br i1 %{{.*}}, label %for.cond.cleanup.loopexit.i, label %for.body.i, !dbg !{{[0-9]+}}, !llvm.loop [[SCALAR:![0-9]+]]
; CHECK-DAG: [[VECTOR]] = distinct !{[[VECTOR]], [[START:![0-9]+]], [[END:![0-9]+]], [[IS_VECTORIZED:![0-9]+]]}
; CHECK-DAG: [[SCALAR]] = distinct !{[[SCALAR]], [[START]], [[END]], [[NO_UNROLL:![0-9]+]], [[IS_VECTORIZED]]}
; CHECK-DAG: [[IS_VECTORIZED]] = !{!"llvm.loop.isvectorized", i32 1}
; CHECK-DAG: [[NO_UNROLL]] = !{!"llvm.loop.unroll.runtime.disable"}

; This IR can be generated by running:
;   clang -emit-llvm -S -gmlt -O2 inlined.cpp -o before.ll -mllvm -opt-bisect-limit=53
;
; Where inlined.cpp contains:
; extern int *Array;
; static int bar(unsigned x)
; {
;   int Ret = 0;
;   for (unsigned i = 0; i < x; ++i)
;   {
;     Ret += Array[i] * i;
;   }
;   return Ret;
; }
;
; int foo(unsigned x)
; {
;   int Bar = bar(x);
;   return Bar;
; }

; ModuleID = 'inlined.cpp'
source_filename = "inlined.cpp"
target datalayout = "e-m:w-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-windows-msvc19.16.27030"

@"?Array@@3PEAHEA" = external dso_local local_unnamed_addr global i32*, align 8

; Function Attrs: nounwind uwtable
define dso_local i32 @"?foo@@YAHI@Z"(i32 %x) local_unnamed_addr !dbg !8 {
entry:
  %call = call fastcc i32 @"?bar@@YAHI@Z"(i32 %x), !dbg !10
  ret i32 %call, !dbg !11
}

; Function Attrs: norecurse nounwind readonly uwtable
define internal fastcc i32 @"?bar@@YAHI@Z"(i32 %x) unnamed_addr !dbg !12 {
entry:
  %cmp7 = icmp eq i32 %x, 0, !dbg !13
  br i1 %cmp7, label %for.cond.cleanup, label %for.body.lr.ph, !dbg !13

for.body.lr.ph:                                   ; preds = %entry
  %0 = load i32*, i32** @"?Array@@3PEAHEA", align 8, !dbg !14, !tbaa !15
  %wide.trip.count = zext i32 %x to i64, !dbg !14
  br label %for.body, !dbg !13

for.cond.cleanup.loopexit:                        ; preds = %for.body
  %add.lcssa = phi i32 [ %add, %for.body ], !dbg !19
  br label %for.cond.cleanup, !dbg !20

for.cond.cleanup:                                 ; preds = %for.cond.cleanup.loopexit, %entry
  %Ret.0.lcssa = phi i32 [ 0, %entry ], [ %add.lcssa, %for.cond.cleanup.loopexit ], !dbg !14
  ret i32 %Ret.0.lcssa, !dbg !20

for.body:                                         ; preds = %for.body, %for.body.lr.ph
  %indvars.iv = phi i64 [ 0, %for.body.lr.ph ], [ %indvars.iv.next, %for.body ]
  %Ret.08 = phi i32 [ 0, %for.body.lr.ph ], [ %add, %for.body ]
  %arrayidx = getelementptr inbounds i32, i32* %0, i64 %indvars.iv, !dbg !19
  %1 = load i32, i32* %arrayidx, align 4, !dbg !19, !tbaa !21
  %2 = trunc i64 %indvars.iv to i32, !dbg !19
  %mul = mul i32 %1, %2, !dbg !19
  %add = add i32 %mul, %Ret.08, !dbg !19
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1, !dbg !13
  %exitcond = icmp eq i64 %indvars.iv.next, %wide.trip.count, !dbg !13
  br i1 %exitcond, label %for.cond.cleanup.loopexit, label %for.body, !dbg !13, !llvm.loop !23
}

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!3, !4, !5, !6}
!llvm.ident = !{!7}

!0 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus, file: !1, producer: "clang version 9.0.0 (https://github.com/llvm/llvm-project.git b1e28d9b6a16380ccf1456fe0695f639364407a9)", isOptimized: true, runtimeVersion: 0, emissionKind: LineTablesOnly, enums: !2, nameTableKind: None)
!1 = !DIFile(filename: "inlined.cpp", directory: "")
!2 = !{}
!3 = !{i32 2, !"CodeView", i32 1}
!4 = !{i32 2, !"Debug Info Version", i32 3}
!5 = !{i32 1, !"wchar_size", i32 2}
!6 = !{i32 7, !"PIC Level", i32 2}
!7 = !{!"clang version 9.0.0 (https://github.com/llvm/llvm-project.git b1e28d9b6a16380ccf1456fe0695f639364407a9)"}
!8 = distinct !DISubprogram(name: "foo", scope: !1, file: !1, line: 13, type: !9, scopeLine: 14, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !2)
!9 = !DISubroutineType(types: !2)
!10 = !DILocation(line: 15, scope: !8)
!11 = !DILocation(line: 16, scope: !8)
!12 = distinct !DISubprogram(name: "bar", scope: !1, file: !1, line: 3, type: !9, scopeLine: 4, flags: DIFlagPrototyped, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !2)
!13 = !DILocation(line: 6, scope: !12)
!14 = !DILocation(line: 0, scope: !12)
!15 = !{!16, !16, i64 0}
!16 = !{!"any pointer", !17, i64 0}
!17 = !{!"omnipotent char", !18, i64 0}
!18 = !{!"Simple C++ TBAA"}
!19 = !DILocation(line: 8, scope: !12)
!20 = !DILocation(line: 10, scope: !12)
!21 = !{!22, !22, i64 0}
!22 = !{!"int", !17, i64 0}
!23 = distinct !{!23, !13, !24}
!24 = !DILocation(line: 9, scope: !12)

