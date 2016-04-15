; RUN: llc -mcpu=core2 -mtriple=i686-pc-win32 -O0 < %s | FileCheck --check-prefix=X86 %s
; RUN: llc -mcpu=core2 -mtriple=i686-pc-win32 -o - -O0 < %s | llvm-mc -triple=i686-pc-win32 -filetype=obj | llvm-readobj -s -sr -codeview -section-symbols | FileCheck --check-prefix=OBJ32 %s
; RUN: llc -mcpu=core2 -mtriple=x86_64-pc-win32 -O0 < %s | FileCheck --check-prefix=X64 %s
; RUN: llc -mcpu=core2 -mtriple=x86_64-pc-win32 -o - -O0 < %s | llvm-mc -triple=x86_64-pc-win32 -filetype=obj | llvm-readobj -s -sr -codeview -section-symbols | FileCheck --check-prefix=OBJ64 %s

; This LL file was generated by running clang on the following code:
; D:\test.c:
; 1 void g(void);
; 2
; 3 void f(void) {
; 4   g();
; 5 }

; X86-LABEL: _f:
; X86:      # BB
; X86-NEXT: [[CALL_LINE:^L.*]]:{{$}}
; X86:      calll   _g
; X86-NEXT: [[RETURN_STMT:.*]]:
; X86:      ret
; X86-NEXT: [[END_OF_F:.*]]:
;
; X86-LABEL: .section        .debug$S,"dr"
; X86-NEXT: .long   4
; Symbol subsection
; X86-NEXT: .long   241
; X86-NEXT: .long [[F1_END:.*]]-[[F1_START:.*]]
; X86-NEXT: [[F1_START]]:
; X86-NEXT: .short [[PROC_SEGMENT_END:.*]]-[[PROC_SEGMENT_START:.*]]
; X86-NEXT: [[PROC_SEGMENT_START]]:
; X86-NEXT: .short  4423
; X86-NEXT: .zero   12
; X86-NEXT: .long [[END_OF_F]]-_f
; X86-NEXT: .zero   12
; X86-NEXT: .secrel32 _f
; X86-NEXT: .secidx _f
; X86-NEXT: .byte   0
; X86-NEXT: .byte   102
; X86-NEXT: .byte   0
; X86-NEXT: [[PROC_SEGMENT_END]]:
; X86-NEXT: .short  2
; X86-NEXT: .short  4431
; X86-NEXT: [[F1_END]]:
; Padding
; X86-NEXT: .zero   3
; Line table
; X86-NEXT: .long   242
; X86-NEXT: .long [[F2_END:.*]]-[[F2_START:.*]]
; X86-NEXT: [[F2_START]]:
; X86-NEXT: .secrel32 _f
; X86-NEXT: .secidx _f
; X86-NEXT: .short  1
; X86-NEXT: .long [[END_OF_F]]-_f
; X86-NEXT: [[FILE_SEGMENT_START:[^:]*]]:
; X86-NEXT: .long   0
; X86-NEXT: .long   2
; X86-NEXT: .long [[FILE_SEGMENT_END:.*]]-[[FILE_SEGMENT_START]]
; X86-NEXT: .long [[CALL_LINE]]-_f
; X86-NEXT: .long   -2147483644
; X86-NEXT: .long [[RETURN_STMT]]-_f
; X86-NEXT: .long   -2147483643
; X86-NEXT: .short  0
; X86-NEXT: .short  0
; X86-NEXT: .short  0
; X86-NEXT: .short  0
; X86-NEXT: [[FILE_SEGMENT_END]]:
; X86-NEXT: [[F2_END]]:
; File index to string table offset subsection
; X86-NEXT: .long   244
; X86-NEXT: .long   8
; X86-NEXT: .long   1
; X86-NEXT: .long   0
; String table
; X86-NEXT: .long   243
; X86-NEXT: .long   11
; X86-NEXT: .byte   0
; X86-NEXT: .ascii  "D:\\test.c"
; X86-NEXT: .byte   0
; Padding
; X86-NEXT: .zero   1

