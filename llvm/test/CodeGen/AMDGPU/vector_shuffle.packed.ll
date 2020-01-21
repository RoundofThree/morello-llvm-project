; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=amdgcn-amd-amdhsa -mcpu=gfx900 -verify-machineinstrs < %s | FileCheck -check-prefix=GFX9 %s

define <4 x half> @shuffle_v4f16_23uu(<4 x half> addrspace(1)* %arg0, <4 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v4f16_23uu:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dword v0, v[0:1], off offset:4
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <4 x half>, <4 x half> addrspace(1)* %arg0
  %val1 = load <4 x half>, <4 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <4 x half> %val0, <4 x half> %val1, <4 x i32> <i32 2, i32 3, i32 undef, i32 undef>
  ret <4 x half> %shuffle
}

define <4 x half> @shuffle_v4f16_234u(<4 x half> addrspace(1)* %arg0, <4 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v4f16_234u:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dwordx2 v[2:3], v[2:3], off
; GFX9-NEXT:    global_load_dword v0, v[0:1], off offset:4
; GFX9-NEXT:    s_waitcnt vmcnt(1)
; GFX9-NEXT:    v_mov_b32_e32 v1, v2
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <4 x half>, <4 x half> addrspace(1)* %arg0
  %val1 = load <4 x half>, <4 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <4 x half> %val0, <4 x half> %val1, <4 x i32> <i32 2, i32 3, i32 4, i32 undef>
  ret <4 x half> %shuffle
}

define <4 x half> @shuffle_v4f16_u1u3(<4 x half> addrspace(1)* %arg0, <4 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v4f16_u1u3:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dwordx2 v[0:1], v[0:1], off
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <4 x half>, <4 x half> addrspace(1)* %arg0
  %val1 = load <4 x half>, <4 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <4 x half> %val0, <4 x half> %val1, <4 x i32> <i32 undef, i32 1, i32 undef, i32 3>
  ret <4 x half> %shuffle
}

define <4 x half> @shuffle_v4f16_u3u1(<4 x half> addrspace(1)* %arg0, <4 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v4f16_u3u1:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dwordx2 v[0:1], v[0:1], off
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    v_lshrrev_b32_e32 v1, 16, v1
; GFX9-NEXT:    v_lshrrev_b32_e32 v2, 16, v0
; GFX9-NEXT:    v_lshlrev_b32_e32 v0, 16, v1
; GFX9-NEXT:    v_lshlrev_b32_e32 v1, 16, v2
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <4 x half>, <4 x half> addrspace(1)* %arg0
  %val1 = load <4 x half>, <4 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <4 x half> %val0, <4 x half> %val1, <4 x i32> <i32 undef, i32 3, i32 undef, i32 1>
  ret <4 x half> %shuffle
}

define <4 x half> @shuffle_v4f16_u3uu(<4 x half> addrspace(1)* %arg0, <4 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v4f16_u3uu:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dword v0, v[0:1], off offset:4
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    v_lshrrev_b32_e32 v0, 16, v0
; GFX9-NEXT:    v_lshlrev_b32_e32 v0, 16, v0
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <4 x half>, <4 x half> addrspace(1)* %arg0
  %val1 = load <4 x half>, <4 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <4 x half> %val0, <4 x half> %val1, <4 x i32> <i32 undef, i32 3, i32 undef, i32 undef>
  ret <4 x half> %shuffle
}

define <4 x half> @shuffle_v4f16_3u6u(<4 x half> addrspace(1)* %arg0, <4 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v4f16_3u6u:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dword v0, v[0:1], off offset:4
; GFX9-NEXT:    global_load_dword v1, v[2:3], off offset:4
; GFX9-NEXT:    s_waitcnt vmcnt(1)
; GFX9-NEXT:    v_lshrrev_b32_e32 v0, 16, v0
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <4 x half>, <4 x half> addrspace(1)* %arg0
  %val1 = load <4 x half>, <4 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <4 x half> %val0, <4 x half> %val1, <4 x i32> <i32 3, i32 undef, i32 6, i32 undef>
  ret <4 x half> %shuffle
}

define <4 x half> @shuffle_v4f16_3uu7(<4 x half> addrspace(1)* %arg0, <4 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v4f16_3uu7:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dword v2, v[2:3], off offset:4
; GFX9-NEXT:    global_load_dword v0, v[0:1], off offset:4
; GFX9-NEXT:    s_waitcnt vmcnt(1)
; GFX9-NEXT:    v_lshrrev_b32_e32 v1, 16, v2
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    v_lshrrev_b32_e32 v0, 16, v0
; GFX9-NEXT:    v_lshlrev_b32_e32 v1, 16, v1
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <4 x half>, <4 x half> addrspace(1)* %arg0
  %val1 = load <4 x half>, <4 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <4 x half> %val0, <4 x half> %val1, <4 x i32> <i32 3, i32 undef, i32 undef, i32 7>
  ret <4 x half> %shuffle
}

