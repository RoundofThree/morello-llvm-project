// NOTE: Assertions have been autogenerated by utils/update_cc_test_checks.py
// RUN: %clang %s -fno-rtti -std=c++11 -target aarch64-none-elf -march=morello+c64 -mabi=purecap -o - -emit-llvm -S -fPIC | FileCheck %s
// REQUIRES: asserts

class A {
public:
  int x = 3;
  int y = 4;
  int foo() { return 1; }
  virtual int foo_virtual() { return 2; }
  int bar() { return 1; }
  virtual int bar_virtual() { return 2; }
};

// compare IR with simulated function pointers:
struct mem_fn_ptr {
  void* ptr;
  long offset;
};

// UTC_ARGS: --disable
void func(void);
mem_fn_ptr virt = { (void*)32, 1 };
mem_fn_ptr nonvirt = { (void*)&func, 1 };

// now the real thing
typedef int (A::* AMemberFuncPtr)();

AMemberFuncPtr global_null_func_ptr = nullptr;
int A::* global_data_ptr = &A::y;
AMemberFuncPtr global_nonvirt_func_ptr = &A::bar;
AMemberFuncPtr global_virt_func_ptr = &A::bar_virtual;

// CHECK-LABEL: define {{[^@]+}}@main() addrspace(200) #2
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[RETVAL:%.*]] = alloca i32, align 4, addrspace(200)
// CHECK-NEXT:    [[A:%.*]] = alloca [[CLASS_A:%.*]], align 16, addrspace(200)
// CHECK-NEXT:    [[NULL_DATA_PTR:%.*]] = alloca i64, align 8, addrspace(200)
// CHECK-NEXT:    [[DATA_PTR:%.*]] = alloca i64, align 8, addrspace(200)
// CHECK-NEXT:    [[DATA_PTR_2:%.*]] = alloca i64, align 8, addrspace(200)
// CHECK-NEXT:    [[NULL_FUNC_PTR:%.*]] = alloca { i8 addrspace(200)*, i64 }, align 16, addrspace(200)
// CHECK-NEXT:    [[FUNC_PTR:%.*]] = alloca { i8 addrspace(200)*, i64 }, align 16, addrspace(200)
// CHECK-NEXT:    [[FUNC_PTR_2:%.*]] = alloca { i8 addrspace(200)*, i64 }, align 16, addrspace(200)
// CHECK-NEXT:    [[VIRTUAL_FUNC_PTR:%.*]] = alloca { i8 addrspace(200)*, i64 }, align 16, addrspace(200)
// CHECK-NEXT:    [[VIRTUAL_FUNC_PTR_2:%.*]] = alloca { i8 addrspace(200)*, i64 }, align 16, addrspace(200)
// CHECK-NEXT:    store i32 0, i32 addrspace(200)* [[RETVAL]], align 4
// CHECK-NEXT:    call void @_ZN1AC2Ev(%class.A addrspace(200)* [[A]]) #7
// CHECK-NEXT:    store i64 -1, i64 addrspace(200)* [[NULL_DATA_PTR]], align 8
// CHECK-NEXT:    store i64 16, i64 addrspace(200)* [[DATA_PTR]], align 8
// CHECK-NEXT:    store i64 20, i64 addrspace(200)* [[DATA_PTR_2]], align 8
// CHECK-NEXT:    store { i8 addrspace(200)*, i64 } zeroinitializer, { i8 addrspace(200)*, i64 } addrspace(200)* [[NULL_FUNC_PTR]], align 16
// CHECK-NEXT:    store { i8 addrspace(200)*, i64 } { i8 addrspace(200)* bitcast (i32 (%class.A addrspace(200)*) addrspace(200)* @_ZN1A3fooEv to i8 addrspace(200)*), i64 0 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[FUNC_PTR]], align 16
// CHECK-NEXT:    store { i8 addrspace(200)*, i64 } { i8 addrspace(200)* bitcast (i32 (%class.A addrspace(200)*) addrspace(200)* @_ZN1A3barEv to i8 addrspace(200)*), i64 0 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[FUNC_PTR_2]], align 16
// CHECK-NEXT:    store { i8 addrspace(200)*, i64 } { i8 addrspace(200)* null, i64 1 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[VIRTUAL_FUNC_PTR]], align 16
// CHECK-NEXT:    store { i8 addrspace(200)*, i64 } { i8 addrspace(200)* getelementptr (i8, i8 addrspace(200)* null, i64 16), i64 1 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[VIRTUAL_FUNC_PTR_2]], align 16
// CHECK-NEXT:    [[TMP0:%.*]] = load i64, i64 addrspace(200)* [[DATA_PTR]], align 8
// CHECK-NEXT:    [[TMP1:%.*]] = bitcast [[CLASS_A]] addrspace(200)* [[A]] to i8 addrspace(200)*
// CHECK-NEXT:    [[MEMPTR_OFFSET:%.*]] = getelementptr inbounds i8, i8 addrspace(200)* [[TMP1]], i64 [[TMP0]]
// CHECK-NEXT:    [[TMP2:%.*]] = bitcast i8 addrspace(200)* [[MEMPTR_OFFSET]] to i32 addrspace(200)*
// CHECK-NEXT:    [[TMP3:%.*]] = load i32, i32 addrspace(200)* [[TMP2]], align 4
// CHECK-NEXT:    ret i32 [[TMP3]]
//
int main() {
  A a;
  // FIXME: alignment is wrong
  int A::* null_data_ptr = nullptr;
  int A::* data_ptr = &A::x;
  int A::* data_ptr_2 = &A::y;

  AMemberFuncPtr null_func_ptr = nullptr;

  AMemberFuncPtr func_ptr = &A::foo;
  AMemberFuncPtr func_ptr_2 = &A::bar;
  AMemberFuncPtr virtual_func_ptr = &A::foo_virtual;
  AMemberFuncPtr virtual_func_ptr_2 = &A::bar_virtual;

  // return a.*data_ptr + (a.*func_ptr)() + (a.*virtual_func_ptr)();
  // return null_func_ptr == nullptr;
  return a.*data_ptr;
}

