; NOTE: Assertions have been autogenerated by utils/update_mir_test_checks.py
; RUN: llc -global-isel -mtriple=amdgcn-mesa-mesa3d -mcpu=gfx900 -stop-after=regbankselect -verify-machineinstrs < %s | FileCheck -enable-var-scope -check-prefix=GFX9 %s
; RUN: llc -global-isel -mtriple=amdgcn-mesa-mesa3d -mcpu=gfx1010 -stop-after=regbankselect -verify-machineinstrs < %s | FileCheck -enable-var-scope -check-prefix=GFX10 %s

; Make sure we don't violate the constant bus restriction
; FIXME: Make this test isa output when div.fmas works.


define amdgpu_ps float @fmul_s_s(float inreg %src0, float inreg %src1) {
  ; GFX9-LABEL: name: fmul_s_s
  ; GFX9: bb.1 (%ir-block.0):
  ; GFX9:   liveins: $sgpr2, $sgpr3
  ; GFX9:   [[COPY:%[0-9]+]]:sgpr(s32) = COPY $sgpr2
  ; GFX9:   [[COPY1:%[0-9]+]]:sgpr(s32) = COPY $sgpr3
  ; GFX9:   [[COPY2:%[0-9]+]]:vgpr(s32) = COPY [[COPY]](s32)
  ; GFX9:   [[COPY3:%[0-9]+]]:vgpr(s32) = COPY [[COPY1]](s32)
  ; GFX9:   [[FMUL:%[0-9]+]]:vgpr(s32) = G_FMUL [[COPY2]], [[COPY3]]
  ; GFX9:   $vgpr0 = COPY [[FMUL]](s32)
  ; GFX9:   SI_RETURN_TO_EPILOG implicit $vgpr0
  ; GFX10-LABEL: name: fmul_s_s
  ; GFX10: bb.1 (%ir-block.0):
  ; GFX10:   liveins: $sgpr2, $sgpr3
  ; GFX10:   [[COPY:%[0-9]+]]:sgpr(s32) = COPY $sgpr2
  ; GFX10:   [[COPY1:%[0-9]+]]:sgpr(s32) = COPY $sgpr3
  ; GFX10:   [[COPY2:%[0-9]+]]:vgpr(s32) = COPY [[COPY]](s32)
  ; GFX10:   [[COPY3:%[0-9]+]]:vgpr(s32) = COPY [[COPY1]](s32)
  ; GFX10:   [[FMUL:%[0-9]+]]:vgpr(s32) = G_FMUL [[COPY2]], [[COPY3]]
  ; GFX10:   $vgpr0 = COPY [[FMUL]](s32)
  ; GFX10:   SI_RETURN_TO_EPILOG implicit $vgpr0
  %result = fmul float %src0, %src1
  ret float %result
}

define amdgpu_ps float @fmul_ss(float inreg %src) {
  ; GFX9-LABEL: name: fmul_ss
  ; GFX9: bb.1 (%ir-block.0):
  ; GFX9:   liveins: $sgpr2
  ; GFX9:   [[COPY:%[0-9]+]]:sgpr(s32) = COPY $sgpr2
  ; GFX9:   [[COPY1:%[0-9]+]]:vgpr(s32) = COPY [[COPY]](s32)
  ; GFX9:   [[COPY2:%[0-9]+]]:vgpr(s32) = COPY [[COPY]](s32)
  ; GFX9:   [[FMUL:%[0-9]+]]:vgpr(s32) = G_FMUL [[COPY1]], [[COPY2]]
  ; GFX9:   $vgpr0 = COPY [[FMUL]](s32)
  ; GFX9:   SI_RETURN_TO_EPILOG implicit $vgpr0
  ; GFX10-LABEL: name: fmul_ss
  ; GFX10: bb.1 (%ir-block.0):
  ; GFX10:   liveins: $sgpr2
  ; GFX10:   [[COPY:%[0-9]+]]:sgpr(s32) = COPY $sgpr2
  ; GFX10:   [[COPY1:%[0-9]+]]:vgpr(s32) = COPY [[COPY]](s32)
  ; GFX10:   [[COPY2:%[0-9]+]]:vgpr(s32) = COPY [[COPY]](s32)
  ; GFX10:   [[FMUL:%[0-9]+]]:vgpr(s32) = G_FMUL [[COPY1]], [[COPY2]]
  ; GFX10:   $vgpr0 = COPY [[FMUL]](s32)
  ; GFX10:   SI_RETURN_TO_EPILOG implicit $vgpr0
  %result = fmul float %src, %src
  ret float %result
}

