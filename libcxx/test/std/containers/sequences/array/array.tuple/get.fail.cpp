//===----------------------------------------------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is dual licensed under the MIT and the University of Illinois Open
// Source Licenses. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

// <array>

// template <size_t I, class T, size_t N> T& get(array<T, N>& a);

// Prevent -Warray-bounds from issuing a diagnostic when testing with clang verify.
#if defined(__clang__)
#pragma clang diagnostic ignored "-Warray-bounds"
#endif

#include <array>
#include <cassert>


// std::array is explicitly allowed to be initialized with A a = { init-list };.
// Disable the missing braces warning for this reason.
#include "disable_missing_braces_warning.h"

int main()
{
    {
        typedef double T;
        typedef std::array<T, 3> C;
        C c = {1, 2, 3.5};
        std::get<3>(c) = 5.5; // expected-note {{requested here}}
        // expected-error-re@array:* {{static_assert failed{{( due to requirement '3U[L]{0,2} < 3U[L]{0,2}')?}} "Index out of bounds in std::get<> (std::array)"}}
    }
}
