; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -march=amdgcn -mcpu=tahiti < %s | FileCheck -allow-deprecated-dag-overlap -check-prefix=GCN -check-prefix=SI -check-prefix=FUNC %s
; RUN: llc -march=amdgcn -mcpu=tonga -mattr=-flat-for-global -amdgpu-sdwa-peephole=0 < %s | FileCheck -allow-deprecated-dag-overlap -check-prefix=GCN -check-prefix=VI -check-prefix=FUNC %s

declare i32 @llvm.amdgcn.workitem.id.x() nounwind readnone
declare i32 @llvm.amdgcn.workitem.id.y() nounwind readnone

define amdgpu_kernel void @test_copy_v4i8(<4 x i8> addrspace(1)* %out, <4 x i8> addrspace(1)* %in) nounwind {
; SI-LABEL: test_copy_v4i8:
; SI:       ; %bb.0:
; SI-NEXT:    s_load_dwordx4 s[4:7], s[0:1], 0x9
; SI-NEXT:    s_mov_b32 s3, 0xf000
; SI-NEXT:    s_mov_b32 s10, 0
; SI-NEXT:    s_mov_b32 s11, s3
; SI-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; SI-NEXT:    s_waitcnt lgkmcnt(0)
; SI-NEXT:    s_mov_b64 s[8:9], s[6:7]
; SI-NEXT:    v_mov_b32_e32 v1, 0
; SI-NEXT:    buffer_load_dword v0, v[0:1], s[8:11], 0 addr64
; SI-NEXT:    s_mov_b32 s2, -1
; SI-NEXT:    s_mov_b32 s0, s4
; SI-NEXT:    s_mov_b32 s1, s5
; SI-NEXT:    s_waitcnt vmcnt(0)
; SI-NEXT:    buffer_store_dword v0, off, s[0:3], 0
; SI-NEXT:    s_endpgm
;
; VI-LABEL: test_copy_v4i8:
; VI:       ; %bb.0:
; VI-NEXT:    s_load_dwordx4 s[4:7], s[0:1], 0x24
; VI-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; VI-NEXT:    s_mov_b32 s3, 0xf000
; VI-NEXT:    s_mov_b32 s2, -1
; VI-NEXT:    s_waitcnt lgkmcnt(0)
; VI-NEXT:    v_mov_b32_e32 v1, s7
; VI-NEXT:    v_add_u32_e32 v0, vcc, s6, v0
; VI-NEXT:    v_addc_u32_e32 v1, vcc, 0, v1, vcc
; VI-NEXT:    flat_load_dword v0, v[0:1]
; VI-NEXT:    s_mov_b32 s0, s4
; VI-NEXT:    s_mov_b32 s1, s5
; VI-NEXT:    s_waitcnt vmcnt(0)
; VI-NEXT:    buffer_store_dword v0, off, s[0:3], 0
; VI-NEXT:    s_endpgm
  %tid.x = call i32 @llvm.amdgcn.workitem.id.x()
  %gep = getelementptr <4 x i8>, <4 x i8> addrspace(1)* %in, i32 %tid.x
  %val = load <4 x i8>, <4 x i8> addrspace(1)* %gep, align 4
  store <4 x i8> %val, <4 x i8> addrspace(1)* %out, align 4
  ret void
}

define amdgpu_kernel void @test_copy_v4i8_x2(<4 x i8> addrspace(1)* %out0, <4 x i8> addrspace(1)* %out1, <4 x i8> addrspace(1)* %in) nounwind {
; SI-LABEL: test_copy_v4i8_x2:
; SI:       ; %bb.0:
; SI-NEXT:    s_load_dwordx4 s[4:7], s[0:1], 0x9
; SI-NEXT:    s_load_dwordx2 s[0:1], s[0:1], 0xd
; SI-NEXT:    s_mov_b32 s11, 0xf000
; SI-NEXT:    s_mov_b32 s2, 0
; SI-NEXT:    s_mov_b32 s3, s11
; SI-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; SI-NEXT:    v_mov_b32_e32 v1, 0
; SI-NEXT:    s_waitcnt lgkmcnt(0)
; SI-NEXT:    buffer_load_dword v0, v[0:1], s[0:3], 0 addr64
; SI-NEXT:    s_mov_b32 s10, -1
; SI-NEXT:    s_mov_b32 s8, s4
; SI-NEXT:    s_mov_b32 s9, s5
; SI-NEXT:    s_mov_b32 s2, s10
; SI-NEXT:    s_mov_b32 s0, s6
; SI-NEXT:    s_mov_b32 s1, s7
; SI-NEXT:    s_waitcnt vmcnt(0)
; SI-NEXT:    buffer_store_dword v0, off, s[8:11], 0
; SI-NEXT:    buffer_store_dword v0, off, s[0:3], 0
; SI-NEXT:    s_endpgm
;
; VI-LABEL: test_copy_v4i8_x2:
; VI:       ; %bb.0:
; VI-NEXT:    s_load_dwordx4 s[4:7], s[0:1], 0x24
; VI-NEXT:    s_load_dwordx2 s[0:1], s[0:1], 0x34
; VI-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; VI-NEXT:    s_mov_b32 s3, 0xf000
; VI-NEXT:    s_mov_b32 s2, -1
; VI-NEXT:    s_mov_b32 s10, s2
; VI-NEXT:    s_waitcnt lgkmcnt(0)
; VI-NEXT:    v_mov_b32_e32 v1, s1
; VI-NEXT:    v_add_u32_e32 v0, vcc, s0, v0
; VI-NEXT:    v_addc_u32_e32 v1, vcc, 0, v1, vcc
; VI-NEXT:    flat_load_dword v0, v[0:1]
; VI-NEXT:    s_mov_b32 s0, s4
; VI-NEXT:    s_mov_b32 s1, s5
; VI-NEXT:    s_mov_b32 s11, s3
; VI-NEXT:    s_mov_b32 s8, s6
; VI-NEXT:    s_mov_b32 s9, s7
; VI-NEXT:    s_waitcnt vmcnt(0)
; VI-NEXT:    buffer_store_dword v0, off, s[0:3], 0
; VI-NEXT:    buffer_store_dword v0, off, s[8:11], 0
; VI-NEXT:    s_endpgm
  %tid.x = call i32 @llvm.amdgcn.workitem.id.x()
  %gep = getelementptr <4 x i8>, <4 x i8> addrspace(1)* %in, i32 %tid.x
  %val = load <4 x i8>, <4 x i8> addrspace(1)* %gep, align 4
  store <4 x i8> %val, <4 x i8> addrspace(1)* %out0, align 4
  store <4 x i8> %val, <4 x i8> addrspace(1)* %out1, align 4
  ret void
}

