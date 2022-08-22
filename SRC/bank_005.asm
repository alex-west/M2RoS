; Disassembly of "Metroid2.gb"
; This file was created with:
; mgbdis v1.4 - Game Boy ROM disassembler by Matt Currie and contributors.
; https://github.com/mattcurrie/mgbdis

SECTION "ROM Bank $005", ROMX[$4000], BANK[$5]

titleCreditsBank:

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
    call copyToVram
ret

;------------------------------------------------------------------------------
; VBlank subroutine called during credits
VBlank_drawCreditsLine: ; 05:403D
    ; Redundant bank write
    ld a, $05
    ld [rMBC_BANK_REG], a
    ; Load credits text pointer
    ld a, [credits_textPointerLow]
    ld l, a
    ld a, [credits_textPointerHigh]
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
    ld [credits_textPointerLow], a
    ld a, h
    ld [credits_textPointerHigh], a
    ; Clear ready flag
    xor a
    ld [credits_nextLineReady], a

    call OAM_DMA

    ld a, $01
    ldh [hVBlankDoneFlag], a
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
    ld [scrollY], a
    ld a, $c3
    ldh [rLCDC], a
    ; Play title music
    ld a, $11
    ld [songRequest], a
    
    xor a
    ld [$d039], a
    ld [$d07a], a
    ld a, [loadingFromFile]
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
    call OAM_clearTable

    ; Handle flashing
    ; Set default palette
    ld a, $93
    ld [bg_palette], a
    ; Jump ahead if the lower 2 bits of the high byte aren't clear
    ld a, [countdownTimerHigh]
    and %00000011 ;$03
    jr nz, .handleTitleStar
    ; Jump ahead if the lower byte isn't less than $10
    ld a, [countdownTimerLow]
    cp $10
    jr nc, .handleTitleStar
    ; Only set the palette every other frame
    bit 1, a
    jr z, .handleTitleStar
    ; Flash
    ld a, $90
    ld [bg_palette], a

    ; Handle logic and drawing of the title star
.handleTitleStar:
    ld a, [titleStarX]
    ; if starX < 3 then don't move it
    cp $03
    jr c, .titleStarTryRespawn
    ; Move left fast
    sub $02
    ld [titleStarX], a
    ; Move down slow
    ld a, [titleStarY]
    add $01
    ld [titleStarY], a
    jr .titleStarTryRespawn ; Pointless relative jump?

.titleStarTryRespawn:
    ; if rDIV != frameCounter, skip ahead
    ldh a, [rDIV]
    ld b, a
    ldh a, [frameCounter]
    cp b
    jr nz, .titleStarDraw
    ; If frame is odd, skip ahead
    and $01
    jr nz, .titleStarDraw
    ; Reset position of star
    ; Y position is essentially random
    ld a, b
    ld [titleStarY], a
    ; Move to right side
    ld a, $ff
    ld [titleStarX], a

.titleStarDraw:
    ld a, [titleStarY]
    ldh [hSpriteYPixel], a
    ld a, [titleStarX]
    ldh [hSpriteXPixel], a
    ld a, $06
    ldh [hSpriteId], a
    ; Make star flicker
    ldh a, [frameCounter]
    and %00000010
    srl a
    ldh [hSpriteAttr], a
    call drawNonGameSprite_longCall

