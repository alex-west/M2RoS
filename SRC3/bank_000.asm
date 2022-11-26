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
        jp nz, Jump_000_2b8f
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
    ld hl, $dfff
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
    ld sp, $dfff
    call initializeAudio_longJump
    ; Enable SRAM (?)
    ld a, $0a
    ld [$0000], a
    
    ; Clear $DF00-$DF00 (stack)
    xor a
    ld hl, $dfff
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
    ldh [$99], a
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
    ldh a, [$99]
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
    ld [$d05d], a
    
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
    cp $18
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
            call nz, toggleMissiles
        jr .endIf_A
    .else_A:
        ; Check if in a door transition
        ; BUG: This only checks the low byte of the index
        ld a, [doorScrollDirection]
        and a
        jr nz, .endIf_A
            ; Do various common things
            xor a
            ld [$d05c], a
            call hurtSamus ; Damage Samus
            call samus_handlePose ; Samus pose handler
            call Call_000_32ab ; ? Samus/enemy collision logic
            call Call_000_21fb ; Handle shooting or toggling cannon
            call handleProjectiles_longJump ; Handle projectiles
            call Call_000_3d99 ; Handle bombs
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
    ld [$d05c], a
    ; Do various common things
    call samus_handlePose
    call Call_000_32ab
    call Call_000_21fb
    call handleProjectiles_longJump
    call Call_000_3d99
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
        jp nz, Jump_000_0b44 ; Handle door

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
    ldh [$98], a
    
    ldh a, [$98]
    bit 0, a ; Check right
    jr z, jr_000_0949
        ldh a, [hCameraXPixel]
        cp $b0
        jp nz, Jump_000_0936        
            ld a, [samus_onscreenXPos]
            cp $a1
                jr c, jr_000_0991
            ld a, $01 ; Right
            ld [doorScrollDirection], a
            call loadDoorIndex
            jp Jump_000_0991
        Jump_000_0936:
    
        jr c, jr_000_0949
            ; Move camera left
            ldh a, [hCameraXPixel]
            sub $01
            ldh [hCameraXPixel], a
            ldh a, [hCameraXScreen]
            sbc $00
            and $0f
            ldh [hCameraXScreen], a
            jp Jump_000_0991
    jr_000_0949:

    ld a, [camera_speedRight]
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
        ld a, [camera_scrollDirection]
        set scrollDirBit_right, a
        ld [camera_scrollDirection], a
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
    jr_000_0991:

Jump_000_0991:

    ldh a, [$98]
    bit 1, a ; Check left
    jr z, jr_000_09cd
        ldh a, [hCameraXPixel]
        cp $50
        jr nz, jr_000_09bb
            ld a, [samus_onscreenXPos]
            cp $0f
                jp nc, Jump_000_0a18
            ld a, $02 ; Left
            ld [doorScrollDirection], a
            ld a, $00
            ldh [hSamusXPixel], a
            ldh a, [hSamusXScreen]
            inc a
            and $0f
            ldh [hSamusXScreen], a
            call loadDoorIndex
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

    ld a, [camera_speedLeft]
    and a
    jr z, jr_000_0a18
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
        ld a, [camera_scrollDirection]
        set scrollDirBit_left, a
        ld [camera_scrollDirection], a
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
    jr_000_0a18:

Jump_000_0a18:
    xor a
    ld [camera_speedRight], a
    ld [camera_speedLeft], a
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
        ld [camera_speedDown], a
        ld a, [camera_scrollDirection]
        set 7, a
        ld [camera_scrollDirection], a
        
        ; Why's this case so different from the others
        ldh a, [$98]
        bit 3, a ; Check down
        jr z, jr_000_0a9d
            ld a, [queen_roomFlag]
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
                    ld a, [samus_onscreenYPos]
                    cp $78
                        jp c, Jump_000_0b2c
                    ld a, $08 ; Down
                    ld [doorScrollDirection], a
                    call loadDoorIndex
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
                    ld a, [camera_speedDown]
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
                ld a, [camera_speedDown]
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
    ld [camera_speedUp], a
    ld a, [camera_scrollDirection]
    set scrollDirBit_up, a
    ld [camera_scrollDirection], a
        
    ldh a, [$98]
    bit 2, a ; Check up
    jr z, jr_000_0b17
        ldh a, [hCameraYPixel]
        cp $48
        jr nz, jr_000_0aee
            ld a, [samus_onscreenYPos]
            cp $1b
                jr nc, jr_000_0b2c
            ld a, $04 ; Up
            ld [doorScrollDirection], a
            ld a, $00
            ldh [hSamusYPixel], a
            ldh a, [hCameraYScreen]
            ldh [hSamusYScreen], a
            ld a, [queen_roomFlag]
            cp $11
                call nz, loadDoorIndex
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
                ld a, [camera_speedUp]
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
            ld a, [camera_speedUp]
            ld b, a
            ldh a, [hCameraYPixel]
            sub b
            ldh [hCameraYPixel], a
            ldh a, [hCameraYScreen]
            sbc $00
            ldh [hCameraYScreen], a
    jr_000_0b2c:

Jump_000_0b2c:
    xor a
    ld [camera_speedDown], a
    ld [camera_speedUp], a
    ldh a, [hSamusYPixel]
    ld [$d00c], a
ret
;}

; 00:0B39 - Unreferenced data?
    db $00, $01, $01, $00, $00, $00, $01, $02, $02, $01, $01

; Already in a door transition?
Jump_000_0b44: ;{ 00:0B44
    ; Make sure spinning animation happens during transition
    ld a, [samus_spinAnimationTimer]
    inc a
    ld [samus_spinAnimationTimer], a
    
    ld a, [doorScrollDirection]
    bit 0, a
    jr z, jr_000_0b82
        ; Scroll right
        ldh a, [hCameraXPixel]
        add $04
        ldh [hCameraXPixel], a
        ldh a, [hCameraXScreen]
        adc $00
        and $0f
        ldh [hCameraXScreen], a
        ; Also force the running/rolling animation to happen if applicable
        ld a, [samus_animationTimer]
        inc a
        inc a
        inc a
        ld [samus_animationTimer], a
        ; Set screen movement direction
        ld a, scrollDir_right
        ld [camera_scrollDirection], a
        ; Move Samus
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
        ; Scroll left
        ldh a, [hCameraXPixel]
        sub $04
        ldh [hCameraXPixel], a
        ldh a, [hCameraXScreen]
        sbc $00
        and $0f
        ldh [hCameraXScreen], a
        ; Also force the running/rolling animation to happen if applicable
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
        ldh a, [hCameraXPixel]
        cp $b0
            ret nz
        jr jr_000_0c24
    jr_000_0bb5:

    bit 2, a
    jr z, jr_000_0bee
        ; Scroll up
        ldh a, [hCameraYPixel]
        sub $04
        ldh [hCameraYPixel], a
        ldh a, [hCameraYScreen]
        sbc $00
        and $0f
        ldh [hCameraYScreen], a
        ; Also force the running/rolling animation to happen if applicable
        ld a, [samus_animationTimer]
        inc a
        inc a
        inc a
        ld [samus_animationTimer], a
        ; Set screen movement direction
        ld a, scrollDir_up
        ld [camera_scrollDirection], a
        ; Move Samus 1.5 px/frame
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
        ; Scroll down
        ldh a, [hCameraYPixel]
        add $04
        ldh [hCameraYPixel], a
        ldh a, [hCameraYScreen]
        adc $00
        and $0f
        ldh [hCameraYScreen], a
        ; Also force the running/rolling animation to happen if applicable
        ld a, [samus_animationTimer]
        inc a
        inc a
        inc a
        ld [samus_animationTimer], a
        ; Set screen movement direction
        ld a, scrollDir_down
        ld [camera_scrollDirection], a
        ; Move Samus 1.5 px/frame
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
    ; end cases

Jump_000_0c24:
jr_000_0c24:
    xor a
    ld [doorScrollDirection], a
    ld [cutsceneActive], a
    ; Apply fade-in if we have faded out.
    ld a, [bg_palette]
    cp $93
        ret z
    ld a, $2f
    ld [fadeInTimer], a
ret
;}

loadDoorIndex: ;{ 00:0C37
    ; Check related to being in the Queen fight
    ld a, [queen_roomFlag]
    cp $11
    jr nz, .endIf
        ; If in a spider ball pose, return to morph ball
        ld a, [samusPose]
        cp $0b
        jr c, .endIf
            cp $0f
            jr nc, .endIf
                ld a, $05
                ld [samusPose], a
    .endIf:

    xor a
    ld [samus_hurtFlag], a
    ld [saveContactFlag], a
    ; Clear bomb slots
    ld a, $ff
    ld hl, $dd30
    ld [hl], a
    ld hl, $dd40
    ld [hl], a
    ld hl, $dd50
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
    ; Set status
    ld a, $02
    ld [doorExitStatus], a
    xor a
    ld [fadeInTimer], a
    ; If in debug mode, check cheat to warp to queen
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
ret
;}

; Loads Samus' information from the WRAM save buffer to working locations in RAM
loadGame_samusData: ;{ 00:0CA3
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
    
    ; Prep the Samus appearance sequence
    ld a, $13
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
        dw poseFunc_standing   ; $00 Standing
        dw poseFunc_jump       ; $01 Jumping
        dw poseFunc_spinJump   ; $02 Spin-jumping
        dw poseFunc_running    ; $03 Running (set to 83h when turning)
        dw poseFunc_crouch     ; $04 Crouching
        dw poseFunc_morphBall  ; $05 Morphball
        dw poseFunc_morphJump  ; $06 Morphball jumping
        dw poseFunc_12F5       ; $07 Falling
        dw poseFunc_morphFall  ; $08 Morphball falling
        dw poseFunc_jumpStart  ; $09 Starting to jump
        dw poseFunc_jumpStart  ; $0A Starting to spin-jump
        dw poseFunc_spiderRoll ; $0B Spider ball rolling
        dw poseFunc_spiderFall ; $0C Spider ball falling
        dw poseFunc_spiderJump ; $0D Spider ball jumping
        dw poseFunc_spiderBall ; $0E Spider ball
        dw poseFunc_0EF7       ; $0F Knockback
        dw poseFunc_0F38       ; $10 Morphball knockback
        dw poseFunc_0F6C       ; $11 Standing bombed
        dw poseFunc_0ECB       ; $12 Morphball bombed
        dw poseFunc_faceScreen ; $13 Facing screen
        dw poseFunc_faceScreen ; $14
        dw poseFunc_faceScreen ; $15
        dw poseFunc_faceScreen ; $16
        dw poseFunc_faceScreen ; $17
        ; Poses related to being eaten by the queen
        dw poseFunc_0E36       ; $18 Being eaten by Metroid Queen
        dw poseFunc_0DF0       ; $19 In Metroid Queen's mouth
        dw poseFunc_0DBE       ; $1A Being swallowed by Metroid Queen
        dw poseFunc_0D87       ; $1B In Metroid Queen's stomach
        dw poseFunc_0D8B       ; $1C Escaping Metroid Queen
        dw poseFunc_0ECB       ; $1D Escaped Metroid Queen
;}

; Samus' pose functions: {

poseFunc_0D87: ;{ $1B - In Queen's stomach
    call applyDamage.queenStomach
ret ;}

poseFunc_0D8B: ;{ $1C - Escaping Queen's mouth
    call applyDamage.queenStomach
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

    ld a, samus_jumpArrayBaseOffset
    ld [samus_jumpArcCounter], a
    ld a, $01
    ld [$d00f], a
    ld a, $1d
    ld [samusPose], a
ret ;}

