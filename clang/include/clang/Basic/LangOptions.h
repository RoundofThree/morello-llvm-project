//===- LangOptions.h - C Language Family Language Options -------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
/// \file
/// Defines the clang::LangOptions interface.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CLANG_BASIC_LANGOPTIONS_H
#define LLVM_CLANG_BASIC_LANGOPTIONS_H

#include "clang/Basic/CommentOptions.h"
#include "clang/Basic/LLVM.h"
#include "clang/Basic/ObjCRuntime.h"
#include "clang/Basic/Sanitizers.h"
#include "clang/Basic/Visibility.h"
#include "llvm/ADT/FloatingPointMode.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/ADT/Triple.h"
#include <string>
#include <vector>

namespace clang {

/// Bitfields of LangOptions, split out from LangOptions in order to ensure that
/// this large collection of bitfields is a trivial class type.
class LangOptionsBase {
public:
  // Define simple language options (with no accessors).
#define LANGOPT(Name, Bits, Default, Description) unsigned Name : Bits;
#define ENUM_LANGOPT(Name, Type, Bits, Default, Description)
#include "clang/Basic/LangOptions.def"

protected:
  // Define language options of enumeration type. These are private, and will
  // have accessors (below).
#define LANGOPT(Name, Bits, Default, Description)
#define ENUM_LANGOPT(Name, Type, Bits, Default, Description) \
  unsigned Name : Bits;
#include "clang/Basic/LangOptions.def"
};

/// In the Microsoft ABI, this controls the placement of virtual displacement
/// members used to implement virtual inheritance.
enum class MSVtorDispMode { Never, ForVBaseOverride, ForVFTable };

/// Keeps track of the various options that can be
/// enabled, which controls the dialect of C or C++ that is accepted.
class LangOptions : public LangOptionsBase {
public:
  using Visibility = clang::Visibility;
  using RoundingMode = llvm::RoundingMode;

  enum GCMode { NonGC, GCOnly, HybridGC };
  enum StackProtectorMode { SSPOff, SSPOn, SSPStrong, SSPReq };

  // Automatic variables live on the stack, and when trivial they're usually
  // uninitialized because it's undefined behavior to use them without
  // initializing them.
  enum class TrivialAutoVarInitKind { Uninitialized, Zero, Pattern };

  enum SignedOverflowBehaviorTy {
    // Default C standard behavior.
    SOB_Undefined,

    // -fwrapv
    SOB_Defined,

    // -ftrapv
    SOB_Trapping
  };

  // FIXME: Unify with TUKind.
  enum CompilingModuleKind {
    /// Not compiling a module interface at all.
    CMK_None,

    /// Compiling a module from a module map.
    CMK_ModuleMap,

    /// Compiling a module from a list of header files.
    CMK_HeaderModule,

    /// Compiling a C++ modules TS module interface unit.
    CMK_ModuleInterface,
  };

  enum PragmaMSPointersToMembersKind {
    PPTMK_BestCase,
    PPTMK_FullGeneralitySingleInheritance,
    PPTMK_FullGeneralityMultipleInheritance,
    PPTMK_FullGeneralityVirtualInheritance
  };

  using MSVtorDispMode = clang::MSVtorDispMode;

  enum DefaultCallingConvention {
    DCC_None,
    DCC_CDecl,
    DCC_FastCall,
    DCC_StdCall,
    DCC_VectorCall,
    DCC_RegCall
  };

  enum AddrSpaceMapMangling { ASMM_Target, ASMM_On, ASMM_Off };

  // Corresponds to _MSC_VER
  enum MSVCMajorVersion {
    MSVC2010 = 1600,
    MSVC2012 = 1700,
    MSVC2013 = 1800,
    MSVC2015 = 1900,
    MSVC2017 = 1910,
    MSVC2017_5 = 1912,
    MSVC2017_7 = 1914,
  };

  /// Clang versions with different platform ABI conformance.
  enum class ClangABI {
    /// Attempt to be ABI-compatible with code generated by Clang 3.8.x
    /// (SVN r257626). This causes <1 x long long> to be passed in an
    /// integer register instead of an SSE register on x64_64.
    Ver3_8,

