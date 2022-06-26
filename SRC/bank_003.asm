; Disassembly of "Metroid2.gb"
; This file was created with:
; mgbdis v1.4 - Game Boy ROM disassembler by Matt Currie and contributors.
; https://github.com/mattcurrie/mgbdis

SECTION "ROM Bank $003", ROMX[$4000], BANK[$3]

    call Call_003_4014
    ld hl, $c433
    ld a, [hl-]
    ld [hl+], a
    ld a, [$c205]
    ld [hl+], a
    inc l
    ld a, [hl-]
    ld [hl+], a
    ld a, [$c206]
    ld [hl], a
    ret


Call_003_4014:
    ld de, $ffc8
    ld a, [de]
    ld l, a
    inc e
    ld a, [de]
    ld h, a
    push hl
    ld bc, $0068
    add hl, bc
    ld a, l
    and $f0
    ld [$c410], a
    ld a, h
    ld [$c40f], a
    pop hl
    ld bc, $ffa8
    add hl, bc
    ld a, l
    and $f0
    ld [$c412], a
    ld a, h
    ld [$c411], a
    inc e
    ld a, [de]
    ld l, a
    inc e
    ld a, [de]
    ld h, a
    push hl
    ld bc, $0068
    add hl, bc
    ld a, l
    and $f8
    ld [$c414], a
    ld a, h
    ld [$c413], a
    pop hl
    ld bc, $ffa0 ; Not sprite DMA related?
    add hl, bc
    ld a, l
    and $f8
    ld [$c416], a
    ld a, h
    ld [$c415], a
    ld d, $ff
    ld a, [$c40f]
    ld b, a
    and $0f
    jr nz, jr_003_408a

    ld a, [$c411]
    ld c, a
    and $0f
    cp $0f
    jr nz, jr_003_408a

    ld a, [hCameraYScreen]
    cp b
    jr z, jr_003_4082

    ld a, c
    ld [$c40f], a
    ld a, d
    ld [$c410], a
    jr jr_003_408a

jr_003_4082:
    ld a, b
    ld [$c411], a
    xor a
    ld [$c412], a

jr_003_408a:
    ld a, [$c413]
    ld b, a
    and $0f
    jr nz, jr_003_40b4

    ld a, [$c415]
    ld c, a
    and $0f
    cp $0f
    jr nz, jr_003_40b4

    ld a, [hCameraXScreen]
    cp b
    jr z, jr_003_40ac

    ld a, c
    ld [$c413], a
    ld a, d
    ld [$c414], a
    jr jr_003_40b4

jr_003_40ac:
    ld a, b
    ld [$c415], a
    xor a
    ld [$c416], a

jr_003_40b4:
    ld hl, $c401
    ld a, [hl]
    xor $01
    ld [hl], a
    jp z, Jump_003_416a

    ld hl, $c432
    ld a, [$c205]
    sub [hl]
    ret z

    jr c, jr_003_40e3

    ld a, $01
    ld [$c400], a
    ld a, [$c40f]
    ld b, a
    ld a, [$c415]
    ld c, a
    ld a, [$c410]
    ld [$ff98], a
    call getEnemyDataPointerForBank
    call getEnemyDataPointerForScreen
    jr jr_003_40fc

jr_003_40e3:
    ld a, $03
    ld [$c400], a
    ld a, [$c411]
    ld b, a
    ld a, [$c415]
    ld c, a
    ld a, [$c412]
    ld [$ff98], a
    call getEnemyDataPointerForBank
    call getEnemyDataPointerForScreen

jr_003_40fc:
    ld a, [hl]
    cp $ff
    jr z, jr_003_4135

    ld a, [hl+]
    ld e, a
    ld d, $c5
    ld a, [de]
    cp $fe
    jr nc, jr_003_410f

    inc hl

jr_003_410b:
    inc hl

jr_003_410c:
    inc hl
    jr jr_003_40fc

jr_003_410f:
    inc hl
    ld a, [hl]
    and $f8
    ld e, a
    ld a, [$c416]
    cp e
    jr nc, jr_003_410b

    ld d, a
    ld a, [$c414]
    cp d
    jr c, jr_003_4123

    cp e
    ret c

jr_003_4123:
    inc hl
    ld a, [hl]
    and $f0
    ld e, a
    ld a, [$ff98]
    cp e
    jr z, jr_003_4130

    jr jr_003_410c

jr_003_4130:
    call Call_003_422f
    jr jr_003_410c

jr_003_4135:
    inc hl
    ld a, [$c413]
    cp c
    ret z

    ret c

jr_003_413c:
    ld a, [hl]
    cp $ff
    ret z

    ld a, [hl+]
    ld e, a
    ld d, $c5
    ld a, [de]
    cp $fe
    jr nc, jr_003_414e

    inc hl
    inc hl

jr_003_414b:
    inc hl
    jr jr_003_413c

jr_003_414e:
    inc hl
    ld a, [hl]
    and $f8
    ld e, a
    ld a, [$c414]
    cp e
    ret c

    inc hl
    ld a, [hl]
    and $f0
    ld e, a
    ld a, [$ff98]
    cp e
    jr z, jr_003_4165

    jr jr_003_414b

jr_003_4165:
    call Call_003_422f
    jr jr_003_414b

Jump_003_416a:
    ld hl, $c434
    ld a, [$c206]
    sub [hl]
    ret z

    jr c, jr_003_4192

    ld a, $00
    ld [$c400], a
    ld a, [$c411]
    ld b, a
    ld a, [$c413]
    ld c, a
    ld [$c457], a
    ld a, [$c414]
    ld [$ff98], a
    call getEnemyDataPointerForBank
    call getEnemyDataPointerForScreen
    jr jr_003_41ab

jr_003_4192:
    ld a, $01
    ld [$c400], a
    ld a, [$c411]
    ld b, a
    ld a, [$c415]
    ld c, a
    ld a, [$c416]
    ld [$ff98], a
    call getEnemyDataPointerForBank
    call getEnemyDataPointerForScreen

jr_003_41ab:
    ld a, [hl]
    cp $ff
    jr z, jr_003_41e9

    ld a, [hl+]
    ld e, a
    ld d, $c5
    ld a, [de]
    cp $fe
    jr nc, jr_003_41be

    inc hl

jr_003_41ba:
    inc hl

jr_003_41bb:
    inc hl
    jr jr_003_41ab

jr_003_41be:
    inc hl
    ld a, [hl]
    and $f8
    ld e, a
    ld a, [$ff98]
    cp e
    jr z, jr_003_41cd

    jr nc, jr_003_41ba

    jr jr_003_41e9

jr_003_41cd:
    inc hl
    ld a, [hl]
    and $f0
    ld e, a
    ld a, [$c412]
    cp e
    jr z, jr_003_41da

    jr nc, jr_003_41bb

jr_003_41da:
    ld d, a
    ld a, [$c410]
    cp d
    jr c, jr_003_41e4

    cp e
    jr c, jr_003_41bb

jr_003_41e4:
    call Call_003_422f
    jr jr_003_41bb

jr_003_41e9:
    ld a, [$c411]
    ld b, a
    inc b
    ld a, [$c40f]
    cp b
    ret nz

    ld a, c
    ld [$c456], a
    call getEnemyDataPointerForBank
    call getEnemyDataPointerForScreen

jr_003_41fd:
    ld a, [hl]
    cp $ff
    ret z

    ld a, [hl+]
    ld e, a
    ld d, $c5
    ld a, [de]
    cp $fe
    jr nc, jr_003_420f

    inc hl

jr_003_420b:
    inc hl

jr_003_420c:
    inc hl
    jr jr_003_41fd

jr_003_420f:
    inc hl
    ld a, [hl]
    and $f8
    ld e, a
    ld a, [$ff98]
    cp e
    ret c

    jr z, jr_003_421d

    jr jr_003_420b

jr_003_421d:
    inc hl
    ld a, [hl]
    and $f0
    ld e, a
    ld a, [$c410]
    cp e
    jr nc, jr_003_422a

    jr jr_003_420c

jr_003_422a:
    call Call_003_422f
    jr jr_003_420c

Call_003_422f:
    push bc
    ld d, h
    ld e, l
    call findFirstEmptyEnemySlot
    ld a, l
    ld [$c450], a
    ld a, h
    ld [$c451], a
    xor a
    ld [hl+], a
    push de
    ld a, [$c205]
    ld b, a
    ld a, [de]
    add $10
    sub b
    ld [hl+], a
    ld a, [$c206]
    ld b, a
    dec de
    ld a, [de]
    add $08
    sub b
    ld [hl+], a
    dec de
    ld a, [de]
    ld [hl], a
    ld a, l
    add $1a
    ld l, a
    dec de
    ld a, [de]
    ld [hl], a ; Write enemy spawn number to enemy entry in RAM
    ld hl, enemySpawnFlags
    ld l, a
    ld a, [hl]
    cp $ff
    jr z, jr_003_426e

    ld a, $04
    ld [hl], a
    ld [$c461], a
    jr jr_003_4274

jr_003_426e:
    ld a, $01
    ld [hl], a
    ld [$c461], a

jr_003_4274:
    ld a, [$c450]
    add $03
    ld l, a
    ld a, [$c451]
    ld h, a
    ld a, [hl+]
    push hl
    ld hl, enemyHeaderPointers
    call readPointerFromIndex
    pop hl
    ld b, $09

    jr_003_4289:
        ld a, [de]
        ld [hl+], a
        inc de
        dec b
    jr nz, jr_003_4289

    ld c, a
    xor a
    ld b, $04

    jr_003_4293:
        ld [hl+], a
        dec b
    jr nz, jr_003_4293

    ld [hl], c
    ld a, [$c450]
    add $1c
    ld l, a
    ld a, [$c461]
    ld [hl], a
    inc l
    inc l
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl], a
    ld hl, $c425
    inc [hl]
    inc l
    inc [hl]
    pop de
    ld l, e
    ld h, d
    pop bc
    ret

; returns pointer to first unused enemy slot in HL
findFirstEmptyEnemySlot: ; 03:42B4
    ld hl, $c600
    ld bc, $0020

    .findLoop:
        ld a, [hl]
        cp $ff
            ret z
        add hl, bc
    jr .findLoop

; Returns the base offset for a bank's enemy data pointer in HL
getEnemyDataPointerForBank:
    ld hl, enemyDataPointers
    ld a, [currentLevelBank]
    sub $09 ; Adjust pointer to account for $9 being the first level bank
    add a
    ld d, a
    ld e, $00
    add hl, de
    ret


getEnemyDataPointerForScreen:
    ld a, b
    swap a
    add c

; Given a base offset in hl and a pointer index in a, returns a pointer in hl
readPointerFromIndex:
    ; de = a*2
    ld d, $00
    add a
    rl d
    ld e, a
    add hl, de
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld h, d
    ld l, e
    ret

; Enemy Data starts here
enemyDataPointers:
	include "maps/enemyData.asm"

; 03:6244 -- Enemy Data ends here
; Freespace filled with $00 (NOP)

