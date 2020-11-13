; NOTE: Assertions have been autogenerated by utils/update_analyze_test_checks.py
; RUN: opt < %s -mtriple=i686-unknown-linux-gnu -cost-model -analyze -mattr=+sse2 | FileCheck %s -check-prefixes=X86,SSE2
; RUN: opt < %s -mtriple=i686-unknown-linux-gnu -cost-model -analyze -mattr=+sse4.2 | FileCheck %s -check-prefixes=X86,SSE42
; RUN: opt < %s -mtriple=i686-unknown-linux-gnu -cost-model -analyze -mattr=+avx | FileCheck %s -check-prefixes=X86,AVX,AVX1
; RUN: opt < %s -mtriple=i686-unknown-linux-gnu -cost-model -analyze -mattr=+avx2 | FileCheck %s -check-prefixes=X86,AVX,AVX2
; RUN: opt < %s -mtriple=i686-unknown-linux-gnu -cost-model -analyze -mattr=+avx512f | FileCheck %s -check-prefixes=X86,AVX512,AVX512F
; RUN: opt < %s -mtriple=i686-unknown-linux-gnu -cost-model -analyze -mattr=+avx512vl,avx512bw,avx512dq | FileCheck %s -check-prefixes=X86,AVX512,AVX512BW
; RUN: opt < %s -mtriple=x86_64-unknown-linux-gnu -cost-model -analyze -mattr=+sse2 | FileCheck %s -check-prefixes=X64,SSE2
; RUN: opt < %s -mtriple=x86_64-unknown-linux-gnu -cost-model -analyze -mattr=+sse4.2 | FileCheck %s -check-prefixes=X64,SSE42
; RUN: opt < %s -mtriple=x86_64-unknown-linux-gnu -cost-model -analyze -mattr=+avx | FileCheck %s -check-prefixes=X64,AVX,AVX1
; RUN: opt < %s -mtriple=x86_64-unknown-linux-gnu -cost-model -analyze -mattr=+avx2 | FileCheck %s -check-prefixes=X64,AVX,AVX2
; RUN: opt < %s -mtriple=x86_64-unknown-linux-gnu -cost-model -analyze -mattr=+avx512f | FileCheck %s -check-prefixes=X64,AVX512,AVX512F
; RUN: opt < %s -mtriple=x86_64-unknown-linux-gnu -cost-model -analyze -mattr=+avx512vl,+avx512bw,+avx512dq | FileCheck %s -check-prefixes=X64,AVX512,AVX512BW
; RUN: opt < %s -mtriple=x86_64-unknown-linux-gnu -cost-model -analyze -mattr=+xop | FileCheck %s -check-prefixes=XOP
; RUN: opt < %s -mtriple=x86_64-unknown-linux-gnu -cost-model -analyze -mattr=+xop,+avx2 | FileCheck %s -check-prefixes=XOP

; Verify the cost of scalar bitreverse instructions.

declare i64 @llvm.bitreverse.i64(i64)
declare i32 @llvm.bitreverse.i32(i32)
declare i16 @llvm.bitreverse.i16(i16)
declare  i8 @llvm.bitreverse.i8(i8)

define i64 @var_bitreverse_i64(i64 %a) {
; X86-LABEL: 'var_bitreverse_i64'
; X86-NEXT:  Cost Model: Found an estimated cost of 28 for instruction: %bitreverse = call i64 @llvm.bitreverse.i64(i64 %a)
; X86-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret i64 %bitreverse
;
; X64-LABEL: 'var_bitreverse_i64'
; X64-NEXT:  Cost Model: Found an estimated cost of 14 for instruction: %bitreverse = call i64 @llvm.bitreverse.i64(i64 %a)
; X64-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret i64 %bitreverse
;
; XOP-LABEL: 'var_bitreverse_i64'
; XOP-NEXT:  Cost Model: Found an estimated cost of 3 for instruction: %bitreverse = call i64 @llvm.bitreverse.i64(i64 %a)
; XOP-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret i64 %bitreverse
;
  %bitreverse = call i64 @llvm.bitreverse.i64(i64 %a)
  ret i64 %bitreverse
}

