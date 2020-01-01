; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i386-apple-macosx10.15.0 -mattr=+cmov | FileCheck %s

@b = global i32 0, align 4
@a = global i64 0, align 8

define double @c() nounwind {
; CHECK-LABEL: c:
; CHECK:       ## %bb.0: ## %entry
; CHECK-NEXT:    pushl %esi
; CHECK-NEXT:    subl $16, %esp
; CHECK-NEXT:    movl _b, %eax
; CHECK-NEXT:    movl %eax, %ecx
; CHECK-NEXT:    sarl $31, %ecx
; CHECK-NEXT:    movl _a+4, %edx
; CHECK-NEXT:    movl _a, %esi
; CHECK-NEXT:    subl %eax, %esi
; CHECK-NEXT:    sbbl %ecx, %edx
; CHECK-NEXT:    setb %al
; CHECK-NEXT:    xorl %ecx, %ecx
; CHECK-NEXT:    testl %edx, %edx
; CHECK-NEXT:    setns %cl
; CHECK-NEXT:    movl %esi, (%esp)
; CHECK-NEXT:    movl %edx, {{[0-9]+}}(%esp)
; CHECK-NEXT:    fildll (%esp)
; CHECK-NEXT:    fadds LCPI0_0(,%ecx,4)
; CHECK-NEXT:    fstpl {{[0-9]+}}(%esp)
; CHECK-NEXT:    fldl {{[0-9]+}}(%esp)
; CHECK-NEXT:    fldz
; CHECK-NEXT:    testb %al, %al
; CHECK-NEXT:    fxch %st(1)
; CHECK-NEXT:    fcmovne %st(1), %st
; CHECK-NEXT:    fstp %st(1)
; CHECK-NEXT:    addl $16, %esp
; CHECK-NEXT:    popl %esi
; CHECK-NEXT:    retl
entry:
  %0 = load i32, i32* @b, align 4
  %conv = sext i32 %0 to i64
  %1 = load i64, i64* @a, align 8
  %cmp = icmp ult i64 %1, %conv
  %sub = sub i64 %1, %conv
  %conv3 = uitofp i64 %sub to double
  %cond = select i1 %cmp, double 0.000000e+00, double %conv3
  ret double %cond
}

