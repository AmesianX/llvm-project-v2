//===-- CommandCompletions.cpp ----------------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

// C Includes
#include <sys/stat.h>
#if defined(__APPLE__) || defined(__linux__)
#include <pwd.h>
#endif

// C++ Includes
// Other libraries and framework includes
#include "llvm/ADT/SmallString.h"
#include "llvm/ADT/StringSet.h"

// Project includes
#include "lldb/Core/FileSpecList.h"
#include "lldb/Core/Module.h"
#include "lldb/Core/PluginManager.h"
#include "lldb/Host/FileSystem.h"
#include "lldb/Interpreter/Args.h"
#include "lldb/Interpreter/CommandCompletions.h"
#include "lldb/Interpreter/CommandInterpreter.h"
#include "lldb/Interpreter/OptionValueProperties.h"
#include "lldb/Symbol/CompileUnit.h"
#include "lldb/Symbol/Variable.h"
#include "lldb/Target/Target.h"
#include "lldb/Utility/CleanUp.h"
#include "lldb/Utility/FileSpec.h"
#include "lldb/Utility/StreamString.h"
#include "lldb/Utility/TildeExpressionResolver.h"

#include "llvm/ADT/SmallString.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/Path.h"

using namespace lldb_private;

CommandCompletions::CommonCompletionElement
    CommandCompletions::g_common_completions[] = {
        {eCustomCompletion, nullptr},
        {eSourceFileCompletion, CommandCompletions::SourceFiles},
        {eDiskFileCompletion, CommandCompletions::DiskFiles},
        {eDiskDirectoryCompletion, CommandCompletions::DiskDirectories},
        {eSymbolCompletion, CommandCompletions::Symbols},
        {eModuleCompletion, CommandCompletions::Modules},
        {eSettingsNameCompletion, CommandCompletions::SettingsNames},
        {ePlatformPluginCompletion, CommandCompletions::PlatformPluginNames},
        {eArchitectureCompletion, CommandCompletions::ArchitectureNames},
        {eVariablePathCompletion, CommandCompletions::VariablePath},
        {eNoCompletion, nullptr} // This one has to be last in the list.
};

bool CommandCompletions::InvokeCommonCompletionCallbacks(
    CommandInterpreter &interpreter, uint32_t completion_mask,
    llvm::StringRef completion_str, int match_start_point,
    int max_return_elements, SearchFilter *searcher, bool &word_complete,
    StringList &matches) {
  bool handled = false;

  if (completion_mask & eCustomCompletion)
    return false;

  for (int i = 0;; i++) {
    if (g_common_completions[i].type == eNoCompletion)
      break;
    else if ((g_common_completions[i].type & completion_mask) ==
                 g_common_completions[i].type &&
             g_common_completions[i].callback != nullptr) {
      handled = true;
      g_common_completions[i].callback(interpreter, completion_str,
                                       match_start_point, max_return_elements,
                                       searcher, word_complete, matches);
    }
  }
  return handled;
}

int CommandCompletions::SourceFiles(CommandInterpreter &interpreter,
                                    llvm::StringRef partial_file_name,
                                    int match_start_point,
                                    int max_return_elements,
                                    SearchFilter *searcher, bool &word_complete,
                                    StringList &matches) {
  word_complete = true;
  // Find some way to switch "include support files..."
  SourceFileCompleter completer(interpreter, false, partial_file_name,
                                match_start_point, max_return_elements,
                                matches);

  if (searcher == nullptr) {
    lldb::TargetSP target_sp = interpreter.GetDebugger().GetSelectedTarget();
    SearchFilterForUnconstrainedSearches null_searcher(target_sp);
    completer.DoCompletion(&null_searcher);
  } else {
    completer.DoCompletion(searcher);
  }
  return matches.GetSize();
}

