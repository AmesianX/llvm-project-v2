//===- HotColdSplitting.cpp -- Outline Cold Regions -------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
///
/// \file
/// The goal of hot/cold splitting is to improve the memory locality of code.
/// The splitting pass does this by identifying cold blocks and moving them into
/// separate functions.
///
/// When the splitting pass finds a cold block (referred to as "the sink"), it
/// grows a maximal cold region around that block. The maximal region contains
/// all blocks (post-)dominated by the sink [*]. In theory, these blocks are as
/// cold as the sink. Once a region is found, it's split out of the original
/// function provided it's profitable to do so.
///
/// [*] In practice, there is some added complexity because some blocks are not
/// safe to extract.
///
/// TODO: Use the PM to get domtrees, and preserve BFI/BPI.
/// TODO: Reorder outlined functions.
///
//===----------------------------------------------------------------------===//

#include "llvm/ADT/PostOrderIterator.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/Analysis/AliasAnalysis.h"
#include "llvm/Analysis/BlockFrequencyInfo.h"
#include "llvm/Analysis/BranchProbabilityInfo.h"
#include "llvm/Analysis/CFG.h"
#include "llvm/Analysis/OptimizationRemarkEmitter.h"
#include "llvm/Analysis/PostDominators.h"
#include "llvm/Analysis/ProfileSummaryInfo.h"
#include "llvm/Analysis/TargetTransformInfo.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/CallSite.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/DiagnosticInfo.h"
#include "llvm/IR/Dominators.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Instruction.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/Metadata.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/PassManager.h"
#include "llvm/IR/Type.h"
#include "llvm/IR/Use.h"
#include "llvm/IR/User.h"
#include "llvm/IR/Value.h"
#include "llvm/Pass.h"
#include "llvm/Support/BlockFrequency.h"
#include "llvm/Support/BranchProbability.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/IPO.h"
#include "llvm/Transforms/IPO/HotColdSplitting.h"
#include "llvm/Transforms/Scalar.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include "llvm/Transforms/Utils/CodeExtractor.h"
#include "llvm/Transforms/Utils/Local.h"
#include "llvm/Transforms/Utils/SSAUpdater.h"
#include "llvm/Transforms/Utils/ValueMapper.h"
#include <algorithm>
#include <cassert>

#define DEBUG_TYPE "hotcoldsplit"

STATISTIC(NumColdRegionsFound, "Number of cold regions found.");
STATISTIC(NumColdRegionsOutlined, "Number of cold regions outlined.");

using namespace llvm;

static cl::opt<bool> EnableStaticAnalyis("hot-cold-static-analysis",
                              cl::init(true), cl::Hidden);

static cl::opt<int>
    SplittingThreshold("hotcoldsplit-threshold", cl::init(3), cl::Hidden,
                       cl::desc("Code size threshold for splitting cold code "
                                "(as a multiple of TCC_Basic)"));

