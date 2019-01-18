//===-- BreakpadRecordsTest.cpp ---------------------------------*- C++ -*-===//
//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "Plugins/ObjectFile/Breakpad/BreakpadRecords.h"
#include "gtest/gtest.h"

using namespace lldb_private;
using namespace lldb_private::breakpad;

TEST(Record, classify) {
  EXPECT_EQ(Record::Module, Record::classify("MODULE"));
  EXPECT_EQ(Record::Info, Record::classify("INFO"));
  EXPECT_EQ(Record::File, Record::classify("FILE"));
  EXPECT_EQ(Record::Func, Record::classify("FUNC"));
  EXPECT_EQ(Record::Public, Record::classify("PUBLIC"));
  EXPECT_EQ(Record::Stack, Record::classify("STACK"));

  // Any line which does not start with a known keyword will be classified as a
  // line record, as those are the only ones that start without a keyword.
  EXPECT_EQ(Record::Line, Record::classify("deadbeef"));
  EXPECT_EQ(Record::Line, Record::classify("12"));
  EXPECT_EQ(Record::Line, Record::classify("CODE_ID"));
}

TEST(ModuleRecord, parse) {
  EXPECT_EQ(ModuleRecord(llvm::Triple::Linux, llvm::Triple::x86_64,
                         UUID::fromData("@ABCDEFGHIJKLMNO", 16)),
            ModuleRecord::parse(
                "MODULE Linux x86_64 434241404544474648494a4b4c4d4e4f0 a.out"));

  EXPECT_EQ(llvm::None, ModuleRecord::parse("MODULE"));
  EXPECT_EQ(llvm::None, ModuleRecord::parse("MODULE Linux"));
  EXPECT_EQ(llvm::None, ModuleRecord::parse("MODULE Linux x86_64"));
  EXPECT_EQ(llvm::None,
            ModuleRecord::parse("MODULE Linux x86_64 deadbeefbaadf00d"));
}

TEST(InfoRecord, parse) {
  EXPECT_EQ(InfoRecord(UUID::fromData("@ABCDEFGHIJKLMNO", 16)),
            InfoRecord::parse("INFO CODE_ID 404142434445464748494a4b4c4d4e4f"));
  EXPECT_EQ(InfoRecord(UUID()), InfoRecord::parse("INFO CODE_ID 47 a.exe"));

  EXPECT_EQ(llvm::None, InfoRecord::parse("INFO"));
  EXPECT_EQ(llvm::None, InfoRecord::parse("INFO CODE_ID"));
}

TEST(PublicRecord, parse) {
  EXPECT_EQ(PublicRecord(true, 0x47, 0x8, "foo"),
            PublicRecord::parse("PUBLIC m 47 8 foo"));
  EXPECT_EQ(PublicRecord(false, 0x47, 0x8, "foo"),
            PublicRecord::parse("PUBLIC 47 8 foo"));

  EXPECT_EQ(llvm::None, PublicRecord::parse("PUBLIC 47 8"));
  EXPECT_EQ(llvm::None, PublicRecord::parse("PUBLIC 47"));
  EXPECT_EQ(llvm::None, PublicRecord::parse("PUBLIC m"));
  EXPECT_EQ(llvm::None, PublicRecord::parse("PUBLIC"));
}
