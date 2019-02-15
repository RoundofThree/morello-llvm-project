// NOTE: Assertions have been autogenerated by utils/update_cc_test_checks.py
// Check that we can set bounds on addrof expressions
// RUN: %cheri128_purecap_cc1 -cheri-bounds=subobject-safe -O2 -std=c++11 -emit-llvm %s -o - -Wno-array-bounds \
// RUN:   -Wcheri-subobject-bounds -Rcheri-subobject-bounds -verify | FileCheck %s

struct Foo {
  float f;
  int buffer[64];
  int i;
};

extern "C" void call(int *arg);
extern "C" void call_ref(int &i);

// CHECK-LABEL: @test(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[BUFFER:%.*]] = getelementptr inbounds [[STRUCT_FOO:%.*]], [[STRUCT_FOO]] addrspace(200)* [[F:%.*]], i64 0, i32 1
// CHECK-NEXT:    [[TMP0:%.*]] = bitcast [64 x i32] addrspace(200)* [[BUFFER]] to i8 addrspace(200)*
// CHECK-NEXT:    [[TMP1:%.*]] = tail call i8 addrspace(200)* @llvm.cheri.cap.bounds.set(i8 addrspace(200)* nonnull [[TMP0]], i64 256)
// CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds i8, i8 addrspace(200)* [[TMP1]], i64 256
// CHECK-NEXT:    [[TMP2:%.*]] = bitcast i8 addrspace(200)* [[ARRAYIDX]] to i32 addrspace(200)*
// CHECK-NEXT:    tail call void @call(i32 addrspace(200)* nonnull [[TMP2]]) #3
// CHECK-NEXT:    ret void
//
extern "C" void test(struct Foo *f) {
  call(&f->buffer[64]); // expected-remark {{using size of containing type 'int [64]' instead of object type 'int' for subobject bounds on &array[<CONSTANT>]}}
  // expected-remark@-1{{setting sub-object bounds for pointer to 'int' to 256 bytes}}
}
// CHECK-LABEL: @test2(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds [[STRUCT_FOO:%.*]], [[STRUCT_FOO]] addrspace(200)* [[F:%.*]], i64 0, i32 1, i64 64
// CHECK-NEXT:    [[TMP0:%.*]] = bitcast i32 addrspace(200)* [[ARRAYIDX]] to i8 addrspace(200)*
// CHECK-NEXT:    [[TMP1:%.*]] = tail call i8 addrspace(200)* @llvm.cheri.cap.bounds.set(i8 addrspace(200)* nonnull [[TMP0]], i64 4)
// CHECK-NEXT:    [[REF_WITH_BOUNDS:%.*]] = bitcast i8 addrspace(200)* [[TMP1]] to i32 addrspace(200)*
// CHECK-NEXT:    tail call void @call_ref(i32 addrspace(200)* dereferenceable(4) [[REF_WITH_BOUNDS]]) #3
// CHECK-NEXT:    ret void
//
extern "C" void test2(struct Foo *f) {
  call_ref(f->buffer[64]);
  // expected-remark@-1{{setting sub-object bounds for reference to 'int' to 4 bytes}}
}

union U {
  double d;
  int a;
  struct Foo foo;
};

// CHECK-LABEL: @test3(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = bitcast [[UNION_U:%.*]] addrspace(200)* [[U:%.*]] to i8 addrspace(200)*
// CHECK-NEXT:    [[TMP1:%.*]] = tail call i8 addrspace(200)* @llvm.cheri.cap.bounds.set(i8 addrspace(200)* [[TMP0]], i64 264)
// CHECK-NEXT:    [[ADDROF_WITH_BOUNDS:%.*]] = bitcast i8 addrspace(200)* [[TMP1]] to i32 addrspace(200)*
// CHECK-NEXT:    tail call void @call(i32 addrspace(200)* [[ADDROF_WITH_BOUNDS]]) #3
// CHECK-NEXT:    ret void
//
extern "C" void test3(union U *u) {
  call(&u->a); // expected-remark{{using size of containing type 'union U' instead of object type 'int' for subobject bounds on union member}}
  // expected-remark@-1{{setting sub-object bounds for pointer to 'int' to 264 bytes}}
}