define i32 @var_bitreverse_i32(i32 %a) {
; X86-LABEL: 'var_bitreverse_i32'
; X86-NEXT:  Cost Model: Found an estimated cost of 14 for instruction: %bitreverse = call i32 @llvm.bitreverse.i32(i32 %a)
; X86-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret i32 %bitreverse
;
; X64-LABEL: 'var_bitreverse_i32'
; X64-NEXT:  Cost Model: Found an estimated cost of 14 for instruction: %bitreverse = call i32 @llvm.bitreverse.i32(i32 %a)
; X64-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret i32 %bitreverse
;
; XOP-LABEL: 'var_bitreverse_i32'
; XOP-NEXT:  Cost Model: Found an estimated cost of 3 for instruction: %bitreverse = call i32 @llvm.bitreverse.i32(i32 %a)
; XOP-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret i32 %bitreverse
;
  %bitreverse = call i32 @llvm.bitreverse.i32(i32 %a)
  ret i32 %bitreverse
}

define i16 @var_bitreverse_i16(i16 %a) {
; X86-LABEL: 'var_bitreverse_i16'
; X86-NEXT:  Cost Model: Found an estimated cost of 14 for instruction: %bitreverse = call i16 @llvm.bitreverse.i16(i16 %a)
; X86-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret i16 %bitreverse
;
; X64-LABEL: 'var_bitreverse_i16'
; X64-NEXT:  Cost Model: Found an estimated cost of 14 for instruction: %bitreverse = call i16 @llvm.bitreverse.i16(i16 %a)
; X64-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret i16 %bitreverse
;
; XOP-LABEL: 'var_bitreverse_i16'
; XOP-NEXT:  Cost Model: Found an estimated cost of 3 for instruction: %bitreverse = call i16 @llvm.bitreverse.i16(i16 %a)
; XOP-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret i16 %bitreverse
;
  %bitreverse = call i16 @llvm.bitreverse.i16(i16 %a)
  ret i16 %bitreverse
}

define i8 @var_bitreverse_i8(i8 %a) {
; X86-LABEL: 'var_bitreverse_i8'
; X86-NEXT:  Cost Model: Found an estimated cost of 11 for instruction: %bitreverse = call i8 @llvm.bitreverse.i8(i8 %a)
; X86-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret i8 %bitreverse
;
; X64-LABEL: 'var_bitreverse_i8'
; X64-NEXT:  Cost Model: Found an estimated cost of 11 for instruction: %bitreverse = call i8 @llvm.bitreverse.i8(i8 %a)
; X64-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret i8 %bitreverse
;
; XOP-LABEL: 'var_bitreverse_i8'
; XOP-NEXT:  Cost Model: Found an estimated cost of 3 for instruction: %bitreverse = call i8 @llvm.bitreverse.i8(i8 %a)
; XOP-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret i8 %bitreverse
;
  %bitreverse = call i8 @llvm.bitreverse.i8(i8 %a)
  ret i8 %bitreverse
}

; Verify the cost of vector bitreverse instructions.

declare <2 x i64> @llvm.bitreverse.v2i64(<2 x i64>)
declare <4 x i32> @llvm.bitreverse.v4i32(<4 x i32>)
declare <8 x i16> @llvm.bitreverse.v8i16(<8 x i16>)
declare <16 x i8> @llvm.bitreverse.v16i8(<16 x i8>)

declare <4 x i64> @llvm.bitreverse.v4i64(<4 x i64>)
declare <8 x i32> @llvm.bitreverse.v8i32(<8 x i32>)
declare <16 x i16> @llvm.bitreverse.v16i16(<16 x i16>)
declare <32 x i8> @llvm.bitreverse.v32i8(<32 x i8>)

declare <8 x i64> @llvm.bitreverse.v8i64(<8 x i64>)
declare <16 x i32> @llvm.bitreverse.v16i32(<16 x i32>)
declare <32 x i16> @llvm.bitreverse.v32i16(<32 x i16>)
declare <64 x i8> @llvm.bitreverse.v64i8(<64 x i8>)

