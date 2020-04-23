// NOTE: Assertions have been autogenerated by utils/update_cc_test_checks.py
// RUN: %cheri_purecap_cc1 %s -fno-rtti -std=c++11 -o - -emit-llvm | %cheri_FileCheck %s "-implicit-check-not=alloca { i64, i64 }" -check-prefix CHECK
// RUN: %cheri_cc1 %s -target-abi n64 -fno-rtti -std=c++11 -o - -emit-llvm -O2 | %cheri_FileCheck %s -check-prefix N64

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
// CHECK: @virt = addrspace(200) global { i8 addrspace(200)*, i64 } { i8 addrspace(200)* inttoptr (i64 32 to i8 addrspace(200)*), i64 1 }, align [[#CAP_SIZE]]
// CHECK: @nonvirt = addrspace(200) global { i8 addrspace(200)*, i64 } {
// CHECK-SAME: i8 addrspace(200)* bitcast (void () addrspace(200)* @_Z4funcv to i8 addrspace(200)*), i64 1 }, align [[#CAP_SIZE]]

// now the real thing
typedef int (A::* AMemberFuncPtr)();

AMemberFuncPtr global_null_func_ptr = nullptr;
int A::* global_data_ptr = &A::y;
AMemberFuncPtr global_nonvirt_func_ptr = &A::bar;
AMemberFuncPtr global_virt_func_ptr = &A::bar_virtual;
// CHECK: @global_null_func_ptr = addrspace(200) global { i8 addrspace(200)*, i64 } zeroinitializer, align [[#CAP_SIZE]]
// Offet is 20 for 128 and 36 for 256:
// CHECK: @global_data_ptr = addrspace(200) global i64 [[$A_Y_OFFSET:20|36]], align 8
// CHECK: @global_nonvirt_func_ptr = addrspace(200) global { i8 addrspace(200)*, i64 } {
// CHECK-SAME: i8 addrspace(200)* bitcast (i32 (%class.A addrspace(200)*) addrspace(200)* @_ZN1A3barEv to i8 addrspace(200)*), i64 0 }, align [[#CAP_SIZE]]
// CHECK: @global_virt_func_ptr = addrspace(200) global { i8 addrspace(200)*, i64 } { i8 addrspace(200)* inttoptr (i64 [[#CAP_SIZE]] to i8 addrspace(200)*), i64 1 }, align [[#CAP_SIZE]]
// UTC_ARGS: --enable


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
// CHECK-NEXT:    call void @_ZN1AC1Ev(%class.A addrspace(200)* [[A]]) #6
// CHECK-NEXT:    store i64 -1, i64 addrspace(200)* [[NULL_DATA_PTR]], align 8
// CHECK-NEXT:    store i64 16, i64 addrspace(200)* [[DATA_PTR]], align 8
// CHECK-NEXT:    store i64 20, i64 addrspace(200)* [[DATA_PTR_2]], align 8
// CHECK-NEXT:    store { i8 addrspace(200)*, i64 } zeroinitializer, { i8 addrspace(200)*, i64 } addrspace(200)* [[NULL_FUNC_PTR]], align 16
// CHECK-NEXT:    store { i8 addrspace(200)*, i64 } { i8 addrspace(200)* bitcast (i32 (%class.A addrspace(200)*) addrspace(200)* @_ZN1A3fooEv to i8 addrspace(200)*), i64 0 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[FUNC_PTR]], align 16
// CHECK-NEXT:    store { i8 addrspace(200)*, i64 } { i8 addrspace(200)* bitcast (i32 (%class.A addrspace(200)*) addrspace(200)* @_ZN1A3barEv to i8 addrspace(200)*), i64 0 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[FUNC_PTR_2]], align 16
// CHECK-NEXT:    store { i8 addrspace(200)*, i64 } { i8 addrspace(200)* null, i64 1 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[VIRTUAL_FUNC_PTR]], align 16
// CHECK-NEXT:    store { i8 addrspace(200)*, i64 } { i8 addrspace(200)* inttoptr (i64 16 to i8 addrspace(200)*), i64 1 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[VIRTUAL_FUNC_PTR_2]], align 16
// CHECK-NEXT:    [[TMP0:%.*]] = load i64, i64 addrspace(200)* [[DATA_PTR]], align 8
// CHECK-NEXT:    [[TMP1:%.*]] = bitcast [[CLASS_A]] addrspace(200)* [[A]] to i8 addrspace(200)*
// CHECK-NEXT:    [[MEMPTR_OFFSET:%.*]] = getelementptr inbounds i8, i8 addrspace(200)* [[TMP1]], i64 [[TMP0]]
// CHECK-NEXT:    [[TMP2:%.*]] = bitcast i8 addrspace(200)* [[MEMPTR_OFFSET]] to i32 addrspace(200)*
// CHECK-NEXT:    [[TMP3:%.*]] = load i32, i32 addrspace(200)* [[TMP2]], align 4
// CHECK-NEXT:    ret i32 [[TMP3]]
//
// N64-LABEL: define {{[^@]+}}@main() local_unnamed_addr #2
// N64-NEXT:  entry:
// N64-NEXT:    ret i32 3
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
// N64-LABEL: define {{[^@]+}}@_Z19data_ptr_is_nonnullM1Ai
// N64-SAME: (i64 [[PTR:%.*]]) local_unnamed_addr #2
// N64-NEXT:  entry:
// N64-NEXT:    [[MEMPTR_TOBOOL:%.*]] = icmp ne i64 [[PTR]], -1
// N64-NEXT:    ret i1 [[MEMPTR_TOBOOL]]
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
// N64-LABEL: define {{[^@]+}}@_Z16data_ptr_is_nullM1Ai
// N64-SAME: (i64 [[PTR:%.*]]) local_unnamed_addr #2
// N64-NEXT:  entry:
// N64-NEXT:    [[MEMPTR_TOBOOL:%.*]] = icmp eq i64 [[PTR]], -1
// N64-NEXT:    ret i1 [[MEMPTR_TOBOOL]]
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
// N64-LABEL: define {{[^@]+}}@_Z14data_ptr_equalM1AiS0_
// N64-SAME: (i64 [[PTR1:%.*]], i64 [[PTR2:%.*]]) local_unnamed_addr #2
// N64-NEXT:  entry:
// N64-NEXT:    [[TMP0:%.*]] = icmp eq i64 [[PTR1]], [[PTR2]]
// N64-NEXT:    ret i1 [[TMP0]]
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
// N64-LABEL: define {{[^@]+}}@_Z18data_ptr_not_equalM1AiS0_
// N64-SAME: (i64 [[PTR1:%.*]], i64 [[PTR2:%.*]]) local_unnamed_addr #2
// N64-NEXT:  entry:
// N64-NEXT:    [[TMP0:%.*]] = icmp ne i64 [[PTR1]], [[PTR2]]
// N64-NEXT:    ret i1 [[TMP0]]
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
// N64-LABEL: define {{[^@]+}}@_Z19data_ptr_derefereceP1AMS_i
// N64-SAME: (%class.A* nocapture readonly [[A:%.*]], i64 [[PTR:%.*]]) local_unnamed_addr #3
// N64-NEXT:  entry:
// N64-NEXT:    [[TMP0:%.*]] = bitcast %class.A* [[A]] to i8*
// N64-NEXT:    [[MEMPTR_OFFSET:%.*]] = getelementptr inbounds i8, i8* [[TMP0]], i64 [[PTR]]
// N64-NEXT:    [[TMP1:%.*]] = bitcast i8* [[MEMPTR_OFFSET]] to i32*
// N64-NEXT:    [[TMP2:%.*]] = load i32, i32* [[TMP1]], align 4, !tbaa !2
// N64-NEXT:    ret i32 [[TMP2]]
//
int data_ptr_dereferece(A* a, int A::* ptr) {
  return a->*ptr;
}

