//===- lib/MC/MCObjectStreamer.cpp - Object File MCStreamer Interface -----===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "llvm/MC/MCObjectStreamer.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/MC/MCAsmBackend.h"
#include "llvm/MC/MCAssembler.h"
#include "llvm/MC/MCCodeEmitter.h"
#include "llvm/MC/MCCodeView.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCDwarf.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCObjectWriter.h"
#include "llvm/MC/MCSection.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/SourceMgr.h"
using namespace llvm;

MCObjectStreamer::MCObjectStreamer(MCContext &Context,
                                   std::unique_ptr<MCAsmBackend> TAB,
                                   std::unique_ptr<MCObjectWriter> OW,
                                   std::unique_ptr<MCCodeEmitter> Emitter)
    : MCStreamer(Context),
      Assembler(std::make_unique<MCAssembler>(
          Context, std::move(TAB), std::move(Emitter), std::move(OW))),
      EmitEHFrame(true), EmitDebugFrame(false) {
  if (Assembler->getBackendPtr())
    setAllowAutoPadding(Assembler->getBackend().allowAutoPadding());
}

MCObjectStreamer::~MCObjectStreamer() {}

// AssemblerPtr is used for evaluation of expressions and causes
// difference between asm and object outputs. Return nullptr to in
// inline asm mode to limit divergence to assembly inputs.
MCAssembler *MCObjectStreamer::getAssemblerPtr() {
  if (getUseAssemblerInfoForParsing())
    return Assembler.get();
  return nullptr;
}

void MCObjectStreamer::addPendingLabel(MCSymbol* S) {
  MCSection *CurSection = getCurrentSectionOnly();
  if (CurSection) {
    // Register labels that have not yet been assigned to a Section.
    if (!PendingLabels.empty()) {
      for (MCSymbol* Sym : PendingLabels)
        CurSection->addPendingLabel(Sym);
      PendingLabels.clear();
    }

    // Add this label to the current Section / Subsection.
    CurSection->addPendingLabel(S, CurSubsectionIdx);

    // Add this Section to the list of PendingLabelSections.
    auto SecIt = std::find(PendingLabelSections.begin(),
                           PendingLabelSections.end(), CurSection);
    if (SecIt == PendingLabelSections.end())
      PendingLabelSections.push_back(CurSection);
  }
  else
    // There is no Section / Subsection for this label yet.
    PendingLabels.push_back(S);
}

void MCObjectStreamer::flushPendingLabels(MCFragment *F, uint64_t FOffset) {
  MCSection *CurSection = getCurrentSectionOnly();
  if (!CurSection) {
    assert(PendingLabels.empty());
    return;
  }
  // Register labels that have not yet been assigned to a Section.
  if (!PendingLabels.empty()) {
    for (MCSymbol* Sym : PendingLabels)
      CurSection->addPendingLabel(Sym, CurSubsectionIdx);
    PendingLabels.clear();
  }

  // Associate a fragment with this label, either the supplied fragment
  // or an empty data fragment.
  if (F)
    CurSection->flushPendingLabels(F, FOffset, CurSubsectionIdx);
  else
    CurSection->flushPendingLabels(nullptr, 0, CurSubsectionIdx);
}

void MCObjectStreamer::flushPendingLabels() {
  // Register labels that have not yet been assigned to a Section.
  if (!PendingLabels.empty()) {
    MCSection *CurSection = getCurrentSectionOnly();
    assert(CurSection);
    for (MCSymbol* Sym : PendingLabels)
      CurSection->addPendingLabel(Sym, CurSubsectionIdx);
    PendingLabels.clear();
  }

  // Assign an empty data fragment to all remaining pending labels.
  for (MCSection* Section : PendingLabelSections)
    Section->flushPendingLabels();
}

