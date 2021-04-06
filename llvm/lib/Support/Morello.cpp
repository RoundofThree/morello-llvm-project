//===- Morello.cpp - Morello-specific utility functions for capabilities --===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "llvm/Support/MathExtras.h"
#include "llvm/Support/Morello.h"

using namespace llvm;

namespace llvm {

uint64_t getMorelloRequiredAlignment(uint64_t length) {
  // FIXME: In the specification l is a 65-bit value to permit the encoding
  // of 2^64 via E = 52, T = 0, B = 0. We don't have a case where length
  // can be 2^ 64 at the moment.
  // Using formula E = 52 - CountLeadingZeros(length[64:13])
  uint64_t E = length >> 13;
  if (E)
    E = 52 - countLeadingZeros(length);
  // Ie = 0 if E == 0 and Length[12] == 0; 1 otherwise
  if (E == 0 && ((length & 0x1000) == 0))
    // InternalExponent Ie = 0 no additional alignment requirements
    return 1;
  // InternalExponent Ie = 1 Alignment Requirement is 2 ^ E+3
  return 1 << (E + 3);
}

} // namespace llvm
