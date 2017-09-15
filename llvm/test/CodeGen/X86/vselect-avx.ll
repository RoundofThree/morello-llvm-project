; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-apple-macosx -mattr=+avx | FileCheck %s --check-prefix=AVX --check-prefix=AVX1
; RUN: llc < %s -mtriple=x86_64-apple-macosx -mattr=+avx2 | FileCheck %s --check-prefix=AVX --check-prefix=AVX2

target datalayout = "e-m:o-i64:64-f80:128-n8:16:32:64-S128"

; For this test we used to optimize the <i1 true, i1 false, i1 false, i1 true>
; mask into <i32 2147483648, i32 0, i32 0, i32 2147483648> because we thought
; we would lower that into a blend where only the high bit is relevant.
; However, since the whole mask is constant, this is simplified incorrectly
; by the generic code, because it was expecting -1 in place of 2147483648.
;
; The problem does not occur without AVX, because vselect of v4i32 is not legal
; nor custom.
;
; <rdar://problem/18675020>

define void @test(<4 x i16>* %a, <4 x i16>* %b) {
; AVX-LABEL: test:
; AVX:       ## BB#0: ## %body
; AVX-NEXT:    movq {{.*}}(%rip), %rax
; AVX-NEXT:    movq %rax, (%rdi)
; AVX-NEXT:    movq {{.*}}(%rip), %rax
; AVX-NEXT:    movq %rax, (%rsi)
; AVX-NEXT:    retq
body:
  %predphi = select <4 x i1> <i1 true, i1 false, i1 false, i1 true>, <4 x i16> <i16 -3, i16 545, i16 4385, i16 14807>, <4 x i16> <i16 123, i16 124, i16 125, i16 127>
  %predphi42 = select <4 x i1> <i1 true, i1 false, i1 false, i1 true>, <4 x i16> <i16 -1, i16 -1, i16 -1, i16 -1>, <4 x i16> zeroinitializer
  store <4 x i16> %predphi, <4 x i16>* %a, align 8
  store <4 x i16> %predphi42, <4 x i16>* %b, align 8
  ret void
}

; Improve code coverage.
;
; When shrinking the condition used into the select to match a blend, this
; test case exercises the path where the modified node is not the root
; of the condition.

