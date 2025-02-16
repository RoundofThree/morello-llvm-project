# RUN: llvm-mc -triple=aarch64 -mattr=+morello < %s \
# RUN:     | FileCheck -check-prefix=CHECK-INST %s
# RUN: llvm-mc -filetype=obj -triple=aarch64 -mattr=+morello < %s \
# RUN:     | llvm-readobj -r - | FileCheck -check-prefix=CHECK-RELOC %s

foo:
  nop
  nop
bar:
  ret

.data

# CHECK-INST: .chericap foo-foo
# CHECK-RELOC-NOT: R_MORELLO_CAPINIT
.chericap foo - foo

# CHECK-INST: .chericap foo-bar
# CHECK-RELOC-NOT: R_MORELLO_CAPINIT
.chericap foo - bar

# CHECK-INST: .chericap foo
# CHECK-RELOC: 0x20 R_MORELLO_CAPINIT foo 0x0
.chericap foo

# CHECK-INST: .chericap foo+4
# CHECK-RELOC: 0x30 R_MORELLO_CAPINIT foo 0x4
.chericap foo + 4

# CHECK-INST: .chericap foo+(bar-foo)
# CHECK-RELOC: 0x40 R_MORELLO_CAPINIT foo 0x8
.chericap foo + (bar - foo)

# CHECK-INST: .chericap foo@code
# CHECK-RELOC: 0x50 R_MORELLO_CODE_CAPINIT foo 0x0
.chericap foo@code

# CHECK-INST: .chericap foo@code+4
# CHECK-RELOC: 0x60 R_MORELLO_CODE_CAPINIT foo 0x4
.chericap foo@code + 4

# CHECK-INST: .chericap foo@code+(bar-foo)
# CHECK-RELOC: 0x70 R_MORELLO_CODE_CAPINIT foo 0x8
.chericap foo@code + (bar - foo)
