// REQUIRES: aarch64
// RUN: llvm-mc -filetype=obj -triple=arm64 -mattr=+morello,+c64 %s -o %t.o
// RUN: ld.lld %t.o -o %t
// RUN: llvm-objdump --mattr=+morello -d %t | FileCheck %s

// CHECK: adrp c25, 0x8020f000 <foo+0x1ffffc>
// CHECK: adrp c26, 0xffffffff80210000

  .text
  .global _start
  .type _start, %function
_start:
  foo = .
  adrp c25, foo+0x7FFFF000
  adrp c26, foo-0x80000000
