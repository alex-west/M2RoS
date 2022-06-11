; Disassembly of "Metroid2.gb"
; This file was created with:
; mgbdis v1.4 - Game Boy ROM disassembler by Matt Currie and contributors.
; https://github.com/mattcurrie/mgbdis

SECTION "ROM Bank $001", ROMX[$4000], BANK[$1]

; 01:4000
include "data/sprites_samus.asm"

; 01:493E: Update status bar
updateStatusBar:
    ld a, [$c3ca]
    and a
    ret nz

    ld a, [$d06c]
    and a
    ret nz

    ld a, [$d06d]
    and a
    ret nz

    ld hl, $ffb7
    ld a, $af
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    ld a, [samusEnergyTanks]
    and a
    jr z, jr_001_4979

    ld b, a
    ld hl, $ffb7
    ld a, $9c

jr_001_4963:
    ld [hl+], a
    dec b
    jr nz, jr_001_4963

    ld a, [samusDispHealthHigh]
    and a
    jr z, jr_001_497d

    ld b, a
    ld hl, $ffb7
    ld a, $9d

jr_001_4973:
    ld [hl+], a
    dec b
    jr nz, jr_001_4973

    jr jr_001_497d

jr_001_4979:
    ld a, $aa
    ldh [$b7], a

jr_001_497d:
    ld hl, $9be0
    ld a, [$d08b]
    cp $11
    jr z, jr_001_498e

    ld a, $07
    ldh [rWX], a
    ld hl, $9c00

jr_001_498e:
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
    ld a, $9e
    ld [hl+], a
    ld a, [samusDispHealthLow]
    and $f0
    swap a
    add $a0
    ld [hl+], a
    ld a, [samusDispHealthLow]
    and $0f
    add $a0
    ld [hl+], a
    inc hl
    inc hl
    inc hl
    ld a, [samusDispMissilesHigh]
    and $0f
    add $a0
    ld [hl+], a
    ld a, [samusDispMissilesLow]
    and $f0
    swap a
    add $a0
    ld [hl+], a
    ld a, [samusDispMissilesLow]
    and $0f
    add $a0
    ld [hl+], a
    inc hl
    inc hl
    inc hl
    inc hl
    ldh a, [gameMode]
    cp $08
    jr z, jr_001_4a0f

    ld a, [$d096]
    and a
    jr nz, jr_001_49f2

    ld a, [metroidCountDisplayed]
    and $f0
    swap a
    add $a0
    ld [hl+], a
    ld a, [metroidCountDisplayed]
    and $0f
    add $a0
    ld [hl], a
ret


jr_001_49f2:
    dec a
    ld [$d096], a
    cp $80
    ret nc

    ldh a, [rDIV]
    add $10
    daa
    and $f0
    swap a
    add $a0
    ld [hl+], a
    ldh a, [rDIV]
    inc a
    daa
    and $0f
    add $a0
    ld [hl], a
    ret


jr_001_4a0f:
    ld a, [$d0a7]
    cp $ff
    jr z, jr_001_4a26

    and $f0
    swap a
    add $a0
    ld [hl+], a
    ld a, [$d0a7]
    and $0f
    add $a0
    ld [hl], a
    ret


jr_001_4a26:
    ld a, $9e
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
            ld [$cec0], a
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
            ld [$cec0], a

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
        ld [$cec0], a
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
; 01:4AFC - Display a two-sprite number
    ldh [$99], a
    swap a
    and $0f
    add $a0
    call Call_001_4b11
    ldh a, [$99]
; 01:4B09 - Display a one-sprite number
    and $0f
    add $a0
    call Call_001_4b11
ret


Call_001_4b11:
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
        ld a, [$d07d]
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
    ld [$d057], a
    ; Animate the counter
    ldh a, [frameCounter]
    and $10
    swap a
    add $3f
    ldh [hSpriteId], a
    ; Draw the sprite
    call Call_001_4b62
ret


Call_001_4b62:
    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ldh a, [hSpriteId]
    ld d, $00
    ld e, a
    sla e
    rl d
    ld hl, $4000
    add hl, de
    ld a, [hl+]
    ld e, a
    ld a, [hl]
    ld d, a
    ld h, $c0
    ldh a, [hOamBufferIndex]
    ld l, a
    ldh a, [hSpriteYPixel]
    ld b, a
    ldh a, [hSpriteXPixel]
    ld c, a

jr_001_4b86:
    ld a, [de]
    cp $ff
    jr z, jr_001_4bb2

    add b
    ld [hl+], a
    inc de
    ld a, [de]
    add c
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    ldh a, [hSpriteAttr]
    and a
    jr z, jr_001_4b9f

    ld a, [de]
    set 4, a
    jr jr_001_4ba0

