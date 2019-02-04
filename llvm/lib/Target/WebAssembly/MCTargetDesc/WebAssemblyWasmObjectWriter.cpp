//===-- WebAssemblyWasmObjectWriter.cpp - WebAssembly Wasm Writer ---------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
///
/// \file
/// This file handles Wasm-specific object emission, converting LLVM's
/// internal fixups into the appropriate relocations.
///
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/WebAssemblyFixupKinds.h"
#include "MCTargetDesc/WebAssemblyMCTargetDesc.h"
#include "llvm/BinaryFormat/Wasm.h"
#include "llvm/MC/MCAsmBackend.h"
#include "llvm/MC/MCFixup.h"
#include "llvm/MC/MCFixupKindInfo.h"
#include "llvm/MC/MCObjectWriter.h"
#include "llvm/MC/MCSectionWasm.h"
#include "llvm/MC/MCSymbolWasm.h"
#include "llvm/MC/MCValue.h"
#include "llvm/MC/MCWasmObjectWriter.h"
#include "llvm/Support/Casting.h"
#include "llvm/Support/ErrorHandling.h"

using namespace llvm;

namespace {
class WebAssemblyWasmObjectWriter final : public MCWasmObjectTargetWriter {
public:
  explicit WebAssemblyWasmObjectWriter(bool Is64Bit);

private:
  unsigned getRelocType(const MCValue &Target,
                        const MCFixup &Fixup) const override;
};
} // end anonymous namespace

WebAssemblyWasmObjectWriter::WebAssemblyWasmObjectWriter(bool Is64Bit)
    : MCWasmObjectTargetWriter(Is64Bit) {}

// Test whether the given expression computes a function address.
static bool IsFunctionExpr(const MCExpr *Expr) {
  if (auto SyExp = dyn_cast<MCSymbolRefExpr>(Expr))
    return cast<MCSymbolWasm>(SyExp->getSymbol()).isFunction();

  if (auto BinOp = dyn_cast<MCBinaryExpr>(Expr))
    return IsFunctionExpr(BinOp->getLHS()) != IsFunctionExpr(BinOp->getRHS());

  if (auto UnOp = dyn_cast<MCUnaryExpr>(Expr))
    return IsFunctionExpr(UnOp->getSubExpr());

  return false;
}

static bool IsFunctionType(const MCValue &Target) {
  const MCSymbolRefExpr *RefA = Target.getSymA();
  return RefA && RefA->getKind() == MCSymbolRefExpr::VK_WebAssembly_TYPEINDEX;
}

static const MCSection *GetFixupSection(const MCExpr *Expr) {
  if (auto SyExp = dyn_cast<MCSymbolRefExpr>(Expr)) {
    if (SyExp->getSymbol().isInSection())
      return &SyExp->getSymbol().getSection();
    return nullptr;
  }

  if (auto BinOp = dyn_cast<MCBinaryExpr>(Expr)) {
    auto SectionLHS = GetFixupSection(BinOp->getLHS());
    auto SectionRHS = GetFixupSection(BinOp->getRHS());
    return SectionLHS == SectionRHS ? nullptr : SectionLHS;
  }

  if (auto UnOp = dyn_cast<MCUnaryExpr>(Expr))
    return GetFixupSection(UnOp->getSubExpr());

  return nullptr;
}

static bool IsGlobalType(const MCValue &Target) {
  const MCSymbolRefExpr *RefA = Target.getSymA();
  return RefA && RefA->getKind() == MCSymbolRefExpr::VK_WebAssembly_GLOBAL;
}

static bool IsEventType(const MCValue &Target) {
  const MCSymbolRefExpr *RefA = Target.getSymA();
  return RefA && RefA->getKind() == MCSymbolRefExpr::VK_WebAssembly_EVENT;
}

unsigned WebAssemblyWasmObjectWriter::getRelocType(const MCValue &Target,
                                                   const MCFixup &Fixup) const {
  // WebAssembly functions are not allocated in the data address space. To
  // resolve a pointer to a function, we must use a special relocation type.
  bool IsFunction = IsFunctionExpr(Fixup.getValue());

  switch (unsigned(Fixup.getKind())) {
  case WebAssembly::fixup_code_sleb128_i32:
    if (IsFunction)
      return wasm::R_WASM_TABLE_INDEX_SLEB;
    return wasm::R_WASM_MEMORY_ADDR_SLEB;
  case WebAssembly::fixup_code_sleb128_i64:
    llvm_unreachable("fixup_sleb128_i64 not implemented yet");
  case WebAssembly::fixup_code_uleb128_i32:
    if (IsGlobalType(Target))
      return wasm::R_WASM_GLOBAL_INDEX_LEB;
    if (IsFunctionType(Target))
      return wasm::R_WASM_TYPE_INDEX_LEB;
    if (IsFunction)
      return wasm::R_WASM_FUNCTION_INDEX_LEB;
    if (IsEventType(Target))
      return wasm::R_WASM_EVENT_INDEX_LEB;
    return wasm::R_WASM_MEMORY_ADDR_LEB;
  case FK_Data_4:
    if (IsFunction)
      return wasm::R_WASM_TABLE_INDEX_I32;
    if (auto Section = static_cast<const MCSectionWasm *>(
            GetFixupSection(Fixup.getValue()))) {
      if (Section->getKind().isText())
        return wasm::R_WASM_FUNCTION_OFFSET_I32;
      else if (!Section->isWasmData())
        return wasm::R_WASM_SECTION_OFFSET_I32;
    }
    return wasm::R_WASM_MEMORY_ADDR_I32;
  case FK_Data_8:
    llvm_unreachable("FK_Data_8 not implemented yet");
  default:
    llvm_unreachable("unimplemented fixup kind");
  }
}

std::unique_ptr<MCObjectTargetWriter>
llvm::createWebAssemblyWasmObjectWriter(bool Is64Bit) {
  return llvm::make_unique<WebAssemblyWasmObjectWriter>(Is64Bit);
}
