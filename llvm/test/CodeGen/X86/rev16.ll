; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-- | FileCheck %s --check-prefix=X86
; RUN: llc < %s -mtriple=x86_64-- | FileCheck %s --check-prefix=X64

; 0xff00ff00 = 4278255360
; 0x00ff00ff = 16711935
define i32 @rev16(i32 %a) {
; X86-LABEL: rev16:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl %eax, %ecx
; X86-NEXT:    shll $8, %ecx
; X86-NEXT:    shrl $8, %eax
; X86-NEXT:    andl $-16711936, %ecx # imm = 0xFF00FF00
; X86-NEXT:    andl $16711935, %eax # imm = 0xFF00FF
; X86-NEXT:    orl %ecx, %eax
; X86-NEXT:    retl
;
; X64-LABEL: rev16:
; X64:       # %bb.0:
; X64-NEXT:    # kill: def $edi killed $edi def $rdi
; X64-NEXT:    movl %edi, %eax
; X64-NEXT:    shll $8, %eax
; X64-NEXT:    shrl $8, %edi
; X64-NEXT:    andl $-16711936, %eax # imm = 0xFF00FF00
; X64-NEXT:    andl $16711935, %edi # imm = 0xFF00FF
; X64-NEXT:    addl %edi, %eax
; X64-NEXT:    retq
  %l8 = shl i32 %a, 8
  %r8 = lshr i32 %a, 8
  %mask_l8 = and i32 %l8, 4278255360
  %mask_r8 = and i32 %r8, 16711935
  %tmp = or i32 %mask_l8, %mask_r8
  ret i32 %tmp
}

define i32 @not_rev16(i32 %a) {
; X86-LABEL: not_rev16:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl %ecx, %eax
; X86-NEXT:    shll $8, %eax
; X86-NEXT:    shrl $8, %ecx
; X86-NEXT:    andl $65280, %ecx # imm = 0xFF00
; X86-NEXT:    andl $16711680, %eax # imm = 0xFF0000
; X86-NEXT:    orl %ecx, %eax
; X86-NEXT:    retl
;
; X64-LABEL: not_rev16:
; X64:       # %bb.0:
; X64-NEXT:    # kill: def $edi killed $edi def $rdi
; X64-NEXT:    movl %edi, %eax
; X64-NEXT:    shll $8, %eax
; X64-NEXT:    shrl $8, %edi
; X64-NEXT:    andl $65280, %edi # imm = 0xFF00
; X64-NEXT:    andl $16711680, %eax # imm = 0xFF0000
; X64-NEXT:    addl %edi, %eax
; X64-NEXT:    retq
  %l8 = shl i32 %a, 8
  %r8 = lshr i32 %a, 8
  %mask_r8 = and i32 %r8, 4278255360
  %mask_l8 = and i32 %l8, 16711935
  %tmp = or i32 %mask_r8, %mask_l8
  ret i32 %tmp
}

define i32 @extra_maskop_uses2(i32 %a) {
; X86-LABEL: extra_maskop_uses2:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl %ecx, %edx
; X86-NEXT:    shll $8, %edx
; X86-NEXT:    shrl $8, %ecx
; X86-NEXT:    andl $-16711936, %edx # imm = 0xFF00FF00
; X86-NEXT:    andl $16711935, %ecx # imm = 0xFF00FF
; X86-NEXT:    leal (%ecx,%edx), %eax
; X86-NEXT:    imull %edx, %eax
; X86-NEXT:    imull %ecx, %eax
; X86-NEXT:    retl
;
; X64-LABEL: extra_maskop_uses2:
; X64:       # %bb.0:
; X64-NEXT:    # kill: def $edi killed $edi def $rdi
; X64-NEXT:    movl %edi, %ecx
; X64-NEXT:    shll $8, %ecx
; X64-NEXT:    shrl $8, %edi
; X64-NEXT:    andl $-16711936, %ecx # imm = 0xFF00FF00
; X64-NEXT:    andl $16711935, %edi # imm = 0xFF00FF
; X64-NEXT:    leal (%rdi,%rcx), %eax
; X64-NEXT:    imull %ecx, %eax
; X64-NEXT:    imull %edi, %eax
; X64-NEXT:    retq
  %l8 = shl i32 %a, 8
  %r8 = lshr i32 %a, 8
  %mask_l8 = and i32 %l8, 4278255360
  %mask_r8 = and i32 %r8, 16711935
  %or = or i32 %mask_r8, %mask_l8
  %mul = mul i32 %mask_r8, %mask_l8   ; another use of the mask ops
  %r = mul i32 %mul, %or              ; and use that result
  ret i32 %r
}

