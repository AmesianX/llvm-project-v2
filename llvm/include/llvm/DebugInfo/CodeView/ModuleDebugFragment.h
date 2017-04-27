//===- ModuleDebugFragment.h ------------------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_DEBUGINFO_CODEVIEW_MODULEDEBUGFRAGMENT_H
#define LLVM_DEBUGINFO_CODEVIEW_MODULEDEBUGFRAGMENT_H

#include "llvm/DebugInfo/CodeView/CodeView.h"
#include "llvm/Support/Casting.h"

namespace llvm {
namespace codeview {

class ModuleDebugFragment {
public:
  explicit ModuleDebugFragment(ModuleDebugFragmentKind Kind) : Kind(Kind) {}

  virtual ~ModuleDebugFragment();
  ModuleDebugFragmentKind kind() const { return Kind; }

protected:
  ModuleDebugFragmentKind Kind;
};

} // namespace codeview
} // namespace llvm

#endif // LLVM_DEBUGINFO_CODEVIEW_MODULEDEBUGFRAGMENT_H
