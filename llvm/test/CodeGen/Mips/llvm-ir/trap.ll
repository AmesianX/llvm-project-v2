; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=mips-mti-linux-gnu < %s --show-mc-encoding | FileCheck %s --check-prefix=MTI
; RUN: llc -mtriple=mips-mti-linux-gnu -mattr=+micromips < %s --show-mc-encoding | FileCheck %s --check-prefix=MM
; RUN: llc -mtriple=mips-img-linux-gnu < %s --show-mc-encoding | FileCheck %s --check-prefix=IMG
; RUN: llc -mtriple=mips-img-linux-gnu -mattr=+micromips < %s --show-mc-encoding | FileCheck %s --check-prefix=MMR6

define void @test() noreturn nounwind  {
; MTI-LABEL: test:
; MTI:       # %bb.0: # %entry
; MTI-NEXT:    break # encoding: [0x00,0x00,0x00,0x0d]
; MTI-NEXT:    jr $ra # encoding: [0x03,0xe0,0x00,0x08]
; MTI-NEXT:    nop # encoding: [0x00,0x00,0x00,0x00]
;
; MM-LABEL: test:
; MM:       # %bb.0: # %entry
; MM-NEXT:    break # encoding: [0x00,0x00,0x00,0x07]
; MM-NEXT:    jrc $ra # encoding: [0x45,0xbf]
;
; IMG-LABEL: test:
; IMG:       # %bb.0: # %entry
; IMG-NEXT:    break # encoding: [0x00,0x00,0x00,0x0d]
; IMG-NEXT:    jr $ra # encoding: [0x03,0xe0,0x00,0x08]
; IMG-NEXT:    nop # encoding: [0x00,0x00,0x00,0x00]
;
; MMR6-LABEL: test:
; MMR6:       # %bb.0: # %entry
; MMR6-NEXT:    break # encoding: [0x00,0x00,0x00,0x07]
; MMR6-NEXT:    jrc $ra # encoding: [0x45,0xbf]
entry:
  tail call void @llvm.trap( )
  ret void
}

declare void @llvm.trap() nounwind
