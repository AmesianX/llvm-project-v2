//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// <set>

// class multiset

// template <class InputIterator>
//   void insert(InputIterator first, InputIterator last);

#include <set>
#include <cassert>

#include "test_iterators.h"
#include "min_allocator.h"

int main()
{
    {
        typedef std::multiset<int> M;
        typedef int V;
        V ar[] =
        {
            1,
            1,
            1,
            2,
            2,
            2,
            3,
            3,
            3
        };
        M m;
        m.insert(input_iterator<const V*>(ar),
                 input_iterator<const V*>(ar + sizeof(ar)/sizeof(ar[0])));
        assert(m.size() == 9);
        assert(*next(m.begin(), 0) == 1);
        assert(*next(m.begin(), 1) == 1);
        assert(*next(m.begin(), 2) == 1);
        assert(*next(m.begin(), 3) == 2);
        assert(*next(m.begin(), 4) == 2);
        assert(*next(m.begin(), 5) == 2);
        assert(*next(m.begin(), 6) == 3);
        assert(*next(m.begin(), 7) == 3);
        assert(*next(m.begin(), 8) == 3);
    }
#if TEST_STD_VER >= 11
    {
        typedef std::multiset<int, std::less<int>, min_allocator<int>> M;
        typedef int V;
        V ar[] =
        {
            1,
            1,
            1,
            2,
            2,
            2,
            3,
            3,
            3
        };
        M m;
        m.insert(input_iterator<const V*>(ar),
                 input_iterator<const V*>(ar + sizeof(ar)/sizeof(ar[0])));
        assert(m.size() == 9);
        assert(*next(m.begin(), 0) == 1);
        assert(*next(m.begin(), 1) == 1);
        assert(*next(m.begin(), 2) == 1);
        assert(*next(m.begin(), 3) == 2);
        assert(*next(m.begin(), 4) == 2);
        assert(*next(m.begin(), 5) == 2);
        assert(*next(m.begin(), 6) == 3);
        assert(*next(m.begin(), 7) == 3);
        assert(*next(m.begin(), 8) == 3);
    }
#endif
}