SECTION "ROM Bank $003 Part 2", ROMX[$6300], BANK[$3]
; 03:6300 Enemy header pointers
enemyHeaderPointers:
    dw en6509, en6514, enXX,   enXX,   en651F, enXX,   enXX,   enXX,   enXX,   en652A, enXX,   enXX,   enXX,   enXX,   enXX,   enXX
    dw enXX,   enXX,   en6535, enXX,   en6540, enXX,   en654B, enXX,   enXX,   en6556, en6556, en6561, enXX,   enXX,   en656C, en6577
    dw en6509, en6514, enXX,   enXX,   enXX,   enXX,   enXX,   enXX,   en6582, en658D, en6598, en65A3, en670E, enXX,   enXX,   enXX
    dw en65AE, en65B9, enXX,   enXX,   en6719, enXX,   enXX,   enXX,   enXX,   enXX,   enXX,   enXX,   en6556, en6556, enXX,   enXX
    dw en65C4, en65CF, enXX,   enXX,   enXX,   enXX,   en65DA, enXX,   enXX,   enXX,   en65E5, enXX,   enXX,   enXX,   enXX,   enXX
    dw enXX,   en65F0, enXX,   enXX,   enXX,   enXX,   enXX,   enXX,   enXX,   enXX,   enXX,   enXX,   en65FB, enXX,   enXX,   enXX
    dw enXX,   enXX,   enXX,   en6606, enXX,   en6611, enXX,   enXX,   en661C, enXX,   en6627, en6632, enXX,   en663D, en6648, enXX
    dw enXX,   enXX,   en6653, enXX,   enXX,   en665E, en6724, en6724, en6724, en6724, en6724, enXX,   enXX,   enXX,   enXX,   enXX
    dw en66ED, en66ED, en66ED, en66ED, en66ED, en66ED, en66ED, en66ED, en66ED, en66ED, en66ED, en66ED, en66ED, en66ED, en66ED, en66ED
    dw en66ED, en66ED, en66ED, en66ED, en66ED, en66ED, en66ED, en66ED, en66ED, en66ED, en6703, en66ED, en672F, en66ED, enXX,   enXX
    dw en66A0, enXX,   enXX,   en66B6, en66AB, enXX,   en66E2, enXX,   enXX,   enXX,   enXX,   enXX,   enXX,   en66C1, enXX,   enXX
    dw enXX,   enXX,   enXX,   en66CC, enXX,   enXX,   enXX,   enXX,   enXX,   enXX,   enXX,   enXX,   enXX,   enXX,   enXX,   enXX
    dw enXX,   enXX,   enXX,   enXX,   enXX,   enXX,   enXX,   enXX,   enXX,   enXX,   enXX,   enXX,   enXX,   enXX,   en66D7, enXX
    dw en6669, en6674, enXX,   en667F, enXX,   enXX,   enXX,   enXX,   en668A, enXX,   enXX,   enXX,   enXX,   enXX,   enXX,   enXX
    dw enXX,   enXX,   enXX,   enXX,   enXX,   enXX,   enXX,   enXX,   enXX,   enXX,   enXX,   enXX,   enXX,   enXX,   enXX,   enXX
    dw enXX,   enXX,   enXX,   enXX,   enXX,   enXX,   enXX,   enXX,   en6695, enXX,   enXX,   enXX,   enXX,   enXX,   enXX

;        ______________________________ Base sprite attributes - not modified during runtime (apparently)
;       |    ___________________________ Sprite attributes (flipping, etc.) - modified during runtime
;       |   |    ________________________ Stun counter? (dummy value in header)
;       |   |   |    _____________________
;       |   |   |   |    __________________
;       |   |   |   |   |    _______________
;       |   |   |   |   |   |    ____________
;       |   |   |   |   |   |   |    _________ 
;       |   |   |   |   |   |   |   |    ______ Health (also determines drop type?)
;       |   |   |   |   |   |   |   |   |    ___ AI pointer (bank 2)
;       |   |   |   |   |   |   |   |   |   |
enXX: ; Default - 03:64FE
    db $00,$00,$00,$00,$00,$00,$00,$00,$00 
    dw enAI_NULL
en6509: ; Enemy 0/20h (tsumari / needler facing right)
    db $00,$20,$00,$00,$00,$FF,$00,$00,$01
    dw enAI_57DE ;$57DE
en6514: ; Enemy 1/21h (tsumari / needler facing left)
    db $00,$00,$00,$00,$02,$FF,$00,$00,$01
    dw enAI_58DE
en651F: ; Enemy 4 (skreek)
    db $80,$00,$00,$00,$00,$00,$00,$00,$0B
    dw enAI_59C7
en652A: ; Enemy 9 (drivel)
    db $00,$00,$00,$00,$00,$10,$00,$00,$0A
    dw enAI_drivel
en6535: ; Enemy 12h (yumbo)
    db $00,$00,$00,$00,$00,$00,$00,$00,$01
    dw enAI_smallBug ; The things the flit back and forth
en6540: ; Enemy 14h (hornoad)
    db $00,$20,$00,$00,$00,$00,$02,$00,$02
    dw enAI_hopper
en654B: ; Enemy 16h (senjoo)
    db $00,$00,$00,$00,$00,$00,$00,$00,$06
    dw enAI_senjooShirk
en6556: ; Enemy 19h/1Ah/3Ch/3Dh (gawron/yumee spawner (pipe bugs))
    db $80,$00,$00,$00,$00,$00,$00,$00,$FF
    dw enAI_5F67
en6561: ; Enemy 1Bh (chute leech)
    db $00,$00,$00,$00,$00,$00,$00,$00,$03
    dw enAI_chuteLeech
en656C: ; Enemy 1Eh (autrack (flipped))
    db $00,$20,$00,$00,$08,$00,$00,$00,$0F
    dw enAI_autrack
en6577: ; Enemy 1Fh (wallfire (flipped))
    db $00,$20,$00,$00,$00,$00,$00,$00,$FF
    dw enAI_62B4
en6582: ; Enemy 28h (skorp)
    db $80,$00,$00,$00,$00,$00,$00,$00,$04
    dw enAI_60AB
en658D: ; Enemy 29h (skorp)
    db $80,$40,$00,$00,$00,$00,$00,$00,$04
    dw enAI_60AB
en6598: ; Enemy 2Ah (skorp)
    db $80,$00,$00,$00,$00,$00,$00,$00,$04
    dw enAI_60F8
en65A3: ; Enemy 2Bh (skorp)
    db $80,$20,$00,$00,$00,$00,$00,$00,$04
    dw enAI_60F8
en65AE: ; Enemy 30h (moheek facing right)
    db $00,$20,$00,$00,$00,$FF,$00,$00,$05
    dw enAI_57DE
en65B9: ; Enemy 31h (moheek facing left)
    db $00,$00,$00,$00,$02,$FF,$00,$00,$05
    dw enAI_58DE
en65C4: ; Enemy 40h (octroll)
    db $00,$00,$00,$00,$00,$00,$00,$00,$0F
    dw enAI_chuteLeech
en65CF: ; Enemy 41h (autrack)
    db $00,$00,$00,$00,$08,$00,$00,$00,$0F
    dw enAI_autrack
en65DA: ; Enemy 46h (autoad)
    db $00,$20,$00,$00,$00,$00,$02,$00,$0E
    dw enAI_hopper
en65E5: ; Enemy 4Ah (wallfire)
    db $00,$00,$00,$00,$00,$00,$00,$00,$FF
    dw enAI_62B4
en65F0: ; Enemy 51h (gunzoo)
    db $00,$00,$00,$00,$01,$00,$00,$00,$15
    dw enAI_638C
en65FB: ; Enemy 5Ch (autom)
    db $00,$00,$00,$00,$00,$00,$00,$00,$FF
    dw enAI_6540
en6606: ; Enemy 63h (shirk)
    db $00,$00,$00,$00,$00,$00,$00,$00,$0A
    dw enAI_senjooShirk
en6611: ; Enemy 65h (septogg)
    db $00,$00,$00,$00,$00,$00,$00,$00,$FF
    dw enAI_6841
en661C: ; Enemy 68h (noto)
    db $00,$20,$00,$00,$20,$00,$00,$00,$11
    dw enAI_66F3
en6627: ; Enemy 6Ah (halzyn)
    db $00,$00,$00,$00,$30,$00,$00,$00,$03
    dw enAI_6746
en6632: ; Enemy 6Bh (ramulken)
    db $00,$20,$00,$00,$B0,$00,$02,$00,$0C
    dw enAI_hopper
en663D: ; Enemy 6Dh - Metroid egg
    db $00,$00,$00,$00,$00,$00,$00,$00,$FF
    dw enAI_6B83
en6648: ; Enemy 6Eh (proboscum (flipped))
    db $00,$20,$00,$00,$00,$00,$00,$00,$FF
    dw enAI_65D5
en6653: ; Enemy 72h (proboscum)
    db $00,$00,$00,$00,$00,$00,$00,$00,$FF
    dw enAI_65D5
en665E: ; Enemy 75h (missile block)
    db $00,$00,$00,$00,$00,$00,$00,$00,$FF
    dw enAI_6622
en6669: ; Enemy D0h (flitt) (moving or disappearing??)
    db $00,$00,$00,$00,$00,$00,$00,$00,$FF
    dw enAI_68A0
en6674: ; Enemy D1h (flitt) (moving or disappearing??)
    db $00,$00,$00,$00,$00,$00,$00,$00,$FF
    dw enAI_68FC
en667F: ; Enemy D3h (gravitt)
    db $80,$00,$00,$00,$80,$00,$00,$00,$05
    dw enAI_659F
en668A: ; Enemy D8h (gullugg)
    db $00,$00,$00,$00,$00,$00,$00,$00,$04
    dw enAI_gullugg
en6695: ; Enemy F8h (missile door)
    db $00,$00,$00,$00,$00,$00,$00,$00,$FF
    dw enAI_missileDoor
en66A0: ; Enemy A0h (metroid) ; First Alpha metroid
    db $00,$00,$00,$00,$FF,$00,$00,$00,$05
    dw enAI_6BB2
en66AB: ; Enemy A4h (alpha metroid)
    db $00,$00,$00,$00,$FF,$00,$00,$00,$05
    dw enAI_6C44
en66B6: ; Enemy A3h (alpha metroid) ; gamma?
    db $00,$00,$00,$00,$FF,$00,$00,$00,$0A
    dw enAI_6F60
en66C1: ; Enemy ADh (gamma metroid) ; zeta?
    db $00,$00,$00,$00,$FF,$00,$00,$00,$14
    dw enAI_7276
en66CC: ; Enemy B3h (zeta metroid hatching) ; omega?
    db $00,$00,$00,$00,$FF,$00,$00,$00,$28
    dw enAI_7631
en66D7: ; Enemy CEh (metroid) ; ??
    db $00,$00,$00,$00,$FF,$10,$10,$00,$05
    dw enAI_7A4F
en66E2: ; Enemy A6h (baby metroid egg)
    db $80,$00,$00,$00,$FF,$00,$00,$00,$FF
    dw enAI_7BE5
en66ED: ; Enemy 80h..99h/9Bh/9Dh (item / item orb / enemy/missile refill)
    db $80,$00,$00,$00,$00,$00,$00,$00,$FF
    dw enAI_itemOrb
en66F8: ; Unused
    db $00,$00,$00,$00,$00,$00,$00,$00,$FF
    dw enAI_itemOrb
en6703: ; Enemy 9Ah (blob thrower?)
    db $00,$00,$00,$00,$70,$00,$00,$00,$15
    dw enAI_4EA1
en670E: ; Enemy 2Ch (glow fly)
    db $00,$00,$00,$00,$00,$00,$00,$00,$03
    dw enAI_glowFly
en6719: ; Enemy 34h (rock icicle)
    db $00,$00,$00,$00,$00,$00,$00,$00,$01
    dw enAI_rockIcicle
en6724: ; Enemy 76h..7Ah (Arachnus)
    db $00,$00,$00,$00,$00,$00,$00,$00,$FD
    dw enAI_arachnus
en672F: ; Enemy 9Ch (Arachnus orb)
    db $00,$00,$00,$00,$00,$00,$00,$00,$FD
    dw enAI_arachnus

