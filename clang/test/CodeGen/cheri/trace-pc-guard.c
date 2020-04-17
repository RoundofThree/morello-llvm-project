// NOTE: Assertions have been autogenerated by utils/update_cc_test_checks.py
// REQUIRES: mips-registered-target

// RUN: %cheri_clang -fno-discard-value-names -O2 %s -emit-llvm -S -o - -fsanitize-coverage=trace-pc-guard | FileCheck %s -check-prefix MIPS
// RUN: %cheri_purecap_clang -fno-discard-value-names -O2 %s -S -emit-llvm -o - -fsanitize-coverage=trace-pc-guard | FileCheck %s -check-prefix PURECAP

// Check that we can emit assembly:
// RUN: %cheri_clang -O2 %s -S -o - -fsanitize-coverage=trace-pc-guard
// RUN: %cheri_purecap_clang -O2 %s -S -o /dev/null -fsanitize-coverage=trace-pc-guard

extern char *gets(char *);
extern int puts(const char *);
extern int fail1(void);
extern int fail2(void);

// Check that the globals have the right type

// MIPS: @__sancov_lowest_stack = external thread_local(initialexec) global i64
// MIPS: @__sancov_gen_ = private global [1 x i32] zeroinitializer, section "__sancov_guards", comdat($main), align 4, !associated !0
// MIPS: @__sancov_gen_.1 = private global [4 x i32] zeroinitializer, section "__sancov_guards", comdat($func2), align 4, !associated !1
// MIPS: @__start___sancov_guards = external hidden global i32*
// MIPS: @__stop___sancov_guards = external hidden global i32*
// MIPS: @llvm.global_ctors = appending global [1 x { i32, void ()*, i8* }] [{ i32, void ()*, i8* } { i32 2, void ()* @sancov.module_ctor_trace_pc_guard, i8* bitcast (void ()* @sancov.module_ctor_trace_pc_guard to i8*) }]
// MIPS: @llvm.compiler.used = appending global [2 x i8*] [i8* bitcast ([1 x i32]* @__sancov_gen_ to i8*), i8* bitcast ([4 x i32]* @__sancov_gen_.1 to i8*)], section "llvm.metadata"

// These should all be in AS200:
// PURECAP: @__sancov_lowest_stack = external thread_local(initialexec) addrspace(200) global i64
// PURECAP: @__sancov_gen_ = private addrspace(200) global [1 x i32] zeroinitializer, section "__sancov_guards", comdat($main), align 4, !associated !0
// PURECAP: @__sancov_gen_.1 = private addrspace(200) global [4 x i32] zeroinitializer, section "__sancov_guards", comdat($func2), align 4, !associated !1
// PURECAP: @__start___sancov_guards = external hidden addrspace(200) global i32 addrspace(200)*
// PURECAP: @__stop___sancov_guards = external hidden addrspace(200) global i32 addrspace(200)*
// PURECAP: @llvm.global_ctors = appending addrspace(200) global [1 x { i32, void () addrspace(200)*, i8 addrspace(200)* }] [{ i32, void () addrspace(200)*, i8 addrspace(200)* } { i32 2, void () addrspace(200)* @sancov.module_ctor_trace_pc_guard, i8 addrspace(200)* bitcast (void () addrspace(200)* @sancov.module_ctor_trace_pc_guard to i8 addrspace(200)*) }]
// PURECAP: @llvm.compiler.used = appending addrspace(200) global [2 x i8*] [i8* addrspacecast (i8 addrspace(200)* bitcast ([1 x i32] addrspace(200)* @__sancov_gen_ to i8 addrspace(200)*) to i8*), i8* addrspacecast (i8 addrspace(200)* bitcast ([4 x i32] addrspace(200)* @__sancov_gen_.1 to i8 addrspace(200)*) to i8*)], section "llvm.metadata"

// PURECAP