define <2 x i64> @var_bitreverse_v2i64(<2 x i64> %a) {
; SSE2-LABEL: 'var_bitreverse_v2i64'
; SSE2-NEXT:  Cost Model: Found an estimated cost of 29 for instruction: %bitreverse = call <2 x i64> @llvm.bitreverse.v2i64(<2 x i64> %a)
; SSE2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <2 x i64> %bitreverse
;
; SSE42-LABEL: 'var_bitreverse_v2i64'
; SSE42-NEXT:  Cost Model: Found an estimated cost of 5 for instruction: %bitreverse = call <2 x i64> @llvm.bitreverse.v2i64(<2 x i64> %a)
; SSE42-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <2 x i64> %bitreverse
;
; AVX-LABEL: 'var_bitreverse_v2i64'
; AVX-NEXT:  Cost Model: Found an estimated cost of 5 for instruction: %bitreverse = call <2 x i64> @llvm.bitreverse.v2i64(<2 x i64> %a)
; AVX-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <2 x i64> %bitreverse
;
; AVX512-LABEL: 'var_bitreverse_v2i64'
; AVX512-NEXT:  Cost Model: Found an estimated cost of 5 for instruction: %bitreverse = call <2 x i64> @llvm.bitreverse.v2i64(<2 x i64> %a)
; AVX512-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <2 x i64> %bitreverse
;
; XOP-LABEL: 'var_bitreverse_v2i64'
; XOP-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %bitreverse = call <2 x i64> @llvm.bitreverse.v2i64(<2 x i64> %a)
; XOP-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <2 x i64> %bitreverse
;
  %bitreverse = call <2 x i64> @llvm.bitreverse.v2i64(<2 x i64> %a)
  ret <2 x i64> %bitreverse
}

define <4 x i64> @var_bitreverse_v4i64(<4 x i64> %a) {
; SSE2-LABEL: 'var_bitreverse_v4i64'
; SSE2-NEXT:  Cost Model: Found an estimated cost of 58 for instruction: %bitreverse = call <4 x i64> @llvm.bitreverse.v4i64(<4 x i64> %a)
; SSE2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <4 x i64> %bitreverse
;
; SSE42-LABEL: 'var_bitreverse_v4i64'
; SSE42-NEXT:  Cost Model: Found an estimated cost of 10 for instruction: %bitreverse = call <4 x i64> @llvm.bitreverse.v4i64(<4 x i64> %a)
; SSE42-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <4 x i64> %bitreverse
;
; AVX1-LABEL: 'var_bitreverse_v4i64'
; AVX1-NEXT:  Cost Model: Found an estimated cost of 12 for instruction: %bitreverse = call <4 x i64> @llvm.bitreverse.v4i64(<4 x i64> %a)
; AVX1-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <4 x i64> %bitreverse
;
; AVX2-LABEL: 'var_bitreverse_v4i64'
; AVX2-NEXT:  Cost Model: Found an estimated cost of 5 for instruction: %bitreverse = call <4 x i64> @llvm.bitreverse.v4i64(<4 x i64> %a)
; AVX2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <4 x i64> %bitreverse
;
; AVX512-LABEL: 'var_bitreverse_v4i64'
; AVX512-NEXT:  Cost Model: Found an estimated cost of 5 for instruction: %bitreverse = call <4 x i64> @llvm.bitreverse.v4i64(<4 x i64> %a)
; AVX512-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <4 x i64> %bitreverse
;
; XOP-LABEL: 'var_bitreverse_v4i64'
; XOP-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %bitreverse = call <4 x i64> @llvm.bitreverse.v4i64(<4 x i64> %a)
; XOP-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <4 x i64> %bitreverse
;
  %bitreverse = call <4 x i64> @llvm.bitreverse.v4i64(<4 x i64> %a)
  ret <4 x i64> %bitreverse
}

