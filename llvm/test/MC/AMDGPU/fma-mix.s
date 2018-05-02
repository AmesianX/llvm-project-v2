// RUN: llvm-mc -arch=amdgcn -mcpu=gfx904 -show-encoding %s | FileCheck -check-prefix=GFX9-FMAMIX %s
// RUN: llvm-mc -arch=amdgcn -mcpu=gfx906 -show-encoding %s | FileCheck -check-prefix=GFX9-FMAMIX %s
// RUN: not llvm-mc -arch=amdgcn -mcpu=gfx900 -show-encoding %s 2>&1 | FileCheck -check-prefix=GFX9-MADMIX-ERR %s

v_fma_mix_f32 v0, v1, v2, v3
// GFX9-FMAMIX: v_fma_mix_f32 v0, v1, v2, v3 ; encoding: [0x00,0x00,0xa0,0xd3,0x01,0x05,0x0e,0x04]
// GFX9-MADMIX-ERR: error: instruction not supported on this GPU

v_fma_mixlo_f16 v0, v1, v2, v3
// GFX9-FMAMIX: v_fma_mixlo_f16 v0, v1, v2, v3 ; encoding: [0x00,0x00,0xa1,0xd3,0x01,0x05,0x0e,0x04]
// GFX9-MADMIX-ERR: error: instruction not supported on this GPU

v_fma_mixhi_f16 v0, v1, v2, v3
// GFX9-FMAMIX: v_fma_mixhi_f16 v0, v1, v2, v3 ; encoding: [0x00,0x00,0xa2,0xd3,0x01,0x05,0x0e,0x04]
// GFX9-MADMIX-ERR: error: instruction not supported on this GPU

//
// Regular source modifiers on non-packed instructions
//

v_fma_mix_f32 v0, abs(v1), v2, v3
// GFX9-FMAMIX: v_fma_mix_f32 v0, |v1|, v2, v3 ; encoding: [0x00,0x01,0xa0,0xd3,0x01,0x05,0x0e,0x04]

// FIXME: Better error
// GFX9-MADMIX-ERR: error: invalid operand for instruction

v_fma_mix_f32 v0, v1, abs(v2), v3
// GFX9-FMAMIX: v_fma_mix_f32 v0, v1, |v2|, v3 ; encoding: [0x00,0x02,0xa0,0xd3,0x01,0x05,0x0e,0x04]

v_fma_mix_f32 v0, v1, v2, abs(v3)
// GFX9-FMAMIX: v_fma_mix_f32 v0, v1, v2, |v3| ; encoding: [0x00,0x04,0xa0,0xd3,0x01,0x05,0x0e,0x04]

v_fma_mix_f32 v0, -v1, v2, v3
// GFX9-FMAMIX: v_fma_mix_f32 v0, -v1, v2, v3 ; encoding: [0x00,0x00,0xa0,0xd3,0x01,0x05,0x0e,0x24]

v_fma_mix_f32 v0, v1, -v2, v3
// GFX9-FMAMIX: v_fma_mix_f32 v0, v1, -v2, v3 ; encoding: [0x00,0x00,0xa0,0xd3,0x01,0x05,0x0e,0x44]

v_fma_mix_f32 v0, v1, v2, -v3
// GFX9-FMAMIX: v_fma_mix_f32 v0, v1, v2, -v3 ; encoding: [0x00,0x00,0xa0,0xd3,0x01,0x05,0x0e,0x84]

v_fma_mix_f32 v0, -abs(v1), v2, v3
// GFX9-FMAMIX: v_fma_mix_f32 v0, -|v1|, v2, v3 ; encoding: [0x00,0x01,0xa0,0xd3,0x01,0x05,0x0e,0x24]

v_fma_mix_f32 v0, v1, -abs(v2), v3
// GFX9-FMAMIX: v_fma_mix_f32 v0, v1, -|v2|, v3 ; encoding: [0x00,0x02,0xa0,0xd3,0x01,0x05,0x0e,0x44]

v_fma_mix_f32 v0, v1, v2, -abs(v3)
// GFX9-FMAMIX: v_fma_mix_f32 v0, v1, v2, -|v3| ; encoding: [0x00,0x04,0xa0,0xd3,0x01,0x05,0x0e,0x84]

v_fma_mixlo_f16 v0, abs(v1), -v2, abs(v3)
// GFX9-FMAMIX: v_fma_mixlo_f16 v0, |v1|, -v2, |v3| ; encoding: [0x00,0x05,0xa1,0xd3,0x01,0x05,0x0e,0x44]

v_fma_mixhi_f16 v0, -v1, abs(v2), -abs(v3)
// GFX9-FMAMIX: v_fma_mixhi_f16 v0, -v1, |v2|, -|v3| ; encoding: [0x00,0x06,0xa2,0xd3,0x01,0x05,0x0e,0xa4]

