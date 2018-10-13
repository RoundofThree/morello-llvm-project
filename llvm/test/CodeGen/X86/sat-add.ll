; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-- -mattr=+sse2   | FileCheck %s --check-prefixes=ANY,SSE,SSE2
; RUN: llc < %s -mtriple=x86_64-- -mattr=+sse4.1 | FileCheck %s --check-prefixes=ANY,SSE,SSE41

; There are at least 3 potential patterns corresponding to an unsigned saturated add: min, cmp with sum, cmp with not.
; Test each of those patterns with i8/i16/i32/i64.
; Test each of those with a constant operand and a variable operand.
; Test each of those with a 128-bit vector type.

define i8 @unsigned_sat_constant_i8_using_min(i8 %x) {
; ANY-LABEL: unsigned_sat_constant_i8_using_min:
; ANY:       # %bb.0:
; ANY-NEXT:    movl %edi, %eax
; ANY-NEXT:    cmpb $-43, %al
; ANY-NEXT:    jb .LBB0_2
; ANY-NEXT:  # %bb.1:
; ANY-NEXT:    movb $-43, %al
; ANY-NEXT:  .LBB0_2:
; ANY-NEXT:    addb $42, %al
; ANY-NEXT:    # kill: def $al killed $al killed $eax
; ANY-NEXT:    retq
  %c = icmp ult i8 %x, -43
  %s = select i1 %c, i8 %x, i8 -43
  %r = add i8 %s, 42
  ret i8 %r
}

define i8 @unsigned_sat_constant_i8_using_cmp_sum(i8 %x) {
; ANY-LABEL: unsigned_sat_constant_i8_using_cmp_sum:
; ANY:       # %bb.0:
; ANY-NEXT:    addb $42, %dil
; ANY-NEXT:    movb $-1, %al
; ANY-NEXT:    jb .LBB1_2
; ANY-NEXT:  # %bb.1:
; ANY-NEXT:    movl %edi, %eax
; ANY-NEXT:  .LBB1_2:
; ANY-NEXT:    retq
  %a = add i8 %x, 42
  %c = icmp ugt i8 %x, %a
  %r = select i1 %c, i8 -1, i8 %a
  ret i8 %r
}

define i8 @unsigned_sat_constant_i8_using_cmp_notval(i8 %x) {
; ANY-LABEL: unsigned_sat_constant_i8_using_cmp_notval:
; ANY:       # %bb.0:
; ANY-NEXT:    addb $42, %dil
; ANY-NEXT:    movb $-1, %al
; ANY-NEXT:    jb .LBB2_2
; ANY-NEXT:  # %bb.1:
; ANY-NEXT:    movl %edi, %eax
; ANY-NEXT:  .LBB2_2:
; ANY-NEXT:    retq
  %a = add i8 %x, 42
  %c = icmp ugt i8 %x, -43
  %r = select i1 %c, i8 -1, i8 %a
  ret i8 %r
}

define i16 @unsigned_sat_constant_i16_using_min(i16 %x) {
; ANY-LABEL: unsigned_sat_constant_i16_using_min:
; ANY:       # %bb.0:
; ANY-NEXT:    movzwl %di, %eax
; ANY-NEXT:    cmpl $65493, %eax # imm = 0xFFD5
; ANY-NEXT:    movl $65493, %eax # imm = 0xFFD5
; ANY-NEXT:    cmovbl %edi, %eax
; ANY-NEXT:    addl $42, %eax
; ANY-NEXT:    # kill: def $ax killed $ax killed $eax
; ANY-NEXT:    retq
  %c = icmp ult i16 %x, -43
  %s = select i1 %c, i16 %x, i16 -43
  %r = add i16 %s, 42
  ret i16 %r
}

define i16 @unsigned_sat_constant_i16_using_cmp_sum(i16 %x) {
; ANY-LABEL: unsigned_sat_constant_i16_using_cmp_sum:
; ANY:       # %bb.0:
; ANY-NEXT:    addw $42, %di
; ANY-NEXT:    movl $65535, %eax # imm = 0xFFFF
; ANY-NEXT:    cmovael %edi, %eax
; ANY-NEXT:    # kill: def $ax killed $ax killed $eax
; ANY-NEXT:    retq
  %a = add i16 %x, 42
  %c = icmp ugt i16 %x, %a
  %r = select i1 %c, i16 -1, i16 %a
  ret i16 %r
}

define i16 @unsigned_sat_constant_i16_using_cmp_notval(i16 %x) {
; ANY-LABEL: unsigned_sat_constant_i16_using_cmp_notval:
; ANY:       # %bb.0:
; ANY-NEXT:    addw $42, %di
; ANY-NEXT:    movl $65535, %eax # imm = 0xFFFF
; ANY-NEXT:    cmovael %edi, %eax
; ANY-NEXT:    # kill: def $ax killed $ax killed $eax
; ANY-NEXT:    retq
  %a = add i16 %x, 42
  %c = icmp ugt i16 %x, -43
  %r = select i1 %c, i16 -1, i16 %a
  ret i16 %r
}

define i32 @unsigned_sat_constant_i32_using_min(i32 %x) {
; ANY-LABEL: unsigned_sat_constant_i32_using_min:
; ANY:       # %bb.0:
; ANY-NEXT:    cmpl $-43, %edi
; ANY-NEXT:    movl $-43, %eax
; ANY-NEXT:    cmovbl %edi, %eax
; ANY-NEXT:    addl $42, %eax
; ANY-NEXT:    retq
  %c = icmp ult i32 %x, -43
  %s = select i1 %c, i32 %x, i32 -43
  %r = add i32 %s, 42
  ret i32 %r
}

define i32 @unsigned_sat_constant_i32_using_cmp_sum(i32 %x) {
; ANY-LABEL: unsigned_sat_constant_i32_using_cmp_sum:
; ANY:       # %bb.0:
; ANY-NEXT:    addl $42, %edi
; ANY-NEXT:    movl $-1, %eax
; ANY-NEXT:    cmovael %edi, %eax
; ANY-NEXT:    retq
  %a = add i32 %x, 42
  %c = icmp ugt i32 %x, %a
  %r = select i1 %c, i32 -1, i32 %a
  ret i32 %r
}

define i32 @unsigned_sat_constant_i32_using_cmp_notval(i32 %x) {
; ANY-LABEL: unsigned_sat_constant_i32_using_cmp_notval:
; ANY:       # %bb.0:
; ANY-NEXT:    addl $42, %edi
; ANY-NEXT:    movl $-1, %eax
; ANY-NEXT:    cmovael %edi, %eax
; ANY-NEXT:    retq
  %a = add i32 %x, 42
  %c = icmp ugt i32 %x, -43
  %r = select i1 %c, i32 -1, i32 %a
  ret i32 %r
}

