; Disassembly of "Metroid2.gb"
; This file was created with:
; mgbdis v1.4 - Game Boy ROM disassembler by Matt Currie and contributors.
; https://github.com/mattcurrie/mgbdis

SECTION "ROM Bank $004", ROMX[$4000], BANK[$4]

handleAudio:
    jp Jump_004_42b3

silenceAudio:
    jp Jump_004_477b

initializeAudio:
    jp Jump_004_4752


    db $09, $2d, $61

    nop
    add b

    db $2c, $80, $9c, $80, $06, $81, $6b, $81, $c9, $81, $23, $82, $77, $82, $c6, $82
    db $12, $83, $56, $83, $9b, $83, $da, $83, $16, $84, $4e, $84, $83, $84, $b5, $84
    db $e5, $84, $11, $85, $3b, $85, $63, $85, $89, $85, $ac, $85, $ce, $85, $ed, $85
    db $0a, $86, $27, $86, $42, $86, $5b, $86, $72, $86, $89, $86, $9e, $86, $b2, $86
    db $c4, $86, $d6, $86, $e7, $86, $f7, $86, $06, $87, $14, $87, $21, $87, $2d, $87
    db $39, $87, $44, $87, $4f, $87, $59, $87, $62, $87, $6b, $87, $73, $87, $7b, $87
    db $83, $87, $8a, $87, $90, $87, $97, $87, $9d, $87, $a2, $87, $a7, $87, $ac, $87
    db $b1, $87, $b6, $87, $ba, $87, $be, $87, $c1, $87, $c4, $87, $c8, $87, $cb, $87
    db $ce, $87, $d1, $87, $d4, $87, $d6, $87, $d9, $87, $db, $87, $dd, $87, $df, $87

    ld bc, $0201

    db $04, $08

    db $10
    inc bc

    db $06

    inc c
    ld bc, $0103
    jr nz, jr_004_40ad

    ld [bc], a

jr_004_40ad:
    inc b

    db $08, $10

    jr nz, @+$08

    db $0c

    jr @+$04

    dec b
    ld bc, $0240

    db $03, $06, $0c, $18, $30, $09, $12, $24

    inc b
    db $08
    db $01

    db $60

    ld [bc], a

    db $04, $08, $10, $20, $40, $0c, $18, $30

    dec b
    ld a, [bc]

    db $01, $80, $03, $05, $0a, $14, $28, $50, $0f, $1e, $3c

    rlca
    db $0e

    db $01, $a0, $03, $06, $0c, $18, $30, $60, $12, $24, $48, $08

    db $10

    db $02, $c0

    inc bc

    db $07, $0e, $1c, $38

    ld [hl], b

    db $15, $2a

    ld d, h
    add hl, bc
    ld [de], a
    ld [bc], a
    db $e0

    db $04, $08, $10, $20, $40, $80, $18, $30, $60, $0a, $14

    ld [bc], a
    rst $38

    db $04, $09, $12, $24, $48, $90, $1b, $36, $6c

    inc c
    ld a, [de]

    db $02

    rst $38

    db $ee, $ee, $a5, $e5, $e0, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    db $cc, $cc, $82, $c3, $c0, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

    ld [hl], a
    ld [hl], a
    ld d, c
    and d
    add b
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    cp $dc
    cp d
    sbc b
    adc d
    xor b
    ld [hl-], a
    db $10
    cp $ed
    db $db
    xor c
    add a
    ld h, l
    ld sp, $9900
    xor d
    cp e
    call z, $aabb
    ld [hl], a
    inc sp
    ld de, $6734
    adc c
    xor d
    and a
    add a
    ld a, b
    xor e
    rst $28
    cp $da
    sub a
    ld b, e
    db $11
    db $31

    db $ee, $ee, $ee, $00, $00, $00, $ee, $ee, $ee, $00, $00, $00, $ee, $00, $ee, $00
    db $aa, $aa, $aa, $00, $00, $00, $aa, $aa, $aa, $00, $00, $00, $aa, $00, $aa, $00
    db $77, $77, $77, $00, $00, $00, $77, $77, $77, $00, $00, $00, $77, $00, $77, $00
    db $44, $00, $22, $00, $00, $00, $22, $44, $44, $00, $00, $00, $33, $00, $44, $00

    rst $38
    rst $38
    nop
    nop
    rst $38
    rst $38
    nop
    nop
    rst $38
    rst $38
    nop
    nop
    rst $38
    rst $38
    nop
    nop
    nop
    ld [$8000], sp

    db $00, $21, $3d, $80, $30, $40, $31, $c0, $00, $31, $3e, $80, $35, $f7, $6e, $c0
    db $30, $61, $4b, $c0, $30, $c1, $6d, $c0, $00, $81, $4b, $80, $00, $f6, $6d, $80
    db $00, $b6, $6d, $80, $00, $77, $6d, $80, $00, $47, $6d, $80, $00, $97, $6b, $80
    db $00, $77, $6b, $80, $00, $57, $6b, $80, $00, $37, $6b, $80

    nop
    add b
    ld l, l
    add b
    nop
    ld b, b
    ld c, l
    add b

    db $00, $1f, $47, $80, $00, $40, $47, $80, $00, $40, $46, $80, $00, $40, $45, $80
    db $00, $40, $44, $80, $00, $40, $43, $80, $00, $40, $42, $80, $00, $40, $41, $80
    db $00, $1b, $37, $80, $00, $a5, $27, $80

    nop
    rra
    scf
    add b

    db $00, $27, $46, $80, $00, $27, $45, $80

    nop
    dec de
    ld l, e
    add b
    nop
    ld a, [de]
    ld l, e
    add b
    nop
    add hl, de
    ld l, e
    add b
    nop
    rra
    scf
    add b
    nop
    inc e
    ld l, h
    add b

    db $00, $51, $4d, $80, $30, $f1, $6f, $c0

    jr c, @-$5d

    dec sp
    ret nz

    jr c, @-$5d

    ld a, [hl-]
    ret nz

    db $00, $f4, $7a, $80

    nop
    db $f4
    ld a, e
    add b

    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01
    db $08, $10, $18, $20, $28, $30, $38, $40, $38, $30, $28, $20, $18, $10, $08, $00
    db $00, $05, $00, $05, $00, $05, $00, $05, $05, $00, $05, $00, $05, $00, $05, $00
    db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
    db $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03

Jump_004_42b3:
    ld a, [$cfc7]
    cp $01
    jp z, Jump_004_4801

    cp $02
    jp z, Jump_004_4846

    ld a, [$cfc8]
    and a
    jp nz, Jump_004_4852

Jump_004_42c7:
    ld a, [$cede]
    and a
    jr z, jr_004_42ea

    cp $01
    jr z, jr_004_432b

    cp $03
    jp z, Jump_004_4390

    cp $05
    jr z, jr_004_4335

    cp $08
    jp z, Jump_004_43fb

    cp $0e
    jr z, jr_004_433f

    cp $ff
    call z, Call_004_4323
    jr jr_004_42fa

jr_004_42ea:
    ld a, [$cedf]
    and a
    jr z, jr_004_42fa

    cp $02
    jp z, Jump_004_43c4

    cp $08
    jp z, Jump_004_4418

Jump_004_42fa:
jr_004_42fa:
    call Call_004_457c
    call Call_004_44cf
    call Call_004_446b
    call Call_004_44a4
    call Call_004_4512
    xor a
    ld [songRequest], a
    ld [sfxRequest_noise], a
    ld [sfxRequest_square1], a
    ld [sfxRequest_square2], a
    ld [$cece], a
    ld [$cede], a
    ld [$cfe5], a
    ld [$cfc7], a
    ret


Call_004_4323:
    xor a
    ld [$cede], a
    ld [$cedf], a
    ret


jr_004_432b:
    ld [$cedf], a
    ld a, $0a
    ld [songRequest], a
    jr jr_004_4345

jr_004_4335:
    ld [$cedf], a
    ld a, $20
    ld [songRequest], a
    jr jr_004_4345

jr_004_433f:
    ld [$cedf], a
    ld [songRequest], a

jr_004_4345:
    ld a, [songPlaying]
    ld [$cfc5], a
    ld a, [$cede]
    cp $0e
    jr z, jr_004_435c

    ld a, [$cfe6]
    ld [$cfe7], a
    xor a
    ld [$cfe6], a

jr_004_435c:
    ld a, [$cfec]
    ld [$cfed], a
    ld a, [$cf10]
    ld [$cfc9], a
    ld hl, $cf61
    ld de, $cf00
    ld a, [$400b]
    ld b, a

jr_004_4372:
    ld a, [de]
    ld [hl+], a
    inc de
    dec b
    ld a, b
    and a
    jr nz, jr_004_4372

    call Call_004_47b3
    ld [$cede], a
    ld [sfxRequest_square1], a
    ld [$cec1], a
    ld [sfxRequest_noise], a
    ld [$ced6], a
    ld [$cee7], a
    ret


Jump_004_4390:
    dec a
    ld [$cedf], a
    ld hl, $cf00
    ld de, $cf61
    ld a, [$400b]
    ld b, a

jr_004_439e:
    ld a, [de]
    ld [hl+], a
    inc de
    dec b
    ld a, b
    and a
    jr nz, jr_004_439e

    ld hl, $cf10
    ld de, $ff10

jr_004_43ac:
    ld a, [hl+]
    ld [de], a
    inc e
    ld a, e
    cp $24
    jr nz, jr_004_43ac

    xor a
    ld [$cede], a
    ld a, $ff
    ld [sfxRequest_square1], a
    ld [sfxRequest_square2], a
    ld [sfxRequest_noise], a
    ret


Jump_004_43c4:
    ld a, [$cf09]
    ld e, a
    ld a, [$cf0a]
    ld d, a
    xor a
    ldh [rNR30], a
    call Call_004_47c9
    ld a, [songPlaying]
    cp $0e
    jr z, jr_004_43df

    ld a, [$cfe7]
    ld [$cfe6], a

jr_004_43df:
    ld a, [$cfed]
    ld [$cfec], a
    ldh [rNR51], a
    ld a, [$cfc9]
    ld [$cf10], a
    xor a
    ld [$cedf], a
    ld [$cfeb], a
    ld a, [$cfc5]
    ld [songPlaying], a
    ret


Jump_004_43fb:
    ld [$cedf], a
    ld a, $d0
    ld [$cf5c], a
    ld a, [$cf3e]
    ld [$cf5d], a
    ld a, [$cf47]
    ld [$cf5e], a
    ld a, [$cf50]
    ld [$cf5f], a
    jp Jump_004_42fa


Jump_004_4418:
    ld a, [$cf5c]
    dec a
    ld [$cf5c], a
    cp $a0
    jr z, jr_004_4435

    cp $70
    jr z, jr_004_4439

    cp $30
    jr z, jr_004_4449

    cp $10
    jr z, jr_004_444d

    and a
    jr z, jr_004_4461

    jp Jump_004_42fa


jr_004_4435:
    ld a, $65
    jr jr_004_444f

jr_004_4439:
    xor a
    ld [$cf07], a
    ld a, $60
    ld [$cf50], a
    ld [$cf5f], a
    ld a, $45
    jr jr_004_444f

jr_004_4449:
    ld a, $25
    jr jr_004_444f

jr_004_444d:
    ld a, $13

jr_004_444f:
    ld [$cf3e], a
    ld [$cf47], a
    ld [$cf59], a
    ld [$cf5d], a
    ld [$cf5e], a
    jp Jump_004_42fa


jr_004_4461:
    xor a
    ld [songPlaying], a
    ld [$cedf], a
    jp Jump_004_45b4


Call_004_446b:
    ld a, [sfxRequest_square1]
    and a
    jr z, jr_004_448f

    cp $ff
    jp z, Jump_004_46f5

    cp $1f
    jr nc, jr_004_448f

    ld a, [$cec1]
    cp $0c
    jr z, jr_004_448f

    cp $18
    jr z, jr_004_448f

    ld a, [sfxRequest_square1]
    ld hl, $4ec4
    call Call_004_46de
    jp hl


Jump_004_448f:
jr_004_448f:
    ld a, [$cec1]
    and a
    ret z

    cp $1f
    jr nc, jr_004_449f

    ld hl, $4f00
    call Call_004_46de
    jp hl


jr_004_449f:
    xor a
    ld [$cec1], a
    ret


Call_004_44a4:
    ld a, [sfxRequest_square2]
    and a
    jr z, jr_004_44ba

    cp $ff
    jp z, Jump_004_4702

    cp $08
    jr nc, jr_004_44ba

    ld hl, $55f2
    call Call_004_46de
    jp hl


jr_004_44ba:
    ld a, [$cec8]
    and a
    ret z

    cp $08
    jr nc, jr_004_44ca

    ld hl, $5600
    call Call_004_46de
    jp hl


jr_004_44ca:
    xor a
    ld [$cec8], a
    ret


Call_004_44cf:
    ld a, [sfxRequest_noise]
    and a
    jr z, jr_004_44fd

    cp $ff
    jp z, Jump_004_470f

    cp $1b
    jr nc, jr_004_44fd

    ld a, [songPlaying]
    cp $0e
    ret z

    ld a, [$ced6]
    cp $0d
    jr z, jr_004_44fd

    cp $0e
    jr z, jr_004_44fd

    cp $0f
    jr z, jr_004_44fd

    ld a, [sfxRequest_noise]
    ld hl, $56cc
    call Call_004_46de
    jp hl


Jump_004_44fd:
jr_004_44fd:
    ld a, [$ced6]
    and a
    ret z

    cp $1b
    jr nc, jr_004_450d

    ld hl, $5700
    call Call_004_46de
    jp hl


jr_004_450d:
    xor a
    ld [$44fd], a
    ret


Call_004_4512:
    ld a, [$cfe5]
    and a
    jr z, jr_004_452f

    cp $ff
    jr z, jr_004_4544

    cp $06
    ret nc

    ld a, [$cfe5]
    ld [$cee6], a
    ld [$cfe6], a
    ld hl, $5d3f
    call Call_004_46de
    jp hl


jr_004_452f:
    ld a, [$cfe6]
    and a
    ret z

    cp $06
    jr nc, jr_004_453f

    ld hl, $5d49
    call Call_004_46de
    jp hl


jr_004_453f:
    xor a
    ld [$cfe6], a
    ret


jr_004_4544:
    xor a
    ldh [rNR30], a
    ld a, [$cf09]
    ld e, a
    ld a, [$cf0a]
    ld d, a
    call Call_004_47c9
    xor a
    ld [$cee6], a
    ld [$cfe5], a
    ld [$cfe6], a
    ld a, [songPlaying]
    cp $0e
    ret z

    ld a, [$cf1a]
    ldh [rNR30], a
    ld a, [$cf1b]
    ldh [rNR31], a
    ld a, [$cf1c]
    ldh [rNR32], a
    ld a, [$cf1d]
    ldh [rNR33], a
    ld a, [$cf1e]
    ldh [rNR34], a
    ret


Call_004_457c:
    ld a, [songRequest]
    and a
    jr z, jr_004_45d2

    cp $ff
    jr z, jr_004_45b4

    cp $0f
    jr nz, jr_004_4593

    call Call_004_4716
    call Call_004_4741
    ld a, [songRequest]

jr_004_4593:
    cp $21
    jr nc, jr_004_45d2

    ld [songPlaying], a
    dec a
    ld e, a
    ld d, $00
    ld hl, $5f70
    add hl, de
    ld a, [hl]
    ld [$cfec], a
    ldh [rNR51], a
    ld a, [songRequest]
    ld hl, $5f30
    call Call_004_46de
    jp Jump_004_48a0


Jump_004_45b4:
jr_004_45b4:
    xor a
    ld [$cf04], a
    ld [$cf05], a
    ld [$cf06], a
    ld [$cf07], a
    call Call_004_471d
    call Call_004_472e
    call Call_004_473c
    jp Jump_004_4748


jr_004_45cd:
    xor a
    ld [songPlaying], a
    ret


jr_004_45d2:
    ld a, [songPlaying]
    and a
    ret z

    cp $21
    jr nc, jr_004_45cd

    xor a
    ld [$cf08], a
    ld a, [$cf04]
    and a
    jr z, jr_004_461d

    ld a, $01
    ld [$cf03], a
    ld a, [$cf3f]
    ld [$cf36], a
    cp $01
    jp z, Jump_004_497a

    dec a
    ld [$cf3f], a
    ld a, [$cee4]
    and a
    jr nz, jr_004_461d

    ld a, [$cf40]
    ld [$cf37], a
    and a
    jr z, jr_004_461d

    ld a, [$cf13]
    ld c, a
    ld a, [$cf14]
    ld b, a
    call Call_004_4d75
    ld a, [$cf0e]
    ldh [rNR13], a
    ld a, [$cf0f]
    ldh [rNR14], a

Jump_004_461d:
jr_004_461d:
    xor a
    ld [$cf08], a
    ld a, [$cf05]
    and a
    jr z, jr_004_465f

    ld a, $02
    ld [$cf03], a
    ld a, [$cf48]
    ld [$cf36], a
    cp $01
    jp z, Jump_004_49f3

    dec a
    ld [$cf48], a
    ld a, [$cee5]
    and a
    jr nz, jr_004_465f

    ld a, [$cf49]
    ld [$cf37], a
    and a
    jr z, jr_004_465f

    ld a, [$cf18]
    ld c, a
    ld a, [$cf19]
    ld b, a
    call Call_004_4d75
    ld a, [$cf0e]
    ldh [rNR23], a
    ld a, [$cf0f]
    ldh [rNR24], a

Jump_004_465f:
jr_004_465f:
    xor a
    ld [$cf08], a
    ld a, [$cf06]
    and a
    jr z, jr_004_46a3

    ld a, $03
    ld [$cf03], a
    ld a, [$cf51]
    ld [$cf36], a
    cp $01
    jp z, Jump_004_4a81

    dec a
    ld [$cf51], a
    ld a, [$cee6]
    and a
    jr nz, jr_004_46a3

    ld a, [$cf52]
    ld [$cf37], a
    and a
    jr z, jr_004_46a3

    ld a, [$cf1d]
    ld c, a
    ld a, [$cf1e]
    ld b, a
    call Call_004_4d75
    ld a, [$cf0e]
    ldh [rNR33], a
    ld a, [$cf0f]
    res 7, a
    ldh [rNR34], a

Jump_004_46a3:
jr_004_46a3:
    xor a
    ld [$cf08], a
    ld a, [$cf07]
    and a
    jr z, jr_004_46c2

    ld a, $04
    ld [$cf03], a
    ld a, [$cf5a]
    ld [$cf36], a
    cp $01
    jp z, Jump_004_4af6

    dec a
    ld [$cf5a], a
    ret


jr_004_46c2:
    ld a, [$cf04]
    and a
    ret nz

    ld a, [$cf05]
    and a
    ret nz

    ld a, [$cf06]
    and a
    ret nz

    ld a, [$cf07]
    and a
    ret nz

    xor a
    ld [songPlaying], a
    ld [$cedf], a
    ret


Call_004_46de:
    dec a
    add a
    ld b, $00
    ld c, a
    add hl, bc
    ld c, [hl]
    inc hl
    ld b, [hl]
    ld l, c
    ld h, b
    ret


Call_004_46ea:
    ld a, [$cec3]
    and a
    jr z, jr_004_46f5

    dec a
    ld [$cec3], a
    ret


Jump_004_46f5:
jr_004_46f5:
    jr jr_004_4716

Call_004_46f7:
    ld a, [$ceca]
    and a
    jr z, jr_004_4702

    dec a
    ld [$ceca], a
    ret


Jump_004_4702:
jr_004_4702:
    jr jr_004_4727

Call_004_4704:
    ld a, [$ced8]
    and a
    jr z, jr_004_470f

    dec a
    ld [$ced8], a
    ret


Jump_004_470f:
jr_004_470f:
    jr jr_004_4741

    and a
    jr z, jr_004_477b

    dec a
    ret


Call_004_4716:
jr_004_4716:
    xor a
    ld [$cec1], a
    ld [$cee4], a

Call_004_471d:
    ld a, $08
    ldh [rNR12], a
    ld a, $80
    ldh [rNR14], a
    xor a
    ret


jr_004_4727:
    xor a
    ld [$cec8], a
    ld [$cee5], a

Call_004_472e:
    ld a, $08
    ldh [rNR22], a
    ld a, $80
    ldh [rNR24], a
    xor a
    ret


    xor a
    ld [$cee6], a

Call_004_473c:
    xor a
    ldh [rNR30], a
    xor a
    ret