namespace {

/// A sequence of basic blocks.
///
/// A 0-sized SmallVector is slightly cheaper to move than a std::vector.
using BlockSequence = SmallVector<BasicBlock *, 0>;

// Same as blockEndsInUnreachable in CodeGen/BranchFolding.cpp. Do not modify
// this function unless you modify the MBB version as well.
//
/// A no successor, non-return block probably ends in unreachable and is cold.
/// Also consider a block that ends in an indirect branch to be a return block,
/// since many targets use plain indirect branches to return.
bool blockEndsInUnreachable(const BasicBlock &BB) {
  if (!succ_empty(&BB))
    return false;
  if (BB.empty())
    return true;
  const Instruction *I = BB.getTerminator();
  return !(isa<ReturnInst>(I) || isa<IndirectBrInst>(I));
}

bool unlikelyExecuted(BasicBlock &BB) {
  // Exception handling blocks are unlikely executed.
  if (BB.isEHPad() || isa<ResumeInst>(BB.getTerminator()))
    return true;

  // The block is cold if it calls/invokes a cold function.
  for (Instruction &I : BB)
    if (auto CS = CallSite(&I))
      if (CS.hasFnAttr(Attribute::Cold))
        return true;

  // The block is cold if it has an unreachable terminator, unless it's
  // preceded by a call to a (possibly warm) noreturn call (e.g. longjmp).
  if (blockEndsInUnreachable(BB)) {
    if (auto *CI =
            dyn_cast_or_null<CallInst>(BB.getTerminator()->getPrevNode()))
      if (CI->hasFnAttr(Attribute::NoReturn))
        return false;
    return true;
  }

  return false;
}

/// Check whether it's safe to outline \p BB.
static bool mayExtractBlock(const BasicBlock &BB) {
  // EH pads are unsafe to outline because doing so breaks EH type tables. It
  // follows that invoke instructions cannot be extracted, because CodeExtractor
  // requires unwind destinations to be within the extraction region.
  return !BB.hasAddressTaken() && !BB.isEHPad() &&
         !isa<InvokeInst>(BB.getTerminator());
}

/// Check whether \p Region is profitable to outline.
static bool isProfitableToOutline(const BlockSequence &Region,
                                  TargetTransformInfo &TTI) {
  // If the splitting threshold is set at or below zero, skip the usual
  // profitability check.
  if (SplittingThreshold <= 0)
    return true;

  if (Region.size() > 1)
    return true;

  int Cost = 0;
  const BasicBlock &BB = *Region[0];
  for (const Instruction &I : BB) {
    if (isa<DbgInfoIntrinsic>(&I) || &I == BB.getTerminator())
      continue;

    Cost += TTI.getInstructionCost(&I, TargetTransformInfo::TCK_CodeSize);

    if (Cost >= (SplittingThreshold * TargetTransformInfo::TCC_Basic))
      return true;
  }
  return false;
}

/// Mark \p F cold. Based on this assumption, also optimize it for minimum size.
/// Return true if the function is changed.
static bool markFunctionCold(Function &F) {
  assert(!F.hasFnAttribute(Attribute::OptimizeNone) && "Can't mark this cold");
  bool Changed = false;
  if (!F.hasFnAttribute(Attribute::Cold)) {
    F.addFnAttr(Attribute::Cold);
    Changed = true;
  }
  if (!F.hasFnAttribute(Attribute::MinSize)) {
    F.addFnAttr(Attribute::MinSize);
    Changed = true;
  }
  return Changed;
}

class HotColdSplitting {
public:
  HotColdSplitting(ProfileSummaryInfo *ProfSI,
                   function_ref<BlockFrequencyInfo *(Function &)> GBFI,
                   function_ref<TargetTransformInfo &(Function &)> GTTI,
                   std::function<OptimizationRemarkEmitter &(Function &)> *GORE)
      : PSI(ProfSI), GetBFI(GBFI), GetTTI(GTTI), GetORE(GORE) {}
  bool run(Module &M);

private:
  bool isFunctionCold(const Function &F) const;
  bool shouldOutlineFrom(const Function &F) const;
  bool outlineColdRegions(Function &F, bool HasProfileSummary);
  Function *extractColdRegion(const BlockSequence &Region, DominatorTree &DT,
                              BlockFrequencyInfo *BFI, TargetTransformInfo &TTI,
                              OptimizationRemarkEmitter &ORE, unsigned Count);
  ProfileSummaryInfo *PSI;
  function_ref<BlockFrequencyInfo *(Function &)> GetBFI;
  function_ref<TargetTransformInfo &(Function &)> GetTTI;
  std::function<OptimizationRemarkEmitter &(Function &)> *GetORE;
};

class HotColdSplittingLegacyPass : public ModulePass {
public:
  static char ID;
  HotColdSplittingLegacyPass() : ModulePass(ID) {
    initializeHotColdSplittingLegacyPassPass(*PassRegistry::getPassRegistry());
  }

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.addRequired<AssumptionCacheTracker>();
    AU.addRequired<BlockFrequencyInfoWrapperPass>();
    AU.addRequired<ProfileSummaryInfoWrapperPass>();
    AU.addRequired<TargetTransformInfoWrapperPass>();
  }

  bool runOnModule(Module &M) override;
};

} // end anonymous namespace

/// Check whether \p F is inherently cold.
bool HotColdSplitting::isFunctionCold(const Function &F) const {
  if (F.hasFnAttribute(Attribute::Cold))
    return true;

  if (F.getCallingConv() == CallingConv::Cold)
    return true;

  if (PSI->isFunctionEntryCold(&F))
    return true;

  return false;
}

