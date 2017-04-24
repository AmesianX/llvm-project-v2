; RUN: opt < %s -instcombine -S | FileCheck %s

; PR1510

; (a | b) & ~(a & b) --> a ^ b

define i32 @and_to_xor1(i32 %a, i32 %b) {
; CHECK-LABEL: @and_to_xor1(
; CHECK-NEXT:    [[AND2:%.*]] = xor i32 %a, %b
; CHECK-NEXT:    ret i32 [[AND2]]
;
  %or = or i32 %a, %b
  %and = and i32 %a, %b
  %not = xor i32 %and, -1
  %and2 = and i32 %or, %not
  ret i32 %and2
}

; ~(a & b) & (a | b) --> a ^ b

define i32 @and_to_xor2(i32 %a, i32 %b) {
; CHECK-LABEL: @and_to_xor2(
; CHECK-NEXT:    [[AND2:%.*]] = xor i32 %a, %b
; CHECK-NEXT:    ret i32 [[AND2]]
;
  %or = or i32 %a, %b
  %and = and i32 %a, %b
  %not = xor i32 %and, -1
  %and2 = and i32 %not, %or
  ret i32 %and2
}

; (a | b) & ~(b & a) --> a ^ b

define i32 @and_to_xor3(i32 %a, i32 %b) {
; CHECK-LABEL: @and_to_xor3(
; CHECK-NEXT:    [[AND2:%.*]] = xor i32 %a, %b
; CHECK-NEXT:    ret i32 [[AND2]]
;
  %or = or i32 %a, %b
  %and = and i32 %b, %a
  %not = xor i32 %and, -1
  %and2 = and i32 %or, %not
  ret i32 %and2
}

; ~(a & b) & (b | a) --> a ^ b

define i32 @and_to_xor4(i32 %a, i32 %b) {
; CHECK-LABEL: @and_to_xor4(
; CHECK-NEXT:    [[AND2:%.*]] = xor i32 %b, %a
; CHECK-NEXT:    ret i32 [[AND2]]
;
  %or = or i32 %b, %a
  %and = and i32 %a, %b
  %not = xor i32 %and, -1
  %and2 = and i32 %not, %or
  ret i32 %and2
}

define <4 x i32> @and_to_xor1_vec(<4 x i32> %a, <4 x i32> %b) {
; CHECK-LABEL: @and_to_xor1_vec(
; CHECK-NEXT:    [[AND2:%.*]] = xor <4 x i32> %a, %b
; CHECK-NEXT:    ret <4 x i32> [[AND2]]
;
  %or = or <4 x i32> %a, %b
  %and = and <4 x i32> %a, %b
  %not = xor <4 x i32> %and, < i32 -1, i32 -1, i32 -1, i32 -1 >
  %and2 = and <4 x i32> %or, %not
  ret <4 x i32> %and2
}

; In the next 4 tests, cast instructions are used to thwart operand complexity
; canonicalizations, so we can test all of the commuted patterns.

; (a | ~b) & (~a | b) --> ~(a ^ b)

define i32 @and_to_nxor1(float %fa, float %fb) {
; CHECK-LABEL: @and_to_nxor1(
; CHECK-NEXT:    [[A:%.*]] = fptosi float %fa to i32
; CHECK-NEXT:    [[B:%.*]] = fptosi float %fb to i32
; CHECK-NEXT:    [[TMP1:%.*]] = xor i32 [[A]], [[B]]
; CHECK-NEXT:    [[AND:%.*]] = xor i32 [[TMP1]], -1
; CHECK-NEXT:    ret i32 [[AND]]
;
  %a = fptosi float %fa to i32
  %b = fptosi float %fb to i32
  %nota = xor i32 %a, -1
  %notb = xor i32 %b, -1
  %or1 = or i32 %a, %notb
  %or2 = or i32 %nota, %b
  %and = and i32 %or1, %or2
  ret i32 %and
}

; (a | ~b) & (b | ~a) --> ~(a ^ b)

define i32 @and_to_nxor2(float %fa, float %fb) {
; CHECK-LABEL: @and_to_nxor2(
; CHECK-NEXT:    [[A:%.*]] = fptosi float %fa to i32
; CHECK-NEXT:    [[B:%.*]] = fptosi float %fb to i32
; CHECK-NEXT:    [[TMP1:%.*]] = xor i32 [[A]], [[B]]
; CHECK-NEXT:    [[AND:%.*]] = xor i32 [[TMP1]], -1
; CHECK-NEXT:    ret i32 [[AND]]
;
  %a = fptosi float %fa to i32
  %b = fptosi float %fb to i32
  %nota = xor i32 %a, -1
  %notb = xor i32 %b, -1
  %or1 = or i32 %a, %notb
  %or2 = or i32 %b, %nota
  %and = and i32 %or1, %or2
  ret i32 %and
}

; (~a | b) & (a | ~b) --> ~(a ^ b)

define i32 @and_to_nxor3(float %fa, float %fb) {
; CHECK-LABEL: @and_to_nxor3(
; CHECK-NEXT:    [[A:%.*]] = fptosi float %fa to i32
; CHECK-NEXT:    [[B:%.*]] = fptosi float %fb to i32
; CHECK-NEXT:    [[TMP1:%.*]] = xor i32 [[B]], [[A]]
; CHECK-NEXT:    [[AND:%.*]] = xor i32 [[TMP1]], -1
; CHECK-NEXT:    ret i32 [[AND]]
;
  %a = fptosi float %fa to i32
  %b = fptosi float %fb to i32
  %nota = xor i32 %a, -1
  %notb = xor i32 %b, -1
  %or1 = or i32 %nota, %b
  %or2 = or i32 %a, %notb
  %and = and i32 %or1, %or2
  ret i32 %and
}

; (~a | b) & (~b | a) --> ~(a ^ b)

define i32 @and_to_nxor4(float %fa, float %fb) {
; CHECK-LABEL: @and_to_nxor4(
; CHECK-NEXT:    [[A:%.*]] = fptosi float %fa to i32
; CHECK-NEXT:    [[B:%.*]] = fptosi float %fb to i32
; CHECK-NEXT:    [[TMP1:%.*]] = xor i32 [[B]], [[A]]
; CHECK-NEXT:    [[AND:%.*]] = xor i32 [[TMP1]], -1
; CHECK-NEXT:    ret i32 [[AND]]
;
  %a = fptosi float %fa to i32
  %b = fptosi float %fb to i32
  %nota = xor i32 %a, -1
  %notb = xor i32 %b, -1
  %or1 = or i32 %nota, %b
  %or2 = or i32 %notb, %a
  %and = and i32 %or1, %or2
  ret i32 %and
}

; (a & ~b) | (~a & b) --> a ^ b

define i32 @or_to_xor1(float %fa, float %fb) {
; CHECK-LABEL: @or_to_xor1(
; CHECK-NEXT:    [[A:%.*]] = fptosi float %fa to i32
; CHECK-NEXT:    [[B:%.*]] = fptosi float %fb to i32
; CHECK-NEXT:    [[OR:%.*]] = xor i32 [[A]], [[B]]
; CHECK-NEXT:    ret i32 [[OR]]
;
  %a = fptosi float %fa to i32
  %b = fptosi float %fb to i32
  %nota = xor i32 %a, -1
  %notb = xor i32 %b, -1
  %and1 = and i32 %a, %notb
  %and2 = and i32 %nota, %b
  %or = or i32 %and1, %and2
  ret i32 %or
}

; (a & ~b) | (b & ~a) --> a ^ b

define i32 @or_to_xor2(float %fa, float %fb) {
; CHECK-LABEL: @or_to_xor2(
; CHECK-NEXT:    [[A:%.*]] = fptosi float %fa to i32
; CHECK-NEXT:    [[B:%.*]] = fptosi float %fb to i32
; CHECK-NEXT:    [[OR:%.*]] = xor i32 [[A]], [[B]]
; CHECK-NEXT:    ret i32 [[OR]]
;
  %a = fptosi float %fa to i32
  %b = fptosi float %fb to i32
  %nota = xor i32 %a, -1
  %notb = xor i32 %b, -1
  %and1 = and i32 %a, %notb
  %and2 = and i32 %b, %nota
  %or = or i32 %and1, %and2
  ret i32 %or
}

; (~a & b) | (~b & a) --> a ^ b

define i32 @or_to_xor3(float %fa, float %fb) {
; CHECK-LABEL: @or_to_xor3(
; CHECK-NEXT:    [[A:%.*]] = fptosi float %fa to i32
; CHECK-NEXT:    [[B:%.*]] = fptosi float %fb to i32
; CHECK-NEXT:    [[OR:%.*]] = xor i32 [[B]], [[A]]
; CHECK-NEXT:    ret i32 [[OR]]
;
  %a = fptosi float %fa to i32
  %b = fptosi float %fb to i32
  %nota = xor i32 %a, -1
  %notb = xor i32 %b, -1
  %and1 = and i32 %nota, %b
  %and2 = and i32 %notb, %a
  %or = or i32 %and1, %and2
  ret i32 %or
}

; (~a & b) | (a & ~b) --> a ^ b

define i32 @or_to_xor4(float %fa, float %fb) {
; CHECK-LABEL: @or_to_xor4(
; CHECK-NEXT:    [[A:%.*]] = fptosi float %fa to i32
; CHECK-NEXT:    [[B:%.*]] = fptosi float %fb to i32
; CHECK-NEXT:    [[OR:%.*]] = xor i32 [[B]], [[A]]
; CHECK-NEXT:    ret i32 [[OR]]
;
  %a = fptosi float %fa to i32
  %b = fptosi float %fb to i32
  %nota = xor i32 %a, -1
  %notb = xor i32 %b, -1
  %and1 = and i32 %nota, %b
  %and2 = and i32 %a, %notb
  %or = or i32 %and1, %and2
  ret i32 %or
}

; (a & b) | ~(a | b) --> ~(a ^ b)

define i32 @or_to_nxor1(i32 %a, i32 %b) {
; CHECK-LABEL: @or_to_nxor1(
; CHECK-NEXT:    [[TMP1:%.*]] = xor i32 %a, %b
; CHECK-NEXT:    [[OR2:%.*]] = xor i32 [[TMP1]], -1
; CHECK-NEXT:    ret i32 [[OR2]]
;
  %and = and i32 %a, %b
  %or = or i32 %a, %b
  %notor = xor i32 %or, -1
  %or2 = or i32 %and, %notor
  ret i32 %or2
}

; (a & b) | ~(b | a) --> ~(a ^ b)

define i32 @or_to_nxor2(i32 %a, i32 %b) {
; CHECK-LABEL: @or_to_nxor2(
; CHECK-NEXT:    [[TMP1:%.*]] = xor i32 %a, %b
; CHECK-NEXT:    [[OR2:%.*]] = xor i32 [[TMP1]], -1
; CHECK-NEXT:    ret i32 [[OR2]]
;
  %and = and i32 %a, %b
  %or = or i32 %b, %a
  %notor = xor i32 %or, -1
  %or2 = or i32 %and, %notor
  ret i32 %or2
}

; ~(a | b) | (a & b) --> ~(a ^ b)

define i32 @or_to_nxor3(i32 %a, i32 %b) {
; CHECK-LABEL: @or_to_nxor3(
; CHECK-NEXT:    [[TMP1:%.*]] = xor i32 %a, %b
; CHECK-NEXT:    [[OR2:%.*]] = xor i32 [[TMP1]], -1
; CHECK-NEXT:    ret i32 [[OR2]]
;
  %and = and i32 %a, %b
  %or = or i32 %a, %b
  %notor = xor i32 %or, -1
  %or2 = or i32 %notor, %and
  ret i32 %or2
}

; ~(a | b) | (b & a) --> ~(a ^ b)

define i32 @or_to_nxor4(i32 %a, i32 %b) {
; CHECK-LABEL: @or_to_nxor4(
; CHECK-NEXT:    [[TMP1:%.*]] = xor i32 %b, %a
; CHECK-NEXT:    [[OR2:%.*]] = xor i32 [[TMP1]], -1
; CHECK-NEXT:    ret i32 [[OR2]]
;
  %and = and i32 %b, %a
  %or = or i32 %a, %b
  %notor = xor i32 %or, -1
  %or2 = or i32 %notor, %and
  ret i32 %or2
}

; (a & b) ^ (a | b) --> a ^ b

define i32 @xor_to_xor1(i32 %a, i32 %b) {
; CHECK-LABEL: @xor_to_xor1(
; CHECK-NEXT:    [[XOR:%.*]] = xor i32 %a, %b
; CHECK-NEXT:    ret i32 [[XOR]]
;
  %and = and i32 %a, %b
  %or = or i32 %a, %b
  %xor = xor i32 %and, %or
  ret i32 %xor
}

; (a & b) ^ (b | a) --> a ^ b

define i32 @xor_to_xor2(i32 %a, i32 %b) {
; CHECK-LABEL: @xor_to_xor2(
; CHECK-NEXT:    [[XOR:%.*]] = xor i32 %a, %b
; CHECK-NEXT:    ret i32 [[XOR]]
;
  %and = and i32 %a, %b
  %or = or i32 %b, %a
  %xor = xor i32 %and, %or
  ret i32 %xor
}

; (a | b) ^ (a & b) --> a ^ b

define i32 @xor_to_xor3(i32 %a, i32 %b) {
; CHECK-LABEL: @xor_to_xor3(
; CHECK-NEXT:    [[XOR:%.*]] = xor i32 %a, %b
; CHECK-NEXT:    ret i32 [[XOR]]
;
  %or = or i32 %a, %b
  %and = and i32 %a, %b
  %xor = xor i32 %or, %and
  ret i32 %xor
}

; (a | b) ^ (b & a) --> a ^ b

define i32 @xor_to_xor4(i32 %a, i32 %b) {
; CHECK-LABEL: @xor_to_xor4(
; CHECK-NEXT:    [[XOR:%.*]] = xor i32 %a, %b
; CHECK-NEXT:    ret i32 [[XOR]]
;
  %or = or i32 %a, %b
  %and = and i32 %b, %a
  %xor = xor i32 %or, %and
  ret i32 %xor
}

; (a | ~b) ^ (~a | b) --> a ^ b

; In the next 8 tests, cast instructions are used to thwart operand complexity
; canonicalizations, so we can test all of the commuted patterns.

define i32 @xor_to_xor5(float %fa, float %fb) {
; CHECK-LABEL: @xor_to_xor5(
; CHECK-NEXT:    [[A:%.*]] = fptosi float %fa to i32
; CHECK-NEXT:    [[B:%.*]] = fptosi float %fb to i32
; CHECK-NEXT:    [[XOR:%.*]] = xor i32 [[A]], [[B]]
; CHECK-NEXT:    ret i32 [[XOR]]
;
  %a = fptosi float %fa to i32
  %b = fptosi float %fb to i32
  %nota = xor i32 %a, -1
  %notb = xor i32 %b, -1
  %or1 = or i32 %a, %notb
  %or2 = or i32 %nota, %b
  %xor = xor i32 %or1, %or2
  ret i32 %xor
}

; (a | ~b) ^ (b | ~a) --> a ^ b

define i32 @xor_to_xor6(float %fa, float %fb) {
; CHECK-LABEL: @xor_to_xor6(
; CHECK-NEXT:    [[A:%.*]] = fptosi float %fa to i32
; CHECK-NEXT:    [[B:%.*]] = fptosi float %fb to i32
; CHECK-NEXT:    [[XOR:%.*]] = xor i32 [[B]], [[A]]
; CHECK-NEXT:    ret i32 [[XOR]]
;
  %a = fptosi float %fa to i32
  %b = fptosi float %fb to i32
  %nota = xor i32 %a, -1
  %notb = xor i32 %b, -1
  %or1 = or i32 %a, %notb
  %or2 = or i32 %b, %nota
  %xor = xor i32 %or1, %or2
  ret i32 %xor
}

; (~a | b) ^ (a | ~b) --> a ^ b

define i32 @xor_to_xor7(float %fa, float %fb) {
; CHECK-LABEL: @xor_to_xor7(
; CHECK-NEXT:    [[A:%.*]] = fptosi float %fa to i32
; CHECK-NEXT:    [[B:%.*]] = fptosi float %fb to i32
; CHECK-NEXT:    [[XOR:%.*]] = xor i32 [[A]], [[B]]
; CHECK-NEXT:    ret i32 [[XOR]]
;
  %a = fptosi float %fa to i32
  %b = fptosi float %fb to i32
  %nota = xor i32 %a, -1
  %notb = xor i32 %b, -1
  %or1 = or i32 %a, %notb
  %or2 = or i32 %nota, %b
  %xor = xor i32 %or2, %or1
  ret i32 %xor
}

; (~a | b) ^ (~b | a) --> a ^ b

define i32 @xor_to_xor8(float %fa, float %fb) {
; CHECK-LABEL: @xor_to_xor8(
; CHECK-NEXT:    [[A:%.*]] = fptosi float %fa to i32
; CHECK-NEXT:    [[B:%.*]] = fptosi float %fb to i32
; CHECK-NEXT:    [[XOR:%.*]] = xor i32 [[B]], [[A]]
; CHECK-NEXT:    ret i32 [[XOR]]
;
  %a = fptosi float %fa to i32
  %b = fptosi float %fb to i32
  %nota = xor i32 %a, -1
  %notb = xor i32 %b, -1
  %or1 = or i32 %notb, %a
  %or2 = or i32 %nota, %b
  %xor = xor i32 %or2, %or1
  ret i32 %xor
}

; (a & ~b) ^ (~a & b) --> a ^ b

define i32 @xor_to_xor9(float %fa, float %fb) {
; CHECK-LABEL: @xor_to_xor9(
; CHECK-NEXT:    [[A:%.*]] = fptosi float %fa to i32
; CHECK-NEXT:    [[B:%.*]] = fptosi float %fb to i32
; CHECK-NEXT:    [[XOR:%.*]] = xor i32 [[A]], [[B]]
; CHECK-NEXT:    ret i32 [[XOR]]
;
  %a = fptosi float %fa to i32
  %b = fptosi float %fb to i32
  %nota = xor i32 %a, -1
  %notb = xor i32 %b, -1
  %and1 = and i32 %a, %notb
  %and2 = and i32 %nota, %b
  %xor = xor i32 %and1, %and2
  ret i32 %xor
}

; (a & ~b) ^ (b & ~a) --> a ^ b

define i32 @xor_to_xor10(float %fa, float %fb) {
; CHECK-LABEL: @xor_to_xor10(
; CHECK-NEXT:    [[A:%.*]] = fptosi float %fa to i32
; CHECK-NEXT:    [[B:%.*]] = fptosi float %fb to i32
; CHECK-NEXT:    [[XOR:%.*]] = xor i32 [[B]], [[A]]
; CHECK-NEXT:    ret i32 [[XOR]]
;
  %a = fptosi float %fa to i32
  %b = fptosi float %fb to i32
  %nota = xor i32 %a, -1
  %notb = xor i32 %b, -1
  %and1 = and i32 %a, %notb
  %and2 = and i32 %b, %nota
  %xor = xor i32 %and1, %and2
  ret i32 %xor
}

; (~a & b) ^ (a & ~b) --> a ^ b

define i32 @xor_to_xor11(float %fa, float %fb) {
; CHECK-LABEL: @xor_to_xor11(
; CHECK-NEXT:    [[A:%.*]] = fptosi float %fa to i32
; CHECK-NEXT:    [[B:%.*]] = fptosi float %fb to i32
; CHECK-NEXT:    [[XOR:%.*]] = xor i32 [[A]], [[B]]
; CHECK-NEXT:    ret i32 [[XOR]]
;
  %a = fptosi float %fa to i32
  %b = fptosi float %fb to i32
  %nota = xor i32 %a, -1
  %notb = xor i32 %b, -1
  %and1 = and i32 %a, %notb
  %and2 = and i32 %nota, %b
  %xor = xor i32 %and2, %and1
  ret i32 %xor
}

; (~a & b) ^ (~b & a) --> a ^ b

define i32 @xor_to_xor12(float %fa, float %fb) {
; CHECK-LABEL: @xor_to_xor12(
; CHECK-NEXT:    [[A:%.*]] = fptosi float %fa to i32
; CHECK-NEXT:    [[B:%.*]] = fptosi float %fb to i32
; CHECK-NEXT:    [[XOR:%.*]] = xor i32 [[B]], [[A]]
; CHECK-NEXT:    ret i32 [[XOR]]
;
  %a = fptosi float %fa to i32
  %b = fptosi float %fb to i32
  %nota = xor i32 %a, -1
  %notb = xor i32 %b, -1
  %and1 = and i32 %notb, %a
  %and2 = and i32 %nota, %b
  %xor = xor i32 %and2, %and1
  ret i32 %xor
}

; ~(~(a | b) | (a & b)) --> (a | b) & ~(a & b) -> a ^ b

define i32 @demorgan_plus_and_to_xor(i32 %a, i32 %b) {
; CHECK-LABEL: @demorgan_plus_and_to_xor(
; CHECK-NEXT:    [[NOT:%.*]] = xor i32 %b, %a
; CHECK-NEXT:    ret i32 [[NOT]]
;
  %or = or i32 %b, %a
  %notor = xor i32 %or, -1
  %and = and i32 %b, %a
  %or2 = or i32 %and, %notor
  %not = xor i32 %or2, -1
  ret i32 %not
}

define <4 x i32> @demorgan_plus_and_to_xor_vec(<4 x i32> %a, <4 x i32> %b) {
; CHECK-LABEL: @demorgan_plus_and_to_xor_vec(
; CHECK-NEXT:    [[NOT:%.*]] = xor <4 x i32> %a, %b
; CHECK-NEXT:    ret <4 x i32> [[NOT]]
;
  %or = or <4 x i32> %a, %b
  %notor = xor <4 x i32> %or, < i32 -1, i32 -1, i32 -1, i32 -1 >
  %and = and <4 x i32> %a, %b
  %or2 = or <4 x i32> %and, %notor
  %not = xor <4 x i32> %or2, < i32 -1, i32 -1, i32 -1, i32 -1 >
  ret <4 x i32> %not
}