poseFunc_0DBE: ;{ $1A
    call applyDamage.queenStomach
    ldh a, [hSamusXPixel]
    cp $68
    jr z, jr_000_0dea
        ld a, [queen_headX]
        add $06
        ld b, a
        ld a, [scrollX]
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
;} end proc

poseFunc_0DF0: ;{ $19
    ld a, $6c
    ldh [hSamusYPixel], a
    ld a, $a6
    ldh [hSamusXPixel], a
    call applyDamage.queenStomach
    ld a, [queen_eatingState]
    cp $05
    jr nz, .else_A
        ld a, $01
        ld [$d00f], a
        ld a, samus_jumpArrayBaseOffset + $10 ;$50
        ld [samus_jumpArcCounter], a
        ld a, $1d
        ld [samusPose], a
        ret
    .else_A:
        cp $20
        jr nz, .else_B
            ld a, samus_jumpArrayBaseOffset
            ld [samus_jumpArcCounter], a
            ld a, $01
            ld [$d00f], a
            ld a, $1d
            ld [samusPose], a
            ret
        .else_B:
            ldh a, [hInputRisingEdge]
            bit PADB_LEFT, a
                ret z
            ld a, $1a
            ld [samusPose], a
            ld a, $06
            ld [queen_eatingState], a
            ret
;}

