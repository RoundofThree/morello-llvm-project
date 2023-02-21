// REQUIRES: aarch64
// RUN: llvm-mc -target-abi purecap --triple=aarch64-none-elf -mattr=+c64,+morello -filetype=obj %S/Inputs/aarch64-abs.s -o %t.o
// RUN: llvm-mc -target-abi purecap --triple=aarch64-none-elf -mattr=+c64,+morello -filetype=obj %s -o %t2.o
// RUN: ld.lld --local-caprelocs=elf %t.o %t2.o -o %t
// RUN: llvm-readobj --sections --relocs --expand-relocs --symbols -x .got -x .data.rel.ro %t | FileCheck %s

/// Check that we can handle capability generating relocations to absolute
/// symbols.
/// FIXME: The linker does not alter the PCC capability depending on the
/// absolute symbol. At the moment it is the responsibility of the developer
/// to give a value in the PCC range.
 .text
 .global _start
 .type _start, %function
 .size _start, 20
_start:
 adrp c0, :got:foo
 ldr c0, [c0, :got_lo12:foo]
 adrp c1, :got:bar
 ldr c1, [c1, :got_lo12:bar]

 .data.rel.ro
 .capinit foo
 .xword 0
 .xword 0

 .capinit bar
 .xword 0
 .xword 0

// CHECK:        Name: .data.rel.ro
// CHECK-NEXT:   Type: SHT_PROGBITS
// CHECK-NEXT:   Flags [
// CHECK-NEXT:     SHF_ALLOC
// CHECK-NEXT:     SHF_WRITE
// CHECK-NEXT:   ]
// CHECK-NEXT:   Address: 0x220230
// CHECK-NEXT:   Offset: 0x230
// CHECK-NEXT:   Size: 32
// CHECK-NEXT:   Link: 0
// CHECK-NEXT:   Info: 0
// CHECK-NEXT:   AddressAlignment: 1
// CHECK-NEXT:   EntrySize: 0
// CHECK-NEXT: }
// CHECK-NEXT: Section {
// CHECK-NEXT:   Index:
// CHECK-NEXT:   Name: .got
// CHECK-NEXT:   Type: SHT_PROGBITS
// CHECK-NEXT:   Flags [
// CHECK-NEXT:     SHF_ALLOC
// CHECK-NEXT:     SHF_WRITE
// CHECK-NEXT:   ]
// CHECK-NEXT:   Address: 0x220250
// CHECK-NEXT:   Offset: 0x250
// CHECK-NEXT:   Size: 48
// CHECK-NEXT:   Link: 0
// CHECK-NEXT:   Info: 0
// CHECK-NEXT:   AddressAlignment: 16
// CHECK-NEXT:   EntrySize: 0
// CHECK-NEXT: }

// CHECK:        .rela.dyn {
// CHECK-NEXT:     Relocation {
// CHECK-NEXT:       Offset: 0x220250
// CHECK-NEXT:       Type: R_MORELLO_RELATIVE
// CHECK-NEXT:       Symbol: - (0)
// CHECK-NEXT:       Addend: 0x17E41
// CHECK-NEXT:     }
// CHECK-NEXT:     Relocation {
// CHECK-NEXT:       Offset: 0x220260
// CHECK-NEXT:       Type: R_MORELLO_RELATIVE
// CHECK-NEXT:       Symbol: - (0)
// CHECK-NEXT:       Addend: 0x0
// CHECK-NEXT:     }
// CHECK-NEXT:     Relocation {
// CHECK-NEXT:       Offset: 0x220230
// CHECK-NEXT:       Type: R_MORELLO_RELATIVE
// CHECK-NEXT:       Symbol: - (0)
// CHECK-NEXT:       Addend: 0x17E41
// CHECK-NEXT:     }
// CHECK-NEXT:     Relocation {
// CHECK-NEXT:       Offset: 0x220240
// CHECK-NEXT:       Type: R_MORELLO_RELATIVE
// CHECK-NEXT:       Symbol: - (0)
// CHECK-NEXT:       Addend: 0x0
// CHECK-NEXT:     }
// CHECK-NEXT:   }
// CHECK-NEXT: ]

// CHECK:          Name: foo
// CHECK-NEXT:     Value: 0x218001
// CHECK-NEXT:     Size: 4
// CHECK-NEXT:     Binding: Global
// CHECK-NEXT:     Type: Function
// CHECK-NEXT:     Other: 0
// CHECK-NEXT:     Section: Absolute
// CHECK-NEXT:   }
// CHECK:          Name: bar
// CHECK-NEXT:     Value: 0x400000
// CHECK-NEXT:     Size: 8
// CHECK-NEXT:     Binding: Global
// CHECK-NEXT:     Type: Object
// CHECK-NEXT:     Other: 0
// CHECK-NEXT:     Section: Absolute
// CHECK-NEXT:   }


// CHECK:      Hex dump of section '.data.rel.ro':
/// foo: address: 0x218001, size = 4, perms = EXEC(0x4)
// CHECK-NEXT: 0x00220230 c0012000 00000000 c0000200 00000004
/// bar: address: 0x400000, size = 8, perms = RW(0x2)
// CHECK-NEXT: 0x00220240 00004000 00000000 08000000 00000002

// CHECK:      Hex dump of section '.got':
/// foo: address: 0x218001, size = 4, perms = EXEC(0x4)
// CHECK-NEXT: 0x00220250 c0012000 00000000 c0000200 00000004
/// bar: address: 0x400000, size = 8, perms = RW(0x2)
// CHECK-NEXT: 0x00220260 00004000 00000000 08000000 00000002