// TODO: this could be simplified to test the tag bit of the address instead
// of checking the low bit of the adjustment

// CHECK-LABEL: define {{[^@]+}}@_Z19func_ptr_is_nonnullM1AFivE
// CHECK-SAME: (i8 addrspace(200)* inreg [[PTR_COERCE0:%.*]], i64 inreg [[PTR_COERCE1:%.*]]) addrspace(200) #1
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[PTR:%.*]] = alloca { i8 addrspace(200)*, i64 }, align 16, addrspace(200)
// CHECK-NEXT:    [[PTR_ADDR:%.*]] = alloca { i8 addrspace(200)*, i64 }, align 16, addrspace(200)
// CHECK-NEXT:    [[TMP0:%.*]] = getelementptr inbounds { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR]], i32 0, i32 0
// CHECK-NEXT:    store i8 addrspace(200)* [[PTR_COERCE0]], i8 addrspace(200)* addrspace(200)* [[TMP0]], align 16
// CHECK-NEXT:    [[TMP1:%.*]] = getelementptr inbounds { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR]], i32 0, i32 1
// CHECK-NEXT:    store i64 [[PTR_COERCE1]], i64 addrspace(200)* [[TMP1]], align 16
// CHECK-NEXT:    [[PTR1:%.*]] = load { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR]], align 16
// CHECK-NEXT:    store { i8 addrspace(200)*, i64 } [[PTR1]], { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR_ADDR]], align 16
// CHECK-NEXT:    [[TMP2:%.*]] = load { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR_ADDR]], align 16
// CHECK-NEXT:    [[MEMPTR_PTR:%.*]] = extractvalue { i8 addrspace(200)*, i64 } [[TMP2]], 0
// CHECK-NEXT:    [[MEMPTR_TOBOOL:%.*]] = icmp ne i8 addrspace(200)* [[MEMPTR_PTR]], null
// CHECK-NEXT:    [[MEMPTR_ADJ:%.*]] = extractvalue { i8 addrspace(200)*, i64 } [[TMP2]], 1
// CHECK-NEXT:    [[MEMPTR_VIRTUALBIT:%.*]] = and i64 [[MEMPTR_ADJ]], 1
// CHECK-NEXT:    [[MEMPTR_ISVIRTUAL:%.*]] = icmp ne i64 [[MEMPTR_VIRTUALBIT]], 0
// CHECK-NEXT:    [[MEMPTR_ISNONNULL:%.*]] = or i1 [[MEMPTR_TOBOOL]], [[MEMPTR_ISVIRTUAL]]
// CHECK-NEXT:    ret i1 [[MEMPTR_ISNONNULL]]
//
// N64-LABEL: define {{[^@]+}}@_Z19func_ptr_is_nonnullM1AFivE
// N64-SAME: (i64 inreg [[PTR_COERCE0:%.*]], i64 inreg [[PTR_COERCE1:%.*]]) local_unnamed_addr #2
// N64-NEXT:  entry:
// N64-NEXT:    [[MEMPTR_VIRTUALBIT:%.*]] = and i64 [[PTR_COERCE1]], 1
// N64-NEXT:    [[TMP0:%.*]] = or i64 [[MEMPTR_VIRTUALBIT]], [[PTR_COERCE0]]
// N64-NEXT:    [[TMP1:%.*]] = icmp ne i64 [[TMP0]], 0
// N64-NEXT:    ret i1 [[TMP1]]
//
bool func_ptr_is_nonnull(AMemberFuncPtr ptr) {
  return static_cast<bool>(ptr);

}

