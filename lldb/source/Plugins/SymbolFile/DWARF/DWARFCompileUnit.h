//===-- DWARFCompileUnit.h --------------------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#ifndef SymbolFileDWARF_DWARFCompileUnit_h_
#define SymbolFileDWARF_DWARFCompileUnit_h_

#include "DWARFDIE.h"
#include "DWARFDebugInfoEntry.h"
#include "lldb/lldb-enumerations.h"

class NameToDIE;
class SymbolFileDWARF;
class SymbolFileDWARFDwo;

typedef std::shared_ptr<DWARFCompileUnit> DWARFCompileUnitSP;

enum DWARFProducer {
  eProducerInvalid = 0,
  eProducerClang,
  eProducerGCC,
  eProducerLLVMGCC,
  eProcucerOther
};

class DWARFCompileUnit {
public:
  static DWARFCompileUnitSP Extract(SymbolFileDWARF *dwarf2Data,
      lldb::offset_t *offset_ptr);
  ~DWARFCompileUnit();

  size_t ExtractDIEsIfNeeded(bool cu_die_only);
  DWARFDIE LookupAddress(const dw_addr_t address);
  size_t AppendDIEsWithTag(const dw_tag_t tag,
                           DWARFDIECollection &matching_dies,
                           uint32_t depth = UINT32_MAX) const;
  bool Verify(lldb_private::Stream *s) const;
  void Dump(lldb_private::Stream *s) const;
  // Offset of the initial length field.
  dw_offset_t GetOffset() const { return m_offset; }
  lldb::user_id_t GetID() const;
  // Size in bytes of the initial length + compile unit header.
  uint32_t Size() const { return m_is_dwarf64 ? 23 : 11; }
  bool ContainsDIEOffset(dw_offset_t die_offset) const {
    return die_offset >= GetFirstDIEOffset() &&
           die_offset < GetNextCompileUnitOffset();
  }
  dw_offset_t GetFirstDIEOffset() const { return m_offset + Size(); }
  dw_offset_t GetNextCompileUnitOffset() const {
    return m_offset + (m_is_dwarf64 ? 12 : 4) + m_length;
  }
  // Size of the CU data (without initial length and without header).
  size_t GetDebugInfoSize() const {
    return (m_is_dwarf64 ? 12 : 4) + m_length - Size();
  }
  // Size of the CU data incl. header but without initial length.
  uint32_t GetLength() const { return m_length; }
  uint16_t GetVersion() const { return m_version; }
  const DWARFAbbreviationDeclarationSet *GetAbbreviations() const {
    return m_abbrevs;
  }
  dw_offset_t GetAbbrevOffset() const;
  uint8_t GetAddressByteSize() const { return m_addr_size; }
  dw_addr_t GetBaseAddress() const { return m_base_addr; }
  dw_addr_t GetAddrBase() const { return m_addr_base; }
  dw_addr_t GetRangesBase() const { return m_ranges_base; }
  void SetAddrBase(dw_addr_t addr_base, dw_addr_t ranges_base, dw_offset_t base_obj_offset);
  void ClearDIEs(bool keep_compile_unit_die);
  void BuildAddressRangeTable(SymbolFileDWARF *dwarf2Data,
                              DWARFDebugAranges *debug_aranges);

  lldb::ByteOrder GetByteOrder() const;

  lldb_private::TypeSystem *GetTypeSystem();

  DWARFFormValue::FixedFormSizes GetFixedFormSizes();

  void SetBaseAddress(dw_addr_t base_addr) { m_base_addr = base_addr; }

  DWARFDIE
  GetCompileUnitDIEOnly() { return DWARFDIE(this, GetCompileUnitDIEPtrOnly()); }

  DWARFDIE
  DIE() { return DWARFDIE(this, DIEPtr()); }

  void AddDIE(DWARFDebugInfoEntry &die) {
    // The average bytes per DIE entry has been seen to be
    // around 14-20 so lets pre-reserve half of that since
    // we are now stripping the NULL tags.

    // Only reserve the memory if we are adding children of
    // the main compile unit DIE. The compile unit DIE is always
    // the first entry, so if our size is 1, then we are adding
    // the first compile unit child DIE and should reserve
    // the memory.
    if (m_die_array.empty())
      m_die_array.reserve(GetDebugInfoSize() / 24);
    m_die_array.push_back(die);
  }

  void AddCompileUnitDIE(DWARFDebugInfoEntry &die);

  bool HasDIEsParsed() const { return m_die_array.size() > 1; }