// MIPS-LABEL: @main(
// MIPS-NEXT:  entry:
// MIPS-NEXT:    [[FOO:%.*]] = alloca [10 x i8], align 1
// MIPS-NEXT:    call void @__sanitizer_cov_trace_pc_guard(i32* getelementptr inbounds ([1 x i32], [1 x i32]* @__sancov_gen_, i32 0, i64 0))
// MIPS-NEXT:    call void asm sideeffect "", ""()
// MIPS-NEXT:    [[TMP0:%.*]] = getelementptr inbounds [10 x i8], [10 x i8]* [[FOO]], i64 0, i64 0
// MIPS-NEXT:    call void @llvm.lifetime.start.p0i8(i64 10, i8* nonnull [[TMP0]]) #4
// MIPS-NEXT:    [[CALL:%.*]] = call i8* @gets(i8* nonnull [[TMP0]])
// MIPS-NEXT:    [[CALL2:%.*]] = call signext i32 @puts(i8* nonnull [[TMP0]])
// MIPS-NEXT:    call void @llvm.lifetime.end.p0i8(i64 10, i8* nonnull [[TMP0]]) #4
// MIPS-NEXT:    ret i32 0
//
// PURECAP-LABEL: @main(
// PURECAP-NEXT:  entry:
// PURECAP-NEXT:    [[FOO:%.*]] = alloca [10 x i8], align 1, addrspace(200)
// PURECAP-NEXT:    call void @__sanitizer_cov_trace_pc_guard(i32 addrspace(200)* getelementptr inbounds ([1 x i32], [1 x i32] addrspace(200)* @__sancov_gen_, i32 0, i64 0))
// PURECAP-NEXT:    call void asm sideeffect "", ""()
// PURECAP-NEXT:    [[TMP0:%.*]] = getelementptr inbounds [10 x i8], [10 x i8] addrspace(200)* [[FOO]], i64 0, i64 0
// PURECAP-NEXT:    call void @llvm.lifetime.start.p200i8(i64 10, i8 addrspace(200)* nonnull [[TMP0]]) #4
// PURECAP-NEXT:    [[CALL:%.*]] = call i8 addrspace(200)* @gets(i8 addrspace(200)* nonnull [[TMP0]]) #4
// PURECAP-NEXT:    [[CALL2:%.*]] = call signext i32 @puts(i8 addrspace(200)* nonnull [[TMP0]])
// PURECAP-NEXT:    call void @llvm.lifetime.end.p200i8(i64 10, i8 addrspace(200)* nonnull [[TMP0]]) #4
// PURECAP-NEXT:    ret i32 0
//
int main(void) {
  // FIXME: i32* getelementptr inbounds ([1 x i32], [1 x i32]* @__sancov_gen_, i32 0, i32 0)
  char foo[10];
  gets(foo);
  puts(foo);
}