; Draw cursor
    ; Set Y position
    ; Aligned with START text (normal height)
    ld a, $74
    ldh [hSpriteYPixel], a
    ld a, [$d07a]
    and a
    jr z, .normalHeight
        ; Aligned with CLEAR text
        ld a, $80
        ldh [hSpriteYPixel], a
    .normalHeight:

    ; Set x position and attributes
    ld a, $38
    ldh [hSpriteXPixel], a
    xor a
    ldh [hSpriteAttr], a
    ; Get animation frame for cursor
    ldh a, [frameCounter]
    and %00001100
    srl a
    srl a
    ld e, a
    ld d, $00
    ld hl, titleCursorTable
    add hl, de
    ld a, [hl]
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall

    ; Draw sprite for save number
    ld a, [activeSaveSlot]
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
        ; Show "Clear" text
        ld a, $80
        ldh [hSpriteYPixel], a
        ld a, $01
        ldh [hSpriteId], a
        call drawNonGameSprite_longCall
    jr_005_41cf:
    ; End of display logic for title
    call title_clearUnusedOamSlots
    
    ; Title input logic
    ldh a, [hInputRisingEdge]
    cp PADF_SELECT
    jr nz, jr_005_41e5
        ; Play sound effect
        ld a, $15
        ld [sfxRequest_square1], a
        ; Toggle flag
        ld a, [$d0a4]
        xor $ff
        ld [$d0a4], a
    jr_005_41e5:
    
    ; If right is pressed, increment save slot
    ldh a, [hInputRisingEdge]
    cp PADF_RIGHT
    jr nz, .handleLeftInput
        ldh a, [hInputPressed]
        cp PADF_RIGHT
        jr nz, .handleLeftInput
            ; Play sound effect
            ld a, $15
            ld [sfxRequest_square1], a
            ; Increment slot number
            ld a, [activeSaveSlot]
            inc a
            ld [activeSaveSlot], a
            ; Wrap back to zero
            cp $03
            jr nz, .handleLeftInput
                xor a
                ld [activeSaveSlot], a
    .handleLeftInput:

    ; If left is pressed, decrement save slot
    ldh a, [hInputRisingEdge]
    cp PADF_LEFT
    jr nz, jr_005_4226
        ldh a, [hInputPressed]
        cp PADF_LEFT
        jr nz, jr_005_4226
            ; Play sound effect
            ld a, $15
            ld [sfxRequest_square1], a
            ; Decrement slot number
            ld a, [activeSaveSlot]
            dec a
            ld [activeSaveSlot], a
            ; Wrap around to slot 3
            cp $ff
            jr nz, jr_005_4226
                ld a, $02
                ld [activeSaveSlot], a
    jr_005_4226:
    
    xor a
    ld [$d07a], a

    ld a, [$d0a4]
    and a
    jr z, jr_005_4246
        ldh a, [hInputPressed]
        bit PADB_DOWN, a
        jr z, jr_005_4246
            ; Set sound effect
            ld a, $01
            ld [$d07a], a
            ; Check edge of input
            ldh a, [hInputRisingEdge]
            bit PADB_DOWN, a
            jr z, jr_005_4246
                ; Play sound effect
                ld a, $15
                ld [sfxRequest_square1], a
    jr_005_4246:

    ; Exit title routine if start is not pressed
    ldh a, [hInputRisingEdge]
    cp PADF_START
        ret nz

    ; Clear debug flag
    xor a
    ld [debugFlag], a
    ; Flash
    ld a, $93
    ld [bg_palette], a

    ld a, [$d07a]
    and a
    jr nz, jr_005_42a6

    ld a, $15
    ld [sfxRequest_square1], a
    ; Play Samus fanfare
    ld a, $12
    ld [songRequest], a
    xor a
    ld [loadingFromFile], a
    ; Enable SRAM
    ld a, $0a
    ld [$0000], a
    
    ld hl, saveFile_magicNumber
    ; de = $A000 + (activeSaveSlot * $40)
    ld a, [activeSaveSlot]
    sla a
    sla a
    swap a
    ld e, a
    ld d, HIGH(saveData_baseAddr) ;$A0

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
        ld [loadingFromFile], a
    jr_005_428d:
    
    ld a, [activeSaveSlot]
    ld [saveLastSlot], a
    ; Disable SRAM
    ld a, $00
    ld [$0000], a
    ; New game
    ld a, $0b
    ldh [gameMode], a
    ld a, [loadingFromFile]
    and a
        ret z
    ; Load from file
    ld a, $0c
    ldh [gameMode], a
ret

; Clear file
jr_005_42a6:
    ; Play sound effect
    ld a, $0f
    ld [sfxRequest_noise], a
    ; de = $A000 + (activeSaveSlot * $40)
    ld a, [activeSaveSlot]
    sla a
    sla a
    swap a
    ld l, a
    ld h, HIGH(saveData_baseAddr) ; $A0
    ; Enable SRAM
    ld a, $0a
    ld [$0000], a
    ; Erase first two bytes (part w/the magic number)
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
    call copyToVram
ret

;------------------------------------------------------------------------------
; This doesn't contain the weird bookkeeping optimization that the OAM clearing routine in bank 1 has
title_clearUnusedOamSlots: ; 05:42D4
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
    
    call title_clearUnusedOamSlots
ret

