//===--- MisplacedConstCheck.h - clang-tidy----------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CLANG_TOOLS_EXTRA_CLANG_TIDY_MISC_MISPLACED_CONST_H
#define LLVM_CLANG_TOOLS_EXTRA_CLANG_TIDY_MISC_MISPLACED_CONST_H

#include "../ClangTidy.h"

namespace clang {
namespace tidy {
namespace misc {

/// This check diagnoses when a const qualifier is applied to a typedef to a
/// pointer type rather than to the pointee.
///
/// For the user-facing documentation see:
/// http://clang.llvm.org/extra/clang-tidy/checks/misc-misplaced-const.html
class MisplacedConstCheck : public ClangTidyCheck {
public:
  MisplacedConstCheck(StringRef Name, ClangTidyContext *Context)
      : ClangTidyCheck(Name, Context) {}
  void registerMatchers(ast_matchers::MatchFinder *Finder) override;
  void check(const ast_matchers::MatchFinder::MatchResult &Result) override;
};

} // namespace misc
} // namespace tidy
} // namespace clang

#endif // LLVM_CLANG_TOOLS_EXTRA_CLANG_TIDY_MISC_MISPLACED_CONST_H
