//===-- Implementation header for memset ------------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIBC_SRC_STRING_MEMSET_H
#define LLVM_LIBC_SRC_STRING_MEMSET_H

#include "include/string.h"

namespace __llvm_libc {

void *memset(void *ptr, int value, size_t count);

} // namespace __llvm_libc

#endif // LLVM_LIBC_SRC_STRING_MEMSET_H
