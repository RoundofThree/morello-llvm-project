; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown | FileCheck %s

define i32 @mask_negated_zext_bool1(i1 %x) {
; CHECK-LABEL: mask_negated_zext_bool1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl %edi, %eax
; CHECK-NEXT:    andl $1, %eax
; CHECK-NEXT:    retq
  %ext = zext i1 %x to i32
  %neg = sub i32 0, %ext
  %and = and i32 %neg, 1
  ret i32 %and
}

define i32 @mask_negated_zext_bool2(i1 zeroext %x) {
; CHECK-LABEL: mask_negated_zext_bool2:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl %edi, %eax
; CHECK-NEXT:    retq
  %ext = zext i1 %x to i32
  %neg = sub i32 0, %ext
  %and = and i32 %neg, 1
  ret i32 %and
}

define <4 x i32> @mask_negated_zext_bool_vec(<4 x i1> %x) {
; CHECK-LABEL: mask_negated_zext_bool_vec:
; CHECK:       # %bb.0:
; CHECK-NEXT:    andps {{.*}}(%rip), %xmm0
; CHECK-NEXT:    retq
  %ext = zext <4 x i1> %x to <4 x i32>
  %neg = sub <4 x i32> zeroinitializer, %ext
  %and = and <4 x i32> %neg, <i32 1, i32 1, i32 1, i32 1>
  ret <4 x i32> %and
}

define i32 @mask_negated_sext_bool1(i1 %x) {
; CHECK-LABEL: mask_negated_sext_bool1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl %edi, %eax
; CHECK-NEXT:    andl $1, %eax
; CHECK-NEXT:    retq
  %ext = sext i1 %x to i32
  %neg = sub i32 0, %ext
  %and = and i32 %neg, 1
  ret i32 %and
}

define i32 @mask_negated_sext_bool2(i1 zeroext %x) {
; CHECK-LABEL: mask_negated_sext_bool2:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl %edi, %eax
; CHECK-NEXT:    retq
  %ext = sext i1 %x to i32
  %neg = sub i32 0, %ext
  %and = and i32 %neg, 1
  ret i32 %and
}

define <4 x i32> @mask_negated_sext_bool_vec(<4 x i1> %x) {
; CHECK-LABEL: mask_negated_sext_bool_vec:
; CHECK:       # %bb.0:
; CHECK-NEXT:    andps {{.*}}(%rip), %xmm0
; CHECK-NEXT:    retq
  %ext = sext <4 x i1> %x to <4 x i32>
  %neg = sub <4 x i32> zeroinitializer, %ext
  %and = and <4 x i32> %neg, <i32 1, i32 1, i32 1, i32 1>
  ret <4 x i32> %and
}

