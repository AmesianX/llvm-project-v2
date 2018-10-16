//===-- CommandObjectWatchpoint.cpp -----------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "CommandObjectWatchpoint.h"
#include "CommandObjectWatchpointCommand.h"

// C Includes
// C++ Includes
#include <vector>

// Other libraries and framework includes
#include "llvm/ADT/StringRef.h"

// Project includes
#include "lldb/Breakpoint/Watchpoint.h"
#include "lldb/Breakpoint/WatchpointList.h"
#include "lldb/Core/ValueObject.h"
#include "lldb/Core/ValueObjectVariable.h"
#include "lldb/Host/OptionParser.h"
#include "lldb/Interpreter/CommandCompletions.h"
#include "lldb/Interpreter/CommandInterpreter.h"
#include "lldb/Interpreter/CommandReturnObject.h"
#include "lldb/Symbol/Variable.h"
#include "lldb/Symbol/VariableList.h"
#include "lldb/Target/StackFrame.h"
#include "lldb/Target/Target.h"
#include "lldb/Utility/StreamString.h"

using namespace lldb;
using namespace lldb_private;

static void AddWatchpointDescription(Stream *s, Watchpoint *wp,
                                     lldb::DescriptionLevel level) {
  s->IndentMore();
  wp->GetDescription(s, level);
  s->IndentLess();
  s->EOL();
}

static bool CheckTargetForWatchpointOperations(Target *target,
                                               CommandReturnObject &result) {
  if (target == nullptr) {
    result.AppendError("Invalid target.  No existing target or watchpoints.");
    result.SetStatus(eReturnStatusFailed);
    return false;
  }
  bool process_is_valid =
      target->GetProcessSP() && target->GetProcessSP()->IsAlive();
  if (!process_is_valid) {
    result.AppendError("Thre's no process or it is not alive.");
    result.SetStatus(eReturnStatusFailed);
    return false;
  }
  // Target passes our checks, return true.
  return true;
}

// Equivalent class: {"-", "to", "To", "TO"} of range specifier array.
static const char *RSA[4] = {"-", "to", "To", "TO"};

// Return the index to RSA if found; otherwise -1 is returned.
static int32_t WithRSAIndex(llvm::StringRef Arg) {

  uint32_t i;
  for (i = 0; i < 4; ++i)
    if (Arg.find(RSA[i]) != llvm::StringRef::npos)
      return i;
  return -1;
}

// Return true if wp_ids is successfully populated with the watch ids. False
// otherwise.
bool CommandObjectMultiwordWatchpoint::VerifyWatchpointIDs(
    Target *target, Args &args, std::vector<uint32_t> &wp_ids) {
  // Pre-condition: args.GetArgumentCount() > 0.
  if (args.GetArgumentCount() == 0) {
    if (target == nullptr)
      return false;
    WatchpointSP watch_sp = target->GetLastCreatedWatchpoint();
    if (watch_sp) {
      wp_ids.push_back(watch_sp->GetID());
      return true;
    } else
      return false;
  }

  llvm::StringRef Minus("-");
  std::vector<llvm::StringRef> StrRefArgs;
  llvm::StringRef first;
  llvm::StringRef second;
  size_t i;
  int32_t idx;
  // Go through the arguments and make a canonical form of arg list containing
  // only numbers with possible "-" in between.
  for (auto &entry : args.entries()) {
    if ((idx = WithRSAIndex(entry.ref)) == -1) {
      StrRefArgs.push_back(entry.ref);
      continue;
    }
    // The Arg contains the range specifier, split it, then.
    std::tie(first, second) = entry.ref.split(RSA[idx]);
    if (!first.empty())
      StrRefArgs.push_back(first);
    StrRefArgs.push_back(Minus);
    if (!second.empty())
      StrRefArgs.push_back(second);
  }
  // Now process the canonical list and fill in the vector of uint32_t's. If
  // there is any error, return false and the client should ignore wp_ids.
  uint32_t beg, end, id;
  size_t size = StrRefArgs.size();
  bool in_range = false;
  for (i = 0; i < size; ++i) {
    llvm::StringRef Arg = StrRefArgs[i];
    if (in_range) {
      // Look for the 'end' of the range.  Note StringRef::getAsInteger()
      // returns true to signify error while parsing.
      if (Arg.getAsInteger(0, end))
        return false;
      // Found a range!  Now append the elements.
      for (id = beg; id <= end; ++id)
        wp_ids.push_back(id);
      in_range = false;
      continue;
    }
    if (i < (size - 1) && StrRefArgs[i + 1] == Minus) {
      if (Arg.getAsInteger(0, beg))
        return false;
      // Turn on the in_range flag, we are looking for end of range next.
      ++i;
      in_range = true;
      continue;
    }
    // Otherwise, we have a simple ID.  Just append it.
    if (Arg.getAsInteger(0, beg))
      return false;
    wp_ids.push_back(beg);
  }
  // It is an error if after the loop, we're still in_range.
  if (in_range)
    return false;

  return true; // Success!
}

//-------------------------------------------------------------------------
// CommandObjectWatchpointList
//-------------------------------------------------------------------------

//-------------------------------------------------------------------------
// CommandObjectWatchpointList::Options
//-------------------------------------------------------------------------
#pragma mark List::CommandOptions

