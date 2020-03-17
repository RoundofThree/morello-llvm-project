//===--- AArch64.h - Declare AArch64 target feature support -----*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file declares AArch64 TargetInfo objects.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CLANG_LIB_BASIC_TARGETS_AARCH64_H
#define LLVM_CLANG_LIB_BASIC_TARGETS_AARCH64_H

#include "OSTargets.h"
#include "clang/Basic/TargetBuiltins.h"
#include "llvm/Support/TargetParser.h"

namespace clang {
namespace targets {

class LLVM_LIBRARY_VISIBILITY AArch64TargetInfo : public TargetInfo {
  virtual void setDataLayout() = 0;
  static const TargetInfo::GCCRegAlias GCCRegAliases[];
  static const char *const GCCRegNames[];

  enum FPUModeEnum { FPUMode, NeonMode = (1 << 0), SveMode = (1 << 1) };

  unsigned FPU;
  bool HasCRC;
  bool HasCrypto;
  bool HasUnaligned;
  bool HasFullFP16;
  bool HasDotProd;
  bool HasFP16FML;
  bool HasMTE;
  bool HasTME;

  llvm::AArch64::ArchKind ArchKind;

  bool Morello;
  bool C64;
  const unsigned CapSize;

  static const Builtin::Info BuiltinInfo[];

  std::string ABI;

public:
  AArch64TargetInfo(const llvm::Triple &Triple, const TargetOptions &Opts);

  StringRef getABI() const override;
  bool setABI(const std::string &Name) override;

  bool validateBranchProtection(StringRef, BranchProtectionInfo &,
                                StringRef &) const override;

  bool isValidCPUName(StringRef Name) const override;
  void fillValidCPUList(SmallVectorImpl<StringRef> &Values) const override;
  bool setCPU(const std::string &Name) override;

  bool useFP16ConversionIntrinsics() const override {
    return false;
  }

  void getTargetDefinesARMV81A(const LangOptions &Opts,
                               MacroBuilder &Builder) const;
  void getTargetDefinesARMV82A(const LangOptions &Opts,
                               MacroBuilder &Builder) const;
  void getTargetDefinesARMV83A(const LangOptions &Opts,
                               MacroBuilder &Builder) const;
  void getTargetDefinesARMV84A(const LangOptions &Opts,
                               MacroBuilder &Builder) const;
  void getTargetDefinesARMV85A(const LangOptions &Opts,
                               MacroBuilder &Builder) const;
  void getTargetDefines(const LangOptions &Opts,
                        MacroBuilder &Builder) const override;

  ArrayRef<Builtin::Info> getTargetBuiltins() const override;

  bool hasFeature(StringRef Feature) const override;
  bool handleTargetFeatures(std::vector<std::string> &Features,
                            DiagnosticsEngine &Diags) override;

  bool hasMorello() const { return Morello; }
  bool hasPureCap() const { return CapabilityABI; }
  bool hasCapabilities() const override { return Morello || C64; }
  bool hasC64() const { return C64; }
  unsigned getIntCapWidth() const override { return CapSize; }
  unsigned getIntCapAlign() const override { return CapSize; }
  unsigned getIntCapRange() const override { return 64; }
  uint64_t getCHERICapabilityWidth() const override { return CapSize; }
  uint64_t getCHERICapabilityAlign() const override { return CapSize; }
  uint64_t getPointerRangeForCHERICapability() const override { return 64; }

  Optional<unsigned>
  getDWARFAddressSpace(unsigned AddressSpace) const override {
    if (AddressSpace == 200)
      return 1;
    return None;
  }

  bool
  useXDerefForDWARFAddressSpace(unsigned DWARFAddressSpace) const override {
    // Do not use extended dereferencing mechanism for address spaces on
    // AArch64. The only used DWARF address space by this target is '1' which
    // indicates that the pointer/reference type is a capability. Xderef is not
    // needed for such a type.
    return false;
  }

  uint64_t getPointerWidthV(unsigned AddrSpace) const override {
    return (AddrSpace == 200) ? CapSize : PointerWidth;
  }
  uint64_t getPointerAlignV(unsigned AddrSpace) const override {
    return (AddrSpace == 200) ? CapSize : PointerAlign;
  }
  uint64_t getPointerRangeV(unsigned) const override { return 64; }

  bool SupportsCapabilities() const override { return Morello; }

  bool hasBuiltinAtomic(uint64_t AtomicSizeInBits,
                        uint64_t AlignmentInBits) const override {
    if (SupportsCapabilities() &&
        AtomicSizeInBits == getCHERICapabilityWidth() &&
        AlignmentInBits == getCHERICapabilityAlign()) {
      return true;
    }
    return TargetInfo::hasBuiltinAtomic(AtomicSizeInBits, AlignmentInBits);
  }