// MIPS-LABEL: @func2(
// MIPS-NEXT:  entry:
// MIPS-NEXT:    call void @__sanitizer_cov_trace_pc_guard(i32* getelementptr inbounds ([4 x i32], [4 x i32]* @__sancov_gen_.1, i32 0, i64 0))
// MIPS-NEXT:    call void asm sideeffect "", ""()
// MIPS-NEXT:    [[CMP:%.*]] = icmp slt i32 [[I:%.*]], 100
// MIPS-NEXT:    br i1 [[CMP]], label [[IF_THEN:%.*]], label [[IF_ELSE:%.*]]
// MIPS:       if.then:
// MIPS-NEXT:    call void @__sanitizer_cov_trace_pc_guard(i32* getelementptr inbounds ([4 x i32], [4 x i32]* @__sancov_gen_.1, i32 0, i64 1))
// MIPS-NEXT:    call void asm sideeffect "", ""()
// MIPS-NEXT:    [[CALL:%.*]] = tail call signext i32 @fail1() #4
// MIPS-NEXT:    br label [[RETURN:%.*]]
// MIPS:       if.else:
// MIPS-NEXT:    [[CMP1:%.*]] = icmp slt i32 [[I]], 200
// MIPS-NEXT:    br i1 [[CMP1]], label [[IF_THEN2:%.*]], label [[IF_END4:%.*]]
// MIPS:       if.then2:
// MIPS-NEXT:    call void @__sanitizer_cov_trace_pc_guard(i32* getelementptr inbounds ([4 x i32], [4 x i32]* @__sancov_gen_.1, i32 0, i64 2))
// MIPS-NEXT:    call void asm sideeffect "", ""()
// MIPS-NEXT:    [[CALL3:%.*]] = tail call signext i32 @fail2() #4
// MIPS-NEXT:    br label [[RETURN]]
// MIPS:       if.end4:
// MIPS-NEXT:    call void @__sanitizer_cov_trace_pc_guard(i32* getelementptr inbounds ([4 x i32], [4 x i32]* @__sancov_gen_.1, i32 0, i64 3))
// MIPS-NEXT:    call void asm sideeffect "", ""()
// MIPS-NEXT:    [[ADD:%.*]] = add nuw nsw i32 [[I]], 1
// MIPS-NEXT:    br label [[RETURN]]
// MIPS:       return:
// MIPS-NEXT:    [[RETVAL_0:%.*]] = phi i32 [ [[CALL]], [[IF_THEN]] ], [ [[CALL3]], [[IF_THEN2]] ], [ [[ADD]], [[IF_END4]] ]
// MIPS-NEXT:    ret i32 [[RETVAL_0]]
//
// PURECAP-LABEL: @func2(
// PURECAP-NEXT:  entry:
// PURECAP-NEXT:    call void @__sanitizer_cov_trace_pc_guard(i32 addrspace(200)* getelementptr inbounds ([4 x i32], [4 x i32] addrspace(200)* @__sancov_gen_.1, i32 0, i64 0))
// PURECAP-NEXT:    call void asm sideeffect "", ""()
// PURECAP-NEXT:    [[CMP:%.*]] = icmp slt i32 [[I:%.*]], 100
// PURECAP-NEXT:    br i1 [[CMP]], label [[IF_THEN:%.*]], label [[IF_ELSE:%.*]]
// PURECAP:       if.then:
// PURECAP-NEXT:    call void @__sanitizer_cov_trace_pc_guard(i32 addrspace(200)* getelementptr inbounds ([4 x i32], [4 x i32] addrspace(200)* @__sancov_gen_.1, i32 0, i64 1))
// PURECAP-NEXT:    call void asm sideeffect "", ""()
// PURECAP-NEXT:    [[CALL:%.*]] = tail call signext i32 @fail1() #4
// PURECAP-NEXT:    br label [[RETURN:%.*]]
// PURECAP:       if.else:
// PURECAP-NEXT:    [[CMP1:%.*]] = icmp slt i32 [[I]], 200
// PURECAP-NEXT:    br i1 [[CMP1]], label [[IF_THEN2:%.*]], label [[IF_END4:%.*]]
// PURECAP:       if.then2:
// PURECAP-NEXT:    call void @__sanitizer_cov_trace_pc_guard(i32 addrspace(200)* getelementptr inbounds ([4 x i32], [4 x i32] addrspace(200)* @__sancov_gen_.1, i32 0, i64 2))
// PURECAP-NEXT:    call void asm sideeffect "", ""()
// PURECAP-NEXT:    [[CALL3:%.*]] = tail call signext i32 @fail2() #4
// PURECAP-NEXT:    br label [[RETURN]]
// PURECAP:       if.end4:
// PURECAP-NEXT:    call void @__sanitizer_cov_trace_pc_guard(i32 addrspace(200)* getelementptr inbounds ([4 x i32], [4 x i32] addrspace(200)* @__sancov_gen_.1, i32 0, i64 3))
// PURECAP-NEXT:    call void asm sideeffect "", ""()
// PURECAP-NEXT:    [[ADD:%.*]] = add nuw nsw i32 [[I]], 1
// PURECAP-NEXT:    br label [[RETURN]]
// PURECAP:       return:
// PURECAP-NEXT:    [[RETVAL_0:%.*]] = phi i32 [ [[CALL]], [[IF_THEN]] ], [ [[CALL3]], [[IF_THEN2]] ], [ [[ADD]], [[IF_END4]] ]
// PURECAP-NEXT:    ret i32 [[RETVAL_0]]
//
int func2(int i) {
  if (i < 100) {
    return fail1();
  } else if (i < 200) {
    return fail2();
  }
  return i + 1;
}


// Check that the trace functions take as200 pointers:
// PURECAP: declare void @__sanitizer_cov_trace_switch(i64, i64 addrspace(200)*) addrspace(200)
// PURECAP: declare void @__sanitizer_cov_trace_pc() addrspace(200)
// PURECAP: declare void @__sanitizer_cov_trace_pc_guard(i32 addrspace(200)*) addrspace(200)
// PURECAP: declare void @__sanitizer_cov_trace_pc_guard_init(i32 addrspace(200)*, i32 addrspace(200)*) addrspace(200)
