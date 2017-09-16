; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown-unknown    | FileCheck %s -check-prefix=X32
; RUN: llc < %s -mtriple=x86_64-unknown-unknown  | FileCheck %s -check-prefix=X64

; DAGCombiner crashes during sext folding

define <2 x i256> @test_sext1() {
; X32-LABEL: test_sext1:
; X32:       # BB#0:
; X32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    movl $-1, 60(%eax)
; X32-NEXT:    movl $-1, 56(%eax)
; X32-NEXT:    movl $-1, 52(%eax)
; X32-NEXT:    movl $-1, 48(%eax)
; X32-NEXT:    movl $-1, 44(%eax)
; X32-NEXT:    movl $-1, 40(%eax)
; X32-NEXT:    movl $-1, 36(%eax)
; X32-NEXT:    movl $-99, 32(%eax)
; X32-NEXT:    movl $0, 28(%eax)
; X32-NEXT:    movl $0, 24(%eax)
; X32-NEXT:    movl $0, 20(%eax)
; X32-NEXT:    movl $0, 16(%eax)
; X32-NEXT:    movl $0, 12(%eax)
; X32-NEXT:    movl $0, 8(%eax)
; X32-NEXT:    movl $0, 4(%eax)
; X32-NEXT:    movl $0, (%eax)
; X32-NEXT:    retl $4
;
; X64-LABEL: test_sext1:
; X64:       # BB#0:
; X64-NEXT:    xorps %xmm0, %xmm0
; X64-NEXT:    movaps %xmm0, 16(%rdi)
; X64-NEXT:    movaps %xmm0, (%rdi)
; X64-NEXT:    movq $-1, 56(%rdi)
; X64-NEXT:    movq $-1, 48(%rdi)
; X64-NEXT:    movq $-1, 40(%rdi)
; X64-NEXT:    movq $-99, 32(%rdi)
; X64-NEXT:    movq %rdi, %rax
; X64-NEXT:    retq
  %Se = sext <2 x i8> <i8 -100, i8 -99> to <2 x i256>
  %Shuff = shufflevector <2 x i256> zeroinitializer, <2 x i256> %Se, <2 x i32> <i32 1, i32 3>
  ret <2 x i256> %Shuff
}

define <2 x i256> @test_sext2() {
; X32-LABEL: test_sext2:
; X32:       # BB#0:
; X32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    movl $-1, 60(%eax)
; X32-NEXT:    movl $-1, 56(%eax)
; X32-NEXT:    movl $-1, 52(%eax)
; X32-NEXT:    movl $-1, 48(%eax)
; X32-NEXT:    movl $-1, 44(%eax)
; X32-NEXT:    movl $-1, 40(%eax)
; X32-NEXT:    movl $-1, 36(%eax)
; X32-NEXT:    movl $-1999, 32(%eax) # imm = 0xF831
; X32-NEXT:    movl $0, 28(%eax)
; X32-NEXT:    movl $0, 24(%eax)
; X32-NEXT:    movl $0, 20(%eax)
; X32-NEXT:    movl $0, 16(%eax)
; X32-NEXT:    movl $0, 12(%eax)
; X32-NEXT:    movl $0, 8(%eax)
; X32-NEXT:    movl $0, 4(%eax)
; X32-NEXT:    movl $0, (%eax)
; X32-NEXT:    retl $4
;
; X64-LABEL: test_sext2:
; X64:       # BB#0:
; X64-NEXT:    xorps %xmm0, %xmm0
; X64-NEXT:    movaps %xmm0, 16(%rdi)
; X64-NEXT:    movaps %xmm0, (%rdi)
; X64-NEXT:    movq $-1, 56(%rdi)
; X64-NEXT:    movq $-1, 48(%rdi)
; X64-NEXT:    movq $-1, 40(%rdi)
; X64-NEXT:    movq $-1999, 32(%rdi) # imm = 0xF831
; X64-NEXT:    movq %rdi, %rax
; X64-NEXT:    retq
  %Se = sext <2 x i128> <i128 -2000, i128 -1999> to <2 x i256>
  %Shuff = shufflevector <2 x i256> zeroinitializer, <2 x i256> %Se, <2 x i32> <i32 1, i32 3>
  ret <2 x i256> %Shuff
}

