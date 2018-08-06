# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=slm -instruction-tables < %s | FileCheck %s

addsubpd  %xmm0, %xmm2
addsubpd  (%rax),  %xmm2

addsubps  %xmm0, %xmm2
addsubps  (%rax), %xmm2

haddpd    %xmm0, %xmm2
haddpd    (%rax), %xmm2

haddps    %xmm0, %xmm2
haddps    (%rax), %xmm2

hsubpd    %xmm0, %xmm2
hsubpd    (%rax), %xmm2

hsubps    %xmm0, %xmm2
hsubps    (%rax), %xmm2

lddqu     (%rax), %xmm2

movddup   %xmm0, %xmm2
movddup   (%rax), %xmm2

movshdup  %xmm0, %xmm2
movshdup  (%rax), %xmm2

movsldup  %xmm0, %xmm2
movsldup  (%rax), %xmm2

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects (U)

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  1      3     1.00                        addsubpd	%xmm0, %xmm2
# CHECK-NEXT:  1      6     1.00    *                   addsubpd	(%rax), %xmm2
# CHECK-NEXT:  1      3     1.00                        addsubps	%xmm0, %xmm2
# CHECK-NEXT:  1      6     1.00    *                   addsubps	(%rax), %xmm2
# CHECK-NEXT:  1      3     1.00                        haddpd	%xmm0, %xmm2
# CHECK-NEXT:  1      6     1.00    *                   haddpd	(%rax), %xmm2
# CHECK-NEXT:  1      3     1.00                        haddps	%xmm0, %xmm2
# CHECK-NEXT:  1      6     1.00    *                   haddps	(%rax), %xmm2
# CHECK-NEXT:  1      3     1.00                        hsubpd	%xmm0, %xmm2
# CHECK-NEXT:  1      6     1.00    *                   hsubpd	(%rax), %xmm2
# CHECK-NEXT:  1      3     1.00                        hsubps	%xmm0, %xmm2
# CHECK-NEXT:  1      6     1.00    *                   hsubps	(%rax), %xmm2
# CHECK-NEXT:  1      3     1.00    *                   lddqu	(%rax), %xmm2
# CHECK-NEXT:  1      1     1.00                        movddup	%xmm0, %xmm2
# CHECK-NEXT:  1      4     1.00    *                   movddup	(%rax), %xmm2
# CHECK-NEXT:  1      1     1.00                        movshdup	%xmm0, %xmm2
# CHECK-NEXT:  1      4     1.00    *                   movshdup	(%rax), %xmm2
# CHECK-NEXT:  1      1     1.00                        movsldup	%xmm0, %xmm2
# CHECK-NEXT:  1      4     1.00    *                   movsldup	(%rax), %xmm2

# CHECK:      Resources:
# CHECK-NEXT: [0]   - SLMDivider
# CHECK-NEXT: [1]   - SLMFPDivider
# CHECK-NEXT: [2]   - SLMFPMultiplier
# CHECK-NEXT: [3]   - SLM_FPC_RSV0
# CHECK-NEXT: [4]   - SLM_FPC_RSV1
# CHECK-NEXT: [5]   - SLM_IEC_RSV0
# CHECK-NEXT: [6]   - SLM_IEC_RSV1
# CHECK-NEXT: [7]   - SLM_MEC_RSV

# CHECK:      Resource pressure per iteration:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]
# CHECK-NEXT:  -      -      -     14.00  12.00   -      -     10.00

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    Instructions:
# CHECK-NEXT:  -      -      -      -     1.00    -      -      -     addsubpd	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -     1.00    -      -     1.00   addsubpd	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -     1.00    -      -      -     addsubps	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -      -     1.00    -      -     1.00   addsubps	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     1.00   1.00    -      -      -     haddpd	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -     1.00   1.00    -      -     1.00   haddpd	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     1.00   1.00    -      -      -     haddps	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -     1.00   1.00    -      -     1.00   haddps	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     1.00   1.00    -      -      -     hsubpd	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -     1.00   1.00    -      -     1.00   hsubpd	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     1.00   1.00    -      -      -     hsubps	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -     1.00   1.00    -      -     1.00   hsubps	(%rax), %xmm2
# CHECK-NEXT:  -      -      -      -      -      -      -     1.00   lddqu	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     1.00    -      -      -      -     movddup	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -     1.00    -      -      -     1.00   movddup	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     1.00    -      -      -      -     movshdup	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -     1.00    -      -      -     1.00   movshdup	(%rax), %xmm2
# CHECK-NEXT:  -      -      -     1.00    -      -      -      -     movsldup	%xmm0, %xmm2
# CHECK-NEXT:  -      -      -     1.00    -      -      -     1.00   movsldup	(%rax), %xmm2
