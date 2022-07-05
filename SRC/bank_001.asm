; Disassembly of "Metroid2.gb"
; This file was created with:
; mgbdis v1.4 - Game Boy ROM disassembler by Matt Currie and contributors.
; https://github.com/mattcurrie/mgbdis

SECTION "ROM Bank $001", ROMX[$4000], BANK[$1]

; 01:4000
include "data/sprites_samus.asm"

; 01:493E: Update status bar
VBlank_updateStatusBar:
    ; Exit if the queen's head is being animated (vblank time optimization?)
    ld a, [$c3ca]
    and a
        ret nz
    ; Don't update while an item is being collected
    ld a, [itemCollected]
    and a
        ret nz
    ld a, [itemCollectionFlag]
    and a
        ret nz

    ; Prep energy tank graphics
    ld hl, $ffb7
    ; Fill buffer with blank spaces
    ld a, $af ; Blank space
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    
    ; Check max energy
    ld a, [samusEnergyTanks]
    and a
    jr z, .else_A
        ; Pre-fill buffer with empty tanks
        ld b, a
        ld hl, $ffb7
        ld a, $9c ; Empty tank
    
        .loop_A: ; Loop for max tanks
            ld [hl+], a
            dec b
        jr nz, .loop_A
    
        ld a, [samusDispHealthHigh]
        and a
        jr z, .endIf_A
            ; Fill buffer with full tanks
            ld b, a
            ld hl, $ffb7
            ld a, $9d ; Filled tank
        
            .loop_B: ; Loop for full tanks
                ld [hl+], a
                dec b
            jr nz, .loop_B
    
            jr .endIf_A
    .else_A:
        ; Draw E
        ld a, $aa ; E
        ldh [$b7], a
    .endIf_A:

    ; Adjust draw destination depending on if in the Queen fight or not
    ; (the HUD in the Queen's room is on the normal BG layer, since her head uses the window layer)
    ld hl, vramDest_queenStatusBar
    ld a, [$d08b]
    cp $11
    jr z, .endIf_B
        ld a, $07
        ldh [rWX], a
        ld hl, vramDest_statusBar
    .endIf_B:

    ; Draw enery tanks
    ldh a, [$bb]
    ld [hl+], a
    ldh a, [$ba]
    ld [hl+], a
    ldh a, [$b9]
    ld [hl+], a
    ldh a, [$b8]
    ld [hl+], a
    ldh a, [$b7]
    ld [hl+], a
    ld a, $9e ; Dash
    ld [hl+], a
    
    ; Draw Samus' health (tens digit)
    ld a, [samusDispHealthLow]
    and $f0
    swap a
    add $a0
    ld [hl+], a
    ; Ones digit
    ld a, [samusDispHealthLow]
    and $0f
    add $a0
    ld [hl+], a
    
    ; Skip over missile icon (drawn previously)
    inc hl
    inc hl
    inc hl
    
    ; Draw Samus' missiles (hundreds digit)
    ld a, [samusDispMissilesHigh]
    and $0f
    add $a0
    ld [hl+], a
    ; Tens digit
    ld a, [samusDispMissilesLow]
    and $f0
    swap a
    add $a0
    ld [hl+], a
    ; Ones digit
    ld a, [samusDispMissilesLow]
    and $0f
    add $a0
    ld [hl+], a
    
    ; Skip over metroid icon
    inc hl
    inc hl
    inc hl
    inc hl

    ; Draw Metroid counter in corner
    ; Check if paused
    ldh a, [gameMode]
    cp $08
    jr z, .else_C
        ld a, [metroidCountShuffleTimer]
        and a
        jr nz, .else_D
            ; Draw normal metroid counter (tens digit)
            ld a, [metroidCountDisplayed]
            and $f0
            swap a
            add $a0
            ld [hl+], a
            ; Ones digit
            ld a, [metroidCountDisplayed]
            and $0f
            add $a0
            ld [hl], a
            ret
        .else_D:
            ; Draw scrambled metroid counter
            dec a
            ld [metroidCountShuffleTimer], a
            cp $80 ; Wait until counter is less than $80 before scrambling
                ret nc
            ; Tens digit
            ldh a, [rDIV]
            add $10
            daa
            and $f0
            swap a
            add $a0
            ld [hl+], a
            ; Ones digit
            ldh a, [rDIV]
            inc a
            daa
            and $0f
            add $a0
            ld [hl], a
            ret
    .else_C:
        ld a, [metroidLCounterDisp]
        cp $ff
        jr z, .else_E
            ; Draw normal L counter (tens digit)
            and $f0
            swap a
            add $a0
            ld [hl+], a
            ; Ones digit
            ld a, [metroidLCounterDisp]
            and $0f
            add $a0
            ld [hl], a
            ret
        .else_E:
            ; Draw blank L counter "--"
            ld a, $9e ; Dash
            ld [hl+], a
            ld [hl], a
            ret

;------------------------------------------------------------------------------
adjustHudValues:: ; 01:4A2B - Adjusts displayed health and missiles
    ; Clamp ones digit of health to decimal range
    ld a, [samusCurHealthLow]
    and $0f
    cp $0a
    jr c, .endIf_A
        ld a, [samusCurHealthLow]
        and $f0
        add $09
        ld [samusCurHealthLow], a
    .endIf_A:

    ; Clamp tens digit of health to decimal range
    ld a, [samusCurHealthLow]
    and $f0
    cp $a0
    jr c, .endIf_B
        ld a, [samusCurHealthLow]
        and $0f
        add $90
        ld [samusCurHealthLow], a
    .endIf_B:

    ; Check health high byte
    ld a, [samusCurHealthHigh]
    ld b, a
    ld a, [samusDispHealthHigh]
    cp b
    jr z, .checkHealthLowByte
    jr nc, .decrementDisplayedHealth
    jr .incrementDisplayedHealth

.checkHealthLowByte: ; Check health low byte
    ld a, [samusCurHealthLow]
    ld b, a
    ld a, [samusDispHealthLow]
    cp b
    jr z, .checkMissileHighByte
    jr nc, .decrementDisplayedHealth

.incrementDisplayedHealth: ; Increment displayed health
    ld a, [samusDispHealthLow]
    add $01
    daa
    ld [samusDispHealthLow], a
    
    ld a, [samusDispHealthHigh]
    adc $00
    daa
    ld [samusDispHealthHigh], a
    ; Check if no sound effect is playing
    ld a, [$cec1]
    and a
    jr nz, .checkMissileHighByte
        ; Play sound every 4 frames
        ldh a, [frameCounter]
        and $03
        jr nz, .checkMissileHighByte
            ld a, $18
            ld [sfxRequest_square1], a
        jr .checkMissileHighByte

.decrementDisplayedHealth: ; Decrement displayed health
    ld a, [samusDispHealthLow]
    sub $01
    daa
    ld [samusDispHealthLow], a
    
    ld a, [samusDispHealthHigh]
    sbc $00
    daa
    ld [samusDispHealthHigh], a
    ; Check if no sound effect is playing
    ld a, [$cec1]
    and a
    jr nz, .checkMissileHighByte
        ; Play sound every 4 frames
        ldh a, [frameCounter]
        and $03
        jr nz, .checkMissileHighByte
            ld a, $18
            ld [sfxRequest_square1], a

.checkMissileHighByte: ; Check missile high byte
    ld a, [samusCurMissilesHigh]
    ld b, a
    ld a, [samusDispMissilesHigh]
    cp b
    jr z, .checkMissileLowByte

    jr nc, .decrementDisplayedMissiles

    jr .incrementDisplayedMissiles

.checkMissileLowByte: ; Check missile low byte
    ld a, [samusCurMissilesLow]
    ld b, a
    ld a, [samusDispMissilesLow]
    cp b
    ret z
        jr nc, .decrementDisplayedMissiles

.incrementDisplayedMissiles: ; Increment displayed missile count
    ld a, [samusDispMissilesLow]
    add $01
    daa
    ld [samusDispMissilesLow], a
    
    ld a, [samusDispMissilesHigh]
    adc $00
    daa
    ld [samusDispMissilesHigh], a

    ; Play sound every 4 frames
    ldh a, [frameCounter]
    and $03
    ret nz
        ld a, $0c
        ld [sfxRequest_square1], a
ret

.decrementDisplayedMissiles: ; Decrement displayed missile count
    ld a, [samusDispMissilesLow]
    sub $01
    daa
    ld [samusDispMissilesLow], a
    
    ld a, [samusDispMissilesHigh]
    sbc $00
    daa
    ld [samusDispMissilesHigh], a
ret

;------------------------------------------------------------------------------
debug_drawNumber: ; 01:4AFC - Display a two-sprite number
.twoDigit:
    ldh [$99], a
    swap a
    and $0f
    add $a0
    call Call_001_4b11
    ldh a, [$99]
.oneDigit: ; 01:4B09 - Display a one-sprite number
    and $0f
    add $a0
    call Call_001_4b11
ret


Call_001_4b11: ; 01:4B11
    ldh [$98], a
    ld h, $c0
    ldh a, [hOamBufferIndex]
    ld l, a
    ldh a, [hSpriteYPixel]
    ld [hl+], a
    ldh a, [hSpriteXPixel]
    ld [hl+], a
    add $08
    ldh [hSpriteXPixel], a
    ldh a, [$98]
    ld [hl+], a
    ldh a, [hSpriteAttr]
    ld [hl+], a
    ld a, l
    ldh [hOamBufferIndex], a
    ret

; 01:4B2C - Render Metroid sprite on the HUD
drawHudMetroid::
    ld a, $98
    ldh [hSpriteYPixel], a
    ; Check if in queen fight
    ld a, [$d08b]
    cp $11
    jr z, .endIf_A
        ; If standing on save point
        ld a, [saveContactFlag]
        and a
        jr nz, .endIf_B
            ; or if a major item is being collected
            ld a, [$d093]
            and a
            jr z, .endIf_A
                cp $0b
                jr nc, .endIf_A
        .endIf_B:
            ; Then render the metroid counter 8 pixels up
            ld a, $90
            ldh [hSpriteYPixel], a
    .endIf_A:

    ld a, $80
    ldh [hSpriteXPixel], a
    ld a, $01
    ld [samus_screenSpritePriority], a
    ; Animate the counter
    ldh a, [frameCounter]
    and $10
    swap a
    add $3f
    ldh [hSpriteId], a
    ; Draw the sprite
    call drawSamusSprite
ret

; Draws a sprite from Samus's sprite bank
drawSamusSprite: ; 01:4B62
    ; This routine was originally in bank 0
    switchBank samusSpritePointerTable
    ; Index into sprite pointer table
    ldh a, [hSpriteId]
    ld d, $00
    ld e, a
    sla e
    rl d
    ld hl, samusSpritePointerTable
    add hl, de
    ; Load pointer from table
    ld a, [hl+]
    ld e, a
    ld a, [hl]
    ld d, a
    ; Prep HL
    ld h, $c0
    ldh a, [hOamBufferIndex]
    ; Store x and y offsets of sprite in B and C
    ld l, a
    ldh a, [hSpriteYPixel]
    ld b, a
    ldh a, [hSpriteXPixel]
    ld c, a

    .spriteLoop:
        ; No sprite flipping logic here
        ; Load y coordinate
        ld a, [de]
        cp $ff
            jr z, .exit
        
        add b
        ld [hl+], a
        ; Load x coordinate
        inc de        
        ld a, [de]
        add c
        ld [hl+], a
        ; Load tile number
        inc de
        ld a, [de]
        ld [hl+], a
        ; Load sprite attribute byte
        inc de
        ; Set PAL1 bit or leave it alone
        ldh a, [hSpriteAttr]
        and a
        jr z, .else_A
            ld a, [de]
            set OAMB_PAL1, a
            jr .endIf_A
        .else_A:
            ld a, [de]
        .endIf_A:
        ; Adjust priority depending on screen
        ld [hl], a
        ld a, [samus_screenSpritePriority]
        and a
        jr nz, .endIf_B
            ld a, [hl]
            set OAMB_PRI, a
            ld [hl], a
        .endIf_B:
        ; Adjust indeces for next loop iteration
        inc hl
        ld a, l
        ldh [hOamBufferIndex], a
        inc de
    jr .spriteLoop

    .exit:
ret


clearUnusedOamSlots: ; 01:4BB3
    ldh a, [hOamBufferIndex]
    ld b, a
    ld a, [maxOamPrevFrame]
    ld c, a
    cp b
    ; Jump ahead if we used more sprites on the previous frame
    jr c, .endIf
        ld h, HIGH(wram_oamBuffer)
        ldh a, [hOamBufferIndex]
        ld l, a
        ; Loop until we reach the max index from the previous frame
        .loop:
            xor a
            ld [hl+], a
            ld a, l
            cp c
        jr c, .loop
    .endIf:
    ; Update max index
    ldh a, [hOamBufferIndex]
    ld [maxOamPrevFrame], a
ret

clearAllOam: ; 00:4BCE
    ld hl, wram_oamBuffer
    .clearLoop:
        xor a
        ld [hl+], a
        ld a, l
        cp OAM_MAX
    jr c, .clearLoop
ret

;------------------------------------------------------------------------------
drawSamus: ; 01:4BD9: Draw Samus
; Entry point 1
    ld a, [samusInvulnerableTimer]
    and a
    jr z, .endIf_A
        dec a
        ld [samusInvulnerableTimer], a
        ; 4 frames on, 4 frames off
        ldh a, [frameCounter]
        bit 2, a
        ret z
    .endIf_A:
    
    ld a, [acidContactFlag]
    and a
    jr z, .endIf_B
        ; 4 frames on, 4 frames off
        ldh a, [frameCounter]
        bit 2, a
        ret z
    .endIf_B:

.ignoreDamageFrames ; 01:4BF3 - Entry point 2
    ld a, [samusPose]
    bit 7, a
        jp nz, drawSamus_faceScreen

    ; Convert facing direction into a dummy input
    ld b, $01
    ld a, [samusFacingDirection]
    and a
    jr nz, .endIf_C
        ld b, $02
    .endIf_C:

    ; Check if cutsence is active (e.g. a metroid is transforming)
    ld a, [$c463]
    and a
    jr z, .else_D
        ; Load dummy input to temp
        ld a, b
        ldh [$98], a
        jr .endIf_D
    .else_D:
        ; Load input into temp variable
        ldh a, [hInputPressed]
        and PADF_DOWN | PADF_UP | PADF_LEFT | PADF_RIGHT ;$f0
        swap a
        ; OR the dummy input into the temp variable as well
        or b
        ldh [$98], a
    .endIf_D:

    ld a, [samusPose]
    rst $28
        dw drawSamus_standing   ; $00 - Standing
        dw drawSamus_jump       ; $01 - Jumping
        dw drawSamus_spinJump   ; $02 - Spin-jumping
        dw drawSamus_run        ; $03 - Running (set to 83h when turning)
        dw drawSamus_crouch     ; $04 - Crouching
        dw drawSamus_morph      ; $05 - Morphball
        dw drawSamus_morph      ; $06 - Morphball jumping
        dw drawSamus_jump       ; $07 - Falling
        dw drawSamus_morph      ; $08 - Morphball falling
        dw drawSamus_jumpStart  ; $09 - Starting to jump
        dw drawSamus_jumpStart  ; $0A - Starting to spin-jump
        dw drawSamus_spider     ; $0B - Spider ball rolling
        dw drawSamus_spider     ; $0C - Spider ball falling
        dw drawSamus_spider     ; $0D - Spider ball jumping
        dw drawSamus_spider     ; $0E - Spider ball
        dw drawSamus_knockback  ; $0F - Knockback
        dw drawSamus_morph      ; $10 - Morphball knockback
        dw drawSamus_knockback  ; $11 - Standing bombed
        dw drawSamus_morph      ; $12 - Morphball bombed
        dw drawSamus_faceScreen ; $13 - Facing screen
        dw drawSamus_faceScreen ; $14   
        dw drawSamus_faceScreen ; $15   
        dw drawSamus_faceScreen ; $16   
        dw drawSamus_faceScreen ; $17   
        dw drawSamus_morph      ; $18 - Being eaten by Metroid Queen
        dw drawSamus_morph      ; $19 - In Metroid Queen's mouth
        dw drawSamus_morph      ; $1A - Being swallowed by Metroid Queen
        dw drawSamus_morph      ; $1B - In Metroid Queen's stomach
        dw drawSamus_morph      ; $1C - Escaping Metroid Queen
        dw drawSamus_morph      ; $1D - Escaped Metroid Queen

drawSamus_knockback: ; 01:4C59 - $0F, $11: Knockback
    ; Index = facing direction
    ld d, $00
    ld a, [samusFacingDirection]
    ld e, a
    ld hl, .knockbackTable
    add hl, de
    ; Load sprite
    ld a, [hl]
    ldh [hSpriteId], a
jp drawSamus_common

.knockbackTable: ; 02:4C69
    db $16, $09

drawSamus_spider: ; 01:4C6B - $0B-$0E: Spider Ball
    ; Multiply facing direction by 4
    ld a, [samusFacingDirection]
    and $01
    sla a
    sla a
    ld b, a
    ; Get animation frame
    ld a, [samus_spinAnimationTimer]
    and %00001100 ; $0C
    srl a
    srl a
    ; Index into table
    add b
    ld e, a
    ld d, $00
    ; Load sprite ID
    ld hl, .spiderTable
    add hl, de
    ld a, [hl]
    ldh [hSpriteId], a
jp drawSamus_common

.spiderTable: ; 02:4C8C
    db $37, $38, $39, $3a ; Left
    db $3b, $3c, $3d, $3e ; Right

drawSamus_morph: ; 01:4C94 - Morph poses
    ; Get sub-table depending on facing direction
    ld a, [samusFacingDirection]
    and $01
    sla a
    sla a
    ld b, a
    ; Get index into table
    ld a, [samus_spinAnimationTimer]
    and %00001100 ; $0C
    srl a
    srl a
    add b
    ld e, a
    ld d, $00
    ; Load sprite index from table
    ld hl, .morphTable
    add hl, de
    ld a, [hl]
    ldh [hSpriteId], a
jp drawSamus_common

.morphTable: ; 01:4CB5
    db $1e, $1f, $20, $21 ; Left
    db $26, $27, $28, $29 ; Right

drawSamus_jump: ; 01:4CBD - $01, $07: Jumping and falling
    ; Index into table using input + facing direction
    ld d, $00
    ldh a, [$98]
    ld e, a
    ld hl, jumpSpriteTable
    add hl, de
    ; Get sprite ID
    ld a, [hl]
    ldh [hSpriteId], a
jp drawSamus_common

drawSamus_jumpStart: ; 01:4CCC - $09, $0A: Jump Start
    ld a, $03 ; Right
    ldh [hSpriteId], a
    ld a, [samusFacingDirection]
    and a
        jp nz, drawSamus_common
    ld a, $10 ; Left
    ldh [hSpriteId], a
        jp drawSamus_common
; end proc

jumpSpriteTable: ; 01:4CDE
; Value read is based on input and facing direction
;                                U    U              D    D
;       x    R    L    x    U    R    L    x    D    R    L    x    x    x    x    x
    db $00, $09, $16, $00, $00, $0a, $17, $00, $00, $0c, $19, $00, $00, $00, $00, $00

drawSamus_spinJump: ; 01:4CEE - $02: Spin jump
    ld a, [samusFacingDirection]
    and a
    jp z, .else
        ld hl, .spinRightTable
        jp .endIf
    .else:
        ld hl, .spinLeftTable
    .endIf:

    ld a, [samusItems]
    and itemMask_space | itemMask_screw
    jr nz, .spinFast
        ; Slow spin
        ; Get index into table
        ld a, [samus_spinAnimationTimer]
        srl a
        and %00001100
        srl a
        srl a
        ld e, a
        ld d, $00
        add hl, de
        ; Load sprite ID
        ld a, [hl]
        ldh [hSpriteId], a
        jp drawSamus_common
    .spinFast:
        ; Get index into table
        ld a, [samus_spinAnimationTimer]
        srl a
        and %00000011
        ld e, a
        ld d, $00
        add hl, de
        ; Load sprite ID
        ld a, [hl]
        ldh [hSpriteId], a
        jp drawSamus_common
; end proc

; Spin tables
.spinRightTable: ; 01:4D2B
    db $1A, $1B, $1C, $1D ; Right
.spinLeftTable: ; 01:4D2F
    db $22, $23, $24, $25 ; Left

drawSamus_faceScreen: ; 00:4D33 - $13-$17: Facing the screen
    ; Fade-in logic
    ld a, [countdownTimerLow]
    and a
    jr z, .endIf
        ldh a, [frameCounter]
        and $03
        ret z
    .endIf:
    ; Load sprite ID
    ld a, $00
    ldh [hSpriteId], a
jp drawSamus_common

drawSamus_standing: ; $00: Standing
    ; Index into table using input + facing direction
    ld d, $00
    ldh a, [$98]
    ld e, a
    ld hl, .standingTable
    add hl, de
    ; Load sprite ID
    ld a, [hl]
    ldh [hSpriteId], a
jp drawSamus_common

.standingTable: ; 01:4D54
; Value read is based on input and facing direction
;                                U    U              D    D
;       x    R    L    x    U    R    L    x    D    R    L    x    x    x    x    x
    db $00, $01, $0e, $00, $00, $02, $0f, $00, $00, $01, $0e, $00, $00, $00, $00, $00, $00

drawSamus_crouch: ; $04 - Crouching
    ld a, $0b ; Right
    ldh [hSpriteId], a
    ld a, [samusFacingDirection]
    and a
        jp nz, drawSamus_common
    ld a, $18 ; Left
    ldh [hSpriteId], a
        jp drawSamus_common
; end proc

drawSamus_run: ; 01:4D77 - $03: Running
    ; Clamp run animation counter so it never equals or exceeds $30
    ld a, [samus_animationTimer]
    cp $30
    jr c, .endIf_A
        xor a
        ld [samus_animationTimer], a
    .endIf_A:

    ; Play stepping sound
    ld a, [samus_animationTimer]
    and $07
    jr nz, .endIf_B
        ; Don't interrupt currently playing sounds
        ld a, [sfxRequest_noise]
        and a
        jr nz, .endIf_B
            ld a, $10
            ld [sfxRequest_noise], a
    .endIf_B:

    ; Get index into table
    ;  Multiply facing direction by 4 to get the pertinent sub-table
    ld a, [samusFacingDirection]
    and $01
    sla a
    sla a
    ld b, a
    ; Convert run animation timer to table index
    ld a, [samus_animationTimer]
    and $30
    swap a
    add b
    ld e, a
    ld d, $00

    ; Get base address of table
    ld hl, .runningTableNormal
    ldh a, [hInputPressed]
    bit PADB_UP, a
    jr z, .else_C
        ld hl, .runningTableAimingUp
        jr .endIf_C
    .else_C:
        ldh a, [hInputPressed]
        bit PADB_B, a
        jr z, .endIf_C
            ld hl, .runningTableShooting
    .endIf_C:
    add hl, de

    ; Load sprite ID
    ld a, [hl]
    ldh [hSpriteId], a
jp drawSamus_common

; The fourth frame in these tables is just padding
.runningTableNormal: ; 01:4DC7 - Normal
    db $10, $11, $12, $00 ; Left
    db $03, $04, $05, $00 ; Right
.runningTableShooting: ; 01:4DCF - Firing forwards
    db $13, $14, $15, $00 ; Left
    db $06, $07, $08, $00 ; Right
.runningTableAimingUp: ; 01:4DD7 - Aiming up
    db $2e, $2f, $30, $00 ; Left
    db $2b, $2c, $2d, $00 ; Right

; All the above drawSamus procedures jump here
drawSamus_common: ; 01:4DDF
    call loadScreenSpritePriorityBit
    ; Set x pos
    ldh a, [hCameraXPixel]
    ld b, a
    ldh a, [hSamusXPixel]
    sub b
    add $60
    ldh [hSpriteXPixel], a
    ld [$d03c], a
    ; Set y pos
    ldh a, [hCameraYPixel]
    ld b, a
    ldh a, [hSamusYPixel]
    sub b
    add $62
    ldh [hSpriteYPixel], a
    ld [$d03b], a
    ; Set the sprite attribute
    xor a
    ldh [hSpriteAttr], a
    ; If in contact with acid or being hurt, set attribute byte to non-zero
    ld a, [acidContactFlag]
    and a
    jr nz, .then
        ld a, [samusInvulnerableTimer]
        and a
        jr z, .endIf
    .then: ; I'd use else here, but these branches aren't mutually exclusive
        ld a, $01
        ldh [hSpriteAttr], a
    .endIf:

    call drawSamus_earthquakeAdjustment ; Adjust y position
    call drawSamusSprite
    xor a
    ldh [hSpriteAttr], a
    ld [samus_screenSpritePriority], a
ret

; New game
; - Transfers initial savegame from ROM to save buffer in WRAM
createNewSave: ; 01:4E1C
    xor a
    ld [$d079], a
    ld hl, initialSaveFile
    ld de, saveBuffer
    ld b, $26

    .loadLoop:
        ld a, [hl+]
        ld [de], a
        inc de
        dec b
    jr nz, .loadLoop

    ld a, $02 ; "gameMode_LoadA"
    ldh [gameMode], a
ret

; Copies savegame from SRAM to save buffer in WRAM
loadSaveFile: ; 01:4E33
    ld a, [$d079]
    and a
        jr z, createNewSave

    ; Enable SRAM
    ld a, $0a
    ld [$0000], a
    ld a, [activeSaveSlot]
    sla a
    sla a
    swap a
    add $08
    ld l, a
    ld h, HIGH(saveData_baseAddr)
    ld de, saveBuffer
    ld b, $26

    .loadLoop:
        ld a, [hl+]
        ld [de], a
        inc de
        dec b
    jr nz, .loadLoop

    ; Disable SRAM
    ld a, $00
    ld [$0000], a
    
    call loadEnemySaveFlags_longJump ; Indirect call to 01:7AB9 (in this same bank!)
    ld a, $02 ; for "gameMode_LoadA"
    ldh [gameMode], a
ret

; Initial savegame
initialSaveFile:
	dw $07D4     ; Samus' Y position
	dw $0648     ; Samus' X position
	dw $07C0     ; Screen Y position
	dw $0640     ; Screen X position
	
	dw gfx_surfaceSPR      ; Enemy tiles source address
	db BANK(gfx_surfaceBG) ; Background tiles source bank
	dw gfx_surfaceBG       ; Background tiles source address
	dw $5280     ; Metatile definitions source address
	dw $4580     ; Tile properties source address
	db $0F       ; Bank for current room
	
	db $64       ; Samus solid block threshold
	db $64       ; Enemy solid block threshold
	db $64       ; Projectile solid block threshold
	
	db $00       ; Samus' equipment
	db $00       ; Samus' beam
	db $00       ; Samus' energy tanks
	dw $0099     ; Samus' health
	dw $0030     ; Samus' max missiles
	dw $0030     ; Samus' missiles
	
	db $01       ; Direction Samus is facing
	db $02       ; Acid damage
	db $08       ; Spike damage
	db $47       ; Real number of Metroids remaining
	db $04       ; Song for room
	db $00       ; In-game timer, minutes
	db $00       ; In-game timer, hours
	db $39       ; Number of Metroids remaining

samusShoot: ; 01:4E8A
    ldh a, [hInputRisingEdge]
    bit PADB_B, a
        jr nz, jr_001_4e9f

    ldh a, [hInputPressed]
    bit PADB_B, a
        ret z

    ld a, [samusBeamCooldown]
    inc a
    ld [samusBeamCooldown], a
    cp $10
        ret c

Jump_001_4e9f:
jr_001_4e9f:
    ld a, [samusPose]
    bit 7, a
    ret nz

    ld hl, table_5653
    ld a, [samusPose]
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    and a
    ret z

    cp $80
    jp z, Jump_001_53d9

    ld b, a
    xor a
    ld [samusBeamCooldown], a
    
    ldh a, [hInputPressed]
    swap a
    and b
    jr nz, jr_001_4ecf
        ld c, $01
        ld a, [samusFacingDirection]
        and a
        jr nz, jr_001_4ed8
            ld c, $02
            jr jr_001_4ed8
    jr_001_4ecf:
        ld hl, table_5643
        ld e, a
        ld d, $00
        add hl, de
        ld a, [hl]
        ld c, a
    jr_001_4ed8:

    ld a, c
    ldh [$99], a
    ld hl, table_561D
    ld a, [samusPose]
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    ld b, a
    ld hl, table_5630
    ld a, c
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    add b
    sub $04
    ld b, a
    ldh [$9a], a
    ld hl, table_55FB
    sla c
    ld a, [samusFacingDirection]
    add c
    srl c
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    sub $04
    ldh [$98], a
    ld a, [samusActiveWeapon]
    cp $04
    jp z, Jump_001_4f7e

    call findProjectileSlot ; Projectile slot is returned in HL
    ; Exit if projectile is 3
    ld a, l
    swap a
    cp $03
        ret z

    ld a, [samusActiveWeapon]
    cp $08
    jr nz, jr_001_4f44

    ld a, [samusCurMissilesLow]
    ld b, a
    ld a, [samusCurMissilesHigh]
    or b
    jr nz, jr_001_4f32
        ; Play sound effect
        ld a, $19
        ld [sfxRequest_square1], a
            ret
    jr_001_4f32:

    ld a, [samusCurMissilesLow]
    sub $01
    daa
    ld [samusCurMissilesLow], a
    ld a, [samusCurMissilesHigh]
    sbc $00
    daa
    ld [samusCurMissilesHigh], a

jr_001_4f44:
    ld a, [samusActiveWeapon]
    ld [hl+], a
    ldh a, [$99]
    ld [hl+], a
    ldh a, [$9a]
    ld b, a
    ldh a, [hSamusYPixel]
    add b
    ld [hl+], a
    ldh a, [$98]
    ld b, a
    ldh a, [hSamusXPixel]
    add b
    ld [hl+], a
    ldh a, [frameCounter]
    and $10
    srl a
    ld [hl+], a
    xor a
    ld [hl], a
    ld a, [samusActiveWeapon]
    cp $03
    jr nz, jr_001_4f6f

    ld a, l
    cp $20
    jp c, Jump_001_4e9f

jr_001_4f6f:
    ld hl, $4fe5
    ld a, [samusActiveWeapon]
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    ld [sfxRequest_square1], a
    ret


Jump_001_4f7e:
    ld hl, projectileArray
    ld a, [hl]
    cp $ff
    ret nz

Jump_001_4f85:
    ldh a, [$99]
    cp $04
    jr nc, jr_001_4f9d

    ldh a, [$98]
    sub $08
    ldh [$98], a
    ld a, l
    and a
    jr z, jr_001_4fad

    ldh a, [$98]
    add $10
    ldh [$98], a
    jr jr_001_4fad

jr_001_4f9d:
    ldh a, [$9a]
    sub $08
    ldh [$9a], a
    ld a, l
    and a
    jr z, jr_001_4fad

    ldh a, [$9a]
    add $10
    ldh [$9a], a

jr_001_4fad:
    ld a, [samusActiveWeapon]
    ld [hl+], a
    ldh a, [$99]
    ld [hl+], a
    ldh a, [$9a]
    ld b, a
    ldh a, [hSamusYPixel]
    add b
    ld [hl+], a
    ldh a, [$98]
    ld b, a
    ldh a, [hSamusXPixel]
    add b
    ld [hl+], a
    ldh a, [frameCounter]
    and $10
    srl a
    ld [hl+], a
    xor a
    ld [hl], a
    ld a, l
    and $f0
    add $10
    ld l, a
    cp $30
    jp c, Jump_001_4f85

    ld hl, $4fe5
    ld a, [samusActiveWeapon]
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    ld [sfxRequest_square1], a
    ret


    db $07, $09, $16, $0b, $0a

    rlca
    rlca
    rlca

    db $08


findProjectileSlot: ; 01:4FEE
    ld hl, projectileArray
    ld a, [samusActiveWeapon]
    cp $08
    jr nz, .endIf
        ld a, $02
        swap a
        ld l, a
    .endIf

    .loop:
        ld a, [hl]
        cp $ff
            ret z
        ld de, $0010
        add hl, de
        ld a, l
        swap a
        cp $03
    jr nz, .loop
ret


handleProjectiles: ; 01:500D
    xor a
    ld [$d032], a

Jump_001_5011:
    ld a, $dd
    ld h, a
    ldh [$b8], a
    ld a, [$d032]
    swap a
    ld l, a
    ldh [$b7], a
    ld a, [hl+]
    ldh [$b9], a
    ld [$d08d], a
    cp $ff
    jp z, Jump_001_52f3

    ld a, [hl+]
    ldh [$98], a
    ld [$d012], a
    ld a, [hl+]
    ldh [$99], a
    ld a, [hl+]
    ldh [$9a], a
    ld a, [hl+]
    ldh [$ba], a
    ld a, [hl+]
    inc a
    ldh [$bb], a
    ldh a, [$b9]
    cp $02
    jp z, Jump_001_50d4

    cp $03
    jr z, jr_001_504f

    cp $08
    jp z, Jump_001_51c3

    jp Jump_001_5216


jr_001_504f:
    ldh a, [$98]
    bit 0, a
    jr z, jr_001_5064

    call Call_001_509a
    ldh a, [$9a]
    add $04
    ld hl, $d035
    add [hl]
    ldh [$9a], a
    jr jr_001_5097

jr_001_5064:
    bit 1, a
    jr z, jr_001_5077

    call Call_001_509a
    ldh a, [$9a]
    sub $04
    ld hl, $d036
    sub [hl]
    ldh [$9a], a
    jr jr_001_5097

jr_001_5077:
    bit 2, a
    jr z, jr_001_508a

    call Call_001_50b7
    ldh a, [$99]
    sub $04
    ld hl, $d037
    sub [hl]
    ldh [$99], a
    jr jr_001_5097

jr_001_508a:
    call Call_001_50b7
    ldh a, [$99]
    add $04
    ld hl, $d038
    add [hl]
    ldh [$99], a

jr_001_5097:
    jp Jump_001_5282


Call_001_509a:
    ldh a, [$bb]
    cp $05
    ret nc

    ld a, l
    and $f0
    cp $10
    ret z

    cp $00
    jr nz, jr_001_50b0

    ldh a, [$99]
    sub $02
    ldh [$99], a
    ret


jr_001_50b0:
    ldh a, [$99]
    add $02
    ldh [$99], a
    ret


Call_001_50b7:
    ldh a, [$bb]
    cp $05
    ret nc

    ld a, l
    and $f0
    cp $10
    ret z

    cp $00
    jr nz, jr_001_50cd

    ldh a, [$9a]
    sub $02
    ldh [$9a], a
    ret


jr_001_50cd:
    ldh a, [$9a]
    add $02
    ldh [$9a], a
    ret


Jump_001_50d4:
jr_001_50d4:
    ld hl, $5183
    ldh a, [$ba]
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    cp $80
    jr nz, jr_001_50e7

    xor a
    ldh [$ba], a
    jr jr_001_50d4

jr_001_50e7:
    ld b, a
    ldh a, [$98]
    and $0c
    jr nz, jr_001_5116

    ldh a, [$99]
    add b
    ldh [$99], a
    ldh a, [$ba]
    inc a
    ldh [$ba], a
    ldh a, [$98]
    bit 1, a
    jr nz, jr_001_510a

    ldh a, [$9a]
    add $02
    ld hl, $d035
    add [hl]
    ldh [$9a], a
    jr jr_001_513c

jr_001_510a:
    ldh a, [$9a]
    sub $02
    ld hl, $d036
    sub [hl]
    ldh [$9a], a
    jr jr_001_513c

jr_001_5116:
    ldh a, [$9a]
    add b
    ldh [$9a], a
    ldh a, [$ba]
    inc a
    ldh [$ba], a
    ldh a, [$98]
    bit 2, a
    jr nz, jr_001_5132

    ldh a, [$99]
    add $02
    ld hl, $d038
    add [hl]
    ldh [$99], a
    jr jr_001_513c

jr_001_5132:
    ldh a, [$99]
    sub $02
    ld hl, $d037
    sub [hl]
    ldh [$99], a

jr_001_513c:
    ldh a, [$b7]
    ld l, a
    ldh a, [$b8]
    ld h, a
    inc hl
    inc hl
    ldh a, [$99]
    ld [hl+], a
    add $04
    ld [$c203], a
    ldh a, [$9a]
    ld [hl+], a
    add $04
    ld [$c204], a
    ldh a, [$ba]
    ld [hl], a
    ldh a, [frameCounter]
    and $01
    jp z, Jump_001_52e0

    call beam_getTileIndex
    ld hl, beamSolidityIndex
    cp [hl]
    jp nc, Jump_001_52e0

    cp $04
    jr nc, jr_001_5172

    call destroyRespawningBlock
    jp Jump_001_52f3


jr_001_5172:
    ld h, HIGH(collisionArray)
    ld l, a
    ld a, [hl]
    bit blockType_shot, a
    jp z, Jump_001_52f3
        ld a, $ff
        call Call_001_56e9
    jp Jump_001_52f3


    db $00, $07, $05, $02, $00, $fe, $fb, $f9, $00, $f9, $fb, $fe, $00, $02, $05, $07
    db $80

    ld a, [bc]
    or $f6
    ld a, [bc]
    ld a, [bc]
    or $f6
    ld a, [bc]
    ld a, [bc]
    or $f6
    ld a, [bc]
    add b
    nop

    db $00, $01, $00, $00, $01, $00, $01, $00, $01, $00, $01, $01, $01, $01, $02, $01
    db $02, $01, $02, $02, $02, $02, $03, $02, $02, $03, $02, $03, $03, $03, $03, $04
    db $ff

Jump_001_51c3:
    ldh a, [$bb]
    ld e, a
    ld d, $00
    ld hl, $51a1
    add hl, de
    ld a, [hl]
    cp $ff
    jr nz, jr_001_51d9

    ldh a, [$bb]
    dec a
    ldh [$bb], a
    ld a, [$51c1]

jr_001_51d9:
    ld b, a
    ldh a, [$98]
    bit 0, a
    jr z, jr_001_51ec

    ldh a, [$9a]
    add b
    ld hl, $d035
    add [hl]
    ldh [$9a], a
    jp Jump_001_5282


jr_001_51ec:
    bit 1, a
    jr z, jr_001_51fc

    ldh a, [$9a]
    sub b
    ld hl, $d036
    sub [hl]
    ldh [$9a], a
    jp Jump_001_5282


jr_001_51fc:
    bit 2, a
    jr z, jr_001_520b

    ldh a, [$99]
    sub b
    ld hl, $d037
    sub [hl]
    ldh [$99], a
    jr jr_001_5282

jr_001_520b:
    ldh a, [$99]
    add b
    ld hl, $d038
    add [hl]
    ldh [$99], a
    jr jr_001_5282

Jump_001_5216:
    ldh a, [$98]
    bit 0, a
    jr z, jr_001_5234

    ldh a, [$9a]
    add $04
    ld hl, $d035
    add [hl]
    ldh [$9a], a
    ldh a, [$b9]
    cp $04
    jr nz, jr_001_5282

    ldh a, [$9a]
    add $02
    ldh [$9a], a
    jr jr_001_5282

jr_001_5234:
    bit 1, a
    jr z, jr_001_5250

    ldh a, [$9a]
    sub $04
    ld hl, $d036
    sub [hl]
    ldh [$9a], a
    ldh a, [$b9]
    cp $04
    jr nz, jr_001_5282

    ldh a, [$9a]
    sub $02
    ldh [$9a], a
    jr jr_001_5282

jr_001_5250:
    bit 2, a
    jr z, jr_001_526c

    ldh a, [$99]
    sub $04
    ld hl, $d037
    sub [hl]
    ldh [$99], a
    ldh a, [$b9]
    cp $04
    jr nz, jr_001_5282

    ldh a, [$99]
    sub $02
    ldh [$99], a
    jr jr_001_5282

jr_001_526c:
    ldh a, [$99]
    add $04
    ld hl, $d038
    add [hl]
    ldh [$99], a
    ldh a, [$b9]
    cp $04
    jr nz, jr_001_5282

    ldh a, [$99]
    add $02
    ldh [$99], a

Jump_001_5282:
jr_001_5282:
    ldh a, [$b7]
    ld l, a
    ldh a, [$b8]
    ld h, a
    inc hl
    inc hl
    ldh a, [$99]
    ld [hl+], a
    add $04
    ld [$c203], a
    ldh a, [$9a]
    ld [hl+], a
    add $04
    ld [$c204], a
    ldh a, [$ba]
    ld [hl+], a
    ldh a, [$bb]
    ld [hl], a
    ldh a, [frameCounter]
    and $01
    jr z, jr_001_52e0

    call beam_getTileIndex
    ld hl, beamSolidityIndex
    cp [hl]
    jr nc, jr_001_52e0

    cp $04
    jr nc, jr_001_52b8
        call c, destroyRespawningBlock
            jr jr_001_52c6
    jr_001_52b8:

    ld h, HIGH(collisionArray)
    ld l, a
    ld a, [hl]
    bit blockType_shot, a
    jp z, Jump_001_52c6
        ld a, $ff
        call Call_001_56e9
    Jump_001_52c6:

jr_001_52c6:
    ldh a, [$b9]
    cp $07
    call z, Call_001_53af
    cp $03
    jr z, jr_001_52f3

    cp $04
    jr z, jr_001_52f3

    ldh a, [$b7]
    ld l, a
    ldh a, [$b8]
    ld h, a
    ld a, $ff
    ld [hl], a
    jr jr_001_52f3

Jump_001_52e0:
jr_001_52e0:
    call Call_000_31b6
    jr nc, jr_001_52f3

    ld a, $dd
    ld h, a
    ldh [$b8], a
    ld a, [$d032]
    swap a
    ld l, a
    ld a, $ff
    ld [hl], a

Jump_001_52f3:
jr_001_52f3:
    ld a, [$d032]
    inc a
    ld [$d032], a
    cp $03
    jp c, Jump_001_5011

    ret


Call_001_5300: ; draw projectiles ; 01:5300
    ld a, $00
    ld [$d032], a

Jump_001_5305:
    ld hl, projectileArray
    ld a, [$d032]
    swap a
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl+]
    ld d, a
    cp $ff
    jp z, Jump_001_5390

    ld a, [hl+]
    ld c, a
    ld a, [$c205]
    ld b, a
    ld a, [hl+]
    sub b
    ldh [hSpriteYPixel], a
    ld a, [$c206]
    ld b, a
    ld a, [hl]
    sub b
    ldh [hSpriteXPixel], a
    xor a
    ldh [hSpriteAttr], a
    ld a, d
    cp $08
    jr nz, jr_001_534c

    push hl
    ld hl, $539d
    ld a, c
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    ldh [hSpriteId], a
    ld hl, $53a6
    ld a, c
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    ldh [hSpriteAttr], a
    pop hl
    jr jr_001_5359