// Returns false if the function should not be considered for hot-cold split
// optimization.
bool HotColdSplitting::shouldOutlineFrom(const Function &F) const {
  if (F.hasFnAttribute(Attribute::AlwaysInline))
    return false;

  if (F.hasFnAttribute(Attribute::NoInline))
    return false;

  return true;
}

Function *HotColdSplitting::extractColdRegion(const BlockSequence &Region,
                                              DominatorTree &DT,
                                              BlockFrequencyInfo *BFI,
                                              TargetTransformInfo &TTI,
                                              OptimizationRemarkEmitter &ORE,
                                              unsigned Count) {
  assert(!Region.empty());

  // TODO: Pass BFI and BPI to update profile information.
  CodeExtractor CE(Region, &DT, /* AggregateArgs */ false, /* BFI */ nullptr,
                   /* BPI */ nullptr, /* AllowVarArgs */ false,
                   /* AllowAlloca */ false,
                   /* Suffix */ "cold." + std::to_string(Count));

  Function *OrigF = Region[0]->getParent();
  if (Function *OutF = CE.extractCodeRegion()) {
    User *U = *OutF->user_begin();
    CallInst *CI = cast<CallInst>(U);
    CallSite CS(CI);
    NumColdRegionsOutlined++;
    if (TTI.useColdCCForColdCall(*OutF)) {
      OutF->setCallingConv(CallingConv::Cold);
      CS.setCallingConv(CallingConv::Cold);
    }
    CI->setIsNoInline();

    markFunctionCold(*OutF);

    LLVM_DEBUG(llvm::dbgs() << "Outlined Region: " << *OutF);
    ORE.emit([&]() {
      return OptimizationRemark(DEBUG_TYPE, "HotColdSplit",
                                &*Region[0]->begin())
             << ore::NV("Original", OrigF) << " split cold code into "
             << ore::NV("Split", OutF);
    });
    return OutF;
  }

  ORE.emit([&]() {
    return OptimizationRemarkMissed(DEBUG_TYPE, "ExtractFailed",
                                    &*Region[0]->begin())
           << "Failed to extract region at block "
           << ore::NV("Block", Region.front());
  });
  return nullptr;
}

/// A pair of (basic block, score).
using BlockTy = std::pair<BasicBlock *, unsigned>;

/// A maximal outlining region. This contains all blocks post-dominated by a
/// sink block, the sink block itself, and all blocks dominated by the sink.
/// If sink-predecessors and sink-successors cannot be extracted in one region,
/// the static constructor returns a list of suitable extraction regions.
class OutliningRegion {
  /// A list of (block, score) pairs. A block's score is non-zero iff it's a
  /// viable sub-region entry point. Blocks with higher scores are better entry
  /// points (i.e. they are more distant ancestors of the sink block).
  SmallVector<BlockTy, 0> Blocks = {};

  /// The suggested entry point into the region. If the region has multiple
  /// entry points, all blocks within the region may not be reachable from this
  /// entry point.
  BasicBlock *SuggestedEntryPoint = nullptr;

  /// Whether the entire function is cold.
  bool EntireFunctionCold = false;

  /// If \p BB is a viable entry point, return \p Score. Return 0 otherwise.
  static unsigned getEntryPointScore(BasicBlock &BB, unsigned Score) {
    return mayExtractBlock(BB) ? Score : 0;
  }

  /// These scores should be lower than the score for predecessor blocks,
  /// because regions starting at predecessor blocks are typically larger.
  static constexpr unsigned ScoreForSuccBlock = 1;
  static constexpr unsigned ScoreForSinkBlock = 1;

  OutliningRegion(const OutliningRegion &) = delete;
  OutliningRegion &operator=(const OutliningRegion &) = delete;

public:
  OutliningRegion() = default;
  OutliningRegion(OutliningRegion &&) = default;
  OutliningRegion &operator=(OutliningRegion &&) = default;