// When fixup's offset is a forward declared label, e.g.:
//
//   .reloc 1f, R_MIPS_JALR, foo
// 1: nop
//
// postpone adding it to Fixups vector until the label is defined and its offset
// is known.
void MCObjectStreamer::resolvePendingFixups() {
  for (PendingMCFixup &PendingFixup : PendingFixups) {
    if (!PendingFixup.Sym || PendingFixup.Sym->isUndefined ()) {
      getContext().reportError(PendingFixup.Fixup.getLoc(),
                               "unresolved relocation offset");
      continue;
    }
    flushPendingLabels(PendingFixup.DF, PendingFixup.DF->getContents().size());
    PendingFixup.Fixup.setOffset(PendingFixup.Sym->getOffset());
    PendingFixup.DF->getFixups().push_back(PendingFixup.Fixup);
  }
  PendingFixups.clear();
}

// As a compile-time optimization, avoid allocating and evaluating an MCExpr
// tree for (Hi - Lo) when Hi and Lo are offsets into the same fragment.
static Optional<uint64_t>
absoluteSymbolDiff(MCAssembler &Asm, const MCSymbol *Hi, const MCSymbol *Lo) {
  assert(Hi && Lo);
  if (Asm.getBackendPtr()->requiresDiffExpressionRelocations())
    return None;

  if (!Hi->getFragment() || Hi->getFragment() != Lo->getFragment() ||
      Hi->isVariable() || Lo->isVariable())
    return None;

  return Hi->getOffset() - Lo->getOffset();
}

void MCObjectStreamer::emitAbsoluteSymbolDiff(const MCSymbol *Hi,
                                              const MCSymbol *Lo,
                                              unsigned Size) {
  if (Optional<uint64_t> Diff = absoluteSymbolDiff(getAssembler(), Hi, Lo)) {
    emitIntValue(*Diff, Size);
    return;
  }
  MCStreamer::emitAbsoluteSymbolDiff(Hi, Lo, Size);
}

void MCObjectStreamer::emitAbsoluteSymbolDiffAsULEB128(const MCSymbol *Hi,
                                                       const MCSymbol *Lo) {
  if (Optional<uint64_t> Diff = absoluteSymbolDiff(getAssembler(), Hi, Lo)) {
    emitULEB128IntValue(*Diff);
    return;
  }
  MCStreamer::emitAbsoluteSymbolDiffAsULEB128(Hi, Lo);
}

void MCObjectStreamer::reset() {
  if (Assembler)
    Assembler->reset();
  CurInsertionPoint = MCSection::iterator();
  EmitEHFrame = true;
  EmitDebugFrame = false;
  PendingLabels.clear();
  PendingLabelSections.clear();
  MCStreamer::reset();
}

void MCObjectStreamer::EmitFrames(MCAsmBackend *MAB) {
  if (!getNumFrameInfos())
    return;

  if (EmitEHFrame)
    MCDwarfFrameEmitter::Emit(*this, MAB, true);

  if (EmitDebugFrame)
    MCDwarfFrameEmitter::Emit(*this, MAB, false);
}

MCFragment *MCObjectStreamer::getCurrentFragment() const {
  assert(getCurrentSectionOnly() && "No current section!");

  if (CurInsertionPoint != getCurrentSectionOnly()->getFragmentList().begin())
    return &*std::prev(CurInsertionPoint);

  return nullptr;
}

static bool CanReuseDataFragment(const MCDataFragment &F,
                                 const MCAssembler &Assembler,
                                 const MCSubtargetInfo *STI) {
  if (!F.hasInstructions())
    return true;
  // When bundling is enabled, we don't want to add data to a fragment that
  // already has instructions (see MCELFStreamer::EmitInstToData for details)
  if (Assembler.isBundlingEnabled())
    return Assembler.getRelaxAll();
  // If the subtarget is changed mid fragment we start a new fragment to record
  // the new STI.
  return !STI || F.getSubtargetInfo() == STI;
}

MCDataFragment *
MCObjectStreamer::getOrCreateDataFragment(const MCSubtargetInfo *STI) {
  MCDataFragment *F = dyn_cast_or_null<MCDataFragment>(getCurrentFragment());
  if (!F || !CanReuseDataFragment(*F, *Assembler, STI)) {
    F = new MCDataFragment();
    insert(F);
  }
  return F;
}

