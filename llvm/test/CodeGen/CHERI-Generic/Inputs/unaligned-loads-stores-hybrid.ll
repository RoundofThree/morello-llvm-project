; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: %generic_cheri_hybrid_llc --relocation-model=pic %s -o - | FileCheck %s

; ModuleID = 'global.c'

@a1 = global i64 0, align 1
@a2 = global i64 0, align 2
@a4 = global i64 0, align 4
@a8 = global i64 0, align 8


define i64 @load_global_i64_align_1(i64 %y) addrspace(200) nounwind {
entry:
  %ret = load i64, i64 addrspace(200)* addrspacecast(i64* @a1 to i64 addrspace(200)*), align 1
  ret i64 %ret
}

define i64 @load_global_i64_align_2(i64 %y) addrspace(200) nounwind {
entry:
  %ret = load i64, i64 addrspace(200)* addrspacecast(i64* @a2 to i64 addrspace(200)*), align 2
  ret i64 %ret
}

define i64 @load_global_i64_align_4(i64 %y) addrspace(200) nounwind {
entry:
  %ret = load i64, i64 addrspace(200)* addrspacecast(i64* @a4 to i64 addrspace(200)*), align 4
  ret i64 %ret
}

define i64 @load_global_i64_align_8(i64 %y) addrspace(200) nounwind {
entry:
  %ret = load i64, i64 addrspace(200)* addrspacecast(i64* @a8 to i64 addrspace(200)*), align 8
  ret i64 %ret
}

define void @store_global_i64_align_1(i64 %y) addrspace(200) nounwind {
entry:
  store i64 %y, i64 addrspace(200)* addrspacecast(i64* @a1 to i64 addrspace(200)*), align 1
  ret void
}

define void @store_global_i64_align_2(i64 %y) addrspace(200) nounwind {
entry:
  store i64 %y, i64 addrspace(200)* addrspacecast(i64* @a2 to i64 addrspace(200)*), align 2
  ret void
}

define void @store_global_i64_align_4(i64 %y) addrspace(200) nounwind {
entry:
  store i64 %y, i64 addrspace(200)* addrspacecast(i64* @a4 to i64 addrspace(200)*), align 4
  ret void
}

define void @store_global_i64_align_8(i64 %y) addrspace(200) nounwind {
entry:
  store i64 %y, i64 addrspace(200)* addrspacecast(i64* @a8 to i64 addrspace(200)*), align 8
  ret void
}
