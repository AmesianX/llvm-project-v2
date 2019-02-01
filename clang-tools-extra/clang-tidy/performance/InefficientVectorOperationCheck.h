//===--- InefficientVectorOperationCheck.h - clang-tidy----------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CLANG_TOOLS_EXTRA_CLANG_TIDY_PERFORMANCE_INEFFICIENT_VECTOR_OPERATION_H
#define LLVM_CLANG_TOOLS_EXTRA_CLANG_TIDY_PERFORMANCE_INEFFICIENT_VECTOR_OPERATION_H

#include "../ClangTidy.h"

namespace clang {
namespace tidy {
namespace performance {

/// Finds possible inefficient `std::vector` operations (e.g. `push_back`) in
/// for loops that may cause unnecessary memory reallocations.
///
/// For the user-facing documentation see:
/// http://clang.llvm.org/extra/clang-tidy/checks/performance-inefficient-vector-operation.html
class InefficientVectorOperationCheck : public ClangTidyCheck {
public:
  InefficientVectorOperationCheck(StringRef Name, ClangTidyContext *Context);
  void registerMatchers(ast_matchers::MatchFinder *Finder) override;
  void check(const ast_matchers::MatchFinder::MatchResult &Result) override;
  void storeOptions(ClangTidyOptions::OptionMap &Opts) override;

private:
  const std::vector<std::string> VectorLikeClasses;
};

} // namespace performance
} // namespace tidy
} // namespace clang

#endif // LLVM_CLANG_TOOLS_EXTRA_CLANG_TIDY_PERFORMANCE_INEFFICIENT_VECTOR_OPERATION_H