define amdgpu_kernel void @test_copy_v4i8_x3(<4 x i8> addrspace(1)* %out0, <4 x i8> addrspace(1)* %out1, <4 x i8> addrspace(1)* %out2, <4 x i8> addrspace(1)* %in) nounwind {
; SI-LABEL: test_copy_v4i8_x3:
; SI:       ; %bb.0:
; SI-NEXT:    s_load_dwordx8 s[0:7], s[0:1], 0x9
; SI-NEXT:    s_mov_b32 s11, 0xf000
; SI-NEXT:    s_mov_b32 s14, 0
; SI-NEXT:    s_mov_b32 s15, s11
; SI-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; SI-NEXT:    s_waitcnt lgkmcnt(0)
; SI-NEXT:    s_mov_b64 s[12:13], s[6:7]
; SI-NEXT:    v_mov_b32_e32 v1, 0
; SI-NEXT:    buffer_load_dword v0, v[0:1], s[12:15], 0 addr64
; SI-NEXT:    s_mov_b32 s10, -1
; SI-NEXT:    s_mov_b32 s8, s0
; SI-NEXT:    s_mov_b32 s9, s1
; SI-NEXT:    s_mov_b32 s14, s10
; SI-NEXT:    s_mov_b32 s6, s10
; SI-NEXT:    s_mov_b32 s7, s11
; SI-NEXT:    s_mov_b32 s12, s2
; SI-NEXT:    s_mov_b32 s13, s3
; SI-NEXT:    s_waitcnt vmcnt(0)
; SI-NEXT:    buffer_store_dword v0, off, s[8:11], 0
; SI-NEXT:    buffer_store_dword v0, off, s[12:15], 0
; SI-NEXT:    buffer_store_dword v0, off, s[4:7], 0
; SI-NEXT:    s_endpgm
;
; VI-LABEL: test_copy_v4i8_x3:
; VI:       ; %bb.0:
; VI-NEXT:    s_load_dwordx8 s[0:7], s[0:1], 0x24
; VI-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; VI-NEXT:    s_mov_b32 s11, 0xf000
; VI-NEXT:    s_mov_b32 s10, -1
; VI-NEXT:    s_mov_b32 s14, s10
; VI-NEXT:    s_waitcnt lgkmcnt(0)
; VI-NEXT:    v_mov_b32_e32 v1, s7
; VI-NEXT:    v_add_u32_e32 v0, vcc, s6, v0
; VI-NEXT:    v_addc_u32_e32 v1, vcc, 0, v1, vcc
; VI-NEXT:    flat_load_dword v0, v[0:1]
; VI-NEXT:    s_mov_b32 s8, s0
; VI-NEXT:    s_mov_b32 s9, s1
; VI-NEXT:    s_mov_b32 s15, s11
; VI-NEXT:    s_mov_b32 s6, s10
; VI-NEXT:    s_mov_b32 s7, s11
; VI-NEXT:    s_mov_b32 s12, s2
; VI-NEXT:    s_mov_b32 s13, s3
; VI-NEXT:    s_waitcnt vmcnt(0)
; VI-NEXT:    buffer_store_dword v0, off, s[8:11], 0
; VI-NEXT:    buffer_store_dword v0, off, s[12:15], 0
; VI-NEXT:    buffer_store_dword v0, off, s[4:7], 0
; VI-NEXT:    s_endpgm
  %tid.x = call i32 @llvm.amdgcn.workitem.id.x()
  %gep = getelementptr <4 x i8>, <4 x i8> addrspace(1)* %in, i32 %tid.x
  %val = load <4 x i8>, <4 x i8> addrspace(1)* %gep, align 4
  store <4 x i8> %val, <4 x i8> addrspace(1)* %out0, align 4
  store <4 x i8> %val, <4 x i8> addrspace(1)* %out1, align 4
  store <4 x i8> %val, <4 x i8> addrspace(1)* %out2, align 4
  ret void
}

