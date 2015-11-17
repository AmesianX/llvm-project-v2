//===--- ThrownExceptionTypeCheck.h - clang-tidy-----------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CLANG_TOOLS_EXTRA_CLANG_TIDY_CERT_THROWNEXCEPTIONTYPECHECK_H
#define LLVM_CLANG_TOOLS_EXTRA_CLANG_TIDY_CERT_THROWNEXCEPTIONTYPECHECK_H

#include "../ClangTidy.h"

namespace clang {
namespace tidy {

/// Checks whether a thrown object is nothrow copy constructible.
///
/// For the user-facing documentation see:
/// http://clang.llvm.org/extra/clang-tidy/checks/cert-thrown-exception-type.html
class ThrownExceptionTypeCheck : public ClangTidyCheck {
public:
  ThrownExceptionTypeCheck(StringRef Name, ClangTidyContext *Context)
    : ClangTidyCheck(Name, Context) {}
  void registerMatchers(ast_matchers::MatchFinder *Finder) override;
  void check(const ast_matchers::MatchFinder::MatchResult &Result) override;
};

} // namespace tidy
} // namespace clang

#endif // LLVM_CLANG_TOOLS_EXTRA_CLANG_TIDY_CERT_THROWNEXCEPTIONTYPECHECK_H

