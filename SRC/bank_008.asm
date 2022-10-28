; Disassembly of "Metroid2.gb"
; This file was created with:
; mgbdis v1.4 - Game Boy ROM disassembler by Matt Currie and contributors.
; https://github.com/mattcurrie/mgbdis

SECTION "ROM Bank $008", ROMX[$4000], BANK[$8]

bg_queenHead::
.row1:
    db $b0, $b1, $b2, $b3, $b4, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
.row2: ;bg_queenHeadRow2::
    db $c0, $c1, $c2, $c3, $c4, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
.row3: ;bg_queenHeadRow3::
    db $d0, $d1, $d2, $d3, $d4, $d5, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
.row4: ;bg_queenHeadRow4::
    db $e2, $e3, $e4, $e5, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

collision_finalLab:     include "tilesets/finalLab_collision.asm"
collision_plantBubbles: include "tilesets/plantBubbles_collision.asm"
collision_ruinsInside:  include "tilesets/ruinsInside_collision.asm"
collision_queen:        include "tilesets/queen_collision.asm"
collision_caveFirst:    include "tilesets/caveFirst_collision.asm"
collision_surface:      include "tilesets/surface_collision.asm"
collision_lavaCaves:    include "tilesets/lavaCaves_collision.asm"
collision_ruinsExt:     include "tilesets/ruinsExt_collision.asm"

metatiles_plantBubbles:   include "tilesets/plantBubbles_metatiles.asm"
metatiles_ruinsInside:    include "tilesets/ruinsInside_metatiles.asm"
metatiles_finalLab:       include "tilesets/finalLab_metatiles.asm"
metatiles_queen:          include "tilesets/queen_metatiles.asm"
metatiles_caveFirst:      include "tilesets/caveFirst_metatiles.asm"
metatiles_surface:        include "tilesets/surface_metatiles.asm"
metatiles_lavaCavesMid:   include "tilesets/lavaCavesMid_metatiles.asm"
metatiles_lavaCavesEmpty: include "tilesets/lavaCavesEmpty_metatiles.asm"
metatiles_lavaCavesFull:  include "tilesets/lavaCavesFull_metatiles.asm"
metatiles_ruinsExt:       include "tilesets/ruinsExt_metatiles.asm"

gfx_metAlpha:: incbin "gfx/enemies/metAlpha.chr",0,$400
gfx_metGamma:: incbin "gfx/enemies/metGamma.chr",0,$400
gfx_metZeta::  incbin "gfx/enemies/metZeta.chr",0,$400
gfx_metOmega:: incbin "gfx/enemies/metOmega.chr",0,$400
gfx_ruinsExt:: incbin "tilesets/ruinsExt.chr",0,$800
gfx_finalLab:: incbin "tilesets/finalLab.chr",0,$800
gfx_queenSPR:: incbin "gfx/enemies/queenSPR.chr",0,$500

; Check if killed target number of metroids
earthquakeCheck:: ;{ 08:7EBC:
    ld hl, .thresholds
	
    .loop:
	    ; If we have reached the end of .thresholds, then return
	    ld a, [hl+]
        cp $ff
	    jr z, .return

	    ; If metroidCountReal = .thresholds[hl], then branch ahead to set the timer
        ld b, a
        ld a, [metroidCountReal]
        cp b
        jr z, .setTimer
    jr .loop

.setTimer:
; If more than 1 Metroid is left, set timer to 3 and exit
    ld a, $03
    ld [nextEarthquakeTimer], a
    ld a, [metroidCountReal]
    cp $01
    ret nz

; If only 1 metroid (the queen) is left, set timer to 1
    ld a, $01
    ld [nextEarthquakeTimer], a
.return:
    ret

; Earthquake threshholds (terminated with $FF)
.thresholds:
    db $46, $42, $34, $24, $23, $21, $14, $13, $12, $09, $01, $ff
;}
    
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
solidityIndexTable:: include "tilesets/solidityValues.asm"

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

bank8_freespace: ; 7:7B90 - Freespace (filled with $00)
