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
    ld a, [queen_headFrameNext]
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
    ld a, [queen_roomFlag]
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
; Debug Menu drawing routines
debug_drawNumber: ; 01:4AFC - Display a two-sprite number
.twoDigit:
    ldh [$99], a
    swap a
    and $0f
    add $a0 ; Adjust value for display
    call .drawSprite
    ldh a, [$99]
.oneDigit: ; 01:4B09 - Display a one-sprite number
    and $0f
    add $a0 ; Adjust value for display
    call .drawSprite
ret

.drawSprite: ; 01:4B11
    ; Save sprite tile to temp
    ldh [$98], a
    ; Load WRAM address to HL
    ld h, $c0
    ldh a, [hOamBufferIndex]
    ld l, a
    ; Write Y and X positions
    ldh a, [hSpriteYPixel]
    ld [hl+], a
    ldh a, [hSpriteXPixel]
    ld [hl+], a
    ; Update x position for next sprite
    add $08
    ldh [hSpriteXPixel], a
    ; Write tile number and sprite attributes
    ldh a, [$98]
    ld [hl+], a
    ldh a, [hSpriteAttr]
    ld [hl+], a
    ; Save OAM buffer value
    ld a, l
    ldh [hOamBufferIndex], a
ret

;------------------------------------------------------------------------------
; 01:4B2C - Render Metroid sprite on the HUD
drawHudMetroid::
    ld a, $98
    ldh [hSpriteYPixel], a
    ; Check if in queen fight
    ld a, [queen_roomFlag]
    cp $11
    jr z, .endIf_A
        ; If standing on save point
        ld a, [saveContactFlag]
        and a
        jr nz, .endIf_B
            ; or if a major item is being collected
            ld a, [itemCollected_copy]
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
    ld a, [cutsceneActive]
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
    ld [samus_onscreenXPos], a
    ; Set y pos
    ldh a, [hCameraYPixel]
    ld b, a
    ldh a, [hSamusYPixel]
    sub b
    add $62
    ldh [hSpriteYPixel], a
    ld [samus_onscreenYPos], a
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

;------------------------------------------------------------------------------
; New game
; - Transfers initial savegame from ROM to save buffer in WRAM
createNewSave: ; 01:4E1C
    xor a
    ld [loadingFromFile], a
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
    ld a, [loadingFromFile]
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

;------------------------------------------------------------------------------
; Initial savegame
initialSaveFile: ; 01:4E64
include "data/initialSave.asm"

;------------------------------------------------------------------------------

samusShoot: ; 01:4E8A
    ldh a, [hInputRisingEdge]
    bit PADB_B, a
    jr nz, .endIf_A
        ldh a, [hInputPressed]
        bit PADB_B, a
            ret z
        ld a, [samusBeamCooldown]
        inc a
        ld [samusBeamCooldown], a
        cp $10
            ret c
    .endIf_A:

.spazerLoop:
    ld a, [samusPose]
    bit 7, a
        ret nz
    ld hl, table_5653
    ld a, [samusPose]
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    and a ; Return if pose does not allow shooting
        ret z
    cp $80 ; Check if it's a bomb-laying pose
        jp z, samus_layBomb
    ld b, a ; Save table entry to B
    
    ; Clear beam cooldown
    xor a
    ld [samusBeamCooldown], a
    
    ; Determine beam firing direction
    ldh a, [hInputPressed]
    swap a
    and b
    jr nz, .else_B
        ld c, $01
        ld a, [samusFacingDirection]
        and a
        jr nz, .endIf_B
            ld c, $02
            jr .endIf_B
    .else_B:
        ld hl, table_5643
        ld e, a
        ld d, $00
        add hl, de
        ld a, [hl]
        ld c, a
    .endIf_B:

    ld a, c
    ldh [$99], a
    
    ; Load table value to B
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
    cp $04 ; Plasma
        jp z, .plasmaBranch

    call getFirstEmptyProjectileSlot ; Projectile slot is returned in HL
    ; Exit if projectile is 3
    ld a, l
    swap a
    cp $03
        ret z

    ld a, [samusActiveWeapon]
    cp $08 ; Missiles
    jr nz, .endIf_C
        ; Check if we have any missiles
        ld a, [samusCurMissilesLow]
        ld b, a
        ld a, [samusCurMissilesHigh]
        or b
        jr nz, .endIf_D
            ; If not, play sound effect and exit
            ld a, $19
            ld [sfxRequest_square1], a
            ret
        .endIf_D:
        ; Decrement missile count
        ld a, [samusCurMissilesLow]
        sub $01
        daa
        ld [samusCurMissilesLow], a
        ld a, [samusCurMissilesHigh]
        sbc $00
        daa
        ld [samusCurMissilesHigh], a
    .endIf_C:
    ; Write weapon type
    ld a, [samusActiveWeapon]
    ld [hl+], a
    ; Write direction
    ldh a, [$99]
    ld [hl+], a
    ; Write y position
    ldh a, [$9a]
    ld b, a
    ldh a, [hSamusYPixel]
    add b
    ld [hl+], a
    ; Write x position
    ldh a, [$98]
    ld b, a
    ldh a, [hSamusXPixel]
    add b
    ld [hl+], a
    ; Write wave index
    ldh a, [frameCounter]
    and $10
    srl a
    ld [hl+], a
    ; Write frame counter
    xor a
    ld [hl], a

    ld a, [samusActiveWeapon]
    cp $03 ; Spazer
    jr nz, .endIf_E
        ld a, l
        cp $20
        jp c, .spazerLoop
    .endIf_E:

    ld hl, beamSoundTable
    ld a, [samusActiveWeapon]
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    ld [sfxRequest_square1], a
ret

.plasmaBranch: ; Plasma case
    ld hl, projectileArray
    ld a, [hl]
    cp $ff
    ret nz

    .plasmaLoop:
        ldh a, [$99]
        cp $04
        jr nc, .else_F
            ldh a, [$98]
            sub $08
            ldh [$98], a
            ld a, l
            and a
            jr z, .endIf_F
                ldh a, [$98]
                add $10
                ldh [$98], a
                jr .endIf_F
        .else_F:
            ldh a, [$9a]
            sub $08
            ldh [$9a], a
            ld a, l
            and a
            jr z, .endIf_F
                ldh a, [$9a]
                add $10
                ldh [$9a], a
        .endIf_F:
    
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
    jp c, .plasmaLoop

    ld hl, beamSoundTable ;$4fe5
    ld a, [samusActiveWeapon]
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    ld [sfxRequest_square1], a
ret
; end of samusShoot

beamSoundTable: ; 01:4FE5 - Sound effect table
    db $07 ; 0: Normal
    db $09 ; 1: Ice
    db $16 ; 2: Wave
    db $0B ; 3: Spazer
    db $0A ; 4: Plasma
    db $07 ; 5: x
    db $07 ; 6: x
    db $07 ; 7: x
    db $08 ; 8: Missile

getFirstEmptyProjectileSlot: ; 01:4FEE
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

;------------------------------------------------------------------------------
; Beam handler
handleProjectiles: ; 01:500D
    xor a
    ld [projectileIndex], a