void MCObjectStreamer::visitUsedSymbol(const MCSymbol &Sym) {
  Assembler->registerSymbol(Sym);
}

void MCObjectStreamer::emitCFISections(bool EH, bool Debug) {
  MCStreamer::emitCFISections(EH, Debug);
  EmitEHFrame = EH;
  EmitDebugFrame = Debug;
}

void MCObjectStreamer::emitValueImpl(const MCExpr *Value, unsigned Size,
                                     SMLoc Loc) {
  MCStreamer::emitValueImpl(Value, Size, Loc);
  MCDataFragment *DF = getOrCreateDataFragment();
  flushPendingLabels(DF, DF->getContents().size());

  MCDwarfLineEntry::Make(this, getCurrentSectionOnly());

  // Avoid fixups when possible.
  int64_t AbsValue;
  if (Value->evaluateAsAbsolute(AbsValue, getAssemblerPtr())) {
    if (!isUIntN(8 * Size, AbsValue) && !isIntN(8 * Size, AbsValue)) {
      getContext().reportError(
          Loc, "value evaluated as " + Twine(AbsValue) + " is out of range.");
      return;
    }
    emitIntValue(AbsValue, Size);
    return;
  }
  DF->getFixups().push_back(
      MCFixup::create(DF->getContents().size(), Value,
                      MCFixup::getKindForSize(Size, false), Loc));
  DF->getContents().resize(DF->getContents().size() + Size, 0);
}

MCSymbol *MCObjectStreamer::emitCFILabel() {
  MCSymbol *Label = getContext().createTempSymbol("cfi", true);
  emitLabel(Label);
  return Label;
}

void MCObjectStreamer::emitCFIStartProcImpl(MCDwarfFrameInfo &Frame) {
  // We need to create a local symbol to avoid relocations.
  Frame.Begin = getContext().createTempSymbol();
  emitLabel(Frame.Begin);
}

void MCObjectStreamer::emitCFIEndProcImpl(MCDwarfFrameInfo &Frame) {
  Frame.End = getContext().createTempSymbol();
  emitLabel(Frame.End);
}

void MCObjectStreamer::emitLabel(MCSymbol *Symbol, SMLoc Loc) {
  MCStreamer::emitLabel(Symbol, Loc);

  getAssembler().registerSymbol(*Symbol);

  // If there is a current fragment, mark the symbol as pointing into it.
  // Otherwise queue the label and set its fragment pointer when we emit the
  // next fragment.
  auto *F = dyn_cast_or_null<MCDataFragment>(getCurrentFragment());
  if (F && !(getAssembler().isBundlingEnabled() &&
             getAssembler().getRelaxAll())) {
    Symbol->setFragment(F);
    Symbol->setOffset(F->getContents().size());
  } else {
    // Assign all pending labels to offset 0 within the dummy "pending"
    // fragment. (They will all be reassigned to a real fragment in
    // flushPendingLabels())
    Symbol->setOffset(0);
    addPendingLabel(Symbol);
  }
}

// Emit a label at a previously emitted fragment/offset position. This must be
// within the currently-active section.
void MCObjectStreamer::emitLabelAtPos(MCSymbol *Symbol, SMLoc Loc,
                                      MCFragment *F, uint64_t Offset) {
  assert(F->getParent() == getCurrentSectionOnly());

  MCStreamer::emitLabel(Symbol, Loc);
  getAssembler().registerSymbol(*Symbol);
  auto *DF = dyn_cast_or_null<MCDataFragment>(F);
  Symbol->setOffset(Offset);
  if (DF) {
    Symbol->setFragment(F);
  } else {
    assert(isa<MCDummyFragment>(F) &&
           "F must either be an MCDataFragment or the pending MCDummyFragment");
    assert(Offset == 0);
    addPendingLabel(Symbol);
  }
}

void MCObjectStreamer::emitULEB128Value(const MCExpr *Value) {
  int64_t IntValue;
  if (Value->evaluateAsAbsolute(IntValue, getAssemblerPtr())) {
    emitULEB128IntValue(IntValue);
    return;
  }
  insert(new MCLEBFragment(*Value, false));
}