// CHECK-LABEL: define {{[^@]+}}@_Z19data_ptr_is_nonnullM1Ai
// CHECK-SAME: (i64 [[PTR:%.*]]) addrspace(200) #1
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[PTR_ADDR:%.*]] = alloca i64, align 8, addrspace(200)
// CHECK-NEXT:    store i64 [[PTR]], i64 addrspace(200)* [[PTR_ADDR]], align 8
// CHECK-NEXT:    [[TMP0:%.*]] = load i64, i64 addrspace(200)* [[PTR_ADDR]], align 8
// CHECK-NEXT:    [[MEMPTR_TOBOOL:%.*]] = icmp ne i64 [[TMP0]], -1
// CHECK-NEXT:    ret i1 [[MEMPTR_TOBOOL]]
//
bool data_ptr_is_nonnull(int A::* ptr) {
  return static_cast<bool>(ptr);
}

// CHECK-LABEL: define {{[^@]+}}@_Z16data_ptr_is_nullM1Ai
// CHECK-SAME: (i64 [[PTR:%.*]]) addrspace(200) #1
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[PTR_ADDR:%.*]] = alloca i64, align 8, addrspace(200)
// CHECK-NEXT:    store i64 [[PTR]], i64 addrspace(200)* [[PTR_ADDR]], align 8
// CHECK-NEXT:    [[TMP0:%.*]] = load i64, i64 addrspace(200)* [[PTR_ADDR]], align 8
// CHECK-NEXT:    [[MEMPTR_TOBOOL:%.*]] = icmp ne i64 [[TMP0]], -1
// CHECK-NEXT:    [[LNOT:%.*]] = xor i1 [[MEMPTR_TOBOOL]], true
// CHECK-NEXT:    ret i1 [[LNOT]]
//
bool data_ptr_is_null(int A::* ptr) {
  return !ptr;
}

// CHECK-LABEL: define {{[^@]+}}@_Z14data_ptr_equalM1AiS0_
// CHECK-SAME: (i64 [[PTR1:%.*]], i64 [[PTR2:%.*]]) addrspace(200) #1
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[PTR1_ADDR:%.*]] = alloca i64, align 8, addrspace(200)
// CHECK-NEXT:    [[PTR2_ADDR:%.*]] = alloca i64, align 8, addrspace(200)
// CHECK-NEXT:    store i64 [[PTR1]], i64 addrspace(200)* [[PTR1_ADDR]], align 8
// CHECK-NEXT:    store i64 [[PTR2]], i64 addrspace(200)* [[PTR2_ADDR]], align 8
// CHECK-NEXT:    [[TMP0:%.*]] = load i64, i64 addrspace(200)* [[PTR1_ADDR]], align 8
// CHECK-NEXT:    [[TMP1:%.*]] = load i64, i64 addrspace(200)* [[PTR2_ADDR]], align 8
// CHECK-NEXT:    [[TMP2:%.*]] = icmp eq i64 [[TMP0]], [[TMP1]]
// CHECK-NEXT:    ret i1 [[TMP2]]
//
bool data_ptr_equal(int A::* ptr1, int A::* ptr2) {
  return ptr1 == ptr2;
}

