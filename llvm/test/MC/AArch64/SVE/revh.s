// RUN: llvm-mc -triple=aarch64 -show-encoding -mattr=+sve < %s \
// RUN:        | FileCheck %s --check-prefixes=CHECK-ENCODING,CHECK-INST
// RUN: not llvm-mc -triple=aarch64 -show-encoding < %s 2>&1 \
// RUN:        | FileCheck %s --check-prefix=CHECK-ERROR
// RUN: llvm-mc -triple=aarch64 -filetype=obj -mattr=+sve < %s \
// RUN:        | llvm-objdump -d -mattr=+sve - | FileCheck %s --check-prefix=CHECK-INST
// RUN: llvm-mc -triple=aarch64 -filetype=obj -mattr=+sve < %s \
// RUN:        | llvm-objdump -d - | FileCheck %s --check-prefix=CHECK-UNKNOWN

revh  z0.s, p7/m, z31.s
// CHECK-INST: revh	z0.s, p7/m, z31.s
// CHECK-ENCODING: [0xe0,0x9f,0xa5,0x05]
// CHECK-ERROR: instruction requires: sve
// CHECK-UNKNOWN: e0 9f a5 05 <unknown>

revh  z0.d, p7/m, z31.d
// CHECK-INST: revh	z0.d, p7/m, z31.d
// CHECK-ENCODING: [0xe0,0x9f,0xe5,0x05]
// CHECK-ERROR: instruction requires: sve
// CHECK-UNKNOWN: e0 9f e5 05 <unknown>
