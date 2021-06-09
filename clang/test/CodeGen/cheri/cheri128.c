// RUN: %cheri_cc1 -o - -emit-llvm %s | FileCheck -check-prefix=CHECK128 %s
// RUN: %cheri_cc1 -target-cpu cheri256 -cheri-size 256 -o - -emit-llvm %s | FileCheck -check-prefix=CHECK256 %s
// RUN: %clang -target aarch64-none-elf -S -o - -O1 -emit-llvm -march=morello %s | FileCheck -check-prefix=CHECKA64 %s
// RUN: %clang -target aarch64-none-elf -S -o - -O1 -emit-llvm -march=morello+c64 -mabi=purecap %s | FileCheck -check-prefix=CHECKA64-PURE %s

// CHECK128: target datalayout = "E-m:e-pf200:128:128:128:64-i8:8:32-i16:16:32-i64:64-n32:64-S128"
// CHECK256: target datalayout = "E-m:e-pf200:256:256:256:64-i8:8:32-i16:16:32-i64:64-n32:64-S256"
// CHECKA64: target datalayout = "e-m:e-pf200:128:128:128:64-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128"
// CHECKA64-PURE: target datalayout = "e-m:e-pf200:128:128:128:64-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128-A200-P200-G200"

void * __capability array[2];

void * __capability get(int x)
{
	// CHECK128: align 16
	// CHECKA64: align 16
	// CHECK256: align 32
	return array[x];
}

int size(void)
{
	// CHECK128: ret i32 16
	// CHECKA64: ret i32 16
	// CHECK256: ret i32 32
	return sizeof(void* __capability);
}
