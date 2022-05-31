; Disassembly of "Metroid2.gb"
; This file was created with:
; mgbdis v1.4 - Game Boy ROM disassembler by Matt Currie and contributors.
; https://github.com/mattcurrie/mgbdis

SECTION "ROM Bank $000", ROM0[$0]

; Note: RSTs 10, 18, 20, 30, and 38 are unused
RST_00:: jp bootRoutine
    db $00,$00,$00,$00,$00

RST_08:: jp bootRoutine
    db $00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00

RST_28:: ; Jump table routine (index = a)
    ; HL = PC + A*2
    add a
    pop hl ; Grab the program counter from the stack
    ld e, a
    ld d, $00
    add hl, de
    ld e, [hl]
    inc hl
    ld d, [hl]
    push de
    pop hl
    jp hl

    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

VBlankInterrupt:: jp VBlankHandler
    db $00,$00,$00,$00,$00

LCDCInterrupt:: jp LCDCInterruptHandler
    db $00,$00,$00,$00,$00

TimerOverflowInterrupt:: jp TimerOverflowInterruptStub
    db $00,$00,$00,$00,$00

SerialTransferCompleteInterrupt:: jp SerialTransferInterruptStub
    db $00,$00,$00,$00,$00

JoypadTransitionInterrupt:: nop

SECTION "ROM Header", ROM0[$0100]

Boot:: ; 00:0100
    nop
    jp jumpToBoot

HeaderLogo:: NINTENDO_LOGO
HeaderTitle:: db "METROID2", $00, $00, $00, $00, $00, $00, $00, $00
HeaderNewLicenseeCode:: db $00, $00
HeaderSGBFlag::         db $00
HeaderCartridgeType::   db $03
HeaderROMSize::         db $03
HeaderRAMSize::         db $02
HeaderDestinationCode:: db $01
HeaderOldLicenseeCode:: db $01
HeaderMaskROMVersion::  db $00
HeaderComplementCheck:: db $97
HeaderGlobalChecksum::  db $58, $1f

jumpToBoot: ; 00:0150
    jp bootRoutine

SerialTransferInterruptStub:
    reti

VBlankHandler: ; 00:0154
    di
    push af
    push bc
    push de
    push hl
    ld a, [$c205]
    ldh [rSCY], a
    ld a, [$c206]
    ldh [rSCX], a
    ld a, [$d07e]
    ldh [rBGP], a
    ld a, [$d07f]
    ldh [rOBP0], a
    ld a, [$d080]
    ldh [rOBP1], a
    
    ; Decrement countdown timer every frame
    ld a, [countdownTimerLow]
    sub $01
    ld [countdownTimerLow], a
    ld a, [countdownTimerHigh]
    sbc $00
    ld [countdownTimerHigh], a
    jr nc, jr_000_018b
        ; Minimum timer value is $0000
        xor a
        ld [countdownTimerLow], a
        ld [countdownTimerHigh], a
    jr_000_018b:
    
    ld a, [credits_nextLineReady]
    and a
    jp nz, VBlank_drawCreditsLine_longJump

    ld a, [$d059]
    and a
    jp nz, Jump_000_2fe1

    ld a, [$d047]
    and a
    jp nz, Jump_000_2ba3

    ld a, [$d08e]
    and a
    jp nz, Jump_000_2b8f

    ld a, [$d08b]
    cp $11
    jr z, jr_000_01d9

    ld a, [$de01]
    and a
    jr z, jr_000_01bf

    ld a, [currentLevelBank]
    ld [rMBC_BANK_REG], a
    call Call_000_08cf
    jr jr_000_01c7

jr_000_01bf:
    ld a, $01
    ld [rMBC_BANK_REG], a
    call $493e

jr_000_01c7:
    call OAM_DMA ; Sprite DMA
    ld a, [bankRegMirror]
    ld [rMBC_BANK_REG], a
    ld a, $01
    ldh [$82], a
    pop hl
    pop de
    pop bc
    pop af
reti


jr_000_01d9:
    ld a, $01
    ld [rMBC_BANK_REG], a
    call $493e
    call OAM_DMA
    ld a, $03
    ld [rMBC_BANK_REG], a
    call $7cf0
    ld a, [bankRegMirror]
    ld [rMBC_BANK_REG], a
    ld a, $01
    ldh [$82], a
    pop hl
    pop de
    pop bc
    pop af
    reti


bootRoutine: ; 00:01fB
    xor a
    ld hl, $dfff
    ld c, $10
    ld b, $00

    jr_000_0203:
            ld [hl-], a
            dec b
        jr nz, jr_000_0203
        dec c
    jr nz, jr_000_0203

    ld a, $01
    di
    ldh [rIF], a
    ldh [rIE], a
    xor a
    ldh [rSCY], a
    ldh [rSCX], a
    ldh [rSTAT], a
    ldh [rSB], a
    ldh [rSC], a
    ld a, $80
    ldh [rLCDC], a

jr_000_0220:
    ldh a, [rLY]
    cp $94
    jr nz, jr_000_0220

    ld a, $03
    ldh [rLCDC], a
    ld a, $93
    ld [$d07e], a
    ld a, $93
    ld [$d07f], a
    ld a, $43
    ld [$d080], a
    ld sp, $dfff
    call Call_000_2378
    ld a, $0a
    ld [$0000], a
    xor a
    ld hl, $dfff
    ld b, $00

jr_000_024a:
    ld [hl-], a
    dec b
    jr nz, jr_000_024a

    ld hl, $cfff
    ld c, $10
    ld b, $00

jr_000_0255:
    ld [hl-], a
    dec b
    jr nz, jr_000_0255

    dec c
    jr nz, jr_000_0255

    ld a, $ff
    ld hl, $caff
    ld c, $06
    ld b, $00

jr_000_0265:
    ld [hl-], a
    dec b
    jr nz, jr_000_0265

    dec c
    jr nz, jr_000_0265

    xor a
    ld hl, $9fff
    ld c, $20
    ld b, $00

jr_000_0274:
    ld [hl-], a
    dec b
    jr nz, jr_000_0274

    dec c
    jr nz, jr_000_0274

    ld hl, $feff
    ld b, $00

jr_000_0280:
    ld [hl-], a
    dec b
    jr nz, jr_000_0280

    ld hl, $fffe
    ld b, $80

    jr_000_0289:
        ld [hl-], a
        dec b
    jr nz, jr_000_0289

    ; Load OAM DMA routine to HRAM
    ld c, LOW(OAM_DMA)
    ld b, $0a
    ld hl, oamDMA_routine
    jr_000_0294:
        ld a, [hl+]
        ld [c], a
        inc c
        dec b
    jr nz, jr_000_0294

    call Call_000_037b
    ld a, $01
    ldh [rIE], a
    ld a, $07
    ldh [rWX], a
    ld a, $80
    ldh [rLCDC], a
    ei
    xor a
    ldh [rIF], a
    ldh [rWY], a
    ldh [rTMA], a
    ld a, $0a
    ld [$0000], a
    xor a
    ld [$d0a3], a
    ld a, [$a0c0]
    cp $03
    jr nc, jr_000_02c4

    ld [$d0a3], a

jr_000_02c4:
    ld a, $00
    ldh [gameMode], a
    ld a, $00
    ld [$0000], a

Jump_000_02cd:
    xor a
    ld [$de01], a
    ld a, [$d00e]
    and a
    call z, main_readInput
    call main_handleGameMode
    call handleAudio
    call Call_000_239c
    ldh a, [hInputPressed]
    and PADF_START | PADF_SELECT | PADF_B | PADF_A ;$0f
    cp PADF_START | PADF_SELECT | PADF_B | PADF_A
    jp z, bootRoutine

    call Call_000_031c
    jp Jump_000_02cd

; 0:02F0
main_handleGameMode:
    ldh a, [gameMode]
    rst $28
        dw gameMode_Boot
        dw gameMode_Title
        dw gameMode_LoadA
        dw gameMode_LoadB
        dw gameMode_Main
        dw $36B0
        dw $2F86
        dw $371B
        dw gameMode_Paused
        dw $3CE2
        dw $3ACE
        dw $3E67
        dw $3E72
        dw gameMode_None
        dw gameMode_None
        dw $3B2F
        dw $3B43
        dw $3BA1
        dw gameMode_prepareCredits
        dw gameMode_Credits

gameMode_None:
    ret


Call_000_031c:
    db $76

jr_000_031d:
    ldh a, [$82]
    and a
    jr z, jr_000_031d

    ldh a, [$97]
    inc a
    ldh [$97], a
    and a
    jr nz, jr_000_0365

    ldh a, [gameMode]
    cp $04
    jr nz, jr_000_0365

    ld a, [$d0a2]
    inc a
    ld [$d0a2], a
    cp $0e
    jr nz, jr_000_0365

    xor a
    ld [$d0a2], a
    ld a, [gameTimeMinutes]
    add $01
    daa
    ld [gameTimeMinutes], a
    cp $60
    jr c, jr_000_0365

    xor a
    ld [gameTimeMinutes], a
    ld a, [gameTimeHours]
    add $01
    daa
    ld [gameTimeHours], a
    jr nz, jr_000_0365

    ld a, $59
    ld [gameTimeMinutes], a
    ld a, $99
    ld [gameTimeHours], a

jr_000_0365:
    xor a
    ldh [$82], a
    ld a, $c0
    ldh [$8c], a
    xor a
    ldh [hOamBufferIndex], a
    ret


Call_000_0370:
    xor a
    ld hl, $c000
    ld b, $a0

jr_000_0376:
    ld [hl+], a
    dec b
    jr nz, jr_000_0376

    ret


Call_000_037b:
    ld hl, $9fff
    ld bc, $0800

jr_000_0381:
    ld a, $ff
    ld [hl-], a
    dec bc
    ld a, b
    or c
    jr nz, jr_000_0381

    ret


Call_000_038a:
jr_000_038a:
    ld a, [hl+]
    ld [de], a
    inc de
    dec bc
    ld a, b
    or c
    jr nz, jr_000_038a

    ret


jr_000_0393:
    ld a, [de]
    cp $ff
    ret z

    ld [hl+], a
    inc de
    jr jr_000_0393

TimerOverflowInterruptStub:
    reti


Call_000_039c:
    ldh a, [rIE]
    ldh [$99], a
    res 0, a
    ldh [rIE], a

jr_000_03a4:
    ldh a, [rLY]
    cp $91
    jr nz, jr_000_03a4


    ldh a, [rLCDC]
    and $7f
    ldh [rLCDC], a
    ldh a, [$99]
    ldh [rIE], a
    ret

gameMode_LoadA:
    call Call_000_0ca3
    ld a, $08
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld a, [$d80d]
    ld l, a
    ld a, [$d80e]
    ld h, a
    ld de, $da00

jr_000_03cb:
    ld a, [hl+]
    ld [de], a
    inc de
    ld a, d
    cp $dc
    jr nz, jr_000_03cb

    ld a, [$d80f]
    ld l, a
    ld a, [$d810]
    ld h, a

jr_000_03db:
    ld a, [hl+]
    ld [de], a
    inc de
    ld a, d
    cp $dd
    jr nz, jr_000_03db

    ld a, [$d811]
    ld [currentLevelBank], a
    ld a, [$d812]
    ld [$d056], a
    ld a, [$d813]
    ld [$d069], a
    ld a, [$d814]
    ld [$d08a], a
    ld a, [$d81f]
    ld [acidDamageValue], a
    ld a, [$d820]
    ld [spikeDamageValue], a
    ld a, [$d821]
    ld [metroidCountReal], a
    ld a, [$d822]
    ld [$d092], a
    ld a, [$d823]
    ld [gameTimeMinutes], a
    ld a, [$d824]
    ld [gameTimeHours], a
    ld a, [$d825]
    ld [$d09a], a
    xor a
    ld [$d00e], a
    ld [$d059], a
    ld [$d063], a
    ld [$d047], a
    ld [$d06b], a
    ld [$d06c], a
    ld [$d06d], a
    ld [$d06e], a
    ld a, $01
    ld [$d08b], a
    ld a, $ff
    ld [$d05d], a
    ld hl, $d900

jr_000_044b:
    xor a
    ld [hl], a
    ld a, l
    add $10
    ld l, a
    jr nz, jr_000_044b

    ld a, $02
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call $418c
    ldh a, [gameMode]
    inc a
    ldh [gameMode], a
    ret

gameMode_LoadB:
    call Call_000_039c
    call Call_000_05fd
    call Call_000_3bb4
    
    ld a, [saveBuf_cameraYPixel]
    ldh [hCameraYPixel], a
    ld a, [saveBuf_cameraYScreen]
    ldh [hCameraYScreen], a
    ld a, [saveBuf_cameraXPixel]
    ldh [hCameraXPixel], a
    ld a, [saveBuf_cameraXScreen]
    ldh [hCameraXScreen], a
    
    ld a, [currentLevelBank]
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a

jr_000_048a:
    ld a, $00
    ldh [$af], a
    ld a, $de
    ldh [$b0], a
    call Call_000_06cc
    call Call_000_08cf
    ldh a, [hCameraYPixel]
    add $10
    ldh [hCameraYPixel], a
    ldh a, [hCameraYScreen]
    adc $00
    and $0f
    ldh [hCameraYScreen], a
    ldh a, [hCameraYPixel]
    ld b, a
    ld a, [saveBuf_cameraYPixel]
    cp b
    jr nz, jr_000_048a

    ld a, [saveBuf_cameraYPixel]
    ldh [hCameraYPixel], a
    ld a, [saveBuf_cameraYScreen]
    ldh [hCameraYScreen], a
    ld a, [saveBuf_cameraXPixel]
    ldh [hCameraXPixel], a
    ld a, [saveBuf_cameraXScreen]
    ldh [hCameraXScreen], a

    ldh a, [hCameraYPixel]
    sub $78
    ld [$c205], a
    ldh a, [hCameraXPixel]
    sub $30
    ld [$c206], a
    ld a, $e3
    ldh [rLCDC], a
    xor a
    ld [$d011], a
    ldh a, [gameMode]
    inc a
    ldh [gameMode], a
ret

gameMode_Main:
    ld a, [samusPose]
    and $7f
    cp $18
    jp nc, Jump_000_0578

    call Call_000_3d6d
    ld a, [$d084]
    ld b, a
    ld a, [$d085]
    or b
    call z, Call_000_2fa2
    ldh a, [hSamusYPixel]
    ld [$d029], a
    ldh a, [hSamusYScreen]
    ld [$d02a], a
    ldh a, [hSamusXPixel]
    ld [$d027], a
    ldh a, [hSamusXScreen]
    ld [$d028], a
    ld a, [$c463]
    and a
    jr z, jr_000_0522

    ld a, [samusPose]
    res 7, a
    ld [samusPose], a
    ldh a, [hInputRisingEdge]
    bit PADB_SELECT, a
    call nz, Call_000_2212
    jr jr_000_053e

jr_000_0522:
    ld a, [$d00e]
    and a
    jr nz, jr_000_053e

    xor a
    ld [$d05c], a
    call Call_000_2ee3
    call Call_000_0d21
    call Call_000_32ab
    call Call_000_21fb
    call Call_000_3d8e
    call Call_000_3d99

jr_000_053e:
    call Call_000_0698
    call Call_000_08fe
    call Call_000_2366
    call handleItemPickup
    call Call_000_3e93
    call Call_000_3da4
    call Call_000_3d83
    call Call_000_3d78
    ld a, [$d049]
    and a
    jr z, jr_000_0560

    dec a
    ld [$d049], a

jr_000_0560:
    call Call_000_3e9e
    ldh a, [hOamBufferIndex]
    ld [$d064], a
    ld a, [$d08e]
    and a
    jr nz, jr_000_0571

    call Call_000_05de

jr_000_0571:
    call Call_000_3e88
    call Call_000_2c79
    ret


Jump_000_0578:
    call Call_000_3d6d
    ld a, [$d084]
    ld b, a
    ld a, [$d085]
    or b
    call z, Call_000_2fa2
    ldh a, [hSamusYPixel]
    ld [$d029], a
    ldh a, [hSamusYScreen]
    ld [$d02a], a
    ldh a, [hSamusXPixel]
    ld [$d027], a
    ldh a, [hSamusXScreen]
    ld [$d028], a
    xor a
    ld [$d05c], a
    call Call_000_0d21
    call Call_000_32ab
    call Call_000_21fb
    call Call_000_3d8e
    call Call_000_3d99
    call Call_000_0698
    call Call_000_08fe
    call Call_000_2366
    call Call_000_3e93
    call Call_000_3da4
    call Call_000_3d83
    call Call_000_3d78
    ld a, [$d049]
    and a
    jr z, jr_000_05cc

    dec a
    ld [$d049], a

jr_000_05cc:
    call Call_000_3e9e
    ldh a, [hOamBufferIndex]
    ld [$d064], a
    call Call_000_05de
    call Call_000_3e88
    call Call_000_2c79
    ret


Call_000_05de:
    ld a, [$d08b]
    cp $11
    jr z, jr_000_05f1

    ld a, $02
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call $4000
    ret


jr_000_05f1:
    ld a, $03
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call $6e36
    ret


Call_000_05fd:
    ld a, $07
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld bc, $0100
    ld hl, $7a90
    ld de, $8f00
    call Call_000_038a
    ld a, $06
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld bc, $0b00
    ld hl, $4320
    ld de, $8000
    call Call_000_038a
    ld a, $06
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld bc, $0400
    ld a, [$d808]
    ld l, a
    ld a, [$d809]
    ld h, a
    ld de, $8b00
    call Call_000_038a
    ld a, [$d079]
    and a
    jr z, jr_000_0658

    ld a, BANK(gfx_itemFont)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld bc, $0200
    ld hl, gfx_itemFont
    ld de, $8c00
    call Call_000_038a

jr_000_0658:
    ld a, [$d80a]
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld bc, $0800
    ld a, [$d80b]
    ld l, a
    ld a, [$d80c]
    ld h, a
    ld de, $9000
    call Call_000_038a
    ret


Call_000_0673:
    xor a
    ldh [$cc], a
    ldh [$ce], a
    ldh a, [hCameraYScreen]
    ldh [$cd], a
    ldh a, [hCameraXScreen]
    ldh [$cf], a

jr_000_0680:
    ld a, $00
    ldh [$af], a
    ld a, $de
    ldh [$b0], a
    call Call_000_0788
    call Call_000_08cf
    ldh a, [$cc]
    add $10
    ldh [$cc], a
    and a
    jr nz, jr_000_0680

    ret


Call_000_0698:
    ld a, [currentLevelBank]
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld a, $00
    ldh [$af], a
    ld a, $de
    ldh [$b0], a
    xor a
    ld [$d04c], a
    ldh a, [$97]
    and $03
    jr z, jr_000_06c1

    cp $01
    jr z, jr_000_06f3

    cp $02
    jr z, jr_000_0724

    cp $03
    jp z, Jump_000_0756

    ret


jr_000_06c1:
    ld a, [$d023]
    bit 6, a
    ret z

    ld a, $ff
    ld [$d04c], a

Call_000_06cc:
    ldh a, [hCameraXPixel]
    sub $80
    ldh [$ce], a
    ldh a, [hCameraXScreen]
    sbc $00
    and $0f
    ldh [$cf], a
    ldh a, [hCameraYPixel]
    sub $78
    ldh [$cc], a
    ldh a, [hCameraYScreen]
    sbc $00
    and $0f
    ldh [$cd], a
    ld a, [$d023]
    res 6, a
    ld [$d023], a
    jp Jump_000_0788


jr_000_06f3:
    ld a, [$d023]
    bit 7, a
    ret z

    ld a, $ff
    ld [$d04c], a
    ldh a, [hCameraXPixel]
    sub $80
    ldh [$ce], a
    ldh a, [hCameraXScreen]
    sbc $00
    and $0f
    ldh [$cf], a
    ldh a, [hCameraYPixel]
    add $78
    ldh [$cc], a
    ldh a, [hCameraYScreen]
    adc $00
    and $0f
    ldh [$cd], a
    ld a, [$d023]
    res 7, a
    ld [$d023], a
    jr jr_000_0788

jr_000_0724:
    ld a, [$d023]
    bit 5, a
    ret z

    ld a, $ff
    ld [$d04c], a
    ldh a, [hCameraXPixel]
    sub $80
    ldh [$ce], a
    ldh a, [hCameraXScreen]
    sbc $00
    and $0f
    ldh [$cf], a
    ldh a, [hCameraYPixel]
    sub $78
    ldh [$cc], a
    ldh a, [hCameraYScreen]
    sbc $00
    and $0f
    ldh [$cd], a
    ld a, [$d023]
    res 5, a
    ld [$d023], a
    jp Jump_000_07e4


Jump_000_0756:
    ld a, [$d023]
    bit 4, a
    ret z

    ld a, $ff
    ld [$d04c], a
    ldh a, [hCameraXPixel]
    add $70
    ldh [$ce], a
    ldh a, [hCameraXScreen]
    adc $00
    and $0f
    ldh [$cf], a
    ldh a, [hCameraYPixel]
    sub $78
    ldh [$cc], a
    ldh a, [hCameraYScreen]
    sbc $00
    and $0f
    ldh [$cd], a
    ld a, [$d023]
    res 4, a
    ld [$d023], a
    jp Jump_000_07e4


Call_000_0788:
Jump_000_0788:
jr_000_0788:
    call Call_000_0835
    ld a, $10
    ldh [$ae], a

jr_000_078f:
    call Call_000_0886
    ldh a, [$aa]
    add $02
    ldh [$aa], a
    ldh a, [$ab]
    adc $00
    and $9b
    ldh [$ab], a
    ldh a, [$aa]
    and $df
    ldh [$aa], a
    ldh a, [$ad]
    add $01
    ldh [$ad], a
    and $0f
    jr nz, jr_000_07d2

    ldh a, [$ad]
    sub $10
    ldh [$ad], a
    ldh a, [$ac]
    and $f0
    ld b, a
    ldh a, [$ac]
    inc a
    and $0f
    or b
    ldh [$ac], a
    ld e, a
    ld d, $00
    sla e
    rl d
    ld hl, $4000
    add hl, de
    ld a, [hl+]
    ld c, a
    ld a, [hl]
    ld b, a

jr_000_07d2:
    ldh a, [$ae]
    dec a
    ldh [$ae], a
    jr nz, jr_000_078f

    ldh a, [$af]
    ld l, a
    ldh a, [$b0]
    ld h, a
    ld a, $00
    ld [hl+], a
    ld [hl], a
    ret


Call_000_07e4:
Jump_000_07e4:
    ld a, [$d023]
    and $cf
    ld [$d023], a
    call Call_000_0835
    ld a, $10
    ldh [$ae], a

jr_000_07f3:
    call Call_000_0886
    ldh a, [$aa]
    add $40
    ldh [$aa], a
    ldh a, [$ab]
    adc $00
    and $9b
    ldh [$ab], a
    ldh a, [$ad]
    add $10
    ldh [$ad], a
    and $f0
    jr nz, jr_000_0823

    ldh a, [$ac]
    add $10
    ldh [$ac], a
    ld e, a
    ld d, $00
    sla e
    rl d
    ld hl, $4000
    add hl, de
    ld a, [hl+]
    ld c, a
    ld a, [hl]
    ld b, a

jr_000_0823:
    ldh a, [$ae]
    dec a
    ldh [$ae], a
    jr nz, jr_000_07f3

    ldh a, [$af]
    ld l, a
    ldh a, [$b0]
    ld h, a
    ld a, $00
    ld [hl+], a
    ld [hl], a
    ret


