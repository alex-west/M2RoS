; Disassembly of "Metroid2.gb"
; This file was created with:
; mgbdis v1.4 - Game Boy ROM disassembler by Matt Currie and contributors.
; https://github.com/mattcurrie/mgbdis

SECTION "ROM Bank $005", ROMX[$4000], BANK[$5]

;------------------------------------------------------------------------------
; Draw two digits of ending timer
credits_drawTimerDigits: ; 05:4000
    ; Temp storage for timer number
    ldh [$99], a
    ; Extract the tens digit
    swap a
    and $0f
    add $f0 ; Adjust the value for display
    call credits_drawOneDigit
    ; Reload timer value from temp
    ldh a, [$99]
    and $0f ; Isolate the ones digit
    add $f0 ; Adjust the value for display
    call credits_drawOneDigit
ret

;------------------------------------------------------------------------------
; Draw one digit of ending timer
credits_drawOneDigit: ; 05:4015
    ; Temp storage for the digit to be displayed
    ldh [$98], a
    ; HL = oam buffer pointer
    ld h, HIGH(wram_oamBuffer)
    ldh a, [hOamBufferIndex]
    ld l, a
    ; Write y pixel
    ldh a, [hSpriteYPixel]
    ld [hl+], a
    ; Write x pixel
    ldh a, [hSpriteXPixel]
    ld [hl+], a
    ; Increment X pixel position for next digit
    add $08
    ldh [hSpriteXPixel], a
    ; Reload tile number from temp, write tile number
    ldh a, [$98]
    ld [hl+], a
    ; Write sprite attribute
    ldh a, [hSpriteAttr]
    ld [hl+], a
    ; Store final value of oam index
    ld a, l
    ldh [hOamBufferIndex], a
ret

;------------------------------------------------------------------------------
; Load credits character tiles
credits_loadFont: ; 05:4030
    ld bc, $0200
    ld hl, gfx_creditsFont
    ld de, vramDest_creditsFont
    call $038a
ret

;------------------------------------------------------------------------------
; VBlank subroutine called during credits
VBlank_drawCreditsLine: ; 05:403D
    ; Redundant bank write
    ld a, $05
    ld [rMBC_BANK_REG], a
    ; Load credits text pointer
    ld a, [$d073]
    ld l, a
    ld a, [$d074]
    ld h, a
    ; Load tilemap destination pointer
    ld a, [$c215]
    ld e, a
    ld a, [$c216]
    ld d, a
    ; Enable SRAM
    ld a, $0a
    ld [$0000], a
    ; Check if newline
    ld a, [hl]
    cp $f1
    jr z, .writeBlankLine

; Write normal line
    ld b, $14
    .writeLineLoop:
        ld a, [hl+]
        sub $21 ; Adjust character encoding to ASCII
        ld [de], a
        inc de
        dec b
    jr nz, .writeLineLoop

    jr .finishVBlank

.writeBlankLine:
    ld b, $14
    .writeBlankLoop:
        ld a, $ff
        ld [de], a
        inc de
        dec b
    jr nz, .writeBlankLoop

    inc hl

.finishVBlank:
    ; Disable SRAM
    ld a, $00
    ld [$0000], a
    ; Store new value of credits text pointer
    ld a, l
    ld [$d073], a
    ld a, h
    ld [$d074], a
    ; Clear ready flag
    xor a
    ld [credits_nextLineReady], a

    call OAM_DMA

    ld a, $01
    ldh [$82], a
    ; Return from interrupt
    pop hl
    pop de
    pop bc
    pop af
reti

