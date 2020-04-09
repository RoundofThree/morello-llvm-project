// NOTE: Assertions have been autogenerated by utils/update_cc_test_checks.py
// RUN: %cheri_cc1 -fsyntax-only %s -verify=expected,hybrid -Wcheri-pedantic
// RUN: %cheri_purecap_cc1 -fsyntax-only %s -verify=expected,purecap -Wcheri-pedantic
// RUN: %cheri_cc1 -emit-llvm -O2 %s -o - -DCODEGEN | FileCheck %s

template <typename srcty> long cheri_addr_dep(srcty arg) {
  return (__cheri_addr long)arg;
  // expected-error@-1{{invalid source type 'foo' for __cheri_addr: source must be a capability}}
  // expected-error@-2{{invalid source type 'int' for __cheri_addr: source must be a capability}}
}
template <typename srcty> long cheri_offset_dep(srcty arg) {
  return (__cheri_offset long)arg;
  // expected-error@-1{{invalid source type 'foo' for __cheri_offset: source must be a capability}}
  // expected-error@-2{{invalid source type 'int' for __cheri_offset: source must be a capability}}
}

struct foo {
  int a;
  int b;
};

// CHECK-LABEL: define {{[^@]+}}@_Z17call_good_uintcapu11__uintcap_t
// CHECK-SAME: (i8 addrspace(200)* [[CAP:%.*]]) local_unnamed_addr #0
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.cheri.cap.address.get.i64(i8 addrspace(200)* [[CAP:%.*]]) #3
// CHECK-NEXT:    [[TMP1:%.*]] = tail call i64 @llvm.cheri.cap.offset.get.i64(i8 addrspace(200)* [[CAP]]) #3
// CHECK-NEXT:    [[ADD:%.*]] = add nsw i64 [[TMP1]], [[TMP0]]
// CHECK-NEXT:    ret i64 [[ADD]]
//
long call_good_uintcap(__uintcap_t cap) {
  return cheri_addr_dep(cap) +
    cheri_offset_dep(cap);
}
// CHECK-LABEL: define {{[^@]+}}@_Z13call_good_ptrU12__capabilityPv
// CHECK-SAME: (i8 addrspace(200)* [[CAP:%.*]]) local_unnamed_addr #0
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = tail call i64 @llvm.cheri.cap.address.get.i64(i8 addrspace(200)* [[CAP:%.*]]) #3
// CHECK-NEXT:    [[TMP1:%.*]] = tail call i64 @llvm.cheri.cap.offset.get.i64(i8 addrspace(200)* [[CAP]]) #3
// CHECK-NEXT:    [[ADD:%.*]] = add nsw i64 [[TMP1]], [[TMP0]]
// CHECK-NEXT:    ret i64 [[ADD]]
//
long call_good_ptr(void* __capability cap) {
  return cheri_addr_dep(cap) +
      cheri_offset_dep(cap);
}
#ifndef CODEGEN
long call_bad_struct(struct foo not_cap) {
  return cheri_addr_dep(not_cap) + // expected-note{{in instantiation of function template specialization 'cheri_addr_dep<foo>' requested here}}
      cheri_offset_dep(not_cap); // expected-note{{in instantiation of function template specialization 'cheri_offset_dep<foo>' requested here}}
}
long call_bad_int(int not_cap) {
  return cheri_addr_dep(not_cap) + // expected-note{{in instantiation of function template specialization 'cheri_addr_dep<int>' requested here}}
      cheri_offset_dep(not_cap); // expected-note{{in instantiation of function template specialization 'cheri_offset_dep<int>' requested here}}
}
#endif


template <typename srcty> int* cheri_fromcap_dep(srcty arg) {
  return (__cheri_fromcap int*)arg;
  // expected-error-re@-1{{invalid __cheri_fromcap from 'long * __capability' to unrelated type 'int *{{( __capability)?}}'}}
  // expected-error@-2{{invalid source type 'int' for __cheri_fromcap: source must be a capability}}
  // hybrid-error@-3{{invalid source type 'int *' for __cheri_fromcap: source must be a capability}}
  // purecap-warning@-4{{__cheri_fromcap from 'int * __capability' to 'int * __capability' is a no-op}}
}
template <typename srcty> int* __capability cheri_tocap_dep(srcty arg) {
  return (__cheri_tocap int* __capability)arg;
  // expected-error-re@-1{{invalid __cheri_tocap from 'long *{{( __capability)?}}' to unrelated type 'int * __capability'}}
  // expected-error@-2{{invalid source type 'int' for __cheri_tocap: source must be a pointer}}
  // expected-warning@-3{{__cheri_tocap from 'int * __capability' to 'int * __capability' is a no-op}}
}

// CHECK-LABEL: define {{[^@]+}}@_Z12fromcap_goodU12__capabilityPi
// CHECK-SAME: (i32 addrspace(200)* readnone [[CAP_PTR:%.*]]) local_unnamed_addr #1
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = addrspacecast i32 addrspace(200)* [[CAP_PTR]] to i32*
// CHECK-NEXT:    ret i32* [[TMP0]]
//
int* fromcap_good(int* __capability cap_ptr) {
  return cheri_fromcap_dep(cap_ptr); // purecap-note{{in instantiation of function template specialization 'cheri_fromcap_dep<int * __capability>' requested here}}
}

