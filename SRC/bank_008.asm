; Disassembly of "Metroid2.gb"
; This file was created with:
; mgbdis v1.4 - Game Boy ROM disassembler by Matt Currie and contributors.
; https://github.com/mattcurrie/mgbdis

SECTION "ROM Bank $008", ROMX[$4000], BANK[$8]

bg_queenHead::
    db $b0, $b1, $b2, $b3, $b4, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
bg_queenHeadRow2::
    db $c0, $c1, $c2, $c3, $c4, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
bg_queenHeadRow3::
    db $d0, $d1, $d2, $d3, $d4, $d5, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
bg_queenHeadRow4::
    db $e2, $e3, $e4, $e5, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

collision_finalLab:     include "tilesets/collision/collision_finalLab.asm"
collision_plantBubbles: include "tilesets/collision/collision_plantBubbles.asm"
collision_ruinsInside:  include "tilesets/collision/collision_ruinsInside.asm"
collision_queen:        include "tilesets/collision/collision_queen.asm"
collision_caveFirst:    include "tilesets/collision/collision_caveFirst.asm"
collision_surface:      include "tilesets/collision/collision_surface.asm"
collision_lavaCaves:    include "tilesets/collision/collision_lavaCaves.asm"
collision_ruinsExt:     include "tilesets/collision/collision_ruinsExt.asm"

metatiles_plantBubbles:   include "tilesets/metatiles/metatiles_plantBubbles.asm"
metatiles_ruinsInside:    include "tilesets/metatiles/metatiles_ruinsInside.asm"
metatiles_finalLab:       include "tilesets/metatiles/metatiles_finalLab.asm"
metatiles_queen:          include "tilesets/metatiles/metatiles_queen.asm"
metatiles_caveFirst:      include "tilesets/metatiles/metatiles_caveFirst.asm"
metatiles_surface:        include "tilesets/metatiles/metatiles_surface.asm"
metatiles_lavaCavesMid:   include "tilesets/metatiles/metatiles_lavaCavesMid.asm"   
metatiles_lavaCavesEmpty: include "tilesets/metatiles/metatiles_lavaCavesEmpty.asm"
metatiles_lavaCavesFull:  include "tilesets/metatiles/metatiles_lavaCavesFull.asm"
metatiles_ruinsExt:       include "tilesets/metatiles/metatiles_ruinsExt.asm"

gfx_metAlpha:: include "gfx/enemies/gfx_metAlpha.asm"
gfx_metGamma:: include "gfx/enemies/gfx_metGamma.asm"
gfx_metZeta::  include "gfx/enemies/gfx_metZeta.asm"
gfx_metOmega:: include "gfx/enemies/gfx_metOmega.asm"
gfx_ruinsExt:: include "tilesets/gfx_ruinsExt.asm"
gfx_finalLab:: include "tilesets/gfx_finalLab.asm"
gfx_queenSPR:: include "gfx/enemies/gfx_queenSPR.asm"

;;; 8:7EBC: Check if killed target number of metroids ;;;
earthquakeCheck::
    ld hl, earthquakeThresholds
	
    .loop:
	    ; If we have reached the end of earthquakeThresholds, then return
	    ld a, [hl+]
        cp $ff
	    jr z, .return

	    ; If metroidCountReal = earthquakeThresholds[hl], then branch ahead to set the timer
        ld b, a
        ld a, [metroidCountReal]
        cp b
        jr z, .setTimer
    jr .loop

.setTimer:
; If more than 1 Metroid is left, set timer to 3 and exit
    ld a, $03
    ld [earthquakeTimer], a
    ld a, [metroidCountReal]
    cp $01
    ret nz

; If only 1 metroid (the queen) is left, set timer to 1
    ld a, $01
    ld [earthquakeTimer], a
.return:
    ret

; Earthquake threshholds (terminated with $FF)
earthquakeThresholds:
    db $46, $42, $34, $24, $23, $21, $14, $13, $12, $09, $01, $ff
	
; 8:7EEA - Collision Table Pointers
collisionPointerTable::
    dw collision_plantBubbles ; 0
    dw collision_ruinsInside  ; 1
    dw collision_queen        ; 2
    dw collision_caveFirst    ; 3
    dw collision_surface      ; 4
    dw collision_lavaCaves    ; 5
    dw collision_ruinsExt     ; 6
    dw collision_finalLab     ; 7

; 8:7EFA Solidity threshholds
solidityIndexTable::
    db $69, $63, $6e, $ff ; 0 - plantBubbles
    db $5e, $54, $5e, $ff ; 1 - ruinsInside
    db $f0, $f0, $f0, $ff ; 2 - queen
    db $63, $5d, $63, $ff ; 3 - caveFirst
    db $69, $69, $69, $ff ; 4 - surface
    db $42, $42, $42, $ff ; 5 - lavaCaves
    db $5c, $54, $64, $ff ; 6 - ruinsExt
    db $75, $75, $75, $ff ; 7 - finalLab

; 8:7F1A Metatile definition pointers
metatilePointerTable::
    dw metatiles_finalLab       ; 0 - 2
    dw metatiles_ruinsInside    ; 1 - 1
    dw metatiles_plantBubbles   ; 2 - 0
    dw metatiles_queen          ; 3 - 3
    dw metatiles_caveFirst      ; 4 - 4
    dw metatiles_surface        ; 5 - 5
    dw metatiles_lavaCavesEmpty ; 6 - 7
    dw metatiles_lavaCavesFull  ; 7 - 8
    dw metatiles_lavaCavesMid   ; 8 - 6
    dw metatiles_ruinsExt       ; 9 - 9

; 7:7B90 - Freespace (filled with $00)
