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
    ; Update scrolling
    ld a, [$c205]
    ldh [rSCY], a
    ld a, [$c206]
    ldh [rSCX], a
    ; Update palettes
    ld a, [bg_palette]
    ldh [rBGP], a
    ld a, [ob_palette0]
    ldh [rOBP0], a
    ld a, [ob_palette1]
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
; Various different update handlers
;  Looks like 
    ; Credits drawing routine
    ld a, [credits_nextLineReady]
    and a
    jp nz, VBlank_drawCreditsLine_longJump
    ; Death sequence drawing routine
    ld a, [deathAnimTimer]
    and a
    jp nz, VBlank_deathSequence
    ; Some other VRAM 
    ld a, [$d047]
    and a
    jp nz, Jump_000_2ba3

    ld a, [doorIndexLow]
    and a
    jp nz, Jump_000_2b8f

    ; Branch for queen fight
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
    ldh [hVBlankDoneFlag], a
    pop hl
    pop de
    pop bc
    pop af
reti


jr_000_01d9:
    ld a, BANK(updateStatusBar)
    ld [rMBC_BANK_REG], a
    call updateStatusBar
    call OAM_DMA
    
    ld a, BANK(VBlank_drawQueen)
    ld [rMBC_BANK_REG], a
    call VBlank_drawQueen
    
    ld a, [bankRegMirror]
    ld [rMBC_BANK_REG], a
    ld a, $01
    ldh [hVBlankDoneFlag], a
    ; Return from interrupt
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
    ld [bg_palette], a
    ld a, $93
    ld [ob_palette0], a
    ld a, $43
    ld [ob_palette1], a
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

    call clearTilemaps
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
    ld [activeSaveSlot], a
    ld a, [saveLastSlot]
    cp $03
    jr nc, jr_000_02c4
        ld [activeSaveSlot], a
    jr_000_02c4:

    ld a, $00
    ldh [gameMode], a
    ld a, $00
    ld [$0000], a

mainGameLoop: ; 00:02CD
    ; Clear vram update flag
    xor a
    ld [$de01], a
    ; Update buttons if not in a door transition
    ld a, [doorScrollDirection]
    and a
    call z, main_readInput
    ; Do imporatant stuff
    call main_handleGameMode
    call handleAudio
    call executeDoorScript
    ldh a, [hInputPressed]
    ; Soft reset
    and PADF_START | PADF_SELECT | PADF_B | PADF_A ;$0f
    cp PADF_START | PADF_SELECT | PADF_B | PADF_A
        jp z, bootRoutine
    call waitForNextFrame
jp mainGameLoop


main_handleGameMode: ; 0:02F0
    ldh a, [gameMode]
    rst $28
        dw gameMode_Boot           ; $00
        dw gameMode_Title          ; $01
        dw gameMode_LoadA          ; $02 Setup for playing the game
        dw gameMode_LoadB          ; $03  More setup
        dw gameMode_Main           ; $04 Actually playing the game
        dw gameMode_dead           ; $05 Dead (prep Game Over screen)
        dw gameMode_dying          ; $06 Dying
        dw gameMode_gameOver       ; $07 Game Over (press button to restart)
        dw gameMode_Paused         ; $08
        dw gameMode_saveGame       ; $09 Save to SRAM
        dw gameMode_unusedA        ; $0A Prep "Game Saved" screen (unused)
        dw gameMode_newGame        ; $0B New game
        dw gameMode_loadSave       ; $0C Load save
        dw gameMode_None           ; $0D
        dw gameMode_None           ; $0E
        dw gameMode_unusedB        ; $0F from $0A, displays "Game Saved" (unused)
        dw gameMode_unusedC        ; $10 Prep "Game Cleared" screen (unused)
        dw gameMode_unusedD        ; $11 from $10, displays "Game Cleared" (unused)
        dw gameMode_prepareCredits ; $12
        dw gameMode_Credits        ; $13

gameMode_None:
    ret


waitForNextFrame: ; 00:031C
    db $76 ; HALT

    .vBlankNotDone:
        ldh a, [hVBlankDoneFlag]
        and a
    jr z, .vBlankNotDone

    ; Increment frame counter
    ldh a, [frameCounter]
    inc a
    ldh [frameCounter], a
    and a
    jr nz, .endIf
        ; Increment in-game timer
        ; Check if ingame
        ldh a, [gameMode]
        cp $04
        jr nz, .endIf
            ; Increment "seconds" (actually 256-frame periods (not saved))
            ld a, [gameTimeSeconds]
            inc a
            ld [gameTimeSeconds], a
            cp $0e
            jr nz, .endIf
                ; Increment minutes
                xor a
                ld [gameTimeSeconds], a
                ld a, [gameTimeMinutes]
                add $01
                daa
                ld [gameTimeMinutes], a
                cp $60
                jr c, .endIf
                    ; Increment hours
                    xor a
                    ld [gameTimeMinutes], a
                    ld a, [gameTimeHours]
                    add $01
                    daa
                    ld [gameTimeHours], a
                    jr nz, .endIf
                        ; Clamp to max IGT (59:99)
                        ld a, $59
                        ld [gameTimeMinutes], a
                        ld a, $99
                        ld [gameTimeHours], a
    .endIf:
    
    xor a
    ldh [hVBlankDoneFlag], a
    ld a, $c0
    ldh [$8c], a
    xor a
    ldh [hOamBufferIndex], a
ret


OAM_clearTable: ; 00:0370
    xor a
    ld hl, $c000
    ld b, $a0

    jr_000_0376:
        ld [hl+], a
        dec b
    jr nz, jr_000_0376
ret

; Clears both the BG and window tilemaps
clearTilemaps: ; 00:037B
    ld hl, $9fff
    ld bc, $0800
    .loop:
        ld a, $ff
        ld [hl-], a
        dec bc
        ld a, b
        or c
    jr nz, .loop
ret

; hl: source, de: destination, bc: length
copyToVram:
    .loop:
        ld a, [hl+]
        ld [de], a
        inc de
        dec bc
        ld a, b
        or c
    jr nz, .loop
ret

; de: source, hl: destination, $FF terminated
unusedCopyRoutine:
    .loop:
        ld a, [de]
        cp $ff
            ret z
        ld [hl+], a
        inc de
    jr .loop

TimerOverflowInterruptStub:
    reti


disableLCD:
    ldh a, [rIE]
    ldh [$99], a
    res 0, a
    ldh [rIE], a
    .waitLoop:
        ldh a, [rLY]
        cp $91
    jr nz, .waitLoop
    ldh a, [rLCDC]
    and $7f
    ldh [rLCDC], a
    ldh a, [$99]
    ldh [rIE], a
ret

gameMode_LoadA:
    call loadGame_samusData
    ld a, $08
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld a, [saveBuf_tiletableSrcLow]
    ld l, a
    ld a, [saveBuf_tiletableSrcHigh]
    ld h, a
    ld de, tiletableArray

    .tiletableLoop:
        ld a, [hl+]
        ld [de], a
        inc de
        ld a, d
        cp $dc
    jr nz, .tiletableLoop

    ld a, [saveBuf_collisionSrcLow]
    ld l, a
    ld a, [saveBuf_collisionSrcHigh]
    ld h, a

    .collisionLoop:
        ld a, [hl+]
        ld [de], a
        inc de
        ld a, d
        cp $dd
    jr nz, .collisionLoop

    ld a, [saveBuf_currentLevelBank]
    ld [currentLevelBank], a
    
    ld a, [saveBuf_samusSolidityIndex]
    ld [samusSolidityIndex], a
    ld a, [saveBuf_enemySolidityIndex]
    ld [enemySolidityIndex_canon], a
    ld a, [saveBuf_beamSolidityIndex]
    ld [beamSolidityIndex], a
    
    ld a, [saveBuf_acidDamageValue]
    ld [acidDamageValue], a
    ld a, [saveBuf_spikeDamageValue]
    ld [spikeDamageValue], a
    
    ld a, [saveBuf_metroidCountReal]
    ld [metroidCountReal], a
    
    ld a, [saveBuf_currentRoomSong]
    ld [currentRoomSong], a
    
    ld a, [saveBuf_gameTimeMinutes]
    ld [gameTimeMinutes], a
    ld a, [saveBuf_gameTimeHours]
    ld [gameTimeHours], a
    
    ld a, [saveBuf_metroidCountDisplayed]
    ld [metroidCountDisplayed], a
    
    xor a
    ld [doorScrollDirection], a
    ld [deathAnimTimer], a
    ld [deathFlag], a
    ld [$d047], a
    ld [$d06b], a
    ld [itemCollected], a
    ld [itemCollectionFlag], a
    ld [maxOamPrevFrame], a

    ld a, $01
    ld [$d08b], a
    ld a, $ff
    ld [$d05d], a
    
    ; Clear respawning block table
    ld hl, $d900
    .clearLoop:
        xor a
        ld [hl], a
        ld a, l
        add $10
        ld l, a
    jr nz, .clearLoop

    ld a, $02
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call $418c
    ; Increment gameMode to gameMode_loadB
    ldh a, [gameMode]
    inc a
    ldh [gameMode], a
ret

gameMode_LoadB:
    call disableLCD
    call loadGame_loadGraphics
    call loadGame_SamusItemGraphics
    
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
    ; Render map
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
    ; Enable LCD
    ld a, $e3
    ldh [rLCDC], a
    xor a
    ld [$d011], a
    ; Increment game mode to main
    ldh a, [gameMode]
    inc a
    ldh [gameMode], a
ret

gameMode_Main:
    ld a, [samusPose]
    and $7f
    ; Jump ahead if being eaten by the Queen
    cp $18
    jp nc, Jump_000_0578

    call Call_000_3d6d
    ; Check if dead (when displayed health is zero)
    ld a, [samusDispHealthLow]
    ld b, a
    ld a, [samusDispHealthHigh]
    or b
    call z, killSamus
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
    call nz, toggleMissiles
    jr jr_000_053e

jr_000_0522:
    ld a, [doorScrollDirection]
    and a
    jr nz, jr_000_053e

    xor a
    ld [$d05c], a
    call Call_000_2ee3 ; Damage Samus
    call Call_000_0d21 ; Samus pose handler
    call Call_000_32ab ; ? Samus/enemy collision logic
    call Call_000_21fb ; Handle shooting or toggling cannon
    call handleProjectiles_longJump ; Handle projectiles
    call Call_000_3d99 ; Handle bombs

jr_000_053e:
    call Call_000_0698 ; Handle loading blocks
    call Call_000_08fe ; Handle scrolling/triggering door transitions
    call Call_000_2366 ; Calculate scroll offsets
    call handleItemPickup
    call Call_000_3e93 ; Draw Samus
    call Call_000_3da4 ; Draw projectiles
    call handleRespawningBlocks_longJump ; Handle respawning blocks
    call adjustHudValues_longJump ; Handle missile/energy counters
    ld a, [$d049]
    and a
    jr z, jr_000_0560

    dec a
    ld [$d049], a

jr_000_0560:
    call drawHudMetroid_longJump
    ldh a, [hOamBufferIndex]
    ld [$d064], a
    ld a, [doorIndexLow]
    and a
    jr nz, jr_000_0571

    call Call_000_05de ; Handle enemies

jr_000_0571:
    call clearUnusedOamSlots_longJump ; Clear unused OAM
    call Call_000_2c79 ; Handle pausing ?
    ret


Jump_000_0578:
    call Call_000_3d6d
    ld a, [samusDispHealthLow]
    ld b, a
    ld a, [samusDispHealthHigh]
    or b
    call z, killSamus
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
    call handleProjectiles_longJump
    call Call_000_3d99
    call Call_000_0698
    call Call_000_08fe
    call Call_000_2366
    call Call_000_3e93
    call Call_000_3da4
    call handleRespawningBlocks_longJump
    call adjustHudValues_longJump
    ld a, [$d049]
    and a
    jr z, jr_000_05cc

    dec a
    ld [$d049], a

jr_000_05cc:
    call drawHudMetroid_longJump
    ldh a, [hOamBufferIndex]
    ld [$d064], a
    call Call_000_05de
    call clearUnusedOamSlots_longJump
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
    ld a, BANK(queenHandler)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call queenHandler
    ret


