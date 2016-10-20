// RUN: %check_clang_tidy %s readability-redundant-member-init %t

struct S {
  S() = default;
  S(int i) : i(i) {}
  int i = 1;
};

struct T {
  T(int i = 1) : i(i) {}
  int i;
};

struct U {
  int i;
};

union V {
  int i;
  double f;
};

// Initializer calls default constructor
struct F1 {
  F1() : f() {}
  // CHECK-MESSAGES: :[[@LINE-1]]:10: warning: initializer for member 'f' is redundant
  // CHECK-FIXES: F1()  {}
  S f;
};

// Initializer calls default constructor with default argument
struct F2 {
  F2() : f() {}
  // CHECK-MESSAGES: :[[@LINE-1]]:10: warning: initializer for member 'f' is redundant
  // CHECK-FIXES: F2()  {}
  T f;
};

// Multiple redundant initializers for same constructor
struct F3 {
  F3() : f(), g(1), h() {}
  // CHECK-MESSAGES: :[[@LINE-1]]:10: warning: initializer for member 'f' is redundant
  // CHECK-MESSAGES: :[[@LINE-2]]:21: warning: initializer for member 'h' is redundant
  // CHECK-FIXES: F3() :  g(1) {}
  S f, g, h;
};

// Templated class independent type
template <class V>
struct F4 {
  F4() : f() {}
  // CHECK-MESSAGES: :[[@LINE-1]]:10: warning: initializer for member 'f' is redundant
  // CHECK-FIXES: F4()  {}
  S f;
};
F4<int> f4i;
F4<S> f4s;

// Base class
struct F5 : S {
  F5() : S() {}
  // CHECK-MESSAGES: :[[@LINE-1]]:10: warning: initializer for base class 'S' is redundant
  // CHECK-FIXES: F5()  {}
};

// Constructor call requires cleanup
struct Cleanup {
  ~Cleanup() {}
};

struct UsesCleanup {
  UsesCleanup(const Cleanup &c = Cleanup()) {}
};

struct F6 {
  F6() : uc() {}
  // CHECK-MESSAGES: :[[@LINE-1]]:10: warning: initializer for member 'uc' is redundant
  // CHECK-FIXES: F6()  {}
  UsesCleanup uc;
};

// Multiple inheritance
struct F7 : S, T {
  F7() : S(), T() {}
  // CHECK-MESSAGES: :[[@LINE-1]]:10: warning: initializer for base class 'S' is redundant
  // CHECK-MESSAGES: :[[@LINE-2]]:15: warning: initializer for base class 'T' is redundant
  // CHECK-FIXES: F7()  {}
};

// Initializer not written
struct NF1 {
  NF1() {}
  S f;
};

// Initializer doesn't call default constructor
struct NF2 {
  NF2() : f(1) {}
  S f;
};

// Initializer calls default constructor without using default argument
struct NF3 {
  NF3() : f(1) {}
  T f;
};

// Initializer calls default constructor without using default argument
struct NF4 {
  NF4() : f(2) {}
  T f;
};

// Initializer is zero-initialization
struct NF5 {
  NF5() : i() {}
  int i;
};

// Initializer is direct-initialization
struct NF6 {
  NF6() : i(1) {}
  int i;
};

// Initializer is aggregate initialization of struct
struct NF7 {
  NF7() : f{} {}
  U f;
};

// Initializer is zero-initialization of struct
struct NF7b {
  NF7b() : f() {}
  U f;
};

// Initializer is aggregate initialization of array
struct NF8 {
  NF8() : f{} {}
  int f[2];
};

struct NF9 {
  NF9() : f{} {}
  S f[2];
};

// Initializing member of union
union NF10 {
  NF10() : s() {}
  int i;
  S s;
};

// Templated class dependent type
template <class V>
struct NF11 {
  NF11() : f() {}
  V f;
};
NF11<int> nf11i;
NF11<S> nf11s;

// Delegating constructor
class NF12 {
  NF12() = default;
  NF12(int) : NF12() {}
};

// Const member
struct NF13 {
  NF13() : f() {}
  const S f;
};

// Union member
struct NF14 {
  NF14() : f() {}
  V f;
};
