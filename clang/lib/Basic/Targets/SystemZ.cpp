//===--- SystemZ.cpp - Implement SystemZ target feature support -----------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file implements SystemZ TargetInfo objects.
//
//===----------------------------------------------------------------------===//

#include "SystemZ.h"
#include "clang/Basic/Builtins.h"
#include "clang/Basic/LangOptions.h"
#include "clang/Basic/MacroBuilder.h"
#include "clang/Basic/TargetBuiltins.h"
#include "llvm/ADT/StringSwitch.h"

using namespace clang;
using namespace clang::targets;

const Builtin::Info SystemZTargetInfo::BuiltinInfo[] = {
#define BUILTIN(ID, TYPE, ATTRS)                                               \
  {#ID, TYPE, ATTRS, nullptr, ALL_LANGUAGES, nullptr},
#define TARGET_BUILTIN(ID, TYPE, ATTRS, FEATURE)                               \
  {#ID, TYPE, ATTRS, nullptr, ALL_LANGUAGES, FEATURE},
#include "clang/Basic/BuiltinsSystemZ.def"
};

const char *const SystemZTargetInfo::GCCRegNames[] = {
    "r0",  "r1",  "r2",  "r3",  "r4",  "r5",  "r6",  "r7",
    "r8",  "r9",  "r10", "r11", "r12", "r13", "r14", "r15",
    "f0",  "f2",  "f4",  "f6",  "f1",  "f3",  "f5",  "f7",
    "f8",  "f10", "f12", "f14", "f9",  "f11", "f13", "f15",
    /*ap*/"", "cc", /*fp*/"", /*rp*/"", "a0",  "a1",
    "v16", "v18", "v20", "v22", "v17", "v19", "v21", "v23",
    "v24", "v26", "v28", "v30", "v25", "v27", "v29", "v31"
};

const TargetInfo::AddlRegName GCCAddlRegNames[] = {
    {{"v0"}, 16}, {{"v2"},  17}, {{"v4"},  18}, {{"v6"},  19},
    {{"v1"}, 20}, {{"v3"},  21}, {{"v5"},  22}, {{"v7"},  23},
    {{"v8"}, 24}, {{"v10"}, 25}, {{"v12"}, 26}, {{"v14"}, 27},
    {{"v9"}, 28}, {{"v11"}, 29}, {{"v13"}, 30}, {{"v15"}, 31}
};

ArrayRef<const char *> SystemZTargetInfo::getGCCRegNames() const {
  return llvm::makeArrayRef(GCCRegNames);
}

ArrayRef<TargetInfo::AddlRegName> SystemZTargetInfo::getGCCAddlRegNames() const {
  return llvm::makeArrayRef(GCCAddlRegNames);
}

bool SystemZTargetInfo::validateAsmConstraint(
    const char *&Name, TargetInfo::ConstraintInfo &Info) const {
  switch (*Name) {
  default:
    return false;

  case 'a': // Address register
  case 'd': // Data register (equivalent to 'r')
  case 'f': // Floating-point register
  case 'v': // Vector register
    Info.setAllowsRegister();
    return true;

  case 'I': // Unsigned 8-bit constant
  case 'J': // Unsigned 12-bit constant
  case 'K': // Signed 16-bit constant
  case 'L': // Signed 20-bit displacement (on all targets we support)
  case 'M': // 0x7fffffff
    return true;

  case 'Q': // Memory with base and unsigned 12-bit displacement
  case 'R': // Likewise, plus an index
  case 'S': // Memory with base and signed 20-bit displacement
  case 'T': // Likewise, plus an index
    Info.setAllowsMemory();
    return true;
  }
}

int SystemZTargetInfo::getISARevision(StringRef Name) const {
  return llvm::StringSwitch<int>(Name)
      .Cases("arch8", "z10", 8)
      .Cases("arch9", "z196", 9)
      .Cases("arch10", "zEC12", 10)
      .Cases("arch11", "z13", 11)
      .Cases("arch12", "z14", 12)
      .Default(-1);
}

bool SystemZTargetInfo::hasFeature(StringRef Feature) const {
  return llvm::StringSwitch<bool>(Feature)
      .Case("systemz", true)
      .Case("arch8", ISARevision >= 8)
      .Case("arch9", ISARevision >= 9)
      .Case("arch10", ISARevision >= 10)
      .Case("arch11", ISARevision >= 11)
      .Case("arch12", ISARevision >= 12)
      .Case("htm", HasTransactionalExecution)
      .Case("vx", HasVector)
      .Default(false);
}

void SystemZTargetInfo::getTargetDefines(const LangOptions &Opts,
                                         MacroBuilder &Builder) const {
  Builder.defineMacro("__s390__");
  Builder.defineMacro("__s390x__");
  Builder.defineMacro("__zarch__");
  Builder.defineMacro("__LONG_DOUBLE_128__");

  Builder.defineMacro("__ARCH__", Twine(ISARevision));

  Builder.defineMacro("__GCC_HAVE_SYNC_COMPARE_AND_SWAP_1");
  Builder.defineMacro("__GCC_HAVE_SYNC_COMPARE_AND_SWAP_2");
  Builder.defineMacro("__GCC_HAVE_SYNC_COMPARE_AND_SWAP_4");
  Builder.defineMacro("__GCC_HAVE_SYNC_COMPARE_AND_SWAP_8");

  if (HasTransactionalExecution)
    Builder.defineMacro("__HTM__");
  if (HasVector)
    Builder.defineMacro("__VX__");
  if (Opts.ZVector)
    Builder.defineMacro("__VEC__", "10302");
}

ArrayRef<Builtin::Info> SystemZTargetInfo::getTargetBuiltins() const {
  return llvm::makeArrayRef(BuiltinInfo, clang::SystemZ::LastTSBuiltin -
                                             Builtin::FirstTSBuiltin);
}