loadGame_loadGraphics:
    ld a, BANK(gfx_commonItems)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld bc, $0100
    ld hl, gfx_commonItems
    ld de, vramDest_commonItems
    call copyToVram
    
    ld a, BANK(gfx_samusPowerSuit)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld bc, $0b00
    ld hl, gfx_samusPowerSuit
    ld de, vramDest_samus
    call copyToVram

    ld a, BANK(gfx_enemiesA)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld bc, $0400
    ld a, [saveBuf_enGfxSrcLow]
    ld l, a
    ld a, [saveBuf_enGfxSrcHigh]
    ld h, a
    ld de, vramDest_enemies
    call copyToVram

    ld a, [$d079]
    and a
    jr z, jr_000_0658
        ld a, BANK(gfx_itemFont)
        ld [bankRegMirror], a
        ld [rMBC_BANK_REG], a
        ld bc, $0200
        ld hl, gfx_itemFont
        ld de, vramDest_itemFont
        call copyToVram
    jr_000_0658:

    ld a, [saveBuf_bgGfxSrcBank]
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld bc, $0800
    ld a, [saveBuf_bgGfxSrcLow]
    ld l, a
    ld a, [saveBuf_bgGfxSrcHigh]
    ld h, a
    ld de, vramDest_bgTiles
    call copyToVram
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
    ldh a, [frameCounter]
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
    ld hl, tiletableArray
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
    ld a, [doorScrollDirection]
    and a
    jp nz, Jump_000_0b44

    ; Get screen index from coordinates
    ldh a, [hCameraYScreen]
    swap a
    ld b, a
    ldh a, [hCameraXScreen]
    or b
    ld e, a    
    ld d, $00
    
    ; Load scroll data for screen
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
    ld [doorScrollDirection], a
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
    ld [doorScrollDirection], a
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
    ld [doorScrollDirection], a
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
    ld [doorScrollDirection], a
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
    ld a, [doorScrollDirection]
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
    ldh a, [frameCounter]
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
    ldh a, [frameCounter]
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
    ld [doorScrollDirection], a
    ld [$c463], a
    ld a, [bg_palette]
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
    ld [saveContactFlag], a
    ld a, $ff
    ld hl, $dd30
    ld [hl], a
    ld hl, $dd40
    ld [hl], a
    ld hl, $dd50
    ld [hl], a
    ld [$d09e], a
    ; Get screen ID from coordinates
    ldh a, [hCameraYScreen]
    swap a
    ld e, a
    ldh a, [hCameraXScreen]
    add e
    ld e, a
    ld d, $00
    sla e
    rl d
    ld hl, $4300 ; Door transition table
    add hl, de
    ld a, [hl+]
    ld [doorIndexLow], a
    ld a, [hl]
    res 3, a ; Remove sprite priority bit from door index in ROM
    ld [doorIndexHigh], a
    ld a, $02
    ld [$c458], a
    xor a
    ld [$d09b], a
    ld a, [debugFlag]
    and a
    ret z

    ; Check if either A or Start is pressed
    ldh a, [hInputPressed]
    and PADF_START | PADF_SELECT | PADF_B | PADF_A ;$0f
    cp PADF_SELECT | PADF_B ;$06
    ret nz
    ; Force transition to queen
    ld a, $9d
    ld [doorIndexLow], a
    ld a, $01
    ld [doorIndexHigh], a
ret

; Loads Samus' information from the WRAM save buffer to working locations in RAM
loadGame_samusData:
    call clearProjectileArray
    
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
    ld [samusInvulnerableTimer], a
    
    ld a, [saveBuf_samusItems]
    ld [samusItems], a
    
    ld a, [saveBuf_samusBeam]
    ld [samusActiveWeapon], a
    ld [samusBeam], a
    
    ld a, [saveBuf_samusFacingDirection]
    ld [samusFacingDirection], a
    
    ld a, [saveBuf_samusEnergyTanks]
    ld [samusEnergyTanks], a
    
    ld a, [saveBuf_samusHealthLow]
    ld [samusCurHealthLow], a
    ld [samusDispHealthLow], a
    
    ld a, [saveBuf_samusHealthHigh]
    ld [samusCurHealthHigh], a
    ld [samusDispHealthHigh], a
    
    ld a, [saveBuf_samusMaxMissilesLow]
    ld [samusMaxMissilesLow], a
    
    ld a, [saveBuf_samusMaxMissilesHigh]
    ld [samusMaxMissilesHigh], a
    
    ld a, [saveBuf_samusCurMissilesLow]
    ld [samusCurMissilesLow], a
    ld [samusDispMissilesLow], a
    
    ld a, [saveBuf_samusCurMissilesHigh]
    ld [samusCurMissilesHigh], a
    ld [samusDispMissilesHigh], a
    
    ld a, $13
    ld [samusPose], a
    ld a, $40
    ld [countdownTimerLow], a
    ld a, $01
    ld [countdownTimerHigh], a
    ; Play Samus' appearance fanfare
    ld a, $12
    ld [$cedc], a
ret


Call_000_0d21:
Jump_000_0d21:
    xor a
    ld [waterContactFlag], a
    ld [acidContactFlag], a
    ld a, [$d072]
    inc a
    ld [$d072], a
    
    ld a, [deathFlag]
    and a
    jr z, jr_000_0d3a
        xor a
        ldh [hInputRisingEdge], a
        ldh [hInputPressed], a
    jr_000_0d3a:

    ld a, [doorScrollDirection]
    and a
    ret nz

    ld a, [samusPose]
    bit 7, a
    jp nz, Jump_000_139d

    ld a, [samusPose]
    rst $28
        dw poseFunc_13B7 ; $00
        dw poseFunc_17BB ; $01
        dw poseFunc_18E8 ; $02
        dw poseFunc_14D6 ; $03
        dw poseFunc_15F4 ; $04
        dw poseFunc_1701 ; $05
        dw poseFunc_179F ; $06
        dw poseFunc_12F5 ; $07
        dw poseFunc_124B ; $08
        dw poseFunc_19E2 ; $09
        dw poseFunc_19E2 ; $0A
        dw poseFunc_1083 ; $0B
        dw poseFunc_11E4 ; $0C
        dw poseFunc_1170 ; $0D
        dw poseFunc_1029 ; $0E
        dw poseFunc_0EF7 ; $0F
        dw poseFunc_0F38 ; $10
        dw poseFunc_0F6C ; $11
        dw poseFunc_0ECB ; $12
        dw poseFunc_0EA5 ; $13
        dw poseFunc_0EA5 ; $14
        dw poseFunc_0EA5 ; $15
        dw poseFunc_0EA5 ; $16
        dw poseFunc_0EA5 ; $17
        dw poseFunc_0E36 ; $18
        dw poseFunc_0DF0 ; $19
        dw poseFunc_0DBE ; $1A
        dw poseFunc_0D87 ; $1B
        dw poseFunc_0D8B ; $1C
        dw poseFunc_0ECB ; $1D

poseFunc_0D87: ; $1B
    call Call_000_2f29
    ret

poseFunc_0D8B: ; $1C
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

poseFunc_0DBE: ; $1A
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

poseFunc_0DF0: ; $19
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

poseFunc_0E36: ; $18
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

poseFunc_0EA5: ; $13-$17
    ld a, [countdownTimerLow]
    and a
        ret nz
    ld a, [countdownTimerHigh]
    and a
        ret nz

    ld a, [$cedd]
    ld b, a
    ld a, [currentRoomSong]
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

poseFunc_0ECB: ; $12 and $1D
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
        call samus_unmorphInAir
        ld a, $10
        ld [$d049], a
    jr jr_000_0f6c

poseFunc_0EF7: ; $0F - Knockback
    ldh a, [hInputRisingEdge]
    bit PADB_A, a
    jr z, jr_000_0f6c

    call Call_000_1e88
    ret c

    xor a
    ld [samusInvulnerableTimer], a
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
    ld a, [waterContactFlag]
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

poseFunc_0F38: ; $10
    ldh a, [hInputRisingEdge]
    bit PADB_UP, a
    jp z, Jump_000_0f47
        call samus_unmorphInAir
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
    ld [samusInvulnerableTimer], a
    ld a, $2e
    ld [$d026], a
    ld a, $06
    ld [samusPose], a
    xor a
    ld [$d010], a
    ld a, $01
    ld [$cec0], a
    ret

poseFunc_0F6C: ; $11
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
        call samus_moveRightInAir.damageBoost
    jr_000_0fb6:
        ld a, [$d00f]
        cp $ff
            ret nz
        call samus_moveLeftInAir.damageBoost
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

; 00:0FD8
    nop
    nop
    nop
    nop
    nop
    nop
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

; 00:0FF6
    db $fd, $fd, $fd, $fd, $fe, $fd, $fe, $fd, $fe, $fe, $fe, $fe, $fe, $fe, $ff, $fe
    db $fe, $ff, $fe, $ff, $fe, $ff, $ff, $00, $00, $00, $00, $01, $01, $02, $01, $02
    db $01, $02, $02, $01, $02, $02, $02, $02, $02, $02, $03, $02, $03, $02, $03, $03
    db $03, $03, $80

poseFunc_1029: ; $0E
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

poseFunc_1083: ; $0B
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
        call nz, samus_spiderRight
    ld a, [$d042]
    bit 1, a
        call nz, samus_spiderLeft
    ld a, [$d042]
    bit 2, a
        call nz, samus_spiderUp
    ld a, [$d042]
    bit 3, a
        call nz, samus_spiderDown
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
        call nz, samus_spiderRight
    ld a, [$d042]
    bit 1, a
        call nz, samus_spiderLeft
    ld a, [$d042]
    bit 2, a
        call nz, samus_spiderUp
    ld a, [$d042]
    bit 3, a
        call nz, samus_spiderDown
ret

samus_spiderRight: ; 00:1132
    call samus_rollRight.spider
    ld a, [$d035]
    ld [$d043], a
ret

samus_spiderLeft: ; 00:113C
    call samus_rollLeft.spider
    ld a, [$d036]
    ld [$d043], a
ret

samus_spiderUp: ; 00:1146
    ld a, $01
    call Call_000_1d98
    ld a, [$d037]
    ld [$d043], a
ret

samus_spiderDown: ; 00:1152
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

poseFunc_1170: ; $0D
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
        call samus_spiderRight
        ret
    jr_000_11c6:
        ldh a, [hInputPressed]
        bit PADB_LEFT, a
        jr z, jr_000_11d0
            call samus_rollLeft.morph
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

poseFunc_11E4: ; $0C
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
        call samus_spiderRight
        jr jr_000_1209
    jr_000_1200:
        ldh a, [hInputPressed]
        bit PADB_LEFT, a
        jr z, jr_000_1209
            call samus_spiderLeft
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

poseFunc_124B: ; $08
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

    ld a, [acidContactFlag]
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
        call samus_unmorphInAir
        ld a, $10
        ld [$d049], a
        jr jr_000_12dd
    jr_000_1295:

    ldh a, [hInputPressed]
    bit PADB_RIGHT, a
    jr z, jr_000_12aa

    call samus_moveRightInAir
    ld a, [samusItems]
    bit itemBit_spider, a
    jr z, jr_000_12aa

    ld a, [$d035]
    jr jr_000_12bd

jr_000_12aa:
    ldh a, [hInputPressed]
    bit PADB_LEFT, a
    jr z, jr_000_12bd

    call samus_moveLeftInAir
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

poseFunc_12F5: ; $07
    ldh a, [hInputRisingEdge]
    bit PADB_A, a
    jr z, jr_000_1335

    ld a, [acidContactFlag]
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

    call samus_moveRightInAir
    jr jr_000_1349

jr_000_1340:
    ldh a, [hInputPressed]
    bit PADB_LEFT, a
    jr z, jr_000_1349

    call samus_moveLeftInAir

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

; 001386
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

poseFunc_13B7: ; $00
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
    ld a, [waterContactFlag]
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
        ld a, [samusFacingDirection]
        cp $01
        jr z, jr_000_1443
            ld a, $83
            ld [samusPose], a
            ld a, $01
            ld [samusFacingDirection], a
            ld a, $02
            ld [$d02c], a
            ld a, $04
            ld [$cec0], a
            ret
        jr_000_1443:
            call samus_walkRight
                ret c
            ld a, $01
            ld [samusFacingDirection], a
            ld a, $03
            ld [samusPose], a
            ret
    jr_000_1452:

    ldh a, [hInputPressed]
    bit PADB_LEFT, a
    jr z, jr_000_1483
        ld a, [samusFacingDirection]
        cp $00
        jr z, jr_000_1474
            ld a, $83
            ld [samusPose], a
            ld a, $00
            ld [samusFacingDirection], a
            ld a, $02
            ld [$d02c], a
            ld a, $04
            ld [$cec0], a
            ret
        jr_000_1474:
            call samus_walkLeft
                ret c
            ld a, $00
            ld [samusFacingDirection], a
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
    ld a, [waterContactFlag]
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

