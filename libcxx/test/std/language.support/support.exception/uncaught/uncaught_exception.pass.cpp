//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// UNSUPPORTED: libcpp-no-exceptions
// test uncaught_exception

#include <exception>
#include <cassert>

struct A
{
    ~A()
    {
        assert(std::uncaught_exception());
    }
};

struct B
{
    B()
    {
        // http://www.open-std.org/jtc1/sc22/wg21/docs/cwg_defects.html#475
        assert(!std::uncaught_exception());
    }
};

int main()
{
    try
    {
        A a;
        assert(!std::uncaught_exception());
        throw B();
    }
    catch (...)
    {
        assert(!std::uncaught_exception());
    }
    assert(!std::uncaught_exception());
}