jr_001_534c:
    ld a, $7e
    ldh [hSpriteId], a
    ld a, c
    and $03
    jr nz, jr_001_5359

    ld a, $7f
    ldh [hSpriteId], a

jr_001_5359:
    ldh a, [hSpriteXPixel]
    cp $08
    jr c, jr_001_538a

    ldh a, [hSpriteXPixel]
    cp $a4
    jr nc, jr_001_538a

    ldh a, [hSpriteYPixel]
    cp $0c
    jr c, jr_001_538a

    ldh a, [hSpriteYPixel]
    cp $94
    jr nc, jr_001_538a

    ld h, $c0
    ldh a, [hOamBufferIndex]
    ld l, a
    ldh a, [hSpriteYPixel]
    ld [hl+], a
    ldh a, [hSpriteXPixel]
    ld [hl+], a
    ldh a, [hSpriteId]
    ld [hl+], a
    ldh a, [hSpriteAttr]
    ld [hl+], a
    ld a, l
    ldh [hOamBufferIndex], a
    xor a
    ldh [hSpriteAttr], a
    jr jr_001_5390

jr_001_538a:
    dec hl
    dec hl
    dec hl
    ld a, $ff
    ld [hl], a

Jump_001_5390:
jr_001_5390:
    ld a, [$d032]
    inc a
    ld [$d032], a
    cp $03
    jp c, Jump_001_5305

    ret


    nop

    db $98, $98

    nop

    db $99

    nop
    nop
    nop

    db $99

    nop

    db $00, $20

    nop

    db $00

    nop
    nop
    nop

    db $40