Call_004_4741:
jr_004_4741:
    xor a
    ld [$ced6], a
    ld [$cee7], a

Jump_004_4748:
    ld a, $08
    ldh [rNR42], a
    ld a, $80
    ldh [rNR44], a
    xor a
    ret


Jump_004_4752:
    ld a, $80
    ldh [rNR52], a
    ld a, $77
    ldh [rNR50], a
    ld a, $ff
    ldh [rNR51], a
    ld hl, sfxRequest_square1

    jr_004_4761:
        ld [hl], $00
        inc hl
        ld a, h
        cp $d0
    jr nz, jr_004_4761
ret


Jump_004_476a:
    xor a
    ld [sfxRequest_square1], a
    ld [sfxRequest_square2], a
    ld [$cece], a
    ld [sfxRequest_noise], a
    ld [$cfc7], a
    ret


Jump_004_477b:
jr_004_477b:
    ld a, $ff
    ldh [rNR51], a
    xor a
    ld [sfxRequest_square1], a
    ld [sfxRequest_square2], a
    ld [$cece], a
    ld [sfxRequest_noise], a
    ld [$cec1], a
    ld [$cec8], a
    ld [$cecf], a
    ld [$ced6], a
    ld a, $ff
    ld [songRequest], a
    ld [songPlaying], a
    xor a
    ld [$cede], a
    ld [$cedf], a
    ld [$cfe5], a
    ld [$cfe6], a
    ld [$cfc8], a
    ld [$cfc7], a

Call_004_47b3:
    ld a, $08
    ldh [rNR12], a
    ldh [rNR22], a
    ldh [rNR42], a
    ld a, $80
    ldh [rNR14], a
    ldh [rNR24], a
    ldh [rNR44], a
    xor a
    ldh [rNR10], a
    ldh [rNR30], a
ret


Call_004_47c9:
    push bc
    push de
    ld c, $30

jr_004_47cd:
    ld a, [de]
    ld [c], a
    inc de
    inc c
    ld a, c
    cp $40
    jr nz, jr_004_47cd

    pop de
    pop bc
    ret


Call_004_47d9:
Jump_004_47d9:
    push hl
    ld hl, $ff10
    ld b, $05
    jr jr_004_47f9

Jump_004_47e1:
    push hl
    ld hl, $ff16
    ld b, $04
    jr jr_004_47f9

Jump_004_47e9:
    push hl
    ld hl, $ff1a
    ld b, $05
    jr jr_004_47f9

Call_004_47f1:
Jump_004_47f1:
    push hl
    ld hl, $ff20
    ld b, $04
    jr jr_004_47f9

jr_004_47f9:
    ld a, [de]
    ld [hl+], a
    inc de
    dec b
    jr nz, jr_004_47f9

    pop hl
    ret


Jump_004_4801:
    call Call_004_47b3
    xor a
    ld [$cec1], a
    ld [$cec8], a
    ld [$cecf], a
    ld [$ced6], a
    ld a, $40
    ld [$cfc8], a
    ld de, $487c

jr_004_4819:
    call Call_004_47f1
    jp Jump_004_476a


jr_004_481f:
    ld de, $4880
    jr jr_004_4819

jr_004_4824:
    ld de, $488e
    jr jr_004_4819

jr_004_4829:
    ld de, $4897
    jr jr_004_4819

jr_004_482e:
    ld de, $4884

jr_004_4831:
    call Call_004_47d9
    jp Jump_004_476a


jr_004_4837:
    ld de, $4889
    jr jr_004_4831

jr_004_483c:
    ld de, $4892
    jr jr_004_4831

jr_004_4841:
    ld de, $489b
    jr jr_004_4831

Jump_004_4846:
    xor a
    ld [$cfc8], a
    ld a, $1e
    ld [sfxRequest_square1], a
    jp Jump_004_42c7


Jump_004_4852:
    ld hl, $cfc8
    dec [hl]
    ld a, [hl]
    cp $3f
    jr z, jr_004_482e

    cp $3d
    jr z, jr_004_481f

    cp $3a
    jr z, jr_004_4837

    cp $32
    jr z, jr_004_4824

    cp $2f
    jr z, jr_004_483c

    cp $27
    jr z, jr_004_4829

    cp $24
    jr z, jr_004_4841

    cp $10
    jp nz, Jump_004_476a

    inc [hl]
    jp Jump_004_476a


    db $00, $87, $31, $80, $00, $83, $5d, $80, $1d, $80, $f7, $c0, $87, $1d, $80, $c7
    db $d0, $87, $00, $53, $5c, $80, $1d, $80, $77, $d5, $87, $00, $36, $5b, $80, $1d
    db $80, $47, $d9, $87

Jump_004_48a0:
    call Call_004_4e8e
    ld a, [hl+]
    bit 0, a
    jr z, jr_004_48af

    push af
    ld a, $01
    ld [$cf60], a
    pop af

jr_004_48af:
    res 0, a
    ld [$cf00], a
    ld a, [hl+]
    ld [$cf02], a
    ld a, [hl+]
    ld [$cf01], a
    ld a, [hl+]
    ld [$cf39], a
    ld a, [hl+]
    ld [$cf38], a
    ld a, [hl+]
    ld [$cf42], a
    ld a, [hl+]
    ld [$cf41], a
    ld a, [hl+]
    ld [$cf4b], a
    ld a, [hl+]
    ld [$cf4a], a
    ld a, [hl+]
    ld [$cf54], a
    ld a, [hl]
    ld [$cf53], a
    ld a, [$cf38]
    ld h, a
    ld a, [$cf39]
    ld l, a
    ld a, l
    or h
    jr nz, jr_004_48f6

    xor a
    ld [$cf04], a
    ld a, $08
    ldh [rNR12], a
    ld a, $80
    ldh [rNR14], a
    jr jr_004_4903

jr_004_48f6:
    ld a, $01
    ld [$cf04], a
    ld a, [hl+]
    ld [$cf27], a
    ld a, [hl]
    ld [$cf26], a

jr_004_4903:
    ld a, [$cf41]
    ld h, a
    ld a, [$cf42]
    ld l, a
    ld a, l
    or h
    jr nz, jr_004_491d

    xor a
    ld [$cf05], a
    ld a, $08
    ldh [rNR22], a
    ld a, $80
    ldh [rNR24], a
    jr jr_004_492a

jr_004_491d:
    ld a, $02
    ld [$cf05], a
    ld a, [hl+]
    ld [$cf29], a
    ld a, [hl]
    ld [$cf28], a

jr_004_492a:
    ld a, [$cf4a]
    ld h, a
    ld a, [$cf4b]
    ld l, a
    ld a, l
    or h
    jr nz, jr_004_493f

    xor a
    ld [$cf06], a
    xor a
    ldh [rNR30], a
    jr jr_004_494c

jr_004_493f:
    ld a, $03
    ld [$cf06], a
    ld a, [hl+]
    ld [$cf2b], a
    ld a, [hl]
    ld [$cf2a], a

jr_004_494c:
    ld a, [$cf53]
    ld h, a
    ld a, [$cf54]
    ld l, a
    ld a, l
    or h
    jr nz, jr_004_495e

    xor a
    ld [$cf07], a
    jr jr_004_496b

jr_004_495e:
    ld a, $04
    ld [$cf07], a
    ld a, [hl+]
    ld [$cf2d], a
    ld a, [hl]
    ld [$cf2c], a

jr_004_496b:
    ld a, $01
    ld [$cf3f], a
    ld [$cf48], a
    ld [$cf51], a
    ld [$cf5a], a
    ret


Jump_004_497a:
    ld de, $cf38
    ld hl, $cf2f
    call Call_004_4d68
    ld a, [$cf26]
    ld h, a
    ld a, [$cf27]
    ld l, a
    ld a, $01
    call Call_004_4b47
    ld a, [$cf03]
    ld [$cf04], a
    and a
    jp z, Jump_004_4e44

    ld a, h
    ld [$cf26], a
    ld a, l
    ld [$cf27], a
    ld hl, $cf38
    ld de, $cf2f
    call Call_004_4d68
    ld a, [$cf08]
    cp $01
    jr nz, jr_004_49be

    ld a, [$cf0b]
    ld [$cf10], a
    ld a, [$cf0c]
    ld [$cf11], a

jr_004_49be:
    ld a, [$cf0d]
    ld [$cf12], a
    ld a, [$cf0e]
    ld [$cf13], a
    ld a, [$cf0f]
    ld [$cf14], a
    ld a, [$cee4]
    and a
    jp nz, Jump_004_461d

    ld a, [$cf10]
    ldh [rNR10], a
    ld a, [$cf11]
    ldh [rNR11], a
    ld a, [$cf12]
    ldh [rNR12], a
    ld a, [$cf13]
    ldh [rNR13], a
    ld a, [$cf14]
    ldh [rNR14], a
    jp Jump_004_461d


Jump_004_49f3:
    ld de, $cf41
    ld hl, $cf2f
    call Call_004_4d68
    ld a, [$cf28]
    ld h, a
    ld a, [$cf29]
    ld l, a
    ld a, $02
    call Call_004_4b47
    ld a, [$cf03]
    ld [$cf05], a
    and a
    jp z, Jump_004_4e59

    ld a, h
    ld [$cf28], a
    ld a, l
    ld [$cf29], a
    ld hl, $cf41
    ld de, $cf2f
    call Call_004_4d68
    ld a, [$cf08]
    cp $02
    jr nz, jr_004_4a31

    ld a, [$cf0c]
    ld [$cf16], a

jr_004_4a31:
    ld a, [$cf0d]
    ld [$cf17], a
    ld a, [$cf0e]
    ld [$cf18], a
    ld a, [$cf0f]
    ld [$cf19], a
    ld a, [$cee5]
    and a
    jp nz, Jump_004_465f

    ld a, [$cf16]
    ldh [rNR21], a
    ld a, [$cf60]
    cp $01
    jr nz, jr_004_4a6f

    ld a, [$cf18]
    ld l, a
    ld a, [$cf19]
    ld h, a
    cp $87
    jr nc, jr_004_4a66

    inc hl
    inc hl
    jr jr_004_4a67

jr_004_4a66:
    inc hl

jr_004_4a67:
    ld a, l
    ld [$cf18], a
    ld a, h
    ld [$cf19], a

jr_004_4a6f:
    ld a, [$cf17]
    ldh [rNR22], a
    ld a, [$cf18]
    ldh [rNR23], a
    ld a, [$cf19]
    ldh [rNR24], a
    jp Jump_004_465f


Jump_004_4a81:
    ld de, $cf4a
    ld hl, $cf2f
    call Call_004_4d68
    ld a, [$cf2a]
    ld h, a
    ld a, [$cf2b]
    ld l, a
    ld a, $03
    call Call_004_4b47
    ld a, [$cf03]
    ld [$cf06], a
    and a
    jp z, Jump_004_4e6e

    ld a, h
    ld [$cf2a], a
    ld a, l
    ld [$cf2b], a
    ld hl, $cf4a
    ld de, $cf2f
    call Call_004_4d68
    ld a, [$cf0b]
    ld [$cf1a], a
    ld a, [$cf0c]
    ld [$cf1b], a
    ld a, [$cf0d]
    ld [$cf1c], a
    ld a, [$cf0e]
    ld [$cf1d], a
    ld a, [$cf0f]
    ld [$cf1e], a
    ld a, [$cee6]
    and a
    jp nz, Jump_004_46a3

    xor a
    ldh [rNR30], a
    ld a, [$cf1a]
    ldh [rNR30], a
    ld a, [$cf1b]
    ldh [rNR31], a
    ld a, [$cf1c]
    ldh [rNR32], a
    ld a, [$cf1d]
    ldh [rNR33], a
    ld a, [$cf1e]
    ldh [rNR34], a
    jp Jump_004_46a3


Jump_004_4af6:
    ld de, $cf53
    ld hl, $cf2f
    call Call_004_4d68
    ld a, [$cf2c]
    ld h, a
    ld a, [$cf2d]
    ld l, a
    ld a, $04
    call Call_004_4b47
    ld a, [$cf03]
    ld [$cf07], a
    and a
    jp z, Jump_004_4e7b

    ld a, h
    ld [$cf2c], a
    ld a, l
    ld [$cf2d], a
    ld hl, $cf53
    ld de, $cf2f
    call Call_004_4d68
    ld a, [$cee7]
    and a
    ret nz

    ld a, [$cf0c]
    ldh [rNR41], a
    ld a, [$cf0d]
    ldh [rNR42], a
    ld a, [$cf0e]
    ldh [rNR43], a
    ld [$cf22], a
    ld a, [$cf0f]
    ldh [rNR44], a
    ld [$cf23], a
    ret


Call_004_4b47:
    ld [$cf03], a
    ld a, [hl]
    and a
    jp nz, Jump_004_4b7f

Jump_004_4b4f:
    ld a, [$cf2f]
    ld h, a
    ld a, [$cf30]
    ld l, a
    inc hl
    inc hl
    ld a, h
    ld [$cf2f], a
    ld a, l
    ld [$cf30], a
    ld a, [hl]
    and a
    jr nz, jr_004_4b6f

    inc hl
    ld a, [hl-]
    and a
    jr nz, jr_004_4b6f

    xor a
    ld [$cf03], a
    ret


jr_004_4b6f:
    ld a, [hl]
    cp $f0
    jr nz, jr_004_4b7a

    inc hl
    ld a, [hl-]
    and a
    call z, Call_004_4d37

jr_004_4b7a:
    ld a, [hl+]
    ld b, a
    ld a, [hl]
    ld h, a
    ld l, b

Jump_004_4b7f:
jr_004_4b7f:
    ld a, [hl]
    cp $f1
    call z, Call_004_4cb7
    cp $f2
    call z, Call_004_4d25
    cp $f3
    call z, Call_004_4d30
    cp $f4
    call z, Call_004_4d45
    cp $f5
    call z, Call_004_4d54
    and a
    jp z, Jump_004_4b4f

    cp $f6
    jp nc, Jump_004_477b

    cp $f1
    jr nc, jr_004_4b7f

    cp $9f
    jp c, Jump_004_4bc7

    res 7, a
    res 5, a
    push af
    ld a, [$cf01]
    ld b, a
    ld a, [$cf02]
    ld c, a
    pop af
    push hl
    ld l, a
    ld h, $00
    add hl, bc
    ld a, [hl]
    pop hl
    ld [$cf36], a
    ld [$cf34], a
    inc hl

Jump_004_4bc7:
    ld a, [$cf34]
    ld [$cf36], a
    ld a, [$cf03]
    cp $04
    jp z, Jump_004_4c3d

    ld a, [hl+]
    cp $01
    jr z, jr_004_4c23

    cp $03
    jp z, Jump_004_4c5c

    cp $05
    jp z, Jump_004_4c63

    push hl
    push af
    ld a, [$cf03]
    cp $03
    jr nz, jr_004_4bff

    ld a, [$cee6]
    and a
    jr nz, jr_004_4bff

    ld hl, $ff25
    set 6, [hl]
    set 2, [hl]
    ld a, $80
    ld [$cf0b], a

jr_004_4bff:
    pop af
    ld b, a
    ld a, [$cf03]
    cp $04
    jr z, jr_004_4c0c

    ld a, [$cf00]
    add b

jr_004_4c0c:
    ld c, a
    ld b, $00
    ld hl, $400c
    add hl, bc
    ld a, [$cf35]
    ld [$cf0d], a
    ld a, [hl+]
    ld [$cf0e], a
    ld a, [hl]
    ld [$cf0f], a
    pop hl
    ret


jr_004_4c23:
    ld a, [$cf03]
    cp $03
    jr z, jr_004_4c35

    ld a, $08
    ld [$cf0d], a
    ld a, $80
    ld [$cf0f], a
    ret


jr_004_4c35:
    xor a
    ld [$cf0b], a
    ld [$cf0d], a
    ret


Jump_004_4c3d:
    ld a, [hl+]
    cp $01
    jr z, jr_004_4c23

    push hl
    ld c, a
    ld b, $00
    ld hl, $41bb
    add hl, bc
    ld a, [hl+]
    ld [$cf0c], a
    ld a, [hl+]
    ld [$cf0d], a
    ld a, [hl+]
    ld [$cf0e], a
    ld a, [hl]
    ld [$cf0f], a
    pop hl
    ret


Jump_004_4c5c:
    ld a, $66
    ld [$cf0d], a
    jr jr_004_4c6a

Jump_004_4c63:
    ld a, $46
    ld [$cf0d], a
    jr jr_004_4c6a

jr_004_4c6a:
    ld a, [$cedf]
    cp $08
    jr nz, jr_004_4c76

    ld a, $08
    ld [$cf0d], a

jr_004_4c76:
    ld a, [$cf03]
    cp $01
    jr z, jr_004_4c86

    cp $02
    jr z, jr_004_4c93

    cp $03
    jr z, jr_004_4ca0

    ret


jr_004_4c86:
    ld a, [$cf13]
    ld [$cf0e], a
    ld a, [$cf14]
    ld [$cf0f], a
    ret


jr_004_4c93:
    ld a, [$cf18]
    ld [$cf0e], a
    ld a, [$cf19]
    ld [$cf0f], a
    ret


jr_004_4ca0:
    ld a, [$cee6]
    and a
    ret nz

    ld a, $80
    ld [$cf0b], a
    ld a, [$cf1d]
    ld [$cf0e], a
    ld a, [$cf1e]
    ld [$cf0f], a
    ret


Call_004_4cb7:
    inc hl
    ld a, [$cf03]
    ld [$cf08], a
    cp $03
    jr z, jr_004_4cec

    ld a, [$cedf]
    cp $08
    jr nz, jr_004_4ccf

    ld a, [hl+]
    ld [$cf0d], a
    jr jr_004_4cd6

jr_004_4ccf:
    ld a, [hl+]
    ld [$cf0d], a
    ld [$cf35], a

jr_004_4cd6:
    ld a, [hl+]
    ld [$cf0b], a
    ld a, [hl]
    ld [$cf0c], a
    res 6, a
    res 7, a

jr_004_4ce2:
    and a
    jr nz, jr_004_4ce6

    xor a

jr_004_4ce6:
    ld [$cf37], a

jr_004_4ce9:
    inc hl

jr_004_4cea:
    ld a, [hl]
    ret


jr_004_4cec:
    ld a, [hl+]
    ld [$cf09], a
    ld [$cfe3], a
    ld e, a
    ld a, [hl+]
    ld [$cf0a], a
    ld [$cfe4], a
    ld d, a
    ld a, [$cedf]
    cp $08
    jr nz, jr_004_4d09

    ld a, [hl]
    ld [$cf0d], a
    jr jr_004_4d10

jr_004_4d09:
    ld a, [hl]
    ld [$cf0d], a
    ld [$cf35], a

jr_004_4d10:
    ld a, [$cee6]
    and a
    jr nz, jr_004_4d1c

    xor a
    ldh [rNR30], a
    call Call_004_47c9

jr_004_4d1c:
    ld a, [$cf0d]
    res 5, a
    res 6, a
    jr jr_004_4ce2

Call_004_4d25:
    inc hl
    ld a, [hl+]
    ld [$cf02], a
    ld a, [hl+]
    ld [$cf01], a
    jr jr_004_4cea

Call_004_4d30:
    inc hl
    ld a, [hl+]
    ld [$cf00], a
    jr jr_004_4cea

Call_004_4d37:
    inc hl
    inc hl
    ld a, [hl+]
    ld [$cf30], a
    ld b, a
    ld a, [hl]
    ld [$cf2f], a
    ld h, a
    ld l, b
    ret


Call_004_4d45:
    inc hl
    ld a, [hl+]
    ld [$cf33], a
    ld a, h
    ld [$cf31], a
    ld a, l
    ld [$cf32], a
    jr jr_004_4cea

Call_004_4d54:
    ld a, [$cf33]
    dec a
    ld [$cf33], a
    and a
    jr z, jr_004_4ce9

    ld a, [$cf31]
    ld h, a
    ld a, [$cf32]
    ld l, a
    jr jr_004_4cea

Call_004_4d68:
    ld a, [$4009]
    ld b, a

jr_004_4d6c:
    ld a, [de]
    ld [hl+], a
    inc de
    dec b
    ld a, b
    and a
    jr nz, jr_004_4d6c

    ret


