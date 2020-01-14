// Test clang diagnositic handler works in IR file compilation.

// REQUIRES: x86-registered-target

// RUN: llvm-profdata merge -o %t1.profdata %S/Inputs/thinlto_expect1.proftext
// RUN: %clang -O2 -fexperimental-new-pass-manager -flto=thin -g -fprofile-use=%t1.profdata -c -o %t1.bo %s
// RUN: llvm-lto -thinlto -o %t %t1.bo
// RUN: %clang -cc1 -O2 -fexperimental-new-pass-manager -x ir %t1.bo -fthinlto-index=%t.thinlto.bc -emit-obj -Rpass-analysis=info 2>&1 | FileCheck %s -check-prefix=CHECK-REMARK
// RUN: llvm-profdata merge -o %t2.profdata %S/Inputs/thinlto_expect2.proftext
// RUN: %clang -cc1 -O2 -fexperimental-new-pass-manager -x ir %t1.bo -fthinlto-index=%t.thinlto.bc -fprofile-instrument-use-path=%t2.profdata -emit-obj -Wmisexpect 2>&1 | FileCheck %s -check-prefix=CHECK-WARNING
// RUN: %clang -cc1 -O2 -fexperimental-new-pass-manager -x ir %t1.bo -fthinlto-index=%t.thinlto.bc -fprofile-instrument-use-path=%t2.profdata -emit-obj 2>&1 | FileCheck %s -allow-empty -check-prefix=CHECK-NOWARNING

int sum;
__attribute__((noinline)) void bar() {
  sum = 1234;
}

__attribute__((noinline)) void foo(int m) {
  if (__builtin_expect(m > 9, 1))
    bar();
}
// CHECK-REMARK: remark: {{.*}}.c:
// CHECK-WARNING: warning: Potential performance regression from use of __builtin_expect(): Annotation was correct on {{.*}}.c:{{[0-9]*}}:26: 50.00% (12 / 24) of profiled executions.
// CHECK-NOWARNING-NOT: warning: {{.*}}.c:{{[0-9]*}}:26: 50.00% (12 / 24)
