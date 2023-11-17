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

LCDCInterrupt:: jp LCDCInterruptHandler_farCall
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

VBlankHandler: ;{ 00:0154
    di
    push af
    push bc
    push de
    push hl
    ; Update scrolling
    ld a, [scrollY]
    ldh [rSCY], a
    ld a, [scrollX]
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
    jr nc, .endIf_A
        ; Minimum timer value is $0000
        xor a
        ld [countdownTimerLow], a
        ld [countdownTimerHigh], a
    .endIf_A:
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
    ; VRAM data transfer
    ld a, [vramTransferFlag]
    and a
        jp nz, VBlank_vramDataTransfer
    ; Handle map updates during door transitions
    ld a, [doorIndexLow]
    and a
        jp nz, VBlank_updateMapDuringTransition
    ; Branch for queen fight
    ld a, [queen_roomFlag]
    cp $11
        jr z, .queenBranch
    ; Update a map row or the status bar
    ld a, [mapUpdateFlag]
    and a
    jr z, .else_B
        ld a, [currentLevelBank]
        ld [rMBC_BANK_REG], a
        call VBlank_updateMap
        jr .endIf_B
    .else_B:
        ld a, BANK(VBlank_updateStatusBar)
        ld [rMBC_BANK_REG], a
        call VBlank_updateStatusBar
    .endIf_B:
; End vblank
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

.queenBranch:
    ld a, BANK(VBlank_updateStatusBar)
    ld [rMBC_BANK_REG], a
    call VBlank_updateStatusBar
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
;}

bootRoutine: ;{ 00:01FB
    ; Clear $D000-$DFFF
    xor a
    ld hl, wram_end ; $DFFF
    ld c, $10
    ld b, $00
    .clearLoop_A:
            ld [hl-], a
            dec b
        jr nz, .clearLoop_A
        dec c
    jr nz, .clearLoop_A
    
    ; Initialize registers
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
    
    ; Wait for rendering to be off
    .waitLoop:
        ldh a, [rLY]
        cp $94
    jr nz, .waitLoop
    ; Init LCD parameters
    ld a, $03
    ldh [rLCDC], a
    ld a, $93
    ld [bg_palette], a
    ld a, $93
    ld [ob_palette0], a
    ld a, $43
    ld [ob_palette1], a
    
    ; Init stack pointer before calling a function
    ld sp, stack.bottom ; $DFFF
    call initializeAudio_longJump
    ; Enable SRAM (?)
    ld a, $0a
    ld [$0000], a
    
    ; Clear $DF00-$DF00 (stack)
    xor a
    ld hl, stack.bottom ; $DFFF
    ld b, $00
    .clearLoop_B:
        ld [hl-], a
        dec b
    jr nz, .clearLoop_B
    
    ; Clear $C000-$CFFF
    ld hl, $cfff
    ld c, $10
    ld b, $00
    .clearLoop_C:
            ld [hl-], a
            dec b
            jr nz, .clearLoop_C
        dec c
    jr nz, .clearLoop_C
    
    ; Fill $C500-$CAFF with $FF
    ld a, $ff
    ld hl, $caff
    ld c, $06
    ld b, $00
    .clearLoop_D:
            ld [hl-], a
            dec b
            jr nz, .clearLoop_D
        dec c
    jr nz, .clearLoop_D

    ; Clear $8000-$9FFF (VRAM)
    xor a
    ld hl, $9fff
    ld c, $20
    ld b, $00
    .clearLoop_E:
            ld [hl-], a
            dec b
            jr nz, .clearLoop_E
        dec c
    jr nz, .clearLoop_E

    ; Clear OAM
    ld hl, $feff
    ld b, $00
    .clearLoop_F:
        ld [hl-], a
        dec b
    jr nz, .clearLoop_F

    ; Clear HRAM
    ld hl, $fffe
    ld b, $80
    .clearLoop_G:
        ld [hl-], a
        dec b
    jr nz, .clearLoop_G

    ; Load OAM DMA routine to HRAM
    ld c, LOW(OAM_DMA)
    ld b, $0a
    ld hl, oamDMA_routine
    .loadLoop:
        ld a, [hl+]
        ld [c], a
        inc c
        dec b
    jr nz, .loadLoop

    ; Fill tilemaps with $FF
    call clearTilemaps
    ; Init video registers for use
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

    ; Enable SRAM
    ld a, $0a
    ld [$0000], a
    ; Set active save slot based on SRAM
    xor a
    ld [activeSaveSlot], a
    ld a, [saveLastSlot]
    cp $03
    jr nc, .endIf
        ld [activeSaveSlot], a
    .endIf:
    ; Set game mode
    ld a, $00
    ldh [gameMode], a
    ; Disable SRAM
    ld a, $00
    ld [$0000], a
;}

mainGameLoop: ;{ 00:02CD
    ; Clear vram update flag
    xor a
    ld [mapUpdateFlag], a
    ; Update buttons if not in a door transition
    ld a, [doorScrollDirection]
    and a
    call z, main_readInput
    ; Do imporatant stuff
    call main_handleGameMode
    call handleAudio_longJump
    call executeDoorScript
    ldh a, [hInputPressed]
    ; Soft reset
    and PADF_START | PADF_SELECT | PADF_B | PADF_A ;$0f
    cp PADF_START | PADF_SELECT | PADF_B | PADF_A
        jp z, bootRoutine
    call waitForNextFrame
jp mainGameLoop
;}

main_handleGameMode: ;{ 0:02F0
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
;}

gameMode_None: ; 00:031B
    ret

; Called when frame is done
waitForNextFrame: ;{ 00:031C
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
    ldh [hUnusedFlag_1], a
    xor a
    ldh [hOamBufferIndex], a
ret
;}

OAM_clearTable: ;{ 00:0370
    xor a
    ld hl, wram_oamBuffer
    ld b, OAM_MAX

    .loop:
        ld [hl+], a
        dec b
    jr nz, .loop
ret
;}

; Clears both the BG and window tilemaps
clearTilemaps: ;{ 00:037B
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
;}

; hl: source, de: destination, bc: length
copyToVram: ;{ 00:038A
    .loop:
        ld a, [hl+]
        ld [de], a
        inc de
        dec bc
        ld a, b
        or c
    jr nz, .loop
ret
;}

; de: source, hl: destination, $FF terminated
unusedCopyRoutine: ;{ 00:0393
    .loop:
        ld a, [de]
        cp $ff
            ret z
        ld [hl+], a
        inc de
    jr .loop
;}

TimerOverflowInterruptStub: ; 00:039B
    reti

disableLCD: ;{ 00:039C
    ; Save interrupt status
    ldh a, [rIE]
    ldh [hTemp.b], a
    res 0, a
    ldh [rIE], a
    ; Wait for VBlank
    .waitLoop:
        ldh a, [rLY]
        cp $91
    jr nz, .waitLoop
    ; Disable LCD
    ldh a, [rLCDC]
    and $7f
    ldh [rLCDC], a
    ; Restore interrupt status
    ldh a, [hTemp.b]
    ldh [rIE], a
ret
;}

; Game Mode $02
; Primarily loads data from saveBuf to their working copies
gameMode_LoadA: ;{ 00:03B5
    ; Load various variables from the saveBuf to their working copies
    ;  and prep the start-up sequence
    call loadGame_samusData
    ; Load metatiles
    switchBank metatilePointerTable
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
        cp HIGH(tiletableArray)+2 ;$dc
    jr nz, .tiletableLoop

    ; Load collision data
    ld a, [saveBuf_collisionSrcLow]
    ld l, a
    ld a, [saveBuf_collisionSrcHigh]
    ld h, a
    .collisionLoop:
        ld a, [hl+]
        ld [de], a
        inc de
        ld a, d
        cp HIGH(collisionArray)+1 ;$dd
    jr nz, .collisionLoop

; Load various variables from saveBuf to their working copies
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

    ; Clear variables
    xor a
    ld [doorScrollDirection], a
    ld [deathAnimTimer], a
    ld [deathFlag], a
    ld [vramTransferFlag], a
    ld [unused_D06B], a
    ld [itemCollected], a
    ld [itemCollectionFlag], a
    ld [maxOamPrevFrame], a

    ld a, $01
    ld [queen_roomFlag], a
    ld a, $ff
    ld [collision_weaponType], a
    
    ; Clear respawning block table
    ld hl, respawningBlockArray
    .clearLoop:
        xor a
        ld [hl], a
        ld a, l
        add $10
        ld l, a
    jr nz, .clearLoop

    callFar inGame_saveAndLoadEnemySaveFlags
    ; Increment gameMode to gameMode_loadB
    ldh a, [gameMode]
    inc a
    ldh [gameMode], a
ret
;}

; Game Mode $03
; Loads graphics and map
gameMode_LoadB: ;{ 00:0464
    call disableLCD
    ; Load graphics
    call loadGame_loadGraphics
    ; Adjust Samus graphics based on her item loadout
    call loadGame_samusItemGraphics

    ; Set camera position
    ld a, [saveBuf_cameraYPixel]
    ldh [hCameraYPixel], a
    ld a, [saveBuf_cameraYScreen]
    ldh [hCameraYScreen], a
    ld a, [saveBuf_cameraXPixel]
    ldh [hCameraXPixel], a
    ld a, [saveBuf_cameraXScreen]
    ldh [hCameraXScreen], a
    
    ; Render map
    switchBankVar [currentLevelBank]
    .renderLoop:
        ; Initialize update buffer pointer
        ld a, LOW(mapUpdateBuffer)
        ldh [hMapUpdate.buffPtrLow], a
        ld a, HIGH(mapUpdateBuffer)
        ldh [hMapUpdate.buffPtrHigh], a

        call prepMapUpdate.forceRow ; Force row update
        call VBlank_updateMap
        ; Move camera down to render next row
        ldh a, [hCameraYPixel]
        add $10
        ldh [hCameraYPixel], a
        ldh a, [hCameraYScreen]
        adc $00
        and $0f
        ldh [hCameraYScreen], a
        ; Repeat until we've scrolled down a full screen
        ldh a, [hCameraYPixel]
        ld b, a
        ld a, [saveBuf_cameraYPixel]
        cp b
    jr nz, .renderLoop

    ; Reload camera position
    ld a, [saveBuf_cameraYPixel]
    ldh [hCameraYPixel], a
    ld a, [saveBuf_cameraYScreen]
    ldh [hCameraYScreen], a
    ld a, [saveBuf_cameraXPixel]
    ldh [hCameraXPixel], a
    ld a, [saveBuf_cameraXScreen]
    ldh [hCameraXScreen], a

    ; Adjust virtual camera position to real scroll position
    ldh a, [hCameraYPixel]
    sub $78
    ld [scrollY], a
    ldh a, [hCameraXPixel]
    sub $30
    ld [scrollX], a

    ; Enable LCD
    ld a, $e3
    ldh [rLCDC], a
    xor a
    ld [unused_D011], a
    ; Increment game mode to main
    ldh a, [gameMode]
    inc a
    ldh [gameMode], a
ret
;}

; Game Mode $04
gameMode_Main: ;{ 00:04DF
    ; Jump ahead if being eaten by the Queen
    ld a, [samusPose]
    and %01111111 ; Mask out upper bit (for turnaround animation)
    cp pose_beingEaten ; $18
        jp nc, .queenBranch
    ; Handle window height, save sprite text, earthquake, low heath beep, fade in, and Metroid Queen cry
    call miscIngameTasks_longJump
    ; Check if dead (when displayed health is zero)
    ld a, [samusDispHealthLow]
    ld b, a
    ld a, [samusDispHealthHigh]
    or b
        call z, killSamus
    ; Update Samus position history
    ldh a, [hSamusYPixel]
    ld [prevSamusYPixel], a
    ldh a, [hSamusYScreen]
    ld [prevSamusYScreen], a
    ldh a, [hSamusXPixel]
    ld [prevSamusXPixel], a
    ldh a, [hSamusXScreen]
    ld [prevSamusXScreen], a
    ; Check if a cutscene is active (i.e. a Metroid is transforming)
    ld a, [cutsceneActive]
    and a
    jr z, .else_A
        ; Force Samus out of turnaround pose
        ld a, [samusPose]
        res 7, a
        ld [samusPose], a
        ; Only allow toggling missiles as input
        ldh a, [hInputRisingEdge]
        bit PADB_SELECT, a
            call nz, samus_tryShooting.toggleMissiles
        jr .endIf_A
    .else_A:
        ; Check if in a door transition
        ; BUG: This only checks the low byte of the index
        ld a, [doorScrollDirection]
        and a
        jr nz, .endIf_A
            ; Do various common things
            xor a
            ld [samusSpriteCollisionProcessedFlag], a
            call hurtSamus ; Damage Samus
            call samus_handlePose ; Samus pose handler
            call collision_samusEnemies.standard ; ? Samus/enemy collision logic
            call samus_tryShooting ; Handle shooting or toggling cannon
            call handleProjectiles_longJump ; Handle projectiles
            call handleBombs_longJump ; Handle bombs
    .endIf_A:

    call prepMapUpdate ; Handle loading blocks from scrolling
    call handleCamera ; Handle scrolling/triggering door transitions
    call convertCameraToScroll ; Calculate scroll offsets
    call handleItemPickup
    call drawSamus_longJump ; Draw Samus
    call drawProjectiles_longJump ; Draw projectiles
    call handleRespawningBlocks_longJump ; Handle respawning blocks
    call adjustHudValues_longJump ; Handle missile/energy counters
    ; Decrement unmorph jump timer
    ld a, [samus_unmorphJumpTimer]
    and a
    jr z, .endIf_B
        dec a
        ld [samus_unmorphJumpTimer], a
    .endIf_B:
    
    call drawHudMetroid_longJump
    ; Set max OAM offset of non-enemies
    ldh a, [hOamBufferIndex]
    ld [samusTopOamOffset], a
    ; Handle enemies if not in a door
    ; BUG: This only checks the low byte of the index
    ld a, [doorIndexLow]
    and a
    jr nz, .endIf_C
        call handleEnemiesOrQueen ; Handle enemies
    .endIf_C:

    call clearUnusedOamSlots_longJump ; Clear unused OAM
    call tryPausing ; Handle pausing
ret

.queenBranch: ;{ Branch used when being eaten. Skips a few tasks, but otherwise quite similar to the above
    ; Handle window height, save text, earthquake, low heath beep, fade in, and Metroid Queen cry
    call miscIngameTasks_longJump
    ; Check if dead (when displayed health is zero)
    ld a, [samusDispHealthLow]
    ld b, a
    ld a, [samusDispHealthHigh]
    or b
        call z, killSamus
    ; Update Samus position history
    ldh a, [hSamusYPixel]
    ld [prevSamusYPixel], a
    ldh a, [hSamusYScreen]
    ld [prevSamusYScreen], a
    ldh a, [hSamusXPixel]
    ld [prevSamusXPixel], a
    ldh a, [hSamusXScreen]
    ld [prevSamusXScreen], a
    xor a
    ld [samusSpriteCollisionProcessedFlag], a
    ; Do various common things
    call samus_handlePose
    call collision_samusEnemies.standard
    call samus_tryShooting
    call handleProjectiles_longJump
    call handleBombs_longJump
    call prepMapUpdate
    call handleCamera
    call convertCameraToScroll
    call drawSamus_longJump
    call drawProjectiles_longJump
    call handleRespawningBlocks_longJump
    call adjustHudValues_longJump
    ; Decrement unmorph jump timer
    ld a, [samus_unmorphJumpTimer]
    and a
    jr z, .endIf_D
        dec a
        ld [samus_unmorphJumpTimer], a
    .endIf_D:

    call drawHudMetroid_longJump
    ; Set max OAM offset of non-enemies
    ldh a, [hOamBufferIndex]
    ld [samusTopOamOffset], a
    call handleEnemiesOrQueen
    call clearUnusedOamSlots_longJump
    call tryPausing
    ret ;}
;}

handleEnemiesOrQueen: ;{ 00:05DE
    ld a, [queen_roomFlag]
    cp $11
    jr z, .else
        callFar enemyHandler ; Handle enemies
        ret
    .else:
        callFar queenHandler ; Handle Queen
        ret
;}

loadGame_loadGraphics: ;{ 00:05FD
    ; Missile tank, missile door, missile block, and refills
    switchBank gfx_commonItems
    ld bc, $0100
    ld hl, gfx_commonItems
    ld de, vramDest_commonItems
    call copyToVram
    ; Load default power suit and common sprite/HUD tiles
    switchBank gfx_samusPowerSuit
    ld bc, $0b00
    ld hl, gfx_samusPowerSuit
    ld de, vramDest_samus
    call copyToVram
    ; Load enemy graphics page
    switchBank gfx_enemiesA ; Unforunately, save files don't save the bank they load enemy graphics from
    ld bc, $0400
    ld a, [saveBuf_enGfxSrcLow]
    ld l, a
    ld a, [saveBuf_enGfxSrcHigh]
    ld h, a
    ld de, vramDest_enemies
    call copyToVram
    ; Load font if loading from file
    ld a, [loadingFromFile]
    and a
    jr z, .endIf
        switchBank gfx_itemFont
        ld bc, $0200
        ld hl, gfx_itemFont
        ld de, vramDest_itemFont
        call copyToVram
    .endIf:
    ; Load BG graphic tiles
    switchBankVar [saveBuf_bgGfxSrcBank]
    ld bc, $0800
    ld a, [saveBuf_bgGfxSrcLow]
    ld l, a
    ld a, [saveBuf_bgGfxSrcHigh]
    ld h, a
    ld de, vramDest_bgTiles
    call copyToVram
ret
;}

; Only called when entering the queen's room
queen_renderRoom: ;{ 00:0673
    ; Set source coordinate to upper-left corner of screen
    xor a
    ldh [hMapSource.yPixel], a
    ldh [hMapSource.xPixel], a
    ldh a, [hCameraYScreen]
    ldh [hMapSource.yScreen], a
    ldh a, [hCameraXScreen]
    ldh [hMapSource.xScreen], a
    ; Iterate over every row of the screen
    .loop:
        ld a, LOW(mapUpdateBuffer)
        ldh [hMapUpdate.buffPtrLow], a
        ld a, HIGH(mapUpdateBuffer)
        ldh [hMapUpdate.buffPtrHigh], a
        call prepMapUpdate.row
        call VBlank_updateMap
        ldh a, [hMapSource.yPixel]
        add $10
        ldh [hMapSource.yPixel], a
        and a
    jr nz, .loop
ret
;}

prepMapUpdate: ;{ 00:0698
    ; Switch to current level bank
    switchBankVar [currentLevelBank]
    ; Reset map update buffer pointer
    ld a, LOW(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrLow], a
    ld a, HIGH(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrHigh], a
    xor a
    ld [mapUpdate_unusedVar], a
    ; Choose direction based on frame counter
    ldh a, [frameCounter]
    and $03 ; Up
        jr z, .up
    cp $01 ; Down
        jr z, .down
    cp $02 ; Left
        jr z, .left
    cp $03 ; Right
        jp z, .right
ret ; Should never end up here

.up: ; Up
    ; If if not scrolling up
    ld a, [camera_scrollDirection]
    bit scrollDirBit_up, a
        ret z
    ld a, $ff
    ld [mapUpdate_unusedVar], a
  .forceRow: ; Alternate call point used when loading the game
    ; Get x pixel/screen of the top-left of the source row
    ldh a, [hCameraXPixel]
    sub $80
    ldh [hMapSource.xPixel], a
    ldh a, [hCameraXScreen]
    sbc $00
    and $0f
    ldh [hMapSource.xScreen], a
    ; Get y pixel/screen of the top-left of the source row
    ldh a, [hCameraYPixel]
    sub $78
    ldh [hMapSource.yPixel], a
    ldh a, [hCameraYScreen]
    sbc $00
    and $0f
    ldh [hMapSource.yScreen], a
    ; Clear scroll direction
    ld a, [camera_scrollDirection]
    res scrollDirBit_up, a
    ld [camera_scrollDirection], a
jp .row

.down: ; Down
    ; If if not scrolling down
    ld a, [camera_scrollDirection]
    bit scrollDirBit_down, a
        ret z
    ld a, $ff
    ld [mapUpdate_unusedVar], a
    ; Get x pixel/screen of the top-left of the source row
    ldh a, [hCameraXPixel]
    sub $80
    ldh [hMapSource.xPixel], a
    ldh a, [hCameraXScreen]
    sbc $00
    and $0f
    ldh [hMapSource.xScreen], a
    ; Get y pixel/screen of the top-left of the source row
    ldh a, [hCameraYPixel]
    add $78
    ldh [hMapSource.yPixel], a
    ldh a, [hCameraYScreen]
    adc $00
    and $0f
    ldh [hMapSource.yScreen], a
    ; Clear scroll direction
    ld a, [camera_scrollDirection]
    res scrollDirBit_down, a
    ld [camera_scrollDirection], a
jr .row

.left: ; Left
    ; If if not scrolling left
    ld a, [camera_scrollDirection]
    bit scrollDirBit_left, a
        ret z
    ld a, $ff
    ld [mapUpdate_unusedVar], a
    ; Get x pixel/screen of the top-left of the source column
    ldh a, [hCameraXPixel]
    sub $80
    ldh [hMapSource.xPixel], a
    ldh a, [hCameraXScreen]
    sbc $00
    and $0f
    ldh [hMapSource.xScreen], a
    ; Get y pixel/screen of the top-left of the source column
    ldh a, [hCameraYPixel]
    sub $78
    ldh [hMapSource.yPixel], a
    ldh a, [hCameraYScreen]
    sbc $00
    and $0f
    ldh [hMapSource.yScreen], a
    ; Clear scroll direction
    ld a, [camera_scrollDirection]
    res scrollDirBit_left, a
    ld [camera_scrollDirection], a
jp .column

.right: ; Right
    ; If if not scrolling right
    ld a, [camera_scrollDirection]
    bit scrollDirBit_right, a
        ret z
    ld a, $ff
    ld [mapUpdate_unusedVar], a
    ; Get x pixel/screen of the top-left of the source column
    ldh a, [hCameraXPixel]
    add $70
    ldh [hMapSource.xPixel], a
    ldh a, [hCameraXScreen]
    adc $00
    and $0f
    ldh [hMapSource.xScreen], a
    ; Get y pixel/screen of the top-left of the source column
    ldh a, [hCameraYPixel]
    sub $78
    ldh [hMapSource.yPixel], a
    ldh a, [hCameraYScreen]
    sbc $00
    and $0f
    ldh [hMapSource.yScreen], a
    ; Clear scroll direction
    ld a, [camera_scrollDirection]
    res scrollDirBit_right, a
    ld [camera_scrollDirection], a
jp .column

.row: ;{ 00:0788
    call mapUpdate_getSrcAndDest

    ld a, $10
    ldh [hMapUpdate.size], a
    .loop_A:
        call mapUpdate_writeToBuffer
        ; Iterate rightwards to next block
        ldh a, [hMapUpdate.destAddrLow]
        add $02
        ldh [hMapUpdate.destAddrLow], a
        ldh a, [hMapUpdate.destAddrHigh]
        adc $00
        and $9b
        ldh [hMapUpdate.destAddrHigh], a
        ldh a, [hMapUpdate.destAddrLow]
        and $df
        ldh [hMapUpdate.destAddrLow], a
        ; Iterate rightwards to next source block
        ldh a, [hMapUpdate.srcBlock]
        add $01
        ldh [hMapUpdate.srcBlock], a
        and $0f
        jr nz, .endIf_A
            ; Iterate rightwards to next source screen if necessary
            ldh a, [hMapUpdate.srcBlock]
            sub $10
            ldh [hMapUpdate.srcBlock], a
            ldh a, [hMapUpdate.srcScreen]
            and $f0
            ld b, a
            ldh a, [hMapUpdate.srcScreen]
            inc a
            and $0f
            or b
            ldh [hMapUpdate.srcScreen], a
            ld e, a
            ld d, $00
            sla e
            rl d
            ld hl, map_screenPointers ; $4000
            add hl, de
            ld a, [hl+]
            ld c, a
            ld a, [hl]
            ld b, a
        .endIf_A:
    
        ldh a, [hMapUpdate.size]
        dec a
        ldh [hMapUpdate.size], a
    jr nz, .loop_A
    ; Terminate buffer list
    ldh a, [hMapUpdate.buffPtrLow]
    ld l, a
    ldh a, [hMapUpdate.buffPtrHigh]
    ld h, a
    ld a, $00
    ld [hl+], a
    ld [hl], a
ret ;}

.column: ;{ 00:07E4
    ld a, [camera_scrollDirection]
    and ~(scrollDir_left|scrollDir_right) ; $CF
    ld [camera_scrollDirection], a
    call mapUpdate_getSrcAndDest
    
    ld a, $10
    ldh [hMapUpdate.size], a
    .loop_B:
        call mapUpdate_writeToBuffer
        ; Iterate downwards to next block
        ldh a, [hMapUpdate.destAddrLow]
        add $40
        ldh [hMapUpdate.destAddrLow], a
        ldh a, [hMapUpdate.destAddrHigh]
        adc $00
        and $9b ; Clamp destination address to the tilemap 0
        ldh [hMapUpdate.destAddrHigh], a
        ; Iterate downwards to next source block
        ldh a, [hMapUpdate.srcBlock]
        add $10
        ldh [hMapUpdate.srcBlock], a
        and $f0
        jr nz, .endIf_B
            ; Iterate downwards to next source screen if necessary
            ldh a, [hMapUpdate.srcScreen]
            add $10
            ldh [hMapUpdate.srcScreen], a
            ld e, a
            ld d, $00
            sla e
            rl d
            ld hl, map_screenPointers ; $4000
            add hl, de
            ld a, [hl+]
            ld c, a
            ld a, [hl]
            ld b, a
        .endIf_B:
    
        ldh a, [hMapUpdate.size]
        dec a
        ldh [hMapUpdate.size], a
    jr nz, .loop_B
    ; Terminate buffer list
    ldh a, [hMapUpdate.buffPtrLow]
    ld l, a
    ldh a, [hMapUpdate.buffPtrHigh]
    ld h, a
    ld a, $00
    ld [hl+], a
    ld [hl], a
ret ;}
;}

; Translates X and Y map/screen coordinates into map/screen array indeces
;  and a VRAM address, for updating scrolling
; Return values
;  BC - screen pointer
;  hMapUpdate.srcBlock (block index in screen (YX))
;  hMapUpdate.destAddr (VRAM dest address)
mapUpdate_getSrcAndDest: ;{ 00:0835
    ; srcScreen = (Y,X)
    ldh a, [hMapSource.yScreen]
    swap a
    and $f0
    ld b, a
    ldh a, [hMapSource.xScreen]
    and $0f
    or b
    ldh [hMapUpdate.srcScreen], a
    ; BC = map_screenPointers + *2
    ld e, a
    ld d, $00
    sla e
    rl d
    ld hl, map_screenPointers ;$4000
    add hl, de
    ld a, [hl+]
    ld c, a
    ld a, [hl]
    ld b, a
    ; srcBlock = upper 16 bits of (Y,X)
    ldh a, [hMapSource.yPixel]
    and $f0
    ld l, a
    ldh a, [hMapSource.xPixel]
    swap a
    and $0f
    or l
    ldh [hMapUpdate.srcBlock], a
    ; destAddr = $9800 + (upper nybble of ypx*4) + (upper nybble of xpx/8)
    ld hl, $9800
    ldh a, [hMapSource.yPixel]
    and $f0
    ld e, a
    xor a
    ld d, a
    sla e
    rl d
    sla e
    rl d
    add hl, de
    ldh a, [hMapSource.xPixel]
    and $f0
    swap a
    sla a
    ld e, a
    ld d, $00
    add hl, de
    ld a, l
    ldh [hMapUpdate.destAddrLow], a
    ld a, h
    ldh [hMapUpdate.destAddrHigh], a
ret
;}

; Load metatile from map to WRAM buffer
mapUpdate_writeToBuffer: ;{ 00:0886
    ; Load tile number from map
    ;  BC is the address of the screen being loaded from
    ;  [$AD] is the tile in that screen ($YX format)
    ldh a, [hMapUpdate.srcBlock]
    ld l, a
    ld h, $00
    add hl, bc
    ld a, [hl]
    ; HL = tiletableArray + (tileNumber * 4)
    ld e, a
    xor a
    ld d, a
    sla e
    rl d
    sla e
    rl d
    ld hl, tiletableArray
    add hl, de
    ; Load tiles from tiletable to temp
    ld a, [hl+]
    ld [tempMetatile.topLeft], a
    ld a, [hl+]
    ld [tempMetatile.topRight], a
    ld a, [hl+]
    ld [tempMetatile.bottomLeft], a
    ld a, [hl+]
    ld [tempMetatile.bottomRight], a
    ; Load WRAM buffer address to HL
    ldh a, [hMapUpdate.buffPtrLow]
    ld l, a
    ldh a, [hMapUpdate.buffPtrHigh]
    ld h, a
    ; Load VRAM address to WRAM buffer
    ldh a, [hMapUpdate.destAddrLow]
    ld [hl+], a
    ldh a, [hMapUpdate.destAddrHigh]
    ld [hl+], a
    ; Load tiles from temp to WRAM buffer
    ld a, [tempMetatile.topLeft]
    ld [hl+], a
    ld a, [tempMetatile.topRight]
    ld [hl+], a
    ld a, [tempMetatile.bottomLeft]
    ld [hl+], a
    ld a, [tempMetatile.bottomRight]
    ld [hl+], a
    ; Save the WRAM buffer address
    ld a, l
    ldh [hMapUpdate.buffPtrLow], a
    ld a, h
    ldh [hMapUpdate.buffPtrHigh], a
ret
;}

; Only call this when rendering is disabled
VBlank_updateMap: ;{ 00:08CF
    ld de, mapUpdateBuffer - 1 ;$ddff

    .loop:
        ; Load address
        inc de
        ld a, [de]
        ld l, a
        inc de
        ld a, [de]
        ld h, a
        and a ; Exit if address is $00xx
            jr z, .break
        ; Load and write top-left tile
        inc de
        ld a, [de]
        ld [hl+], a
        ; Load and write top-right tile
        ld a, h
        and $9b
        ld h, a
        inc de
        ld a, [de]
        ld [hl], a
        ; Load and write bottom-left tile
        ld bc, $001f
        add hl, bc
        ld a, h
        and $9b
        ld h, a
        inc de
        ld a, [de]
        ld [hl+], a
        ; Load and write bottom-right tile
        ld a, h
        and $9b
        ld h, a
        inc de
        ld a, [de]
        ld [hl], a
    jr .loop
    .break:

    xor a
    ld [mapUpdateFlag], a
ret
;}

