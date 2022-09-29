; Disassembly of "Metroid2.gb"
; This file was created with:
; mgbdis v1.4 - Game Boy ROM disassembler by Matt Currie and contributors.
; https://github.com/mattcurrie/mgbdis

SECTION "ROM Bank $004", ROMX[$4000], BANK[$4]

externalHandleAudio:
    jp handleAudio

externalSilenceAudio:
    jp silenceAudio

externalInitializeAudio:
    jp initializeAudio

; Song processing state size constants
;{
    channelSongProcessingStateSize:
    db $09 ; Size of channel song processing state ($CF38 - $CF2F)

    channelAllSongProcessingStateSizes:
    db $2d ; Size of all channel song processing states ($CF5C - $CF2F)

    songProcessingStateSize:
    db $61 ; Size of song processing state ($CF61 - songTranspose)
;}

musicNotes:
;{
    dw $8000 ; Off-key 64Hz "tone"

;      C      Db     D      Eb     E      F      Gb     G      Ab     A      Bb     B
    dw $802c, $809c, $8106, $816b, $81c9, $8223, $8277, $82c6, $8312, $8356, $839b, $83da ; Octave 2
    dw $8416, $844e, $8483, $84b5, $84e5, $8511, $853b, $8563, $8589, $85ac, $85ce, $85ed ; Octave 3
    dw $860a, $8627, $8642, $865b, $8672, $8689, $869e, $86b2, $86c4, $86d6, $86e7, $86f7 ; Octave 4
    dw $8706, $8714, $8721, $872d, $8739, $8744, $874f, $8759, $8762, $876b, $8773, $877b ; Octave 5
    dw $8783, $878a, $8790, $8797, $879d, $87a2, $87a7, $87ac, $87b1, $87b6, $87ba, $87be ; Octave 6
    dw $87c1, $87c4, $87c8, $87cb, $87ce, $87d1, $87d4, $87d6, $87d9, $87db, $87dd, $87df ; Octave 7
;}

instructionTimerArrays:
;{
    db $01, $01, $02, $04, $08, $10, $03, $06, $0c, $01, $03, $01, $20
    db $01, $02, $04, $08, $10, $20, $06, $0c, $18, $02, $05, $01, $40
    db $02, $03, $06, $0c, $18, $30, $09, $12, $24, $04, $08, $01, $60
    db $02, $04, $08, $10, $20, $40, $0c, $18, $30, $05, $0a, $01, $80
    db $03, $05, $0a, $14, $28, $50, $0f, $1e, $3c, $07, $0e, $01, $a0
    db $03, $06, $0c, $18, $30, $60, $12, $24, $48, $08, $10, $02, $c0
    db $03, $07, $0e, $1c, $38, $70, $15, $2a, $54, $09, $12, $02, $e0
    db $04, $08, $10, $20, $40, $80, $18, $30, $60, $0a, $14, $02, $ff
    db $04, $09, $12, $24, $48, $90, $1b, $36, $6c, $0c, $1a, $02, $ff
;}

wavePatterns:
;{
.wave0 ; $4113
    db $ee, $ee, $a5, $e5, $e0, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

.wave1 ; $4123
    db $cc, $cc, $82, $c3, $c0, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
; Unused data
    db $77, $77, $51, $a2, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    db $fe, $dc, $ba, $98, $8a, $a8, $32, $10, $fe, $ed, $db, $a9, $87, $65, $31, $00
    db $99, $aa, $bb, $cc, $bb, $aa, $77, $33, $11, $34, $67, $89, $aa, $a7, $87, $78
    db $ab, $ef, $fe, $da, $97, $43, $11, $31
.wave2 ; $416B
    db $EE, $EE, $EE, $00, $00, $00, $EE, $EE, $EE, $00, $00, $00, $EE, $00, $EE, $00

.wave3 ; $417B
    db $AA, $AA, $AA, $00, $00, $00, $AA, $AA, $AA, $00, $00, $00, $AA, $00, $AA, $00

.wave4 ; $418B
    db $77, $77, $77, $00, $00, $00, $77, $77, $77, $00, $00, $00, $77, $00, $77, $00

.wave5 ; $419B
    db $44, $00, $22, $00, $00, $00, $22, $44, $44, $00, $00, $00, $33, $00, $44, $00

.wave6 ; $41AB
    db $FF, $FF, $00, $00, $FF, $FF, $00, $00, $FF, $FF, $00, $00, $FF, $FF, $00, $00
;}

songNoiseChannelOptionSets:
;{
; Used by songs

; Sound length
;     00tttttt
;     Sound length = 0.25 * (1 - t/40h) seconds
;
; Envelope
;     vvvvdttt
;     Envelope step length = t/8 * 0.125 seconds
;     d: Envelope direction. 0: Decrease, 1: Increase
;     v: Initial volume
;
; Polynomial counter
;     nnnnwaaa
;     If a = 0:
;         Frequency = 80000h / 2^n hertz
;     Else:
;         Frequency = 40000h / (a * 2^n) hertz
;     w: Counter width. 0: 7 bits, 1: 15 bits
;
; Counter control
;     rs000000
;     r: Restart sound
;     s: Stop output after sound has finished (according to sound length)

;       _____________ Sound length
;      |    _________ Envelope
;      |   |    _____ Polynomial counter
;      |   |   |    _ Counter control
;      |   |   |   |
    db $00,$08,$00,$80
    db $00,$21,$3D,$80 ; Can never be used (in song handler, '1' disables sound channel)
    db $30,$40,$31,$C0
    db $00,$31,$3E,$80
    db $35,$F7,$6E,$C0
    db $30,$61,$4B,$C0
    db $30,$C1,$6D,$C0
    db $00,$81,$4B,$80
    db $00,$F6,$6D,$80
    db $00,$B6,$6D,$80
    db $00,$77,$6D,$80
    db $00,$47,$6D,$80
    db $00,$97,$6B,$80
    db $00,$77,$6B,$80
    db $00,$57,$6B,$80
    db $00,$37,$6B,$80
    db $00,$80,$6D,$80
    db $00,$40,$4D,$80
    db $00,$1F,$47,$80
    db $00,$40,$47,$80
    db $00,$40,$46,$80
    db $00,$40,$45,$80
    db $00,$40,$44,$80
    db $00,$40,$43,$80
    db $00,$40,$42,$80
    db $00,$40,$41,$80
    db $00,$1B,$37,$80
    db $00,$A5,$27,$80
    db $00,$1F,$37,$80
    db $00,$27,$46,$80
    db $00,$27,$45,$80
    db $00,$1B,$6B,$80
    db $00,$1A,$6B,$80
    db $00,$19,$6B,$80
    db $00,$1F,$37,$80
    db $00,$1C,$6C,$80
    db $00,$51,$4D,$80
    db $30,$F1,$6F,$C0
    db $38,$A1,$3B,$C0
    db $38,$A1,$3A,$C0
    db $00,$F4,$7A,$80
    db $00,$F4,$7B,$80
;}

; Data for $CF0E, indexed by [toneSweepChannelFrequency]/[toneChannelFrequency]/[waveChannelFrequency] (sound channel frequencies)
;{
data4263:
; workingSoundLength = 2
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01

data4273:
; workingSoundLength = 3
    db $08, $10, $18, $20, $28, $30, $38, $40, $38, $30, $28, $20, $18, $10, $08, $00

data4283:
; workingSoundLength = 4
    db $00, $05, $00, $05, $00, $05, $00, $05, $05, $00, $05, $00, $05, $00, $05, $00

data4293:
; workingSoundLength = 9
    db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01

data42A3:
; workingSoundLength = Ah
    db $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03
;}

handleAudio:
;{
    ld a, [audioPauseControl]
    cp audioPauseControl_pause
        jp z, audioPause

    cp audioPauseControl_unpause
        jp z, audioUnpause

    ld a, [audioPauseSoundEffectTimer]
    and a
        jp nz, handleAudio_paused
;}

handleAudio_handleIsolatedSoundEffectToPlay:
;{
    ld a, [isolatedSoundEffectToPlay]
    and a
        jr z, handleAudio_handleIsolatedSoundEffectPlaying

    cp isolatedSoundEffect_itemGet
        jr z, playIsolatedSoundEffect_itemGet

    cp isolatedSoundEffect_end_toPlay
        jp z, startEndingIsolatedSoundEffect

    cp isolatedSoundEffect_missilePickup
        jr z, playIsolatedSoundEffect_missilePickup

    cp isolatedSoundEffect_fadeOutMusic
        jp z, handleAudio_initiateFadingOutMusic

    cp isolatedSoundEffect_earthquake
        jr z, playIsolatedSoundEffect_earthquake

    cp isolatedSoundEffect_clear
        call z, clearIsolatedSoundEffect

    jr handleSongAndSoundEffects
;}

handleAudio_handleIsolatedSoundEffectPlaying:
;{
    ld a, [isolatedSoundEffectPlaying]
    and a
        jr z, handleSongAndSoundEffects

    cp isolatedSoundEffect_end_playing
        jp z, finishEndingIsolatedSoundEffect

    cp isolatedSoundEffect_fadeOutMusic
        jp z, handleAudio_handleFadingOutMusic
;}

handleSongAndSoundEffects:
;{
    call handleSong
    call handleNoiseChannelSoundEffect
    call handleToneSweepChannelSoundEffect
    call handleToneChannelSoundEffect
    call handleWaveChannelSoundEffect
    xor a
    ld [songRequest], a
    ld [sfxRequest_noise], a
    ld [sfxRequest_square1], a
    ld [sfxRequest_square2], a
    ld [sfxRequest_fakeWave], a
    ld [isolatedSoundEffectToPlay], a
    ld [lowHealthBeepSoundEffectToPlay], a
    ld [audioPauseControl], a
ret
;}

clearIsolatedSoundEffect:
;{
    xor a
    ld [isolatedSoundEffectToPlay], a
    ld [isolatedSoundEffectPlaying], a
ret
;}

playIsolatedSoundEffect_itemGet:
;{
    ld [isolatedSoundEffectPlaying], a
    ld a, song_itemGet
    ld [songRequest], a
    jr playIsolatedSoundEffect
;}

playIsolatedSoundEffect_missilePickup:
;{
    ld [isolatedSoundEffectPlaying], a
    ld a, song_missilePickup
    ld [songRequest], a
    jr playIsolatedSoundEffect
;}

playIsolatedSoundEffect_earthquake:
;{
    ld [isolatedSoundEffectPlaying], a
    ld [songRequest], a
;}

playIsolatedSoundEffect:
;{
    ld a, [songPlaying]
    ld [songPlayingBackup], a
    ld a, [isolatedSoundEffectToPlay]
    cp isolatedSoundEffect_earthquake
    jr z, .endIf_notEarthquake
        ld a, [lowHealthBeepSoundEffectPlaying]
        ld [lowHealthBeepSoundEffectPlayingBackup], a
        xor a
        ld [lowHealthBeepSoundEffectPlaying], a
        .endIf_notEarthquake

    ld a, [audioChannelOutputStereoFlags]
    ld [audioChannelOutputStereoFlagsBackup], a
    ld a, [toneSweepChannelSweep]
    ld [toneSweepChannelSweepBackup], a

    ld hl, songProcessingStateBackup
    ld de, songProcessingState
    ld a, [songProcessingStateSize]
    ld b, a

    .copyLoop
        ld a, [de]
        ld [hl+], a
        inc de
        dec b
        ld a, b
        and a
    jr nz, .copyLoop

    call muteSoundChannels
    ld [isolatedSoundEffectToPlay], a
    ld [sfxRequest_square1], a
    ld [toneSweepChannelSoundEffectPlaying], a
    ld [sfxRequest_noise], a
    ld [noiseChannelSoundEffectPlaying], a
    ld [noiseChannelSoundEffectIsPlayingFlag], a
ret
;}

startEndingIsolatedSoundEffect:
;{
    dec a
    ld [isolatedSoundEffectPlaying], a
    ld hl, songProcessingState
    ld de, songProcessingStateBackup
    ld a, [songProcessingStateSize]
    ld b, a

    .copyStateLoop
        ld a, [de]
        ld [hl+], a
        inc de
        dec b
        ld a, b
        and a
    jr nz, .copyStateLoop

    ld hl, audioChannelOptions
    ld de, rAUD1SWEEP

    .copyOptionsLoop
        ld a, [hl+]
        ld [de], a
        inc e
        ld a, e
        cp $24 ; Low byte of end of audio channel options ($FF24 & $FF)
    jr nz, .copyOptionsLoop

    xor a
    ld [isolatedSoundEffectToPlay], a
    ld a, $ff
    ld [sfxRequest_square1], a
    ld [sfxRequest_square2], a
    ld [sfxRequest_noise], a
ret
;}

finishEndingIsolatedSoundEffect:
;{
    ld a, [wavePatternDataPointer]
    ld e, a
    ld a, [wavePatternDataPointer+1]
    ld d, a
    xor a
    ldh [rAUD3ENA], a
    call writeToWavePatternRam

    ld a, [songPlaying]
    cp song_earthquake
    jr z, .endIf
        ld a, [lowHealthBeepSoundEffectPlayingBackup]
        ld [lowHealthBeepSoundEffectPlaying], a
        .endIf

    ld a, [audioChannelOutputStereoFlagsBackup]
    ld [audioChannelOutputStereoFlags], a
    ldh [rAUDTERM], a
    ld a, [toneSweepChannelSweepBackup]
    ld [toneSweepChannelSweep], a
    xor a
    ld [isolatedSoundEffectPlaying], a
    ld [ramCFEB], a
    ld a, [songPlayingBackup]
    ld [songPlaying], a
ret
;}

handleAudio_initiateFadingOutMusic:
;{
    ld [isolatedSoundEffectPlaying], a
    ld a, $d0
    ld [songFadeoutTimer], a
    ld a, [toneSweepSoundEnvelope]
    ld [ramCF5D], a
    ld a, [toneSoundEnvelope]
    ld [ramCF5E], a
    ld a, [waveVolume]
    ld [ramCF5F], a
    jp handleSongAndSoundEffects

;}

handleAudio_handleFadingOutMusic:
;{
    ld a, [songFadeoutTimer]
    dec a
    ld [songFadeoutTimer], a
    cp $a0
        jr z, .timerA0

    cp $70
        jr z, .timer70

    cp $30
        jr z, .timer30

    cp $10
        jr z, .timer10

    and a
        jr z, .timer0

    jp handleSongAndSoundEffects

.timerA0
    ld a, $65
    jr .merge

.timer70
    xor a
    ld [songNoiseChannelEnable], a
    ld a, $60
    ld [waveVolume], a
    ld [ramCF5F], a
    ld a, $45
    jr .merge

.timer30
    ld a, $25
    jr .merge

.timer10
    ld a, $13

.merge
    ld [toneSweepSoundEnvelope], a
    ld [toneSoundEnvelope], a
    ld [noiseSoundEnvelope], a
    ld [ramCF5D], a
    ld [ramCF5E], a
    jp handleSongAndSoundEffects

.timer0
    xor a
    ld [songPlaying], a
    ld [isolatedSoundEffectPlaying], a
    jp disableSoundChannels
;}

handleToneSweepChannelSoundEffect:
;{
    ld a, [sfxRequest_square1]
    and a
        jr z, .endif_sfxRequested

    cp $ff
        jp z, gotoClearToneSweepChannelSoundEffect

    cp $1f
        jr nc, .endif_sfxRequested

    ld a, [toneSweepChannelSoundEffectPlaying]
    cp toneSweepSoundEffect_pickedUpMissileDrop
        jr z, .endif_sfxRequested

    cp toneSweepSoundEffect_samusHealthChange
        jr z, .endif_sfxRequested

        ld a, [sfxRequest_square1]
        ld hl, toneSweepSfx_initPointers
        call loadPointerFromTable
        jp hl
    .endif_sfxRequested

.playing
    ld a, [toneSweepChannelSoundEffectPlaying]
    and a
    ret z

    cp $1f
    jr nc, .endif_sfxPlaying
        ld hl, toneSweepSfx_playbackPointers
        call loadPointerFromTable
        jp hl
    .endif_sfxPlaying

    xor a
    ld [toneSweepChannelSoundEffectPlaying], a
ret
;}

handleToneChannelSoundEffect:
;{
    ld a, [sfxRequest_square2]
    and a
        jr z, .endif_sfxRequested

    cp $ff
        jp z, gotoClearToneChannelSoundEffect

    cp $08
        jr nc, .endif_sfxRequested

    ld hl, toneChannelSoundEffectInitialisationFunctionPointers
    call loadPointerFromTable
    jp hl
    .endif_sfxRequested

    ld a, [toneChannelSoundEffectPlaying]
    and a
    ret z

    cp $08
    jr nc, .endif_sfxPlaying
        ld hl, toneChannelSoundEffectPlaybackFunctionPointers
        call loadPointerFromTable
        jp hl
    .endif_sfxPlaying

    xor a
    ld [toneChannelSoundEffectPlaying], a
ret
;}

handleNoiseChannelSoundEffect:
;{
    ld a, [sfxRequest_noise]
    and a
        jr z, .endif_sfxRequested

    cp $ff
        jp z, gotoClearNoiseChannelSoundEffect

    cp $1b
        jr nc, .endif_sfxRequested

    ld a, [songPlaying]
    cp song_earthquake
    ret z

    ld a, [noiseChannelSoundEffectPlaying]
    cp $0d
        jr z, .endif_sfxRequested

    cp $0e
        jr z, .endif_sfxRequested

    cp $0f
        jr z, .endif_sfxRequested

        ld a, [sfxRequest_noise]
        ld hl, noiseChannelSoundEffectInitialisationFunctionPointers
        call loadPointerFromTable
        jp hl
    .endif_sfxRequested

.playing
    ld a, [noiseChannelSoundEffectPlaying]
    and a
    ret z

    cp $1b
    jr nc, .endif_sfxPlaying
        ld hl, noiseChannelSoundEffectPlaybackFunctionPointers
        call loadPointerFromTable
        jp hl
    .endif_sfxPlaying

    xor a
    ld [.playing], a ; Bug, should be noiseChannelSoundEffectPlaying. This branch is never taken anyway though
    ret
;}

handleWaveChannelSoundEffect:
;{
    ld a, [waveChannelSoundEffectToPlay]
    and a
        jr z, .soundEffect0

    cp $ff
        jr z, .soundEffectFF

    cp $06
    ret nc

    ld a, [waveChannelSoundEffectToPlay]
    ld [waveChannelSoundEffectIsPlayingFlag], a
    ld [waveChannelSoundEffectPlaying], a
    ld hl, waveChannelSoundEffectInitialisationFunctionPointers
    call loadPointerFromTable
    jp hl

.soundEffect0
    ld a, [waveChannelSoundEffectPlaying]
    and a
    ret z

    cp $06
    jr nc, .endif_sfxPlaying
        ld hl, waveChannelSoundEffectPlaybackFunctionPointers
        call loadPointerFromTable
        jp hl
    .endif_sfxPlaying

    xor a
    ld [waveChannelSoundEffectPlaying], a
    ret

.soundEffectFF
    xor a
    ldh [rAUD3ENA], a
    ld a, [wavePatternDataPointer]
    ld e, a
    ld a, [wavePatternDataPointer+1]
    ld d, a
    call writeToWavePatternRam
    xor a
    ld [waveChannelSoundEffectIsPlayingFlag], a
    ld [waveChannelSoundEffectToPlay], a
    ld [waveChannelSoundEffectPlaying], a
    ld a, [songPlaying]
    cp song_earthquake
    ret z

    ld a, [waveChannelEnableOption]
    ldh [rAUD3ENA], a
    ld a, [waveChannelSoundLength]
    ldh [rAUD3LEN], a
    ld a, [waveChannelVolume]
    ldh [rAUD3LEVEL], a
    ld a, [waveChannelFrequency]
    ldh [rAUD3LOW], a
    ld a, [waveChannelFrequency+1]
    ldh [rAUD3HIGH], a
    ret
;}

handleSong:
;{
    ld a, [songRequest]
    and a
        jr z, handleSongPlaying

    cp $ff
        jr z, disableSoundChannels

    cp song_killedMetroid
    jr nz, .endIf
        call clearToneSweepChannelSoundEffect
        call clearNoiseChannelSoundEffect
        ld a, [songRequest]
    .endIf

    cp $21
        jr nc, handleSongPlaying

    ld [songPlaying], a
    dec a
    ld e, a
    ld d, $00
    ld hl, songStereoFlags
    add hl, de
    ld a, [hl]
    ld [audioChannelOutputStereoFlags], a
    ldh [rNR51], a
    ld a, [songRequest]
    ld hl, songDataTable
    call loadPointerFromTable
    jp loadSongHeader
;}

disableSoundChannels:
;{
    xor a
    ld [songToneSweepChannelEnable], a
    ld [songToneChannelEnable], a
    ld [songWaveChannelEnable], a
    ld [songNoiseChannelEnable], a
    call disableToneSweepChannel
    call disableToneChannel
    call disableWaveChannel
    jp disableNoiseChannel
;}

clearSongPlaying:
;{
    xor a
    ld [songPlaying], a
    ret
;}

handleSongPlaying:
;{
    ld a, [songPlaying]
    and a
    ret z

    cp $21
        jr nc, clearSongPlaying

    xor a
    ld [ramCF08], a
    ld a, [songToneSweepChannelEnable]
    and a
        jr z, .endToneSweep

    ld a, $01
    ld [workingSoundChannel], a
    ld a, [toneSweepInstructionTimer]
    ld [workingInstructionTimer], a
    cp $01
        jp z, handleSong_loadNextToneSweepChannelSound

    dec a
    ld [toneSweepInstructionTimer], a
    ld a, [toneSweepChannelSoundEffectIsPlayingFlag]
    and a
        jr nz, .endToneSweep

    ld a, [toneSweepSoundLength]
    ld [workingSoundLength], a
    and a
        jr z, .endToneSweep

    ld a, [toneSweepChannelFrequency]
    ld c, a
    ld a, [toneSweepChannelFrequency+1]
    ld b, a
    call Call_004_4d75
    ld a, [workingSoundChannelFrequency]
    ldh [rAUD1LOW], a
    ld a, [workingSoundChannelFrequency+1]
    ldh [rAUD1HIGH], a
    .endToneSweep

    xor a
    ld [ramCF08], a
    ld a, [songToneChannelEnable]
    and a
        jr z, .endTone

    ld a, $02
    ld [workingSoundChannel], a
    ld a, [toneInstructionTimer]
    ld [workingInstructionTimer], a
    cp $01
        jp z, handleSong_loadNextToneChannelSound

    dec a
    ld [toneInstructionTimer], a
    ld a, [toneChannelSoundEffectIsPlayingFlag]
    and a
        jr nz, .endTone

    ld a, [toneSoundLength]
    ld [workingSoundLength], a
    and a
        jr z, .endTone

    ld a, [toneChannelFrequency]
    ld c, a
    ld a, [toneChannelFrequency+1]
    ld b, a
    call Call_004_4d75
    ld a, [workingSoundChannelFrequency]
    ldh [rAUD2LOW], a
    ld a, [workingSoundChannelFrequency+1]
    ldh [rAUD2HIGH], a
    .endTone

    xor a
    ld [ramCF08], a
    ld a, [songWaveChannelEnable]
    and a
        jr z, .endWave

    ld a, $03
    ld [workingSoundChannel], a
    ld a, [waveInstructionTimer]
    ld [workingInstructionTimer], a
    cp $01
        jp z, handleSong_loadNextWaveChannelSound

    dec a
    ld [waveInstructionTimer], a
    ld a, [waveChannelSoundEffectIsPlayingFlag]
    and a
        jr nz, .endWave

    ld a, [waveSoundLength]
    ld [workingSoundLength], a
    and a
        jr z, .endWave

    ld a, [waveChannelFrequency]
    ld c, a
    ld a, [waveChannelFrequency+1]
    ld b, a
    call Call_004_4d75
    ld a, [workingSoundChannelFrequency]
    ldh [rNR33], a
    ld a, [workingSoundChannelFrequency+1]
    res 7, a
    ldh [rNR34], a
    .endWave

    xor a
    ld [ramCF08], a
    ld a, [songNoiseChannelEnable]
    and a
        jr z, .endNoise

    ld a, $04
    ld [workingSoundChannel], a
    ld a, [noiseInstructionTimer]
    ld [workingInstructionTimer], a
    cp $01
        jp z, handleSong_loadNextNoiseChannelSound

    dec a
    ld [noiseInstructionTimer], a
    ret
    .endNoise

    ld a, [songToneSweepChannelEnable]
    and a
    ret nz

    ld a, [songToneChannelEnable]
    and a
    ret nz

    ld a, [songWaveChannelEnable]
    and a
    ret nz

    ld a, [songNoiseChannelEnable]
    and a
    ret nz

    xor a
    ld [songPlaying], a
    ld [isolatedSoundEffectPlaying], a
    ret
;}

loadPointerFromTable:
;{
; hl = [[hl] + ([a] - 1) * 2]
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
;}

decrementToneSweepChannelSoundEffectTimer:
;{
    ld a, [toneSweepChannelSoundEffectTimer]
    and a
        jr z, gotoClearToneSweepChannelSoundEffect

    dec a
    ld [toneSweepChannelSoundEffectTimer], a
    ret
;}

gotoClearToneSweepChannelSoundEffect:
;{
    jr clearToneSweepChannelSoundEffect
;}

decrementToneChannelSoundEffectTimer:
;{
    ld a, [toneChannelSoundEffectTimer]
    and a
        jr z, gotoClearToneChannelSoundEffect

    dec a
    ld [toneChannelSoundEffectTimer], a
    ret
;}

gotoClearToneChannelSoundEffect:
;{
    jr clearToneChannelSoundEffect
;}

decrementNoiseChannelSoundEffectTimer:
;{
    ld a, [noiseChannelSoundEffectTimer]
    and a
        jr z, gotoClearNoiseChannelSoundEffect

    dec a
    ld [noiseChannelSoundEffectTimer], a
    ret
;}

gotoClearNoiseChannelSoundEffect:
;{
    jr clearNoiseChannelSoundEffect
;}

; Dead code
;{
    and a
        jr z, silenceAudio

    dec a
    ret
;}

clearToneSweepChannelSoundEffect:
;{
    xor a
    ld [toneSweepChannelSoundEffectPlaying], a
    ld [toneSweepChannelSoundEffectIsPlayingFlag], a
;}

disableToneSweepChannel:
;{
    ld a, $08
    ldh [rAUD1ENV], a
    ld a, $80
    ldh [rAUD1HIGH], a
    xor a
    ret
;}

clearToneChannelSoundEffect:
;{
    xor a
    ld [toneChannelSoundEffectPlaying], a
    ld [toneChannelSoundEffectIsPlayingFlag], a
;}

disableToneChannel:
;{
    ld a, $08
    ldh [rAUD2ENV], a
    ld a, $80
    ldh [rAUD2HIGH], a
    xor a
    ret
;}

clearWaveChannelSoundEffect:
;{
    xor a
    ld [waveChannelSoundEffectIsPlayingFlag], a
;}

disableWaveChannel:
;{
    xor a
    ldh [rAUD3ENA], a
    xor a
    ret
;}

clearNoiseChannelSoundEffect:
;{
    xor a
    ld [noiseChannelSoundEffectPlaying], a
    ld [noiseChannelSoundEffectIsPlayingFlag], a
;}

disableNoiseChannel:
;{
    ld a, $08
    ldh [rNR42], a
    ld a, $80
    ldh [rNR44], a
    xor a
    ret
;}

initializeAudio:
;{
    ld a, $80
    ldh [rNR52], a
    ld a, $77
    ldh [rNR50], a
    ld a, $ff
    ldh [rNR51], a
    ld hl, sfxRequest_square1

    .loop
        ld [hl], $00
        inc hl
        ld a, h
        cp $d0 ; $D000 / 10h
    jr nz, .loop

.ret
ret
;}

clearNonWaveSoundEffectRequests:
;{
    xor a
    ld [sfxRequest_square1], a
    ld [sfxRequest_square2], a
    ld [sfxRequest_fakeWave], a
    ld [sfxRequest_noise], a
    ld [audioPauseControl], a
    ret
;}

silenceAudio:
;{
    ld a, $ff
    ldh [rNR51], a
    xor a
    ld [sfxRequest_square1], a
    ld [sfxRequest_square2], a
    ld [sfxRequest_fakeWave], a
    ld [sfxRequest_noise], a
    ld [toneSweepChannelSoundEffectPlaying], a
    ld [toneChannelSoundEffectPlaying], a
    ld [ramCECF], a
    ld [noiseChannelSoundEffectPlaying], a
    ld a, $ff
    ld [songRequest], a
    ld [songPlaying], a
    xor a
    ld [isolatedSoundEffectToPlay], a
    ld [isolatedSoundEffectPlaying], a
    ld [waveChannelSoundEffectToPlay], a
    ld [waveChannelSoundEffectPlaying], a
    ld [audioPauseSoundEffectTimer], a
    ld [audioPauseControl], a
;}

muteSoundChannels:
;{
    ld a, $08
    ldh [rAUD1ENV], a
    ldh [rAUD2ENV], a
    ldh [rNR42], a
    ld a, $80
    ldh [rAUD1HIGH], a
    ldh [rAUD2HIGH], a
    ldh [rNR44], a
    xor a
    ldh [rNR10], a
    ldh [rAUD3ENA], a
ret
;}

writeToWavePatternRam:
;{
    push bc
    push de
    ld c, _AUD3WAVERAM & $FF

    .loop
        ld a, [de]
        ld [c], a
        inc de
        inc c
        ld a, c
        cp (_AUD3WAVERAM + $10) & $FF
    jr nz, .loop

    pop de
    pop bc
    ret
;}

setChannelOptionSet:
;{
.toneSweep
    push hl
    ld hl, $ff10
    ld b, $05
    jr .merge

.tone
    push hl
    ld hl, $ff16
    ld b, $04
    jr .merge

.wave
    push hl
    ld hl, $ff1a
    ld b, $05
    jr .merge

.noise
    push hl
    ld hl, $ff20
    ld b, $04
    jr .merge

.merge
    .copyLoop
        ld a, [de]
        ld [hl+], a
        inc de
        dec b
    jr nz, .copyLoop

    pop hl
    ret
;}

audioPause:
;{
    call muteSoundChannels
    xor a
    ld [toneSweepChannelSoundEffectPlaying], a
    ld [toneChannelSoundEffectPlaying], a
    ld [ramCECF], a
    ld [noiseChannelSoundEffectPlaying], a
    ld a, $40
    ld [audioPauseSoundEffectTimer], a
    ld de, $487c
;}

; Set noise channel option set [de] and clear sound channel 1/2/4 sound effects to play
jr_004_4819:
;{
    call setChannelOptionSet.noise
    jp clearNonWaveSoundEffectRequests
;}

handleAudio_paused_frame3D:
;{
    ld de, $4880
    jr jr_004_4819
;}

handleAudio_paused_frame32:
;{
    ld de, $488e
    jr jr_004_4819
;}

handleAudio_paused_frame27:
;{
    ld de, $4897
    jr jr_004_4819
;}

handleAudio_paused_frame3F:
;{
    ld de, $4884
;}

; Set tone/sweep channel option set [de] and clear sound channel 1/2/4 sound effects to play
jr_004_4831:
;{
    call setChannelOptionSet.toneSweep
    jp clearNonWaveSoundEffectRequests
;}

handleAudio_paused_frame3A:
;{
    ld de, $4889
    jr jr_004_4831
;}

handleAudio_paused_frame2F:
;{
    ld de, $4892
    jr jr_004_4831
;}

handleAudio_paused_frame24:
;{
    ld de, $489b
    jr jr_004_4831
;}

audioUnpause:
;{
    xor a
    ld [audioPauseSoundEffectTimer], a
    ld a, toneSweepSoundEffect_unpaused
    ld [sfxRequest_square1], a
    jp handleAudio_handleIsolatedSoundEffectToPlay
;}

handleAudio_paused:
;{
    ld hl, audioPauseSoundEffectTimer
    dec [hl]
    ld a, [hl]
    cp $3f
        jr z, handleAudio_paused_frame3F
    cp $3d
        jr z, handleAudio_paused_frame3D
    cp $3a
        jr z, handleAudio_paused_frame3A
    cp $32
        jr z, handleAudio_paused_frame32
    cp $2f
        jr z, handleAudio_paused_frame2F
    cp $27
        jr z, handleAudio_paused_frame27
    cp $24
        jr z, handleAudio_paused_frame24
    cp $10
        jp nz, clearNonWaveSoundEffectRequests

    inc [hl]
    jp clearNonWaveSoundEffectRequests
;}

pausedOptionSets:
;{
.frame40 ; $487C
    LengthOptions $0
    DescendingEnvelopeOptions 7, $8
    PolynomialCounterOptions 1, 0, $3
    CounterControlOptions 0

.frame3D ; $4880
    LengthOptions $0
    DescendingEnvelopeOptions 3, $8
    PolynomialCounterOptions 5, 1, $5
    CounterControlOptions 0

.frame3F ; $4884
    DescendingSweepOptions 5, 1
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $F
    FrequencyOptions $7C0, 0

.frame3A ; $4889
    DescendingSweepOptions 5, 1
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $C
    FrequencyOptions $7D0, 0

.frame32 ; $488E
    LengthOptions $0
    DescendingEnvelopeOptions 3, $5
    PolynomialCounterOptions 4, 1, $5
    CounterControlOptions 0

.frame2F ; $4892
    DescendingSweepOptions 5, 1
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $7
    FrequencyOptions $7D5, 0

.frame27 ; $4897
    LengthOptions $0
    DescendingEnvelopeOptions 6, $3
    PolynomialCounterOptions 3, 1, $5
    CounterControlOptions 0

.frame24 ; $489B
    DescendingSweepOptions 5, 1
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $4
    FrequencyOptions $7D9, 0
;}

loadSongHeader:
;{
    call resetSongSoundChannelOptions
    ld a, [hl+]
    bit 0, a
    jr z, .endIf_frequencyTweak
        push af
        ld a, $01
        ld [toneChannelFrequencyTweak], a
        pop af
    .endIf_frequencyTweak

    res 0, a
    ld [songTranspose], a
    ld a, [hl+]
    ld [songInstructionTimerArrayPointer+1], a
    ld a, [hl+]
    ld [songInstructionTimerArrayPointer], a
    ld a, [hl+]
    ld [toneSweepInstructionPointer+1], a
    ld a, [hl+]
    ld [toneSweepInstructionPointer], a
    ld a, [hl+]
    ld [toneInstructionPointer+1], a
    ld a, [hl+]
    ld [toneInstructionPointer], a
    ld a, [hl+]
    ld [waveInstructionPointer+1], a
    ld a, [hl+]
    ld [waveInstructionPointer], a
    ld a, [hl+]
    ld [noiseInstructionPointer+1], a
    ld a, [hl]
    ld [noiseInstructionPointer], a
    ld a, [toneSweepInstructionPointer]
    ld h, a
    ld a, [toneSweepInstructionPointer+1]
    ld l, a
    ld a, l
    or h
    jr nz, .else_toneSweep
        xor a
        ld [songToneSweepChannelEnable], a
        ld a, $08
        ldh [rAUD1ENV], a
        ld a, $80
        ldh [rAUD1HIGH], a
        jr .endIf_toneSweep
    .else_toneSweep
        ld a, $01
        ld [songToneSweepChannelEnable], a
        ld a, [hl+]
        ld [songToneSweepChannelInstructionPointer+1], a
        ld a, [hl]
        ld [songToneSweepChannelInstructionPointer], a
    .endIf_toneSweep

    ld a, [toneInstructionPointer]
    ld h, a
    ld a, [toneInstructionPointer+1]
    ld l, a
    ld a, l
    or h
    jr nz, .else_tone
        xor a
        ld [songToneChannelEnable], a
        ld a, $08
        ldh [rAUD2ENV], a
        ld a, $80
        ldh [rAUD2HIGH], a
        jr .endIf_tone
    .else_tone
        ld a, $02
        ld [songToneChannelEnable], a
        ld a, [hl+]
        ld [songToneChannelInstructionPointer+1], a
        ld a, [hl]
        ld [songToneChannelInstructionPointer], a
    .endIf_tone

    ld a, [waveInstructionPointer]
    ld h, a
    ld a, [waveInstructionPointer+1]
    ld l, a
    ld a, l
    or h
    jr nz, .else_wave
        xor a
        ld [songWaveChannelEnable], a
        xor a
        ldh [rAUD3ENA], a
        jr .endIf_wave
    .else_wave
        ld a, $03
        ld [songWaveChannelEnable], a
        ld a, [hl+]
        ld [songWaveChannelInstructionPointer+1], a
        ld a, [hl]
        ld [songWaveChannelInstructionPointer], a
    .endIf_wave

    ld a, [noiseInstructionPointer]
    ld h, a
    ld a, [noiseInstructionPointer+1]
    ld l, a
    ld a, l
    or h
    jr nz, .else_noise
        xor a
        ld [songNoiseChannelEnable], a
        jr .endIf_noise
    .else_noise
        ld a, $04
        ld [songNoiseChannelEnable], a
        ld a, [hl+]
        ld [songNoiseChannelInstructionPointer+1], a
        ld a, [hl]
        ld [songNoiseChannelInstructionPointer], a
    .endIf_noise

    ld a, $01
    ld [toneSweepInstructionTimer], a
    ld [toneInstructionTimer], a
    ld [waveInstructionTimer], a
    ld [noiseInstructionTimer], a
    ret
;}

handleSong_loadNextToneSweepChannelSound:
;{
    ld de, toneSweepChannelSongProcessingState
    ld hl, workingChannelSongProcessingState
    call copyChannelSongProcessingState
    ld a, [songToneSweepChannelInstructionPointer]
    ld h, a
    ld a, [songToneSweepChannelInstructionPointer+1]
    ld l, a
    ld a, $01
    call loadNextSound
    ld a, [workingSoundChannel]
    ld [songToneSweepChannelEnable], a
    and a
        jp z, resetToneSweepChannelOptions

    ld a, h
    ld [songToneSweepChannelInstructionPointer], a
    ld a, l
    ld [songToneSweepChannelInstructionPointer+1], a
    ld hl, toneSweepChannelSongProcessingState
    ld de, workingChannelSongProcessingState
    call copyChannelSongProcessingState
    ld a, [ramCF08]
    cp $01
    jr nz, .endIf
        ld a, [workingSoundChannelSweep]
        ld [toneSweepChannelSweep], a
        ld a, [workingSoundChannelSoundLength]
        ld [toneSweepChannelSoundLength], a
    .endIf

    ld a, [workingSoundChannelEnvelope]
    ld [toneSweepChannelEnvelope], a
    ld a, [workingSoundChannelFrequency]
    ld [toneSweepChannelFrequency], a
    ld a, [workingSoundChannelFrequency+1]
    ld [toneSweepChannelFrequency+1], a
    ld a, [toneSweepChannelSoundEffectIsPlayingFlag]
    and a
        jp nz, handleSongPlaying.endToneSweep

    ld a, [toneSweepChannelSweep]
    ldh [rNR10], a
    ld a, [toneSweepChannelSoundLength]
    ldh [rNR11], a
    ld a, [toneSweepChannelEnvelope]
    ldh [rAUD1ENV], a
    ld a, [toneSweepChannelFrequency]
    ldh [rAUD1LOW], a
    ld a, [toneSweepChannelFrequency+1]
    ldh [rAUD1HIGH], a
    jp handleSongPlaying.endToneSweep
;}

handleSong_loadNextToneChannelSound:
;{
    ld de, toneChannelSongProcessingState
    ld hl, workingChannelSongProcessingState
    call copyChannelSongProcessingState
    ld a, [songToneChannelInstructionPointer]
    ld h, a
    ld a, [songToneChannelInstructionPointer+1]
    ld l, a
    ld a, $02
    call loadNextSound
    ld a, [workingSoundChannel]
    ld [songToneChannelEnable], a
    and a
        jp z, resetToneChannelOptions

    ld a, h
    ld [songToneChannelInstructionPointer], a
    ld a, l
    ld [songToneChannelInstructionPointer+1], a
    ld hl, toneChannelSongProcessingState
    ld de, workingChannelSongProcessingState
    call copyChannelSongProcessingState
    ld a, [ramCF08]
    cp $02
    jr nz, .endIf_setSoundLength
        ld a, [workingSoundChannelSoundLength]
        ld [toneChannelSoundLength], a
    .endIf_setSoundLength

    ld a, [workingSoundChannelEnvelope]
    ld [toneChannelEnvelope], a
    ld a, [workingSoundChannelFrequency]
    ld [toneChannelFrequency], a
    ld a, [workingSoundChannelFrequency+1]
    ld [toneChannelFrequency+1], a
    ld a, [toneChannelSoundEffectIsPlayingFlag]
    and a
        jp nz, handleSongPlaying.endTone

    ld a, [toneChannelSoundLength]
    ldh [rNR21], a
    ld a, [toneChannelFrequencyTweak]
    cp $01
    jr nz, .endIf_tweakFrequency
        ld a, [toneChannelFrequency]
        ld l, a
        ld a, [toneChannelFrequency+1]
        ld h, a
        cp $87
        jr nc, .else
            inc hl
            inc hl
            jr .endIf
        .else
            inc hl
        .endIf

        ld a, l
        ld [toneChannelFrequency], a
        ld a, h
        ld [toneChannelFrequency+1], a
    .endIf_tweakFrequency

    ld a, [toneChannelEnvelope]
    ldh [rAUD2ENV], a
    ld a, [toneChannelFrequency]
    ldh [rAUD2LOW], a
    ld a, [toneChannelFrequency+1]
    ldh [rAUD2HIGH], a
    jp handleSongPlaying.endTone
;}

handleSong_loadNextWaveChannelSound:
;{
    ld de, waveChannelSongProcessingState
    ld hl, workingChannelSongProcessingState
    call copyChannelSongProcessingState
    ld a, [songWaveChannelInstructionPointer]
    ld h, a
    ld a, [songWaveChannelInstructionPointer+1]
    ld l, a
    ld a, $03
    call loadNextSound
    ld a, [workingSoundChannel]
    ld [songWaveChannelEnable], a
    and a
        jp z, resetWaveChannelOptions

    ld a, h
    ld [songWaveChannelInstructionPointer], a
    ld a, l
    ld [songWaveChannelInstructionPointer+1], a
    ld hl, waveChannelSongProcessingState
    ld de, workingChannelSongProcessingState
    call copyChannelSongProcessingState
    ld a, [workingSoundChannelEnable]
    ld [waveChannelEnableOption], a
    ld a, [workingSoundChannelSoundLength]
    ld [waveChannelSoundLength], a
    ld a, [workingSoundChannelVolume]
    ld [waveChannelVolume], a
    ld a, [workingSoundChannelFrequency]
    ld [waveChannelFrequency], a
    ld a, [workingSoundChannelFrequency+1]
    ld [waveChannelFrequency+1], a
    ld a, [waveChannelSoundEffectIsPlayingFlag]
    and a
        jp nz, handleSongPlaying.endWave

    xor a
    ldh [rAUD3ENA], a
    ld a, [waveChannelEnableOption]
    ldh [rAUD3ENA], a
    ld a, [waveChannelSoundLength]
    ldh [rNR31], a
    ld a, [waveChannelVolume]
    ldh [rNR32], a
    ld a, [waveChannelFrequency]
    ldh [rNR33], a
    ld a, [waveChannelFrequency+1]
    ldh [rNR34], a
    jp handleSongPlaying.endWave
;}

handleSong_loadNextNoiseChannelSound:
;{
    ld de, noiseChannelSongProcessingState
    ld hl, workingChannelSongProcessingState
    call copyChannelSongProcessingState
    ld a, [songNoiseChannelInstructionPointer]
    ld h, a
    ld a, [songNoiseChannelInstructionPointer+1]
    ld l, a
    ld a, $04
    call loadNextSound
    ld a, [workingSoundChannel]
    ld [songNoiseChannelEnable], a
    and a
        jp z, resetNoiseChannelOptions

    ld a, h
    ld [songNoiseChannelInstructionPointer], a
    ld a, l
    ld [songNoiseChannelInstructionPointer+1], a
    ld hl, noiseChannelSongProcessingState
    ld de, workingChannelSongProcessingState
    call copyChannelSongProcessingState
    ld a, [noiseChannelSoundEffectIsPlayingFlag]
    and a
        ret nz

    ld a, [workingSoundChannelSoundLength]
    ldh [rNR41], a
    ld a, [workingSoundChannelEnvelope]
    ldh [rNR42], a
    ld a, [workingSoundChannelPolynomialCounter]
    ldh [rAUD4POLY], a
    ld [noiseChannelPolynomialCounter], a
    ld a, [workingSoundChannelCounterControl]
    ldh [rNR44], a
    ld [noiseChannelCounterControl], a
    ret
;}

loadNextSound:
;{
;; Parameters:
;;     a:  Working sound channel
;;     hl: Song instruction pointer list
;; Returns:
;;     a:  Working sound channel frequency / polynomial counter

    ld [workingSoundChannel], a
    ld a, [hl]
    and a
        jp nz, .loop

.nextInstructionList
    ld a, [workingInstructionPointer]
    ld h, a
    ld a, [workingInstructionPointer+1]
    ld l, a
    inc hl
    inc hl
    ld a, h
    ld [workingInstructionPointer], a
    ld a, l
    ld [workingInstructionPointer+1], a
    ld a, [hl]
    and a
    jr nz, .endif_endOfInstructionLists
        inc hl
        ld a, [hl-]
        and a
            jr nz, .endif_endOfInstructionLists

        xor a
        ld [workingSoundChannel], a
        ret
    .endif_endOfInstructionLists

    ld a, [hl]
    cp $f0
    jr nz, .endIf_instructionPointerListGoto
        inc hl
        ld a, [hl-]
        and a
            call z, songInstruction_goto
    .endIf_instructionPointerListGoto:

    ld a, [hl+]
    ld b, a
    ld a, [hl]
    ld h, a
    ld l, b

.loop:
    ld a, [hl]
    cp $f1
        call z, songInstruction_setWorkingSoundChannelOptions
    cp $f2
        call z, songInstruction_setInstructionTimerArrayPointer
    cp $f3
        call z, songInstruction_setMusicNoteOffset
    cp $f4
        call z, songInstruction_markRepeatPoint
    cp $f5
        call z, songInstruction_repeat
    and a
        jp z, .nextInstructionList
    cp $f6
        jp nc, silenceAudio
    cp $f1
        jr nc, .loop
        
    cp $9f
    jp c, .endIf_instructionLength
        res 7, a
        res 5, a
        push af
        ld a, [songInstructionTimerArrayPointer]
        ld b, a
        ld a, [songInstructionTimerArrayPointer+1]
        ld c, a
        pop af
        push hl
        ld l, a
        ld h, $00
        add hl, bc
        ld a, [hl]
        pop hl
        ld [workingInstructionTimer], a
        ld [workingInstructionLength], a
        inc hl
    .endIf_instructionLength

    ld a, [workingInstructionLength]
    ld [workingInstructionTimer], a
    ld a, [workingSoundChannel]
    cp $04
        jp z, .noise
    ld a, [hl+]
    cp $01
        jr z, .mute
    cp $03
        jp z, .songInstruction3
    cp $05
        jp z, .songInstruction5
        
    push hl
    push af
    ld a, [workingSoundChannel]
    cp $03
    jr nz, .endIf_wave
        ld a, [waveChannelSoundEffectIsPlayingFlag]
        and a
            jr nz, .endIf_wave

        ld hl, rAUDTERM
        set 6, [hl]
        set 2, [hl]
        ld a, $80
        ld [workingSoundChannelEnable], a
    .endIf_wave

    pop af
    ld b, a
    ld a, [workingSoundChannel]
    cp $04
    jr z, .endIf_noise
        ld a, [songTranspose]
        add b
    .endIf_noise

    ld c, a
    ld b, $00
    ld hl, musicNotes
    add hl, bc
    ld a, [workingSoundEnvelope]
    ld [workingSoundChannelEnvelope], a
    ld a, [hl+]
    ld [workingSoundChannelFrequency], a
    ld a, [hl]
    ld [workingSoundChannelFrequency+1], a
    pop hl
    ret

.mute:
    ld a, [workingSoundChannel]
    cp $03
    jr z, .endIf_restartChannel
        ld a, $08
        ld [workingSoundChannelEnvelope], a
        ld a, $80
        ld [workingSoundChannelCounterControl], a
        ret
    .endIf_restartChannel

    xor a
    ld [workingSoundChannelEnable], a
    ld [workingSoundChannelVolume], a
    ret

.noise:
    ld a, [hl+]
    cp $01
        jr z, .mute

    push hl
    ld c, a
    ld b, $00
    ld hl, songNoiseChannelOptionSets
    add hl, bc
    ld a, [hl+]
    ld [workingSoundChannelSoundLength], a
    ld a, [hl+]
    ld [workingSoundChannelEnvelope], a
    ld a, [hl+]
    ld [workingSoundChannelPolynomialCounter], a
    ld a, [hl]
    ld [workingSoundChannelCounterControl], a
    pop hl
    ret

.songInstruction3:
    ld a, $66
    ld [workingSoundChannelEnvelope], a
    jr .merge

.songInstruction5:
    ld a, $46
    ld [workingSoundChannelEnvelope], a
    jr .merge

.merge
    ld a, [isolatedSoundEffectPlaying]
    cp isolatedSoundEffect_fadeOutMusic
    jr nz, .endIf_fadeOut
        ld a, isolatedSoundEffect_fadeOutMusic
        ld [workingSoundChannelEnvelope], a
    .endIf_fadeOut

    ld a, [workingSoundChannel]
    cp $01
        jr z, .setFrequency_toneSweep
    cp $02
        jr z, .setFrequency_tone
    cp $03
        jr z, .setFrequency_wave
    ret

.setFrequency_toneSweep
    ld a, [toneSweepChannelFrequency]
    ld [workingSoundChannelFrequency], a
    ld a, [toneSweepChannelFrequency+1]
    ld [workingSoundChannelFrequency+1], a
    ret

.setFrequency_tone
    ld a, [toneChannelFrequency]
    ld [workingSoundChannelFrequency], a
    ld a, [toneChannelFrequency+1]
    ld [workingSoundChannelFrequency+1], a
    ret

.setFrequency_wave
    ld a, [waveChannelSoundEffectIsPlayingFlag]
    and a
        ret nz

    ld a, $80
    ld [workingSoundChannelEnable], a
    ld a, [waveChannelFrequency]
    ld [workingSoundChannelFrequency], a
    ld a, [waveChannelFrequency+1]
    ld [workingSoundChannelFrequency+1], a
    ret
;}

songInstruction_setWorkingSoundChannelOptions:
;{
    inc hl
    ld a, [workingSoundChannel]
    ld [ramCF08], a
    cp $03
        jr z, songInstruction_setWorkingSoundChannelOptions_wave

    ld a, [isolatedSoundEffectPlaying]
    cp isolatedSoundEffect_fadeOutMusic
    jr nz, .else_fadeOut
        ld a, [hl+]
        ld [workingSoundChannelEnvelope], a
        jr .endIf_fadeOut
    .else_fadeOut
        ld a, [hl+]
        ld [workingSoundChannelEnvelope], a
        ld [workingSoundEnvelope], a
    .endIf_fadeOut
    
    ld a, [hl+]
    ld [workingSoundChannelSweep], a
    ld a, [hl]
    ld [workingSoundChannelSoundLength], a
    res 6, a
    res 7, a

.soundLength
    and a
    jr nz, .endIf_badCode
        xor a
    .endIf_badCode

    ld [workingSoundLength], a
;}

endSongInstructionWithParameter:
;{
    inc hl
;}

endSongInstruction:
;{
    ld a, [hl]
    ret
;}

songInstruction_setWorkingSoundChannelOptions_wave:
;{
    ld a, [hl+]
    ld [wavePatternDataPointer], a
    ld [ramCFE3], a
    ld e, a
    ld a, [hl+]
    ld [wavePatternDataPointer+1], a
    ld [ramCFE3+1], a
    ld d, a
    ld a, [isolatedSoundEffectPlaying]
    cp isolatedSoundEffect_fadeOutMusic
    jr nz, .else_fadeOut
        ld a, [hl]
        ld [workingSoundChannelVolume], a
        jr .endIf_fadeOut
    .else_fadeOut
        ld a, [hl]
        ld [workingSoundChannelVolume], a
        ld [workingVolume], a
    .endIf_fadeOut

    ld a, [waveChannelSoundEffectIsPlayingFlag]
    and a
    jr nz, .endIf_disableWave
        xor a
        ldh [rAUD3ENA], a
        call writeToWavePatternRam
    .endIf_disableWave

    ld a, [workingSoundChannelVolume]
    res 5, a
    res 6, a
    jr songInstruction_setWorkingSoundChannelOptions.soundLength
;}

songInstruction_setInstructionTimerArrayPointer:
;{
    inc hl
    ld a, [hl+]
    ld [songInstructionTimerArrayPointer+1], a
    ld a, [hl+]
    ld [songInstructionTimerArrayPointer], a
    jr endSongInstruction
;}

songInstruction_setMusicNoteOffset:
;{
    inc hl
    ld a, [hl+]
    ld [songTranspose], a
    jr endSongInstruction
;}

songInstruction_goto:
;{
    inc hl
    inc hl
    ld a, [hl+]
    ld [workingInstructionPointer+1], a
    ld b, a
    ld a, [hl]
    ld [workingInstructionPointer], a
    ld h, a
    ld l, b
    ret
;}

songInstruction_markRepeatPoint:
;{
    inc hl
    ld a, [hl+]
    ld [workingRepeatPoint], a
    ld a, h
    ld [workingRepeatCount], a
    ld a, l
    ld [workingRepeatCount+1], a
    jr endSongInstruction
;}

songInstruction_repeat:
;{
    ld a, [workingRepeatPoint]
    dec a
    ld [workingRepeatPoint], a
    and a
        jr z, endSongInstructionWithParameter

    ld a, [workingRepeatCount]
    ld h, a
    ld a, [workingRepeatCount+1]
    ld l, a
    jr endSongInstruction
;}

copyChannelSongProcessingState:
;{
    ld a, [channelSongProcessingStateSize]
    ld b, a

    .loopCopy
        ld a, [de]
        ld [hl+], a
        inc de
        dec b
        ld a, b
        and a
    jr nz, .loopCopy

    ret
;}

Call_004_4d75:
;{
    ld a, [workingSoundLength]
    cp $02
        jr z, .soundLength2
    cp $03
        jr z, .soundLength3
    cp $04
        jr z, .soundLength4
    cp $06
        jr z, .soundLength6
    cp $07
        jp z, .soundLength7
    cp $08
        jp z, .soundLength8
    cp $09
        jp z, .soundLength9
    cp $0a
        jp z, .soundLengthA
    ret

.merge
    ld a, [$cf2e]
    and a
    jr nz, .endIf_resetTimer
        ld a, $11
        ld [$cf2e], a
    .endIf_resetTimer

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
    ld [workingSoundChannelFrequency], a
    ld a, h
    res 7, a
    res 6, a
    ld [workingSoundChannelFrequency+1], a
    ret

.soundLength2:
    ld hl, $4263
    jr .merge

.soundLength3:
    ld hl, $4273
    jr .merge

.soundLength4:
    ld hl, $4283
    jr .merge

.soundLength9:
    ld hl, $4293
    jr .merge

.soundLengthA:
    ld hl, $42a3
    jr .merge

.soundLength6:
    inc bc
    ld a, c
    ld [workingSoundChannelFrequency], a
    ld a, b
    res 7, a
    res 6, a
    ld [workingSoundChannelFrequency+1], a

.setFrequency
    ld a, [workingSoundChannel]
    cp $01
    jr nz, .endIf_toneSweep
        ld a, [workingSoundChannelFrequency]
        ld [toneSweepChannelFrequency], a
        ld a, [workingSoundChannelFrequency+1]
        ld [toneSweepChannelFrequency+1], a
        ret
    .endIf_toneSweep

    cp $02
    jr nz, .endIf_tone
        ld a, [workingSoundChannelFrequency]
        ld [toneChannelFrequency], a
        ld a, [workingSoundChannelFrequency+1]
        ld [toneChannelFrequency+1], a
        ret
    .endIf_tone

    cp $03
        ret nz

    ld a, [workingSoundChannelFrequency]
    ld [waveChannelFrequency], a
    ld a, [workingSoundChannelFrequency+1]
    res 7, a
    ld [waveChannelFrequency+1], a
    ret

.soundLength7:
    inc bc
    inc bc
    inc bc
    inc bc
    ld a, c
    ld [workingSoundChannelFrequency], a
    ld a, b
    res 7, a
    res 6, a
    ld [workingSoundChannelFrequency+1], a
    jr .setFrequency

.soundLength8:
    dec bc
    dec bc
    dec bc
    ld a, c
    ld [workingSoundChannelFrequency], a
    ld a, b
    res 7, a
    res 6, a
    ld [workingSoundChannelFrequency+1], a
    jr .setFrequency
;}

resetToneSweepChannelOptions:
;{
    xor a
    ld [songToneSweepChannelEnable], a
    ld a, $08
    ldh [rAUD1ENV], a
    ld [toneSweepChannelEnvelope], a
    ld a, $80
    ldh [rAUD1HIGH], a
    ld [toneSweepChannelFrequency+1], a
    jp handleSongPlaying.endToneSweep
;}

resetToneChannelOptions:
;{
    xor a
    ld [songToneChannelEnable], a
    ld a, $08
    ldh [rAUD2ENV], a
    ld [toneChannelEnvelope], a
    ld a, $80
    ldh [rAUD2HIGH], a
    ld [toneChannelFrequency+1], a
    jp handleSongPlaying.endTone
;}

resetWaveChannelOptions:
;{
    xor a
    ld [songWaveChannelEnable], a
    xor a
    ldh [rAUD3ENA], a
    ld [waveChannelEnableOption], a
    jp handleSongPlaying.endWave
;}

resetNoiseChannelOptions:
;{
    xor a
    ld [songNoiseChannelEnable], a
    ld a, $08
    ldh [rNR42], a
    ld [noiseChannelEnvelope], a
    ld a, $80
    ldh [rNR44], a
    ld [noiseChannelCounterControl], a
    ret
;}

resetSongSoundChannelOptions:
;{
    push hl
    ld hl, songProcessingStates
    ld a, [channelAllSongProcessingStateSizes]
    ld b, a

    .loop
        ld [hl], $00
        inc hl
        dec b
        ld a, b
        and a
    jr nz, .loop

    pop hl
    xor a
    ld [toneSweepChannelSoundEffectIsPlayingFlag], a
    ld [toneChannelSoundEffectIsPlayingFlag], a
    ld [waveChannelSoundEffectIsPlayingFlag], a
    ld [noiseChannelSoundEffectIsPlayingFlag], a
    ld [toneChannelFrequencyTweak], a
    ldh [rNR10], a
    ldh [rAUD3ENA], a
    ld a, $08
    ldh [rAUD1ENV], a
    ldh [rAUD2ENV], a
    ldh [rNR42], a
    ld a, $80
    ldh [rAUD1HIGH], a
    ldh [rAUD2HIGH], a
    ldh [rNR44], a
    ret
;}

; Tone/sweep channel sound effects
;{
toneSweepSfx_initPointers:
;{
    dw toneSweepSfx_init_1 ; 1: Jumping
    dw toneSweepSfx_init_2 ; 2: Hi-jumping
    dw toneSweepSfx_init_3 ; 3: Screw attacking
    dw toneSweepSfx_init_4 ; 4: Uncrouching / turning around / landing
    dw toneSweepSfx_init_5 ; 5: Crouching / unmorphing
    dw toneSweepSfx_init_6 ; 6: Morphing
    dw toneSweepSfx_init_7 ; 7: Shooting beam
    dw toneSweepSfx_init_8 ; 8: Shooting missile
    dw toneSweepSfx_init_9 ; 9: Shooting ice beam
    dw toneSweepSfx_init_A ; Ah: Shooting plasma beam
    dw toneSweepSfx_init_B ; Bh: Shooting spazer beam
    dw toneSweepSfx_init_C ; Ch: Picked up missile drop
    dw toneSweepSfx_init_D ; Dh: Spider ball
    dw toneSweepSfx_init_E ; Eh: Picked up energy drop
    dw toneSweepSfx_init_F ; Fh: Shot missile door with beam
    dw toneSweepSfx_init_10 ; 10h
    dw initializeAudio.ret ; 11h: ret
    dw toneSweepSfx_init_12 ; 12h
    dw toneSweepSfx_init_13 ; 13h: Bomb laid
    dw toneSweepSfx_init_14 ; 14h
    dw toneSweepSfx_init_15 ; 15h: Option select / missile select
    dw toneSweepSfx_init_16 ; 16h: Shooting wave beam
    dw toneSweepSfx_init_17 ; 17h
    dw toneSweepSfx_init_18 ; 18h: Samus' health changed
    dw toneSweepSfx_init_19 ; 19h: No missile dud shot
    dw toneSweepSfx_init_1A ; 1Ah
    dw toneSweepSfx_init_1B ; 1Bh: Metroid cry
    dw toneSweepSfx_init_1C ; 1Ch: Saved
    dw toneSweepSfx_init_1D ; 1Dh
    dw toneSweepSfx_init_1E ; 1Eh: Unpaused
;}

toneSweepSfx_playbackPointers:
;{
    dw toneSweepSfx_playback_1 ; 1: Jumping
    dw toneSweepSfx_playback_2 ; 2: Hi-jumping
    dw toneSweepSfx_playback_3 ; 3: Screw attacking
    dw toneSweepSfx_playback_4 ; 4: Uncrouching / turning around / landing
    dw toneSweepSfx_playback_5 ; 5: Crouching / unmorphing
    dw toneSweepSfx_playback_6 ; 6: Morphing
    dw toneSweepSfx_playback_7 ; 7: Shooting beam
    dw toneSweepSfx_playback_8 ; 8: Shooting missile
    dw toneSweepSfx_playback_9 ; 9: Shooting ice beam
    dw toneSweepSfx_playback_A ; Ah: Shooting plasma beam
    dw toneSweepSfx_playback_B ; Bh: Shooting spazer beam
    dw toneSweepSfx_playback_C ; Ch: Picked up missile drop
    dw toneSweepSfx_playback_D ; Dh: Spider ball
    dw toneSweepSfx_playback_E ; Eh: Picked up energy drop
    dw toneSweepSfx_playback_F ; Fh: Shot missile door with beam
    dw toneSweepSfx_playback_10 ; 10h
    dw initializeAudio.ret ; 11h: ret
    dw decrementToneSweepChannelSoundEffectTimer ; 12h
    dw decrementToneSweepChannelSoundEffectTimer ; 13h: Bomb laid
    dw toneSweepSfx_playback_14 ; 14h
    dw toneSweepSfx_playback_15 ; 15h: Option select / missile select
    dw toneSweepSfx_playback_16 ; 16h: Shooting wave beam
    dw toneSweepSfx_playback_17 ; 17h
    dw decrementToneSweepChannelSoundEffectTimer ; 18h: Samus' health changed
    dw toneSweepSfx_playback_19 ; 19h: No missile dud shot
    dw toneSweepSfx_playback_1A ; 1Ah
    dw toneSweepSfx_playback_1B ; 1Bh: Metroid cry
    dw toneSweepSfx_playback_1C ; 1Ch: Saved
    dw toneSweepSfx_playback_1D ; 1Dh
    dw toneSweepSfx_playback_1E ; 1Eh: Unpaused
;}

playShortJumpSound:
;{
    ld a, $0b
    ld de, toneSweepOptionSets.jumping_0
    jp playToneSweepSfx
;}

playingShortJumpSound:
;{
    call decrementToneSweepChannelSoundEffectTimer
    cp $09
        jr z, toneSweepSfx_playback_1.set1
    ret
;}

toneSweepSfx_init_1:
;{
    ld a, [toneSweepChannelSoundEffectPlaying]
    cp toneSweepSoundEffect_shootingWaveBeam
        jp z, handleToneSweepChannelSoundEffect.playing

    cp toneSweepSoundEffect_shootingBeam
    jr c, .endIf
        cp toneSweepSoundEffect_shootingSpazerBeam
            jp c, handleToneSweepChannelSoundEffect.playing
    .endIf

    ld a, [songPlaying]
    cp song_chozoRuins
        jr z, playShortJumpSound

    ld a, $32
    ld de, toneSweepOptionSets.jumping_0
    jp playToneSweepSfx
;}

toneSweepSfx_playback_1:
;{
    ld a, [songPlaying]
    cp song_chozoRuins
        jr z, playingShortJumpSound

    call decrementToneSweepChannelSoundEffectTimer
    cp $2d
        jr z, .set1
    cp $1e
        jr z, .set2
    cp $18
        jr z, .set3
    cp $06
        jr z, .set4
    cp $01
        jr z, .set5
    ret

.set1
    ld de, toneSweepOptionSets.jumping_1
    jp setChannelOptionSet.toneSweep

.set2
    ld de, toneSweepOptionSets.jumping_2
    jp setChannelOptionSet.toneSweep

.set3
    ld de, toneSweepOptionSets.jumping_3
    jp setChannelOptionSet.toneSweep

.set4
    ld de, toneSweepOptionSets.jumping_4
    jp setChannelOptionSet.toneSweep

.set5
    ld de, toneSweepOptionSets.jumping_5
    jp setChannelOptionSet.toneSweep
;}

playShortHiJumpSound:
;{
    ld a, $09
    ld de, toneSweepOptionSets.hijumping_0
    jp playToneSweepSfx
;}

playingShortHiJumpSound:
;{
    call decrementToneSweepChannelSoundEffectTimer
    cp $08
        jr z, toneSweepSfx_playback_2.set1

    ret
;}

toneSweepSfx_init_2:
;{
    ld a, [toneSweepChannelSoundEffectPlaying]
    cp toneSweepSoundEffect_shootingWaveBeam
        jp z, handleToneSweepChannelSoundEffect.playing

    cp toneSweepSoundEffect_shootingBeam
    jr c, .endIf
        cp toneSweepSoundEffect_shootingSpazerBeam
            jp c, handleToneSweepChannelSoundEffect.playing
    .endIf

    ld a, [songPlaying]
    cp song_chozoRuins
        jr z, playShortHiJumpSound

    ld a, $43
    ld de, toneSweepOptionSets.hijumping_0
    jp playToneSweepSfx
;}

toneSweepSfx_playback_2:
;{
    ld a, [songPlaying]
    cp song_chozoRuins
        jr z, playingShortHiJumpSound

    call decrementToneSweepChannelSoundEffectTimer
    cp $41
        jr z, .set1
    cp $2d
        jr z, .set2
    cp $2b
        jr z, .set3
    cp $18
        jr z, .set4
    cp $15
        jr z, .set5
    cp $04
        jr z, .set6
    cp $01
        jr z, .set7
    ret

.set0
    ld de, toneSweepOptionSets.hijumping_0
    jp setChannelOptionSet.toneSweep

.set1
    ld de, toneSweepOptionSets.hijumping_1
    jp setChannelOptionSet.toneSweep

.set2
    ld de, toneSweepOptionSets.hijumping_2
    jp setChannelOptionSet.toneSweep

.set3
    ld de, toneSweepOptionSets.hijumping_3
    jp setChannelOptionSet.toneSweep

.set4
    ld de, toneSweepOptionSets.hijumping_4
    jp setChannelOptionSet.toneSweep

.set5
    ld de, toneSweepOptionSets.hijumping_5
    jp setChannelOptionSet.toneSweep

.set6
    ld de, toneSweepOptionSets.hijumping_6
    jp setChannelOptionSet.toneSweep

.set7
    ld de, toneSweepOptionSets.hijumping_7
    jp setChannelOptionSet.toneSweep
;}

toneSweepSfx_init_3:
;{
    ld a, $3f
    ld de, toneSweepOptionSets.screwAttacking_0
    jp playToneSweepSfx
;}

toneSweepSfx_playback_3:
;{
    ld a, [toneSweepChannelSoundEffectTimer]
    and a
        call z, .getTimerResetValue
        
    dec a
    ld [toneSweepChannelSoundEffectTimer], a
    cp $3b
        jr z, .set1
    cp $37
        jr z, .set2
    cp $33
        jr z, .set3
    cp $2f
        jr z, .set4
    cp $2b
        jr z, .set5
    cp $27
        jr z, .set6
    cp $23
        jr z, .set7
    cp $1f
        jr z, .set8
    cp $1b
        jr z, .set9
    cp $17
        jr z, .setA
    cp $13
        jr z, .setB
    cp $0f
        jr z, .setA
    cp $0c
        jr z, .setB
    cp $09
        jr z, .setC
    cp $06
        jr z, .setD
    cp $03
        jr z, .setC
    ret

.set1
    ld de, toneSweepOptionSets.screwAttacking_1
    jp setChannelOptionSet.toneSweep

.set2
    ld de, toneSweepOptionSets.screwAttacking_2
    jp setChannelOptionSet.toneSweep

.set3
    ld de, toneSweepOptionSets.screwAttacking_3
    jp setChannelOptionSet.toneSweep

.set4
    ld de, toneSweepOptionSets.screwAttacking_4
    jp setChannelOptionSet.toneSweep

.set5
    ld de, toneSweepOptionSets.screwAttacking_5
    jp setChannelOptionSet.toneSweep

.set6
    ld de, toneSweepOptionSets.screwAttacking_6
    jp setChannelOptionSet.toneSweep

.set7
    ld de, toneSweepOptionSets.screwAttacking_7
    jp setChannelOptionSet.toneSweep

.set8
    ld de, toneSweepOptionSets.screwAttacking_8
    jp setChannelOptionSet.toneSweep

.set9
    ld de, toneSweepOptionSets.screwAttacking_9
    jp setChannelOptionSet.toneSweep

.setA
    ld de, toneSweepOptionSets.screwAttacking_A
    jp setChannelOptionSet.toneSweep

.setB
    ld de, toneSweepOptionSets.screwAttacking_B
    jp setChannelOptionSet.toneSweep

.setC
    ld de, toneSweepOptionSets.screwAttacking_C
    jp setChannelOptionSet.toneSweep

.setD
    ld de, toneSweepOptionSets.screwAttacking_D
    jp setChannelOptionSet.toneSweep

.getTimerResetValue
    ld a, $10
    ret
;}

toneSweepSfx_init_4:
;{
    ld a, [toneSweepChannelSoundEffectPlaying]
    cp $04
        jp nc, handleToneSweepChannelSoundEffect.playing

    ld a, $0a
    ld de, toneSweepOptionSets.standingTransition_0
    jp playToneSweepSfx
;}

toneSweepSfx_playback_4:
;{
    call decrementToneSweepChannelSoundEffectTimer
    cp $06
        jr z, .set1
    cp $02
        jr z, .set2
    ret

.set1
    ld de, toneSweepOptionSets.standingTransition_1
    jp setChannelOptionSet.toneSweep

.set2
    ld de, toneSweepOptionSets.standingTransition_2
    jp setChannelOptionSet.toneSweep
;}

toneSweepSfx_init_5:
;{
    ld a, $0a
    ld de, toneSweepOptionSets.crouchingTransition_0
    jp playToneSweepSfx
;}

toneSweepSfx_playback_5:
;{
    call decrementToneSweepChannelSoundEffectTimer
    cp $06
        jr z, .set1
    cp $02
        jr z, .set2
    ret

.set1
    ld de, toneSweepOptionSets.crouchingTransition_1
    jp setChannelOptionSet.toneSweep

.set2
    ld de, toneSweepOptionSets.crouchingTransition_2
    jp setChannelOptionSet.toneSweep
;}

toneSweepSfx_init_6:
;{
    ld a, $0e
    ld de, toneSweepOptionSets.morphing_0
    jp playToneSweepSfx
;}

toneSweepSfx_playback_6:
;{
    call decrementToneSweepChannelSoundEffectTimer
    cp $0b
        jr z, .set0
    cp $08
        jr z, .set1
    cp $03
        jr z, .set2
    ret

.set0
    ld de, toneSweepOptionSets.morphing_0
    jp setChannelOptionSet.toneSweep

.set1
    ld de, toneSweepOptionSets.morphing_1
    jp setChannelOptionSet.toneSweep

.set2
    ld de, toneSweepOptionSets.morphing_2
    jp setChannelOptionSet.toneSweep
;}

toneSweepSfx_init_7:
;{
    ld a, $0f
    ld de, toneSweepOptionSets.shootingBeam_0
    jp playToneSweepSfx
;}

toneSweepSfx_playback_7:
;{
    call decrementToneSweepChannelSoundEffectTimer
    cp $0d
        jr z, .set1
    cp $0b
        jr z, .set1
    cp $09
        jr z, .set2
    cp $07
        jr z, .set2
    cp $05
        jr z, .set3
    cp $03
        jr z, .set3
    cp $01
        jr z, .set4
    ret

.set1
    ld de, toneSweepOptionSets.shootingBeam_1
    jp setChannelOptionSet.toneSweep

.set2
    ld de, toneSweepOptionSets.shootingBeam_2
    jp setChannelOptionSet.toneSweep

.set3
    ld de, toneSweepOptionSets.shootingBeam_3
    jp setChannelOptionSet.toneSweep

.set4
    ld de, toneSweepOptionSets.shootingBeam_4
    jp setChannelOptionSet.toneSweep
;}

toneSweepSfx_init_8:
;{
    ld a, $31
    ld de, toneSweepOptionSets.shootingMissile_0
    jp playToneSweepSfx
;}

toneSweepSfx_playback_8:
;{
    call decrementToneSweepChannelSoundEffectTimer
    cp $2d
        jr z, .set1
    cp $25
        jr z, .set2
    cp $1a
        jr z, .set3
    cp $18
        jr z, .set4
    cp $15
        jr z, .set5
    cp $12
        jr z, .set6
    cp $0f
        jr z, .set7
    cp $0c
        jr z, .set8
    cp $09
        jr z, .set9
    ret

.set1
    ld de, toneSweepOptionSets.shootingMissile_1
    jp setChannelOptionSet.toneSweep

.set2
    ld de, toneSweepOptionSets.shootingMissile_2
    jp setChannelOptionSet.toneSweep

.set3
    ld de, toneSweepOptionSets.shootingMissile_3
    jp setChannelOptionSet.toneSweep

.set4
    ld de, toneSweepOptionSets.shootingMissile_4
    jp setChannelOptionSet.toneSweep

.set5
    ld de, toneSweepOptionSets.shootingMissile_5
    jp setChannelOptionSet.toneSweep

.set6
    ld de, toneSweepOptionSets.shootingMissile_6
    jp setChannelOptionSet.toneSweep

.set7
    ld de, toneSweepOptionSets.shootingMissile_7
    jp setChannelOptionSet.toneSweep

.set8
    ld de, toneSweepOptionSets.shootingMissile_8
    jp setChannelOptionSet.toneSweep

.set9
    ld de, toneSweepOptionSets.shootingMissile_9
    jp setChannelOptionSet.toneSweep
;}

toneSweepSfx_init_9:
;{
    ld a, $d0
    ld [variableToneSweepChannelFrequency], a
    ld a, $14
    ld de, toneSweepOptionSets.shootingIceBeam
    jp playToneSweepSfx
;}

toneSweepSfx_playback_9:
;{
    call decrementToneSweepChannelSoundEffectTimer
    ld a, [variableToneSweepChannelFrequency]
    ldh [rAUD1LOW], a
    ld [variableToneSweepChannelFrequency], a
    ret
;}

toneSweepSfx_init_A:
;{
    ld a, $d0
    ld [variableToneSweepChannelFrequency], a
    ld a, $14
    ld de, toneSweepOptionSets.shootingPlasmaBeam
    jp playToneSweepSfx
;}

toneSweepSfx_playback_A:
;{
    call decrementToneSweepChannelSoundEffectTimer
    ld a, [variableToneSweepChannelFrequency]
    ldh [rAUD1LOW], a
    ld [variableToneSweepChannelFrequency], a
    ret
;}

toneSweepSfx_init_B:
;{
    ld a, $d0
    ld [variableToneSweepChannelFrequency], a
    ld a, $14
    ld de, toneSweepOptionSets.shootingSpazerBeam
    jp playToneSweepSfx
;}

toneSweepSfx_playback_B:
;{
    call decrementToneSweepChannelSoundEffectTimer
    ld a, [variableToneSweepChannelFrequency]
    ldh [rAUD1LOW], a
    ld [variableToneSweepChannelFrequency], a
    ret
;}

toneSweepSfx_init_C:
;{
    ld a, $14
    ld de, toneSweepOptionSets.pickingUpMissileDrop_0
    jp playToneSweepSfx
;}

toneSweepSfx_playback_C:
;{
    call decrementToneSweepChannelSoundEffectTimer
    cp $0d
        jr z, .set1
    cp $0b
        jr z, .set2
    cp $08
        jr z, .set3
    cp $05
        jr z, .set4
    cp $03
        jr z, setPickedUpDropEndOptionSet
    ret

.set1
    ld de, toneSweepOptionSets.pickingUpMissileDrop_1
    jp setChannelOptionSet.toneSweep

.set2
    ld de, toneSweepOptionSets.pickingUpMissileDrop_2
    jp setChannelOptionSet.toneSweep

.set3
    ld de, toneSweepOptionSets.pickingUpMissileDrop_3
    jp setChannelOptionSet.toneSweep

.set4
    ld de, toneSweepOptionSets.pickingUpMissileDrop_4
    jp setChannelOptionSet.toneSweep
;}

toneSweepSfx_init_D:
;{
    ld a, $0d
    ld de, toneSweepOptionSets.spiderBall_0
    jp playToneSweepSfx
;}

toneSweepSfx_playback_D:
;{
    call decrementToneSweepChannelSoundEffectTimer
    cp $03
        ret nz

    ld de, toneSweepOptionSets.spiderBall_1
    jp setChannelOptionSet.toneSweep
;}

toneSweepSfx_init_E:
;{
    call rememberIfScrewAttackingSfxIsPlaying
    ld a, $0a
    ld de, toneSweepOptionSets.pickedUpEnergyDrop_0
    jp playToneSweepSfx
;}

toneSweepSfx_playback_E:
;{
    call decrementToneSweepChannelSoundEffectTimer
    cp $01
        jp z, maybeResumeScrewAttackingSfx
    cp $08
        jr z, .set1
    cp $05
        jr z, .set2
    cp $03
        jr z, setPickedUpDropEndOptionSet
    ret

.set1
    ld de, toneSweepOptionSets.pickedUpEnergyDrop_1
    jp setChannelOptionSet.toneSweep

.set2
    ld de, toneSweepOptionSets.pickedUpEnergyDrop_2
    jp setChannelOptionSet.toneSweep
;}

setPickedUpDropEndOptionSet:
;{
    ld de, toneSweepOptionSets.pickedUpDropEnd
    jp setChannelOptionSet.toneSweep
;}

toneSweepSfx_init_F:
;{
    ld a, $05
    ld de, toneSweepOptionSets.shotMissileDoorWithBeam_0
    jp playToneSweepSfx
;}

toneSweepSfx_playback_F:
;{
    call decrementToneSweepChannelSoundEffectTimer
    cp $02
        jr z, .set1
    ret

.set1
    ld de, toneSweepOptionSets.shotMissileDoorWithBeam_1
    jp setChannelOptionSet.toneSweep
;}

toneSweepSfx_init_10:
;{
    ld a, $16
    ld de, toneSweepOptionSets.unknown10_0
    jp playToneSweepSfx
;}

toneSweepSfx_playback_10:
;{
    call decrementToneSweepChannelSoundEffectTimer
    cp $14
        jr z, .set1
    cp $12
        jr z, .set2
    cp $10
        jr z, .set3
    cp $0e
        jr z, .set4
    cp $0c
        jr z, .set5
    cp $0a
        jr z, .set6
    cp $08
        jr z, .set7
    cp $06
        jr z, .set8
    cp $04
        jr z, .set9
    cp $02
        jr z, .setA
    ret

.set1
    ld de, toneSweepOptionSets.unknown10_1
    jp setChannelOptionSet.toneSweep

.set2
    ld de, toneSweepOptionSets.unknown10_2
    jp setChannelOptionSet.toneSweep

.set3
    ld de, toneSweepOptionSets.unknown10_3
    jp setChannelOptionSet.toneSweep

.set4
    ld de, toneSweepOptionSets.unknown10_4
    jp setChannelOptionSet.toneSweep

.set5
    ld de, toneSweepOptionSets.unknown10_5
    jp setChannelOptionSet.toneSweep

.set6
    ld de, toneSweepOptionSets.unknown10_6
    jp setChannelOptionSet.toneSweep

.set7
    ld de, toneSweepOptionSets.unknown10_7
    jp setChannelOptionSet.toneSweep

.set8
    ld de, toneSweepOptionSets.unknown10_8
    jp setChannelOptionSet.toneSweep

.set9
    ld de, toneSweepOptionSets.unknown10_9
    jp setChannelOptionSet.toneSweep

.setA
    ld de, toneSweepOptionSets.unknown10_A
    jp setChannelOptionSet.toneSweep
;}

toneSweepSfx_init_12:
;{
    xor a
    ld de, toneSweepOptionSets.unused12
    jp playToneSweepSfx
;}

toneSweepSfx_init_13:
;{
    ld a, $02
    ld de, toneSweepOptionSets.bombLaid
    jp playToneSweepSfx
;}

toneSweepSfx_init_14:
;{
    ld a, $0e
    ld de, toneSweepOptionSets.unused14_0
    jp playToneSweepSfx
;}

toneSweepSfx_playback_14:
;{
    call decrementToneSweepChannelSoundEffectTimer
    cp $06
        jr z, .set1
    ret

.set1
    ld de, toneSweepOptionSets.unused14_1
    jp setChannelOptionSet.toneSweep
;}

toneSweepSfx_init_15:
;{
    ld a, $04
    ld de, toneSweepOptionSets.optionMissileSelect_0
    jp playToneSweepSfx
;}

toneSweepSfx_playback_15:
;{
    call decrementToneSweepChannelSoundEffectTimer
    cp $02
        jr z, .set1
    ret

.set1
    ld de, toneSweepOptionSets.optionMissileSelect_1
    jp setChannelOptionSet.toneSweep
;}

toneSweepSfx_init_16:
;{
    ld a, $1d
    ld de, toneSweepOptionSets.shootingWaveBeam_0
    jp playToneSweepSfx
;}

toneSweepSfx_playback_16:
;{
    call decrementToneSweepChannelSoundEffectTimer
    cp $1a
        jr z, .set1
    cp $15
        jr z, .set1
    cp $11
        jr z, .set2
    cp $0d
        jr z, .set2
    cp $09
        jr z, .set3
    cp $05
        jr z, .set3
    cp $01
        jr z, .set4
    ret

.set1
    ld de, toneSweepOptionSets.shootingWaveBeam_1
    jp setChannelOptionSet.toneSweep

.set2
    ld de, toneSweepOptionSets.shootingWaveBeam_2
    jp setChannelOptionSet.toneSweep

.set3
    ld de, toneSweepOptionSets.shootingWaveBeam_3
    jp setChannelOptionSet.toneSweep

.set4
    ld de, toneSweepOptionSets.shootingWaveBeam_4
    jp setChannelOptionSet.toneSweep
;}

toneSweepSfx_init_17:
;{
    call rememberIfScrewAttackingSfxIsPlaying
    ld a, $10
    ld de, toneSweepOptionSets.largeEnergyDrop_0
    jp playToneSweepSfx
;}

toneSweepSfx_playback_17:
;{
    call decrementToneSweepChannelSoundEffectTimer
    cp $01
        jp z, maybeResumeScrewAttackingSfx
    cp $0d
        jr z, .set1
    cp $0a
        jr z, .set2
    cp $08
        jr z, .set3
    cp $05
        jr z, .set4
    cp $02
        jr z, .set4
    ret

.set1
    ld de, toneSweepOptionSets.largeEnergyDrop_1
    jp setChannelOptionSet.toneSweep

.set2
    ld de, toneSweepOptionSets.largeEnergyDrop_2
    jp setChannelOptionSet.toneSweep

.set3
    ld de, toneSweepOptionSets.largeEnergyDrop_3
    jp setChannelOptionSet.toneSweep

.set4
    ld de, toneSweepOptionSets.largeEnergyDrop_4
    jp setChannelOptionSet.toneSweep
;}

toneSweepSfx_init_18:
;{
    ld a, [samusHealthChangedOptionSetIndex]
    and a
        call nz, .endIf ; Vanilla bug: call instead of jr
        ld a, $02
        ld [samusHealthChangedOptionSetIndex], a
    .endIf

    cp $01
        jr z, .set1
    cp $02
        jr z, .set0

    ld a, $02
    ld [samusHealthChangedOptionSetIndex], a
    ret

.set0
    dec a
    ld [samusHealthChangedOptionSetIndex], a
    ld a, $02
    ld de, toneSweepOptionSets.samusHealthChanged_0
    jp playToneSweepSfx

.set1
    dec a
    ld [samusHealthChangedOptionSetIndex], a
    ld a, $02
    ld de, toneSweepOptionSets.samusHealthChanged_1
    jp playToneSweepSfx
;}

toneSweepSfx_init_19:
;{
    ld a, $04
    ld de, toneSweepOptionSets.noMissileDudShot_0
    jp playToneSweepSfx
;}

toneSweepSfx_playback_19:
;{
    call decrementToneSweepChannelSoundEffectTimer
    cp $02
        jr z, .set1
    ret

.set1
    ld de, toneSweepOptionSets.noMissileDudShot_1
    jp setChannelOptionSet.toneSweep
;}

toneSweepSfx_init_1A:
;{
    ld a, $16
    ld de, toneSweepOptionSets.unknown1A_0
    jp playToneSweepSfx
;}

toneSweepSfx_playback_1A:
;{
    call decrementToneSweepChannelSoundEffectTimer
    cp $14
        jr z, .set1
    cp $12
        jr z, .set2
    cp $10
        jr z, .set1
    cp $0e
        jr z, .set3
    cp $0c
        jr z, .set1
    cp $0a
        jr z, .set4
    cp $08
        jr z, .set1
    cp $06
        jr z, .set5
    cp $04
        jr z, .set1
    cp $02
        jr z, .set6
    ret

.set1
    ld de, toneSweepOptionSets.unknown1A_1
    jp setChannelOptionSet.toneSweep

.set2
    ld de, toneSweepOptionSets.unknown1A_2
    jp setChannelOptionSet.toneSweep

.set3
    ld de, toneSweepOptionSets.unknown1A_3
    jp setChannelOptionSet.toneSweep

.set4
    ld de, toneSweepOptionSets.unknown1A_4
    jp setChannelOptionSet.toneSweep

.set5
    ld de, toneSweepOptionSets.unknown1A_5
    jp setChannelOptionSet.toneSweep

.set6
    ld de, toneSweepOptionSets.unknown1A_6
    jp setChannelOptionSet.toneSweep
;}

toneSweepSfx_init_1B:
;{
    ldh a, [rDIV]
    swap a
    set 7, a
    set 6, a
    set 5, a
    res 1, a
    ld [variableToneSweepChannelFrequency], a
    ld a, $30
    ld de, toneSweepOptionSets.metroidCry
    jp playToneSweepSfx
;}

toneSweepSfx_playback_1B:
;{
    call decrementToneSweepChannelSoundEffectTimer
    cp $20
        jr c, .endIf
        ld a, [variableToneSweepChannelFrequency]
        inc a
        inc a
        inc a
        inc a
        inc a
        inc a
        ldh [rAUD1LOW], a
        ld [variableToneSweepChannelFrequency], a
        ret
    .endIf

    ld a, [variableToneSweepChannelFrequency]
    dec a
    ldh [rAUD1LOW], a
    ld [variableToneSweepChannelFrequency], a
    ret
;}

toneSweepSfx_init_1C:
;{
    ld a, $0f
    ld de, toneSweepOptionSets.saved0
    jp playToneSweepSfx
;}

toneSweepSfx_playback_1C:
;{
    call decrementToneSweepChannelSoundEffectTimer
    cp $0a
        jr z, .set1
    cp $03
        jr z, .set2
    ret

.set1
    ld de, toneSweepOptionSets.saved1
    jp setChannelOptionSet.toneSweep

.set2
    ld de, toneSweepOptionSets.saved2
    jp setChannelOptionSet.toneSweep
;}

toneSweepSfx_init_1D:
;{
    ld a, $90
    ld de, toneSweepOptionSets.variaSuitTransformation
    jp playToneSweepSfx
;}

toneSweepSfx_playback_1D:
;{
    call decrementToneSweepChannelSoundEffectTimer
    cp $7e
        jr z, .set
    cp $6e
        jr z, .set
    cp $5e
        jr z, .set
    cp $4e
        jr z, .set
    cp $3e
        jr z, .set
    cp $2e
        jr z, .set
    cp $1e
        jr z, .set
    ret

.set
    ld de, toneSweepOptionSets.variaSuitTransformation
    jp setChannelOptionSet.toneSweep
;}

toneSweepSfx_init_1E:
;{
    ld a, $0e
    ld de, toneSweepOptionSets.unpaused_0
    jp playToneSweepSfx
;}

toneSweepSfx_playback_1E:
;{
    call decrementToneSweepChannelSoundEffectTimer
    cp $0a
        jr z, .set1
    cp $03
        jr z, .set2
    ret

.set1
    ld de, toneSweepOptionSets.unpaused_1
    jp setChannelOptionSet.toneSweep

.set2
    ld de, toneSweepOptionSets.unpaused_2
    jp setChannelOptionSet.toneSweep
;}


; All these following "examples" are completely unused
toneSweepSfx_init_exampleA:
;{
    ld a, $50
    ld de, toneSweepOptionSets.exampleA
    jp playToneSweepSfx
;}

toneSweepSfx_playback_exampleA:
;{
    ld de, toneSweepOptionSets.exampleA
    jp setChannelOptionSet.toneSweep
;}

toneSweepSfx_init_exampleB:
;{
    ld a, $50
    ld de, toneSweepOptionSets.exampleB
    jp playToneSweepSfx
;}

setOptionSet_exampleB:
;{
    ld de, toneSweepOptionSets.exampleB
    jp setChannelOptionSet.toneSweep
;}

toneSweepSfx_playback_exampleB:
;{
    call decrementToneSweepChannelSoundEffectTimer
    cp $40
        ret nz

    ld de, toneSweepOptionSets.exampleB
    jp setChannelOptionSet.toneSweep
;}

toneSweepSfx_init_exampleC:
;{
    ld a, $50
    ld de, toneSweepOptionSets.exampleC
    jp playToneSweepSfx
;}

setOptionSet_exampleC:
;{
    ld de, toneSweepOptionSets.exampleC
    jp setChannelOptionSet.toneSweep
;}

toneSweepSfx_playback_exampleC:
;{
    call decrementToneSweepChannelSoundEffectTimer
    cp $40
        jr z, setOptionSet_exampleC
    cp $30
        jr z, setOptionSet_exampleC
    ret
;}

toneSweepSfx_init_exampleD:
;{
    ld a, $50
    ld de, toneSweepOptionSets.exampleD
    jp playToneSweepSfx
;}

setOptionSet_exampleD:
;{
    ld de, toneSweepOptionSets.exampleD
    jp setChannelOptionSet.toneSweep
;}

toneSweepSfx_playback_exampleD:
;{
    call decrementToneSweepChannelSoundEffectTimer
    cp $40
        jr z, setOptionSet_exampleD
    cp $30
        jr z, setOptionSet_exampleD
    cp $20
        jr z, setOptionSet_exampleD
    ret
;}

toneSweepSfx_init_exampleE:
;{
    ld a, $50
    ld de, toneSweepOptionSets.exampleE
    jp playToneSweepSfx
;}

setOptionSet_exampleE:
;{
    ld de, toneSweepOptionSets.exampleE
    jp setChannelOptionSet.toneSweep
;}

toneSweepSfx_playback_exampleE:
;{
    call decrementToneSweepChannelSoundEffectTimer
    cp $40
        jr z, setOptionSet_exampleE
    cp $30
        jr z, setOptionSet_exampleE
    cp $20
        jr z, setOptionSet_exampleE
    cp $10
        jr z, setOptionSet_exampleE
    ret
;}


rememberIfScrewAttackingSfxIsPlaying:
;{
    ld a, [toneSweepChannelSoundEffectPlaying]
    cp toneSweepSoundEffect_screwAttacking
        ret nz

    ld [resumeScrewAttackSoundEffectFlag], a
    ret
;}

maybeResumeScrewAttackingSfx:
;{
    ld a, [resumeScrewAttackSoundEffectFlag]
    and a
        ret z

    ld a, [samusPose]
    cp pose_spinJump
        ret nz
        
    ld a, [samusItems]
    bit itemBit_screw, a
        ret z

    ld a, toneSweepSoundEffect_screwAttacking
    ld [toneSweepChannelSoundEffectPlaying], a
    xor a
    ld [resumeScrewAttackSoundEffectFlag], a
    ret
;}

playToneSweepSfx:
;{
    ld [toneSweepChannelSoundEffectTimer], a
    ld a, [sfxRequest_square1]
    ld [toneSweepChannelSoundEffectPlaying], a
    ld [toneSweepChannelSoundEffectIsPlayingFlag], a
    jp setChannelOptionSet.toneSweep
;}
;}

; Tone channel sound effects
;{
toneChannelSoundEffectInitialisationFunctionPointers:
;{
    dw initializeAudio.ret ; 1: ret
    dw initializeAudio.ret ; 2: ret
    dw toneSfx_init_3 ; 3: Metroid Queen cry
    dw toneSfx_init_4 ; 4: Baby Metroid hatched / clearing blocks
    dw toneSfx_init_5 ; 5: Baby Metroid cry
    dw toneSfx_init_6 ; 6: Metroid Queen hurt cry
    dw toneSfx_init_7 ; 7: unknown
;}

toneChannelSoundEffectPlaybackFunctionPointers:
;{
    dw initializeAudio.ret ; 1: ret
    dw initializeAudio.ret ; 2: ret
    dw toneSfx_playback_3 ; 3: Metroid Queen cry
    dw toneSfx_playback_4 ; 4: Baby Metroid hatched / clearing blocks
    dw toneSfx_playback_5 ; 5: Baby Metroid cry
    dw toneSfx_playback_6 ; 6: Metroid Queen hurt cry
    dw decrementToneChannelSoundEffectTimer ; 7: unknown
;}

toneSfx_init_3:
;{
    ldh a, [rDIV]
    swap a
    res 7, a
    res 6, a
    res 5, a
    ld [variableToneChannelFrequency], a
    ld a, $30
    ld de, toneOptionSets.metroidQueenCry
    jp playToneSfx
;}

toneSfx_playback_3:
toneSfx_playback_5:
toneSfx_playback_6:
;{
    call decrementToneChannelSoundEffectTimer
    bit 0, a
        jr z, .even

    ld a, [variableToneChannelFrequency]
    set 4, a
    ld [variableToneChannelFrequency], a

.merge
    ld a, [toneChannelSoundEffectTimer]
    cp $20
        jr c, .part2

    ld a, [variableToneChannelFrequency]
    add $03
    ldh [rAUD2LOW], a
    ld [variableToneChannelFrequency], a
    ret

.even
    ld a, [variableToneChannelFrequency]
    res 4, a
    ld [variableToneChannelFrequency], a
    jr .merge

.part2
    ld a, [variableToneChannelFrequency]
    dec a
    ldh [rAUD2LOW], a
    ld [variableToneChannelFrequency], a
    ret
;}

toneSfx_init_4:
;{
    ldh a, [rDIV]
    set 7, a
    res 6, a
    ld [variableToneChannelFrequency], a
    ld a, $1c
    ld de, toneOptionSets.babyMetroidClearingBlock
    jp playToneSfx
;}

toneSfx_playback_4:
;{
    call decrementToneChannelSoundEffectTimer
    cp $13
        jr z, .part2
    cp $0c
        jr z, .part3

    ld a, [variableToneChannelFrequency]
    inc a
    inc a
    ld [variableToneChannelFrequency], a
    ldh [rAUD2LOW], a
    ret

.part2
    ld a, $a0
    ld [variableToneChannelFrequency], a
    ret

.part3
    ld a, $90
    ld [variableToneChannelFrequency], a
    ret
;}

toneSfx_init_5:
;{
    ldh a, [rDIV]
    swap a
    res 7, a
    set 6, a
    res 4, a
    res 2, a
    ld [variableToneChannelFrequency], a
    ld a, $30
    ld de, toneOptionSets.babyMetroidCry
    jp playToneSfx
;}

toneSfx_init_6:
;{
    ldh a, [rDIV]
    swap a
    res 7, a
    set 6, a
    ld [variableToneChannelFrequency], a
    ld a, $30
    ld de, toneOptionSets.metroidQueenHurtCry
    jp playToneSfx
;}

toneSfx_init_7:
;{
    ld a, $01
    ld de, toneOptionSets.unknown7
    jp playToneSfx
;}

playToneSfx:
;{
    ld [toneChannelSoundEffectTimer], a
    ld a, [sfxRequest_square2]
    ld [toneChannelSoundEffectPlaying], a
    ld [toneChannelSoundEffectIsPlayingFlag], a
    jp setChannelOptionSet.tone
;}
;}

; Noise channel sound effects
;{
noiseChannelSoundEffectInitialisationFunctionPointers:
;{
    dw noiseSfx_init_1 ; 1: Enemy shot
    dw noiseSfx_init_2 ; 2: Enemy killed
    dw noiseSfx_init_3 ; 3:
    dw noiseSfx_init_4 ; 4: Shot block destroyed
    dw noiseSfx_init_5 ; 5: Metroid hurt
    dw noiseSfx_init_6 ; 6: Samus hurt
    dw noiseSfx_init_7 ; 7: Acid damage
    dw noiseSfx_init_8 ; 8: Shot missile door with missile
    dw noiseSfx_init_9 ; 9: Metroid Queen cry
    dw noiseSfx_init_A ; Ah: Metroid Queen hurt cry
    dw noiseSfx_init_B ; Bh: Samus killed
    dw noiseSfx_init_C ; Ch: Bomb detonated
    dw noiseSfx_init_D ; Dh: Metroid killed
    dw noiseSfx_init_E ; Eh:
    dw noiseSfx_init_F ; Fh:
    dw noiseSfx_init_10 ; 10h Footsteps
    dw noiseSfx_init_11 ; 11h:
    dw noiseSfx_init_12 ; 12h:
    dw noiseSfx_init_13 ; 13h: Unused
    dw noiseSfx_init_14 ; 14h:
    dw noiseSfx_init_15 ; 15h:
    dw noiseSfx_init_16 ; 16h: Baby Metroid hatched / clearing blocks
    dw noiseSfx_init_17 ; 17h: Baby Metroid cry
    dw noiseSfx_init_18 ; 18h:
    dw noiseSfx_init_19 ; 19h: Unused
    dw noiseSfx_init_1A ; 1Ah:
;}

noiseChannelSoundEffectPlaybackFunctionPointers:
;{
    dw decrementNoiseChannelSoundEffectTimer ; 1: Enemy shot
    dw noiseSfx_playback_2 ; 2: Enemy killed
    dw decrementNoiseChannelSoundEffectTimer ; 3:
    dw decrementNoiseChannelSoundEffectTimer ; 4: Shot block destroyed
    dw noiseSfx_playback_5 ; 5: Metroid hurt
    dw noiseSfx_playback_6 ; 6: Samus hurt
    dw noiseSfx_playback_7 ; 7: Acid damage
    dw noiseSfx_playback_8 ; 8: Shot missile door with missile
    dw noiseSfx_playback_9 ; 9: Metroid Queen cry
    dw noiseSfx_playback_A ; Ah: Metroid Queen hurt cry
    dw noiseSfx_playback_B ; Bh: Samus killed
    dw noiseSfx_playback_C ; Ch: Bomb detonated
    dw noiseSfx_playback_D ; Dh: Metroid killed
    dw noiseSfx_playback_E ; Eh:
    dw noiseSfx_playback_F ; Fh:
    dw noiseSfx_playback_10 ; 10h Footsteps
    dw noiseSfx_playback_11 ; 11h:
    dw noiseSfx_playback_12 ; 12h:
    dw noiseSfx_playback_13 ; 13h: Unused
    dw noiseSfx_playback_14 ; 14h:
    dw noiseSfx_playback_15 ; 15h:
    dw decrementNoiseChannelSoundEffectTimer ; 16h: Baby Metroid hatched / clearing blocks
    dw decrementNoiseChannelSoundEffectTimer ; 17h: Baby Metroid cry
    dw noiseSfx_playback_18 ; 18h:
    dw decrementNoiseChannelSoundEffectTimer ; 19h: Unused
    dw decrementNoiseChannelSoundEffectTimer ; 1Ah:
;}

noiseSfx_init_1:
;{
    ld a, $0d
    ld de, noiseOptionSets.enemyShot
    jp playNoiseSweepSfx
;}

noiseSfx_init_2:
;{
    ld a, $19
    ld de, noiseOptionSets.enemyKilled_0
    jp playNoiseSweepSfx
;}

noiseSfx_playback_2:
;{
    call decrementNoiseChannelSoundEffectTimer
    cp $0d
        jr z, .set1
    ret

.set1
    ld de, noiseOptionSets.enemyKilled_1
    jp setChannelOptionSet.noise
;}

noiseSfx_init_3:
;{
    ld a, $1d
    ld de, noiseOptionSets.unknown3
    jp playNoiseSweepSfx
;}

noiseSfx_init_4:
;{
    ld a, $08
    ld de, noiseOptionSets.shotBlockDestroyed
    jp playNoiseSweepSfx
;}

noiseSfx_init_5:
;{
    ld a, toneSweepSoundEffect_metroidCry
    ld [sfxRequest_square1], a
    ld a, $40
    ld de, noiseOptionSets.metroidHurt_0
    call playNoiseSweepSfx ; call instead of jp...?
;}

noiseSfx_playback_5:
;{
    call decrementNoiseChannelSoundEffectTimer
    cp $38
        jr z, .set1
    ret

.set1
    ld de, noiseOptionSets.metroidHurt_1
    jp setChannelOptionSet.noise
;}

noiseSfx_init_6:
;{
    ld a, $14
    ld de, noiseOptionSets.SamusHurt_0
    jp playNoiseSweepSfx
;}

noiseSfx_playback_6:
;{
    call decrementNoiseChannelSoundEffectTimer
    cp $10
        jr z, .set1
    cp $0c
        jr z, .set0
    cp $08
        jr z, .set1
    ret

.set0
    ld de, noiseOptionSets.SamusHurt_0
    jp setChannelOptionSet.noise

.set1
    ld de, noiseOptionSets.SamusHurt_1
    jp setChannelOptionSet.noise
;}

noiseSfx_init_7:
;{
    ld a, $08
    ld de, noiseOptionSets.acidDamage_0
    jp playNoiseSweepSfx
;}

noiseSfx_playback_7:
;{
    call decrementNoiseChannelSoundEffectTimer
    cp $05
        jr z, noiseSfx_playback_6.set1
    ret
;}

noiseSfx_init_8:
;{
    ld a, $08
    ld de, noiseOptionSets.shotMissileDoor_0
    jp playNoiseSweepSfx
;}

noiseSfx_playback_8:
;{
    call decrementNoiseChannelSoundEffectTimer
    cp $05
        jr z, .set1
    ret

.set1
    ld de, noiseOptionSets.shotMissileDoor_1
    jp setChannelOptionSet.noise
;}

noiseSfx_init_9:
;{
    ld a, toneSoundEffect_metroidQueenCry
    ld [sfxRequest_square2], a
    ld a, $40
    ld de, noiseOptionSets.metroidQueenCry_0
    jp playNoiseSweepSfx
;}

noiseSfx_playback_9:
;{
    call decrementNoiseChannelSoundEffectTimer
    cp $38
        jr z, .set1
    ret

.set1
    ld de, noiseOptionSets.metroidQueenCry_1
    jp setChannelOptionSet.noise
;}

noiseSfx_init_A:
;{
    ld a, toneSoundEffect_metroidQueenHurtCry
    ld [sfxRequest_square2], a
    ld a, $40
    ld de, noiseOptionSets.metroidQueenHurtCry_0
    jp playNoiseSweepSfx
;}

noiseSfx_playback_A:
;{
    call decrementNoiseChannelSoundEffectTimer
    cp $38
        jr z, .set1
    ret

.set1
    ld de, noiseOptionSets.metroidQueenHurtCry_1
    jp setChannelOptionSet.noise
;}

noiseSfx_init_B:
;{
    ld a, $b0
    ld de, noiseOptionSets.samusKilled_0
    jp playNoiseSweepSfx
;}

noiseSfx_playback_B:
;{
    call decrementNoiseChannelSoundEffectTimer
    cp $9f
        jr z, .set1
    cp $70
        jr z, .set2
    cp $6c
        jr z, setPolynomialCounter27
    cp $68
        jr z, setPolynomialCounter35
    cp $64                        
        jr z, setPolynomialCounter37
    cp $60                        
        jr z, setPolynomialCounter45
    cp $5c                        
        jr z, setPolynomialCounter47
    cp $58                        
        jr z, setPolynomialCounter55
    cp $54                        
        jr z, setPolynomialCounter57
    cp $50                        
        jr z, setPolynomialCounter65
    cp $4c                        
        jr z, setPolynomialCounter66
    cp $48                        
        jr z, setPolynomialCounter67
    cp $40
        jr z, setOptionSetSamusKilled_3
    ret

.set1
    ld de, noiseOptionSets.samusKilled_1
    jp setChannelOptionSet.noise

.set2
    ld de, noiseOptionSets.samusKilled_2
    jp setChannelOptionSet.noise
;}

setPolynomialCounter27:
;{
    ld a, $27
    ldh [rAUD4POLY], a
    ret
;}

setPolynomialCounter35:
;{
    ld a, $35
    ldh [rAUD4POLY], a
    ret
;}

setPolynomialCounter37:
;{
    ld a, $37
    ldh [rAUD4POLY], a
    ret
;}

setPolynomialCounter45:
;{
    ld a, $45
    ldh [rAUD4POLY], a
    ret
;}

setPolynomialCounter47:
;{
    ld a, $47
    ldh [rAUD4POLY], a
    ret
;}

setPolynomialCounter55:
;{
    ld a, $55
    ldh [rAUD4POLY], a
    ret
;}

setPolynomialCounter57:
;{
    ld a, $57
    ldh [rAUD4POLY], a
    ret
;}

setPolynomialCounter65:
;{
    ld a, $65
    ldh [rAUD4POLY], a
    ret
;}

setPolynomialCounter66:
;{
    ld a, $66
    ldh [rAUD4POLY], a
    ret
;}

setPolynomialCounter67:
;{
    ld a, $67
    ldh [rAUD4POLY], a
    ret
;}

setOptionSetSamusKilled_3:
;{
    ld de, noiseOptionSets.samusKilled_3
    jp setChannelOptionSet.noise
;}

noiseSfx_init_C:
;{
    ld a, $14
    ld de, noiseOptionSets.bombDetonated_0
    jp playNoiseSweepSfx
;}

noiseSfx_playback_C:
;{
    call decrementNoiseChannelSoundEffectTimer
    cp $0c
        jr z, .set1
    ret

.set1
    ld de, noiseOptionSets.bombDetonated_1
    jp setChannelOptionSet.noise
;}

noiseSfx_init_D:
;{
    ld a, $35
    ld de, noiseOptionSets.metroidKilled_0
    jp playNoiseSweepSfx
;}

noiseSfx_playback_D:
;{
    call decrementNoiseChannelSoundEffectTimer
    cp $30
        jr z, setPolynomialCounter57
    cp $2c                        
        jr z, setPolynomialCounter35
    cp $27                        
        jr z, setPolynomialCounter37
    cp $23                        
        jr z, setPolynomialCounter55
    cp $20                        
        jr z, setPolynomialCounter47
    cp $1d                        
        jr z, setPolynomialCounter45
    cp $1a
        jr z, .set1
    ret

.set1
    ld de, noiseOptionSets.metroidKilled_1
    jp setChannelOptionSet.noise
;}

noiseSfx_init_E:
;{
    ld a, $4f
    ld de, noiseOptionSets.unknownE_0
    jp playNoiseSweepSfx
;}

noiseSfx_playback_E:
;{
    call decrementNoiseChannelSoundEffectTimer
    cp $4d
        jr z, setPolynomialCounter65
    cp $4a                        
        jp z, setPolynomialCounter57
    cp $47                        
        jp z, setPolynomialCounter55
    cp $44                        
        jp z, setPolynomialCounter47
    cp $41                        
        jp z, setPolynomialCounter65
    cp $3e                        
        jp z, setPolynomialCounter57
    cp $3b                        
        jp z, setPolynomialCounter55
    cp $39                        
        jp z, setPolynomialCounter47
    cp $36                        
        jp z, setPolynomialCounter45
    cp $33                        
        jp z, setPolynomialCounter37
    cp $30
        jr z, .set1
    ret

.set1
    ld de, noiseOptionSets.unknownE_1
    jp setChannelOptionSet.noise
;}

noiseSfx_init_F:
;{
    ld a, $70
    ld de, noiseOptionSets.clearedSaveFile_0
    jp playNoiseSweepSfx
;}

noiseSfx_playback_F:
;{
    call decrementNoiseChannelSoundEffectTimer
    cp $6d
        jp z, setPolynomialCounter67
    cp $6a                        
        jp z, setPolynomialCounter66
    cp $67                        
        jp z, setPolynomialCounter65
    cp $64                        
        jp z, setPolynomialCounter57
    cp $61                        
        jp z, setPolynomialCounter55
    cp $5e                        
        jp z, setPolynomialCounter47
    cp $5b                        
        jp z, setPolynomialCounter45
    cp $59                        
        jp z, setPolynomialCounter37
    cp $56                        
        jp z, setPolynomialCounter35
    cp $53                        
        jp z, setPolynomialCounter27
    cp $50
        jr z, .set1
    ret

.set1
    ld de, noiseOptionSets.clearedSaveFile_1
    jp setChannelOptionSet.noise
;}

noiseSfx_init_10:
;{
    ld a, [noiseChannelSoundEffectPlaying]
    and a
        jp nz, handleNoiseChannelSoundEffect.playing

    ld a, [songNoiseChannelEnable]
    and a
        jp nz, handleNoiseChannelSoundEffect.playing

    ld a, $02
    ld de, noiseOptionSets.footsteps_0
    jp playNoiseSweepSfx
;}

noiseSfx_playback_10:
;{
    call decrementNoiseChannelSoundEffectTimer
    cp $01
        jp z, .set1
    ret

.set1
    ld de, noiseOptionSets.footsteps_1
    jp setChannelOptionSet.noise
;}

noiseSfx_init_11:
;{
    ld a, $10
    ld de, noiseOptionSets.unknown11_0
    jp playNoiseSweepSfx
;}

noiseSfx_playback_11:
noiseSfx_playback_12:
noiseSfx_playback_13:
;{
    call decrementNoiseChannelSoundEffectTimer
    cp $0c
        jr z, .set1
    ret

.set1
    ld de, noiseOptionSets.unknown_1
    jp setChannelOptionSet.noise
;}

noiseSfx_init_12:
;{
    ld a, $10
    ld de, noiseOptionSets.unknown12_0
    jp playNoiseSweepSfx
;}

noiseSfx_init_13:
;{
    ld a, $10
    ld de, noiseOptionSets.unused13_0
    jp playNoiseSweepSfx
;}

noiseSfx_init_14:
;{
    ld a, $18
    ld de, noiseOptionSets.unknown14_0
    jp playNoiseSweepSfx
;}

noiseSfx_playback_14:
;{
    call decrementNoiseChannelSoundEffectTimer
    cp $10
        jr z, .set1
    cp $0c
        jr z, .set0
    cp $08
        jr z, .set1
    ret

.set1
    ld de, noiseOptionSets.unknown14_1
    jp setChannelOptionSet.noise

.set0
    ld de, noiseOptionSets.unknown14_0
    jp setChannelOptionSet.noise
;}

noiseSfx_init_15:
;{
    ld a, $30
    ld de, noiseOptionSets.unknown15_0
    jp playNoiseSweepSfx
;}

noiseSfx_playback_15:
;{
    call decrementNoiseChannelSoundEffectTimer
    cp $20
        jr z, .set1
    ret

.set1
    ld de, noiseOptionSets.unknown15_1
    jp setChannelOptionSet.noise
;}

noiseSfx_init_16:
;{
    ld a, toneSoundEffect_babyMetroidClearingBlock
    ld [sfxRequest_square2], a
    ld a, $08
    ld de, noiseOptionSets.babyMetroidClearingBlock
    jp playNoiseSweepSfx
;}

noiseSfx_init_17:
;{
    ld a, toneSoundEffect_babyMetroidCry
    ld [sfxRequest_square2], a
    ld a, $40
    ld de, noiseOptionSets.babyMetroidCry
    jp playNoiseSweepSfx
;}

noiseSfx_init_18:
;{
    ld a, $0f
    ld de, noiseOptionSets.unknown18_0
    jp playNoiseSweepSfx
;}

noiseSfx_playback_18:
;{
    call decrementNoiseChannelSoundEffectTimer
    cp $0c
        jr z, .set1
    ret

.set1
    ld de, noiseOptionSets.unknown18_1
    jp setChannelOptionSet.noise
;}

noiseSfx_init_19:
;{
    ld a, $10
    ld de, noiseOptionSets.unused19
    jp playNoiseSweepSfx
;}

noiseSfx_init_1A:
;{
    ld a, $10
    ld de, noiseOptionSets.unknown1A
    jp playNoiseSweepSfx
;}

playNoiseSweepSfx:
;{
    ld [noiseChannelSoundEffectTimer], a
    ld a, [sfxRequest_noise]
    ld [noiseChannelSoundEffectPlaying], a
    ld [noiseChannelSoundEffectIsPlayingFlag], a
    jp setChannelOptionSet.noise
;}
;}

; Option sets
;{
toneSweepOptionSets:
;{
.jumping_0 ; $5A28
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 0
    DescendingEnvelopeOptions 7, $A
    FrequencyOptions $690, 0

.jumping_1 ; $5A2D
    AscendingSweepOptions 6, 2
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 3, $8
    FrequencyOptions $5C0, 0

.jumping_2 ; $5A32
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 0
    DescendingEnvelopeOptions 7, $4
    FrequencyOptions $690, 0

.jumping_3 ; $5A37
    AscendingSweepOptions 6, 2
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $3
    FrequencyOptions $5C0, 0

.jumping_4 ; $5A3C
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 0
    DescendingEnvelopeOptions 7, $2
    FrequencyOptions $690, 0

.jumping_5 ; $5A41
    AscendingSweepOptions 6, 2
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $2
    FrequencyOptions $5C0, 0


.hijumping_0 ; $5A46
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 0
    DescendingEnvelopeOptions 7, $A
    FrequencyOptions $690, 0

.hijumping_1 ; $5A4B
    AscendingSweepOptions 6, 2
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 3, $7
    FrequencyOptions $6C0, 0

.hijumping_2 ; $5A50
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 0
    DescendingEnvelopeOptions 7, $3
    FrequencyOptions $690, 0

.hijumping_3 ; $5A55
    AscendingSweepOptions 6, 2
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $3
    FrequencyOptions $6C0, 0

.hijumping_4 ; $5A5A
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 0
    DescendingEnvelopeOptions 7, $2
    FrequencyOptions $690, 0

.hijumping_5 ; $5A5F
    AscendingSweepOptions 6, 2
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $2
    FrequencyOptions $6C0, 0

.hijumping_6 ; $5A64
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 0
    DescendingEnvelopeOptions 7, $1
    FrequencyOptions $690, 0

.hijumping_7 ; $5A69
    AscendingSweepOptions 6, 2
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $1
    FrequencyOptions $6C0, 0


.screwAttacking_0 ; $5A6E
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 0
    DescendingEnvelopeOptions 7, $7
    FrequencyOptions $700, 0

.screwAttacking_1 ; $5A73
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 0
    DescendingEnvelopeOptions 7, $B
    FrequencyOptions $560, 0

.screwAttacking_2 ; $5A78
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 0
    DescendingEnvelopeOptions 7, $F
    FrequencyOptions $5C0, 0

.screwAttacking_3 ; $5A7D
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 0
    DescendingEnvelopeOptions 7, $F
    FrequencyOptions $600, 0

.screwAttacking_4 ; $5A82
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 1
    DescendingEnvelopeOptions 7, $F
    FrequencyOptions $640, 0

.screwAttacking_5 ; $5A87
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 1
    DescendingEnvelopeOptions 7, $E
    FrequencyOptions $670, 0

.screwAttacking_6 ; $5A8C
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $D
    FrequencyOptions $690, 0

.screwAttacking_7 ; $5A91
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $C
    FrequencyOptions $6B0, 0

.screwAttacking_8 ; $5A96
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $A
    FrequencyOptions $6C0, 0

.screwAttacking_9 ; $5A9B
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 1
    DescendingEnvelopeOptions 7, $8
    FrequencyOptions $6C0, 0

.screwAttacking_A ; $5AA0
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 1
    DescendingEnvelopeOptions 7, $8
    FrequencyOptions $6D0, 0

.screwAttacking_B ; $5AA5
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 1
    DescendingEnvelopeOptions 7, $4
    FrequencyOptions $6E0, 0

.screwAttacking_C ; $5AAA
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 1
    DescendingEnvelopeOptions 7, $5
    FrequencyOptions $6F0, 0

.screwAttacking_D ; $5AAF
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 1
    DescendingEnvelopeOptions 7, $5
    FrequencyOptions $700, 0


.standingTransition_0 ; $5AB4
    AscendingSweepOptions 4, 1
    LengthDutyOptions $36, 2
    DescendingEnvelopeOptions 1, $9
    FrequencyOptions $4A0, 1

.standingTransition_1 ; $5AB9
    AscendingSweepOptions 4, 1
    LengthDutyOptions $36, 2
    DescendingEnvelopeOptions 1, $7
    FrequencyOptions $4A0, 1

.standingTransition_2 ; $5ABE
    AscendingSweepOptions 4, 1
    LengthDutyOptions $36, 2
    DescendingEnvelopeOptions 1, $5
    FrequencyOptions $4A0, 1


.crouchingTransition_0 ; $5AC3
    AscendingSweepOptions 4, 1
    LengthDutyOptions $26, 1
    DescendingEnvelopeOptions 1, $9
    FrequencyOptions $4A0, 1

.crouchingTransition_1 ; $5AC8
    AscendingSweepOptions 4, 1
    LengthDutyOptions $26, 1
    DescendingEnvelopeOptions 1, $6
    FrequencyOptions $4A0, 1

.crouchingTransition_2 ; $5ACD
    AscendingSweepOptions 4, 1
    LengthDutyOptions $26, 1
    DescendingEnvelopeOptions 1, $4
    FrequencyOptions $4A0, 1


.morphing_0 ; $5AD2
    AscendingSweepOptions 4, 1
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $A
    FrequencyOptions $700, 0

.morphing_1 ; $5AD7
    DescendingSweepOptions 5, 3
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 1, $C
    FrequencyOptions $750, 0

.morphing_2 ; $5ADC
    DescendingSweepOptions 5, 3
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 1, $6
    FrequencyOptions $750, 0


.shootingBeam_0 ; $5AE1
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 0
    DescendingEnvelopeOptions 7, $F
    FrequencyOptions $6D0, 0

.shootingBeam_1 ; $5AE6
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 5, $9
    FrequencyOptions $680, 0

.shootingBeam_2 ; $5AEB
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 5, $9
    FrequencyOptions $6C0, 0

.shootingBeam_3 ; $5AF0
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 5, $8
    FrequencyOptions $700, 0

.shootingBeam_4 ; $5AF5
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 5, $7
    FrequencyOptions $780, 0


.shootingMissile_0 ; $5AFA
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 1
    DescendingEnvelopeOptions 7, $F
    FrequencyOptions $690, 0

.shootingMissile_1 ; $5AFF
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 0
    DescendingEnvelopeOptions 7, $F
    FrequencyOptions $5A0, 0

.shootingMissile_2 ; $5B04
    DescendingSweepOptions 5, 1
    LengthDutyOptions $0, 0
    DescendingEnvelopeOptions 5, $5
    FrequencyOptions $7A0, 0

.shootingMissile_3 ; $5B09
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 0
    DescendingEnvelopeOptions 7, $6
    FrequencyOptions $600, 0

.shootingMissile_4 ; $5B0E
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 0
    DescendingEnvelopeOptions 7, $A
    FrequencyOptions $620, 0

.shootingMissile_5 ; $5B13
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 0
    DescendingEnvelopeOptions 7, $9
    FrequencyOptions $640, 0

.shootingMissile_6 ; $5B18
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 0
    DescendingEnvelopeOptions 7, $8
    FrequencyOptions $660, 0

.shootingMissile_7 ; $5B1D
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 0
    DescendingEnvelopeOptions 7, $6
    FrequencyOptions $680, 0

.shootingMissile_8 ; $5B22
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 0
    DescendingEnvelopeOptions 7, $4
    FrequencyOptions $6A0, 0

.shootingMissile_9 ; $5B27
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 0
    DescendingEnvelopeOptions 7, $3
    FrequencyOptions $6C0, 0


.shootingIceBeam ; $5B2C
    DescendingSweepOptions 7, 1
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $7
    FrequencyOptions $7D0, 0


.shootingPlasmaBeam ; $5B31
    AscendingSweepOptions 7, 1
    LengthDutyOptions $0, 0
    DescendingEnvelopeOptions 7, $A
    FrequencyOptions $600, 0


.shootingSpazerBeam ; $5B36
    DescendingSweepOptions 7, 1
    LengthDutyOptions $0, 0
    DescendingEnvelopeOptions 7, $C
    FrequencyOptions $7D0, 0


.pickingUpMissileDrop_0 ; $5B3B
    AscendingSweepOptions 5, 3
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $8
    FrequencyOptions $6A0, 0

.pickingUpMissileDrop_1 ; $5B40
    AscendingSweepOptions 4, 3
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $C
    FrequencyOptions $710, 0

.pickingUpMissileDrop_2 ; $5B45
    AscendingSweepOptions 4, 3
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $B
    FrequencyOptions $740, 0

.pickingUpMissileDrop_3 ; $5B4A
    AscendingSweepOptions 4, 3
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $9
    FrequencyOptions $760, 0

.pickingUpMissileDrop_4 ; $5B4F
    AscendingSweepOptions 4, 3
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $6
    FrequencyOptions $780, 0


.spiderBall_0 ; $5B54
    DescendingSweepOptions 2, 2
    LengthDutyOptions $0, 0
    DescendingEnvelopeOptions 7, $F
    FrequencyOptions $600, 0

.spiderBall_1 ; $5B59
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $5
    FrequencyOptions $600, 0


.pickedUpEnergyDrop_0 ; $5B5E
    DescendingSweepOptions 1, 3
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $E
    FrequencyOptions $740, 0

.pickedUpEnergyDrop_1 ; $5B63
    AscendingSweepOptions 4, 4
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $D
    FrequencyOptions $6F0, 0

.pickedUpEnergyDrop_2 ; $5B68
    AscendingSweepOptions 4, 4
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $9
    FrequencyOptions $6F0, 0


.pickedUpDropEnd ; $5B6D
    AscendingSweepOptions 4, 4
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $3
    FrequencyOptions $6F0, 0


.shotMissileDoorWithBeam_0 ; $5B72
    AscendingSweepOptions 4, 4
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 1, $C
    FrequencyOptions $700, 0

.shotMissileDoorWithBeam_1 ; $5B77
    AscendingSweepOptions 0, 0
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 1, $4
    FrequencyOptions $7D0, 0


.unknown10_0 ; $5B7C
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $A
    FrequencyOptions $5A0, 0

.unknown10_1 ; $5B81
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $A
    FrequencyOptions $5C0, 0

.unknown10_2 ; $5B86
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $A
    FrequencyOptions $5F0, 0

.unknown10_3 ; $5B8B
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $A
    FrequencyOptions $610, 0

.unknown10_4 ; $5B90
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $A
    FrequencyOptions $640, 0

.unknown10_5 ; $5B95
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $A
    FrequencyOptions $670, 0

.unknown10_6 ; $5B9A
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $A
    FrequencyOptions $690, 0

.unknown10_7 ; $5B9F
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $A
    FrequencyOptions $6A0, 0

.unknown10_8 ; $5BA4
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $A
    FrequencyOptions $6C0, 0

.unknown10_9 ; $5BA9
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $A
    FrequencyOptions $6E0, 0

.unknown10_A ; $5BAE
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $A
    FrequencyOptions $700, 0


.unused12 ; $5BB3
    AscendingSweepOptions 0, 0
    LengthDutyOptions $0, 0
    AscendingEnvelopeOptions 0, $0
    FrequencyOptions $0, 0


.bombLaid ; $5BB8
    DescendingSweepOptions 6, 1
    LengthDutyOptions $0, 1
    DescendingEnvelopeOptions 7, $5
    FrequencyOptions $7C0, 0


.unused14_0 ; $5BBD
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 0
    DescendingEnvelopeOptions 7, $C
    FrequencyOptions $400, 0

.unused14_1 ; $5BC2
    DescendingSweepOptions 5, 1
    LengthDutyOptions $0, 0
    DescendingEnvelopeOptions 7, $C
    FrequencyOptions $7D0, 0


.optionMissileSelect_0 ; $5BC7
    AscendingSweepOptions 4, 1
    LengthDutyOptions $0, 0
    DescendingEnvelopeOptions 7, $C
    FrequencyOptions $700, 0

.optionMissileSelect_1 ; $5BCC
    AscendingSweepOptions 4, 1
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $C
    FrequencyOptions $640, 0


.shootingWaveBeam_0 ; $5BD1
    AscendingSweepOptions 6, 1
    LengthDutyOptions $0, 1
    DescendingEnvelopeOptions 7, $F
    FrequencyOptions $6D0, 0

.shootingWaveBeam_1 ; $5BD6
    AscendingSweepOptions 6, 1
    LengthDutyOptions $0, 1
    DescendingEnvelopeOptions 7, $C
    FrequencyOptions $680, 0

.shootingWaveBeam_2 ; $5BDB
    AscendingSweepOptions 6, 1
    LengthDutyOptions $0, 1
    DescendingEnvelopeOptions 7, $A
    FrequencyOptions $6C0, 0

.shootingWaveBeam_3 ; $5BE0
    AscendingSweepOptions 6, 1
    LengthDutyOptions $0, 1
    DescendingEnvelopeOptions 7, $8
    FrequencyOptions $700, 0

.shootingWaveBeam_4 ; $5BE5
    AscendingSweepOptions 7, 1
    LengthDutyOptions $0, 1
    DescendingEnvelopeOptions 7, $C
    FrequencyOptions $7A0, 0


.largeEnergyDrop_0 ; $5BEA
    DescendingSweepOptions 1, 3
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $F
    FrequencyOptions $740, 0

.largeEnergyDrop_1 ; $5BEF
    AscendingSweepOptions 4, 4
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $E
    FrequencyOptions $710, 0

.largeEnergyDrop_2 ; $5BF4
    AscendingSweepOptions 4, 4
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $C
    FrequencyOptions $710, 0

.largeEnergyDrop_3 ; $5BF9
    AscendingSweepOptions 4, 4
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $A
    FrequencyOptions $710, 0

.largeEnergyDrop_4 ; $5BFE
    AscendingSweepOptions 4, 4
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $3
    FrequencyOptions $710, 0


.samusHealthChanged_0 ; $5C03
    AscendingSweepOptions 6, 1
    LengthDutyOptions $3D, 2
    DescendingEnvelopeOptions 5, $5
    FrequencyOptions $750, 0

.samusHealthChanged_1 ; $5C08
    AscendingSweepOptions 0, 0
    LengthDutyOptions $3D, 2
    DescendingEnvelopeOptions 5, $5
    FrequencyOptions $7A0, 0


.noMissileDudShot_0 ; $5C0D
    AscendingSweepOptions 4, 1
    LengthDutyOptions $0, 0
    DescendingEnvelopeOptions 7, $C
    FrequencyOptions $6A0, 0

.noMissileDudShot_1 ; $5C12
    AscendingSweepOptions 5, 1
    LengthDutyOptions $0, 0
    DescendingEnvelopeOptions 7, $C
    FrequencyOptions $6A0, 0


.unknown1A_0 ; $5C17
    DescendingSweepOptions 5, 1
    LengthDutyOptions $0, 0
    DescendingEnvelopeOptions 1, $F
    FrequencyOptions $7C0, 0

.unknown1A_1 ; $5C1C
    DescendingSweepOptions 1, 3
    LengthDutyOptions $0, 0
    DescendingEnvelopeOptions 1, $F
    FrequencyOptions $7D0, 0

.unknown1A_2 ; $5C21
    DescendingSweepOptions 5, 1
    LengthDutyOptions $0, 0
    DescendingEnvelopeOptions 1, $E
    FrequencyOptions $7C4, 0

.unknown1A_3 ; $5C26
    DescendingSweepOptions 5, 1
    LengthDutyOptions $0, 0
    DescendingEnvelopeOptions 1, $D
    FrequencyOptions $7CC, 0

.unknown1A_4 ; $5C2B
    DescendingSweepOptions 5, 1
    LengthDutyOptions $0, 0
    DescendingEnvelopeOptions 1, $E
    FrequencyOptions $7D0, 0

.unknown1A_5 ; $5C30
    DescendingSweepOptions 5, 1
    LengthDutyOptions $0, 0
    DescendingEnvelopeOptions 1, $D
    FrequencyOptions $7D8, 0

.unknown1A_6 ; $5C35
    DescendingSweepOptions 5, 1
    LengthDutyOptions $38, 0
    DescendingEnvelopeOptions 1, $E
    FrequencyOptions $7DC, 1


.metroidCry ; $5C3A
    DescendingSweepOptions 7, 4
    LengthDutyOptions $0, 0
    DescendingEnvelopeOptions 6, $F
    FrequencyOptions $7F0, 0


.saved0 ; $5C3F
    DescendingSweepOptions 4, 5
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $C
    FrequencyOptions $780, 0

.saved1 ; $5C44
    AscendingSweepOptions 5, 4
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $8
    FrequencyOptions $782, 0

.saved2 ; $5C49
    AscendingSweepOptions 5, 4
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $5
    FrequencyOptions $782, 0


.variaSuitTransformation ; $5C4E
    AscendingSweepOptions 4, 3
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 5, $A
    FrequencyOptions $200, 0


.unpaused_0 ; $5C53
    AscendingSweepOptions 3, 4
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $F
    FrequencyOptions $700, 0

.unpaused_1 ; $5C58
    AscendingSweepOptions 5, 4
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $F
    FrequencyOptions $7A2, 0

.unpaused_2 ; $5C5D
    AscendingSweepOptions 5, 4
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 7, $5
    FrequencyOptions $7A2, 0


.exampleA ; $5C62
    AscendingSweepOptions 7, 7
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 1, $F
    FrequencyOptions $600, 0


.exampleB ; $5C67
    AscendingSweepOptions 7, 7
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 1, $F
    FrequencyOptions $6A0, 0


.exampleC ; $5C6C
    AscendingSweepOptions 7, 7
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 1, $F
    FrequencyOptions $700, 0


.exampleD ; $5C71
    AscendingSweepOptions 7, 7
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 1, $F
    FrequencyOptions $740, 0


.exampleE ; $5C76
    AscendingSweepOptions 7, 7
    LengthDutyOptions $0, 2
    DescendingEnvelopeOptions 1, $F
    FrequencyOptions $790, 0
;}

noiseOptionSets:
;{
.enemyShot ; $5C7B
    LengthOptions $0
    AscendingEnvelopeOptions 1, $0
    PolynomialCounterOptions 2, 0, $6
    CounterControlOptions 0

.enemyKilled_0 ; $5C7F
    LengthOptions $0
    AscendingEnvelopeOptions 1, $1
    PolynomialCounterOptions 3, 0, $3
    CounterControlOptions 0

.enemyKilled_1 ; $5C83
    LengthOptions $0
    DescendingEnvelopeOptions 1, $F
    PolynomialCounterOptions 6, 1, $4
    CounterControlOptions 0

.unknown3 ; $5C87
    LengthOptions $0
    DescendingEnvelopeOptions 2, $F
    PolynomialCounterOptions 4, 1, $6
    CounterControlOptions 0

.shotBlockDestroyed ; $5C8B
    LengthOptions $0
    AscendingEnvelopeOptions 1, $1
    PolynomialCounterOptions 5, 1, $4
    CounterControlOptions 0

.metroidHurt_0 ; $5C8F
    LengthOptions $0
    AscendingEnvelopeOptions 1, $0
    PolynomialCounterOptions 5, 1, $3
    CounterControlOptions 0

.metroidHurt_1 ; $5C93
    LengthOptions $0
    DescendingEnvelopeOptions 4, $F
    PolynomialCounterOptions 5, 0, $4
    CounterControlOptions 0

.SamusHurt_0 ; $5C97
    LengthOptions $0
    DescendingEnvelopeOptions 7, $F
    PolynomialCounterOptions 2, 1, $4
    CounterControlOptions 0

.SamusHurt_1 ; $5C9B
.acidDamage_1 ; $5C9B
    LengthOptions $0
    DescendingEnvelopeOptions 5, $4
    PolynomialCounterOptions 2, 1, $4
    CounterControlOptions 0

.acidDamage_0 ; $5C9F
    LengthOptions $0
    DescendingEnvelopeOptions 7, $F
    PolynomialCounterOptions 2, 1, $4
    CounterControlOptions 0

.shotMissileDoor_0 ; $5CA3
    LengthOptions $0
    DescendingEnvelopeOptions 7, $F
    PolynomialCounterOptions 3, 0, $3
    CounterControlOptions 0

.shotMissileDoor_1 ; $5CA7
    LengthOptions $0
    DescendingEnvelopeOptions 1, $F
    PolynomialCounterOptions 4, 1, $5
    CounterControlOptions 0

.metroidQueenCry_0 ; $5CAB
    LengthOptions $0
    DescendingEnvelopeOptions 2, $E
    PolynomialCounterOptions 6, 1, $4
    CounterControlOptions 0

.metroidQueenCry_1 ; $5CAF
    LengthOptions $0
    DescendingEnvelopeOptions 6, $C
    PolynomialCounterOptions 5, 0, $4
    CounterControlOptions 0

.metroidQueenHurtCry_0 ; $5CB3
    LengthOptions $0
    DescendingEnvelopeOptions 2, $F
    PolynomialCounterOptions 2, 1, $5
    CounterControlOptions 0

.metroidQueenHurtCry_1 ; $5CB7
    LengthOptions $0
    DescendingEnvelopeOptions 4, $F
    PolynomialCounterOptions 4, 0, $4
    CounterControlOptions 0

.samusKilled_1 ; $5CBB
    LengthOptions $0
    AscendingEnvelopeOptions 5, $0
    PolynomialCounterOptions 4, 0, $2
    CounterControlOptions 0

.samusKilled_2 ; $5CBF
    LengthOptions $0
    DescendingEnvelopeOptions 0, $F
    PolynomialCounterOptions 5, 0, $1
    CounterControlOptions 0

.samusKilled_3 ; $5CC3
    LengthOptions $0
    DescendingEnvelopeOptions 7, $8
    PolynomialCounterOptions 4, 0, $7
    CounterControlOptions 0

.bombDetonated_0 ; $5CC7
    LengthOptions $0
    DescendingEnvelopeOptions 7, $A
    PolynomialCounterOptions 3, 0, $4
    CounterControlOptions 0

.bombDetonated_1 ; $5CCB
    LengthOptions $0
    DescendingEnvelopeOptions 1, $F
    PolynomialCounterOptions 4, 0, $6
    CounterControlOptions 0

.metroidKilled_0 ; $5CCF
    LengthOptions $0
    DescendingEnvelopeOptions 7, $F
    PolynomialCounterOptions 4, 0, $6
    CounterControlOptions 0

.metroidKilled_1 ; $5CD3
    LengthOptions $0
    DescendingEnvelopeOptions 3, $A
    PolynomialCounterOptions 2, 0, $2
    CounterControlOptions 0

.unknownE_0 ; $5CD7
    LengthOptions $0
    DescendingEnvelopeOptions 7, $F
    PolynomialCounterOptions 2, 0, $2
    CounterControlOptions 0

.unknownE_1 ; $5CDB
    LengthOptions $0
    DescendingEnvelopeOptions 5, $A
    PolynomialCounterOptions 3, 0, $3
    CounterControlOptions 0

.clearedSaveFile_0 ; $5CDF
    LengthOptions $0
    DescendingEnvelopeOptions 0, $F
    PolynomialCounterOptions 3, 0, $4
    CounterControlOptions 0

.clearedSaveFile_1 ; $5CE3
    LengthOptions $0
    DescendingEnvelopeOptions 6, $F
    PolynomialCounterOptions 5, 0, $6
    CounterControlOptions 0

.footsteps_0 ; $5CE7
    LengthOptions $3D
    DescendingEnvelopeOptions 7, $3
    PolynomialCounterOptions 2, 1, $2
    CounterControlOptions 1

.footsteps_1 ; $5CEB
    LengthOptions $3C
    DescendingEnvelopeOptions 5, $1
    PolynomialCounterOptions 2, 1, $2
    CounterControlOptions 1

.unknown11_0 ; $5CEF
    LengthOptions $0
    DescendingEnvelopeOptions 3, $7
    PolynomialCounterOptions 7, 0, $2
    CounterControlOptions 0

.unknown_1 ; $5CF3
    LengthOptions $0
    DescendingEnvelopeOptions 7, $9
    PolynomialCounterOptions 7, 0, $7
    CounterControlOptions 0

.unknown12_0 ; $5CF7
    LengthOptions $0
    DescendingEnvelopeOptions 7, $8
    PolynomialCounterOptions 4, 0, $4
    CounterControlOptions 0

.unused13_0 ; $5CFB
    LengthOptions $0
    DescendingEnvelopeOptions 7, $8
    PolynomialCounterOptions 3, 0, $3
    CounterControlOptions 0

.unknown14_0 ; $5CFF
    LengthOptions $0
    DescendingEnvelopeOptions 1, $9
    PolynomialCounterOptions 4, 1, $3
    CounterControlOptions 0

.unknown14_1 ; $5D03
    LengthOptions $0
    DescendingEnvelopeOptions 1, $9
    PolynomialCounterOptions 3, 1, $4
    CounterControlOptions 0

.unknown15_0 ; $5D07
    LengthOptions $0
    DescendingEnvelopeOptions 7, $A
    PolynomialCounterOptions 5, 0, $5
    CounterControlOptions 0

.unknown15_1 ; $5D0B
    LengthOptions $0
    DescendingEnvelopeOptions 3, $C
    PolynomialCounterOptions 3, 0, $5
    CounterControlOptions 0

.babyMetroidClearingBlock ; $5D0F
    LengthOptions $0
    AscendingEnvelopeOptions 3, $1
    PolynomialCounterOptions 1, 0, $3
    CounterControlOptions 0

.babyMetroidCry ; $5D13
    LengthOptions $0
    DescendingEnvelopeOptions 7, $A
    PolynomialCounterOptions 5, 1, $7
    CounterControlOptions 0

.unknown18_0 ; $5D17
    LengthOptions $0
    DescendingEnvelopeOptions 1, $6
    PolynomialCounterOptions 7, 1, $2
    CounterControlOptions 0

.unknown18_1 ; $5D1B
    LengthOptions $0
    DescendingEnvelopeOptions 0, $6
    PolynomialCounterOptions 1, 0, $2
    CounterControlOptions 0

.unused19 ; $5D1F
    LengthOptions $0
    DescendingEnvelopeOptions 3, $C
    PolynomialCounterOptions 1, 0, $1
    CounterControlOptions 0

.unknown1A ; $5D23
    LengthOptions $0
    DescendingEnvelopeOptions 4, $4
    PolynomialCounterOptions 2, 1, $4
    CounterControlOptions 0

.samusKilled_0 ; $5D27
    LengthOptions $0
    AscendingEnvelopeOptions 0, $0
    PolynomialCounterOptions 0, 0, $0
    CounterControlOptions 0
;}

toneOptionSets:
;{
.metroidQueenCry ; $5D2B
    LengthDutyOptions $0, 0
    DescendingEnvelopeOptions 4, $F
    FrequencyOptions $700, 0

.babyMetroidClearingBlock ; $5D2F
    LengthDutyOptions $0, 0
    DescendingEnvelopeOptions 7, $9
    FrequencyOptions $790, 0

.babyMetroidCry ; $5D33
    LengthDutyOptions $0, 1
    DescendingEnvelopeOptions 7, $5
    FrequencyOptions $700, 0

.metroidQueenHurtCry ; $5D37
    LengthDutyOptions $0, 1
    DescendingEnvelopeOptions 7, $F
    FrequencyOptions $700, 0

.unknown7 ; $5D3B
    LengthDutyOptions $0, 0
    DescendingEnvelopeOptions 7, $8
    FrequencyOptions $200, 0
;}
;}

; Wave channel sound effects
;{
waveChannelSoundEffectInitialisationFunctionPointers:
;{
    dw waveSfx_init_1 ; 1: Samus' health < 10
    dw waveSfx_init_2 ; 2: Samus' health < 20
    dw waveSfx_init_3 ; 3: Samus' health < 30
    dw waveSfx_init_4 ; 4: Samus' health < 40
    dw waveSfx_init_5 ; 5: Samus' health < 50
;}

waveChannelSoundEffectPlaybackFunctionPointers:
;{
    dw waveSfx_playback_1 ; 1: Samus' health < 10
    dw waveSfx_playback_2 ; 2: Samus' health < 20
    dw waveSfx_playback_3 ; 3: Samus' health < 30
    dw waveSfx_playback_4 ; 4: Samus' health < 40
    dw waveSfx_playback_5 ; 5: Samus' health < 50
;}

waveSfx_init_1:
waveSfx_init_2:
;{
    xor a
    ldh [rAUD3ENA], a
    ld de, wavePatterns.wave4
    call writeToWavePatternRam
    ld a, $0c
    ld [loudLowHealthBeepTimer], a
    ld a, $0e
    ld de, waveOptionSets.healthUnder20_0
    jp Jump_004_5f27
;}

waveSfx_playback_1:
waveSfx_playback_2:
;{
    ld a, $01
    ld [waveChannelSoundEffectIsPlayingFlag], a
    ld a, [waveChannelSoundEffectTimer]
    dec a
    ld [waveChannelSoundEffectTimer], a
    cp $0a
        jr z, .set1
    and a
        jr z, .set0
    ret

.set1
    ld a, [loudLowHealthBeepTimer]
    and a
    jr z, .else1
        dec a
        ld [loudLowHealthBeepTimer], a
        ld de, wavePatterns.wave4
        call writeToWavePatternRam
        jr .endIf1
    .else1
        xor a
        ldh [rAUD3ENA], a
        ld de, wavePatterns.wave5
        call writeToWavePatternRam
    .endIf1

    ld de, waveOptionSets.healthUnder20_1
    jp setChannelOptionSet.wave

.set0
    ld a, [loudLowHealthBeepTimer]
    and a
    jr z, .else0
        ld de, wavePatterns.wave4
        call writeToWavePatternRam
        jr .endIf0
    .else0
        ld de, wavePatterns.wave5
        call writeToWavePatternRam
    .endIf0

    ld a, [waveChannelSoundEffectLength]
    ld [waveChannelSoundEffectTimer], a
    ld de, waveOptionSets.healthUnder20_0
    jp setChannelOptionSet.wave
;}

waveSfx_init_3:
;{
    xor a
    ldh [rAUD3ENA], a
    ld de, wavePatterns.wave4
    call writeToWavePatternRam
    ld a, $06
    ld [loudLowHealthBeepTimer], a
    ld a, $13
    ld de, waveOptionSets.healthUnder30_0
    jp Jump_004_5f27
;}

waveSfx_playback_3:
;{
    ld a, $02
    ld [waveChannelSoundEffectIsPlayingFlag], a
    ld a, [waveChannelSoundEffectTimer]
    dec a
    ld [waveChannelSoundEffectTimer], a
    cp $09
        jr z, .set1
    and a
        jr z, .set0
    ret

.set1
    ld a, [loudLowHealthBeepTimer]
    and a
    jr z, .else1
        dec a
        ld [loudLowHealthBeepTimer], a
        ld de, wavePatterns.wave4
        call writeToWavePatternRam
        jr .endIf1
    .else1
        xor a
        ldh [rAUD3ENA], a
        ld de, wavePatterns.wave5
        call writeToWavePatternRam
    .endIf1

    ld de, waveOptionSets.healthUnder30_1
    jp setChannelOptionSet.wave

.set0
    ld a, [loudLowHealthBeepTimer]
    and a
    jr z, .else0
        ld de, wavePatterns.wave4
        call writeToWavePatternRam
        jr .endIf0
    .else0
        ld de, wavePatterns.wave5
        call writeToWavePatternRam
    .endIf0

    ld a, [waveChannelSoundEffectLength]
    ld [waveChannelSoundEffectTimer], a
    ld de, waveOptionSets.healthUnder30_0
    jp setChannelOptionSet.wave
;}

waveSfx_init_4:
;{
    xor a
    ldh [rAUD3ENA], a
    ld de, wavePatterns.wave4
    call writeToWavePatternRam
    ld a, $06
    ld [loudLowHealthBeepTimer], a
    ld a, $16
    ld de, waveOptionSets.healthUnder40_0
    jp Jump_004_5f27
;}

waveSfx_playback_4:
;{
    ld a, $03
    ld [waveChannelSoundEffectIsPlayingFlag], a
    ld a, [waveChannelSoundEffectTimer]
    dec a
    ld [waveChannelSoundEffectTimer], a
    cp $09
        jr z, .set1
    and a
        jr z, .set0
    ret

.set1
    ld a, [loudLowHealthBeepTimer]
    and a
    jr z, .else1
        dec a
        ld [loudLowHealthBeepTimer], a
        ld de, wavePatterns.wave4
        call writeToWavePatternRam
        jr .endIf1
    .else1
        xor a
        ldh [rAUD3ENA], a
        ld de, wavePatterns.wave5
        call writeToWavePatternRam
    .endIf1

    ld de, waveOptionSets.healthUnder40_1
    jp setChannelOptionSet.wave

.set0
    ld a, [loudLowHealthBeepTimer]
    and a
    jr z, .else0
        ld de, wavePatterns.wave4
        call writeToWavePatternRam
        jr .endIf0
    .else0
        ld de, wavePatterns.wave5
        call writeToWavePatternRam
    .endIf0

    ld a, [waveChannelSoundEffectLength]
    ld [waveChannelSoundEffectTimer], a
    ld de, waveOptionSets.healthUnder40_0
    jp setChannelOptionSet.wave
;}

waveSfx_init_5:
;{
    xor a
    ldh [rAUD3ENA], a
    ld de, wavePatterns.wave4
    call writeToWavePatternRam
    ld a, $06
    ld [loudLowHealthBeepTimer], a
    ld a, $18
    ld de, waveOptionSets.healthUnder50_0
    jp Jump_004_5f27
;}

waveSfx_playback_5:
;{
    ld a, $04
    ld [waveChannelSoundEffectIsPlayingFlag], a
    ld a, [waveChannelSoundEffectTimer]
    dec a
    ld [waveChannelSoundEffectTimer], a
    cp $0b
        jr z, .set1
    and a
        jr z, .set0
    ret

.set1
    ld a, [loudLowHealthBeepTimer]
    and a
    jr z, .else1
        dec a
        ld [loudLowHealthBeepTimer], a
        ld de, wavePatterns.wave4
        call writeToWavePatternRam
        jr .endIf1
    .else1
        xor a
        ldh [rAUD3ENA], a
        ld de, wavePatterns.wave5
        call writeToWavePatternRam
    .endIf1

    ld de, waveOptionSets.healthUnder50_1
    jp setChannelOptionSet.wave

.set0
    ld a, [loudLowHealthBeepTimer]
    and a
    jr z, .else0
        ld de, wavePatterns.wave4
        call writeToWavePatternRam
        jr .endIf0
    .else0
        ld de, wavePatterns.wave5
        call writeToWavePatternRam
    .endIf0

    ld a, [waveChannelSoundEffectLength]
    ld [waveChannelSoundEffectTimer], a
    ld de, waveOptionSets.healthUnder50_0
    jp setChannelOptionSet.wave
;}

waveOptionSets:
;{
macro WaveOptionSet ; [volume], [frequency]
    static_assert \1 < 4, "Invalid volume"
    static_assert \2 < $800, "Invalid frequency"
    
    db $80, $00, \1 << 5
    dw \2 | $8000
endm

.healthUnder20_0 ; $5EFF
    WaveOptionSet 1, $4F0

.healthUnder20_1 ; $5F04
    WaveOptionSet 2, $4D0

.healthUnder30_0 ; $5F09
    WaveOptionSet 1, $4C4

.healthUnder30_1 ; $5F0E
    WaveOptionSet 2, $4C4

.healthUnder40_0 ; $5F13
    WaveOptionSet 1, $4B6

.healthUnder40_1 ; $5F18
    WaveOptionSet 2, $4B6

.healthUnder50_0 ; $5F1D
    WaveOptionSet 1, $4A3

.healthUnder50_1 ; $5F22
    WaveOptionSet 2, $4A3
;}

Jump_004_5f27:
;{
    ld [waveChannelSoundEffectTimer], a
    ld [waveChannelSoundEffectLength], a
    jp setChannelOptionSet.wave
;}
;}

; Song data:
;{
songDataTable:
;{
    dw song_babyMetroid_header
    dw song_metroidQueenBattle_header
    dw song_chozoRuins_header
    dw song_mainCaves_header
    dw song_subCaves1_header
    dw song_subCaves2_header
    dw song_subCaves3_header
    dw song_finalCaves_header
    dw song_metroidHive_header
    dw song_itemGet_header
    dw song_metroidQueenHallway_header
    dw song_metroidBattle_header
    dw song_subCaves4_header
    dw song_earthquake_header
    dw song_killedMetroid_header
    dw initializeAudio.ret ; 10h: Nothing
    dw song_title_header
    dw song_samusFanfare_header
    dw song_reachedTheGunship_header
    dw song_chozoRuins_clone_header
    dw song_mainCaves_noIntro_header
    dw song_subCaves1_noIntro_header
    dw song_subCaves2_noIntro_header
    dw song_subCaves3_noIntro_header
    dw song_finalCaves_clone_header
    dw song_metroidHive_clone_header
    dw song_itemGet_clone_header
    dw song_metroidQueenHallway_clone_header
    dw song_metroidBattle_clone_header
    dw song_subCaves4_noIntro_header
    dw song_metroidHive_withIntro_header
    dw song_missilePickup_header
;}

songStereoFlags:
;{
    db $FF ; 1: Baby Metroid
    db $FF ; 2: Metroid Queen battle
    db $FF ; 3: Chozo ruins
    db $FF ; 4: Main caves
    db $FF ; 5: Sub caves 1
    db $FF ; 6: Sub caves 2
    db $FF ; 7: Sub caves 3
    db $FF ; 8: Final caves
    db $FF ; 9: Metroid hive
    db $DB ; Ah: Item-get
    db $FF ; Bh: Metroid Queen hallway
    db $FF ; Ch: Metroid battle
    db $FF ; Dh: Sub caves 4
    db $DE ; Eh: Earthquake
    db $DE ; Fh: Killed Metroid
    db $FF ; 10h: Nothing
    db $FF ; 11h: Title
    db $DE ; 12h: Samus fanfare
    db $FF ; 13h: Reach the gunship
    db $FF ; 14h: Chozo ruins, same as 3
    db $FF ; 15h: Main caves, no intro
    db $FF ; 16h: Sub caves 1, no intro
    db $FF ; 17h: Sub caves 2, no intro
    db $FF ; 18h: Sub caves 3, no intro
    db $FF ; 19h: Final caves, same as 8
    db $FF ; 1Ah: Metroid hive, same as 9
    db $DB ; 1Bh: Item-get, same as Ah
    db $FF ; 1Ch: Metroid Queen hallway, same as Bh
    db $FF ; 1Dh: Metroid battle, same as Ch
    db $FF ; 1Eh: Sub caves 4, no intro
    db $FF ; 1Fh: Metroid hive with intro
    db $DE ; 20h: Missile pickup
;}

; $5F90
song_babyMetroid_header:
    SongHeader $1, $4106, song_babyMetroid_toneSweep, song_babyMetroid_tone, song_babyMetroid_wave, song_babyMetroid_noise

; $5F9B
song_babyMetroid_toneSweep:
;{
    dw song_babyMetroid_toneSweep_section0 ; $7E1A
    dw song_babyMetroid_toneSweep_section1 ; $7E1A
    dw song_babyMetroid_toneSweep_section2 ; $7E09
    dw song_babyMetroid_toneSweep_section3 ; $7D42
    dw song_babyMetroid_toneSweep_section4 ; $5FE7
    dw song_babyMetroid_toneSweep_section5 ; $7D47
    dw song_babyMetroid_toneSweep_section6 ; $5FF2
    dw song_babyMetroid_toneSweep_section7 ; $7D4C
    dw song_babyMetroid_toneSweep_section8 ; $6002
    .loop
    dw song_babyMetroid_toneSweep_section9 ; $600A
    dw $00F0, .loop
;}

; $5FB3
song_babyMetroid_tone:
;{
    dw song_babyMetroid_tone_section0 ; $7E1A
    dw song_babyMetroid_tone_section1 ; $7E1A
    dw song_babyMetroid_tone_section2 ; $7E09
    dw song_babyMetroid_tone_section3 ; $7D42
    dw song_babyMetroid_tone_section4 ; $6025
    dw song_babyMetroid_tone_section5 ; $7D47
    dw song_babyMetroid_tone_section6 ; $6030
    dw song_babyMetroid_tone_section7 ; $7D4C
    dw song_babyMetroid_tone_section8 ; $603E
    .loop
    dw song_babyMetroid_tone_section9 ; $6046
    dw $00F0, .loop
;}

; $5FCB
song_babyMetroid_wave:
;{
    dw song_babyMetroid_wave_section0 ; $7E21
    dw song_babyMetroid_wave_section1 ; $7E21
    dw song_babyMetroid_wave_section2 ; $7E10
    dw song_babyMetroid_wave_section3 ; $7D5B
    dw song_babyMetroid_wave_section4 ; $6060
    .loop
    dw song_babyMetroid_wave_section5 ; $605C
    dw $00F0, .loop
;}

; $5FDB
song_babyMetroid_noise:
;{
    .loop
    dw song_babyMetroid_noise_section0 ; $7E28
    dw song_babyMetroid_noise_section1 ; $7E28
    dw song_babyMetroid_noise_section2 ; $7E17
    dw song_babyMetroid_noise_section3 ; $6084
    dw $00F0, .loop
;}

; $5FE7
song_babyMetroid_toneSweep_section4:
;{
    SongRepeatSetup $2
        SongNoteLength_Quaver
        SongNote "C4"
        SongNote "F4"
        SongNote "G4"
        SongNote "Bb4"
        SongNoteLength_Crochet
        SongNote "Eb4"
    SongRepeat
    SongEnd
;}

; $5FF2
song_babyMetroid_toneSweep_section6:
;{
    SongRepeatSetup $2
        SongNoteLength_Quaver
        SongNote "C4"
        SongNote "F4"
        SongNote "G4"
        SongNote "Bb4"
        SongNoteLength_Crochet
        SongNote "Eb4"
    SongRepeat
    SongNoteLength_Quaver
    SongNote "C4"
    SongNote "F4"
    SongNote "G4"
    SongNote "Bb4"
    SongEnd
;}

; $6002
song_babyMetroid_toneSweep_section8:
;{
    SongRepeatSetup $3
        SongNote "C4"
        SongNote "F4"
        SongNote "G4"
        SongNote "Bb4"
    SongRepeat
    SongEnd
;}

; $600A
song_babyMetroid_toneSweep_section9:
;{
    SongOptions
        DescendingEnvelopeOptions 7, $7
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 2
    SongRepeatSetup $4
        SongNoteLength_Quaver
        SongNote "C4"
        SongNote "F4"
        SongNote "G4"
        SongNote "Bb4"
        SongNoteLength_Crochet
        SongNote "Eb4"
    SongRepeat
    SongNoteLength_Quaver
    SongNote "C4"
    SongNote "F4"
    SongNote "G4"
    SongNote "Bb4"
    SongRepeatSetup $3
        SongNote "C4"
        SongNote "F4"
        SongNote "G4"
        SongNote "Bb4"
    SongRepeat
    SongEnd
;}

; $6025
song_babyMetroid_tone_section4:
;{
    SongRepeatSetup $3
        SongNoteLength_DottedQuaver
        SongNote "C4"
        SongNote "F4"
        SongNote "G4"
        SongNote "Bb4"
        SongNote "Eb4"
        SongNote "F4"
    SongRepeat
    SongEnd
;}

; $6030
song_babyMetroid_tone_section6:
;{
    SongNote "C4"
    SongNote "F4"
    SongNote "G4"
    SongNote "Bb4"
    SongNote "Eb4"
    SongNote "F4"
    SongRepeatSetup $2
        SongNote "C4"
        SongNote "F4"
        SongNote "G4"
        SongNote "Bb4"
    SongRepeat
    SongEnd
;}

; $603E
song_babyMetroid_tone_section8:
;{
    SongRepeatSetup $2
        SongNote "C4"
        SongNote "F4"
        SongNote "G4"
        SongNote "Bb4"
    SongRepeat
    SongEnd
;}

; $6046
song_babyMetroid_tone_section9:
;{
    SongOptions
        DescendingEnvelopeOptions 7, $7
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 2
    SongRepeatSetup $4
        SongNoteLength_DottedQuaver
        SongNote "C4"
        SongNote "F4"
        SongNote "G4"
        SongNote "Bb4"
        SongNote "Eb4"
        SongNote "F4"
    SongRepeat
    SongRepeatSetup $4
        SongNote "C4"
        SongNote "F4"
        SongNote "G4"
        SongNote "Bb4"
    SongRepeat
    SongEnd
;}

; $605C
song_babyMetroid_wave_section5:
;{
    SongOptions
        WaveOptions $4113, 3, $0
;}

; $6060
song_babyMetroid_wave_section4:
;{
    SongRepeatSetup $4
        SongNoteLength_Semiquaver
        SongNote "C5"
        Echo1
        SongNote "F5"
        Echo1
        SongNote "G5"
        Echo1
        SongNote "Bb5"
        Echo1
        SongNoteLength_Quaver
        SongNote "Eb5"
        Echo1
    SongRepeat
    SongNoteLength_Semiquaver
    SongNote "C5"
    Echo1
    SongNote "F5"
    Echo1
    SongNote "G5"
    Echo1
    SongNote "Bb5"
    Echo1
    SongRepeatSetup $3
        SongNote "C5"
        Echo1
        SongNote "F5"
        Echo1
        SongNote "G5"
        Echo1
        SongNote "Bb5"
        Echo1
    SongRepeat
    SongEnd
;}

; $6084
song_babyMetroid_noise_section3:
;{
    SongNoteLength_Crochet
    SongNoiseNote $1D
    SongNoiseNote $1E
    SongNoteLength_Demisemiquaver
    SongRest
    SongEnd
;}

; $608A
song_metroidQueenBattle_header:
    SongHeader $1, $4106, song_metroidQueenBattle_toneSweep, song_metroidQueenBattle_tone, song_metroidQueenBattle_wave, song_metroidQueenBattle_noise

; $6095
song_metroidQueenBattle_toneSweep:
;{
    dw song_metroidQueenBattle_toneSweep_section0 ; $6107
    dw song_metroidQueenBattle_toneSweep_section1 ; $6112
    dw song_metroidQueenBattle_toneSweep_section2 ; $7D86
    dw song_metroidQueenBattle_toneSweep_section3 ; $6112
    dw song_metroidQueenBattle_toneSweep_section4 ; $7D82
    dw song_metroidQueenBattle_toneSweep_section5 ; $6112
    dw song_metroidQueenBattle_toneSweep_section6 ; $7D7E
    dw song_metroidQueenBattle_toneSweep_section7 ; $6112
    dw song_metroidQueenBattle_toneSweep_section8 ; $7D7A
    dw song_metroidQueenBattle_toneSweep_section9 ; $6112
    dw song_metroidQueenBattle_toneSweep_sectionA ; $7D76
    dw song_metroidQueenBattle_toneSweep_sectionB ; $7D91
    dw song_metroidQueenBattle_toneSweep_sectionC ; $6112
    dw song_metroidQueenBattle_toneSweep_sectionD ; $7D72
    dw song_metroidQueenBattle_toneSweep_sectionE ; $7D94
    dw song_metroidQueenBattle_toneSweep_sectionF ; $6112
    dw song_metroidQueenBattle_toneSweep_section10 ; $7D6E
    dw song_metroidQueenBattle_toneSweep_section11 ; $7D97
    dw song_metroidQueenBattle_toneSweep_section12 ; $6112
    dw song_metroidQueenBattle_toneSweep_section13 ; $7D6A
    dw song_metroidQueenBattle_toneSweep_section14 ; $7D9A
    dw song_metroidQueenBattle_toneSweep_section15 ; $6112
    dw song_metroidQueenBattle_toneSweep_section16 ; $7D6A
    dw song_metroidQueenBattle_toneSweep_section17 ; $7D9D
    dw song_metroidQueenBattle_toneSweep_section18 ; $6112
    dw song_metroidQueenBattle_toneSweep_section19 ; $7D6A
    dw song_metroidQueenBattle_toneSweep_section1A ; $7D9A
    dw song_metroidQueenBattle_toneSweep_section1B ; $610C
    dw song_metroidQueenBattle_toneSweep_section1C ; $7D6E
    dw song_metroidQueenBattle_toneSweep_section1D ; $7D97
    dw song_metroidQueenBattle_toneSweep_section1E ; $610C
    dw song_metroidQueenBattle_toneSweep_section1F ; $7D72
    dw song_metroidQueenBattle_toneSweep_section20 ; $7D94
    dw song_metroidQueenBattle_toneSweep_section21 ; $610C
    dw song_metroidQueenBattle_toneSweep_section22 ; $7D76
    dw song_metroidQueenBattle_toneSweep_section23 ; $7D91
    dw song_metroidQueenBattle_toneSweep_section24 ; $610C
    dw song_metroidQueenBattle_toneSweep_section25 ; $7D7E
    dw song_metroidQueenBattle_toneSweep_section26 ; $7D8E
    .loop
    dw song_metroidQueenBattle_toneSweep_section27 ; $6118
    dw $00F0, .loop
;}

; $60E9
song_metroidQueenBattle_tone:
;{
    dw song_metroidQueenBattle_tone_section0 ; $6122
    dw song_metroidQueenBattle_tone_section1 ; $612F
    .loop
    dw song_metroidQueenBattle_tone_section2 ; $613C
    dw $00F0, .loop
;}

; $60F3
song_metroidQueenBattle_wave:
;{
    dw song_metroidQueenBattle_wave_section0 ; $6146
    dw song_metroidQueenBattle_wave_section1 ; $6153
    .loop
    dw song_metroidQueenBattle_wave_section2 ; $6160
    dw $00F0, .loop
;}

; $60FD
song_metroidQueenBattle_noise:
;{
    dw song_metroidQueenBattle_noise_section0 ; $61BA
    dw song_metroidQueenBattle_noise_section1 ; $61C3
    .loop
    dw song_metroidQueenBattle_noise_section2 ; $61CC
    dw $00F0, .loop
;}

; $6107
song_metroidQueenBattle_toneSweep_section0:
;{
    SongOptions
        DescendingEnvelopeOptions 7, $C
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
    SongEnd
;}

; $610C
song_metroidQueenBattle_toneSweep_section1E:
song_metroidQueenBattle_toneSweep_section24:
song_metroidQueenBattle_toneSweep_section1B:
song_metroidQueenBattle_toneSweep_section21:
;{
    SongNoteLength_Crochet
    SongNote "E3"
    SongNote "Bb3"
    SongNote "C3"
    SongNote "G3"
    SongEnd
;}

; $6112
song_metroidQueenBattle_toneSweep_sectionF:
song_metroidQueenBattle_toneSweep_section15:
song_metroidQueenBattle_toneSweep_section5:
song_metroidQueenBattle_toneSweep_section18:
song_metroidQueenBattle_toneSweep_section1:
song_metroidQueenBattle_toneSweep_section7:
song_metroidQueenBattle_toneSweep_section3:
song_metroidQueenBattle_toneSweep_section9:
song_metroidQueenBattle_toneSweep_sectionC:
song_metroidQueenBattle_toneSweep_section12:
;{
    SongNoteLength_DottedCrochet
    SongNote "E3"
    SongNote "Bb3"
    SongNote "C3"
    SongNote "G3"
    SongEnd
;}

; $6118
song_metroidQueenBattle_toneSweep_section27:
;{
    SongOptions
        DescendingEnvelopeOptions 7, $8
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
    SongNoteLength_Minum
    SongNote "E3"
    SongNote "Bb3"
    SongNote "C3"
    SongNote "G3"
    SongEnd
;}

; $6122
song_metroidQueenBattle_tone_section0:
;{
    SongOptions
        DescendingEnvelopeOptions 7, $C
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
    SongRepeatSetup $A
        SongNoteLength_DottedCrochet
        SongNote "A3"
        SongNote "Eb4"
        SongNote "F3"
        SongNote "C4"
    SongRepeat
    SongEnd
;}

; $612F
song_metroidQueenBattle_tone_section1:
;{
    SongOptions
        DescendingEnvelopeOptions 7, $A
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
    SongRepeatSetup $4
        SongNoteLength_Crochet
        SongNote "A3"
        SongNote "Eb4"
        SongNote "F3"
        SongNote "C4"
    SongRepeat
    SongEnd
;}

; $613C
song_metroidQueenBattle_tone_section2:
;{
    SongOptions
        DescendingEnvelopeOptions 7, $8
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
    SongNoteLength_Minum
    SongNote "A3"
    SongNote "Eb4"
    SongNote "F3"
    SongNote "C4"
    SongEnd
;}

; $6146
song_metroidQueenBattle_wave_section0:
;{
    SongOptions
        WaveOptions $416B, 2, $0
    SongRepeatSetup $A
        SongNoteLength_DottedCrochet
        SongNote "A2"
        SongNote "Eb3"
        SongNote "F2"
        SongNote "C3"
    SongRepeat
    SongEnd
;}

; $6153
song_metroidQueenBattle_wave_section1:
;{
    SongOptions
        WaveOptions $416B, 2, $0
    SongRepeatSetup $4
        SongNoteLength_Crochet
        SongNote "A3"
        SongNote "Eb4"
        SongNote "F3"
        SongNote "C4"
    SongRepeat
    SongEnd
;}

; $6160
song_metroidQueenBattle_wave_section2:
;{
    SongNoteLength_Crochet
    SongNote "C5"
    Echo1
    SongNote "Eb5"
    Echo1
    SongNote "C5"
    Echo1
    SongNote "B4"
    Echo1
    SongNote "Gb4"
    Echo1
    SongNote "G4"
    SongNoteLength_Semiquaver
    SongNote "E5"
    Echo1
    SongNote "Eb5"
    Echo1
    SongNote "Db5"
    Echo1
    SongNote "C5"
    Echo1
    SongNote "Db5"
    Echo1
    SongNote "Eb5"
    Echo1
    SongNote "E5"
    Echo1
    SongNote "Eb5"
    Echo1
    SongNote "Db5"
    Echo1
    SongNote "C5"
    Echo1
    SongNote "Db5"
    Echo1
    SongNote "Eb5"
    Echo1
    SongNoteLength_Quaver
    SongNote "E5"
    Echo1
    SongNote "Ab4"
    Echo1
    SongNote "C5"
    Echo1
    SongNoteLength_DottedQuaver
    SongNote "B4"
    Echo1
    SongNote "F4"
    Echo1
    SongNoteLength_Quaver
    SongNote "Gb4"
    Echo1
    SongNote "C5"
    Echo1
    SongNote "B4"
    Echo1
    SongNoteLength_DottedCrochet
    SongNote "F5"
    SongNoteLength_Crochet
    Echo1
    SongNoteLength_Demisemiquaver
    SongNote "C2"
    SongNote "Db2"
    SongNote "Eb2"
    SongNote "E2"
    SongNote "G2"
    SongNote "Ab2"
    SongNote "Bb2"
    SongNote "B2"
    SongNote "C3"
    SongNote "Db3"
    SongNote "Eb3"
    SongNote "E3"
    SongNote "G3"
    SongNote "Ab3"
    SongNote "Bb3"
    SongNote "B3"
    SongNote "B3"
    SongNote "Bb3"
    SongNote "Ab3"
    SongNote "G3"
    SongNote "E3"
    SongNote "Eb3"
    SongNote "Db3"
    SongNote "C3"
    SongNote "G2"
    SongNote "E2"
    SongNote "B2"
    SongNote "Bb2"
    SongEnd
;}

; $61BA
song_metroidQueenBattle_noise_section0:
;{
    SongRepeatSetup $A
        SongNoteLength_DottedCrochet
        SongNoteLength_Demisemiquaver
        SongRest
        SongNoteLength_Minum
        SongRest
    SongRepeat
    SongEnd
;}

; $61C3
song_metroidQueenBattle_noise_section1:
;{
    SongRepeatSetup $4
        SongNoteLength_Crochet
        SongNoiseNote $9
        SongRest
        SongNoiseNote $D
        SongRest
    SongRepeat
    SongEnd
;}

; $61CC
song_metroidQueenBattle_noise_section2:
;{
    SongNoteLength_Quaver
    SongNoiseNote $7
    SongNoteLength_Minum
    SongNoteLength_Demisemiquaver
    SongNoteLength_DottedQuaver
    SongRest
    SongNoiseNote $1A
    SongEnd
;}

; $61D4
song_chozoRuins_header:
song_chozoRuins_clone_header:
    SongHeader $1, $40DF, song_chozoRuins_toneSweep, song_chozoRuins_tone, song_chozoRuins_wave, $0000

; $61DF
song_chozoRuins_clone_toneSweep:
song_chozoRuins_toneSweep:
;{
    .loop
    dw song_chozoRuins_toneSweep_section0 ; $6219
    dw song_chozoRuins_toneSweep_section1 ; $624C
    dw song_chozoRuins_toneSweep_section2 ; $6264
    dw song_chozoRuins_toneSweep_section3 ; $6297
    dw song_chozoRuins_toneSweep_section4 ; $6219
    dw song_chozoRuins_toneSweep_section5 ; $629D
    dw song_chozoRuins_toneSweep_section6 ; $624C
    dw song_chozoRuins_toneSweep_section7 ; $6264
    dw song_chozoRuins_toneSweep_section8 ; $62A3
    dw $00F0, .loop
;}

; $61F5
song_chozoRuins_clone_tone:
song_chozoRuins_tone:
;{
    .loop
    dw song_chozoRuins_tone_section0 ; $62F6
    dw song_chozoRuins_tone_section1 ; $6328
    dw song_chozoRuins_tone_section2 ; $6349
    dw song_chozoRuins_tone_section3 ; $62F6
    dw song_chozoRuins_tone_section4 ; $6328
    dw song_chozoRuins_tone_section5 ; $6349
    dw song_chozoRuins_tone_section6 ; $637A
    dw $00F0, .loop
;}

; $6207
song_chozoRuins_clone_wave:
song_chozoRuins_wave:
;{
    .loop
    dw song_chozoRuins_wave_section0 ; $63DF
    dw song_chozoRuins_wave_section1 ; $6412
    dw song_chozoRuins_wave_section2 ; $6435
    dw song_chozoRuins_wave_section3 ; $63DF
    dw song_chozoRuins_wave_section4 ; $6412
    dw song_chozoRuins_wave_section5 ; $6435
    dw song_chozoRuins_wave_section6 ; $6467
    dw $00F0, .loop
;}

; $6219
song_chozoRuins_toneSweep_section4:
song_chozoRuins_toneSweep_section0:
;{
    SongOptions
        DescendingEnvelopeOptions 0, $5
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 2
    SongNoteLength_Crochet
    SongRest
    SongNoteLength_Quaver
    SongNote "C4"
    Echo2
    SongNote "B3"
    Echo2
    SongNote "Bb3"
    Echo2
    SongNoteLength_Crochet
    SongNote "Gb3"
    Echo2
    SongNote "G3"
    Echo2
    SongNoteLength_Quaver
    SongNote "G3"
    Echo2
    SongNote "Gb3"
    Echo2
    SongNote "Eb3"
    Echo2
    SongNoteLength_Semiquaver
    SongNote "B3"
    Echo2
    SongNote "C4"
    Echo2
    SongNote "B4"
    Echo2
    SongNote "C5"
    Echo2
    SongNote "B2"
    Echo2
    SongNote "C3"
    Echo2
    SongNoteLength_Crochet
    SongNote "B3"
    Echo2
    SongNoteLength_Semiquaver
    SongNote "C4"
    Echo2
    SongNote "Eb4"
    Echo2
    SongNote "E4"
    Echo2
    SongRest
    SongRest
    SongEnd
;}

; $624C
song_chozoRuins_toneSweep_section6:
song_chozoRuins_toneSweep_section1:
;{
    SongNoteLength_Quaver
    SongNote "Eb3"
    Echo2
    SongNote "Gb3"
    Echo2
    SongNoteLength_DottedCrochet
    SongNote "A3"
    SongNote "Gb3"
    SongNoteLength_Crochet
    SongNote "C3"
    SongNoteLength_Quaver
    SongNote "Db3"
    SongRest
    SongRepeatSetup $2
        SongNoteLength_Semiquaver
        SongNote "B2"
        SongNote "C3"
        SongNote "B2"
        SongNote "C3"
    SongRepeat
    SongNoteLength_Minum
    SongRest
    SongEnd
;}

; $6264
song_chozoRuins_toneSweep_section7:
song_chozoRuins_toneSweep_section2:
;{
    SongNoteLength_Crochet
    SongNote "E4"
    Echo1
    SongNoteLength_Semiquaver
    SongNote "C4"
    Echo1
    SongNote "Db4"
    Echo1
    SongNoteLength_Quaver
    SongNote "A3"
    Echo1
    SongNote "E4"
    Echo1
    SongNoteLength_Semiquaver
    SongNote "C4"
    Echo1
    SongNote "B4"
    Echo1
    SongNoteLength_Quaver
    SongNote "F3"
    Echo1
    SongNote "B3"
    Echo1
    SongNoteLength_Semiquaver
    SongNote "G3"
    Echo1
    SongNote "Bb3"
    Echo1
    SongNote "B3"
    Echo1
    SongNote "Gb3"
    Echo1
    SongNoteLength_Quaver
    SongNote "F3"
    Echo1
    SongNote "A3"
    Echo1
    SongNote "G3"
    Echo1
    SongNoteLength_DottedQuaver
    SongNote "Gb3"
    Echo1
    SongNoteLength_Crochet
    SongNote "E3"
    Echo1
    SongNoteLength_DottedCrochet
    SongNote "D3"
    Echo2
    SongNoteLength_Semibreve
    SongRest
    SongEnd
;}

; $6297
song_chozoRuins_toneSweep_section3:
;{
    SongTranspose $FE
    SongTempo $40EC
    SongEnd
;}

; $629D
song_chozoRuins_toneSweep_section5:
;{
    SongTranspose $0
    SongTempo $40DF
    SongEnd
;}

; $62A3
song_chozoRuins_toneSweep_section8:
;{
    SongOptions
        DescendingEnvelopeOptions 2, $6
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 1
    SongRepeatSetup $2
        SongNoteLength_Semiquaver
        SongNote "F2"
        SongNote "Bb2"
        SongNote "F2"
        SongNote "Bb2"
        SongNote "G2"
        SongNote "B2"
        SongNote "G2"
        SongNote "B2"
        SongNote "F2"
        SongNote "A2"
        SongNote "F2"
        SongNote "A2"
        SongNote "G2"
        SongNote "Eb2"
        SongNote "G2"
        SongNote "Eb2"
        SongNote "G2"
        SongNote "Eb2"
        SongNote "F2"
        SongNote "Db2"
        SongNote "F2"
        SongNote "Db2"
        SongNote "F2"
        SongNote "Db2"
    SongRepeat
    SongOptions
        DescendingEnvelopeOptions 2, $6
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
    SongNoteLength_Semiquaver
    SongNote "F4"
    SongNote "Bb4"
    SongNote "F4"
    SongNote "Bb4"
    SongNote "G4"
    SongNote "B4"
    SongNote "G4"
    SongNote "B4"
    SongNote "F4"
    SongNote "A4"
    SongNote "F4"
    SongNote "A4"
    SongNote "G4"
    SongNote "Eb4"
    SongNote "G4"
    SongNote "Eb4"
    SongNote "G4"
    SongNote "Eb4"
    SongNote "F4"
    SongNote "Db4"
    SongNote "F4"
    SongNote "Db4"
    SongNote "F4"
    SongNote "Db4"
    SongNote "E4"
    SongNote "Bb3"
    SongNote "D4"
    SongNote "Ab3"
    SongNote "B3"
    SongNote "F3"
    SongNote "A3"
    SongNote "Eb3"
    SongNote "C3"
    SongNote "B2"
    SongNote "Ab2"
    SongNote "C2"
    SongOptions
        DescendingEnvelopeOptions 7, $8
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 1
    SongNoteLength_Semibreve
    SongNote "C6"
    SongRest
    SongNoteLength_Crochet
    SongRest
    SongEnd
;}

; $62F6
song_chozoRuins_tone_section0:
song_chozoRuins_tone_section3:
;{
    SongOptions
        DescendingEnvelopeOptions 0, $5
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 2
    SongNoteLength_Quaver
    SongNote "B3"
    SongNote "C4"
    SongNote "G4"
    Echo2
    SongNote "Eb4"
    Echo2
    SongNote "E4"
    Echo2
    SongNoteLength_Crochet
    SongNote "B3"
    Echo2
    SongNote "C4"
    Echo2
    SongNoteLength_Quaver
    SongNote "G3"
    Echo2
    SongNote "Gb3"
    Echo2
    SongNote "Eb3"
    Echo2
    SongNoteLength_Semiquaver
    SongNote "B3"
    Echo2
    SongNote "C4"
    Echo2
    SongNote "B4"
    Echo2
    SongNote "C5"
    Echo2
    SongNote "B2"
    Echo2
    SongNote "C3"
    Echo2
    SongNoteLength_Crochet
    SongNote "B3"
    Echo2
    SongNoteLength_Semiquaver
    SongNote "C4"
    Echo2
    SongNote "Eb4"
    Echo2
    SongNote "E4"
    SongNoteLength_DottedQuaver
    Echo2
    SongEnd
;}

; $6328
song_chozoRuins_tone_section1:
song_chozoRuins_tone_section4:
;{
    SongNoteLength_Quaver
    SongNote "C4"
    Echo2
    SongNote "D4"
    Echo2
    SongNoteLength_Semiquaver
    SongNote "F4"
    Echo2
    SongNote "E4"
    Echo2
    SongNote "C4"
    Echo2
    SongNoteLength_Quaver
    SongNote "D4"
    Echo2
    SongRest
    SongNote "Gb3"
    Echo2
    SongNote "G3"
    Echo2
    SongRest
    SongNoteLength_Semiquaver
    SongNote "Gb3"
    Echo2
    SongNote "Eb3"
    Echo2
    SongNote "E3"
    Echo1
    SongNoteLength_Quaver
    SongNote "C3"
    SongNoteLength_DottedCrochet
    Echo2
    SongEnd
;}

; $6349
song_chozoRuins_tone_section5:
song_chozoRuins_tone_section2:
;{
    SongNoteLength_Quaver
    SongNote "G4"
    SongNoteLength_DottedCrochet
    Echo2
    SongNoteLength_Semiquaver
    SongNote "Eb4"
    Echo2
    SongNote "E4"
    Echo2
    SongNoteLength_Quaver
    SongNote "C4"
    Echo2
    SongNoteLength_Quaver
    SongNote "G4"
    Echo2
    SongNoteLength_Semiquaver
    SongNote "Eb4"
    Echo2
    SongNote "E4"
    Echo2
    SongNoteLength_Quaver
    SongNote "C4"
    Echo2
    SongNote "G3"
    Echo2
    SongNoteLength_Quaver
    SongNote "Bb3"
    Echo2
    SongNoteLength_Minum
    SongRest
    SongNoteLength_Quaver
    SongNote "A3"
    Echo2
    SongNote "G3"
    Echo2
    SongNoteLength_Quaver
    SongNote "Bb3"
    SongNoteLength_Crochet
    Echo2
    SongNoteLength_Quaver
    SongNote "Ab3"
    SongNoteLength_DottedCrochet
    Echo2
    SongNoteLength_DottedCrochet
    SongNote "A3"
    Echo2
    SongNoteLength_Semibreve
    SongRest
    SongEnd
;}

; $637A
song_chozoRuins_tone_section6:
;{
    SongOptions
        DescendingEnvelopeOptions 2, $6
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 2
    SongNoteLength_Semiquaver
    SongNote "F2"
    SongNote "Bb2"
    SongNote "F2"
    SongNote "Bb2"
    SongNote "G2"
    SongNote "B2"
    SongNote "G2"
    SongNote "B2"
    SongNote "F2"
    SongNote "A2"
    SongNote "F2"
    SongNote "A2"
    SongNote "G2"
    SongNote "Eb2"
    SongNote "G2"
    SongNote "Eb2"
    SongNote "G2"
    SongNote "Eb2"
    SongNote "F2"
    SongNote "Db2"
    SongNote "F2"
    SongNote "Db2"
    SongNote "F2"
    SongNote "Db2"
    SongNoteLength_Semiquaver
    SongNote "A3"
    SongNote "C4"
    SongNote "A3"
    SongNote "C4"
    SongNote "B3"
    SongNote "Eb4"
    SongNote "B3"
    SongNote "Eb4"
    SongNote "A3"
    SongNote "Db4"
    SongNote "A3"
    SongNote "Db4"
    SongNote "B3"
    SongNote "A3"
    SongNote "B3"
    SongNote "A3"
    SongNote "C3"
    SongNote "F4"
    SongNote "G4"
    SongNote "Bb4"
    SongNote "C5"
    SongNote "D5"
    SongNote "F5"
    SongNote "G5"
    SongNoteLength_Semiquaver
    SongNote "A3"
    SongNote "C4"
    SongNote "A3"
    SongNote "C4"
    SongNote "B3"
    SongNote "Eb4"
    SongNote "B3"
    SongNote "Eb4"
    SongNote "A3"
    SongNote "Db4"
    SongNote "A3"
    SongNote "Db4"
    SongNote "B3"
    SongNote "A3"
    SongNote "B3"
    SongNote "A3"
    SongNote "Db4"
    SongNote "C4"
    SongNote "F4"
    SongNote "Bb4"
    SongNote "G4"
    SongNote "C4"
    SongNote "Ab3"
    SongNote "D3"
    SongNote "Db3"
    SongNote "C3"
    SongNote "B2"
    SongNote "Bb2"
    SongNote "A2"
    SongNote "Ab2"
    SongNote "G2"
    SongNote "Gb2"
    SongNote "F2"
    SongNote "E2"
    SongNote "Eb2"
    SongNote "E2"
    SongOptions
        DescendingEnvelopeOptions 7, $8
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 1
    SongNoteLength_Semibreve
    SongNote "C6"
    SongRest
    SongNoteLength_Crochet
    SongRest
    SongEnd
;}

; $63DF
song_chozoRuins_wave_section3:
song_chozoRuins_wave_section0:
;{
    SongOptions
        WaveOptions $417B, 2, $0
    SongNoteLength_Crochet
    SongRest
    SongNoteLength_Quaver
    SongNote "C4"
    Echo1
    SongNote "B3"
    Echo1
    SongNote "Bb3"
    Echo1
    SongNoteLength_Crochet
    SongNote "Gb3"
    Echo1
    SongNote "G3"
    Echo1
    SongNoteLength_Quaver
    SongNote "G3"
    Echo1
    SongNote "Gb3"
    Echo1
    SongNote "Eb3"
    Echo1
    SongNoteLength_Semiquaver
    SongNote "B3"
    Echo1
    SongNote "C4"
    Echo1
    SongNote "B4"
    Echo1
    SongNote "C5"
    Echo1
    SongNote "B2"
    Echo1
    SongNote "C3"
    Echo1
    SongNoteLength_Crochet
    SongNote "B3"
    Echo1
    SongNoteLength_Semiquaver
    SongNote "C4"
    Echo1
    SongNote "Eb4"
    Echo1
    SongNote "E4"
    Echo1
    SongRest
    SongRest
    SongEnd
;}

; $6412
song_chozoRuins_wave_section4:
song_chozoRuins_wave_section1:
;{
    SongNoteLength_Quaver
    SongNote "C4"
    Echo1
    SongNote "D4"
    Echo1
    SongNoteLength_Semiquaver
    SongNote "F4"
    Echo1
    SongNote "E4"
    Echo1
    SongNote "C4"
    Echo1
    SongNoteLength_Crochet
    SongNote "D4"
    SongNoteLength_Quaver
    Echo1
    SongNote "Gb3"
    Echo1
    SongNoteLength_Crochet
    SongNote "G3"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongNote "Gb3"
    Echo1
    SongNote "Eb3"
    Echo1
    SongNote "E3"
    Echo1
    SongNoteLength_Quaver
    SongNote "C3"
    Echo1
    SongNoteLength_Crochet
    SongRest
    SongEnd
;}

; $6435
song_chozoRuins_wave_section2:
song_chozoRuins_wave_section5:
;{
    SongNoteLength_Crochet
    SongNote "G4"
    SongNoteLength_Quaver
    Echo1
    SongRest
    SongNoteLength_Semiquaver
    SongNote "Eb4"
    Echo1
    SongNote "E4"
    Echo1
    SongNoteLength_Quaver
    SongNote "C4"
    SongNoteLength_Semiquaver
    Echo1
    SongRest
    SongNoteLength_Quaver
    SongNote "G4"
    Echo1
    SongNoteLength_Semiquaver
    SongNote "Eb4"
    Echo1
    SongNote "E4"
    Echo1
    SongNoteLength_Quaver
    SongNote "C4"
    Echo1
    SongNote "G3"
    Echo1
    SongNoteLength_DottedCrochet
    SongNote "Bb3"
    Echo1
    SongNoteLength_Quaver
    SongNote "A3"
    Echo1
    SongNote "G3"
    Echo1
    SongNoteLength_DottedQuaver
    SongNote "Bb3"
    Echo1
    SongNoteLength_Crochet
    SongNote "Ab3"
    Echo1
    SongNoteLength_Crochet
    SongNote "A3"
    Echo1
    SongNoteLength_Semibreve
    SongRest
    SongNoteLength_Crochet
    SongRest
    SongEnd
;}

; $6467
song_chozoRuins_wave_section6:
;{
    SongNoteLength_DottedMinum
    SongRest
    SongRest
    SongNoteLength_Demisemiquaver
    SongNote "A3"
    Echo1
    SongNote "C4"
    Echo1
    SongNote "A3"
    Echo1
    SongNote "C4"
    Echo1
    SongNote "B3"
    Echo1
    SongNote "Eb4"
    Echo1
    SongNote "B3"
    Echo1
    SongNote "Eb4"
    Echo1
    SongNote "A3"
    Echo1
    SongNote "Db4"
    Echo1
    SongNote "A3"
    Echo1
    SongNote "Db4"
    Echo1
    SongNote "B3"
    Echo1
    SongNote "A3"
    Echo1
    SongNote "B3"
    Echo1
    SongNote "A3"
    Echo1
    SongNote "C3"
    Echo1
    SongNote "F4"
    Echo1
    SongNote "G4"
    Echo1
    SongNote "Bb4"
    Echo1
    SongNote "C5"
    Echo1
    SongNote "D5"
    Echo1
    SongNote "F5"
    Echo1
    SongNote "G5"
    Echo1
    SongNoteLength_Demisemiquaver
    SongNote "A3"
    Echo1
    SongNote "C4"
    Echo1
    SongNote "A3"
    Echo1
    SongNote "C4"
    Echo1
    SongNote "B3"
    Echo1
    SongNote "Eb4"
    Echo1
    SongNote "B3"
    Echo1
    SongNote "Eb4"
    Echo1
    SongNote "A3"
    Echo1
    SongNote "Db4"
    Echo1
    SongNote "A3"
    Echo1
    SongNote "Db4"
    Echo1
    SongNote "B3"
    Echo1
    SongNote "A3"
    Echo1
    SongNote "B3"
    Echo1
    SongNote "A3"
    Echo1
    SongNote "Db4"
    Echo1
    SongNote "C4"
    Echo1
    SongNote "F4"
    Echo1
    SongNote "Bb4"
    Echo1
    SongNote "G4"
    Echo1
    SongNote "C4"
    Echo1
    SongNote "Ab3"
    Echo1
    SongNote "D3"
    Echo1
    SongNote "Db3"
    Echo1
    SongNote "C3"
    Echo1
    SongNote "B2"
    Echo1
    SongNote "Bb2"
    Echo1
    SongNote "A2"
    Echo1
    SongNote "Ab2"
    Echo1
    SongNote "G2"
    Echo1
    SongNote "Gb2"
    Echo1
    SongNote "F2"
    Echo1
    SongNote "E2"
    Echo1
    SongNote "Eb2"
    Echo1
    SongNote "E2"
    Echo1
    SongNoteLength_DottedQuaver
    SongNote "C6"
    Echo1
    SongNoteLength_DottedCrochet
    SongRest
    SongNoteLength_DottedMinum
    SongRest
    SongRest
    SongEnd
;}

; $64ED
song_mainCaves_header:
    SongHeader $0, $40C5, song_mainCaves_toneSweep, song_mainCaves_tone, song_mainCaves_wave, song_mainCaves_noise

; $64F8
song_mainCaves_toneSweep:
;{
    dw song_mainCaves_toneSweep_section0 ; $6542
    .alternateEntry
    dw song_mainCaves_toneSweep_section1 ; $6672
    .loop
    dw song_mainCaves_toneSweep_section2 ; $659C
    dw song_mainCaves_toneSweep_section3 ; $659C
    dw song_mainCaves_toneSweep_section4 ; $65EB
    dw song_mainCaves_toneSweep_section5 ; $65EB
    dw song_mainCaves_toneSweep_section6 ; $65EB
    dw song_mainCaves_toneSweep_section7 ; $65EB
    dw song_mainCaves_toneSweep_section8 ; $6550
    dw song_mainCaves_toneSweep_section9 ; $659C
    dw song_mainCaves_toneSweep_sectionA ; $659C
    dw song_mainCaves_toneSweep_sectionB ; $6600
    dw song_mainCaves_toneSweep_sectionC ; $6600
    dw song_mainCaves_toneSweep_sectionD ; $6600
    dw song_mainCaves_toneSweep_sectionE ; $6600
    dw song_mainCaves_toneSweep_sectionF ; $6550
    dw $00F0, .loop
;}

; $651C
song_mainCaves_tone:
;{
    dw song_mainCaves_tone_section0 ; $6615
    .alternateEntry
    dw song_mainCaves_tone_section1 ; $6623
    .loop
    dw song_mainCaves_tone_section2 ; $6631
    dw song_mainCaves_tone_section3 ; $6672
    dw $00F0, .loop
;}

; $6528
song_mainCaves_wave:
;{
    dw song_mainCaves_wave_section0 ; $669E
    .loop
    .alternateEntry
    dw song_mainCaves_wave_section1 ; $66AC
    dw song_mainCaves_wave_section2 ; $66DB
    dw song_mainCaves_wave_section3 ; $676A
    dw $00F0, .loop
;}

; $6534
song_mainCaves_noise:
;{
    dw song_mainCaves_noise_section0 ; $67C3
    .loop
    .alternateEntry
    dw song_mainCaves_noise_section1 ; $67C9
    dw song_mainCaves_noise_section2 ; $67ED
    dw song_mainCaves_noise_section3 ; $6803
    dw song_mainCaves_noise_section4 ; $6828
    dw $00F0, .loop
;}

; $6542
song_mainCaves_toneSweep_section0:
;{
    SongOptions
        DescendingEnvelopeOptions 5, $5
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 1
    SongNoteLength_Semiquaver
    SongNote "C3"
    SongNote "F3"
    SongNote "A4"
    SongNote "Bb4"
    SongNote "C5"
    SongNote "Eb5"
    SongNote "F6"
    SongNote "A6"
    SongEnd
;}

; $6550
song_mainCaves_toneSweep_section8:
song_mainCaves_toneSweep_sectionF:
;{
    SongOptions
        DescendingEnvelopeOptions 6, $2
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 1
    SongNoteLength_Quaver
    SongNote "C5"
    SongNote "F5"
    SongNote "C5"
    SongNote "C5"
    SongNoteLength_Crochet
    SongNote "F5"
    SongNoteLength_Quaver
    SongNote "C5"
    SongNote "F5"
    SongNote "C5"
    SongNote "F5"
    SongNote "C5"
    SongNote "C5"
    SongNoteLength_Crochet
    SongNote "F5"
    SongNoteLength_Quaver
    SongNote "C5"
    SongNote "C5"
    SongNote "Bb4"
    SongNote "Eb5"
    SongNote "Bb4"
    SongNote "Bb4"
    SongNoteLength_Crochet
    SongNote "Eb5"
    SongNoteLength_Quaver
    SongNote "Bb4"
    SongNote "Eb5"
    SongNote "Bb4"
    SongNote "Eb5"
    SongNote "Bb4"
    SongNote "Bb4"
    SongNoteLength_Quaver
    SongNote "Eb5"
    SongNote "Bb4"
    SongNote "Eb5"
    SongNote "Eb5"
    SongNote "C5"
    SongNote "F5"
    SongNote "C5"
    SongNote "C5"
    SongNoteLength_Crochet
    SongNote "F5"
    SongNoteLength_Quaver
    SongNote "C5"
    SongNote "F5"
    SongNote "C5"
    SongNote "F5"
    SongNote "C5"
    SongNote "C5"
    SongNoteLength_Crochet
    SongNote "F5"
    SongNoteLength_Quaver
    SongNote "C5"
    SongNote "C5"
    SongNote "Bb4"
    SongNote "Eb5"
    SongNote "Bb4"
    SongNote "Bb4"
    SongNoteLength_Crochet
    SongNote "Bb4"
    SongNote "Bb2"
    SongNoteLength_Quaver
    SongNote "F3"
    SongNote "Bb3"
    SongNote "C4"
    SongNote "Eb4"
    SongNote "F3"
    SongNote "Bb3"
    SongNote "C4"
    SongNote "Eb4"
    SongEnd
;}

; $659C
song_mainCaves_toneSweep_section9:
song_mainCaves_toneSweep_section2:
song_mainCaves_toneSweep_section3:
song_mainCaves_toneSweep_sectionA:
;{
    SongOptions
        DescendingEnvelopeOptions 1, $7
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 1
    SongRepeatSetup $3
        SongNoteLength_Quaver
        SongNote "C3"
        SongNote "F3"
        SongNote "C3"
        SongNote "C3"
        SongNoteLength_Crochet
        SongNote "F3"
        SongNoteLength_Quaver
        SongNote "C3"
        SongNote "F3"
        SongNote "C3"
        SongNote "F3"
        SongNote "C3"
        SongNote "C3"
        SongNoteLength_Crochet
        SongNote "F3"
        SongNoteLength_Quaver
        SongNote "C3"
        SongNote "C3"
        SongNote "Bb2"
        SongNote "Eb3"
        SongNote "Bb2"
        SongNote "Bb2"
        SongNoteLength_Crochet
        SongNote "Eb3"
        SongNoteLength_Quaver
        SongNote "Bb2"
        SongNote "Eb3"
        SongNote "Bb2"
        SongNote "Eb3"
        SongNote "Bb2"
        SongNote "Bb2"
        SongNote "Eb3"
        SongNote "Bb2"
        SongNote "Eb3"
        SongNote "Eb3"
    SongRepeat
    SongNoteLength_Quaver
    SongNote "C3"
    SongNote "F3"
    SongNote "C3"
    SongNote "C3"
    SongNoteLength_Crochet
    SongNote "F3"
    SongNoteLength_Quaver
    SongNote "C3"
    SongNote "F3"
    SongNote "C3"
    SongNote "F3"
    SongNote "C3"
    SongNote "C3"
    SongNoteLength_Crochet
    SongNote "F3"
    SongNoteLength_Quaver
    SongNote "F3"
    SongNote "C3"
    SongNote "Bb2"
    SongNote "Eb3"
    SongNote "Bb2"
    SongNote "Bb2"
    SongNoteLength_Crochet
    SongNote "Bb2"
    SongNote "Bb2"
    SongNoteLength_Quaver
    SongNote "F3"
    SongNote "Bb3"
    SongNote "C4"
    SongNote "Eb4"
    SongNote "F3"
    SongNote "Bb3"
    SongNote "C4"
    SongNote "Eb4"
    SongEnd
;}

; $65EB
song_mainCaves_toneSweep_section5:
song_mainCaves_toneSweep_section6:
song_mainCaves_toneSweep_section7:
song_mainCaves_toneSweep_section4:
;{
    SongOptions
        DescendingEnvelopeOptions 3, $6
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 1
    SongRepeatSetup $4
        SongNoteLength_Quaver
        SongNote "C3"
        SongNote "F3"
        SongNote "A3"
        SongNote "Bb3"
    SongRepeat
    SongRepeatSetup $4
        SongNoteLength_Quaver
        SongNote "Bb2"
        SongNote "Eb3"
        SongNote "F3"
        SongNote "Bb3"
    SongRepeat
    SongEnd
;}

; $6600
song_mainCaves_toneSweep_sectionB:
song_mainCaves_toneSweep_sectionC:
song_mainCaves_toneSweep_sectionD:
song_mainCaves_toneSweep_sectionE:
;{
    SongOptions
        AscendingEnvelopeOptions 2, $0
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
    SongRepeatSetup $4
        SongNoteLength_Quaver
        SongNote "C5"
        SongNote "F5"
        SongNote "A5"
        SongNote "Bb5"
    SongRepeat
    SongRepeatSetup $4
        SongNoteLength_Quaver
        SongNote "Bb4"
        SongNote "Eb5"
        SongNote "A5"
        SongNote "Bb5"
    SongRepeat
    SongEnd
;}

; $6615
song_mainCaves_tone_section0:
;{
    SongOptions
        DescendingEnvelopeOptions 5, $7
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 1
    SongNoteLength_Semiquaver
    SongNote "C3"
    SongNote "F3"
    SongNote "A3"
    SongNote "Bb3"
    SongNote "C4"
    SongNote "Eb4"
    SongNote "F4"
    SongNote "A4"
    SongEnd
;}

; $6623
song_mainCaves_tone_section1:
;{
    SongOptions
        AscendingEnvelopeOptions 7, $0
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
    SongNoteLength_Semibreve
    SongNote "F3"
    Echo1
    SongNote "Eb3"
    Echo1
    SongNote "F4"
    Echo1
    SongNote "Eb4"
    Echo1
    SongEnd
;}

; $6631
song_mainCaves_tone_section2:
;{
    SongOptions
        DescendingEnvelopeOptions 3, $7
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 1
    SongRepeatSetup $8
        SongNoteLength_Crochet
        SongNote "F2"
        Echo1
        SongNote "F2"
        Echo1
        SongNote "F2"
        Echo1
        SongNote "F2"
        Echo1
        SongNote "Eb2"
        Echo1
        SongNote "Eb2"
        Echo1
        SongNote "Eb2"
        Echo1
        SongNote "Eb2"
        Echo1
    SongRepeat
    SongOptions
        DescendingEnvelopeOptions 2, $2
        DescendingSweepOptions 4, 6
        LengthDutyOptions $0, 2
    SongRepeatSetup $8
        SongNoteLength_Semiquaver
        SongNote "C6"
        SongNote "B5"
        SongNote "D5"
        SongNote "G5"
        SongNote "E5"
        SongNote "A5"
        SongNote "B5"
        SongNote "F5"
        SongNote "A5"
        SongNote "A5"
        SongNote "B5"
        SongNote "B5"
        SongNote "C5"
        SongNote "C5"
        SongNote "A5"
        SongNote "A5"
        SongNote "E5"
        SongNote "E5"
        SongNote "A5"
        SongNote "A5"
        SongNote "F5"
        SongNote "F5"
        SongNote "A5"
        SongNote "A5"
        SongNote "E5"
        SongNote "E5"
        SongNote "C5"
        SongNote "C5"
        SongNote "A5"
        SongNote "A5"
        SongNote "E5"
        SongNote "E5"
    SongRepeat
    SongEnd
;}

; $6672
song_mainCaves_toneSweep_section1:
song_mainCaves_tone_section3:
;{
    SongOptions
        DescendingEnvelopeOptions 7, $4
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 1
    SongNoteLength_Minum
    SongNote "F3"
    SongNoteLength_DottedCrochet
    SongNote "C3"
    SongNote "C3"
    SongNoteLength_Crochet
    SongNote "C3"
    SongNote "F3"
    SongNote "C3"
    SongNoteLength_Minum
    SongNote "Eb3"
    SongNoteLength_DottedCrochet
    SongNote "Bb2"
    SongNote "Bb2"
    SongNoteLength_Crochet
    SongNote "Bb2"
    SongNote "Eb3"
    SongNote "Bb2"
    SongNoteLength_Minum
    SongNote "F3"
    SongNoteLength_DottedCrochet
    SongNote "C3"
    SongNote "C3"
    SongNoteLength_Crochet
    SongNote "C3"
    SongNote "F3"
    SongNote "C3"
    SongNoteLength_Minum
    SongNote "Eb3"
    SongNoteLength_DottedCrochet
    SongNote "Bb2"
    SongNoteLength_Quaver
    SongNote "Bb2"
    SongNote "F2"
    SongNote "Bb2"
    SongNote "C3"
    SongNote "Eb3"
    SongNoteLength_Minum
    SongNote "F2"
    SongEnd
;}

; $669E
song_mainCaves_wave_section0:
;{
    SongOptions
        WaveOptions $417B, 2, $0
    SongNoteLength_Semiquaver
    SongNote "C2"
    SongNote "F2"
    SongNote "A2"
    SongNote "Bb2"
    SongNote "C3"
    SongNote "Eb3"
    SongNote "F3"
    SongNote "A3"
    SongEnd
;}

; $66AC
song_mainCaves_wave_section1:
;{
    SongOptions
        WaveOptions $417B, 2, $0
    SongNoteLength_Crochet
    SongNote "C4"
    SongNoteLength_Quaver
    Echo1
    SongNote "C4"
    SongNoteLength_Crochet
    Echo1
    SongNoteLength_Semibreve
    SongRest
    SongNoteLength_Crochet
    SongRest
    SongNote "Bb3"
    SongNoteLength_Quaver
    Echo1
    SongNote "Bb3"
    SongNoteLength_Crochet
    Echo1
    SongNoteLength_Semibreve
    SongRest
    SongNoteLength_Crochet
    SongRest
    SongNote "C4"
    SongNoteLength_Quaver
    Echo1
    SongNote "C4"
    SongNoteLength_Crochet
    Echo1
    SongNoteLength_Semibreve
    SongRest
    SongNoteLength_Crochet
    SongRest
    SongNote "Bb3"
    SongNoteLength_Quaver
    Echo1
    SongNote "Bb3"
    SongNoteLength_Crochet
    Echo1
    SongNoteLength_DottedMinum
    SongRest
    SongNoteLength_Crochet
    SongNote "C3"
    Echo1
    SongEnd
;}

; $66DB
song_mainCaves_wave_section2:
;{
    SongOptions
        WaveOptions $417B, 2, $0
    SongNoteLength_DottedQuaver
    SongNote "C4"
    Echo1
    SongNote "F4"
    Echo1
    SongNoteLength_Crochet
    SongNote "G4"
    Echo1
    SongNote "Bb4"
    Echo1
    SongRest
    SongNoteLength_DottedQuaver
    SongNote "A4"
    Echo1
    SongNote "F4"
    Echo1
    SongNoteLength_Crochet
    SongNote "G4"
    Echo1
    SongNote "Eb4"
    Echo1
    SongRest
    SongNoteLength_DottedQuaver
    SongNote "C4"
    Echo1
    SongNote "F4"
    Echo1
    SongNoteLength_Crochet
    SongNote "G4"
    Echo1
    SongNote "Bb4"
    Echo1
    SongRest
    SongNoteLength_DottedQuaver
    SongNote "A4"
    Echo1
    SongNote "Bb4"
    Echo1
    SongNoteLength_DottedCrochet
    SongNote "C5"
    Echo1
    SongNoteLength_Crochet
    SongNote "G4"
    Echo1
    SongNoteLength_DottedQuaver
    SongNote "C4"
    Echo1
    SongNote "F4"
    Echo1
    SongNoteLength_Crochet
    SongNote "G4"
    Echo1
    SongNote "Bb4"
    Echo1
    SongRest
    SongNoteLength_DottedQuaver
    SongNote "A4"
    Echo1
    SongNote "F4"
    Echo1
    SongNoteLength_Crochet
    SongNote "G4"
    Echo1
    SongRest
    SongRest
    SongRest
    SongNoteLength_DottedQuaver
    SongNote "C4"
    Echo1
    SongNote "F4"
    Echo1
    SongNoteLength_Crochet
    SongNote "G4"
    Echo1
    SongNote "Bb4"
    Echo1
    SongRest
    SongNoteLength_DottedQuaver
    SongNote "A4"
    Echo1
    SongNote "Bb4"
    Echo1
    SongNoteLength_Crochet
    SongNote "C5"
    Echo1
    SongNote "Eb5"
    Echo1
    SongNoteLength_Quaver
    SongNote "D5"
    Echo1
    SongRepeatSetup $2
        SongNoteLength_DottedQuaver
        SongNote "C5"
        Echo1
        SongNote "Bb4"
        Echo1
        SongNoteLength_Crochet
        SongNote "A4"
        Echo1
        SongNoteLength_DottedCrochet
        SongNote "F4"
        Echo1
        SongNoteLength_DottedQuaver
        SongNote "Eb4"
        Echo1
        SongNote "G4"
        Echo1
        SongNoteLength_DottedCrochet
        SongNote "Bb4"
        Echo1
        SongNoteLength_Crochet
        SongNote "A4"
        Echo1
        SongNoteLength_DottedQuaver
        SongNote "C5"
        Echo1
        SongNote "Bb4"
        Echo1
        SongNoteLength_Crochet
        SongNote "A4"
        Echo1
        SongNote "F5"
        Echo1
        SongNoteLength_Quaver
        SongNote "Eb5"
        Echo1
        SongNoteLength_DottedQuaver
        SongNote "D5"
        Echo1
        SongNote "Bb4"
        Echo1
        SongNoteLength_DottedCrochet
        SongNote "C5"
        Echo1
        SongNoteLength_Minum
        SongRest
    SongRepeat
    SongEnd
;}

; $676A
song_mainCaves_wave_section3:
;{
    SongOptions
        WaveOptions $417B, 2, $0
    SongNoteLength_DottedCrochet
    SongNote "F3"
    Echo1
    SongNote "Bb3"
    Echo1
    SongNoteLength_Crochet
    SongNote "C4"
    Echo1
    SongNoteLength_DottedCrochet
    SongNote "Eb4"
    Echo1
    SongNote "D4"
    Echo1
    SongNoteLength_Crochet
    SongNote "Bb3"
    Echo1
    SongNoteLength_DottedCrochet
    SongNote "F3"
    Echo1
    SongNote "C4"
    Echo1
    SongNoteLength_Crochet
    SongNote "D4"
    Echo1
    SongNoteLength_DottedCrochet
    SongNote "Eb4"
    Echo1
    SongNote "F4"
    Echo1
    SongNoteLength_Crochet
    SongNote "G4"
    Echo1
    SongNoteLength_DottedCrochet
    SongNote "F3"
    Echo1
    SongNote "A3"
    Echo1
    SongNoteLength_Crochet
    SongNote "Bb3"
    Echo1
    SongNoteLength_DottedCrochet
    SongNote "C4"
    Echo1
    SongNote "D4"
    Echo1
    SongNoteLength_Crochet
    SongNote "Eb4"
    Echo1
    SongNote "F4"
    Echo1
    SongNote "A4"
    Echo1
    SongNoteLength_Quaver
    SongNote "Bb4"
    Echo1
    SongNoteLength_Crochet
    SongNote "C5"
    Echo1
    SongNote "Eb5"
    Echo1
    SongNoteLength_Quaver
    SongNote "F5"
    Echo1
    SongNote "A5"
    Echo1
    SongNote "Bb5"
    Echo1
    SongNoteLength_Semiquaver
    SongNote "C6"
    Echo1
    SongNote "Eb6"
    Echo1
    SongNote "F6"
    Echo1
    SongNote "Bb6"
    Echo1
    SongNote "C6"
    Echo1
    SongNote "Eb6"
    Echo1
    SongNote "F6"
    Echo1
    SongNote "A6"
    Echo1
    SongEnd
;}

; $67C3
song_mainCaves_noise_section0:
;{
    SongRepeatSetup $8
        SongNoteLength_Semiquaver
        SongNoiseNote $4
    SongRepeat
    SongEnd
;}

; $67C9
song_mainCaves_noise_section1:
;{
    SongRepeatSetup $3
        SongNoteLength_Quaver
        SongNoiseNote $24
        SongNoiseNote $3
        SongNoiseNote $1
        SongNoiseNote $25
        SongNoiseNote $1
        SongNoiseNote $1
        SongNoiseNote $3
        SongNoiseNote $1
        SongNoiseNote $1
        SongNoiseNote $1
        SongNoiseNote $3
        SongNoiseNote $1
        SongNoiseNote $24
        SongNoiseNote $3
        SongNoiseNote $1
        SongNoiseNote $3
    SongRepeat
    SongNoteLength_Quaver
    SongNoiseNote $24
    SongNoiseNote $1
    SongNoiseNote $3
    SongNoiseNote $24
    SongNoiseNote $1
    SongNoiseNote $1
    SongNoiseNote $3
    SongNoiseNote $1
    SongNoiseNote $5
    SongNoiseNote $4
    SongNoiseNote $5
    SongNoiseNote $4
    SongNoteLength_Minum
    SongNoiseNote $7
    SongEnd
;}

; $67ED
song_mainCaves_noise_section2:
;{
    SongRepeatSetup $F
        SongNoteLength_Quaver
        SongNoiseNote $24
        SongNoiseNote $1
        SongNoiseNote $3
        SongNoiseNote $1
        SongNoiseNote $24
        SongNoiseNote $1
        SongNoiseNote $3
        SongNoiseNote $1
    SongRepeat
    SongNoteLength_Quaver
    SongNoiseNote $5
    SongNoiseNote $4
    SongNoiseNote $4
    SongNoiseNote $4
    SongNoiseNote $5
    SongNoiseNote $4
    SongNoiseNote $5
    SongNoiseNote $4
    SongEnd
;}

; $6803
song_mainCaves_noise_section3:
;{
    SongRepeatSetup $7
        SongNoteLength_Quaver
        SongNoiseNote $24
        SongNoiseNote $3
        SongNoiseNote $1
        SongNoiseNote $25
        SongNoiseNote $5
        SongNoiseNote $1
        SongNoiseNote $3
        SongNoiseNote $1
        SongNoiseNote $24
        SongNoiseNote $3
        SongNoiseNote $1
        SongNoiseNote $3
        SongNoiseNote $25
        SongNoiseNote $3
        SongNoiseNote $1
        SongNoiseNote $1
    SongRepeat
    SongNoiseNote $24
    SongNoiseNote $3
    SongNoiseNote $2
    SongNoiseNote $25
    SongNoiseNote $24
    SongNoiseNote $3
    SongNoiseNote $2
    SongNoiseNote $1
    SongNoiseNote $5
    SongNoiseNote $4
    SongNoiseNote $4
    SongNoiseNote $4
    SongNoiseNote $5
    SongNoiseNote $4
    SongNoiseNote $5
    SongNoiseNote $4
    SongEnd
;}

; $6828
song_mainCaves_noise_section4:
;{
    SongRepeatSetup $4
        SongNoteLength_Quaver
        SongNoiseNote $5
        SongNoiseNote $3
        SongNoiseNote $5
        SongNoiseNote $1
        SongNoiseNote $2
        SongNoiseNote $3
        SongNoiseNote $2
        SongNoiseNote $1
        SongNoiseNote $1
        SongNoiseNote $3
        SongNoiseNote $2
        SongNoiseNote $1
        SongNoiseNote $2
        SongNoteLength_Crochet
        SongNoiseNote $1A
        SongNoteLength_Quaver
        SongNoiseNote $3
    SongRepeat
    SongRepeatSetup $3
        SongNoteLength_Quaver
        SongNoiseNote $4
        SongNoiseNote $4
        SongNoiseNote $1
        SongNoiseNote $4
        SongNoiseNote $5
        SongNoiseNote $3
        SongNoiseNote $2
        SongNoiseNote $1
        SongNoiseNote $24
        SongNoiseNote $3
        SongNoiseNote $2
        SongNoiseNote $1
        SongNoiseNote $24
        SongNoteLength_Crochet
        SongNoiseNote $1A
        SongNoteLength_Quaver
        SongNoiseNote $3
    SongRepeat
    SongNoiseNote $24
    SongNoiseNote $3
    SongNoiseNote $24
    SongNoiseNote $1
    SongNoiseNote $2
    SongNoiseNote $3
    SongNoiseNote $2
    SongNoiseNote $1
    SongRepeatSetup $8
        SongNoiseNote $5
    SongRepeat
    SongEnd
;}

; $685F
song_subCaves1_header:
    SongHeader $0, $40C5, song_subCaves1_toneSweep, song_subCaves1_tone, song_subCaves1_wave, song_subCaves1_noise

; $686A
song_subCaves1_toneSweep:
;{
    dw song_subCaves1_toneSweep_section0 ; $7DA0
    dw song_subCaves1_toneSweep_section1 ; $7D86
    .loop
    .alternateEntry
    dw song_subCaves1_toneSweep_section2 ; $6880
    dw $00F0, .loop
;}

; $6874
song_subCaves1_tone:
;{
    dw song_subCaves1_tone_section0 ; $7DCA
    dw $0000
;}

; $6878
song_subCaves1_wave:
;{
    dw song_subCaves1_wave_section0 ; $7DF4
    dw $0000
;}

; $687C
song_subCaves1_noise:
;{
    dw song_subCaves1_noise_section0 ; $7E04
    dw $0000
;}

; $6880
song_subCaves1_toneSweep_section2:
;{
    SongOptions
        DescendingEnvelopeOptions 7, $3
        AscendingSweepOptions 5, 3
        LengthDutyOptions $0, 2
    SongNoteLength_Semiquaver
    SongNote "G5"
    SongNoteLength_Semiquaver
    SongNote "Ab5"
    SongNote "A5"
    SongNote "Bb5"
    SongNote "B5"
    SongNote "C6"
    SongNote "Db6"
    SongNote "D6"
    SongNote "Eb6"
    SongNote "E6"
    SongNoteLength_TripletQuaver
    SongNote "F6"
    SongNote "Gb6"
    SongNote "G6"
    SongNote "Ab6"
    SongNote "A6"
    SongNote "Bb6"
    SongNote "B6"
    SongNoteLength_Semibreve
    SongNote "C7"
    SongNoteLength_Demisemiquaver
    SongNote "G5"
    SongNote "Ab5"
    SongNote "A5"
    SongNote "Bb5"
    SongNote "B5"
    SongNote "C6"
    SongNote "Db6"
    SongNote "D6"
    SongNote "Eb6"
    SongNote "E6"
    SongNoteLength_Semiquaver
    SongNote "F6"
    SongNote "Gb6"
    SongNote "G6"
    SongNoteLength_Minum
    SongNote "Ab6"
    SongNoteLength_Minum
    SongRest
    SongNoteLength_Demisemiquaver
    SongRest
    SongNoteLength_Demisemiquaver
    SongNote "Ab6"
    SongNote "A6"
    SongNote "Bb6"
    SongNote "B6"
    SongNote "C7"
    SongNote "Db7"
    SongNoteLength_Minum
    SongNote "D7"
    SongNoteLength_TripletQuaver
    SongNote "Db6"
    SongNote "E6"
    SongNote "Gb6"
    SongNote "A6"
    SongNoteLength_DottedMinum
    SongNote "C6"
    SongNoteLength_DottedQuaver
    SongRest
    SongNoteLength_TripletQuaver
    SongNote "C7"
    SongNote "Db7"
    SongNote "D7"
    SongNote "Eb7"
    SongNote "E7"
    SongNoteLength_Semibreve
    SongNote "F7"
    SongNoteLength_TripletCrochet
    SongRest
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Demisemiquaver
    SongNote "Ab6"
    SongNote "A6"
    SongNote "Bb6"
    SongNote "B6"
    SongNote "C7"
    SongNote "Db7"
    SongNoteLength_DottedMinum
    SongNote "D7"
    SongNoteLength_DottedQuaver
    SongNote "Ab5"
    SongNote "A5"
    SongNoteLength_Quaver
    SongNote "Bb5"
    SongNote "B5"
    SongNote "C6"
    SongNoteLength_Semiquaver
    SongNote "Db6"
    SongNote "D6"
    SongNoteLength_TripletQuaver
    SongNote "Eb6"
    SongNote "E6"
    SongNote "F6"
    SongNote "Ab6"
    SongNoteLength_Semiquaver
    SongNote "A6"
    SongNote "Bb6"
    SongNote "B6"
    SongNoteLength_Semibreve
    SongNote "C7"
    SongNoteLength_TripletCrochet
    SongRest
    SongEnd
;}

; $68EE
song_subCaves2_header:
    SongHeader $0, $40C5, song_subCaves2_toneSweep, song_subCaves2_tone, song_subCaves2_wave, song_subCaves2_noise

; $68F9
song_subCaves2_toneSweep:
;{
    dw song_subCaves2_toneSweep_section0 ; $7DA0
    dw song_subCaves2_toneSweep_section1 ; $7D8A
    dw $0000
;}

; $68FF
song_subCaves2_tone:
;{
    dw song_subCaves2_tone_section0 ; $7DCA
    .loop
    .alternateEntry
    dw song_subCaves2_tone_section1 ; $6911
    dw $00F0, .loop
;}

ds $2, $00
; $6909
song_subCaves2_wave:
;{
    dw song_subCaves2_wave_section0 ; $7DF4
    dw $0000
;}

; $690D
song_subCaves2_noise:
;{
    dw song_subCaves2_noise_section0 ; $7E04
    dw $0000
;}

; $6911
song_subCaves2_tone_section1:
;{
    SongOptions
        DescendingEnvelopeOptions 7, $4
        AscendingSweepOptions 0, 0
        LengthDutyOptions $7, 0
    SongNoteLength_DottedMinum
    SongRest
    SongRest
    SongNoteLength_Demisemiquaver
    SongNote "G6"
    SongNote "E6"
    SongNote "A6"
    SongNote "B6"
    SongNote "F6"
    SongNote "E6"
    SongNote "A6"
    SongNote "D6"
    SongNoteLength_Semiquaver
    SongNote "C7"
    SongNote "B6"
    SongNote "A6"
    SongNote "B6"
    SongNote "F6"
    SongNoteLength_Semibreve
    SongRest
    SongNoteLength_Semiquaver
    SongNote "C7"
    SongNote "B6"
    SongNote "D6"
    SongNote "G6"
    SongNote "E6"
    SongNote "A6"
    SongNote "B6"
    SongNote "F6"
    SongNoteLength_Semibreve
    SongRest
    SongNoteLength_DottedMinum
    SongRest
    SongNoteLength_Demisemiquaver
    SongNote "C7"
    SongNote "B6"
    SongNote "D6"
    SongNote "G6"
    SongNote "E6"
    SongNote "A6"
    SongNote "B6"
    SongNote "F6"
    SongNoteLength_Semibreve
    SongRest
    SongNoteLength_DottedCrochet
    SongRest
    SongNoteLength_Semiquaver
    SongNote "C7"
    SongNote "B6"
    SongNote "D6"
    SongNote "G6"
    SongNote "E6"
    SongNote "A6"
    SongNote "B6"
    SongNote "F6"
    SongNoteLength_Semibreve
    SongRest
    SongRest
    SongNoteLength_Crochet
    SongRest
    SongNoteLength_Semiquaver
    SongNote "B6"
    SongNote "D6"
    SongNote "C7"
    SongRest
    SongRest
    SongNote "B6"
    SongNote "D6"
    SongNote "G6"
    SongNote "E6"
    SongNote "A6"
    SongNote "G6"
    SongNoteLength_DottedQuaver
    SongRest
    SongNoteLength_Semiquaver
    SongNote "E6"
    SongNote "F6"
    SongNote "Gb6"
    SongNote "G6"
    SongNote "A6"
    SongNoteLength_Crochet
    SongRest
    SongNoteLength_Semiquaver
    SongNote "C7"
    SongNote "E6"
    SongNote "C6"
    SongNote "G5"
    SongNote "F6"
    SongNoteLength_DottedMinum
    SongRest
    SongRest
    SongRest
    SongRest
    SongNoteLength_Semiquaver
    SongNote "B6"
    SongNote "D6"
    SongNote "C7"
    SongNote "B6"
    SongNote "D6"
    SongNote "G6"
    SongNote "E6"
    SongNote "A6"
    SongNote "G6"
    SongNote "E6"
    SongNoteLength_DottedMinum
    SongRest
    SongRest
    SongNoteLength_Semiquaver
    SongNote "C6"
    SongNote "C7"
    SongNote "B6"
    SongNote "D6"
    SongNoteLength_Semibreve
    SongRest
    SongEnd
;}

; $6988
song_subCaves3_header:
    SongHeader $0, $40C5, song_subCaves3_toneSweep, song_subCaves3_tone, song_subCaves3_wave, song_subCaves3_noise

; $6993
song_subCaves3_toneSweep:
;{
    dw song_subCaves3_toneSweep_section0 ; $7DA0
    dw song_subCaves3_toneSweep_section1 ; $7D7E
    .loop
    .alternateEntry
    dw song_subCaves3_toneSweep_section2 ; $69B1
    dw $00F0, .loop
;}

; $699D
song_subCaves3_tone:
;{
    dw song_subCaves3_tone_section0 ; $7DCA
    .loop
    .alternateEntry
    dw song_subCaves3_tone_section1 ; $69E2
    dw $00F0, .loop
;}

; $69A5
song_subCaves3_wave:
;{
    dw song_subCaves3_wave_section0 ; $7DF4
    .loop
    .alternateEntry
    dw song_subCaves3_wave_section1 ; $6A92
    dw $00F0, .loop
;}

; $69AD
song_subCaves3_noise:
;{
    dw song_subCaves3_noise_section0 ; $7E04
    dw $0000
;}

; $69B1
song_subCaves3_toneSweep_section2:
;{
    SongOptions
        DescendingEnvelopeOptions 7, $5
        AscendingSweepOptions 5, 1
        LengthDutyOptions $0, 2
    SongRepeatSetup $A
        SongNoteLength_Semiquaver
        SongNote "C7"
        SongNote "B6"
        SongNote "D6"
        SongNote "G6"
        SongNote "E6"
        SongNote "A6"
        SongNote "B6"
        SongNote "F6"
    SongRepeat
    SongNoteLength_Semibreve
    SongRest
    SongRest
    SongRepeatSetup $2
        SongNoteLength_Semiquaver
        SongNote "C7"
        SongNote "B6"
        SongNote "D6"
        SongNote "G6"
        SongNote "E6"
        SongNote "A6"
        SongNote "B6"
        SongNote "F6"
    SongRepeat
    SongNoteLength_Semibreve
    SongRest
    SongRepeatSetup $16
        SongNoteLength_Semiquaver
        SongNote "D7"
        SongNote "B6"
        SongNote "F6"
        SongNote "Ab6"
        SongNote "E6"
        SongNote "Bb6"
        SongNote "B6"
        SongNote "C6"
    SongRepeat
    SongNoteLength_Breve
    SongRest
    SongRest
    SongEnd
;}

; $69E2
song_subCaves3_tone_section1:
;{
    SongOptions
        DescendingEnvelopeOptions 7, $3
        AscendingSweepOptions 0, 0
        LengthDutyOptions $7, 0
    SongNoteLength_Semibreve
    SongRest
    SongRest
    SongNoteLength_Semiquaver
    SongNote "Db2"
    SongNote "B2"
    SongNote "Db3"
    SongNote "B3"
    SongNote "Db4"
    SongNote "B4"
    SongNote "Db5"
    SongNote "B5"
    SongNote "Db6"
    SongNote "B6"
    SongNote "Db7"
    SongNote "B7"
    SongRepeatSetup $4
        SongNote "C6"
        SongNote "Db6"
        SongNote "C6"
        SongNote "Db6"
        SongNote "C6"
        SongNote "Db6"
        SongNote "C6"
        SongNote "Db6"
        SongNoteLength_Breve
        SongRest
        SongRest
        SongNoteLength_Semiquaver
        SongNote "Db2"
        SongNote "F2"
        SongNote "G2"
        SongNote "B2"
        SongNote "Db3"
        SongNote "F3"
        SongNote "G3"
        SongNote "B3"
        SongNote "Db4"
        SongNote "F4"
        SongNote "G4"
        SongNote "B4"
        SongNote "Db5"
        SongNote "F5"
        SongNote "G5"
        SongNote "B5"
        SongNote "Db6"
        SongNote "F6"
        SongNote "G6"
        SongNote "B6"
        SongNote "Db7"
        SongNote "F7"
        SongNote "G7"
        SongNote "B7"
        SongNote "C7"
        SongNote "Db7"
        SongNote "C6"
        SongNote "Db6"
        SongNote "C5"
        SongNote "Db5"
        SongNote "C4"
        SongNote "Db4"
        SongNote "C3"
        SongNote "Db3"
        SongNote "C2"
        SongNote "Db2"
        SongNoteLength_Breve
        SongRest
        SongRest
        SongRest
        SongNoteLength_Semiquaver
        SongNote "F7"
        SongNote "F7"
        SongNote "F2"
        SongNote "Gb2"
        SongNote "F6"
        SongNote "Gb6"
        SongNote "F3"
        SongNote "Gb3"
        SongNote "F5"
        SongNote "Gb5"
        SongNote "F4"
        SongNote "Gb4"
        SongNote "F4"
        SongNote "G7"
        SongNote "B7"
        SongNote "G2"
        SongNote "B2"
        SongNote "G6"
        SongNote "B6"
        SongNote "G3"
        SongNote "B3"
        SongNote "G5"
        SongNote "B5"
        SongNote "G4"
        SongNote "B4"
        SongNote "G4"
        SongNote "B4"
        SongNote "G4"
        SongNote "D7"
        SongNote "Db7"
        SongNote "D2"
        SongNote "Db2"
        SongNote "D6"
        SongNote "C6"
        SongNote "D3"
        SongNote "Db3"
        SongNote "D5"
        SongNote "Db5"
        SongNote "D4"
        SongNote "Db4"
        SongNote "D4"
        SongNote "Db4"
        SongNote "Db4"
        SongNote "D4"
        SongNote "Db4"
        SongNote "C7"
        SongNote "Db7"
        SongNote "G6"
        SongNote "C6"
        SongNote "Db6"
        SongNote "G5"
        SongNote "C5"
        SongNote "Db5"
        SongNote "G4"
        SongNote "C4"
        SongNote "Db4"
        SongNote "G3"
        SongNote "C3"
        SongNote "Db3"
        SongNote "G2"
        SongNote "C2"
        SongNote "Db2"
        SongNoteLength_Breve
        SongRest
        SongOptions
        DescendingEnvelopeOptions 7, $4
        AscendingSweepOptions 0, 0
        LengthDutyOptions $2, 2
        SongNoteLength_Demisemiquaver
        SongNote "G7"
        SongNote "F7"
        SongNote "C7"
        SongNote "B6"
        SongNote "G6"
        SongNote "F6"
        SongNote "C6"
        SongNote "B5"
        SongNote "G5"
        SongNote "F5"
        SongNote "C5"
        SongNote "B4"
        SongNote "G4"
        SongNote "F4"
        SongNote "C4"
        SongNote "B3"
        SongNote "G3"
        SongNote "F3"
        SongNote "C3"
        SongNote "B2"
        SongNote "G2"
        SongNote "F2"
        SongNote "C2"
        SongNoteLength_Semibreve
        SongNote "B6"
        SongRest
        SongRest
        SongNote "B6"
        SongNoteLength_Breve
        SongRest
        SongRest
        SongEnd
;}

; $6A92
song_subCaves3_wave_section1:
;{
    SongOptions
        WaveOptions $418B, 3, $3
    SongNoteLength_DottedMinum
    SongRepeatSetup $6
        SongNote "B3"
    SongRepeat
    SongRepeatSetup $6
        SongNote "C4"
    SongRepeat
    SongRepeatSetup $6
        SongNote "Db4"
    SongRepeat
    SongRepeatSetup $6
        SongNote "D4"
    SongRepeat
    SongRepeatSetup $6
        SongNote "Eb4"
    SongRepeat
    SongRepeatSetup $6
        SongNote "E4"
    SongRepeat
    SongRepeatSetup $6
        SongNote "F4"
    SongRepeat
    SongRepeatSetup $6
        SongNote "Gb4"
    SongRepeat
    SongRepeatSetup $6
        SongNote "G4"
    SongRepeat
    SongRepeatSetup $6
        SongNote "Gb4"
    SongRepeat
    SongRepeatSetup $6
        SongNote "F4"
    SongRepeat
    SongRepeatSetup $6
        SongNote "E4"
    SongRepeat
    SongRepeatSetup $6
        SongNote "Eb4"
    SongRepeat
    SongRepeatSetup $6
        SongNote "D4"
    SongRepeat
    SongRepeatSetup $6
        SongNote "Db4"
    SongRepeat
    SongRepeatSetup $6
        SongNote "C4"
    SongRepeat
    SongRepeatSetup $6
        SongNote "B3"
    SongRepeat
    SongRepeatSetup $6
        SongNote "Bb3"
    SongRepeat
    SongNoteLength_Semibreve
    SongRest
    SongEnd
;}

; $6AE2
song_finalCaves_header:
song_finalCaves_clone_header:
    SongHeader $1, $40B8, song_finalCaves_toneSweep, song_finalCaves_tone, song_finalCaves_wave, song_finalCaves_noise

; $6AED
song_finalCaves_clone_toneSweep:
song_finalCaves_toneSweep:
;{
    .loop
    dw song_finalCaves_toneSweep_section0 ; $6B05
    dw $00F0, .loop
;}

; $6AF3
song_finalCaves_clone_tone:
song_finalCaves_tone:
;{
    .loop
    dw song_finalCaves_tone_section0 ; $6B15
    dw $00F0, .loop
;}

; $6AF9
song_finalCaves_clone_wave:
song_finalCaves_wave:
;{
    .loop
    dw song_finalCaves_wave_section0 ; $6B25
    dw $00F0, .loop
;}

; $6AFF
song_finalCaves_clone_noise:
song_finalCaves_noise:
;{
    .loop
    dw song_finalCaves_noise_section0 ; $6BBA
    dw $00F0, .loop
;}

; $6B05
song_finalCaves_toneSweep_section0:
;{
    SongOptions
        DescendingEnvelopeOptions 3, $C
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
    SongNoteLength_Crochet
    SongNote "C3"
    Echo1
    SongNoteLength_DottedCrochet
    SongNote "C3"
    Echo1
    Echo1
    SongNoteLength_Breve
    Echo2
    SongRest
    SongRest
    SongEnd
;}

; $6B15
song_finalCaves_tone_section0:
;{
    SongOptions
        DescendingEnvelopeOptions 4, $C
        AscendingSweepOptions 0, 0
        LengthDutyOptions $A, 0
    SongNoteLength_Crochet
    SongNote "C2"
    Echo1
    SongNoteLength_DottedCrochet
    SongNote "C2"
    Echo1
    Echo1
    SongNoteLength_Breve
    Echo2
    SongRest
    SongRest
    SongEnd
;}

; $6B25
song_finalCaves_wave_section0:
;{
    SongOptions
        WaveOptions $417B, 2, $4
    SongRepeatSetup $5
        SongNoteLength_Breve
        SongRest
        SongRest
        SongNoteLength_Semiquaver
        SongRest
        SongNoteLength_Semibreve
        SongRest
        SongNoteLength_Semiquaver
        SongNote "E3"
        Echo1
        SongNote "F3"
        Echo1
        SongNote "B3"
        Echo1
        SongNote "Bb3"
        Echo1
        SongNoteLength_Minum
        SongNote "A3"
        Echo1
        SongRest
        SongNote "G4"
        SongNoteLength_Crochet
        Echo1
        SongRest
        SongNoteLength_Semiquaver
        SongNote "Eb3"
        Echo1
        SongNote "A3"
        Echo1
        SongNoteLength_Minum
        SongNote "Db4"
        SongNoteLength_Crochet
        Echo1
        SongRest
        SongNoteLength_Semiquaver
        SongNote "C4"
        Echo1
        SongNote "B3"
        Echo1
        SongNoteLength_Semibreve
        SongNote "F3"
        Echo1
        SongRest
        SongNoteLength_Breve
        SongRest
        SongNoteLength_Semiquaver
        SongNote "Eb3"
        Echo1
        SongNote "E3"
        Echo1
        SongNote "C3"
        Echo1
        SongNote "Bb3"
        Echo1
        SongNote "A3"
        Echo1
        SongNoteLength_Minum
        SongNote "Gb3"
        Echo1
        SongRest
        SongRest
        SongNoteLength_Quaver
        SongNote "D3"
        Echo1
        SongNote "Eb3"
        Echo1
        SongNote "G3"
        Echo1
        SongNoteLength_DottedCrochet
        SongNote "B2"
        Echo1
        SongNoteLength_Semiquaver
        SongNote "Db3"
        Echo1
        SongNoteLength_DottedMinum
        SongNote "G2"
        Echo1
        SongNote "A2"
        Echo1
        SongNote "F2"
        Echo1
        SongNoteLength_Semiquaver
        SongNote "C2"
        Echo1
        SongNote "Gb2"
        Echo1
        SongNote "B2"
        Echo1
        SongNote "C3"
        Echo1
        SongNote "F3"
        Echo1
        SongNoteLength_DottedCrochet
        SongNote "B3"
        Echo1
        SongNote "Bb3"
        Echo1
        SongNoteLength_DottedMinum
        SongNote "C4"
        Echo1
        SongNoteLength_DottedCrochet
        SongNote "G4"
        Echo1
        SongNote "Ab4"
        Echo1
        SongNote "E4"
        Echo1
        SongNote "F4"
        Echo1
        SongNote "Eb4"
        Echo1
        SongNote "G4"
        Echo1
        SongNote "B3"
        Echo1
        SongNoteLength_Minum
        SongNote "G3"
        Echo1
        SongNoteLength_DottedMinum
        SongNote "Ab3"
        Echo1
        SongRest
        SongNoteLength_Semiquaver
        SongNote "G3"
        Echo1
        SongNote "Gb3"
        Echo1
        SongNote "C3"
        Echo1
        SongNote "A2"
        Echo1
        SongNote "Gb2"
        Echo1
        SongNoteLength_Minum
        SongNote "C3"
        Echo1
    SongRepeat
    SongRepeatSetup $8
        SongNoteLength_Breve
        SongRest
    SongRepeat
    SongEnd
;}

; $6BBA
song_finalCaves_noise_section0:
;{
    SongNoteLength_Minum
    SongNoiseNote $1D
    SongNoteLength_Quaver
    SongRest
    SongNoteLength_DottedCrochet
    SongNoiseNote $1E
    SongNoteLength_Quaver
    SongRest
    SongEnd
;}

; $6BC3
song_metroidHive_header:
song_metroidHive_clone_header:
    SongHeader $FE, $40DF, $0000, song_metroidHive_tone, song_metroidHive_wave, song_metroidHive_noise

; $6BCE
song_metroidHive_withIntro_toneSweep_loop:
;{
    .loop
    dw song_metroidHive_withIntro_toneSweep_loop_section0 ; $6C00
    dw song_metroidHive_withIntro_toneSweep_loop_section1 ; $6C00
    dw song_metroidHive_withIntro_toneSweep_loop_section2 ; $6C5F
    dw song_metroidHive_withIntro_toneSweep_loop_section3 ; $6C00
    dw song_metroidHive_withIntro_toneSweep_loop_section4 ; $6C5F
    dw song_metroidHive_withIntro_toneSweep_loop_section5 ; $6C5F
    dw song_metroidHive_withIntro_toneSweep_loop_section6 ; $6C00
    dw $00F0, .loop
;}

; $6BE0
song_metroidHive_clone_tone:
song_metroidHive_tone:
;{
    .loop
    dw song_metroidHive_tone_section0 ; $6C5A
    dw song_metroidHive_tone_section1 ; $6C04
    dw song_metroidHive_tone_section2 ; $6C04
    dw song_metroidHive_tone_section3 ; $6C5F
    dw song_metroidHive_tone_section4 ; $6C04
    dw song_metroidHive_tone_section5 ; $6C5F
    dw song_metroidHive_tone_section6 ; $6C5F
    dw song_metroidHive_tone_section7 ; $6C04
    dw $00F0, .loop
;}

; $6BF4
song_metroidHive_clone_wave:
song_metroidHive_wave:
;{
    .loop
    dw song_metroidHive_wave_section0 ; $6C65
    dw $00F0, .loop
;}

; $6BFA
song_metroidHive_clone_noise:
song_metroidHive_noise:
;{
    .loop
    dw song_metroidHive_noise_section0 ; $6C85
    dw $00F0, .loop
;}

; $6C00
song_metroidHive_withIntro_toneSweep_loop_section3:
song_metroidHive_withIntro_toneSweep_loop_section6:
song_metroidHive_withIntro_toneSweep_loop_section0:
song_metroidHive_withIntro_toneSweep_loop_section1:
;{
    SongOptions
        DescendingEnvelopeOptions 1, $6
        AscendingSweepOptions 0, 0
        LengthDutyOptions $9, 1
;}

; $6C04
song_metroidHive_tone_section1:
song_metroidHive_tone_section7:
song_metroidHive_tone_section2:
song_metroidHive_tone_section4:
;{
    SongRepeatSetup $2
        SongNoteLength_TripletQuaver
        SongNote "B6"
        Echo2
        Echo1
        SongNote "Eb6"
        Echo2
        Echo1
        SongNote "F6"
        Echo2
        Echo1
        SongNote "Db6"
        Echo2
        Echo1
        SongNote "Eb6"
        Echo2
        Echo1
        SongNote "G6"
        Echo2
        Echo1
    SongRepeat
    SongRepeatSetup $2
        SongNote "A6"
        Echo2
        Echo1
        SongNote "Eb6"
        Echo2
        Echo1
        SongNote "F6"
        Echo2
        Echo1
        SongNote "Db6"
        Echo2
        Echo1
        SongNote "Eb6"
        Echo2
        Echo1
        SongNote "B5"
        Echo2
        Echo1
    SongRepeat
    SongRepeatSetup $2
        SongNote "G6"
        Echo2
        Echo1
        SongNote "B5"
        Echo2
        Echo1
        SongNote "Db6"
        Echo2
        Echo1
        SongNote "F6"
        Echo2
        Echo1
        SongNote "G6"
        Echo2
        Echo1
        SongNote "B6"
        Echo2
        Echo1
    SongRepeat
    SongRepeatSetup $2
        SongNote "F6"
        Echo2
        Echo1
        SongNote "B5"
        Echo2
        Echo1
        SongNote "Db6"
        Echo2
        Echo1
        SongNote "A5"
        Echo2
        Echo1
        SongNote "B5"
        Echo2
        Echo1
        SongNote "Eb6"
        Echo2
        Echo1
    SongRepeat
    SongEnd
;}

; $6C5A
song_metroidHive_tone_section0:
;{
    SongOptions
        DescendingEnvelopeOptions 1, $6
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 1
    SongEnd
;}

; $6C5F
song_metroidHive_tone_section6:
song_metroidHive_withIntro_toneSweep_loop_section4:
song_metroidHive_withIntro_toneSweep_loop_section2:
song_metroidHive_tone_section5:
song_metroidHive_withIntro_toneSweep_loop_section5:
song_metroidHive_tone_section3:
;{
    SongRepeatSetup $6
        SongNoteLength_Semibreve
        SongRest
    SongRepeat
    SongEnd
;}

; $6C65
song_metroidHive_wave_section0:
;{
    SongOptions
        WaveOptions $417B, 2, $0
    SongRepeatSetup $A
        SongNoteLength_Semibreve
        SongNote "B2"
        SongNoteLength_DottedCrochet
        SongNote "F3"
        SongNoteLength_Semibreve
        SongNote "Eb3"
        SongNote "A2"
        SongNote "F2"
        SongNoteLength_DottedCrochet
        SongNote "Db3"
        SongNoteLength_Semibreve
        SongNote "A2"
        SongNote "F2"
        SongNote "C3"
    SongRepeat
    SongNoteLength_DottedMinum
    SongNote "B2"
    SongNoteLength_Semibreve
    SongNote "Bb2"
    SongNoteLength_Minum
    SongNote "A2"
    SongNoteLength_Semibreve
    SongNote "Ab2"
    SongNote "F3"
    SongNote "A2"
    SongEnd
;}

; $6C85
song_metroidHive_noise_section0:
;{
    SongNoteLength_DottedQuaver
    SongNoiseNote $1D
    SongNoteLength_Demisemiquaver
    SongRest
    SongNoteLength_DottedQuaver
    SongNoiseNote $1E
    SongNoteLength_Semiquaver
    SongRest
    SongEnd
;}

; $6C8E
song_itemGet_header:
song_itemGet_clone_header:
    SongHeader $B, $40C5, song_itemGet_toneSweep, song_itemGet_tone, song_itemGet_wave, song_itemGet_noise

; $6C99
song_itemGet_clone_toneSweep:
song_itemGet_toneSweep:
;{
    dw song_itemGet_toneSweep_section0 ; $6CA9
    dw $0000
;}

; $6C9D
song_itemGet_clone_tone:
song_itemGet_tone:
;{
    dw song_itemGet_tone_section0 ; $6CEE
    dw $0000
;}

; $6CA1
song_itemGet_clone_wave:
song_itemGet_wave:
;{
    dw song_itemGet_wave_section0 ; $6D1D
    dw $0000
;}

; $6CA5
song_itemGet_clone_noise:
song_itemGet_noise:
;{
    dw song_itemGet_noise_section0 ; $6D46
    dw $0000
;}

; $6CA9
song_itemGet_toneSweep_section0:
;{
    SongOptions
        DescendingEnvelopeOptions 1, $A
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
    SongNoteLength_Semiquaver
    SongNote "A6"
    SongNote "Bb6"
    SongNote "A6"
    SongNote "Bb6"
    SongOptions
        DescendingEnvelopeOptions 0, $8
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 2
    SongNoteLength_Quaver
    SongNote "C4"
    SongNoteLength_DottedCrochet
    Echo1
    SongNoteLength_Quaver
    SongNote "A3"
    SongNoteLength_DottedCrochet
    Echo1
    SongNoteLength_Quaver
    SongNote "G3"
    Echo1
    SongNote "E3"
    Echo1
    SongNote "C3"
    Echo1
    SongNote "E3"
    Echo1
    SongNote "D4"
    Echo1
    SongNote "Bb3"
    Echo1
    SongNote "G3"
    SongNoteLength_DottedQuaver
    Echo1
    SongNoteLength_DottedQuaver
    SongNote "Eb3"
    Echo1
    SongOptions
        AscendingEnvelopeOptions 5, $0
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 2
    SongNoteLength_DottedCrochet
    SongNote "E3"
    SongNoteLength_Crochet
    Echo1
    SongOptions
        DescendingEnvelopeOptions 1, $8
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
    SongRepeatSetup $4
        SongNoteLength_Semiquaver
        SongNote "C7"
        SongNote "E7"
    SongRepeat
    SongOptions
        DescendingEnvelopeOptions 1, $4
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
    SongRepeatSetup $6
        SongNoteLength_Semiquaver
        SongNote "C7"
        SongNote "E7"
    SongRepeat
    SongEnd
;}

; $6CEE
song_itemGet_tone_section0:
;{
    SongOptions
        DescendingEnvelopeOptions 0, $F
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 2
    SongNoteLength_Hemidemisemiquaver
    SongRest
    SongNoteLength_Crochet
    SongRest
    SongNoteLength_Quaver
    SongNote "F4"
    Echo1
    SongNote "Bb4"
    Echo1
    SongNote "C5"
    Echo1
    SongNote "D5"
    Echo1
    SongNote "E5"
    Echo1
    SongNote "C5"
    Echo1
    SongNote "G4"
    Echo1
    SongNote "C5"
    Echo1
    SongNote "F5"
    Echo1
    SongNote "D5"
    Echo1
    SongNote "Bb4"
    SongNoteLength_DottedQuaver
    Echo1
    SongNote "G4"
    Echo1
    SongOptions
        AscendingEnvelopeOptions 3, $0
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 2
    SongNoteLength_DottedCrochet
    SongNote "A4"
    SongOptions
        DescendingEnvelopeOptions 6, $B
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 2
    SongNoteLength_Semibreve
    SongNote "A4"
    SongEnd
;}

; $6D1D
song_itemGet_wave_section0:
;{
    SongOptions
        WaveOptions $4123, 1, $0
    SongNoteLength_Crochet
    SongRest
    SongNoteLength_Quaver
    SongNote "F5"
    Echo2
    SongNote "Bb5"
    Echo2
    SongNote "C6"
    Echo2
    SongNote "D6"
    Echo2
    SongNote "E6"
    Echo2
    SongNote "C6"
    Echo2
    SongNote "G5"
    Echo2
    SongNote "C6"
    Echo2
    SongNote "F6"
    Echo2
    SongNote "D6"
    Echo2
    SongNote "Bb5"
    SongNoteLength_DottedQuaver
    Echo2
    SongNoteLength_Quaver
    SongNote "G5"
    SongNoteLength_DottedQuaver
    Echo2
    Echo1
    SongNoteLength_Minum
    SongNote "A5"
    SongNoteLength_Crochet
    Echo2
    Echo1
    SongEnd
;}

; $6D46
song_itemGet_noise_section0:
;{
    SongNoteLength_DottedCrochet
    SongNoiseNote $1A
    SongNoteLength_Semibreve
    SongNoiseNote $1B
    SongRest
    SongRest
    SongNoteLength_DottedCrochet
    SongNoiseNote $1A
    SongNoteLength_Breve
    SongNoiseNote $1B
    SongEnd
;}

; $6D51
song_metroidQueenHallway_header:
song_metroidQueenHallway_clone_header:
    SongHeader $1, $40D2, song_metroidQueenHallway_toneSweep, song_metroidQueenHallway_tone, song_metroidQueenHallway_wave, song_metroidQueenHallway_noise

; $6D5C
song_metroidQueenHallway_clone_tone:
song_metroidQueenHallway_clone_toneSweep:
song_metroidQueenHallway_tone:
song_metroidQueenHallway_toneSweep:
;{
    dw song_metroidQueenHallway_toneSweep_section0 ; $6D70
    .loop
    dw song_metroidQueenHallway_toneSweep_section1 ; $6D7B
    dw $00F0, .loop
;}

; $6D64
song_metroidQueenHallway_clone_wave:
song_metroidQueenHallway_wave:
;{
    .loop
    dw song_metroidQueenHallway_wave_section0 ; $6D77
    dw $00F0, .loop
;}

; $6D6A
song_metroidQueenHallway_clone_noise:
song_metroidQueenHallway_noise:
;{
    .loop
    dw song_metroidQueenHallway_noise_section0 ; $6D82
    dw $00F0, .loop
;}

; $6D70
song_metroidQueenHallway_toneSweep_section0:
;{
    SongOptions
        DescendingEnvelopeOptions 0, $9
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 1
    SongNoteLength_Demisemiquaver
    SongRest
    SongEnd
;}

; $6D77
song_metroidQueenHallway_wave_section0:
;{
    SongOptions
        WaveOptions $416B, 2, $0
;}

; $6D7B
song_metroidQueenHallway_toneSweep_section1:
;{
    SongRepeatSetup $3
        SongNoteLength_Crochet
        SongNote "A2"
        Echo1
    SongRepeat
    SongEnd
;}

; $6D82
song_metroidQueenHallway_noise_section0:
;{
    SongNoteLength_DottedQuaver
    SongNoiseNote $1D
    SongNoteLength_Demisemiquaver
    SongRest
    SongNoteLength_DottedQuaver
    SongNoiseNote $1E
    SongNoteLength_Semiquaver
    SongRest
    SongEnd
;}

; $6D8B
song_metroidBattle_header:
song_metroidBattle_clone_header:
    SongHeader $0, $40C5, song_metroidBattle_toneSweep, song_metroidBattle_tone, song_metroidBattle_wave, song_metroidBattle_noise

; $6D96
song_metroidBattle_clone_toneSweep:
song_metroidBattle_toneSweep:
;{
    dw song_metroidBattle_toneSweep_section0 ; $6DB8
    dw song_metroidBattle_toneSweep_section1 ; $7D7E
    .loop
    dw song_metroidBattle_toneSweep_section2 ; $6DC6
    dw $00F0, .loop
;}

; $6DA0
song_metroidBattle_clone_tone:
song_metroidBattle_tone:
;{
    dw song_metroidBattle_tone_section0 ; $6E0D
    .loop
    dw song_metroidBattle_tone_section1 ; $6E29
    dw $00F0, .loop
;}

; $6DA8
song_metroidBattle_clone_wave:
song_metroidBattle_wave:
;{
    dw song_metroidBattle_wave_section0 ; $6E68
    .loop
    dw song_metroidBattle_wave_section1 ; $6E77
    dw $00F0, .loop
;}

; $6DB0
song_metroidBattle_clone_noise:
song_metroidBattle_noise:
;{
    dw song_metroidBattle_noise_section0 ; $6EA3
    .loop
    dw song_metroidBattle_noise_section1 ; $6EB2
    dw $00F0, .loop
;}

; $6DB8
song_metroidBattle_toneSweep_section0:
;{
    SongOptions
        DescendingEnvelopeOptions 0, $A
        AscendingSweepOptions 7, 1
        LengthDutyOptions $6, 0
    SongNoteLength_Semibreve
    SongNote "Gb2"
    SongNoteLength_Quaver
    SongNote "Db4"
    SongNote "Eb4"
    SongNote "Ab4"
    SongNote "C5"
    SongNote "Gb5"
    SongNote "Bb5"
    SongEnd
;}

; $6DC6
song_metroidBattle_toneSweep_section2:
;{
    SongOptions
        DescendingEnvelopeOptions 7, $8
        DescendingSweepOptions 7, 7
        LengthDutyOptions $0, 0
    SongNoteLength_Quaver
    SongNote "C3"
    SongRest
    SongNote "Db3"
    SongRest
    SongNote "D3"
    SongRest
    SongNote "Eb3"
    SongRest
    SongNote "E3"
    SongRest
    SongNote "F3"
    SongOptions
        DescendingEnvelopeOptions 7, $6
        AscendingSweepOptions 4, 3
        LengthDutyOptions $0, 0
    SongNoteLength_Semiquaver
    SongNote "G3"
    SongRepeatSetup $3
        SongNoteLength_Quaver
        SongNote "C4"
        SongRest
        SongNote "D4"
        SongRest
        SongNote "B3"
        SongRest
        SongNote "Bb3"
        SongRest
    SongRepeat
    SongOptions
        DescendingEnvelopeOptions 3, $8
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
    SongNoteLength_Semiquaver
    SongNote "C5"
    SongNote "B5"
    SongNote "C5"
    SongNote "B5"
    SongNoteLength_Crochet
    SongNote "C5"
    SongNoteLength_Semiquaver
    SongNote "C5"
    SongNote "B5"
    SongNote "C5"
    SongOptions
        DescendingEnvelopeOptions 1, $D
        AscendingSweepOptions 0, 0
        LengthDutyOptions $8, 0
    SongNoteLength_Crochet
    SongNote "G5"
    SongNoteLength_Semiquaver
    SongRest
    SongOptions
        DescendingEnvelopeOptions 7, $6
        AscendingSweepOptions 7, 7
        LengthDutyOptions $0, 0
    SongNoteLength_Quaver
    SongNote "E3"
    SongRest
    SongNote "Eb3"
    SongRest
    SongNote "D3"
    SongRest
    SongNote "Db3"
    SongRest
    SongEnd
;}

; $6E0D
song_metroidBattle_tone_section0:
;{
    SongOptions
        DescendingEnvelopeOptions 5, $A
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
    SongNoteLength_Semiquaver
    SongNote "D4"
    SongNote "D3"
    SongNote "Ab4"
    SongNote "Ab3"
    SongNoteLength_Minum
    SongNote "D5"
    SongNoteLength_Semiquaver
    SongNote "D7"
    SongNote "Db7"
    SongNote "D7"
    SongNote "Db7"
    SongOptions
        DescendingEnvelopeOptions 5, $8
        AscendingSweepOptions 0, 0
        LengthDutyOptions $8, 0
    SongNoteLength_Quaver
    SongNote "C6"
    SongNote "B5"
    SongNote "Bb5"
    SongNote "A5"
    SongNote "Gb5"
    SongNote "Db5"
    SongEnd
;}

; $6E29
song_metroidBattle_tone_section1:
;{
    SongOptions
        DescendingEnvelopeOptions 3, $8
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
    SongNoteLength_Quaver
    SongNote "B3"
    SongNote "F3"
    SongNote "A3"
    SongNote "F3"
    SongNote "Gb3"
    SongNote "F3"
    SongNote "G3"
    SongNote "F3"
    SongNote "B3"
    SongNote "F3"
    SongNote "A3"
    SongNoteLength_Semiquaver
    SongNote "Gb3"
    SongRepeatSetup $3
        SongNoteLength_Quaver
        SongNote "B3"
        SongNote "F3"
        SongNote "A3"
        SongNote "F3"
        SongNote "Gb3"
        SongNote "F3"
        SongNote "G3"
        SongNote "F3"
    SongRepeat
    SongNoteLength_Semiquaver
    SongNote "Ab5"
    SongNote "Gb5"
    SongNote "Ab5"
    SongNote "Gb5"
    SongNoteLength_Crochet
    SongNote "Ab5"
    SongNoteLength_Semiquaver
    SongNote "Ab5"
    SongNote "Gb5"
    SongNote "Ab5"
    SongOptions
        DescendingEnvelopeOptions 1, $D
        AscendingSweepOptions 0, 0
        LengthDutyOptions $8, 0
    SongNoteLength_Crochet
    SongNote "Ab5"
    SongNoteLength_Semiquaver
    SongRest
    SongOptions
        DescendingEnvelopeOptions 1, $A
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
    SongNoteLength_Quaver
    SongNote "B3"
    SongNote "F3"
    SongNote "A3"
    SongNote "F3"
    SongNote "Gb3"
    SongNote "F3"
    SongNote "G3"
    SongNote "F3"
    SongEnd
;}

; $6E68
song_metroidBattle_wave_section0:
;{
    SongOptions
        WaveOptions $416B, 2, $0
    SongNoteLength_Semiquaver
    SongNote "D5"
    SongNote "D3"
    SongNote "Ab5"
    SongNote "Ab3"
    SongNoteLength_DottedCrochet
    SongNote "D6"
    Echo1
    SongNoteLength_DottedMinum
    SongRest
    SongEnd
;}

; $6E77
song_metroidBattle_wave_section1:
;{
    SongOptions
        WaveOptions $418B, 2, $7
    SongNoteLength_Crochet
    SongNote "A3"
    SongNote "A3"
    SongNote "A3"
    SongNote "A3"
    SongNote "Ab3"
    SongNoteLength_Quaver
    SongNote "G3"
    SongNoteLength_Semiquaver
    SongRest
    SongRepeatSetup $3
        SongNoteLength_Crochet
        SongNote "Bb3"
        SongNote "A3"
        SongNote "Bb3"
        SongNote "A3"
    SongRepeat
    SongOptions
        WaveOptions $417B, 2, $7
    SongNoteLength_Semiquaver
    SongNote "Db7"
    SongNote "Gb7"
    SongNote "Ab7"
    SongNote "Bb7"
    SongNoteLength_Crochet
    SongNote "Gb5"
    SongNoteLength_Semiquaver
    SongNote "Ab7"
    SongNote "E7"
    SongNote "Db7"
    SongNote "E7"
    SongNoteLength_Crochet
    SongNote "D5"
    SongNoteLength_Minum
    SongNote "Ab3"
    SongNote "Ab3"
    SongEnd
;}

; $6EA3
song_metroidBattle_noise_section0:
;{
    SongNoteLength_Semiquaver
    SongNoiseNote $7
    SongNoiseNote $6
    SongNoiseNote $7
    SongNoiseNote $6
    SongNoteLength_DottedMinum
    SongNoiseNote $7
    SongNoteLength_Quaver
    SongNoiseNote $4
    SongNoiseNote $5
    SongNoiseNote $6
    SongNoiseNote $6
    SongNoiseNote $7
    SongNoiseNote $7
    SongEnd
;}

; $6EB2
song_metroidBattle_noise_section1:
;{
    SongNoteLength_Crochet
    SongNoiseNote $5
    SongNoiseNote $5
    SongNoiseNote $5
    SongNoiseNote $5
    SongNoiseNote $5
    SongNoteLength_Quaver
    SongRest
    SongNoteLength_Semiquaver
    SongNoiseNote $4
    SongRepeatSetup $6
        SongNoteLength_Crochet
        SongNoiseNote $5
        SongNoiseNote $5
    SongRepeat
    SongNoteLength_Semiquaver
    SongNoiseNote $5
    SongNoiseNote $5
    SongNoiseNote $5
    SongNoiseNote $5
    SongNoteLength_Crochet
    SongNoiseNote $7
    SongNoteLength_Semiquaver
    SongNoiseNote $5
    SongNoteLength_DottedCrochet
    SongNoiseNote $12
    SongNoteLength_Semiquaver
    SongNoiseNote $5
    SongNoteLength_Crochet
    SongNoiseNote $5
    SongNoiseNote $5
    SongNoiseNote $5
    SongNoiseNote $5
    SongEnd
;}

; $6ED5
song_subCaves4_header:
    SongHeader $0, $40C5, song_subCaves4_toneSweep, song_subCaves4_tone, song_subCaves4_wave, song_subCaves4_noise

; $6EE0
song_subCaves4_toneSweep:
;{
    dw song_subCaves4_toneSweep_section0 ; $7DA0
    dw song_subCaves4_toneSweep_section1 ; $7D7E
    dw $0000
;}

; $6EE6
song_subCaves4_tone:
;{
    dw song_subCaves4_tone_section0 ; $7DCA
    .loop
    .alternateEntry
    dw song_subCaves4_tone_section1 ; $6EF6
    dw $00F0, .loop
;}

; $6EEE
song_subCaves4_wave:
;{
    dw song_subCaves4_wave_section0 ; $7DF4
    dw $0000
;}

; $6EF2
song_subCaves4_noise:
;{
    dw song_subCaves4_noise_section0 ; $7E04
    dw $0000
;}

; $6EF6
song_subCaves4_tone_section1:
;{
    SongOptions
        DescendingEnvelopeOptions 7, $1
        AscendingSweepOptions 0, 0
        LengthDutyOptions $7, 2
    SongNoteLength_Semiquaver
    SongNote "C6"
    SongNote "E5"
    SongNote "A5"
    SongNote "B5"
    SongNote "B5"
    SongNote "D5"
    SongNote "G5"
    SongNote "F5"
    SongNoteLength_Minum
    SongRest
    SongNoteLength_Quaver
    SongNote "C6"
    SongNote "G5"
    SongNote "E5"
    SongNote "B5"
    SongNote "D5"
    SongNoteLength_Breve
    SongRest
    SongNoteLength_Semiquaver
    SongNote "D5"
    SongNote "G5"
    SongNote "E5"
    SongNoteLength_DottedMinum
    SongRest
    SongRest
    SongNoteLength_Semiquaver
    SongNote "G5"
    SongNote "E5"
    SongNote "A5"
    SongNote "D5"
    SongNote "G6"
    SongNote "E5"
    SongNoteLength_Semibreve
    SongRest
    SongNoteLength_Quaver
    SongNote "G5"
    SongNote "E5"
    SongNoteLength_Breve
    SongRest
    SongNoteLength_Semiquaver
    SongNote "F5"
    SongNote "B5"
    SongNote "A5"
    SongNote "G5"
    SongNote "E5"
    SongNote "B5"
    SongNote "C6"
    SongNoteLength_DottedMinum
    SongNote "E5"
    SongNote "G5"
    SongNote "D5"
    SongRest
    SongRest
    SongNoteLength_Semiquaver
    SongNote "C6"
    SongNote "B5"
    SongRest
    SongNote "Gb5"
    SongNote "F5"
    SongNote "G5"
    SongNote "E5"
    SongRest
    SongRest
    SongNote "G5"
    SongNote "D5"
    SongNote "B5"
    SongNoteLength_DottedCrochet
    SongRest
    SongNoteLength_Breve
    SongRest
    SongNoteLength_DottedQuaver
    SongNote "D5"
    SongNote "G5"
    SongNote "E5"
    SongNoteLength_Breve
    SongRest
    SongNoteLength_Semiquaver
    SongNote "A5"
    SongNote "B5"
    SongNote "F5"
    SongNote "Gb5"
    SongNote "G5"
    SongNoteLength_Breve
    SongRest
    SongEnd
;}

; $6F50
song_earthquake_header:
    SongHeader $0, $40DF, $0000, $0000, $0000, song_earthquake_noise

; $6F5B
song_earthquake_noise:
;{
    dw song_earthquake_noise_section0 ; $6F5F
    dw $0000
;}

; $6F5F
song_earthquake_noise_section0:
;{
    SongNoteLength_Crochet
    SongNoiseNote $12
    SongRepeatSetup $3
        SongNoteLength_Semiquaver
        SongNoiseNote $B
        SongNoiseNote $B
    SongRepeat
    SongRepeatSetup $3
        SongNoiseNote $B
        SongNoiseNote $A
    SongRepeat
    SongRepeatSetup $2
        SongNoiseNote $A
        SongNoiseNote $9
    SongRepeat
    SongRepeatSetup $3
        SongNoiseNote $8
        SongNoiseNote $9
    SongRepeat
    SongRepeatSetup $2
        SongNoiseNote $D
        SongNoiseNote $E
    SongRepeat
    SongNoteLength_Semiquaver
    SongNoiseNote $8
    SongNoiseNote $D
    SongNoiseNote $B
    SongNoiseNote $E
    SongNoiseNote $8
    SongNoiseNote $E
    SongNoiseNote $B
    SongNoiseNote $D
    SongNoiseNote $B
    SongNoiseNote $D
    SongNoiseNote $A
    SongNoiseNote $D
    SongNoiseNote $8
    SongNoiseNote $F
    SongNoiseNote $8
    SongNoiseNote $B
    SongNoiseNote $8
    SongNoiseNote $F
    SongNoiseNote $A
    SongNoiseNote $D
    SongNoiseNote $A
    SongNoiseNote $C
    SongNoiseNote $A
    SongNoiseNote $B
    SongNoteLength_Semiquaver
    SongNoiseNote $9
    SongNoiseNote $17
    SongRepeatSetup $3
        SongNoiseNote $A
        SongNoiseNote $18
    SongRepeat
    SongRepeatSetup $5A
        SongNoiseNote $A
        SongNoiseNote $B
    SongRepeat
    SongNoteLength_Semibreve
    SongNoiseNote $A
    SongEnd
;}

; $6FA4
song_killedMetroid_header:
    SongHeader $D, $40F9, song_killedMetroid_toneSweep, song_killedMetroid_tone, song_killedMetroid_wave, $0000

; $6FAF
song_killedMetroid_tone:
song_killedMetroid_toneSweep:
;{
    dw song_killedMetroid_toneSweep_section0 ; $6FC5
    dw song_killedMetroid_toneSweep_section1 ; $7D7A
    dw song_killedMetroid_toneSweep_section2 ; $6FD2
    dw song_killedMetroid_toneSweep_section3 ; $6FF6
    dw $0000
;}

; $6FB9
unused6FB9:
;{
    dw unused6FB9_section0 ; $6FC5
    dw unused6FB9_section1 ; $6FD2
    dw unused6FB9_section2 ; $6FF6
    dw $0000
;}

; $6FC1
song_killedMetroid_wave:
;{
    dw song_killedMetroid_wave_section0 ; $7000
    dw $0000
;}

; $6FC5
unused6FB9_section0:
song_killedMetroid_toneSweep_section0:
;{
    SongOptions
        AscendingEnvelopeOptions 1, $0
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
    SongNoteLength_DottedCrochet
    SongNote "C6"
    SongOptions
        DescendingEnvelopeOptions 5, $F
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
    SongNoteLength_DottedMinum
    SongNote "C6"
    SongEnd
;}

; $6FD2
unused6FB9_section1:
song_killedMetroid_toneSweep_section2:
;{
    SongOptions
        DescendingEnvelopeOptions 7, $A
        AscendingSweepOptions 5, 3
        LengthDutyOptions $0, 2
;}

; $6FD6
song_metroidHive_withIntro_tone_section2:
song_metroidHive_withIntro_toneSweep_section3:
;{
    SongNoteLength_Hemidemisemiquaver
    SongNote "C4"
    SongNote "G4"
    SongNote "D4"
    SongNote "A4"
    SongNote "E4"
    SongNote "B4"
    SongNote "F4"
    SongNote "C5"
    SongNote "G4"
    SongNote "D5"
    SongNote "A4"
    SongNote "E5"
    SongNote "B4"
    SongNote "F5"
    SongNote "C5"
    SongNote "G5"
    SongNote "D5"
    SongNote "A5"
    SongNote "E5"
    SongNote "B5"
    SongNote "F5"
    SongNote "C6"
    SongNote "G5"
    SongNote "D6"
    SongNote "A5"
    SongNote "E6"
    SongNote "B5"
    SongNote "F6"
    SongNote "C6"
    SongNote "G6"
    SongEnd
;}

; $6FF6
unused6FB9_section2:
song_killedMetroid_toneSweep_section3:
;{
    SongOptions
        DescendingEnvelopeOptions 7, $C
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 2
    SongNoteLength_Demisemiquaver
    SongNote "E5"
    SongRest
    SongNoteLength_Semibreve
    SongNote "F5"
    SongEnd
;}

; $7000
song_killedMetroid_wave_section0:
;{
    SongOptions
        WaveOptions $416B, 1, $0
    SongNoteLength_Crochet
    SongRest
    SongNoteLength_Semiquaver
    SongRest
    SongRepeatSetup $4
        SongNoteLength_Demisemiquaver
        SongNote "C2"
        Echo1
    SongRepeat
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Minum
    SongRest
    SongOptions
        WaveOptions $416B, 3, $0
    SongNoteLength_Hemidemisemiquaver
    SongNote "C4"
    SongNote "G4"
    SongNote "D4"
    SongNote "A4"
    SongNote "E4"
    SongNote "B4"
    SongNote "F4"
    SongNote "C5"
    SongNote "G4"
    SongNote "D5"
    SongNote "A4"
    SongNote "E5"
    SongNote "B4"
    SongNote "F5"
    SongNote "C5"
    SongNote "G5"
    SongNote "D5"
    SongNote "A5"
    SongNote "E5"
    SongNote "B5"
    SongNote "F5"
    SongNote "C6"
    SongNote "G5"
    SongNote "D6"
    SongNote "A5"
    SongNote "E6"
    SongNote "B5"
    SongNote "F6"
    SongNote "C6"
    SongNote "G6"
    SongNoteLength_Demisemiquaver
    SongNote "E5"
    Echo1
    SongNoteLength_Crochet
    SongNote "F5"
    Echo1
    SongEnd
;}

; $703C
song_title_header:
    SongHeader $1, $40D2, song_title_toneSweep, song_title_tone, song_title_wave, song_title_noise

; $7047
song_title_tone:
song_title_toneSweep:
;{
    .loop
    dw song_title_toneSweep_section0 ; $7E09
    dw song_title_toneSweep_section1 ; $708B
    dw song_title_toneSweep_section2 ; $708B
    dw song_title_toneSweep_section3 ; $708B
    dw song_title_toneSweep_section4 ; $708B
    dw song_title_toneSweep_section5 ; $708B
    dw song_title_toneSweep_section6 ; $7D7E
    dw song_title_toneSweep_section7 ; $7152
    dw song_title_toneSweep_section8 ; $7187
    dw song_title_toneSweep_section9 ; $71CC
    dw song_title_toneSweep_sectionA ; $7D7A
    dw $00F0, .loop
;}

; $7061
song_title_wave:
;{
    .loop
    dw song_title_wave_section0 ; $7E10
    dw song_title_wave_section1 ; $7095
    dw song_title_wave_section2 ; $709F
    dw song_title_wave_section3 ; $7112
    dw song_title_wave_section4 ; $7095
    dw song_title_wave_section5 ; $7211
    dw song_title_wave_section6 ; $724E
    dw song_title_wave_section7 ; $73B0
    dw $00F0, .loop
;}

; $7075
song_title_noise:
;{
    .loop
    dw song_title_noise_section0 ; $7E17
    dw song_title_noise_section1 ; $713E
    dw song_title_noise_section2 ; $713E
    dw song_title_noise_section3 ; $7144
    dw song_title_noise_section4 ; $7144
    dw song_title_noise_section5 ; $713E
    dw song_title_noise_section6 ; $73E9
    dw song_title_noise_section7 ; $73EF
    dw song_title_noise_section8 ; $740F
    dw $00F0, .loop
;}

; $708B
song_title_toneSweep_section4:
song_title_toneSweep_section2:
song_title_toneSweep_section3:
song_title_toneSweep_section5:
song_title_toneSweep_section1:
;{
    SongOptions
        DescendingEnvelopeOptions 7, $D
        AscendingSweepOptions 0, 0
        LengthDutyOptions $4, 1
    SongRepeatSetup $4
        SongNoteLength_Breve
        SongNote "Bb6"
    SongRepeat
    SongEnd
;}

; $7095
song_title_wave_section1:
song_title_wave_section4:
;{
    SongOptions
        WaveOptions $4123, 3, $3
    SongNoteLength_Breve
    SongRest
    SongRest
    SongRest
    SongRest
    SongEnd
;}

; $709F
song_title_wave_section2:
;{
    SongNoteLength_DottedMinum
    SongRest
    SongNoteLength_Quaver
    SongNote "Ab6"
    SongNote "A5"
    SongNote "C6"
    Echo1
    SongNote "Ab6"
    SongNote "E5"
    SongRest
    SongNote "A5"
    SongRest
    SongNote "C6"
    SongNoteLength_DottedMinum
    SongRest
    SongNoteLength_Quaver
    SongRest
    SongNote "Db6"
    SongNote "Ab6"
    SongNote "Db6"
    SongNote "A6"
    SongNote "B6"
    SongNote "B5"
    SongNote "Gb6"
    SongNote "Ab6"
    SongRest
    SongNoteLength_DottedMinum
    SongRest
    SongNoteLength_Quaver
    SongNote "Ab6"
    SongNote "E6"
    SongNote "F5"
    SongNote "D6"
    SongNote "Db6"
    SongNote "C5"
    SongNote "B6"
    Echo1
    SongNote "Ab5"
    SongNote "Eb6"
    SongNoteLength_DottedMinum
    SongRest
    SongNoteLength_Quaver
    SongNote "Gb6"
    SongRest
    SongNote "Ab5"
    SongNote "E6"
    SongNote "Db5"
    SongNote "Ab6"
    SongNote "B6"
    SongNote "E5"
    SongNote "Bb6"
    Echo1
    SongOptions
        WaveOptions $4123, 2, $3
    SongNoteLength_Minum
    SongRest
    SongNoteLength_Quaver
    SongNote "Bb6"
    Echo1
    SongNote "Ab6"
    Echo1
    SongNote "C6"
    SongNote "Db7"
    SongNote "Ab6"
    Echo1
    SongNote "Ab6"
    SongNote "C6"
    SongNote "Bb6"
    Echo1
    SongNoteLength_DottedMinum
    SongRest
    SongNoteLength_Quaver
    SongRest
    SongNote "Db6"
    SongNote "B6"
    SongNote "D6"
    Echo1
    SongNote "Db6"
    SongNote "E6"
    SongNote "F6"
    SongNote "Gb6"
    Echo1
    SongNoteLength_Minum
    SongRest
    SongNoteLength_Quaver
    SongNote "C6"
    SongNote "E6"
    SongNote "Ab6"
    Echo1
    SongNote "F6"
    SongNote "D6"
    Echo1
    SongNote "C6"
    SongNote "E6"
    Echo1
    SongNote "A6"
    Echo1
    SongNoteLength_Minum
    SongRest
    SongNoteLength_Quaver
    SongNote "D6"
    Echo1
    SongNote "Ab6"
    Echo1
    SongNote "E6"
    SongNote "B6"
    SongNote "A6"
    SongNote "Db6"
    Echo1
    SongNote "B6"
    SongNote "Bb6"
    Echo1
    SongEnd
;}

; $7112
song_title_wave_section3:
;{
    SongOptions
        WaveOptions $4113, 2, $0
    SongNoteLength_Crochet
    SongNote "F7"
    Echo1
    SongNote "C7"
    Echo1
    SongNote "E7"
    Echo1
    SongNote "Bb6"
    Echo1
    SongNote "D7"
    Echo1
    SongNote "G6"
    Echo1
    SongNote "Db7"
    Echo1
    SongNote "A6"
    Echo1
    SongNote "B6"
    Echo1
    SongNote "D7"
    Echo1
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Crochet
    SongNote "Db7"
    Echo1
    SongNoteLength_Quaver
    SongRest
    SongNoteLength_Crochet
    SongNote "A6"
    Echo1
    SongNoteLength_DottedQuaver
    SongRest
    SongNoteLength_DottedMinum
    SongNote "G6"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_DottedMinum
    SongRest
    SongEnd
;}

; $713E
song_title_noise_section1:
song_title_noise_section2:
song_title_noise_section5:
;{
    SongNoteLength_Breve
    SongRest
    SongRest
    SongRest
    SongRest
    SongEnd
;}

; $7144
song_title_noise_section3:
song_title_noise_section4:
;{
    SongRepeatSetup $2
        SongNoteLength_Quaver
        SongNoiseNote $5
        SongNoteLength_Semibreve
        SongNoiseNote $8
        SongNoteLength_Minum
        SongRest
        SongNoteLength_DottedCrochet
        SongRest
        SongNoteLength_Breve
        SongNoiseNote $C
    SongRepeat
    SongEnd
;}

; $7152
song_title_toneSweep_section7:
;{
    SongOptions
        AscendingEnvelopeOptions 4, $0
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 1
    SongNoteLength_DottedCrochet
    SongNote "G4"
    SongNoteLength_Minum
    Echo1
    SongNoteLength_Quaver
    SongRest
    SongNoteLength_DottedCrochet
    SongNote "F4"
    SongNoteLength_Minum
    Echo1
    SongNoteLength_Quaver
    SongRest
    SongNoteLength_DottedCrochet
    SongNote "E4"
    SongNoteLength_Minum
    Echo1
    SongNoteLength_Quaver
    SongRest
    SongNoteLength_DottedCrochet
    SongNote "Eb4"
    SongNoteLength_Minum
    Echo1
    SongNoteLength_Quaver
    SongRest
    SongNoteLength_DottedCrochet
    SongNote "D4"
    SongNoteLength_Minum
    Echo1
    SongNoteLength_Quaver
    SongRest
    SongNoteLength_DottedCrochet
    SongNote "Bb4"
    SongNoteLength_Minum
    Echo1
    SongNoteLength_Quaver
    SongRest
    SongNoteLength_DottedCrochet
    SongNote "Eb4"
    SongNoteLength_Minum
    Echo1
    SongNoteLength_Quaver
    SongRest
    SongNoteLength_DottedCrochet
    SongNote "B4"
    SongNoteLength_Minum
    Echo1
    SongNoteLength_Quaver
    SongRest
    SongEnd
;}

; $7187
song_title_toneSweep_section8:
;{
    SongOptions
        AscendingEnvelopeOptions 7, $0
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
    SongNoteLength_DottedMinum
    SongNote "C5"
    SongNoteLength_Crochet
    Echo1
    SongNoteLength_DottedMinum
    SongNote "B4"
    SongNoteLength_Crochet
    Echo1
    SongNoteLength_DottedMinum
    SongNote "Bb4"
    SongNoteLength_Crochet
    Echo1
    SongNoteLength_DottedMinum
    SongNote "A4"
    SongNoteLength_Crochet
    Echo1
    SongNoteLength_DottedMinum
    SongNote "Ab4"
    SongNoteLength_Crochet
    Echo1
    SongNoteLength_DottedMinum
    SongNote "G4"
    SongNoteLength_Crochet
    Echo1
    SongNoteLength_DottedMinum
    SongNote "Gb4"
    SongNoteLength_Crochet
    Echo1
    SongNoteLength_DottedMinum
    SongNote "B4"
    SongNoteLength_Crochet
    Echo1
    SongNoteLength_DottedMinum
    SongNote "C4"
    SongNoteLength_Crochet
    Echo1
    SongNoteLength_DottedMinum
    SongNote "B3"
    SongNoteLength_Crochet
    Echo1
    SongNoteLength_DottedMinum
    SongNote "Bb3"
    SongNoteLength_Crochet
    Echo1
    SongNoteLength_DottedMinum
    SongNote "A3"
    SongNoteLength_Crochet
    Echo1
    SongNoteLength_DottedMinum
    SongNote "G3"
    SongNoteLength_Crochet
    Echo1
    SongNoteLength_DottedMinum
    SongNote "F3"
    SongNoteLength_Crochet
    Echo1
    SongNoteLength_DottedMinum
    SongNote "Eb3"
    SongNoteLength_Crochet
    Echo1
    SongNoteLength_DottedMinum
    SongNote "C3"
    SongNoteLength_DottedCrochet
    Echo1
    SongEnd
;}

; $71CC
song_title_toneSweep_section9:
;{
    SongOptions
        DescendingEnvelopeOptions 3, $F
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
    SongRepeatSetup $2
        SongNoteLength_Quaver
        SongNote "C6"
        Echo1
        SongNote "Bb6"
        Echo1
        SongNote "A6"
        Echo1
        SongNote "F6"
        Echo1
        SongNoteLength_Crochet
        SongNote "G6"
        Echo1
        SongNoteLength_DottedMinum
        SongRest
    SongRepeat
    SongOptions
        DescendingEnvelopeOptions 3, $C
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
    SongNoteLength_Quaver
    SongNote "C6"
    Echo1
    SongNote "Bb6"
    Echo1
    SongNote "A6"
    Echo1
    SongNote "F6"
    Echo1
    SongNoteLength_Crochet
    SongNote "G6"
    Echo1
    SongNoteLength_DottedMinum
    SongRest
    SongOptions
        DescendingEnvelopeOptions 4, $8
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
    SongNoteLength_Crochet
    SongNote "C6"
    SongNote "Bb6"
    SongNote "A6"
    SongNote "F6"
    SongNote "G6"
    SongRest
    SongNoteLength_DottedMinum
    SongRest
    SongOptions
        DescendingEnvelopeOptions 7, $4
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
    SongNoteLength_Crochet
    SongNote "C6"
    SongNote "Bb6"
    SongNote "A6"
    SongNote "F6"
    SongNote "G6"
    SongRest
    SongRepeatSetup $E
        SongNoteLength_Semibreve
        SongRest
    SongRepeat
    SongEnd
;}

; $7211
song_title_wave_section5:
;{
    SongOptions
        WaveOptions $41AB, 1, $0
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Crochet
    SongNote "E5"
    Echo1
    SongRest
    SongNoteLength_Quaver
    SongNote "F5"
    Echo1
    SongNoteLength_Crochet
    SongNote "G5"
    Echo1
    SongNoteLength_DottedQuaver
    SongNote "C5"
    SongNoteLength_Crochet
    Echo1
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_DottedQuaver
    SongNote "Bb5"
    SongNoteLength_DottedQuaver
    Echo1
    SongRest
    SongRest
    SongNoteLength_Semiquaver
    SongNote "A5"
    Echo1
    SongNote "F5"
    Echo1
    SongNoteLength_DottedQuaver
    SongNote "G5"
    SongNoteLength_Semiquaver
    Echo1
    SongNoteLength_Crochet
    SongRest
    SongRest
    SongRest
    SongNoteLength_Semibreve
    SongRest
    SongRest
    SongNoteLength_DottedQuaver
    SongNote "Bb5"
    Echo1
    SongNoteLength_DottedCrochet
    SongRest
    SongNoteLength_Semiquaver
    SongNote "A5"
    Echo1
    SongNote "F5"
    Echo1
    SongNoteLength_DottedQuaver
    SongNote "G5"
    SongNoteLength_Crochet
    Echo1
    SongRest
    SongRest
    SongEnd
;}

; $724E
song_title_wave_section6:
;{
    SongOptions
        WaveOptions $418B, 1, $0
    SongNoteLength_Quaver
    SongRest
    SongNoteLength_DottedQuaver
    SongNote "E5"
    SongNoteLength_Quaver
    Echo2
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    SongNote "F5"
    SongNoteLength_Semiquaver
    SongRest
    Echo2
    SongNoteLength_Quaver
    SongNote "G5"
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo2
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Semiquaver
    SongNote "F5"
    Echo1
    SongNote "E5"
    Echo1
    SongNoteLength_Quaver
    SongNote "F5"
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo2
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Semiquaver
    SongNote "E5"
    Echo1
    SongNote "D5"
    Echo1
    SongNoteLength_Quaver
    SongNote "C5"
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo2
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Semiquaver
    SongNote "C5"
    Echo1
    SongNote "D5"
    Echo1
    SongNoteLength_Quaver
    SongNote "C5"
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo2
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    SongNote "D5"
    SongNoteLength_Semiquaver
    SongRest
    Echo2
    SongNoteLength_Quaver
    SongNote "C5"
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo2
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    SongNote "C5"
    SongNoteLength_Semiquaver
    SongRest
    Echo2
    SongNoteLength_Quaver
    SongNote "C5"
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo2
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Semiquaver
    SongNote "B4"
    Echo1
    SongNote "A4"
    Echo1
    SongNoteLength_Quaver
    SongNote "B4"
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo2
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Semiquaver
    SongNote "C5"
    Echo1
    SongNote "D5"
    SongOptions
        WaveOptions $418B, 1, $0
    SongNoteLength_Semiquaver
    Echo1
    SongNoteLength_DottedQuaver
    SongNote "E5"
    SongNoteLength_Quaver
    Echo2
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    SongNote "F5"
    SongNoteLength_Semiquaver
    SongRest
    Echo2
    SongNoteLength_Quaver
    SongNote "G5"
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo2
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Semiquaver
    SongNote "F5"
    Echo1
    SongNote "E5"
    Echo1
    SongNoteLength_Quaver
    SongNote "F5"
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo2
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Semiquaver
    SongNote "E5"
    Echo1
    SongNote "D5"
    Echo1
    SongNoteLength_Quaver
    SongNote "C5"
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo2
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Semiquaver
    SongNote "B4"
    Echo1
    SongNote "A4"
    Echo1
    SongNoteLength_Quaver
    SongNote "B4"
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo2
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    SongNote "A4"
    SongNoteLength_Semiquaver
    SongRest
    Echo2
    SongNoteLength_Quaver
    SongNote "B4"
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo2
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Semiquaver
    SongNote "Bb4"
    Echo1
    SongNote "A4"
    Echo1
    SongNoteLength_Quaver
    SongNote "G4"
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo2
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    SongNote "F4"
    SongNoteLength_Semiquaver
    SongRest
    Echo2
    SongNoteLength_Quaver
    SongNote "G4"
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Demisemiquaver
    Echo2
    SongNoteLength_Quaver
    SongNote "G4"
    SongNoteLength_Semiquaver
    SongRest
    SongNote "G4"
    SongRest
    SongNote "G4"
    SongRest
    SongNote "Ab4"
    SongNoteLength_Demisemiquaver
    SongRest
    SongNote "Ab4"
    SongRest
    SongNote "Ab4"
    SongRest
    SongNote "A4"
    SongRest
    SongNote "A4"
    SongRest
    SongNote "Bb4"
    SongRest
    SongNote "B4"
    SongRest
    SongNote "C5"
    SongRest
    SongEnd
;}

; $73B0
song_title_wave_section7:
;{
    SongOptions
        WaveOptions $416B, 1, $0
    SongNoteLength_Semiquaver
    Echo1
    SongNoteLength_Quaver
    SongNote "C3"
    Echo1
    SongNote "C3"
    Echo1
    SongRepeatSetup $8
        SongNoteLength_Quaver
        SongNote "C3"
        Echo1
        SongNote "C3"
        Echo1
        SongNote "C3"
        Echo1
    SongRepeat
    SongOptions
        WaveOptions $416B, 2, $0
    SongRepeatSetup $3
        SongNoteLength_Quaver
        SongNote "C3"
        Echo1
        SongNote "C3"
        Echo1
        SongNote "C3"
        Echo1
    SongRepeat
    SongOptions
        WaveOptions $416B, 3, $0
    SongRepeatSetup $5
        SongNoteLength_Quaver
        SongNote "C3"
        Echo1
        SongNote "C3"
        Echo1
        SongNote "C3"
        Echo1
    SongRepeat
    SongRepeatSetup $B
        SongNoteLength_Semibreve
        SongRest
    SongRepeat
    SongNoteLength_DottedMinum
    SongRest
    SongEnd
;}

; $73E9
song_title_noise_section6:
;{
    SongRepeatSetup $8
        SongNoteLength_Semibreve
        SongRest
    SongRepeat
    SongEnd
;}

; $73EF
song_title_noise_section7:
;{
    SongRepeatSetup $8
        SongNoteLength_Semibreve
        SongRest
    SongRepeat
    SongNoteLength_Quaver
    SongRest
    SongNoteLength_Minum
    SongRest
    SongNoteLength_Semibreve
    SongNoiseNote $8
    SongRest
    SongRest
    SongNoiseNote $8
    SongRest
    SongRest
    SongNoteLength_DottedCrochet
    SongNoiseNote $8
    SongNoteLength_Semiquaver
    SongRest
    SongNoteLength_Quaver
    SongNoiseNote $1F
    SongRest
    SongNoiseNote $20
    SongRest
    SongNoiseNote $21
    SongRest
    SongNoteLength_DottedQuaver
    SongNoiseNote $21
    SongNoteLength_Quaver
    SongRest
    SongEnd
;}

; $740F
song_title_noise_section8:
;{
    SongRepeatSetup $5
        SongNoteLength_DottedMinum
        SongNoiseNote $8
        SongNoiseNote $C
        SongNoiseNote $8
    SongRepeat
    SongNoiseNote $8
    SongNoiseNote $C
    SongNoiseNote $8
    SongNoiseNote $C
    SongNoiseNote $9
    SongNoiseNote $9
    SongNoiseNote $E
    SongNoiseNote $A
    SongNoiseNote $A
    SongNoiseNote $F
    SongNoiseNote $F
    SongRepeatSetup $5
        SongNoteLength_Semibreve
        SongRest
    SongRepeat
    SongEnd
;}

; $7427
song_samusFanfare_header:
    SongHeader $1, $40DF, song_samusFanfare_toneSweep, song_samusFanfare_tone, song_samusFanfare_wave, song_samusFanfare_noise

; $7432
song_samusFanfare_tone:
song_samusFanfare_toneSweep:
;{
    dw song_samusFanfare_toneSweep_section0 ; $743E
    dw $0000
;}

; $7436
song_samusFanfare_wave:
;{
    dw song_samusFanfare_wave_section0 ; $7462
    dw $0000
;}

; $743A
song_samusFanfare_noise:
;{
    dw song_samusFanfare_noise_section0 ; $747A
    dw $0000
;}

; $743E
song_samusFanfare_toneSweep_section0:
;{
    SongOptions
        AscendingEnvelopeOptions 3, $0
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 1
    SongNoteLength_DottedCrochet
    SongNote "G2"
    Echo1
    SongNoteLength_Semiquaver
    SongRest
    SongOptions
        AscendingEnvelopeOptions 1, $0
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 1
    SongNoteLength_DottedQuaver
    SongNote "G3"
    SongNoteLength_Semiquaver
    Echo1
    SongNoteLength_DottedQuaver
    SongNote "G4"
    SongNoteLength_Semiquaver
    Echo1
    SongNoteLength_DottedQuaver
    SongNote "Gb4"
    SongNoteLength_Semiquaver
    Echo1
    SongNoteLength_Demisemiquaver
    SongRest
    SongNoteLength_DottedQuaver
    SongNote "D4"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Minum
    SongNote "E4"
    SongNoteLength_Semibreve
    Echo1
    SongEnd
;}

; $7462
song_samusFanfare_wave_section0:
;{
    SongOptions
        WaveOptions $417B, 2, $0
    SongNoteLength_DottedMinum
    SongRest
    SongNoteLength_Quaver
    SongRest
    SongNoteLength_DottedCrochet
    SongNote "C6"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_DottedCrochet
    SongNote "D6"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongRest
    SongRest
    SongNoteLength_Minum
    SongNote "A5"
    SongNoteLength_Quaver
    Echo1
    SongEnd
;}

; $747A
song_samusFanfare_noise_section0:
;{
    SongNoteLength_DottedCrochet
    SongNoiseNote $12
    SongNoiseNote $1D
    SongNoiseNote $12
    SongNoteLength_DottedQuaver
    SongNoiseNote $17
    SongNoiseNote $15
    SongNoiseNote $13
    SongNoiseNote $14
    SongNoteLength_Quaver
    SongNoiseNote $16
    SongNoteLength_Crochet
    SongNoiseNote $1A
    SongNoteLength_Breve
    SongNoiseNote $1B
    SongEnd
;}

; $748A
song_reachedTheGunship_header:
    SongHeader $0, $40F9, song_reachedTheGunship_toneSweep, song_reachedTheGunship_tone, song_reachedTheGunship_wave, song_reachedTheGunship_noise

; $7495
song_reachedTheGunship_toneSweep:
;{
    dw song_reachedTheGunship_toneSweep_section0 ; $74F1
    dw song_reachedTheGunship_toneSweep_section1 ; $79CB
    dw song_reachedTheGunship_toneSweep_section2 ; $74F9
    dw song_reachedTheGunship_toneSweep_section3 ; $76BA
    dw song_reachedTheGunship_toneSweep_section4 ; $74FE
    dw song_reachedTheGunship_toneSweep_section5 ; $7523
    dw song_reachedTheGunship_toneSweep_section6 ; $758C
    dw song_reachedTheGunship_toneSweep_section7 ; $75C5
    dw song_reachedTheGunship_toneSweep_section8 ; $75C5
    dw song_reachedTheGunship_toneSweep_section9 ; $75C5
    dw song_reachedTheGunship_toneSweep_sectionA ; $75C5
    dw song_reachedTheGunship_toneSweep_sectionB ; $75EA
    dw song_reachedTheGunship_toneSweep_sectionC ; $7613
    dw song_reachedTheGunship_toneSweep_sectionD ; $762C
    dw $0000
;}

; $74B3
song_reachedTheGunship_tone:
;{
    dw song_reachedTheGunship_tone_section0 ; $76AE
    dw song_reachedTheGunship_tone_section1 ; $79CB
    dw song_reachedTheGunship_tone_section2 ; $76B6
    dw song_reachedTheGunship_tone_section3 ; $7745
    dw song_reachedTheGunship_tone_section4 ; $7759
    dw song_reachedTheGunship_tone_section5 ; $77BE
    dw song_reachedTheGunship_tone_section6 ; $7819
    dw song_reachedTheGunship_tone_section7 ; $785B
    dw song_reachedTheGunship_tone_section8 ; $7891
    dw song_reachedTheGunship_tone_section9 ; $78E6
    dw $0000
;}

; $74C9
song_reachedTheGunship_wave:
;{
    dw song_reachedTheGunship_wave_section0 ; $79A3
    dw song_reachedTheGunship_wave_section1 ; $7A0D
    dw song_reachedTheGunship_wave_section2 ; $7A56
    dw song_reachedTheGunship_wave_section3 ; $7A6B
    dw song_reachedTheGunship_wave_section4 ; $7A81
    dw song_reachedTheGunship_wave_section5 ; $7A8C
    dw song_reachedTheGunship_wave_section6 ; $7A95
    dw song_reachedTheGunship_wave_section7 ; $7A9E
    dw song_reachedTheGunship_wave_section8 ; $7AAB
    dw $0000
;}

; $74DD
song_reachedTheGunship_noise:
;{
    dw song_reachedTheGunship_noise_section0 ; $7B1E
    dw song_reachedTheGunship_noise_section1 ; $7B4B
    dw song_reachedTheGunship_noise_section2 ; $7B75
    dw song_reachedTheGunship_noise_section3 ; $7B8D
    dw song_reachedTheGunship_noise_section4 ; $7BAE
    dw song_reachedTheGunship_noise_section5 ; $7BC4
    dw song_reachedTheGunship_noise_section6 ; $7BDA
    dw song_reachedTheGunship_noise_section7 ; $7BEC
    dw song_reachedTheGunship_noise_section8 ; $7BFE
    dw $0000
;}

; $74F1
song_reachedTheGunship_toneSweep_section0:
;{
    SongOptions
        DescendingEnvelopeOptions 0, $6
        AscendingSweepOptions 0, 0
        LengthDutyOptions $9, 0
    SongNoteLength_Semibreve
    SongRest
    SongRest
    SongEnd
;}

; $74F9
song_reachedTheGunship_toneSweep_section2:
;{
    SongOptions
        DescendingEnvelopeOptions 0, $B
        AscendingSweepOptions 0, 0
        LengthDutyOptions $9, 1
    SongEnd
;}

; $74FE
song_reachedTheGunship_toneSweep_section4:
;{
    SongOptions
        DescendingEnvelopeOptions 2, $5
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 1
    SongRepeatSetup $2
        SongNoteLength_Semiquaver
        SongNote "C5"
        SongNote "F5"
        SongNote "G5"
        SongNote "C6"
    SongRepeat
    SongRepeatSetup $2
        SongNoteLength_Semiquaver
        SongNote "F4"
        SongNote "C5"
        SongNote "D5"
        SongNote "F5"
    SongRepeat
    SongRepeatSetup $2
        SongNoteLength_Semiquaver
        SongNote "C5"
        SongNote "F5"
        SongNote "G5"
        SongNote "C6"
    SongRepeat
    SongRepeatSetup $2
        SongNoteLength_Semiquaver
        SongNote "F4"
        SongNote "C5"
        SongNote "D5"
        SongNote "F5"
    SongRepeat
    SongEnd
;}

; $7523
song_reachedTheGunship_toneSweep_section5:
;{
    SongOptions
        DescendingEnvelopeOptions 1, $5
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 1
    SongRepeatSetup $2
        SongNoteLength_Semiquaver
        SongNote "C5"
        SongNote "F5"
        SongNote "G5"
        SongNote "C6"
    SongRepeat
    SongRepeatSetup $2
        SongNoteLength_Semiquaver
        SongNote "F4"
        SongNote "C5"
        SongNote "D5"
        SongNote "F5"
    SongRepeat
    SongRepeatSetup $2
        SongNoteLength_Semiquaver
        SongNote "C5"
        SongNote "E5"
        SongNote "F5"
        SongNote "C6"
    SongRepeat
    SongRepeatSetup $2
        SongNoteLength_Semiquaver
        SongNote "D5"
        SongNote "E5"
        SongNote "F5"
        SongNote "D6"
    SongRepeat
    SongRepeatSetup $2
        SongNoteLength_Semiquaver
        SongNote "C5"
        SongNote "F5"
        SongNote "G5"
        SongNote "C6"
    SongRepeat
    SongRepeatSetup $2
        SongNoteLength_Semiquaver
        SongNote "F4"
        SongNote "C5"
        SongNote "D5"
        SongNote "F5"
    SongRepeat
    SongRepeatSetup $2
        SongNoteLength_Semiquaver
        SongNote "G4"
        SongNote "C5"
        SongNote "D5"
        SongNote "G5"
    SongRepeat
    SongRepeatSetup $2
        SongNoteLength_Semiquaver
        SongNote "F4"
        SongNote "C5"
        SongNote "D5"
        SongNote "F5"
    SongRepeat
    SongRepeatSetup $2
        SongNoteLength_Semiquaver
        SongNote "C5"
        SongNote "E5"
        SongNote "F5"
        SongNote "C6"
        SongNote "C5"
        SongNote "E5"
        SongNote "F5"
        SongNote "C6"
        SongNote "F4"
        SongNote "C5"
        SongNote "D5"
        SongNote "F5"
        SongNote "F4"
        SongNote "C5"
        SongNote "D5"
        SongNote "F5"
        SongNote "C5"
        SongNote "E5"
        SongNote "F5"
        SongNote "C6"
        SongNote "C5"
        SongNote "E5"
        SongNote "F5"
        SongNote "C6"
        SongNote "D5"
        SongNote "E5"
        SongNote "F5"
        SongNote "D6"
        SongNote "D5"
        SongNote "E5"
        SongNote "F5"
        SongNote "D6"
    SongRepeat
    SongEnd
;}

; $758C
song_reachedTheGunship_toneSweep_section6:
;{
    SongOptions
        DescendingEnvelopeOptions 1, $8
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
    SongRepeatSetup $3
        SongNoteLength_Semiquaver
        SongNote "C5"
        SongNote "E5"
        SongNote "F5"
        SongNote "C6"
        SongNote "C5"
        SongNote "E5"
        SongNote "F5"
        SongNote "C6"
        SongNote "Bb4"
        SongNote "E5"
        SongNote "F5"
        SongNote "Bb5"
        SongNote "Bb4"
        SongNote "E5"
        SongNote "F5"
        SongNote "Bb5"
    SongRepeat
    SongRepeatSetup $2
        SongNoteLength_Semiquaver
        SongNote "F4"
        SongNote "C5"
        SongNote "D5"
        SongNote "F5"
    SongRepeat
    SongRepeatSetup $2
        SongNoteLength_Semiquaver
        SongNote "Bb4"
        SongNote "E5"
        SongNote "F5"
        SongNote "Bb5"
    SongRepeat
    SongRepeatSetup $2
        SongNoteLength_Semiquaver
        SongNote "A4"
        SongNote "E5"
        SongNote "F5"
        SongNote "A5"
    SongRepeat
    SongRepeatSetup $2
        SongNoteLength_Semiquaver
        SongNote "G4"
        SongNote "C5"
        SongNote "D5"
        SongNote "E5"
    SongRepeat
    SongEnd
;}

; $75C5
song_reachedTheGunship_toneSweep_section9:
song_reachedTheGunship_toneSweep_sectionA:
song_reachedTheGunship_toneSweep_section7:
song_reachedTheGunship_toneSweep_section8:
;{
    SongOptions
        DescendingEnvelopeOptions 1, $6
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 1
    SongRepeatSetup $2
        SongNoteLength_Semiquaver
        SongNote "F4"
        SongNote "C5"
        SongNote "D5"
        SongNote "F5"
    SongRepeat
    SongRepeatSetup $2
        SongNoteLength_Semiquaver
        SongNote "Bb4"
        SongNote "E5"
        SongNote "F5"
        SongNote "Bb5"
    SongRepeat
    SongRepeatSetup $2
        SongNoteLength_Semiquaver
        SongNote "A4"
        SongNote "E5"
        SongNote "F5"
        SongNote "A5"
    SongRepeat
    SongRepeatSetup $2
        SongNoteLength_Semiquaver
        SongNote "G4"
        SongNote "C5"
        SongNote "D5"
        SongNote "E5"
    SongRepeat
    SongEnd
;}

; $75EA
song_reachedTheGunship_toneSweep_sectionB:
;{
    SongOptions
        DescendingEnvelopeOptions 3, $4
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 2
    SongRepeatSetup $4
        SongNoteLength_Semiquaver
        SongNote "F4"
        SongNote "A4"
        SongNote "D5"
        SongNote "F5"
        SongNote "F4"
        SongNote "A4"
        SongNote "D5"
        SongNote "F5"
        SongNote "Bb4"
        SongNote "E5"
        SongNote "F5"
        SongNote "Bb5"
        SongNote "Bb4"
        SongNote "E5"
        SongNote "F5"
        SongNote "Bb5"
        SongNote "A4"
        SongNote "E5"
        SongNote "F5"
        SongNote "A5"
        SongNote "A4"
        SongNote "E5"
        SongNote "F5"
        SongNote "A5"
        SongNote "G4"
        SongNote "C5"
        SongNote "D5"
        SongNote "E5"
        SongNote "G4"
        SongNote "C5"
        SongNote "D5"
        SongNote "E5"
    SongRepeat
    SongEnd
;}

; $7613
song_reachedTheGunship_toneSweep_sectionC:
;{
    SongOptions
        DescendingEnvelopeOptions 2, $7
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
    SongRepeatSetup $4
        SongNoteLength_Semiquaver
        SongNote "C5"
        SongNote "E5"
        SongNote "F5"
        SongNote "C6"
        SongNote "C5"
        SongNote "E5"
        SongNote "F5"
        SongNote "C6"
        SongNote "Bb4"
        SongNote "E5"
        SongNote "F5"
        SongNote "Bb5"
        SongNote "Bb4"
        SongNote "E5"
        SongNote "F5"
        SongNote "Bb5"
    SongRepeat
    SongEnd
;}

; $762C
song_reachedTheGunship_toneSweep_sectionD:
;{
    SongOptions
        DescendingEnvelopeOptions 2, $8
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
    SongNoteLength_Semiquaver
    SongNote "C5"
    SongNote "E5"
    SongNote "F5"
    SongNote "C6"
    SongNote "C5"
    SongNote "E5"
    SongNote "F5"
    SongNote "C6"
    SongNote "F4"
    SongNote "C5"
    SongNote "D5"
    SongNote "F5"
    SongNote "F4"
    SongNote "C5"
    SongNote "D5"
    SongNote "F5"
    SongNote "C5"
    SongNote "E5"
    SongNote "F5"
    SongNote "C6"
    SongNote "C5"
    SongNote "E5"
    SongNote "F5"
    SongNote "C6"
    SongNote "D5"
    SongNote "E5"
    SongNote "F5"
    SongNote "D6"
    SongNote "D5"
    SongNote "E5"
    SongNote "F5"
    SongNote "D6"
    SongOptions
        DescendingEnvelopeOptions 2, $A
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
    SongRepeatSetup $5
        SongNoteLength_Semiquaver
        SongNote "C5"
        SongNote "E5"
        SongNote "F5"
        SongNote "C5"
        SongNote "C5"
        SongNote "E5"
        SongNote "F5"
        SongNote "C5"
        SongNote "F4"
        SongNote "C5"
        SongNote "D5"
        SongNote "F5"
        SongNote "F4"
        SongNote "C5"
        SongNote "D5"
        SongNote "F5"
    SongRepeat
    SongOptions
        DescendingEnvelopeOptions 3, $C
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
    SongNoteLength_Semiquaver
    SongNote "C5"
    SongNote "E5"
    SongNote "F5"
    SongNote "C6"
    SongNote "C5"
    SongNote "E5"
    SongNote "F5"
    SongNote "C6"
    SongNote "F4"
    SongNote "C5"
    SongNote "D5"
    SongNote "F5"
    SongNote "F4"
    SongNote "C5"
    SongNote "D5"
    SongNote "F5"
    SongOptions
        DescendingEnvelopeOptions 4, $D
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
    SongNoteLength_Quaver
    SongNote "C5"
    SongNoteLength_Semiquaver
    Echo1
    SongNoteLength_Quaver
    SongNote "B4"
    SongNoteLength_Semiquaver
    Echo1
    SongNote "C5"
    Echo1
    SongTempo $4106
    SongNoteLength_Minum
    SongNote "F5"
    SongOptions
        AscendingEnvelopeOptions 1, $0
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
    SongNoteLength_Quaver
    SongNote "E5"
    Echo1
    SongOptions
        DescendingEnvelopeOptions 5, $D
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 1
    SongNoteLength_Semiquaver
    SongNote "C5"
    Echo1
    SongNoteLength_Demisemiquaver
    SongNote "C5"
    Echo1
    SongNote "C5"
    Echo1
    SongNoteLength_Hemidemisemiquaver
    SongNote "C4"
    SongNote "G4"
    SongOptions
        DescendingEnvelopeOptions 7, $C
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
    SongNoteLength_Semibreve
    SongNote "C6"
    SongEnd
;}

; $76AE
song_reachedTheGunship_tone_section0:
;{
    SongOptions
        DescendingEnvelopeOptions 0, $6
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
    SongNoteLength_Semibreve
    SongRest
    SongRest
    SongEnd
;}

; $76B6
song_reachedTheGunship_tone_section2:
;{
    SongOptions
        DescendingEnvelopeOptions 0, $B
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
;}

; $76BA
song_reachedTheGunship_toneSweep_section3:
;{
    SongNoteLength_Crochet
    SongNote "E5"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Demisemiquaver
    SongNote "F5"
    Echo1
    SongNote "E5"
    Echo1
    SongNoteLength_Semiquaver
    SongNote "D5"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongNote "C5"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongNote "Bb4"
    Echo1
    SongNoteLength_Quaver
    SongNote "C5"
    Echo1
    SongNote "F4"
    Echo1
    SongNoteLength_Crochet
    SongNote "F5"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Demisemiquaver
    SongNote "E5"
    Echo1
    SongNote "D5"
    Echo1
    SongNoteLength_Crochet
    SongNote "E5"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongNote "D5"
    Echo1
    SongNoteLength_Quaver
    SongNote "D5"
    Echo1
    SongNote "A4"
    Echo1
    SongNoteLength_Crochet
    SongNote "C5"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Demisemiquaver
    SongNote "B4"
    Echo1
    SongNote "A4"
    Echo1
    SongNoteLength_Crochet
    SongNote "B4"
    Echo1
    SongNoteLength_Crochet
    SongNote "E5"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Demisemiquaver
    SongNote "F5"
    Echo1
    SongNote "E5"
    Echo1
    SongNoteLength_Semiquaver
    SongNote "D5"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongNote "C5"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongNote "Bb4"
    Echo1
    SongNoteLength_Crochet
    SongNote "C5"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Demisemiquaver
    SongNote "D5"
    Echo1
    SongNote "E5"
    Echo1
    SongNoteLength_Crochet
    SongNote "F5"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Demisemiquaver
    SongNote "G5"
    Echo1
    SongNote "F5"
    Echo1
    SongNoteLength_Crochet
    SongNote "E5"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongNote "D5"
    Echo1
    SongNoteLength_Quaver
    SongNote "D5"
    Echo1
    SongNote "A4"
    Echo1
    SongNoteLength_Crochet
    SongNote "C5"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Demisemiquaver
    SongNote "B4"
    Echo1
    SongNote "C5"
    Echo1
    SongNoteLength_Quaver
    SongNote "D5"
    Echo1
    SongNote "A4"
    Echo1
    SongNoteLength_Crochet
    SongNote "C5"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Demisemiquaver
    SongNote "B4"
    Echo1
    SongNote "A4"
    Echo1
    SongNoteLength_Crochet
    SongNote "B4"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongNote "G5"
    Echo1
    SongEnd
;}

; $7745
song_reachedTheGunship_tone_section3:
;{
    SongOptions
        DescendingEnvelopeOptions 0, $A
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
    SongNoteLength_DottedCrochet
    SongNote "C6"
    SongNoteLength_Minum
    Echo1
    SongNoteLength_Semiquaver
    SongNote "G4"
    Echo1
    SongNoteLength_DottedCrochet
    SongNote "C6"
    Echo1
    SongNoteLength_Semiquaver
    SongNote "C3"
    Echo1
    SongRest
    SongRest
    SongEnd
;}

; $7759
song_reachedTheGunship_tone_section4:
;{
    SongOptions
        DescendingEnvelopeOptions 0, $C
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 1
    SongNoteLength_Crochet
    SongNote "C5"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongNote "C5"
    Echo1
    SongNoteLength_Quaver
    SongNote "Bb4"
    SongNoteLength_Semiquaver
    Echo1
    SongNoteLength_Quaver
    SongNote "A4"
    SongNoteLength_Semiquaver
    Echo1
    SongNoteLength_Demisemiquaver
    SongNote "G4"
    Echo1
    SongNote "F4"
    Echo1
    SongNoteLength_Crochet
    SongNote "G4"
    SongNoteLength_DottedMinum
    Echo1
    SongNoteLength_Crochet
    SongNote "E4"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongNote "G4"
    Echo1
    SongNoteLength_Quaver
    SongNote "F4"
    SongNoteLength_Semiquaver
    Echo1
    SongNoteLength_Quaver
    SongNote "E4"
    SongNoteLength_Semiquaver
    Echo1
    SongNoteLength_Demisemiquaver
    SongNote "D4"
    Echo1
    SongNote "C4"
    Echo1
    SongNoteLength_Crochet
    SongNote "D4"
    SongNoteLength_DottedMinum
    Echo1
    SongNoteLength_Crochet
    SongNote "G4"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongNote "C5"
    Echo1
    SongNoteLength_Quaver
    SongNote "Bb4"
    SongNoteLength_Semiquaver
    Echo1
    SongNoteLength_Quaver
    SongNote "A4"
    SongNoteLength_Semiquaver
    Echo1
    SongNoteLength_Demisemiquaver
    SongNote "G4"
    Echo1
    SongNote "F4"
    Echo1
    SongNoteLength_Crochet
    SongNote "G4"
    SongNoteLength_DottedMinum
    Echo1
    SongNoteLength_Crochet
    SongNote "G4"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongNote "C5"
    Echo1
    SongNoteLength_Quaver
    SongNote "F4"
    SongNoteLength_Semiquaver
    Echo1
    SongNoteLength_Quaver
    SongNote "G4"
    SongNoteLength_Semiquaver
    Echo1
    SongNoteLength_Demisemiquaver
    SongNote "A4"
    Echo1
    SongNote "F4"
    Echo1
    SongNoteLength_Crochet
    SongNote "G4"
    SongNoteLength_DottedMinum
    Echo1
    SongEnd
;}

; $77BE
song_reachedTheGunship_tone_section5:
;{
    SongOptions
        DescendingEnvelopeOptions 0, $B
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 1
    SongNoteLength_Crochet
    SongNote "E5"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Demisemiquaver
    SongNote "D5"
    Echo1
    SongNote "E5"
    Echo1
    SongNoteLength_Crochet
    SongNote "F5"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Demisemiquaver
    SongNote "E5"
    Echo1
    SongNote "D5"
    Echo1
    SongNoteLength_Crochet
    SongNote "E5"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Demisemiquaver
    SongNote "D5"
    Echo1
    SongNote "E5"
    Echo1
    SongNoteLength_Crochet
    SongNote "F5"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Demisemiquaver
    SongNote "E5"
    Echo1
    SongNote "F5"
    Echo1
    SongNoteLength_Crochet
    SongNote "G5"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Demisemiquaver
    SongNote "F5"
    Echo1
    SongNote "E5"
    Echo1
    SongNoteLength_Crochet
    SongNote "F5"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Demisemiquaver
    SongNote "E5"
    Echo1
    SongNote "D5"
    Echo1
    SongNoteLength_DottedQuaver
    SongNote "C5"
    Echo1
    SongNoteLength_Demisemiquaver
    SongNote "D5"
    Echo1
    SongNote "E5"
    Echo1
    SongNoteLength_DottedQuaver
    SongNote "D5"
    Echo1
    SongNoteLength_Demisemiquaver
    SongNote "C5"
    Echo1
    SongNote "Bb4"
    Echo1
    SongNoteLength_DottedQuaver
    SongNote "C5"
    Echo1
    SongNoteLength_Demisemiquaver
    SongNote "Bb4"
    Echo1
    SongNote "A4"
    Echo1
    SongNoteLength_DottedQuaver
    SongNote "Bb4"
    Echo1
    SongNoteLength_Demisemiquaver
    SongNote "A4"
    Echo1
    SongNote "G4"
    Echo1
    SongEnd
;}

; $7819
song_reachedTheGunship_tone_section6:
;{
    SongOptions
        DescendingEnvelopeOptions 0, $D
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
    SongRepeatSetup $2
        SongNoteLength_Quaver
        SongNote "C5"
        Echo1
        SongNote "G5"
        Echo1
        SongNoteLength_Crochet
        SongNote "F5"
        SongNoteLength_Quaver
        Echo1
        SongNoteLength_Semiquaver
        SongNote "C5"
        Echo1
        SongNoteLength_Crochet
        SongNote "C5"
        SongNoteLength_Quaver
        Echo1
        SongNoteLength_Demisemiquaver
        SongNote "Bb4"
        Echo1
        SongNote "A4"
        Echo1
        SongNoteLength_Crochet
        SongNote "Bb4"
        SongNoteLength_Quaver
        Echo1
        SongNoteLength_Semiquaver
        SongNote "D5"
        Echo1
        SongNoteLength_Quaver
        SongNote "C5"
        Echo1
        SongNote "G5"
        Echo1
        SongNoteLength_Crochet
        SongNote "F5"
        SongNoteLength_Quaver
        Echo1
        SongNoteLength_Semiquaver
        SongNote "C5"
        Echo1
        SongNoteLength_Crochet
        SongNote "C5"
        SongNoteLength_Quaver
        Echo1
        SongNoteLength_Demisemiquaver
        SongNote "Bb4"
        Echo1
        SongNote "A4"
        Echo1
        SongNoteLength_Crochet
        SongNote "Bb4"
        SongNoteLength_Quaver
        Echo1
        SongNoteLength_Demisemiquaver
        SongNote "A4"
        Echo1
        SongNote "G4"
        Echo1
    SongRepeat
    SongEnd
;}

; $785B
song_reachedTheGunship_tone_section7:
;{
    SongOptions
        DescendingEnvelopeOptions 0, $A
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 2
    SongRepeatSetup $2
        SongNoteLength_Crochet
        SongNote "C6"
        SongNoteLength_Minum
        Echo1
        SongNoteLength_Quaver
        SongRest
        SongNoteLength_Semiquaver
        SongNote "D6"
        Echo1
        SongNoteLength_DottedQuaver
        SongNote "C6"
        Echo1
        SongNoteLength_Demisemiquaver
        SongNote "Bb5"
        Echo1
        SongNote "A5"
        Echo1
        SongNoteLength_DottedQuaver
        SongNote "Bb5"
        Echo1
        SongNoteLength_Semiquaver
        SongNote "A5"
        Echo1
        SongNoteLength_DottedQuaver
        SongNote "A5"
        SongNoteLength_Minum
        Echo1
        SongNoteLength_DottedQuaver
        SongRest
        SongNoteLength_Semiquaver
        SongNote "Bb5"
        Echo1
        SongNoteLength_Quaver
        SongNote "F5"
        SongNoteLength_Crochet
        Echo1
        SongNoteLength_Semiquaver
        SongNote "G5"
        Echo1
        SongNoteLength_Quaver
        SongNote "A5"
        SongNoteLength_Crochet
        Echo1
        SongNoteLength_Semiquaver
        SongNote "Bb5"
        Echo1
    SongRepeat
    SongEnd
;}

; $7891
song_reachedTheGunship_tone_section8:
;{
    SongOptions
        DescendingEnvelopeOptions 0, $D
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
    SongNoteLength_Crochet
    SongNote "E4"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Demisemiquaver
    SongNote "F4"
    Echo1
    SongNote "E4"
    Echo1
    SongNoteLength_Quaver
    SongNote "D4"
    SongNoteLength_Semiquaver
    Echo1
    SongNoteLength_Quaver
    SongNote "C4"
    SongNoteLength_Semiquaver
    Echo1
    SongNoteLength_Semiquaver
    SongNote "Bb3"
    Echo1
    SongNoteLength_Crochet
    SongNote "G4"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Demisemiquaver
    SongNote "A4"
    Echo1
    SongNote "G4"
    Echo1
    SongNoteLength_Quaver
    SongNote "F4"
    SongNoteLength_Semiquaver
    Echo1
    SongNoteLength_Quaver
    SongNote "E4"
    SongNoteLength_Semiquaver
    Echo1
    SongNoteLength_Semiquaver
    SongNote "D4"
    Echo1
    SongNoteLength_Crochet
    SongNote "E4"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Demisemiquaver
    SongNote "F4"
    Echo1
    SongNote "E4"
    Echo1
    SongNoteLength_Quaver
    SongNote "D4"
    SongNoteLength_Semiquaver
    Echo1
    SongNoteLength_Quaver
    SongNote "E4"
    SongNoteLength_Semiquaver
    Echo1
    SongNoteLength_Semiquaver
    SongNote "F4"
    Echo1
    SongNoteLength_Crochet
    SongNote "G4"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Demisemiquaver
    SongNote "A4"
    Echo1
    SongNote "G4"
    Echo1
    SongNoteLength_Quaver
    SongNote "F4"
    SongNoteLength_Semiquaver
    Echo1
    SongNoteLength_Quaver
    SongNote "G4"
    SongNoteLength_Semiquaver
    Echo1
    SongNoteLength_Semiquaver
    SongNote "A4"
    Echo1
    SongEnd
;}

; $78E6
song_reachedTheGunship_tone_section9:
;{
    SongOptions
        DescendingEnvelopeOptions 0, $B
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 1
    SongNoteLength_Crochet
    SongNote "G4"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongNote "C5"
    Echo1
    SongNoteLength_Quaver
    SongNote "A4"
    SongNoteLength_Semiquaver
    Echo1
    SongNoteLength_Quaver
    SongNote "G4"
    SongNoteLength_Semiquaver
    Echo1
    SongNoteLength_Semiquaver
    SongNote "F4"
    Echo1
    SongNoteLength_Crochet
    SongNote "G4"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongNote "C5"
    Echo1
    SongNoteLength_Quaver
    SongNote "A4"
    SongNoteLength_Semiquaver
    Echo1
    SongNoteLength_Quaver
    SongNote "C5"
    SongNoteLength_Semiquaver
    Echo1
    SongNoteLength_Semiquaver
    SongNote "F5"
    Echo1
    SongNoteLength_Crochet
    SongNote "G4"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongNote "C5"
    Echo1
    SongNoteLength_Quaver
    SongNote "A4"
    SongNoteLength_Semiquaver
    Echo1
    SongNoteLength_Quaver
    SongNote "G4"
    SongNoteLength_Semiquaver
    Echo1
    SongNoteLength_Semiquaver
    SongNote "F4"
    Echo1
    SongNoteLength_Crochet
    SongNote "G4"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongNote "C5"
    Echo1
    SongNoteLength_Quaver
    SongNote "A4"
    SongNoteLength_Semiquaver
    Echo1
    SongNoteLength_Quaver
    SongNote "C5"
    SongNoteLength_Semiquaver
    Echo1
    SongNoteLength_Semiquaver
    SongNote "F5"
    Echo1
    SongNoteLength_Crochet
    SongNote "E5"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongNote "G5"
    Echo1
    SongNoteLength_Quaver
    SongNote "F5"
    SongNoteLength_Semiquaver
    Echo1
    SongNoteLength_Quaver
    SongNote "E5"
    SongNoteLength_Semiquaver
    Echo1
    SongNote "C5"
    Echo1
    SongNoteLength_Crochet
    SongNote "E5"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongNote "G5"
    Echo1
    SongNoteLength_Quaver
    SongNote "F5"
    SongNoteLength_Semiquaver
    Echo1
    SongNoteLength_Quaver
    SongNote "A5"
    SongNoteLength_Semiquaver
    Echo1
    SongNote "C6"
    Echo1
    SongNoteLength_Crochet
    SongNote "E5"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongNote "G5"
    Echo1
    SongNoteLength_Quaver
    SongNote "F5"
    SongNoteLength_Semiquaver
    Echo1
    SongNoteLength_Quaver
    SongNote "E5"
    SongNoteLength_Semiquaver
    Echo1
    SongNote "C5"
    Echo1
    SongOptions
        DescendingEnvelopeOptions 0, $D
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
    SongNoteLength_Quaver
    SongNote "F4"
    SongNoteLength_Semiquaver
    Echo1
    SongNoteLength_Quaver
    SongNote "E4"
    SongNoteLength_Semiquaver
    Echo1
    SongNote "C4"
    Echo1
    SongNoteLength_Quaver
    SongNote "F5"
    SongNoteLength_Semiquaver
    Echo1
    SongNoteLength_Quaver
    SongNote "E5"
    SongNoteLength_Semiquaver
    Echo1
    SongNote "C5"
    Echo1
    SongNoteLength_Semiquaver
    SongNote "F5"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongNote "E5"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Semiquaver
    SongNote "F5"
    Echo1
    SongOptions
        DescendingEnvelopeOptions 0, $D
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
    SongNoteLength_DottedCrochet
    SongNote "C4"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Quaver
    SongNote "C4"
    Echo1
    SongNoteLength_Semiquaver
    SongNote "C3"
    Echo1
    SongNoteLength_Demisemiquaver
    SongNote "C3"
    Echo1
    SongNote "C3"
    Echo1
    SongNoteLength_Hemidemisemiquaver
    SongNote "C2"
    SongNote "G2"
    SongNoteLength_Quaver
    SongNote "C3"
    SongNoteLength_Semibreve
    Echo2
    SongEnd
;}

; $79A3
song_reachedTheGunship_wave_section0:
;{
    SongOptions
        WaveOptions $416B, 2, $0
    SongRepeatSetup $2
        SongNoteLength_Demisemiquaver
        SongNote "C3"
        Echo1
        SongNote "Eb3"
        Echo1
        SongNote "F3"
        Echo1
        SongNote "Bb3"
        Echo1
        SongNote "C3"
        Echo1
        SongNote "Eb3"
        Echo1
        SongNote "A3"
        Echo1
        SongNote "Eb3"
        Echo1
        SongNote "C3"
        Echo1
        SongNote "Eb3"
        Echo1
        SongNote "F3"
        Echo1
        SongNote "Bb3"
        Echo1
        SongNote "C3"
        Echo1
        SongNote "Eb3"
        Echo1
        SongNote "F3"
        Echo1
        SongNote "C4"
        Echo1
    SongRepeat
;}

; $79CB
song_reachedTheGunship_tone_section1:
song_reachedTheGunship_toneSweep_section1:
;{
    SongNoteLength_Demisemiquaver
    SongNote "C3"
    Echo1
    SongNote "Eb3"
    Echo1
    SongNote "F3"
    Echo1
    SongNote "Bb3"
    Echo1
    SongNote "C3"
    Echo1
    SongNote "Eb3"
    Echo1
    SongNote "F3"
    Echo1
    SongNote "C4"
    Echo1
    SongNote "C3"
    Echo1
    SongNote "Eb3"
    Echo1
    SongNote "F3"
    Echo1
    SongNote "Eb4"
    Echo1
    SongNote "C3"
    Echo1
    SongNote "Eb3"
    Echo1
    SongNote "F3"
    Echo1
    SongNote "Bb3"
    Echo1
    SongNote "C3"
    Echo1
    SongNote "Eb3"
    Echo1
    SongNote "F3"
    Echo1
    SongNote "G3"
    Echo1
    SongNote "C3"
    Echo1
    SongNote "Eb3"
    Echo1
    SongNote "F3"
    Echo1
    SongNote "A3"
    Echo1
    SongNote "C3"
    Echo1
    SongNote "Eb3"
    Echo1
    SongNote "F3"
    Echo1
    SongNote "C4"
    Echo1
    SongNote "C4"
    Echo1
    SongNote "Eb4"
    Echo1
    SongNote "F4"
    Echo1
    SongNote "G5"
    Echo1
    SongEnd
;}

; $7A0D
song_reachedTheGunship_wave_section1:
;{
    SongOptions
        WaveOptions $417B, 2, $0
    SongNoteLength_Minum
    SongNote "C6"
    SongNoteLength_DottedCrochet
    SongNote "Bb5"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_DottedCrochet
    SongNote "A5"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_DottedCrochet
    SongNote "Ab5"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_DottedCrochet
    SongNote "G5"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_DottedCrochet
    SongNote "Gb5"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_DottedCrochet
    SongNote "F5"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_DottedCrochet
    SongNote "G5"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_DottedCrochet
    SongNote "C5"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_DottedCrochet
    SongNote "Bb4"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_DottedCrochet
    SongNote "A4"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_DottedCrochet
    SongNote "Ab4"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Minum
    SongNote "G4"
    SongNoteLength_DottedCrochet
    SongNote "Gb4"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_DottedCrochet
    SongNote "F4"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_DottedCrochet
    SongNote "Gb4"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_DottedCrochet
    SongNote "G4"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_DottedCrochet
    SongNote "G3"
    SongNoteLength_Quaver
    Echo1
    SongEnd
;}

; $7A56
song_reachedTheGunship_wave_section2:
;{
    SongOptions
        WaveOptions $416B, 2, $0
    SongRepeatSetup $7
        SongNoteLength_Semiquaver
        SongNote "C3"
        Echo1
        SongNoteLength_Demisemiquaver
        SongNote "C3"
        Echo1
        SongNote "C3"
        Echo1
    SongRepeat
    SongNoteLength_Semiquaver
    SongNote "G3"
    Echo1
    SongRest
    SongRest
    SongEnd
;}

; $7A6B
song_reachedTheGunship_wave_section3:
;{
    SongOptions
        WaveOptions $417B, 2, $0
    SongNoteLength_Minum
    SongNote "C4"
    SongNote "F3"
    SongNote "E3"
    SongNote "D3"
    SongNote "C3"
    SongNote "F3"
    SongNote "G3"
    SongNote "F3"
    SongRepeatSetup $2
        SongNoteLength_Minum
        SongNote "C3"
        SongNote "F3"
        SongNote "E3"
        SongNote "D3"
    SongRepeat
    SongEnd
;}

; $7A81
song_reachedTheGunship_wave_section4:
;{
    SongRepeatSetup $3
        SongNoteLength_Minum
        SongNote "C4"
        SongNote "Bb3"
    SongRepeat
    SongNote "F3"
    SongNote "Bb3"
    SongNote "A3"
    SongNote "G3"
    SongEnd
;}

; $7A8C
song_reachedTheGunship_wave_section5:
;{
    SongRepeatSetup $4
        SongNoteLength_Minum
        SongNote "F3"
        SongNote "Bb3"
        SongNote "A3"
        SongNote "G3"
    SongRepeat
    SongEnd
;}

; $7A95
song_reachedTheGunship_wave_section6:
;{
    SongRepeatSetup $4
        SongNoteLength_Minum
        SongNote "F3"
        SongNote "Bb3"
        SongNote "A3"
        SongNote "G3"
    SongRepeat
    SongEnd
;}

; $7A9E
song_reachedTheGunship_wave_section7:
;{
    SongRepeatSetup $2
        SongNoteLength_Minum
        SongNote "C4"
        SongNote "Bb3"
    SongRepeat
    SongRepeatSetup $2
        SongNoteLength_Minum
        SongNote "C3"
        SongNote "Bb2"
    SongRepeat
    SongEnd
;}

; $7AAB
song_reachedTheGunship_wave_section8:
;{
    SongNoteLength_Minum
    SongNote "C3"
    SongNote "F3"
    SongNote "E3"
    SongNote "D3"
    SongNote "C3"
    SongNote "F3"
    SongNote "C4"
    SongNote "F4"
    SongOptions
        WaveOptions $416B, 2, $0
    SongRepeatSetup $2
        SongNoteLength_Quaver
        SongNote "C4"
        SongNoteLength_Semiquaver
        Echo1
        SongNoteLength_Quaver
        SongNote "B3"
        SongNoteLength_Semiquaver
        Echo1
        SongNote "G3"
        Echo1
        SongNoteLength_Quaver
        SongNote "F4"
        SongNoteLength_Semiquaver
        Echo1
        SongNoteLength_Quaver
        SongNote "E4"
        SongNoteLength_Semiquaver
        Echo1
        SongNote "C4"
        Echo1
    SongRepeat
    SongNoteLength_Quaver
    SongNote "C5"
    SongNoteLength_Semiquaver
    Echo1
    SongNoteLength_Quaver
    SongNote "B4"
    SongNoteLength_Semiquaver
    Echo1
    SongNote "G4"
    Echo1
    SongNoteLength_Quaver
    SongNote "F5"
    SongNoteLength_Semiquaver
    Echo1
    SongNoteLength_Quaver
    SongNote "E5"
    SongNoteLength_Semiquaver
    Echo1
    SongNote "C5"
    Echo1
    SongNoteLength_Quaver
    SongNote "C5"
    SongNoteLength_Semiquaver
    Echo1
    SongNoteLength_Quaver
    SongNote "B4"
    SongNoteLength_Semiquaver
    Echo1
    SongNote "G4"
    Echo1
    SongNoteLength_Quaver
    SongNote "F5"
    SongNoteLength_Semiquaver
    Echo1
    SongNoteLength_Quaver
    SongNote "E5"
    SongNoteLength_Semiquaver
    Echo1
    SongNote "C5"
    Echo1
    SongNoteLength_Quaver
    SongNote "C6"
    SongNoteLength_Semiquaver
    Echo1
    SongNoteLength_Quaver
    SongNote "B5"
    SongNoteLength_Semiquaver
    Echo1
    SongNote "C6"
    SongNoteLength_Demisemiquaver
    Echo1
    SongRest
    SongNoteLength_DottedCrochet
    SongNote "G5"
    SongNoteLength_Quaver
    Echo1
    SongNoteLength_Quaver
    SongNote "G4"
    Echo1
    SongOptions
        WaveOptions $416B, 1, $0
    SongNoteLength_Semiquaver
    SongNote "G3"
    Echo1
    SongNoteLength_Demisemiquaver
    SongNote "G3"
    Echo1
    SongNote "G3"
    Echo1
    SongNoteLength_Hemidemisemiquaver
    SongNote "C2"
    SongNote "G2"
    SongNoteLength_Quaver
    SongNote "G3"
    SongNoteLength_Crochet
    Echo1
    SongEnd
;}

; $7B1E
song_reachedTheGunship_noise_section0:
;{
    SongRepeatSetup $2
        SongNoteLength_Quaver
        SongNoiseNote $4
        SongNoiseNote $3
        SongNoiseNote $4
        SongNoiseNote $3
        SongNoiseNote $4
        SongNoiseNote $3
        SongNoiseNote $3
        SongNoteLength_Semiquaver
        SongNoiseNote $7
        SongNoiseNote $5
    SongRepeat
    SongRepeatSetup $3
        SongNoteLength_Semiquaver
        SongNoiseNote $4
        SongNoiseNote $5
        SongNoiseNote $3
        SongNoiseNote $1
    SongRepeat
    SongNoiseNote $5
    SongNoiseNote $3
    SongNoiseNote $7
    SongNoiseNote $7
    SongRepeatSetup $2
        SongNoiseNote $4
        SongNoiseNote $7
        SongNoiseNote $3
        SongNoiseNote $1
    SongRepeat
    SongNoiseNote $7
    SongNoiseNote $7
    SongNoiseNote $7
    SongNoiseNote $7
    SongNoteLength_Quaver
    SongNoiseNote $1A
    SongNoteLength_Demisemiquaver
    SongNoiseNote $7
    SongNoiseNote $7
    SongNoiseNote $7
    SongNoiseNote $7
    SongEnd
;}

; $7B4B
song_reachedTheGunship_noise_section1:
;{
    SongNoteLength_Semibreve
    SongNoiseNote $1B
    SongRest
    SongRest
    SongNoteLength_DottedMinum
    SongRest
    SongNoteLength_Crochet
    SongNoiseNote $1A
    SongNoteLength_Crochet
    SongNoiseNote $1B
    SongNoiseNote $14
    SongNoiseNote $15
    SongNoiseNote $16
    SongNoteLength_Crochet
    SongNoiseNote $15
    SongNoteLength_Minum
    SongNoiseNote $17
    SongNoteLength_Crochet
    SongNoiseNote $19
    SongNoiseNote $18
    SongNoiseNote $16
    SongNoteLength_Minum
    SongNoiseNote $15
    SongNoteLength_Crochet
    SongNoiseNote $14
    SongNoiseNote $13
    SongNoiseNote $15
    SongNoiseNote $14
    SongRepeatSetup $4
        SongNoteLength_Semiquaver
        SongNoiseNote $13
        SongNoiseNote $19
    SongRepeat
    SongNoteLength_Semiquaver
    SongNoiseNote $5
    SongNoiseNote $5
    SongNoiseNote $5
    SongNoiseNote $5
    SongNoteLength_Crochet
    SongNoiseNote $1B
    SongEnd
;}

; $7B75
song_reachedTheGunship_noise_section2:
;{
    SongRepeatSetup $3
        SongNoteLength_Semiquaver
        SongNoiseNote $7
        SongNoiseNote $3
        SongNoiseNote $5
        SongNoiseNote $5
    SongRepeat
    SongNoteLength_Quaver
    SongNoiseNote $1A
    SongNoteLength_Semiquaver
    SongNoiseNote $7
    SongNoiseNote $3
    SongRepeatSetup $3
        SongNoteLength_Semiquaver
        SongNoiseNote $7
        SongNoiseNote $2
        SongNoiseNote $5
        SongNoiseNote $5
    SongRepeat
    SongNoteLength_Crochet
    SongNoiseNote $1B
    SongEnd
;}

; $7B8D
song_reachedTheGunship_noise_section3:
;{
    SongRepeatSetup $7
        SongNoteLength_Semiquaver
        SongNoiseNote $5
        SongNoiseNote $3
        SongNoiseNote $4
        SongNoiseNote $4
        SongNoiseNote $5
        SongNoiseNote $2
        SongNoiseNote $4
        SongNoiseNote $4
        SongNoiseNote $5
        SongNoiseNote $1
        SongNoiseNote $4
        SongNoiseNote $4
        SongNoiseNote $5
        SongNoiseNote $3
        SongNoiseNote $5
        SongNoiseNote $1
    SongRepeat
    SongRepeatSetup $3
        SongNoteLength_Semiquaver
        SongNoiseNote $5
        SongNoiseNote $2
        SongNoiseNote $4
        SongNoiseNote $4
    SongRepeat
    SongNoiseNote $7
    SongNoiseNote $5
    SongNoiseNote $7
    SongNoiseNote $5
    SongEnd
;}

; $7BAE
song_reachedTheGunship_noise_section4:
;{
    SongRepeatSetup $11
        SongNoteLength_Semiquaver
        SongNoiseNote $7
        SongNoiseNote $3
        SongNoiseNote $2
        SongNoiseNote $3
    SongRepeat
    SongRepeatSetup $2
        SongNoteLength_Semiquaver
        SongNoiseNote $7
        SongNoiseNote $3
        SongNoiseNote $7
        SongNoiseNote $3
    SongRepeat
    SongNoteLength_Semiquaver
    SongNoiseNote $7
    SongNoiseNote $5
    SongNoiseNote $7
    SongNoiseNote $3
    SongEnd
;}

; $7BC4
song_reachedTheGunship_noise_section5:
;{
    SongRepeatSetup $F
        SongNoteLength_Semiquaver
        SongNoiseNote $7
        SongNoiseNote $4
        SongNoiseNote $2
        SongNoiseNote $4
        SongNoiseNote $7
        SongNoiseNote $3
        SongNoiseNote $4
        SongNoiseNote $2
    SongRepeat
    SongNoteLength_Semiquaver
    SongNoiseNote $7
    SongNoiseNote $5
    SongNoiseNote $2
    SongNoiseNote $5
    SongNoiseNote $7
    SongNoiseNote $5
    SongNoiseNote $7
    SongNoiseNote $5
    SongEnd
;}

; $7BDA
song_reachedTheGunship_noise_section6:
;{
    SongRepeatSetup $1E
        SongNoteLength_Semiquaver
        SongNoiseNote $5
        SongNoiseNote $3
        SongNoiseNote $2
        SongNoiseNote $3
    SongRepeat
    SongNoteLength_Semiquaver
    SongNoiseNote $7
    SongNoiseNote $5
    SongNoiseNote $2
    SongNoiseNote $5
    SongNoiseNote $7
    SongNoiseNote $5
    SongNoiseNote $7
    SongNoiseNote $5
    SongEnd
;}

; $7BEC
song_reachedTheGunship_noise_section7:
;{
    SongRepeatSetup $E
        SongNoteLength_Semiquaver
        SongNoiseNote $5
        SongNoiseNote $4
        SongNoiseNote $3
        SongNoiseNote $4
    SongRepeat
    SongNoteLength_Semiquaver
    SongNoiseNote $7
    SongNoiseNote $5
    SongNoiseNote $2
    SongNoiseNote $5
    SongNoiseNote $7
    SongNoiseNote $5
    SongNoiseNote $7
    SongNoiseNote $5
    SongEnd
;}

; $7BFE
song_reachedTheGunship_noise_section8:
;{
    SongRepeatSetup $8
        SongNoteLength_Semiquaver
        SongNoiseNote $5
        SongNoiseNote $4
        SongNoiseNote $2
        SongNoiseNote $4
    SongRepeat
    SongRepeatSetup $4
        SongNoteLength_Semiquaver
        SongNoiseNote $5
        SongNoiseNote $3
        SongNoiseNote $5
        SongNoiseNote $4
    SongRepeat
    SongRepeatSetup $8
        SongNoteLength_Semiquaver
        SongNoiseNote $5
        SongNoiseNote $5
        SongNoiseNote $2
        SongNoiseNote $5
    SongRepeat
    SongRepeatSetup $4
        SongNoteLength_Semiquaver
        SongNoiseNote $5
        SongNoiseNote $5
        SongNoiseNote $5
        SongNoiseNote $5
    SongRepeat
    SongRepeatSetup $8
        SongNoteLength_Semiquaver
        SongNoiseNote $7
        SongNoiseNote $7
        SongNoiseNote $7
        SongNoiseNote $7
    SongRepeat
    SongNoteLength_DottedQuaver
    SongNoiseNote $7
    SongNoiseNote $7
    SongNoteLength_Quaver
    SongNoiseNote $7
    SongNoteLength_Minum
    SongNoiseNote $7
    SongNoteLength_Crochet
    SongNoiseNote $7
    SongNoteLength_Quaver
    SongNoiseNote $7
    SongNoteLength_Semiquaver
    SongNoiseNote $7
    SongNoiseNote $7
    SongNoteLength_Hemidemisemiquaver
    SongNoiseNote $7
    SongNoiseNote $7
    SongNoteLength_Semibreve
    SongNoiseNote $7
    SongEnd
;}

; $7C3A
song_mainCaves_noIntro_header:
    SongHeader $0, $40C5, song_mainCaves_toneSweep.alternateEntry, song_mainCaves_tone.alternateEntry, song_mainCaves_wave.alternateEntry, song_mainCaves_noise.alternateEntry

; $7C45
song_subCaves1_noIntro_header:
    SongHeader $0, $40F9, song_subCaves1_toneSweep.alternateEntry, $0000, $0000, $0000

; $7C50
song_subCaves2_noIntro_header:
    SongHeader $0, $40F9, $0000, song_subCaves2_tone.alternateEntry, $0000, $0000

; $7C5B
song_subCaves3_noIntro_header:
    SongHeader $0, $40DF, song_subCaves3_toneSweep.alternateEntry, song_subCaves3_tone.alternateEntry, song_subCaves3_wave.alternateEntry, $0000

; $7C66
song_subCaves4_noIntro_header:
    SongHeader $0, $40C5, $0000, song_subCaves4_tone.alternateEntry, $0000, $0000

; $7C71
song_metroidHive_withIntro_header:
    SongHeader $1, $40B8, song_metroidHive_withIntro_toneSweep, song_metroidHive_withIntro_tone, song_metroidHive_withIntro_wave, song_metroidHive_withIntro_noise

; $7C7C
song_metroidHive_withIntro_toneSweep:
;{
    dw song_metroidHive_withIntro_toneSweep_section0 ; $7CA6
    dw song_metroidHive_withIntro_toneSweep_section1 ; $7D7E
    dw song_metroidHive_withIntro_toneSweep_section2 ; $7CAD
    dw song_metroidHive_withIntro_toneSweep_section3 ; $6FD6
    dw song_metroidHive_withIntro_toneSweep_section4 ; $7CB8
    dw $00F0, song_metroidHive_withIntro_toneSweep_loop
;}

; $7C8A
song_metroidHive_withIntro_tone:
;{
    dw song_metroidHive_withIntro_tone_section0 ; $7CBF
    dw song_metroidHive_withIntro_tone_section1 ; $7CCB
    dw song_metroidHive_withIntro_tone_section2 ; $6FD6
    dw song_metroidHive_withIntro_tone_section3 ; $7CD6
    dw $00F0, song_metroidHive_tone.loop
;}

; $7C96
song_metroidHive_withIntro_wave:
;{
    dw song_metroidHive_withIntro_wave_section0 ; $7CDD
    dw song_metroidHive_withIntro_wave_section1 ; $7CEB
    dw $00F0, song_metroidHive_wave.loop
;}

; $7C9E
song_metroidHive_withIntro_noise:
;{
    dw song_metroidHive_withIntro_noise_section0 ; $7CF9
    dw song_metroidHive_withIntro_noise_section1 ; $7D01
    dw $00F0, song_metroidHive_noise.loop
;}

; $7CA6
song_metroidHive_withIntro_toneSweep_section0:
;{
    SongOptions
        DescendingEnvelopeOptions 7, $8
        AscendingSweepOptions 7, 1
        LengthDutyOptions $6, 0
    SongNoteLength_Semibreve
    SongNote "Gb2"
    SongEnd
;}

; $7CAD
song_metroidHive_withIntro_toneSweep_section2:
;{
    SongOptions
        AscendingEnvelopeOptions 5, $0
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
    SongNoteLength_Semibreve
    SongNote "C6"
    SongOptions
        DescendingEnvelopeOptions 7, $C
        AscendingSweepOptions 5, 3
        LengthDutyOptions $0, 0
    SongEnd
;}

; $7CB8
song_metroidHive_withIntro_toneSweep_section4:
;{
    SongOptions
        DescendingEnvelopeOptions 5, $F
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 1
    SongNoteLength_Semibreve
    SongNote "F6"
    SongEnd
;}

; $7CBF
song_metroidHive_withIntro_tone_section0:
;{
    SongOptions
        DescendingEnvelopeOptions 7, $8
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
    SongNoteLength_Semiquaver
    SongNote "D4"
    SongNote "D3"
    SongNote "Ab4"
    SongNote "Ab3"
    SongNoteLength_DottedMinum
    SongNote "D5"
    SongEnd
;}

; $7CCB
song_metroidHive_withIntro_tone_section1:
;{
    SongOptions
        AscendingEnvelopeOptions 5, $0
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
    SongNoteLength_Semibreve
    SongNote "B5"
    SongOptions
        DescendingEnvelopeOptions 7, $C
        AscendingSweepOptions 0, 0
        LengthDutyOptions $8, 0
    SongEnd
;}

; $7CD6
song_metroidHive_withIntro_tone_section3:
;{
    SongOptions
        DescendingEnvelopeOptions 5, $F
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 1
    SongNoteLength_Semibreve
    SongNote "E6"
    SongEnd
;}

; $7CDD
song_metroidHive_withIntro_wave_section0:
;{
    SongOptions
        WaveOptions $417B, 2, $0
    SongNoteLength_Semiquaver
    SongNote "D5"
    SongNote "D3"
    SongNote "Ab5"
    SongNote "Ab3"
    SongNoteLength_Crochet
    SongNote "D6"
    Echo1
    SongRest
    SongEnd
;}

; $7CEB
song_metroidHive_withIntro_wave_section1:
;{
    SongOptions
        WaveOptions $416B, 2, $0
    SongNoteLength_Semiquaver
    SongNote "C2"
    Echo1
    SongRepeatSetup $A
        SongNoteLength_Quaver
        SongNote "C2"
        Echo1
    SongRepeat
    SongEnd
;}

; $7CF9
song_metroidHive_withIntro_noise_section0:
;{
    SongNoteLength_Semiquaver
    SongNoiseNote $7
    SongNoiseNote $6
    SongNoiseNote $7
    SongNoiseNote $6
    SongNoteLength_DottedMinum
    SongNoiseNote $7
    SongEnd
;}

; $7D01
song_metroidHive_withIntro_noise_section1:
;{
    SongNoteLength_Semibreve
    SongRest
    SongRest
    SongNoteLength_Minum
    SongRest
    SongNoteLength_Quaver
    SongRest
    SongEnd
;}

; $7D09
song_missilePickup_header:
    SongHeader $1, $40DF, song_missilePickup_toneSweep, song_missilePickup_tone, song_missilePickup_wave, song_missilePickup_noise

; $7D14
song_missilePickup_tone:
song_missilePickup_toneSweep:
;{
    dw song_missilePickup_toneSweep_section0 ; $7D20
    dw $0000
;}

; $7D18
song_missilePickup_wave:
;{
    dw song_missilePickup_wave_section0 ; $7D2F
    dw $0000
;}

; $7D1C
song_missilePickup_noise:
;{
    dw song_missilePickup_noise_section0 ; $7D3C
    dw $0000
;}

; $7D20
song_missilePickup_toneSweep_section0:
;{
    SongOptions
        DescendingEnvelopeOptions 2, $F
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 2
    SongNoteLength_Semiquaver
    SongNote "G3"
    SongNote "A3"
    SongNote "Bb3"
    SongOptions
        DescendingEnvelopeOptions 5, $F
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 2
    SongNoteLength_DottedMinum
    SongNote "F4"
    SongEnd
;}

; $7D2F
song_missilePickup_wave_section0:
;{
    SongOptions
        WaveOptions $417B, 2, $0
    SongNoteLength_Semiquaver
    SongNote "Bb4"
    Echo1
    SongNote "C5"
    SongNoteLength_Quaver
    SongNote "C4"
    Echo2
    Echo1
    SongEnd
;}

; $7D3C
song_missilePickup_noise_section0:
;{
    SongNoteLength_Semiquaver
    SongNoiseNote $5
    SongNoiseNote $5
    SongNoiseNote $5
    SongNoiseNote $7
    SongEnd
;}

; $7D42
song_babyMetroid_tone_section3:
song_babyMetroid_toneSweep_section3:
;{
    SongOptions
        DescendingEnvelopeOptions 5, $1
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 1
    SongEnd
;}

; $7D47
song_babyMetroid_toneSweep_section5:
song_babyMetroid_tone_section5:
;{
    SongOptions
        DescendingEnvelopeOptions 5, $3
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 1
    SongEnd
;}

; $7D4C
song_babyMetroid_toneSweep_section7:
song_babyMetroid_tone_section7:
;{
    SongOptions
        DescendingEnvelopeOptions 5, $6
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 1
    SongEnd
;}

; $7D51
unused7D51_section0:
;{
    SongOptions
        DescendingEnvelopeOptions 5, $8
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 1
    SongEnd
;}

; $7D56
unused7D56_section0:
;{
    SongOptions
        DescendingEnvelopeOptions 5, $A
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 1
    SongEnd
;}

; $7D5B
song_babyMetroid_wave_section3:
;{
    SongOptions
        WaveOptions $417B, 3, $0
    SongEnd
;}

; $7D60
unused7D60_section0:
;{
    SongOptions
        WaveOptions $417B, 2, $0
    SongEnd
;}

; $7D65
unused7D65_section0:
;{
    SongOptions
        WaveOptions $417B, 1, $0
    SongEnd
;}

; $7D6A
song_metroidQueenBattle_toneSweep_section13:
song_metroidQueenBattle_toneSweep_section19:
song_metroidQueenBattle_toneSweep_section16:
;{
    SongTempo $409E
    SongEnd
;}

; $7D6E
song_metroidQueenBattle_toneSweep_section10:
song_metroidQueenBattle_toneSweep_section1C:
;{
    SongTempo $40AB
    SongEnd
;}

; $7D72
song_metroidQueenBattle_toneSweep_section1F:
song_metroidQueenBattle_toneSweep_sectionD:
;{
    SongTempo $40B8
    SongEnd
;}

; $7D76
song_metroidQueenBattle_toneSweep_sectionA:
song_metroidQueenBattle_toneSweep_section22:
;{
    SongTempo $40C5
    SongEnd
;}

; $7D7A
song_metroidQueenBattle_toneSweep_section8:
song_killedMetroid_toneSweep_section1:
song_title_toneSweep_sectionA:
;{
    SongTempo $40D2
    SongEnd
;}

; $7D7E
song_metroidBattle_toneSweep_section1:
song_metroidQueenBattle_toneSweep_section25:
song_subCaves4_toneSweep_section1:
song_metroidQueenBattle_toneSweep_section6:
song_subCaves3_toneSweep_section1:
song_metroidHive_withIntro_toneSweep_section1:
song_title_toneSweep_section6:
;{
    SongTempo $40DF
    SongEnd
;}

; $7D82
song_metroidQueenBattle_toneSweep_section4:
;{
    SongTempo $40EC
    SongEnd
;}

; $7D86
song_metroidQueenBattle_toneSweep_section2:
song_subCaves1_toneSweep_section1:
;{
    SongTempo $40F9
    SongEnd
;}

; $7D8A
song_subCaves2_toneSweep_section1:
;{
    SongTempo $4106
    SongEnd
;}

; $7D8E
song_metroidQueenBattle_toneSweep_section26:
;{
    SongTranspose $0
    SongEnd
;}

; $7D91
song_metroidQueenBattle_toneSweep_sectionB:
song_metroidQueenBattle_toneSweep_section23:
;{
    SongTranspose $2
    SongEnd
;}

; $7D94
song_metroidQueenBattle_toneSweep_sectionE:
song_metroidQueenBattle_toneSweep_section20:
;{
    SongTranspose $4
    SongEnd
;}

; $7D97
song_metroidQueenBattle_toneSweep_section11:
song_metroidQueenBattle_toneSweep_section1D:
;{
    SongTranspose $8
    SongEnd
;}

; $7D9A
song_metroidQueenBattle_toneSweep_section14:
song_metroidQueenBattle_toneSweep_section1A:
;{
    SongTranspose $C
    SongEnd
;}

; $7D9D
song_metroidQueenBattle_toneSweep_section17:
;{
    SongTranspose $10
    SongEnd
;}

; $7DA0
song_subCaves4_toneSweep_section0:
song_subCaves3_toneSweep_section0:
song_subCaves1_toneSweep_section0:
song_subCaves2_toneSweep_section0:
;{
    SongOptions
        DescendingEnvelopeOptions 4, $A
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 1
    SongNoteLength_Quaver
    SongNote "C4"
    Echo1
    SongNote "C4"
    Echo1
    SongOptions
        DescendingEnvelopeOptions 4, $8
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 1
    SongNoteLength_Crochet
    SongNote "C4"
    SongOptions
        DescendingEnvelopeOptions 4, $6
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 1
    SongNoteLength_Crochet
    SongNote "C4"
    SongOptions
        DescendingEnvelopeOptions 4, $4
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 1
    SongNoteLength_Crochet
    SongNote "C4"
    SongOptions
        DescendingEnvelopeOptions 4, $2
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 1
    SongNoteLength_Crochet
    SongNote "C4"
    SongOptions
        DescendingEnvelopeOptions 4, $1
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 1
    SongNoteLength_DottedMinum
    SongNote "C4"
    SongNoteLength_Semibreve
    SongRest
    SongEnd
;}

; $7DCA
song_subCaves4_tone_section0:
song_subCaves1_tone_section0:
song_subCaves3_tone_section0:
song_subCaves2_tone_section0:
;{
    SongOptions
        DescendingEnvelopeOptions 3, $B
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 1
    SongNoteLength_Quaver
    SongNote "F2"
    Echo1
    SongNote "F2"
    Echo1
    SongOptions
        DescendingEnvelopeOptions 3, $9
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 1
    SongNoteLength_Crochet
    SongNote "F2"
    SongOptions
        DescendingEnvelopeOptions 3, $7
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 1
    SongNoteLength_Crochet
    SongNote "F2"
    SongOptions
        DescendingEnvelopeOptions 3, $5
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 1
    SongNoteLength_Crochet
    SongNote "F2"
    SongOptions
        DescendingEnvelopeOptions 3, $3
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 1
    SongNoteLength_Crochet
    SongNote "F2"
    SongOptions
        DescendingEnvelopeOptions 3, $2
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 1
    SongNoteLength_DottedMinum
    SongNote "F2"
    SongNoteLength_Semibreve
    SongRest
    SongEnd
;}

; $7DF4
song_subCaves3_wave_section0:
song_subCaves2_wave_section0:
song_subCaves1_wave_section0:
song_subCaves4_wave_section0:
;{
    SongOptions
        WaveOptions $417B, 2, $0
    SongRepeatSetup $2
        SongNoteLength_Quaver
        SongNote "C4"
        Echo1
    SongRepeat
    SongNoteLength_DottedMinum
    SongRest
    SongRest
    SongNoteLength_Semibreve
    SongRest
    SongEnd
;}

; $7E04
song_subCaves2_noise_section0:
song_subCaves3_noise_section0:
song_subCaves1_noise_section0:
song_subCaves4_noise_section0:
;{
    SongNoteLength_Semibreve
    SongRest
    SongRest
    SongRest
    SongEnd
;}

; $7E09
song_title_toneSweep_section0:
song_babyMetroid_toneSweep_section2:
song_babyMetroid_tone_section2:
;{
    SongOptions
        DescendingEnvelopeOptions 1, $1
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
    SongNoteLength_Minum
    SongRest
    SongEnd
;}

; $7E10
song_babyMetroid_wave_section2:
song_title_wave_section0:
;{
    SongOptions
        WaveOptions $416B, 3, $0
    SongNoteLength_Minum
    SongRest
    SongEnd
;}

; $7E17
song_title_noise_section0:
song_babyMetroid_noise_section2:
;{
    SongNoteLength_Minum
    SongRest
    SongEnd
;}

; $7E1A
song_babyMetroid_tone_section0:
song_babyMetroid_toneSweep_section0:
song_babyMetroid_toneSweep_section1:
song_babyMetroid_tone_section1:
;{
    SongOptions
        DescendingEnvelopeOptions 1, $1
        AscendingSweepOptions 0, 0
        LengthDutyOptions $0, 0
    SongNoteLength_Semibreve
    SongRest
    SongEnd
;}

; $7E21
song_babyMetroid_wave_section0:
song_babyMetroid_wave_section1:
;{
    SongOptions
        WaveOptions $416B, 3, $0
    SongNoteLength_Semibreve
    SongRest
    SongEnd
;}

; $7E28
song_babyMetroid_noise_section0:
song_babyMetroid_noise_section1:
;{
    SongNoteLength_Semibreve
    SongRest
    SongEnd
;}
;}

; Freespace - 04:7E2B (filled with $00)