    /// Attempt to be ABI-compatible with code generated by Clang 4.0.x
    /// (SVN r291814). This causes move operations to be ignored when
    /// determining whether a class type can be passed or returned directly.
    Ver4,

    /// Attempt to be ABI-compatible with code generated by Clang 6.0.x
    /// (SVN r321711). This causes determination of whether a type is
    /// standard-layout to ignore collisions between empty base classes
    /// and between base classes and member subobjects, which affects
    /// whether we reuse base class tail padding in some ABIs.
    Ver6,

    /// Attempt to be ABI-compatible with code generated by Clang 7.0.x
    /// (SVN r338536). This causes alignof (C++) and _Alignof (C11) to be
    /// compatible with __alignof (i.e., return the preferred alignment)
    /// rather than returning the required alignment.
    Ver7,

    /// Attempt to be ABI-compatible with code generated by Clang 9.0.x
    /// (SVN r351319). This causes vectors of __int128 to be passed in memory
    /// instead of passing in multiple scalar registers on x86_64 on Linux and
    /// NetBSD.
    Ver9,

    /// Conform to the underlying platform's C and C++ ABIs as closely
    /// as we can.
    Latest
  };

  enum class CoreFoundationABI {
    /// No interoperability ABI has been specified
    Unspecified,
    /// CoreFoundation does not have any language interoperability
    Standalone,
    /// Interoperability with the ObjectiveC runtime
    ObjectiveC,
    /// Interoperability with the latest known version of the Swift runtime
    Swift,
    /// Interoperability with the Swift 5.0 runtime
    Swift5_0,
    /// Interoperability with the Swift 4.2 runtime
    Swift4_2,
    /// Interoperability with the Swift 4.1 runtime
    Swift4_1,
  };

  enum FPModeKind {
    // Disable the floating point pragma
    FPM_Off,

    // Enable the floating point pragma
    FPM_On,

    // Aggressively fuse FP ops (E.g. FMA).
    FPM_Fast
  };

  enum CheriUIntCapMode {
    UIntCap_Offset, /// Use the capability the offset for operations on
                    /// uintcap_t (GC-friendlier than vaddr)
    UIntCap_Addr, /// Use the capability the offset for operations on uintcap_t
                  /// (More C compatible than offset)
  };

  enum CheriCapIntConversion {
    CapInt_Strict, /// All conversions (including (u)intcap<->int need explicit
                   /// casts). Unlikely to be useful very often but could
                   /// detect some cases of accidental tag-stripping.
    CapInt_Explicit, /// Require explicit casts for pointer -> capability and
                     /// integer -> capability pointer
    CapInt_Address,  /// Conversions return the address or create an untagged
                     /// capability with the address
    CapInt_Relative, /// Perform conversions relative to DDC (previous
                     /// default)
    CapInt_Invalid = -1,
  };

  enum CheriMemopsInlineBehaviourMode {
    CheriMemopsInlineBehaviour_Legacy, /// All calls to memcpy/memmove preserve tags
    CheriMemopsInlineBehaviour_New, /// Inline memcpy calls without preseving tags
                                    /// if the source type doesn't contain capabilities.
  };

  // TODO: this should probably be flags
#if 0
    CBM_ReferencesAggressive, /// (unused for now, might set more bounds)
    CBM_NestedStructs
    CBM_NonArrayObjectMembers, /// also set bounds on non-array object members
    CBM_AllObjectMembers,     /// also set bounds on non-array object members
    CBM_NonzeroArrayIndexes, /// also set bounds &array[n] if n != 0
    CBM_AllArrayIndexes,     /// also set bounds on all non-annoated array index
#endif
  enum CheriBoundsMode {
    CBM_Conservative, /// Only set bounds for stack allocations (safe)
    CBM_References,   /// Also set bounds for C++ references to scalar types and
                      /// references to final without vtables or flexible arrays
    CBM_SubObjectsSafe, /// in addition to references also set bounds for
                        /// pointers to subobjects (but only for those where we
                        /// assume that it is safe to do so)
    CBM_Aggressive, /// Set bounds for anything that is not definitively unsafe
                    /// or annotated as not wanting bounds
    CBM_VeryAggressive,   /// Same as aggressive but also set bounds on array
                          /// indexing operations such as foo(&array[0]) -> set
                          /// bounds to first member
    CBM_EverywhereUnsafe, /// Unsafe: Set bounds everywhere where there isn't an
                          /// explicit opt-out (also sets bounds on object
                          /// pointers with vtables)
  };