Call_001_53af:
    ld hl, $dd30

jr_001_53b2:
    ld a, [hl]
    cp $ff
    jr z, jr_001_53c3

    ld de, $0010
    add hl, de
    ld a, l
    swap a
    cp $06
    jr nz, jr_001_53b2

    ret


jr_001_53c3:
    ld a, $01
    ld [hl+], a
    ld a, $60
    ld [hl+], a
    ldh a, [$99]
    add $04
    ld [hl+], a
    ldh a, [$9a]
    add $04
    ld [hl+], a
    ld a, $13
    ld [sfxRequest_square1], a
    ret


Jump_001_53d9:
    ld a, [samusItems]
    bit itemBit_bomb, a
    ret z

    ldh a, [hInputRisingEdge]
    bit PADB_B, a
    ret z

    ld hl, $dd30

    jr_001_53e7:
        ld a, [hl]
        cp $ff
            jr z, jr_001_53f8
        ld de, $0010
        add hl, de
        ld a, l
        swap a
        cp $06
    jr nz, jr_001_53e7
    ret
    
    jr_001_53f8:

    ld a, $01
    ld [hl+], a
    ld a, $60
    ld [hl+], a
    ldh a, [hSamusYPixel]
    add $26
    ld [hl+], a
    ldh a, [hSamusXPixel]
    add $10
    ld [hl+], a
    ld a, $13
    ld [sfxRequest_square1], a
