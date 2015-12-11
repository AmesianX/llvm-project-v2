// RUN: %clang_profgen -O2 -o %t %s
// RUN: env LLVM_PROFILE_FILE=%t.profraw %run %t
// RUN: llvm-profdata merge -o %t.profdata %t.profraw
// RUN: llvm-profdata show --all-functions -ic-targets  %t.profdata |  FileCheck  %s 

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
typedef struct __llvm_profile_data __llvm_profile_data;
const __llvm_profile_data *__llvm_profile_begin_data(void);
const __llvm_profile_data *__llvm_profile_end_data(void);
void __llvm_profile_set_num_value_sites(__llvm_profile_data *Data,
                                        uint32_t ValueKind,
                                        uint16_t NumValueSites);
__llvm_profile_data *
__llvm_profile_iterate_data(const __llvm_profile_data *Data);
void *__llvm_get_function_addr(const __llvm_profile_data *Data);
void __llvm_profile_instrument_target(uint64_t TargetValue, void *Data,
                                      uint32_t CounterIndex);
void callee1() {}
void callee2() {}

void caller_without_value_site1() {}
void caller_with_value_site_never_called1() {}
void caller_with_vp1() {}
void caller_with_value_site_never_called2() {}
void caller_without_value_site2() {}
void caller_with_vp2() {}

int main(int argc, const char *argv[]) {
  unsigned S, NS = 10, V;
  const __llvm_profile_data *Data, *DataEnd;

  Data = __llvm_profile_begin_data();
  DataEnd = __llvm_profile_end_data();
  for (; Data < DataEnd; Data = __llvm_profile_iterate_data(Data)) {
    void *func = __llvm_get_function_addr(Data);
    if (func == caller_without_value_site1 ||
        func == caller_without_value_site2 ||
        func == callee1 || func == callee2 || func == main)
      continue;

    __llvm_profile_set_num_value_sites((__llvm_profile_data *)Data,
                                       0 /*IPVK_IndirectCallTarget */, 10);

    if (func == caller_with_value_site_never_called1 ||
        func == caller_with_value_site_never_called2)
      continue;
    for (S = 0; S < NS; S++) {
      unsigned C;
      for (C = 0; C < S + 1; C++) {
        __llvm_profile_instrument_target((uint64_t)&callee1, (void *)Data, S);
        if (C % 2 == 0)
          __llvm_profile_instrument_target((uint64_t)&callee2, (void *)Data, S);
      }
    }
  }
}

// CHECK:  caller_with_value_site_never_called2:
// CHECK-NEXT:    Hash: 0x0000000000000000
// CHECK-NEXT:    Counters:
// CHECK-NEXT:    Function count
// CHECK-NEXT:    Indirect Call Site Count: 10
// CHECK-NEXT:    Indirect Target Results: 
// CHECK:       caller_with_vp2:
// CHECK-NEXT:    Hash: 0x0000000000000000
// CHECK-NEXT:    Counters:
// CHECK-NEXT:    Function count:
// CHECK-NEXT:    Indirect Call Site Count: 10
// CHECK-NEXT:    Indirect Target Results: 
// CHECK-NEXT:	[ 0, callee1, 1 ]
// CHECK-NEXT:	[ 0, callee2, 1 ]
// CHECK-NEXT:	[ 1, callee1, 2 ]
// CHECK-NEXT:	[ 1, callee2, 1 ]
// CHECK-NEXT:	[ 2, callee1, 3 ]
// CHECK-NEXT:	[ 2, callee2, 2 ]
// CHECK-NEXT:	[ 3, callee1, 4 ]
// CHECK-NEXT:	[ 3, callee2, 2 ]
// CHECK-NEXT:	[ 4, callee1, 5 ]
// CHECK-NEXT:	[ 4, callee2, 3 ]
// CHECK-NEXT:	[ 5, callee1, 6 ]
// CHECK-NEXT:	[ 5, callee2, 3 ]
// CHECK-NEXT:	[ 6, callee1, 7 ]
// CHECK-NEXT:	[ 6, callee2, 4 ]
// CHECK-NEXT:	[ 7, callee1, 8 ]
// CHECK-NEXT:	[ 7, callee2, 4 ]
// CHECK-NEXT:	[ 8, callee1, 9 ]
// CHECK-NEXT:	[ 8, callee2, 5 ]
// CHECK-NEXT:	[ 9, callee1, 10 ]
// CHECK-NEXT:	[ 9, callee2, 5 ]
// CHECK:       caller_with_vp1:
// CHECK-NEXT:    Hash: 0x0000000000000000
// CHECK-NEXT:    Counters:
// CHECK-NEXT:    Function count
// CHECK-NEXT:    Indirect Call Site Count: 10
// CHECK-NEXT:    Indirect Target Results: 
// CHECK-NEXT:	[ 0, callee1, 1 ]
// CHECK-NEXT:	[ 0, callee2, 1 ]
// CHECK-NEXT:	[ 1, callee1, 2 ]
// CHECK-NEXT:	[ 1, callee2, 1 ]
// CHECK-NEXT:	[ 2, callee1, 3 ]
// CHECK-NEXT:	[ 2, callee2, 2 ]
// CHECK-NEXT:	[ 3, callee1, 4 ]
// CHECK-NEXT:	[ 3, callee2, 2 ]
// CHECK-NEXT:	[ 4, callee1, 5 ]
// CHECK-NEXT:	[ 4, callee2, 3 ]
// CHECK-NEXT:	[ 5, callee1, 6 ]
// CHECK-NEXT:	[ 5, callee2, 3 ]
// CHECK-NEXT:	[ 6, callee1, 7 ]
// CHECK-NEXT:	[ 6, callee2, 4 ]
// CHECK-NEXT:	[ 7, callee1, 8 ]
// CHECK-NEXT:	[ 7, callee2, 4 ]
// CHECK-NEXT:	[ 8, callee1, 9 ]
// CHECK-NEXT:	[ 8, callee2, 5 ]
// CHECK-NEXT:	[ 9, callee1, 10 ]
// CHECK-NEXT:	[ 9, callee2, 5 ]
// CHECK:       caller_with_value_site_never_called1:
// CHECK-NEXT:    Hash: 0x0000000000000000
// CHECK-NEXT:    Counters:
// CHECK-NEXT:    Function count:
// CHECK-NEXT:    Indirect Call Site Count: 10
// CHECK-NEXT:    Indirect Target Results: 
// CHECK:       caller_without_value_site2:
// CHECK-NEXT:    Hash: 0x0000000000000000
// CHECK-NEXT:    Counters:
// CHECK-NEXT:    Function count:
// CHECK-NEXT:    Indirect Call Site Count: 0
// CHECK-NEXT:    Indirect Target Results: 
// CHECK:       caller_without_value_site1:
// CHECK-NEXT:    Hash: 0x0000000000000000
// CHECK-NEXT:    Counters:
// CHECK-NEXT:    Function count:
// CHECK-NEXT:    Indirect Call Site Count: 0
// CHECK-NEXT:    Indirect Target Results: 
