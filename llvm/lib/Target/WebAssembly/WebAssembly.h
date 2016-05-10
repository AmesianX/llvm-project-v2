//===-- WebAssembly.h - Top-level interface for WebAssembly  ----*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
///
/// \file
/// \brief This file contains the entry points for global functions defined in
/// the LLVM WebAssembly back-end.
///
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_WEBASSEMBLY_WEBASSEMBLY_H
#define LLVM_LIB_TARGET_WEBASSEMBLY_WEBASSEMBLY_H

#include "llvm/Support/CodeGen.h"

namespace llvm {

class WebAssemblyTargetMachine;
class FunctionPass;

// LLVM IR passes.
FunctionPass *createWebAssemblyOptimizeReturned();

// ISel and immediate followup passes.
FunctionPass *createWebAssemblyISelDag(WebAssemblyTargetMachine &TM,
                                       CodeGenOpt::Level OptLevel);
FunctionPass *createWebAssemblyArgumentMove();
FunctionPass *createWebAssemblySetP2AlignOperands();

// Regalloc-time passes.
FunctionPass *createWebAssemblyPEI();

// Late passes.
FunctionPass *createWebAssemblyReplacePhysRegs();
FunctionPass *createWebAssemblyPrepareForLiveIntervals();
FunctionPass *createWebAssemblyOptimizeLiveIntervals();
FunctionPass *createWebAssemblyStoreResults();
FunctionPass *createWebAssemblyRegStackify();
FunctionPass *createWebAssemblyRegColoring();
FunctionPass *createWebAssemblyFixIrreducibleControlFlow();
FunctionPass *createWebAssemblyCFGStackify();
FunctionPass *createWebAssemblyLowerBrUnless();
FunctionPass *createWebAssemblyRegNumbering();
FunctionPass *createWebAssemblyPeephole();

} // end namespace llvm

#endif