define <8 x i64> @var_bitreverse_v8i64(<8 x i64> %a) {
; SSE2-LABEL: 'var_bitreverse_v8i64'
; SSE2-NEXT:  Cost Model: Found an estimated cost of 116 for instruction: %bitreverse = call <8 x i64> @llvm.bitreverse.v8i64(<8 x i64> %a)
; SSE2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x i64> %bitreverse
;
; SSE42-LABEL: 'var_bitreverse_v8i64'
; SSE42-NEXT:  Cost Model: Found an estimated cost of 20 for instruction: %bitreverse = call <8 x i64> @llvm.bitreverse.v8i64(<8 x i64> %a)
; SSE42-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x i64> %bitreverse
;
; AVX1-LABEL: 'var_bitreverse_v8i64'
; AVX1-NEXT:  Cost Model: Found an estimated cost of 24 for instruction: %bitreverse = call <8 x i64> @llvm.bitreverse.v8i64(<8 x i64> %a)
; AVX1-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x i64> %bitreverse
;
; AVX2-LABEL: 'var_bitreverse_v8i64'
; AVX2-NEXT:  Cost Model: Found an estimated cost of 10 for instruction: %bitreverse = call <8 x i64> @llvm.bitreverse.v8i64(<8 x i64> %a)
; AVX2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x i64> %bitreverse
;
; AVX512F-LABEL: 'var_bitreverse_v8i64'
; AVX512F-NEXT:  Cost Model: Found an estimated cost of 36 for instruction: %bitreverse = call <8 x i64> @llvm.bitreverse.v8i64(<8 x i64> %a)
; AVX512F-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x i64> %bitreverse
;
; AVX512BW-LABEL: 'var_bitreverse_v8i64'
; AVX512BW-NEXT:  Cost Model: Found an estimated cost of 5 for instruction: %bitreverse = call <8 x i64> @llvm.bitreverse.v8i64(<8 x i64> %a)
; AVX512BW-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x i64> %bitreverse
;
; XOP-LABEL: 'var_bitreverse_v8i64'
; XOP-NEXT:  Cost Model: Found an estimated cost of 8 for instruction: %bitreverse = call <8 x i64> @llvm.bitreverse.v8i64(<8 x i64> %a)
; XOP-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x i64> %bitreverse
;
  %bitreverse = call <8 x i64> @llvm.bitreverse.v8i64(<8 x i64> %a)
  ret <8 x i64> %bitreverse
}

define <4 x i32> @var_bitreverse_v4i32(<4 x i32> %a) {
; SSE2-LABEL: 'var_bitreverse_v4i32'
; SSE2-NEXT:  Cost Model: Found an estimated cost of 27 for instruction: %bitreverse = call <4 x i32> @llvm.bitreverse.v4i32(<4 x i32> %a)
; SSE2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <4 x i32> %bitreverse
;
; SSE42-LABEL: 'var_bitreverse_v4i32'
; SSE42-NEXT:  Cost Model: Found an estimated cost of 5 for instruction: %bitreverse = call <4 x i32> @llvm.bitreverse.v4i32(<4 x i32> %a)
; SSE42-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <4 x i32> %bitreverse
;
; AVX-LABEL: 'var_bitreverse_v4i32'
; AVX-NEXT:  Cost Model: Found an estimated cost of 5 for instruction: %bitreverse = call <4 x i32> @llvm.bitreverse.v4i32(<4 x i32> %a)
; AVX-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <4 x i32> %bitreverse
;
; AVX512-LABEL: 'var_bitreverse_v4i32'
; AVX512-NEXT:  Cost Model: Found an estimated cost of 5 for instruction: %bitreverse = call <4 x i32> @llvm.bitreverse.v4i32(<4 x i32> %a)
; AVX512-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <4 x i32> %bitreverse
;
; XOP-LABEL: 'var_bitreverse_v4i32'
; XOP-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %bitreverse = call <4 x i32> @llvm.bitreverse.v4i32(<4 x i32> %a)
; XOP-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <4 x i32> %bitreverse
;
  %bitreverse = call <4 x i32> @llvm.bitreverse.v4i32(<4 x i32> %a)
  ret <4 x i32> %bitreverse
}