ret


Call_001_540e:
    xor a
    ld [$d032], a

    Jump_001_5412:
        ld hl, $dd30
        ld a, [$d032]
        swap a
        add l
        ld l, a
        ld a, [hl+]
        ldh [$98], a
        cp $ff
        jr z, jr_001_5490
            ld a, [hl+]
            ld c, a
            ld a, [$c205]
            ld b, a
            ld a, [hl+]
            ld [$d04a], a
            sub b
            ldh [hSpriteYPixel], a
            ld a, [$c206]
            ld b, a
            ld a, [hl]
            ld [$d04b], a
            sub b
            ldh [hSpriteXPixel], a
            ldh a, [hSpriteXPixel]
            cp $b0
            jr nc, jr_001_548a
                ldh a, [hSpriteYPixel]
                cp $b0
                jr nc, jr_001_548a
                    ldh a, [$98]
                    cp $01
                    jr nz, jr_001_545d
                        ld a, c
                        and $08
                        sla a
                        swap a
                        add $35
                        ldh [hSpriteId], a
                        call drawSamusSprite
                        jr jr_001_5490
                    jr_001_545d:
                    
                    ld a, c
                    cp $08
                    jr nz, jr_001_547e
                        ld a, [samusPose]
                        cp $18
                            call c, Call_001_54d7
                        ld a, c
                        srl a
                        add $31
                        ldh [hSpriteId], a
                        call drawSamusSprite
                        call $30bb
                        ld a, $0c
                        ld [sfxRequest_noise], a
                        jr jr_001_5490
                    jr_001_547e:
                        ld a, c
                        srl a
                        add $31
                        ldh [hSpriteId], a
                        call drawSamusSprite
                        jr jr_001_5490
            
            jr_001_548a:
                dec hl
                dec hl
                dec hl
                ld a, $ff
                ld [hl], a
        
        jr_001_5490:
        ld a, [$d032]
        inc a
        ld [$d032], a
        cp $03
    jp nz, Jump_001_5412
