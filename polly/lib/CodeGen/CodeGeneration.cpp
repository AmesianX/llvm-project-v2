//===------ CodeGeneration.cpp - Code generate the Scops using ISL. ----======//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// The CodeGeneration pass takes a Scop created by ScopInfo and translates it
// back to LLVM-IR using the ISL code generator.
//
// The Scop describes the high level memory behavior of a control flow region.
// Transformation passes can update the schedule (execution order) of statements
// in the Scop. ISL is used to generate an abstract syntax tree that reflects
// the updated execution order. This clast is used to create new LLVM-IR that is
// computationally equivalent to the original control flow region, but executes
// its code in the new execution order defined by the changed schedule.
//
//===----------------------------------------------------------------------===//

#include "polly/CodeGen/CodeGeneration.h"
#include "polly/CodeGen/IslAst.h"
#include "polly/CodeGen/IslNodeBuilder.h"
#include "polly/CodeGen/PerfMonitor.h"
#include "polly/CodeGen/Utils.h"
#include "polly/DependenceInfo.h"
#include "polly/LinkAllPasses.h"
#include "polly/Options.h"
#include "polly/ScopInfo.h"
#include "polly/Support/ScopHelper.h"
#include "llvm/Analysis/AliasAnalysis.h"
#include "llvm/Analysis/BasicAliasAnalysis.h"
#include "llvm/Analysis/GlobalsModRef.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/ScalarEvolutionAliasAnalysis.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/PassManager.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/Debug.h"

using namespace polly;
using namespace llvm;

#define DEBUG_TYPE "polly-codegen"

static cl::opt<bool> Verify("polly-codegen-verify",
                            cl::desc("Verify the function generated by Polly"),
                            cl::Hidden, cl::init(false), cl::ZeroOrMore,
                            cl::cat(PollyCategory));

static cl::opt<bool>
    PerfMonitoring("polly-codegen-perf-monitoring",
                   cl::desc("Add run-time performance monitoring"), cl::Hidden,
                   cl::init(false), cl::ZeroOrMore, cl::cat(PollyCategory));

