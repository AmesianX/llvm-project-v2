# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=x86-64 -instruction-tables < %s | FileCheck %s

pabsb       %mm0, %mm2
pabsb       (%rax), %mm2

pabsb       %xmm0, %xmm2
pabsb       (%rax), %xmm2

pabsd       %mm0, %mm2
pabsd       (%rax), %mm2

pabsd       %xmm0, %xmm2
pabsd       (%rax), %xmm2

pabsw       %mm0, %mm2
pabsw       (%rax), %mm2

pabsw       %xmm0, %xmm2
pabsw       (%rax), %xmm2

palignr     $1, %mm0, %mm2
palignr     $1, (%rax), %mm2

palignr     $1, %xmm0, %xmm2
palignr     $1, (%rax), %xmm2

phaddd      %mm0, %mm2
phaddd      (%rax), %mm2

phaddd      %xmm0, %xmm2
phaddd      (%rax), %xmm2

phaddsw     %mm0, %mm2
phaddsw     (%rax), %mm2

phaddsw     %xmm0, %xmm2
phaddsw     (%rax), %xmm2

phaddw      %mm0, %mm2
phaddw      (%rax), %mm2

phaddw      %xmm0, %xmm2
phaddw      (%rax), %xmm2

phsubd      %mm0, %mm2
phsubd      (%rax), %mm2

phsubd      %xmm0, %xmm2
phsubd      (%rax), %xmm2

phsubsw     %mm0, %mm2
phsubsw     (%rax), %mm2

phsubsw     %xmm0, %xmm2
phsubsw     (%rax), %xmm2

phsubw      %mm0, %mm2
phsubw      (%rax), %mm2

phsubw      %xmm0, %xmm2
phsubw      (%rax), %xmm2

pmaddubsw   %mm0, %mm2
pmaddubsw   (%rax), %mm2

pmaddubsw   %xmm0, %xmm2
pmaddubsw   (%rax), %xmm2

pmulhrsw    %mm0, %mm2
pmulhrsw    (%rax), %mm2

pmulhrsw    %xmm0, %xmm2
pmulhrsw    (%rax), %xmm2

pshufb      %mm0, %mm2
pshufb      (%rax), %mm2

pshufb      %xmm0, %xmm2
pshufb      (%rax), %xmm2

psignb      %mm0, %mm2
psignb      (%rax), %mm2

psignb      %xmm0, %xmm2
psignb      (%rax), %xmm2

psignd      %mm0, %mm2
psignd      (%rax), %mm2

psignd      %xmm0, %xmm2
psignd      (%rax), %xmm2

psignw      %mm0, %mm2
psignw      (%rax), %mm2

