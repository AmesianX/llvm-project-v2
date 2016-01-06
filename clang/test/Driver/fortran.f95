// Check that the clang driver can invoke gcc to compile Fortran.

// RUN: %clang -target x86_64-unknown-linux-gnu -integrated-as -c %s -### 2>&1 \
// RUN:   | FileCheck --check-prefix=CHECK-OBJECT %s
// CHECK-OBJECT: gcc
// CHECK-OBJECT: "-c"
// CHECK-OBJECT: "-x" "f95"
// CHECK-OBJECT-NOT: cc1as

// RUN: %clang -target x86_64-unknown-linux-gnu -integrated-as -S %s -### 2>&1 \
// RUN:   | FileCheck --check-prefix=CHECK-ASM %s
// CHECK-ASM: gcc
// CHECK-ASM: "-S"
// CHECK-ASM: "-x" "f95"
// CHECK-ASM-NOT: cc1