  // TODO: merge FEnvAccessModeKind and FPContractModeKind
  enum FEnvAccessModeKind {
    FEA_Off,

    FEA_On
  };

  /// Alias for RoundingMode::NearestTiesToEven.
  static constexpr unsigned FPR_ToNearest =
      static_cast<unsigned>(llvm::RoundingMode::NearestTiesToEven);

  /// Possible floating point exception behavior.
  enum FPExceptionModeKind {
    /// Assume that floating-point exceptions are masked.
    FPE_Ignore,
    /// Transformations do not cause new exceptions but may hide some.
    FPE_MayTrap,
    /// Strictly preserve the floating-point exception semantics.
    FPE_Strict
  };

  enum class LaxVectorConversionKind {
    /// Permit no implicit vector bitcasts.
    None,
    /// Permit vector bitcasts between integer vectors with different numbers
    /// of elements but the same total bit-width.
    Integer,
    /// Permit vector bitcasts between all vectors with the same total
    /// bit-width.
    All,
  };

  enum class SignReturnAddressScopeKind {
    /// No signing for any function.
    None,
    /// Sign the return address of functions that spill LR.
    NonLeaf,
    /// Sign the return address of all functions,
    All
  };

  enum class SignReturnAddressKeyKind {
    /// Return address signing uses APIA key.
    AKey,
    /// Return address signing uses APIB key.
    BKey
  };

public:
  /// Set of enabled sanitizers.
  SanitizerSet Sanitize;

  /// Paths to blacklist files specifying which objects
  /// (files, functions, variables) should not be instrumented.
  std::vector<std::string> SanitizerBlacklistFiles;

  /// Paths to the XRay "always instrument" files specifying which
  /// objects (files, functions, variables) should be imbued with the XRay
  /// "always instrument" attribute.
  /// WARNING: This is a deprecated field and will go away in the future.
  std::vector<std::string> XRayAlwaysInstrumentFiles;

  /// Paths to the XRay "never instrument" files specifying which
  /// objects (files, functions, variables) should be imbued with the XRay
  /// "never instrument" attribute.
  /// WARNING: This is a deprecated field and will go away in the future.
  std::vector<std::string> XRayNeverInstrumentFiles;

  /// Paths to the XRay attribute list files, specifying which objects
  /// (files, functions, variables) should be imbued with the appropriate XRay
  /// attribute(s).
  std::vector<std::string> XRayAttrListFiles;

  clang::ObjCRuntime ObjCRuntime;

  CoreFoundationABI CFRuntime = CoreFoundationABI::Unspecified;

  std::string ObjCConstantStringClass;

  /// The name of the handler function to be called when -ftrapv is
  /// specified.
  ///
  /// If none is specified, abort (GCC-compatible behaviour).
  std::string OverflowHandler;

  /// The module currently being compiled as specified by -fmodule-name.
  std::string ModuleName;

  /// The name of the current module, of which the main source file
  /// is a part. If CompilingModule is set, we are compiling the interface
  /// of this module, otherwise we are compiling an implementation file of
  /// it. This starts as ModuleName in case -fmodule-name is provided and
  /// changes during compilation to reflect the current module.
  std::string CurrentModule;

  /// The names of any features to enable in module 'requires' decls
  /// in addition to the hard-coded list in Module.cpp and the target features.
  ///
  /// This list is sorted.
  std::vector<std::string> ModuleFeatures;

  /// Options for parsing comments.
  CommentOptions CommentOpts;

  /// A list of all -fno-builtin-* function names (e.g., memset).
  std::vector<std::string> NoBuiltinFuncs;

  /// Triples of the OpenMP targets that the host code codegen should
  /// take into account in order to generate accurate offloading descriptors.
  std::vector<llvm::Triple> OMPTargetTriples;

