//===- MipsInstructionSelector.cpp ------------------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
/// \file
/// This file implements the targeting of the InstructionSelector class for
/// Mips.
/// \todo This should be generated by TableGen.
//===----------------------------------------------------------------------===//

#include "MipsRegisterBankInfo.h"
#include "MipsTargetMachine.h"
#include "llvm/CodeGen/GlobalISel/InstructionSelectorImpl.h"
#include "llvm/CodeGen/GlobalISel/MachineIRBuilder.h"

#define DEBUG_TYPE "mips-isel"

using namespace llvm;

namespace {

#define GET_GLOBALISEL_PREDICATE_BITSET
#include "MipsGenGlobalISel.inc"
#undef GET_GLOBALISEL_PREDICATE_BITSET

class MipsInstructionSelector : public InstructionSelector {
public:
  MipsInstructionSelector(const MipsTargetMachine &TM, const MipsSubtarget &STI,
                          const MipsRegisterBankInfo &RBI);

  bool select(MachineInstr &I, CodeGenCoverage &CoverageInfo) const override;
  static const char *getName() { return DEBUG_TYPE; }

private:
  bool selectImpl(MachineInstr &I, CodeGenCoverage &CoverageInfo) const;
  bool materialize32BitImm(unsigned DestReg, APInt Imm,
                           MachineIRBuilder &B) const;
  bool selectCopy(MachineInstr &I, MachineRegisterInfo &MRI) const;

  const MipsTargetMachine &TM;
  const MipsSubtarget &STI;
  const MipsInstrInfo &TII;
  const MipsRegisterInfo &TRI;
  const MipsRegisterBankInfo &RBI;

#define GET_GLOBALISEL_PREDICATES_DECL
#include "MipsGenGlobalISel.inc"
#undef GET_GLOBALISEL_PREDICATES_DECL

#define GET_GLOBALISEL_TEMPORARIES_DECL
#include "MipsGenGlobalISel.inc"
#undef GET_GLOBALISEL_TEMPORARIES_DECL
};

} // end anonymous namespace

#define GET_GLOBALISEL_IMPL
#include "MipsGenGlobalISel.inc"
#undef GET_GLOBALISEL_IMPL

MipsInstructionSelector::MipsInstructionSelector(
    const MipsTargetMachine &TM, const MipsSubtarget &STI,
    const MipsRegisterBankInfo &RBI)
    : InstructionSelector(), TM(TM), STI(STI), TII(*STI.getInstrInfo()),
      TRI(*STI.getRegisterInfo()), RBI(RBI),

#define GET_GLOBALISEL_PREDICATES_INIT
#include "MipsGenGlobalISel.inc"
#undef GET_GLOBALISEL_PREDICATES_INIT
#define GET_GLOBALISEL_TEMPORARIES_INIT
#include "MipsGenGlobalISel.inc"
#undef GET_GLOBALISEL_TEMPORARIES_INIT
{
}

bool MipsInstructionSelector::selectCopy(MachineInstr &I,
                                         MachineRegisterInfo &MRI) const {
  unsigned DstReg = I.getOperand(0).getReg();
  if (TargetRegisterInfo::isPhysicalRegister(DstReg))
    return true;

  const RegisterBank *RegBank = RBI.getRegBank(DstReg, MRI, TRI);
  const unsigned DstSize = MRI.getType(DstReg).getSizeInBits();

  const TargetRegisterClass *RC = &Mips::GPR32RegClass;
  if (RegBank->getID() == Mips::FPRBRegBankID) {
    if (DstSize == 32)
      RC = &Mips::FGR32RegClass;
    else if (DstSize == 64)
      RC = STI.isFP64bit() ? &Mips::FGR64RegClass : &Mips::AFGR64RegClass;
    else
      llvm_unreachable("Unsupported destination size");
  }
  if (!RBI.constrainGenericRegister(DstReg, *RC, MRI)) {
    LLVM_DEBUG(dbgs() << "Failed to constrain " << TII.getName(I.getOpcode())
                      << " operand\n");
    return false;
  }
  return true;
}

