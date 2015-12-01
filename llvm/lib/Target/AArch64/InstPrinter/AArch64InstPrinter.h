//===-- AArch64InstPrinter.h - Convert AArch64 MCInst to assembly syntax --===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This class prints an AArch64 MCInst to a .s file.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_AARCH64_INSTPRINTER_AARCH64INSTPRINTER_H
#define LLVM_LIB_TARGET_AARCH64_INSTPRINTER_AARCH64INSTPRINTER_H

#include "MCTargetDesc/AArch64MCTargetDesc.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/MC/MCInstPrinter.h"
#include "llvm/MC/MCSubtargetInfo.h"

namespace llvm {

class MCOperand;

class AArch64InstPrinter : public MCInstPrinter {
public:
  AArch64InstPrinter(const MCAsmInfo &MAI, const MCInstrInfo &MII,
                     const MCRegisterInfo &MRI);

  void printInst(const MCInst *MI, raw_ostream &O, StringRef Annot,
                 const MCSubtargetInfo &STI) override;
  void printRegName(raw_ostream &OS, unsigned RegNo) const override;

  // Autogenerated by tblgen.
  virtual void printInstruction(const MCInst *MI, const MCSubtargetInfo &STI,
                                raw_ostream &O);
  virtual bool printAliasInstr(const MCInst *MI, const MCSubtargetInfo &STI,
                               raw_ostream &O);
  virtual void printCustomAliasOperand(const MCInst *MI, unsigned OpIdx,
                                       unsigned PrintMethodIdx,
                                       const MCSubtargetInfo &STI,
                                       raw_ostream &O);
  virtual StringRef getRegName(unsigned RegNo) const {
    return getRegisterName(RegNo);
  }
  static const char *getRegisterName(unsigned RegNo,
                                     unsigned AltIdx = AArch64::NoRegAltName);

protected:
  bool printSysAlias(const MCInst *MI, const MCSubtargetInfo &STI,
                     raw_ostream &O);
  // Operand printers
  void printOperand(const MCInst *MI, unsigned OpNo, const MCSubtargetInfo &STI,
                    raw_ostream &O);
  void printHexImm(const MCInst *MI, unsigned OpNo, const MCSubtargetInfo &STI,
                   raw_ostream &O);
  void printPostIncOperand(const MCInst *MI, unsigned OpNo, unsigned Imm,
                           raw_ostream &O);
  template <int Amount>
  void printPostIncOperand(const MCInst *MI, unsigned OpNo,
                           const MCSubtargetInfo &STI, raw_ostream &O) {
    printPostIncOperand(MI, OpNo, Amount, O);
  }

  void printVRegOperand(const MCInst *MI, unsigned OpNo,
                        const MCSubtargetInfo &STI, raw_ostream &O);
  void printSysCROperand(const MCInst *MI, unsigned OpNo,
                         const MCSubtargetInfo &STI, raw_ostream &O);
  void printAddSubImm(const MCInst *MI, unsigned OpNum,
                      const MCSubtargetInfo &STI, raw_ostream &O);
  void printLogicalImm32(const MCInst *MI, unsigned OpNum,
                         const MCSubtargetInfo &STI, raw_ostream &O);
  void printLogicalImm64(const MCInst *MI, unsigned OpNum,
                         const MCSubtargetInfo &STI, raw_ostream &O);
  void printShifter(const MCInst *MI, unsigned OpNum,
                    const MCSubtargetInfo &STI, raw_ostream &O);
  void printShiftedRegister(const MCInst *MI, unsigned OpNum,
                            const MCSubtargetInfo &STI, raw_ostream &O);
  void printExtendedRegister(const MCInst *MI, unsigned OpNum,
                             const MCSubtargetInfo &STI, raw_ostream &O);
  void printArithExtend(const MCInst *MI, unsigned OpNum,
                        const MCSubtargetInfo &STI, raw_ostream &O);

  void printMemExtend(const MCInst *MI, unsigned OpNum, raw_ostream &O,
                      char SrcRegKind, unsigned Width);
  template <char SrcRegKind, unsigned Width>
  void printMemExtend(const MCInst *MI, unsigned OpNum,
                      const MCSubtargetInfo &STI, raw_ostream &O) {
    printMemExtend(MI, OpNum, O, SrcRegKind, Width);
  }

