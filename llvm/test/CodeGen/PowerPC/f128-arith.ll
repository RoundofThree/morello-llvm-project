; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mcpu=pwr9 -mtriple=powerpc64le-unknown-unknown -verify-machineinstrs \
; RUN:   -ppc-asm-full-reg-names -ppc-vsr-nums-as-vr < %s | FileCheck %s
; RUN: llc -mcpu=pwr8 -mtriple=powerpc64le-unknown-unknown -verify-machineinstrs \
; RUN:   -ppc-asm-full-reg-names -ppc-vsr-nums-as-vr < %s -enable-soft-fp128 | FileCheck %s \
; RUN:   -check-prefix=CHECK-P8

; Function Attrs: norecurse nounwind
define void @qpAdd(fp128* nocapture readonly %a, fp128* nocapture %res) {
; CHECK-LABEL: qpAdd:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lxv v2, 0(r3)
; CHECK-NEXT:    xsaddqp v2, v2, v2
; CHECK-NEXT:    stxv v2, 0(r4)
; CHECK-NEXT:    blr
;
; CHECK-P8-LABEL: qpAdd:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    mflr r0
; CHECK-P8-NEXT:    .cfi_def_cfa_offset 48
; CHECK-P8-NEXT:    .cfi_offset lr, 16
; CHECK-P8-NEXT:    .cfi_offset r30, -16
; CHECK-P8-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; CHECK-P8-NEXT:    std r0, 16(r1)
; CHECK-P8-NEXT:    stdu r1, -48(r1)
; CHECK-P8-NEXT:    lvx v2, 0, r3
; CHECK-P8-NEXT:    mr r30, r4
; CHECK-P8-NEXT:    vmr v3, v2
; CHECK-P8-NEXT:    bl __addkf3
; CHECK-P8-NEXT:    nop
; CHECK-P8-NEXT:    stvx v2, 0, r30
; CHECK-P8-NEXT:    addi r1, r1, 48
; CHECK-P8-NEXT:    ld r0, 16(r1)
; CHECK-P8-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; CHECK-P8-NEXT:    mtlr r0
; CHECK-P8-NEXT:    blr
entry:
  %0 = load fp128, fp128* %a, align 16
  %add = fadd fp128 %0, %0
  store fp128 %add, fp128* %res, align 16
  ret void
}

; Function Attrs: norecurse nounwind
define void @qpSub(fp128* nocapture readonly %a, fp128* nocapture %res) {
; CHECK-LABEL: qpSub:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lxv v2, 0(r3)
; CHECK-NEXT:    xssubqp v2, v2, v2
; CHECK-NEXT:    stxv v2, 0(r4)
; CHECK-NEXT:    blr
;
; CHECK-P8-LABEL: qpSub:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    mflr r0
; CHECK-P8-NEXT:    .cfi_def_cfa_offset 48
; CHECK-P8-NEXT:    .cfi_offset lr, 16
; CHECK-P8-NEXT:    .cfi_offset r30, -16
; CHECK-P8-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; CHECK-P8-NEXT:    std r0, 16(r1)
; CHECK-P8-NEXT:    stdu r1, -48(r1)
; CHECK-P8-NEXT:    lvx v2, 0, r3
; CHECK-P8-NEXT:    mr r30, r4
; CHECK-P8-NEXT:    vmr v3, v2
; CHECK-P8-NEXT:    bl __subkf3
; CHECK-P8-NEXT:    nop
; CHECK-P8-NEXT:    stvx v2, 0, r30
; CHECK-P8-NEXT:    addi r1, r1, 48
; CHECK-P8-NEXT:    ld r0, 16(r1)
; CHECK-P8-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; CHECK-P8-NEXT:    mtlr r0
; CHECK-P8-NEXT:    blr
entry:
  %0 = load fp128, fp128* %a, align 16
  %sub = fsub fp128 %0, %0
  store fp128 %sub, fp128* %res, align 16
  ret void
}

; Function Attrs: norecurse nounwind
define void @qpMul(fp128* nocapture readonly %a, fp128* nocapture %res) {
; CHECK-LABEL: qpMul:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lxv v2, 0(r3)
; CHECK-NEXT:    xsmulqp v2, v2, v2
; CHECK-NEXT:    stxv v2, 0(r4)
; CHECK-NEXT:    blr
;
; CHECK-P8-LABEL: qpMul:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    mflr r0
; CHECK-P8-NEXT:    .cfi_def_cfa_offset 48
; CHECK-P8-NEXT:    .cfi_offset lr, 16
; CHECK-P8-NEXT:    .cfi_offset r30, -16
; CHECK-P8-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; CHECK-P8-NEXT:    std r0, 16(r1)
; CHECK-P8-NEXT:    stdu r1, -48(r1)
; CHECK-P8-NEXT:    lvx v2, 0, r3
; CHECK-P8-NEXT:    mr r30, r4
; CHECK-P8-NEXT:    vmr v3, v2
; CHECK-P8-NEXT:    bl __mulkf3
; CHECK-P8-NEXT:    nop
; CHECK-P8-NEXT:    stvx v2, 0, r30
; CHECK-P8-NEXT:    addi r1, r1, 48
; CHECK-P8-NEXT:    ld r0, 16(r1)
; CHECK-P8-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; CHECK-P8-NEXT:    mtlr r0
; CHECK-P8-NEXT:    blr
entry:
  %0 = load fp128, fp128* %a, align 16
  %mul = fmul fp128 %0, %0
  store fp128 %mul, fp128* %res, align 16
  ret void
}

; Function Attrs: norecurse nounwind
define void @qpDiv(fp128* nocapture readonly %a, fp128* nocapture %res) {
; CHECK-LABEL: qpDiv:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lxv v2, 0(r3)
; CHECK-NEXT:    xsdivqp v2, v2, v2
; CHECK-NEXT:    stxv v2, 0(r4)
; CHECK-NEXT:    blr
;
; CHECK-P8-LABEL: qpDiv:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    mflr r0
; CHECK-P8-NEXT:    .cfi_def_cfa_offset 48
; CHECK-P8-NEXT:    .cfi_offset lr, 16
; CHECK-P8-NEXT:    .cfi_offset r30, -16
; CHECK-P8-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; CHECK-P8-NEXT:    std r0, 16(r1)
; CHECK-P8-NEXT:    stdu r1, -48(r1)
; CHECK-P8-NEXT:    lvx v2, 0, r3
; CHECK-P8-NEXT:    mr r30, r4
; CHECK-P8-NEXT:    vmr v3, v2
; CHECK-P8-NEXT:    bl __divkf3
; CHECK-P8-NEXT:    nop
; CHECK-P8-NEXT:    stvx v2, 0, r30
; CHECK-P8-NEXT:    addi r1, r1, 48
; CHECK-P8-NEXT:    ld r0, 16(r1)
; CHECK-P8-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; CHECK-P8-NEXT:    mtlr r0
; CHECK-P8-NEXT:    blr
entry:
  %0 = load fp128, fp128* %a, align 16
  %div = fdiv fp128 %0, %0
  store fp128 %div, fp128* %res, align 16
  ret void
}

