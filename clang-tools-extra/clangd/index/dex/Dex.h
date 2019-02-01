//===--- Dex.h - Dex Symbol Index Implementation ----------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
///
/// \file
/// This defines Dex - a symbol index implementation based on query iterators
/// over symbol tokens, such as fuzzy matching trigrams, scopes, types, etc.
/// While consuming more memory and having longer build stage due to
/// preprocessing, Dex will have substantially lower latency. It will also allow
/// efficient symbol searching which is crucial for operations like code
/// completion, and can be very important for a number of different code
/// transformations which will be eventually supported by Clangd.
///
//===----------------------------------------------------------------------===//

#ifndef LLVM_CLANG_TOOLS_EXTRA_CLANGD_INDEX_DEX_DEX_H
#define LLVM_CLANG_TOOLS_EXTRA_CLANGD_INDEX_DEX_DEX_H

#include "Iterator.h"
#include "PostingList.h"
#include "Token.h"
#include "Trigram.h"
#include "index/Index.h"
#include "index/MemIndex.h"
#include "index/SymbolCollector.h"

namespace clang {
namespace clangd {
namespace dex {

/// In-memory Dex trigram-based index implementation.
// FIXME(kbobyrev): Introduce serialization and deserialization of the symbol
// index so that it can be loaded from the disk. Since static index is not
// changed frequently, it's safe to assume that it has to be built only once
// (when the clangd process starts). Therefore, it can be easier to store built
// index on disk and then load it if available.
class Dex : public SymbolIndex {
public:
  // All data must outlive this index.
  template <typename SymbolRange, typename RefsRange>
  Dex(SymbolRange &&Symbols, RefsRange &&Refs) : Corpus(0) {
    for (auto &&Sym : Symbols)
      this->Symbols.push_back(&Sym);
    for (auto &&Ref : Refs)
      this->Refs.try_emplace(Ref.first, Ref.second);
    buildIndex();
  }
  // Symbols and Refs are owned by BackingData, Index takes ownership.
  template <typename SymbolRange, typename RefsRange, typename Payload>
  Dex(SymbolRange &&Symbols, RefsRange &&Refs, Payload &&BackingData,
      size_t BackingDataSize)
      : Dex(std::forward<SymbolRange>(Symbols), std::forward<RefsRange>(Refs)) {
    KeepAlive = std::shared_ptr<void>(
        std::make_shared<Payload>(std::move(BackingData)), nullptr);
    this->BackingDataSize = BackingDataSize;
  }

  /// Builds an index from slabs. The index takes ownership of the slab.
  static std::unique_ptr<SymbolIndex> build(SymbolSlab, RefSlab);

  bool
  fuzzyFind(const FuzzyFindRequest &Req,
            llvm::function_ref<void(const Symbol &)> Callback) const override;

  void lookup(const LookupRequest &Req,
              llvm::function_ref<void(const Symbol &)> Callback) const override;

  void refs(const RefsRequest &Req,
            llvm::function_ref<void(const Ref &)> Callback) const override;

  size_t estimateMemoryUsage() const override;

private:
  void buildIndex();
  std::unique_ptr<Iterator> iterator(const Token &Tok) const;

  /// Stores symbols sorted in the descending order of symbol quality..
  std::vector<const Symbol *> Symbols;
  /// SymbolQuality[I] is the quality of Symbols[I].
  std::vector<float> SymbolQuality;
  llvm::DenseMap<SymbolID, const Symbol *> LookupTable;
  /// Inverted index is a mapping from the search token to the posting list,
  /// which contains all items which can be characterized by such search token.
  /// For example, if the search token is scope "std::", the corresponding
  /// posting list would contain all indices of symbols defined in namespace
  /// std. Inverted index is used to retrieve posting lists which are processed
  /// during the fuzzyFind process.
  llvm::DenseMap<Token, PostingList> InvertedIndex;
  dex::Corpus Corpus;
  llvm::DenseMap<SymbolID, llvm::ArrayRef<Ref>> Refs;
  std::shared_ptr<void> KeepAlive; // poor man's move-only std::any
  // Size of memory retained by KeepAlive.
  size_t BackingDataSize = 0;
};

/// Returns Search Token for a number of parent directories of given Path.
/// Should be used within the index build process.
///
/// This function is exposed for testing only.
std::vector<std::string> generateProximityURIs(llvm::StringRef URIPath);

} // namespace dex
} // namespace clangd
} // namespace clang

#endif // LLVM_CLANG_TOOLS_EXTRA_CLANGD_INDEX_DEX_DEX_H