// CHECK-LABEL: define {{[^@]+}}@_Z16func_ptr_is_nullM1AFivE
// CHECK-SAME: (i8 addrspace(200)* inreg [[PTR_COERCE0:%.*]], i64 inreg [[PTR_COERCE1:%.*]]) addrspace(200) #1
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[PTR:%.*]] = alloca { i8 addrspace(200)*, i64 }, align 16, addrspace(200)
// CHECK-NEXT:    [[PTR_ADDR:%.*]] = alloca { i8 addrspace(200)*, i64 }, align 16, addrspace(200)
// CHECK-NEXT:    [[TMP0:%.*]] = getelementptr inbounds { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR]], i32 0, i32 0
// CHECK-NEXT:    store i8 addrspace(200)* [[PTR_COERCE0]], i8 addrspace(200)* addrspace(200)* [[TMP0]], align 16
// CHECK-NEXT:    [[TMP1:%.*]] = getelementptr inbounds { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR]], i32 0, i32 1
// CHECK-NEXT:    store i64 [[PTR_COERCE1]], i64 addrspace(200)* [[TMP1]], align 16
// CHECK-NEXT:    [[PTR1:%.*]] = load { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR]], align 16
// CHECK-NEXT:    store { i8 addrspace(200)*, i64 } [[PTR1]], { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR_ADDR]], align 16
// CHECK-NEXT:    [[TMP2:%.*]] = load { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR_ADDR]], align 16
// CHECK-NEXT:    [[MEMPTR_PTR:%.*]] = extractvalue { i8 addrspace(200)*, i64 } [[TMP2]], 0
// CHECK-NEXT:    [[MEMPTR_TOBOOL:%.*]] = icmp ne i8 addrspace(200)* [[MEMPTR_PTR]], null
// CHECK-NEXT:    [[MEMPTR_ADJ:%.*]] = extractvalue { i8 addrspace(200)*, i64 } [[TMP2]], 1
// CHECK-NEXT:    [[MEMPTR_VIRTUALBIT:%.*]] = and i64 [[MEMPTR_ADJ]], 1
// CHECK-NEXT:    [[MEMPTR_ISVIRTUAL:%.*]] = icmp ne i64 [[MEMPTR_VIRTUALBIT]], 0
// CHECK-NEXT:    [[MEMPTR_ISNONNULL:%.*]] = or i1 [[MEMPTR_TOBOOL]], [[MEMPTR_ISVIRTUAL]]
// CHECK-NEXT:    [[LNOT:%.*]] = xor i1 [[MEMPTR_ISNONNULL]], true
// CHECK-NEXT:    ret i1 [[LNOT]]
//
// N64-LABEL: define {{[^@]+}}@_Z16func_ptr_is_nullM1AFivE
// N64-SAME: (i64 inreg [[PTR_COERCE0:%.*]], i64 inreg [[PTR_COERCE1:%.*]]) local_unnamed_addr #2
// N64-NEXT:  entry:
// N64-NEXT:    [[MEMPTR_VIRTUALBIT:%.*]] = and i64 [[PTR_COERCE1]], 1
// N64-NEXT:    [[TMP0:%.*]] = or i64 [[MEMPTR_VIRTUALBIT]], [[PTR_COERCE0]]
// N64-NEXT:    [[TMP1:%.*]] = icmp eq i64 [[TMP0]], 0
// N64-NEXT:    ret i1 [[TMP1]]
//
bool func_ptr_is_null(AMemberFuncPtr ptr) {
  return !ptr;

}