define void @testLdNSt(i8* nocapture readonly %PtrC, fp128* nocapture %PtrF) {
; CHECK-LABEL: testLdNSt:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addi r3, r3, 4
; CHECK-NEXT:    addi r4, r4, 8
; CHECK-NEXT:    lxvx vs0, 0, r3
; CHECK-NEXT:    stxvx vs0, 0, r4
; CHECK-NEXT:    blr
;
; CHECK-P8-LABEL: testLdNSt:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    addi r3, r3, 4
; CHECK-P8-NEXT:    lvx v2, 0, r3
; CHECK-P8-NEXT:    addi r3, r4, 8
; CHECK-P8-NEXT:    stvx v2, 0, r3
; CHECK-P8-NEXT:    blr
entry:
  %add.ptr = getelementptr inbounds i8, i8* %PtrC, i64 4
  %0 = bitcast i8* %add.ptr to fp128*
  %1 = load fp128, fp128* %0, align 16
  %2 = bitcast fp128* %PtrF to i8*
  %add.ptr1 = getelementptr inbounds i8, i8* %2, i64 8
  %3 = bitcast i8* %add.ptr1 to fp128*
  store fp128 %1, fp128* %3, align 16
  ret void
}

define void @qpSqrt(fp128* nocapture readonly %a, fp128* nocapture %res) {
; CHECK-LABEL: qpSqrt:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lxv v2, 0(r3)
; CHECK-NEXT:    xssqrtqp v2, v2
; CHECK-NEXT:    stxv v2, 0(r4)
; CHECK-NEXT:    blr
;
; CHECK-P8-LABEL: qpSqrt:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    mflr r0
; CHECK-P8-NEXT:    .cfi_def_cfa_offset 48
; CHECK-P8-NEXT:    .cfi_offset lr, 16
; CHECK-P8-NEXT:    .cfi_offset r30, -16
; CHECK-P8-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; CHECK-P8-NEXT:    std r0, 16(r1)
; CHECK-P8-NEXT:    stdu r1, -48(r1)
; CHECK-P8-NEXT:    lvx v2, 0, r3
; CHECK-P8-NEXT:    mr r30, r4
; CHECK-P8-NEXT:    bl sqrtf128
; CHECK-P8-NEXT:    nop
; CHECK-P8-NEXT:    stvx v2, 0, r30
; CHECK-P8-NEXT:    addi r1, r1, 48
; CHECK-P8-NEXT:    ld r0, 16(r1)
; CHECK-P8-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; CHECK-P8-NEXT:    mtlr r0
; CHECK-P8-NEXT:    blr
entry:
  %0 = load fp128, fp128* %a, align 16
  %1 = tail call fp128 @llvm.sqrt.f128(fp128 %0)
  store fp128 %1, fp128* %res, align 16
  ret void

}
declare fp128 @llvm.sqrt.f128(fp128 %Val)

define void @qpCpsgn(fp128* nocapture readonly %a, fp128* nocapture readonly %b,
; CHECK-LABEL: qpCpsgn:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lxv v2, 0(r3)
; CHECK-NEXT:    lxv v3, 0(r4)
; CHECK-NEXT:    xscpsgnqp v2, v3, v2
; CHECK-NEXT:    stxv v2, 0(r5)
; CHECK-NEXT:    blr
;
; CHECK-P8-LABEL: qpCpsgn:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    lvx v2, 0, r3
; CHECK-P8-NEXT:    lvx v3, 0, r4
; CHECK-P8-NEXT:    addi r3, r1, -16
; CHECK-P8-NEXT:    addi r4, r1, -32
; CHECK-P8-NEXT:    stvx v3, 0, r3
; CHECK-P8-NEXT:    stvx v2, 0, r4
; CHECK-P8-NEXT:    lbz r3, -1(r1)
; CHECK-P8-NEXT:    lbz r6, -17(r1)
; CHECK-P8-NEXT:    rlwimi r6, r3, 0, 0, 24
; CHECK-P8-NEXT:    stb r6, -17(r1)
; CHECK-P8-NEXT:    lvx v2, 0, r4
; CHECK-P8-NEXT:    stvx v2, 0, r5
; CHECK-P8-NEXT:    blr
                     fp128* nocapture %res) {
entry:
  %0 = load fp128, fp128* %a, align 16
  %1 = load fp128, fp128* %b, align 16
  %2 = tail call fp128 @llvm.copysign.f128(fp128 %0, fp128 %1)
  store fp128 %2, fp128* %res, align 16
  ret void

}
declare fp128 @llvm.copysign.f128(fp128 %Mag, fp128 %Sgn)

define void @qpAbs(fp128* nocapture readonly %a, fp128* nocapture %res) {
; CHECK-LABEL: qpAbs:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lxv v2, 0(r3)
; CHECK-NEXT:    xsabsqp v2, v2
; CHECK-NEXT:    stxv v2, 0(r4)
; CHECK-NEXT:    blr
;
; CHECK-P8-LABEL: qpAbs:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    lvx v2, 0, r3
; CHECK-P8-NEXT:    addi r3, r1, -16
; CHECK-P8-NEXT:    stvx v2, 0, r3
; CHECK-P8-NEXT:    lbz r5, -1(r1)
; CHECK-P8-NEXT:    clrlwi r5, r5, 25
; CHECK-P8-NEXT:    stb r5, -1(r1)
; CHECK-P8-NEXT:    lvx v2, 0, r3
; CHECK-P8-NEXT:    stvx v2, 0, r4
; CHECK-P8-NEXT:    blr
entry:
  %0 = load fp128, fp128* %a, align 16
  %1 = tail call fp128 @llvm.fabs.f128(fp128 %0)
  store fp128 %1, fp128* %res, align 16
  ret void

}
declare fp128 @llvm.fabs.f128(fp128 %Val)

define void @qpNAbs(fp128* nocapture readonly %a, fp128* nocapture %res) {
; CHECK-LABEL: qpNAbs:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lxv v2, 0(r3)
; CHECK-NEXT:    xsnabsqp v2, v2
; CHECK-NEXT:    stxv v2, 0(r4)
; CHECK-NEXT:    blr
;
; CHECK-P8-LABEL: qpNAbs:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    lvx v2, 0, r3
; CHECK-P8-NEXT:    addi r3, r1, -32
; CHECK-P8-NEXT:    stvx v2, 0, r3
; CHECK-P8-NEXT:    lbz r5, -17(r1)
; CHECK-P8-NEXT:    clrlwi r5, r5, 25
; CHECK-P8-NEXT:    stb r5, -17(r1)
; CHECK-P8-NEXT:    lvx v2, 0, r3
; CHECK-P8-NEXT:    addi r3, r1, -16
; CHECK-P8-NEXT:    stvx v2, 0, r3
; CHECK-P8-NEXT:    lbz r5, -1(r1)
; CHECK-P8-NEXT:    xori r5, r5, 128
; CHECK-P8-NEXT:    stb r5, -1(r1)
; CHECK-P8-NEXT:    lvx v2, 0, r3
; CHECK-P8-NEXT:    stvx v2, 0, r4
; CHECK-P8-NEXT:    blr
entry:
  %0 = load fp128, fp128* %a, align 16
  %1 = tail call fp128 @llvm.fabs.f128(fp128 %0)
  %neg = fsub fp128 0xL00000000000000008000000000000000, %1
  store fp128 %neg, fp128* %res, align 16
  ret void

}