define <4 x half> @shuffle_v4f16_35u5(<4 x half> addrspace(1)* %arg0, <4 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v4f16_35u5:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dword v2, v[2:3], off
; GFX9-NEXT:    global_load_dword v0, v[0:1], off offset:4
; GFX9-NEXT:    v_mov_b32_e32 v1, 0xffff
; GFX9-NEXT:    s_waitcnt vmcnt(1)
; GFX9-NEXT:    v_lshrrev_b32_e32 v2, 16, v2
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    v_and_b32_sdwa v0, v1, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
; GFX9-NEXT:    v_lshl_or_b32 v0, v2, 16, v0
; GFX9-NEXT:    v_lshlrev_b32_e32 v1, 16, v2
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <4 x half>, <4 x half> addrspace(1)* %arg0
  %val1 = load <4 x half>, <4 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <4 x half> %val0, <4 x half> %val1, <4 x i32> <i32 3, i32 5, i32 undef, i32 5>
  ret <4 x half> %shuffle
}

define <4 x half> @shuffle_v4f16_357u(<4 x half> addrspace(1)* %arg0, <4 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v4f16_357u:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dwordx2 v[2:3], v[2:3], off
; GFX9-NEXT:    global_load_dword v0, v[0:1], off offset:4
; GFX9-NEXT:    v_mov_b32_e32 v1, 0xffff
; GFX9-NEXT:    s_waitcnt vmcnt(1)
; GFX9-NEXT:    v_lshrrev_b32_e32 v2, 16, v2
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    v_and_b32_sdwa v0, v1, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
; GFX9-NEXT:    v_lshrrev_b32_e32 v1, 16, v3
; GFX9-NEXT:    v_lshl_or_b32 v0, v2, 16, v0
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <4 x half>, <4 x half> addrspace(1)* %arg0
  %val1 = load <4 x half>, <4 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <4 x half> %val0, <4 x half> %val1, <4 x i32> <i32 3, i32 5, i32 7, i32 undef>
  ret <4 x half> %shuffle
}

define <4 x half> @shuffle_v4f16_0101(<4 x half> addrspace(1)* %arg0, <4 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v4f16_0101:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dword v0, v[0:1], off
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    v_mov_b32_e32 v1, v0
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <4 x half>, <4 x half> addrspace(1)* %arg0
  %val1 = load <4 x half>, <4 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <4 x half> %val0, <4 x half> %val1, <4 x i32> <i32 0, i32 1, i32 0, i32 1>
  ret <4 x half> %shuffle
}

define <4 x half> @shuffle_v4f16_0123(<4 x half> addrspace(1)* %arg0, <4 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v4f16_0123:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dwordx2 v[0:1], v[0:1], off
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <4 x half>, <4 x half> addrspace(1)* %arg0
  %val1 = load <4 x half>, <4 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <4 x half> %val0, <4 x half> %val1, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  ret <4 x half> %shuffle
}

define <4 x half> @shuffle_v4f16_0145(<4 x half> addrspace(1)* %arg0, <4 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v4f16_0145:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dword v0, v[0:1], off
; GFX9-NEXT:    global_load_dword v1, v[2:3], off
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <4 x half>, <4 x half> addrspace(1)* %arg0
  %val1 = load <4 x half>, <4 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <4 x half> %val0, <4 x half> %val1, <4 x i32> <i32 0, i32 1, i32 4, i32 5>
  ret <4 x half> %shuffle
}

define <4 x half> @shuffle_v4f16_0167(<4 x half> addrspace(1)* %arg0, <4 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v4f16_0167:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dword v0, v[0:1], off
; GFX9-NEXT:    global_load_dword v1, v[2:3], off offset:4
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <4 x half>, <4 x half> addrspace(1)* %arg0
  %val1 = load <4 x half>, <4 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <4 x half> %val0, <4 x half> %val1, <4 x i32> <i32 0, i32 1, i32 6, i32 7>
  ret <4 x half> %shuffle
}

define <4 x half> @shuffle_v4f16_2301(<4 x half> addrspace(1)* %arg0, <4 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v4f16_2301:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dwordx2 v[1:2], v[0:1], off
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    v_mov_b32_e32 v0, v2
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <4 x half>, <4 x half> addrspace(1)* %arg0
  %val1 = load <4 x half>, <4 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <4 x half> %val0, <4 x half> %val1, <4 x i32> <i32 2, i32 3, i32 0, i32 1>
  ret <4 x half> %shuffle
}

define <4 x half> @shuffle_v4f16_2323(<4 x half> addrspace(1)* %arg0, <4 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v4f16_2323:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dword v0, v[0:1], off offset:4
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    v_mov_b32_e32 v1, v0
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <4 x half>, <4 x half> addrspace(1)* %arg0
  %val1 = load <4 x half>, <4 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <4 x half> %val0, <4 x half> %val1, <4 x i32> <i32 2, i32 3, i32 2, i32 3>
  ret <4 x half> %shuffle
}