Call_000_0835:
    ldh a, [$cd]
    swap a
    and $f0
    ld b, a
    ldh a, [$cf]
    and $0f
    or b
    ldh [$ac], a
    ld e, a
    ld d, $00
    sla e
    rl d
    ld hl, $4000
    add hl, de
    ld a, [hl+]
    ld c, a
    ld a, [hl]
    ld b, a
    ldh a, [$cc]
    and $f0
    ld l, a
    ldh a, [$ce]
    swap a
    and $0f
    or l
    ldh [$ad], a
    ld hl, $9800
    ldh a, [$cc]
    and $f0
    ld e, a
    xor a
    ld d, a
    sla e
    rl d
    sla e
    rl d
    add hl, de
    ldh a, [$ce]
    and $f0
    swap a
    sla a
    ld e, a
    ld d, $00
    add hl, de
    ld a, l
    ldh [$aa], a
    ld a, h
    ldh [$ab], a
    ret


Call_000_0886:
    ldh a, [$ad]
    ld l, a
    ld h, $00
    add hl, bc
    ld a, [hl]
    ld e, a
    xor a
    ld d, a
    sla e
    rl d
    sla e
    rl d
    ld hl, $da00
    add hl, de
    ld a, [hl+]
    ld [$d008], a
    ld a, [hl+]
    ld [$d009], a
    ld a, [hl+]
    ld [$d00a], a
    ld a, [hl+]
    ld [$d00b], a
    ldh a, [$af]
    ld l, a
    ldh a, [$b0]
    ld h, a
    ldh a, [$aa]
    ld [hl+], a
    ldh a, [$ab]
    ld [hl+], a
    ld a, [$d008]
    ld [hl+], a
    ld a, [$d009]
    ld [hl+], a
    ld a, [$d00a]
    ld [hl+], a
    ld a, [$d00b]
    ld [hl+], a
    ld a, l
    ldh [$af], a
    ld a, h
    ldh [$b0], a
    ret


Call_000_08cf:
    ld de, $ddff

jr_000_08d2:
    inc de
    ld a, [de]
    ld l, a
    inc de
    ld a, [de]
    ld h, a
    and a
    jr z, jr_000_08f9

    inc de
    ld a, [de]
    ld [hl+], a
    ld a, h
    and $9b
    ld h, a
    inc de
    ld a, [de]
    ld [hl], a
    ld bc, $001f
    add hl, bc
    ld a, h
    and $9b
    ld h, a
    inc de
    ld a, [de]
    ld [hl+], a
    ld a, h
    and $9b
    ld h, a
    inc de
    ld a, [de]
    ld [hl], a
    jr jr_000_08d2

jr_000_08f9:
    xor a
    ld [$de01], a
    ret


Call_000_08fe:
    ld a, [$d00e]
    and a
    jp nz, Jump_000_0b44

    ldh a, [hCameraYScreen]
    swap a
    ld b, a
    ldh a, [hCameraXScreen]
    or b
    ld e, a
    ld d, $00
    ld hl, $4200
    add hl, de
    ld a, [hl]
    ldh [$98], a
    ldh a, [$98]
    bit 0, a
    jr z, jr_000_0949

    ldh a, [hCameraXPixel]
    cp $b0
    jp nz, Jump_000_0936

    ld a, [$d03c]
    cp $a1
    jr c, jr_000_0991

    ld a, $01
    ld [$d00e], a
    call Call_000_0c37
    jp Jump_000_0991


Jump_000_0936:
    jr c, jr_000_0949

    ldh a, [hCameraXPixel]
    sub $01
    ldh [hCameraXPixel], a
    ldh a, [hCameraXScreen]
    sbc $00
    and $0f
    ldh [hCameraXScreen], a
    jp Jump_000_0991


jr_000_0949:
    ld a, [$d035]
    and a
    jr z, jr_000_0991

    ld b, a
    ldh a, [hCameraXPixel]
    add b
    ldh [hCameraXPixel], a
    ld b, a
    ldh a, [hCameraXScreen]
    adc $00
    and $0f
    ldh [hCameraXScreen], a
    ld a, [$d023]
    set 4, a
    ld [$d023], a
    ldh a, [hSamusXPixel]
    sub b
    add $60
    cp $40
    jr c, jr_000_097f

    ldh a, [hCameraXPixel]
    add $01
    ldh [hCameraXPixel], a
    ldh a, [hCameraXScreen]
    adc $00
    and $0f
    ldh [hCameraXScreen], a
    jr jr_000_0991

jr_000_097f:
    cp $3f
    jr nc, jr_000_0991

    ldh a, [hCameraXPixel]
    sub $01
    ldh [hCameraXPixel], a
    ldh a, [hCameraXScreen]
    sbc $00
    and $0f
    ldh [hCameraXScreen], a

Jump_000_0991:
jr_000_0991:
    ldh a, [$98]
    bit 1, a
    jr z, jr_000_09cd

    ldh a, [hCameraXPixel]
    cp $50
    jr nz, jr_000_09bb

    ld a, [$d03c]
    cp $0f
    jp nc, Jump_000_0a18

    ld a, $02
    ld [$d00e], a
    ld a, $00
    ldh [hSamusXPixel], a
    ldh a, [hSamusXScreen]
    inc a
    and $0f
    ldh [hSamusXScreen], a
    call Call_000_0c37
    jp Jump_000_0a18


jr_000_09bb:
    jr nc, jr_000_09cd

    ldh a, [hCameraXPixel]
    add $01
    ldh [hCameraXPixel], a
    ldh a, [hCameraXScreen]
    adc $00
    and $0f
    ldh [hCameraXScreen], a
    jr jr_000_0a18

jr_000_09cd:
    ld a, [$d036]
    and a
    jr z, jr_000_0a18

    ld a, [$d036]
    ld b, a
    ldh a, [hCameraXPixel]
    sub b
    ldh [hCameraXPixel], a
    ld b, a
    ldh a, [hCameraXScreen]
    sbc $00
    and $0f
    ldh [hCameraXScreen], a
    ld a, [$d023]
    set 5, a
    ld [$d023], a
    ldh a, [hSamusXPixel]
    sub b
    add $60
    cp $70
    jr nc, jr_000_0a06

    ldh a, [hCameraXPixel]
    sub $01
    ldh [hCameraXPixel], a
    ldh a, [hCameraXScreen]
    sbc $00
    and $0f
    ldh [hCameraXScreen], a
    jr jr_000_0a18

jr_000_0a06:
    cp $71
    jr c, jr_000_0a18

    ldh a, [hCameraXPixel]
    add $01
    ldh [hCameraXPixel], a
    ldh a, [hCameraXScreen]
    adc $00
    and $0f
    ldh [hCameraXScreen], a

Jump_000_0a18:
jr_000_0a18:
    xor a
    ld [$d035], a
    ld [$d036], a
    ldh a, [hCameraYPixel]
    ld b, a
    ldh a, [hSamusYPixel]
    sub b
    add $60
    ldh [$99], a
    ld a, [$d00c]
    ld b, a
    ldh a, [hSamusYPixel]
    sub b
    jp z, Jump_000_0b2c

    bit 7, a
    jp nz, Jump_000_0ab6

    ld [$d038], a
    ld a, [$d023]
    set 7, a
    ld [$d023], a
    ldh a, [$98]
    bit 3, a
    jr z, jr_000_0a9d

    ld a, [$d08b]
    cp $11
    jr nz, jr_000_0a58

    ldh a, [hCameraYPixel]
    cp $a0
    jr nz, jr_000_0a71

    jr jr_000_0a5e

jr_000_0a58:
    ldh a, [hCameraYPixel]
    cp $c0
    jr nz, jr_000_0a71

jr_000_0a5e:
    ld a, [$d03b]
    cp $78
    jp c, Jump_000_0b2c

    ld a, $08
    ld [$d00e], a
    call Call_000_0c37
    jp Jump_000_0ab6


jr_000_0a71:
    jr c, jr_000_0a84

    ldh a, [hCameraYPixel]
    sub $01
    ldh [hCameraYPixel], a
    ldh a, [hCameraYScreen]
    sbc $00
    and $0f
    ldh [hCameraYScreen], a
    jp Jump_000_0b2c


jr_000_0a84:
    ldh a, [$99]
    cp $40
    jp c, Jump_000_0b2c

    ld a, [$d038]
    ld b, a
    ldh a, [hCameraYPixel]
    add b
    ldh [hCameraYPixel], a
    ldh a, [hCameraYScreen]
    adc $00
    ldh [hCameraYScreen], a
    jp Jump_000_0b2c


jr_000_0a9d:
    ldh a, [$99]
    cp $50
    jp c, Jump_000_0b2c

    ld a, [$d038]
    ld b, a
    ldh a, [hCameraYPixel]
    add b
    ldh [hCameraYPixel], a
    ldh a, [hCameraYScreen]
    adc $00
    ldh [hCameraYScreen], a
    jp Jump_000_0b2c


Jump_000_0ab6:
    cpl
    inc a
    ld [$d037], a
    ld a, [$d023]
    set 6, a
    ld [$d023], a
    ldh a, [$98]
    bit 2, a
    jr z, jr_000_0b17

    ldh a, [hCameraYPixel]
    cp $48
    jr nz, jr_000_0aee

    ld a, [$d03b]
    cp $1b
    jr nc, jr_000_0b2c

    ld a, $04
    ld [$d00e], a
    ld a, $00
    ldh [hSamusYPixel], a
    ldh a, [hCameraYScreen]
    ldh [hSamusYScreen], a
    ld a, [$d08b]
    cp $11
    call nz, Call_000_0c37
    jp Jump_000_0b2c


jr_000_0aee:
    jr nc, jr_000_0b00

    ldh a, [hCameraYPixel]
    add $01
    ldh [hCameraYPixel], a
    ldh a, [hCameraYScreen]
    adc $00
    and $0f
    ldh [hCameraYScreen], a
    jr jr_000_0b2c

jr_000_0b00:
    ldh a, [$99]
    cp $3e
    jr nc, jr_000_0b2c

    ld a, [$d037]
    ld b, a
    ldh a, [hCameraYPixel]
    sub b
    ldh [hCameraYPixel], a
    ldh a, [hCameraYScreen]
    sbc $00
    ldh [hCameraYScreen], a
    jr jr_000_0b2c

jr_000_0b17:
    ldh a, [$99]
    cp $4e
    jr nc, jr_000_0b2c

    ld a, [$d037]
    ld b, a
    ldh a, [hCameraYPixel]
    sub b
    ldh [hCameraYPixel], a
    ldh a, [hCameraYScreen]
    sbc $00
    ldh [hCameraYScreen], a

Jump_000_0b2c:
jr_000_0b2c:
    xor a
    ld [$d038], a
    ld [$d037], a
    ldh a, [hSamusYPixel]
    ld [$d00c], a
    ret


    nop
    ld bc, $0001
    nop
    nop
    ld bc, $0202
    db $01
    db $01

Jump_000_0b44:
    ld a, [$d072]
    inc a
    ld [$d072], a
    ld a, [$d00e]
    bit 0, a
    jr z, jr_000_0b82

    ldh a, [hCameraXPixel]
    add $04
    ldh [hCameraXPixel], a
    ldh a, [hCameraXScreen]
    adc $00
    and $0f
    ldh [hCameraXScreen], a
    ld a, [$d022]
    inc a
    inc a
    inc a
    ld [$d022], a
    ld a, $10
    ld [$d023], a
    ldh a, [hSamusXPixel]
    add $01
    ldh [hSamusXPixel], a
    ldh a, [hSamusXScreen]
    adc $00
    ldh [hSamusXScreen], a
    ldh a, [hCameraXPixel]
    cp $50
    ret nz

    jp Jump_000_0c24


jr_000_0b82:
    bit 1, a
    jr z, jr_000_0bb5

    ldh a, [hCameraXPixel]
    sub $04
    ldh [hCameraXPixel], a
    ldh a, [hCameraXScreen]
    sbc $00
    and $0f
    ldh [hCameraXScreen], a
    ld a, [$d022]
    inc a
    inc a
    inc a
    ld [$d022], a
    ld a, $20
    ld [$d023], a
    ldh a, [hSamusXPixel]
    sub $01
    ldh [hSamusXPixel], a
    ldh a, [hSamusXScreen]
    sbc $00
    ldh [hSamusXScreen], a
    ldh a, [hCameraXPixel]
    cp $b0
    ret nz

    jr jr_000_0c24

jr_000_0bb5:
    bit 2, a
    jr z, jr_000_0bee

    ldh a, [hCameraYPixel]
    sub $04
    ldh [hCameraYPixel], a
    ldh a, [hCameraYScreen]
    sbc $00
    and $0f
    ldh [hCameraYScreen], a
    ld a, [$d022]
    inc a
    inc a
    inc a
    ld [$d022], a
    ld a, $40
    ld [$d023], a
    ldh a, [$97]
    and $01
    add $01
    ld b, a
    ldh a, [hSamusYPixel]
    sub b
    ldh [hSamusYPixel], a
    ldh a, [hSamusYScreen]
    sbc $00
    ldh [hSamusYScreen], a
    ldh a, [hCameraYPixel]
    cp $b8
    ret nz

    jr jr_000_0c24

jr_000_0bee:
    bit 3, a
    ret z

    ldh a, [hCameraYPixel]
    add $04
    ldh [hCameraYPixel], a
    ldh a, [hCameraYScreen]
    adc $00
    and $0f
    ldh [hCameraYScreen], a
    ld a, [$d022]
    inc a
    inc a
    inc a
    ld [$d022], a
    ld a, $80
    ld [$d023], a
    ldh a, [$97]
    and $01
    add $01
    ld b, a
    ldh a, [hSamusYPixel]
    add b
    ldh [hSamusYPixel], a
    ldh a, [hSamusYScreen]
    adc $00
    ldh [hSamusYScreen], a
    ldh a, [hCameraYPixel]
    cp $48
    ret nz

Jump_000_0c24:
jr_000_0c24:
    xor a
    ld [$d00e], a
    ld [$c463], a
    ld a, [$d07e]
    cp $93
    ret z

    ld a, $2f
    ld [$d09b], a
    ret


Call_000_0c37:
    ld a, [$d08b]
    cp $11
    jr nz, jr_000_0c4e

    ld a, [samusPose]
    cp $0b
    jr c, jr_000_0c4e

    cp $0f
    jr nc, jr_000_0c4e

    ld a, $05
    ld [samusPose], a

jr_000_0c4e:
    xor a
    ld [$c422], a
    ld [$d07d], a
    ld a, $ff
    ld hl, $dd30
    ld [hl], a
    ld hl, $dd40
    ld [hl], a
    ld hl, $dd50
    ld [hl], a
    ld [$d09e], a
    ldh a, [hCameraYScreen]
    swap a
    ld e, a
    ldh a, [hCameraXScreen]
    add e
    ld e, a
    ld d, $00
    sla e
    rl d
    ld hl, $4300
    add hl, de
    ld a, [hl+]
    ld [$d08e], a
    ld a, [hl]
    res 3, a
    ld [$d08f], a
    ld a, $02
    ld [$c458], a
    xor a
    ld [$d09b], a
    ld a, [$d0a0]
    and a
    ret z

    ; Check if either A or Start is pressed
    ldh a, [hInputPressed]
    and PADF_START | PADF_SELECT | PADF_B | PADF_A ;$0f
    cp PADF_SELECT | PADF_B ;$06
    ret nz

    ld a, $9d
    ld [$d08e], a
    ld a, $01
    ld [$d08f], a
    ret


Call_000_0ca3:
    call Call_000_21ef
    
    ld a, [saveBuf_samusXPixel]
    ldh [hSamusXPixel], a
    
    ld a, [saveBuf_samusYPixel]
    ldh [hSamusYPixel], a
    ld [$d00c], a
    
    ld a, [saveBuf_samusXScreen]
    ldh [hSamusXScreen], a
    
    ld a, [saveBuf_samusYScreen]
    ldh [hSamusYScreen], a
    
    xor a
    ld [$d04f], a
    
    ld a, [$d815]
    ld [samusItems], a
    
    ld a, [$d816]
    ld [$d04d], a
    ld [$d055], a
    
    ld a, [$d81e]
    ld [$d02b], a
    
    ld a, [$d817]
    ld [$d050], a
    
    ld a, [$d818]
    ld [$d051], a
    ld [$d084], a
    
    ld a, [$d819]
    ld [$d052], a
    ld [$d085], a
    
    ld a, [$d81a]
    ld [$d081], a
    
    ld a, [$d81b]
    ld [$d082], a
    
    ld a, [$d81c]
    ld [$d053], a
    ld [$d086], a
    
    ld a, [$d81d]
    ld [$d054], a
    ld [$d087], a
    
    ld a, $13
    ld [samusPose], a
    ld a, $40
    ld [countdownTimerLow], a
    ld a, $01
    ld [countdownTimerHigh], a
    ld a, $12
    ld [$cedc], a
    ret


Call_000_0d21:
Jump_000_0d21:
    xor a
    ld [$d048], a
    ld [$d062], a
    ld a, [$d072]
    inc a
    ld [$d072], a
    ld a, [$d063]
    and a
    jr z, jr_000_0d3a

    xor a
    ldh [hInputRisingEdge], a
    ldh [hInputPressed], a

jr_000_0d3a:
    ld a, [$d00e]
    and a
    ret nz

    ld a, [samusPose]
    bit 7, a
    jp nz, Jump_000_139d

    ld a, [samusPose]
    rst $28
        dw $13B7
        dw $17BB
        dw $18E8
        dw $14D6
        dw $15F4
        dw $1701
        dw $179F
        dw $12F5
        dw $124B
        dw $19E2
        dw $19E2
        dw $1083
        dw $11E4
        dw $1170
        dw $1029
        dw $0EF7
        dw $0F38
        dw $0F6C
        dw $0ECB
        dw $0EA5
        dw $0EA5
        dw $0EA5
        dw $0EA5
        dw $0EA5
        dw $0E36
        dw $0DF0
        dw $0DBE
        dw $0D87
        dw $0D8B
        dw $0ECB


    call Call_000_2f29
    ret


    call Call_000_2f29
    ldh a, [hSamusXPixel]
    cp $b0
    jr z, jr_000_0dae

    add $02
    ldh [hSamusXPixel], a
    cp $80
    jr nc, jr_000_0da4

    ldh a, [hSamusYPixel]
    sub $02
    ldh [hSamusYPixel], a
    jr jr_000_0dad

jr_000_0da4:
    cp $98
    jr c, jr_000_0dad

    ldh a, [hSamusYPixel]
    dec a
    ldh [hSamusYPixel], a

jr_000_0dad:
    ret


jr_000_0dae:
    ld a, $40
    ld [$d026], a
    ld a, $01
    ld [$d00f], a
    ld a, $1d
    ld [samusPose], a
    ret


    call Call_000_2f29
    ldh a, [hSamusXPixel]
    cp $68
    jr z, jr_000_0dea

    ld a, [$c3a8]
    add $06
    ld b, a
    ld a, [$c206]
    add b
    ld b, a
    ldh a, [hSamusXPixel]
    cp b
    jr c, jr_000_0ddc

    ldh a, [hSamusYPixel]
    dec a
    ldh [hSamusYPixel], a

jr_000_0ddc:
    ldh a, [hSamusXPixel]
    dec a
    ldh [hSamusXPixel], a
    cp $80
    ret nc

    ldh a, [hSamusYPixel]
    inc a
    ldh [hSamusYPixel], a
    ret


jr_000_0dea:
    ld a, $1b
    ld [samusPose], a
    ret


    ld a, $6c
    ldh [hSamusYPixel], a
    ld a, $a6
    ldh [hSamusXPixel], a
    call Call_000_2f29
    ld a, [$d090]
    cp $05
    jr nz, jr_000_0e12

    ld a, $01
    ld [$d00f], a
    ld a, $50
    ld [$d026], a
    ld a, $1d
    ld [samusPose], a
    ret


jr_000_0e12:
    cp $20
    jr nz, jr_000_0e26

    ld a, $40
    ld [$d026], a
    ld a, $01
    ld [$d00f], a
    ld a, $1d
    ld [samusPose], a
    ret


jr_000_0e26:
    ldh a, [hInputRisingEdge]
    bit PADB_LEFT, a
    ret z

    ld a, $1a
    ld [samusPose], a
    ld a, $06
    ld [$d090], a
    ret


    call Call_000_2f29
    ld a, [$d090]
    cp $03
    jr nz, jr_000_0e46

    ld a, $19
    ld [samusPose], a
    ret


jr_000_0e46:
    ld c, $00
    ld a, [$c3a9]
    add $13
    ld b, a
    ld a, [$d03b]
    cp b
    jr nz, jr_000_0e58

    ld c, $01
    jr jr_000_0e72

jr_000_0e58:
    jr c, jr_000_0e67

    ldh a, [hSamusYPixel]
    sub $01
    ldh [hSamusYPixel], a
    ld a, $01
    ld [$d037], a
    jr jr_000_0e72

jr_000_0e67:
    ldh a, [hSamusYPixel]
    add $01
    ldh [hSamusYPixel], a
    ld a, $01
    ld [$d038], a

jr_000_0e72:
    ld a, [$c3a8]
    add $1a
    ld b, a
    ld a, [$d03c]
    cp b
    jr nz, jr_000_0e81

    inc c
    jr z, jr_000_0e9b

jr_000_0e81:
    jr c, jr_000_0e90

    ldh a, [hSamusXPixel]
    sub $02
    ldh [hSamusXPixel], a
    ld a, $01
    ld [$d036], a
    jr jr_000_0e9b

jr_000_0e90:
    ldh a, [hSamusXPixel]
    add $01
    ldh [hSamusXPixel], a
    ld a, $01
    ld [$d035], a

jr_000_0e9b:
    ld a, c
    cp $02
    ret nz

    ld a, $02
    ld [$d090], a
    ret


    ld a, [countdownTimerLow]
    and a
    ret nz

    ld a, [countdownTimerHigh]
    and a
    ret nz

    ld a, [$cedd]
    ld b, a
    ld a, [$d092]
    cp b
    jr z, jr_000_0ebc

    ld [$cedc], a

jr_000_0ebc:
    ld a, [$d079]
    and a
    jr nz, jr_000_0ec6

    ldh a, [hInputPressed]
    and a
    ret z

jr_000_0ec6:
    xor a
    ld [samusPose], a
    ret


    ldh a, [hInputRisingEdge]
    bit PADB_DOWN, a
    jr z, jr_000_0ee7

    ld a, [samusItems]
    bit itemBit_spider, a
    jr z, jr_000_0ee7

    ld a, $0c
    ld [samusPose], a
    xor a
    ld [$d044], a
    ld a, $0d
    ld [$cec0], a
    ret


jr_000_0ee7:
    ldh a, [hInputRisingEdge]
    bit PADB_UP, a
    jr z, jr_000_0f6c

    call Call_000_1bb3
    ld a, $10
    ld [$d049], a
    jr jr_000_0f6c

    ldh a, [hInputRisingEdge]
    bit 0, a
    jr z, jr_000_0f6c

    call Call_000_1e88
    ret c

    xor a
    ld [$d04f], a
    ld a, $21
    ld [$d026], a
    ld a, $02
    ld [$cec0], a
    ld a, [samusItems]
    bit itemBit_hiJump, a
    jr nz, jr_000_0f20

    ld a, $31
    ld [$d026], a
    ld a, $01
    ld [$cec0], a

jr_000_0f20:
    ld a, [$d048]
    and a
    jr z, jr_000_0f2e

    ld a, [$d026]
    add $10
    ld [$d026], a

jr_000_0f2e:
    ld a, $09
    ld [samusPose], a
    xor a
    ld [$d010], a
    ret


    ldh a, [hInputRisingEdge]
    bit PADB_UP, a
    jp z, Jump_000_0f47

    call Call_000_1bb3
    ld a, $10
    ld [$d049], a

Jump_000_0f47:
    ld a, [samusItems]
    bit itemBit_spring, a
    jr z, jr_000_0f6c

    ldh a, [hInputRisingEdge]
    bit PADB_A, a
    jr z, jr_000_0f6c

    xor a
    ld [$d04f], a
    ld a, $2e
    ld [$d026], a
    ld a, $06
    ld [samusPose], a
    xor a
    ld [$d010], a
    ld a, $01
    ld [$cec0], a
    ret


