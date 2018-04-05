//===-- sanitizer_symbolizer_libcdep.cc -----------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file is shared between AddressSanitizer and ThreadSanitizer
// run-time libraries.
//===----------------------------------------------------------------------===//

#include "sanitizer_allocator_internal.h"
#include "sanitizer_internal_defs.h"
#include "sanitizer_symbolizer_internal.h"

namespace __sanitizer {

Symbolizer *Symbolizer::GetOrInit() {
  SpinMutexLock l(&init_mu_);
  if (symbolizer_)
    return symbolizer_;
  symbolizer_ = PlatformInit();
  CHECK(symbolizer_);
  return symbolizer_;
}

// See sanitizer_symbolizer_fuchsia.cc.
#if !SANITIZER_FUCHSIA

const char *ExtractToken(const char *str, const char *delims, char **result) {
  uptr prefix_len = internal_strcspn(str, delims);
  *result = (char*)InternalAlloc(prefix_len + 1);
  internal_memcpy(*result, str, prefix_len);
  (*result)[prefix_len] = '\0';
  const char *prefix_end = str + prefix_len;
  if (*prefix_end != '\0') prefix_end++;
  return prefix_end;
}

const char *ExtractInt(const char *str, const char *delims, int *result) {
  char *buff;
  const char *ret = ExtractToken(str, delims, &buff);
  if (buff != 0) {
    *result = (int)internal_atoll(buff);
  }
  InternalFree(buff);
  return ret;
}

const char *ExtractUptr(const char *str, const char *delims, uptr *result) {
  char *buff;
  const char *ret = ExtractToken(str, delims, &buff);
  if (buff != 0) {
    *result = (uptr)internal_atoll(buff);
  }
  InternalFree(buff);
  return ret;
}

const char *ExtractTokenUpToDelimiter(const char *str, const char *delimiter,
                                      char **result) {
  const char *found_delimiter = internal_strstr(str, delimiter);
  uptr prefix_len =
      found_delimiter ? found_delimiter - str : internal_strlen(str);
  *result = (char *)InternalAlloc(prefix_len + 1);
  internal_memcpy(*result, str, prefix_len);
  (*result)[prefix_len] = '\0';
  const char *prefix_end = str + prefix_len;
  if (*prefix_end != '\0') prefix_end += internal_strlen(delimiter);
  return prefix_end;
}

SymbolizedStack *Symbolizer::SymbolizePC(uptr addr) {
  BlockingMutexLock l(&mu_);
  const char *module_name;
  uptr module_offset;
  ModuleArch arch;
  SymbolizedStack *res = SymbolizedStack::New(addr);
  if (!FindModuleNameAndOffsetForAddress(addr, &module_name, &module_offset,
                                         &arch))
    return res;
  // Always fill data about module name and offset.
  res->info.FillModuleInfo(module_name, module_offset, arch);
  for (auto &tool : tools_) {
    SymbolizerScope sym_scope(this);
    if (tool.SymbolizePC(addr, res)) {
      return res;
    }
  }
  return res;
}

bool Symbolizer::SymbolizeData(uptr addr, DataInfo *info) {
  BlockingMutexLock l(&mu_);
  const char *module_name;
  uptr module_offset;
  ModuleArch arch;
  if (!FindModuleNameAndOffsetForAddress(addr, &module_name, &module_offset,
                                         &arch))
    return false;
  info->Clear();
  info->module = internal_strdup(module_name);
  info->module_offset = module_offset;
  info->module_arch = arch;
  for (auto &tool : tools_) {
    SymbolizerScope sym_scope(this);
    if (tool.SymbolizeData(addr, info)) {
      return true;
    }
  }
  return true;
}

bool Symbolizer::GetModuleNameAndOffsetForPC(uptr pc, const char **module_name,
                                             uptr *module_address) {
  BlockingMutexLock l(&mu_);
  const char *internal_module_name = nullptr;
  ModuleArch arch;
  if (!FindModuleNameAndOffsetForAddress(pc, &internal_module_name,
                                         module_address, &arch))
    return false;

  if (module_name)
    *module_name = module_names_.GetOwnedCopy(internal_module_name);
  return true;
}

void Symbolizer::Flush() {
  BlockingMutexLock l(&mu_);
  for (auto &tool : tools_) {
    SymbolizerScope sym_scope(this);
    tool.Flush();
  }
}

const char *Symbolizer::Demangle(const char *name) {
  BlockingMutexLock l(&mu_);
  for (auto &tool : tools_) {
    SymbolizerScope sym_scope(this);
    if (const char *demangled = tool.Demangle(name))
      return demangled;
  }
  return PlatformDemangle(name);
}

bool Symbolizer::FindModuleNameAndOffsetForAddress(uptr address,
                                                   const char **module_name,
                                                   uptr *module_offset,
                                                   ModuleArch *module_arch) {
  const LoadedModule *module = FindModuleForAddress(address);
  if (module == nullptr)
    return false;
  *module_name = module->full_name();
  *module_offset = address - module->base_address();
  *module_arch = module->arch();
  return true;
}

void Symbolizer::RefreshModules() {
  modules_.init();
  fallback_modules_.fallbackInit();
  RAW_CHECK(modules_.size() > 0);
  modules_fresh_ = true;
}

static const LoadedModule *SearchForModule(const ListOfModules &modules,
                                           uptr address) {
  for (uptr i = 0; i < modules.size(); i++) {
    if (modules[i].containsAddress(address)) {
      return &modules[i];
    }
  }
  return nullptr;
}

const LoadedModule *Symbolizer::FindModuleForAddress(uptr address) {
  bool modules_were_reloaded = false;
  if (!modules_fresh_) {
    RefreshModules();
    modules_were_reloaded = true;
  }
  const LoadedModule *module = SearchForModule(modules_, address);
  if (module) return module;

  // dlopen/dlclose interceptors invalidate the module list, but when
  // interception is disabled, we need to retry if the lookup fails in
  // case the module list changed.
#if !SANITIZER_INTERCEPT_DLOPEN_DLCLOSE
  if (!modules_were_reloaded) {
    RefreshModules();
    module = SearchForModule(modules_, address);
    if (module) return module;
  }
#endif

  if (fallback_modules_.size()) {
    module = SearchForModule(fallback_modules_, address);
  }
  return module;
}

// For now we assume the following protocol:
// For each request of the form
//   <module_name> <module_offset>
// passed to STDIN, external symbolizer prints to STDOUT response:
//   <function_name>
//   <file_name>:<line_number>:<column_number>
//   <function_name>
//   <file_name>:<line_number>:<column_number>
//   ...
//   <empty line>
class LLVMSymbolizerProcess : public SymbolizerProcess {
 public:
  explicit LLVMSymbolizerProcess(const char *path) : SymbolizerProcess(path) {}