poseFunc_14D6: ; $03
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
    ld a, [waterContactFlag]
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

    ld a, [samusFacingDirection]
    cp $01
    jr z, jr_000_155d
        ld a, $83
        ld [samusPose], a
        ld a, $01
        ld [samusFacingDirection], a
        ld a, $02
        ld [$d02c], a
        ld a, $04
        ld [$cec0], a
        ret
    jr_000_155d:
        call samus_walkRight
            ret nc
        xor a
        ld [samusPose], a
        ret


jr_000_1566:
    ldh a, [hInputPressed]
    bit PADB_LEFT, a
    jr z, jr_000_1591

    ld a, [samusFacingDirection]
    cp $00
    jr z, jr_000_1588
        ld a, $83
        ld [samusPose], a
        ld a, $00
        ld [samusFacingDirection], a
        ld a, $02
        ld [$d02c], a
        ld a, $04
        ld [$cec0], a
        ret
    jr_000_1588:
        call samus_walkLeft
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
    ld a, [waterContactFlag]
    and a
    jr z, jr_000_15f3

    ld a, [$d026]
    add $10
    ld [$d026], a

jr_000_15f3:
    ret

poseFunc_15F4: ; $04
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
    ld a, [samusFacingDirection]
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
    ld [samusFacingDirection], a
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
    ld a, [samusFacingDirection]
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
    ld [samusFacingDirection], a
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
    ld a, [waterContactFlag]
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

poseFunc_1701: ; $05 - Morph ball
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
            call samus_rollRight.morph
            ld a, [$d035]
            ret
        jr_000_1779:
            ldh a, [hInputPressed]
            bit PADB_LEFT, a
                ret z
            call samus_rollLeft.morph
            ld a, [$d036]
            ret
; end proc

; Activate spider ball
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

poseFunc_179F: ; $06
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

poseFunc_17BB: ; $01
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

    ld a, [acidContactFlag]
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
            call samus_unmorphInAir
            ld a, $10
            ld [$d049], a
    jr_000_181b:

    ldh a, [hInputPressed]
    bit PADB_RIGHT, a
    jr z, jr_000_1824

    call samus_moveRightInAir

jr_000_1824:
    ldh a, [hInputPressed]
    bit PADB_LEFT, a
    jr z, jr_000_182d

    call samus_moveLeftInAir

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

; 00:184A
    db $fe, $fe, $fe, $fe, $ff, $fe, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $ff, $00, $ff
    db $ff, $00, $ff, $00, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $01
    db $00, $01, $01, $00, $01, $01, $01, $01, $01, $01, $02, $01, $02, $01, $02, $02
    db $02, $02, $03, $02, $02, $03, $02, $02, $03, $02, $03, $02, $03, $02, $03, $02
    db $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $80

; 00:1899
    nop
    nop
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

poseFunc_18E8: ; $02
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
    ld [samusFacingDirection], a
    ret


jr_000_195f:
    ld a, [$d00f]
    and a
    jr nz, jr_000_1970
        ldh a, [hInputPressed]
        bit PADB_UP, a
        jr z, jr_000_1970
            ldh a, [frameCounter]
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

    ld a, [acidContactFlag]
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
        call samus_moveRightInAir.damageBoost
        ret
    jr_000_19bc:
        ld a, [$d00f]
        cp $ff
            ret nz
        call samus_moveLeftInAir.damageBoost
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

poseFunc_19E2: ; $09 and $0A
    ldh a, [hInputPressed]
    bit PADB_A, a
    jr z, jr_000_1a1b

    ldh a, [frameCounter]
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

    call samus_moveRightInAir
    ret


jr_000_1a10:
    ldh a, [hInputPressed]
    bit PADB_LEFT, a
    jr z, jr_000_1a1a

    call samus_moveLeftInAir
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
    ld hl, table_1A3F
    add hl, de
    ld a, [hl]
    ld [$d00f], a
    ld a, $02
    ld [samusPose], a
    ret

table_1A3F:
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
    call samus_getTileIndex
    ld hl, samusSolidityIndex
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

; Called when landing (unmorphed) and uncrouching
Call_000_1b37: ; 00:1B37
    ld a, $04
    ld [$cec0], a
    ldh a, [hSamusXPixel]
    add $0c
    ld [$c204], a
    ldh a, [hSamusYPixel]
    add $10
    ld [$c203], a
    call samus_getTileIndex
    ld hl, samusSolidityIndex
    cp [hl]
        ret c
    ldh a, [hSamusXPixel]
    add $14
    ld [$c204], a
    call samus_getTileIndex
    ld hl, samusSolidityIndex
    cp [hl]
        ret c
    ; Set pose to crouching
    xor a
    ld [samusPose], a
    ld a, $04
    ld [$cec0], a
ret


jr_000_1b6b:
    ldh a, [hSamusYPixel]
    add $18
    ld [$c203], a
    call samus_getTileIndex
    ld hl, samusSolidityIndex
    cp [hl]
    jr c, jr_000_1b9a

    ldh a, [hSamusXPixel]
    add $14
    ld [$c204], a
    call samus_getTileIndex
    ld hl, samusSolidityIndex
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


samus_unmorphInAir: ; 00:1BB3
    ldh a, [hSamusYPixel]
    add $08
    ld [$c203], a
    ldh a, [hSamusXPixel]
    add $0b
    ld [$c204], a
    call samus_getTileIndex
    ld hl, samusSolidityIndex
    cp [hl]
        jr c, .exit

    ldh a, [hSamusXPixel]
    add $14
    ld [$c204], a
    call samus_getTileIndex
    ld hl, samusSolidityIndex
    cp [hl]
        jr c, .exit

    ldh a, [hSamusYPixel]
    add $18
    ld [$c203], a
    ldh a, [hSamusXPixel]
    add $0b
    ld [$c204], a
    call samus_getTileIndex
    ld hl, samusSolidityIndex
    cp [hl]
        jr c, .exit

    ldh a, [hSamusXPixel]
    add $14
    ld [$c204], a
    call samus_getTileIndex
    ld hl, samusSolidityIndex
    cp [hl]
        jr c, .exit

    ld a, $07
    ld [samusPose], a
    ld a, $04
    ld [$cec0], a
ret
    .exit:
ret

; Movement functions
; Move right (walking)
samus_walkRight: ; 00:1C0D
    ld a, $01
    ld [samusFacingDirection], a
    ld b, $01
    ld a, [waterContactFlag]
    and a
    jr nz, .endIf
        ld a, [samusItems]
        bit itemBit_varia, a
        jr z, .else
            ld b, $02
            jr .endIf
        .else:
            ldh a, [frameCounter]
            and $01
            add $01
            ld b, a
    .endIf:

    ldh a, [hSamusXPixel]
    add b
    ldh [hSamusXPixel], a
    ldh a, [hSamusXScreen]
    adc $00
    and $0f
    ldh [hSamusXScreen], a
    ld [$c204], a
    call Call_000_1de2
    jr nc, .keepResults
        ld a, [$d027]
        ldh [hSamusXPixel], a
        ld a, [$d028]
        ldh [hSamusXScreen], a
        ret
    .keepResults:
        ld a, b
        ld [$d035], a
        ret
; end proc

samus_walkLeft: ; 00:1C51
    xor a
    ld [samusFacingDirection], a
    ld b, $01
    ld a, [waterContactFlag]
    and a
    jr nz, .endIf
        ld a, [samusItems]
        bit itemBit_varia, a
        jr z, .else
            ld b, $02
            jr .endIf
        .else:
            ldh a, [frameCounter]
            and $01
            add $01
            ld b, a
    .endIf:

    ldh a, [hSamusXPixel]
    sub b
    ldh [hSamusXPixel], a
    ldh a, [hSamusXScreen]
    sbc $00
    and $0f
    ldh [hSamusXScreen], a
    ld [$c204], a
    call Call_000_1dd6
    jr nc, .keepResults
        ld a, [$d027]
        ldh [hSamusXPixel], a
        ld a, [$d028]
        ldh [hSamusXScreen], a
        ret
    .keepResults:
        ld a, b
        ld [$d036], a
        ret
; end proc

samus_rollRight:
    .spider: ; 00:1C94 - Entry point for spider
        ld a, $01
        jr .start
    .morph: ; 00:1C98 - Entry point for morph
        ld a, $02
.start:
    ld b, a
    ld a, $01
    ld [samusFacingDirection], a
    ldh a, [hSamusXPixel]
    add b
    ldh [hSamusXPixel], a
    ldh a, [hSamusXScreen]
    adc $00
    and $0f
    ldh [hSamusXScreen], a
    ld [$c204], a
    call Call_000_1de2
    jr nc, .keepResults
        ; Revert to previous position
        ld a, [$d027]
        ldh [hSamusXPixel], a
        ld a, [$d028]
        ldh [hSamusXScreen], a
        ret
    .keepResults:
        ld a, b
        ld [$d035], a
        ret


samus_rollLeft:
    .spider: ; 00:1CC5 - Entry point for spider
        ld a, $01
        jr .start
    .morph: ; 00:1CC9 - Entry point for morph
        ld a, $02
.start:
    ld b, a
    xor a
    ld [samusFacingDirection], a

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


samus_moveRightInAir: ; 00:1CF5
    ld a, $01
    ld [samusFacingDirection], a
.damageBoost: ; 00:1CFA Alternate entry
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
    jr nc, .keepResults
        ; Revert to previous position
        ld a, [$d027]
        ldh [hSamusXPixel], a
        ld a, [$d028]
        ldh [hSamusXScreen], a
        ret
    .keepResults:
        ld a, b
        ld [$d035], a
        ret


samus_moveLeftInAir: ; 00:1D22
    xor a
    ld [samusFacingDirection], a
.damageBoost: ; 00:1D26 - Alternate entry
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
    jr nc, .keepResults
        ; Revert to previous position
        ld a, [$d027]
        ldh [hSamusXPixel], a
        ld a, [$d028]
        ldh [hSamusXScreen], a
        ret
    .keepResults:
        ld a, b
        ld [$d036], a
        ret


Call_000_1d4e: ; move down
    bit 7, a
        jr nz, jr_000_1d96 ; Move up if negative
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
    jr nc, .keepResults
        ld a, [$d029]
        ldh [hSamusYPixel], a
        ld a, [$d02a]
        ldh [hSamusYScreen], a
        scf
        ret
    .keepResults:
        ld a, [waterContactFlag]
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

Call_000_1d98: ; move up
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
    jr nc, .keepResults
        ld a, $56
        ld [$d026], a
        ld a, [$d029]
        ldh [hSamusYPixel], a
        ld a, [$d02a]
        ldh [hSamusYScreen], a
        ret
    .keepResults:
        ld a, [waterContactFlag]
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

; BG collision functions
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
    call samus_getTileIndex
    ld hl, samusSolidityIndex
    cp [hl]
    jr c, jr_000_1e84

jr_000_1e38:
    ld a, [$d030]
    ld b, a
    ldh a, [hSamusYPixel]
    add b
    ld [$c203], a
    call samus_getTileIndex
    ld hl, samusSolidityIndex
    cp [hl]
    jr c, jr_000_1e84

jr_000_1e4b:
    ld a, [$d02f]
    ld b, a
    ldh a, [hSamusYPixel]
    add b
    ld [$c203], a
    call samus_getTileIndex
    ld hl, samusSolidityIndex
    cp [hl]
    jr c, jr_000_1e84

jr_000_1e5e:
    ld a, [$d02e]
    ld b, a
    ldh a, [hSamusYPixel]
    add b
    ld [$c203], a
    call samus_getTileIndex
    ld hl, samusSolidityIndex
    cp [hl]
    jr c, jr_000_1e84