; 03:673A
enemyDamageTable:
    db $08, $08, $08, $08, $10, $10, $10, $10, $03, $10, $10, $10, $03, $03, $03, $03
    db $03, $03, $05, $05, $10, $10, $15, $08, $08, $00, $00, $12, $12, $12, $15, $15
    db $10, $10, $10, $10, $00, $00, $00, $00, $11, $11, $11, $11, $10, $10, $10, $10
    db $13, $13, $13, $13, $00, $08, $08, $08, $12, $12, $12, $12, $00, $00, $20, $20
    db $20, $15, $15, $15, $15, $10, $15, $15, $00, $00, $15, $15, $FF, $10, $10, $10
    db $10, $15, $15, $15, $08, $08, $08, $08, $08, $08, $08, $08, $15, $15, $10, $10
    db $10, $10, $10, $15, $15, $FF, $FF, $20, $20, $20, $10, $20, $20, $00, $FF, $00
    db $00, $00, $FF, $00, $00, $FF, $20, $20, $20, $20, $20, $02, $02, $00, $00, $00
    db $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
    db $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $30, $00, $FF, $00, $10, $10
    db $FE, $00, $00, $10, $10, $FF, $FF, $FF, $00, $00, $00, $00, $00, $15, $15, $15
    db $15, $00, $00, $20, $20, $20, $20, $20, $20, $20, $00, $00, $00, $00, $10, $25
    db $25, $25, $25, $25, $00, $00, $12, $12, $12, $12, $12, $12, $12, $12, $FE, $FE
    db $FF, $FF, $00, $10, $10, $10, $10, $10, $12, $12, $12, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    db $40, $40, $20, $40, $00, $40, $40, $FF, $FF, $FF, $FF, $00, $00, $00, $00

; 3:6839 - Enemy Hitbox pointers
enemyHitboxPointers:
    dw hitbox6A6B, hitbox6A6B, hitbox6A6B, hitbox6A6B, hitbox6A6F, hitbox6A6F, hitbox6A6F, hitbox6A6F, hitbox6A3F, hitbox6A4B, hitbox6A7F, hitbox6A77, hitbox6A3F, hitbox6A3F, hitbox6A3F, hitbox6A43
    dw hitbox6A7B, hitbox6AA7, hitbox6A43, hitbox6A43, hitbox6A6F, hitbox6A6F, hitbox6A6F, hitbox6A6B, hitbox6A6B, hitbox6A37, hitbox6A37, hitbox6A47, hitbox6A6B, hitbox6A6F, hitbox6A6B, hitbox6A8F
    dw hitbox6A6B, hitbox6A6B, hitbox6A6B, hitbox6A6B, hitbox6A37, hitbox6A37, hitbox6A37, hitbox6A37, hitbox6A93, hitbox6A93, hitbox6A6F, hitbox6A6F, hitbox6A8F, hitbox6A8F, hitbox6A6B, hitbox6A6B
    dw hitbox6A6B, hitbox6A6B, hitbox6A6B, hitbox6A6B, hitbox6A3F, hitbox6A3F, hitbox6A67, hitbox6A67, hitbox6A6B, hitbox6A6B, hitbox6A5B, hitbox6A5B, hitbox6A37, hitbox6A37, hitbox6A73, hitbox6A73
    dw hitbox6A73, hitbox6A6B, hitbox6AA3, hitbox6AC7, hitbox6AC7, hitbox6A43, hitbox6A6F, hitbox6A6F, hitbox6A93, hitbox6A93, hitbox6A8F, hitbox6A8F, hitbox6A8F, hitbox6A3F, hitbox6A3F, hitbox6A67
    dw hitbox6AB7, hitbox6A97, hitbox6A97, hitbox6A97, hitbox6A3F, hitbox6A67, hitbox6AB7, hitbox6A3F, hitbox6A3F, hitbox6A67, hitbox6ACF, hitbox6ADB, hitbox6A97, hitbox6A97, hitbox6A3F, hitbox6A8F
    dw hitbox6ACF, hitbox6ACF, hitbox6ACF, hitbox6A97, hitbox6A97, hitbox6A93, hitbox6A93, hitbox6A93, hitbox6A93, hitbox6A93, hitbox6A67, hitbox6A6F, hitbox6A6F, hitbox6A6B, hitbox6A43, hitbox6A43
    dw hitbox6A43, hitbox6A43, hitbox6A47, hitbox6A37, hitbox6A37, hitbox6A6B, hitbox6A6B, hitbox6A6B, hitbox6ABB, hitbox6ABB, hitbox6ABB, hitbox6A77, hitbox6A77, hitbox6A37, hitbox6A37, hitbox6A37
    dw hitbox6A6B, hitbox6A3F, hitbox6A6B, hitbox6A3F, hitbox6A6B, hitbox6A3F, hitbox6A6B, hitbox6A3F, hitbox6A6B, hitbox6A3F, hitbox6A6B, hitbox6A3F, hitbox6A6B, hitbox6A3F, hitbox6A6B, hitbox6A3F
    dw hitbox6A6B, hitbox6A3F, hitbox6A6B, hitbox6A3F, hitbox6A6B, hitbox6A3F, hitbox6A6B, hitbox6A3F, hitbox6A6B, hitbox6A3F, hitboxC360, hitbox6A3B, hitbox6A6B, hitbox6A3B, hitbox6A3F, hitbox6A3F
    dw hitbox6A87, hitbox6A9B, hitbox6A9B, hitbox6A9B, hitbox6A9B, hitbox6A97, hitbox6A97, hitbox6A97, hitbox6A6B, hitbox6A6B, hitbox6A3F, hitbox6A5F, hitbox6A63, hitbox6A9F, hitbox6A9F, hitbox6A9F
    dw hitbox6AC3, hitbox6A3F, hitbox6A37, hitbox6ABB, hitbox6ABB, hitbox6ABB, hitbox6ABB, hitbox6ABB, hitbox6ABB, hitbox6ABB, hitbox6ABB, hitbox6ABB, hitbox6ABB, hitbox6ABB, hitbox6A3F, hitbox6AB3
    dw hitbox6AB3, hitbox6AB3, hitbox6AB3, hitbox6AB3, hitbox6A37, hitbox6A37, hitbox6A3F, hitbox6A3F, hitbox6A43, hitbox6A4F, hitbox6A53, hitbox6A57, hitbox6A3F, hitbox6A3F, hitbox6A87, hitbox6A87
    dw hitbox6A6B, hitbox6A6B, hitbox6A37, hitbox6A6B, hitbox6A6B, hitbox6A6B, hitbox6A6B, hitbox6A6B, hitbox6A93, hitbox6A93, hitbox6A93, hitbox6A37, hitbox6A37, hitbox6A37, hitbox6A37, hitbox6A37
    dw hitbox6A3F, hitbox6A3F, hitbox6A6B, hitbox6A6B, hitbox6A97, hitbox6A97, hitbox6A97, hitbox6A97, hitbox6A6B, hitbox6A3F, hitbox6A97, hitbox6ABF, hitbox6A6B, hitbox6A6B, hitbox6A3F, hitbox6A3F
    dw hitbox6A8B, hitbox6AD7, hitbox6AAB, hitbox6AE3, hitbox6A37, hitbox6AD7, hitbox6ACB, hitbox6ACB, hitbox6ADF, hitbox6ADF, hitbox6ADF, hitbox6ADF, hitbox6ADF, hitbox6ADF, hitbox6A3F

hitbox6A37: db   0,  0,   0,  0
hitbox6A3B: db   1,  1,   1,  1
hitbox6A3F: db  -4,  3,  -4,  3
hitbox6A43: db  -4,  3,  -8,  7
hitbox6A47: db  -4,  3, -12, 11
hitbox6A4B: db  -4,  3, -16, 15
hitbox6A4F: db  -4,  3, -20, 19
hitbox6A53: db  -4,  3, -24, 23
hitbox6A57: db  -4,  3, -28, 27
hitbox6A5B: db  -8,  0,  -8, 16
hitbox6A5F: db  -4,  3, -12,  3
hitbox6A63: db  -4,  3, -20,  3
hitbox6A67: db  -8,  7,  -4,  3
hitbox6A6B: db  -8,  7,  -8,  7
hitbox6A6F: db  -8,  7, -12, 11
hitbox6A73: db  -8,  7, -16, 15
hitbox6A77: db  -4, 11,  -8,  7
hitbox6A7B: db -12,  3, -12, 11
hitbox6A7F: db  -4, 11, -12, 11
hitbox6A83: db  -4, 11, -12,  3
hitbox6A87: db -11,  9, -12, 11
hitbox6A8B: db   0, 15,   0,  7
hitbox6A8F: db -12, 11,  -4,  3
hitbox6A93: db -12, 11,  -8,  7
hitbox6A97: db -12, 11, -12, 11
hitbox6A9B: db -12, 11, -16, 15
hitbox6A9F: db -12, 11, -20, 19
hitbox6AA3: db -16,  7,  -8,  7
hitbox6AA7: db -20,  3,  -4, 19
hitbox6AAB: db   0, 19,   0,  8
hitbox6AAF: db  -4, 19, -12,  3
hitbox6AB3: db -12, 19,  -8,  7
hitbox6AB7: db -16, 15,  -4,  3
hitbox6ABB: db -16, 15, -12, 11
hitbox6ABF: db -16, 15, -16, 15
hitbox6AC3: db -16, 15, -20, 19
hitbox6AC7: db -24,  7,  -8,  7
hitbox6ACB: db   0, 33,   0, 18
hitbox6ACF: db -20, 19,  -4,  3
hitbox6AD3: db -20, 19, -20, 19
hitbox6AD7: db   0, 39,   0, 31
hitbox6ADB: db -24, 23,  -4,  3
hitbox6ADF: db -24, 23, -24, 23
hitbox6AE3: db   0, 55,   0, 47

; Enemy AI stuff
; 03:6AE7
    ld hl, $ffe0
    ld c, [hl]
    ld a, $ff
    ld b, $0f

    jr_003_6aef:
        ld [hl+], a
        dec b
    jr nz, jr_003_6aef

    ld a, [hl]
    and $0f
    jr nz, jr_003_6b1f

    ld a, [hl]
    ld h, $c6
    bit 4, a
    jr nz, jr_003_6b04
        add $1c
        ld l, a
        jr jr_003_6b08
    jr_003_6b04:
        add $0c
        ld l, a
        inc h
    jr_003_6b08:

    ld a, [hl]
    cp $03
    jr z, jr_003_6b15
        cp $05
            jr nz, jr_003_6b1f
        ld a, $04
        jr jr_003_6b17
    jr_003_6b15:
        ld a, $01
    jr_003_6b17:
    
    ld [hl+], a
    ld b, a
    ld a, [hl]
    ld hl, enemySpawnFlags
    ld l, a
    ld [hl], b

jr_003_6b1f:
    ld hl, $fff1
    ld a, $ff
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    ld hl, $c425
    dec [hl]
    inc l
    dec [hl]
    ld hl, $c468
    ld de, $fffd
    ld a, [de]
    cp [hl]
    ret nz

    dec e
    dec l
    ld a, [de]
    cp [hl]
    ret nz

    dec l
    ld a, $ff
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    ret


    ld hl, $c43f
    ld a, [$d03c]
    add $10
    ld [hl-], a
    ld a, [$d03b]
    add $10
    ld [hl-], a
    ldh a, [$e2]
    add $10
    ld [hl-], a
    ldh a, [$e1]
    add $10
    ld [hl], a
    ld a, [$c43e]
    sub [hl]
    jr z, jr_003_6b77

    jr c, jr_003_6b6f

    ldh a, [$e9]
    cp d
    jr z, jr_003_6b77

    add b
    ldh [$e9], a
    jr jr_003_6b77

jr_003_6b6f:
    ldh a, [$e9]
    cp e
    jr z, jr_003_6b77

    sub b
    ldh [$e9], a

