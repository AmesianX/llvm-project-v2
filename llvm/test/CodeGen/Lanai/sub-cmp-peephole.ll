; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=lanai | FileCheck %s

define i32 @f(i32 inreg %a, i32 inreg %b) nounwind ssp {
; CHECK-LABEL: f:
; CHECK:       ! %bb.0:
; CHECK-NEXT:    st %fp, [--%sp]
; CHECK-NEXT:    add %sp, 0x8, %fp
; CHECK-NEXT:    sub %sp, 0x8, %sp
; CHECK-NEXT:    sub.f %r6, %r7, %r3
; CHECK-NEXT:    sel.gt %r3, %r0, %rv
; CHECK-NEXT:    ld -4[%fp], %pc ! return
; CHECK-NEXT:    add %fp, 0x0, %sp
; CHECK-NEXT:    ld -8[%fp], %fp
  %cmp = icmp sgt i32 %a, %b
  %sub = sub nsw i32 %a, %b
  %sub. = select i1 %cmp, i32 %sub, i32 0
  ret i32 %sub.
}

define i32 @g(i32 inreg %a, i32 inreg %b) nounwind ssp {
; CHECK-LABEL: g:
; CHECK:       ! %bb.0:
; CHECK-NEXT:    st %fp, [--%sp]
; CHECK-NEXT:    add %sp, 0x8, %fp
; CHECK-NEXT:    sub %sp, 0x8, %sp
; CHECK-NEXT:    sub.f %r7, %r6, %r3
; CHECK-NEXT:    sel.lt %r3, %r0, %rv
; CHECK-NEXT:    ld -4[%fp], %pc ! return
; CHECK-NEXT:    add %fp, 0x0, %sp
; CHECK-NEXT:    ld -8[%fp], %fp
  %cmp = icmp slt i32 %a, %b
  %sub = sub nsw i32 %b, %a
  %sub. = select i1 %cmp, i32 %sub, i32 0
  ret i32 %sub.
}

define i32 @h(i32 inreg %a, i32 inreg %b) nounwind ssp {
; CHECK-LABEL: h:
; CHECK:       ! %bb.0:
; CHECK-NEXT:    st %fp, [--%sp]
; CHECK-NEXT:    add %sp, 0x8, %fp
; CHECK-NEXT:    sub %sp, 0x8, %sp
; CHECK-NEXT:    sub.f %r6, 0x3, %r3
; CHECK-NEXT:    sel.gt %r3, %r7, %rv
; CHECK-NEXT:    ld -4[%fp], %pc ! return
; CHECK-NEXT:    add %fp, 0x0, %sp
; CHECK-NEXT:    ld -8[%fp], %fp
  %cmp = icmp sgt i32 %a, 3
  %sub = sub nsw i32 %a, 3
  %sub. = select i1 %cmp, i32 %sub, i32 %b
  ret i32 %sub.
}

define i32 @i(i32 inreg %a, i32 inreg %b) nounwind readnone ssp {
; CHECK-LABEL: i:
; CHECK:       ! %bb.0:
; CHECK-NEXT:    st %fp, [--%sp]
; CHECK-NEXT:    add %sp, 0x8, %fp
; CHECK-NEXT:    sub %sp, 0x8, %sp
; CHECK-NEXT:    sub.f %r7, %r6, %r3
; CHECK-NEXT:    sel.ult %r3, %r0, %rv
; CHECK-NEXT:    ld -4[%fp], %pc ! return
; CHECK-NEXT:    add %fp, 0x0, %sp
; CHECK-NEXT:    ld -8[%fp], %fp
  %cmp = icmp ult i32 %a, %b
  %sub = sub i32 %b, %a
  %sub. = select i1 %cmp, i32 %sub, i32 0
  ret i32 %sub.
}

