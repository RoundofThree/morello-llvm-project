; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --scrub-attributes
; RUN: opt -S -passes=attributor -aa-pipeline='basic-aa' -attributor-disable=false -attributor-max-iterations-verify -attributor-max-iterations=2 < %s | FileCheck %s

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%union.u = type { x86_fp80 }
%struct.s = type { double, i16, i8, [5 x i8] }

@b = internal global %struct.s { double 3.14, i16 9439, i8 25, [5 x i8] undef }, align 16

%struct.Foo = type { i32, i64 }
@a = internal global %struct.Foo { i32 1, i64 2 }, align 8

define void @run() {
; CHECK-LABEL: define {{[^@]+}}@run()
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[A_CAST:%.*]] = bitcast %struct.Foo* @a to i32*
; CHECK-NEXT:    [[TMP0:%.*]] = load i32, i32* [[A_CAST]], align 1
; CHECK-NEXT:    [[A_0_1:%.*]] = getelementptr [[STRUCT_FOO:%.*]], %struct.Foo* @a, i32 0, i32 1
; CHECK-NEXT:    [[TMP1:%.*]] = load i64, i64* [[A_0_1]], align 1
; CHECK-NEXT:    [[TMP2:%.*]] = call i64 @CaptureAStruct(i32 [[TMP0]], i64 [[TMP1]])
; CHECK-NEXT:    unreachable
;
entry:
  tail call i8 @UseLongDoubleUnsafely(%union.u* byval align 16 bitcast (%struct.s* @b to %union.u*))
  tail call x86_fp80 @UseLongDoubleSafely(%union.u* byval align 16 bitcast (%struct.s* @b to %union.u*))
  call i64 @AccessPaddingOfStruct(%struct.Foo* @a)
  call i64 @CaptureAStruct(%struct.Foo* @a)
  ret void
}

define internal i8 @UseLongDoubleUnsafely(%union.u* byval align 16 %arg) {
entry:
  %bitcast = bitcast %union.u* %arg to %struct.s*
  %gep = getelementptr inbounds %struct.s, %struct.s* %bitcast, i64 0, i32 2
  %result = load i8, i8* %gep
  ret i8 %result
}

define internal x86_fp80 @UseLongDoubleSafely(%union.u* byval align 16 %arg) {
  %gep = getelementptr inbounds %union.u, %union.u* %arg, i64 0, i32 0
  %fp80 = load x86_fp80, x86_fp80* %gep
  ret x86_fp80 %fp80
}

define internal i64 @AccessPaddingOfStruct(%struct.Foo* byval %a) {
  %p = bitcast %struct.Foo* %a to i64*
  %v = load i64, i64* %p
  ret i64 %v
}

define internal i64 @CaptureAStruct(%struct.Foo* byval %a) {
; CHECK-LABEL: define {{[^@]+}}@CaptureAStruct
; CHECK-SAME: (i32 [[TMP0:%.*]], i64 [[TMP1:%.*]])
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[A_PRIV:%.*]] = alloca [[STRUCT_FOO:%.*]]
; CHECK-NEXT:    [[A_PRIV_CAST:%.*]] = bitcast %struct.Foo* [[A_PRIV]] to i32*
; CHECK-NEXT:    store i32 [[TMP0]], i32* [[A_PRIV_CAST]]
; CHECK-NEXT:    [[A_PRIV_0_1:%.*]] = getelementptr [[STRUCT_FOO]], %struct.Foo* [[A_PRIV]], i32 0, i32 1
; CHECK-NEXT:    store i64 [[TMP1]], i64* [[A_PRIV_0_1]]
; CHECK-NEXT:    [[A_PTR:%.*]] = alloca %struct.Foo*
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[PHI:%.*]] = phi %struct.Foo* [ null, [[ENTRY:%.*]] ], [ [[GEP:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[TMP2:%.*]] = phi %struct.Foo* [ [[A_PRIV]], [[ENTRY]] ], [ [[TMP2]], [[LOOP]] ]
; CHECK-NEXT:    store %struct.Foo* [[PHI]], %struct.Foo** [[A_PTR]], align 8
; CHECK-NEXT:    [[GEP]] = getelementptr [[STRUCT_FOO]], %struct.Foo* [[A_PRIV]], i64 0
; CHECK-NEXT:    br label [[LOOP]]
;
entry:
  %a_ptr = alloca %struct.Foo*
  br label %loop

loop:
  %phi = phi %struct.Foo* [ null, %entry ], [ %gep, %loop ]
  %0   = phi %struct.Foo* [ %a, %entry ],   [ %0, %loop ]
  store %struct.Foo* %phi, %struct.Foo** %a_ptr
  %gep = getelementptr %struct.Foo, %struct.Foo* %a, i64 0
  br label %loop
}
