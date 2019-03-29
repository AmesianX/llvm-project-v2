# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=bdver2 -iterations=3 -timeline -register-file-stats < %s | FileCheck %s

pxor %mm0, %mm0
movq %mm0, %mm1

xorps %xmm0, %xmm0
movaps %xmm0, %xmm1
movups %xmm1, %xmm2
movapd %xmm2, %xmm3
movupd %xmm3, %xmm4
movdqa %xmm4, %xmm5
movdqu %xmm5, %xmm0

# CHECK:      Iterations:        3
# CHECK-NEXT: Instructions:      27
# CHECK-NEXT: Total Cycles:      16
# CHECK-NEXT: Total uOps:        27

# CHECK:      Dispatch Width:    4
# CHECK-NEXT: uOps Per Cycle:    1.69
# CHECK-NEXT: IPC:               1.69
# CHECK-NEXT: Block RThroughput: 3.5

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects (U)

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  1      0     0.25                        pxor	%mm0, %mm0
# CHECK-NEXT:  1      2     0.50                        movq	%mm0, %mm1
# CHECK-NEXT:  1      0     0.25                        xorps	%xmm0, %xmm0
# CHECK-NEXT:  1      1     0.50                        movaps	%xmm0, %xmm1
# CHECK-NEXT:  1      1     0.50                        movups	%xmm1, %xmm2
# CHECK-NEXT:  1      1     0.50                        movapd	%xmm2, %xmm3
# CHECK-NEXT:  1      1     0.50                        movupd	%xmm3, %xmm4
# CHECK-NEXT:  1      1     0.50                        movdqa	%xmm4, %xmm5
# CHECK-NEXT:  1      1     0.50                        movdqu	%xmm5, %xmm0

# CHECK:      Register File statistics:
# CHECK-NEXT: Total number of mappings created:    21
# CHECK-NEXT: Max number of mappings used:         16

# CHECK:      *  Register File #1 -- PdFpuPRF:
# CHECK-NEXT:    Number of physical registers:     160
# CHECK-NEXT:    Total number of mappings created: 21
# CHECK-NEXT:    Max number of mappings used:      16

# CHECK:      *  Register File #2 -- PdIntegerPRF:
# CHECK-NEXT:    Number of physical registers:     96
# CHECK-NEXT:    Total number of mappings created: 0
# CHECK-NEXT:    Max number of mappings used:      0

# CHECK:      Resources:
# CHECK-NEXT: [0.0] - PdAGLU01
# CHECK-NEXT: [0.1] - PdAGLU01
# CHECK-NEXT: [1]   - PdBranch
# CHECK-NEXT: [2]   - PdCount
# CHECK-NEXT: [3]   - PdDiv
# CHECK-NEXT: [4]   - PdEX0
# CHECK-NEXT: [5]   - PdEX1
# CHECK-NEXT: [6]   - PdFPCVT
# CHECK-NEXT: [7.0] - PdFPFMA
# CHECK-NEXT: [7.1] - PdFPFMA
# CHECK-NEXT: [8.0] - PdFPMAL
# CHECK-NEXT: [8.1] - PdFPMAL
# CHECK-NEXT: [9]   - PdFPMMA
# CHECK-NEXT: [10]  - PdFPSTO
# CHECK-NEXT: [11]  - PdFPU0
# CHECK-NEXT: [12]  - PdFPU1
# CHECK-NEXT: [13]  - PdFPU2
# CHECK-NEXT: [14]  - PdFPU3
# CHECK-NEXT: [15]  - PdFPXBR
# CHECK-NEXT: [16.0] - PdLoad
# CHECK-NEXT: [16.1] - PdLoad
# CHECK-NEXT: [17]  - PdMul
# CHECK-NEXT: [18]  - PdStore

# CHECK:      Resource pressure per iteration:
# CHECK-NEXT: [0.0]  [0.1]  [1]    [2]    [3]    [4]    [5]    [6]    [7.0]  [7.1]  [8.0]  [8.1]  [9]    [10]   [11]   [12]   [13]   [14]   [15]   [16.0] [16.1] [17]   [18]
# CHECK-NEXT:  -      -      -      -      -      -      -      -     2.00   2.00   1.33   1.67    -      -     3.33   3.67    -      -      -      -      -      -      -

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0.0]  [0.1]  [1]    [2]    [3]    [4]    [5]    [6]    [7.0]  [7.1]  [8.0]  [8.1]  [9]    [10]   [11]   [12]   [13]   [14]   [15]   [16.0] [16.1] [17]   [18]   Instructions:
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -     pxor	%mm0, %mm0
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -     0.33   0.67    -      -      -     1.00    -      -      -      -      -      -      -     movq	%mm0, %mm1
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -      -     xorps	%xmm0, %xmm0
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -     1.00    -      -      -      -     0.33   0.67    -      -      -      -      -      -      -     movaps	%xmm0, %xmm1
# CHECK-NEXT:  -      -      -      -      -      -      -      -     1.00    -      -      -      -      -      -     1.00    -      -      -      -      -      -      -     movups	%xmm1, %xmm2
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -     1.00    -      -      -      -     0.67   0.33    -      -      -      -      -      -      -     movapd	%xmm2, %xmm3
# CHECK-NEXT:  -      -      -      -      -      -      -      -     1.00    -      -      -      -      -     0.67   0.33    -      -      -      -      -      -      -     movupd	%xmm3, %xmm4
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -     0.67   0.33    -      -     1.00    -      -      -      -      -      -      -      -     movdqa	%xmm4, %xmm5
# CHECK-NEXT:  -      -      -      -      -      -      -      -      -      -     0.33   0.67    -      -     0.67   0.33    -      -      -      -      -      -      -     movdqu	%xmm5, %xmm0