define i32 @bswap_ror_commuted(i32 %a) {
; X86-LABEL: bswap_ror_commuted:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl %eax, %ecx
; X86-NEXT:    shll $8, %ecx
; X86-NEXT:    shrl $8, %eax
; X86-NEXT:    andl $-16711936, %ecx # imm = 0xFF00FF00
; X86-NEXT:    andl $16711935, %eax # imm = 0xFF00FF
; X86-NEXT:    orl %ecx, %eax
; X86-NEXT:    retl
;
; X64-LABEL: bswap_ror_commuted:
; X64:       # %bb.0:
; X64-NEXT:    # kill: def $edi killed $edi def $rdi
; X64-NEXT:    movl %edi, %eax
; X64-NEXT:    shll $8, %eax
; X64-NEXT:    shrl $8, %edi
; X64-NEXT:    andl $-16711936, %eax # imm = 0xFF00FF00
; X64-NEXT:    andl $16711935, %edi # imm = 0xFF00FF
; X64-NEXT:    addl %edi, %eax
; X64-NEXT:    retq
  %l8 = shl i32 %a, 8
  %r8 = lshr i32 %a, 8
  %mask_l8 = and i32 %l8, 4278255360
  %mask_r8 = and i32 %r8, 16711935
  %tmp = or i32 %mask_r8, %mask_l8
  ret i32 %tmp
}

define i32 @different_shift_amount(i32 %a) {
; X86-LABEL: different_shift_amount:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl %eax, %ecx
; X86-NEXT:    shll $9, %ecx
; X86-NEXT:    shrl $8, %eax
; X86-NEXT:    andl $-16712192, %ecx # imm = 0xFF00FE00
; X86-NEXT:    andl $16711935, %eax # imm = 0xFF00FF
; X86-NEXT:    orl %ecx, %eax
; X86-NEXT:    retl
;
; X64-LABEL: different_shift_amount:
; X64:       # %bb.0:
; X64-NEXT:    # kill: def $edi killed $edi def $rdi
; X64-NEXT:    movl %edi, %eax
; X64-NEXT:    shll $9, %eax
; X64-NEXT:    shrl $8, %edi
; X64-NEXT:    andl $-16712192, %eax # imm = 0xFF00FE00
; X64-NEXT:    andl $16711935, %edi # imm = 0xFF00FF
; X64-NEXT:    addl %edi, %eax
; X64-NEXT:    retq
  %l8 = shl i32 %a, 9
  %r8 = lshr i32 %a, 8
  %mask_l8 = and i32 %l8, 4278255360
  %mask_r8 = and i32 %r8, 16711935
  %tmp = or i32 %mask_l8, %mask_r8
  ret i32 %tmp
}

define i32 @different_constant(i32 %a) {
; X86-LABEL: different_constant:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    shrl $8, %eax
; X86-NEXT:    andl $16711935, %eax # imm = 0xFF00FF
; X86-NEXT:    retl
;
; X64-LABEL: different_constant:
; X64:       # %bb.0:
; X64-NEXT:    movl %edi, %eax
; X64-NEXT:    shrl $8, %eax
; X64-NEXT:    andl $16711935, %eax # imm = 0xFF00FF
; X64-NEXT:    retq
  %l8 = shl i32 %a, 8
  %r8 = lshr i32 %a, 8
  %mask_l8 = and i32 %l8, 42
  %mask_r8 = and i32 %r8, 16711935
  %tmp = or i32 %mask_l8, %mask_r8
  ret i32 %tmp
}