define <4 x half> @shuffle_v4f16_2345(<4 x half> addrspace(1)* %arg0, <4 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v4f16_2345:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dword v0, v[0:1], off offset:4
; GFX9-NEXT:    global_load_dword v1, v[2:3], off
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <4 x half>, <4 x half> addrspace(1)* %arg0
  %val1 = load <4 x half>, <4 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <4 x half> %val0, <4 x half> %val1, <4 x i32> <i32 2, i32 3, i32 4, i32 5>
  ret <4 x half> %shuffle
}

define <4 x half> @shuffle_v4f16_2367(<4 x half> addrspace(1)* %arg0, <4 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v4f16_2367:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dword v0, v[0:1], off offset:4
; GFX9-NEXT:    global_load_dword v1, v[2:3], off offset:4
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <4 x half>, <4 x half> addrspace(1)* %arg0
  %val1 = load <4 x half>, <4 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <4 x half> %val0, <4 x half> %val1, <4 x i32> <i32 2, i32 3, i32 6, i32 7>
  ret <4 x half> %shuffle
}

define <4 x half> @shuffle_v4f16_4501(<4 x half> addrspace(1)* %arg0, <4 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v4f16_4501:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dword v2, v[2:3], off
; GFX9-NEXT:    global_load_dword v1, v[0:1], off
; GFX9-NEXT:    s_waitcnt vmcnt(1)
; GFX9-NEXT:    v_mov_b32_e32 v0, v2
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <4 x half>, <4 x half> addrspace(1)* %arg0
  %val1 = load <4 x half>, <4 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <4 x half> %val0, <4 x half> %val1, <4 x i32> <i32 4, i32 5, i32 0, i32 1>
  ret <4 x half> %shuffle
}

define <4 x half> @shuffle_v4f16_4523(<4 x half> addrspace(1)* %arg0, <4 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v4f16_4523:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dword v2, v[2:3], off
; GFX9-NEXT:    global_load_dword v1, v[0:1], off offset:4
; GFX9-NEXT:    s_waitcnt vmcnt(1)
; GFX9-NEXT:    v_mov_b32_e32 v0, v2
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <4 x half>, <4 x half> addrspace(1)* %arg0
  %val1 = load <4 x half>, <4 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <4 x half> %val0, <4 x half> %val1, <4 x i32> <i32 4, i32 5, i32 2, i32 3>
  ret <4 x half> %shuffle
}

define <4 x half> @shuffle_v4f16_4545(<4 x half> addrspace(1)* %arg0, <4 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v4f16_4545:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dword v0, v[2:3], off
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    v_mov_b32_e32 v1, v0
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <4 x half>, <4 x half> addrspace(1)* %arg0
  %val1 = load <4 x half>, <4 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <4 x half> %val0, <4 x half> %val1, <4 x i32> <i32 4, i32 5, i32 4, i32 5>
  ret <4 x half> %shuffle
}

define <4 x half> @shuffle_v4f16_4567(<4 x half> addrspace(1)* %arg0, <4 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v4f16_4567:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dwordx2 v[0:1], v[2:3], off
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <4 x half>, <4 x half> addrspace(1)* %arg0
  %val1 = load <4 x half>, <4 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <4 x half> %val0, <4 x half> %val1, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  ret <4 x half> %shuffle
}

define <4 x half> @shuffle_v4f16_6701(<4 x half> addrspace(1)* %arg0, <4 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v4f16_6701:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dword v2, v[2:3], off offset:4
; GFX9-NEXT:    global_load_dword v1, v[0:1], off
; GFX9-NEXT:    s_waitcnt vmcnt(1)
; GFX9-NEXT:    v_mov_b32_e32 v0, v2
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <4 x half>, <4 x half> addrspace(1)* %arg0
  %val1 = load <4 x half>, <4 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <4 x half> %val0, <4 x half> %val1, <4 x i32> <i32 6, i32 7, i32 0, i32 1>
  ret <4 x half> %shuffle
}

define <4 x half> @shuffle_v4f16_6723(<4 x half> addrspace(1)* %arg0, <4 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v4f16_6723:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dword v2, v[2:3], off offset:4
; GFX9-NEXT:    global_load_dword v1, v[0:1], off offset:4
; GFX9-NEXT:    s_waitcnt vmcnt(1)
; GFX9-NEXT:    v_mov_b32_e32 v0, v2
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <4 x half>, <4 x half> addrspace(1)* %arg0
  %val1 = load <4 x half>, <4 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <4 x half> %val0, <4 x half> %val1, <4 x i32> <i32 6, i32 7, i32 2, i32 3>
  ret <4 x half> %shuffle
}

