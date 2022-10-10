//===--- ModRef.h - Memory effect modelling ---------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Definitions of ModRefInfo and FunctionModRefBehavior, which are used to
// describe the memory effects of instructions.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_IR_MODREF_H
#define LLVM_IR_MODREF_H

#include "llvm/ADT/BitmaskEnum.h"

namespace llvm {

/// Flags indicating whether a memory access modifies or references memory.
///
/// This is no access at all, a modification, a reference, or both
/// a modification and a reference. These are specifically structured such that
/// they form a three bit matrix and bit-tests for 'mod' or 'ref' or 'must'
/// work with any of the possible values.
enum class ModRefInfo : uint8_t {
  /// Must is provided for completeness, but no routines will return only
  /// Must today. See definition of Must below.
  Must = 0,
  /// The access may reference the value stored in memory,
  /// a mustAlias relation was found, and no mayAlias or partialAlias found.
  MustRef = 1,
  /// The access may modify the value stored in memory,
  /// a mustAlias relation was found, and no mayAlias or partialAlias found.
  MustMod = 2,
  /// The access may reference, modify or both the value stored in memory,
  /// a mustAlias relation was found, and no mayAlias or partialAlias found.
  MustModRef = MustRef | MustMod,
  /// The access neither references nor modifies the value stored in memory.
  NoModRef = 4,
  /// The access may reference the value stored in memory.
  Ref = NoModRef | MustRef,
  /// The access may modify the value stored in memory.
  Mod = NoModRef | MustMod,
  /// The access may reference and may modify the value stored in memory.
  ModRef = Ref | Mod,