Call_004_4d75:
    ld a, [$cf37]
    cp $02
    jr z, jr_004_4dc4

    cp $03
    jr z, jr_004_4dc9

    cp $04
    jr z, jr_004_4dce

    cp $06
    jr z, jr_004_4ddd

    cp $07
    jp z, Jump_004_4e21

    cp $08
    jp z, Jump_004_4e33

    cp $09
    jp z, Jump_004_4dd3

    cp $0a
    jp z, Jump_004_4dd8

    ret


jr_004_4d9d:
    ld a, [$cf2e]
    and a
    jr nz, jr_004_4da8

    ld a, $11
    ld [$cf2e], a

jr_004_4da8:
    dec a
    ld [$cf2e], a
    ld e, a
    xor a
    ld d, a
    add hl, de
    ld a, [hl]
    ld e, a
    ld a, c
    ld l, a
    ld a, b
    ld h, a
    add hl, de
    ld a, l
    ld [$cf0e], a
    ld a, h
    res 7, a
    res 6, a
    ld [$cf0f], a
    ret


jr_004_4dc4:
    ld hl, $4263
    jr jr_004_4d9d

jr_004_4dc9:
    ld hl, $4273
    jr jr_004_4d9d

jr_004_4dce:
    ld hl, $4283
    jr jr_004_4d9d

Jump_004_4dd3:
    ld hl, $4293
    jr jr_004_4d9d

Jump_004_4dd8:
    ld hl, $42a3
    jr jr_004_4d9d

jr_004_4ddd:
    inc bc
    ld a, c
    ld [$cf0e], a
    ld a, b
    res 7, a
    res 6, a
    ld [$cf0f], a

jr_004_4dea:
    ld a, [$cf03]
    cp $01
    jr nz, jr_004_4dfe

    ld a, [$cf0e]
    ld [$cf13], a
    ld a, [$cf0f]
    ld [$cf14], a
    ret


jr_004_4dfe:
    cp $02
    jr nz, jr_004_4e0f

    ld a, [$cf0e]
    ld [$cf18], a
    ld a, [$cf0f]
    ld [$cf19], a
    ret


jr_004_4e0f:
    cp $03
    ret nz

    ld a, [$cf0e]
    ld [$cf1d], a
    ld a, [$cf0f]
    res 7, a
    ld [$cf1e], a
    ret


Jump_004_4e21:
    inc bc
    inc bc
    inc bc
    inc bc
    ld a, c
    ld [$cf0e], a
    ld a, b
    res 7, a
    res 6, a
    ld [$cf0f], a
    jr jr_004_4dea

Jump_004_4e33:
    dec bc
    dec bc
    dec bc
    ld a, c
    ld [$cf0e], a
    ld a, b
    res 7, a
    res 6, a
    ld [$cf0f], a
    jr jr_004_4dea

Jump_004_4e44:
    xor a
    ld [$cf04], a
    ld a, $08
    ldh [rNR12], a
    ld [$cf12], a
    ld a, $80
    ldh [rNR14], a
    ld [$cf14], a
    jp Jump_004_461d


Jump_004_4e59:
    xor a
    ld [$cf05], a
    ld a, $08
    ldh [rNR22], a
    ld [$cf17], a
    ld a, $80
    ldh [rNR24], a
    ld [$cf19], a
    jp Jump_004_465f


Jump_004_4e6e:
    xor a
    ld [$cf06], a
    xor a
    ldh [rNR30], a
    ld [$cf1a], a
    jp Jump_004_46a3


Jump_004_4e7b:
    xor a
    ld [$cf07], a
    ld a, $08
    ldh [rNR42], a
    ld [$cf21], a
    ld a, $80
    ldh [rNR44], a
    ld [$cf23], a
    ret


Call_004_4e8e:
    push hl
    ld hl, $cf2f
    ld a, [$400a]
    ld b, a

jr_004_4e96:
    ld [hl], $00
    inc hl
    dec b
    ld a, b
    and a
    jr nz, jr_004_4e96

    pop hl
    xor a
    ld [$cee4], a
    ld [$cee5], a
    ld [$cee6], a
    ld [$cee7], a
    ld [$cf60], a
    ldh [rNR10], a
    ldh [rNR30], a
    ld a, $08
    ldh [rNR12], a
    ldh [rNR22], a
    ldh [rNR42], a
    ld a, $80
    ldh [rNR14], a
    ldh [rNR24], a
    ldh [rNR44], a
    ret


    db $4c, $4f, $b9, $4f, $30, $50, $d5, $50, $fd, $50, $1d, $51, $47, $51, $87, $51
    db $ed, $51, $06, $52, $1f, $52, $38, $52, $70, $52, $84, $52, $b6, $52, $cc, $52

    ld l, c
    ld b, a
    inc a
    ld d, e

    db $43, $53

    ld c, e
    ld d, e

    db $61, $53, $77, $53, $b7, $53, $f7, $53

    add hl, hl
    ld d, h

    db $3f, $54, $97, $54, $ce, $54, $ee, $54, $1c, $55, $6c, $4f, $d9, $4f, $38, $50
    db $e5, $50, $05, $51, $25, $51, $4f, $51, $8f, $51, $fa, $51, $13, $52, $2c, $52
    db $40, $52, $78, $52, $8f, $52, $be, $52, $d4, $52

    ld l, c
    ld b, a
    db $ea
    ld b, [hl]

    db $ea, $46

    ld d, e
    ld d, e

    db $69, $53, $7f, $53, $c2, $53, $ea, $46

    db $31
    ld d, h

    db $47, $54, $ae, $54, $d6, $54, $f6, $54, $24, $55

jr_004_4f3c:
    ld a, $0b
    ld de, $5a28
    jp Jump_004_55e3


jr_004_4f44:
    call Call_004_46ea
    cp $09
    jr z, jr_004_4f8b

    ret


    ld a, [$cec1]
    cp $16
    jp z, Jump_004_448f

    cp $07
    jr c, jr_004_4f5d

    cp $0b
    jp c, Jump_004_448f

jr_004_4f5d:
    ld a, [songPlaying]
    cp $03
    jr z, jr_004_4f3c

    ld a, $32
    ld de, $5a28
    jp Jump_004_55e3


    ld a, [songPlaying]
    cp $03
    jr z, jr_004_4f44

    call Call_004_46ea
    cp $2d
    jr z, jr_004_4f8b

    cp $1e
    jr z, jr_004_4f91

    cp $18
    jr z, jr_004_4f97

    cp $06
    jr z, jr_004_4f9d

    cp $01
    jr z, jr_004_4fa3

    ret


jr_004_4f8b:
    ld de, $5a2d
    jp Jump_004_47d9


jr_004_4f91:
    ld de, $5a32
    jp Jump_004_47d9


jr_004_4f97:
    ld de, $5a37
    jp Jump_004_47d9


jr_004_4f9d:
    ld de, $5a3c
    jp Jump_004_47d9


jr_004_4fa3:
    ld de, $5a41
    jp Jump_004_47d9


jr_004_4fa9:
    ld a, $09
    ld de, $5a46
    jp Jump_004_55e3


jr_004_4fb1:
    call Call_004_46ea
    cp $08
    jr z, jr_004_5006

    ret


    ld a, [$cec1]
    cp $16
    jp z, Jump_004_448f

    cp $07
    jr c, jr_004_4fca

    cp $0b
    jp c, Jump_004_448f

jr_004_4fca:
    ld a, [songPlaying]
    cp $03
    jr z, jr_004_4fa9

    ld a, $43
    ld de, $5a46
    jp Jump_004_55e3


    ld a, [songPlaying]
    cp $03
    jr z, jr_004_4fb1

    call Call_004_46ea
    cp $41
    jr z, jr_004_5006

    cp $2d
    jr z, jr_004_500c

    cp $2b
    jr z, jr_004_5012

    cp $18
    jr z, jr_004_5018

    cp $15
    jr z, jr_004_501e

    cp $04
    jr z, jr_004_5024

    cp $01
    jr z, jr_004_502a

    ret


    ld de, $5a46
    jp Jump_004_47d9


jr_004_5006:
    ld de, $5a4b
    jp Jump_004_47d9


jr_004_500c:
    ld de, $5a50
    jp Jump_004_47d9


jr_004_5012:
    ld de, $5a55
    jp Jump_004_47d9


jr_004_5018:
    ld de, $5a5a
    jp Jump_004_47d9


jr_004_501e:
    ld de, $5a5f
    jp Jump_004_47d9


jr_004_5024:
    ld de, $5a64
    jp Jump_004_47d9


jr_004_502a:
    ld de, $5a69
    jp Jump_004_47d9


    ld a, $3f
    ld de, $5a6e
    jp Jump_004_55e3


    ld a, [$cec3]
    and a
    call z, Call_004_50d2
    dec a
    ld [$cec3], a
    cp $3b
    jr z, jr_004_5084

    cp $37
    jr z, jr_004_508a

    cp $33
    jr z, jr_004_5090

    cp $2f
    jr z, jr_004_5096

    cp $2b
    jr z, jr_004_509c

    cp $27
    jr z, jr_004_50a2

    cp $23
    jr z, jr_004_50a8

    cp $1f
    jr z, jr_004_50ae

    cp $1b
    jr z, jr_004_50b4

    cp $17
    jr z, jr_004_50ba

    cp $13
    jr z, jr_004_50c0

    cp $0f
    jr z, jr_004_50ba

    cp $0c
    jr z, jr_004_50c0

    cp $09
    jr z, jr_004_50c6

    cp $06
    jr z, jr_004_50cc

    cp $03
    jr z, jr_004_50c6

    ret


jr_004_5084:
    ld de, $5a73
    jp Jump_004_47d9


jr_004_508a:
    ld de, $5a78
    jp Jump_004_47d9


jr_004_5090:
    ld de, $5a7d
    jp Jump_004_47d9


jr_004_5096:
    ld de, $5a82
    jp Jump_004_47d9


jr_004_509c:
    ld de, $5a87
    jp Jump_004_47d9


jr_004_50a2:
    ld de, $5a8c
    jp Jump_004_47d9


jr_004_50a8:
    ld de, $5a91
    jp Jump_004_47d9


jr_004_50ae:
    ld de, $5a96
    jp Jump_004_47d9


jr_004_50b4:
    ld de, $5a9b
    jp Jump_004_47d9


jr_004_50ba:
    ld de, $5aa0
    jp Jump_004_47d9


jr_004_50c0:
    ld de, $5aa5
    jp Jump_004_47d9


jr_004_50c6:
    ld de, $5aaa
    jp Jump_004_47d9


jr_004_50cc:
    ld de, $5aaf
    jp Jump_004_47d9


Call_004_50d2:
    ld a, $10
    ret


    ld a, [$cec1]
    cp $04
    jp nc, Jump_004_448f

    ld a, $0a
    ld de, $5ab4
    jp Jump_004_55e3


    call Call_004_46ea
    cp $06
    jr z, jr_004_50f1

    cp $02
    jr z, jr_004_50f7

    ret


jr_004_50f1:
    ld de, $5ab9
    jp Jump_004_47d9


jr_004_50f7:
    ld de, $5abe
    jp Jump_004_47d9


    ld a, $0a
    ld de, $5ac3
    jp Jump_004_55e3


    call Call_004_46ea
    cp $06
    jr z, jr_004_5111

    cp $02
    jr z, jr_004_5117

    ret


jr_004_5111:
    ld de, $5ac8
    jp Jump_004_47d9


jr_004_5117:
    ld de, $5acd
    jp Jump_004_47d9


    ld a, $0e
    ld de, $5ad2
    jp Jump_004_55e3


    call Call_004_46ea
    cp $0b
    jr z, jr_004_5135

    cp $08
    jr z, jr_004_513b

    cp $03
    jr z, jr_004_5141

    ret


jr_004_5135:
    ld de, $5ad2
    jp Jump_004_47d9


jr_004_513b:
    ld de, $5ad7
    jp Jump_004_47d9


jr_004_5141:
    ld de, $5adc
    jp Jump_004_47d9


    ld a, $0f
    ld de, $5ae1
    jp Jump_004_55e3


    call Call_004_46ea
    cp $0d
    jr z, jr_004_516f

    cp $0b
    jr z, jr_004_516f

    cp $09
    jr z, jr_004_5175

    cp $07
    jr z, jr_004_5175

    cp $05
    jr z, jr_004_517b

    cp $03
    jr z, jr_004_517b

    cp $01
    jr z, jr_004_5181

    ret


jr_004_516f:
    ld de, $5ae6
    jp Jump_004_47d9


jr_004_5175:
    ld de, $5aeb
    jp Jump_004_47d9


jr_004_517b:
    ld de, $5af0
    jp Jump_004_47d9


jr_004_5181:
    ld de, $5af5
    jp Jump_004_47d9


    ld a, $31
    ld de, $5afa
    jp Jump_004_55e3


    call Call_004_46ea
    cp $2d
    jr z, jr_004_51b7

    cp $25
    jr z, jr_004_51bd

    cp $1a
    jr z, jr_004_51c3

    cp $18
    jr z, jr_004_51c9

    cp $15
    jr z, jr_004_51cf

    cp $12
    jr z, jr_004_51d5

    cp $0f
    jr z, jr_004_51db

    cp $0c
    jr z, jr_004_51e1

    cp $09
    jr z, jr_004_51e7

    ret


jr_004_51b7:
    ld de, $5aff
    jp Jump_004_47d9


jr_004_51bd:
    ld de, $5b04
    jp Jump_004_47d9


jr_004_51c3:
    ld de, $5b09
    jp Jump_004_47d9


jr_004_51c9:
    ld de, $5b0e
    jp Jump_004_47d9


jr_004_51cf:
    ld de, $5b13
    jp Jump_004_47d9


jr_004_51d5:
    ld de, $5b18
    jp Jump_004_47d9


jr_004_51db:
    ld de, $5b1d
    jp Jump_004_47d9


jr_004_51e1:
    ld de, $5b22
    jp Jump_004_47d9


jr_004_51e7:
    ld de, $5b27
    jp Jump_004_47d9


    ld a, $d0
    ld [$cfd1], a
    ld a, $14
    ld de, $5b2c
    jp Jump_004_55e3


    call Call_004_46ea
    ld a, [$cfd1]
    ldh [rNR13], a
    ld [$cfd1], a
    ret


    ld a, $d0
    ld [$cfd1], a
    ld a, $14
    ld de, $5b31
    jp Jump_004_55e3


    call Call_004_46ea
    ld a, [$cfd1]
    ldh [rNR13], a
    ld [$cfd1], a
    ret


    ld a, $d0
    ld [$cfd1], a
    ld a, $14
    ld de, $5b36
    jp Jump_004_55e3


    call Call_004_46ea
    ld a, [$cfd1]
    ldh [rNR13], a
    ld [$cfd1], a
    ret


    ld a, $14
    ld de, $5b3b
    jp Jump_004_55e3


    call Call_004_46ea
    cp $0d
    jr z, jr_004_5258

    cp $0b
    jr z, jr_004_525e

    cp $08
    jr z, jr_004_5264

    cp $05
    jr z, jr_004_526a

    cp $03
    jr z, jr_004_52b0

    ret


jr_004_5258:
    ld de, $5b40
    jp Jump_004_47d9


jr_004_525e:
    ld de, $5b45
    jp Jump_004_47d9


jr_004_5264:
    ld de, $5b4a
    jp Jump_004_47d9


jr_004_526a:
    ld de, $5b4f
    jp Jump_004_47d9


    ld a, $0d
    ld de, $5b54
    jp Jump_004_55e3


    call Call_004_46ea
    cp $03
    ret nz

    ld de, $5b59
    jp Jump_004_47d9


    call Call_004_55be
    ld a, $0a
    ld de, $5b5e
    jp Jump_004_55e3


    call Call_004_46ea
    cp $01
    jp z, Jump_004_55c8

    cp $08
    jr z, jr_004_52a4

    cp $05
    jr z, jr_004_52aa

    cp $03
    jr z, jr_004_52b0

    ret


jr_004_52a4:
    ld de, $5b63
    jp Jump_004_47d9


jr_004_52aa:
    ld de, $5b68
    jp Jump_004_47d9


jr_004_52b0:
    ld de, $5b6d
    jp Jump_004_47d9


    ld a, $05
    ld de, $5b72
    jp Jump_004_55e3


    call Call_004_46ea
    cp $02
    jr z, jr_004_52c6

    ret


jr_004_52c6:
    ld de, $5b77
    jp Jump_004_47d9


    ld a, $16
    ld de, $5b7c
    jp Jump_004_55e3


    call Call_004_46ea
    cp $14
    jr z, jr_004_5300

    cp $12
    jr z, jr_004_5306

    cp $10
    jr z, jr_004_530c

    cp $0e
    jr z, jr_004_5312

    cp $0c
    jr z, jr_004_5318

    cp $0a
    jr z, jr_004_531e

    cp $08
    jr z, jr_004_5324

    cp $06
    jr z, jr_004_532a

    cp $04
    jr z, jr_004_5330

    cp $02
    jr z, jr_004_5336

    ret


jr_004_5300:
    ld de, $5b81
    jp Jump_004_47d9


jr_004_5306:
    ld de, $5b86
    jp Jump_004_47d9


jr_004_530c:
    ld de, $5b8b
    jp Jump_004_47d9


jr_004_5312:
    ld de, $5b90
    jp Jump_004_47d9


jr_004_5318:
    ld de, $5b95
    jp Jump_004_47d9


jr_004_531e:
    ld de, $5b9a
    jp Jump_004_47d9


jr_004_5324:
    ld de, $5b9f
    jp Jump_004_47d9


jr_004_532a:
    ld de, $5ba4
    jp Jump_004_47d9


jr_004_5330:
    ld de, $5ba9
    jp Jump_004_47d9


jr_004_5336:
    ld de, $5bae
    jp Jump_004_47d9


    xor a
    ld de, $5bb3
    jp Jump_004_55e3


    ld a, $02
    ld de, $5bb8
    jp Jump_004_55e3


    ld a, $0e
    ld de, $5bbd
    jp Jump_004_55e3


    call Call_004_46ea
    cp $06
    jr z, jr_004_535b

    ret


jr_004_535b:
    ld de, $5bc2
    jp Jump_004_47d9


    ld a, $04
    ld de, $5bc7
    jp Jump_004_55e3


    call Call_004_46ea
    cp $02
    jr z, jr_004_5371

    ret


jr_004_5371:
    ld de, $5bcc
    jp Jump_004_47d9


    ld a, $1d
    ld de, $5bd1
    jp Jump_004_55e3


    call Call_004_46ea
    cp $1a
    jr z, jr_004_539f

    cp $15
    jr z, jr_004_539f

    cp $11
    jr z, jr_004_53a5

    cp $0d
    jr z, jr_004_53a5

    cp $09
    jr z, jr_004_53ab

    cp $05
    jr z, jr_004_53ab

    cp $01
    jr z, jr_004_53b1

    ret


jr_004_539f:
    ld de, $5bd6
    jp Jump_004_47d9


jr_004_53a5:
    ld de, $5bdb
    jp Jump_004_47d9


jr_004_53ab:
    ld de, $5be0
    jp Jump_004_47d9


jr_004_53b1:
    ld de, $5be5
    jp Jump_004_47d9


    call Call_004_55be
    ld a, $10
    ld de, $5bea
    jp Jump_004_55e3


    call Call_004_46ea
    cp $01
    jp z, Jump_004_55c8

    cp $0d
    jr z, jr_004_53df

    cp $0a
    jr z, jr_004_53e5

    cp $08
    jr z, jr_004_53eb

    cp $05
    jr z, jr_004_53f1

    cp $02
    jr z, jr_004_53f1

    ret


jr_004_53df:
    ld de, $5bef
    jp Jump_004_47d9


jr_004_53e5:
    ld de, $5bf4
    jp Jump_004_47d9


jr_004_53eb:
    ld de, $5bf9
    jp Jump_004_47d9


jr_004_53f1:
    ld de, $5bfe
    jp Jump_004_47d9


    ld a, [$cec4]
    and a
    call nz, Call_004_5403
    ld a, $02
    ld [$cec4], a

Call_004_5403:
    cp $01
    jr z, jr_004_541d

    cp $02
    jr z, jr_004_5411

    ld a, $02
    ld [$cec4], a
    ret


jr_004_5411:
    dec a
    ld [$cec4], a
    ld a, $02
    ld de, $5c03
    jp Jump_004_55e3


jr_004_541d:
    dec a
    ld [$cec4], a
    ld a, $02
    ld de, $5c08
    jp Jump_004_55e3


    ld a, $04
    ld de, $5c0d
    jp Jump_004_55e3


    call Call_004_46ea
    cp $02
    jr z, jr_004_5439

    ret