ret

Call_001_549d: ; 00:549D
    xor a
    ld [$d032], a

    jr_001_54a1:
        ld hl, $dd30
        ld a, [$d032]
        swap a
        add l
        ld l, a
        ld a, [hl+]
        ld b, a
        cp $ff
        jr z, jr_001_54c8
            ld a, [hl]
            dec a
            ld [hl], a
            jr nz, jr_001_54c8
                ld a, b
                cp $01
                jr z, jr_001_54c1
                    dec hl
                    ld a, $ff
                    ld [hl], a
                    jr jr_001_54c8
                jr_001_54c1:
        
                dec hl
                ld a, $02
                ld [hl+], a
                ld a, $08
                ld [hl], a
        jr_001_54c8:
        
        ld a, [$d032]
        inc a
        ld [$d032], a
        cp $03
    jr nz, jr_001_54a1

    call Call_001_540e
ret


Call_001_54d7:
    push bc
    push de
    push hl
    ldh a, [hSpriteYPixel]
    ld b, a
    ld a, [$d03b]
    sub $20
    cp b
    jr nc, jr_001_5525
        ld a, [$d03b]
        add $20
        cp b
        jr c, jr_001_5525
            ldh a, [hSpriteXPixel]
            ld b, a
            ld a, [$d03c]
            sub $10
            cp b
            jr nc, jr_001_5525
                ld a, [$d03c]
                add $10
                cp b
                jr c, jr_001_5525
                    ld c, $ff
                    ld a, [$d03c]
                    sub b
                    jr c, jr_001_550e
                        ld c, $00
                        jr z, jr_001_550e
                            ld c, $01
                    jr_001_550e:
                    ld a, c
                    ld [$d00f], a
                    ld a, $40
                    ld [samus_jumpArcCounter], a
                    ld a, [samusPose]
                    ld e, a
                    ld d, $00
                    ld hl, table_55DD
                    add hl, de
                    ld a, [hl]
                    ld [samusPose], a
    jr_001_5525:

    ld a, [$d04a]
    sub $10
    ld [$c203], a
    ld a, [$d04b]
    ld [$c204], a
    call beam_getTileIndex
    cp $04
    jr nc, jr_001_553f
        call destroyRespawningBlock
        jr jr_001_554d
    jr_001_553f:
        ld h, HIGH(collisionArray)
        ld l, a
        ld a, [hl]
        bit blockType_bomb, a
        jp z, Jump_001_554d
            ld a, $ff
            call Call_001_56e9
        Jump_001_554d:
    jr_001_554d:

    ld a, [$d04a]
    ld [$c203], a
    call beam_getTileIndex
    cp $04
    jr nc, jr_001_555f
        call destroyRespawningBlock
        jr jr_001_556d
    jr_001_555f:
        ld h, HIGH(collisionArray)
        ld l, a
        ld a, [hl]
        bit blockType_bomb, a
        jp z, Jump_001_556d
            ld a, $ff
            call Call_001_56e9
        Jump_001_556d:
    jr_001_556d:

    ld a, [$d04a]
    add $10
    ld [$c203], a
    call beam_getTileIndex
    cp $04
    jr nc, jr_001_5581
        call destroyRespawningBlock
        jr jr_001_558f
    jr_001_5581:
        ld h, HIGH(collisionArray)
        ld l, a
        ld a, [hl]
        bit blockType_bomb, a
        jp z, Jump_001_558f
            ld a, $ff
            call Call_001_56e9
        Jump_001_558f:
    jr_001_558f:

    ld a, [$d04a]
    ld [$c203], a
    ld a, [$d04b]
    add $10
    ld [$c204], a
    call beam_getTileIndex
    cp $04
    jr nc, jr_001_55a9
        call destroyRespawningBlock
        jr jr_001_55b7
    jr_001_55a9:
        ld h, HIGH(collisionArray)
        ld l, a
        ld a, [hl]
        bit blockType_bomb, a
        jp z, Jump_001_55b7
            ld a, $ff
            call Call_001_56e9
        Jump_001_55b7:
    jr_001_55b7:

    ld a, [$d04b]
    sub $10
    ld [$c204], a
    call beam_getTileIndex
    cp $04
    jr nc, jr_001_55cb
        call destroyRespawningBlock
        jr jr_001_55d9
    jr_001_55cb:
        ld h, HIGH(collisionArray)
        ld l, a
        ld a, [hl]
        bit blockType_bomb, a
        jp z, Jump_001_55d9
            ld a, $ff
            call Call_001_56e9
        Jump_001_55d9:
    jr_001_55d9:

    pop hl
    pop de
    pop bc
ret

table_55DD: ; 01:55DD - Pose related
    db $11
    db $11
    db $11
    db $11
    db $11
    db $12
    db $12
    db $11
    db $12
    db $11
    db $11
    db $12
    db $12
    db $12
    db $12
    db $11
    db $12
    db $11
    db $12
    db $11
    db $00
    db $00
    db $00
    db $00
    db $12
    db $12
    db $1A
    db $1B
    db $1C
    db $1D

table_55FB: ; 01:55FB - Projectile X offsets
; Column index into table is based off of facing direction
; Row index is based off of you facing direction of the table_5643
    db $00, $00
    db $18, $1C ; Right
    db $04, $08 ; Left
    db $10, $10
    db $0E, $12 ; Up
    db $10, $10
    db $10, $10
    db $10, $10
    db $0D, $13 ; Down
    db $10, $10
    db $10, $10
    db $10, $10
    db $10, $10
    db $10, $10
    db $10, $10
    db $10, $10
    db $10, $10

table_561D: ; 01:561D - Projectile y-offsets per pose
    db $17
    db $1F
    db $00
    db $14
    db $21
    db $00
    db $00
    db $1D
    db $00
    db $15
    db $15
    db $00
    db $00
    db $00
    db $00
    db $1F
    db $00
    db $1F
    db $00
    
