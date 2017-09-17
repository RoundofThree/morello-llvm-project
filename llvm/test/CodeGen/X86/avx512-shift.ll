; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
;RUN: llc < %s -mtriple=x86_64-unknown-unknown -mcpu=knl | FileCheck %s --check-prefix=CHECK --check-prefix=KNL
;RUN: llc < %s -mtriple=x86_64-unknown-unknown -mcpu=skx | FileCheck %s --check-prefix=CHECK --check-prefix=SKX

define <16 x i32> @shift_16_i32(<16 x i32> %a) {
; CHECK-LABEL: shift_16_i32:
; CHECK:       # BB#0:
; CHECK-NEXT:    vpsrld $1, %zmm0, %zmm0
; CHECK-NEXT:    vpslld $12, %zmm0, %zmm0
; CHECK-NEXT:    vpsrad $12, %zmm0, %zmm0
; CHECK-NEXT:    retq
   %b = lshr <16 x i32> %a, <i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1, i32 1>
   %c = shl <16 x i32> %b, <i32 12, i32 12, i32 12, i32 12, i32 12, i32 12, i32 12, i32 12, i32 12, i32 12, i32 12, i32 12, i32 12, i32 12, i32 12, i32 12>
   %d = ashr <16 x i32> %c, <i32 12, i32 12, i32 12, i32 12, i32 12, i32 12, i32 12, i32 12, i32 12, i32 12, i32 12, i32 12, i32 12, i32 12, i32 12, i32 12>
   ret <16 x i32> %d;
}

define <8 x i64> @shift_8_i64(<8 x i64> %a) {
; CHECK-LABEL: shift_8_i64:
; CHECK:       # BB#0:
; CHECK-NEXT:    vpsrlq $1, %zmm0, %zmm0
; CHECK-NEXT:    vpsllq $12, %zmm0, %zmm0
; CHECK-NEXT:    vpsraq $12, %zmm0, %zmm0
; CHECK-NEXT:    retq
   %b = lshr <8 x i64> %a, <i64 1, i64 1, i64 1, i64 1, i64 1, i64 1, i64 1, i64 1>
   %c = shl <8 x i64> %b,  <i64 12, i64 12, i64 12, i64 12, i64 12, i64 12, i64 12, i64 12>
   %d = ashr <8 x i64> %c, <i64 12, i64 12, i64 12, i64 12, i64 12, i64 12, i64 12, i64 12>
   ret <8 x i64> %d;
}

define <4 x i64> @shift_4_i64(<4 x i64> %a) {
; KNL-LABEL: shift_4_i64:
; KNL:       # BB#0:
; KNL-NEXT:    vpsrlq $1, %ymm0, %ymm0
; KNL-NEXT:    vpsllq $12, %ymm0, %ymm0
; KNL-NEXT:    vpsraq $12, %zmm0, %zmm0
; KNL-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<kill>
; KNL-NEXT:    retq
;
; SKX-LABEL: shift_4_i64:
; SKX:       # BB#0:
; SKX-NEXT:    vpsrlq $1, %ymm0, %ymm0
; SKX-NEXT:    vpsllq $12, %ymm0, %ymm0
; SKX-NEXT:    vpsraq $12, %ymm0, %ymm0
; SKX-NEXT:    retq
   %b = lshr <4 x i64> %a, <i64 1, i64 1, i64 1, i64 1>
   %c = shl <4 x i64> %b,  <i64 12, i64 12, i64 12, i64 12>
   %d = ashr <4 x i64> %c, <i64 12, i64 12, i64 12, i64 12>
   ret <4 x i64> %d;
}

define <8 x i64> @variable_shl4(<8 x i64> %x, <8 x i64> %y) {
; CHECK-LABEL: variable_shl4:
; CHECK:       # BB#0:
; CHECK-NEXT:    vpsllvq %zmm1, %zmm0, %zmm0
; CHECK-NEXT:    retq
  %k = shl <8 x i64> %x, %y
  ret <8 x i64> %k
}

define <16 x i32> @variable_shl5(<16 x i32> %x, <16 x i32> %y) {
; CHECK-LABEL: variable_shl5:
; CHECK:       # BB#0:
; CHECK-NEXT:    vpsllvd %zmm1, %zmm0, %zmm0
; CHECK-NEXT:    retq
  %k = shl <16 x i32> %x, %y
  ret <16 x i32> %k
}

define <16 x i32> @variable_srl0(<16 x i32> %x, <16 x i32> %y) {
; CHECK-LABEL: variable_srl0:
; CHECK:       # BB#0:
; CHECK-NEXT:    vpsrlvd %zmm1, %zmm0, %zmm0
; CHECK-NEXT:    retq
  %k = lshr <16 x i32> %x, %y
  ret <16 x i32> %k
}