jr_001_4b9f:
    ld a, [de]

jr_001_4ba0:
    ld [hl], a
    ld a, [$d057]
    and a
    jr nz, jr_001_4bab

    ld a, [hl]
    set 7, a
    ld [hl], a

jr_001_4bab:
    inc hl
    ld a, l
    ldh [hOamBufferIndex], a
    inc de
    jr jr_001_4b86

jr_001_4bb2:
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

; 01:4BD9: Draw Samus
    ld a, [samusInvulnerableTimer]
    and a
    jr z, jr_001_4be8
        dec a
        ld [samusInvulnerableTimer], a
        ldh a, [frameCounter]
        bit 2, a
        ret z
    jr_001_4be8:
    
    ld a, [acidContactFlag]
    and a
    jr z, jr_001_4bf3
        ldh a, [frameCounter]
        bit 2, a
        ret z
    jr_001_4bf3:

    ld a, [samusPose]
    bit 7, a
    jp nz, Jump_001_4d33

    ld b, $01
    ld a, [$d02b]
    and a
    jr nz, jr_001_4c05

    ld b, $02

jr_001_4c05:
    ld a, [$c463]
    and a
    jr z, jr_001_4c10

    ld a, b
    ldh [$98], a
    jr jr_001_4c19

jr_001_4c10:
    ldh a, [hInputPressed]
    and PADF_DOWN | PADF_UP | PADF_LEFT | PADF_RIGHT ;$f0
    swap a
    or b
    ldh [$98], a

jr_001_4c19:
    ld a, [samusPose]
    rst $28
        dw drawSamus_4D45 ; $00
        dw drawSamus_4CBD ; $01
        dw drawSamus_4CEE ; $02
        dw drawSamus_4D77 ; $03
        dw drawSamus_4D65 ; $04
        dw drawSamus_4C94 ; $05
        dw drawSamus_4C94 ; $06
        dw drawSamus_4CBD ; $07
        dw drawSamus_4C94 ; $08
        dw drawSamus_4CCC ; $09
        dw drawSamus_4CCC ; $0A
        dw drawSamus_4C6B ; $0B
        dw drawSamus_4C6B ; $0C
        dw drawSamus_4C6B ; $0D
        dw drawSamus_4C6B ; $0E
        dw drawSamus_4C59 ; $0F
        dw drawSamus_4C94 ; $10
        dw drawSamus_4C59 ; $11
        dw drawSamus_4C94 ; $12
        dw drawSamus_4D33 ; $13
        dw drawSamus_4D33 ; $14
        dw drawSamus_4D33 ; $15
        dw drawSamus_4D33 ; $16
        dw drawSamus_4D33 ; $17
        dw drawSamus_4C94 ; $18
        dw drawSamus_4C94 ; $19
        dw drawSamus_4C94 ; $1A
        dw drawSamus_4C94 ; $1B
        dw drawSamus_4C94 ; $1C
        dw drawSamus_4C94 ; $1D

drawSamus_4C59: ; $0F, $11
    ld d, $00
    ld a, [$d02b]
    ld e, a
    ld hl, $4c69
    add hl, de
    ld a, [hl]
    ldh [hSpriteId], a
    jp Jump_001_4ddf

    db $16, $09

drawSamus_4C6B: ; $0B-$0E
    ld a, [$d02b]
    and $01
    sla a
    sla a
    ld b, a
    ld a, [$d072]
    and $0c
    srl a
    srl a
    add b
    ld e, a
    ld d, $00
    ld hl, $4c8c
    add hl, de
    ld a, [hl]
    ldh [hSpriteId], a
    jp Jump_001_4ddf

    db $37, $38, $39, $3a, $3b, $3c, $3d, $3e

drawSamus_4C94: ; Morph poses
    ld a, [$d02b]
    and $01
    sla a
    sla a
    ld b, a
    ld a, [$d072]
    and $0c
    srl a
    srl a
    add b
    ld e, a
    ld d, $00
    ld hl, $4cb5
    add hl, de
    ld a, [hl]
    ldh [hSpriteId], a
    jp Jump_001_4ddf

    db $1e, $1f, $20, $21, $26, $27, $28, $29

drawSamus_4CBD: ; $01, $07
    ld d, $00
    ldh a, [$98]
    ld e, a
    ld hl, $4cde
    add hl, de
    ld a, [hl]
    ldh [hSpriteId], a
    jp Jump_001_4ddf


drawSamus_4CCC: ; %09, $0A
    ld a, $03
    ldh [hSpriteId], a
    ld a, [$d02b]
    and a
    jp nz, Jump_001_4ddf

    ld a, $10
    ldh [hSpriteId], a
    jp Jump_001_4ddf


    db $00, $09, $16, $00, $00, $0a, $17, $00
    db $00, $0c, $19, $00, $00, $00, $00, $00