; OBJ32:    Section {
; OBJ32:      Name: .debug$S (2E 64 65 62 75 67 24 53)
; OBJ32:      Characteristics [ (0x42100040)
; OBJ32:      ]
; OBJ32:      Relocations [
; OBJ32-NEXT:   0x2C IMAGE_REL_I386_SECREL _f
; OBJ32-NEXT:   0x30 IMAGE_REL_I386_SECTION _f
; OBJ32-NEXT:   0x44 IMAGE_REL_I386_SECREL _f
; OBJ32-NEXT:   0x48 IMAGE_REL_I386_SECTION _f
; OBJ32-NEXT: ]
; OBJ32:      Subsection [
; OBJ32-NEXT:   SubSectionType: Symbols (0xF1)
; OBJ32-NOT:    ]
; OBJ32:        ProcStart {
; OBJ32:          CodeSize: 0x6
; OBJ32:          DisplayName: f
; OBJ32:          LinkageName: _f
; OBJ32:        }
; OBJ32-NEXT:   ProcEnd
; OBJ32-NEXT: ]
; OBJ32:      FunctionLineTable [
; OBJ32-NEXT:   Name: _f
; OBJ32-NEXT:   Flags: 0x1
; OBJ32-NEXT:   CodeSize: 0x6
; OBJ32-NEXT:   FilenameSegment [
; OBJ32-NEXT:     Filename: D:\test.c
; OBJ32-NEXT:     +0x0 [
; OBJ32-NEXT:       LineNumberStart: 4
; OBJ32-NEXT:       LineNumberEndDelta: 0
; OBJ32-NEXT:       IsStatement: Yes
; OBJ32-NEXT:       ColStart: 0
; OBJ32-NEXT:       ColEnd: 0
; OBJ32-NEXT:     ]
; OBJ32-NEXT:     +0x5 [
; OBJ32-NEXT:       LineNumberStart: 5
; OBJ32-NEXT:       LineNumberEndDelta: 0
; OBJ32-NEXT:       IsStatement: Yes
; OBJ32-NEXT:       ColStart: 0
; OBJ32-NEXT:       ColEnd: 0
; OBJ32-NEXT:     ]
; OBJ32-NEXT:   ]
; OBJ32-NEXT: ]

; X64-LABEL: f:
; X64-NEXT: .L{{.*}}:{{$}}
; X64-NEXT: [[START:.*]]:{{$}}
; X64:      # BB
; X64:      subq    $40, %rsp
; X64-NEXT: [[CALL_LINE:.*]]:{{$}}
; X64-NEXT: callq   g
; X64-NEXT: [[EPILOG_AND_RET:.*]]:
; X64:      addq    $40, %rsp
; X64-NEXT: ret
; X64-NEXT: [[END_OF_F:.*]]:
;
; X64-LABEL: .section        .debug$S,"dr"
; X64-NEXT: .long   4
; Symbol subsection
; X64-NEXT: .long   241
; X64-NEXT: .long [[F1_END:.*]]-[[F1_START:.*]]
; X64-NEXT: [[F1_START]]:
; X64-NEXT: .short [[PROC_SEGMENT_END:.*]]-[[PROC_SEGMENT_START:.*]]
; X64-NEXT: [[PROC_SEGMENT_START]]:
; X64-NEXT: .short  4423
; X64-NEXT: .zero   12
; X64-NEXT: .long [[END_OF_F]]-f
; X64-NEXT: .zero   12
; X64-NEXT: .secrel32 f
; X64-NEXT: .secidx f
; X64-NEXT: .byte   0
; X64-NEXT: .byte   102
; X64-NEXT: .byte   0
; X64-NEXT: [[PROC_SEGMENT_END]]:
; X64-NEXT: .short  2
; X64-NEXT: .short  4431
; X64-NEXT: [[F1_END]]:
; Padding
; X64-NEXT: .zero   3
; Line table
; X64-NEXT: .long   242
; X64-NEXT: .long [[F2_END:.*]]-[[F2_START:.*]]
; X64-NEXT: [[F2_START]]:
; X64-NEXT: .secrel32 f
; X64-NEXT: .secidx f
; X64-NEXT: .short  1
; X64-NEXT: .long [[END_OF_F]]-f
; X64-NEXT: [[FILE_SEGMENT_START:[^:]*]]:
; X64-NEXT: .long   0
; X64-NEXT: .long   3
; X64-NEXT: .long [[FILE_SEGMENT_END:.*]]-[[FILE_SEGMENT_START]]
; X64-NEXT: .long [[START]]-f
; X64-NEXT: .long   -2147483645
; X64-NEXT: .long [[CALL_LINE]]-f
; X64-NEXT: .long   -2147483644
; X64-NEXT: .long [[EPILOG_AND_RET]]-f
; X64-NEXT: .long   -2147483643
; X64-NEXT: .short  0
; X64-NEXT: .short  0
; X64-NEXT: .short  0
; X64-NEXT: .short  0
; X64-NEXT: .short  0
; X64-NEXT: .short  0
; X64-NEXT: [[FILE_SEGMENT_END]]:
; X64-NEXT: [[F2_END]]:
; File index to string table offset subsection
; X64-NEXT: .long   244
; X64-NEXT: .long   8
; X64-NEXT: .long   1
; X64-NEXT: .long   0
; String table
; X64-NEXT: .long   243
; X64-NEXT: .long   11
; X64-NEXT: .byte   0
; X64-NEXT: .ascii  "D:\\test.c"
; X64-NEXT: .byte   0
; Padding
; X64-NEXT: .zero   1

