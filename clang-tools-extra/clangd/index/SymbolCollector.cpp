//===--- SymbolCollector.cpp -------------------------------------*- C++-*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "SymbolCollector.h"
#include "../AST.h"
#include "../CodeComplete.h"
#include "../CodeCompletionStrings.h"
#include "../Logger.h"
#include "../SourceCode.h"
#include "../URI.h"
#include "CanonicalIncludes.h"
#include "clang/AST/DeclCXX.h"
#include "clang/AST/DeclTemplate.h"
#include "clang/ASTMatchers/ASTMatchFinder.h"
#include "clang/Basic/SourceManager.h"
#include "clang/Index/IndexSymbol.h"
#include "clang/Index/USRGeneration.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/Support/Path.h"

namespace clang {
namespace clangd {

namespace {
/// If \p ND is a template specialization, returns the described template.
/// Otherwise, returns \p ND.
const NamedDecl &getTemplateOrThis(const NamedDecl &ND) {
  if (auto T = ND.getDescribedTemplate())
    return *T;
  return ND;
}

// Returns a URI of \p Path. Firstly, this makes the \p Path absolute using the
// current working directory of the given SourceManager if the Path is not an
// absolute path. If failed, this resolves relative paths against \p FallbackDir
// to get an absolute path. Then, this tries creating an URI for the absolute
// path with schemes specified in \p Opts. This returns an URI with the first
// working scheme, if there is any; otherwise, this returns None.
//
// The Path can be a path relative to the build directory, or retrieved from
// the SourceManager.
llvm::Optional<std::string> toURI(const SourceManager &SM, StringRef Path,
                                  const SymbolCollector::Options &Opts) {
  llvm::SmallString<128> AbsolutePath(Path);
  if (std::error_code EC =
          SM.getFileManager().getVirtualFileSystem()->makeAbsolute(
              AbsolutePath))
    log("Warning: could not make absolute file: {0}", EC.message());
  if (llvm::sys::path::is_absolute(AbsolutePath)) {
    // Handle the symbolic link path case where the current working directory
    // (getCurrentWorkingDirectory) is a symlink./ We always want to the real
    // file path (instead of the symlink path) for the  C++ symbols.
    //
    // Consider the following example:
    //
    //   src dir: /project/src/foo.h
    //   current working directory (symlink): /tmp/build -> /project/src/
    //
    // The file path of Symbol is "/project/src/foo.h" instead of
    // "/tmp/build/foo.h"
    if (const DirectoryEntry *Dir = SM.getFileManager().getDirectory(
            llvm::sys::path::parent_path(AbsolutePath.str()))) {
      StringRef DirName = SM.getFileManager().getCanonicalName(Dir);
      SmallString<128> AbsoluteFilename;
      llvm::sys::path::append(AbsoluteFilename, DirName,
                              llvm::sys::path::filename(AbsolutePath.str()));
      AbsolutePath = AbsoluteFilename;
    }
  } else if (!Opts.FallbackDir.empty()) {
    llvm::sys::fs::make_absolute(Opts.FallbackDir, AbsolutePath);
  }

  llvm::sys::path::remove_dots(AbsolutePath, /*remove_dot_dot=*/true);

  std::string ErrMsg;
  for (const auto &Scheme : Opts.URISchemes) {
    auto U = URI::create(AbsolutePath, Scheme);
    if (U)
      return U->toString();
    ErrMsg += llvm::toString(U.takeError()) + "\n";
  }
  log("Failed to create an URI for file {0}: {1}", AbsolutePath, ErrMsg);
  return llvm::None;
}

// All proto generated headers should start with this line.
static const char *PROTO_HEADER_COMMENT =
    "// Generated by the protocol buffer compiler.  DO NOT EDIT!";

// Checks whether the decl is a private symbol in a header generated by
// protobuf compiler.
// To identify whether a proto header is actually generated by proto compiler,
// we check whether it starts with PROTO_HEADER_COMMENT.
// FIXME: make filtering extensible when there are more use cases for symbol
// filters.
bool isPrivateProtoDecl(const NamedDecl &ND) {
  const auto &SM = ND.getASTContext().getSourceManager();
  auto Loc = findNameLoc(&ND);
  auto FileName = SM.getFilename(Loc);
  if (!FileName.endswith(".proto.h") && !FileName.endswith(".pb.h"))
    return false;
  auto FID = SM.getFileID(Loc);
  // Double check that this is an actual protobuf header.
  if (!SM.getBufferData(FID).startswith(PROTO_HEADER_COMMENT))
    return false;

  // ND without identifier can be operators.
  if (ND.getIdentifier() == nullptr)
    return false;
  auto Name = ND.getIdentifier()->getName();
  if (!Name.contains('_'))
    return false;
  // Nested proto entities (e.g. Message::Nested) have top-level decls
  // that shouldn't be used (Message_Nested). Ignore them completely.
  // The nested entities are dangling type aliases, we may want to reconsider
  // including them in the future.
  // For enum constants, SOME_ENUM_CONSTANT is not private and should be
  // indexed. Outer_INNER is private. This heuristic relies on naming style, it
  // will include OUTER_INNER and exclude some_enum_constant.
  // FIXME: the heuristic relies on naming style (i.e. no underscore in
  // user-defined names) and can be improved.
  return (ND.getKind() != Decl::EnumConstant) ||
         std::any_of(Name.begin(), Name.end(), islower);
}

// We only collect #include paths for symbols that are suitable for global code
// completion, except for namespaces since #include path for a namespace is hard
// to define.
bool shouldCollectIncludePath(index::SymbolKind Kind) {
  using SK = index::SymbolKind;
  switch (Kind) {
  case SK::Macro:
  case SK::Enum:
  case SK::Struct:
  case SK::Class:
  case SK::Union:
  case SK::TypeAlias:
  case SK::Using:
  case SK::Function:
  case SK::Variable:
  case SK::EnumConstant:
    return true;
  default:
    return false;
  }
}

/// Gets a canonical include (URI of the header or <header>  or "header") for
/// header of \p Loc.
/// Returns None if fails to get include header for \p Loc.
llvm::Optional<std::string>
getIncludeHeader(llvm::StringRef QName, const SourceManager &SM,
                 SourceLocation Loc, const SymbolCollector::Options &Opts) {
  std::vector<std::string> Headers;
  // Collect the #include stack.
  while (true) {
    if (!Loc.isValid())
      break;
    auto FilePath = SM.getFilename(Loc);
    if (FilePath.empty())
      break;
    Headers.push_back(FilePath);
    if (SM.isInMainFile(Loc))
      break;
    Loc = SM.getIncludeLoc(SM.getFileID(Loc));
  }
  if (Headers.empty())
    return llvm::None;
  llvm::StringRef Header = Headers[0];
  if (Opts.Includes) {
    Header = Opts.Includes->mapHeader(Headers, QName);
    if (Header.startswith("<") || Header.startswith("\""))
      return Header.str();
  }
  return toURI(SM, Header, Opts);
}

// Return the symbol range of the token at \p TokLoc.
std::pair<SymbolLocation::Position, SymbolLocation::Position>
getTokenRange(SourceLocation TokLoc, const SourceManager &SM,
              const LangOptions &LangOpts) {
  auto CreatePosition = [&SM](SourceLocation Loc) {
    auto LSPLoc = sourceLocToPosition(SM, Loc);
    SymbolLocation::Position Pos;
    Pos.Line = LSPLoc.line;
    Pos.Column = LSPLoc.character;
    return Pos;
  };

  auto TokenLength = clang::Lexer::MeasureTokenLength(TokLoc, SM, LangOpts);
  return {CreatePosition(TokLoc),
          CreatePosition(TokLoc.getLocWithOffset(TokenLength))};
}

// Return the symbol location of the token at \p TokLoc.
llvm::Optional<SymbolLocation>
getTokenLocation(SourceLocation TokLoc, const SourceManager &SM,
                 const SymbolCollector::Options &Opts,
                 const clang::LangOptions &LangOpts,
                 std::string &FileURIStorage) {
  auto U = toURI(SM, SM.getFilename(TokLoc), Opts);
  if (!U)
    return llvm::None;
  FileURIStorage = std::move(*U);
  SymbolLocation Result;
  Result.FileURI = FileURIStorage;
  auto Range = getTokenRange(TokLoc, SM, LangOpts);
  Result.Start = Range.first;
  Result.End = Range.second;

  return std::move(Result);
}

// Checks whether \p ND is a definition of a TagDecl (class/struct/enum/union)
// in a header file, in which case clangd would prefer to use ND as a canonical
// declaration.
// FIXME: handle symbol types that are not TagDecl (e.g. functions), if using
// the first seen declaration as canonical declaration is not a good enough
// heuristic.
bool isPreferredDeclaration(const NamedDecl &ND, index::SymbolRoleSet Roles) {
  using namespace clang::ast_matchers;
  return (Roles & static_cast<unsigned>(index::SymbolRole::Definition)) &&
         llvm::isa<TagDecl>(&ND) &&
         match(decl(isExpansionInMainFile()), ND, ND.getASTContext()).empty();
}

SymbolOccurrenceKind toOccurrenceKind(index::SymbolRoleSet Roles) {
  return static_cast<SymbolOccurrenceKind>(
      static_cast<unsigned>(AllOccurrenceKinds) & Roles);
}

} // namespace

SymbolCollector::SymbolCollector(Options Opts) : Opts(std::move(Opts)) {}

void SymbolCollector::initialize(ASTContext &Ctx) {
  ASTCtx = &Ctx;
  CompletionAllocator = std::make_shared<GlobalCodeCompletionAllocator>();
  CompletionTUInfo =
      llvm::make_unique<CodeCompletionTUInfo>(CompletionAllocator);
}

bool SymbolCollector::shouldCollectSymbol(const NamedDecl &ND,
                                          ASTContext &ASTCtx,
                                          const Options &Opts) {
  using namespace clang::ast_matchers;
  if (ND.isImplicit())
    return false;
  // Skip anonymous declarations, e.g (anonymous enum/class/struct).
  if (ND.getDeclName().isEmpty())
    return false;

  // FIXME: figure out a way to handle internal linkage symbols (e.g. static
  // variables, function) defined in the .cc files. Also we skip the symbols
  // in anonymous namespace as the qualifier names of these symbols are like
  // `foo::<anonymous>::bar`, which need a special handling.
  // In real world projects, we have a relatively large set of header files
  // that define static variables (like "static const int A = 1;"), we still
  // want to collect these symbols, although they cause potential ODR
  // violations.
  if (ND.isInAnonymousNamespace())
    return false;

  // We want most things but not "local" symbols such as symbols inside
  // FunctionDecl, BlockDecl, ObjCMethodDecl and OMPDeclareReductionDecl.
  // FIXME: Need a matcher for ExportDecl in order to include symbols declared
  // within an export.
  auto InNonLocalContext = hasDeclContext(anyOf(
      translationUnitDecl(), namespaceDecl(), linkageSpecDecl(), recordDecl(),
      enumDecl(), objcProtocolDecl(), objcInterfaceDecl(), objcCategoryDecl(),
      objcCategoryImplDecl(), objcImplementationDecl()));
  // Don't index template specializations and expansions in main files.
  auto IsSpecialization =
      anyOf(functionDecl(isExplicitTemplateSpecialization()),
            cxxRecordDecl(isExplicitTemplateSpecialization()),
            varDecl(isExplicitTemplateSpecialization()));
  if (match(decl(allOf(unless(isExpansionInMainFile()), InNonLocalContext,
                       unless(IsSpecialization))),
            ND, ASTCtx)
          .empty())
    return false;

  // Avoid indexing internal symbols in protobuf generated headers.
  if (isPrivateProtoDecl(ND))
    return false;
  return true;
}

// Always return true to continue indexing.
bool SymbolCollector::handleDeclOccurence(
    const Decl *D, index::SymbolRoleSet Roles,
    ArrayRef<index::SymbolRelation> Relations, SourceLocation Loc,
    index::IndexDataConsumer::ASTNodeInfo ASTNode) {
  assert(ASTCtx && PP.get() && "ASTContext and Preprocessor must be set.");
  assert(CompletionAllocator && CompletionTUInfo);
  assert(ASTNode.OrigD);
  // If OrigD is an declaration associated with a friend declaration and it's
  // not a definition, skip it. Note that OrigD is the occurrence that the
  // collector is currently visiting.
  if ((ASTNode.OrigD->getFriendObjectKind() !=
       Decl::FriendObjectKind::FOK_None) &&
      !(Roles & static_cast<unsigned>(index::SymbolRole::Definition)))
    return true;
  // A declaration created for a friend declaration should not be used as the
  // canonical declaration in the index. Use OrigD instead, unless we've already
  // picked a replacement for D
  if (D->getFriendObjectKind() != Decl::FriendObjectKind::FOK_None)
    D = CanonicalDecls.try_emplace(D, ASTNode.OrigD).first->second;
  const NamedDecl *ND = llvm::dyn_cast<NamedDecl>(D);
  if (!ND)
    return true;

  // Mark D as referenced if this is a reference coming from the main file.
  // D may not be an interesting symbol, but it's cheaper to check at the end.
  auto &SM = ASTCtx->getSourceManager();
  auto SpellingLoc = SM.getSpellingLoc(Loc);
  if (Opts.CountReferences &&
      (Roles & static_cast<unsigned>(index::SymbolRole::Reference)) &&
      SM.getFileID(SpellingLoc) == SM.getMainFileID())
    ReferencedDecls.insert(ND);

  if ((static_cast<unsigned>(Opts.OccurrenceFilter) & Roles) &&
      SM.getFileID(SpellingLoc) == SM.getMainFileID())
    DeclOccurrences[ND].emplace_back(SpellingLoc, Roles);

  // Don't continue indexing if this is a mere reference.
  if (!(Roles & static_cast<unsigned>(index::SymbolRole::Declaration) ||
        Roles & static_cast<unsigned>(index::SymbolRole::Definition)))
    return true;
  if (!shouldCollectSymbol(*ND, *ASTCtx, Opts))
    return true;

  auto ID = getSymbolID(ND);
  if (!ID)
    return true;

  const NamedDecl &OriginalDecl = *cast<NamedDecl>(ASTNode.OrigD);
  const Symbol *BasicSymbol = Symbols.find(*ID);
  if (!BasicSymbol) // Regardless of role, ND is the canonical declaration.
    BasicSymbol = addDeclaration(*ND, std::move(*ID));
  else if (isPreferredDeclaration(OriginalDecl, Roles))
    // If OriginalDecl is preferred, replace the existing canonical
    // declaration (e.g. a class forward declaration). There should be at most
    // one duplicate as we expect to see only one preferred declaration per
    // TU, because in practice they are definitions.
    BasicSymbol = addDeclaration(OriginalDecl, std::move(*ID));

  if (Roles & static_cast<unsigned>(index::SymbolRole::Definition))
    addDefinition(OriginalDecl, *BasicSymbol);
  return true;
}

bool SymbolCollector::handleMacroOccurence(const IdentifierInfo *Name,
                                           const MacroInfo *MI,
                                           index::SymbolRoleSet Roles,
                                           SourceLocation Loc) {
  if (!Opts.CollectMacro)
    return true;
  assert(PP.get());

  const auto &SM = PP->getSourceManager();
  if (SM.isInMainFile(SM.getExpansionLoc(MI->getDefinitionLoc())))
    return true;
  // Header guards are not interesting in index. Builtin macros don't have
  // useful locations and are not needed for code completions.
  if (MI->isUsedForHeaderGuard() || MI->isBuiltinMacro())
    return true;

  // Mark the macro as referenced if this is a reference coming from the main
  // file. The macro may not be an interesting symbol, but it's cheaper to check
  // at the end.
  if (Opts.CountReferences &&
      (Roles & static_cast<unsigned>(index::SymbolRole::Reference)) &&
      SM.getFileID(SM.getSpellingLoc(Loc)) == SM.getMainFileID())
    ReferencedMacros.insert(Name);
  // Don't continue indexing if this is a mere reference.
  // FIXME: remove macro with ID if it is undefined.
  if (!(Roles & static_cast<unsigned>(index::SymbolRole::Declaration) ||
        Roles & static_cast<unsigned>(index::SymbolRole::Definition)))
    return true;

  llvm::SmallString<128> USR;
  if (index::generateUSRForMacro(Name->getName(), MI->getDefinitionLoc(), SM,
                                 USR))
    return true;
  SymbolID ID(USR);

  // Only collect one instance in case there are multiple.
  if (Symbols.find(ID) != nullptr)
    return true;

  Symbol S;
  S.ID = std::move(ID);
  S.Name = Name->getName();
  S.IsIndexedForCodeCompletion = true;
  S.SymInfo = index::getSymbolInfoForMacro(*MI);
  std::string FileURI;
  if (auto DeclLoc = getTokenLocation(MI->getDefinitionLoc(), SM, Opts,
                                      PP->getLangOpts(), FileURI))
    S.CanonicalDeclaration = *DeclLoc;

  CodeCompletionResult SymbolCompletion(Name);
  const auto *CCS = SymbolCompletion.CreateCodeCompletionStringForMacro(
      *PP, *CompletionAllocator, *CompletionTUInfo);
  std::string Signature;
  std::string SnippetSuffix;
  getSignature(*CCS, &Signature, &SnippetSuffix);

  std::string Include;
  if (Opts.CollectIncludePath && shouldCollectIncludePath(S.SymInfo.Kind)) {
    if (auto Header =
            getIncludeHeader(Name->getName(), SM,
                             SM.getExpansionLoc(MI->getDefinitionLoc()), Opts))
      Include = std::move(*Header);
  }
  S.Signature = Signature;
  S.CompletionSnippetSuffix = SnippetSuffix;
  if (!Include.empty())
    S.IncludeHeaders.emplace_back(Include, 1);

  Symbols.insert(S);
  return true;
}

void SymbolCollector::finish() {
  // At the end of the TU, add 1 to the refcount of all referenced symbols.
  auto IncRef = [this](const SymbolID &ID) {
    if (const auto *S = Symbols.find(ID)) {
      Symbol Inc = *S;
      ++Inc.References;
      Symbols.insert(Inc);
    }
  };
  for (const NamedDecl *ND : ReferencedDecls) {
    if (auto ID = getSymbolID(ND)) {
      IncRef(*ID);
    }
  }
  if (Opts.CollectMacro) {
    assert(PP);
    for (const IdentifierInfo *II : ReferencedMacros) {
      llvm::SmallString<128> USR;
      if (const auto *MI = PP->getMacroDefinition(II).getMacroInfo())
        if (!index::generateUSRForMacro(II->getName(), MI->getDefinitionLoc(),
                                        PP->getSourceManager(), USR))
          IncRef(SymbolID(USR));
    }
  }

  const auto &SM = ASTCtx->getSourceManager();
  auto* MainFileEntry = SM.getFileEntryForID(SM.getMainFileID());

  if (auto MainFileURI = toURI(SM, MainFileEntry->getName(), Opts)) {
    std::string MainURI = *MainFileURI;
    for (const auto &It : DeclOccurrences) {
      if (auto ID = getSymbolID(It.first)) {
        if (Symbols.find(*ID)) {
          for (const auto &LocAndRole : It.second) {
            SymbolOccurrence Occurrence;
            auto Range =
                getTokenRange(LocAndRole.first, SM, ASTCtx->getLangOpts());
            Occurrence.Location.Start = Range.first;
            Occurrence.Location.End = Range.second;
            Occurrence.Location.FileURI = MainURI;
            Occurrence.Kind = toOccurrenceKind(LocAndRole.second);
            SymbolOccurrences.insert(*ID, Occurrence);
          }
        }
      }
    }
  } else {
    log("Failed to create URI for main file: {0}", MainFileEntry->getName());
  }

  ReferencedDecls.clear();
  ReferencedMacros.clear();
  DeclOccurrences.clear();
}

const Symbol *SymbolCollector::addDeclaration(const NamedDecl &ND,
                                              SymbolID ID) {
  auto &Ctx = ND.getASTContext();
  auto &SM = Ctx.getSourceManager();

  Symbol S;
  S.ID = std::move(ID);
  std::string QName = printQualifiedName(ND);
  std::tie(S.Scope, S.Name) = splitQualifiedName(QName);
  // FIXME: this returns foo:bar: for objective-C methods, we prefer only foo:
  // for consistency with CodeCompletionString and a clean name/signature split.

  S.IsIndexedForCodeCompletion = isIndexedForCodeCompletion(ND, Ctx);
  S.SymInfo = index::getSymbolInfo(&ND);
  std::string FileURI;
  if (auto DeclLoc = getTokenLocation(findNameLoc(&ND), SM, Opts,
                                      ASTCtx->getLangOpts(), FileURI))
    S.CanonicalDeclaration = *DeclLoc;

  // Add completion info.
  // FIXME: we may want to choose a different redecl, or combine from several.
  assert(ASTCtx && PP.get() && "ASTContext and Preprocessor must be set.");
  // We use the primary template, as clang does during code completion.
  CodeCompletionResult SymbolCompletion(&getTemplateOrThis(ND), 0);
  const auto *CCS = SymbolCompletion.CreateCodeCompletionString(
      *ASTCtx, *PP, CodeCompletionContext::CCC_Name, *CompletionAllocator,
      *CompletionTUInfo,
      /*IncludeBriefComments*/ false);
  std::string Signature;
  std::string SnippetSuffix;
  getSignature(*CCS, &Signature, &SnippetSuffix);
  std::string Documentation =
      formatDocumentation(*CCS, getDocComment(Ctx, SymbolCompletion,
                                              /*CommentsFromHeaders=*/true));
  std::string ReturnType = getReturnType(*CCS);

  std::string Include;
  if (Opts.CollectIncludePath && shouldCollectIncludePath(S.SymInfo.Kind)) {
    // Use the expansion location to get the #include header since this is
    // where the symbol is exposed.
    if (auto Header = getIncludeHeader(
            QName, SM, SM.getExpansionLoc(ND.getLocation()), Opts))
      Include = std::move(*Header);
  }
  S.Signature = Signature;
  S.CompletionSnippetSuffix = SnippetSuffix;
  S.Documentation = Documentation;
  S.ReturnType = ReturnType;
  if (!Include.empty())
    S.IncludeHeaders.emplace_back(Include, 1);

  S.Origin = Opts.Origin;
  Symbols.insert(S);
  return Symbols.find(S.ID);
}

void SymbolCollector::addDefinition(const NamedDecl &ND,
                                    const Symbol &DeclSym) {
  if (DeclSym.Definition)
    return;
  // If we saw some forward declaration, we end up copying the symbol.
  // This is not ideal, but avoids duplicating the "is this a definition" check
  // in clang::index. We should only see one definition.
  Symbol S = DeclSym;
  std::string FileURI;
  if (auto DefLoc = getTokenLocation(findNameLoc(&ND),
                                     ND.getASTContext().getSourceManager(),
                                     Opts, ASTCtx->getLangOpts(), FileURI))
    S.Definition = *DefLoc;
  Symbols.insert(S);
}

} // namespace clangd
} // namespace clang