// CHECK-LABEL: define {{[^@]+}}@_Z18data_ptr_not_equalM1AiS0_
// CHECK-SAME: (i64 [[PTR1:%.*]], i64 [[PTR2:%.*]]) addrspace(200) #1
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[PTR1_ADDR:%.*]] = alloca i64, align 8, addrspace(200)
// CHECK-NEXT:    [[PTR2_ADDR:%.*]] = alloca i64, align 8, addrspace(200)
// CHECK-NEXT:    store i64 [[PTR1]], i64 addrspace(200)* [[PTR1_ADDR]], align 8
// CHECK-NEXT:    store i64 [[PTR2]], i64 addrspace(200)* [[PTR2_ADDR]], align 8
// CHECK-NEXT:    [[TMP0:%.*]] = load i64, i64 addrspace(200)* [[PTR1_ADDR]], align 8
// CHECK-NEXT:    [[TMP1:%.*]] = load i64, i64 addrspace(200)* [[PTR2_ADDR]], align 8
// CHECK-NEXT:    [[TMP2:%.*]] = icmp ne i64 [[TMP0]], [[TMP1]]
// CHECK-NEXT:    ret i1 [[TMP2]]
//
bool data_ptr_not_equal(int A::* ptr1, int A::* ptr2) {
  return ptr1 != ptr2;
}

// CHECK-LABEL: define {{[^@]+}}@_Z19data_ptr_derefereceP1AMS_i
// CHECK-SAME: (%class.A addrspace(200)* [[A:%.*]], i64 [[PTR:%.*]]) addrspace(200) #1
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[A_ADDR:%.*]] = alloca [[CLASS_A:%.*]] addrspace(200)*, align 16, addrspace(200)
// CHECK-NEXT:    [[PTR_ADDR:%.*]] = alloca i64, align 8, addrspace(200)
// CHECK-NEXT:    store [[CLASS_A]] addrspace(200)* [[A]], [[CLASS_A]] addrspace(200)* addrspace(200)* [[A_ADDR]], align 16
// CHECK-NEXT:    store i64 [[PTR]], i64 addrspace(200)* [[PTR_ADDR]], align 8
// CHECK-NEXT:    [[TMP0:%.*]] = load [[CLASS_A]] addrspace(200)*, [[CLASS_A]] addrspace(200)* addrspace(200)* [[A_ADDR]], align 16
// CHECK-NEXT:    [[TMP1:%.*]] = load i64, i64 addrspace(200)* [[PTR_ADDR]], align 8
// CHECK-NEXT:    [[TMP2:%.*]] = bitcast [[CLASS_A]] addrspace(200)* [[TMP0]] to i8 addrspace(200)*
// CHECK-NEXT:    [[MEMPTR_OFFSET:%.*]] = getelementptr inbounds i8, i8 addrspace(200)* [[TMP2]], i64 [[TMP1]]
// CHECK-NEXT:    [[TMP3:%.*]] = bitcast i8 addrspace(200)* [[MEMPTR_OFFSET]] to i32 addrspace(200)*
// CHECK-NEXT:    [[TMP4:%.*]] = load i32, i32 addrspace(200)* [[TMP3]], align 4
// CHECK-NEXT:    ret i32 [[TMP4]]
//
int data_ptr_dereferece(A* a, int A::* ptr) {
  return a->*ptr;
}