jr_000_0f6c:
    ld a, [$d026]
    sub $40
    ld e, a
    ld d, $00
    ld hl, $0ff6
    add hl, de
    ld a, [hl]
    cp $80
    jr nz, jr_000_0f7f

    jr jr_000_0fc0

jr_000_0f7f:
    call Call_000_1d4e
    jr nc, jr_000_0f8b

    ld a, [$d026]
    cp $57
    jr nc, jr_000_0fc0

jr_000_0f8b:
    ld a, [$d026]
    inc a
    ld [$d026], a
    cp $56
    jr c, jr_000_0fac

    ldh a, [hInputPressed]
    bit PADB_RIGHT, a
    jr z, jr_000_0fa1

    ld a, $01
    ld [$d00f], a

jr_000_0fa1:
    ldh a, [hInputPressed]
    bit PADB_LEFT, a
    jr z, jr_000_0fac

    ld a, $ff
    ld [$d00f], a

jr_000_0fac:
    ld a, [$d00f]
    cp $01
    jr nz, jr_000_0fb6

    call Call_000_1cfa

jr_000_0fb6:
    ld a, [$d00f]
    cp $ff
    ret nz

    call Call_000_1d26
    ret


jr_000_0fc0:
    xor a
    ld [$d026], a
    ld a, $16
    ld [$d024], a
    ld a, [samusPose]
    ld e, a
    ld d, $00
    ld hl, $0fd8
    add hl, de
    ld a, [hl]
    ld [samusPose], a
    ret


    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

    db $07, $08, $07, $08

    nop
    nop
    nop
    nop
    nop
    jr @+$1b

    ld a, [de]
    dec de
    inc e
    db $08

    db $fd, $fd, $fd, $fd, $fe, $fd, $fe, $fd, $fe, $fe, $fe, $fe, $fe, $fe, $ff, $fe
    db $fe, $ff, $fe, $ff, $fe, $ff, $ff, $00, $00, $00, $00, $01, $01, $02, $01, $02
    db $01, $02, $02, $01, $02, $02, $02, $02, $02, $02, $03, $02, $03, $02, $03, $03
    db $03, $03, $80

    ldh a, [hInputRisingEdge]
    bit PADB_A, a
    jr z, jr_000_103a

    ld a, $05
    ld [samusPose], a
    ld a, $06
    ld [$cec0], a
    ret


jr_000_103a:
    call Call_000_1a42
    ld a, [$d03d]
    and a
    jr nz, jr_000_104d

    ld a, $0c
    ld [samusPose], a
    ld a, $01
    ld [$d024], a

jr_000_104d:
    ldh a, [hInputRisingEdge]
    and PADF_DOWN | PADF_UP | PADF_LEFT | PADF_RIGHT ;$f0
    ret z

    call Call_000_1a42
    ldh a, [hInputRisingEdge]
    and PADF_DOWN | PADF_UP | PADF_LEFT | PADF_RIGHT ;$f0
    swap a
    jr z, jr_000_107d

    ld b, a
    ld a, [$d03d]
    swap a
    add b
    ld e, a
    ld d, $00
    ld a, $06
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld hl, spiderBallTable ; 06:7E03
    add hl, de
    ld a, [hl]
    ld [$d044], a
    ld a, $0b
    ld [samusPose], a
    ret


jr_000_107d:
    ld a, $0c
    ld [samusPose], a
    ret


    ldh a, [hInputRisingEdge]
    bit PADB_A, a
    jr z, jr_000_1094

    ld a, $05
    ld [samusPose], a
    ld a, $06
    ld [$cec0], a
    ret


jr_000_1094:
    ldh a, [hInputPressed]
    and PADF_DOWN | PADF_UP | PADF_LEFT | PADF_RIGHT ;$f0
    jr nz, jr_000_10a4

    ld a, $0e
    ld [samusPose], a
    xor a
    ld [$d044], a
    ret


jr_000_10a4:
    call Call_000_1a42
    ld a, [$d03d]
    and a
    jr z, jr_000_107d

    ld e, a
    ld d, $00
    ld a, [$d044]
    bit 0, a
    jr z, jr_000_10bc

    ld hl, $20a9
    jr jr_000_10c2

jr_000_10bc:
    bit 1, a
    ret z

    ld hl, $20c9

jr_000_10c2:
    add hl, de
    ld a, [hl]
    ld [$d042], a
    xor a
    ld [$d043], a
    ld a, [$d042]
    bit 0, a
    call nz, Call_000_1132
    ld a, [$d042]
    bit 1, a
    call nz, Call_000_113c
    ld a, [$d042]
    bit 2, a
    call nz, Call_000_1146
    ld a, [$d042]
    bit 3, a
    call nz, Call_000_1152
    ld a, [$d043]
    and a
    ret nz

    ld a, [$d03d]
    ld e, a
    ld d, $00
    ld a, [$d044]
    bit 0, a
    jr z, jr_000_1102

    ld hl, $20b9
    jr jr_000_1108

jr_000_1102:
    bit 1, a
    ret z

    ld hl, $20d9

jr_000_1108:
    add hl, de
    ld a, [hl]
    ld [$d042], a
    xor a
    ld [$d043], a
    ld a, [$d042]
    bit 0, a
    call nz, Call_000_1132
    ld a, [$d042]
    bit 1, a
    call nz, Call_000_113c
    ld a, [$d042]
    bit 2, a
    call nz, Call_000_1146
    ld a, [$d042]
    bit 3, a
    call nz, Call_000_1152
    ret


Call_000_1132:
    call Call_000_1c94
    ld a, [$d035]
    ld [$d043], a
    ret


Call_000_113c:
    call Call_000_1cc5
    ld a, [$d036]
    ld [$d043], a
    ret


Call_000_1146:
    ld a, $01
    call Call_000_1d98
    ld a, [$d037]
    ld [$d043], a
    ret


Call_000_1152:
    ld a, $01
    call Call_000_1d4e
    ld a, [$d038]
    ld [$d043], a
    ret nc

    ld a, [$c43a]
    and a
    ret nz

    ldh a, [hSamusYPixel]
    and $f8
    or $04
    ldh [hSamusYPixel], a
    xor a
    ld [$d043], a
    ret


    ldh a, [hInputRisingEdge]
    bit PADB_A, a
    jr z, jr_000_1181

    ld a, $06
    ld [samusPose], a
    ld a, $06
    ld [$cec0], a
    ret


jr_000_1181:
    ld a, [$d026]
    cp $40
    jr nc, jr_000_1197

    ldh a, [hInputPressed]
    bit PADB_A, a
    jr z, jr_000_1192

    ld a, $fe
    jr jr_000_11a5

jr_000_1192:
    ld a, $56
    ld [$d026], a

jr_000_1197:
    sub $40
    ld hl, $184a
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    cp $80
    jr z, jr_000_11d1

jr_000_11a5:
    call Call_000_1d4e
    jp c, Jump_000_1233

    call Call_000_1a42
    ld a, [$d03d]
    and a
    jp nz, Jump_000_1241

    ld a, [$d026]
    inc a
    ld [$d026], a
    ldh a, [hInputPressed]
    bit PADB_RIGHT, a
    jr z, jr_000_11c6

    call Call_000_1132
    ret


jr_000_11c6:
    ldh a, [hInputPressed]
    bit PADB_LEFT, a
    jr z, jr_000_11d0

    call Call_000_1cc9
    ret


jr_000_11d0:
    ret


jr_000_11d1:
    xor a
    ld [$184a], a
    ld a, $16
    ld [$d024], a
    ld a, $0c
    ld [samusPose], a
    xor a
    ld [$d044], a
    ret


    ldh a, [hInputRisingEdge]
    bit PADB_A, a
    jr z, jr_000_11f5

    ld a, $08
    ld [samusPose], a
    ld a, $06
    ld [$cec0], a
    ret


jr_000_11f5:
    ldh a, [hInputPressed]
    bit PADB_RIGHT, a
    jr z, jr_000_1200

    call Call_000_1132
    jr jr_000_1209

jr_000_1200:
    ldh a, [hInputPressed]
    bit PADB_LEFT, a
    jr z, jr_000_1209

    call Call_000_113c

jr_000_1209:
    ld hl, $1386
    ld a, [$d024]
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    call Call_000_1d4e
    jr c, jr_000_1233

    call Call_000_1a42
    ld a, [$d03d]
    and a
    jr nz, jr_000_1241

    ld a, [$d024]
    inc a
    ld [$d024], a
    cp $17
    jr c, jr_000_1232

    ld a, $16
    ld [$d024], a

jr_000_1232:
    ret


Jump_000_1233:
jr_000_1233:
    ld a, [$c43a]
    and a
    jr nz, jr_000_1241

    ldh a, [hSamusYPixel]
    and $f8
    or $04
    ldh [hSamusYPixel], a

Jump_000_1241:
jr_000_1241:
    ld a, $0b
    ld [samusPose], a
    xor a
    ld [$d024], a
    ret


    ldh a, [hInputRisingEdge]
    bit PADB_DOWN, a
    jr z, jr_000_1267

    ld a, [samusItems]
    bit itemBit_spider, a
    jr z, jr_000_1267

    ld a, $0c
    ld [samusPose], a
    xor a
    ld [$d044], a
    ld a, $0d
    ld [$cec0], a
    ret


jr_000_1267:
    ldh a, [hInputRisingEdge]
    bit PADB_A, a
    jr z, jr_000_1285

    ld a, [$d062]
    and a
    jr z, jr_000_1285

    ld [$d026], a
    ld a, $06
    ld [samusPose], a
    xor a
    ld [$d010], a
    ld a, $01
    ld [$cec0], a
    ret


jr_000_1285:
    ldh a, [hInputRisingEdge]
    bit PADB_UP, a
    jr z, jr_000_1295

    call Call_000_1bb3
    ld a, $10
    ld [$d049], a
    jr jr_000_12dd

jr_000_1295:
    ldh a, [hInputPressed]
    bit PADB_RIGHT, a
    jr z, jr_000_12aa

    call Call_000_1cf5
    ld a, [samusItems]
    bit itemBit_spider, a
    jr z, jr_000_12aa

    ld a, [$d035]
    jr jr_000_12bd

jr_000_12aa:
    ldh a, [hInputPressed]
    bit PADB_LEFT, a
    jr z, jr_000_12bd

    call Call_000_1d22
    ld a, [samusItems]
    bit itemBit_spider, a
    jr z, jr_000_12bd

    ld a, [$d036]

jr_000_12bd:
    ld hl, $1386
    ld a, [$d024]
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    call Call_000_1d4e
    jr c, jr_000_12de

    ld a, [$d024]
    inc a
    ld [$d024], a
    cp $17
    jr c, jr_000_12dd

    ld a, $16
    ld [$d024], a

jr_000_12dd:
    ret


jr_000_12de:
    ld a, $05
    ld [samusPose], a
    xor a
    ld [$d024], a
    ld a, [$c43a]
    and a
    ret nz

    ldh a, [hSamusYPixel]
    and $f8
    or $04
    ldh [hSamusYPixel], a
    ret


    ldh a, [hInputRisingEdge]
    bit PADB_A, a
    jr z, jr_000_1335

    ld a, [$d062]
    and a
    jr z, jr_000_1306

    ld [$d026], a
    jr jr_000_1311

jr_000_1306:
    ld a, [$d049]
    and a
    jr z, jr_000_1335

    ld a, $21
    ld [$d026], a

jr_000_1311:
    ld a, $02
    ld [$cec0], a
    ld a, [samusItems]
    bit itemBit_hiJump, a
    jr nz, jr_000_1327

    ld a, $31
    ld [$d026], a
    ld a, $01
    ld [$cec0], a

jr_000_1327:
    ld a, $09
    ld [samusPose], a
    xor a
    ld [$d010], a
    xor a
    ld [$d049], a
    ret


jr_000_1335:
    ldh a, [hInputPressed]
    bit PADB_RIGHT, a
    jr z, jr_000_1340

    call Call_000_1cf5
    jr jr_000_1349

jr_000_1340:
    ldh a, [hInputPressed]
    bit PADB_LEFT, a
    jr z, jr_000_1349

    call Call_000_1d22

jr_000_1349:
    ld hl, $1386
    ld a, [$d024]
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    call Call_000_1d4e
    jr c, jr_000_136a

    ld a, [$d024]
    inc a
    ld [$d024], a
    cp $17
    jr c, jr_000_1369

    ld a, $16
    ld [$d024], a

jr_000_1369:
    ret


jr_000_136a:
    call Call_000_1b37
    jr nc, jr_000_1374

    ld a, $04
    ld [samusPose], a

jr_000_1374:
    xor a
    ld [$d024], a
    ld a, [$c43a]
    and a
    ret nz

    ldh a, [hSamusYPixel]
    and $f8
    or $04
    ldh [hSamusYPixel], a
    ret


    db $01, $01, $01, $01, $00, $01, $01, $00, $01, $01, $01, $01, $01, $01, $02, $01
    db $02, $02, $01, $02, $02, $02, $03

Jump_000_139d:
    call Call_000_1f0f
    ldh a, [hInputRisingEdge]
    bit PADB_A, a
    jp nz, Jump_000_13ac

    ld hl, $d02c
    dec [hl]
    ret nz

Jump_000_13ac:
    ld a, [samusPose]
    res 7, a
    ld [samusPose], a
    jp Jump_000_0d21


    call Call_000_1f0f
    jr c, jr_000_13c7

    ld a, $07
    ld [samusPose], a
    ld a, $01
    ld [$d024], a
    ret


jr_000_13c7:
    xor a
    ld [$d022], a
    ldh a, [hInputRisingEdge]
    bit PADB_A, a
    jr z, jr_000_1421

    ldh a, [hInputPressed]
    and PADF_LEFT | PADF_RIGHT ;$30
    jr z, jr_000_1421

    ld a, [samusItems]
    bit itemBit_space, a
    jp z, Jump_000_149e

    call Call_000_1e88
    ret c

    ld a, $21
    ld [$d026], a
    ld a, $02
    ld [$cec0], a
    ld a, [samusItems]
    bit itemBit_hiJump, a
    jr nz, jr_000_13fe

    ld a, $31
    ld [$d026], a
    ld a, $01
    ld [$cec0], a

jr_000_13fe:
    ld a, [$d048]
    and a
    jr z, jr_000_140c

    ld a, [$d026]
    add $10
    ld [$d026], a

jr_000_140c:
    ld a, $0a
    ld [samusPose], a
    xor a
    ld [$d010], a
    ld a, [samusItems]
    bit itemBit_screw, a
    ret z

    ld a, $03
    ld [$cec0], a
    ret


jr_000_1421:
    ldh a, [hInputPressed]
    bit PADB_RIGHT, a
    jr z, jr_000_1452

    ld a, [$d02b]
    cp $01
    jr z, jr_000_1443

    ld a, $83
    ld [samusPose], a
    ld a, $01
    ld [$d02b], a
    ld a, $02
    ld [$d02c], a
    ld a, $04
    ld [$cec0], a
    ret


jr_000_1443:
    call Call_000_1c0d
    ret c

    ld a, $01
    ld [$d02b], a
    ld a, $03
    ld [samusPose], a
    ret


jr_000_1452:
    ldh a, [hInputPressed]
    bit PADB_LEFT, a
    jr z, jr_000_1483

    ld a, [$d02b]
    cp $00
    jr z, jr_000_1474

    ld a, $83
    ld [samusPose], a
    ld a, $00
    ld [$d02b], a
    ld a, $02
    ld [$d02c], a
    ld a, $04
    ld [$cec0], a
    ret


jr_000_1474:
    call Call_000_1c51
    ret c

    ld a, $00
    ld [$d02b], a
    ld a, $03
    ld [samusPose], a
    ret


jr_000_1483:
    ldh a, [hInputRisingEdge]
    bit PADB_DOWN, a
    jr z, jr_000_1498

    xor a
    ld [$d022], a
    ld a, $04
    ld [samusPose], a
    ld a, $05
    ld [$cec0], a
    ret


jr_000_1498:
    ldh a, [hInputRisingEdge]
    bit PADB_A, a
    jr z, jr_000_14d5

Jump_000_149e:
    call Call_000_1e88
    ret c

    ld a, $21
    ld [$d026], a
    ld a, $02
    ld [$cec0], a
    ld a, [samusItems]
    bit itemBit_hiJump, a
    jr nz, jr_000_14bd

    ld a, $31
    ld [$d026], a
    ld a, $01
    ld [$cec0], a

jr_000_14bd:
    ld a, [$d048]
    and a
    jr z, jr_000_14cb

    ld a, [$d026]
    add $10
    ld [$d026], a

jr_000_14cb:
    ld a, $09
    ld [samusPose], a
    xor a
    ld [$d010], a
    ret


jr_000_14d5:
    ret


    call Call_000_1f0f
    jr c, jr_000_14e6

    ld a, $07
    ld [samusPose], a
    ld a, $01
    ld [$d024], a
    ret


jr_000_14e6:
    ld hl, $d022
    inc [hl]
    inc [hl]
    inc [hl]
    ldh a, [hInputRisingEdge]
    bit PADB_A, a
    jr z, jr_000_153b

    ldh a, [hInputPressed]
    and PADF_LEFT | PADF_RIGHT ;$30
    jr z, jr_000_153b

    call Call_000_1e88
    ret c

    ld a, $21
    ld [$d026], a
    ld a, [samusItems]
    and itemMask_hiJump
    srl a
    inc a
    ld [$cec0], a
    ld a, [samusItems]
    bit itemBit_hiJump, a
    jr nz, jr_000_1518

    ld a, $31
    ld [$d026], a

jr_000_1518:
    ld a, [$d048]
    and a
    jr z, jr_000_1526

    ld a, [$d026]
    add $10
    ld [$d026], a

jr_000_1526:
    ld a, $0a
    ld [samusPose], a
    xor a
    ld [$d010], a
    ld a, [samusItems]
    bit itemBit_screw, a
    ret z

    ld a, $03
    ld [$cec0], a
    ret


jr_000_153b:
    ldh a, [hInputPressed]
    bit PADB_RIGHT, a
    jr z, jr_000_1566

    ld a, [$d02b]
    cp $01
    jr z, jr_000_155d

    ld a, $83
    ld [samusPose], a
    ld a, $01
    ld [$d02b], a
    ld a, $02
    ld [$d02c], a
    ld a, $04
    ld [$cec0], a
    ret


jr_000_155d:
    call Call_000_1c0d
    ret nc

    xor a
    ld [samusPose], a
    ret


jr_000_1566:
    ldh a, [hInputPressed]
    bit PADB_LEFT, a
    jr z, jr_000_1591

    ld a, [$d02b]
    cp $00
    jr z, jr_000_1588

    ld a, $83
    ld [samusPose], a
    ld a, $00
    ld [$d02b], a
    ld a, $02
    ld [$d02c], a
    ld a, $04
    ld [$cec0], a
    ret


jr_000_1588:
    call Call_000_1c51
    ret nc

    xor a
    ld [samusPose], a
    ret


jr_000_1591:
    xor a
    ld [samusPose], a
    ldh a, [hInputRisingEdge]
    bit PADB_DOWN, a
    jr z, jr_000_15aa

    xor a
    ld [$d022], a
    ld a, $04
    ld [samusPose], a
    ld a, $05
    ld [$cec0], a
    ret


jr_000_15aa:
    ldh a, [hInputRisingEdge]
    bit PADB_A, a
    jr z, jr_000_15f3

    ldh a, [hSamusYPixel]
    sub $08
    ldh [hSamusYPixel], a
    call Call_000_1e88
    ret c

    ld a, $21
    ld [$d026], a
    ld a, [samusItems]
    bit itemBit_hiJump, a
    jr nz, jr_000_15cb

    ld a, $31
    ld [$d026], a

jr_000_15cb:
    ld a, $09
    ld [samusPose], a
    xor a
    ld [$d010], a
    ld a, $02
    ld [$cec0], a
    ld a, [samusItems]
    bit itemBit_hiJump, a
    jr nz, jr_000_15e5

    ld a, $01
    ld [$cec0], a

jr_000_15e5:
    ld a, [$d048]
    and a
    jr z, jr_000_15f3

    ld a, [$d026]
    add $10
    ld [$d026], a

jr_000_15f3:
    ret


    call Call_000_1f0f
    jr c, jr_000_1604

    ld a, $07
    ld [samusPose], a
    ld a, $01
    ld [$d024], a
    ret


jr_000_1604:
    ldh a, [hInputPressed]
    bit PADB_RIGHT, a
    jr z, jr_000_163b

    ld a, [$d022]
    inc a
    ld [$d022], a
    cp $08
    jr nc, jr_000_161b

    ldh a, [hInputRisingEdge]
    bit PADB_RIGHT, a
    jr z, jr_000_163b

jr_000_161b:
    xor a
    ld [$d022], a
    ld a, [$d02b]
    cp $01
    jr nz, jr_000_1635

    call Call_000_1b37
    ret nc

    ld a, $05
    ld [samusPose], a
    ld a, $06
    ld [$cec0], a
    ret


jr_000_1635:
    ld a, $01
    ld [$d02b], a
    ret


jr_000_163b:
    ldh a, [hInputPressed]
    bit PADB_LEFT, a
    jr z, jr_000_1671

    ld a, [$d022]
    inc a
    ld [$d022], a
    cp $08
    jr nc, jr_000_1652

    ldh a, [hInputRisingEdge]
    bit PADB_LEFT, a
    jr z, jr_000_1671

jr_000_1652:
    xor a
    ld [$d022], a
    ld a, [$d02b]
    and a
    jr nz, jr_000_166b

    call Call_000_1b37
    ret nc

    ld a, $05
    ld [samusPose], a
    ld a, $06
    ld [$cec0], a
    ret


jr_000_166b:
    ld a, $00
    ld [$d02b], a
    ret


jr_000_1671:
    ldh a, [hInputRisingEdge]
    bit PADB_A, a
    jr z, jr_000_16c4

    ld a, [samusItems]
    and itemMask_hiJump
    srl a
    inc a
    ld [$cec0], a
    ldh a, [hInputPressed]
    and PADF_LEFT | PADF_RIGHT ;$30
    jr z, jr_000_169b

    ld a, $02
    ld [samusPose], a
    ld a, [samusItems]
    bit itemBit_screw, a
    jr z, jr_000_16a0

    ld a, $03
    ld [$cec0], a
    jr jr_000_16a0

jr_000_169b:
    ld a, $01
    ld [samusPose], a

jr_000_16a0:
    ld a, $21
    ld [$d026], a
    ld a, [samusItems]
    bit itemBit_hiJump, a
    jr nz, jr_000_16b1

    ld a, $31
    ld [$d026], a

jr_000_16b1:
    ld a, [$d048]
    and a
    jr z, jr_000_16bf

    ld a, [$d026]
    add $10
    ld [$d026], a

jr_000_16bf:
    xor a
    ld [$d010], a
    ret


jr_000_16c4:
    ldh a, [hInputRisingEdge]
    bit PADB_DOWN, a
    jr z, jr_000_16ce

    call Call_000_1ba4
    ret


jr_000_16ce:
    ldh a, [hInputPressed]
    bit PADB_DOWN, a
    jr z, jr_000_16e2

    ld a, [$d022]
    inc a
    ld [$d022], a
    cp $10
    ret c

    call Call_000_1ba4
    ret


jr_000_16e2:
    ldh a, [hInputRisingEdge]
    bit PADB_UP, a
    jr z, jr_000_16ec

    call Call_000_1b37
    ret


jr_000_16ec:
    ldh a, [hInputPressed]
    bit PADB_UP, a
    jr z, jr_000_1700

    ld a, [$d022]
    inc a
    ld [$d022], a
    cp $10
    ret c

    call Call_000_1b37
    ret


jr_000_1700:
    ret


    call Call_000_1f0f
    jr c, jr_000_1711

    ld a, $08
    ld [samusPose], a
    ld a, $01
    ld [$d024], a
    ret


