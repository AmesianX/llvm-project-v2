//===-- UnwindTable.cpp -----------------------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "lldb/Symbol/UnwindTable.h"

#include <stdio.h>

#include "lldb/Core/Module.h"
#include "lldb/Core/Section.h"
#include "lldb/Symbol/ArmUnwindInfo.h"
#include "lldb/Symbol/CompactUnwindInfo.h"
#include "lldb/Symbol/DWARFCallFrameInfo.h"
#include "lldb/Symbol/FuncUnwinders.h"
#include "lldb/Symbol/ObjectFile.h"
#include "lldb/Symbol/SymbolContext.h"

// There is one UnwindTable object per ObjectFile.
// It contains a list of Unwind objects -- one per function, populated lazily --
// for the ObjectFile.
// Each Unwind object has multiple UnwindPlans for different scenarios.

using namespace lldb;
using namespace lldb_private;

UnwindTable::UnwindTable(ObjectFile &objfile)
    : m_object_file(objfile), m_unwinds(), m_initialized(false), m_mutex(),
      m_eh_frame_up(), m_compact_unwind_up(), m_arm_unwind_up() {}

// We can't do some of this initialization when the ObjectFile is running its
// ctor; delay doing it
// until needed for something.

void UnwindTable::Initialize() {
  if (m_initialized)
    return;

  std::lock_guard<std::mutex> guard(m_mutex);

  if (m_initialized) // check again once we've acquired the lock
    return;

  SectionList *sl = m_object_file.GetSectionList();
  if (sl) {
    SectionSP sect = sl->FindSectionByType(eSectionTypeEHFrame, true);
    if (sect.get()) {
      m_eh_frame_up.reset(new DWARFCallFrameInfo(m_object_file, sect,
                                                 eRegisterKindEHFrame, true));
    }
    sect = sl->FindSectionByType(eSectionTypeCompactUnwind, true);
    if (sect.get()) {
      m_compact_unwind_up.reset(new CompactUnwindInfo(m_object_file, sect));
    }
    sect = sl->FindSectionByType(eSectionTypeARMexidx, true);
    if (sect.get()) {
      SectionSP sect_extab = sl->FindSectionByType(eSectionTypeARMextab, true);
      if (sect_extab.get()) {
        m_arm_unwind_up.reset(
            new ArmUnwindInfo(m_object_file, sect, sect_extab));
      }
    }
  }

  m_initialized = true;
}

UnwindTable::~UnwindTable() {}

FuncUnwindersSP
UnwindTable::GetFuncUnwindersContainingAddress(const Address &addr,
                                               SymbolContext &sc) {
  FuncUnwindersSP no_unwind_found;

  Initialize();

  std::lock_guard<std::mutex> guard(m_mutex);

  // There is an UnwindTable per object file, so we can safely use file handles
  addr_t file_addr = addr.GetFileAddress();
  iterator end = m_unwinds.end();
  iterator insert_pos = end;
  if (!m_unwinds.empty()) {
    insert_pos = m_unwinds.lower_bound(file_addr);
    iterator pos = insert_pos;
    if ((pos == m_unwinds.end()) ||
        (pos != m_unwinds.begin() &&
         pos->second->GetFunctionStartAddress() != addr))
      --pos;

    if (pos->second->ContainsAddress(addr))
      return pos->second;
  }

  AddressRange range;
  if (!sc.GetAddressRange(eSymbolContextFunction | eSymbolContextSymbol, 0,
                          false, range) ||
      !range.GetBaseAddress().IsValid()) {
    // Does the eh_frame unwind info has a function bounds for this addr?
    if (m_eh_frame_up == nullptr ||
        !m_eh_frame_up->GetAddressRange(addr, range)) {
      return no_unwind_found;
    }
  }

  FuncUnwindersSP func_unwinder_sp(new FuncUnwinders(*this, range));
  m_unwinds.insert(insert_pos,
                   std::make_pair(range.GetBaseAddress().GetFileAddress(),
                                  func_unwinder_sp));
  //    StreamFile s(stdout, false);
  //    Dump (s);
  return func_unwinder_sp;
}

// Ignore any existing FuncUnwinders for this function, create a new one and
// don't add it to the
// UnwindTable.  This is intended for use by target modules show-unwind where we
// want to create
// new UnwindPlans, not re-use existing ones.

FuncUnwindersSP
UnwindTable::GetUncachedFuncUnwindersContainingAddress(const Address &addr,
                                                       SymbolContext &sc) {
  FuncUnwindersSP no_unwind_found;
  Initialize();

  AddressRange range;
  if (!sc.GetAddressRange(eSymbolContextFunction | eSymbolContextSymbol, 0,
                          false, range) ||
      !range.GetBaseAddress().IsValid()) {
    // Does the eh_frame unwind info has a function bounds for this addr?
    if (m_eh_frame_up == nullptr ||
        !m_eh_frame_up->GetAddressRange(addr, range)) {
      return no_unwind_found;
    }
  }

  FuncUnwindersSP func_unwinder_sp(new FuncUnwinders(*this, range));
  return func_unwinder_sp;
}

void UnwindTable::Dump(Stream &s) {
  std::lock_guard<std::mutex> guard(m_mutex);
  s.Printf("UnwindTable for '%s':\n",
           m_object_file.GetFileSpec().GetPath().c_str());
  const_iterator begin = m_unwinds.begin();
  const_iterator end = m_unwinds.end();
  for (const_iterator pos = begin; pos != end; ++pos) {
    s.Printf("[%u] 0x%16.16" PRIx64 "\n", (unsigned)std::distance(begin, pos),
             pos->first);
  }
  s.EOL();
}

DWARFCallFrameInfo *UnwindTable::GetEHFrameInfo() {
  Initialize();
  return m_eh_frame_up.get();
}

CompactUnwindInfo *UnwindTable::GetCompactUnwindInfo() {
  Initialize();
  return m_compact_unwind_up.get();
}

ArmUnwindInfo *UnwindTable::GetArmUnwindInfo() {
  Initialize();
  return m_arm_unwind_up.get();
}

bool UnwindTable::GetArchitecture(lldb_private::ArchSpec &arch) {
  return m_object_file.GetArchitecture(arch);
}

bool UnwindTable::GetAllowAssemblyEmulationUnwindPlans() {
  return m_object_file.AllowAssemblyEmulationUnwindPlans();
}