define amdgpu_kernel void @test_copy_v4i8_x4(<4 x i8> addrspace(1)* %out0, <4 x i8> addrspace(1)* %out1, <4 x i8> addrspace(1)* %out2, <4 x i8> addrspace(1)* %out3, <4 x i8> addrspace(1)* %in) nounwind {
; SI-LABEL: test_copy_v4i8_x4:
; SI:       ; %bb.0:
; SI-NEXT:    s_load_dwordx2 s[4:5], s[0:1], 0x11
; SI-NEXT:    s_mov_b32 s11, 0xf000
; SI-NEXT:    s_mov_b32 s6, 0
; SI-NEXT:    s_mov_b32 s7, s11
; SI-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; SI-NEXT:    v_mov_b32_e32 v1, 0
; SI-NEXT:    s_waitcnt lgkmcnt(0)
; SI-NEXT:    buffer_load_dword v0, v[0:1], s[4:7], 0 addr64
; SI-NEXT:    s_load_dwordx8 s[0:7], s[0:1], 0x9
; SI-NEXT:    s_mov_b32 s10, -1
; SI-NEXT:    s_mov_b32 s14, s10
; SI-NEXT:    s_mov_b32 s15, s11
; SI-NEXT:    s_mov_b32 s18, s10
; SI-NEXT:    s_waitcnt lgkmcnt(0)
; SI-NEXT:    s_mov_b32 s8, s0
; SI-NEXT:    s_mov_b32 s9, s1
; SI-NEXT:    s_mov_b32 s19, s11
; SI-NEXT:    s_mov_b32 s22, s10
; SI-NEXT:    s_mov_b32 s23, s11
; SI-NEXT:    s_mov_b32 s12, s2
; SI-NEXT:    s_mov_b32 s13, s3
; SI-NEXT:    s_mov_b32 s16, s4
; SI-NEXT:    s_mov_b32 s17, s5
; SI-NEXT:    s_mov_b32 s20, s6
; SI-NEXT:    s_mov_b32 s21, s7
; SI-NEXT:    s_waitcnt vmcnt(0)
; SI-NEXT:    buffer_store_dword v0, off, s[8:11], 0
; SI-NEXT:    buffer_store_dword v0, off, s[12:15], 0
; SI-NEXT:    buffer_store_dword v0, off, s[16:19], 0
; SI-NEXT:    buffer_store_dword v0, off, s[20:23], 0
; SI-NEXT:    s_endpgm
;
; VI-LABEL: test_copy_v4i8_x4:
; VI:       ; %bb.0:
; VI-NEXT:    s_load_dwordx2 s[2:3], s[0:1], 0x44
; VI-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; VI-NEXT:    s_mov_b32 s11, 0xf000
; VI-NEXT:    s_mov_b32 s10, -1
; VI-NEXT:    s_mov_b32 s14, s10
; VI-NEXT:    s_waitcnt lgkmcnt(0)
; VI-NEXT:    v_mov_b32_e32 v1, s3
; VI-NEXT:    v_add_u32_e32 v0, vcc, s2, v0
; VI-NEXT:    v_addc_u32_e32 v1, vcc, 0, v1, vcc
; VI-NEXT:    flat_load_dword v0, v[0:1]
; VI-NEXT:    s_load_dwordx8 s[0:7], s[0:1], 0x24
; VI-NEXT:    s_mov_b32 s15, s11
; VI-NEXT:    s_mov_b32 s18, s10
; VI-NEXT:    s_mov_b32 s19, s11
; VI-NEXT:    s_mov_b32 s22, s10
; VI-NEXT:    s_waitcnt lgkmcnt(0)
; VI-NEXT:    s_mov_b32 s8, s0
; VI-NEXT:    s_mov_b32 s9, s1
; VI-NEXT:    s_mov_b32 s23, s11
; VI-NEXT:    s_mov_b32 s12, s2
; VI-NEXT:    s_mov_b32 s13, s3
; VI-NEXT:    s_mov_b32 s16, s4
; VI-NEXT:    s_mov_b32 s17, s5
; VI-NEXT:    s_mov_b32 s20, s6
; VI-NEXT:    s_mov_b32 s21, s7
; VI-NEXT:    s_waitcnt vmcnt(0)
; VI-NEXT:    buffer_store_dword v0, off, s[8:11], 0
; VI-NEXT:    buffer_store_dword v0, off, s[12:15], 0
; VI-NEXT:    buffer_store_dword v0, off, s[16:19], 0
; VI-NEXT:    buffer_store_dword v0, off, s[20:23], 0
; VI-NEXT:    s_endpgm
  %tid.x = call i32 @llvm.amdgcn.workitem.id.x()
  %gep = getelementptr <4 x i8>, <4 x i8> addrspace(1)* %in, i32 %tid.x
  %val = load <4 x i8>, <4 x i8> addrspace(1)* %gep, align 4
  store <4 x i8> %val, <4 x i8> addrspace(1)* %out0, align 4
  store <4 x i8> %val, <4 x i8> addrspace(1)* %out1, align 4
  store <4 x i8> %val, <4 x i8> addrspace(1)* %out2, align 4
  store <4 x i8> %val, <4 x i8> addrspace(1)* %out3, align 4
  ret void
}