 private:
  bool ReachedEndOfOutput(const char *buffer, uptr length) const override {
    // Empty line marks the end of llvm-symbolizer output.
    return length >= 2 && buffer[length - 1] == '\n' &&
           buffer[length - 2] == '\n';
  }

  // When adding a new architecture, don't forget to also update
  // script/asan_symbolize.py and sanitizer_common.h.
  void GetArgV(const char *path_to_binary,
               const char *(&argv)[kArgVMax]) const override {
#if defined(__x86_64h__)
    const char* const kSymbolizerArch = "--default-arch=x86_64h";
#elif defined(__x86_64__)
    const char* const kSymbolizerArch = "--default-arch=x86_64";
#elif defined(__i386__)
    const char* const kSymbolizerArch = "--default-arch=i386";
#elif defined(__aarch64__)
    const char* const kSymbolizerArch = "--default-arch=arm64";
#elif defined(__arm__)
    const char* const kSymbolizerArch = "--default-arch=arm";
#elif defined(__powerpc64__) && __BYTE_ORDER__ == __ORDER_BIG_ENDIAN__
    const char* const kSymbolizerArch = "--default-arch=powerpc64";
#elif defined(__powerpc64__) && __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
    const char* const kSymbolizerArch = "--default-arch=powerpc64le";
#elif defined(__s390x__)
    const char* const kSymbolizerArch = "--default-arch=s390x";
#elif defined(__s390__)
    const char* const kSymbolizerArch = "--default-arch=s390";
#else
    const char* const kSymbolizerArch = "--default-arch=unknown";
#endif

    const char *const inline_flag = common_flags()->symbolize_inline_frames
                                        ? "--inlining=true"
                                        : "--inlining=false";
    int i = 0;
    argv[i++] = path_to_binary;
    argv[i++] = inline_flag;
    argv[i++] = kSymbolizerArch;
    argv[i++] = nullptr;
  }
};

LLVMSymbolizer::LLVMSymbolizer(const char *path, LowLevelAllocator *allocator)
    : symbolizer_process_(new(*allocator) LLVMSymbolizerProcess(path)) {}

// Parse a <file>:<line>[:<column>] buffer. The file path may contain colons on
// Windows, so extract tokens from the right hand side first. The column info is
// also optional.
static const char *ParseFileLineInfo(AddressInfo *info, const char *str) {
  char *file_line_info = 0;
  str = ExtractToken(str, "\n", &file_line_info);
  CHECK(file_line_info);

  if (uptr size = internal_strlen(file_line_info)) {
    char *back = file_line_info + size - 1;
    for (int i = 0; i < 2; ++i) {
      while (back > file_line_info && IsDigit(*back)) --back;
      if (*back != ':' || !IsDigit(back[1])) break;
      info->column = info->line;
      info->line = internal_atoll(back + 1);
      // Truncate the string at the colon to keep only filename.
      *back = '\0';
      --back;
    }
    ExtractToken(file_line_info, "", &info->file);
  }

  InternalFree(file_line_info);
  return str;
}

// Parses one or more two-line strings in the following format:
//   <function_name>
//   <file_name>:<line_number>[:<column_number>]
// Used by LLVMSymbolizer, Addr2LinePool and InternalSymbolizer, since all of
// them use the same output format.
void ParseSymbolizePCOutput(const char *str, SymbolizedStack *res) {
  bool top_frame = true;
  SymbolizedStack *last = res;
  while (true) {
    char *function_name = 0;
    str = ExtractToken(str, "\n", &function_name);
    CHECK(function_name);
    if (function_name[0] == '\0') {
      // There are no more frames.
      InternalFree(function_name);
      break;
    }
    SymbolizedStack *cur;
    if (top_frame) {
      cur = res;
      top_frame = false;
    } else {
      cur = SymbolizedStack::New(res->info.address);
      cur->info.FillModuleInfo(res->info.module, res->info.module_offset,
                               res->info.module_arch);
      last->next = cur;
      last = cur;
    }

    AddressInfo *info = &cur->info;
    info->function = function_name;
    str = ParseFileLineInfo(info, str);

    // Functions and filenames can be "??", in which case we write 0
    // to address info to mark that names are unknown.
    if (0 == internal_strcmp(info->function, "??")) {
      InternalFree(info->function);
      info->function = 0;
    }
    if (0 == internal_strcmp(info->file, "??")) {
      InternalFree(info->file);
      info->file = 0;
    }
  }
}

// Parses a two-line string in the following format:
//   <symbol_name>
//   <start_address> <size>
// Used by LLVMSymbolizer and InternalSymbolizer.
void ParseSymbolizeDataOutput(const char *str, DataInfo *info) {
  str = ExtractToken(str, "\n", &info->name);
  str = ExtractUptr(str, " ", &info->start);
  str = ExtractUptr(str, "\n", &info->size);
}

bool LLVMSymbolizer::SymbolizePC(uptr addr, SymbolizedStack *stack) {
  AddressInfo *info = &stack->info;
  const char *buf = FormatAndSendCommand(
      /*is_data*/ false, info->module, info->module_offset, info->module_arch);
  if (buf) {
    ParseSymbolizePCOutput(buf, stack);
    return true;
  }
  return false;
}

bool LLVMSymbolizer::SymbolizeData(uptr addr, DataInfo *info) {
  const char *buf = FormatAndSendCommand(
      /*is_data*/ true, info->module, info->module_offset, info->module_arch);
  if (buf) {
    ParseSymbolizeDataOutput(buf, info);
    info->start += (addr - info->module_offset); // Add the base address.
    return true;
  }
  return false;
}

const char *LLVMSymbolizer::FormatAndSendCommand(bool is_data,
                                                 const char *module_name,
                                                 uptr module_offset,
                                                 ModuleArch arch) {
  CHECK(module_name);
  const char *is_data_str = is_data ? "DATA " : "";
  if (arch == kModuleArchUnknown) {
    if (internal_snprintf(buffer_, kBufferSize, "%s\"%s\" 0x%zx\n", is_data_str,
                          module_name,
                          module_offset) >= static_cast<int>(kBufferSize)) {
      Report("WARNING: Command buffer too small");
      return nullptr;
    }
  } else {
    if (internal_snprintf(buffer_, kBufferSize, "%s\"%s:%s\" 0x%zx\n",
                          is_data_str, module_name, ModuleArchToString(arch),
                          module_offset) >= static_cast<int>(kBufferSize)) {
      Report("WARNING: Command buffer too small");
      return nullptr;
    }
  }
  return symbolizer_process_->SendCommand(buffer_);
}

SymbolizerProcess::SymbolizerProcess(const char *path, bool use_forkpty)
    : path_(path),
      input_fd_(kInvalidFd),
      output_fd_(kInvalidFd),
      times_restarted_(0),
      failed_to_start_(false),
      reported_invalid_path_(false),
      use_forkpty_(use_forkpty) {
  CHECK(path_);
  CHECK_NE(path_[0], '\0');
}

static bool IsSameModule(const char* path) {
  if (const char* ProcessName = GetProcessName()) {
    if (const char* SymbolizerName = StripModuleName(path)) {
      return !internal_strcmp(ProcessName, SymbolizerName);
    }
  }
  return false;
}

const char *SymbolizerProcess::SendCommand(const char *command) {
  if (failed_to_start_)
    return nullptr;
  if (IsSameModule(path_)) {
    Report("WARNING: Symbolizer was blocked from starting itself!\n");
    failed_to_start_ = true;
    return nullptr;
  }
  for (; times_restarted_ < kMaxTimesRestarted; times_restarted_++) {
    // Start or restart symbolizer if we failed to send command to it.
    if (const char *res = SendCommandImpl(command))
      return res;
    Restart();
  }
  if (!failed_to_start_) {
    Report("WARNING: Failed to use and restart external symbolizer!\n");
    failed_to_start_ = true;
  }
  return 0;
}

const char *SymbolizerProcess::SendCommandImpl(const char *command) {
  if (input_fd_ == kInvalidFd || output_fd_ == kInvalidFd)
      return 0;
  if (!WriteToSymbolizer(command, internal_strlen(command)))
      return 0;
  if (!ReadFromSymbolizer(buffer_, kBufferSize))
      return 0;
  return buffer_;
}

bool SymbolizerProcess::Restart() {
  if (input_fd_ != kInvalidFd)
    CloseFile(input_fd_);
  if (output_fd_ != kInvalidFd)
    CloseFile(output_fd_);
  return StartSymbolizerSubprocess();
}

bool SymbolizerProcess::ReadFromSymbolizer(char *buffer, uptr max_length) {
  if (max_length == 0)
    return true;
  uptr read_len = 0;
  while (true) {
    uptr just_read = 0;
    bool success = ReadFromFile(input_fd_, buffer + read_len,
                                max_length - read_len - 1, &just_read);
    // We can't read 0 bytes, as we don't expect external symbolizer to close
    // its stdout.
    if (!success || just_read == 0) {
      Report("WARNING: Can't read from symbolizer at fd %d\n", input_fd_);
      return false;
    }
    read_len += just_read;
    if (ReachedEndOfOutput(buffer, read_len))
      break;
    if (read_len + 1 == max_length) {
      Report("WARNING: Symbolizer buffer too small\n");
      read_len = 0;
      break;
    }
  }
  buffer[read_len] = '\0';
  return true;
}

bool SymbolizerProcess::WriteToSymbolizer(const char *buffer, uptr length) {
  if (length == 0)
    return true;
  uptr write_len = 0;
  bool success = WriteToFile(output_fd_, buffer, length, &write_len);
  if (!success || write_len != length) {
    Report("WARNING: Can't write to symbolizer at fd %d\n", output_fd_);
    return false;
  }
  return true;
}

#endif  // !SANITIZER_FUCHSIA

}  // namespace __sanitizer
