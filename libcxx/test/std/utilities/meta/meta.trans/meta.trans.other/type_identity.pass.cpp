//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
// UNSUPPORTED: c++98, c++03, c++11, c++14, c++17

// type_traits

// type_identity

#include <type_traits>

#include "test_macros.h"

template <class T>
void test_type_identity()
{
    static_assert((std::is_same<typename std::type_identity<T>::type, T>::value), "");
    static_assert((std::is_same<         std::type_identity_t<T>,     T>::value), "");
}

int main(int, char**)
{
    test_type_identity<void>();
    test_type_identity<int>();
    test_type_identity<const volatile int>();
    test_type_identity<int*>();
    test_type_identity<      int[3]>();
    test_type_identity<const int[3]>();

    test_type_identity<void (*)()>();
    test_type_identity<int(int) const>();
    test_type_identity<int(int) volatile>();
    test_type_identity<int(int)  &>();
    test_type_identity<int(int) &&>();

  return 0;
}
