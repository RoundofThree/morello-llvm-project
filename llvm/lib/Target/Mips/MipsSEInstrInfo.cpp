//===-- MipsSEInstrInfo.cpp - Mips32/64 Instruction Information -----------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains the Mips32/64 implementation of the TargetInstrInfo class.
//
//===----------------------------------------------------------------------===//

#include "MipsSEInstrInfo.h"
#include "MCTargetDesc/MipsInstPrinter.h"
#include "MipsAnalyzeImmediate.h"
#include "MipsMachineFunction.h"
#include "MipsTargetMachine.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/MathExtras.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;

static unsigned getUnconditionalBranch(const MipsSubtarget &STI) {
  if (STI.inMicroMipsMode())
    return STI.isPositionIndependent() ? Mips::B_MM : Mips::J_MM;
  return STI.isPositionIndependent() ? Mips::B : Mips::J;
}

MipsSEInstrInfo::MipsSEInstrInfo(const MipsSubtarget &STI)
    : MipsInstrInfo(STI, getUnconditionalBranch(STI)), RI(STI) {}

const MipsRegisterInfo &MipsSEInstrInfo::getRegisterInfo() const {
  return RI;
}

/// isLoadFromStackSlot - If the specified machine instruction is a direct
/// load from a stack slot, return the virtual or physical register number of
/// the destination along with the FrameIndex of the loaded stack slot.  If
/// not, return 0.  This predicate must return 0 if the instruction has
/// any side effects other than loading from the stack slot.
unsigned MipsSEInstrInfo::isLoadFromStackSlot(const MachineInstr &MI,
                                              int &FrameIndex) const {
  if (MI.mayLoad()) { // Is a load...
    if ((MI.getOperand(1).isFI()) &&  // is a stack slot
        (MI.getOperand(2).isImm()) && // the imm is zero
        (isZeroImm(MI.getOperand(2)))) {
      FrameIndex = MI.getOperand(1).getIndex();
      return MI.getOperand(0).getReg();
    }
  }

  return 0;
}

/// isStoreToStackSlot - If the specified machine instruction is a direct
/// store to a stack slot, return the virtual or physical register number of
/// the source reg along with the FrameIndex of the loaded stack slot.  If
/// not, return 0.  This predicate must return 0 if the instruction has
/// any side effects other than storing to the stack slot.
unsigned MipsSEInstrInfo::isStoreToStackSlot(const MachineInstr &MI,
                                             int &FrameIndex) const {
  if (MI.mayStore()) { // is a store...
    if ((MI.getOperand(1).isFI()) &&  // is a stack slot
        (MI.getOperand(2).isImm()) && // the imm is zero
        (isZeroImm(MI.getOperand(2)))) {
      FrameIndex = MI.getOperand(1).getIndex();
      return MI.getOperand(0).getReg();
    }
  }

  return 0;
}

void MipsSEInstrInfo::copyPhysReg(MachineBasicBlock &MBB,
                                  MachineBasicBlock::iterator I,
                                  const DebugLoc &DL, unsigned DestReg,
                                  unsigned SrcReg, bool KillSrc) const {
  unsigned Opc = 0, ZeroReg = 0;
  bool isMicroMips = Subtarget.inMicroMipsMode();

  if (Mips::GPR32RegClass.contains(DestReg)) { // Copy to CPU Reg.
    if (Mips::GPR32RegClass.contains(SrcReg)) {
      if (isMicroMips)
        Opc = Mips::MOVE16_MM;
      else
        Opc = Mips::OR, ZeroReg = Mips::ZERO;
    } else if (Mips::CCRRegClass.contains(SrcReg))
      Opc = Mips::CFC1;
    else if (Mips::FGR32RegClass.contains(SrcReg))
      Opc = Mips::MFC1;
    else if (Mips::HI32RegClass.contains(SrcReg)) {
      Opc = isMicroMips ? Mips::MFHI16_MM : Mips::MFHI;
      SrcReg = 0;
    } else if (Mips::LO32RegClass.contains(SrcReg)) {
      Opc = isMicroMips ? Mips::MFLO16_MM : Mips::MFLO;
      SrcReg = 0;
    } else if (Mips::HI32DSPRegClass.contains(SrcReg))
      Opc = Mips::MFHI_DSP;
    else if (Mips::LO32DSPRegClass.contains(SrcReg))
      Opc = Mips::MFLO_DSP;
    else if (Mips::DSPCCRegClass.contains(SrcReg)) {
      BuildMI(MBB, I, DL, get(Mips::RDDSP), DestReg).addImm(1 << 4)
        .addReg(SrcReg, RegState::Implicit | getKillRegState(KillSrc));
      return;
    }
    else if (Mips::MSACtrlRegClass.contains(SrcReg))
      Opc = Mips::CFCMSA;
  }
  else if (Mips::GPR32RegClass.contains(SrcReg)) { // Copy from CPU Reg.
    if (Mips::CCRRegClass.contains(DestReg))
      Opc = Mips::CTC1;
    else if (Mips::FGR32RegClass.contains(DestReg))
      Opc = Mips::MTC1;
    else if (Mips::HI32RegClass.contains(DestReg))
      Opc = Mips::MTHI, DestReg = 0;
    else if (Mips::LO32RegClass.contains(DestReg))
      Opc = Mips::MTLO, DestReg = 0;
    else if (Mips::HI32DSPRegClass.contains(DestReg))
      Opc = Mips::MTHI_DSP;
    else if (Mips::LO32DSPRegClass.contains(DestReg))
      Opc = Mips::MTLO_DSP;
    else if (Mips::DSPCCRegClass.contains(DestReg)) {
      BuildMI(MBB, I, DL, get(Mips::WRDSP))
        .addReg(SrcReg, getKillRegState(KillSrc)).addImm(1 << 4)
        .addReg(DestReg, RegState::ImplicitDefine);
      return;
    } else if (Mips::MSACtrlRegClass.contains(DestReg)) {
      BuildMI(MBB, I, DL, get(Mips::CTCMSA))
          .addReg(DestReg)
          .addReg(SrcReg, getKillRegState(KillSrc));
      return;
    }
  }
  else if (Mips::FGR32RegClass.contains(DestReg, SrcReg))
    Opc = Mips::FMOV_S;
  else if (Mips::AFGR64RegClass.contains(DestReg, SrcReg))
    Opc = Mips::FMOV_D32;
  else if (Mips::FGR64RegClass.contains(DestReg, SrcReg))
    Opc = Mips::FMOV_D64;
  else if (Mips::GPR64RegClass.contains(DestReg)) { // Copy to CPU64 Reg.
    if (Mips::GPR64RegClass.contains(SrcReg))
      Opc = Mips::OR64, ZeroReg = Mips::ZERO_64;
    else if (Mips::HI64RegClass.contains(SrcReg))
      Opc = Mips::MFHI64, SrcReg = 0;
    else if (Mips::LO64RegClass.contains(SrcReg))
      Opc = Mips::MFLO64, SrcReg = 0;
    else if (Mips::FGR64RegClass.contains(SrcReg))
      Opc = Mips::DMFC1;
  }
  else if (Mips::GPR64RegClass.contains(SrcReg)) { // Copy from CPU64 Reg.
    if (Mips::HI64RegClass.contains(DestReg))
      Opc = Mips::MTHI64, DestReg = 0;
    else if (Mips::LO64RegClass.contains(DestReg))
      Opc = Mips::MTLO64, DestReg = 0;
    else if (Mips::FGR64RegClass.contains(DestReg))
      Opc = Mips::DMTC1;
  } else if (Mips::CheriGPROrCNullRegClass.contains(SrcReg)) {
    BuildMI(MBB, I, DL, get(Mips::CMove))
        .addReg(DestReg, RegState::Define)
        .addReg(SrcReg, getKillRegState(KillSrc));
    return;
  } else if (Mips::CheriHWRegsRegClass.contains(SrcReg)) {
    BuildMI(MBB, I, DL, get(Mips::CReadHwr))
        .addReg(DestReg, RegState::Define)
        .addReg(SrcReg, getKillRegState(KillSrc));
    return;
  } else if (Mips::CheriHWRegsRegClass.contains(DestReg)) {
    BuildMI(MBB, I, DL, get(Mips::CWriteHwr))
        .addReg(SrcReg, RegState::Define)
        .addReg(DestReg, getKillRegState(KillSrc));
    return;
  } else if (Mips::MSA128BRegClass.contains(DestReg)) { // Copy to MSA reg
    if (Mips::MSA128BRegClass.contains(SrcReg))
      Opc = Mips::MOVE_V;
  }

  assert(Opc && "Cannot copy registers");

  MachineInstrBuilder MIB = BuildMI(MBB, I, DL, get(Opc));

  if (DestReg)
    MIB.addReg(DestReg, RegState::Define);

  if (SrcReg)
    MIB.addReg(SrcReg, getKillRegState(KillSrc));

  if (ZeroReg)
    MIB.addReg(ZeroReg);
}