define amdgpu_kernel void @test_copy_v4i8_extra_use(<4 x i8> addrspace(1)* %out0, <4 x i8> addrspace(1)* %out1, <4 x i8> addrspace(1)* %in) nounwind {
; SI-LABEL: test_copy_v4i8_extra_use:
; SI:       ; %bb.0:
; SI-NEXT:    s_load_dwordx4 s[4:7], s[0:1], 0x9
; SI-NEXT:    s_load_dwordx2 s[0:1], s[0:1], 0xd
; SI-NEXT:    s_mov_b32 s11, 0xf000
; SI-NEXT:    s_mov_b32 s2, 0
; SI-NEXT:    s_mov_b32 s3, s11
; SI-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; SI-NEXT:    v_mov_b32_e32 v1, 0
; SI-NEXT:    s_waitcnt lgkmcnt(0)
; SI-NEXT:    buffer_load_dword v0, v[0:1], s[0:3], 0 addr64
; SI-NEXT:    s_mov_b32 s12, 0xff00
; SI-NEXT:    s_movk_i32 s13, 0xff
; SI-NEXT:    s_mov_b32 s10, -1
; SI-NEXT:    s_mov_b32 s8, s4
; SI-NEXT:    s_mov_b32 s9, s5
; SI-NEXT:    s_mov_b32 s2, s10
; SI-NEXT:    s_mov_b32 s0, s6
; SI-NEXT:    s_mov_b32 s1, s7
; SI-NEXT:    s_waitcnt vmcnt(0)
; SI-NEXT:    v_add_i32_e32 v3, vcc, 9, v0
; SI-NEXT:    v_lshrrev_b32_e32 v1, 16, v0
; SI-NEXT:    v_and_b32_e32 v4, s12, v1
; SI-NEXT:    v_add_i32_e32 v1, vcc, 9, v1
; SI-NEXT:    v_and_b32_e32 v2, s12, v0
; SI-NEXT:    v_and_b32_e32 v3, s13, v3
; SI-NEXT:    v_or_b32_e32 v2, v2, v3
; SI-NEXT:    v_and_b32_e32 v1, s13, v1
; SI-NEXT:    v_add_i32_e32 v2, vcc, 0x900, v2
; SI-NEXT:    v_or_b32_e32 v1, v4, v1
; SI-NEXT:    v_and_b32_e32 v2, 0xffff, v2
; SI-NEXT:    v_lshlrev_b32_e32 v1, 16, v1
; SI-NEXT:    v_or_b32_e32 v1, v1, v2
; SI-NEXT:    v_add_i32_e32 v1, vcc, 0x9000000, v1
; SI-NEXT:    buffer_store_dword v0, off, s[8:11], 0
; SI-NEXT:    buffer_store_dword v1, off, s[0:3], 0
; SI-NEXT:    s_endpgm
;
; VI-LABEL: test_copy_v4i8_extra_use:
; VI:       ; %bb.0:
; VI-NEXT:    s_load_dwordx4 s[4:7], s[0:1], 0x24
; VI-NEXT:    s_load_dwordx2 s[0:1], s[0:1], 0x34
; VI-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; VI-NEXT:    s_movk_i32 s12, 0xff00
; VI-NEXT:    s_movk_i32 s13, 0xff
; VI-NEXT:    s_movk_i32 s14, 0x900
; VI-NEXT:    s_waitcnt lgkmcnt(0)
; VI-NEXT:    v_mov_b32_e32 v1, s1
; VI-NEXT:    v_add_u32_e32 v0, vcc, s0, v0
; VI-NEXT:    v_addc_u32_e32 v1, vcc, 0, v1, vcc
; VI-NEXT:    flat_load_dword v0, v[0:1]
; VI-NEXT:    s_mov_b32 s3, 0xf000
; VI-NEXT:    s_mov_b32 s2, -1
; VI-NEXT:    s_mov_b32 s0, s4
; VI-NEXT:    s_mov_b32 s1, s5
; VI-NEXT:    s_mov_b32 s10, s2
; VI-NEXT:    s_mov_b32 s11, s3
; VI-NEXT:    s_mov_b32 s8, s6
; VI-NEXT:    s_mov_b32 s9, s7
; VI-NEXT:    s_waitcnt vmcnt(0)
; VI-NEXT:    v_lshrrev_b32_e32 v1, 16, v0
; VI-NEXT:    v_and_b32_e32 v4, s12, v1
; VI-NEXT:    v_add_u16_e32 v1, 9, v1
; VI-NEXT:    v_add_u16_e32 v3, 9, v0
; VI-NEXT:    v_and_b32_e32 v1, s13, v1
; VI-NEXT:    v_or_b32_e32 v1, v4, v1
; VI-NEXT:    v_and_b32_e32 v2, s12, v0
; VI-NEXT:    v_and_b32_e32 v3, s13, v3
; VI-NEXT:    v_or_b32_e32 v2, v2, v3
; VI-NEXT:    v_add_u16_e32 v1, s14, v1
; VI-NEXT:    v_add_u16_e32 v2, s14, v2
; VI-NEXT:    v_lshlrev_b32_e32 v1, 16, v1
; VI-NEXT:    v_or_b32_e32 v1, v2, v1
; VI-NEXT:    buffer_store_dword v0, off, s[0:3], 0
; VI-NEXT:    buffer_store_dword v1, off, s[8:11], 0
; VI-NEXT:    s_endpgm
  %tid.x = call i32 @llvm.amdgcn.workitem.id.x()
  %gep = getelementptr <4 x i8>, <4 x i8> addrspace(1)* %in, i32 %tid.x
  %val = load <4 x i8>, <4 x i8> addrspace(1)* %gep, align 4
  %add = add <4 x i8> %val, <i8 9, i8 9, i8 9, i8 9>
  store <4 x i8> %val, <4 x i8> addrspace(1)* %out0, align 4
  store <4 x i8> %add, <4 x i8> addrspace(1)* %out1, align 4
  ret void
}

