; Enemy headers {
;                                         v--- Working address in HRAM 
;        ______________________________ $FFE4 - Base sprite attributes - not modified during runtime (apparently)
;       |    ___________________________ $FFE5 - Sprite attributes (flipping, etc.) - modified during runtime
;       |   |    ________________________ $FFE6 - Stun counter? (dummy value in header)
;       |   |   |    _____________________ $FFE7 - General variable (dummy value in header)
;       |   |   |   |    __________________ $FFE8 - Upper nybble - directional invulnerability flags, lower nybble - flip related?
;       |   |   |   |   |    _______________ $FFE9 - Not a dummy value?
;       |   |   |   |   |   |    ____________ $FFEA - Not a dummy value?
;       |   |   |   |   |   |   |    _________ $FFEB - Ice counter (dummy value in header)
;       |   |   |   |   |   |   |   |    ______ $FFEC - Health (also determines drop type?)
;       |   |   |   |   |   |   |   |   |    ___ AI pointer (bank 2)
;       |   |   |   |   |   |   |   |   |   |
enXX: ; Default - 03:64FE
    db $00,$00,$00,$00,$00,$00,$00,$00,$00 
    dw enAI_NULL
en6509: ; Enemy 0/20h (tsumari / needler facing right)
    db $00,$20,$00,$00,$00,$FF,$00,$00,$01
    dw enAI_crawlerA ;$57DE
en6514: ; Enemy 1/21h (tsumari / needler facing left)
    db $00,$00,$00,$00,$02,$FF,$00,$00,$01
    dw enAI_crawlerB
en651F: ; Enemy 4 (skreek)
    db $80,$00,$00,$00,$00,$00,$00,$00,$0B
    dw enAI_skreek
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
    dw enAI_pipeBug
en6561: ; Enemy 1Bh (chute leech)
    db $00,$00,$00,$00,$00,$00,$00,$00,$03
    dw enAI_chuteLeech
en656C: ; Enemy 1Eh (autrack (flipped))
    db $00,$20,$00,$00,$08,$00,$00,$00,$0F
    dw enAI_autrack
en6577: ; Enemy 1Fh (wallfire (flipped))
    db $00,$20,$00,$00,$00,$00,$00,$00,$FF
    dw enAI_wallfire
en6582: ; Enemy 28h (skorp (vertical, upwards))
    db $80,$00,$00,$00,$00,$00,$00,$00,$04
    dw enAI_skorpVert
en658D: ; Enemy 29h (skorp (vertical, downwards))
    db $80,$40,$00,$00,$00,$00,$00,$00,$04
    dw enAI_skorpVert
en6598: ; Enemy 2Ah (skorp (horizontal, rightwards))
    db $80,$00,$00,$00,$00,$00,$00,$00,$04
    dw enAI_skorpHori
en65A3: ; Enemy 2Bh (skorp (horizontal, leftwards))
    db $80,$20,$00,$00,$00,$00,$00,$00,$04
    dw enAI_skorpHori
en65AE: ; Enemy 30h (moheek facing right)
    db $00,$20,$00,$00,$00,$FF,$00,$00,$05
    dw enAI_crawlerA
en65B9: ; Enemy 31h (moheek facing left)
    db $00,$00,$00,$00,$02,$FF,$00,$00,$05
    dw enAI_crawlerB
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
    dw enAI_wallfire
en65F0: ; Enemy 51h (gunzoo)
    db $00,$00,$00,$00,$01,$00,$00,$00,$15
    dw enAI_gunzoo
en65FB: ; Enemy 5Ch (autom)
    db $00,$00,$00,$00,$00,$00,$00,$00,$FF
    dw enAI_autom
en6606: ; Enemy 63h (shirk)
    db $00,$00,$00,$00,$00,$00,$00,$00,$0A
    dw enAI_senjooShirk
en6611: ; Enemy 65h (septogg)
    db $00,$00,$00,$00,$00,$00,$00,$00,$FF
    dw enAI_septogg
en661C: ; Enemy 68h (moto)
    db $00,$20,$00,$00,$20,$00,$00,$00,$11
    dw enAI_moto
en6627: ; Enemy 6Ah (halzyn)
    db $00,$00,$00,$00,$30,$00,$00,$00,$03
    dw enAI_halzyn
en6632: ; Enemy 6Bh (ramulken)
    db $00,$20,$00,$00,$B0,$00,$02,$00,$0C
    dw enAI_hopper
en663D: ; Enemy 6Dh - Metroid stinger event
    db $00,$00,$00,$00,$00,$00,$00,$00,$FF
    dw enAI_metroidStinger
en6648: ; Enemy 6Eh (proboscum (flipped))
    db $00,$20,$00,$00,$00,$00,$00,$00,$FF
    dw enAI_proboscum
en6653: ; Enemy 72h (proboscum)
    db $00,$00,$00,$00,$00,$00,$00,$00,$FF
    dw enAI_proboscum
en665E: ; Enemy 75h (missile block)
    db $00,$00,$00,$00,$00,$00,$00,$00,$FF
    dw enAI_missileBlock
en6669: ; Enemy D0h (flitt) (vanishing type)
    db $00,$00,$00,$00,$00,$00,$00,$00,$FF
    dw enAI_flittVanishing
en6674: ; Enemy D1h (flitt) (moving type)
    db $00,$00,$00,$00,$00,$00,$00,$00,$FF
    dw enAI_flittMoving
en667F: ; Enemy D3h (gravitt)
    db $80,$00,$00,$00,$80,$00,$00,$00,$05
    dw enAI_gravitt
en668A: ; Enemy D8h (gullugg)
    db $00,$00,$00,$00,$00,$00,$00,$00,$04
    dw enAI_gullugg
en6695: ; Enemy F8h (missile door)
    db $00,$00,$00,$00,$00,$00,$00,$00,$FF
    dw enAI_missileDoor
en66A0: ; Enemy A0h (hatching alpha metroid)
    db $00,$00,$00,$00,$FF,$00,$00,$00,$05
    dw enAI_hatchingAlpha
en66AB: ; Enemy A4h (alpha metroid)
    db $00,$00,$00,$00,$FF,$00,$00,$00,$05
    dw enAI_alphaMetroid
en66B6: ; Enemy A3h (gamma metroid)
    db $00,$00,$00,$00,$FF,$00,$00,$00,$0A
    dw enAI_gammaMetroid
en66C1: ; Enemy ADh (zeta metroid)
    db $00,$00,$00,$00,$FF,$00,$00,$00,$14
    dw enAI_zetaMetroid
en66CC: ; Enemy B3h (omega metroid hatching)
    db $00,$00,$00,$00,$FF,$00,$00,$00,$28
    dw enAI_omegaMetroid
en66D7: ; Enemy CEh (normal metroid)
    db $00,$00,$00,$00,$FF,$10,$10,$00,$05
    dw enAI_normalMetroid
en66E2: ; Enemy A6h (baby metroid)
    db $80,$00,$00,$00,$FF,$00,$00,$00,$FF
    dw enAI_babyMetroid
en66ED: ; Enemy 80h..99h/9Bh/9Dh (item / item orb / enemy/missile refill)
    db $80,$00,$00,$00,$00,$00,$00,$00,$FF
    dw enAI_itemOrb
en66F8: ; Unused (item, but horizontally flipped)
    db $00,$00,$00,$00,$00,$00,$00,$00,$FF
    dw enAI_itemOrb
en6703: ; Enemy 9Ah (blob thrower?)
    db $00,$00,$00,$00,$70,$00,$00,$00,$15
    dw enAI_blobThrower
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
;}