define <8 x i32> @var_bitreverse_v8i32(<8 x i32> %a) {
; SSE2-LABEL: 'var_bitreverse_v8i32'
; SSE2-NEXT:  Cost Model: Found an estimated cost of 54 for instruction: %bitreverse = call <8 x i32> @llvm.bitreverse.v8i32(<8 x i32> %a)
; SSE2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x i32> %bitreverse
;
; SSE42-LABEL: 'var_bitreverse_v8i32'
; SSE42-NEXT:  Cost Model: Found an estimated cost of 10 for instruction: %bitreverse = call <8 x i32> @llvm.bitreverse.v8i32(<8 x i32> %a)
; SSE42-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x i32> %bitreverse
;
; AVX1-LABEL: 'var_bitreverse_v8i32'
; AVX1-NEXT:  Cost Model: Found an estimated cost of 12 for instruction: %bitreverse = call <8 x i32> @llvm.bitreverse.v8i32(<8 x i32> %a)
; AVX1-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x i32> %bitreverse
;
; AVX2-LABEL: 'var_bitreverse_v8i32'
; AVX2-NEXT:  Cost Model: Found an estimated cost of 5 for instruction: %bitreverse = call <8 x i32> @llvm.bitreverse.v8i32(<8 x i32> %a)
; AVX2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x i32> %bitreverse
;
; AVX512-LABEL: 'var_bitreverse_v8i32'
; AVX512-NEXT:  Cost Model: Found an estimated cost of 5 for instruction: %bitreverse = call <8 x i32> @llvm.bitreverse.v8i32(<8 x i32> %a)
; AVX512-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x i32> %bitreverse
;
; XOP-LABEL: 'var_bitreverse_v8i32'
; XOP-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %bitreverse = call <8 x i32> @llvm.bitreverse.v8i32(<8 x i32> %a)
; XOP-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x i32> %bitreverse
;
  %bitreverse = call <8 x i32> @llvm.bitreverse.v8i32(<8 x i32> %a)
  ret <8 x i32> %bitreverse
}

define <16 x i32> @var_bitreverse_v16i32(<16 x i32> %a) {
; SSE2-LABEL: 'var_bitreverse_v16i32'
; SSE2-NEXT:  Cost Model: Found an estimated cost of 108 for instruction: %bitreverse = call <16 x i32> @llvm.bitreverse.v16i32(<16 x i32> %a)
; SSE2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <16 x i32> %bitreverse
;
; SSE42-LABEL: 'var_bitreverse_v16i32'
; SSE42-NEXT:  Cost Model: Found an estimated cost of 20 for instruction: %bitreverse = call <16 x i32> @llvm.bitreverse.v16i32(<16 x i32> %a)
; SSE42-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <16 x i32> %bitreverse
;
; AVX1-LABEL: 'var_bitreverse_v16i32'
; AVX1-NEXT:  Cost Model: Found an estimated cost of 24 for instruction: %bitreverse = call <16 x i32> @llvm.bitreverse.v16i32(<16 x i32> %a)
; AVX1-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <16 x i32> %bitreverse
;
; AVX2-LABEL: 'var_bitreverse_v16i32'
; AVX2-NEXT:  Cost Model: Found an estimated cost of 10 for instruction: %bitreverse = call <16 x i32> @llvm.bitreverse.v16i32(<16 x i32> %a)
; AVX2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <16 x i32> %bitreverse
;
; AVX512F-LABEL: 'var_bitreverse_v16i32'
; AVX512F-NEXT:  Cost Model: Found an estimated cost of 24 for instruction: %bitreverse = call <16 x i32> @llvm.bitreverse.v16i32(<16 x i32> %a)
; AVX512F-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <16 x i32> %bitreverse
;
; AVX512BW-LABEL: 'var_bitreverse_v16i32'
; AVX512BW-NEXT:  Cost Model: Found an estimated cost of 5 for instruction: %bitreverse = call <16 x i32> @llvm.bitreverse.v16i32(<16 x i32> %a)
; AVX512BW-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <16 x i32> %bitreverse
;
; XOP-LABEL: 'var_bitreverse_v16i32'
; XOP-NEXT:  Cost Model: Found an estimated cost of 8 for instruction: %bitreverse = call <16 x i32> @llvm.bitreverse.v16i32(<16 x i32> %a)
; XOP-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <16 x i32> %bitreverse
;
  %bitreverse = call <16 x i32> @llvm.bitreverse.v16i32(<16 x i32> %a)
  ret <16 x i32> %bitreverse
}