  /// About Must:
  /// Must is set in a best effort manner.
  /// We usually do not try our best to infer Must, instead it is merely
  /// another piece of "free" information that is presented when available.
  /// Must set means there was certainly a MustAlias found. For calls,
  /// where multiple arguments are checked (argmemonly), this translates to
  /// only MustAlias or NoAlias was found.
  /// Must is not set for RAR accesses, even if the two locations must
  /// alias. The reason is that two read accesses translate to an early return
  /// of NoModRef. An additional alias check to set Must may be
  /// expensive. Other cases may also not set Must(e.g. callCapturesBefore).
  /// We refer to Must being *set* when the most significant bit is *cleared*.
  /// Conversely we *clear* Must information by *setting* the Must bit to 1.
};

LLVM_NODISCARD inline bool isNoModRef(const ModRefInfo MRI) {
  return (static_cast<int>(MRI) & static_cast<int>(ModRefInfo::MustModRef)) ==
         static_cast<int>(ModRefInfo::Must);
}
LLVM_NODISCARD inline bool isModOrRefSet(const ModRefInfo MRI) {
  return static_cast<int>(MRI) & static_cast<int>(ModRefInfo::MustModRef);
}
LLVM_NODISCARD inline bool isModAndRefSet(const ModRefInfo MRI) {
  return (static_cast<int>(MRI) & static_cast<int>(ModRefInfo::MustModRef)) ==
         static_cast<int>(ModRefInfo::MustModRef);
}
LLVM_NODISCARD inline bool isModSet(const ModRefInfo MRI) {
  return static_cast<int>(MRI) & static_cast<int>(ModRefInfo::MustMod);
}
LLVM_NODISCARD inline bool isRefSet(const ModRefInfo MRI) {
  return static_cast<int>(MRI) & static_cast<int>(ModRefInfo::MustRef);
}
LLVM_NODISCARD inline bool isMustSet(const ModRefInfo MRI) {
  return !(static_cast<int>(MRI) & static_cast<int>(ModRefInfo::NoModRef));
}

LLVM_NODISCARD inline ModRefInfo setMod(const ModRefInfo MRI) {
  return ModRefInfo(static_cast<int>(MRI) |
                    static_cast<int>(ModRefInfo::MustMod));
}
LLVM_NODISCARD inline ModRefInfo setRef(const ModRefInfo MRI) {
  return ModRefInfo(static_cast<int>(MRI) |
                    static_cast<int>(ModRefInfo::MustRef));
}
LLVM_NODISCARD inline ModRefInfo setMust(const ModRefInfo MRI) {
  return ModRefInfo(static_cast<int>(MRI) &
                    static_cast<int>(ModRefInfo::MustModRef));
}
LLVM_NODISCARD inline ModRefInfo setModAndRef(const ModRefInfo MRI) {
  return ModRefInfo(static_cast<int>(MRI) |
                    static_cast<int>(ModRefInfo::MustModRef));
}
LLVM_NODISCARD inline ModRefInfo clearMod(const ModRefInfo MRI) {
  return ModRefInfo(static_cast<int>(MRI) & static_cast<int>(ModRefInfo::Ref));
}
LLVM_NODISCARD inline ModRefInfo clearRef(const ModRefInfo MRI) {
  return ModRefInfo(static_cast<int>(MRI) & static_cast<int>(ModRefInfo::Mod));
}
LLVM_NODISCARD inline ModRefInfo clearMust(const ModRefInfo MRI) {
  return ModRefInfo(static_cast<int>(MRI) |
                    static_cast<int>(ModRefInfo::NoModRef));
}
LLVM_NODISCARD inline ModRefInfo unionModRef(const ModRefInfo MRI1,
                                             const ModRefInfo MRI2) {
  return ModRefInfo(static_cast<int>(MRI1) | static_cast<int>(MRI2));
}
LLVM_NODISCARD inline ModRefInfo intersectModRef(const ModRefInfo MRI1,
                                                 const ModRefInfo MRI2) {
  return ModRefInfo(static_cast<int>(MRI1) & static_cast<int>(MRI2));
}

/// The locations at which a function might access memory.
///
/// These are primarily used in conjunction with the \c AccessKind bits to
/// describe both the nature of access and the locations of access for a
/// function call.
enum FunctionModRefLocation {
  /// Base case is no access to memory.
  FMRL_Nowhere = 0,
  /// Access to memory via argument pointers.
  FMRL_ArgumentPointees = 8,
  /// Memory that is inaccessible via LLVM IR.
  FMRL_InaccessibleMem = 16,
  /// Access to any memory.
  FMRL_Anywhere = 32 | FMRL_InaccessibleMem | FMRL_ArgumentPointees
};

/// Summary of how a function affects memory in the program.
///
/// Loads from constant globals are not considered memory accesses for this
/// interface. Also, functions may freely modify stack space local to their
/// invocation without having to report it through these interfaces.
enum FunctionModRefBehavior {
  /// This function does not perform any non-local loads or stores to memory.
  ///
  /// This property corresponds to the GCC 'const' attribute.
  /// This property corresponds to the LLVM IR 'readnone' attribute.
  /// This property corresponds to the IntrNoMem LLVM intrinsic flag.
  FMRB_DoesNotAccessMemory =
      FMRL_Nowhere | static_cast<int>(ModRefInfo::NoModRef),

  /// The only memory references in this function (if it has any) are
  /// non-volatile loads from objects pointed to by its pointer-typed
  /// arguments, with arbitrary offsets.
  ///
  /// This property corresponds to the combination of the IntrReadMem
  /// and IntrArgMemOnly LLVM intrinsic flags.
  FMRB_OnlyReadsArgumentPointees =
      FMRL_ArgumentPointees | static_cast<int>(ModRefInfo::Ref),

  /// The only memory references in this function (if it has any) are
  /// non-volatile stores from objects pointed to by its pointer-typed
  /// arguments, with arbitrary offsets.
  ///
  /// This property corresponds to the combination of the IntrWriteMem
  /// and IntrArgMemOnly LLVM intrinsic flags.
  FMRB_OnlyWritesArgumentPointees =
      FMRL_ArgumentPointees | static_cast<int>(ModRefInfo::Mod),

  /// The only memory references in this function (if it has any) are
  /// non-volatile loads and stores from objects pointed to by its
  /// pointer-typed arguments, with arbitrary offsets.
  ///
  /// This property corresponds to the IntrArgMemOnly LLVM intrinsic flag.
  FMRB_OnlyAccessesArgumentPointees =
      FMRL_ArgumentPointees | static_cast<int>(ModRefInfo::ModRef),