define <4 x half> @shuffle_v4f16_6745(<4 x half> addrspace(1)* %arg0, <4 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v4f16_6745:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dwordx2 v[1:2], v[2:3], off
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    v_mov_b32_e32 v0, v2
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <4 x half>, <4 x half> addrspace(1)* %arg0
  %val1 = load <4 x half>, <4 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <4 x half> %val0, <4 x half> %val1, <4 x i32> <i32 6, i32 7, i32 4, i32 5>
  ret <4 x half> %shuffle
}

define <4 x half> @shuffle_v4f16_6767(<4 x half> addrspace(1)* %arg0, <4 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v4f16_6767:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dword v0, v[2:3], off offset:4
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    v_mov_b32_e32 v1, v0
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <4 x half>, <4 x half> addrspace(1)* %arg0
  %val1 = load <4 x half>, <4 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <4 x half> %val0, <4 x half> %val1, <4 x i32> <i32 6, i32 7, i32 6, i32 7>
  ret <4 x half> %shuffle
}

define <4 x half> @shuffle_v4f16_2356(<4 x half> addrspace(1)* %arg0, <4 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v4f16_2356:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dwordx2 v[2:3], v[2:3], off
; GFX9-NEXT:    global_load_dword v0, v[0:1], off offset:4
; GFX9-NEXT:    v_mov_b32_e32 v1, 0xffff
; GFX9-NEXT:    s_waitcnt vmcnt(1)
; GFX9-NEXT:    v_and_b32_sdwa v1, v1, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
; GFX9-NEXT:    v_lshl_or_b32 v1, v3, 16, v1
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <4 x half>, <4 x half> addrspace(1)* %arg0
  %val1 = load <4 x half>, <4 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <4 x half> %val0, <4 x half> %val1, <4 x i32> <i32 2, i32 3, i32 5, i32 6>
  ret <4 x half> %shuffle
}

define <4 x half> @shuffle_v4f16_5623(<4 x half> addrspace(1)* %arg0, <4 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v4f16_5623:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dwordx2 v[2:3], v[2:3], off
; GFX9-NEXT:    global_load_dword v1, v[0:1], off offset:4
; GFX9-NEXT:    v_mov_b32_e32 v0, 0xffff
; GFX9-NEXT:    s_waitcnt vmcnt(1)
; GFX9-NEXT:    v_and_b32_sdwa v0, v0, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
; GFX9-NEXT:    v_lshl_or_b32 v0, v3, 16, v0
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <4 x half>, <4 x half> addrspace(1)* %arg0
  %val1 = load <4 x half>, <4 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <4 x half> %val0, <4 x half> %val1, <4 x i32> <i32 5, i32 6, i32 2, i32 3>
  ret <4 x half> %shuffle
}

define <4 x half> @shuffle_v4f16_3456(<4 x half> addrspace(1)* %arg0, <4 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v4f16_3456:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dwordx2 v[2:3], v[2:3], off
; GFX9-NEXT:    global_load_dword v0, v[0:1], off offset:4
; GFX9-NEXT:    v_mov_b32_e32 v1, 0xffff
; GFX9-NEXT:    s_waitcnt vmcnt(1)
; GFX9-NEXT:    v_and_b32_sdwa v4, v1, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    v_and_b32_sdwa v0, v1, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
; GFX9-NEXT:    v_lshl_or_b32 v0, v2, 16, v0
; GFX9-NEXT:    v_lshl_or_b32 v1, v3, 16, v4
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <4 x half>, <4 x half> addrspace(1)* %arg0
  %val1 = load <4 x half>, <4 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <4 x half> %val0, <4 x half> %val1, <4 x i32> <i32 3, i32 4, i32 5, i32 6>
  ret <4 x half> %shuffle
}

define <4 x half> @shuffle_v4f16_5634(<4 x half> addrspace(1)* %arg0, <4 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v4f16_5634:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dwordx2 v[2:3], v[2:3], off
; GFX9-NEXT:    global_load_dword v0, v[0:1], off offset:4
; GFX9-NEXT:    v_mov_b32_e32 v1, 0xffff
; GFX9-NEXT:    s_waitcnt vmcnt(1)
; GFX9-NEXT:    v_and_b32_sdwa v4, v1, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    v_and_b32_sdwa v0, v1, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
; GFX9-NEXT:    v_lshl_or_b32 v1, v2, 16, v0
; GFX9-NEXT:    v_lshl_or_b32 v0, v3, 16, v4
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <4 x half>, <4 x half> addrspace(1)* %arg0
  %val1 = load <4 x half>, <4 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <4 x half> %val0, <4 x half> %val1, <4 x i32> <i32 5, i32 6, i32 3, i32 4>
  ret <4 x half> %shuffle
}