define <8 x i16> @var_bitreverse_v8i16(<8 x i16> %a) {
; SSE2-LABEL: 'var_bitreverse_v8i16'
; SSE2-NEXT:  Cost Model: Found an estimated cost of 27 for instruction: %bitreverse = call <8 x i16> @llvm.bitreverse.v8i16(<8 x i16> %a)
; SSE2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x i16> %bitreverse
;
; SSE42-LABEL: 'var_bitreverse_v8i16'
; SSE42-NEXT:  Cost Model: Found an estimated cost of 5 for instruction: %bitreverse = call <8 x i16> @llvm.bitreverse.v8i16(<8 x i16> %a)
; SSE42-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x i16> %bitreverse
;
; AVX-LABEL: 'var_bitreverse_v8i16'
; AVX-NEXT:  Cost Model: Found an estimated cost of 5 for instruction: %bitreverse = call <8 x i16> @llvm.bitreverse.v8i16(<8 x i16> %a)
; AVX-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x i16> %bitreverse
;
; AVX512-LABEL: 'var_bitreverse_v8i16'
; AVX512-NEXT:  Cost Model: Found an estimated cost of 5 for instruction: %bitreverse = call <8 x i16> @llvm.bitreverse.v8i16(<8 x i16> %a)
; AVX512-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x i16> %bitreverse
;
; XOP-LABEL: 'var_bitreverse_v8i16'
; XOP-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %bitreverse = call <8 x i16> @llvm.bitreverse.v8i16(<8 x i16> %a)
; XOP-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x i16> %bitreverse
;
  %bitreverse = call <8 x i16> @llvm.bitreverse.v8i16(<8 x i16> %a)
  ret <8 x i16> %bitreverse
}

define <16 x i16> @var_bitreverse_v16i16(<16 x i16> %a) {
; SSE2-LABEL: 'var_bitreverse_v16i16'
; SSE2-NEXT:  Cost Model: Found an estimated cost of 54 for instruction: %bitreverse = call <16 x i16> @llvm.bitreverse.v16i16(<16 x i16> %a)
; SSE2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <16 x i16> %bitreverse
;
; SSE42-LABEL: 'var_bitreverse_v16i16'
; SSE42-NEXT:  Cost Model: Found an estimated cost of 10 for instruction: %bitreverse = call <16 x i16> @llvm.bitreverse.v16i16(<16 x i16> %a)
; SSE42-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <16 x i16> %bitreverse
;
; AVX1-LABEL: 'var_bitreverse_v16i16'
; AVX1-NEXT:  Cost Model: Found an estimated cost of 12 for instruction: %bitreverse = call <16 x i16> @llvm.bitreverse.v16i16(<16 x i16> %a)
; AVX1-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <16 x i16> %bitreverse
;
; AVX2-LABEL: 'var_bitreverse_v16i16'
; AVX2-NEXT:  Cost Model: Found an estimated cost of 5 for instruction: %bitreverse = call <16 x i16> @llvm.bitreverse.v16i16(<16 x i16> %a)
; AVX2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <16 x i16> %bitreverse
;
; AVX512-LABEL: 'var_bitreverse_v16i16'
; AVX512-NEXT:  Cost Model: Found an estimated cost of 5 for instruction: %bitreverse = call <16 x i16> @llvm.bitreverse.v16i16(<16 x i16> %a)
; AVX512-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <16 x i16> %bitreverse
;
; XOP-LABEL: 'var_bitreverse_v16i16'
; XOP-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %bitreverse = call <16 x i16> @llvm.bitreverse.v16i16(<16 x i16> %a)
; XOP-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <16 x i16> %bitreverse
;
  %bitreverse = call <16 x i16> @llvm.bitreverse.v16i16(<16 x i16> %a)
  ret <16 x i16> %bitreverse
}