void MCObjectStreamer::emitSLEB128Value(const MCExpr *Value) {
  int64_t IntValue;
  if (Value->evaluateAsAbsolute(IntValue, getAssemblerPtr())) {
    emitSLEB128IntValue(IntValue);
    return;
  }
  insert(new MCLEBFragment(*Value, true));
}

void MCObjectStreamer::emitWeakReference(MCSymbol *Alias,
                                         const MCSymbol *Symbol) {
  report_fatal_error("This file format doesn't support weak aliases.");
}

void MCObjectStreamer::ChangeSection(MCSection *Section,
                                     const MCExpr *Subsection) {
  changeSectionImpl(Section, Subsection);
}

bool MCObjectStreamer::changeSectionImpl(MCSection *Section,
                                         const MCExpr *Subsection) {
  assert(Section && "Cannot switch to a null section!");
  getContext().clearDwarfLocSeen();

  bool Created = getAssembler().registerSection(*Section);

  int64_t IntSubsection = 0;
  if (Subsection &&
      !Subsection->evaluateAsAbsolute(IntSubsection, getAssemblerPtr()))
    report_fatal_error("Cannot evaluate subsection number");
  if (IntSubsection < 0 || IntSubsection > 8192)
    report_fatal_error("Subsection number out of range");
  CurSubsectionIdx = unsigned(IntSubsection);
  CurInsertionPoint =
      Section->getSubsectionInsertionPoint(CurSubsectionIdx);
  return Created;
}

void MCObjectStreamer::emitAssignment(MCSymbol *Symbol, const MCExpr *Value) {
  getAssembler().registerSymbol(*Symbol);
  MCStreamer::emitAssignment(Symbol, Value);
}

bool MCObjectStreamer::mayHaveInstructions(MCSection &Sec) const {
  return Sec.hasInstructions();
}

void MCObjectStreamer::emitInstruction(const MCInst &Inst,
                                       const MCSubtargetInfo &STI) {
  getAssembler().getBackend().alignBranchesBegin(*this, Inst);
  emitInstructionImpl(Inst, STI);
  getAssembler().getBackend().alignBranchesEnd(*this, Inst);
}

void MCObjectStreamer::emitInstructionImpl(const MCInst &Inst,
                                           const MCSubtargetInfo &STI) {
  MCStreamer::emitInstruction(Inst, STI);

  MCSection *Sec = getCurrentSectionOnly();
  Sec->setHasInstructions(true);

  // Now that a machine instruction has been assembled into this section, make
  // a line entry for any .loc directive that has been seen.
  MCDwarfLineEntry::Make(this, getCurrentSectionOnly());

  // If this instruction doesn't need relaxation, just emit it as data.
  MCAssembler &Assembler = getAssembler();
  if (!Assembler.getBackend().mayNeedRelaxation(Inst, STI)) {
    EmitInstToData(Inst, STI);
    return;
  }

  // Otherwise, relax and emit it as data if either:
  // - The RelaxAll flag was passed
  // - Bundling is enabled and this instruction is inside a bundle-locked
  //   group. We want to emit all such instructions into the same data
  //   fragment.
  if (Assembler.getRelaxAll() ||
      (Assembler.isBundlingEnabled() && Sec->isBundleLocked())) {
    MCInst Relaxed;
    getAssembler().getBackend().relaxInstruction(Inst, STI, Relaxed);
    while (getAssembler().getBackend().mayNeedRelaxation(Relaxed, STI))
      getAssembler().getBackend().relaxInstruction(Relaxed, STI, Relaxed);
    EmitInstToData(Relaxed, STI);
    return;
  }

  // Otherwise emit to a separate fragment.
  EmitInstToFragment(Inst, STI);
}