static bool isORCopyInst(const MachineInstr &MI) {
  switch (MI.getOpcode()) {
  default:
    break;
  case Mips::OR_MM:
  case Mips::OR:
    if (MI.getOperand(2).getReg() == Mips::ZERO)
      return true;
    break;
  case Mips::OR64:
    if (MI.getOperand(2).getReg() == Mips::ZERO_64)
      return true;
    break;
  }
  return false;
}

static bool isCIncOffsetCopyInst(const MachineInstr &MI) {
  if (MI.getOpcode() == Mips::CIncOffset &&
      MI.getOperand(2).getReg() == Mips::ZERO_64)
    return true;
  if (MI.getOpcode() == Mips::CIncOffsetImm && MI.getOperand(2).getImm() == 0)
    return true;
  return false;
}

/// If @MI is WRDSP/RRDSP instruction return true with @isWrite set to true
/// if it is WRDSP instruction.
static bool isReadOrWriteToDSPReg(const MachineInstr &MI, bool &isWrite) {
  switch (MI.getOpcode()) {
  default:
   return false;
  case Mips::WRDSP:
  case Mips::WRDSP_MM:
    isWrite = true;
    break;
  case Mips::RDDSP:
  case Mips::RDDSP_MM:
    isWrite = false;
    break;
  }
  return true;
}

/// We check for the common case of 'or', as it's MIPS' preferred instruction
/// for GPRs but we have to check the operands to ensure that is the case.
/// Other move instructions for MIPS are directly identifiable.
bool MipsSEInstrInfo::isCopyInstrImpl(const MachineInstr &MI,
                                      const MachineOperand *&Src,
                                      const MachineOperand *&Dest) const {
  bool isDSPControlWrite = false;
  // Condition is made to match the creation of WRDSP/RDDSP copy instruction
  // from copyPhysReg function.

  // FIXME: Handle CRead/WriteHWR here as well?
  if (isReadOrWriteToDSPReg(MI, isDSPControlWrite)) {
    if (!MI.getOperand(1).isImm() || MI.getOperand(1).getImm() != (1<<4))
      return false;
    else if (isDSPControlWrite) {
      Src = &MI.getOperand(0);
      Dest = &MI.getOperand(2);
    } else {
      Dest = &MI.getOperand(0);
      Src = &MI.getOperand(2);
    }
    return true;
  } else if (MI.isMoveReg() || isORCopyInst(MI) || isCIncOffsetCopyInst(MI)) {
    Dest = &MI.getOperand(0);
    Src = &MI.getOperand(1);
    return true;
  }
  return false;
}