jr_000_1e71:
    ld a, [$d02d]
    ld b, a
    ldh a, [hSamusYPixel]
    add b
    ld [$c203], a
    call samus_getTileIndex
    ld hl, samusSolidityIndex
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
    call samus_getTileIndex
    ld hl, samusSolidityIndex
    cp [hl]
    ld h, HIGH(collisionArray)
    ld l, a
    ld a, [hl]
    bit blockType_water, a
    jr z, jr_000_1ebf
        ld a, $ff
        ld [waterContactFlag], a
        ld a, [hl]
    jr_000_1ebf:

    bit blockType_up, a
    jr z, jr_000_1ec4
        ccf
    jr_000_1ec4:

    ld a, [hl]
    bit blockType_acid, a
    jr z, jr_000_1ed6
        ld a, $40
        ld [acidContactFlag], a
        push af
        ld a, [acidDamageValue]
        call applyAcidDamage
        pop af
    jr_000_1ed6:

    jr c, jr_000_1f0b

    ldh a, [hSamusXPixel]
    add $14
    ld [$c204], a
    call samus_getTileIndex
    ld hl, samusSolidityIndex
    cp [hl]
    ld h, HIGH(collisionArray)
    ld l, a
    ld a, [hl]
    bit blockType_water, a
    jr z, jr_000_1ef4
        ld a, $ff
        ld [waterContactFlag], a
        ld a, [hl]
    jr_000_1ef4:
    
    bit blockType_up, a
    jr z, jr_000_1ef9

    ccf

jr_000_1ef9:
    ld a, [hl]
    bit blockType_acid, a
    jr z, jr_000_1f0b

    ld a, $40
    ld [acidContactFlag], a
    push af
    ld a, [acidDamageValue]
    call applyAcidDamage
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
    call samus_getTileIndex
    ld hl, samusSolidityIndex
    cp [hl]
    ld h, HIGH(collisionArray)
    ld l, a
    ld a, [hl]
    bit blockType_water, a
    jr z, jr_000_1f4e
        ld a, $31 ; Set to $FF in every other circumstance (why?)
        ld [waterContactFlag], a
    jr_000_1f4e:

    ld a, [hl]
    bit blockType_save, a
    jr z, jr_000_1f58
        ld a, $ff
        ld [saveContactFlag], a
    jr_000_1f58:

    ld a, [hl]
    bit blockType_down, a
    jr z, jr_000_1f62
        ld a, [samusPose]
        scf
        ccf
    jr_000_1f62:

    ld a, [hl]
    bit blockType_acid, a
    jr z, jr_000_1f74
        ld a, $40
        ld [acidContactFlag], a
        push af
        ld a, [acidDamageValue]
        call applyAcidDamage
        pop af
    jr_000_1f74:

    jr c, jr_000_1fbb

    ldh a, [hSamusXPixel]
    add $14
    ld [$c204], a
    call samus_getTileIndex
    ld hl, samusSolidityIndex
    cp [hl]
    ld h, HIGH(collisionArray)
    ld l, a
    ld a, [hl]
    bit blockType_water, a
    jr z, jr_000_1f91
        ld a, $ff
        ld [waterContactFlag], a
    jr_000_1f91:

    ld a, [hl]
    bit blockType_save, a
    jr z, jr_000_1f9b
        ld a, $ff
        ld [saveContactFlag], a
    jr_000_1f9b:

    ld a, [hl]
    bit blockType_down, a
    jr z, jr_000_1fa2
        scf
        ccf
    jr_000_1fa2:

    ld a, [hl]
    bit blockType_acid, a
    jr z, jr_000_1fb4
        ld a, $40
        ld [acidContactFlag], a
        push af
        ld a, [acidDamageValue]
        call applyAcidDamage
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
    call samus_getTileIndex
    ld hl, samusSolidityIndex
    cp [hl]
    jr nc, jr_000_1fe0

    ld h, HIGH(collisionArray)
    ld l, a
    ld a, [hl]
    bit blockType_acid, a
    jr z, jr_000_1fdb
        ld a, $40
        ld [acidContactFlag], a
        ld a, [acidDamageValue]
        call applyAcidDamage
    jr_000_1fdb:
    
    scf
    ret


jr_000_1fdd:
    scf
    ccf
    ret


jr_000_1fe0:
    ld h, HIGH(collisionArray)
    ld l, a
    ld a, [hl]
    bit blockType_acid, a
    jr z, jr_000_1fdd
        ld a, $40
        ld [acidContactFlag], a
        ld a, [acidDamageValue]
        call applyAcidDamage
    jr jr_000_1fdd

; end of BG collision functions?

samus_getTileIndex: ; 00:1FF5
    call getTilemapAddress

    ; Adjust base address for collision depending on the tilemap being used
    ld a, [$c219]
    and $08
    jr z, .endIf_A
        ld a, $04
        add h
        ld h, a
        ld [$c216], a
    .endIf_A

    ; What's with this double read from VRAM? Insurance?
    .waitLoop_A: ; Wait for h-blank
        ldh a, [rSTAT]
        and $03
    jr nz, .waitLoop_A

    ld b, [hl]

    .waitLoop_B: ; Wait for h-blank
        ldh a, [rSTAT]
        and $03
    jr nz, .waitLoop_B

    ld a, [hl]
    and b
    ld b, a

    ; Check for spike collision
    ;  I presume this is done here because spike collision pertains to every moment direction and every state (?)
    ld a, [samusInvulnerableTimer]
    and a
    jr nz, .endIf_B
        ld h, HIGH(collisionArray)
        ld a, b
        ld l, a
        ld a, [hl]
        bit blockType_spike, a
        jr z, .endIf_B
            ; Play sfx
            ld a, $04
            ld [$cec0], a
            ; Samus damaged flag
            ld a, $01
            ld [$c422], a
            ; Damage boost up
            xor a
            ld [$c423], a
            ; Samus damage
            ld a, [spikeDamageValue]
            ld [$c424], a
    .endIf_B:

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
clearProjectileArray: ; 00:21EF
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
        jp z, samusShoot_longJump
    ld a, [$d090]
    cp $22
        jp z, samusShoot_longJump
    ldh a, [hInputRisingEdge]
    bit PADB_SELECT, a
        jp z, samusShoot_longJump

; Switch between missiles and beams
toggleMissiles: ; 00:2212
    ; Check if missiles are active
    ld a, [samusActiveWeapon]
    cp $08
    jr nz, .endIf
        ; Switch to beam
        ld a, [samusBeam]
        ld [samusActiveWeapon], a
        ld hl, gfxInfo_cannonBeam
        call Call_000_2753
        ; Play sound effect
        ld a, $15
        ld [$cec0], a
            ret
    .endIf:
    ; Save current beam (unnecessary code?)
    ld a, [samusActiveWeapon]
    ld [samusBeam], a
    ; Switch to missiles
    ld a, $08
    ld [samusActiveWeapon], a
    ld hl, gfxInfo_cannonMissile
    call Call_000_2753
    ; Play sound effect
    ld a, $15
    ld [$cec0], a
ret

; 00:2242
gfxInfo_cannonMissile: db BANK(gfx_cannonMissile)
    dw gfx_cannonMissile, vramDest_cannon, $0020
; 00:2249
gfxInfo_cannonBeam: db BANK(gfx_cannonBeam) 
    dw gfx_cannonBeam, vramDest_cannon, $0020

; Function returns the tile number for a particular x-y tile on the tilemap
enemy_getTileIndex: ; 00:2250 - Called by enemy routines
    ; Adjust enemy coordinates (in camera-space) to map-space coordinates
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
    
beam_getTileIndex: ; 00:2266 - Entry point for beam routines
    call getTilemapAddress
    ld a, [$c219]
    and $08
    jr z, .endIf
    ld a, $04
    add h
    ld h, a
    ld [$c216], a
    .endIf

    .waitLoop_A:
        ldh a, [rSTAT]
        and $03
    jr nz, .waitLoop_A

    ld b, [hl]

    .waitLoop_B:
        ldh a, [rSTAT]
        and $03
    jr nz, .waitLoop_B

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

; Given pixels coordinates in y:[$C203], x:[$C204]
;  returns the tilemap address in [$C215] and [$C216]
getTilemapAddress: ; 00:22BC
    ld a, [$c203]
    sub $10
    ld b, $08
    ld de, $0020
    ld hl, $9800 - $20 ;$97e0

    .loop:
        add hl, de
        sub b
    jr nc, .loop

    ; subtract 8 and divide by 8
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

;------------------------------------------------------------------------------
; Screen Transition decoder
executeDoorScript: ; 00:239C
    ; Check if a door script is queued up
    ld a, [doorIndexLow]
    ld b, a
    ld a, [doorIndexHigh]
    or b
    jp z, .endDoorScript

    ld a, [$d064]
    ldh [hOamBufferIndex], a
    call clearUnusedOamSlots_longJump ; Clear unused OAM
    call waitOneFrame
    call OAM_DMA
	
	; From the door index, get the pointer and load the script
    ld a, BANK(doorPointerTable)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ; Get index to door script pointer
    ld a, [doorIndexLow]
    ld e, a
    ld a, [doorIndexHigh]
    ld d, a
    sla e
    rl d
    ld hl, doorPointerTable
    add hl, de
    ; Load door script pointer into HL
    ld a, [hl+]
    ld e, a
    ld a, [hl]
    ld h, a
    ld a, e
    ld l, a
	; Load door script into buffer
    ld b, doorScriptBufferSize
    ld de, doorScriptBuffer
    .loadDoor:
        ld a, [hl+]
	    ld [de], a
        inc de
        dec b
    jr nz, .loadDoor

    ld hl, doorScriptBuffer

.readOneToken:
    ld a, [hl]
    cp $ff ; END_DOOR
    jp nz, .doorToken_load
        inc hl
        jp .endDoorScript

    .doorToken_load:
    and $f0
    cp $b0 ; LOAD_BG/LOAD_SPR
    jr nz, .doorToken_copy
        xor a
        ld [$d088], a
        ld [saveContactFlag], a
        ld a, $88
        ldh [rWY], a
        call door_loadGraphics
        jp .nextToken
        
    .doorToken_copy:
    cp $00 ; COPY_DATA/COPY_BG/COPY_SPR
    jr nz, .doorToken_tiletable
        xor a
        ld [$d088], a
        ld [saveContactFlag], a
        ld a, $88
        ldh [rWY], a
        call door_copyData
        jp .nextToken

    .doorToken_tiletable:
    cp $10 ; TILETABLE
    jr nz, .doorToken_collision
        call door_loadTiletable
        jp .nextToken

    .doorToken_collision:
    cp $20 ; COLLISION
    jr nz, .doorToken_solidity
        call door_loadCollision
        jp .nextToken

    .doorToken_solidity:
    cp $30 ; SOLIDITY
    jr nz, .doorToken_warp
        ld a, [hl+]
        push hl
            ; Extract table index from token and get the base address in the solidity table
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
            ; Update solidity indexes (working and save buffer copies)
            ld a, [hl+]
            ld [samusSolidityIndex], a
            ld [saveBuf_samusSolidityIndex], a
            ld a, [hl+]
            ld [enemySolidityIndex_canon], a
            ld [saveBuf_enemySolidityIndex], a
            ld a, [hl+]
            ld [beamSolidityIndex], a
            ld [saveBuf_beamSolidityIndex], a
        pop hl
        jp .nextToken

    .doorToken_warp:
    cp $40 ; WARP
    jr nz, .doorToken_escapeQueen
        call door_warp
        ld a, $01
        ld [$c458], a
        ld a, [$d08b]
        and $0f
        ld [$d08b], a
        jp .nextToken

    .doorToken_escapeQueen:
    cp $50 ; ESCAPE QUEEN
    jr nz, .doorToken_damage
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
        ; Source
        ld a, LOW(hudBaseTilemap) ; bank 5
        ldh [$b1], a
        ld a, HIGH(hudBaseTilemap)
        ldh [$b2], a
        ; Dest
        ld a, LOW(vramDest_statusBar)
        ldh [$b3], a
        ld a, HIGH(vramDest_statusBar)
        ldh [$b4], a
        ; Length
        ld a, $14
        ldh [$b5], a
        ld a, $00
        ldh [$b6], a
        
        ld a, $05
        ld [$d065], a
        call Call_000_27ba
        xor a
        ld [$c436], a
        jp .nextToken

    .doorToken_damage:
    cp $60 ; DAMAGE
    jr nz, .doorToken_exitQueen
        inc hl
        ld a, [hl+]
        ld [acidDamageValue], a
        ld [saveBuf_acidDamageValue], a
        ld a, [hl+]
        ld [spikeDamageValue], a
        ld [saveBuf_spikeDamageValue], a
        jp .nextToken

    .doorToken_exitQueen:
    cp $70 ; EXIT_QUEEN
    jr nz, .doorToken_enterQueen
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
            
            ld a, LOW(hudBaseTilemap) ; bank 5
            ldh [$b1], a
            ld a, HIGH(hudBaseTilemap)
            ldh [$b2], a
            
            ld a, LOW(vramDest_statusBar)
            ldh [$b3], a
            ld a, HIGH(vramDest_statusBar)
            ldh [$b4], a
            
            ld a, $14
            ldh [$b5], a
            ld a, $00
            ldh [$b6], a
            
            ld a, $05
            ld [$d065], a
            call Call_000_27ba
        pop hl
        jp .nextToken

    .doorToken_enterQueen:
    cp $80 ; ENTER_QUEEN
    jr nz, .doorToken_compare
        xor a
        ld [$d03b], a
        ld [$d03c], a
        ldh [hOamBufferIndex], a
        ld [$d0a6], a
        ld a, $02
        ld [$cedc], a
        push hl
        call clearAllOam_longJump
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
        jp .nextToken

    .doorToken_compare:
    cp $90 ; IF_MET_LESS - comparison operator
    jr nz, .doorToken_fadeout
        inc hl
        ; Compare metroid count to operand
        ld a, [metroidCountReal]
        ld b, a
        ld a, [hl+]
        cp b
        jr nc, .loadNewScript
            inc hl
            inc hl
            jp .nextToken
    
        .loadNewScript:
        ld a, [hl+]
        ld [doorIndexLow], a
        ld a, [hl]
        ld [doorIndexHigh], a
        jp executeDoorScript

    .doorToken_fadeout:
    cp $a0 ; FADEOUT
    jr nz, .doorToken_song

        inc hl
        push hl
        call waitOneFrame
        call waitOneFrame
        call waitOneFrame
        call waitOneFrame
        ld a, $2f
        ld [countdownTimerLow], a
    
        .fadeLoop:
            ld hl, .fadePaletteTable
            ld a, [countdownTimerLow]
            and $f0
            swap a
            ld e, a
            ld d, $00
            add hl, de
            ld a, [hl]
            ld [bg_palette], a
            ld [ob_palette0], a
            call waitOneFrame
            ld a, [countdownTimerLow]
            cp $0e
        jr nc, .fadeLoop
    
        pop hl
        xor a
        ld [countdownTimerLow], a
        jp .nextToken
    
    .fadePaletteTable: db $ff, $fb, $e7 ; 00:259B

