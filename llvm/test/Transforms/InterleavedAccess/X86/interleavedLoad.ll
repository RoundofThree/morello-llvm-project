; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -mtriple=x86_64-pc-linux -mattr=+avx2 -interleaved-access -S | FileCheck %s --check-prefix=AVX2
; RUN: opt < %s -mtriple=x86_64-pc-linux -mattr=+avx512f -mattr=+avx512bw -mattr=+avx512vl -interleaved-access -S | FileCheck %s --check-prefix=AVX2 --check-prefix=AVX512

define <32 x i8> @interleaved_load_vf32_i8_stride3(<96 x i8>* %ptr){
; AVX2-LABEL: @interleaved_load_vf32_i8_stride3(
; AVX2-NEXT:    [[TMP1:%.*]] = bitcast <96 x i8>* [[PTR:%.*]] to <16 x i8>*
; AVX2-NEXT:    [[TMP2:%.*]] = getelementptr <16 x i8>, <16 x i8>* [[TMP1]], i32 0
; AVX2-NEXT:    [[TMP3:%.*]] = load <16 x i8>, <16 x i8>* [[TMP2]]
; AVX2-NEXT:    [[TMP4:%.*]] = getelementptr <16 x i8>, <16 x i8>* [[TMP1]], i32 1
; AVX2-NEXT:    [[TMP5:%.*]] = load <16 x i8>, <16 x i8>* [[TMP4]]
; AVX2-NEXT:    [[TMP6:%.*]] = getelementptr <16 x i8>, <16 x i8>* [[TMP1]], i32 2
; AVX2-NEXT:    [[TMP7:%.*]] = load <16 x i8>, <16 x i8>* [[TMP6]]
; AVX2-NEXT:    [[TMP8:%.*]] = getelementptr <16 x i8>, <16 x i8>* [[TMP1]], i32 3
; AVX2-NEXT:    [[TMP9:%.*]] = load <16 x i8>, <16 x i8>* [[TMP8]]
; AVX2-NEXT:    [[TMP10:%.*]] = getelementptr <16 x i8>, <16 x i8>* [[TMP1]], i32 4
; AVX2-NEXT:    [[TMP11:%.*]] = load <16 x i8>, <16 x i8>* [[TMP10]]
; AVX2-NEXT:    [[TMP12:%.*]] = getelementptr <16 x i8>, <16 x i8>* [[TMP1]], i32 5
; AVX2-NEXT:    [[TMP13:%.*]] = load <16 x i8>, <16 x i8>* [[TMP12]]
; AVX2-NEXT:    [[TMP14:%.*]] = shufflevector <16 x i8> [[TMP3]], <16 x i8> [[TMP9]], <32 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31>
; AVX2-NEXT:    [[TMP15:%.*]] = shufflevector <16 x i8> [[TMP5]], <16 x i8> [[TMP11]], <32 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31>
; AVX2-NEXT:    [[TMP16:%.*]] = shufflevector <16 x i8> [[TMP7]], <16 x i8> [[TMP13]], <32 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31>
; AVX2-NEXT:    [[TMP17:%.*]] = shufflevector <32 x i8> [[TMP14]], <32 x i8> undef, <32 x i32> <i32 0, i32 3, i32 6, i32 9, i32 12, i32 15, i32 2, i32 5, i32 8, i32 11, i32 14, i32 1, i32 4, i32 7, i32 10, i32 13, i32 16, i32 19, i32 22, i32 25, i32 28, i32 31, i32 18, i32 21, i32 24, i32 27, i32 30, i32 17, i32 20, i32 23, i32 26, i32 29>
; AVX2-NEXT:    [[TMP18:%.*]] = shufflevector <32 x i8> [[TMP15]], <32 x i8> undef, <32 x i32> <i32 0, i32 3, i32 6, i32 9, i32 12, i32 15, i32 2, i32 5, i32 8, i32 11, i32 14, i32 1, i32 4, i32 7, i32 10, i32 13, i32 16, i32 19, i32 22, i32 25, i32 28, i32 31, i32 18, i32 21, i32 24, i32 27, i32 30, i32 17, i32 20, i32 23, i32 26, i32 29>
; AVX2-NEXT:    [[TMP19:%.*]] = shufflevector <32 x i8> [[TMP16]], <32 x i8> undef, <32 x i32> <i32 0, i32 3, i32 6, i32 9, i32 12, i32 15, i32 2, i32 5, i32 8, i32 11, i32 14, i32 1, i32 4, i32 7, i32 10, i32 13, i32 16, i32 19, i32 22, i32 25, i32 28, i32 31, i32 18, i32 21, i32 24, i32 27, i32 30, i32 17, i32 20, i32 23, i32 26, i32 29>
; AVX2-NEXT:    [[TMP20:%.*]] = shufflevector <32 x i8> [[TMP19]], <32 x i8> [[TMP17]], <32 x i32> <i32 11, i32 12, i32 13, i32 14, i32 15, i32 32, i32 33, i32 34, i32 35, i32 36, i32 37, i32 38, i32 39, i32 40, i32 41, i32 42, i32 27, i32 28, i32 29, i32 30, i32 31, i32 48, i32 49, i32 50, i32 51, i32 52, i32 53, i32 54, i32 55, i32 56, i32 57, i32 58>
; AVX2-NEXT:    [[TMP21:%.*]] = shufflevector <32 x i8> [[TMP17]], <32 x i8> [[TMP18]], <32 x i32> <i32 11, i32 12, i32 13, i32 14, i32 15, i32 32, i32 33, i32 34, i32 35, i32 36, i32 37, i32 38, i32 39, i32 40, i32 41, i32 42, i32 27, i32 28, i32 29, i32 30, i32 31, i32 48, i32 49, i32 50, i32 51, i32 52, i32 53, i32 54, i32 55, i32 56, i32 57, i32 58>
; AVX2-NEXT:    [[TMP22:%.*]] = shufflevector <32 x i8> [[TMP18]], <32 x i8> [[TMP19]], <32 x i32> <i32 11, i32 12, i32 13, i32 14, i32 15, i32 32, i32 33, i32 34, i32 35, i32 36, i32 37, i32 38, i32 39, i32 40, i32 41, i32 42, i32 27, i32 28, i32 29, i32 30, i32 31, i32 48, i32 49, i32 50, i32 51, i32 52, i32 53, i32 54, i32 55, i32 56, i32 57, i32 58>
; AVX2-NEXT:    [[TMP23:%.*]] = shufflevector <32 x i8> [[TMP21]], <32 x i8> [[TMP20]], <32 x i32> <i32 11, i32 12, i32 13, i32 14, i32 15, i32 32, i32 33, i32 34, i32 35, i32 36, i32 37, i32 38, i32 39, i32 40, i32 41, i32 42, i32 27, i32 28, i32 29, i32 30, i32 31, i32 48, i32 49, i32 50, i32 51, i32 52, i32 53, i32 54, i32 55, i32 56, i32 57, i32 58>
; AVX2-NEXT:    [[TMP24:%.*]] = shufflevector <32 x i8> [[TMP22]], <32 x i8> [[TMP21]], <32 x i32> <i32 11, i32 12, i32 13, i32 14, i32 15, i32 32, i32 33, i32 34, i32 35, i32 36, i32 37, i32 38, i32 39, i32 40, i32 41, i32 42, i32 27, i32 28, i32 29, i32 30, i32 31, i32 48, i32 49, i32 50, i32 51, i32 52, i32 53, i32 54, i32 55, i32 56, i32 57, i32 58>
; AVX2-NEXT:    [[TMP25:%.*]] = shufflevector <32 x i8> [[TMP20]], <32 x i8> [[TMP22]], <32 x i32> <i32 11, i32 12, i32 13, i32 14, i32 15, i32 32, i32 33, i32 34, i32 35, i32 36, i32 37, i32 38, i32 39, i32 40, i32 41, i32 42, i32 27, i32 28, i32 29, i32 30, i32 31, i32 48, i32 49, i32 50, i32 51, i32 52, i32 53, i32 54, i32 55, i32 56, i32 57, i32 58>
; AVX2-NEXT:    [[TMP26:%.*]] = shufflevector <32 x i8> [[TMP24]], <32 x i8> undef, <32 x i32> <i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 0, i32 1, i32 2, i32 3, i32 4, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31, i32 16, i32 17, i32 18, i32 19, i32 20>
; AVX2-NEXT:    [[TMP27:%.*]] = shufflevector <32 x i8> [[TMP23]], <32 x i8> undef, <32 x i32> <i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25>
; AVX2-NEXT:    [[ADD1:%.*]] = add <32 x i8> [[TMP27]], [[TMP26]]
; AVX2-NEXT:    [[ADD2:%.*]] = add <32 x i8> [[TMP25]], [[ADD1]]
; AVX2-NEXT:    ret <32 x i8> [[ADD2]]
;
  %wide.vec = load <96 x i8>, <96 x i8>* %ptr
  %v1 = shufflevector <96 x i8> %wide.vec, <96 x i8> undef,<32 x i32> <i32 0,i32 3,i32 6,i32 9,i32 12,i32 15,i32 18,i32 21,i32 24,i32 27,i32 30,i32 33,i32 36,i32 39,i32 42,i32 45,i32 48,i32 51,i32 54,i32 57,i32 60,i32 63,i32 66,i32 69,i32 72,i32 75,i32 78,i32 81,i32 84,i32 87,i32 90,i32 93>
  %v2 = shufflevector <96 x i8> %wide.vec, <96 x i8> undef,<32 x i32> <i32 1,i32 4,i32 7,i32 10,i32 13,i32 16,i32 19,i32 22,i32 25,i32 28,i32 31,i32 34,i32 37,i32 40,i32 43,i32 46,i32 49,i32 52,i32 55,i32 58,i32 61,i32 64,i32 67,i32 70,i32 73,i32 76,i32 79,i32 82,i32 85,i32 88,i32 91,i32 94>
  %v3 = shufflevector <96 x i8> %wide.vec, <96 x i8> undef,<32 x i32> <i32 2,i32 5,i32 8,i32 11,i32 14,i32 17,i32 20,i32 23,i32 26,i32 29,i32 32,i32 35,i32 38,i32 41,i32 44,i32 47,i32 50,i32 53,i32 56,i32 59,i32 62,i32 65,i32 68,i32 71,i32 74,i32 77,i32 80,i32 83,i32 86,i32 89,i32 92,i32 95>
  %add1 = add <32 x i8> %v1, %v2
  %add2 = add <32 x i8> %v3, %add1
  ret <32 x i8> %add2
}

define <16 x i8> @interleaved_load_vf16_i8_stride3(<48 x i8>* %ptr){
; AVX2-LABEL: @interleaved_load_vf16_i8_stride3(
; AVX2-NEXT:    [[TMP1:%.*]] = bitcast <48 x i8>* [[PTR:%.*]] to <16 x i8>*
; AVX2-NEXT:    [[TMP2:%.*]] = getelementptr <16 x i8>, <16 x i8>* [[TMP1]], i32 0
; AVX2-NEXT:    [[TMP3:%.*]] = load <16 x i8>, <16 x i8>* [[TMP2]]
; AVX2-NEXT:    [[TMP4:%.*]] = getelementptr <16 x i8>, <16 x i8>* [[TMP1]], i32 1
; AVX2-NEXT:    [[TMP5:%.*]] = load <16 x i8>, <16 x i8>* [[TMP4]]
; AVX2-NEXT:    [[TMP6:%.*]] = getelementptr <16 x i8>, <16 x i8>* [[TMP1]], i32 2
; AVX2-NEXT:    [[TMP7:%.*]] = load <16 x i8>, <16 x i8>* [[TMP6]]
; AVX2-NEXT:    [[TMP8:%.*]] = shufflevector <16 x i8> [[TMP3]], <16 x i8> undef, <16 x i32> <i32 0, i32 3, i32 6, i32 9, i32 12, i32 15, i32 2, i32 5, i32 8, i32 11, i32 14, i32 1, i32 4, i32 7, i32 10, i32 13>
; AVX2-NEXT:    [[TMP9:%.*]] = shufflevector <16 x i8> [[TMP5]], <16 x i8> undef, <16 x i32> <i32 0, i32 3, i32 6, i32 9, i32 12, i32 15, i32 2, i32 5, i32 8, i32 11, i32 14, i32 1, i32 4, i32 7, i32 10, i32 13>
; AVX2-NEXT:    [[TMP10:%.*]] = shufflevector <16 x i8> [[TMP7]], <16 x i8> undef, <16 x i32> <i32 0, i32 3, i32 6, i32 9, i32 12, i32 15, i32 2, i32 5, i32 8, i32 11, i32 14, i32 1, i32 4, i32 7, i32 10, i32 13>
; AVX2-NEXT:    [[TMP11:%.*]] = shufflevector <16 x i8> [[TMP10]], <16 x i8> [[TMP8]], <16 x i32> <i32 11, i32 12, i32 13, i32 14, i32 15, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26>
; AVX2-NEXT:    [[TMP12:%.*]] = shufflevector <16 x i8> [[TMP8]], <16 x i8> [[TMP9]], <16 x i32> <i32 11, i32 12, i32 13, i32 14, i32 15, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26>
; AVX2-NEXT:    [[TMP13:%.*]] = shufflevector <16 x i8> [[TMP9]], <16 x i8> [[TMP10]], <16 x i32> <i32 11, i32 12, i32 13, i32 14, i32 15, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26>
; AVX2-NEXT:    [[TMP14:%.*]] = shufflevector <16 x i8> [[TMP12]], <16 x i8> [[TMP11]], <16 x i32> <i32 11, i32 12, i32 13, i32 14, i32 15, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26>
; AVX2-NEXT:    [[TMP15:%.*]] = shufflevector <16 x i8> [[TMP13]], <16 x i8> [[TMP12]], <16 x i32> <i32 11, i32 12, i32 13, i32 14, i32 15, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26>
; AVX2-NEXT:    [[TMP16:%.*]] = shufflevector <16 x i8> [[TMP11]], <16 x i8> [[TMP13]], <16 x i32> <i32 11, i32 12, i32 13, i32 14, i32 15, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26>
; AVX2-NEXT:    [[TMP17:%.*]] = shufflevector <16 x i8> [[TMP15]], <16 x i8> undef, <16 x i32> <i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 0, i32 1, i32 2, i32 3, i32 4>
; AVX2-NEXT:    [[TMP18:%.*]] = shufflevector <16 x i8> [[TMP14]], <16 x i8> undef, <16 x i32> <i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9>
; AVX2-NEXT:    [[ADD1:%.*]] = add <16 x i8> [[TMP18]], [[TMP17]]
; AVX2-NEXT:    [[ADD2:%.*]] = add <16 x i8> [[TMP16]], [[ADD1]]
; AVX2-NEXT:    ret <16 x i8> [[ADD2]]
;
  %wide.vec = load <48 x i8>, <48 x i8>* %ptr
  %v1 = shufflevector <48 x i8> %wide.vec, <48 x i8> undef,<16 x i32> <i32 0,i32 3,i32 6,i32 9,i32 12,i32 15,i32 18,i32 21,i32 24,i32 27,i32 30,i32 33,i32 36,i32 39,i32 42 ,i32 45>
  %v2 = shufflevector <48 x i8> %wide.vec, <48 x i8> undef,<16 x i32> <i32 1,i32 4,i32 7,i32 10,i32 13,i32 16,i32 19,i32 22,i32 25,i32 28,i32 31,i32 34,i32 37,i32 40,i32 43,i32 46>
  %v3 = shufflevector <48 x i8> %wide.vec, <48 x i8> undef,<16 x i32> <i32 2,i32 5,i32 8,i32 11,i32 14,i32 17,i32 20,i32 23,i32 26,i32 29,i32 32,i32 35,i32 38,i32 41,i32 44,i32 47>
  %add1 = add <16 x i8> %v1, %v2
  %add2 = add <16 x i8> %v3, %add1
  ret <16 x i8> %add2
}

define <8 x i8> @interleaved_load_vf8_i8_stride3(<24 x i8>* %ptr){
; AVX2-LABEL: @interleaved_load_vf8_i8_stride3(
; AVX2-NEXT:    [[WIDE_VEC:%.*]] = load <24 x i8>, <24 x i8>* [[PTR:%.*]]
; AVX2-NEXT:    [[V1:%.*]] = shufflevector <24 x i8> [[WIDE_VEC]], <24 x i8> undef, <8 x i32> <i32 0, i32 3, i32 6, i32 9, i32 12, i32 15, i32 18, i32 21>
; AVX2-NEXT:    [[V2:%.*]] = shufflevector <24 x i8> [[WIDE_VEC]], <24 x i8> undef, <8 x i32> <i32 1, i32 4, i32 7, i32 10, i32 13, i32 16, i32 19, i32 22>
; AVX2-NEXT:    [[V3:%.*]] = shufflevector <24 x i8> [[WIDE_VEC]], <24 x i8> undef, <8 x i32> <i32 2, i32 5, i32 8, i32 11, i32 14, i32 17, i32 20, i32 23>
; AVX2-NEXT:    [[ADD1:%.*]] = add <8 x i8> [[V1]], [[V2]]
; AVX2-NEXT:    [[ADD2:%.*]] = add <8 x i8> [[V3]], [[ADD1]]
; AVX2-NEXT:    ret <8 x i8> [[ADD2]]
;
  %wide.vec = load <24 x i8>, <24 x i8>* %ptr
  %v1 = shufflevector <24 x i8> %wide.vec, <24 x i8> undef,<8 x i32> <i32 0,i32 3,i32 6,i32  9,i32 12,i32 15,i32 18,i32 21>
  %v2 = shufflevector <24 x i8> %wide.vec, <24 x i8> undef,<8 x i32> <i32 1,i32 4,i32 7,i32 10,i32 13,i32 16,i32 19,i32 22>
  %v3 = shufflevector <24 x i8> %wide.vec, <24 x i8> undef,<8 x i32> <i32 2,i32 5,i32 8,i32 11,i32 14,i32 17,i32 20,i32 23>
  %add1 = add <8 x i8> %v1, %v2
  %add2 = add <8 x i8> %v3, %add1
  ret <8 x i8> %add2
}


define <64 x i8> @interleaved_load_vf64_i8_stride3(<192 x i8>* %ptr){
; AVX2-LABEL: @interleaved_load_vf64_i8_stride3(
; AVX2-NEXT:    [[WIDE_VEC:%.*]] = load <192 x i8>, <192 x i8>* [[PTR:%.*]], align 1
; AVX2-NEXT:    [[V1:%.*]] = shufflevector <192 x i8> [[WIDE_VEC]], <192 x i8> undef, <64 x i32> <i32 0, i32 3, i32 6, i32 9, i32 12, i32 15, i32 18, i32 21, i32 24, i32 27, i32 30, i32 33, i32 36, i32 39, i32 42, i32 45, i32 48, i32 51, i32 54, i32 57, i32 60, i32 63, i32 66, i32 69, i32 72, i32 75, i32 78, i32 81, i32 84, i32 87, i32 90, i32 93, i32 96, i32 99, i32 102, i32 105, i32 108, i32 111, i32 114, i32 117, i32 120, i32 123, i32 126, i32 129, i32 132, i32 135, i32 138, i32 141, i32 144, i32 147, i32 150, i32 153, i32 156, i32 159, i32 162, i32 165, i32 168, i32 171, i32 174, i32 177, i32 180, i32 183, i32 186, i32 189>
; AVX2-NEXT:    [[V2:%.*]] = shufflevector <192 x i8> [[WIDE_VEC]], <192 x i8> undef, <64 x i32> <i32 1, i32 4, i32 7, i32 10, i32 13, i32 16, i32 19, i32 22, i32 25, i32 28, i32 31, i32 34, i32 37, i32 40, i32 43, i32 46, i32 49, i32 52, i32 55, i32 58, i32 61, i32 64, i32 67, i32 70, i32 73, i32 76, i32 79, i32 82, i32 85, i32 88, i32 91, i32 94, i32 97, i32 100, i32 103, i32 106, i32 109, i32 112, i32 115, i32 118, i32 121, i32 124, i32 127, i32 130, i32 133, i32 136, i32 139, i32 142, i32 145, i32 148, i32 151, i32 154, i32 157, i32 160, i32 163, i32 166, i32 169, i32 172, i32 175, i32 178, i32 181, i32 184, i32 187, i32 190>
; AVX2-NEXT:    [[V3:%.*]] = shufflevector <192 x i8> [[WIDE_VEC]], <192 x i8> undef, <64 x i32> <i32 2, i32 5, i32 8, i32 11, i32 14, i32 17, i32 20, i32 23, i32 26, i32 29, i32 32, i32 35, i32 38, i32 41, i32 44, i32 47, i32 50, i32 53, i32 56, i32 59, i32 62, i32 65, i32 68, i32 71, i32 74, i32 77, i32 80, i32 83, i32 86, i32 89, i32 92, i32 95, i32 98, i32 101, i32 104, i32 107, i32 110, i32 113, i32 116, i32 119, i32 122, i32 125, i32 128, i32 131, i32 134, i32 137, i32 140, i32 143, i32 146, i32 149, i32 152, i32 155, i32 158, i32 161, i32 164, i32 167, i32 170, i32 173, i32 176, i32 179, i32 182, i32 185, i32 188, i32 191>
; AVX2-NEXT:    [[ADD1:%.*]] = add <64 x i8> [[V1]], [[V2]]
; AVX2-NEXT:    [[ADD2:%.*]] = add <64 x i8> [[V3]], [[ADD1]]
; AVX2-NEXT:    ret <64 x i8> [[ADD2]]
;
%wide.vec = load <192 x i8>, <192 x i8>* %ptr, align 1
%v1 = shufflevector <192 x i8> %wide.vec, <192 x i8> undef, <64 x i32> <i32 0, i32 3, i32 6, i32 9, i32 12, i32 15, i32 18, i32 21, i32 24, i32 27, i32 30, i32 33, i32 36, i32 39, i32 42, i32 45, i32 48, i32 51, i32 54, i32 57, i32 60, i32 63, i32 66, i32 69, i32 72, i32 75, i32 78, i32 81, i32 84, i32 87, i32 90, i32 93, i32 96, i32 99, i32 102, i32 105, i32 108, i32 111, i32 114, i32 117, i32 120, i32 123, i32 126, i32 129, i32 132, i32 135, i32 138, i32 141, i32 144, i32 147, i32 150, i32 153, i32 156, i32 159, i32 162, i32 165, i32 168, i32 171, i32 174, i32 177, i32 180, i32 183, i32 186, i32 189>
%v2 = shufflevector <192 x i8> %wide.vec, <192 x i8> undef, <64 x i32> <i32 1, i32 4, i32 7, i32 10, i32 13, i32 16, i32 19, i32 22, i32 25, i32 28, i32 31, i32 34, i32 37, i32 40, i32 43, i32 46, i32 49, i32 52, i32 55, i32 58, i32 61, i32 64, i32 67, i32 70, i32 73, i32 76, i32 79, i32 82, i32 85, i32 88, i32 91, i32 94, i32 97, i32 100, i32 103, i32 106, i32 109, i32 112, i32 115, i32 118, i32 121, i32 124, i32 127, i32 130, i32 133, i32 136, i32 139, i32 142, i32 145, i32 148, i32 151, i32 154, i32 157, i32 160, i32 163, i32 166, i32 169, i32 172, i32 175, i32 178, i32 181, i32 184, i32 187, i32 190>
%v3 = shufflevector <192 x i8> %wide.vec, <192 x i8> undef, <64 x i32> <i32 2, i32 5, i32 8, i32 11, i32 14, i32 17, i32 20, i32 23, i32 26, i32 29, i32 32, i32 35, i32 38, i32 41, i32 44, i32 47, i32 50, i32 53, i32 56, i32 59, i32 62, i32 65, i32 68, i32 71, i32 74, i32 77, i32 80, i32 83, i32 86, i32 89, i32 92, i32 95, i32 98, i32 101, i32 104, i32 107, i32 110, i32 113, i32 116, i32 119, i32 122, i32 125, i32 128, i32 131, i32 134, i32 137, i32 140, i32 143, i32 146, i32 149, i32 152, i32 155, i32 158, i32 161, i32 164, i32 167, i32 170, i32 173, i32 176, i32 179, i32 182, i32 185, i32 188, i32 191>
%add1 = add <64 x i8> %v1, %v2
%add2 = add <64 x i8> %v3, %add1
ret <64 x i8> %add2
}