void MipsSEInstrInfo::
storeRegToStack(MachineBasicBlock &MBB, MachineBasicBlock::iterator I,
                unsigned SrcReg, bool isKill, int FI,
                const TargetRegisterClass *RC, const TargetRegisterInfo *TRI,
                int64_t Offset) const {
  DebugLoc DL;
  MachineMemOperand *MMO = GetMemOperand(MBB, FI, MachineMemOperand::MOStore);

  unsigned Opc = 0;

  // The ACC64/128 registers are handled by STORE_ACC64/128 pseudos, which call this function again with more ordinary
  // registers when they are lowered: so no special treatment for CHERI is required.
  if (Subtarget.isABI_CheriPureCap() &&
      !Mips::ACC64RegClass.hasSubClassEq(RC) &&
      !Mips::ACC128RegClass.hasSubClassEq(RC)) {
    if (Mips::GPR32RegClass.hasSubClassEq(RC))
      Opc = Mips::CAPSTORE32;
    else if (Mips::GPR64RegClass.hasSubClassEq(RC))
      Opc = Mips::CAPSTORE64;
    else if (Mips::FGR64RegClass.hasSubClassEq(RC)) {
      DebugLoc DL = I->getDebugLoc();
      MachineRegisterInfo &RegInfo = MBB.getParent()->getRegInfo();
      unsigned IntReg = RegInfo.createVirtualRegister(&Mips::GPR64RegClass);
      BuildMI(MBB, I, DL, get(Mips::DMFC1), IntReg)
        .addReg(SrcReg);
      BuildMI(MBB, I, DL, get(Mips::CAPSTORE64)).addReg(IntReg, getKillRegState(true))
        .addReg(Mips::ZERO_64).addFrameIndex(FI).addImm(Offset).addMemOperand(MMO);
      return;
    } else if (Mips::CheriGPROrCNullRegClass.hasSubClassEq(RC)) {
      Opc = Mips::STORECAP;
      // Ensure that capabilities have a 32-byte alignment
      // FIXME: This shouldn't be needed.  Whatever is allocating the frame index
      // ought to set it.
      MachineFrameInfo &MFI = MBB.getParent()->getFrameInfo();
      MFI.setObjectAlignment(FI, Subtarget.getCapSizeInBytes());
    } else {
      llvm_unreachable("Unexpected register type for CHERI!");
    }
    BuildMI(MBB, I, DL, get(Opc)).addReg(SrcReg, getKillRegState(isKill))
      .addReg(Mips::ZERO_64).addFrameIndex(FI).addImm(Offset).addMemOperand(MMO);
    return;
  }
  if (Mips::GPR32RegClass.hasSubClassEq(RC))
    Opc = Mips::SW;
  else if (Mips::GPR64RegClass.hasSubClassEq(RC))
    Opc = Mips::SD;
  else if (Mips::ACC64RegClass.hasSubClassEq(RC))
    Opc = Mips::STORE_ACC64;
  else if (Mips::ACC64DSPRegClass.hasSubClassEq(RC))
    Opc = Mips::STORE_ACC64DSP;
  else if (Mips::ACC128RegClass.hasSubClassEq(RC))
    Opc = Mips::STORE_ACC128;
  else if (Mips::DSPCCRegClass.hasSubClassEq(RC))
    Opc = Mips::STORE_CCOND_DSP;
  else if (Mips::FGR32RegClass.hasSubClassEq(RC))
    Opc = Mips::SWC1;
  else if (Mips::AFGR64RegClass.hasSubClassEq(RC))
    Opc = Mips::SDC1;
  else if (Mips::FGR64RegClass.hasSubClassEq(RC))
    Opc = Mips::SDC164;
  else if (TRI->isTypeLegalForClass(*RC, MVT::v16i8))
    Opc = Mips::ST_B;
  else if (TRI->isTypeLegalForClass(*RC, MVT::v8i16) ||
           TRI->isTypeLegalForClass(*RC, MVT::v8f16))
    Opc = Mips::ST_H;
  else if (TRI->isTypeLegalForClass(*RC, MVT::v4i32) ||
           TRI->isTypeLegalForClass(*RC, MVT::v4f32))
    Opc = Mips::ST_W;
  else if (TRI->isTypeLegalForClass(*RC, MVT::v2i64) ||
           TRI->isTypeLegalForClass(*RC, MVT::v2f64))
    Opc = Mips::ST_D;
  else if (Mips::CheriGPROrCNullRegClass.hasSubClassEq(RC)) {
    Opc = Mips::STORECAP;
    // Ensure that capabilities have a 32-byte alignment
    // FIXME: This shouldn't be needed.  Whatever is allocating the frame index
    // ought to set it.
    MachineFrameInfo &MFI = MBB.getParent()->getFrameInfo();
    MFI.setObjectAlignment(FI, Subtarget.getCapSizeInBytes());
    BuildMI(MBB, I, DL, get(Opc))
        .addReg(SrcReg, getKillRegState(isKill))
        .addFrameIndex(FI)
        .addImm(Offset)
        .addMemOperand(MMO)
        .addReg(Mips::DDC);
    return;
  } else if (Mips::LO32RegClass.hasSubClassEq(RC))
    Opc = Mips::SW;
  else if (Mips::LO64RegClass.hasSubClassEq(RC))
    Opc = Mips::SD;
  else if (Mips::HI32RegClass.hasSubClassEq(RC))
    Opc = Mips::SW;
  else if (Mips::HI64RegClass.hasSubClassEq(RC))
    Opc = Mips::SD;
  else if (Mips::DSPRRegClass.hasSubClassEq(RC))
    Opc = Mips::SWDSP;

  // Hi, Lo are normally caller save but they are callee save
  // for interrupt handling.
  const Function &Func = MBB.getParent()->getFunction();
  if (Func.hasFnAttribute("interrupt")) {
    if (Mips::HI32RegClass.hasSubClassEq(RC)) {
      BuildMI(MBB, I, DL, get(Mips::MFHI), Mips::K0);
      SrcReg = Mips::K0;
    } else if (Mips::HI64RegClass.hasSubClassEq(RC)) {
      BuildMI(MBB, I, DL, get(Mips::MFHI64), Mips::K0_64);
      SrcReg = Mips::K0_64;
    } else if (Mips::LO32RegClass.hasSubClassEq(RC)) {
      BuildMI(MBB, I, DL, get(Mips::MFLO), Mips::K0);
      SrcReg = Mips::K0;
    } else if (Mips::LO64RegClass.hasSubClassEq(RC)) {
      BuildMI(MBB, I, DL, get(Mips::MFLO64), Mips::K0_64);
      SrcReg = Mips::K0_64;
    }
  }

  assert(Opc && "Register class not handled!");
  BuildMI(MBB, I, DL, get(Opc)).addReg(SrcReg, getKillRegState(isKill))
    .addFrameIndex(FI).addImm(Offset).addMemOperand(MMO);
}

void MipsSEInstrInfo::
loadRegFromStack(MachineBasicBlock &MBB, MachineBasicBlock::iterator I,
                 unsigned DestReg, int FI, const TargetRegisterClass *RC,
                 const TargetRegisterInfo *TRI, int64_t Offset) const {
  DebugLoc DL;
  if (I != MBB.end()) DL = I->getDebugLoc();
  MachineMemOperand *MMO = GetMemOperand(MBB, FI, MachineMemOperand::MOLoad);
  unsigned Opc = 0;

  // The ACC64/128 registers are handled by LOAD_ACC64/128 pseudos, which call this function again with more ordinary
  // registers when they are lowered: so no special treatment for CHERI is required.
  if (Subtarget.isABI_CheriPureCap() &&
      !Mips::ACC64RegClass.hasSubClassEq(RC) &&
      !Mips::ACC128RegClass.hasSubClassEq(RC)) {
    if (Mips::GPR32RegClass.hasSubClassEq(RC))
      Opc = Mips::CAPLOAD32;
    else if (Mips::GPR64RegClass.hasSubClassEq(RC))
      Opc = Mips::CAPLOAD64;
    else if (Mips::FGR64RegClass.hasSubClassEq(RC)) {
      DebugLoc DL = I->getDebugLoc();
      MachineRegisterInfo &RegInfo = MBB.getParent()->getRegInfo();
      unsigned IntReg = RegInfo.createVirtualRegister(&Mips::GPR64RegClass);
      BuildMI(MBB, I, DL, get(Mips::CAPLOAD64), IntReg)
        .addReg(Mips::ZERO_64).addFrameIndex(FI).addImm(Offset)
        .addMemOperand(MMO);
      BuildMI(MBB, I, DL, get(Mips::DMTC1), DestReg)
        .addReg(IntReg, getKillRegState(true));
      return;
    } else if (Mips::CheriGPROrCNullRegClass.hasSubClassEq(RC)) {
      Opc = Mips::LOADCAP;
    } else {
      llvm_unreachable("Unexpected register type for CHERI!");
    }
    BuildMI(MBB, I, DL, get(Opc), DestReg)
      .addReg(Mips::ZERO_64).addFrameIndex(FI).addImm(Offset)
      .addMemOperand(MMO);
    return;
  }
  const Function &Func = MBB.getParent()->getFunction();
  bool ReqIndirectLoad = Func.hasFnAttribute("interrupt") &&
                         (DestReg == Mips::LO0 || DestReg == Mips::LO0_64 ||
                          DestReg == Mips::HI0 || DestReg == Mips::HI0_64);

  if (Mips::GPR32RegClass.hasSubClassEq(RC))
    Opc = Mips::LW;
  else if (Mips::GPR64RegClass.hasSubClassEq(RC))
    Opc = Mips::LD;
  else if (Mips::ACC64RegClass.hasSubClassEq(RC))
    Opc = Mips::LOAD_ACC64;
  else if (Mips::ACC64DSPRegClass.hasSubClassEq(RC))
    Opc = Mips::LOAD_ACC64DSP;
  else if (Mips::ACC128RegClass.hasSubClassEq(RC))
    Opc = Mips::LOAD_ACC128;
  else if (Mips::DSPCCRegClass.hasSubClassEq(RC))
    Opc = Mips::LOAD_CCOND_DSP;
  else if (Mips::FGR32RegClass.hasSubClassEq(RC))
    Opc = Mips::LWC1;
  else if (Mips::AFGR64RegClass.hasSubClassEq(RC))
    Opc = Mips::LDC1;
  else if (Mips::FGR64RegClass.hasSubClassEq(RC))
    Opc = Mips::LDC164;
  else if (TRI->isTypeLegalForClass(*RC, MVT::v16i8))
    Opc = Mips::LD_B;
  else if (TRI->isTypeLegalForClass(*RC, MVT::v8i16) ||
           TRI->isTypeLegalForClass(*RC, MVT::v8f16))
    Opc = Mips::LD_H;
  else if (TRI->isTypeLegalForClass(*RC, MVT::v4i32) ||
           TRI->isTypeLegalForClass(*RC, MVT::v4f32))
    Opc = Mips::LD_W;
  else if (TRI->isTypeLegalForClass(*RC, MVT::v2i64) ||
           TRI->isTypeLegalForClass(*RC, MVT::v2f64))
    Opc = Mips::LD_D;
  else if (Mips::CheriGPROrCNullRegClass.hasSubClassEq(RC)) {
    Opc = Mips::LOADCAP;
    BuildMI(MBB, I, DL, get(Opc), DestReg)
        .addFrameIndex(FI)
        .addImm(Offset)
        .addMemOperand(MMO)
        .addReg(Mips::DDC);
    return;
  } else if (Mips::HI32RegClass.hasSubClassEq(RC))
    Opc = Mips::LW;
  else if (Mips::HI64RegClass.hasSubClassEq(RC))
    Opc = Mips::LD;
  else if (Mips::LO32RegClass.hasSubClassEq(RC))
    Opc = Mips::LW;
  else if (Mips::LO64RegClass.hasSubClassEq(RC))
    Opc = Mips::LD;
  else if (Mips::DSPRRegClass.hasSubClassEq(RC))
    Opc = Mips::LWDSP;

  assert(Opc && "Register class not handled!");

  if (!ReqIndirectLoad)
    BuildMI(MBB, I, DL, get(Opc), DestReg)
        .addFrameIndex(FI)
        .addImm(Offset)
        .addMemOperand(MMO);
  else {
    // Load HI/LO through K0. Notably the DestReg is encoded into the
    // instruction itself.
    unsigned Reg = Mips::K0;
    unsigned LdOp = Mips::MTLO;
    if (DestReg == Mips::HI0)
      LdOp = Mips::MTHI;

    if (Subtarget.getABI().ArePtrs64bit()) {
      Reg = Mips::K0_64;
      if (DestReg == Mips::HI0_64)
        LdOp = Mips::MTHI64;
      else
        LdOp = Mips::MTLO64;
    }

    BuildMI(MBB, I, DL, get(Opc), Reg)
        .addFrameIndex(FI)
        .addImm(Offset)
        .addMemOperand(MMO);
    BuildMI(MBB, I, DL, get(LdOp)).addReg(Reg);
  }
}

