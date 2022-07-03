; Disassembly of "Metroid2.gb"
; This file was created with:
; mgbdis v1.4 - Game Boy ROM disassembler by Matt Currie and contributors.
; https://github.com/mattcurrie/mgbdis

SECTION "ROM Bank $002", ROMX[$4000], BANK[$2]

Call_002_4000: ; 02:4000
    ld e, $00
    ld a, [currentLevelBank]
    inc a
    ld [$c418], a
    ld a, [$d09e]
    and a
    jr z, jr_002_4029
        ld e, a
        xor a
        ld [$c474], a
        ld [$c475], a
        ld [$d09e], a
        ld a, $ff
        ld hl, $c466
        ld [hl+], a
        ld [hl+], a
        ld [hl], a
        ld hl, $d05d
        ld [hl+], a
        ld [hl+], a
        ld [hl+], a
        ld [hl], a
    jr_002_4029:

    ld a, [$c465]
    and a
    jr z, jr_002_4063

    cp $02
    jr z, jr_002_4039

    ld a, e
    and a
    jr z, jr_002_4063

    jr jr_002_404b

jr_002_4039:
    ld hl, $c41b
    ld a, [hl]
    cp $90
    jr z, jr_002_404b

    ld a, [frameCounter]
    and $01
    jr nz, jr_002_4063

    inc [hl]
    jr jr_002_4063

jr_002_404b:
    ld a, [metroidCountReal]
    and a
    jr z, jr_002_4059
        ; Resume music unless all metroids are dead
        ld a, [currentRoomSong]
        add $11
        ld [songRequest], a
    jr_002_4059:

    xor a
    ld [$c41b], a
    ld [$c41c], a
    ld [$c465], a

jr_002_4063:
    ld a, [enemySolidityIndex_canon]
    ld [enemySolidityIndex], a
    ld hl, $c44b
    ld a, [hl]
    and a
    jr z, jr_002_4077
        call Call_002_418c ; Save and then load enemy spawn/save flags
        xor a
        ld [$c44b], a
    jr_002_4077:

    ld a, [rLY]
    cp $70
    ret nc

    ld a, [$c436]
    and a
    jr nz, jr_002_408b
        call Call_002_412f ; Load enemy save flags without saving them
        ld a, $01
        ld [$c436], a
    jr_002_408b:

    call $3dba
    call Call_002_409e
    call Call_002_45ca
    ld a, [rLY]
    cp $70
        ret nc

    call $3dce
ret


Call_002_409e:
    ld de, $0020
    ld a, [$c452]
    ld l, a
    ld a, [$c453]
    ld h, a
    ld a, [$c438]
    and a
    jr nz, jr_002_40ba
        ldh a, [hEnemy_frameCounter]
        inc a
        ldh [hEnemy_frameCounter], a
        ld a, [$c425]
        ld [$c439], a
    jr_002_40ba:

    ld a, [$c439]
    and a
    jp z, Jump_002_4110

jr_002_40c1:
    ld a, [hl]
    and $0f
    jr z, jr_002_40cc

    dec a
    jr z, jr_002_40f6

jr_002_40c9:
    add hl, de
    jr jr_002_40c1

jr_002_40cc:
    call Call_002_43d2
    call Call_002_4239
    call Call_002_452e
    call Call_002_5630

Jump_002_40d8:
jr_002_40d8:
    call Call_002_4421
    ld a, [$c439]
    dec a
    ld [$c439], a
    jr z, jr_002_4110

    ld de, $0020
    ldh a, [$fc]
    ld l, a
    ldh a, [$fd]
    ld h, a
    ld a, [rLY]
    cp $58
    jr nc, jr_002_4101

    jr jr_002_40c9

jr_002_40f6:
    call Call_002_43d2
    call Call_002_4464
    call Call_002_44c0
    jr jr_002_40d8

jr_002_4101:
    add hl, de
    ld a, l
    ld [$c452], a
    ld a, h
    ld [$c453], a
    ld hl, $c438
    inc [hl]
    jr jr_002_4125

Jump_002_4110:
jr_002_4110:
    xor a
    ld [$c452], a
    ld a, $c6
    ld [$c453], a
    ld hl, $c438
    ld a, [hl]
    and a
    jr z, jr_002_4124

    xor a
    ld [hl], a
    jr jr_002_4125

jr_002_4124:
    inc [hl]

jr_002_4125:
    ld a, [rLY]
    cp $6c
    ret nc

    call $3de2
ret


Call_002_412f: ; Loads enemy save flags from save buffer to WRAM without saving the previous set of flags to the save buffer
    ld d, $00
    ld a, [currentLevelBank]
    ld [previousLevelBank], a
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

    jr_002_4149: ; Load enemySaveFlags from buffer
        ld a, [hl+]
        ld [de], a
        inc e
        dec b
    jr nz, jr_002_4149

    ld a, $c6
    ld [$c453], a
    xor a
    ld [$c452], a
    ld [$c41c], a
    ld [$c465], a
    ld [$c463], a
    ld [$c425], a
    ld [$c426], a
    ld [$c427], a
    ld [$c438], a
    ld a, $ff
    ld [$c466], a
    ld [$c467], a
    ld [$c468], a
    ld [$c46d], a
    ld hl, $c432
    ld a, [$c205]
    ld [hl+], a
    ld [hl+], a
    ld a, [$c206]
    ld [hl+], a
    ld [hl], a
    call Call_002_4db1
ret


Call_002_418c:
    ; Clear first $40 enemy spawn flags
    ld hl, enemySpawnFlags
    ld b, $40
    ld a, $ff
    jr_002_4193:
        ld [hl+], a
        dec b
    jr nz, jr_002_4193

    ; Save the enemySaveFlags to the save buffer
    ld d, $00
    ld a, [currentLevelBank]
    ld c, a
    ld a, [previousLevelBank]
    and a
    jr z, jr_002_41ce
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
    
        jr_002_41b5:
            ld a, [de]
            cp $02
                jr z, jr_002_41c8        
            cp $fe
                jr z, jr_002_41c8
            cp $04
                jr z, jr_002_41c6
            cp $05
                jr nz, jr_002_41c9
        
            jr_002_41c6:
                ld a, $fe
            jr_002_41c8:
                ld [hl], a
            jr_002_41c9:
                inc l
                inc e
                dec b
        jr nz, jr_002_41b5
    jr_002_41ce:

    ld d, $00
    ld a, c
    ld [previousLevelBank], a ; Update previousLevelBank to current now that the enemySaveFlags are saved
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
    ; Copy enemySaveFlags from save buffer
    jr_002_41e6:
        ld a, [hl+]
        ld [de], a
        inc e
        dec b
    jr nz, jr_002_41e6

    xor a
    ld [$c452], a
    ld [$c439], a
    ld [$c438], a
    ld a, $c6
    ld [$c453], a
    ld a, $ff
    ld [$c466], a
    ld [$c467], a
    ld [$c468], a
    ld hl, $c432
    ld a, [$c205]
    ld [hl+], a
    ld [hl+], a
    ld a, [$c206]
    ld [hl+], a
    ld [hl], a
    call Call_002_4217
ret


Call_002_4217:
    ld a, $ff
    ld hl, $c600
    ld c, $20
    ld d, $10

    jr_002_4220:
        ld [hl], a
        add hl, bc
        dec d
    jr nz, jr_002_4220

    ld b, $16
    ld hl, $ffe0

    jr_002_422a: ; Clear enemy temps in HRAM
        ld [hl+], a
        dec b
    jr nz, jr_002_422a

    xor a
    ld hl, $c425
    ld b, $03

    jr_002_4234:
        ld [hl+], a
        dec b
    jr nz, jr_002_4234
ret


Call_002_4239:
    ld hl, $d05d
    ld a, [hl+]
    cp $ff
    ret z

    ldh a, [$fc]
    cp [hl]
    ret nz

    inc hl
    ldh a, [$fd]
    cp [hl]
    ret nz

    ldh a, [$ee]
    and a
        jp nz, Jump_002_438f
    ldh a, [hEnemyDropType]
    and a
        jr z, jr_002_42ce

    dec hl
    dec hl
    ld a, [hl]
    cp $10
        jp c, Jump_002_438f

    ldh a, [hEnemyDropType]
    dec a
        jr z, jr_002_426f

    dec a
        jr z, jr_002_4266

    jr jr_002_42a2

jr_002_4266:
    ld b, $20
    ld a, $17
    ld [sfxRequest_square1], a
    jr jr_002_4276

jr_002_426f:
    ld b, $05
    ld a, $0e
    ld [sfxRequest_square1], a

jr_002_4276:
    ld hl, samusCurHealthLow
    ld a, [hl]
    add b
    daa
    ld [hl+], a
    ld a, [hl]
    adc $00
    ld [hl], a
    ld a, [samusEnergyTanks]
    sub [hl]
    jr nc, jr_002_428b

    dec [hl]
    dec hl
    ld [hl], $99

jr_002_428b:
    call $3ca6
    ld a, $02
    ldh [hEnemySpawnFlag], a
    call Call_002_438f
    ld hl, $c466
    ld a, $ff
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    pop af
    jp Jump_002_40d8


jr_002_42a2:
    ld a, $0c
    ld [sfxRequest_square1], a
    ld hl, samusCurMissilesLow
    ld a, [hl]
    add $05
    daa
    ld [hl+], a
    ld a, [hl]
    adc $00
    ld [hl], a
    ld a, [samusMaxMissilesHigh]
    sub [hl]
    jr c, jr_002_42c4

    jr nz, jr_002_428b

    dec hl
    ld a, [samusMaxMissilesLow]
    sub [hl]
    jr nc, jr_002_428b

    jr jr_002_42c8

jr_002_42c4:
    ld a, [samusMaxMissilesHigh]
    ld [hl-], a

jr_002_42c8:
    ld a, [samusMaxMissilesLow]
    ld [hl], a
    jr jr_002_428b

jr_002_42ce:
    ldh a, [hEnemySpriteType]
    cp $a0
    jr c, jr_002_42d9

    cp $d0
    jp c, Jump_002_438f

jr_002_42d9:
    dec hl
    dec hl
    ld a, [hl]
    cp $10
    jr z, jr_002_433b

    jp nc, Jump_002_438f

    cp $01
    jr nz, jr_002_4314

    ld hl, hEnemyHealth
    ld a, [hl]
    and a
        jr z, jr_002_434c ; if health == $00
    inc a
        jr z, jr_002_4345 ; if health == $FF
    inc a
        jr z, jr_002_430d ; if health == $FE

    call Call_002_43a9
    dec [hl]
        jr z, jr_002_42fb

    dec [hl]

jr_002_42fb:
    ld a, $01
    ld [sfxRequest_noise], a

jr_002_4300:
    ld hl, hEnemyStunCounter
    ld [hl], $10
    ld hl, hEnemyIceCounter
    ld [hl], $01
    jp Jump_002_438f


jr_002_430d:
    ld a, $0f
    ld [sfxRequest_square1], a
    jr jr_002_4300

jr_002_4314:
    ld e, a
    ld d, $00
    ld hl, $43c8
    add hl, de
    call Call_002_43a9
    ldh a, [hEnemyHealth]
    cp $fe
    jr nc, jr_002_4345

    sub [hl]
    jr z, jr_002_434c

    jr c, jr_002_434c

    ldh [hEnemyHealth], a
    ld a, $01
    ld [sfxRequest_noise], a
    call Call_002_438f
    ld a, $11
    ldh [hEnemyStunCounter], a
    pop af
    jp Jump_002_40d8


jr_002_433b:
    ldh a, [hEnemyHealth]
    cp $ff
    jr z, jr_002_4345

    ld b, $20
    jr jr_002_434e

Jump_002_4345:
jr_002_4345:
    ld a, $0f
    ld [sfxRequest_square1], a
    jr jr_002_438f

jr_002_434c:
    ; Prep explosion flag and determine drop
    ld b, $10

jr_002_434e:
    ldh a, [hEnemySpawnFlag]
    cp $06
        jr z, jr_002_436e

    and $0f
        jr z, jr_002_436e

    ldh a, [$f5]
    cp $fd
        jr z, jr_002_4374
    cp $fe
        jr z, jr_002_4374
    bit 0, a
        jr z, jr_002_4372
    cp $0a
        jr c, jr_002_436e

    set 1, b
        jr jr_002_4374
jr_002_436e:
    set 0, b
        jr jr_002_4374

jr_002_4372:
    set 2, b

jr_002_4374:
    ld a, b
    ldh [$ee], a
    
    xor a
    ldh [$e9], a
    ld a, $02
    ld [sfxRequest_noise], a

jr_002_437f:
    call Call_002_438f
    pop af
    jp Jump_002_40d8


    call $3ca6
    ld a, $ff
    ldh [hEnemySpawnFlag], a
    jr jr_002_437f

Call_002_438f:
Jump_002_438f:
jr_002_438f:
    ld hl, $d05d
    ld a, [hl+]
    ld [$c466], a
    ld a, [hl+]
    ld [$c467], a
    ld a, [hl+]
    ld [$c468], a
    ld a, [hl]
    ld [$c469], a
    ld a, $ff
    ld [hl-], a
    ld [hl-], a
    ld [hl-], a
    ld [hl], a
    ret


Call_002_43a9:
    ld a, [$d05d]
    cp $02
    ret z

    ld c, a
    ldh a, [$e8]
    and $f0
    ret z

    swap a
    ld b, a
    ld a, [$d060]

jr_002_43bb:
    rrc b
    srl a
    jr nc, jr_002_43bb

    bit 7, b
    ret z

    pop af
    jp Jump_002_4345


    db $01

    ld [bc], a

    db $04, $08, $1e

    nop
    nop
    ld [bc], a
    inc d
    ld a, [bc]

Call_002_43d2:
    ld a, l
    ldh [$fc], a
    ld a, h
    ldh [$fd], a
    ld b, $0f
    ld de, $ffe0

    jr_002_43dd:
        ld a, [hl+]
        ld [de], a
        inc e
        dec b
    jr nz, jr_002_43dd

    ld a, [hl+] ; enemyOffset + $0F
    ldh [$f3], a
    ld a, [hl+] ; enemyOffset + $10
    ldh [$f4], a
    ld a, [hl] ; enemyOffset + $11
    ldh [$f5], a
    
    ; Load spawn flag, spawn number, and AI pointer to $FFEF-$FFF2
    ldh a, [$fc]
    add $1c
    ld l, a
    ld b, $04
    jr_002_43f3:
        ld a, [hl+]
        ld [de], a
        inc e
        dec b
    jr nz, jr_002_43f3

    ldh a, [hEnemyYPos]
    ld [$c41e], a
    ldh a, [hEnemyXPos]
    ld [$c41f], a
    ldh a, [hEnemyStunCounter]
    cp $11
        ret c

    inc a
    ldh [hEnemyStunCounter], a
    cp $14
    jr z, jr_002_4413

    pop af
    jp Jump_002_40d8


jr_002_4413:
    ldh a, [hEnemyIceCounter]
    and a
    jr nz, jr_002_441c
        xor a
        ldh [hEnemyStunCounter], a
        ret
    jr_002_441c:
        ld a, $10
        ldh [hEnemyStunCounter], a
        ret


Call_002_4421:
    ld b, $0f
    ld de, $ffe0
    ldh a, [$fc]
    ld l, a
    ldh a, [$fd]
    ld h, a

    jr_002_442c:
        ld a, [de]
        ld [hl+], a
        inc e
        dec b
    jr nz, jr_002_442c

    ldh a, [$f3]
    ld [hl+], a
    ldh a, [$f4]
    ld [hl+], a
    ldh a, [$fc]
    add $1c
    ld l, a
    ld a, [de]
    ld [hl+], a
    
    inc e
    ld a, [de]
    ld [hl+], a
    ld b, a
    ldh a, [$f1]
    ld [hl+], a
    ldh a, [$f2]
    ld [hl], a
    
    ld hl, enemySpawnFlags
    ld l, b
    dec e
    ld a, [de]
    ld [hl], a
    ldh a, [$fc]
    ld l, a
    ldh a, [$fd]
    ld h, a
    ld a, [hl]
    cp $ff
    ret nz

    ld a, l
    add $1c
    ld l, a
    ld [hl], $ff
    inc l
    ld [hl], $ff
    ret


Call_002_4464:
    ld hl, $fff3
    ld a, [hl+]
    cp $fe
    jr z, jr_002_4470

    cp $03
    jr nz, jr_002_44b6

jr_002_4470:
    ld hl, $ffe0
    ld a, $ff
    ld b, $0f

jr_002_4477:
    ld [hl+], a
    dec b
    jr nz, jr_002_4477

    ld a, [hl]
    cp $02
    jr z, jr_002_448e

    cp $04
    jr nz, jr_002_448b

    ld a, $fe
    ld [hl], a
    ld a, $ff
    jr jr_002_448e

jr_002_448b:
    ld a, $ff
    ld [hl], a

jr_002_448e:
    inc l
    inc l
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    ld hl, $c425
    dec [hl]
    inc l
    inc l
    dec [hl]
    ld hl, $c468
    ld de, $fffd
    ld a, [de]
    cp [hl]
    jr nz, jr_002_44b2

    dec e
    dec l
    ld a, [de]
    cp [hl]
    jr nz, jr_002_44b2

    dec l
    ld a, $ff
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld [hl], a

jr_002_44b2:
    pop af
    jp Jump_002_40d8


jr_002_44b6:
    ld a, [hl]
    cp $fe
    jr z, jr_002_4470

    cp $03
    ret nz

    jr jr_002_4470

Call_002_44c0:
    ld hl, $fff3
    ld de, hEnemyYPos
    ld a, [hl]
    cp $ff
    jr z, jr_002_44d9

    and a
    jr z, jr_002_44e1

    dec a
    jr nz, jr_002_44ee

    ld a, [de]
    cp $c0
    jr nc, jr_002_44ee

jr_002_44d6:
    dec [hl]
    jr jr_002_44ee

jr_002_44d9:
    ld a, [de]
    cp $f0
    jr c, jr_002_44ee

jr_002_44de:
    inc [hl]
    jr jr_002_44ee

jr_002_44e1:
    ld a, [de]
    cp $c0
    jr c, jr_002_44ee

    cp $d8
    jr c, jr_002_44de

    cp $f0
    jr c, jr_002_44d6

jr_002_44ee:
    inc l
    inc e
    ld a, [hl]
    cp $ff
    jr z, jr_002_4503

    and a
    jr z, jr_002_450b

    dec a
    jr nz, jr_002_4518

    ld a, [de]
    cp $c0
    jr nc, jr_002_4518

jr_002_4500:
    dec [hl]
    jr jr_002_4518

jr_002_4503:
    ld a, [de]
    cp $f0
    jr c, jr_002_4518

jr_002_4508:
    inc [hl]
    jr jr_002_4518

jr_002_450b:
    ld a, [de]
    cp $c0
    jr c, jr_002_4518

    cp $d8
    jr c, jr_002_4508

    cp $f0
    jr c, jr_002_4500

jr_002_4518:
    ldh a, [$f3]
    ld b, a
    ldh a, [$f4]
    or b
    ret nz

    ld hl, $ffe0
    ld [hl], $00
    ld hl, $c426
    inc [hl]
    inc l
    dec [hl]
    pop af
    jp Jump_002_40d8


Call_002_452e:
    xor a
    ld [$c479], a
    ld hl, hEnemyYPos
    ld a, [hl+]
    cp $c0
    jr c, jr_002_4551

    cp $d8
    jr c, jr_002_4548

    cp $f0
    jr nc, jr_002_4551

    ld a, $ff
    ldh [$f3], a
    jr jr_002_454c

jr_002_4548:
    ld a, $01
    ldh [$f3], a

jr_002_454c:
    ld a, $01
    ld [$c479], a

jr_002_4551:
    ld a, [hl]
    cp $c0
    jr c, jr_002_456d

    cp $d8
    jr c, jr_002_4564

    cp $f0
    jr nc, jr_002_456d

    ld a, $ff
    ldh [$f4], a
    jr jr_002_4568

jr_002_4564:
    ld a, $01
    ldh [$f4], a

jr_002_4568:
    ld a, $01
    ld [$c479], a

jr_002_456d:
    ld a, [$c479]
    and a
    ret z

    ld hl, $ffe0
    ld [hl], $01
    ldh a, [hEnemySpawnFlag]
    cp $02
    jr z, jr_002_459d

    cp $06
    jr z, jr_002_45a8

    and $0f
    jr z, jr_002_45a8

    ld hl, $c426
    dec [hl]
    inc l
    inc [hl]
    ldh a, [hEnemySpawnFlag]
    cp $03
    jr z, jr_002_45c2

    cp $04
    jr z, jr_002_45b3

    cp $05
    jr z, jr_002_45b3

    pop af
    jp Jump_002_40d8


jr_002_459d:
    call $3ca6
    ld a, $02
    ldh [hEnemySpawnFlag], a
    pop af
    jp Jump_002_40d8


jr_002_45a8:
    call $3ca6
    ld a, $ff
    ldh [hEnemySpawnFlag], a
    pop af
    jp Jump_002_40d8


jr_002_45b3:
    ld a, $04
    ldh [hEnemySpawnFlag], a
    xor a
    ld [$c41b], a
    ld [$c41c], a
    pop af
    jp Jump_002_40d8


jr_002_45c2:
    ld a, $01
    ldh [hEnemySpawnFlag], a
    pop af
    jp Jump_002_40d8


Call_002_45ca:
    ld de, $c40a
    ld hl, $c408
    ld a, [de]
    ld [hl+], a
    inc e
    ld a, [de]
    ld [hl+], a
    inc e
    ld a, [de]
    ld [hl+], a
    inc e
    ld a, [de]
    ld [hl+], a
    ld de, $c205
    ld a, [de]
    ld [hl+], a
    inc e
    ld a, [de]
    ld [hl], a
    ret


    ld a, [$d03c]
    ld b, a
    ld hl, hEnemyXPos
    ld a, [hl]
    cp b
    jr nc, jr_002_45f4

    xor a
    ld [$c40e], a
    ret


jr_002_45f4:
    ld a, $02
    ld [$c40e], a
    ret


    ld hl, hEnemyAttr
    ldh a, [$e8]
    and a
    jr z, jr_002_4605
        ld [hl], $00
        ret
    jr_002_4605:
        ld [hl], OAMF_XFLIP
        ret
; end proc


; Beginning of apparent enemy tilemap collision routines
Call_002_4608:
    ld a, $11
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $03
    ld [$c44d], a
    ldh a, [hEnemyXPos]
    add $03
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44d]
    add $06
    ld [$c44d], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    jr jr_002_46a6

    ld a, $11
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $03
    ld [$c44d], a
    ldh a, [hEnemyXPos]
    add $07
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44d]
    add $06
    ld [$c44d], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    jr jr_002_46a6

Call_002_4662:
    ld a, $11
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $06
    ld [$c44d], a
    ldh a, [hEnemyXPos]
    add $07
    ld [$c44e], a
    call enemy_getTileIndex
    ld [$c417], a
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44d]
    add $06
    ld [$c44d], a
    call enemy_getTileIndex
    ld [$c417], a
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44d]
    add $06
    ld [$c44d], a
    call enemy_getTileIndex
    ld [$c417], a
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

jr_002_46a6:
    ld hl, en_bgCollisionResult
    res 0, [hl]
    ret


Call_002_46ac:
    ld a, $11
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $07
    ld [$c44d], a
    ldh a, [hEnemyXPos]
    add $0b
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44d]
    add $07
    ld [$c44d], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44d]
    add $07
    ld [$c44d], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    jr jr_002_46a6

    ld a, $11
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $0b
    ld [$c44d], a
    ldh a, [hEnemyXPos]
    add $07
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44d]
    add $08
    ld [$c44d], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44d]
    add $06
    ld [$c44d], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44d]
    add $08
    ld [$c44d], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    jr jr_002_47ae

Call_002_4736:
    ld a, $11
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $0b
    ld [$c44d], a
    ldh a, [hEnemyXPos]
    add $0b
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44d]
    add $08
    ld [$c44d], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44d]
    add $06
    ld [$c44d], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44d]
    add $08
    ld [$c44d], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    jr jr_002_47ae

Call_002_4783:
    ld a, $11
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $08
    ld [$c44d], a
    ldh a, [hEnemyXPos]
    add $07
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44d]
    add $0f
    ld [$c44d], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

jr_002_47ae:
    ld hl, en_bgCollisionResult
    res 0, [hl]
    ret


Call_002_47b4:
    ld a, $11
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $07
    ld [$c44d], a
    ldh a, [hEnemyXPos]
    add $07
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44d]
    add $0f
    ld [$c44d], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    jr jr_002_47ae

Call_002_47e1:
    ld a, $44
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $03
    ld [$c44d], a
    ldh a, [hEnemyXPos]
    sub $03
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44d]
    add $06
    ld [$c44d], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    jr jr_002_487f

    ld a, $44
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $03
    ld [$c44d], a
    ldh a, [hEnemyXPos]
    sub $07
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44d]
    add $06
    ld [$c44d], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    jr jr_002_487f

Call_002_483b:
    ld a, $44
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $06
    ld [$c44d], a
    ldh a, [hEnemyXPos]
    sub $07
    ld [$c44e], a
    call enemy_getTileIndex
    ld [$c417], a
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44d]
    add $06
    ld [$c44d], a
    call enemy_getTileIndex
    ld [$c417], a
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44d]
    add $06
    ld [$c44d], a
    call enemy_getTileIndex
    ld [$c417], a
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

jr_002_487f:
    ld hl, en_bgCollisionResult
    res 2, [hl]
    ret


Call_002_4885:
    ld a, $44
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $07
    ld [$c44d], a
    ldh a, [hEnemyXPos]
    sub $0b
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44d]
    add $07
    ld [$c44d], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44d]
    add $07
    ld [$c44d], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    jr jr_002_487f

    ld a, $44
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $0b
    ld [$c44d], a
    ldh a, [hEnemyXPos]
    sub $07
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44d]
    add $08
    ld [$c44d], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44d]
    add $06
    ld [$c44d], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44d]
    add $08
    ld [$c44d], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    jr jr_002_4987

Call_002_490f:
    ld a, $44
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $0b
    ld [$c44d], a
    ldh a, [hEnemyXPos]
    sub $0b
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44d]
    add $08
    ld [$c44d], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44d]
    add $06
    ld [$c44d], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44d]
    add $08
    ld [$c44d], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    jr jr_002_4987

Call_002_495c:
    ld a, $44
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $07
    ld [$c44d], a
    ldh a, [hEnemyXPos]
    sub $09
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44d]
    add $0f
    ld [$c44d], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

jr_002_4987:
    ld hl, en_bgCollisionResult
    res 2, [hl]
    ret


Call_002_498d:
    ld a, $44
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $08
    ld [$c44d], a
    ldh a, [hEnemyXPos]
    sub $09
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44d]
    add $0f
    ld [$c44d], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    jr jr_002_4987

Call_002_49ba:
    ld a, $22
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    add $03
    ld [$c44d], a
    ldh a, [hEnemyXPos]
    sub $03
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44e]
    add $06
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    jr jr_002_4a22

; 02:49E7 - Unused?
    ld a, $22
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    add $03
    ld [$c44d], a
    ldh a, [hEnemyXPos]
    sub $07
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44e]
    add $07
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44e]
    add $07
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

jr_002_4a22:
    ld hl, en_bgCollisionResult
    res 1, [hl]
ret


