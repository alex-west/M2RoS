; SRAM Defines
;;; $A000..BFFF: SRAM ;;;

section "SRAM", sram[$A000], bank[0]

saveData_baseAddr::
saveData1:: ds $40 ;$A000..3F: SRAM slot 1
saveData2:: ds $40 ;$A040..7F: SRAM slot 2
saveData3:: ds $40 ;$A080..BF: SRAM slot 3
;{
;    + 0..7: 0123456789ABCDEF
;    + 8: Samus' Y position
;    + Ah: Samus' X position
;    + Ch: Screen Y position
;    + Eh: Screen X position
;    + 10h: Enemy tiles source address (2 bytes)
;    + 12h: Background tiles source bank
;    + 13h: Background tiles source address (2 bytes)
;    + 15h: Metatile definitions source address (bank 8, 2 bytes)
;    + 17h: Tile properties source address (bank 8, 2 bytes)
;    + 19h: Bank for current room
;    + 1Ah: Samus solid block threshold
;    + 1Bh: Enemy solid block threshold
;    + 1Ch: Projectile solid block threshold
;    + 1Dh: Samus' equipment
;    + 1Eh: Samus' beam
;    + 1Fh: Samus' energy tanks
;    + 20h: Samus' health
;    + 22h: Samus' max missiles
;    + 24h: Samus' missiles
;    + 26h: Direction Samus is facing
;    + 27h: Acid damage
;    + 28h: Spike damage
;    + 29h: Real number of Metroids remaining
;    + 2Ah: Song for room
;    + 2Bh: In-game timer, minutes
;    + 2Ch: In-game timer, hours
;    + 2Dh: Number of Metroids remaining
;      2Eh-3F: Unused
;}

saveLastSlot: ds 1;$A0C0: Last used save slot

; Over $700 bytes of freespace

section "SRAM Credits", sram[$A800], bank[0]
creditsTextBuffer:: ds $800 ; Written to in credits from [$6:7920..7E02]

section "SRAM Object Lists", sram[$B000], bank[0]
; Object permanence lists (per save file)
saveData_objList_baseAddr::
saveData1_objList: ds $200 ;$B000..B1BF: SRAM slot 1
saveData2_objList: ds $200 ;$B200..B3BF: SRAM slot 2
saveData3_objList: ds $200 ;$B400..B5BF: SRAM slot 3
; $40 bytes per map, 7 maps ($40 unused between files)
; Enough leftover space to easily handle 16 maps worth of save data (WRAM permitting)

; $BFFF - End of SRAM
; EoF