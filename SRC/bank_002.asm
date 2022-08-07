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

    ld a, [metroid_fightActive]
    and a
        jr z, jr_002_4063 ; case 0 - no metroids
    cp $02
        jr z, jr_002_4039 ; case 2 - metroid exploding
    ; case 1 (default) - metroid fight active

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
    ld [metroid_fightActive], a

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

    call scrollEnemies_farCall ; Adjust enemy positions due to scrolling
    call Call_002_409e ; Handle each enemy
    call updateScrollHistory
    ld a, [rLY]
    cp $70
        ret nc

    call drawEnemies_farCall
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
        ld a, [numEnemies]
        ld [$c439], a
    jr_002_40ba:

    ld a, [$c439]
    and a
    jp z, Jump_002_4110

jr_002_40c1:
    ; Check if enemy if active
    ld a, [hl]
    and $0f
        jr z, jr_002_40cc

    dec a
    jr z, jr_002_40f6
        jr_002_40c9:
            add hl, de
            jr jr_002_40c1
        
        jr_002_40cc:
            call enemy_moveFromWramToHram
            call Call_002_4239 ; Explosion/drop handler?
            call Call_002_452e ; Check if offscreen
            call Call_002_5630 ; Enemy AI and related stuffs
        
        Jump_002_40d8:
        jr_002_40d8:
            call enemy_moveFromHramToWram
            ld a, [$c439]
            dec a
            ld [$c439], a
                jr z, jr_002_4110
        
            ld de, $0020
            ; Reload enemy base address
            ldh a, [$fc]
            ld l, a
            ldh a, [$fd]
            ld h, a
            ; Stop processing enemies (to avoid lag)
            ld a, [rLY]
            cp $58
                jr nc, jr_002_4101
    
        jr jr_002_40c9
    jr_002_40f6:
    
    call enemy_moveFromWramToHram
    call Call_002_4464 ; Delete enemy that is sufficiently offscreen
    call Call_002_44c0 ; Check if back onscreen
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

    call Call_000_3de2 ; Load enemies?
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
    ld [metroid_fightActive], a
    ld [cutsceneActive], a
    ld [numEnemies], a
    ld [numActiveEnemies], a
    ld [numOffscreenEnemies], a
    ld [$c438], a
    ld a, $ff
    ld [$c466], a
    ld [$c467], a
    ld [$c468], a
    ld [$c46d], a
    ld hl, $c432
    ld a, [scrollY]
    ld [hl+], a
    ld [hl+], a
    ld a, [scrollX]
    ld [hl+], a
    ld [hl], a
    call blobThrower_loadSprite
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
    ld a, [scrollY]
    ld [hl+], a
    ld [hl+], a
    ld a, [scrollX]
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
    ld hl, hEnemyWorkingHram ;$ffe0

    jr_002_422a: ; Clear enemy temps in HRAM
        ld [hl+], a
        dec b
    jr nz, jr_002_422a

    xor a
    ld hl, numEnemies
    ld b, $03

    jr_002_4234:
        ld [hl+], a
        dec b
    jr nz, jr_002_4234
ret

;------------------------------------------------------------------------------
; Important per-enemy routine
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

    ldh a, [hEnemyExplosionFlag]
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
    call Call_000_3ca6
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
    ld hl, weaponDamageTable
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
    jr jr_002_438f ; Exit

jr_002_434c: ; if enemy health == 0 (it dead)
    ; Prep explosion flag and determine drop
    ld b, $10

jr_002_434e:
    ldh a, [hEnemySpawnFlag]
    cp $06
        jr z, .smallHealth

    and $0f
        jr z, .smallHealth

    ldh a, [hEnemyMaxHealth]
    cp $fd
        jr z, .setExplosion ; If max health == $FD (only arachnus?)
    cp $fe
        jr z, .setExplosion ; If max health == $FE (no enemies??)
    bit 0, a
        jr z, .missileDrop ; If max health is even
    cp $0a
        jr c, .smallHealth ; If max health is less than 10

    set 1, b ; Large health
        jr .setExplosion
.smallHealth:
    set 0, b ; Small health
        jr .setExplosion
.missileDrop:
    set 2, b ; Missile drop
.setExplosion:
    ld a, b
    ldh [hEnemyExplosionFlag], a
    ; Clear timer
    xor a
    ldh [$e9], a
    ld a, $02
    ld [sfxRequest_noise], a

jr_002_437f:
    call Call_002_438f
    pop af
    jp Jump_002_40d8 ; Skip to next enemy

; 02:4386 - Unused branch
    call Call_000_3ca6
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
    ; Check for directional vulnerabilities
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

weaponDamageTable: ; 02:43C8
    db $01 ; $00 - Power Beam
    db $02 ; $01 - Ice Beam
    db $04 ; $02 - Wave Beam
    db $08 ; $03 - Spazer Beam
    db $1E ; $04 - Plasma Beam (30!?)
    db $00 ; $05 - x
    db $00 ; $06 - x
    db $02 ; $07 - Bomb Beam !?
    db $14 ; $08 - Missiles (20!)
    db $0A ; $09 - Bomb Explosion

enemy_moveFromWramToHram: ; 02:43D2
    ld a, l
    ldh [$fc], a
    ld a, h
    ldh [$fd], a
    ld b, $0f
    ld de, hEnemyWorkingHram ; $FFE0

    jr_002_43dd:
        ld a, [hl+]
        ld [de], a
        inc e
        dec b
    jr nz, jr_002_43dd

    ld a, [hl+] ; enemyOffset + $0F
    ldh [hEnemyYScreen], a
    ld a, [hl+] ; enemyOffset + $10
    ldh [hEnemyXScreen], a
    ld a, [hl] ; enemyOffset + $11
    ldh [hEnemyMaxHealth], a
    
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
    ld [enemy_yPosMirror], a
    ldh a, [hEnemyXPos]
    ld [enemy_xPosMirror], a
    ; Return if stun counter is less than $11
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
; end proc

enemy_moveFromHramToWram: ; 02:4421
    ld b, $0f
    ld de, hEnemyWorkingHram ; $FFE0
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

    ldh a, [hEnemyYScreen]
    ld [hl+], a
    ldh a, [hEnemyXScreen]
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

; Delete enemies that are sufficiently off-screen
Call_002_4464:
    ld hl, hEnemyYScreen
    ld a, [hl+]
    cp $fe
        jr z, jr_002_4470
    cp $03
        jr nz, jr_002_44b6

jr_002_4470:
    ld hl, hEnemyWorkingHram
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
    ld hl, numEnemies
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
; end proc

; Check if offscreen enemy needs to be reactivated
Call_002_44c0:
; ypos part
    ld hl, hEnemyYScreen
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

; xpos part
jr_002_44ee:
    inc l ; enemyXScreen
    inc e ; enemyXPos
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
    ; Exit if enemy is offscreen
    ldh a, [hEnemyYScreen]
    ld b, a
    ldh a, [hEnemyXScreen]
    or b
        ret nz
    ; Reactivate enemy
    ld hl, hEnemyStatus
    ld [hl], $00
    ld hl, numActiveEnemies
    inc [hl]
    inc l
    dec [hl]
    pop af
    jp Jump_002_40d8

; Check if enemy needs to be deactivated for being offscreen
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
    ldh [hEnemyYScreen], a
    jr jr_002_454c

jr_002_4548:
    ld a, $01
    ldh [hEnemyYScreen], a

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
    ldh [hEnemyXScreen], a
    jr jr_002_4568

jr_002_4564:
    ld a, $01
    ldh [hEnemyXScreen], a

jr_002_4568:
    ld a, $01
    ld [$c479], a

jr_002_456d:
    ld a, [$c479]
    and a
    ret z

    ld hl, hEnemyStatus
    ld [hl], $01
    ldh a, [hEnemySpawnFlag]
    cp $02
    jr z, jr_002_459d

    cp $06
    jr z, jr_002_45a8

    and $0f
    jr z, jr_002_45a8

    ; Deactivate enemy
    ld hl, numActiveEnemies
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
    call Call_000_3ca6
    ld a, $02
    ldh [hEnemySpawnFlag], a
    pop af
    jp Jump_002_40d8


jr_002_45a8:
    call Call_000_3ca6
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


updateScrollHistory:
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
    ld de, scrollY
    ld a, [de]
    ld [hl+], a
    inc e
    ld a, [de]
    ld [hl], a
ret

unknown_002_45E4: ; 02:45E4 - Unreferenced
    ld a, [samus_onscreenXPos]
    ld b, a
    ld hl, hEnemyXPos
    ld a, [hl]
    cp b
    jr nc, .else
        xor a
        ld [$c40e], a ; Variable appears to be unused
        ret
    .else:
        ld a, $02
        ld [$c40e], a
        ret
; end proc

unknown_002_45FA: ; 02:45FA - Unreferenced
    ld hl, hEnemyAttr
    ldh a, [$e8]
    and a
    jr z, .else
        ld [hl], $00
        ret
    .else:
        ld [hl], OAMF_XFLIP
        ret
; end proc

;------------------------------------------------------------------------------
; Beginning of enemy tilemap collision routines
;
; "$11 routines" = Check right side of object
; 8 routines (2 unused)
enCollision_right:

.nearSmall: ; 02:4608
;(3,-3)
;(3, 3)
    ld a, $11
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $03
    ld [enemy_testPointYPos], a
    ldh a, [hEnemyXPos]
    add $03
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointYPos]
    add $06
    ld [enemy_testPointYPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    jr .exitA

.midSmall: ; 02:4635 - Unused
;(7,-3)
;(7, 3)
    ld a, $11
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $03
    ld [enemy_testPointYPos], a
    ldh a, [hEnemyXPos]
    add $07
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointYPos]
    add $06
    ld [enemy_testPointYPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    jr .exitA

.midMedium: ; 02:4662 - Note: saves tile number to $C417
;(7,-6)
;(7, 0)
;(7, 6)
    ld a, $11
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $06
    ld [enemy_testPointYPos], a
    ldh a, [hEnemyXPos]
    add $07
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld [$c417], a
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointYPos]
    add $06
    ld [enemy_testPointYPos], a
    call enemy_getTileIndex
    ld [$c417], a
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointYPos]
    add $06
    ld [enemy_testPointYPos], a
    call enemy_getTileIndex
    ld [$c417], a
    ld hl, enemySolidityIndex
    cp [hl]
        ret c

.exitA:
    ld hl, en_bgCollisionResult
    res 0, [hl]
    ret

.farMedium: ; 02:46AC
;(11,-7)
;(11, 0)
;(11, 7)
    ld a, $11
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $07
    ld [enemy_testPointYPos], a
    ldh a, [hEnemyXPos]
    add $0b
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointYPos]
    add $07
    ld [enemy_testPointYPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointYPos]
    add $07
    ld [enemy_testPointYPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    jr .exitA

.midWide: ; 02:46E9 - Unused
;(7,-11)
;(7, -3)
;(7,  3)
;(7, 11)
    ld a, $11
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $0b
    ld [enemy_testPointYPos], a
    ldh a, [hEnemyXPos]
    add $07
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointYPos]
    add $08
    ld [enemy_testPointYPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointYPos]
    add $06
    ld [enemy_testPointYPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointYPos]
    add $08
    ld [enemy_testPointYPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    jr .exitB

.farWide: ; 02:4736
;(11,-11)
;(11. -3)
;(11,  3)
;(11, 11)
    ld a, $11
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $0b
    ld [enemy_testPointYPos], a
    ldh a, [hEnemyXPos]
    add $0b
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointYPos]
    add $08
    ld [enemy_testPointYPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointYPos]
    add $06
    ld [enemy_testPointYPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointYPos]
    add $08
    ld [enemy_testPointYPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    jr .exitB

.crawlA: ; 02:4783
;(7,-8)
;(7, 7)
    ld a, $11
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $08
    ld [enemy_testPointYPos], a
    ldh a, [hEnemyXPos]
    add $07
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointYPos]
    add $0f
    ld [enemy_testPointYPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c

.exitB:
    ld hl, en_bgCollisionResult
    res 0, [hl]
    ret

.crawlB: ; 02:47B4
;(7,-7)
;(7, 8)
    ld a, $11
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $07
    ld [enemy_testPointYPos], a
    ldh a, [hEnemyXPos]
    add $07
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointYPos]
    add $0f
    ld [enemy_testPointYPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    jr .exitB

;------------------------------------------------------------------------------
; "$44 functions" = Check left edge of object
; 8 functions (2 unused)
enCollision_left:

.nearSmall: ; 02:47E1
;(-3,-3)
;(-3, 3)
    ld a, $44
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $03
    ld [enemy_testPointYPos], a
    ldh a, [hEnemyXPos]
    sub $03
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointYPos]
    add $06
    ld [enemy_testPointYPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    jr .exitA

.midSmall: ; 02:480E - Unused
;(-7,-3)
;(-7, 3)
    ld a, $44
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $03
    ld [enemy_testPointYPos], a
    ldh a, [hEnemyXPos]
    sub $07
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointYPos]
    add $06
    ld [enemy_testPointYPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    jr .exitA

.midMedium: ; 02:483B - Note: saves tile number to $C417
;(-7,-6)
;(-7, 0)
;(-7, 6)
    ld a, $44
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $06
    ld [enemy_testPointYPos], a
    ldh a, [hEnemyXPos]
    sub $07
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld [$c417], a
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointYPos]
    add $06
    ld [enemy_testPointYPos], a
    call enemy_getTileIndex
    ld [$c417], a
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointYPos]
    add $06
    ld [enemy_testPointYPos], a
    call enemy_getTileIndex
    ld [$c417], a
    ld hl, enemySolidityIndex
    cp [hl]
        ret c

.exitA:
    ld hl, en_bgCollisionResult
    res 2, [hl]
    ret

.farMedium: ; 02:4885
;(-11,-7)
;(-11, 0)
;(-11, 7)
    ld a, $44
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $07
    ld [enemy_testPointYPos], a
    ldh a, [hEnemyXPos]
    sub $0b
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointYPos]
    add $07
    ld [enemy_testPointYPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointYPos]
    add $07
    ld [enemy_testPointYPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    jr .exitA

.midWide: ; 02:48C2 - Unused
;(-7,-11)
;(-7, -3)
;(-7,  3)
;(-7, 11)
    ld a, $44
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $0b
    ld [enemy_testPointYPos], a
    ldh a, [hEnemyXPos]
    sub $07
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointYPos]
    add $08
    ld [enemy_testPointYPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointYPos]
    add $06
    ld [enemy_testPointYPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointYPos]
    add $08
    ld [enemy_testPointYPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    jr .exitB

.farWide: ; 02:490F
;(-11,-11)
;(-11, -3)
;(-11,  3)
;(-11, 11)
    ld a, $44
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $0b
    ld [enemy_testPointYPos], a
    ldh a, [hEnemyXPos]
    sub $0b
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointYPos]
    add $08
    ld [enemy_testPointYPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointYPos]
    add $06
    ld [enemy_testPointYPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointYPos]
    add $08
    ld [enemy_testPointYPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    jr .exitB

.crawlA: ; 02:495C
;(-9,-7)
;(-9, 8)
    ld a, $44
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $07
    ld [enemy_testPointYPos], a
    ldh a, [hEnemyXPos]
    sub $09
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointYPos]
    add $0f
    ld [enemy_testPointYPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c

.exitB:
    ld hl, en_bgCollisionResult
    res 2, [hl]
    ret

.crawlB: ; 02:498D
;(-9,-8)
;(-9, 7)
    ld a, $44
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $08
    ld [enemy_testPointYPos], a
    ldh a, [hEnemyXPos]
    sub $09
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointYPos]
    add $0f
    ld [enemy_testPointYPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    jr .exitB

;------------------------------------------------------------------------------
; "$22 functions" - Check bottom edge of object
; 9 functions (2 unused)
enCollision_down:

.nearSmall: ; 02:49BA
;(-3,3)
;( 3,3)
    ld a, $22
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    add $03
    ld [enemy_testPointYPos], a
    ldh a, [hEnemyXPos]
    sub $03
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointXPos]
    add $06
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    jr .exitA