table_5630: ; 01:5630 - Projectile y offset due to firing direction
    db $00
    db $00
    db $00
    db $00
    db $F0
    db $00
    db $00
    db $00
    db $08
    db $00
    db $00
    db $00
    db $00
    db $00
    db $00
    db $00
    db $1F
    db $00
    db $00
    
table_5643: ; 01:5643 - Shot direction based on directional input
    db $00
    db $01
    db $02
    db $01
    db $04
    db $04
    db $04
    db $04
    db $08
    db $08
    db $08
    db $08
    db $08
    db $08
    db $08
    db $08

table_5653: ; 01:5653 - Possible shot directions
    db $07
    db $0F
    db $00
    db $07
    db $03
    db $80
    db $80
    db $0F
    db $80
    db $0F
    db $0F
    db $80
    db $80
    db $80
    db $80
    db $0F
    db $80
    db $0F
    db $80
    db $00
    db $00
    db $00
    db $00
    db $00
    db $00
    db $80
    db $00
    db $80
    db $00
    db $80

destroyRespawningBlock: ; 01:5671
    ld hl, $d900

    .findLoop:
        ld a, [hl]
        and a
            jr z, .break    
        ld a, l
        add $10
        ld l, a
        cp $00
            ret z
    jr .findLoop
    .break:

    ld a, $01
    ld [hl+], a
    ld a, [$c203]
    ld [hl+], a
    ld a, [$c204]
    ld [hl+], a
    ; Request sound effect
    ld a, $04
    ld [sfxRequest_noise], a
ret

handleRespawningBlocks: ; 01:5692
    ld hl, $d900
    .loop:
        ; Skip block if timer is zero
        ld a, [hl]
        and a
        jr z, .nextBlock
            ; Increment frame counter
            inc a
            ld [hl+], a
            ; Compare scroll y and tile y
            ld a, [$c205]
            ld b, a
            ld a, [hl+]
            ld [$c203], a
            sub b
            and $f0
            cp $c0
                jr z, .removeBlock
        
            ; Control scroll x and tile x
            ld a, [$c206]
            ld b, a
            ld a, [hl]
            ld [$c204], a
            sub b
            and $f0
            cp $d0
                jr z, .removeBlock
        
            dec hl
            dec hl
            ld a, [hl]
            cp $02
                jp z, Jump_001_5742
            cp $07
                jp z, Jump_001_5769
            cp $0d
                jr z, jr_001_56e9
            cp $f6
                jp z, Jump_001_5769
            cp $fa
                jr z, jr_001_5742
            cp $fe
                jr z, jr_001_5712
        
            jr .nextBlock
        
        .removeBlock: ; Clear the 
            ld a, l
            and $f0
            ld l, a
            xor a
            ld [hl], a
    
    .nextBlock:
        ld a, l
        and $f0
        add $10
        ld l, a
        and a
    jr nz, .loop
ret


Call_001_56e9:
jr_001_56e9: ; Destroy block (frame 3)
    call getTilemapAddress
    ld a, [$c215]
    and $de
    ld l, a
    ld a, [$c216]
    ld h, a
    ld de, $001f

    jr_001_56f9:
        ldh a, [rSTAT]
        and $03
    jr nz, jr_001_56f9

    jr_001_56ff:
        ldh a, [rSTAT]
        and $03
    jr nz, jr_001_56ff

    ; Destroy block (turn to blank)
    ld a, $ff
    ld [hl+], a
    ld [hl], a
    add hl, de
    ld [hl+], a
    ld [hl], a

    ld a, $04
    ld [sfxRequest_noise], a
ret


jr_001_5712: ; Restore block (frame 3)
    xor a
    ld [hl], a
    call getTilemapAddress
    ld a, [$c215]
    and $de
    ld l, a
    ld a, [$c216]
    ld h, a
    ld de, $001f

    jr_001_5724:
        ldh a, [rSTAT]
        and $03
    jr nz, jr_001_5724

    jr_001_572a:
        ldh a, [rSTAT]
        and $03
    jr nz, jr_001_572a

    xor a
    ld [hl+], a
    inc a
    ld [hl], a
    add hl, de
    inc a
    ld [hl+], a
    inc a
    ld [hl], a
    ld a, [samusInvulnerableTimer]
    and a
        ret nz

    call Call_001_5790
ret


Jump_001_5742: ; Destroy block (frame 1), Restore block (frame 2)
jr_001_5742:
    call getTilemapAddress
    ld a, [$c215]
    and $de
    ld l, a
    ld a, [$c216]
    ld h, a
    ld de, $001f

    jr_001_5752:
        ldh a, [rSTAT]
        and $03
    jr nz, jr_001_5752

    jr_001_5758:
        ldh a, [rSTAT]
        and $03
    jr nz, jr_001_5758

    ld a, $04
    ld [hl+], a
    inc a
    ld [hl], a
    add hl, de
    inc a
    ld [hl+], a
    inc a
    ld [hl], a
ret


Jump_001_5769: ; Destroy block (frame 2), Restore block (frame 1)
    call getTilemapAddress
    ld a, [$c215]
    and $de
    ld l, a
    ld a, [$c216]
    ld h, a
    ld de, $001f

    jr_001_5779:
        ldh a, [rSTAT]
        and $03
    jr nz, jr_001_5779

    jr_001_577f:
        ldh a, [rSTAT]
        and $03
    jr nz, jr_001_577f

    ld a, $08
    ld [hl+], a
    inc a
    ld [hl], a
    add hl, de
    inc a
    ld [hl+], a
    inc a
    ld [hl], a
    ret


Call_001_5790:
    ; Index into table with Samus' pose
    ld hl, table_57DF
    ld a, [samusPose]
    ld e, a
    ld d, $00
    add hl, de
    
    ld a, [hl]
    ld b, a
    ld a, [$c203]
    sub $10
    and $f0
    ld c, a
    ldh [$98], a
    ldh a, [hSamusYPixel]
    add $18
    sub c
    cp b
        jr nc, .exit

    ld a, [$c204]
    sub $08
    and $f0
    ld b, a
    ldh [$99], a
    ldh a, [hSamusXPixel]
    add $0c
    sub b
    cp $18
        jr nc, .exit

    cp $0c
    jr nc, .else
        ld a, $ff
        ld [$c423], a
        jr .endIf
    .else:
        ld a, $01
        ld [$c423], a
    .endIf:
    
    ld a, $01
    ld [samus_hurtFlag], a
    ld a, $02
    ld [samus_damageValue], a
    call destroyRespawningBlock

.exit:
    ret

; Pose related
table_57DF: ; 01:57DF
    db $20, $20, $20, $20, $20, $10, $10, $20, $10, $20, $20, $10, $10, $10, $10, $20
    db $10, $20, $10

;------------------------------------------------------------------------------
Call_001_57f2: ; 01:57F2
    ld a, [$d088]
    and a
    jr z, jr_001_57fc
        dec a
        ld [$d088], a
    jr_001_57fc:

    ld a, [$d08b]
    cp $11
    jr z, jr_001_5873

    ldh a, [rLCDC]
    bit 5, a
    jr nz, jr_001_580d
        set 5, a
        ldh [rLCDC], a
    jr_001_580d:

    ld a, $88
    ldh [rWY], a
    ld a, [saveContactFlag]
    and a
        jr nz, jr_001_582a

    ld a, [$d093]
    and a
    jr z, jr_001_5873

    ld a, [$d093]
    cp $0b
    jr nc, jr_001_5873

    ld a, $80
    ldh [rWY], a
    jr jr_001_5873

jr_001_582a:
    ld a, $80
    ldh [rWY], a
    ld a, [$d088]
    and a
    jr nz, jr_001_5843
        ldh a, [hInputRisingEdge]
        cp PADF_START
        jr nz, jr_001_5843
            ld a, $09
            ldh [gameMode], a
            ld a, $ff
            ld [$d088], a
    jr_001_5843:

    ld a, [$d088]
    and a
    jr z, jr_001_585a
        ; Draw save "Completed" sprite
        ld a, $98
        ldh [hSpriteYPixel], a
        ld a, $44
        ldh [hSpriteXPixel], a
        ld a, $43
        ldh [hSpriteId], a
        call drawSamusSprite
        jr jr_001_5873
    jr_001_585a:
        ; Draw blinking "Press Start" sprite
        xor a
        ld [saveContactFlag], a
        ldh a, [frameCounter]
        bit 3, a
        jr z, jr_001_5873
            ld a, $98
            ldh [hSpriteYPixel], a
            ld a, $44
            ldh [hSpriteXPixel], a
            ld a, $42
            ldh [hSpriteId], a
            call drawSamusSprite
    jr_001_5873:

    ldh a, [frameCounter]
    and a
    jr nz, jr_001_589a
        ld a, [nextEarthquakeTimer]
        and a
        jr z, jr_001_589a
            dec a
            ld [nextEarthquakeTimer], a
            jr nz, jr_001_589a
                ld a, $ff
                ld [earthquakeTimer], a
                ld a, $0e
                ld [$cede], a
                ld a, [metroidCountReal]
                cp $01
                jr nz, jr_001_589a
                    ld a, $60
                    ld [earthquakeTimer], a
    jr_001_589a:

    ld a, [samusPose]
    cp pose_faceScreen
    jr nz, jr_001_58ab

    ld a, [countdownTimerLow]
    ld b, a
    ld a, [countdownTimerHigh]
    or b
    jr nz, jr_001_58d8

jr_001_58ab:
    ld a, [samusCurHealthHigh]
    and a
    jr nz, jr_001_58cd

    ld a, [samusCurHealthLow]
    cp $50
    jr nc, jr_001_58cd

    ld b, a
    ld a, [$d0a1]
    cp b
    jr z, jr_001_58d8

    ld a, b
    ld [$d0a1], a
    and $f0
    swap a
    inc a
    ld [$cfe5], a
    jr jr_001_58d8

jr_001_58cd:
    ld a, [$cfe6]
    and a
    jr z, jr_001_58d8

    ld a, $ff
    ld [$cfe5], a

jr_001_58d8:
    ld a, [$d09b]
    and a
    call nz, Call_001_7a45
    ld a, [$d0a6]
    and a
    jr z, jr_001_58f0
        ldh a, [frameCounter]
        and $7f
        jr nz, jr_001_58f0
            ld a, $17
            ld [sfxRequest_noise], a
    jr_001_58f0:
ret

; Item message pointers and strings:
itemTextPointerTable: ; 01:58F1
    include "data/itemNames.asm"

Call_001_5a11: ; Draw enemies - 01:5A11
    ld a, [$c426]
    and a
    ret z

    ld hl, $c600
    ld a, l
    ld [$c454], a
    ld a, h
    ld [$c455], a

    jr_001_5a21:
        ld a, [hl]
        and a
        call z, Call_001_5a3f
        ld a, [$c454]
        ld l, a
        ld a, [$c455]
        ld h, a
        ld de, $0020
        add hl, de
        ld a, l
        ld [$c454], a
        ld a, h
        ld [$c455], a
        cp $c8
    jr nz, jr_001_5a21

    ret