drawSamus_4CEE: ; $02
    ld a, [$d02b]
    and a
    jp z, Jump_001_4cfb

    ld hl, $4d2b
    jp Jump_001_4cfe


Jump_001_4cfb:
    ld hl, $4d2f

Jump_001_4cfe:
    ld a, [samusItems]
    and itemMask_space | itemMask_screw
    jr nz, jr_001_4d1a

    ld a, [$d072]
    srl a
    and $0c
    srl a
    srl a
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    ldh [hSpriteId], a
    jp Jump_001_4ddf


jr_001_4d1a:
    ld a, [$d072]
    srl a
    and $03
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    ldh [hSpriteId], a
    jp Jump_001_4ddf

    db $1a, $1b, $1c, $1d, $22, $23, $24, $25

drawSamus_4D33: ; $13-$17: Facing the screen
Jump_001_4d33:
    ld a, [countdownTimerLow]
    and a
    jr z, jr_001_4d3e

    ldh a, [frameCounter]
    and $03
    ret z

jr_001_4d3e:
    ld a, $00
    ldh [hSpriteId], a
    jp Jump_001_4ddf


drawSamus_4D45: ; $00
    ld d, $00
    ldh a, [$98]
    ld e, a
    ld hl, $4d54
    add hl, de
    ld a, [hl]
    ldh [hSpriteId], a
    jp Jump_001_4ddf

    db $00, $01, $0e, $00, $00, $02, $0f, $00
    db $00, $01, $0e, $00, $00, $00, $00, $00, $00


drawSamus_4D65: ; $04
    ld a, $0b
    ldh [hSpriteId], a
    ld a, [$d02b]
    and a
    jp nz, Jump_001_4ddf

    ld a, $18
    ldh [hSpriteId], a
    jp Jump_001_4ddf

drawSamus_4D77: ; $03
    ld a, [$d022]
    cp $30
    jr c, jr_001_4d82

    xor a
    ld [$d022], a

jr_001_4d82:
    ld a, [$d022]
    and $07
    jr nz, jr_001_4d94

    ld a, [$ced5]
    and a
    jr nz, jr_001_4d94

    ld a, $10
    ld [$ced5], a

jr_001_4d94:
    ld a, [$d02b]
    and $01
    sla a
    sla a
    ld b, a
    ld a, [$d022]
    and $30
    swap a
    add b
    ld e, a
    ld d, $00
    ld hl, $4dc7
    ldh a, [hInputPressed]
    bit PADB_UP, a
    jr z, jr_001_4db7

    ld hl, $4dd7
    jr jr_001_4dc0

jr_001_4db7:
    ldh a, [hInputPressed]
    bit PADB_B, a
    jr z, jr_001_4dc0

    ld hl, $4dcf

jr_001_4dc0:
    add hl, de
    ld a, [hl]
    ldh [hSpriteId], a
    jp Jump_001_4ddf


    db $10, $11, $12

    nop

    db $03, $04, $05

    nop

    db $13, $14, $15

    nop

    db $06, $07, $08

    nop

    db $2e, $2f, $30

    nop

    db $2b, $2c, $2d

    nop

Jump_001_4ddf:
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
    
    xor a
    ldh [hSpriteAttr], a
    ld a, [acidContactFlag]
    and a
    jr nz, jr_001_4e0b
        ld a, [samusInvulnerableTimer]
        and a
        jr z, jr_001_4e0f

        jr_001_4e0b:
            ld a, $01
            ldh [hSpriteAttr], a
    jr_001_4e0f:

    call Call_001_7a34
    call Call_001_4b62
    xor a
    ldh [hSpriteAttr], a
    ld [$d057], a
ret


jr_001_4e1c:
    xor a
    ld [$d079], a
    ld hl, $4e64
    ld de, saveBuffer
    ld b, $26

jr_001_4e28:
    ld a, [hl+]
    ld [de], a
    inc de
    dec b
    jr nz, jr_001_4e28

    ld a, $02
    ldh [gameMode], a
    ret


    ld a, [$d079]
    and a
    jr z, jr_001_4e1c

    ld a, $0a
    ld [$0000], a
    ld a, [activeSaveSlot]
    sla a
    sla a
    swap a
    add $08
    ld l, a
    ld h, $a0
    ld de, saveBuffer
    ld b, $26

jr_001_4e51:
    ld a, [hl+]
    ld [de], a
    inc de
    dec b
    jr nz, jr_001_4e51

    ld a, $00
    ld [$0000], a
    call $3e0a
    ld a, $02
    ldh [gameMode], a
    ret

