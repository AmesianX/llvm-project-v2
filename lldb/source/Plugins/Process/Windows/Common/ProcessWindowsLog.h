//===-- ProcessWindowsLog.h -------------------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef liblldb_ProcessWindowsLog_h_
#define liblldb_ProcessWindowsLog_h_

#include "lldb/Core/Log.h"

#define WINDOWS_LOG_VERBOSE (1u << 0)
#define WINDOWS_LOG_PROCESS (1u << 1)     // Log process operations
#define WINDOWS_LOG_EXCEPTION (1u << 1)   // Log exceptions
#define WINDOWS_LOG_THREAD (1u << 2)      // Log thread operations
#define WINDOWS_LOG_MEMORY (1u << 3)      // Log memory reads/writes calls
#define WINDOWS_LOG_BREAKPOINTS (1u << 4) // Log breakpoint operations
#define WINDOWS_LOG_STEP (1u << 5)        // Log step operations
#define WINDOWS_LOG_REGISTERS (1u << 6)   // Log register operations
#define WINDOWS_LOG_EVENT (1u << 7)       // Low level debug events
#define WINDOWS_LOG_ALL (UINT32_MAX)

enum class LogMaskReq { All, Any };

class ProcessWindowsLog {
  static const char *m_pluginname;

public:
  // ---------------------------------------------------------------------
  // Public Static Methods
  // ---------------------------------------------------------------------
  static void Initialize();

  static void Terminate();

  static void RegisterPluginName(const char *pluginName) {
    m_pluginname = pluginName;
  }

  static void RegisterPluginName(lldb_private::ConstString pluginName) {
    m_pluginname = pluginName.GetCString();
  }

  static lldb_private::Log *GetLogIfAny(uint32_t mask);

  static void DisableLog(const char **args,
                         lldb_private::Stream *feedback_strm);

  static lldb_private::Log *
  EnableLog(const std::shared_ptr<llvm::raw_ostream> &log_stream_sp,
            uint32_t log_options, const char **args,
            lldb_private::Stream *feedback_strm);

  static void ListLogCategories(lldb_private::Stream *strm);
};

#endif // liblldb_ProcessWindowsLog_h_