static constexpr OptionDefinition g_watchpoint_list_options[] = {
    // clang-format off
  { LLDB_OPT_SET_1, false, "brief",   'b', OptionParser::eNoArgument, nullptr, {}, 0, eArgTypeNone, "Give a brief description of the watchpoint (no location info)." },
  { LLDB_OPT_SET_2, false, "full",    'f', OptionParser::eNoArgument, nullptr, {}, 0, eArgTypeNone, "Give a full description of the watchpoint and its locations." },
  { LLDB_OPT_SET_3, false, "verbose", 'v', OptionParser::eNoArgument, nullptr, {}, 0, eArgTypeNone, "Explain everything we know about the watchpoint (for debugging debugger bugs)." }
    // clang-format on
};

#pragma mark List

class CommandObjectWatchpointList : public CommandObjectParsed {
public:
  CommandObjectWatchpointList(CommandInterpreter &interpreter)
      : CommandObjectParsed(
            interpreter, "watchpoint list",
            "List all watchpoints at configurable levels of detail.", nullptr),
        m_options() {
    CommandArgumentEntry arg;
    CommandObject::AddIDsArgumentData(arg, eArgTypeWatchpointID,
                                      eArgTypeWatchpointIDRange);
    // Add the entry for the first argument for this command to the object's
    // arguments vector.
    m_arguments.push_back(arg);
  }

  ~CommandObjectWatchpointList() override = default;

  Options *GetOptions() override { return &m_options; }

  class CommandOptions : public Options {
  public:
    CommandOptions()
        : Options(),
          m_level(lldb::eDescriptionLevelBrief) // Watchpoint List defaults to
                                                // brief descriptions
    {}

    ~CommandOptions() override = default;

    Status SetOptionValue(uint32_t option_idx, llvm::StringRef option_arg,
                          ExecutionContext *execution_context) override {
      Status error;
      const int short_option = m_getopt_table[option_idx].val;

      switch (short_option) {
      case 'b':
        m_level = lldb::eDescriptionLevelBrief;
        break;
      case 'f':
        m_level = lldb::eDescriptionLevelFull;
        break;
      case 'v':
        m_level = lldb::eDescriptionLevelVerbose;
        break;
      default:
        error.SetErrorStringWithFormat("unrecognized option '%c'",
                                       short_option);
        break;
      }

      return error;
    }

    void OptionParsingStarting(ExecutionContext *execution_context) override {
      m_level = lldb::eDescriptionLevelFull;
    }

    llvm::ArrayRef<OptionDefinition> GetDefinitions() override {
      return llvm::makeArrayRef(g_watchpoint_list_options);
    }

    // Instance variables to hold the values for command options.

    lldb::DescriptionLevel m_level;
  };

protected:
  bool DoExecute(Args &command, CommandReturnObject &result) override {
    Target *target = m_interpreter.GetDebugger().GetSelectedTarget().get();
    if (target == nullptr) {
      result.AppendError("Invalid target. No current target or watchpoints.");
      result.SetStatus(eReturnStatusSuccessFinishNoResult);
      return true;
    }

    if (target->GetProcessSP() && target->GetProcessSP()->IsAlive()) {
      uint32_t num_supported_hardware_watchpoints;
      Status error = target->GetProcessSP()->GetWatchpointSupportInfo(
          num_supported_hardware_watchpoints);
      if (error.Success())
        result.AppendMessageWithFormat(
            "Number of supported hardware watchpoints: %u\n",
            num_supported_hardware_watchpoints);
    }

    const WatchpointList &watchpoints = target->GetWatchpointList();

    std::unique_lock<std::recursive_mutex> lock;
    target->GetWatchpointList().GetListMutex(lock);

    size_t num_watchpoints = watchpoints.GetSize();

    if (num_watchpoints == 0) {
      result.AppendMessage("No watchpoints currently set.");
      result.SetStatus(eReturnStatusSuccessFinishNoResult);
      return true;
    }

    Stream &output_stream = result.GetOutputStream();

    if (command.GetArgumentCount() == 0) {
      // No watchpoint selected; show info about all currently set watchpoints.
      result.AppendMessage("Current watchpoints:");
      for (size_t i = 0; i < num_watchpoints; ++i) {
        Watchpoint *wp = watchpoints.GetByIndex(i).get();
        AddWatchpointDescription(&output_stream, wp, m_options.m_level);
      }
      result.SetStatus(eReturnStatusSuccessFinishNoResult);
    } else {
      // Particular watchpoints selected; enable them.
      std::vector<uint32_t> wp_ids;
      if (!CommandObjectMultiwordWatchpoint::VerifyWatchpointIDs(
              target, command, wp_ids)) {
        result.AppendError("Invalid watchpoints specification.");
        result.SetStatus(eReturnStatusFailed);
        return false;
      }

      const size_t size = wp_ids.size();
      for (size_t i = 0; i < size; ++i) {
        Watchpoint *wp = watchpoints.FindByID(wp_ids[i]).get();
        if (wp)
          AddWatchpointDescription(&output_stream, wp, m_options.m_level);
        result.SetStatus(eReturnStatusSuccessFinishNoResult);
      }
    }

    return result.Succeeded();
  }

private:
  CommandOptions m_options;
};

//-------------------------------------------------------------------------
// CommandObjectWatchpointEnable
//-------------------------------------------------------------------------
#pragma mark Enable

