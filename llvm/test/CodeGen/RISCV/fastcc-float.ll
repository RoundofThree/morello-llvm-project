; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=riscv32 -mattr=+f,+d -verify-machineinstrs < %s \
; RUN:     | FileCheck %s

define fastcc float @callee(<32 x float> %A) nounwind {
; CHECK-LABEL: callee:
; CHECK:       # %bb.0:
; CHECK-NEXT:    fmv.x.w a0, fa0
; CHECK-NEXT:    ret
	%B = extractelement <32 x float> %A, i32 0
	ret float %B
}

; With the fastcc, arguments will be passed by fa0-fa7 and ft0-ft11.
; The rest will be pushed on the stack.
define float @caller(<32 x float> %A) nounwind {
; CHECK-LABEL: caller:
; CHECK:       # %bb.0:
; CHECK-NEXT:    addi sp, sp, -64
; CHECK-NEXT:    sw ra, 60(sp) # 4-byte Folded Spill
; CHECK-NEXT:    flw fa0, 0(a0)
; CHECK-NEXT:    flw fa1, 4(a0)
; CHECK-NEXT:    flw fa2, 8(a0)
; CHECK-NEXT:    flw fa3, 12(a0)
; CHECK-NEXT:    flw fa4, 16(a0)
; CHECK-NEXT:    flw fa5, 20(a0)
; CHECK-NEXT:    flw fa6, 24(a0)
; CHECK-NEXT:    flw fa7, 28(a0)
; CHECK-NEXT:    flw ft0, 32(a0)
; CHECK-NEXT:    flw ft1, 36(a0)
; CHECK-NEXT:    flw ft2, 40(a0)
; CHECK-NEXT:    flw ft3, 44(a0)
; CHECK-NEXT:    flw ft4, 48(a0)
; CHECK-NEXT:    flw ft5, 52(a0)
; CHECK-NEXT:    flw ft6, 56(a0)
; CHECK-NEXT:    flw ft7, 60(a0)
; CHECK-NEXT:    flw ft8, 64(a0)
; CHECK-NEXT:    flw ft9, 68(a0)
; CHECK-NEXT:    flw ft10, 72(a0)
; CHECK-NEXT:    flw ft11, 76(a0)
; CHECK-NEXT:    flw fs0, 80(a0)
; CHECK-NEXT:    flw fs1, 84(a0)
; CHECK-NEXT:    flw fs2, 88(a0)
; CHECK-NEXT:    flw fs3, 92(a0)
; CHECK-NEXT:    flw fs4, 96(a0)
; CHECK-NEXT:    flw fs5, 100(a0)
; CHECK-NEXT:    flw fs6, 104(a0)
; CHECK-NEXT:    flw fs7, 108(a0)
; CHECK-NEXT:    flw fs8, 112(a0)
; CHECK-NEXT:    flw fs9, 116(a0)
; CHECK-NEXT:    flw fs10, 120(a0)
; CHECK-NEXT:    flw fs11, 124(a0)
; CHECK-NEXT:    fsw fs11, 44(sp)
; CHECK-NEXT:    fsw fs10, 40(sp)
; CHECK-NEXT:    fsw fs9, 36(sp)
; CHECK-NEXT:    fsw fs8, 32(sp)
; CHECK-NEXT:    fsw fs7, 28(sp)
; CHECK-NEXT:    fsw fs6, 24(sp)
; CHECK-NEXT:    fsw fs5, 20(sp)
; CHECK-NEXT:    fsw fs4, 16(sp)
; CHECK-NEXT:    fsw fs3, 12(sp)
; CHECK-NEXT:    fsw fs2, 8(sp)
; CHECK-NEXT:    fsw fs1, 4(sp)
; CHECK-NEXT:    fsw fs0, 0(sp)
; CHECK-NEXT:    call callee
; CHECK-NEXT:    lw ra, 60(sp) # 4-byte Folded Reload
; CHECK-NEXT:    addi sp, sp, 64
; CHECK-NEXT:    ret
	%C = call fastcc float @callee(<32 x float> %A)
	ret float %C
}