define void @qpNeg(fp128* nocapture readonly %a, fp128* nocapture %res) {
; CHECK-LABEL: qpNeg:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lxv v2, 0(r3)
; CHECK-NEXT:    xsnegqp v2, v2
; CHECK-NEXT:    stxv v2, 0(r4)
; CHECK-NEXT:    blr
;
; CHECK-P8-LABEL: qpNeg:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    lvx v2, 0, r3
; CHECK-P8-NEXT:    addi r3, r1, -16
; CHECK-P8-NEXT:    stvx v2, 0, r3
; CHECK-P8-NEXT:    lbz r5, -1(r1)
; CHECK-P8-NEXT:    xori r5, r5, 128
; CHECK-P8-NEXT:    stb r5, -1(r1)
; CHECK-P8-NEXT:    lvx v2, 0, r3
; CHECK-P8-NEXT:    stvx v2, 0, r4
; CHECK-P8-NEXT:    blr
entry:
  %0 = load fp128, fp128* %a, align 16
  %sub = fsub fp128 0xL00000000000000008000000000000000, %0
  store fp128 %sub, fp128* %res, align 16
  ret void

}

define fp128 @qp_sin(fp128* nocapture readonly %a) {
; CHECK-LABEL: qp_sin:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    mflr r0
; CHECK-NEXT:    std r0, 16(r1)
; CHECK-NEXT:    stdu r1, -32(r1)
; CHECK-NEXT:    .cfi_def_cfa_offset 32
; CHECK-NEXT:    .cfi_offset lr, 16
; CHECK-NEXT:    lxv v2, 0(r3)
; CHECK-NEXT:    bl sinf128
; CHECK-NEXT:    nop
; CHECK-NEXT:    addi r1, r1, 32
; CHECK-NEXT:    ld r0, 16(r1)
; CHECK-NEXT:    mtlr r0
; CHECK-NEXT:    blr
;
; CHECK-P8-LABEL: qp_sin:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    mflr r0
; CHECK-P8-NEXT:    std r0, 16(r1)
; CHECK-P8-NEXT:    stdu r1, -32(r1)
; CHECK-P8-NEXT:    .cfi_def_cfa_offset 32
; CHECK-P8-NEXT:    .cfi_offset lr, 16
; CHECK-P8-NEXT:    lvx v2, 0, r3
; CHECK-P8-NEXT:    bl sinf128
; CHECK-P8-NEXT:    nop
; CHECK-P8-NEXT:    addi r1, r1, 32
; CHECK-P8-NEXT:    ld r0, 16(r1)
; CHECK-P8-NEXT:    mtlr r0
; CHECK-P8-NEXT:    blr
entry:
  %0 = load fp128, fp128* %a, align 16
  %1 = tail call fp128 @llvm.sin.f128(fp128 %0)
  ret fp128 %1
}
declare fp128 @llvm.sin.f128(fp128 %Val)

define fp128 @qp_cos(fp128* nocapture readonly %a) {
; CHECK-LABEL: qp_cos:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    mflr r0
; CHECK-NEXT:    std r0, 16(r1)
; CHECK-NEXT:    stdu r1, -32(r1)
; CHECK-NEXT:    .cfi_def_cfa_offset 32
; CHECK-NEXT:    .cfi_offset lr, 16
; CHECK-NEXT:    lxv v2, 0(r3)
; CHECK-NEXT:    bl cosf128
; CHECK-NEXT:    nop
; CHECK-NEXT:    addi r1, r1, 32
; CHECK-NEXT:    ld r0, 16(r1)
; CHECK-NEXT:    mtlr r0
; CHECK-NEXT:    blr
;
; CHECK-P8-LABEL: qp_cos:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    mflr r0
; CHECK-P8-NEXT:    std r0, 16(r1)
; CHECK-P8-NEXT:    stdu r1, -32(r1)
; CHECK-P8-NEXT:    .cfi_def_cfa_offset 32
; CHECK-P8-NEXT:    .cfi_offset lr, 16
; CHECK-P8-NEXT:    lvx v2, 0, r3
; CHECK-P8-NEXT:    bl cosf128
; CHECK-P8-NEXT:    nop
; CHECK-P8-NEXT:    addi r1, r1, 32
; CHECK-P8-NEXT:    ld r0, 16(r1)
; CHECK-P8-NEXT:    mtlr r0
; CHECK-P8-NEXT:    blr
entry:
  %0 = load fp128, fp128* %a, align 16
  %1 = tail call fp128 @llvm.cos.f128(fp128 %0)
  ret fp128 %1
}
declare fp128 @llvm.cos.f128(fp128 %Val)

define fp128 @qp_log(fp128* nocapture readonly %a) {
; CHECK-LABEL: qp_log:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    mflr r0
; CHECK-NEXT:    std r0, 16(r1)
; CHECK-NEXT:    stdu r1, -32(r1)
; CHECK-NEXT:    .cfi_def_cfa_offset 32
; CHECK-NEXT:    .cfi_offset lr, 16
; CHECK-NEXT:    lxv v2, 0(r3)
; CHECK-NEXT:    bl logf128
; CHECK-NEXT:    nop
; CHECK-NEXT:    addi r1, r1, 32
; CHECK-NEXT:    ld r0, 16(r1)
; CHECK-NEXT:    mtlr r0
; CHECK-NEXT:    blr
;
; CHECK-P8-LABEL: qp_log:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    mflr r0
; CHECK-P8-NEXT:    std r0, 16(r1)
; CHECK-P8-NEXT:    stdu r1, -32(r1)
; CHECK-P8-NEXT:    .cfi_def_cfa_offset 32
; CHECK-P8-NEXT:    .cfi_offset lr, 16
; CHECK-P8-NEXT:    lvx v2, 0, r3
; CHECK-P8-NEXT:    bl logf128
; CHECK-P8-NEXT:    nop
; CHECK-P8-NEXT:    addi r1, r1, 32
; CHECK-P8-NEXT:    ld r0, 16(r1)
; CHECK-P8-NEXT:    mtlr r0
; CHECK-P8-NEXT:    blr
entry:
  %0 = load fp128, fp128* %a, align 16
  %1 = tail call fp128 @llvm.log.f128(fp128 %0)
  ret fp128 %1
}
declare fp128     @llvm.log.f128(fp128 %Val)

define fp128 @qp_log10(fp128* nocapture readonly %a) {
; CHECK-LABEL: qp_log10:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    mflr r0
; CHECK-NEXT:    std r0, 16(r1)
; CHECK-NEXT:    stdu r1, -32(r1)
; CHECK-NEXT:    .cfi_def_cfa_offset 32
; CHECK-NEXT:    .cfi_offset lr, 16
; CHECK-NEXT:    lxv v2, 0(r3)
; CHECK-NEXT:    bl log10f128
; CHECK-NEXT:    nop
; CHECK-NEXT:    addi r1, r1, 32
; CHECK-NEXT:    ld r0, 16(r1)
; CHECK-NEXT:    mtlr r0
; CHECK-NEXT:    blr
;
; CHECK-P8-LABEL: qp_log10:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    mflr r0
; CHECK-P8-NEXT:    std r0, 16(r1)
; CHECK-P8-NEXT:    stdu r1, -32(r1)
; CHECK-P8-NEXT:    .cfi_def_cfa_offset 32
; CHECK-P8-NEXT:    .cfi_offset lr, 16
; CHECK-P8-NEXT:    lvx v2, 0, r3
; CHECK-P8-NEXT:    bl log10f128
; CHECK-P8-NEXT:    nop
; CHECK-P8-NEXT:    addi r1, r1, 32
; CHECK-P8-NEXT:    ld r0, 16(r1)
; CHECK-P8-NEXT:    mtlr r0
; CHECK-P8-NEXT:    blr
entry:
  %0 = load fp128, fp128* %a, align 16
  %1 = tail call fp128 @llvm.log10.f128(fp128 %0)
  ret fp128 %1
}
declare fp128     @llvm.log10.f128(fp128 %Val)

