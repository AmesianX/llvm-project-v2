; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown-unknown -mattr=+mmx,+3dnowa -post-RA-scheduler=false | FileCheck %s --check-prefixes=CHECK,NOPOST
; RUN: llc < %s -mtriple=i686-unknown-unknown -mattr=+mmx,+3dnowa -post-RA-scheduler=true | FileCheck %s --check-prefixes=CHECK,POST

define float @PR35982_emms(<1 x i64>) nounwind {
; CHECK-LABEL: PR35982_emms:
; CHECK:       # %bb.0:
; CHECK-NEXT:    pushl %ebp
; CHECK-NEXT:    movl %esp, %ebp
; CHECK-NEXT:    andl $-8, %esp
; CHECK-NEXT:    subl $16, %esp
; CHECK-NEXT:    movl 8(%ebp), %eax
; CHECK-NEXT:    movl 12(%ebp), %ecx
; CHECK-NEXT:    movl %ecx, {{[0-9]+}}(%esp)
; CHECK-NEXT:    movl %eax, {{[0-9]+}}(%esp)
; CHECK-NEXT:    movq {{[0-9]+}}(%esp), %mm0
; CHECK-NEXT:    punpckhdq %mm0, %mm0 # mm0 = mm0[1,1]
; CHECK-NEXT:    movd %mm0, %ecx
; CHECK-NEXT:    emms
; CHECK-NEXT:    movl %eax, (%esp)
; CHECK-NEXT:    fildl (%esp)
; CHECK-NEXT:    movl %ecx, {{[0-9]+}}(%esp)
; CHECK-NEXT:    fiaddl {{[0-9]+}}(%esp)
; CHECK-NEXT:    movl %ebp, %esp
; CHECK-NEXT:    popl %ebp
; CHECK-NEXT:    retl
  %2 = bitcast <1 x i64> %0 to <2 x i32>
  %3 = extractelement <2 x i32> %2, i32 0
  %4 = extractelement <1 x i64> %0, i32 0
  %5 = bitcast i64 %4 to x86_mmx
  %6 = tail call x86_mmx @llvm.x86.mmx.punpckhdq(x86_mmx %5, x86_mmx %5)
  %7 = bitcast x86_mmx %6 to <2 x i32>
  %8 = extractelement <2 x i32> %7, i32 0
  tail call void @llvm.x86.mmx.emms()
  %9 = sitofp i32 %3 to float
  %10 = sitofp i32 %8 to float
  %11 = fadd float %9, %10
  ret float %11
}

define float @PR35982_femms(<1 x i64>) nounwind {
; CHECK-LABEL: PR35982_femms:
; CHECK:       # %bb.0:
; CHECK-NEXT:    pushl %ebp
; CHECK-NEXT:    movl %esp, %ebp
; CHECK-NEXT:    andl $-8, %esp
; CHECK-NEXT:    subl $16, %esp
; CHECK-NEXT:    movl 8(%ebp), %eax
; CHECK-NEXT:    movl 12(%ebp), %ecx
; CHECK-NEXT:    movl %ecx, {{[0-9]+}}(%esp)
; CHECK-NEXT:    movl %eax, {{[0-9]+}}(%esp)
; CHECK-NEXT:    movq {{[0-9]+}}(%esp), %mm0
; CHECK-NEXT:    punpckhdq %mm0, %mm0 # mm0 = mm0[1,1]
; CHECK-NEXT:    movd %mm0, %ecx
; CHECK-NEXT:    femms
; CHECK-NEXT:    movl %eax, (%esp)
; CHECK-NEXT:    fildl (%esp)
; CHECK-NEXT:    movl %ecx, {{[0-9]+}}(%esp)
; CHECK-NEXT:    fiaddl {{[0-9]+}}(%esp)
; CHECK-NEXT:    movl %ebp, %esp
; CHECK-NEXT:    popl %ebp
; CHECK-NEXT:    retl
  %2 = bitcast <1 x i64> %0 to <2 x i32>
  %3 = extractelement <2 x i32> %2, i32 0
  %4 = extractelement <1 x i64> %0, i32 0
  %5 = bitcast i64 %4 to x86_mmx
  %6 = tail call x86_mmx @llvm.x86.mmx.punpckhdq(x86_mmx %5, x86_mmx %5)
  %7 = bitcast x86_mmx %6 to <2 x i32>
  %8 = extractelement <2 x i32> %7, i32 0
  tail call void @llvm.x86.mmx.femms()
  %9 = sitofp i32 %3 to float
  %10 = sitofp i32 %8 to float
  %11 = fadd float %9, %10
  ret float %11
}

declare x86_mmx @llvm.x86.mmx.punpckhdq(x86_mmx, x86_mmx)
declare void @llvm.x86.mmx.femms()
declare void @llvm.x86.mmx.emms()