jr_004_5439:
    ld de, $5c12
    jp Jump_004_47d9


    ld a, $16
    ld de, $5c17
    jp Jump_004_55e3


    call Call_004_46ea
    cp $14
    jr z, jr_004_5473

    cp $12
    jr z, jr_004_5479

    cp $10
    jr z, jr_004_5473

    cp $0e
    jr z, jr_004_547f

    cp $0c
    jr z, jr_004_5473

    cp $0a
    jr z, jr_004_5485

    cp $08
    jr z, jr_004_5473

    cp $06
    jr z, jr_004_548b

    cp $04
    jr z, jr_004_5473

    cp $02
    jr z, jr_004_5491

    ret


jr_004_5473:
    ld de, $5c1c
    jp Jump_004_47d9


jr_004_5479:
    ld de, $5c21
    jp Jump_004_47d9


jr_004_547f:
    ld de, $5c26
    jp Jump_004_47d9


jr_004_5485:
    ld de, $5c2b
    jp Jump_004_47d9


jr_004_548b:
    ld de, $5c30
    jp Jump_004_47d9


jr_004_5491:
    ld de, $5c35
    jp Jump_004_47d9


    ldh a, [rDIV]
    swap a
    set 7, a
    set 6, a
    set 5, a
    res 1, a
    ld [$cfd1], a
    ld a, $30
    ld de, $5c3a
    jp Jump_004_55e3


    call Call_004_46ea
    cp $20
    jr c, jr_004_54c4

    ld a, [$cfd1]
    inc a
    inc a
    inc a
    inc a
    inc a
    inc a
    ldh [rNR13], a
    ld [$cfd1], a
    ret


jr_004_54c4:
    ld a, [$cfd1]
    dec a
    ldh [rNR13], a
    ld [$cfd1], a
    ret


    ld a, $0f
    ld de, $5c3f
    jp Jump_004_55e3


    call Call_004_46ea
    cp $0a
    jr z, jr_004_54e2

    cp $03
    jr z, jr_004_54e8

    ret


jr_004_54e2:
    ld de, $5c44
    jp Jump_004_47d9


jr_004_54e8:
    ld de, $5c49
    jp Jump_004_47d9


    ld a, $90
    ld de, $5c4e
    jp Jump_004_55e3


    call Call_004_46ea
    cp $7e
    jr z, jr_004_5516

    cp $6e
    jr z, jr_004_5516

    cp $5e
    jr z, jr_004_5516

    cp $4e
    jr z, jr_004_5516

    cp $3e
    jr z, jr_004_5516

    cp $2e
    jr z, jr_004_5516

    cp $1e
    jr z, jr_004_5516

    ret


jr_004_5516:
    ld de, $5c4e
    jp Jump_004_47d9


    ld a, $0e
    ld de, $5c53
    jp Jump_004_55e3


    call Call_004_46ea
    cp $0a
    jr z, jr_004_5530

    cp $03
    jr z, jr_004_5536

    ret


jr_004_5530:
    ld de, $5c58
    jp Jump_004_47d9


jr_004_5536:
    ld de, $5c5d
    jp Jump_004_47d9


    ld a, $50
    ld de, $5c62
    jp Jump_004_55e3


    ld de, $5c62
    jp Jump_004_47d9


    ld a, $50
    ld de, $5c67
    jp Jump_004_55e3


    ld de, $5c67
    jp Jump_004_47d9


    call Call_004_46ea
    cp $40
    ret nz

    ld de, $5c67
    jp Jump_004_47d9


    ld a, $50
    ld de, $5c6c
    jp Jump_004_55e3


jr_004_556c:
    ld de, $5c6c
    jp Jump_004_47d9


    call Call_004_46ea
    cp $40
    jr z, jr_004_556c

    cp $30
    jr z, jr_004_556c

    ret


    ld a, $50
    ld de, $5c71
    jp Jump_004_55e3


jr_004_5586:
    ld de, $5c71
    jp Jump_004_47d9


    call Call_004_46ea
    cp $40
    jr z, jr_004_5586

    cp $30
    jr z, jr_004_5586

    cp $20
    jr z, jr_004_5586

    ret


    ld a, $50
    ld de, $5c76
    jp Jump_004_55e3


jr_004_55a4:
    ld de, $5c76
    jp Jump_004_47d9


    call Call_004_46ea
    cp $40
    jr z, jr_004_55a4

    cp $30
    jr z, jr_004_55a4

    cp $20
    jr z, jr_004_55a4

    cp $10
    jr z, jr_004_55a4

    ret


Call_004_55be:
    ld a, [$cec1]
    cp $03
    ret nz

    ld [$cee8], a
    ret


Jump_004_55c8:
    ld a, [$cee8]
    and a
    ret z

    ld a, [samusPose]
    cp pose_spinJump
        ret nz
    ld a, [samusItems]
    bit itemBit_screw, a
        ret z

    ld a, $03
    ld [$cec1], a
    xor a
    ld [$cee8], a
    ret


Jump_004_55e3:
    ld [$cec3], a
    ld a, [sfxRequest_square1]
    ld [$cec1], a
    ld [$cee4], a
    jp Jump_004_47d9


    ld l, c
    ld b, a
    ld l, c
    ld b, a

    db $0e, $56, $58, $56, $8b, $56, $a2, $56, $b5, $56

    ld l, c
    ld b, a
    ld l, c
    ld b, a

    db $23, $56, $69, $56, $23, $56, $23, $56, $f7, $46

    ldh a, [rDIV]
    swap a
    res 7, a
    res 6, a
    res 5, a
    ld [$cecc], a
    ld a, $30
    ld de, $5d2b
    jp Jump_004_56bd


    call Call_004_46f7
    bit 0, a
    jr z, jr_004_5644

    ld a, [$cecc]
    set 4, a
    ld [$cecc], a

jr_004_5632:
    ld a, [$ceca]
    cp $20
    jr c, jr_004_564e

    ld a, [$cecc]
    add $03
    ldh [rNR23], a
    ld [$cecc], a
    ret


jr_004_5644:
    ld a, [$cecc]
    res 4, a
    ld [$cecc], a
    jr jr_004_5632

jr_004_564e:
    ld a, [$cecc]
    dec a
    ldh [rNR23], a
    ld [$cecc], a
    ret


    ldh a, [rDIV]
    set 7, a
    res 6, a
    ld [$cecc], a
    ld a, $1c
    ld de, $5d2f
    jp Jump_004_56bd


    call Call_004_46f7
    cp $13
    jr z, jr_004_567f

    cp $0c
    jr z, jr_004_5685

    ld a, [$cecc]
    inc a
    inc a
    ld [$cecc], a
    ldh [rNR23], a
    ret


jr_004_567f:
    ld a, $a0
    ld [$cecc], a
    ret


jr_004_5685:
    ld a, $90
    ld [$cecc], a
    ret


    ldh a, [rDIV]
    swap a
    res 7, a
    set 6, a
    res 4, a
    res 2, a
    ld [$cecc], a
    ld a, $30
    ld de, $5d33
    jp Jump_004_56bd


    ldh a, [rDIV]
    swap a
    res 7, a
    set 6, a
    ld [$cecc], a
    ld a, $30
    ld de, $5d37
    jp Jump_004_56bd


    ld a, $01
    ld de, $5d3b
    jp Jump_004_56bd


Jump_004_56bd:
    ld [$ceca], a
    ld a, [sfxRequest_square2]
    ld [$cec8], a
    ld [$cee5], a
    jp Jump_004_47e1


    db $34, $57, $3c, $57, $52, $57, $5a, $57, $62, $57, $7d, $57, $a1, $57, $b1, $57
    db $c7, $57, $e2, $57, $fd, $57, $81, $58, $97, $58, $c5, $58, $0c, $59, $54, $59
    db $79, $59, $8f, $59, $97, $59, $9f, $59, $c3, $59, $d9, $59, $e6, $59, $f3, $59

    add hl, bc
    ld e, d

    db $11, $5a, $04, $47, $44, $57, $04, $47, $04, $47, $6f, $57, $85, $57, $a9, $57
    db $b9, $57, $d4, $57, $ef, $57, $05, $58, $89, $58, $9f, $58, $cd, $58, $14, $59
    db $6a, $59, $81, $59, $81, $59, $81, $59, $a7, $59, $cb, $59, $04, $47, $04, $47
    db $fb, $59

    inc b
    ld b, a

    db $04, $47

    ld a, $0d
    ld de, $5c7b
    jp Jump_004_5a19


    ld a, $19
    ld de, $5c7f
    jp Jump_004_5a19


    call Call_004_4704
    cp $0d
    jr z, jr_004_574c

    ret


jr_004_574c:
    ld de, $5c83
    jp Jump_004_47f1


    ld a, $1d
    ld de, $5c87
    jp Jump_004_5a19


    ld a, $08
    ld de, $5c8b
    jp Jump_004_5a19


    ld a, $1b
    ld [sfxRequest_square1], a
    ld a, $40
    ld de, $5c8f
    call Call_004_5a19
    call Call_004_4704
    cp $38
    jr z, jr_004_5777

    ret


jr_004_5777:
    ld de, $5c93
    jp Jump_004_47f1


    ld a, $14
    ld de, $5c97
    jp Jump_004_5a19


    call Call_004_4704
    cp $10
    jr z, jr_004_579b

    cp $0c
    jr z, jr_004_5795

    cp $08
    jr z, jr_004_579b

    ret


jr_004_5795:
    ld de, $5c97
    jp Jump_004_47f1


jr_004_579b:
    ld de, $5c9b
    jp Jump_004_47f1


    ld a, $08
    ld de, $5c9f
    jp Jump_004_5a19


    call Call_004_4704
    cp $05
    jr z, jr_004_579b

    ret


    ld a, $08
    ld de, $5ca3
    jp Jump_004_5a19


    call Call_004_4704
    cp $05
    jr z, jr_004_57c1

    ret


jr_004_57c1:
    ld de, $5ca7
    jp Jump_004_47f1


    ld a, $03
    ld [sfxRequest_square2], a
    ld a, $40
    ld de, $5cab
    jp Jump_004_5a19


    call Call_004_4704
    cp $38
    jr z, jr_004_57dc

    ret


jr_004_57dc:
    ld de, $5caf
    jp Jump_004_47f1


    ld a, $06
    ld [sfxRequest_square2], a
    ld a, $40
    ld de, $5cb3
    jp Jump_004_5a19


    call Call_004_4704
    cp $38
    jr z, jr_004_57f7

    ret


jr_004_57f7:
    ld de, $5cb7
    jp Jump_004_47f1


    ld a, $b0
    ld de, $5d27
    jp Jump_004_5a19


    call Call_004_4704
    cp $9f
    jr z, jr_004_583d

    cp $70
    jr z, jr_004_5843

    cp $6c
    jr z, jr_004_5849

    cp $68
    jr z, jr_004_584e

    cp $64
    jr z, jr_004_5853

    cp $60
    jr z, jr_004_5858

    cp $5c
    jr z, jr_004_585d

    cp $58
    jr z, jr_004_5862

    cp $54
    jr z, jr_004_5867

    cp $50
    jr z, jr_004_586c

    cp $4c
    jr z, jr_004_5871

    cp $48
    jr z, jr_004_5876

    cp $40
    jr z, jr_004_587b

    ret


jr_004_583d:
    ld de, $5cbb
    jp Jump_004_47f1


jr_004_5843:
    ld de, $5cbf
    jp Jump_004_47f1


Jump_004_5849:
jr_004_5849:
    ld a, $27
    ldh [rNR43], a
    ret


Jump_004_584e:
jr_004_584e:
    ld a, $35
    ldh [rNR43], a
    ret


Jump_004_5853:
jr_004_5853:
    ld a, $37
    ldh [rNR43], a
    ret


Jump_004_5858:
jr_004_5858:
    ld a, $45
    ldh [rNR43], a
    ret


Jump_004_585d:
jr_004_585d:
    ld a, $47
    ldh [rNR43], a
    ret


Jump_004_5862:
jr_004_5862:
    ld a, $55
    ldh [rNR43], a
    ret


Jump_004_5867:
jr_004_5867:
    ld a, $57
    ldh [rNR43], a
    ret


Jump_004_586c:
jr_004_586c:
    ld a, $65
    ldh [rNR43], a
    ret


Jump_004_5871:
jr_004_5871:
    ld a, $66
    ldh [rNR43], a
    ret


Jump_004_5876:
jr_004_5876:
    ld a, $67
    ldh [rNR43], a
    ret


jr_004_587b:
    ld de, $5cc3
    jp Jump_004_47f1


    ld a, $14
    ld de, $5cc7
    jp Jump_004_5a19


    call Call_004_4704
    cp $0c
    jr z, jr_004_5891

    ret


jr_004_5891:
    ld de, $5ccb
    jp Jump_004_47f1


    ld a, $35
    ld de, $5ccf
    jp Jump_004_5a19


    call Call_004_4704
    cp $30
    jr z, jr_004_5867

    cp $2c
    jr z, jr_004_584e

    cp $27
    jr z, jr_004_5853

    cp $23
    jr z, jr_004_5862

    cp $20
    jr z, jr_004_585d

    cp $1d
    jr z, jr_004_5858

    cp $1a
    jr z, jr_004_58bf

    ret


jr_004_58bf:
    ld de, $5cd3
    jp Jump_004_47f1


    ld a, $4f
    ld de, $5cd7
    jp Jump_004_5a19


    call Call_004_4704
    cp $4d
    jr z, jr_004_586c

    cp $4a
    jp z, Jump_004_5867

    cp $47
    jp z, Jump_004_5862

    cp $44
    jp z, Jump_004_585d

    cp $41
    jp z, Jump_004_586c

    cp $3e
    jp z, Jump_004_5867

    cp $3b
    jp z, Jump_004_5862

    cp $39
    jp z, Jump_004_585d

    cp $36
    jp z, Jump_004_5858

    cp $33
    jp z, Jump_004_5853

    cp $30
    jr z, jr_004_5906

    ret


jr_004_5906:
    ld de, $5cdb
    jp Jump_004_47f1


    ld a, $70
    ld de, $5cdf
    jp Jump_004_5a19


    call Call_004_4704
    cp $6d
    jp z, Jump_004_5876

    cp $6a
    jp z, Jump_004_5871

    cp $67
    jp z, Jump_004_586c

    cp $64
    jp z, Jump_004_5867

    cp $61
    jp z, Jump_004_5862

    cp $5e
    jp z, Jump_004_585d

    cp $5b
    jp z, Jump_004_5858

    cp $59
    jp z, Jump_004_5853

    cp $56
    jp z, Jump_004_584e

    cp $53
    jp z, Jump_004_5849

    cp $50
    jr z, jr_004_594e

    ret


jr_004_594e:
    ld de, $5ce3
    jp Jump_004_47f1


    ld a, [$ced6]
    and a
    jp nz, Jump_004_44fd

    ld a, [$cf07]
    and a
    jp nz, Jump_004_44fd

    ld a, $02
    ld de, $5ce7
    jp Jump_004_5a19


    call Call_004_4704
    cp $01
    jp z, Jump_004_5973

    ret


Jump_004_5973:
    ld de, $5ceb
    jp Jump_004_47f1


    ld a, $10
    ld de, $5cef
    jp Jump_004_5a19


    call Call_004_4704
    cp $0c
    jr z, jr_004_5989

    ret


jr_004_5989:
    ld de, $5cf3
    jp Jump_004_47f1


    ld a, $10
    ld de, $5cf7
    jp Jump_004_5a19


    ld a, $10
    ld de, $5cfb
    jp Jump_004_5a19


    ld a, $18
    ld de, $5cff
    jp Jump_004_5a19


    call Call_004_4704
    cp $10
    jr z, jr_004_59b7

    cp $0c
    jr z, jr_004_59bd

    cp $08
    jr z, jr_004_59b7

    ret


jr_004_59b7:
    ld de, $5d03
    jp Jump_004_47f1


jr_004_59bd:
    ld de, $5cff
    jp Jump_004_47f1


    ld a, $30
    ld de, $5d07
    jp Jump_004_5a19


    call Call_004_4704
    cp $20
    jr z, jr_004_59d3

    ret


jr_004_59d3:
    ld de, $5d0b
    jp Jump_004_47f1


    ld a, $04
    ld [sfxRequest_square2], a
    ld a, $08
    ld de, $5d0f
    jp Jump_004_5a19


    ld a, $05
    ld [sfxRequest_square2], a
    ld a, $40
    ld de, $5d13
    jp Jump_004_5a19


    ld a, $0f
    ld de, $5d17
    jp Jump_004_5a19


    call Call_004_4704
    cp $0c
    jr z, jr_004_5a03

    ret


jr_004_5a03:
    ld de, $5d1b
    jp Jump_004_47f1


    ld a, $10
    ld de, $5d1f
    jp Jump_004_5a19


    ld a, $10
    ld de, $5d23
    jp Jump_004_5a19