; Initial savegame
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


    ldh a, [hInputRisingEdge]
    bit PADB_B, a
    jr nz, jr_001_4e9f

    ldh a, [hInputPressed]
    bit PADB_B, a
    ret z

    ld a, [$d00d]
    inc a
    ld [$d00d], a
    cp $10
    ret c

Jump_001_4e9f:
jr_001_4e9f:
    ld a, [samusPose]
    bit 7, a
    ret nz

    ld hl, $5653
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
    ld [$d00d], a
    ldh a, [hInputPressed]
    swap a
    and b
    jr nz, jr_001_4ecf

    ld c, $01
    ld a, [$d02b]
    and a
    jr nz, jr_001_4ed8

    ld c, $02
    jr jr_001_4ed8

jr_001_4ecf:
    ld hl, $5643
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    ld c, a

jr_001_4ed8:
    ld a, c
    ldh [$99], a
    ld hl, $561d
    ld a, [samusPose]
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    ld b, a
    ld hl, $5630
    ld a, c
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    add b
    sub $04
    ld b, a
    ldh [$9a], a
    ld hl, $55fb
    sla c
    ld a, [$d02b]
    add c
    srl c
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    sub $04
    ldh [$98], a
    ld a, [$d04d]
    cp $04
    jp z, Jump_001_4f7e

    call Call_001_4fee
    ld a, l
    swap a
    cp $03
    ret z

    ld a, [$d04d]
    cp $08
    jr nz, jr_001_4f44

    ld a, [samusCurMissilesLow]
    ld b, a
    ld a, [samusCurMissilesHigh]
    or b
    jr nz, jr_001_4f32

    ld a, $19
    ld [$cec0], a
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
    ld a, [$d04d]
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
    ld a, [$d04d]
    cp $03
    jr nz, jr_001_4f6f

    ld a, l
    cp $20
    jp c, Jump_001_4e9f

jr_001_4f6f:
    ld hl, $4fe5
    ld a, [$d04d]
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    ld [$cec0], a
    ret


Jump_001_4f7e:
    ld hl, $dd00
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
    ld a, [$d04d]
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
    ld a, [$d04d]
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    ld [$cec0], a
    ret


    db $07, $09, $16, $0b, $0a

    rlca
    rlca
    rlca

    db $08

Call_001_4fee:
    ld hl, $dd00
    ld a, [$d04d]
    cp $08
    jr nz, jr_001_4ffd

    ld a, $02
    swap a
    ld l, a

jr_001_4ffd:
    ld a, [hl]
    cp $ff
    ret z

    ld de, $0010
    add hl, de
    ld a, l
    swap a
    cp $03
    jr nz, jr_001_4ffd

    ret


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

    call $2266
    ld hl, beamSolidityIndex
    cp [hl]
    jp nc, Jump_001_52e0

    cp $04
    jr nc, jr_001_5172

    call Call_001_5671
    jp Jump_001_52f3


jr_001_5172:
    ld h, $dc
    ld l, a
    ld a, [hl]
    bit 5, a
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

    call $2266
    ld hl, beamSolidityIndex
    cp [hl]
    jr nc, jr_001_52e0

    cp $04
    jr nc, jr_001_52b8

    call c, Call_001_5671
    jr jr_001_52c6

jr_001_52b8:
    ld h, $dc
    ld l, a
    ld a, [hl]
    bit 5, a
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
    call $31b6
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


    ld a, $00
    ld [$d032], a

Jump_001_5305:
    ld hl, $dd00
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
    ld [$cec0], a
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
    ld [$cec0], a
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
    call Call_001_4b62
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
    call Call_001_4b62
    call $30bb
    ld a, $0c
    ld [$ced5], a
    jr jr_001_5490

jr_001_547e:
    ld a, c
    srl a
    add $31
    ldh [hSpriteId], a
    call Call_001_4b62
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
    ld [$d026], a
    ld a, [samusPose]
    ld e, a
    ld d, $00
    ld hl, $55dd
    add hl, de
    ld a, [hl]
    ld [samusPose], a

jr_001_5525:
    ld a, [$d04a]
    sub $10
    ld [$c203], a
    ld a, [$d04b]
    ld [$c204], a
    call $2266
    cp $04
    jr nc, jr_001_553f

    call Call_001_5671
    jr jr_001_554d

jr_001_553f:
    ld h, $dc
    ld l, a
    ld a, [hl]
    bit 6, a
    jp z, Jump_001_554d

    ld a, $ff
    call Call_001_56e9

Jump_001_554d:
jr_001_554d:
    ld a, [$d04a]
    ld [$c203], a
    call $2266
    cp $04
    jr nc, jr_001_555f

    call Call_001_5671
    jr jr_001_556d