; Ternary operation with 3 different SGPRs
define amdgpu_ps float @fma_s_s_s(float inreg %src0, float inreg %src1, float inreg %src2) {
  ; GFX9-LABEL: name: fma_s_s_s
  ; GFX9: bb.1 (%ir-block.0):
  ; GFX9:   liveins: $sgpr2, $sgpr3, $sgpr4
  ; GFX9:   [[COPY:%[0-9]+]]:sgpr(s32) = COPY $sgpr2
  ; GFX9:   [[COPY1:%[0-9]+]]:sgpr(s32) = COPY $sgpr3
  ; GFX9:   [[COPY2:%[0-9]+]]:sgpr(s32) = COPY $sgpr4
  ; GFX9:   [[COPY3:%[0-9]+]]:vgpr(s32) = COPY [[COPY]](s32)
  ; GFX9:   [[COPY4:%[0-9]+]]:vgpr(s32) = COPY [[COPY1]](s32)
  ; GFX9:   [[COPY5:%[0-9]+]]:vgpr(s32) = COPY [[COPY2]](s32)
  ; GFX9:   [[FMA:%[0-9]+]]:vgpr(s32) = G_FMA [[COPY3]], [[COPY4]], [[COPY5]]
  ; GFX9:   $vgpr0 = COPY [[FMA]](s32)
  ; GFX9:   SI_RETURN_TO_EPILOG implicit $vgpr0
  ; GFX10-LABEL: name: fma_s_s_s
  ; GFX10: bb.1 (%ir-block.0):
  ; GFX10:   liveins: $sgpr2, $sgpr3, $sgpr4
  ; GFX10:   [[COPY:%[0-9]+]]:sgpr(s32) = COPY $sgpr2
  ; GFX10:   [[COPY1:%[0-9]+]]:sgpr(s32) = COPY $sgpr3
  ; GFX10:   [[COPY2:%[0-9]+]]:sgpr(s32) = COPY $sgpr4
  ; GFX10:   [[COPY3:%[0-9]+]]:vgpr(s32) = COPY [[COPY]](s32)
  ; GFX10:   [[COPY4:%[0-9]+]]:vgpr(s32) = COPY [[COPY1]](s32)
  ; GFX10:   [[COPY5:%[0-9]+]]:vgpr(s32) = COPY [[COPY2]](s32)
  ; GFX10:   [[FMA:%[0-9]+]]:vgpr(s32) = G_FMA [[COPY3]], [[COPY4]], [[COPY5]]
  ; GFX10:   $vgpr0 = COPY [[FMA]](s32)
  ; GFX10:   SI_RETURN_TO_EPILOG implicit $vgpr0
  %result = call float @llvm.fma.f32(float %src0, float %src1, float %src2)
  ret float %result
}