Call_004_5a19:
Jump_004_5a19:
    ld [$ced8], a
    ld a, [sfxRequest_noise]
    ld [$ced6], a
    ld [$cee7], a
    jp Jump_004_47f1


    db $15, $00, $a7, $90, $86, $26, $80, $83, $c0, $85, $15, $00, $47, $90, $86, $26
    db $80, $37, $c0, $85, $15, $00, $27, $90, $86, $26, $80, $27, $c0, $85, $15, $00
    db $a7, $90, $86, $26, $80, $73, $c0, $86, $15, $00, $37, $90, $86, $26, $80, $37
    db $c0, $86, $15, $00, $27, $90, $86, $26, $80, $27, $c0, $86, $15, $00, $17, $90
    db $86, $26, $80, $17, $c0, $86, $15, $00, $77, $00, $87, $15, $00, $b7, $60, $85
    db $15, $00, $f7, $c0, $85, $15, $00, $f7, $00, $86, $15, $40, $f7, $40, $86, $15
    db $40, $e7, $70, $86, $15, $80, $d7, $90, $86, $15, $80, $c7, $b0, $86, $15, $80
    db $a7, $c0, $86, $15, $40, $87, $c0, $86, $15, $40, $87, $d0, $86, $15, $40, $47
    db $e0, $86, $15, $40, $57, $f0, $86, $15, $40, $57, $00, $87, $14, $b6, $91, $a0
    db $c4, $14, $b6, $71, $a0, $c4, $14, $b6, $51, $a0, $c4, $14, $66, $91, $a0, $c4
    db $14, $66, $61, $a0, $c4, $14, $66, $41, $a0, $c4, $14, $80, $a7, $00, $87, $3d
    db $80, $c1, $50, $87, $3d, $80, $61, $50, $87, $15, $00, $f7, $d0, $86, $15, $80
    db $95, $80, $86, $15, $80, $95, $c0, $86, $15, $80, $85, $00, $87, $15, $80, $75
    db $80, $87, $15, $40, $f7, $90, $86, $15, $00, $f7, $a0, $85, $1d, $00, $55, $a0
    db $87, $15, $00, $67, $00, $86, $15, $00, $a7, $20, $86, $15, $00, $97, $40, $86
    db $15, $00, $87, $60, $86, $15, $00, $67, $80, $86, $15, $00, $47, $a0, $86, $15
    db $00, $37, $c0, $86, $1f, $80, $77, $d0, $87, $17, $00, $a7, $00, $86, $1f, $00
    db $c7, $d0, $87, $35, $80, $87, $a0, $86, $34, $80, $c7, $10, $87, $34, $80, $b7
    db $40, $87, $34, $80, $97, $60, $87, $34, $80, $67, $80, $87, $2a, $00, $f7, $00
    db $86, $15, $80, $57, $00, $86, $39, $80, $e7, $40, $87, $44, $80, $d7, $f0, $86
    db $44, $80, $97, $f0, $86, $44, $80, $37, $f0, $86, $44, $80, $c1, $00, $87, $00
    db $80, $41, $d0, $87, $15, $80, $a7, $a0, $85, $15, $80, $a7, $c0, $85, $15, $80
    db $a7, $f0, $85, $15, $80, $a7, $10, $86, $15, $80, $a7, $40, $86, $15, $80, $a7
    db $70, $86, $15, $80, $a7, $90, $86, $15, $80, $a7, $a0, $86, $15, $80, $a7, $c0
    db $86, $15, $80, $a7, $e0, $86, $15, $80, $a7, $00, $87

    nop
    nop
    ld [$8000], sp

    db $1e, $40, $57, $c0, $87

    dec d
    nop
    rst $00
    nop
    add h
    dec e
    nop
    rst $00
    ret nc

    add a

    db $14, $00, $c7, $00, $87, $14, $80, $c7, $40, $86, $16, $40, $f7, $d0, $86, $16
    db $40, $c7, $80, $86, $16, $40, $a7, $c0, $86, $16, $40, $87, $00, $87, $17, $40
    db $c7, $a0, $87, $39, $80, $f7, $40, $87, $44, $80, $e7, $10, $87, $44, $80, $c7
    db $10, $87, $44, $80, $a7, $10, $87, $44, $80, $37, $10, $87, $16, $bd, $55, $50
    db $87, $00, $bd, $55, $a0, $87

    inc d
    nop
    rst $00
    and b
    add [hl]
    dec d
    nop
    rst $00
    and b
    add [hl]

    db $1d, $00, $f1, $c0, $87, $39, $00, $f1, $d0, $87, $1d, $00, $e1, $c4, $87, $1d
    db $00, $d1, $cc, $87, $1d, $00, $e1, $d0, $87, $1d, $00, $d1, $d8, $87, $1d, $38
    db $e1, $dc, $c7, $4f, $00, $f6, $f0, $87, $5c, $80, $c7, $80, $87, $45, $80, $87
    db $82, $87, $45, $80, $57, $82, $87, $34, $80, $a5, $00, $82, $43, $80, $f7, $00
    db $87, $45, $80, $f7, $a2, $87, $45, $80, $57, $a2, $87

    ld [hl], a
    add b
    pop af
    nop
    add [hl]
    ld [hl], a
    add b
    pop af
    and b
    add [hl]
    ld [hl], a
    add b
    pop af
    nop
    add a
    ld [hl], a
    add b
    pop af
    ld b, b
    add a
    ld [hl], a
    add b
    pop af
    sub b
    add a

    db $00, $09, $62, $80, $00, $19, $33, $80, $00, $f1, $4e, $80, $00, $f2, $6c, $80
    db $00, $19, $4d, $80, $00, $09, $3d, $80, $00, $f4, $45, $80, $00, $f7, $4a, $80
    db $00, $45, $4a, $80, $00, $f7, $4a, $80, $00, $f7, $33, $80, $00, $f1, $5c, $80
    db $00, $e2, $4e, $80, $00, $c6, $45, $80, $00, $f2, $5a, $80, $00, $f4, $44, $80
    db $00, $0d, $24, $80, $00, $f0, $15, $80, $00, $87, $74, $80, $00, $a7, $43, $80
    db $00, $f1, $64, $80, $00, $f7, $64, $80, $00, $a3, $22, $80, $00, $f7, $22, $80
    db $00, $a5, $33, $80, $00, $f0, $43, $80, $00, $f6, $65, $80, $3d, $37, $2a, $c0
    db $3c, $15, $2a, $c0, $00, $73, $27, $80, $00, $97, $77, $80, $00, $87, $44, $80
    db $00, $87, $33, $80, $00, $91, $3c, $80, $00, $91, $4b, $80, $00, $a7, $55, $80
    db $00, $c3, $53, $80, $00, $1b, $31, $80, $00, $a7, $7d, $80, $00, $61, $2f, $80
    db $00, $60, $21, $80

    nop
    jp $8011


    db $00, $44, $4a, $80, $00, $08, $00, $80, $00, $f4, $00, $87, $00, $97, $90, $87
    db $40, $57, $00, $87, $40, $f7, $00, $87, $00, $87, $00, $82, $53, $5d, $53, $5d
    db $be, $5d, $29, $5e, $94, $5e, $69, $5d, $69, $5d, $d4, $5d, $3f, $5e, $aa, $5e

    xor a
    ldh [rNR30], a
    ld de, $418b
    call Call_004_47c9
    ld a, $0c
    ld [$cfee], a
    ld a, $0e
    ld de, $5eff
    jp Jump_004_5f27


    ld a, $01
    ld [$cee6], a
    ld a, [$cfe8]
    dec a
    ld [$cfe8], a
    cp $0a
    jr z, jr_004_5d7d

    and a
    jr z, jr_004_5d9e

    ret


jr_004_5d7d:
    ld a, [$cfee]
    and a
    jr z, jr_004_5d8f

    dec a
    ld [$cfee], a
    ld de, $418b
    call Call_004_47c9
    jr jr_004_5d98

jr_004_5d8f:
    xor a
    ldh [rNR30], a
    ld de, $419b
    call Call_004_47c9

jr_004_5d98:
    ld de, $5f04
    jp Jump_004_47e9


jr_004_5d9e:
    ld a, [$cfee]
    and a
    jr z, jr_004_5dac

    ld de, $418b
    call Call_004_47c9
    jr jr_004_5db2

jr_004_5dac:
    ld de, $419b
    call Call_004_47c9

jr_004_5db2:
    ld a, [$cfe9]
    ld [$cfe8], a
    ld de, $5eff
    jp Jump_004_47e9


    xor a
    ldh [rNR30], a
    ld de, $418b
    call Call_004_47c9
    ld a, $06
    ld [$cfee], a
    ld a, $13
    ld de, $5f09
    jp Jump_004_5f27


    ld a, $02
    ld [$cee6], a
    ld a, [$cfe8]
    dec a
    ld [$cfe8], a
    cp $09
    jr z, jr_004_5de8

    and a
    jr z, jr_004_5e09

    ret


jr_004_5de8:
    ld a, [$cfee]
    and a
    jr z, jr_004_5dfa

    dec a
    ld [$cfee], a
    ld de, $418b
    call Call_004_47c9
    jr jr_004_5e03

jr_004_5dfa:
    xor a
    ldh [rNR30], a
    ld de, $419b
    call Call_004_47c9

jr_004_5e03:
    ld de, $5f0e
    jp Jump_004_47e9


jr_004_5e09:
    ld a, [$cfee]
    and a
    jr z, jr_004_5e17

    ld de, $418b
    call Call_004_47c9
    jr jr_004_5e1d

jr_004_5e17:
    ld de, $419b
    call Call_004_47c9

jr_004_5e1d:
    ld a, [$cfe9]
    ld [$cfe8], a
    ld de, $5f09
    jp Jump_004_47e9


    xor a
    ldh [rNR30], a
    ld de, $418b
    call Call_004_47c9
    ld a, $06
    ld [$cfee], a
    ld a, $16
    ld de, $5f13
    jp Jump_004_5f27


    ld a, $03
    ld [$cee6], a
    ld a, [$cfe8]
    dec a
    ld [$cfe8], a
    cp $09
    jr z, jr_004_5e53

    and a
    jr z, jr_004_5e74

    ret


jr_004_5e53:
    ld a, [$cfee]
    and a
    jr z, jr_004_5e65

    dec a
    ld [$cfee], a
    ld de, $418b
    call Call_004_47c9
    jr jr_004_5e6e

jr_004_5e65:
    xor a
    ldh [rNR30], a
    ld de, $419b
    call Call_004_47c9

jr_004_5e6e:
    ld de, $5f18
    jp Jump_004_47e9


jr_004_5e74:
    ld a, [$cfee]
    and a
    jr z, jr_004_5e82

    ld de, $418b
    call Call_004_47c9
    jr jr_004_5e88

jr_004_5e82:
    ld de, $419b
    call Call_004_47c9

jr_004_5e88:
    ld a, [$cfe9]
    ld [$cfe8], a
    ld de, $5f13
    jp Jump_004_47e9


    xor a
    ldh [rNR30], a
    ld de, $418b
    call Call_004_47c9
    ld a, $06
    ld [$cfee], a
    ld a, $18
    ld de, $5f1d
    jp Jump_004_5f27


    ld a, $04
    ld [$cee6], a
    ld a, [$cfe8]
    dec a
    ld [$cfe8], a
    cp $0b
    jr z, jr_004_5ebe

    and a
    jr z, jr_004_5edf

    ret


jr_004_5ebe:
    ld a, [$cfee]
    and a
    jr z, jr_004_5ed0

    dec a
    ld [$cfee], a
    ld de, $418b
    call Call_004_47c9
    jr jr_004_5ed9

jr_004_5ed0:
    xor a
    ldh [rNR30], a
    ld de, $419b
    call Call_004_47c9

jr_004_5ed9:
    ld de, $5f22
    jp Jump_004_47e9


jr_004_5edf:
    ld a, [$cfee]
    and a
    jr z, jr_004_5eed

    ld de, $418b
    call Call_004_47c9
    jr jr_004_5ef3

jr_004_5eed:
    ld de, $419b
    call Call_004_47c9

jr_004_5ef3:
    ld a, [$cfe9]
    ld [$cfe8], a
    ld de, $5f1d
    jp Jump_004_47e9


    db $80, $00, $20, $f0, $84, $80, $00, $40, $d0, $84, $80, $00, $20, $c4, $84

    add b
    nop
    ld b, b
    db $c4
    add h

    db $80, $00, $20, $b6, $84

    add b
    nop
    ld b, b
    or [hl]
    add h

    db $80, $00, $20, $a3, $84, $80, $00, $40, $a3, $84

