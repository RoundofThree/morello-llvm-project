//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// <iostream>

// istream clog;

// The FVP for now doesn't output to stderr so this doesn't work.
// Temporarily xfailing this.
// XFAIL: libcpp-has-newlib

// RUN: %{build}
// RUN: %{exec} %t.exe 2> %t.err
// RUN: grep -e 'Hello World!' %t.err

#include <iostream>

#include "test_macros.h"

int main(int, char**)
{
    std::clog << "Hello World!\n";

    return 0;
}