; If SR is live-out, we can't remove cmp if there exists a swapped sub.
define i32 @j(i32 inreg %a, i32 inreg %b) nounwind {
; CHECK-LABEL: j:
; CHECK:       ! %bb.0: ! %entry
; CHECK-NEXT:    st %fp, [--%sp]
; CHECK-NEXT:    add %sp, 0x8, %fp
; CHECK-NEXT:    sub %sp, 0x8, %sp
; CHECK-NEXT:    sub.f %r7, %r6, %r0
; CHECK-NEXT:    bne .LBB4_2
; CHECK-NEXT:    sub %r6, %r7, %rv
; CHECK-NEXT:  .LBB4_1: ! %if.then
; CHECK-NEXT:    sel.gt %rv, %r6, %rv
; CHECK-NEXT:  .LBB4_2: ! %if.else
; CHECK-NEXT:    ld -4[%fp], %pc ! return
; CHECK-NEXT:    add %fp, 0x0, %sp
; CHECK-NEXT:    ld -8[%fp], %fp
entry:
  %cmp = icmp eq i32 %b, %a
  %sub = sub nsw i32 %a, %b
  br i1 %cmp, label %if.then, label %if.else

if.then:
  %cmp2 = icmp sgt i32 %b, %a
  %sel = select i1 %cmp2, i32 %sub, i32 %a
  ret i32 %sel

if.else:
  ret i32 %sub
}

declare void @abort()
declare void @exit(i32)
@t = common global i32 0

; If the comparison uses the C bit (signed overflow/underflow), we can't
; omit the comparison.
define i32 @cmp_ult0(i32 inreg %a, i32 inreg %b, i32 inreg %x, i32 inreg %y) {
; CHECK-LABEL: cmp_ult0:
; CHECK:       ! %bb.0: ! %entry
; CHECK-NEXT:    st %fp, [--%sp]
; CHECK-NEXT:    add %sp, 0x8, %fp
; CHECK-NEXT:    mov hi(t), %r3
; CHECK-NEXT:    or %r3, lo(t), %r3
; CHECK-NEXT:    ld 0[%r3], %r3
; CHECK-NEXT:    sub %r3, 0x11, %r3
; CHECK-NEXT:    sub.f %r3, 0x0, %r0
; CHECK-NEXT:    buge .LBB5_2
; CHECK-NEXT:    sub %sp, 0x10, %sp
; CHECK-NEXT:  .LBB5_1: ! %if.then
; CHECK-NEXT:    add %pc, 0x10, %rca
; CHECK-NEXT:    st %rca, [--%sp]
; CHECK-NEXT:    bt abort
; CHECK-NEXT:    nop
; CHECK-NEXT:  .LBB5_2: ! %if.else
; CHECK-NEXT:    st %r0, 0[%sp]
; CHECK-NEXT:    add %pc, 0x10, %rca
; CHECK-NEXT:    st %rca, [--%sp]
; CHECK-NEXT:    bt exit
; CHECK-NEXT:    nop
entry:
  %load = load i32, i32* @t, align 4
  %sub = sub i32 %load, 17
  %cmp = icmp ult i32 %sub, 0
  br i1 %cmp, label %if.then, label %if.else

if.then:
  call void @abort()
  unreachable

if.else:
  call void @exit(i32 0)
  unreachable
}

; Same for the V bit.
; TODO: add test that exercises V bit individually (VC/VS).
define i32 @cmp_gt0(i32 inreg %a, i32 inreg %b, i32 inreg %x, i32 inreg %y) {
; CHECK-LABEL: cmp_gt0:
; CHECK:       ! %bb.0: ! %entry
; CHECK-NEXT:    st %fp, [--%sp]
; CHECK-NEXT:    add %sp, 0x8, %fp
; CHECK-NEXT:    mov hi(t), %r3
; CHECK-NEXT:    or %r3, lo(t), %r3
; CHECK-NEXT:    ld 0[%r3], %r3
; CHECK-NEXT:    sub %r3, 0x11, %r3
; CHECK-NEXT:    sub.f %r3, 0x1, %r0
; CHECK-NEXT:    blt .LBB6_2
; CHECK-NEXT:    sub %sp, 0x10, %sp
; CHECK-NEXT:  .LBB6_1: ! %if.then
; CHECK-NEXT:    add %pc, 0x10, %rca
; CHECK-NEXT:    st %rca, [--%sp]
; CHECK-NEXT:    bt abort
; CHECK-NEXT:    nop
; CHECK-NEXT:  .LBB6_2: ! %if.else
; CHECK-NEXT:    st %r0, 0[%sp]
; CHECK-NEXT:    add %pc, 0x10, %rca
; CHECK-NEXT:    st %rca, [--%sp]
; CHECK-NEXT:    bt exit
; CHECK-NEXT:    nop
entry:
  %load = load i32, i32* @t, align 4
  %sub = sub i32 %load, 17
  %cmp = icmp sgt i32 %sub, 0
  br i1 %cmp, label %if.then, label %if.else

if.then:
  call void @abort()
  unreachable

if.else:
  call void @exit(i32 0)
  unreachable
}