;------------------------------------------------------------------------------
; called by gameMode_boot
loadTitleScreen: ; 05:408F
    call title_loadGraphics
    
    ld hl, hudBaseTilemap
    ld de, vramDest_statusBar
    ld b, $14
    .hudLoop:
        ld a, [hl+]
        ld [de], a
        inc de
        dec b
    jr nz, .hudLoop

    ld hl, saveTextTilemap
    ld de, vramDest_itemText
    ld b, $14
    .saveTextLoop:
        ld a, [hl+]
        ld [de], a
        inc de
        dec b
    jr nz, .saveTextLoop

    ld de, $9800
    ld hl, titleTilemap
    .titleTilemapLoop:
        ld a, [hl+]
        ld [de], a
        inc de
        ld a, d
        cp $9c
    jr nz, .titleTilemapLoop

    ld a, $07
    ldh [rWX], a
    ld a, $88
    ldh [rWY], a
    xor a
    ld [$c205], a
    ld a, $c3
    ldh [rLCDC], a
    ; Play title music
    ld a, $11
    ld [$cedc], a
    
    xor a
    ld [$d039], a
    ld [$d07a], a
    ld a, [$d079]
    and a
    jr z, jr_005_40e3

    ld a, $01
    ld [$d07a], a

jr_005_40e3:
    ; Set countdown timer to max
    ld a, $ff
    ld [countdownTimerHigh], a
    ld [countdownTimerLow], a
    ; Set game mode to title
    ld a, $01
    ldh [gameMode], a
ret

hudBaseTilemap:  ; 05:40F0
    db $AF, $AF, $AF, $AF, $AF, $9E, $AF, $AF, $AF, $9F, $9E, $AF, $AF, $AF, $AF, $FF, $FF, $9E, $A3, $A0
saveTextTilemap: ; 05:4104
    db $FF, $D2, $C0, $D5, $C4, $DE, $DF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

;------------------------------------------------------------------------------
titleScreenRoutine: ; 05: 4118
    call $0370
    ld a, $93
    ld [bg_palette], a
    ; Handle flashing
    ld a, [countdownTimerHigh]
    and $03
    jr nz, jr_005_4137

    ld a, [countdownTimerLow]
    cp $10
    jr nc, jr_005_4137

    bit 1, a
    jr z, jr_005_4137
    ; Flash
    ld a, $90
    ld [bg_palette], a

jr_005_4137:
    ld a, [$d07c]
    cp $03
    jr c, jr_005_414d

    sub $02
    ld [$d07c], a
    ld a, [$d07b]
    add $01
    ld [$d07b], a
    jr jr_005_414d

jr_005_414d:
    ldh a, [rDIV]
    ld b, a
    ldh a, [$97]
    cp b
    jr nz, jr_005_4162

    and $01
    jr nz, jr_005_4162

    ld a, b
    ld [$d07b], a
    ld a, $ff
    ld [$d07c], a

jr_005_4162:
    ld a, [$d07b]
    ldh [hSpriteYPixel], a
    ld a, [$d07c]
    ldh [hSpriteXPixel], a
    ld a, $06
    ldh [hSpriteId], a
    ldh a, [$97]
    and $02
    srl a
    ldh [hSpriteAttr], a
    call drawNonGameSprite_longCall
    ld a, $74
    ldh [hSpriteYPixel], a
    ld a, [$d07a]
    and a
    jr z, jr_005_4189

    ld a, $80
    ldh [hSpriteYPixel], a

jr_005_4189:

    ld a, $38
    ldh [hSpriteXPixel], a
    xor a
    ldh [hSpriteAttr], a
    ldh a, [$97]
    and $0c
    srl a
    srl a
    ld e, a
    ld d, $00
    ld hl, titleCursorTable
    add hl, de
    ld a, [hl]
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    
    ld a, [$d0a3]
    add $23
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    
    ld a, $44
    ldh [hSpriteXPixel], a
    ld a, $74
    ldh [hSpriteYPixel], a
    ld a, $00
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ; If show clear save option
    ld a, [$d0a4]
    and a
    jr z, jr_005_41cf
    ; then show "Clear" text
    ld a, $80
    ldh [hSpriteYPixel], a
    ld a, $01
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall

jr_005_41cf:
    call clearUnusedOamSlots
    ldh a, [hInputRisingEdge]
    cp PADF_SELECT
    jr nz, jr_005_41e5

    ld a, $15
    ld [$cec0], a
    ld a, [$d0a4]
    xor $ff
    ld [$d0a4], a

jr_005_41e5:
    ldh a, [hInputRisingEdge]
    cp PADF_RIGHT
    jr nz, jr_005_4205

    ldh a, [hInputPressed]
    cp PADF_RIGHT;$10
    jr nz, jr_005_4205

    ld a, $15
    ld [$cec0], a
    ld a, [$d0a3]
    inc a
    ld [$d0a3], a
    cp $03
    jr nz, jr_005_4205

    xor a
    ld [$d0a3], a

jr_005_4205:
    ldh a, [hInputRisingEdge]
    cp PADF_LEFT
    jr nz, jr_005_4226

    ldh a, [hInputPressed]
    cp PADF_LEFT
    jr nz, jr_005_4226

    ld a, $15
    ld [$cec0], a
    ld a, [$d0a3]
    dec a
    ld [$d0a3], a
    cp $ff
    jr nz, jr_005_4226

    ld a, $02
    ld [$d0a3], a

jr_005_4226:
    xor a
    ld [$d07a], a
    ld a, [$d0a4]
    and a
    jr z, jr_005_4246

    ldh a, [hInputPressed]
    bit PADB_DOWN, a
    jr z, jr_005_4246

    ld a, $01
    ld [$d07a], a
    ldh a, [hInputRisingEdge]
    bit PADB_DOWN, a
    jr z, jr_005_4246

    ld a, $15
    ld [$cec0], a

jr_005_4246:
    ldh a, [hInputRisingEdge]
    cp PADF_START
    ret nz

    xor a
    ld [$d0a0], a
    ld a, $93
    ld [bg_palette], a
    ld a, [$d07a]
    and a
    jr nz, jr_005_42a6

    ld a, $15
    ld [$cec0], a
    ld a, $12
    ld [$cedc], a
    xor a
    ld [$d079], a
    ; Enable SRAM
    ld a, $0a
    ld [$0000], a
    ld hl, saveFile_magicNumber
    ld a, [$d0a3]
    sla a
    sla a
    swap a
    ld e, a
    ld d, $a0

jr_005_427c:
    ld a, [hl+]
    ld b, a
    ld a, [de]
    inc de
    cp b
    jr z, jr_005_427c

    ld a, b
    cp $08
    jr c, jr_005_428d

    ld a, $ff
    ld [$d079], a

jr_005_428d:
    ld a, [$d0a3]
    ld [$a0c0], a
    ; Disable SRAM
    ld a, $00
    ld [$0000], a
    ; New game
    ld a, $0b
    ldh [gameMode], a
    ld a, [$d079]
    and a
        ret z
    ; Load from file
    ld a, $0c
    ldh [gameMode], a
ret

; Clear file
jr_005_42a6:
    ld a, $0f
    ld [$ced5], a
    ld a, [$d0a3]
    sla a
    sla a
    swap a
    ld l, a
    ld h, $a0
    ; Enable SRAM
    ld a, $0a
    ld [$0000], a
    ; Erase first two bytes (w/part of the magic number)
    xor a
    ld [hl+], a
    ld [hl], a
    ; Disable SRAM
    ld [$0000], a
    xor a
    ld [$d0a4], a
ret

;------------------------------------------------------------------------------
title_loadGraphics: ; 5:42C7
    ld bc, $1000
    ld hl, gfx_titleScreen
    ld de, $8800
    call $038a
ret

;------------------------------------------------------------------------------
clearUnusedOamSlots: ; 05:42D4
    ld h, HIGH(wram_oamBuffer)
    ldh a, [hOamBufferIndex]
    ld l, a

    .clearLoop:
        xor a
        ld [hl+], a
        ld a, l
        cp OAM_MAX
    jr c, .clearLoop