  DWARFDIE
  GetDIE(dw_offset_t die_offset);

  static uint8_t GetAddressByteSize(const DWARFCompileUnit *cu);

  static bool IsDWARF64(const DWARFCompileUnit *cu);

  static uint8_t GetDefaultAddressSize();

  static void SetDefaultAddressSize(uint8_t addr_size);

  void *GetUserData() const { return m_user_data; }

  void SetUserData(void *d);

  bool Supports_DW_AT_APPLE_objc_complete_type();

  bool DW_AT_decl_file_attributes_are_invalid();

  bool Supports_unnamed_objc_bitfields();

  void Index(NameToDIE &func_basenames, NameToDIE &func_fullnames,
             NameToDIE &func_methods, NameToDIE &func_selectors,
             NameToDIE &objc_class_selectors, NameToDIE &globals,
             NameToDIE &types, NameToDIE &namespaces);

  const DWARFDebugAranges &GetFunctionAranges();

  SymbolFileDWARF *GetSymbolFileDWARF() const { return m_dwarf2Data; }

  DWARFProducer GetProducer();

  uint32_t GetProducerVersionMajor();

  uint32_t GetProducerVersionMinor();

  uint32_t GetProducerVersionUpdate();

  static lldb::LanguageType LanguageTypeFromDWARF(uint64_t val);

  lldb::LanguageType GetLanguageType();

  bool IsDWARF64() const;

  bool GetIsOptimized();

  SymbolFileDWARFDwo *GetDwoSymbolFile() const {
    return m_dwo_symbol_file.get();
  }

  dw_offset_t GetBaseObjOffset() const { return m_base_obj_offset; }

protected:
  SymbolFileDWARF *m_dwarf2Data;
  std::unique_ptr<SymbolFileDWARFDwo> m_dwo_symbol_file;
  const DWARFAbbreviationDeclarationSet *m_abbrevs;
  void *m_user_data = nullptr;
  DWARFDebugInfoEntry::collection
      m_die_array; // The compile unit debug information entry item
  std::unique_ptr<DWARFDebugAranges> m_func_aranges_ap; // A table similar to
                                                        // the .debug_aranges
                                                        // table, but this one
                                                        // points to the exact
                                                        // DW_TAG_subprogram
                                                        // DIEs
  dw_addr_t m_base_addr = 0;
  // Offset of the initial length field.
  dw_offset_t m_offset;
  dw_offset_t m_length;
  uint16_t m_version;
  uint8_t m_addr_size;
  DWARFProducer m_producer = eProducerInvalid;
  uint32_t m_producer_version_major = 0;
  uint32_t m_producer_version_minor = 0;
  uint32_t m_producer_version_update = 0;
  lldb::LanguageType m_language_type = lldb::eLanguageTypeUnknown;
  bool m_is_dwarf64;
  lldb_private::LazyBool m_is_optimized = lldb_private::eLazyBoolCalculate;
  dw_addr_t m_addr_base = 0;     // Value of DW_AT_addr_base
  dw_addr_t m_ranges_base = 0;   // Value of DW_AT_ranges_base
  // If this is a dwo compile unit this is the offset of the base compile unit
  // in the main object file
  dw_offset_t m_base_obj_offset = DW_INVALID_OFFSET;

  void ParseProducerInfo();

  static void
  IndexPrivate(DWARFCompileUnit *dwarf_cu, const lldb::LanguageType cu_language,
               const DWARFFormValue::FixedFormSizes &fixed_form_sizes,
               const dw_offset_t cu_offset, NameToDIE &func_basenames,
               NameToDIE &func_fullnames, NameToDIE &func_methods,
               NameToDIE &func_selectors, NameToDIE &objc_class_selectors,
               NameToDIE &globals, NameToDIE &types, NameToDIE &namespaces);

private:
  DWARFCompileUnit(SymbolFileDWARF *dwarf2Data);

  const DWARFDebugInfoEntry *GetCompileUnitDIEPtrOnly() {
    ExtractDIEsIfNeeded(true);
    if (m_die_array.empty())
      return NULL;
    return &m_die_array[0];
  }

  const DWARFDebugInfoEntry *DIEPtr() {
    ExtractDIEsIfNeeded(false);
    if (m_die_array.empty())
      return NULL;
    return &m_die_array[0];
  }

  DISALLOW_COPY_AND_ASSIGN(DWARFCompileUnit);
};

#endif // SymbolFileDWARF_DWARFCompileUnit_h_
