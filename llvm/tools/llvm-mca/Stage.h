//===---------------------- Stage.h -----------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
/// \file
///
/// This file defines a stage.
/// A chain of stages compose an instruction pipeline.
///
//===----------------------------------------------------------------------===//

#ifndef LLVM_TOOLS_LLVM_MCA_STAGE_H
#define LLVM_TOOLS_LLVM_MCA_STAGE_H

#include "HWEventListener.h"
#include "llvm/Support/Error.h"
#include <set>

namespace mca {

class InstRef;

class Stage {
  Stage(const Stage &Other) = delete;
  Stage &operator=(const Stage &Other) = delete;
  std::set<HWEventListener *> Listeners;

public:
  /// A Stage's execute() returns Continue, Stop, or an error.  Returning
  /// Continue means that the stage successfully completed its 'execute'
  /// action, and that the instruction being processed can be moved to the next
  /// pipeline stage during this cycle.  Continue allows the pipeline to
  /// continue calling 'execute' on subsequent stages.  Returning Stop
  /// signifies that the stage ran into an error, and tells the pipeline to stop
  /// passing the instruction to subsequent stages during this cycle.  Any
  /// failures that occur during 'execute' are represented by the error variant
  /// that is provided by the Expected template.
  enum State { Stop, Continue };
  using Status = llvm::Expected<State>;

protected:
  const std::set<HWEventListener *> &getListeners() const { return Listeners; }

public:
  Stage();
  virtual ~Stage() = default;

  /// Called prior to preExecute to ensure that the stage has items that it
  /// is to process.  For example, a FetchStage might have more instructions
  /// that need to be processed, or a RCU might have items that have yet to
  /// retire.
  virtual bool hasWorkToComplete() const = 0;

  /// Called once at the start of each cycle.  This can be used as a setup
  /// phase to prepare for the executions during the cycle.
  virtual void cycleStart() {}

  /// Called once at the end of each cycle.
  virtual void cycleEnd() {}

  /// Called prior to executing the list of stages.
  /// This can be called multiple times per cycle.
  virtual void preExecute() {}

  /// Called as a cleanup and finalization phase after each execution.
  /// This will only be called if all stages return a success from their
  /// execute callback.  This can be called multiple times per cycle.
  virtual void postExecute() {}

  /// The primary action that this stage performs.
  /// Returning false prevents successor stages from having their 'execute'
  /// routine called.  This can be called multiple times during a single cycle.
  virtual Status execute(InstRef &IR) = 0;

  /// Add a listener to receive callbacks during the execution of this stage.
  void addListener(HWEventListener *Listener);

  /// Notify listeners of a particular hardware event.
  template <typename EventT> void notifyEvent(const EventT &Event) {
    for (HWEventListener *Listener : Listeners)
      Listener->onEvent(Event);
  }
};

} // namespace mca
#endif // LLVM_TOOLS_LLVM_MCA_STAGE_H
