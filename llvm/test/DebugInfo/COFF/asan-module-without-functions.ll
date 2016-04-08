; RUN: llc -mcpu=core2 -mtriple=i686-pc-win32 -O0 < %s | FileCheck --check-prefix=X86 %s

; This LL file was generated by running clang on the following code with
; -fsanitize=address
; D:\asan.c:
; 1 unsigned char c = 42;
;
; This file defines no functions, so just make sure we don't try to emit
; the line table for functions of zero size.
; X86-NOT: .section        .debug$S,"rn"

; ModuleID = 'asan.c'
target datalayout = "e-m:w-p:32:32-i64:64-f80:32-n8:16:32-S32"
target triple = "i686-pc-win32"

@c = global { i8, [63 x i8] } { i8 42, [63 x i8] zeroinitializer }, align 32
@llvm.global_ctors = appending global [1 x { i32, void ()* }] [{ i32, void ()* } { i32 1, void ()* @asan.module_ctor }]
@__asan_gen_ = private constant [7 x i8] c"asan.c\00", align 1
@__asan_gen_1 = private unnamed_addr constant [2 x i8] c"c\00", align 1
@0 = internal global [1 x { i32, i32, i32, i32, i32, i32 }] [{ i32, i32, i32, i32, i32, i32 } { i32 ptrtoint ({ i8, [63 x i8] }* @c to i32), i32 1, i32 64, i32 ptrtoint ([2 x i8]* @__asan_gen_1 to i32), i32 ptrtoint ([7 x i8]* @__asan_gen_ to i32), i32 0 }]
@llvm.global_dtors = appending global [1 x { i32, void ()* }] [{ i32, void ()* } { i32 1, void ()* @asan.module_dtor }]

define internal void @asan.module_ctor() {
  call void @__asan_init_v3()
  call void @__asan_register_globals(i32 ptrtoint ([1 x { i32, i32, i32, i32, i32, i32 }]* @0 to i32), i32 1)
  ret void
}

declare void @__asan_init_v3()

declare void @__asan_before_dynamic_init(i32)

declare void @__asan_after_dynamic_init()

declare void @__asan_register_globals(i32, i32)

declare void @__asan_unregister_globals(i32, i32)

define internal void @asan.module_dtor() {
  call void @__asan_unregister_globals(i32 ptrtoint ([1 x { i32, i32, i32, i32, i32, i32 }]* @0 to i32), i32 1)
  ret void
}

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!3, !4}
!llvm.ident = !{!5}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, producer: "clang version 3.5.0 ", isOptimized: false, emissionKind: LineTablesOnly, file: !1, enums: !2, retainedTypes: !2, subprograms: !2, globals: !2, imports: !2)
!1 = !DIFile(filename: "asan.c", directory: "D:\5C")
!2 = !{}
!3 = !{i32 2, !"CodeView", i32 1}
!4 = !{i32 1, !"Debug Info Version", i32 3}
!5 = !{!"clang version 3.5.0 "}
