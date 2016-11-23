# RUN: llvm-mc %s -triple=mips-unknown-linux -show-encoding -mcpu=mips32r6 -mattr=micromips | FileCheck %s

  .set noat
  add $3, $4, $5           # CHECK: add $3, $4, $5      # encoding: [0x00,0xa4,0x19,0x10]
  addiu $3, $4, 1234       # CHECK: addiu $3, $4, 1234  # encoding: [0x30,0x64,0x04,0xd2]
  addu $3, $4, $5          # CHECK: addu $3, $4, $5     # encoding: [0x00,0xa4,0x19,0x50]
  addiupc $4, 100          # CHECK: addiupc $4, 100     # encoding: [0x78,0x80,0x00,0x19]
  addiur1sp $7, 4          # CHECK: addiur1sp $7, 4     # encoding: [0x6f,0x83]
  addiur2 $6, $7, -1       # CHECK: addiur2 $6, $7, -1  # encoding: [0x6f,0x7e]
  addiur2 $6, $7, 12       # CHECK: addiur2 $6, $7, 12  # encoding: [0x6f,0x76]
  addius5 $7, -2           # CHECK: addius5 $7, -2      # encoding: [0x4c,0xfc]
  addiusp -1028            # CHECK: addiusp -1028       # encoding: [0x4f,0xff]
  addiusp -1032            # CHECK: addiusp -1032       # encoding: [0x4f,0xfd]
  addiusp 1024             # CHECK: addiusp 1024        # encoding: [0x4c,0x01]
  addiusp 1028             # CHECK: addiusp 1028        # encoding: [0x4c,0x03]
  addiusp -16              # CHECK: addiusp -16         # encoding: [0x4f,0xf9]
  aluipc $3, 56            # CHECK: aluipc $3, 56       # encoding: [0x78,0x7f,0x00,0x38]
  and $3, $4, $5           # CHECK: and $3, $4, $5      # encoding: [0x00,0xa4,0x1a,0x50]
  andi $3, $4, 1234        # CHECK: andi $3, $4, 1234   # encoding: [0xd0,0x64,0x04,0xd2]
  auipc $3, -1             # CHECK: auipc $3, -1        # encoding: [0x78,0x7e,0xff,0xff]
  align $4, $2, $3, 2      # CHECK: align $4, $2, $3, 2 # encoding: [0x00,0x43,0x24,0x1f]
  aui $3,$2,23             # CHECK: aui $3, $2, 23      # encoding: [0x10,0x62,0x00,0x17]
  beqc $3,$4, 16           # CHECK: beqc    $3, $4, 16  # encoding: [0x74,0x83,0x00,0x04]
  bgec $3,$4, 16           # CHECK: bgec    $3, $4, 16  # encoding: [0xf4,0x83,0x00,0x04]
  bgeuc $3,$4, 16          # CHECK: bgeuc   $3, $4, 16  # encoding: [0xc0,0x83,0x00,0x04]
  bltc $3,$4, 16           # CHECK: bltc    $3, $4, 16  # encoding: [0xd4,0x83,0x00,0x04]
  bltuc $3,$4, 16          # CHECK: bltuc   $3, $4, 16  # encoding: [0xe0,0x83,0x00,0x04]
  bnec $3,$4, 16           # CHECK: bnec    $3, $4, 16  # encoding: [0x7c,0x83,0x00,0x04]
  beqzalc $2, 1332         # CHECK: beqzalc $2, 1332    # encoding: [0x74,0x40,0x02,0x9a]
  bnezalc $2, 1332         # CHECK: bnezalc $2, 1332    # encoding: [0x7c,0x40,0x02,0x9a]
  bgezalc $2, 1332         # CHECK: bgezalc $2, 1332    # encoding: [0xc0,0x42,0x02,0x9a]
  bgtzalc $2, 1332         # CHECK: bgtzalc $2, 1332    # encoding: [0xe0,0x40,0x02,0x9a]
  bltzalc $2, 1332         # CHECK: bltzalc $2, 1332    # encoding: [0xe0,0x42,0x02,0x9a]
  blezalc $2, 1332         # CHECK: blezalc $2, 1332    # encoding: [0xc0,0x40,0x02,0x9a]
  beqzc   $3, 64           # CHECK: beqzc   $3, 64      # encoding: [0x80,0x60,0x00,0x10]
  bnezc   $3, 64           # CHECK: bnezc   $3, 64      # encoding: [0xa0,0x60,0x00,0x10]
  balc 7286128             # CHECK: balc 7286128        # encoding: [0xb4,0x37,0x96,0xb8]
  b 132                    # CHECK: bc16 132            # encoding: [0xcc,0x42]
  bc 7286128               # CHECK: bc 7286128          # encoding: [0x94,0x37,0x96,0xb8]
  bc16 132                 # CHECK: bc16 132            # encoding: [0xcc,0x42]
  beqzc16 $6, 20           # CHECK: beqzc16 $6, 20      # encoding: [0x8f,0x0a]
  bnezc16 $6, 20           # CHECK: bnezc16 $6, 20      # encoding: [0xaf,0x0a]
  bitswap $4, $2           # CHECK: bitswap $4, $2      # encoding: [0x00,0x44,0x0b,0x3c]
  break                    # CHECK: break               # encoding: [0x00,0x00,0x00,0x07]
  break 7                  # CHECK: break 7             # encoding: [0x00,0x07,0x00,0x07]
  break 7, 5               # CHECK: break 7, 5          # encoding: [0x00,0x07,0x01,0x47]
  cache 1, 8($5)           # CHECK: cache 1, 8($5)      # encoding: [0x20,0x25,0x60,0x08]
  clo $11, $a1             # CHECK: clo $11, $5         # encoding: [0x01,0x65,0x4b,0x3c]
  clz $sp, $gp             # CHECK: clz $sp, $gp        # encoding: [0x03,0x80,0xe8,0x50]
  div $3, $4, $5           # CHECK: div $3, $4, $5      # encoding: [0x00,0xa4,0x19,0x18]
  divu $3, $4, $5          # CHECK: divu $3, $4, $5     # encoding: [0x00,0xa4,0x19,0x98]
  ehb                      # CHECK: ehb                 # encoding: [0x00,0x00,0x18,0x00]
  ei                       # CHECK: ei                  # encoding: [0x00,0x00,0x57,0x7c]
  ei $0                    # CHECK: ei                  # encoding: [0x00,0x00,0x57,0x7c]
  ei $10                   # CHECK: ei $10              # encoding: [0x00,0x0a,0x57,0x7c]
  di                       # CHECK: di                  # encoding: [0x00,0x00,0x47,0x7c]
  di $0                    # CHECK: di                  # encoding: [0x00,0x00,0x47,0x7c]
  di $15                   # CHECK: di $15              # encoding: [0x00,0x0f,0x47,0x7c]
  eret                     # CHECK: eret                # encoding: [0x00,0x00,0xf3,0x7c]
  eretnc                   # CHECK: eretnc              # encoding: [0x00,0x01,0xf3,0x7c]
  jalr $9                  # CHECK: jalr $9             # encoding: [0x45,0x2b]
  jialc $5, 256            # CHECK: jialc $5, 256       # encoding: [0x80,0x05,0x01,0x00]
  jic   $5, 256            # CHECK: jic $5, 256         # encoding: [0xa0,0x05,0x01,0x00]
  jrc16 $9                 # CHECK: jrc16 $9            # encoding: [0x45,0x23]
  jrcaddiusp 20            # CHECK: jrcaddiusp 20       # encoding: [0x44,0xb3]
  lh $2, 8($4)             # CHECK: lh $2, 8($4)        # encoding: [0x3c,0x44,0x00,0x08]
  lhe $4, 8($2)            # CHECK: lhe $4, 8($2)       # encoding: [0x60,0x82,0x6a,0x08]
  lhu $4, 8($2)            # CHECK: lhu $4, 8($2)       # encoding: [0x34,0x82,0x00,0x08]
  lhue $4, 8($2)           # CHECK: lhue $4, 8($2)      # encoding: [0x60,0x82,0x62,0x08]
  lsa $2, $3, $4, 3        # CHECK: lsa  $2, $3, $4, 3  # encoding: [0x00,0x43,0x24,0x0f]
  lwpc    $2,268           # CHECK: lwpc $2, 268        # encoding: [0x78,0x48,0x00,0x43]
  lwm $16, $17, $ra, 8($sp)   # CHECK: lwm16 $16, $17, $ra, 8($sp) # encoding: [0x45,0x22]
  lwm16 $16, $17, $ra, 8($sp) # CHECK: lwm16 $16, $17, $ra, 8($sp) # encoding: [0x45,0x22]
  ll $2, 8($4)                    # CHECK: ll $2, 8($4)                    # encoding: [0x60,0x44,0x30,0x08]
  lwm32 $16, $17, 8($4)           # CHECK: lwm32 $16, $17, 8($4)           # encoding: [0x20,0x44,0x50,0x08]
  lwm32 $16, $17, 8($sp)          # CHECK: lwm32 $16, $17, 8($sp)          # encoding: [0x20,0x5d,0x50,0x08]
  lwm32 $16, $17, $ra, 8($4)      # CHECK: lwm32 $16, $17, $ra, 8($4)      # encoding: [0x22,0x44,0x50,0x08]
  lwm32 $16, $17, $ra, 64($sp)    # CHECK: lwm32 $16, $17, $ra, 64($sp)    # encoding: [0x22,0x5d,0x50,0x40]
  lwm32 $16, $17, $18, $19, 8($4) # CHECK: lwm32 $16, $17, $18, $19, 8($4) # encoding: [0x20,0x84,0x50,0x08]
  lwm32 $16, $17, $18, $19, $ra, 8($4)                          # CHECK: lwm32 $16, $17, $18, $19, $ra, 8($4)                          # encoding: [0x22,0x84,0x50,0x08]
  lwm32 $16, $17, $18, $19, $20, $21, $22, $23, $fp, 8($4)      # CHECK: lwm32 $16, $17, $18, $19, $20, $21, $22, $23, $fp, 8($4)      # encoding: [0x21,0x24,0x50,0x08]
  lwm32 $16, $17, $18, $19, $20, $21, $22, $23, $fp, $ra, 8($4) # CHECK: lwm32 $16, $17, $18, $19, $20, $21, $22, $23, $fp, $ra, 8($4) # encoding: [0x23,0x24,0x50,0x08]
  lwm32 $16, $17, $18, $19, $20, $21, $22, $23, $fp, $ra, 8($4) # CHECK: lwm32 $16, $17, $18, $19, $20, $21, $22, $23, $fp, $ra, 8($4) # encoding: [0x23,0x24,0x50,0x08]
  movep $5, $6, $2, $3            # CHECK: movep $5, $6, $2, $3            # encoding: [0x84,0x34]
  rotr $2, 7                      # CHECK: rotr $2, $2, 7                  # encoding: [0x00,0x42,0x38,0xc0]
  rotr $9, $6, 7                  # CHECK: rotr $9, $6, 7                  # encoding: [0x01,0x26,0x38,0xc0]
  rotrv $9, $6, $7                # CHECK: rotrv $9, $6, $7                # encoding: [0x00,0xc7,0x48,0xd0]
  sc $2, 8($4)                    # CHECK: sc $2, 8($4)                    # encoding: [0x60,0x44,0xb0,0x08]
  sgt $4, $5, $6                  # CHECK: slt $4, $6, $5                  # encoding: [0x00,0xa6,0x23,0x50]
  sgtu $4, $5, $6                 # CHECK: sltu $4, $6, $5                 # encoding: [0x00,0xa6,0x23,0x90]
  sll $4, $5                      # CHECK: sllv $4, $4, $5                 # encoding: [0x00,0x85,0x20,0x10]
  sra $4, $5                      # CHECK: srav $4, $4, $5                 # encoding: [0x00,0x85,0x20,0x90]
  srl $4, $5                      # CHECK: srlv $4, $4, $5                 # encoding: [0x00,0x85,0x20,0x50]
  swm32 $16, $17, 8($4)           # CHECK: swm32 $16, $17, 8($4)           # encoding: [0x20,0x44,0xd0,0x08]
  swm32 $16, $17, 8($sp)          # CHECK: swm32 $16, $17, 8($sp)          # encoding: [0x20,0x5d,0xd0,0x08]
  swm32 $16, $17, $ra, 8($4)      # CHECK: swm32 $16, $17, $ra, 8($4)      # encoding: [0x22,0x44,0xd0,0x08]
  swm32 $16, $17, $ra, 64($sp)    # CHECK: swm32 $16, $17, $ra, 64($sp)    # encoding: [0x22,0x5d,0xd0,0x40]
  swm32 $16, $17, $18, $19, 8($4) # CHECK: swm32 $16, $17, $18, $19, 8($4) # encoding: [0x20,0x84,0xd0,0x08]
  syscall                         # CHECK: syscall                         # encoding: [0x00,0x00,0x8b,0x7c]
  syscall 396                     # CHECK: syscall 396                     # encoding: [0x01,0x8c,0x8b,0x7c]
  mod $3, $4, $5           # CHECK: mod $3, $4, $5      # encoding: [0x00,0xa4,0x19,0x58]
  modu $3, $4, $5          # CHECK: modu $3, $4, $5     # encoding: [0x00,0xa4,0x19,0xd8]
  mul $3, $4, $5           # CHECK mul $3, $4, $5       # encoding: [0x00,0xa4,0x18,0x18]
  muh $3, $4, $5           # CHECK muh $3, $4, $5       # encoding: [0x00,0xa4,0x18,0x58]
  mulu $3, $4, $5          # CHECK mulu $3, $4, $5      # encoding: [0x00,0xa4,0x18,0x98]
  muhu $3, $4, $5          # CHECK muhu $3, $4, $5      # encoding: [0x00,0xa4,0x18,0xd8]
  nop                      # CHECK: nop                 # encoding: [0x00,0x00,0x00,0x00]
  nor $3, $4, $5           # CHECK: nor $3, $4, $5      # encoding: [0x00,0xa4,0x1a,0xd0]
  or $3, $4, $5            # CHECK: or $3, $4, $5       # encoding: [0x00,0xa4,0x1a,0x90]
  ori $3, $4, 1234         # CHECK: ori $3, $4, 1234    # encoding: [0x50,0x64,0x04,0xd2]
  pref 1, 8($5)            # CHECK: pref 1, 8($5)       # encoding: [0x60,0x25,0x20,0x08]
  sb16 $3, 4($16)          # CHECK: sb16 $3, 4($16)     # encoding: [0x89,0x84]
  seb $3, $4               # CHECK: seb $3, $4          # encoding: [0x00,0x64,0x2b,0x3c]
  seb $3                   # CHECK: seb $3, $3          # encoding: [0x00,0x63,0x2b,0x3c]
  seh $3, $4               # CHECK: seh $3, $4          # encoding: [0x00,0x64,0x3b,0x3c]
  seh $3                   # CHECK: seh $3, $3          # encoding: [0x00,0x63,0x3b,0x3c]
  seleqz $2,$3,$4          # CHECK: seleqz $2, $3, $4   # encoding: [0x00,0x83,0x11,0x40]
  selnez $2,$3,$4          # CHECK: selnez $2, $3, $4   # encoding: [0x00,0x83,0x11,0x80]
  sh16 $4, 8($17)          # CHECK: sh16 $4, 8($17)     # encoding: [0xaa,0x14]
  sll $4, $3, 7            # CHECK: sll $4, $3, 7       # encoding: [0x00,0x83,0x38,0x00]
  sub $3, $4, $5           # CHECK: sub $3, $4, $5      # encoding: [0x00,0xa4,0x19,0x90]
  subu $3, $4, $5          # CHECK: subu $3, $4, $5     # encoding: [0x00,0xa4,0x19,0xd0]
  sw $4, 124($sp)          # CHECK: sw $4, 124($sp)     # encoding: [0xc8,0x9f]
  sw $4, 128($sp)          # CHECK: sw $4, 128($sp)     # encoding: [0xf8,0x9d,0x00,0x80]
  sw16 $4, 4($17)          # CHECK: sw16 $4, 4($17)     # encoding: [0xea,0x11]
  sw16 $0, 4($17)          # CHECK: sw16 $zero, 4($17)  # encoding: [0xe8,0x11]
  swm $16, $17, $ra, 8($sp)   # CHECK: swm16 $16, $17, $ra, 8($sp) # encoding: [0x45,0x2a]
  swm16 $16, $17, $ra, 8($sp) # CHECK: swm16 $16, $17, $ra, 8($sp) # encoding: [0x45,0x2a]
  wrpgpr $3, $4            # CHECK: wrpgpr $3, $4       # encoding: [0x00,0x64,0xf1,0x7c]
  wsbh $3, $4              # CHECK: wsbh $3, $4         # encoding: [0x00,0x64,0x7b,0x3c]
  pause                    # CHECK: pause               # encoding: [0x00,0x00,0x28,0x00]
  rdhwr $5, $29, 2         # CHECK: rdhwr $5, $29, 2    # encoding: [0x00,0xbd,0x11,0xc0]
  rdhwr $5, $29, 0         # CHECK: rdhwr $5, $29       # encoding: [0x00,0xbd,0x01,0xc0]
  rdhwr $5, $29            # CHECK: rdhwr $5, $29       # encoding: [0x00,0xbd,0x01,0xc0]
  wait                     # CHECK: wait                # encoding: [0x00,0x00,0x93,0x7c]
  wait 17                  # CHECK: wait 17             # encoding: [0x00,0x11,0x93,0x7c]
  ssnop                    # CHECK: ssnop               # encoding: [0x00,0x00,0x08,0x00]
  sync                     # CHECK: sync                # encoding: [0x00,0x00,0x6b,0x7c]
  sync 17                  # CHECK: sync 17             # encoding: [0x00,0x11,0x6b,0x7c]
  synci 8($5)              # CHECK: synci 8($5)         # encoding: [0x41,0x85,0x00,0x08]
  rdpgpr $3, $9            # CHECK: $3, $9              # encoding: [0x00,0x69,0xe1,0x7c]
  sdbbp                    # CHECK: sdbbp               # encoding: [0x00,0x00,0xdb,0x7c]
  sdbbp 34                 # CHECK: sdbbp 34            # encoding: [0x00,0x22,0xdb,0x7c]
  xor $3, $4, $5           # CHECK: xor $3, $4, $5      # encoding: [0x00,0xa4,0x1b,0x10]
  xori $3, $4, 1234        # CHECK: xori $3, $4, 1234   # encoding: [0x70,0x64,0x04,0xd2]
  sw $5, 4($6)             # CHECK: sw $5, 4($6)        # encoding: [0xf8,0xa6,0x00,0x04]
  swe $5, 8($4)            # CHECK: swe $5, 8($4)       # encoding: [0x60,0xa4,0xae,0x08]
  add.s $f3, $f4, $f5      # CHECK: add.s $f3, $f4, $f5 # encoding: [0x54,0xa4,0x18,0x30]
  add.d $f2, $f4, $f6      # CHECK: add.d $f2, $f4, $f6 # encoding: [0x54,0xc4,0x11,0x30]
  sub.s $f3, $f4, $f5      # CHECK: sub.s $f3, $f4, $f5 # encoding: [0x54,0xa4,0x18,0x70]
  sub.d $f2, $f4, $f6      # CHECK: sub.d $f2, $f4, $f6 # encoding: [0x54,0xc4,0x11,0x70]
  mul.s $f3, $f4, $f5      # CHECK: mul.s $f3, $f4, $f5 # encoding: [0x54,0xa4,0x18,0xb0]
  mul.d $f2, $f4, $f6      # CHECK: mul.d $f2, $f4, $f6 # encoding: [0x54,0xc4,0x11,0xb0]
  div.s $f3, $f4, $f5      # CHECK: div.s $f3, $f4, $f5 # encoding: [0x54,0xa4,0x18,0xf0]
  div.d $f2, $f4, $f6      # CHECK: div.d $f2, $f4, $f6 # encoding: [0x54,0xc4,0x11,0xf0]
  maddf.s $f3, $f4, $f5    # CHECK: maddf.s $f3, $f4, $f5 # encoding: [0x54,0xa4,0x19,0xb8]
  maddf.d $f3, $f4, $f5    # CHECK: maddf.d $f3, $f4, $f5 # encoding: [0x54,0xa4,0x1b,0xb8]
  msubf.s $f3, $f4, $f5    # CHECK: msubf.s $f3, $f4, $f5 # encoding: [0x54,0xa4,0x19,0xf8]
  msubf.d $f3, $f4, $f5    # CHECK: msubf.d $f3, $f4, $f5 # encoding: [0x54,0xa4,0x1b,0xf8]
  mov.s $f6, $f7           # CHECK: mov.s $f6, $f7      # encoding: [0x54,0xc7,0x00,0x7b]
  mov.d $f4, $f6           # CHECK: mov.d $f4, $f6      # encoding: [0x54,0x86,0x20,0x7b]
  neg.s $f6, $f7           # CHECK: neg.s $f6, $f7      # encoding: [0x54,0xc7,0x0b,0x7b]
  neg.d $f4, $f6           # CHECK: neg.d $f4, $f6      # encoding: [0x54,0x86,0x2b,0x7b]
  max.s $f5, $f4, $f3      # CHECK: max.s $f5, $f4, $f3      # encoding: [0x54,0x64,0x28,0x0b]
  max.d $f5, $f4, $f3      # CHECK: max.d $f5, $f4, $f3      # encoding: [0x54,0x64,0x2a,0x0b]
  maxa.s $f5, $f4, $f3     # CHECK: maxa.s $f5, $f4, $f3     # encoding: [0x54,0x64,0x28,0x2b]
  maxa.d $f5, $f4, $f3     # CHECK: maxa.d $f5, $f4, $f3     # encoding: [0x54,0x64,0x2a,0x2b]
  min.s $f5, $f4, $f3      # CHECK: min.s $f5, $f4, $f3      # encoding: [0x54,0x64,0x28,0x03]
  min.d $f5, $f4, $f3      # CHECK: min.d $f5, $f4, $f3      # encoding: [0x54,0x64,0x2a,0x03]
  mina.s $f5, $f4, $f3     # CHECK: mina.s $f5, $f4, $f3     # encoding: [0x54,0x64,0x28,0x23]
  mina.d $f5, $f4, $f3     # CHECK: mina.d $f5, $f4, $f3     # encoding: [0x54,0x64,0x2a,0x23]
  cmp.af.s $f2, $f3, $f4   # CHECK: cmp.af.s $f2, $f3, $f4   # encoding: [0x54,0x83,0x10,0x05]
  cmp.af.d $f2, $f3, $f4   # CHECK: cmp.af.d $f2, $f3, $f4   # encoding: [0x54,0x83,0x10,0x15]
  cmp.un.s $f2, $f3, $f4   # CHECK: cmp.un.s $f2, $f3, $f4   # encoding: [0x54,0x83,0x10,0x45]
  cmp.un.d $f2, $f3, $f4   # CHECK: cmp.un.d $f2, $f3, $f4   # encoding: [0x54,0x83,0x10,0x55]
  cmp.eq.s $f2, $f3, $f4   # CHECK: cmp.eq.s $f2, $f3, $f4   # encoding: [0x54,0x83,0x10,0x85]
  cmp.eq.d $f2, $f3, $f4   # CHECK: cmp.eq.d $f2, $f3, $f4   # encoding: [0x54,0x83,0x10,0x95]
  cmp.ueq.s $f2, $f3, $f4  # CHECK: cmp.ueq.s $f2, $f3, $f4  # encoding: [0x54,0x83,0x10,0xc5]
  cmp.ueq.d $f2, $f3, $f4  # CHECK: cmp.ueq.d $f2, $f3, $f4  # encoding: [0x54,0x83,0x10,0xd5]
  cmp.lt.s $f2, $f3, $f4   # CHECK: cmp.lt.s  $f2, $f3, $f4  # encoding: [0x54,0x83,0x11,0x05]
  cmp.lt.d $f2, $f3, $f4   # CHECK: cmp.lt.d  $f2, $f3, $f4  # encoding: [0x54,0x83,0x11,0x15]
  cmp.ult.s $f2, $f3, $f4  # CHECK: cmp.ult.s $f2, $f3, $f4  # encoding: [0x54,0x83,0x11,0x45]
  cmp.ult.d $f2, $f3, $f4  # CHECK: cmp.ult.d $f2, $f3, $f4  # encoding: [0x54,0x83,0x11,0x55]
  cmp.le.s $f2, $f3, $f4   # CHECK: cmp.le.s  $f2, $f3, $f4  # encoding: [0x54,0x83,0x11,0x85]
  cmp.le.d $f2, $f3, $f4   # CHECK: cmp.le.d  $f2, $f3, $f4  # encoding: [0x54,0x83,0x11,0x95]
  cmp.ule.s $f2, $f3, $f4  # CHECK: cmp.ule.s $f2, $f3, $f4  # encoding: [0x54,0x83,0x11,0xc5]
  cmp.ule.d $f2, $f3, $f4  # CHECK: cmp.ule.d $f2, $f3, $f4  # encoding: [0x54,0x83,0x11,0xd5]
  cmp.saf.s $f2, $f3, $f4  # CHECK: cmp.saf.s $f2, $f3, $f4  # encoding: [0x54,0x83,0x12,0x05]
  cmp.saf.d $f2, $f3, $f4  # CHECK: cmp.saf.d $f2, $f3, $f4  # encoding: [0x54,0x83,0x12,0x15]
  cmp.sun.s $f2, $f3, $f4  # CHECK: cmp.sun.s $f2, $f3, $f4  # encoding: [0x54,0x83,0x12,0x45]
  cmp.sun.d $f2, $f3, $f4  # CHECK: cmp.sun.d $f2, $f3, $f4  # encoding: [0x54,0x83,0x12,0x55]
  cmp.seq.s $f2, $f3, $f4  # CHECK: cmp.seq.s $f2, $f3, $f4  # encoding: [0x54,0x83,0x12,0x85]
  cmp.seq.d $f2, $f3, $f4  # CHECK: cmp.seq.d $f2, $f3, $f4  # encoding: [0x54,0x83,0x12,0x95]
  cmp.sueq.s $f2, $f3, $f4 # CHECK: cmp.sueq.s $f2, $f3, $f4 # encoding: [0x54,0x83,0x12,0xc5]
  cmp.sueq.d $f2, $f3, $f4 # CHECK: cmp.sueq.d $f2, $f3, $f4 # encoding: [0x54,0x83,0x12,0xd5]
  cmp.slt.s $f2, $f3, $f4  # CHECK: cmp.slt.s $f2, $f3, $f4  # encoding: [0x54,0x83,0x13,0x05]
  cmp.slt.d $f2, $f3, $f4  # CHECK: cmp.slt.d $f2, $f3, $f4  # encoding: [0x54,0x83,0x13,0x15]
  cmp.sult.s $f2, $f3, $f4 # CHECK: cmp.sult.s $f2, $f3, $f4 # encoding: [0x54,0x83,0x13,0x45]
  cmp.sult.d $f2, $f3, $f4 # CHECK: cmp.sult.d $f2, $f3, $f4 # encoding: [0x54,0x83,0x13,0x55]
  cmp.sle.s $f2, $f3, $f4  # CHECK: cmp.sle.s $f2, $f3, $f4  # encoding: [0x54,0x83,0x13,0x85]
  cmp.sle.d $f2, $f3, $f4  # CHECK: cmp.sle.d $f2, $f3, $f4  # encoding: [0x54,0x83,0x13,0x95]
  cmp.sule.s $f2, $f3, $f4 # CHECK: cmp.sule.s $f2, $f3, $f4 # encoding: [0x54,0x83,0x13,0xc5]
  cmp.sule.d $f2, $f3, $f4 # CHECK: cmp.sule.d $f2, $f3, $f4 # encoding: [0x54,0x83,0x13,0xd5]
  cvt.l.s $f3, $f4         # CHECK: cvt.l.s $f3, $f4         # encoding: [0x54,0x64,0x01,0x3b]
  cvt.l.d $f3, $f4         # CHECK: cvt.l.d $f3, $f4         # encoding: [0x54,0x64,0x41,0x3b]
  cvt.w.s $f3, $f4         # CHECK: cvt.w.s $f3, $f4         # encoding: [0x54,0x64,0x09,0x3b]
  cvt.w.d $f3, $f4         # CHECK: cvt.w.d $f3, $f4         # encoding: [0x54,0x64,0x49,0x3b]
  cvt.d.s $f2, $f4         # CHECK: cvt.d.s $f2, $f4         # encoding: [0x54,0x44,0x13,0x7b]
  cvt.d.w $f2, $f4         # CHECK: cvt.d.w $f2, $f4         # encoding: [0x54,0x44,0x33,0x7b]
  cvt.d.l $f2, $f4         # CHECK: cvt.d.l $f2, $f4         # encoding: [0x54,0x44,0x53,0x7b]
  cvt.s.d $f2, $f4         # CHECK: cvt.s.d $f2, $f4         # encoding: [0x54,0x44,0x1b,0x7b]
  cvt.s.w $f3, $f4         # CHECK: cvt.s.w $f3, $f4         # encoding: [0x54,0x64,0x3b,0x7b]
  cvt.s.l $f3, $f4         # CHECK: cvt.s.l $f3, $f4         # encoding: [0x54,0x64,0x5b,0x7b]
  abs.s $f3, $f5           # CHECK: abs.s $f3, $f5      # encoding: [0x54,0x65,0x03,0x7b]
  abs.d $f2, $f4           # CHECK: abs.d $f2, $f4      # encoding: [0x54,0x44,0x23,0x7b]
  floor.l.s $f3, $f5       # CHECK: floor.l.s $f3, $f5  # encoding: [0x54,0x65,0x03,0x3b]
  floor.l.d $f2, $f4       # CHECK: floor.l.d $f2, $f4  # encoding: [0x54,0x44,0x43,0x3b]
  floor.w.s $f3, $f5       # CHECK: floor.w.s $f3, $f5  # encoding: [0x54,0x65,0x0b,0x3b]
  floor.w.d $f2, $f4       # CHECK: floor.w.d $f2, $f4  # encoding: [0x54,0x44,0x4b,0x3b]
  ceil.l.s $f3, $f5        # CHECK: ceil.l.s $f3, $f5   # encoding: [0x54,0x65,0x13,0x3b]
  ceil.l.d $f2, $f4        # CHECK: ceil.l.d $f2, $f4   # encoding: [0x54,0x44,0x53,0x3b]
  ceil.w.s $f3, $f5        # CHECK: ceil.w.s $f3, $f5   # encoding: [0x54,0x65,0x1b,0x3b]
  ceil.w.d $f2, $f4        # CHECK: ceil.w.d $f2, $f4   # encoding: [0x54,0x44,0x5b,0x3b]
  trunc.l.s $f3, $f5       # CHECK: trunc.l.s $f3, $f5  # encoding: [0x54,0x65,0x23,0x3b]
  trunc.l.d $f2, $f4       # CHECK: trunc.l.d $f2, $f4  # encoding: [0x54,0x44,0x63,0x3b]
  trunc.w.s $f3, $f5       # CHECK: trunc.w.s $f3, $f5  # encoding: [0x54,0x65,0x2b,0x3b]
  trunc.w.d $f2, $f4       # CHECK: trunc.w.d $f2, $f4  # encoding: [0x54,0x44,0x6b,0x3b]
  sqrt.s $f3, $f5          # CHECK: sqrt.s $f3, $f5     # encoding: [0x54,0x65,0x0a,0x3b]
  sqrt.d $f2, $f4          # CHECK: sqrt.d $f2, $f4     # encoding: [0x54,0x44,0x4a,0x3b]
  rsqrt.s $f3, $f5         # CHECK: rsqrt.s $f3, $f5    # encoding: [0x54,0x65,0x02,0x3b]
  rsqrt.d $f2, $f4         # CHECK: rsqrt.d $f2, $f4    # encoding: [0x54,0x44,0x42,0x3b]
  lw $3, -260($gp)         # CHECK: lw $3, -260($gp)    # encoding: [0xfc,0x7c,0xfe,0xfc]
  lw $3, -256($gp)         # CHECK: lw $3, -256($gp)    # encoding: [0x65,0xc0]
  lw $3, 32($gp)           # CHECK: lw $3, 32($gp)      # encoding: [0x65,0x88]
  lw $3, 252($gp)          # CHECK: lw $3, 252($gp)     # encoding: [0x65,0xbf]
  lw $3, 256($gp)          # CHECK: lw $3, 256($gp)     # encoding: [0xfc,0x7c,0x01,0x00]
  lw $3, 24($sp)           # CHECK: lw $3, 24($sp)      # encoding: [0x48,0x66]
  lw $3, 124($sp)          # CHECK: lw $3, 124($sp)     # encoding: [0x48,0x7f]
  lw $3, 128($sp)          # CHECK: lw $3, 128($sp)     # encoding: [0xfc,0x7d,0x00,0x80]
  lw16 $4, 8($17)          # CHECK: lw16 $4, 8($17)     # encoding: [0x6a,0x12]
  lhu16 $3, 4($16)         # CHECK: lhu16 $3, 4($16)    # encoding: [0x29,0x82]
  lbu16 $3, 4($17)         # CHECK: lbu16 $3, 4($17)    # encoding: [0x09,0x94]
  lbu16 $3, -1($17)        # CHECK: lbu16 $3, -1($17)   # encoding: [0x09,0x9f]
  sb  $4, 6($5)            # CHECK: sb  $4, 6($5)       # encoding: [0x18,0x85,0x00,0x06]
  sbe $4, 6($5)            # CHECK: sbe $4, 6($5)       # encoding: [0x60,0x85,0xa8,0x06]
  sce $4, 6($5)            # CHECK: sce $4, 6($5)       # encoding: [0x60,0x85,0xac,0x06]
  sh $4, 6($5)             # CHECK: sh $4, 6($5)        # encoding: [0x38,0x85,0x00,0x06]
  she $4, 6($5)            # CHECK: she $4, 6($5)       # encoding: [0x60,0x85,0xaa,0x06]
  lle $4, 6($5)            # CHECK: lle $4, 6($5)       # encoding: [0x60,0x85,0x6c,0x06]
  lwe $4, 6($5)            # CHECK: lwe $4, 6($5)       # encoding: [0x60,0x85,0x6e,0x06]
  lw $4, 6($5)             # CHECK: lw $4, 6($5)        # encoding: [0xfc,0x85,0x00,0x06]
  lui $6, 17767            # CHECK: lui $6, 17767       # encoding: [0x10,0xc0,0x45,0x67]
  addu16 $6, $17, $4       # CHECK: addu16 $6, $17, $4  # encoding: [0x04,0xcc]
  and16 $16, $2            # CHECK: and16 $16, $2       # encoding: [0x44,0x21]
  andi16 $4, $5, 8         # CHECK: andi16 $4, $5, 8    # encoding: [0x2e,0x56]
  not16 $4, $7             # CHECK: not16 $4, $7        # encoding: [0x46,0x70]
  or16 $3, $7              # CHECK: or16 $3, $7         # encoding: [0x45,0xf9]
  sll16 $3, $6, 8          # CHECK: sll16 $3, $6, 8     # encoding: [0x25,0xe0]
  srl16 $3, $6, 8          # CHECK: srl16 $3, $6, 8     # encoding: [0x25,0xe1]
  prefe 1, 8($5)           # CHECK: prefe 1, 8($5)      # encoding: [0x60,0x25,0xa4,0x08]
  cachee 1, 8($5)          # CHECK: cachee 1, 8($5)     # encoding: [0x60,0x25,0xa6,0x08]
  teq $8, $9               # CHECK: teq $8, $9          # encoding: [0x01,0x28,0x00,0x3c]
  teq $5, $7, 15           # CHECK: teq $5, $7, 15      # encoding: [0x00,0xe5,0xf0,0x3c]
  tge $7, $10              # CHECK: tge $7, $10         # encoding: [0x01,0x47,0x02,0x3c]
  tge $7, $19, 15          # CHECK: tge $7, $19, 15     # encoding: [0x02,0x67,0xf2,0x3c]
  tgeu $22, $gp            # CHECK: tgeu $22, $gp       # encoding: [0x03,0x96,0x04,0x3c]
  tgeu $20, $14, 15        # CHECK: tgeu $20, $14, 15   # encoding: [0x01,0xd4,0xf4,0x3c]
  tlt $15, $13             # CHECK: tlt $15, $13        # encoding: [0x01,0xaf,0x08,0x3c]
  tlt $2, $19, 15          # CHECK: tlt $2, $19, 15     # encoding: [0x02,0x62,0xf8,0x3c]
  tltu $11, $16            # CHECK: tltu $11, $16       # encoding: [0x02,0x0b,0x0a,0x3c]
  tltu $16, $sp, 15        # CHECK: tltu $16, $sp, 15   # encoding: [0x03,0xb0,0xfa,0x3c]
  tne $6, $17              # CHECK: tne $6, $17         # encoding: [0x02,0x26,0x0c,0x3c]
  tne $7, $8, 15           # CHECK: tne $7, $8, 15      # encoding: [0x01,0x07,0xfc,0x3c]
  break16 8                # CHECK: break16 8           # encoding: [0x46,0x1b]
  li16 $3, -1              # CHECK: li16 $3, -1         # encoding: [0xed,0xff]
  move16 $3, $5            # CHECK: move16 $3, $5       # encoding: [0x0c,0x65]
  sdbbp16 8                # CHECK: sdbbp16 8           # encoding: [0x46,0x3b]
  subu16 $5, $16, $3       # CHECK: subu16 $5, $16, $3  # encoding: [0x04,0x3b]
  xor16 $17, $5            # CHECK: xor16 $17, $5       # encoding: [0x44,0xd8]
  lb $4, 8($5)             # CHECK: lb $4, 8($5)        # encoding: [0x1c,0x85,0x00,0x08]
  lbu $4, 8($5)            # CHECK: lbu $4, 8($5)       # encoding: [0x14,0x85,0x00,0x08]
  lbe $4, 8($5)            # CHECK: lbe $4, 8($5)       # encoding: [0x60,0x85,0x68,0x08]
  lbue $4, 8($5)           # CHECK: lbue $4, 8($5)      # encoding: [0x60,0x85,0x60,0x08]
  recip.s $f2, $f4         # CHECK: recip.s $f2, $f4    # encoding: [0x54,0x44,0x12,0x3b]
  recip.d $f2, $f4         # CHECK: recip.d $f2, $f4    # encoding: [0x54,0x44,0x52,0x3b]
  rint.s $f2, $f4          # CHECK: rint.s $f2, $f4     # encoding: [0x54,0x82,0x00,0x20]
  rint.d $f2, $f4          # CHECK: rint.d $f2, $f4     # encoding: [0x54,0x82,0x02,0x20]
  round.l.s $f2, $f4       # CHECK: round.l.s $f2, $f4  # encoding: [0x54,0x44,0x33,0x3b]
  round.l.d $f2, $f4       # CHECK: round.l.d $f2, $f4  # encoding: [0x54,0x44,0x73,0x3b]
  round.w.s $f2, $f4       # CHECK: round.w.s $f2, $f4  # encoding: [0x54,0x44,0x3b,0x3b]
  round.w.d $f2, $f4       # CHECK: round.w.d $f2, $f4  # encoding: [0x54,0x44,0x7b,0x3b]
  sel.s $f1, $f1, $f2      # CHECK: sel.s $f1, $f1, $f2 # encoding: [0x54,0x41,0x08,0xb8]
  sel.d $f0, $f2, $f4      # CHECK: sel.d $f0, $f2, $f4 # encoding: [0x54,0x82,0x02,0xb8]
  seleqz.s $f1, $f2, $f3   # CHECK: seleqz.s $f1, $f2, $f3 # encoding: [0x54,0x62,0x08,0x38]
  seleqz.d $f2, $f4, $f8   # CHECK: seleqz.d $f2, $f4, $f8 # encoding: [0x55,0x04,0x12,0x38]
  selnez.s $f1, $f2, $f3   # CHECK: selnez.s $f1, $f2, $f3 # encoding: [0x54,0x62,0x08,0x78]
  selnez.d $f2, $f4, $f8   # CHECK: selnez.d $f2, $f4, $f8 # encoding: [0x55,0x04,0x12,0x78]
  slt $3, $4, $5           # CHECK: slt $3, $4, $5         # encoding: [0x00,0xa4,0x1b,0x50]
  slti $3, $4, 256         # CHECK: slti $3, $4, 256       # encoding: [0x90,0x64,0x01,0x00]
  sltiu $3, $4, 256        # CHECK: sltiu $3, $4, 256      # encoding: [0xb0,0x64,0x01,0x00]
  sltu $3, $4, $5          # CHECK: sltu $3, $4, $5        # encoding: [0x00,0xa4,0x1b,0x90]
  class.s $f2, $f3         # CHECK: class.s $f2, $f3       # encoding: [0x54,0x62,0x00,0x60]
  class.d $f2, $f4         # CHECK: class.d $f2, $f4       # encoding: [0x54,0x82,0x02,0x60]
  deret                    # CHECK: deret                  # encoding: [0x00,0x00,0xe3,0x7c]
  tlbinv                   # CHECK: tlbinv                 # encoding: [0x00,0x00,0x43,0x7c]
  tlbinvf                  # CHECK: tlbinvf                # encoding: [0x00,0x00,0x53,0x7c]
  mtc0 $5, $9              # CHECK: mtc0 $5, $9, 0         # encoding: [0x00,0xa9,0x02,0xfc]
  mtc0 $1, $2, 7           # CHECK: mtc0 $1, $2, 7         # encoding: [0x00,0x22,0x3a,0xfc]
  mtc1 $3, $f4             # CHECK: mtc1 $3, $f4           # encoding: [0x54,0x64,0x28,0x3b]
  mtc2 $5, $6              # CHECK: mtc2 $5, $6            # encoding: [0x00,0xa6,0x5d,0x3c]
  mthc0 $7, $8             # CHECK: mthc0 $7, $8, 0        # encoding: [0x00,0xe8,0x02,0xf4]
  mthc0 $9, $10, 1         # CHECK: mthc0 $9, $10, 1       # encoding: [0x01,0x2a,0x0a,0xf4]
  mthc1 $11, $f12          # CHECK: mthc1 $11, $f12        # encoding: [0x55,0x6c,0x38,0x3b]
  mthc2 $13, $14           # CHECK: mthc2 $13, $14         # encoding: [0x01,0xae,0x9d,0x3c]
  mfc0 $3, $7              # CHECK: mfc0 $3, $7, 0         # encoding: [0x00,0x67,0x00,0xfc]
  mfc0 $3, $7, 3           # CHECK: mfc0 $3, $7, 3         # encoding: [0x00,0x67,0x18,0xfc]
  mfc1 $5, $f10            # CHECK: mfc1 $5, $f10          # encoding: [0x54,0xaa,0x20,0x3b]
  mfc2 $15, $5             # CHECK: mfc2 $15, $5           # encoding: [0x01,0xe5,0x4d,0x3c]
  mfhc0 $20, $21           # CHECK: mfhc0 $20, $21, 0      # encoding: [0x02,0x95,0x00,0xf4]
  mfhc0 $1, $2, 1          # CHECK: mfhc0 $1, $2, 1        # encoding: [0x00,0x22,0x08,0xf4]
  mfhc1 $zero, $f6         # CHECK: mfhc1 $zero, $f6       # encoding: [0x54,0x06,0x30,0x3b]
  mfhc2 $23, $16           # CHECK: mfhc2 $23, $16         # encoding: [0x02,0xf0,0x8d,0x3c]
  tlbp                     # CHECK: tlbp                   # encoding: [0x00,0x00,0x03,0x7c]
  tlbr                     # CHECK: tlbr                   # encoding: [0x00,0x00,0x13,0x7c]
  tlbwi                    # CHECK: tlbwi                  # encoding: [0x00,0x00,0x23,0x7c]
  tlbwr                    # CHECK: tlbwr                  # encoding: [0x00,0x00,0x33,0x7c]
  dvp                      # CHECK: dvp $zero              # encoding: [0x00,0x00,0x19,0x7c]
  dvp $4                   # CHECK: dvp $4                 # encoding: [0x00,0x04,0x19,0x7c]
  evp                      # CHECK: evp $zero              # encoding: [0x00,0x00,0x39,0x7c]
  evp $4                   # CHECK: evp $4                 # encoding: [0x00,0x04,0x39,0x7c]
  jalrc.hb $4              # CHECK: jalrc.hb $4            # encoding: [0x03,0xe4,0x1f,0x3c]
  jalrc.hb $4, $5          # CHECK: jalrc.hb $4, $5        # encoding: [0x00,0x85,0x1f,0x3c]
  sllv $2, $3, $5          # CHECK: sllv $2, $3, $5        # encoding: [0x00,0x65,0x10,0x10]
  sra $4, $3, 7            # CHECK: sra $4, $3, 7          # encoding: [0x00,0x83,0x38,0x80]
  srav $2, $3, $5          # CHECK: srav $2, $3, $5        # encoding: [0x00,0x65,0x10,0x90]
  srl $4, $3, 7            # CHECK: srl $4, $3, 7          # encoding: [0x00,0x83,0x38,0x40]
  srlv $2, $3, $5          # CHECK: srlv $2, $3, $5        # encoding: [0x00,0x65,0x10,0x50]
  sll $2, $3, $5           # CHECK: sllv $2, $3, $5        # encoding: [0x00,0x65,0x10,0x10]
  sra $2, $3, $5           # CHECK: srav $2, $3, $5        # encoding: [0x00,0x65,0x10,0x90]
  srl $2, $3, $5           # CHECK: srlv $2, $3, $5        # encoding: [0x00,0x65,0x10,0x50]
  sll $2, $3               # CHECK: sllv $2, $2, $3        # encoding: [0x00,0x43,0x10,0x10]
  sra $2, $3               # CHECK: srav $2, $2, $3        # encoding: [0x00,0x43,0x10,0x90]
  srl $2, $3               # CHECK: srlv $2, $2, $3        # encoding: [0x00,0x43,0x10,0x50]
  sll $3, 7                # CHECK: sll $3, $3, 7          # encoding: [0x00,0x63,0x38,0x00]
  sra $3, 7                # CHECK: sra $3, $3, 7          # encoding: [0x00,0x63,0x38,0x80]
  srl $3, 7                # CHECK: srl $3, $3, 7          # encoding: [0x00,0x63,0x38,0x40]
  lwp $16, 8($4)           # CHECK: lwp $16, 8($4)         # encoding: [0x22,0x04,0x10,0x08]
  swp $16, 8($4)           # CHECK: swp $16, 8($4)         # encoding: [0x22,0x04,0x90,0x08]
  bc1eqzc $f31, 4          # CHECK: bc1eqzc $f31, 4        # encoding: [0x41,0x1f,0x00,0x02]
  bc1nezc $f31, 4          # CHECK: bc1nezc $f31, 4        # encoding: [0x41,0x3f,0x00,0x02]
  bc2eqzc $31, 8           # CHECK: bc2eqzc $31, 8         # encoding: [0x41,0x5f,0x00,0x04]
  bc2nezc $31, 8           # CHECK: bc2nezc $31, 8         # encoding: [0x41,0x7f,0x00,0x04]
  ins $9, $6, 3, 7         # CHECK: ins $9, $6, 3, 7       # encoding: [0x01,0x26,0x48,0xcc]
  jalrc $4, $5             # CHECK: jalrc $4, $5           # encoding: [0x00,0x85,0x0f,0x3c]
  jalrc $5                 # CHECK: jalrc $5               # encoding: [0x03,0xe5,0x0f,0x3c]
  ext $9, $6, 3, 7         # CHECK: ext $9, $6, 3, 7       # encoding: [0x01,0x26,0x30,0xec]
  bovc $2, $4, 24          # CHECK: bovc $2, $4, 24        # encoding: [0x74,0x44,0x00,0x0c]
  bovc $4, $2, 24          # CHECK: bovc $4, $2, 24        # encoding: [0x74,0x44,0x00,0x0c]
  bnvc $2, $4, 24          # CHECK: bnvc $2, $4, 24        # encoding: [0x7c,0x44,0x00,0x0c]
  bnvc $4, $2, 24          # CHECK: bnvc $4, $2, 24        # encoding: [0x7c,0x44,0x00,0x0c]
  and $3, 5                # CHECK: andi $3, $3, 5         # encoding: [0xd0,0x63,0x00,0x05]
  and $3, $4, 5            # CHECK: andi $3, $4, 5         # encoding: [0xd0,0x64,0x00,0x05]
  not $3, $4               # CHECK: not $3, $4             # encoding: [0x00,0x04,0x1a,0xd0]
  not $3                   # CHECK: not $3, $3             # encoding: [0x00,0x03,0x1a,0xd0]
  or $3, 5                 # CHECK: ori $3, $3, 5          # encoding: [0x50,0x63,0x00,0x05]
  or $3, $4, 5             # CHECK: ori $3, $4, 5          # encoding: [0x50,0x64,0x00,0x05]
  xor $3, 5                # CHECK: xori $3, $3, 5         # encoding: [0x70,0x63,0x00,0x05]
  xor $3, $4, 5            # CHECK: xori $3, $4, 5         # encoding: [0x70,0x64,0x00,0x05]
  ldc1 $f7, 300($10)       # CHECK: ldc1 $f7, 300($10)     # encoding: [0xbc,0xea,0x01,0x2c]
  ldc1 $f8, 300($10)       # CHECK: ldc1 $f8, 300($10)     # encoding: [0xbd,0x0a,0x01,0x2c]
  ldc2 $11, 1023($12)      # CHECK: ldc2 $11, 1023($12)    # encoding: [0x21,0x6c,0x23,0xff]
  lwc1 $f2, 32($5)         # CHECK: lwc1 $f2, 32($5)       # encoding: [0x9c,0x45,0x00,0x20]
  lwc2 $1, 16($4)          # CHECK: lwc2 $1, 16($4)        # encoding: [0x20,0x24,0x00,0x10]
  sdc1 $f7, 64($10)        # CHECK: sdc1 $f7, 64($10)      # encoding: [0xb8,0xea,0x00,0x40]
  sdc1 $f8, 64($10)        # CHECK: sdc1 $f8, 64($10)      # encoding: [0xb9,0x0a,0x00,0x40]
  sdc2 $2, 8($16)          # CHECK: sdc2 $2, 8($16)        # encoding: [0x20,0x50,0xa0,0x08]
  swc1 $f6, 369($13)       # CHECK: swc1 $f6, 369($13)     # encoding: [0x98,0xcd,0x01,0x71]
  swc2 $7, 777($17)        # CHECK: swc2 $7, 777($17)      # encoding: [0x20,0xf1,0x83,0x09]
  cfc1 $1, $2              # CHECK: cfc1 $1, $2            # encoding: [0x54,0x22,0x10,0x3b]
  cfc2 $3, $4              # CHECK: cfc2 $3, $4            # encoding: [0x00,0x64,0xcd,0x3c]
  ctc1 $5, $6              # CHECK: ctc1 $5, $6            # encoding: [0x54,0xa6,0x18,0x3b]
  ctc2 $7, $8              # CHECK: ctc2 $7, $8            # encoding: [0x00,0xe8,0xdd,0x3c]
  bltzc $6, 128            # CHECK: bltzc $6, 128          # encoding: [0xd4,0xc6,0x00,0x20]
  blezc $2, 256            # CHECK: blezc $2, 256          # encoding: [0xf4,0x40,0x00,0x40]
  bgezc $16, 512           # CHECK: bgezc $16, 512         # encoding: [0xf6,0x10,0x00,0x80]
  bgtzc $12, 1024          # CHECK: bgtzc $12, 1024        # encoding: [0xd5,0x80,0x01,0x00]