bool MipsInstructionSelector::materialize32BitImm(unsigned DestReg, APInt Imm,
                                                  MachineIRBuilder &B) const {
  assert(Imm.getBitWidth() == 32 && "Unsupported immediate size.");
  // Ori zero extends immediate. Used for values with zeros in high 16 bits.
  if (Imm.getHiBits(16).isNullValue()) {
    MachineInstr *Inst = B.buildInstr(Mips::ORi, {DestReg}, {Mips::ZERO})
                             .addImm(Imm.getLoBits(16).getLimitedValue());
    return constrainSelectedInstRegOperands(*Inst, TII, TRI, RBI);
  }
  // Lui places immediate in high 16 bits and sets low 16 bits to zero.
  if (Imm.getLoBits(16).isNullValue()) {
    MachineInstr *Inst = B.buildInstr(Mips::LUi, {DestReg}, {})
                             .addImm(Imm.getHiBits(16).getLimitedValue());
    return constrainSelectedInstRegOperands(*Inst, TII, TRI, RBI);
  }
  // ADDiu sign extends immediate. Used for values with 1s in high 17 bits.
  if (Imm.isSignedIntN(16)) {
    MachineInstr *Inst = B.buildInstr(Mips::ADDiu, {DestReg}, {Mips::ZERO})
                             .addImm(Imm.getLoBits(16).getLimitedValue());
    return constrainSelectedInstRegOperands(*Inst, TII, TRI, RBI);
  }
  // Values that cannot be materialized with single immediate instruction.
  unsigned LUiReg = B.getMRI()->createVirtualRegister(&Mips::GPR32RegClass);
  MachineInstr *LUi = B.buildInstr(Mips::LUi, {LUiReg}, {})
                          .addImm(Imm.getHiBits(16).getLimitedValue());
  MachineInstr *ORi = B.buildInstr(Mips::ORi, {DestReg}, {LUiReg})
                          .addImm(Imm.getLoBits(16).getLimitedValue());
  if (!constrainSelectedInstRegOperands(*LUi, TII, TRI, RBI))
    return false;
  if (!constrainSelectedInstRegOperands(*ORi, TII, TRI, RBI))
    return false;
  return true;
}

/// Returning Opc indicates that we failed to select MIPS instruction opcode.
static unsigned selectLoadStoreOpCode(unsigned Opc, unsigned MemSizeInBytes) {
  if (Opc == TargetOpcode::G_STORE)
    switch (MemSizeInBytes) {
    case 4:
      return Mips::SW;
    case 2:
      return Mips::SH;
    case 1:
      return Mips::SB;
    default:
      return Opc;
    }
  else
    // Unspecified extending load is selected into zeroExtending load.
    switch (MemSizeInBytes) {
    case 4:
      return Mips::LW;
    case 2:
      return Opc == TargetOpcode::G_SEXTLOAD ? Mips::LH : Mips::LHu;
    case 1:
      return Opc == TargetOpcode::G_SEXTLOAD ? Mips::LB : Mips::LBu;
    default:
      return Opc;
    }
}