.bigLoop:
    ld a, $dd
    ld h, a
    ldh [$b8], a
    ld a, [projectileIndex]
    swap a
    ld l, a
    ldh [$b7], a
    ; Load projectile type
    ld a, [hl+]
    ldh [$b9], a
    ld [$d08d], a
    cp $ff
        jp z, .nextProjectile
    ; Load direction
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
    cp $02 ; Wave
        jp z, .waveBranch
    cp $03 ; Spazer
        jr z, .spazerBranch
    cp $08 ; Missile
        jp z, .missileBranch
    jp .defaultBranch ; Default projectile (ice, power, plasma)

.spazerBranch: ; Spazer
    ldh a, [$98]
    ; Right
    bit 0, a
    jr z, .endIf_A
        call .spazer_splitVertically
        ldh a, [$9a]
        add $04
        ld hl, camera_speedRight
        add [hl]
        ldh [$9a], a
        jr .spazerEnd
    .endIf_A:
        
    ; Left
    bit 1, a
    jr z, .endIf_B
        call .spazer_splitVertically
        ldh a, [$9a]
        sub $04
        ld hl, camera_speedLeft
        sub [hl]
        ldh [$9a], a
        jr .spazerEnd
    .endIf_B:

    ; Up
    bit 2, a
    jr z, .endIf_C
        call .spazer_splitHorizontally
        ldh a, [$99]
        sub $04
        ld hl, camera_speedUp
        sub [hl]
        ldh [$99], a
        jr .spazerEnd
    .endIf_C:

    ; Down
    ; Default case (bit 3, a)
        call .spazer_splitHorizontally
        ldh a, [$99]
        add $04
        ld hl, camera_speedDown
        add [hl]
        ldh [$99], a
        
    .spazerEnd:
jp .commonBranch

.spazer_splitVertically:
    ; Limit spread to first few frames
    ldh a, [$bb]
    cp $05
        ret nc
    ; Middle beam doesn't move sideways
    ld a, l
    and $f0
    cp $10
        ret z
    cp $00
    jr nz, .else_D
        ; First beam moves up
        ldh a, [$99]
        sub $02
        ldh [$99], a
        ret
    .else_D:
        ; Third beam moves down
        ldh a, [$99]
        add $02
        ldh [$99], a
        ret
; end proc

.spazer_splitHorizontally:
    ; Limit spread to first few frames
    ldh a, [$bb]
    cp $05
        ret nc
    ; Middle beam doesn't
    ld a, l
    and $f0
    cp $10
        ret z
    cp $00
    jr nz, .else_E
        ; First beam moves left
        ldh a, [$9a]
        sub $02
        ldh [$9a], a
        ret
    .else_E:
        ; Third beam moves right
        ldh a, [$9a]
        add $02
        ldh [$9a], a
        ret
; end proc
; end Spazer case

.waveBranch: ; Wave
    ; Read from wave tranverse velocity table
    .waveLoop:
        ld hl, .waveSpeedTable
        ldh a, [$ba]
        ld e, a
        ld d, $00
        add hl, de
        ld a, [hl]
        cp $80
            jr nz, .break
        xor a
        ldh [$ba], a
    jr .waveLoop
    .break:
    ld b, a ; Save result from table

    ldh a, [$98]
    and %1100 ; $0C ; Check if moving vertically
    jr nz, .else_F
        ; Horizontal case
        ; Adjust vertical position of wave
        ldh a, [$99]
        add b
        ldh [$99], a
        ; Increment wave index
        ldh a, [$ba]
        inc a
        ldh [$ba], a
        ; Check direction
        ldh a, [$98]
        bit 1, a
        jr nz, .else_G
            ; Move right
            ldh a, [$9a]
            add $02
            ld hl, camera_speedRight ; Adjust for camera velocity
            add [hl]
            ldh [$9a], a
            jr .endIf_F
        .else_G:
            ; Move left
            ldh a, [$9a]
            sub $02
            ld hl, camera_speedLeft ; Adjust for camera velocity
            sub [hl]
            ldh [$9a], a
            jr .endIf_F
    
    .else_F:
        ; Vertical case
        ; Adjust horizontal position of wave
        ldh a, [$9a]
        add b
        ldh [$9a], a
        ; Increment wave index
        ldh a, [$ba]
        inc a
        ldh [$ba], a
        ; Check direction
        ldh a, [$98]
        bit 2, a
        jr nz, .else_H
            ; Move down
            ldh a, [$99]
            add $02
            ld hl, camera_speedDown ; Adjust for camera velocity
            add [hl]
            ldh [$99], a
            jr .endIf_F
        .else_H:
            ; Move up
            ldh a, [$99]
            sub $02
            ld hl, camera_speedUp ; Adjust for camera velocity
            sub [hl]
            ldh [$99], a
    .endIf_F:

    ; Save wave beam projectile to WRAM
    ; Get WRAM pointer for current projectile
    ldh a, [$b7]
    ld l, a
    ldh a, [$b8]
    ld h, a
    inc hl
    inc hl
    ; Save Y position
    ldh a, [$99]
    ld [hl+], a
    ; Adjust for collision
    add $04
    ld [$c203], a
    ; Save X position
    ldh a, [$9a]
    ld [hl+], a
    ; Adjust for collision
    add $04
    ld [$c204], a
    ; Save wave index
    ldh a, [$ba]
    ld [hl], a
    ; Only collide every other frame
    ldh a, [frameCounter]
    and $01
        jp z, .checkEnemies
    call beam_getTileIndex
    ld hl, beamSolidityIndex
    cp [hl]
        jp nc, .checkEnemies ; Block not destroyed
    ; Destroy a block
    cp $04
    jr nc, .else_I
        call destroyRespawningBlock
        jp .nextProjectile
    .else_I:
        ld h, HIGH(collisionArray)
        ld l, a
        ld a, [hl]
        bit blockType_shot, a
        jp z, .nextProjectile
            ld a, $ff
            call destroyBlock
        jp .nextProjectile
; end case

.waveSpeedTable: ; 01:5183 - Wave speed table (transverse velocity)
    db $00, $07, $05, $02, $00, $fe, $fb, $f9, $00, $f9, $fb, $fe, $00, $02, $05, $07
    db $80

.waveSpeedTable_alt: ; 01:5194 - Unused (alternate wave table -- motion blur makes it looks very spazer-like)
    db $0A, $F6, $F6, $0A, $0A, $F6, $F6, $0A, $0A, $F6, $F6, $0A, $80

.missileSpeedTable: ; 01:51A1 - Missile speed table (first value in array is unused)
    db $00, $00, $01, $00, $00, $01, $00, $01, $00, $01, $00, $01, $01, $01, $01, $02
    db $01, $02, $01, $02, $02, $02, $02, $03, $02, $02, $03, $02, $03, $03, $03, $03
    db $04, $FF

