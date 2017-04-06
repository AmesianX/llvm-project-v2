//===-- Connection.cpp ------------------------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "lldb/Core/Connection.h"

#if defined(_WIN32)
#include "lldb/Host/windows/ConnectionGenericFileWindows.h"
#endif

#include "lldb/Host/ConnectionFileDescriptor.h"

#include <string.h> // for strstr

using namespace lldb_private;

Connection::Connection() {}

Connection::~Connection() {}

Connection *Connection::CreateDefaultConnection(const char *url) {
#if defined(_WIN32)
  if (strstr(url, "file://") == url)
    return new ConnectionGenericFile();
#endif
  return new ConnectionFileDescriptor();
}