  CallingConvCheckResult checkCallingConvention(CallingConv CC) const override;

  bool isCLZForZeroUndef() const override;

  BuiltinVaListKind getBuiltinVaListKind() const override;

  ArrayRef<const char *> getGCCRegNames() const override;
  ArrayRef<TargetInfo::GCCRegAlias> getGCCRegAliases() const override;

  std::string convertConstraint(const char *&Constraint) const override {
    std::string R;
    switch (*Constraint) {
    case 'U': // Three-character constraint; add "@3" hint for later parsing.
      R = std::string("@3") + std::string(Constraint, 3);
      Constraint += 2;
      break;
    default:
      R = std::string(1, *Constraint);
      break;
    }
    return R;
  }

  bool validateAsmConstraint(const char *&Name,
                             TargetInfo::ConstraintInfo &Info) const override;
  bool
  validateConstraintModifier(StringRef Constraint, char Modifier, unsigned Size,
                             std::string &SuggestedModifier) const override;
  const char *getClobbers() const override;

  StringRef getConstraintRegister(StringRef Constraint,
                                  StringRef Expression) const override {
    return Expression;
  }

  int getEHDataRegisterNumber(unsigned RegNo) const override;

  bool hasInt128Type() const override;
};

class LLVM_LIBRARY_VISIBILITY AArch64leTargetInfo : public AArch64TargetInfo {
public:
  AArch64leTargetInfo(const llvm::Triple &Triple, const TargetOptions &Opts);

  void getTargetDefines(const LangOptions &Opts,
                            MacroBuilder &Builder) const override;
private:
  void setDataLayout() override;
};

class LLVM_LIBRARY_VISIBILITY WindowsARM64TargetInfo
    : public WindowsTargetInfo<AArch64leTargetInfo> {
  const llvm::Triple Triple;

public:
  WindowsARM64TargetInfo(const llvm::Triple &Triple,
                         const TargetOptions &Opts);

  void setDataLayout() override;

  BuiltinVaListKind getBuiltinVaListKind() const override;

  CallingConvCheckResult checkCallingConvention(CallingConv CC) const override;
};

// Windows ARM, MS (C++) ABI
class LLVM_LIBRARY_VISIBILITY MicrosoftARM64TargetInfo
    : public WindowsARM64TargetInfo {
public:
  MicrosoftARM64TargetInfo(const llvm::Triple &Triple,
                           const TargetOptions &Opts);

  void getTargetDefines(const LangOptions &Opts,
                        MacroBuilder &Builder) const override;
  TargetInfo::CallingConvKind
  getCallingConvKind(bool ClangABICompat4) const override;

  unsigned getMinGlobalAlign(uint64_t TypeSize) const override;
};

// ARM64 MinGW target
class LLVM_LIBRARY_VISIBILITY MinGWARM64TargetInfo
    : public WindowsARM64TargetInfo {
public:
  MinGWARM64TargetInfo(const llvm::Triple &Triple, const TargetOptions &Opts);
};

class LLVM_LIBRARY_VISIBILITY AArch64beTargetInfo : public AArch64TargetInfo {
public:
  AArch64beTargetInfo(const llvm::Triple &Triple, const TargetOptions &Opts);
  void getTargetDefines(const LangOptions &Opts,
                        MacroBuilder &Builder) const override;

private:
  void setDataLayout() override;
};

class LLVM_LIBRARY_VISIBILITY DarwinAArch64TargetInfo
    : public DarwinTargetInfo<AArch64leTargetInfo> {
public:
  DarwinAArch64TargetInfo(const llvm::Triple &Triple, const TargetOptions &Opts);

  BuiltinVaListKind getBuiltinVaListKind() const override;

 protected:
  void getOSDefines(const LangOptions &Opts, const llvm::Triple &Triple,
                    MacroBuilder &Builder) const override;
};

// 64-bit RenderScript is aarch64
class LLVM_LIBRARY_VISIBILITY RenderScript64TargetInfo
    : public AArch64leTargetInfo {
public:
  RenderScript64TargetInfo(const llvm::Triple &Triple,
                           const TargetOptions &Opts);

  void getTargetDefines(const LangOptions &Opts,
                        MacroBuilder &Builder) const override;
};

} // namespace targets
} // namespace clang

#endif // LLVM_CLANG_LIB_BASIC_TARGETS_AARCH64_H
