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
enHead_NULL: ; Default - 03:64FE
    db $00,$00,$00,$00,$00,$00,$00,$00,$00 
    dw enAI_NULL
enHead_crawlerRight: ; Enemy 0/20h (tsumari / needler facing right)
    db $00,$20,$00,$00,$00,$FF,$00,$00,$01
    dw enAI_crawlerA ;$57DE
enHead_crawlerLeft: ; Enemy 1/21h (tsumari / needler facing left)
    db $00,$00,$00,$00,$02,$FF,$00,$00,$01
    dw enAI_crawlerB
enHead_skreek: ; Enemy 4 (skreek)
    db $80,$00,$00,$00,$00,$00,$00,$00,$0B
    dw enAI_skreek
enHead_drivel: ; Enemy 9 (drivel)
    db $00,$00,$00,$00,$00,$10,$00,$00,$0A
    dw enAI_drivel
enHead_smallBug: ; Enemy 12h (yumbo)
    db $00,$00,$00,$00,$00,$00,$00,$00,$01
    dw enAI_smallBug ; The things the flit back and forth
enHead_hornoad: ; Enemy 14h (hornoad)
    db $00,$20,$00,$00,$00,$00,$02,$00,$02
    dw enAI_hopper
enHead_senjoo: ; Enemy 16h (senjoo)
    db $00,$00,$00,$00,$00,$00,$00,$00,$06
    dw enAI_senjooShirk
enHead_pipeBug: ; Enemy 19h/1Ah/3Ch/3Dh (gawron/yumee spawner (pipe bugs))
    db $80,$00,$00,$00,$00,$00,$00,$00,$FF
    dw enAI_pipeBug
enHead_chuteLeech: ; Enemy 1Bh (chute leech)
    db $00,$00,$00,$00,$00,$00,$00,$00,$03
    dw enAI_chuteLeech
enHead_autrackFlipped: ; Enemy 1Eh (autrack (flipped))
    db $00,$20,$00,$00,$08,$00,$00,$00,$0F
    dw enAI_autrack
enHead_wallfireFlipped: ; Enemy 1Fh (wallfire (flipped))
    db $00,$20,$00,$00,$00,$00,$00,$00,$FF
    dw enAI_wallfire

enHead_skorpUp: ; Enemy 28h (skorp (vertical, upwards))
    db $80,$00,$00,$00,$00,$00,$00,$00,$04
    dw enAI_skorpVert
enHead_skorpDown: ; Enemy 29h (skorp (vertical, downwards))
    db $80,$40,$00,$00,$00,$00,$00,$00,$04
    dw enAI_skorpVert
enHead_skorpRight: ; Enemy 2Ah (skorp (horizontal, rightwards))
    db $80,$00,$00,$00,$00,$00,$00,$00,$04
    dw enAI_skorpHori
enHead_skorpLeft: ; Enemy 2Bh (skorp (horizontal, leftwards))
    db $80,$20,$00,$00,$00,$00,$00,$00,$04
    dw enAI_skorpHori

enHead_moheekRight: ; Enemy 30h (moheek facing right)
    db $00,$20,$00,$00,$00,$FF,$00,$00,$05
    dw enAI_crawlerA
enHead_moheekLeft: ; Enemy 31h (moheek facing left)
    db $00,$00,$00,$00,$02,$FF,$00,$00,$05
    dw enAI_crawlerB
enHead_octroll: ; Enemy 40h (octroll)
    db $00,$00,$00,$00,$00,$00,$00,$00,$0F
    dw enAI_chuteLeech
enHead_autrack: ; Enemy 41h (autrack)
    db $00,$00,$00,$00,$08,$00,$00,$00,$0F
    dw enAI_autrack
enHead_autoad: ; Enemy 46h (autoad)
    db $00,$20,$00,$00,$00,$00,$02,$00,$0E
    dw enAI_hopper
enHead_wallfire: ; Enemy 4Ah (wallfire)
    db $00,$00,$00,$00,$00,$00,$00,$00,$FF
    dw enAI_wallfire
enHead_gunzoo: ; Enemy 51h (gunzoo)
    db $00,$00,$00,$00,$01,$00,$00,$00,$15
    dw enAI_gunzoo
enHead_autom: ; Enemy 5Ch (autom)
    db $00,$00,$00,$00,$00,$00,$00,$00,$FF
    dw enAI_autom
enHead_shirk: ; Enemy 63h (shirk)
    db $00,$00,$00,$00,$00,$00,$00,$00,$0A
    dw enAI_senjooShirk
enHead_septogg: ; Enemy 65h (septogg)
    db $00,$00,$00,$00,$00,$00,$00,$00,$FF
    dw enAI_septogg