class CommandObjectWatchpointEnable : public CommandObjectParsed {
public:
  CommandObjectWatchpointEnable(CommandInterpreter &interpreter)
      : CommandObjectParsed(interpreter, "enable",
                            "Enable the specified disabled watchpoint(s). If "
                            "no watchpoints are specified, enable all of them.",
                            nullptr) {
    CommandArgumentEntry arg;
    CommandObject::AddIDsArgumentData(arg, eArgTypeWatchpointID,
                                      eArgTypeWatchpointIDRange);
    // Add the entry for the first argument for this command to the object's
    // arguments vector.
    m_arguments.push_back(arg);
  }

  ~CommandObjectWatchpointEnable() override = default;

protected:
  bool DoExecute(Args &command, CommandReturnObject &result) override {
    Target *target = m_interpreter.GetDebugger().GetSelectedTarget().get();
    if (!CheckTargetForWatchpointOperations(target, result))
      return false;

    std::unique_lock<std::recursive_mutex> lock;
    target->GetWatchpointList().GetListMutex(lock);

    const WatchpointList &watchpoints = target->GetWatchpointList();

    size_t num_watchpoints = watchpoints.GetSize();

    if (num_watchpoints == 0) {
      result.AppendError("No watchpoints exist to be enabled.");
      result.SetStatus(eReturnStatusFailed);
      return false;
    }

    if (command.GetArgumentCount() == 0) {
      // No watchpoint selected; enable all currently set watchpoints.
      target->EnableAllWatchpoints();
      result.AppendMessageWithFormat("All watchpoints enabled. (%" PRIu64
                                     " watchpoints)\n",
                                     (uint64_t)num_watchpoints);
      result.SetStatus(eReturnStatusSuccessFinishNoResult);
    } else {
      // Particular watchpoints selected; enable them.
      std::vector<uint32_t> wp_ids;
      if (!CommandObjectMultiwordWatchpoint::VerifyWatchpointIDs(
              target, command, wp_ids)) {
        result.AppendError("Invalid watchpoints specification.");
        result.SetStatus(eReturnStatusFailed);
        return false;
      }

      int count = 0;
      const size_t size = wp_ids.size();
      for (size_t i = 0; i < size; ++i)
        if (target->EnableWatchpointByID(wp_ids[i]))
          ++count;
      result.AppendMessageWithFormat("%d watchpoints enabled.\n", count);
      result.SetStatus(eReturnStatusSuccessFinishNoResult);
    }

    return result.Succeeded();
  }
};

//-------------------------------------------------------------------------
// CommandObjectWatchpointDisable
//-------------------------------------------------------------------------
#pragma mark Disable

class CommandObjectWatchpointDisable : public CommandObjectParsed {
public:
  CommandObjectWatchpointDisable(CommandInterpreter &interpreter)
      : CommandObjectParsed(interpreter, "watchpoint disable",
                            "Disable the specified watchpoint(s) without "
                            "removing it/them.  If no watchpoints are "
                            "specified, disable them all.",
                            nullptr) {
    CommandArgumentEntry arg;
    CommandObject::AddIDsArgumentData(arg, eArgTypeWatchpointID,
                                      eArgTypeWatchpointIDRange);
    // Add the entry for the first argument for this command to the object's
    // arguments vector.
    m_arguments.push_back(arg);
  }

  ~CommandObjectWatchpointDisable() override = default;

protected:
  bool DoExecute(Args &command, CommandReturnObject &result) override {
    Target *target = m_interpreter.GetDebugger().GetSelectedTarget().get();
    if (!CheckTargetForWatchpointOperations(target, result))
      return false;

    std::unique_lock<std::recursive_mutex> lock;
    target->GetWatchpointList().GetListMutex(lock);

    const WatchpointList &watchpoints = target->GetWatchpointList();
    size_t num_watchpoints = watchpoints.GetSize();

    if (num_watchpoints == 0) {
      result.AppendError("No watchpoints exist to be disabled.");
      result.SetStatus(eReturnStatusFailed);
      return false;
    }

    if (command.GetArgumentCount() == 0) {
      // No watchpoint selected; disable all currently set watchpoints.
      if (target->DisableAllWatchpoints()) {
        result.AppendMessageWithFormat("All watchpoints disabled. (%" PRIu64
                                       " watchpoints)\n",
                                       (uint64_t)num_watchpoints);
        result.SetStatus(eReturnStatusSuccessFinishNoResult);
      } else {
        result.AppendError("Disable all watchpoints failed\n");
        result.SetStatus(eReturnStatusFailed);
      }
    } else {
      // Particular watchpoints selected; disable them.
      std::vector<uint32_t> wp_ids;
      if (!CommandObjectMultiwordWatchpoint::VerifyWatchpointIDs(
              target, command, wp_ids)) {
        result.AppendError("Invalid watchpoints specification.");
        result.SetStatus(eReturnStatusFailed);
        return false;
      }

      int count = 0;
      const size_t size = wp_ids.size();
      for (size_t i = 0; i < size; ++i)
        if (target->DisableWatchpointByID(wp_ids[i]))
          ++count;
      result.AppendMessageWithFormat("%d watchpoints disabled.\n", count);
      result.SetStatus(eReturnStatusSuccessFinishNoResult);
    }

    return result.Succeeded();
  }
};

//-------------------------------------------------------------------------
// CommandObjectWatchpointDelete
//-------------------------------------------------------------------------
#pragma mark Delete