.doorToken_song:
    cp $c0 ; SONG
    jr nz, .doorToken_item
        ; What the heck is this spaghetti code?
        ld a, [$cedf]
        cp $0e
        jr z, .song_branchC
            ld a, [hl+]
            and $0f
            cp $0a
            jr z, .song_branchB    
                ld [$cedc], a
                ld [currentRoomSong], a
                cp $0b
                jr nz, .song_branchA
                    ld a, $ff
                    ld [$d0a6], a
                    xor a
                    ld [$d0a5], a
                    jp .nextToken
            
                .song_branchA:
                xor a
                ld [$d0a5], a
                ld [$d0a6], a
                jp .nextToken
        
            .song_branchB:
            ld a, $ff
            ld [$cedc], a
            ld [currentRoomSong], a
            xor a
            ld [$d0a5], a
            ld a, $ff
            ld [$d0a6], a
            jp .nextToken
    
        .song_branchC:
        ld a, [hl+]
        and $0f
        cp $0a
        jr z, .song_branchE
            ld [$d0a5], a
            cp $0b
            jr nz, .song_branchD
                ld a, $ff
                ld [$d0a6], a
                jp .nextToken
        
            .song_branchD:
            xor a
            ld [$d0a6], a
            jp .nextToken
    
        .song_branchE:
        ld a, $ff
        ld [$d0a5], a
        ld [$d0a6], a
        jp .nextToken
        
    .unreferencedTable: db $04, $05, $06, $07, $08, $09, $10, $12 ; 00:260C

    .doorToken_item:
    cp $d0 ; ITEM
    jp nz, .nextToken
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

        ld a, LOW(vramDest_item)
        ldh [$b3], a
        ld a, HIGH(vramDest_item)

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
        ld a, LOW(vramDest_itemFont)
        ldh [$b3], a
        ld a, HIGH(vramDest_itemFont)
        ldh [$b4], a
        ; Write length
        ld a, $30
        ldh [$b5], a
        ld a, $02
        ldh [$b6], a
        call Call_000_27ba
    
        pop hl
        ld a, BANK(itemTextPointerTable)
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
        ld hl, itemTextPointerTable
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
        
        ld a, LOW(vramDest_itemText)
        ldh [$b3], a
        ld a, HIGH(vramDest_itemText)
        ldh [$b4], a
        ld a, $10
        ldh [$b5], a
        ld a, $00
        ldh [$b6], a
        call Call_000_27ba
        pop hl
        jr .nextToken

.nextToken:
    call waitOneFrame
    jp .readOneToken

.endDoorScript:
    ld a, [$c458]
    ld [$c44b], a
    xor a
    ld [doorIndexLow], a
    ld [doorIndexHigh], a
    ld [$c458], a
    ld [$d0a8], a
ret


door_loadGraphics: ; door script load graphics routine
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
        ld [saveBuf_enGfxSrcLow], a
        
        ld a, [hl+]
        ldh [$b2], a
        ld [saveBuf_enGfxSrcHigh], a
        
        ld a, LOW(vramDest_enemies)
        ldh [$b3], a
        ld a, HIGH(vramDest_enemies)
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
        ld [saveBuf_bgGfxSrcBank], a
        ld [rMBC_BANK_REG], a
        
        ld a, [hl+]
        ldh [$b1], a
        ld [saveBuf_bgGfxSrcLow], a
        ld a, [hl+]
        ldh [$b2], a
        ld [saveBuf_bgGfxSrcHigh], a
        
        ld a, LOW(vramDest_bgTiles)
        ldh [$b3], a
        ld a, HIGH(vramDest_bgTiles)
        ldh [$b4], a
        
        ld a, $00
        ldh [$b5], a
        ld a, $08
        ldh [$b6], a
    jr jr_000_27ba

door_copyData: ; door script copy data routine
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
    ld [saveBuf_bgGfxSrcBank], a
    ld [rMBC_BANK_REG], a
    ld a, [hl+]
    ldh [$b1], a
    ld [saveBuf_bgGfxSrcLow], a
    ld a, [hl+]
    ldh [$b2], a
    ld [saveBuf_bgGfxSrcHigh], a
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
    ld [saveBuf_enGfxSrcLow], a
    ld a, [hl+]
    ldh [$b2], a
    ld [saveBuf_enGfxSrcHigh], a
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
    ld a, BANK(drawHudMetroid)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call drawHudMetroid
    call clearUnusedOamSlots_longJump

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
    ld a, BANK(drawHudMetroid)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call drawHudMetroid
    call clearUnusedOamSlots_longJump
    call waitOneFrame
    ldh a, [$b4]
    cp $85
    jr c, jr_000_2804

    xor a
    ld [$d08c], a
    ret


door_loadTiletable:
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
    ld [saveBuf_tiletableSrcLow], a
    ld b, a
    ld a, [hl+]
    ld [saveBuf_tiletableSrcHigh], a
    ld h, a
    ld a, b
    ld l, a
    ld de, tiletableArray

    .loop:
        ld a, [hl+]
        ld [de], a
        inc de
        ld a, d
        cp $dc
    jr nz, .loop

    jp Jump_000_2918


door_loadCollision:
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
        ld [saveBuf_collisionSrcLow], a
        ld b, a
        ld a, [hl+]
        ld [saveBuf_collisionSrcHigh], a
        ld h, a
        ld a, b
        ld l, a
        ld de, collisionArray
    
        .loop:
            ld a, [hl+]
            ld [de], a
            inc de
            ld a, d
            cp $dd
        jr nz, .loop
    pop hl
ret


Call_000_2887:
    ld a, [hl+]
    and $0f
    ld [currentLevelBank], a
    ld [saveBuf_currentLevelBank], a
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
    call disableLCD
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
    ld [doorScrollDirection], a
    ld [$c205], a
    ldh [rSCY], a
    ld a, [bg_palette]
    cp $93
    jr z, jr_000_28f9

    ld a, $2f
    ld [$d09b], a

jr_000_28f9:
    pop hl
    ret


door_warp:
    ld a, [hl+]
    and $0f
    ld [currentLevelBank], a
    ld [saveBuf_currentLevelBank], a
    
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

Jump_000_2918: ; Rerender screen ahead of Samus
    ; Right
    ld a, [doorScrollDirection]
    cp $01
    jr z, jr_000_2939
    ; Left
    ld a, [doorScrollDirection]
    cp $02
    jp z, Jump_000_29c4
    ; Up
    ld a, [doorScrollDirection]
    cp $04
    jp z, Jump_000_2b04
    ; Down
    ld a, [doorScrollDirection]
    cp $08
    jp z, Jump_000_2a4f
    ; None
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
    ldh [hVBlankDoneFlag], a
    ld a, [bankRegMirror]
    ld [rMBC_BANK_REG], a
    pop hl
    pop de
    pop bc
    pop af
reti


Jump_000_2bf4:
    ldh a, [frameCounter]
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
    ld [deathAnimTimer], a

jr_000_2c42:
    ld a, [$c205]
    ldh [rSCY], a
    ld a, [$c206]
    ldh [rSCX], a
    call OAM_DMA
    ld a, [bankRegMirror]
    ld [rMBC_BANK_REG], a
    ld a, $01
    ldh [hVBlankDoneFlag], a
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

    .vBlankNotDone:
        ldh a, [hVBlankDoneFlag]
        and a
    jr z, .vBlankNotDone

    ldh a, [frameCounter]
    inc a
    ldh [frameCounter], a
    xor a
    ldh [hVBlankDoneFlag], a
    ld a, $c0
    ldh [hUnusedFlag_1], a
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
    ld a, [doorScrollDirection]
    and a
        ret nz
    ld a, [saveContactFlag]
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
    ld a, [debugFlag]
    and a
    jr z, jr_000_2cbe

    xor a
    ldh [hOamBufferIndex], a
    call clearUnusedOamSlots_longJump

jr_000_2cbe:
    xor a
    ld [debugItemIndex], a
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
    ; Change palette on a 32 frame cycle (16 frame light/dark phases)
    ld b, $e7
    ldh a, [frameCounter]
    bit 4, a
    jr z, .endIf
        ld b, $93
    .endIf:

    ld a, b
    ld [bg_palette], a
    ld [ob_palette0], a
    
    ld a, [debugFlag]
    and a
        jr nz, .debugBranch

    ; Unpause if start is pressed
    ldh a, [hInputRisingEdge]
    bit PADB_START, a
        ret z

    ; Return to main game mode if start is pressed
    ld a, $93
    ld [bg_palette], a
    ld [ob_palette0], a
    ld a, $02
    ld [$cfc7], a
    ld a, $04
    ldh [gameMode], a
ret

.debugBranch:
    call drawHudMetroid_longJump
    ldh a, [hInputRisingEdge]
    cp PADF_START
        jr nz, debugPauseMenu

    ; Return to main game mode if start is pressed
    ld a, $93
    ld [bg_palette], a
    ld [ob_palette0], a
    call clearUnusedOamSlots_longJump
    ld a, $02
    ld [$cfc7], a
    ld a, $04
    ldh [gameMode], a
ret


