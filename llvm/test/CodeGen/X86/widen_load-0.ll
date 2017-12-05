; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-linux -mattr=+sse4.2 | FileCheck %s --check-prefix=X86
; RUN: llc < %s -mtriple=x86_64-linux -mattr=+sse4.2 | FileCheck %s --check-prefix=X64

; PR4891

; Both loads should happen before either store.

define void @short2_int_swap(<2 x i16>* nocapture %b, i32* nocapture %c) nounwind {
; X86-LABEL: short2_int_swap:
; X86:       # %bb.0: # %entry
; X86-NEXT:    pushl %esi
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl (%ecx), %edx
; X86-NEXT:    movl (%eax), %esi
; X86-NEXT:    movl %edx, (%eax)
; X86-NEXT:    movl %esi, (%ecx)
; X86-NEXT:    popl %esi
; X86-NEXT:    retl
;
; X64-LABEL: short2_int_swap:
; X64:       # %bb.0: # %entry
; X64-NEXT:    movl (%rsi), %eax
; X64-NEXT:    movl (%rdi), %ecx
; X64-NEXT:    movl %eax, (%rdi)
; X64-NEXT:    movl %ecx, (%rsi)
; X64-NEXT:    retq
entry:
  %0 = load <2 x i16>, <2 x i16>* %b, align 2                ; <<2 x i16>> [#uses=1]
  %1 = load i32, i32* %c, align 4                      ; <i32> [#uses=1]
  %tmp1 = bitcast i32 %1 to <2 x i16>             ; <<2 x i16>> [#uses=1]
  store <2 x i16> %tmp1, <2 x i16>* %b, align 2
  %tmp5 = bitcast <2 x i16> %0 to <1 x i32>       ; <<1 x i32>> [#uses=1]
  %tmp3 = extractelement <1 x i32> %tmp5, i32 0   ; <i32> [#uses=1]
  store i32 %tmp3, i32* %c, align 4
  ret void
}