// CHECK-LABEL: define {{[^@]+}}@_Z19func_ptr_is_nonnullM1AFivE
// CHECK-SAME: ({ i8 addrspace(200)*, i64 } [[PTR_COERCE:%.*]]) addrspace(200) #1
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[PTR:%.*]] = alloca { i8 addrspace(200)*, i64 }, align 16, addrspace(200)
// CHECK-NEXT:    [[PTR_ADDR:%.*]] = alloca { i8 addrspace(200)*, i64 }, align 16, addrspace(200)
// CHECK-NEXT:    store { i8 addrspace(200)*, i64 } [[PTR_COERCE]], { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR]], align 16
// CHECK-NEXT:    [[PTR1:%.*]] = load { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR]], align 16
// CHECK-NEXT:    store { i8 addrspace(200)*, i64 } [[PTR1]], { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR_ADDR]], align 16
// CHECK-NEXT:    [[TMP0:%.*]] = load { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR_ADDR]], align 16
// CHECK-NEXT:    [[MEMPTR_PTR:%.*]] = extractvalue { i8 addrspace(200)*, i64 } [[TMP0]], 0
// CHECK-NEXT:    [[MEMPTR_TOBOOL:%.*]] = icmp ne i8 addrspace(200)* [[MEMPTR_PTR]], null
// CHECK-NEXT:    [[MEMPTR_ADJ:%.*]] = extractvalue { i8 addrspace(200)*, i64 } [[TMP0]], 1
// CHECK-NEXT:    [[MEMPTR_VIRTUALBIT:%.*]] = and i64 [[MEMPTR_ADJ]], 1
// CHECK-NEXT:    [[MEMPTR_ISVIRTUAL:%.*]] = icmp ne i64 [[MEMPTR_VIRTUALBIT]], 0
// CHECK-NEXT:    [[MEMPTR_ISNONNULL:%.*]] = or i1 [[MEMPTR_TOBOOL]], [[MEMPTR_ISVIRTUAL]]
// CHECK-NEXT:    ret i1 [[MEMPTR_ISNONNULL]]
//
bool func_ptr_is_nonnull(AMemberFuncPtr ptr) {
  return static_cast<bool>(ptr);

}

// CHECK-LABEL: define {{[^@]+}}@_Z16func_ptr_is_nullM1AFivE
// CHECK-SAME: ({ i8 addrspace(200)*, i64 } [[PTR_COERCE:%.*]]) addrspace(200) #1
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[PTR:%.*]] = alloca { i8 addrspace(200)*, i64 }, align 16, addrspace(200)
// CHECK-NEXT:    [[PTR_ADDR:%.*]] = alloca { i8 addrspace(200)*, i64 }, align 16, addrspace(200)
// CHECK-NEXT:    store { i8 addrspace(200)*, i64 } [[PTR_COERCE]], { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR]], align 16
// CHECK-NEXT:    [[PTR1:%.*]] = load { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR]], align 16
// CHECK-NEXT:    store { i8 addrspace(200)*, i64 } [[PTR1]], { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR_ADDR]], align 16
// CHECK-NEXT:    [[TMP0:%.*]] = load { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR_ADDR]], align 16
// CHECK-NEXT:    [[MEMPTR_PTR:%.*]] = extractvalue { i8 addrspace(200)*, i64 } [[TMP0]], 0
// CHECK-NEXT:    [[MEMPTR_TOBOOL:%.*]] = icmp ne i8 addrspace(200)* [[MEMPTR_PTR]], null
// CHECK-NEXT:    [[MEMPTR_ADJ:%.*]] = extractvalue { i8 addrspace(200)*, i64 } [[TMP0]], 1
// CHECK-NEXT:    [[MEMPTR_VIRTUALBIT:%.*]] = and i64 [[MEMPTR_ADJ]], 1
// CHECK-NEXT:    [[MEMPTR_ISVIRTUAL:%.*]] = icmp ne i64 [[MEMPTR_VIRTUALBIT]], 0
// CHECK-NEXT:    [[MEMPTR_ISNONNULL:%.*]] = or i1 [[MEMPTR_TOBOOL]], [[MEMPTR_ISVIRTUAL]]
// CHECK-NEXT:    [[LNOT:%.*]] = xor i1 [[MEMPTR_ISNONNULL]], true
// CHECK-NEXT:    ret i1 [[LNOT]]
//
bool func_ptr_is_null(AMemberFuncPtr ptr) {
  return !ptr;

}

