// RUN: not llvm-mc -triple armv8 -show-encoding -mattr=+specctrl < %s 2>&1 | FileCheck %s

sbeq

// CHECK: instruction 'sb' is not predicable