; FIXME: Need to handle non-uniform case for function below (load without gep).
define amdgpu_kernel void @test_copy_v4i8_x2_extra_use(<4 x i8> addrspace(1)* %out0, <4 x i8> addrspace(1)* %out1, <4 x i8> addrspace(1)* %out2, <4 x i8> addrspace(1)* %in) nounwind {
; SI-LABEL: test_copy_v4i8_x2_extra_use:
; SI:       ; %bb.0:
; SI-NEXT:    s_load_dwordx8 s[0:7], s[0:1], 0x9
; SI-NEXT:    s_mov_b32 s11, 0xf000
; SI-NEXT:    s_mov_b32 s14, 0
; SI-NEXT:    s_mov_b32 s15, s11
; SI-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; SI-NEXT:    s_waitcnt lgkmcnt(0)
; SI-NEXT:    s_mov_b64 s[12:13], s[6:7]
; SI-NEXT:    v_mov_b32_e32 v1, 0
; SI-NEXT:    buffer_load_dword v0, v[0:1], s[12:15], 0 addr64
; SI-NEXT:    s_mov_b32 s16, 0xff00
; SI-NEXT:    s_movk_i32 s17, 0xff
; SI-NEXT:    s_mov_b32 s10, -1
; SI-NEXT:    s_mov_b32 s14, s10
; SI-NEXT:    s_mov_b32 s8, s0
; SI-NEXT:    s_mov_b32 s9, s1
; SI-NEXT:    s_mov_b32 s12, s2
; SI-NEXT:    s_mov_b32 s13, s3
; SI-NEXT:    s_mov_b32 s6, s10
; SI-NEXT:    s_mov_b32 s7, s11
; SI-NEXT:    s_waitcnt vmcnt(0)
; SI-NEXT:    v_add_i32_e32 v3, vcc, 9, v0
; SI-NEXT:    v_lshrrev_b32_e32 v1, 16, v0
; SI-NEXT:    v_and_b32_e32 v4, s16, v1
; SI-NEXT:    v_add_i32_e32 v1, vcc, 9, v1
; SI-NEXT:    v_and_b32_e32 v2, s16, v0
; SI-NEXT:    v_and_b32_e32 v3, s17, v3
; SI-NEXT:    v_or_b32_e32 v2, v2, v3
; SI-NEXT:    v_and_b32_e32 v1, s17, v1
; SI-NEXT:    v_add_i32_e32 v2, vcc, 0x900, v2
; SI-NEXT:    v_or_b32_e32 v1, v4, v1
; SI-NEXT:    v_and_b32_e32 v2, 0xffff, v2
; SI-NEXT:    v_lshlrev_b32_e32 v1, 16, v1
; SI-NEXT:    v_or_b32_e32 v1, v1, v2
; SI-NEXT:    v_add_i32_e32 v1, vcc, 0x9000000, v1
; SI-NEXT:    buffer_store_dword v0, off, s[8:11], 0
; SI-NEXT:    buffer_store_dword v1, off, s[12:15], 0
; SI-NEXT:    buffer_store_dword v0, off, s[4:7], 0
; SI-NEXT:    s_endpgm
;
; VI-LABEL: test_copy_v4i8_x2_extra_use:
; VI:       ; %bb.0:
; VI-NEXT:    s_load_dwordx8 s[0:7], s[0:1], 0x24
; VI-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; VI-NEXT:    s_movk_i32 s16, 0xff00
; VI-NEXT:    s_movk_i32 s17, 0xff
; VI-NEXT:    s_movk_i32 s18, 0x900
; VI-NEXT:    s_waitcnt lgkmcnt(0)
; VI-NEXT:    v_mov_b32_e32 v1, s7
; VI-NEXT:    v_add_u32_e32 v0, vcc, s6, v0
; VI-NEXT:    v_addc_u32_e32 v1, vcc, 0, v1, vcc
; VI-NEXT:    flat_load_dword v0, v[0:1]
; VI-NEXT:    s_mov_b32 s11, 0xf000
; VI-NEXT:    s_mov_b32 s10, -1
; VI-NEXT:    s_mov_b32 s14, s10
; VI-NEXT:    s_mov_b32 s15, s11
; VI-NEXT:    s_mov_b32 s8, s0
; VI-NEXT:    s_mov_b32 s9, s1
; VI-NEXT:    s_mov_b32 s12, s2
; VI-NEXT:    s_mov_b32 s13, s3
; VI-NEXT:    s_mov_b32 s6, s10
; VI-NEXT:    s_mov_b32 s7, s11
; VI-NEXT:    s_waitcnt vmcnt(0)
; VI-NEXT:    v_lshrrev_b32_e32 v1, 16, v0
; VI-NEXT:    v_and_b32_e32 v4, s16, v1
; VI-NEXT:    v_add_u16_e32 v1, 9, v1
; VI-NEXT:    v_add_u16_e32 v3, 9, v0
; VI-NEXT:    v_and_b32_e32 v1, s17, v1
; VI-NEXT:    v_or_b32_e32 v1, v4, v1
; VI-NEXT:    v_and_b32_e32 v2, s16, v0
; VI-NEXT:    v_and_b32_e32 v3, s17, v3
; VI-NEXT:    v_or_b32_e32 v2, v2, v3
; VI-NEXT:    v_add_u16_e32 v1, s18, v1
; VI-NEXT:    v_add_u16_e32 v2, s18, v2
; VI-NEXT:    v_lshlrev_b32_e32 v1, 16, v1
; VI-NEXT:    v_or_b32_e32 v1, v2, v1
; VI-NEXT:    buffer_store_dword v0, off, s[8:11], 0
; VI-NEXT:    buffer_store_dword v1, off, s[12:15], 0
; VI-NEXT:    buffer_store_dword v0, off, s[4:7], 0
; VI-NEXT:    s_endpgm
  %tid.x = call i32 @llvm.amdgcn.workitem.id.x()
  %in.ptr = getelementptr <4 x i8>, <4 x i8> addrspace(1)* %in, i32 %tid.x
  %val = load <4 x i8>, <4 x i8> addrspace(1)* %in.ptr, align 4
  %add = add <4 x i8> %val, <i8 9, i8 9, i8 9, i8 9>
  store <4 x i8> %val, <4 x i8> addrspace(1)* %out0, align 4
  store <4 x i8> %add, <4 x i8> addrspace(1)* %out1, align 4
  store <4 x i8> %val, <4 x i8> addrspace(1)* %out2, align 4
  ret void
}