define <4 x half> @shuffle_v4f16_5734(<4 x half> addrspace(1)* %arg0, <4 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v4f16_5734:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dwordx2 v[2:3], v[2:3], off
; GFX9-NEXT:    global_load_dword v0, v[0:1], off offset:4
; GFX9-NEXT:    v_mov_b32_e32 v1, 0xffff
; GFX9-NEXT:    s_waitcnt vmcnt(1)
; GFX9-NEXT:    v_lshrrev_b32_e32 v3, 16, v3
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    v_and_b32_sdwa v0, v1, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
; GFX9-NEXT:    v_and_b32_sdwa v4, v1, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
; GFX9-NEXT:    v_lshl_or_b32 v1, v2, 16, v0
; GFX9-NEXT:    v_lshl_or_b32 v0, v3, 16, v4
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <4 x half>, <4 x half> addrspace(1)* %arg0
  %val1 = load <4 x half>, <4 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <4 x half> %val0, <4 x half> %val1, <4 x i32> <i32 5, i32 7, i32 3, i32 4>
  ret <4 x half> %shuffle
}

define <4 x i16> @shuffle_v4i16_2356(<4 x i16> addrspace(1)* %arg0, <4 x i16> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v4i16_2356:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dwordx2 v[2:3], v[2:3], off
; GFX9-NEXT:    global_load_dword v0, v[0:1], off offset:4
; GFX9-NEXT:    v_mov_b32_e32 v1, 0xffff
; GFX9-NEXT:    s_waitcnt vmcnt(1)
; GFX9-NEXT:    v_and_b32_sdwa v1, v1, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
; GFX9-NEXT:    v_lshl_or_b32 v1, v3, 16, v1
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <4 x i16>, <4 x i16> addrspace(1)* %arg0
  %val1 = load <4 x i16>, <4 x i16> addrspace(1)* %arg1
  %shuffle = shufflevector <4 x i16> %val0, <4 x i16> %val1, <4 x i32> <i32 2, i32 3, i32 5, i32 6>
  ret <4 x i16> %shuffle
}

define <4 x i16> @shuffle_v4i16_0167(<4 x i16> addrspace(1)* %arg0, <4 x i16> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v4i16_0167:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dword v0, v[0:1], off
; GFX9-NEXT:    global_load_dword v1, v[2:3], off offset:4
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <4 x i16>, <4 x i16> addrspace(1)* %arg0
  %val1 = load <4 x i16>, <4 x i16> addrspace(1)* %arg1
  %shuffle = shufflevector <4 x i16> %val0, <4 x i16> %val1, <4 x i32> <i32 0, i32 1, i32 6, i32 7>
  ret <4 x i16> %shuffle
}

define <4 x half> @shuffle_v4f16_0000(<4 x half> addrspace(1)* %arg0, <4 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v4f16_0000:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dwordx2 v[0:1], v[0:1], off
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    v_and_b32_e32 v1, 0xffff, v0
; GFX9-NEXT:    v_lshl_or_b32 v0, v0, 16, v1
; GFX9-NEXT:    v_mov_b32_e32 v1, v0
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <4 x half>, <4 x half> addrspace(1)* %arg0
  %val1 = load <4 x half>, <4 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <4 x half> %val0, <4 x half> %val1, <4 x i32> zeroinitializer
  ret <4 x half> %shuffle
}

define <4 x half> @shuffle_v4f16_1010(<4 x half> addrspace(1)* %arg0, <4 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v4f16_1010:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dwordx2 v[0:1], v[0:1], off
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    v_mov_b32_e32 v1, 0xffff
; GFX9-NEXT:    v_and_b32_sdwa v1, v1, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
; GFX9-NEXT:    v_lshl_or_b32 v0, v0, 16, v1
; GFX9-NEXT:    v_mov_b32_e32 v1, v0
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <4 x half>, <4 x half> addrspace(1)* %arg0
  %val1 = load <4 x half>, <4 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <4 x half> %val0, <4 x half> %val1, <4 x i32> <i32 1, i32 0, i32 1, i32 0>
  ret <4 x half> %shuffle
}

define <4 x half> @shuffle_v4f16_1100(<4 x half> addrspace(1)* %arg0, <4 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v4f16_1100:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dwordx2 v[0:1], v[0:1], off
; GFX9-NEXT:    v_mov_b32_e32 v2, 0xffff
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    v_and_b32_e32 v1, v2, v0
; GFX9-NEXT:    v_lshrrev_b32_e32 v3, 16, v0
; GFX9-NEXT:    v_lshl_or_b32 v1, v0, 16, v1
; GFX9-NEXT:    v_and_b32_e32 v0, v2, v3
; GFX9-NEXT:    v_lshl_or_b32 v0, v3, 16, v0
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <4 x half>, <4 x half> addrspace(1)* %arg0
  %val1 = load <4 x half>, <4 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <4 x half> %val0, <4 x half> %val1, <4 x i32> <i32 1, i32 1, i32 0, i32 0>
  ret <4 x half> %shuffle
}