jr_001_555f:
    ld h, $dc
    ld l, a
    ld a, [hl]
    bit 6, a
    jp z, Jump_001_556d

    ld a, $ff
    call Call_001_56e9

Jump_001_556d:
jr_001_556d:
    ld a, [$d04a]
    add $10
    ld [$c203], a
    call $2266
    cp $04
    jr nc, jr_001_5581

    call Call_001_5671
    jr jr_001_558f

jr_001_5581:
    ld h, $dc
    ld l, a
    ld a, [hl]
    bit 6, a
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
    call $2266
    cp $04
    jr nc, jr_001_55a9

    call Call_001_5671
    jr jr_001_55b7

jr_001_55a9:
    ld h, $dc
    ld l, a
    ld a, [hl]
    bit 6, a
    jp z, Jump_001_55b7

    ld a, $ff
    call Call_001_56e9

Jump_001_55b7:
jr_001_55b7:
    ld a, [$d04b]
    sub $10
    ld [$c204], a
    call $2266
    cp $04
    jr nc, jr_001_55cb

    call Call_001_5671
    jr jr_001_55d9

jr_001_55cb:
    ld h, $dc
    ld l, a
    ld a, [hl]
    bit 6, a
    jp z, Jump_001_55d9

    ld a, $ff
    call Call_001_56e9

Jump_001_55d9:
jr_001_55d9:
    pop hl
    pop de
    pop bc
    ret


    db $11, $11

    db $11

    db $11, $11, $12, $12

    db $11

    db $12, $11

    db $11

    db $12

    ld [de], a
    ld [de], a

    db $12

    db $11

    db $12, $11, $12

    ld de, $0000
    nop
    nop
    ld [de], a
    ld [de], a
    ld a, [de]
    dec de
    inc e
    dec e
    nop
    nop

    db $18, $1c, $04, $08

    db $10
    db $10

    db $0e, $12

    db $10
    db $10
    db $10
    db $10
    db $10
    db $10

    db $0d, $13

    db $10
    db $10
    db $10
    db $10
    db $10
    db $10
    db $10
    db $10
    db $10
    db $10
    db $10
    db $10
    db $10
    db $10
    db $10
    db $10

    db $17, $1f

    nop

    db $14, $21

    nop
    nop

    db $1d

    nop

    db $15, $15

    nop
    nop
    nop
    nop

    db $1f

    nop

    db $1f

    nop
    nop

    db $00, $00

    nop

    db $f0

    nop
    nop
    nop

    db $08

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    rra
    nop
    nop
    nop

    db $01, $02

    db $01

    db $04, $04, $04

    inc b

    db $08, $08, $08

    ld [$0808], sp
    db $08
    db $08

    db $07, $0f, $00, $07, $03, $80, $80, $0f, $80, $0f, $0f, $80, $80, $80, $80, $0f
    db $80, $0f, $80, $00

    nop
    nop
    nop
    nop
    nop
    add b

    db $00, $80, $00

    add b

Call_001_5671:
    ld hl, $d900

jr_001_5674:
    ld a, [hl]
    and a
    jr z, jr_001_5681

    ld a, l
    add $10
    ld l, a
    cp $00
    ret z

    jr jr_001_5674

jr_001_5681:
    ld a, $01
    ld [hl+], a
    ld a, [$c203]
    ld [hl+], a
    ld a, [$c204]
    ld [hl+], a
    ld a, $04
    ld [$ced5], a
    ret


    ld hl, $d900

jr_001_5695:
    ld a, [hl]
    and a
    jr z, jr_001_56df

    inc a
    ld [hl+], a
    ld a, [$c205]
    ld b, a
    ld a, [hl+]
    ld [$c203], a
    sub b
    and $f0
    cp $c0
    jr z, jr_001_56d9

    ld a, [$c206]
    ld b, a
    ld a, [hl]
    ld [$c204], a
    sub b
    and $f0
    cp $d0
    jr z, jr_001_56d9

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

    jr jr_001_56df

jr_001_56d9:
    ld a, l
    and $f0
    ld l, a
    xor a
    ld [hl], a

jr_001_56df:
    ld a, l
    and $f0
    add $10
    ld l, a
    and a
    jr nz, jr_001_5695

    ret


Call_001_56e9:
jr_001_56e9:
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

    ld a, $ff
    ld [hl+], a
    ld [hl], a
    add hl, de
    ld [hl+], a
    ld [hl], a
    ld a, $04
    ld [$ced5], a
    ret


jr_001_5712:
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


Jump_001_5742:
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


