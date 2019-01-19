//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// <valarray>

// template<class T> class valarray;

// valarray(const gslice_array<value_type>& sa);

#include <valarray>
#include <cassert>

int main()
{
    int a[] = { 0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11,
               12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23,
               24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35,
               36, 37, 38, 39, 40};
    std::valarray<int> v1(a, sizeof(a)/sizeof(a[0]));
    std::size_t sz[] = {2, 4, 3};
    std::size_t st[] = {19, 4, 1};
    typedef std::valarray<std::size_t> sizes;
    typedef std::valarray<std::size_t> strides;
    std::valarray<int> v(v1[std::gslice(3, sizes(sz, sizeof(sz)/sizeof(sz[0])),
                                         strides(st, sizeof(st)/sizeof(st[0])))]);
    assert(v.size() == 24);
    assert(v[ 0] ==  3);
    assert(v[ 1] ==  4);
    assert(v[ 2] ==  5);
    assert(v[ 3] ==  7);
    assert(v[ 4] ==  8);
    assert(v[ 5] ==  9);
    assert(v[ 6] == 11);
    assert(v[ 7] == 12);
    assert(v[ 8] == 13);
    assert(v[ 9] == 15);
    assert(v[10] == 16);
    assert(v[11] == 17);
    assert(v[12] == 22);
    assert(v[13] == 23);
    assert(v[14] == 24);
    assert(v[15] == 26);
    assert(v[16] == 27);
    assert(v[17] == 28);
    assert(v[18] == 30);
    assert(v[19] == 31);
    assert(v[20] == 32);
    assert(v[21] == 34);
    assert(v[22] == 35);
    assert(v[23] == 36);
}