  static std::vector<OutliningRegion> create(BasicBlock &SinkBB,
                                             const DominatorTree &DT,
                                             const PostDominatorTree &PDT) {
    std::vector<OutliningRegion> Regions;
    SmallPtrSet<BasicBlock *, 4> RegionBlocks;

    Regions.emplace_back();
    OutliningRegion *ColdRegion = &Regions.back();

    auto addBlockToRegion = [&](BasicBlock *BB, unsigned Score) {
      RegionBlocks.insert(BB);
      ColdRegion->Blocks.emplace_back(BB, Score);
    };

    // The ancestor farthest-away from SinkBB, and also post-dominated by it.
    unsigned SinkScore = getEntryPointScore(SinkBB, ScoreForSinkBlock);
    ColdRegion->SuggestedEntryPoint = (SinkScore > 0) ? &SinkBB : nullptr;
    unsigned BestScore = SinkScore;

    // Visit SinkBB's ancestors using inverse DFS.
    auto PredIt = ++idf_begin(&SinkBB);
    auto PredEnd = idf_end(&SinkBB);
    while (PredIt != PredEnd) {
      BasicBlock &PredBB = **PredIt;
      bool SinkPostDom = PDT.dominates(&SinkBB, &PredBB);

      // If the predecessor is cold and has no predecessors, the entire
      // function must be cold.
      if (SinkPostDom && pred_empty(&PredBB)) {
        ColdRegion->EntireFunctionCold = true;
        return Regions;
      }

      // If SinkBB does not post-dominate a predecessor, do not mark the
      // predecessor (or any of its predecessors) cold.
      if (!SinkPostDom || !mayExtractBlock(PredBB)) {
        PredIt.skipChildren();
        continue;
      }

      // Keep track of the post-dominated ancestor farthest away from the sink.
      // The path length is always >= 2, ensuring that predecessor blocks are
      // considered as entry points before the sink block.
      unsigned PredScore = getEntryPointScore(PredBB, PredIt.getPathLength());
      if (PredScore > BestScore) {
        ColdRegion->SuggestedEntryPoint = &PredBB;
        BestScore = PredScore;
      }

      addBlockToRegion(&PredBB, PredScore);
      ++PredIt;
    }

    // If the sink can be added to the cold region, do so. It's considered as
    // an entry point before any sink-successor blocks.
    //
    // Otherwise, split cold sink-successor blocks using a separate region.
    // This satisfies the requirement that all extraction blocks other than the
    // first have predecessors within the extraction region.
    if (mayExtractBlock(SinkBB)) {
      addBlockToRegion(&SinkBB, SinkScore);
    } else {
      Regions.emplace_back();
      ColdRegion = &Regions.back();
      BestScore = 0;
    }

    // Find all successors of SinkBB dominated by SinkBB using DFS.
    auto SuccIt = ++df_begin(&SinkBB);
    auto SuccEnd = df_end(&SinkBB);
    while (SuccIt != SuccEnd) {
      BasicBlock &SuccBB = **SuccIt;
      bool SinkDom = DT.dominates(&SinkBB, &SuccBB);

      // Don't allow the backwards & forwards DFSes to mark the same block.
      bool DuplicateBlock = RegionBlocks.count(&SuccBB);

      // If SinkBB does not dominate a successor, do not mark the successor (or
      // any of its successors) cold.
      if (DuplicateBlock || !SinkDom || !mayExtractBlock(SuccBB)) {
        SuccIt.skipChildren();
        continue;
      }

      unsigned SuccScore = getEntryPointScore(SuccBB, ScoreForSuccBlock);
      if (SuccScore > BestScore) {
        ColdRegion->SuggestedEntryPoint = &SuccBB;
        BestScore = SuccScore;
      }

      addBlockToRegion(&SuccBB, SuccScore);
      ++SuccIt;
    }

    return Regions;
  }

  /// Whether this region has nothing to extract.
  bool empty() const { return !SuggestedEntryPoint; }

  /// The blocks in this region.
  ArrayRef<std::pair<BasicBlock *, unsigned>> blocks() const { return Blocks; }

  /// Whether the entire function containing this region is cold.
  bool isEntireFunctionCold() const { return EntireFunctionCold; }