class CommandObjectWatchpointDelete : public CommandObjectParsed {
public:
  CommandObjectWatchpointDelete(CommandInterpreter &interpreter)
      : CommandObjectParsed(interpreter, "watchpoint delete",
                            "Delete the specified watchpoint(s).  If no "
                            "watchpoints are specified, delete them all.",
                            nullptr) {
    CommandArgumentEntry arg;
    CommandObject::AddIDsArgumentData(arg, eArgTypeWatchpointID,
                                      eArgTypeWatchpointIDRange);
    // Add the entry for the first argument for this command to the object's
    // arguments vector.
    m_arguments.push_back(arg);
  }

  ~CommandObjectWatchpointDelete() override = default;

protected:
  bool DoExecute(Args &command, CommandReturnObject &result) override {
    Target *target = m_interpreter.GetDebugger().GetSelectedTarget().get();
    if (!CheckTargetForWatchpointOperations(target, result))
      return false;

    std::unique_lock<std::recursive_mutex> lock;
    target->GetWatchpointList().GetListMutex(lock);

    const WatchpointList &watchpoints = target->GetWatchpointList();

    size_t num_watchpoints = watchpoints.GetSize();

    if (num_watchpoints == 0) {
      result.AppendError("No watchpoints exist to be deleted.");
      result.SetStatus(eReturnStatusFailed);
      return false;
    }

    if (command.GetArgumentCount() == 0) {
      if (!m_interpreter.Confirm(
              "About to delete all watchpoints, do you want to do that?",
              true)) {
        result.AppendMessage("Operation cancelled...");
      } else {
        target->RemoveAllWatchpoints();
        result.AppendMessageWithFormat("All watchpoints removed. (%" PRIu64
                                       " watchpoints)\n",
                                       (uint64_t)num_watchpoints);
      }
      result.SetStatus(eReturnStatusSuccessFinishNoResult);
    } else {
      // Particular watchpoints selected; delete them.
      std::vector<uint32_t> wp_ids;
      if (!CommandObjectMultiwordWatchpoint::VerifyWatchpointIDs(
              target, command, wp_ids)) {
        result.AppendError("Invalid watchpoints specification.");
        result.SetStatus(eReturnStatusFailed);
        return false;
      }

      int count = 0;
      const size_t size = wp_ids.size();
      for (size_t i = 0; i < size; ++i)
        if (target->RemoveWatchpointByID(wp_ids[i]))
          ++count;
      result.AppendMessageWithFormat("%d watchpoints deleted.\n", count);
      result.SetStatus(eReturnStatusSuccessFinishNoResult);
    }

    return result.Succeeded();
  }
};

//-------------------------------------------------------------------------
// CommandObjectWatchpointIgnore
//-------------------------------------------------------------------------

#pragma mark Ignore::CommandOptions
static constexpr OptionDefinition g_watchpoint_ignore_options[] = {
    // clang-format off
  { LLDB_OPT_SET_ALL, true, "ignore-count", 'i', OptionParser::eRequiredArgument, nullptr, {}, 0, eArgTypeCount, "Set the number of times this watchpoint is skipped before stopping." }
    // clang-format on
};

class CommandObjectWatchpointIgnore : public CommandObjectParsed {
public:
  CommandObjectWatchpointIgnore(CommandInterpreter &interpreter)
      : CommandObjectParsed(interpreter, "watchpoint ignore",
                            "Set ignore count on the specified watchpoint(s).  "
                            "If no watchpoints are specified, set them all.",
                            nullptr),
        m_options() {
    CommandArgumentEntry arg;
    CommandObject::AddIDsArgumentData(arg, eArgTypeWatchpointID,
                                      eArgTypeWatchpointIDRange);
    // Add the entry for the first argument for this command to the object's
    // arguments vector.
    m_arguments.push_back(arg);
  }

  ~CommandObjectWatchpointIgnore() override = default;

  Options *GetOptions() override { return &m_options; }

  class CommandOptions : public Options {
  public:
    CommandOptions() : Options(), m_ignore_count(0) {}

    ~CommandOptions() override = default;

    Status SetOptionValue(uint32_t option_idx, llvm::StringRef option_arg,
                          ExecutionContext *execution_context) override {
      Status error;
      const int short_option = m_getopt_table[option_idx].val;

      switch (short_option) {
      case 'i':
        if (option_arg.getAsInteger(0, m_ignore_count))
          error.SetErrorStringWithFormat("invalid ignore count '%s'",
                                         option_arg.str().c_str());
        break;
      default:
        error.SetErrorStringWithFormat("unrecognized option '%c'",
                                       short_option);
        break;
      }

      return error;
    }

    void OptionParsingStarting(ExecutionContext *execution_context) override {
      m_ignore_count = 0;
    }

    llvm::ArrayRef<OptionDefinition> GetDefinitions() override {
      return llvm::makeArrayRef(g_watchpoint_ignore_options);
    }

    // Instance variables to hold the values for command options.