Jump_004_5f27:
    ld [$cfe8], a
    ld [$cfe9], a
    jp Jump_004_47e9


    db $90, $5f, $8a, $60, $d4, $61, $ed, $64, $5f, $68, $ee, $68, $88, $69, $e2, $6a
    db $c3, $6b, $8e, $6c, $51, $6d, $8b, $6d, $d5, $6e, $50, $6f, $a4, $6f

    ld l, c
    ld b, a

    db $3c, $70, $27, $74, $8a, $74, $d4, $61, $3a, $7c, $45, $7c, $50, $7c, $5b, $7c
    db $e2, $6a

    jp $8e6b


    ld l, h
    ld d, c
    ld l, l
    adc e
    ld l, l

    db $66, $7c, $71, $7c, $09, $7d, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $db
    db $ff, $ff, $ff, $de, $de

    rst $38

    db $ff, $de, $ff, $ff, $ff, $ff, $ff, $ff, $ff

    rst $38
    db $db
    rst $38
    rst $38

    db $ff, $ff, $de, $01, $06, $41, $9b, $5f, $b3, $5f, $cb, $5f, $db, $5f, $1a, $7e
    db $1a, $7e, $09, $7e, $42, $7d, $e7, $5f, $47, $7d, $f2, $5f, $4c, $7d, $02, $60
    db $0a, $60, $f0, $00, $ad, $5f, $1a, $7e, $1a, $7e, $09, $7e, $42, $7d, $25, $60
    db $47, $7d, $30, $60, $4c, $7d, $3e, $60, $46, $60, $f0, $00, $c5, $5f, $21, $7e
    db $21, $7e, $10, $7e, $5b, $7d, $60, $60, $5c, $60, $f0, $00, $d5, $5f, $28, $7e
    db $28, $7e, $17, $7e, $84, $60, $f0, $00, $db, $5f, $f4, $02, $a2, $32, $3c, $40
    db $46, $a3, $38, $f5, $00, $f4, $02, $a2, $32, $3c, $40, $46, $a3, $38, $f5, $a2
    db $32, $3c, $40, $46, $00, $f4, $03, $32, $3c, $40, $46, $f5, $00, $f1, $77, $00
    db $80, $f4, $04, $a2, $32, $3c, $40, $46, $a3, $38, $f5, $a2, $32, $3c, $40, $46
    db $f4, $03, $32, $3c, $40, $46, $f5, $00, $f4, $03, $a6, $32, $3c, $40, $46, $38
    db $3c, $f5, $00, $32, $3c, $40, $46, $38, $3c, $f4, $02, $32, $3c, $40, $46, $f5
    db $00, $f4, $02, $32, $3c, $40, $46, $f5, $00, $f1, $77, $00, $80, $f4, $04, $a6
    db $32, $3c, $40, $46, $38, $3c, $f5, $f4, $04, $32, $3c, $40, $46, $f5, $00, $f1
    db $13, $41, $60, $f4, $04, $a1, $4a, $03, $54, $03, $58, $03, $5e, $03, $a2, $50
    db $03, $f5, $a1, $4a, $03, $54, $03, $58, $03, $5e, $03, $f4, $03, $4a, $03, $54
    db $03, $58, $03, $5e, $03, $f5, $00, $a3, $74, $78, $a0, $01, $00, $01, $06, $41
    db $95, $60, $e9, $60, $f3, $60, $fd, $60, $07, $61, $12, $61, $86, $7d, $12, $61
    db $82, $7d, $12, $61, $7e, $7d, $12, $61, $7a, $7d, $12, $61, $76, $7d, $91, $7d
    db $12, $61, $72, $7d, $94, $7d, $12, $61, $6e, $7d, $97, $7d, $12, $61, $6a, $7d
    db $9a, $7d, $12, $61, $6a, $7d, $9d, $7d, $12, $61, $6a, $7d, $9a, $7d, $0c, $61
    db $6e, $7d, $97, $7d, $0c, $61, $72, $7d, $94, $7d, $0c, $61, $76, $7d, $91, $7d
    db $0c, $61, $7e, $7d, $8e, $7d, $18, $61, $f0, $00, $e3, $60, $22, $61, $2f, $61
    db $3c, $61, $f0, $00, $ed, $60, $46, $61, $53, $61, $60, $61, $f0, $00, $f7, $60
    db $ba, $61, $c3, $61, $cc, $61, $f0, $00, $01, $61, $f1, $c7, $00, $00, $00, $a3
    db $22, $2e, $1a, $28, $00, $a7, $22, $2e, $1a, $28, $00, $f1, $87, $00, $00, $a4
    db $22, $2e, $1a, $28, $00, $f1, $c7, $00, $00, $f4, $0a, $a7, $2c, $38, $24, $32
    db $f5, $00, $f1, $a7, $00, $00, $f4, $04, $a3, $2c, $38, $24, $32, $f5, $00, $f1
    db $87, $00, $00, $a4, $2c, $38, $24, $32, $00, $f1, $6b, $41, $40, $f4, $0a, $a7
    db $14, $20, $0c, $1a, $f5, $00, $f1, $6b, $41, $40, $f4, $04, $a3, $2c, $38, $24
    db $32, $f5, $00, $a3, $4a, $03, $50, $03, $4a, $03, $48, $03, $3e, $03, $40, $a1
    db $52, $03, $50, $03, $4c, $03, $4a, $03, $4c, $03, $50, $03, $52, $03, $50, $03
    db $4c, $03, $4a, $03, $4c, $03, $50, $03, $a2, $52, $03, $42, $03, $4a, $03, $a6
    db $48, $03, $3c, $03, $a2, $3e, $03, $4a, $03, $48, $03, $a7, $54, $a3, $03, $a0
    db $02, $04, $08, $0a, $10, $12, $16, $18, $1a, $1c, $20, $22, $28, $2a, $2e, $30
    db $30, $2e, $2a, $28, $22, $20, $1c, $1a, $10, $0a, $18, $16, $00, $f4, $0a, $a7
    db $a0, $01, $a4, $01, $f5, $00, $f4, $04, $a3, $24, $01, $34, $01, $f5, $00, $a2
    db $1c, $a4, $a0, $a6, $01, $68, $00, $01, $df, $40, $df, $61, $f5, $61, $07, $62
    db $00, $00, $19, $62, $4c, $62, $64, $62, $97, $62, $19, $62, $9d, $62, $4c, $62
    db $64, $62, $a3, $62, $f0, $00, $df, $61, $f6, $62, $28, $63, $49, $63, $f6, $62
    db $28, $63, $49, $63, $7a, $63, $f0, $00, $f5, $61, $df, $63, $12, $64, $35, $64
    db $df, $63, $12, $64, $35, $64, $67, $64, $f0, $00, $07, $62, $f1, $50, $00, $80
    db $a3, $01, $a2, $32, $05, $30, $05, $2e, $05, $a3, $26, $05, $28, $05, $a2, $28
    db $05, $26, $05, $20, $05, $a1, $30, $05, $32, $05, $48, $05, $4a, $05, $18, $05
    db $1a, $05, $a3, $30, $05, $a1, $32, $05, $38, $05, $3a, $05, $01, $01, $00, $a2
    db $20, $05, $26, $05, $a7, $2c, $26, $a3, $1a, $a2, $1c, $01, $f4, $02, $a1, $18
    db $1a, $18, $1a, $f5, $a4, $01, $00, $a3, $3a, $03, $a1, $32, $03, $34, $03, $a2
    db $2c, $03, $3a, $03, $a1, $32, $03, $48, $03, $a2, $24, $03, $30, $03, $a1, $28
    db $03, $2e, $03, $30, $03, $26, $03, $a2, $24, $03, $2c, $03, $28, $03, $a6, $26
    db $03, $a3, $22, $03, $a7, $1e, $05, $a5, $01, $00, $f3, $fe, $f2, $ec, $40, $00
    db $f3, $00, $f2, $df, $40, $00, $f1, $62, $00, $40, $f4, $02, $a1, $0c, $16, $0c
    db $16, $10, $18, $10, $18, $0c, $14, $0c, $14, $10, $08, $10, $08, $10, $08, $0c
    db $04, $0c, $04, $0c, $04, $f5, $f1, $62, $00, $00, $a1, $3c, $46, $3c, $46, $40
    db $48, $40, $48, $3c, $44, $3c, $44, $40, $38, $40, $38, $40, $38, $3c, $34, $3c
    db $34, $3c, $34, $3a, $2e, $36, $2a, $30, $24, $2c, $20, $1a, $18, $12, $02, $f1
    db $87, $00, $40, $a5, $62, $01, $a3, $01, $00, $f1, $50, $00, $80, $a2, $30, $32
    db $40, $05, $38, $05, $3a, $05, $a3, $30, $05, $32, $05, $a2, $28, $05, $26, $05
    db $20, $05, $a1, $30, $05, $32, $05, $48, $05, $4a, $05, $18, $05, $1a, $05, $a3
    db $30, $05, $a1, $32, $05, $38, $05, $3a, $a6, $05, $00, $a2, $32, $05, $36, $05
    db $a1, $3c, $05, $3a, $05, $32, $05, $a2, $36, $05, $01, $26, $05, $28, $05, $01
    db $a1, $26, $05, $20, $05, $22, $03, $a2, $1a, $a7, $05, $00, $a2, $40, $a7, $05
    db $a1, $38, $05, $3a, $05, $a2, $32, $05, $a2, $40, $05, $a1, $38, $05, $3a, $05
    db $a2, $32, $05, $28, $05, $a2, $2e, $05, $a4, $01, $a2, $2c, $05, $28, $05, $a2
    db $2e, $a3, $05, $a2, $2a, $a7, $05, $a7, $2c, $05, $a5, $01, $00, $f1, $62, $00
    db $80, $a1, $0c, $16, $0c, $16, $10, $18, $10, $18, $0c, $14, $0c, $14, $10, $08
    db $10, $08, $10, $08, $0c, $04, $0c, $04, $0c, $04, $a1, $2c, $32, $2c, $32, $30
    db $38, $30, $38, $2c, $34, $2c, $34, $30, $2c, $30, $2c, $1a, $3c, $40, $46, $4a
    db $4e, $54, $58, $a1, $2c, $32, $2c, $32, $30, $38, $30, $38, $2c, $34, $2c, $34
    db $30, $2c, $30, $2c, $34, $32, $3c, $46, $40, $32, $2a, $1e, $1c, $1a, $18, $16
    db $14, $12, $10, $0e, $0c, $0a, $08, $0a, $f1, $87, $00, $40, $a5, $62, $01, $a3
    db $01, $00, $f1, $7b, $41, $40, $a3, $01, $a2, $32, $03, $30, $03, $2e, $03, $a3
    db $26, $03, $28, $03, $a2, $28, $03, $26, $03, $20, $03, $a1, $30, $03, $32, $03
    db $48, $03, $4a, $03, $18, $03, $1a, $03, $a3, $30, $03, $a1, $32, $03, $38, $03
    db $3a, $03, $01, $01, $00, $a2, $32, $03, $36, $03, $a1, $3c, $03, $3a, $03, $32
    db $03, $a3, $36, $a2, $03, $26, $03, $a3, $28, $a2, $03, $a1, $26, $03, $20, $03
    db $22, $03, $a2, $1a, $03, $a3, $01, $00, $a3, $40, $a2, $03, $01, $a1, $38, $03
    db $3a, $03, $a2, $32, $a1, $03, $01, $a2, $40, $03, $a1, $38, $03, $3a, $03, $a2
    db $32, $03, $28, $03, $a7, $2e, $03, $a2, $2c, $03, $28, $03, $a6, $2e, $03, $a3
    db $2a, $03, $a3, $2c, $03, $a5, $01, $a3, $01, $00, $a8, $01, $01, $a0, $2c, $03
    db $32, $03, $2c, $03, $32, $03, $30, $03, $38, $03, $30, $03, $38, $03, $2c, $03
    db $34, $03, $2c, $03, $34, $03, $30, $03, $2c, $03, $30, $03, $2c, $03, $1a, $03
    db $3c, $03, $40, $03, $46, $03, $4a, $03, $4e, $03, $54, $03, $58, $03, $a0, $2c
    db $03, $32, $03, $2c, $03, $32, $03, $30, $03, $38, $03, $30, $03, $38, $03, $2c
    db $03, $34, $03, $2c, $03, $34, $03, $30, $03, $2c, $03, $30, $03, $2c, $03, $34
    db $03, $32, $03, $3c, $03, $46, $03, $40, $03, $32, $03, $2a, $03, $1e, $03, $1c
    db $03, $1a, $03, $18, $03, $16, $03, $14, $03, $12, $03, $10, $03, $0e, $03, $0c
    db $03, $0a, $03, $08, $03, $0a, $03, $a6, $62, $03, $a7, $01, $a8, $01, $01, $00
    db $00, $c5, $40, $f8, $64, $1c, $65, $28, $65, $34, $65, $42, $65, $72, $66, $9c
    db $65, $9c, $65, $eb, $65, $eb, $65, $eb, $65, $eb, $65, $50, $65, $9c, $65, $9c
    db $65, $00, $66, $00, $66, $00, $66, $00, $66, $50, $65, $f0, $00, $fc, $64, $15
    db $66, $23, $66, $31, $66, $72, $66, $f0, $00, $20, $65, $9e, $66, $ac, $66, $db
    db $66, $6a, $67, $f0, $00, $2a, $65, $c3, $67, $c9, $67, $ed, $67, $03, $68, $28
    db $68, $f0, $00, $36, $65, $f1, $55, $00, $40, $a1, $1a, $24, $44, $46, $4a, $50
    db $6c, $74, $00, $f1, $26, $00, $40, $a2, $4a, $54, $4a, $4a, $a3, $54, $a2, $4a
    db $54, $4a, $54, $4a, $4a, $a3, $54, $a2, $4a, $4a, $46, $50, $46, $46, $a3, $50
    db $a2, $46, $50, $46, $50, $46, $46, $a2, $50, $46, $50, $50, $4a, $54, $4a, $4a
    db $a3, $54, $a2, $4a, $54, $4a, $54, $4a, $4a, $a3, $54, $a2, $4a, $4a, $46, $50
    db $46, $46, $a3, $46, $16, $a2, $24, $2e, $32, $38, $24, $2e, $32, $38, $00, $f1
    db $71, $00, $40, $f4, $03, $a2, $1a, $24, $1a, $1a, $a3, $24, $a2, $1a, $24, $1a
    db $24, $1a, $1a, $a3, $24, $a2, $1a, $1a, $16, $20, $16, $16, $a3, $20, $a2, $16
    db $20, $16, $20, $16, $16, $20, $16, $20, $20, $f5, $a2, $1a, $24, $1a, $1a, $a3
    db $24, $a2, $1a, $24, $1a, $24, $1a, $1a, $a3, $24, $a2, $24, $1a, $16, $20, $16
    db $16, $a3, $16, $16, $a2, $24, $2e, $32, $38, $24, $2e, $32, $38, $00, $f1, $63
    db $00, $40, $f4, $04, $a2, $1a, $24, $2c, $2e, $f5, $f4, $04, $a2, $16, $20, $24
    db $2e, $f5, $00, $f1, $0a, $00, $00, $f4, $04, $a2, $4a, $54, $5c, $5e, $f5, $f4
    db $04, $a2, $46, $50, $5c, $5e, $f5, $00, $f1, $75, $00, $40, $a1, $1a, $24, $2c
    db $2e, $32, $38, $3c, $44, $00, $f1, $0f, $00, $00, $a5, $24, $03, $20, $03, $3c
    db $03, $38, $03, $00, $f1, $73, $00, $40, $f4, $08, $a3, $0c, $03, $0c, $03, $0c
    db $03, $0c, $03, $08, $03, $08, $03, $08, $03, $08, $03, $f5, $f1, $22, $6c, $80
    db $f4, $08, $a1, $62, $60, $4e, $58, $52, $5c, $60, $54, $5c, $5c, $60, $60, $4a
    db $4a, $5c, $5c, $52, $52, $5c, $5c, $54, $54, $5c, $5c, $52, $52, $4a, $4a, $5c
    db $5c, $52, $52, $f5, $00, $f1, $47, $00, $40, $a4, $24, $a7, $1a, $1a, $a3, $1a
    db $24, $1a, $a4, $20, $a7, $16, $16, $a3, $16, $20, $16, $a4, $24, $a7, $1a, $1a
    db $a3, $1a, $24, $1a, $a4, $20, $a7, $16, $a2, $16, $0c, $16, $1a, $20, $a4, $0c
    db $00, $f1, $7b, $41, $40, $a1, $02, $0c, $14, $16, $1a, $20, $24, $2c, $00, $f1
    db $7b, $41, $40, $a3, $32, $a2, $03, $32, $a3, $03, $a5, $01, $a3, $01, $2e, $a2
    db $03, $2e, $a3, $03, $a5, $01, $a3, $01, $32, $a2, $03, $32, $a3, $03, $a5, $01
    db $a3, $01, $2e, $a2, $03, $2e, $a3, $03, $a8, $01, $a3, $1a, $03, $00, $f1, $7b
    db $41, $40, $a6, $32, $03, $3c, $03, $a3, $40, $03, $46, $03, $01, $a6, $44, $03
    db $3c, $03, $a3, $40, $03, $38, $03, $01, $a6, $32, $03, $3c, $03, $a3, $40, $03
    db $46, $03, $01, $a6, $44, $03, $46, $03, $a7, $4a, $03, $a3, $40, $03, $a6, $32
    db $03, $3c, $03, $a3, $40, $03, $46, $03, $01, $a6, $44, $03, $3c, $03, $a3, $40
    db $03, $01, $01, $01, $a6, $32, $03, $3c, $03, $a3, $40, $03, $46, $03, $01, $a6
    db $44, $03, $46, $03, $a3, $4a, $03, $50, $03, $a2, $4e, $03, $f4, $02, $a6, $4a
    db $03, $46, $03, $a3, $44, $03, $a7, $3c, $03, $a6, $38, $03, $40, $03, $a7, $46
    db $03, $a3, $44, $03, $a6, $4a, $03, $46, $03, $a3, $44, $03, $54, $03, $a2, $50
    db $03, $a6, $4e, $03, $46, $03, $a7, $4a, $03, $a4, $01, $f5, $00, $f1, $7b, $41
    db $40, $a7, $24, $03, $2e, $03, $a3, $32, $03, $a7, $38, $03, $36, $03, $a3, $2e
    db $03, $a7, $24, $03, $32, $03, $a3, $36, $03, $a7, $38, $03, $3c, $03, $a3, $40
    db $03, $a7, $24, $03, $2c, $03, $a3, $2e, $03, $a7, $32, $03, $36, $03, $a3, $38
    db $03, $3c, $03, $44, $03, $a2, $46, $03, $a3, $4a, $03, $50, $03, $a2, $54, $03
    db $5c, $03, $5e, $03, $a1, $62, $03, $68, $03, $6c, $03, $76, $03, $62, $03, $68
    db $03, $6c, $03, $74, $03, $00, $f4, $08, $a1, $10, $f5, $00, $f4, $03, $a2, $90
    db $0c, $04, $94, $04, $04, $0c, $04, $04, $04, $0c, $04, $90, $0c, $04, $0c, $f5
    db $a2, $90, $04, $0c, $90, $04, $04, $0c, $04, $14, $10, $14, $10, $a4, $1c, $00
    db $f4, $0f, $a2, $90, $04, $0c, $04, $90, $04, $0c, $04, $f5, $a2, $14, $10, $10
    db $10, $14, $10, $14, $10, $00, $f4, $07, $a2, $90, $0c, $04, $94, $14, $04, $0c
    db $04, $90, $0c, $04, $0c, $94, $0c, $04, $04, $f5, $90, $0c, $08, $94, $90, $0c
    db $08, $04, $14, $10, $10, $10, $14, $10, $14, $10, $00, $f4, $04, $a2, $14, $0c
    db $14, $04, $08, $0c, $08, $04, $04, $0c, $08, $04, $08, $a3, $68, $a2, $0c, $f5
    db $f4, $03, $a2, $10, $10, $04, $10, $14, $0c, $08, $04, $90, $0c, $08, $04, $90
    db $a3, $68, $a2, $0c, $f5, $90, $0c, $90, $04, $08, $0c, $08, $04, $f4, $08, $14
    db $f5, $00, $00, $c5, $40, $6a, $68, $74, $68, $78, $68, $7c, $68, $a0, $7d, $86
    db $7d, $80, $68, $f0, $00, $6e, $68, $ca, $7d, $00, $00, $f4, $7d, $00, $00, $04
    db $7e, $00, $00, $f1, $37, $35, $80, $a1, $58, $a1, $5a, $5c, $5e, $60, $62, $64
    db $66, $68, $6a, $a9, $6c, $6e, $70, $72, $74, $76, $78, $a5, $7a, $a0, $58, $5a
    db $5c, $5e, $60, $62, $64, $66, $68, $6a, $a1, $6c, $6e, $70, $a4, $72, $a4, $01
    db $a0, $01, $a0, $72, $74, $76, $78, $7a, $7c, $a4, $7e, $a9, $64, $6a, $6e, $74
    db $a8, $62, $a6, $01, $a9, $7a, $7c, $7e, $80, $82, $a5, $84, $aa, $01, $a1, $01
    db $a0, $72, $74, $76, $78, $7a, $7c, $a8, $7e, $a6, $5a, $5c, $a2, $5e, $60, $62
    db $a1, $64, $66, $a9, $68, $6a, $6c, $72, $a1, $74, $76, $78, $a5, $7a, $aa, $01
    db $00, $00, $c5, $40, $f9, $68, $ff, $68, $09, $69, $0d, $69, $a0, $7d, $8a, $7d
    db $00, $00, $ca, $7d, $11, $69, $f0, $00, $01, $69

    nop
    nop

    db $f4, $7d, $00, $00, $04, $7e, $00, $00, $f1, $47, $00, $07, $a8, $01, $01, $a0
    db $70, $6a, $74, $78, $6c, $6a, $74, $66, $a1, $7a, $78, $74, $78, $6c, $a5, $01
    db $a1, $7a, $78, $66, $70, $6a, $74, $78, $6c, $a5, $01, $a8, $01, $a0, $7a, $78
    db $66, $70, $6a, $74, $78, $6c, $a5, $01, $a7, $01, $a1, $7a, $78, $66, $70, $6a
    db $74, $78, $6c, $a5, $01, $01, $a3, $01, $a1, $78, $66, $7a, $01, $01, $78, $66
    db $70, $6a, $74, $70, $a6, $01, $a1, $6a, $6c, $6e, $70, $74, $a3, $01, $a1, $7a
    db $6a, $62, $58, $6c, $a8, $01, $01, $01, $01, $a1, $78, $66, $7a, $78, $66, $70
    db $6a, $74, $70, $6a, $a8, $01, $01, $a1, $62, $7a, $78, $66, $a5, $01, $00, $00
    db $c5, $40, $93, $69, $9d, $69, $a5, $69, $ad, $69, $a0, $7d, $7e, $7d, $b1, $69
    db $f0, $00, $97, $69, $ca, $7d, $e2, $69, $f0, $00, $9f, $69, $f4, $7d, $92, $6a
    db $f0, $00, $a7, $69, $04, $7e, $00, $00, $f1, $57, $15, $80, $f4, $0a, $a1, $7a
    db $78, $66, $70, $6a, $74, $78, $6c, $f5, $a5, $01, $01, $f4, $02, $a1, $7a, $78
    db $66, $70, $6a, $74, $78, $6c, $f5, $a5, $01, $f4, $16, $a1, $7e, $78, $6c, $72
    db $6a, $76, $78, $62, $f5, $ac, $01, $01, $00, $f1, $37, $00, $07, $a5, $01, $01
    db $a1, $04, $18, $1c, $30, $34, $48, $4c, $60, $64, $78, $7c, $90, $f4, $04, $62
    db $64, $62, $64, $62, $64, $62, $64, $ac, $01, $01, $a1, $04, $0c, $10, $18, $1c
    db $24, $28, $30, $34, $3c, $40, $48, $4c, $54, $58, $60, $64, $6c, $70, $78, $7c
    db $84, $88, $90, $7a, $7c, $62, $64, $4a, $4c, $32, $34, $1a, $1c, $02, $04, $ac
    db $01, $01, $01, $a1, $84, $84, $0c, $0e, $6c, $6e, $24, $26, $54, $56, $3c, $3e
    db $3c, $88, $90, $10, $18, $70, $78, $28, $30, $58, $60, $40, $48, $40, $48, $40
    db $7e, $7c, $06, $04, $66, $62, $1e, $1c, $4e, $4c, $36, $34, $36, $34, $34, $36
    db $34, $7a, $7c, $70, $62, $64, $58, $4a, $4c, $40, $32, $34, $28, $1a, $1c, $10
    db $02, $04, $ac, $01, $f1, $47, $00, $82, $a0, $88, $84, $7a, $78, $70, $6c, $62
    db $60, $58, $54, $4a, $48, $40, $3c, $32, $30, $28, $24, $1a, $18, $10, $0c, $02
    db $a5, $78, $01, $01, $78, $ac, $01, $01, $00, $f1, $8b, $41, $63, $a8, $f4, $06
    db $30, $f5

    db $f4
    ld b, $32
    push af
    db $f4
    ld b, $34
    push af
    db $f4
    ld b, $36
    push af
    db $f4
    ld b, $38
    push af
    db $f4
    ld b, $3a
    push af
    db $f4
    ld b, $3c
    push af
    db $f4
    ld b, $3e
    push af
    db $f4
    ld b, $40
    push af
    db $f4
    ld b, $3e
    push af
    db $f4
    ld b, $3c
    push af
    db $f4
    ld b, $3a
    push af
    db $f4
    ld b, $38
    push af
    db $f4
    ld b, $36
    push af
    db $f4
    ld b, $34
    push af
    db $f4
    ld b, $32
    push af
    db $f4
    ld b, $30
    push af
    db $f4
    ld b, $2e
    push af
    and l
    db $01
    nop

    db $01, $b8, $40, $ed, $6a, $f3, $6a, $f9, $6a, $ff, $6a, $05, $6b, $f0, $00, $ed
    db $6a, $15, $6b, $f0, $00, $f3, $6a, $25, $6b, $f0, $00, $f9, $6a, $ba, $6b, $f0
    db $00, $ff, $6a, $f1, $c3, $00, $00, $a3, $1a, $03, $a7, $1a, $03, $03, $ac, $05
    db $01, $01, $00, $f1, $c4, $00, $0a, $a3, $02, $03, $a7, $02, $03, $03, $ac, $05
    db $01, $01, $00, $f1, $7b, $41, $44, $f4, $05, $ac, $01, $01, $a1, $01, $a5, $01
    db $a1, $22, $03, $24, $03, $30, $03, $2e, $03, $a4, $2c, $03, $01, $40, $a3, $03
    db $01, $a1, $20, $03, $2c, $03, $a4, $34, $a3, $03, $01, $a1, $32, $03, $30, $03
    db $a5, $24, $03, $01, $ac, $01, $a1, $20, $03, $22, $03, $1a, $03, $2e, $03, $2c
    db $03, $a4, $26, $03, $01, $01, $a2, $1e, $03, $20, $03, $28, $03, $a7, $18, $03
    db $a1, $1c, $03, $a8, $10, $03, $14, $03, $0c, $03, $a1, $02, $03, $0e, $03, $18
    db $03, $1a, $03, $24, $03, $a7, $30, $03, $2e, $03, $a8, $32, $03, $a7, $40, $03
    db $42, $03, $3a, $03, $3c, $03, $38, $03, $40, $03, $30, $03, $a4, $28, $03, $a8
    db $2a, $03, $01, $a1, $28, $03, $26, $03, $1a, $03, $14, $03, $0e, $03, $a4, $1a
    db $03, $f5, $f4, $08, $ac, $01, $f5, $00, $a4, $74, $a2, $01, $a7, $78, $a2, $01
    db $00, $fe, $df, $40, $00, $00, $e0, $6b, $f4, $6b, $fa, $6b, $00, $6c, $00, $6c
    db $5f, $6c, $00, $6c, $5f, $6c, $5f, $6c, $00, $6c, $f0, $00, $ce, $6b, $5a, $6c
    db $04, $6c, $04, $6c, $5f, $6c, $04, $6c, $5f, $6c, $5f, $6c, $04, $6c, $f0, $00
    db $e0, $6b, $65, $6c

    ldh a, [rP1]
    db $f4
    ld l, e

    db $85, $6c, $f0, $00, $fa, $6b, $f1, $61, $00, $49, $f4, $02, $a9, $78, $05, $03
    db $68, $05, $03, $6c, $05, $03, $64, $05, $03, $68, $05, $03, $70, $05, $03, $f5
    db $f4, $02, $74, $05, $03, $68, $05, $03, $6c, $05, $03, $64, $05, $03, $68, $05
    db $03, $60, $05, $03, $f5, $f4, $02, $70, $05, $03, $60, $05, $03, $64, $05, $03
    db $6c, $05, $03, $70, $05, $03, $78, $05, $03, $f5, $f4, $02, $6c, $05, $03, $60
    db $05, $03, $64, $05, $03, $5c, $05, $03, $60, $05, $03, $68, $05, $03, $f5, $00
    db $f1, $61, $00, $40, $00, $f4, $06, $a5, $01, $f5, $00, $f1, $7b, $41, $40, $f4
    db $0a, $a5, $18, $a7, $24, $a5, $20, $14, $0c, $a7, $1c, $a5, $14, $0c, $1a, $f5

    xor b
    jr @-$59

    ld d, $a4
    inc d
    and l
    ld [de], a
    inc h
    inc d
    nop

    db $a6, $74, $a0, $01, $a6, $78, $a1, $01, $00, $0b, $c5, $40, $99, $6c, $9d, $6c
    db $a1, $6c, $a5, $6c, $a9, $6c, $00, $00, $ee, $6c, $00, $00, $1d, $6d, $00, $00
    db $46, $6d, $00, $00, $f1, $a1, $00, $00, $a1, $74, $76, $74, $76, $f1, $80, $00
    db $80, $a2, $32, $a7, $03, $a2, $2c, $a7, $03, $a2, $28, $03, $22, $03, $1a, $03
    db $22, $03, $36, $03, $2e, $03, $28, $a6, $03, $a6, $20, $03, $f1, $0d, $00, $80
    db $a7, $22, $a3, $03, $f1, $81, $00, $00, $f4, $04, $a1, $7a, $82, $f5, $f1, $41
    db $00, $00, $f4, $06, $a1, $7a, $82, $f5, $00, $f1, $f0, $00, $80, $ab, $01, $a3
    db $01, $a2, $3c, $03, $46, $03, $4a, $03, $4e, $03, $52, $03, $4a, $03, $40, $03
    db $4a, $03, $54, $03, $4e, $03, $46, $a6, $03, $40, $03, $f1, $0b, $00, $80, $a7
    db $44, $f1, $b6, $00, $80, $a5, $44, $00, $f1, $23, $41, $20, $a3, $01, $a2, $54
    db $05, $5e, $05, $62, $05, $66, $05, $6a, $05, $62, $05, $58, $05, $62, $05, $6c
    db $05, $66, $05, $5e, $a6, $05, $a2, $58, $a6, $05, $03, $a4, $5c, $a3, $05, $03
    db $00, $a7, $68, $a5, $6c, $01, $01, $a7, $68, $ac, $6c, $00, $01, $d2, $40, $5c
    db $6d, $5c, $6d, $64, $6d, $6a, $6d, $70, $6d, $7b, $6d, $f0, $00, $5e, $6d, $77
    db $6d, $f0, $00, $64, $6d, $82, $6d, $f0, $00, $6a, $6d, $f1, $90, $00, $40, $a0
    db $01, $00, $f1, $6b, $41, $40, $f4, $03, $a3, $14, $03, $f5, $00, $a6, $74, $a0
    db $01, $a6, $78, $a1, $01, $00, $00, $c5, $40, $96, $6d, $a0, $6d, $a8, $6d, $b0
    db $6d, $b8, $6d, $7e, $7d, $c6, $6d, $f0, $00, $9a, $6d, $0d, $6e, $29, $6e, $f0
    db $00, $a2, $6d, $68, $6e, $77, $6e, $f0, $00, $aa, $6d, $a3, $6e, $b2, $6e, $f0
    db $00, $b2, $6d, $f1, $a0, $17, $06, $a5, $0e, $a2, $34, $38, $42, $4a, $56, $5e
    db $00, $f1, $87, $7f, $00, $a2, $1a, $01, $1c, $01, $1e, $01, $20, $01, $22, $01
    db $24, $f1, $67, $34, $00, $a1, $28, $f4, $03, $a2, $32, $01, $36, $01, $30, $01
    db $2e, $01, $f5, $f1, $83, $00, $00, $a1, $4a, $60, $4a, $60, $a3, $4a, $a1, $4a
    db $60, $4a, $f1, $d1, $00, $08, $a3, $58, $a1, $01, $f1, $67, $77, $00, $a2, $22
    db $01, $20, $01, $1e, $01, $1c, $01, $00, $f1, $a5, $00, $00, $a1, $36, $1e, $42
    db $2a, $a4, $4e, $a1, $7e, $7c, $7e, $7c, $f1, $85, $00, $08, $a2, $62, $60, $5e
    db $5c, $56, $4c, $00, $f1, $83, $00, $00, $a2, $30, $24, $2c, $24, $26, $24, $28
    db $24, $30, $24, $2c, $a1, $26, $f4, $03, $a2, $30, $24, $2c, $24, $26, $24, $28
    db $24, $f5, $a1, $5a, $56, $5a, $56, $a3, $5a, $a1, $5a, $56, $5a, $f1, $d1, $00
    db $08, $a3, $5a, $a1, $01, $f1, $a1, $00, $00, $a2, $30, $24, $2c, $24, $26, $24
    db $28, $24, $00, $f1, $6b, $41, $40, $a1, $4e, $1e, $5a, $2a, $a7, $66, $03, $a8
    db $01, $00, $f1, $8b, $41, $47, $a3, $2c, $2c, $2c, $2c, $2a, $a2, $28, $a1, $01
    db $f4, $03, $a3, $2e, $2c, $2e, $2c, $f5, $f1, $7b, $41, $47, $a1, $7c, $86, $8a
    db $8e, $a3, $56, $a1, $8a, $82, $7c, $82, $a3, $4e, $a4, $2a, $2a, $00, $a1, $1c
    db $18, $1c, $18, $a8, $1c, $a2, $10, $14, $18, $18, $1c, $1c, $00, $a3, $14, $14
    db $14, $14, $14, $a2, $01, $a1, $10, $f4, $06, $a3, $14, $14, $f5, $a1, $14, $14
    db $14, $14, $a3, $1c, $a1, $14, $a7, $48, $a1, $14, $a3, $14, $14, $14, $14, $00
    db $00, $c5, $40, $e0, $6e, $e6, $6e, $ee, $6e, $f2, $6e, $a0, $7d, $7e, $7d, $00
    db $00, $ca, $7d, $f6, $6e, $f0, $00, $e8, $6e, $f4, $7d, $00, $00, $04, $7e, $00
    db $00, $f1, $17, $00, $87, $a1, $62, $52, $5c, $60, $60, $4e, $58, $54, $a4, $01
    db $a2, $62, $58, $52, $60, $4e, $ac, $01, $a1, $4e, $58, $52, $a8, $01, $01, $a1
    db $58, $52, $5c, $4e, $70, $52, $a5, $01, $a2, $58, $52, $ac, $01, $a1, $54, $60
    db $5c, $58, $52, $60, $62, $a8, $52, $58, $4e, $01, $01, $a1, $62, $60, $01, $56
    db $54, $58, $52, $01, $01, $58, $4e, $60, $a7, $01, $ac, $01, $a6, $4e, $58, $52
    db $ac, $01, $a1, $5c, $60, $54, $56, $58, $ac, $01, $00, $00, $df, $40, $00, $00
    db $00, $00, $00, $00, $5b, $6f, $5f, $6f

    nop
    nop

    db $a3, $48, $f4, $03, $a1, $2c, $2c, $f5, $f4, $03, $2c, $28, $f5, $f4, $02, $28
    db $24, $f5, $f4, $03, $20, $24, $f5, $f4, $02, $34, $38, $f5, $a1, $20, $34, $2c
    db $38, $20, $38, $2c, $34, $2c, $34, $28, $34, $20, $3c, $20, $2c, $20, $3c, $28
    db $34, $28, $30, $28, $2c, $a1, $24, $5c, $f4, $03, $28, $60, $f5, $f4, $5a, $28
    db $2c, $f5

    and l
    jr z, @+$02

    db $0d, $f9, $40, $af, $6f, $af, $6f, $c1, $6f, $00, $00, $c5, $6f, $7a, $7d, $d2
    db $6f, $f6, $6f, $00, $00

    push bc
    ld l, a
    jp nc, $f66f

    ld l, a
    nop
    nop

    db $00, $70, $00, $00, $f1, $09, $00, $00, $a7, $62, $f1, $f5, $00, $00, $a8, $62
    db $00, $f1, $a7, $35, $80, $ab, $32, $40, $36, $44, $3a, $48, $3c, $4a, $40, $4e
    db $44, $52, $48, $54, $4a, $58, $4e, $5c, $52, $60, $54, $62, $58, $66, $5c, $6a
    db $60, $6c, $62, $70, $00, $f1, $c7, $00, $80, $a0, $52, $01, $a5, $54, $00, $f1
    db $6b, $41, $20, $a3, $01, $a1, $01, $f4, $04, $a0, $02, $03, $f5, $a1, $01, $a4
    db $01, $f1, $6b, $41, $60, $ab, $32, $40, $36, $44, $3a, $48, $3c, $4a, $40, $4e
    db $44, $52, $48, $54, $4a, $58, $4e, $5c, $52, $60, $54, $62, $58, $66, $5c, $6a
    db $60, $6c, $62, $70, $a0, $52, $03, $a3, $54, $03, $00, $01, $d2, $40, $47, $70
    db $47, $70, $61, $70, $75, $70, $09, $7e, $8b, $70, $8b, $70

    adc e
    ld [hl], b
    adc e
    ld [hl], b
    adc e
    ld [hl], b
    ld a, [hl]
    ld a, l
    ld d, d
    ld [hl], c
    add a
    ld [hl], c
    call z, $7a71
    ld a, l
    ldh a, [rP1]
    ld b, a
    ld [hl], b

    db $10, $7e, $95, $70, $9f, $70

    ld [de], a
    ld [hl], c
    sub l
    ld [hl], b
    ld de, $4e72
    ld [hl], d
    or b
    ld [hl], e
    ldh a, [rP1]
    ld h, c
    ld [hl], b

    db $17, $7e, $3e, $71, $3e, $71

    ld b, h
    ld [hl], c
    ld b, h
    ld [hl], c
    ld a, $71
    jp hl


    ld [hl], e
    rst $28
    ld [hl], e
    rrca
    ld [hl], h
    ldh a, [rP1]
    ld [hl], l
    ld [hl], b

    db $f1, $d7, $00, $44, $f4, $04, $ac, $76, $f5, $00, $f1, $23, $41, $63, $ac, $01
    db $01, $01, $01, $00, $a8, $01, $a2, $72, $5c, $62

    inc bc
    ld [hl], d
    ld d, d
    ld bc, $015c
    ld h, d
    xor b
    ld bc, $01a2
    ld h, h
    ld [hl], d
    ld h, h
    ld [hl], h
    ld a, b
    ld h, b
    ld l, [hl]
    ld [hl], d
    ld bc, $01a8
    and d
    ld [hl], d
    ld l, d
    ld d, h
    ld h, [hl]
    ld h, h
    ld c, d
    ld a, b
    inc bc
    ld e, d
    ld l, b
    xor b
    ld bc, $6ea2
    ld bc, $6a5a
    ld c, h
    ld [hl], d
    ld a, b
    ld d, d
    db $76
    inc bc
    pop af
    inc hl
    ld b, c
    ld b, e
    and h
    ld bc, $76a2
    inc bc
    ld [hl], d
    inc bc
    ld h, d
    ld a, h
    ld [hl], d
    inc bc
    ld [hl], d
    ld h, d
    db $76
    inc bc
    xor b
    ld bc, $01a2
    ld h, h
    ld a, b
    ld h, [hl]
    inc bc
    ld h, h