debugPauseMenu:
    ; Handle right input
    ldh a, [hInputRisingEdge]
    bit PADB_RIGHT, a
    jr z, jr_000_2d7a
        ldh a, [hInputPressed]
        bit PADB_B, a
        jr nz, jr_000_2d50
            ; Move debug cursor right
            ld a, [debugItemIndex]
            dec a
            and $07
            ld [debugItemIndex], a
            jr jr_000_2d7a
        jr_000_2d50:
    
        bit PADB_A, a
        jr z, jr_000_2d68
            ; Decrement metroid count
            ld a, [metroidCountReal]
            sub $01
            daa
            ld [metroidCountReal], a
            ld a, [metroidCountDisplayed]
            sub $01
            daa
            ld [metroidCountDisplayed], a
            jr jr_000_2d7a
        jr_000_2d68:
    
        ; Decrease Samus' energy tanks (minimum of zero)
        ld a, [samusEnergyTanks]
        and a
        jr z, jr_000_2d7a
            dec a
            ld [samusEnergyTanks], a
            ld [samusCurHealthHigh], a
            ld a, $99
            ld [samusCurHealthLow], a
    jr_000_2d7a:

    ; Handle left input
    ldh a, [hInputRisingEdge]
    bit PADB_LEFT, a
    jr z, jr_000_2dbc
        ldh a, [hInputPressed]
        bit PADB_B, a
        jr nz, jr_000_2d91
            ; Move debug cursor left
            ld a, [debugItemIndex]
            inc a
            and $07
            ld [debugItemIndex], a
            jr jr_000_2dbc
        jr_000_2d91:
    
        bit PADB_A, a
        jr z, jr_000_2da9
            ; Decrement metroid count
            ld a, [metroidCountReal]
            add $01
            daa
            ld [metroidCountReal], a
            ld a, [metroidCountDisplayed]
            add $01
            daa
            ld [metroidCountDisplayed], a
            jr jr_000_2dbc
        jr_000_2da9:
    
        ; Increase Samus' energy tanks (max 5)
        ld a, [samusEnergyTanks]
        cp $05
        jr z, jr_000_2dbc
            inc a
            ld [samusEnergyTanks], a
            ld [samusCurHealthHigh], a
            ld a, $99
            ld [samusCurHealthLow], a
    jr_000_2dbc:

    ; Handle A press
    ldh a, [hInputRisingEdge]
    bit PADB_A, a
    jr z, jr_000_2dd7
        ; Toggle item bit 
        ld b, %00000001 ; Initial bitmask
        ld a, [debugItemIndex]
    
        .bitmaskLoop:
            dec a
            cp $ff
                jr z, .exitLoop
            sla b
        jr .bitmaskLoop
        
        .exitLoop:
        
        ld a, [samusItems]
        xor b
        ld [samusItems], a
    jr_000_2dd7:

    ; Handle up input
    ldh a, [hInputRisingEdge]
    bit PADB_UP, a
    jr z, jr_000_2e07
        ldh a, [hInputPressed]
        bit PADB_B, a
        jr nz, jr_000_2def
            ; Increment weapon equipped
            ld a, [samusActiveWeapon]
            inc a
            ld [samusActiveWeapon], a
            ld [samusBeam], a
            jr jr_000_2e07
        jr_000_2def:
            ; Increment missiles
            ld a, [samusMaxMissilesLow]
            add $10
            daa
            ld [samusMaxMissilesLow], a
            ld [samusCurMissilesLow], a
            ld a, [samusMaxMissilesHigh]
            adc $00
            daa
            ld [samusMaxMissilesHigh], a
            ld [samusCurMissilesHigh], a
    jr_000_2e07:

    ; Handle down input
    ldh a, [hInputRisingEdge]
    bit PADB_DOWN, a
    jr z, jr_000_2e31
        ldh a, [hInputPressed]
        bit PADB_B, a
        jr nz, jr_000_2e1f
            ld a, [samusActiveWeapon]
            dec a
            ld [samusActiveWeapon], a
            ld [samusBeam], a
            jr jr_000_2e31
        jr_000_2e1f:
            ld a, [samusCurMissilesLow]
            sub $10
            daa
            ld [samusCurMissilesLow], a
            ld a, [samusCurMissilesHigh]
            sbc $00
            daa
            ld [samusCurMissilesHigh], a
    jr_000_2e31:

    ; Render logic
    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ; Display debug cursor
    ld a, $58
    ldh [hSpriteYPixel], a
    ld a, [debugItemIndex]
    swap a
    srl a
    xor $ff
    add $69
    ldh [hSpriteXPixel], a
    ld a, [debugItemIndex]
    call $4b09
    ; Display item toggle bits
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
    ld a, [samusActiveWeapon]
    call debug_drawNumber
    
    ldh a, [hOamBufferIndex]
    ld [maxOamPrevFrame], a

    ; Save if pressing select and standing or morphing
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
    ld a, [samusInvulnerableTimer]
    and a
    ret nz

    ld a, [$c424]
    call Call_000_2f57
    ; Give Samus i-frames
    ld a, $33
    ld [samusInvulnerableTimer], a
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


Call_000_2f29: ; Apply queen stomach damage
    ldh a, [frameCounter]
    and $07
    ret nz

    ld a, $07
    ld [$ced5], a
    ldh a, [frameCounter]
    and $0f
    ret nz

    ld b, $02
    jr jr_000_2f60

Call_000_2f3c: ; Apply damage for for enemies with a damage value of $FE?
    ld b, $03
    ldh a, [frameCounter]
    and $07
    ret nz

    ld a, $07
    ld [$ced5], a
    jr jr_000_2f60

applyAcidDamage: ; 00:2F4A
    ld b, a
    ldh a, [frameCounter]
    and $0f
    ret nz

    ld a, $07
    ld [$ced5], a
    jr jr_000_2f60

Call_000_2f57: ; Apply enemy/spike damage?
    ld b, a
    cp $60
        ret nc
    ; Play sound
    ld a, $06
    ld [$ced5], a

jr_000_2f60: ; Apply damage
    ld a, [samusItems]
    bit itemBit_varia, a
    jr z, jr_000_2f69
        srl b
    jr_000_2f69:

    ld a, [samusCurHealthLow]
    sub b
    daa
    ld [samusCurHealthLow], a
    ld a, [samusCurHealthHigh]
    sbc $00
    daa
    ld [samusCurHealthHigh], a
    cp $99
    jr nz, jr_000_2f85
        xor a
        ld [samusCurHealthLow], a
        ld [samusCurHealthHigh], a
    jr_000_2f85:
ret

gameMode_dying: ; 00:2F86
    ld a, [$d08b]
    cp $11
    jr nz, .endIf
        call Call_000_3e93 ; Draw Samus
        call drawHudMetroid_longJump
        
        ld a, BANK(queenHandler)
        ld [bankRegMirror], a
        ld [rMBC_BANK_REG], a
        call queenHandler
        
        call clearUnusedOamSlots_longJump
    .endIf:
ret


killSamus: ; Kill Samus
    call Call_000_2390 ; Music related

    ld a, $0b
    ld [$ced5], a
    call waitOneFrame
    call Call_000_3ebf ; Draw Samus regardless of i-frames

    ; Set timer
    ld a, $20
    ld [deathAnimTimer], a

    xor a
    ld [$d05a], a
    ld a, $80
    ld [$d05b], a
    ld a, $01
    ld [deathFlag], a
    ld a, $06
    ldh [gameMode], a
ret


    ld a, $a0
    ld [$d02c], a
    ld a, $80
    ld [samusPose], a
    ld a, $20
    ld [deathAnimTimer], a
    xor a
    ld [$d05a], a
    ld a, $80
    ld [$d05b], a
    ret

; Vblank routine for death
VBlank_deathSequence: ; 00:2FE1
    ld a, [deathFlag]
    and a
    jr z, unusedDeathAnimation

    ; Animate once every 4 frames
    ldh a, [frameCounter]
    and $03
    jr nz, .endIf
    
        ; Get starting offset for the erase loop
        ld hl, deathAnimationTable
        ld a, [deathAnimTimer]
        dec a
        ld e, a
        ld d, $00
        add hl, de
        ld a, [hl]
        ld l, a
        ld h, $80
        ; Increment value
        ld de, $0020
    
        ; Erase one byte of every two tiles for the first 8 rows of VRAM
        .eraseLoop:
            xor a
            ld [hl], a
            add hl, de
            ld a, h
            cp $88
        jr nz, .eraseLoop
    
        ; Decrement death timer
        ld a, [deathAnimTimer]
        dec a
        ld [deathAnimTimer], a
    
        jr nz, .endIf
            ; Officially dead
            ld a, $ff
            ld [deathFlag], a
            ld a, $05
            ldh [gameMode], a
    .endIf:

    ld a, [$c205]
    ldh [rSCY], a
    ld a, [$c206]
    ldh [rSCX], a
    call OAM_DMA

    ; Queen vblank handler if necessary
    ld a, BANK(VBlank_drawQueen)
    ld [rMBC_BANK_REG], a
    ld a, [$d08b]
    cp $11
    call z, VBlank_drawQueen

    ld a, [bankRegMirror]
    ld [rMBC_BANK_REG], a
    ld a, $01
    ldh [hVBlankDoneFlag], a
    ; Return from interrupt
    pop hl
    pop de
    pop bc
    pop af
reti

deathAnimationTable:: ; 00:3042
    db $00, $04, $08, $0c, $10, $14, $18, $1c, $01, $05, $09, $0d, $11, $15, $19, $1d
    db $02, $06, $0a, $0e, $12, $16, $1a, $1e, $03, $07, $0b, $0f, $13, $17, $1b, $1f

; Only jumped to if the death animation vblank handler is called, but the death flag is not set
;  which is impossible
; Possibly not intended as a death animation
unusedDeathAnimation: ; 00:3062
    ldh a, [frameCounter]
    and $01
    jr nz, .endIf_A
        ld a, [$d05a]
        ld l, a
        ld a, [$d05b]
        ld h, a
        ld de, $0010
    
        .eraseLoop:
            xor a
            ld [hl], a
            add hl, de
            ld a, l
            and $f0
        jr nz, .eraseLoop
    
        ld a, l
        sub $ff
        ld l, a
        ld a, h
        sbc $00
        ld h, a
        ld a, l
        cp $10
        jr nz, .endIf_B
            add $f0
            ld l, a
            ld a, h
            adc $00
            ld h, a
        .endIf_B:
    
        ld a, l
        ld [$d05a], a
        ld a, h
        ld [$d05b], a
        cp $85
        jr nz, .endIf_A
            xor a
            ld [deathAnimTimer], a
    .endIf_A:

    ld a, [$c205]
    ldh [rSCY], a
    ld a, [$c206]
    ldh [rSCX], a
    call OAM_DMA
    ld a, [bankRegMirror]
    ld [rMBC_BANK_REG], a
    ld a, $01
    ldh [hVBlankDoneFlag], a
    pop hl
    pop de
    pop bc
    pop af
reti

; 00:30BB - Bomb-enemy collision detection
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


Call_000_32ab: ; Samus enemy collision detection ?
    ; Conditions for exiting early early
    ld a, [samusPose]
    cp $18
    jp nc, Jump_000_3698

    ld a, [deathFlag]
    and a
    jp nz, Jump_000_3698

    ld a, [samusInvulnerableTimer]
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

    ld a, [deathFlag]
    and a
    jp nz, Jump_000_3698

    ld a, [deathAnimTimer]
    and a
    jp nz, Jump_000_3698

    ld a, [samusInvulnerableTimer]
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

    ld a, [deathFlag]
    and a
    jp nz, Jump_000_3698

    ld a, [samusInvulnerableTimer]
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

    ld a, [deathFlag]
    and a
    jp nz, Jump_000_3698

    ld a, [samusInvulnerableTimer]
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


; 00:369B
    db $ec, $f4, $fc, $ec, $f6, $04, $04, $ec, $04, $ec, $ec, $04, $04, $04, $04, $ec
    db $04, $ec, $04, $ec, $04

gameMode_dead: ; 00:36B0
    ; Wait until the death sound ends
    .loopWaitSilence:
        call handleAudio
        call waitForNextFrame
        ld a, [$ced6]
        cp $0b
    jr z, .loopWaitSilence

    xor a
    ld [$d08b], a
    call disableLCD
    call clearTilemaps
    xor a
    ldh [hOamBufferIndex], a
    call clearAllOam_longJump

    ; Load graphics for Game Over screen
    ld a, BANK(gfx_titleScreen)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld hl, gfx_titleScreen
    ld de, $8800
    ld bc, $1000

    .loadGfxLoop:
        ld a, [hl+]
        ld [de], a
        inc de
        dec bc
        ld a, b
        or c
    jr nz, .loadGfxLoop

    ld hl, gameOverText
    ld de, $9800 + (8*$20) + $6 ; Tilemap address for text

    .loadTextLoop:
        ld a, [hl+]
        cp $80
            jr z, .exitLoop
        ld [de], a
        inc de
    jr .loadTextLoop
    
    .exitLoop:

    xor a
    ld [$c205], a
    ld [$c206], a
    ldh [rSCY], a
    ldh [rSCX], a
    ld a, $c3
    ld [$c219], a
    ldh [rLCDC], a
    ; Set timer for Game Over screen
    ld a, $ff
    ld [countdownTimerLow], a
    ld a, $07
    ldh [gameMode], a