; OBJ64:    Section {
; OBJ64:      Name: .debug$S (2E 64 65 62 75 67 24 53)
; OBJ64:      Characteristics [ (0x42100040)
; OBJ64:      ]
; OBJ64:      Relocations [
; OBJ64-NEXT:   0x2C IMAGE_REL_AMD64_SECREL f
; OBJ64-NEXT:   0x30 IMAGE_REL_AMD64_SECTION f
; OBJ64-NEXT:   0x44 IMAGE_REL_AMD64_SECREL f
; OBJ64-NEXT:   0x48 IMAGE_REL_AMD64_SECTION f
; OBJ64-NEXT: ]
; OBJ64:      Subsection [
; OBJ64-NEXT:   SubSectionType: Symbols (0xF1)
; OBJ64-NOT:    ]
; OBJ64:        ProcStart {
; OBJ64:          CodeSize: 0xE
; OBJ64:          DisplayName: f
; OBJ64:          LinkageName: f
; OBJ64:        }
; OBJ64-NEXT:   ProcEnd
; OBJ64-NEXT: ]
; OBJ64:      FunctionLineTable [
; OBJ64-NEXT:   Name: f
; OBJ64-NEXT:   Flags: 0x1
; OBJ64-NEXT:   CodeSize: 0xE
; OBJ64-NEXT:   FilenameSegment [
; OBJ64-NEXT:     Filename: D:\test.c
; OBJ64-NEXT:     +0x0 [
; OBJ64-NEXT:       LineNumberStart: 3
; OBJ64-NEXT:       LineNumberEndDelta: 0
; OBJ64-NEXT:       IsStatement: Yes
; OBJ64-NEXT:       ColStart: 0
; OBJ64-NEXT:       ColEnd: 0
; OBJ64-NEXT:     ]
; OBJ64-NEXT:     +0x4 [
; OBJ64-NEXT:       LineNumberStart: 4
; OBJ64-NEXT:       LineNumberEndDelta: 0
; OBJ64-NEXT:       IsStatement: Yes
; OBJ64-NEXT:       ColStart: 0
; OBJ64-NEXT:       ColEnd: 0
; OBJ64-NEXT:     ]
; OBJ64-NEXT:     +0x9 [
; OBJ64-NEXT:       LineNumberStart: 5
; OBJ64-NEXT:       LineNumberEndDelta: 0
; OBJ64-NEXT:       IsStatement: Yes
; OBJ64-NEXT:       ColStart: 0
; OBJ64-NEXT:       ColEnd: 0
; OBJ64-NEXT:     ]
; OBJ64-NEXT:   ]
; OBJ64-NEXT: ]

; Function Attrs: nounwind
define void @f() #0 !dbg !4 {
entry:
  call void @g(), !dbg !12
  ret void, !dbg !13
}

declare void @g() #1

attributes #0 = { nounwind "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-realign-stack" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-realign-stack" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!9, !10}
!llvm.ident = !{!11}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, producer: "clang version 3.5 ", isOptimized: false, emissionKind: FullDebug, file: !1, enums: !2, retainedTypes: !2, globals: !2, imports: !2)
!1 = !DIFile(filename: "<unknown>", directory: "D:\5C")
!2 = !{}
!4 = distinct !DISubprogram(name: "f", line: 3, isLocal: false, isDefinition: true, virtualIndex: 6, flags: DIFlagPrototyped, isOptimized: false, unit: !0, scopeLine: 3, file: !5, scope: !6, type: !7, variables: !2)
!5 = !DIFile(filename: "test.c", directory: "D:\5C")
!6 = !DIFile(filename: "test.c", directory: "D:C")
!7 = !DISubroutineType(types: !8)
!8 = !{null}
!9 = !{i32 2, !"CodeView", i32 1}
!10 = !{i32 1, !"Debug Info Version", i32 3}
!11 = !{!"clang version 3.5 "}
!12 = !DILocation(line: 4, scope: !4)
!13 = !DILocation(line: 5, scope: !4)