static int DiskFilesOrDirectories(const llvm::Twine &partial_name,
                                  bool only_directories, bool &saw_directory,
                                  StringList &matches,
                                  TildeExpressionResolver &Resolver) {
  matches.Clear();

  llvm::SmallString<256> CompletionBuffer;
  llvm::SmallString<256> Storage;
  partial_name.toVector(CompletionBuffer);

  if (CompletionBuffer.size() >= PATH_MAX)
    return 0;

  namespace fs = llvm::sys::fs;
  namespace path = llvm::sys::path;

  llvm::StringRef SearchDir;
  llvm::StringRef PartialItem;

  if (CompletionBuffer.startswith("~")) {
    llvm::StringRef Buffer(CompletionBuffer);
    size_t FirstSep =
        Buffer.find_if([](char c) { return path::is_separator(c); });

    llvm::StringRef Username = Buffer.take_front(FirstSep);
    llvm::StringRef Remainder;
    if (FirstSep != llvm::StringRef::npos)
      Remainder = Buffer.drop_front(FirstSep + 1);

    llvm::SmallString<PATH_MAX> Resolved;
    if (!Resolver.ResolveExact(Username, Resolved)) {
      // We couldn't resolve it as a full username.  If there were no slashes
      // then this might be a partial username.   We try to resolve it as such
      // but after that, we're done regardless of any matches.
      if (FirstSep == llvm::StringRef::npos) {
        llvm::StringSet<> MatchSet;
        saw_directory = Resolver.ResolvePartial(Username, MatchSet);
        for (const auto &S : MatchSet) {
          Resolved = S.getKey();
          path::append(Resolved, path::get_separator());
          matches.AppendString(Resolved);
        }
        saw_directory = (matches.GetSize() > 0);
      }
      return matches.GetSize();
    }

    // If there was no trailing slash, then we're done as soon as we resolve the
    // expression to the correct directory.  Otherwise we need to continue
    // looking for matches within that directory.
    if (FirstSep == llvm::StringRef::npos) {
      // Make sure it ends with a separator.
      path::append(CompletionBuffer, path::get_separator());
      saw_directory = true;
      matches.AppendString(CompletionBuffer);
      return 1;
    }

    // We want to keep the form the user typed, so we special case this to
    // search in the fully resolved directory, but CompletionBuffer keeps the
    // unmodified form that the user typed.
    Storage = Resolved;
    SearchDir = Resolved;
  } else {
    SearchDir = path::parent_path(CompletionBuffer);
  }

  size_t FullPrefixLen = CompletionBuffer.size();

  PartialItem = path::filename(CompletionBuffer);
  if (PartialItem == ".")
    PartialItem = llvm::StringRef();

  assert(!SearchDir.empty());
  assert(!PartialItem.contains(path::get_separator()));

  // SearchDir now contains the directory to search in, and Prefix contains the
  // text we want to match against items in that directory.

  std::error_code EC;
  fs::directory_iterator Iter(SearchDir, EC, false);
  fs::directory_iterator End;
  for (; Iter != End && !EC; Iter.increment(EC)) {
    auto &Entry = *Iter;

    auto Name = path::filename(Entry.path());

    // Omit ".", ".."
    if (Name == "." || Name == ".." || !Name.startswith(PartialItem))
      continue;

    // We have a match.

    fs::file_status st;
    if ((EC = Entry.status(st)))
      continue;

    // If it's a symlink, then we treat it as a directory as long as the target
    // is a directory.
    bool is_dir = fs::is_directory(st);
    if (fs::is_symlink_file(st)) {
      fs::file_status target_st;
      if (!fs::status(Entry.path(), target_st))
        is_dir = fs::is_directory(target_st);
    }
    if (only_directories && !is_dir)
      continue;

    // Shrink it back down so that it just has the original prefix the user
    // typed and remove the part of the name which is common to the located
    // item and what the user typed.
    CompletionBuffer.resize(FullPrefixLen);
    Name = Name.drop_front(PartialItem.size());
    CompletionBuffer.append(Name);

    if (is_dir) {
      saw_directory = true;
      path::append(CompletionBuffer, path::get_separator());
    }

    matches.AppendString(CompletionBuffer);
  }

  return matches.GetSize();
}

int CommandCompletions::DiskFiles(CommandInterpreter &interpreter,
                                  llvm::StringRef partial_file_name,
                                  int match_start_point,
                                  int max_return_elements,
                                  SearchFilter *searcher, bool &word_complete,
                                  StringList &matches) {
  word_complete = false;
  StandardTildeExpressionResolver Resolver;
  return DiskFiles(partial_file_name, matches, Resolver);
}