.missileBranch: ; Missile
    ; Use projectile frame counter as index into table
    ldh a, [$bb]
    ld e, a
    ld d, $00
    ld hl, .missileSpeedTable
    add hl, de
    ld a, [hl]
    cp $ff
    jr nz, .endif_J
        ; Decrement value so it doesn't overflow on the next tick
        ldh a, [$bb]
        dec a
        ldh [$bb], a
        ; Load second to last value from table
        ld a, [.missileSpeedTable + $20]
    .endif_J:
    ld b, a ; Save speed to B
    
    ; Handle directions
    ldh a, [$98]
    bit 0, a
    jr z, .endif_K
        ; Go right
        ldh a, [$9a]
        add b
        ld hl, camera_speedRight
        add [hl]
        ldh [$9a], a
        jp .commonBranch
    .endif_K:
    
    bit 1, a
    jr z, .endif_L
        ; Go left
        ldh a, [$9a]
        sub b
        ld hl, camera_speedLeft
        sub [hl]
        ldh [$9a], a
        jp .commonBranch
    .endif_L:
    
    bit 2, a
    jr z, .endif_M
        ; Go up
        ldh a, [$99]
        sub b
        ld hl, camera_speedUp
        sub [hl]
        ldh [$99], a
        jr .commonBranch
    .endif_M:

    ; bit 3, a
        ; Go down
        ldh a, [$99]
        add b
        ld hl, camera_speedDown
        add [hl]
        ldh [$99], a
        jr .commonBranch
; End case

.defaultBranch: ; Default projectile
    ; Handle directions
    ldh a, [$98]
    bit 0, a
    jr z, .endIf_N
        ; Move right
        ldh a, [$9a]
        add $04
        ld hl, camera_speedRight ; Adjust for camera
        add [hl]
        ldh [$9a], a
        ldh a, [$b9]
        cp $04 ; Plasma speed
        jr nz, .commonBranch
            ldh a, [$9a]
            add $02 ; Default speed
            ldh [$9a], a
            jr .commonBranch
    .endIf_N:
    
    bit 1, a
    jr z, .endIf_O
        ; Move left
        ldh a, [$9a]
        sub $04
        ld hl, camera_speedLeft
        sub [hl]
        ldh [$9a], a
        ldh a, [$b9]
        cp $04
        jr nz, .commonBranch
            ldh a, [$9a]
            sub $02
            ldh [$9a], a
            jr .commonBranch
    .endIf_O:
        
    bit 2, a
    jr z, .endIf_P
        ; Move up
        ldh a, [$99]
        sub $04
        ld hl, camera_speedUp
        sub [hl]
        ldh [$99], a
        ldh a, [$b9]
        cp $04
        jr nz, .commonBranch
            ldh a, [$99]
            sub $02
            ldh [$99], a
            jr .commonBranch
    .endIf_P:
    
    ; bit 3, a
        ; Move down
        ldh a, [$99]
        add $04
        ld hl, camera_speedDown
        add [hl]
        ldh [$99], a
        ldh a, [$b9]
        cp $04
        jr nz, .commonBranch
            ldh a, [$99]
            add $02
            ldh [$99], a
; end case

.commonBranch: ; Common projectile code
    ; HL = WRAM address of working projectile
    ldh a, [$b7]
    ld l, a
    ldh a, [$b8]
    ld h, a
    inc hl
    inc hl
    ; Save Y
    ldh a, [$99]
    ld [hl+], a
    ; Adjust for collision
    add $04
    ld [$c203], a
    ; Save X
    ldh a, [$9a]
    ld [hl+], a
    ; Adjust for collision
    add $04
    ld [$c204], a
    ; Save wave index
    ldh a, [$ba]
    ld [hl+], a
    ; Save projectile frame counter
    ldh a, [$bb]
    ld [hl], a
    
    ldh a, [frameCounter]
    and $01
    jr z, .else_Q
    
        call beam_getTileIndex
        ld hl, beamSolidityIndex
        cp [hl]
        jr nc, .else_Q
    
            cp $04
            jr nc, .else_R
                call c, destroyRespawningBlock
                jr .endIf_R
            .else_R:
                ld h, HIGH(collisionArray)
                ld l, a
                ld a, [hl]
                bit blockType_shot, a
                jp z, .endIf_R
                    ld a, $ff
                    call destroyBlock
;                Jump_001_52c6:
            .endIf_R:
        
            ldh a, [$b9]
            cp $07 ; Bomb beam
                call z, bombBeam_layBomb
            ; This gives the spazer/plasma beam the wall-clip property
            cp $03 ; Spazer
                jr z, .nextProjectile
            cp $04 ; Plasma
                jr z, .nextProjectile
            ; Delete projectile
            ldh a, [$b7]
            ld l, a
            ldh a, [$b8]
            ld h, a
            ld a, $ff
            ld [hl], a
            jr .endIf_Q
    .else_Q:
    .checkEnemies: ; Enemy processing
        call Call_000_31b6 ; Projectile-enemy collision routine
        jr nc, .endIf_Q
            ; Delete projectile
            ld a, $dd
            ld h, a
            ldh [$b8], a
            ld a, [projectileIndex]
            swap a
            ld l, a
            ld a, $ff
            ld [hl], a
    .endIf_Q:
    
    .nextProjectile: ; Next projectile

    ld a, [projectileIndex]
    inc a
    ld [projectileIndex], a
    cp $03
    jp c, .bigLoop
ret

; Draw projectiles
drawProjectiles: ; 01:5300
    ld a, $00
    ld [projectileIndex], a

    .projectileLoop:
        ; Convert index into pointer
        ld hl, projectileArray
        ld a, [projectileIndex]
        swap a
        ld e, a
        ld d, $00
        add hl, de
        ; Load weapon type to D, check if slot is used
        ld a, [hl+]
        ld d, a
        cp $ff
        jp z, .nextProjectile
            ; Load direction to C (for missiles)
            ld a, [hl+]
            ld c, a
            ; Load Y pos, adjust for camera
            ld a, [scrollY]
            ld b, a
            ld a, [hl+]
            sub b
            ldh [hSpriteYPixel], a
            ; Load X pos, adjust for camera
            ld a, [scrollX]
            ld b, a
            ld a, [hl]
            sub b
            ldh [hSpriteXPixel], a
            ; Set attribute
            xor a
            ldh [hSpriteAttr], a
            ; Check if missile
            ld a, d
            cp $08
            jr nz, .else_A
                ; Missile case
                push hl
                    ; Load sprite tile for direction
                    ld hl, .missileSpriteTileTable
                    ld a, c
                    ld e, a
                    ld d, $00
                    add hl, de
                    ld a, [hl]
                    ldh [hSpriteId], a
                    ; Load sprite attribute for direction
                    ld hl, .missileSpriteAttributeTable
                    ld a, c
                    ld e, a
                    ld d, $00
                    add hl, de
                    ld a, [hl]
                    ldh [hSpriteAttr], a
                pop hl
                jr .endIf_A
            .else_A:
                ; Beam case
                ld a, $7e ; Horizontal sprite
                ldh [hSpriteId], a
                ld a, c
                and %0011 ; Left or right
                jr nz, .endIf_A
                    ld a, $7f ; Vertical sprite
                    ldh [hSpriteId], a
            .endIf_A:
            ; Check if sprite is offscreen
            ldh a, [hSpriteXPixel]
            cp $08
            jr c, .else_B
                ldh a, [hSpriteXPixel]
                cp $a4
                jr nc, .else_B
                    ldh a, [hSpriteYPixel]
                    cp $0c
                    jr c, .else_B
                        ldh a, [hSpriteYPixel]
                        cp $94
                        jr nc, .else_B
                            ; Set HL to current top of OAM buffer
                            ld h, HIGH(wram_oamBuffer)
                            ldh a, [hOamBufferIndex]
                            ld l, a
                            ; Write the things
                            ldh a, [hSpriteYPixel]
                            ld [hl+], a
                            ldh a, [hSpriteXPixel]
                            ld [hl+], a
                            ldh a, [hSpriteId]
                            ld [hl+], a
                            ldh a, [hSpriteAttr]
                            ld [hl+], a
                            ; Update the OAM buffer index
                            ld a, l
                            ldh [hOamBufferIndex], a
                            ; Clear this variable (why?)
                            xor a
                            ldh [hSpriteAttr], a
                            jr .endIf_B
            .else_B:
                ; Abort rendering
                dec hl
                dec hl
                dec hl
                ; Delete projectile
                ld a, $ff
                ld [hl], a
            .endIf_B:
        .nextProjectile:
        ; Move on to next projectile if it exists
        ld a, [projectileIndex]
        inc a
        ld [projectileIndex], a
        cp $03
    jp c, .projectileLoop
