; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx | FileCheck %s --check-prefixes=AVX,AVXNOVLBW,AVX1
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx2 | FileCheck %s --check-prefixes=AVX,AVXNOVLBW,INT256,AVX2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512f | FileCheck %s --check-prefixes=AVX,AVXNOVLBW,INT256,AVX512,AVX512F
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512f,+avx512vl | FileCheck %s --check-prefixes=AVX,AVXNOVLBW,INT256,AVX512,AVX512VL
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512bw,+avx512vl | FileCheck %s --check-prefixes=AVX,INT256,AVX512,AVX512VLBW
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512bw,+avx512vl,+avx512vbmi | FileCheck %s --check-prefixes=AVX,INT256,AVX512,AVX512VLBW,VBMI

define <4 x i64> @var_shuffle_v4i64(<4 x i64> %v, <4 x i64> %indices) nounwind {
; AVX1-LABEL: var_shuffle_v4i64:
; AVX1:       # BB#0:
; AVX1-NEXT:    pushq %rbp
; AVX1-NEXT:    movq %rsp, %rbp
; AVX1-NEXT:    andq $-32, %rsp
; AVX1-NEXT:    subq $64, %rsp
; AVX1-NEXT:    vmovq %xmm1, %rax
; AVX1-NEXT:    andl $3, %eax
; AVX1-NEXT:    vpextrq $1, %xmm1, %rcx
; AVX1-NEXT:    andl $3, %ecx
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm1
; AVX1-NEXT:    vmovq %xmm1, %rdx
; AVX1-NEXT:    andl $3, %edx
; AVX1-NEXT:    vpextrq $1, %xmm1, %rsi
; AVX1-NEXT:    andl $3, %esi
; AVX1-NEXT:    vmovaps %ymm0, (%rsp)
; AVX1-NEXT:    vmovsd {{.*#+}} xmm0 = mem[0],zero
; AVX1-NEXT:    vmovsd {{.*#+}} xmm1 = mem[0],zero
; AVX1-NEXT:    vmovlhps {{.*#+}} xmm0 = xmm1[0],xmm0[0]
; AVX1-NEXT:    vmovsd {{.*#+}} xmm1 = mem[0],zero
; AVX1-NEXT:    vmovsd {{.*#+}} xmm2 = mem[0],zero
; AVX1-NEXT:    vmovlhps {{.*#+}} xmm1 = xmm2[0],xmm1[0]
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; AVX1-NEXT:    movq %rbp, %rsp
; AVX1-NEXT:    popq %rbp
; AVX1-NEXT:    retq
;
; INT256-LABEL: var_shuffle_v4i64:
; INT256:       # BB#0:
; INT256-NEXT:    pushq %rbp
; INT256-NEXT:    movq %rsp, %rbp
; INT256-NEXT:    andq $-32, %rsp
; INT256-NEXT:    subq $64, %rsp
; INT256-NEXT:    vmovq %xmm1, %rax
; INT256-NEXT:    andl $3, %eax
; INT256-NEXT:    vpextrq $1, %xmm1, %rcx
; INT256-NEXT:    andl $3, %ecx
; INT256-NEXT:    vextracti128 $1, %ymm1, %xmm1
; INT256-NEXT:    vmovq %xmm1, %rdx
; INT256-NEXT:    andl $3, %edx
; INT256-NEXT:    vpextrq $1, %xmm1, %rsi
; INT256-NEXT:    andl $3, %esi
; INT256-NEXT:    vmovaps %ymm0, (%rsp)
; INT256-NEXT:    vmovsd {{.*#+}} xmm0 = mem[0],zero
; INT256-NEXT:    vmovsd {{.*#+}} xmm1 = mem[0],zero
; INT256-NEXT:    vmovlhps {{.*#+}} xmm0 = xmm1[0],xmm0[0]
; INT256-NEXT:    vmovsd {{.*#+}} xmm1 = mem[0],zero
; INT256-NEXT:    vmovsd {{.*#+}} xmm2 = mem[0],zero
; INT256-NEXT:    vmovlhps {{.*#+}} xmm1 = xmm2[0],xmm1[0]
; INT256-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; INT256-NEXT:    movq %rbp, %rsp
; INT256-NEXT:    popq %rbp
; INT256-NEXT:    retq
  %index0 = extractelement <4 x i64> %indices, i32 0
  %index1 = extractelement <4 x i64> %indices, i32 1
  %index2 = extractelement <4 x i64> %indices, i32 2
  %index3 = extractelement <4 x i64> %indices, i32 3
  %v0 = extractelement <4 x i64> %v, i64 %index0
  %v1 = extractelement <4 x i64> %v, i64 %index1
  %v2 = extractelement <4 x i64> %v, i64 %index2
  %v3 = extractelement <4 x i64> %v, i64 %index3
  %ret0 = insertelement <4 x i64> undef, i64 %v0, i32 0
  %ret1 = insertelement <4 x i64> %ret0, i64 %v1, i32 1
  %ret2 = insertelement <4 x i64> %ret1, i64 %v2, i32 2
  %ret3 = insertelement <4 x i64> %ret2, i64 %v3, i32 3
  ret <4 x i64> %ret3
}

define <8 x i32> @var_shuffle_v8i32(<8 x i32> %v, <8 x i32> %indices) nounwind {
; AVX1-LABEL: var_shuffle_v8i32:
; AVX1:       # BB#0:
; AVX1-NEXT:    pushq %rbp
; AVX1-NEXT:    movq %rsp, %rbp
; AVX1-NEXT:    andq $-32, %rsp
; AVX1-NEXT:    subq $64, %rsp
; AVX1-NEXT:    vpextrq $1, %xmm1, %r8
; AVX1-NEXT:    movq %r8, %rcx
; AVX1-NEXT:    shrq $30, %rcx
; AVX1-NEXT:    vmovq %xmm1, %r9
; AVX1-NEXT:    movq %r9, %rsi
; AVX1-NEXT:    shrq $30, %rsi
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm1
; AVX1-NEXT:    vpextrq $1, %xmm1, %r10
; AVX1-NEXT:    movq %r10, %rdi
; AVX1-NEXT:    shrq $30, %rdi
; AVX1-NEXT:    vmovq %xmm1, %rax
; AVX1-NEXT:    movq %rax, %rdx
; AVX1-NEXT:    shrq $30, %rdx
; AVX1-NEXT:    vmovaps %ymm0, (%rsp)
; AVX1-NEXT:    andl $7, %r9d
; AVX1-NEXT:    andl $28, %esi
; AVX1-NEXT:    andl $7, %r8d
; AVX1-NEXT:    andl $28, %ecx
; AVX1-NEXT:    andl $7, %eax
; AVX1-NEXT:    andl $28, %edx
; AVX1-NEXT:    andl $7, %r10d
; AVX1-NEXT:    andl $28, %edi
; AVX1-NEXT:    vmovd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; AVX1-NEXT:    movq %rsp, %rax
; AVX1-NEXT:    vpinsrd $1, (%rdx,%rax), %xmm0, %xmm0
; AVX1-NEXT:    vpinsrd $2, (%rsp,%r10,4), %xmm0, %xmm0
; AVX1-NEXT:    vpinsrd $3, (%rdi,%rax), %xmm0, %xmm0
; AVX1-NEXT:    vmovd {{.*#+}} xmm1 = mem[0],zero,zero,zero
; AVX1-NEXT:    vpinsrd $1, (%rsi,%rax), %xmm1, %xmm1
; AVX1-NEXT:    vpinsrd $2, (%rsp,%r8,4), %xmm1, %xmm1
; AVX1-NEXT:    vpinsrd $3, (%rcx,%rax), %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; AVX1-NEXT:    movq %rbp, %rsp
; AVX1-NEXT:    popq %rbp
; AVX1-NEXT:    retq
;
; INT256-LABEL: var_shuffle_v8i32:
; INT256:       # BB#0:
; INT256-NEXT:    pushq %rbp
; INT256-NEXT:    movq %rsp, %rbp
; INT256-NEXT:    andq $-32, %rsp
; INT256-NEXT:    subq $64, %rsp
; INT256-NEXT:    vpextrq $1, %xmm1, %r8
; INT256-NEXT:    movq %r8, %rcx
; INT256-NEXT:    shrq $30, %rcx
; INT256-NEXT:    vmovq %xmm1, %r9
; INT256-NEXT:    movq %r9, %rsi
; INT256-NEXT:    shrq $30, %rsi
; INT256-NEXT:    vextracti128 $1, %ymm1, %xmm1
; INT256-NEXT:    vpextrq $1, %xmm1, %r10
; INT256-NEXT:    movq %r10, %rdi
; INT256-NEXT:    shrq $30, %rdi
; INT256-NEXT:    vmovq %xmm1, %rax
; INT256-NEXT:    movq %rax, %rdx
; INT256-NEXT:    shrq $30, %rdx
; INT256-NEXT:    vmovaps %ymm0, (%rsp)
; INT256-NEXT:    andl $7, %r9d
; INT256-NEXT:    andl $28, %esi
; INT256-NEXT:    andl $7, %r8d
; INT256-NEXT:    andl $28, %ecx
; INT256-NEXT:    andl $7, %eax
; INT256-NEXT:    andl $28, %edx
; INT256-NEXT:    andl $7, %r10d
; INT256-NEXT:    andl $28, %edi
; INT256-NEXT:    vmovd {{.*#+}} xmm0 = mem[0],zero,zero,zero
; INT256-NEXT:    movq %rsp, %rax
; INT256-NEXT:    vpinsrd $1, (%rdx,%rax), %xmm0, %xmm0
; INT256-NEXT:    vpinsrd $2, (%rsp,%r10,4), %xmm0, %xmm0
; INT256-NEXT:    vpinsrd $3, (%rdi,%rax), %xmm0, %xmm0
; INT256-NEXT:    vmovd {{.*#+}} xmm1 = mem[0],zero,zero,zero
; INT256-NEXT:    vpinsrd $1, (%rsi,%rax), %xmm1, %xmm1
; INT256-NEXT:    vpinsrd $2, (%rsp,%r8,4), %xmm1, %xmm1
; INT256-NEXT:    vpinsrd $3, (%rcx,%rax), %xmm1, %xmm1
; INT256-NEXT:    vinserti128 $1, %xmm0, %ymm1, %ymm0
; INT256-NEXT:    movq %rbp, %rsp
; INT256-NEXT:    popq %rbp
; INT256-NEXT:    retq
  %index0 = extractelement <8 x i32> %indices, i32 0
  %index1 = extractelement <8 x i32> %indices, i32 1
  %index2 = extractelement <8 x i32> %indices, i32 2
  %index3 = extractelement <8 x i32> %indices, i32 3
  %index4 = extractelement <8 x i32> %indices, i32 4
  %index5 = extractelement <8 x i32> %indices, i32 5
  %index6 = extractelement <8 x i32> %indices, i32 6
  %index7 = extractelement <8 x i32> %indices, i32 7
  %v0 = extractelement <8 x i32> %v, i32 %index0
  %v1 = extractelement <8 x i32> %v, i32 %index1
  %v2 = extractelement <8 x i32> %v, i32 %index2
  %v3 = extractelement <8 x i32> %v, i32 %index3
  %v4 = extractelement <8 x i32> %v, i32 %index4
  %v5 = extractelement <8 x i32> %v, i32 %index5
  %v6 = extractelement <8 x i32> %v, i32 %index6
  %v7 = extractelement <8 x i32> %v, i32 %index7
  %ret0 = insertelement <8 x i32> undef, i32 %v0, i32 0
  %ret1 = insertelement <8 x i32> %ret0, i32 %v1, i32 1
  %ret2 = insertelement <8 x i32> %ret1, i32 %v2, i32 2
  %ret3 = insertelement <8 x i32> %ret2, i32 %v3, i32 3
  %ret4 = insertelement <8 x i32> %ret3, i32 %v4, i32 4
  %ret5 = insertelement <8 x i32> %ret4, i32 %v5, i32 5
  %ret6 = insertelement <8 x i32> %ret5, i32 %v6, i32 6
  %ret7 = insertelement <8 x i32> %ret6, i32 %v7, i32 7
  ret <8 x i32> %ret7
}

define <16 x i16> @var_shuffle_v16i16(<16 x i16> %v, <16 x i16> %indices) nounwind {
; AVX1-LABEL: var_shuffle_v16i16:
; AVX1:       # BB#0:
; AVX1-NEXT:    pushq %rbp
; AVX1-NEXT:    movq %rsp, %rbp
; AVX1-NEXT:    andq $-32, %rsp
; AVX1-NEXT:    subq $64, %rsp
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vmovd %xmm2, %eax
; AVX1-NEXT:    vmovaps %ymm0, (%rsp)
; AVX1-NEXT:    andl $15, %eax
; AVX1-NEXT:    movzwl (%rsp,%rax,2), %eax
; AVX1-NEXT:    vmovd %eax, %xmm0
; AVX1-NEXT:    vpextrw $1, %xmm2, %eax
; AVX1-NEXT:    andl $15, %eax
; AVX1-NEXT:    vpinsrw $1, (%rsp,%rax,2), %xmm0, %xmm0
; AVX1-NEXT:    vpextrw $2, %xmm2, %eax
; AVX1-NEXT:    andl $15, %eax
; AVX1-NEXT:    vpinsrw $2, (%rsp,%rax,2), %xmm0, %xmm0
; AVX1-NEXT:    vpextrw $3, %xmm2, %eax
; AVX1-NEXT:    andl $15, %eax
; AVX1-NEXT:    vpinsrw $3, (%rsp,%rax,2), %xmm0, %xmm0
; AVX1-NEXT:    vpextrw $4, %xmm2, %eax
; AVX1-NEXT:    andl $15, %eax
; AVX1-NEXT:    vpinsrw $4, (%rsp,%rax,2), %xmm0, %xmm0
; AVX1-NEXT:    vpextrw $5, %xmm2, %eax
; AVX1-NEXT:    andl $15, %eax
; AVX1-NEXT:    vpinsrw $5, (%rsp,%rax,2), %xmm0, %xmm0
; AVX1-NEXT:    vpextrw $6, %xmm2, %eax
; AVX1-NEXT:    andl $15, %eax
; AVX1-NEXT:    vpinsrw $6, (%rsp,%rax,2), %xmm0, %xmm0
; AVX1-NEXT:    vpextrw $7, %xmm2, %eax
; AVX1-NEXT:    andl $15, %eax
; AVX1-NEXT:    vpinsrw $7, (%rsp,%rax,2), %xmm0, %xmm0
; AVX1-NEXT:    vmovd %xmm1, %eax
; AVX1-NEXT:    andl $15, %eax
; AVX1-NEXT:    movzwl (%rsp,%rax,2), %eax
; AVX1-NEXT:    vmovd %eax, %xmm2
; AVX1-NEXT:    vpextrw $1, %xmm1, %eax
; AVX1-NEXT:    andl $15, %eax
; AVX1-NEXT:    vpinsrw $1, (%rsp,%rax,2), %xmm2, %xmm2
; AVX1-NEXT:    vpextrw $2, %xmm1, %eax
; AVX1-NEXT:    andl $15, %eax
; AVX1-NEXT:    vpinsrw $2, (%rsp,%rax,2), %xmm2, %xmm2
; AVX1-NEXT:    vpextrw $3, %xmm1, %eax
; AVX1-NEXT:    andl $15, %eax
; AVX1-NEXT:    vpinsrw $3, (%rsp,%rax,2), %xmm2, %xmm2
; AVX1-NEXT:    vpextrw $4, %xmm1, %eax
; AVX1-NEXT:    andl $15, %eax
; AVX1-NEXT:    vpinsrw $4, (%rsp,%rax,2), %xmm2, %xmm2
; AVX1-NEXT:    vpextrw $5, %xmm1, %eax
; AVX1-NEXT:    andl $15, %eax
; AVX1-NEXT:    vpinsrw $5, (%rsp,%rax,2), %xmm2, %xmm2
; AVX1-NEXT:    vpextrw $6, %xmm1, %eax
; AVX1-NEXT:    andl $15, %eax
; AVX1-NEXT:    vpinsrw $6, (%rsp,%rax,2), %xmm2, %xmm2
; AVX1-NEXT:    vpextrw $7, %xmm1, %eax
; AVX1-NEXT:    andl $15, %eax
; AVX1-NEXT:    vpinsrw $7, (%rsp,%rax,2), %xmm2, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; AVX1-NEXT:    movq %rbp, %rsp
; AVX1-NEXT:    popq %rbp
; AVX1-NEXT:    retq
;
; INT256-LABEL: var_shuffle_v16i16:
; INT256:       # BB#0:
; INT256-NEXT:    pushq %rbp
; INT256-NEXT:    movq %rsp, %rbp
; INT256-NEXT:    andq $-32, %rsp
; INT256-NEXT:    subq $64, %rsp
; INT256-NEXT:    vextracti128 $1, %ymm1, %xmm2
; INT256-NEXT:    vmovd %xmm2, %eax
; INT256-NEXT:    vmovaps %ymm0, (%rsp)
; INT256-NEXT:    andl $15, %eax
; INT256-NEXT:    movzwl (%rsp,%rax,2), %eax
; INT256-NEXT:    vmovd %eax, %xmm0
; INT256-NEXT:    vpextrw $1, %xmm2, %eax
; INT256-NEXT:    andl $15, %eax
; INT256-NEXT:    vpinsrw $1, (%rsp,%rax,2), %xmm0, %xmm0
; INT256-NEXT:    vpextrw $2, %xmm2, %eax
; INT256-NEXT:    andl $15, %eax
; INT256-NEXT:    vpinsrw $2, (%rsp,%rax,2), %xmm0, %xmm0
; INT256-NEXT:    vpextrw $3, %xmm2, %eax
; INT256-NEXT:    andl $15, %eax
; INT256-NEXT:    vpinsrw $3, (%rsp,%rax,2), %xmm0, %xmm0
; INT256-NEXT:    vpextrw $4, %xmm2, %eax
; INT256-NEXT:    andl $15, %eax
; INT256-NEXT:    vpinsrw $4, (%rsp,%rax,2), %xmm0, %xmm0
; INT256-NEXT:    vpextrw $5, %xmm2, %eax
; INT256-NEXT:    andl $15, %eax
; INT256-NEXT:    vpinsrw $5, (%rsp,%rax,2), %xmm0, %xmm0
; INT256-NEXT:    vpextrw $6, %xmm2, %eax
; INT256-NEXT:    andl $15, %eax
; INT256-NEXT:    vpinsrw $6, (%rsp,%rax,2), %xmm0, %xmm0
; INT256-NEXT:    vpextrw $7, %xmm2, %eax
; INT256-NEXT:    andl $15, %eax
; INT256-NEXT:    vpinsrw $7, (%rsp,%rax,2), %xmm0, %xmm0
; INT256-NEXT:    vmovd %xmm1, %eax
; INT256-NEXT:    andl $15, %eax
; INT256-NEXT:    movzwl (%rsp,%rax,2), %eax
; INT256-NEXT:    vmovd %eax, %xmm2
; INT256-NEXT:    vpextrw $1, %xmm1, %eax
; INT256-NEXT:    andl $15, %eax
; INT256-NEXT:    vpinsrw $1, (%rsp,%rax,2), %xmm2, %xmm2
; INT256-NEXT:    vpextrw $2, %xmm1, %eax
; INT256-NEXT:    andl $15, %eax
; INT256-NEXT:    vpinsrw $2, (%rsp,%rax,2), %xmm2, %xmm2
; INT256-NEXT:    vpextrw $3, %xmm1, %eax
; INT256-NEXT:    andl $15, %eax
; INT256-NEXT:    vpinsrw $3, (%rsp,%rax,2), %xmm2, %xmm2
; INT256-NEXT:    vpextrw $4, %xmm1, %eax
; INT256-NEXT:    andl $15, %eax
; INT256-NEXT:    vpinsrw $4, (%rsp,%rax,2), %xmm2, %xmm2
; INT256-NEXT:    vpextrw $5, %xmm1, %eax
; INT256-NEXT:    andl $15, %eax
; INT256-NEXT:    vpinsrw $5, (%rsp,%rax,2), %xmm2, %xmm2
; INT256-NEXT:    vpextrw $6, %xmm1, %eax
; INT256-NEXT:    andl $15, %eax
; INT256-NEXT:    vpinsrw $6, (%rsp,%rax,2), %xmm2, %xmm2
; INT256-NEXT:    vpextrw $7, %xmm1, %eax
; INT256-NEXT:    andl $15, %eax
; INT256-NEXT:    vpinsrw $7, (%rsp,%rax,2), %xmm2, %xmm1
; INT256-NEXT:    vinserti128 $1, %xmm0, %ymm1, %ymm0
; INT256-NEXT:    movq %rbp, %rsp
; INT256-NEXT:    popq %rbp
; INT256-NEXT:    retq
  %index0 = extractelement <16 x i16> %indices, i32 0
  %index1 = extractelement <16 x i16> %indices, i32 1
  %index2 = extractelement <16 x i16> %indices, i32 2
  %index3 = extractelement <16 x i16> %indices, i32 3
  %index4 = extractelement <16 x i16> %indices, i32 4
  %index5 = extractelement <16 x i16> %indices, i32 5
  %index6 = extractelement <16 x i16> %indices, i32 6
  %index7 = extractelement <16 x i16> %indices, i32 7
  %index8 = extractelement <16 x i16> %indices, i32 8
  %index9 = extractelement <16 x i16> %indices, i32 9
  %index10 = extractelement <16 x i16> %indices, i32 10
  %index11 = extractelement <16 x i16> %indices, i32 11
  %index12 = extractelement <16 x i16> %indices, i32 12
  %index13 = extractelement <16 x i16> %indices, i32 13
  %index14 = extractelement <16 x i16> %indices, i32 14
  %index15 = extractelement <16 x i16> %indices, i32 15
  %v0 = extractelement <16 x i16> %v, i16 %index0
  %v1 = extractelement <16 x i16> %v, i16 %index1
  %v2 = extractelement <16 x i16> %v, i16 %index2
  %v3 = extractelement <16 x i16> %v, i16 %index3
  %v4 = extractelement <16 x i16> %v, i16 %index4
  %v5 = extractelement <16 x i16> %v, i16 %index5
  %v6 = extractelement <16 x i16> %v, i16 %index6
  %v7 = extractelement <16 x i16> %v, i16 %index7
  %v8 = extractelement <16 x i16> %v, i16 %index8
  %v9 = extractelement <16 x i16> %v, i16 %index9
  %v10 = extractelement <16 x i16> %v, i16 %index10
  %v11 = extractelement <16 x i16> %v, i16 %index11
  %v12 = extractelement <16 x i16> %v, i16 %index12
  %v13 = extractelement <16 x i16> %v, i16 %index13
  %v14 = extractelement <16 x i16> %v, i16 %index14
  %v15 = extractelement <16 x i16> %v, i16 %index15
  %ret0 = insertelement <16 x i16> undef, i16 %v0, i32 0
  %ret1 = insertelement <16 x i16> %ret0, i16 %v1, i32 1
  %ret2 = insertelement <16 x i16> %ret1, i16 %v2, i32 2
  %ret3 = insertelement <16 x i16> %ret2, i16 %v3, i32 3
  %ret4 = insertelement <16 x i16> %ret3, i16 %v4, i32 4
  %ret5 = insertelement <16 x i16> %ret4, i16 %v5, i32 5
  %ret6 = insertelement <16 x i16> %ret5, i16 %v6, i32 6
  %ret7 = insertelement <16 x i16> %ret6, i16 %v7, i32 7
  %ret8 = insertelement <16 x i16> %ret7, i16 %v8, i32 8
  %ret9 = insertelement <16 x i16> %ret8, i16 %v9, i32 9
  %ret10 = insertelement <16 x i16> %ret9, i16 %v10, i32 10
  %ret11 = insertelement <16 x i16> %ret10, i16 %v11, i32 11
  %ret12 = insertelement <16 x i16> %ret11, i16 %v12, i32 12
  %ret13 = insertelement <16 x i16> %ret12, i16 %v13, i32 13
  %ret14 = insertelement <16 x i16> %ret13, i16 %v14, i32 14
  %ret15 = insertelement <16 x i16> %ret14, i16 %v15, i32 15
  ret <16 x i16> %ret15
}

define <32 x i8> @var_shuffle_v32i8(<32 x i8> %v, <32 x i8> %indices) nounwind {
; AVX1-LABEL: var_shuffle_v32i8:
; AVX1:       # BB#0:
; AVX1-NEXT:    pushq %rbp
; AVX1-NEXT:    movq %rsp, %rbp
; AVX1-NEXT:    andq $-32, %rsp
; AVX1-NEXT:    subq $64, %rsp
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vpextrb $0, %xmm2, %eax
; AVX1-NEXT:    vmovaps %ymm0, (%rsp)
; AVX1-NEXT:    andl $31, %eax
; AVX1-NEXT:    movq %rsp, %rcx
; AVX1-NEXT:    movzbl (%rax,%rcx), %eax
; AVX1-NEXT:    vmovd %eax, %xmm0
; AVX1-NEXT:    vpextrb $1, %xmm2, %eax
; AVX1-NEXT:    andl $31, %eax
; AVX1-NEXT:    movzbl (%rax,%rcx), %eax
; AVX1-NEXT:    vpinsrb $1, %eax, %xmm0, %xmm0
; AVX1-NEXT:    vpextrb $2, %xmm2, %eax
; AVX1-NEXT:    andl $31, %eax
; AVX1-NEXT:    movzbl (%rax,%rcx), %eax
; AVX1-NEXT:    vpinsrb $2, %eax, %xmm0, %xmm0
; AVX1-NEXT:    vpextrb $3, %xmm2, %eax
; AVX1-NEXT:    andl $31, %eax
; AVX1-NEXT:    movzbl (%rax,%rcx), %eax
; AVX1-NEXT:    vpinsrb $3, %eax, %xmm0, %xmm0
; AVX1-NEXT:    vpextrb $4, %xmm2, %eax
; AVX1-NEXT:    andl $31, %eax
; AVX1-NEXT:    movzbl (%rax,%rcx), %eax
; AVX1-NEXT:    vpinsrb $4, %eax, %xmm0, %xmm0
; AVX1-NEXT:    vpextrb $5, %xmm2, %eax
; AVX1-NEXT:    andl $31, %eax
; AVX1-NEXT:    movzbl (%rax,%rcx), %eax
; AVX1-NEXT:    vpinsrb $5, %eax, %xmm0, %xmm0
; AVX1-NEXT:    vpextrb $6, %xmm2, %eax
; AVX1-NEXT:    andl $31, %eax
; AVX1-NEXT:    movzbl (%rax,%rcx), %eax
; AVX1-NEXT:    vpinsrb $6, %eax, %xmm0, %xmm0
; AVX1-NEXT:    vpextrb $7, %xmm2, %eax
; AVX1-NEXT:    andl $31, %eax
; AVX1-NEXT:    movzbl (%rax,%rcx), %eax
; AVX1-NEXT:    vpinsrb $7, %eax, %xmm0, %xmm0
; AVX1-NEXT:    vpextrb $8, %xmm2, %eax
; AVX1-NEXT:    andl $31, %eax
; AVX1-NEXT:    movzbl (%rax,%rcx), %eax
; AVX1-NEXT:    vpinsrb $8, %eax, %xmm0, %xmm0
; AVX1-NEXT:    vpextrb $9, %xmm2, %eax
; AVX1-NEXT:    andl $31, %eax
; AVX1-NEXT:    movzbl (%rax,%rcx), %eax
; AVX1-NEXT:    vpinsrb $9, %eax, %xmm0, %xmm0
; AVX1-NEXT:    vpextrb $10, %xmm2, %eax
; AVX1-NEXT:    andl $31, %eax
; AVX1-NEXT:    movzbl (%rax,%rcx), %eax
; AVX1-NEXT:    vpinsrb $10, %eax, %xmm0, %xmm0
; AVX1-NEXT:    vpextrb $11, %xmm2, %eax
; AVX1-NEXT:    andl $31, %eax
; AVX1-NEXT:    movzbl (%rax,%rcx), %eax
; AVX1-NEXT:    vpinsrb $11, %eax, %xmm0, %xmm0
; AVX1-NEXT:    vpextrb $12, %xmm2, %eax
; AVX1-NEXT:    andl $31, %eax
; AVX1-NEXT:    movzbl (%rax,%rcx), %eax
; AVX1-NEXT:    vpinsrb $12, %eax, %xmm0, %xmm0
; AVX1-NEXT:    vpextrb $13, %xmm2, %eax
; AVX1-NEXT:    andl $31, %eax
; AVX1-NEXT:    movzbl (%rax,%rcx), %eax
; AVX1-NEXT:    vpinsrb $13, %eax, %xmm0, %xmm0
; AVX1-NEXT:    vpextrb $14, %xmm2, %eax
; AVX1-NEXT:    andl $31, %eax
; AVX1-NEXT:    movzbl (%rax,%rcx), %eax
; AVX1-NEXT:    vpinsrb $14, %eax, %xmm0, %xmm0
; AVX1-NEXT:    vpextrb $15, %xmm2, %eax
; AVX1-NEXT:    andl $31, %eax
; AVX1-NEXT:    movzbl (%rax,%rcx), %eax
; AVX1-NEXT:    vpinsrb $15, %eax, %xmm0, %xmm0
; AVX1-NEXT:    vpextrb $0, %xmm1, %eax
; AVX1-NEXT:    andl $31, %eax
; AVX1-NEXT:    movzbl (%rax,%rcx), %eax
; AVX1-NEXT:    vmovd %eax, %xmm2
; AVX1-NEXT:    vpextrb $1, %xmm1, %eax
; AVX1-NEXT:    andl $31, %eax
; AVX1-NEXT:    vpinsrb $1, (%rax,%rcx), %xmm2, %xmm2
; AVX1-NEXT:    vpextrb $2, %xmm1, %eax
; AVX1-NEXT:    andl $31, %eax
; AVX1-NEXT:    vpinsrb $2, (%rax,%rcx), %xmm2, %xmm2
; AVX1-NEXT:    vpextrb $3, %xmm1, %eax
; AVX1-NEXT:    andl $31, %eax
; AVX1-NEXT:    vpinsrb $3, (%rax,%rcx), %xmm2, %xmm2
; AVX1-NEXT:    vpextrb $4, %xmm1, %eax
; AVX1-NEXT:    andl $31, %eax
; AVX1-NEXT:    vpinsrb $4, (%rax,%rcx), %xmm2, %xmm2
; AVX1-NEXT:    vpextrb $5, %xmm1, %eax
; AVX1-NEXT:    andl $31, %eax
; AVX1-NEXT:    vpinsrb $5, (%rax,%rcx), %xmm2, %xmm2
; AVX1-NEXT:    vpextrb $6, %xmm1, %eax
; AVX1-NEXT:    andl $31, %eax
; AVX1-NEXT:    vpinsrb $6, (%rax,%rcx), %xmm2, %xmm2
; AVX1-NEXT:    vpextrb $7, %xmm1, %eax
; AVX1-NEXT:    andl $31, %eax
; AVX1-NEXT:    vpinsrb $7, (%rax,%rcx), %xmm2, %xmm2
; AVX1-NEXT:    vpextrb $8, %xmm1, %eax
; AVX1-NEXT:    andl $31, %eax
; AVX1-NEXT:    vpinsrb $8, (%rax,%rcx), %xmm2, %xmm2
; AVX1-NEXT:    vpextrb $9, %xmm1, %eax
; AVX1-NEXT:    andl $31, %eax
; AVX1-NEXT:    vpinsrb $9, (%rax,%rcx), %xmm2, %xmm2
; AVX1-NEXT:    vpextrb $10, %xmm1, %eax
; AVX1-NEXT:    andl $31, %eax
; AVX1-NEXT:    vpinsrb $10, (%rax,%rcx), %xmm2, %xmm2
; AVX1-NEXT:    vpextrb $11, %xmm1, %eax
; AVX1-NEXT:    andl $31, %eax
; AVX1-NEXT:    vpinsrb $11, (%rax,%rcx), %xmm2, %xmm2
; AVX1-NEXT:    vpextrb $12, %xmm1, %eax
; AVX1-NEXT:    andl $31, %eax
; AVX1-NEXT:    vpinsrb $12, (%rax,%rcx), %xmm2, %xmm2
; AVX1-NEXT:    vpextrb $13, %xmm1, %eax
; AVX1-NEXT:    andl $31, %eax
; AVX1-NEXT:    vpinsrb $13, (%rax,%rcx), %xmm2, %xmm2
; AVX1-NEXT:    vpextrb $14, %xmm1, %eax
; AVX1-NEXT:    andl $31, %eax
; AVX1-NEXT:    vpinsrb $14, (%rax,%rcx), %xmm2, %xmm2
; AVX1-NEXT:    vpextrb $15, %xmm1, %eax
; AVX1-NEXT:    andl $31, %eax
; AVX1-NEXT:    movzbl (%rax,%rcx), %eax
; AVX1-NEXT:    vpinsrb $15, %eax, %xmm2, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; AVX1-NEXT:    movq %rbp, %rsp
; AVX1-NEXT:    popq %rbp
; AVX1-NEXT:    retq
;
; INT256-LABEL: var_shuffle_v32i8:
; INT256:       # BB#0:
; INT256-NEXT:    pushq %rbp
; INT256-NEXT:    movq %rsp, %rbp
; INT256-NEXT:    andq $-32, %rsp
; INT256-NEXT:    subq $64, %rsp
; INT256-NEXT:    vextracti128 $1, %ymm1, %xmm2
; INT256-NEXT:    vpextrb $0, %xmm2, %eax
; INT256-NEXT:    vmovaps %ymm0, (%rsp)
; INT256-NEXT:    andl $31, %eax
; INT256-NEXT:    movq %rsp, %rcx
; INT256-NEXT:    movzbl (%rax,%rcx), %eax
; INT256-NEXT:    vmovd %eax, %xmm0
; INT256-NEXT:    vpextrb $1, %xmm2, %eax
; INT256-NEXT:    andl $31, %eax
; INT256-NEXT:    movzbl (%rax,%rcx), %eax
; INT256-NEXT:    vpinsrb $1, %eax, %xmm0, %xmm0
; INT256-NEXT:    vpextrb $2, %xmm2, %eax
; INT256-NEXT:    andl $31, %eax
; INT256-NEXT:    movzbl (%rax,%rcx), %eax
; INT256-NEXT:    vpinsrb $2, %eax, %xmm0, %xmm0
; INT256-NEXT:    vpextrb $3, %xmm2, %eax
; INT256-NEXT:    andl $31, %eax
; INT256-NEXT:    movzbl (%rax,%rcx), %eax
; INT256-NEXT:    vpinsrb $3, %eax, %xmm0, %xmm0
; INT256-NEXT:    vpextrb $4, %xmm2, %eax
; INT256-NEXT:    andl $31, %eax
; INT256-NEXT:    movzbl (%rax,%rcx), %eax
; INT256-NEXT:    vpinsrb $4, %eax, %xmm0, %xmm0
; INT256-NEXT:    vpextrb $5, %xmm2, %eax
; INT256-NEXT:    andl $31, %eax
; INT256-NEXT:    movzbl (%rax,%rcx), %eax
; INT256-NEXT:    vpinsrb $5, %eax, %xmm0, %xmm0
; INT256-NEXT:    vpextrb $6, %xmm2, %eax
; INT256-NEXT:    andl $31, %eax
; INT256-NEXT:    movzbl (%rax,%rcx), %eax
; INT256-NEXT:    vpinsrb $6, %eax, %xmm0, %xmm0
; INT256-NEXT:    vpextrb $7, %xmm2, %eax
; INT256-NEXT:    andl $31, %eax
; INT256-NEXT:    movzbl (%rax,%rcx), %eax
; INT256-NEXT:    vpinsrb $7, %eax, %xmm0, %xmm0
; INT256-NEXT:    vpextrb $8, %xmm2, %eax
; INT256-NEXT:    andl $31, %eax
; INT256-NEXT:    movzbl (%rax,%rcx), %eax
; INT256-NEXT:    vpinsrb $8, %eax, %xmm0, %xmm0
; INT256-NEXT:    vpextrb $9, %xmm2, %eax
; INT256-NEXT:    andl $31, %eax
; INT256-NEXT:    movzbl (%rax,%rcx), %eax
; INT256-NEXT:    vpinsrb $9, %eax, %xmm0, %xmm0
; INT256-NEXT:    vpextrb $10, %xmm2, %eax
; INT256-NEXT:    andl $31, %eax
; INT256-NEXT:    movzbl (%rax,%rcx), %eax
; INT256-NEXT:    vpinsrb $10, %eax, %xmm0, %xmm0
; INT256-NEXT:    vpextrb $11, %xmm2, %eax
; INT256-NEXT:    andl $31, %eax
; INT256-NEXT:    movzbl (%rax,%rcx), %eax
; INT256-NEXT:    vpinsrb $11, %eax, %xmm0, %xmm0
; INT256-NEXT:    vpextrb $12, %xmm2, %eax
; INT256-NEXT:    andl $31, %eax
; INT256-NEXT:    movzbl (%rax,%rcx), %eax
; INT256-NEXT:    vpinsrb $12, %eax, %xmm0, %xmm0
; INT256-NEXT:    vpextrb $13, %xmm2, %eax
; INT256-NEXT:    andl $31, %eax
; INT256-NEXT:    movzbl (%rax,%rcx), %eax
; INT256-NEXT:    vpinsrb $13, %eax, %xmm0, %xmm0
; INT256-NEXT:    vpextrb $14, %xmm2, %eax
; INT256-NEXT:    andl $31, %eax
; INT256-NEXT:    movzbl (%rax,%rcx), %eax
; INT256-NEXT:    vpinsrb $14, %eax, %xmm0, %xmm0
; INT256-NEXT:    vpextrb $15, %xmm2, %eax
; INT256-NEXT:    andl $31, %eax
; INT256-NEXT:    movzbl (%rax,%rcx), %eax
; INT256-NEXT:    vpinsrb $15, %eax, %xmm0, %xmm0
; INT256-NEXT:    vpextrb $0, %xmm1, %eax
; INT256-NEXT:    andl $31, %eax
; INT256-NEXT:    movzbl (%rax,%rcx), %eax
; INT256-NEXT:    vmovd %eax, %xmm2
; INT256-NEXT:    vpextrb $1, %xmm1, %eax
; INT256-NEXT:    andl $31, %eax
; INT256-NEXT:    vpinsrb $1, (%rax,%rcx), %xmm2, %xmm2
; INT256-NEXT:    vpextrb $2, %xmm1, %eax
; INT256-NEXT:    andl $31, %eax
; INT256-NEXT:    vpinsrb $2, (%rax,%rcx), %xmm2, %xmm2
; INT256-NEXT:    vpextrb $3, %xmm1, %eax
; INT256-NEXT:    andl $31, %eax
; INT256-NEXT:    vpinsrb $3, (%rax,%rcx), %xmm2, %xmm2
; INT256-NEXT:    vpextrb $4, %xmm1, %eax
; INT256-NEXT:    andl $31, %eax
; INT256-NEXT:    vpinsrb $4, (%rax,%rcx), %xmm2, %xmm2
; INT256-NEXT:    vpextrb $5, %xmm1, %eax
; INT256-NEXT:    andl $31, %eax
; INT256-NEXT:    vpinsrb $5, (%rax,%rcx), %xmm2, %xmm2
; INT256-NEXT:    vpextrb $6, %xmm1, %eax
; INT256-NEXT:    andl $31, %eax
; INT256-NEXT:    vpinsrb $6, (%rax,%rcx), %xmm2, %xmm2
; INT256-NEXT:    vpextrb $7, %xmm1, %eax
; INT256-NEXT:    andl $31, %eax
; INT256-NEXT:    vpinsrb $7, (%rax,%rcx), %xmm2, %xmm2
; INT256-NEXT:    vpextrb $8, %xmm1, %eax
; INT256-NEXT:    andl $31, %eax
; INT256-NEXT:    vpinsrb $8, (%rax,%rcx), %xmm2, %xmm2
; INT256-NEXT:    vpextrb $9, %xmm1, %eax
; INT256-NEXT:    andl $31, %eax
; INT256-NEXT:    vpinsrb $9, (%rax,%rcx), %xmm2, %xmm2
; INT256-NEXT:    vpextrb $10, %xmm1, %eax
; INT256-NEXT:    andl $31, %eax
; INT256-NEXT:    vpinsrb $10, (%rax,%rcx), %xmm2, %xmm2
; INT256-NEXT:    vpextrb $11, %xmm1, %eax
; INT256-NEXT:    andl $31, %eax
; INT256-NEXT:    vpinsrb $11, (%rax,%rcx), %xmm2, %xmm2
; INT256-NEXT:    vpextrb $12, %xmm1, %eax
; INT256-NEXT:    andl $31, %eax
; INT256-NEXT:    vpinsrb $12, (%rax,%rcx), %xmm2, %xmm2
; INT256-NEXT:    vpextrb $13, %xmm1, %eax
; INT256-NEXT:    andl $31, %eax
; INT256-NEXT:    vpinsrb $13, (%rax,%rcx), %xmm2, %xmm2
; INT256-NEXT:    vpextrb $14, %xmm1, %eax
; INT256-NEXT:    andl $31, %eax
; INT256-NEXT:    vpinsrb $14, (%rax,%rcx), %xmm2, %xmm2
; INT256-NEXT:    vpextrb $15, %xmm1, %eax
; INT256-NEXT:    andl $31, %eax
; INT256-NEXT:    movzbl (%rax,%rcx), %eax
; INT256-NEXT:    vpinsrb $15, %eax, %xmm2, %xmm1
; INT256-NEXT:    vinserti128 $1, %xmm0, %ymm1, %ymm0
; INT256-NEXT:    movq %rbp, %rsp
; INT256-NEXT:    popq %rbp
; INT256-NEXT:    retq
  %index0 = extractelement <32 x i8> %indices, i32 0
  %index1 = extractelement <32 x i8> %indices, i32 1
  %index2 = extractelement <32 x i8> %indices, i32 2
  %index3 = extractelement <32 x i8> %indices, i32 3
  %index4 = extractelement <32 x i8> %indices, i32 4
  %index5 = extractelement <32 x i8> %indices, i32 5
  %index6 = extractelement <32 x i8> %indices, i32 6
  %index7 = extractelement <32 x i8> %indices, i32 7
  %index8 = extractelement <32 x i8> %indices, i32 8
  %index9 = extractelement <32 x i8> %indices, i32 9
  %index10 = extractelement <32 x i8> %indices, i32 10
  %index11 = extractelement <32 x i8> %indices, i32 11
  %index12 = extractelement <32 x i8> %indices, i32 12
  %index13 = extractelement <32 x i8> %indices, i32 13
  %index14 = extractelement <32 x i8> %indices, i32 14
  %index15 = extractelement <32 x i8> %indices, i32 15
  %index16 = extractelement <32 x i8> %indices, i32 16
  %index17 = extractelement <32 x i8> %indices, i32 17
  %index18 = extractelement <32 x i8> %indices, i32 18
  %index19 = extractelement <32 x i8> %indices, i32 19
  %index20 = extractelement <32 x i8> %indices, i32 20
  %index21 = extractelement <32 x i8> %indices, i32 21
  %index22 = extractelement <32 x i8> %indices, i32 22
  %index23 = extractelement <32 x i8> %indices, i32 23
  %index24 = extractelement <32 x i8> %indices, i32 24
  %index25 = extractelement <32 x i8> %indices, i32 25
  %index26 = extractelement <32 x i8> %indices, i32 26
  %index27 = extractelement <32 x i8> %indices, i32 27
  %index28 = extractelement <32 x i8> %indices, i32 28
  %index29 = extractelement <32 x i8> %indices, i32 29
  %index30 = extractelement <32 x i8> %indices, i32 30
  %index31 = extractelement <32 x i8> %indices, i32 31
  %v0 = extractelement <32 x i8> %v, i8 %index0
  %v1 = extractelement <32 x i8> %v, i8 %index1
  %v2 = extractelement <32 x i8> %v, i8 %index2
  %v3 = extractelement <32 x i8> %v, i8 %index3
  %v4 = extractelement <32 x i8> %v, i8 %index4
  %v5 = extractelement <32 x i8> %v, i8 %index5
  %v6 = extractelement <32 x i8> %v, i8 %index6
  %v7 = extractelement <32 x i8> %v, i8 %index7
  %v8 = extractelement <32 x i8> %v, i8 %index8
  %v9 = extractelement <32 x i8> %v, i8 %index9
  %v10 = extractelement <32 x i8> %v, i8 %index10
  %v11 = extractelement <32 x i8> %v, i8 %index11
  %v12 = extractelement <32 x i8> %v, i8 %index12
  %v13 = extractelement <32 x i8> %v, i8 %index13
  %v14 = extractelement <32 x i8> %v, i8 %index14
  %v15 = extractelement <32 x i8> %v, i8 %index15
  %v16 = extractelement <32 x i8> %v, i8 %index16
  %v17 = extractelement <32 x i8> %v, i8 %index17
  %v18 = extractelement <32 x i8> %v, i8 %index18
  %v19 = extractelement <32 x i8> %v, i8 %index19
  %v20 = extractelement <32 x i8> %v, i8 %index20
  %v21 = extractelement <32 x i8> %v, i8 %index21
  %v22 = extractelement <32 x i8> %v, i8 %index22
  %v23 = extractelement <32 x i8> %v, i8 %index23
  %v24 = extractelement <32 x i8> %v, i8 %index24
  %v25 = extractelement <32 x i8> %v, i8 %index25
  %v26 = extractelement <32 x i8> %v, i8 %index26
  %v27 = extractelement <32 x i8> %v, i8 %index27
  %v28 = extractelement <32 x i8> %v, i8 %index28
  %v29 = extractelement <32 x i8> %v, i8 %index29
  %v30 = extractelement <32 x i8> %v, i8 %index30
  %v31 = extractelement <32 x i8> %v, i8 %index31
  %ret0 = insertelement <32 x i8> undef, i8 %v0, i32 0
  %ret1 = insertelement <32 x i8> %ret0, i8 %v1, i32 1
  %ret2 = insertelement <32 x i8> %ret1, i8 %v2, i32 2
  %ret3 = insertelement <32 x i8> %ret2, i8 %v3, i32 3
  %ret4 = insertelement <32 x i8> %ret3, i8 %v4, i32 4
  %ret5 = insertelement <32 x i8> %ret4, i8 %v5, i32 5
  %ret6 = insertelement <32 x i8> %ret5, i8 %v6, i32 6
  %ret7 = insertelement <32 x i8> %ret6, i8 %v7, i32 7
  %ret8 = insertelement <32 x i8> %ret7, i8 %v8, i32 8
  %ret9 = insertelement <32 x i8> %ret8, i8 %v9, i32 9
  %ret10 = insertelement <32 x i8> %ret9, i8 %v10, i32 10
  %ret11 = insertelement <32 x i8> %ret10, i8 %v11, i32 11
  %ret12 = insertelement <32 x i8> %ret11, i8 %v12, i32 12
  %ret13 = insertelement <32 x i8> %ret12, i8 %v13, i32 13
  %ret14 = insertelement <32 x i8> %ret13, i8 %v14, i32 14
  %ret15 = insertelement <32 x i8> %ret14, i8 %v15, i32 15
  %ret16 = insertelement <32 x i8> %ret15, i8 %v16, i32 16
  %ret17 = insertelement <32 x i8> %ret16, i8 %v17, i32 17
  %ret18 = insertelement <32 x i8> %ret17, i8 %v18, i32 18
  %ret19 = insertelement <32 x i8> %ret18, i8 %v19, i32 19
  %ret20 = insertelement <32 x i8> %ret19, i8 %v20, i32 20
  %ret21 = insertelement <32 x i8> %ret20, i8 %v21, i32 21
  %ret22 = insertelement <32 x i8> %ret21, i8 %v22, i32 22
  %ret23 = insertelement <32 x i8> %ret22, i8 %v23, i32 23
  %ret24 = insertelement <32 x i8> %ret23, i8 %v24, i32 24
  %ret25 = insertelement <32 x i8> %ret24, i8 %v25, i32 25
  %ret26 = insertelement <32 x i8> %ret25, i8 %v26, i32 26
  %ret27 = insertelement <32 x i8> %ret26, i8 %v27, i32 27
  %ret28 = insertelement <32 x i8> %ret27, i8 %v28, i32 28
  %ret29 = insertelement <32 x i8> %ret28, i8 %v29, i32 29
  %ret30 = insertelement <32 x i8> %ret29, i8 %v30, i32 30
  %ret31 = insertelement <32 x i8> %ret30, i8 %v31, i32 31
  ret <32 x i8> %ret31
}