// CHECK-LABEL: define {{[^@]+}}@_Z14func_ptr_equalM1AFivES1_
// CHECK-SAME: (i8 addrspace(200)* inreg [[PTR1_COERCE0:%.*]], i64 inreg [[PTR1_COERCE1:%.*]], i8 addrspace(200)* inreg [[PTR2_COERCE0:%.*]], i64 inreg [[PTR2_COERCE1:%.*]]) addrspace(200) #1
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[PTR1:%.*]] = alloca { i8 addrspace(200)*, i64 }, align 16, addrspace(200)
// CHECK-NEXT:    [[PTR2:%.*]] = alloca { i8 addrspace(200)*, i64 }, align 16, addrspace(200)
// CHECK-NEXT:    [[PTR1_ADDR:%.*]] = alloca { i8 addrspace(200)*, i64 }, align 16, addrspace(200)
// CHECK-NEXT:    [[PTR2_ADDR:%.*]] = alloca { i8 addrspace(200)*, i64 }, align 16, addrspace(200)
// CHECK-NEXT:    [[TMP0:%.*]] = getelementptr inbounds { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR1]], i32 0, i32 0
// CHECK-NEXT:    store i8 addrspace(200)* [[PTR1_COERCE0]], i8 addrspace(200)* addrspace(200)* [[TMP0]], align 16
// CHECK-NEXT:    [[TMP1:%.*]] = getelementptr inbounds { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR1]], i32 0, i32 1
// CHECK-NEXT:    store i64 [[PTR1_COERCE1]], i64 addrspace(200)* [[TMP1]], align 16
// CHECK-NEXT:    [[PTR11:%.*]] = load { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR1]], align 16
// CHECK-NEXT:    [[TMP2:%.*]] = getelementptr inbounds { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR2]], i32 0, i32 0
// CHECK-NEXT:    store i8 addrspace(200)* [[PTR2_COERCE0]], i8 addrspace(200)* addrspace(200)* [[TMP2]], align 16
// CHECK-NEXT:    [[TMP3:%.*]] = getelementptr inbounds { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR2]], i32 0, i32 1
// CHECK-NEXT:    store i64 [[PTR2_COERCE1]], i64 addrspace(200)* [[TMP3]], align 16
// CHECK-NEXT:    [[PTR22:%.*]] = load { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR2]], align 16
// CHECK-NEXT:    store { i8 addrspace(200)*, i64 } [[PTR11]], { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR1_ADDR]], align 16
// CHECK-NEXT:    store { i8 addrspace(200)*, i64 } [[PTR22]], { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR2_ADDR]], align 16
// CHECK-NEXT:    [[TMP4:%.*]] = load { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR1_ADDR]], align 16
// CHECK-NEXT:    [[TMP5:%.*]] = load { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR2_ADDR]], align 16
// CHECK-NEXT:    [[LHS_MEMPTR_PTR:%.*]] = extractvalue { i8 addrspace(200)*, i64 } [[TMP4]], 0
// CHECK-NEXT:    [[RHS_MEMPTR_PTR:%.*]] = extractvalue { i8 addrspace(200)*, i64 } [[TMP5]], 0
// CHECK-NEXT:    [[CMP_PTR:%.*]] = icmp eq i8 addrspace(200)* [[LHS_MEMPTR_PTR]], [[RHS_MEMPTR_PTR]]
// CHECK-NEXT:    [[CMP_PTR_NULL:%.*]] = icmp eq i8 addrspace(200)* [[LHS_MEMPTR_PTR]], null
// CHECK-NEXT:    [[LHS_MEMPTR_ADJ:%.*]] = extractvalue { i8 addrspace(200)*, i64 } [[TMP4]], 1
// CHECK-NEXT:    [[RHS_MEMPTR_ADJ:%.*]] = extractvalue { i8 addrspace(200)*, i64 } [[TMP5]], 1
// CHECK-NEXT:    [[CMP_ADJ:%.*]] = icmp eq i64 [[LHS_MEMPTR_ADJ]], [[RHS_MEMPTR_ADJ]]
// CHECK-NEXT:    [[OR_ADJ:%.*]] = or i64 [[LHS_MEMPTR_ADJ]], [[RHS_MEMPTR_ADJ]]
// CHECK-NEXT:    [[TMP6:%.*]] = and i64 [[OR_ADJ]], 1
// CHECK-NEXT:    [[CMP_OR_ADJ:%.*]] = icmp eq i64 [[TMP6]], 0
// CHECK-NEXT:    [[TMP7:%.*]] = and i1 [[CMP_PTR_NULL]], [[CMP_OR_ADJ]]
// CHECK-NEXT:    [[TMP8:%.*]] = or i1 [[TMP7]], [[CMP_ADJ]]
// CHECK-NEXT:    [[MEMPTR_EQ:%.*]] = and i1 [[CMP_PTR]], [[TMP8]]
// CHECK-NEXT:    ret i1 [[MEMPTR_EQ]]
//
// N64-LABEL: define {{[^@]+}}@_Z14func_ptr_equalM1AFivES1_
// N64-SAME: (i64 inreg [[PTR1_COERCE0:%.*]], i64 inreg [[PTR1_COERCE1:%.*]], i64 inreg [[PTR2_COERCE0:%.*]], i64 inreg [[PTR2_COERCE1:%.*]]) local_unnamed_addr #2
// N64-NEXT:  entry:
// N64-NEXT:    [[CMP_PTR:%.*]] = icmp eq i64 [[PTR1_COERCE0]], [[PTR2_COERCE0]]
// N64-NEXT:    [[CMP_ADJ:%.*]] = icmp eq i64 [[PTR1_COERCE1]], [[PTR2_COERCE1]]
// N64-NEXT:    [[OR_ADJ:%.*]] = or i64 [[PTR2_COERCE1]], [[PTR1_COERCE1]]
// N64-NEXT:    [[TMP0:%.*]] = and i64 [[OR_ADJ]], 1
// N64-NEXT:    [[TMP1:%.*]] = or i64 [[TMP0]], [[PTR1_COERCE0]]
// N64-NEXT:    [[TMP2:%.*]] = icmp eq i64 [[TMP1]], 0
// N64-NEXT:    [[TMP3:%.*]] = or i1 [[CMP_ADJ]], [[TMP2]]
// N64-NEXT:    [[MEMPTR_EQ:%.*]] = and i1 [[CMP_PTR]], [[TMP3]]
// N64-NEXT:    ret i1 [[MEMPTR_EQ]]
//
bool func_ptr_equal(AMemberFuncPtr ptr1, AMemberFuncPtr ptr2) {
  return ptr1 == ptr2;

}