    uint32_t m_ignore_count;
  };

protected:
  bool DoExecute(Args &command, CommandReturnObject &result) override {
    Target *target = m_interpreter.GetDebugger().GetSelectedTarget().get();
    if (!CheckTargetForWatchpointOperations(target, result))
      return false;

    std::unique_lock<std::recursive_mutex> lock;
    target->GetWatchpointList().GetListMutex(lock);

    const WatchpointList &watchpoints = target->GetWatchpointList();

    size_t num_watchpoints = watchpoints.GetSize();

    if (num_watchpoints == 0) {
      result.AppendError("No watchpoints exist to be ignored.");
      result.SetStatus(eReturnStatusFailed);
      return false;
    }

    if (command.GetArgumentCount() == 0) {
      target->IgnoreAllWatchpoints(m_options.m_ignore_count);
      result.AppendMessageWithFormat("All watchpoints ignored. (%" PRIu64
                                     " watchpoints)\n",
                                     (uint64_t)num_watchpoints);
      result.SetStatus(eReturnStatusSuccessFinishNoResult);
    } else {
      // Particular watchpoints selected; ignore them.
      std::vector<uint32_t> wp_ids;
      if (!CommandObjectMultiwordWatchpoint::VerifyWatchpointIDs(
              target, command, wp_ids)) {
        result.AppendError("Invalid watchpoints specification.");
        result.SetStatus(eReturnStatusFailed);
        return false;
      }

      int count = 0;
      const size_t size = wp_ids.size();
      for (size_t i = 0; i < size; ++i)
        if (target->IgnoreWatchpointByID(wp_ids[i], m_options.m_ignore_count))
          ++count;
      result.AppendMessageWithFormat("%d watchpoints ignored.\n", count);
      result.SetStatus(eReturnStatusSuccessFinishNoResult);
    }

    return result.Succeeded();
  }

private:
  CommandOptions m_options;
};

//-------------------------------------------------------------------------
// CommandObjectWatchpointModify
//-------------------------------------------------------------------------

#pragma mark Modify::CommandOptions

static constexpr OptionDefinition g_watchpoint_modify_options[] = {
    // clang-format off
  { LLDB_OPT_SET_ALL, false, "condition", 'c', OptionParser::eRequiredArgument, nullptr, {}, 0, eArgTypeExpression, "The watchpoint stops only if this condition expression evaluates to true." }
    // clang-format on
};

#pragma mark Modify

class CommandObjectWatchpointModify : public CommandObjectParsed {
public:
  CommandObjectWatchpointModify(CommandInterpreter &interpreter)
      : CommandObjectParsed(
            interpreter, "watchpoint modify",
            "Modify the options on a watchpoint or set of watchpoints in the "
            "executable.  "
            "If no watchpoint is specified, act on the last created "
            "watchpoint.  "
            "Passing an empty argument clears the modification.",
            nullptr),
        m_options() {
    CommandArgumentEntry arg;
    CommandObject::AddIDsArgumentData(arg, eArgTypeWatchpointID,
                                      eArgTypeWatchpointIDRange);
    // Add the entry for the first argument for this command to the object's
    // arguments vector.
    m_arguments.push_back(arg);
  }

  ~CommandObjectWatchpointModify() override = default;

  Options *GetOptions() override { return &m_options; }

  class CommandOptions : public Options {
  public:
    CommandOptions() : Options(), m_condition(), m_condition_passed(false) {}

    ~CommandOptions() override = default;

    Status SetOptionValue(uint32_t option_idx, llvm::StringRef option_arg,
                          ExecutionContext *execution_context) override {
      Status error;
      const int short_option = m_getopt_table[option_idx].val;

      switch (short_option) {
      case 'c':
        m_condition = option_arg;
        m_condition_passed = true;
        break;
      default:
        error.SetErrorStringWithFormat("unrecognized option '%c'",
                                       short_option);
        break;
      }

      return error;
    }

    void OptionParsingStarting(ExecutionContext *execution_context) override {
      m_condition.clear();
      m_condition_passed = false;
    }

    llvm::ArrayRef<OptionDefinition> GetDefinitions() override {
      return llvm::makeArrayRef(g_watchpoint_modify_options);
    }

    // Instance variables to hold the values for command options.

    std::string m_condition;
    bool m_condition_passed;
  };

protected:
  bool DoExecute(Args &command, CommandReturnObject &result) override {
    Target *target = m_interpreter.GetDebugger().GetSelectedTarget().get();
    if (!CheckTargetForWatchpointOperations(target, result))
      return false;

    std::unique_lock<std::recursive_mutex> lock;
    target->GetWatchpointList().GetListMutex(lock);

    const WatchpointList &watchpoints = target->GetWatchpointList();

    size_t num_watchpoints = watchpoints.GetSize();

    if (num_watchpoints == 0) {
      result.AppendError("No watchpoints exist to be modified.");
      result.SetStatus(eReturnStatusFailed);
      return false;
    }

    if (command.GetArgumentCount() == 0) {
      WatchpointSP wp_sp = target->GetLastCreatedWatchpoint();
      wp_sp->SetCondition(m_options.m_condition.c_str());
      result.SetStatus(eReturnStatusSuccessFinishNoResult);
    } else {
      // Particular watchpoints selected; set condition on them.
      std::vector<uint32_t> wp_ids;
      if (!CommandObjectMultiwordWatchpoint::VerifyWatchpointIDs(
              target, command, wp_ids)) {
        result.AppendError("Invalid watchpoints specification.");
        result.SetStatus(eReturnStatusFailed);
        return false;
      }

      int count = 0;
      const size_t size = wp_ids.size();
      for (size_t i = 0; i < size; ++i) {
        WatchpointSP wp_sp = watchpoints.FindByID(wp_ids[i]);
        if (wp_sp) {
          wp_sp->SetCondition(m_options.m_condition.c_str());
          ++count;
        }
      }
      result.AppendMessageWithFormat("%d watchpoints modified.\n", count);
      result.SetStatus(eReturnStatusSuccessFinishNoResult);
    }

    return result.Succeeded();
  }

private:
  CommandOptions m_options;
};