jr_000_1711:
    ldh a, [hInputRisingEdge]
    bit PADB_DOWN, a
    jr nz, jr_000_1785

    ldh a, [hInputRisingEdge]
    bit PADB_UP, a
    jr z, jr_000_1721

    call Call_000_1b2e
    ret


jr_000_1721:
    ldh a, [hInputPressed]
    bit PADB_A, a
    jr z, jr_000_1742

    ld a, [samusItems]
    bit itemBit_spring, a
    jr z, jr_000_1742

    ld a, $2e
    ld [$d026], a
    ld a, $06
    ld [samusPose], a
    xor a
    ld [$d010], a
    ld a, $01
    ld [$cec0], a
    ret


jr_000_1742:
    ld a, [$d033]
    cp $02
    jr c, jr_000_1768

    ldh a, [hInputPressed]
    bit PADB_DOWN, a
    jp nz, Jump_000_1785

    ld a, $06
    ld [samusPose], a
    ld a, $01
    ld [$cec0], a
    jr nz, jr_000_1762

    ld a, $48
    ld [$d026], a
    ret


jr_000_1762:
    ld a, $44
    ld [$d026], a
    ret


jr_000_1768:
    xor a
    ld [$d033], a
    ldh a, [hInputPressed]
    bit PADB_RIGHT, a
    jr z, jr_000_1779

    call Call_000_1c98
    ld a, [$d035]
    ret


jr_000_1779:
    ldh a, [hInputPressed]
    bit PADB_LEFT, a
    ret z

    call Call_000_1cc9
    ld a, [$d036]
    ret


Jump_000_1785:
jr_000_1785:
    ld a, [samusItems]
    bit itemBit_spider, a
    ret z

    ld a, $0e
    ld [samusPose], a
    ld a, $01
    ld [$d024], a
    xor a
    ld [$d044], a
    ld a, $0d
    ld [$cec0], a
    ret


    ldh a, [hInputRisingEdge]
    bit PADB_DOWN, a
    jr z, jr_000_17bb

    ld a, [samusItems]
    bit itemBit_spider, a
    jr z, jr_000_17bb

    ld a, $0d
    ld [samusPose], a
    xor a
    ld [$d044], a
    ld a, $0d
    ld [$cec0], a
    ret


jr_000_17bb:
    ld a, [$d026]
    cp $40
    jr nc, jr_000_17da

    ldh a, [hInputPressed]
    bit PADB_A, a
    jr z, jr_000_17d5

    ld a, [samusItems]
    and itemMask_hiJump
    srl a
    ld b, a
    ld a, $fe
    sub b
    jr jr_000_17f3

jr_000_17d5:
    ld a, $56
    ld [$d026], a

jr_000_17da:
    sub $40
    ld hl, $184a
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    cp $80
    jr z, jr_000_182e

    bit 7, a
    jr nz, jr_000_17f3

    ld a, [$d062]
    and a
    jr nz, jr_000_182e

    ld a, [hl]

jr_000_17f3:
    call Call_000_1d4e
    jr nc, jr_000_17ff

    ld a, [$d026]
    cp $57
    jr nc, jr_000_182e

jr_000_17ff:
    ld a, [$d026]
    inc a
    ld [$d026], a
    ld a, [samusPose]
    cp $06
    jr nz, jr_000_181b

    ldh a, [hInputRisingEdge]
    bit PADB_UP, a
    jr z, jr_000_181b

    call Call_000_1bb3
    ld a, $10
    ld [$d049], a

jr_000_181b:
    ldh a, [hInputPressed]
    bit PADB_RIGHT, a
    jr z, jr_000_1824

    call Call_000_1cf5

jr_000_1824:
    ldh a, [hInputPressed]
    bit PADB_LEFT, a
    jr z, jr_000_182d

    call Call_000_1d22

jr_000_182d:
    ret


jr_000_182e:
    xor a
    ld [$184a], a
    ld a, $16
    ld [$d024], a
    ld a, [samusPose]
    cp $06
    jr z, jr_000_1844

    ld a, $07
    ld [samusPose], a
    ret


jr_000_1844:
    ld a, $08
    ld [samusPose], a
    ret


    db $fe, $fe, $fe, $fe, $ff, $fe, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $ff, $00, $ff
    db $ff, $00, $ff, $00, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $01
    db $00, $01, $01, $00, $01, $01, $01, $01, $01, $01, $02, $01, $02, $01, $02, $02
    db $02, $02, $03, $02, $02, $03, $02, $02, $03, $02, $03, $02, $03, $02, $03, $02
    db $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $80

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

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

    db $00, $00

    nop
    nop

    db $00

    nop

    db $00, $00

    nop

    db $00

    nop

    db $00, $00, $00, $00, $00, $00, $00, $02, $01, $02, $02, $02, $02, $03, $02, $02
    db $03, $02, $02, $03, $02, $03, $02, $03, $02, $03, $02, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00

    nop

    db $00

    add b

    ldh a, [hInputRisingEdge]
    bit PADB_B, a
    jr z, jr_000_18f3

    ld a, $01
    ld [samusPose], a

jr_000_18f3:
    ld a, [$d026]
    cp $40
    jr nc, jr_000_1912

    ldh a, [hInputPressed]
    bit PADB_A, a
    jr z, jr_000_190d

    ld a, [samusItems]
    and itemMask_hiJump
    srl a
    ld b, a
    ld a, $fe
    sub b
    jr jr_000_197b

jr_000_190d:
    ld a, $56
    ld [$d026], a

jr_000_1912:
    sub $40
    ld e, a
    ld d, $00
    ldh a, [hInputRisingEdge]
    bit PADB_A, a
    jr z, jr_000_195f

    ld hl, $1899
    add hl, de
    ld a, [hl]
    and a
    jr z, jr_000_195f

    ld a, [samusItems]
    bit itemBit_space, a
    jr z, jr_000_195f

    ld a, $18
    ld [$d026], a
    ld a, $02
    ld [$cec0], a
    ld a, [samusItems]
    bit itemBit_hiJump, a
    jr nz, jr_000_1947

    ld a, $28
    ld [$d026], a
    ld a, $01
    ld [$cec0], a

jr_000_1947:
    ld a, [samusItems]
    bit itemBit_screw, a
    jr z, jr_000_1953

    ld a, $03
    ld [$cec0], a

jr_000_1953:
    ld a, [$d00f]
    and a
    ret z

    inc a
    srl a
    ld [$d02b], a
    ret


jr_000_195f:
    ld a, [$d00f]
    and a
    jr nz, jr_000_1970

    ldh a, [hInputPressed]
    bit PADB_UP, a
    jr z, jr_000_1970

    ldh a, [$97]
    and $03
    ret nz

jr_000_1970:
    ld hl, $184a
    add hl, de
    ld a, [hl]
    cp $80
    jr nz, jr_000_197b

    jr jr_000_19c7

jr_000_197b:
    bit 7, a
    jr nz, jr_000_1986

    ld a, [$d062]
    and a
    jr nz, jr_000_19c7

    ld a, [hl]

jr_000_1986:
    call Call_000_1d4e
    jr nc, jr_000_1994

    ld a, [$d026]
    cp $57
    jr c, jr_000_1994

    jr jr_000_19d3

jr_000_1994:
    ld a, [$d026]
    inc a
    ld [$d026], a
    ldh a, [hInputPressed]
    bit PADB_RIGHT, a
    jr z, jr_000_19a6

    ld a, $01
    ld [$d00f], a

jr_000_19a6:
    ldh a, [hInputPressed]
    bit PADB_LEFT, a
    jr z, jr_000_19b1

    ld a, $ff
    ld [$d00f], a

jr_000_19b1:
    ld a, [$d00f]
    cp $01
    jr nz, jr_000_19bc

    call Call_000_1cfa
    ret


jr_000_19bc:
    ld a, [$d00f]
    cp $ff
    ret nz

    call Call_000_1d26
    ret


    ret


jr_000_19c7:
    ld a, [samusItems]
    and itemMask_space | itemMask_screw
    jr z, jr_000_19d3

    ld a, $04
    ld [$cec0], a

jr_000_19d3:
    xor a
    ld [$184a], a
    ld a, $16
    ld [$d024], a
    ld a, $07
    ld [samusPose], a
    ret


    ldh a, [hInputPressed]
    bit PADB_A, a
    jr z, jr_000_1a1b

    ldh a, [$97]
    and $02
    srl a
    ld b, a
    ld a, $fe
    sub b
    call Call_000_1d4e
    jr nc, jr_000_19fb

    call Call_000_1b37
    ret


jr_000_19fb:
    ld a, [$d010]
    inc a
    ld [$d010], a
    cp $06
    jr nc, jr_000_1a1b

    ldh a, [hInputPressed]
    bit PADB_RIGHT, a
    jr z, jr_000_1a10

    call Call_000_1cf5
    ret


jr_000_1a10:
    ldh a, [hInputPressed]
    bit PADB_LEFT, a
    jr z, jr_000_1a1a

    call Call_000_1d22
    ret


jr_000_1a1a:
    ret


jr_000_1a1b:
    ld a, [samusPose]
    cp $09
    jr nz, jr_000_1a28

    ld a, $01
    ld [samusPose], a
    ret


jr_000_1a28:
    ldh a, [hInputPressed]
    and PADF_LEFT | PADF_RIGHT
    swap a
    ld e, a
    ld d, $00
    ld hl, $1a3f
    add hl, de
    ld a, [hl]
    ld [$d00f], a
    ld a, $02
    ld [samusPose], a
    ret


    db $00, $01, $ff

Call_000_1a42:
    xor a
    ld [$d03d], a
    ldh a, [hSamusXPixel]
    add $15
    ld [$c204], a
    ldh a, [hSamusYPixel]
    add $1e
    ld [$c203], a
    call Call_000_1fbf
    ld a, [$d03d]
    rr a
    ld [$d03d], a
    ldh a, [hSamusYPixel]
    add $2c
    ld [$c203], a
    call Call_000_1fbf
    ld a, [$d03d]
    rr a
    ld [$d03d], a
    ldh a, [hSamusXPixel]
    add $0a
    ld [$c204], a
    ldh a, [hSamusYPixel]
    add $1e
    ld [$c203], a
    call Call_000_1fbf
    ld a, [$d03d]
    rr a
    ld [$d03d], a
    ldh a, [hSamusYPixel]
    add $2c
    ld [$c203], a
    call Call_000_1fbf
    ld a, [$d03d]
    rr a
    ld [$d03d], a
    swap a
    ld [$d03d], a
    ldh a, [hSamusXPixel]
    add $15
    ld [$c204], a
    ldh a, [hSamusYPixel]
    add $25
    ld [$c203], a
    call Call_000_1fbf
    jr nc, jr_000_1abc

    ld a, [$d03d]
    or $03
    ld [$d03d], a

jr_000_1abc:
    ldh a, [hSamusXPixel]
    add $0a
    ld [$c204], a
    ldh a, [hSamusYPixel]
    add $25
    ld [$c203], a
    call Call_000_1fbf
    jr nc, jr_000_1ad7

    ld a, [$d03d]
    or $0c
    ld [$d03d], a

jr_000_1ad7:
    ldh a, [hSamusXPixel]
    add $0f
    ld [$c204], a
    ldh a, [hSamusYPixel]
    add $1e
    ld [$c203], a
    call Call_000_1fbf
    jr nc, jr_000_1af2

    ld a, [$d03d]
    or $05
    ld [$d03d], a

jr_000_1af2:
    ldh a, [hSamusYPixel]
    add $2c
    ld [$c203], a
    ldh a, [hSamusXPixel]
    add $0f
    ld [$c204], a
    call Call_000_1ff5
    ld hl, $d056
    cp [hl]
    jr nc, jr_000_1b13

    ld a, [$d03d]
    or $0a
    ld [$d03d], a
    jr jr_000_1b20

jr_000_1b13:
    call Call_000_348d
    jr nc, jr_000_1b20

    ld a, [$d03d]
    or $0a
    ld [$d03d], a

jr_000_1b20:
    ld a, [$d03d]
    and $05
    cp $05
    ret z

    ldh a, [hInputPressed]
    bit PADB_A, a
    ret z

    ret


Call_000_1b2e:
    ldh a, [hSamusXPixel]
    add $0b
    ld [$c204], a
    jr jr_000_1b6b

Call_000_1b37:
    ld a, $04
    ld [$cec0], a
    ldh a, [hSamusXPixel]
    add $0c
    ld [$c204], a
    ldh a, [hSamusYPixel]
    add $10
    ld [$c203], a
    call Call_000_1ff5
    ld hl, $d056
    cp [hl]
    ret c

    ldh a, [hSamusXPixel]
    add $14
    ld [$c204], a
    call Call_000_1ff5
    ld hl, $d056
    cp [hl]
    ret c

    xor a
    ld [samusPose], a
    ld a, $04
    ld [$cec0], a
    ret


jr_000_1b6b:
    ldh a, [hSamusYPixel]
    add $18
    ld [$c203], a
    call Call_000_1ff5
    ld hl, $d056
    cp [hl]
    jr c, jr_000_1b9a

    ldh a, [hSamusXPixel]
    add $14
    ld [$c204], a
    call Call_000_1ff5
    ld hl, $d056
    cp [hl]
    jr c, jr_000_1b9a

    ld a, $04
    ld [samusPose], a
    xor a
    ld [$d022], a
    ld a, $05
    ld [$cec0], a
    ret


jr_000_1b9a:
    ld a, $05
    ld [samusPose], a
    xor a
    ld [$d033], a
    ret


Call_000_1ba4:
    ld a, $05
    ld [samusPose], a
    xor a
    ld [$d033], a
    ld a, $06
    ld [$cec0], a
    ret


Call_000_1bb3:
    ldh a, [hSamusYPixel]
    add $08
    ld [$c203], a
    ldh a, [hSamusXPixel]
    add $0b
    ld [$c204], a
    call Call_000_1ff5
    ld hl, $d056
    cp [hl]
    jr c, jr_000_1c0c

    ldh a, [hSamusXPixel]
    add $14
    ld [$c204], a
    call Call_000_1ff5
    ld hl, $d056
    cp [hl]
    jr c, jr_000_1c0c

    ldh a, [hSamusYPixel]
    add $18
    ld [$c203], a
    ldh a, [hSamusXPixel]
    add $0b
    ld [$c204], a
    call Call_000_1ff5
    ld hl, $d056
    cp [hl]
    jr c, jr_000_1c0c

    ldh a, [hSamusXPixel]
    add $14
    ld [$c204], a
    call Call_000_1ff5
    ld hl, $d056
    cp [hl]
    jr c, jr_000_1c0c

    ld a, $07
    ld [samusPose], a
    ld a, $04
    ld [$cec0], a
    ret


jr_000_1c0c:
    ret


Call_000_1c0d:
    ld a, $01
    ld [$d02b], a
    ld b, $01
    ld a, [$d048]
    and a
    jr nz, jr_000_1c2c

    ld a, [samusItems]
    bit itemBit_varia, a
    jr z, jr_000_1c25

    ld b, $02
    jr jr_000_1c2c

jr_000_1c25:
    ldh a, [$97]
    and $01
    add $01
    ld b, a

jr_000_1c2c:
    ldh a, [hSamusXPixel]
    add b
    ldh [hSamusXPixel], a
    ldh a, [hSamusXScreen]
    adc $00
    and $0f
    ldh [hSamusXScreen], a
    ld [$c204], a
    call Call_000_1de2
    jr nc, jr_000_1c4c

    ld a, [$d027]
    ldh [hSamusXPixel], a
    ld a, [$d028]
    ldh [hSamusXScreen], a
    ret


jr_000_1c4c:
    ld a, b
    ld [$d035], a
    ret


Call_000_1c51:
    xor a
    ld [$d02b], a
    ld b, $01
    ld a, [$d048]
    and a
    jr nz, jr_000_1c6f

    ld a, [samusItems]
    bit itemBit_varia, a
    jr z, jr_000_1c68

    ld b, $02
    jr jr_000_1c6f

jr_000_1c68:
    ldh a, [$97]
    and $01
    add $01
    ld b, a

jr_000_1c6f:
    ldh a, [hSamusXPixel]
    sub b
    ldh [hSamusXPixel], a
    ldh a, [hSamusXScreen]
    sbc $00
    and $0f
    ldh [hSamusXScreen], a
    ld [$c204], a
    call Call_000_1dd6
    jr nc, jr_000_1c8f

    ld a, [$d027]
    ldh [hSamusXPixel], a
    ld a, [$d028]
    ldh [hSamusXScreen], a
    ret


jr_000_1c8f:
    ld a, b
    ld [$d036], a
    ret


Call_000_1c94:
    ld a, $01
    jr jr_000_1c9a

Call_000_1c98:
    ld a, $02

jr_000_1c9a:
    ld b, a
    ld a, $01
    ld [$d02b], a
    ldh a, [hSamusXPixel]
    add b
    ldh [hSamusXPixel], a
    ldh a, [hSamusXScreen]
    adc $00
    and $0f
    ldh [hSamusXScreen], a
    ld [$c204], a
    call Call_000_1de2
    jr nc, jr_000_1cc0

    ld a, [$d027]
    ldh [hSamusXPixel], a
    ld a, [$d028]
    ldh [hSamusXScreen], a
    ret


jr_000_1cc0:
    ld a, b
    ld [$d035], a
    ret


Call_000_1cc5:
    ld a, $01
    jr jr_000_1ccb

Call_000_1cc9:
    ld a, $02

jr_000_1ccb:
    ld b, a
    xor a
    ld [$d02b], a
    ldh a, [hSamusXPixel]
    sub b
    ldh [hSamusXPixel], a
    ldh a, [hSamusXScreen]
    sbc $00
    and $0f
    ldh [hSamusXScreen], a
    ld [$c204], a
    call Call_000_1dd6
    jr nc, jr_000_1cf0

    ld a, [$d027]
    ldh [hSamusXPixel], a
    ld a, [$d028]
    ldh [hSamusXScreen], a
    ret


jr_000_1cf0:
    ld a, b
    ld [$d036], a
    ret


Call_000_1cf5:
    ld a, $01
    ld [$d02b], a

Call_000_1cfa:
    ld a, $01
    ld b, a
    ldh a, [hSamusXPixel]
    add b
    ldh [hSamusXPixel], a
    ldh a, [hSamusXScreen]
    adc $00
    and $0f
    ldh [hSamusXScreen], a
    ld [$c204], a
    call Call_000_1de2
    jr nc, jr_000_1d1d

    ld a, [$d027]
    ldh [hSamusXPixel], a
    ld a, [$d028]
    ldh [hSamusXScreen], a
    ret


jr_000_1d1d:
    ld a, b
    ld [$d035], a
    ret


Call_000_1d22:
    xor a
    ld [$d02b], a

Call_000_1d26:
    ld a, $01
    ld b, a
    ldh a, [hSamusXPixel]
    sub b
    ldh [hSamusXPixel], a
    ldh a, [hSamusXScreen]
    sbc $00
    and $0f
    ldh [hSamusXScreen], a
    ld [$c204], a
    call Call_000_1dd6
    jr nc, jr_000_1d49

    ld a, [$d027]
    ldh [hSamusXPixel], a
    ld a, [$d028]
    ldh [hSamusXScreen], a
    ret


jr_000_1d49:
    ld a, b
    ld [$d036], a
    ret


Call_000_1d4e:
    bit 7, a
    jr nz, jr_000_1d96

    ld b, a
    ld a, b
    ld [$d034], a
    ldh a, [hSamusYPixel]
    add b
    ldh [hSamusYPixel], a
    ldh a, [hSamusYScreen]
    adc $00
    and $0f
    ldh [hSamusYScreen], a
    ld a, b
    call Call_000_1f0f
    jr nc, jr_000_1d76

    ld a, [$d029]
    ldh [hSamusYPixel], a
    ld a, [$d02a]
    ldh [hSamusYScreen], a
    scf
    ret


jr_000_1d76:
    ld a, [$d048]
    and a
    jr z, jr_000_1d8b

    srl b
    ld a, [$d029]
    add b
    ldh [hSamusYPixel], a
    ld a, [$d02a]
    adc $00
    ldh [hSamusYScreen], a

jr_000_1d8b:
    ld a, b
    ld [$d038], a
    ld a, [$d034]
    ld [$d033], a
    ret


jr_000_1d96:
    cpl
    inc a

Call_000_1d98:
    ld b, a
    ldh a, [hSamusYPixel]
    sub b
    ldh [hSamusYPixel], a
    ldh a, [hSamusYScreen]
    sbc $00
    and $0f
    ldh [hSamusYScreen], a
    ld a, b
    call Call_000_1e88
    jr nc, jr_000_1dbc

    ld a, $56
    ld [$d026], a
    ld a, [$d029]
    ldh [hSamusYPixel], a
    ld a, [$d02a]
    ldh [hSamusYScreen], a
    ret


jr_000_1dbc:
    ld a, [$d048]
    and a
    jr z, jr_000_1dd1

    srl b
    ld a, [$d029]
    sub b
    ldh [hSamusYPixel], a
    ld a, [$d02a]
    sbc $00
    ldh [hSamusYScreen], a

jr_000_1dd1:
    ld a, b
    ld [$d037], a
    ret


Call_000_1dd6:
    push hl
    push de
    push bc
    ldh a, [hSamusXPixel]
    add $0b
    ld [$c204], a
    jr jr_000_1dec

Call_000_1de2:
    push hl
    push de
    push bc
    ldh a, [hSamusXPixel]
    add $14
    ld [$c204], a

jr_000_1dec:
    call Call_000_32cf
    jp c, Jump_000_1e84

    ld hl, $20ff
    ld a, [samusPose]
    sla a
    sla a
    sla a
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl+]
    cp $80
    jp z, Jump_000_1e84

    ld [$d02d], a
    ld a, [hl+]
    cp $80
    jr z, jr_000_1e71

    ld [$d02e], a
    ld a, [hl+]
    cp $80
    jr z, jr_000_1e5e

    ld [$d02f], a
    ld a, [hl+]
    cp $80
    jr z, jr_000_1e4b

    ld [$d030], a
    ld a, [hl]
    cp $80
    jr z, jr_000_1e38

    ld b, a
    ldh a, [hSamusYPixel]
    add b
    ld [$c203], a
    call Call_000_1ff5
    ld hl, $d056
    cp [hl]
    jr c, jr_000_1e84

jr_000_1e38:
    ld a, [$d030]
    ld b, a
    ldh a, [hSamusYPixel]
    add b
    ld [$c203], a
    call Call_000_1ff5
    ld hl, $d056
    cp [hl]
    jr c, jr_000_1e84

jr_000_1e4b:
    ld a, [$d02f]
    ld b, a
    ldh a, [hSamusYPixel]
    add b
    ld [$c203], a
    call Call_000_1ff5
    ld hl, $d056
    cp [hl]
    jr c, jr_000_1e84

jr_000_1e5e:
    ld a, [$d02e]
    ld b, a
    ldh a, [hSamusYPixel]
    add b
    ld [$c203], a
    call Call_000_1ff5
    ld hl, $d056
    cp [hl]
    jr c, jr_000_1e84

jr_000_1e71:
    ld a, [$d02d]
    ld b, a
    ldh a, [hSamusYPixel]
    add b
    ld [$c203], a
    call Call_000_1ff5
    ld hl, $d056
    cp [hl]
    jr c, jr_000_1e84

Jump_000_1e84:
jr_000_1e84:
    pop bc
    pop de
    pop hl
    ret


Call_000_1e88:
    push hl
    push de
    push bc
    call Call_000_34ef
    jp c, Jump_000_1f0b

    ldh a, [hSamusXPixel]
    add $0c
    ld [$c204], a
    ld hl, $20e9
    ld a, [samusPose]
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    ld b, a
    ldh a, [hSamusYPixel]
    add b
    ld [$c203], a
    call Call_000_1ff5
    ld hl, $d056
    cp [hl]
    ld h, $dc
    ld l, a
    ld a, [hl]
    bit 0, a
    jr z, jr_000_1ebf

    ld a, $ff
    ld [$d048], a
    ld a, [hl]