define <32 x i16> @var_bitreverse_v32i16(<32 x i16> %a) {
; SSE2-LABEL: 'var_bitreverse_v32i16'
; SSE2-NEXT:  Cost Model: Found an estimated cost of 108 for instruction: %bitreverse = call <32 x i16> @llvm.bitreverse.v32i16(<32 x i16> %a)
; SSE2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <32 x i16> %bitreverse
;
; SSE42-LABEL: 'var_bitreverse_v32i16'
; SSE42-NEXT:  Cost Model: Found an estimated cost of 20 for instruction: %bitreverse = call <32 x i16> @llvm.bitreverse.v32i16(<32 x i16> %a)
; SSE42-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <32 x i16> %bitreverse
;
; AVX1-LABEL: 'var_bitreverse_v32i16'
; AVX1-NEXT:  Cost Model: Found an estimated cost of 24 for instruction: %bitreverse = call <32 x i16> @llvm.bitreverse.v32i16(<32 x i16> %a)
; AVX1-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <32 x i16> %bitreverse
;
; AVX2-LABEL: 'var_bitreverse_v32i16'
; AVX2-NEXT:  Cost Model: Found an estimated cost of 10 for instruction: %bitreverse = call <32 x i16> @llvm.bitreverse.v32i16(<32 x i16> %a)
; AVX2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <32 x i16> %bitreverse
;
; AVX512F-LABEL: 'var_bitreverse_v32i16'
; AVX512F-NEXT:  Cost Model: Found an estimated cost of 10 for instruction: %bitreverse = call <32 x i16> @llvm.bitreverse.v32i16(<32 x i16> %a)
; AVX512F-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <32 x i16> %bitreverse
;
; AVX512BW-LABEL: 'var_bitreverse_v32i16'
; AVX512BW-NEXT:  Cost Model: Found an estimated cost of 5 for instruction: %bitreverse = call <32 x i16> @llvm.bitreverse.v32i16(<32 x i16> %a)
; AVX512BW-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <32 x i16> %bitreverse
;
; XOP-LABEL: 'var_bitreverse_v32i16'
; XOP-NEXT:  Cost Model: Found an estimated cost of 8 for instruction: %bitreverse = call <32 x i16> @llvm.bitreverse.v32i16(<32 x i16> %a)
; XOP-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <32 x i16> %bitreverse
;
  %bitreverse = call <32 x i16> @llvm.bitreverse.v32i16(<32 x i16> %a)
  ret <32 x i16> %bitreverse
}

define <16 x i8> @var_bitreverse_v16i8(<16 x i8> %a) {
; SSE2-LABEL: 'var_bitreverse_v16i8'
; SSE2-NEXT:  Cost Model: Found an estimated cost of 20 for instruction: %bitreverse = call <16 x i8> @llvm.bitreverse.v16i8(<16 x i8> %a)
; SSE2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <16 x i8> %bitreverse
;
; SSE42-LABEL: 'var_bitreverse_v16i8'
; SSE42-NEXT:  Cost Model: Found an estimated cost of 5 for instruction: %bitreverse = call <16 x i8> @llvm.bitreverse.v16i8(<16 x i8> %a)
; SSE42-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <16 x i8> %bitreverse
;
; AVX-LABEL: 'var_bitreverse_v16i8'
; AVX-NEXT:  Cost Model: Found an estimated cost of 5 for instruction: %bitreverse = call <16 x i8> @llvm.bitreverse.v16i8(<16 x i8> %a)
; AVX-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <16 x i8> %bitreverse
;
; AVX512-LABEL: 'var_bitreverse_v16i8'
; AVX512-NEXT:  Cost Model: Found an estimated cost of 5 for instruction: %bitreverse = call <16 x i8> @llvm.bitreverse.v16i8(<16 x i8> %a)
; AVX512-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <16 x i8> %bitreverse
;
; XOP-LABEL: 'var_bitreverse_v16i8'
; XOP-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %bitreverse = call <16 x i8> @llvm.bitreverse.v16i8(<16 x i8> %a)
; XOP-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <16 x i8> %bitreverse
;
  %bitreverse = call <16 x i8> @llvm.bitreverse.v16i8(<16 x i8> %a)
  ret <16 x i8> %bitreverse
}