void MCObjectStreamer::EmitInstToFragment(const MCInst &Inst,
                                          const MCSubtargetInfo &STI) {
  if (getAssembler().getRelaxAll() && getAssembler().isBundlingEnabled())
    llvm_unreachable("All instructions should have already been relaxed");

  // Always create a new, separate fragment here, because its size can change
  // during relaxation.
  MCRelaxableFragment *IF = new MCRelaxableFragment(Inst, STI);
  insert(IF);

  SmallString<128> Code;
  raw_svector_ostream VecOS(Code);
  getAssembler().getEmitter().encodeInstruction(Inst, VecOS, IF->getFixups(),
                                                STI);
  IF->getContents().append(Code.begin(), Code.end());
}

#ifndef NDEBUG
static const char *const BundlingNotImplementedMsg =
  "Aligned bundling is not implemented for this object format";
#endif

void MCObjectStreamer::emitBundleAlignMode(unsigned AlignPow2) {
  llvm_unreachable(BundlingNotImplementedMsg);
}

void MCObjectStreamer::emitBundleLock(bool AlignToEnd) {
  llvm_unreachable(BundlingNotImplementedMsg);
}

void MCObjectStreamer::emitBundleUnlock() {
  llvm_unreachable(BundlingNotImplementedMsg);
}

void MCObjectStreamer::emitDwarfLocDirective(unsigned FileNo, unsigned Line,
                                             unsigned Column, unsigned Flags,
                                             unsigned Isa,
                                             unsigned Discriminator,
                                             StringRef FileName) {
  // In case we see two .loc directives in a row, make sure the
  // first one gets a line entry.
  MCDwarfLineEntry::Make(this, getCurrentSectionOnly());

  this->MCStreamer::emitDwarfLocDirective(FileNo, Line, Column, Flags, Isa,
                                          Discriminator, FileName);
}

static const MCExpr *buildSymbolDiff(MCObjectStreamer &OS, const MCSymbol *A,
                                     const MCSymbol *B) {
  MCContext &Context = OS.getContext();
  MCSymbolRefExpr::VariantKind Variant = MCSymbolRefExpr::VK_None;
  const MCExpr *ARef = MCSymbolRefExpr::create(A, Variant, Context);
  const MCExpr *BRef = MCSymbolRefExpr::create(B, Variant, Context);
  const MCExpr *AddrDelta =
      MCBinaryExpr::create(MCBinaryExpr::Sub, ARef, BRef, Context);
  return AddrDelta;
}

static void emitDwarfSetLineAddr(MCObjectStreamer &OS,
                                 MCDwarfLineTableParams Params,
                                 int64_t LineDelta, const MCSymbol *Label,
                                 int PointerSize) {
  // emit the sequence to set the address
  OS.emitIntValue(dwarf::DW_LNS_extended_op, 1);
  OS.emitULEB128IntValue(PointerSize + 1);
  OS.emitIntValue(dwarf::DW_LNE_set_address, 1);
  OS.emitSymbolValue(Label, PointerSize);

  // emit the sequence for the LineDelta (from 1) and a zero address delta.
  MCDwarfLineAddr::Emit(&OS, Params, LineDelta, 0);
}

void MCObjectStreamer::emitDwarfAdvanceLineAddr(int64_t LineDelta,
                                                const MCSymbol *LastLabel,
                                                const MCSymbol *Label,
                                                unsigned PointerSize) {
  if (!LastLabel) {
    emitDwarfSetLineAddr(*this, Assembler->getDWARFLinetableParams(), LineDelta,
                         Label, PointerSize);
    return;
  }
  const MCExpr *AddrDelta = buildSymbolDiff(*this, Label, LastLabel);
  int64_t Res;
  if (AddrDelta->evaluateAsAbsolute(Res, getAssemblerPtr())) {
    MCDwarfLineAddr::Emit(this, Assembler->getDWARFLinetableParams(), LineDelta,
                          Res);
    return;
  }
  insert(new MCDwarfLineAddrFragment(LineDelta, *AddrDelta));
}

