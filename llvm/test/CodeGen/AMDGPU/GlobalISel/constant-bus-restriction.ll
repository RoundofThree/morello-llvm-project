; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -global-isel -mtriple=amdgcn-mesa-mesa3d -mcpu=gfx900 -verify-machineinstrs < %s | FileCheck -enable-var-scope -check-prefix=GFX9 %s
; RUN: llc -global-isel -mtriple=amdgcn-mesa-mesa3d -mcpu=gfx1010 -verify-machineinstrs < %s | FileCheck -enable-var-scope -check-prefix=GFX10 %s

; Make sure we don't violate the constant bus restriction

define amdgpu_ps float @fmul_s_s(float inreg %src0, float inreg %src1) {
; GFX9-LABEL: fmul_s_s:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    v_mov_b32_e32 v0, s3
; GFX9-NEXT:    v_mul_f32_e32 v0, s2, v0
; GFX9-NEXT:    ; return to shader part epilog
;
; GFX10-LABEL: fmul_s_s:
; GFX10:       ; %bb.0:
; GFX10-NEXT:    v_mul_f32_e64 v0, s2, s3
; GFX10-NEXT:    ; implicit-def: $vcc_hi
; GFX10-NEXT:    ; return to shader part epilog
  %result = fmul float %src0, %src1
  ret float %result
}

define amdgpu_ps float @fmul_ss(float inreg %src) {
; GFX9-LABEL: fmul_ss:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    v_mul_f32_e64 v0, s2, s2
; GFX9-NEXT:    ; return to shader part epilog
;
; GFX10-LABEL: fmul_ss:
; GFX10:       ; %bb.0:
; GFX10-NEXT:    v_mul_f32_e64 v0, s2, s2
; GFX10-NEXT:    ; implicit-def: $vcc_hi
; GFX10-NEXT:    ; return to shader part epilog
  %result = fmul float %src, %src
  ret float %result
}

; Ternary operation with 3 different SGPRs
define amdgpu_ps float @fma_s_s_s(float inreg %src0, float inreg %src1, float inreg %src2) {
; GFX9-LABEL: fma_s_s_s:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    v_mov_b32_e32 v0, s3
; GFX9-NEXT:    v_mov_b32_e32 v1, s4
; GFX9-NEXT:    v_fma_f32 v0, s2, v0, v1
; GFX9-NEXT:    ; return to shader part epilog
;
; GFX10-LABEL: fma_s_s_s:
; GFX10:       ; %bb.0:
; GFX10-NEXT:    v_mov_b32_e32 v0, s4
; GFX10-NEXT:    ; implicit-def: $vcc_hi
; GFX10-NEXT:    v_fma_f32 v0, s3, s2, v0
; GFX10-NEXT:    ; return to shader part epilog
  %result = call float @llvm.fma.f32(float %src0, float %src1, float %src2)
  ret float %result
}

; Ternary operation with 3 identical SGPRs
define amdgpu_ps float @fma_sss(float inreg %src) {
; GFX9-LABEL: fma_sss:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    v_fma_f32 v0, s2, s2, s2
; GFX9-NEXT:    ; return to shader part epilog
;
; GFX10-LABEL: fma_sss:
; GFX10:       ; %bb.0:
; GFX10-NEXT:    v_fma_f32 v0, s2, s2, s2
; GFX10-NEXT:    ; implicit-def: $vcc_hi
; GFX10-NEXT:    ; return to shader part epilog
  %result = call float @llvm.fma.f32(float %src, float %src, float %src)
  ret float %result
}

; src0/1 are same SGPR
define amdgpu_ps float @fma_ss_s(float inreg %src01, float inreg %src2) {
; GFX9-LABEL: fma_ss_s:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    v_mov_b32_e32 v0, s3
; GFX9-NEXT:    v_fma_f32 v0, s2, s2, v0
; GFX9-NEXT:    ; return to shader part epilog
;
; GFX10-LABEL: fma_ss_s:
; GFX10:       ; %bb.0:
; GFX10-NEXT:    v_fma_f32 v0, s2, s2, s3
; GFX10-NEXT:    ; implicit-def: $vcc_hi
; GFX10-NEXT:    ; return to shader part epilog
  %result = call float @llvm.fma.f32(float %src01, float %src01, float %src2)
  ret float %result
}