// CHECK-LABEL: define {{[^@]+}}@_Z10tocap_goodPi
// CHECK-SAME: (i32* readnone [[NOT_CAP_PTR:%.*]]) local_unnamed_addr #1
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[TMP0:%.*]] = addrspacecast i32* [[NOT_CAP_PTR]] to i32 addrspace(200)*
// CHECK-NEXT:    ret i32 addrspace(200)* [[TMP0]]
//
int* __capability tocap_good(int* not_cap_ptr) {
  return cheri_tocap_dep(not_cap_ptr); // purecap-note{{in instantiation of function template specialization 'cheri_tocap_dep<int * __capability>' requested here}}
}
#ifndef CODEGEN
int* fromcap_bad_incompatible_type(long* __capability cap_ptr) {
  return cheri_fromcap_dep(cap_ptr); // expected-note{{in instantiation of function template specialization 'cheri_fromcap_dep<long * __capability>' requested here}}
}
int* fromcap_bad_int(int not_cap) {
  return cheri_fromcap_dep(not_cap); // expected-note{{in instantiation of function template specialization 'cheri_fromcap_dep<int>' requested here}}
}
int* fromcap_bad_not_cap_ptr_hybrid(int* not_cap_ptr) {
  return cheri_fromcap_dep(not_cap_ptr);  // hybrid-note{{in instantiation of function template specialization 'cheri_fromcap_dep<int *>' requested here}}
}

int* __capability tocap_bad_incompatible_type(long* not_cap_ptr) {
  return cheri_tocap_dep(not_cap_ptr); // expected-note-re{{in instantiation of function template specialization 'cheri_tocap_dep<long *{{( __capability)?}}>' requested here}}
}
int* __capability tocap_bad_int(int not_cap) {
  return cheri_tocap_dep(not_cap); // expected-note{{in instantiation of function template specialization 'cheri_tocap_dep<int>' requested here}}
}
int* __capability tocap_bad_not_cap_ptr_hybrid(int* __capability cap_ptr) {
  return cheri_tocap_dep(cap_ptr);  // hybrid-note{{in instantiation of function template specialization 'cheri_tocap_dep<int * __capability>' requested here}}
}
#endif



#ifndef CODEGEN
template <typename T1, typename T2> T1 both_dependent_addr(T2 arg) {
  return (__cheri_addr T1)arg;
  // expected-error@-1{{invalid source type 'foo' for __cheri_addr: source must be a capability}}
  // hybrid-error@-2{{integral pointer type 'char *' is not a valid target type for __cheri_addr: target must be an integer type}}
  // purecap-error@-3{{capability type 'char * __capability' is not a valid target type for __cheri_addr: target must be an integer type}}
}
template <typename T1, typename T2> T1 both_dependent_offset(T2 arg) {
  return (__cheri_offset T1)arg;
  // expected-error@-1{{invalid source type 'foo' for __cheri_offset: source must be a capability}}
  // expected-error-re@-2{{invalid target type 'char *{{( __capability)?}}' for __cheri_offset: target must be an integer type}}
}

template <typename T1, typename T2> T1 both_dependent_fromcap(T2 arg) {
  return (__cheri_fromcap T1)arg;
  // expected-error@-1{{invalid target type 'long' for __cheri_fromcap: target must be a pointer}}
  // expected-error@-2{{invalid source type 'foo' for __cheri_fromcap: source must be a capability}}
}
template <typename T1, typename T2> T1 both_dependent_tocap(T2 arg) {
  return (__cheri_tocap T1)arg;
  // expected-error@-1{{invalid source type 'foo' for __cheri_tocap: source must be a pointer}}
  // expected-error@-2{{invalid target type 'long' for __cheri_tocap: target must be a capability}}
  // hybrid-error@-3{{invalid target type 'char *' for __cheri_tocap: target must be a capability}}
  // purecap-warning@-4{{__cheri_tocap from 'void * __capability' to 'char * __capability' is a no-op}}
}

void both_dependent_offset_instantiate() {
  (void)both_dependent_addr<char*, void* __capability>(0);// expected-note{{requested here}}
  (void)both_dependent_addr<long, foo>({}); // expected-note{{requested here}}

  (void)both_dependent_offset<char*, void* __capability>(0); // expected-note{{requested here}}
  (void)both_dependent_offset<long, foo>({}); // expected-note{{requested here}}

  (void)both_dependent_fromcap<long, void* __capability>(0);// expected-note{{requested here}}
  (void)both_dependent_fromcap<char*, foo>({}); // expected-note{{requested here}}

  (void)both_dependent_tocap<char*, void* __capability>(0); // expected-note{{requested here}}
  (void)both_dependent_tocap<long, foo>({}); // expected-note{{requested here}}
  (void)both_dependent_tocap<long, char*>({}); // expected-note{{requested here}}
}

#endif