.nearMedium: ; 02:49E7 - Unused
;(-7,3)
;( 0,3)
;( 7,3)
    ld a, $22
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    add $03
    ld [enemy_testPointYPos], a
    ldh a, [hEnemyXPos]
    sub $07
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointXPos]
    add $07
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointXPos]
    add $07
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c

.exitA:
    ld hl, en_bgCollisionResult
    res 1, [hl]
ret

.midMedium: ; 02:4A28 - Note: saves tile number to $C417
;(-6,7)
;( 0,7)
;( 6,7)
    ld a, $22
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    add $07
    ld [enemy_testPointYPos], a
    ldh a, [hEnemyXPos]
    sub $06
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld [$c417], a
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointXPos]
    add $06
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld [$c417], a
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointXPos]
    add $06
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld [$c417], a
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    jr .exitA

.midWide: ; 02:4A6E - Unused
;(-11,7)
;( -3,7)
;(  3,7)
;( 11,7)
    ld a, $22
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    add $07
    ld [enemy_testPointYPos], a
    ldh a, [hEnemyXPos]
    sub $0b
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointXPos]
    add $08
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointXPos]
    add $06
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointXPos]
    add $08
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    jr .exitB

.onePoint: ; 02:4ABB
;(0,11)
    ld a, $22
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    add $0b
    ld [enemy_testPointYPos], a
    ldh a, [hEnemyXPos]
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    jr .exitB

.farMedium: ; 02:4AD6
;(-7,11)
;( 0,11)
;( 7,11)
    ld a, $22
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    add $0b
    ld [enemy_testPointYPos], a
    ldh a, [hEnemyXPos]
    sub $07
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointXPos]
    add $07
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointXPos]
    add $07
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c

.exitB:
    ld hl, en_bgCollisionResult
    res 1, [hl]
    ret

.farWide: ; 02:4B17
;(-11,11)
;( -3,11)
;(  3,11)
;( 11,11)
    ld a, $22
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    add $0b
    ld [enemy_testPointYPos], a
    ldh a, [hEnemyXPos]
    sub $0b
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointXPos]
    add $08
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointXPos]
    add $06
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointXPos]
    add $08
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    jr .exitB

.crawlA: ; 02:4B64
;(-8,8)
;( 7,8)
    ld a, $22
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    add $08
    ld [enemy_testPointYPos], a
    ldh a, [hEnemyXPos]
    sub $08
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointXPos]
    add $0f
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    jr .exitC

.crawlB: ; 02:4B19
;(-9,8)
;( 6,8)
    ld a, $22
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    add $08
    ld [enemy_testPointYPos], a
    ldh a, [hEnemyXPos]
    sub $09
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointXPos]
    add $0f
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c

.exitC:
    ld hl, en_bgCollisionResult
    res 1, [hl]
    ret

;------------------------------------------------------------------------------
; "$88 functions" - Check top edge of object
; 8 functions (3 unused)
enCollision_up:

.nearSmall: ; 02:4BC2
;(-3,-3)
;( 3,-3)
    ld a, $88
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $03
    ld [enemy_testPointYPos], a
    ldh a, [hEnemyXPos]
    sub $03
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointXPos]
    add $06
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    jr .exitA

.nearMedium: ; 02:4BEF - Unused
;(-7,-3)
;( 0,-3)
;( 7,-3)
    ld a, $88
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $03
    ld [enemy_testPointYPos], a
    ldh a, [hEnemyXPos]
    sub $07
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointXPos]
    add $07
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointXPos]
    add $07
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c

.exitA:
    ld hl, en_bgCollisionResult
    res 3, [hl]
    ret

.midMedium: ; 02:4C30 - Note: saves tile number to $C417
;(-6,-7)
;( 0,-7)
;( 6,-7)
    ld a, $88
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $07
    ld [enemy_testPointYPos], a
    ldh a, [hEnemyXPos]
    sub $06
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld [$c417], a
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointXPos]
    add $06
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld [$c417], a
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointXPos]
    add $06
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld [$c417], a
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    jr .exitA

.midWide: ; 02:4C76 - Unused
;(-11,-7)
;( -3,-7)
;(  3,-7)
;( 11,-7)
    ld a, $88
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $07
    ld [enemy_testPointYPos], a
    ldh a, [hEnemyXPos]
    sub $0b
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointXPos]
    add $08
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointXPos]
    add $06
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointXPos]
    add $08
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    jr .exitB

.farMedium: ; 02:4CC3 - Unused
;(-7,-11)
;( 0,-11)
;( 7,-11)
    ld a, $88
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $0b
    ld [enemy_testPointYPos], a
    ldh a, [hEnemyXPos]
    sub $07
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointXPos]
    add $07
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointXPos]
    add $07
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c

.exitB:
    ld hl, en_bgCollisionResult
    res 3, [hl]
    ret

.farWide: ; 02:4D04
;(-11,-11)
;( -3,-11)
;(  3,-11)
;( 11,-11)
    ld a, $88
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $0b
    ld [enemy_testPointYPos], a
    ldh a, [hEnemyXPos]
    sub $0b
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointXPos]
    add $08
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointXPos]
    add $06
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointXPos]
    add $08
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    jr .exitB

.crawlA: ; 02:4D51
;(-9,-8)
;( 6,-8)
    ld a, $88
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $08
    ld [enemy_testPointYPos], a
    ld a, [enemy_xPosMirror]
    sub $09
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointXPos]
    add $0f
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    jr .exitC

.crawlB: ; 02:4D7F
;(-8,-8)
;( 7,-8)
    ld a, $88
    ld [en_bgCollisionResult], a
    ldh a, [hEnemyYPos]
    sub $08
    ld [enemy_testPointYPos], a
    ld a, [enemy_xPosMirror]
    sub $08
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c
    ld a, [enemy_testPointXPos]
    add $0f
    ld [enemy_testPointXPos], a
    call enemy_getTileIndex
    ld hl, enemySolidityIndex
    cp [hl]
        ret c

.exitC:
    ld hl, en_bgCollisionResult
    res 3, [hl]
    ret

; End of enemy tilemap collision routines
;------------------------------------------------------------------------------

; Loads the Blob Thrower sprite and hitbox into RAM
blobThrower_loadSprite: ; 02:4DB1
    ld hl, blobThrower.sprite ;$4ffe
    ld de, spriteC300
    ld b, $3e

    jr_002_4db9:
        ld a, [hl+]
        ld [de], a
        inc de
        dec b
    jr nz, jr_002_4db9

    ld hl, blobThrower.hitbox
    ld de, hitboxC360
    ld b, $04

    jr_002_4dc7:
        ld a, [hl+]
        ld [de], a
        inc de
        dec b
    jr nz, jr_002_4dc7

    ld a, $00
    ld [blobThrower_actionTimer], a
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

    call enemy_getSamusCollisionResults ; Get sprite collision results
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
    call Call_000_3ca6 ; Delete self
    ld a, $02 ; Set collected flag
    ldh [hEnemySpawnFlag], a
ret

;------------------------------------------------------------------------------
; Blob Thrower AI (plant that spits out spores)
enAI_blobThrower: ; 02:4EA1
blobThrower:
    ; Make stem blink periodically by changing tile numbers
    ld a, [frameCounter]
    and $0e
    jr nz, .endIf_A
        ; Blink the first three tiles
        ld de, $0004
        ld b, $03
        ld hl, spriteC300 + 4*4 + 2 ;$C312
        .blinkLoop:
            ld a, [hl]
            xor $07
            ld [hl], a
            add hl, de
            dec b
        jr nz, .blinkLoop
        ; Blink two other tiles (8 and 11)
        ld hl, spriteC300 + 8*4 + 2 ; $C322
        ld a, [hl]
        xor $0d
        ld [hl], a
        ld hl, spriteC300 + 11*4 + 2 ; $C32E
        ld a, [hl]
        xor $0d
        ld [hl], a
    .endIf_A:

    ; Wait on the wait timer
    ld a, [blobThrower_waitTimer]
    and a
    jr z, .else_B
        ; Decrement timer
        dec a
        ld [blobThrower_waitTimer], a
        ret
    .else_B:
        ; Go to current state
        ld a, [blobThrower_state]
        and a
            jr z, .state_0 ; case 0
        cp $01
            jr z, .state_1 ; case 1
        cp $02
            jr z, .state_2 ; case 2
        jp .state_3 ; case 3

.state_0: ; Main action
    ; Adjust sprites
    ld de, spriteC300
    ld hl, .speedTable_top
    ld a, $04
    call .moveSprites
    
    ld hl, .speedTable_top
    ld a, $01
    call .moveSprites
    
    ld hl, .speedTable_middle
    ld a, $01
    call .moveSprites
    
    ld hl, .speedTable_bottom
    ld a, $01
    call .moveSprites
    ; Adjust hitbox
    ld hl, .speedTable_top
    ld a, [blobThrower_actionTimer]
    ld e, a
    ld d, $00
    add hl, de
    ld de, hitboxC360
    ld a, [de]
    add [hl]
    ld [de], a
    ; Increment timer
    ld a, [blobThrower_actionTimer]
    inc a
    ld [blobThrower_actionTimer], a
    ; Check if at peak height
    cp $15
        ret nz

    ; Open up mouth by modifying first four tile numbers
    ld hl, spriteC300 + 2 ;$c302
    ld de, $0004
    ld [hl], $df
    add hl, de
    ld [hl], $df
    add hl, de
    ld [hl], $e1
    add hl, de
    ld [hl], $e1
    ; Set y-pos for the 13th sprite so it and the next one get rendered
    ld hl, spriteC300 + 13*4; $C334
    ld [hl], $e8
    ; Prep next state
    ld a, $04
    ld [blobThrower_waitTimer], a
    ld a, $01
    ld [blobThrower_state], a
ret

.state_1: ; Open mouth
    ld hl, spriteC300 + 2 ;$c302
    ld de, $0004
    ld [hl], $e2
    add hl, de
    ld [hl], $e2
    ld a, $04
    ld [blobThrower_waitTimer], a
    ld a, $02
    ld [blobThrower_state], a
ret

.state_2: ; Spew blobs
    ld hl, spriteC300 + 2 ;$c302
    ld de, $0004
    ld [hl], $e3
    add hl, de
    ld [hl], $e3
    ld a, $40
    ld [blobThrower_waitTimer], a
    ld a, $03
    ld [blobThrower_state], a
    call .getFacingDirection
    ld de, .blobHeader_A
    call .spewBlob
    ld de, .blobHeader_B
    call .spewBlob
    ld de, .blobHeader_C
    call .spewBlob
    ld de, .blobHeader_D
    call .spewBlob
ret

.getFacingDirection: ; 02:4F87 - Shared with Arachnus
    ld a, [samus_onscreenXPos]
    ld b, a
    ldh a, [hEnemyXPos]
    cp b
    ld a, $00
    jr c, .endIf_C
        inc a
    .endIf_C:

    ld [blobThrower_facingDirection], a
ret

.spewBlob:
    call findFirstEmptyEnemySlot_longJump
    ; Activate enemy
    ld [hl], $00
    inc hl
    ; Set position of enemy
    ldh a, [hEnemyYPos]
    sub $20
    ld [hl+], a
    ldh a, [hEnemyXPos]
    ld [hl+], a
    ; Load header
    ld a, $06
    ld [enemy_tempSpawnFlag], a
    push hl
        call enemy_spawnObject.longHeader
    pop hl
    ; Dynamically set [$E7] for the blobs (their lower bound) depending on the y position of the thrower.
    ld de, $0004
    add hl, de
    ldh a, [hEnemyYPos]
    add $40
    ld [hl], a
ret

.state_3: ; State 3 - Close mouth
    ld hl, spriteC300 + 2 ; $c302
    ld de, $0004
    ld [hl], $dd
    add hl, de
    ld [hl], $dd
    add hl, de
    ld [hl], $de
    add hl, de
    ld [hl], $de
    ; Set this y coordinate to $FF so this sprite and the one after it don't get rendered
    ld hl, spriteC300 + 13*4; $C334
    ld [hl], $ff
    xor a
    ld [blobThrower_state], a
ret

; A = number of sprites to move
.moveSprites:
    push de
    push af
    push hl
    ld a, [blobThrower_actionTimer]

    .readLoop:
        ; Check that we're not at the end of the list
        ld e, a
        ld d, $00
        add hl, de
        ld a, [hl]
        cp $80
        jr z, .endIf_D
            pop bc
            pop bc ; This is where B gets assigned the argument from A
            pop de
            ; Move the sprites, then exit
            .moveLoop:
                ld a, [de]
                add [hl]
                ld [de], a
                inc de
                inc de
                inc de
                inc de
                dec b
            jr nz, .moveLoop
            ret
        .endIf_D:
        ; Delay when at bottom
        ld a, $30
        ld [blobThrower_waitTimer], a
        ; Reset index
        xor a
        ld [blobThrower_actionTimer], a
        pop hl
        push hl
    jr .readLoop
; end proc

; Main blob thrower sprite
.sprite: ; 02:4FFE
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
    db $FF, $F0, $E0, $00 ; Note the $FF. It's dynamically changed to a valid value so this sprite and the next appear conditionally.
    db $E8, $08, $E0, $20
    db $FF
.hitbox: ; 02:503B
    db $FC, $18, $F8, $08

; Speed tables for moving the top, middile, and bottom parts of the blob thrower sprite
.speedTable_top: ; 02:503F
    db $00, $FE, $FF, $FF, $FF, $FF, $FF, $FF, $FE, $FE, $FE, $FE, $FE, $FE, $FD, $FF
    db $00, $00, $00, $00, $00, $00, $02, $01, $00, $01, $01, $01, $01, $00, $01, $00
    db $02, $01, $01, $01, $01, $02, $00, $00, $01, $01, $01, $02, $01, $00, $02, $00
    db $00, $80
.speedTable_middle: ; 02:5071
    db $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FE, $FF, $FF, $FF, $FE, $FF, $00
    db $00, $00, $00, $00, $00, $00, $01, $00, $01, $02, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $01, $00, $01, $02, $00, $02, $00, $01, $01, $01, $01, $01, $01
    db $00, $80
.speedTable_bottom: ; 02:50A3
    db $00, $FF, $00, $FF, $00, $FF, $00, $00, $FF, $00, $FF, $00, $FF, $FF, $FF, $00
    db $00, $00, $00, $00, $00, $01, $00, $00, $01, $01, $00, $00, $00, $00, $00, $01
    db $00, $00, $00, $01, $00, $01, $00, $00, $00, $00, $01, $00, $00, $00, $01, $00
    db $00, $80
; Enemy headers for projectiles
.blobHeader_A: ; 02:50D5
    db $9E, $00, $00, $00, $00, $00,
    dw blobMovementTable_A
    db $00, $02, $02
    dw enAI_blobProjectile
.blobHeader_B: ; 02:50E2
    db $9E, $00, $00, $00, $00, $00
    dw blobMovementTable_B
    db $00, $02, $03
    dw enAI_blobProjectile
.blobHeader_C: ; 02:50EF
    db $9E, $00, $00, $00, $00, $00
    dw blobMovementTable_C
    db $00, $02, $04
    dw enAI_blobProjectile
.blobHeader_D: ; 02:50FC
    db $9E, $00, $00, $00, $00, $00
    dw blobMovementTable_D
    db $00, $02, $05
    dw enAI_blobProjectile