poseFunc_0E36: ;{ $18
    call applyDamage.queenStomach
    ld a, [queen_eatingState]
    cp $03
    jr nz, jr_000_0e46
        ld a, $19
        ld [samusPose], a
        ret
    jr_000_0e46:

    ld c, $00
    ld a, [queen_headY]
    add $13
    ld b, a
    ld a, [samus_onscreenYPos]
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
        ld [camera_speedUp], a
        jr jr_000_0e72
    jr_000_0e67:
        ldh a, [hSamusYPixel]
        add $01
        ldh [hSamusYPixel], a
        ld a, $01
        ld [camera_speedDown], a
    jr_000_0e72:

    ld a, [queen_headX]
    add $1a
    ld b, a
    ld a, [samus_onscreenXPos]
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
        ld [camera_speedLeft], a
        jr jr_000_0e9b
    jr_000_0e90:
        ldh a, [hSamusXPixel]
        add $01
        ldh [hSamusXPixel], a
        ld a, $01
        ld [camera_speedRight], a
    jr_000_0e9b:

    ld a, c
    cp $02
        ret nz
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

poseFunc_0ECB: ;{ $12 and $1D
    ldh a, [hInputRisingEdge]
    bit PADB_DOWN, a
    jr z, .endIf
        ld a, [samusItems]
        bit itemBit_spider, a
        jr z, .endIf
            ld a, pose_spiderFall
            ld [samusPose], a
            xor a
            ld [spiderRotationState], a
            ld a, $0d
            ld [sfxRequest_square1], a
            ret
    .endIf:

    ldh a, [hInputRisingEdge]
    bit PADB_UP, a
    jr z, poseFunc_0F6C
        call samus_unmorphInAir
        ld a, samus_unmorphJumpTime
        ld [samus_unmorphJumpTimer], a
    jr poseFunc_0F6C
;}

poseFunc_0EF7: ;{ $0F - Knockback
    ; Go to "bombed" pose handler if jump is not pressed
    ldh a, [hInputRisingEdge]
    bit PADB_A, a
        jr z, poseFunc_0F6C

    ; Return if colliding with something
    call collision_samusTop
        ret c

    ; Clear i-frames
    xor a
    ld [samusInvulnerableTimer], a
    ; High-jump jump value
    ld a, samus_jumpArrayBaseOffset - $1F ;$21
    ld [samus_jumpArcCounter], a
    ld a, $02
    ld [sfxRequest_square1], a
    ld a, [samusItems]
    bit itemBit_hiJump, a
    jr nz, .endIf_A
        ; Normal jump value
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

    ld a, pose_jumpStart
    ld [samusPose], a
    xor a
    ld [samus_jumpStartCounter], a
ret
;}

poseFunc_0F38: ;{ $10
    ldh a, [hInputRisingEdge]
    bit PADB_UP, a
    jp z, .endIf_A
        call samus_unmorphInAir
        ld a, samus_unmorphJumpTime
        ld [samus_unmorphJumpTimer], a
    .endIf_A:

    ld a, [samusItems]
    bit itemBit_spring, a
    jr z, .endIf_B
        ldh a, [hInputRisingEdge]
        bit PADB_A, a
        jr z, .endIf_B
            xor a
            ld [samusInvulnerableTimer], a
            ld a, samus_jumpArrayBaseOffset - $12 ;$2e
            ld [samus_jumpArcCounter], a
            ld a, pose_morphJump
            ld [samusPose], a
            xor a
            ld [samus_jumpStartCounter], a
            ld a, $01
            ld [sfxRequest_square1], a
            ret
    .endIf_B:
; Fallthrough to next pose handler
;}

poseFunc_0F6C: ;{ 00:0F6C - $11: Bombed (standing)
    ld a, [samus_jumpArcCounter]
    sub samus_jumpArrayBaseOffset
    ld e, a
    ld d, $00
    ld hl, table_0FF6
    add hl, de
    ld a, [hl]
    cp $80
    jr nz, jr_000_0f7f
        jr jr_000_0fc0
    jr_000_0f7f:

    call samus_moveVertical
    jr nc, jr_000_0f8b
        ld a, [samus_jumpArcCounter]
        cp samus_jumpArrayBaseOffset + $17 ; $57
        jr nc, jr_000_0fc0
    jr_000_0f8b:

    ld a, [samus_jumpArcCounter]
    inc a
    ld [samus_jumpArcCounter], a
    cp samus_jumpArrayBaseOffset + $16 ; $56
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
    ;jr_000_0fac:

    ld a, [$d00f]
    cp $01
    jr nz, jr_000_0fb6
        call samus_moveRightInAir.noTurn
    jr_000_0fb6:
        ld a, [$d00f]
        cp $ff
            ret nz
        call samus_moveLeftInAir.noTurn
        ret

jr_000_0fc0:
    xor a
    ld [samus_jumpArcCounter], a
    ld a, $16
    ld [samus_fallArcCounter], a
    ld a, [samusPose]
    ld e, a
    ld d, $00
    ld hl, table_0FD8
    add hl, de
    ld a, [hl]
    ld [samusPose], a
ret

table_0FD8: ; 00:0FD8 - A pose-transition table
    db $00 ; 00: Standing
    db $00 ; 01: Jumping
    db $00 ; 02: Spin-jumping
    db $00 ; 03: Running (set to 83h when turning)
    db $00 ; 04: Crouching
    db $00 ; 05: Morphball
    db $00 ; 06: Morphball jumping
    db $00 ; 07: Falling
    db $00 ; 08: Morphball falling
    db $00 ; 09: Starting to jump
    db $00 ; 0A: Starting to spin-jump
    db $00 ; 0B: Spider ball rolling
    db $00 ; 0C: Spider ball falling
    db $00 ; 0D: Spider ball jumping
    db $00 ; 0E: Spider ball
    db $07 ; 0F: Knockback
    db $08 ; 10: Morphball knockback
    db $07 ; 11: Standing bombed
    db $08 ; 12: Morphball bombed
    db $00 ; 13: Facing screen
    db $00 
    db $00 
    db $00 
    db $00 
    db $18 ; 18: Being eaten by Metroid Queen 
    db $19 ; 19: In Metroid Queen's mouth
    db $1A ; 1A: Being swallowed by Metroid Queen
    db $1B ; 1B: In Metroid Queen's stomach
    db $1C ; 1C: Escaping Metroid Queen
    db $08 ; 1D: Escaped Metroid Queen

; Bombed arc table?
table_0FF6: ; 00:0FF6
    db $fd, $fd, $fd, $fd, $fe, $fd, $fe, $fd, $fe, $fe, $fe, $fe, $fe, $fe, $ff, $fe
    db $fe, $ff, $fe, $ff, $fe, $ff, $ff, $00, $00, $00, $00, $01, $01, $02, $01, $02
    db $01, $02, $02, $01, $02, $02, $02, $02, $02, $02, $03, $02, $03, $02, $03, $03
    db $03, $03, $80
;}

poseFunc_spiderBall: ;{ 00:1029 - $0E: spider ball (not moving)
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
        ; Set pose to fall
        ld a, pose_spiderFall
        ld [samusPose], a
        ret
;}

poseFunc_spiderRoll: ;{ 00:1083 - $0B: Spider Ball (rolling)
    ldh a, [hInputRisingEdge]
    bit PADB_A, a
    jr z, .endIf_A
        ld a, pose_morph
        ld [samusPose], a
        ld a, $06
        ld [sfxRequest_square1], a
        ret
    .endIf_A:

    ldh a, [hInputPressed]
    and PADF_DOWN | PADF_UP | PADF_LEFT | PADF_RIGHT ;$f0
    jr nz, .endIf_B
        ld a, pose_spider
        ld [samusPose], a
        xor a
        ld [spiderRotationState], a
        ret
    .endIf_B:

    call collision_checkSpiderSet
    ld a, [spiderContactState]
    and a
        jr z, poseFunc_spiderBall.fall

    ld e, a
    ld d, $00
    ld a, [spiderRotationState]
    bit 0, a
    jr z, .else_C
        ld hl, table_20A9
        jr .endIf_C
    .else_C:
        bit 1, a
            ret z
        ld hl, table_20C9
    .endIf_C:

    add hl, de
    ld a, [hl]
    ld [spiderBallDirection], a
    xor a
    ld [spiderDisplacement], a
    ld a, [spiderBallDirection]
    bit 0, a
        call nz, samus_spiderRight
    ld a, [spiderBallDirection]
    bit 1, a
        call nz, samus_spiderLeft
    ld a, [spiderBallDirection]
    bit 2, a
        call nz, samus_spiderUp
    ld a, [spiderBallDirection]
    bit 3, a
        call nz, samus_spiderDown
    ld a, [spiderDisplacement]
    and a
        ret nz

    ld a, [spiderContactState]
    ld e, a
    ld d, $00
    ld a, [spiderRotationState]
    bit 0, a
    jr z, .else_D
        ld hl, table_20B9
        jr .endIf_D
    .else_D:
        bit 1, a
            ret z
        ld hl, table_20D9
    .endIf_D:

    add hl, de
    ld a, [hl]
    ld [spiderBallDirection], a
    xor a
    ld [spiderDisplacement], a
    ld a, [spiderBallDirection]
    bit 0, a
        call nz, samus_spiderRight
    ld a, [spiderBallDirection]
    bit 1, a
        call nz, samus_spiderLeft
    ld a, [spiderBallDirection]
    bit 2, a
        call nz, samus_spiderUp
    ld a, [spiderBallDirection]
    bit 3, a
        call nz, samus_spiderDown
ret

samus_spiderRight: ; 00:1132
    call samus_rollRight.spider
    ld a, [camera_speedRight]
    ld [spiderDisplacement], a
ret

samus_spiderLeft: ; 00:113C
    call samus_rollLeft.spider
    ld a, [camera_speedLeft]
    ld [spiderDisplacement], a
ret

samus_spiderUp: ; 00:1146
    ld a, $01
    call samus_moveUp
    ld a, [camera_speedUp]
    ld [spiderDisplacement], a
ret

samus_spiderDown: ; 00:1152
    ld a, $01
    call samus_moveVertical
    ld a, [camera_speedDown]
    ld [spiderDisplacement], a
        ret nc
    ld a, [samus_onSolidSprite]
    and a
        ret nz
    ldh a, [hSamusYPixel]
    and $f8
    or $04
    ldh [hSamusYPixel], a
    xor a
    ld [spiderDisplacement], a
ret
;}

poseFunc_spiderJump: ;{ 00:1170 - $0D: Spider ball jumping
    ldh a, [hInputRisingEdge]
    bit PADB_A, a
    jr z, .endIf_A
        ld a, pose_morphJump
        ld [samusPose], a
        ld a, $06
        ld [sfxRequest_square1], a
        ret
    .endIf_A:

    ld a, [samus_jumpArcCounter]
    cp samus_jumpArrayBaseOffset
    jr nc, .endIf_B
        ldh a, [hInputPressed]
        bit PADB_A, a
        jr z, .endIf_C
            ld a, $fe
                jr .moveVertical
        .endIf_C:
        
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
    call samus_moveVertical
        jp c, Jump_000_1233

    ; Spider collision check
    call collision_checkSpiderSet
    ld a, [spiderContactState]
    and a
        jp nz, Jump_000_1241

    ; Increment jump counter
    ld a, [samus_jumpArcCounter]
    inc a
    ld [samus_jumpArcCounter], a

;moveHorizontal    
    ldh a, [hInputPressed]
    bit PADB_RIGHT, a
    jr z, .else
        call samus_spiderRight ; Change to "samus_rollRight.morph" for BIDIRECTIONAL SPIDER THROWING ($1132 -> $1C98)
        ret
    .else:
        ldh a, [hInputPressed]
        bit PADB_LEFT, a
        jr z, .endIf_D
            call samus_rollLeft.morph
            ret
        .endIf_D:
        ret

.startFalling:
    ; What? Why is this writing to ROM?
    xor a
    ld [jumpArcTable], a
    ld a, $16
    ld [samus_fallArcCounter], a
    ld a, pose_spiderFall
    ld [samusPose], a
    xor a
    ld [spiderRotationState], a
ret
;}

poseFunc_spiderFall: ;{ 00:11E4 - $0C
    ldh a, [hInputRisingEdge]
    bit PADB_A, a
    jr z, jr_000_11f5
        ld a, pose_morphFall
        ld [samusPose], a
        ld a, $06
        ld [sfxRequest_square1], a
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

    ld hl, fallArcTable
    ld a, [samus_fallArcCounter]
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    call samus_moveVertical
    jr c, jr_000_1233

    call collision_checkSpiderSet
    ld a, [spiderContactState]
    and a
    jr nz, jr_000_1241

    ld a, [samus_fallArcCounter]
    inc a
    ld [samus_fallArcCounter], a
    
    cp $17
    jr c, jr_000_1232

    ld a, $16
    ld [samus_fallArcCounter], a

jr_000_1232:
    ret


Jump_000_1233:
jr_000_1233:
    ld a, [samus_onSolidSprite]
    and a
    jr nz, jr_000_1241

    ldh a, [hSamusYPixel]
    and $f8
    or $04
    ldh [hSamusYPixel], a

Jump_000_1241:
jr_000_1241:
    ld a, pose_spiderRoll
    ld [samusPose], a
    xor a
    ld [samus_fallArcCounter], a
    ret
;}

poseFunc_morphFall: ;{ 00:123B - $08: Morphball falling
    ldh a, [hInputRisingEdge]
    bit PADB_DOWN, a
    jr z, .endIf_A
        ld a, [samusItems]
        bit itemBit_spider, a
        jr z, .endIf_A
            ld a, pose_spiderFall
            ld [samusPose], a
            xor a
            ld [spiderRotationState], a
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
            ld [samus_jumpArcCounter], a
            ld a, pose_morphJump
            ld [samusPose], a
            xor a
            ld [samus_jumpStartCounter], a
            ld a, $01
            ld [sfxRequest_square1], a
            ret
    .endIf_B:

    ; Handle unmorphing
    ldh a, [hInputRisingEdge]
    bit PADB_UP, a
    jr z, .endIf_C
        call samus_unmorphInAir
        ld a, samus_unmorphJumpTime
        ld [samus_unmorphJumpTimer], a
        jr .exit
    .endIf_C:

;moveHorizontal
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
    ld hl, fallArcTable
    ld a, [samus_fallArcCounter]
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    call samus_moveVertical
    jr c, .else
        ; Keep falling
        ; Increase fall counter
        ld a, [samus_fallArcCounter]
        inc a
        ld [samus_fallArcCounter], a
        ; Cap value to $16
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
        ; Clamp y pixel to 8x8 tile boundary if this condition is met
        ld a, [samus_onSolidSprite]
        and a
            ret nz
        ldh a, [hSamusYPixel]
        and $f8
        or $04
        ldh [hSamusYPixel], a
        ret
;} end proc

poseFunc_12F5: ;{ 00:12F5 - $07 - Falling
    ldh a, [hInputRisingEdge]
    bit PADB_A, a
    jr z, jr_000_1335
        ld a, [acidContactFlag]
        and a
        jr z, jr_000_1306
            ld [samus_jumpArcCounter], a
            jr jr_000_1311
        jr_000_1306:
            ld a, [samus_unmorphJumpTimer]
            and a
                jr z, jr_000_1335
            ld a, samus_jumpArrayBaseOffset - $1F ;$21
            ld [samus_jumpArcCounter], a
        jr_000_1311:
    
        ld a, $02
        ld [sfxRequest_square1], a
        ld a, [samusItems]
        bit itemBit_hiJump, a
        jr nz, jr_000_1327
            ld a, samus_jumpArrayBaseOffset - $F ;$31
            ld [samus_jumpArcCounter], a
            ld a, $01
            ld [sfxRequest_square1], a
        jr_000_1327:
    
        ld a, pose_jumpStart
        ld [samusPose], a
        xor a
        ld [samus_jumpStartCounter], a
        xor a
        ld [samus_unmorphJumpTimer], a
        ret    
    jr_000_1335:

    ldh a, [hInputPressed]
    bit PADB_RIGHT, a
    jr z, jr_000_1340
        call samus_moveRightInAir.turn
        jr jr_000_1349
    jr_000_1340:
        ldh a, [hInputPressed]
        bit PADB_LEFT, a
        jr z, jr_000_1349
            call samus_moveLeftInAir.turn
    jr_000_1349:

    ld hl, fallArcTable
    ld a, [samus_fallArcCounter]
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    call samus_moveVertical
    jr c, jr_000_136a
        ld a, [samus_fallArcCounter]
        inc a
        ld [samus_fallArcCounter], a
        cp $17
        jr c, jr_000_1369
            ld a, $16
            ld [samus_fallArcCounter], a
        jr_000_1369:
        ret
    jr_000_136a:
        call samus_tryStanding
        jr nc, jr_000_1374
            ld a, pose_crouch
            ld [samusPose], a
        jr_000_1374:
    
        xor a
        ld [samus_fallArcCounter], a
        ld a, [samus_onSolidSprite]
        and a
            ret nz
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
    call Call_000_1f0f ; Downwards BG collision
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
    call Call_000_1f0f
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
        ld a, pose_jumpStart
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
    call Call_000_1f0f
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
        ld a, pose_jumpStart
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
    call Call_000_1f0f
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
    call Call_000_1f0f
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
    ldh a, [hInputPressed]
    bit PADB_A, a
    jr z, .endIf_C
        ld a, [samusItems]
        bit itemBit_spring, a
        jr z, .endIf_C
            ld a, samus_jumpArrayBaseOffset - $12 ;$2e
            ld [samus_jumpArcCounter], a
            ld a, pose_morphJump
            ld [samusPose], a
            xor a
            ld [samus_jumpStartCounter], a
            ld a, $01
            ld [sfxRequest_square1], a
            ret
    .endIf_C:

    ; Bounce if last vertical speed was >= 2
    ld a, [$d033]
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
        ld [$d033], a
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
    ld a, [samus_jumpArcCounter]
    cp samus_jumpArrayBaseOffset
    jr nc, .endIf_A
        ldh a, [hInputPressed]
        bit PADB_A, a
        jr z, .endIf_B
            ld a, [samusItems]
            and itemMask_hiJump
            srl a
            ld b, a
            ld a, $fe
            sub b
                jr .moveVertical
        .endIf_B:
    
        ld a, samus_jumpArrayBaseOffset + $16 ;56
        ld [samus_jumpArcCounter], a
    .endIf_A:

    sub samus_jumpArrayBaseOffset
    ld hl, jumpArcTable
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
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
    ldh a, [hInputPressed]
    bit PADB_RIGHT, a
    jr z, .endIf_F
        call samus_moveRightInAir.turn
    .endIf_F:
    
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

    ld a, $16
    ld [samus_fallArcCounter], a

    ld a, [samusPose]
    cp pose_morphJump
    jr z, .endIf_H
        ld a, pose_fall
        ld [samusPose], a
        ret
    .endIf_H:
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
    sub $40
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
                ; Something regarding damage boosting?
                ld a, [$d00f]
                and a
                    ret z
                inc a
                srl a
                ld [samusFacingDirection], a
                ret
    .endIf_D:

    ld a, [$d00f]
    and a
    jr nz, .endIf_G
        ldh a, [hInputPressed]
        bit PADB_UP, a
        jr z, .endIf_G
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

    call samus_moveVertical
    jr nc, .endIf_I
        ld a, [samus_jumpArcCounter]
        cp samus_jumpArrayBaseOffset + $17
            jr c, .endIf_I
        jr .startFalling
    .endIf_I:

    ; Increment jump counter
    ld a, [samus_jumpArcCounter]
    inc a
    ld [samus_jumpArcCounter], a

;moveHorizontal
    ldh a, [hInputPressed]
    bit PADB_RIGHT, a
    jr z, .endIf_J
        ld a, $01
        ld [$d00f], a
    .endIf_J:

    ldh a, [hInputPressed]
    bit PADB_LEFT, a
    jr z, .endIf_K
        ld a, $ff
        ld [$d00f], a
    .endIf_K:

    ld a, [$d00f]
    cp $01
    jr nz, .else
        call samus_moveRightInAir.noTurn ; Is this name correct?
        ret
    .else:
        ld a, [$d00f]
        cp $ff
            ret nz
        call samus_moveLeftInAir.noTurn
        ret

    ret ; Unreferenced return :(

.breakSpin:
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
    ld a, $16
    ld [samus_fallArcCounter], a
    ld a, pose_fall
    ld [samusPose], a
ret
;}

poseFunc_jumpStart: ;{ 00:19E2 - $09 and $0A - Starting to jump
    ldh a, [hInputPressed]
    bit PADB_A, a
    jr z, .endIf_A
        ldh a, [frameCounter]
        and $02
        srl a
        ld b, a
        ld a, $fe
        sub b
        call samus_moveVertical
        jr nc, .endIf_B
            call samus_tryStanding
            ret
        .endIf_B:
    
        ; Inc jump-start counter
        ld a, [samus_jumpStartCounter]
        inc a
        ld [samus_jumpStartCounter], a
        cp $06
        jr nc, .endIf_A
            ldh a, [hInputPressed]
            bit PADB_RIGHT, a
            jr z, .endIf_C
                call samus_moveRightInAir.turn
                ret
            .endIf_C:
        
            ldh a, [hInputPressed]
            bit PADB_LEFT, a
            jr z, .endIf_D
                call samus_moveLeftInAir.turn
                ret
            .endIf_D:
            ret
    .endIf_A:

    ld a, [samusPose]
    cp pose_jumpStart
    jr nz, .else
        ld a, pose_jump
        ld [samusPose], a
        ret
    .else:
        ldh a, [hInputPressed]
        and PADF_LEFT | PADF_RIGHT
        swap a
        ld e, a
        ld d, $00
        ld hl, .directionTable
        add hl, de
        ld a, [hl]
        ld [$d00f], a
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
    ld [$c204], a

    ldh a, [hSamusYPixel]
    add spiderYTop
    ld [$c203], a
    call collision_checkSpiderPoint
    
    ld a, [spiderContactState]
    rr a
    ld [spiderContactState], a
    
; Point 1 ($15, $2C)
    ldh a, [hSamusYPixel]
    add spiderYBottom
    ld [$c203], a
    call collision_checkSpiderPoint
    
    ld a, [spiderContactState]
    rr a
    ld [spiderContactState], a
    
; Point 2 ($0A, $1E)
    ldh a, [hSamusXPixel]
    add spiderXLeft
    ld [$c204], a

    ldh a, [hSamusYPixel]
    add spiderYTop
    ld [$c203], a
    call collision_checkSpiderPoint
    
    ld a, [spiderContactState]
    rr a
    ld [spiderContactState], a
    
; Point 3 ($0A, $2C)
    ldh a, [hSamusYPixel]
    add spiderYBottom
    ld [$c203], a
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
    ld [$c204], a

    ldh a, [hSamusYPixel]
    add spiderYMid
    ld [$c203], a
    call collision_checkSpiderPoint
    
    jr nc, .endIf_A
        ld a, [spiderContactState]
        or %0011
        ld [spiderContactState], a
    .endIf_A:

; Point 5 ($0A, $25)
    ldh a, [hSamusXPixel]
    add spiderXLeft
    ld [$c204], a

    ldh a, [hSamusYPixel]
    add spiderYMid
    ld [$c203], a
    call collision_checkSpiderPoint
    
    jr nc, .endIf_B
        ld a, [spiderContactState]
        or %1100
        ld [spiderContactState], a
    .endIf_B:

; Point 6 ($0F, $1E)
    ldh a, [hSamusXPixel]
    add spiderXMid
    ld [$c204], a

    ldh a, [hSamusYPixel]
    add spiderYTop
    ld [$c203], a
    call collision_checkSpiderPoint
    
    jr nc, .endIf_C
        ld a, [spiderContactState]
        or %0101
        ld [spiderContactState], a
    .endIf_C:

; Point 7 ($0F, $2C)
    ldh a, [hSamusYPixel]
    add spiderYBottom
    ld [$c203], a

    ldh a, [hSamusXPixel]
    add spiderXMid
    ld [$c204], a
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
        call Call_000_348d ; Sprite collision for bottom?
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
    ld [$c204], a
jr samus_groundUnmorph_cont ;} This is structured like it used to be a conditional jump...

; Attempts to stand up. Returns carry if it fails.
samus_tryStanding: ;{ 00:1B37
    ld a, $04
    ld [sfxRequest_square1], a
    ; Check upper left pixel
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
    ; Check upper right pixel
    ldh a, [hSamusXPixel]
    add $14
    ld [$c204], a
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
    ld [$c203], a
    call samus_getTileIndex
    ; Check if solid
    ld hl, samusSolidityIndex
    cp [hl]
    jr c, .endIf
        ; Was not solid, check upper right pixel
        ldh a, [hSamusXPixel]
        add $14
        ld [$c204], a
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
    ld [$d033], a
ret
;}

samus_morphOnGround: ;{ 00:1BA4
    ; Set pose
    ld a, pose_morph
    ld [samusPose], a
    ; Clear vertical speed
    xor a
    ld [$d033], a
    ; Play morphing sound
    ld a, $06
    ld [sfxRequest_square1], a
ret
;}

samus_unmorphInAir: ;{ 00:1BB3
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

    ld a, pose_fall
    ld [samusPose], a
    ld a, $04
    ld [sfxRequest_square1], a
ret
    .exit:
ret
;}

; Samus movement functions {
; Move right (walking)
samus_walkRight: ;{ 00:1C0D
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
    call collision_samusHorizontal.right
    jr nc, .keepResults
        ld a, [prevSamusXPixel]
        ldh [hSamusXPixel], a
        ld a, [prevSamusXScreen]
        ldh [hSamusXScreen], a
        ret
    .keepResults:
        ld a, b
        ld [camera_speedRight], a
        ret
;} end proc

samus_walkLeft: ;{ 00:1C51
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
    call collision_samusHorizontal.left
    jr nc, .keepResults
        ld a, [prevSamusXPixel]
        ldh [hSamusXPixel], a
        ld a, [prevSamusXScreen]
        ldh [hSamusXScreen], a
        ret
    .keepResults:
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
    call collision_samusHorizontal.right
    jr nc, .keepResults
        ; Revert to previous position
        ld a, [prevSamusXPixel]
        ldh [hSamusXPixel], a
        ld a, [prevSamusXScreen]
        ldh [hSamusXScreen], a
        ret
    .keepResults:
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
    call collision_samusHorizontal.left
    jr nc, jr_000_1cf0
        ld a, [prevSamusXPixel]
        ldh [hSamusXPixel], a
        ld a, [prevSamusXScreen]
        ldh [hSamusXScreen], a
        ret
    jr_000_1cf0:
        ld a, b
        ld [camera_speedLeft], a
        ret
;}

samus_moveRightInAir: ;{ 00:1CF5
.turn:
    ld a, $01
    ld [samusFacingDirection], a
.noTurn: ; 00:1CFA Alternate entry
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
    call collision_samusHorizontal.right
    jr nc, .keepResults
        ; Revert to previous position
        ld a, [prevSamusXPixel]
        ldh [hSamusXPixel], a
        ld a, [prevSamusXScreen]
        ldh [hSamusXScreen], a
        ret
    .keepResults:
        ld a, b
        ld [camera_speedRight], a
        ret
;}

samus_moveLeftInAir: ;{ 00:1D22
.turn:
    xor a
    ld [samusFacingDirection], a
.noTurn: ; 00:1D26 - Alternate entry
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
    call collision_samusHorizontal.left
    jr nc, .keepResults
        ; Revert to previous position
        ld a, [prevSamusXPixel]
        ldh [hSamusXPixel], a
        ld a, [prevSamusXScreen]
        ldh [hSamusXScreen], a
        ret
    .keepResults:
        ld a, b
        ld [camera_speedLeft], a
        ret
;}

samus_moveVertical: ;{ 00:1D4E - move down
    ; Move up if negative
    bit 7, a
        jr nz, .moveUp
    ; else, move down
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
        ld a, [prevSamusYPixel]
        ldh [hSamusYPixel], a
        ld a, [prevSamusYScreen]
        ldh [hSamusYScreen], a
        scf
        ret
    .keepResults:
        ld a, [waterContactFlag]
        and a
        jr z, .endIf
            srl b
            ld a, [prevSamusYPixel]
            add b
            ldh [hSamusYPixel], a
            ld a, [prevSamusYScreen]
            adc $00
            ldh [hSamusYScreen], a
        .endIf:
        ld a, b
        ld [camera_speedDown], a
        ld a, [$d034]
        ld [$d033], a
        ret

.moveUp:
    cpl
    inc a
;} Fall-through to move up routine
    
samus_moveUp: ;{ 00:1D98 - Move up (only directly called by spider ball)
    ld b, a
    ldh a, [hSamusYPixel]
    sub b
    ldh [hSamusYPixel], a
    ldh a, [hSamusYScreen]
    sbc $00
    and $0f
    ldh [hSamusYScreen], a
    ld a, b
    call collision_samusTop
    jr nc, .keepResults
        ld a, samus_jumpArrayBaseOffset + $16 ;$56
        ld [samus_jumpArcCounter], a
        ld a, [prevSamusYPixel]
        ldh [hSamusYPixel], a
        ld a, [prevSamusYScreen]
        ldh [hSamusYScreen], a
        ret
    .keepResults:
        ld a, [waterContactFlag]
        and a
        jr z, .endIf
            srl b
            ld a, [prevSamusYPixel]
            sub b
            ldh [hSamusYPixel], a
            ld a, [prevSamusYScreen]
            sbc $00
            ldh [hSamusYScreen], a
        .endIf:
        ld a, b
        ld [camera_speedUp], a
        ret
;}
;}

;------------------------------------------------------------------------------
; BG collision functions {
collision_samusHorizontal: ;{ Has two entry points (left and right)
    .left: ; 00:1DD6 - Entry point for left-side collision
        push hl
        push de
        push bc
        ldh a, [hSamusXPixel]
        add $0b
        ld [$c204], a
        jr .start
    .right: ; 00:1DE2 - Entry point for right-side collision
        push hl
        push de
        push bc
        ldh a, [hSamusXPixel]
        add $14
        ld [$c204], a
.start: ; Start
    call Call_000_32cf ; Sprite collision?
        jp c, .exit

    ld hl, table_20FF
    ld a, [samusPose]
    sla a
    sla a
    sla a
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl+]
    cp $80
    jp z, .endIf_A
        ld [$d02d], a
        ld a, [hl+]
        cp $80
        jr z, .endIf_B
            ld [$d02e], a
            ld a, [hl+]
            cp $80
            jr z, .endIf_C
                ld [$d02f], a
                ld a, [hl+]
                cp $80
                jr z, .endIf_D
                    ld [$d030], a
                    ld a, [hl]
                    cp $80
                    jr z, .endIf_E
                        ld b, a
                        ldh a, [hSamusYPixel]
                        add b
                        ld [$c203], a
                        call samus_getTileIndex
                        ld hl, samusSolidityIndex
                        cp [hl]
                            jr c, .exit
                    .endIf_E:
                    ld a, [$d030]
                    ld b, a
                    ldh a, [hSamusYPixel]
                    add b
                    ld [$c203], a
                    call samus_getTileIndex
                    ld hl, samusSolidityIndex
                    cp [hl]
                        jr c, .exit
                .endIf_D:
                
                ld a, [$d02f]
                ld b, a
                ldh a, [hSamusYPixel]
                add b
                ld [$c203], a
                call samus_getTileIndex
                ld hl, samusSolidityIndex
                cp [hl]
                    jr c, .exit
            .endIf_C:
            
            ld a, [$d02e]
            ld b, a
            ldh a, [hSamusYPixel]
            add b
            ld [$c203], a
            call samus_getTileIndex
            ld hl, samusSolidityIndex
            cp [hl]
                jr c, .exit
        .endIf_B:
        
        ld a, [$d02d]
        ld b, a
        ldh a, [hSamusYPixel]
        add b
        ld [$c203], a
        call samus_getTileIndex
        ld hl, samusSolidityIndex
        cp [hl]
            jr c, .exit
    .endIf_A:

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
    call Call_000_34ef ; Sprite collision?
        jp c, .exit

; Top left side
    ldh a, [hSamusXPixel]
    add $0c
    ld [$c204], a
    ld hl, table_20E9
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
    jr z, .endIf_A
        ld a, $ff
        ld [waterContactFlag], a
        ld a, [hl]
    .endIf_A:

    bit blockType_up, a
    jr z, .endIf_B
        ; Invert the solidity
        ccf
    .endIf_B:

    ld a, [hl]
    bit blockType_acid, a
    jr z, .endIf_C
        ld a, $40
        ld [acidContactFlag], a
        push af
        ld a, [acidDamageValue]
        call applyDamage.acid
        pop af
    .endIf_C:

    jr c, .exit

; Top right side
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
    jr z, .endIf_D
        ld a, $ff
        ld [waterContactFlag], a
        ld a, [hl]
    .endIf_D:
    
    bit blockType_up, a
    jr z, .endIf_E
        ; Invert the solidity
        ccf
    .endIf_E:

    ld a, [hl]
    bit blockType_acid, a
    jr z, .endIf_F
        ld a, $40
        ld [acidContactFlag], a
        push af
        ld a, [acidDamageValue]
        call applyDamage.acid
        pop af
    .endIf_F:

.exit:
    pop bc
    pop de
    pop hl
ret
;}

; Samus downwards BG collision detection
Call_000_1f0f: ;{ 00:1F0F
    push hl
    push de
    push bc
    call Call_000_348d ; Sprite collision?
    jr nc, .endIf_A
        ld a, $01
        ld [samus_onSolidSprite], a
        ld a, l
        ld [$d05e], a
        ld a, h
        ld [$d05f], a
        ld a, $20
        ld [$d05d], a
        jp .exit
    .endIf_A:

; Bottom left side
    ldh a, [hSamusXPixel]
    add $0c
    ld [$c204], a
    ldh a, [hSamusYPixel]
    add $2c
    ld [$c203], a
    call samus_getTileIndex
    ld hl, samusSolidityIndex
    cp [hl]
    ; Carry set means a collision happened - carry clear means it didn't
    ld h, HIGH(collisionArray)
    ld l, a
    ld a, [hl]
    bit blockType_water, a
    jr z, .endIf_B
        ld a, $31 ; Set to $FF in every other circumstance (why?)
        ld [waterContactFlag], a
    .endIf_B:

    ld a, [hl]
    bit blockType_save, a
    jr z, .endIf_C
        ld a, $ff
        ld [saveContactFlag], a
    .endIf_C:

    ld a, [hl]
    bit blockType_down, a
    jr z, .endIf_D
        ld a, [samusPose] ; ?
        ; Clear carry flag
        scf
        ccf
    .endIf_D:

    ld a, [hl]
    bit blockType_acid, a
    jr z, .endIf_E
        ld a, $40
        ld [acidContactFlag], a
        push af
        ld a, [acidDamageValue]
        call applyDamage.acid
        pop af
    .endIf_E:

    jr c, .exit

; Bottom right side
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
    jr z, .endIf_F
        ld a, $ff
        ld [waterContactFlag], a
    .endIf_F:

    ld a, [hl]
    bit blockType_save, a
    jr z, .endIf_G
        ld a, $ff
        ld [saveContactFlag], a
    .endIf_G:

    ld a, [hl]
    bit blockType_down, a
    jr z, .endIf_H
        ; Clear carry flag (ignore collision)
        scf
        ccf
    .endIf_H:

    ld a, [hl]
    bit blockType_acid, a
    jr z, .endIf_I
        ld a, $40
        ld [acidContactFlag], a
        push af
        ld a, [acidDamageValue]
        call applyDamage.acid
        pop af
    .endIf_I:

    jr nc, .exit

    ld a, $00
    ld [samus_unmorphJumpTimer], a

.exit:
    pop bc
    pop de
    pop hl
ret
;}

;------------------------------------------------------------------------------
; Used by Spider Ball collision function
collision_checkSpiderPoint: ;{ 00:1FBF
    call samus_getTileIndex
    ld hl, samusSolidityIndex
    cp [hl]
        jr nc, .noHit

    ; Check if touching acid
    ld h, HIGH(collisionArray)
    ld l, a
    ld a, [hl]
    bit blockType_acid, a
    jr z, .endIf
        ld a, $40
        ld [acidContactFlag], a
        ld a, [acidDamageValue]
        call applyDamage.acid
    .endIf:
;exitWithHit
    ; Set carry
    scf
ret

.exitNoHit:
    ; Clear carry
    scf
    ccf
ret

.noHit:
    ; Check if touching acid
    ld h, HIGH(collisionArray)
    ld l, a
    ld a, [hl]
    bit blockType_acid, a
    jr z, .exitNoHit
        ld a, $40
        ld [acidContactFlag], a
        ld a, [acidDamageValue]
        call applyDamage.acid
    jr .exitNoHit
;}
;}

; end of BG collision functions

samus_getTileIndex: ;{ 00:1FF5
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
            ld [sfxRequest_square1], a
            ; Samus damaged flag
            ld a, $01
            ld [samus_hurtFlag], a
            ; Damage boost up
            xor a
            ld [$c423], a
            ; Samus damage
            ld a, [spikeDamageValue]
            ld [samus_damageValue], a
    .endIf_B:

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
    db $0F ; $00 - Standing
    db $0F ; $01 - Jumping
    db $0F ; $02 - Spin-jumping
    db $0F ; $03 - Running (set to 83h when turning)
    db $0F ; $04 - Crouching
    db $10 ; $05 - Morphball
    db $10 ; $06 - Morphball jumping
    db $0F ; $07 - Falling
    db $10 ; $08 - Morphball falling
    db $0F ; $09 - Starting to jump
    db $0F ; $0A - Starting to spin-jump
    db $10 ; $0B - Spider ball rolling
    db $10 ; $0C - Spider ball falling
    db $10 ; $0D - Spider ball jumping
    db $10 ; $0E - Spider ball
    db $0F ; $0F - Knockback
    db $10 ; $10 - Morphball knockback
    db $0F ; $11 - Standing bombed
    db $10 ; $12 - Morphball bombed
    db $0F ; $13 - Facing screen
    db $00
    db $00
    db $00
    db $00
    db $10 ; $18 - Being eaten by Metroid Queen
    db $10 ; $19 - In Metroid Queen's mouth
    db $1A ; $1A - Being swallowed by Metroid Queen
    db $1B ; $1B - In Metroid Queen's stomach
    db $1C ; $1C - Escaping Metroid Queen
    db $1D ; $1D - Escaped Metroid Queen
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
table_20A9: db 0, $4, $1, $4, $2, $2,  0, $2, $8,  0, $1, $4, $8, $8, $1,  0
table_20B9: db 0, $2, $4, $2, $8, $8,  0, $8, $1,  0, $4, $2, $1, $1, $4,  0
table_20C9: db 0, $1, $8, $8, $4, $1,  0, $8, $2,  0, $2, $2, $4, $1, $4,  0
table_20D9: db 0, $8, $2, $2, $1, $8,  0, $2, $4,  0, $4, $4, $1, $8, $1,  0
;}

table_20E9: ;{ 00:20E9 - Samus pose related (y pixel offsets?)
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
;}

table_20FF: ;{ 00:20FF - Y-Offset collision lists per pose ($80 terminated)
    db $10, $18, $20, $28, $2A, $80, 0, 0 ; $00 Standing
    db $14, $18, $20, $28, $2A, $80, 0, 0 ; $01 Jumping
    db $1A, $20, $28, $2A, $80, 0, 0, 0   ; $02 Spin-jumping
    db $10, $18, $20, $28, $2A, $80, 0, 0 ; $03 Running (set to 83h when turning)
    db $10, $18, $20, $28, $2A, $80, 0, 0 ; $04 Crouching
    db $20, $25, $2A, $80, 0, 0, 0, 0     ; $05 Morphball
    db $20, $25, $2A, $80, 0, 0, 0, 0     ; $06 Morphball jumping
    db $10, $18, $20, $28, $2A, $80, 0, 0 ; $07 Falling
    db $20, $25, $2A, $80, 0, 0, 0, 0     ; $08 Morphball falling
    db $10, $18, $20, $28, $2A, $80, 0, 0 ; $09 Starting to jump
    db $10, $18, $20, $28, $2A, $80, 0, 0 ; $0A Starting to spin-jump
    db $20, $25, $2B, $80, 0, 0, 0, 0     ; $0B Spider ball rolling
    db $20, $25, $2B, $80, 0, 0, 0, 0     ; $0C Spider ball falling
    db $20, $25, $2B, $80, 0, 0, 0, 0     ; $0D Spider ball jumping
    db $20, $25, $2B, $80, 0, 0, 0, 0     ; $0E Spider ball
    db $14, $18, $20, $28, $2A, $80, 0, 0 ; $0F Knockback
    db $20, $25, $2A, $80, 0, 0, 0, 0     ; $10 Morphball knockback
    db $10, $18, $20, $28, $2A, $80, 0, 0 ; $11 Standing bombed
    db $20, $25, $2A, $80, 0, 0, 0, 0     ; $12 Morphball bombed
    db $10, $18, $20, $28, $2A, $80, 0, 0 ; $13 Facing screen
    db 0, 0, 0, 0, 0, 0, 0, 0             ; $14
    db 0, 0, 0, 0, 0, 0, 0, 0             ; $15
    db 0, 0, 0, 0, 0, 0, 0, 0             ; $16
    db 0, 0, 0, 0, 0, 0, 0, 0             ; $17
    db $20, $25, $2A, $80, 0, 0, 0, 0     ; $18 Being eaten by Metroid Queen
    db $20, $25, $2A, $80, 0, 0, 0, 0     ; $19 In Metroid Queen's mouth
    db $20, $25, $2A, $80, 0, 0, 0, 0     ; $1A Being swallowed by Metroid Queen
    db $20, $25, $2A, $80, 0, 0, 0, 0     ; $1B In Metroid Queen's stomach
    db $20, $25, $2A, $80, 0, 0, 0, 0     ; $1C Escaping Metroid Queen
    db $20, $25, $2A, $80, 0, 0, 0, 0     ; $1D Escaped Metroid Queen 
;}

; Clear Projectile RAM
clearProjectileArray: ;{ 00:21EF
    ld h, HIGH(projectileArray)
    ld l, LOW(projectileArray)
    .loop:
        ld a, $ff
        ld [hl+], a
        ld a, l
        and a
    jr nz, .loop
ret
;}

Call_000_21fb:
    ld a, [samusPose]
    cp pose_faceScreen
        jp z, samusShoot_longJump
    ld a, [queen_eatingState]
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
    jr nz, .else
        ; Switch to beam
        ld a, [samusBeam]
        ld [samusActiveWeapon], a
        ld hl, gfxInfo_cannonBeam
        call Call_000_2753
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
        call Call_000_2753
        ; Play sound effect
        ld a, $15
        ld [sfxRequest_square1], a
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
    ld a, [scrollY]
    ld b, a
    ld a, [enemy_testPointYPos]
    add b
    ld [$c203], a
    ld a, [scrollX]
    ld b, a
    ld a, [enemy_testPointXPos]
    add b
    ld [$c204], a
    
beam_getTileIndex: ; 00:2266 - Entry point for beam routines
    call getTilemapAddress
    ld a, [gameOver_LCDC_copy]
    and $08
    jr z, .endIf
        ld a, $04
        add h
        ld h, a
        ld [pTilemapDestHigh], a
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

; Given pixels coordinates in y:[$C203], x:[$C204]
;  returns the tilemap address in [pTilemapDestLow] and [pTilemapDestHigh]
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
    ld [pTilemapDestLow], a
    ld a, h
    ld [pTilemapDestHigh], a
ret

unknown_22E1: ; 00:22E1 - Unused ?
    ld a, [pTilemapDestHigh]
    ld d, a
    ld a, [pTilemapDestLow]
    ld e, a
    ld b, $04

    .loop:
        rr d
        rr e
        dec b
    jr nz, .loop

    ld a, e
    sub $84
    and $fe
    rlca
    rlca
    add $08
    ld [$c203], a
    ld a, [pTilemapDestLow]
    and $1f
    rla
    rla
    rla
    add $08
    ld [$c204], a
ret

unknown_230C: ; 00:230C - Unused?
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
    callFar initializeAudio
ret

handleAudio_longJump: ;00:2384
    callFar handleAudio
ret

silenceAudio_longJump: ; 00:2390
    callFar silenceAudio
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
        ld [saveMessageCooldownTimer], a
        ld [saveContactFlag], a
        ld a, $88
        ldh [rWY], a
        call door_loadGraphics
        jp .nextToken
        
    .doorToken_copy:
    cp $00 ; COPY_DATA/COPY_BG/COPY_SPR
    jr nz, .doorToken_tiletable
        xor a
        ld [saveMessageCooldownTimer], a
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
        pop hl
        jp .nextToken

    .doorToken_warp:
    cp $40 ; WARP
    jr nz, .doorToken_escapeQueen
        call door_warp
        ld a, $01
        ld [doorExitStatus], a
        ld a, [queen_roomFlag]
        and $0f
        ld [queen_roomFlag], a
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
        
        ld a, $05
        ld [$d065], a
        call Call_000_27ba
        xor a
        ld [loadSpawnFlagsRequest], a
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
            ld [queen_roomFlag], a
            ld a, $88
            ldh [rWY], a
            ld a, $07
            ldh [rWX], a
            ldh a, [rIE]
            res 1, a
            ldh [rIE], a
            
            ld a, LOW(hudBaseTilemap) ; bank 5
            ldh [hVramTransfer.srcAddrLow], a
            ld a, HIGH(hudBaseTilemap)
            ldh [hVramTransfer.srcAddrHigh], a
            
            ld a, LOW(vramDest_statusBar)
            ldh [hVramTransfer.destAddrLow], a
            ld a, HIGH(vramDest_statusBar)
            ldh [hVramTransfer.destAddrHigh], a
            
            ld a, $14
            ldh [hVramTransfer.sizeLow], a
            ld a, $00
            ldh [hVramTransfer.sizeHigh], a
            
            ld a, $05
            ld [$d065], a
            call Call_000_27ba
        pop hl
        jp .nextToken

    .doorToken_enterQueen:
    cp $80 ; ENTER_QUEEN
    jr nz, .doorToken_compare
        xor a
        ld [samus_onscreenYPos], a
        ld [samus_onscreenXPos], a
        ldh [hOamBufferIndex], a
        ld [$d0a6], a
        ld a, $02
        ld [songRequest], a
        push hl
        call clearAllOam_longJump
        pop hl
        call waitOneFrame
        call OAM_DMA
        call Call_000_2887
        ld a, $01
        ld [doorExitStatus], a
        ld a, $11
        ld [queen_roomFlag], a
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
        ; Check if earthquake noise is playing
        ld a, [$cedf]
        cp $0e
        jr z, .song_else_A
            ; If the earthquake noise is not playing
            ld a, [hl+]
            and $0f
            cp $0a
            jr z, .song_else_B    
                ld [songRequest], a
                ld [currentRoomSong], a
                cp $0b
                jr nz, .song_else_C
                    ld a, $ff
                    ld [$d0a6], a
                    xor a
                    ld [$d0a5], a
                    jp .nextToken
                .song_else_C:
                    xor a
                    ld [$d0a5], a
                    ld [$d0a6], a
                    jp .nextToken
            .song_else_B:
                ld a, $ff
                ld [songRequest], a
                ld [currentRoomSong], a
                xor a
                ld [$d0a5], a
                ld a, $ff
                ld [$d0a6], a
                jp .nextToken
    
        .song_else_A:
            ; If the earthquake noise is playing
            ld a, [hl+]
            and $0f
            cp $0a
            jr z, .song_else_D
                ld [$d0a5], a
                cp $0b
                jr nz, .song_else_E
                    ld a, $ff
                    ld [$d0a6], a
                    jp .nextToken
                .song_else_E:
                    xor a
                    ld [$d0a6], a
                    jp .nextToken
            .song_else_D:
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
        ldh [hVramTransfer.srcAddrLow], a
        ld a, h
        ldh [hVramTransfer.srcAddrHigh], a

        ld a, LOW(vramDest_item)
        ldh [hVramTransfer.destAddrLow], a
        ld a, HIGH(vramDest_item)

        ldh [hVramTransfer.destAddrHigh], a
        ld a, $40
        ldh [hVramTransfer.sizeLow], a
        ld a, $00
        ldh [hVramTransfer.sizeHigh], a
        call Call_000_27ba
        ; Load item orb
        ld a, LOW(gfx_itemOrb)
        ldh [hVramTransfer.srcAddrLow], a
        ld a, HIGH(gfx_itemOrb)
        ldh [hVramTransfer.srcAddrHigh], a
        ld a, $00
        ldh [hVramTransfer.destAddrLow], a
        ld a, $8b
        ldh [hVramTransfer.destAddrHigh], a
        ld a, $40
        ldh [hVramTransfer.sizeLow], a
        ld a, $00
        ldh [hVramTransfer.sizeHigh], a
        call Call_000_27ba
        ; Load item font text
        ld a, BANK(gfx_itemFont)
        ld [bankRegMirror], a
        ld [$d065], a
        ld [rMBC_BANK_REG], a
        ld a, LOW(gfx_itemFont) ;$34
        ldh [hVramTransfer.srcAddrLow], a
        ld a, HIGH(gfx_itemFont) ;$6c
        ldh [hVramTransfer.srcAddrHigh], a
        ; VRAM Dest
        ld a, LOW(vramDest_itemFont)
        ldh [hVramTransfer.destAddrLow], a
        ld a, HIGH(vramDest_itemFont)
        ldh [hVramTransfer.destAddrHigh], a
        ; Write length
        ld a, $30
        ldh [hVramTransfer.sizeLow], a
        ld a, $02
        ldh [hVramTransfer.sizeHigh], a
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
        ldh [hVramTransfer.srcAddrLow], a
        ld a, h
        ldh [hVramTransfer.srcAddrHigh], a
        
        ld a, LOW(vramDest_itemText)
        ldh [hVramTransfer.destAddrLow], a
        ld a, HIGH(vramDest_itemText)
        ldh [hVramTransfer.destAddrHigh], a
        ld a, $10
        ldh [hVramTransfer.sizeLow], a
        ld a, $00
        ldh [hVramTransfer.sizeHigh], a
        call Call_000_27ba
        pop hl
        jr .nextToken

.nextToken:
    call waitOneFrame
    jp .readOneToken

.endDoorScript:
    ld a, [doorExitStatus]
    ld [saveLoadSpawnFlagsRequest], a
    xor a
    ld [doorIndexLow], a
    ld [doorIndexHigh], a
    ld [doorExitStatus], a
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
        ldh [hVramTransfer.srcAddrLow], a
        ld [saveBuf_enGfxSrcLow], a
        
        ld a, [hl+]
        ldh [hVramTransfer.srcAddrHigh], a
        ld [saveBuf_enGfxSrcHigh], a
        
        ld a, LOW(vramDest_enemies)
        ldh [hVramTransfer.destAddrLow], a
        ld a, HIGH(vramDest_enemies)
        ldh [hVramTransfer.destAddrHigh], a

        ld a, $00
        ldh [hVramTransfer.sizeLow], a
        ld a, $04
        ldh [hVramTransfer.sizeHigh], a
    jp Jump_000_27ba

    jr_000_271c:
        ld a, [hl+]
        ld [bankRegMirror], a
        ld [$d065], a
        ld [saveBuf_bgGfxSrcBank], a
        ld [rMBC_BANK_REG], a
        
        ld a, [hl+]
        ldh [hVramTransfer.srcAddrLow], a
        ld [saveBuf_bgGfxSrcLow], a
        ld a, [hl+]
        ldh [hVramTransfer.srcAddrHigh], a
        ld [saveBuf_bgGfxSrcHigh], a
        
        ld a, LOW(vramDest_bgTiles)
        ldh [hVramTransfer.destAddrLow], a
        ld a, HIGH(vramDest_bgTiles)
        ldh [hVramTransfer.destAddrHigh], a
        
        ld a, $00
        ldh [hVramTransfer.sizeLow], a
        ld a, $08
        ldh [hVramTransfer.sizeHigh], a
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
    jr jr_000_27ba

jr_000_2771:
    ld a, [hl+]
    ld [bankRegMirror], a
    ld [$d065], a
    ld [saveBuf_bgGfxSrcBank], a
    ld [rMBC_BANK_REG], a
    ld a, [hl+]
    ldh [hVramTransfer.srcAddrLow], a
    ld [saveBuf_bgGfxSrcLow], a
    ld a, [hl+]
    ldh [hVramTransfer.srcAddrHigh], a
    ld [saveBuf_bgGfxSrcHigh], a
    ld a, [hl+]
    ldh [hVramTransfer.destAddrLow], a
    ld a, [hl+]
    ldh [hVramTransfer.destAddrHigh], a
    ld a, [hl+]
    ldh [hVramTransfer.sizeLow], a
    ld a, [hl+]
    ldh [hVramTransfer.sizeHigh], a
    jr jr_000_27ba

jr_000_2798:
    ld a, [hl+]
    ld [bankRegMirror], a
    ld [$d065], a
    ld [rMBC_BANK_REG], a
    ld a, [hl+]
    ldh [hVramTransfer.srcAddrLow], a
    ld [saveBuf_enGfxSrcLow], a
    ld a, [hl+]
    ldh [hVramTransfer.srcAddrHigh], a
    ld [saveBuf_enGfxSrcHigh], a
    ld a, [hl+]
    ldh [hVramTransfer.destAddrLow], a
    ld a, [hl+]
    ldh [hVramTransfer.destAddrHigh], a
    ld a, [hl+]
    ldh [hVramTransfer.sizeLow], a
    ld a, [hl+]
    ldh [hVramTransfer.sizeHigh], a

Call_000_27ba:
Jump_000_27ba:
jr_000_27ba:
    ld a, $ff
    ld [vramTransferFlag], a

    jr_000_27bf:
        ld a, [$d08c]
        and a
        jr z, jr_000_27d9
            call drawSamus_longJump
            call handleEnemiesOrQueen
            callFar drawHudMetroid
            call clearUnusedOamSlots_longJump
        jr_000_27d9:
        ; Wait until WRAM transfer is done
        call waitOneFrame
        ld a, [vramTransferFlag]
        and a
    jr nz, jr_000_27bf
ret

; Used for animating the Varia Suit collection
Call_000_27e3: ; 00:27E3
    ld a, [hl+]
    ld [bankRegMirror], a
    ld [$d065], a
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
    ld a, $ff
    ld [vramTransferFlag], a

    jr_000_2804:
        ld a, $80
        ldh [rWY], a
        call drawSamus_longJump
        call handleEnemiesOrQueen
        callFar drawHudMetroid
        call clearUnusedOamSlots_longJump
        call waitOneFrame
        ldh a, [hVramTransfer.destAddrHigh]
        cp $85
    jr c, jr_000_2804

    xor a
    ld [$d08c], a
    ret


door_loadTiletable:
    switchBank metatilePointerTable
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
    switchBank collisionPointerTable
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

; Only called from the ENTER_QUEEN
Call_000_2887: ; 00:2887
    ld a, [hl+]
    and $0f
    ld [currentLevelBank], a
    ld [saveBuf_currentLevelBank], a
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    
    ld a, [hl+]
    ldh [hCameraYPixel], a
    sub $48
    ld [scrollY], a
    ld a, [hl+]
    ldh [hCameraYScreen], a
    ld a, [hl+]
    ldh [hCameraXPixel], a
    sub $50
    ld [scrollX], a
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
        call queen_renderRoom
        callFar queen_initialize
        ldh a, [hCameraXPixel]
        ld b, a
        ldh a, [hSamusXPixel]
        sub b
        add $60
        ld [samus_onscreenXPos], a
        ldh a, [hCameraYPixel]
        ld b, a
        ldh a, [hSamusYPixel]
        sub b
        add $62
        ld [samus_onscreenYPos], a
        ld a, $e3
        ldh [rLCDC], a
        xor a
        ld [doorScrollDirection], a
        ld [scrollY], a
        ldh [rSCY], a
        ld a, [bg_palette]
        cp $93
        jr z, jr_000_28f9
            ld a, $2f
            ld [fadeInTimer], a
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
    switchBankVar [currentLevelBank]
    ld a, LOW(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrLow], a
    ld a, HIGH(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrHigh], a
    ld a, $ff
    ld [mapUpdate_unusedVar], a
    ldh a, [hCameraXPixel]
    add $50
    ldh [hMapSource.xPixel], a
    ldh a, [hCameraXScreen]
    adc $00
    and $0f
    ldh [hMapSource.xScreen], a
    ldh a, [hCameraYPixel]
    sub $74
    ldh [hMapSource.yPixel], a
    ldh a, [hCameraYScreen]
    sbc $00
    and $0f
    ldh [hMapSource.yScreen], a
    call prepMapUpdate.column
    call waitOneFrame
    
    switchBankVar [currentLevelBank]
    ld a, LOW(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrLow], a
    ld a, HIGH(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrHigh], a
    ld a, $ff
    ld [mapUpdate_unusedVar], a
    ldh a, [hCameraXPixel]
    add $60
    ldh [hMapSource.xPixel], a
    ldh a, [hCameraXScreen]
    adc $00
    and $0f
    ldh [hMapSource.xScreen], a
    call prepMapUpdate.column
    call waitOneFrame
    
    switchBankVar [currentLevelBank]
    ld a, LOW(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrLow], a
    ld a, HIGH(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrHigh], a
    ld a, $ff
    ld [mapUpdate_unusedVar], a
    ldh a, [hCameraXPixel]
    add $70
    ldh [hMapSource.xPixel], a
    ldh a, [hCameraXScreen]
    adc $00
    and $0f
    ldh [hMapSource.xScreen], a
    call prepMapUpdate.column
    pop hl
ret


Jump_000_29c4:
    switchBankVar [currentLevelBank]
    ld a, LOW(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrLow], a
    ld a, HIGH(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrHigh], a
    ld a, $ff
    ld [mapUpdate_unusedVar], a
    ldh a, [hCameraXPixel]
    sub $60
    ldh [hMapSource.xPixel], a
    ldh a, [hCameraXScreen]
    sbc $00
    and $0f
    ldh [hMapSource.xScreen], a
    ldh a, [hCameraYPixel]
    sub $74
    ldh [hMapSource.yPixel], a
    ldh a, [hCameraYScreen]
    sbc $00
    and $0f
    ldh [hMapSource.yScreen], a
    call prepMapUpdate.column
    call waitOneFrame
    
    switchBankVar [currentLevelBank]
    ld a, LOW(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrLow], a
    ld a, HIGH(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrHigh], a
    ld a, $ff
    ld [mapUpdate_unusedVar], a
    ldh a, [hCameraXPixel]
    sub $70
    ldh [hMapSource.xPixel], a
    ldh a, [hCameraXScreen]
    sbc $00
    and $0f
    ldh [hMapSource.xScreen], a
    call prepMapUpdate.column
    call waitOneFrame
    
    switchBankVar [currentLevelBank]
    ld a, LOW(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrLow], a
    ld a, HIGH(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrHigh], a
    ld a, $ff
    ld [mapUpdate_unusedVar], a
    ldh a, [hCameraXPixel]
    sub $80
    ldh [hMapSource.xPixel], a
    ldh a, [hCameraXScreen]
    sbc $00
    and $0f
    ldh [hMapSource.xScreen], a
    call prepMapUpdate.column
    pop hl
ret


Jump_000_2a4f:
    switchBankVar [currentLevelBank]
    ld a, LOW(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrLow], a
    ld a, HIGH(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrHigh], a
    ld a, $ff
    ld [mapUpdate_unusedVar], a
    ldh a, [hCameraXPixel]
    sub $80
    ldh [hMapSource.xPixel], a
    ldh a, [hCameraXScreen]
    sbc $00
    and $0f
    ldh [hMapSource.xScreen], a
    ldh a, [hCameraYPixel]
    add $78
    ldh [hMapSource.yPixel], a
    ldh a, [hCameraYScreen]
    adc $00
    and $0f
    ldh [hMapSource.yScreen], a
    call prepMapUpdate.row
    call waitOneFrame
    
    switchBankVar [currentLevelBank]
    ld a, LOW(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrLow], a
    ld a, HIGH(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrHigh], a
    ld a, $ff
    ld [mapUpdate_unusedVar], a
    ldh a, [hCameraYPixel]
    add $68
    ldh [hMapSource.yPixel], a
    ldh a, [hCameraYScreen]
    adc $00
    and $0f
    ldh [hMapSource.yScreen], a
    call prepMapUpdate.row
    call waitOneFrame
    
    switchBankVar [currentLevelBank]
    ld a, LOW(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrLow], a
    ld a, HIGH(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrHigh], a
    ld a, $ff
    ld [mapUpdate_unusedVar], a
    ldh a, [hCameraYPixel]
    add $58
    ldh [hMapSource.yPixel], a
    ldh a, [hCameraYScreen]
    adc $00
    and $0f
    ldh [hMapSource.yScreen], a
    call prepMapUpdate.row
    call waitOneFrame
    
    switchBankVar [currentLevelBank]
    ld a, LOW(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrLow], a
    ld a, HIGH(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrHigh], a
    ld a, $ff
    ld [mapUpdate_unusedVar], a
    ldh a, [hCameraYPixel]
    add $48
    ldh [hMapSource.yPixel], a
    ldh a, [hCameraYScreen]
    adc $00
    and $0f
    ldh [hMapSource.yScreen], a
    call prepMapUpdate.row
    pop hl
ret


Jump_000_2b04:
    switchBankVar [currentLevelBank]
    ld a, LOW(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrLow], a
    ld a, HIGH(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrHigh], a
    ld a, $ff
    ld [mapUpdate_unusedVar], a
    ldh a, [hCameraXPixel]
    sub $80
    ldh [hMapSource.xPixel], a
    ldh a, [hCameraXScreen]
    sbc $00
    and $0f
    ldh [hMapSource.xScreen], a
    ldh a, [hCameraYPixel]
    sub $78
    ldh [hMapSource.yPixel], a
    ldh a, [hCameraYScreen]
    sbc $00
    and $0f
    ldh [hMapSource.yScreen], a
    call prepMapUpdate.row
    call waitOneFrame
    
    switchBankVar [currentLevelBank]
    ld a, LOW(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrLow], a
    ld a, HIGH(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrHigh], a
    ld a, $ff
    ld [mapUpdate_unusedVar], a
    ldh a, [hCameraYPixel]
    sub $68
    ldh [hMapSource.yPixel], a
    ldh a, [hCameraYScreen]
    sbc $00
    and $0f
    ldh [hMapSource.yScreen], a
    call prepMapUpdate.row
    call waitOneFrame
    
    switchBankVar [currentLevelBank]
    ld a, LOW(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrLow], a
    ld a, HIGH(mapUpdateBuffer)
    ldh [hMapUpdate.buffPtrHigh], a
    ld a, $ff
    ld [mapUpdate_unusedVar], a
    ldh a, [hCameraYPixel]
    sub $58
    ldh [hMapSource.yPixel], a
    ldh a, [hCameraYScreen]
    sbc $00
    and $0f
    ldh [hMapSource.yScreen], a
    call prepMapUpdate.row
    pop hl
ret


Jump_000_2b8f:
    ld a, [mapUpdateFlag]
    and a
        jr z, VBlank_vramDataTransfer.exit
    switchBankVar [currentLevelBank]
    call VBlank_updateMap
jr VBlank_vramDataTransfer.exit

VBlank_vramDataTransfer: ; 00:2BA3
    ld a, [$d08c]
    and a
        jp nz, Jump_000_2bf4

    ; Load transfer parameters
    ld a, [$d065]
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
    ld a, $01
    ldh [hVBlankDoneFlag], a
    ld a, [bankRegMirror]
    ld [rMBC_BANK_REG], a
    pop hl
    pop de
    pop bc
    pop af
reti

; Varia animation case
Jump_000_2bf4: ; 00:2BF4
    ldh a, [frameCounter]
    and $01
    jr nz, jr_000_2c42

    ld a, [$d065]
    ld [rMBC_BANK_REG], a
    ldh a, [hVramTransfer.destAddrLow] ; ??
    ld l, a
    ldh a, [hVramTransfer.destAddrHigh] ; ??
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
    ldh [hVramTransfer.destAddrLow], a
    ld a, h
    ldh [hVramTransfer.destAddrHigh], a
    cp $85
    jr nz, jr_000_2c42
        xor a
        ld [deathAnimTimer], a
    jr_000_2c42:
    
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
reti


waitOneFrame: ; 00:2C5E
    push hl
    call handleAudio_longJump
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


tryPausing: ; 00:2C79
    ; Don't try pausing unless start is pressed
    ldh a, [hInputRisingEdge]
    cp PADF_START
        ret nz
    ; Exit if in Queen's room
    ld a, [queen_roomFlag]
    cp $11
        ret z
    ; No pausing if facing the screen
    ld a, [samusPose]
    cp pose_faceScreen
        ret z
    ld a, [doorScrollDirection]
    and a
        ret nz
    ld a, [saveContactFlag]
    and a
        ret nz

    ld hl, metroidLCounterTable
    ld a, [metroidCountReal]
    ld e, a
    ld d, $00
    add hl, de
    ld a, [hl]
    ld [metroidLCounterDisp], a
    ; Clear L counter value if an earthquake is either queued up or happening
    ld a, [nextEarthquakeTimer]
    and a
    jr nz, .else_A
        ld a, [earthquakeTimer]
        and a
        jr z, .endIf_A
    .else_A:
        xor a
        ld [metroidLCounterDisp], a
    .endIf_A:

    ld a, [debugFlag]
    and a
    jr z, .endIf_B
        xor a
        ldh [hOamBufferIndex], a
        call clearUnusedOamSlots_longJump
    .endIf_B:

    xor a
    ld [debugItemIndex], a
    ld [unused_D011], a
    ld hl, wram_oamBuffer + $2

    .loop:
        ld a, [hl]
        and $9a
        cp $9a
            jr z, .break
        ld a, l
        add $04
        ld l, a
        cp $a0
    jr c, .loop

    jr .exit

.break:
    ld de, $0004
    ld a, $36
    ld [hl], a
    add hl, de
    ld a, $0f
    ld [hl], a

.exit:
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
    ld a, [$c423]
    ld [$d00f], a
    ld a, [queen_roomFlag]
    cp $11
    jr nz, .endIf
        ; Force damage boost to right if in Queen's room
        ld a, $01
        ld [$d00f], a
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
        ldh a, [frameCounter]
        and $07
            ret nz
        ld a, $07
        ld [sfxRequest_noise], a
        ldh a, [frameCounter]
        and $0f
            ret nz
        ld b, $02
        jr .apply
    .larvaMetroid: ; 00:2F3C
        ; Any enemies with a damage value of $FE inflicts continuous contact damage.
        ; In the game, this only applies to the larva metroids.
        ld b, $03
        ldh a, [frameCounter]
        and $07
            ret nz
        ld a, $07
        ld [sfxRequest_noise], a
        jr .apply
    .acid: ; 00:2F4A
        ld b, a
        ldh a, [frameCounter]
        and $0f
            ret nz
        ld a, $07
        ld [sfxRequest_noise], a
        jr .apply
    .enemySpike: ; 00:2F57
        ; Apply damage from enemies, spikes, and respawning blocks
        ld b, a
        ; Arbitrarily limit damage to 96 units
        cp $60
            ret nc
        ; Play sound
        ld a, $06
        ld [sfxRequest_noise], a
.apply: ; Apply damage
    ; Half damage with varia
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

gameMode_dying: ; 00:2F86
    ; Do some things, only during the queen fight
    ld a, [queen_roomFlag]
    cp $11
    jr nz, .endIf
        call drawSamus_longJump ; Draw Samus
        call drawHudMetroid_longJump
        callFar queenHandler
        call clearUnusedOamSlots_longJump
    .endIf:
ret


killSamus: ; Kill Samus
    call silenceAudio_longJump ; Music related

    ld a, $0b
    ld [sfxRequest_noise], a
    call waitOneFrame
    call drawSamus_ignoreDamageFrames_longJump ; Draw Samus regardless of i-frames

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

; 00:2FC8 - Unused
    ld a, $a0
    ld [samus_turnAnimTimer], a
    ld a, $80 | pose_standing
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

    ld a, [scrollY]
    ldh [rSCY], a
    ld a, [scrollX]
    ldh [rSCX], a
    call OAM_DMA

    ; Queen vblank handler if necessary
    ld a, BANK(VBlank_drawQueen)
    ld [rMBC_BANK_REG], a
    ld a, [queen_roomFlag]
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
unusedDeathAnimation: ;{ 00:3062
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

; 00:30BB - Bomb-enemy collision detection
Call_000_30bb: ; 00:30BB
    ldh a, [hSpriteYPixel]
    ldh [$98], a
    ldh a, [hSpriteXPixel]
    ldh [$99], a
    ld a, $03
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    ld hl, $c600

    .loop:
        ld a, [hl]
        and $0f
        jr nz, .endIf
            call Call_000_30ea
                jr c, .break
        .endIf:
        ld de, $0020
        add hl, de
        ld a, h
        cp $c8
    jr nz, .loop
    .break:
    
    ld a, $01
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
ret


Call_000_30ea:
    push hl
    ; Load enemy Y
    inc hl
    ld a, [hl+]
    cp $e0
        jp nc, .exit_noHit
    ldh [$b7], a
    ; Load enemy X
    ld a, [hl+]
    cp $e0
        jp nc, .exit_noHit
    ldh [$b8], a
    ; Load enemy sprite type
    ld a, [hl+]
    ldh [$b9], a
    ; Load enemy attributes
    inc hl
    ld a, [hl+]
    ldh [$bf], a
    ; Load hitbox pointer of enemy
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
    ; Save en Y to B
    ldh a, [$b7]
    ld b, a
    ldh a, [$bf]
    bit 6, a
    jr nz, .else_A
        ld a, [hl+]
        add b
        sub $10
        ldh [$ba], a
        ld a, [hl+]
        add b
        add $10
        ldh [$bb], a
        jr .endIf_A
    .else_A:
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
    .endIf_A:

    ldh a, [$b8]
    ld b, a
    ldh a, [$bf]
    bit 5, a
    jr nz, .else_B
        ld a, [hl+]
        add b
        sub $10
        ldh [$bc], a
        ld a, [hl+]
        add b
        add $10
        ldh [$bd], a
        jr .endIf_B
    .else_B:
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
    .endIf_B:

    ldh a, [$ba]
    ld b, a
    ldh a, [$bb]
    sub b
    ld c, a
    ldh a, [$98]
    sub b
    cp c
        jr nc, .exit_noHit

    ldh a, [$bc]
    ld b, a
    ldh a, [$bd]
    sub b
    ld c, a
    ldh a, [$99]
    sub b
    cp c
        jr nc, .exit_noHit
; A collision happened
    ld a, $09
    ld [$d05d], a
    pop hl
    ld a, l
    ld [$d05e], a
    ld a, h
    ld [$d05f], a
    
    ld a, [queen_eatingState]
    cp $03
    jr nz, .endIf_C
        ldh a, [$b9]
        cp $f1
        jr nz, .endIf_C
            ld a, $04
            ld [queen_eatingState], a
    .endIf_C:

    ld a, [queen_eatingState]
    cp $06
    jr nz, .endIf_D
        ldh a, [$b9]
        cp $f3
        jr nz, .endIf_D
            ld a, $07
            ld [queen_eatingState], a
            ld a, $1c
            ld [samusPose], a
    .endIf_D:
    ; A collision happened
    scf
ret

.exit_noHit:
;.exit_noHit:
    pop hl
    scf
    ccf
ret

Call_000_31b6: ; 00:31B6 - Projectile/enemy collision function
    ld a, [scrollY]
    ld b, a
    ld a, [$c203]
    sub b
    ldh [$98], a
    ld a, [scrollX]
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
    ; Ignore collision if X or Y position is too high?
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
            ld [queen_eatingState], a
    jr_000_32a5:
    ; A collision happened
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

    ld a, [samus_onscreenXPos]
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
    ld hl, table_369B
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
    cp pose_spinJump
        jr z, jr_000_33f6
    ld a, [samusPose]
    cp pose_spinStart
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

    ld [samus_damageValue], a
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
        cp pose_morph
        jr z, jr_000_343c
            cp pose_morphJump
            jr z, jr_000_343c
                cp pose_morphFall
                    jr nz, jr_000_3446
            jr_000_343c:
                ld a, $01
                ld [queen_eatingState], a
                ld a, $18
                ld [samusPose], a
    jr_000_3446:
    ; A collision happened
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
    ld [samus_damageValue], a
    ld a, $01
    ld [samus_hurtFlag], a
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
    call applyDamage.larvaMetroid

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

; Exit that clears the carry flag (indicates no collision happened)
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

    ld a, [samus_onscreenYPos]
    add $12
    ldh [$98], a
    xor a
    ld [samus_onSolidSprite], a
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
            ld a, [samus_damageValue]
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
    ld hl, table_369B
    add hl, de
    ld a, [hl+]
    ld b, a
    ld a, [samus_onscreenYPos]
    add b
    ldh [$98], a
    xor a
    ld [samus_onSolidSprite], a
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
    cp pose_spinJump
        jr z, jr_000_35fe
    ld a, [samusPose]
    cp pose_spinStart
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
    ld [samus_damageValue], a
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
        cp pose_morph
            jr z, jr_000_3644
            cp pose_morphJump
                jr z, jr_000_3644
                cp pose_morphFall
                jr nz, jr_000_364e
            jr_000_3644:
                ld a, $01
                ld [queen_eatingState], a
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

    ld [samus_damageValue], a
    ld a, $01
    ld [samus_hurtFlag], a
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
    call applyDamage.larvaMetroid

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


; Common exits for collision routines that clear the carry flag (indicating no collision happened)
Jump_000_3694:
    pop hl
    scf
    ccf
    ret

Jump_000_3698:
    scf
    ccf
    ret

table_369B: ; 00:369B - Collision/pose related table
    db $ec, $f4, $fc, $ec, $f6, $04, $04, $ec, $04, $ec, $ec, $04, $04, $04, $04, $ec
    db $04, $ec, $04, $ec, $04

gameMode_dead: ;{ 00:36B0
    ; Wait until the death sound ends
    .loopWaitSilence:
        call handleAudio_longJump
        call waitForNextFrame
        ld a, [$ced6]
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
    ld [$cede], a
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
            ld [$cede], a
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
            ld [$cede], a
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
    ld a, [$cedf]
    cp $0e
    jr nz, .endIf_C
        ld a, $00
        ld [$cede], a
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
    call Call_000_2753
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
    call Call_000_2753
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
    call Call_000_2753
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
    call Call_000_2753
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
        call Call_000_2753
        ld hl, gfxInfo_spinScrewBottom
        call Call_000_2753
        jp handleItemPickup_end
    .else:
        ; With space jump
        ld hl, gfxInfo_spinSpaceScrewTop
        call Call_000_2753
        ld hl, gfxInfo_spinSpaceScrewBottom
        call Call_000_2753
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
    ld [$d08c], a
    ; Fancy loading animation (only loads first 5 rows)
    ld hl, gfxInfo_variaSuit
    call Call_000_27e3
    ; Clear flag
    xor a
    ld [$d08c], a
    ; Load all the varia graphics
    ld hl, gfxInfo_variaSuit
    call Call_000_2753
    ; Load cannon graphics if missiles are active
    ld hl, gfxInfo_cannonMissile
    ld a, [samusActiveWeapon]
    cp $08
        call z, Call_000_2753
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
        call Call_000_2753
        ld hl, gfxInfo_spinSpaceBottom
        call Call_000_2753
        jp handleItemPickup_end
    .else:
        ; With screw attack
        ld hl, gfxInfo_spinSpaceScrewTop
        call Call_000_2753
        ld hl, gfxInfo_spinSpaceScrewBottom
        call Call_000_2753
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
    call Call_000_2753
    ld hl, gfxInfo_springBallBottom
    call Call_000_2753
jp handleItemPickup_end ;}

pickup_energyTank: ;{
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
        ld [$cede], a
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
        ld a, [$cedf]
        cp $0e
        jr z, .endIf_B
            ld a, $03
            ld [$cede], a
    .endIf_B:
    ; Clear flag
    xor a
    ld [itemCollected_copy], a
    ; Signal to item object that this sequence is completed
    ld a, $03
    ld [itemCollectionFlag], a
    
    ; Set collision variables
    ld a, [itemOrb_collisionType]
    ld [$c466], a
    ld a, [itemOrb_pEnemyWramLow]
    ld [$c467], a
    ld a, [itemOrb_pEnemyWramHigh]
    ld [$c468], a

    .waitLoop_B:
        ; Perform common functions during this wait loop
        call drawSamus_longJump
        call drawHudMetroid_longJump
        call Call_000_32ab
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
        call Call_000_2753
        ld hl, gfxInfo_springBallBottom
        call Call_000_2753
    .endIf_spring:

    ; Load appropriate spin-jump graphics
    ; (3 options, mutually exclusive)
    ld a, [samusItems]
    and itemMask_space | itemMask_screw
    cp itemMask_space | itemMask_screw
    jr nz, .endIf_spinBoth
        ; Both space jump and screw attack
        ld hl, gfxInfo_spinSpaceScrewTop
        call Call_000_2753
        ld hl, gfxInfo_spinSpaceScrewBottom
        call Call_000_2753
        ret
    .endIf_spinBoth:

    cp itemMask_space
    jr nz, .endIf_space
        ; Only space jump
        ld hl, gfxInfo_spinSpaceTop
        call Call_000_2753
        ld hl, gfxInfo_spinSpaceBottom
        call Call_000_2753
        ret
    .endIf_space:
    
    cp itemMask_screw
        ret nz
    ; Only screw attack
    ld hl, gfxInfo_spinScrewTop
    call Call_000_2753
    ld hl, gfxInfo_spinScrewBottom
    call Call_000_2753
ret ;}

; Game modes $0A and $0F
;  Displays "GAME SAVED" screen (incorrectly)
gameMode_unusedA: ;{ 00:3ACE
    ; Clear sound, graphics, etc.
    call silenceAudio_longJump
    ld a, $ff
    ld [$cfe5], a
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
    ld [$cfe5], a
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
            ld hl, gfxInfo_plasma
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
    ld [$d065], a
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

Call_000_3d99: ; 00:3D99
    jpLong Call_001_549d ; $549d

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

; 00:3F07
; unused (duplicate of the routine at 00:3062)
unusedDeathAnimation_copy: ;{ 00:3F07
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
reti
;}

; Freespace - 00:3F60 (filled with $00)