define i64 @unsigned_sat_constant_i64_using_min(i64 %x) {
; ANY-LABEL: unsigned_sat_constant_i64_using_min:
; ANY:       # %bb.0:
; ANY-NEXT:    cmpq $-43, %rdi
; ANY-NEXT:    movq $-43, %rax
; ANY-NEXT:    cmovbq %rdi, %rax
; ANY-NEXT:    addq $42, %rax
; ANY-NEXT:    retq
  %c = icmp ult i64 %x, -43
  %s = select i1 %c, i64 %x, i64 -43
  %r = add i64 %s, 42
  ret i64 %r
}

define i64 @unsigned_sat_constant_i64_using_cmp_sum(i64 %x) {
; ANY-LABEL: unsigned_sat_constant_i64_using_cmp_sum:
; ANY:       # %bb.0:
; ANY-NEXT:    addq $42, %rdi
; ANY-NEXT:    movq $-1, %rax
; ANY-NEXT:    cmovaeq %rdi, %rax
; ANY-NEXT:    retq
  %a = add i64 %x, 42
  %c = icmp ugt i64 %x, %a
  %r = select i1 %c, i64 -1, i64 %a
  ret i64 %r
}

define i64 @unsigned_sat_constant_i64_using_cmp_notval(i64 %x) {
; ANY-LABEL: unsigned_sat_constant_i64_using_cmp_notval:
; ANY:       # %bb.0:
; ANY-NEXT:    addq $42, %rdi
; ANY-NEXT:    movq $-1, %rax
; ANY-NEXT:    cmovaeq %rdi, %rax
; ANY-NEXT:    retq
  %a = add i64 %x, 42
  %c = icmp ugt i64 %x, -43
  %r = select i1 %c, i64 -1, i64 %a
  ret i64 %r
}

define i8 @unsigned_sat_variable_i8_using_min(i8 %x, i8 %y) {
; ANY-LABEL: unsigned_sat_variable_i8_using_min:
; ANY:       # %bb.0:
; ANY-NEXT:    movl %edi, %eax
; ANY-NEXT:    movl %esi, %ecx
; ANY-NEXT:    notb %cl
; ANY-NEXT:    cmpb %cl, %al
; ANY-NEXT:    jb .LBB12_2
; ANY-NEXT:  # %bb.1:
; ANY-NEXT:    movl %ecx, %eax
; ANY-NEXT:  .LBB12_2:
; ANY-NEXT:    addb %sil, %al
; ANY-NEXT:    # kill: def $al killed $al killed $eax
; ANY-NEXT:    retq
  %noty = xor i8 %y, -1
  %c = icmp ult i8 %x, %noty
  %s = select i1 %c, i8 %x, i8 %noty
  %r = add i8 %s, %y
  ret i8 %r
}

define i8 @unsigned_sat_variable_i8_using_cmp_sum(i8 %x, i8 %y) {
; ANY-LABEL: unsigned_sat_variable_i8_using_cmp_sum:
; ANY:       # %bb.0:
; ANY-NEXT:    addb %sil, %dil
; ANY-NEXT:    movb $-1, %al
; ANY-NEXT:    jb .LBB13_2
; ANY-NEXT:  # %bb.1:
; ANY-NEXT:    movl %edi, %eax
; ANY-NEXT:  .LBB13_2:
; ANY-NEXT:    retq
  %a = add i8 %x, %y
  %c = icmp ugt i8 %x, %a
  %r = select i1 %c, i8 -1, i8 %a
  ret i8 %r
}

define i8 @unsigned_sat_variable_i8_using_cmp_notval(i8 %x, i8 %y) {
; ANY-LABEL: unsigned_sat_variable_i8_using_cmp_notval:
; ANY:       # %bb.0:
; ANY-NEXT:    movl %esi, %eax
; ANY-NEXT:    notb %al
; ANY-NEXT:    cmpb %al, %dil
; ANY-NEXT:    movb $-1, %al
; ANY-NEXT:    ja .LBB14_2
; ANY-NEXT:  # %bb.1:
; ANY-NEXT:    addb %sil, %dil
; ANY-NEXT:    movl %edi, %eax
; ANY-NEXT:  .LBB14_2:
; ANY-NEXT:    retq
  %noty = xor i8 %y, -1
  %a = add i8 %x, %y
  %c = icmp ugt i8 %x, %noty
  %r = select i1 %c, i8 -1, i8 %a
  ret i8 %r
}

define i16 @unsigned_sat_variable_i16_using_min(i16 %x, i16 %y) {
; ANY-LABEL: unsigned_sat_variable_i16_using_min:
; ANY:       # %bb.0:
; ANY-NEXT:    # kill: def $esi killed $esi def $rsi
; ANY-NEXT:    movl %esi, %eax
; ANY-NEXT:    notl %eax
; ANY-NEXT:    cmpw %ax, %di
; ANY-NEXT:    cmovbl %edi, %eax
; ANY-NEXT:    leal (%rax,%rsi), %eax
; ANY-NEXT:    # kill: def $ax killed $ax killed $eax
; ANY-NEXT:    retq
  %noty = xor i16 %y, -1
  %c = icmp ult i16 %x, %noty
  %s = select i1 %c, i16 %x, i16 %noty
  %r = add i16 %s, %y
  ret i16 %r
}

define i16 @unsigned_sat_variable_i16_using_cmp_sum(i16 %x, i16 %y) {
; ANY-LABEL: unsigned_sat_variable_i16_using_cmp_sum:
; ANY:       # %bb.0:
; ANY-NEXT:    addw %si, %di
; ANY-NEXT:    movl $65535, %eax # imm = 0xFFFF
; ANY-NEXT:    cmovael %edi, %eax
; ANY-NEXT:    # kill: def $ax killed $ax killed $eax
; ANY-NEXT:    retq
  %a = add i16 %x, %y
  %c = icmp ugt i16 %x, %a
  %r = select i1 %c, i16 -1, i16 %a
  ret i16 %r
}

define i16 @unsigned_sat_variable_i16_using_cmp_notval(i16 %x, i16 %y) {
; ANY-LABEL: unsigned_sat_variable_i16_using_cmp_notval:
; ANY:       # %bb.0:
; ANY-NEXT:    # kill: def $esi killed $esi def $rsi
; ANY-NEXT:    # kill: def $edi killed $edi def $rdi
; ANY-NEXT:    leal (%rdi,%rsi), %ecx
; ANY-NEXT:    notl %esi
; ANY-NEXT:    cmpw %si, %di
; ANY-NEXT:    movl $65535, %eax # imm = 0xFFFF
; ANY-NEXT:    cmovbel %ecx, %eax
; ANY-NEXT:    # kill: def $ax killed $ax killed $eax
; ANY-NEXT:    retq
  %noty = xor i16 %y, -1
  %a = add i16 %x, %y
  %c = icmp ugt i16 %x, %noty
  %r = select i1 %c, i16 -1, i16 %a
  ret i16 %r
}