;------------------------------------------------------------------------------
; Arachnus / Arachnus Orb
enAI_arachnus: ; 02:5109
arachnus:
    ldh a, [$e7]
    rst $28
        dw .state_0 ; Init and start fight
        dw .state_1 ; Initial bouncing for the intro
        dw .state_2 ; An additional small bounce for the intro
        dw .state_3 ; Standing up (part 1)
        dw .state_4 ; Standing up (part 2)
        dw .state_5 ; Attacking/Vulnerable
        dw .state_6 ; Bouncing again (loops back to state 3)
        dw enAI_NULL ;arachnus_5651

.state_0: ; 02:511C - State 0 - Init and start fight
    ; Clear arachnus scratchpad
    ld hl, arachnus_jumpCounter
    xor a
    ld b, $06
    .initLoop:
        ld [hl+], a
        dec b
    jr nz, .initLoop
    ; Set actual health and fake health
    ld a, $06
    ld [arachnus_health], a
    ld a, $ff
    ldh [hEnemyHealth], a
    ; Check if hit
    call enemy_getSamusCollisionResults
    ld a, [$c46d]
    cp $ff ; Exit if touching
        ret z
    cp $09 ; Exit if not hit with bombs or a beam
        ret nc
; Actually start the fight
    ; Set sprite to arachnus
    ld a, $76
    ldh [hEnemySpriteType], a
  .nextStateAndResetJumpCounterAndUnknownVar:
    ld a, $05
    ld [arachnus_unknownVar], a
  .nextStateAndResetJumpCounter:
    xor a
    ld [arachnus_jumpCounter], a
    ld a, $20
  .nextState:
    ld [arachnus_actionTimer], a
    ; Next state
    ld hl, $ffe7
    inc [hl]
ret

.state_1: ; 02:5152 - State 1 - Initial Bouncing
    ld hl, .jumpSpeedTable_high
    call .jump
        jr nz, .nextStateAndResetJumpCounterAndUnknownVar
    ; Move right
    ld hl, hEnemyXPos
    ld a, [hl]
    add $01
    ld [hl], a
    ; Animate
  .flipSpriteId: ; 02:5161
    ld a, [frameCounter]
    and $06
        ret nz
    ldh a, [hEnemySpriteType]
    xor $01
    ldh [hEnemySpriteType], a
ret

; Subroutine, not a state
.jump: ; 02:516E
    ; Read value from jump table
    ld a, [arachnus_jumpCounter]
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    ; Store distance in B
    ld b, a
    ; Check if it's a special token ($80 or $81) or not
    cp $80
    jr nz, .else_A
        ld bc, $0380 ; B = speed, C = status
        jr .endIf_A
    .else_A:
        cp $81
        jr nz, .else_B
            ld bc, $0381 ; B = speed, C = status
            jr .endIf_A
        .else_B:
            ; Increment jump counter
            inc e
            ld a, e
            ld [arachnus_jumpCounter], a
            ld c, $00
    .endIf_A:
    ; Move vertically
    ldh a, [hEnemyYPos]
    add b
    ldh [hEnemyYPos], a
    ; Save value of c
    ld a, c
    ld [arachnus_jumpStatus], a
    ; Exit if no collision happened
    call enCollision_down.midMedium
    ld a, [en_bgCollisionResult]
    and $02
        ret z
    
    ld a, [arachnus_jumpStatus]
    and a ; Return nz if we somehow landed early
    jr z, .else_C
        cp $81 ; Return nz if we're at the end of the last bounce
        jr z, .else_C
            ; If arachnus_jumpStatus was $80, move on to the next jump speed table (so it bounces)
            ; (note that the jump speed tables are right next to each other, and only the last one ends in $81)
            ld a, [arachnus_jumpCounter]
            inc a
            ld [arachnus_jumpCounter], a
            ; Return zero
            xor a
            and a
            ret
    .else_C:
        ; Return non-zero
        inc a
        and a
        ret
; end state

.state_2: ; 02:51B9 - State 2 - An additional small bounce
    ld hl, .jumpSpeedTable_low
  .jumpAndAnimate:
    call arachnus.jump
    jr nz, .else_D ; Animate spin
        jr arachnus.flipSpriteId
    .else_D: ; Done bouncing
        ; Set timer
        ld a, $04
        ld [arachnus_actionTimer], a
        ; Move to state 3
        ld hl, $ffe7
        ld [hl], $03
        ret

.state_3: ; 02:51CE - State 3 - Standing up (part 1)
    ld a, [arachnus_actionTimer]
    and a
    jr z, .else_E
        dec a
        ld [arachnus_actionTimer], a
        jr arachnus.flipSpriteId
    .else_E:
        call .faceSamus
        ; Stand up
        ldh a, [hEnemyYPos]
        sub $08
        ldh [hEnemyYPos], a
        ld a, $78
      .nextStateAndSetSprite:
        ldh [hEnemySpriteType], a
        ld a, $04 ; value for animation timer
        jp arachnus.nextState
; end state

.state_4: ; 02:51EC - State 4 - Standing up (part 2)
    ld a, [arachnus_actionTimer]
    and a
    jr z, .else_F
        dec a
        ld [arachnus_actionTimer], a
        ret
    .else_F:
        ld a, $7a ; Set sprite type
        jr .nextStateAndSetSprite
; end state

.state_5: ; 02:51FB - State 5 - Attacking/Vulnerable
    call enemy_getSamusCollisionResults
    ld a, [$c46d]
    cp $ff ; Skip ahead if nothing
    jr z, .endIf_G
        cp $09 ; Check if bomb
        jr nz, .endIf_G
            ld a, $05
            ld [sfxRequest_noise], a
            ld a, $11
            ldh [hEnemyStunCounter], a
            ld a, [arachnus_health]
            dec a
            ld [arachnus_health], a
                jr z, .die
    .endIf_G:

    ld a, [hInputPressed]
    and PADF_B
    jr nz, .else_H
        call .faceSamus
        ld a, [arachnus_actionTimer]
        and a
        jr z, .else_I
            dec a
            ld [arachnus_actionTimer], a
            ret
        .else_I:
            ; Spit fireball sprite
            ld a, $7a
            ldh [hEnemySpriteType], a
            ldh a, [hEnemySpawnFlag]
            cp $01
                ret nz
            ; Spawn projectile
            ld de, .fireballHeader
            call .shootFireball
            ld a, $79
            ldh [hEnemySpriteType], a
            ; Reset action timer
            ld a, $10
            ld [arachnus_actionTimer], a
            ret
    .else_H:
        ldh a, [hEnemyYPos]
        add $08
        ldh [hEnemyYPos], a
        ld a, $76
        ldh [hEnemySpriteType], a
        jp .nextStateAndResetJumpCounter
; end state

.die: ; Become Spring ball
    ld a, $0d
    ld [sfxRequest_noise], a
    ; Transform into spring ball
    ld hl, hEnemyHealth
    ld [hl], $ff
    ld a, $95 ; Spring Ball
    ldh [hEnemySpriteType], a
    ld hl, hEnemyAI_low ;$fff1
    ld de, enAI_itemOrb ;$4dd3
    ld [hl], e
    inc l
    ld [hl], d
ret

.state_6: ; 02:526E - State 6 - Bouncing again (loops back to state 3)
    ldh a, [hEnemyAttr]
    and a
    jr z, .else_J
        ; Try right
        call enCollision_right.midMedium
        ld b, 1 ; Speed
        ld a, [en_bgCollisionResult]
        and $01
        jr z, .moveHorizontal
            jr .moveVertical
            
          .moveHorizontal:
            ldh a, [hEnemyXPos]
            add b
            ldh [hEnemyXPos], a
          .moveVertical:
            ld hl, .jumpSpeedTable_mid
            jp .jumpAndAnimate
    .else_J:
        ; Try left
        call enCollision_left.midMedium
        ld b, -1 ; Speed
        ld a, [en_bgCollisionResult]
        and $04
        jr z, .moveHorizontal
            jr .moveVertical
; end state

.faceSamus: ; 02:529A
    call blobThrower.getFacingDirection
    and a
    ld a, OAMF_XFLIP ;$20
    jr z, .endIf_K
        xor a
    .endIf_K:
    ldh [hEnemyAttr], a
ret

.shootFireball: ; 02:52A6
    call findFirstEmptyEnemySlot_longJump
    ld [hl], $00
    inc hl
    ldh a, [hEnemyYPos]
    add $fd
    ld [hl+], a
    ; Adjust x-position based on facing
    ldh a, [hEnemyAttr]
    ld b, $18
    and a
    jr nz, .endIf_L
        ld b, -$18 ; $E8
    .endIf_L:
    ldh a, [hEnemyXPos]
    add b
    ld [hl+], a
    
    push hl
        call enemy_createLinkForChildObject ; Fireball doesn't bother with this link
        call enemy_spawnObject.longHeader
    pop hl
    ld de, $0004
    add hl, de
    ldh a, [hEnemyAttr]
    ld [hl], a
    ld a, $03
    ldh [hEnemySpawnFlag], a
ret

.fireballHeader: ; 02:52D2 - Enemy header
    db $7b, $00, $00, $00, $00, $00, $00, $00, $00, $02, $02
    dw .fireballAI

.fireballAI: ; 02:52DF
    ld hl, hEnemyXPos
    ldh a, [$e7]
    and a
    ; Set speed
    ld b, 3
    jr nz, .endIf_M
        ld b, -3 ;$fd
    .endIf_M:
    ; Move
    ld a, [hl]
    add b
    ld [hl], a
    ; Animate
    ld a, [frameCounter]
    and $06
        ret nz
    ldh a, [hEnemySpriteType]
    xor $07
    ldh [hEnemySpriteType], a
ret

    ret ; 02:52FB - Unreferenced

; Notes: These tables need to be contiguous, and the code that accesses them only supports
;  them having a combined length of 256 (easy enough to fix though).
; The $80 at the end of each table should coincide with the moment that Arachnus lands on the ground,
;  assuming you want it to continue on to the next bounce.
; The last table should end with $81 so the game doesn't read junk data as velocities
.jumpSpeedTable_high: ; 02:52FC - State 1 (jump off the pedestal)
    db $FF, $FE, $FE, $FE, $FF, $FF, $FE, $FF, $FE, $FE, $FE, $FF, $FF, $FF, $00, $00
    db $00, $00, $01, $00, $01, $01, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01
    db $01, $02, $02, $02, $02, $02, $02, $02, $02, $03, $03, $03, $03, $03, $03, $03
    db $00, $80
.jumpSpeedTable_mid: ; 02:532E - State 6
    db $FC, $FD, $FD, $FD, $FE, $FE, $FD, $FE, $FE, $FE, $FE, $FF, $FE, $FF, $FE, $FF
    db $FF, $00, $00, $00, $00, $01, $01, $02, $01, $02, $01, $02, $02, $02, $02, $03
    db $02, $02, $03, $03, $03, $04, $00, $80
.jumpSpeedTable_low: ; 02:5356 - State 2
    db $FD, $FE, $FE, $FE, $FF, $FF, $00, $FF, $FF, $00, $FF, $00, $00, $01, $00, $01
    db $01, $00, $01, $01, $02, $02, $02, $03, $81

;------------------------------------------------------------------------------
; Blob thrower projectile
enAI_blobProjectile: ; 02:536F
    ldh a, [hEnemy_frameCounter]
    ld b, a
    and $01
        ret nz
    ; Animate
    ld a, b
    and $01
    jr nz, .endIf_A ; This conditional seems superfluous given the conditional return above
        ldh a, [hEnemySpriteType]
        xor $01
        ldh [hEnemySpriteType], a
    .endIf_A:

    ; Load pointer to movement table (two bytes)
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
    ; Apply the sign-bit if necessary (uses sign-magnitude format)
    bit 3, a
    jr z, .endIf_B
        and $07
        cpl
        inc a
    .endIf_B:
    ; Save result
    ld b, a

    ; Negate if Samus is to the right side of the parent blob thrower
    ld a, [blobThrower_facingDirection]
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
    ; Apply the sign-bit if necessary (uses sign-magnitude format)
    bit 3, a
    jr z, .endIf_D
        and $07
        cpl
        inc a
    .endIf_D:
    ; Save result to B (unnecessary)
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
    ; Clear unused variable
    xor a
    ld [blobThrowerBlob_unknownVar], a
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
        call Call_000_3ca6
        ld a, $ff
        ldh [hEnemySpawnFlag], a
        ret
; end 

; Bitpacked speed pairs
; - Signed-magnitude format (Signs: $X---Y---, Magnitudes: $-xxx-yyy)
blobMovementTable_A: ; 02:53D7
    db $19, $1A, $1A, $29, $28, $31, $32, $32, $33, $34, $34, $25, $89, $9B, $9B, $A9
    db $A8, $B1, $B2, $C2, $C3, $D4, $D4, $C5, $09, $1B, $1B, $29, $28, $31, $32, $42
    db $43, $54, $54, $45, $89, $9B, $9B, $A9, $A8, $B1, $B2, $C2, $C3, $D4, $D4, $C5
    db $80
blobMovementTable_B: ; 02:5408
    db $09, $1A, $1A, $2A, $3A, $3A, $4A, $49, $58, $51, $89, $9B, $9B, $A9, $A8, $B1
    db $B2, $C2, $C3, $D4, $D4, $C5, $09, $1B, $1B, $29, $28, $31, $32, $42, $43, $54
    db $54, $45, $89, $9B, $9B, $A9, $A8, $B1, $B2, $C2, $C3, $D4, $D4, $C5, $80
blobMovementTable_C: ; 02:5437
    db $19, $1A, $2B, $4B, $4A, $5A, $59, $09, $1B, $1B, $29, $28, $31, $32, $42, $43
    db $54, $54, $45, $89, $9B, $9B, $A9, $A8, $B1, $B2, $C2, $C3, $D4, $D4, $C5, $09
    db $1B, $1B, $29, $28, $31, $32, $42, $43, $54, $54, $45, $80
blobMovementTable_D: ; 02:5463
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
    call enCollision_right.nearSmall
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
    call enCollision_left.nearSmall
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

    call enCollision_down.nearSmall ; Tilemap collision routine
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

; Common enemy handler
Call_002_5630:
    ; Check if a drop
    ldh a, [hEnemyDropType]
    and a
        jr nz, jr_002_5692
    ; Check if exploding/becoming a drop
    ldh a, [hEnemyExplosionFlag]
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

Call_002_565f: ; 02:565F
    ; Act every two frames
    ldh a, [hEnemy_frameCounter]
    and $01
        ret nz
    ; Do nothing if ice counter is below $C4
    ld hl, hEnemyIceCounter
    ld a, [hl]
    cp $c4
    inc [hl]
    inc [hl]
        ret c
    cp $d0
    jr nc, .else_A
        ld hl, hEnemyStatus
        ld a, [hl]
        xor $80
        ld [hl], a
        ret
    .else_A:
        ; Clear ice counter
        xor a
        ld [hl+], a
        ; Check health
        ld a, [hl]
        and a
        jr z, .else_B
            ; Unfreeze
            xor a
            ldh [hEnemyStunCounter], a
            ldh [hEnemyStatus], a
            ret
        .else_B:
            ; Kill
            ld a, $02
            ld [sfxRequest_noise], a
            call Call_000_3ca6
            ld a, $02
            ldh [hEnemySpawnFlag], a
            ret
; end branch

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
        call Call_000_3ca6
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
    ldh a, [hEnemyMaxHealth]
    cp $fd
        jr z, jr_002_5727

    ; 50% chance of dropping nothing
    ld a, [rDIV]
    and $01
        jr nz, .dropNothing

    ldh a, [hEnemyExplosionFlag]
    and $0f
        jr z, .dropNothing ; Case 0 - Nothing/default?
    dec a
        jr z, .dropSmallHealth ; Case 1 - Small Health
    dec a
        jr z, .dropLargeHealth ; Case 2 - Large health

; Missile drop
    ld bc, $04ee ; drop type, sprite ID
        jr .setDrop
.dropSmallHealth:
    ld bc, $01e0 ; drop type, sprite ID
        jr .setDrop
.dropLargeHealth:
    ld bc, $02ec ; drop type, sprite ID
        jr .setDrop

