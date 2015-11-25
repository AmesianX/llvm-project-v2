; RUN: llvm-as %s -o %t.o
; RUN: llvm-as %p/Inputs/resolve-to-alias.ll -o %t2.o

; RUN: %gold -plugin %llvmshlibdir/LLVMgold.so \
; RUN:    --plugin-opt=emit-llvm \
; RUN:    -shared %t.o %t2.o -o %t.bc
; RUN: llvm-dis %t.bc -o %t.ll
; RUN: FileCheck --check-prefix=PASS1 %s < %t.ll
; RUN: FileCheck --check-prefix=PASS2 %s < %t.ll

; RUN: %gold -plugin %llvmshlibdir/LLVMgold.so \
; RUN:    --plugin-opt=emit-llvm \
; RUN:    -shared %t2.o %t.o -o %t.bc
; RUN: llvm-dis %t.bc -o %t.ll
; RUN: FileCheck --check-prefix=PASS1 %s < %t.ll
; RUN: FileCheck --check-prefix=PASS2 %s < %t.ll

define void @foo() {
  call void @bar()
  ret void
}
declare void @bar()

; PASS1: @bar = alias void (), void ()* @zed

; PASS1:      define void @foo() {
; PASS1-NEXT:   call void @bar()
; PASS1-NEXT:   ret void
; PASS1-NEXT: }

; PASS2:      define void @zed() {
; PASS2-NEXT:   ret void
; PASS2-NEXT: }