Call_002_4a28:
    ld a, $22
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    add $07
    ld [$c44d], a
    ldh a, [hEnemyXPos]
    sub $06
    ld [$c44e], a
    call enemy_getTileIndex
    ld [$c417], a
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44e]
    add $06
    ld [$c44e], a
    call enemy_getTileIndex
    ld [$c417], a
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44e]
    add $06
    ld [$c44e], a
    call enemy_getTileIndex
    ld [$c417], a
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    jr jr_002_4a22

    ld a, $22
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    add $07
    ld [$c44d], a
    ldh a, [hEnemyXPos]
    sub $0b
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44e]
    add $08
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44e]
    add $06
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44e]
    add $08
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    jr jr_002_4b11

Call_002_4abb:
    ld a, $22
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    add $0b
    ld [$c44d], a
    ldh a, [hEnemyXPos]
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    jr jr_002_4b11

Call_002_4ad6:
    ld a, $22
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    add $0b
    ld [$c44d], a
    ldh a, [hEnemyXPos]
    sub $07
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44e]
    add $07
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44e]
    add $07
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

jr_002_4b11:
    ld hl, en_bgCollisionResult
    res 1, [hl]
    ret


Call_002_4b17:
    ld a, $22
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    add $0b
    ld [$c44d], a
    ldh a, [hEnemyXPos]
    sub $0b
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44e]
    add $08
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44e]
    add $06
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44e]
    add $08
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    jr jr_002_4b11

Call_002_4b64:
    ld a, $22
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    add $08
    ld [$c44d], a
    ldh a, [hEnemyXPos]
    sub $08
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44e]
    add $0f
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    jr jr_002_4bbc

Call_002_4b91:
    ld a, $22
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    add $08
    ld [$c44d], a
    ldh a, [hEnemyXPos]
    sub $09
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44e]
    add $0f
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

jr_002_4bbc:
    ld hl, en_bgCollisionResult
    res 1, [hl]
    ret


Call_002_4bc2:
    ld a, $88
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $03
    ld [$c44d], a
    ldh a, [hEnemyXPos]
    sub $03
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44e]
    add $06
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    jr jr_002_4c2a

    ld a, $88
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $03
    ld [$c44d], a
    ldh a, [hEnemyXPos]
    sub $07
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44e]
    add $07
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44e]
    add $07
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

jr_002_4c2a:
    ld hl, en_bgCollisionResult
    res 3, [hl]
    ret


Call_002_4c30:
    ld a, $88
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $07
    ld [$c44d], a
    ldh a, [hEnemyXPos]
    sub $06
    ld [$c44e], a
    call enemy_getTileIndex
    ld [$c417], a
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44e]
    add $06
    ld [$c44e], a
    call enemy_getTileIndex
    ld [$c417], a
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44e]
    add $06
    ld [$c44e], a
    call enemy_getTileIndex
    ld [$c417], a
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    jr jr_002_4c2a

    ld a, $88
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $07
    ld [$c44d], a
    ldh a, [hEnemyXPos]
    sub $0b
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44e]
    add $08
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44e]
    add $06
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44e]
    add $08
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    jr jr_002_4cfe

    ld a, $88
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $0b
    ld [$c44d], a
    ldh a, [hEnemyXPos]
    sub $07
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44e]
    add $07
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44e]
    add $07
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

jr_002_4cfe:
    ld hl, en_bgCollisionResult
    res 3, [hl]
    ret


Call_002_4d04:
    ld a, $88
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $0b
    ld [$c44d], a
    ldh a, [hEnemyXPos]
    sub $0b
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44e]
    add $08
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44e]
    add $06
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44e]
    add $08
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    jr jr_002_4cfe

Call_002_4d51:
    ld a, $88
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $08
    ld [$c44d], a
    ld a, [$c41f]
    sub $09
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44e]
    add $0f
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    jr jr_002_4dab

Call_002_4d7f:
    ld a, $88
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $08
    ld [$c44d], a
    ld a, [$c41f]
    sub $08
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

    ld a, [$c44e]
    add $0f
    ld [$c44e], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
    ret c

jr_002_4dab:
    ld hl, en_bgCollisionResult
    res 3, [hl]
    ret

; End of apparent enemy tilemap collision routines

; Loads the Blob Thrower sprite and hitbox into RAM
Call_002_4db1:
    ld hl, blobThrowerSprite ;$4ffe
    ld de, spriteC300
    ld b, $3e

    jr_002_4db9:
        ld a, [hl+]
        ld [de], a
        inc de
        dec b
    jr nz, jr_002_4db9

    ld hl, blobThrowerHitbox
    ld de, hitboxC360
    ld b, $04

    jr_002_4dc7:
        ld a, [hl+]
        ld [de], a
        inc de
        dec b
    jr nz, jr_002_4dc7

    ld a, $00
    ld [$c380], a
ret

;------------------------------------------------------------------------------
; Item Orb and Item AI
;  Note: Orbs have even enemy IDs, items have odd enemy IDs
enAI_itemOrb: ; 02:4DD3
    ldh a, [hEnemySpriteType]
    bit 0, a ; Jump ahead if orb, not item
    jr z, .endIf_A
        ld a, [frameCounter]
        and $06
        jr nz, .endIf_A
            ldh a, [hEnemyStunCounter]
            xor $10
            ldh [hEnemyStunCounter], a
    .endIf_A:

    call Call_002_7da0 ; Get sprite collision results
    ld a, [$c46d]
    cp $ff
        ret z

    ld b, a
    ld [$d06f], a
    ldh a, [$fc]
    ld [$d070], a
    ldh a, [$fd]
    ld [$d071], a
    ; Branch ahead if not orb
    ldh a, [hEnemySpriteType]
    ld c, a
    bit 0, a
        jr nz, .branchItem

    ; Orb branch
    ; Check if orb got hit
    ld a, b
    cp $09
        ret z
    cp $10
        ret z
    cp $20
        ret z
    ; Request sound effect
    xor a
    ld [sfxRequest_square1], a
    ld a, $02
    ld [sfxRequest_noise], a
    ; Change orb into item
    ld a, c
    inc a
    ldh [hEnemySpriteType], a
ret

.branchItem:
    ld a, b
    cp $20
    jr z, .endIf_B
        cp $10
            ret nz
        ; Clear sound effect
        ld a, $ff
        ld [sfxRequest_square1], a
    .endIf_B:

    ld a, [itemCollectionFlag]
    and a
        jr nz, .checkIfDone

; Energy refill branch
    ld a, c
    cp $9b ; Jump ahead if not energy refill
        jr nz, .branchMissileRefill
    ; Return if at full health
    ld a, [samusCurHealthLow]
    cp $99
        jr nz, .getItemNum
    ld a, [samusEnergyTanks]
    ld b, a
    ld a, [samusCurHealthHigh]
    cp b
        jr nz, .getItemNum
ret

.branchMissileRefill:
    cp $9d ; Jump ahead if not missile refill
        jr nz, .getItemNum
    ; Return if at full missiles
    ld a, [samusCurMissilesLow]
    ld b, a
    ld a, [samusMaxMissilesLow]
    cp b
        jr nz, .getItemNum
    ld a, [samusCurMissilesHigh]
    ld b, a
    ld a, [samusMaxMissilesHigh]
    cp b
        ret z

.getItemNum:
    ; Converts the sprite type into the item type
    ; Formula is equivalent to (([enemy sprite ID] - 81h)/2) + 1
    ld a, c
    ld [temp_spriteType], a
    ld c, $01

    .loop:
        cp $81
            jr z, .break
        sub $02
        inc c
    jr .loop
    .break:

    ; Set item number being collected
    ld a, c
    ld [itemCollected], a
    
    ldh a, [hEnemyYPos]
    ld [$d094], a
    ldh a, [hEnemyXPos]
    ld [$d095], a
    ; Let game know that an item is being collected now
    ld a, $ff
    ld [itemCollectionFlag], a
ret