psignw      %xmm0, %xmm2
psignw      (%rax), %xmm2

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  1      1     0.50                        pabsb	%mm0, %mm2
# CHECK-NEXT:  2      6     0.50    *                   pabsb	(%rax), %mm2
# CHECK-NEXT:  1      1     0.50                        pabsb	%xmm0, %xmm2
# CHECK-NEXT:  2      7     0.50    *                   pabsb	(%rax), %xmm2
# CHECK-NEXT:  1      1     0.50                        pabsd	%mm0, %mm2
# CHECK-NEXT:  2      6     0.50    *                   pabsd	(%rax), %mm2
# CHECK-NEXT:  1      1     0.50                        pabsd	%xmm0, %xmm2
# CHECK-NEXT:  2      7     0.50    *                   pabsd	(%rax), %xmm2
# CHECK-NEXT:  1      1     0.50                        pabsw	%mm0, %mm2
# CHECK-NEXT:  2      6     0.50    *                   pabsw	(%rax), %mm2
# CHECK-NEXT:  1      1     0.50                        pabsw	%xmm0, %xmm2
# CHECK-NEXT:  2      7     0.50    *                   pabsw	(%rax), %xmm2
# CHECK-NEXT:  1      1     0.50                        palignr	$1, %mm0, %mm2
# CHECK-NEXT:  2      6     0.50    *                   palignr	$1, (%rax), %mm2
# CHECK-NEXT:  1      1     0.50                        palignr	$1, %xmm0, %xmm2
# CHECK-NEXT:  2      7     0.50    *                   palignr	$1, (%rax), %xmm2
# CHECK-NEXT:  3      3     1.50                        phaddd	%mm0, %mm2
# CHECK-NEXT:  4      8     1.50    *                   phaddd	(%rax), %mm2
# CHECK-NEXT:  3      3     1.50                        phaddd	%xmm0, %xmm2
# CHECK-NEXT:  4      9     1.50    *                   phaddd	(%rax), %xmm2
# CHECK-NEXT:  3      3     1.50                        phaddsw	%mm0, %mm2
# CHECK-NEXT:  4      8     1.50    *                   phaddsw	(%rax), %mm2
# CHECK-NEXT:  3      3     1.50                        phaddsw	%xmm0, %xmm2
# CHECK-NEXT:  4      9     1.50    *                   phaddsw	(%rax), %xmm2
# CHECK-NEXT:  3      3     1.50                        phaddw	%mm0, %mm2
# CHECK-NEXT:  4      8     1.50    *                   phaddw	(%rax), %mm2
# CHECK-NEXT:  3      3     1.50                        phaddw	%xmm0, %xmm2
# CHECK-NEXT:  4      9     1.50    *                   phaddw	(%rax), %xmm2
# CHECK-NEXT:  3      3     1.50                        phsubd	%mm0, %mm2
# CHECK-NEXT:  4      8     1.50    *                   phsubd	(%rax), %mm2
# CHECK-NEXT:  3      3     1.50                        phsubd	%xmm0, %xmm2
# CHECK-NEXT:  4      9     1.50    *                   phsubd	(%rax), %xmm2
# CHECK-NEXT:  3      3     1.50                        phsubsw	%mm0, %mm2
# CHECK-NEXT:  4      8     1.50    *                   phsubsw	(%rax), %mm2
# CHECK-NEXT:  3      3     1.50                        phsubsw	%xmm0, %xmm2
# CHECK-NEXT:  4      9     1.50    *                   phsubsw	(%rax), %xmm2
# CHECK-NEXT:  3      3     1.50                        phsubw	%mm0, %mm2
# CHECK-NEXT:  4      8     1.50    *                   phsubw	(%rax), %mm2
# CHECK-NEXT:  3      3     1.50                        phsubw	%xmm0, %xmm2
# CHECK-NEXT:  4      9     1.50    *                   phsubw	(%rax), %xmm2
# CHECK-NEXT:  1      5     1.00                        pmaddubsw	%mm0, %mm2
# CHECK-NEXT:  2      10    1.00    *                   pmaddubsw	(%rax), %mm2
# CHECK-NEXT:  1      5     1.00                        pmaddubsw	%xmm0, %xmm2
# CHECK-NEXT:  2      11    1.00    *                   pmaddubsw	(%rax), %xmm2
# CHECK-NEXT:  1      5     1.00                        pmulhrsw	%mm0, %mm2
# CHECK-NEXT:  2      10    1.00    *                   pmulhrsw	(%rax), %mm2
# CHECK-NEXT:  1      5     1.00                        pmulhrsw	%xmm0, %xmm2
# CHECK-NEXT:  2      11    1.00    *                   pmulhrsw	(%rax), %xmm2
# CHECK-NEXT:  1      1     0.50                        pshufb	%mm0, %mm2
# CHECK-NEXT:  2      6     0.50    *                   pshufb	(%rax), %mm2
# CHECK-NEXT:  1      1     0.50                        pshufb	%xmm0, %xmm2
# CHECK-NEXT:  2      7     0.50    *                   pshufb	(%rax), %xmm2
# CHECK-NEXT:  1      1     0.50                        psignb	%mm0, %mm2
# CHECK-NEXT:  2      6     0.50    *                   psignb	(%rax), %mm2
# CHECK-NEXT:  1      1     0.50                        psignb	%xmm0, %xmm2
# CHECK-NEXT:  2      7     0.50    *                   psignb	(%rax), %xmm2
# CHECK-NEXT:  1      1     0.50                        psignd	%mm0, %mm2
# CHECK-NEXT:  2      6     0.50    *                   psignd	(%rax), %mm2
# CHECK-NEXT:  1      1     0.50                        psignd	%xmm0, %xmm2
# CHECK-NEXT:  2      7     0.50    *                   psignd	(%rax), %xmm2
# CHECK-NEXT:  1      1     0.50                        psignw	%mm0, %mm2
# CHECK-NEXT:  2      6     0.50    *                   psignw	(%rax), %mm2
# CHECK-NEXT:  1      1     0.50                        psignw	%xmm0, %xmm2
# CHECK-NEXT:  2      7     0.50    *                   psignw	(%rax), %xmm2

# CHECK:      Resources:
# CHECK-NEXT: [0]   - SBDivider
# CHECK-NEXT: [1]   - SBFPDivider
# CHECK-NEXT: [2]   - SBPort0
# CHECK-NEXT: [3]   - SBPort1
# CHECK-NEXT: [4]   - SBPort4
# CHECK-NEXT: [5]   - SBPort5
# CHECK-NEXT: [6.0] - SBPort23
# CHECK-NEXT: [6.1] - SBPort23