bool MipsSEInstrInfo::expandPostRAPseudo(MachineInstr &MI) const {
  MachineBasicBlock &MBB = *MI.getParent();
  bool isMicroMips = Subtarget.inMicroMipsMode();
  unsigned Opc;

  switch (MI.getDesc().getOpcode()) {
  default:
    return false;
  case Mips::RetRA:
    expandRetRA(MBB, MI);
    break;
  case Mips::ERet:
    expandERet(MBB, MI);
    break;
  case Mips::PseudoMFHI:
    expandPseudoMFHiLo(MBB, MI, Mips::MFHI);
    break;
  case Mips::PseudoMFHI_MM:
    expandPseudoMFHiLo(MBB, MI, Mips::MFHI16_MM);
    break;
  case Mips::PseudoMFLO:
    expandPseudoMFHiLo(MBB, MI, Mips::MFLO);
    break;
  case Mips::PseudoMFLO_MM:
    expandPseudoMFHiLo(MBB, MI, Mips::MFLO16_MM);
    break;
  case Mips::PseudoMFHI64:
    expandPseudoMFHiLo(MBB, MI, Mips::MFHI64);
    break;
  case Mips::PseudoMFLO64:
    expandPseudoMFHiLo(MBB, MI, Mips::MFLO64);
    break;
  case Mips::PseudoMTLOHI:
    expandPseudoMTLoHi(MBB, MI, Mips::MTLO, Mips::MTHI, false);
    break;
  case Mips::PseudoMTLOHI64:
    expandPseudoMTLoHi(MBB, MI, Mips::MTLO64, Mips::MTHI64, false);
    break;
  case Mips::PseudoMTLOHI_DSP:
    expandPseudoMTLoHi(MBB, MI, Mips::MTLO_DSP, Mips::MTHI_DSP, true);
    break;
  case Mips::PseudoMTLOHI_MM:
    expandPseudoMTLoHi(MBB, MI, Mips::MTLO_MM, Mips::MTHI_MM, false);
    break;
  case Mips::PseudoCVT_S_W:
    expandCvtFPInt(MBB, MI, Mips::CVT_S_W, Mips::MTC1, false);
    break;
  case Mips::PseudoCVT_D32_W:
    Opc = isMicroMips ? Mips::CVT_D32_W_MM : Mips::CVT_D32_W;
    expandCvtFPInt(MBB, MI, Opc, Mips::MTC1, false);
    break;
  case Mips::PseudoCVT_S_L:
    expandCvtFPInt(MBB, MI, Mips::CVT_S_L, Mips::DMTC1, true);
    break;
  case Mips::PseudoCVT_D64_W:
    Opc = isMicroMips ? Mips::CVT_D64_W_MM : Mips::CVT_D64_W;
    expandCvtFPInt(MBB, MI, Opc, Mips::MTC1, true);
    break;
  case Mips::PseudoCVT_D64_L:
    expandCvtFPInt(MBB, MI, Mips::CVT_D64_L, Mips::DMTC1, true);
    break;
  case Mips::BuildPairF64:
    expandBuildPairF64(MBB, MI, isMicroMips, false);
    break;
  case Mips::BuildPairF64_64:
    expandBuildPairF64(MBB, MI, isMicroMips, true);
    break;
  case Mips::ExtractElementF64:
    expandExtractElementF64(MBB, MI, isMicroMips, false);
    break;
  case Mips::ExtractElementF64_64:
    expandExtractElementF64(MBB, MI, isMicroMips, true);
    break;
  case Mips::MIPSeh_return32:
  case Mips::MIPSeh_return64:
    expandEhReturn(MBB, MI);
    break;
  case Mips::CapRetPseudo:
    BuildMI(MBB, MI, MI.getDebugLoc(), get(Mips::PseudoReturnCap))
      .addReg(Mips::C17);
    break;
  case Mips::CheriBoundedStackPseudo: {
    auto Op = MI.getOperand(3).isImm() ? Mips::CSetBoundsImm : Mips::CSetBounds;
    if (Op == Mips::CSetBoundsImm)
      assert(isInt<11>(MI.getOperand(3).getImm()));
    else
      assert(MI.getOperand(3).isReg());
    assert(MI.getOperand(2).getImm() == 0 && "This operand is a dummy and must be zero!");
    BuildMI(MBB, MI, MI.getDebugLoc(), get(Op), MI.getOperand(0).getReg())
      .addReg(MI.getOperand(1).getReg()).add(MI.getOperand(3));
    break;
  }
  case Mips::CPSETUP:
    expandCPSETUP(MBB, MI);
    break;
  case Mips::CCallPseudo:
    expandCCallPseudo(MBB, MI);
    break;
  }

  MBB.erase(MI);
  return true;
}