.setDrop:
    ld a, b
    ldh [hEnemyDropType], a
    ld a, c
    ldh [hEnemySpriteType], a
    xor a
    ldh [hEnemyStunCounter], a
    ldh [hEnemyIceCounter], a
    ldh [$e9], a
    ldh [hEnemyExplosionFlag], a
ret

.dropNothing: ; Delete self
    call Call_000_3ca6
    ld a, $02
    ldh [hEnemySpawnFlag], a
    ret

jr_002_5727:
    xor a
    ldh [hEnemyStunCounter], a
    ldh [hEnemyIceCounter], a
    ldh [hEnemyExplosionFlag], a
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

    ld hl, cutsceneActive
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
    call Call_000_3ca6
    ld a, $02
    ldh [hEnemySpawnFlag], a
    xor a
    ld [$c41c], a
    ld [cutsceneActive], a
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
    call Call_000_3ca6
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
enAI_57DE: ; 02:57DE
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
    call enemy_flipSpriteId.now
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
    call enCollision_up.crawlA
    ld a, [en_bgCollisionResult]
    bit 3, a
        jr z, jr_002_57e6
    call Call_002_58b8
ret

jr_002_580e:
    call enCollision_right.crawlA
    ld a, [en_bgCollisionResult]
    bit 0, a
        jr z, jr_002_57e6
    call Call_002_58cc
ret

jr_002_581c:
    call enCollision_down.crawlA
    ld a, [en_bgCollisionResult]
    bit 1, a
        jr z, jr_002_57e6
    call Call_002_5895
ret

jr_002_582a:
    call enCollision_left.crawlA
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
    call enCollision_right.crawlA
    ld a, [en_bgCollisionResult]
    bit 0, a
        jr nz, jr_002_57e0
    call Call_002_5895
ret

jr_002_5851:
    call enCollision_down.crawlA
    ld a, [en_bgCollisionResult]
    bit 1, a
        jp nz, Jump_002_57e0
    call Call_002_58a7
ret

jr_002_5860:
    call enCollision_left.crawlA
    ld a, [en_bgCollisionResult]
    bit 2, a
        jp nz, Jump_002_57e0
    call Call_002_58b8
ret

jr_002_586f:
    call enCollision_up.crawlA
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
    call enemy_flipSpriteId.now
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
    call enCollision_up.crawlB
    ld a, [en_bgCollisionResult]
    bit 3, a
        jr z, jr_002_58e6
    call Call_002_5895
    ld hl, hEnemyAttr
    set OAMB_YFLIP, [hl]
ret

jr_002_5912:
    call enCollision_right.crawlB
    ld a, [en_bgCollisionResult]
    bit 0, a
        jr z, jr_002_58e6
    call Call_002_58a7
    ld hl, hEnemyAttr
    res OAMB_XFLIP, [hl]
ret

Jump_002_5925:
    call enCollision_down.crawlB
    ld a, [en_bgCollisionResult]
    bit 1, a
        jr z, jr_002_58e6
    call Call_002_58b8
    ld hl, hEnemyAttr
    res OAMB_YFLIP, [hl]
ret

Jump_002_5938:
    call enCollision_left.crawlB
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
    call enCollision_left.crawlB
    ld a, [en_bgCollisionResult]
    bit 2, a
        jp nz, Jump_002_58e0
    call Call_002_58b8
    ld hl, hEnemyAttr
    res OAMB_YFLIP, [hl]
ret

jr_002_596a:
    call enCollision_up.crawlB
    ld a, [en_bgCollisionResult]
    bit 3, a
        jp nz, Jump_002_58e0
    call Call_002_58cc
    ld hl, hEnemyAttr
    set OAMB_XFLIP, [hl]
ret

jr_002_597e:
    call enCollision_right.crawlB
    ld a, [en_bgCollisionResult]
    bit 0, a
        jp nz, Jump_002_58e0
    call Call_002_5895
    ld hl, hEnemyAttr
    set OAMB_YFLIP, [hl]
ret

jr_002_5992:
    call enCollision_down.crawlB
    ld a, [en_bgCollisionResult]
    bit 1, a
        jp nz, Jump_002_58e0
    call Call_002_58a7
    ld hl, hEnemyAttr
    res OAMB_XFLIP, [hl]
ret


;------------------------------------------------------------------------------
; Skreek projectile code
jr_002_59a6: ; 02:59A6
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
    call Call_000_3ca6
    ld a, $ff
    ldh [hEnemySpawnFlag], a
ret

;------------------------------------------------------------------------------
; Skreek AI (bird faced things that jump out of lava and spit at samus)
enAI_59C7: ; 02:59C7
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
    ld a, [samus_onscreenXPos]
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
        ld hl, table_5A7D
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
        ld hl, table_5A7D
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
        ld de, header_5A9E
        call enemy_createLinkForChildObject
        call enemy_spawnObject.shortHeader
        ld a, $03
        ldh [hEnemySpawnFlag], a
        ld a, $07
        ldh [hEnemySpriteType], a
        ld a, $12
        ld [sfxRequest_noise], a
        ret
; end proc

table_5A7D: ; 02:5A7D
    db $00, $05, $05, $05, $04, $05, $03, $03, $02, $03, $03, $03, $02, $03, $03, $02
    db $02, $03, $02, $02, $00, $01, $01, $01, $00, $01, $01, $00, $00, $01, $00, $00
    db $00
header_5A9E: ; 02:5A9E
    db $00, $00, $00, $10, $00, $00, $ff, $07
    dw enAI_59C7

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
    call enemy_flipSpriteId.now ; Animate
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
    call enemy_flipHorizontal.now
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
    ld a, [samus_onscreenXPos]
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
    call enemy_createLinkForChildObject
    call enemy_spawnObject.longHeader
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
    call enCollision_down.nearSmall
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
    call Call_000_3ca6
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
    ld a, [samus_onscreenXPos]
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
    ld a, [samus_onscreenXPos]
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
        call nc, enemy_flipSpriteId.twoFrame

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
enAI_5F67: ; 02:5F67
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
        call Call_000_3ca6
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
    ld [enemy_tempSpawnFlag], a
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
    ld a, [enemy_tempSpawnFlag]
    ld [hl], a
    ld hl, numEnemies
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
    ld a, [samus_onscreenXPos]
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
    ld a, [samus_onscreenYPos]
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

    call Call_000_3ca6
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

;------------------------------------------------------------------------------
; Skorp AI - Things with circular saws that poke out of walls (which type?)
enAI_60AB: ; 02:60AB
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

    call enemy_flipHorizontal.twoFrame
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

    call enemy_flipHorizontal.twoFrame
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

;------------------------------------------------------------------------------
; Skorp AI - Things with circular saws that poke out of walls (which type?)
enAI_60F8: ; 02:60F8
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

    call enemy_flipVertical.twoFrame
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

    call enemy_flipVertical.twoFrame
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
    ld [enemy_tempSpawnFlag], a
    call enemy_spawnObject.shortHeader
    
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

    call enCollision_down.midMedium
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
    call enemy_flipHorizontal.now
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
    call enCollision_down.midMedium ; BG collision function
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
        call enemy_flipHorizontal.now
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

    call enemy_getSamusCollisionResults
    ldh a, [hEnemySpawnFlag]
    cp $06
        jr z, jr_002_633a

    ld hl, hEnemySpriteType
    ld a, [hl]
    cp $4c
        ret z

    ld a, [$c46d]
    cp $20 ; Touch
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
    ld de, header_6382
    ld a, $06
    ld [enemy_tempSpawnFlag], a
    call enemy_spawnObject.shortHeader
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

    call enemy_flipSpriteId_2Bits.twoFrame
    ld hl, hEnemyXPos
    ldh a, [hEnemyAttr]
    bit OAMB_XFLIP, a
    jr nz, jr_002_6365

    ld a, [hl]
    add $04
    ld [hl], a
    call enCollision_right.nearSmall
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
    call enCollision_left.nearSmall
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
    call Call_000_3ca6
    ld a, $ff
    ldh [hEnemySpawnFlag], a
    ret

header_6382:
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
    ld [enemy_tempSpawnFlag], a
    ld de, header_6511
    call enemy_spawnObject.longHeader
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
    ld [enemy_tempSpawnFlag], a
    ld de, header_651E
    call enemy_spawnObject.longHeader
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
    ld [enemy_tempSpawnFlag], a
    ld de, header_652B
    call enemy_spawnObject.longHeader
    ld a, $01
    ldh [hEnemyState], a
    ld a, $12
    ld [sfxRequest_noise], a
    ret


Jump_002_64a7: ; Gunzoo projectile
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
    call enCollision_down.nearSmall
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
    call Call_000_3ca6
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
    call enCollision_left.nearSmall
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
header_6511: ; 02:6511
    db $57, $00, $00, $00, $00, $00, $00, $00, $00, $fe, $01
    dw enAI_638C
header_651E: ; 02:651E
    db $57, $00, $00, $00, $00, $00, $00, $00, $00, $fe, $02
    dw enAI_638C
header_652B: ; 92:651E
    db $54, $00, $00, $00, $00, $00, $00, $00, $00, $fe, $03
    dw enAI_638C

Call_002_6538:
    ldh a, [hEnemy_frameCounter]
    and $07
        ret nz
    ld [hl], $51
ret

;------------------------------------------------------------------------------
; Autom AI (robot that shoots a flamethrower downwards)
enAI_autom: ; 02:6540
    ; Don't do anything while shooting stuff
    ldh a, [hEnemySpawnFlag]
    cp $03
        ret z
    and $0f
        jr z, .projectileCode
    ; Randomly shoot
    ld a, [rDIV]
    and $1f
        jr z, .useFlamethrower

    ; Animate
    ld a, $5c ; Sprite with light off
    ldh [hEnemySpriteType], a
    ; Prep variables
    ld de, hEnemyXPos
    ld hl, $ffe9
    ; Check direction
    ldh a, [hEnemyState]
    and a
    jr nz, .else_A
        ; Increment timer
        inc [hl]
        ld a, [hl]
        cp $20
            jr z, .flipDirection
        ; Move right
        ld a, [de]
        add $03
        ld [de], a
        ret
        
.flipDirection:
        ld hl, hEnemyState
        ld a, [hl]
        xor $01
        ld [hl], a
        ret
    
    .else_A:
        ; Decrement timer
        dec [hl]
            jr z, .flipDirection
        ; Move left
        ld a, [de]
        sub $03
        ld [de], a
        ret
; end state

.useFlamethrower: ; A fan wiki says its a flamethrower
    call findFirstEmptyEnemySlot_longJump
    ; Set enemy slot to active
    xor a
    ld [hl+], a
    ; Set position
    ldh a, [hEnemyYPos]
    add $10
    ld [hl+], a
    ldh a, [hEnemyXPos]
    inc a
    ld [hl+], a
    ; Load header
    call enemy_createLinkForChildObject
    ld de, .header_65C8
    call enemy_spawnObject.longHeader
    ; Animate
    ld hl, hEnemySpriteType
    ld [hl], $5d ; Sprite with light on
    ; Stay inactive while projectile is onscreen
    ld a, $03
    ldh [hEnemySpawnFlag], a
ret


.projectileCode:
    ld a, $07
    ld [sfxRequest_square2], a
    ; Check sprite type
    ld hl, hEnemySpriteType
    ld a, [hl]
    cp $60
    jr z, .else_B
    jr nc, .else_C
        ; Increment sprite type
        inc [hl]
        ; Move down
        ld hl, hEnemyYPos
        ld a, [hl]
        add $08
        ld [hl], a
        ret

    .else_B:
        ; Increment sprite type
        inc [hl]
        ret
        
    .else_C:
        ; Animate
        call enemy_flipSpriteId_2Bits.fourFrame
        ; Increment and check timer
        ld hl, $ffe9
        inc [hl]
        ld a, [hl]
        cp $20
            ret nz
        ; Delete self
        call Call_000_3ca6
        ld a, $ff
        ldh [hEnemySpawnFlag], a
        ret
; end proc

.header_65C8:
    db $5e, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $00
    dw enAI_autom

;------------------------------------------------------------------------------
; Proboscum AI (nose on wall that is acts as a platform)
enAI_65D5: ; 02:65D5
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
    call enemy_getSamusCollisionResults
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
    call enCollision_down.midMedium ; Check bg collision
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
    call Call_000_3ca6 ; Delete self
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
; Moto AI (the animal with a face-plate)
enAI_moto: ; 02:66F3
    call .animate
    ; Act every other frame
    ldh a, [hEnemy_frameCounter]
    and $01
        ret nz
    ; Handle movement
    ld hl, hEnemyXPos
    ld b, $02 ; Speed
    ; Check direction
    ldh a, [$e8]
    and $0f
    jr z, .moveRight

; Move left
    ld a, [hl]
    sub b
    ld [hl], a