; Ternary operation with 3 identical SGPRs
define amdgpu_ps float @fma_sss(float inreg %src) {
  ; GFX9-LABEL: name: fma_sss
  ; GFX9: bb.1 (%ir-block.0):
  ; GFX9:   liveins: $sgpr2
  ; GFX9:   [[COPY:%[0-9]+]]:sgpr(s32) = COPY $sgpr2
  ; GFX9:   [[COPY1:%[0-9]+]]:vgpr(s32) = COPY [[COPY]](s32)
  ; GFX9:   [[COPY2:%[0-9]+]]:vgpr(s32) = COPY [[COPY]](s32)
  ; GFX9:   [[COPY3:%[0-9]+]]:vgpr(s32) = COPY [[COPY]](s32)
  ; GFX9:   [[FMA:%[0-9]+]]:vgpr(s32) = G_FMA [[COPY1]], [[COPY2]], [[COPY3]]
  ; GFX9:   $vgpr0 = COPY [[FMA]](s32)
  ; GFX9:   SI_RETURN_TO_EPILOG implicit $vgpr0
  ; GFX10-LABEL: name: fma_sss
  ; GFX10: bb.1 (%ir-block.0):
  ; GFX10:   liveins: $sgpr2
  ; GFX10:   [[COPY:%[0-9]+]]:sgpr(s32) = COPY $sgpr2
  ; GFX10:   [[COPY1:%[0-9]+]]:vgpr(s32) = COPY [[COPY]](s32)
  ; GFX10:   [[COPY2:%[0-9]+]]:vgpr(s32) = COPY [[COPY]](s32)
  ; GFX10:   [[COPY3:%[0-9]+]]:vgpr(s32) = COPY [[COPY]](s32)
  ; GFX10:   [[FMA:%[0-9]+]]:vgpr(s32) = G_FMA [[COPY1]], [[COPY2]], [[COPY3]]
  ; GFX10:   $vgpr0 = COPY [[FMA]](s32)
  ; GFX10:   SI_RETURN_TO_EPILOG implicit $vgpr0
  %result = call float @llvm.fma.f32(float %src, float %src, float %src)
  ret float %result
}

; src0/1 are same SGPR
define amdgpu_ps float @fma_ss_s(float inreg %src01, float inreg %src2) {
  ; GFX9-LABEL: name: fma_ss_s
  ; GFX9: bb.1 (%ir-block.0):
  ; GFX9:   liveins: $sgpr2, $sgpr3
  ; GFX9:   [[COPY:%[0-9]+]]:sgpr(s32) = COPY $sgpr2
  ; GFX9:   [[COPY1:%[0-9]+]]:sgpr(s32) = COPY $sgpr3
  ; GFX9:   [[COPY2:%[0-9]+]]:vgpr(s32) = COPY [[COPY]](s32)
  ; GFX9:   [[COPY3:%[0-9]+]]:vgpr(s32) = COPY [[COPY]](s32)
  ; GFX9:   [[COPY4:%[0-9]+]]:vgpr(s32) = COPY [[COPY1]](s32)
  ; GFX9:   [[FMA:%[0-9]+]]:vgpr(s32) = G_FMA [[COPY2]], [[COPY3]], [[COPY4]]
  ; GFX9:   $vgpr0 = COPY [[FMA]](s32)
  ; GFX9:   SI_RETURN_TO_EPILOG implicit $vgpr0
  ; GFX10-LABEL: name: fma_ss_s
  ; GFX10: bb.1 (%ir-block.0):
  ; GFX10:   liveins: $sgpr2, $sgpr3
  ; GFX10:   [[COPY:%[0-9]+]]:sgpr(s32) = COPY $sgpr2
  ; GFX10:   [[COPY1:%[0-9]+]]:sgpr(s32) = COPY $sgpr3
  ; GFX10:   [[COPY2:%[0-9]+]]:vgpr(s32) = COPY [[COPY]](s32)
  ; GFX10:   [[COPY3:%[0-9]+]]:vgpr(s32) = COPY [[COPY]](s32)
  ; GFX10:   [[COPY4:%[0-9]+]]:vgpr(s32) = COPY [[COPY1]](s32)
  ; GFX10:   [[FMA:%[0-9]+]]:vgpr(s32) = G_FMA [[COPY2]], [[COPY3]], [[COPY4]]
  ; GFX10:   $vgpr0 = COPY [[FMA]](s32)
  ; GFX10:   SI_RETURN_TO_EPILOG implicit $vgpr0
  %result = call float @llvm.fma.f32(float %src01, float %src01, float %src2)
  ret float %result
}