define amdgpu_kernel void @test_copy_v3i8_align4(<3 x i8> addrspace(1)* %out, <3 x i8> addrspace(1)* %in) nounwind {
; SI-LABEL: test_copy_v3i8_align4:
; SI:       ; %bb.0:
; SI-NEXT:    s_load_dwordx4 s[8:11], s[0:1], 0x9
; SI-NEXT:    s_mov_b32 s3, 0xf000
; SI-NEXT:    s_mov_b32 s6, 0
; SI-NEXT:    s_mov_b32 s7, s3
; SI-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; SI-NEXT:    s_waitcnt lgkmcnt(0)
; SI-NEXT:    s_mov_b64 s[4:5], s[10:11]
; SI-NEXT:    v_mov_b32_e32 v1, 0
; SI-NEXT:    buffer_load_dword v0, v[0:1], s[4:7], 0 addr64
; SI-NEXT:    s_mov_b32 s2, -1
; SI-NEXT:    s_mov_b32 s0, s8
; SI-NEXT:    s_mov_b32 s1, s9
; SI-NEXT:    s_waitcnt vmcnt(0)
; SI-NEXT:    v_lshrrev_b32_e32 v1, 16, v0
; SI-NEXT:    buffer_store_short v0, off, s[0:3], 0
; SI-NEXT:    buffer_store_byte v1, off, s[0:3], 0 offset:2
; SI-NEXT:    s_endpgm
;
; VI-LABEL: test_copy_v3i8_align4:
; VI:       ; %bb.0:
; VI-NEXT:    s_load_dwordx4 s[0:3], s[0:1], 0x24
; VI-NEXT:    v_lshlrev_b32_e32 v0, 2, v0
; VI-NEXT:    s_waitcnt lgkmcnt(0)
; VI-NEXT:    v_mov_b32_e32 v1, s3
; VI-NEXT:    v_add_u32_e32 v0, vcc, s2, v0
; VI-NEXT:    v_addc_u32_e32 v1, vcc, 0, v1, vcc
; VI-NEXT:    flat_load_dword v0, v[0:1]
; VI-NEXT:    s_mov_b32 s3, 0xf000
; VI-NEXT:    s_mov_b32 s2, -1
; VI-NEXT:    s_waitcnt vmcnt(0)
; VI-NEXT:    v_lshrrev_b32_e32 v1, 16, v0
; VI-NEXT:    buffer_store_short v0, off, s[0:3], 0
; VI-NEXT:    buffer_store_byte v1, off, s[0:3], 0 offset:2
; VI-NEXT:    s_endpgm
  %tid.x = call i32 @llvm.amdgcn.workitem.id.x()
  %gep = getelementptr <3 x i8>, <3 x i8> addrspace(1)* %in, i32 %tid.x
  %val = load <3 x i8>, <3 x i8> addrspace(1)* %gep, align 4
  store <3 x i8> %val, <3 x i8> addrspace(1)* %out, align 4
  ret void
}