; src1/2 are same SGPR
define amdgpu_ps float @fma_s_ss(float inreg %src0, float inreg %src12) {
; GFX9-LABEL: fma_s_ss:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    v_mov_b32_e32 v0, s3
; GFX9-NEXT:    v_fma_f32 v0, s2, v0, v0
; GFX9-NEXT:    ; return to shader part epilog
;
; GFX10-LABEL: fma_s_ss:
; GFX10:       ; %bb.0:
; GFX10-NEXT:    v_fma_f32 v0, s2, s3, s3
; GFX10-NEXT:    ; implicit-def: $vcc_hi
; GFX10-NEXT:    ; return to shader part epilog
  %result = call float @llvm.fma.f32(float %src0, float %src12, float %src12)
  ret float %result
}

; src0/2 are same SGPR
define amdgpu_ps float @fma_ss_s_same_outer(float inreg %src02, float inreg %src1) {
; GFX9-LABEL: fma_ss_s_same_outer:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    v_mov_b32_e32 v0, s3
; GFX9-NEXT:    v_fma_f32 v0, s2, v0, s2
; GFX9-NEXT:    ; return to shader part epilog
;
; GFX10-LABEL: fma_ss_s_same_outer:
; GFX10:       ; %bb.0:
; GFX10-NEXT:    v_fma_f32 v0, s2, s3, s2
; GFX10-NEXT:    ; implicit-def: $vcc_hi
; GFX10-NEXT:    ; return to shader part epilog
  %result = call float @llvm.fma.f32(float %src02, float %src1, float %src02)
  ret float %result
}

define amdgpu_ps float @fcmp_s_s(float inreg %src0, float inreg %src1) {
; GFX9-LABEL: fcmp_s_s:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    v_mov_b32_e32 v0, s3
; GFX9-NEXT:    v_cmp_eq_f32_e32 vcc, s2, v0
; GFX9-NEXT:    v_cndmask_b32_e64 v0, 0, 1.0, vcc
; GFX9-NEXT:    ; return to shader part epilog
;
; GFX10-LABEL: fcmp_s_s:
; GFX10:       ; %bb.0:
; GFX10-NEXT:    v_cmp_eq_f32_e64 s0, s2, s3
; GFX10-NEXT:    ; implicit-def: $vcc_hi
; GFX10-NEXT:    v_cndmask_b32_e64 v0, 0, 1.0, s0
; GFX10-NEXT:    ; return to shader part epilog
  %cmp = fcmp oeq float %src0, %src1
  %result = select i1 %cmp, float 1.0, float 0.0
  ret float %result
}

define amdgpu_ps float @select_vcc_s_s(float %cmp0, float %cmp1, float inreg %src0, float inreg %src1) {
; GFX9-LABEL: select_vcc_s_s:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    v_mov_b32_e32 v2, s2
; GFX9-NEXT:    v_mov_b32_e32 v3, s3
; GFX9-NEXT:    v_cmp_eq_f32_e32 vcc, v0, v1
; GFX9-NEXT:    v_cndmask_b32_e32 v0, v3, v2, vcc
; GFX9-NEXT:    ; return to shader part epilog
;
; GFX10-LABEL: select_vcc_s_s:
; GFX10:       ; %bb.0:
; GFX10-NEXT:    v_mov_b32_e32 v2, s3
; GFX10-NEXT:    v_cmp_eq_f32_e32 vcc_lo, v0, v1
; GFX10-NEXT:    ; implicit-def: $vcc_hi
; GFX10-NEXT:    v_cndmask_b32_e64 v0, v2, s2, vcc_lo
; GFX10-NEXT:    ; return to shader part epilog
  %cmp = fcmp oeq float %cmp0, %cmp1
  %result = select i1 %cmp, float %src0, float %src1
  ret float %result
}

define amdgpu_ps float @select_vcc_fneg_s_s(float %cmp0, float %cmp1, float inreg %src0, float inreg %src1) {
; GFX9-LABEL: select_vcc_fneg_s_s:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    v_mov_b32_e32 v2, s3
; GFX9-NEXT:    v_mov_b32_e32 v3, s2
; GFX9-NEXT:    v_cmp_eq_f32_e32 vcc, v0, v1
; GFX9-NEXT:    v_cndmask_b32_e64 v0, v2, -v3, vcc
; GFX9-NEXT:    ; return to shader part epilog
;
; GFX10-LABEL: select_vcc_fneg_s_s:
; GFX10:       ; %bb.0:
; GFX10-NEXT:    v_mov_b32_e32 v2, s2
; GFX10-NEXT:    v_cmp_eq_f32_e32 vcc_lo, v0, v1
; GFX10-NEXT:    ; implicit-def: $vcc_hi
; GFX10-NEXT:    v_cndmask_b32_e64 v0, s3, -v2, vcc_lo
; GFX10-NEXT:    ; return to shader part epilog
  %cmp = fcmp oeq float %cmp0, %cmp1
  %neg.src0 = fneg float %src0
  %result = select i1 %cmp, float %neg.src0, float %src1
  ret float %result
}