; src1/2 are same SGPR
define amdgpu_ps float @fma_s_ss(float inreg %src0, float inreg %src12) {
  ; GFX9-LABEL: name: fma_s_ss
  ; GFX9: bb.1 (%ir-block.0):
  ; GFX9:   liveins: $sgpr2, $sgpr3
  ; GFX9:   [[COPY:%[0-9]+]]:sgpr(s32) = COPY $sgpr2
  ; GFX9:   [[COPY1:%[0-9]+]]:sgpr(s32) = COPY $sgpr3
  ; GFX9:   [[COPY2:%[0-9]+]]:vgpr(s32) = COPY [[COPY]](s32)
  ; GFX9:   [[COPY3:%[0-9]+]]:vgpr(s32) = COPY [[COPY1]](s32)
  ; GFX9:   [[COPY4:%[0-9]+]]:vgpr(s32) = COPY [[COPY1]](s32)
  ; GFX9:   [[FMA:%[0-9]+]]:vgpr(s32) = G_FMA [[COPY2]], [[COPY3]], [[COPY4]]
  ; GFX9:   $vgpr0 = COPY [[FMA]](s32)
  ; GFX9:   SI_RETURN_TO_EPILOG implicit $vgpr0
  ; GFX10-LABEL: name: fma_s_ss
  ; GFX10: bb.1 (%ir-block.0):
  ; GFX10:   liveins: $sgpr2, $sgpr3
  ; GFX10:   [[COPY:%[0-9]+]]:sgpr(s32) = COPY $sgpr2
  ; GFX10:   [[COPY1:%[0-9]+]]:sgpr(s32) = COPY $sgpr3
  ; GFX10:   [[COPY2:%[0-9]+]]:vgpr(s32) = COPY [[COPY]](s32)
  ; GFX10:   [[COPY3:%[0-9]+]]:vgpr(s32) = COPY [[COPY1]](s32)
  ; GFX10:   [[COPY4:%[0-9]+]]:vgpr(s32) = COPY [[COPY1]](s32)
  ; GFX10:   [[FMA:%[0-9]+]]:vgpr(s32) = G_FMA [[COPY2]], [[COPY3]], [[COPY4]]
  ; GFX10:   $vgpr0 = COPY [[FMA]](s32)
  ; GFX10:   SI_RETURN_TO_EPILOG implicit $vgpr0
  %result = call float @llvm.fma.f32(float %src0, float %src12, float %src12)
  ret float %result
}

; src0/2 are same SGPR
define amdgpu_ps float @fma_ss_s_same_outer(float inreg %src02, float inreg %src1) {
  ; GFX9-LABEL: name: fma_ss_s_same_outer
  ; GFX9: bb.1 (%ir-block.0):
  ; GFX9:   liveins: $sgpr2, $sgpr3
  ; GFX9:   [[COPY:%[0-9]+]]:sgpr(s32) = COPY $sgpr2
  ; GFX9:   [[COPY1:%[0-9]+]]:sgpr(s32) = COPY $sgpr3
  ; GFX9:   [[COPY2:%[0-9]+]]:vgpr(s32) = COPY [[COPY]](s32)
  ; GFX9:   [[COPY3:%[0-9]+]]:vgpr(s32) = COPY [[COPY1]](s32)
  ; GFX9:   [[COPY4:%[0-9]+]]:vgpr(s32) = COPY [[COPY]](s32)
  ; GFX9:   [[FMA:%[0-9]+]]:vgpr(s32) = G_FMA [[COPY2]], [[COPY3]], [[COPY4]]
  ; GFX9:   $vgpr0 = COPY [[FMA]](s32)
  ; GFX9:   SI_RETURN_TO_EPILOG implicit $vgpr0
  ; GFX10-LABEL: name: fma_ss_s_same_outer
  ; GFX10: bb.1 (%ir-block.0):
  ; GFX10:   liveins: $sgpr2, $sgpr3
  ; GFX10:   [[COPY:%[0-9]+]]:sgpr(s32) = COPY $sgpr2
  ; GFX10:   [[COPY1:%[0-9]+]]:sgpr(s32) = COPY $sgpr3
  ; GFX10:   [[COPY2:%[0-9]+]]:vgpr(s32) = COPY [[COPY]](s32)
  ; GFX10:   [[COPY3:%[0-9]+]]:vgpr(s32) = COPY [[COPY1]](s32)
  ; GFX10:   [[COPY4:%[0-9]+]]:vgpr(s32) = COPY [[COPY]](s32)
  ; GFX10:   [[FMA:%[0-9]+]]:vgpr(s32) = G_FMA [[COPY2]], [[COPY3]], [[COPY4]]
  ; GFX10:   $vgpr0 = COPY [[FMA]](s32)
  ; GFX10:   SI_RETURN_TO_EPILOG implicit $vgpr0
  %result = call float @llvm.fma.f32(float %src02, float %src1, float %src02)
  ret float %result
}