  /// The only memory references in this function (if it has any) are
  /// reads of memory that is otherwise inaccessible via LLVM IR.
  ///
  /// This property corresponds to the LLVM IR inaccessiblememonly attribute.
  FMRB_OnlyReadsInaccessibleMem =
      FMRL_InaccessibleMem | static_cast<int>(ModRefInfo::Ref),

  /// The only memory references in this function (if it has any) are
  /// writes to memory that is otherwise inaccessible via LLVM IR.
  ///
  /// This property corresponds to the LLVM IR inaccessiblememonly attribute.
  FMRB_OnlyWritesInaccessibleMem =
      FMRL_InaccessibleMem | static_cast<int>(ModRefInfo::Mod),

  /// The only memory references in this function (if it has any) are
  /// references of memory that is otherwise inaccessible via LLVM IR.
  ///
  /// This property corresponds to the LLVM IR inaccessiblememonly attribute.
  FMRB_OnlyAccessesInaccessibleMem =
      FMRL_InaccessibleMem | static_cast<int>(ModRefInfo::ModRef),

  /// The function may perform non-volatile loads from objects pointed
  /// to by its pointer-typed arguments, with arbitrary offsets, and
  /// it may also perform loads of memory that is otherwise
  /// inaccessible via LLVM IR.
  ///
  /// This property corresponds to the LLVM IR
  /// inaccessiblemem_or_argmemonly attribute.
  FMRB_OnlyReadsInaccessibleOrArgMem = FMRL_InaccessibleMem |
                                       FMRL_ArgumentPointees |
                                       static_cast<int>(ModRefInfo::Ref),

  /// The function may perform non-volatile stores to objects pointed
  /// to by its pointer-typed arguments, with arbitrary offsets, and
  /// it may also perform stores of memory that is otherwise
  /// inaccessible via LLVM IR.
  ///
  /// This property corresponds to the LLVM IR
  /// inaccessiblemem_or_argmemonly attribute.
  FMRB_OnlyWritesInaccessibleOrArgMem = FMRL_InaccessibleMem |
                                        FMRL_ArgumentPointees |
                                        static_cast<int>(ModRefInfo::Mod),

  /// The function may perform non-volatile loads and stores of objects
  /// pointed to by its pointer-typed arguments, with arbitrary offsets, and
  /// it may also perform loads and stores of memory that is otherwise
  /// inaccessible via LLVM IR.
  ///
  /// This property corresponds to the LLVM IR
  /// inaccessiblemem_or_argmemonly attribute.
  FMRB_OnlyAccessesInaccessibleOrArgMem = FMRL_InaccessibleMem |
                                          FMRL_ArgumentPointees |
                                          static_cast<int>(ModRefInfo::ModRef),

  /// This function does not perform any non-local stores or volatile loads,
  /// but may read from any memory location.
  ///
  /// This property corresponds to the GCC 'pure' attribute.
  /// This property corresponds to the LLVM IR 'readonly' attribute.
  /// This property corresponds to the IntrReadMem LLVM intrinsic flag.
  FMRB_OnlyReadsMemory = FMRL_Anywhere | static_cast<int>(ModRefInfo::Ref),

  // This function does not read from memory anywhere, but may write to any
  // memory location.
  //
  // This property corresponds to the LLVM IR 'writeonly' attribute.
  // This property corresponds to the IntrWriteMem LLVM intrinsic flag.
  FMRB_OnlyWritesMemory = FMRL_Anywhere | static_cast<int>(ModRefInfo::Mod),

  /// This indicates that the function could not be classified into one of the
  /// behaviors above.
  FMRB_UnknownModRefBehavior =
      FMRL_Anywhere | static_cast<int>(ModRefInfo::ModRef)
};

// Wrapper method strips bits significant only in FunctionModRefBehavior,
// to obtain a valid ModRefInfo. The benefit of using the wrapper is that if
// ModRefInfo enum changes, the wrapper can be updated to & with the new enum
// entry with all bits set to 1.
LLVM_NODISCARD inline ModRefInfo
createModRefInfo(const FunctionModRefBehavior FMRB) {
  return ModRefInfo(FMRB & static_cast<int>(ModRefInfo::ModRef));
}

} // namespace llvm

#endif