jr_004_70ef:
    ld l, d
    ld l, h
    ld l, [hl]
    inc bc
    and h
    ld bc, $62a2
    ld l, d
    ld [hl], d
    inc bc
    ld l, h
    ld h, [hl]
    inc bc
    ld h, d
    ld l, d
    inc bc
    ld [hl], h
    inc bc
    and h
    ld bc, $66a2
    inc bc
    ld [hl], d
    inc bc
    ld l, d
    ld a, b
    ld [hl], h
    ld h, h
    inc bc
    ld a, b
    db $76
    inc bc
    nop
    pop af
    inc de
    ld b, c
    ld b, b
    and e
    add h
    inc bc
    ld a, d
    inc bc
    add d
    inc bc
    db $76
    inc bc
    ld a, [hl]
    inc bc
    ld [hl], b
    inc bc
    ld a, h
    inc bc
    ld [hl], h
    inc bc
    ld a, b
    inc bc
    ld a, [hl]
    inc bc
    and c
    ld bc, $7ca3
    inc bc
    and d
    ld bc, $74a3
    inc bc
    and [hl]
    ld bc, $70a8
    and d
    inc bc
    xor b
    db $01
    nop

    db $ac, $01, $01, $01, $01, $00

    db $f4
    ld [bc], a

jr_004_7146:
    and d
    inc d
    and l
    jr nz, jr_004_70ef

    ld bc, $01a7
    xor h
    jr nc, jr_004_7146

    nop
    pop af
    inc c
    nop

jr_004_7155:
    ld b, b
    and a
    ld b, b
    and h
    inc bc
    and d
    ld bc, $3ca7
    and h
    inc bc
    and d

jr_004_7161:
    ld bc, $3aa7
    and h
    inc bc
    and d
    ld bc, $38a7
    and h
    inc bc
    and d
    ld bc, $36a7
    and h
    inc bc
    and d
    ld bc, $46a7
    and h
    inc bc
    and d
    ld bc, $38a7
    and h
    inc bc
    and d
    ld bc, $48a7
    and h
    inc bc
    and d
    ld bc, $f100
    rrca
    nop
    nop
    xor b
    ld c, d
    and e
    inc bc
    xor b
    ld c, b
    and e
    inc bc
    xor b
    ld b, [hl]
    and e
    inc bc
    xor b
    ld b, h
    and e
    inc bc
    xor b
    ld b, d
    and e
    inc bc
    xor b
    ld b, b
    and e
    inc bc
    xor b
    ld a, $a3
    inc bc
    xor b
    ld c, b
    and e
    inc bc
    xor b
    ld [hl-], a
    and e
    inc bc
    xor b
    jr nc, jr_004_7155

    inc bc
    xor b
    ld l, $a3
    inc bc

jr_004_71b7:
    xor b
    inc l
    and e
    inc bc
    xor b
    jr z, jr_004_7161

    inc bc
    xor b
    inc h
    and e
    inc bc
    xor b
    jr nz, @-$5b

    inc bc
    xor b
    ld a, [de]
    and a
    inc bc
    nop
    pop af
    di
    nop
    nop
    db $f4
    ld [bc], a
    and d
    ld h, d
    inc bc
    db $76
    inc bc
    ld [hl], h
    inc bc
    ld l, h
    inc bc
    and e
    ld [hl], b
    inc bc
    xor b
    ld bc, $f1f5
    jp RST_00


    and d
    ld h, d
    inc bc
    db $76
    inc bc
    ld [hl], h
    inc bc
    ld l, h
    inc bc
    and e
    ld [hl], b
    inc bc
    xor b
    ld bc, $84f1

jr_004_71f5:
    nop
    nop
    and e
    ld h, d
    db $76
    ld [hl], h
    ld l, h
    ld [hl], b
    ld bc, $01a8
    pop af
    ld b, a
    nop
    nop
    and e
    ld h, d
    db $76
    ld [hl], h
    ld l, h
    ld [hl], b
    ld bc, $0ef4
    and l
    ld bc, $00f5
    pop af
    xor e
    ld b, c
    jr nz, jr_004_71b7

    ld bc, $52a3
    inc bc
    ld bc, $54a2
    inc bc
    and e
    ld e, b
    inc bc
    and [hl]
    ld c, d
    and e
    inc bc
    and c
    ld bc, $5ea6
    and [hl]
    inc bc
    ld bc, $a101
    ld e, h
    inc bc
    ld d, h
    inc bc
    and [hl]
    ld e, b
    and c
    inc bc
    and e
    ld bc, $0101
    and l
    ld bc, $a601
    ld e, [hl]
    inc bc
    and a
    ld bc, $5ca1
    inc bc
    ld d, h
    inc bc
    and [hl]
    ld e, b
    and e
    inc bc
    ld bc, $0001
    pop af
    adc e
    ld b, c
    jr nz, jr_004_71f5

    ld bc, $52a6
    and d
    dec b
    and c
    ld bc, $03a2
    and c
    ld bc, $03a2
    and c
    ld bc, $54a2
    and c
    ld bc, $a205
    ld e, b
    and c
    ld bc, $05a2
    and c
    ld bc, $03a2
    and c
    ld bc, $03a2
    and c
    ld bc, $54a1
    inc bc
    ld d, d
    inc bc
    and d
    ld d, h
    and c
    ld bc, $05a2
    and c
    ld bc, $03a2
    and c
    ld bc, $03a2
    and c
    ld bc, $52a1
    inc bc
    ld c, [hl]
    inc bc
    and d
    ld c, d
    and c
    ld bc, $05a2
    and c
    ld bc, $03a2
    and c
    ld bc, $03a2