define i32 @unsigned_sat_variable_i32_using_min(i32 %x, i32 %y) {
; ANY-LABEL: unsigned_sat_variable_i32_using_min:
; ANY:       # %bb.0:
; ANY-NEXT:    # kill: def $esi killed $esi def $rsi
; ANY-NEXT:    movl %esi, %eax
; ANY-NEXT:    notl %eax
; ANY-NEXT:    cmpl %eax, %edi
; ANY-NEXT:    cmovbl %edi, %eax
; ANY-NEXT:    leal (%rax,%rsi), %eax
; ANY-NEXT:    retq
  %noty = xor i32 %y, -1
  %c = icmp ult i32 %x, %noty
  %s = select i1 %c, i32 %x, i32 %noty
  %r = add i32 %s, %y
  ret i32 %r
}

define i32 @unsigned_sat_variable_i32_using_cmp_sum(i32 %x, i32 %y) {
; ANY-LABEL: unsigned_sat_variable_i32_using_cmp_sum:
; ANY:       # %bb.0:
; ANY-NEXT:    addl %esi, %edi
; ANY-NEXT:    movl $-1, %eax
; ANY-NEXT:    cmovael %edi, %eax
; ANY-NEXT:    retq
  %a = add i32 %x, %y
  %c = icmp ugt i32 %x, %a
  %r = select i1 %c, i32 -1, i32 %a
  ret i32 %r
}

define i32 @unsigned_sat_variable_i32_using_cmp_notval(i32 %x, i32 %y) {
; ANY-LABEL: unsigned_sat_variable_i32_using_cmp_notval:
; ANY:       # %bb.0:
; ANY-NEXT:    # kill: def $esi killed $esi def $rsi
; ANY-NEXT:    # kill: def $edi killed $edi def $rdi
; ANY-NEXT:    leal (%rdi,%rsi), %ecx
; ANY-NEXT:    notl %esi
; ANY-NEXT:    cmpl %esi, %edi
; ANY-NEXT:    movl $-1, %eax
; ANY-NEXT:    cmovbel %ecx, %eax
; ANY-NEXT:    retq
  %noty = xor i32 %y, -1
  %a = add i32 %x, %y
  %c = icmp ugt i32 %x, %noty
  %r = select i1 %c, i32 -1, i32 %a
  ret i32 %r
}

define i64 @unsigned_sat_variable_i64_using_min(i64 %x, i64 %y) {
; ANY-LABEL: unsigned_sat_variable_i64_using_min:
; ANY:       # %bb.0:
; ANY-NEXT:    movq %rsi, %rax
; ANY-NEXT:    notq %rax
; ANY-NEXT:    cmpq %rax, %rdi
; ANY-NEXT:    cmovbq %rdi, %rax
; ANY-NEXT:    leaq (%rax,%rsi), %rax
; ANY-NEXT:    retq
  %noty = xor i64 %y, -1
  %c = icmp ult i64 %x, %noty
  %s = select i1 %c, i64 %x, i64 %noty
  %r = add i64 %s, %y
  ret i64 %r
}

define i64 @unsigned_sat_variable_i64_using_cmp_sum(i64 %x, i64 %y) {
; ANY-LABEL: unsigned_sat_variable_i64_using_cmp_sum:
; ANY:       # %bb.0:
; ANY-NEXT:    addq %rsi, %rdi
; ANY-NEXT:    movq $-1, %rax
; ANY-NEXT:    cmovaeq %rdi, %rax
; ANY-NEXT:    retq
  %a = add i64 %x, %y
  %c = icmp ugt i64 %x, %a
  %r = select i1 %c, i64 -1, i64 %a
  ret i64 %r
}

define i64 @unsigned_sat_variable_i64_using_cmp_notval(i64 %x, i64 %y) {
; ANY-LABEL: unsigned_sat_variable_i64_using_cmp_notval:
; ANY:       # %bb.0:
; ANY-NEXT:    leaq (%rdi,%rsi), %rcx
; ANY-NEXT:    notq %rsi
; ANY-NEXT:    cmpq %rsi, %rdi
; ANY-NEXT:    movq $-1, %rax
; ANY-NEXT:    cmovbeq %rcx, %rax
; ANY-NEXT:    retq
  %noty = xor i64 %y, -1
  %a = add i64 %x, %y
  %c = icmp ugt i64 %x, %noty
  %r = select i1 %c, i64 -1, i64 %a
  ret i64 %r
}

define <16 x i8> @unsigned_sat_constant_v16i8_using_min(<16 x i8> %x) {
; ANY-LABEL: unsigned_sat_constant_v16i8_using_min:
; ANY:       # %bb.0:
; ANY-NEXT:    pminub {{.*}}(%rip), %xmm0
; ANY-NEXT:    paddb {{.*}}(%rip), %xmm0
; ANY-NEXT:    retq
  %c = icmp ult <16 x i8> %x, <i8 -43, i8 -43, i8 -43, i8 -43, i8 -43, i8 -43, i8 -43, i8 -43, i8 -43, i8 -43, i8 -43, i8 -43, i8 -43, i8 -43, i8 -43, i8 -43>
  %s = select <16 x i1> %c, <16 x i8> %x, <16 x i8> <i8 -43, i8 -43, i8 -43, i8 -43, i8 -43, i8 -43, i8 -43, i8 -43, i8 -43, i8 -43, i8 -43, i8 -43, i8 -43, i8 -43, i8 -43, i8 -43>
  %r = add <16 x i8> %s, <i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42>
  ret <16 x i8> %r
}

define <16 x i8> @unsigned_sat_constant_v16i8_using_cmp_sum(<16 x i8> %x) {
; ANY-LABEL: unsigned_sat_constant_v16i8_using_cmp_sum:
; ANY:       # %bb.0:
; ANY-NEXT:    paddusb {{.*}}(%rip), %xmm0
; ANY-NEXT:    retq
  %a = add <16 x i8> %x, <i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42>
  %c = icmp ugt <16 x i8> %x, %a
  %r = select <16 x i1> %c, <16 x i8> <i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1>, <16 x i8> %a
  ret <16 x i8> %r
}