// CHECK-LABEL: @test4(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = bitcast [[UNION_U:%.*]] addrspace(200)* [[U:%.*]] to i8 addrspace(200)*
// CHECK-NEXT:    [[TMP1:%.*]] = tail call i8 addrspace(200)* @llvm.cheri.cap.bounds.set(i8 addrspace(200)* [[TMP0]], i64 264)
// CHECK-NEXT:    [[REF_WITH_BOUNDS:%.*]] = bitcast i8 addrspace(200)* [[TMP1]] to i32 addrspace(200)*
// CHECK-NEXT:    tail call void @call_ref(i32 addrspace(200)* dereferenceable(4) [[REF_WITH_BOUNDS]]) #3
// CHECK-NEXT:    ret void
//
extern "C" void test4(union U *u) {
  call_ref(u->a); // expected-remark{{using size of containing type 'union U' instead of object type 'int' for subobject bounds on union member}}
  // expected-remark@-1{{setting sub-object bounds for reference to 'int' to 264 bytes}}
}

struct WithNestedUnion {
  int a;
  int b;
  union U u;
};

// CHECK-LABEL: @test5(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[U:%.*]] = getelementptr inbounds [[STRUCT_WITHNESTEDUNION:%.*]], [[STRUCT_WITHNESTEDUNION]] addrspace(200)* [[W:%.*]], i64 0, i32 2
// CHECK-NEXT:    [[TMP0:%.*]] = bitcast [[UNION_U:%.*]] addrspace(200)* [[U]] to i8 addrspace(200)*
// CHECK-NEXT:    [[TMP1:%.*]] = tail call i8 addrspace(200)* @llvm.cheri.cap.bounds.set(i8 addrspace(200)* nonnull [[TMP0]], i64 264)
// CHECK-NEXT:    [[ADDROF_WITH_BOUNDS:%.*]] = bitcast i8 addrspace(200)* [[TMP1]] to i32 addrspace(200)*
// CHECK-NEXT:    tail call void @call(i32 addrspace(200)* [[ADDROF_WITH_BOUNDS]]) #3
// CHECK-NEXT:    ret void
//
extern "C" void test5(struct WithNestedUnion *w) {
  call(&w->u.a); // expected-remark{{using size of containing type 'union U' instead of object type 'int' for subobject bounds on union member}}
  // expected-remark@-1{{setting sub-object bounds for pointer to 'int' to 264 bytes}}
}

// CHECK-LABEL: @test6(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[U:%.*]] = getelementptr inbounds [[STRUCT_WITHNESTEDUNION:%.*]], [[STRUCT_WITHNESTEDUNION]] addrspace(200)* [[W:%.*]], i64 0, i32 2
// CHECK-NEXT:    [[TMP0:%.*]] = bitcast [[UNION_U:%.*]] addrspace(200)* [[U]] to i8 addrspace(200)*
// CHECK-NEXT:    [[TMP1:%.*]] = tail call i8 addrspace(200)* @llvm.cheri.cap.bounds.set(i8 addrspace(200)* nonnull [[TMP0]], i64 264)
// CHECK-NEXT:    [[REF_WITH_BOUNDS:%.*]] = bitcast i8 addrspace(200)* [[TMP1]] to i32 addrspace(200)*
// CHECK-NEXT:    tail call void @call_ref(i32 addrspace(200)* dereferenceable(4) [[REF_WITH_BOUNDS]]) #3
// CHECK-NEXT:    ret void
//
extern "C" void test6(struct WithNestedUnion *w) {
  call_ref(w->u.a); // expected-remark{{using size of containing type 'union U' instead of object type 'int' for subobject bounds on union member}}
  // expected-remark@-1{{setting sub-object bounds for reference to 'int' to 264 bytes}}
}

// Reduced test case from bin/sh/exec.c (where we were generating the CIncOffset before the CSetBounds)
// This happens because when loading a global the GEP is a ConstantExpr and not a GetElementPointerInst
#define CMDTABLESIZE 31
struct tblentry;
static struct tblentry *cmdtable[CMDTABLESIZE];
extern "C" void do_stuff(void *);