  /// Name of the IR file that contains the result of the OpenMP target
  /// host code generation.
  std::string OMPHostIRFile;

  /// Indicates whether the front-end is explicitly told that the
  /// input is a header file (i.e. -x c-header).
  bool IsHeaderFile = false;

  LangOptions();

  // Define accessors/mutators for language options of enumeration type.
#define LANGOPT(Name, Bits, Default, Description)
#define ENUM_LANGOPT(Name, Type, Bits, Default, Description) \
  Type get##Name() const { return static_cast<Type>(Name); } \
  void set##Name(Type Value) { Name = static_cast<unsigned>(Value); }
#include "clang/Basic/LangOptions.def"

  /// Are we compiling a module interface (.cppm or module map)?
  bool isCompilingModule() const {
    return getCompilingModule() != CMK_None;
  }

  /// Do we need to track the owning module for a local declaration?
  bool trackLocalOwningModule() const {
    return isCompilingModule() || ModulesLocalVisibility;
  }

  bool isSignedOverflowDefined() const {
    return getSignedOverflowBehavior() == SOB_Defined;
  }

  bool isSubscriptPointerArithmetic() const {
    return ObjCRuntime.isSubscriptPointerArithmetic() &&
           !ObjCSubscriptingLegacyRuntime;
  }

  bool isCompatibleWithMSVC(MSVCMajorVersion MajorVersion) const {
    return MSCompatibilityVersion >= MajorVersion * 100000U;
  }

  bool cheriUIntCapUsesAddr() const {
    return getCheriUIntCap() == UIntCap_Addr;
  }

  bool cheriUIntCapUsesOffset() const {
    return getCheriUIntCap() == UIntCap_Offset;
  }

  bool explicitConversionsFromCap() const {
    return getCheriCapToInt() == CapInt_Explicit ||
           getCheriCapToInt() == CapInt_Strict;
  }

  bool explicitConversionsToCap() const {
    return getCheriIntToCap() == CapInt_Explicit ||
           getCheriIntToCap() == CapInt_Strict;
  }

  /// Reset all of the options that are not considered when building a
  /// module.
  void resetNonModularOptions();

  /// Is this a libc/libm function that is no longer recognized as a
  /// builtin because a -fno-builtin-* option has been specified?
  bool isNoBuiltinFunc(StringRef Name) const;

  /// True if any ObjC types may have non-trivial lifetime qualifiers.
  bool allowsNonTrivialObjCLifetimeQualifiers() const {
    return ObjCAutoRefCount || ObjCWeak;
  }

  bool assumeFunctionsAreConvergent() const {
    return ConvergentFunctions;
  }

  /// Return the OpenCL C or C++ version as a VersionTuple.
  VersionTuple getOpenCLVersionTuple() const;

  /// Check if return address signing is enabled.
  bool hasSignReturnAddress() const {
    return getSignReturnAddressScope() != SignReturnAddressScopeKind::None;
  }

  /// Check if return address signing uses AKey.
  bool isSignReturnAddressWithAKey() const {
    return getSignReturnAddressKey() == SignReturnAddressKeyKind::AKey;
  }

  /// Check if leaf functions are also signed.
  bool isSignReturnAddressScopeAll() const {
    return getSignReturnAddressScope() == SignReturnAddressScopeKind::All;
  }
};

/// Floating point control options
class FPOptionsOverride;
class FPOptions {
public:
  // We start by defining the layout.
  using storage_type = uint16_t;

  using RoundingMode = llvm::RoundingMode;

  static constexpr unsigned StorageBitSize = 8 * sizeof(storage_type);

  // Define a fake option named "First" so that we have a PREVIOUS even for the
  // real first option.
  static constexpr storage_type FirstShift = 0, FirstWidth = 0;
#define OPTION(NAME, TYPE, WIDTH, PREVIOUS)                                    \
  static constexpr storage_type NAME##Shift =                                  \
      PREVIOUS##Shift + PREVIOUS##Width;                                       \
  static constexpr storage_type NAME##Width = WIDTH;                           \
  static constexpr storage_type NAME##Mask = ((1 << NAME##Width) - 1)          \
                                             << NAME##Shift;
#include "clang/Basic/FPOptions.def"

