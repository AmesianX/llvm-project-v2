//=- WebAssemblySubtarget.h - Define Subtarget for the WebAssembly -*- C++ -*-//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
///
/// \file
/// This file declares the WebAssembly-specific subclass of
/// TargetSubtarget.
///
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_WEBASSEMBLY_WEBASSEMBLYSUBTARGET_H
#define LLVM_LIB_TARGET_WEBASSEMBLY_WEBASSEMBLYSUBTARGET_H

#include "WebAssemblyFrameLowering.h"
#include "WebAssemblyISelLowering.h"
#include "WebAssemblyInstrInfo.h"
#include "WebAssemblySelectionDAGInfo.h"
#include "llvm/CodeGen/TargetSubtargetInfo.h"
#include <string>

#define GET_SUBTARGETINFO_HEADER
#include "WebAssemblyGenSubtargetInfo.inc"

namespace llvm {

class WebAssemblySubtarget final : public WebAssemblyGenSubtargetInfo {
  enum SIMDEnum {
    NoSIMD,
    SIMD128,
    UnimplementedSIMD128,
  } SIMDLevel = NoSIMD;

  bool HasAtomics = false;
  bool HasNontrappingFPToInt = false;
  bool HasSignExt = false;
  bool HasExceptionHandling = false;
  bool HasBulkMemory = false;

  /// String name of used CPU.
  std::string CPUString;

  /// What processor and OS we're targeting.
  Triple TargetTriple;

  WebAssemblyFrameLowering FrameLowering;
  WebAssemblyInstrInfo InstrInfo;
  WebAssemblySelectionDAGInfo TSInfo;
  WebAssemblyTargetLowering TLInfo;

  /// Initializes using CPUString and the passed in feature string so that we
  /// can use initializer lists for subtarget initialization.
  WebAssemblySubtarget &initializeSubtargetDependencies(StringRef FS);

public:
  /// This constructor initializes the data members to match that
  /// of the specified triple.
  WebAssemblySubtarget(const Triple &TT, const std::string &CPU,
                       const std::string &FS, const TargetMachine &TM);

  const WebAssemblySelectionDAGInfo *getSelectionDAGInfo() const override {
    return &TSInfo;
  }
  const WebAssemblyFrameLowering *getFrameLowering() const override {
    return &FrameLowering;
  }
  const WebAssemblyTargetLowering *getTargetLowering() const override {
    return &TLInfo;
  }
  const WebAssemblyInstrInfo *getInstrInfo() const override {
    return &InstrInfo;
  }
  const WebAssemblyRegisterInfo *getRegisterInfo() const override {
    return &getInstrInfo()->getRegisterInfo();
  }
  const Triple &getTargetTriple() const { return TargetTriple; }
  bool enableMachineScheduler() const override;
  bool useAA() const override;

  // Predicates used by WebAssemblyInstrInfo.td.
  bool hasAddr64() const { return TargetTriple.isArch64Bit(); }
  bool hasSIMD128() const { return SIMDLevel >= SIMD128; }
  bool hasUnimplementedSIMD128() const {
    return SIMDLevel >= UnimplementedSIMD128;
  }
  bool hasAtomics() const { return HasAtomics; }
  bool hasNontrappingFPToInt() const { return HasNontrappingFPToInt; }
  bool hasSignExt() const { return HasSignExt; }
  bool hasExceptionHandling() const { return HasExceptionHandling; }
  bool hasBulkMemory() const { return HasBulkMemory; }

  /// Parses features string setting specified subtarget options. Definition of
  /// function is auto generated by tblgen.
  void ParseSubtargetFeatures(StringRef CPU, StringRef FS);
};

} // end namespace llvm

#endif
