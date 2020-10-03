; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unkown-unknown -mattr=+kl,widekl | FileCheck %s --check-prefix=X64
; RUN: llc < %s -mtriple=i386-unkown-unknown -mattr=+kl,widekl -mattr=+avx2 | FileCheck %s --check-prefix=X32
; RUN: llc < %s -mtriple=x86_64-unkown-unknown -mattr=+widekl | FileCheck %s --check-prefix=X64
; RUN: llc < %s -mtriple=i386-unkown-unknown -mattr=+widekl -mattr=+avx2 | FileCheck %s --check-prefix=X32

declare void @llvm.x86.loadiwkey(i32, <2 x i64>, <2 x i64>, <2 x i64>)
declare { i32, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } @llvm.x86.encodekey128(i32, <2 x i64>)
declare { i32, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } @llvm.x86.encodekey256(i32, <2 x i64>, <2 x i64>)
declare { i8, <2 x i64> } @llvm.x86.aesenc128kl(<2 x i64>, i8*)
declare { i8, <2 x i64> } @llvm.x86.aesdec128kl(<2 x i64>, i8*)
declare { i8, <2 x i64> } @llvm.x86.aesenc256kl(<2 x i64>, i8*)
declare { i8, <2 x i64> } @llvm.x86.aesdec256kl(<2 x i64>, i8*)
declare { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } @llvm.x86.aesencwide128kl(i8*, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>)
declare { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } @llvm.x86.aesdecwide128kl(i8*, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>)
declare { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } @llvm.x86.aesencwide256kl(i8*, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>)
declare { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } @llvm.x86.aesdecwide256kl(i8*, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>)

define void @test_loadiwkey(i32 %ctl, <2 x i64> %intkey, <2 x i64> %enkey_lo, <2 x i64> %enkey_hi) {
; X64-LABEL: test_loadiwkey:
; X64:       # %bb.0: # %entry
; X64-NEXT:    movl %edi, %eax
; X64-NEXT:    loadiwkey %xmm2, %xmm1
; X64-NEXT:    retq
;
; X32-LABEL: test_loadiwkey:
; X32:       # %bb.0: # %entry
; X32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    loadiwkey %xmm2, %xmm1
; X32-NEXT:    retl
entry:
  tail call void @llvm.x86.loadiwkey(i32 %ctl, <2 x i64> %intkey, <2 x i64> %enkey_lo, <2 x i64> %enkey_hi)
  ret void
}

