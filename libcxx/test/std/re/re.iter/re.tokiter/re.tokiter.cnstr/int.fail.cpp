//===----------------------------------------------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is dual licensed under the MIT and the University of Illinois Open
// Source Licenses. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

// <regex>

// class regex_iterator<BidirectionalIterator, charT, traits>

// regex_token_iterator(BidirectionalIterator a, BidirectionalIterator b,
//                      const regex_type&& re, int submatch = 0,
//                      regex_constants::match_flag_type m =
//                                              regex_constants::match_default);

// XFAIL: C++98, c++03, c++11

#include <regex>
#include <cassert>
#include "test_macros.h"

int main()
{
    {
        std::regex phone_numbers("\\d{3}-\\d{4}");
        const char phone_book[] = "start 555-1234, 555-2345, 555-3456 end";
        std::cregex_token_iterator i(std::begin(phone_book), std::end(phone_book)-1,
                                     std::regex("\\d{3}-\\d{4}"), -1);
    }
}