; Render enemy sprite
Call_001_5a3f:
    call Call_001_5a9a
    ld a, [$c430]
    ld d, $00
    ld e, a
    sla e
    rl d
    ld hl, $5ab1
    add hl, de
    ld a, [hl+]
    ld e, a
    ld a, [hl]
    ld d, a

    ld h, $c0
    ldh a, [hOamBufferIndex]
    ld l, a

    ld a, [$c42e]
    ld b, a
    ld a, [$c42f]
    ld c, a

    jr_001_5a61:
        ld a, [de]
        cp $ff
            jr z, jr_001_5a99
    
        ld a, [$c431]
        bit 6, a
        jr z, jr_001_5a73
            ld a, [de]
            cpl
            sub $07
            jr jr_001_5a74
        jr_001_5a73:
            ld a, [de]
        jr_001_5a74:
    
        add b
        ld [hl+], a
        inc de
        ld a, [$c431]
        bit 5, a
        jr z, jr_001_5a84
            ld a, [de]
            cpl
            sub $07
            jr jr_001_5a85
        jr_001_5a84:
            ld a, [de]
        jr_001_5a85:
    
        add c
        ld [hl+], a
        inc de
        ld a, [de]
        ld [hl+], a
        inc de
        push hl
        ld hl, $c431
        ld a, [de]
        xor [hl]
        pop hl
        ld [hl+], a
        ld a, l
        ldh [hOamBufferIndex], a
        inc de
    jr jr_001_5a61

jr_001_5a99: ; .break
ret

; Get base information for enemy sprite to render
Call_001_5a9a:
    inc l
    ; y pos
    ld a, [hl+]
    ld [$c42e], a
    ; x pos
    ld a, [hl+]
    ld [$c42f], a
    ; sprite type
    ld a, [hl+]
    ld [$c430], a
    ; Attributes
    ld a, [hl+]
    xor [hl]
    inc l
    xor [hl]
    and $f0
    ld [$c431], a
ret

; 01:5AB1
include "data/sprites_enemies.asm"

Call_001_70ba: ; 01:70BA - called from bank 2 (Alpha Metroid related?)
    call Call_001_70c1
    call Call_001_70fe
    ret

Call_001_70c1:
    ld hl, $ffe1
    ld a, [hl]
    add $10
    ld b, a
    ld a, [$d03b]
    sub b
    jr c, jr_001_70d5
        ld b, $00
        jr z, jr_001_70d9
            inc b
            jr jr_001_70d9
    jr_001_70d5:
        cpl
        inc a
        ld b, $ff
    jr_001_70d9:

    ld [$c45d], a
    ld a, b
    ld [$c45b], a
    inc l
    ld a, [hl]
    add $10
    ld b, a
    ld a, [$d03c]
    sub b
    jr c, jr_001_70f2
        ld b, $00
        jr z, jr_001_70f6
            inc b
            jr jr_001_70f6
    jr_001_70f2:
        cpl
        inc a
        ld b, $ff
    jr_001_70f6:

    ld [$c45e], a
    ld a, b
    ld [$c45a], a
ret


Call_001_70fe:
    ld a, [$c45a]
    and a
    jr z, jr_001_7147

    ld c, a
    ld a, [$c45b]
    and a
    jr z, jr_001_713a

    inc a
    jr z, jr_001_7119

    inc c
    jr z, jr_001_7115
        ld a, $04
        jr jr_001_7122
    jr_001_7115:
        ld a, $09
        jr jr_001_7122

jr_001_7119:
    inc c
    jr z, jr_001_7120
        ld a, $0e
        jr jr_001_7122
    jr_001_7120:
        ld a, $13

jr_001_7122:
    ld [$c45c], a
    call Call_001_7170
    call Call_001_7189

jr_001_712b:
    ld a, [$c45c]
    ld e, a
    ld d, $00
    ld hl, table_7158
    add hl, de
    ld a, [hl]
    ld [hEnemyState], a
    ret


jr_001_713a:
    ld a, [$c45a]
    dec a
    jr z, jr_001_7144
        ld a, $01
        jr jr_001_7153
    jr_001_7144:
        xor a
        jr jr_001_7153

jr_001_7147:
    ld a, [$c45b]
    dec a
    jr z, jr_001_7151
        ld a, $03
        jr jr_001_7153
    jr_001_7151:
        ld a, $02

jr_001_7153:
    ld [$c45c], a
    jr jr_001_712b

table_7158: ; 01:7158 - Enemy state transition table?
    db $00, $01, $02, $03, $00, $04, $05, $06, $02, $01, $07, $08, $09, $02, $00, $0A
    db $0B, $0C, $03, $01, $0D, $0E, $0F, $03

Call_001_7170:
    ld b, $64
    ld a, [$c45d]
    ld e, a
    call Call_001_73b9
    ld a, [$c45e]
    ld c, a
    call Call_001_73cc
    ld a, l
    ld [$c45f], a
    ld a, h
    ld [$c460], a
ret


Call_001_7189:
    ld a, [$c460]
    and a
    jr nz, jr_001_71a0

    ld a, [$c45f]
    cp $14
    jr c, jr_001_71b1

    cp $3c
    jr c, jr_001_71b5

    cp $c8
    jr c, jr_001_71b9

    jr jr_001_71bd

jr_001_71a0:
    cp $02
    jr z, jr_001_71a8

    jr nc, jr_001_71c1

    jr jr_001_71bd

jr_001_71a8:
    ld a, [$c45f]
    cp $58
    jr nc, jr_001_71c1

    jr jr_001_71bd

jr_001_71b1:
    ld b, $00
    jr jr_001_71c3

jr_001_71b5:
    ld b, $01
    jr jr_001_71c3

jr_001_71b9:
    ld b, $02
    jr jr_001_71c3

jr_001_71bd:
    ld b, $03
    jr jr_001_71c3

jr_001_71c1:
    ld b, $04

jr_001_71c3:
    ld a, [$c45c]
    add b
    ld [$c45c], a
ret

Call_001_71cb: ; 01:71CB
    ld hl, table_71DB
    ld a, [hEnemyState]
    add a
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl+]
    ld d, [hl]
    ld h, d
    ld l, a
    jp hl
    
    table_71DB: ; 01:71DB
        dw func_71FB
        dw func_71FF
        dw func_7203
        dw func_7207 ; Possibly unused?
        dw func_720B
        dw func_720F
        dw func_7213
        dw func_7217
        dw func_721B
        dw func_721F
        dw func_7223
        dw func_7227
        dw func_722B
        dw func_722F
        dw func_7233
        dw func_7237

func_71FB: ld bc, $0003
    ret

func_71FF: ld bc, $0083
    ret

func_7203: ld bc, $0300
    ret

func_7207: ld bc, $8300
    ret

func_720B: ld bc, $0103
    ret

func_720F: ld bc, $0202
    ret

func_7213: ld bc, $0301
    ret

func_7217: ld bc, $0183
    ret

func_721B: ld bc, $0282
    ret

func_721F: ld bc, $0381
    ret

func_7223: ld bc, $8103
    ret

func_7227: ld bc, $8202
    ret

func_722B: ld bc, $8301
    ret

func_722F: ld bc, $8183
    ret

func_7233: ld bc, $8282
    ret

func_7237: ld bc, $8381
    ret

Call_001_723b: ; 01:723B
    call Call_001_70c1
    call Call_001_7242
    ret


Call_001_7242:
    ld a, [$c45a]
    and a
    jr z, jr_001_728b

    ld c, a
    ld a, [$c45b]
    and a
    jr z, jr_001_727e

    inc a
    jr z, jr_001_725d

    inc c
    jr z, jr_001_7259

    ld a, $04
    jr jr_001_7266

jr_001_7259:
    ld a, $0b
    jr jr_001_7266

jr_001_725d:
    inc c
    jr z, jr_001_7264

    ld a, $12
    jr jr_001_7266

jr_001_7264:
    ld a, $19

jr_001_7266:
    ld [$c45c], a
    call Call_001_7170
    call Call_001_72bc

jr_001_726f:
    ld a, [$c45c]
    ld e, a
    ld d, $00
    ld hl, table_729C
    add hl, de
    ld a, [hl]
    ld [hEnemyState], a
    ret


jr_001_727e:
    ld a, [$c45a]
    dec a
    jr z, jr_001_7288

    ld a, $01
    jr jr_001_7297

jr_001_7288:
    xor a
    jr jr_001_7297

jr_001_728b:
    ld a, [$c45b]
    dec a
    jr z, jr_001_7295

    ld a, $03
    jr jr_001_7297

jr_001_7295:
    ld a, $02

jr_001_7297:
    ld [$c45c], a
    jr jr_001_726f

table_729C: ; 01:729C - State transition table?
    db $00, $01, $02, $03, $00, $04, $05, $06, $07, $08, $02, $01, $09, $0A, $0B, $0C
    db $0D, $02, $00, $0E, $0F, $10, $11, $12, $03, $01, $13, $14, $15, $16, $17, $03


Call_001_72bc:
    ld a, [$c460]
    and a
    jr nz, jr_001_72d7

    ld a, [$c45f]
    cp $0c
    jr c, jr_001_72f7

    cp $26
    jr c, jr_001_72fb

    cp $4b
    jr c, jr_001_72ff

    cp $96
    jr c, jr_001_7303

    jr jr_001_7307

jr_001_72d7:
    cp $03
    jr z, jr_001_72e5

    jr nc, jr_001_730f

    cp $01
    jr z, jr_001_72ee

    jr nc, jr_001_730b

    jr jr_001_7307

jr_001_72e5:
    ld a, [$c45f]
    cp $20
    jr nc, jr_001_730f

    jr jr_001_730b

jr_001_72ee:
    ld a, [$c45f]
    cp $2c
    jr nc, jr_001_730b

    jr jr_001_7307

jr_001_72f7:
    ld b, $00
    jr jr_001_7311

jr_001_72fb:
    ld b, $01
    jr jr_001_7311

jr_001_72ff:
    ld b, $02
    jr jr_001_7311

jr_001_7303:
    ld b, $03
    jr jr_001_7311

jr_001_7307:
    ld b, $04
    jr jr_001_7311

jr_001_730b:
    ld b, $05
    jr jr_001_7311

jr_001_730f:
    ld b, $06

jr_001_7311:
    ld a, [$c45c]
    add b
    ld [$c45c], a
    ret

Call_001_7319: ; 01:7319
    ld hl, table_7329
    ld a, [hEnemyState]
    add a
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl+]
    ld d, [hl]
    ld h, d
    ld l, a
    jp hl