Jump_001_5769:
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
    ld hl, $57df
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
    jr nc, jr_001_57de

    ld a, [$c204]
    sub $08
    and $f0
    ld b, a
    ldh [$99], a
    ldh a, [hSamusXPixel]
    add $0c
    sub b
    cp $18
    jr nc, jr_001_57de

    cp $0c
    jr nc, jr_001_57cc

    ld a, $ff
    ld [$c423], a
    jr jr_001_57d1

jr_001_57cc:
    ld a, $01
    ld [$c423], a

jr_001_57d1:
    ld a, $01
    ld [$c422], a
    ld a, $02
    ld [$c424], a
    call Call_001_5671

jr_001_57de:
    ret


    db $20, $20, $20, $20

    db $20

    db $10

    db $10
    db $20

    db $10

    jr nz, @+$22

    db $10

    db $10
    db $10
    db $10
    jr nz, @+$12

    jr nz, @+$12

    ld a, [$d088]

jr_001_57f5:
    and a
    jr z, jr_001_57fc

jr_001_57f8:
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
    ld a, [$d07d]
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

    ld a, $98
    ldh [hSpriteYPixel], a
    ld a, $44
    ldh [hSpriteXPixel], a
    ld a, $43
    ldh [hSpriteId], a
    call Call_001_4b62
    jr jr_001_5873

jr_001_585a:
    xor a
    ld [$d07d], a
    ldh a, [frameCounter]
    bit 3, a
    jr z, jr_001_5873

    ld a, $98
    ldh [hSpriteYPixel], a
    ld a, $44
    ldh [hSpriteXPixel], a
    ld a, $42
    ldh [hSpriteId], a
    call Call_001_4b62

jr_001_5873:
    ldh a, [frameCounter]
    and a
    jr nz, jr_001_589a

    ld a, [earthquakeTimer]
    and a
    jr z, jr_001_589a

    dec a
    ld [earthquakeTimer], a
    jr nz, jr_001_589a

    ld a, $ff
    ld [$d083], a
    ld a, $0e
    ld [$cede], a
    ld a, [metroidCountReal]
    cp $01
    jr nz, jr_001_589a

    ld a, $60
    ld [$d083], a

jr_001_589a:
    ld a, [samusPose]
    cp $13
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
    ld [$ced5], a

jr_001_58f0:
    ret

; Item message pointers and strings:
; 01:58F1
itemTextPointerTable:
    dw $5911
    dw $5921
    dw $5931
    dw $5941
    dw $5951
    dw $5961
    dw $5971
    dw $5981
    dw $5991
    dw $59A1
    dw $59B1
    dw $59C1
    dw $59D1
    dw $59E1
    dw $59F1
    dw $5A01

; 01:5911 - Item names
; TODO: Define a charmap for this
    db $FF, $D2, $C0, $D5, $C4, $DE, $DF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    db $FF, $FF, $FF, $FF, $FF, $CF, $CB, $C0, $D2, $CC, $C0, $FF, $C1, $C4, $C0, $CC
    db $FF, $FF, $FF, $FF, $FF, $FF, $C8, $C2, $C4, $FF, $C1, $C4, $C0, $CC, $FF, $FF
    db $FF, $FF, $FF, $FF, $FF, $D6, $C0, $D5, $C4, $FF, $C1, $C4, $C0, $CC, $FF, $FF
    db $FF, $FF, $FF, $FF, $FF, $FF, $D2, $CF, $C0, $D9, $C4, $D1, $FF, $FF, $FF, $FF
    db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $C1, $CE, $CC, $C1, $FF, $FF, $FF, $FF
    db $FF, $FF, $FF, $FF, $D2, $C2, $D1, $C4, $D6, $FF, $C0, $D3, $D3, $C0, $C2, $CA
    db $FF, $FF, $FF, $FF, $FF, $FF, $D5, $C0, $D1, $C8, $C0, $FF, $FF, $FF, $FF, $FF
    db $FF, $C7, $C8, $C6, $C7, $FF, $C9, $D4, $CC, $CF, $FF, $C1, $CE, $CE, $D3, $D2
    db $FF, $FF, $FF, $FF, $FF, $D2, $CF, $C0, $C2, $C4, $FF, $C9, $D4, $CC, $CF, $FF
    db $FF, $FF, $FF, $FF, $D2, $CF, $C8, $C3, $C4, $D1, $FF, $C1, $C0, $CB, $CB, $FF
    db $FF, $FF, $FF, $D2, $CF, $D1, $C8, $CD, $C6, $FF, $C1, $C0, $CB, $CB, $FF, $FF
    db $FF, $FF, $FF, $FF, $C4, $CD, $C4, $D1, $C6, $D8, $FF, $D3, $C0, $CD, $CA, $FF
    db $FF, $FF, $FF, $FF, $CC, $C8, $D2, $D2, $C8, $CB, $C4, $FF, $D3, $C0, $CD, $CA
    db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $C4, $CD, $C4, $D1, $C6, $D8, $FF, $FF, $FF
    db $FF, $FF, $FF, $FF, $FF, $FF, $CC, $C8, $D2, $D2, $C8, $CB, $C4, $D2, $FF, $FF