ret

;------------------------------------------------------------------------------
; Used by title
titleCursorTable: ; 05:42E1
    db $02, $03, $04, $03

;------------------------------------------------------------------------------
; Screen transitions
doorPointerTable:: ; 05:42E5
include "maps/door macros.asm"
include "maps/doors.asm"

;    db $FF ; Test filler byte

;------------------------------------------------------------------------------
; Credits - 05:55A3
creditsRoutine::
    ldh a, [hSamusYPixel]
    ldh [hSpriteYPixel], a
    ldh a, [hSamusXPixel]
    ldh [hSpriteXPixel], a
    
    call credits_animateSamus
    call credits_scrollHandler
    call credits_drawTimer
    call credits_moveStars
    call credits_drawStars
    
    call clearUnusedOamSlots
ret

;------------------------------------------------------------------------------
credits_drawTimer:
    ; Check if credits are done
    ld a, [$d09f]
    and a
        ret z
    ; Draw hours
    ld a, $88
    ldh [hSpriteYPixel], a
    ld a, $42
    ldh [hSpriteXPixel], a
    ld a, [gameTimeHours]
    call credits_drawTimerDigits
    ; Draw minutes
    ld a, $56
    ldh [hSpriteXPixel], a
    ld a, [gameTimeMinutes]
    call credits_drawTimerDigits
ret

;------------------------------------------------------------------------------
credits_moveStars:
    ld hl, credits_starArray
    ld b, $10

    .starLoop:
        ldh a, [$97]
        and $03
        jr nz, .moveLeft
        ;moveDown
            ld a, [hl]
            add $01
            ld [hl], a
            ; Loop stars back to the top
            cp $a0
            jr c, .moveLeft
                ld a, $10
                ld [hl], a
        .moveLeft:
            inc hl
            ld a, [hl]
            sub $01
            ld [hl], a
            ; Loop stars back to the right
            cp $f8
            jr c, .nextStar
                ld a, $a8
                ld [hl], a
        .nextStar:
            inc hl
            dec b
    jr nz, .starLoop
ret

;------------------------------------------------------------------------------
credits_drawStars: ; Draw stars during credits
    ld hl, credits_starArray
    ld b, $10

    .starLoop:
        ld a, [hl+]
        ldh [hSpriteYPixel], a
        ld a, [hl+]
        ldh [hSpriteXPixel], a
        ; LSB of star number determines star graphic
        ld a, b
        and $01
        add $1b
        ldh [hSpriteId], a
        ; push/pop variables to avoid clobbering
        push hl
        push bc
            call drawNonGameSprite_longCall
        pop bc
        pop hl

        dec b
    jr nz, .starLoop
ret

;------------------------------------------------------------------------------
; animateSamus
credits_animateSamus:
    ld a, [$d097]
    rst $28
        dw func_5808 ; 00
        dw func_5835 ; 01
        dw func_5877 ; 02 - Unused?
        dw func_57E4 ; 03
        dw func_57B4 ; 04
        dw func_579D ; 05
        dw func_5679 ; 06
        dw func_5690 ; 07
        dw func_56A7 ; 08
        dw func_56BE ; 09
        dw func_56D5 ; 0A
        dw func_56EC ; 0B
        dw func_5703 ; 0C
        dw func_571A ; 0D
        dw func_5731 ; 0E
        dw func_5748 ; 0F
        dw func_575F ; 10
        dw func_5776 ; 11
        dw func_578D ; 12
        dw func_5662 ; 13
        dw func_565C ; 14
        dw func_5650 ; 15

func_5650: ; Animate Suitless Samus's hair flowing
    ldh a, [$97]
    and $10
    swap a
    add $13
    call credits_drawSamus
ret

func_565C: ; Draw Suited Samus standing
    ld a, $0a
    call credits_drawSamus
ret

