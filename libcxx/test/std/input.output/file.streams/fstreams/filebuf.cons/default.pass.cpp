//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// <fstream>

// template <class charT, class traits = char_traits<charT> >
// class basic_filebuf

// basic_filebuf();

#include <fstream>
#include <cassert>

int main()
{
    {
        std::filebuf f;
        assert(!f.is_open());
    }
    {
        std::wfilebuf f;
        assert(!f.is_open());
    }
}