jr_000_1ebf:
    bit 1, a
    jr z, jr_000_1ec4

    ccf

jr_000_1ec4:
    ld a, [hl]
    bit 4, a
    jr z, jr_000_1ed6

    ld a, $40
    ld [$d062], a
    push af
    ld a, [acidDamageValue]
    call Call_000_2f4a
    pop af

jr_000_1ed6:
    jr c, jr_000_1f0b

    ldh a, [hSamusXPixel]
    add $14
    ld [$c204], a
    call Call_000_1ff5
    ld hl, $d056
    cp [hl]
    ld h, $dc
    ld l, a
    ld a, [hl]
    bit 0, a
    jr z, jr_000_1ef4

    ld a, $ff
    ld [$d048], a
    ld a, [hl]

jr_000_1ef4:
    bit 1, a
    jr z, jr_000_1ef9

    ccf

jr_000_1ef9:
    ld a, [hl]
    bit 4, a
    jr z, jr_000_1f0b

    ld a, $40
    ld [$d062], a
    push af
    ld a, [acidDamageValue]
    call Call_000_2f4a
    pop af

Jump_000_1f0b:
jr_000_1f0b:
    pop bc
    pop de
    pop hl
    ret


Call_000_1f0f:
    push hl
    push de
    push bc
    call Call_000_348d
    jr nc, jr_000_1f2c

    ld a, $01
    ld [$c43a], a
    ld a, l
    ld [$d05e], a
    ld a, h
    ld [$d05f], a
    ld a, $20
    ld [$d05d], a
    jp Jump_000_1fbb


jr_000_1f2c:
    ldh a, [hSamusXPixel]
    add $0c
    ld [$c204], a
    ldh a, [hSamusYPixel]
    add $2c
    ld [$c203], a
    call Call_000_1ff5
    ld hl, $d056
    cp [hl]
    ld h, $dc
    ld l, a
    ld a, [hl]
    bit 0, a
    jr z, jr_000_1f4e

    ld a, $31
    ld [$d048], a

jr_000_1f4e:
    ld a, [hl]
    bit 7, a
    jr z, jr_000_1f58

    ld a, $ff
    ld [$d07d], a

jr_000_1f58:
    ld a, [hl]
    bit 2, a
    jr z, jr_000_1f62

    ld a, [samusPose]
    scf
    ccf

jr_000_1f62:
    ld a, [hl]
    bit 4, a
    jr z, jr_000_1f74

    ld a, $40
    ld [$d062], a
    push af
    ld a, [acidDamageValue]
    call Call_000_2f4a
    pop af

jr_000_1f74:
    jr c, jr_000_1fbb

    ldh a, [hSamusXPixel]
    add $14
    ld [$c204], a
    call Call_000_1ff5
    ld hl, $d056
    cp [hl]
    ld h, $dc
    ld l, a
    ld a, [hl]
    bit 0, a
    jr z, jr_000_1f91

    ld a, $ff
    ld [$d048], a

jr_000_1f91:
    ld a, [hl]
    bit 7, a
    jr z, jr_000_1f9b

    ld a, $ff
    ld [$d07d], a

jr_000_1f9b:
    ld a, [hl]
    bit 2, a
    jr z, jr_000_1fa2

    scf
    ccf

jr_000_1fa2:
    ld a, [hl]
    bit 4, a
    jr z, jr_000_1fb4

    ld a, $40
    ld [$d062], a
    push af
    ld a, [acidDamageValue]
    call Call_000_2f4a
    pop af

jr_000_1fb4:
    jr nc, jr_000_1fbb

    ld a, $00
    ld [$d049], a

Jump_000_1fbb:
jr_000_1fbb:
    pop bc
    pop de
    pop hl
    ret


Call_000_1fbf:
    call Call_000_1ff5
    ld hl, $d056
    cp [hl]
    jr nc, jr_000_1fe0

    ld h, $dc
    ld l, a
    ld a, [hl]
    bit 4, a
    jr z, jr_000_1fdb

    ld a, $40
    ld [$d062], a
    ld a, [acidDamageValue]
    call Call_000_2f4a

jr_000_1fdb:
    scf
    ret


jr_000_1fdd:
    scf
    ccf
    ret


jr_000_1fe0:
    ld h, $dc
    ld l, a
    ld a, [hl]
    bit 4, a
    jr z, jr_000_1fdd

    ld a, $40
    ld [$d062], a
    ld a, [acidDamageValue]
    call Call_000_2f4a
    jr jr_000_1fdd

Call_000_1ff5:
    call Call_000_22bc
    ld a, [$c219]
    and $08
    jr z, jr_000_2006

    ld a, $04
    add h
    ld h, a
    ld [$c216], a

jr_000_2006:
    ldh a, [rSTAT]
    and $03
    jr nz, jr_000_2006

    ld b, [hl]

jr_000_200d:
    ldh a, [rSTAT]
    and $03
    jr nz, jr_000_200d

    ld a, [hl]
    and b
    ld b, a
    ld a, [$d04f]
    and a
    jr nz, jr_000_2039

    ld h, $dc
    ld a, b
    ld l, a
    ld a, [hl]
    bit 3, a
    jr z, jr_000_2039

    ld a, $04
    ld [$cec0], a
    ld a, $01
    ld [$c422], a
    xor a
    ld [$c423], a
    ld a, [spikeDamageValue]
    ld [$c424], a

jr_000_2039:
    ld a, b
    ret

; 0:203B - Metroids remaining (L counter)
    db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00
    db $01, $02, $03, $01, $01, $01, $02, $03, $04, $05, $00, $00, $00, $00, $00, $00
    db $06, $07, $01, $02, $01, $01, $02, $03, $04, $05, $00, $00, $00, $00, $00, $00
    db $06, $07, $08, $09, $10, $01, $02, $03, $04, $05, $00, $00, $00, $00, $00, $00
    db $06, $07, $08, $01, $02, $03, $04, $01

; 0:2083 - Magic number for save
saveFile_magicNumber:
    db $01, $23, $45, $67, $89, $ab, $cd, $ef

; Damage pose transition table 
; 00:208B
    db $0F
    db $0F
    db $0F
    db $0F
    db $0F
    db $10
    db $10
    db $0F
    db $10
    db $0F
    db $0F
    db $10
    db $10
    db $10
    db $10
    db $0F
    db $10
    db $0F
    db $10
    db $0F
    db $00
    db $00
    db $00
    db $00
    db $10
    db $10
    db $1A
    db $1B
    db $1C
    db $1D
    
; Spider ball direction table
; 00:20A9 - Spider Ball Direction Table
    db $00, $04, $01, $04, $02, $02, $00, $02, $08, $00, $01, $04, $08, $08, $01, $00
    db $00, $02, $04, $02, $08, $08, $00, $08, $01, $00, $04, $02, $01, $01, $04, $00
    db $00, $01, $08, $08, $04, $01, $00, $08, $02, $00, $02, $02, $04, $01, $04, $00
    db $00, $08, $02, $02, $01, $08, $00, $02, $04, $00, $04, $04, $01, $08, $01, $00

; 00:20E9 - Samus pose related (y pixel offsets?)
    db $08
    db $14
    db $1A
    db $08
    db $10
    db $20
    db $20
    db $10
    db $20
    db $10
    db $10
    db $20
    db $20
    db $20
    db $20
    db $10
    db $20
    db $10
    db $20
    db $08
    db $20
    db $20

; 00:20FF - Pose related table
    db $10, $18, $20, $28, $2A, $80, $00, $00
    db $14, $18, $20, $28, $2A, $80, $00, $00
    db $1A, $20, $28, $2A, $80, $00, $00, $00
    db $10, $18, $20, $28, $2A, $80, $00, $00
    db $10, $18, $20, $28, $2A, $80, $00, $00
    db $20, $25, $2A, $80, $00, $00, $00, $00
    db $20, $25, $2A, $80, $00, $00, $00, $00
    db $10, $18, $20, $28, $2A, $80, $00, $00
    db $20, $25, $2A, $80, $00, $00, $00, $00
    db $10, $18, $20, $28, $2A, $80, $00, $00
    db $10, $18, $20, $28, $2A, $80, $00, $00
    db $20, $25, $2B, $80, $00, $00, $00, $00
    db $20, $25, $2B, $80, $00, $00, $00, $00
    db $20, $25, $2B, $80, $00, $00, $00, $00
    db $20, $25, $2B, $80, $00, $00, $00, $00
    db $14, $18, $20, $28, $2A, $80, $00, $00
    db $20, $25, $2A, $80, $00, $00, $00, $00
    db $10, $18, $20, $28, $2A, $80, $00, $00
    db $20, $25, $2A, $80, $00, $00, $00, $00
    db $10, $18, $20, $28, $2A, $80, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00
    db $20, $25, $2A, $80, $00, $00, $00, $00
    db $20, $25, $2A, $80, $00, $00, $00, $00
    db $20, $25, $2A, $80, $00, $00, $00, $00
    db $20, $25, $2A, $80, $00, $00, $00, $00
    db $20, $25, $2A, $80, $00, $00, $00, $00
    db $20, $25, $2A, $80, $00, $00, $00, $00


; Clear Projectile RAM
Call_000_21ef: ; 00:21EF
    ld h, $dd
    ld l, $00
    .loop:
        ld a, $ff
        ld [hl+], a
        ld a, l
        and a
    jr nz, .loop
ret


Call_000_21fb:
    ld a, [samusPose]
    cp $13
    jp z, Jump_000_3daf

    ld a, [$d090]
    cp $22
    jp z, Jump_000_3daf

    ldh a, [hInputRisingEdge]
    bit PADB_SELECT, a
    jp z, Jump_000_3daf

Call_000_2212:
    ld a, [$d04d]
    cp $08
    jr nz, jr_000_222b

    ld a, [$d055]
    ld [$d04d], a
    ld hl, $2249
    call Call_000_2753
    ld a, $15
    ld [$cec0], a
    ret


jr_000_222b:
    ld a, [$d04d]
    ld [$d055], a
    ld a, $08
    ld [$d04d], a
    ld hl, $2242
    call Call_000_2753
    ld a, $15
    ld [$cec0], a
    ret


    db $06, $20, $40, $80, $80, $20, $00, $06, $00, $40, $80, $80, $20, $00

    ld a, [$c205]
    ld b, a
    ld a, [$c44d]
    add b
    ld [$c203], a
    ld a, [$c206]
    ld b, a
    ld a, [$c44e]
    add b
    ld [$c204], a
    call Call_000_22bc
    ld a, [$c219]
    and $08
    jr z, jr_000_2277

    ld a, $04
    add h
    ld h, a
    ld [$c216], a

jr_000_2277:
    ldh a, [rSTAT]
    and $03
    jr nz, jr_000_2277

    ld b, [hl]

jr_000_227e:
    ldh a, [rSTAT]
    and $03
    jr nz, jr_000_227e

    ld a, [hl]
    and b
    ret

; 0:2287 - Read Input
main_readInput:
    ld a, $20
    ldh [rP1], a
    ldh a, [rP1]
    ldh a, [rP1]
    cpl
    and $0f
    swap a
    ld b, a
    ld a, $10
    ldh [rP1], a
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    cpl
    and $0f
    or b
    ld c, a
    ldh a, [hInputPressed]
    xor c
    and c
    ldh [hInputRisingEdge], a
    ld a, c
    ldh [hInputPressed], a
    ld a, $30
    ldh [rP1], a
ret


Call_000_22bc:
    ld a, [$c203]
    sub $10
    ld b, $08
    ld de, $0020
    ld hl, $97e0

jr_000_22c9:
    add hl, de
    sub b
    jr nc, jr_000_22c9

    ld a, [$c204]
    sub b
    srl a
    srl a
    srl a
    add l
    ld l, a
    ld [$c215], a
    ld a, h
    ld [$c216], a
    ret


    ld a, [$c216]
    ld d, a
    ld a, [$c215]
    ld e, a
    ld b, $04

jr_000_22eb:
    rr d
    rr e
    dec b
    jr nz, jr_000_22eb

    ld a, e
    sub $84
    and $fe
    rlca
    rlca
    add $08
    ld [$c203], a
    ld a, [$c215]
    and $1f
    rla
    rla
    rla
    add $08
    ld [$c204], a
    ret


    ld a, [$c227]
    and a
    ret z

    ld c, $03
    xor a
    ld [$c227], a

jr_000_2317:
    ld a, [de]
    ld b, a
    swap a
    and $0f
    jr nz, jr_000_234a

    ld a, [$c227]
    and a
    ld a, $00
    jr nz, jr_000_2329

    ld a, $ff

jr_000_2329:
    ld [hl+], a
    ld a, b
    and $0f
    jr nz, jr_000_2353

    ld a, [$c227]
    and a
    ld a, $00
    jr nz, jr_000_2340

    ld a, $01
    cp c
    ld a, $00
    jr z, jr_000_2340

    ld a, $ff

jr_000_2340:
    ld [hl+], a
    dec e
    dec c
    jr nz, jr_000_2317

    xor a
    ld [$c227], a
    ret


jr_000_234a:
    push af
    ld a, $01
    ld [$c227], a
    pop af
    jr jr_000_2329

jr_000_2353:
    push af
    ld a, $01
    ld [$c227], a
    pop af
    jr jr_000_2340

;------------------------------------------------------------------------------
oamDMA_routine: ; Copied to $FFA0 in HRAM
    ld a, HIGH(wram_oamBuffer)
    ldh [rDMA], a
    ld a, $28
    .loop:
        dec a
    jr nz, .loop
ret

;------------------------------------------------------------------------------
Call_000_2366:
    ldh a, [hCameraYPixel]
    sub $48
    ld [$c205], a
    ldh a, [hCameraXPixel]
    sub $50
    ld [$c206], a
    call Call_000_3ced
    ret


Call_000_2378:
    ld a, $04
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call $4006
    ret


handleAudio: ;00:2384
    ld a, BANK(handleAudio_longJump)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call handleAudio_longJump
ret


Call_000_2390:
    ld a, $04
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call $4003
    ret

; Screen Transition decoder
Call_000_239c:
Jump_000_239c:
    ld a, [$d08e]
    ld b, a
    ld a, [$d08f]
    or b
    jp z, Jump_000_26d7

    ld a, [$d064]
    ldh [hOamBufferIndex], a
    call Call_000_3e88
    call waitOneFrame
    call OAM_DMA
	
	; From the door index, get the pointer and load the script
    ld a, $05
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld a, [$d08e]
    ld e, a
    ld a, [$d08f]
    ld d, a
    sla e
    rl d
    ld hl, doorPointerTable
    add hl, de
    ld a, [hl+]
    ld e, a
    ld a, [hl]
    ld h, a
    ld a, e
    ld l, a
	
    ld b, doorScriptBufferSize
    ld de, doorScriptBuffer
    .loadDoor:
        ld a, [hl+]
	    ld [de], a
        inc de
        dec b
    jr nz, .loadDoor

    ld hl, doorScriptBuffer

Jump_000_23e1:
    ld a, [hl]
    cp $ff
    jp nz, Jump_000_23eb

    inc hl
    jp Jump_000_26d7


Jump_000_23eb:
    and $f0
    cp $b0
    jr nz, jr_000_2402

    xor a
    ld [$d088], a
    ld [$d07d], a
    ld a, $88
    ldh [rWY], a
    call Call_000_26eb
    jp Jump_000_26d1


jr_000_2402:
    cp $00
    jr nz, jr_000_2417

    xor a
    ld [$d088], a
    ld [$d07d], a
    ld a, $88
    ldh [rWY], a
    call Call_000_2747
    jp Jump_000_26d1


jr_000_2417:
    cp $10
    jr nz, jr_000_2421

    call Call_000_282a
    jp Jump_000_26d1


jr_000_2421:
    cp $20
    jr nz, jr_000_242b

    call Call_000_2859
    jp Jump_000_26d1


jr_000_242b:
    cp $30
    jr nz, jr_000_245f

    ld a, [hl+]
    push hl
    and $0f
    ld e, a
    ld d, $00
    sla e
    sla e
    ld a, BANK(solidityIndexTable)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld hl, solidityIndexTable
    add hl, de
    ld a, [hl+]
    ld [$d056], a
    ld [$d812], a
    ld a, [hl+]
    ld [$d069], a
    ld [$d813], a
    ld a, [hl+]
    ld [$d08a], a
    ld [$d814], a
    pop hl
    jp Jump_000_26d1


jr_000_245f:
    cp $40
    jr nz, jr_000_2476

    call Call_000_28fb
    ld a, $01
    ld [$c458], a
    ld a, [$d08b]
    and $0f
    ld [$d08b], a
    jp Jump_000_26d1


jr_000_2476:
    cp $50
    jr nz, jr_000_24b8

    inc hl
    ldh a, [rIE]
    res 1, a
    ldh [rIE], a
    ld a, $d7
    ldh [hSamusYPixel], a
    ld a, $78
    ldh [hSamusXPixel], a
    ld a, $c0
    ldh [hCameraYPixel], a
    ld a, $80
    ldh [hCameraXPixel], a
    ld a, $f0
    ldh [$b1], a
    ld a, $40
    ldh [$b2], a
    ld a, $00
    ldh [$b3], a
    ld a, $9c
    ldh [$b4], a
    ld a, $14
    ldh [$b5], a
    ld a, $00
    ldh [$b6], a
    ld a, $05
    ld [$d065], a
    call Call_000_27ba
    xor a
    ld [$c436], a
    jp Jump_000_26d1


jr_000_24b8:
    cp $60
    jr nz, jr_000_24ce

    inc hl
    ld a, [hl+]
    ld [acidDamageValue], a
    ld [$d81f], a
    ld a, [hl+]
    ld [spikeDamageValue], a
    ld [$d820], a
    jp Jump_000_26d1


jr_000_24ce:
    cp $70
    jr nz, jr_000_250a

    inc hl
    push hl
    xor a
    ld [$d08b], a
    ld a, $88
    ldh [rWY], a
    ld a, $07
    ldh [rWX], a
    ldh a, [rIE]
    res 1, a
    ldh [rIE], a
    ld a, $f0
    ldh [$b1], a
    ld a, $40
    ldh [$b2], a
    ld a, $00
    ldh [$b3], a
    ld a, $9c
    ldh [$b4], a
    ld a, $14
    ldh [$b5], a
    ld a, $00
    ldh [$b6], a
    ld a, $05
    ld [$d065], a
    call Call_000_27ba
    pop hl
    jp Jump_000_26d1


jr_000_250a:
    cp $80
    jr nz, jr_000_2540

    xor a
    ld [$d03b], a
    ld [$d03c], a
    ldh [hOamBufferIndex], a
    ld [$d0a6], a
    ld a, $02
    ld [$cedc], a
    push hl
    call Call_000_3eca
    pop hl
    call waitOneFrame
    call OAM_DMA
    call Call_000_2887
    ld a, $01
    ld [$c458], a
    ld a, $11
    ld [$d08b], a
    ldh a, [rIE]
    set 1, a
    ldh [rIE], a
    jp Jump_000_26d1


jr_000_2540:
    cp $90
    jr nz, jr_000_255d

    inc hl
    ld a, [metroidCountReal]
    ld b, a
    ld a, [hl+]
    cp b
    jr nc, jr_000_2552

    inc hl
    inc hl
    jp Jump_000_26d1


jr_000_2552:
    ld a, [hl+]
    ld [$d08e], a
    ld a, [hl]
    ld [$d08f], a
    jp Jump_000_239c


jr_000_255d:
    cp $a0
    jr nz, jr_000_259e

    inc hl
    push hl
    call waitOneFrame
    call waitOneFrame
    call waitOneFrame
    call waitOneFrame
    ld a, $2f
    ld [countdownTimerLow], a

jr_000_2574:
    ld hl, $259b
    ld a, [countdownTimerLow]
    and $f0
    swap a
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    ld [$d07e], a
    ld [$d07f], a
    call waitOneFrame
    ld a, [countdownTimerLow]
    cp $0e
    jr nc, jr_000_2574

    pop hl
    xor a
    ld [countdownTimerLow], a
    jp Jump_000_26d1


    db $ff, $fb, $e7

jr_000_259e:
    cp $c0
    jr nz, jr_000_2614

    ld a, [$cedf]
    cp $0e
    jr z, jr_000_25e4

    ld a, [hl+]
    and $0f
    cp $0a
    jr z, jr_000_25d0

    ld [$cedc], a
    ld [$d092], a
    cp $0b
    jr nz, jr_000_25c6

    ld a, $ff
    ld [$d0a6], a
    xor a
    ld [$d0a5], a
    jp Jump_000_26d1


jr_000_25c6:
    xor a
    ld [$d0a5], a
    ld [$d0a6], a
    jp Jump_000_26d1


jr_000_25d0:
    ld a, $ff
    ld [$cedc], a
    ld [$d092], a
    xor a
    ld [$d0a5], a
    ld a, $ff
    ld [$d0a6], a
    jp Jump_000_26d1


jr_000_25e4:
    ld a, [hl+]
    and $0f
    cp $0a
    jr z, jr_000_2601

    ld [$d0a5], a
    cp $0b
    jr nz, jr_000_25fa

    ld a, $ff
    ld [$d0a6], a
    jp Jump_000_26d1


jr_000_25fa:
    xor a
    ld [$d0a6], a
    jp Jump_000_26d1


jr_000_2601:
    ld a, $ff
    ld [$d0a5], a
    ld [$d0a6], a
    jp Jump_000_26d1


    inc b
    dec b
    ld b, $07
    ld [$1009], sp
    ld [de], a

jr_000_2614:
    cp $d0
    jp nz, Jump_000_26d1

    ; Load item graphics
    ld a, BANK(gfx_items)
    ld [bankRegMirror], a
    ld [$d065], a
    ld [rMBC_BANK_REG], a
    ld a, [hl]
    push hl
    dec a
    and $0f
    swap a
    ld e, a
    ld d, $00
    sla e
    rl d
    sla e
    rl d
    ld hl, gfx_items
    add hl, de
    ld a, l
    ldh [$b1], a
    ld a, h
    ldh [$b2], a
    ld a, $40
    ldh [$b3], a
    ld a, $8b
    ldh [$b4], a
    ld a, $40
    ldh [$b5], a
    ld a, $00
    ldh [$b6], a
    call Call_000_27ba
	; Load item orb
    ld a, LOW(gfx_itemOrb)
    ldh [$b1], a
    ld a, HIGH(gfx_itemOrb)
    ldh [$b2], a
    ld a, $00
    ldh [$b3], a
    ld a, $8b
    ldh [$b4], a
    ld a, $40
    ldh [$b5], a
    ld a, $00
    ldh [$b6], a
    call Call_000_27ba
	; Load item font text
    ld a, BANK(gfx_itemFont)
    ld [bankRegMirror], a
    ld [$d065], a
    ld [rMBC_BANK_REG], a
    ld a, LOW(gfx_itemFont) ;$34
    ldh [$b1], a
    ld a, HIGH(gfx_itemFont) ;$6c
    ldh [$b2], a
	; VRAM Dest
    ld a, $00
    ldh [$b3], a
    ld a, $8c
    ldh [$b4], a
	; Write length
    ld a, $30
    ldh [$b5], a
    ld a, $02
    ldh [$b6], a
    call Call_000_27ba

    pop hl
    ld a, $01
    ld [bankRegMirror], a
    ld [$d065], a
    ld [rMBC_BANK_REG], a
    ld a, [hl+]
    push hl
    and $0f
    ld e, a
    ld d, $00
    sla e
    rl d
    ld hl, $58f1
    add hl, de
    ld a, [hl+]
    ld e, a
    ld a, [hl]
    ld h, a
    ld a, e
    ld l, a
    ld a, l
    ldh [$b1], a
    ld a, h
    ldh [$b2], a
    ld a, $20
    ldh [$b3], a
    ld a, $9c
    ldh [$b4], a
    ld a, $10
    ldh [$b5], a
    ld a, $00
    ldh [$b6], a
    call Call_000_27ba
    pop hl
    jr jr_000_26d1