define fp128 @qp_log2(fp128* nocapture readonly %a) {
; CHECK-LABEL: qp_log2:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    mflr r0
; CHECK-NEXT:    std r0, 16(r1)
; CHECK-NEXT:    stdu r1, -32(r1)
; CHECK-NEXT:    .cfi_def_cfa_offset 32
; CHECK-NEXT:    .cfi_offset lr, 16
; CHECK-NEXT:    lxv v2, 0(r3)
; CHECK-NEXT:    bl log2f128
; CHECK-NEXT:    nop
; CHECK-NEXT:    addi r1, r1, 32
; CHECK-NEXT:    ld r0, 16(r1)
; CHECK-NEXT:    mtlr r0
; CHECK-NEXT:    blr
;
; CHECK-P8-LABEL: qp_log2:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    mflr r0
; CHECK-P8-NEXT:    std r0, 16(r1)
; CHECK-P8-NEXT:    stdu r1, -32(r1)
; CHECK-P8-NEXT:    .cfi_def_cfa_offset 32
; CHECK-P8-NEXT:    .cfi_offset lr, 16
; CHECK-P8-NEXT:    lvx v2, 0, r3
; CHECK-P8-NEXT:    bl log2f128
; CHECK-P8-NEXT:    nop
; CHECK-P8-NEXT:    addi r1, r1, 32
; CHECK-P8-NEXT:    ld r0, 16(r1)
; CHECK-P8-NEXT:    mtlr r0
; CHECK-P8-NEXT:    blr
entry:
  %0 = load fp128, fp128* %a, align 16
  %1 = tail call fp128 @llvm.log2.f128(fp128 %0)
  ret fp128 %1
}
declare fp128     @llvm.log2.f128(fp128 %Val)

define fp128 @qp_minnum(fp128* nocapture readonly %a,
; CHECK-LABEL: qp_minnum:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    mflr r0
; CHECK-NEXT:    std r0, 16(r1)
; CHECK-NEXT:    stdu r1, -32(r1)
; CHECK-NEXT:    .cfi_def_cfa_offset 32
; CHECK-NEXT:    .cfi_offset lr, 16
; CHECK-NEXT:    lxv v2, 0(r3)
; CHECK-NEXT:    lxv v3, 0(r4)
; CHECK-NEXT:    bl fminf128
; CHECK-NEXT:    nop
; CHECK-NEXT:    addi r1, r1, 32
; CHECK-NEXT:    ld r0, 16(r1)
; CHECK-NEXT:    mtlr r0
; CHECK-NEXT:    blr
;
; CHECK-P8-LABEL: qp_minnum:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    mflr r0
; CHECK-P8-NEXT:    std r0, 16(r1)
; CHECK-P8-NEXT:    stdu r1, -32(r1)
; CHECK-P8-NEXT:    .cfi_def_cfa_offset 32
; CHECK-P8-NEXT:    .cfi_offset lr, 16
; CHECK-P8-NEXT:    lvx v2, 0, r3
; CHECK-P8-NEXT:    lvx v3, 0, r4
; CHECK-P8-NEXT:    bl fminf128
; CHECK-P8-NEXT:    nop
; CHECK-P8-NEXT:    addi r1, r1, 32
; CHECK-P8-NEXT:    ld r0, 16(r1)
; CHECK-P8-NEXT:    mtlr r0
; CHECK-P8-NEXT:    blr
                        fp128* nocapture readonly %b) {
entry:
  %0 = load fp128, fp128* %a, align 16
  %1 = load fp128, fp128* %b, align 16
  %2 = tail call fp128 @llvm.minnum.f128(fp128 %0, fp128 %1)
  ret fp128 %2
}
declare fp128     @llvm.minnum.f128(fp128 %Val0, fp128 %Val1)

define fp128 @qp_maxnum(fp128* nocapture readonly %a,
; CHECK-LABEL: qp_maxnum:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    mflr r0
; CHECK-NEXT:    std r0, 16(r1)
; CHECK-NEXT:    stdu r1, -32(r1)
; CHECK-NEXT:    .cfi_def_cfa_offset 32
; CHECK-NEXT:    .cfi_offset lr, 16
; CHECK-NEXT:    lxv v2, 0(r3)
; CHECK-NEXT:    lxv v3, 0(r4)
; CHECK-NEXT:    bl fmaxf128
; CHECK-NEXT:    nop
; CHECK-NEXT:    addi r1, r1, 32
; CHECK-NEXT:    ld r0, 16(r1)
; CHECK-NEXT:    mtlr r0
; CHECK-NEXT:    blr
;
; CHECK-P8-LABEL: qp_maxnum:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    mflr r0
; CHECK-P8-NEXT:    std r0, 16(r1)
; CHECK-P8-NEXT:    stdu r1, -32(r1)
; CHECK-P8-NEXT:    .cfi_def_cfa_offset 32
; CHECK-P8-NEXT:    .cfi_offset lr, 16
; CHECK-P8-NEXT:    lvx v2, 0, r3
; CHECK-P8-NEXT:    lvx v3, 0, r4
; CHECK-P8-NEXT:    bl fmaxf128
; CHECK-P8-NEXT:    nop
; CHECK-P8-NEXT:    addi r1, r1, 32
; CHECK-P8-NEXT:    ld r0, 16(r1)
; CHECK-P8-NEXT:    mtlr r0
; CHECK-P8-NEXT:    blr
                        fp128* nocapture readonly %b) {
entry:
  %0 = load fp128, fp128* %a, align 16
  %1 = load fp128, fp128* %b, align 16
  %2 = tail call fp128 @llvm.maxnum.f128(fp128 %0, fp128 %1)
  ret fp128 %2
}
declare fp128     @llvm.maxnum.f128(fp128 %Val0, fp128 %Val1)

define fp128 @qp_pow(fp128* nocapture readonly %a,
; CHECK-LABEL: qp_pow:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    mflr r0
; CHECK-NEXT:    std r0, 16(r1)
; CHECK-NEXT:    stdu r1, -32(r1)
; CHECK-NEXT:    .cfi_def_cfa_offset 32
; CHECK-NEXT:    .cfi_offset lr, 16
; CHECK-NEXT:    lxv v2, 0(r3)
; CHECK-NEXT:    lxv v3, 0(r4)
; CHECK-NEXT:    bl powf128
; CHECK-NEXT:    nop
; CHECK-NEXT:    addi r1, r1, 32
; CHECK-NEXT:    ld r0, 16(r1)
; CHECK-NEXT:    mtlr r0
; CHECK-NEXT:    blr
;
; CHECK-P8-LABEL: qp_pow:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    mflr r0
; CHECK-P8-NEXT:    std r0, 16(r1)
; CHECK-P8-NEXT:    stdu r1, -32(r1)
; CHECK-P8-NEXT:    .cfi_def_cfa_offset 32
; CHECK-P8-NEXT:    .cfi_offset lr, 16
; CHECK-P8-NEXT:    lvx v2, 0, r3
; CHECK-P8-NEXT:    lvx v3, 0, r4
; CHECK-P8-NEXT:    bl powf128
; CHECK-P8-NEXT:    nop
; CHECK-P8-NEXT:    addi r1, r1, 32
; CHECK-P8-NEXT:    ld r0, 16(r1)
; CHECK-P8-NEXT:    mtlr r0
; CHECK-P8-NEXT:    blr
                     fp128* nocapture readonly %b) {
entry:
  %0 = load fp128, fp128* %a, align 16
  %1 = load fp128, fp128* %b, align 16
  %2 = tail call fp128 @llvm.pow.f128(fp128 %0, fp128 %1)
  ret fp128 %2
}
declare fp128 @llvm.pow.f128(fp128 %Val, fp128 %Power)

