//===----------------------------------------------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is dual licensed under the MIT and the University of Illinois Open
// Source Licenses. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

// <functional>


//  In C++17, the function adapters mem_fun/mem_fun_ref, etc have been removed.
//  However, for backwards compatibility, if _LIBCPP_ENABLE_CXX17_REMOVED_BINDERS
//  is defined before including <functional>, then they will be restored.

#define _LIBCPP_ENABLE_CXX17_REMOVED_BINDERS

#include <functional>
#include <cassert>

int identity(int v) { return v; }
int sum(int a, int b) { return a + b; }

struct Foo {
	int zero() const { return 0; }
	int identity(int v) const { return v; }
	int sum(int a, int b) const { return a + b; }
};

int main()
{
	typedef std::pointer_to_unary_function<int, int> PUF;
	typedef std::pointer_to_binary_function<int, int, int> PBF;
	assert((std::ptr_fun<int, int>(identity)(4) == 4));
	assert((std::ptr_fun<int, int, int>(sum)(4, 5) == 9));
	
	Foo f;
	assert((std::mem_fn(&Foo::identity)(f, 5) == 5));
	assert((std::mem_fn(&Foo::sum)(f, 5, 6) == 11));
	
    typedef std::mem_fun_ref_t<int, Foo> MFR;
    typedef std::const_mem_fun_ref_t<int, Foo> CMFR;
	
	assert((std::mem_fun_ref(&Foo::zero)(f) == 0));
	assert((std::mem_fun_ref(&Foo::identity)(f, 5) == 5));
}
