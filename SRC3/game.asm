; Disassembly of "Metroid2.gb"
; This file was created with:
; mgbdis v1.4 - Game Boy ROM disassembler by Matt Currie and contributors.
; https://github.com/mattcurrie/mgbdis

INCLUDE "hardware.inc"

INCLUDE "constants.asm"
INCLUDE "macros.asm"

; RAM definitions
INCLUDE "ram/vram.asm"
INCLUDE "ram/sram.asm"
INCLUDE "ram/wram.asm"
INCLUDE "ram/hram.asm"

; ROM start
INCLUDE "bank_000.asm"
INCLUDE "bank_001.asm"
INCLUDE "bank_002.asm"
INCLUDE "bank_003.asm"
INCLUDE "bank_004.asm"
INCLUDE "bank_005.asm"
INCLUDE "bank_006.asm"
INCLUDE "bank_007.asm"
INCLUDE "bank_008.asm"
; Level Data banks
INCLUDE "maps/bank_009.asm"
INCLUDE "maps/bank_00a.asm"
INCLUDE "maps/bank_00b.asm"
INCLUDE "maps/bank_00c.asm"
INCLUDE "maps/bank_00d.asm"
INCLUDE "maps/bank_00e.asm"
INCLUDE "maps/bank_00f.asm"