define amdgpu_kernel void @test_copy_v3i8_align2(<3 x i8> addrspace(1)* %out, <3 x i8> addrspace(1)* %in) nounwind {
; SI-LABEL: test_copy_v3i8_align2:
; SI:       ; %bb.0:
; SI-NEXT:    s_load_dwordx4 s[4:7], s[0:1], 0x9
; SI-NEXT:    s_mov_b32 s3, 0xf000
; SI-NEXT:    s_mov_b32 s2, -1
; SI-NEXT:    s_mov_b32 s10, s2
; SI-NEXT:    s_mov_b32 s11, s3
; SI-NEXT:    s_waitcnt lgkmcnt(0)
; SI-NEXT:    s_mov_b32 s8, s6
; SI-NEXT:    s_mov_b32 s9, s7
; SI-NEXT:    buffer_load_ushort v0, off, s[8:11], 0
; SI-NEXT:    buffer_load_ubyte v1, off, s[8:11], 0 offset:2
; SI-NEXT:    s_mov_b32 s0, s4
; SI-NEXT:    s_mov_b32 s1, s5
; SI-NEXT:    s_waitcnt vmcnt(0)
; SI-NEXT:    buffer_store_byte v1, off, s[0:3], 0 offset:2
; SI-NEXT:    buffer_store_short v0, off, s[0:3], 0
; SI-NEXT:    s_endpgm
;
; VI-LABEL: test_copy_v3i8_align2:
; VI:       ; %bb.0:
; VI-NEXT:    s_load_dwordx4 s[4:7], s[0:1], 0x24
; VI-NEXT:    s_mov_b32 s3, 0xf000
; VI-NEXT:    s_mov_b32 s2, -1
; VI-NEXT:    s_mov_b32 s10, s2
; VI-NEXT:    s_mov_b32 s11, s3
; VI-NEXT:    s_waitcnt lgkmcnt(0)
; VI-NEXT:    s_mov_b32 s8, s6
; VI-NEXT:    s_mov_b32 s9, s7
; VI-NEXT:    buffer_load_ushort v0, off, s[8:11], 0
; VI-NEXT:    buffer_load_ubyte v1, off, s[8:11], 0 offset:2
; VI-NEXT:    s_mov_b32 s0, s4
; VI-NEXT:    s_mov_b32 s1, s5
; VI-NEXT:    s_waitcnt vmcnt(0)
; VI-NEXT:    buffer_store_byte v1, off, s[0:3], 0 offset:2
; VI-NEXT:    buffer_store_short v0, off, s[0:3], 0
; VI-NEXT:    s_endpgm
  %val = load <3 x i8>, <3 x i8> addrspace(1)* %in, align 2
  store <3 x i8> %val, <3 x i8> addrspace(1)* %out, align 2
  ret void
}

define amdgpu_kernel void @test_copy_v3i8_align1(<3 x i8> addrspace(1)* %out, <3 x i8> addrspace(1)* %in) nounwind {
; SI-LABEL: test_copy_v3i8_align1:
; SI:       ; %bb.0:
; SI-NEXT:    s_load_dwordx4 s[4:7], s[0:1], 0x9
; SI-NEXT:    s_mov_b32 s3, 0xf000
; SI-NEXT:    s_mov_b32 s2, -1
; SI-NEXT:    s_mov_b32 s10, s2
; SI-NEXT:    s_mov_b32 s11, s3
; SI-NEXT:    s_waitcnt lgkmcnt(0)
; SI-NEXT:    s_mov_b32 s8, s6
; SI-NEXT:    s_mov_b32 s9, s7
; SI-NEXT:    buffer_load_ubyte v0, off, s[8:11], 0
; SI-NEXT:    buffer_load_ubyte v1, off, s[8:11], 0 offset:1
; SI-NEXT:    buffer_load_ubyte v2, off, s[8:11], 0 offset:2
; SI-NEXT:    s_mov_b32 s0, s4
; SI-NEXT:    s_mov_b32 s1, s5
; SI-NEXT:    s_waitcnt vmcnt(2)
; SI-NEXT:    buffer_store_byte v0, off, s[0:3], 0
; SI-NEXT:    s_waitcnt vmcnt(2)
; SI-NEXT:    buffer_store_byte v1, off, s[0:3], 0 offset:1
; SI-NEXT:    s_waitcnt vmcnt(2)
; SI-NEXT:    buffer_store_byte v2, off, s[0:3], 0 offset:2
; SI-NEXT:    s_endpgm
;
; VI-LABEL: test_copy_v3i8_align1:
; VI:       ; %bb.0:
; VI-NEXT:    s_load_dwordx4 s[4:7], s[0:1], 0x24
; VI-NEXT:    s_mov_b32 s3, 0xf000
; VI-NEXT:    s_mov_b32 s2, -1
; VI-NEXT:    s_mov_b32 s10, s2
; VI-NEXT:    s_mov_b32 s11, s3
; VI-NEXT:    s_waitcnt lgkmcnt(0)
; VI-NEXT:    s_mov_b32 s8, s6
; VI-NEXT:    s_mov_b32 s9, s7
; VI-NEXT:    buffer_load_ubyte v0, off, s[8:11], 0
; VI-NEXT:    buffer_load_ubyte v1, off, s[8:11], 0 offset:1
; VI-NEXT:    buffer_load_ubyte v2, off, s[8:11], 0 offset:2
; VI-NEXT:    s_mov_b32 s0, s4
; VI-NEXT:    s_mov_b32 s1, s5
; VI-NEXT:    s_waitcnt vmcnt(2)
; VI-NEXT:    buffer_store_byte v0, off, s[0:3], 0
; VI-NEXT:    s_waitcnt vmcnt(2)
; VI-NEXT:    buffer_store_byte v1, off, s[0:3], 0 offset:1
; VI-NEXT:    s_waitcnt vmcnt(2)
; VI-NEXT:    buffer_store_byte v2, off, s[0:3], 0 offset:2
; VI-NEXT:    s_endpgm
  %val = load <3 x i8>, <3 x i8> addrspace(1)* %in, align 1
  store <3 x i8> %val, <3 x i8> addrspace(1)* %out, align 1
  ret void
}