//-------------------------------------------------------------------------
// CommandObjectWatchpointSetVariable
//-------------------------------------------------------------------------
#pragma mark SetVariable

class CommandObjectWatchpointSetVariable : public CommandObjectParsed {
public:
  CommandObjectWatchpointSetVariable(CommandInterpreter &interpreter)
      : CommandObjectParsed(
            interpreter, "watchpoint set variable",
            "Set a watchpoint on a variable. "
            "Use the '-w' option to specify the type of watchpoint and "
            "the '-s' option to specify the byte size to watch for. "
            "If no '-w' option is specified, it defaults to write. "
            "If no '-s' option is specified, it defaults to the variable's "
            "byte size. "
            "Note that there are limited hardware resources for watchpoints. "
            "If watchpoint setting fails, consider disable/delete existing "
            "ones "
            "to free up resources.",
            nullptr,
            eCommandRequiresFrame | eCommandTryTargetAPILock |
                eCommandProcessMustBeLaunched | eCommandProcessMustBePaused),
        m_option_group(), m_option_watchpoint() {
    SetHelpLong(
        R"(
Examples:

(lldb) watchpoint set variable -w read_write my_global_var

)"
        "    Watches my_global_var for read/write access, with the region to watch \
corresponding to the byte size of the data type.");

    CommandArgumentEntry arg;
    CommandArgumentData var_name_arg;

    // Define the only variant of this arg.
    var_name_arg.arg_type = eArgTypeVarName;
    var_name_arg.arg_repetition = eArgRepeatPlain;

    // Push the variant into the argument entry.
    arg.push_back(var_name_arg);

    // Push the data for the only argument into the m_arguments vector.
    m_arguments.push_back(arg);

    // Absorb the '-w' and '-s' options into our option group.
    m_option_group.Append(&m_option_watchpoint, LLDB_OPT_SET_ALL,
                          LLDB_OPT_SET_1);
    m_option_group.Finalize();
  }

  ~CommandObjectWatchpointSetVariable() override = default;

  Options *GetOptions() override { return &m_option_group; }

protected:
  static size_t GetVariableCallback(void *baton, const char *name,
                                    VariableList &variable_list) {
    Target *target = static_cast<Target *>(baton);
    if (target) {
      return target->GetImages().FindGlobalVariables(ConstString(name),
                                                     UINT32_MAX, variable_list);
    }
    return 0;
  }

  bool DoExecute(Args &command, CommandReturnObject &result) override {
    Target *target = m_interpreter.GetDebugger().GetSelectedTarget().get();
    StackFrame *frame = m_exe_ctx.GetFramePtr();

    // If no argument is present, issue an error message.  There's no way to
    // set a watchpoint.
    if (command.GetArgumentCount() <= 0) {
      result.GetErrorStream().Printf("error: required argument missing; "
                                     "specify your program variable to watch "
                                     "for\n");
      result.SetStatus(eReturnStatusFailed);
      return false;
    }

    // If no '-w' is specified, default to '-w write'.
    if (!m_option_watchpoint.watch_type_specified) {
      m_option_watchpoint.watch_type = OptionGroupWatchpoint::eWatchWrite;
    }

    // We passed the sanity check for the command. Proceed to set the
    // watchpoint now.
    lldb::addr_t addr = 0;
    size_t size = 0;

    VariableSP var_sp;
    ValueObjectSP valobj_sp;
    Stream &output_stream = result.GetOutputStream();

    // A simple watch variable gesture allows only one argument.
    if (command.GetArgumentCount() != 1) {
      result.GetErrorStream().Printf(
          "error: specify exactly one variable to watch for\n");
      result.SetStatus(eReturnStatusFailed);
      return false;
    }

    // Things have checked out ok...
    Status error;
    uint32_t expr_path_options =
        StackFrame::eExpressionPathOptionCheckPtrVsMember |
        StackFrame::eExpressionPathOptionsAllowDirectIVarAccess;
    valobj_sp = frame->GetValueForVariableExpressionPath(
        command.GetArgumentAtIndex(0), eNoDynamicValues, expr_path_options,
        var_sp, error);

    if (!valobj_sp) {
      // Not in the frame; let's check the globals.

      VariableList variable_list;
      ValueObjectList valobj_list;

      Status error(Variable::GetValuesForVariableExpressionPath(
          command.GetArgumentAtIndex(0),
          m_exe_ctx.GetBestExecutionContextScope(), GetVariableCallback, target,
          variable_list, valobj_list));

      if (valobj_list.GetSize())
        valobj_sp = valobj_list.GetValueObjectAtIndex(0);
    }

    CompilerType compiler_type;

    if (valobj_sp) {
      AddressType addr_type;
      addr = valobj_sp->GetAddressOf(false, &addr_type);
      if (addr_type == eAddressTypeLoad) {
        // We're in business.
        // Find out the size of this variable.
        size = m_option_watchpoint.watch_size == 0
                   ? valobj_sp->GetByteSize()
                   : m_option_watchpoint.watch_size;
      }
      compiler_type = valobj_sp->GetCompilerType();
    } else {
      const char *error_cstr = error.AsCString(nullptr);
      if (error_cstr)
        result.GetErrorStream().Printf("error: %s\n", error_cstr);
      else
        result.GetErrorStream().Printf("error: unable to find any variable "
                                       "expression path that matches '%s'\n",
                                       command.GetArgumentAtIndex(0));
      return false;
    }

    // Now it's time to create the watchpoint.
    uint32_t watch_type = m_option_watchpoint.watch_type;

    error.Clear();
    Watchpoint *wp =
        target->CreateWatchpoint(addr, size, &compiler_type, watch_type, error)
            .get();
    if (wp) {
      wp->SetWatchSpec(command.GetArgumentAtIndex(0));
      wp->SetWatchVariable(true);
      if (var_sp && var_sp->GetDeclaration().GetFile()) {
        StreamString ss;
        // True to show fullpath for declaration file.
        var_sp->GetDeclaration().DumpStopContext(&ss, true);
        wp->SetDeclInfo(ss.GetString());
      }
      output_stream.Printf("Watchpoint created: ");
      wp->GetDescription(&output_stream, lldb::eDescriptionLevelFull);
      output_stream.EOL();
      result.SetStatus(eReturnStatusSuccessFinishResult);
    } else {
      result.AppendErrorWithFormat(
          "Watchpoint creation failed (addr=0x%" PRIx64 ", size=%" PRIu64
          ", variable expression='%s').\n",
          addr, (uint64_t)size, command.GetArgumentAtIndex(0));
      if (error.AsCString(nullptr))
        result.AppendError(error.AsCString());
      result.SetStatus(eReturnStatusFailed);
    }

    return result.Succeeded();
  }