ret

; 01:539D - Missile sprite table
.missileSpriteTileTable:
    db $00, $98, $98, $00, $99, $00, $00, $00, $99
; 01:53A6 - Missile attribute table
.missileSpriteAttributeTable:
    db $00, $00, $20, $00, $00, $00, $00, $00, $40

;------------------------------------------------------------------------------
; Bomb stuff

; Bomb beam code
bombBeam_layBomb: ; 01:53AF
    ; Find first open bomb slot (if available)
    ld hl, bombArray
    .loop:
        ld a, [hl]
        cp $ff
            jr z, .break
        ld de, $0010
        add hl, de
        ld a, l
        swap a
        cp $06
    jr nz, .loop
        ret
    .break:

    ; Set bomb type
    ld a, $01
    ld [hl+], a
    ; Set timer
    ld a, $60
    ld [hl+], a
    ; Set y pos
    ldh a, [$99]
    add $04
    ld [hl+], a
    ; Set x pos
    ldh a, [$9a]
    add $04
    ld [hl+], a
    ; Play sound
    ld a, $13
    ld [sfxRequest_square1], a
ret

samus_layBomb: ; 01:53D9 - Lay bombs
    ld a, [samusItems]
    bit itemBit_bomb, a
        ret z
    ldh a, [hInputRisingEdge]
    bit PADB_B, a
        ret z
    ; Find first open bomb slot (if available)
    ld hl, bombArray
    .loop:
        ld a, [hl]
        cp $ff
            jr z, .break
        ld de, $0010
        add hl, de
        ld a, l
        swap a
        cp $06
    jr nz, .loop
        ret ; Return without laying a bomb
    .break:

    ; Set bomb type
    ld a, $01
    ld [hl+], a
    ; Set timer
    ld a, $60
    ld [hl+], a
    ; Set ypos
    ldh a, [hSamusYPixel]
    add $26
    ld [hl+], a
    ; Set xpos
    ldh a, [hSamusXPixel]
    add $10
    ld [hl+], a
    ; Play sound
    ld a, $13
    ld [sfxRequest_square1], a
ret

; Draw bombs
Call_001_540e:
    xor a
    ld [projectileIndex], a

    Jump_001_5412:
        ld hl, $dd30
        ld a, [projectileIndex]
        swap a
        add l
        ld l, a
        ld a, [hl+]
        ldh [$98], a
        cp $ff
        jr z, jr_001_5490
            ld a, [hl+]
            ld c, a
            ld a, [scrollY]
            ld b, a
            ld a, [hl+]
            ld [$d04a], a
            sub b
            ldh [hSpriteYPixel], a
            ld a, [scrollX]
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
                        call Call_000_30bb
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
        ld a, [projectileIndex]
        inc a
        ld [projectileIndex], a
        cp $03
    jp nz, Jump_001_5412
ret

; Bomb related
Call_001_549d: ; 00:549D
    xor a
    ld [projectileIndex], a

    jr_001_54a1:
        ld hl, bombArray
        ld a, [projectileIndex]
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
        
        ld a, [projectileIndex]
        inc a
        ld [projectileIndex], a
        cp $03
    jr nz, jr_001_54a1

    call Call_001_540e
ret

; Bombs - Destroy blocks
Call_001_54d7: ; 01:54D7
    push bc
    push de
    push hl
    ldh a, [hSpriteYPixel]
    ld b, a
    ld a, [samus_onscreenYPos]
    sub $20
    cp b
    jr nc, jr_001_5525
        ld a, [samus_onscreenYPos]
        add $20
        cp b
        jr c, jr_001_5525
            ldh a, [hSpriteXPixel]
            ld b, a
            ld a, [samus_onscreenXPos]
            sub $10
            cp b
            jr nc, jr_001_5525
                ld a, [samus_onscreenXPos]
                add $10
                cp b
                jr c, jr_001_5525
                    ld c, $ff
                    ld a, [samus_onscreenXPos]
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
            call destroyBlock
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
            call destroyBlock
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
            call destroyBlock
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
            call destroyBlock
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
            call destroyBlock
        Jump_001_55d9:
    jr_001_55d9:

    pop hl
    pop de
    pop bc
ret

table_55DD: ; 01:55DD - Pose related
    db $11 ; $00 - Standing
    db $11 ; $01 - Jumping
    db $11 ; $02 - Spin-jumping
    db $11 ; $03 - Running (set to 83h when turning)
    db $11 ; $04 - Crouching
    db $12 ; $05 - Morphball
    db $12 ; $06 - Morphball jumping
    db $11 ; $07 - Falling
    db $12 ; $08 - Morphball falling
    db $11 ; $09 - Starting to jump
    db $11 ; $0A - Starting to spin-jump
    db $12 ; $0B - Spider ball rolling
    db $12 ; $0C - Spider ball falling
    db $12 ; $0D - Spider ball jumping
    db $12 ; $0E - Spider ball
    db $11 ; $0F - Knockback
    db $12 ; $10 - Morphball knockback
    db $11 ; $11 - Standing bombed
    db $12 ; $12 - Morphball bombed
    db $11 ; $13 - Facing screen
    db $00 ; 
    db $00 ; 
    db $00 ; 
    db $00 ; 
    db $12 ; $18 - Being eaten by Metroid Queen
    db $12 ; $19 - In Metroid Queen's mouth
    db $1A ; $1A - Being swallowed by Metroid Queen
    db $1B ; $1B - In Metroid Queen's stomach
    db $1C ; $1C - Escaping Metroid Queen
    db $1D ; $1D - Escaped Metroid Queen

table_55FB: ; 01:55FB - Projectile X offsets
; Column index into table is based off of facing direction
; Row index is based off of your facing direction of the table_5643
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
    db $17 ; Standing
    db $1F ; Jumping
    db $00 ; Spin-jumping
    db $14 ; Running (set to 83h when turning)
    db $21 ; Crouching
    db $00 ; Morphball
    db $00 ; Morphball jumping
    db $1D ; Falling
    db $00 ; Morphball falling
    db $15 ; Starting to jump
    db $15 ; Starting to spin-jump
    db $00 ; Spider ball rolling
    db $00 ; Spider ball falling
    db $00 ; Spider ball jumping
    db $00 ; Spider ball
    db $1F ; Knockback
    db $00 ; Morphball knockback
    db $1F ; Standing bombed
    db $00 ; Morphball bombed
    