  /// Remove a sub-region from this region and return it as a block sequence.
  BlockSequence takeSingleEntrySubRegion(DominatorTree &DT) {
    assert(!empty() && !isEntireFunctionCold() && "Nothing to extract");

    // Remove blocks dominated by the suggested entry point from this region.
    // During the removal, identify the next best entry point into the region.
    // Ensure that the first extracted block is the suggested entry point.
    BlockSequence SubRegion = {SuggestedEntryPoint};
    BasicBlock *NextEntryPoint = nullptr;
    unsigned NextScore = 0;
    auto RegionEndIt = Blocks.end();
    auto RegionStartIt = remove_if(Blocks, [&](const BlockTy &Block) {
      BasicBlock *BB = Block.first;
      unsigned Score = Block.second;
      bool InSubRegion =
          BB == SuggestedEntryPoint || DT.dominates(SuggestedEntryPoint, BB);
      if (!InSubRegion && Score > NextScore) {
        NextEntryPoint = BB;
        NextScore = Score;
      }
      if (InSubRegion && BB != SuggestedEntryPoint)
        SubRegion.push_back(BB);
      return InSubRegion;
    });
    Blocks.erase(RegionStartIt, RegionEndIt);

    // Update the suggested entry point.
    SuggestedEntryPoint = NextEntryPoint;

    return SubRegion;
  }
};

bool HotColdSplitting::outlineColdRegions(Function &F, bool HasProfileSummary) {
  bool Changed = false;

  // The set of cold blocks.
  SmallPtrSet<BasicBlock *, 4> ColdBlocks;

  // The worklist of non-intersecting regions left to outline.
  SmallVector<OutliningRegion, 2> OutliningWorklist;

  // Set up an RPO traversal. Experimentally, this performs better (outlines
  // more) than a PO traversal, because we prevent region overlap by keeping
  // the first region to contain a block.
  ReversePostOrderTraversal<Function *> RPOT(&F);

  // Calculate domtrees lazily. This reduces compile-time significantly.
  std::unique_ptr<DominatorTree> DT;
  std::unique_ptr<PostDominatorTree> PDT;

  // Calculate BFI lazily (it's only used to query ProfileSummaryInfo). This
  // reduces compile-time significantly. TODO: When we *do* use BFI, we should
  // be able to salvage its domtrees instead of recomputing them.
  BlockFrequencyInfo *BFI = nullptr;
  if (HasProfileSummary)
    BFI = GetBFI(F);

  TargetTransformInfo &TTI = GetTTI(F);
  OptimizationRemarkEmitter &ORE = (*GetORE)(F);

  // Find all cold regions.
  for (BasicBlock *BB : RPOT) {
    // This block is already part of some outlining region.
    if (ColdBlocks.count(BB))
      continue;

    bool Cold = (BFI && PSI->isColdBlock(BB, BFI)) ||
                (EnableStaticAnalyis && unlikelyExecuted(*BB));
    if (!Cold)
      continue;

    LLVM_DEBUG({
      dbgs() << "Found a cold block:\n";
      BB->dump();
    });

    if (!DT)
      DT = make_unique<DominatorTree>(F);
    if (!PDT)
      PDT = make_unique<PostDominatorTree>(F);

    auto Regions = OutliningRegion::create(*BB, *DT, *PDT);
    for (OutliningRegion &Region : Regions) {
      if (Region.empty())
        continue;

      if (Region.isEntireFunctionCold()) {
        LLVM_DEBUG(dbgs() << "Entire function is cold\n");
        return markFunctionCold(F);
      }

      // If this outlining region intersects with another, drop the new region.
      //
      // TODO: It's theoretically possible to outline more by only keeping the
      // largest region which contains a block, but the extra bookkeeping to do
      // this is tricky/expensive.
      bool RegionsOverlap = any_of(Region.blocks(), [&](const BlockTy &Block) {
        return !ColdBlocks.insert(Block.first).second;
      });
      if (RegionsOverlap)
        continue;

      OutliningWorklist.emplace_back(std::move(Region));
      ++NumColdRegionsFound;
    }
  }

  // Outline single-entry cold regions, splitting up larger regions as needed.
  unsigned OutlinedFunctionID = 1;
  while (!OutliningWorklist.empty()) {
    OutliningRegion Region = OutliningWorklist.pop_back_val();
    assert(!Region.empty() && "Empty outlining region in worklist");
    do {
      BlockSequence SubRegion = Region.takeSingleEntrySubRegion(*DT);
      if (!isProfitableToOutline(SubRegion, TTI)) {
        LLVM_DEBUG({
          dbgs() << "Skipping outlining; not profitable to outline\n";
          SubRegion[0]->dump();
        });
        continue;
      }

      LLVM_DEBUG({
        dbgs() << "Hot/cold splitting attempting to outline these blocks:\n";
        for (BasicBlock *BB : SubRegion)
          BB->dump();
      });

      Function *Outlined =
          extractColdRegion(SubRegion, *DT, BFI, TTI, ORE, OutlinedFunctionID);
      if (Outlined) {
        ++OutlinedFunctionID;
        Changed = true;
      }
    } while (!Region.empty());
  }

  return Changed;
}

