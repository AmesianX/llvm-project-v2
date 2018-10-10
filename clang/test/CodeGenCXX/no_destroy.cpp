// RUN: %clang_cc1 %s -emit-llvm -triple x86_64-apple-macosx10.13.0 -o - | FileCheck %s

struct NonTrivial {
  ~NonTrivial();
};

// CHECK-NOT: __cxa_atexit{{.*}}_ZN10NonTrivialD1Ev
[[clang::no_destroy]] NonTrivial nt1;
// CHECK-NOT: _tlv_atexit{{.*}}_ZN10NonTrivialD1Ev
[[clang::no_destroy]] thread_local NonTrivial nt2;

struct NonTrivial2 {
  ~NonTrivial2();
};

// CHECK: __cxa_atexit{{.*}}_ZN11NonTrivial2D1Ev
NonTrivial2 nt21;
// CHECK: _tlv_atexit{{.*}}_ZN11NonTrivial2D1Ev
thread_local NonTrivial2 nt22;

void f() {
  // CHECK: __cxa_atexit{{.*}}_ZN11NonTrivial2D1Ev
  static NonTrivial2 nt21;
  // CHECK: _tlv_atexit{{.*}}_ZN11NonTrivial2D1Ev
  thread_local NonTrivial2 nt22;
}

// CHECK: __cxa_atexit{{.*}}_ZN10NonTrivialD1Ev
[[clang::always_destroy]] NonTrivial nt3;
// CHECK: _tlv_atexit{{.*}}_ZN10NonTrivialD1Ev
[[clang::always_destroy]] thread_local NonTrivial nt4;