define amdgpu_ps float @fcmp_s_s(float inreg %src0, float inreg %src1) {
  ; GFX9-LABEL: name: fcmp_s_s
  ; GFX9: bb.1 (%ir-block.0):
  ; GFX9:   liveins: $sgpr2, $sgpr3
  ; GFX9:   [[COPY:%[0-9]+]]:sgpr(s32) = COPY $sgpr2
  ; GFX9:   [[COPY1:%[0-9]+]]:sgpr(s32) = COPY $sgpr3
  ; GFX9:   [[C:%[0-9]+]]:sgpr(s32) = G_FCONSTANT float 1.000000e+00
  ; GFX9:   [[C1:%[0-9]+]]:sgpr(s32) = G_FCONSTANT float 0.000000e+00
  ; GFX9:   [[COPY2:%[0-9]+]]:vgpr(s32) = COPY [[COPY1]](s32)
  ; GFX9:   [[FCMP:%[0-9]+]]:vcc(s1) = G_FCMP floatpred(oeq), [[COPY]](s32), [[COPY2]]
  ; GFX9:   [[COPY3:%[0-9]+]]:vgpr(s32) = COPY [[C]](s32)
  ; GFX9:   [[COPY4:%[0-9]+]]:vgpr(s32) = COPY [[C1]](s32)
  ; GFX9:   [[SELECT:%[0-9]+]]:vgpr(s32) = G_SELECT [[FCMP]](s1), [[COPY3]], [[COPY4]]
  ; GFX9:   $vgpr0 = COPY [[SELECT]](s32)
  ; GFX9:   SI_RETURN_TO_EPILOG implicit $vgpr0
  ; GFX10-LABEL: name: fcmp_s_s
  ; GFX10: bb.1 (%ir-block.0):
  ; GFX10:   liveins: $sgpr2, $sgpr3
  ; GFX10:   [[COPY:%[0-9]+]]:sgpr(s32) = COPY $sgpr2
  ; GFX10:   [[COPY1:%[0-9]+]]:sgpr(s32) = COPY $sgpr3
  ; GFX10:   [[C:%[0-9]+]]:sgpr(s32) = G_FCONSTANT float 1.000000e+00
  ; GFX10:   [[C1:%[0-9]+]]:sgpr(s32) = G_FCONSTANT float 0.000000e+00
  ; GFX10:   [[COPY2:%[0-9]+]]:vgpr(s32) = COPY [[COPY1]](s32)
  ; GFX10:   [[FCMP:%[0-9]+]]:vcc(s1) = G_FCMP floatpred(oeq), [[COPY]](s32), [[COPY2]]
  ; GFX10:   [[COPY3:%[0-9]+]]:vgpr(s32) = COPY [[C]](s32)
  ; GFX10:   [[COPY4:%[0-9]+]]:vgpr(s32) = COPY [[C1]](s32)
  ; GFX10:   [[SELECT:%[0-9]+]]:vgpr(s32) = G_SELECT [[FCMP]](s1), [[COPY3]], [[COPY4]]
  ; GFX10:   $vgpr0 = COPY [[SELECT]](s32)
  ; GFX10:   SI_RETURN_TO_EPILOG implicit $vgpr0
  %cmp = fcmp oeq float %src0, %src1
  %result = select i1 %cmp, float 1.0, float 0.0
  ret float %result
}

