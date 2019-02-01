//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// UNSUPPORTED: libcpp-has-no-threads

// <future>

// class shared_future<R>

// shared_future();

#include <future>
#include <cassert>

int main()
{
    {
        std::shared_future<int> f;
        assert(!f.valid());
    }
    {
        std::shared_future<int&> f;
        assert(!f.valid());
    }
    {
        std::shared_future<void> f;
        assert(!f.valid());
    }
}