define fp128 @qp_exp(fp128* nocapture readonly %a) {
; CHECK-LABEL: qp_exp:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    mflr r0
; CHECK-NEXT:    std r0, 16(r1)
; CHECK-NEXT:    stdu r1, -32(r1)
; CHECK-NEXT:    .cfi_def_cfa_offset 32
; CHECK-NEXT:    .cfi_offset lr, 16
; CHECK-NEXT:    lxv v2, 0(r3)
; CHECK-NEXT:    bl expf128
; CHECK-NEXT:    nop
; CHECK-NEXT:    addi r1, r1, 32
; CHECK-NEXT:    ld r0, 16(r1)
; CHECK-NEXT:    mtlr r0
; CHECK-NEXT:    blr
;
; CHECK-P8-LABEL: qp_exp:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    mflr r0
; CHECK-P8-NEXT:    std r0, 16(r1)
; CHECK-P8-NEXT:    stdu r1, -32(r1)
; CHECK-P8-NEXT:    .cfi_def_cfa_offset 32
; CHECK-P8-NEXT:    .cfi_offset lr, 16
; CHECK-P8-NEXT:    lvx v2, 0, r3
; CHECK-P8-NEXT:    bl expf128
; CHECK-P8-NEXT:    nop
; CHECK-P8-NEXT:    addi r1, r1, 32
; CHECK-P8-NEXT:    ld r0, 16(r1)
; CHECK-P8-NEXT:    mtlr r0
; CHECK-P8-NEXT:    blr
entry:
  %0 = load fp128, fp128* %a, align 16
  %1 = tail call fp128 @llvm.exp.f128(fp128 %0)
  ret fp128 %1
}
declare fp128     @llvm.exp.f128(fp128 %Val)

define fp128 @qp_exp2(fp128* nocapture readonly %a) {
; CHECK-LABEL: qp_exp2:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    mflr r0
; CHECK-NEXT:    std r0, 16(r1)
; CHECK-NEXT:    stdu r1, -32(r1)
; CHECK-NEXT:    .cfi_def_cfa_offset 32
; CHECK-NEXT:    .cfi_offset lr, 16
; CHECK-NEXT:    lxv v2, 0(r3)
; CHECK-NEXT:    bl exp2f128
; CHECK-NEXT:    nop
; CHECK-NEXT:    addi r1, r1, 32
; CHECK-NEXT:    ld r0, 16(r1)
; CHECK-NEXT:    mtlr r0
; CHECK-NEXT:    blr
;
; CHECK-P8-LABEL: qp_exp2:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    mflr r0
; CHECK-P8-NEXT:    std r0, 16(r1)
; CHECK-P8-NEXT:    stdu r1, -32(r1)
; CHECK-P8-NEXT:    .cfi_def_cfa_offset 32
; CHECK-P8-NEXT:    .cfi_offset lr, 16
; CHECK-P8-NEXT:    lvx v2, 0, r3
; CHECK-P8-NEXT:    bl exp2f128
; CHECK-P8-NEXT:    nop
; CHECK-P8-NEXT:    addi r1, r1, 32
; CHECK-P8-NEXT:    ld r0, 16(r1)
; CHECK-P8-NEXT:    mtlr r0
; CHECK-P8-NEXT:    blr
entry:
  %0 = load fp128, fp128* %a, align 16
  %1 = tail call fp128 @llvm.exp2.f128(fp128 %0)
  ret fp128 %1
}
declare fp128     @llvm.exp2.f128(fp128 %Val)

define void @qp_powi(fp128* nocapture readonly %a, i32* nocapture readonly %b,
; CHECK-LABEL: qp_powi:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    mflr r0
; CHECK-NEXT:    .cfi_def_cfa_offset 48
; CHECK-NEXT:    .cfi_offset lr, 16
; CHECK-NEXT:    .cfi_offset r30, -16
; CHECK-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; CHECK-NEXT:    std r0, 16(r1)
; CHECK-NEXT:    stdu r1, -48(r1)
; CHECK-NEXT:    lxv v2, 0(r3)
; CHECK-NEXT:    mr r30, r5
; CHECK-NEXT:    lwz r5, 0(r4)
; CHECK-NEXT:    bl __powikf2
; CHECK-NEXT:    nop
; CHECK-NEXT:    stxv v2, 0(r30)
; CHECK-NEXT:    addi r1, r1, 48
; CHECK-NEXT:    ld r0, 16(r1)
; CHECK-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; CHECK-NEXT:    mtlr r0
; CHECK-NEXT:    blr
;
; CHECK-P8-LABEL: qp_powi:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    mflr r0
; CHECK-P8-NEXT:    .cfi_def_cfa_offset 48
; CHECK-P8-NEXT:    .cfi_offset lr, 16
; CHECK-P8-NEXT:    .cfi_offset r30, -16
; CHECK-P8-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; CHECK-P8-NEXT:    std r0, 16(r1)
; CHECK-P8-NEXT:    stdu r1, -48(r1)
; CHECK-P8-NEXT:    lvx v2, 0, r3
; CHECK-P8-NEXT:    lwz r3, 0(r4)
; CHECK-P8-NEXT:    mr r30, r5
; CHECK-P8-NEXT:    mr r5, r3
; CHECK-P8-NEXT:    bl __powikf2
; CHECK-P8-NEXT:    nop
; CHECK-P8-NEXT:    stvx v2, 0, r30
; CHECK-P8-NEXT:    addi r1, r1, 48
; CHECK-P8-NEXT:    ld r0, 16(r1)
; CHECK-P8-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; CHECK-P8-NEXT:    mtlr r0
; CHECK-P8-NEXT:    blr
                     fp128* nocapture %res) {
entry:
  %0 = load fp128, fp128* %a, align 16
  %1 = load i32, i32* %b, align 8
  %2 = tail call fp128 @llvm.powi.f128(fp128 %0, i32 %1)
  store fp128 %2, fp128* %res, align 16
  ret void
}
declare fp128 @llvm.powi.f128(fp128 %Val, i32 %power)

@a = common global fp128 0xL00000000000000000000000000000000, align 16
@b = common global fp128 0xL00000000000000000000000000000000, align 16

