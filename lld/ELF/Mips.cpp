//===- Mips.cpp ----------------------------------------------------------===//
//
//                             The LLVM Linker
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===---------------------------------------------------------------------===//
//
// This file contains a helper function for the Writer.
//
//===---------------------------------------------------------------------===//

#include "Error.h"
#include "InputFiles.h"
#include "SymbolTable.h"
#include "Writer.h"

#include "llvm/Object/ELF.h"
#include "llvm/Support/ELF.h"

using namespace llvm;
using namespace llvm::object;
using namespace llvm::ELF;

using namespace lld;
using namespace lld::elf;

namespace {
struct ArchTreeEdge {
  uint32_t Child;
  uint32_t Parent;
};

struct FileFlags {
  StringRef Filename;
  uint32_t Flags;
};
}

static StringRef getAbiName(uint32_t Flags) {
  switch (Flags) {
  case 0:
    return "n64";
  case EF_MIPS_ABI2:
    return "n32";
  case EF_MIPS_ABI_O32:
    return "o32";
  case EF_MIPS_ABI_O64:
    return "o64";
  case EF_MIPS_ABI_EABI32:
    return "eabi32";
  case EF_MIPS_ABI_EABI64:
    return "eabi64";
  default:
    return "unknown";
  }
}

static StringRef getNanName(bool IsNan2008) {
  return IsNan2008 ? "2008" : "legacy";
}

static StringRef getFpName(bool IsFp64) { return IsFp64 ? "64" : "32"; }

static void checkFlags(ArrayRef<FileFlags> Files) {
  uint32_t ABI = Files[0].Flags & (EF_MIPS_ABI | EF_MIPS_ABI2);
  bool Nan = Files[0].Flags & EF_MIPS_NAN2008;
  bool Fp = Files[0].Flags & EF_MIPS_FP64;

  for (const FileFlags &F : Files.slice(1)) {
    uint32_t ABI2 = F.Flags & (EF_MIPS_ABI | EF_MIPS_ABI2);
    if (ABI != ABI2)
      error("target ABI '" + getAbiName(ABI) + "' is incompatible with '" +
            getAbiName(ABI2) + "': " + F.Filename);

    bool Nan2 = F.Flags & EF_MIPS_NAN2008;
    if (Nan != Nan2)
      error("target -mnan=" + getNanName(Nan) + " is incompatible with -mnan=" +
            getNanName(Nan2) + ": " + F.Filename);

    bool Fp2 = F.Flags & EF_MIPS_FP64;
    if (Fp != Fp2)
      error("target -mfp" + getFpName(Fp) + " is incompatible with -mfp" +
            getFpName(Fp2) + ": " + F.Filename);
  }
}

static uint32_t getMiscFlags(ArrayRef<FileFlags> Files) {
  uint32_t Ret = 0;
  for (const FileFlags &F : Files)
    Ret |= F.Flags &
           (EF_MIPS_ABI | EF_MIPS_ABI2 | EF_MIPS_ARCH_ASE | EF_MIPS_NOREORDER |
            EF_MIPS_MICROMIPS | EF_MIPS_NAN2008 | EF_MIPS_32BITMODE);
  return Ret;
}

static uint32_t getPicFlags(ArrayRef<FileFlags> Files) {
  // Check PIC/non-PIC compatibility.
  bool IsPic = Files[0].Flags & (EF_MIPS_PIC | EF_MIPS_CPIC);
  for (const FileFlags &F : Files.slice(1)) {
    bool IsPic2 = F.Flags & (EF_MIPS_PIC | EF_MIPS_CPIC);
    if (IsPic && !IsPic2)
      warning("linking abicalls code with non-abicalls file: " + F.Filename);
    if (!IsPic && IsPic2)
      warning("linking non-abicalls code with abicalls file: " + F.Filename);
  }

  // Compute the result PIC/non-PIC flag.
  uint32_t Ret = Files[0].Flags & (EF_MIPS_PIC | EF_MIPS_CPIC);
  for (const FileFlags &F : Files.slice(1))
    Ret &= F.Flags & (EF_MIPS_PIC | EF_MIPS_CPIC);

  // PIC code is inherently CPIC and may not set CPIC flag explicitly.
  if (Ret & EF_MIPS_PIC)
    Ret |= EF_MIPS_CPIC;
  return Ret;
}