// CHECK-LABEL: define {{[^@]+}}@_Z18func_ptr_not_equalM1AFivES1_
// CHECK-SAME: (i8 addrspace(200)* inreg [[PTR1_COERCE0:%.*]], i64 inreg [[PTR1_COERCE1:%.*]], i8 addrspace(200)* inreg [[PTR2_COERCE0:%.*]], i64 inreg [[PTR2_COERCE1:%.*]]) addrspace(200) #1
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[PTR1:%.*]] = alloca { i8 addrspace(200)*, i64 }, align 16, addrspace(200)
// CHECK-NEXT:    [[PTR2:%.*]] = alloca { i8 addrspace(200)*, i64 }, align 16, addrspace(200)
// CHECK-NEXT:    [[PTR1_ADDR:%.*]] = alloca { i8 addrspace(200)*, i64 }, align 16, addrspace(200)
// CHECK-NEXT:    [[PTR2_ADDR:%.*]] = alloca { i8 addrspace(200)*, i64 }, align 16, addrspace(200)
// CHECK-NEXT:    [[TMP0:%.*]] = getelementptr inbounds { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR1]], i32 0, i32 0
// CHECK-NEXT:    store i8 addrspace(200)* [[PTR1_COERCE0]], i8 addrspace(200)* addrspace(200)* [[TMP0]], align 16
// CHECK-NEXT:    [[TMP1:%.*]] = getelementptr inbounds { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR1]], i32 0, i32 1
// CHECK-NEXT:    store i64 [[PTR1_COERCE1]], i64 addrspace(200)* [[TMP1]], align 16
// CHECK-NEXT:    [[PTR11:%.*]] = load { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR1]], align 16
// CHECK-NEXT:    [[TMP2:%.*]] = getelementptr inbounds { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR2]], i32 0, i32 0
// CHECK-NEXT:    store i8 addrspace(200)* [[PTR2_COERCE0]], i8 addrspace(200)* addrspace(200)* [[TMP2]], align 16
// CHECK-NEXT:    [[TMP3:%.*]] = getelementptr inbounds { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR2]], i32 0, i32 1
// CHECK-NEXT:    store i64 [[PTR2_COERCE1]], i64 addrspace(200)* [[TMP3]], align 16
// CHECK-NEXT:    [[PTR22:%.*]] = load { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR2]], align 16
// CHECK-NEXT:    store { i8 addrspace(200)*, i64 } [[PTR11]], { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR1_ADDR]], align 16
// CHECK-NEXT:    store { i8 addrspace(200)*, i64 } [[PTR22]], { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR2_ADDR]], align 16
// CHECK-NEXT:    [[TMP4:%.*]] = load { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR1_ADDR]], align 16
// CHECK-NEXT:    [[TMP5:%.*]] = load { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR2_ADDR]], align 16
// CHECK-NEXT:    [[LHS_MEMPTR_PTR:%.*]] = extractvalue { i8 addrspace(200)*, i64 } [[TMP4]], 0
// CHECK-NEXT:    [[RHS_MEMPTR_PTR:%.*]] = extractvalue { i8 addrspace(200)*, i64 } [[TMP5]], 0
// CHECK-NEXT:    [[CMP_PTR:%.*]] = icmp ne i8 addrspace(200)* [[LHS_MEMPTR_PTR]], [[RHS_MEMPTR_PTR]]
// CHECK-NEXT:    [[CMP_PTR_NULL:%.*]] = icmp ne i8 addrspace(200)* [[LHS_MEMPTR_PTR]], null
// CHECK-NEXT:    [[LHS_MEMPTR_ADJ:%.*]] = extractvalue { i8 addrspace(200)*, i64 } [[TMP4]], 1
// CHECK-NEXT:    [[RHS_MEMPTR_ADJ:%.*]] = extractvalue { i8 addrspace(200)*, i64 } [[TMP5]], 1
// CHECK-NEXT:    [[CMP_ADJ:%.*]] = icmp ne i64 [[LHS_MEMPTR_ADJ]], [[RHS_MEMPTR_ADJ]]
// CHECK-NEXT:    [[OR_ADJ:%.*]] = or i64 [[LHS_MEMPTR_ADJ]], [[RHS_MEMPTR_ADJ]]
// CHECK-NEXT:    [[TMP6:%.*]] = and i64 [[OR_ADJ]], 1
// CHECK-NEXT:    [[CMP_OR_ADJ:%.*]] = icmp ne i64 [[TMP6]], 0
// CHECK-NEXT:    [[TMP7:%.*]] = or i1 [[CMP_PTR_NULL]], [[CMP_OR_ADJ]]
// CHECK-NEXT:    [[TMP8:%.*]] = and i1 [[TMP7]], [[CMP_ADJ]]
// CHECK-NEXT:    [[MEMPTR_NE:%.*]] = or i1 [[CMP_PTR]], [[TMP8]]
// CHECK-NEXT:    ret i1 [[MEMPTR_NE]]
//
// N64-LABEL: define {{[^@]+}}@_Z18func_ptr_not_equalM1AFivES1_
// N64-SAME: (i64 inreg [[PTR1_COERCE0:%.*]], i64 inreg [[PTR1_COERCE1:%.*]], i64 inreg [[PTR2_COERCE0:%.*]], i64 inreg [[PTR2_COERCE1:%.*]]) local_unnamed_addr #2
// N64-NEXT:  entry:
// N64-NEXT:    [[CMP_PTR:%.*]] = icmp ne i64 [[PTR1_COERCE0]], [[PTR2_COERCE0]]
// N64-NEXT:    [[CMP_ADJ:%.*]] = icmp ne i64 [[PTR1_COERCE1]], [[PTR2_COERCE1]]
// N64-NEXT:    [[OR_ADJ:%.*]] = or i64 [[PTR2_COERCE1]], [[PTR1_COERCE1]]
// N64-NEXT:    [[TMP0:%.*]] = and i64 [[OR_ADJ]], 1
// N64-NEXT:    [[TMP1:%.*]] = or i64 [[TMP0]], [[PTR1_COERCE0]]
// N64-NEXT:    [[TMP2:%.*]] = icmp ne i64 [[TMP1]], 0
// N64-NEXT:    [[TMP3:%.*]] = and i1 [[CMP_ADJ]], [[TMP2]]
// N64-NEXT:    [[MEMPTR_NE:%.*]] = or i1 [[CMP_PTR]], [[TMP3]]
// N64-NEXT:    ret i1 [[MEMPTR_NE]]
//
bool func_ptr_not_equal(AMemberFuncPtr ptr1, AMemberFuncPtr ptr2) {
  return ptr1 != ptr2;

}