; Constant bus used by vcc
define amdgpu_ps float @amdgcn_div_fmas_sss(float inreg %src, float %cmp.src) {
; GFX9-LABEL: amdgcn_div_fmas_sss:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    v_cmp_eq_f32_e32 vcc, 0, v0
; GFX9-NEXT:    v_mov_b32_e32 v0, s2
; GFX9-NEXT:    s_nop 2
; GFX9-NEXT:    v_div_fmas_f32 v0, v0, v0, v0
; GFX9-NEXT:    ; return to shader part epilog
;
; GFX10-LABEL: amdgcn_div_fmas_sss:
; GFX10:       ; %bb.0:
; GFX10-NEXT:    v_cmp_eq_f32_e32 vcc_lo, 0, v0
; GFX10-NEXT:    v_div_fmas_f32 v0, s2, s2, s2
; GFX10-NEXT:    ; implicit-def: $vcc_hi
; GFX10-NEXT:    ; return to shader part epilog
  %vcc = fcmp oeq float %cmp.src, 0.0
  %result = call float @llvm.amdgcn.div.fmas.f32(float %src, float %src, float %src, i1 %vcc)
  ret float %result
}

define amdgpu_ps float @class_s_s(float inreg %src0, i32 inreg %src1) {
; GFX9-LABEL: class_s_s:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    v_mov_b32_e32 v0, s3
; GFX9-NEXT:    v_cmp_class_f32_e32 vcc, s2, v0
; GFX9-NEXT:    v_cndmask_b32_e64 v0, 0, 1.0, vcc
; GFX9-NEXT:    ; return to shader part epilog
;
; GFX10-LABEL: class_s_s:
; GFX10:       ; %bb.0:
; GFX10-NEXT:    v_cmp_class_f32_e64 s0, s2, s3
; GFX10-NEXT:    ; implicit-def: $vcc_hi
; GFX10-NEXT:    v_cndmask_b32_e64 v0, 0, 1.0, s0
; GFX10-NEXT:    ; return to shader part epilog
  %class = call i1 @llvm.amdgcn.class.f32(float %src0, i32 %src1)
  %result = select i1 %class, float 1.0, float 0.0
  ret float %result
}

define amdgpu_ps float @div_scale_s_s_true(float inreg %src0, float inreg %src1) {
; GFX9-LABEL: div_scale_s_s_true:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    v_mov_b32_e32 v0, s3
; GFX9-NEXT:    v_div_scale_f32 v0, s[0:1], s2, v0, s2
; GFX9-NEXT:    ; return to shader part epilog
;
; GFX10-LABEL: div_scale_s_s_true:
; GFX10:       ; %bb.0:
; GFX10-NEXT:    v_div_scale_f32 v0, s0, s2, s3, s2
; GFX10-NEXT:    ; implicit-def: $vcc_hi
; GFX10-NEXT:    ; return to shader part epilog
  %div.scale = call { float, i1 } @llvm.amdgcn.div.scale.f32(float %src0, float %src1, i1 true)
  %result = extractvalue { float, i1 } %div.scale, 0
  ret float %result
}

define amdgpu_ps float @div_scale_s_s_false(float inreg %src0, float inreg %src1) {
; GFX9-LABEL: div_scale_s_s_false:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    v_mov_b32_e32 v0, s3
; GFX9-NEXT:    v_div_scale_f32 v0, s[0:1], v0, v0, s2
; GFX9-NEXT:    ; return to shader part epilog
;
; GFX10-LABEL: div_scale_s_s_false:
; GFX10:       ; %bb.0:
; GFX10-NEXT:    v_div_scale_f32 v0, s0, s3, s3, s2
; GFX10-NEXT:    ; implicit-def: $vcc_hi
; GFX10-NEXT:    ; return to shader part epilog
  %div.scale = call { float, i1 } @llvm.amdgcn.div.scale.f32(float %src0, float %src1, i1 false)
  %result = extractvalue { float, i1 } %div.scale, 0
  ret float %result
}

declare float @llvm.fma.f32(float, float, float) #0
declare float @llvm.amdgcn.div.fmas.f32(float, float, float, i1) #1
declare { float, i1 } @llvm.amdgcn.div.scale.f32(float, float, i1 immarg) #1
declare i1 @llvm.amdgcn.class.f32(float, i32) #1

attributes #0 = { nounwind readnone speculatable willreturn }
attributes #1 = { nounwind readnone speculatable }