func_5662: ; Draw Suited? Samus kneeling
    ld a, $08
    call credits_drawSamus
    ld a, [countdownTimerLow]
    and a
    ret nz

    ld a, $30
    ld [countdownTimerLow], a
    ld a, [$d097]
    inc a
    ld [$d097], a
ret

func_5679: ; Draw Suitless Samus standing (hair up, hands down)
    ld a, $0b
    call credits_drawSamus
    ld a, [countdownTimerLow]
    and a
    ret nz

    ld a, $08
    ld [countdownTimerLow], a
    ld a, [$d097]
    inc a
    ld [$d097], a
ret

func_5690: ; Draw suitless Samus reaching up to her hair
    ld a, $0c
    call credits_drawSamus
    ld a, [countdownTimerLow]
    and a
    ret nz

    ld a, $10
    ld [countdownTimerLow], a
    ld a, [$d097]
    inc a
    ld [$d097], a
ret

func_56A7: ; Draw suitless Samus untying her hair
    ld a, $0d
    call credits_drawSamus
    ld a, [countdownTimerLow]
    and a
    ret nz

    ld a, $08
    ld [countdownTimerLow], a
    ld a, [$d097]
    inc a
    ld [$d097], a
ret

func_56BE: ; Draw suitless Samus reaching up to her hair (lower her hand, I guess)
    ld a, $0c
    call credits_drawSamus
    ld a, [countdownTimerLow]
    and a
    ret nz

    ld a, $08
    ld [countdownTimerLow], a
    ld a, [$d097]
    inc a
    ld [$d097], a
ret

func_56D5: ; Draw suitless Samus standing (hair up, hands down)
    ld a, $0b
    call credits_drawSamus
    ld a, [countdownTimerLow]
    and a
    ret nz

    ld a, $08
    ld [countdownTimerLow], a
    ld a, [$d097]
    inc a
    ld [$d097], a
ret

func_56EC: ; Draw suitless Samus turning her head left
    ld a, $0e
    call credits_drawSamus
    ld a, [countdownTimerLow]
    and a
    ret nz

    ld a, $08
    ld [countdownTimerLow], a
    ld a, [$d097]
    inc a
    ld [$d097], a
ret

func_5703: ; Draw suitless Samus standing (hair up, hands down)
    ld a, $0b
    call credits_drawSamus
    ld a, [countdownTimerLow]
    and a
    ret nz

    ld a, $08
    ld [countdownTimerLow], a
    ld a, [$d097]
    inc a
    ld [$d097], a
ret

func_571A: ; Draw suitless Samus turning her head right
    ld a, $0f
    call credits_drawSamus
    ld a, [countdownTimerLow]
    and a
    ret nz

    ld a, $08
    ld [countdownTimerLow], a
    ld a, [$d097]
    inc a
    ld [$d097], a
ret

func_5731: ; Draw suitless Samus standing (hair up, hands down)
    ld a, $0b
    call credits_drawSamus
    ld a, [countdownTimerLow]
    and a
    ret nz

    ld a, $0a
    ld [countdownTimerLow], a
    ld a, [$d097]
    inc a
    ld [$d097], a
ret

func_5748: ; Draw suitless Samus turning her head left
    ld a, $0e
    call credits_drawSamus
    ld a, [countdownTimerLow]
    and a
    ret nz

    ld a, $0a
    ld [countdownTimerLow], a
    ld a, [$d097]
    inc a
    ld [$d097], a
ret

func_575F: ; Draw suitless Samus unfurling her hair (frame 1)
    ld a, $10
    call credits_drawSamus
    ld a, [countdownTimerLow]
    and a
    ret nz

    ld a, $0a
    ld [countdownTimerLow], a
    ld a, [$d097]
    inc a
    ld [$d097], a
ret

func_5776: ; Draw suitless Samus unfurling her hair (frame 2)
    ld a, $11
    call credits_drawSamus
    ld a, [countdownTimerLow]
    and a
    ret nz

    ld a, $20
    ld [countdownTimerLow], a
    ld a, [$d097]
    inc a
    ld [$d097], a