; Draw enemies - 01:5A11
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

jr_001_5a99:
    ret


Call_001_5a9a:
    inc l
    ld a, [hl+]
    ld [$c42e], a
    ld a, [hl+]
    ld [$c42f], a
    ld a, [hl+]
    ld [$c430], a
    ld a, [hl+]
    xor [hl]
    inc l
    xor [hl]
    and $f0
    ld [$c431], a
    ret

; 01:5AB1
include "data/sprites_enemies.asm"

; 01:70BA (called from bank 3?)
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
    ld hl, $7158
    add hl, de
    ld a, [hl]
    ld [$ffea], a
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

    db $00, $01

    ld [bc], a
    inc bc
    nop

    db $04, $05, $06, $02, $01, $07, $08, $09, $02, $00, $0a, $0b, $0c

    inc bc

    db $01, $0d, $0e, $0f

    inc bc

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


    ld hl, $71db
    ld a, [$ffea]
    add a
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl+]
    ld d, [hl]
    ld h, d
    ld l, a
    jp hl


    db $fb, $71, $ff, $71, $03, $72

    rlca
    ld [hl], d

    db $0b, $72, $0f, $72, $13, $72, $17, $72, $1b, $72, $1f, $72, $23, $72, $27, $72
    db $2b, $72, $2f, $72, $33, $72, $37, $72

    ld bc, $0003
    ret


    ld bc, $0083
    ret


    ld bc, $0300
    ret


    ld bc, $8300
    ret


    ld bc, $0103
    ret


    ld bc, $0202
    ret


    ld bc, $0301
    ret


    ld bc, $0183
    ret


    ld bc, $0282
    ret


    ld bc, $0381
    ret


    ld bc, $8103
    ret


    ld bc, $8202
    ret


    ld bc, $8301
    ret


    ld bc, $8183
    ret


    ld bc, $8282
    ret


    ld bc, $8381
    ret


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
    ld hl, $729c
    add hl, de
    ld a, [hl]
    ld [$ffea], a
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

    nop
    db $01
    ld [bc], a

    db $03, $00, $04, $05, $06, $07, $08, $02, $01, $09, $0a, $0b, $0c, $0d, $02, $00
    db $0e, $0f, $10, $11, $12, $03, $01, $13, $14, $15, $16

    rla

    db $03

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


    ld hl, $7329
    ld a, [$ffea]
    add a
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl+]
    ld d, [hl]
    ld h, d
    ld l, a
    jp hl


    db $59, $73, $5d, $73, $61, $73, $65, $73, $69, $73, $6d, $73, $71, $73, $75, $73
    db $79, $73, $7d, $73, $81, $73, $85, $73, $89, $73, $8d, $73, $91, $73, $95, $73
    db $99, $73, $9d, $73, $a1, $73, $a5, $73, $a9, $73, $ad, $73, $b1, $73

    or l
    ld [hl], e

    ld bc, $0004
    ret


    ld bc, $0084
    ret


    ld bc, $0400
    ret


    ld bc, $8400
    ret


    ld bc, HeaderLogo
    ret


    ld bc, $0204
    ret


    ld bc, $0303
    ret


    ld bc, $0402
    ret


    ld bc, $0401
    ret


    ld bc, $0184
    ret


    ld bc, $0284
    ret


    ld bc, $0383
    ret


    ld bc, $0482
    ret


    ld bc, $0481
    ret


    ld bc, $8104
    ret


    ld bc, $8204
    ret


    ld bc, $8303
    ret


    ld bc, $8402
    ret


    ld bc, $8401
    ret


    ld bc, $8184
    ret


    ld bc, $8284
    ret


    ld bc, $8383
    ret


    ld bc, $8482
    ret


    ld bc, $8481
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
    ldh a, [hSpriteId]
    ld d, $00
    ld e, a
    sla e
    rl d
    ld hl, $744a
    add hl, de
    ld a, [hl+]
    ld e, a
    ld a, [hl]
    ld d, a
    ld h, $c0
    ldh a, [hOamBufferIndex]
    ld l, a
    ldh a, [hSpriteYPixel]
    ld b, a
    ldh a, [hSpriteXPixel]
    ld c, a