handleCamera: ;{ 00:08FE
    ld a, [doorScrollDirection]
    and a
        jp nz, handleCamera_door ; Handle door

    ; Get screen index from coordinates
    ldh a, [hCameraYScreen]
    swap a
    ld b, a
    ldh a, [hCameraXScreen]
    or b
    ld e, a    
    ld d, $00
    
    ; Load scroll data for screen
    ld hl, map_scrollData ;$4200
    add hl, de
    ld a, [hl]
    ldh [hTemp.a], a
    
    ; Rightward camera checks {
    ldh a, [hTemp.a]
    bit 0, a ; Check if screen blocks scrolling to the right
    jr z, .endIf_A
        ; Check if the camera is on the right edge of the screen
        ldh a, [hCameraXPixel]
        cp $b0
        jp nz, .else_B
            ; If so, check if Samus is to the right of the screen boundary
            ld a, [samus_onscreenXPos]
            cp $a1
                jr c, .endRightCase
            ; If so, initiate a rightward door transition
            ld a, $01 ; Right
            ld [doorScrollDirection], a
            call loadDoorIndex
            jp .endRightCase
        .else_B:
            ; Check if camera is beyond the right boundary of the screen
            jr c, .endIf_A
                ; If so, move the camera left one pixel
                ldh a, [hCameraXPixel]
                sub $01
                ldh [hCameraXPixel], a
                ldh a, [hCameraXScreen]
                sbc $00
                and $0f
                ldh [hCameraXScreen], a
                jp .endRightCase
    .endIf_A:

    ; Check if camera speed is non-zero
    ld a, [camera_speedRight]
    and a
    jr z, .endIf_C
        ; Move camera rightward
        ld b, a
        ldh a, [hCameraXPixel]
        add b
        ldh [hCameraXPixel], a
        ld b, a
        ldh a, [hCameraXScreen]
        adc $00
        and $0f
        ldh [hCameraXScreen], a

        ; Set scroll bit (for prepMapUpdate)
        ld a, [camera_scrollDirection]
        set scrollDirBit_right, a
        ld [camera_scrollDirection], a

        ; samusX - cameraX + $60
        ; (Get Samus's coordinate in camera-space, relative to the left edge of the screen)
        ldh a, [hSamusXPixel]
        sub b
        add $60 ; Adjusts math to be relative to the edge, not center, of the screen
        
        ; Check if camera has not caught up with the right-scrolling guide
        cp $40
        jr c, .else_D
            ; Move camera an extra pixel right
            ldh a, [hCameraXPixel]
            add $01
            ldh [hCameraXPixel], a
            ldh a, [hCameraXScreen]
            adc $00
            and $0f
            ldh [hCameraXScreen], a
            jr .endIf_C
        .else_D:
            ; Check if the camera is past the right-scrolling guide
            cp $3f
            jr nc, .endIf_C
                ; Move camera an extra pixel left
                ldh a, [hCameraXPixel]
                sub $01
                ldh [hCameraXPixel], a
                ldh a, [hCameraXScreen]
                sbc $00
                and $0f
                ldh [hCameraXScreen], a
    .endIf_C:
    .endRightCase: ;}

    ; Leftward camera checks {
    ldh a, [hTemp.a]
    bit 1, a ; Check if screen blocks scrolling to the left
    jr z, .endIf_E
        ; Check if camera is on the left edge of the screen
        ldh a, [hCameraXPixel]
        cp $50
        jr nz, .else_F
            ; If so, check if Samus is to the left of the screen boundary
            ld a, [samus_onscreenXPos]
            cp $0f
                jp nc, .endLeftCase
            ; If so, initiate a leftwards screen transition
            ld a, $02 ; Left
            ld [doorScrollDirection], a
            ; Normalize Samus's x position
            ld a, $00
            ldh [hSamusXPixel], a
            ; Increment Samus's x screen so the correct door transition is sourced
            ldh a, [hSamusXScreen]
            inc a
            and $0f
            ldh [hSamusXScreen], a
            call loadDoorIndex
            jp .endLeftCase
        .else_F:
            ; Check if camera is past the left edge of the screen
            jr nc, .endIf_E
                ; Move camera one pixel to the right
                ldh a, [hCameraXPixel]
                add $01
                ldh [hCameraXPixel], a
                ldh a, [hCameraXScreen]
                adc $00
                and $0f
                ldh [hCameraXScreen], a
                jr .endLeftCase
    .endIf_E:

    ; Check if camera is moving left
    ld a, [camera_speedLeft]
    and a
    jr z, .endIf_G
        ; Move camera left
        ld a, [camera_speedLeft]
        ld b, a
        ldh a, [hCameraXPixel]
        sub b
        ldh [hCameraXPixel], a
        ld b, a
        ldh a, [hCameraXScreen]
        sbc $00
        and $0f
        ldh [hCameraXScreen], a
        
        ; Set scroll bit (for prepMapUpdate)
        ld a, [camera_scrollDirection]
        set scrollDirBit_left, a
        ld [camera_scrollDirection], a
 
        ; samusX - cameraX + $60
        ; (Get Samus's coordinate in camera-space, relative to the left edge of the screen)
        ldh a, [hSamusXPixel]
        sub b
        add $60 ; Adjusts math to be relative to the edge, not center, of the screen

        ; Check if the camera has not caught up with the left-scrolling guide
        cp $70
        jr nc, .else_H
            ; Move an extra pixel to the left
            ldh a, [hCameraXPixel]
            sub $01
            ldh [hCameraXPixel], a
            ldh a, [hCameraXScreen]
            sbc $00
            and $0f
            ldh [hCameraXScreen], a
            jr .endIf_G
        .else_H:
            ; Check if the camera is beyond the left-scrolling guide
            cp $71
            jr c, .endIf_G
                ; Move an extra pixel to the right
                ldh a, [hCameraXPixel]
                add $01
                ldh [hCameraXPixel], a
                ldh a, [hCameraXScreen]
                adc $00
                and $0f
                ldh [hCameraXScreen], a
    .endIf_G:
    .endLeftCase: ;}

    ; Clear horizontal camera speed variables
    xor a
    ld [camera_speedRight], a
    ld [camera_speedLeft], a
    
    ; samusY - cameraY + $60
    ; (Get Samus's coordinate in camera-space, relative to the left edge of the screen)
    ldh a, [hCameraYPixel]
    ld b, a
    ldh a, [hSamusYPixel]
    sub b
    add $60 ; Adjusts math to be relative to the edge, not center, of the screen
    ldh [hTemp.b], a
    
    ; deltaY = y - yPrev
    ld a, [samusPrevYPixel]
    ld b, a
    ldh a, [hSamusYPixel]
    sub b
        ; Exit if no change in vertical position
        jp z, .exit
    
    ; Upward camera checks {
    ; Jump ahead if Samus moved up
    bit 7, a
    jp nz, .endIf_I
        ; Load deltaY to down speed
        ld [camera_speedDown], a
        ; Set scroll bit (for prepMapUpdate)
        ld a, [camera_scrollDirection]
        set 7, a
        ld [camera_scrollDirection], a
        
        ; Check if screen blocks scrolling downwards
        ldh a, [hTemp.a]
        bit 3, a ; Check down
        jr z, .else_J
            ; Different behaviors for queen room/otherwise
            ld a, [queen_roomFlag]
            cp $11
            jr nz, .else_K
                ; Check if camera is at bottom of queen's room
                ldh a, [hCameraYPixel]
                cp $a0
                    jr nz, .endIf_K
                jr .checkBottomExit
            .else_K:
                ; Check if camera is at bottom of screen
                ldh a, [hCameraYPixel]
                cp $c0
                jr nz, .endIf_K
    
                .checkBottomExit:
                    ; Check if Samus is at the bottom of the screen
                    ld a, [samus_onscreenYPos]
                    cp $78
                        jp c, .exit
                    ; If so, initiate a downwards door transition
                    ld a, $08 ; Down
                    ld [doorScrollDirection], a
                    call loadDoorIndex
                    jp .endIf_I
            .endIf_K:
            
            ; Check if camera is below the lower bound of the screen
            jr c, .else_L
                ; If so, move the camera a pixel up
                ldh a, [hCameraYPixel]
                sub $01
                ldh [hCameraYPixel], a
                ldh a, [hCameraYScreen]
                sbc $00
                and $0f
                ldh [hCameraYScreen], a
                jp .exit
            .else_L:
                ; (Screen does block downward scrolling)
                ; Check if Samus is below a certain threshold
                ldh a, [hTemp.b]
                cp $40
                jp c, .exit
                    ; If so, move the camera down
                    ld a, [camera_speedDown]
                    ld b, a
                    ldh a, [hCameraYPixel]
                    add b
                    ldh [hCameraYPixel], a
                    ldh a, [hCameraYScreen]
                    adc $00
                    ldh [hCameraYScreen], a
                    jp .exit
        .else_J:
            ; (Screen does no block downward scrolling)
            ; Check if Samus is below a certain threshold
            ldh a, [hTemp.b]
            cp $50
            jp c, .exit
                ; If so, move the camera down
                ld a, [camera_speedDown]
                ld b, a
                ldh a, [hCameraYPixel]
                add b
                ldh [hCameraYPixel], a
                ldh a, [hCameraYScreen]
                adc $00
                ldh [hCameraYScreen], a
                jp .exit
    .endIf_I: ;}

    ; Downward camera checks {
    ; Invert deltaY to get upward scrolling speed
    cpl
    inc a
    ld [camera_speedUp], a
    ; Set scroll bit (for prepMapUpdate)
    ld a, [camera_scrollDirection]
    set scrollDirBit_up, a
    ld [camera_scrollDirection], a
    
    ; Check if screen stops scrolling upwards
    ldh a, [hTemp.a]
    bit 2, a ; Check up
    jr z, .else_M
        ; (Screen blocks scrolling upwards)
        ; Check if screen is at threshold
        ldh a, [hCameraYPixel]
        cp $48
        jr nz, .else_N
            ; Check if Samus is above threshold
            ld a, [samus_onscreenYPos]
            cp $1b
                jr nc, .endIf_M
            ; If so, initiate upwards door transition
            ld a, $04 ; Up
            ld [doorScrollDirection], a
            ; Normalize Samus's y position
            ld a, $00
            ldh [hSamusYPixel], a
            ldh a, [hCameraYScreen]
            ldh [hSamusYScreen], a
            ; Perform a check to not initiate an upward transition during the queen fight
            ld a, [queen_roomFlag]
            cp $11
                call nz, loadDoorIndex
            jp .endIf_M
        .else_N:
            ; Check if camera is above threshold
            jr nc, .else_O
                ; If above, scroll down
                ldh a, [hCameraYPixel]
                add $01
                ldh [hCameraYPixel], a
                ldh a, [hCameraYScreen]
                adc $00
                and $0f
                ldh [hCameraYScreen], a
                jr .endIf_M
            .else_O:
                ; If camera is below threshold
                ; Check if Samus is below threshold
                ldh a, [hTemp.b]
                cp $3e
                jr nc, .endIf_M
                    ; If so, scroll upwards
                    ld a, [camera_speedUp]
                    ld b, a
                    ldh a, [hCameraYPixel]
                    sub b
                    ldh [hCameraYPixel], a
                    ldh a, [hCameraYScreen]
                    sbc $00
                    ldh [hCameraYScreen], a
                    jr .endIf_M   
    .else_M:
        ; (Screen does not block scrolling upwards)
        ; Check if Samus is below threshold
        ldh a, [hTemp.b]
        cp $4e
        jr nc, .endIf_M
            ; If so, scroll upwards
            ld a, [camera_speedUp]
            ld b, a
            ldh a, [hCameraYPixel]
            sub b
            ldh [hCameraYPixel], a
            ldh a, [hCameraYScreen]
            sbc $00
            ldh [hCameraYScreen], a
    .endIf_M: ;}

.exit:
    ; Clear vertical speed values
    xor a
    ld [camera_speedDown], a
    ld [camera_speedUp], a
    ; Save previous y position
    ldh a, [hSamusYPixel]
    ld [samusPrevYPixel], a
ret
;}

.unusedTable ; 00:0B39 - Unreferenced data of unknown purpose
    db $00, $01, $01, $00, $00, $00, $01, $02, $02, $01, $01

; Already in a door transition?
handleCamera_door: ;{ 00:0B44
    ; Make sure spinning animation happens during transition
    ld a, [samus_spinAnimationTimer]
    inc a
    ld [samus_spinAnimationTimer], a
    
    ; Check if scrolling right {
    ld a, [doorScrollDirection]
    bit 0, a
    jr z, .endIf_A
        ; Scroll right
        ldh a, [hCameraXPixel]
        add $04
        ldh [hCameraXPixel], a
        ldh a, [hCameraXScreen]
        adc $00
        and $0f
        ldh [hCameraXScreen], a
        ; Ensure the rolling/running pose animates
        ld a, [samus_animationTimer]
        inc a
        inc a
        inc a
        ld [samus_animationTimer], a
        ; Set screen movement direction
        ld a, scrollDir_right
        ld [camera_scrollDirection], a
        ; Move Samus 1 pixel/frame
        ldh a, [hSamusXPixel]
        add $01
        ldh [hSamusXPixel], a
        ldh a, [hSamusXScreen]
        adc $00
        ldh [hSamusXScreen], a
        ; Check if camera has reached threshold
        ldh a, [hCameraXPixel]
        cp $50
            ret nz
        jp .endDoor
    .endIf_A: ;}

    ; Check if scrolling left {
    bit 1, a
    jr z, .endIf_B
        ; Scroll left
        ldh a, [hCameraXPixel]
        sub $04
        ldh [hCameraXPixel], a
        ldh a, [hCameraXScreen]
        sbc $00
        and $0f
        ldh [hCameraXScreen], a
        ; Ensure the rolling/running pose animates
        ld a, [samus_animationTimer]
        inc a
        inc a
        inc a
        ld [samus_animationTimer], a
        ; Set screen movement direction
        ld a, scrollDir_left
        ld [camera_scrollDirection], a
        ; Move Samus
        ldh a, [hSamusXPixel]
        sub $01
        ldh [hSamusXPixel], a
        ldh a, [hSamusXScreen]
        sbc $00
        ldh [hSamusXScreen], a
        ; Check if camera has reached threshold
        ldh a, [hCameraXPixel]
        cp $b0
            ret nz
        jr .endDoor
    .endIf_B: ;}

    ; Check if scrolling up {
    bit 2, a
    jr z, .endIf_C
        ; Scroll up
        ldh a, [hCameraYPixel]
        sub $04
        ldh [hCameraYPixel], a
        ldh a, [hCameraYScreen]
        sbc $00
        and $0f
        ldh [hCameraYScreen], a
        ; Ensure the rolling/running pose animates
        ld a, [samus_animationTimer]
        inc a
        inc a
        inc a
        ld [samus_animationTimer], a
        ; Set screen movement direction
        ld a, scrollDir_up
        ld [camera_scrollDirection], a
        ; Move Samus up 1.5 px/frame
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
        ; Check if camera has reached threshold
        ldh a, [hCameraYPixel]
        cp $b8
            ret nz
        jr .endDoor
    .endIf_C: ;}

    ; Check if scrolling down {
    bit 3, a
    ret z
        ; Scroll down
        ldh a, [hCameraYPixel]
        add $04
        ldh [hCameraYPixel], a
        ldh a, [hCameraYScreen]
        adc $00
        and $0f
        ldh [hCameraYScreen], a
        ; Ensure the rolling/running pose animates
        ld a, [samus_animationTimer]
        inc a
        inc a
        inc a
        ld [samus_animationTimer], a
        ; Set screen movement direction
        ld a, scrollDir_down
        ld [camera_scrollDirection], a
        ; Move Samus down 1.5 px/frame
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
        ; Check if camera has reached threshold
        ldh a, [hCameraYPixel]
        cp $48
            ret nz
    ;} end downwards case

    ; We get here if the once the camera reaches the appropriate threshold
    ; (Note that since the thresholds are checked for equality, so if the
    ;  camera position and speed are somehow misaligned from the threshold,
    ;  then the transition scrolling will continue forever.)
.endDoor:
    ; Clear flags
    xor a
    ld [doorScrollDirection], a
    ld [cutsceneActive], a
    ; Set fade-in timer if the transition triggered a fade-out
    ld a, [bg_palette]
    cp $93
        ret z
    ld a, $2f
    ld [fadeInTimer], a
ret
;}

; Called from handleCamera
loadDoorIndex: ;{ 00:0C37
    ; Check related to being in the Queen fight
    ld a, [queen_roomFlag]
    cp $11
    jr nz, .endIf
        ; If in a spider ball pose, return to morph ball
        ld a, [samusPose]
        cp pose_spiderRoll ; $0B
        jr c, .endIf
            cp pose_spider + 1 ; $0F
            jr nc, .endIf
                ld a, pose_morph ; $05
                ld [samusPose], a
    .endIf:

    ; Clear some collision flags
    xor a
    ld [samus_hurtFlag], a
    ld [saveContactFlag], a

    ; Clear bomb slots
    ld a, $ff
    ld hl, bombArray.slotA ; $DD30
    ld [hl], a
    ld hl, bombArray.slotB ; $DD40
    ld [hl], a
    ld hl, bombArray.slotC ; $DD50
    ld [hl], a
    ; Set flag to indicate a screen transition just started
    ld [justStartedTransition], a
    
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
    ; Load door index
    ld hl, map_doorIndexes ; $4300 - Door transition table
    add hl, de
    ld a, [hl+]
    ld [doorIndexLow], a
    ld a, [hl]
    res 3, a ; Remove sprite priority bit from door index in ROM
    ld [doorIndexHigh], a
    
    ; Set status (to indicate that enemy spawn flags need to be refreshed
    ld a, $02
    ld [doorExitStatus], a
    xor a
    ld [fadeInTimer], a
    
    ; If in debug mode, check input to warp to queen
    ld a, [debugFlag]
    and a
        ret z
    ; Check if either A and Start are pressed
    ldh a, [hInputPressed]
    and PADF_START | PADF_SELECT | PADF_B | PADF_A ;$0f
    cp PADF_SELECT | PADF_B ;$06
        ret nz
    ; Force transition to queen
    ld a, $9d
    ld [doorIndexLow], a
    ld a, $01
    ld [doorIndexHigh], a
ret;}

; Loads Samus' information from the WRAM save buffer to working locations in RAM
loadGame_samusData: ;{ 00:0CA3
    call clearProjectileArray
    
    ld a, [saveBuf_samusXPixel]
    ldh [hSamusXPixel], a
    
    ld a, [saveBuf_samusYPixel]
    ldh [hSamusYPixel], a
    ld [samusPrevYPixel], a
    
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
    
    ; Prep the Samus appearance sequence
    ld a, pose_faceScreen ; $13
    ld [samusPose], a
    ld a, $40
    ld [countdownTimerLow], a
    ld a, $01
    ld [countdownTimerHigh], a
    ld a, $12
    ld [songRequest], a
ret
;}

; Main pose handler for Samus (shooting is handled elsewhere)
samus_handlePose: ;{ 00:0D21
    ; Clear collision flags
    xor a
    ld [waterContactFlag], a
    ld [acidContactFlag], a
    ; Increment animation-related counter
    ld a, [samus_spinAnimationTimer]
    inc a
    ld [samus_spinAnimationTimer], a
    ; Erase inputs if dead
    ld a, [deathFlag]
    and a
    jr z, .endIf
        xor a
        ldh [hInputRisingEdge], a
        ldh [hInputPressed], a
    .endIf:
    ; Exit if door is scrolling
    ld a, [doorScrollDirection]
    and a
        ret nz
    ; Turnaround animation logic
    ld a, [samusPose]
    bit 7, a
        jp nz, handleTurnaroundTimer
    ; Take the jump table
    ld a, [samusPose]
    rst $28
        ; Table Generated from samus/samus.csv
        include "samus/samus_poseJumpTable.asm"
;}

; Samus' pose functions: {

poseFunc_inStomach: ;{ 00:0D87 $1B - In Queen's stomach
    ; Hurt Samus
    call applyDamage.queenStomach
    ; Note: Firing weapons is handled elsewhere
ret ;}

poseFunc_outStomach: ;{ 00:0D8B - $1C - Escaping Queen's mouth
    ; Hurt Samus
    call applyDamage.queenStomach
    
    ; Check if Samus has reached a horizontal threshold
    ldh a, [hSamusXPixel]
    cp $b0
    jr z, .else_A
        ; If not, move Samus right
        add $02
        ldh [hSamusXPixel], a
        ; Check if Samus has reached another horizontal threshold
        cp $80
        jr nc, .else_B
            ; If not, move Samus upwards
            ldh a, [hSamusYPixel]
            sub $02
            ldh [hSamusYPixel], a
            jr .endIf_B
        .else_B:
            ; Check if Samus has reached yet another horizontal threshold
            cp $98
            jr c, .endIf_B
                ; If so, move Samus downwards
                ldh a, [hSamusYPixel]
                dec a
                ldh [hSamusYPixel], a
        .endIf_B:
        ret
    .else_A:
        ; Set up "bomb jump" to the right
        ld a, samus_jumpArrayBaseOffset
        ld [samus_jumpArcCounter], a
        ld a, $01
        ld [samusAirDirection], a
        ; Set pose to escape Queen
        ld a, pose_exitQueen ; $1D
        ld [samusPose], a
        ret 
;}

poseFunc_toStomach: ;{ 00:0DBE - $1A - Being swallowed by Metroid Queen
    ; Hurt Samus
    call applyDamage.queenStomach
    ; Check if Samus has reached stomach
    ldh a, [hSamusXPixel]
    cp $68
    jr z, .else_A
        ; If not, move Samus
        ; Check if (queenX + 6 + scrollX) < samusX
        ld a, [queen_headX]
        add $06
        ld b, a
        ld a, [scrollX]
        add b
        ld b, a
        ldh a, [hSamusXPixel]
        cp b
        jr c, .endIf_B
            ; If so, have Samus move up a pixel
            ldh a, [hSamusYPixel]
            dec a
            ldh [hSamusYPixel], a
        .endIf_B:
        ; Move Samus left
        ldh a, [hSamusXPixel]
        dec a
        ldh [hSamusXPixel], a
        ; Check if Samus is left of a threshold
        cp $80
            ret nc
        ; If so, move Samus down
        ldh a, [hSamusYPixel]
        inc a
        ldh [hSamusYPixel], a
        ret
    .else_A:
        ; Move to next pose
        ld a, pose_inStomach ; $1B
        ld [samusPose], a
        ret
;} end proc

poseFunc_inMouth: ;{ 00:0DF0 - $19 -  In Metroid Queen's mouth
    ; Lock Samus's position
    ld a, $6c
    ldh [hSamusYPixel], a
    ld a, $a6
    ldh [hSamusXPixel], a
    ; Hurt Samus
    call applyDamage.queenStomach
    
    ; Check if Samus bombed the Queen's mouth (non-fatally)
    ld a, [queen_eatingState]
    cp $05
    jr nz, .else_A
        ; Set up "bomb jump" to the right
        ld a, $01
        ld [samusAirDirection], a
        ld a, samus_jumpArrayBaseOffset + $10 ;$50
        ld [samus_jumpArcCounter], a
        ; Set pose to escape Queen
        ld a, pose_exitQueen ; $1D
        ld [samusPose], a
        ret
    .else_A:
        ; Check if Samus bombed the Queen's mouth (fatally)
        cp $20
        jr nz, .else_B
            ; If so, set up "bomb jump" to the right
            ld a, samus_jumpArrayBaseOffset
            ld [samus_jumpArcCounter], a
            ld a, $01
            ld [samusAirDirection], a
            ; Set pose to escape Queen
            ld a, pose_exitQueen ; $1D
            ld [samusPose], a
            ret
        .else_B:
            ; Check if Samus is pressing left
            ldh a, [hInputRisingEdge]
            bit PADB_LEFT, a
                ret z
            ; If so, start swallowing Samus
            ld a, pose_toStomach ; $1A
            ld [samusPose], a
            ld a, $06
            ld [queen_eatingState], a
            ret
;}

poseFunc_beingEaten: ;{ 00:0E36 - $18 - Being eaten by Metroid Queen
    call applyDamage.queenStomach
    ; Move on to next pose if the Queen's mouth is closed
    ld a, [queen_eatingState]
    cp $03
    jr nz, .endIf_A
        ld a, pose_inMouth ; $19
        ld [samusPose], a
        ret
    .endIf_A:

    ; Use C as a counter to count the number of axes Samus is aligned with the queen
    ld c, $00
    ; queenY + $13 - samusY
    ld a, [queen_headY]
    add $13
    ld b, a
    ld a, [samus_onscreenYPos]
    cp b
    ; Check if the y positions are equal
    jr nz, .elseIf_B
        ; Set C to 1 to indicate the y positions are equal
        ld c, $01
        jr .endIf_B
    .elseIf_B:
    ; Check if Samus is above or below the queen's head
    jr c, .else_B
        ; Move Samus up
        ldh a, [hSamusYPixel]
        sub $01
        ldh [hSamusYPixel], a
        ld a, $01
        ld [camera_speedUp], a
        jr .endIf_B
    .else_B:
        ; Move Samus down
        ldh a, [hSamusYPixel]
        add $01
        ldh [hSamusYPixel], a
        ld a, $01
        ld [camera_speedDown], a
    .endIf_B:

    ; queenX + $1A - samusX
    ld a, [queen_headX]
    add $1a
    ld b, a
    ld a, [samus_onscreenXPos]
    cp b
    ; Check if the x positions are equal
    jr nz, .elseIf_C
        ; Increment C to indicate that the x positions are equal
        inc c
        jr z, .endIf_C
    .elseIf_C:
    ; Check if Samus is left or right of the queen's head
    jr c, .else_C
        ; Move Samus left (2 pixels/frame !?)
        ldh a, [hSamusXPixel]
        sub $02
        ldh [hSamusXPixel], a
        ld a, $01
        ld [camera_speedLeft], a
        jr .endIf_C
    .else_C:
        ; Move Samus right
        ldh a, [hSamusXPixel]
        add $01
        ldh [hSamusXPixel], a
        ld a, $01
        ld [camera_speedRight], a
    .endIf_C:

    ; Verify that Samus is aligned with the mouth on both axes
    ld a, c
    cp $02
        ret nz
    ; If so, have the queen's mouth start closing
    ld a, $02
    ld [queen_eatingState], a
ret
;}

poseFunc_faceScreen: ;{ 00:0EA5 - poses $13-$17
    ; Wait until timer expires
    ld a, [countdownTimerLow]
    and a
        ret nz
    ld a, [countdownTimerHigh]
    and a
        ret nz
    ; Request song change if the current song doesn't match what's playing
    ld a, [songPlaying]
    ld b, a
    ld a, [currentRoomSong]
    cp b
    jr z, .endIf_A
        ld [songRequest], a
    .endIf_A:
    ; Keep facing forward if starting a new game
    ld a, [loadingFromFile]
    and a
    jr nz, .endIf_B
        ; Exit if nothing is pressed
        ldh a, [hInputPressed]
        and a
        ret z
    .endIf_B:
    ; Force pose to standing if loading from a file
    xor a
    ld [samusPose], a
ret
;}

poseFunc_morphBombed: ;{ 00:0ECB - $12 and $1D - Morphball bombed
    ; Check if down is pressed
    ldh a, [hInputRisingEdge]
    bit PADB_DOWN, a
    jr z, .endIf
        ; If so, check if we have the Spider Ball
        ld a, [samusItems]
        bit itemBit_spider, a
        jr z, .endIf
            ; If so, activate Spider Ball
            ld a, pose_spiderFall
            ld [samusPose], a
            xor a
            ld [spiderRotationState], a
            ld a, $0d
            ld [sfxRequest_square1], a
            ret
    .endIf:

    ; Check if Up is pressed
    ldh a, [hInputRisingEdge]
    bit PADB_UP, a
    jr z, poseFunc_bombed
        ; If so, unmorph
        call samus_unmorphInAir
        ; Set grace period for unmorph jumping
        ld a, samus_unmorphJumpTime
        ld [samus_unmorphJumpTimer], a
    jr poseFunc_bombed
;}

poseFunc_hurt: ;{ 00:0EF7 - $0F - Knockback
    ; Go to "bombed" pose handler if jump is not pressed
    ldh a, [hInputRisingEdge]
    bit PADB_A, a
        jr z, poseFunc_bombed
    ; Do a mid-air jump

    ; Return if colliding with something
    call collision_samusTop
        ret c

    ; Clear i-frames
    xor a
    ld [samusInvulnerableTimer], a
    ; Set jump counter value and play sound effect
    ;  High-jump case
    ld a, samus_jumpArrayBaseOffset - $1F ;$21
    ld [samus_jumpArcCounter], a
    ld a, $02
    ld [sfxRequest_square1], a
    ; Verify we have high jump
    ld a, [samusItems]
    bit itemBit_hiJump, a
    jr nz, .endIf_A
        ; Normal jump case
        ld a, samus_jumpArrayBaseOffset - $0F ;$31
        ld [samus_jumpArcCounter], a
        ld a, $01
        ld [sfxRequest_square1], a
    .endIf_A:

    ; Reduce height of knockback if in water
    ld a, [waterContactFlag]
    and a
    jr z, .endIf_B
        ld a, [samus_jumpArcCounter]
        add $10
        ld [samus_jumpArcCounter], a
    .endIf_B:

    ; Start jumping
    ld a, pose_nJumpStart
    ld [samusPose], a
    xor a
    ld [samus_jumpStartCounter], a
ret
;}

poseFunc_morphHurt: ;{ 00:0F38 - $10 - Morphball knockback
    ; Check if up is pressed
    ldh a, [hInputRisingEdge]
    bit PADB_UP, a
    jp z, .endIf_A
        ; Attempt to unmorph if so
        call samus_unmorphInAir
        ; Set grace period for unmorph jumping
        ld a, samus_unmorphJumpTime
        ld [samus_unmorphJumpTimer], a
    .endIf_A:

    ; Check if we have Spring Ball
    ld a, [samusItems]
    bit itemBit_spring, a
    jr z, .endIf_B
        ; Check if A is pressed
        ldh a, [hInputRisingEdge]
        bit PADB_A, a
        jr z, .endIf_B
            ; Do mid-air jump
            ; Clear i-frames
            xor a
            ld [samusInvulnerableTimer], a
            ; Set jump counter value
            ld a, samus_jumpArrayBaseOffset - $12 ;$2e
            ld [samus_jumpArcCounter], a
            ; Set pose
            ld a, pose_morphJump
            ld [samusPose], a
            ; Clear counter
            xor a
            ld [samus_jumpStartCounter], a
            ; Play sound
            ld a, $01
            ld [sfxRequest_square1], a
            ret
    .endIf_B:
; Fallthrough to next pose handler
;}

poseFunc_bombed: ;{ 00:0F6C - $11: Bombed (standing)
    ; Load y speed from bombArcTable
    ld a, [samus_jumpArcCounter]
    sub samus_jumpArrayBaseOffset
    ld e, a
    ld d, $00
    ld hl, .bombArcTable
    add hl, de
    ld a, [hl]
    ; Enter falling pose if at end of the table
    cp $80
    jr nz, .endIf_A
        jr .startFalling
    .endIf_A:

    ; Move Samus vertically
    call samus_moveVertical
    ; Check if she hit anything
    jr nc, .endIf_B
        ; If so, start falling if she bonked the ceiling during the rising portion of the knockback
        ld a, [samus_jumpArcCounter]
        cp samus_jumpArrayBaseOffset + $17 ; $57
        jr nc, .startFalling
    .endIf_B:

    ; Increment jump arc counter
    ld a, [samus_jumpArcCounter]
    inc a
    ld [samus_jumpArcCounter], a

    ; Don't let Samus change aerial direction during the rising portion of the knockback
    cp samus_jumpArrayBaseOffset + $16 ; $56
    jr c, .endIf_C
        ; Check if right is pressed
        ldh a, [hInputPressed]
        bit PADB_RIGHT, a
        jr z, .endIf_D
            ; Face right
            ld a, $01
            ld [samusAirDirection], a
        .endIf_D:
    
        ; Check if left is pressed
        ldh a, [hInputPressed]
        bit PADB_LEFT, a
        jr z, .endIf_E
            ; Face left
            ld a, $ff
            ld [samusAirDirection], a
        .endIf_E:
    .endIf_C:

    ; Move right if applicable
    ld a, [samusAirDirection]
    cp $01
    jr nz, .endIf_F
        call samus_moveRightInAir.noTurn
    .endIf_F:
    ; Move left if applicable
    ld a, [samusAirDirection]
    cp $ff
        ret nz
    call samus_moveLeftInAir.noTurn
ret

.startFalling:
    ; Set up counters for falling pose
    xor a
    ld [samus_jumpArcCounter], a
    ld a, $16
    ld [samus_fallArcCounter], a
    ; Set falling pose based on the table below
    ld a, [samusPose]
    ld e, a
    ld d, $00
    ld hl, .fallingPoseTable
    add hl, de
    ld a, [hl]
    ld [samusPose], a
ret

.fallingPoseTable: ; 00:0FD8 - A pose-transition table for going from bombed to falling
    ; Table Generated from samus/samus.csv
    include "samus/samus_bombedFallingPoseTransitionTable.asm"

; Bombed arc table?
.bombArcTable: ; 00:0FF6
    db $fd, $fd, $fd, $fd, $fe, $fd, $fe, $fd, $fe, $fe, $fe, $fe, $fe, $fe, $ff, $fe
    db $fe, $ff, $fe, $ff, $fe, $ff, $ff, $00, $00, $00, $00, $01, $01, $02, $01, $02
    db $01, $02, $02, $01, $02, $02, $02, $02, $02, $02, $03, $02, $03, $02, $03, $03
    db $03, $03, $80
;}

poseFunc_spiderBall: ;{ 00:1029 - $0E: Spider Ball (not moving)
    ; Un-spider if A is pressed
    ldh a, [hInputRisingEdge]
    bit PADB_A, a
    jr z, .endIf_A
        ld a, pose_morph
        ld [samusPose], a
        ld a, $06
        ld [sfxRequest_square1], a
            ret
    .endIf_A:

    ; Fall if not touching anything
    call collision_checkSpiderSet ; Get spiderContactState
    ld a, [spiderContactState]
    and a
    jr nz, .endIf_B
        ld a, pose_spiderFall
        ld [samusPose], a
        ld a, $01
        ld [samus_fallArcCounter], a
    .endIf_B:

    ; Exit if not touching the d-pad
    ldh a, [hInputRisingEdge]
    and PADF_DOWN | PADF_UP | PADF_LEFT | PADF_RIGHT ;$f0
        ret z

    call collision_checkSpiderSet ; Get spiderContactState (again??)
    ldh a, [hInputRisingEdge]
    and PADF_DOWN | PADF_UP | PADF_LEFT | PADF_RIGHT ;$f0
    swap a
    jr z, .fall
        ; Create index into the 2D array spiderBallOrientationTable
        ; - Upper nybble is spiderContactState
        ; - Lower nybble is d-pad inputs
        ld b, a
        ld a, [spiderContactState]
        swap a
        add b
        ld e, a
        ld d, $00
        ; Load value from table
        switchBank spiderBallOrientationTable
        ld hl, spiderBallOrientationTable ; 06:7E03
        add hl, de
        ld a, [hl]
        ld [spiderRotationState], a
        ; Set pose to roll
        ld a, pose_spiderRoll
        ld [samusPose], a
        ret
    .fall:
        ; Note: It should be impossible to get to this branch
        ; Set pose to fall
        ld a, pose_spiderFall
        ld [samusPose], a
        ret
;}

poseFunc_spiderRoll: ;{ 00:1083 - $0B: Spider Ball (rolling)
    ; Un-spider if A is pressed
    ldh a, [hInputRisingEdge]
    bit PADB_A, a
    jr z, .endIf_A
        ld a, pose_morph
        ld [samusPose], a
        ld a, $06
        ld [sfxRequest_square1], a
        ret
    .endIf_A:

    ; Go to normal spider pose if no direction inputs are pressed
    ldh a, [hInputPressed]
    and PADF_DOWN | PADF_UP | PADF_LEFT | PADF_RIGHT ;$f0
    jr nz, .endIf_B
        ld a, pose_spider
        ld [samusPose], a
        xor a
        ld [spiderRotationState], a
        ret
    .endIf_B:

    ; Check collision points surrounding ball
    call collision_checkSpiderSet
    ; Start falling if not touching anything
    ld a, [spiderContactState]
    and a
        jr z, poseFunc_spiderBall.fall

    ; Based off of spiderContactState and spiderRotationState
    ;  load the first movement direction to test
    ld e, a
    ld d, $00
    ld a, [spiderRotationState]
    bit 0, a
    jr z, .else_C
        ld hl, spiderDirectionTable.ccw_try1 ; CCW
        jr .endIf_C
    .else_C:
        bit 1, a
            ret z
        ld hl, spiderDirectionTable.cw_try1 ; CW
    .endIf_C:
    add hl, de
    ld a, [hl]
    ld [spiderBallDirection], a
    
    ; Init variable
    xor a
    ld [spiderDisplacement], a
    
    ; Move in the direction given by whichever table we just read
    ld a, [spiderBallDirection]
    bit 0, a
        call nz, .right
    ld a, [spiderBallDirection]
    bit 1, a
        call nz, .left
    ld a, [spiderBallDirection]
    bit 2, a
        call nz, .up
    ld a, [spiderBallDirection]
    bit 3, a
        call nz, .down

    ; Exit if the spider ball moved at all
    ld a, [spiderDisplacement]
    and a
        ret nz

    ; If the spider ball was unable to move in the first direction it tried (because
    ;  the wall was solid), then try the secondary direction.

    ; Based off of spiderContactState and spiderRotationState
    ;  load the second movement direction to test
    ld a, [spiderContactState]
    ld e, a
    ld d, $00
    ld a, [spiderRotationState]
    bit 0, a
    jr z, .else_D
        ld hl, spiderDirectionTable.ccw_try2 ; CCW
        jr .endIf_D
    .else_D:
        bit 1, a
            ret z
        ld hl, spiderDirectionTable.cw_try2 ; CW
    .endIf_D:
    add hl, de
    ld a, [hl]
    ld [spiderBallDirection], a
    
    ; Clear variable
    xor a
    ld [spiderDisplacement], a

    ; Move in the direction given by whichever table we just read
    ld a, [spiderBallDirection]
    bit 0, a
        call nz, .right
    ld a, [spiderBallDirection]
    bit 1, a
        call nz, .left
    ld a, [spiderBallDirection]
    bit 2, a
        call nz, .up
    ld a, [spiderBallDirection]
    bit 3, a
        call nz, .down
    ; If we had any luck, the spider ball should have moved
ret

.right: ; 00:1132
    call samus_rollRight.spider
    ; Save displacement
    ld a, [camera_speedRight]
    ld [spiderDisplacement], a
ret

.left: ; 00:113C
    call samus_rollLeft.spider
    ; Save displacement
    ld a, [camera_speedLeft]
    ld [spiderDisplacement], a
ret

.up: ; 00:1146
    ; Move up 1 pixel
    ld a, $01
    call samus_moveUp
    ; Save displacement
    ld a, [camera_speedUp]
    ld [spiderDisplacement], a
ret

.down: ; 00:1152
    ; Move down 1 pixel
    ld a, $01
    call samus_moveVertical
    ; Save displacement
    ld a, [camera_speedDown]
    ld [spiderDisplacement], a
    ; Exit if Samus was unimpeded moving down
        ret nc
    ; Exit if Samus landed into a solid sprite
    ld a, [samus_onSolidSprite]
    and a
        ret nz
    ; Normalize Samus's y position
    ldh a, [hSamusYPixel]
    and $f8
    or $04
    ldh [hSamusYPixel], a
    ; Clear displacement
    xor a
    ld [spiderDisplacement], a
ret
;}

poseFunc_spiderJump: ;{ 00:1170 - $0D: Spider ball jumping
    ; Un-spider if A is pressed
    ldh a, [hInputRisingEdge]
    bit PADB_A, a
    jr z, .endIf_A
        ld a, pose_morphJump
        ld [samusPose], a
        ld a, $06
        ld [sfxRequest_square1], a
        ret
    .endIf_A:

    ; Check if were in the linear portion of the jump
    ld a, [samus_jumpArcCounter]
    cp samus_jumpArrayBaseOffset
    jr nc, .endIf_B
        ; Check if A is being held down
        ldh a, [hInputPressed]
        bit PADB_A, a
        jr z, .else_C
            ; If so, ascend 2 pixels/frame
            ld a, -2 ; $FE
                jr .moveVertical
        .else_C:
            ; Else, start falling
            ld a, samus_jumpArrayBaseOffset + $16 ;$56
            ld [samus_jumpArcCounter], a
    .endIf_B:

    ; Read vertical speed from jump arc table
    sub samus_jumpArrayBaseOffset
    ld hl, jumpArcTable
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    ; Start falling if at the end of the table
    cp samus_jumpArrayBaseOffset + $40 ;$80
        jr z, .startFalling

.moveVertical:
    ; Move vertically
    call samus_moveVertical
        ; If we hit something, consider sticking to it
        jp c, poseFunc_spiderFall.land

    ; Spider collision check
    call collision_checkSpiderSet
    ld a, [spiderContactState]
    and a
        ; If we touched something, then stick to it
        jp nz, poseFunc_spiderFall.attach

    ; Increment jump counter
    ld a, [samus_jumpArcCounter]
    inc a
    ld [samus_jumpArcCounter], a

;moveHorizontal
    ; Move right if right is pressed
    ldh a, [hInputPressed]
    bit PADB_RIGHT, a
    jr z, .else_D
        call poseFunc_spiderRoll.right ; Change to "samus_rollRight.morph" for BIDIRECTIONAL SPIDER THROWING ($1132 -> $1C98)
        ret
    .else_D:
        ; Move left if left is pressed
        ldh a, [hInputPressed]
        bit PADB_LEFT, a
        jr z, .else_E
            call samus_rollLeft.morph
            ret
        .else_E:
            ; Don't move horizontally
            ret

.startFalling:
    ; What? Why is this writing to ROM?
    xor a
    ld [jumpArcTable], a
    ; Start falling
    ld a, $16
    ld [samus_fallArcCounter], a
    ld a, pose_spiderFall
    ld [samusPose], a
    xor a
    ld [spiderRotationState], a
ret
;}

poseFunc_spiderFall: ;{ 00:11E4 - $0C
    ; Un-spider if we pressed A
    ldh a, [hInputRisingEdge]
    bit PADB_A, a
    jr z, .endIf_A
        ld a, pose_morphFall
        ld [samusPose], a
        ; Play sound
        ld a, $06
        ld [sfxRequest_square1], a
        ret
    .endIf_A:

    ; If we pressed right, move right
    ldh a, [hInputPressed]
    bit PADB_RIGHT, a
    jr z, .else_B
        call poseFunc_spiderRoll.right
        jr .endIf_B
    .else_B:
        ; If we pressed left, move left
        ldh a, [hInputPressed]
        bit PADB_LEFT, a
        jr z, .endIf_C
            call poseFunc_spiderRoll.left
        .endIf_C:
    .endIf_B:

    ; Move vertically according to value in fallArcTable
    ld hl, fallArcTable
    ld a, [samus_fallArcCounter]
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    call samus_moveVertical
        ; If Samus hit something, then land
        jr c, .land

    ; Check spider collision points
    call collision_checkSpiderSet
    ld a, [spiderContactState]
    and a
        ; If Samus touched something, then stick to it
        jr nz, .attach

    ; Increment fall counter
    ld a, [samus_fallArcCounter]
    inc a
    ld [samus_fallArcCounter], a
    ; Clamp value to $16
    cp $17
    jr c, .endIf_D
        ld a, $16
        ld [samus_fallArcCounter], a
    .endIf_D:
ret

.land:
    ; Check if Samus landed on a solid sprite
    ld a, [samus_onSolidSprite]
    and a
    jr nz, .endIf_E
        ; If not, then normalize Samus's y position
        ldh a, [hSamusYPixel]
        and $f8
        or $04
        ldh [hSamusYPixel], a
    .endIf_E:
.attach:
    ; Set pose to spider rolling
    ld a, pose_spiderRoll
    ld [samusPose], a
    ; Clear counter
    xor a
    ld [samus_fallArcCounter], a
ret
;}

poseFunc_morphFall: ;{ 00:123B - $08: Morphball falling
    ; Check if down was just pressed
    ldh a, [hInputRisingEdge]
    bit PADB_DOWN, a
    jr z, .endIf_A
        ; If so, check if we have spider
        ld a, [samusItems]
        bit itemBit_spider, a
        jr z, .endIf_A
            ; If so, enter spider falling pose
            ld a, pose_spiderFall
            ld [samusPose], a
            xor a
            ld [spiderRotationState], a
            ; Play sound
            ld a, $0d
            ld [sfxRequest_square1], a
            ret
    .endIf_A:

    ; Handle morph jump in acid (unused)
    ;  This should allow for a free morph jump in acid
    ;  But since collision check hasn't been performed yet this frame
    ;  acidContactFlag is never set, so the code inside is never executed
    ldh a, [hInputRisingEdge]
    bit PADB_A, a
    jr z, .endIf_B
        ld a, [acidContactFlag]
        and a
        jr z, .endIf_B
            ; This code is never executed
            ; Set jump counter to acidContactFlag's value
            ld [samus_jumpArcCounter], a
            ; Set pose
            ld a, pose_morphJump
            ld [samusPose], a
            ;
            xor a
            ld [samus_jumpStartCounter], a
            ; Play jump sound
            ld a, $01
            ld [sfxRequest_square1], a
            ret
    .endIf_B:

    ; Check if up was just pressed
    ldh a, [hInputRisingEdge]
    bit PADB_UP, a
    jr z, .endIf_C
        ; If so, try unmorphing
        call samus_unmorphInAir
        ; Set grace period of mid-air jumping
        ld a, samus_unmorphJumpTime
        ld [samus_unmorphJumpTimer], a
        jr .exit
    .endIf_C:

;moveHorizontal
    ; Move right if right is pressed
    ldh a, [hInputPressed]
    bit PADB_RIGHT, a
    jr z, .endIf_D
        call samus_moveRightInAir.turn
        ; The value loaded from camera_speedRight appears to be immediately discarded after the jump
        ld a, [samusItems]
        bit itemBit_spider, a
        jr z, .endIf_D
            ld a, [camera_speedRight]
            jr .moveVertical
    .endIf_D:

    ; Move left if left is pressed
    ldh a, [hInputPressed]
    bit PADB_LEFT, a
    jr z, .endIf_E
        call samus_moveLeftInAir.turn
        ; The value loaded from camera_speedLeft appears to be immediately discarded after the jump
        ld a, [samusItems]
        bit itemBit_spider, a
        jr z, .endIf_E
            ld a, [camera_speedLeft]
    .endIf_E

.moveVertical:
    ; Move vertically according to the value in the fallArcTable
    ld hl, fallArcTable
    ld a, [samus_fallArcCounter]
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    call samus_moveVertical
    ; Branch ahead if Samus landed on something
    jr c, .else
        ; Keep falling
        ; Increase fall counter
        ld a, [samus_fallArcCounter]
        inc a
        ld [samus_fallArcCounter], a
        ; Clamp value to $16
        cp $17
        jr c, .endIf_F
            ld a, $16
            ld [samus_fallArcCounter], a
        .endIf_F:
        
        .exit:
        ret
    .else: ; Hit ground
        ; Set pose
        ld a, pose_morph
        ld [samusPose], a
        ; Clear counter
        xor a
        ld [samus_fallArcCounter], a
        ; Exit if Samus landed on a solid enemy
        ld a, [samus_onSolidSprite]
        and a
            ret nz
        ; Normalize Samus's y position
        ldh a, [hSamusYPixel]
        and $f8
        or $04
        ldh [hSamusYPixel], a
        ret
;} end proc

poseFunc_fall: ;{ 00:12F5 - $07 - Falling
    ; Check if A was just pressed
    ldh a, [hInputRisingEdge]
    bit PADB_A, a
    jr z, .endIf_A
        ; Check if Samus has touched acid
        ld a, [acidContactFlag]
        and a
        jr z, .else_B
            ; Set jump counter to value of acidContactFlag
            ; Note: Samus BG collision has not been evaluated yet for this frame,
            ;  so this branch is never executed.
            ld [samus_jumpArcCounter], a
            jr .endIf_B
        .else_B:
            ; Check if unmorph jump timer is non-zero
            ld a, [samus_unmorphJumpTimer]
            and a
                jr z, .endIf_A
            ; If so, initiate aerial jump (high jump)
            ld a, samus_jumpArrayBaseOffset - $1F ;$21
            ld [samus_jumpArcCounter], a
        .endIf_B:
        ; High jump SFX
        ld a, $02
        ld [sfxRequest_square1], a

        ; Check if Samus does not have high jump
        ld a, [samusItems]
        bit itemBit_hiJump, a
        jr nz, .endIf_C
            ; If so, provide normal jump parameters
            ld a, samus_jumpArrayBaseOffset - $F ;$31
            ld [samus_jumpArcCounter], a
            ; High jump 
            ld a, $01
            ld [sfxRequest_square1], a
        .endIf_C:
        ; Set pose
        ld a, pose_nJumpStart
        ld [samusPose], a
        ; Clear timers
        xor a
        ld [samus_jumpStartCounter], a
        xor a
        ld [samus_unmorphJumpTimer], a
        ret    
    .endIf_A:

    ; Check if right is held
    ldh a, [hInputPressed]
    bit PADB_RIGHT, a
    jr z, .else_D
        ; If so, move right
        call samus_moveRightInAir.turn
        jr .endIf_D
    .else_D:
        ; Check if left is held
        ldh a, [hInputPressed]
        bit PADB_LEFT, a
        jr z, .endIf_D
            ; If so, move left
            call samus_moveLeftInAir.turn
    .endIf_D:

    ; Read fall arc table and move accordingly
    ld hl, fallArcTable
    ld a, [samus_fallArcCounter]
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    call samus_moveVertical
    ; Branch ahead if Samus hit something
    jr c, .else_E
        ; Increment fall counter
        ld a, [samus_fallArcCounter]
        inc a
        ld [samus_fallArcCounter], a
        ; Clamp fall counter to $16
        cp $17
        jr c, .endIf_F
            ld a, $16
            ld [samus_fallArcCounter], a
        .endIf_F:
        ret
    .else_E:
        ; Try standing
        call samus_tryStanding
        jr nc, .endIf_G
            ; Crouch if we didn't have room to stand
            ld a, pose_crouch
            ld [samusPose], a
        .endIf_G:
        ; Clear fall counter
        xor a
        ld [samus_fallArcCounter], a
        ; Exit if Samus landed on a solid sprite
        ld a, [samus_onSolidSprite]
        and a
            ret nz
        ; Normalize y position if not on solid sprite
        ldh a, [hSamusYPixel]
        and $f8
        or $04
        ldh [hSamusYPixel], a
        ret
;}

fallArcTable: ;{ 00:1386
    db $01, $01, $01, $01, $00, $01, $01, $00, $01, $01, $01, $01, $01, $01, $02, $01
    db $02, $02, $01, $02, $02, $02, $03
;}

handleTurnaroundTimer: ;{ Called if MSB of Samus' pose is set
    call collision_samusBottom ; Downwards BG collision
    ; Exit this state if jump is pressed
    ldh a, [hInputRisingEdge]
    bit PADB_A, a
    jp nz, .endIf
        ; Decrement timer
        ld hl, samus_turnAnimTimer
        dec [hl]
        ret nz
    .endIf:
    ; Clear MSB of pose
    ld a, [samusPose]
    res 7, a
    ld [samusPose], a
    jp samus_handlePose
;} end proc

poseFunc_standing: ;{ 00:13B7 - $00: Standing
    ; Fall if ground is missing
    call collision_samusBottom
    jr c, .endIf_A
        ld a, pose_fall
        ld [samusPose], a
        ld a, $01
        ld [samus_fallArcCounter], a
        ret
    .endIf_A:
    ; Clear timer
    xor a
    ld [samus_animationTimer], a

; Handle spin jump inputs
    ldh a, [hInputRisingEdge]
    bit PADB_A, a
    jr z, .endIf_B
        ldh a, [hInputPressed]
        and PADF_LEFT | PADF_RIGHT ;$30
        jr z, .endIf_B
            ; This check makes it so you can't spin-jump from a standstill without Space Jump. Very strange.
            ld a, [samusItems]
            bit itemBit_space, a
                jp z, .normalJump
            ; Return if a ceiling is in the way
            call collision_samusTop
                ret c
            ; High jump parameters
            ld a, samus_jumpArrayBaseOffset - $1F ;$21
            ld [samus_jumpArcCounter], a
            ld a, $02
            ld [sfxRequest_square1], a
            ; Check for high jump
            ld a, [samusItems]
            bit itemBit_hiJump, a
            jr nz, .endIf_C
                ; Normal jump parameters
                ld a, samus_jumpArrayBaseOffset - $0F ;$31
                ld [samus_jumpArcCounter], a
                ld a, $01
                ld [sfxRequest_square1], a
            .endIf_C:
            ; Decrease jump height in water
            ld a, [waterContactFlag]
            and a
            jr z, .endIf_D
                ld a, [samus_jumpArcCounter]
                add $10
                ld [samus_jumpArcCounter], a
            .endIf_D:
            ; Select pose
            ld a, pose_spinStart
            ld [samusPose], a
            ; Clear jump start counter
            xor a
            ld [samus_jumpStartCounter], a
            ; Set up Screw Attack sound if needed
            ld a, [samusItems]
            bit itemBit_screw, a
                ret z
            ld a, $03
            ld [sfxRequest_square1], a
            ret
    .endIf_B:
    
; Handle right input
    ldh a, [hInputPressed]
    bit PADB_RIGHT, a
    jr z, .endIf_E
        ; Check facing direction
        ld a, [samusFacingDirection]
        cp $01
        jr z, .else_F
            ; Turning around
            ld a, $80 | pose_run
            ld [samusPose], a
            ld a, $01
            ld [samusFacingDirection], a
            ld a, $02
            ld [samus_turnAnimTimer], a
            ld a, $04
            ld [sfxRequest_square1], a
            ret
        .else_F:
            ; Walking forward
            call samus_walkRight
                ret c
            ld a, $01
            ld [samusFacingDirection], a
            ld a, pose_run
            ld [samusPose], a
            ret
    .endIf_E:

; Handle left input
    ldh a, [hInputPressed]
    bit PADB_LEFT, a
    jr z, .endIf_G
        ; Check facing direction
        ld a, [samusFacingDirection]
        cp $00
        jr z, .else_H
            ; Turning around
            ld a, $80 | pose_run
            ld [samusPose], a
            ld a, $00
            ld [samusFacingDirection], a
            ld a, $02
            ld [samus_turnAnimTimer], a
            ld a, $04
            ld [sfxRequest_square1], a
            ret
        .else_H:
            ; Walking forward
            call samus_walkLeft
                ret c
            ld a, $00
            ld [samusFacingDirection], a
            ld a, pose_run
            ld [samusPose], a
            ret
    .endIf_G:

; Handle morph input
    ldh a, [hInputRisingEdge]
    bit PADB_DOWN, a
    jr z, .endIf_I
        ; Clear cooldown timer (so we don't instantly morph)
        xor a
        ld [samus_animationTimer], a
        ; Set pose
        ld a, pose_crouch
        ld [samusPose], a
        ; Play sound
        ld a, $05
        ld [sfxRequest_square1], a
        ret
    .endIf_I:

; Handle normal jump input
    ldh a, [hInputRisingEdge]
    bit PADB_A, a
    jr z, .endIf_J
        .normalJump: ; Entry point from a weird case above
        call collision_samusTop
            ret c
        ; High jump parameters
        ld a, samus_jumpArrayBaseOffset - $1F ;$21
        ld [samus_jumpArcCounter], a
        ld a, $02
        ld [sfxRequest_square1], a
        ; Check for high jump
        ld a, [samusItems]
        bit itemBit_hiJump, a
        jr nz, .endIf_K
            ; Normal jump parameters
            ld a, samus_jumpArrayBaseOffset - $0F ;$31
            ld [samus_jumpArcCounter], a
            ld a, $01
            ld [sfxRequest_square1], a
        .endIf_K:
        ; Decrease jump height in water
        ld a, [waterContactFlag]
        and a
        jr z, .endIf_L
            ld a, [samus_jumpArcCounter]
            add $10
            ld [samus_jumpArcCounter], a
        .endIf_L:
        ; Set pose
        ld a, pose_nJumpStart
        ld [samusPose], a
        ; Clear counter
        xor a
        ld [samus_jumpStartCounter], a
        ret
    .endIf_J:
ret
;}

poseFunc_running: ;{ 00:14D6 - $03: Running
    ; Fall if ground is missing
    call collision_samusBottom
    jr c, .endIf_A
        ld a, pose_fall
        ld [samusPose], a
        ld a, $01
        ld [samus_fallArcCounter], a
        ret
    .endIf_A:

    ; Animation timer
    ld hl, samus_animationTimer
    inc [hl]
    inc [hl]
    inc [hl]

; Handle spin jump inputs
    ldh a, [hInputRisingEdge]
    bit PADB_A, a
    jr z, .endIf_B
        ldh a, [hInputPressed]
        and PADF_LEFT | PADF_RIGHT ;$30
        jr z, .endIf_B
            ; Exit if a ceiling is in the way
            call collision_samusTop
                ret c
            ; High jump parameter
            ld a, samus_jumpArrayBaseOffset - $1F ;$21
            ld [samus_jumpArcCounter], a
            ; Request sound
            ld a, [samusItems]
            and itemMask_hiJump
            srl a
            inc a
            ld [sfxRequest_square1], a
            ; Check equipment
            ld a, [samusItems]
            bit itemBit_hiJump, a
            jr nz, .endIf_C
                ; Normal jump parameter
                ld a, samus_jumpArrayBaseOffset - $0F ;$31
                ld [samus_jumpArcCounter], a
            .endIf_C:
            ; Decrease jump height in water
            ld a, [waterContactFlag]
            and a
            jr z, .endIf_D
                ld a, [samus_jumpArcCounter]
                add $10
                ld [samus_jumpArcCounter], a
            .endIf_D:
            ; Set pose
            ld a, pose_spinStart
            ld [samusPose], a
            ; Clear counter
            xor a
            ld [samus_jumpStartCounter], a
            ; Request Screw Attack sound if needed
            ld a, [samusItems]
            bit itemBit_screw, a
                ret z
            ld a, $03
            ld [sfxRequest_square1], a
            ret
    .endIf_B:

; Handle right input
    ldh a, [hInputPressed]
    bit PADB_RIGHT, a
    jr z, .endIf_E
        ; Check facing direction
        ld a, [samusFacingDirection]
        cp $01
        jr z, .else_F
            ; Turn around
            ld a, $80 | pose_run
            ld [samusPose], a
            ld a, $01
            ld [samusFacingDirection], a
            ld a, $02
            ld [samus_turnAnimTimer], a
            ld a, $04
            ld [sfxRequest_square1], a
            ret
        .else_F:
            ; Walk forwards
            call samus_walkRight
                ret nc
            xor a
            ld [samusPose], a
            ret
    .endIf_E:

; Handle left input
    ldh a, [hInputPressed]
    bit PADB_LEFT, a
    jr z, .endIf_G
        ; Check facing direction
        ld a, [samusFacingDirection]
        cp $00
        jr z, .else_H
            ; Turn around
            ld a, $80 | pose_run
            ld [samusPose], a
            ld a, $00
            ld [samusFacingDirection], a
            ld a, $02
            ld [samus_turnAnimTimer], a
            ld a, $04
            ld [sfxRequest_square1], a
            ret
        .else_H:
            ; Walk forward
            call samus_walkLeft
                ret nc
            xor a
            ld [samusPose], a
            ret
    .endIf_G:

    ; Set pose to standing (neither direction was pressed, so no longer walking)
    xor a
    ld [samusPose], a

; Handle down input
    ldh a, [hInputRisingEdge]
    bit PADB_DOWN, a
    jr z, .endIf_I
        ; Clear cooldown timer (so you don't instantly morph)
        xor a
        ld [samus_animationTimer], a
        ; Set pose
        ld a, pose_crouch
        ld [samusPose], a
        ; Request sound
        ld a, $05
        ld [sfxRequest_square1], a
        ret
    .endIf_I:

; Handle normal jump input
    ldh a, [hInputRisingEdge]
    bit PADB_A, a
    jr z, .endIf_J
        ; Exit if ceiling is in the way
        ldh a, [hSamusYPixel]
        sub $08
        ldh [hSamusYPixel], a
        call collision_samusTop
            ret c
        
        ; High jump parameter
        ld a, samus_jumpArrayBaseOffset - $1F ;$21
        ld [samus_jumpArcCounter], a
        ; Check equipment
        ld a, [samusItems]
        bit itemBit_hiJump, a
        jr nz, .endIf_K
            ; Normal jump parameter
            ld a, samus_jumpArrayBaseOffset - $0F ;$31
            ld [samus_jumpArcCounter], a
        .endIf_K:
        
        ; Set pose
        ld a, pose_nJumpStart
        ld [samusPose], a
        ; Clear counter
        xor a
        ld [samus_jumpStartCounter], a
        
        ; High jump sound
        ld a, $02
        ld [sfxRequest_square1], a
        ; Check equipment
        ld a, [samusItems]
        bit itemBit_hiJump, a
        jr nz, .endIf_L
            ; Normal jump sound
            ld a, $01
            ld [sfxRequest_square1], a
        .endIf_L:
        
        ; Decrease jump height in water
        ld a, [waterContactFlag]
        and a
        jr z, .endIf_M
            ld a, [samus_jumpArcCounter]
            add $10
            ld [samus_jumpArcCounter], a
        .endIf_M:
    .endIf_J:
ret
;}

poseFunc_crouch: ;{ 00:15F4 - $04: Crouching
    ; Start falling if ground disappears
    call collision_samusBottom
    jr c, .endIf_A
        ld a, pose_fall
        ld [samusPose], a
        ld a, $01
        ld [samus_fallArcCounter], a
        ret
    .endIf_A:

; Handle right input
    ldh a, [hInputPressed]
    bit PADB_RIGHT, a
    jr z, .endIf_B
        ; inc input cooldown timer
        ld a, [samus_animationTimer]
        inc a
        ld [samus_animationTimer], a
        ; Jump ahead if cooldown is met
        cp $08
        jr nc, .endIf_C
            ; Exit if statement if not a rising edge
            ldh a, [hInputRisingEdge]
            bit PADB_RIGHT, a
                jr z, .endIf_B
        .endIf_C:
        ; We've reached this point if the cooldown is done or if the input was a rising edge
        ; Clear cooldown
        xor a
        ld [samus_animationTimer], a
        ; Check if facing direction matches input
        ld a, [samusFacingDirection]
        cp $01
        jr nz, .else_D
            ; It's a match. Now prep to move forward
            call samus_tryStanding ; Stand
                ret nc
            ; Morph if can't stand
            ld a, pose_morph
            ld [samusPose], a
            ld a, $06
            ld [sfxRequest_square1], a
            ret
        .else_D:
            ; Turn around
            ld a, $01
            ld [samusFacingDirection], a
            ret
    .endIf_B:

; Handle left input
    ldh a, [hInputPressed]
    bit PADB_LEFT, a
    jr z, .endIf_E
        ; inc input cooldown timer
        ld a, [samus_animationTimer]
        inc a
        ld [samus_animationTimer], a
        ; Jump ahead if cooldown is met
        cp $08
        jr nc, .endIf_F
            ; Exit if statement if not a rising edge
            ldh a, [hInputRisingEdge]
            bit PADB_LEFT, a
                jr z, .endIf_E
        .endIf_F:
        ; We've reached this point if the cooldown is done or if the input was a rising edge
        ; Clear cooldown
        xor a
        ld [samus_animationTimer], a
        ; Check if facing direction matches input
        ld a, [samusFacingDirection]
        and a
        jr nz, .else_G
            ; It's a match. Now prep to move forward
            call samus_tryStanding ; Stand
                ret nc
            ; Morph if can't stand
            ld a, pose_morph
            ld [samusPose], a
            ld a, $06
            ld [sfxRequest_square1], a
            ret
        .else_G:
            ; Turn around
            ld a, $00
            ld [samusFacingDirection], a
            ret
    .endIf_E:

; Handle jump input
    ldh a, [hInputRisingEdge]
    bit PADB_A, a
    jr z, .endIf_H
        ; Request appropriate jump sound effect
        ld a, [samusItems]
        and itemMask_hiJump
        srl a
        inc a
        ld [sfxRequest_square1], a
        ; Check if we're making a normal jump or spin jump
        ldh a, [hInputPressed]
        and PADF_LEFT | PADF_RIGHT ;$30
        jr z, .else_I
            ; Spin jump
            ld a, pose_spinJump
            ld [samusPose], a
            ; Request screw sound effect
            ld a, [samusItems]
            bit itemBit_screw, a
            jr z, .endIf_I
                ld a, $03
                ld [sfxRequest_square1], a
                jr .endIf_I
        .else_I:
            ; Normal jump
            ld a, pose_jump
            ld [samusPose], a
        .endIf_I:

        ; High jump counter value
        ld a, samus_jumpArrayBaseOffset - $1F ;$21
        ld [samus_jumpArcCounter], a
        ld a, [samusItems]
        bit itemBit_hiJump, a
        jr nz, .endIf_J
            ; Normal jump counter value
            ld a, samus_jumpArrayBaseOffset - $0F ;$31
            ld [samus_jumpArcCounter], a
        .endIf_J:

        ; Make jump lower if in water
        ld a, [waterContactFlag]
        and a
        jr z, .endIf_K
            ld a, [samus_jumpArcCounter]
            add $10
            ld [samus_jumpArcCounter], a
        .endIf_K:
    
        ; Clear jump start counter
        ; (Not sure if this is necessary since we're not entering the jumpStart pose)
        xor a
        ld [samus_jumpStartCounter], a
        ret
    .endIf_H:

; Handle down input
    ; Rising edge
    ldh a, [hInputRisingEdge]
    bit PADB_DOWN, a
    jr z, .endIf_L
        call samus_morphOnGround
        ret
    .endIf_L:

    ; Already pressed
    ldh a, [hInputPressed]
    bit PADB_DOWN, a
    jr z, .endIf_M
        ; Increment cooldown
        ld a, [samus_animationTimer]
        inc a
        ld [samus_animationTimer], a
        ; Morph if cooldown is done
        cp $10
            ret c
        call samus_morphOnGround
        ret
    .endIf_M:

; Handle up input
    ; Rising edge
    ldh a, [hInputRisingEdge]
    bit PADB_UP, a
    jr z, .endIf_N
        call samus_tryStanding
        ret
    .endIf_N:

    ; Already pressed
    ldh a, [hInputPressed]
    bit PADB_UP, a
    jr z, .endIf_O
        ; Increment cooldown
        ld a, [samus_animationTimer]
        inc a
        ld [samus_animationTimer], a
        ; Stand if cooldown is done
        cp $10
            ret c
        call samus_tryStanding
        ret
    .endIf_O:
ret
;}

poseFunc_morphBall: ;{ 00:1701 - $05: Morph ball
    ; Start falling if nothing below
    call collision_samusBottom
    jr c, .endIf_A
        ld a, pose_morphFall
        ld [samusPose], a
        ; init fall arc counter
        ld a, $01
        ld [samus_fallArcCounter], a
        ret
    .endIf_A:

    ; Activate spider ball
    ldh a, [hInputRisingEdge]
    bit PADB_DOWN, a
        jr nz, .activateSpiderBall

    ; Unmorph on ground
    ldh a, [hInputRisingEdge]
    bit PADB_UP, a
    jr z, .endIf_B
        call samus_groundUnmorph
        ret
    .endIf_B:

    ; Handle spring ball
    ; Check if A is pressed
    ldh a, [hInputPressed]
    bit PADB_A, a
    jr z, .endIf_C
        ; Check if we have spring ball
        ld a, [samusItems]
        bit itemBit_spring, a
        jr z, .endIf_C
            ; Set jump parameter
            ld a, samus_jumpArrayBaseOffset - $12 ;$2e
            ld [samus_jumpArcCounter], a
            ; Set pose
            ld a, pose_morphJump
            ld [samusPose], a
            ; Clear counter
            xor a
            ld [samus_jumpStartCounter], a
            ; Play SFX
            ld a, $01
            ld [sfxRequest_square1], a
            ret
    .endIf_C:

    ; Bounce if last vertical speed was >= 2
    ld a, [samus_speedDown]
    cp $02
    jr c, .else_A
        ; Handle morph bounce
        ldh a, [hInputPressed]
        bit PADB_DOWN, a
            jp nz, .activateSpiderBall
        ld a, pose_morphJump
        ld [samusPose], a
        ld a, $01
        ld [sfxRequest_square1], a
        ; Set up initial jump arc table index for morph bounce
        jr nz, .else_B
            ; Unused
            ld a, samus_jumpArrayBaseOffset + $08 ;$48
            ld [samus_jumpArcCounter], a
            ret
        .else_B:
            ; Used
            ld a, samus_jumpArrayBaseOffset + $04 ;$44
            ld [samus_jumpArcCounter], a
            ret
    .else_A: ; Move horizontal
        xor a
        ld [samus_speedDown], a
        ldh a, [hInputPressed]
        bit PADB_RIGHT, a
        jr z, .else_C
            call samus_rollRight.morph
            ld a, [camera_speedRight]
            ret
        .else_C:
            ldh a, [hInputPressed]
            bit PADB_LEFT, a
                ret z
            call samus_rollLeft.morph
            ld a, [camera_speedLeft]
            ret
; end proc

.activateSpiderBall:
    ; Check for item
    ld a, [samusItems]
    bit itemBit_spider, a
        ret z
    ; Set pose and variables
    ld a, pose_spider
    ld [samusPose], a
    ld a, $01
    ld [samus_fallArcCounter], a
    xor a
    ld [spiderRotationState], a
    ; Play noise
    ld a, $0d
    ld [sfxRequest_square1], a
ret
;}

poseFunc_morphJump: ;{ 00:179F - $06: Morph Jump
    ; Check down input
    ldh a, [hInputRisingEdge]
    bit PADB_DOWN, a
    jr z, .jump
        ; Check for item
        ld a, [samusItems]
        bit itemBit_spider, a
        jr z, .jump
            ; Enter the spider ball
            ld a, pose_spiderJump
            ld [samusPose], a
            xor a
            ld [spiderRotationState], a
            ld a, $0d
            ld [sfxRequest_square1], a
            ret
    .jump: ; Fall through to jump handler below
;} end proc

poseFunc_jump: ;{ 00:17BB - Pose $01
    ; Check if in linear portion of ascent
    ld a, [samus_jumpArcCounter]
    cp samus_jumpArrayBaseOffset
    jr nc, .endIf_A
        ; If so, check if A is pressed
        ldh a, [hInputPressed]
        bit PADB_A, a
        jr z, .endIf_B
            ; Set speed, subtracting an extra 1 from it if we have high jump
            ld a, [samusItems]
            and itemMask_hiJump
            srl a
            ld b, a
            ld a, -2 ; $FE
            sub b
                jr .moveVertical
        .endIf_B:
        ; If A is not pressed, start falling portion of arc
        ld a, samus_jumpArrayBaseOffset + $16 ;56
        ld [samus_jumpArcCounter], a
    .endIf_A:

    ; Get vertical speed from jumpArcTable
    sub samus_jumpArrayBaseOffset
    ld hl, jumpArcTable
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    ; Start falling pose if at the end of the table
    cp samus_jumpArrayBaseOffset + $40 ;$80
        jr z, .startFalling

    ; Skip ahead if moving upwards
    bit 7, a
    jr nz, .endIf_C
        ; If the acid contact flag is set, start falling
        ld a, [acidContactFlag]
        and a
            jr nz, .startFalling ; Note: acidContactFlag is never set at this point in the main loop, so this jump appears to be thankfully never taken.
        ld a, [hl]
    .endIf_C

.moveVertical:
    call samus_moveVertical
    ; Bonk head on ceiling
    jr nc, .endIf_D
        ld a, [samus_jumpArcCounter]
        ; Enter falling pose if prior to the falling portion of the jump
        cp samus_jumpArrayBaseOffset + $17 ; 57
            jr nc, .startFalling
    .endIf_D:

    ; Increment jump counter
    ld a, [samus_jumpArcCounter]
    inc a
    ld [samus_jumpArcCounter], a
    ; Unmorph (if morphed and up is pressed)
    ld a, [samusPose]
    cp pose_morphJump
    jr nz, .endIf_E
        ldh a, [hInputRisingEdge]
        bit PADB_UP, a
        jr z, .endIf_E
            call samus_unmorphInAir
            ld a, $10
            ld [samus_unmorphJumpTimer], a
    .endIf_E:

;moveHorizontal
    ; Move right if right is pressed
    ldh a, [hInputPressed]
    bit PADB_RIGHT, a
    jr z, .endIf_F
        call samus_moveRightInAir.turn
    .endIf_F:

    ; Move left if left is pressed
    ldh a, [hInputPressed]
    bit PADB_LEFT, a
    jr z, .endIf_G
        call samus_moveLeftInAir.turn
    .endIf_G:
ret

.startFalling:
    ; Why write to ROM?
    xor a
    ld [jumpArcTable], a
    ; Set counter
    ld a, $16
    ld [samus_fallArcCounter], a
    ; Check if morphed
    ld a, [samusPose]
    cp pose_morphJump
    jr z, .endIf_H
        ; If not, just fall
        ld a, pose_fall
        ld [samusPose], a
        ret
    .endIf_H:
        ; If morphed, fall as a ball
        ld a, pose_morphFall
        ld [samusPose], a
        ret
;} end proc

; Jump arc table
; - This starts being referenced when the jump counter is $40
; - I have no idea why the game tries writing to this table
jumpArcTable: ;{ 00:184A - Jump arc table
    db $fe, $fe, $fe, $fe, $ff, $fe, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $ff, $00, $ff
    db $ff, $00, $ff, $00, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $01
    db $00, $01, $01, $00, $01, $01, $01, $01, $01, $01, $02, $01, $02, $01, $02, $02
    db $02, $02, $03, $02, $02, $03, $02, $02, $03, $02, $03, $02, $03, $02, $03, $02
    db $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $80
;}

; Space Jump Table
; - $00 means no space jumping on that frame
; - Non-zero values mean that you can space jump on that frame
;  - Different non-zero values appear to have no meaning in the code (uncertain)
spaceJumpTable: ;{ 00:1899
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $02, $01, $02, $02
    db $02, $02, $03, $02, $02, $03, $02, $02, $03, $02, $03, $02, $03, $02, $03, $02
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80
;}

poseFunc_spinJump: ;{ 00:18E8 - $02: Spin jumping
    ; Break out of spin if firing a shot
    ldh a, [hInputRisingEdge]
    bit PADB_B, a
    jr z, .endIf_A
        ld a, pose_jump
        ld [samusPose], a
    .endIf_A:

    ; If jump timer is > $40, then jump ahead
    ld a, [samus_jumpArcCounter]
    cp samus_jumpArrayBaseOffset
    jr nc, .endIf_B
        ; Handle linear ascent of the jump
        ; If A is being held, proper upwards
        ldh a, [hInputPressed]
        bit PADB_A, a
        jr z, .endIf_C
            ; Normal jump speed is 2 px/frame
            ; With hi jump it's 3 px/frame
            ld a, [samusItems]
            and itemMask_hiJump
            srl a
            ld b, a
            ld a, -2 ;$fe
            sub b
                ; Jump ahead to handle vertical movement
                jr .moveVertical
        .endIf_C:
        ; Set position to table to the apex of the jump
        ld a, samus_jumpArrayBaseOffset + $16
        ld [samus_jumpArcCounter], a
    .endIf_B:

    ; Handle arc of jump (tabular data)
    ; Get index into the table
    sub samus_jumpArrayBaseOffset
    ld e, a
    ld d, $00
    ; Skip ahead if not holding jump
    ldh a, [hInputRisingEdge]
    bit PADB_A, a
    jr z, .endIf_D
        ; Load value from table
        ld hl, spaceJumpTable
        add hl, de
        ld a, [hl]
        ; Skip ahead if zero
        and a
        jr z, .endIf_D
            ; Handle space jump
            ld a, [samusItems]
            bit itemBit_space, a
            jr z, .endIf_D
                ; High-jump space jump value
                ld a, samus_jumpArrayBaseOffset - $28 ;$18
                ld [samus_jumpArcCounter], a
                ld a, $02
                ld [sfxRequest_square1], a
                
                ld a, [samusItems]
                bit itemBit_hiJump, a
                jr nz, .endIf_E
                    ; Normal jump space jump value
                    ld a, samus_jumpArrayBaseOffset - $18 ;$28
                    ld [samus_jumpArcCounter], a
                    ld a, $01
                    ld [sfxRequest_square1], a
                .endIf_E:
                ; Screw sound effect
                ld a, [samusItems]
                bit itemBit_screw, a
                jr z, .endIf_F
                    ld a, $03
                    ld [sfxRequest_square1], a
                .endIf_F:
                ; Convert Samus's air direction to her facing direction
                ld a, [samusAirDirection]
                and a
                    ret z
                inc a
                srl a
                ld [samusFacingDirection], a
                ret
    .endIf_D:

    ; Check if Samus is doing a neutral spinning jump (yes, it's possible)
    ld a, [samusAirDirection]
    and a
    jr nz, .endIf_G
        ; Check if up is being held
        ldh a, [hInputPressed]
        bit PADB_UP, a
        jr z, .endIf_G
            ; Exit every 3 out of 4 frames (fall slowly)
            ldh a, [frameCounter]
            and $03
                ret nz
    .endIf_G:

    ; Check if we're at the end of the table
    ld hl, jumpArcTable
    add hl, de
    ld a, [hl]
    cp samus_jumpArrayBaseOffset + $40 ;$80
        jr nz, .moveVertical
    ; Start falling
    jr .breakSpin

.moveVertical:
    ; Skip ahead if moving upwards
    bit 7, a
    jr nz, .endIf_H
        ; If the acid contact flag is set, start falling
        ; Note: acidContactFlag is never set at this point, so this jump appears to be never taken (thankfully).
        ld a, [acidContactFlag]
        and a
            jr nz, .breakSpin
        ld a, [hl]
    .endIf_H:

    ; Move Samus vertically
    call samus_moveVertical
    jr nc, .endIf_I
        ; If Samus hit the ceiling during the ascending part of the jump
        ld a, [samus_jumpArcCounter]
        cp samus_jumpArrayBaseOffset + $17
            jr c, .endIf_I
        ; Then enter the falling pose
        jr .startFalling
    .endIf_I:

    ; Increment jump counter
    ld a, [samus_jumpArcCounter]
    inc a
    ld [samus_jumpArcCounter], a

;.moveHorizontal:
    ; Make Samus face right if right is pressed
    ldh a, [hInputPressed]
    bit PADB_RIGHT, a
    jr z, .endIf_J
        ld a, $01
        ld [samusAirDirection], a
    .endIf_J:

    ; Make Samus face left if left is pressed
    ldh a, [hInputPressed]
    bit PADB_LEFT, a
    jr z, .endIf_K
        ld a, $ff
        ld [samusAirDirection], a
    .endIf_K:

    ; If Samus is facing right, move right
    ld a, [samusAirDirection]
    cp $01
    jr nz, .else
        call samus_moveRightInAir.noTurn
        ret
    .else:
        ; If Samus is facing left, move left
        ld a, [samusAirDirection]
        cp $ff
            ret nz
        call samus_moveLeftInAir.noTurn
        ret

    ret ; Unreferenced return :-(

.breakSpin:
    ; Play a sound effect when breaking spin if Samus has either space or screw
    ld a, [samusItems]
    and itemMask_space | itemMask_screw
    jr z, .endIf_L
        ld a, $04
        ld [sfxRequest_square1], a
    .endIf_L

.startFalling:
    ; Why write to rom?
    xor a
    ld [jumpArcTable], a
    ; Set fall arc counter to max
    ld a, $16
    ld [samus_fallArcCounter], a
    ; Set pose
    ld a, pose_fall
    ld [samusPose], a
ret
;}

poseFunc_jumpStart: ;{ 00:19E2 - $09 and $0A - Starting to jump
    ; Check if A is pressed
    ldh a, [hInputPressed]
    bit PADB_A, a
    jr z, .endIf_A
        ; Move up 2 pixel/frame, with an extra pixel 2 out of 4 frames
        ldh a, [frameCounter]
        and $02
        srl a
        ld b, a
        ld a, -2 ; $FE
        sub b
        call samus_moveVertical
        jr nc, .endIf_B
            call samus_tryStanding
            ret
        .endIf_B:
    
        ; Increment jump-start counter
        ld a, [samus_jumpStartCounter]
        inc a
        ld [samus_jumpStartCounter], a
        ; Branch ahead if counter has expired
        cp $06
        jr nc, .endIf_A
            ; Move/turn right if right is pressed
            ldh a, [hInputPressed]
            bit PADB_RIGHT, a
            jr z, .endIf_C
                call samus_moveRightInAir.turn
                ret
            .endIf_C:
            
            ; Move/turn left if left is pressed
            ldh a, [hInputPressed]
            bit PADB_LEFT, a
            jr z, .endIf_D
                call samus_moveLeftInAir.turn
                ret
            .endIf_D:
            ret
    .endIf_A:

    ; Check if Samus is starting a normal jump or spin jump
    ld a, [samusPose]
    cp pose_nJumpStart
    jr nz, .else
        ; Start a normal jump
        ld a, pose_jump
        ld [samusPose], a
        ret
    .else:
        ; Start a spin jump
        ; Use inputs to set samusAirDirection from .directionTable
        ldh a, [hInputPressed]
        and PADF_LEFT | PADF_RIGHT
        swap a
        ld e, a
        ld d, $00
        ld hl, .directionTable
        add hl, de
        ld a, [hl]
        ld [samusAirDirection], a
        ; Set pose to spin jump
        ld a, pose_spinJump
        ld [samusPose], a
        ret
; end proc

.directionTable:
    db $00, $01, $ff
;}
;}

;------------------------------------------------------------------------------
; Check all the collision points pertinent to the spider ball
;
; The following points are checked,
;     x   y             arranged like so:
; Corners    Bitmasks           |
;  0 $15 $1E  %0001             |
;  1 $15 $2C  %0010             v
;  2 $0A $1E  %0100          2 _6_ 0
;  3 $0A $2C  %1000           /   \
; Sides                      5|   |4
;  4 $15 $25  %0011           \___/
;  5 $0A $25  %1100          3  7  1
;  6 $0F $1E  %0101
;  7 $0F $2C  %1010
;
; Notice that the bitmasks for the sides are the OR'd sum of the bitmasks their
;  adjacent corners.
;

; Pertinent constants (TODO: get these from every other Samus-related collision function too and put them in their own file)
spiderXLeft  = $0A
spiderXRight = $15
spiderXMid   = (spiderXLeft + spiderXRight)/2 ; $0F

spiderYTop    = $1E
spiderYBottom = $2C
spiderYMid    = (spiderYTop + spiderYBottom)/2 ; $25

collision_checkSpiderSet: ;{ 00:1A42
    ; Clear spider ball results flag
    xor a
    ld [spiderContactState], a
; Point 0 ($15, $1E)
    ldh a, [hSamusXPixel]
    add spiderXRight
    ld [tileX], a

    ldh a, [hSamusYPixel]
    add spiderYTop
    ld [tileY], a
    call collision_checkSpiderPoint
    
    ld a, [spiderContactState]
    rr a
    ld [spiderContactState], a
    
; Point 1 ($15, $2C)
    ldh a, [hSamusYPixel]
    add spiderYBottom
    ld [tileY], a
    call collision_checkSpiderPoint
    
    ld a, [spiderContactState]
    rr a
    ld [spiderContactState], a
    
; Point 2 ($0A, $1E)
    ldh a, [hSamusXPixel]
    add spiderXLeft
    ld [tileX], a

    ldh a, [hSamusYPixel]
    add spiderYTop
    ld [tileY], a
    call collision_checkSpiderPoint
    
    ld a, [spiderContactState]
    rr a
    ld [spiderContactState], a
    
; Point 3 ($0A, $2C)
    ldh a, [hSamusYPixel]
    add spiderYBottom
    ld [tileY], a
    call collision_checkSpiderPoint
    
    ld a, [spiderContactState]
    rr a
    ld [spiderContactState], a
    ; All corner bits are in, now swap them into the lower nybble
    swap a
    ld [spiderContactState], a
    
; Point 4 ($15, $25)
    ldh a, [hSamusXPixel]
    add spiderXRight
    ld [tileX], a

    ldh a, [hSamusYPixel]
    add spiderYMid
    ld [tileY], a
    call collision_checkSpiderPoint
    
    jr nc, .endIf_A
        ld a, [spiderContactState]
        or %0011
        ld [spiderContactState], a
    .endIf_A:

; Point 5 ($0A, $25)
    ldh a, [hSamusXPixel]
    add spiderXLeft
    ld [tileX], a

    ldh a, [hSamusYPixel]
    add spiderYMid
    ld [tileY], a
    call collision_checkSpiderPoint
    
    jr nc, .endIf_B
        ld a, [spiderContactState]
        or %1100
        ld [spiderContactState], a
    .endIf_B:

; Point 6 ($0F, $1E)
    ldh a, [hSamusXPixel]
    add spiderXMid
    ld [tileX], a

    ldh a, [hSamusYPixel]
    add spiderYTop
    ld [tileY], a
    call collision_checkSpiderPoint
    
    jr nc, .endIf_C
        ld a, [spiderContactState]
        or %0101
        ld [spiderContactState], a
    .endIf_C:

; Point 7 ($0F, $2C)
    ldh a, [hSamusYPixel]
    add spiderYBottom
    ld [tileY], a

    ldh a, [hSamusXPixel]
    add spiderXMid
    ld [tileX], a
    ; I don't know why this doesn't just use collision_checkSpiderPoint,
    ;  unless it's to minimize the damage from the acid
    call samus_getTileIndex
    ld hl, samusSolidityIndex
    cp [hl]
    jr nc, .else_D
        ld a, [spiderContactState]
        or %1010
        ld [spiderContactState], a
        jr .endIf_D
    .else_D:
        call collision_samusEnemiesDown ; Sprite collision for bottom?
        jr nc, .endIf_D
            ld a, [spiderContactState]
            or %1010
            ld [spiderContactState], a
    .endIf_D:

    ; Does this code do anything?
    ld a, [spiderContactState]
    and $05
    cp $05
        ret z
    ldh a, [hInputPressed]
    bit PADB_A, a
        ret z
    ret
;} end proc

samus_groundUnmorph: ;{ 00:1B2E - Unmorph on ground
    ; Check upper left pixel
    ldh a, [hSamusXPixel]
    add $0b
    ld [tileX], a
jr samus_groundUnmorph_cont ;} This is structured like it used to be a conditional jump...

; Attempts to stand up. Returns carry if it fails.
samus_tryStanding: ;{ 00:1B37
    ld a, $04
    ld [sfxRequest_square1], a
    ; Check upper left pixel
    ldh a, [hSamusXPixel]
    add $0c
    ld [tileX], a
    ldh a, [hSamusYPixel]
    add $10
    ld [tileY], a
    call samus_getTileIndex
    ld hl, samusSolidityIndex
    cp [hl]
        ret c
    ; Check upper right pixel
    ldh a, [hSamusXPixel]
    add $14
    ld [tileX], a
    call samus_getTileIndex
    ld hl, samusSolidityIndex
    cp [hl]
        ret c
    ; Set pose to standing
    xor a
    ld [samusPose], a
    ld a, $04
    ld [sfxRequest_square1], a
ret
;}

samus_groundUnmorph_cont: ;{ 00:1B6B - Unmorph on ground, continued
    ; Check upper left pixel (cont.)
    ldh a, [hSamusYPixel]
    add $18
    ld [tileY], a
    call samus_getTileIndex
    ; Check if solid
    ld hl, samusSolidityIndex
    cp [hl]
    jr c, .endIf
        ; Was not solid, check upper right pixel
        ldh a, [hSamusXPixel]
        add $14
        ld [tileX], a
        call samus_getTileIndex
        ; Check if solid
        ld hl, samusSolidityIndex
        cp [hl]
        jr c, .endIf
            ; Was not solid, so crouch
            ld a, pose_crouch
            ld [samusPose], a
            ; Clear timer, play sound
            xor a
            ld [samus_animationTimer], a
            ld a, $05
            ld [sfxRequest_square1], a
            ret
    .endIf:
    ; Remain in morph
    ld a, pose_morph
    ld [samusPose], a
    ; Clear vertical speed
    xor a
    ld [samus_speedDown], a
ret ;}

samus_morphOnGround: ;{ 00:1BA4
    ; Set pose
    ld a, pose_morph
    ld [samusPose], a
    ; Clear vertical speed
    xor a
    ld [samus_speedDown], a
    ; Play morphing sound
    ld a, $06
    ld [sfxRequest_square1], a
ret ;}

samus_unmorphInAir: ;{ 00:1BB3
; Check top row of tiles
    ; Check upper-left tile
    ldh a, [hSamusYPixel]
    add $08
    ld [tileY], a
    ldh a, [hSamusXPixel]
    add $0b
    ld [tileX], a
    call samus_getTileIndex
    ld hl, samusSolidityIndex
    cp [hl]
        jr c, .exit
    ; Check upper-right tile
    ldh a, [hSamusXPixel]
    add $14
    ld [tileX], a
    call samus_getTileIndex
    ld hl, samusSolidityIndex
    cp [hl]
        jr c, .exit
; Check lower row of tiles
    ; Check lower-left tile
    ldh a, [hSamusYPixel]
    add $18
    ld [tileY], a
    ldh a, [hSamusXPixel]
    add $0b
    ld [tileX], a
    call samus_getTileIndex
    ld hl, samusSolidityIndex
    cp [hl]
        jr c, .exit
    ; Check lower-right tile
    ldh a, [hSamusXPixel]
    add $14
    ld [tileX], a
    call samus_getTileIndex
    ld hl, samusSolidityIndex
    cp [hl]
        jr c, .exit

    ; Set pose
    ld a, pose_fall
    ld [samusPose], a
    ; Fall
    ld a, $04
    ld [sfxRequest_square1], a
ret
    .exit:
ret ;}

; Samus movement functions {
; Move right (walking)
samus_walkRight: ;{ 00:1C0D
    ; Set facing direction
    ld a, $01
    ld [samusFacingDirection], a
; Set speed
    ; Water walking speed
    ld b, $01
    ; Check if touching water
    ld a, [waterContactFlag]
    and a
    jr nz, .endIf
        ; If not, then check equipment
        ld a, [samusItems]
        bit itemBit_varia, a
        jr z, .else
            ; Varia walking speed
            ld b, $02
            jr .endIf
        .else:
            ; Normal walking speed (1.5 px/f)
            ldh a, [frameCounter]
            and $01
            add $01
            ld b, a
    .endIf:
    
    ; Move Samus right
    ldh a, [hSamusXPixel]
    add b
    ldh [hSamusXPixel], a
    ldh a, [hSamusXScreen]
    adc $00
    and $0f
    ldh [hSamusXScreen], a
    ; Unnecessary write to this variable (since the collision function immediately overwrites it)
    ld [tileX], a

    ; Perform collision test
    call collision_samusHorizontal.right
    jr nc, .keepResults
        ; Revert to previous X position if we hit something
        ld a, [prevSamusXPixel]
        ldh [hSamusXPixel], a
        ld a, [prevSamusXScreen]
        ldh [hSamusXScreen], a
        ret
    .keepResults:
        ; Keep results
        ; Set camera speed
        ld a, b
        ld [camera_speedRight], a
        ret
;} end proc

samus_walkLeft: ;{ 00:1C51
    ; Set facing direction
    xor a
    ld [samusFacingDirection], a
; Set speed
    ; Water speed
    ld b, $01
    ; Check if touching water
    ld a, [waterContactFlag]
    and a
    jr nz, .endIf
        ; If not, then check equipment
        ld a, [samusItems]
        bit itemBit_varia, a
        jr z, .else
            ; Varia walking speed
            ld b, $02
            jr .endIf
        .else:
            ; Normal walking speed (1.5 px/f)
            ldh a, [frameCounter]
            and $01
            add $01
            ld b, a
    .endIf:

    ; Move Samus left
    ldh a, [hSamusXPixel]
    sub b
    ldh [hSamusXPixel], a
    ldh a, [hSamusXScreen]
    sbc $00
    and $0f
    ldh [hSamusXScreen], a
    ; Unnecessary write to this variable (since the collision function immediately overwrites it)
    ld [tileX], a
    
    ; Perform collision test
    call collision_samusHorizontal.left
    jr nc, .keepResults
        ; Revert to previous X position if we hit something
        ld a, [prevSamusXPixel]
        ldh [hSamusXPixel], a
        ld a, [prevSamusXScreen]
        ldh [hSamusXScreen], a
        ret
    .keepResults:
        ; Keep results
        ; Set camera speed
        ld a, b
        ld [camera_speedLeft], a
        ret
;} end proc

samus_rollRight: ;{
    .spider: ; 00:1C94 - Entry point for spider
        ld a, $01
        jr .start
    .morph: ; 00:1C98 - Entry point for morph
        ld a, $02
.start:
    ; Set speed
    ld b, a
    ; Set facing direction
    ld a, $01
    ld [samusFacingDirection], a
    
    ; Move right
    ldh a, [hSamusXPixel]
    add b
    ldh [hSamusXPixel], a
    ldh a, [hSamusXScreen]
    adc $00
    and $0f
    ldh [hSamusXScreen], a
    ; Unnecessary write to this variable (since the collision function immediately overwrites it)
    ld [tileX], a
    
    ; Perform collision test
    call collision_samusHorizontal.right
    jr nc, .keepResults
        ; Revert to previous X position if we hit something
        ld a, [prevSamusXPixel]
        ldh [hSamusXPixel], a
        ld a, [prevSamusXScreen]
        ldh [hSamusXScreen], a
        ret
    .keepResults:
        ; Keep results
        ; Set camera speed
        ld a, b
        ld [camera_speedRight], a
        ret
;}

samus_rollLeft: ;{
    .spider: ; 00:1CC5 - Entry point for spider
        ld a, $01
        jr .start
    .morph: ; 00:1CC9 - Entry point for morph
        ld a, $02
.start:
    ; Set speed
    ld b, a
    ; Set facing direction
    xor a
    ld [samusFacingDirection], a
    
    ; Move left
    ldh a, [hSamusXPixel]
    sub b
    ldh [hSamusXPixel], a
    ldh a, [hSamusXScreen]
    sbc $00
    and $0f
    ldh [hSamusXScreen], a
    ; Unnecessary write to this variable (since the collision function immediately overwrites it)
    ld [tileX], a
    
    ; Perform collision test
    call collision_samusHorizontal.left
    jr nc, .keepResults
        ; Revert to previous X position if we hit something
        ld a, [prevSamusXPixel]
        ldh [hSamusXPixel], a
        ld a, [prevSamusXScreen]
        ldh [hSamusXScreen], a
        ret
    .keepResults:
        ; Keep results
        ; Set camera speed
        ld a, b
        ld [camera_speedLeft], a
        ret
;}

samus_moveRightInAir: ;{ 00:1CF5
.turn:
    ; Set facing direction
    ld a, $01
    ld [samusFacingDirection], a
.noTurn: ; 00:1CFA Alternate entry
    ; Set speed
    ld a, $01
    ld b, a
    
    ; Move right
    ldh a, [hSamusXPixel]
    add b
    ldh [hSamusXPixel], a
    ldh a, [hSamusXScreen]
    adc $00
    and $0f
    ldh [hSamusXScreen], a    
    ; Unnecessary write to this variable (since the collision function immediately overwrites it)
    ld [tileX], a
    
    ; Perform collision test
    call collision_samusHorizontal.right
    jr nc, .keepResults
        ; Revert to previous X position if we hit something
        ld a, [prevSamusXPixel]
        ldh [hSamusXPixel], a
        ld a, [prevSamusXScreen]
        ldh [hSamusXScreen], a
        ret
    .keepResults:
        ; Keep results
        ; Set camera speed
        ld a, b
        ld [camera_speedRight], a
        ret
;}

samus_moveLeftInAir: ;{ 00:1D22
.turn:
    ; Set facing direction
    xor a
    ld [samusFacingDirection], a
.noTurn: ; 00:1D26 - Alternate entry
    ; Set speed
    ld a, $01
    ld b, a
    
    ; Move left
    ldh a, [hSamusXPixel]
    sub b
    ldh [hSamusXPixel], a
    ldh a, [hSamusXScreen]
    sbc $00
    and $0f
    ldh [hSamusXScreen], a
    ; Unnecessary write to this variable (since the collision function immediately overwrites it)
    ld [tileX], a
    
    ; Perform collision test
    call collision_samusHorizontal.left
    jr nc, .keepResults
        ; Revert to previous X position if we hit something
        ld a, [prevSamusXPixel]
        ldh [hSamusXPixel], a
        ld a, [prevSamusXScreen]
        ldh [hSamusXScreen], a
        ret
    .keepResults:
        ; Keep results
        ; Set camera speed
        ld a, b
        ld [camera_speedLeft], a
        ret
;}

; Note: The caller might provide the speed in A
samus_moveVertical: ;{ 00:1D4E - move down
    ; Move up if negative
    bit 7, a
        jr nz, .moveUp
    ; else, move down
    ; Set speed
    ld b, a
    ld a, b
    ld [samus_speedDownTemp], a
    
    ; Move down
    ldh a, [hSamusYPixel]
    add b
    ldh [hSamusYPixel], a
    ldh a, [hSamusYScreen]
    adc $00
    and $0f
    ldh [hSamusYScreen], a
    ; Loading speed to A for no apparent reason
    ld a, b
    
    ; Perform collision test
    call collision_samusBottom
    jr nc, .keepResults
        ; Revert to previous X position if we hit something
        ld a, [prevSamusYPixel]
        ldh [hSamusYPixel], a
        ld a, [prevSamusYScreen]
        ldh [hSamusYScreen], a
        ; Set carry so the caller knows we hit something
        scf
        ret
    .keepResults:
        ; Check if we're touching water
        ld a, [waterContactFlag]
        and a
        jr z, .endIf
            ; If so, halve the speed
            srl b
            ld a, [prevSamusYPixel]
            add b
            ldh [hSamusYPixel], a
            ld a, [prevSamusYScreen]
            adc $00
            ldh [hSamusYScreen], a
        .endIf:
        ; Set camera speed
        ld a, b
        ld [camera_speedDown], a
        ; Set downwards speed for later use (e.g. morph bouncing)
        ld a, [samus_speedDownTemp]
        ld [samus_speedDown], a
        ret

.moveUp:
    ; Negate speed value so it's positive
    cpl
    inc a
;} Fall-through to move up routine
    
samus_moveUp: ;{ 00:1D98 - Move up (only directly called by spider ball)
    ; Set speed
    ld b, a

    ; Move up
    ldh a, [hSamusYPixel]
    sub b
    ldh [hSamusYPixel], a
    ldh a, [hSamusYScreen]
    sbc $00
    and $0f
    ldh [hSamusYScreen], a
    ; Loading speed to A for no apparent reason
    ld a, b
    
    ; Perform collision test
    call collision_samusTop
    jr nc, .keepResults
        ; Bonk head on ceiling if we hit something
        ld a, samus_jumpArrayBaseOffset + $16 ;$56
        ; Revert to previous X position
        ld [samus_jumpArcCounter], a
        ld a, [prevSamusYPixel]
        ldh [hSamusYPixel], a
        ld a, [prevSamusYScreen]
        ldh [hSamusYScreen], a
        ret
    .keepResults:
        ; Check if touching water
        ld a, [waterContactFlag]
        and a
        jr z, .endIf
            ; Halve speed if so
            srl b
            ld a, [prevSamusYPixel]
            sub b
            ldh [hSamusYPixel], a
            ld a, [prevSamusYScreen]
            sbc $00
            ldh [hSamusYScreen], a
        .endIf:
        ; Set camera speed
        ld a, b
        ld [camera_speedUp], a
        ret
;}
;}

;------------------------------------------------------------------------------
; Samus's BG collision functions {
collision_samusHorizontal: ;{ Has two entry points (left and right)
    .left: ; 00:1DD6 - Entry point for left-side collision
        push hl
        push de
        push bc
        ; Get offset for left side
        ldh a, [hSamusXPixel]
        add $0b
        ld [tileX], a
        jr .start
    .right: ; 00:1DE2 - Entry point for right-side collision
        push hl
        push de
        push bc
        ; Get offset for right side
        ldh a, [hSamusXPixel]
        add $14
        ld [tileX], a
.start: ; Start
    ; Do sprite collision
    call collision_samusEnemies.horizontal
        jp c, .exit
    
    ; Get base address to the first entry for the pose's y offset list
    ; HL = list + pose*8
    ld hl, collision_samusHorizontalYOffsetLists
    ld a, [samusPose]
    sla a
    sla a
    sla a
    ld e, a
    ld d, $00
    add hl, de
    
    ; Read each entry in the list, skipping ahead to collision if it is $80
    ; Read 1st entry
    ld a, [hl+]
    cp $80
    jp z, .endIf_A
        ld [collision_samusYOffset_A], a
        ; Read 2nd entry
        ld a, [hl+]
        cp $80
        jr z, .endIf_B
            ld [collision_samusYOffset_B], a
            ; Read 3rd entry
            ld a, [hl+]
            cp $80
            jr z, .endIf_C
                ld [collision_samusYOffset_C], a
                ; Read 4th entry
                ld a, [hl+]
                cp $80
                jr z, .endIf_D
                    ld [collision_samusYOffset_D], a
                    ; Read 5th entry
                    ld a, [hl]
                    cp $80
                    jr z, .endIf_E
                        ; Test 5th pointh
                        ld b, a
                        ldh a, [hSamusYPixel]
                        add b
                        ld [tileY], a
                        call samus_getTileIndex
                        ld hl, samusSolidityIndex
                        cp [hl]
                            jr c, .exit
                    .endIf_E:
                    ; Test 4th point
                    ld a, [collision_samusYOffset_D]
                    ld b, a
                    ldh a, [hSamusYPixel]
                    add b
                    ld [tileY], a
                    call samus_getTileIndex
                    ld hl, samusSolidityIndex
                    cp [hl]
                        jr c, .exit
                .endIf_D:
                ; Test 3rd point
                ld a, [collision_samusYOffset_C]
                ld b, a
                ldh a, [hSamusYPixel]
                add b
                ld [tileY], a
                call samus_getTileIndex
                ld hl, samusSolidityIndex
                cp [hl]
                    jr c, .exit
            .endIf_C:
            ; Test 2nd point
            ld a, [collision_samusYOffset_B]
            ld b, a
            ldh a, [hSamusYPixel]
            add b
            ld [tileY], a
            call samus_getTileIndex
            ld hl, samusSolidityIndex
            cp [hl]
                jr c, .exit
        .endIf_B:
        ; Test 1st point
        ld a, [collision_samusYOffset_A]
        ld b, a
        ldh a, [hSamusYPixel]
        add b
        ld [tileY], a
        call samus_getTileIndex
        ld hl, samusSolidityIndex
        cp [hl]
            jr c, .exit
    .endIf_A:
    ; Done testing points (or: no points tested)
.exit:
    pop bc
    pop de
    pop hl
ret
;}

; Samus upwards BG collision detection
collision_samusTop: ;{ 00:1E88
    push hl
    push de
    push bc
    ; Check sprite collision
    call collision_samusEnemiesUp
        jp c, .exit

; Top left side
    ; Set x offset for left side
    ldh a, [hSamusXPixel]
    add $0c
    ld [tileX], a
    ; Load y offset for top from table
    ld hl, collision_samusBGHitboxTopTable
    ld a, [samusPose]
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    ; Set offset for top
    ld b, a
    ldh a, [hSamusYPixel]
    add b
    ld [tileY], a
    ; Perform collision check
    call samus_getTileIndex

    ; Perform compare operation to set the carry flag if applicable
    ld hl, samusSolidityIndex
    cp [hl]
    
    ; Load collision properties from table
    ld h, HIGH(collisionArray)
    ld l, a
    ld a, [hl]
    
    ; Set waterContactFlag if tile is water
    bit blockType_water, a
    jr z, .endIf_A
        ld a, $ff
        ld [waterContactFlag], a
        ld a, [hl]
    .endIf_A:

    ; Invert the solidity if tile is an up-block
    bit blockType_up, a
    jr z, .endIf_B
        ccf ; Invert the solidity
    .endIf_B:

    ; Check if tile is acid
    ld a, [hl]
    bit blockType_acid, a
    jr z, .endIf_C
        ; Set acidContactFlag
        ld a, $40 ; This is supposed to be a jump table index (behavior is unused)
        ld [acidContactFlag], a
        ; Damage Samus
        push af
        ld a, [acidDamageValue]
        call applyDamage.acid
        pop af
    .endIf_C:
    
    ; Exit if the carry flag is set (i.e. if the tile is solid)
    jr c, .exit

; Top right side
    ; Get x offset for right side
    ldh a, [hSamusXPixel]
    add $14
    ld [tileX], a
    ; Perform collision check
    call samus_getTileIndex
    
    ; Perform compare operation to set the carry flag if applicable
    ld hl, samusSolidityIndex
    cp [hl]
    
    ; Load collision properties from table
    ld h, HIGH(collisionArray)
    ld l, a
    ld a, [hl]
    
    ; Set waterContactFlag if tile is water
    bit blockType_water, a
    jr z, .endIf_D
        ld a, $ff
        ld [waterContactFlag], a
        ld a, [hl]
    .endIf_D:
    
    ; Invert the solidity if tile is an up-block
    bit blockType_up, a
    jr z, .endIf_E
        ccf ; Invert the solidity
    .endIf_E:

    ; Check if tile is acid
    ld a, [hl]
    bit blockType_acid, a
    jr z, .endIf_F
        ; Set acidContactFlag
        ld a, $40 ; This is supposed to be a jump table index (behavior is unused)
        ld [acidContactFlag], a
        ; Damage Samus
        push af
        ld a, [acidDamageValue]
        call applyDamage.acid
        pop af
    .endIf_F:

.exit:
    pop bc
    pop de
    pop hl
ret ;}

; Samus downwards BG collision detection
collision_samusBottom: ;{ 00:1F0F
    push hl
    push de
    push bc
    ; Check sprite collision
    call collision_samusEnemiesDown
    jr nc, .endIf_A
        ; Set flag for a sprite being touched
        ld a, $01
        ld [samus_onSolidSprite], a
        ; Save pointer to enemy
        ld a, l
        ld [collision_pEnemyLow], a
        ld a, h
        ld [collision_pEnemyHigh], a
        ; Save weapon type as "touch"
        ld a, $20
        ld [collision_weaponType], a
        ; Exit
        jp .exit
    .endIf_A:

; Bottom left side
    ; Set x offset for left side
    ldh a, [hSamusXPixel]
    add $0c
    ld [tileX], a
    ; Set y offset for bottom
    ldh a, [hSamusYPixel]
    add $2c
    ld [tileY], a
    
    ; Perform collision check 
    call samus_getTileIndex
    
    ; Perform compare operation to set the carry flag if applicable
    ld hl, samusSolidityIndex
    cp [hl]
    
    ; Load collision properties from table
    ld h, HIGH(collisionArray)
    ld l, a
    ld a, [hl]

    ; Set waterContactFlag if tile is water
    bit blockType_water, a
    jr z, .endIf_B
        ld a, $31 ; Set to $FF in every other circumstance (why?)
        ld [waterContactFlag], a
    .endIf_B:

    ; Set saveContactFlag if tile is a save point
    ld a, [hl]
    bit blockType_save, a
    jr z, .endIf_C
        ld a, $ff
        ld [saveContactFlag], a
    .endIf_C:

    ; Check if tile is a fall-through tile
    ld a, [hl]
    bit blockType_down, a
    jr z, .endIf_D
        ld a, [samusPose] ; Pointless operation
        ; Clear carry flag
        scf
        ccf
    .endIf_D:

    ; Check if tile is acid
    ld a, [hl]
    bit blockType_acid, a
    jr z, .endIf_E
        ; Set acidContactFlag
        ld a, $40 ; This is supposed to be a jump table index (behavior is unused)
        ld [acidContactFlag], a
        ; Damage Samus
        push af
        ld a, [acidDamageValue]
        call applyDamage.acid
        pop af
    .endIf_E:

    ; Exit if the carry flag is set (i.e. if the tile is solid)
    jr c, .exit

; Bottom right side
    ; Set x offset for right side
    ldh a, [hSamusXPixel]
    add $14
    ld [tileX], a
    
    ; Perform collision check 
    call samus_getTileIndex
    
    ; Perform compare operation to set the carry flag if applicable
    ld hl, samusSolidityIndex
    cp [hl]
    
    ; Load collision properties from table
    ld h, HIGH(collisionArray)
    ld l, a
    ld a, [hl]
    
    ; Set waterContactFlag if tile is water
    bit blockType_water, a
    jr z, .endIf_F
        ld a, $ff
        ld [waterContactFlag], a
    .endIf_F:

    ; Set saveContactFlag if tile is a save point
    ld a, [hl]
    bit blockType_save, a
    jr z, .endIf_G
        ld a, $ff
        ld [saveContactFlag], a
    .endIf_G:

    ; Check if tile is a fall-through tile
    ld a, [hl]
    bit blockType_down, a
    jr z, .endIf_H
        ; Clear carry flag (ignore collision)
        scf
        ccf
    .endIf_H:
    
    ; Check if tile is acid
    ld a, [hl]
    bit blockType_acid, a
    jr z, .endIf_I
        ; Set acidContactFlag
        ld a, $40 ; This is supposed to be a jump table index (behavior is unused)
        ld [acidContactFlag], a
        ; Damage Samus
        push af
        ld a, [acidDamageValue]
        call applyDamage.acid
        pop af
    .endIf_I:

    ; Clear unmorph jump timer if Samus touched a solid tile
    jr nc, .endIf_J
        ld a, $00
        ld [samus_unmorphJumpTimer], a
    .endIf_J:

.exit:
    pop bc
    pop de
    pop hl
ret ;}

; Used by main Spider Ball collision function
collision_checkSpiderPoint: ;{ 00:1FBF
    ; Perform collision check on tile specied by the caller
    call samus_getTileIndex
    
    ; Go to noHit branch if not solid
    ld hl, samusSolidityIndex
    cp [hl]
        jr nc, .noHit

; Collision occurred
    ; Load collision properties from table
    ld h, HIGH(collisionArray)
    ld l, a
    ld a, [hl]
    
    ; Check if tile is acid
    bit blockType_acid, a
    jr z, .endIf
        ; Set acidContactFlag
        ld a, $40 ; This is supposed to be a jump table index (behavior is unused)
        ld [acidContactFlag], a
        ld a, [acidDamageValue]
        ; Damage Samus
        call applyDamage.acid
    .endIf:
;exitWithHit
    ; Set carry flag (to indicate a collision occurred)
    scf
ret

.exitNoHit:
    ; Clear carry flag (to indicate no collision occurred)
    scf
    ccf
ret

.noHit:
    ; Load collision properties from table
    ld h, HIGH(collisionArray)
    ld l, a
    ld a, [hl]
    
    ; Check if tile is acid
    bit blockType_acid, a
    jr z, .exitNoHit
        ld a, $40 ; This is supposed to be a jump table index (behavior is unused)
        ld [acidContactFlag], a
        ld a, [acidDamageValue]
        ; Damage Samus
        call applyDamage.acid
    jr .exitNoHit
;}
;} end of Samus BG collision functions

samus_getTileIndex: ;{ 00:1FF5
    ; Get tilemap address based on coordinates provided by the caller
    call getTilemapAddress

    ; Adjust base address for collision depending on the tilemap being used
    ld a, [gameOver_LCDC_copy]
    and $08
    jr z, .endIf_A
        ld a, $04
        add h
        ld h, a
        ld [pTilemapDestHigh], a
    .endIf_A

    ; Wait for HBlank and read once
    .waitLoop_A:
        ldh a, [rSTAT]
        and $03
    jr nz, .waitLoop_A
    ld b, [hl]

    ; Wait for HBlank and read again
    .waitLoop_B: ; Wait for h-blank
        ldh a, [rSTAT]
        and $03
    jr nz, .waitLoop_B
    ld a, [hl]
    
    ; Combine results of the two read attempts
    and b
    ld b, a

; Check for spike collision (presumably done here because spikes pertain to every moment direction and state)
    ; Check if Samus is invulnerable
    ld a, [samusInvulnerableTimer]
    and a
    jr nz, .endIf_B
        ; Load collision properties from table
        ld h, HIGH(collisionArray)
        ld a, b
        ld l, a
        ld a, [hl]
        
        ; Check if tile is a spike
        bit blockType_spike, a
        jr z, .endIf_B
            ; Play sfx
            ld a, $04
            ld [sfxRequest_square1], a
            ; Samus damaged flag
            ld a, $01
            ld [samus_hurtFlag], a
            ; Damage boost up
            xor a
            ld [samus_damageBoostDirection], a
            ; Samus damage
            ld a, [spikeDamageValue]
            ld [samus_damageValue], a
    .endIf_B:
    ; Reload tile index back to A
    ld a, b
ret
;}

metroidLCounterTable: ;{ 0:203B - Metroids remaining (L counter) - Value is BCD
    db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00
    db $01, $02, $03, $01, $01, $01, $02, $03, $04, $05, $00, $00, $00, $00, $00, $00
    db $06, $07, $01, $02, $01, $01, $02, $03, $04, $05, $00, $00, $00, $00, $00, $00
    db $06, $07, $08, $09, $10, $01, $02, $03, $04, $05, $00, $00, $00, $00, $00, $00
    db $06, $07, $08, $01, $02, $03, $04, $01
;}

; Magic number for save
saveFile_magicNumber: ; 00:2083
    db $01, $23, $45, $67, $89, $ab, $cd, $ef

; Damage pose transition table 
samus_damagePoseTransitionTable: ;{ 00:208B
    ; Table Generated from samus/samus.csv
    include "samus/samus_damagePoseTransitionTable.asm"
;}

; 00:20A9 - Spider Ball Direction Tables {
; Values
; - 0: Nothing
; - 1: Move Right
; - 2: Move Left
; - 4: Move Up
; - 8: Move Down
;
;               _____________________________________________________________ 0: In air
;              |    _________________________________________________________ 1: Outside corner: Of left-facing wall and ceiling
;              |   |    _____________________________________________________ 2: Outside corner: Of left-facing wall and floor
;              |   |   |    _________________________________________________ 3: Flat surface:   Left-facing wall
;              |   |   |   |    _____________________________________________ 4: Outside corner: Of right-facing wall and ceiling
;              |   |   |   |   |    _________________________________________ 5: Flat surface:   Ceiling
;              |   |   |   |   |   |    _____________________________________ 6: Unused:         Top-left and bottom-right corners of ball in contact
;              |   |   |   |   |   |   |    _________________________________ 7: Inside corner:  Of left-facing wall and ceiling
;              |   |   |   |   |   |   |   |    _____________________________ 8: Outside corner: Of right-facing wall and floor
;              |   |   |   |   |   |   |   |   |    _________________________ 9: Unused:         Bottom-left and top-right corners of ball in contact
;              |   |   |   |   |   |   |   |   |   |    _____________________ A: Flat surface:   Floor
;              |   |   |   |   |   |   |   |   |   |   |    _________________ B: Inside corner:  Of left-facing wall and floor
;              |   |   |   |   |   |   |   |   |   |   |   |    _____________ C: Flat surface:   Right-facing wall
;              |   |   |   |   |   |   |   |   |   |   |   |   |    _________ D: Inside corner:  Of right-facing wall and ceiling
;              |   |   |   |   |   |   |   |   |   |   |   |   |   |    _____ E: Inside corner:  Of right-facing wall and floor
;              |   |   |   |   |   |   |   |   |   |   |   |   |   |   |    _ F: Unused:         Embedded in solid
;              |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
spiderDirectionTable:
 .ccw_try1: db 0, $4, $1, $4, $2, $2,  0, $2, $8,  0, $1, $4, $8, $8, $1,  0
 .ccw_try2: db 0, $2, $4, $2, $8, $8,  0, $8, $1,  0, $4, $2, $1, $1, $4,  0
 .cw_try1:  db 0, $1, $8, $8, $4, $1,  0, $8, $2,  0, $2, $2, $4, $1, $4,  0
 .cw_try2:  db 0, $8, $2, $2, $1, $8,  0, $2, $4,  0, $4, $4, $1, $8, $1,  0

; How this works:
; - For a given direction (ccw or cw), the spider ball checks its collision state.
; - It then tries going in the direction given corresponding to the collision state from "try1"
; - If the spider ball successfully moved, then it's done.
; - If the spider ball could not move in the direction given in try1, it tries going in the direction given by try2.
;}

collision_samusBGHitboxTopTable: ;{ 00:20E9 - Vertical offset for the top of Samus's hitbox, per pose, for BG collisions
    ; Table Generated from samus/samus.csv
    include "samus/samus_bgHitboxTop.asm"
;}

collision_samusHorizontalYOffsetLists: ;{ 00:20FF - Y-Offset collision lists per pose ($80 terminated)
; Note: Due to limitations of the function that read this
;  despite each row being 8 bytes long, only 5 offsets are supported
    ; Table Generated from samus/samus.csv
    include "samus/samus_horizontalYOffsets.asm"
;}

; Clear Projectile RAM
clearProjectileArray: ;{ 00:21EF
    ; Fill array with $FF
    ld h, HIGH(projectileArray)
    ld l, LOW(projectileArray)
    .loop:
        ld a, $ff
        ld [hl+], a
        ; Continue until we reach address $xx00
        ld a, l
        and a
    jr nz, .loop
ret
;}

; Procedure has two entry points
samus_tryShooting: ;{ 00:21FB
    ; Don't allow toggling missiles if facing the screen
    ld a, [samusPose]
    cp pose_faceScreen
        jp z, samusShoot_longJump
    ; Don't allow toggling missiles if the queen is dying
    ld a, [queen_eatingState]
    cp $22
        jp z, samusShoot_longJump
    ; Toggle missiles if select is pressed
    ldh a, [hInputRisingEdge]
    bit PADB_SELECT, a
        jp z, samusShoot_longJump
; Switch between missiles and beams
.toggleMissiles: ; 00:2212
    ; Check if missiles are active
    ld a, [samusActiveWeapon]
    cp $08
    jr nz, .else
        ; Switch to beam
        ld a, [samusBeam]
        ld [samusActiveWeapon], a
        ld hl, gfxInfo_cannonBeam
        call loadGraphics
        ; Play sound effect
        ld a, $15
        ld [sfxRequest_square1], a
        ret
    .else:
        ; Save current beam (unnecessary code?)
        ld a, [samusActiveWeapon]
        ld [samusBeam], a
        ; Switch to missiles
        ld a, $08
        ld [samusActiveWeapon], a
        ld hl, gfxInfo_cannonMissile
        call loadGraphics
        ; Play sound effect
        ld a, $15
        ld [sfxRequest_square1], a
        ret
;}

; 00:2242
gfxInfo_cannonMissile: db BANK(gfx_cannonMissile)
    dw gfx_cannonMissile, vramDest_cannon, $0020
; 00:2249
gfxInfo_cannonBeam: db BANK(gfx_cannonBeam) 
    dw gfx_cannonBeam, vramDest_cannon, $0020

; Function returns the tile number for a particular x-y tile on the tilemap
;  Function has two entry points
getTileIndex: ;{ 00:2250 - Called by enemy routines
    .enemy:
    ; Adjust enemy coordinates (in camera-space) to map-space coordinates
    ; tileY = scrollY + enemyY
    ld a, [scrollY]
    ld b, a
    ld a, [enemy_testPointYPos]
    add b
    ld [tileY], a
    ; tileX = scrollX + enemyX
    ld a, [scrollX]
    ld b, a
    ld a, [enemy_testPointXPos]
    add b
    ld [tileX], a
.projectile: ; 00:2266 - Entry point for beam routines
    ; Get address of tile
    call getTilemapAddress
    ; Adjust address based on which tilemap is active (unused functionality?)
    ld a, [gameOver_LCDC_copy]
    and $08
    jr z, .endIf
        ld a, $04
        add h
        ld h, a
        ld [pTilemapDestHigh], a
    .endIf

    ; Wait for HBlank and read once
    .waitLoop_A:
        ldh a, [rSTAT]
        and $03
    jr nz, .waitLoop_A
    ld b, [hl]

    ; Wait for HBlank and try reading again
    .waitLoop_B:
        ldh a, [rSTAT]
        and $03
    jr nz, .waitLoop_B
    ld a, [hl]

    ; Combine results of the two read attempts
    and b
ret ;}

main_readInput: ;{ 00:2287
    ; Select d-pad to read
    ld a, $20
    ldh [rP1], a
    ; Read d-pad
    ldh a, [rP1]
    ldh a, [rP1]
    ; Invert, swap to other nybble, store in B
    cpl
    and $0f
    swap a
    ld b, a
    
    ; Select buttons to read
    ld a, $10
    ldh [rP1], a
    ; Read buttons
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ; Invert, mask out upper bits, and OR with B
    cpl
    and $0f
    or b
    ; Store in C as temp
    ld c, a

    ; rising edge = (prev XOR current) AND current
    ldh a, [hInputPressed]
    xor c
    and c
    ldh [hInputRisingEdge], a
    ; Save current input
    ld a, c
    ldh [hInputPressed], a
    ; Deselect reading both input types
    ld a, $30
    ldh [rP1], a
ret ;}

; Given pixels coordinates in y:[tileY], x:[tileX]
;  returns the tilemap address in [pTilemapDestLow] and [pTilemapDestHigh]
getTilemapAddress: ;{ 00:22BC
    ; HL = $9800 + (tileY-$10)/8*$20
    ld a, [tileY]
    sub $10
    ld b, $08
    ld de, $0020
    ld hl, $9800 - $20 ;$97E0
    .loop:
        add hl, de ; Add one row of bytes to the pointer per loop
        sub b ; Subtract one row of pixels from A per loop
    jr nc, .loop
    ; HL += (tileX-8)/8
    ld a, [tileX]
    sub b
    srl a
    srl a
    srl a
    add l
    ; Save HL to pTilemapDest
    ld l, a
    ld [pTilemapDestLow], a
    ld a, h
    ld [pTilemapDestHigh], a
ret ;}

; Given a particular tilemap address, possibly returns the XY pixel coordinates of the tile
;  Function is unused
getTilemapCoordinates: ;{ 00:22E1
    ; DE = pTilemapDest
    ld a, [pTilemapDestHigh]
    ld d, a
    ld a, [pTilemapDestLow]
    ld e, a
    ; Can't entirely make sense of this math that calculates tileY
    ; essentially DE/16 (D is discarded so the rotated-in bits don't matter)
    ld b, $04
    .loop:
        rr d
        rr e
        dec b
    jr nz, .loop
    ld a, e
    ; The $8x part seems to adjust for the $9800 base address
    ; The $x4 seems to adjust for 2 rows of tiles
    sub $84
    ; Mask out lowest bit
    and $fe
    ; A*4 + 8
    rlca
    rlca
    add $08
    ld [tileY], a
    ; X = (low mod 32)*8 + 
    ld a, [pTilemapDestLow]
    and $1f
    rla
    rla
    rla
    add $08
    ld [tileX], a
ret ;}

; Unused function - no idea what this could have been used for
;  Seems to assume HL, DE, and C227 were set before entry
unknownProc_230C: ;{ 00:230C
    ; Exit if zero
    ld a, [unknown_C227]
    and a
        ret z
    
    ; Set loop counter
    ld c, $03
    ; Clear value
    xor a
    ld [unknown_C227], a
    .loop:
        ; Branch if upper nybble is nonzero
        ld a, [de]
        ld b, a
        swap a
        and $0f
            jr nz, .branch_A
    
        ; Load 0 to HL if unknown var is non-zero
        ld a, [unknown_C227]
        and a
        ld a, $00
        jr nz, .endIf_A
            ; Else load $FF to HL
            ld a, $ff
        .endIf_A:
    .reentry_A:
        ld [hl+], a
        
        ; Branch is lower nybble is nonzero
        ld a, b
        and $0f
            jr nz, .branch_B
    
        ; Load 0 to HL if var is non-zero
        ld a, [unknown_C227]
        and a
        ld a, $00
        jr nz, .endIf_B
            ; Write FF to HL if this is the last loop iteration
            ld a, $01
            cp c
            ld a, $00
            jr z, .endIf_B
                ld a, $ff
        .endIf_B:
    .reentry_B:
        ld [hl+], a
        ; Get address of next source byte
        dec e
        ; Decrement loop counter
        dec c
    jr nz, .loop
    ; Clear variable
    xor a
    ld [unknown_C227], a
ret

.branch_A:
    push af
    ; Set variable to 1
    ld a, $01
    ld [unknown_C227], a
    pop af
jr .reentry_A

.branch_B:
    push af
    ; Set variable to 1
    ld a, $01
    ld [unknown_C227], a
    pop af
jr .reentry_B
;}

;------------------------------------------------------------------------------
oamDMA_routine: ;{ 00:235C Copied to $FFA0 in HRAM
    ld a, HIGH(wram_oamBuffer)
    ldh [rDMA], a
    ld a, $28
    .loop:
        dec a
    jr nz, .loop
ret ;}

; Converts camera values to hardware scroll values
convertCameraToScroll: ;{ 00:2366
    ; Camera values are in the center of the screen
    ldh a, [hCameraYPixel]
    sub $48
    ld [scrollY], a
    ldh a, [hCameraXPixel]
    sub $50
    ld [scrollX], a
    ; Handle earthquake
    call earthquake_adjustScroll_longJump
ret ;}

;------------------------------------------------------------------------------
; Audio calls
initializeAudio_longJump: ; 00:2378
    callFar externalInitializeAudio
ret

handleAudio_longJump: ;00:2384
    callFar externalHandleAudio
ret

silenceAudio_longJump: ; 00:2390
    callFar externalSilenceAudio
ret

;------------------------------------------------------------------------------
; Screen Transition decoder
executeDoorScript: ;{ 00:239C
    ; Check if a door script is queued up
    ld a, [doorIndexLow]
    ld b, a
    ld a, [doorIndexHigh]
    or b
        jp z, .endDoorScript

    ; Clear non-Samus/HUD OAM entries
    ld a, [samusTopOamOffset]
    ldh [hOamBufferIndex], a
    call clearUnusedOamSlots_longJump ; Clear unused OAM
    call waitOneFrame
    call OAM_DMA
	
; From the door index, get the pointer and load the script
    switchBank doorPointerTable
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
    
    ; Read tokens starting from the beginning of the script
    ld hl, doorScriptBuffer

.readOneToken: ;{ Main loop for door script interpreter
    ; Read token (note this does not use [HL+])
    ld a, [hl]
    cp $ff ; END_DOOR {
    jp nz, .doorToken_load
        ; Technically unnecessary (since the script is finished)
        ;  but good practice because each token's code is expected
        ;  to increment HL to the next token
        inc hl 
    jp .endDoorScript ;}

    .doorToken_load:
    ; Each token type from this point on is defined by the upper nybble
    and $f0
    cp $b0 ; LOAD_BG/LOAD_SPR {
    jr nz, .doorToken_copy
        ; Clear save flags (to suppress save message)
        xor a
        ld [saveMessageCooldownTimer], a
        ld [saveContactFlag], a
        ; Set window to lower position
        ld a, $88
        ldh [rWY], a
        ; Load graphics (reads lower nybble of token and three more bytes)
        call door_loadGraphics
    jp .nextToken ;}
        
    .doorToken_copy:
    cp $00 ; COPY_DATA/COPY_BG/COPY_SPR {
    jr nz, .doorToken_tiletable
        ; Clear save flags (to suppress save message)
        xor a
        ld [saveMessageCooldownTimer], a
        ld [saveContactFlag], a
        ; Set window to lower position
        ld a, $88
        ldh [rWY], a
        ; Load graphics (reads lower nybble of token and seven more bytes)
        call door_copyData
    jp .nextToken ;}

    .doorToken_tiletable:
    cp $10 ; TILETABLE {
    jr nz, .doorToken_collision
        ; Load metatile table (uses lower nybble of token)
        call door_loadTiletable
    jp .nextToken ;}

    .doorToken_collision:
    cp $20 ; COLLISION {
    jr nz, .doorToken_solidity
        ; Load collision table (uses lower nybble of token)
        call door_loadCollision
    jp .nextToken ;}

    .doorToken_solidity:
    cp $30 ; SOLIDITY {
    jr nz, .doorToken_warp
        ; Re-read token (why?)
        ld a, [hl+]
        push hl
            ; Extract table index from token
            and $0f
            ; Get base address in solidity table
            ; HL = table + index*4
            ld e, a
            ld d, $00
            sla e
            sla e
            switchBank solidityIndexTable
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
            ; Note the solidity table has an unused 4th column
        pop hl
    jp .nextToken ;}

    .doorToken_warp:
    cp $40 ; WARP {
    jr nz, .doorToken_escapeQueen
        call door_warp
        ; Set exit status to indicate that enemy spawn flags should be refreshed
        ;  (although loadDoorIndex does that already so this might be unnecessary)
        ld a, $01
        ld [doorExitStatus], a
        ; Deactivate queen fight ($11 means active)
        ld a, [queen_roomFlag]
        and $0f
        ld [queen_roomFlag], a
    jp .nextToken ;}

    .doorToken_escapeQueen:
    cp $50 ; ESCAPE QUEEN {
    jr nz, .doorToken_damage
        ; Increment HL to next token
        ; This token takes no arguments
        inc hl
        ; Disable VBlank
        ldh a, [rIE]
        res 1, a
        ldh [rIE], a
        ; Set Samus and camera to a particular YX position
        ld a, $d7
        ldh [hSamusYPixel], a
        ld a, $78
        ldh [hSamusXPixel], a
        ld a, $c0
        ldh [hCameraYPixel], a
        ld a, $80
        ldh [hCameraXPixel], a
        ; Redraw the HUD tilemap
        ; Source
        ld a, LOW(hudBaseTilemap) ; bank 5
        ldh [hVramTransfer.srcAddrLow], a
        ld a, HIGH(hudBaseTilemap)
        ldh [hVramTransfer.srcAddrHigh], a
        ; Dest
        ld a, LOW(vramDest_statusBar)
        ldh [hVramTransfer.destAddrLow], a
        ld a, HIGH(vramDest_statusBar)
        ldh [hVramTransfer.destAddrHigh], a
        ; Length
        ld a, $14
        ldh [hVramTransfer.sizeLow], a
        ld a, $00
        ldh [hVramTransfer.sizeHigh], a
        ; Source bank
        ld a, BANK(hudBaseTilemap)
        ld [vramTransfer_srcBank], a
        ; Transfer graphics
        call beginGraphicsTransfer
        ; Set the loadSpawnFlagsRequest flag (why does zero == true for this variable?)
        xor a
        ld [loadSpawnFlagsRequest], a
    jp .nextToken ;}

    .doorToken_damage:
    cp $60 ; DAMAGE {
    jr nz, .doorToken_exitQueen
        ; Increment HL to arguments
        inc hl
        ; Set acid damage
        ld a, [hl+]
        ld [acidDamageValue], a
        ld [saveBuf_acidDamageValue], a
        ; Set spike damage
        ld a, [hl+]
        ld [spikeDamageValue], a
        ld [saveBuf_spikeDamageValue], a
    jp .nextToken ;}

    .doorToken_exitQueen:
    cp $70 ; EXIT_QUEEN {
    jr nz, .doorToken_enterQueen
        ; Increment HL to next token
        ; This token takes no arguments
        inc hl
        push hl
            ; Clear Queen room flag
            xor a
            ld [queen_roomFlag], a
            ; Set window position to default (one row, left side)
            ld a, $88
            ldh [rWY], a
            ld a, $07
            ldh [rWX], a
            ; Disable VBlank
            ldh a, [rIE]
            res 1, a
            ldh [rIE], a
            ; Redraw the HUD tilemap
            ; Source address
            ld a, LOW(hudBaseTilemap)
            ldh [hVramTransfer.srcAddrLow], a
            ld a, HIGH(hudBaseTilemap)
            ldh [hVramTransfer.srcAddrHigh], a
            ; Destination address
            ld a, LOW(vramDest_statusBar)
            ldh [hVramTransfer.destAddrLow], a
            ld a, HIGH(vramDest_statusBar)
            ldh [hVramTransfer.destAddrHigh], a
            ; Size
            ld a, $14
            ldh [hVramTransfer.sizeLow], a
            ld a, $00
            ldh [hVramTransfer.sizeHigh], a
            ; Source bank
            ld a, BANK(hudBaseTilemap) ; bank $05
            ld [vramTransfer_srcBank], a
            ; Transfer graphics
            call beginGraphicsTransfer
        pop hl
    jp .nextToken ;}

    .doorToken_enterQueen:
    cp $80 ; ENTER_QUEEN {
    jr nz, .doorToken_compare
        ; Clear variables
        xor a
        ld [samus_onscreenYPos], a
        ld [samus_onscreenXPos], a
        ldh [hOamBufferIndex], a
        ld [sound_playQueenRoar], a
        ; Set song
        ld a, song_metroidQueenBattle ; $02
        ld [songRequest], a
        ; Clear sprites
        push hl
            call clearAllOam_longJump
        pop hl
        call waitOneFrame
        ; Update OAM
        call OAM_DMA
        ; Prep queen fight (reads lower nybble of token and 8 more bytes)
        call door_queen
        ; Set exit status to indicate that enemy spawn flags should be refreshed
        ;  (although loadDoorIndex does that already so this might be unnecessary)
        ld a, $01
        ld [doorExitStatus], a
        ; Activate queen fight
        ld a, $11
        ld [queen_roomFlag], a
        ; Enable VBlank
        ldh a, [rIE]
        set 1, a
        ldh [rIE], a
    jp .nextToken ;}

    .doorToken_compare:
    cp $90 ; IF_MET_LESS - comparison operator {
    jr nz, .doorToken_fadeout
        ; Incrment HL to argument
        inc hl
        ; Compare metroid count to operand
        ld a, [metroidCountReal]
        ld b, a
        ld a, [hl+]
        ; if (metroids <= arg) then load new script
        cp b
        jr nc, .loadNewScript
            ; Skip door ID and load next token
            inc hl
            inc hl
            jp .nextToken
        .loadNewScript:
            ; Load door index
            ld a, [hl+]
            ld [doorIndexLow], a
            ld a, [hl]
            ld [doorIndexHigh], a
            ; Execute it
            jp executeDoorScript
    ;}

    .doorToken_fadeout:
    cp $a0 ; FADEOUT {
    jr nz, .doorToken_song
        ; Incrment HL for next token (this token takes no arguments)
        inc hl
        push hl
        ; Wait a few frames
        call waitOneFrame
        call waitOneFrame
        call waitOneFrame
        call waitOneFrame
        ; Set countdown timer
        ld a, $2f
        ld [countdownTimerLow], a    
        .fadeLoop:
            ld hl, .fadePaletteTable
            ; Use upper nybble of timer to index into .fadePaletteTable
            ld a, [countdownTimerLow]
            and $f0
            swap a
            ld e, a
            ld d, $00
            add hl, de
            ; Load palette
            ld a, [hl]
            ld [bg_palette], a
            ld [ob_palette0], a
            ; Wait a frame
            call waitOneFrame
            ; Exit loop once we've decremented past $0E
            ld a, [countdownTimerLow]
            cp $0e
        jr nc, .fadeLoop
    
        pop hl
        ; Clear timer
        xor a
        ld [countdownTimerLow], a
    jp .nextToken ;}
    
    .fadePaletteTable: db $ff, $fb, $e7 ; 00:259B

    .doorToken_song:
    cp $c0 ; SONG {
    jr nz, .doorToken_item
        ; Very convoluted logic. Unsure if semantics are 100% accurate
        ; Check if earthquake noise is playing
        ld a, [songInterruptionPlaying]
        cp song_earthquake ;$0E
        jr z, .song_else_A
            ; If the earthquake noise is not playing {
            ; Read lower nybble of token
            ld a, [hl+]
            and $0f
            ; Check if argument is $A
            cp $0a
            jr z, .song_else_B    
                ; Argument was not $A, so just request the song properly
                ld [songRequest], a
                ld [currentRoomSong], a
                ; Check if the argument was $B
                cp $0b
                jr nz, .song_else_C
                    ; If so, play the Queen's distant roar
                    ld a, $ff
                    ld [sound_playQueenRoar], a
                    ; Clear variable
                    xor a
                    ld [songRequest_afterEarthquake], a
                    jp .nextToken
                .song_else_C:
                    ; Clear variable
                    xor a
                    ld [songRequest_afterEarthquake], a
                    ; Silence the Queen's distant roar
                    ld [sound_playQueenRoar], a
                    jp .nextToken
            .song_else_B:
                ; Special case if argument is $A
                ; Disable sound channels (uncertain)
                ld a, $ff
                ld [songRequest], a
                ld [currentRoomSong], a
                ; Play silence after earthquake?
                xor a
                ld [songRequest_afterEarthquake], a
                ; Play Queen's roar
                ld a, $ff
                ld [sound_playQueenRoar], a
                jp .nextToken
            ;}
        .song_else_A:
            ; If the earthquake noise is playing {
            ; then read lower nybble of token
            ld a, [hl+]
            and $0f
            ; Check if argument is $A
            cp $0a
            jr z, .song_else_D
                ; Argument was not $A, so just request the song properly
                ;  for after the earthquake
                ld [songRequest_afterEarthquake], a
                ; Check if the argument was $B
                cp $0b
                jr nz, .song_else_E
                    ; If it was $B, play the Queen's distant roar
                    ld a, $ff
                    ld [sound_playQueenRoar], a
                    jp .nextToken
                .song_else_E:
                    ; If it was not $B, silence the Queen's roar
                    xor a
                    ld [sound_playQueenRoar], a
                    jp .nextToken
            .song_else_D:
                ; If argument is $A
                ; Disable sound channels after earthquake
                ld a, $ff
                ld [songRequest_afterEarthquake], a
                ; Play Queen's distant roar
                ld [sound_playQueenRoar], a
                jp .nextToken
            ;}
    ;}
    
    .unreferencedTable: db $04, $05, $06, $07, $08, $09, $10, $12 ; 00:260C

    .doorToken_item:
    cp $d0 ; ITEM {
    jp nz, .nextToken
        ; Load item graphics
        ; Set source bank
        ld a, BANK(gfx_items)
        ld [bankRegMirror], a
        ld [vramTransfer_srcBank], a
        ld [rMBC_BANK_REG], a
        ; Load lower nybble of token (minus 1)
        ld a, [hl] ; Note: this is not [HL+]
        push hl
            dec a
            and $0f
            ; Multiply by $40 to get offset for sprite graphics
            swap a
            ld e, a
            ld d, $00
            sla e
            rl d
            sla e
            rl d
            ld hl, gfx_items
            add hl, de
            ; Set source address for item sprite graphics
            ld a, l
            ldh [hVramTransfer.srcAddrLow], a
            ld a, h
            ldh [hVramTransfer.srcAddrHigh], a
            
            ; Set destination address
            ld a, LOW(vramDest_item)
            ldh [hVramTransfer.destAddrLow], a
            ld a, HIGH(vramDest_item)    
            ldh [hVramTransfer.destAddrHigh], a
            
            ; Set transfer size (4 tiles)
            ld a, $40
            ldh [hVramTransfer.sizeLow], a
            ld a, $00
            ldh [hVramTransfer.sizeHigh], a
            ; Transfer graphics
            call beginGraphicsTransfer
            
        ; Load item orb {
            ; Set source address
            ld a, LOW(gfx_itemOrb)
            ldh [hVramTransfer.srcAddrLow], a
            ld a, HIGH(gfx_itemOrb)
            ldh [hVramTransfer.srcAddrHigh], a
            ; Set destination address
            ld a, $00
            ldh [hVramTransfer.destAddrLow], a
            ld a, $8b
            ldh [hVramTransfer.destAddrHigh], a
            ; Set transfer length (4 tiles)
            ld a, $40
            ldh [hVramTransfer.sizeLow], a
            ld a, $00
            ldh [hVramTransfer.sizeHigh], a
            ; Transfer graphics
            call beginGraphicsTransfer
        ;}
            
        ; Load item font text {
            ; Set source bank
            ld a, BANK(gfx_itemFont)
            ld [bankRegMirror], a
            ld [vramTransfer_srcBank], a
            ld [rMBC_BANK_REG], a
            ; Set source address
            ld a, LOW(gfx_itemFont) ;$34
            ldh [hVramTransfer.srcAddrLow], a
            ld a, HIGH(gfx_itemFont) ;$6c
            ldh [hVramTransfer.srcAddrHigh], a
            ; Set destination address
            ld a, LOW(vramDest_itemFont)
            ldh [hVramTransfer.destAddrLow], a
            ld a, HIGH(vramDest_itemFont)
            ldh [hVramTransfer.destAddrHigh], a
            ; Set transfer length ($23 tiles)
            ld a, $30
            ldh [hVramTransfer.sizeLow], a
            ld a, $02
            ldh [hVramTransfer.sizeHigh], a
            ; Transfer graphics
            call beginGraphicsTransfer
        ;}
        pop hl
        
        ; Load item text {
        ; Set source bank
        ld a, BANK(itemTextPointerTable)
        ld [bankRegMirror], a
        ld [vramTransfer_srcBank], a
        ld [rMBC_BANK_REG], a
        ; Read lower nybble of token
        ld a, [hl+]
        push hl
            and $0f
            ; Index into text pointer table
            ld e, a
            ld d, $00
            sla e
            rl d
            ld hl, itemTextPointerTable
            add hl, de
            ; Load pointer to HL
            ld a, [hl+]
            ld e, a
            ld a, [hl]
            ld h, a
            ld a, e
            ld l, a
            ; Set source address of text
            ld a, l
            ldh [hVramTransfer.srcAddrLow], a
            ld a, h
            ldh [hVramTransfer.srcAddrHigh], a
            ; Set destination address of text
            ld a, LOW(vramDest_itemText)
            ldh [hVramTransfer.destAddrLow], a
            ld a, HIGH(vramDest_itemText)
            ldh [hVramTransfer.destAddrHigh], a
            ; Set length of string (16 letters)
            ld a, $10
            ldh [hVramTransfer.sizeLow], a
            ld a, $00
            ldh [hVramTransfer.sizeHigh], a
            ; Transfer graphics
            call beginGraphicsTransfer
        pop hl ;}
    jr .nextToken ;}

.nextToken:
    ; Wait a frame before reading another token
    call waitOneFrame
    jp .readOneToken ;}

.endDoorScript:
    ; Refresh the enemy spawn flags
    ld a, [doorExitStatus]
    ld [saveLoadSpawnFlagsRequest], a
    
    ; Clear variables
    xor a
    ld [doorIndexLow], a
    ld [doorIndexHigh], a
    ld [doorExitStatus], a
    ; Otherwise unused variable
    ld [wramUnknown_D0A8], a
ret ;}

; Door script load graphics routine
door_loadGraphics: ;{ 00:26EB
    ; Read lower nybble of token to determine if loading enemy or BG graphics
    ld a, [hl+]
    and $0f
    ld b, a
    cp $01
    jr z, .else
        ; Load enemy graphics source bank
        ld a, [hl+]
        ld [bankRegMirror], a
        ld [vramTransfer_srcBank], a
        ld [rMBC_BANK_REG], a
        ; Load source address (and save result to save buffer as enemy graphics)
        ld a, [hl+]
        ldh [hVramTransfer.srcAddrLow], a
        ld [saveBuf_enGfxSrcLow], a
        ld a, [hl+]
        ldh [hVramTransfer.srcAddrHigh], a
        ld [saveBuf_enGfxSrcHigh], a
        ; Set destination address (constant)
        ld a, LOW(vramDest_enemies)
        ldh [hVramTransfer.destAddrLow], a
        ld a, HIGH(vramDest_enemies)
        ldh [hVramTransfer.destAddrHigh], a
        ; Set transfer size (constant)
        ld a, $00
        ldh [hVramTransfer.sizeLow], a
        ld a, $04
        ldh [hVramTransfer.sizeHigh], a
        jp beginGraphicsTransfer
    .else:
        ; Load source bank (and save result to save buffer as background graphics)
        ld a, [hl+]
        ld [bankRegMirror], a
        ld [vramTransfer_srcBank], a
        ld [saveBuf_bgGfxSrcBank], a
        ld [rMBC_BANK_REG], a
        ; Load source address (and save result to save buffer as background graphics)
        ld a, [hl+]
        ldh [hVramTransfer.srcAddrLow], a
        ld [saveBuf_bgGfxSrcLow], a
        ld a, [hl+]
        ldh [hVramTransfer.srcAddrHigh], a
        ld [saveBuf_bgGfxSrcHigh], a
        ; Set destination address (constant)
        ld a, LOW(vramDest_bgTiles)
        ldh [hVramTransfer.destAddrLow], a
        ld a, HIGH(vramDest_bgTiles)
        ldh [hVramTransfer.destAddrHigh], a
        ; Set transfer size (contant)
        ld a, $00
        ldh [hVramTransfer.sizeLow], a
        ld a, $08
        ldh [hVramTransfer.sizeHigh], a
        jr beginGraphicsTransfer
;}

; Door script copy data routine
door_copyData: ;{ 00:2747
    ld a, [hl+]
    and $0f
    ld b, a
    cp $01 ; BG gfx case
        jr z, loadGraphics.background
    cp $02 ; Enemy gfx case
        jr z, loadGraphics.enemy
;} Fallthrough to default case

loadGraphics: ;{ 00:2753
    ; Load source bank
    ld a, [hl+]
    ld [bankRegMirror], a
    ld [vramTransfer_srcBank], a
    ld [rMBC_BANK_REG], a
    ; Load source address
    ld a, [hl+]
    ldh [hVramTransfer.srcAddrLow], a
    ld a, [hl+]
    ldh [hVramTransfer.srcAddrHigh], a
    ; Load destination address
    ld a, [hl+]
    ldh [hVramTransfer.destAddrLow], a
    ld a, [hl+]
    ldh [hVramTransfer.destAddrHigh], a
    ; Load block size
    ld a, [hl+]
    ldh [hVramTransfer.sizeLow], a
    ld a, [hl+]
    ldh [hVramTransfer.sizeHigh], a
jr beginGraphicsTransfer

; Case from door_copyData
.background: ;{ 00:2771
    ; Load source bank
    ld a, [hl+]
    ld [bankRegMirror], a
    ld [vramTransfer_srcBank], a
    ld [saveBuf_bgGfxSrcBank], a ; Save bank as BG graphics source
    ld [rMBC_BANK_REG], a
    ; Load source address (and save it as the BG graphics source)
    ld a, [hl+]
    ldh [hVramTransfer.srcAddrLow], a
    ld [saveBuf_bgGfxSrcLow], a
    ld a, [hl+]
    ldh [hVramTransfer.srcAddrHigh], a
    ld [saveBuf_bgGfxSrcHigh], a
    ; Load destination address
    ld a, [hl+]
    ldh [hVramTransfer.destAddrLow], a
    ld a, [hl+]
    ldh [hVramTransfer.destAddrHigh], a
    ; Load block size
    ld a, [hl+]
    ldh [hVramTransfer.sizeLow], a
    ld a, [hl+]
    ldh [hVramTransfer.sizeHigh], a
jr beginGraphicsTransfer ;}

; Case from door_copyData
.enemy: ;{ 00:2798
    ; Load source bank
    ld a, [hl+]
    ld [bankRegMirror], a
    ld [vramTransfer_srcBank], a
    ld [rMBC_BANK_REG], a
    ; Load source address (and save address as enemy graphics source)
    ld a, [hl+]
    ldh [hVramTransfer.srcAddrLow], a
    ld [saveBuf_enGfxSrcLow], a
    ld a, [hl+]
    ldh [hVramTransfer.srcAddrHigh], a
    ld [saveBuf_enGfxSrcHigh], a
    ; Load destination address
    ld a, [hl+]
    ldh [hVramTransfer.destAddrLow], a
    ld a, [hl+]
    ldh [hVramTransfer.destAddrHigh], a
    ; Load block size
    ld a, [hl+]
    ldh [hVramTransfer.sizeLow], a
    ld a, [hl+]
    ldh [hVramTransfer.sizeHigh], a
;} Fallthrough to next function
;}

beginGraphicsTransfer: ;{ 00:27BA
    ; Set VRAM transfer flag
    ld a, $ff
    ld [vramTransferFlag], a

    .loop:
        ; Skip some common routines during the Varia animation
        ld a, [variaAnimationFlag]
        and a
        jr z, .endIf
            call drawSamus_longJump
            call handleEnemiesOrQueen
            callFar drawHudMetroid
            call clearUnusedOamSlots_longJump
        .endIf:
        ; Wait until WRAM transfer is done
        call waitOneFrame
        ld a, [vramTransferFlag]
        and a
    jr nz, .loop
ret ;}

; Used for animating the Varia Suit collection
animateGettingVaria: ;{ 00:27E3
    ; Load VRAM update list (presumably for Varia)
    ld a, [hl+]
    ld [bankRegMirror], a
    ld [vramTransfer_srcBank], a
    ld [rMBC_BANK_REG], a
    ld a, [hl+]
    ldh [hVramTransfer.srcAddrLow], a
    ld a, [hl+]
    ldh [hVramTransfer.srcAddrHigh], a
    ld a, [hl+]
    ldh [hVramTransfer.destAddrLow], a
    ld a, [hl+]
    ldh [hVramTransfer.destAddrHigh], a
    ld a, [hl+]
    ldh [hVramTransfer.sizeLow], a
    ld a, [hl+]
    ldh [hVramTransfer.sizeHigh], a
    ; Enable VRAM transfer
    ld a, $ff
    ld [vramTransferFlag], a

    .loop:
        ; Set window height (higher position)
        ld a, $80
        ldh [rWY], a
        ; Do common tasks
        call drawSamus_longJump
        call handleEnemiesOrQueen
        callFar drawHudMetroid
        call clearUnusedOamSlots_longJump
        ; Wait for next frame
        call waitOneFrame
        ; Loop until 5 rows have been transfered
        ldh a, [hVramTransfer.destAddrHigh]
        cp $85
    jr c, .loop
    ; Clear animation flag
    xor a
    ld [variaAnimationFlag], a
ret ;}

door_loadTiletable: ;{ 00:282A
    ; Load bank that the metatiles are in
    switchBank metatilePointerTable
    ; Use lower nybble of token to index into the table
    ld a, [hl+]
    push hl
        and $0f
        sla a
        ld e, a
        ld d, $00
        ld hl, metatilePointerTable
        add hl, de
        ; Save pointer to save buffer
        ld a, [hl+]
        ld [saveBuf_tiletableSrcLow], a
        ld b, a
        ld a, [hl+]
        ld [saveBuf_tiletableSrcHigh], a
        ; Load pointer to HL
        ld h, a
        ld a, b
        ld l, a
        ; Copy to fill range $DA00-$DBFF
        ld de, tiletableArray
        .loop:
            ld a, [hl+]
            ld [de], a
            inc de
            ld a, d
            cp HIGH(tiletableArray.end) ;$DC
        jr nz, .loop
    ; Jump target will pop HL eventually
    ; Rerender screen ahead of camera
jp door_warp.rerender ;}

door_loadCollision: ;{ 00:2859
    ; Load bank that the collision data is in
    switchBank collisionPointerTable
    ; Use the lower nybble of the token to index into the pointer table
    ld a, [hl+]
    push hl
        and $0f
        sla a
        ld e, a
        ld d, $00
        ld hl, collisionPointerTable
        add hl, de
        ; Save pointer to save buffer
        ld a, [hl+]
        ld [saveBuf_collisionSrcLow], a
        ld b, a
        ld a, [hl+]
        ld [saveBuf_collisionSrcHigh], a
        ; Load pointer to HL
        ld h, a
        ld a, b
        ld l, a
        ; Copy to fill range $DC00-$DCFF
        ld de, collisionArray
        .loop:
            ld a, [hl+]
            ld [de], a
            inc de
            ld a, d
            cp HIGH(collisionArray.end) ; $DD
        jr nz, .loop
    pop hl
ret ;}

; Only called from the ENTER_QUEEN
door_queen: ;{ 00:2887
    ; Load destination map bank from lower nybble of token
    ld a, [hl+]
    and $0f
    ld [currentLevelBank], a
    ld [saveBuf_currentLevelBank], a
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ; Load camera y position (pixel/screen)
    ld a, [hl+]
    ldh [hCameraYPixel], a
    sub $48
    ld [scrollY], a
    ld a, [hl+]
    ldh [hCameraYScreen], a
    ; Load camera X position (pixel/screen)
    ld a, [hl+]
    ldh [hCameraXPixel], a
    sub $50
    ld [scrollX], a
    ld a, [hl+]
    ldh [hCameraXScreen], a
    ; Load Samus y position (pixel, screen)
    ld a, [hl+]
    ldh [hSamusYPixel], a
    ld a, [hl+]
    ldh [hSamusYScreen], a
    ; Load Samus x position (pixel, screen)
    ld a, [hl+]
    ldh [hSamusXPixel], a
    ld a, [hl+]
    ldh [hSamusXScreen], a
    push hl
        ; Render queen's room
        call disableLCD
        call queen_renderRoom
        ; Initialize the variables for the queen fight
        callFar queen_initialize
        ; Initialize Samus's onscreen x position
        ldh a, [hCameraXPixel]
        ld b, a
        ldh a, [hSamusXPixel]
        sub b
        add $60
        ld [samus_onscreenXPos], a
        ; Initialize Samus's onscreen y position
        ldh a, [hCameraYPixel]
        ld b, a
        ldh a, [hSamusYPixel]
        sub b
        add $62
        ld [samus_onscreenYPos], a
        ld a, $e3
        ldh [rLCDC], a
        ; Clear variables
        xor a
        ld [doorScrollDirection], a
        ld [scrollY], a
        ldh [rSCY], a
        ; Activate fade-in if necessary
        ld a, [bg_palette]
        cp $93
        jr z, .endIf
            ld a, $2f
            ld [fadeInTimer], a
        .endIf:
    pop hl
ret ;}

door_warp: ;{ 00:28FB
    ; Load destination bank from lower nybble of token
    ld a, [hl+]
    and $0f
    ld [currentLevelBank], a
    ld [saveBuf_currentLevelBank], a
    ; Load y screen from upper nybble of next byte
    ld a, [hl]
    swap a
    and $0f
    ldh [hCameraYScreen], a
    ldh [hSamusYScreen], a
    ; Load x screen from lower nybble of byte
    ld a, [hl+]
    and $0f
    ldh [hCameraXScreen], a
    ldh [hSamusXScreen], a
    ; Save HL (for subsequent door script tokens)
    push hl
    ; Wait a frame
    call waitOneFrame

.rerender: ; Rerender screen ahead of Samus
    ; Right
    ld a, [doorScrollDirection]
    cp $01
        jr z, .right
    ; Left
    ld a, [doorScrollDirection]
    cp $02
        jp z, .left
    ; Up
    ld a, [doorScrollDirection]
    cp $04
        jp z, .up
    ; Down
    ld a, [doorScrollDirection]
    cp $08
        jp z, .down
    ; None
    pop hl
ret

.right: ;{ 00:2939
    ; Get level bank
    switchBankVar [currentLevelBank]
    ; Init mapUpdateBuffer
    ld a, LOW(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrLow], a
    ld a, HIGH(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrHigh], a
    ld a, $ff
    ld [mapUpdate_unusedVar], a
    ; Get the x coordinate of the column to be rendered
    ldh a, [hCameraXPixel]
    add $50
    ldh [hMapSource.xPixel], a
    ldh a, [hCameraXScreen]
    adc $00
    and $0f
    ldh [hMapSource.xScreen], a
    ; Get y coordinate of the top of the column to be rendered
    ldh a, [hCameraYPixel]
    sub $74
    ldh [hMapSource.yPixel], a
    ldh a, [hCameraYScreen]
    sbc $00
    and $0f
    ldh [hMapSource.yScreen], a
    ; Render map column
    call prepMapUpdate.column
    call waitOneFrame
    
    ; Get level bank
    switchBankVar [currentLevelBank]
    ; Init mapUpdateBuffer
    ld a, LOW(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrLow], a
    ld a, HIGH(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrHigh], a
    ld a, $ff
    ld [mapUpdate_unusedVar], a
    ; Get the x coordinate of the next column to be rendered
    ldh a, [hCameraXPixel]
    add $60
    ldh [hMapSource.xPixel], a
    ldh a, [hCameraXScreen]
    adc $00
    and $0f
    ldh [hMapSource.xScreen], a
    ; Render map column
    call prepMapUpdate.column
    call waitOneFrame
    
    ; Get level bank
    switchBankVar [currentLevelBank]
    ; Init mapUpdateBuffer
    ld a, LOW(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrLow], a
    ld a, HIGH(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrHigh], a
    ld a, $ff
    ld [mapUpdate_unusedVar], a
    ; Get the x coordinate of the next column to be rendered
    ldh a, [hCameraXPixel]
    add $70
    ldh [hMapSource.xPixel], a
    ldh a, [hCameraXScreen]
    adc $00
    and $0f
    ldh [hMapSource.xScreen], a
    ; Render map column
    call prepMapUpdate.column
    ; Get back the working pointer for the door script
    pop hl
ret ;}

.left: ;{ 00:29C4
    ; Get level bank
    switchBankVar [currentLevelBank]
    ; Init mapUpdateBuffer
    ld a, LOW(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrLow], a
    ld a, HIGH(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrHigh], a
    ld a, $ff
    ld [mapUpdate_unusedVar], a
    ; Get the x coordinate of the column to be rendered
    ldh a, [hCameraXPixel]
    sub $60
    ldh [hMapSource.xPixel], a
    ldh a, [hCameraXScreen]
    sbc $00
    and $0f
    ldh [hMapSource.xScreen], a
    ; Get y coordinate of the top of the column to be rendered
    ldh a, [hCameraYPixel]
    sub $74
    ldh [hMapSource.yPixel], a
    ldh a, [hCameraYScreen]
    sbc $00
    and $0f
    ldh [hMapSource.yScreen], a
    ; Render map column
    call prepMapUpdate.column
    call waitOneFrame
    
    ; Get level bank
    switchBankVar [currentLevelBank]
    ; Init mapUpdateBuffer
    ld a, LOW(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrLow], a
    ld a, HIGH(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrHigh], a
    ld a, $ff
    ld [mapUpdate_unusedVar], a
    ; Get the x coordinate of the next column to be rendered
    ldh a, [hCameraXPixel]
    sub $70
    ldh [hMapSource.xPixel], a
    ldh a, [hCameraXScreen]
    sbc $00
    and $0f
    ldh [hMapSource.xScreen], a
    ; Render map column
    call prepMapUpdate.column
    call waitOneFrame
    
    ; Get level bank
    switchBankVar [currentLevelBank]
    ; Init mapUpdateBuffer
    ld a, LOW(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrLow], a
    ld a, HIGH(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrHigh], a
    ld a, $ff
    ld [mapUpdate_unusedVar], a
    ; Get the x coordinate of the next column to be rendered
    ldh a, [hCameraXPixel]
    sub $80
    ldh [hMapSource.xPixel], a
    ldh a, [hCameraXScreen]
    sbc $00
    and $0f
    ldh [hMapSource.xScreen], a
    ; Render map column
    call prepMapUpdate.column
    ; Get back the working pointer for the door script
    pop hl
ret ;}

.down: ;{ 00:2A4F - This case renders 4 rows instead of 3. Odd.
    ; Get level bank
    switchBankVar [currentLevelBank]
    ; Init mapUpdateBuffer
    ld a, LOW(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrLow], a
    ld a, HIGH(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrHigh], a
    ld a, $ff
    ld [mapUpdate_unusedVar], a
    ; Get x coordinate of the left of the row to be rendered
    ldh a, [hCameraXPixel]
    sub $80
    ldh [hMapSource.xPixel], a
    ldh a, [hCameraXScreen]
    sbc $00
    and $0f
    ldh [hMapSource.xScreen], a
    ; Get the y coordinate of the row to be rendered
    ldh a, [hCameraYPixel]
    add $78
    ldh [hMapSource.yPixel], a
    ldh a, [hCameraYScreen]
    adc $00
    and $0f
    ldh [hMapSource.yScreen], a
    ; Render map row
    call prepMapUpdate.row
    call waitOneFrame
    
    ; Get level bank
    switchBankVar [currentLevelBank]
    ; Init mapUpdateBuffer
    ld a, LOW(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrLow], a
    ld a, HIGH(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrHigh], a
    ld a, $ff
    ld [mapUpdate_unusedVar], a
    ; Get the y coordinate of the next row to be rendered
    ldh a, [hCameraYPixel]
    add $68
    ldh [hMapSource.yPixel], a
    ldh a, [hCameraYScreen]
    adc $00
    and $0f
    ldh [hMapSource.yScreen], a
    ; Render map row
    call prepMapUpdate.row
    call waitOneFrame
    
    ; Get level bank
    switchBankVar [currentLevelBank]
    ; Init mapUpdateBuffer
    ld a, LOW(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrLow], a
    ld a, HIGH(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrHigh], a
    ld a, $ff
    ld [mapUpdate_unusedVar], a
    ; Get the y coordinate of the next row to be rendered
    ldh a, [hCameraYPixel]
    add $58
    ldh [hMapSource.yPixel], a
    ldh a, [hCameraYScreen]
    adc $00
    and $0f
    ldh [hMapSource.yScreen], a
    ; Render map row
    call prepMapUpdate.row
    call waitOneFrame
    
    ; Get level bank
    switchBankVar [currentLevelBank]
    ; Init mapUpdateBuffer
    ld a, LOW(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrLow], a
    ld a, HIGH(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrHigh], a
    ld a, $ff
    ld [mapUpdate_unusedVar], a
    ; Get the y coordinate of the next row to be rendered
    ldh a, [hCameraYPixel]
    add $48
    ldh [hMapSource.yPixel], a
    ldh a, [hCameraYScreen]
    adc $00
    and $0f
    ldh [hMapSource.yScreen], a
    ; Render map row
    call prepMapUpdate.row
    ; Get back the working pointer for the door script
    pop hl
ret ;}

.up: ;{ 00:2B04
    ; Get level bank
    switchBankVar [currentLevelBank]
    ; Init mapUpdateBuffer
    ld a, LOW(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrLow], a
    ld a, HIGH(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrHigh], a
    ld a, $ff
    ld [mapUpdate_unusedVar], a
    ; Get x coordinate of the left of the row to be rendered
    ldh a, [hCameraXPixel]
    sub $80
    ldh [hMapSource.xPixel], a
    ldh a, [hCameraXScreen]
    sbc $00
    and $0f
    ldh [hMapSource.xScreen], a
    ; Get the y coordinate of the row to be rendered
    ldh a, [hCameraYPixel]
    sub $78
    ldh [hMapSource.yPixel], a
    ldh a, [hCameraYScreen]
    sbc $00
    and $0f
    ldh [hMapSource.yScreen], a
    ; Render map row
    call prepMapUpdate.row
    call waitOneFrame
    
    ; Get level bank
    switchBankVar [currentLevelBank]
    ; Init mapUpdateBuffer
    ld a, LOW(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrLow], a
    ld a, HIGH(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrHigh], a
    ld a, $ff
    ld [mapUpdate_unusedVar], a
    ; Get the y coordinate of the next row to be rendered
    ldh a, [hCameraYPixel]
    sub $68
    ldh [hMapSource.yPixel], a
    ldh a, [hCameraYScreen]
    sbc $00
    and $0f
    ldh [hMapSource.yScreen], a
    ; Render map row
    call prepMapUpdate.row
    call waitOneFrame
    
    ; Get level bank
    switchBankVar [currentLevelBank]
    ; Init mapUpdateBuffer
    ld a, LOW(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrLow], a
    ld a, HIGH(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrHigh], a
    ld a, $ff
    ld [mapUpdate_unusedVar], a
    ; Get the y coordinate of the next row to be rendered
    ldh a, [hCameraYPixel]
    sub $58
    ldh [hMapSource.yPixel], a
    ldh a, [hCameraYScreen]
    sbc $00
    and $0f
    ldh [hMapSource.yScreen], a
    ; Render map row
    call prepMapUpdate.row
    ; Get back the working pointer for the door script
    pop hl
ret ;}
;}

; Called if doorIndexLow is non-zero
VBlank_updateMapDuringTransition: ;{ 00:2B8F
    ; Exit if no map update pending
    ld a, [mapUpdateFlag]
    and a
        jr z, VBlank_vramDataTransfer.exit
    ; Pretty sure this bankswitch is not needed
    switchBankVar [currentLevelBank]
    ; Update map
    call VBlank_updateMap
jr VBlank_vramDataTransfer.exit ;}

VBlank_vramDataTransfer: ;{ 00:2BA3
    ; Check if varia suit is being collected
    ld a, [variaAnimationFlag]
    and a
        jp nz, VBlank_variaAnimation

    ; Load transfer parameters
    ld a, [vramTransfer_srcBank]
    ld [rMBC_BANK_REG], a
    ldh a, [hVramTransfer.sizeLow]
    ld c, a
    ldh a, [hVramTransfer.sizeHigh]
    ld b, a
    ldh a, [hVramTransfer.srcAddrLow]
    ld l, a
    ldh a, [hVramTransfer.srcAddrHigh]
    ld h, a
    ldh a, [hVramTransfer.destAddrLow]
    ld e, a
    ldh a, [hVramTransfer.destAddrHigh]
    ld d, a

    .transferLoop:
        ld a, [hl+]
        ld [de], a
        inc de
        dec bc
        ld a, c
        and $3f ; Limits updates to 4 tiles/frame
    jr nz, .transferLoop

    ; Save transfer parameters
    ld a, c
    ldh [hVramTransfer.sizeLow], a
    ld a, b
    ldh [hVramTransfer.sizeHigh], a
    ld a, l
    ldh [hVramTransfer.srcAddrLow], a
    ld a, h
    ldh [hVramTransfer.srcAddrHigh], a
    ld a, e
    ldh [hVramTransfer.destAddrLow], a
    ld a, d
    ldh [hVramTransfer.destAddrHigh], a
    ; Clear update flag if done
    ld a, b
    or c
    jr nz, .endIf
        xor a
        ld [vramTransferFlag], a
    .endIf:
.exit:
    ; Exit vblank
    ; Interesting that OAM_DMA is not called
    ld a, $01
    ldh [hVBlankDoneFlag], a
    ld a, [bankRegMirror]
    ld [rMBC_BANK_REG], a
    pop hl
    pop de
    pop bc
    pop af
reti ;}

; Varia animation case
VBlank_variaAnimation: ;{ 00:2BF4
    ; Animate every other frame
    ldh a, [frameCounter]
    and $01
    jr nz, .endIf_A
        ; Set HL to the source byte of the data transfer
        ld a, [vramTransfer_srcBank]
        ld [rMBC_BANK_REG], a
        ldh a, [hVramTransfer.destAddrLow]
        ld l, a
        ldh a, [hVramTransfer.destAddrHigh]
        ld h, a
        ; Unused line since DE is immediately overwritten
        ld de, $0010
        .loop:
            ; Update DE
            push hl
                ld de, gfx_samusVariaSuit - vramDest_samus ; $CE20 = ($4E20 - $8000)
                add hl, de
                ld e, l
                ld d, h
            pop hl
            ; Load GFX from ROM to VRAM
            ld a, [de]
            ld [hl], a
            ; Increment to same row in next tile
            ld a, l
            add $10
            ld l, a
            ld a, h
            adc $00
            ld h, a
            ; Exit loop if L = $0x (row is complete
            ld a, l
            and $F0
        jr nz, .loop
        ; HL = HL - $00FF (get first byte of next pixel row)
        ld a, l
        sub $ff
        ld l, a
        ld a, h
        sbc $00
        ld h, a
        ; Check if we passed the last pixel row of a tile
        ld a, l
        cp $10
        jr nz, .endIf_B
            ; If so, HL = HL + $00F0 (move to first pixel row of the next tile row)
            add $f0
            ld l, a
            ld a, h
            adc $00
            ld h, a
        .endIf_B:
        ; Save VRAM transfer parameters
        ld a, l
        ldh [hVramTransfer.destAddrLow], a
        ld a, h
        ldh [hVramTransfer.destAddrHigh], a
        ; Clear variable if we've transfered all 5 rows
        cp $85
        jr nz, .endIf_C
            xor a
            ld [deathAnimTimer], a
        .endIf_C:
    .endIf_A:
    ; Exit VBlank
    ld a, [scrollY]
    ldh [rSCY], a
    ld a, [scrollX]
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
reti ;}

waitOneFrame: ;{ 00:2C5E
    ; Handle audio
    push hl
    call handleAudio_longJump
    pop hl
    db $76 ; halt
    ; Wait for VBlank to finish
    .vBlankNotDone:
        ldh a, [hVBlankDoneFlag]
        and a
    jr z, .vBlankNotDone
    ; Increment frame counter
    ldh a, [frameCounter]
    inc a
    ldh [frameCounter], a
    ; Clear VBlank flag
    xor a
    ldh [hVBlankDoneFlag], a
    ; Reset OAM buffer index
    ld a, $c0
    ldh [hUnusedFlag_1], a ; Likely the unused high-byte of the OAM buffer index/pointer
    xor a
    ldh [hOamBufferIndex], a
ret ;}

tryPausing: ;{ 00:2C79
    ; Don't try pausing unless start is pressed
    ldh a, [hInputRisingEdge]
    cp PADF_START
        ret nz
    ; No pausing in Queen's room
    ld a, [queen_roomFlag]
    cp $11
        ret z
    ; No pausing if facing the screen
    ld a, [samusPose]
    cp pose_faceScreen
        ret z
    ; No pausing if in a scroll direction
    ld a, [doorScrollDirection]
    and a
        ret nz
    ; No pausing when on a save pillar
    ld a, [saveContactFlag]
    and a
        ret nz

    ; Read L counter value from table
    ld hl, metroidLCounterTable
    ld a, [metroidCountReal]
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    ld [metroidLCounterDisp], a
    ; Clear displayed L counter value if an earthquake is either queued up or happening
    ld a, [nextEarthquakeTimer]
    and a
    jr nz, .then_A
        ld a, [earthquakeTimer]
        and a
        jr z, .endIf_A
    .then_A:
        xor a
        ld [metroidLCounterDisp], a
    .endIf_A:

    ; Clear sprites if debug mode is enabled
    ld a, [debugFlag]
    and a
    jr z, .endIf_B
        xor a
        ldh [hOamBufferIndex], a
        call clearUnusedOamSlots_longJump
    .endIf_B:

    ; Clear variables
    xor a
    ld [debugItemIndex], a
    ld [unused_D011], a
    
    ; Set HL to align with sprite tile byte
    ld hl, wram_oamBuffer + $2
    
    ; Attempt to find the first sprite that uses the HUD Metroid sprite tiles ($9A and $9B)
    ; Note that the following hex values would all be detected by this loop:
    ;  9A, 9B, 9E, 9F, BA, BB, BE, BF, DA, DB, DE, DF, FA, FB, FE, FF
    ; The HUD Metroid is rendered after Samus and the beams, which menas that they
    ;  should not use tiles with those values. (Enemy sprites are not a concern here.)
    .loop:
        ld a, [hl]
        and $9a
        cp $9a
            jr z, .break
        ld a, l
        ; Iterate to next sprite
        add $04
        ld l, a
        cp OAM_MAX ; $A0
    jr c, .loop
    jr .exit

.break:
    ; Draw the L counter sprite
    ld de, $0004
    ; Write blank tile
    ld a, $36
    ld [hl], a
    ; Iterate to next sprite
    add hl, de
    ; Write L tile
    ld a, $0f
    ld [hl], a

.exit:
    ; Play pause sound and stop music
    ld a, $01
    ld [audioPauseControl], a
    ; Set game mode
    ld a, $08
    ldh [gameMode], a
ret ;}

gameMode_Paused: ;{ 00:2CED
    ; Change palette on a 32 frame cycle (16 frame light/dark phases)
    ld b, $93 ;$e7
    ldh a, [frameCounter]
    bit 4, a
    jr z, .endIf
        ld b, $93
    .endIf:
    ; Set palette
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
    ; Play unpausing sound
    ld a, $02
    ld [audioPauseControl], a
    ; Switch game mode
    ld a, $04
    ldh [gameMode], a
ret

.debugBranch:
    call drawHudMetroid_longJump
    ldh a, [hInputRisingEdge]
    cp PADF_START
        jr nz, debugPauseMenu

    ; Return to main game mode if start is pressed
    ; Reset palette
    ld a, $93
    ld [bg_palette], a
    ld [ob_palette0], a
    ; Clear sprites
    call clearUnusedOamSlots_longJump
    ; Play unpause sound effect
    ld a, $02
    ld [audioPauseControl], a
    ; Set game mode
    ld a, $04
    ldh [gameMode], a
ret ;}

debugPauseMenu: ;{ 00:2D39
;{ Main input logic for debug menu
    ; Handle right input
    ldh a, [hInputRisingEdge]
    bit PADB_RIGHT, a
    jr z, .endIf_A
        ; Check if holding B
        ldh a, [hInputPressed]
        bit PADB_B, a
        jr nz, .endIf_B
            ; Move debug cursor right
            ld a, [debugItemIndex]
            dec a
            and $07
            ld [debugItemIndex], a
            jr .endIf_A
        .endIf_B:
    
        ; Check if holding A
        bit PADB_A, a
        jr z, .endIf_C
            ; Decrement metroid count
            ld a, [metroidCountReal]
            sub $01
            daa
            ld [metroidCountReal], a
            ld a, [metroidCountDisplayed]
            sub $01
            daa
            ld [metroidCountDisplayed], a
            jr .endIf_A
        .endIf_C:
    
        ; If not holding A or B
        ld a, [samusEnergyTanks]
        and a
        jr z, .endIf_A
            ; Decrease Samus' energy tanks (minimum of zero)
            dec a
            ld [samusEnergyTanks], a
            ld [samusCurHealthHigh], a
            ld a, $99
            ld [samusCurHealthLow], a
    .endIf_A:

    ; Handle left input
    ldh a, [hInputRisingEdge]
    bit PADB_LEFT, a
    jr z, .endIf_D
        ; Check if holding B
        ldh a, [hInputPressed]
        bit PADB_B, a
        jr nz, .endIf_E
            ; Move debug cursor left
            ld a, [debugItemIndex]
            inc a
            and $07
            ld [debugItemIndex], a
            jr .endIf_D
        .endIf_E:
    
        ; Check if holding A
        bit PADB_A, a
        jr z, .endIf_F
            ; Decrement metroid count
            ld a, [metroidCountReal]
            add $01
            daa
            ld [metroidCountReal], a
            ld a, [metroidCountDisplayed]
            add $01
            daa
            ld [metroidCountDisplayed], a
            jr .endIf_D
        .endIf_F:
    
        ; If not holding A or B
        ld a, [samusEnergyTanks]
        cp $05
        jr z, .endIf_D
            ; Increase Samus' energy tanks (max 5)
            inc a
            ld [samusEnergyTanks], a
            ld [samusCurHealthHigh], a
            ld a, $99
            ld [samusCurHealthLow], a
    .endIf_D:

    ; Handle A press
    ldh a, [hInputRisingEdge]
    bit PADB_A, a
    jr z, .endIf_G
        ; Toggle item bit 
        ld b, %00000001 ; Initial bitmask
        ld a, [debugItemIndex]
        .bitmaskLoop:
            dec a
            cp $ff
                jr z, .break
            sla b
        jr .bitmaskLoop
        .break:
        ; Bitmask now corresponds to item index
        
        ; Toggle appropriate bit
        ld a, [samusItems]
        xor b
        ld [samusItems], a
    .endIf_G:

    ; Handle up input
    ldh a, [hInputRisingEdge]
    bit PADB_UP, a
    jr z, .endIf_H
        ; Check if holding B
        ldh a, [hInputPressed]
        bit PADB_B, a
        jr nz, .else_I
            ; Increment weapon equipped
            ld a, [samusActiveWeapon]
            inc a
            ld [samusActiveWeapon], a
            ld [samusBeam], a
            jr .endIf_H
        .else_I:
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
    .endIf_H:

    ; Handle down input
    ldh a, [hInputRisingEdge]
    bit PADB_DOWN, a
    jr z, .endIf_J
        ; Check if holding B
        ldh a, [hInputPressed]
        bit PADB_B, a
        jr nz, .else_K
            ; Decrement weapon equipped
            ld a, [samusActiveWeapon]
            dec a
            ld [samusActiveWeapon], a
            ld [samusBeam], a
            jr .endIf_J
        .else_K:
            ; Decrement max missiles
            ld a, [samusCurMissilesLow]
            sub $10
            daa
            ld [samusCurMissilesLow], a
            ld a, [samusCurMissilesHigh]
            sbc $00
            daa
            ld [samusCurMissilesHigh], a
    .endIf_J:
;}

;{ Render logic for debug menu
    switchBank debug_drawNumber
    ; Display debug cursor
    ; ypos is fixed
    ld a, $58
    ldh [hSpriteYPixel], a
    ; xpos = index*8 + $69
    ld a, [debugItemIndex]
    swap a
    srl a
    xor $ff
    add $69
    ldh [hSpriteXPixel], a
    ; Display index of item bit
    ld a, [debugItemIndex]
    call debug_drawNumber.oneDigit
    
    ; Draw item toggle icons
    ; Set common y position and sprite ID
    ld a, $54
    ldh [hSpriteYPixel], a
    ld a, $36
    ldh [hSpriteId], a
    ; Draw item icons
    ld a, $34
    ldh [hSpriteXPixel], a
    ld a, [samusItems]
    bit itemBit_UNUSED, a
        call nz, drawSamusSprite   
    ld a, $3c
    ldh [hSpriteXPixel], a
    ld a, [samusItems]
    bit itemBit_varia, a
        call nz, drawSamusSprite
    ld a, $44
    ldh [hSpriteXPixel], a
    ld a, [samusItems]
    bit itemBit_spider, a
        call nz, drawSamusSprite
    ld a, $4c
    ldh [hSpriteXPixel], a
    ld a, [samusItems]
    bit itemBit_spring, a
        call nz, drawSamusSprite
    ld a, $54
    ldh [hSpriteXPixel], a
    ld a, [samusItems]
    bit itemBit_space, a
        call nz, drawSamusSprite
    ld a, $5c
    ldh [hSpriteXPixel], a
    ld a, [samusItems]
    bit itemBit_screw, a
        call nz, drawSamusSprite
    ld a, $64
    ldh [hSpriteXPixel], a
    ld a, [samusItems]
    bit itemBit_hiJump, a
        call nz, drawSamusSprite
    ld a, $6c
    ldh [hSpriteXPixel], a
    ld a, [samusItems]
    bit itemBit_bomb, a
        call nz, drawSamusSprite

    ; Draw Samus' current weapon number
    ld a, $68
    ldh [hSpriteYPixel], a
    ld a, $50
    ldh [hSpriteXPixel], a
    ld a, [samusActiveWeapon]
    call debug_drawNumber.twoDigit

    ; OAM bookkeeping
    ldh a, [hOamBufferIndex]
    ld [maxOamPrevFrame], a
;} End display logic

; Save if pressing select and standing or morphing
    ldh a, [hInputRisingEdge]
    cp PADF_SELECT
        ret nz
    ldh a, [hInputPressed]
    cp PADF_SELECT
        ret nz
    ld a, [samusPose]
    and a ; equivalent to "cp pose_standing"
        jr z, .save
    cp pose_morph
        ret nz
        
.save:
    ld a, $09
    ldh [gameMode], a
ret ;}

hurtSamus: ;{ 00:2EE3
    ; Exit if hurt flag is not set
    ld a, [samus_hurtFlag]
    cp $01
        ret nz
    ; Clear hurt flag
    xor a
    ld [samus_hurtFlag], a

    ; Exit if i-frames are active
    ld a, [samusInvulnerableTimer]
    and a
        ret nz

    ; Apply damage value to Samus
    ld a, [samus_damageValue]
    call applyDamage.enemySpike
    ; Give Samus i-frames
    ld a, $33
    ld [samusInvulnerableTimer], a

    ; Use table to force Samus into the appropriate knockback pose
    ld a, [samusPose]
    res 7, a ; Force Samus out of turnaround animation
    ld e, a
    ld d, $00
    ld hl, samus_damagePoseTransitionTable
    add hl, de
    ld a, [hl]
    ld [samusPose], a

    ; Set travel direction to damage boost direction
    ld a, [samus_damageBoostDirection]
    ld [samusAirDirection], a
    ; Force damage boost to right if in Queen's room
    ld a, [queen_roomFlag]
    cp $11
    jr nz, .endIf
        ld a, $01
        ld [samusAirDirection], a
    .endIf:

    ; Set jump arc counter to base
    ld a, samus_jumpArrayBaseOffset
    ld [samus_jumpArcCounter], a
    xor a
    ld [samus_unmorphJumpTimer], a
ret ;}

applyDamage: ;{ This procedure has multiple entry points
    .queenStomach: ; 00:2F29
        ; Apply queen stomach damage
        ; Make noise once every 8 frames
        ldh a, [frameCounter]
        and $07
            ret nz
        ld a, $07
        ld [sfxRequest_noise], a
        ; Damage once every 16 frames
        ldh a, [frameCounter]
        and $0f
            ret nz
        ; Set damage to 2
        ld b, $02
        jr .apply
        
    .larvaMetroid: ; 00:2F3C
        ; Any enemies with a damage value of $FE inflicts continuous contact damage.
        ; In the game, this only applies to the larva metroids.
        ; Set damage to 3
        ld b, $03
        ; Damage once every 8 frames
        ldh a, [frameCounter]
        and $07
            ret nz
        ; Make noise
        ld a, $07
        ld [sfxRequest_noise], a
        jr .apply
        
    .acid: ; 00:2F4A
        ; Damage is set by caller
        ld b, a
        ; Damage once every 16 frames
        ldh a, [frameCounter]
        and $0f
            ret nz
        ; Make noise
        ld a, $07
        ld [sfxRequest_noise], a
        jr .apply
        
    .enemySpike: ; 00:2F57
        ; Apply damage from enemies, spikes, and respawning blocks
        ld b, a
        ; Arbitrarily limit damage to 60 units (remember Samus' health is BCD)
        cp $60
            ret nc
        ; Play sound
        ld a, $06
        ld [sfxRequest_noise], a
        ; Fallthrough to .apply
        
.apply: ; Apply damage
    ; Half damage with varia
    ; (note this results in unintuitive results for higher damage values thanks to health being BCD)
    ld a, [samusItems]
    bit itemBit_varia, a
    jr z, .endIf_A
        srl b
    .endIf_A:
    ; Take health
    ld a, [samusCurHealthLow]
    sub b
    daa
    ld [samusCurHealthLow], a    
    ld a, [samusCurHealthHigh]
    sbc $00
    daa
    ld [samusCurHealthHigh], a
    ; Clamp to zero health minimum
    cp $99
    jr nz, .endIf_B
        xor a
        ld [samusCurHealthLow], a
        ld [samusCurHealthHigh], a
    .endIf_B:
ret ;}

gameMode_dying: ;{ 00:2F86
    ; Do some things, only during the queen fight
    ld a, [queen_roomFlag]
    cp $11
    jr nz, .endIf
        call drawSamus_longJump ; Draw Samus
        call drawHudMetroid_longJump
        callFar queenHandler
        call clearUnusedOamSlots_longJump
    .endIf:
ret ;}

; Tasks to do once Samus's displayed health reaches zero
killSamus: ;{ 00:2FA2
    ; Silence audio
    call silenceAudio_longJump
    ; Play noise
    ld a, $0b
    ld [sfxRequest_noise], a
    ; Delay a frame
    call waitOneFrame
    ; Draw Samus regardless of i-frames
    call drawSamus_ignoreDamageFrames_longJump
    ; Set timer
    ld a, $20
    ld [deathAnimTimer], a
    ; Set base address of tile manipulation
    ;  Note: the actual death animation does not use this variable
    xor a
    ld [pDeathAltAnimBaseLow], a
    ld a, $80
    ld [pDeathAltAnimBaseHigh], a
    ld a, $01
    ld [deathFlag], a
    ld a, $06
    ldh [gameMode], a
ret ;}

prepUnusedDeathAnimation: ;{ 00:2FC8 - Unused
    ; Force Samus to face screen for 160 frames
    ld a, $a0
    ld [samus_turnAnimTimer], a
    ; Set pose to standing, in turnaround state
    ld a, $80 | pose_standing
    ld [samusPose], a
    ; Set timer
    ; Note: The reason it is suspected that this function pertains to 
    ;  "unusedDeathAnimation" is because it sets deathAnimTimer but
    ;  not deathFlag.
    ld a, $20
    ld [deathAnimTimer], a
    ; Set base address of tile effect
    xor a
    ld [pDeathAltAnimBaseLow], a
    ld a, $80
    ld [pDeathAltAnimBaseHigh], a
ret ;}

; Vblank routine for death
VBlank_deathSequence: ;{ 00:2FE1
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

    ; Set scroll values
    ld a, [scrollY]
    ldh [rSCY], a
    ld a, [scrollX]
    ldh [rSCX], a
    ; DMA sprites
    call OAM_DMA

    ; Queen vblank handler if necessary
    ld a, BANK(VBlank_drawQueen)
    ld [rMBC_BANK_REG], a
    ld a, [queen_roomFlag]
    cp $11
        call z, VBlank_drawQueen

    ; Return from interrupt
    ld a, [bankRegMirror]
    ld [rMBC_BANK_REG], a
    ld a, $01
    ldh [hVBlankDoneFlag], a
    pop hl
    pop de
    pop bc
    pop af
reti ;}

deathAnimationTable:: ; 00:3042
    db $00, $04, $08, $0c, $10, $14, $18, $1c, $01, $05, $09, $0d, $11, $15, $19, $1d
    db $02, $06, $0a, $0e, $12, $16, $1a, $1e, $03, $07, $0b, $0f, $13, $17, $1b, $1f

; Only jumped to if the death animation vblank handler is called, but the death flag is not set
;  which is impossible
; Possibly not intended as a death animation
unusedDeathAnimation: ;{ 00:3062
    ; Animate every other frame
    ldh a, [frameCounter]
    and $01
    jr nz, .endIf_A
        ; Get pointer for starting offset
        ld a, [pDeathAltAnimBaseLow]
        ld l, a
        ld a, [pDeathAltAnimBaseHigh]
        ld h, a
        
        ; Set increment value for loop
        ld de, $0010
        .eraseLoop:
            ; Clear byte
            xor a
            ld [hl], a
            ; Iterate to next byte
            add hl, de
            ; Exit loop once $xx0x is reached
            ld a, l
            and $f0
        jr nz, .eraseLoop
        ; Iterate to next row of pixels to clear        
        ; HL-$00FF (to get to the next byte of the starting tile)
        ld a, l
        sub $ff
        ld l, a
        ld a, h
        sbc $00
        ld h, a
        ; If HL points to the second tile in a row
        ld a, l
        cp $10
        jr nz, .endIf_B
            ; Then add $F0 to HL so it points to the first tile of the next row
            add $f0
            ld l, a
            ld a, h
            adc $00
            ld h, a
        .endIf_B:
        ; Save the pointer
        ld a, l
        ld [pDeathAltAnimBaseLow], a
        ld a, h
        ld [pDeathAltAnimBaseHigh], a
        ; Stop animating once 5 rows have been cleared
        cp $85
        jr nz, .endIf_A
            ; Clear timer
            xor a
            ld [deathAnimTimer], a
            ; Note: This does not set deathFlag
            ;  or gameMode like it should.
    .endIf_A:

    ; Set scroll values
    ld a, [scrollY]
    ldh [rSCY], a
    ld a, [scrollX]
    ldh [rSCX], a
    ; DMA sprites
    call OAM_DMA
    ; Return from interrupt
    ld a, [bankRegMirror]
    ld [rMBC_BANK_REG], a
    ld a, $01
    ldh [hVBlankDoneFlag], a
    pop hl
    pop de
    pop bc
    pop af
reti ;}

; Sprite-sprite collision routines {

; 00:30BB - Bomb-enemy collision detection
collision_bombEnemies: ;{ 00:30BB
    ; Set temp variables to bomb coordinates
    ldh a, [hSpriteYPixel]
    ldh [hTemp.a], a
    ldh a, [hSpriteXPixel]
    ldh [hTemp.b], a
    ; Switch to bank with enemy hitboxes
    switchBank enemyHitboxPointers
    ; Iterate through all enemy slots
    ld hl, enemyDataSlots
    .loop:
        ; Check if enemy is active ($x0 status value)
        ld a, [hl]
        and $0f
        jr nz, .endIf
            ; If so, check collision
            call collision_bombOneEnemy
            ; Exit if a collision occurred
            jr c, .break
        .endIf:
        ; Iterate to next enemy
        ld de, ENEMY_SLOT_SIZE ; $0020
        add hl, de
        ; Exit loop if at end of enemy slots
        ld a, h
        cp HIGH(enemyDataSlots.end)
    jr nz, .loop
    .break:
    
    ; Switch to bank of caller function
    switchBank drawBombs
ret ;}

; Bomb-enemy single collision
collision_bombOneEnemy: ;{ 00:30EA
    ; push the enemy base address on the stack
    push hl
    inc hl ; Iterate past status byte
    ; Load enemy Y
    ld a, [hl+]
    ; Skip collision if offscreen vertically
    cp $e0
        jp nc, .exit_noHit
    ldh [hCollision_enY], a

    ; Load enemy X
    ld a, [hl+]
    ; Skip collision if offscreen horizontally
    cp $e0
        jp nc, .exit_noHit
    ldh [hCollision_enX], a

    ; Load enemy sprite type
    ld a, [hl+]
    ldh [hCollision_enSprite], a
    ; Load enemy attributes
    inc hl
    ld a, [hl+]
    ldh [hCollision_enAttr], a

    ; Load hitbox pointer of enemy
    ldh a, [hCollision_enSprite]
    sla a
    ld e, a
    ld d, $00
    rl d
    ld hl, enemyHitboxPointers
    add hl, de
    ; Load pointer to HL
    ld a, [hl+]
    ld e, a
    ld a, [hl]
    ld h, a
    ld l, e
    ; Save enY to B
    ldh a, [hCollision_enY]
    ld b, a
    ; Check if vertically flipped
    ldh a, [hCollision_enAttr]
    bit OAMB_YFLIP, a
    jr nz, .else_A
        ; Normal case
        ; hCollision_enTop = (top+Y) - $10
        ld a, [hl+]
        add b
        sub $10
        ldh [hCollision_enTop], a
        ; hCollision_enBottom = (bottom+Y) + $10
        ld a, [hl+]
        add b
        add $10
        ldh [hCollision_enBottom], a
        jr .endIf_A
    .else_A:
        ; Vertically flipped case
        ; hCollision_enBottom = -(bottom-Y) + $10
        ld a, [hl+]
        sub b
        cpl
        add $10
        ldh [hCollision_enBottom], a
        ; hCollision_enTop = -(bottom-Y) - $10
        ld a, [hl+]
        sub b
        cpl
        sub $10
        ldh [hCollision_enTop], a
    .endIf_A:

    ; Save enX to B
    ldh a, [hCollision_enX]
    ld b, a
    ; Check if horizontally flipped
    ldh a, [hCollision_enAttr]
    bit OAMB_XFLIP, a
    jr nz, .else_B
        ; Normal case
        ; hCollision_enLeft = (left+X) - $10
        ld a, [hl+]
        add b
        sub $10
        ldh [hCollision_enLeft], a
        ; hCollision_enRight = (right+X) + $10
        ld a, [hl+]
        add b
        add $10
        ldh [hCollision_enRight], a
        jr .endIf_B
    .else_B:
        ; Horizontally flipped case
        ; hCollision_enRight = -(left-X) + $10
        ld a, [hl+]
        sub b
        cpl
        add $10
        ldh [hCollision_enRight], a
        ; hCollision_enLeft = -(right-X) - $10
        ld a, [hl+]
        sub b
        cpl
        sub $10
        ldh [hCollision_enLeft], a
    .endIf_B:
    ; Note: By this point, the enemy's hitbox will be extended
    ;  by 16 pixels in all 4 directions

    ; Bottom - Top
    ldh a, [hCollision_enTop]
    ld b, a
    ldh a, [hCollision_enBottom]
    sub b
    ld c, a
    ; Y - Top
    ldh a, [hTemp.a] ; bombY
    sub b
    ; exit if (Bottom - Top) <= (Y - Top)
    cp c
        jr nc, .exit_noHit

    ; Right - Left
    ldh a, [hCollision_enLeft]
    ld b, a
    ldh a, [hCollision_enRight]
    sub b
    ld c, a
    ; X - Left
    ldh a, [hTemp.b] ; bombX
    sub b
    ; exit if (Right - Left) <= (X - Left)
    cp c
        jr nc, .exit_noHit

; A collision happened
    ; Save the weapon type
    ld a, $09
    ld [collision_weaponType], a
    ; pop the enemy base address off the stack
    pop hl
    ; Save the base address of the hit enemy
    ld a, l
    ld [collision_pEnemyLow], a
    ld a, h
    ld [collision_pEnemyHigh], a
    ; This code appears to rely on other code defaulting the weapon direction to $FF by default

; Special Queen logic {
    ; If the Queen's mouth is closed with Samus inside
    ld a, [queen_eatingState]
    cp $03
    jr nz, .endIf_C
        ; and if the left half of her head just got bombed
        ldh a, [hCollision_enSprite]
        cp QUEEN_ACTOR_HEAD_LEFT ; $F1
        jr nz, .endIf_C
            ; Release Samus from the mouth
            ld a, $04
            ld [queen_eatingState], a
    .endIf_C:

    ; If Samus is swallowed by the Queen
    ld a, [queen_eatingState]
    cp $06
    jr nz, .endIf_D
        ; And her main body (stomach) just got bombed
        ldh a, [hCollision_enSprite]
        cp QUEEN_ACTOR_BODY ; $F3
        jr nz, .endIf_D
            ; Then eject Samus from the Queen
            ld a, $07
            ld [queen_eatingState], a
            ld a, pose_outStomach ; $1C
            ld [samusPose], a
    .endIf_D: ;}
    
    ; A collision happened - set the carry flag
    scf
ret

.exit_noHit:
    ; pop the enemy base address off the stack
    pop hl
    ; Clear the carry flag
    scf
    ccf
ret ;}

; Beams/missiles
collision_projectileEnemies: ;{ 00:31B6 - Projectile/enemy collision function
    ; Convert projectile coordinates to camera-space
    ; beamY-scrollY
    ld a, [scrollY]
    ld b, a
    ld a, [tileY]
    sub b
    ldh [hTemp.a], a
    ; beamX-scrollX
    ld a, [scrollX]
    ld b, a
    ld a, [tileX]
    sub b
    ldh [hTemp.b], a

    ; Switch bank for callee's sake
    switchBank enemyHitboxPointers ; and enemyDamageTable

    ; Iterate through enemy slots
    ld hl, enemyDataSlots ;$C600
    .loop:
        ; Check if enemy is active ($x0 status value)
        ld a, [hl]
        and $0f
        jr nz, .endIf
            ; If so, check collision
            call collision_projectileOneEnemy
            ; Exit if a collision occurred
            jr c, .break
        .endIf:
        ; Iterate to next enemy
        ld de, ENEMY_SLOT_SIZE ; $0020
        add hl, de
        ; Exit loop if at end of enemy slots
        ld a, h
        cp HIGH(enemyDataSlots.end) ;$c8
    jr nz, .loop
    .break:
    
    ; Switch to bank of caller function
    switchBank handleProjectiles
ret ;}

; Projectile-enemy single collision (beams/missile)
collision_projectileOneEnemy: ;{ 00:31F1
    ; push the enemy base address on the stack
    push hl
    inc hl ; Iterate HL past enemy status byte
    
    ; Load enemy Y, and skip collision if offscreen
    ld a, [hl+]
    cp $e0
        jp nc, .exit_noHit
    ldh [hCollision_enY], a
    ; Load enemy X, and skip collision if offscreen
    ld a, [hl+]
    cp $e0
        jp nc, .exit_noHit
    ldh [hCollision_enX], a
    
    ; Load enemy sprite type
    ld a, [hl+]
    ldh [hCollision_enSprite], a
    ; Load enemy attributes
    inc hl
    ld a, [hl]
    ldh [hCollision_enAttr], a

    ; Exit if enemy damage is zero
    ldh a, [hCollision_enSprite]
    ld e, a
    ld d, $00
    ld hl, enemyDamageTable
    add hl, de
    ld a, [hl]
    and a
        jp z, .exit_noHit

    ; Load hitbox pointer of enemy
    ldh a, [hCollision_enSprite]
    sla a
    ld e, a
    ld d, $00
    rl d
    ld hl, enemyHitboxPointers
    add hl, de
    ; Load pointer to HL
    ld a, [hl+]
    ld e, a
    ld a, [hl]
    ld h, a
    ld l, e
    
    ; Save enY to B
    ldh a, [hCollision_enY]
    ld b, a
    ; Check if vertically flipped
    ldh a, [hCollision_enAttr]
    bit OAMB_YFLIP, a
    jr nz, .else_A
        ; Normal case
        ; hCollision_enTop = top+Y
        ld a, [hl+]
        add b
        ldh [hCollision_enTop], a
        ; hCollision_enBottom = bottom+Y
        ld a, [hl+]
        add b
        ldh [hCollision_enBottom], a
        jr .endIf_A
    .else_A:
        ; Vertically flipped case
        ; hCollision_enBottom = -(top-Y)
        ld a, [hl+]
        sub b
        cpl
        ldh [hCollision_enBottom], a
        ; hCollision_enTop = -(bottom-Y)
        ld a, [hl+]
        sub b
        cpl
        ldh [hCollision_enTop], a
    .endIf_A:

    ; Save enX to B
    ldh a, [hCollision_enX]
    ld b, a
    ; Check if horizontally flipped
    ldh a, [hCollision_enAttr]
    bit OAMB_XFLIP, a
    jr nz, .else_B
        ; Normal case
        ; hCollision_enLeft = left+X
        ld a, [hl+]
        add b
        ldh [hCollision_enLeft], a
        ; hCollision_enRight = right+X
        ld a, [hl+]
        add b
        ldh [hCollision_enRight], a
        jr .endIf_B
    .else_B:
        ; Horizontally flipped case
        ; hCollision_enRight = -(left-X)
        ld a, [hl+]
        sub b
        cpl
        ldh [hCollision_enRight], a
        ; hCollision_enLeft = -(right-X)
        ld a, [hl+]
        sub b
        cpl
        ldh [hCollision_enLeft], a
    .endIf_B:

    ; Bottom - Top
    ldh a, [hCollision_enTop]
    ld b, a
    ldh a, [hCollision_enBottom]
    sub b
    ld c, a
    ; beamY - Top
    ldh a, [hTemp.a] ; beamY
    sub b
    ; exit if (Bottom - Top) <= (Y - Top)
    cp c
        jr nc, .exit_noHit
    ; Right - Left
    ldh a, [hCollision_enLeft]
    ld b, a
    ldh a, [hCollision_enRight]
    sub b
    ld c, a
    ; beamX - Left
    ldh a, [hTemp.b] ; beamX
    sub b
    ; exit if (Right - Left) <= (X - Left)
    cp c
        jr nc, .exit_noHit
        
; A collision happened
    ; Save weapon type
    ld a, [weaponType]
    ld [collision_weaponType], a
    ; pop the enemy base address off the stack
    pop hl
    ; Save base address of enemy
    ld a, l
    ld [collision_pEnemyLow], a
    ld a, h
    ld [collision_pEnemyHigh], a
    ; Save weapon direction
    ld a, [weaponDirection]
    ld [collision_weaponDir], a

; Special Queen Logic {
    ; If the weapon was missiles
    ld a, [weaponType]
    cp $08
    jr nz, .endIf_C
        ; And if we hit the Queen's open mouth
        ldh a, [hCollision_enSprite]
        cp QUEEN_ACTOR_MOUTH_OPEN ; $F6
        jr nz, .endIf_C
            ; Then paralyze the Queen
            ld a, $10
            ld [queen_eatingState], a
    .endIf_C: ;}
    
    ; A collision happened -- set the carry flag
    scf
ret

.exit_noHit:
    ; pop the enemy base address off the stack
    pop hl
    ; Clear the carry flag
    scf
    ccf
ret ;}

; Note: Function has two entry points
collision_samusEnemies: ;{ 00:32AB - Samus enemy collision detection loop
    .standard: 
        ; Conditions for skipping collision processing
        ; Exit if being eaten
        ld a, [samusPose]
        cp pose_beingEaten ; $18
            jp nc, collision_exitNoHit
        ; Exit if dying
        ld a, [deathFlag]
        and a
            jp nz, collision_exitNoHit
        ; Exit if in i-frames
        ld a, [samusInvulnerableTimer]
        and a
            jp nz, collision_exitNoHit
        ; Exit if this function has already been called this frame
        ld a, [samusSpriteCollisionProcessedFlag]
        and a
            jp nz, collision_exitNoHit
        
        ; Set tempX to Samus' onscreen X position
        ld a, [samus_onscreenXPos]
        ldh [hTemp.b], a
        jr .start
        
    .horizontal: ; 00:32CF - Samus horizontal collision
        ; Conditions for skipping collision processing
        ; Exit if being eaten
        ld a, [samusPose]
        cp pose_beingEaten ; $18
            jp nc, collision_exitNoHit
        ; Exit if dying
        ld a, [deathFlag]
        and a
            jp nz, collision_exitNoHit
        ; Exit if dying
        ld a, [deathAnimTimer]
        and a
            jp nz, collision_exitNoHit
        ; Exit if in i-frames
        ld a, [samusInvulnerableTimer]
        and a
            jp nz, collision_exitNoHit
        ; Note: This entry point does not check samusSpriteCollisionProcessedFlag
        
        ; Set tempX to Samus' postion in camera-space
        ldh a, [hCameraXPixel]
        ld b, a
        ld a, [tileX]
        sub b
        add $50
        ldh [hTemp.b], a
.start:
    ; Set tempY to Samus' postion in camera-space
    ldh a, [hCameraYPixel]
    ld b, a
    ldh a, [hSamusYPixel]
    sub b
    add $48 + $1A ; $62 - This breakdown doesn't seem quite right
    ldh [hTemp.a], a
    
    ; Switch to bank with enemy hitboxes
    switchBank enemyHitboxPointers ; $03
    
    ; Set flag to indicate this function has been entered
    ld a, $ff
    ld [samusSpriteCollisionProcessedFlag], a
    
    ; Iterate through all enemy slots
    ld hl, enemyDataSlots ;$C600
    .loop:
        ; Check if enemy is active ($x0 status value)
        ld a, [hl]
        and $0f
        jr nz, .endIf
            ; Exit if we made a collision
            call collision_samusOneEnemy
            ret c
        .endIf:
        ; Iterate to next enemy
        ld de, ENEMY_SLOT_SIZE ; $0020
        add hl, de
        ; Exit if we finished all enemies
        ld a, h
        cp HIGH(enemyDataSlots.end) ; $C8
    jr nz, .loop
ret ;}

; Samus vs. Single Enemy Collision
collision_samusOneEnemy: ;{ 00:3324
    ; push the enemy base address on the stack
    push hl
    ; Load enemy Y, exit if offscreen
    inc hl
    ld a, [hl+]
    cp $e0
        jp nc, .exit_noHit
    ldh [hCollision_enY], a
    ; Load enemy X, exit if offscreen
    ld a, [hl+]
    cp $e0
        jp nc, .exit_noHit
    ldh [hCollision_enX], a
    
    ; Load enemy sprite type
    ld a, [hl+]
    ldh [hCollision_enSprite], a
    
    ; Load enemy attributes
    inc hl
    ld a, [hl+]
    ldh [hCollision_enAttr], a
    
    ; Load enemy ice counter
    inc hl
    inc hl
    inc hl
    inc hl
    inc hl
    ld a, [hl]
    ldh [hCollision_enIce], a
    
    ; Get hitbox pointer of enemy
    ldh a, [hCollision_enSprite]
    sla a
    ld e, a
    ld d, $00
    rl d
    ld hl, enemyHitboxPointers
    add hl, de
    ; Load pointer to HL
    ld a, [hl+]
    ld e, a
    ld a, [hl]
    ld h, a
    ld l, e
    
    ; Save enY to B
    ldh a, [hCollision_enY]
    ld b, a
    ; Check if vertically flipped
    ldh a, [hCollision_enAttr]
    bit OAMB_YFLIP, a
    jr nz, .else_A
        ; Normal case
        ; hCollision_enTop = (top+Y) - $11
        ld a, [hl+]
        add b
        sub $11
        ldh [hCollision_enTop], a
        ; hCollision_enBottom = (bottom+Y) - $04
        ld a, [hl+]
        add b
        sub $04
        ldh [hCollision_enBottom], a
        jr .endIf_A
    .else_A:
        ; Vertically flipped case
        ; hCollision_enBottom = -(bottom-Y) + $04
        ld a, [hl+]
        sub b
        cpl
        sub $04
        ldh [hCollision_enBottom], a
        ; hCollision_enTop = -(bottom-Y) - $11
        ld a, [hl+]
        sub b
        cpl
        sub $11
        ldh [hCollision_enTop], a
    .endIf_A:
    
    ; Save enX to B
    ldh a, [hCollision_enX]
    ld b, a
    ; Check if horizontally flipped
    ldh a, [hCollision_enAttr]
    bit OAMB_XFLIP, a
    jr nz, .else_B
        ; Normal case
        ; hCollision_enLeft = (left+X) - $05
        ld a, [hl+]
        add b
        sub $05
        ldh [hCollision_enLeft], a
        ; hCollision_enRight = (right+X) + $05
        ld a, [hl+]
        add b
        add $05
        ldh [hCollision_enRight], a
        jr .endIf_B
    .else_B:
        ; Horizontally flipped case
        ; hCollision_enRight = -(left-X) + $05
        ld a, [hl+]
        sub b
        cpl
        add $05
        ldh [hCollision_enRight], a
        ; hCollision_enLeft = -(right-X) - $05
        ld a, [hl+]
        sub b
        cpl
        sub $05
        ldh [hCollision_enLeft], a
    .endIf_B:

    ; Load top offset for Samus' hitbox
    ld a, [samusPose]
    and $7f
    ld e, a
    ld d, $00
    ld hl, collision_samusSpriteHitboxTopTable
    add hl, de
    ld a, [hl+]
    ; Bottom = Bottom - Samus' Top
    ld b, a
    ldh a, [hCollision_enBottom]
    sub b
    ldh [hCollision_enBottom], a
    ; Bottom - Top
    ldh a, [hCollision_enTop]
    ld b, a
    ldh a, [hCollision_enBottom]
    sub b
    ld c, a
    ; Samus Y - Top
    ldh a, [hTemp.a]
    sub b
    ; exit if (Bottom - Top) <= (Y - Top)
    cp c
        jp nc, .exit_noHit
    
    ; Set default damage boost direction (right)
    ld a, $01
    ld [samus_damageBoostDirection], a
    
    ; Samus X - Left
    ldh a, [hCollision_enLeft]
    ld b, a
    ldh a, [hTemp.b]
    sub b
    ld c, a
    ; Right - Left
    ldh a, [hCollision_enRight]
    sub b
    ld d, a
    ; D = (R - L)/2 (center of the hitbox)
    srl d
    ; exit if (Right - Left) <= (X - Left)
    sub c
        jp c, .exit_noHit
    
; A collision has happened
    ; If Samus was on the left side of the enemy
    ; (checks if (Samus X - Left < half the width of the hitbox)
    ld a, d
    cp c
    jr c, .endIf_C
        ; If so, change the damage boost value to the left
        ld a, $ff
        ld [samus_damageBoostDirection], a
    .endIf_C:

    ; Check if screw attack is active
    ld a, [samusItems]
    bit itemBit_screw, a
        jr z, .iceCase
    ld a, [samusPose]
    cp pose_spinJump
        jr z, .screwCase
    ld a, [samusPose]
    cp pose_spinStart
        jr nz, .iceCase

.screwCase: ; { Screw is active
    ; Don't screw if ice counter is greater than zero and even
    ldh a, [hCollision_enIce]
    and a
    jr z, .endIf_D
        bit 0, a
        jr z, .solidCase
    .endIf_D:

    ; Load enemy's damage from table
    ldh a, [hCollision_enSprite]
    ld e, a
    ld d, $00
    ld hl, enemyDamageTable
    add hl, de
    ld a, [hl]
    
    ; Don't screw if damage is $FF (enemy is solid)
    cp $ff
        jr z, .solidCase
    
    ; Screw attack the enemy
    ; Save the damage value (unnecessary)
    ld [samus_damageValue], a
    ; Hurt flag is not set here, so Samus will not be damaged by this
    
    ; pop the enemy base address off the stack
    pop hl
    
    ; Save weapon type to Screw Attack
    ld a, $10
    ld [collision_weaponType], a
    ; Save enemy base pointer
    ld a, l
    ld [collision_pEnemyLow], a
    ld a, h
    ld [collision_pEnemyHigh], a
    
    ; Clear carry flag (no solid collision occurred)
    scf
    ccf
ret ;}

.iceCase:
    ; Assume enemy is not solid if not frozen (ice == 0)
    ldh a, [hCollision_enIce]
    and a
        jr z, .hurtCase
.solidCase: ;{
    ; pop the enemy base address off the stack
    pop hl
    ; Note: the caller is expected to save the enemy address, etc. in this case (why?)
    
    ; Special Queen logic {
    ; Check if touching the queen's stunned mouth
    ldh a, [hCollision_enSprite]
    cp QUEEN_ACTOR_MOUTH_STUNNED ; $F7
    jr nz, .endIf_E
        ; Check if Samus' pose is (morph OR morphJump OR morphFall)
        ld a, [samusPose]
        cp pose_morph
            jr z, .then
        cp pose_morphJump
            jr z, .then
        cp pose_morphFall
            jr nz, .endIf_E
        .then:
            ; Set state to Samus entering the Queen's mouth
            ld a, $01
            ld [queen_eatingState], a
            ; Set pose
            ld a, pose_beingEaten ; $18
            ld [samusPose], a
    .endIf_E: ;}
    ; Set carry flag (to indicate a solid collision)
    scf
ret ;}

.hurtCase: ;{
    ; Load damage value for sprite
    ldh a, [hCollision_enSprite]
    ld e, a
    ld d, $00
    ld hl, enemyDamageTable
    add hl, de
    ld a, [hl]
    
    ; Check if enemy is solid
    cp $ff
        jr z, .solidCase
    ; Check if enemy drains health
    cp $fe
        jr z, .healthDrain
    ; Check if enemy is intangible (damage == 0)
    and a
        jr z, .touchNoDamage
    
    ; Save damage value
    ld [samus_damageValue], a
    ; Actually hurt Samus
    ld a, $01
    ld [samus_hurtFlag], a
    
    ; pop the enemy base address off the stack
    pop hl
    
    ; Save the enemy base address
    ld a, l
    ld [collision_pEnemyLow], a
    ld a, h
    ld [collision_pEnemyHigh], a
    ; Set "weapon" type to touch
    ld a, $20
    ld [collision_weaponType], a
    
    ; Set the carry flag (a solid collision occurred)
    scf
ret ;}

.healthDrain:
    ; Drain health
    call applyDamage.larvaMetroid
.touchNoDamage:
    ; pop the enemy base address off the stack
    pop hl
    ; Save the enemy base address
    ld a, l
    ld [collision_pEnemyLow], a
    ld a, h
    ld [collision_pEnemyHigh], a
    ; Set "weapon" type to touch
    ld a, $20
    ld [collision_weaponType], a
    ; Clear carry flag (no solid collision occurred)
    scf
    ccf
ret

; Exit that clears the carry flag (indicates no collision happened)
.exit_noHit:
    ; pop the enemy base address off the stack
    pop hl
    ; Clear carry flag (no solid collision occurred)
    scf
    ccf
ret ;}

; Samus-sprite downward collision loop
collision_samusEnemiesDown: ;{ 00:348D
    ; Conditions for skipping collision processing
    ; Exit if being eaten
    ld a, [samusPose]
    cp pose_beingEaten ; $18
        jp nc, collision_exitNoHit
    ; Exit if dying
    ld a, [deathFlag]
    and a
        jp nz, collision_exitNoHit
    ; Exit if in i-frames
    ld a, [samusInvulnerableTimer]
    and a
        jp nz, collision_exitNoHit

    ; Set tempY based on Samus' onscreen Y position
    ld a, [samus_onscreenYPos]
    add $12
    ldh [hTemp.a], a
    
    ; Clear flag
    xor a
    ld [samus_onSolidSprite], a
    
    ; Set tempX to Samus' position in camera-space
    ldh a, [hCameraXPixel]
    ld b, a
    ldh a, [hSamusXPixel]
    sub b
    add $60
    ldh [hTemp.b], a
    
    ; Switch to bank with enemy hitboxes
    switchBank enemyHitboxPointers ; $03
    
    ; Iterate through all enemy slots
    ld hl, enemyDataSlots ;$C600
    .loop:
        ; Check if enemy is active ($x0 status value)
        ld a, [hl]
        and $0f
        jr nz, .endIf_A
            ; Do collision check
            call collision_samusOneEnemyVertical
            jr nc, .endIf_A
                ; If collision occured, check if enemy damage was either $00 or $FF
                ld a, [samus_damageValue]
                dec a
                cp $fe
                jr c, .endIf_B
                    ; Subtract vertical distance between enemy's top and Samus
                    ;  from Samus's Y position
                    ldh a, [hTemp.c]
                    ld b, a
                    ldh a, [hSamusYPixel]
                    sub b
                    ldh [hSamusYPixel], a
                    ldh a, [hSamusYScreen]
                    sbc $00
                    ldh [hSamusYScreen], a
                .endIf_B:
                ; Set carry flag (to indicate a solid collision occurred)
                scf
                ; Exit since a collision was made
                ret
            .endIf_A:
        
        ; Iterate to next enemy
        ld de, ENEMY_SLOT_SIZE ; $0020
        add hl, de
        ; Exit if we finished all enemies
        ld a, h
        cp HIGH(enemyDataSlots.end) ; $C8
    jr nz, .loop
ret ;}

; A Samus-sprite upward collision loop
collision_samusEnemiesUp: ;{ 00:34EF
    ; Conditions for skipping collision processing
    ; Exit if being eaten
    ld a, [samusPose]
    cp pose_beingEaten ; $18
        jp nc, collision_exitNoHit
    ; Exit if dying
    ld a, [deathFlag]
    and a
        jp nz, collision_exitNoHit
    ; Exit if in i-frames
    ld a, [samusInvulnerableTimer]
    and a
        jp nz, collision_exitNoHit

    ; Load top offset for Samus' hitbox
    ld a, [samusPose]
    and $7f ; Mask out turnaround bit
    ld e, a
    ld d, $00
    ld hl, collision_samusSpriteHitboxTopTable
    add hl, de
    ld a, [hl+]
    
    ; Set tempY based on Samus' onscreen Y position
    ld b, a
    ld a, [samus_onscreenYPos]
    add b
    ldh [hTemp.a], a
    
    ; Clear flag
    xor a
    ld [samus_onSolidSprite], a
    
    ; Set tempX to Samus' position in camera-space
    ldh a, [hCameraXPixel]
    ld b, a
    ldh a, [hSamusXPixel]
    sub b
    add $60
    ldh [hTemp.b], a
    
    ; Switch to bank with enemy hitboxes
    switchBank enemyHitboxPointers ; $03
    
    ; Iterate through all enemy slots
    ld hl, enemyDataSlots ;$C600
    .loop:
        ; Check if enemy is active ($x0 status value)
        ld a, [hl]
        and $0f
        jr nz, .endIf
            ; Exit if a collision is made
            call collision_samusOneEnemyVertical
            ret c
        .endIf:
        
        ; Iterate to next enemy
        ld de, ENEMY_SLOT_SIZE ; $0020
        add hl, de
        ; Exit if we finished all enemies
        ld a, h
        cp HIGH(enemyDataSlots.end) ; $C8
    jr nz, .loop
ret ;}

; Samus-sprite vertical collision detection
collision_samusOneEnemyVertical: ;{ 00:3545
    ; push the enemy base address on the stack
    push hl
    ; Load enemy Y, exit if offscreen
    inc hl
    ld a, [hl+]
    cp $e0
        jp nc, .exit_noHit
    ldh [hCollision_enY], a
    ; Load enemy X, exit if offscreen
    ld a, [hl+]
    cp $e0
        jp nc, .exit_noHit
    ldh [hCollision_enX], a
    
    ; Load enemy sprite type
    ld a, [hl+]
    ldh [hCollision_enSprite], a
    
    ; Load enemy attributes
    inc hl
    ld a, [hl+]
    ldh [hCollision_enAttr], a
    
    ; Load enemy ice counter
    inc hl
    inc hl
    inc hl
    inc hl
    inc hl
    ld a, [hl]
    ldh [hCollision_enIce], a
    
    ; Get hitbox pointer of enemy
    ldh a, [hCollision_enSprite]
    sla a
    ld e, a
    ld d, $00
    rl d
    ld hl, enemyHitboxPointers
    add hl, de
    ; Load pointer to HL
    ld a, [hl+]
    ld e, a
    ld a, [hl]
    ld h, a
    ld l, e
    
    ; Save enY to B
    ldh a, [hCollision_enY]
    ld b, a
    ; Check if vertically flipped
    ldh a, [hCollision_enAttr]
    bit OAMB_YFLIP, a
    jr nz, .else_A
        ; Normal case
        ; hCollision_enTop = (top+Y)
        ld a, [hl+]
        add b
        ldh [hCollision_enTop], a
        ; hCollision_enBottom = (bottom+Y)
        ld a, [hl+]
        add b
        ldh [hCollision_enBottom], a
        jr .endIf_A
    .else_A:
        ; Vertically flipped case
        ; hCollision_enBottom = -(bottom-Y)
        ld a, [hl+]
        sub b
        cpl
        ldh [hCollision_enBottom], a
        ; hCollision_enTop = -(bottom-Y)
        ld a, [hl+]
        sub b
        cpl
        ldh [hCollision_enTop], a
    .endIf_A:

    ; Save enX to B
    ldh a, [hCollision_enX]
    ld b, a
    ; Check if horizontally flipped
    ldh a, [hCollision_enAttr]
    bit OAMB_XFLIP, a
    jr nz, .else_B
        ; Normal case
        ; hCollision_enLeft = (left+X) - $05
        ld a, [hl+]
        add b
        sub $05
        ldh [hCollision_enLeft], a
        ; hCollision_enRight = (right+X) + $05
        ld a, [hl+]
        add b
        add $05
        ldh [hCollision_enRight], a
        jr .endIf_B
    .else_B:
        ; Horizontally flipped case
        ; hCollision_enRight = -(left-X) + $05
        ld a, [hl+]
        sub b
        cpl
        add $05
        ldh [hCollision_enRight], a
        ; hCollision_enLeft = -(right-X) - $05
        ld a, [hl+]
        sub b
        cpl
        sub $05
        ldh [hCollision_enLeft], a
    .endIf_B:
    
    ; Bottom - Top
    ldh a, [hCollision_enTop]
    ld b, a
    ldh a, [hCollision_enBottom]
    sub b
    ld c, a
    ; Samus Y - Top
    ldh a, [hTemp.a]
    sub b
    ldh [hTemp.c], a ; Save vertical distance
    ; exit if (Bottom - Top) <= (Y - Top)
    cp c
        jp nc, .exit_noHit
    
    ; Set default damage boost direction (right)
    ld a, $01
    ld [samus_damageBoostDirection], a
    
    ; Samus X - Left
    ldh a, [hCollision_enLeft]
    ld b, a
    ldh a, [hTemp.b]
    sub b
    ld c, a
    ; Right - Left
    ldh a, [hCollision_enRight]
    sub b
    ld d, a
    ; D = (R - L)/2 (center of the hitbox)
    srl d
    ; exit if (Right - Left) <= (X - Left)
    sub c
        jp c, .exit_noHit
    
; A collision has happened
    ; If Samus was on the left side of the enemy
    ; (checks if (Samus X - Left < half the width of the hitbox)
    ld a, d
    cp c
    jr c, .endIf_C
        ; If so, change the damage boost value to the left
        ld a, $ff
        ld [samus_damageBoostDirection], a
    .endIf_C:

    ; Check if screw attack is active
    ld a, [samusItems]
    bit itemBit_screw, a
        jr z, .iceCase
    ld a, [samusPose]
    cp pose_spinJump
        jr z, .screwCase
    ld a, [samusPose]
    cp pose_spinStart
        jr nz, .iceCase

.screwCase: ; { Screw is active
    ; Don't screw if ice counter is greater than zero and even
    ldh a, [hCollision_enIce]
    and a
    jr z, .endIf_D
        bit 0, a
        jr z, .solidCase
    .endIf_D:

    ; Load enemy's damage from table
    ldh a, [hCollision_enSprite]
    ld e, a
    ld d, $00
    ld hl, enemyDamageTable
    add hl, de
    ld a, [hl]
    
    ; Don't screw if damage is $FF (enemy is solid)
    cp $ff
        jr z, .solidCase
    
    ; Screw attack the enemy
    ; Save the damage value (unnecessary)
    ld [samus_damageValue], a
    ; Hurt flag is not set here, so Samus will not be damaged by this
    
    ; pop the enemy base address off the stack
    pop hl
    
    ; Save weapon type to Screw Attack
    ld a, $10
    ld [collision_weaponType], a
    ; Save enemy base pointer
    ld a, l
    ld [collision_pEnemyLow], a
    ld a, h
    ld [collision_pEnemyHigh], a
    ; Clear carry flag (no solid collision occurred)
    scf
    ccf
ret ;}

.iceCase:
    ; Assume enemy is not solid if not frozen (ice == 0)
    ldh a, [hCollision_enIce]
    and a
        jr z, .hurtCase
.solidCase: ;{
    ; pop the enemy base address off the stack
    pop hl
    ; Note: the caller is expected to save the enemy address, etc. in this case (why?)
    
    ; Special Queen logic {
    ; Check if touching the queen's stunned mouth
    ldh a, [hCollision_enSprite]
    cp QUEEN_ACTOR_MOUTH_STUNNED ; $F7
    jr nz, .endIf_E
        ; Check if Samus' pose is (morph OR morphJump OR morphFall)
        ld a, [samusPose]
        cp pose_morph
            jr z, .then
        cp pose_morphJump
            jr z, .then
        cp pose_morphFall
            jr nz, .endIf_E
        .then:
            ; Set state to Samus entering the Queen's mouth
            ld a, $01
            ld [queen_eatingState], a
            ; Set pose
            ld a, pose_beingEaten ; $18
            ld [samusPose], a
    .endIf_E: ;}
    ; Set carry flag (to indicate a solid collision)
    scf
ret ;}

.hurtCase: ;{
    ; Sprite 0 (tsumuri, horizontal frame 1) is solid? What?
    ldh a, [hCollision_enSprite]
    and a
        jr z, .solidCase

    ; Load damage value for sprite
    ld e, a
    ld d, $00
    ld hl, enemyDamageTable
    add hl, de
    ld a, [hl]
    
    ; Check if enemy is solid
    cp $ff
        jr z, .solidCase
    ; Check if enemy drains health
    cp $fe
        jr z, .healthDrain
    ; Check if enemy is intangible (damage == 0)
    and a
        jr z, .touchNoDamage

    ; Save damage value
    ld [samus_damageValue], a
    ; Actually hurt Samus
    ld a, $01
    ld [samus_hurtFlag], a
    
    ; pop the enemy base address off the stack
    pop hl
    
    ; Save the enemy base address
    ld a, l
    ld [collision_pEnemyLow], a
    ; Set "weapon" type to touch
    ld a, h
    ld [collision_pEnemyHigh], a
    ld a, $20
    ld [collision_weaponType], a
    
    ; Set the carry flag (a solid collision occurred)
    scf
ret ;}

.healthDrain:
    ; Drain health
    call applyDamage.larvaMetroid
.touchNoDamage:
    ; pop the enemy base address off the stack
    pop hl
    ; Save the enemy base address
    ld a, l
    ld [collision_pEnemyLow], a
    ld a, h
    ld [collision_pEnemyHigh], a
    ; Set "weapon" type to touch
    ld a, $20
    ld [collision_weaponType], a
    ; Clear carry flag (no solid collision occurred)
    scf
    ccf
ret

; Exit that clears the carry flag (indicates no collision happened)
.exit_noHit:
    ; pop the enemy base address off the stack
    pop hl
    ; Clear carry flag (no solid collision occurred)
    scf
    ccf
ret ;}

; Common exit for collision-loop routines that preemptively skip collision checks
collision_exitNoHit: ; { 00:3698
    ; We do not pop the enemy address 
    ; Clear carry flag (no solid collision occurred)
    scf
    ccf
ret ;}

collision_samusSpriteHitboxTopTable: ;{ 00:369B - Offset for the top of Samus's hitbox per pose (for sprite collisions)
    ; Table Generated from samus/samus.csv
    include "samus/samus_spriteHitboxTopTable.asm"
    ;}
;} end of sprite-sprite collision routines

gameMode_dead: ;{ 00:36B0
    ; Wait until the death sound ends
    .loopWaitSilence:
        call handleAudio_longJump
        call waitForNextFrame
        ld a, [sfxPlaying_noise]
        cp $0b
    jr z, .loopWaitSilence
    
    ; Clear flag
    xor a
    ld [queen_roomFlag], a
    
    ; Disable LCD to clear BGs, sprites, etc.
    call disableLCD
    call clearTilemaps
    xor a
    ldh [hOamBufferIndex], a
    call clearAllOam_longJump

    ; Load graphics for Game Over screen
    switchBank gfx_titleScreen
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

    ; Load game over text ($80-terminated)
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
    
    ; Reset scroll
    xor a
    ld [scrollY], a
    ld [scrollX], a
    ldh [rSCY], a
    ldh [rSCX], a
    ; Re-enable LCD
    ld a, $c3
    ld [gameOver_LCDC_copy], a
    ldh [rLCDC], a
    
    ; Set timer for Game Over screen
    ld a, $ff
    ld [countdownTimerLow], a
    ld a, $07
    ldh [gameMode], a
ret

gameOverText: ; 00:3711 - "GAME OVER"
    db $56, $50, $5c, $54, $ff, $5e, $65, $54, $61, $80
;}

; Reboot game if a certain amount of time has elapsed, or if start is pressed
gameMode_gameOver: ;{ 00:371B
    call handleAudio_longJump
    call waitForNextFrame
    ; Reboot once timer expires
    ld a, [countdownTimerLow]
    and a
    jr z, .reboot
        ; Or if start is pressed
        ldh a, [hInputRisingEdge]
        cp PADF_START
            ret nz
    .reboot:
jp bootRoutine ;}

;------------------------------------------------------------------------------
; Handle item pick-up
handleItemPickup: ;{ 00:372F
    ; Exit unless an item is being collected
    ; (a sprite actor will set this flag)
    ld a, [itemCollected]
    and a
        ret z
    ; Wait a few frames
    call waitOneFrame
    call waitOneFrame
    call waitOneFrame
    call waitOneFrame
    ; Set working copy of variable
    ld a, [itemCollected]
    ld [itemCollected_copy], a
    ld b, a
    ; Unused SFX
    ld a, $12
    ld [sfxRequest_square1], a
    ; Play item get jingle
    ld a, $01
    ld [songInterruptionRequest], a
    ; Set timer for duration of item get jingle
    ld a, $01
    ld [countdownTimerHigh], a
    ld a, $60
    ld [countdownTimerLow], a
    ld a, b
    cp $0d
    jr c, .endIf_A
        cp $0e
        jr nc, .else_B
            ; Play missile get jingle
            ld a, $05
            ld [songInterruptionRequest], a
            ; Set shorter timer
            xor a
            ld [countdownTimerHigh], a
            ld a, $60
            ld [countdownTimerLow], a
            jr .endIf_A
        .else_B:
            ; Refill branch
            ; Do not play jingle
            ld a, $00
            ld [songInterruptionRequest], a
            ; No delay
            ld [countdownTimerHigh], a
            ld [countdownTimerLow], a
            ld a, $0e
            ld [sfxRequest_square1], a
            jr z, .endIf_A
                ; Play sound effect
                ld a, $0c
                ld [sfxRequest_square1], a
    .endIf_A:

    ; Do not play jingle if earthquake sound is playing
    ld a, [songInterruptionPlaying]
    cp $0e
    jr nz, .endIf_C
        ld a, $00
        ld [songInterruptionRequest], a
    .endIf_C:

    ; Jump to pick-up specific routine
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
;}

; Item Pick-up Sub-routines {
pickup_plasmaBeam: ;{
    ; Set beam
    ld a, $04
    ld [samusBeam], a
    ; Load graphics
    ld hl, gfxInfo_plasma
    call loadGraphics
    ; Set to active weapon if missiles aren't active
    ld a, [samusActiveWeapon]
    cp $08
        jp z, handleItemPickup_end
    ld a, $04
    ld [samusActiveWeapon], a
    ld [samusBeam], a ; Redundant write
jp handleItemPickup_end ;}

gfxInfo_spazer: ; Free label for an enterprising modder
gfxInfo_plasma: db BANK(gfx_beamPlasma)
    dw gfx_beamPlasma, vramDest_beam, $0020

pickup_iceBeam: ;{
    ; Set beam
    ld a, $01
    ld [samusBeam], a
    ; Load graphics
    ld hl, gfxInfo_ice
    call loadGraphics
    ; Set to active weapon if missiles aren't active
    ld a, [samusActiveWeapon]
    cp $08
        jp z, handleItemPickup_end
    ld a, $01
    ld [samusActiveWeapon], a
    ld [samusBeam], a ; Redundant write
jp handleItemPickup_end ;}

gfxInfo_ice: db BANK(gfx_beamIce)
    dw gfx_beamIce, vramDest_beam, $0020

pickup_waveBeam: ;{
    ; Set beam
    ld a, $02
    ld [samusBeam], a
    ; Load graphics
    ld hl, gfxInfo_wave
    call loadGraphics
    ; Set to active weapon if missiles aren't active
    ld a, [samusActiveWeapon]
    cp $08
        jp z, handleItemPickup_end
    ld a, $02
    ld [samusActiveWeapon], a
    ld [samusBeam], a ; Redundant write
jp handleItemPickup_end ;}

gfxInfo_wave: db BANK(gfx_beamWave)
    dw gfx_beamWave, vramDest_beam, $0020

pickup_spazer: ;{
    ; Set beam
    ld a, $03
    ld [samusBeam], a
    ; Load graphics
    ld hl, gfxInfo_spazer ;gfxInfo_plasma
    call loadGraphics
    ; Set to active weapon if missiles aren't active
    ld a, [samusActiveWeapon]
    cp $08
        jp z, handleItemPickup_end
    ld a, $03
    ld [samusActiveWeapon], a
    ld [samusBeam], a ; Redundant write
jp handleItemPickup_end ;}

pickup_bombs: ;{
    ; Set item bit
    ld a, [samusItems]
    set itemBit_bomb, a
    ld [samusItems], a
jp handleItemPickup_end ;}

pickup_screwAttack: ;{
    ; Set item bit
    ld a, [samusItems]
    set itemBit_screw, a
    ld [samusItems], a
    ; Load appropriate graphics
    bit itemBit_space, a
    jr nz, .else
        ; No space jump
        ld hl, gfxInfo_spinScrewTop
        call loadGraphics
        ld hl, gfxInfo_spinScrewBottom
        call loadGraphics
        jp handleItemPickup_end
    .else:
        ; With space jump
        ld hl, gfxInfo_spinSpaceScrewTop
        call loadGraphics
        ld hl, gfxInfo_spinSpaceScrewBottom
        call loadGraphics
        jp handleItemPickup_end
;} end case

; VRAM Update Lists - 00:387A {
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
;}

pickup_variaSuit: ;{
    ; Wait for fanfare to expire
    .loop:
            call drawSamus_longJump ; Draw Samus
            call handleEnemiesOrQueen ; Handle enemies
            callFar drawHudMetroid
            call clearUnusedOamSlots_longJump ; Clear unused OAM entries
            ; Higher window position
            ld a, $80
            ldh [rWY], a
            call waitOneFrame
            ; Wait for countdown timer to expire
            ld a, [countdownTimerHigh]
            and a
        jr nz, .loop
        ld a, [countdownTimerLow]
        and a
    jr nz, .loop
    
    ; Set item bit
    ld a, [samusItems]
    set itemBit_varia, a
    ld [samusItems], a
    
    ; Make Samus face the screen
    ld a, $80
    ld [samusPose], a
    call drawSamus_longJump
    ; Set turnaround timer (for facing the screen)
    ld a, $10
    ld [samus_turnAnimTimer], a
    call waitOneFrame
    
    ; Play sound
    ld a, $1d
    ld [sfxRequest_square1], a
    
    ; Set flag for updating tiles varia-collection-style
    ld a, $ff
    ld [variaAnimationFlag], a
    ; Fancy loading animation (only loads first 5 rows)
    ld hl, gfxInfo_variaSuit
    call animateGettingVaria
    ; Clear flag
    xor a
    ld [variaAnimationFlag], a
    
    ; Load all the varia graphics
    ld hl, gfxInfo_variaSuit
    call loadGraphics
    ; Load cannon graphics if missiles are active
    ld hl, gfxInfo_cannonMissile
    ld a, [samusActiveWeapon]
    cp $08
        call z, loadGraphics
    ; Load all the other patched-in graphics
    call varia_loadExtraGraphics
jp handleItemPickup_end ;}

pickup_hiJump: ;{
    ; Set item bit
    ld a, [samusItems]
    set itemBit_hiJump, a
    ld [samusItems], a
jp handleItemPickup_end ;}

pickup_spaceJump: ;{
    ; Set item bit
    ld a, [samusItems]
    set itemBit_space, a
    ld [samusItems], a
    ; Load appropriate graphics
    bit itemBit_screw, a
    jr nz, .else
        ; No screw attack
        ld hl, gfxInfo_spinSpaceTop
        call loadGraphics
        ld hl, gfxInfo_spinSpaceBottom
        call loadGraphics
        jp handleItemPickup_end
    .else:
        ; With screw attack
        ld hl, gfxInfo_spinSpaceScrewTop
        call loadGraphics
        ld hl, gfxInfo_spinSpaceScrewBottom
        call loadGraphics
        jp handleItemPickup_end
;} end case

pickup_spiderBall: ;{
    ; Set item bit
    ld a, [samusItems]
    set itemBit_spider, a
    ld [samusItems], a
jp handleItemPickup_end ;}

pickup_springBall: ;{
    ; Set item bit
    ld a, [samusItems]
    set itemBit_spring, a
    ld [samusItems], a
    ; Load graphics
    ld hl, gfxInfo_springBallTop
    call loadGraphics
    ld hl, gfxInfo_springBallBottom
    call loadGraphics
jp handleItemPickup_end ;}

pickup_energyTank: ;{
    ; Check if energy tanks are at max
    ld a, [samusEnergyTanks]
    cp $05 ; Max Energy tanks
    jr z, .endIf
        ; Give another energy tank
        inc a
        ld [samusEnergyTanks], a
    .endIf:
    ; Set current health to max
    ld [samusCurHealthHigh], a
    ld a, $99
    ld [samusCurHealthLow], a
jr handleItemPickup_end ;}

pickup_energyRefill: ;{
    ; Set current health to max
    ld a, [samusEnergyTanks]
    ld [samusCurHealthHigh], a
    ld a, $99
    ld [samusCurHealthLow], a
jr handleItemPickup_end ;}

pickup_missileRefill: ;{
    ; Check if all metroids are dead
    ld a, [metroidCountReal]
    and a
    jr nz, .else
        ; Prep the credits prep
        ; Set countdown timer for fadeout
        ld a, $ff
        ld [countdownTimerLow], a
        ; Play sound
        ld a, $08
        ld [songInterruptionRequest], a
        ; Set game mode to prep credits
        ld a, $12
        ldh [gameMode], a
        ret
    .else:
        ; Set current missiles to max
        ld a, [samusMaxMissilesLow]
        ld [samusCurMissilesLow], a
        ld a, [samusMaxMissilesHigh]
        ld [samusCurMissilesHigh], a
jr handleItemPickup_end ;}

pickup_missileTank: ;{
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
    jr c, .endIf
        ld a, $99
        ld [samusMaxMissilesLow], a
        ld a, $09
        ld [samusMaxMissilesHigh], a
    .endIf:
    
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
    jr c, handleItemPickup_end
        ld a, $99
        ld [samusCurMissilesLow], a
        ld a, $09
        ld [samusCurMissilesHigh], a
    jr handleItemPickup_end
;} end case
;}

; Common routine for all pickups
handleItemPickup_end: ;{ 00:3A01
    .waitLoop_A:
            ; Perform some common routines during this wait loop
            call drawSamus_longJump
            call drawHudMetroid_longJump
            callFar enemyHandler
            call handleAudio_longJump
            call clearUnusedOamSlots_longJump
            ; Show window if a major item
            ld a, [itemCollected_copy]
            cp $0b
            jr nc, .endIf_A
                ld a, $80
                ldh [rWY], a
            .endIf_A:
            ; Wait for countdown to end
            call waitForNextFrame
            ld a, [countdownTimerHigh]
            and a
        jr nz, .waitLoop_A
        ld a, [countdownTimerLow]
        and a
    jr nz, .waitLoop_A

    ; Check if this is not a refill
    ld a, [itemCollected_copy]
    cp $0e
    jr nc, .endIf_B
        ; End isolated sound effect (as long as it's not the earthquake)
        ld a, [songInterruptionPlaying]
        cp $0e
        jr z, .endIf_B
            ld a, $03
            ld [songInterruptionRequest], a
    .endIf_B:
    ; Clear flag
    xor a
    ld [itemCollected_copy], a
    ; Signal to item object that this sequence is completed
    ld a, $03
    ld [itemCollectionFlag], a
    
    ; Set collision variables
    ld a, [itemOrb_collisionType]
    ld [enSprCollision.weaponType], a
    ld a, [itemOrb_pEnemyWramLow]
    ld [enSprCollision.pEnemyLow], a
    ld a, [itemOrb_pEnemyWramHigh]
    ld [enSprCollision.pEnemyHigh], a

    .waitLoop_B:
        ; Perform common functions during this wait loop
        call drawSamus_longJump
        call drawHudMetroid_longJump
        call collision_samusEnemies.standard
        callFar enemyHandler
        call handleAudio_longJump
        call clearUnusedOamSlots_longJump
        call waitForNextFrame
        ; Wait until the item deletes itself
        ld a, [itemCollectionFlag]
        and a
    jr nz, .waitLoop_B
ret ;}

; Called by the Varia Suit collection routine
varia_loadExtraGraphics: ;{ 00:3A84
    ; Load spring ball graphics if applicable
    ld a, [samusItems]
    bit itemBit_spring, a
    jr z, .endIf_spring
        ld hl, gfxInfo_springBallTop
        call loadGraphics
        ld hl, gfxInfo_springBallBottom
        call loadGraphics
    .endIf_spring:

    ; Load appropriate spin-jump graphics
    ; (3 options, mutually exclusive)
    ld a, [samusItems]
    and itemMask_space | itemMask_screw
    cp itemMask_space | itemMask_screw
    jr nz, .endIf_spinBoth
        ; Both space jump and screw attack
        ld hl, gfxInfo_spinSpaceScrewTop
        call loadGraphics
        ld hl, gfxInfo_spinSpaceScrewBottom
        call loadGraphics
        ret
    .endIf_spinBoth:

    cp itemMask_space
    jr nz, .endIf_space
        ; Only space jump
        ld hl, gfxInfo_spinSpaceTop
        call loadGraphics
        ld hl, gfxInfo_spinSpaceBottom
        call loadGraphics
        ret
    .endIf_space:
    
    cp itemMask_screw
        ret nz
    ; Only screw attack
    ld hl, gfxInfo_spinScrewTop
    call loadGraphics
    ld hl, gfxInfo_spinScrewBottom
    call loadGraphics
ret ;}

; Game modes $0A and $0F
;  Displays "GAME SAVED" screen (incorrectly)
gameMode_unusedA: ;{ 00:3ACE
    ; Clear sound, graphics, etc.
    call silenceAudio_longJump
    ld a, $ff
    ld [sfxRequest_lowHealthBeep], a
    call disableLCD
    call clearTilemaps
    xor a
    ldh [hOamBufferIndex], a
    call clearAllOam_longJump
    
    ; Load graphics (badly)
    switchBank gfx_titleScreen
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

    ; Load $80-terminated string
    ld hl, gameSavedText
    ld de, $9800 + (8*$20) + $5 ; Tilemap address for text destination
    .loadTextLoop:
        ld a, [hl+]
        cp $80
            jr z, .break
        ld [de], a
        inc de
    jr .loadTextLoop
    .break:

    ; Reset camera
    xor a
    ld [scrollY], a
    ld [scrollX], a
    ; Enable LCD
    ld a, $c3
    ldh [rLCDC], a
    ; Set countdown timer
    ld a, $a0
    ld [countdownTimerLow], a
    ld a, $01 ; Game mode $F doesn't even read this
    ld [countdownTimerHigh], a
    ; Set game mode
    ld a, $0f
    ldh [gameMode], a
ret

gameSavedText: ; 00:3B24 - "GAME SAVED"
    db $56, $50, $5C, $54, $FF, $62, $50, $65, $54, $53, $80

gameMode_unusedB: ; 00:3B2F
    call handleAudio_longJump
    ; Wait for timer to expire
    call waitForNextFrame
    ld a, [countdownTimerLow]
    and a
    jr z, .reboot
        ; Reboot if start is pressed
        ldh a, [hInputRisingEdge]
        cp PADF_START
            ret nz
    .reboot:
jp bootRoutine
;}

; Game modes $10 and $11
;  Displays "GAME CLEARED" screen
gameMode_unusedC: ;{ 00:3B43
    ; Clear sound, graphics, etc.
    call silenceAudio_longJump
    ld a, $ff
    ld [sfxRequest_lowHealthBeep], a
    call disableLCD
    call clearTilemaps
    xor a
    ldh [hOamBufferIndex], a
    call clearAllOam_longJump

    ; Load CHR data
    switchBank gfx_titleScreen
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

    ; Load $80-terminated string
    ld hl, gameClearedText
    ld de, $9800 + (8*$20) + $4 ; Tilemap address for text
    .loadTextLoop:
        ld a, [hl+]
        cp $80
            jr z, .break
        ld [de], a
        inc de
    jr .loadTextLoop
    .break:

    ; Reset camera
    xor a
    ld [scrollY], a
    ld [scrollX], a
    ; Enable LCD
    ld a, $c3
    ldh [rLCDC], a
    ; Set timer and game mode
    ld a, $ff
    ld [countdownTimerLow], a
    ld a, $11
    ldh [gameMode], a
ret

gameClearedText: ; 00:3B94 - "GAME CLEARED"
    db $56, $50, $5C, $54, $FF, $52, $5B, $54, $50, $61, $54, $53, $80

gameMode_unusedD: ; 00:3BA1
    ; call handleAudio_longJump ; This ain't called here
    call waitForNextFrame
    ld a, [countdownTimerLow]
    and a
    jr z, .reboot
        ; Reboot if start is pressed
        ldh a, [hInputRisingEdge]
        cp PADF_START
            ret nz
    .reboot:
    ; The other two routines like this do this instead: jp bootRoutine
    ld a, $00
    ldh [gameMode], a
ret
;}

; Loads graphics depending on Samus' loadout
loadGame_samusItemGraphics: ;{ 00:3BB4
    ; Load Varia first before other graphics are patched in
    ld a, [samusItems]
    bit itemBit_varia, a
    jr z, .endIf_varia
        ld hl, gfxInfo_variaSuit
        call loadGame_copyItemToVram
    .endIf_varia:
    
    ld a, [samusItems]
    bit itemBit_spring, a
    jr z, .endIf_spring
        ld hl, gfxInfo_springBallTop
        call loadGame_copyItemToVram
        ld hl, gfxInfo_springBallBottom
        call loadGame_copyItemToVram
    .endIf_spring:
    
    ; Load spin jump graphics depending on space jump and screw attack
    ld a, [samusItems]
        and itemMask_space | itemMask_screw
        cp itemMask_space | itemMask_screw
        jr nz, .endIf_spinBoth
            ld hl, gfxInfo_spinSpaceScrewTop
            call loadGame_copyItemToVram
            ld hl, gfxInfo_spinSpaceScrewBottom
            call loadGame_copyItemToVram
            jr .endSpinBranch
        .endIf_spinBoth:
        
        cp itemMask_space
        jr nz, .endIf_space
            ld hl, gfxInfo_spinSpaceTop
            call loadGame_copyItemToVram
            ld hl, gfxInfo_spinSpaceBottom
            call loadGame_copyItemToVram
            jr .endSpinBranch
        .endIf_space:
    
        cp itemMask_screw
        jr nz, .endIf_screw
            ld hl, gfxInfo_spinScrewTop
            call loadGame_copyItemToVram
            ld hl, gfxInfo_spinScrewBottom
            call loadGame_copyItemToVram
        .endIf_screw:
    .endSpinBranch:

    ; Load beam graphics depending on beam
    ld a, [samusActiveWeapon]
        cp $01
        jr nz, .endIf_ice
            ld hl, gfxInfo_ice
            call loadGame_copyItemToVram
            jr .endBeamBranch
        .endIf_ice:
    
        cp $03
        jr nz, .endIf_spazer
            ld hl, gfxInfo_spazer
            call loadGame_copyItemToVram
            jr .endBeamBranch
        .endIf_spazer:
    
        cp $02
        jr nz, .endIf_wave
            ld hl, gfxInfo_wave
            call loadGame_copyItemToVram
            jr .endBeamBranch
        .endIf_wave:
    
        cp $04
        jr nz, .endIf_plasma
            ld hl, gfxInfo_plasma
            call loadGame_copyItemToVram
        .endIf_plasma:
    .endBeamBranch:
ret ;}

; Given a gfxInfo entry pointed to by HL, copies graphics into VRAM
loadGame_copyItemToVram: ;{ 00:3C3F
    ; Read source bank of transfer
    ld a, [hl+]
    ld [bankRegMirror], a
    ld [vramTransfer_srcBank], a
    ld [rMBC_BANK_REG], a
    ; Read source address of transfer to temp
    ld a, [hl+]
    ldh [hTemp.a], a
    ld a, [hl+]
    ldh [hTemp.b], a
    ; Read destination address of transfer
    ld a, [hl+]
    ld e, a
    ld a, [hl+]
    ld d, a
    ; Read length of transfer
    ld a, [hl+]
    ld c, a
    ld a, [hl+]
    ld b, a
    ; Load source address to HL from temp
    ldh a, [hTemp.a]
    ld l, a
    ldh a, [hTemp.b]
    ld h, a
  .unusedEntry:
    call copyToVram
ret ;}

; Unreferenced procedure, branches to the function above
; - Uploads one less byte (at start) to VRAM compared to the arguments sent to it
unused_decreasingVramTransfer: ;{ 00:3C61
    ; Increment start of source and destination address
    ld a, [hl+]
    ld [de], a
    inc de
    ; Decrease length by 1
    dec bc
    ; Exit if length is now zero
    ld a, c
    or b
    jr nz, loadGame_copyItemToVram.unusedEntry
ret ;}

; 00:3C6A - Load credits to SRAM
loadCreditsText: ;{
    switchBank creditsText
    ld hl, creditsText ;$7920
    ld de, creditsTextBuffer
    ; Enable SRAM
    ld a, $0a
    ld [$0000], a

    ; Load text until $F0 is found
    .loadLoop:
        ld a, [hl+]
        ld [de], a
        inc de
        cp $f0
    jr nz, .loadLoop

    ; Disable SRAM
    ld a, $00
    ld [$0000], a

    switchBank prepareCredits
ret ;}

; External Calls {
earthquakeCheck_farCall: ; 00:3C92
    callFar earthquakeCheck
    ; Return to callee
    ld a, $02 ; All callees are Metroid AI routines
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
ret

enemy_deleteSelf_farCall: ; 00:3CA6 - enemy routine: Delete self?
    callFar enemy_deleteSelf
    ld a, $02 ; Enemy AI bank
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
ret

enemy_seekSamus_farCall: ; 00:3CBA
    callFar enemy_seekSamus
    ld a, $02 ; Callees are metroids
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
ret

destroyBlock_farCall: ; 00:3CCE
    callFar destroyBlock ; $56e9
    switchBank enAI_babyMetroid ; The Baby
ret

gameMode_saveGame: ; 00:3CE2
    jpLong saveFileToSRAM

earthquake_adjustScroll_longJump: ; 00:3CED
    jpLong earthquake_adjustScroll

drawNonGameSprite_longCall: ; 00:3CF8
    callFar drawNonGameSprite
    switchBank titleCreditsBank
ret

alpha_getAngle_farCall: ; 00:3D0C
    callFar alpha_getAngle ; $70ba
    switchBank enAI_alphaMetroid ; Bank 2 - Alpha Metroid AI?
ret

gamma_getAngle_farCall: ; 00:3D20
    callFar gamma_getAngle
    switchBank enAI_gammaMetroid ; Gamma Metroid AI (also used by Omega Metroid fireball)
ret

alpha_getSpeedVector_farCall: ; 00:3D34
    callFar alpha_getSpeedVector ; $71cb
    switchBank enAI_alphaMetroid ; Also Alpha Metroid AI?
ret

gamma_getSpeedVector_farCall: ; 00:3D48
    callFar gamma_getSpeedVector ; $7319
    switchBank enAI_gammaMetroid ; Gamma Metroid AI (also used by Omega Metroid fireball)
ret

LCDCInterruptHandler_farCall: ; 00:3D5C
    push af
        ; Presuming this non-standard convention is because this is an interrupt handler
        ld a, $03
        ld [rMBC_BANK_REG], a
        call LCDCInterruptHandler
        ld a, [bankRegMirror]
        ld [rMBC_BANK_REG], a
    pop af
reti


miscIngameTasks_longJump: ; 00:3D6D
    jpLong miscIngameTasks

adjustHudValues_longJump: ; 00:3D78
    jpLong adjustHudValues

handleRespawningBlocks_longJump: ; 00:3D83
    jpLong handleRespawningBlocks

handleProjectiles_longJump: ; 00:3D8E
    jpLong handleProjectiles

handleBombs_longJump: ; 00:3D99
    jpLong handleBombs ; $549d

drawProjectiles_longJump: ; 00:3DA4
    jpLong drawProjectiles

samusShoot_longJump: ; 00:3DAF
    jpLong samusShoot

scrollEnemies_farCall: ; 00:3DBA
    callFar scrollEnemies
    switchBank enemyHandler
ret

drawEnemies_farCall: ; 00:3DCE
    callFar drawEnemies
    switchBank enemyHandler
ret

handleEnemyLoading_farCall: ; 00:3DE2
    callFar handleEnemyLoading ;$4000
    switchBank processEnemies
ret

loadEnemy_getFirstEmptySlot_longJump: ; 00:3DF6
    callFar loadEnemy_getFirstEmptySlot
    switchBankVar $02 ; Enemy AI bank
ret

loadEnemySaveFlags_longJump: ; 00:3E0A
    callFar loadEnemySaveFlags
    switchBank loadSaveFile
ret

VBlank_drawCreditsLine_longJump: ; 00:3E1E
    jpLong VBlank_drawCreditsLine

gameMode_prepareCredits: ; 00:3E29
    jpLong prepareCredits

gameMode_Credits: ; 00:3E34
    jpLong creditsRoutine

gameMode_Boot: ; 00:3E3F
    call disableLCD
    call OAM_clearTable
    xor a
    ldh [hOamBufferIndex], a
    call clearUnusedOamSlots_longJump
    call silenceAudio_longJump
    jpLong loadTitleScreen

gameMode_Title: ; 00:3E59
    call OAM_clearTable
    jpLong titleScreenRoutine

gameMode_newGame: ; 00:3E67
    jpLong createNewSave

gameMode_loadSave: ; 00:3E72
    jpLong loadSaveFile

drawSamusSprite_longJump: ; 00:3E7D - Unused long jump?
    jpLong drawSamusSprite

clearUnusedOamSlots_longJump: ; 00:3E88
    jpLong clearUnusedOamSlots

drawSamus_longJump: ; 00:3E93
    jpLong drawSamus

drawHudMetroid_longJump: ; 00:3E9E
    jpLong drawHudMetroid

debug_drawOneDigitNumber_longJump: ; 00:3EA9 - Unused long jump?
    jpLong debug_drawNumber.oneDigit

debug_drawTwoDigitNumber_longJump: ; 00:3EB4 - Unused long jump?
    jpLong debug_drawNumber.twoDigit

drawSamus_ignoreDamageFrames_longJump: ; 00:3EBF
    jpLong drawSamus.ignoreDamageFrames

clearAllOam_longJump: ; 00:3ECA
    jpLong clearAllOam

;} End of long calls

; Extracts the sprite priority bit that is bit-packed with the door transition index using the bitmask (0x0800)
; (I don't know why they didn't store these bits with the scroll bytes)
loadScreenSpritePriorityBit: ;{ 00:3ED5
    switchBankVar [currentLevelBank]
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
    ld hl, map_doorIndexes ; $4300 - Base address for door transition indexes
    add hl, de
    ; Load the high byte of the transition index
    inc hl
    ld a, [hl]
    ; Rotate the relavent bit to the LSB and store it
    swap a
    rlc a
    and $01
    xor $01
    ld [samus_screenSpritePriority], a
    ; Return to the callee
    switchBank drawSamus
ret
;}

; Unused (duplicate of the routine at 00:3062)
unusedDeathAnimation_copy: ;{ 00:3F07
    ; Animate every other frame
    ldh a, [frameCounter]
    and $01
    jr nz, .endIf_A
        ; Get pointer for starting offset
        ld a, [pDeathAltAnimBaseLow]
        ld l, a
        ld a, [pDeathAltAnimBaseHigh]
        ld h, a
        
        ; Set increment value for loop
        ld de, $0010
        .eraseLoop:
            ; Clear byte
            xor a
            ld [hl], a
            ; Iterate to next byte
            add hl, de
            ; Exit loop once $xx0x is reached
            ld a, l
            and $f0
        jr nz, .eraseLoop
        ; Iterate to next row of pixels to clear        
        ; HL-$00FF (to get to the next byte of the starting tile)
        ld a, l
        sub $ff
        ld l, a
        ld a, h
        sbc $00
        ld h, a
        ; If HL points to the second tile in a row
        ld a, l
        cp $10
        jr nz, .endIf_B
            ; Then add $F0 to HL so it points to the first tile of the next row
            add $f0
            ld l, a
            ld a, h
            adc $00
            ld h, a
        .endIf_B:
        ; Save the pointer
        ld a, l
        ld [pDeathAltAnimBaseLow], a
        ld a, h
        ld [pDeathAltAnimBaseHigh], a
        ; Stop animating once 5 rows have been cleared
        cp $85
        jr nz, .endIf_A
            ; Clear timer
            xor a
            ld [deathAnimTimer], a
            ; Note: This does not set deathFlag
            ;  or gameMode like it should.
    .endIf_A:

    ; Set scroll values
    ld a, [scrollY]
    ldh [rSCY], a
    ld a, [scrollX]
    ldh [rSCX], a
    ; DMA sprites
    call OAM_DMA
    ; Return from interrupt
    ld a, [bankRegMirror]
    ld [rMBC_BANK_REG], a
    ld a, $01
    ldh [hVBlankDoneFlag], a
    pop hl
    pop de
    pop bc
    pop af
reti ;}

bank0_freespace: ; Freespace - 00:3F60 (filled with $00)
