; RUN: llc --mtriple=i686-- --mcpu=x86-64 --mattr=ssse3 < %s
; RUN: llc --mtriple=x86_64-- --mcpu=x86-64 --mattr=ssse3 < %s

;PR18045:
;Issue of selection for 'v4i32 load'.
;This instruction is not legal for X86 CPUs with sse < 'sse4.1'.
;This node was generated by X86ISelLowering.cpp, EltsFromConsecutiveLoads
;static function after legalize stage.

@e = external global [4 x i32], align 4
@f = external global [4 x i32], align 4

; Function Attrs: nounwind
define void @fn3(i32 %el) {
entry:
  %0 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @e, i32 0, i32 0)
  %1 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @e, i32 0, i32 1)
  %2 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @e, i32 0, i32 2)
  %3 = load i32, i32* getelementptr inbounds ([4 x i32], [4 x i32]* @e, i32 0, i32 3)
  %4 = insertelement <4 x i32> undef, i32 %0, i32 0
  %5 = insertelement <4 x i32> %4, i32 %1, i32 1
  %6 = insertelement <4 x i32> %5, i32 %2, i32 2
  %7 = insertelement <4 x i32> %6, i32 %3, i32 3
  %8 = add <4 x i32> %6, %7
  store <4 x i32> %8, <4 x i32>* bitcast ([4 x i32]* @f to <4 x i32>*)
  ret void
}