;------------------------------------------------------------------------------
credits_drawTimer:
    ; Check if credits are done
    ld a, [credits_scrollingDone]
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
        ldh a, [frameCounter]
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
credits_animateSamus: ;{ 05:5620
    ld a, [credits_samusAnimState]
    rst $28
        dw .standingStart     ; 00
        dw .running           ; 01
        dw .unused            ; 02 - Unused stub
        dw .spinRising        ; 03
        dw .spinFalling       ; 04
        dw .suitless_kneeling ; 05
        ; States $6-$12 are Samus untying her hair
        dw .untying_frameA ; $06
        dw .untying_frameB ; $07
        dw .untying_frameC ; $08
        dw .untying_frameD ; $09
        dw .untying_frameE ; $0A
        dw .untying_frameF ; $0B
        dw .untying_frameG ; $0C
        dw .untying_frameH ; $0D
        dw .untying_frameI ; $0E
        dw .untying_frameJ ; $0F
        dw .untying_frameK ; $10
        dw .untying_frameL ; $11
        dw .untying_frameM ; $12
        
        dw .suited_kneeling    ; $13
        dw .suited_standingEnd ; $14
        dw .hairWaving         ; $15

; Animation state functions {
.hairWaving: ; $15 - Animate Suitless Samus's hair flowing
    ; Animate every 16th frame
    ldh a, [frameCounter]
    and $10
    swap a
    ; Add 0 or 1 to this base index of the hair waving animation
    add $13
    call credits_drawSamus
ret

.suited_standingEnd: ; $14 - Draw Suited Samus standing
    ; Stand forever
    ld a, $0a
    call credits_drawSamus
ret

.suited_kneeling: ; $13 - Draw Suited Samus kneeling
    ld a, $08
    call credits_drawSamus
    ; Wait for timer to expire
    ld a, [countdownTimerLow]
    and a
        ret nz
    ; Set countdown timer for next state (for no reason?)
    ld a, $30
    ld [countdownTimerLow], a
    ; Incrment state to suited_standingEnd
    ld a, [credits_samusAnimState]
    inc a
    ld [credits_samusAnimState], a
ret

.untying_frameA: ; $06 - Draw Suitless Samus standing (hair up, hands down)
    ld a, $0b
    call credits_drawSamus
    ; Wait for timer to expire
    ld a, [countdownTimerLow]
    and a
        ret nz
    ; Set timer for next state
    ld a, $08
    ld [countdownTimerLow], a
    ; Increment state
    ld a, [credits_samusAnimState]
    inc a
    ld [credits_samusAnimState], a
ret

.untying_frameB: ; $07 - Draw suitless Samus reaching up to her hair
    ld a, $0c
    call credits_drawSamus
    ; Wait for timer to expire
    ld a, [countdownTimerLow]
    and a
        ret nz
    ; Set timer for next state
    ld a, $10
    ld [countdownTimerLow], a
    ; Increment state
    ld a, [credits_samusAnimState]
    inc a
    ld [credits_samusAnimState], a
ret

.untying_frameC: ; $08 - Draw suitless Samus untying her hair
    ld a, $0d
    call credits_drawSamus
    ; Wait for timer to expire
    ld a, [countdownTimerLow]
    and a
        ret nz
    ; Set timer for next state
    ld a, $08
    ld [countdownTimerLow], a
    ; Increment state
    ld a, [credits_samusAnimState]
    inc a
    ld [credits_samusAnimState], a
ret

.untying_frameD: ; $09 - Draw suitless Samus reaching up to her hair (lower her hand, I guess)
    ld a, $0c
    call credits_drawSamus
    ; Wait for timer to expire
    ld a, [countdownTimerLow]
    and a
        ret nz
    ; Set timer for next state
    ld a, $08
    ld [countdownTimerLow], a
    ; Increment state
    ld a, [credits_samusAnimState]
    inc a
    ld [credits_samusAnimState], a
ret

.untying_frameE: ; $0A - Draw suitless Samus standing (hair up, hands down)
    ld a, $0b
    call credits_drawSamus
    ; Wait for timer to expire
    ld a, [countdownTimerLow]
    and a
        ret nz
    ; Set timer for next state
    ld a, $08
    ld [countdownTimerLow], a
    ; Increment state
    ld a, [credits_samusAnimState]
    inc a
    ld [credits_samusAnimState], a
ret

.untying_frameF: ; $0B - Draw suitless Samus turning her head left
    ld a, $0e
    call credits_drawSamus
    ; Wait for timer to expire
    ld a, [countdownTimerLow]
    and a
        ret nz
    ; Set timer for next state
    ld a, $08
    ld [countdownTimerLow], a
    ; Increment state
    ld a, [credits_samusAnimState]
    inc a
    ld [credits_samusAnimState], a
ret

.untying_frameG: ; $0C - Draw suitless Samus standing (hair up, hands down)
    ld a, $0b
    call credits_drawSamus
    ; Wait for timer to expire
    ld a, [countdownTimerLow]
    and a
        ret nz
    ; Set timer for next state
    ld a, $08
    ld [countdownTimerLow], a
    ; Increment state
    ld a, [credits_samusAnimState]
    inc a
    ld [credits_samusAnimState], a
ret

.untying_frameH: ; $0D - Draw suitless Samus turning her head right
    ld a, $0f
    call credits_drawSamus
    ; Wait for timer to expire
    ld a, [countdownTimerLow]
    and a
        ret nz
    ; Set timer for next state
    ld a, $08
    ld [countdownTimerLow], a
    ; Increment state
    ld a, [credits_samusAnimState]
    inc a
    ld [credits_samusAnimState], a
ret

.untying_frameI: ; $0E - Draw suitless Samus standing (hair up, hands down)
    ld a, $0b
    call credits_drawSamus
    ; Wait for timer to expire
    ld a, [countdownTimerLow]
    and a
        ret nz
    ; Set timer for next state
    ld a, $0a
    ld [countdownTimerLow], a
    ; Increment state
    ld a, [credits_samusAnimState]
    inc a
    ld [credits_samusAnimState], a
ret

.untying_frameJ: ; $0F - Draw suitless Samus turning her head left
    ld a, $0e
    call credits_drawSamus
    ; Wait for timer to expire
    ld a, [countdownTimerLow]
    and a
        ret nz
    ; Set timer for next state
    ld a, $0a
    ld [countdownTimerLow], a
    ; Increment state
    ld a, [credits_samusAnimState]
    inc a
    ld [credits_samusAnimState], a
ret

.untying_frameK: ; $10 - Draw suitless Samus unfurling her hair (frame 1)
    ld a, $10
    call credits_drawSamus
    ; Wait for timer to expire
    ld a, [countdownTimerLow]
    and a
        ret nz
    ; Set timer for next state
    ld a, $0a
    ld [countdownTimerLow], a
    ; Increment state
    ld a, [credits_samusAnimState]
    inc a
    ld [credits_samusAnimState], a
ret

.untying_frameL: ; $11 - Draw suitless Samus unfurling her hair (frame 2)
    ld a, $11
    call credits_drawSamus
    ; Wait for timer to expire
    ld a, [countdownTimerLow]
    and a
        ret nz
    ; Set timer for next state
    ld a, $20
    ld [countdownTimerLow], a
    ; Increment state
    ld a, [credits_samusAnimState]
    inc a
    ld [credits_samusAnimState], a
ret

.untying_frameM: ; $12 - Draw suitless Samus unfurling her hair (frame 3)
    ld a, $12
    call credits_drawSamus
    ; Wait for timer to expire
    ld a, [countdownTimerLow]
    and a
        ret nz
    ; Set next state to hair waving
    ld a, $15
    ld [credits_samusAnimState], a
ret

.suitless_kneeling: ; $05 - Draw suitless Samus kneeling
    ld a, $09
    call credits_drawSamus
    ; Wait for timer to expire
    ld a, [countdownTimerLow]
    and a
        ret nz
    ; Set timer for next state
    ld a, $30
    ld [countdownTimerLow], a
    ; Increment state to untying animation
    ld a, [credits_samusAnimState]
    inc a
    ld [credits_samusAnimState], a
ret

.spinFalling: ; $04 - Draw Samus spin jumping (falling)
    ; Move down
    ldh a, [hSamusYPixel]
    add $03
    ldh [hSamusYPixel], a
    ; Frame to Render = 4 + (frameCounter mod 4)
    ldh a, [frameCounter]
    and $03
    add $04
    call credits_drawSamus
    ; Detect when Samus hits the ground (what ground?)
    ldh a, [hSamusYPixel]
    and $fc ; Ignore the lower bits to give some leeway
    cp $60
        ret nz

    ; Set timer for next state
    ld a, $20
    ld [countdownTimerLow], a
    ; Select ending
    ld a, [gameTimeHours]
    cp $03
    jr nc, .else_A
        ; Best ending - Suitless kneeling -> hair untying
        ld a, [credits_samusAnimState]
        inc a
        ld [credits_samusAnimState], a
        ret
    .else_A:
        ; Second best - Suited kneeling -> suited standing
        ld a, $13
        ld [credits_samusAnimState], a
        ret
; end state

.spinRising: ; $03 - Draw Samus spin jumping (rising)
    ; Move Samus up until she reaches a certain point
    ldh a, [hSamusYPixel]
    and $f0 ; Ignore the lower bits to give some leeway
    cp $e0
    jr z, .endIf_B
        ; Move up
        ldh a, [hSamusYPixel]
        sub $03
        ldh [hSamusYPixel], a
    .endIf_B:
    ; Frame to Render = 4 + (frameCounter mod 4)
    ldh a, [frameCounter]
    and $03
    add $04
    call credits_drawSamus
    ; Wait for timer to expire
    ld a, [countdownTimerLow]
    and a
        ret nz
    ; Increment state to falling
    ld a, [credits_samusAnimState]
    inc a
    ld [credits_samusAnimState], a
ret

.standingStart: ; $00 - Draw suited Samus standing
    ld a, $0a
    call credits_drawSamus
    ; Worst ending (>= 7 hours) - Samus only stands
    ld a, [gameTimeHours]
    cp $07
        ret nc
    ; Wait for timer to expire ($FF frames, as set in prepareCreditsRoutine)
    ld a, [countdownTimerLow]
    and a
        ret nz

    ; Initialize counters for running animation
    xor a
    ld [credits_runAnimCounter], a
    xor a
    ld [credits_runAnimFrame], a
    ; Pointlessly reset the scrolling done value
    ld [credits_scrollingDone], a
    ; Set timer to $1200 (4608 frames, or 76.8 seconds)
    ld a, $00
    ld [countdownTimerHigh], a ; Shouldn't this be countdownTimerLow?
    ld a, $12
    ld [countdownTimerHigh], a
    ; Increment state to running
    ld a, [credits_samusAnimState]
    inc a
    ld [credits_samusAnimState], a
ret

.running: ; $01 - Draw Samus running
    ; Increment counter between animation frames
    ld a, [credits_runAnimCounter]
    inc a
    ld [credits_runAnimCounter], a
    cp $06
    jr c, .endIf_C
        ; Reset counter
        xor a
        ld [credits_runAnimCounter], a
        ; Increment frame being displayed (in range 0-3)
        ld a, [credits_runAnimFrame]
        inc a
        ld [credits_runAnimFrame], a
        cp $04
        jr nz, .endIf_C
            ld a, $00
            ld [credits_runAnimFrame], a
    .endIf_C:

    ld a, [credits_runAnimFrame]
    call credits_drawSamus

    ; Second-worst ending: (between 5 and 7 hours)
    ; - Samus never stops running, so we never move on from this animation procedure
    ld a, [gameTimeHours]
    cp $05
        ret nc
    ; Keep running until credits stop
    ld a, [credits_scrollingDone]
    and a
        ret z

    ; Set timer for next state to $0040
    xor a
    ld [countdownTimerLow], a ; Should be countdownTimerHigh
    ld a, $40
    ld [countdownTimerLow], a
    ; Set anim state to jumping
    ld a, [credits_samusAnimState]
    inc a
    inc a
    ld [credits_samusAnimState], a
ret

.unused: ; $02 - Unused. Falls through to this table
;}
;}

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
    ; Remove the low health beep sound
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
    call clearTilemaps
    
    ; Clear OAM buffer ?
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
    call copyToVram
    
    ld bc, $0100
    ld hl, gfx_theEnd
    ld de, $9000
    call copyToVram
    
    ld bc, $0100
    ld hl, gfx_creditsNumbers
    ld de, $8f00
    call copyToVram
    
    ld a, LOW(creditsTextBuffer)
    ld [credits_textPointerLow], a
    ld a, HIGH(creditsTextBuffer)
    ld [credits_textPointerHigh], a
    
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

    ; Initialize scroll
    xor a
    ld [scrollY], a
    ld [scrollX], a

    ld a, $c3
    ldh [rLCDC], a

    ; Set timer for initial animation state (standing still in suit)
    ld a, $ff
    ld [countdownTimerLow], a
    ; Set Samus' position
    ld a, $60
    ldh [hSamusYPixel], a
    ld a, $88
    ldh [hSamusXPixel], a
    ; Play credits music
    ld a, $13
    ld [songRequest], a
    ; Init animation state
    xor a
    ld [credits_samusAnimState], a
    ; Move to credits game mode
    ldh a, [gameMode]
    inc a
    ldh [gameMode], a