define <32 x i8> @var_bitreverse_v32i8(<32 x i8> %a) {
; SSE2-LABEL: 'var_bitreverse_v32i8'
; SSE2-NEXT:  Cost Model: Found an estimated cost of 40 for instruction: %bitreverse = call <32 x i8> @llvm.bitreverse.v32i8(<32 x i8> %a)
; SSE2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <32 x i8> %bitreverse
;
; SSE42-LABEL: 'var_bitreverse_v32i8'
; SSE42-NEXT:  Cost Model: Found an estimated cost of 10 for instruction: %bitreverse = call <32 x i8> @llvm.bitreverse.v32i8(<32 x i8> %a)
; SSE42-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <32 x i8> %bitreverse
;
; AVX1-LABEL: 'var_bitreverse_v32i8'
; AVX1-NEXT:  Cost Model: Found an estimated cost of 12 for instruction: %bitreverse = call <32 x i8> @llvm.bitreverse.v32i8(<32 x i8> %a)
; AVX1-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <32 x i8> %bitreverse
;
; AVX2-LABEL: 'var_bitreverse_v32i8'
; AVX2-NEXT:  Cost Model: Found an estimated cost of 5 for instruction: %bitreverse = call <32 x i8> @llvm.bitreverse.v32i8(<32 x i8> %a)
; AVX2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <32 x i8> %bitreverse
;
; AVX512-LABEL: 'var_bitreverse_v32i8'
; AVX512-NEXT:  Cost Model: Found an estimated cost of 5 for instruction: %bitreverse = call <32 x i8> @llvm.bitreverse.v32i8(<32 x i8> %a)
; AVX512-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <32 x i8> %bitreverse
;
; XOP-LABEL: 'var_bitreverse_v32i8'
; XOP-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %bitreverse = call <32 x i8> @llvm.bitreverse.v32i8(<32 x i8> %a)
; XOP-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <32 x i8> %bitreverse
;
  %bitreverse = call <32 x i8> @llvm.bitreverse.v32i8(<32 x i8> %a)
  ret <32 x i8> %bitreverse
}

define <64 x i8> @var_bitreverse_v64i8(<64 x i8> %a) {
; SSE2-LABEL: 'var_bitreverse_v64i8'
; SSE2-NEXT:  Cost Model: Found an estimated cost of 80 for instruction: %bitreverse = call <64 x i8> @llvm.bitreverse.v64i8(<64 x i8> %a)
; SSE2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <64 x i8> %bitreverse
;
; SSE42-LABEL: 'var_bitreverse_v64i8'
; SSE42-NEXT:  Cost Model: Found an estimated cost of 20 for instruction: %bitreverse = call <64 x i8> @llvm.bitreverse.v64i8(<64 x i8> %a)
; SSE42-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <64 x i8> %bitreverse
;
; AVX1-LABEL: 'var_bitreverse_v64i8'
; AVX1-NEXT:  Cost Model: Found an estimated cost of 24 for instruction: %bitreverse = call <64 x i8> @llvm.bitreverse.v64i8(<64 x i8> %a)
; AVX1-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <64 x i8> %bitreverse
;
; AVX2-LABEL: 'var_bitreverse_v64i8'
; AVX2-NEXT:  Cost Model: Found an estimated cost of 10 for instruction: %bitreverse = call <64 x i8> @llvm.bitreverse.v64i8(<64 x i8> %a)
; AVX2-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <64 x i8> %bitreverse
;
; AVX512F-LABEL: 'var_bitreverse_v64i8'
; AVX512F-NEXT:  Cost Model: Found an estimated cost of 10 for instruction: %bitreverse = call <64 x i8> @llvm.bitreverse.v64i8(<64 x i8> %a)
; AVX512F-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <64 x i8> %bitreverse
;
; AVX512BW-LABEL: 'var_bitreverse_v64i8'
; AVX512BW-NEXT:  Cost Model: Found an estimated cost of 5 for instruction: %bitreverse = call <64 x i8> @llvm.bitreverse.v64i8(<64 x i8> %a)
; AVX512BW-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <64 x i8> %bitreverse
;
; XOP-LABEL: 'var_bitreverse_v64i8'
; XOP-NEXT:  Cost Model: Found an estimated cost of 8 for instruction: %bitreverse = call <64 x i8> @llvm.bitreverse.v64i8(<64 x i8> %a)
; XOP-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <64 x i8> %bitreverse
;
  %bitreverse = call <64 x i8> @llvm.bitreverse.v64i8(<64 x i8> %a)
  ret <64 x i8> %bitreverse
}
