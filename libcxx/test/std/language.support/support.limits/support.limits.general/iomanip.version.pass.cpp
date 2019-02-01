//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// WARNING: This test was generated by generate_feature_test_macro_components.py
// and should not be edited manually.

// <iomanip>

// Test the feature test macros defined by <iomanip>

/*  Constant                      Value
    __cpp_lib_quoted_string_io    201304L [C++14]
*/

#include <iomanip>
#include "test_macros.h"

#if TEST_STD_VER < 14

# ifdef __cpp_lib_quoted_string_io
#   error "__cpp_lib_quoted_string_io should not be defined before c++14"
# endif

#elif TEST_STD_VER == 14

# ifndef __cpp_lib_quoted_string_io
#   error "__cpp_lib_quoted_string_io should be defined in c++14"
# endif
# if __cpp_lib_quoted_string_io != 201304L
#   error "__cpp_lib_quoted_string_io should have the value 201304L in c++14"
# endif

#elif TEST_STD_VER == 17

# ifndef __cpp_lib_quoted_string_io
#   error "__cpp_lib_quoted_string_io should be defined in c++17"
# endif
# if __cpp_lib_quoted_string_io != 201304L
#   error "__cpp_lib_quoted_string_io should have the value 201304L in c++17"
# endif

#elif TEST_STD_VER > 17

# ifndef __cpp_lib_quoted_string_io
#   error "__cpp_lib_quoted_string_io should be defined in c++2a"
# endif
# if __cpp_lib_quoted_string_io != 201304L
#   error "__cpp_lib_quoted_string_io should have the value 201304L in c++2a"
# endif

#endif // TEST_STD_VER > 17

int main() {}
