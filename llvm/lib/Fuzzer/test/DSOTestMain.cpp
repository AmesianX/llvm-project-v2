// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.

// Source code for a simple DSO.

#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <cstdio>
extern int DSO1(int a);
extern int DSO2(int a);
extern int DSOTestExtra(int a);


extern "C" int LLVMFuzzerTestOneInput(const uint8_t *Data, size_t Size) {
  if (Size < sizeof(int) * 3) return 0;
  int x, y, z;
  memcpy(&x, Data + 0 * sizeof(int), sizeof(int));
  memcpy(&y, Data + 1 * sizeof(int), sizeof(int));
  memcpy(&z, Data + 2 * sizeof(int), sizeof(int));
  int sum = DSO1(x) + DSO2(y) + DSOTestExtra(z);
  if (sum == 3) {
    fprintf(stderr, "BINGO %d %d %d\n", x, y, z);
    exit(1);
  }
  return 0;
}
