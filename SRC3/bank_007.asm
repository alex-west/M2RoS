; Disassembly of "Metroid2.gb"
; This file was created with:
; mgbdis v1.4 - Game Boy ROM disassembler by Matt Currie and contributors.
; https://github.com/mattcurrie/mgbdis

SECTION "ROM Bank $007", ROMX[$4000], BANK[$7]

gfx_plantBubbles:: incbin "tilesets/plantBubbles.chr",0,$800
gfx_ruinsInside::  incbin "tilesets/ruinsInside.chr", 0,$800
gfx_queenBG::      incbin "tilesets/queenBG.chr",     0,$800
gfx_caveFirst::    incbin "tilesets/caveFirst.chr",   0,$800
gfx_surfaceBG::    incbin "tilesets/surfaceBG.chr",   0,$800
gfx_lavaCavesA::   incbin "tilesets/lavaCavesA.chr",  0,$530
gfx_lavaCavesB::   incbin "tilesets/lavaCavesB.chr",  0,$530
gfx_lavaCavesC::   incbin "tilesets/lavaCavesC.chr",  0,$530

; 7:7790 - Item graphics (0x40 each)
; Plasma Beam, Ice Beam, Wave Beam, Spazer Beam
; Bombs, Screw Attack, Varia Suit, High Jump Boots
; Space Jump, Spider Ball, Spring Ball
gfx_items:: incbin "gfx/items.chr"

; 7:7A50 - Item Orb
gfx_itemOrb:: incbin "gfx/itemOrb.chr"

; 7:7A90 - Missile Tank, Door, Missile Block, Refills
gfx_commonItems:: incbin "gfx/commonItems.chr"

bank7_freespace: ; 7:7B90 -- Freespace
