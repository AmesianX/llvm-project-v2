//===- LLVMContextTest.cpp - LLVMContext unit tests -----------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/DebugInfoMetadata.h"
#include "gtest/gtest.h"
using namespace llvm;

namespace {

TEST(LLVMContextTest, enableDebugTypeODRUniquing) {
  LLVMContext Context;
  EXPECT_FALSE(Context.isODRUniquingDebugTypes());
  Context.enableDebugTypeODRUniquing();
  EXPECT_TRUE(Context.isODRUniquingDebugTypes());
  Context.disableDebugTypeODRUniquing();
  EXPECT_FALSE(Context.isODRUniquingDebugTypes());
}

TEST(LLVMContextTest, getOrInsertODRUniquedType) {
  LLVMContext Context;
  const MDString &S = *MDString::get(Context, "string");

  // Without a type map, this should return null.
  EXPECT_FALSE(Context.getOrInsertODRUniquedType(S));

  // Get the mapping.
  Context.enableDebugTypeODRUniquing();
  DIType **Mapping = Context.getOrInsertODRUniquedType(S);
  ASSERT_TRUE(Mapping);

  // Create some type and add it to the mapping.
  auto &BT =
      *DIBasicType::get(Context, dwarf::DW_TAG_unspecified_type, S.getString());
  *Mapping = &BT;

  // Check that we get it back.
  Mapping = Context.getOrInsertODRUniquedType(S);
  ASSERT_TRUE(Mapping);
  EXPECT_EQ(&BT, *Mapping);

  // Check that it's discarded with the type map.
  Context.disableDebugTypeODRUniquing();
  EXPECT_FALSE(Context.getOrInsertODRUniquedType(S));

  // And it shouldn't magically reappear...
  Context.enableDebugTypeODRUniquing();
  EXPECT_FALSE(*Context.getOrInsertODRUniquedType(S));
}

} // end namespace