define fp128 @qp_frem() #0 {
; CHECK-LABEL: qp_frem:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    mflr r0
; CHECK-NEXT:    std r0, 16(r1)
; CHECK-NEXT:    stdu r1, -32(r1)
; CHECK-NEXT:    .cfi_def_cfa_offset 32
; CHECK-NEXT:    .cfi_offset lr, 16
; CHECK-NEXT:    addis r3, r2, a@toc@ha
; CHECK-NEXT:    addi r3, r3, a@toc@l
; CHECK-NEXT:    lxvx v2, 0, r3
; CHECK-NEXT:    addis r3, r2, b@toc@ha
; CHECK-NEXT:    addi r3, r3, b@toc@l
; CHECK-NEXT:    lxvx v3, 0, r3
; CHECK-NEXT:    bl fmodf128
; CHECK-NEXT:    nop
; CHECK-NEXT:    addi r1, r1, 32
; CHECK-NEXT:    ld r0, 16(r1)
; CHECK-NEXT:    mtlr r0
; CHECK-NEXT:    blr
;
; CHECK-P8-LABEL: qp_frem:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    mflr r0
; CHECK-P8-NEXT:    std r0, 16(r1)
; CHECK-P8-NEXT:    stdu r1, -32(r1)
; CHECK-P8-NEXT:    .cfi_def_cfa_offset 32
; CHECK-P8-NEXT:    .cfi_offset lr, 16
; CHECK-P8-NEXT:    addis r3, r2, a@toc@ha
; CHECK-P8-NEXT:    addis r4, r2, b@toc@ha
; CHECK-P8-NEXT:    addi r3, r3, a@toc@l
; CHECK-P8-NEXT:    addi r4, r4, b@toc@l
; CHECK-P8-NEXT:    lvx v2, 0, r3
; CHECK-P8-NEXT:    lvx v3, 0, r4
; CHECK-P8-NEXT:    bl fmodf128
; CHECK-P8-NEXT:    nop
; CHECK-P8-NEXT:    addi r1, r1, 32
; CHECK-P8-NEXT:    ld r0, 16(r1)
; CHECK-P8-NEXT:    mtlr r0
; CHECK-P8-NEXT:    blr
entry:
  %0 = load fp128, fp128* @a, align 16
  %1 = load fp128, fp128* @b, align 16
  %rem = frem fp128 %0, %1
  ret fp128 %rem
}

define void @qpCeil(fp128* nocapture readonly %a, fp128* nocapture %res) {
; CHECK-LABEL: qpCeil:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lxv v2, 0(r3)
; CHECK-NEXT:    xsrqpi 1, v2, v2, 2
; CHECK-NEXT:    stxv v2, 0(r4)
; CHECK-NEXT:    blr
;
; CHECK-P8-LABEL: qpCeil:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    mflr r0
; CHECK-P8-NEXT:    .cfi_def_cfa_offset 48
; CHECK-P8-NEXT:    .cfi_offset lr, 16
; CHECK-P8-NEXT:    .cfi_offset r30, -16
; CHECK-P8-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; CHECK-P8-NEXT:    std r0, 16(r1)
; CHECK-P8-NEXT:    stdu r1, -48(r1)
; CHECK-P8-NEXT:    lvx v2, 0, r3
; CHECK-P8-NEXT:    mr r30, r4
; CHECK-P8-NEXT:    bl ceilf128
; CHECK-P8-NEXT:    nop
; CHECK-P8-NEXT:    stvx v2, 0, r30
; CHECK-P8-NEXT:    addi r1, r1, 48
; CHECK-P8-NEXT:    ld r0, 16(r1)
; CHECK-P8-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; CHECK-P8-NEXT:    mtlr r0
; CHECK-P8-NEXT:    blr
entry:
  %0 = load fp128, fp128* %a, align 16
  %1 = tail call fp128 @llvm.ceil.f128(fp128 %0)
  store fp128 %1, fp128* %res, align 16
  ret void
}
declare fp128 @llvm.ceil.f128(fp128 %Val)

define void @qpFloor(fp128* nocapture readonly %a, fp128* nocapture %res) {
; CHECK-LABEL: qpFloor:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lxv v2, 0(r3)
; CHECK-NEXT:    xsrqpi 1, v2, v2, 3
; CHECK-NEXT:    stxv v2, 0(r4)
; CHECK-NEXT:    blr
;
; CHECK-P8-LABEL: qpFloor:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    mflr r0
; CHECK-P8-NEXT:    .cfi_def_cfa_offset 48
; CHECK-P8-NEXT:    .cfi_offset lr, 16
; CHECK-P8-NEXT:    .cfi_offset r30, -16
; CHECK-P8-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; CHECK-P8-NEXT:    std r0, 16(r1)
; CHECK-P8-NEXT:    stdu r1, -48(r1)
; CHECK-P8-NEXT:    lvx v2, 0, r3
; CHECK-P8-NEXT:    mr r30, r4
; CHECK-P8-NEXT:    bl floorf128
; CHECK-P8-NEXT:    nop
; CHECK-P8-NEXT:    stvx v2, 0, r30
; CHECK-P8-NEXT:    addi r1, r1, 48
; CHECK-P8-NEXT:    ld r0, 16(r1)
; CHECK-P8-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; CHECK-P8-NEXT:    mtlr r0
; CHECK-P8-NEXT:    blr
entry:
  %0 = load fp128, fp128* %a, align 16
  %1 = tail call fp128 @llvm.floor.f128(fp128 %0)
  store fp128 %1, fp128* %res, align 16
  ret void
}
declare fp128 @llvm.floor.f128(fp128 %Val)

define void @qpTrunc(fp128* nocapture readonly %a, fp128* nocapture %res) {
; CHECK-LABEL: qpTrunc:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lxv v2, 0(r3)
; CHECK-NEXT:    xsrqpi 1, v2, v2, 1
; CHECK-NEXT:    stxv v2, 0(r4)
; CHECK-NEXT:    blr
;
; CHECK-P8-LABEL: qpTrunc:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    mflr r0
; CHECK-P8-NEXT:    .cfi_def_cfa_offset 48
; CHECK-P8-NEXT:    .cfi_offset lr, 16
; CHECK-P8-NEXT:    .cfi_offset r30, -16
; CHECK-P8-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; CHECK-P8-NEXT:    std r0, 16(r1)
; CHECK-P8-NEXT:    stdu r1, -48(r1)
; CHECK-P8-NEXT:    lvx v2, 0, r3
; CHECK-P8-NEXT:    mr r30, r4
; CHECK-P8-NEXT:    bl truncf128
; CHECK-P8-NEXT:    nop
; CHECK-P8-NEXT:    stvx v2, 0, r30
; CHECK-P8-NEXT:    addi r1, r1, 48
; CHECK-P8-NEXT:    ld r0, 16(r1)
; CHECK-P8-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; CHECK-P8-NEXT:    mtlr r0
; CHECK-P8-NEXT:    blr
entry:
  %0 = load fp128, fp128* %a, align 16
  %1 = tail call fp128 @llvm.trunc.f128(fp128 %0)
  store fp128 %1, fp128* %res, align 16
  ret void
}
declare fp128 @llvm.trunc.f128(fp128 %Val)

define void @qpRound(fp128* nocapture readonly %a, fp128* nocapture %res) {
; CHECK-LABEL: qpRound:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lxv v2, 0(r3)
; CHECK-NEXT:    xsrqpi 0, v2, v2, 0
; CHECK-NEXT:    stxv v2, 0(r4)
; CHECK-NEXT:    blr
;
; CHECK-P8-LABEL: qpRound:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    mflr r0
; CHECK-P8-NEXT:    .cfi_def_cfa_offset 48
; CHECK-P8-NEXT:    .cfi_offset lr, 16
; CHECK-P8-NEXT:    .cfi_offset r30, -16
; CHECK-P8-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; CHECK-P8-NEXT:    std r0, 16(r1)
; CHECK-P8-NEXT:    stdu r1, -48(r1)
; CHECK-P8-NEXT:    lvx v2, 0, r3
; CHECK-P8-NEXT:    mr r30, r4
; CHECK-P8-NEXT:    bl roundf128
; CHECK-P8-NEXT:    nop
; CHECK-P8-NEXT:    stvx v2, 0, r30
; CHECK-P8-NEXT:    addi r1, r1, 48
; CHECK-P8-NEXT:    ld r0, 16(r1)
; CHECK-P8-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; CHECK-P8-NEXT:    mtlr r0
; CHECK-P8-NEXT:    blr
entry:
  %0 = load fp128, fp128* %a, align 16
  %1 = tail call fp128 @llvm.round.f128(fp128 %0)
  store fp128 %1, fp128* %res, align 16
  ret void
}
declare fp128 @llvm.round.f128(fp128 %Val)