define <8 x i64> @variable_srl2(<8 x i64> %x, <8 x i64> %y) {
; CHECK-LABEL: variable_srl2:
; CHECK:       # BB#0:
; CHECK-NEXT:    vpsrlvq %zmm1, %zmm0, %zmm0
; CHECK-NEXT:    retq
  %k = lshr <8 x i64> %x, %y
  ret <8 x i64> %k
}

define <16 x i32> @variable_sra1(<16 x i32> %x, <16 x i32> %y) {
; CHECK-LABEL: variable_sra1:
; CHECK:       # BB#0:
; CHECK-NEXT:    vpsravd %zmm1, %zmm0, %zmm0
; CHECK-NEXT:    retq
  %k = ashr <16 x i32> %x, %y
  ret <16 x i32> %k
}

define <8 x i64> @variable_sra2(<8 x i64> %x, <8 x i64> %y) {
; CHECK-LABEL: variable_sra2:
; CHECK:       # BB#0:
; CHECK-NEXT:    vpsravq %zmm1, %zmm0, %zmm0
; CHECK-NEXT:    retq
  %k = ashr <8 x i64> %x, %y
  ret <8 x i64> %k
}

define <4 x i64> @variable_sra3(<4 x i64> %x, <4 x i64> %y) {
; KNL-LABEL: variable_sra3:
; KNL:       # BB#0:
; KNL-NEXT:    # kill: %YMM1<def> %YMM1<kill> %ZMM1<def>
; KNL-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<def>
; KNL-NEXT:    vpsravq %zmm1, %zmm0, %zmm0
; KNL-NEXT:    # kill: %YMM0<def> %YMM0<kill> %ZMM0<kill>
; KNL-NEXT:    retq
;
; SKX-LABEL: variable_sra3:
; SKX:       # BB#0:
; SKX-NEXT:    vpsravq %ymm1, %ymm0, %ymm0
; SKX-NEXT:    retq
  %k = ashr <4 x i64> %x, %y
  ret <4 x i64> %k
}

define <8 x i16> @variable_sra4(<8 x i16> %x, <8 x i16> %y) {
; KNL-LABEL: variable_sra4:
; KNL:       # BB#0:
; KNL-NEXT:    vpmovzxwd {{.*#+}} ymm1 = xmm1[0],zero,xmm1[1],zero,xmm1[2],zero,xmm1[3],zero,xmm1[4],zero,xmm1[5],zero,xmm1[6],zero,xmm1[7],zero
; KNL-NEXT:    vpmovsxwd %xmm0, %ymm0
; KNL-NEXT:    vpsravd %ymm1, %ymm0, %ymm0
; KNL-NEXT:    vpmovdw %zmm0, %ymm0
; KNL-NEXT:    # kill: %XMM0<def> %XMM0<kill> %YMM0<kill>
; KNL-NEXT:    retq
;
; SKX-LABEL: variable_sra4:
; SKX:       # BB#0:
; SKX-NEXT:    vpsravw %xmm1, %xmm0, %xmm0
; SKX-NEXT:    retq
  %k = ashr <8 x i16> %x, %y
  ret <8 x i16> %k
}

define <16 x i32> @variable_sra01_load(<16 x i32> %x, <16 x i32>* %y) {
; CHECK-LABEL: variable_sra01_load:
; CHECK:       # BB#0:
; CHECK-NEXT:    vpsravd (%rdi), %zmm0, %zmm0
; CHECK-NEXT:    retq
  %y1 = load <16 x i32>, <16 x i32>* %y
  %k = ashr <16 x i32> %x, %y1
  ret <16 x i32> %k
}

define <16 x i32> @variable_shl1_load(<16 x i32> %x, <16 x i32>* %y) {
; CHECK-LABEL: variable_shl1_load:
; CHECK:       # BB#0:
; CHECK-NEXT:    vpsllvd (%rdi), %zmm0, %zmm0
; CHECK-NEXT:    retq
  %y1 = load <16 x i32>, <16 x i32>* %y
  %k = shl <16 x i32> %x, %y1
  ret <16 x i32> %k
}

define <16 x i32> @variable_srl0_load(<16 x i32> %x, <16 x i32>* %y) {
; CHECK-LABEL: variable_srl0_load:
; CHECK:       # BB#0:
; CHECK-NEXT:    vpsrlvd (%rdi), %zmm0, %zmm0
; CHECK-NEXT:    retq
  %y1 = load <16 x i32>, <16 x i32>* %y
  %k = lshr <16 x i32> %x, %y1
  ret <16 x i32> %k
}

define <8 x i64> @variable_srl3_load(<8 x i64> %x, <8 x i64>* %y) {
; CHECK-LABEL: variable_srl3_load:
; CHECK:       # BB#0:
; CHECK-NEXT:    vpsrlvq (%rdi), %zmm0, %zmm0
; CHECK-NEXT:    retq
  %y1 = load <8 x i64>, <8 x i64>* %y
  %k = lshr <8 x i64> %x, %y1
  ret <8 x i64> %k
}