table_7329: ; 01:7329
    dw func_7359
    dw func_735D
    dw func_7361
    dw func_7365
    dw func_7369
    dw func_736D
    dw func_7371
    dw func_7375
    dw func_7379
    dw func_737D
    dw func_7381
    dw func_7385
    dw func_7389
    dw func_738D
    dw func_7391
    dw func_7395
    dw func_7399
    dw func_739D
    dw func_73A1
    dw func_73A5
    dw func_73A9
    dw func_73AD
    dw func_73B1
    dw func_73B5 ; Possibly unused?

func_7359: ld bc, $0004
    ret

func_735D: ld bc, $0084
    ret

func_7361: ld bc, $0400
    ret

func_7365: ld bc, $8400
    ret

func_7369: ld bc, HeaderLogo
    ret

func_736D: ld bc, $0204
    ret

func_7371: ld bc, $0303
    ret

func_7375: ld bc, $0402
    ret

func_7379: ld bc, $0401
    ret

func_737D: ld bc, $0184
    ret

func_7381: ld bc, $0284
    ret

func_7385: ld bc, $0383
    ret

func_7389:
    ld bc, $0482
    ret

func_738D: ld bc, $0481
    ret

func_7391: ld bc, $8104
    ret

func_7395: ld bc, $8204
    ret

func_7399: ld bc, $8303
    ret

func_739D: ld bc, $8402
    ret

func_73A1: ld bc, $8401
    ret

func_73A5: ld bc, $8184
    ret

func_73A9: ld bc, $8284
    ret

func_73AD: ld bc, $8383
    ret

func_73B1: ld bc, $8482
    ret

func_73B5: ld bc, $8481
    ret


Call_001_73b9:
    ld hl, $0000
    ld c, l
    ld a, $08

jr_001_73bf:
    srl b
    rr c
    sla e
    jr nc, jr_001_73c8

    add hl, bc

jr_001_73c8:
    dec a
    jr nz, jr_001_73bf

    ret


Call_001_73cc:
    ld a, h
    or l
    ret z

    ld de, $0000
    ld b, $10
    sla l
    rl h
    rl e
    rl d

jr_001_73dc:
    ld a, e
    sub c
    ld a, d
    sbc $00
    jr c, jr_001_73ea

    ld a, e
    sub c
    ld e, a
    ld a, d
    sbc $00
    ld d, a

jr_001_73ea:
    ccf
    rl l
    rl h
    rl e
    rl d
    dec b
    jr nz, jr_001_73dc

    ret

; Draws sprites for title and credits
drawNonGameSprite: ; 01:73F7
    ; Index into sprite pointer table
    ldh a, [hSpriteId]
    ld d, $00
    ld e, a
    sla e
    rl d
    ld hl, creditsSpritePointerTable
    add hl, de
    ; Load pointer from table
    ld a, [hl+]
    ld e, a
    ld a, [hl]
    ld d, a
    ; Prep HL
    ld h, $c0
    ldh a, [hOamBufferIndex]
    ld l, a
    ; Store x and y offsets of sprite in B and C
    ldh a, [hSpriteYPixel]
    ld b, a
    ldh a, [hSpriteXPixel]
    ld c, a

    .spriteLoop:
        ; Load y coordinate
        ld a, [de]
        cp $ff
            jr z, .exit
        ; Handle y flipping
        ldh a, [hSpriteAttr]
        bit OAMB_YFLIP, a
        jr z, .else_A
            ld a, [de]
            cpl
            sub $07
            jr .endIf_A
        .else_A:
            ld a, [de]
        .endIf_A:
        ; Add y offset and store
        add b
        ld [hl+], a

        ; Load x coordinate
        inc de
        ldh a, [hSpriteAttr]
        bit OAMB_XFLIP, a
        jr z, .else_B
            ld a, [de]
            cpl
            sub $07
            jr .endIf_B
        .else_B:
            ld a, [de]
        .endIf_B:
    
        add c
        ld [hl+], a
        ; Load tile number
        inc de
        ld a, [de]
        ld [hl+], a
        ; Load sprite attribute byte
        inc de
        push hl
            ld hl, hSpriteAttr
            ld a, [de]
            xor [hl]
        pop hl
        ld [hl+], a
        ; Adjust indeces for next loop iteration
        ld a, l ; Assumes OAM buffer address is $00 aligned?
        ldh [hOamBufferIndex], a
        inc de
    jr .spriteLoop

    .exit:
ret

; 01:744A
include "data/sprites_credits.asm" ; Also title

Call_001_79ef: ; 01:79EF: Handle earthquake (called from bank 0)
    ld a, [earthquakeTimer]
    and a
        ret z

    ; Value of A oscillates between 1 and -1 every two frames
    and $02
    dec a
    ld b, a
    ; Adjust scroll
    ld a, [$c205]
    add b
    ld [$c205], a

    ldh a, [frameCounter]
    and $01
        ret nz

    ld a, [earthquakeTimer]
    dec a
    ld [earthquakeTimer], a
        ret nz

    xor a
    ld [$cedf], a
    ld a, [$d08b]
    cp $10
    jr nc, jr_001_7a2e
        ld a, [$d0a5]
        and a
        jr z, jr_001_7a28
            ld [songRequest], a
            ld [currentRoomSong], a
            xor a
            ld [$d0a5], a
            ret
        jr_001_7a28:
            ld a, $03
            ld [$cede], a
            ret
    jr_001_7a2e:
        ld a, $01
        ld [songRequest], a
        ret


drawSamus_earthquakeAdjustment: ; 01:7A34
    ld a, [earthquakeTimer]
    and a
        ret z
    ; Alternate between +1 and -1 pixel based on timer (every 4 frames)
    and %00000100 ; $04
    srl a
    dec a
    ld b, a
    ; Add adjustment
    ldh a, [hSpriteYPixel]
    add b
    ldh [hSpriteYPixel], a
ret


Call_001_7a45:
    ld hl, $7a69
    ld a, [$d09b]
    and $f0
    swap a
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    ld [bg_palette], a
    ld [ob_palette0], a
    ld a, [$d09b]
    dec a
    ld [$d09b], a
    cp $0e
    ret nc

    xor a
    ld [$d09b], a
    ret

; 01:7A69
    db $93, $e7, $fb


saveEnemyFlagsToSRAM: ; 01:7A6C
    ld d, $00
    ld a, [previousLevelBank]
    sub $09
    swap a
    add a
    add a
    ld e, a
    rl d
    ld hl, saveBuf_enemySaveFlags
    add hl, de
    ld de, enemySaveFlags
    ld b, $40

    ; Save active enemy save flags to save buffer
    .bufferLoop:
        ld a, [de]
        cp $02
            jr z, .case_A
        cp $fe
            jr z, .case_A
        cp $04
            jr nz, .case_B
        ld a, $fe
    
        .case_A:
            ld [hl], a
        .case_B:
            inc l
            inc e
            dec b
    jr nz, .bufferLoop

    ; Enable SRAM
    ld a, $0a
    ld [$0000], a

    ld de, saveData_objList_baseAddr
    ld a, [activeSaveSlot]
    add a
    add d
    ld d, a
    ld hl, saveBuf_enemySaveFlags
    ld bc, $01c0

    .saveLoop:
        ld a, [hl+]
        ld [de], a
        inc de
        dec bc
        ld a, b
        or c
    jr nz, .saveLoop

    ; Disable SRAM
    xor a
    ld [$0000], a
ret

; Loads enemy save flags from SRAM to a WRAM buffer.
loadEnemySaveFlags: ; 01:7AB9
    ld a, $0a
    ld [$0000], a
    ld de, saveBuf_enemySaveFlags
    ld bc, $01c0
    ld hl, saveData_objList_baseAddr
    ld a, [activeSaveSlot]
    add a
    add h
    ld h, a

    .loadLoop:
        ld a, [hl+]
        ld [de], a
        inc de
        dec bc
        ld a, b
        or c
    jr nz, .loadLoop

    ld a, $00
    ld [$0000], a
    
    xor a
    ld [$c436], a
ret

saveFileToSRAM: ; 01:7ADF
    ; Enable SRAM
    ld a, $0a
    ld [$0000], a

    ld hl, saveFile_magicNumber
    ld a, [activeSaveSlot]
    sla a
    sla a
    swap a
    ld e, a
    ld d, HIGH(saveData_baseAddr)
    ld b, $08

    .loop_A: ; Copy magic number to save file
        ld a, [hl+]
        ld [de], a
        inc de
        dec b
    jr nz, .loop_A

    ld a, [activeSaveSlot]
    sla a
    sla a
    swap a
    add $08
    ld l, a
    ld h, HIGH(saveData_baseAddr)
    
    ldh a, [hSamusYPixel]
    ld [hl+], a
    ldh a, [hSamusYScreen]
    ld [hl+], a
    ldh a, [hSamusXPixel]
    ld [hl+], a
    ldh a, [hSamusXScreen]
    ld [hl+], a
    ldh a, [hCameraYPixel]
    ld [hl+], a
    ldh a, [hCameraYScreen]
    ld [hl+], a
    ldh a, [hCameraXPixel]
    ld [hl+], a
    ldh a, [hCameraXScreen]
    ld [hl+], a

    ld de, saveBuffer + $08
    ld b, $0d
    .loop_B: ; Save graphics pointers and such
        ld a, [de]
        inc de
        ld [hl+], a
        dec b
    jr nz, .loop_B

    ld a, [samusItems]
    ld [hl+], a
    ld a, [samusBeam]
    ld [hl+], a
    ld a, [samusEnergyTanks]
    ld [hl+], a
    ld a, [samusCurHealthLow]
    ld [hl+], a
    ld a, [samusCurHealthHigh]
    ld [hl+], a
    ld a, [samusMaxMissilesLow]
    ld [hl+], a
    ld a, [samusMaxMissilesHigh]
    ld [hl+], a
    ld a, [samusCurMissilesLow]
    ld [hl+], a
    ld a, [samusCurMissilesHigh]
    ld [hl+], a
    ld a, [samusFacingDirection]
    ld [hl+], a
    ld a, [acidDamageValue]
    ld [hl+], a
    ld a, [spikeDamageValue]
    ld [hl+], a
    ld a, [metroidCountReal]
    ld [hl+], a
    ld a, [currentRoomSong]
    ld [hl+], a
    ld a, [gameTimeMinutes]
    ld [hl+], a
    ld a, [gameTimeHours]
    ld [hl+], a
    ld a, [metroidCountDisplayed]
    ld [hl], a
    ; Disable SRAM
    ld a, $00
    ld [$0000], a

    call saveEnemyFlagsToSRAM
    
    ; Play save sound effect
    ld a, $1c
    ld [sfxRequest_square1], a
    ; But why write to this twice?
    ld a, $1c
    ld [sfxRequest_square1], a
    ; Turn game mode back to main
    ld a, $04
    ldh [gameMode], a
ret

; 1:7B87 - Freespace (filled with $00)