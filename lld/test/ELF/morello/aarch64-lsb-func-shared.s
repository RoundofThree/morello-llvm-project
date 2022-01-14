// REQUIRES: aarch64
// RUN: llvm-mc --triple=aarch64-none-elf -target-abi purecap -mattr=+c64,+morello -filetype=obj %s -o %t.o
// RUN: ld.lld --shared -Bsymbolic %t.o -o %t.so
// RUN: llvm-objdump --print-imm-hex --no-show-raw-insn -d --triple=aarch64-none-elf --mattr=+morello -s %t.so | FileCheck %s
// RUN: llvm-readobj --symbols --relocations %t.so | FileCheck %s --check-prefix=RELS --check-prefix=SYMS

.text
.global _start
.type _start, %function
_start:
	adrp	c0, :got:bar
	ldr	c0, [c0, :got_lo12:bar]
	ret
.size _start, . - _start

.arch armv8-a+a64c
.global bar
.type bar, %function
bar:
	ret
.size bar, . - bar

// CHECK: Contents of section .got:
// CHECK-NEXT: 20380 00020000 00000000 c0010200 00000004

// RELS: Relocations [
// RELS-NEXT:  Section (5) .rela.dyn {

// SYMS-NEXT:    0x20380 R_MORELLO_RELATIVE bar 0x100BC
// SYMS: Name: bar (18)
// SYMS-NEXT: Value: 0x102BC
