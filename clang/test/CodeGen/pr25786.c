// RUN: %clang_cc1 -triple x86_64-unknown-linux-gnu -emit-llvm -o - %s | FileCheck %s
// RUN: %clang_cc1 -triple i686-unknown-linux-gnu -emit-llvm -o - %s | FileCheck %s --check-prefix=CHECK-OK

void (__attribute__((regparm(3), stdcall)) *pf) ();
void (__attribute__((regparm(2), stdcall)) foo)(int a) {
}
// CHECK: @pf = global void (...)* null
// CHECK: define void @foo(i32 %a)

// CHECK-OK: @pf = global void (...)* null
// CHECK-OK: define x86_stdcallcc void @foo(i32 inreg %a)