/// getOppositeBranchOpc - Return the inverse of the specified
/// opcode, e.g. turning BEQ to BNE.
unsigned MipsSEInstrInfo::getOppositeBranchOpc(unsigned Opc) const {
  switch (Opc) {
  default:           llvm_unreachable("Illegal opcode!");
  case Mips::BEQ:    return Mips::BNE;
  case Mips::BEQ_MM: return Mips::BNE_MM;
  case Mips::BNE:    return Mips::BEQ;
  case Mips::BNE_MM: return Mips::BEQ_MM;
  case Mips::BGTZ:   return Mips::BLEZ;
  case Mips::BGEZ:   return Mips::BLTZ;
  case Mips::BLTZ:   return Mips::BGEZ;
  case Mips::BLEZ:   return Mips::BGTZ;
  case Mips::BGTZ_MM:   return Mips::BLEZ_MM;
  case Mips::BGEZ_MM:   return Mips::BLTZ_MM;
  case Mips::BLTZ_MM:   return Mips::BGEZ_MM;
  case Mips::BLEZ_MM:   return Mips::BGTZ_MM;
  case Mips::BEQ64:  return Mips::BNE64;
  case Mips::BNE64:  return Mips::BEQ64;
  case Mips::BGTZ64: return Mips::BLEZ64;
  case Mips::BGEZ64: return Mips::BLTZ64;
  case Mips::BLTZ64: return Mips::BGEZ64;
  case Mips::BLEZ64: return Mips::BGTZ64;
  case Mips::BC1T:   return Mips::BC1F;
  case Mips::BC1F:   return Mips::BC1T;
  case Mips::BC1T_MM:   return Mips::BC1F_MM;
  case Mips::BC1F_MM:   return Mips::BC1T_MM;
  case Mips::BEQZ16_MM: return Mips::BNEZ16_MM;
  case Mips::BNEZ16_MM: return Mips::BEQZ16_MM;
  case Mips::BEQZC_MM:  return Mips::BNEZC_MM;
  case Mips::BNEZC_MM:  return Mips::BEQZC_MM;
  case Mips::BEQZC:  return Mips::BNEZC;
  case Mips::BNEZC:  return Mips::BEQZC;
  case Mips::BLEZC:  return Mips::BGTZC;
  case Mips::BGEZC:  return Mips::BLTZC;
  case Mips::BGEC:   return Mips::BLTC;
  case Mips::BGTZC:  return Mips::BLEZC;
  case Mips::BLTZC:  return Mips::BGEZC;
  case Mips::BLTC:   return Mips::BGEC;
  case Mips::BGEUC:  return Mips::BLTUC;
  case Mips::BLTUC:  return Mips::BGEUC;
  case Mips::BEQC:   return Mips::BNEC;
  case Mips::BNEC:   return Mips::BEQC;
  case Mips::BC1EQZ: return Mips::BC1NEZ;
  case Mips::BC1NEZ: return Mips::BC1EQZ;
  case Mips::BEQZC_MMR6:  return Mips::BNEZC_MMR6;
  case Mips::BNEZC_MMR6:  return Mips::BEQZC_MMR6;
  case Mips::BLEZC_MMR6:  return Mips::BGTZC_MMR6;
  case Mips::BGEZC_MMR6:  return Mips::BLTZC_MMR6;
  case Mips::BGEC_MMR6:   return Mips::BLTC_MMR6;
  case Mips::BGTZC_MMR6:  return Mips::BLEZC_MMR6;
  case Mips::BLTZC_MMR6:  return Mips::BGEZC_MMR6;
  case Mips::BLTC_MMR6:   return Mips::BGEC_MMR6;
  case Mips::BGEUC_MMR6:  return Mips::BLTUC_MMR6;
  case Mips::BLTUC_MMR6:  return Mips::BGEUC_MMR6;
  case Mips::BEQC_MMR6:   return Mips::BNEC_MMR6;
  case Mips::BNEC_MMR6:   return Mips::BEQC_MMR6;
  case Mips::BC1EQZC_MMR6: return Mips::BC1NEZC_MMR6;
  case Mips::BC1NEZC_MMR6: return Mips::BC1EQZC_MMR6;
  case Mips::BEQZC64:  return Mips::BNEZC64;
  case Mips::BNEZC64:  return Mips::BEQZC64;
  case Mips::BEQC64:   return Mips::BNEC64;
  case Mips::BNEC64:   return Mips::BEQC64;
  case Mips::BGEC64:   return Mips::BLTC64;
  case Mips::BGEUC64:  return Mips::BLTUC64;
  case Mips::BLTC64:   return Mips::BGEC64;
  case Mips::BLTUC64:  return Mips::BGEUC64;
  case Mips::BGTZC64:  return Mips::BLEZC64;
  case Mips::BGEZC64:  return Mips::BLTZC64;
  case Mips::BLTZC64:  return Mips::BGEZC64;
  case Mips::BLEZC64:  return Mips::BGTZC64;
  case Mips::BBIT0:  return Mips::BBIT1;
  case Mips::BBIT1:  return Mips::BBIT0;
  case Mips::BBIT032:  return Mips::BBIT132;
  case Mips::BBIT132:  return Mips::BBIT032;
  case Mips::BZ_B:   return Mips::BNZ_B;
  case Mips::BZ_H:   return Mips::BNZ_H;
  case Mips::BZ_W:   return Mips::BNZ_W;
  case Mips::BZ_D:   return Mips::BNZ_D;
  case Mips::BZ_V:   return Mips::BNZ_V;
  case Mips::BNZ_B:  return Mips::BZ_B;
  case Mips::BNZ_H:  return Mips::BZ_H;
  case Mips::BNZ_W:  return Mips::BZ_W;
  case Mips::BNZ_D:  return Mips::BZ_D;
  case Mips::BNZ_V:  return Mips::BZ_V;
  case Mips::CBTS:   return Mips::CBTU;
  case Mips::CBTU:   return Mips::CBTS;
  case Mips::CBEZ:   return Mips::CBNZ;
  case Mips::CBNZ:   return Mips::CBEZ;
  }
}