// CHECK-LABEL: define {{[^@]+}}@_Z20func_ptr_dereferenceP1AMS_FivE
// CHECK-SAME: (%class.A addrspace(200)* [[A:%.*]], i8 addrspace(200)* inreg [[PTR_COERCE0:%.*]], i64 inreg [[PTR_COERCE1:%.*]]) addrspace(200) #1
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[PTR:%.*]] = alloca { i8 addrspace(200)*, i64 }, align 16, addrspace(200)
// CHECK-NEXT:    [[A_ADDR:%.*]] = alloca [[CLASS_A:%.*]] addrspace(200)*, align 16, addrspace(200)
// CHECK-NEXT:    [[PTR_ADDR:%.*]] = alloca { i8 addrspace(200)*, i64 }, align 16, addrspace(200)
// CHECK-NEXT:    [[TMP0:%.*]] = getelementptr inbounds { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR]], i32 0, i32 0
// CHECK-NEXT:    store i8 addrspace(200)* [[PTR_COERCE0]], i8 addrspace(200)* addrspace(200)* [[TMP0]], align 16
// CHECK-NEXT:    [[TMP1:%.*]] = getelementptr inbounds { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR]], i32 0, i32 1
// CHECK-NEXT:    store i64 [[PTR_COERCE1]], i64 addrspace(200)* [[TMP1]], align 16
// CHECK-NEXT:    [[PTR1:%.*]] = load { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR]], align 16
// CHECK-NEXT:    store [[CLASS_A]] addrspace(200)* [[A]], [[CLASS_A]] addrspace(200)* addrspace(200)* [[A_ADDR]], align 16
// CHECK-NEXT:    store { i8 addrspace(200)*, i64 } [[PTR1]], { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR_ADDR]], align 16
// CHECK-NEXT:    [[TMP2:%.*]] = load [[CLASS_A]] addrspace(200)*, [[CLASS_A]] addrspace(200)* addrspace(200)* [[A_ADDR]], align 16
// CHECK-NEXT:    [[TMP3:%.*]] = load { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR_ADDR]], align 16
// CHECK-NEXT:    [[MEMPTR_ADJ:%.*]] = extractvalue { i8 addrspace(200)*, i64 } [[TMP3]], 1
// CHECK-NEXT:    [[MEMPTR_ADJ_SHIFTED:%.*]] = ashr i64 [[MEMPTR_ADJ]], 1
// CHECK-NEXT:    [[THIS_NOT_ADJUSTED:%.*]] = bitcast [[CLASS_A]] addrspace(200)* [[TMP2]] to i8 addrspace(200)*
// CHECK-NEXT:    [[MEMPTR_VTABLE_ADDR:%.*]] = getelementptr inbounds i8, i8 addrspace(200)* [[THIS_NOT_ADJUSTED]], i64 [[MEMPTR_ADJ_SHIFTED]]
// CHECK-NEXT:    [[THIS_ADJUSTED:%.*]] = bitcast i8 addrspace(200)* [[MEMPTR_VTABLE_ADDR]] to [[CLASS_A]] addrspace(200)*
// CHECK-NEXT:    [[MEMPTR_PTR:%.*]] = extractvalue { i8 addrspace(200)*, i64 } [[TMP3]], 0
// CHECK-NEXT:    [[TMP4:%.*]] = and i64 [[MEMPTR_ADJ]], 1
// CHECK-NEXT:    [[MEMPTR_ISVIRTUAL:%.*]] = icmp ne i64 [[TMP4]], 0
// CHECK-NEXT:    br i1 [[MEMPTR_ISVIRTUAL]], label [[MEMPTR_VIRTUAL:%.*]], label [[MEMPTR_NONVIRTUAL:%.*]]
// CHECK:       memptr.virtual:
// CHECK-NEXT:    [[TMP5:%.*]] = bitcast i8 addrspace(200)* [[MEMPTR_VTABLE_ADDR]] to i8 addrspace(200)* addrspace(200)*
// CHECK-NEXT:    [[VTABLE:%.*]] = load i8 addrspace(200)*, i8 addrspace(200)* addrspace(200)* [[TMP5]], align 16
// CHECK-NEXT:    [[MEMPTR_VTABLE_OFFSET:%.*]] = ptrtoint i8 addrspace(200)* [[MEMPTR_PTR]] to i64
// CHECK-NEXT:    [[TMP6:%.*]] = getelementptr i8, i8 addrspace(200)* [[VTABLE]], i64 [[MEMPTR_VTABLE_OFFSET]], !nosanitize !2
// CHECK-NEXT:    [[TMP7:%.*]] = bitcast i8 addrspace(200)* [[TMP6]] to i32 (%class.A addrspace(200)*) addrspace(200)* addrspace(200)*, !nosanitize !2
// CHECK-NEXT:    [[MEMPTR_VIRTUALFN:%.*]] = load i32 (%class.A addrspace(200)*) addrspace(200)*, i32 (%class.A addrspace(200)*) addrspace(200)* addrspace(200)* [[TMP7]], align 16, !nosanitize !2
// CHECK-NEXT:    br label [[MEMPTR_END:%.*]]
// CHECK:       memptr.nonvirtual:
// CHECK-NEXT:    [[MEMPTR_NONVIRTUALFN:%.*]] = bitcast i8 addrspace(200)* [[MEMPTR_PTR]] to i32 (%class.A addrspace(200)*) addrspace(200)*
// CHECK-NEXT:    br label [[MEMPTR_END]]
// CHECK:       memptr.end:
// CHECK-NEXT:    [[TMP8:%.*]] = phi i32 (%class.A addrspace(200)*) addrspace(200)* [ [[MEMPTR_VIRTUALFN]], [[MEMPTR_VIRTUAL]] ], [ [[MEMPTR_NONVIRTUALFN]], [[MEMPTR_NONVIRTUAL]] ]
// CHECK-NEXT:    [[CALL:%.*]] = call signext i32 [[TMP8]](%class.A addrspace(200)* [[THIS_ADJUSTED]])
// CHECK-NEXT:    ret i32 [[CALL]]
//
// N64-LABEL: define {{[^@]+}}@_Z20func_ptr_dereferenceP1AMS_FivE
// N64-SAME: (%class.A* [[A:%.*]], i64 inreg [[PTR_COERCE0:%.*]], i64 inreg [[PTR_COERCE1:%.*]]) local_unnamed_addr #1
// N64-NEXT:  entry:
// N64-NEXT:    [[MEMPTR_ADJ_SHIFTED:%.*]] = ashr i64 [[PTR_COERCE1]], 1
// N64-NEXT:    [[THIS_NOT_ADJUSTED:%.*]] = bitcast %class.A* [[A]] to i8*
// N64-NEXT:    [[MEMPTR_VTABLE_ADDR:%.*]] = getelementptr inbounds i8, i8* [[THIS_NOT_ADJUSTED]], i64 [[MEMPTR_ADJ_SHIFTED]]
// N64-NEXT:    [[THIS_ADJUSTED:%.*]] = bitcast i8* [[MEMPTR_VTABLE_ADDR]] to %class.A*
// N64-NEXT:    [[TMP0:%.*]] = and i64 [[PTR_COERCE1]], 1
// N64-NEXT:    [[MEMPTR_ISVIRTUAL:%.*]] = icmp eq i64 [[TMP0]], 0
// N64-NEXT:    br i1 [[MEMPTR_ISVIRTUAL]], label [[MEMPTR_NONVIRTUAL:%.*]], label [[MEMPTR_VIRTUAL:%.*]]
// N64:       memptr.virtual:
// N64-NEXT:    [[TMP1:%.*]] = bitcast i8* [[MEMPTR_VTABLE_ADDR]] to i8**
// N64-NEXT:    [[VTABLE:%.*]] = load i8*, i8** [[TMP1]], align 8, !tbaa !6
// N64-NEXT:    [[TMP2:%.*]] = getelementptr i8, i8* [[VTABLE]], i64 [[PTR_COERCE0]], !nosanitize !8
// N64-NEXT:    [[TMP3:%.*]] = bitcast i8* [[TMP2]] to i32 (%class.A*)**, !nosanitize !8
// N64-NEXT:    [[MEMPTR_VIRTUALFN:%.*]] = load i32 (%class.A*)*, i32 (%class.A*)** [[TMP3]], align 8, !nosanitize !8
// N64-NEXT:    br label [[MEMPTR_END:%.*]]
// N64:       memptr.nonvirtual:
// N64-NEXT:    [[MEMPTR_NONVIRTUALFN:%.*]] = inttoptr i64 [[PTR_COERCE0]] to i32 (%class.A*)*
// N64-NEXT:    br label [[MEMPTR_END]]
// N64:       memptr.end:
// N64-NEXT:    [[TMP4:%.*]] = phi i32 (%class.A*)* [ [[MEMPTR_VIRTUALFN]], [[MEMPTR_VIRTUAL]] ], [ [[MEMPTR_NONVIRTUALFN]], [[MEMPTR_NONVIRTUAL]] ]
// N64-NEXT:    [[CALL:%.*]] = tail call signext i32 [[TMP4]](%class.A* [[THIS_ADJUSTED]]) #5
// N64-NEXT:    ret i32 [[CALL]]
//
int func_ptr_dereference(A* a, AMemberFuncPtr ptr) {
  return (a->*ptr)();
}