define i32 @test_encodekey128_u32(i32 %htype, <2 x i64> %key, <2 x i64>* nocapture %h0, <2 x i64>* nocapture %h1, <2 x i64>* nocapture %h2, <2 x i64>* nocapture %h3, <2 x i64>* nocapture %h4, <2 x i64>* nocapture %h5) nounwind {
; X64-LABEL: test_encodekey128_u32:
; X64:       # %bb.0: # %entry
; X64-NEXT:    movq {{[0-9]+}}(%rsp), %r10
; X64-NEXT:    encodekey128 %edi, %eax
; X64-NEXT:    movaps %xmm0, (%rsi)
; X64-NEXT:    movaps %xmm1, (%rdx)
; X64-NEXT:    movaps %xmm2, (%rcx)
; X64-NEXT:    movaps %xmm4, (%r8)
; X64-NEXT:    movaps %xmm5, (%r9)
; X64-NEXT:    movaps %xmm6, (%r10)
; X64-NEXT:    retq
;
; X32-LABEL: test_encodekey128_u32:
; X32:       # %bb.0: # %entry
; X32-NEXT:    pushl %ebp
; X32-NEXT:    pushl %ebx
; X32-NEXT:    pushl %edi
; X32-NEXT:    pushl %esi
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X32-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X32-NEXT:    movl {{[0-9]+}}(%esp), %esi
; X32-NEXT:    movl {{[0-9]+}}(%esp), %edi
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ebx
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ebp
; X32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    encodekey128 %eax, %eax
; X32-NEXT:    vmovaps %xmm0, (%ebp)
; X32-NEXT:    vmovaps %xmm1, (%ebx)
; X32-NEXT:    vmovaps %xmm2, (%edi)
; X32-NEXT:    vmovaps %xmm4, (%esi)
; X32-NEXT:    vmovaps %xmm5, (%edx)
; X32-NEXT:    vmovaps %xmm6, (%ecx)
; X32-NEXT:    popl %esi
; X32-NEXT:    popl %edi
; X32-NEXT:    popl %ebx
; X32-NEXT:    popl %ebp
; X32-NEXT:    retl
entry:
  %0 = tail call { i32, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } @llvm.x86.encodekey128(i32 %htype, <2 x i64> %key)
  %1 = extractvalue { i32, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 1
  store <2 x i64> %1, <2 x i64>* %h0, align 16
  %2 = extractvalue { i32, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 2
  store <2 x i64> %2, <2 x i64>* %h1, align 16
  %3 = extractvalue { i32, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 3
  store <2 x i64> %3, <2 x i64>* %h2, align 16
  %4 = extractvalue { i32, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 4
  store <2 x i64> %4, <2 x i64>* %h3, align 16
  %5 = extractvalue { i32, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 5
  store <2 x i64> %5, <2 x i64>* %h4, align 16
  %6 = extractvalue { i32, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 6
  store <2 x i64> %6, <2 x i64>* %h5, align 16
  %7 = extractvalue { i32, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 0
  ret i32 %7
}

define i32 @test_encodekey256_u32(i32 %htype, <2 x i64> %key_lo, <2 x i64> %key_hi, <2 x i64>* nocapture %h0, <2 x i64>* nocapture %h1, <2 x i64>* nocapture %h2, <2 x i64>* nocapture %h3, <2 x i64>* nocapture %h4, <2 x i64>* nocapture %h5, <2 x      i64>* nocapture readnone %h6) nounwind {
; X64-LABEL: test_encodekey256_u32:
; X64:       # %bb.0: # %entry
; X64-NEXT:    movq {{[0-9]+}}(%rsp), %r10
; X64-NEXT:    encodekey256 %edi, %eax
; X64-NEXT:    movaps %xmm0, (%rsi)
; X64-NEXT:    movaps %xmm1, (%rdx)
; X64-NEXT:    movaps %xmm2, (%rcx)
; X64-NEXT:    movaps %xmm3, (%r8)
; X64-NEXT:    movaps %xmm4, (%r9)
; X64-NEXT:    movaps %xmm5, (%r10)
; X64-NEXT:    retq
;
; X32-LABEL: test_encodekey256_u32:
; X32:       # %bb.0: # %entry
; X32-NEXT:    pushl %ebp
; X32-NEXT:    pushl %ebx
; X32-NEXT:    pushl %edi
; X32-NEXT:    pushl %esi
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X32-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X32-NEXT:    movl {{[0-9]+}}(%esp), %esi
; X32-NEXT:    movl {{[0-9]+}}(%esp), %edi
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ebx
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ebp
; X32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    encodekey256 %eax, %eax
; X32-NEXT:    vmovaps %xmm0, (%ebp)
; X32-NEXT:    vmovaps %xmm1, (%ebx)
; X32-NEXT:    vmovaps %xmm2, (%edi)
; X32-NEXT:    vmovaps %xmm3, (%esi)
; X32-NEXT:    vmovaps %xmm4, (%edx)
; X32-NEXT:    vmovaps %xmm5, (%ecx)
; X32-NEXT:    popl %esi
; X32-NEXT:    popl %edi
; X32-NEXT:    popl %ebx
; X32-NEXT:    popl %ebp
; X32-NEXT:    retl
entry:
  %0 = tail call { i32, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } @llvm.x86.encodekey256(i32 %htype, <2 x i64> %key_lo, <2 x i64> %key_hi)
  %1 = extractvalue { i32, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 1
  store <2 x i64> %1, <2 x i64>* %h0, align 16
  %2 = extractvalue { i32, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 2
  store <2 x i64> %2, <2 x i64>* %h1, align 16
  %3 = extractvalue { i32, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 3
  store <2 x i64> %3, <2 x i64>* %h2, align 16
  %4 = extractvalue { i32, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 4
  store <2 x i64> %4, <2 x i64>* %h3, align 16
  %5 = extractvalue { i32, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 5
  store <2 x i64> %5, <2 x i64>* %h4, align 16
  %6 = extractvalue { i32, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 6
  store <2 x i64> %6, <2 x i64>* %h5, align 16
  %7 = extractvalue { i32, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 0
  ret i32 %7
}

define i8 @test_mm_aesenc128kl_u8(<2 x i64> %data, i8* %h, <2 x i64>* %out) {
; X64-LABEL: test_mm_aesenc128kl_u8:
; X64:       # %bb.0: # %entry
; X64-NEXT:    aesenc128kl (%rdi), %xmm0
; X64-NEXT:    sete %al
; X64-NEXT:    movaps %xmm0, (%rsi)
; X64-NEXT:    retq
;
; X32-LABEL: test_mm_aesenc128kl_u8:
; X32:       # %bb.0: # %entry
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    aesenc128kl (%eax), %xmm0
; X32-NEXT:    sete %al
; X32-NEXT:    vmovaps %xmm0, (%ecx)
; X32-NEXT:    retl
entry:
  %0 = tail call { i8, <2 x i64> } @llvm.x86.aesenc128kl(<2 x i64> %data, i8* %h)
  %1 = extractvalue { i8, <2 x i64> } %0, 1
  store <2 x i64> %1, <2 x i64>* %out
  %2 = extractvalue { i8, <2 x i64> } %0, 0
  ret i8 %2
}

define i8 @test_mm_aesdec128kl_u8(<2 x i64> %data, i8* %h, <2 x i64>* %out) {
; X64-LABEL: test_mm_aesdec128kl_u8:
; X64:       # %bb.0: # %entry
; X64-NEXT:    aesdec128kl (%rdi), %xmm0
; X64-NEXT:    sete %al
; X64-NEXT:    movaps %xmm0, (%rsi)
; X64-NEXT:    retq
;
; X32-LABEL: test_mm_aesdec128kl_u8:
; X32:       # %bb.0: # %entry
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    aesdec128kl (%eax), %xmm0
; X32-NEXT:    sete %al
; X32-NEXT:    vmovaps %xmm0, (%ecx)
; X32-NEXT:    retl
entry:
  %0 = tail call { i8, <2 x i64> } @llvm.x86.aesdec128kl(<2 x i64> %data, i8* %h)
  %1 = extractvalue { i8, <2 x i64> } %0, 1
  store <2 x i64> %1, <2 x i64>* %out
  %2 = extractvalue { i8, <2 x i64> } %0, 0
  ret i8 %2
}

define i8 @test_mm_aesenc256kl_u8(<2 x i64> %data, i8* %h, <2 x i64>* %out) {
; X64-LABEL: test_mm_aesenc256kl_u8:
; X64:       # %bb.0: # %entry
; X64-NEXT:    aesenc256kl (%rdi), %xmm0
; X64-NEXT:    sete %al
; X64-NEXT:    movaps %xmm0, (%rsi)
; X64-NEXT:    retq
;
; X32-LABEL: test_mm_aesenc256kl_u8:
; X32:       # %bb.0: # %entry
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    aesenc256kl (%eax), %xmm0
; X32-NEXT:    sete %al
; X32-NEXT:    vmovaps %xmm0, (%ecx)
; X32-NEXT:    retl
entry:
  %0 = tail call { i8, <2 x i64> } @llvm.x86.aesenc256kl(<2 x i64> %data, i8* %h)
  %1 = extractvalue { i8, <2 x i64> } %0, 1
  store <2 x i64> %1, <2 x i64>* %out
  %2 = extractvalue { i8, <2 x i64> } %0, 0
  ret i8 %2
}

define i8 @test_mm_aesdec256kl_u8(<2 x i64> %data, i8* %h, <2 x i64>* %out) {
; X64-LABEL: test_mm_aesdec256kl_u8:
; X64:       # %bb.0: # %entry
; X64-NEXT:    aesdec256kl (%rdi), %xmm0
; X64-NEXT:    sete %al
; X64-NEXT:    movaps %xmm0, (%rsi)
; X64-NEXT:    retq
;
; X32-LABEL: test_mm_aesdec256kl_u8:
; X32:       # %bb.0: # %entry
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X32-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    aesdec256kl (%eax), %xmm0
; X32-NEXT:    sete %al
; X32-NEXT:    vmovaps %xmm0, (%ecx)
; X32-NEXT:    retl
entry:
  %0 = tail call { i8, <2 x i64> } @llvm.x86.aesdec256kl(<2 x i64> %data, i8* %h)
  %1 = extractvalue { i8, <2 x i64> } %0, 1
  store <2 x i64> %1, <2 x i64>* %out
  %2 = extractvalue { i8, <2 x i64> } %0, 0
  ret i8 %2
}

define i8 @test_mm_aesencwide128kl_u8(i8* %p, <2 x i64> %v0, <2 x i64> %v1, <2 x i64> %v2, <2 x i64> %v3, <2 x i64> %v4, <2 x i64> %v5, <2 x i64> %v6, <2 x i64> %v7, <2 x i64>* %out0, <2 x i64>* %out1, <2 x i64>* %out2, <2 x i64>* %out3, <2 x i64>* %out4, <2 x i64>* %out5, <2 x i64>* %out6, <2 x i64>* %out7) nounwind {
; X64-LABEL: test_mm_aesencwide128kl_u8:
; X64:       # %bb.0: # %entry
; X64-NEXT:    pushq %rbx
; X64-NEXT:    movq {{[0-9]+}}(%rsp), %r10
; X64-NEXT:    movq {{[0-9]+}}(%rsp), %r11
; X64-NEXT:    movq {{[0-9]+}}(%rsp), %rbx
; X64-NEXT:    aesencwide128kl (%rdi)
; X64-NEXT:    sete %al
; X64-NEXT:    movaps %xmm0, (%rsi)
; X64-NEXT:    movaps %xmm1, (%rdx)
; X64-NEXT:    movaps %xmm1, (%rcx)
; X64-NEXT:    movaps %xmm1, (%r8)
; X64-NEXT:    movaps %xmm1, (%r9)
; X64-NEXT:    movaps %xmm1, (%rbx)
; X64-NEXT:    movaps %xmm1, (%r11)
; X64-NEXT:    movaps %xmm1, (%r10)
; X64-NEXT:    popq %rbx
; X64-NEXT:    retq
;
; X32-LABEL: test_mm_aesencwide128kl_u8:
; X32:       # %bb.0: # %entry
; X32-NEXT:    pushl %ebp
; X32-NEXT:    movl %esp, %ebp
; X32-NEXT:    andl $-16, %esp
; X32-NEXT:    subl $16, %esp
; X32-NEXT:    vmovaps 24(%ebp), %xmm3
; X32-NEXT:    vmovaps 40(%ebp), %xmm4
; X32-NEXT:    vmovaps 56(%ebp), %xmm5
; X32-NEXT:    vmovaps 72(%ebp), %xmm6
; X32-NEXT:    vmovaps 88(%ebp), %xmm7
; X32-NEXT:    movl 8(%ebp), %eax
; X32-NEXT:    aesencwide128kl (%eax)
; X32-NEXT:    movl 104(%ebp), %eax
; X32-NEXT:    vmovaps %xmm0, (%eax)
; X32-NEXT:    movl 108(%ebp), %eax
; X32-NEXT:    vmovaps %xmm1, (%eax)
; X32-NEXT:    movl 112(%ebp), %eax
; X32-NEXT:    vmovaps %xmm1, (%eax)
; X32-NEXT:    movl 116(%ebp), %eax
; X32-NEXT:    vmovaps %xmm1, (%eax)
; X32-NEXT:    movl 120(%ebp), %eax
; X32-NEXT:    vmovaps %xmm1, (%eax)
; X32-NEXT:    movl 124(%ebp), %eax
; X32-NEXT:    vmovaps %xmm1, (%eax)
; X32-NEXT:    movl 128(%ebp), %eax
; X32-NEXT:    vmovaps %xmm1, (%eax)
; X32-NEXT:    movl 132(%ebp), %eax
; X32-NEXT:    vmovaps %xmm1, (%eax)
; X32-NEXT:    sete %al
; X32-NEXT:    movl %ebp, %esp
; X32-NEXT:    popl %ebp
; X32-NEXT:    retl
entry:
  %0 = call { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } @llvm.x86.aesencwide128kl(i8* %p, <2 x i64> %v0, <2 x i64> %v1, <2 x i64> %v2, <2 x i64> %v3, <2 x i64> %v4, <2 x i64> %v5, <2 x i64> %v6,      <2 x i64> %v7)
  %1 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 1
  store <2 x i64> %1, <2 x i64>* %out0
  %2 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 2
  store <2 x i64> %2, <2 x i64>* %out1
  %3 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 3
  store <2 x i64> %2, <2 x i64>* %out2
  %4 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 4
  store <2 x i64> %2, <2 x i64>* %out3
  %5 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 5
  store <2 x i64> %2, <2 x i64>* %out4
  %6 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 6
  store <2 x i64> %2, <2 x i64>* %out5
  %7 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 7
  store <2 x i64> %2, <2 x i64>* %out6
  %8 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 8
  store <2 x i64> %2, <2 x i64>* %out7
  %9 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 0
  ret i8 %9
}

define i8 @test_mm_aesdecwide128kl_u8(i8* %p, <2 x i64> %v0, <2 x i64> %v1, <2 x i64> %v2, <2 x i64> %v3, <2 x i64> %v4, <2 x i64> %v5, <2 x i64> %v6, <2 x i64> %v7, <2 x i64>* %out0, <2 x i64>* %out1, <2 x i64>* %out2, <2 x i64>* %out3, <2 x i64>* %out4, <2 x i64>* %out5, <2 x i64>* %out6, <2 x i64>* %out7) nounwind {
; X64-LABEL: test_mm_aesdecwide128kl_u8:
; X64:       # %bb.0: # %entry
; X64-NEXT:    pushq %rbx
; X64-NEXT:    movq {{[0-9]+}}(%rsp), %r10
; X64-NEXT:    movq {{[0-9]+}}(%rsp), %r11
; X64-NEXT:    movq {{[0-9]+}}(%rsp), %rbx
; X64-NEXT:    aesdecwide128kl (%rdi)
; X64-NEXT:    sete %al
; X64-NEXT:    movaps %xmm0, (%rsi)
; X64-NEXT:    movaps %xmm1, (%rdx)
; X64-NEXT:    movaps %xmm1, (%rcx)
; X64-NEXT:    movaps %xmm1, (%r8)
; X64-NEXT:    movaps %xmm1, (%r9)
; X64-NEXT:    movaps %xmm1, (%rbx)
; X64-NEXT:    movaps %xmm1, (%r11)
; X64-NEXT:    movaps %xmm1, (%r10)
; X64-NEXT:    popq %rbx
; X64-NEXT:    retq
;
; X32-LABEL: test_mm_aesdecwide128kl_u8:
; X32:       # %bb.0: # %entry
; X32-NEXT:    pushl %ebp
; X32-NEXT:    movl %esp, %ebp
; X32-NEXT:    andl $-16, %esp
; X32-NEXT:    subl $16, %esp
; X32-NEXT:    vmovaps 24(%ebp), %xmm3
; X32-NEXT:    vmovaps 40(%ebp), %xmm4
; X32-NEXT:    vmovaps 56(%ebp), %xmm5
; X32-NEXT:    vmovaps 72(%ebp), %xmm6
; X32-NEXT:    vmovaps 88(%ebp), %xmm7
; X32-NEXT:    movl 8(%ebp), %eax
; X32-NEXT:    aesdecwide128kl (%eax)
; X32-NEXT:    movl 104(%ebp), %eax
; X32-NEXT:    vmovaps %xmm0, (%eax)
; X32-NEXT:    movl 108(%ebp), %eax
; X32-NEXT:    vmovaps %xmm1, (%eax)
; X32-NEXT:    movl 112(%ebp), %eax
; X32-NEXT:    vmovaps %xmm1, (%eax)
; X32-NEXT:    movl 116(%ebp), %eax
; X32-NEXT:    vmovaps %xmm1, (%eax)
; X32-NEXT:    movl 120(%ebp), %eax
; X32-NEXT:    vmovaps %xmm1, (%eax)
; X32-NEXT:    movl 124(%ebp), %eax
; X32-NEXT:    vmovaps %xmm1, (%eax)
; X32-NEXT:    movl 128(%ebp), %eax
; X32-NEXT:    vmovaps %xmm1, (%eax)
; X32-NEXT:    movl 132(%ebp), %eax
; X32-NEXT:    vmovaps %xmm1, (%eax)
; X32-NEXT:    sete %al
; X32-NEXT:    movl %ebp, %esp
; X32-NEXT:    popl %ebp
; X32-NEXT:    retl
entry:
  %0 = call { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } @llvm.x86.aesdecwide128kl(i8* %p, <2 x i64> %v0, <2 x i64> %v1, <2 x i64> %v2, <2 x i64> %v3, <2 x i64> %v4, <2 x i64> %v5, <2 x i64> %v6,      <2 x i64> %v7)
  %1 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 1
  store <2 x i64> %1, <2 x i64>* %out0
  %2 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 2
  store <2 x i64> %2, <2 x i64>* %out1
  %3 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 3
  store <2 x i64> %2, <2 x i64>* %out2
  %4 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 4
  store <2 x i64> %2, <2 x i64>* %out3
  %5 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 5
  store <2 x i64> %2, <2 x i64>* %out4
  %6 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 6
  store <2 x i64> %2, <2 x i64>* %out5
  %7 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 7
  store <2 x i64> %2, <2 x i64>* %out6
  %8 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 8
  store <2 x i64> %2, <2 x i64>* %out7
  %9 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 0
  ret i8 %9
}

define i8 @test_mm_aesencwide256kl_u8(i8* %p, <2 x i64> %v0, <2 x i64> %v1, <2 x i64> %v2, <2 x i64> %v3, <2 x i64> %v4, <2 x i64> %v5, <2 x i64> %v6, <2 x i64> %v7, <2 x i64>* %out0, <2 x i64>* %out1, <2 x i64>* %out2, <2 x i64>* %out3, <2 x i64>* %out4, <2 x i64>* %out5, <2 x i64>* %out6, <2 x i64>* %out7) nounwind {
; X64-LABEL: test_mm_aesencwide256kl_u8:
; X64:       # %bb.0: # %entry
; X64-NEXT:    pushq %rbx
; X64-NEXT:    movq {{[0-9]+}}(%rsp), %r10
; X64-NEXT:    movq {{[0-9]+}}(%rsp), %r11
; X64-NEXT:    movq {{[0-9]+}}(%rsp), %rbx
; X64-NEXT:    aesencwide256kl (%rdi)
; X64-NEXT:    sete %al
; X64-NEXT:    movaps %xmm0, (%rsi)
; X64-NEXT:    movaps %xmm1, (%rdx)
; X64-NEXT:    movaps %xmm1, (%rcx)
; X64-NEXT:    movaps %xmm1, (%r8)
; X64-NEXT:    movaps %xmm1, (%r9)
; X64-NEXT:    movaps %xmm1, (%rbx)
; X64-NEXT:    movaps %xmm1, (%r11)
; X64-NEXT:    movaps %xmm1, (%r10)
; X64-NEXT:    popq %rbx
; X64-NEXT:    retq
;
; X32-LABEL: test_mm_aesencwide256kl_u8:
; X32:       # %bb.0: # %entry
; X32-NEXT:    pushl %ebp
; X32-NEXT:    movl %esp, %ebp
; X32-NEXT:    andl $-16, %esp
; X32-NEXT:    subl $16, %esp
; X32-NEXT:    vmovaps 24(%ebp), %xmm3
; X32-NEXT:    vmovaps 40(%ebp), %xmm4
; X32-NEXT:    vmovaps 56(%ebp), %xmm5
; X32-NEXT:    vmovaps 72(%ebp), %xmm6
; X32-NEXT:    vmovaps 88(%ebp), %xmm7
; X32-NEXT:    movl 8(%ebp), %eax
; X32-NEXT:    aesencwide256kl (%eax)
; X32-NEXT:    movl 104(%ebp), %eax
; X32-NEXT:    vmovaps %xmm0, (%eax)
; X32-NEXT:    movl 108(%ebp), %eax
; X32-NEXT:    vmovaps %xmm1, (%eax)
; X32-NEXT:    movl 112(%ebp), %eax
; X32-NEXT:    vmovaps %xmm1, (%eax)
; X32-NEXT:    movl 116(%ebp), %eax
; X32-NEXT:    vmovaps %xmm1, (%eax)
; X32-NEXT:    movl 120(%ebp), %eax
; X32-NEXT:    vmovaps %xmm1, (%eax)
; X32-NEXT:    movl 124(%ebp), %eax
; X32-NEXT:    vmovaps %xmm1, (%eax)
; X32-NEXT:    movl 128(%ebp), %eax
; X32-NEXT:    vmovaps %xmm1, (%eax)
; X32-NEXT:    movl 132(%ebp), %eax
; X32-NEXT:    vmovaps %xmm1, (%eax)
; X32-NEXT:    sete %al
; X32-NEXT:    movl %ebp, %esp
; X32-NEXT:    popl %ebp
; X32-NEXT:    retl
entry:
  %0 = call { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } @llvm.x86.aesencwide256kl(i8* %p, <2 x i64> %v0, <2 x i64> %v1, <2 x i64> %v2, <2 x i64> %v3, <2 x i64> %v4, <2 x i64> %v5, <2 x i64> %v6,      <2 x i64> %v7)
  %1 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 1
  store <2 x i64> %1, <2 x i64>* %out0
  %2 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 2
  store <2 x i64> %2, <2 x i64>* %out1
  %3 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 3
  store <2 x i64> %2, <2 x i64>* %out2
  %4 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 4
  store <2 x i64> %2, <2 x i64>* %out3
  %5 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 5
  store <2 x i64> %2, <2 x i64>* %out4
  %6 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 6
  store <2 x i64> %2, <2 x i64>* %out5
  %7 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 7
  store <2 x i64> %2, <2 x i64>* %out6
  %8 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 8
  store <2 x i64> %2, <2 x i64>* %out7
  %9 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 0
  ret i8 %9
}

define i8 @test_mm_aesdecwide256kl_u8(i8* %p, <2 x i64> %v0, <2 x i64> %v1, <2 x i64> %v2, <2 x i64> %v3, <2 x i64> %v4, <2 x i64> %v5, <2 x i64> %v6, <2 x i64> %v7, <2 x i64>* %out0, <2 x i64>* %out1, <2 x i64>* %out2, <2 x i64>* %out3, <2 x i64>* %out4, <2 x i64>* %out5, <2 x i64>* %out6, <2 x i64>* %out7) nounwind {
; X64-LABEL: test_mm_aesdecwide256kl_u8:
; X64:       # %bb.0: # %entry
; X64-NEXT:    pushq %rbx
; X64-NEXT:    movq {{[0-9]+}}(%rsp), %r10
; X64-NEXT:    movq {{[0-9]+}}(%rsp), %r11
; X64-NEXT:    movq {{[0-9]+}}(%rsp), %rbx
; X64-NEXT:    aesdecwide256kl (%rdi)
; X64-NEXT:    sete %al
; X64-NEXT:    movaps %xmm0, (%rsi)
; X64-NEXT:    movaps %xmm1, (%rdx)
; X64-NEXT:    movaps %xmm1, (%rcx)
; X64-NEXT:    movaps %xmm1, (%r8)
; X64-NEXT:    movaps %xmm1, (%r9)
; X64-NEXT:    movaps %xmm1, (%rbx)
; X64-NEXT:    movaps %xmm1, (%r11)
; X64-NEXT:    movaps %xmm1, (%r10)
; X64-NEXT:    popq %rbx
; X64-NEXT:    retq
;
; X32-LABEL: test_mm_aesdecwide256kl_u8:
; X32:       # %bb.0: # %entry
; X32-NEXT:    pushl %ebp
; X32-NEXT:    movl %esp, %ebp
; X32-NEXT:    andl $-16, %esp
; X32-NEXT:    subl $16, %esp
; X32-NEXT:    vmovaps 24(%ebp), %xmm3
; X32-NEXT:    vmovaps 40(%ebp), %xmm4
; X32-NEXT:    vmovaps 56(%ebp), %xmm5
; X32-NEXT:    vmovaps 72(%ebp), %xmm6
; X32-NEXT:    vmovaps 88(%ebp), %xmm7
; X32-NEXT:    movl 8(%ebp), %eax
; X32-NEXT:    aesdecwide256kl (%eax)
; X32-NEXT:    movl 104(%ebp), %eax
; X32-NEXT:    vmovaps %xmm0, (%eax)
; X32-NEXT:    movl 108(%ebp), %eax
; X32-NEXT:    vmovaps %xmm1, (%eax)
; X32-NEXT:    movl 112(%ebp), %eax
; X32-NEXT:    vmovaps %xmm1, (%eax)
; X32-NEXT:    movl 116(%ebp), %eax
; X32-NEXT:    vmovaps %xmm1, (%eax)
; X32-NEXT:    movl 120(%ebp), %eax
; X32-NEXT:    vmovaps %xmm1, (%eax)
; X32-NEXT:    movl 124(%ebp), %eax
; X32-NEXT:    vmovaps %xmm1, (%eax)
; X32-NEXT:    movl 128(%ebp), %eax
; X32-NEXT:    vmovaps %xmm1, (%eax)
; X32-NEXT:    movl 132(%ebp), %eax
; X32-NEXT:    vmovaps %xmm1, (%eax)
; X32-NEXT:    sete %al
; X32-NEXT:    movl %ebp, %esp
; X32-NEXT:    popl %ebp
; X32-NEXT:    retl
entry:
  %0 = call { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } @llvm.x86.aesdecwide256kl(i8* %p, <2 x i64> %v0, <2 x i64> %v1, <2 x i64> %v2, <2 x i64> %v3, <2 x i64> %v4, <2 x i64> %v5, <2 x i64> %v6,      <2 x i64> %v7)
  %1 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 1
  store <2 x i64> %1, <2 x i64>* %out0
  %2 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 2
  store <2 x i64> %2, <2 x i64>* %out1
  %3 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 3
  store <2 x i64> %2, <2 x i64>* %out2
  %4 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 4
  store <2 x i64> %2, <2 x i64>* %out3
  %5 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 5
  store <2 x i64> %2, <2 x i64>* %out4
  %6 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 6
  store <2 x i64> %2, <2 x i64>* %out5
  %7 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 7
  store <2 x i64> %2, <2 x i64>* %out6
  %8 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 8
  store <2 x i64> %2, <2 x i64>* %out7
  %9 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 0
  ret i8 %9
}

; Tests to make sure we can select an appropriate addressing mode for a global.

@foo = external global [64 x i8]

define i8 @test_mm_aesenc256kl_u8_global(<2 x i64> %data, <2 x i64>* %out) {
; X64-LABEL: test_mm_aesenc256kl_u8_global:
; X64:       # %bb.0: # %entry
; X64-NEXT:    aesenc256kl {{.*}}(%rip), %xmm0
; X64-NEXT:    sete %al
; X64-NEXT:    movaps %xmm0, (%rdi)
; X64-NEXT:    retq
;
; X32-LABEL: test_mm_aesenc256kl_u8_global:
; X32:       # %bb.0: # %entry
; X32-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X32-NEXT:    aesenc256kl foo, %xmm0
; X32-NEXT:    sete %al
; X32-NEXT:    vmovaps %xmm0, (%ecx)
; X32-NEXT:    retl
entry:
  %h = bitcast [64 x i8]* @foo to i8*
  %0 = tail call { i8, <2 x i64> } @llvm.x86.aesenc256kl(<2 x i64> %data, i8* %h)
  %1 = extractvalue { i8, <2 x i64> } %0, 1
  store <2 x i64> %1, <2 x i64>* %out
  %2 = extractvalue { i8, <2 x i64> } %0, 0
  ret i8 %2
}

define i8 @test_mm_aesdecwide256kl_u8_global(<2 x i64> %v0, <2 x i64> %v1, <2 x i64> %v2, <2 x i64> %v3, <2 x i64> %v4, <2 x i64> %v5, <2 x i64> %v6, <2 x i64> %v7, <2 x i64>* %out0, <2 x i64>* %out1, <2 x i64>* %out2, <2 x i64>* %out3, <2 x i64>* %out4, <2 x i64>* %out5, <2 x i64>* %out6, <2 x i64>* %out7) nounwind {
; X64-LABEL: test_mm_aesdecwide256kl_u8_global:
; X64:       # %bb.0: # %entry
; X64-NEXT:    movq {{[0-9]+}}(%rsp), %r10
; X64-NEXT:    movq {{[0-9]+}}(%rsp), %r11
; X64-NEXT:    aesdecwide256kl {{.*}}(%rip)
; X64-NEXT:    sete %al
; X64-NEXT:    movaps %xmm0, (%rdi)
; X64-NEXT:    movaps %xmm1, (%rsi)
; X64-NEXT:    movaps %xmm1, (%rdx)
; X64-NEXT:    movaps %xmm1, (%rcx)
; X64-NEXT:    movaps %xmm1, (%r8)
; X64-NEXT:    movaps %xmm1, (%r9)
; X64-NEXT:    movaps %xmm1, (%r11)
; X64-NEXT:    movaps %xmm1, (%r10)
; X64-NEXT:    retq
;
; X32-LABEL: test_mm_aesdecwide256kl_u8_global:
; X32:       # %bb.0: # %entry
; X32-NEXT:    pushl %ebp
; X32-NEXT:    movl %esp, %ebp
; X32-NEXT:    andl $-16, %esp
; X32-NEXT:    subl $16, %esp
; X32-NEXT:    movl 88(%ebp), %eax
; X32-NEXT:    vmovaps 8(%ebp), %xmm3
; X32-NEXT:    vmovaps 24(%ebp), %xmm4
; X32-NEXT:    vmovaps 40(%ebp), %xmm5
; X32-NEXT:    vmovaps 56(%ebp), %xmm6
; X32-NEXT:    vmovaps 72(%ebp), %xmm7
; X32-NEXT:    aesdecwide256kl foo
; X32-NEXT:    vmovaps %xmm0, (%eax)
; X32-NEXT:    movl 92(%ebp), %eax
; X32-NEXT:    vmovaps %xmm1, (%eax)
; X32-NEXT:    movl 96(%ebp), %eax
; X32-NEXT:    vmovaps %xmm1, (%eax)
; X32-NEXT:    movl 100(%ebp), %eax
; X32-NEXT:    vmovaps %xmm1, (%eax)
; X32-NEXT:    movl 104(%ebp), %eax
; X32-NEXT:    vmovaps %xmm1, (%eax)
; X32-NEXT:    movl 108(%ebp), %eax
; X32-NEXT:    vmovaps %xmm1, (%eax)
; X32-NEXT:    movl 112(%ebp), %eax
; X32-NEXT:    vmovaps %xmm1, (%eax)
; X32-NEXT:    movl 116(%ebp), %eax
; X32-NEXT:    vmovaps %xmm1, (%eax)
; X32-NEXT:    sete %al
; X32-NEXT:    movl %ebp, %esp
; X32-NEXT:    popl %ebp
; X32-NEXT:    retl
entry:
  %p = bitcast [64 x i8]* @foo to i8*
  %0 = call { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } @llvm.x86.aesdecwide256kl(i8* %p, <2 x i64> %v0, <2 x i64> %v1, <2 x i64> %v2, <2 x i64> %v3, <2 x i64> %v4, <2 x i64> %v5, <2 x i64> %v6,      <2 x i64> %v7)
  %1 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 1
  store <2 x i64> %1, <2 x i64>* %out0
  %2 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 2
  store <2 x i64> %2, <2 x i64>* %out1
  %3 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 3
  store <2 x i64> %2, <2 x i64>* %out2
  %4 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 4
  store <2 x i64> %2, <2 x i64>* %out3
  %5 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 5
  store <2 x i64> %2, <2 x i64>* %out4
  %6 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 6
  store <2 x i64> %2, <2 x i64>* %out5
  %7 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 7
  store <2 x i64> %2, <2 x i64>* %out6
  %8 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 8
  store <2 x i64> %2, <2 x i64>* %out7
  %9 = extractvalue { i8, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64> } %0, 0
  ret i8 %9
}
