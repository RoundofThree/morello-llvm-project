; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -verify-machineinstrs -mtriple=powerpc64le-unknown-linux-gnu \
; RUN:   -mcpu=pwr10 -ppc-asm-full-reg-names -ppc-vsr-nums-as-vr < %s \
; RUN:   | FileCheck %s --check-prefix=LE
; RUN: llc -verify-machineinstrs -target-abi=elfv2 -mtriple=powerpc64-- \
; RUN:   -mcpu=pwr10 -ppc-asm-full-reg-names -ppc-vsr-nums-as-vr < %s \
; RUN:   | FileCheck %s --check-prefix=BE


%struct.Struct = type { i8, i16, i32 }

@valChar = external local_unnamed_addr global i8, align 1
@valShort = external local_unnamed_addr global i16, align 2
@valInt = external global i32, align 4
@valUnsigned = external local_unnamed_addr global i32, align 4
@valLong = external local_unnamed_addr global i64, align 8
@ptr = external local_unnamed_addr global i32*, align 8
@array = external local_unnamed_addr global [10 x i32], align 4
@structure = external local_unnamed_addr global %struct.Struct, align 4
@ptrfunc = external local_unnamed_addr global void (...)*, align 8

define dso_local signext i32 @ReadGlobalVarChar() local_unnamed_addr  {
; LE-LABEL: ReadGlobalVarChar:
; LE:       # %bb.0: # %entry
; LE-NEXT:    pld r3, valChar@got@pcrel(0), 1
; LE-NEXT:    lbz r3, 0(r3)
; LE-NEXT:    blr
;
; BE-LABEL: ReadGlobalVarChar:
; BE:       # %bb.0: # %entry
; BE-NEXT:    pld r3, valChar@got@pcrel(0), 1
; BE-NEXT:    lbz r3, 0(r3)
; BE-NEXT:    blr
entry:
  %0 = load i8, i8* @valChar, align 1
  %conv = zext i8 %0 to i32
  ret i32 %conv
}

define dso_local void @WriteGlobalVarChar() local_unnamed_addr  {
; LE-LABEL: WriteGlobalVarChar:
; LE:       # %bb.0: # %entry
; LE-NEXT:    pld r3, valChar@got@pcrel(0), 1
; LE-NEXT:    li r4, 3
; LE-NEXT:    stb r4, 0(r3)
; LE-NEXT:    blr
;
; BE-LABEL: WriteGlobalVarChar:
; BE:       # %bb.0: # %entry
; BE-NEXT:    pld r3, valChar@got@pcrel(0), 1
; BE-NEXT:    li r4, 3
; BE-NEXT:    stb r4, 0(r3)
; BE-NEXT:    blr
entry:
  store i8 3, i8* @valChar, align 1
  ret void
}

define dso_local signext i32 @ReadGlobalVarShort() local_unnamed_addr  {
; LE-LABEL: ReadGlobalVarShort:
; LE:       # %bb.0: # %entry
; LE-NEXT:    pld r3, valShort@got@pcrel(0), 1
; LE-NEXT:    lha r3, 0(r3)
; LE-NEXT:    blr
;
; BE-LABEL: ReadGlobalVarShort:
; BE:       # %bb.0: # %entry
; BE-NEXT:    pld r3, valShort@got@pcrel(0), 1
; BE-NEXT:    lha r3, 0(r3)
; BE-NEXT:    blr
entry:
  %0 = load i16, i16* @valShort, align 2
  %conv = sext i16 %0 to i32
  ret i32 %conv
}

define dso_local void @WriteGlobalVarShort() local_unnamed_addr  {
; LE-LABEL: WriteGlobalVarShort:
; LE:       # %bb.0: # %entry
; LE-NEXT:    pld r3, valShort@got@pcrel(0), 1
; LE-NEXT:    li r4, 3
; LE-NEXT:    sth r4, 0(r3)
; LE-NEXT:    blr
;
; BE-LABEL: WriteGlobalVarShort:
; BE:       # %bb.0: # %entry
; BE-NEXT:    pld r3, valShort@got@pcrel(0), 1
; BE-NEXT:    li r4, 3
; BE-NEXT:    sth r4, 0(r3)
; BE-NEXT:    blr
entry:
  store i16 3, i16* @valShort, align 2
  ret void
}

