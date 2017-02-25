//===--- DataBufferLLVM.cpp -------------------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "lldb/Core/DataBufferLLVM.h"

#include "lldb/Host/FileSpec.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/MemoryBuffer.h"

using namespace lldb_private;

DataBufferLLVM::DataBufferLLVM(std::unique_ptr<llvm::MemoryBuffer> MemBuffer)
    : Buffer(std::move(MemBuffer)) {
  assert(Buffer != nullptr &&
         "Cannot construct a DataBufferLLVM with a null buffer");
}

DataBufferLLVM::~DataBufferLLVM() {}

std::shared_ptr<DataBufferLLVM>
DataBufferLLVM::CreateFromPath(llvm::StringRef Path, uint64_t Size,
                               uint64_t Offset) {
  // If the file resides non-locally, pass the volatile flag so that we don't
  // mmap it.
  bool Volatile = !llvm::sys::fs::is_local(Path);

  auto Buffer = llvm::MemoryBuffer::getFileSlice(Path, Size, Offset, Volatile);
  if (!Buffer)
    return nullptr;
  return std::shared_ptr<DataBufferLLVM>(
      new DataBufferLLVM(std::move(*Buffer)));
}

std::shared_ptr<DataBufferLLVM>
DataBufferLLVM::CreateFromFileSpec(const FileSpec &F, uint64_t Size,
                                   uint64_t Offset) {
  return CreateFromPath(F.GetPath(), Size, Offset);
}

uint8_t *DataBufferLLVM::GetBytes() {
  return const_cast<uint8_t *>(GetBuffer());
}

const uint8_t *DataBufferLLVM::GetBytes() const { return GetBuffer(); }

lldb::offset_t DataBufferLLVM::GetByteSize() const {
  return Buffer->getBufferSize();
}

const uint8_t *DataBufferLLVM::GetBuffer() const {
  return reinterpret_cast<const uint8_t *>(Buffer->getBufferStart());
}
