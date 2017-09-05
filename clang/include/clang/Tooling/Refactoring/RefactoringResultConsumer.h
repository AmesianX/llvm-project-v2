//===--- RefactoringResultConsumer.h - Clang refactoring library ----------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CLANG_TOOLING_REFACTOR_REFACTORING_RESULT_CONSUMER_H
#define LLVM_CLANG_TOOLING_REFACTOR_REFACTORING_RESULT_CONSUMER_H

#include "clang/Basic/LLVM.h"
#include "clang/Tooling/Refactoring/AtomicChange.h"
#include "llvm/Support/Error.h"

namespace clang {
namespace tooling {

/// An abstract interface that consumes the various refactoring results that can
/// be produced by refactoring actions.
///
/// A valid refactoring result must be handled by a \c handle method.
class RefactoringResultConsumer {
public:
  virtual ~RefactoringResultConsumer() {}

  /// Handles an initation or an invication error. An initiation error typically
  /// has a \c DiagnosticError payload that describes why initation failed.
  virtual void handleError(llvm::Error Err) = 0;

  /// Handles the source replacements that are produced by a refactoring action.
  virtual void handle(AtomicChanges SourceReplacements) {
    defaultResultHandler();
  }

private:
  void defaultResultHandler() {
    handleError(llvm::make_error<llvm::StringError>(
        "unsupported refactoring result", llvm::inconvertibleErrorCode()));
  }
};

namespace traits {
namespace internal {

template <typename T> struct HasHandle {
private:
  template <typename ClassT>
  static auto check(ClassT *) -> typename std::is_same<
      decltype(std::declval<ClassT>().handle(std::declval<T>())), void>::type;

  template <typename> static std::false_type check(...);

public:
  using Type = decltype(check<RefactoringResultConsumer>(nullptr));
};

} // end namespace internal

/// A type trait that returns true iff the given type is a valid refactoring
/// result.
template <typename T>
struct IsValidRefactoringResult : internal::HasHandle<T>::Type {};

} // end namespace traits
} // end namespace tooling
} // end namespace clang

#endif // LLVM_CLANG_TOOLING_REFACTOR_REFACTORING_RESULT_CONSUMER_H