define dso_local signext i32 @ReadGlobalVarInt() local_unnamed_addr  {
; LE-LABEL: ReadGlobalVarInt:
; LE:       # %bb.0: # %entry
; LE-NEXT:    pld r3, valInt@got@pcrel(0), 1
; LE-NEXT:    lwa r3, 0(r3)
; LE-NEXT:    blr
;
; BE-LABEL: ReadGlobalVarInt:
; BE:       # %bb.0: # %entry
; BE-NEXT:    pld r3, valInt@got@pcrel(0), 1
; BE-NEXT:    lwa r3, 0(r3)
; BE-NEXT:    blr
entry:
  %0 = load i32, i32* @valInt, align 4
  ret i32 %0
}

define dso_local void @WriteGlobalVarInt() local_unnamed_addr  {
; LE-LABEL: WriteGlobalVarInt:
; LE:       # %bb.0: # %entry
; LE-NEXT:    pld r3, valInt@got@pcrel(0), 1
; LE-NEXT:    li r4, 33
; LE-NEXT:    stw r4, 0(r3)
; LE-NEXT:    blr
;
; BE-LABEL: WriteGlobalVarInt:
; BE:       # %bb.0: # %entry
; BE-NEXT:    pld r3, valInt@got@pcrel(0), 1
; BE-NEXT:    li r4, 33
; BE-NEXT:    stw r4, 0(r3)
; BE-NEXT:    blr
entry:
  store i32 33, i32* @valInt, align 4
  ret void
}

define dso_local signext i32 @ReadGlobalVarUnsigned() local_unnamed_addr  {
; LE-LABEL: ReadGlobalVarUnsigned:
; LE:       # %bb.0: # %entry
; LE-NEXT:    pld r3, valUnsigned@got@pcrel(0), 1
; LE-NEXT:    lwa r3, 0(r3)
; LE-NEXT:    blr
;
; BE-LABEL: ReadGlobalVarUnsigned:
; BE:       # %bb.0: # %entry
; BE-NEXT:    pld r3, valUnsigned@got@pcrel(0), 1
; BE-NEXT:    lwa r3, 0(r3)
; BE-NEXT:    blr
entry:
  %0 = load i32, i32* @valUnsigned, align 4
  ret i32 %0
}

define dso_local void @WriteGlobalVarUnsigned() local_unnamed_addr  {
; LE-LABEL: WriteGlobalVarUnsigned:
; LE:       # %bb.0: # %entry
; LE-NEXT:    pld r3, valUnsigned@got@pcrel(0), 1
; LE-NEXT:    li r4, 33
; LE-NEXT:    stw r4, 0(r3)
; LE-NEXT:    blr
;
; BE-LABEL: WriteGlobalVarUnsigned:
; BE:       # %bb.0: # %entry
; BE-NEXT:    pld r3, valUnsigned@got@pcrel(0), 1
; BE-NEXT:    li r4, 33
; BE-NEXT:    stw r4, 0(r3)
; BE-NEXT:    blr
entry:
  store i32 33, i32* @valUnsigned, align 4
  ret void
}

define dso_local signext i32 @ReadGlobalVarLong() local_unnamed_addr  {
; LE-LABEL: ReadGlobalVarLong:
; LE:       # %bb.0: # %entry
; LE-NEXT:    pld r3, valLong@got@pcrel(0), 1
; LE-NEXT:    lwa r3, 0(r3)
; LE-NEXT:    blr
;
; BE-LABEL: ReadGlobalVarLong:
; BE:       # %bb.0: # %entry
; BE-NEXT:    pld r3, valLong@got@pcrel(0), 1
; BE-NEXT:    lwa r3, 4(r3)
; BE-NEXT:    blr
entry:
  %0 = load i64, i64* @valLong, align 8
  %conv = trunc i64 %0 to i32
  ret i32 %conv
}

