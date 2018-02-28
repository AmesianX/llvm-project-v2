// RUN: %clang_cc1 -triple i686-unknown-windows-msvc -fobjc-runtime=ios-6.0 -Os -S -emit-llvm -o - %s -mdisable-fp-elim | FileCheck %s

struct S {
  S() = default;
  S(const S &) {}
};

@interface I
+ (S)m:(S)s;
@end

S f() {
  return [I m:S()];
}

// CHECK: declare dllimport void @objc_msgSend_stret(i8*, i8*, ...)
// CHECK-NOT: declare dllimport void @objc_msgSend(i8*, i8*, ...)

