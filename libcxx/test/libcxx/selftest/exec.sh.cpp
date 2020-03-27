// -*- C++ -*-
//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// RUN: %{build}
// RUN: %{exec} %t.exe "HELLO"

#include <cassert>
#include <string>

int main(int argc, char** argv) {
  assert(argc == 2);

  std::string arg = argv[1];
  assert(arg == "HELLO");
  return 0;
}