table_5630: ; 01:5630 - Projectile y offset due to firing direction
    db $00 ; Standing
    db $00 ; Jumping
    db $00 ; Spin-jumping
    db $00 ; Running (set to 83h when turning)
    db $F0 ; Crouching
    db $00 ; Morphball
    db $00 ; Morphball jumping
    db $00 ; Falling
    db $08 ; Morphball falling
    db $00 ; Starting to jump
    db $00 ; Starting to spin-jump
    db $00 ; Spider ball rolling
    db $00 ; Spider ball falling
    db $00 ; Spider ball jumping
    db $00 ; Spider ball
    db $00 ; Knockback
    db $1F ; Morphball knockback
    db $00 ; Standing bombed
    db $00 ; Morphball bombed

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
    db $07 ; $00 - Standing
    db $0F ; $01 - Jumping
    db $00 ; $02 - Spin-jumping
    db $07 ; $03 - Running (set to 83h when turning)
    db $03 ; $04 - Crouching
    db $80 ; $05 - Morphball
    db $80 ; $06 - Morphball jumping
    db $0F ; $07 - Falling
    db $80 ; $08 - Morphball falling
    db $0F ; $09 - Starting to jump
    db $0F ; $0A - Starting to spin-jump
    db $80 ; $0B - Spider ball rolling
    db $80 ; $0C - Spider ball falling
    db $80 ; $0D - Spider ball jumping
    db $80 ; $0E - Spider ball
    db $0F ; $0F - Knockback
    db $80 ; $10 - Morphball knockback
    db $0F ; $11 - Standing bombed
    db $80 ; $12 - Morphball bombed
    db $00 ; $13 - Facing screen
    db $00 ; 
    db $00 ; 
    db $00 ; 
    db $00 ; 
    db $00 ; $18 - Being eaten by Metroid Queen
    db $80 ; $19 - In Metroid Queen's mouth
    db $00 ; $1A - Being swallowed by Metroid Queen
    db $80 ; $1B - In Metroid Queen's stomach
    db $00 ; $1C - Escaping Metroid Queen
    db $80 ; $1D - Escaped Metroid Queen

;------------------------------------------------------------------------------

destroyRespawningBlock: ; 01:5671
    ld hl, respawningBlockArray
    .findLoop:
        ; Exit loop if frame counter is zero
        ld a, [hl]
        and a
            jr z, .break
        ; Iterate to next block
        ld a, l
        add $10
        ld l, a
        ; Exit if we're at the end of the page
        cp $00
            ret z
    jr .findLoop
    .break:

    ; Set frame counter
    ld a, $01
    ld [hl+], a
    ; Set Y pos
    ld a, [$c203]
    ld [hl+], a
    ; Set X pos
    ld a, [$c204]
    ld [hl+], a
    ; Request sound effect
    ld a, $04
    ld [sfxRequest_noise], a
ret

handleRespawningBlocks: ; 01:5692
    ld hl, respawningBlockArray
    .loop:
        ; Skip block if timer is zero
        ld a, [hl]
        and a
        jr z, .nextBlock
            ; Increment frame counter
            inc a
            ld [hl+], a
            ; Compare scroll y and tile y
            ld a, [scrollY]
            ld b, a
            ld a, [hl+]
            ld [$c203], a
            sub b
            and $f0
            cp $c0 ; Remove from table if offscreen
                jr z, .removeBlock
        
            ; Compare scroll x and tile x
            ld a, [scrollX]
            ld b, a
            ld a, [hl]
            ld [$c204], a
            sub b
            and $f0
            cp $d0 ; Remove from table if offscreen
                jr z, .removeBlock
        
            dec hl
            dec hl
            ld a, [hl]
            cp $02
                jp z, destroyBlock.frame_A
            cp $07
                jp z, destroyBlock.frame_B
            cp $0d
                jr z, destroyBlock.empty ; Deleted
            cp $f6
                jp z, destroyBlock.frame_B
            cp $fa
                jr z, destroyBlock.frame_A
            cp $fe
                jr z, destroyBlock.reform ; Reformed
        
            jr .nextBlock
        
        .removeBlock: ; Clear the block from the array
            ld a, l
            and $f0
            ld l, a
            ; Clear timer for block
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

destroyBlock: ; 01:56E9
.empty: ; Destroy block (frame 3 - empty)
    call getTilemapAddress
    ; Load return arg into HL
    ld a, [pTilemapDestLow]
    and $de ; Bit-fiddling to ensure it's the top-left corner of the tile?
    ld l, a
    ld a, [pTilemapDestHigh]
    ld h, a
    ld de, $001f ; Distance in memory between top-right and bottom-left tile

    .waitLoop_A:
        ldh a, [rSTAT]
        and $03
    jr nz, .waitLoop_A

    .waitLoop_B:
        ldh a, [rSTAT]
        and $03
    jr nz, .waitLoop_B

    ; Destroy block (turn to blank)
    ld a, $ff
    ld [hl+], a
    ld [hl], a
    add hl, de
    ld [hl+], a
    ld [hl], a
    ; Play sound
    ld a, $04
    ld [sfxRequest_noise], a
ret

.reform: ; 01:5712 - Fully restore block (frame 6)
    xor a
    ld [hl], a
    call getTilemapAddress
    ld a, [pTilemapDestLow]
    and $de
    ld l, a
    ld a, [pTilemapDestHigh]
    ld h, a
    ld de, $001f

    .waitLoop_C:
        ldh a, [rSTAT]
        and $03
    jr nz, .waitLoop_C

    .waitLoop_D:
        ldh a, [rSTAT]
        and $03
    jr nz, .waitLoop_D

    xor a
    ld [hl+], a
    inc a
    ld [hl], a
    add hl, de
    inc a
    ld [hl+], a
    inc a
    ld [hl], a
    ; Hurt Samus if applicable
    ld a, [samusInvulnerableTimer]
    and a
        ret nz
    call .hurtSamus
ret

.frame_A: ; Destroy block (frames 1, 5)
    call getTilemapAddress
    ld a, [pTilemapDestLow]
    and $de
    ld l, a
    ld a, [pTilemapDestHigh]
    ld h, a
    ld de, $001f

    .waitLoop_E:
        ldh a, [rSTAT]
        and $03
    jr nz, .waitLoop_E

    .waitLoop_F:
        ldh a, [rSTAT]
        and $03
    jr nz, .waitLoop_F

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

.frame_B: ; Destroy block (frames 2, 4)
    call getTilemapAddress
    ld a, [pTilemapDestLow]
    and $de
    ld l, a
    ld a, [pTilemapDestHigh]
    ld h, a
    ld de, $001f

    .waitLoop_G:
        ldh a, [rSTAT]
        and $03
    jr nz, .waitLoop_G

    .waitLoop_H:
        ldh a, [rSTAT]
        and $03
    jr nz, .waitLoop_H

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

.hurtSamus: ; 01:5790
    ; Index into height table using Samus' pose
    ld hl, .samusHeightTable
    ld a, [samusPose]
    ld e, a
    ld d, $00
    add hl, de
    ; Save height
    ld a, [hl]
    ld b, a

    ; Bounds checking for y position
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
    ; Bounds checking for x position
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
    ; Set damage boosting direction depending of x position
    cp $0c
    jr nc, .else
        ld a, $ff ; Left
        ld [$c423], a
        jr .endIf
    .else:
        ld a, $01 ; Right
        ld [$c423], a
    .endIf:
    ; Hurt samus
    ld a, $01
    ld [samus_hurtFlag], a
    ld a, $02
    ld [samus_damageValue], a
    call destroyRespawningBlock

    .exit:
ret

.samusHeightTable: ; 01:57DF
    db $20 ; $00 - Standing
    db $20 ; $01 - Jumping
    db $20 ; $02 - Spin-jumping
    db $20 ; $03 - Running (set to 83h when turning)
    db $20 ; $04 - Crouching
    db $10 ; $05 - Morphball
    db $10 ; $06 - Morphball jumping
    db $20 ; $07 - Falling
    db $10 ; $08 - Morphball falling
    db $20 ; $09 - Starting to jump
    db $20 ; $0A - Starting to spin-jump
    db $10 ; $0B - Spider ball rolling
    db $10 ; $0C - Spider ball falling
    db $10 ; $0D - Spider ball jumping
    db $10 ; $0E - Spider ball
    db $20 ; $0F - Knockback
    db $10 ; $10 - Morphball knockback
    db $20 ; $11 - Standing bombed
    db $10 ; $12 - Morphball bombed

;------------------------------------------------------------------------------
; Handle window height, save text, earthquake, low heath beep, fade in, and Metroid Queen cry
miscIngameTasks: ;{ 01:57F2
;{ Handle window display stuff
    ; Decrement cooldown
    ld a, [saveMessageCooldownTimer]
    and a
    jr z, .endIf_A
        dec a
        ld [saveMessageCooldownTimer], a
    .endIf_A:

    ; Skip this if in the Queen fight
    ld a, [queen_roomFlag]
    cp $11
    jr z, .endIf_B
        ldh a, [rLCDC]
        bit 5, a
        jr nz, .endIf_C
            set 5, a ; Enable window display
            ldh [rLCDC], a
        .endIf_C:
        
        ld a, $88 ; Default window position
        ldh [rWY], a
        ; Check different cases for raising the window
        ld a, [saveContactFlag] ; Only unset by door transitions and this function
        and a
        jr nz, .else_D
            ; Check if item being collected
            ld a, [itemCollected_copy]
            and a
            jr z, .endIf_B
                ld a, [itemCollected_copy]
                cp $0b ; Check if not a common item or refill
                jr nc, .endIf_B
                    ld a, $80 ; Higher window position
                    ldh [rWY], a
                    jr .endIf_B
        .else_D:
            ; Touching a save point
            ld a, $80 ; Higher window position
            ldh [rWY], a
            ; Don't allow saving while "Completed" is displayed
            ld a, [saveMessageCooldownTimer]
            and a
            jr nz, .endIf_E
                ; Check input
                ldh a, [hInputRisingEdge]
                cp PADF_START
                jr nz, .endIf_E
                    ; Save!
                    ld a, $09
                    ldh [gameMode], a
                    ; Let the "Completed" message show
                    ld a, $ff
                    ld [saveMessageCooldownTimer], a
            .endIf_E:

            ; Draw completed text when timer is non-zero
            ld a, [saveMessageCooldownTimer]
            and a
            jr z, .else_F
                ; Draw save "Completed" sprite
                ld a, $98
                ldh [hSpriteYPixel], a
                ld a, $44
                ldh [hSpriteXPixel], a
                ld a, $43
                ldh [hSpriteId], a
                call drawSamusSprite
                jr .endIf_B
            .else_F:
                ; Clear flag
                xor a
                ld [saveContactFlag], a
                ; Draw blinking "Press Start" sprite
                ldh a, [frameCounter]
                bit 3, a
                jr z, .endIf_B
                    ld a, $98
                    ldh [hSpriteYPixel], a
                    ld a, $44
                    ldh [hSpriteXPixel], a
                    ld a, $42
                    ldh [hSpriteId], a
                    call drawSamusSprite
    .endIf_B: ;}

;{ Earthquake stuff
    ; Only do this stuff once every 256 frames
    ldh a, [frameCounter]
    and a
    jr nz, .endIf_G
        ; Check if this is non-zero
        ld a, [nextEarthquakeTimer]
        and a
        jr z, .endIf_G
            ; Decrement timer
            dec a
            ld [nextEarthquakeTimer], a
            jr nz, .endIf_G
                ; Activate earthquake
                ld a, $ff
                ld [earthquakeTimer], a
                ld a, $0e
                ld [$cede], a
                ; Special case for last metroid (Queen)
                ld a, [metroidCountReal]
                cp $01
                jr nz, .endIf_G
                    ld a, $60
                    ld [earthquakeTimer], a
    .endIf_G: ;}

;{ Handle low health beep
    ; Only play the low-health beep after the intro has finished
    ld a, [samusPose]
    cp pose_faceScreen
    jr nz, .then_H
        ld a, [countdownTimerLow]
        ld b, a
        ld a, [countdownTimerHigh]
        or b
        jr nz, .endIf_H
        .then_H:
            ; Skip ahead if health isn't below 50
            ld a, [samusCurHealthHigh]
            and a
            jr nz, .else_I
                ld a, [samusCurHealthLow]
                cp $50
                jr nc, .else_I
                    ; Check if health decreased from the last frame
                    ld b, a
                    ld a, [$d0a1]
                    cp b
                    jr z, .endIf_H
                        ; Queue up new sound effect based on tens digit
                        ld a, b
                        ld [$d0a1], a
                        and $f0
                        swap a
                        inc a
                        ld [$cfe5], a
                        jr .endIf_H
            .else_I:
                ; Check if not already clear
                ld a, [$cfe6]
                and a
                jr z, .endIf_H
                    ; Clear the low health beep
                    ld a, $ff
                    ld [$cfe5], a
    .endIf_H: ;}

; Handle fade-in
    ld a, [fadeInTimer]
    and a
        call nz, fadeIn

; Handle Queen's roar
    ld a, [$d0a6]
    and a
    jr z, .else_J
        ; Only roar every 128 frames
        ldh a, [frameCounter]
        and $7f
        jr nz, .else_J
            ld a, $17
            ld [sfxRequest_noise], a
    .else_J:
ret ;}

; Item message pointers and strings:
itemTextPointerTable: ; 01:58F1
    include "data/itemNames.asm"

drawEnemies: ; Draw enemies - 01:5A11
    ; Exit if there are no enemies to render
    ld a, [numActiveEnemies]
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
            call z, drawEnemySprite
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
drawEnemySprite: ; 01:5A3F
    call Call_001_5a9a
    ld a, [$c430]
    ld d, $00
    ld e, a
    sla e
    rl d
    ld hl, enemySpritePointerTable ;$5ab1
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

    .spriteLoop:
        ld a, [de]
        cp $ff
            jr z, .exit
    
        ld a, [$c431]
        bit 6, a
        jr z, .else_A
            ld a, [de]
            cpl
            sub $07
            jr .endIf_A
        .else_A:
            ld a, [de]
        .endIf_A:
    
        add b
        ld [hl+], a
        inc de
        ld a, [$c431]
        bit 5, a
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
    jr .spriteLoop

    .exit:
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

;------------------------------------------------------------------------------
; Alpha Metroid - get angle based on relative positions
alpha_getAngle: ; 01:70BA - called from bank 2
    call metroid_getDistanceAndDirection
    call alpha_getAngleFromTable
    ret