// CHECK-LABEL: define {{[^@]+}}@_Z14func_ptr_equalM1AFivES1_
// CHECK-SAME: ({ i8 addrspace(200)*, i64 } [[PTR1_COERCE:%.*]], { i8 addrspace(200)*, i64 } [[PTR2_COERCE:%.*]]) addrspace(200) #1
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[PTR1:%.*]] = alloca { i8 addrspace(200)*, i64 }, align 16, addrspace(200)
// CHECK-NEXT:    [[PTR2:%.*]] = alloca { i8 addrspace(200)*, i64 }, align 16, addrspace(200)
// CHECK-NEXT:    [[PTR1_ADDR:%.*]] = alloca { i8 addrspace(200)*, i64 }, align 16, addrspace(200)
// CHECK-NEXT:    [[PTR2_ADDR:%.*]] = alloca { i8 addrspace(200)*, i64 }, align 16, addrspace(200)
// CHECK-NEXT:    store { i8 addrspace(200)*, i64 } [[PTR1_COERCE]], { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR1]], align 16
// CHECK-NEXT:    [[PTR11:%.*]] = load { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR1]], align 16
// CHECK-NEXT:    store { i8 addrspace(200)*, i64 } [[PTR2_COERCE]], { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR2]], align 16
// CHECK-NEXT:    [[PTR22:%.*]] = load { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR2]], align 16
// CHECK-NEXT:    store { i8 addrspace(200)*, i64 } [[PTR11]], { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR1_ADDR]], align 16
// CHECK-NEXT:    store { i8 addrspace(200)*, i64 } [[PTR22]], { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR2_ADDR]], align 16
// CHECK-NEXT:    [[TMP0:%.*]] = load { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR1_ADDR]], align 16
// CHECK-NEXT:    [[TMP1:%.*]] = load { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR2_ADDR]], align 16
// CHECK-NEXT:    [[LHS_MEMPTR_PTR:%.*]] = extractvalue { i8 addrspace(200)*, i64 } [[TMP0]], 0
// CHECK-NEXT:    [[RHS_MEMPTR_PTR:%.*]] = extractvalue { i8 addrspace(200)*, i64 } [[TMP1]], 0
// CHECK-NEXT:    [[CMP_PTR:%.*]] = icmp eq i8 addrspace(200)* [[LHS_MEMPTR_PTR]], [[RHS_MEMPTR_PTR]]
// CHECK-NEXT:    [[CMP_PTR_NULL:%.*]] = icmp eq i8 addrspace(200)* [[LHS_MEMPTR_PTR]], null
// CHECK-NEXT:    [[LHS_MEMPTR_ADJ:%.*]] = extractvalue { i8 addrspace(200)*, i64 } [[TMP0]], 1
// CHECK-NEXT:    [[RHS_MEMPTR_ADJ:%.*]] = extractvalue { i8 addrspace(200)*, i64 } [[TMP1]], 1
// CHECK-NEXT:    [[CMP_ADJ:%.*]] = icmp eq i64 [[LHS_MEMPTR_ADJ]], [[RHS_MEMPTR_ADJ]]
// CHECK-NEXT:    [[OR_ADJ:%.*]] = or i64 [[LHS_MEMPTR_ADJ]], [[RHS_MEMPTR_ADJ]]
// CHECK-NEXT:    [[TMP2:%.*]] = and i64 [[OR_ADJ]], 1
// CHECK-NEXT:    [[CMP_OR_ADJ:%.*]] = icmp eq i64 [[TMP2]], 0
// CHECK-NEXT:    [[TMP3:%.*]] = and i1 [[CMP_PTR_NULL]], [[CMP_OR_ADJ]]
// CHECK-NEXT:    [[TMP4:%.*]] = or i1 [[TMP3]], [[CMP_ADJ]]
// CHECK-NEXT:    [[MEMPTR_EQ:%.*]] = and i1 [[CMP_PTR]], [[TMP4]]
// CHECK-NEXT:    ret i1 [[MEMPTR_EQ]]
//
bool func_ptr_equal(AMemberFuncPtr ptr1, AMemberFuncPtr ptr2) {
  return ptr1 == ptr2;

}

