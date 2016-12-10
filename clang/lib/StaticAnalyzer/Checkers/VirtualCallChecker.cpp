//=======- VirtualCallChecker.cpp --------------------------------*- C++ -*-==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
//  This file defines a checker that checks virtual function calls during
//  construction or destruction of C++ objects.
//
//===----------------------------------------------------------------------===//

#include "ClangSACheckers.h"
#include "clang/AST/DeclCXX.h"
#include "clang/AST/StmtVisitor.h"
#include "clang/StaticAnalyzer/Core/BugReporter/BugReporter.h"
#include "clang/StaticAnalyzer/Core/Checker.h"
#include "clang/StaticAnalyzer/Core/PathSensitive/AnalysisManager.h"
#include "llvm/ADT/SmallString.h"
#include "llvm/Support/SaveAndRestore.h"
#include "llvm/Support/raw_ostream.h"

using namespace clang;
using namespace ento;

namespace {

class WalkAST : public StmtVisitor<WalkAST> {
  const CheckerBase *Checker;
  BugReporter &BR;
  AnalysisDeclContext *AC;

  /// The root constructor or destructor whose callees are being analyzed.
  const CXXMethodDecl *RootMethod = nullptr;

  /// Whether the checker should walk into bodies of called functions.
  /// Controlled by the "Interprocedural" analyzer-config option.
  bool IsInterprocedural = false;

  /// Whether the checker should only warn for calls to pure virtual functions
  /// (which is undefined behavior) or for all virtual functions (which may
  /// may result in unexpected behavior).
  bool ReportPureOnly = false;

  typedef const CallExpr * WorkListUnit;
  typedef SmallVector<WorkListUnit, 20> DFSWorkList;

  /// A vector representing the worklist which has a chain of CallExprs.
  DFSWorkList WList;

  // PreVisited : A CallExpr to this FunctionDecl is in the worklist, but the
  // body has not been visited yet.
  // PostVisited : A CallExpr to this FunctionDecl is in the worklist, and the
  // body has been visited.
  enum Kind { NotVisited,
              PreVisited,  /**< A CallExpr to this FunctionDecl is in the
                                worklist, but the body has not yet been
                                visited. */
              PostVisited  /**< A CallExpr to this FunctionDecl is in the
                                worklist, and the body has been visited. */
  };

  /// A DenseMap that records visited states of FunctionDecls.
  llvm::DenseMap<const FunctionDecl *, Kind> VisitedFunctions;

  /// The CallExpr whose body is currently being visited.  This is used for
  /// generating bug reports.  This is null while visiting the body of a
  /// constructor or destructor.
  const CallExpr *visitingCallExpr;

public:
  WalkAST(const CheckerBase *checker, BugReporter &br, AnalysisDeclContext *ac,
          const CXXMethodDecl *rootMethod, bool isInterprocedural,
          bool reportPureOnly)
      : Checker(checker), BR(br), AC(ac), RootMethod(rootMethod),
        IsInterprocedural(isInterprocedural), ReportPureOnly(reportPureOnly),
        visitingCallExpr(nullptr) {
    // Walking should always start from either a constructor or a destructor.
    assert(isa<CXXConstructorDecl>(rootMethod) ||
           isa<CXXDestructorDecl>(rootMethod));
  }

  bool hasWork() const { return !WList.empty(); }

  /// This method adds a CallExpr to the worklist and marks the callee as
  /// being PreVisited.
  void Enqueue(WorkListUnit WLUnit) {
    const FunctionDecl *FD = WLUnit->getDirectCallee();
    if (!FD || !FD->getBody())
      return;
    Kind &K = VisitedFunctions[FD];
    if (K != NotVisited)
      return;
    K = PreVisited;
    WList.push_back(WLUnit);
  }

  /// This method returns an item from the worklist without removing it.
  WorkListUnit Dequeue() {
    assert(!WList.empty());
    return WList.back();
  }

  void Execute() {
    while (hasWork()) {
      WorkListUnit WLUnit = Dequeue();
      const FunctionDecl *FD = WLUnit->getDirectCallee();
      assert(FD && FD->getBody());

      if (VisitedFunctions[FD] == PreVisited) {
        // If the callee is PreVisited, walk its body.
        // Visit the body.
        SaveAndRestore<const CallExpr *> SaveCall(visitingCallExpr, WLUnit);
        Visit(FD->getBody());

        // Mark the function as being PostVisited to indicate we have
        // scanned the body.
        VisitedFunctions[FD] = PostVisited;
        continue;
      }

      // Otherwise, the callee is PostVisited.
      // Remove it from the worklist.
      assert(VisitedFunctions[FD] == PostVisited);
      WList.pop_back();
    }
  }

  // Stmt visitor methods.
  void VisitCallExpr(CallExpr *CE);
  void VisitCXXMemberCallExpr(CallExpr *CE);
  void VisitStmt(Stmt *S) { VisitChildren(S); }
  void VisitChildren(Stmt *S);

  void ReportVirtualCall(const CallExpr *CE, bool isPure);

};
} // end anonymous namespace

//===----------------------------------------------------------------------===//
// AST walking.
//===----------------------------------------------------------------------===//