// CHECK-LABEL: @clearcmentry(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i8 addrspace(200)* @llvm.cheri.cap.bounds.set(i8 addrspace(200)* bitcast ([31 x [[STRUCT_TBLENTRY:%.*]] addrspace(200)*] addrspace(200)* @_ZL8cmdtable to i8 addrspace(200)*), i64 496)
// CHECK-NEXT:    [[TMP1:%.*]] = getelementptr inbounds i8, i8 addrspace(200)* [[TMP0]], i64 496
// CHECK-NEXT:    tail call void @do_stuff(i8 addrspace(200)* nonnull [[TMP1]]) #3
// CHECK-NEXT:    ret void
//
extern "C" void clearcmentry() {
  do_stuff(&cmdtable[CMDTABLESIZE]);
  // expected-remark@-1{{using size of containing type 'struct tblentry * __capability [31]' instead of object type 'struct tblentry * __capability' for subobject bounds on &array[<CONSTANT>]}}
  // expected-remark@-2{{setting sub-object bounds for pointer to 'struct tblentry * __capability' to 496 bytes}}
}

// CHECK-LABEL: @clearcmentry2(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i8 addrspace(200)* @llvm.cheri.cap.bounds.set(i8 addrspace(200)* bitcast ([31 x [[STRUCT_TBLENTRY:%.*]] addrspace(200)*] addrspace(200)* @_ZL8cmdtable to i8 addrspace(200)*), i64 496)
// CHECK-NEXT:    tail call void @do_stuff(i8 addrspace(200)* [[TMP0]]) #3
// CHECK-NEXT:    ret void
//
extern "C" void clearcmentry2() {
  do_stuff(&cmdtable[0]);
  // expected-remark@-1{{using size of containing type 'struct tblentry * __capability [31]' instead of object type 'struct tblentry * __capability' for subobject bounds on &array[0]}}
  // expected-remark@-2{{setting sub-object bounds for pointer to 'struct tblentry * __capability' to 496 bytes}}
}

// CHECK-LABEL: @clearcmentry3(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i8 addrspace(200)* @llvm.cheri.cap.bounds.set(i8 addrspace(200)* bitcast ([31 x [[STRUCT_TBLENTRY:%.*]] addrspace(200)*] addrspace(200)* @_ZL8cmdtable to i8 addrspace(200)*), i64 496)
// CHECK-NEXT:    [[TMP1:%.*]] = getelementptr inbounds i8, i8 addrspace(200)* [[TMP0]], i64 16
// CHECK-NEXT:    tail call void @do_stuff(i8 addrspace(200)* nonnull [[TMP1]]) #3
// CHECK-NEXT:    ret void
//
extern "C" void clearcmentry3() {
  do_stuff(&cmdtable[1]);
  // expected-remark@-1{{using size of containing type 'struct tblentry * __capability [31]' instead of object type 'struct tblentry * __capability' for subobject bounds on &array[<CONSTANT>]}}
  // expected-remark@-2{{setting sub-object bounds for pointer to 'struct tblentry * __capability' to 496 bytes}}
}

union U global_u;

// CHECK-LABEL: @same_with_union(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i8 addrspace(200)* @llvm.cheri.cap.bounds.set(i8 addrspace(200)* bitcast (%union.U addrspace(200)* @global_u to i8 addrspace(200)*), i64 264)
// CHECK-NEXT:    [[ADDROF_WITH_BOUNDS:%.*]] = bitcast i8 addrspace(200)* [[TMP0]] to i32 addrspace(200)*
// CHECK-NEXT:    tail call void @call(i32 addrspace(200)* [[ADDROF_WITH_BOUNDS]]) #3
// CHECK-NEXT:    ret void
//
extern "C" void same_with_union() {
  call(&global_u.a);
  // expected-remark@-1{{using size of containing type 'union U' instead of object type 'int' for subobject bounds on union member}}
  // expected-remark@-2{{setting sub-object bounds for pointer to 'int' to 264 bytes}}
}

// CHECK-LABEL: @same_with_union_ref(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i8 addrspace(200)* @llvm.cheri.cap.bounds.set(i8 addrspace(200)* bitcast (%union.U addrspace(200)* @global_u to i8 addrspace(200)*), i64 264)
// CHECK-NEXT:    [[REF_WITH_BOUNDS:%.*]] = bitcast i8 addrspace(200)* [[TMP0]] to i32 addrspace(200)*
// CHECK-NEXT:    tail call void @call_ref(i32 addrspace(200)* dereferenceable(4) [[REF_WITH_BOUNDS]]) #3
// CHECK-NEXT:    ret void
//
extern "C" void same_with_union_ref() {
  call_ref(global_u.a);
  // expected-remark@-1{{using size of containing type 'union U' instead of object type 'int' for subobject bounds on union member}}
  // expected-remark@-2{{setting sub-object bounds for reference to 'int' to 264 bytes}}
}