# CHECK:      Resource pressure per iteration:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6.0]  [6.1]
# CHECK-NEXT:  -      -     8.00   52.00   -     52.00  16.00  16.00

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6.0]  [6.1]  Instructions:
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     pabsb	%mm0, %mm2
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   pabsb	(%rax), %mm2
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     pabsb	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   pabsb	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     pabsd	%mm0, %mm2
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   pabsd	(%rax), %mm2
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     pabsd	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   pabsd	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     pabsw	%mm0, %mm2
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   pabsw	(%rax), %mm2
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     pabsw	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   pabsw	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     palignr	$1, %mm0, %mm2
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   palignr	$1, (%rax), %mm2
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     palignr	$1, %xmm0, %xmm2
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   palignr	$1, (%rax), %xmm2
# CHECK-NEXT:  -      -      -     1.50    -     1.50    -      -     phaddd	%mm0, %mm2
# CHECK-NEXT:  -      -      -     1.50    -     1.50   0.50   0.50   phaddd	(%rax), %mm2
# CHECK-NEXT:  -      -      -     1.50    -     1.50    -      -     phaddd	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -     1.50    -     1.50   0.50   0.50   phaddd	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     1.50    -     1.50    -      -     phaddsw	%mm0, %mm2
# CHECK-NEXT:  -      -      -     1.50    -     1.50   0.50   0.50   phaddsw	(%rax), %mm2
# CHECK-NEXT:  -      -      -     1.50    -     1.50    -      -     phaddsw	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -     1.50    -     1.50   0.50   0.50   phaddsw	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     1.50    -     1.50    -      -     phaddw	%mm0, %mm2
# CHECK-NEXT:  -      -      -     1.50    -     1.50   0.50   0.50   phaddw	(%rax), %mm2
# CHECK-NEXT:  -      -      -     1.50    -     1.50    -      -     phaddw	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -     1.50    -     1.50   0.50   0.50   phaddw	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     1.50    -     1.50    -      -     phsubd	%mm0, %mm2
# CHECK-NEXT:  -      -      -     1.50    -     1.50   0.50   0.50   phsubd	(%rax), %mm2
# CHECK-NEXT:  -      -      -     1.50    -     1.50    -      -     phsubd	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -     1.50    -     1.50   0.50   0.50   phsubd	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     1.50    -     1.50    -      -     phsubsw	%mm0, %mm2
# CHECK-NEXT:  -      -      -     1.50    -     1.50   0.50   0.50   phsubsw	(%rax), %mm2
# CHECK-NEXT:  -      -      -     1.50    -     1.50    -      -     phsubsw	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -     1.50    -     1.50   0.50   0.50   phsubsw	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     1.50    -     1.50    -      -     phsubw	%mm0, %mm2
# CHECK-NEXT:  -      -      -     1.50    -     1.50   0.50   0.50   phsubw	(%rax), %mm2
# CHECK-NEXT:  -      -      -     1.50    -     1.50    -      -     phsubw	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -     1.50    -     1.50   0.50   0.50   phsubw	(%rax), %xmm2
# CHECK-NEXT:  -      -     1.00    -      -      -      -      -     pmaddubsw	%mm0, %mm2
# CHECK-NEXT:  -      -     1.00    -      -      -     0.50   0.50   pmaddubsw	(%rax), %mm2
# CHECK-NEXT:  -      -     1.00    -      -      -      -      -     pmaddubsw	%xmm0, %xmm2
# CHECK-NEXT:  -      -     1.00    -      -      -     0.50   0.50   pmaddubsw	(%rax), %xmm2
# CHECK-NEXT:  -      -     1.00    -      -      -      -      -     pmulhrsw	%mm0, %mm2
# CHECK-NEXT:  -      -     1.00    -      -      -     0.50   0.50   pmulhrsw	(%rax), %mm2
# CHECK-NEXT:  -      -     1.00    -      -      -      -      -     pmulhrsw	%xmm0, %xmm2
# CHECK-NEXT:  -      -     1.00    -      -      -     0.50   0.50   pmulhrsw	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     pshufb	%mm0, %mm2
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   pshufb	(%rax), %mm2
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     pshufb	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   pshufb	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     psignb	%mm0, %mm2
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   psignb	(%rax), %mm2
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     psignb	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   psignb	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     psignd	%mm0, %mm2
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   psignd	(%rax), %mm2
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     psignd	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   psignd	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     psignw	%mm0, %mm2
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   psignw	(%rax), %mm2
# CHECK-NEXT:  -      -      -     0.50    -     0.50    -      -     psignw	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -     0.50    -     0.50   0.50   0.50   psignw	(%rax), %xmm2
