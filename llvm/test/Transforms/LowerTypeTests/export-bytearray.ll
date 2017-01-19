; RUN: opt -S -lowertypetests -lowertypetests-summary-action=export -lowertypetests-read-summary=%S/Inputs/use-typeid1-typeid2.yaml -lowertypetests-write-summary=%t < %s | FileCheck %s
; RUN: FileCheck --check-prefix=SUMMARY %s < %t

@foo = constant [2048 x i8] zeroinitializer, !type !0, !type !1, !type !2, !type !3

!0 = !{i32 0, !"typeid1"}
!1 = !{i32 130, !"typeid1"}
!2 = !{i32 4, !"typeid2"}
!3 = !{i32 1032, !"typeid2"}

; CHECK: [[G:@[0-9]+]] = private constant { [2048 x i8] } zeroinitializer
; CHECK: [[B:@[0-9]+]] = private constant [258 x i8] c"\03\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\02\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\01"

; CHECK: @__typeid_typeid1_global_addr = hidden alias i8, getelementptr inbounds ({ [2048 x i8] }, { [2048 x i8] }* [[G]], i32 0, i32 0, i32 0)
; CHECK: @__typeid_typeid1_align = hidden alias i8, inttoptr (i8 1 to i8*)
; CHECK: @__typeid_typeid1_size_m1 = hidden alias i8, inttoptr (i8 65 to i8*)
; CHECK: @__typeid_typeid1_byte_array = hidden alias i8, i8* @bits.1
; CHECK: @__typeid_typeid1_bit_mask = hidden alias i8, inttoptr (i8 2 to i8*)

; CHECK: @__typeid_typeid2_global_addr = hidden alias i8, getelementptr inbounds ({ [2048 x i8] }, { [2048 x i8] }* [[G]], i32 0, i32 0, i64 4)
; CHECK: @__typeid_typeid2_align = hidden alias i8, inttoptr (i8 2 to i8*)
; CHECK: @__typeid_typeid2_size_m1 = hidden alias i8, inttoptr (i32 257 to i8*)
; CHECK: @__typeid_typeid2_byte_array = hidden alias i8, i8* @bits
; CHECK: @__typeid_typeid2_bit_mask = hidden alias i8, inttoptr (i8 1 to i8*)

; CHECK: @foo = alias [2048 x i8], getelementptr inbounds ({ [2048 x i8] }, { [2048 x i8] }* [[G]], i32 0, i32 0)
; CHECK: @bits = private alias i8, getelementptr inbounds ([258 x i8], [258 x i8]* [[B]], i64 0, i64 0)
; CHECK: @bits.1 = private alias i8, getelementptr inbounds ([258 x i8], [258 x i8]* [[B]], i64 0, i64 0)

; SUMMARY:      TypeIdMap:
; SUMMARY-NEXT:   typeid1:
; SUMMARY-NEXT:     TTRes:
; SUMMARY-NEXT:       Kind:            ByteArray
; SUMMARY-NEXT:       SizeM1BitWidth:  7
; SUMMARY-NEXT:   typeid2:
; SUMMARY-NEXT:     TTRes:
; SUMMARY-NEXT:       Kind:            ByteArray
; SUMMARY-NEXT:       SizeM1BitWidth:  32