// CHECK-LABEL: define {{[^@]+}}@_Z18func_ptr_not_equalM1AFivES1_
// CHECK-SAME: ({ i8 addrspace(200)*, i64 } [[PTR1_COERCE:%.*]], { i8 addrspace(200)*, i64 } [[PTR2_COERCE:%.*]]) addrspace(200) #1
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[PTR1:%.*]] = alloca { i8 addrspace(200)*, i64 }, align 16, addrspace(200)
// CHECK-NEXT:    [[PTR2:%.*]] = alloca { i8 addrspace(200)*, i64 }, align 16, addrspace(200)
// CHECK-NEXT:    [[PTR1_ADDR:%.*]] = alloca { i8 addrspace(200)*, i64 }, align 16, addrspace(200)
// CHECK-NEXT:    [[PTR2_ADDR:%.*]] = alloca { i8 addrspace(200)*, i64 }, align 16, addrspace(200)
// CHECK-NEXT:    store { i8 addrspace(200)*, i64 } [[PTR1_COERCE]], { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR1]], align 16
// CHECK-NEXT:    [[PTR11:%.*]] = load { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR1]], align 16
// CHECK-NEXT:    store { i8 addrspace(200)*, i64 } [[PTR2_COERCE]], { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR2]], align 16
// CHECK-NEXT:    [[PTR22:%.*]] = load { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR2]], align 16
// CHECK-NEXT:    store { i8 addrspace(200)*, i64 } [[PTR11]], { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR1_ADDR]], align 16
// CHECK-NEXT:    store { i8 addrspace(200)*, i64 } [[PTR22]], { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR2_ADDR]], align 16
// CHECK-NEXT:    [[TMP0:%.*]] = load { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR1_ADDR]], align 16
// CHECK-NEXT:    [[TMP1:%.*]] = load { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR2_ADDR]], align 16
// CHECK-NEXT:    [[LHS_MEMPTR_PTR:%.*]] = extractvalue { i8 addrspace(200)*, i64 } [[TMP0]], 0
// CHECK-NEXT:    [[RHS_MEMPTR_PTR:%.*]] = extractvalue { i8 addrspace(200)*, i64 } [[TMP1]], 0
// CHECK-NEXT:    [[CMP_PTR:%.*]] = icmp ne i8 addrspace(200)* [[LHS_MEMPTR_PTR]], [[RHS_MEMPTR_PTR]]
// CHECK-NEXT:    [[CMP_PTR_NULL:%.*]] = icmp ne i8 addrspace(200)* [[LHS_MEMPTR_PTR]], null
// CHECK-NEXT:    [[LHS_MEMPTR_ADJ:%.*]] = extractvalue { i8 addrspace(200)*, i64 } [[TMP0]], 1
// CHECK-NEXT:    [[RHS_MEMPTR_ADJ:%.*]] = extractvalue { i8 addrspace(200)*, i64 } [[TMP1]], 1
// CHECK-NEXT:    [[CMP_ADJ:%.*]] = icmp ne i64 [[LHS_MEMPTR_ADJ]], [[RHS_MEMPTR_ADJ]]
// CHECK-NEXT:    [[OR_ADJ:%.*]] = or i64 [[LHS_MEMPTR_ADJ]], [[RHS_MEMPTR_ADJ]]
// CHECK-NEXT:    [[TMP2:%.*]] = and i64 [[OR_ADJ]], 1
// CHECK-NEXT:    [[CMP_OR_ADJ:%.*]] = icmp ne i64 [[TMP2]], 0
// CHECK-NEXT:    [[TMP3:%.*]] = or i1 [[CMP_PTR_NULL]], [[CMP_OR_ADJ]]
// CHECK-NEXT:    [[TMP4:%.*]] = and i1 [[TMP3]], [[CMP_ADJ]]
// CHECK-NEXT:    [[MEMPTR_NE:%.*]] = or i1 [[CMP_PTR]], [[TMP4]]
// CHECK-NEXT:    ret i1 [[MEMPTR_NE]]
//
bool func_ptr_not_equal(AMemberFuncPtr ptr1, AMemberFuncPtr ptr2) {
  return ptr1 != ptr2;

}