jr_003_6b77:
    inc l
    ld a, [$c43f]
    sub [hl]
    jr z, jr_003_6b92

    jr c, jr_003_6b8a

    ldh a, [hEnemyState]
    cp d
    jr z, jr_003_6b92

    add b
    ldh [hEnemyState], a
    jr jr_003_6b92

jr_003_6b8a:
    ldh a, [hEnemyState]
    cp e
    jr z, jr_003_6b92

    sub b
    ldh [hEnemyState], a

jr_003_6b92:
    ldh a, [$e9]
    ld e, a
    ld d, $00
    ld hl, $6bb1
    add hl, de
    ld a, [hl]
    ld hl, $ffe1
    add [hl]
    ld [hl], a
    ldh a, [hEnemyState]
    ld e, a
    ld d, $00
    ld hl, $6bb1
    add hl, de
    ld a, [hl]
    ld hl, $ffe2
    add [hl]
    ld [hl], a
ret


    db $fb

    ei

    db $fc, $fc, $fd, $fe, $fd, $fd, $fd, $ff, $fe, $fe, $fe, $ff, $ff, $00, $00, $00
    db $01, $01, $02, $02, $02, $01, $03, $03, $03, $02, $03, $04, $04

    dec b

    db $05


    ld hl, $c40c
    ld de, $c205
    ld a, [de]
    sub [hl]
    ld b, a
    inc l
    inc e
    ld a, [de]
    sub [hl]
    ld c, a
    or b
    ret z

    ld a, [$c425]
    and a
    ret z

    ld [$c44c], a
    ld hl, $c5e0
    ld de, $0020

jr_003_6bf0:
    add hl, de
    ld a, [hl]
    inc a
    jr z, jr_003_6bf0

    push hl
    call Call_003_6c58
    ld hl, $ffe1
    bit 7, b
    jr z, jr_003_6c14

    ld a, b
    cpl
    inc a
    add [hl]
    ld [hl+], a
    jr nc, jr_003_6c24

    ldh a, [$e0]
    cp $01
    jr nz, jr_003_6c24

    ldh a, [$f3]
    inc a
    ldh [$f3], a
    jr jr_003_6c24

jr_003_6c14:
    ld a, [hl]
    sub b
    ld [hl+], a
    jr nc, jr_003_6c24

    ldh a, [$e0]
    cp $01
    jr nz, jr_003_6c24

    ldh a, [$f3]
    dec a
    ldh [$f3], a

jr_003_6c24:
    bit 7, c
    jr z, jr_003_6c3b

    ld a, c
    cpl
    inc a
    add [hl]
    ld [hl], a
    jr nc, jr_003_6c4a

    ldh a, [$e0]
    cp $01
    jr nz, jr_003_6c4a

    ld hl, $fff4
    inc [hl]
    jr jr_003_6c4a

jr_003_6c3b:
    ld a, [hl]
    sub c
    ld [hl], a
    jr nc, jr_003_6c4a

    ldh a, [$e0]
    cp $01
    jr nz, jr_003_6c4a

    ld hl, $fff4
    dec [hl]

jr_003_6c4a:
    call Call_003_6c74
    pop hl
    ld a, [$c44c]
    dec a
    ld [$c44c], a
    ret z

    jr jr_003_6bf0

Call_003_6c58:
    ld a, l
    ld [$c450], a
    ld a, h
    ld [$c451], a
    ld a, [hl+]
    ldh [$e0], a
    ld a, [hl+]
    ldh [$e1], a
    ld a, [hl]
    ldh [$e2], a
    ld a, l
    add $0d
    ld l, a
    ld a, [hl+]
    ldh [$f3], a
    ld a, [hl]
    ldh [$f4], a
    ret


Call_003_6c74:
    ld a, [$c450]
    ld l, a
    ld a, [$c451]
    ld h, a
    inc l
    ldh a, [$e1]
    ld [hl+], a
    ldh a, [$e2]
    ld [hl], a
    ld a, l
    add $0d
    ld l, a
    ldh a, [$f3]
    ld [hl+], a
    ldh a, [$f4]
    ld [hl], a
    ret

; Uncertain data
    db $9c, $6c

    or d
    ld l, h

    db $00, $6d

    ret z

    ld l, h

    db $1e, $6d, $27, $6d

    rst $20
    ld l, h

    db $81, $33, $33, $32, $32, $32, $32, $33, $23, $23, $24, $23, $23, $23, $24, $13
    db $13, $13, $13, $13, $00, $80

    add c
    db $e3
    db $e3
    db $e3
    db $e3
    db $e3
    ld [c], a
    ld [c], a
    ld [c], a
    ld [c], a
    ld [c], a
    ld [c], a
    jp nc, $d2d2

    jp nc, $d2d2

    nop
    nop
    nop
    add b
    add c
    ld bc, $0101
    ld bc, $01f1
    pop af
    pop af
    pop af
    pop af
    pop af
    pop af
    ld a, [c]
    ld a, [c]
    ld [c], a
    ld [c], a
    ld [c], a
    ld [c], a
    ld [c], a
    ld [c], a
    ld [c], a
    jp nc, $d2d2

    jp nc, $00d2

    nop
    nop
    add b
    add c
    ld bc, $1202
    ld [bc], a
    ld [de], a
    ld [de], a
    ld [de], a
    ld [de], a
    inc de
    inc de
    inc de
    di
    inc bc
    inc bc
    di
    inc bc
    di
    di
    di
    nop
    nop
    nop
    nop
    add b

    db $81, $01, $01, $01, $01, $01, $01, $02, $02, $12, $02, $12, $02, $12, $12, $12
    db $12, $12, $22, $22, $22, $23, $23, $33, $33, $33, $00, $00, $00, $80, $81, $93
    db $93, $93, $d3, $00, $00, $00, $80

    add c

    db $10, $20, $20, $20, $20, $20, $21, $21, $20, $20, $20, $20, $20, $20, $21, $21
    db $20, $20, $20, $20, $20, $21, $21, $21, $20, $20, $20, $20, $20, $21, $21, $21
    db $00, $80

    ld hl, $c300
    xor a
    ld b, a

jr_003_6d4f:
    ld [hl+], a
    dec b
    jr nz, jr_003_6d4f

    ld a, $67
    ld [$c3a0], a
    ld a, $37
    ld [$c3a2], a
    ld a, $44
    ld [rSTAT], a
    ld a, $5c
    ld [$c3a1], a
    ld a, [$c206]
    ld [$c3c6], a
    ld a, $03
    ld [rWX], a
    ld [$c3a8], a
    ld a, [$c205]
    ld [$c3c7], a
    ld a, $70
    ld [rWY], a
    ld [$c3a9], a
    ld hl, $c3ad
    ld [hl], $ff
    ld a, l
    ld [$c3aa], a
    ld a, h
    ld [$c3ab], a
    ld a, $09
    ld [$c3b7], a
    ld [$c3b6], a
    ld hl, $c300
    ld a, l
    ld [$c3b8], a
    ld a, h
    ld [$c3b9], a
    ld hl, $c338
    ld b, $0c
    ld a, $78

jr_003_6daa:
    ld [hl+], a
    ld [hl], $a2
    inc l
    ld [hl], $b0
    inc l
    ld [hl], $00
    inc l
    add $08
    dec b
    jr nz, jr_003_6daa

    call Call_003_6e22
    ld hl, $7484
    ld a, l
    ld [$c3c4], a
    ld a, h
    ld [$c3c5], a
    ld a, $17
    ld [$c3c3], a
    ld hl, $c600
    ld bc, $01a0

jr_003_6dd2:
    xor a
    ld [hl+], a
    dec bc
    ld a, b
    or c
    jr nz, jr_003_6dd2

    ld a, $96
    ld [$c3d3], a
    call Call_003_6f07
    ld hl, $c603
    ld [hl], $f3
    ld l, $23
    ld [hl], $f5
    ld l, $43
    ld [hl], $f1
    ld l, $63
    ld [hl], $f2
    ld hl, $c683
    ld de, $0020
    ld b, $06
    ld a, $f0

jr_003_6dfc:
    ld [hl], a
    add hl, de
    dec b
    jr nz, jr_003_6dfc

    call Call_003_6e12
    ld a, $01
    ld [$c3ca], a
    ld [$c3cb], a
    ld a, $8c
    ld [$c3cf], a
    ret


Call_003_6e12:
    ld hl, $c680
    ld b, $06

Call_003_6e17:
    ld de, $0020
    ld a, $ff

jr_003_6e1c:
    ld [hl], a
    add hl, de
    dec b
    jr nz, jr_003_6e1c

    ret


Call_003_6e22:
    ld hl, $c354
    ld b, $05
    ld a, [$c3a9]
    add $10

jr_003_6e2c:
    ld [hl+], a
    inc l
    inc l
    inc l
    add $08
    dec b
    jr nz, jr_003_6e2c

    ret

queenHandler: ; 03:6E36
    ld a, [deathFlag]
    and a
    jr z, jr_003_6e4a

    xor a
    ld [queenAnimFootCounter], a
    ld [$c3ca], a
    ld [$c3e0], a
    call Call_003_7140
    ret


jr_003_6e4a:
    ld a, [frameCounter]
    and $03
    jr nz, jr_003_6e6b

    ld a, [$c3d2]
    and a
    jr z, jr_003_6e6b

    xor $90
    ld [$c3d2], a
    ld b, $0c
    ld hl, $c308

jr_003_6e61:
    inc l
    inc l
    inc l
    ld a, $10
    xor [hl]
    ld [hl+], a
    dec b
    jr nz, jr_003_6e61

jr_003_6e6b:
    ld a, [$c3d3]
    and a
    jr z, jr_003_6e85

    cp $64
    jr nc, jr_003_6e85

    ld b, a
    ld a, $01
    ld [$c3f1], a
    ld a, b
    cp $32
    jr nc, jr_003_6e85

    ld a, $01
    ld [$c3ef], a

jr_003_6e85:
    call Call_003_748c
    call Call_003_7be8
    call Call_003_72b8
    call Call_003_7230
    call Call_003_716e
    call Call_003_7190
    call Call_003_71cf
    call Call_003_6f07
    call Call_003_6e22
    call Call_003_7140
    call Call_003_6ea7
    ret


Call_003_6ea7:
    ld a, [$c3f0]
    and a
    jr z, jr_003_6eba

    dec a
    ld [$c3f0], a
    jr nz, jr_003_6eba

    xor a
    ld [$c3d2], a
    call Call_003_7812

jr_003_6eba:
    ld a, [$d05d]
    ld b, a
    ld a, $ff
    ld [$d05d], a
    ld a, b
    cp $ff
    ret z

    cp $08
    ret nz

    ld a, [$d05f]
    cp $c6
    ret nz

    ld h, a
    ld a, [$d05e]
    cp $20
    jr nz, jr_003_6efe

    ld l, $23
    ld a, [hl]
    cp $f6
    ret z

jr_003_6ede:
    call Call_003_7436
    ld a, $08
    ld [$c3f0], a
    ld a, [$c3d2]
    and a
    ret nz

    ld a, $93
    ld [$c3d2], a
    ld a, [$c3ef]
    and a
    ld a, $09
    jr z, jr_003_6efa

    ld a, $0a

jr_003_6efa:
    ld [sfxRequest_noise], a
    ret


jr_003_6efe:
    cp $40
    jr z, jr_003_6ede

    cp $60
    jr z, jr_003_6ede

    ret


Call_003_6f07:
    ld hl, $c601
    ld a, [$c3a0]
    add $18
    ld [hl+], a
    ld a, [$c3a1]
    cpl
    inc a
    add $30
    ld [hl], a
    ld l, $41
    ld a, [$c3a9]
    add $10
    ld [hl+], a
    ld a, [$c3a8]
    ld [hl], a
    ld l, $61
    ld a, [$c3a9]
    add $10
    ld [hl+], a
    ld a, [$c3a8]
    add $20
    ld [hl], a
    ld l, $23
    ld b, $12
    ld c, $0e
    ld a, [hl-]
    cp $f7
    jr nz, jr_003_6f41

    ld b, $15
    ld c, $12