define <4 x half> @shuffle_v4f16_6161(<4 x half> addrspace(1)* %arg0, <4 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v4f16_6161:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dword v2, v[2:3], off offset:4
; GFX9-NEXT:    global_load_dword v0, v[0:1], off
; GFX9-NEXT:    s_waitcnt vmcnt(1)
; GFX9-NEXT:    v_and_b32_e32 v1, 0xffff, v2
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    v_lshrrev_b32_e32 v0, 16, v0
; GFX9-NEXT:    v_lshl_or_b32 v0, v0, 16, v1
; GFX9-NEXT:    v_mov_b32_e32 v1, v0
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <4 x half>, <4 x half> addrspace(1)* %arg0
  %val1 = load <4 x half>, <4 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <4 x half> %val0, <4 x half> %val1, <4 x i32> <i32 6, i32 1, i32 6, i32 1>
  ret <4 x half> %shuffle
}

define <4 x half> @shuffle_v4f16_2333(<4 x half> addrspace(1)* %arg0, <4 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v4f16_2333:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dword v0, v[0:1], off offset:4
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    v_lshrrev_b32_e32 v1, 16, v0
; GFX9-NEXT:    v_and_b32_e32 v2, 0xffff, v1
; GFX9-NEXT:    v_lshl_or_b32 v1, v1, 16, v2
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <4 x half>, <4 x half> addrspace(1)* %arg0
  %val1 = load <4 x half>, <4 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <4 x half> %val0, <4 x half> %val1, <4 x i32> <i32 2, i32 3, i32 3, i32 3>
  ret <4 x half> %shuffle
}

define <4 x half> @shuffle_v4f16_6667(<4 x half> addrspace(1)* %arg0, <4 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v4f16_6667:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dword v0, v[0:1], off offset:4
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    v_lshrrev_b32_e32 v1, 16, v0
; GFX9-NEXT:    v_and_b32_e32 v2, 0xffff, v1
; GFX9-NEXT:    v_lshl_or_b32 v1, v1, 16, v2
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <4 x half>, <4 x half> addrspace(1)* %arg0
  %val1 = load <4 x half>, <4 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <4 x half> %val0, <4 x half> %val1, <4 x i32> <i32 2, i32 3, i32 3, i32 3>
  ret <4 x half> %shuffle
}

define <4 x half> @shuffle_v8f16_0101(<8 x half> addrspace(1)* %arg0, <8 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v8f16_0101:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dword v0, v[0:1], off
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    v_mov_b32_e32 v1, v0
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <8 x half>, <8 x half> addrspace(1)* %arg0
  %val1 = load <8 x half>, <8 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <8 x half> %val0, <8 x half> %val1, <4 x i32> <i32 0, i32 1, i32 0, i32 1>
  ret <4 x half> %shuffle
}

define <4 x half> @shuffle_v8f16_0123(<8 x half> addrspace(1)* %arg0, <8 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v8f16_0123:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dwordx4 v[0:3], v[0:1], off
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <8 x half>, <8 x half> addrspace(1)* %arg0
  %val1 = load <8 x half>, <8 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <8 x half> %val0, <8 x half> %val1, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  ret <4 x half> %shuffle
}

define <4 x half> @shuffle_v8f16_4589(<8 x half> addrspace(1)* %arg0, <8 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v8f16_4589:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dword v0, v[0:1], off offset:8
; GFX9-NEXT:    global_load_dword v1, v[2:3], off
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <8 x half>, <8 x half> addrspace(1)* %arg0
  %val1 = load <8 x half>, <8 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <8 x half> %val0, <8 x half> %val1, <4 x i32> <i32 4, i32 5, i32 8, i32 9>
  ret <4 x half> %shuffle
}

define <4 x half> @shuffle_v8f16_10_11_2_3(<8 x half> addrspace(1)* %arg0, <8 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v8f16_10_11_2_3:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dword v1, v[0:1], off offset:4
; GFX9-NEXT:    global_load_dword v0, v[2:3], off offset:4
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <8 x half>, <8 x half> addrspace(1)* %arg0
  %val1 = load <8 x half>, <8 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <8 x half> %val0, <8 x half> %val1, <4 x i32> <i32 10, i32 11, i32 2, i32 3>
  ret <4 x half> %shuffle
}

define <4 x half> @shuffle_v8f16_13_14_2_3(<8 x half> addrspace(1)* %arg0, <8 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v8f16_13_14_2_3:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dwordx4 v[2:5], v[2:3], off
; GFX9-NEXT:    global_load_dword v1, v[0:1], off offset:4
; GFX9-NEXT:    v_mov_b32_e32 v0, 0xffff
; GFX9-NEXT:    s_waitcnt vmcnt(1)
; GFX9-NEXT:    v_and_b32_sdwa v0, v0, v4 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
; GFX9-NEXT:    v_lshl_or_b32 v0, v5, 16, v0
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <8 x half>, <8 x half> addrspace(1)* %arg0
  %val1 = load <8 x half>, <8 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <8 x half> %val0, <8 x half> %val1, <4 x i32> <i32 13, i32 14, i32 2, i32 3>
  ret <4 x half> %shuffle
}