; Constant bus used by vcc
define amdgpu_ps float @amdgcn_div_fmas_sss(float inreg %src, float %cmp.src) {
  ; GFX9-LABEL: name: amdgcn_div_fmas_sss
  ; GFX9: bb.1 (%ir-block.0):
  ; GFX9:   liveins: $sgpr2, $vgpr0
  ; GFX9:   [[COPY:%[0-9]+]]:sgpr(s32) = COPY $sgpr2
  ; GFX9:   [[COPY1:%[0-9]+]]:vgpr(s32) = COPY $vgpr0
  ; GFX9:   [[C:%[0-9]+]]:sgpr(s32) = G_FCONSTANT float 0.000000e+00
  ; GFX9:   [[COPY2:%[0-9]+]]:vgpr(s32) = COPY [[C]](s32)
  ; GFX9:   [[FCMP:%[0-9]+]]:vcc(s1) = G_FCMP floatpred(oeq), [[COPY1]](s32), [[COPY2]]
  ; GFX9:   [[COPY3:%[0-9]+]]:vgpr(s32) = COPY [[COPY]](s32)
  ; GFX9:   [[COPY4:%[0-9]+]]:vgpr(s32) = COPY [[COPY]](s32)
  ; GFX9:   [[COPY5:%[0-9]+]]:vgpr(s32) = COPY [[COPY]](s32)
  ; GFX9:   [[INT:%[0-9]+]]:vgpr(s32) = G_INTRINSIC intrinsic(@llvm.amdgcn.div.fmas), [[COPY3]](s32), [[COPY4]](s32), [[COPY5]](s32), [[FCMP]](s1)
  ; GFX9:   $vgpr0 = COPY [[INT]](s32)
  ; GFX9:   SI_RETURN_TO_EPILOG implicit $vgpr0
  ; GFX10-LABEL: name: amdgcn_div_fmas_sss
  ; GFX10: bb.1 (%ir-block.0):
  ; GFX10:   liveins: $sgpr2, $vgpr0
  ; GFX10:   [[COPY:%[0-9]+]]:sgpr(s32) = COPY $sgpr2
  ; GFX10:   [[COPY1:%[0-9]+]]:vgpr(s32) = COPY $vgpr0
  ; GFX10:   [[C:%[0-9]+]]:sgpr(s32) = G_FCONSTANT float 0.000000e+00
  ; GFX10:   [[COPY2:%[0-9]+]]:vgpr(s32) = COPY [[C]](s32)
  ; GFX10:   [[FCMP:%[0-9]+]]:vcc(s1) = G_FCMP floatpred(oeq), [[COPY1]](s32), [[COPY2]]
  ; GFX10:   [[COPY3:%[0-9]+]]:vgpr(s32) = COPY [[COPY]](s32)
  ; GFX10:   [[COPY4:%[0-9]+]]:vgpr(s32) = COPY [[COPY]](s32)
  ; GFX10:   [[COPY5:%[0-9]+]]:vgpr(s32) = COPY [[COPY]](s32)
  ; GFX10:   [[INT:%[0-9]+]]:vgpr(s32) = G_INTRINSIC intrinsic(@llvm.amdgcn.div.fmas), [[COPY3]](s32), [[COPY4]](s32), [[COPY5]](s32), [[FCMP]](s1)
  ; GFX10:   $vgpr0 = COPY [[INT]](s32)
  ; GFX10:   SI_RETURN_TO_EPILOG implicit $vgpr0
  %vcc = fcmp oeq float %cmp.src, 0.0
  %result = call float @llvm.amdgcn.div.fmas.f32(float %src, float %src, float %src, i1 %vcc)
  ret float %result
}