jr_003_6f41:
    ld a, [$c3a8]
    add b
    ld [hl-], a
    ld a, [$c3a9]
    add c
    ld [hl], a
    call Call_003_6e12
    ld a, [$c3d3]
    and a
    ret z

    ld a, [$c3d1]
    and a
    jr nz, jr_003_6f8d

    ld a, [$c3e3]
    and a
    ret nz

    ld a, [$c3b8]
    cp $00
    ret z

    inc a
    ld l, a
    ld a, [$c3b9]
    ld h, a
    ld de, $c683
    ld a, $f0
    ld [de], a
    dec e

jr_003_6f71:
    ld a, [hl-]
    ld [de], a
    dec e
    ld a, [hl]
    ld [de], a
    dec e
    xor a
    ld [de], a
    push de
    ld de, $fff9
    add hl, de
    pop de
    push hl
    ld hl, $0022
    add hl, de
    ld e, l
    ld d, h
    pop hl
    ld a, l
    cp $01
    jr nz, jr_003_6f71

    ret


jr_003_6f8d:
    ld de, $c308
    ld hl, $c680
    ld [hl], $00
    inc l
    ld a, [de]
    add $10
    ld [hl+], a
    inc e
    ld a, [de]
    add $10
    ld [hl+], a
    ld [hl], $82
    ret

; 3:6FA2
; Queen head tilemaps
    db $bb, $b1, $b2, $b3, $b4, $ff, $c0, $c1, $c2, $c3, $c4, $ff, $d0, $d1, $d2, $d3
    db $d4, $d5, $ff, $ff, $e2, $e3, $e4, $e5, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $bb, $b1, $f5, $b8, $b9, $ba, $c0, $c1, $c7, $c8, $c9, $ca
    db $d0, $e6, $d7, $d8, $ff, $ff, $ff, $f6, $e7, $e8, $ff, $ff, $ff, $ff, $f7, $f8
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $bc, $bd, $be, $ff, $ff, $ff, $cb
    db $cc, $cd, $ff, $ff, $da, $db, $dc, $dd, $ff, $ff, $ea, $eb, $ec, $ed, $de, $ff
    db $fa, $fb, $fc, $fd, $ee, $d9, $ff, $ff, $ff, $ff, $ff, $ff

jr_003_700e:
    ld a, [$c3f2]
    ld l, a
    ld a, [$c3f3]
    ld d, a
    ld a, [$c3f4]
    ld e, a
    ld h, $9c
    jr jr_003_703b

jr_003_701e:
    ld a, [$c3ca]
    and a
    ret z

    cp $ff
    jr z, jr_003_700e

    ld de, $6fa2
    cp $01
    jr z, jr_003_7038

    ld de, $6fc6
    cp $02
    jr z, jr_003_7038

    ld de, $6fea

jr_003_7038:
    ld hl, $9c00

jr_003_703b:
    ld c, $03

jr_003_703d:
    ld b, $06

jr_003_703f:
    ld a, [de]
    ld [hl+], a
    inc de
    dec b
    jr nz, jr_003_703f

    ld a, $1a
    add l
    ld l, a
    dec c
    jr nz, jr_003_703d

    ld a, [$c3ca]
    cp $ff
    jr nz, jr_003_7058

    xor a
    ld [$c3ca], a
    ret


jr_003_7058:
    ld a, l
    ld [$c3f2], a
    ld a, d
    ld [$c3f3], a
    ld a, e
    ld [$c3f4], a
    ld a, $ff
    ld [$c3ca], a
    ret

; 03:706A - Rendering the Queen's feet
queenDrawFeet:
    ; Skip rendering feet if zero
    ld a, [queenAnimFootCounter]
    and a
    jr z, jr_003_701e

    ld b, a
    ; Exit this routine (jump to another) if the animation delay is not zero
    ld a, [queenAnimFootDelay]
    and a
    jr z, .selectFrontOrRear
    
    dec a
    ld [queenAnimFootDelay], a
    jr jr_003_701e

.selectFrontOrRear:
    ld a, $01
    ld [queenAnimFootDelay], a
    ld a, b
    bit 7, a ; Bit 7 == 0 -> do the front foot, else do the rear foot
    ld hl, queenFrontFootPointers
    ld de, queenFrontFootOffsets
    ld b, $0c
    jr z, .getTilemapPointer

    ld hl, queenRearFootPointers
    ld de, queenRearFootOffsets
    ld b, $10

    .getTilemapPointer:
    push de
        and $7f ; Mask out the bit determining which foot to render
        dec a   ; Adjusting because the value zero earlier meant "skip rendering"
        sla a
        ld e, a
        ld d, $00
        add hl, de
        ld e, [hl]
        inc hl
        ld d, [hl]
    pop hl
    ; HL now points to the offset table
    ; DE now points to the tilemap

    .vramUpdateLoop:
        push bc ; push the loop counter (b) on to the stack
            ; VRAM Offset: BC = $9A00 + [HL]
            ld b, $9a
            ld c, [hl]
            ; DE points to the table holding the current frame of data
            ld a, [de]
            ld [bc], a ; Write to 
            inc hl
            inc de
        pop bc ; pop the loop counter from the stack
        dec b
    jr nz, .vramUpdateLoop

    ; Don't increment the frame counter if we rendered the front foot
    ld a, [queenAnimFootCounter]
    bit 7, a
    jr z, .swapFeet
        inc a

    .swapFeet:
    xor $80 ; Swap which foot to render
    and $83 ; Mask frame numbers greater than 3
    ; inc if zero so we don't stop animating the feet
    jr nz, .return
        inc a

.return:
    ld [queenAnimFootCounter], a
    ret

; Pointers, tile numbers, and tilemap offsets for the rear and front feet.
queenRearFootPointers:
    dw queenRearFoot1, queenRearFoot2, queenRearFoot3
queenFrontFootPointers:
    dw queenFrontFoot1, queenFrontFoot2, queenFrontFoot3
    
; 03:70D0
queenRearFoot1:
    db     $21,$22,$23,$24
    db $30,$31,$32,$33
    db $40,$41,$42,    $44
    db $50,$51,$52,$53
queenRearFoot2:
    db     $2c,$2d,$2e,$2f
    db $3b,$3c,$3d,$3e
    db $4b,$4c,$4d,    $4f
    db $7f,$f2,$ef,$df
queenRearFoot3:
    db     $2c,$2d,$2e,$2f 
    db $3b,$3c,$3d,$3e
    db $4b,$4c,$4d,    $4f
    db $10,$11,$12,$df

; 03:7100
queenFrontFoot1:
    db $28,$29,$2a
    db $38,$39,$3a
    db $48,$49,$4a
    db $fe,$f9,$f4
queenFrontFoot2:
    db $1b,$1c,$1d
    db $03,$04,$05
    db $0e,$0f,$1f
    db $ff,$ff,$ff
queenFrontFoot3:
    db $1b,$1c,$1d
    db $03,$04,$05
    db $0e,$0f,$1f
    db $00,$01,$02
    
; 03:7124
queenRearFootOffsets:
    db     $01,$02,$03,$04
    db $20,$21,$22,$23
    db $40,$41,$42,    $44,
    db $60,$61,$62,$63
queenFrontFootOffsets:
    db $08,$09,$0a 
    db $28,$29,$2a 
    db $48,$49,$4a
    db $68,$69,$6a

; End of the Queen's Feet ordeal


Call_003_7140:
    ld hl, $c308
    ld a, [hOamBufferIndex]
    ld e, a
    ld d, $c0
    ld c, $06

jr_003_714b:
    ld a, [$c3b8]
    add $08
    cp l
    jr z, jr_003_715e

    ld b, $08

jr_003_7155:
    ld a, [hl+]
    ld [de], a
    inc de
    dec b
    jr nz, jr_003_7155

    dec c
    jr nz, jr_003_714b

jr_003_715e:
    ld hl, $c338
    ld b, $30

jr_003_7163:
    ld a, [hl+]
    ld [de], a
    inc de
    dec b
    jr nz, jr_003_7163

    ld a, e
    ld [hOamBufferIndex], a
    ret


Call_003_716e:
    ld a, [$c3c7]
    ld b, a
    ld a, [$c205]
    cp $f8
    jr c, jr_003_717a

    xor a

jr_003_717a:
    ld [$c3c7], a
    sub b
    ld [$c3bc], a
    ld a, [$c3c6]
    ld b, a
    ld a, [$c206]
    ld [$c3c6], a
    sub b
    ld [$c3bb], a
    ret


Call_003_7190:
    ld a, [$c3bb]
    ld b, a
    ld a, [$c3a1]
    add b
    ld [$c3a1], a
    ld a, [$c3a8]
    sub b
    ld [$c3a8], a
    ld a, [$c3bc]
    ld b, a
    ld a, [$c3a9]
    sub b
    ld [$c3a9], a
    ld a, [$c205]
    cp $f8
    jr c, jr_003_71b5

    xor a

jr_003_71b5:
    ld c, a
    ld a, $67
    sub c
    jr c, jr_003_71c4

    ld [$c3a0], a
    ld a, $37
    ld [$c3a2], a
    ret


jr_003_71c4:
    ld d, $37
    add d
    ld [$c3a2], a
    xor a
    ld [$c3a0], a
    ret


Call_003_71cf:
    ld a, [$c3d1]
    ld d, $05
    and a
    jr z, jr_003_71d9

    ld d, $01

jr_003_71d9:
    ld a, [$c3bb]
    ld b, a
    ld a, [$c3bc]
    ld c, a
    ld a, [$c3b8]
    cp $00
    jr z, jr_003_7215

    add d
    ld l, a
    ld a, [$c3b9]
    ld h, a

jr_003_71ee:
    ld a, [hl]
    sub b
    ld [hl-], a
    ld a, [hl]
    sub c
    ld [hl-], a
    dec l
    dec l
    ld a, $05
    cp l
    jr nz, jr_003_71ee

    ld hl, $c741
    ld d, $03

jr_003_7200:
    call Call_003_7229
    ld a, l
    add $1e
    ld l, a
    dec d
    jr nz, jr_003_7200

    ld hl, $c3e6
    ld d, $03

jr_003_720f:
    call Call_003_7229
    dec d
    jr nz, jr_003_720f

jr_003_7215:
    ld hl, $c338
    ld d, $0c

jr_003_721a:
    ld a, [hl]
    sub c
    ld [hl+], a
    ld a, [hl]
    sub b
    ld [hl+], a
    inc l
    inc l
    dec d
    jr nz, jr_003_721a

    call Call_003_6e22
    ret


Call_003_7229:
    ld a, [hl]
    sub c
    ld [hl+], a
    ld a, [hl]
    sub b
    ld [hl+], a
    ret


Call_003_7230:
    ld a, [$c3b8]
    ld l, a
    ld a, [$c3b9]
    ld h, a
    ld a, [$c3ba]
    and a
    ret z

    cp $01
    jr nz, jr_003_7291

    ld a, [$c3b6]
    cp $08
    jr nc, jr_003_724e

    ld a, [$c3b7]
    cp $0c
    ret c

jr_003_724e:
    xor a
    ld [$c3b6], a
    ld [$c3b7], a
    ld a, $30
    cp l
    ret z

    ld de, $0008
    add hl, de
    push hl
    ld a, [$c3cb]
    ld b, $15
    cp $03
    jr nz, jr_003_7269

    ld b, $27