private:
  OptionGroupOptions m_option_group;
  OptionGroupWatchpoint m_option_watchpoint;
};

//-------------------------------------------------------------------------
// CommandObjectWatchpointSetExpression
//-------------------------------------------------------------------------
#pragma mark Set

class CommandObjectWatchpointSetExpression : public CommandObjectRaw {
public:
  CommandObjectWatchpointSetExpression(CommandInterpreter &interpreter)
      : CommandObjectRaw(
            interpreter, "watchpoint set expression",
            "Set a watchpoint on an address by supplying an expression. "
            "Use the '-w' option to specify the type of watchpoint and "
            "the '-s' option to specify the byte size to watch for. "
            "If no '-w' option is specified, it defaults to write. "
            "If no '-s' option is specified, it defaults to the target's "
            "pointer byte size. "
            "Note that there are limited hardware resources for watchpoints. "
            "If watchpoint setting fails, consider disable/delete existing "
            "ones "
            "to free up resources.",
            "",
            eCommandRequiresFrame | eCommandTryTargetAPILock |
                eCommandProcessMustBeLaunched | eCommandProcessMustBePaused),
        m_option_group(), m_option_watchpoint() {
    SetHelpLong(
        R"(
Examples:

(lldb) watchpoint set expression -w write -s 1 -- foo + 32

    Watches write access for the 1-byte region pointed to by the address 'foo + 32')");

    CommandArgumentEntry arg;
    CommandArgumentData expression_arg;

    // Define the only variant of this arg.
    expression_arg.arg_type = eArgTypeExpression;
    expression_arg.arg_repetition = eArgRepeatPlain;

    // Push the only variant into the argument entry.
    arg.push_back(expression_arg);

    // Push the data for the only argument into the m_arguments vector.
    m_arguments.push_back(arg);

    // Absorb the '-w' and '-s' options into our option group.
    m_option_group.Append(&m_option_watchpoint, LLDB_OPT_SET_ALL,
                          LLDB_OPT_SET_1);
    m_option_group.Finalize();
  }

  ~CommandObjectWatchpointSetExpression() override = default;

  // Overrides base class's behavior where WantsCompletion =
  // !WantsRawCommandString.
  bool WantsCompletion() override { return true; }