define <16 x i8> @unsigned_sat_constant_v16i8_using_cmp_notval(<16 x i8> %x) {
; ANY-LABEL: unsigned_sat_constant_v16i8_using_cmp_notval:
; ANY:       # %bb.0:
; ANY-NEXT:    paddusb {{.*}}(%rip), %xmm0
; ANY-NEXT:    retq
  %a = add <16 x i8> %x, <i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42, i8 42>
  %c = icmp ugt <16 x i8> %x, <i8 -43, i8 -43, i8 -43, i8 -43, i8 -43, i8 -43, i8 -43, i8 -43, i8 -43, i8 -43, i8 -43, i8 -43, i8 -43, i8 -43, i8 -43, i8 -43>
  %r = select <16 x i1> %c, <16 x i8> <i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1>, <16 x i8> %a
  ret <16 x i8> %r
}

define <8 x i16> @unsigned_sat_constant_v8i16_using_min(<8 x i16> %x) {
; SSE2-LABEL: unsigned_sat_constant_v8i16_using_min:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movdqa {{.*#+}} xmm1 = [32768,32768,32768,32768,32768,32768,32768,32768]
; SSE2-NEXT:    pxor %xmm1, %xmm0
; SSE2-NEXT:    pminsw {{.*}}(%rip), %xmm0
; SSE2-NEXT:    pxor %xmm1, %xmm0
; SSE2-NEXT:    paddw {{.*}}(%rip), %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: unsigned_sat_constant_v8i16_using_min:
; SSE41:       # %bb.0:
; SSE41-NEXT:    pminuw {{.*}}(%rip), %xmm0
; SSE41-NEXT:    paddw {{.*}}(%rip), %xmm0
; SSE41-NEXT:    retq
  %c = icmp ult <8 x i16> %x, <i16 -43, i16 -43, i16 -43, i16 -43, i16 -43, i16 -43, i16 -43, i16 -43>
  %s = select <8 x i1> %c, <8 x i16> %x, <8 x i16> <i16 -43, i16 -43, i16 -43, i16 -43, i16 -43, i16 -43, i16 -43, i16 -43>
  %r = add <8 x i16> %s, <i16 42, i16 42, i16 42, i16 42, i16 42, i16 42, i16 42, i16 42>
  ret <8 x i16> %r
}

define <8 x i16> @unsigned_sat_constant_v8i16_using_cmp_sum(<8 x i16> %x) {
; ANY-LABEL: unsigned_sat_constant_v8i16_using_cmp_sum:
; ANY:       # %bb.0:
; ANY-NEXT:    paddusw {{.*}}(%rip), %xmm0
; ANY-NEXT:    retq
  %a = add <8 x i16> %x, <i16 42, i16 42, i16 42, i16 42, i16 42, i16 42, i16 42, i16 42>
  %c = icmp ugt <8 x i16> %x, %a
  %r = select <8 x i1> %c, <8 x i16> <i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1>, <8 x i16> %a
  ret <8 x i16> %r
}

define <8 x i16> @unsigned_sat_constant_v8i16_using_cmp_notval(<8 x i16> %x) {
; ANY-LABEL: unsigned_sat_constant_v8i16_using_cmp_notval:
; ANY:       # %bb.0:
; ANY-NEXT:    paddusw {{.*}}(%rip), %xmm0
; ANY-NEXT:    retq
  %a = add <8 x i16> %x, <i16 42, i16 42, i16 42, i16 42, i16 42, i16 42, i16 42, i16 42>
  %c = icmp ugt <8 x i16> %x, <i16 -43, i16 -43, i16 -43, i16 -43, i16 -43, i16 -43, i16 -43, i16 -43>
  %r = select <8 x i1> %c, <8 x i16> <i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1>, <8 x i16> %a
  ret <8 x i16> %r
}

define <4 x i32> @unsigned_sat_constant_v4i32_using_min(<4 x i32> %x) {
; SSE2-LABEL: unsigned_sat_constant_v4i32_using_min:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movdqa {{.*#+}} xmm1 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    pxor %xmm0, %xmm1
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [2147483605,2147483605,2147483605,2147483605]
; SSE2-NEXT:    pcmpgtd %xmm1, %xmm2
; SSE2-NEXT:    pand %xmm2, %xmm0
; SSE2-NEXT:    pandn {{.*}}(%rip), %xmm2
; SSE2-NEXT:    por %xmm2, %xmm0
; SSE2-NEXT:    paddd {{.*}}(%rip), %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: unsigned_sat_constant_v4i32_using_min:
; SSE41:       # %bb.0:
; SSE41-NEXT:    pminud {{.*}}(%rip), %xmm0
; SSE41-NEXT:    paddd {{.*}}(%rip), %xmm0
; SSE41-NEXT:    retq
  %c = icmp ult <4 x i32> %x, <i32 -43, i32 -43, i32 -43, i32 -43>
  %s = select <4 x i1> %c, <4 x i32> %x, <4 x i32> <i32 -43, i32 -43, i32 -43, i32 -43>
  %r = add <4 x i32> %s, <i32 42, i32 42, i32 42, i32 42>
  ret <4 x i32> %r
}

define <4 x i32> @unsigned_sat_constant_v4i32_using_cmp_sum(<4 x i32> %x) {
; SSE2-LABEL: unsigned_sat_constant_v4i32_using_cmp_sum:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movdqa {{.*#+}} xmm1 = [42,42,42,42]
; SSE2-NEXT:    paddd %xmm0, %xmm1
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    pxor %xmm2, %xmm0
; SSE2-NEXT:    pxor %xmm1, %xmm2
; SSE2-NEXT:    pcmpgtd %xmm2, %xmm0
; SSE2-NEXT:    por %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: unsigned_sat_constant_v4i32_using_cmp_sum:
; SSE41:       # %bb.0:
; SSE41-NEXT:    movdqa {{.*#+}} xmm2 = [42,42,42,42]
; SSE41-NEXT:    paddd %xmm0, %xmm2
; SSE41-NEXT:    movdqa %xmm0, %xmm1
; SSE41-NEXT:    pminud %xmm2, %xmm1
; SSE41-NEXT:    pcmpeqd %xmm0, %xmm1
; SSE41-NEXT:    pcmpeqd %xmm0, %xmm0
; SSE41-NEXT:    pxor %xmm0, %xmm1
; SSE41-NEXT:    por %xmm2, %xmm1
; SSE41-NEXT:    movdqa %xmm1, %xmm0
; SSE41-NEXT:    retq
  %a = add <4 x i32> %x, <i32 42, i32 42, i32 42, i32 42>
  %c = icmp ugt <4 x i32> %x, %a
  %r = select <4 x i1> %c, <4 x i32> <i32 -1, i32 -1, i32 -1, i32 -1>, <4 x i32> %a
  ret <4 x i32> %r
}

define <4 x i32> @unsigned_sat_constant_v4i32_using_cmp_notval(<4 x i32> %x) {
; SSE2-LABEL: unsigned_sat_constant_v4i32_using_cmp_notval:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movdqa {{.*#+}} xmm1 = [42,42,42,42]
; SSE2-NEXT:    paddd %xmm0, %xmm1
; SSE2-NEXT:    pxor {{.*}}(%rip), %xmm0
; SSE2-NEXT:    pcmpgtd {{.*}}(%rip), %xmm0
; SSE2-NEXT:    por %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: unsigned_sat_constant_v4i32_using_cmp_notval:
; SSE41:       # %bb.0:
; SSE41-NEXT:    movdqa {{.*#+}} xmm1 = [42,42,42,42]
; SSE41-NEXT:    paddd %xmm0, %xmm1
; SSE41-NEXT:    movdqa {{.*#+}} xmm2 = [4294967253,4294967253,4294967253,4294967253]
; SSE41-NEXT:    pminud %xmm0, %xmm2
; SSE41-NEXT:    pcmpeqd %xmm2, %xmm0
; SSE41-NEXT:    pcmpeqd %xmm2, %xmm2
; SSE41-NEXT:    pxor %xmm2, %xmm0
; SSE41-NEXT:    por %xmm1, %xmm0
; SSE41-NEXT:    retq
  %a = add <4 x i32> %x, <i32 42, i32 42, i32 42, i32 42>
  %c = icmp ugt <4 x i32> %x, <i32 -43, i32 -43, i32 -43, i32 -43>
  %r = select <4 x i1> %c, <4 x i32> <i32 -1, i32 -1, i32 -1, i32 -1>, <4 x i32> %a
  ret <4 x i32> %r
}

define <2 x i64> @unsigned_sat_constant_v2i64_using_min(<2 x i64> %x) {
; SSE2-LABEL: unsigned_sat_constant_v2i64_using_min:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movdqa {{.*#+}} xmm1 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    pxor %xmm0, %xmm1
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [9223372034707292117,9223372034707292117]
; SSE2-NEXT:    movdqa %xmm2, %xmm3
; SSE2-NEXT:    pcmpgtd %xmm1, %xmm3
; SSE2-NEXT:    pshufd {{.*#+}} xmm4 = xmm3[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm2, %xmm1
; SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[1,1,3,3]
; SSE2-NEXT:    pand %xmm4, %xmm1
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm3[1,1,3,3]
; SSE2-NEXT:    por %xmm1, %xmm2
; SSE2-NEXT:    pand %xmm2, %xmm0
; SSE2-NEXT:    pandn {{.*}}(%rip), %xmm2
; SSE2-NEXT:    por %xmm2, %xmm0
; SSE2-NEXT:    paddq {{.*}}(%rip), %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: unsigned_sat_constant_v2i64_using_min:
; SSE41:       # %bb.0:
; SSE41-NEXT:    movdqa %xmm0, %xmm1
; SSE41-NEXT:    movapd {{.*#+}} xmm2 = [18446744073709551573,18446744073709551573]
; SSE41-NEXT:    movdqa {{.*#+}} xmm0 = [2147483648,2147483648,2147483648,2147483648]
; SSE41-NEXT:    pxor %xmm1, %xmm0
; SSE41-NEXT:    movdqa {{.*#+}} xmm3 = [9223372034707292117,9223372034707292117]
; SSE41-NEXT:    movdqa %xmm3, %xmm4
; SSE41-NEXT:    pcmpgtd %xmm0, %xmm4
; SSE41-NEXT:    pshufd {{.*#+}} xmm5 = xmm4[0,0,2,2]
; SSE41-NEXT:    pcmpeqd %xmm3, %xmm0
; SSE41-NEXT:    pshufd {{.*#+}} xmm3 = xmm0[1,1,3,3]
; SSE41-NEXT:    pand %xmm5, %xmm3
; SSE41-NEXT:    pshufd {{.*#+}} xmm0 = xmm4[1,1,3,3]
; SSE41-NEXT:    por %xmm3, %xmm0
; SSE41-NEXT:    blendvpd %xmm0, %xmm1, %xmm2
; SSE41-NEXT:    paddq {{.*}}(%rip), %xmm2
; SSE41-NEXT:    movdqa %xmm2, %xmm0
; SSE41-NEXT:    retq
  %c = icmp ult <2 x i64> %x, <i64 -43, i64 -43>
  %s = select <2 x i1> %c, <2 x i64> %x, <2 x i64> <i64 -43, i64 -43>
  %r = add <2 x i64> %s, <i64 42, i64 42>
  ret <2 x i64> %r
}

define <2 x i64> @unsigned_sat_constant_v2i64_using_cmp_sum(<2 x i64> %x) {
; ANY-LABEL: unsigned_sat_constant_v2i64_using_cmp_sum:
; ANY:       # %bb.0:
; ANY-NEXT:    movdqa {{.*#+}} xmm1 = [42,42]
; ANY-NEXT:    paddq %xmm0, %xmm1
; ANY-NEXT:    movdqa {{.*#+}} xmm2 = [2147483648,2147483648,2147483648,2147483648]
; ANY-NEXT:    pxor %xmm2, %xmm0
; ANY-NEXT:    pxor %xmm1, %xmm2
; ANY-NEXT:    movdqa %xmm0, %xmm3
; ANY-NEXT:    pcmpgtd %xmm2, %xmm3
; ANY-NEXT:    pshufd {{.*#+}} xmm4 = xmm3[0,0,2,2]
; ANY-NEXT:    pcmpeqd %xmm0, %xmm2
; ANY-NEXT:    pshufd {{.*#+}} xmm2 = xmm2[1,1,3,3]
; ANY-NEXT:    pand %xmm4, %xmm2
; ANY-NEXT:    pshufd {{.*#+}} xmm0 = xmm3[1,1,3,3]
; ANY-NEXT:    por %xmm1, %xmm0
; ANY-NEXT:    por %xmm2, %xmm0
; ANY-NEXT:    retq
  %a = add <2 x i64> %x, <i64 42, i64 42>
  %c = icmp ugt <2 x i64> %x, %a
  %r = select <2 x i1> %c, <2 x i64> <i64 -1, i64 -1>, <2 x i64> %a
  ret <2 x i64> %r
}

define <2 x i64> @unsigned_sat_constant_v2i64_using_cmp_notval(<2 x i64> %x) {
; ANY-LABEL: unsigned_sat_constant_v2i64_using_cmp_notval:
; ANY:       # %bb.0:
; ANY-NEXT:    movdqa {{.*#+}} xmm1 = [42,42]
; ANY-NEXT:    paddq %xmm0, %xmm1
; ANY-NEXT:    pxor {{.*}}(%rip), %xmm0
; ANY-NEXT:    movdqa {{.*#+}} xmm2 = [9223372034707292117,9223372034707292117]
; ANY-NEXT:    movdqa %xmm0, %xmm3
; ANY-NEXT:    pcmpgtd %xmm2, %xmm3
; ANY-NEXT:    pshufd {{.*#+}} xmm4 = xmm3[0,0,2,2]
; ANY-NEXT:    pcmpeqd %xmm2, %xmm0
; ANY-NEXT:    pshufd {{.*#+}} xmm2 = xmm0[1,1,3,3]
; ANY-NEXT:    pand %xmm4, %xmm2
; ANY-NEXT:    pshufd {{.*#+}} xmm0 = xmm3[1,1,3,3]
; ANY-NEXT:    por %xmm1, %xmm0
; ANY-NEXT:    por %xmm2, %xmm0
; ANY-NEXT:    retq
  %a = add <2 x i64> %x, <i64 42, i64 42>
  %c = icmp ugt <2 x i64> %x, <i64 -43, i64 -43>
  %r = select <2 x i1> %c, <2 x i64> <i64 -1, i64 -1>, <2 x i64> %a
  ret <2 x i64> %r
}

define <16 x i8> @unsigned_sat_variable_v16i8_using_min(<16 x i8> %x, <16 x i8> %y) {
; ANY-LABEL: unsigned_sat_variable_v16i8_using_min:
; ANY:       # %bb.0:
; ANY-NEXT:    pcmpeqd %xmm2, %xmm2
; ANY-NEXT:    pxor %xmm1, %xmm2
; ANY-NEXT:    pminub %xmm2, %xmm0
; ANY-NEXT:    paddb %xmm1, %xmm0
; ANY-NEXT:    retq
  %noty = xor <16 x i8> %y, <i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1>
  %c = icmp ult <16 x i8> %x, %noty
  %s = select <16 x i1> %c, <16 x i8> %x, <16 x i8> %noty
  %r = add <16 x i8> %s, %y
  ret <16 x i8> %r
}

define <16 x i8> @unsigned_sat_variable_v16i8_using_cmp_sum(<16 x i8> %x, <16 x i8> %y) {
; ANY-LABEL: unsigned_sat_variable_v16i8_using_cmp_sum:
; ANY:       # %bb.0:
; ANY-NEXT:    paddusb %xmm1, %xmm0
; ANY-NEXT:    retq
  %a = add <16 x i8> %x, %y
  %c = icmp ugt <16 x i8> %x, %a
  %r = select <16 x i1> %c, <16 x i8> <i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1>, <16 x i8> %a
  ret <16 x i8> %r
}

define <16 x i8> @unsigned_sat_variable_v16i8_using_cmp_notval(<16 x i8> %x, <16 x i8> %y) {
; ANY-LABEL: unsigned_sat_variable_v16i8_using_cmp_notval:
; ANY:       # %bb.0:
; ANY-NEXT:    pcmpeqd %xmm2, %xmm2
; ANY-NEXT:    movdqa %xmm0, %xmm3
; ANY-NEXT:    paddb %xmm1, %xmm3
; ANY-NEXT:    pxor %xmm2, %xmm1
; ANY-NEXT:    pminub %xmm0, %xmm1
; ANY-NEXT:    pcmpeqb %xmm1, %xmm0
; ANY-NEXT:    pxor %xmm2, %xmm0
; ANY-NEXT:    por %xmm3, %xmm0
; ANY-NEXT:    retq
  %noty = xor <16 x i8> %y, <i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1>
  %a = add <16 x i8> %x, %y
  %c = icmp ugt <16 x i8> %x, %noty
  %r = select <16 x i1> %c, <16 x i8> <i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1>, <16 x i8> %a
  ret <16 x i8> %r
}

define <8 x i16> @unsigned_sat_variable_v8i16_using_min(<8 x i16> %x, <8 x i16> %y) {
; SSE2-LABEL: unsigned_sat_variable_v8i16_using_min:
; SSE2:       # %bb.0:
; SSE2-NEXT:    pcmpeqd %xmm2, %xmm2
; SSE2-NEXT:    movdqa {{.*#+}} xmm3 = [32768,32768,32768,32768,32768,32768,32768,32768]
; SSE2-NEXT:    pxor %xmm3, %xmm0
; SSE2-NEXT:    pxor %xmm3, %xmm2
; SSE2-NEXT:    pxor %xmm1, %xmm2
; SSE2-NEXT:    pminsw %xmm2, %xmm0
; SSE2-NEXT:    pxor %xmm3, %xmm0
; SSE2-NEXT:    paddw %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: unsigned_sat_variable_v8i16_using_min:
; SSE41:       # %bb.0:
; SSE41-NEXT:    pcmpeqd %xmm2, %xmm2
; SSE41-NEXT:    pxor %xmm1, %xmm2
; SSE41-NEXT:    pminuw %xmm2, %xmm0
; SSE41-NEXT:    paddw %xmm1, %xmm0
; SSE41-NEXT:    retq
  %noty = xor <8 x i16> %y, <i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1>
  %c = icmp ult <8 x i16> %x, %noty
  %s = select <8 x i1> %c, <8 x i16> %x, <8 x i16> %noty
  %r = add <8 x i16> %s, %y
  ret <8 x i16> %r
}

define <8 x i16> @unsigned_sat_variable_v8i16_using_cmp_sum(<8 x i16> %x, <8 x i16> %y) {
; ANY-LABEL: unsigned_sat_variable_v8i16_using_cmp_sum:
; ANY:       # %bb.0:
; ANY-NEXT:    paddusw %xmm1, %xmm0
; ANY-NEXT:    retq
  %a = add <8 x i16> %x, %y
  %c = icmp ugt <8 x i16> %x, %a
  %r = select <8 x i1> %c, <8 x i16> <i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1>, <8 x i16> %a
  ret <8 x i16> %r
}

define <8 x i16> @unsigned_sat_variable_v8i16_using_cmp_notval(<8 x i16> %x, <8 x i16> %y) {
; SSE2-LABEL: unsigned_sat_variable_v8i16_using_cmp_notval:
; SSE2:       # %bb.0:
; SSE2-NEXT:    pcmpeqd %xmm2, %xmm2
; SSE2-NEXT:    movdqa %xmm0, %xmm3
; SSE2-NEXT:    paddw %xmm1, %xmm3
; SSE2-NEXT:    movdqa {{.*#+}} xmm4 = [32768,32768,32768,32768,32768,32768,32768,32768]
; SSE2-NEXT:    pxor %xmm4, %xmm0
; SSE2-NEXT:    pxor %xmm4, %xmm2
; SSE2-NEXT:    pxor %xmm1, %xmm2
; SSE2-NEXT:    pcmpgtw %xmm2, %xmm0
; SSE2-NEXT:    por %xmm3, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: unsigned_sat_variable_v8i16_using_cmp_notval:
; SSE41:       # %bb.0:
; SSE41-NEXT:    pcmpeqd %xmm2, %xmm2
; SSE41-NEXT:    movdqa %xmm0, %xmm3
; SSE41-NEXT:    paddw %xmm1, %xmm3
; SSE41-NEXT:    pxor %xmm2, %xmm1
; SSE41-NEXT:    pminuw %xmm0, %xmm1
; SSE41-NEXT:    pcmpeqw %xmm1, %xmm0
; SSE41-NEXT:    pxor %xmm2, %xmm0
; SSE41-NEXT:    por %xmm3, %xmm0
; SSE41-NEXT:    retq
  %noty = xor <8 x i16> %y, <i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1>
  %a = add <8 x i16> %x, %y
  %c = icmp ugt <8 x i16> %x, %noty
  %r = select <8 x i1> %c, <8 x i16> <i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1>, <8 x i16> %a
  ret <8 x i16> %r
}

define <4 x i32> @unsigned_sat_variable_v4i32_using_min(<4 x i32> %x, <4 x i32> %y) {
; SSE2-LABEL: unsigned_sat_variable_v4i32_using_min:
; SSE2:       # %bb.0:
; SSE2-NEXT:    pcmpeqd %xmm2, %xmm2
; SSE2-NEXT:    movdqa {{.*#+}} xmm3 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm0, %xmm4
; SSE2-NEXT:    pxor %xmm3, %xmm4
; SSE2-NEXT:    pxor %xmm2, %xmm3
; SSE2-NEXT:    pxor %xmm1, %xmm3
; SSE2-NEXT:    pcmpgtd %xmm4, %xmm3
; SSE2-NEXT:    pand %xmm3, %xmm0
; SSE2-NEXT:    pxor %xmm2, %xmm3
; SSE2-NEXT:    movdqa %xmm1, %xmm2
; SSE2-NEXT:    pandn %xmm3, %xmm2
; SSE2-NEXT:    por %xmm2, %xmm0
; SSE2-NEXT:    paddd %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: unsigned_sat_variable_v4i32_using_min:
; SSE41:       # %bb.0:
; SSE41-NEXT:    pcmpeqd %xmm2, %xmm2
; SSE41-NEXT:    pxor %xmm1, %xmm2
; SSE41-NEXT:    pminud %xmm2, %xmm0
; SSE41-NEXT:    paddd %xmm1, %xmm0
; SSE41-NEXT:    retq
  %noty = xor <4 x i32> %y, <i32 -1, i32 -1, i32 -1, i32 -1>
  %c = icmp ult <4 x i32> %x, %noty
  %s = select <4 x i1> %c, <4 x i32> %x, <4 x i32> %noty
  %r = add <4 x i32> %s, %y
  ret <4 x i32> %r
}

define <4 x i32> @unsigned_sat_variable_v4i32_using_cmp_sum(<4 x i32> %x, <4 x i32> %y) {
; SSE2-LABEL: unsigned_sat_variable_v4i32_using_cmp_sum:
; SSE2:       # %bb.0:
; SSE2-NEXT:    paddd %xmm0, %xmm1
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    pxor %xmm2, %xmm0
; SSE2-NEXT:    pxor %xmm1, %xmm2
; SSE2-NEXT:    pcmpgtd %xmm2, %xmm0
; SSE2-NEXT:    por %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: unsigned_sat_variable_v4i32_using_cmp_sum:
; SSE41:       # %bb.0:
; SSE41-NEXT:    paddd %xmm0, %xmm1
; SSE41-NEXT:    movdqa %xmm0, %xmm2
; SSE41-NEXT:    pminud %xmm1, %xmm2
; SSE41-NEXT:    pcmpeqd %xmm0, %xmm2
; SSE41-NEXT:    pcmpeqd %xmm0, %xmm0
; SSE41-NEXT:    pxor %xmm0, %xmm2
; SSE41-NEXT:    por %xmm1, %xmm2
; SSE41-NEXT:    movdqa %xmm2, %xmm0
; SSE41-NEXT:    retq
  %a = add <4 x i32> %x, %y
  %c = icmp ugt <4 x i32> %x, %a
  %r = select <4 x i1> %c, <4 x i32> <i32 -1, i32 -1, i32 -1, i32 -1>, <4 x i32> %a
  ret <4 x i32> %r
}

define <4 x i32> @unsigned_sat_variable_v4i32_using_cmp_notval(<4 x i32> %x, <4 x i32> %y) {
; SSE2-LABEL: unsigned_sat_variable_v4i32_using_cmp_notval:
; SSE2:       # %bb.0:
; SSE2-NEXT:    pcmpeqd %xmm2, %xmm2
; SSE2-NEXT:    movdqa %xmm0, %xmm3
; SSE2-NEXT:    paddd %xmm1, %xmm3
; SSE2-NEXT:    movdqa {{.*#+}} xmm4 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    pxor %xmm4, %xmm0
; SSE2-NEXT:    pxor %xmm4, %xmm2
; SSE2-NEXT:    pxor %xmm1, %xmm2
; SSE2-NEXT:    pcmpgtd %xmm2, %xmm0
; SSE2-NEXT:    por %xmm3, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: unsigned_sat_variable_v4i32_using_cmp_notval:
; SSE41:       # %bb.0:
; SSE41-NEXT:    pcmpeqd %xmm2, %xmm2
; SSE41-NEXT:    movdqa %xmm0, %xmm3
; SSE41-NEXT:    paddd %xmm1, %xmm3
; SSE41-NEXT:    pxor %xmm2, %xmm1
; SSE41-NEXT:    pminud %xmm0, %xmm1
; SSE41-NEXT:    pcmpeqd %xmm1, %xmm0
; SSE41-NEXT:    pxor %xmm2, %xmm0
; SSE41-NEXT:    por %xmm3, %xmm0
; SSE41-NEXT:    retq
  %noty = xor <4 x i32> %y, <i32 -1, i32 -1, i32 -1, i32 -1>
  %a = add <4 x i32> %x, %y
  %c = icmp ugt <4 x i32> %x, %noty
  %r = select <4 x i1> %c, <4 x i32> <i32 -1, i32 -1, i32 -1, i32 -1>, <4 x i32> %a
  ret <4 x i32> %r
}

define <2 x i64> @unsigned_sat_variable_v2i64_using_min(<2 x i64> %x, <2 x i64> %y) {
; SSE2-LABEL: unsigned_sat_variable_v2i64_using_min:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    pcmpeqd %xmm3, %xmm3
; SSE2-NEXT:    movdqa %xmm0, %xmm4
; SSE2-NEXT:    pxor %xmm2, %xmm4
; SSE2-NEXT:    pxor %xmm3, %xmm2
; SSE2-NEXT:    pxor %xmm1, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm5
; SSE2-NEXT:    pcmpgtd %xmm4, %xmm5
; SSE2-NEXT:    pshufd {{.*#+}} xmm6 = xmm5[0,0,2,2]
; SSE2-NEXT:    pcmpeqd %xmm4, %xmm2
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm2[1,1,3,3]
; SSE2-NEXT:    pand %xmm6, %xmm2
; SSE2-NEXT:    pshufd {{.*#+}} xmm4 = xmm5[1,1,3,3]
; SSE2-NEXT:    por %xmm2, %xmm4
; SSE2-NEXT:    pand %xmm4, %xmm0
; SSE2-NEXT:    pxor %xmm3, %xmm4
; SSE2-NEXT:    movdqa %xmm1, %xmm2
; SSE2-NEXT:    pandn %xmm4, %xmm2
; SSE2-NEXT:    por %xmm2, %xmm0
; SSE2-NEXT:    paddq %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: unsigned_sat_variable_v2i64_using_min:
; SSE41:       # %bb.0:
; SSE41-NEXT:    movdqa %xmm0, %xmm2
; SSE41-NEXT:    pcmpeqd %xmm3, %xmm3
; SSE41-NEXT:    pxor %xmm1, %xmm3
; SSE41-NEXT:    movdqa {{.*#+}} xmm0 = [2147483648,2147483648,2147483648,2147483648]
; SSE41-NEXT:    movdqa %xmm2, %xmm4
; SSE41-NEXT:    pxor %xmm0, %xmm4
; SSE41-NEXT:    pxor %xmm3, %xmm0
; SSE41-NEXT:    movdqa %xmm0, %xmm5
; SSE41-NEXT:    pcmpgtd %xmm4, %xmm5
; SSE41-NEXT:    pshufd {{.*#+}} xmm6 = xmm5[0,0,2,2]
; SSE41-NEXT:    pcmpeqd %xmm4, %xmm0
; SSE41-NEXT:    pshufd {{.*#+}} xmm4 = xmm0[1,1,3,3]
; SSE41-NEXT:    pand %xmm6, %xmm4
; SSE41-NEXT:    pshufd {{.*#+}} xmm0 = xmm5[1,1,3,3]
; SSE41-NEXT:    por %xmm4, %xmm0
; SSE41-NEXT:    blendvpd %xmm0, %xmm2, %xmm3
; SSE41-NEXT:    paddq %xmm1, %xmm3
; SSE41-NEXT:    movdqa %xmm3, %xmm0
; SSE41-NEXT:    retq
  %noty = xor <2 x i64> %y, <i64 -1, i64 -1>
  %c = icmp ult <2 x i64> %x, %noty
  %s = select <2 x i1> %c, <2 x i64> %x, <2 x i64> %noty
  %r = add <2 x i64> %s, %y
  ret <2 x i64> %r
}

define <2 x i64> @unsigned_sat_variable_v2i64_using_cmp_sum(<2 x i64> %x, <2 x i64> %y) {
; ANY-LABEL: unsigned_sat_variable_v2i64_using_cmp_sum:
; ANY:       # %bb.0:
; ANY-NEXT:    paddq %xmm0, %xmm1
; ANY-NEXT:    movdqa {{.*#+}} xmm2 = [2147483648,2147483648,2147483648,2147483648]
; ANY-NEXT:    pxor %xmm2, %xmm0
; ANY-NEXT:    pxor %xmm1, %xmm2
; ANY-NEXT:    movdqa %xmm0, %xmm3
; ANY-NEXT:    pcmpgtd %xmm2, %xmm3
; ANY-NEXT:    pshufd {{.*#+}} xmm4 = xmm3[0,0,2,2]
; ANY-NEXT:    pcmpeqd %xmm0, %xmm2
; ANY-NEXT:    pshufd {{.*#+}} xmm2 = xmm2[1,1,3,3]
; ANY-NEXT:    pand %xmm4, %xmm2
; ANY-NEXT:    pshufd {{.*#+}} xmm0 = xmm3[1,1,3,3]
; ANY-NEXT:    por %xmm1, %xmm0
; ANY-NEXT:    por %xmm2, %xmm0
; ANY-NEXT:    retq
  %a = add <2 x i64> %x, %y
  %c = icmp ugt <2 x i64> %x, %a
  %r = select <2 x i1> %c, <2 x i64> <i64 -1, i64 -1>, <2 x i64> %a
  ret <2 x i64> %r
}

define <2 x i64> @unsigned_sat_variable_v2i64_using_cmp_notval(<2 x i64> %x, <2 x i64> %y) {
; ANY-LABEL: unsigned_sat_variable_v2i64_using_cmp_notval:
; ANY:       # %bb.0:
; ANY-NEXT:    movdqa {{.*#+}} xmm2 = [2147483648,2147483648,2147483648,2147483648]
; ANY-NEXT:    pcmpeqd %xmm3, %xmm3
; ANY-NEXT:    movdqa %xmm0, %xmm4
; ANY-NEXT:    paddq %xmm1, %xmm4
; ANY-NEXT:    pxor %xmm2, %xmm0
; ANY-NEXT:    pxor %xmm2, %xmm3
; ANY-NEXT:    pxor %xmm1, %xmm3
; ANY-NEXT:    movdqa %xmm0, %xmm1
; ANY-NEXT:    pcmpgtd %xmm3, %xmm1
; ANY-NEXT:    pshufd {{.*#+}} xmm2 = xmm1[0,0,2,2]
; ANY-NEXT:    pcmpeqd %xmm0, %xmm3
; ANY-NEXT:    pshufd {{.*#+}} xmm3 = xmm3[1,1,3,3]
; ANY-NEXT:    pand %xmm2, %xmm3
; ANY-NEXT:    pshufd {{.*#+}} xmm0 = xmm1[1,1,3,3]
; ANY-NEXT:    por %xmm4, %xmm0
; ANY-NEXT:    por %xmm3, %xmm0
; ANY-NEXT:    retq
  %noty = xor <2 x i64> %y, <i64 -1, i64 -1>
  %a = add <2 x i64> %x, %y
  %c = icmp ugt <2 x i64> %x, %noty
  %r = select <2 x i1> %c, <2 x i64> <i64 -1, i64 -1>, <2 x i64> %a
  ret <2 x i64> %r
}