int CommandCompletions::DiskFiles(const llvm::Twine &partial_file_name,
                                  StringList &matches,
                                  TildeExpressionResolver &Resolver) {
  bool word_complete;
  int ret_val = DiskFilesOrDirectories(partial_file_name, false, word_complete,
                                       matches, Resolver);
  return ret_val;
}

int CommandCompletions::DiskDirectories(
    CommandInterpreter &interpreter, llvm::StringRef partial_file_name,
    int match_start_point, int max_return_elements, SearchFilter *searcher,
    bool &word_complete, StringList &matches) {
  word_complete = false;
  StandardTildeExpressionResolver Resolver;
  return DiskDirectories(partial_file_name, matches, Resolver);
}

int CommandCompletions::DiskDirectories(const llvm::Twine &partial_file_name,
                                        StringList &matches,
                                        TildeExpressionResolver &Resolver) {
  bool word_complete;
  int ret_val = DiskFilesOrDirectories(partial_file_name, true, word_complete,
                                       matches, Resolver);
  return ret_val;
}

int CommandCompletions::Modules(CommandInterpreter &interpreter,
                                llvm::StringRef partial_file_name,
                                int match_start_point, int max_return_elements,
                                SearchFilter *searcher, bool &word_complete,
                                StringList &matches) {
  word_complete = true;
  ModuleCompleter completer(interpreter, partial_file_name, match_start_point,
                            max_return_elements, matches);

  if (searcher == nullptr) {
    lldb::TargetSP target_sp = interpreter.GetDebugger().GetSelectedTarget();
    SearchFilterForUnconstrainedSearches null_searcher(target_sp);
    completer.DoCompletion(&null_searcher);
  } else {
    completer.DoCompletion(searcher);
  }
  return matches.GetSize();
}

int CommandCompletions::Symbols(CommandInterpreter &interpreter,
                                llvm::StringRef partial_file_name,
                                int match_start_point, int max_return_elements,
                                SearchFilter *searcher, bool &word_complete,
                                StringList &matches) {
  word_complete = true;
  SymbolCompleter completer(interpreter, partial_file_name, match_start_point,
                            max_return_elements, matches);

  if (searcher == nullptr) {
    lldb::TargetSP target_sp = interpreter.GetDebugger().GetSelectedTarget();
    SearchFilterForUnconstrainedSearches null_searcher(target_sp);
    completer.DoCompletion(&null_searcher);
  } else {
    completer.DoCompletion(searcher);
  }
  return matches.GetSize();
}

int CommandCompletions::SettingsNames(
    CommandInterpreter &interpreter, llvm::StringRef partial_setting_name,
    int match_start_point, int max_return_elements, SearchFilter *searcher,
    bool &word_complete, StringList &matches) {
  // Cache the full setting name list
  static StringList g_property_names;
  if (g_property_names.GetSize() == 0) {
    // Generate the full setting name list on demand
    lldb::OptionValuePropertiesSP properties_sp(
        interpreter.GetDebugger().GetValueProperties());
    if (properties_sp) {
      StreamString strm;
      properties_sp->DumpValue(nullptr, strm, OptionValue::eDumpOptionName);
      const std::string &str = strm.GetString();
      g_property_names.SplitIntoLines(str.c_str(), str.size());
    }
  }

  size_t exact_matches_idx = SIZE_MAX;
  const size_t num_matches = g_property_names.AutoComplete(
      partial_setting_name, matches, exact_matches_idx);
  word_complete = exact_matches_idx != SIZE_MAX;
  return num_matches;
}

int CommandCompletions::PlatformPluginNames(
    CommandInterpreter &interpreter, llvm::StringRef partial_name,
    int match_start_point, int max_return_elements, SearchFilter *searcher,
    bool &word_complete, lldb_private::StringList &matches) {
  const uint32_t num_matches =
      PluginManager::AutoCompletePlatformName(partial_name, matches);
  word_complete = num_matches == 1;
  return num_matches;
}

int CommandCompletions::ArchitectureNames(
    CommandInterpreter &interpreter, llvm::StringRef partial_name,
    int match_start_point, int max_return_elements, SearchFilter *searcher,
    bool &word_complete, lldb_private::StringList &matches) {
  const uint32_t num_matches = ArchSpec::AutoComplete(partial_name, matches);
  word_complete = num_matches == 1;
  return num_matches;
}