Jump_000_26d1:
jr_000_26d1:
    call waitOneFrame
    jp Jump_000_23e1


Jump_000_26d7:
    ld a, [$c458]
    ld [$c44b], a
    xor a
    ld [$d08e], a
    ld [$d08f], a
    ld [$c458], a
    ld [$d0a8], a
    ret


Call_000_26eb:
    ld a, [hl+]
    and $0f
    ld b, a
    cp $01
    jr z, jr_000_271c

    ld a, [hl+]
    ld [bankRegMirror], a
    ld [$d065], a
    ld [rMBC_BANK_REG], a
    ld a, [hl+]
    ldh [$b1], a
    ld [$d808], a
    ld a, [hl+]
    ldh [$b2], a
    ld [$d809], a
    ld a, $00
    ldh [$b3], a
    ld a, $8b
    ldh [$b4], a
    ld a, $00
    ldh [$b5], a
    ld a, $04
    ldh [$b6], a
    jp Jump_000_27ba


jr_000_271c:
    ld a, [hl+]
    ld [bankRegMirror], a
    ld [$d065], a
    ld [$d80a], a
    ld [rMBC_BANK_REG], a
    ld a, [hl+]
    ldh [$b1], a
    ld [$d80b], a
    ld a, [hl+]
    ldh [$b2], a
    ld [$d80c], a
    ld a, $00
    ldh [$b3], a
    ld a, $90
    ldh [$b4], a
    ld a, $00
    ldh [$b5], a
    ld a, $08
    ldh [$b6], a
    jr jr_000_27ba

Call_000_2747:
    ld a, [hl+]
    and $0f
    ld b, a
    cp $01
    jr z, jr_000_2771

    cp $02
    jr z, jr_000_2798

Call_000_2753:
    ld a, [hl+]
    ld [bankRegMirror], a
    ld [$d065], a
    ld [rMBC_BANK_REG], a
    ld a, [hl+]
    ldh [$b1], a
    ld a, [hl+]
    ldh [$b2], a
    ld a, [hl+]
    ldh [$b3], a
    ld a, [hl+]
    ldh [$b4], a
    ld a, [hl+]
    ldh [$b5], a
    ld a, [hl+]
    ldh [$b6], a
    jr jr_000_27ba

jr_000_2771:
    ld a, [hl+]
    ld [bankRegMirror], a
    ld [$d065], a
    ld [$d80a], a
    ld [rMBC_BANK_REG], a
    ld a, [hl+]
    ldh [$b1], a
    ld [$d80b], a
    ld a, [hl+]
    ldh [$b2], a
    ld [$d80c], a
    ld a, [hl+]
    ldh [$b3], a
    ld a, [hl+]
    ldh [$b4], a
    ld a, [hl+]
    ldh [$b5], a
    ld a, [hl+]
    ldh [$b6], a
    jr jr_000_27ba

jr_000_2798:
    ld a, [hl+]
    ld [bankRegMirror], a
    ld [$d065], a
    ld [rMBC_BANK_REG], a
    ld a, [hl+]
    ldh [$b1], a
    ld [$d808], a
    ld a, [hl+]
    ldh [$b2], a
    ld [$d809], a
    ld a, [hl+]
    ldh [$b3], a
    ld a, [hl+]
    ldh [$b4], a
    ld a, [hl+]
    ldh [$b5], a
    ld a, [hl+]
    ldh [$b6], a

Call_000_27ba:
Jump_000_27ba:
jr_000_27ba:
    ld a, $ff
    ld [$d047], a

jr_000_27bf:
    ld a, [$d08c]
    and a
    jr z, jr_000_27d9

    call Call_000_3e93
    call Call_000_05de
    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call $4b2c
    call Call_000_3e88

jr_000_27d9:
    call waitOneFrame
    ld a, [$d047]
    and a
    jr nz, jr_000_27bf

    ret


Call_000_27e3:
    ld a, [hl+]
    ld [bankRegMirror], a
    ld [$d065], a
    ld [rMBC_BANK_REG], a
    ld a, [hl+]
    ldh [$b1], a
    ld a, [hl+]
    ldh [$b2], a
    ld a, [hl+]
    ldh [$b3], a
    ld a, [hl+]
    ldh [$b4], a
    ld a, [hl+]
    ldh [$b5], a
    ld a, [hl+]
    ldh [$b6], a
    ld a, $ff
    ld [$d047], a

jr_000_2804:
    ld a, $80
    ldh [rWY], a
    call Call_000_3e93
    call Call_000_05de
    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call $4b2c
    call Call_000_3e88
    call waitOneFrame
    ldh a, [$b4]
    cp $85
    jr c, jr_000_2804

    xor a
    ld [$d08c], a
    ret


Call_000_282a:
    ld a, BANK(metatilePointerTable)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld a, [hl+]
    push hl
    and $0f
    sla a
    ld e, a
    ld d, $00
    ld hl, metatilePointerTable
    add hl, de
    ld a, [hl+]
    ld [$d80d], a
    ld b, a
    ld a, [hl+]
    ld [$d80e], a
    ld h, a
    ld a, b
    ld l, a
    ld de, $da00

jr_000_284e:
    ld a, [hl+]
    ld [de], a
    inc de
    ld a, d
    cp $dc
    jr nz, jr_000_284e

    jp Jump_000_2918


Call_000_2859:
    ld a, BANK(collisionPointerTable)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld a, [hl+]
    push hl
    and $0f
    sla a
    ld e, a
    ld d, $00
    ld hl, collisionPointerTable
    add hl, de
    ld a, [hl+]
    ld [$d80f], a
    ld b, a
    ld a, [hl+]
    ld [$d810], a
    ld h, a
    ld a, b
    ld l, a
    ld de, $dc00

jr_000_287d:
    ld a, [hl+]
    ld [de], a
    inc de
    ld a, d
    cp $dd
    jr nz, jr_000_287d

    pop hl
    ret


Call_000_2887:
    ld a, [hl+]
    and $0f
    ld [currentLevelBank], a
    ld [$d811], a
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld a, [hl+]
    ldh [hCameraYPixel], a
    sub $48
    ld [$c205], a
    ld a, [hl+]
    ldh [hCameraYScreen], a
    ld a, [hl+]
    ldh [hCameraXPixel], a
    sub $50
    ld [$c206], a
    ld a, [hl+]
    ldh [hCameraXScreen], a
    ld a, [hl+]
    ldh [hSamusYPixel], a
    ld a, [hl+]
    ldh [hSamusYScreen], a
    ld a, [hl+]
    ldh [hSamusXPixel], a
    ld a, [hl+]
    ldh [hSamusXScreen], a
    push hl
    call Call_000_039c
    call Call_000_0673
    ld a, $03
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call $6d4a
    ldh a, [hCameraXPixel]
    ld b, a
    ldh a, [hSamusXPixel]
    sub b
    add $60
    ld [$d03c], a
    ldh a, [hCameraYPixel]
    ld b, a
    ldh a, [hSamusYPixel]
    sub b
    add $62
    ld [$d03b], a
    ld a, $e3
    ldh [rLCDC], a
    xor a
    ld [$d00e], a
    ld [$c205], a
    ldh [rSCY], a
    ld a, [$d07e]
    cp $93
    jr z, jr_000_28f9

    ld a, $2f
    ld [$d09b], a

jr_000_28f9:
    pop hl
    ret


Call_000_28fb:
    ld a, [hl+]
    and $0f
    ld [currentLevelBank], a
    ld [$d811], a
    ld a, [hl]
    swap a
    and $0f
    ldh [hCameraYScreen], a
    ldh [hSamusYScreen], a
    ld a, [hl+]
    and $0f
    ldh [hCameraXScreen], a
    ldh [hSamusXScreen], a
    push hl
    call waitOneFrame

Jump_000_2918:
    ld a, [$d00e]
    cp $01
    jr z, jr_000_2939

    ld a, [$d00e]
    cp $02
    jp z, Jump_000_29c4

    ld a, [$d00e]
    cp $04
    jp z, Jump_000_2b04

    ld a, [$d00e]
    cp $08
    jp z, Jump_000_2a4f

    pop hl
    ret


jr_000_2939:
    ld a, [currentLevelBank]
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld a, $00
    ldh [$af], a
    ld a, $de
    ldh [$b0], a
    ld a, $ff
    ld [$d04c], a
    ldh a, [hCameraXPixel]
    add $50
    ldh [$ce], a
    ldh a, [hCameraXScreen]
    adc $00
    and $0f
    ldh [$cf], a
    ldh a, [hCameraYPixel]
    sub $74
    ldh [$cc], a
    ldh a, [hCameraYScreen]
    sbc $00
    and $0f
    ldh [$cd], a
    call Call_000_07e4
    call waitOneFrame
    ld a, [currentLevelBank]
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld a, $00
    ldh [$af], a
    ld a, $de
    ldh [$b0], a
    ld a, $ff
    ld [$d04c], a
    ldh a, [hCameraXPixel]
    add $60
    ldh [$ce], a
    ldh a, [hCameraXScreen]
    adc $00
    and $0f
    ldh [$cf], a
    call Call_000_07e4
    call waitOneFrame
    ld a, [currentLevelBank]
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld a, $00
    ldh [$af], a
    ld a, $de
    ldh [$b0], a
    ld a, $ff
    ld [$d04c], a
    ldh a, [hCameraXPixel]
    add $70
    ldh [$ce], a
    ldh a, [hCameraXScreen]
    adc $00
    and $0f
    ldh [$cf], a
    call Call_000_07e4
    pop hl
    ret


Jump_000_29c4:
    ld a, [currentLevelBank]
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld a, $00
    ldh [$af], a
    ld a, $de
    ldh [$b0], a
    ld a, $ff
    ld [$d04c], a
    ldh a, [hCameraXPixel]
    sub $60
    ldh [$ce], a
    ldh a, [hCameraXScreen]
    sbc $00
    and $0f
    ldh [$cf], a
    ldh a, [hCameraYPixel]
    sub $74
    ldh [$cc], a
    ldh a, [hCameraYScreen]
    sbc $00
    and $0f
    ldh [$cd], a
    call Call_000_07e4
    call waitOneFrame
    ld a, [currentLevelBank]
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld a, $00
    ldh [$af], a
    ld a, $de
    ldh [$b0], a
    ld a, $ff
    ld [$d04c], a
    ldh a, [hCameraXPixel]
    sub $70
    ldh [$ce], a
    ldh a, [hCameraXScreen]
    sbc $00
    and $0f
    ldh [$cf], a
    call Call_000_07e4
    call waitOneFrame
    ld a, [currentLevelBank]
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld a, $00
    ldh [$af], a
    ld a, $de
    ldh [$b0], a
    ld a, $ff
    ld [$d04c], a
    ldh a, [hCameraXPixel]
    sub $80
    ldh [$ce], a
    ldh a, [hCameraXScreen]
    sbc $00
    and $0f
    ldh [$cf], a
    call Call_000_07e4
    pop hl
    ret


Jump_000_2a4f:
    ld a, [currentLevelBank]
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld a, $00
    ldh [$af], a
    ld a, $de
    ldh [$b0], a
    ld a, $ff
    ld [$d04c], a
    ldh a, [hCameraXPixel]
    sub $80
    ldh [$ce], a
    ldh a, [hCameraXScreen]
    sbc $00
    and $0f
    ldh [$cf], a
    ldh a, [hCameraYPixel]
    add $78
    ldh [$cc], a
    ldh a, [hCameraYScreen]
    adc $00
    and $0f
    ldh [$cd], a
    call Call_000_0788
    call waitOneFrame
    ld a, [currentLevelBank]
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld a, $00
    ldh [$af], a
    ld a, $de
    ldh [$b0], a
    ld a, $ff
    ld [$d04c], a
    ldh a, [hCameraYPixel]
    add $68
    ldh [$cc], a
    ldh a, [hCameraYScreen]
    adc $00
    and $0f
    ldh [$cd], a
    call Call_000_0788
    call waitOneFrame
    ld a, [currentLevelBank]
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld a, $00
    ldh [$af], a
    ld a, $de
    ldh [$b0], a
    ld a, $ff
    ld [$d04c], a
    ldh a, [hCameraYPixel]
    add $58
    ldh [$cc], a
    ldh a, [hCameraYScreen]
    adc $00
    and $0f
    ldh [$cd], a
    call Call_000_0788
    call waitOneFrame
    ld a, [currentLevelBank]
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld a, $00
    ldh [$af], a
    ld a, $de
    ldh [$b0], a
    ld a, $ff
    ld [$d04c], a
    ldh a, [hCameraYPixel]
    add $48
    ldh [$cc], a
    ldh a, [hCameraYScreen]
    adc $00
    and $0f
    ldh [$cd], a
    call Call_000_0788
    pop hl
    ret


Jump_000_2b04:
    ld a, [currentLevelBank]
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld a, $00
    ldh [$af], a
    ld a, $de
    ldh [$b0], a
    ld a, $ff
    ld [$d04c], a
    ldh a, [hCameraXPixel]
    sub $80
    ldh [$ce], a
    ldh a, [hCameraXScreen]
    sbc $00
    and $0f
    ldh [$cf], a
    ldh a, [hCameraYPixel]
    sub $78
    ldh [$cc], a
    ldh a, [hCameraYScreen]
    sbc $00
    and $0f
    ldh [$cd], a
    call Call_000_0788
    call waitOneFrame
    ld a, [currentLevelBank]
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld a, $00
    ldh [$af], a
    ld a, $de
    ldh [$b0], a
    ld a, $ff
    ld [$d04c], a
    ldh a, [hCameraYPixel]
    sub $68
    ldh [$cc], a
    ldh a, [hCameraYScreen]
    sbc $00
    and $0f
    ldh [$cd], a
    call Call_000_0788
    call waitOneFrame
    ld a, [currentLevelBank]
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld a, $00
    ldh [$af], a
    ld a, $de
    ldh [$b0], a
    ld a, $ff
    ld [$d04c], a
    ldh a, [hCameraYPixel]
    sub $58
    ldh [$cc], a
    ldh a, [hCameraYScreen]
    sbc $00
    and $0f
    ldh [$cd], a
    call Call_000_0788
    pop hl
    ret


Jump_000_2b8f:
    ld a, [$de01]
    and a
    jr z, jr_000_2be5

    ld a, [currentLevelBank]
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call Call_000_08cf
    jr jr_000_2be5

Jump_000_2ba3:
    ld a, [$d08c]
    and a
    jp nz, Jump_000_2bf4

    ld a, [$d065]
    ld [rMBC_BANK_REG], a
    ldh a, [$b5]
    ld c, a
    ldh a, [$b6]
    ld b, a
    ldh a, [$b1]
    ld l, a
    ldh a, [$b2]
    ld h, a
    ldh a, [$b3]
    ld e, a
    ldh a, [$b4]
    ld d, a

jr_000_2bc2:
    ld a, [hl+]
    ld [de], a
    inc de
    dec bc
    ld a, c
    and $3f
    jr nz, jr_000_2bc2

    ld a, c
    ldh [$b5], a
    ld a, b
    ldh [$b6], a
    ld a, l
    ldh [$b1], a
    ld a, h
    ldh [$b2], a
    ld a, e
    ldh [$b3], a
    ld a, d
    ldh [$b4], a
    ld a, b
    or c
    jr nz, jr_000_2be5

    xor a
    ld [$d047], a

jr_000_2be5:
    ld a, $01
    ldh [$82], a
    ld a, [bankRegMirror]
    ld [rMBC_BANK_REG], a
    pop hl
    pop de
    pop bc
    pop af
    reti


Jump_000_2bf4:
    ldh a, [$97]
    and $01
    jr nz, jr_000_2c42

    ld a, [$d065]
    ld [rMBC_BANK_REG], a
    ldh a, [$b3]
    ld l, a
    ldh a, [$b4]
    ld h, a
    ld de, $0010

jr_000_2c09:
    push hl
    ld de, $ce20
    add hl, de
    ld e, l
    ld d, h
    pop hl
    ld a, [de]
    ld [hl], a
    ld a, l
    add $10
    ld l, a
    ld a, h
    adc $00
    ld h, a
    ld a, l
    and $f0
    jr nz, jr_000_2c09

    ld a, l
    sub $ff
    ld l, a
    ld a, h
    sbc $00
    ld h, a
    ld a, l
    cp $10
    jr nz, jr_000_2c34

    add $f0
    ld l, a
    ld a, h
    adc $00
    ld h, a

jr_000_2c34:
    ld a, l
    ldh [$b3], a
    ld a, h
    ldh [$b4], a
    cp $85
    jr nz, jr_000_2c42

    xor a
    ld [$d059], a

jr_000_2c42:
    ld a, [$c205]
    ldh [rSCY], a
    ld a, [$c206]
    ldh [rSCX], a
    call OAM_DMA
    ld a, [bankRegMirror]
    ld [rMBC_BANK_REG], a
    ld a, $01
    ldh [$82], a
    pop hl
    pop de
    pop bc
    pop af
reti


waitOneFrame: ; 00:2C5E
    push hl
    call handleAudio
    pop hl
    db $76 ; halt

jr_000_2c64:
    ldh a, [$82]
    and a
    jr z, jr_000_2c64

    ldh a, [$97]
    inc a
    ldh [$97], a
    xor a
    ldh [$82], a
    ld a, $c0
    ldh [$8c], a
    xor a
    ldh [hOamBufferIndex], a
    ret


Call_000_2c79:
    ldh a, [hInputRisingEdge]
    cp PADF_START
    ret nz

    ld a, [$d08b]
    cp $11
    ret z

    ld a, [samusPose]
    cp $13
    ret z

    ld a, [$d00e]
    and a
    ret nz

    ld a, [$d07d]
    and a
    ret nz

    ld hl, $203b
    ld a, [metroidCountReal]
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    ld [$d0a7], a
    ld a, [earthquakeTimer]
    and a
    jr nz, jr_000_2cae

    ld a, [$d083]
    and a
    jr z, jr_000_2cb2

jr_000_2cae:
    xor a
    ld [$d0a7], a

jr_000_2cb2:
    ld a, [$d0a0]
    and a
    jr z, jr_000_2cbe

    xor a
    ldh [hOamBufferIndex], a
    call Call_000_3e88

jr_000_2cbe:
    xor a
    ld [$d046], a
    ld [$d011], a
    ld hl, $c002

jr_000_2cc8:
    ld a, [hl]
    and $9a
    cp $9a
    jr z, jr_000_2cd9

    ld a, l
    add $04
    ld l, a
    cp $a0
    jr c, jr_000_2cc8

    jr jr_000_2ce3

jr_000_2cd9:
    ld de, $0004
    ld a, $36
    ld [hl], a
    add hl, de
    ld a, $0f
    ld [hl], a

jr_000_2ce3:
    ld a, $01
    ld [$cfc7], a
    ld a, $08
    ldh [gameMode], a
    ret

gameMode_Paused:
    ld b, $e7
    ldh a, [$97]
    bit 4, a
    jr z, jr_000_2cf7

    ld b, $93

jr_000_2cf7:
    ld a, b
    ld [$d07e], a
    ld [$d07f], a
    ld a, [$d0a0]
    and a
    jr nz, jr_000_2d1b

    ldh a, [hInputRisingEdge]
    bit PADB_START, a
    ret z

    ld a, $93
    ld [$d07e], a
    ld [$d07f], a
    ld a, $02
    ld [$cfc7], a
    ld a, $04
    ldh [gameMode], a
    ret


jr_000_2d1b:
    call Call_000_3e9e
    ldh a, [hInputRisingEdge]
    cp PADF_START
    jr nz, jr_000_2d39

    ld a, $93
    ld [$d07e], a
    ld [$d07f], a
    call Call_000_3e88
    ld a, $02
    ld [$cfc7], a
    ld a, $04
    ldh [gameMode], a
    ret


jr_000_2d39:
    ldh a, [hInputRisingEdge]
    bit PADB_RIGHT, a
    jr z, jr_000_2d7a

    ldh a, [hInputPressed]
    bit PADB_B, a
    jr nz, jr_000_2d50

    ld a, [$d046]
    dec a
    and $07
    ld [$d046], a
    jr jr_000_2d7a

jr_000_2d50:
    bit 0, a
    jr z, jr_000_2d68

    ld a, [metroidCountReal]
    sub $01
    daa
    ld [metroidCountReal], a
    ld a, [$d09a]
    sub $01
    daa
    ld [$d09a], a
    jr jr_000_2d7a

jr_000_2d68:
    ld a, [$d050]
    and a
    jr z, jr_000_2d7a

    dec a
    ld [$d050], a
    ld [$d052], a
    ld a, $99
    ld [$d051], a

jr_000_2d7a:
    ldh a, [hInputRisingEdge]
    bit PADB_LEFT, a
    jr z, jr_000_2dbc

    ldh a, [hInputPressed]
    bit PADB_B, a
    jr nz, jr_000_2d91

    ld a, [$d046]
    inc a
    and $07
    ld [$d046], a
    jr jr_000_2dbc

jr_000_2d91:
    bit 0, a
    jr z, jr_000_2da9

    ld a, [metroidCountReal]
    add $01
    daa
    ld [metroidCountReal], a
    ld a, [$d09a]
    add $01
    daa
    ld [$d09a], a
    jr jr_000_2dbc

jr_000_2da9:
    ld a, [$d050]
    cp $05
    jr z, jr_000_2dbc

    inc a
    ld [$d050], a
    ld [$d052], a
    ld a, $99
    ld [$d051], a

jr_000_2dbc:
    ldh a, [hInputRisingEdge]
    bit PADB_A, a
    jr z, jr_000_2dd7

    ld b, $01
    ld a, [$d046]

jr_000_2dc7:
    dec a
    cp $ff
    jr z, jr_000_2dd0

    sla b
    jr jr_000_2dc7

jr_000_2dd0:
    ld a, [samusItems]
    xor b
    ld [samusItems], a

jr_000_2dd7:
    ldh a, [hInputRisingEdge]
    bit PADB_UP, a
    jr z, jr_000_2e07

    ldh a, [hInputPressed]
    bit PADB_B, a
    jr nz, jr_000_2def

    ld a, [$d04d]
    inc a
    ld [$d04d], a
    ld [$d055], a
    jr jr_000_2e07

jr_000_2def:
    ld a, [$d081]
    add $10
    daa
    ld [$d081], a
    ld [$d053], a
    ld a, [$d082]
    adc $00
    daa
    ld [$d082], a
    ld [$d054], a

jr_000_2e07:
    ldh a, [hInputRisingEdge]
    bit PADB_DOWN, a
    jr z, jr_000_2e31

    ldh a, [hInputPressed]
    bit PADB_B, a
    jr nz, jr_000_2e1f

    ld a, [$d04d]
    dec a
    ld [$d04d], a
    ld [$d055], a
    jr jr_000_2e31

jr_000_2e1f:
    ld a, [$d053]
    sub $10
    daa
    ld [$d053], a
    ld a, [$d054]
    sbc $00
    daa
    ld [$d054], a

