; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
;RUN: llc < %s | FileCheck %s

; This test case failed on legalization of "shl" node. PR29058.

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@structMember = external local_unnamed_addr global i64, align 8

; Function Attrs: norecurse nounwind uwtable
define i32 @_Z3foov() local_unnamed_addr #0 {
; CHECK-LABEL: _Z3foov:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    movq %rax, {{.*}}(%rip)
; CHECK-NEXT:    retq
entry:
  %bool_1 = icmp ne i8 undef, 0
  %bool_2 = icmp eq i8 undef, 0
  %0 = select i1 %bool_2, i32 2147483646, i32 undef
  %or_1 = select i1 %bool_1, i32 undef, i32 -1
  %shl_1 = shl i32 %0, %or_1
  %conv = zext i32 %shl_1 to i64
  store i64 %conv, i64* @structMember, align 8
  %tmp = select i1 %bool_2, i32 2147483646, i32 undef
  %lnot = icmp eq i8 undef, 0
  %or_2 = select i1 %lnot, i32 -1, i32 undef
  %shl_2 = shl i32 %tmp, %or_2
  ret i32 %shl_2
}

attributes #0 = { norecurse nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