/// Adjust SP by Amount bytes.
void MipsSEInstrInfo::adjustStackPtr(unsigned SP, int64_t Amount,
                                     MachineBasicBlock &MBB,
                                     MachineBasicBlock::iterator I) const {
  MipsABIInfo ABI = Subtarget.getABI();
  DebugLoc DL;
  unsigned ADDiu = ABI.GetPtrAddiuOp();

  if (Amount == 0)
    return;

  if (ABI.IsCheriPureCap()) {
    if (isInt<11>(Amount)) {
      BuildMI(MBB, I, DL, get(Mips::CIncOffsetImm), SP)
        .addReg(SP).addImm(Amount);
    } else {
      unsigned Reg = loadImmediate(Amount, MBB, I, DL, nullptr);
      BuildMI(MBB, I, DL, get(Mips::CIncOffset), SP)
        .addReg(SP).addReg(Reg, RegState::Kill);
    }
  } else if (isInt<16>(Amount)) {
    // addi sp, sp, amount
    BuildMI(MBB, I, DL, get(ADDiu), SP).addReg(SP).addImm(Amount);
  } else {
    // For numbers which are not 16bit integers we synthesize Amount inline
    // then add or subtract it from sp.
    unsigned Opc = ABI.GetPtrAdduOp();
    if (Amount < 0) {
      Opc = ABI.GetPtrSubuOp();
      Amount = -Amount;
    }
    unsigned Reg = loadImmediate(Amount, MBB, I, DL, nullptr);
    BuildMI(MBB, I, DL, get(Opc), SP).addReg(SP).addReg(Reg, RegState::Kill);
  }
}

/// This function generates the sequence of instructions needed to get the
/// result of adding register REG and immediate IMM.
unsigned MipsSEInstrInfo::loadImmediate(int64_t Imm, MachineBasicBlock &MBB,
                                        MachineBasicBlock::iterator II,
                                        const DebugLoc &DL,
                                        unsigned *NewImm) const {
  MipsAnalyzeImmediate AnalyzeImm;
  const MipsSubtarget &STI = Subtarget;
  MachineRegisterInfo &RegInfo = MBB.getParent()->getRegInfo();
  unsigned Size = STI.isABI_N64() ? 64 : 32;
  unsigned LUi = STI.isABI_N64() ? Mips::LUi64 : Mips::LUi;
  unsigned ZEROReg = STI.isABI_N64() ? Mips::ZERO_64 : Mips::ZERO;
  const TargetRegisterClass *RC = STI.isABI_N64() ?
    &Mips::GPR64RegClass : &Mips::GPR32RegClass;
  bool LastInstrIsADDiu = NewImm;

  const MipsAnalyzeImmediate::InstSeq &Seq =
    AnalyzeImm.Analyze(Imm, Size, LastInstrIsADDiu);
  MipsAnalyzeImmediate::InstSeq::const_iterator Inst = Seq.begin();

  assert(Seq.size() && (!LastInstrIsADDiu || (Seq.size() > 1)));

  // The first instruction can be a LUi, which is different from other
  // instructions (ADDiu, ORI and SLL) in that it does not have a register
  // operand.
  unsigned Reg = RegInfo.createVirtualRegister(RC);

  if (Inst->Opc == LUi)
    BuildMI(MBB, II, DL, get(LUi), Reg).addImm(SignExtend64<16>(Inst->ImmOpnd));
  else
    BuildMI(MBB, II, DL, get(Inst->Opc), Reg).addReg(ZEROReg)
      .addImm(SignExtend64<16>(Inst->ImmOpnd));

  // Build the remaining instructions in Seq.
  for (++Inst; Inst != Seq.end() - LastInstrIsADDiu; ++Inst)
    BuildMI(MBB, II, DL, get(Inst->Opc), Reg).addReg(Reg, RegState::Kill)
      .addImm(SignExtend64<16>(Inst->ImmOpnd));

  if (LastInstrIsADDiu)
    *NewImm = Inst->ImmOpnd;

  return Reg;
}

unsigned MipsSEInstrInfo::getAnalyzableBrOpc(unsigned Opc) const {
  return (Opc == Mips::BEQ    || Opc == Mips::BEQ_MM || Opc == Mips::BNE    ||
          Opc == Mips::BNE_MM || Opc == Mips::BGTZ   || Opc == Mips::BGEZ   ||
          Opc == Mips::BLTZ   || Opc == Mips::BLEZ   || Opc == Mips::BEQ64  ||
          Opc == Mips::BNE64  || Opc == Mips::BGTZ64 || Opc == Mips::BGEZ64 ||
          Opc == Mips::BLTZ64 || Opc == Mips::BLEZ64 || Opc == Mips::BC1T   ||
          Opc == Mips::CBTS   || Opc == Mips::CBTU   || Opc == Mips::CBEZ   ||
          Opc == Mips::CBNZ   ||
          Opc == Mips::BC1F   || Opc == Mips::B      || Opc == Mips::J      ||
          Opc == Mips::J_MM   || Opc == Mips::B_MM   || Opc == Mips::BEQZC_MM ||
          Opc == Mips::BNEZC_MM || Opc == Mips::BEQC || Opc == Mips::BNEC   ||
          Opc == Mips::BLTC   || Opc == Mips::BGEC   || Opc == Mips::BLTUC  ||
          Opc == Mips::BGEUC  || Opc == Mips::BGTZC  || Opc == Mips::BLEZC  ||
          Opc == Mips::BGEZC  || Opc == Mips::BLTZC  || Opc == Mips::BEQZC  ||
          Opc == Mips::BNEZC  || Opc == Mips::BEQZC64 || Opc == Mips::BNEZC64 ||
          Opc == Mips::BEQC64 || Opc == Mips::BNEC64 || Opc == Mips::BGEC64 ||
          Opc == Mips::BGEUC64 || Opc == Mips::BLTC64 || Opc == Mips::BLTUC64 ||
          Opc == Mips::BGTZC64 || Opc == Mips::BGEZC64 ||
          Opc == Mips::BLTZC64 || Opc == Mips::BLEZC64 || Opc == Mips::BC ||
          Opc == Mips::BBIT0 || Opc == Mips::BBIT1 || Opc == Mips::BBIT032 ||
          Opc == Mips::BBIT132 ||  Opc == Mips::BC_MMR6 ||
          Opc == Mips::BEQC_MMR6 || Opc == Mips::BNEC_MMR6 ||
          Opc == Mips::BLTC_MMR6 || Opc == Mips::BGEC_MMR6 ||
          Opc == Mips::BLTUC_MMR6 || Opc == Mips::BGEUC_MMR6 ||
          Opc == Mips::BGTZC_MMR6 || Opc == Mips::BLEZC_MMR6 ||
          Opc == Mips::BGEZC_MMR6 || Opc == Mips::BLTZC_MMR6 ||
          Opc == Mips::BEQZC_MMR6 || Opc == Mips::BNEZC_MMR6) ? Opc : 0;
}

void MipsSEInstrInfo::expandRetRA(MachineBasicBlock &MBB,
                                  MachineBasicBlock::iterator I) const {

  MachineInstrBuilder MIB;
  if (Subtarget.isGP64bit())
    MIB = BuildMI(MBB, I, I->getDebugLoc(), get(Mips::PseudoReturn64))
              .addReg(Mips::RA_64, RegState::Undef);
  else
    MIB = BuildMI(MBB, I, I->getDebugLoc(), get(Mips::PseudoReturn))
              .addReg(Mips::RA, RegState::Undef);

  // Retain any imp-use flags.
  for (auto & MO : I->operands()) {
    if (MO.isImplicit())
      MIB.add(MO);
  }
}