v_fma_mixlo_f16 v0, v1, v2, v3 clamp
// GFX9-FMAMIX: v_fma_mixlo_f16 v0, v1, v2, v3  clamp ; encoding: [0x00,0x80,0xa1,0xd3,0x01,0x05,0x0e,0x04]

v_fma_mixhi_f16 v0, v1, v2, v3 clamp
// GFX9-FMAMIX: v_fma_mixhi_f16 v0, v1, v2, v3  clamp ; encoding: [0x00,0x80,0xa2,0xd3,0x01,0x05,0x0e,0x04]

//
// op_sel with non-packed instructions
//

v_fma_mix_f32 v0, v1, v2, v3 op_sel:[0,0,0]
// GFX9-FMAMIX: v_fma_mix_f32 v0, v1, v2, v3 ; encoding: [0x00,0x00,0xa0,0xd3,0x01,0x05,0x0e,0x04]
// FIXME: Better error
// GFX-MADMIX-ERR: error: unknown token in expression

v_fma_mix_f32 v0, v1, v2, v3 op_sel:[1,0,0]
// GFX9-FMAMIX: v_fma_mix_f32 v0, v1, v2, v3 op_sel:[1,0,0] ; encoding: [0x00,0x08,0xa0,0xd3,0x01,0x05,0x0e,0x04]

v_fma_mix_f32 v0, v1, v2, v3 op_sel:[0,1,0]
// GFX9-FMAMIX: v_fma_mix_f32 v0, v1, v2, v3 op_sel:[0,1,0] ; encoding: [0x00,0x10,0xa0,0xd3,0x01,0x05,0x0e,0x04]

v_fma_mix_f32 v0, v1, v2, v3 op_sel:[0,0,1]
// GFX9-FMAMIX: v_fma_mix_f32 v0, v1, v2, v3 op_sel:[0,0,1] ; encoding: [0x00,0x20,0xa0,0xd3,0x01,0x05,0x0e,0x04]

v_fma_mix_f32 v0, v1, v2, v3 op_sel:[1,1,1]
// GFX9-FMAMIX: v_fma_mix_f32 v0, v1, v2, v3 op_sel:[1,1,1] ; encoding: [0x00,0x38,0xa0,0xd3,0x01,0x05,0x0e,0x04]

v_fma_mix_f32 v0, v1, v2, v3
// GFX9-FMAMIX: v_fma_mix_f32 v0, v1, v2, v3 ; encoding: [0x00,0x00,0xa0,0xd3,0x01,0x05,0x0e,0x04]

v_fma_mix_f32 v0, v1, v2, v3 op_sel_hi:[1,0,0]
// GFX9-FMAMIX: v_fma_mix_f32 v0, v1, v2, v3 op_sel_hi:[1,0,0] ; encoding: [0x00,0x00,0xa0,0xd3,0x01,0x05,0x0e,0x0c]

v_fma_mix_f32 v0, v1, v2, v3 op_sel_hi:[0,1,0]
// GFX9-FMAMIX: v_fma_mix_f32 v0, v1, v2, v3 op_sel_hi:[0,1,0] ; encoding: [0x00,0x00,0xa0,0xd3,0x01,0x05,0x0e,0x14]

v_fma_mix_f32 v0, v1, v2, v3 op_sel_hi:[0,0,1]
// GFX9-FMAMIX: v_fma_mix_f32 v0, v1, v2, v3 op_sel_hi:[0,0,1] ; encoding: [0x00,0x40,0xa0,0xd3,0x01,0x05,0x0e,0x04]

v_fma_mix_f32 v0, v1, v2, v3 op_sel_hi:[1,1,1]
// GFX9-FMAMIX: v_fma_mix_f32 v0, v1, v2, v3 op_sel_hi:[1,1,1] ; encoding: [0x00,0x40,0xa0,0xd3,0x01,0x05,0x0e,0x1c]

v_fma_mixlo_f16 v0, v1, v2, v3 op_sel_hi:[1,0,1] clamp
// GFX9-FMAMIX: v_fma_mixlo_f16 v0, v1, v2, v3 op_sel_hi:[1,0,1] clamp ; encoding: [0x00,0xc0,0xa1,0xd3,0x01,0x05,0x0e,0x0c]

v_fma_mixhi_f16 v0, v1, v2, v3 op_sel_hi:[1,0,1] clamp
// GFX9-FMAMIX: v_fma_mixhi_f16 v0, v1, v2, v3 op_sel_hi:[1,0,1] clamp ; encoding: [0x00,0xc0,0xa2,0xd3,0x01,0x05,0x0e,0x0c]