bool MipsInstructionSelector::select(MachineInstr &I,
                                     CodeGenCoverage &CoverageInfo) const {

  MachineBasicBlock &MBB = *I.getParent();
  MachineFunction &MF = *MBB.getParent();
  MachineRegisterInfo &MRI = MF.getRegInfo();

  if (!isPreISelGenericOpcode(I.getOpcode())) {
    if (I.isCopy())
      return selectCopy(I, MRI);

    return true;
  }

  if (I.getOpcode() == Mips::G_MUL) {
    MachineInstr *Mul = BuildMI(MBB, I, I.getDebugLoc(), TII.get(Mips::MUL))
                            .add(I.getOperand(0))
                            .add(I.getOperand(1))
                            .add(I.getOperand(2));
    if (!constrainSelectedInstRegOperands(*Mul, TII, TRI, RBI))
      return false;
    Mul->getOperand(3).setIsDead(true);
    Mul->getOperand(4).setIsDead(true);

    I.eraseFromParent();
    return true;
  }

  if (selectImpl(I, CoverageInfo))
    return true;

  MachineInstr *MI = nullptr;
  using namespace TargetOpcode;

  switch (I.getOpcode()) {
  case G_UMULH: {
    unsigned PseudoMULTuReg = MRI.createVirtualRegister(&Mips::ACC64RegClass);
    MachineInstr *PseudoMULTu, *PseudoMove;

    PseudoMULTu = BuildMI(MBB, I, I.getDebugLoc(), TII.get(Mips::PseudoMULTu))
                      .addDef(PseudoMULTuReg)
                      .add(I.getOperand(1))
                      .add(I.getOperand(2));
    if (!constrainSelectedInstRegOperands(*PseudoMULTu, TII, TRI, RBI))
      return false;

    PseudoMove = BuildMI(MBB, I, I.getDebugLoc(), TII.get(Mips::PseudoMFHI))
                     .addDef(I.getOperand(0).getReg())
                     .addUse(PseudoMULTuReg);
    if (!constrainSelectedInstRegOperands(*PseudoMove, TII, TRI, RBI))
      return false;

    I.eraseFromParent();
    return true;
  }
  case G_GEP: {
    MI = BuildMI(MBB, I, I.getDebugLoc(), TII.get(Mips::ADDu))
             .add(I.getOperand(0))
             .add(I.getOperand(1))
             .add(I.getOperand(2));
    break;
  }
  case G_FRAME_INDEX: {
    MI = BuildMI(MBB, I, I.getDebugLoc(), TII.get(Mips::ADDiu))
             .add(I.getOperand(0))
             .add(I.getOperand(1))
             .addImm(0);
    break;
  }
  case G_BRCOND: {
    MI = BuildMI(MBB, I, I.getDebugLoc(), TII.get(Mips::BNE))
             .add(I.getOperand(0))
             .addUse(Mips::ZERO)
             .add(I.getOperand(1));
    break;
  }
  case G_PHI: {
    const unsigned DestReg = I.getOperand(0).getReg();
    const unsigned DestRegBank = RBI.getRegBank(DestReg, MRI, TRI)->getID();
    const unsigned OpSize = MRI.getType(DestReg).getSizeInBits();

    if (DestRegBank != Mips::GPRBRegBankID || OpSize != 32)
      return false;

    const TargetRegisterClass *DefRC = &Mips::GPR32RegClass;
    I.setDesc(TII.get(TargetOpcode::PHI));
    return RBI.constrainGenericRegister(DestReg, *DefRC, MRI);
  }
  case G_STORE:
  case G_LOAD:
  case G_ZEXTLOAD:
  case G_SEXTLOAD: {
    const unsigned DestReg = I.getOperand(0).getReg();
    const unsigned DestRegBank = RBI.getRegBank(DestReg, MRI, TRI)->getID();
    const unsigned OpSize = MRI.getType(DestReg).getSizeInBits();
    const unsigned OpMemSizeInBytes = (*I.memoperands_begin())->getSize();

    if (DestRegBank != Mips::GPRBRegBankID || OpSize != 32)
      return false;

    const unsigned NewOpc =
        selectLoadStoreOpCode(I.getOpcode(), OpMemSizeInBytes);
    if (NewOpc == I.getOpcode())
      return false;

    MI = BuildMI(MBB, I, I.getDebugLoc(), TII.get(NewOpc))
             .add(I.getOperand(0))
             .add(I.getOperand(1))
             .addImm(0)
             .addMemOperand(*I.memoperands_begin());
    break;
  }
  case G_UDIV:
  case G_UREM:
  case G_SDIV:
  case G_SREM: {
    unsigned HILOReg = MRI.createVirtualRegister(&Mips::ACC64RegClass);
    bool IsSigned = I.getOpcode() == G_SREM || I.getOpcode() == G_SDIV;
    bool IsDiv = I.getOpcode() == G_UDIV || I.getOpcode() == G_SDIV;

    MachineInstr *PseudoDIV, *PseudoMove;
    PseudoDIV = BuildMI(MBB, I, I.getDebugLoc(),
                        TII.get(IsSigned ? Mips::PseudoSDIV : Mips::PseudoUDIV))
                    .addDef(HILOReg)
                    .add(I.getOperand(1))
                    .add(I.getOperand(2));
    if (!constrainSelectedInstRegOperands(*PseudoDIV, TII, TRI, RBI))
      return false;

    PseudoMove = BuildMI(MBB, I, I.getDebugLoc(),
                         TII.get(IsDiv ? Mips::PseudoMFLO : Mips::PseudoMFHI))
                     .addDef(I.getOperand(0).getReg())
                     .addUse(HILOReg);
    if (!constrainSelectedInstRegOperands(*PseudoMove, TII, TRI, RBI))
      return false;

    I.eraseFromParent();
    return true;
  }
  case G_SELECT: {
    // Handle operands with pointer type.
    MI = BuildMI(MBB, I, I.getDebugLoc(), TII.get(Mips::MOVN_I_I))
             .add(I.getOperand(0))
             .add(I.getOperand(2))
             .add(I.getOperand(1))
             .add(I.getOperand(3));
    break;
  }
  case G_CONSTANT: {
    MachineIRBuilder B(I);
    if (!materialize32BitImm(I.getOperand(0).getReg(),
                             I.getOperand(1).getCImm()->getValue(), B))
      return false;

    I.eraseFromParent();
    return true;
  }
  case G_FCONSTANT: {
    const APFloat &FPimm = I.getOperand(1).getFPImm()->getValueAPF();
    APInt APImm = FPimm.bitcastToAPInt();
    unsigned Size = MRI.getType(I.getOperand(0).getReg()).getSizeInBits();

    if (Size == 32) {
      unsigned GPRReg = MRI.createVirtualRegister(&Mips::GPR32RegClass);
      MachineIRBuilder B(I);
      if (!materialize32BitImm(GPRReg, APImm, B))
        return false;

      MachineInstrBuilder MTC1 =
          B.buildInstr(Mips::MTC1, {I.getOperand(0).getReg()}, {GPRReg});
      if (!MTC1.constrainAllUses(TII, TRI, RBI))
        return false;
    }
    if (Size == 64) {
      unsigned GPRRegHigh = MRI.createVirtualRegister(&Mips::GPR32RegClass);
      unsigned GPRRegLow = MRI.createVirtualRegister(&Mips::GPR32RegClass);
      MachineIRBuilder B(I);
      if (!materialize32BitImm(GPRRegHigh, APImm.getHiBits(32).trunc(32), B))
        return false;
      if (!materialize32BitImm(GPRRegLow, APImm.getLoBits(32).trunc(32), B))
        return false;

      MachineInstrBuilder PairF64 = B.buildInstr(
          STI.isFP64bit() ? Mips::BuildPairF64_64 : Mips::BuildPairF64,
          {I.getOperand(0).getReg()}, {GPRRegLow, GPRRegHigh});
      if (!PairF64.constrainAllUses(TII, TRI, RBI))
        return false;
    }

    I.eraseFromParent();
    return true;
  }
  case G_GLOBAL_VALUE: {
    if (MF.getTarget().isPositionIndependent())
      return false;

    const llvm::GlobalValue *GVal = I.getOperand(1).getGlobal();
    unsigned LUiReg = MRI.createVirtualRegister(&Mips::GPR32RegClass);
    MachineInstr *LUi, *ADDiu;

    LUi = BuildMI(MBB, I, I.getDebugLoc(), TII.get(Mips::LUi))
              .addDef(LUiReg)
              .addGlobalAddress(GVal);
    LUi->getOperand(1).setTargetFlags(MipsII::MO_ABS_HI);

    ADDiu = BuildMI(MBB, I, I.getDebugLoc(), TII.get(Mips::ADDiu))
                .addDef(I.getOperand(0).getReg())
                .addUse(LUiReg)
                .addGlobalAddress(GVal);
    ADDiu->getOperand(2).setTargetFlags(MipsII::MO_ABS_LO);

    if (!constrainSelectedInstRegOperands(*LUi, TII, TRI, RBI))
      return false;
    if (!constrainSelectedInstRegOperands(*ADDiu, TII, TRI, RBI))
      return false;

    I.eraseFromParent();
    return true;
  }
  case G_ICMP: {
    struct Instr {
      unsigned Opcode, Def, LHS, RHS;
      Instr(unsigned Opcode, unsigned Def, unsigned LHS, unsigned RHS)
          : Opcode(Opcode), Def(Def), LHS(LHS), RHS(RHS){};

      bool hasImm() const {
        if (Opcode == Mips::SLTiu || Opcode == Mips::XORi)
          return true;
        return false;
      }
    };

    SmallVector<struct Instr, 2> Instructions;
    unsigned ICMPReg = I.getOperand(0).getReg();
    unsigned Temp = MRI.createVirtualRegister(&Mips::GPR32RegClass);
    unsigned LHS = I.getOperand(2).getReg();
    unsigned RHS = I.getOperand(3).getReg();
    CmpInst::Predicate Cond =
        static_cast<CmpInst::Predicate>(I.getOperand(1).getPredicate());

    switch (Cond) {
    case CmpInst::ICMP_EQ: // LHS == RHS -> (LHS ^ RHS) < 1
      Instructions.emplace_back(Mips::XOR, Temp, LHS, RHS);
      Instructions.emplace_back(Mips::SLTiu, ICMPReg, Temp, 1);
      break;
    case CmpInst::ICMP_NE: // LHS != RHS -> 0 < (LHS ^ RHS)
      Instructions.emplace_back(Mips::XOR, Temp, LHS, RHS);
      Instructions.emplace_back(Mips::SLTu, ICMPReg, Mips::ZERO, Temp);
      break;
    case CmpInst::ICMP_UGT: // LHS >  RHS -> RHS < LHS
      Instructions.emplace_back(Mips::SLTu, ICMPReg, RHS, LHS);
      break;
    case CmpInst::ICMP_UGE: // LHS >= RHS -> !(LHS < RHS)
      Instructions.emplace_back(Mips::SLTu, Temp, LHS, RHS);
      Instructions.emplace_back(Mips::XORi, ICMPReg, Temp, 1);
      break;
    case CmpInst::ICMP_ULT: // LHS <  RHS -> LHS < RHS
      Instructions.emplace_back(Mips::SLTu, ICMPReg, LHS, RHS);
      break;
    case CmpInst::ICMP_ULE: // LHS <= RHS -> !(RHS < LHS)
      Instructions.emplace_back(Mips::SLTu, Temp, RHS, LHS);
      Instructions.emplace_back(Mips::XORi, ICMPReg, Temp, 1);
      break;
    case CmpInst::ICMP_SGT: // LHS >  RHS -> RHS < LHS
      Instructions.emplace_back(Mips::SLT, ICMPReg, RHS, LHS);
      break;
    case CmpInst::ICMP_SGE: // LHS >= RHS -> !(LHS < RHS)
      Instructions.emplace_back(Mips::SLT, Temp, LHS, RHS);
      Instructions.emplace_back(Mips::XORi, ICMPReg, Temp, 1);
      break;
    case CmpInst::ICMP_SLT: // LHS <  RHS -> LHS < RHS
      Instructions.emplace_back(Mips::SLT, ICMPReg, LHS, RHS);
      break;
    case CmpInst::ICMP_SLE: // LHS <= RHS -> !(RHS < LHS)
      Instructions.emplace_back(Mips::SLT, Temp, RHS, LHS);
      Instructions.emplace_back(Mips::XORi, ICMPReg, Temp, 1);
      break;
    default:
      return false;
    }

    MachineIRBuilder B(I);
    for (const struct Instr &Instruction : Instructions) {
      MachineInstrBuilder MIB = B.buildInstr(
          Instruction.Opcode, {Instruction.Def}, {Instruction.LHS});

      if (Instruction.hasImm())
        MIB.addImm(Instruction.RHS);
      else
        MIB.addUse(Instruction.RHS);

      if (!MIB.constrainAllUses(TII, TRI, RBI))
        return false;
    }

    I.eraseFromParent();
    return true;
  }
  default:
    return false;
  }

  I.eraseFromParent();
  return constrainSelectedInstRegOperands(*MI, TII, TRI, RBI);
}

namespace llvm {
InstructionSelector *createMipsInstructionSelector(const MipsTargetMachine &TM,
                                                   MipsSubtarget &Subtarget,
                                                   MipsRegisterBankInfo &RBI) {
  return new MipsInstructionSelector(TM, Subtarget, RBI);
}
} // end namespace llvm