  Options *GetOptions() override { return &m_option_group; }

protected:
  bool DoExecute(llvm::StringRef raw_command,
                 CommandReturnObject &result) override {
    auto exe_ctx = GetCommandInterpreter().GetExecutionContext();
    m_option_group.NotifyOptionParsingStarting(
        &exe_ctx); // This is a raw command, so notify the option group

    Target *target = m_interpreter.GetDebugger().GetSelectedTarget().get();
    StackFrame *frame = m_exe_ctx.GetFramePtr();

    OptionsWithRaw args(raw_command);

    llvm::StringRef expr = args.GetRawPart();

    if (args.HasArgs())
      if (!ParseOptionsAndNotify(args.GetArgs(), result, m_option_group,
                                 exe_ctx))
        return false;

    // If no argument is present, issue an error message.  There's no way to
    // set a watchpoint.
    if (raw_command.trim().empty()) {
      result.GetErrorStream().Printf("error: required argument missing; "
                                     "specify an expression to evaulate into "
                                     "the address to watch for\n");
      result.SetStatus(eReturnStatusFailed);
      return false;
    }

    // If no '-w' is specified, default to '-w write'.
    if (!m_option_watchpoint.watch_type_specified) {
      m_option_watchpoint.watch_type = OptionGroupWatchpoint::eWatchWrite;
    }

    // We passed the sanity check for the command. Proceed to set the
    // watchpoint now.
    lldb::addr_t addr = 0;
    size_t size = 0;

    ValueObjectSP valobj_sp;

    // Use expression evaluation to arrive at the address to watch.
    EvaluateExpressionOptions options;
    options.SetCoerceToId(false);
    options.SetUnwindOnError(true);
    options.SetKeepInMemory(false);
    options.SetTryAllThreads(true);
    options.SetTimeout(llvm::None);

    ExpressionResults expr_result =
        target->EvaluateExpression(expr, frame, valobj_sp, options);
    if (expr_result != eExpressionCompleted) {
      result.GetErrorStream().Printf(
          "error: expression evaluation of address to watch failed\n");
      result.GetErrorStream() << "expression evaluated: \n" << expr << "\n";
      result.SetStatus(eReturnStatusFailed);
      return false;
    }

    // Get the address to watch.
    bool success = false;
    addr = valobj_sp->GetValueAsUnsigned(0, &success);
    if (!success) {
      result.GetErrorStream().Printf(
          "error: expression did not evaluate to an address\n");
      result.SetStatus(eReturnStatusFailed);
      return false;
    }

    if (m_option_watchpoint.watch_size != 0)
      size = m_option_watchpoint.watch_size;
    else
      size = target->GetArchitecture().GetAddressByteSize();

    // Now it's time to create the watchpoint.
    uint32_t watch_type = m_option_watchpoint.watch_type;

    // Fetch the type from the value object, the type of the watched object is
    // the pointee type
    /// of the expression, so convert to that if we  found a valid type.
    CompilerType compiler_type(valobj_sp->GetCompilerType());

    Status error;
    Watchpoint *wp =
        target->CreateWatchpoint(addr, size, &compiler_type, watch_type, error)
            .get();
    if (wp) {
      Stream &output_stream = result.GetOutputStream();
      output_stream.Printf("Watchpoint created: ");
      wp->GetDescription(&output_stream, lldb::eDescriptionLevelFull);
      output_stream.EOL();
      result.SetStatus(eReturnStatusSuccessFinishResult);
    } else {
      result.AppendErrorWithFormat("Watchpoint creation failed (addr=0x%" PRIx64
                                   ", size=%" PRIu64 ").\n",
                                   addr, (uint64_t)size);
      if (error.AsCString(nullptr))
        result.AppendError(error.AsCString());
      result.SetStatus(eReturnStatusFailed);
    }

    return result.Succeeded();
  }

private:
  OptionGroupOptions m_option_group;
  OptionGroupWatchpoint m_option_watchpoint;
};

//-------------------------------------------------------------------------
// CommandObjectWatchpointSet
//-------------------------------------------------------------------------
#pragma mark Set

class CommandObjectWatchpointSet : public CommandObjectMultiword {
public:
  CommandObjectWatchpointSet(CommandInterpreter &interpreter)
      : CommandObjectMultiword(
            interpreter, "watchpoint set", "Commands for setting a watchpoint.",
            "watchpoint set <subcommand> [<subcommand-options>]") {

    LoadSubCommand(
        "variable",
        CommandObjectSP(new CommandObjectWatchpointSetVariable(interpreter)));
    LoadSubCommand(
        "expression",
        CommandObjectSP(new CommandObjectWatchpointSetExpression(interpreter)));
  }

  ~CommandObjectWatchpointSet() override = default;
};

//-------------------------------------------------------------------------
// CommandObjectMultiwordWatchpoint
//-------------------------------------------------------------------------
#pragma mark MultiwordWatchpoint

CommandObjectMultiwordWatchpoint::CommandObjectMultiwordWatchpoint(
    CommandInterpreter &interpreter)
    : CommandObjectMultiword(interpreter, "watchpoint",
                             "Commands for operating on watchpoints.",
                             "watchpoint <subcommand> [<command-options>]") {
  CommandObjectSP list_command_object(
      new CommandObjectWatchpointList(interpreter));
  CommandObjectSP enable_command_object(
      new CommandObjectWatchpointEnable(interpreter));
  CommandObjectSP disable_command_object(
      new CommandObjectWatchpointDisable(interpreter));
  CommandObjectSP delete_command_object(
      new CommandObjectWatchpointDelete(interpreter));
  CommandObjectSP ignore_command_object(
      new CommandObjectWatchpointIgnore(interpreter));
  CommandObjectSP command_command_object(
      new CommandObjectWatchpointCommand(interpreter));
  CommandObjectSP modify_command_object(
      new CommandObjectWatchpointModify(interpreter));
  CommandObjectSP set_command_object(
      new CommandObjectWatchpointSet(interpreter));

  list_command_object->SetCommandName("watchpoint list");
  enable_command_object->SetCommandName("watchpoint enable");
  disable_command_object->SetCommandName("watchpoint disable");
  delete_command_object->SetCommandName("watchpoint delete");
  ignore_command_object->SetCommandName("watchpoint ignore");
  command_command_object->SetCommandName("watchpoint command");
  modify_command_object->SetCommandName("watchpoint modify");
  set_command_object->SetCommandName("watchpoint set");

  LoadSubCommand("list", list_command_object);
  LoadSubCommand("enable", enable_command_object);
  LoadSubCommand("disable", disable_command_object);
  LoadSubCommand("delete", delete_command_object);
  LoadSubCommand("ignore", ignore_command_object);
  LoadSubCommand("command", command_command_object);
  LoadSubCommand("modify", modify_command_object);
  LoadSubCommand("set", set_command_object);
}

CommandObjectMultiwordWatchpoint::~CommandObjectMultiwordWatchpoint() = default;
