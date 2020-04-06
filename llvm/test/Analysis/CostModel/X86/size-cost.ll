; NOTE: Assertions have been autogenerated by utils/update_analyze_test_checks.py
; RUN: opt < %s -cost-model -cost-kind=code-size -analyze -mtriple=x86_64-- | FileCheck %s

define i8 @trunc_i64_i8(i64 %x) {
; CHECK-LABEL: 'trunc_i64_i8'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %r = trunc i64 %x to i8
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: ret i8 %r
;
  %r = trunc i64 %x to i8
  ret i8 %r
}

define i64 @sext_i8_i64(i8 %x) {
; CHECK-LABEL: 'sext_i8_i64'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %r = sext i8 %x to i64
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: ret i64 %r
;
  %r = sext i8 %x to i64
  ret i64 %r
}

define i64 @zext_i8_i64(i8 %x) {
; CHECK-LABEL: 'zext_i8_i64'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %r = zext i8 %x to i64
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: ret i64 %r
;
  %r = zext i8 %x to i64
  ret i64 %r
}

define i64 @bitcast_f64_i64(double %x) {
; CHECK-LABEL: 'bitcast_f64_i64'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %r = bitcast double %x to i64
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: ret i64 %r
;
  %r = bitcast double %x to i64
  ret i64 %r
}

define double @bitcast_i64_f64(i64 %x) {
; CHECK-LABEL: 'bitcast_i64_f64'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %r = bitcast i64 %x to double
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: ret double %r
;
  %r = bitcast i64 %x to double
  ret double %r
}

define i64* @inttoptr_i64_p64(i64 %x) {
; CHECK-LABEL: 'inttoptr_i64_p64'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %r = inttoptr i64 %x to i64*
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: ret i64* %r
;
  %r = inttoptr i64 %x to i64*
  ret i64* %r
}

define i64 @ptrtoint_p64_i64(i64* %x) {
; CHECK-LABEL: 'ptrtoint_p64_i64'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %r = ptrtoint i64* %x to i64
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: ret i64 %r
;
  %r = ptrtoint i64* %x to i64
  ret i64 %r
}

define i64 @add_i64(i64 %x, i64 %y) {
; CHECK-LABEL: 'add_i64'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %r = add i64 %x, %y
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: ret i64 %r
;
  %r = add i64 %x, %y
  ret i64 %r
}

define i64 @sub_i64(i64 %x, i64 %y) {
; CHECK-LABEL: 'sub_i64'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %r = sub i64 %x, %y
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: ret i64 %r
;
  %r = sub i64 %x, %y
  ret i64 %r
}

define i64 @mul_i64(i64 %x, i64 %y) {
; CHECK-LABEL: 'mul_i64'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %r = mul i64 %x, %y
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: ret i64 %r
;
  %r = mul i64 %x, %y
  ret i64 %r
}

; FIXME: idiv is 1 instruction.

define i64 @sdiv_i64(i64 %x, i64 %y) {
; CHECK-LABEL: 'sdiv_i64'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %r = sdiv i64 %x, %y
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: ret i64 %r
;
  %r = sdiv i64 %x, %y
  ret i64 %r
}

; FIXME: div is 1 instruction.

define i64 @udiv_i64(i64 %x, i64 %y) {
; CHECK-LABEL: 'udiv_i64'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %r = udiv i64 %x, %y
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: ret i64 %r
;
  %r = udiv i64 %x, %y
  ret i64 %r
}

; FIXME: idiv is 1 instruction.

define i64 @srem_i64(i64 %x, i64 %y) {
; CHECK-LABEL: 'srem_i64'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %r = srem i64 %x, %y
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: ret i64 %r
;
  %r = srem i64 %x, %y
  ret i64 %r
}

; FIXME: div is 1 instruction.

define i64 @urem_i64(i64 %x, i64 %y) {
; CHECK-LABEL: 'urem_i64'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %r = urem i64 %x, %y
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: ret i64 %r
;
  %r = urem i64 %x, %y
  ret i64 %r
}

define i64 @ashr_i64(i64 %x, i64 %y) {
; CHECK-LABEL: 'ashr_i64'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %r = ashr i64 %x, %y
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: ret i64 %r
;
  %r = ashr i64 %x, %y
  ret i64 %r
}

define i64 @lshr_i64(i64 %x, i64 %y) {
; CHECK-LABEL: 'lshr_i64'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %r = lshr i64 %x, %y
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: ret i64 %r
;
  %r = lshr i64 %x, %y
  ret i64 %r
}

define i64 @shl_i64(i64 %x, i64 %y) {
; CHECK-LABEL: 'shl_i64'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %r = shl i64 %x, %y
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: ret i64 %r
;
  %r = shl i64 %x, %y
  ret i64 %r
}

define i64 @and_i64(i64 %x, i64 %y) {
; CHECK-LABEL: 'and_i64'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %r = and i64 %x, %y
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: ret i64 %r
;
  %r = and i64 %x, %y
  ret i64 %r
}

define i64 @or_i64(i64 %x, i64 %y) {
; CHECK-LABEL: 'or_i64'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %r = or i64 %x, %y
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: ret i64 %r
;
  %r = or i64 %x, %y
  ret i64 %r
}

define i64 @xor_i64(i64 %x, i64 %y) {
; CHECK-LABEL: 'xor_i64'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %r = xor i64 %x, %y
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: ret i64 %r
;
  %r = xor i64 %x, %y
  ret i64 %r
}

define double @fadd_f64(double %x, double %y) {
; CHECK-LABEL: 'fadd_f64'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %r = fadd double %x, %y
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: ret double %r
;
  %r = fadd double %x, %y
  ret double %r
}

define double @fsub_f64(double %x, double %y) {
; CHECK-LABEL: 'fsub_f64'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %r = fsub double %x, %y
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: ret double %r
;
  %r = fsub double %x, %y
  ret double %r
}

define double @fmul_f64(double %x, double %y) {
; CHECK-LABEL: 'fmul_f64'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %r = fmul double %x, %y
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: ret double %r
;
  %r = fmul double %x, %y
  ret double %r
}

; FIXME: divsd is 1 instruction.

define double @fdiv_f64(double %x, double %y) {
; CHECK-LABEL: 'fdiv_f64'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %r = fdiv double %x, %y
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: ret double %r
;
  %r = fdiv double %x, %y
  ret double %r
}

; TODO: How does this lower?

define double @frem_f64(double %x, double %y) {
; CHECK-LABEL: 'frem_f64'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %r = frem double %x, %y
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: ret double %r
;
  %r = frem double %x, %y
  ret double %r
}

define double @fneg_f64(double %x) {
; CHECK-LABEL: 'fneg_f64'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %r = fneg double %x
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: ret double %r
;
  %r = fneg double %x
  ret double %r
}
