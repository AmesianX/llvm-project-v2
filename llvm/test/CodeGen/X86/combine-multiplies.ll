; RUN: llc < %s -mattr=sse2 -mtriple=i386-unknown-linux-gnu | FileCheck %s

; Source file looks something like this:
;
; typedef int AAA[100][100];
;
; void testCombineMultiplies(AAA a,int lll)
; {
;   int LOC = lll + 5;
;
;   a[LOC][LOC] = 11;
;
;   a[LOC][20] = 22;
;   a[LOC+20][20] = 33;
; }
;
; We want to make sure we don't generate 2 multiply instructions,
; one for a[LOC][] and one for a[LOC+20]. visitMUL in DAGCombiner.cpp
; should combine the instructions in such a way to avoid the extra
; multiply.
;
; Output looks roughly like this:
;
;	movl	8(%esp), %eax
;	movl	12(%esp), %ecx
;	imull	$400, %ecx, %edx        # imm = 0x190
;	leal	(%edx,%eax), %esi
;	movl	$11, 2020(%esi,%ecx,4)
;	movl	$22, 2080(%edx,%eax)
;	movl	$33, 10080(%edx,%eax)
;
; CHECK-LABEL: testCombineMultiplies
; CHECK: imull $400, [[ARG1:%[a-z]+]], [[MUL:%[a-z]+]] # imm = 0x190
; CHECK-NEXT: leal ([[MUL]],[[ARG2:%[a-z]+]]), [[LEA:%[a-z]+]]
; CHECK-NEXT: movl $11, {{[0-9]+}}([[LEA]],[[ARG1]],4)
; CHECK-NEXT: movl $22, {{[0-9]+}}([[MUL]],[[ARG2]])
; CHECK-NEXT: movl $33, {{[0-9]+}}([[MUL]],[[ARG2]])
; CHECK: retl
;

; Function Attrs: nounwind
define void @testCombineMultiplies([100 x i32]* nocapture %a, i32 %lll) {
entry:
  %add = add nsw i32 %lll, 5
  %arrayidx1 = getelementptr inbounds [100 x i32], [100 x i32]* %a, i32 %add, i32 %add
  store i32 11, i32* %arrayidx1, align 4
  %arrayidx3 = getelementptr inbounds [100 x i32], [100 x i32]* %a, i32 %add, i32 20
  store i32 22, i32* %arrayidx3, align 4
  %add4 = add nsw i32 %lll, 25
  %arrayidx6 = getelementptr inbounds [100 x i32], [100 x i32]* %a, i32 %add4, i32 20
  store i32 33, i32* %arrayidx6, align 4
  ret void
}


; Test for the same optimization on vector multiplies.
;
; Source looks something like this:
;
; typedef int v4int __attribute__((__vector_size__(16)));
;
; v4int x;
; v4int v2, v3;
; void testCombineMultiplies_splat(v4int v1) {
;   v2 = (v1 + (v4int){ 11, 11, 11, 11 }) * (v4int) {22, 22, 22, 22};
;   v3 = (v1 + (v4int){ 33, 33, 33, 33 }) * (v4int) {22, 22, 22, 22};
;   x = (v1 + (v4int){ 11, 11, 11, 11 });
; }
;
; Output looks something like this:
;
; testCombineMultiplies_splat:                              # @testCombineMultiplies_splat
; # BB#0:                                 # %entry
; 	movdqa	.LCPI1_0, %xmm1         # xmm1 = [11,11,11,11]
; 	paddd	%xmm0, %xmm1
; 	movdqa	.LCPI1_1, %xmm2         # xmm2 = [22,22,22,22]
; 	pshufd	$245, %xmm0, %xmm3      # xmm3 = xmm0[1,1,3,3]
; 	pmuludq	%xmm2, %xmm0
; 	pshufd	$232, %xmm0, %xmm0      # xmm0 = xmm0[0,2,2,3]
; 	pmuludq	%xmm2, %xmm3
; 	pshufd	$232, %xmm3, %xmm2      # xmm2 = xmm3[0,2,2,3]
; 	punpckldq	%xmm2, %xmm0    # xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1]
; 	movdqa	.LCPI1_2, %xmm2         # xmm2 = [242,242,242,242]
;	paddd	%xmm0, %xmm2
;	paddd	.LCPI1_3, %xmm0
;	movdqa	%xmm2, v2
;	movdqa	%xmm0, v3
;	movdqa	%xmm1, x
;	retl
;
; Again, we want to make sure we don't generate two different multiplies.
; We should have a single multiply for "v1 * {22, 22, 22, 22}" (made up of two
; pmuludq instructions), followed by two adds. Without this optimization, we'd
; do 2 adds, followed by 2 multiplies (i.e. 4 pmuludq instructions).
;
; CHECK-LABEL: testCombineMultiplies_splat
; CHECK:       movdqa .LCPI1_0, [[C11:%xmm[0-9]]]
; CHECK-NEXT:  paddd %xmm0, [[C11]]
; CHECK-NEXT:  movdqa .LCPI1_1, [[C22:%xmm[0-9]]]
; CHECK-NEXT:  pshufd $245, %xmm0, [[T1:%xmm[0-9]]]
; CHECK-NEXT:  pmuludq [[C22]], [[T2:%xmm[0-9]]]
; CHECK-NEXT:  pshufd $232, [[T2]], [[T3:%xmm[0-9]]]
; CHECK-NEXT:  pmuludq [[C22]], [[T4:%xmm[0-9]]]
; CHECK-NEXT:  pshufd $232, [[T4]], [[T5:%xmm[0-9]]]
; CHECK-NEXT:  punpckldq [[T5]], [[T6:%xmm[0-9]]]
; CHECK-NEXT:  movdqa .LCPI1_2, [[C242:%xmm[0-9]]]
; CHECK-NEXT:  paddd [[T6]], [[C242]]
; CHECK-NEXT:  paddd .LCPI1_3, [[C726:%xmm[0-9]]]
; CHECK-NEXT:  movdqa [[C242]], v2
; CHECK-NEXT:  [[C726]], v3
; CHECK-NEXT:  [[C11]], x
; CHECK-NEXT:  retl 