ret

gameOverText: ; 00:3711 - "GAME OVER"
    db $56, $50, $5c, $54, $ff, $5e, $65, $54, $61, $80

; Reboot game if a certain amount of time has elapsed, or if start is pressed
gameMode_gameOver: ; 00:371B
    call handleAudio
    call waitForNextFrame
    ld a, [countdownTimerLow]
    and a
    jr z, .reboot
        ldh a, [hInputRisingEdge]
        cp PADF_START
            ret nz
    .reboot:
jp bootRoutine

;------------------------------------------------------------------------------
; Handle item pick-up
handleItemPickup: ; 00:372F
    ld a, [itemCollected]
    and a
        ret z

    call waitOneFrame
    call waitOneFrame
    call waitOneFrame
    call waitOneFrame

    ld a, [itemCollected]
    ld [$d093], a
    ld b, a
    ; Unused SFX?
    ld a, $12
    ld [$cec0], a
    ; Play item get jingle
    ld a, $01
    ld [$cede], a
    ; Set timer for duration of item get jingle
    ld a, $01
    ld [countdownTimerHigh], a
    ld a, $60
    ld [countdownTimerLow], a
    ld a, b
    cp $0d
    jr c, .endIf
        cp $0e
        jr nc, .refillBranch
            ; Play missile get jingle
            ld a, $05
            ld [$cede], a
            ; Set 1 second timer
            xor a
            ld [countdownTimerHigh], a
            ld a, $60
            ld [countdownTimerLow], a
            jr .endIf
    
        .refillBranch:
            ; Do not play jingle
            ld a, $00
            ld [$cede], a
            ; No delay
            ld [countdownTimerHigh], a
            ld [countdownTimerLow], a
            ld a, $0e
            ld [$cec0], a
            jr z, .endIf
                ; Play sound effect
                ld a, $0c
                ld [$cec0], a
    .endIf:

    ld a, [$cedf]
    cp $0e
    jr nz, .endIf_B
        ; Do not play jingle
        ld a, $00
        ld [$cede], a
    .endIf_B:

    ld a, b
    dec a
    rst $28
        dw pickup_plasmaBeam
        dw pickup_iceBeam
        dw pickup_waveBeam
        dw pickup_spazer
        dw pickup_bombs
        dw pickup_screwAttack
        dw pickup_variaSuit
        dw pickup_hiJump
        dw pickup_spaceJump
        dw pickup_spiderBall
        dw pickup_springBall
        dw pickup_energyTank
        dw pickup_missileTank
        dw pickup_energyRefill
        dw pickup_missileRefill

pickup_plasmaBeam:
    ld a, $04
    ld [samusBeam], a
    ld hl, gfxInfo_plasma
    call Call_000_2753
    ld a, [samusActiveWeapon]
    cp $08
    jp z, Jump_000_3a01

    ld a, $04
    ld [samusActiveWeapon], a
    ld [samusBeam], a
    jp Jump_000_3a01
    
gfxInfo_plasma: db BANK(gfx_beamPlasma)
    dw gfx_beamPlasma, vramDest_beam, $0020

pickup_iceBeam:
    ld a, $01
    ld [samusBeam], a
    ld hl, gfxInfo_ice
    call Call_000_2753
    ld a, [samusActiveWeapon]
    cp $08
    jp z, Jump_000_3a01

    ld a, $01
    ld [samusActiveWeapon], a
    ld [samusBeam], a
    jp Jump_000_3a01

gfxInfo_ice: db BANK(gfx_beamIce)
    dw gfx_beamIce, vramDest_beam, $0020

pickup_waveBeam:
    ld a, $02
    ld [samusBeam], a
    ld hl, gfxInfo_wave
    call Call_000_2753
    ld a, [samusActiveWeapon]
    cp $08
    jp z, Jump_000_3a01

    ld a, $02
    ld [samusActiveWeapon], a
    ld [samusBeam], a
    jp Jump_000_3a01

gfxInfo_wave: db BANK(gfx_beamWave)
    dw gfx_beamWave, vramDest_beam, $0020

pickup_spazer:
    ld a, $03
    ld [samusBeam], a
    ld hl, gfxInfo_plasma
    call Call_000_2753
    ld a, [samusActiveWeapon]
    cp $08
    jp z, Jump_000_3a01

    ld a, $03
    ld [samusActiveWeapon], a
    ld [samusBeam], a
    jp Jump_000_3a01


pickup_bombs:
    ld a, [samusItems]
    set itemBit_bomb, a
    ld [samusItems], a
    jp Jump_000_3a01

pickup_screwAttack:
    ld a, [samusItems]
    set itemBit_screw, a
    ld [samusItems], a
    bit itemBit_space, a
    jr nz, jr_000_386b

    ld hl, gfxInfo_spinScrewTop
    call Call_000_2753
    ld hl, gfxInfo_spinScrewBottom
    call Call_000_2753
    jp Jump_000_3a01


jr_000_386b:
    ld hl, gfxInfo_spinSpaceScrewTop
    call Call_000_2753
    ld hl, gfxInfo_spinSpaceScrewBottom
    call Call_000_2753
    jp Jump_000_3a01


; VRAM Update Lists - 00:387A
gfxInfo_variaSuit: db BANK(gfx_samusVariaSuit)
    dw gfx_samusVariaSuit, vramDest_samus, $07B0

gfxInfo_spinSpaceTop: db BANK(gfx_spinSpaceTop)
    dw gfx_spinSpaceTop, vramDest_spinTop, $0070
gfxInfo_spinSpaceBottom: db BANK(gfx_spinSpaceBottom)
    dw gfx_spinSpaceBottom, vramDest_spinBottom, $0050

gfxInfo_spinScrewTop: db BANK(gfx_spinScrewTop)
    dw gfx_spinScrewTop, vramDest_spinTop, $0070
gfxInfo_spinScrewBottom: db BANK(gfx_spinScrewBottom)
    dw gfx_spinScrewBottom, vramDest_spinBottom, $0050

gfxInfo_spinSpaceScrewTop: db BANK(gfx_spinSpaceScrewTop)
    dw gfx_spinSpaceScrewTop, vramDest_spinTop, $0070
gfxInfo_spinSpaceScrewBottom: db BANK(gfx_spinSpaceScrewBottom)
    dw gfx_spinSpaceScrewBottom, vramDest_spinBottom, $0050

gfxInfo_springBallTop: db BANK(gfx_springBallTop)
    dw gfx_springBallTop, vramDest_ballTop, $0020
gfxInfo_springBallBottom: db BANK(gfx_springBallBottom)
    dw gfx_springBallBottom, vramDest_ballBottom, $0020

pickup_variaSuit:
    .loop:
            call Call_000_3e93 ; Draw Samus
            call Call_000_05de ; Handle enemies
            ld a, BANK(drawHudMetroid)
            ld [bankRegMirror], a
            ld [rMBC_BANK_REG], a
            call drawHudMetroid
            call clearUnusedOamSlots_longJump ; Clear unused OAM entries
            ld a, $80
            ldh [rWY], a
            call waitOneFrame
            ld a, [countdownTimerHigh]
            and a
        jr nz, .loop
        ld a, [countdownTimerLow]
        and a
    jr nz, .loop

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
    ld hl, gfxInfo_variaSuit
    call Call_000_27e3
    xor a
    ld [$d08c], a
    ld hl, gfxInfo_variaSuit
    call Call_000_2753
    ld hl, gfxInfo_cannonMissile
    ld a, [samusActiveWeapon]
    cp $08
    call z, Call_000_2753
    call loadExtraSuitGraphics
    jp Jump_000_3a01

pickup_hiJump:
    ld a, [samusItems]
    set itemBit_hiJump, a
    ld [samusItems], a
    jp Jump_000_3a01

pickup_spaceJump:
    ld a, [samusItems]
    set itemBit_space, a
    ld [samusItems], a
    bit itemBit_screw, a
    jr nz, jr_000_3949

    ld hl, gfxInfo_spinSpaceTop
    call Call_000_2753
    ld hl, gfxInfo_spinSpaceBottom
    call Call_000_2753
    jp Jump_000_3a01

jr_000_3949:
    ld hl, gfxInfo_spinSpaceScrewTop
    call Call_000_2753
    ld hl, gfxInfo_spinSpaceScrewBottom
    call Call_000_2753
    jp Jump_000_3a01

pickup_spiderBall:
    ld a, [samusItems]
    set itemBit_spider, a
    ld [samusItems], a
    jp Jump_000_3a01

pickup_springBall:
    ld a, [samusItems]
    set itemBit_spring, a
    ld [samusItems], a
    ld hl, gfxInfo_springBallTop
    call Call_000_2753
    ld hl, gfxInfo_springBallBottom
    call Call_000_2753
    jp Jump_000_3a01

pickup_energyTank:
    ld a, [samusEnergyTanks]
    cp $05 ; Max Energy tanks
    jr z, jr_000_3985
        inc a
        ld [samusEnergyTanks], a
    jr_000_3985:
    ld [samusCurHealthHigh], a
    ld a, $99
    ld [samusCurHealthLow], a
    jr jr_000_3a01

pickup_energyRefill:
    ld a, [samusEnergyTanks]
    ld [samusCurHealthHigh], a
    ld a, $99
    ld [samusCurHealthLow], a
    jr jr_000_3a01

pickup_missileRefill:
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

    ld a, [samusMaxMissilesLow]
    ld [samusCurMissilesLow], a
    ld a, [samusMaxMissilesHigh]
    ld [samusCurMissilesHigh], a
    jr jr_000_3a01

pickup_missileTank:
    ; Add 10 to max missiles
    ld a, [samusMaxMissilesLow]
    add $10
    daa
    ld [samusMaxMissilesLow], a
    ld a, [samusMaxMissilesHigh]
    adc $00
    daa
    ld [samusMaxMissilesHigh], a
    ; Clamp max missiles at 999
    cp $10
    jr c, jr_000_39df
        ld a, $99
        ld [samusMaxMissilesLow], a
        ld a, $09
        ld [samusMaxMissilesHigh], a
    jr_000_39df:
    
    ; Add 10 to current missiles
    ld a, [samusCurMissilesLow]
    add $10
    daa
    ld [samusCurMissilesLow], a
    ld a, [samusCurMissilesHigh]
    adc $00
    daa
    ld [samusCurMissilesHigh], a
    ; Clamp current missiles to 999
    cp $10
    jr c, jr_000_3a01
        ld a, $99
        ld [samusCurMissilesLow], a
        ld a, $09
        ld [samusCurMissilesHigh], a
    jr jr_000_3a01

; Common routine for all pickups
Jump_000_3a01:
    jr_000_3a01:
            call Call_000_3e93
            call drawHudMetroid_longJump
            ld a, $02
            ld [bankRegMirror], a
            ld [rMBC_BANK_REG], a
            call $4000
            call handleAudio
            call clearUnusedOamSlots_longJump
            ld a, [$d093]
            cp $0b
            jr nc, jr_000_3a23
                ld a, $80
                ldh [rWY], a
            jr_000_3a23:
            
            call waitForNextFrame
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
    ld [itemCollectionFlag], a
    ld a, [$d06f]
    ld [$c466], a
    ld a, [$d070]
    ld [$c467], a
    ld a, [$d071]
    ld [$c468], a

    jr_000_3a60:
        call Call_000_3e93
        call drawHudMetroid_longJump
        call Call_000_32ab
        ld a, $02
        ld [bankRegMirror], a
        ld [rMBC_BANK_REG], a
        call $4000
        call handleAudio
        call clearUnusedOamSlots_longJump
        call waitForNextFrame
        ld a, [itemCollectionFlag]
        and a
    jr nz, jr_000_3a60
ret