namespace {

static void verifyGeneratedFunction(Scop &S, Function &F, IslAstInfo &AI) {
  if (!Verify || !verifyFunction(F, &errs()))
    return;

  DEBUG({
    errs() << "== ISL Codegen created an invalid function ==\n\n== The "
              "SCoP ==\n";
    S.print(errs());
    errs() << "\n== The isl AST ==\n";
    AI.print(errs());
    errs() << "\n== The invalid function ==\n";
    F.print(errs());
  });

  llvm_unreachable("Polly generated function could not be verified. Add "
                   "-polly-codegen-verify=false to disable this assertion.");
}

// CodeGeneration adds a lot of BBs without updating the RegionInfo
// We make all created BBs belong to the scop's parent region without any
// nested structure to keep the RegionInfo verifier happy.
static void fixRegionInfo(Function &F, Region &ParentRegion, RegionInfo &RI) {
  for (BasicBlock &BB : F) {
    if (RI.getRegionFor(&BB))
      continue;

    RI.setRegionFor(&BB, &ParentRegion);
  }
}

/// Mark a basic block unreachable.
///
/// Marks the basic block @p Block unreachable by equipping it with an
/// UnreachableInst.
static void markBlockUnreachable(BasicBlock &Block, PollyIRBuilder &Builder) {
  auto *OrigTerminator = Block.getTerminator();
  Builder.SetInsertPoint(OrigTerminator);
  Builder.CreateUnreachable();
  OrigTerminator->eraseFromParent();
}

/// Remove all lifetime markers (llvm.lifetime.start, llvm.lifetime.end) from
/// @R.
///
/// CodeGeneration does not copy lifetime markers into the optimized SCoP,
/// which would leave the them only in the original path. This can transform
/// code such as
///
///     llvm.lifetime.start(%p)
///     llvm.lifetime.end(%p)
///
/// into
///
///     if (RTC) {
///       // generated code
///     } else {
///       // original code
///       llvm.lifetime.start(%p)
///     }
///     llvm.lifetime.end(%p)
///
/// The current StackColoring algorithm cannot handle if some, but not all,
/// paths from the end marker to the entry block cross the start marker. Same
/// for start markers that do not always cross the end markers. We avoid any
/// issues by removing all lifetime markers, even from the original code.
///
/// A better solution could be to hoist all llvm.lifetime.start to the split
/// node and all llvm.lifetime.end to the merge node, which should be
/// conservatively correct.
static void removeLifetimeMarkers(Region *R) {
  for (auto *BB : R->blocks()) {
    auto InstIt = BB->begin();
    auto InstEnd = BB->end();

    while (InstIt != InstEnd) {
      auto NextIt = InstIt;
      ++NextIt;

      if (auto *IT = dyn_cast<IntrinsicInst>(&*InstIt)) {
        switch (IT->getIntrinsicID()) {
        case llvm::Intrinsic::lifetime_start:
        case llvm::Intrinsic::lifetime_end:
          BB->getInstList().erase(InstIt);
          break;
        default:
          break;
        }
      }

      InstIt = NextIt;
    }
  }
}

static bool CodeGen(Scop &S, IslAstInfo &AI, LoopInfo &LI, DominatorTree &DT,
                    ScalarEvolution &SE, RegionInfo &RI) {
  // Check if we created an isl_ast root node, otherwise exit.
  isl_ast_node *AstRoot = AI.getAst();
  if (!AstRoot)
    return false;

  auto &DL = S.getFunction().getParent()->getDataLayout();
  Region *R = &S.getRegion();
  assert(!R->isTopLevelRegion() && "Top level regions are not supported");

  ScopAnnotator Annotator;

  simplifyRegion(R, &DT, &LI, &RI);
  assert(R->isSimple());
  BasicBlock *EnteringBB = S.getEnteringBlock();
  assert(EnteringBB);
  PollyIRBuilder Builder = createPollyIRBuilder(EnteringBB, Annotator);

  // Only build the run-time condition and parameters _after_ having
  // introduced the conditional branch. This is important as the conditional
  // branch will guard the original scop from new induction variables that
  // the SCEVExpander may introduce while code generating the parameters and
  // which may introduce scalar dependences that prevent us from correctly
  // code generating this scop.
  BBPair StartExitBlocks =
      executeScopConditionally(S, Builder.getTrue(), DT, RI, LI);
  BasicBlock *StartBlock = std::get<0>(StartExitBlocks);
  BasicBlock *ExitBlock = std::get<1>(StartExitBlocks);

  removeLifetimeMarkers(R);
  auto *SplitBlock = StartBlock->getSinglePredecessor();

  IslNodeBuilder NodeBuilder(Builder, Annotator, DL, LI, SE, DT, S, StartBlock);

  // All arrays must have their base pointers known before
  // ScopAnnotator::buildAliasScopes.
  NodeBuilder.allocateNewArrays();
  Annotator.buildAliasScopes(S);

  if (PerfMonitoring) {
    PerfMonitor P(S, EnteringBB->getParent()->getParent());
    P.initialize();
    P.insertRegionStart(SplitBlock->getTerminator());

    BasicBlock *MergeBlock = ExitBlock->getUniqueSuccessor();
    P.insertRegionEnd(MergeBlock->getTerminator());
  }

  // First generate code for the hoisted invariant loads and transitively the
  // parameters they reference. Afterwards, for the remaining parameters that
  // might reference the hoisted loads. Finally, build the runtime check
  // that might reference both hoisted loads as well as parameters.
  // If the hoisting fails we have to bail and execute the original code.
  Builder.SetInsertPoint(SplitBlock->getTerminator());
  if (!NodeBuilder.preloadInvariantLoads()) {

    // Patch the introduced branch condition to ensure that we always execute
    // the original SCoP.
    auto *FalseI1 = Builder.getFalse();
    auto *SplitBBTerm = Builder.GetInsertBlock()->getTerminator();
    SplitBBTerm->setOperand(0, FalseI1);

    // Since the other branch is hence ignored we mark it as unreachable and
    // adjust the dominator tree accordingly.
    auto *ExitingBlock = StartBlock->getUniqueSuccessor();
    assert(ExitingBlock);
    auto *MergeBlock = ExitingBlock->getUniqueSuccessor();
    assert(MergeBlock);
    markBlockUnreachable(*StartBlock, Builder);
    markBlockUnreachable(*ExitingBlock, Builder);
    auto *ExitingBB = S.getExitingBlock();
    assert(ExitingBB);
    DT.changeImmediateDominator(MergeBlock, ExitingBB);
    DT.eraseNode(ExitingBlock);

    isl_ast_node_free(AstRoot);
  } else {
    NodeBuilder.addParameters(S.getContext());
    Value *RTC = NodeBuilder.createRTC(AI.getRunCondition());

    Builder.GetInsertBlock()->getTerminator()->setOperand(0, RTC);
    Builder.SetInsertPoint(&StartBlock->front());

    NodeBuilder.create(AstRoot);
    NodeBuilder.finalize();
    fixRegionInfo(*EnteringBB->getParent(), *R->getParent(), RI);
  }

  Function *F = EnteringBB->getParent();
  verifyGeneratedFunction(S, *F, AI);
  for (auto *SubF : NodeBuilder.getParallelSubfunctions())
    verifyGeneratedFunction(S, *SubF, AI);

  // Mark the function such that we run additional cleanup passes on this
  // function (e.g. mem2reg to rediscover phi nodes).
  F->addFnAttr("polly-optimized");
  return true;
}

class CodeGeneration : public ScopPass {
public:
  static char ID;