  static constexpr storage_type TotalWidth = 0
#define OPTION(NAME, TYPE, WIDTH, PREVIOUS) +WIDTH
#include "clang/Basic/FPOptions.def"
      ;
  static_assert(TotalWidth <= StorageBitSize, "Too short type for FPOptions");

private:
  storage_type Value;

public:
  FPOptions() : Value(0) {
    setFPContractMode(LangOptions::FPM_Off);
    setRoundingMode(static_cast<RoundingMode>(LangOptions::FPR_ToNearest));
    setFPExceptionMode(LangOptions::FPE_Ignore);
  }
  // Used for serializing.
  explicit FPOptions(unsigned I) { getFromOpaqueInt(I); }

  explicit FPOptions(const LangOptions &LO) {
    Value = 0;
    setFPContractMode(LO.getDefaultFPContractMode());
    setRoundingMode(LO.getFPRoundingMode());
    setFPExceptionMode(LO.getFPExceptionMode());
    setAllowFEnvAccess(LangOptions::FPM_Off);
    setAllowFPReassociate(LO.AllowFPReassoc);
    setNoHonorNaNs(LO.NoHonorNaNs);
    setNoHonorInfs(LO.NoHonorInfs);
    setNoSignedZero(LO.NoSignedZero);
    setAllowReciprocal(LO.AllowRecip);
    setAllowApproxFunc(LO.ApproxFunc);
  }

  bool allowFPContractWithinStatement() const {
    return getFPContractMode() == LangOptions::FPM_On;
  }
  void setAllowFPContractWithinStatement() {
    setFPContractMode(LangOptions::FPM_On);
  }

  bool allowFPContractAcrossStatement() const {
    return getFPContractMode() == LangOptions::FPM_Fast;
  }
  void setAllowFPContractAcrossStatement() {
    setFPContractMode(LangOptions::FPM_Fast);
  }

  bool isFPConstrained() const {
    return getRoundingMode() !=
               static_cast<unsigned>(RoundingMode::NearestTiesToEven) ||
           getFPExceptionMode() != LangOptions::FPE_Ignore ||
           getAllowFEnvAccess();
  }

  bool operator==(FPOptions other) const { return Value == other.Value; }

  /// Return the default value of FPOptions that's used when trailing
  /// storage isn't required.
  static FPOptions defaultWithoutTrailingStorage(const LangOptions &LO);

  storage_type getAsOpaqueInt() const { return Value; }
  void getFromOpaqueInt(storage_type value) { Value = value; }