define amdgpu_kernel void @test_copy_v4i8_volatile_load(<4 x i8> addrspace(1)* %out, <4 x i8> addrspace(1)* %in) nounwind {
; SI-LABEL: test_copy_v4i8_volatile_load:
; SI:       ; %bb.0:
; SI-NEXT:    s_load_dwordx4 s[4:7], s[0:1], 0x9
; SI-NEXT:    s_mov_b32 s3, 0xf000
; SI-NEXT:    s_mov_b32 s2, -1
; SI-NEXT:    s_waitcnt lgkmcnt(0)
; SI-NEXT:    s_mov_b32 s0, s4
; SI-NEXT:    s_mov_b32 s1, s5
; SI-NEXT:    s_mov_b32 s4, s6
; SI-NEXT:    s_mov_b32 s5, s7
; SI-NEXT:    s_mov_b32 s6, s2
; SI-NEXT:    s_mov_b32 s7, s3
; SI-NEXT:    buffer_load_dword v0, off, s[4:7], 0
; SI-NEXT:    s_waitcnt vmcnt(0)
; SI-NEXT:    buffer_store_dword v0, off, s[0:3], 0
; SI-NEXT:    s_endpgm
;
; VI-LABEL: test_copy_v4i8_volatile_load:
; VI:       ; %bb.0:
; VI-NEXT:    s_load_dwordx4 s[4:7], s[0:1], 0x24
; VI-NEXT:    s_mov_b32 s3, 0xf000
; VI-NEXT:    s_mov_b32 s2, -1
; VI-NEXT:    s_waitcnt lgkmcnt(0)
; VI-NEXT:    s_mov_b32 s0, s4
; VI-NEXT:    s_mov_b32 s1, s5
; VI-NEXT:    s_mov_b32 s4, s6
; VI-NEXT:    s_mov_b32 s5, s7
; VI-NEXT:    s_mov_b32 s6, s2
; VI-NEXT:    s_mov_b32 s7, s3
; VI-NEXT:    buffer_load_dword v0, off, s[4:7], 0
; VI-NEXT:    s_waitcnt vmcnt(0)
; VI-NEXT:    buffer_store_dword v0, off, s[0:3], 0
; VI-NEXT:    s_endpgm
  %val = load volatile <4 x i8>, <4 x i8> addrspace(1)* %in, align 4
  store <4 x i8> %val, <4 x i8> addrspace(1)* %out, align 4
  ret void
}

define amdgpu_kernel void @test_copy_v4i8_volatile_store(<4 x i8> addrspace(1)* %out, <4 x i8> addrspace(1)* %in) nounwind {
; SI-LABEL: test_copy_v4i8_volatile_store:
; SI:       ; %bb.0:
; SI-NEXT:    s_load_dwordx4 s[4:7], s[0:1], 0x9
; SI-NEXT:    s_mov_b32 s3, 0xf000
; SI-NEXT:    s_mov_b32 s2, -1
; SI-NEXT:    s_mov_b32 s10, s2
; SI-NEXT:    s_mov_b32 s11, s3
; SI-NEXT:    s_waitcnt lgkmcnt(0)
; SI-NEXT:    s_mov_b32 s8, s6
; SI-NEXT:    s_mov_b32 s9, s7
; SI-NEXT:    buffer_load_ubyte v0, off, s[8:11], 0
; SI-NEXT:    buffer_load_ubyte v1, off, s[8:11], 0 offset:1
; SI-NEXT:    buffer_load_ubyte v2, off, s[8:11], 0 offset:2
; SI-NEXT:    buffer_load_ubyte v3, off, s[8:11], 0 offset:3
; SI-NEXT:    s_mov_b32 s0, s4
; SI-NEXT:    s_mov_b32 s1, s5
; SI-NEXT:    s_waitcnt vmcnt(0)
; SI-NEXT:    buffer_store_byte v3, off, s[0:3], 0 offset:3
; SI-NEXT:    buffer_store_byte v2, off, s[0:3], 0 offset:2
; SI-NEXT:    buffer_store_byte v1, off, s[0:3], 0 offset:1
; SI-NEXT:    buffer_store_byte v0, off, s[0:3], 0
; SI-NEXT:    s_endpgm
;
; VI-LABEL: test_copy_v4i8_volatile_store:
; VI:       ; %bb.0:
; VI-NEXT:    s_load_dwordx4 s[4:7], s[0:1], 0x24
; VI-NEXT:    s_mov_b32 s3, 0xf000
; VI-NEXT:    s_mov_b32 s2, -1
; VI-NEXT:    s_mov_b32 s10, s2
; VI-NEXT:    s_mov_b32 s11, s3
; VI-NEXT:    s_waitcnt lgkmcnt(0)
; VI-NEXT:    s_mov_b32 s8, s6
; VI-NEXT:    s_mov_b32 s9, s7
; VI-NEXT:    buffer_load_ubyte v0, off, s[8:11], 0
; VI-NEXT:    buffer_load_ubyte v1, off, s[8:11], 0 offset:1
; VI-NEXT:    buffer_load_ubyte v2, off, s[8:11], 0 offset:2
; VI-NEXT:    buffer_load_ubyte v3, off, s[8:11], 0 offset:3
; VI-NEXT:    s_mov_b32 s0, s4
; VI-NEXT:    s_mov_b32 s1, s5
; VI-NEXT:    s_waitcnt vmcnt(0)
; VI-NEXT:    buffer_store_byte v3, off, s[0:3], 0 offset:3
; VI-NEXT:    buffer_store_byte v2, off, s[0:3], 0 offset:2
; VI-NEXT:    buffer_store_byte v1, off, s[0:3], 0 offset:1
; VI-NEXT:    buffer_store_byte v0, off, s[0:3], 0
; VI-NEXT:    s_endpgm
  %val = load <4 x i8>, <4 x i8> addrspace(1)* %in, align 4
  store volatile <4 x i8> %val, <4 x i8> addrspace(1)* %out, align 4
  ret void
}