metroid_getDistanceAndDirection: ; 01:70C1
    ld hl, hEnemyYPos
    ld a, [hl]
    add $10
    ld b, a
    ld a, [samus_onscreenYPos]
    sub b
    jr c, .else_A
        ld b, $00
        jr z, .endIf_A
            inc b
            jr .endIf_A
    .else_A:
        cpl
        inc a
        ld b, $ff
    .endIf_A:

    ld [metroid_absSamusDistY], a
    ld a, b
    ld [metroid_samusYDir], a
    inc l
    ld a, [hl]
    add $10
    ld b, a
    ld a, [samus_onscreenXPos]
    sub b
    jr c, .else_B
        ld b, $00
        jr z, .endIf_B
            inc b
            jr .endIf_B
    .else_B:
        cpl
        inc a
        ld b, $ff
    .endIf_B:

    ld [metroid_absSamusDistX], a
    ld a, b
    ld [metroid_samusXDir], a
ret


alpha_getAngleFromTable: ; 01:70FE
    ld a, [metroid_samusXDir]
    and a
        jr z, .pickVerticalDirection
    ld c, a
    ld a, [metroid_samusYDir]
    and a
        jr z, .pickHorizontalDirection

    ; Determine base table index for quadrant
    inc a
    jr z, .else_A
        inc c
        jr z, .else_B
            ld a, $04 ; Bottom right quadrant
            jr .endIf_A
        .else_B:
            ld a, $09 ; Bottom left quadrant
            jr .endIf_A
    .else_A:
        inc c
        jr z, .else_C
            ld a, $0e ; Top right quadrant
            jr .endIf_A
        .else_C:
            ld a, $13 ; Top left quadrant
    .endIf_A:

    ld [metroid_angleTableIndex], a
    call Call_001_7170 ; Do some arithmetic
    call alpha_adjustAngle ; Adjust the angle index

.getAngleFromTable:
    ld a, [metroid_angleTableIndex]
    ld e, a
    ld d, $00
    ld hl, alpha_angleTable
    add hl, de
    ld a, [hl]
    ld [hEnemyState], a
ret

    .pickHorizontalDirection:
        ld a, [metroid_samusXDir]
        dec a
        jr z, .else_D
            ld a, $01 ; Left
            jr .setTableIndex
        .else_D:
            xor a ; Right
            jr .setTableIndex
    .pickVerticalDirection:
        ld a, [metroid_samusYDir]
        dec a
        jr z, .else_E
            ld a, $03 ; Up
            jr .setTableIndex
        .else_E:
            ld a, $02 ; Down
.setTableIndex:
    ld [metroid_angleTableIndex], a
    jr .getAngleFromTable
; end proc

alpha_angleTable: ; 01:7158
    ; $00 - Cardinal directions
    db $00, $01, $02, $03
    ; $04 - Bottom right quadrant
    db $00, $04, $05, $06, $02
    ; $09 - Bottom left quadrant
    db $01, $07, $08, $09, $02
    ; $0E - Top right quadrant
    db $00, $0A, $0B, $0C, $03
    ; $13 - Top left quadrant
    db $01, $0D, $0E, $0F, $03

Call_001_7170:
    ld b, $64
    ld a, [metroid_absSamusDistY]
    ld e, a
    call Call_001_73b9
    ld a, [metroid_absSamusDistX]
    ld c, a
    call Call_001_73cc
    ld a, l
    ld [$c45f], a
    ld a, h
    ld [$c460], a
ret

; Adjusts the travel angle of the Alpha Metroid from one of the cardinal angles
alpha_adjustAngle: ; 01:7189
    ld a, [$c460]
    and a
    jr nz, .else_A
        ld a, [$c45f]
        cp $14
            jr c, .add_0
        cp $3c
            jr c, .add_1
        cp $c8
            jr c, .add_2
        jr .add_3
    .else_A:
        cp $02
        jr z, .else_B
            jr nc, .add_4
            jr .add_3
        .else_B:
            ld a, [$c45f]
            cp $58
                jr nc, .add_4
            jr .add_3

    .add_0: ; Keep horizontal
        ld b, $00
        jr .exit
    .add_1: ; Shallow angle
        ld b, $01
        jr .exit
    .add_2: ; Diagonal
        ld b, $02
        jr .exit
    .add_3: ; Steep angle
        ld b, $03
        jr .exit
    .add_4: ; Vertical
        ld b, $04
.exit:
    ld a, [metroid_angleTableIndex]
    add b
    ld [metroid_angleTableIndex], a
ret

; Alpha Metroid speed/direction vectors
; Load a (Y,X) sign-magnitude velocity pair to BC
alpha_getSpeedVector: ; 01:71CB
    ld hl, .jumpTable
    ld a, [hEnemyState] ; $EA - Metroid angle
    add a
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl+]
    ld d, [hl]
    ld h, d
    ld l, a
    jp hl
    
    .jumpTable: ; 01:71DB
        dw func_71FB ; $00 - Right                 (3,0)
        dw func_71FF ; $01 - Left                 (-3,0)
        dw func_7203 ; $02 - Down                  (0,3)
        dw func_7207 ; $03 - Up                    (0,-3)
        dw func_720B ; $04 - Bottom right quadrant (3,1)
        dw func_720F ; $05 -  ""                   (2,2)
        dw func_7213 ; $06 -  ""                   (1,3)
        dw func_7217 ; $07 - Bottom left quadrant (-3,1)
        dw func_721B ; $08 -  ""                  (-2,2)
        dw func_721F ; $09 -  ""                  (-1,3)
        dw func_7223 ; $0A - Upper right quadrant (3,-1)
        dw func_7227 ; $0B -  ""                  (2,-2)
        dw func_722B ; $0C -  ""                  (1,-3)
        dw func_722F ; $0D - Upper left quadrant (-3,-1)
        dw func_7233 ; $0E -  ""                 (-2,-2)
        dw func_7237 ; $0F -  ""                 (-1,-3)

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

;------------------------------------------------------------------------------
; Gamma Metroid - get angle based on relative positions
;  Also used by the Omega Metroids' fireballs
gamma_getAngle: ; 01:723B
    call metroid_getDistanceAndDirection
    call gamma_getAngleFromTable ; Get angle
ret

gamma_getAngleFromTable: ; 01:7242
    ld a, [metroid_samusXDir]
    and a
        jr z, .pickVerticalDirection
    ld c, a
    ld a, [metroid_samusYDir]
    and a
        jr z, .pickHorizontalDirection

    ; Determine base table index for quadrant
    inc a
    jr z, .else_A
        inc c
        jr z, .else_B
            ld a, $04 ; Bottom right quadrant
            jr .endIf_A
        .else_B:
            ld a, $0b ; Bottom left quadrant
            jr .endIf_A
    .else_A:
        inc c
        jr z, .else_C
            ld a, $12 ; Top right quadrant
            jr .endIf_A
        .else_C:
            ld a, $19 ; Top left quadrant
    .endIf_A:

    ld [metroid_angleTableIndex], a
    call Call_001_7170 ; Do some arithmetic
    call gamma_adjustAngle

.getAngleFromTable:
    ld a, [metroid_angleTableIndex]
    ld e, a
    ld d, $00
    ld hl, gamma_angleTable
    add hl, de
    ld a, [hl]
    ld [hEnemyState], a
