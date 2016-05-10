//===-- YamlXrefsDB.h -------------------------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CLANG_TOOLS_EXTRA_INCLUDE_FIXER_YAMLXREFSDB_H
#define LLVM_CLANG_TOOLS_EXTRA_INCLUDE_FIXER_YAMLXREFSDB_H

#include "XrefsDB.h"
#include "find-all-symbols/SymbolInfo.h"
#include "llvm/Support/ErrorOr.h"
#include <map>
#include <vector>

namespace clang {
namespace include_fixer {

/// Yaml format database.
class YamlXrefsDB : public XrefsDB {
public:
  /// Create a new Yaml db from a file.
  static llvm::ErrorOr<std::unique_ptr<YamlXrefsDB>>
  createFromFile(llvm::StringRef FilePath);
  /// Look for a file called \c Name in \c Directory and all parent directories.
  static llvm::ErrorOr<std::unique_ptr<YamlXrefsDB>>
  createFromDirectory(llvm::StringRef Directory, llvm::StringRef Name);

  std::vector<clang::find_all_symbols::SymbolInfo>
  search(llvm::StringRef Identifier) override;

private:
  explicit YamlXrefsDB(std::vector<clang::find_all_symbols::SymbolInfo> Symbols)
      : Symbols(std::move(Symbols)) {}

  std::vector<clang::find_all_symbols::SymbolInfo> Symbols;
};

} // namespace include_fixer
} // namespace clang

#endif // LLVM_CLANG_TOOLS_EXTRA_INCLUDE_FIXER_YAMLXREFSDB_H
