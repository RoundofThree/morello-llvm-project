; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=arm-eabi -mcpu=cortex-a8 | FileCheck %s

define zeroext i1 @ne_neg1_and_ne_zero(i32 %x) nounwind {
; CHECK-LABEL: ne_neg1_and_ne_zero:
; CHECK:       @ %bb.0:
; CHECK-NEXT:    add r1, r0, #1
; CHECK-NEXT:    mov r0, #0
; CHECK-NEXT:    cmp r1, #1
; CHECK-NEXT:    movwhi r0, #1
; CHECK-NEXT:    bx lr
  %cmp1 = icmp ne i32 %x, -1
  %cmp2 = icmp ne i32 %x, 0
  %and = and i1 %cmp1, %cmp2
  ret i1 %and
}

; PR32401 - https://bugs.llvm.org/show_bug.cgi?id=32401

define zeroext i1 @and_eq(i32 %a, i32 %b, i32 %c, i32 %d) nounwind {
; CHECK-LABEL: and_eq:
; CHECK:       @ %bb.0:
; CHECK: eor     r2, r2, r3
; CHECK: eor     r0, r0, r1
; CHECK: orr     r0, r0, r2
; CHECK: clz     r0, r0
; CHECK: lsr     r0, r0, #5
; CHECK: bx      lr
  %cmp1 = icmp eq i32 %a, %b
  %cmp2 = icmp eq i32 %c, %d
  %and = and i1 %cmp1, %cmp2
  ret i1 %and
}

define zeroext i1 @or_ne(i32 %a, i32 %b, i32 %c, i32 %d) nounwind {
; CHECK-LABEL: or_ne:
; CHECK:       @ %bb.0:
; CHECK-NEXT:    eor r2, r2, r3
; CHECK-NEXT:    eor r0, r0, r1
; CHECK-NEXT:    orrs r0, r0, r2
; CHECK-NEXT:    movwne r0, #1
; CHECK-NEXT:    bx lr
  %cmp1 = icmp ne i32 %a, %b
  %cmp2 = icmp ne i32 %c, %d
  %or = or i1 %cmp1, %cmp2
  ret i1 %or
}

define <4 x i1> @and_eq_vec(<4 x i32> %a, <4 x i32> %b, <4 x i32> %c, <4 x i32> %d) nounwind {
; CHECK-LABEL: and_eq_vec:
; CHECK:       @ %bb.0:
; CHECK-NEXT:    .save {r11, lr}
; CHECK-NEXT:    push {r11, lr}
; CHECK-NEXT:    vmov d19, r2, r3
; CHECK-NEXT:    add r12, sp, #40
; CHECK-NEXT:    add lr, sp, #8
; CHECK-NEXT:    vmov d18, r0, r1
; CHECK-NEXT:    vld1.64 {d16, d17}, [lr]
; CHECK-NEXT:    add r0, sp, #24
; CHECK-NEXT:    vld1.64 {d20, d21}, [r12]
; CHECK-NEXT:    vceq.i32 q8, q9, q8
; CHECK-NEXT:    vld1.64 {d22, d23}, [r0]
; CHECK-NEXT:    vceq.i32 q9, q11, q10
; CHECK-NEXT:    vand q8, q8, q9
; CHECK-NEXT:    vmovn.i32 d16, q8
; CHECK-NEXT:    vmov r0, r1, d16
; CHECK-NEXT:    pop {r11, pc}
  %cmp1 = icmp eq <4 x i32> %a, %b
  %cmp2 = icmp eq <4 x i32> %c, %d
  %and = and <4 x i1> %cmp1, %cmp2
  ret <4 x i1> %and
}

