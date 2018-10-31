// RUN: %clang_cc1 -emit-llvm %s -o - -triple x86_64-linux-gnu | FileCheck %s -implicit-check-not="call void @__ubsan_handle_implicit_conversion" --check-prefix=CHECK
// RUN: %clang_cc1 -fsanitize=implicit-integer-sign-change -fno-sanitize-recover=implicit-integer-sign-change -emit-llvm %s -o - -triple x86_64-linux-gnu | FileCheck %s -implicit-check-not="call void @__ubsan_handle_implicit_conversion" --check-prefixes=CHECK,CHECK-SANITIZE,CHECK-SANITIZE-ANYRECOVER,CHECK-SANITIZE-NORECOVER
// RUN: %clang_cc1 -fsanitize=implicit-integer-sign-change -fsanitize-recover=implicit-integer-sign-change -emit-llvm %s -o - -triple x86_64-linux-gnu | FileCheck %s -implicit-check-not="call void @__ubsan_handle_implicit_conversion" --check-prefixes=CHECK,CHECK-SANITIZE,CHECK-SANITIZE-ANYRECOVER,CHECK-SANITIZE-RECOVER
// RUN: %clang_cc1 -fsanitize=implicit-integer-sign-change -fsanitize-trap=implicit-integer-sign-change -emit-llvm %s -o - -triple x86_64-linux-gnu | FileCheck %s -implicit-check-not="call void @__ubsan_handle_implicit_conversion" --check-prefixes=CHECK,CHECK-SANITIZE,CHECK-SANITIZE-TRAP

// ========================================================================== //
// The expected true-negatives.
// ========================================================================== //

// Sanitization is explicitly disabled.
// ========================================================================== //

// CHECK-LABEL: @blacklist_0
__attribute__((no_sanitize("undefined"))) unsigned int blacklist_0(signed int src) {
  // We are not in "undefined" group, so that doesn't work.
  // CHECK-SANITIZE: call
  return src;
}

// CHECK-LABEL: @blacklist_1
__attribute__((no_sanitize("integer"))) unsigned int blacklist_1(signed int src) {
  return src;
}

// CHECK-LABEL: @blacklist_2
__attribute__((no_sanitize("implicit-conversion"))) unsigned int blacklist_2(signed int src) {
  return src;
}

// CHECK-LABEL: @blacklist_3
__attribute__((no_sanitize("implicit-integer-sign-change"))) unsigned int blacklist_3(signed int src) {
  return src;
}

// Explicit sign-changing conversions.
// ========================================================================== //

// CHECK-LABEL: explicit_signed_int_to_unsigned_int
unsigned int explicit_signed_int_to_unsigned_int(signed int src) {
  return (unsigned int)src;
}

// CHECK-LABEL: explicit_unsigned_int_to_signed_int
signed int explicit_unsigned_int_to_signed_int(unsigned int src) {
  return (signed int)src;
}

// Explicit NOP conversions.
// ========================================================================== //

// CHECK-LABEL: @explicit_ununsigned_int_to_ununsigned_int
unsigned int explicit_ununsigned_int_to_ununsigned_int(unsigned int src) {
  return (unsigned int)src;
}

// CHECK-LABEL: @explicit_unsigned_int_to_unsigned_int
signed int explicit_unsigned_int_to_unsigned_int(signed int src) {
  return (signed int)src;
}

// conversions to to boolean type are not counted as sign-change.
// ========================================================================== //

// CHECK-LABEL: @unsigned_int_to_bool
_Bool unsigned_int_to_bool(unsigned int src) {
  return src;
}

// CHECK-LABEL: @signed_int_to_bool
_Bool signed_int_to_bool(signed int src) {
  return src;
}

// CHECK-LABEL: @explicit_unsigned_int_to_bool
_Bool explicit_unsigned_int_to_bool(unsigned int src) {
  return (_Bool)src;
}

// CHECK-LABEL: @explicit_signed_int_to_bool
_Bool explicit_signed_int_to_bool(signed int src) {
  return (_Bool)src;
}

// Explicit conversions from pointer to an integer.
// Can not have an implicit conversion from pointer to an integer.
// Can not have an implicit conversion between two enums.
// ========================================================================== //

// CHECK-LABEL: @explicit_voidptr_to_unsigned_int
unsigned int explicit_voidptr_to_unsigned_int(void *src) {
  return (unsigned int)src;
}

// CHECK-LABEL: @explicit_voidptr_to_signed_int
signed int explicit_voidptr_to_signed_int(void *src) {
  return (signed int)src;
}

// Implicit conversions from floating-point.
// ========================================================================== //

// CHECK-LABEL: @float_to_unsigned_int
unsigned int float_to_unsigned_int(float src) {
  return src;
}

// CHECK-LABEL: @float_to_signed_int
signed int float_to_signed_int(float src) {
  return src;
}

// CHECK-LABEL: @double_to_unsigned_int
unsigned int double_to_unsigned_int(double src) {
  return src;
}

// CHECK-LABEL: @double_to_signed_int
signed int double_to_signed_int(double src) {
  return src;
}

// Sugar.
// ========================================================================== //

typedef unsigned int uint32_t;

// CHECK-LABEL: @uint32_to_unsigned_int
unsigned int uint32_to_unsigned_int(uint32_t src) {
  return src;
}

// CHECK-LABEL: @unsigned_int_to_uint32
uint32_t unsigned_int_to_uint32(unsigned int src) {
  return src;
}

// CHECK-LABEL: @uint32_to_uint32
uint32_t uint32_to_uint32(uint32_t src) {
  return src;
}
