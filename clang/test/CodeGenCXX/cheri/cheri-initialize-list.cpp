// NOTE: Assertions have been autogenerated by utils/update_cc_test_checks.py
// RUN: %cheri_purecap_cc1 -emit-llvm -std=c++11 -o - %s | FileCheck %s -check-prefix CHECK
// RUN: %cheri_purecap_cc1 -emit-llvm -std=c++11 -DMAYBE_STATIC=static -o - %s | FileCheck %s -check-prefix STATIC
namespace std
{

template<class _Ep>
class initializer_list
{
  const _Ep* __begin_;
  unsigned long    __size_;

  initializer_list(const _Ep* __b, unsigned long __s)
      : __begin_(__b),
        __size_(__s)
      {}
};


}

extern int foo(std::initializer_list<int>& l);

#ifndef MAYBE_STATIC
#define MAYBE_STATIC
#endif

// CHECK-LABEL: @main(
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[L1:%.*]] = alloca %"class.std::initializer_list", align {{16|32}}, addrspace(200)
// CHECK-NEXT:    [[REF_TMP:%.*]] = alloca [3 x i32], align 4, addrspace(200)
// CHECK-NEXT:    [[ARRAYINIT_BEGIN:%.*]] = getelementptr inbounds [3 x i32], [3 x i32] addrspace(200)* [[REF_TMP]], i64 0, i64 0
// CHECK-NEXT:    store i32 1, i32 addrspace(200)* [[ARRAYINIT_BEGIN]], align 4
// CHECK-NEXT:    [[ARRAYINIT_ELEMENT:%.*]] = getelementptr inbounds i32, i32 addrspace(200)* [[ARRAYINIT_BEGIN]], i64 1
// CHECK-NEXT:    store i32 2, i32 addrspace(200)* [[ARRAYINIT_ELEMENT]], align 4
// CHECK-NEXT:    [[ARRAYINIT_ELEMENT1:%.*]] = getelementptr inbounds i32, i32 addrspace(200)* [[ARRAYINIT_ELEMENT]], i64 1
// CHECK-NEXT:    store i32 3, i32 addrspace(200)* [[ARRAYINIT_ELEMENT1]], align 4
// CHECK-NEXT:    [[__BEGIN_:%.*]] = getelementptr inbounds %"class.std::initializer_list", %"class.std::initializer_list" addrspace(200)* [[L1]], i32 0, i32 0
// CHECK-NEXT:    [[ARRAYSTART:%.*]] = getelementptr inbounds [3 x i32], [3 x i32] addrspace(200)* [[REF_TMP]], i64 0, i64 0
// CHECK-NEXT:    store i32 addrspace(200)* [[ARRAYSTART]], i32 addrspace(200)* addrspace(200)* [[__BEGIN_]], align {{16|32}}
// CHECK-NEXT:    [[__SIZE_:%.*]] = getelementptr inbounds %"class.std::initializer_list", %"class.std::initializer_list" addrspace(200)* [[L1]], i32 0, i32 1
// CHECK-NEXT:    store i64 3, i64 addrspace(200)* [[__SIZE_]], align {{16|32}}
// CHECK-NEXT:    [[CALL:%.*]] = call signext i32 @_Z3fooU3capRSt16initializer_listIiE(%"class.std::initializer_list" addrspace(200)* dereferenceable({{32|64}}) [[L1]])
// CHECK-NEXT:    ret i32 0


// STATIC: @_ZZ4mainE2l1 = internal addrspace(200) global { i32 addrspace(200)*, i64 } { i32 addrspace(200)* getelementptr inbounds ([3 x i32], [3 x i32] addrspace(200)* @_ZGRZ4mainE2l1_, i32 0, i32 0), i64 3 }, align {{16|32}}
// STATIC: @_ZGRZ4mainE2l1_ = internal addrspace(200) constant [3 x i32] [i32 1, i32 2, i32 3], align 4

// STATIC-LABEL: @main(
// STATIC-NEXT:  entry:
// STATIC-NEXT:    [[CALL:%.*]] = call signext i32 @_Z3fooU3capRSt16initializer_listIiE(%"class.std::initializer_list" addrspace(200)* dereferenceable({{32|64}}) bitcast ({ i32 addrspace(200)*, i64 } addrspace(200)* @_ZZ4mainE2l1 to %"class.std::initializer_list" addrspace(200)*))
// STATIC-NEXT:    ret i32 0
//
int main() {
  MAYBE_STATIC std::initializer_list<int> l1 = {1, 2, 3};
  foo(l1);
}