int CommandCompletions::VariablePath(
    CommandInterpreter &interpreter, llvm::StringRef partial_name,
    int match_start_point, int max_return_elements, SearchFilter *searcher,
    bool &word_complete, lldb_private::StringList &matches) {
  return Variable::AutoComplete(interpreter.GetExecutionContext(), partial_name,
                                matches, word_complete);
}

CommandCompletions::Completer::Completer(CommandInterpreter &interpreter,
                                         llvm::StringRef completion_str,
                                         int match_start_point,
                                         int max_return_elements,
                                         StringList &matches)
    : m_interpreter(interpreter), m_completion_str(completion_str),
      m_match_start_point(match_start_point),
      m_max_return_elements(max_return_elements), m_matches(matches) {}

CommandCompletions::Completer::~Completer() = default;

//----------------------------------------------------------------------
// SourceFileCompleter
//----------------------------------------------------------------------

CommandCompletions::SourceFileCompleter::SourceFileCompleter(
    CommandInterpreter &interpreter, bool include_support_files,
    llvm::StringRef completion_str, int match_start_point,
    int max_return_elements, StringList &matches)
    : CommandCompletions::Completer(interpreter, completion_str,
                                    match_start_point, max_return_elements,
                                    matches),
      m_include_support_files(include_support_files), m_matching_files() {
  FileSpec partial_spec(m_completion_str, false);
  m_file_name = partial_spec.GetFilename().GetCString();
  m_dir_name = partial_spec.GetDirectory().GetCString();
}

Searcher::Depth CommandCompletions::SourceFileCompleter::GetDepth() {
  return eDepthCompUnit;
}

Searcher::CallbackReturn
CommandCompletions::SourceFileCompleter::SearchCallback(SearchFilter &filter,
                                                        SymbolContext &context,
                                                        Address *addr,
                                                        bool complete) {
  if (context.comp_unit != nullptr) {
    if (m_include_support_files) {
      FileSpecList supporting_files = context.comp_unit->GetSupportFiles();
      for (size_t sfiles = 0; sfiles < supporting_files.GetSize(); sfiles++) {
        const FileSpec &sfile_spec =
            supporting_files.GetFileSpecAtIndex(sfiles);
        const char *sfile_file_name = sfile_spec.GetFilename().GetCString();
        const char *sfile_dir_name = sfile_spec.GetFilename().GetCString();
        bool match = false;
        if (m_file_name && sfile_file_name &&
            strstr(sfile_file_name, m_file_name) == sfile_file_name)
          match = true;
        if (match && m_dir_name && sfile_dir_name &&
            strstr(sfile_dir_name, m_dir_name) != sfile_dir_name)
          match = false;

        if (match) {
          m_matching_files.AppendIfUnique(sfile_spec);
        }
      }
    } else {
      const char *cur_file_name = context.comp_unit->GetFilename().GetCString();
      const char *cur_dir_name = context.comp_unit->GetDirectory().GetCString();

      bool match = false;
      if (m_file_name && cur_file_name &&
          strstr(cur_file_name, m_file_name) == cur_file_name)
        match = true;

      if (match && m_dir_name && cur_dir_name &&
          strstr(cur_dir_name, m_dir_name) != cur_dir_name)
        match = false;

      if (match) {
        m_matching_files.AppendIfUnique(context.comp_unit);
      }
    }
  }
  return Searcher::eCallbackReturnContinue;
}

size_t
CommandCompletions::SourceFileCompleter::DoCompletion(SearchFilter *filter) {
  filter->Search(*this);
  // Now convert the filelist to completions:
  for (size_t i = 0; i < m_matching_files.GetSize(); i++) {
    m_matches.AppendString(
        m_matching_files.GetFileSpecAtIndex(i).GetFilename().GetCString());
  }
  return m_matches.GetSize();
}

//----------------------------------------------------------------------
// SymbolCompleter
//----------------------------------------------------------------------