ret

func_578D: ; Draw suitless Samus unfurling her hair (frame 3)
    ld a, $12
    call credits_drawSamus
    ld a, [countdownTimerLow]
    and a
    ret nz

    ; Set next state to hair waving
    ld a, $15
    ld [$d097], a
ret

func_579D: ; Draw suitless Samus kneeling
    ld a, $09
    call credits_drawSamus
    ld a, [countdownTimerLow]
    and a
    ret nz

    ld a, $30
    ld [countdownTimerLow], a
    ld a, [$d097]
    inc a
    ld [$d097], a
ret

func_57B4: ; Draw Samus spin jumping (falling)
    ldh a, [hSamusYPixel]
    add $03
    ldh [hSamusYPixel], a
    ldh a, [$97]
    and $03
    add $04
    call credits_drawSamus
    ldh a, [hSamusYPixel]
    and $fc
    cp $60
    ret nz

    ld a, $20
    ld [countdownTimerLow], a
    ; Select ending
    ld a, [gameTimeHours]
    cp $03
    jr nc, jr_005_57de
    ; Best ending (suitless)
    ld a, [$d097]
    inc a
    ld [$d097], a
ret
    ; Second best (suited kneeling animation)
    jr_005_57de:
    ld a, $13
    ld [$d097], a
ret

func_57E4: ; Draw Samus spin jumping (rising)
    ldh a, [hSamusYPixel]
    and $f0
    cp $e0
    jr z, jr_005_57f2

    ldh a, [hSamusYPixel]
    sub $03
    ldh [hSamusYPixel], a

jr_005_57f2:
    ldh a, [$97]
    and $03
    add $04
    call credits_drawSamus
    ld a, [countdownTimerLow]
    and a
    ret nz

    ld a, [$d097]
    inc a
    ld [$d097], a
ret

func_5808: ; Draw suited Samus standing
    ld a, $0a
    call credits_drawSamus
    ld a, [gameTimeHours]
    ; Worst ending (>= 7 hours) - Samus only stands
    cp $07
    ret nc

    ld a, [countdownTimerLow]
    and a
    ret nz

    xor a
    ld [$d09d], a
    xor a
    ld [$d09c], a
    ld [$d09f], a
    ld a, $00
    ld [countdownTimerHigh], a
    ld a, $12
    ld [countdownTimerHigh], a
    ld a, [$d097]
    inc a
    ld [$d097], a
ret

func_5835: ; Draw Samus running (?)
    ld a, [$d09d]
    inc a
    ld [$d09d], a
    cp $06
    jr c, jr_005_5854

    xor a
    ld [$d09d], a
    ld a, [$d09c]
    inc a
    ld [$d09c], a
    cp $04
    jr nz, jr_005_5854

    ld a, $00
    ld [$d09c], a

jr_005_5854:
    ld a, [$d09c]
    call credits_drawSamus
    ld a, [gameTimeHours]
    ; Second-worst ending (between 5 and 7 hours) - Samus never stops running
    cp $05
    ret nc

    ld a, [$d09f]
    and a
    ret z

    xor a
    ld [countdownTimerLow], a
    ld a, $40
    ld [countdownTimerLow], a
    ld a, [$d097]
    inc a
    inc a
    ld [$d097], a
ret

func_5877:
    ; Unused? Falls through to this table:

;------------------------------------------------------------------------------
paletteFade: ; 05:5877
    db $ff, $ff, $fb, $eb, $e7, $a7, $a3, $93

prepareCreditsRoutine: ; 05:587F
    ld hl, paletteFade
    ld a, [countdownTimerLow]
    and a
    jr z, jr_005_58ab

    and $f0
    swap a
    srl a
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    ld [bg_palette], a
    ld [ob_palette0], a
    ld [ob_palette1], a
    ld a, [countdownTimerLow]
    cp $0e
    ret nc

    xor a
    ld [countdownTimerLow], a
    ld a, $ff
    ld [$cfe5], a