jr_000_2e31:
    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld a, $58
    ldh [hSpriteYPixel], a
    ld a, [$d046]
    swap a
    srl a
    xor $ff
    add $69
    ldh [hSpriteXPixel], a
    ld a, [$d046]
    call $4b09
    ld a, $54
    ldh [hSpriteYPixel], a
    ld a, $36
    ldh [hSpriteId], a
    ld a, $34
    ldh [hSpriteXPixel], a
    ld a, [samusItems]
    bit itemBit_UNUSED, a
    call nz, $4b62
    ld a, $3c
    ldh [hSpriteXPixel], a
    ld a, [samusItems]
    bit itemBit_varia, a
    call nz, $4b62
    ld a, $44
    ldh [hSpriteXPixel], a
    ld a, [samusItems]
    bit itemBit_spider, a
    call nz, $4b62
    ld a, $4c
    ldh [hSpriteXPixel], a
    ld a, [samusItems]
    bit itemBit_spring, a
    call nz, $4b62
    ld a, $54
    ldh [hSpriteXPixel], a
    ld a, [samusItems]
    bit itemBit_space, a
    call nz, $4b62
    ld a, $5c
    ldh [hSpriteXPixel], a
    ld a, [samusItems]
    bit itemBit_screw, a
    call nz, $4b62
    ld a, $64
    ldh [hSpriteXPixel], a
    ld a, [samusItems]
    bit itemBit_hiJump, a
    call nz, $4b62
    ld a, $6c
    ldh [hSpriteXPixel], a
    ld a, [samusItems]
    bit itemBit_bomb, a
    call nz, $4b62
    ld a, $68
    ldh [hSpriteYPixel], a
    ld a, $50
    ldh [hSpriteXPixel], a
    ld a, [$d04d]
    call $4afc
    ldh a, [hOamBufferIndex]
    ld [$d06e], a
    ldh a, [hInputRisingEdge]
    cp PADF_SELECT
    ret nz

    ldh a, [hInputPressed]
    cp PADF_SELECT
    ret nz

    ld a, [samusPose]
    and a
    jr z, jr_000_2ede

    cp $05
    ret nz

jr_000_2ede:
    ld a, $09
    ldh [gameMode], a
    ret


Call_000_2ee3:
    ld a, [$c422]
    cp $01
    ret nz

    xor a
    ld [$c422], a
    ld a, [$d04f]
    and a
    ret nz

    ld a, [$c424]
    call Call_000_2f57
    ld a, $33
    ld [$d04f], a
    ld a, [samusPose]
    res 7, a
    ld e, a
    ld d, $00
    ld hl, $208b
    add hl, de
    ld a, [hl]
    ld [samusPose], a
    ld a, [$c423]
    ld [$d00f], a
    ld a, [$d08b]
    cp $11
    jr nz, jr_000_2f1f

    ld a, $01
    ld [$d00f], a

jr_000_2f1f:
    ld a, $40
    ld [$d026], a
    xor a
    ld [$d049], a
    ret


Call_000_2f29:
    ldh a, [$97]
    and $07
    ret nz

    ld a, $07
    ld [$ced5], a
    ldh a, [$97]
    and $0f
    ret nz

    ld b, $02
    jr jr_000_2f60

Call_000_2f3c:
    ld b, $03
    ldh a, [$97]
    and $07
    ret nz

    ld a, $07
    ld [$ced5], a
    jr jr_000_2f60

Call_000_2f4a:
    ld b, a
    ldh a, [$97]
    and $0f
    ret nz

    ld a, $07
    ld [$ced5], a
    jr jr_000_2f60

Call_000_2f57:
    ld b, a
    cp $60
    ret nc

    ld a, $06
    ld [$ced5], a

jr_000_2f60:
    ld a, [samusItems]
    bit itemBit_varia, a
    jr z, jr_000_2f69

    srl b

jr_000_2f69:
    ld a, [$d051]
    sub b
    daa
    ld [$d051], a
    ld a, [$d052]
    sbc $00
    daa
    ld [$d052], a
    cp $99
    jr nz, jr_000_2f85

    xor a
    ld [$d051], a
    ld [$d052], a

jr_000_2f85:
    ret


    ld a, [$d08b]
    cp $11
    jr nz, jr_000_2fa1

    call Call_000_3e93
    call Call_000_3e9e
    ld a, $03
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call $6e36
    call Call_000_3e88

jr_000_2fa1:
    ret


Call_000_2fa2:
    call Call_000_2390
    ld a, $0b
    ld [$ced5], a
    call waitOneFrame
    call Call_000_3ebf
    ld a, $20
    ld [$d059], a
    xor a
    ld [$d05a], a
    ld a, $80
    ld [$d05b], a
    ld a, $01
    ld [$d063], a
    ld a, $06
    ldh [gameMode], a
    ret


    ld a, $a0
    ld [$d02c], a
    ld a, $80
    ld [samusPose], a
    ld a, $20
    ld [$d059], a
    xor a
    ld [$d05a], a
    ld a, $80
    ld [$d05b], a
    ret


Jump_000_2fe1:
    ld a, [$d063]
    and a
    jr z, jr_000_3062

    ldh a, [$97]
    and $03
    jr nz, jr_000_3019

    ld hl, twoTiles
    ld a, [$d059]
    dec a
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    ld l, a
    ld h, $80
    ld de, $0020

jr_000_2fff:
    xor a
    ld [hl], a
    add hl, de
    ld a, h
    cp $88
    jr nz, jr_000_2fff

    ld a, [$d059]
    dec a
    ld [$d059], a
    jr nz, jr_000_3019

    ld a, $ff
    ld [$d063], a
    ld a, $05
    ldh [gameMode], a

jr_000_3019:
    ld a, [$c205]
    ldh [rSCY], a
    ld a, [$c206]
    ldh [rSCX], a
    call OAM_DMA
    ld a, $03
    ld [rMBC_BANK_REG], a
    ld a, [$d08b]
    cp $11
    call z, $7cf0
    ld a, [bankRegMirror]
    ld [rMBC_BANK_REG], a
    ld a, $01
    ldh [$82], a
    pop hl
    pop de
    pop bc
    pop af
    reti


twoTiles::
    db $00, $04, $08, $0c, $10, $14, $18, $1c, $01, $05, $09, $0d, $11, $15, $19, $1d
    db $02, $06, $0a, $0e, $12, $16, $1a, $1e, $03, $07, $0b, $0f, $13, $17, $1b, $1f

jr_000_3062:
    ldh a, [$97]
    and $01
    jr nz, jr_000_309f

    ld a, [$d05a]
    ld l, a
    ld a, [$d05b]
    ld h, a
    ld de, $0010

jr_000_3073:
    xor a
    ld [hl], a
    add hl, de
    ld a, l
    and $f0
    jr nz, jr_000_3073

    ld a, l
    sub $ff
    ld l, a
    ld a, h
    sbc $00
    ld h, a
    ld a, l
    cp $10
    jr nz, jr_000_308f

    add $f0
    ld l, a
    ld a, h
    adc $00
    ld h, a

jr_000_308f:
    ld a, l
    ld [$d05a], a
    ld a, h
    ld [$d05b], a
    cp $85
    jr nz, jr_000_309f

    xor a
    ld [$d059], a

jr_000_309f:
    ld a, [$c205]
    ldh [rSCY], a
    ld a, [$c206]
    ldh [rSCX], a
    call OAM_DMA
    ld a, [bankRegMirror]
    ld [rMBC_BANK_REG], a
    ld a, $01
    ldh [$82], a
    pop hl
    pop de
    pop bc
    pop af
    reti


    ldh a, [hSpriteYPixel]
    ldh [$98], a
    ldh a, [hSpriteXPixel]
    ldh [$99], a
    ld a, $03
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld hl, $c600

jr_000_30ce:
    ld a, [hl]
    and $0f
    jr nz, jr_000_30d8

    call Call_000_30ea
    jr c, jr_000_30e1

jr_000_30d8:
    ld de, $0020
    add hl, de
    ld a, h
    cp $c8
    jr nz, jr_000_30ce

jr_000_30e1:
    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ret


Call_000_30ea:
    push hl
    inc hl
    ld a, [hl+]
    cp $e0
    jp nc, Jump_000_31b2

    ldh [$b7], a
    ld a, [hl+]
    cp $e0
    jp nc, Jump_000_31b2

    ldh [$b8], a
    ld a, [hl+]
    ldh [$b9], a
    inc hl
    ld a, [hl+]
    ldh [$bf], a
    ldh a, [$b9]
    sla a
    ld e, a
    ld d, $00
    rl d
    ld hl, enemyHitboxPointers
    add hl, de
    ld a, [hl+]
    ld e, a
    ld a, [hl]
    ld h, a
    ld l, e
    ldh a, [$b7]
    ld b, a
    ldh a, [$bf]
    bit 6, a
    jr nz, jr_000_312c

    ld a, [hl+]
    add b
    sub $10
    ldh [$ba], a
    ld a, [hl+]
    add b
    add $10
    ldh [$bb], a
    jr jr_000_313a

jr_000_312c:
    ld a, [hl+]
    sub b
    cpl
    add $10
    ldh [$bb], a
    ld a, [hl+]
    sub b
    cpl
    sub $10
    ldh [$ba], a

jr_000_313a:
    ldh a, [$b8]
    ld b, a
    ldh a, [$bf]
    bit 5, a
    jr nz, jr_000_3151

    ld a, [hl+]
    add b
    sub $10
    ldh [$bc], a
    ld a, [hl+]
    add b
    add $10
    ldh [$bd], a
    jr jr_000_315f

jr_000_3151:
    ld a, [hl+]
    sub b
    cpl
    add $10
    ldh [$bd], a
    ld a, [hl+]
    sub b
    cpl
    sub $10
    ldh [$bc], a

jr_000_315f:
    ldh a, [$ba]
    ld b, a
    ldh a, [$bb]
    sub b
    ld c, a
    ldh a, [$98]
    sub b
    cp c
    jr nc, jr_000_31b2

    ldh a, [$bc]
    ld b, a
    ldh a, [$bd]
    sub b
    ld c, a
    ldh a, [$99]
    sub b
    cp c
    jr nc, jr_000_31b2

    ld a, $09
    ld [$d05d], a
    pop hl
    ld a, l
    ld [$d05e], a
    ld a, h
    ld [$d05f], a
    ld a, [$d090]
    cp $03
    jr nz, jr_000_3199

    ldh a, [$b9]
    cp $f1
    jr nz, jr_000_3199

    ld a, $04
    ld [$d090], a

jr_000_3199:
    ld a, [$d090]
    cp $06
    jr nz, jr_000_31b0

    ldh a, [$b9]
    cp $f3
    jr nz, jr_000_31b0

    ld a, $07
    ld [$d090], a
    ld a, $1c
    ld [samusPose], a

jr_000_31b0:
    scf
    ret


Jump_000_31b2:
jr_000_31b2:
    pop hl
    scf
    ccf
    ret


    ld a, [$c205]
    ld b, a
    ld a, [$c203]
    sub b
    ldh [$98], a
    ld a, [$c206]
    ld b, a
    ld a, [$c204]
    sub b
    ldh [$99], a
    ld a, $03
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld hl, $c600

jr_000_31d5:
    ld a, [hl]
    and $0f
    jr nz, jr_000_31df

    call Call_000_31f1
    jr c, jr_000_31e8

jr_000_31df:
    ld de, $0020
    add hl, de
    ld a, h
    cp $c8
    jr nz, jr_000_31d5

jr_000_31e8:
    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ret


Call_000_31f1:
    push hl
    inc hl
    ld a, [hl+]
    cp $e0
    jp nc, Jump_000_32a7

    ldh [$b7], a
    ld a, [hl+]
    cp $e0
    jp nc, Jump_000_32a7

    ldh [$b8], a
    ld a, [hl+]
    ldh [$b9], a
    inc hl
    ld a, [hl]
    ldh [$bf], a
    ldh a, [$b9]
    ld e, a
    ld d, $00
    ld hl, enemyDamageTable
    add hl, de
    ld a, [hl]
    and a
    jp z, Jump_000_32a7

    ldh a, [$b9]
    sla a
    ld e, a
    ld d, $00
    rl d
    ld hl, enemyHitboxPointers
    add hl, de
    ld a, [hl+]
    ld e, a
    ld a, [hl]
    ld h, a
    ld l, e
    ldh a, [$b7]
    ld b, a
    ldh a, [$bf]
    bit 6, a
    jr nz, jr_000_323d

    ld a, [hl+]
    add b
    ldh [$ba], a
    ld a, [hl+]
    add b
    ldh [$bb], a
    jr jr_000_3247

jr_000_323d:
    ld a, [hl+]
    sub b
    cpl
    ldh [$bb], a
    ld a, [hl+]
    sub b
    cpl
    ldh [$ba], a

jr_000_3247:
    ldh a, [$b8]
    ld b, a
    ldh a, [$bf]
    bit 5, a
    jr nz, jr_000_325a

    ld a, [hl+]
    add b
    ldh [$bc], a
    ld a, [hl+]
    add b
    ldh [$bd], a
    jr jr_000_3264

jr_000_325a:
    ld a, [hl+]
    sub b
    cpl
    ldh [$bd], a
    ld a, [hl+]
    sub b
    cpl
    ldh [$bc], a

jr_000_3264:
    ldh a, [$ba]
    ld b, a
    ldh a, [$bb]
    sub b
    ld c, a
    ldh a, [$98]
    sub b
    cp c
    jr nc, jr_000_32a7

    ldh a, [$bc]
    ld b, a
    ldh a, [$bd]
    sub b
    ld c, a
    ldh a, [$99]
    sub b
    cp c
    jr nc, jr_000_32a7

    ld a, [$d08d]
    ld [$d05d], a
    pop hl
    ld a, l
    ld [$d05e], a
    ld a, h
    ld [$d05f], a
    ld a, [$d012]
    ld [$d060], a
    ld a, [$d08d]
    cp $08
    jr nz, jr_000_32a5

    ldh a, [$b9]
    cp $f6
    jr nz, jr_000_32a5

    ld a, $10
    ld [$d090], a

jr_000_32a5:
    scf
    ret


Jump_000_32a7:
jr_000_32a7:
    pop hl
    scf
    ccf
    ret


Call_000_32ab:
    ld a, [samusPose]
    cp $18
    jp nc, Jump_000_3698

    ld a, [$d063]
    and a
    jp nz, Jump_000_3698

    ld a, [$d04f]
    and a
    jp nz, Jump_000_3698

    ld a, [$d05c]
    and a
    jp nz, Jump_000_3698

    ld a, [$d03c]
    ldh [$99], a
    jr jr_000_32f7

Call_000_32cf:
    ld a, [samusPose]
    cp $18
    jp nc, Jump_000_3698

    ld a, [$d063]
    and a
    jp nz, Jump_000_3698

    ld a, [$d059]
    and a
    jp nz, Jump_000_3698

    ld a, [$d04f]
    and a
    jp nz, Jump_000_3698

    ldh a, [hCameraXPixel]
    ld b, a
    ld a, [$c204]
    sub b
    add $50
    ldh [$99], a

jr_000_32f7:
    ldh a, [hCameraYPixel]
    ld b, a
    ldh a, [hSamusYPixel]
    sub b
    add $62
    ldh [$98], a
    ld a, $03 ; Bank with enemy data
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld a, $ff
    ld [$d05c], a
    ld hl, $c600

jr_000_3311:
    ld a, [hl]
    and $0f
    jr nz, jr_000_331a

    call Call_000_3324
    ret c

jr_000_331a:
    ld de, $0020
    add hl, de
    ld a, h
    cp $c8
    jr nz, jr_000_3311

    ret


Call_000_3324:
    push hl
    inc hl
    ld a, [hl+]
    cp $e0
    jp nc, Jump_000_3489

    ldh [$b7], a
    ld a, [hl+]
    cp $e0
    jp nc, Jump_000_3489

    ldh [$b8], a
    ld a, [hl+]
    ldh [$b9], a
    inc hl
    ld a, [hl+]
    ldh [$bf], a
    inc hl
    inc hl
    inc hl
    inc hl
    inc hl
    ld a, [hl]
    ldh [$be], a
    ldh a, [$b9]
    sla a
    ld e, a
    ld d, $00
    rl d
    ld hl, enemyHitboxPointers
    add hl, de
    ld a, [hl+]
    ld e, a
    ld a, [hl]
    ld h, a
    ld l, e
    ldh a, [$b7]
    ld b, a
    ldh a, [$bf]
    bit 6, a
    jr nz, jr_000_336e

    ld a, [hl+]
    add b
    sub $11
    ldh [$ba], a
    ld a, [hl+]
    add b
    sub $04
    ldh [$bb], a
    jr jr_000_337c

jr_000_336e:
    ld a, [hl+]
    sub b
    cpl
    sub $04
    ldh [$bb], a
    ld a, [hl+]
    sub b
    cpl
    sub $11
    ldh [$ba], a

jr_000_337c:
    ldh a, [$b8]
    ld b, a
    ldh a, [$bf]
    bit 5, a
    jr nz, jr_000_3393

    ld a, [hl+]
    add b
    sub $05
    ldh [$bc], a
    ld a, [hl+]
    add b
    add $05
    ldh [$bd], a
    jr jr_000_33a1

jr_000_3393:
    ld a, [hl+]
    sub b
    cpl
    add $05
    ldh [$bd], a
    ld a, [hl+]
    sub b
    cpl
    sub $05
    ldh [$bc], a

jr_000_33a1:
    ld a, [samusPose]
    and $7f
    ld e, a
    ld d, $00
    ld hl, $369b
    add hl, de
    ld a, [hl+]
    ld b, a
    ldh a, [$bb]
    sub b
    ldh [$bb], a
    ldh a, [$ba]
    ld b, a
    ldh a, [$bb]
    sub b
    ld c, a
    ldh a, [$98]
    sub b
    cp c
    jp nc, Jump_000_3489

    ld a, $01
    ld [$c423], a
    ldh a, [$bc]
    ld b, a
    ldh a, [$99]
    sub b
    ld c, a
    ldh a, [$bd]
    sub b
    ld d, a
    srl d
    sub c
    jp c, Jump_000_3489

    ld a, d
    cp c
    jr c, jr_000_33e1

    ld a, $ff
    ld [$c423], a

jr_000_33e1:
    ld a, [samusItems]
    bit itemBit_screw, a
    jr z, jr_000_3421

    ld a, [samusPose]
    cp $02
    jr z, jr_000_33f6

    ld a, [samusPose]
    cp $0a
    jr nz, jr_000_3421

jr_000_33f6:
    ldh a, [$be]
    and a
    jr z, jr_000_33ff

    bit 0, a
    jr z, jr_000_3426

jr_000_33ff:
    ldh a, [$b9]
    ld e, a
    ld d, $00
    ld hl, enemyDamageTable
    add hl, de
    ld a, [hl]
    cp $ff
    jr z, jr_000_3426

    ld [$c424], a
    pop hl
    ld a, $10
    ld [$d05d], a
    ld a, l
    ld [$d05e], a
    ld a, h
    ld [$d05f], a
    scf
    ccf
    ret


jr_000_3421:
    ldh a, [$be]
    and a
    jr z, jr_000_3448

jr_000_3426:
    pop hl
    ldh a, [$b9]
    cp $f7
    jr nz, jr_000_3446

    ld a, [samusPose]
    cp $05
    jr z, jr_000_343c

    cp $06
    jr z, jr_000_343c

    cp $08
    jr nz, jr_000_3446

jr_000_343c:
    ld a, $01
    ld [$d090], a
    ld a, $18
    ld [samusPose], a

jr_000_3446:
    scf
    ret


jr_000_3448:
    ldh a, [$b9]
    ld e, a
    ld d, $00
    ld hl, enemyDamageTable
    add hl, de
    ld a, [hl]
    cp $ff
    jr z, jr_000_3426

    cp $fe
    jr z, jr_000_3475

    and a
    jr z, jr_000_3478

    ld [$c424], a
    ld a, $01
    ld [$c422], a
    pop hl
    ld a, l
    ld [$d05e], a
    ld a, h
    ld [$d05f], a
    ld a, $20
    ld [$d05d], a
    scf
    ret


jr_000_3475:
    call Call_000_2f3c

jr_000_3478:
    pop hl
    ld a, l
    ld [$d05e], a
    ld a, h
    ld [$d05f], a
    ld a, $20
    ld [$d05d], a
    scf
    ccf
    ret


Jump_000_3489:
    pop hl
    scf
    ccf
    ret


Call_000_348d:
    ld a, [samusPose]
    cp $18
    jp nc, Jump_000_3698

    ld a, [$d063]
    and a
    jp nz, Jump_000_3698

    ld a, [$d04f]
    and a
    jp nz, Jump_000_3698

    ld a, [$d03b]
    add $12
    ldh [$98], a
    xor a
    ld [$c43a], a
    ldh a, [hCameraXPixel]
    ld b, a
    ldh a, [hSamusXPixel]
    sub b
    add $60
    ldh [$99], a
    ld a, $03
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld hl, $c600

jr_000_34c3:
    ld a, [hl]
    and $0f
    jr nz, jr_000_34e5

    call Call_000_3545
    jr nc, jr_000_34e5

    ld a, [$c424]
    dec a
    cp $fe
    jr c, jr_000_34e3

    ldh a, [$9a]
    ld b, a
    ldh a, [hSamusYPixel]
    sub b
    ldh [hSamusYPixel], a
    ldh a, [hSamusYScreen]
    sbc $00
    ldh [hSamusYScreen], a

jr_000_34e3:
    scf
    ret


jr_000_34e5:
    ld de, $0020
    add hl, de
    ld a, h
    cp $c8
    jr nz, jr_000_34c3

    ret


Call_000_34ef:
    ld a, [samusPose]
    cp $18
    jp nc, Jump_000_3698

    ld a, [$d063]
    and a
    jp nz, Jump_000_3698

    ld a, [$d04f]
    and a
    jp nz, Jump_000_3698

    ld a, [samusPose]
    and $7f
    ld e, a
    ld d, $00
    ld hl, $369b
    add hl, de
    ld a, [hl+]
    ld b, a
    ld a, [$d03b]
    add b
    ldh [$98], a
    xor a
    ld [$c43a], a
    ldh a, [hCameraXPixel]
    ld b, a
    ldh a, [hSamusXPixel]
    sub b
    add $60
    ldh [$99], a
    ld a, $03
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld hl, $c600

jr_000_3532:
    ld a, [hl]
    and $0f
    jr nz, jr_000_353b

    call Call_000_3545
    ret c

jr_000_353b:
    ld de, $0020
    add hl, de
    ld a, h
    cp $c8
    jr nz, jr_000_3532

    ret


Call_000_3545:
    push hl
    inc hl
    ld a, [hl+]
    cp $e0
    jp nc, Jump_000_3694

    ldh [$b7], a
    ld a, [hl+]
    cp $e0
    jp nc, Jump_000_3694

    ldh [$b8], a
    ld a, [hl+]
    ldh [$b9], a
    inc hl
    ld a, [hl+]
    ldh [$bf], a
    inc hl
    inc hl
    inc hl
    inc hl
    inc hl
    ld a, [hl]
    ldh [$be], a
    ldh a, [$b9]
    sla a
    ld e, a
    ld d, $00
    rl d
    ld hl, enemyHitboxPointers
    add hl, de
    ld a, [hl+]
    ld e, a
    ld a, [hl]
    ld h, a
    ld l, e
    ldh a, [$b7]
    ld b, a
    ldh a, [$bf]
    bit 6, a
    jr nz, jr_000_358b

    ld a, [hl+]
    add b
    ldh [$ba], a
    ld a, [hl+]
    add b
    ldh [$bb], a
    jr jr_000_3595

jr_000_358b:
    ld a, [hl+]
    sub b
    cpl
    ldh [$bb], a
    ld a, [hl+]
    sub b
    cpl
    ldh [$ba], a

jr_000_3595:
    ldh a, [$b8]
    ld b, a
    ldh a, [$bf]
    bit 5, a
    jr nz, jr_000_35ac

    ld a, [hl+]
    add b
    sub $05
    ldh [$bc], a
    ld a, [hl+]
    add b
    add $05
    ldh [$bd], a
    jr jr_000_35ba

jr_000_35ac:
    ld a, [hl+]
    sub b
    cpl
    add $05
    ldh [$bd], a
    ld a, [hl+]
    sub b
    cpl
    sub $05
    ldh [$bc], a

jr_000_35ba:
    ldh a, [$ba]
    ld b, a
    ldh a, [$bb]
    sub b
    ld c, a
    ldh a, [$98]
    sub b
    ldh [$9a], a
    cp c
    jp nc, Jump_000_3694

    ld a, $01
    ld [$c423], a
    ldh a, [$bc]
    ld b, a
    ldh a, [$99]
    sub b
    ld c, a
    ldh a, [$bd]
    sub b
    ld d, a
    srl d
    sub c
    jp c, Jump_000_3694

    ld a, d
    cp c
    jr c, jr_000_35e9

    ld a, $ff
    ld [$c423], a

