//===-- tsan_platform_linux.cc --------------------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file is a part of ThreadSanitizer (TSan), a race detector.
//
// Linux- and FreeBSD-specific code.
//===----------------------------------------------------------------------===//


#include "sanitizer_common/sanitizer_platform.h"
#if SANITIZER_LINUX || SANITIZER_FREEBSD

#include "sanitizer_common/sanitizer_common.h"
#include "sanitizer_common/sanitizer_libc.h"
#include "sanitizer_common/sanitizer_posix.h"
#include "sanitizer_common/sanitizer_procmaps.h"
#include "sanitizer_common/sanitizer_stoptheworld.h"
#include "sanitizer_common/sanitizer_stackdepot.h"
#include "tsan_platform.h"
#include "tsan_rtl.h"
#include "tsan_flags.h"

#include <fcntl.h>
#include <pthread.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <sys/mman.h>
#include <sys/syscall.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/resource.h>
#include <sys/stat.h>
#include <unistd.h>
#include <errno.h>
#include <sched.h>
#include <dlfcn.h>
#if SANITIZER_LINUX
#define __need_res_state
#include <resolv.h>
#endif

#ifdef sa_handler
# undef sa_handler
#endif

#ifdef sa_sigaction
# undef sa_sigaction
#endif

#if SANITIZER_FREEBSD
extern "C" void *__libc_stack_end;
void *__libc_stack_end = 0;
#endif