jr_005_58ab:
    ld a, $03
    ldh [rLCDC], a
    ld a, $93
    ld [bg_palette], a
    ld a, $93
    ld [ob_palette0], a
    ld a, $43
    ld [ob_palette1], a
    call $037b
    ld hl, $c0ff
    ld a, $ff
    ld c, $01
    ld b, $00

jr_005_58ca:
    ld [hl-], a
    dec b
    jr nz, jr_005_58ca

    dec c
    jr nz, jr_005_58ca

    call credits_loadFont
    
    ld bc, $1000
    ld hl, gfx_creditsSprTiles
    ld de, $8000
    call $038a
    
    ld bc, $0100
    ld hl, gfx_theEnd
    ld de, $9000
    call $038a
    
    ld bc, $0100
    ld hl, gfx_creditsNumbers
    ld de, $8f00
    call $038a
    
    ld a, LOW(creditsTextBuffer)
    ld [$d073], a
    ld a, HIGH(creditsTextBuffer)
    ld [$d074], a
    
    ; Clear unused variable?
    xor a
    ld [$d075], a
        
    ld hl, credits_starPositions
    ld de, credits_starArray
    ld b, $10 ; Should be $20, however, this causes some stars to visibly drop in and out
    jr_005_590e:
        ld a, [hl+]
        ld [de], a
        inc de
        dec b
    jr nz, jr_005_590e

    call loadCreditsText
    
    xor a
    ld [$c205], a
    ld [$c206], a

    ld a, $c3
    ldh [rLCDC], a

    ld a, $ff
    ld [countdownTimerLow], a
    ; Set Samus' position
    ld a, $60
    ldh [hSamusYPixel], a
    ld a, $88
    ldh [hSamusXPixel], a

    ld a, $13
    ld [$cedc], a

    xor a
    ld [$d097], a
    ; Move to credits game mode
    ldh a, [gameMode]
    inc a
    ldh [gameMode], a
ret

;------------------------------------------------------------------------------
credits_scrollHandler: ; 05:593E
    ; Load
    ld a, [$d073]
    ld l, a
    ld a, [$d074]
    ld h, a
    ; Enable SRAM
    ld a, $0a
    ld [$0000], a
    ; Load character
    ld a, [hl]
    ld b, a
    ; Disable SRAM
    ld a, $00
    ld [$0000], a
    ; Check if we're at the end of the credits
    ld a, b
    cp $f0
    jr nz, jr_005_595d

    ld a, $01
    ld [$d09f], a
ret

jr_005_595d:
    ldh a, [$97]
    and $03
    ret nz
    
    ; Scroll a pixel
    ld a, [$c205]
    inc a
    ld [$c205], a

    ld a, [$c205]
    and $07
    ret nz

    ; Adjust cursor position
    ld a, [$c205]
    add $a0
    ld [$c203], a
    ld a, $08
    ld [$c204], a
    call $22bc
    ; Signal that the next line is ready to be drawn
    ld a, $ff
    ld [credits_nextLineReady], a
ret

;------------------------------------------------------------------------------
rebootGame: ; 05:5985 - Unused?
    xor a
    ldh [gameMode], a
ret

;------------------------------------------------------------------------------
credits_drawSamus: ; 05:5989
    call credits_drawSamusJumpTable
ret

