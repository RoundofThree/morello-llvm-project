; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUNNOT: %cheri_purecap_llc -cheri-cap-table-abi=plt %s -O0 -o - -filetype=obj | llvm-dwarfdump -all -
; RUN: %cheri_purecap_llc -cheri-cap-table-abi=plt %s -O2 -o - | %cheri_FileCheck %s
; ModuleID = '/Users/alex/cheri/llvm/tools/clang/test/CodeGen/CHERI/cap-table-call-extern.c'

; Function Attrs: nounwind
define i32 @a() {
; Make sure we don't use $gp and save $cgp prior to every external call
; CHECK-LABEL: a:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    cincoffset $c11, $c11, -[[STACKFRAME_SIZE:48|96]]
; CHECK-NEXT:    .cfi_def_cfa_offset [[STACKFRAME_SIZE]]
; CHECK-NEXT:    csd $16, $zero, [[@EXPR STACKFRAME_SIZE - 8]]($c11)
; CHECK-NEXT:    csc $c18, $zero, [[@EXPR 1 * $CAP_SIZE]]($c11)
; CHECK-NEXT:    csc $c17, $zero, 0($c11)
; CHECK-NEXT:    .cfi_offset 16, -[[@EXPR 0 * $CAP_SIZE + 8]]
; CHECK-NEXT:    .cfi_offset 90, -[[@EXPR 2 * $CAP_SIZE]]
; CHECK-NEXT:    .cfi_offset 89, -[[@EXPR 3 * $CAP_SIZE]]
; CHECK-NEXT:    cmove $c18, $c26
; CHECK-NEXT:    clcbi $c12, %capcall20(external_fn1)($c18)
; CHECK-NEXT:    cmove $c26, $c18
; CHECK-NEXT:    cjalr $c12, $c17
; CHECK-NEXT:    nop
; CHECK-NEXT:    clcbi $c12, %capcall20(external_fn2)($c18)
; CHECK-NEXT:    cmove $c26, $c18
; CHECK-NEXT:    cjalr $c12, $c17
; CHECK-NEXT:    move $16, $2
; CHECK-NEXT:    addu $2, $16, $2
; CHECK-NEXT:    clc $c17, $zero, 0($c11)
; CHECK-NEXT:    clc $c18, $zero, [[@EXPR 1 * $CAP_SIZE]]($c11)
; CHECK-NEXT:    cld $16, $zero, [[@EXPR STACKFRAME_SIZE - 8]]($c11)
; CHECK-NEXT:    cjr $c17
; CHECK-NEXT:    cincoffset $c11, $c11, [[STACKFRAME_SIZE]]
entry:
  %call = call i32 (...) @external_fn1()
  %call2 = call i32 @external_fn2()
  %result = add i32 %call, %call2
  ret i32 %result
}

declare i32 @external_fn1(...)
declare i32 @external_fn2()
