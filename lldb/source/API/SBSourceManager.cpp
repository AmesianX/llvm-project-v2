//===-- SBSourceManager.cpp -------------------------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "lldb/API/SBSourceManager.h"
#include "SBReproducerPrivate.h"
#include "lldb/API/SBDebugger.h"
#include "lldb/API/SBStream.h"
#include "lldb/API/SBTarget.h"

#include "lldb/API/SBFileSpec.h"
#include "lldb/Core/Debugger.h"
#include "lldb/Core/SourceManager.h"
#include "lldb/Core/StreamFile.h"
#include "lldb/Utility/Stream.h"

#include "lldb/Target/Target.h"

namespace lldb_private {
class SourceManagerImpl {
public:
  SourceManagerImpl(const lldb::DebuggerSP &debugger_sp)
      : m_debugger_wp(debugger_sp), m_target_wp() {}

  SourceManagerImpl(const lldb::TargetSP &target_sp)
      : m_debugger_wp(), m_target_wp(target_sp) {}

  SourceManagerImpl(const SourceManagerImpl &rhs) {
    if (&rhs == this)
      return;
    m_debugger_wp = rhs.m_debugger_wp;
    m_target_wp = rhs.m_target_wp;
  }

  size_t DisplaySourceLinesWithLineNumbers(const lldb_private::FileSpec &file,
                                           uint32_t line, uint32_t column,
                                           uint32_t context_before,
                                           uint32_t context_after,
                                           const char *current_line_cstr,
                                           lldb_private::Stream *s) {
    if (!file)
      return 0;

    lldb::TargetSP target_sp(m_target_wp.lock());
    if (target_sp) {
      return target_sp->GetSourceManager().DisplaySourceLinesWithLineNumbers(
          file, line, column, context_before, context_after, current_line_cstr,
          s);
    } else {
      lldb::DebuggerSP debugger_sp(m_debugger_wp.lock());
      if (debugger_sp) {
        return debugger_sp->GetSourceManager()
            .DisplaySourceLinesWithLineNumbers(file, line, column,
                                               context_before, context_after,
                                               current_line_cstr, s);
      }
    }
    return 0;
  }

private:
  lldb::DebuggerWP m_debugger_wp;
  lldb::TargetWP m_target_wp;
};
}

using namespace lldb;
using namespace lldb_private;

SBSourceManager::SBSourceManager(const SBDebugger &debugger) {
  LLDB_RECORD_CONSTRUCTOR(SBSourceManager, (const lldb::SBDebugger &),
                          debugger);

  m_opaque_up.reset(new SourceManagerImpl(debugger.get_sp()));
}

SBSourceManager::SBSourceManager(const SBTarget &target) {
  LLDB_RECORD_CONSTRUCTOR(SBSourceManager, (const lldb::SBTarget &), target);

  m_opaque_up.reset(new SourceManagerImpl(target.GetSP()));
}

SBSourceManager::SBSourceManager(const SBSourceManager &rhs) {
  LLDB_RECORD_CONSTRUCTOR(SBSourceManager, (const lldb::SBSourceManager &),
                          rhs);

  if (&rhs == this)
    return;

  m_opaque_up.reset(new SourceManagerImpl(*(rhs.m_opaque_up.get())));
}

const lldb::SBSourceManager &SBSourceManager::
operator=(const lldb::SBSourceManager &rhs) {
  LLDB_RECORD_METHOD(const lldb::SBSourceManager &,
                     SBSourceManager, operator=,(const lldb::SBSourceManager &),
                     rhs);

  m_opaque_up.reset(new SourceManagerImpl(*(rhs.m_opaque_up.get())));
  return *this;
}

SBSourceManager::~SBSourceManager() {}

size_t SBSourceManager::DisplaySourceLinesWithLineNumbers(
    const SBFileSpec &file, uint32_t line, uint32_t context_before,
    uint32_t context_after, const char *current_line_cstr, SBStream &s) {
  LLDB_RECORD_METHOD(size_t, SBSourceManager, DisplaySourceLinesWithLineNumbers,
                     (const lldb::SBFileSpec &, uint32_t, uint32_t, uint32_t,
                      const char *, lldb::SBStream &),
                     file, line, context_before, context_after,
                     current_line_cstr, s);

  const uint32_t column = 0;
  return DisplaySourceLinesWithLineNumbersAndColumn(
      file.ref(), line, column, context_before, context_after,
      current_line_cstr, s);
}

size_t SBSourceManager::DisplaySourceLinesWithLineNumbersAndColumn(
    const SBFileSpec &file, uint32_t line, uint32_t column,
    uint32_t context_before, uint32_t context_after,
    const char *current_line_cstr, SBStream &s) {
  LLDB_RECORD_METHOD(
      size_t, SBSourceManager, DisplaySourceLinesWithLineNumbersAndColumn,
      (const lldb::SBFileSpec &, uint32_t, uint32_t, uint32_t, uint32_t,
       const char *, lldb::SBStream &),
      file, line, column, context_before, context_after, current_line_cstr, s);

  if (m_opaque_up == NULL)
    return 0;

  return m_opaque_up->DisplaySourceLinesWithLineNumbers(
      file.ref(), line, column, context_before, context_after,
      current_line_cstr, s.get());
}