jr_003_7269:
    ld a, [$c3a9]
    add b
    ld [hl+], a
    ld b, a
    ld a, [$c3a8]
    sub $00
    ld [hl+], a
    ld c, a
    ld [hl], $b5
    inc l
    ld [hl], $80
    inc l
    ld a, b
    add $08
    ld [hl+], a
    ld [hl], c
    inc l
    ld [hl], $c5
    inc l
    ld [hl], $80
    pop hl

Jump_003_7288:
jr_003_7288:
    ld a, l
    ld [$c3b8], a
    ld a, h
    ld [$c3b9], a
    ret


jr_003_7291:
    ld a, [$c3b6]
    cp $08
    jr nc, jr_003_729e

    ld a, [$c3b7]
    cp $0c
    ret c

jr_003_729e:
    ld a, $07
    ld [$c3b6], a
    ld [$c3b7], a
    ld [hl], $ff
    ld de, $0004
    add hl, de
    ld [hl], $ff
    ld de, $fff4
    add hl, de
    ld a, $00
    cp l
    ret z

    jr jr_003_7288

Call_003_72b8:
    ld a, [$c3c0]
    and a
    ret z

    cp $03
    jp z, Jump_003_742a

    ld b, a
    ld a, [$c3a6]
    ld l, a
    ld a, [$c3a7]
    ld h, a
    ld a, b
    cp $01
    jp nz, Jump_003_73b1

    ld a, [$d090]
    cp $10
    jr nz, jr_003_7314

    ld hl, $c623
    ld a, [hl]
    cp $f6
    jr z, jr_003_72ff

    ld a, [$c3d0]
    and a
    jr z, jr_003_72f5

    dec a
    ld [$c3d0], a
    cp $58
    ret nz

    xor a
    ld [$c3d2], a
    call Call_003_7812
    ret


jr_003_72f5:
    xor a
    ld [$d090], a
    ld hl, $c623
    ld [hl], $f6
    ret


jr_003_72ff:
    ld a, $60
    ld [$c3d0], a
    ld a, $93
    ld [$c3d2], a
    ld a, $0a
    ld [sfxRequest_noise], a
    ld hl, $c623
    ld [hl], $f7
    ret


jr_003_7314:
    cp $01
    ret z

    cp $02
    jr nz, jr_003_7328

    xor a
    ld [$c3d2], a
    call Call_003_7812
    ld a, $0d
    ld [$c3c3], a
    ret


jr_003_7328:
    ld a, [hl]
    cp $80
    jr z, jr_003_73a2

    ld a, [$c3a9]
    ld c, a
    ld a, [hl]
    and $f0
    bit 7, a
    jr z, jr_003_733a

    or $0f

jr_003_733a:
    swap a
    add c
    cp $d0
    jr c, jr_003_735c

    ld a, [$c3d1]
    and a
    jr nz, jr_003_7355

    ld a, $04
    ld [$c3c3], a
    xor a
    ld [$c3bf], a
    ld [$c3c1], a
    jr jr_003_7399

jr_003_7355:
    ld a, $0a
    ld [$c3c3], a
    jr jr_003_7399

jr_003_735c:
    ld [$c3a9], a
    ld a, [hl]
    and $f0
    swap a
    ld b, a
    bit 3, a
    jr z, jr_003_736e

    or $f0
    cpl
    inc a
    ld b, a

jr_003_736e:
    ld a, [$c3b7]
    add b
    ld [$c3b7], a
    ld a, [hl]
    and $0f
    ld c, a
    ld a, [$c3a8]
    add c
    ld [$c3a8], a
    ld a, [$c3b6]
    add c
    ld [$c3b6], a
    inc hl
    ld a, [$c3ef]
    and a
    jr z, jr_003_7399

    dec a
    ld [$c3ef], a
    push hl
    call Call_003_7230
    pop hl
    jr jr_003_7328

Jump_003_7399:
jr_003_7399:
    ld a, l
    ld [$c3a6], a
    ld a, h
    ld [$c3a7], a
    ret


jr_003_73a2:
    xor a
    ld [$c3c0], a
    ld [$c3ba], a
    ld a, $81
    ld [$c3c1], a
    dec hl
    jr jr_003_7399

Jump_003_73b1:
    ld a, [frameCounter]
    and $01
    ret z

    ld a, [hl]
    cp $81
    jr z, jr_003_73fc

    ld a, [hl]
    and $f0
    swap a
    bit 3, a
    jr z, jr_003_73cc

    or $f0
    cpl
    inc a
    ld b, a
    jr jr_003_73cf

jr_003_73cc:
    cpl
    inc a
    ld b, a

jr_003_73cf:
    ld a, [$c3a9]
    add b
    ld [$c3a9], a
    bit 7, b
    jr nz, jr_003_73de

    ld a, b
    cpl
    inc a
    ld b, a

jr_003_73de:
    ld a, [$c3b7]
    add b
    ld [$c3b7], a
    ld a, [hl]
    and $0f
    cpl
    inc a
    ld b, a
    ld a, [$c3a8]
    add b
    ld [$c3a8], a
    ld a, [$c3b6]
    add b
    ld [$c3b6], a
    dec hl
    jr jr_003_7399

jr_003_73fc:
    xor a
    ld [$c3c0], a
    ld [$c3ba], a
    ld a, $82
    ld [$c3c1], a
    xor a
    ld [$d090], a
    ld hl, $c623
    ld [hl], $f5
    ld hl, $c300
    ld a, l
    ld [$c3b8], a
    ld a, h
    ld [$c3b9], a
    ld a, $09
    ld [$c3b6], a
    ld [$c3b7], a
    call Call_003_7466
    jp Jump_003_7399


Jump_003_742a:
    ld a, [$c3c2]
    ld b, a
    ld a, [$c3a8]
    add b
    ld [$c3a8], a
    ret


Call_003_7436:
    ld a, [$c3d3]
    and a
    ret z

    dec a
    ld [$c3d3], a
    ret nz

    ld a, $81
    ld [$c3c1], a
    ld a, $11
    ld [$c3c3], a
    xor a
    ld [$c3c0], a
    ld [$c3bd], a
    ld [queenAnimFootCounter], a
    ld [$c3ca], a
    call Call_003_6e12
    ld b, $04
    ld hl, $c600
    call Call_003_6e17
    call Call_003_7aa8
    ret


Call_003_7466:
    ld a, [$c3cd]
    ld l, a
    ld a, [$c3ce]
    ld h, a
    ret


Call_003_746f:
    ld a, [$c3cc]
    sla a
    ld e, a
    ld d, $00
    ld hl, $6c8e
    add hl, de
    ld a, [hl+]
    ld [$c3cd], a
    ld a, [hl]
    ld [$c3ce], a
    ret

; 03:7484
    db $00, $02, $04, $02, $04, $06, $14, $ff

Call_003_748c:
    ld a, [$c3c3] ; Queen's state?
    rst $28
        dw $7821
        dw $783C
        dw $7864
        dw $78EE
        dw $78F7
        dw $7932
        dw $793B
        dw $7954
        dw $7970
        dw $79D0
        dw $79E1
        dw $7A1D
        dw $7846
        dw $772B
        dw $776F
        dw $7785
        dw $77DD
        dw $7ABF
        dw $7B05
        dw $7B9D
        dw $7519
        dw $757B
        dw $7BE7
        dw func_74C4
        dw $74EA
        dw enAI_NULL ; Wrong bank, you silly programmer.

func_74C4:
    ld a, [$c3cf]
    and a
    jr z, jr_003_74cf

jr_003_74ca:
    dec a

jr_003_74cb:
    ld [$c3cf], a
    ret


jr_003_74cf:
    ld a, $02
    ld [$c3ca], a
    ld a, $18
    ld [$c3c3], a
    ld a, [$c3ef]
    and a
    ld a, $09
    jr z, jr_003_74e3

    ld a, $0a

jr_003_74e3:
    ld [sfxRequest_noise], a
    ld a, $32
    jr jr_003_74cb

    ld a, [$c3cf]
    and a
    jr nz, jr_003_74ca

    ld a, $01
    ld [$c3ca], a
    ld a, $0c
    ld [$c3c3], a
    ret


Call_003_74fb:
    ld de, $d03b
    ld hl, $c3e6
    ld a, [de]
    ld b, a
    ld [hl+], a
    inc de
    ld a, [de]
    ld c, a
    ld [hl+], a
    ld a, $f0
    add b
    ld [hl+], a
    ld a, $f0
    add c
    ld [hl+], a
    ld a, $10
    add b
    ld [hl+], a
    ld a, $10
    add c
    ld [hl], a
    ret


    call Call_003_74fb
    ld a, [$c3a9]
    add $20
    ld b, a
    ld a, [$c3a8]
    add $1c
    ld c, a
    ld hl, $c740
    ld d, $20
    call Call_003_756c
    ld l, $60
    ld d, $20
    call Call_003_756c
    ld l, $80
    ld d, $21
    call Call_003_756c
    ld hl, $c308
    ld de, $c740
    ld b, $03
    call Call_003_75fa
    ld a, $0e
    ld [$c3ee], a
    ld a, $02
    ld [$c3ca], a
    ld a, $20
    ld [$c3cf], a
    ld a, $10
    ld [$c3e5], a
    ld a, $15
    ld [$c3c3], a
    ld [$c3e3], a
    ld de, $fff8
    add hl, de
    jp Jump_003_7288


Call_003_756c:
    ld [hl], $00
    inc l
    ld [hl], b
    inc l
    ld [hl], c
    inc l
    ld [hl], $f2
    ld a, l
    add $05
    ld l, a
    ld [hl], d
    ret


    ld a, [$c3cf]
    and a
    jr z, jr_003_758c

    dec a
    ld [$c3cf], a
    jr nz, jr_003_758c

    ld a, $01
    ld [$c3ca], a

jr_003_758c:
    call Call_003_7658
    ld a, [$d05d]
    cp $ff
    jr z, jr_003_75b4

    cp $20
    jr z, jr_003_75b4

    cp $08
    jr z, jr_003_75a2

    cp $10
    jr nz, jr_003_75b4

jr_003_75a2:
    ld a, [$d05f]
    cp $c7
    jr nz, jr_003_75b4

    ld h, a
    ld a, [$d05e]
    cp $40
    jr c, jr_003_75b4

    ld l, a
    ld [hl], $ff

jr_003_75b4:
    ld a, $ff
    ld [$d05d], a
    ld de, $0020
    ld hl, $c740
    ld b, $03

jr_003_75c1:
    ld a, [hl]
    cp $ff
    jr nz, jr_003_75cc

    add hl, de
    dec b
    jr nz, jr_003_75c1

    jr jr_003_75d0

jr_003_75cc:
    call Call_003_75fa
    ret


jr_003_75d0:
    ld hl, $c740
    ld de, $0020
    ld b, $03

jr_003_75d8:
    ld [hl], $ff
    add hl, de
    dec b
    jr nz, jr_003_75d8

    ld hl, $c308
    ld de, $0004
    ld b, $0c
    ld a, $ff

jr_003_75e8:
    ld [hl], a
    add hl, de
    dec b
    jr nz, jr_003_75e8

    call Call_003_7846
    xor a
    ld [$c3e3], a
    ld hl, $c300
    jp Jump_003_7288


Call_003_75fa:
    ld hl, $c308
    ld de, $c740
    ld b, $03

jr_003_7602:
    push bc

jr_003_7603:
    push de
    ld a, [de]
    ld bc, $f0f0
    cp $ff
    jr z, jr_003_761a

    inc e
    ld a, [de]
    cp $e0
    jr nc, jr_003_7627

    ld b, a
    inc e
    ld a, [de]
    cp $e0
    jr nc, jr_003_7627

    ld c, a

jr_003_761a:
    call Call_003_762d
    pop de
    pop bc
    ld a, e
    add $20
    ld e, a
    dec b
    jr nz, jr_003_7602

    ret