// CHECK-LABEL: define {{[^@]+}}@_Z20func_ptr_dereferenceP1AMS_FivE
// CHECK-SAME: (%class.A addrspace(200)* [[A:%.*]], { i8 addrspace(200)*, i64 } [[PTR_COERCE:%.*]]) addrspace(200) #3
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[PTR:%.*]] = alloca { i8 addrspace(200)*, i64 }, align 16, addrspace(200)
// CHECK-NEXT:    [[A_ADDR:%.*]] = alloca [[CLASS_A:%.*]] addrspace(200)*, align 16, addrspace(200)
// CHECK-NEXT:    [[PTR_ADDR:%.*]] = alloca { i8 addrspace(200)*, i64 }, align 16, addrspace(200)
// CHECK-NEXT:    store { i8 addrspace(200)*, i64 } [[PTR_COERCE]], { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR]], align 16
// CHECK-NEXT:    [[PTR1:%.*]] = load { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR]], align 16
// CHECK-NEXT:    store [[CLASS_A]] addrspace(200)* [[A]], [[CLASS_A]] addrspace(200)* addrspace(200)* [[A_ADDR]], align 16
// CHECK-NEXT:    store { i8 addrspace(200)*, i64 } [[PTR1]], { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR_ADDR]], align 16
// CHECK-NEXT:    [[TMP0:%.*]] = load [[CLASS_A]] addrspace(200)*, [[CLASS_A]] addrspace(200)* addrspace(200)* [[A_ADDR]], align 16
// CHECK-NEXT:    [[TMP1:%.*]] = load { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR_ADDR]], align 16
// CHECK-NEXT:    [[MEMPTR_ADJ:%.*]] = extractvalue { i8 addrspace(200)*, i64 } [[TMP1]], 1
// CHECK-NEXT:    [[MEMPTR_ADJ_SHIFTED:%.*]] = ashr i64 [[MEMPTR_ADJ]], 1
// CHECK-NEXT:    [[THIS_NOT_ADJUSTED:%.*]] = bitcast [[CLASS_A]] addrspace(200)* [[TMP0]] to i8 addrspace(200)*
// CHECK-NEXT:    [[MEMPTR_VTABLE_ADDR:%.*]] = getelementptr inbounds i8, i8 addrspace(200)* [[THIS_NOT_ADJUSTED]], i64 [[MEMPTR_ADJ_SHIFTED]]
// CHECK-NEXT:    [[THIS_ADJUSTED:%.*]] = bitcast i8 addrspace(200)* [[MEMPTR_VTABLE_ADDR]] to [[CLASS_A]] addrspace(200)*
// CHECK-NEXT:    [[MEMPTR_PTR:%.*]] = extractvalue { i8 addrspace(200)*, i64 } [[TMP1]], 0
// CHECK-NEXT:    [[TMP2:%.*]] = and i64 [[MEMPTR_ADJ]], 1
// CHECK-NEXT:    [[MEMPTR_ISVIRTUAL:%.*]] = icmp ne i64 [[TMP2]], 0
// CHECK-NEXT:    br i1 [[MEMPTR_ISVIRTUAL]], label [[MEMPTR_VIRTUAL:%.*]], label [[MEMPTR_NONVIRTUAL:%.*]]
// CHECK:       memptr.virtual:
// CHECK-NEXT:    [[TMP3:%.*]] = bitcast i8 addrspace(200)* [[MEMPTR_VTABLE_ADDR]] to i8 addrspace(200)* addrspace(200)*
// CHECK-NEXT:    [[VTABLE:%.*]] = load i8 addrspace(200)*, i8 addrspace(200)* addrspace(200)* [[TMP3]], align 16
// CHECK-NEXT:    [[MEMPTR_VTABLE_OFFSET:%.*]] = ptrtoint i8 addrspace(200)* [[MEMPTR_PTR]] to i64
// CHECK-NEXT:    [[TMP4:%.*]] = getelementptr i8, i8 addrspace(200)* [[VTABLE]], i64 [[MEMPTR_VTABLE_OFFSET]], !nosanitize !3
// CHECK-NEXT:    [[TMP5:%.*]] = bitcast i8 addrspace(200)* [[TMP4]] to i32 (%class.A addrspace(200)*) addrspace(200)* addrspace(200)*, !nosanitize !3
// CHECK-NEXT:    [[MEMPTR_VIRTUALFN:%.*]] = load i32 (%class.A addrspace(200)*) addrspace(200)*, i32 (%class.A addrspace(200)*) addrspace(200)* addrspace(200)* [[TMP5]], align 16, !nosanitize !3
// CHECK-NEXT:    br label [[MEMPTR_END:%.*]]
// CHECK:       memptr.nonvirtual:
// CHECK-NEXT:    [[MEMPTR_NONVIRTUALFN:%.*]] = bitcast i8 addrspace(200)* [[MEMPTR_PTR]] to i32 (%class.A addrspace(200)*) addrspace(200)*
// CHECK-NEXT:    br label [[MEMPTR_END]]
// CHECK:       memptr.end:
// CHECK-NEXT:    [[TMP6:%.*]] = phi i32 (%class.A addrspace(200)*) addrspace(200)* [ [[MEMPTR_VIRTUALFN]], [[MEMPTR_VIRTUAL]] ], [ [[MEMPTR_NONVIRTUALFN]], [[MEMPTR_NONVIRTUAL]] ]
// CHECK-NEXT:    [[CALL:%.*]] = call i32 [[TMP6]](%class.A addrspace(200)* [[THIS_ADJUSTED]])
// CHECK-NEXT:    ret i32 [[CALL]]
//
int func_ptr_dereference(A* a, AMemberFuncPtr ptr) {
  return (a->*ptr)();
}

// Check using Member pointers as return values an parameters
// CHECK-LABEL: define {{[^@]+}}@_Z15return_func_ptrv() addrspace(200) #1
// CHECK-NEXT:  entry:
// CHECK-NEXT:    ret { i8 addrspace(200)*, i64 } { i8 addrspace(200)* getelementptr (i8, i8 addrspace(200)* null, i64 16), i64 1 }
//
AMemberFuncPtr return_func_ptr() {
  return &A::bar_virtual;
}