void MCObjectStreamer::emitDwarfAdvanceFrameAddr(const MCSymbol *LastLabel,
                                                 const MCSymbol *Label) {
  const MCExpr *AddrDelta = buildSymbolDiff(*this, Label, LastLabel);
  int64_t Res;
  if (AddrDelta->evaluateAsAbsolute(Res, getAssemblerPtr())) {
    MCDwarfFrameEmitter::EmitAdvanceLoc(*this, Res);
    return;
  }
  insert(new MCDwarfCallFrameFragment(*AddrDelta));
}

void MCObjectStreamer::EmitCVLocDirective(unsigned FunctionId, unsigned FileNo,
                                          unsigned Line, unsigned Column,
                                          bool PrologueEnd, bool IsStmt,
                                          StringRef FileName, SMLoc Loc) {
  // Validate the directive.
  if (!checkCVLocSection(FunctionId, FileNo, Loc))
    return;

  // Emit a label at the current position and record it in the CodeViewContext.
  MCSymbol *LineSym = getContext().createTempSymbol();
  emitLabel(LineSym);
  getContext().getCVContext().recordCVLoc(getContext(), LineSym, FunctionId,
                                          FileNo, Line, Column, PrologueEnd,
                                          IsStmt);
}

void MCObjectStreamer::EmitCVLinetableDirective(unsigned FunctionId,
                                                const MCSymbol *Begin,
                                                const MCSymbol *End) {
  getContext().getCVContext().emitLineTableForFunction(*this, FunctionId, Begin,
                                                       End);
  this->MCStreamer::EmitCVLinetableDirective(FunctionId, Begin, End);
}

void MCObjectStreamer::EmitCVInlineLinetableDirective(
    unsigned PrimaryFunctionId, unsigned SourceFileId, unsigned SourceLineNum,
    const MCSymbol *FnStartSym, const MCSymbol *FnEndSym) {
  getContext().getCVContext().emitInlineLineTableForFunction(
      *this, PrimaryFunctionId, SourceFileId, SourceLineNum, FnStartSym,
      FnEndSym);
  this->MCStreamer::EmitCVInlineLinetableDirective(
      PrimaryFunctionId, SourceFileId, SourceLineNum, FnStartSym, FnEndSym);
}

void MCObjectStreamer::EmitCVDefRangeDirective(
    ArrayRef<std::pair<const MCSymbol *, const MCSymbol *>> Ranges,
    StringRef FixedSizePortion) {
  MCFragment *Frag =
      getContext().getCVContext().emitDefRange(*this, Ranges, FixedSizePortion);
  // Attach labels that were pending before we created the defrange fragment to
  // the beginning of the new fragment.
  flushPendingLabels(Frag, 0);
  this->MCStreamer::EmitCVDefRangeDirective(Ranges, FixedSizePortion);
}

void MCObjectStreamer::EmitCVStringTableDirective() {
  getContext().getCVContext().emitStringTable(*this);
}
void MCObjectStreamer::EmitCVFileChecksumsDirective() {
  getContext().getCVContext().emitFileChecksums(*this);
}

void MCObjectStreamer::EmitCVFileChecksumOffsetDirective(unsigned FileNo) {
  getContext().getCVContext().emitFileChecksumOffset(*this, FileNo);
}

void MCObjectStreamer::emitBytes(StringRef Data) {
  MCDwarfLineEntry::Make(this, getCurrentSectionOnly());
  MCDataFragment *DF = getOrCreateDataFragment();
  flushPendingLabels(DF, DF->getContents().size());
  DF->getContents().append(Data.begin(), Data.end());
}

void MCObjectStreamer::emitValueToAlignment(unsigned ByteAlignment,
                                            int64_t Value,
                                            unsigned ValueSize,
                                            unsigned MaxBytesToEmit) {
  if (MaxBytesToEmit == 0)
    MaxBytesToEmit = ByteAlignment;
  insert(new MCAlignFragment(ByteAlignment, Value, ValueSize, MaxBytesToEmit));

  // Update the maximum alignment on the current section if necessary.
  MCSection *CurSec = getCurrentSectionOnly();
  if (ByteAlignment > CurSec->getAlignment())
    CurSec->setAlignment(Align(ByteAlignment));
}

