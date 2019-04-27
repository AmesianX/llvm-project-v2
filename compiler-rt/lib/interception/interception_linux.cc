//===-- interception_linux.cc -----------------------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file is a part of AddressSanitizer, an address sanity checker.
//
// Linux-specific interception methods.
//===----------------------------------------------------------------------===//

#include "interception.h"

#if SANITIZER_LINUX || SANITIZER_FREEBSD || SANITIZER_NETBSD || \
    SANITIZER_OPENBSD || SANITIZER_SOLARIS

#include <dlfcn.h>   // for dlsym() and dlvsym()

namespace __interception {

#if SANITIZER_NETBSD
static int StrCmp(const char *s1, const char *s2) {
  while (true) {
    if (*s1 != *s2)
      return false;
    if (*s1 == 0)
      return true;
    s1++;
    s2++;
  }
}
#endif

void *GetFuncAddr(const char *name) {
#if SANITIZER_NETBSD
  // FIXME: Find a better way to handle renames
  if (StrCmp(name, "sigaction"))
    name = "__sigaction14";
#endif
  void *addr = dlsym(RTLD_NEXT, name);
  if (!addr) {
    // If the lookup using RTLD_NEXT failed, the sanitizer runtime library is
    // later in the library search order than the DSO that we are trying to
    // intercept, which means that we cannot intercept this function. We still
    // want the address of the real definition, though, so look it up using
    // RTLD_DEFAULT.
    addr = dlsym(RTLD_DEFAULT, name);
  }
  return addr;
}

// Android and Solaris do not have dlvsym
#if !SANITIZER_ANDROID && !SANITIZER_SOLARIS && !SANITIZER_OPENBSD
void *GetFuncAddrVer(const char *name, const char *ver) {
  return dlvsym(RTLD_NEXT, name, ver);
}
#endif  // !SANITIZER_ANDROID

}  // namespace __interception

#endif  // SANITIZER_LINUX || SANITIZER_FREEBSD || SANITIZER_NETBSD ||
        // SANITIZER_OPENBSD || SANITIZER_SOLARIS