.checkFront:
    ; Check floor below (don't run off a cliff)
    call enCollision_down.onePoint
    ld a, [en_bgCollisionResult]
    bit 1, a
        ret nz
    ; Flip enemy (visually)
    ld hl, hEnemyAttr
    ld a, [hl]
    xor OAMF_XFLIP
    ld [hl], a
    ; Flip enemy (logically)
    ld hl, $ffe8
    ld a, [hl]
    xor %00110010 ; Upper nybble flips directional shield, lower nybble flips logical direction
    ld [hl], a
ret

.moveRight:
    ld a, [hl]
    add b
    ld [hl], a
    jr .checkFront
; end proc

.animate:
    ; Animate every other frame
    ldh a, [hEnemy_frameCounter]
    and $01
        ret nz
    ; Skip ahead if not sprite $68
    ld hl, hEnemySpriteType
    ld a, [hl]
    cp $68
    jr nz, .endIf
        ; Inc/Dec depending on this flag
        ldh a, [$e9]
        and a
        jr z, .else
            inc [hl]
            ret
        .else:
            dec [hl]
            ret
    .endIf:

    ; Reset sprite type
    ld [hl], $68
    ; Switch between incrementing/decrementing the sprite type
    ld hl, $ffe9
    ld a, [hl]
    xor $01
    ld [hl], a
ret

;------------------------------------------------------------------------------
; Halzyn (flying enemy with sheilds on the sides)
enAI_6746: ; 02:6746
    call enemy_flipHorizontal.fourFrame ; Animate
    call Call_002_677c ; Y Movment
    ; Check direction of movement
    ldh a, [$e8]
    and $0f
    jr z, .else
        call Call_002_67d9 ; X Movement
        ; Check collision
        call enCollision_left.farMedium
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
        call enCollision_right.farMedium
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
;  Uses $E9 and $EA as a 16-bit distance-travelled counter
enAI_septogg: ; 02:6841
    call enemy_flipSpriteId_2Bits.twoFrame
    call enemy_getSamusCollisionResults ; Get sprite collision results
    ; Check if shot
    ld a, [$c46d]
    cp $20
        jr nz, .goBackUp
    
    ld a, [samus_onSolidSprite]
    and a
        jr z, .goBackUp

    ; Test if going down is okay
    ld b, $03
    ld hl, hEnemyYPos
    ld a, [hl]
    add b
    ld [hl], a
    call enCollision_down.farMedium
    ld a, [en_bgCollisionResult]
    bit 1, a
    jr z, .else
        ; Hit floor. Stay in place
        ld a, [enemy_yPosMirror]
        ldh [hEnemyYPos], a
        ret
    .else:
        ; Go down
        ld b, $03 ; Speed
        ; Add distance travelled to counter
        ld hl, $ffe9
        ld a, [hl]
        add b
        ld [hl+], a
        ld a, [hl]
        adc $00
        ld [hl], a
        ; Move Samus down (on-screen y-pos)
        ld hl, samus_onscreenYPos
        ld a, [hl]
        add b
        ld [hl], a
        ; Move Samus down (real position)
        ld hl, hSamusYPixel
        ld a, [hl]
        add b
        ld [hl+], a
            ret nc
        ; Don't forget about the y screen coordinate
        inc [hl]
        ret
; end proc

.goBackUp: ; Move back up if distance counter is non-zero
    ; Check low byte of counter
    ld hl, $ffe9
    ld a, [hl]
    and a
    jr nz, .then
        ; Check high byte of counter
        inc l
        ld a, [hl]
        and a
            ret z
    .then:
        ; Move back up
        ld hl, hEnemyYPos
        dec [hl]
        ; Move back up
        ; Adjust low byte
        ld hl, $ffe9
        dec [hl]
        ld a, [hl]
        inc a
            ret nz
        ; Adjust high byte
        inc l
        dec [hl]
        ret
; end proc

;------------------------------------------------------------------------------
; Flitt AI (weird platforms) (vanishing type)
enAI_flittVanishing: ; 02:68A0
    ld de, hEnemySpriteType ; This line doesn't appear to get used
    ; State graph is a simple loop of 0 -> 1 -> 2 -> 3 -> 0...
    ld hl, hEnemyState
    ld a, [hl]
    dec a
        jr z, .case_1 ; case 1
    dec a
        jr z, .case_2 ; case 2
    dec a
        jr z, .case_3 ; case 3

; default case (case 0)
    ; Check timer
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $38 ; Long wait
        ret nz
    ld [hl], $00 ; Reset timer
    ; Animate
    ld a, $01
    ldh [hEnemyState], a
    ld a, $d1
    ldh [hEnemySpriteType], a
ret

.case_1:
    ; Check timer
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $0e
        ret nz
    ld [hl], $00 ; Reset timer
    ; Disappear
    ld a, $02
    ldh [hEnemyState], a
    ld a, $fd ; No graphics
    ldh [hEnemySpriteType], a
ret

.case_2:
    ; Check timer
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $0c
        ret nz
    ld [hl], $00 ; Reset timer
    ; Reappear
    ld a, $03
    ldh [hEnemyState], a
    ld a, $d1
    ldh [hEnemySpriteType], a
ret

.case_3:
    ; Check timer
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $0d
        ret nz
    ld [hl], $00 ; Reset timer
    ; Animate
    ld a, $00
    ldh [hEnemyState], a
    ld a, $d0
    ldh [hEnemySpriteType], a
ret

;------------------------------------------------------------------------------
; Flitt AI (weird platforms) (moving type)
enAI_flittMoving: ; 02:68FC
    call enemy_flipSpriteId.fourFrame
    call enemy_getSamusCollisionResults ; Get collision results
    ; Check logical direction
    ldh a, [$e8]
    and a
    jr nz, .else_A
        ; Moving right
        ld hl, $ffe9
        inc [hl]
        ld a, [hl]
        cp $60
        jr z, .else_B
            ; Move right
            ld hl, hEnemyXPos
            inc [hl]
            ; Check collision results
            ld a, [$c46d]
            cp $20
                ret nz
            ld a, [samus_onSolidSprite]
            and a
                ret z
            ; Move camera and such right
            ld hl, samus_onscreenXPos
            inc [hl]
            ld hl, $d035
            inc [hl]
            ; Move Samus right
            ld hl, hSamusXPixel
            inc [hl]
                ret nz
            inc l
            inc [hl]
            ret
        .else_B:
            ; Flip direction
            ld a, $02
            ldh [$e8], a
            
    .else_A:
        ; Moving left
        ld hl, $ffe9
        dec [hl]
        jr z, .else_C
            ; Move left
            ld hl, hEnemyXPos
            dec [hl]
            ; Check collision results
            ld a, [$c46d]
            cp $20
                ret nz
            ld a, [samus_onSolidSprite]
            and a
                ret z
            ; Move camera left
            ld hl, samus_onscreenXPos
            dec [hl]
            ld hl, $d036
            inc [hl]
            ; Move Samus left
            ld hl, hSamusXPixel
            dec [hl]
            ld a, [hl]
            cp $ff
                ret nz
            inc l
            dec [hl]
            ret
        .else_C:
            ; Flip direction
            xor a
            ldh [$e8], a
            ret
; end proc

;------------------------------------------------------------------------------
; Gravitt AI (crawler with a hat that pops out of the ground)
enAI_gravitt: ; 02:695F
    ld hl, hEnemyState
    ld a, [hl]
    dec a
        jr z, .unburrow ; State 1
    dec a
        jr z, .crawl ; State 2 - Crawl in one direction
    dec a
        jr z, .crawl ; State 3 - And then crawl in the opposite
    dec a
        jr z, .burrow ; State 4
    dec a
        jp z, .wait ; State 5

; Default state
    ; Don't act if Samus isn't within range
    ; abs(samus_xpos - enemy_xpos) < $38
    ; Uses B to mark which direction Samus approaches from
    ld hl, hEnemyXPos
    ld b, $00 ; Samus is to the left
    ld a, [samus_onscreenXPos]
    sub [hl]
    jr nc, .endIf_A
        cpl
        inc a
        inc b ; Samus is to the right
    .endIf_A:
    cp $38
        ret nc
    ; Animate
    ld hl, hEnemySpriteType
    inc [hl]
    ; Peek up a bit
    ld hl, hEnemyYPos
    dec [hl]
    dec [hl]
    ; Next state
    ld a, $01
    ldh [hEnemyState], a
    ; Set 
    ld a, b
    and a
    jr nz, .else_B
        ld a, %10000000 ;$80
        ldh [$e8], a
        ret
    .else_B:
        ld a, %10000010 ;$82
        ldh [$e8], a
        ret
; end state

.unburrow: ; State 1
    ; Increment timer
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $06
    jr z, .else_C
        ; Peek up
        ld hl, hEnemyYPos
        dec [hl]
        dec [hl]
        ret
    .else_C:
        ; Clear timer
        xor a
        ld [hl+], a
        ; Next state
        ld a, $02
        ldh [hEnemyState], a
        ret
; end state

.crawl: ; States 2 and 3
    call .animate
    ; Check and increment timer
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $18
    jr z, .else_D
        ; Move
        ld hl, hEnemyXPos
        ldh a, [$e8]
        bit 1, a ; Check direction
        jr z, .else_E
            ; Move left
            dec [hl]
            dec [hl]
            ret
        .else_E:
            ; Move right
            inc [hl]
            inc [hl]
            ret
    .else_D:
        ;  Clear timer
        ld [hl], $00
        ; Reverse heading
        ld hl, $ffe8
        ld a, [hl]
        xor $02
        ld [hl], a
        ; Increment state
        ld hl, hEnemyState
        inc [hl]
        ret
; end state

.burrow: ; State 4
    ; Check and increment timer
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $07
    jr z, .else_F
        ; Move down
        ld hl, hEnemyYPos
        inc [hl]
        inc [hl]
        ret
    .else_F:
        ; Clear timer
        xor a
        ld [hl+], a
        ; Next state
        ld a, $05
        ldh [hEnemyState], a
        ; Animate
        ld a, $d3
        ldh [hEnemySpriteType], a
        ret
; end state

.wait: ; State 5
    ; Increment and check timer
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $30
        ret nz
    ; Clear timer
    xor a
    ld [hl+], a
    ; Clear state
    ld [hl], a
ret

.animate:
    ; Animate every other frame
    ldh a, [hEnemy_frameCounter]
    and $01
        ret nz
    ; $D4 -> $D5 -> $D6 -> $D7 animation loop
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
    call enemy_getSamusCollisionResults
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
    call Call_000_3ca6 ; Delete self?
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


; When used in conjunction with a child-object spawner routine,
;  this makes a child object point to its parent
enemy_createLinkForChildObject: ; 02:6B21
    ldh a, [$fd]
    cp $c6
    jr nz, .else
        ldh a, [$fc]
        jr .endIf
    .else:
        ldh a, [$fc]
        add $10
    .endIf:

    ld [enemy_tempSpawnFlag], a
ret

;------------------------------------------------------------------------------
; Flip sprite ID (low bit)
enemy_flipSpriteId: ; Procedure has 3 entry points
    .twoFrame: ; 02:6B33 - Once every 2 frames
        ldh a, [hEnemy_frameCounter]
        and $01
            ret nz
        jr .now
    .fourFrame: ; 02:6B3A - Once every 4 frames
        ldh a, [hEnemy_frameCounter]
        and $03
            ret nz
.now: ; 02:6B3F - Immediately
    ld hl, hEnemySpriteType
    ld a, [hl]
    xor %00000001 ;$01
    ld [hl], a
ret

;------------------------------------------------------------------------------
; Flip sprite ID (lowest two bits)
enemy_flipSpriteId_2Bits: ; Procedure has 3 entry points
    .fourFrame: ; 02:6B47
        ldh a, [hEnemy_frameCounter]
        and $03
            ret nz
        jr .now
    .twoFrame: ; 02:6B47
        ldh a, [hEnemy_frameCounter]
        and $01
            ret nz
.now: ; 02:6B53 - Never called directly
    ld hl, hEnemySpriteType
    ld a, [hl]
    xor %00000011 ;$03
    ld [hl], a
ret

;------------------------------------------------------------------------------
; Flip sprite horizontally
enemy_flipHorizontal: ; Procedure has 3 entry points
    .twoFrame: ; 02:6B5B
        ldh a, [hEnemy_frameCounter]
        and $01
            ret nz
        jr enemy_flipHorizontal.now
    .fourFrame: ; 02:6B5B
        ldh a, [hEnemy_frameCounter]
        and $03
            ret nz
.now: ; 02:6B62
    ld hl, hEnemyAttr
    ld a, [hl]
    xor OAMF_XFLIP
    ld [hl], a
ret

;------------------------------------------------------------------------------
; Flip sprite vertically
enemy_flipVertical: ; Procedure has 3 entry points
    .twoFrame: ; 02:6B6F
        ldh a, [hEnemy_frameCounter]
        and $01
            ret nz
        jr .now
    .fourFrame: ; 02:6B76 - Never called
        ldh a, [hEnemy_frameCounter]
        and $03
            ret nz
.now: ; 02:6B7B - Never called directly
    ld hl, hEnemyAttr
    ld a, [hl]
    xor OAMF_YFLIP
    ld [hl], a
ret    

;------------------------------------------------------------------------------
; Baby egg ? (with musical stinger moment)
; - TODO: Verify whether this is a visible sprite or an invisible trigger
enAI_6B83: ; 02:6B83
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $8a
    jr z, jr_002_6ba6
        dec a
            ret nz
        ; Increment displayed metroid count
        ld hl, metroidCountDisplayed
        ld a, [hl]
        add $08
        daa
        ld [hl], a
        ; Shuffle metroid timer
        ld a, $ca
        ld [metroidCountShuffleTimer], a
        ; Play metroid hive song with intro
        ld a, $1f
        ld [songRequest], a
        
        ld a, $01
        ld [cutsceneActive], a
        ret
    jr_002_6ba6:
    ; Delete self
    call Call_000_3ca6
    ld a, $02
    ldh [hEnemySpawnFlag], a
    
    xor a
    ld [cutsceneActive], a
ret

;------------------------------------------------------------------------------
; First alpha metroid ? (with appearance cutscene)
enAI_hatchingAlpha: ; 02:6BB2
;Jump_002_6bb2:
    call enemy_getSamusCollisionResults
    ; Check if stunned
    ld hl, alpha_stunCounter
    ld a, [hl]
    and a
    jr z, .endIf_A
        dec [hl]
        jr z, .else_B
            ; Stunned case
            call Call_002_6ef0 ; Knockback
            call enemy_toggleVisibility ; Blink
            ld a, [$c46d]
            cp $10
                ret nc
            ld a, $0f
            ld [sfxRequest_square1], a
            ret
        .else_B:
            ; End stun
            xor a
            ldh [hEnemyStatus], a
            ld a, $ff
            ldh [$e8], a
            ld a, $a3 ; Alpha metroid
            ldh [hEnemySpriteType], a
    .endIf_A:
    
    ld a, [$c41c]
    cp $02
        jp z, enAI_alphaMetroid.checkIfHurt
    ld b, a
    
    ldh a, [hEnemySpawnFlag]
    cp $04
        jr z, enAI_alphaMetroid.checkIfInRange

    ld c, a
    ld a, b
    cp $01
        jp z, enAI_alphaMetroid.startFight

    ; Check if in screen-facing pose
    ldh a, [hEnemySpriteType]
    cp $a1 ; Metroid hatching
        jp z, enAI_alphaMetroid.appearanceRise

    ld a, [cutsceneActive]
    and a
    jr nz, .else_C
        ldh a, [hEnemy_frameCounter]
        and $03
            ret nz
        ; Flash sprite
        ldh a, [hEnemyStunCounter]
        xor $10
        ldh [hEnemyStunCounter], a
        ; Check if Samus is in range
        ld hl, hEnemyXPos
        ld a, [samus_onscreenXPos]
        sub [hl]
        jr nc, .endIf_D
            cpl
            inc a
        .endIf_D:    
        cp $50
            ret nc
        
        ld a, $01
        ld [cutsceneActive], a
        ld a, $01
        ld [metroid_fightActive], a
        ; Trigger Metroid fight music
        ld a, [songPlaying]
        cp $0c
            ret z
        ld a, $0c
        ld [songRequest], a
        ret
    .else_C:
        ldh a, [hEnemy_frameCounter]
        and $03
            ret nz
        ld hl, $ffe9
        inc [hl]
        ld a, [hl]
        cp $08
            jp z, enAI_alphaMetroid.appearanceFaceScreen
        ; Flash sprite
        ldh a, [hEnemyStunCounter]
        xor $10
        ldh [hEnemyStunCounter], a
        ret
; end proc

;------------------------------------------------------------------------------
; Alpha Metroid ?
enAI_alphaMetroid: ; 02:6C44
    ld a, [metroid_fightActive]
    and a
        jp nz, enAI_hatchingAlpha ; Jump to actual AI is here, for some reason
    ; Check for before it attacks
    ld a, $04
    ldh [hEnemySpawnFlag], a
.checkIfInRange: ; Jump from hatchingAlpha
    ld a, $a3 ; Alpha metroid
    ldh [hEnemySpriteType], a
    ; Check if samus is within $50 pixels
    ld hl, hEnemyXPos
    ld a, [samus_onscreenXPos]
    sub [hl]
    jr nc, .endIf_A
        cpl
        inc a
    .endIf_A:
    cp $50
        ret nc
    ; Start fight
    xor a
    ld [alpha_stunCounter], a
    ld a, $01
    ld [metroid_fightActive], a
    ld a, $02
    ld [$c41c], a
    ld a, [songPlaying]
    cp $0c
        jr z, .standardAction
    ; Trigger Metroid fight music
    ld a, $0c
    ld [songRequest], a
jr .standardAction

.checkIfHurt: ; Shot reactions
    ld a, [$c46d]
    cp $20 ; Not shot
        jp nc, .standardAction
    cp $10
        jr z, .screwReaction
    cp $08
        jr z, .hurtReaction
    ld a, $0f
    ld [sfxRequest_square1], a
ret

.standardAction:
; Check if knockback direction not $FF
    ldh a, [$e8]
    inc a
    jr z, .endIf_B
        call Call_002_6e7f ; Screw attack knockback?
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
    .endIf_B:

; $E9 is used as a counter between lunges
    ld hl, $ffe9
    ld a, [hl]
    and a
    jr nz, .endIf_C
        ; Get direction of next lunge
        call alpha_getAngle_farCall
        ; Face Samus
        ld hl, hEnemyXPos
        ld a, [hl]
        add $10
        ld b, a
        ld a, [samus_onscreenXPos]
        sub b
        jr c, .else_D
            ld a, OAMF_XFLIP
            ldh [hEnemyAttr], a
            jr .endIf_C
        .else_D:
            xor a
            ldh [hEnemyAttr], a
    .endIf_C:

; Lunge for a few frames, pause for a few, then restart
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $0e
    jr c, .endIf_E
        cp $14
            ret nz
        ld [hl], $00
    .endIf_E:

    call alpha_getSpeedVector_farCall ; Translate angle to velocity vector
    call metroid_lungeMovement ; Move
    call alpha_animate ; Animate
ret

.screwReaction:
    call metroid_screwReaction
    ld a, $1a
    ld [sfxRequest_square1], a
ret

.hurtReaction:
    ld hl, hEnemyHealth
    dec [hl]
    ld a, [hl]
    and a
        jr z, .death
    ld a, $08
    ld [alpha_stunCounter], a
    ld a, $05
    ld [sfxRequest_noise], a
    ; Clear directional flag
    ld hl, $ffe8
    ld [hl], $00
    ; Check direction and handle knockback
    ld a, [$c46e]
    ld b, a
    bit 0, b ; Right
        jr nz, .case_setKnockbackRight
    bit 3, b ; Down
        jr nz, .case_setKnockbackDown
    bit 1, b ; Left
        jr nz, .case_setKnockbackLeft

; Vertical cases
    ;case_setKnockbackUp:
        ldh a, [hEnemyYPos]
        sub $05
        cp $10
        jr c, .knockback_randHorizontal
            ldh [hEnemyYPos], a
            set 3, [hl]
            jr .knockback_randHorizontal
    .case_setKnockbackDown:
        set 1, [hl]
        ldh a, [hEnemyYPos]
        add $05
        ldh [hEnemyYPos], a
.knockback_randHorizontal:
    ld a, [rDIV]
    and $01
    jr z, .else_F
        set 0, [hl] ; Right
        ret
    .else_F:
        set 2, [hl] ; Left
        ret

; Horizontal cases
    .case_setKnockbackRight:
        set 0, [hl]
        ldh a, [hEnemyXPos]
        add $05
        ldh [hEnemyXPos], a
        jr .knockback_randVertical
    .case_setKnockbackLeft:
        ldh a, [hEnemyXPos]
        sub $05
        cp $08
        jr c, .knockback_randVertical
            ldh [hEnemyXPos], a
            set 2, [hl]
            jr .knockback_randVertical
.knockback_randVertical:
    ld a, [rDIV]
    and $01
    jr z, .else_G
        set 1, [hl] ; Down
        ret
    .else_G:
        set 3, [hl] ; Up
        ret
; end branch

.death:
    xor a
    ldh [$e9], a
    ldh [hEnemyState], a
    ld a, $80
    ld [$c41c], a
    ; Explode
    ld a, $e2
    ldh [hEnemySpriteType], a
    ld a, $0d
    ld [sfxRequest_noise], a
    ; Play metroid killed jingle
    ld a, $0f
    ld [songRequest], a

    ld a, $02
    ld [metroid_fightActive], a
    ldh [hEnemySpawnFlag], a
    ; Adjust Metroid counts
    ld hl, metroidCountReal
    ld a, [hl]
    sub $01
    daa
    ld [hl], a
    ld hl, metroidCountDisplayed
    ld a, [hl]
    sub $01
    daa
    ld [hl], a
    ; Metroid counter shuffle effect
    ld a, $c0
    ld [metroidCountShuffleTimer], a
    ; Queue earthquake if necessary
    call earthquakeCheck_farCall
ret

; Appearance related branches
.startFight:
    ld hl, hEnemySpriteType
    ld [hl], $a3
    ld a, $04
    ldh [hEnemySpawnFlag], a
    xor a
    ld [cutsceneActive], a
    ld a, $02
    ld [$c41c], a
ret

.appearanceFaceScreen:
    ; Clear counter
    xor a
    ld [hl], a
    ldh [hEnemyStunCounter], a
    ; Screen-facing pose
    ld a, $a1
    ldh [hEnemySpriteType], a
ret

.appearanceRise:
    call Call_002_75ec ; Osciallate horizontally
    ; Continue 1 out of 8 frames
    ldh a, [hEnemy_frameCounter]
    and $07
        ret nz
    ; Move up
    ld hl, hEnemyYPos
    ld a, [hl]
    sub $02
    ld [hl], a
    ; Timer
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $0d
        ret nz
    ;
    xor a
    ld [hl], a
    inc a
    ld [$c41c], a
jr .startFight


; BC should contain the YYXX movement vector
; (each component is in sign-magnitude format)
metroid_lungeMovement: ; 02:6DD4
    push bc
        ld a, b
        and a
        jr z, .endIf_A
            ld hl, hEnemyYPos
            bit 7, b
            jr z, .else_B
                ; Move up
                res 7, b
                ld a, [hl]
                sub b
                ld [hl], a
                call enCollision_up.farWide
                ld a, [en_bgCollisionResult]
                bit 3, a
                jr z, .endIf_A
                    ld a, [enemy_yPosMirror]
                    ldh [hEnemyYPos], a
                    jr .endIf_A
            .else_B:
                ; Move down
                ld a, [hl]
                add b
                ld [hl], a
                call enCollision_down.farWide
                ld a, [en_bgCollisionResult]
                bit 1, a
                jr z, .endIf_A
                    ld a, [enemy_yPosMirror]
                    ldh [hEnemyYPos], a
        .endIf_A:
    pop bc
    
    ld a, c
    and a
        ret z
    ld hl, hEnemyXPos
    bit 7, c
    jr z, .else_C
        ; Move left
        res 7, c
        ld a, [hl]
        sub c
        ld [hl], a
        call enCollision_left.farWide
        ld a, [en_bgCollisionResult]
        bit 2, a
            ret z
        ld a, [enemy_xPosMirror]
        ldh [hEnemyXPos], a
        ret
    .else_C:
        ; Move right
        ld a, [hl]
        add c
        ld [hl], a
        call enCollision_right.farWide
        ld a, [en_bgCollisionResult]
        bit 0, a
            ret z
        ld a, [enemy_xPosMirror]
        ldh [hEnemyXPos], a
        ret
; end proc

alpha_animate: ; 02:6E39
    ld hl, hEnemySpriteType
    ld a, [hl]
    xor $07
    ld [hl], a
ret

;--------------------------------------
; Common metroid routines

metroid_screwReaction: ; 02:6E41
    ; Clear D and E
    ld d, $00
    ld e, d
    ; Get absolute value of Y distance between Samus and metroid
    ; (set direction in E)
    ld hl, hEnemyYPos
    ld a, [samus_onscreenYPos]
    sub [hl]
    jr nc, jr_002_6e50
        cpl
        inc a
        inc e
    jr_002_6e50:

    ; Get absolute value of X distance between Samus and metroid
    ; (set direction in D)
    ld b, a
    inc l
    ld a, [samus_onscreenXPos]
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
; End proc


Call_002_6e7f: ; Screw attack knockback ?
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
    call enCollision_up.farWide
    ld a, [en_bgCollisionResult]
    bit 3, a
        ret z
    ld a, [enemy_yPosMirror]
    ldh [hEnemyYPos], a
    ret


jr_002_6eb4:
    ld a, [hl]
    sub $05
    cp $10
        ret c
    ld [hl], a
    call enCollision_left.farWide
    ld a, [en_bgCollisionResult]
    bit 2, a
        ret z
    ld a, [enemy_xPosMirror]
    ldh [hEnemyXPos], a
ret


jr_002_6eca:
    ld a, [hl]
    add $05
    ld [hl], a
    call enCollision_right.farWide
    ld a, [en_bgCollisionResult]
    bit 0, a
        ret z
    ld a, [enemy_xPosMirror]
    ldh [hEnemyXPos], a
ret

jr_002_6edd:
    ld a, [hl]
    add $05
    ld [hl], a
    call enCollision_down.farWide
    ld a, [en_bgCollisionResult]
    bit 1, a
        ret z
    ld a, [enemy_yPosMirror]
    ldh [hEnemyYPos], a
ret
; end proc


Call_002_6ef0: ; Alpha/Gamma missile knockback
    ld hl, hEnemyYPos
    ldh a, [$e8]
    bit 1, a
    jr nz, jr_002_6f11
        bit 3, a
        jr z, jr_002_6f23
            call Call_002_6f53
            call enCollision_up.farWide
            ld a, [en_bgCollisionResult]
            bit 3, a
            jr z, jr_002_6f23
                ld a, [enemy_yPosMirror]
                ldh [hEnemyYPos], a
                jr jr_002_6f23
    jr_002_6f11:
        call Call_002_6f5b
        call enCollision_down.farWide
        ld a, [en_bgCollisionResult]
        bit 1, a
        jr z, jr_002_6f23
            ld a, [enemy_yPosMirror]
            ldh [hEnemyYPos], a
    jr_002_6f23:

    ld hl, hEnemyXPos
    ldh a, [$e8]
    bit 0, a
    jr nz, jr_002_6f41
        bit 2, a
            ret z
        call Call_002_6f53
        call enCollision_left.farWide
        ld a, [en_bgCollisionResult]
        bit 2, a
            ret z
        ld a, [enemy_xPosMirror]
        ldh [hEnemyXPos], a
        ret
    jr_002_6f41:
        call Call_002_6f5b
        call enCollision_right.farWide
        ld a, [en_bgCollisionResult]
        bit 0, a
            ret z
        ld a, [enemy_xPosMirror]
        ldh [hEnemyXPos], a
        ret


Call_002_6f53: ; Back
    ld a, [hl]
    sub $04
    cp $10
        ret c
    ld [hl], a
ret


Call_002_6f5b: ; Forwards
    ld a, [hl]
    add $04
    ld [hl], a
ret

;------------------------------------------------------------------------------
; Gamma Metroid AI
enAI_gammaMetroid: ; 02:6F60
    call enemy_getSamusCollisionResults
    ld hl, gamma_stunCounter
    ld a, [hl]
    and a
        jr z, .checkIfActing
    dec [hl]
        jr z, .stunEnd
    ; Stunned case
    call Call_002_6ef0 ; Knockback
    call enemy_toggleVisibility ; Blink
    ; When stunned, only process screw attack collision
    ld a, [$c46d]
    cp $10
        ret nc
    ld a, $0f
    ld [sfxRequest_square1], a
ret

.despawn: ; Delete self (don't save it)
    call Call_000_3ca6
    ld a, $ff
    ldh [hEnemySpawnFlag], a
ret

.stunEnd:
    ld a, $ff
    ldh [$e8], a
    xor a
    ldh [hEnemyStatus], a
.checkIfActing:
    ; Act if fight is happening
    ld a, [$c41c]
    and a
        jp nz, .checkIfHurt

    ldh a, [hEnemySpawnFlag]
    cp $04 ; Check if we've already seen this one
        jr z, .quickIntro ; Quick entrance
    and $0f ; Check if killed (?)
        jr z, .despawn ; Despawn self

    ; Fancy entrance
    ld a, [cutsceneActive]
    and a
    jr nz, .endIf_A
        ; Check if Samus is in range
        ld hl, hEnemyXPos
        ld a, [samus_onscreenXPos]
        sub [hl]
        jr nc, .endIf_B
            cpl
            inc a
        .endIf_B:
        cp $50
            ret nc
    
        ld a, $01
        ld [cutsceneActive], a
        ; Trigger Metroid fight music
        ld a, $0c
        ld [songRequest], a
        ld a, $01
        ld [metroid_fightActive], a
    .endIf_A:
    
    ldh a, [hEnemy_frameCounter]
    and $03
        ret nz
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $10
        jp z, .longIntroEnd
    ldh a, [hEnemySpriteType]
    xor $A3^$AD ; $0E -- Switch between Alpha and Gamma sprites
    ldh [hEnemySpriteType], a
ret

.quickIntro:
    ; Load proper Gamma sprite
    ld a, $ad
    ldh [hEnemySpriteType], a
    ; Check if Samus is in range
    ld hl, hEnemyXPos
    ld a, [samus_onscreenXPos]
    sub [hl]
    jr nc, .endIf_C
        cpl
        inc a
    .endIf_C:
    cp $50
        ret nc

    xor a
    ld [gamma_stunCounter], a
    inc a
    ld [$c41c], a
    ld a, $01
    ld [metroid_fightActive], a
    ; Trigger Metroid fight music
    ld a, [songPlaying]
    cp $0c
        ret z
    ld a, $0c
    ld [songRequest], a
ret

.longIntroEnd:
    ; Clear [$E9]
    xor a
    ld [hl], a
    ; Load proper Gamma sprite
    ld a, $ad
    ldh [hEnemySpriteType], a
    xor a
    ld [cutsceneActive], a
    inc a
    ld [$c41c], a
    ; Set spawn flag to "seen"
    ld a, $04
    ldh [hEnemySpawnFlag], a
ret


.checkIfHurt:
    ldh a, [hEnemySpawnFlag]
    cp $05
        ret z
    ; Check if a Gamma projectile
    and $0f
    jr nz, .else_D
        call .projectileCode
        ld a, [$c46d]
        cp $10
            ret nc
        ld a, $0f
        ld [sfxRequest_square1], a
        ret
    .else_D:
        ld a, [$c46d]
        cp $20
            jp nc, .standardAction ; Standard action if not hit with projectile
        cp $10
            jr z, .screwReaction
        cp $08
            jr z, .hurtReaction
        ld a, $0f
        ld [sfxRequest_square1], a
        ret
; end branch

.screwReaction:
    call metroid_screwReaction
    ld a, $1a
    ld [sfxRequest_square1], a
ret

.hurtReaction:
    ld hl, hEnemyHealth
    dec [hl]
    ld a, [hl]
    and a
        jp z, .death

    ld a, $08
    ld [gamma_stunCounter], a
    ld a, $05
    ld [sfxRequest_noise], a
    ld hl, $ffe8
    ld [hl], $00
    ; Prep knockback based on hit direction
    ld a, [$c46e]
    ld b, a
    bit 0, b ; Right
        jr nz, .case_setKnockbackRight
    bit 3, b ; Down
        jr nz, .case_setKnockbackDown
    bit 1, b ; Left
        jr nz, .case_setKnockbackLeft

; Vertical cases
    ;case_setKnockbackUp:
        ldh a, [hEnemyYPos]
        sub $05
        cp $10
            jr c, .knockback_randHorizontal
        ldh [hEnemyYPos], a
        call enCollision_up.farWide
        ld a, [en_bgCollisionResult]
        bit 3, a
        jr nz, .knockback_resetYPos
            ld hl, $ffe8
            set 3, [hl]
            jr .knockback_randHorizontal

        .knockback_resetYPos:
            ld a, [enemy_yPosMirror]
            ldh [hEnemyYPos], a
            ld hl, $ffe8
            jr .knockback_randHorizontal

    .case_setKnockbackDown:
        ldh a, [hEnemyYPos]
        add $05
        ldh [hEnemyYPos], a
        call enCollision_down.farWide
        ld a, [en_bgCollisionResult]
        bit 1, a
            jr nz, .knockback_resetYPos
        ld hl, $ffe8
        set 1, [hl]

.knockback_randHorizontal:
    ld a, [rDIV]
    and $01
    jr z, .else_E
        set 0, [hl] ; Right
        ret
    .else_E:
        set 2, [hl] ; Left
        ret

; Horizontal cases
    .case_setKnockbackRight:
        ldh a, [hEnemyXPos]
        add $05
        ldh [hEnemyXPos], a
        call enCollision_right.farWide
        ld a, [en_bgCollisionResult]
        bit 0, a
        jr nz, .knockback_resetXPos
            ld hl, $ffe8
            set 0, [hl]
            jr .knockback_randVertical

        .knockback_resetXPos:
            ld a, [enemy_xPosMirror]
            ldh [hEnemyXPos], a
            ld hl, $ffe8
            jr .knockback_randVertical

    .case_setKnockbackLeft:
        ldh a, [hEnemyXPos]
        cp $10
            jr c, .knockback_randVertical
        sub $05
        ldh [hEnemyXPos], a
        call enCollision_left.farWide
        ld a, [en_bgCollisionResult]
        bit 2, a
            jr nz, .knockback_resetXPos
        ld hl, $ffe8
        set 2, [hl]
        jr .knockback_randVertical

.knockback_randVertical:
    ld a, [rDIV]
    and $01
    jr z, .else_F
        set 1, [hl] ; Down
        ret
    .else_F:
        set 3, [hl] ; Up
        ret
; end branch

.death:
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
    ld [metroid_fightActive], a
    ldh [hEnemySpawnFlag], a
    ; Adjust Metroid counts
    ld hl, metroidCountReal
    ld a, [hl]
    sub $01
    daa
    ld [hl], a
    ld hl, metroidCountDisplayed
    ld a, [hl]
    sub $01
    daa
    ld [hl], a
    ; Shuffle counter and check earthquake
    ld a, $c0
    ld [metroidCountShuffleTimer], a
    call earthquakeCheck_farCall
ret

.standardAction:
    ; Check knockback direction
    ldh a, [$e8]
    inc a
    jr z, .endIf_G
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
    .endIf_G:

    ld hl, $ffe9
    ld a, [hl]
    and a
    jr nz, .endIf_H
        call gamma_getAngle_farCall
        ld hl, hEnemyXPos
        ld a, [hl]
        add $10
        ld b, a
        ld a, [samus_onscreenXPos]
        sub b
        jr c, .else_I
            ld a, OAMF_XFLIP
            ldh [hEnemyAttr], a
            jr .endIf_H
        .else_I:
            xor a
            ldh [hEnemyAttr], a
    .endIf_H:

    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $0f
    jr nc, .else_J
        call gamma_getSpeedVector_farCall
        call metroid_lungeMovement
        ld a, $b0
        ldh [hEnemySpriteType], a
        ret
    .else_J:
        cp $14
            ret c
        call findFirstEmptyEnemySlot_longJump
        xor a
        ld [hl+], a
        ldh a, [hEnemyYPos]
        add $0c
        ld [hl+], a
        ldh a, [hEnemyAttr]
        ; Adjust attack xpos based on facing direction
        bit OAMB_XFLIP, a
        jr nz, .else_K
            ldh a, [hEnemyXPos]
            sub $08
            jr .endIf_K
        .else_K:
            ldh a, [hEnemyXPos]
            add $08
        .endIf_K:
    
        ld [hl+], a
        ld a, $ae
        ld [hl+], a
        ld a, $00
        ld [hl+], a
        ldh a, [hEnemyAttr]
        ld [hl+], a
        ld de, .projectileHeader
        call enemy_createLinkForChildObject
        call enemy_spawnObject.shortHeader
        ld a, $05
        ldh [hEnemySpawnFlag], a
        xor a
        ldh [$e9], a
        ld a, $14
        ld [sfxRequest_noise], a
        ret

.projectileHeader: ; 02:71D0
    db $00, $00, $ff, $00, $00, $00, $ff, $07
    dw enAI_gammaMetroid

; Gamma Projectile code
.projectileCode: ; 02:71DA
    ldh a, [hEnemy_frameCounter]
    and $01
        ret nz
    ld hl, hEnemySpriteType
    ld a, [hl]
    cp $ae
    jr z, .endIf_L
        dec [hl]
        ldh a, [hEnemyAttr]
        set OAMB_YFLIP, a
        ldh [hEnemyAttr], a
        ldh a, [hEnemyYPos]
        sub $0d
        ldh [hEnemyYPos], a
        ldh a, [hEnemyAttr]
        bit OAMB_XFLIP, a
        jr nz, .else_M
            ldh a, [hEnemyXPos]
            add $04
            ldh [hEnemyXPos], a
            ret
        .else_M:
            ldh a, [hEnemyXPos]
            sub $04
            ldh [hEnemyXPos], a
            ret
    .endIf_L:

    ldh a, [hEnemyAttr]
    bit OAMB_YFLIP, a
    jr nz, .endIf_N
        inc [hl]
        ldh a, [hEnemyYPos]
        sub $10
        ldh [hEnemyYPos], a
        ldh a, [hEnemyAttr]
        bit OAMB_XFLIP, a
        jr nz, .else_O
            ldh a, [hEnemyXPos]
            sub $04
            ldh [hEnemyXPos], a
            ret
        .else_O:
            ldh a, [hEnemyXPos]
            add $04
            ldh [hEnemyXPos], a
            ret
    .endIf_N:

    call Call_000_3ca6
    ld a, $ff
    ldh [hEnemySpawnFlag], a
ret

;------------------------------------------------------------------------------

enemy_spawnObject:
    .shortHeader: ; 02:7231
        ld b, $07
        jr .start
    .longHeader: ;02:7235
        ld b, $0a
.start:

    .loadLoop_A:
        ld a, [de]
        ld [hl+], a
        inc de
        dec b
    jr nz, .loadLoop_A
    ; Save max health to C
    ld c, a
    xor a
    ld b, $04

    .clearLoop:
        ld [hl+], a
        dec b
    jr nz, .clearLoop
    ; Save max health properly
    ld [hl], c
    
    ld a, l
    add $0b
    ld l, a
    ld a, [enemy_tempSpawnFlag]
    ld [hl+], a
    ld b, $03

    .loadLoop_B:
        ld a, [de]
        ld [hl+], a
        inc de
        dec b
    jr nz, .loadLoop_B

    dec l
    dec l
    dec l
    ld a, [hl]
    ld hl, enemySpawnFlags
    ld l, a
    ld a, [enemy_tempSpawnFlag]
    ld [hl], a
    ld hl, numEnemies
    inc [hl]
    inc l
    inc [hl]
ret

; 02:7269 - Unused?
    ld h, $c6
    ldh a, [hEnemySpawnFlag]
    bit 4, a
    jr z, jr_002_7274
        sub $10
        inc h
    jr_002_7274:
        ld l, a
        ret

;------------------------------------------------------------------------------
; Zeta Metroid ?
enAI_7276: ; 02:7276
    call enemy_getSamusCollisionResults
    ldh a, [hEnemySpawnFlag]
    cp $06
        jp z, zeta_fireball
    
    ld a, [$c41c]
    and a
        call nz, Call_002_7dc6
    ; Check if not stunned
    ld hl, zeta_stunCounter
    ld a, [hl]
    and a
        jr z, jr_002_72b1
    dec [hl]
        jr z, jr_002_72a0
    ; Stunned case
    call zeta_animateHurt
    ; Only process screw touch reaction when stunned
    ld a, [$c46d]
    cp $10
        ret nc
    ld a, $0f
    ld [sfxRequest_square1], a
ret


jr_002_72a0:
    xor a
    ldh [hEnemyStatus], a
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

    ld a, [cutsceneActive]
    and a
        jr nz, jr_002_7301

    ldh a, [hEnemy_frameCounter]
    and $03
        ret nz
    ; Blink
    ldh a, [hEnemyStunCounter]
    xor $10
    ldh [hEnemyStunCounter], a
    ; Check if Samus is in range
    ld hl, hEnemyXPos
    ld a, [samus_onscreenXPos]
    sub [hl]
    jr nc, jr_002_72ee
        cpl
        inc a
    jr_002_72ee:
    cp $50
        ret nc
    ; Start fight
    ld a, $01
    ld [cutsceneActive], a
    ; Play Metroid fight song
    ld a, $0c
    ld [songRequest], a
    ld a, $01
    ld [metroid_fightActive], a
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
    ld a, [samus_onscreenXPos]
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
    ld [zeta_stunCounter], a
    ld a, $01
    ld [metroid_fightActive], a
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
    call enemy_seekSamus_farCall
    ld hl, hEnemyXPos
    ld a, [samus_onscreenXPos]
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
    ld a, [samus_onscreenYPos]
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
        jr z, zeta_screw
    cp $08
        jr z, zeta_hurt
zeta_plink:
    ld a, $0f
    ld [sfxRequest_square1], a
ret

zeta_screw:
    call metroid_screwReaction
    ld a, $1a
    ld [sfxRequest_square1], a
ret

zeta_hurt:
    ; Invulnerable to upwards shots
    ld a, [$c46e]
    ld b, a
    bit 2, b
        jr nz, zeta_plink

    ld hl, hEnemyHealth
    dec [hl]
    ld a, [hl]
    and a
        jr z, zeta_die

    ld a, $ba
    ldh [hEnemySpriteType], a
    ld a, $08
    ld [zeta_stunCounter], a
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
; end branch

zeta_die:
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
    ld [metroid_fightActive], a
    ldh [hEnemySpawnFlag], a
    ; Adjust metroid counts
    ld hl, metroidCountReal
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
    call earthquakeCheck_farCall
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


zeta_fireball: ; Projectile code
    ld a, [$c41c]
    cp $06
    jr z, .else_A
        ld hl, hEnemyYPos
        ld a, [hl]
        add $03
        cp $90
        jr nc, .else_A
            ld [hl+], a
            ; Move
            ldh a, [hEnemyAttr]
            bit OAMB_XFLIP, a
            jr nz, .else_B
                dec [hl]
                ret
            .else_B:
                inc [hl]
                ret
    .else_A:
        ; Delete self
        call Call_000_3ca6
        ld a, $ff
        ldh [hEnemySpawnFlag], a
        ret
; end proc

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
    ld [cutsceneActive], a
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

    call Call_000_3ca6
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
    ld de, header_759F
    ld a, $03
    ld [enemy_tempSpawnFlag], a
    call enemy_spawnObject.longHeader
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

header_759F:
    db $b2, $80, $00, $00, $00, $00, $00, $00, $00, $ff, $06
    dw enAI_7276

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
    ld de, header_75E2
    ld a, $06
    ld [enemy_tempSpawnFlag], a
    call enemy_spawnObject.shortHeader
    ld a, $15
    ld [sfxRequest_noise], a
    ret

header_75E2:
    db $00, $00, $ff, $00, $00, $00, $ff, $08
    dw enAI_7276

Call_002_75ec: ; 02:75EC - Weird horizontal oscillation pattern
    ldh a, [hEnemy_frameCounter]
    and $03
        ret z
    ld hl, hEnemyXPos
    dec a
    jr z, .else
        dec a
            ret z
        dec [hl]
        dec [hl]
        ret
    .else:
        inc [hl]
        inc [hl]
        ret
; end proc

Call_002_75ff: ; 02:75FF - Another weird horizontal oscillation pattern
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
    jr nz, .endIf
        ld [hl], $b2 ; $B3 is first proper zeta frame
    .endIf:
    inc [hl]
ret

zeta_animateHurt:
    ld hl, hEnemySpriteType
    ld a, [hl]
    cp $bd
    jr nz, .endIf
        ld [hl], $ba
    .endIf:
    inc [hl]
ret

;------------------------------------------------------------------------------
; Omega Metroid ?
enAI_7631: ; 02:7631
    call enemy_getSamusCollisionResults
    ldh a, [hEnemySpawnFlag]
    cp $06
        jp z, omega_fireball

    ld a, [$c41c]
    and a
        call nz, Call_002_7dc6
    ; Act if not stunned
    ld hl, omega_stunCounter
    ld a, [hl]
    and a
        jr z, jr_002_7665
    dec [hl]
        jr z, jr_002_7660
    ; Stun animation
    ldh a, [hEnemy_frameCounter]
    and $01
        ret nz
    call enemy_flipSpriteId.now
    ; Only hit reaction while stunned is screw (?)
    ld a, [$c46d]
    cp $10
        ret nc
    ld a, $0f
    ld [sfxRequest_square1], a
ret


jr_002_7660:
    ; Reset sprite type
    ld a, [omega_tempSpriteType]
    ldh [hEnemySpriteType], a

jr_002_7665:
    ld a, [$c41c]
    and a
    jp z, Jump_002_78dc

    ld a, [$c46d]
    cp $20 ; Touch
        jp nc, omega_touch
    cp $10 ; Screw
        jr z, omega_screw
    cp $08 ; Missiles
        jr z, omega_hurt
omega_plink:
    ld a, $0f
    ld [sfxRequest_square1], a
ret

omega_screw:
    call metroid_screwReaction
    ld a, $1a
    ld [sfxRequest_square1], a
ret

omega_hurt:
    ; Ignore vertical shots
    ld a, [$c46e]
    ld b, a
    ld a, b
    and $03
        jr z, omega_plink
    ; Check if hit from front or behind
    ldh a, [hEnemyAttr]
    bit OAMB_XFLIP, a
    jr nz, .else_A
        bit 1, b
            jr z, omega_oneDamage
        jr omega_weakPoint
    .else_A:
        bit 0, b
            jr z, omega_oneDamage

    omega_weakPoint:
        ; Omega Metroid was hit in the back (do 3x damage)
        ld hl, hEnemyHealth
        ld a, [hl]
        sub $03
            jr c, jr_002_76e1
            jr z, jr_002_76e1
        ld [hl], a
        ld a, $10
        jr omega_endBranch
    omega_oneDamage:
        ld hl, hEnemyHealth
        dec [hl]
            jr z, jr_002_76e1
        ld a, $03
    omega_endBranch:

    ld [omega_stunCounter], a
    ; Save sprite type to temp
    ld hl, hEnemySpriteType
    ld a, [hl]
    ld [omega_tempSpriteType], a
    ; Animate
    ld [hl], $c4
    ; Noise
    ld a, $09
    ld [sfxRequest_noise], a
    ; omega knockback
    bit 0, b
    jr z, .else_B
        ldh a, [hEnemyXPos]
        add $05
        ldh [hEnemyXPos], a
        ret
    .else_B:
        ldh a, [hEnemyXPos]
        sub $05
        cp $10
            ret c
        ldh [hEnemyXPos], a
        ret
; end branch

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
    ld [metroid_fightActive], a
    ldh [hEnemySpawnFlag], a
    ld hl, metroidCountReal
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
    call earthquakeCheck_farCall
    ret


omega_touch:
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
        call omega_faceSamus
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

    ld a, [numEnemies]
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

    call enemy_flipSpriteId_2Bits.twoFrame
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
    ; Chase Samus
    ld b, $02
    ld de, $2000
    call enemy_seekSamus_farCall
    ld hl, hEnemyXPos
    ld a, [samus_onscreenXPos]
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
    call omega_faceSamus
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


omega_fireball: ; Omega fireball?
    ld a, [metroid_fightActive]
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
        call gamma_getAngle_farCall
    jr_002_7861:

    call gamma_getSpeedVector_farCall
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
            call enCollision_up.nearSmall
            ld a, [en_bgCollisionResult]
            bit 3, a
                jr nz, jr_002_78a9
            jr jr_002_7890
        jr_002_7880:
    
        ld hl, hEnemyYPos
        ld a, [hl]
        add b
        ld [hl], a
        call enCollision_down.nearSmall
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
    call enemy_flipSpriteId.now
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


jr_002_78b9: ; Animate fireball explosion
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
    call Call_000_3ca6
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

    ld a, [cutsceneActive]
    and a
    jr nz, jr_002_790c

    ; Check if Samus is in range
    ld hl, hEnemyXPos
    ld a, [hl]
    add $10
    ld b, a
    ld a, [samus_onscreenXPos]
    add $10
    sub b
    jr nc, jr_002_78fa
        cpl
        inc a
    jr_002_78fa:
    cp $50
        ret nc

    ld a, $01
    ld [cutsceneActive], a
    ; Trigger Metroid fight music
    ld a, $0c
    ld [songRequest], a
    ld a, $01
    ld [metroid_fightActive], a

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
    ld de, header_799E
    ld a, $06
    ld [enemy_tempSpawnFlag], a
    call enemy_spawnObject.shortHeader
    ret


Jump_002_7950:
    ld a, $bf
    ldh [hEnemySpriteType], a
    ; Check if Samus is in range
    ld hl, hEnemyXPos
    ld a, [samus_onscreenXPos]
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
    ld [omega_stunCounter], a
    ld [$c46f], a
    ld [$c478], a
    inc a
    ld [$c41c], a
    ld a, $01
    ld [metroid_fightActive], a
    ld a, $ff
    ldh [$e8], a
    ; Trigger Metroid fight music
    ld a, [songPlaying]
    cp $0c
        ret z
    ld a, $0c
    ld [songRequest], a
ret


Jump_002_798b:
    xor a
    ld [hl], a
    ld a, $bf
    ldh [hEnemySpriteType], a
    xor a
    ld [cutsceneActive], a
    inc a
    ld [$c41c], a
    ld a, $04
    ldh [hEnemySpawnFlag], a
    ret

header_799E:
    db $00, $00, $ff, $00, $00, $00, $ff, $08
    dw enAI_7631

Call_002_79a8:
    ld hl, $c46f
    ld a, [hl]
    cp $40
    jr z, jr_002_79b2
        inc [hl]
        ret
    jr_002_79b2:
    ld [hl], $00 ; Loop back to zero
    
    ; If Samus has lost enough health since last time this was called, do something?
    ld hl, samusCurHealthLow
    ld a, [$c470]
    sub [hl]
    cp $30
        jr nc, .case_default

    ld hl, $c478
    inc [hl]
    ld a, [hl]
    dec a
        jr z, .case_1
    dec a
        jr z, .case_2
    dec a
        jr z, .case_3
    dec a
        jr z, .case_4

.case_default:
    xor a
    ld [$c478], a
    ld a, $0c
        jr .exit
.case_1:
    ld a, $14
        jr .exit
.case_2:
    ld a, $28
        jr .exit
.case_3:
    ld a, $40
        jr .exit
.case_4:
    ld a, $60
.exit:
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

; 02:7A06 - Unused?
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
; end unused?

omega_faceSamus: ; 02:7A32
    ld hl, hEnemyXPos
    ld a, [samus_onscreenXPos]
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
    xor $7f ; Osciallate between $BF and $C0
    ld [hl], a
ret

;------------------------------------------------------------------------------
; Larval Metroid?
enAI_7A4F: ; 02:7A4F
    call enemy_getSamusCollisionResults
    ; Check if latched?
    ldh a, [$e7]
    and a
        jr z, jr_002_7ac0 ; Not latched

    call larva_animate
    ld a, [$c475]
    and a
        jr z, jr_002_7ab0
    dec a
        jr z, jr_002_7a71

    call larva_stayAttached
    ; Unlatch if bombed
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
        call enCollision_up.farWide
        ld a, [en_bgCollisionResult]
        bit 3, a
        jr z, jr_002_7a98
            ld a, [enemy_yPosMirror]
            ldh [hEnemyYPos], a
    jr_002_7a98:

    ldh a, [hEnemyXPos]
    sub $03
    cp $10
        ret c
    ldh [hEnemyXPos], a
    call enCollision_left.farWide
    ld a, [en_bgCollisionResult]
    bit 2, a
        ret z
    ld a, [enemy_xPosMirror]
    ldh [hEnemyXPos], a
ret


jr_002_7ab0:
    xor a
    ld [$c474], a
    ldh [$e7], a
    ld [$c475], a
    ; Reset seek vector
    ld a, $10
    ldh [$e9], a
    ldh [hEnemyState], a
ret

; Normal AI (not latched)
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
        jr z, jr_002_7b43 ; Not frozen

; Frozen
    call Call_002_565f ; Generic ice stuff
    ldh a, [hEnemyIceCounter]
    and a
        jr z, jr_002_7aee

    ; Frozen shot reactions
    ld a, [$c46d]
    cp $20 ; Touch
        ret nc
    cp $08 ; Missiles
        jr z, larva_hurt
    dec a ; $01 - Ice (refreeze)
        jp z, larva_freeze
    ; Plink
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


larva_hurt:
    ld hl, hEnemyHealth
    dec [hl]
    ld a, [hl]
    and a
        jr z, larva_die
    ld a, $03
    ld [$c473], a
    ld a, $cf
    ldh [hEnemySpriteType], a
    ld a, $05
    ld [sfxRequest_noise], a
ret


larva_die:
    xor a
    ldh [$e9], a
    ld [$c474], a
    ld [$c475], a
    
    ld a, $02
    ldh [hEnemySpawnFlag], a
    ld a, $10
    ldh [hEnemyExplosionFlag], a
    ld a, $0d
    ld [sfxRequest_noise], a
    ; Adjust Metroid counts
    ld hl, metroidCountReal
    ld a, [hl]
    sub $01
    daa
    ld [hl], a
    ld hl, metroidCountDisplayed
    ld a, [hl]
    sub $01
    daa
    ld [hl], a
    ; Shuffle counter
    ld a, $c0
    ld [metroidCountShuffleTimer], a
    ; Earthquake
    call earthquakeCheck_farCall
ret


jr_002_7b43: ; Normal shot reactions
    call larva_animate
    ld a, [$c46d]
    cp $ff ; Nothing
        jp z, larva_notHit
    cp $20 ; Touch
        jp z, larva_touch
    cp $10 ; Screw
        jr z, larva_screwBomb
    cp $09 ; Bomb
        jr z, larva_screwBomb
    dec a ; $01 - Ice
        jr z, larva_freeze
    ld a, $0f
    ld [sfxRequest_square1], a
ret

larva_touch:
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


larva_screwBomb:
    xor a
    ldh [$e9], a
    call metroid_screwReaction
    ld a, $1a
    ld [sfxRequest_square1], a
ret


larva_freeze:
    ld a, $1a
    ld [sfxRequest_square1], a
    ld a, $10
    ldh [hEnemyStunCounter], a
    ld a, $44
    ldh [hEnemyIceCounter], a
    xor a
    ldh [hEnemyStatus], a
ret


larva_notHit:
    ldh a, [$e8]
    inc a
    jr z, jr_002_7bc0
        call Call_002_6e7f ; Screw attack knockback?
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
        ; Chase Samus
        ld b, $01
        ld de, $1e02
        call enemy_seekSamus_farCall ; Move
        call Call_002_7cdd ; Correct position
        ret


larva_animate:
    ldh a, [hEnemy_frameCounter]
    and $03
        ret nz
    ld hl, hEnemySpriteType
    ld a, [hl]
    xor $6e ; Osciallate between $A0 and $CE
    ld [hl], a
ret


larva_stayAttached: ; Stay attached to Samus
    ld hl, hEnemyYPos
    ld a, [samus_onscreenYPos]
    ld [hl+], a
    ld a, [samus_onscreenXPos]
    ld [hl], a
ret

;------------------------------------------------------------------------------
; Baby Metroid AI
enAI_babyMetroid: ; 02:7BE5
    ld a, [$c41c]
    and a
        jr z, .case_0 ; case 0
    dec a
        jr z, .case_1 ; case 1
    dec a ; v--- sneaky nz instead of z
        jp nz, .case_3 ; default case (3)
        
; case 2 (active)
    call enemy_flipSpriteId.fourFrame
    ; Chase Samus
    ld b, $02
    ld de, $2000
    call enemy_seekSamus_farCall
    
    call baby_checkBlocks
    call baby_keepOnscreen
ret


.case_1: ; case 1 - Metroid moves up from the egg
    call Call_002_75ff ; Oscillate horizontally
    ; Move up
    ld hl, hEnemyYPos
    dec [hl]
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    cp $0c
        ret nz
    ; Set up $E9/$EA for seekSamus
    ld a, $10
    ld [hl+], a
    ld [hl], a
    ; Set to state 2 (active)
    ld hl, $c41c
    inc [hl]
    ; Clear cutscene
    xor a
    ld [cutsceneActive], a
ret


.case_0: ; case 0 - Waiting
    ldh a, [hEnemySpawnFlag]
    cp $04
    jr z, .else_A
        call .animateFlash
        ; Check if Samus is in range
        ld hl, hEnemyXPos
        ld a, [samus_onscreenXPos]
        sub [hl]
        jr nc, .endIf_B
            cpl
            inc a
        .endIf_B:
        cp $18
            ret nc
            
        dec l
        ld a, [samus_onscreenYPos]
        sub [hl]
        jr nc, .endIf_C
            cpl
            inc a
        .endIf_C:    
        cp $10
            ret nc

        ld a, $01
        ld [cutsceneActive], a
        call .animateEggWiggle ; Animate egg hatching
        ld hl, hEnemyState
        inc [hl]
        ld a, [hl]
        cp $30
            ret nz
        xor a
        ld [hl-], a
        ld [hl], a
        ldh [hEnemyStunCounter], a
        ld a, $03 ; State 3
        ld [$c41c], a
        ld hl, metroid_fightActive
        inc [hl]
        ld a, $04
        ldh [hEnemySpawnFlag], a
        ld a, $16
        ld [sfxRequest_noise], a
        ret
    .else_A:
        ld a, $a8
        ldh [hEnemySpriteType], a
        ; Check if Samus is in range
        ld hl, hEnemyXPos
        ld a, [samus_onscreenXPos]
        sub [hl]
        jr nc, .endIf_D
            cpl
            inc a
        .endIf_D:
        cp $60
            ret nc

        ld a, $01
        ld [metroid_fightActive], a
        ; Set to state 2 (active)
        ld a, $02
        ld [$c41c], a
        ld a, $16
        ld [sfxRequest_noise], a
        ret
; end proc

.case_3: ; Case 2 - Egg exploding
    ld hl, $ffe9
    inc [hl]
    ld a, [hl]
    bit 0, a
    jr z, .else_E
        srl a
        add $e2 ; Explosion
        ldh [hEnemySpriteType], a
        ret
    .else_E:
        cp $0c
            call z, .prepState1
        ld a, $a8
        ldh [hEnemySpriteType], a
        ret
; end proc

.prepState1:
    ; Reset timer
    ld [hl], $00
    ; Set state to 1
    ld a, $01
    ld [$c41c], a
ret


.animateFlash:
    ; Do every 4 frames
    ldh a, [hEnemy_frameCounter]
    and $03
        ret nz
    ; Flash by oscillating this value between $00 and $10
    ld hl, hEnemyStunCounter
    ld a, [hl]
    xor $10
    ld [hl], a
ret

.animateEggWiggle: ; Animate egg hatching
    ldh a, [hEnemy_frameCounter]
    and $01
        ret nz
    ld hl, hEnemySpriteType
    ldh a, [$e9]
    dec a
    jr z, .else
        inc [hl]
        ld a, [hl]
        cp $a7 ; Upper threshold of wiggle
            ret nz
    
    ; Switch direction of wiggle
      .switchDirection:
        ld hl, $ffe9
        ld a, [hl]
        xor $01
        ld [hl], a
        ret
        
    .else:
        dec [hl]
        ld a, [hl]
        cp $a5 ; Lower threshold of wiggle
            ret nz
        jr .switchDirection


Call_002_7cdd: ; 02:7CDD
    ; Some really messy if statements in this function
    ldh a, [$e9]
    cp $10
    jr c, jr_002_7cf4
        call enCollision_down.farWide
        ld a, [en_bgCollisionResult]
        bit 1, a
            jr z, jr_002_7d04
    
        jr_002_7ced:
        ld a, [enemy_yPosMirror]
        ldh [hEnemyYPos], a
            jr jr_002_7d04
    jr_002_7cf4:
        ldh a, [hEnemyYPos]
        cp $10
            jr c, jr_002_7ced
        call enCollision_up.farWide
        ld a, [en_bgCollisionResult]
        bit 3, a
            jr nz, jr_002_7ced
    jr_002_7d04:

    ldh a, [hEnemyState]
    cp $10
    jr c, jr_002_7d19
        call enCollision_right.farWide
        ld a, [en_bgCollisionResult]
        bit 0, a
            ret z
            
        jr_002_7d13:
        ld a, [enemy_xPosMirror]
        ldh [hEnemyXPos], a
        ret
    jr_002_7d19:
        ldh a, [hEnemyXPos]
        cp $10
            jr c, jr_002_7d13
        call enCollision_left.farWide
        ld a, [en_bgCollisionResult]
        bit 2, a
            jr nz, jr_002_7d13
ret


baby_checkBlocks: ; 02:7D2A - Check if blocks need to be cleared
    ; Some really messy if statements in this function
    ld hl, hEnemyXPos
    ld a, [hl]
    ld [baby_tempXpos], a
    ld a, [enemy_xPosMirror]
    ld [hl], a
    ldh a, [$e9]
    cp $10
    jr c, jr_002_7d54
        call enCollision_down.midMedium
        ld a, [en_bgCollisionResult]
        bit 1, a
            jr z, jr_002_7d64

        jr_002_7d45:
        ld a, [$c417]
        cp $64 ; Tile ID of the block the baby can clear
        call z, baby_clearBlock
    
        jr_002_7d4d:
        ld a, [enemy_yPosMirror]
        ldh [hEnemyYPos], a
            jr jr_002_7d64
    jr_002_7d54:
        ldh a, [hEnemyYPos]
        cp $10
            jr c, jr_002_7d4d
        call enCollision_up.midMedium
        ld a, [en_bgCollisionResult]
        bit 3, a
            jr nz, jr_002_7d45
    jr_002_7d64:

    ld a, [baby_tempXpos]
    ldh [hEnemyXPos], a
    ldh a, [hEnemyState]
    cp $10
    jr c, jr_002_7d86
        call enCollision_right.midMedium
        ld a, [en_bgCollisionResult]
        bit 0, a
            ret z
    
        jr_002_7d78:
        ld a, [$c417]
        cp $64 ; Tile ID of the block the baby can clear
            call z, baby_clearBlock
    
        jr_002_7d80:
        ld a, [enemy_xPosMirror]
        ldh [hEnemyXPos], a
        ret
    jr_002_7d86:
        ldh a, [hEnemyXPos]
        cp $10
            jr c, jr_002_7d80
    
        call enCollision_left.midMedium
        ld a, [en_bgCollisionResult]
        bit 2, a
            jr nz, jr_002_7d78
ret


baby_clearBlock: ; 02:7D97
    call destroyBlock_farCall
    ld a, $16
    ld [sfxRequest_noise], a
ret

; end baby specific code

; Verify that enemy was hit by Samus, and copy the results to a working variable
;  Return values ($C46D)
; $00 - Power beam
; $01 - Ice
; $02 - Wave
; $03 - Spazer
; $04 - Plasma
; $09 - Bombs
; $10 - Screw
; $20 - Touch
; $FF - Nothing
enemy_getSamusCollisionResults: ; 02:7DA0
    ; Save null result first
    ld a, $ff
    ld [$c46d], a
    ld c, a
    ; if the pointers at $C467 and $FFFC are different, then exit
    ; - these both appears to be the pointers to the enemy data in WRAM ($C600 region)
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
    ; A collision has occurred
    dec l
    ld c, [hl] ; Read $C466
    ld a, $ff
    ld [hl+], a ; Clear $C466
    ld [hl+], a ; Clear $C467
    ld [hl+], a ; Clear $C468
    ld b, [hl]  ; Read $C469
    ld [hl], a
    ; Save results
    ld a, c
    ld [$c46d], a ; Collision type
    ld a, b
    ld [$c46e], a ; Direction hit from
ret


Call_002_7dc6: ; Used to keep zeta and omegas onscreen?
    ld bc, $1890 ; Not a pointer. This is just loading two different values into B and C.
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
; end proc

baby_keepOnscreen:
    ld bc, $1890 ; Not a pointer. B is a minimum and C is a maximum
    ; Clamp Y position between B and C
    ld hl, hEnemyYPos
    ld a, [hl]
    cp b
    jr nc, .else_A
        ld [hl], b
        jr .endIf_A
    .else_A:
        cp c
        jr c, .endIf_A
            ld [hl], c
    .endIf_A:
    
    ; Clamp X position between B and C
    inc l
    ld a, [hl]
    cp b
    jr nc, .else_B
        ld [hl], b
        ret
    .else_B:
        cp c
            ret c
        ld [hl], c
        ret
; end proc

enemy_toggleVisibility: ; 02:7DF8
    ; Exit if the frame is odd
    ldh a, [hEnemy_frameCounter]
    and $01
        ret nz
    ; Toggle visibility
    ld hl, hEnemyStatus
    ld a, [hl]
    xor $80
    ld [hl], a
ret

; 02:7E05 - Freespace 