jr_000_35e9:
    ld a, [samusItems]
    bit itemBit_screw, a
    jr z, jr_000_3629

    ld a, [samusPose]
    cp $02
    jr z, jr_000_35fe

    ld a, [samusPose]
    cp $0a
    jr nz, jr_000_3629

jr_000_35fe:
    ldh a, [$be]
    and a
    jr z, jr_000_3607

    bit 0, a
    jr z, jr_000_362e

jr_000_3607:
    ldh a, [$b9]
    ld e, a
    ld d, $00
    ld hl, enemyDamageTable
    add hl, de
    ld a, [hl]
    cp $ff
    jr z, jr_000_362e

    ld [$c424], a
    pop hl
    ld a, $10
    ld [$d05d], a
    ld a, l
    ld [$d05e], a
    ld a, h
    ld [$d05f], a
    scf
    ccf
    ret


jr_000_3629:
    ldh a, [$be]
    and a
    jr z, jr_000_3650

jr_000_362e:
    pop hl
    ldh a, [$b9]
    cp $f7
    jr nz, jr_000_364e

    ld a, [samusPose]
    cp $05
    jr z, jr_000_3644

    cp $06
    jr z, jr_000_3644

    cp $08
    jr nz, jr_000_364e

jr_000_3644:
    ld a, $01
    ld [$d090], a
    ld a, $18
    ld [samusPose], a

jr_000_364e:
    scf
    ret


jr_000_3650:
    ldh a, [$b9]
    and a
    jr z, jr_000_362e

    ld e, a
    ld d, $00
    ld hl, enemyDamageTable
    add hl, de
    ld a, [hl]
    cp $ff
    jr z, jr_000_362e

    cp $fe
    jr z, jr_000_3680

    and a
    jr z, jr_000_3683

    ld [$c424], a
    ld a, $01
    ld [$c422], a
    pop hl
    ld a, l
    ld [$d05e], a
    ld a, h
    ld [$d05f], a
    ld a, $20
    ld [$d05d], a
    scf
    ret


jr_000_3680:
    call Call_000_2f3c

jr_000_3683:
    pop hl
    ld a, l
    ld [$d05e], a
    ld a, h
    ld [$d05f], a
    ld a, $20
    ld [$d05d], a
    scf
    ccf
    ret


Jump_000_3694:
    pop hl
    scf
    ccf
    ret


Jump_000_3698:
    scf
    ccf
    ret


    db $ec, $f4, $fc, $ec, $f6, $04, $04, $ec, $04, $ec, $ec, $04, $04, $04, $04, $ec

    inc b

    db $ec, $04

    db $ec
    inc b

jr_000_36b0:
    call handleAudio
    call Call_000_031c
    ld a, [$ced6]
    cp $0b
    jr z, jr_000_36b0

    xor a
    ld [$d08b], a
    call Call_000_039c
    call Call_000_037b
    xor a
    ldh [hOamBufferIndex], a
    call Call_000_3eca
    ld a, $05
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld hl, $5f34
    ld de, $8800
    ld bc, $1000

jr_000_36de:
    ld a, [hl+]
    ld [de], a
    inc de
    dec bc
    ld a, b
    or c
    jr nz, jr_000_36de

    ld hl, $3711
    ld de, $9906

jr_000_36ec:
    ld a, [hl+]
    cp $80
    jr z, jr_000_36f5

    ld [de], a
    inc de
    jr jr_000_36ec

jr_000_36f5:
    xor a
    ld [$c205], a
    ld [$c206], a
    ldh [rSCY], a
    ldh [rSCX], a
    ld a, $c3
    ld [$c219], a
    ldh [rLCDC], a
    ld a, $ff
    ld [countdownTimerLow], a
    ld a, $07
    ldh [gameMode], a
    ret


    db $56, $50, $5c, $54, $ff, $5e, $65, $54, $61, $80

    call handleAudio
    call Call_000_031c
    ld a, [countdownTimerLow]
    and a
    jr z, jr_000_372c

    ldh a, [hInputRisingEdge]
    cp PADF_START
    ret nz

jr_000_372c:
    jp bootRoutine

; Handle item pick-up
handleItemPickup:
    ld a, [$d06c]
    and a
        ret z

    call waitOneFrame
    call waitOneFrame
    call waitOneFrame
    call waitOneFrame

    ld a, [$d06c]
    ld [$d093], a
    ld b, a
    ld a, $12
    ld [$cec0], a
    ld a, $01
    ld [$cede], a
    ld a, $01
    ld [countdownTimerHigh], a
    ld a, $60
    ld [countdownTimerLow], a
    ld a, b
    cp $0d
    jr c, jr_000_378b

    cp $0e
    jr nc, jr_000_3774

    ld a, $05
    ld [$cede], a
    xor a
    ld [countdownTimerHigh], a
    ld a, $60
    ld [countdownTimerLow], a
    jr jr_000_378b

jr_000_3774:
    ld a, $00
    ld [$cede], a
    ld [countdownTimerHigh], a
    ld [countdownTimerLow], a
    ld a, $0e
    ld [$cec0], a
    jr z, jr_000_378b

    ld a, $0c
    ld [$cec0], a

jr_000_378b:
    ld a, [$cedf]
    cp $0e
    jr nz, jr_000_3797

    ld a, $00
    ld [$cede], a

jr_000_3797:
    ld a, b
    dec a
    rst $28
        dw pickup_37B8
        dw pickup_37DD
        dw pickup_3802
        dw pickup_3827
        dw pickup_3845
        dw pickup_3850
        dw pickup_38B9
        dw pickup_3923
        dw pickup_392E
        dw pickup_3958
        dw pickup_3963
        dw pickup_397A
        dw pickup_39BF
        dw pickup_398F
        dw pickup_399C

pickup_37B8:
    ld a, $04
    ld [$d055], a
    ld hl, $37d6
    call Call_000_2753
    ld a, [$d04d]
    cp $08
    jp z, Jump_000_3a01

    ld a, $04
    ld [$d04d], a
    ld [$d055], a
    jp Jump_000_3a01

    db $06, $80, $40, $e0, $87, $20, $00

pickup_37DD:
    ld a, $01
    ld [$d055], a
    ld hl, $37fb
    call Call_000_2753
    ld a, [$d04d]
    cp $08
    jp z, Jump_000_3a01

    ld a, $01
    ld [$d04d], a
    ld [$d055], a
    jp Jump_000_3a01

    db $06, $40, $40, $e0, $87, $20, $00

pickup_3802:
    ld a, $02
    ld [$d055], a
    ld hl, $3820
    call Call_000_2753
    ld a, [$d04d]
    cp $08
    jp z, Jump_000_3a01

    ld a, $02
    ld [$d04d], a
    ld [$d055], a
    jp Jump_000_3a01

    db $06, $60, $40, $e0, $87, $20, $00

pickup_3827:
    ld a, $03
    ld [$d055], a
    ld hl, $37d6
    call Call_000_2753
    ld a, [$d04d]
    cp $08
    jp z, Jump_000_3a01

    ld a, $03
    ld [$d04d], a
    ld [$d055], a
    jp Jump_000_3a01


pickup_3845:
    ld a, [samusItems]
    set itemBit_bomb, a
    ld [samusItems], a
    jp Jump_000_3a01

pickup_3850:
    ld a, [samusItems]
    set itemBit_screw, a
    ld [samusItems], a
    bit itemBit_space, a
    jr nz, jr_000_386b

    ld hl, $388f
    call Call_000_2753
    ld hl, $3896
    call Call_000_2753
    jp Jump_000_3a01


jr_000_386b:
    ld hl, $389d
    call Call_000_2753
    ld hl, $38a4
    call Call_000_2753
    jp Jump_000_3a01


; VRAM Update Lists
    db $06, $20, $4e, $00, $80, $b0, $07, $06, $a0, $40, $00, $85, $70, $00, $06, $10
    db $41, $00, $86, $50, $00

    ld b, $60
    ld b, c
    nop
    add l
    ld [hl], b
    nop
    ld b, $d0
    ld b, c
    nop
    add [hl]
    ld d, b
    nop

    db $06, $20, $42, $00, $85, $70, $00, $06, $90, $42, $00, $86, $50, $00, $06, $e0
    db $42, $90, $85, $20, $00, $06, $00, $43, $90, $86, $20, $00

pickup_38B9:
jr_000_38b9:
    call Call_000_3e93
    call Call_000_05de
    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call $4b2c
    call Call_000_3e88
    ld a, $80
    ldh [rWY], a
    call waitOneFrame
    ld a, [countdownTimerHigh]
    and a
    jr nz, jr_000_38b9

    ld a, [countdownTimerLow]
    and a
    jr nz, jr_000_38b9

    ld a, [samusItems]
    set itemBit_varia, a
    ld [samusItems], a
    ld a, $80
    ld [samusPose], a
    call Call_000_3e93
    ld a, $10
    ld [$d02c], a
    call waitOneFrame
    ld a, $1d
    ld [$cec0], a
    ld a, $ff
    ld [$d08c], a
    ld hl, $387a
    call Call_000_27e3
    xor a
    ld [$d08c], a
    ld hl, $387a
    call Call_000_2753
    ld hl, $2242
    ld a, [$d04d]
    cp $08
    call z, Call_000_2753
    call Call_000_3a84
    jp Jump_000_3a01

pickup_3923:
    ld a, [samusItems]
    set itemBit_hiJump, a
    ld [samusItems], a
    jp Jump_000_3a01

pickup_392E:
    ld a, [samusItems]
    set itemBit_space, a
    ld [samusItems], a
    bit itemBit_screw, a
    jr nz, jr_000_3949

    ld hl, $3881
    call Call_000_2753
    ld hl, $3888
    call Call_000_2753
    jp Jump_000_3a01

jr_000_3949:
    ld hl, $389d
    call Call_000_2753
    ld hl, $38a4
    call Call_000_2753
    jp Jump_000_3a01

pickup_3958:
    ld a, [samusItems]
    set itemBit_spider, a
    ld [samusItems], a
    jp Jump_000_3a01

pickup_3963:
    ld a, [samusItems]
    set itemBit_spring, a
    ld [samusItems], a
    ld hl, $38ab
    call Call_000_2753
    ld hl, $38b2
    call Call_000_2753
    jp Jump_000_3a01

pickup_397A:
    ld a, [$d050]
    cp $05 ; Max Energy tanks
    jr z, jr_000_3985
        inc a
        ld [$d050], a
    jr_000_3985:
    ld [$d052], a
    ld a, $99
    ld [$d051], a
    jr jr_000_3a01

pickup_398F:
    ld a, [$d050]
    ld [$d052], a
    ld a, $99
    ld [$d051], a
    jr jr_000_3a01

pickup_399C:
    ld a, [metroidCountReal]
    and a
    jr nz, jr_000_39b1
        ; Prep the credits prep
        ld a, $ff
        ld [countdownTimerLow], a
        ld a, $08
        ld [$cede], a
        ld a, $12
        ldh [gameMode], a
        ret
jr_000_39b1:
    ld a, [$d081]
    ld [$d053], a
    ld a, [$d082]
    ld [$d054], a
    jr jr_000_3a01

pickup_39BF:
    ld a, [$d081]
    add $10
    daa
    ld [$d081], a
    ld a, [$d082]
    adc $00
    daa
    ld [$d082], a
    ; Max Missiles = 999
    cp $10
    jr c, jr_000_39df
        ld a, $99
        ld [$d081], a
        ld a, $09
        ld [$d082], a
jr_000_39df:
    ; Add 10 to current missiles
    ld a, [$d053]
    add $10
    daa
    ld [$d053], a
    ld a, [$d054]
    adc $00
    daa
    ld [$d054], a
    ; Clamp current missiles to 999
    cp $10
    jr c, jr_000_3a01
        ld a, $99
        ld [$d053], a
        ld a, $09
        ld [$d054], a
    jr jr_000_3a01

; Common routine for all pickups
Jump_000_3a01:
jr_000_3a01:
    call Call_000_3e93
    call Call_000_3e9e
    ld a, $02
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call $4000
    call handleAudio
    call Call_000_3e88
    ld a, [$d093]
    cp $0b
    jr nc, jr_000_3a23

    ld a, $80
    ldh [rWY], a

jr_000_3a23:
    call Call_000_031c
    ld a, [countdownTimerHigh]
    and a
    jr nz, jr_000_3a01

    ld a, [countdownTimerLow]
    and a
    jr nz, jr_000_3a01

    ld a, [$d093]
    cp $0e
    jr nc, jr_000_3a45

    ld a, [$cedf]
    cp $0e
    jr z, jr_000_3a45

    ld a, $03
    ld [$cede], a

jr_000_3a45:
    xor a
    ld [$d093], a
    ld a, $03
    ld [$d06d], a
    ld a, [$d06f]
    ld [$c466], a
    ld a, [$d070]
    ld [$c467], a
    ld a, [$d071]
    ld [$c468], a

jr_000_3a60:
    call Call_000_3e93
    call Call_000_3e9e
    call Call_000_32ab
    ld a, $02
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call $4000
    call handleAudio
    call Call_000_3e88
    call Call_000_031c
    ld a, [$d06d]
    and a
    jr nz, jr_000_3a60

    ret


Call_000_3a84:
    ld a, [samusItems]
    bit itemBit_spring, a
    jr z, jr_000_3a97

    ld hl, $38ab
    call Call_000_2753
    ld hl, $38b2
    call Call_000_2753

jr_000_3a97:
    ld a, [samusItems]
    and itemMask_space | itemMask_screw
    cp itemMask_space | itemMask_screw
    jr nz, jr_000_3aad

    ld hl, $389d
    call Call_000_2753
    ld hl, $38a4
    call Call_000_2753
    ret


jr_000_3aad:
    cp $08
    jr nz, jr_000_3abe

    ld hl, $3881
    call Call_000_2753
    ld hl, $3888
    call Call_000_2753
    ret


jr_000_3abe:
    cp $04
    ret nz

    ld hl, $388f
    call Call_000_2753
    ld hl, $3896
    call Call_000_2753
    ret

; 00:3ACE
    call Call_000_2390
    ld a, $ff
    ld [$cfe5], a
    call Call_000_039c
    call Call_000_037b
    xor a
    ldh [hOamBufferIndex], a
    call Call_000_3eca
    ld a, $05
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld hl, $5f34
    ld de, $8000
    ld bc, $1800

jr_000_3af3:
    ld a, [hl+]
    ld [de], a
    inc de
    dec bc
    ld a, b
    or c
    jr nz, jr_000_3af3

    ld hl, $3b24
    ld de, $9905

jr_000_3b01:
    ld a, [hl+]
    cp $80
    jr z, jr_000_3b0a

    ld [de], a
    inc de
    jr jr_000_3b01

jr_000_3b0a:
    xor a
    ld [$c205], a
    ld [$c206], a
    ld a, $c3
    ldh [rLCDC], a
    ld a, $a0
    ld [countdownTimerLow], a
    ld a, $01
    ld [countdownTimerHigh], a
    ld a, $0f
    ldh [gameMode], a
    ret

; 00:3B24
; "GAME SAVED"
    db $56, $50, $5C, $54, $FF, $62, $50, $65, $54, $53, $80

; 00:3B2F
    call handleAudio
    call Call_000_031c
    ld a, [countdownTimerLow]
    and a
    jr z, jr_000_3b40

    ldh a, [hInputRisingEdge]
    cp PADF_START
    ret nz

jr_000_3b40:
    jp bootRoutine

; 00:3B43
    call Call_000_2390
    ld a, $ff
    ld [$cfe5], a
    call Call_000_039c
    call Call_000_037b
    xor a
    ldh [hOamBufferIndex], a
    call Call_000_3eca
    ld a, $05
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld hl, $5f34
    ld de, $8800
    ld bc, $1000

jr_000_3b68:
    ld a, [hl+]
    ld [de], a
    inc de
    dec bc
    ld a, b
    or c
    jr nz, jr_000_3b68

    ld hl, $3b94
    ld de, $9904

jr_000_3b76:
    ld a, [hl+]
    cp $80
    jr z, jr_000_3b7f

    ld [de], a
    inc de
    jr jr_000_3b76

jr_000_3b7f:
    xor a
    ld [$c205], a
    ld [$c206], a
    ld a, $c3
    ldh [rLCDC], a
    ld a, $ff
    ld [countdownTimerLow], a
    ld a, $11
    ldh [gameMode], a
    ret

; "GAME CLEARED" ?
; 00:3B94
    db $56, $50, $5C, $54, $FF, $52, $5B, $54, $50, $61, $54, $53, $80

; 00:3BA1 
    call Call_000_031c
    ld a, [countdownTimerLow]
    and a
    jr z, jr_000_3baf

    ldh a, [hInputRisingEdge]
    cp PADF_START
    ret nz

jr_000_3baf:
    ld a, $00
    ldh [gameMode], a
    ret


Call_000_3bb4:
    ld a, [samusItems]
    bit itemBit_varia, a
    jr z, jr_000_3bc1

    ld hl, $387a
    call Call_000_3c3f

jr_000_3bc1:
    ld a, [samusItems]
    bit itemBit_spring, a
    jr z, jr_000_3bd4

    ld hl, $38ab
    call Call_000_3c3f
    ld hl, $38b2
    call Call_000_3c3f

jr_000_3bd4:
    ld a, [samusItems]
    and itemMask_space | itemMask_screw
    cp itemMask_space | itemMask_screw
    jr nz, jr_000_3beb

    ld hl, $389d
    call Call_000_3c3f
    ld hl, $38a4
    call Call_000_3c3f
    jr jr_000_3c0d

jr_000_3beb:
    cp $08
    jr nz, jr_000_3bfd

    ld hl, $3881
    call Call_000_3c3f
    ld hl, $3888
    call Call_000_3c3f
    jr jr_000_3c0d

jr_000_3bfd:
    cp $04
    jr nz, jr_000_3c0d

    ld hl, $388f
    call Call_000_3c3f
    ld hl, $3896
    call Call_000_3c3f

jr_000_3c0d:
    ld a, [$d04d]
    cp $01
    jr nz, jr_000_3c1c

    ld hl, $37fb
    call Call_000_3c3f
    jr jr_000_3c3e

jr_000_3c1c:
    cp $03
    jr nz, jr_000_3c28

    ld hl, $37d6
    call Call_000_3c3f
    jr jr_000_3c3e

jr_000_3c28:
    cp $02
    jr nz, jr_000_3c34

    ld hl, $3820
    call Call_000_3c3f
    jr jr_000_3c3e

jr_000_3c34:
    cp $04
    jr nz, jr_000_3c3e

    ld hl, $37d6
    call Call_000_3c3f

jr_000_3c3e:
    ret


Call_000_3c3f:
    ld a, [hl+]
    ld [bankRegMirror], a
    ld [$d065], a
    ld [rMBC_BANK_REG], a
    ld a, [hl+]
    ldh [$98], a
    ld a, [hl+]
    ldh [$99], a
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld c, a
    ld a, [hl+]
    ld b, a
    ldh a, [$98]
    ld l, a
    ldh a, [$99]
    ld h, a

jr_000_3c5d:
    call Call_000_038a
    ret


    ld a, [hl+]
    ld [de], a
    inc de
    dec bc
    ld a, c
    or b
    jr nz, jr_000_3c5d

    ret

; 00:3C6A - Load credits to SRAM
loadCreditsText:
    ld a, BANK(creditsText)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld hl, creditsText ;$7920
    ld de, creditsTextBuffer
    ; Enable SRAM
    ld a, $0a
    ld [$0000], a

    .loadLoop:
        ld a, [hl+]
        ld [de], a
        inc de
        cp $f0
    jr nz, .loadLoop

    ; Disable SRAM
    ld a, $00
    ld [$0000], a

    ld a, $05
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
ret


    ld a, BANK(earthquakeCheck)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call earthquakeCheck
    ld a, $02
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
ret


    ld a, $03
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call $6ae7
    ld a, $02
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ret


    ld a, $03
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call $6b44
    ld a, $02
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ret


    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call $56e9
    ld a, $02
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ret


    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp $7adf


Call_000_3ced:
    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp $79ef

drawNonGameSprite_longCall: ; 00:3CF8
    ld a, BANK(drawNonGameSprite)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call drawNonGameSprite
    ld a, $05
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ret


    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call $70ba
    ld a, $02
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ret


    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call $723b
    ld a, $02
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ret


    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call $71cb
    ld a, $02
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ret


    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call $7319
    ld a, $02
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ret


LCDCInterruptHandler:
    push af
    ld a, $03
    ld [rMBC_BANK_REG], a
    call $7c7f
    ld a, [bankRegMirror]
    ld [rMBC_BANK_REG], a
    pop af
reti


Call_000_3d6d:
    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp $57f2


Call_000_3d78:
    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp $4a2b


Call_000_3d83:
    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp $5692


Call_000_3d8e:
    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp $500d


Call_000_3d99:
    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp $549d


Call_000_3da4:
    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp $5300


Jump_000_3daf:
    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp $4e8a


    ld a, $03
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call $6bd2
    ld a, $02
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ret


    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call $5a11
    ld a, $02
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ret


    ld a, $03
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call $4000
    ld a, $02
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ret


    ld a, $03
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call $42b4
    ld a, $02
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ret


; 3E0A
    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call $7ab9
    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ret


VBlank_drawCreditsLine_longJump:
    ld a, BANK(VBlank_drawCreditsLine)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp VBlank_drawCreditsLine

gameMode_prepareCredits: ; 00:3E29
    ld a, $05
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp prepareCreditsRoutine

gameMode_Credits: ; 00:3E34
    ld a, BANK(creditsRoutine)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp creditsRoutine

gameMode_Boot: ; 00:3E3F
    call Call_000_039c
    call Call_000_0370
    xor a
    ldh [hOamBufferIndex], a
    call Call_000_3e88
    call Call_000_2390
    ld a, $05
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp loadTitleScreen

gameMode_Title: ; 00:3E59
    call Call_000_0370
    ld a, $05
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp titleScreenRoutine


    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp $4e1c


    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp $4e33


    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp $4b62


Call_000_3e88:
    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp $4bb3


Call_000_3e93:
    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp $4bd9


Call_000_3e9e:
    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp $4b2c


    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp $4b09


    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp $4afc


Call_000_3ebf:
    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp $4bf3


Call_000_3eca:
    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp $4bce


    ld a, [currentLevelBank]
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ldh a, [hSamusYScreen]
    swap a
    ld e, a
    ldh a, [hSamusXScreen]
    add e
    ld e, a
    ld d, $00
    sla e
    rl d
    ld hl, $4300
    add hl, de
    inc hl
    ld a, [hl]
    swap a
    rlc a
    and $01
    xor $01
    ld [$d057], a
    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ret

; 00:3F07
; unused
    ldh a, [$97]
    and $01
    jr nz, jr_000_3f44

    ld a, [$d05a]
    ld l, a
    ld a, [$d05b]
    ld h, a
    ld de, $0010

jr_000_3f18:
    xor a
    ld [hl], a
    add hl, de
    ld a, l
    and $f0
    jr nz, jr_000_3f18

    ld a, l
    sub $ff
    ld l, a
    ld a, h
    sbc $00
    ld h, a
    ld a, l
    cp $10
    jr nz, jr_000_3f34

    add $f0
    ld l, a
    ld a, h
    adc $00
    ld h, a

jr_000_3f34:
    ld a, l
    ld [$d05a], a
    ld a, h
    ld [$d05b], a
    cp $85
    jr nz, jr_000_3f44

    xor a
    ld [$d059], a

jr_000_3f44:
    ld a, [$c205]
    ldh [rSCY], a
    ld a, [$c206]
    ldh [rSCX], a
    call OAM_DMA
    ld a, [bankRegMirror]
    ld [rMBC_BANK_REG], a
    ld a, $01
    ldh [$82], a
    pop hl
    pop de
    pop bc
    pop af
reti

; Freespace - 00:3F60 (filled with $00)