  CodeGeneration() : ScopPass(ID) {}

  /// The data layout used.
  const DataLayout *DL;

  /// @name The analysis passes we need to generate code.
  ///
  ///{
  LoopInfo *LI;
  IslAstInfo *AI;
  DominatorTree *DT;
  ScalarEvolution *SE;
  RegionInfo *RI;
  ///}

  /// Generate LLVM-IR for the SCoP @p S.
  bool runOnScop(Scop &S) override {
    AI = &getAnalysis<IslAstInfoWrapperPass>().getAI();
    LI = &getAnalysis<LoopInfoWrapperPass>().getLoopInfo();
    DT = &getAnalysis<DominatorTreeWrapperPass>().getDomTree();
    SE = &getAnalysis<ScalarEvolutionWrapperPass>().getSE();
    DL = &S.getFunction().getParent()->getDataLayout();
    RI = &getAnalysis<RegionInfoPass>().getRegionInfo();
    return CodeGen(S, *AI, *LI, *DT, *SE, *RI);
  }

  /// Register all analyses and transformation required.
  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.addRequired<DominatorTreeWrapperPass>();
    AU.addRequired<IslAstInfoWrapperPass>();
    AU.addRequired<RegionInfoPass>();
    AU.addRequired<ScalarEvolutionWrapperPass>();
    AU.addRequired<ScopDetectionWrapperPass>();
    AU.addRequired<ScopInfoRegionPass>();
    AU.addRequired<LoopInfoWrapperPass>();

    AU.addPreserved<DependenceInfo>();

    AU.addPreserved<AAResultsWrapperPass>();
    AU.addPreserved<BasicAAWrapperPass>();
    AU.addPreserved<LoopInfoWrapperPass>();
    AU.addPreserved<DominatorTreeWrapperPass>();
    AU.addPreserved<GlobalsAAWrapperPass>();
    AU.addPreserved<IslAstInfoWrapperPass>();
    AU.addPreserved<ScopDetectionWrapperPass>();
    AU.addPreserved<ScalarEvolutionWrapperPass>();
    AU.addPreserved<SCEVAAWrapperPass>();

    // FIXME: We do not yet add regions for the newly generated code to the
    //        region tree.
    AU.addPreserved<RegionInfoPass>();
    AU.addPreserved<ScopInfoRegionPass>();
  }
};
} // namespace

PreservedAnalyses
polly::CodeGenerationPass::run(Scop &S, ScopAnalysisManager &SAM,
                               ScopStandardAnalysisResults &AR, SPMUpdater &U) {
  auto &AI = SAM.getResult<IslAstAnalysis>(S, AR);
  if (CodeGen(S, AI, AR.LI, AR.DT, AR.SE, AR.RI))
    return PreservedAnalyses::none();

  return PreservedAnalyses::all();
}

char CodeGeneration::ID = 1;

Pass *polly::createCodeGenerationPass() { return new CodeGeneration(); }

INITIALIZE_PASS_BEGIN(CodeGeneration, "polly-codegen",
                      "Polly - Create LLVM-IR from SCoPs", false, false);
INITIALIZE_PASS_DEPENDENCY(DependenceInfo);
INITIALIZE_PASS_DEPENDENCY(DominatorTreeWrapperPass);
INITIALIZE_PASS_DEPENDENCY(LoopInfoWrapperPass);
INITIALIZE_PASS_DEPENDENCY(RegionInfoPass);
INITIALIZE_PASS_DEPENDENCY(ScalarEvolutionWrapperPass);
INITIALIZE_PASS_DEPENDENCY(ScopDetectionWrapperPass);
INITIALIZE_PASS_END(CodeGeneration, "polly-codegen",
                    "Polly - Create LLVM-IR from SCoPs", false, false)
