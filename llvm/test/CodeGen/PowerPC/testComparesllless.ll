; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -verify-machineinstrs -mtriple=powerpc64-unknown-linux-gnu -O2 \
; RUN:   -ppc-gpr-icmps=all -ppc-asm-full-reg-names -mcpu=pwr8 < %s | FileCheck %s \
; RUN:   --implicit-check-not cmpw --implicit-check-not cmpd --implicit-check-not cmpl
; RUN: llc -verify-machineinstrs -mtriple=powerpc64le-unknown-linux-gnu -O2 \
; RUN:   -ppc-gpr-icmps=all -ppc-asm-full-reg-names -mcpu=pwr8 < %s | FileCheck %s \
; RUN:   --implicit-check-not cmpw --implicit-check-not cmpd --implicit-check-not cmpl

@glob = common local_unnamed_addr global i16 0, align 2

define i64 @test_llless(i16 signext %a, i16 signext %b)  {
; CHECK-LABEL: test_llless:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sub r3, r4, r3
; CHECK-NEXT:    rldicl r3, r3, 1, 63
; CHECK-NEXT:    xori r3, r3, 1
; CHECK-NEXT:    blr
entry:
  %cmp = icmp sle i16 %a, %b
  %conv3 = zext i1 %cmp to i64
  ret i64 %conv3
}

define i64 @test_llless_sext(i16 signext %a, i16 signext %b)  {
; CHECK-LABEL: test_llless_sext:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sub r3, r4, r3
; CHECK-NEXT:    rldicl r3, r3, 1, 63
; CHECK-NEXT:    addi r3, r3, -1
; CHECK-NEXT:    blr
entry:
  %cmp = icmp sle i16 %a, %b
  %conv3 = sext i1 %cmp to i64
  ret i64 %conv3
}

define void @test_llless_store(i16 signext %a, i16 signext %b) {
; CHECK-LABEL: test_llless_store:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addis r5, r2, .LC0@toc@ha
; CHECK-NEXT:    sub r3, r4, r3
; CHECK-NEXT:    ld r4, .LC0@toc@l(r5)
; CHECK-NEXT:    rldicl r3, r3, 1, 63
; CHECK-NEXT:    xori r3, r3, 1
; CHECK-NEXT:    sth r3, 0(r4)
; CHECK-NEXT:    blr
entry:
  %cmp = icmp sle i16 %a, %b
  %conv3 = zext i1 %cmp to i16
  store i16 %conv3, i16* @glob, align 2
  ret void
}

define void @test_llless_sext_store(i16 signext %a, i16 signext %b) {
; CHECK-LABEL: test_llless_sext_store:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addis r5, r2, .LC0@toc@ha
; CHECK-NEXT:    sub r3, r4, r3
; CHECK-NEXT:    ld r4, .LC0@toc@l(r5)
; CHECK-NEXT:    rldicl r3, r3, 1, 63
; CHECK-NEXT:    addi r3, r3, -1
; CHECK-NEXT:    sth r3, 0(r4)
; CHECK-NEXT:    blr
entry:
  %cmp = icmp sle i16 %a, %b
  %conv3 = sext i1 %cmp to i16
  store i16 %conv3, i16* @glob, align 2
  ret void
}