void WalkAST::VisitChildren(Stmt *S) {
  for (Stmt *Child : S->children())
    if (Child)
      Visit(Child);
}

void WalkAST::VisitCallExpr(CallExpr *CE) {
  VisitChildren(CE);
  if (IsInterprocedural)
    Enqueue(CE);
}

void WalkAST::VisitCXXMemberCallExpr(CallExpr *CE) {
  VisitChildren(CE);
  bool callIsNonVirtual = false;

  // Several situations to elide for checking.
  if (MemberExpr *CME = dyn_cast<MemberExpr>(CE->getCallee())) {
    // If the member access is fully qualified (i.e., X::F), then treat
    // this as a non-virtual call and do not warn.
    if (CME->getQualifier())
      callIsNonVirtual = true;

    if (Expr *base = CME->getBase()->IgnoreImpCasts()) {
      // Elide analyzing the call entirely if the base pointer is not 'this'.
      if (!isa<CXXThisExpr>(base))
        return;

      // If the most derived class is marked final, we know that now subclass
      // can override this member.
      if (base->getBestDynamicClassType()->hasAttr<FinalAttr>())
        callIsNonVirtual = true;
    }
  }

  // Get the callee.
  const CXXMethodDecl *MD = dyn_cast<CXXMethodDecl>(CE->getDirectCallee());
  if (MD && MD->isVirtual() && !callIsNonVirtual && !MD->hasAttr<FinalAttr>() &&
      !MD->getParent()->hasAttr<FinalAttr>())
    ReportVirtualCall(CE, MD->isPure());

  if (IsInterprocedural)
    Enqueue(CE);
}

void WalkAST::ReportVirtualCall(const CallExpr *CE, bool isPure) {
  if (ReportPureOnly && !isPure)
    return;

  SmallString<100> buf;
  llvm::raw_svector_ostream os(buf);

  // FIXME: The interprocedural diagnostic experience here is not good.
  // Ultimately this checker should be re-written to be path sensitive.
  // For now, only diagnose intraprocedurally, by default.
  if (IsInterprocedural) {
    os << "Call Path : ";
    // Name of current visiting CallExpr.
    os << *CE->getDirectCallee();

    // Name of the CallExpr whose body is current being walked.
    if (visitingCallExpr)
      os << " <-- " << *visitingCallExpr->getDirectCallee();
    // Names of FunctionDecls in worklist with state PostVisited.
    for (SmallVectorImpl<const CallExpr *>::iterator I = WList.end(),
         E = WList.begin(); I != E; --I) {
      const FunctionDecl *FD = (*(I-1))->getDirectCallee();
      assert(FD);
      if (VisitedFunctions[FD] == PostVisited)
        os << " <-- " << *FD;
    }

    os << "\n";
  }

  PathDiagnosticLocation CELoc =
    PathDiagnosticLocation::createBegin(CE, BR.getSourceManager(), AC);
  SourceRange R = CE->getCallee()->getSourceRange();

  os << "Call to ";
  if (isPure)
    os << "pure ";

  os << "virtual function during ";

  if (isa<CXXConstructorDecl>(RootMethod))
    os << "construction ";
  else
    os << "destruction ";

  if (isPure)
    os << "has undefined behavior";
  else
    os << "will not dispatch to derived class";

  BR.EmitBasicReport(AC->getDecl(), Checker,
                     "Call to virtual function during construction or "
                     "destruction",
                     "C++ Object Lifecycle", os.str(), CELoc, R);
}

//===----------------------------------------------------------------------===//
// VirtualCallChecker
//===----------------------------------------------------------------------===//

namespace {
class VirtualCallChecker : public Checker<check::ASTDecl<CXXRecordDecl> > {
public:
  DefaultBool isInterprocedural;
  DefaultBool isPureOnly;

  void checkASTDecl(const CXXRecordDecl *RD, AnalysisManager& mgr,
                    BugReporter &BR) const {
    AnalysisDeclContext *ADC = mgr.getAnalysisDeclContext(RD);

    // Check the constructors.
    for (const auto *I : RD->ctors()) {
      if (!I->isCopyOrMoveConstructor())
        if (Stmt *Body = I->getBody()) {
          WalkAST walker(this, BR, ADC, I, isInterprocedural, isPureOnly);
          walker.Visit(Body);
          walker.Execute();
        }
    }

    // Check the destructor.
    if (CXXDestructorDecl *DD = RD->getDestructor())
      if (Stmt *Body = DD->getBody()) {
        WalkAST walker(this, BR, ADC, DD, isInterprocedural, isPureOnly);
        walker.Visit(Body);
        walker.Execute();
      }
  }
};
}

void ento::registerVirtualCallChecker(CheckerManager &mgr) {
  VirtualCallChecker *checker = mgr.registerChecker<VirtualCallChecker>();
  checker->isInterprocedural =
      mgr.getAnalyzerOptions().getBooleanOption("Interprocedural", false,
                                                checker);

  checker->isPureOnly =
      mgr.getAnalyzerOptions().getBooleanOption("PureOnly", false,
                                                checker);
}
