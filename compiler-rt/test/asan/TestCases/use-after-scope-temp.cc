// RUN: %clangxx_asan -O1 -mllvm -asan-use-after-scope=1 %s -o %t && \
// RUN:     not %run %t 2>&1 | FileCheck %s
//
// Lifetime for temporaries is not emitted yet.
// XFAIL: *

struct IntHolder {
  int val;
};

const IntHolder *saved;

void save(const IntHolder &holder) {
  saved = &holder;
}

int main(int argc, char *argv[]) {
  save({10});
  int x = saved->val;  // BOOM
// CHECK: ERROR: AddressSanitizer: stack-use-after-scope
// CHECK:  #0 0x{{.*}} in main {{.*}}use-after-scope-temp.cc:[[@LINE-2]]
  return x;
}