namespace __tsan {

static uptr g_data_start;
static uptr g_data_end;

#ifdef TSAN_RUNTIME_VMA
// Runtime detected VMA size.
uptr vmaSize;
#endif

enum {
  MemTotal  = 0,
  MemShadow = 1,
  MemMeta   = 2,
  MemFile   = 3,
  MemMmap   = 4,
  MemTrace  = 5,
  MemHeap   = 6,
  MemOther  = 7,
  MemCount  = 8,
};

void FillProfileCallback(uptr p, uptr rss, bool file,
                         uptr *mem, uptr stats_size) {
  mem[MemTotal] += rss;
  if (p >= ShadowBeg() && p < ShadowEnd())
    mem[MemShadow] += rss;
  else if (p >= MetaShadowBeg() && p < MetaShadowEnd())
    mem[MemMeta] += rss;
#ifndef SANITIZER_GO
  else if (p >= HeapMemBeg() && p < HeapMemEnd())
    mem[MemHeap] += rss;
  else if (p >= LoAppMemBeg() && p < LoAppMemEnd())
    mem[file ? MemFile : MemMmap] += rss;
  else if (p >= HiAppMemBeg() && p < HiAppMemEnd())
    mem[file ? MemFile : MemMmap] += rss;
#else
  else if (p >= AppMemBeg() && p < AppMemEnd())
    mem[file ? MemFile : MemMmap] += rss;
#endif
  else if (p >= TraceMemBeg() && p < TraceMemEnd())
    mem[MemTrace] += rss;
  else
    mem[MemOther] += rss;
}

void WriteMemoryProfile(char *buf, uptr buf_size, uptr nthread, uptr nlive) {
  uptr mem[MemCount];
  internal_memset(mem, 0, sizeof(mem[0]) * MemCount);
  __sanitizer::GetMemoryProfile(FillProfileCallback, mem, 7);
  StackDepotStats *stacks = StackDepotGetStats();
  internal_snprintf(buf, buf_size,
      "RSS %zd MB: shadow:%zd meta:%zd file:%zd mmap:%zd"
      " trace:%zd heap:%zd other:%zd stacks=%zd[%zd] nthr=%zd/%zd\n",
      mem[MemTotal] >> 20, mem[MemShadow] >> 20, mem[MemMeta] >> 20,
      mem[MemFile] >> 20, mem[MemMmap] >> 20, mem[MemTrace] >> 20,
      mem[MemHeap] >> 20, mem[MemOther] >> 20,
      stacks->allocated >> 20, stacks->n_uniq_ids,
      nlive, nthread);
}

#if SANITIZER_LINUX
void FlushShadowMemoryCallback(
    const SuspendedThreadsList &suspended_threads_list,
    void *argument) {
  FlushUnneededShadowMemory(ShadowBeg(), ShadowEnd() - ShadowBeg());
}
#endif

void FlushShadowMemory() {
#if SANITIZER_LINUX
  StopTheWorld(FlushShadowMemoryCallback, 0);
#endif
}

#ifndef SANITIZER_GO
// Mark shadow for .rodata sections with the special kShadowRodata marker.
// Accesses to .rodata can't race, so this saves time, memory and trace space.
static void MapRodata() {
  // First create temp file.
  const char *tmpdir = GetEnv("TMPDIR");
  if (tmpdir == 0)
    tmpdir = GetEnv("TEST_TMPDIR");
#ifdef P_tmpdir
  if (tmpdir == 0)
    tmpdir = P_tmpdir;
#endif
  if (tmpdir == 0)
    return;
  char name[256];
  internal_snprintf(name, sizeof(name), "%s/tsan.rodata.%d",
                    tmpdir, (int)internal_getpid());
  uptr openrv = internal_open(name, O_RDWR | O_CREAT | O_EXCL, 0600);
  if (internal_iserror(openrv))
    return;
  internal_unlink(name);  // Unlink it now, so that we can reuse the buffer.
  fd_t fd = openrv;
  // Fill the file with kShadowRodata.
  const uptr kMarkerSize = 512 * 1024 / sizeof(u64);
  InternalScopedBuffer<u64> marker(kMarkerSize);
  // volatile to prevent insertion of memset
  for (volatile u64 *p = marker.data(); p < marker.data() + kMarkerSize; p++)
    *p = kShadowRodata;
  internal_write(fd, marker.data(), marker.size());
  // Map the file into memory.
  uptr page = internal_mmap(0, GetPageSizeCached(), PROT_READ | PROT_WRITE,
                            MAP_PRIVATE | MAP_ANONYMOUS, fd, 0);
  if (internal_iserror(page)) {
    internal_close(fd);
    return;
  }
  // Map the file into shadow of .rodata sections.
  MemoryMappingLayout proc_maps(/*cache_enabled*/true);
  uptr start, end, offset, prot;
  // Reusing the buffer 'name'.
  while (proc_maps.Next(&start, &end, &offset, name, ARRAY_SIZE(name), &prot)) {
    if (name[0] != 0 && name[0] != '['
        && (prot & MemoryMappingLayout::kProtectionRead)
        && (prot & MemoryMappingLayout::kProtectionExecute)
        && !(prot & MemoryMappingLayout::kProtectionWrite)
        && IsAppMem(start)) {
      // Assume it's .rodata
      char *shadow_start = (char*)MemToShadow(start);
      char *shadow_end = (char*)MemToShadow(end);
      for (char *p = shadow_start; p < shadow_end; p += marker.size()) {
        internal_mmap(p, Min<uptr>(marker.size(), shadow_end - p),
                      PROT_READ, MAP_PRIVATE | MAP_FIXED, fd, 0);
      }
    }
  }
  internal_close(fd);
}

void InitializeShadowMemoryPlatform() {
  MapRodata();
}

static void InitDataSeg() {
  MemoryMappingLayout proc_maps(true);
  uptr start, end, offset;
  char name[128];
#if SANITIZER_FREEBSD
  // On FreeBSD BSS is usually the last block allocated within the
  // low range and heap is the last block allocated within the range
  // 0x800000000-0x8ffffffff.
  while (proc_maps.Next(&start, &end, &offset, name, ARRAY_SIZE(name),
                        /*protection*/ 0)) {
    DPrintf("%p-%p %p %s\n", start, end, offset, name);
    if ((start & 0xffff00000000ULL) == 0 && (end & 0xffff00000000ULL) == 0 &&
        name[0] == '\0') {
      g_data_start = start;
      g_data_end = end;
    }
  }
#else
  bool prev_is_data = false;
  while (proc_maps.Next(&start, &end, &offset, name, ARRAY_SIZE(name),
                        /*protection*/ 0)) {
    DPrintf("%p-%p %p %s\n", start, end, offset, name);
    bool is_data = offset != 0 && name[0] != 0;
    // BSS may get merged with [heap] in /proc/self/maps. This is not very
    // reliable.
    bool is_bss = offset == 0 &&
      (name[0] == 0 || internal_strcmp(name, "[heap]") == 0) && prev_is_data;
    if (g_data_start == 0 && is_data)
      g_data_start = start;
    if (is_bss)
      g_data_end = end;
    prev_is_data = is_data;
  }
#endif
  DPrintf("guessed data_start=%p data_end=%p\n",  g_data_start, g_data_end);
  CHECK_LT(g_data_start, g_data_end);
  CHECK_GE((uptr)&g_data_start, g_data_start);
  CHECK_LT((uptr)&g_data_start, g_data_end);
}

#endif  // #ifndef SANITIZER_GO

void InitializePlatformEarly() {
#ifdef TSAN_RUNTIME_VMA
  vmaSize =
    (MostSignificantSetBitIndex(GET_CURRENT_FRAME()) + 1);
#if defined(__aarch64__)
  if (vmaSize != 39 && vmaSize != 42) {
    Printf("FATAL: ThreadSanitizer: unsupported VMA range\n");
    Printf("FATAL: Found %d - Supported 39 and 42\n", vmaSize);
    Die();
  }
#elif defined(__powerpc64__)
  if (vmaSize != 44 && vmaSize != 46) {
    Printf("FATAL: ThreadSanitizer: unsupported VMA range\n");
    Printf("FATAL: Found %d - Supported 42 and 46\n", vmaSize);
    Die();
  }
#endif
#endif
}

void InitializePlatform() {
  DisableCoreDumperIfNecessary();

  // Go maps shadow memory lazily and works fine with limited address space.
  // Unlimited stack is not a problem as well, because the executable
  // is not compiled with -pie.
  if (kCppMode) {
    bool reexec = false;
    // TSan doesn't play well with unlimited stack size (as stack
    // overlaps with shadow memory). If we detect unlimited stack size,
    // we re-exec the program with limited stack size as a best effort.
    if (StackSizeIsUnlimited()) {
      const uptr kMaxStackSize = 32 * 1024 * 1024;
      VReport(1, "Program is run with unlimited stack size, which wouldn't "
                 "work with ThreadSanitizer.\n"
                 "Re-execing with stack size limited to %zd bytes.\n",
              kMaxStackSize);
      SetStackSizeLimitInBytes(kMaxStackSize);
      reexec = true;
    }

    if (!AddressSpaceIsUnlimited()) {
      Report("WARNING: Program is run with limited virtual address space,"
             " which wouldn't work with ThreadSanitizer.\n");
      Report("Re-execing with unlimited virtual address space.\n");
      SetAddressSpaceUnlimited();
      reexec = true;
    }
    if (reexec)
      ReExec();
  }

#ifndef SANITIZER_GO
  CheckAndProtect();
  InitTlsSize();
  InitDataSeg();
#endif
}

bool IsGlobalVar(uptr addr) {
  return g_data_start && addr >= g_data_start && addr < g_data_end;
}

#ifndef SANITIZER_GO
// Extract file descriptors passed to glibc internal __res_iclose function.
// This is required to properly "close" the fds, because we do not see internal
// closes within glibc. The code is a pure hack.
int ExtractResolvFDs(void *state, int *fds, int nfd) {
#if SANITIZER_LINUX && !SANITIZER_ANDROID
  int cnt = 0;
  __res_state *statp = (__res_state*)state;
  for (int i = 0; i < MAXNS && cnt < nfd; i++) {
    if (statp->_u._ext.nsaddrs[i] && statp->_u._ext.nssocks[i] != -1)
      fds[cnt++] = statp->_u._ext.nssocks[i];
  }
  return cnt;
#else
  return 0;
#endif
}

// Extract file descriptors passed via UNIX domain sockets.
// This is requried to properly handle "open" of these fds.
// see 'man recvmsg' and 'man 3 cmsg'.
int ExtractRecvmsgFDs(void *msgp, int *fds, int nfd) {
  int res = 0;
  msghdr *msg = (msghdr*)msgp;
  struct cmsghdr *cmsg = CMSG_FIRSTHDR(msg);
  for (; cmsg; cmsg = CMSG_NXTHDR(msg, cmsg)) {
    if (cmsg->cmsg_level != SOL_SOCKET || cmsg->cmsg_type != SCM_RIGHTS)
      continue;
    int n = (cmsg->cmsg_len - CMSG_LEN(0)) / sizeof(fds[0]);
    for (int i = 0; i < n; i++) {
      fds[res++] = ((int*)CMSG_DATA(cmsg))[i];
      if (res == nfd)
        return res;
    }
  }
  return res;
}

// Note: this function runs with async signals enabled,
// so it must not touch any tsan state.
int call_pthread_cancel_with_cleanup(int(*fn)(void *c, void *m,
    void *abstime), void *c, void *m, void *abstime,
    void(*cleanup)(void *arg), void *arg) {
  // pthread_cleanup_push/pop are hardcore macros mess.
  // We can't intercept nor call them w/o including pthread.h.
  int res;
  pthread_cleanup_push(cleanup, arg);
  res = fn(c, m, abstime);
  pthread_cleanup_pop(0);
  return res;
}
#endif

#ifndef SANITIZER_GO
void ReplaceSystemMalloc() { }
#endif

}  // namespace __tsan

#endif  // SANITIZER_LINUX || SANITIZER_FREEBSD
