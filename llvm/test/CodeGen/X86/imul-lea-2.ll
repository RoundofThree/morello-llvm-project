; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown | FileCheck %s


define i64 @t1(i64 %a) nounwind readnone {
; CHECK-LABEL: t1:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    leaq (%rdi,%rdi,8), %rax
; CHECK-NEXT:    leaq (%rax,%rax,8), %rax
; CHECK-NEXT:    retq
entry:
  %0 = mul i64 %a, 81
  ret i64 %0
}

define i64 @t2(i64 %a) nounwind readnone {
; CHECK-LABEL: t2:
; CHECK:       # BB#0: # %entry
; CHECK-NEXT:    shlq $3, %rdi
; CHECK-NEXT:    leaq (%rdi,%rdi,4), %rax
; CHECK-NEXT:    retq
entry:
  %0 = mul i64 %a, 40
  ret i64 %0
}

