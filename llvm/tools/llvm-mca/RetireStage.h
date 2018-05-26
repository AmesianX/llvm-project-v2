//===---------------------- RetireStage.h -----------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
/// \file
///
/// This file defines the retire stage of an instruction pipeline.
/// The RetireStage represents the process logic that interacts with the
/// simulated RetireControlUnit hardware.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_TOOLS_LLVM_MCA_RETIRE_STAGE_H
#define LLVM_TOOLS_LLVM_MCA_RETIRE_STAGE_H

#include "RegisterFile.h"
#include "RetireControlUnit.h"
#include "Stage.h"

namespace mca {

class Backend;

class RetireStage : public Stage {
  // Owner will go away when we move listeners/eventing to the stages.
  Backend *Owner;
  RetireControlUnit &RCU;
  RegisterFile &PRF;

public:
  RetireStage(Backend *B, RetireControlUnit &R, RegisterFile &F)
      : Stage(), Owner(B), RCU(R), PRF(F) {}
  RetireStage(const RetireStage &Other) = delete;
  RetireStage &operator=(const RetireStage &Other) = delete;

  virtual void preExecute(const InstRef &IR) override final;
  virtual bool execute(InstRef &IR) override final { return true; }
  void notifyInstructionRetired(const InstRef &IR);
  void onInstructionExecuted(unsigned TokenID);
};

} // namespace mca

#endif // LLVM_TOOLS_LLVM_MCA_RETIRE_STAGE_H