void MCObjectStreamer::emitCodeAlignment(unsigned ByteAlignment,
                                         unsigned MaxBytesToEmit) {
  emitValueToAlignment(ByteAlignment, 0, 1, MaxBytesToEmit);
  cast<MCAlignFragment>(getCurrentFragment())->setEmitNops(true);
}

void MCObjectStreamer::emitValueToOffset(const MCExpr *Offset,
                                         unsigned char Value,
                                         SMLoc Loc) {
  insert(new MCOrgFragment(*Offset, Value, Loc));
}

void MCObjectStreamer::emitCapInit(const MCExpr *Value) {
  MCStreamer::emitValueImpl(Value, 16);
  MCDataFragment *DF = getOrCreateDataFragment();
  flushPendingLabels(DF, DF->getContents().size());
  // Don't resize this, the user will emit the data.
  DF->getFixups().push_back(MCFixup::create(DF->getContents().size(),
                                            Value, FK_Data_8));
}

// Associate DTPRel32 fixup with data and resize data area
void MCObjectStreamer::emitDTPRel32Value(const MCExpr *Value) {
  MCDataFragment *DF = getOrCreateDataFragment();
  flushPendingLabels(DF, DF->getContents().size());

  DF->getFixups().push_back(MCFixup::create(DF->getContents().size(),
                                            Value, FK_DTPRel_4));
  DF->getContents().resize(DF->getContents().size() + 4, 0);
}

// Associate DTPRel64 fixup with data and resize data area
void MCObjectStreamer::emitDTPRel64Value(const MCExpr *Value) {
  MCDataFragment *DF = getOrCreateDataFragment();
  flushPendingLabels(DF, DF->getContents().size());

  DF->getFixups().push_back(MCFixup::create(DF->getContents().size(),
                                            Value, FK_DTPRel_8));
  DF->getContents().resize(DF->getContents().size() + 8, 0);
}

// Associate TPRel32 fixup with data and resize data area
void MCObjectStreamer::emitTPRel32Value(const MCExpr *Value) {
  MCDataFragment *DF = getOrCreateDataFragment();
  flushPendingLabels(DF, DF->getContents().size());

  DF->getFixups().push_back(MCFixup::create(DF->getContents().size(),
                                            Value, FK_TPRel_4));
  DF->getContents().resize(DF->getContents().size() + 4, 0);
}

// Associate TPRel64 fixup with data and resize data area
void MCObjectStreamer::emitTPRel64Value(const MCExpr *Value) {
  MCDataFragment *DF = getOrCreateDataFragment();
  flushPendingLabels(DF, DF->getContents().size());

  DF->getFixups().push_back(MCFixup::create(DF->getContents().size(),
                                            Value, FK_TPRel_8));
  DF->getContents().resize(DF->getContents().size() + 8, 0);
}

// Associate GPRel32 fixup with data and resize data area
void MCObjectStreamer::emitGPRel32Value(const MCExpr *Value) {
  MCDataFragment *DF = getOrCreateDataFragment();
  flushPendingLabels(DF, DF->getContents().size());

  DF->getFixups().push_back(
      MCFixup::create(DF->getContents().size(), Value, FK_GPRel_4));
  DF->getContents().resize(DF->getContents().size() + 4, 0);
}

// Associate GPRel64 fixup with data and resize data area
void MCObjectStreamer::emitGPRel64Value(const MCExpr *Value) {
  MCDataFragment *DF = getOrCreateDataFragment();
  flushPendingLabels(DF, DF->getContents().size());

  DF->getFixups().push_back(
      MCFixup::create(DF->getContents().size(), Value, FK_GPRel_4));
  DF->getContents().resize(DF->getContents().size() + 8, 0);
}

