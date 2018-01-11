; RUN: %cheri_purecap_llc -o - -O2 -mips-ssection-threshold=0 -mxgot -mxmxgot %s
; ModuleID = '/home/alr48/obj/build/llvm-build/cheri_printf-3fff4a-bugpoint-reduce.ll-reduced-simplified.bc'
; This was crahsing after merging to Jan 8th 2018 (cheri_prinf.c from cheribsd)
; Assertion failed: (Offset.getBitWidth() == DL.getPointerBaseSizeInBits(cast<PointerType>( getType())->getAddressSpace()) && "The offset must have exactly as many bits as our pointer.")
source_filename = "cheri_printf-3fff4a-bugpoint-reduce.ll-output-4742795.bc"
target datalayout = "E-m:e-pf200:128:128-i8:8:32-i16:16:32-i64:64-n32:64-S128-A200"
target triple = "cheri-unknown-freebsd"

; Function Attrs: nounwind readnone speculatable
declare void @llvm.dbg.declare(metadata, metadata, metadata) #0

; Function Attrs: noinline nounwind optnone
define void @libcheri_printf_putchar() #1 !dbg !35 {
entry:
  call void @llvm.dbg.declare(metadata i8 addrspace(200)* addrspace(200)* undef, metadata !39, metadata !DIExpression()), !dbg !40
  ret void, !dbg !41
}

attributes #0 = { nounwind readnone speculatable }
attributes #1 = { noinline nounwind optnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="cheri128" "target-features"="+cheri128,+chericap,+soft-float,-noabicalls" "unsafe-fp-math"="false" "use-soft-float"="true" }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!33, !34}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "clang version 7.0.0 (https://github.com/llvm-mirror/clang.git c0a53d564b2fe2334520a006e0f4d889947db864) (https://github.com/llvm-mirror/llvm.git 39575d1d894e8a893d0fd05b480d5977087db4aa)", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, retainedTypes: !3, globals: !25)
!1 = !DIFile(filename: "/tmp/cheri_printf.c", directory: "/home/alr48/cheri/build/llvm-build")
!2 = !{}
!3 = !{!4, !5, !7, !10, !12, !18, !20, !6, !21}
!4 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 128)
!5 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !6, size: 128)
!6 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!7 = !DIDerivedType(tag: DW_TAG_typedef, name: "u_char", file: !8, line: 50, baseType: !9)
!8 = !DIFile(filename: "/home/alr48/cheri/build/cheribsd-obj-128/mips.mips64/exports/users/alr48/sources/cheribsd/tmp/usr/include/sys/types.h", directory: "/home/alr48/cheri/build/llvm-build")
!9 = !DIBasicType(name: "unsigned char", size: 8, encoding: DW_ATE_unsigned_char)
!10 = !DIDerivedType(tag: DW_TAG_typedef, name: "u_int", file: !8, line: 52, baseType: !11)
!11 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!12 = !DIDerivedType(tag: DW_TAG_typedef, name: "uintptr_t", file: !13, line: 78, baseType: !14)
!13 = !DIFile(filename: "/home/alr48/cheri/build/cheribsd-obj-128/mips.mips64/exports/users/alr48/sources/cheribsd/tmp/usr/include/sys/_stdint.h", directory: "/home/alr48/cheri/build/llvm-build")
!14 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uintptr_t", file: !15, line: 119, baseType: !16)
!15 = !DIFile(filename: "/home/alr48/cheri/build/cheribsd-obj-128/mips.mips64/exports/users/alr48/sources/cheribsd/tmp/usr/include/machine/_types.h", directory: "/home/alr48/cheri/build/llvm-build")
!16 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uintcap_t", file: !1, line: 376, baseType: !17)
!17 = !DIBasicType(name: "__uintcap_t", size: 128, encoding: DW_ATE_unsigned)
!18 = !DIDerivedType(tag: DW_TAG_typedef, name: "u_short", file: !8, line: 51, baseType: !19)
!19 = !DIBasicType(name: "unsigned short", size: 16, encoding: DW_ATE_unsigned)
!20 = !DIBasicType(name: "short", size: 16, encoding: DW_ATE_signed)
!21 = !DIDerivedType(tag: DW_TAG_typedef, name: "intmax_t", file: !13, line: 82, baseType: !22)
!22 = !DIDerivedType(tag: DW_TAG_typedef, name: "__intmax_t", file: !15, line: 93, baseType: !23)
!23 = !DIDerivedType(tag: DW_TAG_typedef, name: "__int64_t", file: !15, line: 57, baseType: !24)
!24 = !DIBasicType(name: "long int", size: 64, encoding: DW_ATE_signed)
!25 = !{!26}
!26 = !DIGlobalVariableExpression(var: !27, expr: !DIExpression())
!27 = distinct !DIGlobalVariable(name: "hex2ascii_data", scope: !0, file: !28, line: 64, type: !29, isLocal: true, isDefinition: true)
!28 = !DIFile(filename: "/exports/users/alr48/sources/cheribsd/lib/libc_cheri/cheri_printf.c", directory: "/home/alr48/cheri/build/llvm-build")
!29 = !DICompositeType(tag: DW_TAG_array_type, baseType: !30, size: 296, elements: !31)
!30 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !6)
!31 = !{!32}
!32 = !DISubrange(count: 37)
!33 = !{i32 2, !"Debug Info Version", i32 3}
!34 = !{i32 7, !"PIC Level", i32 1}
!35 = distinct !DISubprogram(name: "libcheri_printf_putchar", scope: !28, file: !28, line: 527, type: !36, isLocal: true, isDefinition: true, scopeLine: 528, flags: DIFlagPrototyped, isOptimized: false, unit: !0, variables: !2)
!36 = !DISubroutineType(types: !37)
!37 = !{null, !38, !4}
!38 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!39 = !DILocalVariable(name: "arg", arg: 2, scope: !35, file: !28, line: 527, type: !4)
!40 = !DILocation(line: 527, column: 38, scope: !35)
!41 = !DILocation(line: 531, column: 1, scope: !35)