ret

    .pickHorizontalDirection:
        ld a, [metroid_samusXDir]
        dec a
        jr z, .else_D
            ld a, $01 ; Left
            jr .setTableIndex
        .else_D:
            xor a ; Right
            jr .setTableIndex
    .pickVerticalDirection:
        ld a, [metroid_samusYDir]
        dec a
        jr z, .else_E
            ld a, $03 ; Up
            jr .setTableIndex
        .else_E:
            ld a, $02 ; Down
.setTableIndex:
    ld [metroid_angleTableIndex], a
    jr .getAngleFromTable
; end proc

gamma_angleTable: ; 01:729C - Gamma angle table
    ; $00 - Cardinal directions
    db $00, $01, $02, $03
    ; $04 - Bottom right quadrant
    db $00, $04, $05, $06, $07, $08, $02
    ; $0B - Bottom left quadrant
    db $01, $09, $0A, $0B, $0C, $0D, $02
    ; $12 - Top right quadrant
    db $00, $0E, $0F, $10, $11, $12, $03
    ; $19 - Top left quadrant
    db $01, $13, $14, $15, $16, $17, $03

gamma_adjustAngle:
    ld a, [$c460]
    and a
    jr nz, .else_A
        ld a, [$c45f]
        cp $0c
            jr c, .add_0
        cp $26
            jr c, .add_1
        cp $4b
            jr c, .add_2
        cp $96
            jr c, .add_3
        jr .add_4
    .else_A:
        cp $03
        jr z, .else_B
            jr nc, .add_6
            cp $01
                jr z, .else_C ; Odd jump
            jr nc, .add_5
            jr .add_4
        .else_B:
            ld a, [$c45f]
            cp $20
                jr nc, .add_6
            jr .add_5

        .else_C: ; Odd jump
            ld a, [$c45f]
            cp $2c
                jr nc, .add_5
            jr .add_4

    .add_0: ; Keep horizontal
        ld b, $00
        jr .exit
    .add_1:
        ld b, $01 ; Shallow angle
        jr .exit
    .add_2:
        ld b, $02 ; Less shallow angle
        jr .exit
    .add_3: ; Diagonal
        ld b, $03
        jr .exit
    .add_4:
        ld b, $04 ; Steep angle
        jr .exit
    .add_5:
        ld b, $05 ; Even steeper angle
        jr .exit
    .add_6: ; Vertical
        ld b, $06
.exit:
    ld a, [metroid_angleTableIndex]
    add b
    ld [metroid_angleTableIndex], a
ret

; Gamma Metroid speed/direction vectors
; Load a (Y,X) sign-magnitude velocity pair to BC
gamma_getSpeedVector: ; 01:7319
    ld hl, .jumpTable
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

    .jumpTable: ; 01:7329
        dw func_7359 ; $00 - Right
        dw func_735D ; $01 - Left
        dw func_7361 ; $02 - Down
        dw func_7365 ; $03 - Up
        dw func_7369 ; $04 - Bottom right quadrant
        dw func_736D ; $05
        dw func_7371 ; $06
        dw func_7375 ; $07
        dw func_7379 ; $08
        dw func_737D ; $09 - Bottom left quadrant
        dw func_7381 ; $0A
        dw func_7385 ; $0B
        dw func_7389 ; $0C
        dw func_738D ; $0D
        dw func_7391 ; $0E - Top right quadrant
        dw func_7395 ; $0F
        dw func_7399 ; $10
        dw func_739D ; $11
        dw func_73A1 ; $12
        dw func_73A5 ; $13 - Top left quadrant
        dw func_73A9 ; $14
        dw func_73AD ; $15
        dw func_73B1 ; $16
        dw func_73B5 ; $17

func_7359: ld bc, $0004
    ret
func_735D: ld bc, $0084
    ret
func_7361: ld bc, $0400
    ret
func_7365: ld bc, $8400
    ret

func_7369: ld bc, $0104
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
func_7389: ld bc, $0482
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

; A cursory look at these two functions seems to indicate that they use
;  some sort of CORDIC-related algorithm
Call_001_73b9: ; 01:73B9
    ; B is set to $64 before entry
    ; E is metroid_absSamusDistY
    ld hl, $0000
    ld c, l
    ld a, $08

    .loop:
        srl b
        rr c
        sla e
        jr nc, .endIf
            add hl, bc
        .endIf:
        dec a
    jr nz, .loop
ret

Call_001_73cc: ; 01:73CC
    ; C is metroid_absSamusDistX
    ld a, h
    or l
        ret z
    ld de, $0000
    ld b, $10
    sla l
    rl h
    rl e
    rl d

    .loop:
        ld a, e
        sub c
        ld a, d
        sbc $00
        jr c, .endIf
            ld a, e
            sub c
            ld e, a
            ld a, d
            sbc $00
            ld d, a
        .endIf:
        ccf
        rl l
        rl h
        rl e
        rl d
        dec b
    jr nz, .loop
ret

;------------------------------------------------------------------------------
; Draws sprites for title and credits
drawNonGameSprite: ;{ 01:73F7
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
ret ;}

; 01:744A
include "data/sprites_credits.asm" ; Also title

;------------------------------------------------------------------------------

earthquake_adjustScroll: ;{ 01:79EF: Handle earthquake (called from bank 0)
    ; Exit if earthquake not active
    ld a, [earthquakeTimer]
    and a
        ret z

    ; Value of A oscillates between 1 and -1 every two frames
    and $02
    dec a
    ld b, a
    ; Adjust scroll
    ld a, [scrollY]
    add b
    ld [scrollY], a

    ; Decrement earthquake timer every two frames
    ldh a, [frameCounter]
    and $01
        ret nz
    ld a, [earthquakeTimer]
    dec a
    ld [earthquakeTimer], a
        ret nz
; Actions once earthquake is finished
    ; Clear earthquake sound
    xor a
    ld [$cedf], a
    
    ld a, [queen_roomFlag]
    cp $10
    jr nc, .else_A
        ld a, [$d0a5]
        and a
        jr z, .else_B
            ; Restore music
            ld [songRequest], a
            ld [currentRoomSong], a
            xor a
            ld [$d0a5], a
            ret
        .else_B:
            ; End isolated sound effect
            ld a, $03
            ld [$cede], a
            ret
    .else_A:
        ; If in Queen's room, start playing the baby metroid music
        ld a, $01
        ld [songRequest], a
        ret
;}

drawSamus_earthquakeAdjustment: ;{ 01:7A34
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
ret ;}

fadeIn: ;{ 01:7A45
    ld hl, .fadeTable
    ; Use upper nybble as index into .fadeTable
    ld a, [fadeInTimer]
    and $f0
    swap a
    ld e, a
    ld d, $00
    add hl, de
    ; Load palette
    ld a, [hl]
    ld [bg_palette], a
    ld [ob_palette0], a
    ; Decrement timer
    ld a, [fadeInTimer]
    dec a
    ld [fadeInTimer], a
    ; Set timer to zero once we reach $0E
    cp $0e
        ret nc
    xor a
    ld [fadeInTimer], a
ret

.fadeTable: ; 01:7A69
    db $93, $e7, $fb
;}

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
    ld [loadSpawnFlagsRequest], a
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