ret

;------------------------------------------------------------------------------
credits_scrollHandler: ; 05:593E
    ; Load
    ld a, [credits_textPointerLow]
    ld l, a
    ld a, [credits_textPointerHigh]
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
        ld [credits_scrollingDone], a
            ret
    jr_005_595d:
    
    ldh a, [frameCounter]
    and $03
    ret nz
    
    ; Scroll a pixel
    ld a, [scrollY]
    inc a
    ld [scrollY], a

    ld a, [scrollY]
    and $07
    ret nz

    ; Adjust cursor position
    ld a, [scrollY]
    add $a0
    ld [$c203], a
    ld a, $08
    ld [$c204], a
    call getTilemapAddress
    ; Signal that the next line is ready to be drawn
    ld a, $ff
    ld [credits_nextLineReady], a
ret

;------------------------------------------------------------------------------
rebootGame: ;{ 05:5985 - Unused?
    xor a
    ldh [gameMode], a
ret
;}

;------------------------------------------------------------------------------
credits_drawSamus: ;{ 05:5989
    call credits_drawSamusJumpTable
ret ;}

credits_drawSamusJumpTable: ;{ 05:598D
    rst $28
        dw .run_frameA ; 00 - Samus running
        dw .run_frameB ; 01 - Samus running 
        dw .run_frameC ; 02 - Samus running
        dw .run_frameD ; 03 - Samus running
        
        dw .jump_frameA ; 04 - Spin jump
        dw .jump_frameB ; 05 - Spin jump
        dw .jump_frameC ; 06 - Spin jump
        dw .jump_frameD ; 07 - Spin jump
        
        dw .suited_kneeling   ; 08 - Suited Samus kneeling (ready to jump)
        dw .suitless_kneeling ; 09 - Suitless Samus kneeling
        dw .suited_standing   ; 0A - Suited Samus standing
        
        dw .suitless_frameA ; 0B - Suitless Samus hair up, hand down
        dw .suitless_frameB ; 0C - Suitless Samus reaching up to hair
        dw .suitless_frameC ; 0D - Suitless Samus untying bun
        dw .suitless_frameD ; 0E - Suitless Samus head turned left
        dw .suitless_frameE ; 0F - Suitless Samus head turned right
        dw .suitless_frameF ; 10 - Suitless Samus hair unfurling 1
        dw .suitless_frameG ; 11 - Suitless Samus hair unfurling 2
        dw .suitless_frameH ; 12 - Suitless Samus hair unfurling 3
        
        dw .hairWaving_frameA ; 13 - Suitless Samus hair waving 1
        dw .hairWaving_frameB ; 14 - Suitless Samus hair waving 2

; Functions called by table {
.run_frameA:
    ld a, $08
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ld a, $0b
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
ret

.run_frameB:
    ld a, $09
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ld a, $0c
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
ret

.run_frameC:
    ld a, $0a
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ; Flip bottom, adjust position
    ld a, OAMF_XFLIP
    ldh [hSpriteAttr], a
    ldh a, [hSpriteXPixel]
    dec a
    ldh [hSpriteXPixel], a
    ld a, $0b
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ; Clear flip
    xor a
    ldh [hSpriteAttr], a
ret

.run_frameD:
    ld a, $09
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ; Flip bottom
    ld a, OAMF_XFLIP
    ldh [hSpriteAttr], a
    ld a, $0c
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ; Clear flip
    xor a
    ldh [hSpriteAttr], a
ret

.jump_frameA:
    ld a, $1f
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
ret

.jump_frameB:
    ld a, $20
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
ret

.jump_frameC:
    ld a, $21
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
ret

.jump_frameD:
    ld a, $22
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
ret

.suited_standing:
    ld a, $07
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
ret

.suited_kneeling:
    ld a, $12
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
ret

.suitless_kneeling:
    ld a, $11
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
ret

.suitless_frameA:
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

.suitless_frameB:
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

.suitless_frameC:
    ld a, $14
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
    ld a, $10
    ldh [hSpriteId], a
    call drawNonGameSprite_longCall
ret

.suitless_frameD:
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

.suitless_frameE:
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

.suitless_frameF:
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

.suitless_frameG:
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

.suitless_frameH:
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

.hairWaving_frameA:
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

.hairWaving_frameB:
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
;}
;}

; Set of initial positions
credits_starPositions: ;{ 05:5B14
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
;}

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