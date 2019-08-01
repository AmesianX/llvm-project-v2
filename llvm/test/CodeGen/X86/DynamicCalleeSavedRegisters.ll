; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i386-linux-gnu  | FileCheck %s

declare x86_regcallcc i32 @callee(i32 %a0, i32 %b0, i32 %c0, i32 %d0, i32 %e0);

; In RegCall calling convention, ESI and EDI are callee saved registers.
; One might think that the caller could assume that ESI value is the same before
; and after calling the callee.
; However, RegCall also says that a register that was used for
; passing/returning argumnets, can be assumed to be modified by the callee.
; In other words, it is no longer a callee saved register.
; In this case we want to see that EDX/ECX values are saved and EDI/ESI are assumed
; to be modified by the callee.
; This is a hipe CC function that doesn't save any register for the caller.
; So we can be sure that there is no other reason to save EDX/ECX.
; The caller arguments are expected to be passed (in the following order)
; in registers: ESI, EBP, EAX, EDX and ECX.
define cc 11 i32 @caller(i32 %a0, i32 %b0, i32 %c0, i32 %d0, i32 %e0) nounwind {
; CHECK-LABEL: caller:
; CHECK:       # %bb.0:
; CHECK-NEXT:    subl $12, %esp
; CHECK-NEXT:    movl %ecx, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Spill
; CHECK-NEXT:    movl %edx, %ebx
; CHECK-NEXT:    movl %eax, %edx
; CHECK-NEXT:    movl %esi, %eax
; CHECK-NEXT:    movl %ebp, %ecx
; CHECK-NEXT:    movl %ebx, %edi
; CHECK-NEXT:    movl {{[-0-9]+}}(%e{{[sb]}}p), %ebp # 4-byte Reload
; CHECK-NEXT:    movl %ebp, %esi
; CHECK-NEXT:    calll callee
; CHECK-NEXT:    leal (%eax,%ebx), %esi
; CHECK-NEXT:    addl %ebp, %esi
; CHECK-NEXT:    addl $12, %esp
; CHECK-NEXT:    retl
  %b1 = call x86_regcallcc i32 @callee(i32 %a0, i32 %b0, i32 %c0, i32 %d0, i32 %e0)
  %b2 = add i32 %b1, %d0
  %b3 = add i32 %b2, %e0
  ret i32 %b3
}
!hipe.literals = !{ !0, !1, !2 }
!0 = !{ !"P_NSP_LIMIT", i32 120 }
!1 = !{ !"X86_LEAF_WORDS", i32 24 }
!2 = !{ !"AMD64_LEAF_WORDS", i32 18 }

; Make sure that the callee doesn't save parameters that were passed as arguments.
; The caller arguments are expected to be passed (in the following order)
; in registers: EAX, ECX, EDX, EDI and ESI.
; The result will return in EAX, ECX and EDX.
define x86_regcallcc {i32, i32, i32} @test_callee(i32 %a0, i32 %b0, i32 %c0, i32 %d0, i32 %e0) nounwind {
; CHECK-LABEL: test_callee:
; CHECK:       # %bb.0:
; CHECK-NEXT:    leal (,%esi,8), %ecx
; CHECK-NEXT:    subl %esi, %ecx
; CHECK-NEXT:    movl $5, %eax
; CHECK-NEXT:    xorl %edx, %edx
; CHECK-NEXT:    divl %esi
; CHECK-NEXT:    movl %eax, %esi
; CHECK-NEXT:    leal (,%edi,8), %edx
; CHECK-NEXT:    subl %edi, %edx
; CHECK-NEXT:    movl %ecx, %eax
; CHECK-NEXT:    movl %esi, %ecx
; CHECK-NEXT:    retl
  %b1 = mul i32 7, %e0
  %b2 = udiv i32 5, %e0
  %b3 = mul i32 7, %d0
  %b4 = insertvalue {i32, i32, i32} undef, i32 %b1, 0
  %b5 = insertvalue {i32, i32, i32} %b4, i32 %b2, 1
  %b6 = insertvalue {i32, i32, i32} %b5, i32 %b3, 2
  ret {i32, i32, i32} %b6
}