define <2 x i256> @test_zext1() {
; X32-LABEL: test_zext1:
; X32:       # BB#0:
; X32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    movl $0, 60(%eax)
; X32-NEXT:    movl $0, 56(%eax)
; X32-NEXT:    movl $0, 52(%eax)
; X32-NEXT:    movl $0, 48(%eax)
; X32-NEXT:    movl $0, 44(%eax)
; X32-NEXT:    movl $0, 40(%eax)
; X32-NEXT:    movl $0, 36(%eax)
; X32-NEXT:    movl $254, 32(%eax)
; X32-NEXT:    movl $0, 28(%eax)
; X32-NEXT:    movl $0, 24(%eax)
; X32-NEXT:    movl $0, 20(%eax)
; X32-NEXT:    movl $0, 16(%eax)
; X32-NEXT:    movl $0, 12(%eax)
; X32-NEXT:    movl $0, 8(%eax)
; X32-NEXT:    movl $0, 4(%eax)
; X32-NEXT:    movl $0, (%eax)
; X32-NEXT:    retl $4
;
; X64-LABEL: test_zext1:
; X64:       # BB#0:
; X64-NEXT:    xorps %xmm0, %xmm0
; X64-NEXT:    movaps %xmm0, 48(%rdi)
; X64-NEXT:    movaps %xmm0, 16(%rdi)
; X64-NEXT:    movaps %xmm0, (%rdi)
; X64-NEXT:    movq $0, 40(%rdi)
; X64-NEXT:    movq $254, 32(%rdi)
; X64-NEXT:    movq %rdi, %rax
; X64-NEXT:    retq
  %Se = zext <2 x i8> <i8 -1, i8 -2> to <2 x i256>
  %Shuff = shufflevector <2 x i256> zeroinitializer, <2 x i256> %Se, <2 x i32> <i32 1, i32 3>
  ret <2 x i256> %Shuff
}

define <2 x i256> @test_zext2() {
; X32-LABEL: test_zext2:
; X32:       # BB#0:
; X32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    movl $0, 60(%eax)
; X32-NEXT:    movl $0, 56(%eax)
; X32-NEXT:    movl $0, 52(%eax)
; X32-NEXT:    movl $0, 48(%eax)
; X32-NEXT:    movl $-1, 44(%eax)
; X32-NEXT:    movl $-1, 40(%eax)
; X32-NEXT:    movl $-1, 36(%eax)
; X32-NEXT:    movl $-2, 32(%eax)
; X32-NEXT:    movl $0, 28(%eax)
; X32-NEXT:    movl $0, 24(%eax)
; X32-NEXT:    movl $0, 20(%eax)
; X32-NEXT:    movl $0, 16(%eax)
; X32-NEXT:    movl $0, 12(%eax)
; X32-NEXT:    movl $0, 8(%eax)
; X32-NEXT:    movl $0, 4(%eax)
; X32-NEXT:    movl $0, (%eax)
; X32-NEXT:    retl $4
;
; X64-LABEL: test_zext2:
; X64:       # BB#0:
; X64-NEXT:    xorps %xmm0, %xmm0
; X64-NEXT:    movaps %xmm0, 48(%rdi)
; X64-NEXT:    movaps %xmm0, 16(%rdi)
; X64-NEXT:    movaps %xmm0, (%rdi)
; X64-NEXT:    movq $-1, 40(%rdi)
; X64-NEXT:    movq $-2, 32(%rdi)
; X64-NEXT:    movq %rdi, %rax
; X64-NEXT:    retq
  %Se = zext <2 x i128> <i128 -1, i128 -2> to <2 x i256>
  %Shuff = shufflevector <2 x i256> zeroinitializer, <2 x i256> %Se, <2 x i32> <i32 1, i32 3>
  ret <2 x i256> %Shuff
}
