; RUN: %llc_dwarf -filetype=obj < %s | llvm-dwarfdump -debug-info - | FileCheck %s
; REQUIRES: object-emission

; Generated by clang++ -S -c -std=c++11 --emit-llvm -g from the following C++11 source:
; [[ noreturn ]] void f() {
;   throw 1;
; }

; CHECK: DW_TAG_subprogram
; CHECK-NOT: DW_TAG
; CHECK: DW_AT_name{{.*}}"f"
; CHECK-NOT: DW_TAG
; CHECK: DW_AT_noreturn

; ModuleID = 'test.cpp'
source_filename = "test.cpp"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@_ZTIi = external constant i8*

; Function Attrs: noreturn
define void @_Z1fv() #0 !dbg !6 {
entry:
  %exception = call i8* @__cxa_allocate_exception(i64 4) #1, !dbg !9
  %0 = bitcast i8* %exception to i32*, !dbg !9
  store i32 1, i32* %0, align 16, !dbg !9
  call void @__cxa_throw(i8* %exception, i8* bitcast (i8** @_ZTIi to i8*), i8* null) #2, !dbg !10
  unreachable, !dbg !9

return:                                           ; No predecessors!
  ret void, !dbg !12
}

declare i8* @__cxa_allocate_exception(i64)

declare void @__cxa_throw(i8*, i8*, i8*)

attributes #0 = { noreturn }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!3, !4}
!llvm.ident = !{!5}

!0 = distinct !DICompileUnit(language: DW_LANG_C_plus_plus, file: !1, producer: "clang version 4.0.0", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !2)
!1 = !DIFile(filename: "test.cpp", directory: "/home/del/test")
!2 = !{}
!3 = !{i32 2, !"Dwarf Version", i32 4}
!4 = !{i32 2, !"Debug Info Version", i32 3}
!5 = !{!"clang version 4.0.0"}
!6 = distinct !DISubprogram(name: "f", linkageName: "_Z1fv", scope: !1, file: !1, line: 1, type: !7, isLocal: false, isDefinition: true, scopeLine: 1, flags: DIFlagPrototyped | DIFlagNoReturn, isOptimized: false, unit: !0, retainedNodes: !2)
!7 = !DISubroutineType(types: !8)
!8 = !{null}
!9 = !DILocation(line: 2, column: 5, scope: !6)
!10 = !DILocation(line: 2, column: 5, scope: !11)
!11 = !DILexicalBlockFile(scope: !6, file: !1, discriminator: 1)
!12 = !DILocation(line: 3, column: 1, scope: !6)
