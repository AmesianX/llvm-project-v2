// Regression test for
// https://code.google.com/p/address-sanitizer/issues/detail?id=180

// RUN: %clangxx_asan -O0 %s -o %t && %env_asan_opts=handle_segv=0 not %run %t 2>&1 | FileCheck %s --check-prefix=CHECK0
// RUN: %clangxx_asan -O2 %s -o %t && %env_asan_opts=handle_segv=0 not %run %t 2>&1 | FileCheck %s --check-prefix=CHECK0

// RUN: %clangxx_asan -O0 %s -o %t && %env_asan_opts=handle_segv=1 not %run %t 2>&1 | FileCheck %s --check-prefix=CHECK1
// RUN: %clangxx_asan -O2 %s -o %t && %env_asan_opts=handle_segv=1 not %run %t 2>&1 | FileCheck %s --check-prefix=CHECK1

// RUN: %clangxx_asan -O0 %s -o %t && %env_asan_opts=handle_segv=2 not %run %t 2>&1 | FileCheck %s --check-prefix=CHECK2
// RUN: %clangxx_asan -O2 %s -o %t && %env_asan_opts=handle_segv=2 not %run %t 2>&1 | FileCheck %s --check-prefix=CHECK2

#include <signal.h>
#include <stdio.h>
#include <stdlib.h>

struct sigaction original_sigaction_sigbus;
struct sigaction original_sigaction_sigsegv;

void User_OnSIGSEGV(int signum, siginfo_t *siginfo, void *context) {
  fprintf(stderr, "User sigaction called\n");
  struct sigaction original_sigaction;
  if (signum == SIGBUS)
    original_sigaction = original_sigaction_sigbus;
  else if (signum == SIGSEGV)
    original_sigaction = original_sigaction_sigsegv;
  else {
    printf("Invalid signum");
    exit(1);
  }
  if (original_sigaction.sa_flags | SA_SIGINFO) {
    if (original_sigaction.sa_sigaction)
      original_sigaction.sa_sigaction(signum, siginfo, context);
  } else {
    if (original_sigaction.sa_handler)
      original_sigaction.sa_handler(signum);
  }
  exit(1);
}

int DoSEGV() {
  volatile int *x = 0;
  return *x;
}

bool InstallHandler(int signum, struct sigaction *original_sigaction) {
  struct sigaction user_sigaction;
  user_sigaction.sa_sigaction = User_OnSIGSEGV;
  user_sigaction.sa_flags = SA_SIGINFO;
  if (sigaction(signum, &user_sigaction, original_sigaction)) {
    perror("sigaction");
    return false;
  }
  return true;
}

int main() {
  // Let's install handlers for both SIGSEGV and SIGBUS, since pre-Yosemite
  // 32-bit Darwin triggers SIGBUS instead.
  if (InstallHandler(SIGSEGV, &original_sigaction_sigsegv) &&
      InstallHandler(SIGBUS, &original_sigaction_sigbus)) {
    fprintf(stderr, "User sigaction installed\n");
  }
  return DoSEGV();
}

// CHECK0-NOT: ASAN:DEADLYSIGNAL
// CHECK0-NOT: AddressSanitizer: SEGV on unknown address
// CHECK0: User sigaction installed
// CHECK0-NEXT: User sigaction called

// CHECK1: User sigaction installed
// CHECK1-NEXT: User sigaction called
// CHECK1-NEXT: ASAN:DEADLYSIGNAL
// CHECK1: AddressSanitizer: SEGV on unknown address

// CHECK2-NOT: User sigaction called
// CHECK2: User sigaction installed
// CHECK2-NEXT: ASAN:DEADLYSIGNAL
// CHECK2: AddressSanitizer: SEGV on unknown address
