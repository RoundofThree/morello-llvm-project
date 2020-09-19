; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-- -mattr=sse2 | FileCheck %s -check-prefixes=ALL,OPT
; RUN: llc < %s -mtriple=i686-- -mattr=sse2 -O0 | FileCheck %s --check-prefixes=ALL,NOOPT

@x = external global double

define void @foo() nounwind  {
; OPT-LABEL: foo:
; OPT:       # %bb.0:
; OPT-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; OPT-NEXT:    xorps %xmm0, %xmm0
; OPT-NEXT:    movsd %xmm0, x
; OPT-NEXT:    movsd %xmm0, x
; OPT-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; OPT-NEXT:    retl
;
; NOOPT-LABEL: foo:
; NOOPT:       # %bb.0:
; NOOPT-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; NOOPT-NEXT:    xorps %xmm1, %xmm1
; NOOPT-NEXT:    movsd %xmm1, x
; NOOPT-NEXT:    movsd %xmm1, x
; NOOPT-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; NOOPT-NEXT:    retl
  %a = load volatile double, double* @x
  store volatile double 0.0, double* @x
  store volatile double 0.0, double* @x
  %b = load volatile double, double* @x
  ret void
}

define void @bar() nounwind  {
; ALL-LABEL: bar:
; ALL:       # %bb.0:
; ALL-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; ALL-NEXT:    retl
  %c = load volatile double, double* @x
  ret void
}
