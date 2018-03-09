
//===----------------------- HWEventListener.h ------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
/// \file
///
/// This file defines the main interface for hardware event listeners.
///
//===----------------------------------------------------------------------===//

#ifndef LLVM_TOOLS_LLVM_MCA_HWEVENTLISTENER_H
#define LLVM_TOOLS_LLVM_MCA_HWEVENTLISTENER_H

#include "llvm/ADT/ArrayRef.h"
#include <utility>

namespace mca {

class HWEventListener {
public:
  // Events generated by the Retire Control Unit.
  virtual void onInstructionRetired(unsigned Index) {};

  // Events generated by the Scheduler.
  using ResourceRef = std::pair<uint64_t, uint64_t>;
  virtual void
  onInstructionIssued(unsigned Index,
                      const llvm::ArrayRef<std::pair<ResourceRef, unsigned>> &Used) {}
  virtual void onInstructionExecuted(unsigned Index) {}
  virtual void onInstructionReady(unsigned Index) {}
  virtual void onResourceAvailable(const ResourceRef &RRef) {};

  // Events generated by the Dispatch logic.
  virtual void onInstructionDispatched(unsigned Index) {}

  // Generic events generated by the Backend.
  virtual void onCycleBegin(unsigned Cycle) {}
  virtual void onCycleEnd(unsigned Cycle) {}

  virtual ~HWEventListener() = default;
  virtual void anchor();
};

} // namespace mca

#endif
