//===- RemarkSerializer.cpp -----------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file provides tools for serializing remarks.
//
//===----------------------------------------------------------------------===//

#include "llvm/Remarks/RemarkSerializer.h"
#include "llvm/Remarks/YAMLRemarkSerializer.h"

using namespace llvm;
using namespace llvm::remarks;

Expected<std::unique_ptr<Serializer>>
remarks::createRemarkSerializer(Format RemarksFormat, raw_ostream &OS) {
  switch (RemarksFormat) {
  case Format::Unknown:
    return createStringError(std::errc::invalid_argument,
                             "Unknown remark serializer format.");
  case Format::YAML:
    return llvm::make_unique<YAMLSerializer>(OS);
  case Format::YAMLStrTab:
    return llvm::make_unique<YAMLStrTabSerializer>(OS);
  }
  llvm_unreachable("Unknown remarks::Format enum");
}

Expected<std::unique_ptr<Serializer>>
remarks::createRemarkSerializer(Format RemarksFormat, raw_ostream &OS,
                                remarks::StringTable StrTab) {
  switch (RemarksFormat) {
  case Format::Unknown:
    return createStringError(std::errc::invalid_argument,
                             "Unknown remark serializer format.");
  case Format::YAML:
    return createStringError(std::errc::invalid_argument,
                             "Unable to use a string table with the yaml "
                             "format. Use 'yaml-strtab' instead.");
  case Format::YAMLStrTab:
    return llvm::make_unique<YAMLStrTabSerializer>(OS, std::move(StrTab));
  }
  llvm_unreachable("Unknown remarks::Format enum");
}