bool MCObjectStreamer::emitRelocDirective(const MCExpr &Offset, StringRef Name,
                                          const MCExpr *Expr, SMLoc Loc,
                                          const MCSubtargetInfo &STI) {
  Optional<MCFixupKind> MaybeKind = Assembler->getBackend().getFixupKind(Name);
  if (!MaybeKind.hasValue())
    return true;

  MCFixupKind Kind = *MaybeKind;

  if (Expr == nullptr)
    Expr =
        MCSymbolRefExpr::create(getContext().createTempSymbol(), getContext());

  MCDataFragment *DF = getOrCreateDataFragment(&STI);
  flushPendingLabels(DF, DF->getContents().size());

  int64_t OffsetValue;
  if (Offset.evaluateAsAbsolute(OffsetValue)) {
    if (OffsetValue < 0)
      llvm_unreachable(".reloc offset is negative");
    DF->getFixups().push_back(MCFixup::create(OffsetValue, Expr, Kind, Loc));
    return false;
  }

  if (Offset.getKind() != llvm::MCExpr::SymbolRef)
    llvm_unreachable(".reloc offset is not absolute nor a label");

  const MCSymbolRefExpr &SRE = cast<MCSymbolRefExpr>(Offset);
  if (SRE.getSymbol().isDefined()) {
    DF->getFixups().push_back(MCFixup::create(SRE.getSymbol().getOffset(),
                                              Expr, Kind, Loc));
    return false;
  }

  PendingFixups.emplace_back(&SRE.getSymbol(), DF,
                                         MCFixup::create(-1, Expr, Kind, Loc));
  return false;
}

void MCObjectStreamer::emitFill(const MCExpr &NumBytes, uint64_t FillValue,
                                SMLoc Loc) {
  MCDataFragment *DF = getOrCreateDataFragment();
  flushPendingLabels(DF, DF->getContents().size());

  assert(getCurrentSectionOnly() && "need a section");
  insert(new MCFillFragment(FillValue, 1, NumBytes, Loc));
}

void MCObjectStreamer::emitFill(const MCExpr &NumValues, int64_t Size,
                                int64_t Expr, SMLoc Loc) {
  int64_t IntNumValues;
  // Do additional checking now if we can resolve the value.
  if (NumValues.evaluateAsAbsolute(IntNumValues, getAssemblerPtr())) {
    if (IntNumValues < 0) {
      getContext().getSourceManager()->PrintMessage(
          Loc, SourceMgr::DK_Warning,
          "'.fill' directive with negative repeat count has no effect");
      return;
    }
    // Emit now if we can for better errors.
    int64_t NonZeroSize = Size > 4 ? 4 : Size;
    Expr &= ~0ULL >> (64 - NonZeroSize * 8);
    for (uint64_t i = 0, e = IntNumValues; i != e; ++i) {
      emitIntValue(Expr, NonZeroSize);
      if (NonZeroSize < Size)
        emitIntValue(0, Size - NonZeroSize);
    }
    return;
  }

  // Otherwise emit as fragment.
  MCDataFragment *DF = getOrCreateDataFragment();
  flushPendingLabels(DF, DF->getContents().size());

  assert(getCurrentSectionOnly() && "need a section");
  insert(new MCFillFragment(Expr, Size, NumValues, Loc));
}

void MCObjectStreamer::emitFileDirective(StringRef Filename) {
  getAssembler().addFileName(Filename);
}

void MCObjectStreamer::emitAddrsig() {
  getAssembler().getWriter().emitAddrsigSection();
}

void MCObjectStreamer::emitAddrsigSym(const MCSymbol *Sym) {
  getAssembler().registerSymbol(*Sym);
  getAssembler().getWriter().addAddrsigSymbol(Sym);
}

void MCObjectStreamer::FinishImpl() {
  getContext().RemapDebugPaths();

  // If we are generating dwarf for assembly source files dump out the sections.
  if (getContext().getGenDwarfForAssembly())
    MCGenDwarfInfo::Emit(this);

  // Dump out the dwarf file & directory tables and line tables.
  MCDwarfLineTable::Emit(this, getAssembler().getDWARFLinetableParams());

  // Update any remaining pending labels with empty data fragments.
  flushPendingLabels();

  resolvePendingFixups();
  getAssembler().Finish();
}
