; NOTE: Assertions have been autogenerated by utils/update_analyze_test_checks.py
; RUN: opt < %s -cost-model -analyze -cost-kind=size-latency -mtriple=x86_64-- -mattr=+sse2 | FileCheck %s --check-prefixes=CHECK,SSE2
; RUN: opt < %s -cost-model -analyze -cost-kind=size-latency -mtriple=x86_64-- -mattr=+avx2 | FileCheck %s --check-prefixes=CHECK,AVX2

define i32 @f32(i32 %arg) {
; CHECK-LABEL: 'f32'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %F32 = call float @llvm.maxnum.f32(float undef, float undef)
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %V2F32 = call <2 x float> @llvm.maxnum.v2f32(<2 x float> undef, <2 x float> undef)
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %V4F32 = call <4 x float> @llvm.maxnum.v4f32(<4 x float> undef, <4 x float> undef)
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %V8F32 = call <8 x float> @llvm.maxnum.v8f32(<8 x float> undef, <8 x float> undef)
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %V16F32 = call <16 x float> @llvm.maxnum.v16f32(<16 x float> undef, <16 x float> undef)
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: ret i32 undef
;
  %F32 = call float @llvm.maxnum.f32(float undef, float undef)
  %V2F32 = call <2 x float> @llvm.maxnum.v2f32(<2 x float> undef, <2 x float> undef)
  %V4F32 = call <4 x float> @llvm.maxnum.v4f32(<4 x float> undef, <4 x float> undef)
  %V8F32 = call <8 x float> @llvm.maxnum.v8f32(<8 x float> undef, <8 x float> undef)
  %V16F32 = call <16 x float> @llvm.maxnum.v16f32(<16 x float> undef, <16 x float> undef)
  ret i32 undef
}

define i32 @f64(i32 %arg) {
; CHECK-LABEL: 'f64'
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %f64 = call double @llvm.maxnum.f64(double undef, double undef)
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %V2f64 = call <2 x double> @llvm.maxnum.v2f64(<2 x double> undef, <2 x double> undef)
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %V4f64 = call <4 x double> @llvm.maxnum.v4f64(<4 x double> undef, <4 x double> undef)
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %V8f64 = call <8 x double> @llvm.maxnum.v8f64(<8 x double> undef, <8 x double> undef)
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %V16f64 = call <16 x double> @llvm.maxnum.v16f64(<16 x double> undef, <16 x double> undef)
; CHECK-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: ret i32 undef
;
  %f64 = call double @llvm.maxnum.f64(double undef, double undef)
  %V2f64 = call <2 x double> @llvm.maxnum.v2f64(<2 x double> undef, <2 x double> undef)
  %V4f64 = call <4 x double> @llvm.maxnum.v4f64(<4 x double> undef, <4 x double> undef)
  %V8f64 = call <8 x double> @llvm.maxnum.v8f64(<8 x double> undef, <8 x double> undef)
  %V16f64 = call <16 x double> @llvm.maxnum.v16f64(<16 x double> undef, <16 x double> undef)
  ret i32 undef
}

declare float @llvm.maxnum.f32(float, float)
declare <2 x float> @llvm.maxnum.v2f32(<2 x float>, <2 x float>)
declare <4 x float> @llvm.maxnum.v4f32(<4 x float>, <4 x float>)
declare <8 x float> @llvm.maxnum.v8f32(<8 x float>, <8 x float>)
declare <16 x float> @llvm.maxnum.v16f32(<16 x float>, <16 x float>)

declare double @llvm.maxnum.f64(double, double)
declare <2 x double> @llvm.maxnum.v2f64(<2 x double>, <2 x double>)
declare <4 x double> @llvm.maxnum.v4f64(<4 x double>, <4 x double>)
declare <8 x double> @llvm.maxnum.v8f64(<8 x double>, <8 x double>)
declare <16 x double> @llvm.maxnum.v16f64(<16 x double>, <16 x double>)