jr_001_7413:
    ld a, [de]
    cp $ff
    jr z, jr_001_7449

    ldh a, [hSpriteAttr]
    bit 6, a
    jr z, jr_001_7424

    ld a, [de]
    cpl
    sub $07
    jr jr_001_7425

jr_001_7424:
    ld a, [de]

jr_001_7425:
    add b
    ld [hl+], a
    inc de
    ldh a, [hSpriteAttr]
    bit 5, a
    jr z, jr_001_7434

    ld a, [de]
    cpl
    sub $07
    jr jr_001_7435

jr_001_7434:
    ld a, [de]

jr_001_7435:
    add c
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    push hl
    ld hl, $ffc7
    ld a, [de]
    xor [hl]
    pop hl
    ld [hl+], a
    ld a, l
    ldh [hOamBufferIndex], a
    inc de
    jr jr_001_7413

jr_001_7449:
    ret

; 01:744A
include "data/sprites_credits.asm" ; Also title

; 01:79EF: Handle earthquake (called from bank 0)
    ld a, [$d083]
    and a
    ret z

    and $02
    dec a
    ld b, a
    ld a, [$c205]
    add b
    ld [$c205], a
    ldh a, [frameCounter]
    and $01
    ret nz

    ld a, [$d083]
    dec a
    ld [$d083], a
    ret nz

    xor a
    ld [$cedf], a
    ld a, [$d08b]
    cp $10
    jr nc, jr_001_7a2e

    ld a, [$d0a5]
    and a
    jr z, jr_001_7a28

    ld [$cedc], a
    ld [$d092], a
    xor a
    ld [$d0a5], a
    ret


jr_001_7a28:
    ld a, $03
    ld [$cede], a
    ret


jr_001_7a2e:
    ld a, $01
    ld [$cedc], a
    ret


Call_001_7a34:
    ld a, [$d083]
    and a
    ret z

    and $04
    srl a
    dec a
    ld b, a
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


    db $93, $e7, $fb

Call_001_7a6c:
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

    jr_001_7a83:
        ld a, [de]
        cp $02
            jr z, jr_001_7a92
        cp $fe
            jr z, jr_001_7a92
        cp $04
            jr nz, jr_001_7a93
        ld a, $fe
    
        jr_001_7a92:
            ld [hl], a
        jr_001_7a93:
            inc l
            inc e
            dec b
    jr nz, jr_001_7a83

    ld a, $0a
    ld [$0000], a
    ld de, $b000
    ld a, [activeSaveSlot]
    add a
    add d
    ld d, a
    ld hl, $c900
    ld bc, $01c0

jr_001_7aac:
    ld a, [hl+]
    ld [de], a
    inc de
    dec bc
    ld a, b
    or c
    jr nz, jr_001_7aac

    xor a
    ld [$0000], a
    ret


    ld a, $0a
    ld [$0000], a
    ld de, $c900
    ld bc, $01c0
    ld hl, $b000
    ld a, [activeSaveSlot]
    add a
    add h
    ld h, a

    jr_001_7acd:
        ld a, [hl+]
        ld [de], a
        inc de
        dec bc
        ld a, b
        or c
    jr nz, jr_001_7acd

    ld a, $00
    ld [$0000], a
    xor a
    ld [$c436], a
ret


    ld a, $0a
    ld [$0000], a
    ld hl, $2083
    ld a, [activeSaveSlot]
    sla a
    sla a
    swap a
    ld e, a
    ld d, $a0
    ld b, $08

jr_001_7af5:
    ld a, [hl+]
    ld [de], a
    inc de
    dec b
    jr nz, jr_001_7af5

    ld a, [activeSaveSlot]
    sla a
    sla a
    swap a
    add $08
    ld l, a
    ld h, $a0
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
    ld de, $d808
    ld b, $0d

jr_001_7b26:
    ld a, [de]
    inc de
    ld [hl+], a
    dec b
    jr nz, jr_001_7b26

    ld a, [samusItems]
    ld [hl+], a
    ld a, [$d055]
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
    ld a, [$d02b]
    ld [hl+], a
    ld a, [acidDamageValue]
    ld [hl+], a
    ld a, [spikeDamageValue]
    ld [hl+], a
    ld a, [metroidCountReal]
    ld [hl+], a
    ld a, [$d092]
    ld [hl+], a
    ld a, [gameTimeMinutes]
    ld [hl+], a
    ld a, [gameTimeHours]
    ld [hl+], a
    ld a, [metroidCountDisplayed]
    ld [hl], a
    ld a, $00
    ld [$0000], a
    call Call_001_7a6c
    ld a, $1c
    ld [$cec0], a
    ld a, $1c
    ld [$cec0], a
    ld a, $04
    ldh [gameMode], a
ret

; 1:7B87 - Freespace (filled with $00)