// Check using Member pointers as return values an parameters
// CHECK-LABEL: define {{[^@]+}}@_Z15return_func_ptrv() addrspace(200) #1
// CHECK-NEXT:  entry:
// CHECK-NEXT:    ret { i8 addrspace(200)*, i64 } { i8 addrspace(200)* inttoptr (i64 16 to i8 addrspace(200)*), i64 1 }
//
// N64-LABEL: define {{[^@]+}}@_Z15return_func_ptrv() local_unnamed_addr #2
// N64-NEXT:  entry:
// N64-NEXT:    ret { i64, i64 } { i64 8, i64 1 }
//
AMemberFuncPtr return_func_ptr() {
  return &A::bar_virtual;
}

// CHECK-LABEL: define {{[^@]+}}@_Z13take_func_ptrM1AFivE
// CHECK-SAME: (i8 addrspace(200)* inreg [[PTR_COERCE0:%.*]], i64 inreg [[PTR_COERCE1:%.*]]) addrspace(200) #1
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[PTR:%.*]] = alloca { i8 addrspace(200)*, i64 }, align 16, addrspace(200)
// CHECK-NEXT:    [[PTR_ADDR:%.*]] = alloca { i8 addrspace(200)*, i64 }, align 16, addrspace(200)
// CHECK-NEXT:    [[TMP0:%.*]] = getelementptr inbounds { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR]], i32 0, i32 0
// CHECK-NEXT:    store i8 addrspace(200)* [[PTR_COERCE0]], i8 addrspace(200)* addrspace(200)* [[TMP0]], align 16
// CHECK-NEXT:    [[TMP1:%.*]] = getelementptr inbounds { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR]], i32 0, i32 1
// CHECK-NEXT:    store i64 [[PTR_COERCE1]], i64 addrspace(200)* [[TMP1]], align 16
// CHECK-NEXT:    [[PTR1:%.*]] = load { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR]], align 16
// CHECK-NEXT:    store { i8 addrspace(200)*, i64 } [[PTR1]], { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR_ADDR]], align 16
// CHECK-NEXT:    ret void
//
// N64-LABEL: define {{[^@]+}}@_Z13take_func_ptrM1AFivE
// N64-SAME: (i64 inreg [[PTR_COERCE0:%.*]], i64 inreg [[PTR_COERCE1:%.*]]) local_unnamed_addr #2
// N64-NEXT:  entry:
// N64-NEXT:    ret void
//
void take_func_ptr(AMemberFuncPtr ptr) {
}