static bool regex_chars(const char comp) {
  return (comp == '[' || comp == ']' || comp == '(' || comp == ')' ||
          comp == '{' || comp == '}' || comp == '+' || comp == '.' ||
          comp == '*' || comp == '|' || comp == '^' || comp == '$' ||
          comp == '\\' || comp == '?');
}

CommandCompletions::SymbolCompleter::SymbolCompleter(
    CommandInterpreter &interpreter, llvm::StringRef completion_str,
    int match_start_point, int max_return_elements, StringList &matches)
    : CommandCompletions::Completer(interpreter, completion_str,
                                    match_start_point, max_return_elements,
                                    matches) {
  std::string regex_str;
  if (!completion_str.empty()) {
    regex_str.append("^");
    regex_str.append(completion_str);
  } else {
    // Match anything since the completion string is empty
    regex_str.append(".");
  }
  std::string::iterator pos =
      find_if(regex_str.begin() + 1, regex_str.end(), regex_chars);
  while (pos < regex_str.end()) {
    pos = regex_str.insert(pos, '\\');
    pos = find_if(pos + 2, regex_str.end(), regex_chars);
  }
  m_regex.Compile(regex_str);
}

Searcher::Depth CommandCompletions::SymbolCompleter::GetDepth() {
  return eDepthModule;
}

Searcher::CallbackReturn CommandCompletions::SymbolCompleter::SearchCallback(
    SearchFilter &filter, SymbolContext &context, Address *addr,
    bool complete) {
  if (context.module_sp) {
    SymbolContextList sc_list;
    const bool include_symbols = true;
    const bool include_inlines = true;
    const bool append = true;
    context.module_sp->FindFunctions(m_regex, include_symbols, include_inlines,
                                     append, sc_list);

    SymbolContext sc;
    // Now add the functions & symbols to the list - only add if unique:
    for (uint32_t i = 0; i < sc_list.GetSize(); i++) {
      if (sc_list.GetContextAtIndex(i, sc)) {
        ConstString func_name = sc.GetFunctionName(Mangled::ePreferDemangled);
        if (!func_name.IsEmpty())
          m_match_set.insert(func_name);
      }
    }
  }
  return Searcher::eCallbackReturnContinue;
}

size_t CommandCompletions::SymbolCompleter::DoCompletion(SearchFilter *filter) {
  filter->Search(*this);
  collection::iterator pos = m_match_set.begin(), end = m_match_set.end();
  for (pos = m_match_set.begin(); pos != end; pos++)
    m_matches.AppendString((*pos).GetCString());

  return m_matches.GetSize();
}

//----------------------------------------------------------------------
// ModuleCompleter
//----------------------------------------------------------------------
CommandCompletions::ModuleCompleter::ModuleCompleter(
    CommandInterpreter &interpreter, llvm::StringRef completion_str,
    int match_start_point, int max_return_elements, StringList &matches)
    : CommandCompletions::Completer(interpreter, completion_str,
                                    match_start_point, max_return_elements,
                                    matches) {
  FileSpec partial_spec(m_completion_str, false);
  m_file_name = partial_spec.GetFilename().GetCString();
  m_dir_name = partial_spec.GetDirectory().GetCString();
}

Searcher::Depth CommandCompletions::ModuleCompleter::GetDepth() {
  return eDepthModule;
}

Searcher::CallbackReturn CommandCompletions::ModuleCompleter::SearchCallback(
    SearchFilter &filter, SymbolContext &context, Address *addr,
    bool complete) {
  if (context.module_sp) {
    const char *cur_file_name =
        context.module_sp->GetFileSpec().GetFilename().GetCString();
    const char *cur_dir_name =
        context.module_sp->GetFileSpec().GetDirectory().GetCString();

    bool match = false;
    if (m_file_name && cur_file_name &&
        strstr(cur_file_name, m_file_name) == cur_file_name)
      match = true;

    if (match && m_dir_name && cur_dir_name &&
        strstr(cur_dir_name, m_dir_name) != cur_dir_name)
      match = false;

    if (match) {
      m_matches.AppendString(cur_file_name);
    }
  }
  return Searcher::eCallbackReturnContinue;
}

size_t CommandCompletions::ModuleCompleter::DoCompletion(SearchFilter *filter) {
  filter->Search(*this);
  return m_matches.GetSize();
}
