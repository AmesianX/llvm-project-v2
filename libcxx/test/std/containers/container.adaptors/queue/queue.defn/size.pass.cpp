//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// <queue>

// size_type size() const;

#include <queue>
#include <cassert>

int main()
{
    std::queue<int> q;
    assert(q.size() == 0);
    q.push(1);
    assert(q.size() == 1);
}