define void @qpLRound(fp128* nocapture readonly %a, i32* nocapture %res) {
; CHECK-LABEL: qpLRound:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    mflr r0
; CHECK-NEXT:    .cfi_def_cfa_offset 48
; CHECK-NEXT:    .cfi_offset lr, 16
; CHECK-NEXT:    .cfi_offset r30, -16
; CHECK-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; CHECK-NEXT:    std r0, 16(r1)
; CHECK-NEXT:    stdu r1, -48(r1)
; CHECK-NEXT:    lxv v2, 0(r3)
; CHECK-NEXT:    mr r30, r4
; CHECK-NEXT:    bl lroundf128
; CHECK-NEXT:    nop
; CHECK-NEXT:    stw r3, 0(r30)
; CHECK-NEXT:    addi r1, r1, 48
; CHECK-NEXT:    ld r0, 16(r1)
; CHECK-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; CHECK-NEXT:    mtlr r0
; CHECK-NEXT:    blr
;
; CHECK-P8-LABEL: qpLRound:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    mflr r0
; CHECK-P8-NEXT:    .cfi_def_cfa_offset 48
; CHECK-P8-NEXT:    .cfi_offset lr, 16
; CHECK-P8-NEXT:    .cfi_offset r30, -16
; CHECK-P8-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; CHECK-P8-NEXT:    std r0, 16(r1)
; CHECK-P8-NEXT:    stdu r1, -48(r1)
; CHECK-P8-NEXT:    lvx v2, 0, r3
; CHECK-P8-NEXT:    mr r30, r4
; CHECK-P8-NEXT:    bl lroundf128
; CHECK-P8-NEXT:    nop
; CHECK-P8-NEXT:    stw r3, 0(r30)
; CHECK-P8-NEXT:    addi r1, r1, 48
; CHECK-P8-NEXT:    ld r0, 16(r1)
; CHECK-P8-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; CHECK-P8-NEXT:    mtlr r0
; CHECK-P8-NEXT:    blr
entry:
  %0 = load fp128, fp128* %a, align 16
  %1 = tail call i32 @llvm.lround.f128(fp128 %0)
  store i32 %1, i32* %res, align 16
  ret void
}
declare i32 @llvm.lround.f128(fp128 %Val)

define void @qpLLRound(fp128* nocapture readonly %a, i64* nocapture %res) {
; CHECK-LABEL: qpLLRound:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    mflr r0
; CHECK-NEXT:    .cfi_def_cfa_offset 48
; CHECK-NEXT:    .cfi_offset lr, 16
; CHECK-NEXT:    .cfi_offset r30, -16
; CHECK-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; CHECK-NEXT:    std r0, 16(r1)
; CHECK-NEXT:    stdu r1, -48(r1)
; CHECK-NEXT:    lxv v2, 0(r3)
; CHECK-NEXT:    mr r30, r4
; CHECK-NEXT:    bl llroundf128
; CHECK-NEXT:    nop
; CHECK-NEXT:    std r3, 0(r30)
; CHECK-NEXT:    addi r1, r1, 48
; CHECK-NEXT:    ld r0, 16(r1)
; CHECK-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; CHECK-NEXT:    mtlr r0
; CHECK-NEXT:    blr
;
; CHECK-P8-LABEL: qpLLRound:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    mflr r0
; CHECK-P8-NEXT:    .cfi_def_cfa_offset 48
; CHECK-P8-NEXT:    .cfi_offset lr, 16
; CHECK-P8-NEXT:    .cfi_offset r30, -16
; CHECK-P8-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; CHECK-P8-NEXT:    std r0, 16(r1)
; CHECK-P8-NEXT:    stdu r1, -48(r1)
; CHECK-P8-NEXT:    lvx v2, 0, r3
; CHECK-P8-NEXT:    mr r30, r4
; CHECK-P8-NEXT:    bl llroundf128
; CHECK-P8-NEXT:    nop
; CHECK-P8-NEXT:    std r3, 0(r30)
; CHECK-P8-NEXT:    addi r1, r1, 48
; CHECK-P8-NEXT:    ld r0, 16(r1)
; CHECK-P8-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; CHECK-P8-NEXT:    mtlr r0
; CHECK-P8-NEXT:    blr
entry:
  %0 = load fp128, fp128* %a, align 16
  %1 = tail call i64 @llvm.llround.f128(fp128 %0)
  store i64 %1, i64* %res, align 16
  ret void
}
declare i64 @llvm.llround.f128(fp128 %Val)

define void @qpRint(fp128* nocapture readonly %a, fp128* nocapture %res) {
; CHECK-LABEL: qpRint:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lxv v2, 0(r3)
; CHECK-NEXT:    xsrqpix 0, v2, v2, 3
; CHECK-NEXT:    stxv v2, 0(r4)
; CHECK-NEXT:    blr
;
; CHECK-P8-LABEL: qpRint:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    mflr r0
; CHECK-P8-NEXT:    .cfi_def_cfa_offset 48
; CHECK-P8-NEXT:    .cfi_offset lr, 16
; CHECK-P8-NEXT:    .cfi_offset r30, -16
; CHECK-P8-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; CHECK-P8-NEXT:    std r0, 16(r1)
; CHECK-P8-NEXT:    stdu r1, -48(r1)
; CHECK-P8-NEXT:    lvx v2, 0, r3
; CHECK-P8-NEXT:    mr r30, r4
; CHECK-P8-NEXT:    bl rintf128
; CHECK-P8-NEXT:    nop
; CHECK-P8-NEXT:    stvx v2, 0, r30
; CHECK-P8-NEXT:    addi r1, r1, 48
; CHECK-P8-NEXT:    ld r0, 16(r1)
; CHECK-P8-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; CHECK-P8-NEXT:    mtlr r0
; CHECK-P8-NEXT:    blr
entry:
  %0 = load fp128, fp128* %a, align 16
  %1 = tail call fp128 @llvm.rint.f128(fp128 %0)
  store fp128 %1, fp128* %res, align 16
  ret void
}
declare fp128 @llvm.rint.f128(fp128 %Val)