  void printCondCode(const MCInst *MI, unsigned OpNum,
                     const MCSubtargetInfo &STI, raw_ostream &O);
  void printInverseCondCode(const MCInst *MI, unsigned OpNum,
                            const MCSubtargetInfo &STI, raw_ostream &O);
  void printAlignedLabel(const MCInst *MI, unsigned OpNum,
                         const MCSubtargetInfo &STI, raw_ostream &O);
  void printUImm12Offset(const MCInst *MI, unsigned OpNum, unsigned Scale,
                         raw_ostream &O);
  void printAMIndexedWB(const MCInst *MI, unsigned OpNum, unsigned Scale,
                        raw_ostream &O);

  template <int Scale>
  void printUImm12Offset(const MCInst *MI, unsigned OpNum,
                         const MCSubtargetInfo &STI, raw_ostream &O) {
    printUImm12Offset(MI, OpNum, Scale, O);
  }

  template <int BitWidth>
  void printAMIndexedWB(const MCInst *MI, unsigned OpNum,
                        const MCSubtargetInfo &STI, raw_ostream &O) {
    printAMIndexedWB(MI, OpNum, BitWidth / 8, O);
  }

  void printAMNoIndex(const MCInst *MI, unsigned OpNum,
                      const MCSubtargetInfo &STI, raw_ostream &O);

  template <int Scale>
  void printImmScale(const MCInst *MI, unsigned OpNum,
                     const MCSubtargetInfo &STI, raw_ostream &O);

  void printPrefetchOp(const MCInst *MI, unsigned OpNum,
                       const MCSubtargetInfo &STI, raw_ostream &O);

  void printPSBHintOp(const MCInst *MI, unsigned OpNum,
                      const MCSubtargetInfo &STI, raw_ostream &O);

  void printFPImmOperand(const MCInst *MI, unsigned OpNum,
                         const MCSubtargetInfo &STI, raw_ostream &O);

  void printVectorList(const MCInst *MI, unsigned OpNum,
                       const MCSubtargetInfo &STI, raw_ostream &O,
                       StringRef LayoutSuffix);

  /// Print a list of vector registers where the type suffix is implicit
  /// (i.e. attached to the instruction rather than the registers).
  void printImplicitlyTypedVectorList(const MCInst *MI, unsigned OpNum,
                                      const MCSubtargetInfo &STI,
                                      raw_ostream &O);

  template <unsigned NumLanes, char LaneKind>
  void printTypedVectorList(const MCInst *MI, unsigned OpNum,
                            const MCSubtargetInfo &STI, raw_ostream &O);

  void printVectorIndex(const MCInst *MI, unsigned OpNum,
                        const MCSubtargetInfo &STI, raw_ostream &O);
  void printAdrpLabel(const MCInst *MI, unsigned OpNum,
                      const MCSubtargetInfo &STI, raw_ostream &O);
  void printBarrierOption(const MCInst *MI, unsigned OpNum,
                          const MCSubtargetInfo &STI, raw_ostream &O);
  void printMSRSystemRegister(const MCInst *MI, unsigned OpNum,
                              const MCSubtargetInfo &STI, raw_ostream &O);
  void printMRSSystemRegister(const MCInst *MI, unsigned OpNum,
                              const MCSubtargetInfo &STI, raw_ostream &O);
  void printSystemPStateField(const MCInst *MI, unsigned OpNum,
                              const MCSubtargetInfo &STI, raw_ostream &O);
  void printSIMDType10Operand(const MCInst *MI, unsigned OpNum,
                              const MCSubtargetInfo &STI, raw_ostream &O);
  template<unsigned size>
  void printGPRSeqPairsClassOperand(const MCInst *MI, unsigned OpNum,
                                    const MCSubtargetInfo &STI,
                                    raw_ostream &O);
};

class AArch64AppleInstPrinter : public AArch64InstPrinter {
public:
  AArch64AppleInstPrinter(const MCAsmInfo &MAI, const MCInstrInfo &MII,
                          const MCRegisterInfo &MRI);

  void printInst(const MCInst *MI, raw_ostream &O, StringRef Annot,
                 const MCSubtargetInfo &STI) override;

  void printInstruction(const MCInst *MI, const MCSubtargetInfo &STI,
                        raw_ostream &O) override;
  bool printAliasInstr(const MCInst *MI, const MCSubtargetInfo &STI,
                       raw_ostream &O) override;
  void printCustomAliasOperand(const MCInst *MI, unsigned OpIdx,
                               unsigned PrintMethodIdx,
                               const MCSubtargetInfo &STI,
                               raw_ostream &O) override;
  StringRef getRegName(unsigned RegNo) const override {
    return getRegisterName(RegNo);
  }
  static const char *getRegisterName(unsigned RegNo,
                                     unsigned AltIdx = AArch64::NoRegAltName);
};
}

#endif