void MipsSEInstrInfo::expandERet(MachineBasicBlock &MBB,
                                 MachineBasicBlock::iterator I) const {
  BuildMI(MBB, I, I->getDebugLoc(), get(Mips::ERET));
}

std::pair<bool, bool>
MipsSEInstrInfo::compareOpndSize(unsigned Opc,
                                 const MachineFunction &MF) const {
  const MCInstrDesc &Desc = get(Opc);
  assert(Desc.NumOperands == 2 && "Unary instruction expected.");
  const MipsRegisterInfo *RI = &getRegisterInfo();
  unsigned DstRegSize = RI->getRegSizeInBits(*getRegClass(Desc, 0, RI, MF));
  unsigned SrcRegSize = RI->getRegSizeInBits(*getRegClass(Desc, 1, RI, MF));

  return std::make_pair(DstRegSize > SrcRegSize, DstRegSize < SrcRegSize);
}

void MipsSEInstrInfo::expandPseudoMFHiLo(MachineBasicBlock &MBB,
                                         MachineBasicBlock::iterator I,
                                         unsigned NewOpc) const {
  BuildMI(MBB, I, I->getDebugLoc(), get(NewOpc), I->getOperand(0).getReg());
}

void MipsSEInstrInfo::expandPseudoMTLoHi(MachineBasicBlock &MBB,
                                         MachineBasicBlock::iterator I,
                                         unsigned LoOpc,
                                         unsigned HiOpc,
                                         bool HasExplicitDef) const {
  // Expand
  //  lo_hi pseudomtlohi $gpr0, $gpr1
  // to these two instructions:
  //  mtlo $gpr0
  //  mthi $gpr1

  DebugLoc DL = I->getDebugLoc();
  const MachineOperand &SrcLo = I->getOperand(1), &SrcHi = I->getOperand(2);
  MachineInstrBuilder LoInst = BuildMI(MBB, I, DL, get(LoOpc));
  MachineInstrBuilder HiInst = BuildMI(MBB, I, DL, get(HiOpc));

  // Add lo/hi registers if the mtlo/hi instructions created have explicit
  // def registers.
  if (HasExplicitDef) {
    unsigned DstReg = I->getOperand(0).getReg();
    unsigned DstLo = getRegisterInfo().getSubReg(DstReg, Mips::sub_lo);
    unsigned DstHi = getRegisterInfo().getSubReg(DstReg, Mips::sub_hi);
    LoInst.addReg(DstLo, RegState::Define);
    HiInst.addReg(DstHi, RegState::Define);
  }

  LoInst.addReg(SrcLo.getReg(), getKillRegState(SrcLo.isKill()));
  HiInst.addReg(SrcHi.getReg(), getKillRegState(SrcHi.isKill()));
}

void MipsSEInstrInfo::expandCvtFPInt(MachineBasicBlock &MBB,
                                     MachineBasicBlock::iterator I,
                                     unsigned CvtOpc, unsigned MovOpc,
                                     bool IsI64) const {
  const MCInstrDesc &CvtDesc = get(CvtOpc), &MovDesc = get(MovOpc);
  const MachineOperand &Dst = I->getOperand(0), &Src = I->getOperand(1);
  unsigned DstReg = Dst.getReg(), SrcReg = Src.getReg(), TmpReg = DstReg;
  unsigned KillSrc =  getKillRegState(Src.isKill());
  DebugLoc DL = I->getDebugLoc();
  bool DstIsLarger, SrcIsLarger;

  std::tie(DstIsLarger, SrcIsLarger) =
      compareOpndSize(CvtOpc, *MBB.getParent());

  if (DstIsLarger)
    TmpReg = getRegisterInfo().getSubReg(DstReg, Mips::sub_lo);

  if (SrcIsLarger)
    DstReg = getRegisterInfo().getSubReg(DstReg, Mips::sub_lo);

  BuildMI(MBB, I, DL, MovDesc, TmpReg).addReg(SrcReg, KillSrc);
  BuildMI(MBB, I, DL, CvtDesc, DstReg).addReg(TmpReg, RegState::Kill);
}

void MipsSEInstrInfo::expandExtractElementF64(MachineBasicBlock &MBB,
                                              MachineBasicBlock::iterator I,
                                              bool isMicroMips,
                                              bool FP64) const {
  unsigned DstReg = I->getOperand(0).getReg();
  unsigned SrcReg = I->getOperand(1).getReg();
  unsigned N = I->getOperand(2).getImm();
  DebugLoc dl = I->getDebugLoc();

  assert(N < 2 && "Invalid immediate");
  unsigned SubIdx = N ? Mips::sub_hi : Mips::sub_lo;
  unsigned SubReg = getRegisterInfo().getSubReg(SrcReg, SubIdx);

  // FPXX on MIPS-II or MIPS32r1 should have been handled with a spill/reload
  // in MipsSEFrameLowering.cpp.
  assert(!(Subtarget.isABI_FPXX() && !Subtarget.hasMips32r2()));

  // FP64A (FP64 with nooddspreg) should have been handled with a spill/reload
  // in MipsSEFrameLowering.cpp.
  assert(!(Subtarget.isFP64bit() && !Subtarget.useOddSPReg()));

  if (SubIdx == Mips::sub_hi && Subtarget.hasMTHC1()) {
    // FIXME: Strictly speaking MFHC1 only reads the top 32-bits however, we
    //        claim to read the whole 64-bits as part of a white lie used to
    //        temporarily work around a widespread bug in the -mfp64 support.
    //        The problem is that none of the 32-bit fpu ops mention the fact
    //        that they clobber the upper 32-bits of the 64-bit FPR. Fixing that
    //        requires a major overhaul of the FPU implementation which can't
    //        be done right now due to time constraints.
    //        MFHC1 is one of two instructions that are affected since they are
    //        the only instructions that don't read the lower 32-bits.
    //        We therefore pretend that it reads the bottom 32-bits to
    //        artificially create a dependency and prevent the scheduler
    //        changing the behaviour of the code.
    BuildMI(MBB, I, dl,
            get(isMicroMips ? (FP64 ? Mips::MFHC1_D64_MM : Mips::MFHC1_D32_MM)
                            : (FP64 ? Mips::MFHC1_D64 : Mips::MFHC1_D32)),
            DstReg)
        .addReg(SrcReg);
  } else
    BuildMI(MBB, I, dl, get(Mips::MFC1), DstReg).addReg(SubReg);
}