jr_004_729f:
    and c
    ld bc, $4aa1
    inc bc
    ld c, [hl]
    inc bc
    and d
    ld c, d
    and c
    ld bc, $05a2
    and c
    ld bc, $03a2
    and c
    ld bc, $03a2
    and c
    ld bc, $4ea2
    and c
    ld bc, $a205
    ld c, d
    and c
    ld bc, $05a2
    and c
    ld bc, $03a2
    and c
    ld bc, $03a2
    and c
    ld bc, $4aa2
    and c
    ld bc, $a205
    ld c, d
    and c
    ld bc, $05a2
    and c
    ld bc, $03a2
    and c
    ld bc, $03a2
    and c
    ld bc, $48a1
    inc bc
    ld b, h
    inc bc
    and d
    ld c, b
    and c
    ld bc, $05a2
    and c
    ld bc, $03a2
    and c
    ld bc, $03a2
    and c
    ld bc, $4aa1
    inc bc
    ld c, [hl]
    pop af
    adc e
    ld b, c
    jr nz, jr_004_729f

    inc bc
    and [hl]
    ld d, d
    and d
    dec b
    and c
    ld bc, $03a2
    and c
    ld bc, $03a2
    and c
    ld bc, $54a2
    and c
    ld bc, $a205
    ld e, b
    and c
    ld bc, $05a2
    and c
    ld bc, $03a2
    and c
    ld bc, $03a2
    and c
    ld bc, $54a1
    inc bc
    ld d, d
    inc bc
    and d
    ld d, h
    and c
    ld bc, $05a2
    and c
    ld bc, $03a2
    and c
    ld bc, $03a2
    and c
    ld bc, $52a1
    inc bc
    ld c, [hl]
    inc bc
    and d
    ld c, d
    and c
    ld bc, $05a2
    and c
    ld bc, $03a2
    and c
    ld bc, $03a2
    and c
    ld bc, $48a1
    inc bc
    ld b, h
    inc bc
    and d
    ld c, b
    and c
    ld bc, $05a2
    and c
    ld bc, $03a2
    and c
    ld bc, $03a2
    and c
    ld bc, $44a2
    and c
    ld bc, $a205
    ld c, b
    and c
    ld bc, $05a2
    and c
    ld bc, $03a2
    and c
    ld bc, $03a2
    and c
    ld bc, $46a1
    inc bc
    ld b, h
    inc bc
    and d
    ld b, b
    and c
    ld bc, $05a2
    and c
    ld bc, $03a2
    and c
    ld bc, $03a2
    and c
    ld bc, $3ca2
    and c
    ld bc, $a205
    ld b, b
    and c
    ld bc, $05a0
    and d
    ld b, b
    and c
    ld bc, $0140
    ld b, b
    ld bc, $a042
    ld bc, $0142
    ld b, d
    ld bc, HeaderNewLicenseeCode
    ld b, h
    ld bc, HeaderSGBFlag
    ld c, b
    ld bc, HeaderDestinationCode
    nop
    pop af
    ld l, e
    ld b, c
    jr nz, @-$5d

    inc bc
    and d
    ld a, [de]
    inc bc
    ld a, [de]
    inc bc
    db $f4
    ld [$1aa2], sp
    inc bc
    ld a, [de]
    inc bc
    ld a, [de]
    inc bc
    push af
    pop af
    ld l, e
    ld b, c
    ld b, b
    db $f4
    inc bc
    and d
    ld a, [de]
    inc bc
    ld a, [de]
    inc bc
    ld a, [de]
    inc bc
    push af
    pop af
    ld l, e
    ld b, c
    ld h, b
    db $f4
    dec b
    and d
    ld a, [de]
    inc bc
    ld a, [de]
    inc bc
    ld a, [de]
    inc bc
    push af
    db $f4
    dec bc
    and l
    ld bc, $a8f5
    ld bc, $f400
    ld [$01a5], sp
    push af
    nop
    db $f4
    ld [$01a5], sp
    push af
    and d
    ld bc, $01a4
    and l
    jr nz, @+$03

    ld bc, $0120
    ld bc, $20a7
    and c
    ld bc, $7ca2
    ld bc, $0180
    add h
    ld bc, $84a6
    and d
    ld bc, $f400
    dec b
    xor b
    jr nz, @+$32

    jr nz, @-$09

    jr nz, @+$32

    jr nz, @+$32

    inc h
    inc h
    jr c, @+$2a

    jr z, @+$3e

    inc a
    db $f4
    dec b
    and l
    ld bc, $00f5

    db $01, $df, $40, $32, $74, $32, $74, $36, $74, $3a, $74, $3e, $74

    nop
    nop

    db $62, $74, $00, $00, $7a, $74

    nop
    nop

    db $f1, $0b, $00, $40, $a7, $10, $03, $a1, $01, $f1, $09, $00, $40, $a6, $28, $a1
    db $03, $a6, $40, $a1, $03, $a6, $3e, $a1, $03, $a0, $01, $a6, $36, $a2, $03, $a4
    db $3a, $a5, $03

    nop

    db $f1, $7b, $41, $40, $a8, $01, $a2, $01, $a7, $62, $a2, $03, $a7, $66, $a2, $03
    db $a1, $01, $01, $a4, $5c, $a2, $03, $00, $a7, $48, $74, $48, $a6, $5c, $54, $4c
    db $50, $a2, $58, $a3, $68, $ac, $6c

    nop

    db $00, $f9, $40, $95, $74, $b3, $74, $c9, $74, $dd, $74, $f1, $74, $cb, $79, $f9
    db $74, $ba, $76, $fe, $74, $23, $75, $8c, $75, $c5, $75, $c5, $75, $c5, $75, $c5
    db $75, $ea, $75, $13, $76, $2c, $76, $00, $00, $ae, $76, $cb, $79, $b6, $76, $45
    db $77, $59, $77, $be, $77, $19, $78, $5b, $78, $91, $78, $e6, $78, $00, $00, $a3
    db $79, $0d, $7a, $56, $7a, $6b, $7a, $81, $7a, $8c, $7a, $95, $7a, $9e, $7a, $ab
    db $7a, $00, $00, $1e, $7b, $4b, $7b, $75, $7b, $8d, $7b, $ae, $7b, $c4, $7b, $da
    db $7b, $ec, $7b, $fe, $7b, $00, $00, $f1, $60, $00, $09, $a5, $01, $01, $00, $f1
    db $b0, $00, $49, $00, $f1, $52, $00, $40, $f4, $02, $a1, $4a, $54, $58, $62, $f5
    db $f4, $02, $a1, $3c, $4a, $4e, $54, $f5, $f4, $02, $a1, $4a, $54, $58, $62, $f5
    db $f4, $02, $a1, $3c, $4a, $4e, $54, $f5, $00, $f1, $51, $00, $40, $f4, $02, $a1
    db $4a, $54, $58, $62, $f5, $f4, $02, $a1, $3c, $4a, $4e, $54, $f5, $f4, $02, $a1
    db $4a, $52, $54, $62, $f5, $f4, $02, $a1, $4e, $52, $54, $66, $f5, $f4, $02, $a1
    db $4a, $54, $58, $62, $f5, $f4, $02, $a1, $3c, $4a, $4e, $54, $f5, $f4, $02, $a1
    db $40, $4a, $4e, $58, $f5, $f4, $02, $a1, $3c, $4a, $4e, $54, $f5, $f4, $02, $a1
    db $4a, $52, $54, $62, $4a, $52, $54, $62, $3c, $4a, $4e, $54, $3c, $4a, $4e, $54
    db $4a, $52, $54, $62, $4a, $52, $54, $62, $4e, $52, $54, $66, $4e, $52, $54, $66
    db $f5, $00, $f1, $81, $00, $00, $f4, $03, $a1, $4a, $52, $54, $62, $4a, $52, $54
    db $62, $46, $52, $54, $5e, $46, $52, $54, $5e, $f5, $f4, $02, $a1, $3c, $4a, $4e
    db $54, $f5, $f4, $02, $a1, $46, $52, $54, $5e, $f5, $f4, $02, $a1, $44, $52, $54
    db $5c, $f5, $f4, $02, $a1, $40, $4a, $4e, $52, $f5, $00, $f1, $61, $00, $40, $f4
    db $02, $a1, $3c, $4a, $4e, $54, $f5, $f4, $02, $a1, $46, $52, $54, $5e, $f5, $f4
    db $02, $a1, $44, $52, $54, $5c, $f5, $f4, $02, $a1, $40, $4a, $4e, $52, $f5, $00
    db $f1, $43, $00, $80, $f4, $04, $a1, $3c, $44, $4e, $54, $3c, $44, $4e, $54, $46
    db $52, $54, $5e, $46, $52, $54, $5e, $44, $52, $54, $5c, $44, $52, $54, $5c, $40
    db $4a, $4e, $52, $40, $4a, $4e, $52, $f5, $00, $f1, $72, $00, $00, $f4, $04, $a1
    db $4a, $52, $54, $62, $4a, $52, $54, $62, $46, $52, $54, $5e, $46, $52, $54, $5e
    db $f5, $00, $f1, $82, $00, $00, $a1, $4a, $52, $54, $62, $4a, $52, $54, $62, $3c
    db $4a, $4e, $54, $3c, $4a, $4e, $54, $4a, $52, $54, $62, $4a, $52, $54, $62, $4e
    db $52, $54, $66, $4e, $52, $54, $66, $f1, $a2, $00, $00, $f4, $05, $a1, $4a, $52
    db $54, $4a, $4a, $52, $54, $4a, $3c, $4a, $4e, $54, $3c, $4a, $4e, $54, $f5, $f1
    db $c3, $00, $00, $a1, $4a, $52, $54, $62, $4a, $52, $54, $62, $3c, $4a, $4e, $54
    db $3c, $4a, $4e, $54, $f1, $d4, $00, $00, $a2, $4a, $a1, $03, $a2, $48, $a1, $03
    db $4a, $03, $f2, $06, $41, $a4, $54, $f1, $09, $00, $00, $a2, $52, $03, $f1, $d5
    db $00, $40, $a1, $4a, $03, $a0, $4a, $03, $4a, $03, $ab, $32, $40, $f1, $c7, $00
    db $00, $a5, $62, $00, $f1, $60, $00, $00, $a5, $01, $01, $00, $f1, $b0, $00, $00
    db $a3, $52, $a2, $03, $a0, $54, $03, $52, $03, $a1, $4e, $a2, $03, $a1, $4a, $a2
    db $03, $a1, $46, $03, $a2, $4a, $03, $3c, $03, $a3, $54, $a2, $03, $a0, $52, $03
    db $4e, $03, $a3, $52, $a2, $03, $a1, $4e, $03, $a2, $4e, $03, $44, $03, $a3, $4a
    db $a2, $03, $a0, $48, $03, $44, $03, $a3, $48, $03, $a3, $52, $a2, $03, $a0, $54
    db $03, $52, $03, $a1, $4e, $a2, $03, $a1, $4a, $a2, $03, $a1, $46, $03, $a3, $4a
    db $a2, $03, $a0, $4e, $03, $52, $03, $a3, $54, $a2, $03, $a0, $58, $03, $54, $03
    db $a3, $52, $a2, $03, $a1, $4e, $03, $a2, $4e, $03, $44, $03, $a3, $4a, $a2, $03
    db $a0, $48, $03, $4a, $03, $a2, $4e, $03, $44, $03, $a3, $4a, $a2, $03, $a0, $48
    db $03, $44, $03, $a3, $48, $a2, $03, $a1, $58, $03, $00, $f1, $a0, $00, $00, $a7
    db $62, $a4, $03, $a1, $40, $03, $a7, $62, $03, $a1, $1a, $03, $01, $01, $00, $f1
    db $c0, $00, $40, $a3, $4a, $a2, $03, $a1, $4a, $03, $a2, $46, $a1, $03, $a2, $44
    db $a1, $03, $a0, $40, $03, $3c, $03, $a3, $40, $a8, $03, $a3, $3a, $a2, $03, $a1
    db $40, $03, $a2, $3c, $a1, $03, $a2, $3a, $a1, $03, $a0, $36, $03, $32, $03, $a3
    db $36, $a8, $03, $a3, $40, $a2, $03, $a1, $4a, $03, $a2, $46, $a1, $03, $a2, $44
    db $a1, $03, $a0, $40, $03, $3c, $03, $a3, $40, $a8, $03, $a3, $40, $a2, $03, $a1
    db $4a, $03, $a2, $3c, $a1, $03, $a2, $40, $a1, $03, $a0, $44, $03, $3c, $03, $a3
    db $40, $a8, $03, $00, $f1, $b0, $00, $40, $a3, $52, $a2, $03, $a0, $4e, $03, $52
    db $03, $a3, $54, $a2, $03, $a0, $52, $03, $4e, $03, $a3, $52, $a2, $03, $a0, $4e
    db $03, $52, $03, $a3, $54, $a2, $03, $a0, $52, $03, $54, $03, $a3, $58, $a2, $03
    db $a0, $54, $03, $52, $03, $a3, $54, $a2, $03, $a0, $52, $03, $4e, $03, $a6, $4a
    db $03, $a0, $4e, $03, $52, $03, $a6, $4e, $03, $a0, $4a, $03, $46, $03, $a6, $4a
    db $03, $a0, $46, $03, $44, $03, $a6, $46, $03, $a0, $44, $03, $40, $03, $00, $f1
    db $d0, $00, $00, $f4, $02, $a2, $4a, $03, $58, $03, $a3, $54, $a2, $03, $a1, $4a
    db $03, $a3, $4a, $a2, $03, $a0, $46, $03, $44, $03, $a3, $46, $a2, $03, $a1, $4e
    db $03, $a2, $4a, $03, $58, $03, $a3, $54, $a2, $03, $a1, $4a, $03, $a3, $4a, $a2
    db $03, $a0, $46, $03, $44, $03, $a3, $46, $a2, $03, $a0, $44, $03, $40, $03, $f5
    db $00, $f1, $a0, $00, $80, $f4, $02, $a3, $62, $a4, $03, $a2, $01, $a1, $66, $03
    db $a6, $62, $03, $a0, $5e, $03, $5c, $03, $a6, $5e, $03, $a1, $5c, $03, $a6, $5c
    db $a4, $03, $a6, $01, $a1, $5e, $03, $a2, $54, $a3, $03, $a1, $58, $03, $a2, $5c
    db $a3, $03, $a1, $5e, $03, $f5, $00, $f1, $d0, $00, $00, $a3, $3a, $a2, $03, $a0
    db $3c, $03, $3a, $03, $a2, $36, $a1, $03, $a2, $32, $a1, $03, $a1, $2e, $03, $a3
    db $40, $a2, $03, $a0, $44, $03, $40, $03, $a2, $3c, $a1, $03, $a2, $3a, $a1, $03
    db $a1, $36, $03, $a3, $3a, $a2, $03, $a0, $3c, $03, $3a, $03, $a2, $36, $a1, $03
    db $a2, $3a, $a1, $03, $a1, $3c, $03, $a3, $40, $a2, $03, $a0, $44, $03, $40, $03
    db $a2, $3c, $a1, $03, $a2, $40, $a1, $03, $a1, $44, $03, $00, $f1, $b0, $00, $40
    db $a3, $40, $a2, $03, $a1, $4a, $03, $a2, $44, $a1, $03, $a2, $40, $a1, $03, $a1
    db $3c, $03, $a3, $40, $a2, $03, $a1, $4a, $03, $a2, $44, $a1, $03, $a2, $4a, $a1
    db $03, $a1, $54, $03, $a3, $40, $a2, $03, $a1, $4a, $03, $a2, $44, $a1, $03, $a2
    db $40, $a1, $03, $a1, $3c, $03, $a3, $40, $a2, $03, $a1, $4a, $03, $a2, $44, $a1
    db $03, $a2, $4a, $a1, $03, $a1, $54, $03, $a3, $52, $a2, $03, $a1, $58, $03, $a2
    db $54, $a1, $03, $a2, $52, $a1, $03, $4a, $03, $a3, $52, $a2, $03, $a1, $58, $03
    db $a2, $54, $a1, $03, $a2, $5c, $a1, $03, $62, $03, $a3, $52, $a2, $03, $a1, $58
    db $03, $a2, $54, $a1, $03, $a2, $52, $a1, $03, $4a, $03, $f1, $d0, $00, $00, $a2
    db $3c, $a1, $03, $a2, $3a, $a1, $03, $32, $03, $a2, $54, $a1, $03, $a2, $52, $a1
    db $03, $4a, $03, $a1, $54, $a2, $03, $a1, $52, $a2, $03, $a1, $54, $03, $f1, $d0
    db $00, $00, $a7, $32, $a2, $03, $a2, $32, $03, $a1, $1a, $03, $a0, $1a, $03, $1a
    db $03, $ab, $02, $10, $a2, $1a, $a5, $05, $00, $f1, $6b, $41, $40, $f4, $02, $a0
    db $1a, $03, $20, $03, $24, $03, $2e, $03, $1a, $03, $20, $03, $2c, $03, $20, $03
    db $1a, $03, $20, $03, $24, $03, $2e, $03, $1a, $03, $20, $03, $24, $03, $32, $03
    db $f5, $a0, $1a, $03, $20, $03, $24, $03, $2e, $03, $1a, $03, $20, $03, $24, $03
    db $32, $03, $1a, $03, $20, $03, $24, $03, $38, $03, $1a, $03, $20, $03, $24, $03
    db $2e, $03, $1a, $03, $20, $03, $24, $03, $28, $03, $1a, $03, $20, $03, $24, $03
    db $2c, $03, $1a, $03, $20, $03, $24, $03, $32, $03, $32, $03, $38, $03, $3c, $03
    db $58, $03, $00, $f1, $7b, $41, $40, $a4, $62, $a7, $5e, $a2, $03, $a7, $5c, $a2
    db $03, $a7, $5a, $a2, $03, $a7, $58, $a2, $03, $a7, $56, $a2, $03, $a7, $54, $a2
    db $03, $a7, $58, $a2, $03, $a7, $4a, $a2, $03, $a7, $46, $a2, $03, $a7, $44, $a2
    db $03, $a7, $42, $a2, $03, $a4, $40, $a7, $3e, $a2, $03, $a7, $3c, $a2, $03, $a7
    db $3e, $a2, $03, $a7, $40, $a2, $03, $a7, $28, $a2, $03, $00, $f1, $6b, $41, $40
    db $f4, $07, $a1, $1a, $03, $a0, $1a, $03, $1a, $03, $f5, $a1, $28, $03, $01, $01
    db $00, $f1, $7b, $41, $40, $a4, $32, $24, $22, $1e, $1a, $24, $28, $24, $f4, $02
    db $a4, $1a, $24, $22, $1e, $f5, $00, $f4, $03, $a4, $32, $2e, $f5, $24, $2e, $2c
    db $28, $00, $f4, $04, $a4, $24, $2e, $2c, $28, $f5, $00, $f4, $04, $a4, $24, $2e
    db $2c, $28, $f5, $00, $f4, $02, $a4, $32, $2e, $f5, $f4, $02, $a4, $1a, $16, $f5
    db $00, $a4, $1a, $24, $22, $1e, $1a, $24, $32, $3c, $f1, $6b, $41, $40, $f4, $02
    db $a2, $32, $a1, $03, $a2, $30, $a1, $03, $28, $03, $a2, $3c, $a1, $03, $a2, $3a
    db $a1, $03, $32, $03, $f5, $a2, $4a, $a1, $03, $a2, $48, $a1, $03, $40, $03, $a2
    db $54, $a1, $03, $a2, $52, $a1, $03, $4a, $03, $a2, $4a, $a1, $03, $a2, $48, $a1
    db $03, $40, $03, $a2, $54, $a1, $03, $a2, $52, $a1, $03, $4a, $03, $a2, $62, $a1
    db $03, $a2, $60, $a1, $03, $62, $a0, $03, $01, $a7, $58, $a2, $03, $a2, $40, $03
    db $f1, $6b, $41, $20, $a1, $28, $03, $a0, $28, $03, $28, $03, $ab, $02, $10, $a2
    db $28, $a3, $03, $00, $f4, $02, $a2, $10, $0c, $10, $0c, $10, $0c, $0c, $a1, $1c
    db $14, $f5, $f4, $03, $a1, $10, $14, $0c, $04, $f5, $14, $0c, $1c, $1c, $f4, $02
    db $10, $1c, $0c, $04, $f5, $1c, $1c, $1c, $1c, $a2, $68, $a0, $1c, $1c, $1c, $1c
    db $00, $a5, $6c, $01, $01, $a8, $01, $a3, $68, $a3, $6c, $50, $54, $58, $a3, $54
    db $a4, $5c, $a3, $64, $60, $58, $a4, $54, $a3, $50, $4c, $54, $50, $f4, $04, $a1
    db $4c, $64, $f5, $a1, $14, $14, $14, $14, $a3, $6c, $00, $f4, $03, $a1, $1c, $0c
    db $14, $14, $f5, $a2, $68, $a1, $1c, $0c, $f4, $03, $a1, $1c, $08, $14, $14, $f5
    db $a3, $6c, $00, $f4, $07, $a1, $14, $0c, $10, $10, $14, $08, $10, $10, $14, $04
    db $10, $10, $14, $0c, $14, $04, $f5, $f4, $03, $a1, $14, $08, $10, $10, $f5, $1c
    db $14, $1c, $14, $00, $f4, $11, $a1, $1c, $0c, $08, $0c, $f5, $f4, $02, $a1, $1c
    db $0c, $1c, $0c, $f5, $a1, $1c, $14, $1c, $0c, $00, $f4, $0f, $a1, $1c, $10, $08
    db $10, $1c, $0c, $10, $08, $f5, $a1, $1c, $14, $08, $14, $1c, $14, $1c, $14, $00
    db $f4, $1e, $a1, $14, $0c, $08, $0c, $f5, $a1, $1c, $14, $08, $14, $1c, $14, $1c
    db $14, $00, $f4, $0e, $a1, $14, $10, $0c, $10, $f5, $a1, $1c, $14, $08, $14, $1c
    db $14, $1c, $14, $00, $f4, $08, $a1, $14, $10, $08, $10, $f5, $f4, $04, $a1, $14
    db $0c, $14, $10, $f5, $f4, $08, $a1, $14, $14, $08, $14, $f5, $f4, $04, $a1, $14
    db $14, $14, $14, $f5, $f4, $08, $a1, $1c, $1c, $1c, $1c, $f5, $a6, $1c, $1c, $a2
    db $1c, $a4, $1c, $a3, $1c, $a2, $1c, $a1, $1c, $1c, $ab, $1c, $1c, $a5, $1c, $00
    db $00, $c5, $40, $fa, $64, $1e, $65, $2a, $65, $36, $65, $00, $f9, $40, $6e, $68
    db $00, $00, $00, $00, $00, $00, $00, $f9, $40, $00, $00, $01, $69, $00, $00, $00
    db $00, $00, $df, $40, $97, $69, $9f, $69, $a7, $69, $00, $00, $00, $c5, $40, $00
    db $00, $e8, $6e, $00, $00, $00, $00, $01, $b8, $40, $7c, $7c, $8a, $7c, $96, $7c
    db $9e, $7c, $a6, $7c, $7e, $7d, $ad, $7c, $d6, $6f, $b8, $7c, $f0, $00, $ce, $6b
    db $bf, $7c, $cb, $7c, $d6, $6f, $d6, $7c, $f0, $00, $e0, $6b, $dd, $7c, $eb, $7c
    db $f0, $00, $f4, $6b, $f9, $7c, $01, $7d, $f0, $00, $fa, $6b, $f1, $87, $17, $06
    db $a5, $0e, $00, $f1, $0d, $00, $00, $a5, $62, $f1, $c7, $35, $00, $00, $f1, $f5
    db $00, $40, $a5, $6c, $00, $f1, $87, $00, $00, $a1, $36, $1e, $42, $2a, $a8, $4e
    db $00, $f1, $0d, $00, $00, $a5, $60, $f1, $c7, $00, $08, $00, $f1, $f5, $00, $40
    db $a5, $6a, $00, $f1, $7b, $41, $40, $a1, $4e, $1e, $5a, $2a, $a3, $66, $03, $01
    db $00, $f1, $6b, $41, $40, $a1, $02, $03, $f4, $0a, $a2, $02, $03, $f5, $00, $a1
    db $1c, $18, $1c, $18, $a8, $1c, $00, $a5, $01, $01, $a4, $01, $a2, $01, $00, $01
    db $df, $40, $14, $7d, $14, $7d, $18, $7d, $1c, $7d, $20, $7d, $00, $00, $2f, $7d
    db $00, $00, $3c, $7d, $00, $00, $f1, $f2, $00, $80, $a1, $28, $2c, $2e, $f1, $f5
    db $00, $80, $a8, $3c, $00, $f1, $7b, $41, $40, $a1, $46, $03, $4a, $a2, $32, $05
    db $03, $00, $a1, $14, $14, $14, $1c, $00, $f1, $15, $00, $40, $00, $f1, $35, $00
    db $40, $00, $f1, $65, $00, $40, $00

    pop af
    add l
    nop
    ld b, b
    nop
    pop af
    and l
    nop
    ld b, b
    nop

    db $f1, $7b, $41, $60, $00

    pop af
    ld a, e
    ld b, c
    ld b, b
    nop
    pop af
    ld a, e
    ld b, c
    jr nz, @+$02

    db $f2, $9e, $40, $00, $f2, $ab, $40, $00, $f2, $b8, $40, $00, $f2, $c5, $40, $00
    db $f2, $d2, $40, $00, $f2, $df, $40, $00, $f2, $ec, $40, $00, $f2, $f9, $40, $00
    db $f2, $06, $41, $00, $f3, $00, $00, $f3, $02, $00, $f3, $04, $00, $f3, $08, $00
    db $f3, $0c, $00, $f3, $10, $00, $f1, $a4, $00, $40, $a2, $32, $03, $32, $03, $f1
    db $84, $00, $40, $a3, $32, $f1, $64, $00, $40, $a3, $32, $f1, $44, $00, $40, $a3
    db $32, $f1, $24, $00, $40, $a3, $32, $f1, $14, $00, $40, $a8, $32, $a5, $01, $00
    db $f1, $b3, $00, $40, $a2, $0c, $03, $0c, $03, $f1, $93, $00, $40, $a3, $0c, $f1
    db $73, $00, $40, $a3, $0c, $f1, $53, $00, $40, $a3, $0c, $f1, $33, $00, $40, $a3
    db $0c, $f1, $23, $00, $40, $a8, $0c, $a5, $01, $00, $f1, $7b, $41, $40, $f4, $02
    db $a2, $32, $03, $f5, $a8, $01, $01, $a5, $01, $00, $a5, $01, $01, $01, $00, $f1
    db $11, $00, $00, $a4, $01, $00, $f1, $6b, $41, $60, $a4, $01, $00, $a4, $01, $00
    db $f1, $11, $00, $00, $a5, $01, $00, $f1, $6b, $41, $60, $a5, $01, $00, $a5, $01
    db $00

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