# CHECK:      Timeline view:
# CHECK-NEXT:                     012345
# CHECK-NEXT: Index     0123456789

# CHECK:      [0,0]     DR   .    .    .   pxor	%mm0, %mm0
# CHECK-NEXT: [0,1]     DeeER.    .    .   movq	%mm0, %mm1
# CHECK-NEXT: [0,2]     D---R.    .    .   xorps	%xmm0, %xmm0
# CHECK-NEXT: [0,3]     DeE-R.    .    .   movaps	%xmm0, %xmm1
# CHECK-NEXT: [0,4]     .DeER.    .    .   movups	%xmm1, %xmm2
# CHECK-NEXT: [0,5]     .D=eER    .    .   movapd	%xmm2, %xmm3
# CHECK-NEXT: [0,6]     .D==eER   .    .   movupd	%xmm3, %xmm4
# CHECK-NEXT: [0,7]     .D===eER  .    .   movdqa	%xmm4, %xmm5
# CHECK-NEXT: [0,8]     . D===eER .    .   movdqu	%xmm5, %xmm0
# CHECK-NEXT: [1,0]     . D-----R .    .   pxor	%mm0, %mm0
# CHECK-NEXT: [1,1]     . DeeE--R .    .   movq	%mm0, %mm1
# CHECK-NEXT: [1,2]     . D-----R .    .   xorps	%xmm0, %xmm0
# CHECK-NEXT: [1,3]     .  DeE---R.    .   movaps	%xmm0, %xmm1
# CHECK-NEXT: [1,4]     .  D=eE--R.    .   movups	%xmm1, %xmm2
# CHECK-NEXT: [1,5]     .  D==eE-R.    .   movapd	%xmm2, %xmm3
# CHECK-NEXT: [1,6]     .  D===eER.    .   movupd	%xmm3, %xmm4
# CHECK-NEXT: [1,7]     .   D===eER    .   movdqa	%xmm4, %xmm5
# CHECK-NEXT: [1,8]     .   D====eER   .   movdqu	%xmm5, %xmm0
# CHECK-NEXT: [2,0]     .   D------R   .   pxor	%mm0, %mm0
# CHECK-NEXT: [2,1]     .   D==eeE-R   .   movq	%mm0, %mm1
# CHECK-NEXT: [2,2]     .    D-----R   .   xorps	%xmm0, %xmm0
# CHECK-NEXT: [2,3]     .    D==eE--R  .   movaps	%xmm0, %xmm1
# CHECK-NEXT: [2,4]     .    D===eE-R  .   movups	%xmm1, %xmm2
# CHECK-NEXT: [2,5]     .    D====eER  .   movapd	%xmm2, %xmm3
# CHECK-NEXT: [2,6]     .    .D====eER .   movupd	%xmm3, %xmm4
# CHECK-NEXT: [2,7]     .    .D=====eER.   movdqa	%xmm4, %xmm5
# CHECK-NEXT: [2,8]     .    .D======eER   movdqu	%xmm5, %xmm0

# CHECK:      Average Wait times (based on the timeline view):
# CHECK-NEXT: [0]: Executions
# CHECK-NEXT: [1]: Average time spent waiting in a scheduler's queue
# CHECK-NEXT: [2]: Average time spent waiting in a scheduler's queue while ready
# CHECK-NEXT: [3]: Average time elapsed from WB until retire stage

# CHECK:            [0]    [1]    [2]    [3]
# CHECK-NEXT: 0.     3     0.0    0.0    3.7       pxor	%mm0, %mm0
# CHECK-NEXT: 1.     3     1.7    1.7    1.0       movq	%mm0, %mm1
# CHECK-NEXT: 2.     3     0.0    0.0    4.3       xorps	%xmm0, %xmm0
# CHECK-NEXT: 3.     3     1.7    1.7    2.0       movaps	%xmm0, %xmm1
# CHECK-NEXT: 4.     3     2.3    0.0    1.0       movups	%xmm1, %xmm2
# CHECK-NEXT: 5.     3     3.3    0.0    0.3       movapd	%xmm2, %xmm3
# CHECK-NEXT: 6.     3     4.0    0.0    0.0       movupd	%xmm3, %xmm4
# CHECK-NEXT: 7.     3     4.7    0.0    0.0       movdqa	%xmm4, %xmm5
# CHECK-NEXT: 8.     3     5.3    0.0    0.0       movdqu	%xmm5, %xmm0