define dso_local void @WriteGlobalVarLong() local_unnamed_addr  {
; LE-LABEL: WriteGlobalVarLong:
; LE:       # %bb.0: # %entry
; LE-NEXT:    pld r3, valLong@got@pcrel(0), 1
; LE-NEXT:    li r4, 3333
; LE-NEXT:    std r4, 0(r3)
; LE-NEXT:    blr
;
; BE-LABEL: WriteGlobalVarLong:
; BE:       # %bb.0: # %entry
; BE-NEXT:    pld r3, valLong@got@pcrel(0), 1
; BE-NEXT:    li r4, 3333
; BE-NEXT:    std r4, 0(r3)
; BE-NEXT:    blr
entry:
  store i64 3333, i64* @valLong, align 8
  ret void
}

define dso_local i32* @ReadGlobalPtr() local_unnamed_addr  {
; LE-LABEL: ReadGlobalPtr:
; LE:       # %bb.0: # %entry
; LE-NEXT:    pld r3, ptr@got@pcrel(0), 1
; LE-NEXT:    ld r3, 0(r3)
; LE-NEXT:    blr
;
; BE-LABEL: ReadGlobalPtr:
; BE:       # %bb.0: # %entry
; BE-NEXT:    pld r3, ptr@got@pcrel(0), 1
; BE-NEXT:    ld r3, 0(r3)
; BE-NEXT:    blr
entry:
  %0 = load i32*, i32** @ptr, align 8
  ret i32* %0
}

define dso_local void @WriteGlobalPtr() local_unnamed_addr  {
; LE-LABEL: WriteGlobalPtr:
; LE:       # %bb.0: # %entry
; LE-NEXT:    pld r3, ptr@got@pcrel(0), 1
; LE-NEXT:    li r4, 3
; LE-NEXT:    ld r3, 0(r3)
; LE-NEXT:    stw r4, 0(r3)
; LE-NEXT:    blr
;
; BE-LABEL: WriteGlobalPtr:
; BE:       # %bb.0: # %entry
; BE-NEXT:    pld r3, ptr@got@pcrel(0), 1
; BE-NEXT:    li r4, 3
; BE-NEXT:    ld r3, 0(r3)
; BE-NEXT:    stw r4, 0(r3)
; BE-NEXT:    blr
entry:
  %0 = load i32*, i32** @ptr, align 8
  store i32 3, i32* %0, align 4
  ret void
}

define dso_local nonnull i32* @GlobalVarAddr() local_unnamed_addr  {
; LE-LABEL: GlobalVarAddr:
; LE:       # %bb.0: # %entry
; LE-NEXT:    pld r3, valInt@got@pcrel(0), 1
; LE-NEXT:    blr
;
; BE-LABEL: GlobalVarAddr:
; BE:       # %bb.0: # %entry
; BE-NEXT:    pld r3, valInt@got@pcrel(0), 1
; BE-NEXT:    blr
entry:
  ret i32* @valInt
}

define dso_local signext i32 @ReadGlobalArray() local_unnamed_addr  {
; LE-LABEL: ReadGlobalArray:
; LE:       # %bb.0: # %entry
; LE-NEXT:    pld r3, array@got@pcrel(0), 1
; LE-NEXT:    lwa r3, 12(r3)
; LE-NEXT:    blr
;
; BE-LABEL: ReadGlobalArray:
; BE:       # %bb.0: # %entry
; BE-NEXT:    pld r3, array@got@pcrel(0), 1
; BE-NEXT:    lwa r3, 12(r3)
; BE-NEXT:    blr
entry:
  %0 = load i32, i32* getelementptr inbounds ([10 x i32], [10 x i32]* @array, i64 0, i64 3), align 4
  ret i32 %0
}