define void @qpLRint(fp128* nocapture readonly %a, i32* nocapture %res) {
; CHECK-LABEL: qpLRint:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    mflr r0
; CHECK-NEXT:    .cfi_def_cfa_offset 48
; CHECK-NEXT:    .cfi_offset lr, 16
; CHECK-NEXT:    .cfi_offset r30, -16
; CHECK-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; CHECK-NEXT:    std r0, 16(r1)
; CHECK-NEXT:    stdu r1, -48(r1)
; CHECK-NEXT:    lxv v2, 0(r3)
; CHECK-NEXT:    mr r30, r4
; CHECK-NEXT:    bl lrintf128
; CHECK-NEXT:    nop
; CHECK-NEXT:    stw r3, 0(r30)
; CHECK-NEXT:    addi r1, r1, 48
; CHECK-NEXT:    ld r0, 16(r1)
; CHECK-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; CHECK-NEXT:    mtlr r0
; CHECK-NEXT:    blr
;
; CHECK-P8-LABEL: qpLRint:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    mflr r0
; CHECK-P8-NEXT:    .cfi_def_cfa_offset 48
; CHECK-P8-NEXT:    .cfi_offset lr, 16
; CHECK-P8-NEXT:    .cfi_offset r30, -16
; CHECK-P8-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; CHECK-P8-NEXT:    std r0, 16(r1)
; CHECK-P8-NEXT:    stdu r1, -48(r1)
; CHECK-P8-NEXT:    lvx v2, 0, r3
; CHECK-P8-NEXT:    mr r30, r4
; CHECK-P8-NEXT:    bl lrintf128
; CHECK-P8-NEXT:    nop
; CHECK-P8-NEXT:    stw r3, 0(r30)
; CHECK-P8-NEXT:    addi r1, r1, 48
; CHECK-P8-NEXT:    ld r0, 16(r1)
; CHECK-P8-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; CHECK-P8-NEXT:    mtlr r0
; CHECK-P8-NEXT:    blr
entry:
  %0 = load fp128, fp128* %a, align 16
  %1 = tail call i32 @llvm.lrint.f128(fp128 %0)
  store i32 %1, i32* %res, align 16
  ret void
}
declare i32 @llvm.lrint.f128(fp128 %Val)

define void @qpLLRint(fp128* nocapture readonly %a, i64* nocapture %res) {
; CHECK-LABEL: qpLLRint:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    mflr r0
; CHECK-NEXT:    .cfi_def_cfa_offset 48
; CHECK-NEXT:    .cfi_offset lr, 16
; CHECK-NEXT:    .cfi_offset r30, -16
; CHECK-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; CHECK-NEXT:    std r0, 16(r1)
; CHECK-NEXT:    stdu r1, -48(r1)
; CHECK-NEXT:    lxv v2, 0(r3)
; CHECK-NEXT:    mr r30, r4
; CHECK-NEXT:    bl llrintf128
; CHECK-NEXT:    nop
; CHECK-NEXT:    std r3, 0(r30)
; CHECK-NEXT:    addi r1, r1, 48
; CHECK-NEXT:    ld r0, 16(r1)
; CHECK-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; CHECK-NEXT:    mtlr r0
; CHECK-NEXT:    blr
;
; CHECK-P8-LABEL: qpLLRint:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    mflr r0
; CHECK-P8-NEXT:    .cfi_def_cfa_offset 48
; CHECK-P8-NEXT:    .cfi_offset lr, 16
; CHECK-P8-NEXT:    .cfi_offset r30, -16
; CHECK-P8-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; CHECK-P8-NEXT:    std r0, 16(r1)
; CHECK-P8-NEXT:    stdu r1, -48(r1)
; CHECK-P8-NEXT:    lvx v2, 0, r3
; CHECK-P8-NEXT:    mr r30, r4
; CHECK-P8-NEXT:    bl llrintf128
; CHECK-P8-NEXT:    nop
; CHECK-P8-NEXT:    std r3, 0(r30)
; CHECK-P8-NEXT:    addi r1, r1, 48
; CHECK-P8-NEXT:    ld r0, 16(r1)
; CHECK-P8-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; CHECK-P8-NEXT:    mtlr r0
; CHECK-P8-NEXT:    blr
entry:
  %0 = load fp128, fp128* %a, align 16
  %1 = tail call i64 @llvm.llrint.f128(fp128 %0)
  store i64 %1, i64* %res, align 16
  ret void
}
declare i64 @llvm.llrint.f128(fp128 %Val)

define void @qpNearByInt(fp128* nocapture readonly %a, fp128* nocapture %res) {
; CHECK-LABEL: qpNearByInt:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lxv v2, 0(r3)
; CHECK-NEXT:    xsrqpi 0, v2, v2, 3
; CHECK-NEXT:    stxv v2, 0(r4)
; CHECK-NEXT:    blr
;
; CHECK-P8-LABEL: qpNearByInt:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    mflr r0
; CHECK-P8-NEXT:    .cfi_def_cfa_offset 48
; CHECK-P8-NEXT:    .cfi_offset lr, 16
; CHECK-P8-NEXT:    .cfi_offset r30, -16
; CHECK-P8-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; CHECK-P8-NEXT:    std r0, 16(r1)
; CHECK-P8-NEXT:    stdu r1, -48(r1)
; CHECK-P8-NEXT:    lvx v2, 0, r3
; CHECK-P8-NEXT:    mr r30, r4
; CHECK-P8-NEXT:    bl nearbyintf128
; CHECK-P8-NEXT:    nop
; CHECK-P8-NEXT:    stvx v2, 0, r30
; CHECK-P8-NEXT:    addi r1, r1, 48
; CHECK-P8-NEXT:    ld r0, 16(r1)
; CHECK-P8-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; CHECK-P8-NEXT:    mtlr r0
; CHECK-P8-NEXT:    blr
entry:
  %0 = load fp128, fp128* %a, align 16
  %1 = tail call fp128 @llvm.nearbyint.f128(fp128 %0)
  store fp128 %1, fp128* %res, align 16
  ret void
}
declare fp128 @llvm.nearbyint.f128(fp128 %Val)

define void @qpFMA(fp128* %a, fp128* %b, fp128* %c, fp128* %res) {
; CHECK-LABEL: qpFMA:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lxv v2, 0(r3)
; CHECK-NEXT:    lxv v3, 0(r4)
; CHECK-NEXT:    lxv v4, 0(r5)
; CHECK-NEXT:    xsmaddqp v4, v2, v3
; CHECK-NEXT:    stxv v4, 0(r6)
; CHECK-NEXT:    blr
;
; CHECK-P8-LABEL: qpFMA:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    mflr r0
; CHECK-P8-NEXT:    .cfi_def_cfa_offset 48
; CHECK-P8-NEXT:    .cfi_offset lr, 16
; CHECK-P8-NEXT:    .cfi_offset r30, -16
; CHECK-P8-NEXT:    std r30, -16(r1) # 8-byte Folded Spill
; CHECK-P8-NEXT:    std r0, 16(r1)
; CHECK-P8-NEXT:    stdu r1, -48(r1)
; CHECK-P8-NEXT:    lvx v2, 0, r3
; CHECK-P8-NEXT:    lvx v3, 0, r4
; CHECK-P8-NEXT:    lvx v4, 0, r5
; CHECK-P8-NEXT:    mr r30, r6
; CHECK-P8-NEXT:    bl fmaf128
; CHECK-P8-NEXT:    nop
; CHECK-P8-NEXT:    stvx v2, 0, r30
; CHECK-P8-NEXT:    addi r1, r1, 48
; CHECK-P8-NEXT:    ld r0, 16(r1)
; CHECK-P8-NEXT:    ld r30, -16(r1) # 8-byte Folded Reload
; CHECK-P8-NEXT:    mtlr r0
; CHECK-P8-NEXT:    blr
entry:
  %0 = load fp128, fp128* %a, align 16
  %1 = load fp128, fp128* %b, align 16
  %2 = load fp128, fp128* %c, align 16
  %3 = tail call fp128 @llvm.fma.f128(fp128 %0, fp128 %1, fp128 %2)
  store fp128 %3, fp128* %res, align 16
  ret void
}
declare fp128 @llvm.fma.f128(fp128, fp128, fp128)