define amdgpu_ps float @class_s_s(float inreg %src0, i32 inreg %src1) {
  ; GFX9-LABEL: name: class_s_s
  ; GFX9: bb.1 (%ir-block.0):
  ; GFX9:   liveins: $sgpr2, $sgpr3
  ; GFX9:   [[COPY:%[0-9]+]]:sgpr(s32) = COPY $sgpr2
  ; GFX9:   [[COPY1:%[0-9]+]]:sgpr(s32) = COPY $sgpr3
  ; GFX9:   [[C:%[0-9]+]]:sgpr(s32) = G_FCONSTANT float 1.000000e+00
  ; GFX9:   [[C1:%[0-9]+]]:sgpr(s32) = G_FCONSTANT float 0.000000e+00
  ; GFX9:   [[COPY2:%[0-9]+]]:vgpr(s32) = COPY [[COPY]](s32)
  ; GFX9:   [[COPY3:%[0-9]+]]:vgpr(s32) = COPY [[COPY1]](s32)
  ; GFX9:   [[INT:%[0-9]+]]:vcc(s1) = G_INTRINSIC intrinsic(@llvm.amdgcn.class), [[COPY2]](s32), [[COPY3]](s32)
  ; GFX9:   [[COPY4:%[0-9]+]]:vgpr(s32) = COPY [[C]](s32)
  ; GFX9:   [[COPY5:%[0-9]+]]:vgpr(s32) = COPY [[C1]](s32)
  ; GFX9:   [[SELECT:%[0-9]+]]:vgpr(s32) = G_SELECT [[INT]](s1), [[COPY4]], [[COPY5]]
  ; GFX9:   $vgpr0 = COPY [[SELECT]](s32)
  ; GFX9:   SI_RETURN_TO_EPILOG implicit $vgpr0
  ; GFX10-LABEL: name: class_s_s
  ; GFX10: bb.1 (%ir-block.0):
  ; GFX10:   liveins: $sgpr2, $sgpr3
  ; GFX10:   [[COPY:%[0-9]+]]:sgpr(s32) = COPY $sgpr2
  ; GFX10:   [[COPY1:%[0-9]+]]:sgpr(s32) = COPY $sgpr3
  ; GFX10:   [[C:%[0-9]+]]:sgpr(s32) = G_FCONSTANT float 1.000000e+00
  ; GFX10:   [[C1:%[0-9]+]]:sgpr(s32) = G_FCONSTANT float 0.000000e+00
  ; GFX10:   [[COPY2:%[0-9]+]]:vgpr(s32) = COPY [[COPY]](s32)
  ; GFX10:   [[COPY3:%[0-9]+]]:vgpr(s32) = COPY [[COPY1]](s32)
  ; GFX10:   [[INT:%[0-9]+]]:vcc(s1) = G_INTRINSIC intrinsic(@llvm.amdgcn.class), [[COPY2]](s32), [[COPY3]](s32)
  ; GFX10:   [[COPY4:%[0-9]+]]:vgpr(s32) = COPY [[C]](s32)
  ; GFX10:   [[COPY5:%[0-9]+]]:vgpr(s32) = COPY [[C1]](s32)
  ; GFX10:   [[SELECT:%[0-9]+]]:vgpr(s32) = G_SELECT [[INT]](s1), [[COPY4]], [[COPY5]]
  ; GFX10:   $vgpr0 = COPY [[SELECT]](s32)
  ; GFX10:   SI_RETURN_TO_EPILOG implicit $vgpr0
  %class = call i1 @llvm.amdgcn.class.f32(float %src0, i32 %src1)
  %result = select i1 %class, float 1.0, float 0.0
  ret float %result
}