credits_drawSamusJumpTable:
    rst $28
        dw func_59B8 ; 00 - Samus running
        dw func_59C7 ; 01 - Samus running 
        dw func_59D6 ; 02 - Samus running
        dw func_59F1 ; 03 - Samus running
        dw func_5A07 ; 04 - Spin jump
        dw func_5A0F ; 05 - Spin jump
        dw func_5A17 ; 06 - Spin jump
        dw func_5A1F ; 07 - Spin jump
        dw func_5A2F ; 08 - Suited Samus kneeling (ready to jump)
        dw func_5A37 ; 09 - Suitless Samus kneeling
        dw func_5A27 ; 0A - Suited Samus standing
        dw func_5A3F ; 0B - Suitless Samus hair up, hand down
        dw func_5A55 ; 0C - Suitless Samus reaching up to hair
        dw func_5A6B ; 0D - Suitless Samus untying bun
        dw func_5A7A ; 0E - Suitless Samus head turned left
        dw func_5A90 ; 0F - Suitless Samus head turned right
        dw func_5AA6 ; 10 - Suitless Samus hair unfurling 1
        dw func_5ABC ; 11 - Suitless Samus hair unfurling 2
        dw func_5AD2 ; 12 - Suitless Samus hair unfurling 3
        dw func_5AE8 ; 13 - Suitless Samus hair waving 1
        dw func_5AFE ; 14 - Suitless Samus hair waving 2

func_59B8:
    ld a, $08
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ld a, $0b
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ret

func_59C7:
    ld a, $09
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ld a, $0c
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ret

func_59D6:
    ld a, $0a
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ld a, $20
    ldh [hSpriteAttr], a
    ldh a, [hSpriteXPixel]
    dec a
    ldh [hSpriteXPixel], a
    ld a, $0b
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    xor a
    ldh [hSpriteAttr], a
    ret

func_59F1:
    ld a, $09
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ld a, $20
    ldh [hSpriteAttr], a
    ld a, $0c
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    xor a
    ldh [hSpriteAttr], a
    ret

func_5A07:
    ld a, $1f
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ret

func_5A0F:
    ld a, $20
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ret

func_5A17:
    ld a, $21
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ret

func_5A1F:
    ld a, $22
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ret

func_5A27:
    ld a, $07
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ret

func_5A2F:
    ld a, $12
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ret

func_5A37:
    ld a, $11
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ret

func_5A3F:
    ld a, $0e
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ld a, $0f
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ld a, $10
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ret

func_5A55:
    ld a, $0e
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ld a, $13
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ld a, $10
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ret

func_5A6B:
    ld a, $14
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ld a, $10
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ret

func_5A7A:
    ld a, $15
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ld a, $0f
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ld a, $10
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ret

func_5A90:
    ld a, $16
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ld a, $0f
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ld a, $10
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ret

func_5AA6:
    ld a, $17
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ld a, $0f
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ld a, $10
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ret

func_5ABC:
    ld a, $18
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ld a, $0f
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ld a, $10
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ret

func_5AD2:
    ld a, $19
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ld a, $0f
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ld a, $10
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ret

func_5AE8:
    ld a, $18
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ld a, $0f
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ld a, $10
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ret

func_5AFE:
    ld a, $1a
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ld a, $0f
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ld a, $10
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ret

; Set of initial positions
credits_starPositions: ; 05:5B14
    ;  ( y, x )
    db $28, $90
    db $18, $70
    db $68, $30
    db $50, $88
    db $40, $18
    db $18, $20
    db $90, $68
    db $48, $40
    ; Due to a bug (?), only the first half of this table gets read
    db $88, $18
    db $80, $88
    db $28, $50
    db $60, $10
    db $98, $38
    db $58, $68
    db $78, $58
    db $38, $70

; 05:5B34 -- Title screen tilemap
titleTilemap: include "data/title_tilemap.asm"

; 05:5F34 - Includes credits font, item font, and sprite numbers
gfx_titleScreen:: include "gfx/gfx_titleScreen.asm"

; 05:6F34
gfx_creditsSprTiles: include "gfx/gfx_creditsSprTiles.asm"

; 05:7E34
gfx_theEnd: include "gfx/gfx_theEnd.asm"

bank5_freespace: ; 05:7F34 -- filled with $00 (nop)

;EoF