define dso_local void @WriteGlobalArray() local_unnamed_addr  {
; LE-LABEL: WriteGlobalArray:
; LE:       # %bb.0: # %entry
; LE-NEXT:    pld r3, array@got@pcrel(0), 1
; LE-NEXT:    li r4, 5
; LE-NEXT:    stw r4, 12(r3)
; LE-NEXT:    blr
;
; BE-LABEL: WriteGlobalArray:
; BE:       # %bb.0: # %entry
; BE-NEXT:    pld r3, array@got@pcrel(0), 1
; BE-NEXT:    li r4, 5
; BE-NEXT:    stw r4, 12(r3)
; BE-NEXT:    blr
entry:
  store i32 5, i32* getelementptr inbounds ([10 x i32], [10 x i32]* @array, i64 0, i64 3), align 4
  ret void
}

define dso_local signext i32 @ReadGlobalStruct() local_unnamed_addr  {
; LE-LABEL: ReadGlobalStruct:
; LE:       # %bb.0: # %entry
; LE-NEXT:    pld r3, structure@got@pcrel(0), 1
; LE-NEXT:    lwa r3, 4(r3)
; LE-NEXT:    blr
;
; BE-LABEL: ReadGlobalStruct:
; BE:       # %bb.0: # %entry
; BE-NEXT:    pld r3, structure@got@pcrel(0), 1
; BE-NEXT:    lwa r3, 4(r3)
; BE-NEXT:    blr
entry:
  %0 = load i32, i32* getelementptr inbounds (%struct.Struct, %struct.Struct* @structure, i64 0, i32 2), align 4
  ret i32 %0
}

define dso_local void @WriteGlobalStruct() local_unnamed_addr  {
; LE-LABEL: WriteGlobalStruct:
; LE:       # %bb.0: # %entry
; LE-NEXT:    pld r3, structure@got@pcrel(0), 1
; LE-NEXT:    li r4, 3
; LE-NEXT:    stw r4, 4(r3)
; LE-NEXT:    blr
;
; BE-LABEL: WriteGlobalStruct:
; BE:       # %bb.0: # %entry
; BE-NEXT:    pld r3, structure@got@pcrel(0), 1
; BE-NEXT:    li r4, 3
; BE-NEXT:    stw r4, 4(r3)
; BE-NEXT:    blr
entry:
  store i32 3, i32* getelementptr inbounds (%struct.Struct, %struct.Struct* @structure, i64 0, i32 2), align 4
  ret void
}

define dso_local void @ReadFuncPtr() local_unnamed_addr  {
; LE-LABEL: ReadFuncPtr:
; LE:         .localentry ReadFuncPtr, 1
; LE-NEXT:  # %bb.0: # %entry
; LE-NEXT:    pld r3, ptrfunc@got@pcrel(0), 1
; LE-NEXT:    ld r12, 0(r3)
; LE-NEXT:    mtctr r12
; LE-NEXT:    bctr
; LE-NEXT:    #TC_RETURNr8 ctr 0
;
; BE-LABEL: ReadFuncPtr:
; BE:         .localentry ReadFuncPtr, 1
; BE-NEXT:  # %bb.0: # %entry
; BE-NEXT:    pld r3, ptrfunc@got@pcrel(0), 1
; BE-NEXT:    ld r12, 0(r3)
; BE-NEXT:    mtctr r12
; BE-NEXT:    bctr
; BE-NEXT:    #TC_RETURNr8 ctr 0
entry:
  %0 = load void ()*, void ()** bitcast (void (...)** @ptrfunc to void ()**), align 8
  tail call void %0()
  ret void
}

define dso_local void @WriteFuncPtr() local_unnamed_addr  {
; LE-LABEL: WriteFuncPtr:
; LE:       # %bb.0: # %entry
; LE-NEXT:    pld r3, ptrfunc@got@pcrel(0), 1
; LE-NEXT:    pld r4, function@got@pcrel(0), 1
; LE-NEXT:    std r4, 0(r3)
; LE-NEXT:    blr
;
; BE-LABEL: WriteFuncPtr:
; BE:       # %bb.0: # %entry
; BE-NEXT:    pld r3, ptrfunc@got@pcrel(0), 1
; BE-NEXT:    pld r4, function@got@pcrel(0), 1
; BE-NEXT:    std r4, 0(r3)
; BE-NEXT:    blr
entry:
  store void (...)* @function, void (...)** @ptrfunc, align 8
  ret void
}

declare void @function(...)

