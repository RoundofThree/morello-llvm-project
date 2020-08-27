// RUN: %cheri_purecap_cc1 %s -O0 -msoft-float -emit-llvm -o - | FileCheck -check-prefix=CHECK-CHERI %s
// RUN: %clang -target aarch64-none-linux-gnu -march=morello+c64 -mabi=purecap %s -O0 -S -emit-llvm -o - | FileCheck -check-prefix=CHECK-AARCH64 %s
// Ensure literals don't spontaneously switch address space during calls when
// using the pure capability ABI. A regression test for #5.

char takes_string_ptr(const char *a) {
    return a[0];
}

// CHECK-LABEL: main
int main(void) {
  // CHECK-CHERI: call signext i8 @takes_string_ptr(i8 addrspace(200)* getelementptr inbounds ([3 x i8], [3 x i8] addrspace(200)* @.str, i64 0, i64 0))
  // CHECK-AARCH64: call i8 @takes_string_ptr(i8 addrspace(200)* getelementptr inbounds ([3 x i8], [3 x i8] addrspace(200)* @.str, i64 0, i64 0))
  return takes_string_ptr("hi");
}