static ArchTreeEdge ArchTree[] = {
    // MIPS32R6 and MIPS64R6 are not compatible with other extensions
    // MIPS64 extensions.
    {EF_MIPS_ARCH_64R2, EF_MIPS_ARCH_64},
    // MIPS V extensions.
    {EF_MIPS_ARCH_64, EF_MIPS_ARCH_5},
    // MIPS IV extensions.
    {EF_MIPS_ARCH_5, EF_MIPS_ARCH_4},
    // MIPS III extensions.
    {EF_MIPS_ARCH_4, EF_MIPS_ARCH_3},
    // MIPS32 extensions.
    {EF_MIPS_ARCH_32R2, EF_MIPS_ARCH_32},
    // MIPS II extensions.
    {EF_MIPS_ARCH_3, EF_MIPS_ARCH_2},
    {EF_MIPS_ARCH_32, EF_MIPS_ARCH_2},
    // MIPS I extensions.
    {EF_MIPS_ARCH_2, EF_MIPS_ARCH_1},
};

static bool isArchMatched(uint32_t New, uint32_t Res) {
  if (New == Res)
    return true;
  if (New == EF_MIPS_ARCH_32 && isArchMatched(EF_MIPS_ARCH_64, Res))
    return true;
  if (New == EF_MIPS_ARCH_32R2 && isArchMatched(EF_MIPS_ARCH_64R2, Res))
    return true;
  for (const auto &Edge : ArchTree) {
    if (Res == Edge.Child) {
      Res = Edge.Parent;
      if (Res == New)
        return true;
    }
  }
  return false;
}

static StringRef getArchName(uint32_t Flags) {
  switch (Flags) {
  case EF_MIPS_ARCH_1:
    return "mips1";
  case EF_MIPS_ARCH_2:
    return "mips2";
  case EF_MIPS_ARCH_3:
    return "mips3";
  case EF_MIPS_ARCH_4:
    return "mips4";
  case EF_MIPS_ARCH_5:
    return "mips5";
  case EF_MIPS_ARCH_32:
    return "mips32";
  case EF_MIPS_ARCH_64:
    return "mips64";
  case EF_MIPS_ARCH_32R2:
    return "mips32r2";
  case EF_MIPS_ARCH_64R2:
    return "mips64r2";
  case EF_MIPS_ARCH_32R6:
    return "mips32r6";
  case EF_MIPS_ARCH_64R6:
    return "mips64r6";
  default:
    return "unknown";
  }
}

static uint32_t getArchFlags(ArrayRef<FileFlags> Files) {
  uint32_t Ret = Files[0].Flags & EF_MIPS_ARCH;

  for (const FileFlags &F : Files.slice(1)) {
    uint32_t New = F.Flags & EF_MIPS_ARCH;

    // Check ISA compatibility.
    if (isArchMatched(New, Ret))
      continue;
    if (!isArchMatched(Ret, New)) {
      error("target ISA '" + getArchName(Ret) + "' is incompatible with '" +
            getArchName(New) + "': " + F.Filename);
      return 0;
    }
    Ret = New;
  }
  return Ret;
}

template <class ELFT> uint32_t elf::getMipsEFlags() {
  std::vector<FileFlags> V;
  for (const std::unique_ptr<elf::ObjectFile<ELFT>> &F :
       Symtab<ELFT>::X->getObjectFiles())
    V.push_back({F->getName(), F->getObj().getHeader()->e_flags});

  checkFlags(V);
  return getMiscFlags(V) | getPicFlags(V) | getArchFlags(V);
}

template uint32_t elf::getMipsEFlags<ELF32LE>();
template uint32_t elf::getMipsEFlags<ELF32BE>();
template uint32_t elf::getMipsEFlags<ELF64LE>();
template uint32_t elf::getMipsEFlags<ELF64BE>();