enHead_moto: ; Enemy 68h (moto)
    db $00,$20,$00,$00,$20,$00,$00,$00,$11
    dw enAI_moto
enHead_halzyn: ; Enemy 6Ah (halzyn)
    db $00,$00,$00,$00,$30,$00,$00,$00,$03
    dw enAI_halzyn
enHead_ramulken: ; Enemy 6Bh (ramulken)
    db $00,$20,$00,$00,$B0,$00,$02,$00,$0C
    dw enAI_hopper

enHead_metroidStinger: ; Enemy 6Dh - Metroid stinger event
    db $00,$00,$00,$00,$00,$00,$00,$00,$FF
    dw enAI_metroidStinger
enHead_proboscumFlipped: ; Enemy 6Eh (proboscum (flipped))
    db $00,$20,$00,$00,$00,$00,$00,$00,$FF
    dw enAI_proboscum
enHead_proboscum: ; Enemy 72h (proboscum)
    db $00,$00,$00,$00,$00,$00,$00,$00,$FF
    dw enAI_proboscum
enHead_missileBlock: ; Enemy 75h (missile block)
    db $00,$00,$00,$00,$00,$00,$00,$00,$FF
    dw enAI_missileBlock
enHead_flittVanishing: ; Enemy D0h (flitt) (vanishing type)
    db $00,$00,$00,$00,$00,$00,$00,$00,$FF
    dw enAI_flittVanishing
enHead_flittMoving: ; Enemy D1h (flitt) (moving type)
    db $00,$00,$00,$00,$00,$00,$00,$00,$FF
    dw enAI_flittMoving
enHead_gravitt: ; Enemy D3h (gravitt)
    db $80,$00,$00,$00,$80,$00,$00,$00,$05
    dw enAI_gravitt
enHead_gullugg: ; Enemy D8h (gullugg)
    db $00,$00,$00,$00,$00,$00,$00,$00,$04
    dw enAI_gullugg
enHead_missileDoor: ; Enemy F8h (missile door)
    db $00,$00,$00,$00,$00,$00,$00,$00,$FF
    dw enAI_missileDoor

enHead_alphaHatching: ; Enemy A0h (hatching alpha metroid)
    db $00,$00,$00,$00,$FF,$00,$00,$00,$05
    dw enAI_hatchingAlpha
enHead_alphaMetroid: ; Enemy A4h (alpha metroid)
    db $00,$00,$00,$00,$FF,$00,$00,$00,$05
    dw enAI_alphaMetroid
enHead_gammaMetroid: ; Enemy A3h (gamma metroid)
    db $00,$00,$00,$00,$FF,$00,$00,$00,$0A
    dw enAI_gammaMetroid
enHead_zetaMetroid: ; Enemy ADh (zeta metroid)
    db $00,$00,$00,$00,$FF,$00,$00,$00,$14
    dw enAI_zetaMetroid
enHead_omegaMetroid: ; Enemy B3h (omega metroid hatching)
    db $00,$00,$00,$00,$FF,$00,$00,$00,$28
    dw enAI_omegaMetroid
enHead_metroid: ; Enemy CEh (normal metroid)
    db $00,$00,$00,$00,$FF,$10,$10,$00,$05
    dw enAI_normalMetroid
enHead_babyMetroid: ; Enemy A6h (baby metroid)
    db $80,$00,$00,$00,$FF,$00,$00,$00,$FF
    dw enAI_babyMetroid

enHead_item: ; Enemy 80h..99h/9Bh/9Dh (item / item orb / enemy/missile refill)
    db $80,$00,$00,$00,$00,$00,$00,$00,$FF
    dw enAI_itemOrb
enHead_itemFlipped: ; Unused (item, but horizontally flipped)
    db $00,$00,$00,$00,$00,$00,$00,$00,$FF
    dw enAI_itemOrb
enHead_blobThrower: ; Enemy 9Ah (blob thrower?)
    db $00,$00,$00,$00,$70,$00,$00,$00,$15
    dw enAI_blobThrower
enHead_glowFly: ; Enemy 2Ch (glow fly)
    db $00,$00,$00,$00,$00,$00,$00,$00,$03
    dw enAI_glowFly
enHead_rockIcicle: ; Enemy 34h (rock icicle)
    db $00,$00,$00,$00,$00,$00,$00,$00,$01
    dw enAI_rockIcicle
enHead_arachnus: ; Enemy 76h..7Ah (Arachnus)
    db $00,$00,$00,$00,$00,$00,$00,$00,$FD
    dw enAI_arachnus
enHead_arachnusOrb: ; Enemy 9Ch (Arachnus orb)
    db $00,$00,$00,$00,$00,$00,$00,$00,$FD
    dw enAI_arachnus
;}