// CHECK-LABEL: define {{[^@]+}}@_Z20passthrough_func_ptrM1AFivE
// CHECK-SAME: (i8 addrspace(200)* inreg [[PTR_COERCE0:%.*]], i64 inreg [[PTR_COERCE1:%.*]]) addrspace(200) #1
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[PTR:%.*]] = alloca { i8 addrspace(200)*, i64 }, align 16, addrspace(200)
// CHECK-NEXT:    [[PTR_ADDR:%.*]] = alloca { i8 addrspace(200)*, i64 }, align 16, addrspace(200)
// CHECK-NEXT:    [[TMP0:%.*]] = getelementptr inbounds { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR]], i32 0, i32 0
// CHECK-NEXT:    store i8 addrspace(200)* [[PTR_COERCE0]], i8 addrspace(200)* addrspace(200)* [[TMP0]], align 16
// CHECK-NEXT:    [[TMP1:%.*]] = getelementptr inbounds { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR]], i32 0, i32 1
// CHECK-NEXT:    store i64 [[PTR_COERCE1]], i64 addrspace(200)* [[TMP1]], align 16
// CHECK-NEXT:    [[PTR1:%.*]] = load { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR]], align 16
// CHECK-NEXT:    store { i8 addrspace(200)*, i64 } [[PTR1]], { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR_ADDR]], align 16
// CHECK-NEXT:    [[TMP2:%.*]] = load { i8 addrspace(200)*, i64 }, { i8 addrspace(200)*, i64 } addrspace(200)* [[PTR_ADDR]], align 16
// CHECK-NEXT:    ret { i8 addrspace(200)*, i64 } [[TMP2]]
//
// N64-LABEL: define {{[^@]+}}@_Z20passthrough_func_ptrM1AFivE
// N64-SAME: (i64 inreg [[PTR_COERCE0:%.*]], i64 inreg [[PTR_COERCE1:%.*]]) local_unnamed_addr #2
// N64-NEXT:  entry:
// N64-NEXT:    [[PTR1_FCA_0_INSERT:%.*]] = insertvalue { i64, i64 } undef, i64 [[PTR_COERCE0]], 0
// N64-NEXT:    [[PTR1_FCA_1_INSERT:%.*]] = insertvalue { i64, i64 } [[PTR1_FCA_0_INSERT]], i64 [[PTR_COERCE1]], 1
// N64-NEXT:    ret { i64, i64 } [[PTR1_FCA_1_INSERT]]
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
// CHECK-NEXT:    call void @_ZN6PR75561AD1Ev(%"struct.PR7556::A" addrspace(200)* [[AGG_TMP_ENSURED]]) #6
// CHECK-NEXT:    [[TMP0:%.*]] = bitcast %"struct.PR7556::B" addrspace(200)* [[AGG_TMP_ENSURED1]] to i8 addrspace(200)*
// CHECK-NEXT:    call void @llvm.memset.p200i8.i64(i8 addrspace(200)* align 4 [[TMP0]], i8 0, i64 4, i1 false)
// CHECK-NEXT:    call void @_ZN6PR75561BD1Ev(%"struct.PR7556::B" addrspace(200)* [[AGG_TMP_ENSURED1]]) #6
// CHECK-NEXT:    [[TMP1:%.*]] = bitcast %"struct.PR7556::C" addrspace(200)* [[AGG_TMP_ENSURED2]] to i8 addrspace(200)*
// CHECK-NEXT:    call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)* align 8 [[TMP1]], i8 addrspace(200)* align 8 bitcast (%"struct.PR7556::C" addrspace(200)* @0 to i8 addrspace(200)*), i64 8, i1 false)
// CHECK-NEXT:    call void @_ZN6PR75561CD1Ev(%"struct.PR7556::C" addrspace(200)* [[AGG_TMP_ENSURED2]]) #6
// CHECK-NEXT:    ret void
//
// N64-LABEL: define {{[^@]+}}@_ZN6PR75563fooEv() local_unnamed_addr #1
// N64-NEXT:  entry:
// N64-NEXT:    [[AGG_TMP_ENSURED:%.*]] = alloca %"struct.PR7556::A", align 1
// N64-NEXT:    [[AGG_TMP_ENSURED1:%.*]] = alloca %"struct.PR7556::B", align 4
// N64-NEXT:    [[AGG_TMP_ENSURED2:%.*]] = alloca %"struct.PR7556::C", align 8
// N64-NEXT:    call void @_ZN6PR75561AD1Ev(%"struct.PR7556::A"* nonnull [[AGG_TMP_ENSURED]]) #5
// N64-NEXT:    [[TMP0:%.*]] = getelementptr inbounds %"struct.PR7556::B", %"struct.PR7556::B"* [[AGG_TMP_ENSURED1]], i64 0, i32 0
// N64-NEXT:    store i32 0, i32* [[TMP0]], align 4
// N64-NEXT:    call void @_ZN6PR75561BD1Ev(%"struct.PR7556::B"* nonnull [[AGG_TMP_ENSURED1]]) #5
// N64-NEXT:    [[TMP1:%.*]] = getelementptr inbounds %"struct.PR7556::C", %"struct.PR7556::C"* [[AGG_TMP_ENSURED2]], i64 0, i32 0
// N64-NEXT:    store i64 -1, i64* [[TMP1]], align 8
// N64-NEXT:    call void @_ZN6PR75561CD1Ev(%"struct.PR7556::C"* nonnull [[AGG_TMP_ENSURED2]]) #5
// N64-NEXT:    ret void
//
  void foo() {
    A();

    // B() is initialized using memset:
    B();

    // C can't be zero-initialized due to pointer to data member:
    C();
  }
}
