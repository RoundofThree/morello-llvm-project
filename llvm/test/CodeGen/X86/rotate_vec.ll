; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown -mcpu=bdver4 | FileCheck %s --check-prefixes=CHECK,XOP
; RUN: llc < %s -mtriple=x86_64-unknown -mcpu=skylake-avx512 | FileCheck %s --check-prefixes=CHECK,AVX512

define <4 x i32> @rot_v4i32_splat(<4 x i32> %x) {
; XOP-LABEL: rot_v4i32_splat:
; XOP:       # %bb.0:
; XOP-NEXT:    vprotd $31, %xmm0, %xmm0
; XOP-NEXT:    retq
;
; AVX512-LABEL: rot_v4i32_splat:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vprold $31, %xmm0, %xmm0
; AVX512-NEXT:    retq
  %1 = lshr <4 x i32> %x, <i32 1, i32 1, i32 1, i32 1>
  %2 = shl <4 x i32> %x, <i32 31, i32 31, i32 31, i32 31>
  %3 = or <4 x i32> %1, %2
  ret <4 x i32> %3
}

define <4 x i32> @rot_v4i32_non_splat(<4 x i32> %x) {
; XOP-LABEL: rot_v4i32_non_splat:
; XOP:       # %bb.0:
; XOP-NEXT:    vprotd {{.*}}(%rip), %xmm0, %xmm0
; XOP-NEXT:    retq
;
; AVX512-LABEL: rot_v4i32_non_splat:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vprolvd {{.*}}(%rip), %xmm0, %xmm0
; AVX512-NEXT:    retq
  %1 = lshr <4 x i32> %x, <i32 1, i32 2, i32 3, i32 4>
  %2 = shl <4 x i32> %x, <i32 31, i32 30, i32 29, i32 28>
  %3 = or <4 x i32> %1, %2
  ret <4 x i32> %3
}

define <4 x i32> @rot_v4i32_splat_2masks(<4 x i32> %x) {
; XOP-LABEL: rot_v4i32_splat_2masks:
; XOP:       # %bb.0:
; XOP-NEXT:    vprotd $31, %xmm0, %xmm0
; XOP-NEXT:    vpand {{.*}}(%rip), %xmm0, %xmm0
; XOP-NEXT:    retq
;
; AVX512-LABEL: rot_v4i32_splat_2masks:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vprold $31, %xmm0, %xmm0
; AVX512-NEXT:    vpand {{.*}}(%rip), %xmm0, %xmm0
; AVX512-NEXT:    retq
  %1 = lshr <4 x i32> %x, <i32 1, i32 1, i32 1, i32 1>
  %2 = and <4 x i32> %1, <i32 4294901760, i32 4294901760, i32 4294901760, i32 4294901760>

  %3 = shl <4 x i32> %x, <i32 31, i32 31, i32 31, i32 31>
  %4 = and <4 x i32> %3, <i32 0, i32 4294901760, i32 0, i32 4294901760>
  %5 = or <4 x i32> %2, %4
  ret <4 x i32> %5
}

define <4 x i32> @rot_v4i32_non_splat_2masks(<4 x i32> %x) {
; XOP-LABEL: rot_v4i32_non_splat_2masks:
; XOP:       # %bb.0:
; XOP-NEXT:    vprotd {{.*}}(%rip), %xmm0, %xmm0
; XOP-NEXT:    vpand {{.*}}(%rip), %xmm0, %xmm0
; XOP-NEXT:    retq
;
; AVX512-LABEL: rot_v4i32_non_splat_2masks:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vprolvd {{.*}}(%rip), %xmm0, %xmm0
; AVX512-NEXT:    vpand {{.*}}(%rip), %xmm0, %xmm0
; AVX512-NEXT:    retq
  %1 = lshr <4 x i32> %x, <i32 1, i32 2, i32 3, i32 4>
  %2 = and <4 x i32> %1, <i32 4294901760, i32 4294901760, i32 4294901760, i32 4294901760>

  %3 = shl <4 x i32> %x, <i32 31, i32 30, i32 29, i32 28>
  %4 = and <4 x i32> %3, <i32 0, i32 4294901760, i32 0, i32 4294901760>
  %5 = or <4 x i32> %2, %4
  ret <4 x i32> %5
}

define <4 x i32> @rot_v4i32_zero_non_splat(<4 x i32> %x) {
; CHECK-LABEL: rot_v4i32_zero_non_splat:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vbroadcastss %xmm0, %xmm0
; CHECK-NEXT:    retq
  %1 = call <4 x i32> @llvm.fshl.v4i32(<4 x i32> %x, <4 x i32> %x, <4 x i32> <i32 0, i32 1, i32 2, i32 3>)
  %2 = shufflevector <4 x i32> %1, <4 x i32> undef, <4 x i32> zeroinitializer
  ret <4 x i32> %2
}

define <4 x i32> @rot_v4i32_allsignbits(<4 x i32> %x, <4 x i32> %y) {
; XOP-LABEL: rot_v4i32_allsignbits:
; XOP:       # %bb.0:
; XOP-NEXT:    vpsrad $31, %xmm0, %xmm0
; XOP-NEXT:    vprotd %xmm1, %xmm0, %xmm0
; XOP-NEXT:    retq
;
; AVX512-LABEL: rot_v4i32_allsignbits:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpsrad $31, %xmm0, %xmm0
; AVX512-NEXT:    vprolvd %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    retq
  %1 = ashr <4 x i32> %x, <i32 31, i32 31, i32 31, i32 31>
  %2 = call <4 x i32> @llvm.fshl.v4i32(<4 x i32> %1, <4 x i32> %1, <4 x i32> %y)
  ret <4 x i32> %2
}

declare <4 x i32> @llvm.fshl.v4i32(<4 x i32>, <4 x i32>, <4 x i32>)
