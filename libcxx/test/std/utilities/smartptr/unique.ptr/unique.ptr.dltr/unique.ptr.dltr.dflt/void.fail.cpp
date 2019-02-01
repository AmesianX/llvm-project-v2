//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// <memory>

// default_delete

// Test that default_delete's operator() requires a complete type

#include <memory>
#include <cassert>

int main()
{
    std::default_delete<const void> d;
    const void* p = 0;
    d(p);
}