define i32 @different_op(i32 %a) {
; X86-LABEL: different_op:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl %eax, %ecx
; X86-NEXT:    shll $8, %ecx
; X86-NEXT:    shrl $8, %eax
; X86-NEXT:    addl $16711936, %ecx # imm = 0xFF0100
; X86-NEXT:    andl $16711935, %eax # imm = 0xFF00FF
; X86-NEXT:    orl %ecx, %eax
; X86-NEXT:    retl
;
; X64-LABEL: different_op:
; X64:       # %bb.0:
; X64-NEXT:    movl %edi, %eax
; X64-NEXT:    shll $8, %eax
; X64-NEXT:    shrl $8, %edi
; X64-NEXT:    addl $16711936, %eax # imm = 0xFF0100
; X64-NEXT:    andl $16711935, %edi # imm = 0xFF00FF
; X64-NEXT:    orl %edi, %eax
; X64-NEXT:    retq
  %l8 = shl i32 %a, 8
  %r8 = lshr i32 %a, 8
  %mask_l8 = sub i32 %l8, 4278255360
  %mask_r8 = and i32 %r8, 16711935
  %tmp = or i32 %mask_l8, %mask_r8
  ret i32 %tmp
}

define i32 @different_vars(i32 %a, i32 %b) {
; X86-LABEL: different_vars:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    shll $8, %ecx
; X86-NEXT:    shrl $8, %eax
; X86-NEXT:    andl $-16711936, %ecx # imm = 0xFF00FF00
; X86-NEXT:    andl $16711935, %eax # imm = 0xFF00FF
; X86-NEXT:    orl %ecx, %eax
; X86-NEXT:    retl
;
; X64-LABEL: different_vars:
; X64:       # %bb.0:
; X64-NEXT:    # kill: def $esi killed $esi def $rsi
; X64-NEXT:    # kill: def $edi killed $edi def $rdi
; X64-NEXT:    shll $8, %edi
; X64-NEXT:    shrl $8, %esi
; X64-NEXT:    andl $-16711936, %edi # imm = 0xFF00FF00
; X64-NEXT:    andl $16711935, %esi # imm = 0xFF00FF
; X64-NEXT:    leal (%rsi,%rdi), %eax
; X64-NEXT:    retq
  %l8 = shl i32 %a, 8
  %r8 = lshr i32 %b, 8
  %mask_l8 = and i32 %l8, 4278255360
  %mask_r8 = and i32 %r8, 16711935
  %tmp = or i32 %mask_l8, %mask_r8
  ret i32 %tmp
}

; TODO: another pattern that we are currently not matching
;
; 0xff000000 = 4278190080
; 0x00ff0000 = 16711680
; 0x0000ff00 = 65280
; 0x000000ff = 255
define i32 @f2(i32 %a) {
; X86-LABEL: f2:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    bswapl %eax
; X86-NEXT:    roll $16, %eax
; X86-NEXT:    retl
;
; X64-LABEL: f2:
; X64:       # %bb.0:
; X64-NEXT:    movl %edi, %eax
; X64-NEXT:    bswapl %eax
; X64-NEXT:    roll $16, %eax
; X64-NEXT:    retq
  %l8 = shl i32 %a, 8
  %r8 = lshr i32 %a, 8
  %masklo_l8 = and i32 %l8, 65280
  %maskhi_l8 = and i32 %l8, 4278190080
  %masklo_r8 = and i32 %r8, 255
  %maskhi_r8 = and i32 %r8, 16711680
  %tmp1 = or i32 %masklo_l8, %masklo_r8
  %tmp2 = or i32 %maskhi_l8, %maskhi_r8
  %tmp = or i32 %tmp1, %tmp2
  ret i32 %tmp
}