  // We can define most of the accessors automatically:
#define OPTION(NAME, TYPE, WIDTH, PREVIOUS)                                    \
  unsigned get##NAME() const {                                                 \
    return static_cast<unsigned>(TYPE((Value & NAME##Mask) >> NAME##Shift));   \
  }                                                                            \
  void set##NAME(TYPE value) {                                                 \
    Value = (Value & ~NAME##Mask) | (storage_type(value) << NAME##Shift);      \
  }
#include "clang/Basic/FPOptions.def"
  LLVM_DUMP_METHOD void dump();
};

/// Represents difference between two FPOptions values.
///
/// The effect of language constructs changing the set of floating point options
/// is usually a change of some FP properties while leaving others intact. This
/// class describes such changes by keeping information about what FP options
/// are overridden.
///
/// The integral set of FP options, described by the class FPOptions, may be
/// represented as a default FP option set, defined by language standard and
/// command line options, with the overrides introduced by pragmas.
///
/// The is implemented as a value of the new FPOptions plus a mask showing which
/// fields are actually set in it.
class FPOptionsOverride {
  FPOptions Options;
  FPOptions::storage_type OverrideMask = 0;

public:
  using RoundingMode = llvm::RoundingMode;

  /// The type suitable for storing values of FPOptionsOverride. Must be twice
  /// as wide as bit size of FPOption.
  using storage_type = uint32_t;
  static_assert(sizeof(storage_type) >= 2 * sizeof(FPOptions::storage_type),
                "Too short type for FPOptionsOverride");

  /// Bit mask selecting bits of OverrideMask in serialized representation of
  /// FPOptionsOverride.
  static constexpr storage_type OverrideMaskBits =
      (static_cast<storage_type>(1) << FPOptions::StorageBitSize) - 1;

  FPOptionsOverride() {}
  FPOptionsOverride(FPOptions::storage_type Value, FPOptions::storage_type Mask)
      : Options(Value), OverrideMask(Mask) {}
  FPOptionsOverride(const LangOptions &LO)
      : Options(LO), OverrideMask(OverrideMaskBits) {}

  // Used for serializing.
  explicit FPOptionsOverride(storage_type I) { getFromOpaqueInt(I); }

  bool requiresTrailingStorage() const { return OverrideMask != 0; }

  void setAllowFPContractWithinStatement() {
    setFPContractModeOverride(LangOptions::FPM_On);
  }

  void setAllowFPContractAcrossStatement() {
    setFPContractModeOverride(LangOptions::FPM_Fast);
  }

  void setDisallowFPContract() {
    setFPContractModeOverride(LangOptions::FPM_Off);
  }

  void setFPPreciseEnabled(bool Value) {
    setAllowFPReassociateOverride(!Value);
    setNoHonorNaNsOverride(!Value);
    setNoHonorInfsOverride(!Value);
    setNoSignedZeroOverride(!Value);
    setAllowReciprocalOverride(!Value);
    setAllowApproxFuncOverride(!Value);
    if (Value)
      /* Precise mode implies fp_contract=on and disables ffast-math */
      setAllowFPContractWithinStatement();
    else
      /* Precise mode disabled sets fp_contract=fast and enables ffast-math */
      setAllowFPContractAcrossStatement();
  }

  storage_type getAsOpaqueInt() const {
    return (static_cast<storage_type>(Options.getAsOpaqueInt())
            << FPOptions::StorageBitSize) |
           OverrideMask;
  }
  void getFromOpaqueInt(storage_type I) {
    OverrideMask = I & OverrideMaskBits;
    Options.getFromOpaqueInt(I >> FPOptions::StorageBitSize);
  }

  FPOptions applyOverrides(FPOptions Base) {
    FPOptions Result((Base.getAsOpaqueInt() & ~OverrideMask) |
                     (Options.getAsOpaqueInt() & OverrideMask));
    return Result;
  }

  FPOptions applyOverrides(const LangOptions &LO) {
    return applyOverrides(FPOptions(LO));
  }

  bool operator==(FPOptionsOverride other) const {
    return Options == other.Options && OverrideMask == other.OverrideMask;
  }
  bool operator!=(FPOptionsOverride other) const { return !(*this == other); }

#define OPTION(NAME, TYPE, WIDTH, PREVIOUS)                                    \
  bool has##NAME##Override() const {                                           \
    return OverrideMask & FPOptions::NAME##Mask;                               \
  }                                                                            \
  unsigned get##NAME##Override() const {                                       \
    assert(has##NAME##Override());                                             \
    return Options.get##NAME();                                                \
  }                                                                            \
  void clear##NAME##Override() {                                               \
    /* Clear the actual value so that we don't have spurious differences when  \
     * testing equality. */                                                    \
    Options.set##NAME(TYPE(0));                                                \
    OverrideMask &= ~FPOptions::NAME##Mask;                                    \
  }                                                                            \
  void set##NAME##Override(TYPE value) {                                       \
    Options.set##NAME(value);                                                  \
    OverrideMask |= FPOptions::NAME##Mask;                                     \
  }
#include "clang/Basic/FPOptions.def"
  LLVM_DUMP_METHOD void dump();
};

/// Describes the kind of translation unit being processed.
enum TranslationUnitKind {
  /// The translation unit is a complete translation unit.
  TU_Complete,

  /// The translation unit is a prefix to a translation unit, and is
  /// not complete.
  TU_Prefix,

  /// The translation unit is a module.
  TU_Module
};

} // namespace clang

#endif // LLVM_CLANG_BASIC_LANGOPTIONS_H