@v2 = common global <4 x i32> zeroinitializer, align 16
@v3 = common global <4 x i32> zeroinitializer, align 16
@x = common global <4 x i32> zeroinitializer, align 16

; Function Attrs: nounwind
define void @testCombineMultiplies_splat(<4 x i32> %v1) {
entry:
  %add1 = add <4 x i32> %v1, <i32 11, i32 11, i32 11, i32 11>
  %mul1 = mul <4 x i32> %add1, <i32 22, i32 22, i32 22, i32 22>
  %add2 = add <4 x i32> %v1, <i32 33, i32 33, i32 33, i32 33>
  %mul2 = mul <4 x i32> %add2, <i32 22, i32 22, i32 22, i32 22>
  store <4 x i32> %mul1, <4 x i32>* @v2, align 16
  store <4 x i32> %mul2, <4 x i32>* @v3, align 16
  store <4 x i32> %add1, <4 x i32>* @x, align 16
  ret void
}

; Finally, check the non-splatted vector case. This is very similar
; to the previous test case, except for the vector values.
;
; CHECK-LABEL: testCombineMultiplies_non_splat
; CHECK:       movdqa .LCPI2_0, [[C11:%xmm[0-9]]]
; CHECK-NEXT:  paddd %xmm0, [[C11]]
; CHECK-NEXT:  movdqa .LCPI2_1, [[C22:%xmm[0-9]]]
; CHECK-NEXT:  pshufd $245, %xmm0, [[T1:%xmm[0-9]]]
; CHECK-NEXT:  pmuludq [[C22]], [[T2:%xmm[0-9]]]
; CHECK-NEXT:  pshufd $232, [[T2]], [[T3:%xmm[0-9]]]
; CHECK-NEXT:  pshufd $245, [[C22]], [[T7:%xmm[0-9]]]
; CHECK-NEXT:  pmuludq [[T1]], [[T7]]
; CHECK-NEXT:  pshufd $232, [[T7]], [[T5:%xmm[0-9]]]
; CHECK-NEXT:  punpckldq [[T5]], [[T6:%xmm[0-9]]]
; CHECK-NEXT:  movdqa .LCPI2_2, [[C242:%xmm[0-9]]]
; CHECK-NEXT:  paddd [[T6]], [[C242]]
; CHECK-NEXT:  paddd .LCPI2_3, [[C726:%xmm[0-9]]]
; CHECK-NEXT:  movdqa [[C242]], v2
; CHECK-NEXT:  [[C726]], v3
; CHECK-NEXT:  [[C11]], x
; CHECK-NEXT:  retl 
; Function Attrs: nounwind
define void @testCombineMultiplies_non_splat(<4 x i32> %v1) {
entry:
  %add1 = add <4 x i32> %v1, <i32 11, i32 22, i32 33, i32 44>
  %mul1 = mul <4 x i32> %add1, <i32 22, i32 33, i32 44, i32 55>
  %add2 = add <4 x i32> %v1, <i32 33, i32 44, i32 55, i32 66>
  %mul2 = mul <4 x i32> %add2, <i32 22, i32 33, i32 44, i32 55>
  store <4 x i32> %mul1, <4 x i32>* @v2, align 16
  store <4 x i32> %mul2, <4 x i32>* @v3, align 16
  store <4 x i32> %add1, <4 x i32>* @x, align 16
  ret void
}
