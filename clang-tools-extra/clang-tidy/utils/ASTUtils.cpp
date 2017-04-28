//===---------- ASTUtils.cpp - clang-tidy ---------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "ASTUtils.h"

#include "clang/ASTMatchers/ASTMatchFinder.h"
#include "clang/ASTMatchers/ASTMatchers.h"

namespace clang {
namespace tidy {
namespace utils {
using namespace ast_matchers;

const FunctionDecl *getSurroundingFunction(ASTContext &Context,
                                           const Stmt &Statement) {
  return selectFirst<const FunctionDecl>(
      "function", match(stmt(hasAncestor(functionDecl().bind("function"))),
                        Statement, Context));
}

bool IsBinaryOrTernary(const Expr *E) {
  const Expr *E_base = E->IgnoreImpCasts();
  if (clang::isa<clang::BinaryOperator>(E_base) ||
      clang::isa<clang::ConditionalOperator>(E_base)) {
    return true;
  }

  if (const auto *Operator =
          clang::dyn_cast<clang::CXXOperatorCallExpr>(E_base)) {
    return Operator->isInfixBinaryOp();
  }

  return false;
}

} // namespace utils
} // namespace tidy
} // namespace clang