define <4 x half> @shuffle_v3f16_0122(<3 x half> addrspace(1)* %arg0, <3 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v3f16_0122:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dwordx2 v[0:1], v[0:1], off
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    v_and_b32_e32 v2, 0xffff, v1
; GFX9-NEXT:    v_lshl_or_b32 v1, v1, 16, v2
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <3 x half>, <3 x half> addrspace(1)* %arg0
  %val1 = load <3 x half>, <3 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <3 x half> %val0, <3 x half> %val1, <4 x i32> <i32 0, i32 1, i32 2, i32 2>
  ret <4 x half> %shuffle
}

define <4 x half> @shuffle_v2f16_0122(<2 x half> addrspace(1)* %arg0, <2 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v2f16_0122:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dword v0, v[0:1], off
; GFX9-NEXT:    v_mov_b32_e32 v1, 0xffff
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    v_and_b32_sdwa v1, v1, v0 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
; GFX9-NEXT:    v_lshl_or_b32 v1, v0, 16, v1
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <2 x half>, <2 x half> addrspace(1)* %arg0
  %val1 = load <2 x half>, <2 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <2 x half> %val0, <2 x half> %val1, <4 x i32> <i32 0, i32 1, i32 1, i32 0>
  ret <4 x half> %shuffle
}

define <6 x half> @shuffle_v6f16_452367(<6 x half> addrspace(1)* %arg0, <6 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v6f16_452367:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    v_mov_b32_e32 v4, v3
; GFX9-NEXT:    v_mov_b32_e32 v3, v2
; GFX9-NEXT:    global_load_dwordx3 v[0:2], v[0:1], off
; GFX9-NEXT:    global_load_dword v3, v[3:4], off
; GFX9-NEXT:    s_waitcnt vmcnt(1)
; GFX9-NEXT:    v_mov_b32_e32 v0, v2
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    v_mov_b32_e32 v2, v3
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <6 x half>, <6 x half> addrspace(1)* %arg0
  %val1 = load <6 x half>, <6 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <6 x half> %val0, <6 x half> %val1, <6 x i32> <i32 4, i32 5, i32 2, i32 3, i32 6, i32 7>
  ret <6 x half> %shuffle
}