jr_003_7627:
    pop de
    ld a, $ff
    ld [de], a
    jr jr_003_7603

Call_003_762d:
    ld d, $f1
    ld e, $c0
    call Call_003_764f
    ld a, $f8
    add b
    ld b, a
    ld e, $80
    call Call_003_764f
    ld a, $f8
    add c
    ld c, a
    dec d
    call Call_003_764f
    ld a, $08
    add b
    ld b, a
    ld e, $c0
    call Call_003_764f
    ret


Call_003_764f:
    ld [hl], b
    inc l
    ld [hl], c
    inc l
    ld [hl], d
    inc l
    ld [hl], e
    inc l
    ret


Call_003_7658:
    ld b, $03
    ld hl, $c740

jr_003_765d:
    push hl
    push bc
    ld a, [hl]
    and a
    jr nz, jr_003_7666

    call Call_003_7701

jr_003_7666:
    pop bc
    pop hl
    ld de, $0020
    add hl, de
    dec b
    jr nz, jr_003_765d

    ld a, [$c3e5]
    and a
    jr z, jr_003_767a

    dec a
    ld [$c3e5], a
    ret


jr_003_767a:
    ld a, $03
    ld [$c3e5], a
    ld a, [$c3ee]
    and a
    ret z

    dec a
    ld [$c3ee], a
    call Call_003_74fb
    ld hl, $c748
    ld de, $c3e6
    ld b, $03

jr_003_7693:
    push hl
    push de
    push bc
    call Call_003_76a6
    pop bc
    pop de
    pop hl
    ld a, l
    add $20
    ld l, a
    inc de
    inc de
    dec b
    jr nz, jr_003_7693

    ret


Call_003_76a6:
    ld a, [hl]
    ld [$c3e4], a
    ld a, l
    sub $07
    ld l, a
    ld a, [$c3e4]
    and $0f
    ld c, a
    call Call_003_76d5
    inc de
    inc hl
    ld a, c
    and $0f
    ld b, a
    ld a, [$c3e4]
    and $f0
    swap a
    ld c, a
    call Call_003_76d5
    ld a, c
    and $0f
    swap a
    or b
    ld b, a
    ld a, l
    add $06
    ld l, a
    ld [hl], b
    ret


Call_003_76d5:
    ld a, [de]
    sub [hl]
    ret z

    push af
    cp $06
    jr c, jr_003_76fb

    cp $fa
    jr nc, jr_003_76fb

jr_003_76e1:
    pop af
    ld a, c
    jr nc, jr_003_76f0

    cp $0e
    ret z

    dec a
    and $0f
    jr nz, jr_003_76ee

    dec a

jr_003_76ee:
    ld c, a
    ret


jr_003_76f0:
    cp $02
    ret z

    inc a
    and $0f
    jr nz, jr_003_76ee

    inc a
    jr jr_003_76ee

jr_003_76fb:
    ld a, c
    and a
    jr nz, jr_003_76e1

    pop af
    ret


Call_003_7701:
    ld b, $02
    inc hl
    push hl
    ld a, l
    add $07
    ld l, a
    ld a, [hl]
    ld [$c3e4], a
    pop hl
    push hl
    ld a, [$c3e4]

jr_003_7712:
    and $0f
    jr z, jr_003_7720

    bit 3, a
    jr nz, jr_003_771e

    inc [hl]
    inc [hl]
    jr jr_003_7720

jr_003_771e:
    dec [hl]
    dec [hl]

jr_003_7720:
    inc hl
    ld a, [$c3e4]
    swap a
    dec b
    jr nz, jr_003_7712

    pop hl
    ret


    ld a, [$c3a6]
    ld l, a
    ld a, [$c3a7]
    ld h, a
    ld a, [hl]
    cp $81
    jp z, Jump_003_7846

    ld a, $02
    ld [$c3ba], a
    ld [$c3c0], a
    ld a, [$c3cb]
    cp $03
    jr nz, jr_003_7750

    ld a, [$c3a9]
    add $10
    ld [$c3a9], a

jr_003_7750:
    ld a, $01
    ld [$c3ca], a
    ld [$c3cb], a
    xor a
    ld [$c3c1], a
    ld a, $ff
    ld [$c620], a
    ld a, $f5
    ld [$c623], a
    ld a, $0e
    ld [$c3c3], a
    dec hl
    jp Jump_003_7399


    ld a, [$c3c1]
    cp $82
    ret nz

    ld a, $03
    ld [$d090], a
    ld a, $0f
    ld [$c3c3], a
    ld a, $01
    ld [queenAnimFootCounter], a
    ret


    ld a, [$d090]
    cp $04
    jr nz, jr_003_77b8

    ld a, [$c3d3]
    sub $0a
    ld [$c3d3], a
    jr c, jr_003_77d5

    ld a, $05
    ld [$d090], a
    ld a, $02
    ld [$c3ca], a
    ld [$c3cb], a
    ld a, $10
    ld [$c3c3], a
    ld a, $3e
    ld [$c3d0], a
    ld a, $93
    ld [$c3d2], a
    ld a, $0a
    ld [sfxRequest_noise], a
    ret


jr_003_77b8:
    cp $06
    jr nz, jr_003_77bd

    ret


jr_003_77bd:
    cp $07
    ret nz

    ld a, $08

jr_003_77c2:
    ld [$d090], a
    ld a, $08
    ld [$c3c3], a
    ld a, $93
    ld [$c3d2], a
    ld a, $0a
    ld [sfxRequest_noise], a
    ret


jr_003_77d5:
    xor a
    ld [$c3d3], a
    ld a, $20
    jr jr_003_77c2

    ld a, [$c3d0]
    and a
    jr z, jr_003_77fd

    dec a
    ld [$c3d0], a
    cp $2e
    jr nz, jr_003_77f2

    xor a
    ld [$c3d2], a
    call Call_003_7812

jr_003_77f2:
    ld a, [queenAnimFootCounter]
    cp $02
    ret nz

    xor a
    ld [queenAnimFootCounter], a
    ret


jr_003_77fd:
    ld [$d090], a
    ld a, $01
    ld [$c3ca], a
    ld [$c3cb], a
    ld a, $06
    ld [$c3c3], a
    ld hl, $748a
    jr jr_003_7856

Call_003_7812:
    ld b, $0c
    ld hl, $c308

jr_003_7817:
    inc l
    inc l
    inc l
    ld a, $80
    ld [hl+], a
    dec b
    jr nz, jr_003_7817

    ret


    xor a
    ld [$c3a4], a
    ld [$c3ba], a
    inc a
    ld [$c3bd], a
    ld a, $03
    ld [$c3c0], a
    ld a, $02
    ld [queenAnimFootCounter], a
    ld a, $01
    ld [$c3c3], a
    ret


    ld a, [$c3bf]
    cp $81
    ret nz

    xor a
    ld [queenAnimFootCounter], a

Call_003_7846:
Jump_003_7846:
    ld a, [$c3c4]
    ld l, a
    ld a, [$c3c5]
    ld h, a

jr_003_784e:
    ld a, [hl+]
    cp $ff
    jr z, jr_003_785f

    ld [$c3c3], a

jr_003_7856:
    ld a, l
    ld [$c3c4], a
    ld a, h
    ld [$c3c5], a
    ret


jr_003_785f:
    ld hl, $7484
    jr jr_003_784e

    ld hl, $c620
    ld [hl], $00
    ld a, $01
    ld [$c3c0], a
    ld [$c3ba], a
    ld a, $03
    ld [$c3c3], a
    ld a, [$c3be]
    xor $01
    ld [$c3be], a
    ld a, [$c3f1]
    and a
    jr nz, jr_003_78ac

    ld a, [$c3be]
    and a
    jr z, jr_003_78ac

    ld a, [$c3a9]
    ld b, $02
    cp $46
    jr c, jr_003_78a5

    ld b, $03
    ld a, [$c3a9]
    add $f0
    ld [$c3a9], a
    ld a, $03
    ld [$c3ca], a
    ld [$c3cb], a

jr_003_78a5:
    ld a, b
    ld [$c3cc], a
    jp Jump_003_78e4


jr_003_78ac:
    ld a, [$c3a9]
    ld b, $00
    cp $29
    jr c, jr_003_78c5

    ld b, $06
    cp $4c
    jr c, jr_003_78c5

    ld b, $01
    ld a, [$c3a9]
    add $f0
    ld [$c3a9], a

jr_003_78c5:
    ld a, b
    ld [$c3cc], a
    ld b, $03
    cp $01
    jr z, jr_003_78dd

    ld b, $02
    ld a, [rDIV]
    and $03
    jr z, jr_003_78e4

    ld hl, $c623
    ld [hl], $f6

jr_003_78dd:
    ld a, b
    ld [$c3ca], a
    ld [$c3cb], a

Jump_003_78e4:
jr_003_78e4:
    call Call_003_746f
    call Call_003_7466
    inc hl
    jp Jump_003_7399


    ld a, [$c3c1]
    cp $81
    ret nz

    jp Jump_003_7846


    ld a, [$c3a6]
    ld l, a
    ld a, [$c3a7]
    ld h, a
    ld a, [hl]
    cp $81
    jp z, Jump_003_7846

    ld a, $02
    ld [$c3ba], a
    ld [$c3c0], a
    ld a, [$c3cb]
    cp $03
    jr nz, jr_003_791c

    ld a, [$c3a9]
    add $10
    ld [$c3a9], a

jr_003_791c:
    ld a, $01
    ld [$c3ca], a
    ld [$c3cb], a
    ld a, $f5
    ld [$c623], a
    ld a, $05
    ld [$c3c3], a
    dec hl
    jp Jump_003_7399


    ld a, [$c3c1]
    cp $82
    ret nz

    jp Jump_003_7846


    ld a, $02
    ld [$c3bd], a
    ld a, $03
    ld [$c3c0], a
    xor a
    ld [$c3ba], a
    ld a, $82
    ld [queenAnimFootCounter], a
    ld a, $07
    ld [$c3c3], a
    ret


    ld a, [$c3bf]
    cp $82
    ret nz

    xor a
    ld [queenAnimFootCounter], a
    jp Jump_003_7846


    db $00, $00, $b5, $08, $00, $c5, $00, $08, $b6, $00, $10, $b7, $08, $0c, $c6

    ld a, [$c3a9]
    cp $2c
    cp $71
    ld a, $01
    ld [$c3c0], a
    xor a
    ld [$c3ba], a
    ld a, $03
    ld [$c3ca], a
    ld [$c3cb], a
    ld a, $09
    ld [$c3c3], a
    ld hl, $c308
    ld a, [$c3a9]
    add $14
    ld b, a
    ld a, [$c3a8]
    add $02
    ld c, a
    ld de, $7961

jr_003_799f:
    ld a, [de]
    add b
    ld [hl+], a
    inc de
    ld a, [de]
    add c
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    ld [hl], $80
    inc l
    inc de
    ld a, l
    cp $1c
    jr nz, jr_003_799f

    dec l
    dec l
    dec l
    dec l
    ld a, l
    ld [$c3b8], a
    ld a, h
    ld [$c3b9], a
    ld a, $04
    ld [$c3cc], a
    ld [$c3d1], a
    call Call_003_746f
    call Call_003_7466
    inc hl
    jp Jump_003_7399


    ld a, [$c3c1]
    cp $81
    ret nz

    ld a, $50
    ld [$c3cf], a
    ld a, $0a
    ld [$c3c3], a
    ret


    ld a, [$c3cf]
    and a
    jr z, jr_003_79f6

    dec a
    ld [$c3cf], a
    ld a, [queenAnimFootCounter]
    cp $02
    ret nz

    xor a
    ld [queenAnimFootCounter], a
    ret


