//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// <functional>
// REQUIRES: c++98 || c++03 || c++11 || c++14

// template<Returnable S, ClassType T, CopyConstructible A>
//   mem_fun1_ref_t<S,T,A>
//   mem_fun_ref(S (T::*f)(A));

#include <functional>
#include <cassert>

struct A
{
    char a1() {return 5;}
    short a2(int i) {return short(i+1);}
    int a3() const {return 1;}
    double a4(unsigned i) const {return i-1;}
};

int main()
{
    A a;
    assert(std::mem_fun_ref(&A::a2)(a, 5) == 6);
}