define void @test2(double** %call1559, i64 %indvars.iv4198, <4 x i1> %tmp1895) {
; AVX1-LABEL: test2:
; AVX1:       ## BB#0: ## %bb
; AVX1-NEXT:    vpslld $31, %xmm0, %xmm0
; AVX1-NEXT:    vpsrad $31, %xmm0, %xmm0
; AVX1-NEXT:    vpmovsxdq %xmm0, %xmm1
; AVX1-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[2,3,0,1]
; AVX1-NEXT:    vpmovsxdq %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; AVX1-NEXT:    movq (%rdi,%rsi,8), %rax
; AVX1-NEXT:    vmovapd {{.*#+}} ymm1 = [5.000000e-01,5.000000e-01,5.000000e-01,5.000000e-01]
; AVX1-NEXT:    vblendvpd %ymm0, {{.*}}(%rip), %ymm1, %ymm0
; AVX1-NEXT:    vmovupd %ymm0, (%rax)
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test2:
; AVX2:       ## BB#0: ## %bb
; AVX2-NEXT:    vpslld $31, %xmm0, %xmm0
; AVX2-NEXT:    vpmovsxdq %xmm0, %ymm0
; AVX2-NEXT:    movq (%rdi,%rsi,8), %rax
; AVX2-NEXT:    vbroadcastsd {{.*#+}} ymm1 = [-0.5,-0.5,-0.5,-0.5]
; AVX2-NEXT:    vbroadcastsd {{.*#+}} ymm2 = [0.5,0.5,0.5,0.5]
; AVX2-NEXT:    vblendvpd %ymm0, %ymm1, %ymm2, %ymm0
; AVX2-NEXT:    vmovupd %ymm0, (%rax)
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
bb:
  %arrayidx1928 = getelementptr inbounds double*, double** %call1559, i64 %indvars.iv4198
  %tmp1888 = load double*, double** %arrayidx1928, align 8
  %predphi.v.v = select <4 x i1> %tmp1895, <4 x double> <double -5.000000e-01, double -5.000000e-01, double -5.000000e-01, double -5.000000e-01>, <4 x double> <double 5.000000e-01, double 5.000000e-01, double 5.000000e-01, double 5.000000e-01>
  %tmp1900 = bitcast double* %tmp1888 to <4 x double>*
  store <4 x double> %predphi.v.v, <4 x double>* %tmp1900, align 8
  ret void
}

; For this test, we used to optimized the conditional mask for the blend, i.e.,
; we shrunk some of its bits.
; However, this same mask was used in another select (%predphi31) that turned out
; to be optimized into a and. In that case, the conditional mask was wrong.
;
; Make sure that the and is fed by the original mask.
;
; <rdar://problem/18819506>

define void @test3(<4 x i32> %induction30, <4 x i16>* %tmp16, <4 x i16>* %tmp17,  <4 x i16> %tmp3, <4 x i16> %tmp12) {
; AVX1-LABEL: test3:
; AVX1:       ## BB#0:
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm3 = [1431655766,1431655766,1431655766,1431655766]
; AVX1-NEXT:    vpshufd {{.*#+}} xmm4 = xmm3[1,1,3,3]
; AVX1-NEXT:    vpshufd {{.*#+}} xmm5 = xmm0[1,1,3,3]
; AVX1-NEXT:    vpmuldq %xmm4, %xmm5, %xmm4
; AVX1-NEXT:    vpmuldq %xmm3, %xmm0, %xmm3
; AVX1-NEXT:    vpshufd {{.*#+}} xmm3 = xmm3[1,1,3,3]
; AVX1-NEXT:    vpblendw {{.*#+}} xmm3 = xmm3[0,1],xmm4[2,3],xmm3[4,5],xmm4[6,7]
; AVX1-NEXT:    vpsrld $31, %xmm3, %xmm4
; AVX1-NEXT:    vpaddd %xmm4, %xmm3, %xmm3
; AVX1-NEXT:    vpmulld {{.*}}(%rip), %xmm3, %xmm3
; AVX1-NEXT:    vpsubd %xmm3, %xmm0, %xmm0
; AVX1-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX1-NEXT:    vpcmpeqd %xmm3, %xmm0, %xmm0
; AVX1-NEXT:    vblendvps %xmm0, %xmm1, %xmm2, %xmm1
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm2 = [0,1,4,5,8,9,12,13,8,9,12,13,12,13,14,15]
; AVX1-NEXT:    vpshufb %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vmovq %xmm0, (%rdi)
; AVX1-NEXT:    vpshufb %xmm2, %xmm1, %xmm0
; AVX1-NEXT:    vmovq %xmm0, (%rsi)
; AVX1-NEXT:    retq
;
; AVX2-LABEL: test3:
; AVX2:       ## BB#0:
; AVX2-NEXT:    vpbroadcastd {{.*#+}} xmm3 = [1431655766,1431655766,1431655766,1431655766]
; AVX2-NEXT:    vpshufd {{.*#+}} xmm4 = xmm3[1,1,3,3]
; AVX2-NEXT:    vpshufd {{.*#+}} xmm5 = xmm0[1,1,3,3]
; AVX2-NEXT:    vpmuldq %xmm4, %xmm5, %xmm4
; AVX2-NEXT:    vpmuldq %xmm3, %xmm0, %xmm3
; AVX2-NEXT:    vpshufd {{.*#+}} xmm3 = xmm3[1,1,3,3]
; AVX2-NEXT:    vpblendd {{.*#+}} xmm3 = xmm3[0],xmm4[1],xmm3[2],xmm4[3]
; AVX2-NEXT:    vpsrld $31, %xmm3, %xmm4
; AVX2-NEXT:    vpaddd %xmm4, %xmm3, %xmm3
; AVX2-NEXT:    vpbroadcastd {{.*#+}} xmm4 = [3,3,3,3]
; AVX2-NEXT:    vpmulld %xmm4, %xmm3, %xmm3
; AVX2-NEXT:    vpsubd %xmm3, %xmm0, %xmm0
; AVX2-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX2-NEXT:    vpcmpeqd %xmm3, %xmm0, %xmm0
; AVX2-NEXT:    vblendvps %xmm0, %xmm1, %xmm2, %xmm1
; AVX2-NEXT:    vmovdqa {{.*#+}} xmm2 = [0,1,4,5,8,9,12,13,8,9,12,13,12,13,14,15]
; AVX2-NEXT:    vpshufb %xmm2, %xmm0, %xmm0
; AVX2-NEXT:    vmovq %xmm0, (%rdi)
; AVX2-NEXT:    vpshufb %xmm2, %xmm1, %xmm0
; AVX2-NEXT:    vmovq %xmm0, (%rsi)
; AVX2-NEXT:    retq
  %tmp6 = srem <4 x i32> %induction30, <i32 3, i32 3, i32 3, i32 3>
  %tmp7 = icmp eq <4 x i32> %tmp6, zeroinitializer
  %predphi = select <4 x i1> %tmp7, <4 x i16> %tmp3, <4 x i16> %tmp12
  %predphi31 = select <4 x i1> %tmp7, <4 x i16> <i16 -1, i16 -1, i16 -1, i16 -1>, <4 x i16> zeroinitializer

  store <4 x i16> %predphi31, <4 x i16>* %tmp16, align 8
  store <4 x i16> %predphi, <4 x i16>* %tmp17, align 8
 ret void
}

; We shouldn't try to lower this directly using VSELECT because we don't have
; vpblendvb in AVX1, only in AVX2. Instead, it should be expanded.

define <32 x i8> @PR22706(<32 x i1> %x) {
; AVX1-LABEL: PR22706:
; AVX1:       ## BB#0:
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX1-NEXT:    vpsllw $7, %xmm1, %xmm1
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm2 = [128,128,128,128,128,128,128,128,128,128,128,128,128,128,128,128]
; AVX1-NEXT:    vpand %xmm2, %xmm1, %xmm1
; AVX1-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX1-NEXT:    vpcmpgtb %xmm1, %xmm3, %xmm1
; AVX1-NEXT:    vmovdqa {{.*#+}} xmm4 = [2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2]
; AVX1-NEXT:    vpaddb %xmm4, %xmm1, %xmm1
; AVX1-NEXT:    vpsllw $7, %xmm0, %xmm0
; AVX1-NEXT:    vpand %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vpcmpgtb %xmm0, %xmm3, %xmm0
; AVX1-NEXT:    vpaddb %xmm4, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: PR22706:
; AVX2:       ## BB#0:
; AVX2-NEXT:    vpsllw $7, %ymm0, %ymm0
; AVX2-NEXT:    vpand {{.*}}(%rip), %ymm0, %ymm0
; AVX2-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX2-NEXT:    vpcmpgtb %ymm0, %ymm1, %ymm0
; AVX2-NEXT:    vpaddb {{.*}}(%rip), %ymm0, %ymm0
; AVX2-NEXT:    retq
  %tmp = select <32 x i1> %x, <32 x i8> <i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1>, <32 x i8> <i8 2, i8 2, i8 2, i8 2, i8 2, i8 2, i8 2, i8 2, i8 2, i8 2, i8 2, i8 2, i8 2, i8 2, i8 2, i8 2, i8 2, i8 2, i8 2, i8 2, i8 2, i8 2, i8 2, i8 2, i8 2, i8 2, i8 2, i8 2, i8 2, i8 2, i8 2, i8 2>
  ret <32 x i8> %tmp
}
