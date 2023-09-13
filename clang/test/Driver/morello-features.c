// Test that target features selected on morello.

// RUN: %clang -target aarch64-none-elf -march=armv8-a+a64c %s -### -o %t.o 2>&1 \
// RUN:   | FileCheck --check-prefix=CHECK-A64C %s

// RUN: %clang -target aarch64-none-elf -march=morello %s -### -o %t.o 2>&1 \
// RUN:   | FileCheck --check-prefix=CHECK-A64CHYBRID %s

// RUN: %clang -target aarch64-none-elf -march=morello -mabi=aapcs %s -### -o %t.o 2>&1 \
// RUN:   | FileCheck --check-prefix=CHECK-A64CHYBRID %s

// RUN: %clang -target aarch64-none-elf -mcpu=rainier %s -### -o %t.o 2>&1 \
// RUN:   | FileCheck --check-prefix=CHECK-A64CHYBRID %s

// RUN: %clang -target aarch64-none-elf -mcpu=rainier -march=morello+noa64c %s -### -o %t.o 2>&1 \
// RUN:   | FileCheck --check-prefix=CHECK-A64 %s

// RUN: %clang -target aarch64-none-elf -march=morello -mabi=purecap %s -### -o %t.o 2>&1 \
// RUN:   | FileCheck --check-prefix=CHECK-C64PURECAP %s

// RUN: %clang -target aarch64-none-elf -march=morello -m16-cap-regs %s -### -o %t.o 2>&1 \
// RUN:   | FileCheck --check-prefix=CHECK-16CAPREGS %s

// RUN: %clang -target aarch64-none-elf -march=morello+c64 -mabi=purecap %s -### -o %t.o 2>&1 \
// RUN:   | FileCheck --check-prefix=CHECK-C64PURECAP %s

// RUN: %clang -target aarch64-none-elf -march=morello+c64 %s -### -o %t.o 2>&1 \
// RUN:   | FileCheck --check-prefix=CHECK-C64HYBRID %s

// RUN: %clang -target aarch64-none-elf -march=morello+c64 -mabi=aapcs %s -### -o %t.o 2>&1 \
// RUN:   | FileCheck --check-prefix=CHECK-C64HYBRID %s

// RUN: %clang -target aarch64-none-elf -march=morello+c64 -mabi=purecap -m16-cap-regs %s -### -o %t.o 2>&1 \
// RUN:   | FileCheck --check-prefix=CHECK-16CAPREGS %s

// RUN: %clang -target aarch64-none-elf -march=morello+c64 -mabi=purecap %s -### -o %t.o 2>&1 \
// RUN:   | FileCheck --check-prefix=CHECK-32CAPREGS %s

// RUN: %clang -target aarch64-none-elf -march=morello -mabi=purecap-benchmark %s -### -o %t.o 2>&1 \
// RUN:   | FileCheck --check-prefix=CHECK-BENCHMARK %s

// CHECK-A64C-NOT: "-target-abi" "purecap"
// CHECK-A64C: "-target-feature" "+morello"

// CHECK-A64CHYBRID-NOT: "-target-abi" "purecap"
// CHECK-A64CHYBRID-DAG: "-target-feature" "+v8.2a"
// CHECK-A64CHYBRID-DAG: "-target-feature" "+fp-armv8"
// CHECK-A64CHYBRID-DAG: "-target-feature" "+dotprod"
// CHECK-A64CHYBRID-DAG: "-target-feature" "+fullfp16"
// CHECK-A64CHYBRID-DAG: "-target-feature" "+spe"
// CHECK-A64CHYBRID-DAG: "-target-feature" "+ssbs"
// CHECK-A64CHYBRID-DAG: "-target-feature" "+rcpc"
// CHECK-A64CHYBRID-DAG: "-target-feature" "+morello"

// CHECK-A64-NOT: "-target-abi" "purecap"
// CHECK-A64-NOT: "-target-feature" "+morello"
// CHECK-A64-DAG: "-target-feature" "+v8.2a"
// CHECK-A64-DAG: "-target-feature" "+fp-armv8"
// CHECK-A64-DAG: "-target-feature" "+dotprod"
// CHECK-A64-DAG: "-target-feature" "+fullfp16"
// CHECK-A64-DAG: "-target-feature" "+spe"
// CHECK-A64-DAG: "-target-feature" "+ssbs"
// CHECK-A64-DAG: "-target-feature" "+rcpc"

// CHECK-C64PURECAP: "-target-feature" "+v8.2a"
// CHECK-C64PURECAP: "-target-feature" "+fp-armv8"
// CHECK-C64PURECAP: "-target-feature" "+dotprod"
// CHECK-C64PURECAP: "-target-feature" "+fullfp16"
// CHECK-C64PURECAP: "-target-feature" "+spe"
// CHECK-C64PURECAP: "-target-feature" "+ssbs"
// CHECK-C64PURECAP: "-target-feature" "+rcpc"
// CHECK-C64PURECAP: "-target-feature" "+morello"
// CHECK-C64PURECAP: "-target-feature" "+c64"
// CHECK-C64PURECAP: "-target-abi" "purecap"

// CHECK-C64HYBRID: "-target-feature" "+v8.2a"
// CHECK-C64HYBRID: "-target-feature" "+fp-armv8"
// CHECK-C64HYBRID: "-target-feature" "+dotprod"
// CHECK-C64HYBRID: "-target-feature" "+fullfp16"
// CHECK-C64HYBRID: "-target-feature" "+spe"
// CHECK-C64HYBRID: "-target-feature" "+ssbs"
// CHECK-C64HYBRID: "-target-feature" "+rcpc"
// CHECK-C64HYBRID: "-target-feature" "+morello"
// CHECK-C64HYBRID: "-target-feature" "+c64"
// CHECK-C64HYBRID-NOT: "-target-abi" "purecap"

// CHECK-16CAPREGS: "-target-feature" "+morello"
// CHECK-16CAPREGS: "-target-feature" "+use-16-cap-regs"

// CHECK-32CAPREGS-NOT: "use-16-cap-regs"
// CHECK-32CAPREGS: "-target-feature" "+morello"

// CHECK-BENCHMARK: "-target-feature" "+v8.2a"
// CHECK-BENCHMARK: "-target-feature" "+fp-armv8"
// CHECK-BENCHMARK: "-target-feature" "+dotprod"
// CHECK-BENCHMARK: "-target-feature" "+fullfp16"
// CHECK-BENCHMARK: "-target-feature" "+spe"
// CHECK-BENCHMARK: "-target-feature" "+ssbs"
// CHECK-BENCHMARK: "-target-feature" "+rcpc"
// CHECK-BENCHMARK: "-target-feature" "+morello"
// CHECK-BENCHMARK: "-target-feature" "+c64"
// CHECK-BENCHMARK: "-target-abi" "purecap-benchmark"
