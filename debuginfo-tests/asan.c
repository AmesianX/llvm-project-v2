// RUN: %clang %target_itanium_abi_host_triple -arch x86_64 %s -o %t.out -g -fsanitize=address
// RUN: %test_debuginfo %s %t.out
// REQUIRES: not_asan
//           Zorg configures the ASAN stage2 bots to not build the asan
//           compiler-rt. Only run this test on non-asanified configurations.
void b();
struct S {
  int a[8];
};

int f(struct S s, unsigned i) {
  // DEBUGGER: break 16
  // DEBUGGER: r
  // DEBUGGER: p s
  // CHECK: a = ([0] = 0, [1] = 1, [2] = 2, [3] = 3, [4] = 4, [5] = 5, [6] = 6, [7] = 7)
  return s.a[i];
}

int main(int argc, const char **argv) {
  struct S s = {{0, 1, 2, 3, 4, 5, 6, 7}};
  if (f(s, 4) == 4) {
    // DEBUGGER: break 26
    // DEBUGGER: c
    // DEBUGGER: p s
    // CHECK: a = ([0] = 0, [1] = 1, [2] = 2, [3] = 3, [4] = 4, [5] = 5, [6] = 6, [7] = 7)
    b();
  }
  return 0;
}

void c() {}

void b() {
  // DEBUGGER: break 39
  // DEBUGGER: c
  // DEBUGGER: p x
  // CHECK: 42
  __block int x = 42;
  c();
}