define amdgpu_ps float @div_scale_s_s_true(float inreg %src0, float inreg %src1) {
  ; GFX9-LABEL: name: div_scale_s_s_true
  ; GFX9: bb.1 (%ir-block.0):
  ; GFX9:   liveins: $sgpr2, $sgpr3
  ; GFX9:   [[COPY:%[0-9]+]]:sgpr(s32) = COPY $sgpr2
  ; GFX9:   [[COPY1:%[0-9]+]]:sgpr(s32) = COPY $sgpr3
  ; GFX9:   [[COPY2:%[0-9]+]]:vgpr(s32) = COPY [[COPY]](s32)
  ; GFX9:   [[COPY3:%[0-9]+]]:vgpr(s32) = COPY [[COPY1]](s32)
  ; GFX9:   [[INT:%[0-9]+]]:vgpr(s32), [[INT1:%[0-9]+]]:vcc(s1) = G_INTRINSIC intrinsic(@llvm.amdgcn.div.scale), [[COPY2]](s32), [[COPY3]](s32), -1
  ; GFX9:   $vgpr0 = COPY [[INT]](s32)
  ; GFX9:   SI_RETURN_TO_EPILOG implicit $vgpr0
  ; GFX10-LABEL: name: div_scale_s_s_true
  ; GFX10: bb.1 (%ir-block.0):
  ; GFX10:   liveins: $sgpr2, $sgpr3
  ; GFX10:   [[COPY:%[0-9]+]]:sgpr(s32) = COPY $sgpr2
  ; GFX10:   [[COPY1:%[0-9]+]]:sgpr(s32) = COPY $sgpr3
  ; GFX10:   [[COPY2:%[0-9]+]]:vgpr(s32) = COPY [[COPY]](s32)
  ; GFX10:   [[COPY3:%[0-9]+]]:vgpr(s32) = COPY [[COPY1]](s32)
  ; GFX10:   [[INT:%[0-9]+]]:vgpr(s32), [[INT1:%[0-9]+]]:vcc(s1) = G_INTRINSIC intrinsic(@llvm.amdgcn.div.scale), [[COPY2]](s32), [[COPY3]](s32), -1
  ; GFX10:   $vgpr0 = COPY [[INT]](s32)
  ; GFX10:   SI_RETURN_TO_EPILOG implicit $vgpr0
  %div.scale = call { float, i1 } @llvm.amdgcn.div.scale.f32(float %src0, float %src1, i1 true)
  %result = extractvalue { float, i1 } %div.scale, 0
  ret float %result
}

define amdgpu_ps float @div_scale_s_s_false(float inreg %src0, float inreg %src1) {
  ; GFX9-LABEL: name: div_scale_s_s_false
  ; GFX9: bb.1 (%ir-block.0):
  ; GFX9:   liveins: $sgpr2, $sgpr3
  ; GFX9:   [[COPY:%[0-9]+]]:sgpr(s32) = COPY $sgpr2
  ; GFX9:   [[COPY1:%[0-9]+]]:sgpr(s32) = COPY $sgpr3
  ; GFX9:   [[COPY2:%[0-9]+]]:vgpr(s32) = COPY [[COPY]](s32)
  ; GFX9:   [[COPY3:%[0-9]+]]:vgpr(s32) = COPY [[COPY1]](s32)
  ; GFX9:   [[INT:%[0-9]+]]:vgpr(s32), [[INT1:%[0-9]+]]:vcc(s1) = G_INTRINSIC intrinsic(@llvm.amdgcn.div.scale), [[COPY2]](s32), [[COPY3]](s32), 0
  ; GFX9:   $vgpr0 = COPY [[INT]](s32)
  ; GFX9:   SI_RETURN_TO_EPILOG implicit $vgpr0
  ; GFX10-LABEL: name: div_scale_s_s_false
  ; GFX10: bb.1 (%ir-block.0):
  ; GFX10:   liveins: $sgpr2, $sgpr3
  ; GFX10:   [[COPY:%[0-9]+]]:sgpr(s32) = COPY $sgpr2
  ; GFX10:   [[COPY1:%[0-9]+]]:sgpr(s32) = COPY $sgpr3
  ; GFX10:   [[COPY2:%[0-9]+]]:vgpr(s32) = COPY [[COPY]](s32)
  ; GFX10:   [[COPY3:%[0-9]+]]:vgpr(s32) = COPY [[COPY1]](s32)
  ; GFX10:   [[INT:%[0-9]+]]:vgpr(s32), [[INT1:%[0-9]+]]:vcc(s1) = G_INTRINSIC intrinsic(@llvm.amdgcn.div.scale), [[COPY2]](s32), [[COPY3]](s32), 0
  ; GFX10:   $vgpr0 = COPY [[INT]](s32)
  ; GFX10:   SI_RETURN_TO_EPILOG implicit $vgpr0
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