bool HotColdSplitting::run(Module &M) {
  bool Changed = false;
  bool HasProfileSummary = M.getProfileSummary();
  for (auto It = M.begin(), End = M.end(); It != End; ++It) {
    Function &F = *It;

    // Do not touch declarations.
    if (F.isDeclaration())
      continue;

    // Do not modify `optnone` functions.
    if (F.hasFnAttribute(Attribute::OptimizeNone))
      continue;

    // Detect inherently cold functions and mark them as such.
    if (isFunctionCold(F)) {
      Changed |= markFunctionCold(F);
      continue;
    }

    if (!shouldOutlineFrom(F)) {
      LLVM_DEBUG(llvm::dbgs() << "Skipping " << F.getName() << "\n");
      continue;
    }

    LLVM_DEBUG(llvm::dbgs() << "Outlining in " << F.getName() << "\n");
    Changed |= outlineColdRegions(F, HasProfileSummary);
  }
  return Changed;
}

bool HotColdSplittingLegacyPass::runOnModule(Module &M) {
  if (skipModule(M))
    return false;
  ProfileSummaryInfo *PSI =
      &getAnalysis<ProfileSummaryInfoWrapperPass>().getPSI();
  auto GTTI = [this](Function &F) -> TargetTransformInfo & {
    return this->getAnalysis<TargetTransformInfoWrapperPass>().getTTI(F);
  };
  auto GBFI = [this](Function &F) {
    return &this->getAnalysis<BlockFrequencyInfoWrapperPass>(F).getBFI();
  };
  std::unique_ptr<OptimizationRemarkEmitter> ORE;
  std::function<OptimizationRemarkEmitter &(Function &)> GetORE =
      [&ORE](Function &F) -> OptimizationRemarkEmitter & {
    ORE.reset(new OptimizationRemarkEmitter(&F));
    return *ORE.get();
  };

  return HotColdSplitting(PSI, GBFI, GTTI, &GetORE).run(M);
}

PreservedAnalyses
HotColdSplittingPass::run(Module &M, ModuleAnalysisManager &AM) {
  auto &FAM = AM.getResult<FunctionAnalysisManagerModuleProxy>(M).getManager();

  std::function<AssumptionCache &(Function &)> GetAssumptionCache =
      [&FAM](Function &F) -> AssumptionCache & {
    return FAM.getResult<AssumptionAnalysis>(F);
  };

  auto GBFI = [&FAM](Function &F) {
    return &FAM.getResult<BlockFrequencyAnalysis>(F);
  };

  std::function<TargetTransformInfo &(Function &)> GTTI =
      [&FAM](Function &F) -> TargetTransformInfo & {
    return FAM.getResult<TargetIRAnalysis>(F);
  };

  std::unique_ptr<OptimizationRemarkEmitter> ORE;
  std::function<OptimizationRemarkEmitter &(Function &)> GetORE =
      [&ORE](Function &F) -> OptimizationRemarkEmitter & {
    ORE.reset(new OptimizationRemarkEmitter(&F));
    return *ORE.get();
  };

  ProfileSummaryInfo *PSI = &AM.getResult<ProfileSummaryAnalysis>(M);

  if (HotColdSplitting(PSI, GBFI, GTTI, &GetORE).run(M))
    return PreservedAnalyses::none();
  return PreservedAnalyses::all();
}

char HotColdSplittingLegacyPass::ID = 0;
INITIALIZE_PASS_BEGIN(HotColdSplittingLegacyPass, "hotcoldsplit",
                      "Hot Cold Splitting", false, false)
INITIALIZE_PASS_DEPENDENCY(ProfileSummaryInfoWrapperPass)
INITIALIZE_PASS_DEPENDENCY(BlockFrequencyInfoWrapperPass)
INITIALIZE_PASS_END(HotColdSplittingLegacyPass, "hotcoldsplit",
                    "Hot Cold Splitting", false, false)

ModulePass *llvm::createHotColdSplittingPass() {
  return new HotColdSplittingLegacyPass();
}
