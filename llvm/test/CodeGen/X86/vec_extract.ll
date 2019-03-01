; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown-linux-gnu -mattr=+sse2,-sse4.1 | FileCheck %s --check-prefix=X32
; RUN: llc < %s -mtriple=x86_64-unknown-linux-gnu -mattr=+sse2,-sse4.1 | FileCheck %s --check-prefix=X64

define void @test1(<4 x float>* %F, float* %f) nounwind {
; X32-LABEL: test1:
; X32:       # %bb.0: # %entry
; X32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X32-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; X32-NEXT:    addss %xmm0, %xmm0
; X32-NEXT:    movss %xmm0, (%eax)
; X32-NEXT:    retl
;
; X64-LABEL: test1:
; X64:       # %bb.0: # %entry
; X64-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; X64-NEXT:    addss %xmm0, %xmm0
; X64-NEXT:    movss %xmm0, (%rsi)
; X64-NEXT:    retq
entry:
  %tmp = load <4 x float>, <4 x float>* %F
  %tmp7 = fadd <4 x float> %tmp, %tmp
  %tmp2 = extractelement <4 x float> %tmp7, i32 0
  store float %tmp2, float* %f
  ret void
}

define float @test2(<4 x float>* %F, float* %f) nounwind {
; X32-LABEL: test2:
; X32:       # %bb.0: # %entry
; X32-NEXT:    pushl %eax
; X32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    movaps (%eax), %xmm0
; X32-NEXT:    addps %xmm0, %xmm0
; X32-NEXT:    movhlps {{.*#+}} xmm0 = xmm0[1,1]
; X32-NEXT:    movss %xmm0, (%esp)
; X32-NEXT:    flds (%esp)
; X32-NEXT:    popl %eax
; X32-NEXT:    retl
;
; X64-LABEL: test2:
; X64:       # %bb.0: # %entry
; X64-NEXT:    movaps (%rdi), %xmm0
; X64-NEXT:    addps %xmm0, %xmm0
; X64-NEXT:    movhlps {{.*#+}} xmm0 = xmm0[1,1]
; X64-NEXT:    retq
entry:
  %tmp = load <4 x float>, <4 x float>* %F
  %tmp7 = fadd <4 x float> %tmp, %tmp
  %tmp2 = extractelement <4 x float> %tmp7, i32 2
  ret float %tmp2
}

define void @test3(float* %R, <4 x float>* %P1) nounwind {
; X32-LABEL: test3:
; X32:       # %bb.0: # %entry
; X32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X32-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; X32-NEXT:    movss %xmm0, (%eax)
; X32-NEXT:    retl
;
; X64-LABEL: test3:
; X64:       # %bb.0: # %entry
; X64-NEXT:    movss {{.*#+}} xmm0 = mem[0],zero,zero,zero
; X64-NEXT:    movss %xmm0, (%rdi)
; X64-NEXT:    retq
entry:
  %X = load <4 x float>, <4 x float>* %P1
  %tmp = extractelement <4 x float> %X, i32 3
  store float %tmp, float* %R
  ret void
}

define double @test4(double %A) nounwind {
; X32-LABEL: test4:
; X32:       # %bb.0: # %entry
; X32-NEXT:    subl $12, %esp
; X32-NEXT:    calll foo
; X32-NEXT:    unpckhpd {{.*#+}} xmm0 = xmm0[1,1]
; X32-NEXT:    addsd {{[0-9]+}}(%esp), %xmm0
; X32-NEXT:    movsd %xmm0, (%esp)
; X32-NEXT:    fldl (%esp)
; X32-NEXT:    addl $12, %esp
; X32-NEXT:    retl
;
; X64-LABEL: test4:
; X64:       # %bb.0: # %entry
; X64-NEXT:    pushq %rax
; X64-NEXT:    movsd %xmm0, (%rsp) # 8-byte Spill
; X64-NEXT:    callq foo
; X64-NEXT:    unpckhpd {{.*#+}} xmm0 = xmm0[1,1]
; X64-NEXT:    addsd (%rsp), %xmm0 # 8-byte Folded Reload
; X64-NEXT:    popq %rax
; X64-NEXT:    retq
entry:
  %tmp1 = call <2 x double> @foo( )
  %tmp2 = extractelement <2 x double> %tmp1, i32 1
  %tmp3 = fadd double %tmp2, %A
  ret double %tmp3
}

declare <2 x double> @foo()