jr_003_79f6:
    xor a
    ld [$c3d2], a
    ld a, [$c3d3]
    and a
    jr z, jr_003_7a4d

    sub $1e
    ld [$c3d3], a
    jr c, jr_003_7a4d

    ld a, $02
    ld [$c3c0], a
    ld a, $0b
    ld [$c3c3], a
    ld a, [$c3a6]
    ld l, a
    ld a, [$c3a7]
    ld h, a
    dec hl
    jp Jump_003_7399


    ld a, [$c3c1]
    cp $82
    ret nz

    ld a, $01
    ld [$c3ca], a
    ld [$c3cb], a
    xor a
    ld [$c3d1], a
    ld hl, $c308
    ld b, $05

jr_003_7a34:
    ld [hl], $ff
    inc l
    inc l
    inc l
    ld [hl], $80
    inc l
    dec b
    jr nz, jr_003_7a34

    ld hl, $c300
    ld a, l
    ld [$c3b8], a
    ld a, h
    ld [$c3b9], a
    jp Jump_003_7846


jr_003_7a4d:
    ld b, $0d
    ld hl, $c600
    call Call_003_6e17
    ld a, $01
    ld [$c3c0], a
    ld [$c3ba], a
    ld a, $11
    ld [$c3c3], a
    xor a
    ld [$c3b6], a
    ld [$c3b7], a
    ld [$c3d1], a
    ld [$c3d3], a
    ld [$c3c1], a
    ld [queenAnimFootCounter], a
    ld [$c3ca], a
    ld [$c3ef], a
    ld hl, $c308
    ld a, l
    ld [$c3b8], a
    ld a, h
    ld [$c3b9], a
    inc l
    inc l
    inc l
    ld [hl], $80
    inc l
    inc l
    inc l
    inc l
    ld [hl], $80
    call Call_003_7aa8
    ld a, $0f
    ld [sfxRequest_noise], a
    ld a, $05
    ld [$c3cc], a
    call Call_003_746f
    call Call_003_7466
    inc hl
    jp Jump_003_7399


Call_003_7aa8:
    ld hl, $9b0e

jr_003_7aab:
    ld a, [rSTAT]
    and $03
    jr nz, jr_003_7aab

    ld [hl], $5d
    inc l

jr_003_7ab5:
    ld a, [rSTAT]
    and $03
    jr nz, jr_003_7ab5

    ld [hl], $5e
    ret


    ld a, [$c3c1]
    cp $81
    ret nz

    ld a, $50
    ld [$c3cf], a
    ld a, $12
    ld [$c3c3], a
    ld a, $05
    ld [$c3d5], a
    xor a
    ld [$c3d3], a
    ld [$c3d4], a
    ld hl, $c3d6
    ld [hl], $ee
    inc hl
    ld [hl], $bb
    inc hl
    ld [hl], $dd
    inc hl
    ld [hl], $77
    inc hl
    ld [hl], $ee
    inc hl
    ld [hl], $bb
    inc hl
    ld [hl], $dd
    inc hl
    ld [hl], $77
    ld a, $d0
    ld [$d083], a
    ; Play earthquake sound
    ld a, $0e
    ld [songRequest], a
    ld a, $22
    ld [$d090], a
    ret


    ld a, [$c3cf]
    and a
    jr z, jr_003_7b1e

    dec a
    ld [$c3cf], a
    cp $4c
    ret nz

    ld a, [samusEnergyTanks]
    ld [samusCurHealthHigh], a
    ld a, $99
    ld [samusCurHealthLow], a
    ret


jr_003_7b1e:
    ld a, [$c3e0]
    and a
    ret nz

    ld de, $c3d6
    ld b, $00
    ld a, [$c3d4]

jr_003_7b2b:
    cp b
    jr z, jr_003_7b32

    inc de
    inc b
    jr jr_003_7b2b

jr_003_7b32:
    ld b, a
    or $10
    ld [$c3de], a
    ld a, b
    add $03
    and $07
    ld [$c3d4], a
    jr nz, jr_003_7b4b

    ld a, [$c3d5]
    dec a
    ld [$c3d5], a
    jr z, jr_003_7b59

jr_003_7b4b:
    ld a, [de]
    rlca
    rlca
    rlca
    ld [de], a
    ld [$c3e0], a
    ld a, $8b
    ld [$c3df], a
    ret


jr_003_7b59:
    ld a, $a0
    ld [$c3ec], a
    ld a, $99
    ld [$c3ed], a
    ld a, $13
    ld [$c3c3], a
    ret


Call_003_7b69:
    ld a, [$c3e0]
    and a
    ret z

    ld b, a
    ld a, [$c3de]
    ld l, a
    ld a, [$c3df]
    ld h, a
    ld de, $0008
    ld c, $1a

jr_003_7b7c:
    ld a, [hl]
    and b
    ld [hl], a
    add hl, de
    ld a, h
    cp $95
    jr z, jr_003_7b91

jr_003_7b85:
    dec c
    jr nz, jr_003_7b7c

    ld a, h
    ld [$c3df], a
    ld a, l
    ld [$c3de], a
    ret


jr_003_7b91:
    ld a, l
    and $f0
    cp $70
    jr nz, jr_003_7b85

    xor a
    ld [$c3e0], a
    ret


    ld a, [$c3ec]
    ld l, a
    ld a, [$c3ed]
    ld h, a
    ld b, $0b

jr_003_7ba7:
    ld a, [rSTAT]
    and $03
    jr nz, jr_003_7ba7

    ld [hl], $ff

jr_003_7bb0:
    ld a, [rSTAT]
    and $03
    jr nz, jr_003_7bb0

    ld [hl], $ff
    inc hl
    dec b
    jr nz, jr_003_7ba7

    ld de, $0015
    add hl, de
    ld a, l
    cp $80
    jr z, jr_003_7bce

    ld [$c3ec], a
    ld a, h
    ld [$c3ed], a
    ret


jr_003_7bce:
    xor a
    ld [$d090], a
    ld [metroidCountDisplayed], a
    ld [metroidCountReal], a
    ld a, $16
    ld [$c3c3], a
    ld a, $80
    ld [$d096], a
    ld a, $17
    ld [sfxRequest_noise], a
    ret


Call_003_7be8:
    xor a
    ld [$c3c2], a
    ld a, [$c3bd]
    and a
    ret z

    ld b, a
    ld a, [$c3a3]
    and a
    jr z, jr_003_7bfd

    dec a
    ld [$c3a3], a
    ret


jr_003_7bfd:
    ld a, [$c3a4]
    ld l, a
    inc a
    ld [$c3a4], a
    ld h, $00
    ld de, $7c39
    add hl, de
    ld a, b
    cp $01
    jr nz, jr_003_7c29

    ld a, [hl]
    cp $81
    jr nz, jr_003_7c1d

    ld [$c3bf], a
    xor a
    ld [$c3bd], a
    ret


jr_003_7c1d:
    cpl
    inc a
    ld [$c3c2], a
    ld a, [hl]
    ld hl, $c3a1
    add [hl]
    ld [hl], a
    ret


jr_003_7c29:
    ld a, [hl]
    cp $82
    jr nz, jr_003_7c1d

    ld [$c3bf], a
    xor a
    ld [$c3bd], a
    ld [$c3a4], a
    ret


    db $ff, $ff, $ff, $ff, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe
    db $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $ff, $ff, $ff
    db $ff, $ff, $81, $01, $01, $01, $01, $02, $02, $02, $02, $02, $02, $02, $02, $02
    db $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
    db $01, $01, $01, $01, $01, $82

    push af
    push bc
    push de
    push hl
    ld a, [$c3aa]
    ld l, a
    ld a, [$c3ab]
    ld h, a

jr_003_7c8b:
    ld a, [hl]
    cp $ff
    jr z, jr_003_7ce3

    and $7f
    cp $01
    jr z, jr_003_7cba

    cp $02
    jr z, jr_003_7ccb

    cp $03
    jr z, jr_003_7cb1

    push hl
    ld hl, $ff40
    res 5, [hl]
    pop hl
    xor a
    ld [rSCX], a
    ld a, $70
    ld [rSCY], a
    inc l
    jr jr_003_7ce3

jr_003_7cb1:
    push hl
    ld hl, $ff40
    res 5, [hl]
    pop hl
    jr jr_003_7cd6

jr_003_7cba:
    ld a, [$c3a1]
    ld [rSCX], a
    ld a, [$c3d2]
    and a
    jr z, jr_003_7cd6

    ld [rBGP], a
    jr jr_003_7cd6

jr_003_7ccb:
    ld a, [$c206]
    ld [rSCX], a
    ld a, $93
    ld [rBGP], a

jr_003_7cd6:
    bit 7, [hl]
    jr z, jr_003_7cde

    inc l
    inc l
    jr jr_003_7c8b

jr_003_7cde:
    inc l
    ld a, [hl+]
    ld [rLYC], a

jr_003_7ce3:
    ld a, l
    ld [$c3aa], a
    ld a, h
    ld [$c3ab], a
    pop hl
    pop de
    pop bc
    pop af
ret


VBlank_drawQueen: ; 03:7CF0
    call queenDrawFeet
    call Call_003_7b69
    ld a, [$c206]
    ld [rSCX], a
    ld a, [$c205]
    ld [rSCY], a
    ld a, [$c3a8]
    cp $a6
    jr nz, jr_003_7d0b

    ld a, $a7

jr_003_7d0b:
    ld [rWX], a
    ld a, [$c3a9]
    ld [rWY], a
    add $26
    cp $90
    jr c, jr_003_7d1c

    ld a, $8f

jr_003_7d1c:
    ld [$c3ac], a
    ld a, [$c3a0]
    ld b, a
    ld a, [$c3a2]
    add b
    cp $90
    jr c, jr_003_7d2d

    ld a, $8f

jr_003_7d2d:
    ld d, a
    ld hl, $c3ad
    ld a, [$c3ac]
    ld b, a
    ld a, [$c3a0]
    sub b
    jr c, jr_003_7d52

    ld c, $83
    jr z, jr_003_7d41

    ld c, $03

jr_003_7d41:
    ld [hl], b
    inc l
    ld [hl], c
    inc l
    ld a, [$c3a0]
    ld [hl+], a
    ld [hl], $01
    inc l
    ld [hl], d
    inc l
    ld [hl], $02
    jr jr_003_7d81

jr_003_7d52:
    ld a, b
    sub d
    jr c, jr_003_7d6f

    ld c, $82
    jr z, jr_003_7d5c

    ld c, $02

jr_003_7d5c:
    ld a, [$c3a0]
    ld [hl+], a
    ld [hl], $01
    inc l
    ld [hl], d
    inc l
    ld [hl], c
    inc l
    ld a, [$c3ac]
    ld [hl+], a
    ld [hl], $03
    jr jr_003_7d81

jr_003_7d6f:
    ld a, [$c3a0]
    ld [hl+], a
    ld [hl], $01
    inc l
    ld a, [$c3ac]
    ld [hl+], a
    ld [hl], $03
    inc l
    ld [hl], d
    inc l
    ld [hl], $02

jr_003_7d81:
    ld b, $03
    ld hl, $c3ad

jr_003_7d86:
    ld a, [hl]
    cp $87
    jr nc, jr_003_7d90

    inc l
    inc l
    dec b
    jr nz, jr_003_7d86

jr_003_7d90:
    ld [hl], $87
    inc l
    ld [hl], $04
    inc l
    ld [hl], $ff
    ld hl, $c3ad
    ld a, [hl+]
    ld [rLYC], a
    ld a, l
    ld [$c3aa], a
    ld a, h
    ld [$c3ab], a
    ld hl, $ff40
    set 5, [hl]
ret

; 3:7DAD -- Freespace filled with $00 (nop)