.checkIfDone:
    ld b, a
    ; Clear item collected (so we don't collect it multiple times)
    xor a
    ld [itemCollected], a
    ; return until handleItemPickup sets the itemCollectionFlag to $03
    ld a, b
    cp $ff
        ret z

    ; Clear item variables
    xor a
    ld [itemCollected], a
    ld [itemCollectionFlag], a
    ; Don't delete the refills
    ld a, [temp_spriteType]
    cp $9b ; Exit if energy refill
        ret z
    cp $9d ; Exit if missile refill
        ret z
    ; Delete the items
    call $3ca6 ; Delete self
    ld a, $02 ; Set collected flag
    ldh [hEnemySpawnFlag], a
ret

;------------------------------------------------------------------------------
; Blob Thrower AI (plant that spits out spores)
enAI_4EA1: ; 02:4EA1
    ld a, [frameCounter]
    and $0e
    jr nz, jr_002_4ec6

    ld de, $0004
    ld b, $03
    ld hl, $c312

jr_002_4eb0:
    ld a, [hl]
    xor $07
    ld [hl], a
    add hl, de
    dec b
    jr nz, jr_002_4eb0

    ld hl, $c322
    ld a, [hl]
    xor $0d
    ld [hl], a
    ld hl, $c32e
    ld a, [hl]
    xor $0d
    ld [hl], a

jr_002_4ec6:
    ld a, [$c381]
    and a
    jr z, jr_002_4ed1

    dec a
    ld [$c381], a
    ret


jr_002_4ed1:
    ld a, [$c382]
    and a
        jr z, jr_002_4ee2 ; case 0
    cp $01
        jr z, jr_002_4f40 ; case 1
    cp $02
        jr z, jr_002_4f56 ; case 2

    jp Jump_002_4fb9


jr_002_4ee2:
    ld de, $c300
    ld hl, table_503F
    ld a, $04
    call Call_002_4fd4
    
    ld hl, table_503F
    ld a, $01
    call Call_002_4fd4
    
    ld hl, table_5071
    ld a, $01
    call Call_002_4fd4
    
    ld hl, table_50A3
    ld a, $01
    call Call_002_4fd4
    ld hl, table_503F
    ld a, [$c380]
    ld e, a
    ld d, $00
    add hl, de

    ld de, hitboxC360
    ld a, [de]
    add [hl]
    ld [de], a
    ld a, [$c380]
    inc a
    ld [$c380], a
    cp $15
        ret nz

    ld hl, $c302
    ld de, $0004
    ld [hl], $df
    add hl, de
    ld [hl], $df
    add hl, de
    ld [hl], $e1
    add hl, de
    ld [hl], $e1
    ld hl, $c334
    ld [hl], $e8
    ld a, $04
    ld [$c381], a
    ld a, $01
    ld [$c382], a
    ret


jr_002_4f40:
    ld hl, $c302
    ld de, $0004
    ld [hl], $e2
    add hl, de
    ld [hl], $e2
    ld a, $04
    ld [$c381], a
    ld a, $02
    ld [$c382], a
    ret


jr_002_4f56:
    ld hl, $c302
    ld de, $0004
    ld [hl], $e3
    add hl, de
    ld [hl], $e3
    ld a, $40
    ld [$c381], a
    ld a, $03
    ld [$c382], a
    call Call_002_4f87
    ld de, header_50D5
    call Call_002_4f97
    ld de, header_50E2
    call Call_002_4f97
    ld de, header_50EF
    call Call_002_4f97
    ld de, header_50FC
    call Call_002_4f97
    ret


Call_002_4f87:
    ld a, [$d03c]
    ld b, a
    ldh a, [hEnemyXPos]
    cp b
    ld a, $00
    jr c, jr_002_4f93
        inc a
    jr_002_4f93:

    ld [$c386], a
ret


Call_002_4f97:
    call findFirstEmptyEnemySlot_longJump
    ld [hl], $00
    inc hl

    ldh a, [hEnemyYPos]
    sub $20
    ld [hl+], a

    ldh a, [hEnemyXPos]
    ld [hl+], a

    ld a, $06
    ld [$c477], a
    push hl
        call Call_002_7235
    pop hl
    ld de, $0004
    add hl, de

    ldh a, [hEnemyYPos]
    add $40
    ld [hl], a
ret


Jump_002_4fb9:
    ld hl, $c302
    ld de, $0004
    ld [hl], $dd
    add hl, de
    ld [hl], $dd
    add hl, de
    ld [hl], $de
    add hl, de
    ld [hl], $de
    ld hl, $c334
    ld [hl], $ff
    xor a
    ld [$c382], a
    ret


Call_002_4fd4:
    push de
    push af
    push hl
    ld a, [$c380]

jr_002_4fda:
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    cp $80
        jr z, jr_002_4ff1

    pop bc
    pop bc
    pop de
    jr_002_4fe6:
        ld a, [de]
        add [hl]
        ld [de], a
        inc de
        inc de
        inc de
        inc de
        dec b
    jr nz, jr_002_4fe6
ret

jr_002_4ff1:
    ld a, $30
    ld [$c381], a
    xor a
    ld [$c380], a
    pop hl
    push hl
jr jr_002_4fda

blobThrowerSprite: ; 02:4FFE
    db $F8, $00, $DD, $20
    db $F8, $F8, $DD, $00
    db $00, $00, $DE, $20
    db $00, $F8, $DE, $00
    db $08, $FC, $DB, $00
    db $08, $FC, $DB, $00
    db $08, $FC, $DB, $00
    db $08, $F4, $D6, $00
    db $08, $FC, $DA, $00
    db $08, $04, $D8, $00
    db $10, $F4, $D3, $00
    db $10, $FC, $D9, $00
    db $10, $04, $D5, $00
    db $FF, $F0, $E0, $00
    db $E8, $08, $E0, $20
    db $FF
blobThrowerHitbox: ; 02:503B
    db $FC, $18, $F8, $08

table_503F: ; 02:503F
    db $00, $FE, $FF, $FF, $FF, $FF, $FF, $FF, $FE, $FE, $FE, $FE, $FE, $FE, $FD, $FF
    db $00, $00, $00, $00, $00, $00, $02, $01, $00, $01, $01, $01, $01, $00, $01, $00
    db $02, $01, $01, $01, $01, $02, $00, $00, $01, $01, $01, $02, $01, $00, $02, $00
    db $00, $80
table_5071: ; 02:5071
    db $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FE, $FF, $FF, $FF, $FE, $FF, $00
    db $00, $00, $00, $00, $00, $00, $01, $00, $01, $02, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $01, $00, $01, $02, $00, $02, $00, $01, $01, $01, $01, $01, $01
    db $00, $80
table_50A3: ; 02:50A3
    db $00, $FF, $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $FF, $FF, $00
    db $00, $00, $00, $00, $00, $01, $00, $00, $01, $01, $00, $00, $00, $00, $00, $01
    db $00, $00, $00, $01, $00, $01, $00, $00, $00, $00, $01, $00, $00, $00, $01, $00
    db $00, $80
; Enemy headers for projectiles
header_50D5:
    db $9E, $00, $00, $00, $00, $00,
    dw table_53D7
    db $00, $02, $02
    dw enAI_536F
header_50E2:
    db $9E, $00, $00, $00, $00, $00
    dw table_5408
    db $00, $02, $03
    dw enAI_536F
header_50EF:
    db $9E, $00, $00, $00, $00, $00
    dw table_5437
    db $00, $02, $04
    dw enAI_536F
header_50FC:
    db $9E, $00, $00, $00, $00, $00
    dw table_5463
    db $00, $02, $05
    dw enAI_536F

;------------------------------------------------------------------------------
; Arachnus / Arachnus Orb
enAI_arachnus: ; 02:5109
    ldh a, [$e7]
    rst $28
        dw arachnus_511C
        dw arachnus_5152
        dw arachnus_51B9
        dw arachnus_51CE
        dw arachnus_51EC
        dw arachnus_51FB
        dw arachnus_526E
        dw enAI_NULL ;arachnus_5651

arachnus_511C:
    ld hl, $c390
    xor a
    ld b, $06

    jr_002_5122:
        ld [hl+], a
        dec b
    jr nz, jr_002_5122

    ld a, $06
    ld [$c394], a
    ld a, $ff
    ldh [hEnemyHealth], a
    call Call_002_7da0
    ld a, [$c46d]
    cp $ff
        ret z
    cp $09
        ret nc
    ld a, $76
    ldh [hEnemySpriteType], a

jr_002_513f:
    ld a, $05
    ld [$c392], a

Jump_002_5144:
    xor a
    ld [$c390], a
    ld a, $20

Jump_002_514a:
    ld [$c391], a
    ; Next state
    ld hl, $ffe7
    inc [hl]
ret

arachnus_5152:
    ld hl, table_52FC
    call Call_002_516e
        jr nz, jr_002_513f
    ld hl, hEnemyXPos
    ld a, [hl]
    add $01
    ld [hl], a

jr_002_5161:
    ld a, [frameCounter]
    and $06
        ret nz
    ldh a, [hEnemySpriteType]
    xor $01
    ldh [hEnemySpriteType], a
ret


Call_002_516e:
    ld a, [$c390]
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    ld b, a
    cp $80
    jr nz, jr_002_5180
        ld bc, $0380
        jr jr_002_5190
    jr_002_5180:
        cp $81
        jr nz, jr_002_5189
            ld bc, $0381
            jr jr_002_5190
        jr_002_5189:
            inc e
            ld a, e
            ld [$c390], a
            ld c, $00
    jr_002_5190:

    ldh a, [hEnemyYPos]
    add b
    ldh [hEnemyYPos], a
    ld a, c
    ld [$c393], a
    call Call_002_4a28
    ld a, [en_bgCollisionResult]
    and $02
    ret z

    ld a, [$c393]
    and a
    jr z, jr_002_51b6
        cp $81
        jr z, jr_002_51b6
            ld a, [$c390]
            inc a
            ld [$c390], a
            xor a
            and a
            ret
    jr_002_51b6:
    inc a
    and a
ret

arachnus_51B9:
    ld hl, table_5356

Jump_002_51bc:
    call Call_002_516e
    jr nz, jr_002_51c3
        jr jr_002_5161
    jr_002_51c3:

    ld a, $04
    ld [$c391], a
    ld hl, $ffe7
    ld [hl], $03
ret

arachnus_51CE:
    ld a, [$c391]
    and a
    jr z, jr_002_51da
        dec a
        ld [$c391], a
        jr jr_002_5161
    jr_002_51da:

    call Call_002_529a
    ldh a, [hEnemyYPos]
    sub $08
    ldh [hEnemyYPos], a
    ld a, $78

jr_002_51e5:
    ldh [hEnemySpriteType], a
    ld a, $04
    jp Jump_002_514a

arachnus_51EC:
    ld a, [$c391]
    and a
    jr z, jr_002_51f7
        dec a
        ld [$c391], a
        ret
    jr_002_51f7:

    ld a, $7a
    jr jr_002_51e5

arachnus_51FB:
    call Call_002_7da0
    ld a, [$c46d]
    cp $ff
    jr z, jr_002_521b
        cp $09
        jr nz, jr_002_521b
            ld a, $05
            ld [sfxRequest_noise], a
            ld a, $11
            ldh [hEnemyStunCounter], a
            ld a, [$c394]
            dec a
            ld [$c394], a
                jr z, jr_002_5256 ; Die
    jr_002_521b:

    ld a, [hInputPressed]
    and PADF_B
    jr nz, jr_002_5249
        call Call_002_529a
        ld a, [$c391]
        and a
        jr z, jr_002_5230
            dec a
            ld [$c391], a
            ret
        jr_002_5230:
    
        ; Spit fireball sprite
        ld a, $7a
        ldh [hEnemySpriteType], a
        ldh a, [hEnemySpawnFlag]
        cp $01
            ret nz
        ; Spawn projectile
        ld de, header_52D2
        call Call_002_52a6
        ld a, $79
        ldh [hEnemySpriteType], a
        ld a, $10
        ld [$c391], a
        ret
    jr_002_5249:
        ldh a, [hEnemyYPos]
        add $08
        ldh [hEnemyYPos], a
        ld a, $76
        ldh [hEnemySpriteType], a
        jp Jump_002_5144


jr_002_5256: ; Become Spring ball
    ld a, $0d
    ld [sfxRequest_noise], a
    ld hl, hEnemyHealth
    ld [hl], $ff
    ld a, $95
    ldh [hEnemySpriteType], a
    ld hl, $fff1
    ld de, enAI_itemOrb ;$4dd3
    ld [hl], e
    inc l
    ld [hl], d
ret

arachnus_526E:
    ldh a, [hEnemyAttr]
    and a
    jr z, jr_002_528c
        call Call_002_4662
        ld b, $01
        ld a, [en_bgCollisionResult]
        and $01
        jr z, jr_002_5281
            jr jr_002_5286
        jr_002_5281:
            ldh a, [hEnemyXPos]
            add b
            ldh [hEnemyXPos], a
        jr_002_5286:
            ld hl, table_532E
            jp Jump_002_51bc
    jr_002_528c:
    
    call Call_002_483b
    ld b, $ff
    ld a, [en_bgCollisionResult]
    and $04
    jr z, jr_002_5281
        jr jr_002_5286


Call_002_529a:
    call Call_002_4f87
    and a
    ld a, $20
    jr z, jr_002_52a3
        xor a
    jr_002_52a3:
    
    ldh [hEnemyAttr], a
ret


Call_002_52a6:
    call findFirstEmptyEnemySlot_longJump
    ld [hl], $00
    inc hl
    ldh a, [hEnemyYPos]
    add $fd
    ld [hl+], a
    ldh a, [hEnemyAttr]
    ld b, $18
    and a
    jr nz, jr_002_52ba
        ld b, $e8
    jr_002_52ba:
    
    ldh a, [hEnemyXPos]
    add b
    ld [hl+], a
    push hl
    call Call_002_6b21
    call Call_002_7235
    pop hl
    ld de, $0004
    add hl, de
    ldh a, [hEnemyAttr]
    ld [hl], a
    ld a, $03
    ldh [hEnemySpawnFlag], a
ret

header_52D2: ; 02:52D2 - Enemy header (arachnus projectile?)
    db $7b, $00, $00, $00, $00, $00, $00, $00, $00, $02, $02
    dw enAI_arachnusFireball

enAI_arachnusFireball: ; 02:52DF
    ld hl, hEnemyXPos
    ldh a, [$e7]
    and a
    ld b, $03
    jr nz, .endIf
        ld b, -3 ;$fd
    .endIf:

    ld a, [hl]
    add b
    ld [hl], a
    ld a, [frameCounter]
    and $06
        ret nz
    ldh a, [hEnemySpriteType]
    xor $07
    ldh [hEnemySpriteType], a
ret

    ret ; 02:52FB - Unreferenced

table_52FC: ; 02:52FC
    db $FF, $FE, $FE, $FE, $FF, $FF, $FE, $FF, $FE, $FE, $FE, $FF, $FF, $FF, $00, $00
    db $00, $00, $01, $00, $01, $01, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01
    db $01, $02, $02, $02, $02, $02, $02, $02, $02, $03, $03, $03, $03, $03, $03, $03
    db $00, $80
table_532E: ; 02:532E
    db $FC, $FD, $FD, $FD, $FE, $FE, $FD, $FE, $FE, $FE, $FE, $FF, $FE, $FF, $FE, $FF
    db $FF, $00, $00, $00, $00, $01, $01, $02, $01, $02, $01, $02, $02, $02, $02, $03
    db $02, $02, $03, $03, $03, $04, $00, $80
table_5356: ; 02:5356
    db $FD, $FE, $FE, $FE, $FF, $FF, $00, $FF, $FF, $00, $FF, $00, $00, $01, $00, $01
    db $01, $00, $01, $01, $02, $02, $02, $03, $81

;------------------------------------------------------------------------------
; Blob thrower projectile
enAI_536F: ; 02:536F
    ldh a, [hEnemy_frameCounter]
    ld b, a
    and $01
        ret nz

    ld a, b
    and $01
    jr nz, .endIf_A
        ldh a, [hEnemySpriteType]
        xor $01
        ldh [hEnemySpriteType], a
    .endIf_A:

    ; Load pointer to table
    ld hl, $ffe9
    ld e, [hl]
    inc l
    ld d, [hl]
    
    ; Check if at end of table
    ld a, [de]
    cp $80
        jr z, .done

;moveHorizontal
    ; Extract upper nybble
    ld a, [de]
    and $f0
    swap a
    ; Sign-extend if necessary (is the stored format sign-magnitude?)
    bit 3, a
    jr z, .endIf_B
        and $07
        cpl
        inc a
    .endIf_B:
    ; Save result
    ld b, a

    ; Negate if Samus is to the right side of the parent blob thrower
    ld a, [$c386]
    and a
    jr z, .endIf_C
        ld a, b
        cpl
        inc a
        ld b, a
    .endIf_C:

    ; Apply velocity
    ldh a, [hEnemyXPos]
    add b
    ldh [hEnemyXPos], a

;moveVertical    
    ; Extract lower nybble
    ld a, [de]
    and $0f
    ; Sign-extend if necessary
    bit 3, a
    jr z, .endIf_D
        and $07
        cpl
        inc a
    .endIf_D:
    ; Save result
    ld b, a
    ; Apply velocity
    ldh a, [hEnemyYPos]
    add b
    ldh [hEnemyYPos], a

    ; Increment and save movement table pointer
    inc de
    ld [hl], d
    dec l
    ld [hl], e
ret


.done:
    ; Clear unused (?) variable
    xor a
    ld [$c387], a
    ; Check if below threshold
    ldh a, [$e7]
    ld b, a
    ldh a, [hEnemyYPos]
    cp b
    jr nc, .else
        ; Move down
        inc a
        inc a
        ldh [hEnemyYPos], a
        ret
    .else:
        ; Delete self
        call $3ca6
        ld a, $ff
        ldh [hEnemySpawnFlag], a
        ret

; Bitpacked speed pairs?
table_53D7: ; 02:53D7
    db $19, $1A, $1A, $29, $28, $31, $32, $32, $33, $34, $34, $25, $89, $9B, $9B, $A9
    db $A8, $B1, $B2, $C2, $C3, $D4, $D4, $C5, $09, $1B, $1B, $29, $28, $31, $32, $42
    db $43, $54, $54, $45, $89, $9B, $9B, $A9, $A8, $B1, $B2, $C2, $C3, $D4, $D4, $C5
    db $80
table_5408: ; 02:5408
    db $09, $1A, $1A, $2A, $3A, $3A, $4A, $49, $58, $51, $89, $9B, $9B, $A9, $A8, $B1
    db $B2, $C2, $C3, $D4, $D4, $C5, $09, $1B, $1B, $29, $28, $31, $32, $42, $43, $54
    db $54, $45, $89, $9B, $9B, $A9, $A8, $B1, $B2, $C2, $C3, $D4, $D4, $C5, $80
table_5437: ; 02:5437
    db $19, $1A, $2B, $4B, $4A, $5A, $59, $09, $1B, $1B, $29, $28, $31, $32, $42, $43
    db $54, $54, $45, $89, $9B, $9B, $A9, $A8, $B1, $B2, $C2, $C3, $D4, $D4, $C5, $09
    db $1B, $1B, $29, $28, $31, $32, $42, $43, $54, $54, $45, $80
table_5463: ; 02:5463
    db $29, $39, $3A, $4A, $4B, $5B, $58, $6B, $09, $1B, $1B, $29, $28, $31, $32, $42
    db $43, $54, $54, $45, $89, $9B, $9B, $A9, $A8, $B1, $B2, $C2, $C3, $D4, $D4, $C5
    db $09, $1B, $1B, $29, $28, $31, $32, $42, $43, $54, $54, $45, $EB, $FA, $FA, $E9
    db $E9, $D8, $D8, $C1, $C1, $B2, $B2, $A3, $A3, $94, $94, $85, $85, $80

;------------------------------------------------------------------------------
; Glow Fly AI (thing that goes back and forth between walls)
enAI_glowFly: ; 02:54A1
    ; Move if state is non-zero
    ldh a, [hEnemyState]
    and a
        jr nz, .case_move
    ; Increment wait timer
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $50
        jr z, .case_launch
    cp $45
        jr z, .case_windUpFrame
    call .animateIdle
ret

.case_windUpFrame:
    ; Animate wind-up frame before movement
    ld a, $2e
    ldh [hEnemySpriteType], a
ret

.case_launch:
    ; Start launching off the wall
    ; Set sprite graphics
    ld a, $2e
    ldh [hEnemySpriteType], a
    ; Reset wait timer
    ld [hl], $00
    ; Set state to move
    ld a, $01
    ldh [hEnemyState], a
ret

.case_move:
    ; Set sprite type
    ld a, $2f
    ldh [hEnemySpriteType], a
    call .move
    call .tryFlip
ret

.move:
    ld hl, hEnemyXPos
    ; Check direction
    ldh a, [$e8]
    and a
    jr nz, .else_A
        ; Move right
        ld a, [hl]
        add $03
        ld [hl], a
        ret
    .else_A:
        ; Move left
        ld a, [hl]
        sub $03
        ld [hl], a
        ret
; end proc

.tryFlip:
    ldh a, [$e8]
    and a
        jr nz, .goingLeft

;goingRight
    call Call_002_4608
    ld a, [en_bgCollisionResult]
    bit 0, a
        ret z

.flip:
    ; Animate sprite
    ld a, $2c
    ldh [hEnemySpriteType], a
    ; Flip sprite (graphics)
    ld hl, hEnemyAttr
    ld a, [hl]
    xor OAMF_XFLIP
    ld [hl], a
    ; Flip sprite (logic)
    ld hl, $ffe8
    ld a, [hl]
    xor $01
    ld [hl], a
    ; Reset state
    xor a
    ldh [hEnemyState], a
ret

.goingLeft:
    call Call_002_47e1
    ld a, [en_bgCollisionResult]
    bit 2, a
        ret z
    jr .flip ; Unconditional jump (code below is orphaned)

; 02:5513 - Unreferenced/unused code?
    ; Perhaps meant to reset state?
    ld [hl], $00
    ; Flip sprite (logic)
    ld hl, $ffe8
    ld a, [hl]
    xor $01
    ld [hl], a
    ; Flip sprite (graphics)
    ld hl, hEnemyAttr
    ld a, [hl]
    xor OAMF_XFLIP
    ld [hl], a
    ; This unused branch doesn't animate the sprite
ret

.animateIdle:
    ; Execute every 8th frame
    ldh a, [hEnemy_frameCounter]
    and $07
        ret nz
    ; Looks like a really convoluted way of oscillating between $2C and $2D
    ldh a, [hEnemySpriteType]
    cp $2c
    jr nz, .else_B
        inc a
        ldh [hEnemySpriteType], a
        ret
    .else_B:
        ldh a, [hEnemySpriteType]
        cp $2d
        jr nz, .else_C
            dec a
            ldh [hEnemySpriteType], a
            ret
        .else_C:
            ld a, $2c
            ldh [hEnemySpriteType], a
            ret

;------------------------------------------------------------------------------
; Rock Icicle (discount skree)
enAI_rockIcicle: ; 02:5542
    ldh a, [hEnemyState] ; state
    cp $00
        jp z, .case_0
    cp $01
        jp z, .case_1
    cp $02
        jp z, .case_2
    cp $03
        jp z, .case_3
    cp $04
        jp z, .case_4
    cp $05
        jp z, .case_5
ret


.case_0:
    ; set the sprite ID
    ld a, $34
    ldh [hEnemySpriteType], a
    ; inc the animation counter
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    ; exit if counter < 0xB
    cp $0b
        ret c

    ; inc the state
    ldh a, [hEnemyState]
    inc a
    ldh [hEnemyState], a
    ; set the next sprite ID
    ld a, $35
    ldh [hEnemySpriteType], a
    ; clear the counter
    ld hl, $ffe9
    ld a, [hl]
    xor a
    ld [hl], a
ret


.case_1:
    ; inc the animation counter
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    ; exit if counter < 0x7
    cp $07
        ret c

    ; inc the state
    ldh a, [hEnemyState]
    inc a
    ldh [hEnemyState], a
    ; clear the animation counter
    ld hl, $ffe9
    ld a, [hl]
    xor a
    ld [hl], a
ret


.case_2:
    ldh a, [hEnemy_frameCounter]
    and $03 ; Act 1 out of 4 frames
        ret nz

    call .animate
    call .moveOnePixel
    cp $04 ; Move to next state after moving 4 pixels
        ret nz

    ld a, $36
    ldh [hEnemySpriteType], a
    ; inc to next state
    ldh a, [hEnemyState]
    inc a
    ldh [hEnemyState], a
ret

    ret ; Unreferenced return

.moveOnePixel:
    ; Move one pixel
    ld hl, hEnemyYPos
    ld a, [hl]
    inc a
    ld [hl], a
    ; Increment distance travelled
    ldh a, [$e7]
    inc a
    ldh [$e7], a
    ; Return distance travelled
    ldh a, [$e7]
ret


.case_4:
    call .animate
    ; inc animation counter
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $10 ; Wait until 16 frames have elapsed
        ret nz

    ; clear animation counter
    xor a
    ld [hl], a
    ; inc the state
    ldh a, [hEnemyState]
    inc a
    ldh [hEnemyState], a
ret


.case_3:
    call .animate
    ldh a, [hEnemy_frameCounter]
    and $05
        ret nz

    ; inc to next state
    ldh a, [hEnemyState]
    inc a
    ldh [hEnemyState], a
ret


.case_5: ; Falling
    call .animate
    ; Move enemy down
    ld hl, hEnemyYPos
    ld a, [hl]
    add $04
    ld [hl], a
    ; Increment distance travelled
    ldh a, [$e7]
    add $04
    ldh [$e7], a

    call Call_002_49ba ; Tilemap collision routine
    ld a, [en_bgCollisionResult]
    bit 1, a ; Bit 1 being set indicates a collision
    jr nz, .endIf_A
        ldh a, [hEnemyYPos]
        cp $a0
            ret c
        ; Reset back to home if it falls off the bottom of the screen
    .endIf_A:
    
    ; Play sound effect
    ld a, $11
    ld [sfxRequest_noise], a
    
    ; Return to home y-position
    ; yPos = yPos - distance travelled
    ld hl, $ffe7
    ld de, hEnemyYPos
    ld a, [de]
    sub [hl]
    ld [de], a

    xor a
    ldh [$e7], a ; Reset distance travelled
    ldh [hEnemyState], a ; Reset state to 0
    ld a, $34
    ldh [hEnemySpriteType], a
ret

.animate: ; Animates by flipping between sprites $36 and $37
    ldh a, [hEnemy_frameCounter]
    and $01
    ret nz

    ldh a, [hEnemySpriteType]
    cp $36
    jr nz, .endIf_B
        inc a
        ldh [hEnemySpriteType], a
            ret
    .endIf_B:
    
    ldh a, [hEnemySpriteType]
    cp $37
    jr nz, .endIf_C
        dec a
        ldh [hEnemySpriteType], a
            ret
    .endIf_C:
    
    ld a, $36
    ldh [hEnemySpriteType], a
ret

; End of the rock icicle's code
;------------------------------------------------------------------------------

Call_002_5630:
    ; Check if a drop
    ldh a, [hEnemyDropType]
    and a
        jr nz, jr_002_5692
    ; Check if exploding/becoming a drop
    ldh a, [$ee]
    and a
        jp nz, Jump_002_56bf
    ; Check if frozen
    ldh a, [hEnemyIceCounter]
    and a
        jr nz, jr_002_5652
    ; Check if metroid has been killed?
    ld a, [$c41c]
    cp $80
        jp z, Jump_002_5732

Jump_002_5648:
jr_002_5648:
    ld bc, hEnemyAI_high ;$fff2
    ld a, [bc]
    ld h, a
    dec c
    ld a, [bc]
    ld l, a
    jp hl ; Jump to enemy AI !!!

; Default AI stub
enAI_NULL: ; 02:5651
    ret


jr_002_5652:
    ; Check if sprite is a standard metroid
    ; (the standard metroid will call this on its own terms)
    ldh a, [hEnemySpriteType]
    cp $a0
        jr z, jr_002_5648
    sub $ce
        jr z, jr_002_5648
    dec a
        jr z, jr_002_5648

Call_002_565f:
    ldh a, [hEnemy_frameCounter]
    and $01
        ret nz
    ld hl, hEnemyIceCounter
    ld a, [hl]
    cp $c4
    inc [hl]
    inc [hl]
        ret c
    cp $d0
    jr nc, jr_002_5679
        ld hl, $ffe0
        ld a, [hl]
        xor $80
        ld [hl], a
        ret
    jr_002_5679:
        xor a
        ld [hl+], a
        ld a, [hl]
        and a
        jr z, jr_002_5685
            xor a
            ldh [hEnemyStunCounter], a
            ldh [$e0], a
            ret
        jr_002_5685:
            ld a, $02
            ld [sfxRequest_noise], a
            call $3ca6
            ld a, $02
            ldh [hEnemySpawnFlag], a
            ret

; Drop handler
jr_002_5692:
    ld hl, $ffe9
    ld a, [hl]
    inc [hl]
    cp $b0
    jr z, jr_002_56b3
        ; Have the drop pulsate more rapidly after $80 frames
        cp $80
        jr nc, jr_002_56a6
            ldh a, [hEnemy_frameCounter]
            and $03
                ret nz
            jr jr_002_56ab
        jr_002_56a6:
            ldh a, [hEnemy_frameCounter]
            and $01
                ret nz
        jr_002_56ab:
        ; Flip low bit of sprite type
        ld hl, hEnemySpriteType
        ld a, [hl]
        xor $01
        ld [hl], a
            ret
    jr_002_56b3:
        xor a
        ld [hl], a
        ldh [hEnemyDropType], a
        ; Die
        call $3ca6
        ld a, $02
        ldh [hEnemySpawnFlag], a
        ret
; end proc

; Explode
Jump_002_56bf:
    bit 5, a
        jr nz, jr_002_56cc
    ld b, $03
    cp $11
        jr z, jr_002_56da
    inc b
        jr jr_002_56da

jr_002_56cc:
    ld hl, $ffe9
    ld a, [hl]
    inc [hl]
    cp $06
        jr z, jr_002_56e7
    add $e2 ; Explosion type A
    ldh [hEnemySpriteType], a
ret

jr_002_56da:
    ld hl, $ffe9
    ld a, [hl]
    inc [hl]
    cp b
        jr z, jr_002_56e7
    add $e8 ; Explosion type b
    ldh [hEnemySpriteType], a
ret


jr_002_56e7:
    ldh a, [$f5]
    cp $fd
        jr z, jr_002_5727

    ; 50% chance of dropping nothing
    ld a, [rDIV]
    and $01
        jr nz, jr_002_571f

    ldh a, [$ee]
    and $0f
        jr z, jr_002_571f ; Case 0 - Nothing/default?
    dec a
        jr z, jr_002_5705 ; Case 1 - Small Health
    dec a
        jr z, jr_002_570a ; Case 2 - Large health

; Missile drop
    ld bc, $04ee
    jr jr_002_570f

jr_002_5705:
    ld bc, $01e0
    jr jr_002_570f

jr_002_570a:
    ld bc, $02ec
    jr jr_002_570f

jr_002_570f:
    ld a, b
    ldh [hEnemyDropType], a
    ld a, c
    ldh [hEnemySpriteType], a
    xor a
    ldh [hEnemyStunCounter], a
    ldh [hEnemyIceCounter], a
    ldh [$e9], a
    ldh [$ee], a
ret

jr_002_571f: ; Delete self
    call $3ca6
    ld a, $02
    ldh [hEnemySpawnFlag], a
    ret

jr_002_5727:
    xor a
    ldh [hEnemyStunCounter], a
    ldh [hEnemyIceCounter], a
    ldh [$ee], a
    inc a
    ldh [$e9], a
ret


; Metroid death branch?
Jump_002_5732:
    ldh a, [hEnemySpawnFlag]
    cp $06
        jr z, jr_002_57ab

    ; Explosion related stuff
    ldh a, [hEnemySpriteType]
    cp $e2
        jp c, Jump_002_5648
    cp $e8
        jp nc, Jump_002_5648

    ld hl, $c463
    ld a, [hl]
    and a
    jr nz, jr_002_5750
        ld [hl], $01
        call Call_002_57b3
    jr_002_5750:

    ld hl, $ffe9
    ld a, [hl]
    cp $06
    jr z, jr_002_575e

    add $e2
    ldh [hEnemySpriteType], a
    inc [hl]
    ret


jr_002_575e:
    ld [hl], $00
    ld hl, hEnemyState
    inc [hl]
    ld a, [hl]
    dec a
        jr z, jr_002_5785
    dec a
        jr z, jr_002_5790
    dec a
        jr z, jr_002_57a2

    ld a, $ff
    ld hl, $c466
    ld [hl+], a
    ld [hl+], a
    ld [hl], a
    call $3ca6
    ld a, $02
    ldh [hEnemySpawnFlag], a
    xor a
    ld [$c41c], a
    ld [$c463], a
    ret


jr_002_5785:
    ld hl, hEnemyXPos
    ld a, [hl]
    sub $10
    ld [hl], a
    call Call_002_57b3
    ret


jr_002_5790:
    ld hl, hEnemyYPos
    ld a, [hl]
    sub $10
    ld [hl], a

jr_002_5797:
    ld hl, hEnemyXPos
    ld a, [hl]
    add $10
    ld [hl], a
    call Call_002_57b3
    ret


jr_002_57a2:
    ld hl, hEnemyYPos
    ld a, [hl]
    add $10
    ld [hl], a
    jr jr_002_5797

jr_002_57ab:
    call $3ca6
    ld a, $ff
    ldh [hEnemySpawnFlag], a
    ret


Call_002_57b3:
    ld hl, hEnemyYPos
    ld a, [hl]
    cp $f0
        jr nc, jr_002_57d7
    cp $a0
        jr nc, jr_002_57d3
    cp $0a
        jr c, jr_002_57d7

jr_002_57c3:
    inc l
    ld a, [hl]
    cp $f0
        jr nc, jr_002_57d0
    cp $a0
        jr nc, jr_002_57db
    cp $0a
        ret nc

jr_002_57d0:
    ld [hl], $18
    ret


jr_002_57d3:
    ld [hl], $98
    jr jr_002_57c3

jr_002_57d7:
    ld [hl], $18
    jr jr_002_57c3

jr_002_57db:
    ld [hl], $98
    ret

;------------------------------------------------------------------------------
; Tsumuri/Needler/Moheek AI (crawlers)
; - Right facing variant
enAI_57DE:
    jr jr_002_5838

Jump_002_57e0:
jr_002_57e0:
    ld a, $ff
    ldh [$e9], a
        jr jr_002_57f5

jr_002_57e6:
    call Call_002_587e
    ldh a, [hEnemy_frameCounter]
    and $01
        ret nz
    ld hl, hEnemySpriteType
    call enemy_flipSpriteId
ret

jr_002_57f5:
    ldh a, [$e8]
    and a
        jr z, jr_002_580e ; State 0 - right?
    dec a                 
        jr z, jr_002_581c ; State 1 - down?
    dec a                 
        jr z, jr_002_582a ; State 2 - left?

; State 3 - up?
    call Call_002_4d51
    ld a, [en_bgCollisionResult]
    bit 3, a
        jr z, jr_002_57e6
    call Call_002_58b8
ret

jr_002_580e:
    call Call_002_4783
    ld a, [en_bgCollisionResult]
    bit 0, a
        jr z, jr_002_57e6
    call Call_002_58cc
ret

jr_002_581c:
    call Call_002_4b64
    ld a, [en_bgCollisionResult]
    bit 1, a
        jr z, jr_002_57e6
    call Call_002_5895
ret

jr_002_582a:
    call Call_002_495c
    ld a, [en_bgCollisionResult]
    bit 2, a
        jr z, jr_002_57e6
    call Call_002_58a7
ret


jr_002_5838:
    ldh a, [$e8]
    and a
        jr z, jr_002_5851 ; State 0 - right?
    dec a
        jr z, jr_002_5860 ; State 1 - down?
    dec a
        jr z, jr_002_586f ; State 2 - left?

; State 3 - up?
    call Call_002_4783
    ld a, [en_bgCollisionResult]
    bit 0, a
        jr nz, jr_002_57e0
    call Call_002_5895
ret

jr_002_5851:
    call Call_002_4b64
    ld a, [en_bgCollisionResult]
    bit 1, a
        jp nz, Jump_002_57e0
    call Call_002_58a7
ret

jr_002_5860:
    call Call_002_495c
    ld a, [en_bgCollisionResult]
    bit 2, a
        jp nz, Jump_002_57e0
    call Call_002_58b8
ret

jr_002_586f:
    call Call_002_4d51
    ld a, [en_bgCollisionResult]
    bit 3, a
        jp nz, Jump_002_57e0
    call Call_002_58cc
ret

; Shared movement subroutine
Call_002_587e:
    ld hl, hEnemyYPos
    ldh a, [$e8]
    and $0f
    cp $01
        jr z, jr_002_5893 ; case 1 - go down
    cp $03
        jr z, jr_002_5891 ; case 3 - go up
    ; x movement cases
    inc l
    and a
        jr z, jr_002_5893 ; case 0 - go right
    ; case 2 - go left
jr_002_5891:
    dec [hl]
    ret

jr_002_5893:
    inc [hl]
    ret

; Rotation (?) functions for the crawlers (shared)
Call_002_5895:
    ldh a, [$e8]
    and $f0
    ldh [$e8], a
    ld hl, hEnemySpriteType
    ld a, [hl]
    and $f0

jr_002_58a1:
    ld [hl+], a
    inc l
    ld a, $20
    ld [hl], a
ret

Call_002_58a7:
    ldh a, [$e8]
    and $f0
    inc a
    ldh [$e8], a
    ld hl, hEnemySpriteType
    ld a, [hl]
    and $f0
    add $02
    jr jr_002_58a1

Call_002_58b8:
    ldh a, [$e8]
    and $f0
    add $02
    ldh [$e8], a
    ld hl, hEnemySpriteType
    ld a, [hl]
    and $f0

jr_002_58c6:
    ld [hl+], a
    inc l
    ld a, $40
    ld [hl], a
    ret

Call_002_58cc:
    ldh a, [$e8]
    and $f0
    add $03
    ldh [$e8], a
    ld hl, hEnemySpriteType
    ld a, [hl]
    and $f0
    add $02
    jr jr_002_58c6

;------------------------------------------------------------------------------
; Tsumuri/Needler/Moheek AI (crawlers)
; - Left facing variant
enAI_58DE:
    jr jr_002_594b

Jump_002_58e0:
    ld a, $ff
    ldh [$e9], a
    jr jr_002_58f2

jr_002_58e6:
    call Call_002_587e
    ldh a, [hEnemy_frameCounter]
    and $01
        ret nz
    call enemy_flipSpriteId
ret


jr_002_58f2:
    ldh a, [$e8]
    and a
        jr z, jr_002_5912   ; State 0 - right?
    dec a                   
        jp z, Jump_002_5925 ; State 1 - down?
    dec a                   
        jp z, Jump_002_5938 ; State 2 - left?

; State 3 - up?
    call Call_002_4d7f
    ld a, [en_bgCollisionResult]
    bit 3, a
        jr z, jr_002_58e6
    call Call_002_5895
    ld hl, hEnemyAttr
    set OAMB_YFLIP, [hl]
ret

jr_002_5912:
    call Call_002_47b4
    ld a, [en_bgCollisionResult]
    bit 0, a
        jr z, jr_002_58e6
    call Call_002_58a7
    ld hl, hEnemyAttr
    res OAMB_XFLIP, [hl]
ret

Jump_002_5925:
    call Call_002_4b91
    ld a, [en_bgCollisionResult]
    bit 1, a
        jr z, jr_002_58e6
    call Call_002_58b8
    ld hl, hEnemyAttr
    res OAMB_YFLIP, [hl]
ret

Jump_002_5938:
    call Call_002_498d
    ld a, [en_bgCollisionResult]
    bit 2, a
        jr z, jr_002_58e6
    call Call_002_58cc
    ld hl, hEnemyAttr
    set OAMB_XFLIP, [hl]
ret

jr_002_594b:
    ldh a, [$e8]
    and a
        jr z, jr_002_596a ; State 0 - right?
    dec a                 
        jr z, jr_002_597e ; State 1 - down?
    dec a                 
        jr z, jr_002_5992 ; State 2 - left?

; State 3 - up?
    call Call_002_498d
    ld a, [en_bgCollisionResult]
    bit 2, a
        jp nz, Jump_002_58e0
    call Call_002_58b8
    ld hl, hEnemyAttr
    res OAMB_YFLIP, [hl]
ret

jr_002_596a:
    call Call_002_4d7f
    ld a, [en_bgCollisionResult]
    bit 3, a
        jp nz, Jump_002_58e0
    call Call_002_58cc
    ld hl, hEnemyAttr
    set OAMB_XFLIP, [hl]
ret

jr_002_597e:
    call Call_002_47b4
    ld a, [en_bgCollisionResult]
    bit 0, a
        jp nz, Jump_002_58e0
    call Call_002_5895
    ld hl, hEnemyAttr
    set OAMB_YFLIP, [hl]
ret

jr_002_5992:
    call Call_002_4b91
    ld a, [en_bgCollisionResult]
    bit 1, a
        jp nz, Jump_002_58e0
    call Call_002_58a7
    ld hl, hEnemyAttr
    res OAMB_XFLIP, [hl]
ret


;------------------------------------------------------------------------------
; Skreek projectile code
jr_002_59a6:
    ld hl, $ffe9
    dec [hl]
        jr z, jr_002_59bf
    ld hl, hEnemyXPos
    ld b, $02
    ldh a, [hEnemyAttr]
    bit OAMB_XFLIP, a
    jr nz, jr_002_59bb
        ld a, [hl]
        sub b
        ld [hl], a
        ret
    jr_002_59bb:
        ld a, [hl]
        add b
        ld [hl], a
        ret

jr_002_59bf:
    call $3ca6
    ld a, $ff
    ldh [hEnemySpawnFlag], a
ret

;------------------------------------------------------------------------------
; Skreek AI (bird faced things that jump out of lava and spit at samus)
enAI_59C7:
    ldh a, [hEnemySpawnFlag]
    and $0f
        jr z, jr_002_59a6

    call Call_002_5aa8
    ldh a, [$e9]
    dec a
        jr z, jr_002_5a28
    dec a
        jr z, jr_002_5a01
    dec a
        jr z, jr_002_5a0f

    ld hl, hEnemyState
    inc [hl]
    ld a, [hl]
    cp $10
        ret nz

    ld [hl], $00
    ld c, $00
    ld a, [$d03c]
    ld b, a
    ld hl, hEnemyXPos
    ld a, [hl]
    sub b
    jr nc, jr_002_59f6
        cpl
        inc a
        ld c, OAMF_XFLIP
    jr_002_59f6:

    cp $30
        ret nc
    ld a, c
    ldh [hEnemyAttr], a
    ld a, $01
    ldh [$e9], a
ret

jr_002_5a01:
    ldh a, [hEnemySpawnFlag]
    cp $03
        ret z
    ld a, $04
    ldh [hEnemySpriteType], a
    ld a, $03
    ldh [$e9], a
ret

jr_002_5a0f:
    ld hl, hEnemyState
    dec [hl]
    jr z, jr_002_5a24
        ld e, [hl]
        ld d, $00
        ld hl, $5a7d
        add hl, de
        ld b, [hl]
        ld hl, hEnemyYPos
        ld a, [hl]
        add b
        ld [hl], a
        ret
    jr_002_5a24:
        xor a
        ldh [$e9], a
        ret
; end proc

jr_002_5a28:
    ld hl, hEnemyState
    ld a, [hl]
    cp $21
    jr z, jr_002_5a40

    ld e, a
    ld d, $00
    inc [hl]
    ld hl, $5a7d
    add hl, de
    ld b, [hl]
    ld hl, hEnemyYPos
    ld a, [hl]
    sub b
    ld [hl], a
    ret


jr_002_5a40:
    ld a, $02
    ldh [$e9], a
    call findFirstEmptyEnemySlot_longJump
    xor a
    ld [hl+], a
    ldh a, [hEnemyYPos]
    ld [hl+], a
    ldh a, [hEnemyAttr]
    ld b, a
    bit OAMB_XFLIP, a
    jr nz, jr_002_5a59

    ldh a, [hEnemyXPos]
    sub $04
    jr jr_002_5a5d

jr_002_5a59:
    ldh a, [hEnemyXPos]
    add $04

jr_002_5a5d:
    ld [hl+], a
    ld a, $08
    ld [hl+], a
    ld a, $80
    ld [hl+], a
    ld a, b
    ld [hl+], a
    ld de, $5a9e
    call Call_002_6b21
    call Call_002_7231
    ld a, $03
    ldh [hEnemySpawnFlag], a
    ld a, $07
    ldh [hEnemySpriteType], a
    ld a, $12
    ld [sfxRequest_noise], a
    ret

; 02:5A7D
    db $00, $05, $05, $05, $04, $05, $03, $03, $02, $03, $03, $03, $02, $03, $03, $02
    db $02, $03, $02, $02, $00, $01, $01, $01, $00, $01, $01, $00, $00, $01, $00, $00
    db $00
; 02:5A9E
    db $00, $00, $00, $10, $00, $00, $ff, $07, $c7, $59

Call_002_5aa8:
    ldh a, [hEnemySpawnFlag]
    cp $03
    ret z

    ldh a, [hEnemy_frameCounter]
    and $03
    ret nz

    ld hl, hEnemySpriteType
    ld a, [hl]
    cp $06
    jr z, jr_002_5abc

    inc [hl]
    ret


jr_002_5abc:
    ld [hl], $04
    ret

;------------------------------------------------------------------------------
; 02:5ABF - small bug AI (enemy 12h)
; Yumbos, Meboids, Mumbos, Pincher Flies, Seerooks, and TPOs
; (TODO: verify they all actually use this)
; Uses spritemaps 12h and 13h
enAI_smallBug: ; 02:5ABF
    call enemy_flipSpriteId ; Animate
    call .act ; Act
ret

.act:
    ; Turn around when frame counter reaches $40
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $40 ; turnaround time
        jr z, .flip

    ; Move according to direction
    ld hl, hEnemyXPos
    ldh a, [hEnemyAttr]
    bit OAMB_XFLIP, a
        jr nz, .moveRight
    
    ; Move Left
    dec [hl]
ret

    .moveRight:
    inc [hl]
ret

    .flip:
    ld [hl], $00
    call enemy_flipHorizontal
ret
;------------------------------------------------------------------------------
; Drivel AI (acid-spitting bat)
enAI_drivel: ; 02:5AE2
    call .animate
    ldh a, [hEnemyState]
    and a
        jr nz, .tryShooting
    ; Randomly enter try-shooting state
    ld a, [rDIV]
    and $0f
        jr z, .startTryShooting
    ; Fallthrough to moving

.move:
    ld de, hEnemyYPos
    ld hl, .ySpeedTable
    ldh a, [$e9]
    ld c, a
    ld b, $00
    add hl, bc
    ld a, [hl]
    cp $80
        jr z, .flipDirection

    ; Check if negative
    bit 7, [hl]
    jr nz, .else_A
        ; If not, then add
        ld a, [de]
        add [hl]
        jr .endIf_A
    .else_A:
        ; else, negate and then subtract
        ld a, [hl]
        cpl
        inc a
        ld b, a
        ld a, [de]
        sub b
        ld b, $00
    .endIf_A:
    ; Store the result
    ld [de], a
    ; DE now points to xpos
    inc e
    ld hl, .xSpeedTable
    add hl, bc
    ldh a, [$e8]
    and a
        jr nz, .moveLeft
; move right
    ld a, [de]
    add [hl]
    ld [de], a
    ; inc counter
    ld hl, $ffe9
    inc [hl]
ret

.flipDirection:
    ; flip direction
    ldh a, [$e8]
    xor $02
    ldh [$e8], a
    ; Reset counter
    xor a
    ldh [$e9], a
ret

.moveLeft:
    ; move left
    ld a, [de]
    sub [hl]
    ld [de], a
    ; inc counter
    ld hl, $ffe9
    inc [hl]
ret

.startTryShooting:
    ; Set try shooting state
    ld a, $01
    ldh [hEnemyState], a
.tryShooting:
    ; abs(samusX_screen - enemyX)
    ld a, [$d03c]
    ld b, a
    ld hl, hEnemyXPos
    ld a, [hl]
    sub b
    jr nc, .endIf_B
        cpl
        inc a
    .endIf_B:
    ; If not within range, just move
    cp $30
        jr nc, .move
    ; else, shoot projectile
    ; Reset state
    ld hl, hEnemyState
    ld [hl], $00
    ; Spawn projectile
    call findFirstEmptyEnemySlot_longJump
    xor a
    ld [hl+], a
    ldh a, [hEnemyYPos]
    add $08
    ld [hl+], a
    ldh a, [hEnemyXPos]
    ld [hl+], a
    ld de, .header_5B6C
    call Call_002_6b21
    call Call_002_7235
    ; Causes drivel to animate, but not act (see .animate function below)
    ld a, $03
    ldh [hEnemySpawnFlag], a
ret

.header_5B6C: ; 02:5B6C
    db $0C, $80, $00, $00, $00, $00, $00, $00, $00, $01, $00
    dw enAI_drivelSpit
.ySpeedTable: ; 02:5B79
    db $01, $01, $01, $02, $03, $03, $03, $03, $03, $02, $02, $02, $02, $01, $01, $00
    db $00, $FF, $FE, $FD, $FC, $FA, $FD, $FE, $FE, $FE, $FE, $FE, $FF, $80
.xSpeedTable: ; 02:5B97
    db $00, $01, $00, $01, $01, $02, $01, $02, $02, $03, $02, $03, $04, $03, $03, $02
    db $04, $02, $05, $04, $05, $04, $01, $02, $01, $01, $00, $01, $00, $80

; Excellent spaghetti code
.animate: ; 02:5BB5
    ldh a, [hEnemySpawnFlag]
    ld hl, hEnemySpriteType
    ; Check if this enemy's projectile is onscreen
    cp $03
        jr z, .forceInaction
    ; Check timer so enemy does not animate for the first few frames of its swoop motion
    ldh a, [$e9]
    cp $0c
        jr nc, .nextFrame        
.resetAnimation:
    ld [hl], $09
    ret
    
.forceInaction:
    ; Pop the return address of the stack so the next ret instruction exits the enemy AI
    ; so the enemy animates, but does no other action while its projectile is onscreen
    pop af
.nextFrame:
    ; Animate every other frame
    ldh a, [hEnemy_frameCounter]
    and $01
        ret nz
    ; Loop back to start of animation if at the end
    ld a, [hl]
    cp $0b
        jr z, .resetAnimation
    ; Set next frame
    inc [hl]
ret

;--------------------------------------
; Drivel projectile code
enAI_drivelSpit: ; 02:5BD4
    ; Initial enemySpriteType is $0C
    ld hl, hEnemySpriteType
    ld a, [hl]
    cp $0e
        jr z, .fall  ; Jump if equal
        jr nc, .explode ; Jump if greater

; animate start
    ldh a, [hEnemy_frameCounter]
    and $03
        ret nz
    inc [hl]
ret

.fall: ; Fall
    ; Move
    ld hl, hEnemyYPos
    inc [hl]
    call enemy_accelForwards
    ; Check collision
    call Call_002_49ba
    ld a, [en_bgCollisionResult]
    bit 1, a
        ret z
    ; Ground has been hit, so move on to next state
    ld a, $0f
    ldh [hEnemySpriteType], a
    ld a, $11
    ld [sfxRequest_noise], a
ret

.explode:
    ; Execute every 4th frame
    ldh a, [hEnemy_frameCounter]
    and $03
        ret nz
    ; Animate explosion
    ; inc enemySpriteType
    inc [hl]
    ld a, [hl]
    cp $12
        ret c
    
    ; Get WRAM offset for parent creature
    ld h, $c6
    ldh a, [hEnemySpawnFlag]
    bit 4, a
    jr nz, .else_A
        add $1c
        ld l, a
        jr .endIf_A
    .else_A:
        add $0c
        ld l, a
        inc h
    .endIf_A:

    ; Check if parent enemy still exists
    ld a, [hl]
    cp $03
    jr nz, .endIf_B
        ; Tell it that this projectile is done
        ld a, $01
        ld [hl+], a
        ; Also update the spawn flag table accordingly
        ld a, [hl]
        ld hl, enemySpawnFlags
        ld l, a
        ld [hl], $01
    .endIf_B:

    ; Delete self
    call $3ca6
    ld a, $03
    ld [sfxRequest_noise], a
    ld a, $ff
    ldh [hEnemySpawnFlag], a
ret

;------------------------------------------------------------------------------
; Senjoo/Shirk AI (things that move in a diamond shaped loop)
enAI_senjooShirk: ; 02:5C36
    call .animate ; animate
    ; Get absolute value of distance between enemy and Samus
    ld a, [$d03c]
    ld b, a
    ld hl, hEnemyXPos
    ld a, [hl]
    sub b
    jr nc, .endIf_A
        cpl
        inc a
    .endIf_A:
    ; Prep HL for idle motion
    ld hl, $ffe7
    ; Do active motion if within $50 pixels
    cp $50
        jr c, .activeMotion
    ; else, do idle motion

;idleMotion: ; bob up and down
    ; Act every other frame
    ldh a, [hEnemy_frameCounter]
    and $01
        ret nz
        
    ld a, [hl]
    cp $0c
    jr z, .else_A
        ; Move down 8 frames at 2 px/frame
        ; Move up   4 frames at 4 px/frame
        cp $08
        jr nc, .else_B
            inc [hl] ; $FFE7
            ; Move down
            ld hl, hEnemyYPos
            ld a, [hl]
            add $02
            ld [hl], a
            ret
        .else_B:
            inc [hl] ; $FFE7
            ; Move up
            ld hl, hEnemyYPos
            ld a, [hl]
            sub $04
            ld [hl], a
            ret
    .else_A:
        ; Reset idle motion
        ldh a, [hEnemy_frameCounter]
        and $03
            ret nz
        ; Reset $FFE7
        ld [hl], $00
        ret

; go in a diamond pattern
.activeMotion:
    ld b, $10
    ld hl, hEnemyState
    ld a, [hl-]
    and a
        jr z, .case_downLeft ; case 0
    dec a
        jr z, .case_downRight ; case 1
    dec a
        jr z, .case_upRight ; case 2
    ; case 3 (default case)

; case_upLeft
    ; Check behavior counter
    ld a, [hl] ; HL = $FFE9
    cp b
        jr z, .resetState
    inc [hl]
    ; ypos - go up
    ld hl, hEnemyYPos
    dec [hl]
    dec [hl]
    ; xpos - go left
    inc l
    dec [hl]
    dec [hl]
ret

.resetState:
    xor a
    ld [hl+], a
    xor a
    ld [hl], a
ret

.case_downLeft:
    ; Check behavior counter
    ld a, [hl]
    cp b
        jr z, .nextState
    inc [hl]
    ; ypos - go down
    ld hl, hEnemyYPos
    inc [hl]
    inc [hl]
    ; xpos - go left
    inc l
    dec [hl]
    dec [hl]
ret

.nextState:
    ; reset behavior counter
    xor a
    ld [hl+], a
    ; inc hEnemyState
    ld a, [hl]
    inc a
    ld [hl], a
ret

.case_downRight:
    ; Check behavior counter
    ld a, [hl]
    cp b
        jr z, .nextState
    inc [hl]
    ; ypos - go down
    ld hl, hEnemyYPos
    inc [hl]
    inc [hl]
    ; xpox - go right
    inc l
    inc [hl]
    inc [hl]
ret

.case_upRight:
    ; Check behavior counter
    ld a, [hl]
    cp b
        jr z, .nextState
    inc [hl]
    ; ypos - go up
    ld hl, hEnemyYPos
    dec [hl]
    dec [hl]
    ; xpos - go right
    inc l
    inc [hl]
    inc [hl]
ret

.animate:
    ldh a, [hEnemy_frameCounter]
    and $01
        ret nz
    ld hl, hEnemySpriteType
    ld a, [hl]
    cp $63
    jr nc, .endIf_B
        ; Senjoo animation
        ld hl, hEnemyAttr
        ld a, [hl]
        xor OAMF_XFLIP
        ld [hl], a
        ret
    .endIf_B:
        ; Shirk animation
        xor $07
        ld [hl], a
        ret
; end proc

;------------------------------------------------------------------------------
; gullugg AI - Thing that flies in a circle
enAI_gullugg: ; 02:5CE0
    call .animate
    ; [$E9] appears to be an animation counter
    ld hl, $ffe9
    ld c, [hl]
    ld b, $00

    ; Read next value from a looping, $80-terminated table
    .loop:
        ld hl, .ySpeedTable_cw ; yPos table
        add hl, bc
        ld a, [hl]
        cp $80 
            jr nz, .break
    
        ; If the table gave us a value of $80, reset the counter try again at the beginning
        ld c, $00
        xor a
        ldh [$e9], a
    jr .loop

.break:
    ; Handle y movement
    ldh a, [hEnemyYPos]
    add [hl]
    ldh [hEnemyYPos], a
    ; Index the x speed table
    ld hl, .xSpeedTable_cw
    add hl, bc
    ; Handle x movement
    ldh a, [hEnemyXPos]
    add [hl]
    ldh [hEnemyXPos], a
    ; Increment the counter
    ld hl, $ffe9
    inc [hl]
ret

; Tables for counter-clockwise circular motion (unused)
.ySpeedTable_ccw: ; 02:5D0C
    db $01, $00, $01, $02, $01, $02, $03, $02, $03, $03, $04, $03, $04, $04, $03, $04
    db $04, $04, $03, $03, $04, $03, $02, $03, $02, $01, $02, $01, $00, $00, $00, $00
    db $FF, $FE, $FF, $FE, $FD, $FE, $FD, $FC, $FD, $FD, $FC, $FC, $FC, $FD, $FC, $FC
    db $FD, $FC, $FD, $FD, $FE, $FD, $FE, $FF, $FE, $FF, $00, $FF, $80
.xSpeedTable_ccw: ; 02:5D49
    db $FD, $FC, $FC, $FD, $FC, $FD, $FD, $FE, $FD, $FE, $FF, $FE, $FF, $00, $FF, $01
    db $00, $01, $02, $01, $02, $03, $02, $03, $03, $04, $03, $04, $04, $03, $04, $04
    db $04, $03, $03, $04, $03, $02, $03, $02, $01, $02, $01, $00, $00, $00, $00, $FF
    db $FE, $FF, $FE, $FD, $FE, $FD, $FC, $FD, $FD, $FC, $FC, $FC

; Tables for clockwise circle motion
.ySpeedTable_cw: ; 02:5D85
    db $01, $00, $01, $01, $01, $02, $02, $02, $02, $02, $03, $03, $03, $03, $02, $03
    db $03, $03, $03, $02, $03, $02, $02, $02, $02, $01, $01, $01, $00, $00, $00, $00
    db $ff, $ff, $ff, $fe, $fe, $fe, $fe, $fd, $fe, $fd, $fd, $fd, $fd, $fe, $fd, $fd
    db $fd, $fd, $fe, $fe, $fe, $fe, $fe, $ff, $ff, $ff, $00, $ff, $80
.xSpeedTable_cw: ; 02:5DC2
    db $02, $03, $03, $03, $03, $02, $02, $02, $02, $02, $01, $01, $01, $00, $01, $FF
    db $00, $FF, $FF, $FF, $FE, $FE, $FE, $FE, $FE, $FD, $FD, $FD, $FD, $FE, $FD, $FD
    db $FD, $FD, $FE, $FD, $FE, $FE, $FE, $FE, $FF, $FF, $FF, $00, $00, $00, $00, $01
    db $01, $01, $02, $02, $02, $02, $03, $02, $03, $03, $03, $03

.animate:
    ; Three-frame animation cycling from $D8->$D9->$DA->$D9, etc.
    ld hl, hEnemySpriteType
    ld a, [hl]
    cp $da
    jr z, .endIf
        inc [hl]
            ret
    .endIf:
    ld [hl], $d8
ret
; End of gullugg code
;------------------------------------------------------------------------------
; enemy octroll/chute leech
enAI_chuteLeech: ; 02:5E0B
    ldh a, [hEnemyState]
    dec a
        jr z, .case_ascend ; if state = 1
    dec a
        jr z, .case_descend ; if state = 2

    ; Fall-through case
    ; abs(samusX_screen - enemyX)
    ld a, [$d03c]
    ld b, a
    ld hl, hEnemyXPos
    ld a, [hl]
    sub b
    jr nc, .endIf_A ; a = -a (two's compliment negation)
        cpl
        inc a
    .endIf_A:

    ; Exit if not withing 5 blocks of distance
    cp $50
        ret nc

    ; state = 1
    ld a, $01
    ldh [hEnemyState], a
    ; Clear flip flag
    xor a
    ldh [hEnemyAttr], a
    ; Animate ascent
    ld hl, hEnemySpriteType
    ld a, [hl]
    cp $3e ; Check if an octroll
    jr nc, .else_A
        ld [hl], $1c ; Chute leech ascent pose
        ret
    .else_A:
        ld [hl], $3e
        ret
; end proc

.case_ascend:
    ; Animate if an octroll
    ldh a, [hEnemySpriteType]
    cp $3e
        call nc, Call_002_6b33

    ; Check if counter == $16
    ldh a, [$e9]
    cp $16
        jr z, .prepState2
    ; Ascend
    ld hl, hEnemyYPos
    ld a, [hl]
    sub $04
    ld [hl], a
    ; Increment counter
    ld hl, $ffe9
    inc [hl]
ret

.prepState2: ; Prep state 2
    ; Clear counter
    xor a
    ldh [$e9], a
    ; Go to state 2
    ld a, $02
    ldh [hEnemyState], a
    ; Animate
    ld hl, hEnemySpriteType
    ld a, [hl]
    cp $3e ; Check if not an octroll
    jr nc, .else_B
        ld [hl], $1d ; chute leech descent pose
        ret
    .else_B:
        ld [hl], $40
        ret
; end proc


.case_descend:
    ; Load x speed from table using animation counter
    ld hl, $ffe9
    ld c, [hl]
    ld b, $00
    ld hl, .xSpeedTable
    add hl, bc
    ld a, [hl]
    cp $80 ; speed table is $80-terminated
        jr nz, .descend

    ; Restart AI
    ; Reset counter
    xor a
    ldh [$e9], a
    ; Reset state
    ldh [hEnemyState], a
    ; Animate
    ld hl, hEnemySpriteType
    ld a, [hl]
    cp $3e ; Check if not octroll
        ret nc
    ld [hl], $1b
ret


.descend: ; Move down
    ; Handle flipping animation
    ; Check if flipped
    ldh a, [hEnemyAttr]
    and a
    jr nz, .else_C
        ; Check if not moving left
        bit 7, [hl]
            jr nz, .moveDown
        ; Increment a secondary counter
        ldh a, [$e7]
        inc a
        ldh [$e7], a
        cp $04 ; Hang in place for 4 frames
            ret nz
        ; Clear the secondary counter
        xor a
        ldh [$e7], a
        ; Flip the sprite horizontally
        ldh a, [hEnemyAttr]
        xor OAMF_XFLIP
        ldh [hEnemyAttr], a
            jr .moveDown
    
    .else_C:
        ; Check if not moving right
        bit 7, [hl]
            jr z, .moveDown
        ; Increment a secondary counter
        ldh a, [$e7]
        inc a
        ldh [$e7], a
        cp $04 ; Hang in place for 4 frames
            ret nz
        ; Clear the secondary counter
        xor a
        ldh [$e7], a
        ; Flip the sprite horizontally
        ldh a, [hEnemyAttr]
        xor OAMF_XFLIP
        ldh [hEnemyAttr], a

.moveDown:
    ; Handle x position
    ldh a, [hEnemyXPos]
    add [hl]
    ldh [hEnemyXPos], a
    ; Handle y position
    ld hl, .ySpeedTable
    add hl, bc
    ldh a, [hEnemyYPos]
    add [hl]
    ldh [hEnemyYPos], a
    ; Increment counter
    ld hl, $ffe9
    inc [hl]
ret

.xSpeedTable:
    db $ff, $ff, $fe, $fe, $ff, $ff, $02, $02, $02, $02, $03, $03, $02, $04, $02, $02
    db $fe, $fe, $fe, $fe, $fe, $fd, $fd, $fd, $fd, $fd, $fd, $fc, $fd, $fd, $fe, $02
    db $03, $02, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $04, $03, $04
    db $03, $02, $fe, $fd, $fd, $fd, $fd, $fc, $fc, $fc, $fc, $fd, $fb, $fd, $fc, $fb
    db $fc, $fc, $fd, $fd, $03, $03, $03, $02, $04, $03, $03, $03, $04, $02, $02, $80
.ySpeedTable:
    db $02, $02, $02, $01, $01, $00, $02, $01, $01, $01, $01, $01, $00, $01, $00, $00
    db $02, $02, $01, $02, $01, $02, $01, $01, $01, $01, $00, $01, $00, $01, $00, $02
    db $01, $02, $01, $01, $01, $01, $01, $01, $01, $01, $00, $01, $00, $01, $00, $01
    db $00, $00, $02, $03, $02, $02, $01, $02, $02, $01, $01, $02, $02, $01, $01, $00
    db $01, $01, $00, $00, $03, $02, $02, $01, $02, $02, $01, $01, $01, $01, $00

; End of octroll/chute leech code
;------------------------------------------------------------------------------
; pipe bug spawner
enAI_5F67:
    ldh a, [hEnemySpawnFlag]
    cp $03
        ret z

    cp $01
        jp nz, Jump_002_600a

    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $18
        ret c

    ld [hl], $00
    ld hl, $ffe7
    ld a, [hl]
    cp $0a
    jr c, jr_002_5f90
        ; Delete self?
        call $3ca6
        ; Play sound
        ld a, $14
        ld [sfxRequest_square1], a
        ld a, $02
        ldh [hEnemySpawnFlag], a
            ret
    jr_002_5f90:

    ; Load in new pipe bug
    inc [hl]
    call findFirstEmptyEnemySlot_longJump ; Get first unused slot
    xor a
    ld [hl+], a
    ldh a, [hEnemyYPos]
    ld [hl+], a
    ldh a, [hEnemyXPos]
    ld [hl+], a
    ldh a, [hEnemySpriteType]
    cp $3c
    jr nc, jr_002_5fa6
        ld a, $17
        jr jr_002_5fa8
    jr_002_5fa6:
        ld a, $38
    jr_002_5fa8:

    ld [hl+], a
    ld de, pipeBugHeader ;$5fff
    ld b, $09

    jr_002_5fae:
        ld a, [de]
        ld [hl+], a
        inc de
        dec b
    jr nz, jr_002_5fae

    ld c, a
    xor a
    ld b, $04

    jr_002_5fb8:
        ld [hl+], a
        dec b
    jr nz, jr_002_5fb8

    ld [hl], c
    ld a, l
    add $0b
    ld l, a
    ldh a, [$fd]
    cp $c6
    jr nz, jr_002_5fcb
        ldh a, [$fc]
        jr jr_002_5fcf
    jr_002_5fcb:
        ldh a, [$fc]
        add $10
    jr_002_5fcf:

    ld [hl+], a
    ld [$c477], a
    ldh a, [hEnemySpriteType]
    bit 0, a
    jr nz, jr_002_5fdc
        xor a
        jr jr_002_5fde
    jr_002_5fdc:
        ld a, $01
    jr_002_5fde:

    ld [hl+], a
    ld b, $02

    jr_002_5fe1:
        ld a, [de]
        ld [hl+], a
        inc e
        dec b
    jr nz, jr_002_5fe1

    dec l
    dec l
    dec l
    ld a, [hl]
    ld hl, enemySpawnFlags
    ld l, a
    ld a, [$c477]
    ld [hl], a
    ld hl, $c425
    inc [hl]
    inc l
    inc [hl]
    ld hl, hEnemySpawnFlag
    ld [hl], $03
ret

; Pipe bug enemy header
pipeBugHeader: ; 02:5FFF
    db $80, $00, $00, $00, $00, $00, $00, $00, $01, $67, $5f

Jump_002_600a:
    call Call_002_609b
    ldh a, [hEnemyState]
    and a
        jr z, jr_002_6017 ; state == 0
    dec a
        jr z, jr_002_603e ; state == 1
    ; last case
        jr jr_002_605a

jr_002_6017: ; state 0
    ld c, $02
    ld a, [$d03c]
    ld b, a
    ld hl, hEnemyXPos
    ld a, [hl]
    sub b
    jr nc, jr_002_6028
        cpl
        inc a
        ld c, $00
    jr_002_6028:

    cp $50
        ret nc

    ld a, c
    ldh [$e8], a
    and a
    jr z, jr_002_6036
        xor a
        ldh [hEnemyAttr], a
        jr jr_002_603a
    jr_002_6036:
        ld a, OAMF_XFLIP
        ldh [hEnemyAttr], a
    jr_002_603a:

    ld a, $01
    ldh [hEnemyState], a

jr_002_603e:
    ld hl, hEnemyYPos
    ld a, [hl]
    sub $04
    ld [hl], a
    ld a, [$d03b]
    add $05
    cp [hl]
        ret c

    ld hl, hEnemyState
    inc [hl]
    ld hl, hEnemySpriteType
    ld a, [hl]
    cp $38
        ret c

    ld [hl], $3a
ret


jr_002_605a:
    ld hl, hEnemyXPos
    ld a, [hl]
    cp $a8
    jr nc, jr_002_6073
        ; Check behavioral flip flag
        ldh a, [$e8]
        and a
        jr z, jr_002_606d
            dec [hl]
            dec [hl]
            call enemy_accelBackwards
                ret
        jr_002_606d:
            inc [hl]
            inc [hl]
            call enemy_accelForwards
                ret
    jr_002_6073:
    
    ld h, $c6
    ldh a, [hEnemySpawnFlag]
    bit 4, a
    jr nz, jr_002_6080
        add $1c
        ld l, a
        jr jr_002_6084
    jr_002_6080:
        add $0c
        ld l, a
        inc h
    jr_002_6084:

    ld a, [hl]
    cp $03
    jr nz, jr_002_6093
        ld a, $01
        ld [hl+], a
        ld a, [hl]
        ld hl, enemySpawnFlags
        ld l, a
        ld [hl], $01
    jr_002_6093:

    call $3ca6
    ld a, $ff
    ldh [hEnemySpawnFlag], a
ret


Call_002_609b:
    ld hl, hEnemySpriteType
    ld a, [hl]
    cp $38
    jr nc, jr_002_60a7
        xor $0f
        jr jr_002_60a9
    jr_002_60a7:
        xor $01
    jr_002_60a9:
    
    ld [hl], a
ret

; end of pipe bug code?

enAI_60AB:
    ld hl, hEnemyState
    ld a, [hl-]
    dec a
        jr z, jr_002_60d2
    dec a
        jr z, jr_002_60d9
    dec a
        jr z, jr_002_60ef

    inc [hl]
    ld a, [hl]
    cp $20
        jr z, jr_002_60ce

    call Call_002_6b5b
    ld hl, hEnemyYPos
    ldh a, [hEnemyAttr]
    bit OAMB_YFLIP, a
    jr nz, jr_002_60cc
        dec [hl]
        ret
    jr_002_60cc:
        inc [hl]
        ret
; end proc

jr_002_60ce:
    xor a
    ld [hl+], a
    inc [hl]
ret


jr_002_60d2:
    inc [hl]
    ld a, [hl]
    cp $08
        jr z, jr_002_60ce
ret


jr_002_60d9:
    inc [hl]
    ld a, [hl]
    cp $20
    jr z, jr_002_60ce

    call Call_002_6b5b
    ld hl, hEnemyYPos
    ldh a, [hEnemyAttr]
    bit OAMB_YFLIP, a
    jr nz, jr_002_60ed

    inc [hl]
    ret


jr_002_60ed:
    dec [hl]
    ret


jr_002_60ef:
    inc [hl]
    ld a, [hl]
    cp $08
    ret nz

    xor a
    ld [hl+], a
    ld [hl], a
    ret

enAI_60F8:
    ld hl, hEnemyState
    ld a, [hl-]
    dec a
    jr z, jr_002_611f

    dec a
    jr z, jr_002_6126

    dec a
    jr z, jr_002_613c

    inc [hl]
    ld a, [hl]
    cp $20
    jr z, jr_002_611b

    call Call_002_6b6f
    ld hl, hEnemyXPos
    ldh a, [hEnemyAttr]
    bit OAMB_XFLIP, a
    jr z, jr_002_6119

    dec [hl]
    ret


jr_002_6119:
    inc [hl]
    ret


jr_002_611b:
    xor a
    ld [hl+], a
    inc [hl]
    ret


jr_002_611f:
    inc [hl]
    ld a, [hl]
    cp $08
    jr z, jr_002_611b

    ret


jr_002_6126:
    inc [hl]
    ld a, [hl]
    cp $20
    jr z, jr_002_611b

    call Call_002_6b6f
    ld hl, hEnemyXPos
    ldh a, [hEnemyAttr]
    bit OAMB_XFLIP, a
    jr z, jr_002_613a

    inc [hl]
    ret


jr_002_613a:
    dec [hl]
    ret


jr_002_613c:
    inc [hl]
    ld a, [hl]
    cp $08
    ret nz

    xor a
    ld [hl+], a
    ld [hl], a
    ret

;------------------------------------------------------------------------------
; Autrack AI (laser turret)
enAI_autrack: ; 02:6145
    ld hl, hEnemySpriteType
    ld a, [hl]
    cp $1e ; Check to change the flipped version to refer to the proper sprite
    jr nz, .endIf_A
        ld [hl], $41
    .endIf_A:
    
    ; Check if this object is actually the laser
    ldh a, [hEnemySpawnFlag]
    cp $06
        jr z, .laser ; Laser AI

    ld hl, hEnemySpriteType
    ldh a, [$e8]
    bit 1, a
    jr nz, .else_B
        ld a, [hl]
        cp $43
            jr z, .fireLaser
        inc [hl]
        ret
    .else_B:
        ld a, [hl]
        cp $41
            jr z, .action
        dec [hl]
        ret
; end proc

.fireLaser:
    ; Only act every 16 frames
    ldh a, [hEnemy_frameCounter]
    and $0f
        ret nz

    ; set HL to enemy's slot
    call findFirstEmptyEnemySlot_longJump
    ; Set enemy to active
    xor a
    ld [hl+], a
    ; Set y position
    ldh a, [hEnemyYPos]
    sub $14
    ld [hl+], a
    ; Adjust spawn location of laser depending on direction facing
    ldh a, [hEnemyAttr]
    ld b, a
    bit OAMB_XFLIP, a
    jr nz, .else_C
        ldh a, [hEnemyXPos]
        sub $08
        jr .endIf_C
    .else_C:
        ldh a, [hEnemyXPos]
        add $08
    .endIf_C:
    ld [hl+], a
    ; Set sprite ID
    ld a, $45
    ld [hl+], a
    
    ld a, $00
    ld [hl+], a
    ; Set attributes
    ld a, b
    ld [hl+], a
    ; Load data from header
    ld de, header_61D1
    ld a, $06
    ld [$c477], a
    call Call_002_7231
    
    ; Animate cannon
    ld a, $44
    ldh [hEnemySpriteType], a
    ; Request sound effect
    ld a, $13
    ld [sfxRequest_noise], a

.action:
    ; Only act every 16 frames
    ldh a, [hEnemy_frameCounter]
    and $0f
        ret nz

    ; Flip a flag
    ld hl, $ffe8
    ld a, [hl]
    xor $0a
    ld [hl], a
    cp $08
        ret nz

    ; Request sound effect
    ld a, $18
    ld [sfxRequest_noise], a
ret

.laser: ; Laser AI
    ld hl, hEnemyXPos
    ldh a, [hEnemyAttr]
    bit OAMB_XFLIP, a
    jr nz, .moveLeft
    ; move left
        ld a, [hl]
        sub $05
        ld [hl], a
        ret
    .moveLeft:
        ld a, [hl]
        add $05
        ld [hl], a
        ret
; end proc

; Enemy header for laser
header_61D1:
    db $00, $00, $00, $00, $00, $00, $fe, $00
    dw enAI_autrack

; -----------------------------------------------------------------------------
; hornoad/autotoad/ramulken AI (enemy 14h)
; various hoppers
enAI_hopper: ; 02:61DB
    ld bc, hEnemyYPos
    ; Check state
    ldh a, [hEnemyState]
    dec a
        jr z, .case_pastApex ; if state = 1
    dec a
        jp z, .case_faceSamus  ; if state = 2
    ldh a, [$e9]
    cp $10
        jr nz, .case_jumpUp
    ; Fall-through case
    ; Clear animation counter
    xor a
    ldh [$e9], a
    ; Set state to 1
    inc a
    ldh [hEnemyState], a
    ; Decrement sprite ID
    ld hl, hEnemySpriteType
    dec [hl]
ret

.case_jumpUp: ; Handles upward movement of the jump
    ; DE = [$E9]
    ld e, a
    ld d, $00
    ld hl, hopper_jumpYSpeedTable
    add hl, de
    ld a, [bc] ; BC is the y position
    sub [hl]   ; subtraction is upwards movement
    ld [bc], a ; save the yPos

    ; Handle x movement
    inc c ; BC now refers to the x position
    ld hl, hopper_jumpXSpeedTable
    add hl, de
    ldh a, [hEnemyAttr]
    and a
    jr z, .else_A
        ; move right
        ld a, [bc]
        add [hl]
        jr .endIf_A
    .else_A:
        ; move left
        ld a, [bc]
        sub [hl]
    .endIf_A:
    ld [bc], a ; save the xPos

    ; Increment animation counter
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $05
        ret nz
    ; Animate on the 5th frame of the jump
    ld hl, hEnemySpriteType
    inc [hl]
    ld a, [hl]
    cp $47
        ret nz
    ; Play jumping SFX if a certain enemy type
    ld a, $1a
    ld [sfxRequest_noise], a
ret


.case_pastApex: ; Handles downward movement in general
    ldh a, [$e9]
    cp $10
    jr nz, .moveDown

    call Call_002_4a28
    ld a, [en_bgCollisionResult]
    bit 1, a
    jr nz, .prepNextJump

    ; Force downward movement to be ySpeedTable[0]
    ld a, $0f
    ldh [$e9], a
    ld bc, hEnemyYPos
jr .moveDown

.prepNextJump:
    ; Clear animation counter and state
    xor a
    ldh [$e9], a
    ldh [hEnemyState], a
    ; Increment jump counter
    ld hl, $ffe7
    inc [hl]
    ld a, [hl]
    cp $03
        ret nz
    ; Every 4 jumps, reset jump counter and flip around
    ld [hl], $00
    call enemy_flipHorizontal
ret


.moveDown: ; Handle downward half of jumping arc
    ; yPos = yPos + ySpeedTable[$0F-[$E9]]
    ;  Function iterates through the speed table backwards
    ld e, a
    ld a, $0f
    sub e
    ld e, a
    ld d, $00
    ld hl, hopper_jumpYSpeedTable
    add hl, de
    ld a, [bc]
    add [hl]
    ld [bc], a

    push de
    call Call_002_4a28 ; BG collision function
    pop de
    ld a, [en_bgCollisionResult]
    bit 1, a ; Exit if we've hit ground (don't move forward)
        jr nz, .prepNextJump

    ; Handle X movemnt
    ld bc, hEnemyXPos
    ld hl, hopper_jumpXSpeedTable
    add hl, de
    ldh a, [hEnemyAttr]
    and a
    jr z, .else_B
        ;move right
        ld a, [bc]
        add [hl]
        jr .endIf_B
    .else_B:
        ; move left
        ld a, [bc]
        sub [hl]
    .endIf_B:
    ld [bc], a ; save the xPos

    ; inc the animation counter
    ld hl, $ffe9
    inc [hl]
ret

; Only used if you approach it from the right side, so it ends up facing you
.case_faceSamus:
    ldh a, [hEnemyXPos]
    cp $c8
    jr nc, .endIf_C
        call enemy_flipHorizontal
    .endIf_C:
    ; Clear state
    xor a
    ldh [hEnemyState], a
ret

; 02:6294 - jump arc? y velocity?
hopper_jumpYSpeedTable:
    db $04, $03, $04, $03, $03, $02, $03, $02, $02, $02, $01, $01, $01, $01, $00, $00
; 02:62A4 - jump arc? x velocity?
hopper_jumpXSpeedTable:
    db $00, $01, $01, $01, $01, $01, $02, $01, $01, $01, $01, $01, $01, $01, $01, $01

;------------------------------------------------------------------------------
; Wallfire AI (bird mask on wall that shoots you)
enAI_62B4: ; 02:62B4
    ld hl, hEnemySpriteType
    ld a, [hl]
    cp $1f
    jr nz, jr_002_62be
        ld [hl], $4a
    jr_002_62be:

    call Call_002_7da0
    ldh a, [hEnemySpawnFlag]
    cp $06
    jr z, jr_002_633a

    ld hl, hEnemySpriteType
    ld a, [hl]
    cp $4c
    ret z

    ld a, [$c46d]
    cp $20
    jr nc, jr_002_62e3

    ld a, $4c
    ld [hl], a
    ld a, $ff
    ld [sfxRequest_square1], a
    ld a, $02
    ld [sfxRequest_noise], a
    ret


jr_002_62e3:
    ld a, [hl]
    cp $4b
    jr z, jr_002_632b

    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $50
    ret nz

    ld [hl], $00
    call findFirstEmptyEnemySlot_longJump
    xor a
    ld [hl+], a
    ldh a, [hEnemyYPos]
    sub $04
    ld [hl+], a
    ldh a, [hEnemyAttr]
    ld b, a
    bit OAMB_XFLIP, a
    jr nz, jr_002_6309

    ldh a, [hEnemyXPos]
    add $08
    jr jr_002_630d

jr_002_6309:
    ldh a, [hEnemyXPos]
    sub $08

jr_002_630d:
    ld [hl+], a
    ld a, $4d
    ld [hl+], a
    ld a, $00
    ld [hl+], a
    ld a, b
    ld [hl+], a
    ld de, $6382
    ld a, $06
    ld [$c477], a
    call Call_002_7231
    ld a, $4b
    ldh [hEnemySpriteType], a
    ld a, $12
    ld [sfxRequest_noise], a
    ret


jr_002_632b:
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $08
    ret nz

    ld [hl], $00
    ld a, $4a
    ldh [hEnemySpriteType], a
    ret


jr_002_633a:
    ld hl, hEnemySpriteType
    ld a, [hl]
    cp $4f
    jr nc, jr_002_6374

    call Call_002_6b4e
    ld hl, hEnemyXPos
    ldh a, [hEnemyAttr]
    bit OAMB_XFLIP, a
    jr nz, jr_002_6365

    ld a, [hl]
    add $04
    ld [hl], a
    call Call_002_4608
    ld a, [en_bgCollisionResult]
    bit 0, a
    ret z

jr_002_635b:
    ld a, $4f
    ldh [hEnemySpriteType], a
    ld a, $03
    ld [sfxRequest_noise], a
    ret


jr_002_6365:
    ld a, [hl]
    sub $04
    ld [hl], a
    call Call_002_47e1
    ld a, [en_bgCollisionResult]
    bit 2, a
    ret z

    jr jr_002_635b

jr_002_6374:
    cp $50
    jr z, jr_002_637a

    inc [hl]
    ret


jr_002_637a:
    call $3ca6
    ld a, $ff
    ldh [hEnemySpawnFlag], a
    ret

    db $00, $00, $00, $00, $00, $00, $fe, $01
    dw enAI_62B4

;------------------------------------------------------------------------------
; Gunzoo AI (floating robot with gun's)
enAI_638C: ; 02:638C
    ldh a, [hEnemySpawnFlag]
    cp $06
    jp z, Jump_002_64a7

    ldh a, [$e8]
    bit 0, a
    jp z, Jump_002_6441

    ld hl, hEnemySpriteType
    ld a, [hl]
    cp $51
    call nz, Call_002_6538
    ; Check state
    ldh a, [hEnemyState]
    dec a
        jr z, jr_002_6409 ; state 1
    dec a
        jr z, jr_002_63b4 ; state 2
    ; default state
    ld a, [rDIV]
    and $1f
    jr z, jr_002_63e1

    jr jr_002_63b4

jr_002_63b4:
    ld de, hEnemyYPos
    ld hl, $ffe9
    ldh a, [$e8]
    bit 1, a
    jr nz, jr_002_63d9

    inc [hl]
    ld a, [hl]
    cp $20
    jr z, jr_002_63d1

    ld a, [de]
    add $02
    ld [de], a
    ret


jr_002_63cb:
    ldh a, [hEnemyState]
    cp $02
        jr z, jr_002_6435

jr_002_63d1:
    ld hl, $ffe8
    ld a, [hl]
    xor $02
    ld [hl], a
    ret


jr_002_63d9:
    dec [hl]
    jr z, jr_002_63cb

    ld a, [de]
    sub $02
    ld [de], a
    ret


jr_002_63e1:
    call findFirstEmptyEnemySlot_longJump
    xor a
    ld [hl+], a
    ldh a, [hEnemyYPos]
    sub $08
    ld [hl+], a
    ldh a, [hEnemyXPos]
    sub $10
    ld [hl+], a
    ld a, $06
    ld [$c477], a
    ld de, $6511
    call Call_002_7235
    ld hl, hEnemySpriteType
    inc [hl]
    ld hl, hEnemyState
    inc [hl]
    ld a, $12
    ld [sfxRequest_noise], a
    ret


jr_002_6409:
    ldh a, [hEnemy_frameCounter]
    and $1f
    jr nz, jr_002_63b4

    call findFirstEmptyEnemySlot_longJump
    xor a
    ld [hl+], a
    ldh a, [hEnemyYPos]
    ld [hl+], a
    ldh a, [hEnemyXPos]
    sub $10
    ld [hl+], a
    ld a, $06
    ld [$c477], a
    ld de, $651e
    call Call_002_7235
    ld a, $53
    ldh [hEnemySpriteType], a
    ld hl, hEnemyState
    inc [hl]
    ld a, $12
    ld [sfxRequest_noise], a
    ret


jr_002_6435:
    ld a, $51
    ldh [hEnemySpriteType], a
    xor a
    ldh [$e8], a
    ldh [$e9], a
    ldh [hEnemyState], a
    ret


Jump_002_6441:
    ldh a, [hEnemyState]
    and a
        jr nz, jr_002_644d

    ld a, [rDIV]
    and $1f
    jr z, jr_002_6483

jr_002_644d:
    ld de, hEnemyXPos
    ld hl, $ffe9
    ldh a, [$e8]
    bit 1, a
    jr nz, jr_002_647b

    inc [hl]
    ld a, [hl]
    cp $20
    jr z, jr_002_6469

    ld a, [de]
    add $02
    ld [de], a
    ret


jr_002_6464:
    ldh a, [hEnemyState]
    and a
        jr nz, jr_002_6471

jr_002_6469:
    ld hl, $ffe8
    ld a, [hl]
    xor $02
    ld [hl], a
    ret


jr_002_6471:
    xor a
    ldh [$e9], a
    ldh [hEnemyState], a
    ld a, $01
    ldh [$e8], a
    ret


jr_002_647b:
    dec [hl]
    jr z, jr_002_6464

    ld a, [de]
    sub $02
    ld [de], a
    ret


jr_002_6483:
    call findFirstEmptyEnemySlot_longJump
    xor a
    ld [hl+], a
    ldh a, [hEnemyYPos]
    add $08
    ld [hl+], a
    ldh a, [hEnemyXPos]
    sub $08
    ld [hl+], a
    ld a, $06
    ld [$c477], a
    ld de, $652b
    call Call_002_7235
    ld a, $01
    ldh [hEnemyState], a
    ld a, $12
    ld [sfxRequest_noise], a
    ret


Jump_002_64a7:
    ld hl, hEnemySpriteType
    ld a, [hl]
    cp $57
    jr nc, jr_002_64ed

    sub $55
    jr z, jr_002_64db

    dec a
    jr z, jr_002_64e5

    ld hl, hEnemyYPos
    ld a, [hl]
    add $02
    ld [hl+], a
    ld a, [hl]
    sub $02
    ld [hl], a
    call Call_002_49ba
    ld a, [en_bgCollisionResult]
    bit 1, a
    ret z

    ld a, $55
    ldh [hEnemySpriteType], a
    ld hl, hEnemyYPos
    ld a, [hl]
    sub $04
    ld [hl], a
    ld a, $03
    ld [sfxRequest_noise], a
    ret


jr_002_64db:
    ld [hl], $56
    ld hl, hEnemyYPos
    ld a, [hl]
    sub $08
    ld [hl], a
    ret


jr_002_64e5:
    call $3ca6
    ld a, $ff
    ldh [hEnemySpawnFlag], a
    ret


jr_002_64ed:
    cp $5b
    jr z, jr_002_64e5

    cp $59
    jr nc, jr_002_650f

    ld hl, hEnemyXPos
    ld a, [hl]
    sub $03
    ld [hl], a
    call Call_002_47e1
    ld a, [en_bgCollisionResult]
    bit 2, a
    ret z

    ld a, $59
    ldh [hEnemySpriteType], a
    ld a, $03
    ld [sfxRequest_noise], a
    ret


jr_002_650f:
    inc [hl]
    ret

; Enemy Headers
    db $57, $00, $00, $00, $00, $00, $00, $00, $00, $fe, $01, $8c, $63
    db $57, $00, $00, $00, $00, $00, $00, $00, $00, $fe, $02, $8c, $63
    db $54, $00, $00, $00, $00, $00, $00, $00, $00, $fe, $03, $8c, $63

Call_002_6538:
    ldh a, [hEnemy_frameCounter]
    and $07
    ret nz

    ld [hl], $51
    ret

;------------------------------------------------------------------------------
; Autom AI (robot that spills oil or fire or something)
enAI_6540: ; 02:6540
    ldh a, [hEnemySpawnFlag]
    cp $03
    ret z

    and $0f
    jr z, jr_002_659b

    ld a, [rDIV]
    and $1f
    jr z, jr_002_657a

    ld a, $5c
    ldh [hEnemySpriteType], a
    ld de, hEnemyXPos
    ld hl, $ffe9
    ldh a, [hEnemyState]
    and a
        jr nz, jr_002_6572

    inc [hl]
    ld a, [hl]
    cp $20
    jr z, jr_002_656a

    ld a, [de]
    add $03
    ld [de], a
    ret


jr_002_656a:
    ld hl, hEnemyState
    ld a, [hl]
    xor $01
    ld [hl], a
    ret


jr_002_6572:
    dec [hl]
    jr z, jr_002_656a

    ld a, [de]
    sub $03
    ld [de], a
    ret


jr_002_657a:
    call findFirstEmptyEnemySlot_longJump
    xor a
    ld [hl+], a
    ldh a, [hEnemyYPos]
    add $10
    ld [hl+], a
    ldh a, [hEnemyXPos]
    inc a
    ld [hl+], a
    call Call_002_6b21
    ld de, $65c8
    call Call_002_7235
    ld hl, hEnemySpriteType
    ld [hl], $5d
    ld a, $03
    ldh [hEnemySpawnFlag], a
    ret


jr_002_659b:
    ld a, $07
    ld [sfxRequest_square2], a
    ld hl, hEnemySpriteType
    ld a, [hl]
    cp $60
    jr z, jr_002_65b3

    jr nc, jr_002_65b5

    inc [hl]
    ld hl, hEnemyYPos
    ld a, [hl]
    add $08
    ld [hl], a
    ret


jr_002_65b3:
    inc [hl]
    ret


jr_002_65b5:
    call Call_002_6b47
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $20
    ret nz

    call $3ca6
    ld a, $ff
    ldh [hEnemySpawnFlag], a
    ret

    db $5e, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $00, $40, $65

;------------------------------------------------------------------------------
; Proboscum AI (nose on wall that is acts as a platform)
enAI_65D5:
    ld hl, hEnemySpriteType
    ld a, [hl]
    cp $6e ; Check to make sure the flipped version has the correct sprite
    jr nz, jr_002_65df
        ld [hl], $72
    jr_002_65df:

    ldh a, [hEnemyState]
    dec a
        jr z, .case_1 ; State 1
    dec a
        jr z, .case_2 ; State 2
    dec a
        jr z, .case_3 ; State 3
    ; Fall-through state

.case_2:
    ; Wait for 64 frames
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $40
        ret nz

    ; Reset counter
    ld [hl], $00
    ; Change sprite (half-extended)
    ld a, $73
    ldh [hEnemySpriteType], a
    ; state becomes 1 or 3, depending on if we fell-through to here or not
    ld hl, hEnemyState
    inc [hl]
ret

.case_1:
    ; Wait for two frames
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $02
        ret nz

    ; Reset counter
    ld [hl], $00
    ; Change sprite
    ld a, $74
    ldh [hEnemySpriteType], a
    ; state = 2
    ld a, $02
    ldh [hEnemyState], a
ret

.case_3:
    ; Wait for two frames
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $02
        ret nz

    ; Reset counter
    ld [hl], $00
    ; Change sprite
    ld a, $72
    ldh [hEnemySpriteType], a
    ; state = 0 (fall-through to 2)
    xor a
    ldh [hEnemyState], a
ret

;------------------------------------------------------------------------------
; Missile block AI
enAI_6622: ; 02:6622
    call Call_002_7da0
    ; Check state
    ld hl, hEnemyState
    ld a, [hl]
    dec a
        jr z, .case_1 ; state 1 - falling 1
    dec a
        jr z, .case_2 ; state 2 - falling 2
    dec a
        jp z, .case_exploding ; state 3 - exploding

    ; default state
    ; Exit if not hit by a projectile
    ld a, [$c46d]
    cp $20
        ret nc
    
    ld b, a
    ; Play plink sound
    ld a, $0f
    ld [sfxRequest_square1], a
    ; Exit if not hit by a missile
    ld a, b
    cp $08
        ret nz

    ; Clear plink sound
    ld a, $ff
    ld [sfxRequest_square1], a
    ; Play missile hit sound
    ld a, $08
    ld [sfxRequest_noise], a
    ; Check direction block was hit from
    ld a, [$c46e]
    bit 0, a
    jr nz, .endIf_A
        ; Set a flag in [$E8] (used for animation)
        ld a, $02
        ldh [$e8], a
    .endIf_A:

    ; Set state
    ld a, $01
    ldh [hEnemyState], a
    
    ld a, $01
    ldh [$e7], a
; continue to case_1

.case_1:
    ldh a, [$e9]
    cp $0a
        jr z, .prepCase_2

    call Call_002_677c ; Y movement
    ; Check direction hit from
    ldh a, [$e8]
    and a
    ; X movement
    jr z, .else_B
        call Call_002_67d9
        jr .endIf_B
    .else_B:
        call Call_002_6803
    .endIf_B:

.common_exit:
    call .animate
    call Call_002_4a28 ; Check bg collision
    ld a, [en_bgCollisionResult]
    bit 1, a
        ret z
    ; Set state to exploding
    ld a, $03
    ldh [hEnemyState], a
    ; Set sprite to explosion
    ld a, $e2
    ldh [hEnemySpriteType], a
ret


.prepCase_2:
    ; Reset counter
    xor a
    ldh [$e9], a
    ; Set state
    ld a, $02
    ldh [hEnemyState], a

.case_2:
    ; Move block down
    ld hl, hEnemyYPos
    ld a, [hl]
    add $04
    ld [hl], a
    call enemy_accelForwards ; Downwards

    inc l ; HL is now x position
    ld b, $01
    ldh a, [$e8]
    and a
    jr z, .else_C
        ; Move left
        ld a, [hl]
        sub b
        ld [hl], a
        jr .common_exit
    .else_C:
        ; Move right
        ld a, [hl]
        add b
        ld [hl], a
        jr .common_exit
; end proc

.case_exploding:
    ; Animate from $E2 to $E7
    ld hl, hEnemySpriteType
    ld a, [hl]
    cp $e7
        jr z, .deleteSelf
    inc [hl]
ret

.deleteSelf:
    call $3ca6 ; Delete self
    ; Delete self for good
    ld a, $02
    ldh [hEnemySpawnFlag], a
ret

; Animate missile block by flipping around
; [$E8] determines if it is "clockwise" or "counter-clockwise"
;  (since the sprites aren't actually rotating, CW/CCW are technically inaccurate terms)
.animate: ; 03:66C0
    ; Animate every 4 frames
    ldh a, [hEnemy_frameCounter]
    and $03
        ret nz
    ; Load HL
    ld hl, hEnemyAttr
    ; Check which direction the block is spinning
    ldh a, [$e8]
    and a
        jr nz, .animate_ccw

;animate_cw
    ld a, [hl]
    and a
        jr z, .setYFlip
    cp OAMF_XFLIP
        jr z, .setNoFlip
    cp OAMF_YFLIP
        jr z, .setXYFlip
    ; continue to .setXFlip

.setXFlip:
    ld [hl], OAMF_XFLIP
    ret
.setNoFlip:
    ld [hl], $00
    ret
.setYFlip:
    ld [hl], OAMF_YFLIP
    ret
.setXYFlip:
    ld [hl], OAMF_XFLIP | OAMF_YFLIP
    ret

.animate_ccw:
    ld a, [hl]
    and a
        jr z, .setXFlip
    cp OAMF_XFLIP
        jr z, .setXYFlip
    cp OAMF_YFLIP
        jr z, .setNoFlip
    jr .setYFlip
; end proc

;------------------------------------------------------------------------------
; Moto enemy AI (the animal with a face-plate)
enAI_66F3: ; 00:66F3
    call Call_002_6726
    ldh a, [hEnemy_frameCounter]
    and $01
        ret nz

    ld hl, hEnemyXPos
    ld b, $02
    ldh a, [$e8]
    and $0f
    jr z, jr_002_6721

; Move left
    ld a, [hl]
    sub b
    ld [hl], a

jr_002_6709:
    call Call_002_4abb
    ld a, [en_bgCollisionResult]
    bit 1, a
        ret nz

    ; Flip enemy
    ld hl, hEnemyAttr
    ld a, [hl]
    xor OAMF_XFLIP
    ld [hl], a
    
    ld hl, $ffe8
    ld a, [hl]
    xor $32
    ld [hl], a
ret


jr_002_6721:
    ld a, [hl]
    add b
    ld [hl], a
    jr jr_002_6709

Call_002_6726:
    ldh a, [hEnemy_frameCounter]
    and $01
        ret nz

    ld hl, hEnemySpriteType
    ld a, [hl]
    cp $68
    jr nz, jr_002_673c
        ldh a, [$e9]
        and a
        jr z, jr_002_673a
            inc [hl]
            ret
        jr_002_673a:
            dec [hl]
            ret
    jr_002_673c:

    ld [hl], $68
    ld hl, $ffe9
    ld a, [hl]
    xor $01
    ld [hl], a
ret

;------------------------------------------------------------------------------
; Halzyn (flying enemy with sheilds on the sides)
enAI_6746: ; 02:6746
    call Call_002_6b62 ; Animate
    call Call_002_677c ; Y Movment
    ; Check direction of movement
    ldh a, [$e8]
    and $0f
    jr z, .else
        call Call_002_67d9 ; X Movement
        ; Check collision
        call Call_002_4885
        ld a, [en_bgCollisionResult]
        bit 2, a
            ret z
        ; Turn around
        ld hl, $ffe8
        ld a, [hl]
        and $f0
        ld [hl], a
            ret
    .else:
        call Call_002_6803 ; X Movement
        ; Check collision
        call Call_002_46ac
        ld a, [en_bgCollisionResult]
        bit 0, a
            ret z
        ; Turn around
        ld hl, $ffe8
        ld a, [hl]
        and $f0
        add $02
        ld [hl], a
            ret
; end proc

;------------------------------------------------------------------------------
; Used by multiple enemies
Call_002_677c:
    ld bc, hEnemyYPos
    ld hl, $ffe9
    ld a, [hl]
    cp $0a
    jr nz, jr_002_679d
        ld [hl], $00
        ld hl, hEnemyState
        ld a, [hl]
        cp $03
        jr z, jr_002_6794
            inc [hl]
            jr jr_002_679d
        jr_002_6794:
            ld [hl], $00
            ld hl, $ffe7
            ld a, [hl]
            xor $01
            ld [hl], a
    jr_002_679d:

    ldh a, [$e9]
    ld e, a
    ld d, $00
    ldh a, [hEnemyState]
    dec a
        jr z, jr_002_67b2 ; State 1
    dec a
        jr z, jr_002_67b7 ; State 2
    dec a
        jr z, jr_002_67bc ; State 3

; State 0
    ld hl, table_682D
        jr jr_002_67bf
jr_002_67b2:
    ld hl, table_6837
        jr jr_002_67cc
jr_002_67b7:
    ld hl, table_682D
        jr jr_002_67cc
jr_002_67bc:
    ld hl, table_6837
        ; implicit jump to jr_002_67bf


jr_002_67bf: ; Move back
    add hl, de
    ldh a, [$e7]
    ld d, a
    ld a, [bc]
    sub [hl]
    bit 0, d
        jr z, jr_002_67ca
    sub [hl]


jr_002_67ca: ; Exit
    ld [bc], a
ret


jr_002_67cc: ; Move ahead
    add hl, de
    ldh a, [$e7]
    ld d, a
    ld a, [bc]
    add [hl]
    bit 0, d
        jr z, jr_002_67ca

    add [hl]
    ld [bc], a
ret

; Called by multiple enemies
Call_002_67d9:
    ld bc, hEnemyXPos
    ld hl, $ffe9
    ld a, [hl]
    ld e, a
    ld d, $00
    inc [hl] ; Table index incremented
    ldh a, [hEnemyState]
    dec a
        jr z, jr_002_67f4 ; State 1
    dec a
        jr z, jr_002_67f9 ; State 2
    dec a
        jr z, jr_002_67fe ; State 3

; State 0
    ld hl, table_6837
        jr jr_002_67bf
jr_002_67f4:
    ld hl, table_682D
        jr jr_002_67bf
jr_002_67f9:
    ld hl, table_6837
        jr jr_002_67bf
jr_002_67fe:
    ld hl, table_682D
        jr jr_002_67bf

; Called by multiple enemies
Call_002_6803:
    ld bc, hEnemyXPos
    ld hl, $ffe9
    ld a, [hl]
    ld e, a
    ld d, $00
    inc [hl] ; Table index incremented
    ldh a, [hEnemyState]
    dec a
        jr z, jr_002_681e ; State 1
    dec a
        jr z, jr_002_6823 ; State 2
    dec a
        jr z, jr_002_6828 ; State 3

; State 0
    ld hl, table_6837
        jr jr_002_67cc
jr_002_681e:
    ld hl, table_682D
        jr jr_002_67cc
jr_002_6823:
    ld hl, table_6837
        jr jr_002_67cc
jr_002_6828:
    ld hl, table_682D
        jr jr_002_67cc

table_682D: ; 02:682D
    db $01, $01, $01, $01, $01, $01, $01, $00, $01, $00 
table_6837: ; 02:6837
    db $00, $01, $00, $01, $01, $01, $01, $01, $01, $01

;------------------------------------------------------------------------------
; Septogg AI (floating platforms)
enAI_6841: ; 02:6841
    call Call_002_6b4e
    call Call_002_7da0
    ld a, [$c46d]
    cp $20
    jr nz, jr_002_6887

    ld a, [$c43a]
    and a
    jr z, jr_002_6887

    ld b, $03
    ld hl, hEnemyYPos
    ld a, [hl]
    add b
    ld [hl], a
    call Call_002_4ad6
    ld a, [en_bgCollisionResult]
    bit 1, a
    jr z, jr_002_686c

    ld a, [$c41e]
    ldh [hEnemyYPos], a
    ret


jr_002_686c:
    ld b, $03
    ld hl, $ffe9
    ld a, [hl]
    add b
    ld [hl+], a
    ld a, [hl]
    adc $00
    ld [hl], a
    ld hl, $d03b
    ld a, [hl]
    add b
    ld [hl], a
    ld hl, $ffc0
    ld a, [hl]
    add b
    ld [hl+], a
    ret nc

    inc [hl]
    ret


jr_002_6887:
    ld hl, $ffe9
    ld a, [hl]
    and a
    jr nz, jr_002_6892

    inc l
    ld a, [hl]
    and a
    ret z

jr_002_6892:
    ld hl, hEnemyYPos
    dec [hl]
    ld hl, $ffe9
    dec [hl]
    ld a, [hl]
    inc a
    ret nz

    inc l
    dec [hl]
    ret

enAI_68A0:
    ld de, hEnemySpriteType
    ld hl, hEnemyState
    ld a, [hl]
    dec a
    jr z, jr_002_68c3

    dec a
    jr z, jr_002_68d6

    dec a
    jr z, jr_002_68e9

    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $38
    ret nz

    ld [hl], $00
    ld a, $01
    ldh [hEnemyState], a
    ld a, $d1
    ldh [hEnemySpriteType], a
    ret


jr_002_68c3:
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $0e
    ret nz

    ld [hl], $00
    ld a, $02
    ldh [hEnemyState], a
    ld a, $fd
    ldh [hEnemySpriteType], a
    ret


jr_002_68d6:
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $0c
    ret nz

    ld [hl], $00
    ld a, $03
    ldh [hEnemyState], a
    ld a, $d1
    ldh [hEnemySpriteType], a
    ret


jr_002_68e9:
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $0d
    ret nz

    ld [hl], $00
    ld a, $00
    ldh [hEnemyState], a
    ld a, $d0
    ldh [hEnemySpriteType], a
    ret

enAI_68FC: ; Flitts 
    call Call_002_6b3a
    call Call_002_7da0
    ldh a, [$e8]
    and a
    jr nz, jr_002_6933

    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $60
    jr z, jr_002_692f

    ld hl, hEnemyXPos
    inc [hl]
    ld a, [$c46d]
    cp $20
    ret nz

    ld a, [$c43a]
    and a
    ret z

    ld hl, $d03c
    inc [hl]
    ld hl, $d035
    inc [hl]
    ld hl, $ffc2
    inc [hl]
    ret nz

    inc l
    inc [hl]
    ret


jr_002_692f:
    ld a, $02
    ldh [$e8], a

jr_002_6933:
    ld hl, $ffe9
    dec [hl]
    jr z, jr_002_695b

    ld hl, hEnemyXPos
    dec [hl]
    ld a, [$c46d]
    cp $20
    ret nz

    ld a, [$c43a]
    and a
    ret z

    ld hl, $d03c
    dec [hl]
    ld hl, $d036
    inc [hl]
    ld hl, $ffc2
    dec [hl]
    ld a, [hl]
    cp $ff
    ret nz

    inc l
    dec [hl]
    ret


jr_002_695b:
    xor a
    ldh [$e8], a
    ret

; Gravitt AI (crawler with a hat that pops out of the ground)
enAI_659F:
    ld hl, hEnemyState
    ld a, [hl]
    dec a
        jr z, jr_002_699f ; State 1
    dec a
        jr z, jr_002_69b5 ; State 2
    dec a
        jr z, jr_002_69b5 ; State 3
    dec a
        jr z, jr_002_69de ; State 4
    dec a
        jp z, Jump_002_69f8 ; State 5

    ; Default state
    ld hl, hEnemyXPos
    ld b, $00
    ld a, [$d03c]
    sub [hl]
    jr nc, jr_002_6981

    cpl
    inc a
    inc b

jr_002_6981:
    cp $38
    ret nc

    ld hl, hEnemySpriteType
    inc [hl]
    ld hl, hEnemyYPos
    dec [hl]
    dec [hl]
    ld a, $01
    ldh [hEnemyState], a
    ld a, b
    and a
    jr nz, jr_002_699a

    ld a, $80
    ldh [$e8], a
    ret


jr_002_699a:
    ld a, $82
    ldh [$e8], a
    ret


jr_002_699f:
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $06
    jr z, jr_002_69ae

    ld hl, hEnemyYPos
    dec [hl]
    dec [hl]
    ret


jr_002_69ae:
    xor a
    ld [hl+], a
    ld a, $02
    ldh [hEnemyState], a
    ret


jr_002_69b5:
    call Call_002_6a04
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $18
    jr z, jr_002_69d0

    ld hl, hEnemyXPos
    ldh a, [$e8]
    bit 1, a
    jr z, jr_002_69cd

    dec [hl]
    dec [hl]
    ret


jr_002_69cd:
    inc [hl]
    inc [hl]
    ret


jr_002_69d0:
    ld [hl], $00
    ld hl, $ffe8
    ld a, [hl]
    xor $02
    ld [hl], a
    ld hl, hEnemyState
    inc [hl]
    ret


jr_002_69de:
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $07
    jr z, jr_002_69ed

    ld hl, hEnemyYPos
    inc [hl]
    inc [hl]
    ret


jr_002_69ed:
    xor a
    ld [hl+], a
    ld a, $05
    ldh [hEnemyState], a
    ld a, $d3
    ldh [hEnemySpriteType], a
    ret


Jump_002_69f8:
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $30
    ret nz

    xor a
    ld [hl+], a
    ld [hl], a
    ret


Call_002_6a04:
    ldh a, [hEnemy_frameCounter]
    and $01
    ret nz

    ld hl, hEnemySpriteType
    inc [hl]
    ld a, [hl]
    cp $d8
    ret nz

    ld [hl], $d4
    ret

;------------------------------------------------------------------------------
; Missile Door
enAI_missileDoor: ; 02:6A14
    ; Load results of collision tests with this object
    call Call_002_7da0
    ; If not the door sprite, jump ahead
    ld hl, hEnemySpriteType
    ld a, [hl]
    cp $f8
        jr nz, .exploding

    ; Exit if not hit with a projectile
    ld a, [$c46d]
    cp $20
        ret nc

    ld b, a
    ; Play sound (plink)
    ld a, $0f
    ld [sfxRequest_square1], a
    ; Exit if not hit by missile
    ld a, b
    cp $08
        ret nz

    ; Clear plink sound
    ld a, $ff
    ld [sfxRequest_square1], a
    ; Play missile sound
    ld a, $08
    ld [sfxRequest_noise], a
    ; Change palette for a few frames
    ld a, $13
    ldh [hEnemyStunCounter], a
    ; Increment hit counter
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    ; Exit if not hit with 5 missiles
    cp $05
        ret nz

    ; Clear hit counter and palette effect
    xor a
    ld [hl], a
    ldh [hEnemyStunCounter], a
    ; Change sprite ID to explosion
    ld a, $e2
    ldh [hEnemySpriteType], a
    ; Play sound effect
    ld a, $10
    ld [sfxRequest_square1], a
    
    ; Check which direction the door was hit from, to adjust the position of the explosion
    ld a, [$c46e]
    bit 1, a
        jr nz, .rightSide

;.leftSide:
    ; Adjust position so the explosion is on the left
    ld hl, hEnemyXPos
    ld a, [hl]
    sub $18
    ld [hl], a
ret

.exploding:
    ; Animate the explosion (sprites $E2 thru $E7)
    ld hl, hEnemySpriteType
    ld a, [hl]
    cp $e7
        jr z, .deleteDoor
    inc [hl]
ret

.rightSide:
    ; Adjust position so the explosion is on the right
    ld hl, hEnemyXPos
    ld a, [hl]
    add $18
    ld [hl], a
ret

.deleteDoor:
    call $3ca6 ; Delete self?
    ; Set enemy spawn flag to dead
    ld a, $02
    ldh [hEnemySpawnFlag], a
ret

; end of missile door code
;------------------------------------------------------------------------------

; Called by multiple enemies
; Used to move enemies "forwards" (right or down) in an accelerating fashion
; Takes HL as an argument/return
enemy_accelForwards: ; 02:6A7B
    push bc
    push de
        push hl
            ; Load value from [$E7], perform bounds check, and increment
            ld bc, $ffe7
            ld a, [bc]
            cp $17
            jr z, .endIf
                inc a
                ld [bc], a
            .endIf:
            ; Load value from table
            ld e, a
            ld d, $00
            ld hl, .speedTable
            add hl, de
            ld a, [hl]
        pop hl
        ; Add value of table to [hl]
        add [hl]
        ld [hl], a
    pop de
    pop bc
ret

.speedTable: ; 02:6A96 - First entry is unused
    db $00, $00, $01, $00, $01, $00, $01, $01, $02, $01, $02, $01, $02, $02, $03, $02
    db $03, $03, $04, $03, $04, $04, $03, $04

; Called by multiple enemies
; Used to move enemies "forwards" (right or down) in an accelerating fashion
; Takes HL as an argument/return
enemy_accelBackwards: ; 02:6AAE
    push bc
    push de
        push hl
            ; Load value from [$E7], perform bounds check, and increment
            ld bc, $ffe7
            ld a, [bc]
            cp $17
            jr z, .endIf
                inc a
                ld [bc], a
            .endIf:
            ; Load value from table
            ld e, a
            ld d, $00
            ld hl, .speedTable
            add hl, de
            ld a, [hl]
        pop hl
        ; Add value of table to [hl]
        add [hl]
        ld [hl], a
    pop de
    pop bc
ret

.speedTable: ; 02:6AC9 First entry is unused
    db $00, $00, $ff, $00, $ff, $00, $ff, $ff, $fe, $ff, $fe, $ff, $fe, $fe, $fd, $fe
    db $fd, $fd, $fc, $fd, $fc, $fc, $fd, $fc

; Unused (?) but similar to the above routines
; Takes HL as an argument/return
; Seems unnecessarily complex with the separate positive/negative cases
unknownProc_6AE1: ; 02:6AE1
    push bc
    push de
        push hl
            ; Load value from [$E7], perform bounds check, and increment
            ld bc, $ffe7
            ld a, [bc]
            cp $17
            jr z, .endIf_A
                inc a
                ld [bc], a
            .endIf_A:
            ; Check if value in table is negative
            ld e, a
            ld d, $00
            ld hl, .unknownTable
            add hl, de
            bit 7, [hl]
            jr z, .else_B
                ; If it was negative, take the two's compliment to make it positive
                ld a, [hl]
                cpl
                inc a
                ld b, a
                
                pop hl
                ; And then subtract the value from the popped HL
                ld a, [hl]
                sub b
                jr .endIf_B
            .else_B:
                ; If it was non-negative, then add the value from the table to the popped HL
                ld a, [hl]
                pop hl
                add [hl]
            .endIf_B:
        ; HL has been popped by this point
    ld [hl], a
    pop de
    pop bc
ret

.unknownTable: ; 02:6B09
    db $00, $FE, $FE, $FE, $FF, $FE, $FE, $FF, $FF, $FE, $FF, $FF, $FF, $00, $FF, $FF
    db $00, $FF, $00, $00, $FF, $00, $00, $00


; Something pointer related
Call_002_6b21:
    ldh a, [$fd]
    cp $c6
    jr nz, .else
        ldh a, [$fc]
        jr .endIf
    .else:
        ldh a, [$fc]
        add $10
    .endIf:

    ld [$c477], a
ret


; Flip sprite ID (low bit)
Call_002_6b33: ; 02:6B33
    ldh a, [hEnemy_frameCounter]
    and $01
    ret nz
    jr enemy_flipSpriteId

Call_002_6b3a: ; 02:6B3A
    ldh a, [hEnemy_frameCounter]
    and $03
    ret nz

enemy_flipSpriteId: ; 02:6B3F
    ld hl, hEnemySpriteType
    ld a, [hl]
    xor %00000001 ;$01
    ld [hl], a
    ret


; Flip sprite ID (lowest two bits)
Call_002_6b47: ; 02:6B47
    ldh a, [hEnemy_frameCounter]
    and $03
    ret nz

    jr jr_002_6b53

Call_002_6b4e: ; 02:6B47
    ldh a, [hEnemy_frameCounter]
    and $01
    ret nz

jr_002_6b53: ; 02:6B53
    ld hl, hEnemySpriteType
    ld a, [hl]
    xor %00000011 ;$03
    ld [hl], a
    ret

; Flip sprite horizontally
Call_002_6b5b: ; 02:6B5B
    ldh a, [hEnemy_frameCounter]
    and $01
    ret nz

    jr enemy_flipHorizontal

Call_002_6b62: ; 02:6B5B
    ldh a, [hEnemy_frameCounter]
    and $03
    ret nz

enemy_flipHorizontal: ; 02:6B62
    ld hl, hEnemyAttr
    ld a, [hl]
    xor OAMF_XFLIP
    ld [hl], a
    ret

; Flip sprite vertically
Call_002_6b6f: ; 02:6B6F
    ldh a, [hEnemy_frameCounter]
    and $01
    ret nz

    jr jr_002_6b7b

; 02:6B76
    ldh a, [hEnemy_frameCounter]
    and $03
    ret nz

jr_002_6b7b: ; 02:6B7B
    ld hl, hEnemyAttr
    ld a, [hl]
    xor OAMF_YFLIP
    ld [hl], a
    ret
    

;------------------------------------------------------------------------------
enAI_6B83: ; Baby egg?
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $8a
    jr z, jr_002_6ba6
        dec a
            ret nz
        ; 
        ld hl, metroidCountDisplayed
        ld a, [hl]
        add $08
        daa
        ld [hl], a
        ld a, $ca
        ld [metroidCountShuffleTimer], a
        ; Play metroid hive song with intro
        ld a, $1f
        ld [songRequest], a
        ld a, $01
        ld [$c463], a
        ret
    jr_002_6ba6:

    call $3ca6
    ld a, $02
    ldh [hEnemySpawnFlag], a
    xor a
    ld [$c463], a
ret


enAI_6BB2:
Jump_002_6bb2:
    call Call_002_7da0
    ld hl, $c464
    ld a, [hl]
    and a
    jr z, jr_002_6bdc

    dec [hl]
    jr z, jr_002_6bd1

    call Call_002_6ef0
    call Call_002_7df8
    ld a, [$c46d]
    cp $10
    ret nc

    ld a, $0f
    ld [sfxRequest_square1], a
    ret


jr_002_6bd1:
    xor a
    ldh [$e0], a
    ld a, $ff
    ldh [$e8], a
    ld a, $a3
    ldh [hEnemySpriteType], a

jr_002_6bdc:
    ld a, [$c41c]
    cp $02
    jp z, Jump_002_6c7d

    ld b, a
    ldh a, [hEnemySpawnFlag]
    cp $04
    jr z, jr_002_6c4f

    ld c, a
    ld a, b
    cp $01
    jp z, Jump_002_6d99

    ldh a, [hEnemySpriteType]
    cp $a1
    jp z, Jump_002_6db5

    ld a, [$c463]
    and a
    jr nz, jr_002_6c2e

    ldh a, [hEnemy_frameCounter]
    and $03
    ret nz

    ldh a, [hEnemyStunCounter]
    xor $10
    ldh [hEnemyStunCounter], a
    ld hl, hEnemyXPos
    ld a, [$d03c]
    sub [hl]
    jr nc, jr_002_6c15

    cpl
    inc a

jr_002_6c15:
    cp $50
    ret nc

    ld a, $01
    ld [$c463], a
    ld a, $01
    ld [$c465], a
    ld a, [songPlaying]
    cp $0c
    ret z

    ; Trigger Metroid fight music
    ld a, $0c
    ld [songRequest], a
    ret


jr_002_6c2e:
    ldh a, [hEnemy_frameCounter]
    and $03
    ret nz

    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $08
    jp z, Jump_002_6dac

    ldh a, [hEnemyStunCounter]
    xor $10
    ldh [hEnemyStunCounter], a
    ret

;------------------------------------------------------------------------------
enAI_6C44: ; Alpha metroid ?
    ld a, [$c465]
    and a
    jp nz, Jump_002_6bb2 ; Jump to actual AI?
    ; Routine for before it attacks

    ld a, $04
    ldh [hEnemySpawnFlag], a

jr_002_6c4f:
    ld a, $a3
    ldh [hEnemySpriteType], a
    ld hl, hEnemyXPos
    ld a, [$d03c]
    sub [hl]
    jr nc, jr_002_6c5e
        cpl
        inc a
    jr_002_6c5e:

    cp $50
    ret nc

    xor a
    ld [$c464], a
    ld a, $01
    ld [$c465], a
    ld a, $02
    ld [$c41c], a
    ld a, [songPlaying]
    cp $0c
    jr z, jr_002_6c93
    ; Trigger Metroid fight music
    ld a, $0c
    ld [songRequest], a
    jr jr_002_6c93

Jump_002_6c7d:
    ld a, [$c46d]
    cp $20
    jp nc, Jump_002_6c93

    cp $10
    jr z, jr_002_6ce9

    cp $08
    jr z, jr_002_6cf2

    ld a, $0f
    ld [sfxRequest_square1], a
    ret


Jump_002_6c93:
jr_002_6c93:
    ldh a, [$e8]
    inc a
    jr z, jr_002_6cb1

    call Call_002_6e7f
    ld hl, $c471
    ld a, [hl]
    and a
    ret z

    ld [hl], $00
    ld a, $ff
    ldh [$e8], a
    ld a, $a3
    ldh [hEnemySpriteType], a
    xor a
    ldh [$e9], a
    ldh [hEnemyState], a
    ret


jr_002_6cb1:
    ld hl, $ffe9
    ld a, [hl]
    and a
    jr nz, jr_002_6cd1

    call $3d0c
    ld hl, hEnemyXPos
    ld a, [hl]
    add $10
    ld b, a
    ld a, [$d03c]
    sub b
    jr c, jr_002_6cce

    ld a, OAMF_XFLIP
    ldh [hEnemyAttr], a
    jr jr_002_6cd1

jr_002_6cce:
    xor a
    ldh [hEnemyAttr], a

jr_002_6cd1:
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $0e
    jr c, jr_002_6cdf

    cp $14
    ret nz

    ld [hl], $00

jr_002_6cdf:
    call $3d34
    call Call_002_6dd4
    call Call_002_6e39
    ret


jr_002_6ce9:
    call Call_002_6e41
    ld a, $1a
    ld [sfxRequest_square1], a
    ret


jr_002_6cf2:
    ld hl, hEnemyHealth
    dec [hl]
    ld a, [hl]
    and a
    jr z, jr_002_6d61

    ld a, $08
    ld [$c464], a
    ld a, $05
    ld [sfxRequest_noise], a
    ld hl, $ffe8
    ld [hl], $00
    ld a, [$c46e]
    ld b, a
    bit 0, b
    jr nz, jr_002_6d3c

    bit 3, b
    jr nz, jr_002_6d27

    bit 1, b
    jr nz, jr_002_6d46

    ldh a, [hEnemyYPos]
    sub $05
    cp $10
    jr c, jr_002_6d2f

    ldh [hEnemyYPos], a
    set 3, [hl]
    jr jr_002_6d2f

jr_002_6d27:
    set 1, [hl]
    ldh a, [hEnemyYPos]
    add $05
    ldh [hEnemyYPos], a

jr_002_6d2f:
    ld a, [rDIV]
    and $01
    jr z, jr_002_6d39

    set 0, [hl]
    ret


jr_002_6d39:
    set 2, [hl]
    ret


jr_002_6d3c:
    set 0, [hl]
    ldh a, [hEnemyXPos]
    add $05
    ldh [hEnemyXPos], a
    jr jr_002_6d54

jr_002_6d46:
    ldh a, [hEnemyXPos]
    sub $05
    cp $08
    jr c, jr_002_6d54

    ldh [hEnemyXPos], a
    set 2, [hl]
    jr jr_002_6d54

jr_002_6d54:
    ld a, [rDIV]
    and $01
    jr z, jr_002_6d5e

    set 1, [hl]
    ret


jr_002_6d5e:
    set 3, [hl]
    ret


jr_002_6d61:
    xor a
    ldh [$e9], a
    ldh [hEnemyState], a
    ld a, $80
    ld [$c41c], a
    ld a, $e2
    ldh [hEnemySpriteType], a
    ld a, $0d
    ld [sfxRequest_noise], a
    ; Play metroid killed jingle
    ld a, $0f
    ld [songRequest], a
    ld a, $02
    ld [$c465], a
    ldh [hEnemySpawnFlag], a
    ld hl, $d089
    ld a, [hl]
    sub $01
    daa
    ld [hl], a
    ld hl, metroidCountDisplayed
    ld a, [hl]
    sub $01
    daa
    ld [hl], a
    ld a, $c0
    ld [metroidCountShuffleTimer], a
    call $3c92
    ret


Jump_002_6d99:
jr_002_6d99:
    ld hl, hEnemySpriteType
    ld [hl], $a3
    ld a, $04
    ldh [hEnemySpawnFlag], a
    xor a
    ld [$c463], a
    ld a, $02
    ld [$c41c], a
    ret


Jump_002_6dac:
    xor a
    ld [hl], a
    ldh [hEnemyStunCounter], a
    ld a, $a1
    ldh [hEnemySpriteType], a
    ret


Jump_002_6db5:
    call Call_002_75ec
    ldh a, [hEnemy_frameCounter]
    and $07
    ret nz

    ld hl, hEnemyYPos
    ld a, [hl]
    sub $02
    ld [hl], a
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $0d
    ret nz

    xor a
    ld [hl], a
    inc a
    ld [$c41c], a
    jr jr_002_6d99

Call_002_6dd4:
    push bc
    ld a, b
    and a
    jr z, jr_002_6e08

    ld hl, hEnemyYPos
    bit 7, b
    jr z, jr_002_6df6

    res 7, b
    ld a, [hl]
    sub b
    ld [hl], a
    call Call_002_4d04
    ld a, [en_bgCollisionResult]
    bit 3, a
    jr z, jr_002_6e08

    ld a, [$c41e]
    ldh [hEnemyYPos], a
    jr jr_002_6e08

jr_002_6df6:
    ld a, [hl]
    add b
    ld [hl], a
    call Call_002_4b17
    ld a, [en_bgCollisionResult]
    bit 1, a
    jr z, jr_002_6e08

    ld a, [$c41e]
    ldh [hEnemyYPos], a

jr_002_6e08:
    pop bc
    ld a, c
    and a
    ret z

    ld hl, hEnemyXPos
    bit 7, c
    jr z, jr_002_6e27

    res 7, c
    ld a, [hl]
    sub c
    ld [hl], a
    call Call_002_490f
    ld a, [en_bgCollisionResult]
    bit 2, a
    ret z

    ld a, [$c41f]
    ldh [hEnemyXPos], a
    ret


jr_002_6e27:
    ld a, [hl]
    add c
    ld [hl], a
    call Call_002_4736
    ld a, [en_bgCollisionResult]
    bit 0, a
    ret z

    ld a, [$c41f]
    ldh [hEnemyXPos], a
    ret


Call_002_6e39:
    ld hl, hEnemySpriteType
    ld a, [hl]
    xor $07
    ld [hl], a
    ret


Call_002_6e41:
    ld d, $00
    ld e, d
    ld hl, hEnemyYPos
    ld a, [$d03b]
    sub [hl]
    jr nc, jr_002_6e50

    cpl
    inc a
    inc e

jr_002_6e50:
    ld b, a
    inc l
    ld a, [$d03c]
    sub [hl]
    jr nc, jr_002_6e5b

    cpl
    inc a
    inc d

jr_002_6e5b:
    ld c, a
    cp b
    jr c, jr_002_6e73

    ld a, d
    and a
    jr nz, jr_002_6e70

    ld a, $02

jr_002_6e65:
    ldh [$e8], a
    xor a
    ldh [$e9], a
    ldh [hEnemyState], a
    call Call_002_6e7f
    ret


jr_002_6e70:
    xor a
    jr jr_002_6e65

jr_002_6e73:
    ld a, e
    and a
    jr nz, jr_002_6e7b

    ld a, $03
    jr jr_002_6e65

jr_002_6e7b:
    ld a, $01
    jr jr_002_6e65

Call_002_6e7f:
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $06
    jr nz, jr_002_6e8e

    ld a, $01
    ld [$c471], a
    ret


jr_002_6e8e:
    ld hl, hEnemyXPos
    ldh a, [$e8]
    and a
    jr z, jr_002_6eca

    cp $02
    jr z, jr_002_6eb4

    dec l
    dec a
    jr z, jr_002_6edd

    ld a, [hl]
    sub $05
    cp $10
    ret c

    ld [hl], a
    call Call_002_4d04
    ld a, [en_bgCollisionResult]
    bit 3, a
    ret z

    ld a, [$c41e]
    ldh [hEnemyYPos], a
    ret


jr_002_6eb4:
    ld a, [hl]
    sub $05
    cp $10
    ret c

    ld [hl], a
    call Call_002_490f
    ld a, [en_bgCollisionResult]
    bit 2, a
    ret z

    ld a, [$c41f]
    ldh [hEnemyXPos], a
    ret


jr_002_6eca:
    ld a, [hl]
    add $05
    ld [hl], a
    call Call_002_4736
    ld a, [en_bgCollisionResult]
    bit 0, a
    ret z

    ld a, [$c41f]
    ldh [hEnemyXPos], a
    ret


jr_002_6edd:
    ld a, [hl]
    add $05
    ld [hl], a
    call Call_002_4b17
    ld a, [en_bgCollisionResult]
    bit 1, a
    ret z

    ld a, [$c41e]
    ldh [hEnemyYPos], a
    ret


Call_002_6ef0:
    ld hl, hEnemyYPos
    ldh a, [$e8]
    bit 1, a
    jr nz, jr_002_6f11

    bit 3, a
    jr z, jr_002_6f23

    call Call_002_6f53
    call Call_002_4d04
    ld a, [en_bgCollisionResult]
    bit 3, a
    jr z, jr_002_6f23

    ld a, [$c41e]
    ldh [hEnemyYPos], a
    jr jr_002_6f23

jr_002_6f11:
    call Call_002_6f5b
    call Call_002_4b17
    ld a, [en_bgCollisionResult]
    bit 1, a
    jr z, jr_002_6f23

    ld a, [$c41e]
    ldh [hEnemyYPos], a

jr_002_6f23:
    ld hl, hEnemyXPos
    ldh a, [$e8]
    bit 0, a
    jr nz, jr_002_6f41

    bit 2, a
    ret z

    call Call_002_6f53
    call Call_002_490f
    ld a, [en_bgCollisionResult]
    bit 2, a
    ret z

    ld a, [$c41f]
    ldh [hEnemyXPos], a
    ret


jr_002_6f41:
    call Call_002_6f5b
    call Call_002_4736
    ld a, [en_bgCollisionResult]
    bit 0, a
    ret z

    ld a, [$c41f]
    ldh [hEnemyXPos], a
    ret


Call_002_6f53:
    ld a, [hl]
    sub $04
    cp $10
    ret c

    ld [hl], a
    ret


Call_002_6f5b:
    ld a, [hl]
    add $04
    ld [hl], a
    ret

enAI_6F60:
    call Call_002_7da0
    ld hl, $c46a
    ld a, [hl]
    and a
    jr z, jr_002_6f8e

    dec [hl]
    jr z, jr_002_6f87

    call Call_002_6ef0
    call Call_002_7df8
    ld a, [$c46d]
    cp $10
    ret nc
    ld a, $0f
    ld [sfxRequest_square1], a
    ret


jr_002_6f7f:
    call $3ca6
    ld a, $ff
    ldh [hEnemySpawnFlag], a
    ret


jr_002_6f87:
    ld a, $ff
    ldh [$e8], a
    xor a
    ldh [$e0], a

jr_002_6f8e:
    ld a, [$c41c]
    and a
    jp nz, Jump_002_7016

    ldh a, [hEnemySpawnFlag]
    cp $04
    jr z, jr_002_6fd8

    and $0f
    jr z, jr_002_6f7f

    ld a, [$c463]
    and a
    jr nz, jr_002_6fc2

    ld hl, hEnemyXPos
    ld a, [$d03c]
    sub [hl]
    jr nc, jr_002_6fb0

    cpl
    inc a

jr_002_6fb0:
    cp $50
    ret nc

    ld a, $01
    ld [$c463], a
    ; Trigger Metroid fight music
    ld a, $0c
    ld [songRequest], a
    ld a, $01
    ld [$c465], a

jr_002_6fc2:
    ldh a, [hEnemy_frameCounter]
    and $03
    ret nz

    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $10
    jp z, Jump_002_7003

    ldh a, [hEnemySpriteType]
    xor $0e
    ldh [hEnemySpriteType], a
    ret


jr_002_6fd8:
    ld a, $ad
    ldh [hEnemySpriteType], a
    ld hl, hEnemyXPos
    ld a, [$d03c]
    sub [hl]
    jr nc, jr_002_6fe7

    cpl
    inc a

jr_002_6fe7:
    cp $50
    ret nc

    xor a
    ld [$c46a], a
    inc a
    ld [$c41c], a
    ld a, $01
    ld [$c465], a
    ld a, [songPlaying]
    cp $0c
    ret z

    ; Trigger Metroid fight music
    ld a, $0c
    ld [songRequest], a
    ret


Jump_002_7003:
    xor a
    ld [hl], a
    ld a, $ad
    ldh [hEnemySpriteType], a
    xor a
    ld [$c463], a
    inc a
    ld [$c41c], a
    ld a, $04
    ldh [hEnemySpawnFlag], a
    ret


Jump_002_7016:
    ldh a, [hEnemySpawnFlag]
    cp $05
    ret z

    and $0f
    jr nz, jr_002_702e

    call Call_002_71da
    ld a, [$c46d]
    cp $10
    ret nc

    ld a, $0f
    ld [sfxRequest_square1], a
    ret


jr_002_702e:
    ld a, [$c46d]
    cp $20
    jp nc, Jump_002_713d

    cp $10
    jr z, jr_002_7044

    cp $08
    jr z, jr_002_704d

    ld a, $0f
    ld [sfxRequest_square1], a
    ret


jr_002_7044:
    call Call_002_6e41
    ld a, $1a
    ld [sfxRequest_square1], a
    ret


jr_002_704d:
    ld hl, hEnemyHealth
    dec [hl]
    ld a, [hl]
    and a
    jp z, Jump_002_7105

    ld a, $08
    ld [$c46a], a
    ld a, $05
    ld [sfxRequest_noise], a
    ld hl, $ffe8
    ld [hl], $00
    ld a, [$c46e]
    ld b, a
    bit 0, b
    jr nz, jr_002_70bc

    bit 3, b
    jr nz, jr_002_709a

    bit 1, b
    jr nz, jr_002_70dd

    ldh a, [hEnemyYPos]
    sub $05
    cp $10
    jr c, jr_002_70af

    ldh [hEnemyYPos], a
    call Call_002_4d04
    ld a, [en_bgCollisionResult]
    bit 3, a
    jr nz, jr_002_7090

    ld hl, $ffe8
    set 3, [hl]
    jr jr_002_70af

jr_002_7090:
    ld a, [$c41e]
    ldh [hEnemyYPos], a
    ld hl, $ffe8
    jr jr_002_70af

jr_002_709a:
    ldh a, [hEnemyYPos]
    add $05
    ldh [hEnemyYPos], a
    call Call_002_4b17
    ld a, [en_bgCollisionResult]
    bit 1, a
    jr nz, jr_002_7090

    ld hl, $ffe8
    set 1, [hl]

jr_002_70af:
    ld a, [rDIV]
    and $01
    jr z, jr_002_70b9

    set 0, [hl]
    ret


jr_002_70b9:
    set 2, [hl]
    ret


jr_002_70bc:
    ldh a, [hEnemyXPos]
    add $05
    ldh [hEnemyXPos], a
    call Call_002_4736
    ld a, [en_bgCollisionResult]
    bit 0, a
    jr nz, jr_002_70d3

    ld hl, $ffe8
    set 0, [hl]
    jr jr_002_70f8

jr_002_70d3:
    ld a, [$c41f]
    ldh [hEnemyXPos], a
    ld hl, $ffe8
    jr jr_002_70f8

jr_002_70dd:
    ldh a, [hEnemyXPos]
    cp $10
    jr c, jr_002_70f8

    sub $05
    ldh [hEnemyXPos], a
    call Call_002_490f
    ld a, [en_bgCollisionResult]
    bit 2, a
    jr nz, jr_002_70d3

    ld hl, $ffe8
    set 2, [hl]
    jr jr_002_70f8

jr_002_70f8:
    ld a, [rDIV]
    and $01
    jr z, jr_002_7102

    set 1, [hl]
    ret


jr_002_7102:
    set 3, [hl]
    ret


Jump_002_7105:
    xor a
    ldh [$e9], a
    ldh [hEnemyState], a
    ld a, $80
    ld [$c41c], a
    ld a, $e2
    ldh [hEnemySpriteType], a
    ld a, $0d
    ld [sfxRequest_noise], a
    ; Play "killed metroid" jingle
    ld a, $0f
    ld [songRequest], a
    ld a, $02
    ld [$c465], a
    ldh [hEnemySpawnFlag], a
    ld hl, $d089
    ld a, [hl]
    sub $01
    daa
    ld [hl], a
    ld hl, metroidCountDisplayed
    ld a, [hl]
    sub $01
    daa
    ld [hl], a
    ld a, $c0
    ld [metroidCountShuffleTimer], a
    call $3c92
    ret


Jump_002_713d:
    ldh a, [$e8]
    inc a
    jr z, jr_002_715f

    call Call_002_6e7f
    ld hl, $c471
    ld a, [hl]
    and a
    ret z

    ld [hl], $00
    ld a, $ff
    ldh [$e8], a
    xor a
    ldh [$e9], a
    ldh [hEnemyState], a
    inc a
    ld [$c41c], a
    ld a, $ad
    ldh [hEnemySpriteType], a
    ret


jr_002_715f:
    ld hl, $ffe9
    ld a, [hl]
    and a
    jr nz, jr_002_717f

    call $3d20
    ld hl, hEnemyXPos
    ld a, [hl]
    add $10
    ld b, a
    ld a, [$d03c]
    sub b
    jr c, jr_002_717c

    ld a, OAMF_XFLIP
    ldh [hEnemyAttr], a
    jr jr_002_717f

jr_002_717c:
    xor a
    ldh [hEnemyAttr], a

jr_002_717f:
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $0f
    jr nc, jr_002_7193

    call $3d48
    call Call_002_6dd4
    ld a, $b0
    ldh [hEnemySpriteType], a
    ret


jr_002_7193:
    cp $14
    ret c

    call findFirstEmptyEnemySlot_longJump
    xor a
    ld [hl+], a
    ldh a, [hEnemyYPos]
    add $0c
    ld [hl+], a
    ldh a, [hEnemyAttr]
    bit OAMB_XFLIP, a
    jr nz, jr_002_71ac

    ldh a, [hEnemyXPos]
    sub $08
    jr jr_002_71b0

jr_002_71ac:
    ldh a, [hEnemyXPos]
    add $08

jr_002_71b0:
    ld [hl+], a
    ld a, $ae
    ld [hl+], a
    ld a, $00
    ld [hl+], a
    ldh a, [hEnemyAttr]
    ld [hl+], a
    ld de, $71d0
    call Call_002_6b21
    call Call_002_7231
    ld a, $05
    ldh [hEnemySpawnFlag], a
    xor a
    ldh [$e9], a
    ld a, $14
    ld [sfxRequest_noise], a
    ret


    db $00, $00, $ff, $00, $00, $00, $ff, $07, $60, $6f

Call_002_71da:
    ldh a, [hEnemy_frameCounter]
    and $01
    ret nz

    ld hl, hEnemySpriteType
    ld a, [hl]
    cp $ae
    jr z, jr_002_7208

    dec [hl]
    ldh a, [hEnemyAttr]
    set OAMB_YFLIP, a
    ldh [hEnemyAttr], a
    ldh a, [hEnemyYPos]
    sub $0d
    ldh [hEnemyYPos], a
    ldh a, [hEnemyAttr]
    bit OAMB_XFLIP, a
    jr nz, jr_002_7201

    ldh a, [hEnemyXPos]
    add $04
    ldh [hEnemyXPos], a
    ret


jr_002_7201:
    ldh a, [hEnemyXPos]
    sub $04
    ldh [hEnemyXPos], a
    ret


jr_002_7208:
    ldh a, [hEnemyAttr]
    bit OAMB_YFLIP, a
    jr nz, jr_002_7229

    inc [hl]
    ldh a, [hEnemyYPos]
    sub $10
    ldh [hEnemyYPos], a
    ldh a, [hEnemyAttr]
    bit OAMB_XFLIP, a
    jr nz, jr_002_7222

    ldh a, [hEnemyXPos]
    sub $04
    ldh [hEnemyXPos], a
    ret


jr_002_7222:
    ldh a, [hEnemyXPos]
    add $04
    ldh [hEnemyXPos], a
    ret


jr_002_7229:
    call $3ca6
    ld a, $ff
    ldh [hEnemySpawnFlag], a
    ret


Call_002_7231:
    ld b, $07
    jr jr_002_7237

Call_002_7235:
    ld b, $0a

    jr_002_7237:
        ld a, [de]
        ld [hl+], a
        inc de
        dec b
    jr nz, jr_002_7237

    ld c, a
    xor a
    ld b, $04

    jr_002_7241:
        ld [hl+], a
        dec b
    jr nz, jr_002_7241

    ld [hl], c
    ld a, l
    add $0b
    ld l, a
    ld a, [$c477]
    ld [hl+], a
    ld b, $03

    jr_002_7250:
        ld a, [de]
        ld [hl+], a
        inc de
        dec b
    jr nz, jr_002_7250

    dec l
    dec l
    dec l
    ld a, [hl]
    ld hl, enemySpawnFlags
    ld l, a
    ld a, [$c477]
    ld [hl], a
    ld hl, $c425
    inc [hl]
    inc l
    inc [hl]
ret


    ld h, $c6
    ldh a, [hEnemySpawnFlag]
    bit 4, a
    jr z, jr_002_7274

    sub $10
    inc h

jr_002_7274:
    ld l, a
    ret

enAI_7276:
    call Call_002_7da0
    ldh a, [hEnemySpawnFlag]
    cp $06
    jp z, Jump_002_74b8

    ld a, [$c41c]
    and a
    call nz, Call_002_7dc6
    ld hl, $c46c
    ld a, [hl]
    and a
    jr z, jr_002_72b1

    dec [hl]
    jr z, jr_002_72a0

    call Call_002_7625
    ld a, [$c46d]
    cp $10
    ret nc

    ld a, $0f
    ld [sfxRequest_square1], a
    ret


jr_002_72a0:
    xor a
    ldh [$e0], a
    ld a, $ff
    ldh [$e8], a
    ld a, $b7
    ldh [hEnemySpriteType], a
    ld a, $10
    ldh [$e9], a
    ldh [hEnemyState], a

jr_002_72b1:
    ld a, [$c41c]
    cp $03
    jp nc, Jump_002_73cc

    ld b, a
    ldh a, [hEnemySpawnFlag]
    cp $04
    jr z, jr_002_7317

    ld c, a
    ld a, b
    cp $02
    jp z, Jump_002_751b

    ldh a, [hEnemySpriteType]
    sub $b2
    jp z, Jump_002_7534

    dec a
    jp z, Jump_002_757f

    ld a, [$c463]
    and a
    jr nz, jr_002_7301

    ldh a, [hEnemy_frameCounter]
    and $03
    ret nz

    ldh a, [hEnemyStunCounter]
    xor $10
    ldh [hEnemyStunCounter], a
    ld hl, hEnemyXPos
    ld a, [$d03c]
    sub [hl]
    jr nc, jr_002_72ee

    cpl
    inc a

jr_002_72ee:
    cp $50
    ret nc

    ld a, $01
    ld [$c463], a
    ; Play Metroid fight song
    ld a, $0c
    ld [songRequest], a
    ld a, $01
    ld [$c465], a
    ret


jr_002_7301:
    ldh a, [hEnemy_frameCounter]
    and $03
    ret nz

    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $08
    jp z, Jump_002_7559

    ldh a, [hEnemyStunCounter]
    xor $10
    ldh [hEnemyStunCounter], a
    ret


jr_002_7317:
    ld a, $b7
    ldh [hEnemySpriteType], a
    ld hl, hEnemyXPos
    ld a, [$d03c]
    sub [hl]
    jr nc, jr_002_7326

    cpl
    inc a

jr_002_7326:
    cp $50
    ret nc

    ld a, $10
    ldh [$e9], a
    ldh [hEnemyState], a
    xor a
    ld [$c46c], a
    ld a, $01
    ld [$c465], a
    ld a, $03
    ld [$c41c], a
    ld a, [songPlaying]
    cp $0c
    jr z, jr_002_734b

    ; Play metroid fight song
    ld a, $0c
    ld [songRequest], a
    jr jr_002_734b

Jump_002_734b:
jr_002_734b:
    ldh a, [$e8]
    inc a
    jr z, jr_002_736f

    call Call_002_6e7f
    ld hl, $c471
    ld a, [hl]
    and a
    ret z

    ld [hl], $00
    ld a, $ff
    ldh [$e8], a
    ld a, $b7
    ldh [hEnemySpriteType], a
    ld a, $10
    ldh [$e9], a
    ldh [hEnemyState], a
    ld a, $03
    ld [$c41c], a
    ret


jr_002_736f:
    ld a, [$c41c]
    cp $04
    jp nc, Jump_002_748a

    ld b, $02
    ld de, $2000
    call $3cba
    ld hl, hEnemyXPos
    ld a, [$d03c]
    sub [hl]
    jr c, jr_002_7397

    cp $20
    jr nc, jr_002_7391

    ld a, $01
    ld [$c437], a

jr_002_7391:
    ld a, OAMF_XFLIP
    ldh [hEnemyAttr], a
    jr jr_002_73a3

jr_002_7397:
    cp $e0
    jr c, jr_002_73a0

    ld a, $01
    ld [$c437], a

jr_002_73a0:
    xor a
    ldh [hEnemyAttr], a

jr_002_73a3:
    ld hl, $c437
    ld a, [hl]
    and a
    ret z

    ld [hl], $00
    ld hl, hEnemyYPos
    ld a, [$d03b]
    sub [hl]
    ret c

    cp $20
    ret nc

    call Call_002_75ac
    ld a, $05
    ldh [hEnemySpawnFlag], a
    ld a, $04
    ld [$c41c], a
    xor a
    ldh [$e9], a
    ldh [hEnemyState], a
    ld a, $b8
    ldh [hEnemySpriteType], a
    ret


Jump_002_73cc:
    ld a, [$c46d]
    cp $20
    jp nc, Jump_002_734b

    cp $10
    jr z, jr_002_73e2

    cp $08
    jr z, jr_002_73eb

jr_002_73dc:
    ld a, $0f
    ld [sfxRequest_square1], a
    ret


jr_002_73e2:
    call Call_002_6e41
    ld a, $1a
    ld [sfxRequest_square1], a
    ret


jr_002_73eb:
    ld a, [$c46e]
    ld b, a
    bit 2, b
    jr nz, jr_002_73dc

    ld hl, hEnemyHealth
    dec [hl]
    ld a, [hl]
    and a
    jr z, jr_002_7452

    ld a, $ba
    ldh [hEnemySpriteType], a
    ld a, $08
    ld [$c46c], a
    ld a, $05
    ld [sfxRequest_noise], a
    ld hl, $ffe8
    ld [hl], $00
    bit 0, b
    jr nz, jr_002_742f

    inc a
    bit 3, b
    jr nz, jr_002_741a

    inc a
    jr jr_002_7439

jr_002_741a:
    set 1, [hl]
    ldh a, [hEnemyYPos]
    add $05
    ldh [hEnemyYPos], a
    ld a, [rDIV]
    and $01
    jr z, jr_002_742c

    set 0, [hl]
    ret


jr_002_742c:
    set 2, [hl]
    ret


jr_002_742f:
    set 0, [hl]
    ldh a, [hEnemyXPos]
    add $05
    ldh [hEnemyXPos], a
    jr jr_002_7445

jr_002_7439:
    ldh a, [hEnemyXPos]
    sub $05
    cp $10
    jr c, jr_002_7445

    ldh [hEnemyXPos], a
    set 2, [hl]

jr_002_7445:
    ld a, [rDIV]
    and $01
    jr z, jr_002_744f

    set 1, [hl]
    ret


jr_002_744f:
    set 3, [hl]
    ret


jr_002_7452:
    xor a
    ldh [$e9], a
    ldh [hEnemyState], a
    ld a, $80
    ld [$c41c], a
    ld a, $e2
    ldh [hEnemySpriteType], a
    ld a, $0d
    ld [sfxRequest_noise], a
    ; Play metroid killed jingle
    ld a, $0f
    ld [songRequest], a
    ld a, $02
    ld [$c465], a
    ldh [hEnemySpawnFlag], a
    ld hl, $d089
    ld a, [hl]
    sub $01
    daa
    ld [hl], a
    ld hl, metroidCountDisplayed
    ld a, [hl]
    sub $01
    daa
    ld [hl], a
    ld a, $c0
    ld [metroidCountShuffleTimer], a
    call $3c92
    ret


Jump_002_748a:
    ld a, [$c41c]
    cp $05
    jr z, jr_002_74dc

    cp $06
    jr z, jr_002_74fe

    ldh a, [hEnemy_frameCounter]
    and $01
    ret nz

    ldh a, [$e9]
    ld hl, hEnemySpriteType
    and a
    jr z, jr_002_74a9

    ld a, [hl]
    cp $b7
    jr z, jr_002_74af

    dec [hl]
    ret


jr_002_74a9:
    inc [hl]
    ld a, $01
    ldh [$e9], a
    ret


jr_002_74af:
    xor a
    ldh [$e9], a
    ld a, $05
    ld [$c41c], a
    ret


Jump_002_74b8:
    ld a, [$c41c]
    cp $06
    jr z, jr_002_74d4

    ld hl, hEnemyYPos
    ld a, [hl]
    add $03
    cp $90
    jr nc, jr_002_74d4

    ld [hl+], a
    ldh a, [hEnemyAttr]
    bit OAMB_XFLIP, a
    jr nz, jr_002_74d2

    dec [hl]
    ret


jr_002_74d2:
    inc [hl]
    ret


jr_002_74d4:
    call $3ca6
    ld a, $ff
    ldh [hEnemySpawnFlag], a
    ret


jr_002_74dc:
    ld hl, hEnemyYPos
    call enemy_accelBackwards
    ld a, [hl+]
    cp $30
    jr c, jr_002_74f1

    ldh a, [hEnemyAttr]
    bit OAMB_XFLIP, a
    jr nz, jr_002_74ef

    dec [hl]
    ret


jr_002_74ef:
    inc [hl]
    ret


jr_002_74f1:
    ld a, $06
    ld [$c41c], a
    xor a
    ldh [$e7], a
    ld a, $b3
    ldh [hEnemySpriteType], a
    ret


jr_002_74fe:
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $20
    jr z, jr_002_750b

    call Call_002_7614
    ret


jr_002_750b:
    ld [hl], $00
    ld a, $03
    ld [$c41c], a
    ld a, $04
    ldh [hEnemySpawnFlag], a
    ld a, $b7
    ldh [hEnemySpriteType], a
    ret


Jump_002_751b:
    ld hl, hEnemySpriteType
    ld [hl], $b7
    ld a, $10
    ldh [$e9], a
    ldh [hEnemyState], a
    ld a, $04
    ldh [hEnemySpawnFlag], a
    xor a
    ld [$c463], a
    ld a, $03
    ld [$c41c], a
    ret


Jump_002_7534:
    ld a, [$c41c]
    and a
    jr nz, jr_002_753e

    call Call_002_75ff
    ret


jr_002_753e:
    ld a, $10
    ldh [hEnemyStunCounter], a
    ld hl, hEnemyYPos
    call enemy_accelForwards
    ld a, [hl]
    cp $90
    ret c

    call $3ca6
    ld a, $02
    ldh [hEnemySpawnFlag], a
    ld a, $02
    ld [$c41c], a
    ret


Jump_002_7559:
    xor a
    ld [hl], a
    ldh [hEnemyStunCounter], a
    call findFirstEmptyEnemySlot_longJump
    xor a
    ld [hl+], a
    ldh a, [hEnemyYPos]
    ld [hl+], a
    ldh a, [hEnemyXPos]
    ld [hl+], a
    ld de, $759f
    ld a, $03
    ld [$c477], a
    call Call_002_7235
    ld hl, hEnemyYPos
    ld a, [hl]
    sub $08
    ld [hl], a
    ld a, $b3
    ldh [hEnemySpriteType], a
    ret


Jump_002_757f:
    ld a, [$c41c]
    and a
    ret nz

    call Call_002_75ec
    ldh a, [hEnemy_frameCounter]
    and $07
    ret nz

    ld hl, hEnemyYPos
    dec [hl]
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $06
    ret nz

    xor a
    ld [hl], a
    inc a
    ld [$c41c], a
    ret


    db $b2, $80, $00, $00, $00, $00, $00, $00, $00, $ff, $06, $76, $72

Call_002_75ac:
    call findFirstEmptyEnemySlot_longJump
    xor a
    ld [hl+], a
    ldh a, [hEnemyYPos]
    add $04
    ld [hl+], a
    ldh a, [hEnemyAttr]
    ld b, a
    bit OAMB_XFLIP, a
    jr nz, jr_002_75c4

    ldh a, [hEnemyXPos]
    sub $18
    ld [hl+], a
    jr jr_002_75c9

jr_002_75c4:
    ldh a, [hEnemyXPos]
    add $18
    ld [hl+], a

jr_002_75c9:
    ld a, $be
    ld [hl+], a
    ld a, $80
    ld [hl+], a
    ld a, b
    ld [hl+], a
    ld de, $75e2
    ld a, $06
    ld [$c477], a
    call Call_002_7231
    ld a, $15
    ld [sfxRequest_noise], a
    ret


    db $00, $00, $ff, $00, $00, $00, $ff, $08, $76, $72

Call_002_75ec:
    ldh a, [hEnemy_frameCounter]
    and $03
    ret z

    ld hl, hEnemyXPos
    dec a
    jr z, jr_002_75fc

    dec a
    ret z

    dec [hl]
    dec [hl]
    ret


jr_002_75fc:
    inc [hl]
    inc [hl]
    ret


Call_002_75ff:
    ldh a, [hEnemy_frameCounter]
    and $03
    ret z

    ld hl, hEnemyXPos
    dec a
    jr z, jr_002_7610

    dec a
    ret z

    dec [hl]
    dec [hl]
    dec [hl]
    ret


jr_002_7610:
    inc [hl]
    inc [hl]
    inc [hl]
    ret


Call_002_7614:
    ldh a, [hEnemy_frameCounter]
    and $03
    ret nz

    ld hl, hEnemySpriteType
    ld a, [hl]
    cp $b6
    jr nz, jr_002_7623

    ld [hl], $b2

jr_002_7623:
    inc [hl]
    ret


Call_002_7625:
    ld hl, hEnemySpriteType
    ld a, [hl]
    cp $bd
    jr nz, jr_002_762f

    ld [hl], $ba

jr_002_762f:
    inc [hl]
    ret

enAI_7631:
    call Call_002_7da0
    ldh a, [hEnemySpawnFlag]
    cp $06
        jp z, Jump_002_7847

    ld a, [$c41c]
    and a
    call nz, Call_002_7dc6
    ld hl, $c462
    ld a, [hl]
    and a
    jr z, jr_002_7665

    dec [hl]
    jr z, jr_002_7660

    ldh a, [hEnemy_frameCounter]
    and $01
    ret nz

    call enemy_flipSpriteId
    ld a, [$c46d]
    cp $10
    ret nc

    ld a, $0f
    ld [sfxRequest_square1], a
    ret


jr_002_7660:
    ld a, [$c44f]
    ldh [hEnemySpriteType], a

jr_002_7665:
    ld a, [$c41c]
    and a
    jp z, Jump_002_78dc

    ld a, [$c46d]
    cp $20
        jp nc, Jump_002_771f
    cp $10
        jr z, jr_002_7682
    cp $08
        jr z, jr_002_768b

jr_002_767c:
    ld a, $0f
    ld [sfxRequest_square1], a
    ret


jr_002_7682:
    call Call_002_6e41
    ld a, $1a
    ld [sfxRequest_square1], a
    ret


jr_002_768b:
    ld a, [$c46e]
    ld b, a
    ld a, b
    and $03
    jr z, jr_002_767c

    ldh a, [hEnemyAttr]
    bit OAMB_XFLIP, a
    jr nz, jr_002_76a0

    bit 1, b
    jr z, jr_002_76b3

    jr jr_002_76a4

jr_002_76a0:
    bit 0, b
    jr z, jr_002_76b3

jr_002_76a4:
    ; Omega Metroid was hit in the back (do 3x damage)
    ld hl, hEnemyHealth
    ld a, [hl]
    sub $03
    jr c, jr_002_76e1

    jr z, jr_002_76e1

    ld [hl], a
    ld a, $10
    jr jr_002_76bb

jr_002_76b3:
    ld hl, hEnemyHealth
    dec [hl]
    jr z, jr_002_76e1

    ld a, $03

jr_002_76bb:
    ld [$c462], a
    ld hl, hEnemySpriteType
    ld a, [hl]
    ld [$c44f], a
    ld [hl], $c4
    ld a, $09
    ld [sfxRequest_noise], a
    bit 0, b
    jr z, jr_002_76d7

    ldh a, [hEnemyXPos]
    add $05
    ldh [hEnemyXPos], a
    ret


jr_002_76d7:
    ldh a, [hEnemyXPos]
    sub $05
    cp $10
    ret c

    ldh [hEnemyXPos], a
    ret


jr_002_76e1:
    xor a
    ldh [$e9], a
    ldh [hEnemyState], a
    ld [$c46f], a
    ld [$c478], a
    ld a, $80
    ld [$c41c], a
    ld a, $e2
    ldh [hEnemySpriteType], a
    ld a, $0e
    ld [sfxRequest_noise], a
    ; Play metroid killed jingle
    ld a, $0f
    ld [songRequest], a
    ld a, $02
    ld [$c465], a
    ldh [hEnemySpawnFlag], a
    ld hl, $d089
    ld a, [hl]
    sub $01
    daa
    ld [hl], a
    ld hl, metroidCountDisplayed
    ld a, [hl]
    sub $01
    daa
    ld [hl], a
    ld a, $c0
    ld [metroidCountShuffleTimer], a
    call $3c92
    ret


Jump_002_771f:
    ldh a, [$e8]
    inc a
    jr z, jr_002_7787

    call Call_002_6e7f
    ld hl, $c471
    ld a, [hl]
    and a
    ret z

    ld [hl], $00
    ld a, $ff
    ldh [$e8], a
    xor a
    ld [$c46f], a
    ld a, $03
    ld [$c478], a
    ld a, $10
    ldh [$e7], a
    ld a, $10
    ldh [$e9], a
    ld a, $10
    ldh [hEnemyState], a
    ld a, $c3
    ldh [hEnemySpriteType], a
    ld a, $05
    ld [$c41c], a
    ret


jr_002_7752:
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $38
    jr z, jr_002_775f

    call Call_002_7a42
    ret


jr_002_775f:
    ld [hl], $00
    ld a, $01
    ld [$c41c], a
    ret


jr_002_7767:
    xor a
    ldh [$e9], a
    ldh [hEnemyState], a
    ld a, $01
    ld [$c41c], a

jr_002_7771:
    ld a, $bf
    ldh [hEnemySpriteType], a
    ret


jr_002_7776:
    ld hl, hEnemyState
    ld a, [hl]
    cp $24
    jr z, jr_002_7783

    inc [hl]
    call Call_002_7a42
    ret


jr_002_7783:
    call Call_002_7a32
    ret


jr_002_7787:
    ld a, [$c41c]
    cp $05
    jr z, jr_002_77bc

    cp $06
    jr z, jr_002_7800

    cp $07
    jr z, jr_002_7752

    call Call_002_79a8
    ld a, [$c41c]
    cp $04
    jr z, jr_002_7767

    dec a
    jp z, Jump_002_7824

    ld a, [$c425]
    dec a
    jr z, jr_002_7767

    ld b, $18
    ld hl, $ffe9
    ld a, [hl]
    cp b
    jr z, jr_002_7776

    inc [hl]
    ld a, [hl]
    cp b
    jr z, jr_002_7771

    call Call_002_6b4e
    ret


jr_002_77bc:
    ld hl, $ffe7
    dec [hl]
    jr z, jr_002_77f3

    ld a, [$c478]
    cp $04
    jr z, jr_002_77d0

    ld a, [samusPose]
    cp pose_crouch
    jr z, jr_002_77f3

jr_002_77d0:
    ld b, $02
    ld de, $2000
    call $3cba
    ld hl, hEnemyXPos
    ld a, [$d03c]
    sub [hl]
    jr c, jr_002_77eb

    cp $10
    jr c, jr_002_77f2

    ld a, OAMF_XFLIP
    ldh [hEnemyAttr], a
    jr jr_002_77f2

jr_002_77eb:
    cp $f0
    jr nc, jr_002_77f2

    xor a
    ldh [hEnemyAttr], a

jr_002_77f2:
    ret


jr_002_77f3:
    ld a, $06
    ld [$c41c], a
    xor a
    ldh [$e7], a
    ldh [$e9], a
    ldh [hEnemyState], a
    ret


jr_002_7800:
    ld hl, hEnemyYPos
    call enemy_accelBackwards
    ld a, [hl+]
    cp $34
    jr c, jr_002_7817

    ldh a, [hEnemyAttr]
    bit OAMB_XFLIP, a
    jr nz, jr_002_7814

    dec [hl]
    dec [hl]
    ret


jr_002_7814:
    inc [hl]
    inc [hl]
    ret


jr_002_7817:
    ld a, $07
    ld [$c41c], a
    xor a
    ldh [$e7], a
    ld a, $bf
    ldh [hEnemySpriteType], a
    ret


Jump_002_7824:
    call Call_002_7a32
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $10
    ret nz

    ld [hl], $00
    call Call_002_7922
    ld a, $02
    ld [$c41c], a
    ld a, $05
    ldh [hEnemySpawnFlag], a
    ld a, $c1
    ldh [hEnemySpriteType], a
    ld a, $15
    ld [sfxRequest_noise], a
    ret


Jump_002_7847:
    ld a, [$c465]
    cp $02
    jp z, Jump_002_78c8

    ldh a, [hEnemySpriteType]
    cp $c8
    jr nc, jr_002_78b9

    ld hl, $ffe9
    ld a, [hl]
    and a
    jr nz, jr_002_7861

    ld [hl], $01
    call $3d20

jr_002_7861:
    call $3d48
    ld a, b
    and a
    jr z, jr_002_7890

    bit 7, b
    jr z, jr_002_7880

    res 7, b
    ld hl, hEnemyYPos
    ld a, [hl]
    sub b
    ld [hl], a
    call Call_002_4bc2
    ld a, [en_bgCollisionResult]
    bit 3, a
    jr nz, jr_002_78a9

    jr jr_002_7890

jr_002_7880:
    ld hl, hEnemyYPos
    ld a, [hl]
    add b
    ld [hl], a
    call Call_002_49ba
    ld a, [en_bgCollisionResult]
    bit 1, a
    jr nz, jr_002_78a9

jr_002_7890:
    ld hl, hEnemyXPos
    bit 7, c
    jr z, jr_002_789d

    res 7, c
    ld a, [hl]
    sub c
    jr jr_002_789f

jr_002_789d:
    ld a, [hl]
    add c

jr_002_789f:
    ld [hl], a
    ldh a, [hEnemy_frameCounter]
    and $03
    ret nz

    call enemy_flipSpriteId
    ret


jr_002_78a9:
    ld a, [en_bgCollisionResult]
    ld [$c42d], a
    xor a
    ldh [$e9], a
    ldh [hEnemyState], a
    ld a, $c8
    ldh [hEnemySpriteType], a
    ret


jr_002_78b9:
    ld hl, hEnemySpriteType
    ld a, [hl]
    cp $cc
    jr z, jr_002_78c8

    ldh a, [hEnemy_frameCounter]
    and $01
    ret nz

    inc [hl]
    ret


Jump_002_78c8:
jr_002_78c8:
    call $3ca6
    ld a, $ff
    ldh [hEnemySpawnFlag], a
    ld hl, $c41c
    ld a, [hl]
    cp $02
    ret nz

    ld a, $04
    ld [$c41c], a
    ret


Jump_002_78dc:
    ldh a, [hEnemySpawnFlag]
    cp $04
    jp z, Jump_002_7950

    ld a, [$c463]
    and a
    jr nz, jr_002_790c

    ld hl, hEnemyXPos
    ld a, [hl]
    add $10
    ld b, a
    ld a, [$d03c]
    add $10
    sub b
    jr nc, jr_002_78fa

    cpl
    inc a

jr_002_78fa:
    cp $50
    ret nc

    ld a, $01
    ld [$c463], a
    ; Trigger Metroid fight music
    ld a, $0c
    ld [songRequest], a
    ld a, $01
    ld [$c465], a

jr_002_790c:
    ldh a, [hEnemy_frameCounter]
    and $03
    ret nz

    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $18
    jp z, Jump_002_798b

    ldh a, [hEnemySpriteType]
    xor $0c
    ldh [hEnemySpriteType], a
    ret


Call_002_7922:
    call findFirstEmptyEnemySlot_longJump
    xor a
    ld [hl+], a
    ldh a, [hEnemyYPos]
    ld [hl+], a
    ldh a, [hEnemyAttr]
    ld b, a
    bit OAMB_XFLIP, a
    jr nz, jr_002_7938

    ldh a, [hEnemyXPos]
    sub $10
    ld [hl+], a
    jr jr_002_793d

jr_002_7938:
    ldh a, [hEnemyXPos]
    add $10
    ld [hl+], a

jr_002_793d:
    ld a, $c6
    ld [hl+], a
    xor a
    ld [hl+], a
    ld a, b
    ld [hl+], a
    ld de, $799e
    ld a, $06
    ld [$c477], a
    call Call_002_7231
    ret


Jump_002_7950:
    ld a, $bf
    ldh [hEnemySpriteType], a
    ld hl, hEnemyXPos
    ld a, [$d03c]
    sub [hl]
    jr nc, jr_002_795f

    cpl
    inc a

jr_002_795f:
    cp $50
    ret nc

    xor a
    ldh [$e7], a
    ldh [$e9], a
    ldh [hEnemyState], a
    ld [$c462], a
    ld [$c46f], a
    ld [$c478], a
    inc a
    ld [$c41c], a
    ld a, $01
    ld [$c465], a
    ld a, $ff
    ldh [$e8], a
    ld a, [songPlaying]
    cp $0c
    ret z

    ; Trigger Metroid fight music
    ld a, $0c
    ld [songRequest], a
    ret


Jump_002_798b:
    xor a
    ld [hl], a
    ld a, $bf
    ldh [hEnemySpriteType], a
    xor a
    ld [$c463], a
    inc a
    ld [$c41c], a
    ld a, $04
    ldh [hEnemySpawnFlag], a
    ret


    db $00, $00, $ff, $00, $00, $00, $ff, $08, $31, $76

Call_002_79a8:
    ld hl, $c46f
    ld a, [hl]
    cp $40
    jr z, jr_002_79b2

    inc [hl]
    ret


jr_002_79b2:
    ld [hl], $00
    ld hl, samusCurHealthLow
    ld a, [$c470]
    sub [hl]
    cp $30
    jr nc, jr_002_79d0

    ld hl, $c478
    inc [hl]
    ld a, [hl]
    dec a
    jr z, jr_002_79d8

    dec a
    jr z, jr_002_79dc

    dec a
    jr z, jr_002_79e0

    dec a
    jr z, jr_002_79e4

jr_002_79d0:
    xor a
    ld [$c478], a
    ld a, $0c
    jr jr_002_79e6

jr_002_79d8:
    ld a, $14
    jr jr_002_79e6

jr_002_79dc:
    ld a, $28
    jr jr_002_79e6

jr_002_79e0:
    ld a, $40
    jr jr_002_79e6

jr_002_79e4:
    ld a, $60

jr_002_79e6:
    ldh [$e7], a
    ld a, [samusCurHealthLow]
    ld [$c470], a
    ld a, $10
    ldh [$e9], a
    ld a, $10
    ldh [hEnemyState], a
    ld a, $c3
    ldh [hEnemySpriteType], a
    ld a, $2d
    ld [sfxRequest_square1], a
    ld a, $05
    ld [$c41c], a
    pop af
    ret


    ld b, $05
    ld de, hEnemyYPos
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    dec a
    jr z, jr_002_7a1d

    dec a
    jr z, jr_002_7a25

    dec a
    jr z, jr_002_7a2d

    ld [hl], $00
    jr jr_002_7a20

jr_002_7a1d:
    ld a, [de]
    sub b
    ld [de], a

jr_002_7a20:
    inc e
    ld a, [de]
    sub b
    ld [de], a
    ret


jr_002_7a25:
    ld a, [de]
    sub b
    ld [de], a

jr_002_7a28:
    inc e
    ld a, [de]
    add b
    ld [de], a
    ret


jr_002_7a2d:
    ld a, [de]
    add b
    ld [de], a
    jr jr_002_7a28

Call_002_7a32:
    ld hl, hEnemyXPos
    ld a, [$d03c]
    sub [hl]
    jr nc, jr_002_7a3e

    xor a
    jr jr_002_7a40

jr_002_7a3e:
    ld a, OAMF_XFLIP

jr_002_7a40:
    ldh [hEnemyAttr], a

Call_002_7a42:
    ldh a, [hEnemy_frameCounter]
    and $03
    ret nz

    ld hl, hEnemySpriteType
    ld a, [hl]
    xor $7f
    ld [hl], a
    ret

enAI_7A4F:
    call Call_002_7da0
    ldh a, [$e7]
    and a
    jr z, jr_002_7ac0

    call Call_002_7bcc
    ld a, [$c475]
    and a
    jr z, jr_002_7ab0

    dec a
    jr z, jr_002_7a71

    call Call_002_7bd9
    ld a, [$c46d]
    cp $09
    ret nz

    ld hl, $c475
    dec [hl]
    ret


jr_002_7a71:
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $18
    jr z, jr_002_7ab0

    ld a, $02
    ld [$c474], a
    ldh a, [hEnemyYPos]
    sub $03
    cp $10
    jr c, jr_002_7a98

    ldh [hEnemyYPos], a
    call Call_002_4d04
    ld a, [en_bgCollisionResult]
    bit 3, a
    jr z, jr_002_7a98

    ld a, [$c41e]
    ldh [hEnemyYPos], a

jr_002_7a98:
    ldh a, [hEnemyXPos]
    sub $03
    cp $10
    ret c

    ldh [hEnemyXPos], a
    call Call_002_490f
    ld a, [en_bgCollisionResult]
    bit 2, a
    ret z

    ld a, [$c41f]
    ldh [hEnemyXPos], a
    ret


jr_002_7ab0:
    xor a
    ld [$c474], a
    ldh [$e7], a
    ld [$c475], a
    ld a, $10
    ldh [$e9], a
    ldh [hEnemyState], a
    ret


jr_002_7ac0:
    ld hl, $c473
    ld a, [hl]
    and a
    jr z, jr_002_7acd

    dec [hl]
    ret nz

    ld a, $ce
    ldh [hEnemySpriteType], a

jr_002_7acd:
    ldh a, [hEnemyIceCounter]
    and a
    jr z, jr_002_7b43

    call Call_002_565f
    ldh a, [hEnemyIceCounter]
    and a
    jr z, jr_002_7aee

    ld a, [$c46d]
    cp $20
    ret nc

    cp $08
    jr z, jr_002_7afd

    dec a
    jp z, Jump_002_7b92

    ld a, $0f
    ld [sfxRequest_square1], a
    ret


jr_002_7aee:
    ld a, $10
    ldh [$e9], a
    ldh [hEnemyState], a
    ld a, $ce
    ldh [hEnemySpriteType], a
    ld a, $05
    ldh [hEnemyHealth], a
    ret


jr_002_7afd:
    ld hl, hEnemyHealth
    dec [hl]
    ld a, [hl]
    and a
    jr z, jr_002_7b14

    ld a, $03
    ld [$c473], a
    ld a, $cf
    ldh [hEnemySpriteType], a
    ld a, $05
    ld [sfxRequest_noise], a
    ret


jr_002_7b14:
    xor a
    ldh [$e9], a
    ld [$c474], a
    ld [$c475], a
    ld a, $02
    ldh [hEnemySpawnFlag], a
    ld a, $10
    ldh [$ee], a
    ld a, $0d
    ld [sfxRequest_noise], a
    ld hl, $d089
    ld a, [hl]
    sub $01
    daa
    ld [hl], a
    ld hl, metroidCountDisplayed
    ld a, [hl]
    sub $01
    daa
    ld [hl], a
    ld a, $c0
    ld [metroidCountShuffleTimer], a
    call $3c92
    ret


jr_002_7b43:
    call Call_002_7bcc
    ld a, [$c46d]
    cp $ff
    jp z, Jump_002_7ba3

    cp $20
    jp z, Jump_002_7b64

    cp $10
    jr z, jr_002_7b86

    cp $09
    jr z, jr_002_7b86

    dec a
    jr z, jr_002_7b92

    ld a, $0f
    ld [sfxRequest_square1], a
    ret


Jump_002_7b64:
    ld hl, $c474
    ld a, [hl]
    cp $02
    jr z, jr_002_7b79

    cp $01
    jr z, jr_002_7b75

    ld a, $01
    ld [$c474], a

jr_002_7b75:
    ld a, $02
    jr jr_002_7b7b

jr_002_7b79:
    ld a, $01

jr_002_7b7b:
    ld [$c475], a
    ld a, $01
    ldh [$e7], a
    xor a
    ldh [$e9], a
    ret


jr_002_7b86:
    xor a
    ldh [$e9], a
    call Call_002_6e41
    ld a, $1a
    ld [sfxRequest_square1], a
    ret


Jump_002_7b92:
jr_002_7b92:
    ld a, $1a
    ld [sfxRequest_square1], a
    ld a, $10
    ldh [hEnemyStunCounter], a
    ld a, $44
    ldh [hEnemyIceCounter], a
    xor a
    ldh [$e0], a
    ret


Jump_002_7ba3:
    ldh a, [$e8]
    inc a
    jr z, jr_002_7bc0

    call Call_002_6e7f
    ld hl, $c471
    ld a, [hl]
    and a
    ret z

    ld [hl], $00
    ld a, $ff
    ldh [$e8], a
    ld a, $10
    ldh [$e9], a
    ld a, $10
    ldh [hEnemyState], a
    ret


jr_002_7bc0:
    ld b, $01
    ld de, $1e02
    call $3cba
    call Call_002_7cdd
    ret


Call_002_7bcc:
    ldh a, [hEnemy_frameCounter]
    and $03
    ret nz

    ld hl, hEnemySpriteType
    ld a, [hl]
    xor $6e
    ld [hl], a
    ret


Call_002_7bd9:
    ld hl, hEnemyYPos
    ld a, [$d03b]
    ld [hl+], a
    ld a, [$d03c]
    ld [hl], a
    ret

;------------------------------------------------------------------------------
enAI_7BE5: ; the baby?
    ld a, [$c41c]
    and a
        jr z, jr_002_7c20 ; case 0
    dec a
        jr z, jr_002_7c04 ; case 1
    dec a
        jp nz, Jump_002_7c8d ; case 2
    ; default case
    call Call_002_6b3a
    ld b, $02
    ld de, $2000
    call $3cba
    call Call_002_7d2a
    call Call_002_7ddc
ret


jr_002_7c04: ; case 1
    call Call_002_75ff
    ld hl, hEnemyYPos
    dec [hl]
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $0c
        ret nz
    ld a, $10
    ld [hl+], a
    ld [hl], a
    ld hl, $c41c
    inc [hl]
    xor a
    ld [$c463], a
ret


jr_002_7c20: ; case 0
    ldh a, [hEnemySpawnFlag]
    cp $04
    jr z, jr_002_7c6b
        call Call_002_7caf
        ld hl, hEnemyXPos
        ld a, [$d03c]
        sub [hl]
        jr nc, jr_002_7c34
            cpl
            inc a
        jr_002_7c34:
    
        cp $18
            ret nc
        dec l
        ld a, [$d03b]
        sub [hl]
        jr nc, jr_002_7c40
            cpl
            inc a
        jr_002_7c40:
    
        cp $10
            ret nc
        ld a, $01
        ld [$c463], a
        call Call_002_7cbc
        ld hl, hEnemyState
        inc [hl]
        ld a, [hl]
        cp $30
            ret nz
        xor a
        ld [hl-], a
        ld [hl], a
        ldh [hEnemyStunCounter], a
        ld a, $03
        ld [$c41c], a
        ld hl, $c465
        inc [hl]
        ld a, $04
        ldh [hEnemySpawnFlag], a
        ld a, $16
        ld [sfxRequest_noise], a
        ret
    jr_002_7c6b:
        ld a, $a8
        ldh [hEnemySpriteType], a
        ld hl, hEnemyXPos
        ld a, [$d03c]
        sub [hl]
        jr nc, jr_002_7c7a
            cpl
            inc a
        jr_002_7c7a:
        
        cp $60
            ret nc
        ld a, $01
        ld [$c465], a
        ld a, $02
        ld [$c41c], a
        ld a, $16
        ld [sfxRequest_noise], a
        ret
; end proc

Jump_002_7c8d: ; Case 2
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    bit 0, a
    jr z, jr_002_7c9d
        srl a
        add $e2
        ldh [hEnemySpriteType], a
        ret
    jr_002_7c9d:
        cp $0c
            call z, Call_002_7ca7
        ld a, $a8
        ldh [hEnemySpriteType], a
        ret


Call_002_7ca7:
    ld [hl], $00
    ld a, $01
    ld [$c41c], a
ret


Call_002_7caf:
    ; Flash every 4 frames
    ldh a, [hEnemy_frameCounter]
    and $03
        ret nz
    ld hl, hEnemyStunCounter
    ld a, [hl]
    xor $10
    ld [hl], a
ret


Call_002_7cbc:
    ldh a, [hEnemy_frameCounter]
    and $01
        ret nz
    ld hl, hEnemySpriteType
    ldh a, [$e9]
    dec a
    jr z, jr_002_7cd6
        inc [hl]
        ld a, [hl]
        cp $a7
        ret nz
    jr_002_7cce:
        ld hl, $ffe9
        ld a, [hl]
        xor $01
        ld [hl], a
        ret
    jr_002_7cd6:

    dec [hl]
    ld a, [hl]
    cp $a5
        ret nz
    jr jr_002_7cce


Call_002_7cdd:
    ldh a, [$e9]
    cp $10
    jr c, jr_002_7cf4

    call Call_002_4b17
    ld a, [en_bgCollisionResult]
    bit 1, a
    jr z, jr_002_7d04

jr_002_7ced:
    ld a, [$c41e]
    ldh [hEnemyYPos], a
    jr jr_002_7d04

jr_002_7cf4:
    ldh a, [hEnemyYPos]
    cp $10
    jr c, jr_002_7ced

    call Call_002_4d04
    ld a, [en_bgCollisionResult]
    bit 3, a
    jr nz, jr_002_7ced

jr_002_7d04:
    ldh a, [hEnemyState]
    cp $10
        jr c, jr_002_7d19

    call Call_002_4736
    ld a, [en_bgCollisionResult]
    bit 0, a
    ret z

jr_002_7d13:
    ld a, [$c41f]
    ldh [hEnemyXPos], a
    ret


jr_002_7d19:
    ldh a, [hEnemyXPos]
    cp $10
    jr c, jr_002_7d13

    call Call_002_490f
    ld a, [en_bgCollisionResult]
    bit 2, a
    jr nz, jr_002_7d13

    ret


Call_002_7d2a:
    ld hl, hEnemyXPos
    ld a, [hl]
    ld [$c43b], a
    ld a, [$c41f]
    ld [hl], a
    ldh a, [$e9]
    cp $10
    jr c, jr_002_7d54

    call Call_002_4a28
    ld a, [en_bgCollisionResult]
    bit 1, a
    jr z, jr_002_7d64

jr_002_7d45:
    ld a, [$c417]
    cp $64
    call z, Call_002_7d97

jr_002_7d4d:
    ld a, [$c41e]
    ldh [hEnemyYPos], a
    jr jr_002_7d64

jr_002_7d54:
    ldh a, [hEnemyYPos]
    cp $10
    jr c, jr_002_7d4d

    call Call_002_4c30
    ld a, [en_bgCollisionResult]
    bit 3, a
    jr nz, jr_002_7d45

jr_002_7d64:
    ld a, [$c43b]
    ldh [hEnemyXPos], a
    ldh a, [hEnemyState]
    cp $10
    jr c, jr_002_7d86

    call Call_002_4662
    ld a, [en_bgCollisionResult]
    bit 0, a
    ret z

jr_002_7d78:
    ld a, [$c417]
    cp $64
    call z, Call_002_7d97

jr_002_7d80:
    ld a, [$c41f]
    ldh [hEnemyXPos], a
    ret


jr_002_7d86:
    ldh a, [hEnemyXPos]
    cp $10
    jr c, jr_002_7d80

    call Call_002_483b
    ld a, [en_bgCollisionResult]
    bit 2, a
    jr nz, jr_002_7d78

    ret


Call_002_7d97:
    call $3cce
    ld a, $16
    ld [sfxRequest_noise], a
    ret

; Theory: This copies collision test results for the working enemy from HRAM to WRAM
Call_002_7da0:
    ld a, $ff
    ld [$c46d], a
    ld c, a
    ; if($c467 != $FFFD) then exit
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
    ld c, [hl]
    ld a, $ff
    ld [hl+], a
    ld [hl+], a
    ld [hl+], a
    ld b, [hl]
    ld [hl], a
    ld a, c
    ld [$c46d], a
    ld a, b
    ld [$c46e], a
ret


Call_002_7dc6:
    ld bc, $1890
    ld hl, hEnemyYPos
    ld a, [hl]
    cp b
    jr nc, jr_002_7dd1

    ld [hl], b

jr_002_7dd1:
    inc l
    ld a, [hl]
    cp b
    jr nc, jr_002_7dd8

    ld [hl], b
    ret


jr_002_7dd8:
    cp c
    ret c

    ld [hl], c
    ret


Call_002_7ddc:
    ld bc, $1890
    ld hl, hEnemyYPos
    ld a, [hl]
    cp b
    jr nc, jr_002_7de9

    ld [hl], b
    jr jr_002_7ded

jr_002_7de9:
    cp c
    jr c, jr_002_7ded

    ld [hl], c

jr_002_7ded:
    inc l
    ld a, [hl]
    cp b
    jr nc, jr_002_7df4

    ld [hl], b
    ret


jr_002_7df4:
    cp c
    ret c

    ld [hl], c
    ret


Call_002_7df8:
    ; Exit if the frame is odd
    ldh a, [hEnemy_frameCounter]
    and $01
        ret nz
    ; Toggle visibility
    ld hl, $ffe0
    ld a, [hl]
    xor $80
    ld [hl], a
    ret

; 02:7E05 - Freespace 