define amdgpu_kernel void @fma_shuffle(<4 x half> addrspace(1)* nocapture readonly %A, <4 x half> addrspace(1)* nocapture readonly %B, <4 x half> addrspace(1)* nocapture %C)  {
; GFX9-LABEL: fma_shuffle:
; GFX9:       ; %bb.0: ; %entry
; GFX9-NEXT:    s_load_dwordx4 s[0:3], s[4:5], 0x0
; GFX9-NEXT:    s_load_dwordx4 s[4:7], s[4:5], 0x10
; GFX9-NEXT:    v_lshlrev_b32_e32 v4, 3, v0
; GFX9-NEXT:    s_waitcnt lgkmcnt(0)
; GFX9-NEXT:    v_mov_b32_e32 v1, s1
; GFX9-NEXT:    v_add_co_u32_e32 v0, vcc, s0, v4
; GFX9-NEXT:    v_addc_co_u32_e32 v1, vcc, 0, v1, vcc
; GFX9-NEXT:    v_mov_b32_e32 v3, s3
; GFX9-NEXT:    v_add_co_u32_e32 v2, vcc, s2, v4
; GFX9-NEXT:    v_addc_co_u32_e32 v3, vcc, 0, v3, vcc
; GFX9-NEXT:    v_mov_b32_e32 v5, s5
; GFX9-NEXT:    v_add_co_u32_e32 v4, vcc, s4, v4
; GFX9-NEXT:    v_addc_co_u32_e32 v5, vcc, 0, v5, vcc
; GFX9-NEXT:    global_load_dwordx2 v[0:1], v[0:1], off
; GFX9-NEXT:    global_load_dwordx2 v[2:3], v[2:3], off
; GFX9-NEXT:    global_load_dwordx2 v[6:7], v[4:5], off
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    v_pk_fma_f16 v6, v0, v2, v6 op_sel_hi:[0,1,1]
; GFX9-NEXT:    v_pk_fma_f16 v2, v1, v2, v7 op_sel_hi:[0,1,1]
; GFX9-NEXT:    v_pk_fma_f16 v0, v0, v3, v6 op_sel:[1,0,0]
; GFX9-NEXT:    v_pk_fma_f16 v1, v1, v3, v2 op_sel:[1,0,0]
; GFX9-NEXT:    global_store_dwordx2 v[4:5], v[0:1], off
; GFX9-NEXT:    s_endpgm
entry:
  %tmp1 = tail call i32 @llvm.amdgcn.workitem.id.x()
  %tmp12 = zext i32 %tmp1 to i64
  %arrayidx = getelementptr inbounds <4 x half>, <4 x half> addrspace(1)* %A, i64 %tmp12
  %tmp14 = load <4 x half>, <4 x half> addrspace(1)* %arrayidx, align 8
  %arrayidx1 = getelementptr inbounds <4 x half>, <4 x half> addrspace(1)* %B, i64 %tmp12
  %tmp15 = load <4 x half>, <4 x half> addrspace(1)* %arrayidx1, align 8
  %arrayidx2 = getelementptr inbounds <4 x half>, <4 x half> addrspace(1)* %C, i64 %tmp12
  %tmp16 = load <4 x half>, <4 x half> addrspace(1)* %arrayidx2, align 8
  %tmp17 = shufflevector <4 x half> %tmp14, <4 x half> undef, <2 x i32> zeroinitializer
  %tmp18 = shufflevector <4 x half> %tmp15, <4 x half> undef, <2 x i32> <i32 0, i32 1>
  %tmp19 = shufflevector <4 x half> %tmp16, <4 x half> undef, <2 x i32> <i32 0, i32 1>
  %tmp20 = tail call <2 x half> @llvm.fma.v2f16(<2 x half> %tmp17, <2 x half> %tmp18, <2 x half> %tmp19)
  %tmp21 = shufflevector <4 x half> %tmp14, <4 x half> undef, <2 x i32> <i32 1, i32 1>
  %tmp22 = shufflevector <4 x half> %tmp15, <4 x half> undef, <2 x i32> <i32 2, i32 3>
  %tmp23 = tail call <2 x half> @llvm.fma.v2f16(<2 x half> %tmp21, <2 x half> %tmp22, <2 x half> %tmp20)
  %tmp24 = shufflevector <2 x half> %tmp23, <2 x half> undef, <4 x i32> <i32 0, i32 1, i32 undef, i32 undef>
  %tmp25 = shufflevector <4 x half> %tmp24, <4 x half> %tmp16, <4 x i32> <i32 0, i32 1, i32 6, i32 7>
  %tmp26 = shufflevector <4 x half> %tmp14, <4 x half> undef, <2 x i32> <i32 2, i32 2>
  %tmp27 = shufflevector <4 x half> %tmp25, <4 x half> undef, <2 x i32> <i32 2, i32 3>
  %tmp28 = tail call <2 x half> @llvm.fma.v2f16(<2 x half> %tmp26, <2 x half> %tmp18, <2 x half> %tmp27)
  %tmp29 = shufflevector <4 x half> %tmp14, <4 x half> undef, <2 x i32> <i32 3, i32 3>
  %tmp30 = tail call <2 x half> @llvm.fma.v2f16(<2 x half> %tmp29, <2 x half> %tmp22, <2 x half> %tmp28)
  %tmp31 = shufflevector <2 x half> %tmp30, <2 x half> undef, <4 x i32> <i32 0, i32 1, i32 undef, i32 undef>
  %tmp32 = shufflevector <4 x half> %tmp25, <4 x half> %tmp31, <4 x i32> <i32 0, i32 1, i32 4, i32 5>
  store <4 x half> %tmp32, <4 x half> addrspace(1)* %arrayidx2, align 8
  ret void
}

define <4 x half> @shuffle_v4f16_0456(<4 x half> addrspace(1)* %arg0, <4 x half> addrspace(1)* %arg1) {
; GFX9-LABEL: shuffle_v4f16_0456:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dwordx2 v[0:1], v[0:1], off
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    global_load_dwordx2 v[1:2], v[2:3], off
; GFX9-NEXT:    v_mov_b32_e32 v3, 0xffff
; GFX9-NEXT:    v_and_b32_e32 v0, v3, v0
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    v_and_b32_sdwa v3, v3, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:WORD_1
; GFX9-NEXT:    v_lshl_or_b32 v0, v1, 16, v0
; GFX9-NEXT:    v_lshl_or_b32 v1, v2, 16, v3
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %val0 = load <4 x half>, <4 x half> addrspace(1)* %arg0
  %val1 = load <4 x half>, <4 x half> addrspace(1)* %arg1
  %shuffle = shufflevector <4 x half> %val0, <4 x half> %val1, <4 x i32> <i32 0, i32 4, i32 5, i32 6>
  ret <4 x half> %shuffle
}

declare <2 x half> @llvm.fma.v2f16(<2 x half>, <2 x half>, <2 x half>) #0
declare i32 @llvm.amdgcn.workitem.id.x() #0

attributes #0 = { nounwind readnone speculatable }