; Called by the Varia Suit collection routine
loadExtraSuitGraphics:
    ld a, [samusItems]
    bit itemBit_spring, a
    jr z, .endIf_spring
        ld hl, gfxInfo_springBallTop
        call Call_000_2753
        ld hl, gfxInfo_springBallBottom
        call Call_000_2753
    .endIf_spring:

    ld a, [samusItems]
    and itemMask_space | itemMask_screw
    cp itemMask_space | itemMask_screw
    jr nz, .endIf_spinBoth
        ld hl, gfxInfo_spinSpaceScrewTop
        call Call_000_2753
        ld hl, gfxInfo_spinSpaceScrewBottom
        call Call_000_2753
            ret
    .endIf_spinBoth:

    cp itemMask_space
    jr nz, .endIf_space
        ld hl, gfxInfo_spinSpaceTop
        call Call_000_2753
        ld hl, gfxInfo_spinSpaceBottom
        call Call_000_2753
            ret
    .endIf_space:

    cp itemMask_screw
        ret nz

    ld hl, gfxInfo_spinScrewTop
    call Call_000_2753
    ld hl, gfxInfo_spinScrewBottom
    call Call_000_2753
ret

gameMode_unusedA: ; 00:3ACE
    call Call_000_2390
    ld a, $ff
    ld [$cfe5], a
    call disableLCD
    call clearTilemaps
    xor a
    ldh [hOamBufferIndex], a
    call clearAllOam_longJump
    
    ld a, BANK(gfx_titleScreen)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld hl, gfx_titleScreen
    ld de, $8000 ; Should be $8800
    ld bc, $1800 ; Should be $1000

    .loadGfxLoop:
        ld a, [hl+]
        ld [de], a
        inc de
        dec bc
        ld a, b
        or c
    jr nz, .loadGfxLoop

    ld hl, gameSavedText
    ld de, $9800 + (8*$20) + $5 ; Tilemap address for text destination

    .loadTextLoop:
        ld a, [hl+]
        cp $80
            jr z, .exitLoop
        ld [de], a
        inc de
    jr .loadTextLoop

    .exitLoop:

    xor a
    ld [$c205], a
    ld [$c206], a
    ld a, $c3
    ldh [rLCDC], a
    ld a, $a0
    ld [countdownTimerLow], a
    ; Game mode $F doesn't even read this
    ld a, $01
    ld [countdownTimerHigh], a
    ld a, $0f
    ldh [gameMode], a
ret

gameSavedText: ; 00:3B24 - "GAME SAVED"
    db $56, $50, $5C, $54, $FF, $62, $50, $65, $54, $53, $80

gameMode_unusedB: ; 00:3B2F
    call handleAudio
    call waitForNextFrame
    ld a, [countdownTimerLow]
    and a
    jr z, .reboot
        ldh a, [hInputRisingEdge]
        cp PADF_START
            ret nz
    .reboot:
jp bootRoutine

gameMode_unusedC: ; 00:3B43
    call Call_000_2390
    ld a, $ff
    ld [$cfe5], a
    call disableLCD
    call clearTilemaps
    xor a
    ldh [hOamBufferIndex], a
    call clearAllOam_longJump

    ld a, BANK(gfx_titleScreen)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld hl, gfx_titleScreen
    ld de, $8800
    ld bc, $1000

    .loadGfxLoop:
        ld a, [hl+]
        ld [de], a
        inc de
        dec bc
        ld a, b
        or c
    jr nz, .loadGfxLoop

    ld hl, gameClearedText
    ld de, $9800 + (8*$20) + $4 ; Tilemap address for text

    .loadTextLoop:
        ld a, [hl+]
        cp $80
        jr z, .exitLoop
    
        ld [de], a
        inc de
    jr .loadTextLoop

    .exitLoop:

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

gameClearedText: ; 00:3B94 - "GAME CLEARED"
    db $56, $50, $5C, $54, $FF, $52, $5B, $54, $50, $61, $54, $53, $80

gameMode_unusedD: ; 00:3BA1
    ; call handleAudio ; This ain't called here
    call waitForNextFrame
    ld a, [countdownTimerLow]
    and a
    jr z, .reboot
        ldh a, [hInputRisingEdge]
        cp PADF_START
            ret nz
    .reboot:
    ; The other two routines like this do this instead: jp bootRoutine
    ld a, $00
    ldh [gameMode], a
ret


; Loads graphics depending on Samus' loadout
loadGame_SamusItemGraphics: ; 00:3BB4
    ld a, [samusItems]
    bit itemBit_varia, a
    jr z, .endIf_varia
        ld hl, gfxInfo_variaSuit
        call Call_000_3c3f
    .endIf_varia:
    
    ld a, [samusItems]
    bit itemBit_spring, a
    jr z, .endIf_spring
        ld hl, gfxInfo_springBallTop
        call Call_000_3c3f
        ld hl, gfxInfo_springBallBottom
        call Call_000_3c3f
    .endIf_spring:
    
    ld a, [samusItems] ; Load spin jump graphics
        and itemMask_space | itemMask_screw
        cp itemMask_space | itemMask_screw
        jr nz, .endIf_spinBoth
            ld hl, gfxInfo_spinSpaceScrewTop
            call Call_000_3c3f
            ld hl, gfxInfo_spinSpaceScrewBottom
            call Call_000_3c3f
            jr .endSpinBranch
        .endIf_spinBoth:
        
        cp itemMask_space
        jr nz, .endIf_space
            ld hl, gfxInfo_spinSpaceTop
            call Call_000_3c3f
            ld hl, gfxInfo_spinSpaceBottom
            call Call_000_3c3f
            jr .endSpinBranch
        .endIf_space:
    
        cp itemMask_screw
        jr nz, .endIf_screw
            ld hl, gfxInfo_spinScrewTop
            call Call_000_3c3f
            ld hl, gfxInfo_spinScrewBottom
            call Call_000_3c3f
        .endIf_screw:
    .endSpinBranch:

    ld a, [samusActiveWeapon] ; Load beam graphics
        cp $01
        jr nz, .endIf_ice
            ld hl, gfxInfo_ice
            call Call_000_3c3f
            jr .endBeamBranch
        .endIf_ice:
    
        cp $03
        jr nz, .endIf_spazer
            ld hl, gfxInfo_plasma
            call Call_000_3c3f
            jr .endBeamBranch
        .endIf_spazer:
    
        cp $02
        jr nz, .endIf_wave
            ld hl, gfxInfo_wave
            call Call_000_3c3f
            jr .endBeamBranch
        .endIf_wave:
    
        cp $04
        jr nz, .endIf_plasma
            ld hl, gfxInfo_plasma
            call Call_000_3c3f
        .endIf_plasma:
    .endBeamBranch:
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
    call copyToVram
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

; External Calls

; 00:3C92
    ld a, BANK(earthquakeCheck)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call earthquakeCheck
    ld a, $02
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
ret

; 00:3CA6
    ld a, $03
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call $6ae7
    ld a, $02
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ret

; 00:3CBA
    ld a, $03
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call $6b44
    ld a, $02
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ret

; 00:3CCE
    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call $56e9
    ld a, $02
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ret

gameMode_saveGame: ; 00:3CE2
    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp saveFileToSRAM


Call_000_3ced: ; 00:3CED
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

; 00:3D0C
    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call $70ba
    ld a, $02
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ret

; 00:3D20
    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call $723b
    ld a, $02
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ret

; 00:3D34
    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call $71cb
    ld a, $02
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ret

; 00:3D48
    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call $7319
    ld a, $02
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ret


LCDCInterruptHandler: ; 00:3D5C
    push af
    ld a, $03
    ld [rMBC_BANK_REG], a
    call $7c7f
    ld a, [bankRegMirror]
    ld [rMBC_BANK_REG], a
    pop af
reti


Call_000_3d6d: ; 00:3D6D
    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp $57f2


adjustHudValues_longJump: ; 00:3D78
    ld a, BANK(adjustHudValues)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp adjustHudValues


handleRespawningBlocks_longJump: ; 00:3D83
    ld a, BANK(handleRespawningBlocks)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp handleRespawningBlocks


handleProjectiles_longJump: ; 00:3D8E
    ld a, BANK(handleProjectiles)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp handleProjectiles


Call_000_3d99: ; 00:3D99
    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp $549d


Call_000_3da4: ; 00:3DA4
    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp $5300 


samusShoot_longJump: ; 00:3DAF
    ld a, BANK(samusShoot)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp samusShoot

; 00:3DBA
    ld a, $03
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call $6bd2
    ld a, $02
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ret

; 00:3DCE
    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call $5a11
    ld a, $02
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ret

; 00:3DE2
    ld a, $03
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call $4000
    ld a, $02
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ret

findFirstEmptyEnemySlot_longJump: ; 00:3DF6
    ld a, BANK(findFirstEmptyEnemySlot)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call findFirstEmptyEnemySlot
    ld a, $02
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ret


loadEnemySaveFlags_longJump: ; 00:3E0A
    ld a, BANK(loadEnemySaveFlags)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call loadEnemySaveFlags
    ; Return to our singular callee (same bank at the function we longjumped too)
    ld a, BANK(loadSaveFile)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ret


VBlank_drawCreditsLine_longJump: ; 00:3E1E
    ld a, BANK(VBlank_drawCreditsLine)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp VBlank_drawCreditsLine

gameMode_prepareCredits: ; 00:3E29
    ld a, BANK(prepareCreditsRoutine)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp prepareCreditsRoutine

gameMode_Credits: ; 00:3E34
    ld a, BANK(creditsRoutine)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp creditsRoutine

gameMode_Boot: ; 00:3E3F
    call disableLCD
    call OAM_clearTable
    xor a
    ldh [hOamBufferIndex], a
    call clearUnusedOamSlots_longJump
    call Call_000_2390
    ld a, BANK(loadTitleScreen)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp loadTitleScreen

gameMode_Title: ; 00:3E59
    call OAM_clearTable
    ld a, BANK(titleScreenRoutine)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp titleScreenRoutine


gameMode_newGame: ; 00:3E67 - New Game
    ld a, BANK(createNewSave)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp createNewSave


gameMode_loadSave: ; 00:3E72 - Load Save
    ld a, BANK(loadSaveFile)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp loadSaveFile


; 00:3E7D
    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp $4b62


clearUnusedOamSlots_longJump: ; 00:3E88
    ld a, BANK(clearUnusedOamSlots)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp clearUnusedOamSlots


Call_000_3e93: ; 00:3E93
    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp $4bd9


drawHudMetroid_longJump: ; 00:3E9E
    ld a, BANK(drawHudMetroid)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp drawHudMetroid


debug_drawOneDigitNumber_longJump: ; 00:3EA9 - Unused?
    ld a, BANK(debug_drawNumber)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp debug_drawNumber.oneDigit

debug_drawTwoDigitNumber_longJump: ; 00:3EB4 - Unused?
    ld a, BANK(debug_drawNumber)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp debug_drawNumber.twoDigit


Call_000_3ebf: ; 00:3EBF
    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp $4bf3


clearAllOam_longJump: ; 00:3ECA
    ld a, BANK(clearAllOam)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp clearAllOam


; Extracts the sprite priority bit that is bit-packed with the door transition index using the bitmask (0x0800)
; (I don't know why they didn't store these bits with the scroll bytes)
loadScreenSpritePriorityBit: ; 00:3ED5
    ld a, [currentLevelBank]
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ; Get screen index from coordinates
    ldh a, [hSamusYScreen]
    swap a
    ld e, a
    ldh a, [hSamusXScreen]
    add e
    ; Get the address of the door transition index
    ld e, a
    ld d, $00
    sla e
    rl d
    ld hl, $4300 ; Base address for door transition indexes
    add hl, de
    ; Load the high byte of the transition index
    inc hl
    ld a, [hl]
    ; Rotate the relavent bit to the LSB and store it
    swap a
    rlc a
    and $01
    xor $01
    ld [$d057], a
    ; Return to the callee
    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
ret

; 00:3F07
; unused (duplicate of the routine at 00:3062)
    ldh a, [frameCounter]
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
    ld [deathAnimTimer], a

jr_000_3f44:
    ld a, [$c205]
    ldh [rSCY], a
    ld a, [$c206]
    ldh [rSCX], a
    call OAM_DMA
    ld a, [bankRegMirror]
    ld [rMBC_BANK_REG], a
    ld a, $01
    ldh [hVBlankDoneFlag], a
    pop hl
    pop de
    pop bc
    pop af
reti

; Freespace - 00:3F60 (filled with $00)