// CHECK-LABEL: define {{[^@]+}}@_Z13take_func_ptrM1AFivE
// CHECK-SAME: ({ i8 addrspace(200)*, i64 } [[PTR_COERCE:%.*]]) addrspace(200) #1
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[PTR:%.*]] = alloca { i8 addrspace(200)*, i64 }, align 16, addrspace(200)
// CHECK-NEXT:    [[PTR_ADDR:%.*]] = alloca { i8 addrspace(200)*, i64 }, align 16, addrspace(200)
// CHECK-NEXT:    store { i8 addrspace(200)*, i64 } [[PTR_COERCE]], { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR]], align 16
// CHECK-NEXT:    [[PTR1:%.*]] = load { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR]], align 16
// CHECK-NEXT:    store { i8 addrspace(200)*, i64 } [[PTR1]], { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR_ADDR]], align 16
// CHECK-NEXT:    ret void
//
void take_func_ptr(AMemberFuncPtr ptr) {
}

// CHECK-LABEL: define {{[^@]+}}@_Z20passthrough_func_ptrM1AFivE
// CHECK-SAME: ({ i8 addrspace(200)*, i64 } [[PTR_COERCE:%.*]]) addrspace(200) #1
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[PTR:%.*]] = alloca { i8 addrspace(200)*, i64 }, align 16, addrspace(200)
// CHECK-NEXT:    [[PTR_ADDR:%.*]] = alloca { i8 addrspace(200)*, i64 }, align 16, addrspace(200)
// CHECK-NEXT:    store { i8 addrspace(200)*, i64 } [[PTR_COERCE]], { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR]], align 16
// CHECK-NEXT:    [[PTR1:%.*]] = load { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR]], align 16
// CHECK-NEXT:    store { i8 addrspace(200)*, i64 } [[PTR1]], { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR_ADDR]], align 16
// CHECK-NEXT:    [[TMP0:%.*]] = load { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR_ADDR]], align 16
// CHECK-NEXT:    ret { i8 addrspace(200)*, i64 } [[TMP0]]
//
AMemberFuncPtr passthrough_func_ptr(AMemberFuncPtr ptr) {
  return ptr;
}

// taken from temporaries.cpp
namespace PR7556 {
  struct A { ~A(); };
  struct B { int i; ~B(); };
  struct C { int C::*pm; ~C(); };
// CHECK-LABEL: define {{[^@]+}}@_ZN6PR75563fooEv() addrspace(200) #1
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[AGG_TMP_ENSURED:%.*]] = alloca %"struct.PR7556::A", align 1, addrspace(200)
// CHECK-NEXT:    [[AGG_TMP_ENSURED1:%.*]] = alloca %"struct.PR7556::B", align 4, addrspace(200)
// CHECK-NEXT:    [[AGG_TMP_ENSURED2:%.*]] = alloca %"struct.PR7556::C", align 8, addrspace(200)
// CHECK-NEXT:    call void @_ZN6PR75561AD1Ev(%"struct.PR7556::A" addrspace(200)* [[AGG_TMP_ENSURED]]) #7
// CHECK-NEXT:    [[TMP0:%.*]] = bitcast %"struct.PR7556::B" addrspace(200)* [[AGG_TMP_ENSURED1]] to i8 addrspace(200)*
// CHECK-NEXT:    call void @llvm.memset.p200i8.i64(i8 addrspace(200)* align 4 [[TMP0]], i8 0, i64 4, i1 false)
// CHECK-NEXT:    call void @_ZN6PR75561BD1Ev(%"struct.PR7556::B" addrspace(200)* [[AGG_TMP_ENSURED1]]) #7
// CHECK-NEXT:    [[TMP1:%.*]] = bitcast %"struct.PR7556::C" addrspace(200)* [[AGG_TMP_ENSURED2]] to i8 addrspace(200)*
// CHECK-NEXT:    call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)* align 8 [[TMP1]], i8 addrspace(200)* align 8 bitcast (%"struct.PR7556::C" addrspace(200)* @0 to i8 addrspace(200)*), i64 8, i1 false)
// CHECK-NEXT:    call void @_ZN6PR75561CD1Ev(%"struct.PR7556::C" addrspace(200)* [[AGG_TMP_ENSURED2]]) #7
// CHECK-NEXT:    ret void
//
  void foo() {
    A();

    // B() is initialized using memset:
    B();

    // C can't be zero-initialized due to pointer to data member:
    C();
  }
}
