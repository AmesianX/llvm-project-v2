# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=znver1 -iterations=1500 -timeline -timeline-max-iterations=4 < %s | FileCheck %s

# Each lzcnt has a false dependency on %ecx; the first lzcnt has to wait on the
# imul. However, the folded load can start immediately.
# The last lzcnt has a false dependency on %cx. However, even in this case, the
# folded load can start immediately.

imul %edx, %ecx
lzcnt (%rsp), %cx
lzcnt 2(%rsp), %cx

# CHECK:      Iterations:        1500
# CHECK-NEXT: Instructions:      4500
# CHECK-NEXT: Total Cycles:      10503
# CHECK-NEXT: Dispatch Width:    4
# CHECK-NEXT: IPC:               0.43
# CHECK-NEXT: Block RThroughput: 1.3

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects (U)

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  1      3     1.00                        imull	%edx, %ecx
# CHECK-NEXT:  2      6     0.50    *                   lzcntw	(%rsp), %cx
# CHECK-NEXT:  2      6     0.50    *                   lzcntw	2(%rsp), %cx

# CHECK:      Resources:
# CHECK-NEXT: [0]   - ZnAGU0
# CHECK-NEXT: [1]   - ZnAGU1
# CHECK-NEXT: [2]   - ZnALU0
# CHECK-NEXT: [3]   - ZnALU1
# CHECK-NEXT: [4]   - ZnALU2
# CHECK-NEXT: [5]   - ZnALU3
# CHECK-NEXT: [6]   - ZnDivider
# CHECK-NEXT: [7]   - ZnFPU0
# CHECK-NEXT: [8]   - ZnFPU1
# CHECK-NEXT: [9]   - ZnFPU2
# CHECK-NEXT: [10]  - ZnFPU3
# CHECK-NEXT: [11]  - ZnMultiplier

# CHECK:      Resource pressure per iteration:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]
# CHECK-NEXT: 1.00   1.00   0.67   1.00   0.67   0.67    -      -      -      -      -     1.00

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   Instructions:
# CHECK-NEXT:  -      -      -     1.00    -      -      -      -      -      -      -     1.00   imull	%edx, %ecx
# CHECK-NEXT:  -     1.00   0.33    -     0.33   0.33    -      -      -      -      -      -     lzcntw	(%rsp), %cx
# CHECK-NEXT: 1.00    -     0.33    -     0.33   0.33    -      -      -      -      -      -     lzcntw	2(%rsp), %cx

# CHECK:      Timeline view:
# CHECK-NEXT:                     0123456789          0
# CHECK-NEXT: Index     0123456789          0123456789

# CHECK:      [0,0]     DeeeER    .    .    .    .    .   imull	%edx, %ecx
# CHECK-NEXT: [0,1]     DeeeeeeER .    .    .    .    .   lzcntw	(%rsp), %cx
# CHECK-NEXT: [0,2]     .DeeeeeeER.    .    .    .    .   lzcntw	2(%rsp), %cx
# CHECK-NEXT: [1,0]     .D======eeeER  .    .    .    .   imull	%edx, %ecx
# CHECK-NEXT: [1,1]     . D=====eeeeeeER    .    .    .   lzcntw	(%rsp), %cx
# CHECK-NEXT: [1,2]     . D======eeeeeeER   .    .    .   lzcntw	2(%rsp), %cx
# CHECK-NEXT: [2,0]     .  D===========eeeER.    .    .   imull	%edx, %ecx
# CHECK-NEXT: [2,1]     .  D===========eeeeeeER  .    .   lzcntw	(%rsp), %cx
# CHECK-NEXT: [2,2]     .   D===========eeeeeeER .    .   lzcntw	2(%rsp), %cx
# CHECK-NEXT: [3,0]     .   D=================eeeER   .   imull	%edx, %ecx
# CHECK-NEXT: [3,1]     .    D================eeeeeeER.   lzcntw	(%rsp), %cx
# CHECK-NEXT: [3,2]     .    D=================eeeeeeER   lzcntw	2(%rsp), %cx

# CHECK:      Average Wait times (based on the timeline view):
# CHECK-NEXT: [0]: Executions
# CHECK-NEXT: [1]: Average time spent waiting in a scheduler's queue
# CHECK-NEXT: [2]: Average time spent waiting in a scheduler's queue while ready
# CHECK-NEXT: [3]: Average time elapsed from WB until retire stage

# CHECK:            [0]    [1]    [2]    [3]
# CHECK-NEXT: 0.     4     9.5    0.3    0.0       imull	%edx, %ecx
# CHECK-NEXT: 1.     4     9.0    0.0    0.0       lzcntw	(%rsp), %cx
# CHECK-NEXT: 2.     4     9.5    0.0    0.0       lzcntw	2(%rsp), %cx