void MipsSEInstrInfo::expandBuildPairF64(MachineBasicBlock &MBB,
                                         MachineBasicBlock::iterator I,
                                         bool isMicroMips, bool FP64) const {
  unsigned DstReg = I->getOperand(0).getReg();
  unsigned LoReg = I->getOperand(1).getReg(), HiReg = I->getOperand(2).getReg();
  const MCInstrDesc& Mtc1Tdd = get(Mips::MTC1);
  DebugLoc dl = I->getDebugLoc();
  const TargetRegisterInfo &TRI = getRegisterInfo();

  // When mthc1 is available, use:
  //   mtc1 Lo, $fp
  //   mthc1 Hi, $fp
  //
  // Otherwise, for O32 FPXX ABI:
  //   spill + reload via ldc1
  // This case is handled by the frame lowering code.
  //
  // Otherwise, for FP32:
  //   mtc1 Lo, $fp
  //   mtc1 Hi, $fp + 1
  //
  // The case where dmtc1 is available doesn't need to be handled here
  // because it never creates a BuildPairF64 node.

  // FPXX on MIPS-II or MIPS32r1 should have been handled with a spill/reload
  // in MipsSEFrameLowering.cpp.
  assert(!(Subtarget.isABI_FPXX() && !Subtarget.hasMips32r2()));

  // FP64A (FP64 with nooddspreg) should have been handled with a spill/reload
  // in MipsSEFrameLowering.cpp.
  assert(!(Subtarget.isFP64bit() && !Subtarget.useOddSPReg()));

  BuildMI(MBB, I, dl, Mtc1Tdd, TRI.getSubReg(DstReg, Mips::sub_lo))
    .addReg(LoReg);

  if (Subtarget.hasMTHC1()) {
    // FIXME: The .addReg(DstReg) is a white lie used to temporarily work
    //        around a widespread bug in the -mfp64 support.
    //        The problem is that none of the 32-bit fpu ops mention the fact
    //        that they clobber the upper 32-bits of the 64-bit FPR. Fixing that
    //        requires a major overhaul of the FPU implementation which can't
    //        be done right now due to time constraints.
    //        MTHC1 is one of two instructions that are affected since they are
    //        the only instructions that don't read the lower 32-bits.
    //        We therefore pretend that it reads the bottom 32-bits to
    //        artificially create a dependency and prevent the scheduler
    //        changing the behaviour of the code.
    BuildMI(MBB, I, dl,
            get(isMicroMips ? (FP64 ? Mips::MTHC1_D64_MM : Mips::MTHC1_D32_MM)
                            : (FP64 ? Mips::MTHC1_D64 : Mips::MTHC1_D32)),
            DstReg)
        .addReg(DstReg)
        .addReg(HiReg);
  } else if (Subtarget.isABI_FPXX())
    llvm_unreachable("BuildPairF64 not expanded in frame lowering code!");
  else
    BuildMI(MBB, I, dl, Mtc1Tdd, TRI.getSubReg(DstReg, Mips::sub_hi))
      .addReg(HiReg);
}

void MipsSEInstrInfo::expandEhReturn(MachineBasicBlock &MBB,
                                     MachineBasicBlock::iterator I) const {
  // This pseudo instruction is generated as part of the lowering of
  // ISD::EH_RETURN. We convert it to a stack increment by OffsetReg, and
  // indirect jump to TargetReg
  MipsABIInfo ABI = Subtarget.getABI();
  unsigned ADDU = ABI.GetPtrAdduOp();
  unsigned SP = Subtarget.isGP64bit() ? Mips::SP_64 : Mips::SP;
  unsigned RA = Subtarget.isGP64bit() ? Mips::RA_64 : Mips::RA;
  unsigned T9 = Subtarget.isGP64bit() ? Mips::T9_64 : Mips::T9;
  unsigned ZERO = Subtarget.isGP64bit() ? Mips::ZERO_64 : Mips::ZERO;
  unsigned OffsetReg = I->getOperand(0).getReg();
  unsigned TargetReg = I->getOperand(1).getReg();

  // addu $ra, $v0, $zero
  // addu $sp, $sp, $v1
  // jr   $ra (via RetRA)
  const TargetMachine &TM = MBB.getParent()->getTarget();
  if (TM.isPositionIndependent())
    BuildMI(MBB, I, I->getDebugLoc(), get(ADDU), T9)
        .addReg(TargetReg)
        .addReg(ZERO);
  BuildMI(MBB, I, I->getDebugLoc(), get(ADDU), RA)
      .addReg(TargetReg)
      .addReg(ZERO);
  BuildMI(MBB, I, I->getDebugLoc(), get(ADDU), SP).addReg(SP).addReg(OffsetReg);
  expandRetRA(MBB, I);
}

void MipsSEInstrInfo::expandCCallPseudo(MachineBasicBlock &MBB,
                                        MachineBasicBlock::iterator I) const {
  const TargetInstrInfo *TII = Subtarget.getInstrInfo();
  DebugLoc DL = I->getDebugLoc();
  // Operand 1 contains the mask of registers to clear, with the top 16 bits
  // containing the capability registers and the bottom 16 bits containing the
  // integer registers (floating point are currently ignored).
  uint32_t ClearMask = I->getOperand(1).getImm();
  // Clear the capability registers
  MachineBasicBlock::iterator BundleStart = BuildMI(MBB, I, DL,
      TII->get(Mips::CClearLo)).addImm(ClearMask >> 16);
  // Emit the jump
  BuildMI(MBB, I, DL, TII->get(Mips::JALR64),
      Mips::RA_64).addReg(I->getOperand(0).getReg());
  // Clear the integer registers (in the delay slot)
  BuildMI(MBB, I, DL, TII->get(Mips::ClearLo)).addImm(ClearMask & 0xffff);
  // Ensure that the jump and the delay slot are not split
  MIBundleBuilder(MBB, BundleStart, std::next(BundleStart, 3));
}

// For opcodes with the ReMaterializable flag set, this function is called to
// verify the instruction is really rematable.
bool MipsSEInstrInfo::isReallyTriviallyReMaterializable(const MachineInstr &MI,
                                                        AliasAnalysis *AA) const {
  switch(MI.getOpcode()) {
    // To allow moving CSetBounds on the stack as late as possible.
    case Mips::CheriBoundedStackPseudo:
      // LLVM_DEBUG(dbgs() << "isReallyTriviallyReMaterializable: CHECKING "; MI.dump();)
      // We cannot trivially rematerialize if the size operand is a GPR since
      // That might be dead by the time we use it. Only remat
      return MI.getOperand(3).isImm();
    case Mips::CIncOffsetImm:
    case Mips::CMove:
      return MI.getOperand(1).isReg() && MI.getOperand(1).getReg() == Mips::CNULL;
    case Mips::LUi64: {
      auto Flags = MI.getOperand(1).getTargetFlags();
      if (Flags == MipsII::MO_CAPTABLE_OFF_HI) {
         return true;
      }
      return false;
    }
  default:
    return false;
  }
}

void MipsSEInstrInfo::expandCPSETUP(MachineBasicBlock &MBB,
                                    MachineBasicBlock::iterator I) const {
  unsigned GP = I->getOperand(0).getReg();
  assert(GP != Mips::T9_64);
  DebugLoc DL = I->getDebugLoc();
  const TargetInstrInfo *TII = Subtarget.getInstrInfo();
  const GlobalValue& FName = MBB.getParent()->getFunction();
  BuildMI(MBB, I, DL, TII->get(Mips::LUi64), GP)
    .addGlobalAddress(&FName, 0, MipsII::MO_GPOFF_HI);
  BuildMI(MBB, I, DL, TII->get(Mips::DADDu), GP).addReg(GP)
    .addReg(Mips::T9_64);
  BuildMI(MBB, I, DL, TII->get(Mips::DADDiu), GP).addReg(GP)
    .addGlobalAddress(&FName, 0, MipsII::MO_GPOFF_LO);
}

const MipsInstrInfo *llvm::createMipsSEInstrInfo(const MipsSubtarget &STI) {
  return new MipsSEInstrInfo(STI);
}
