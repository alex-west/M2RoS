; This file was automatically generated from samus.csv. Please edit that file instead of this one.
    db OAM_Y_OFS + samusOriginY_toStand + $08, OAM_Y_OFS + samusOriginY_toStand + $10, OAM_Y_OFS + samusOriginY_toStand + $18, OAM_Y_OFS + samusOriginY_toStand + $20, OAM_Y_OFS + samusOriginY_toBottom - 2, $80, 0, 0 ; $00 - Standing
    db OAM_Y_OFS + samusOriginY_toNJumpBG, OAM_Y_OFS + samusOriginY_toStand + $10, OAM_Y_OFS + samusOriginY_toStand + $18, OAM_Y_OFS + samusOriginY_toStand + $20, OAM_Y_OFS + samusOriginY_toBottom - 2, $80, 0, 0 ; $01 - Jumping
    db OAM_Y_OFS + samusOriginY_toSpinJumpBG, OAM_Y_OFS + samusOriginY_toStand + $18, OAM_Y_OFS + samusOriginY_toStand + $20, OAM_Y_OFS + samusOriginY_toBottom - 2, $80, 0, 0, 0 ; $02 - Spin-jumping
    db OAM_Y_OFS + samusOriginY_toStand + $08, OAM_Y_OFS + samusOriginY_toStand + $10, OAM_Y_OFS + samusOriginY_toStand + $18, OAM_Y_OFS + samusOriginY_toStand + $20, OAM_Y_OFS + samusOriginY_toBottom - 2, $80, 0, 0 ; $03 - Running
    db OAM_Y_OFS + samusOriginY_toStand + $08, OAM_Y_OFS + samusOriginY_toStand + $10, OAM_Y_OFS + samusOriginY_toStand + $18, OAM_Y_OFS + samusOriginY_toStand + $20, OAM_Y_OFS + samusOriginY_toBottom - 2, $80, 0, 0 ; $04 - Crouching
    db OAM_Y_OFS + samusOriginY_toMorph, OAM_Y_OFS + (samusOriginY_toMorph + samusOriginY_toBottom - 2) / 2, OAM_Y_OFS + samusOriginY_toBottom - 2, $80, 0, 0, 0, 0 ; $05 - Morphball
    db OAM_Y_OFS + samusOriginY_toMorph, OAM_Y_OFS + (samusOriginY_toMorph + samusOriginY_toBottom - 2) / 2, OAM_Y_OFS + samusOriginY_toBottom - 2, $80, 0, 0, 0, 0 ; $06 - Morphball jumping
    db OAM_Y_OFS + samusOriginY_toStand + $08, OAM_Y_OFS + samusOriginY_toStand + $10, OAM_Y_OFS + samusOriginY_toStand + $18, OAM_Y_OFS + samusOriginY_toStand + $20, OAM_Y_OFS + samusOriginY_toBottom - 2, $80, 0, 0 ; $07 - Falling
    db OAM_Y_OFS + samusOriginY_toMorph, OAM_Y_OFS + (samusOriginY_toMorph + samusOriginY_toBottom - 2) / 2, OAM_Y_OFS + samusOriginY_toBottom - 2, $80, 0, 0, 0, 0 ; $08 - Morphball falling
    db OAM_Y_OFS + samusOriginY_toStand + $08, OAM_Y_OFS + samusOriginY_toStand + $10, OAM_Y_OFS + samusOriginY_toStand + $18, OAM_Y_OFS + samusOriginY_toStand + $20, OAM_Y_OFS + samusOriginY_toBottom - 2, $80, 0, 0 ; $09 - Starting to jump
    db OAM_Y_OFS + samusOriginY_toStand + $08, OAM_Y_OFS + samusOriginY_toStand + $10, OAM_Y_OFS + samusOriginY_toStand + $18, OAM_Y_OFS + samusOriginY_toStand + $20, OAM_Y_OFS + samusOriginY_toBottom - 2, $80, 0, 0 ; $0A - Starting to spin-jump
    db OAM_Y_OFS + samusOriginY_toMorph, OAM_Y_OFS + (samusOriginY_toMorph + samusOriginY_toBottom - 2) / 2, OAM_Y_OFS + samusOriginY_toBottom - 1, $80, 0, 0, 0, 0 ; $0B - Spider ball rolling
    db OAM_Y_OFS + samusOriginY_toMorph, OAM_Y_OFS + (samusOriginY_toMorph + samusOriginY_toBottom - 2) / 2, OAM_Y_OFS + samusOriginY_toBottom - 1, $80, 0, 0, 0, 0 ; $0C - Spider ball falling
    db OAM_Y_OFS + samusOriginY_toMorph, OAM_Y_OFS + (samusOriginY_toMorph + samusOriginY_toBottom - 2) / 2, OAM_Y_OFS + samusOriginY_toBottom - 1, $80, 0, 0, 0, 0 ; $0D - Spider ball jumping
    db OAM_Y_OFS + samusOriginY_toMorph, OAM_Y_OFS + (samusOriginY_toMorph + samusOriginY_toBottom - 2) / 2, OAM_Y_OFS + samusOriginY_toBottom - 1, $80, 0, 0, 0, 0 ; $0E - Spider ball
    db OAM_Y_OFS + samusOriginY_toNJumpBG, OAM_Y_OFS + samusOriginY_toStand + $10, OAM_Y_OFS + samusOriginY_toStand + $18, OAM_Y_OFS + samusOriginY_toStand + $20, OAM_Y_OFS + samusOriginY_toBottom - 2, $80, 0, 0 ; $0F - Knockback
    db OAM_Y_OFS + samusOriginY_toMorph, OAM_Y_OFS + (samusOriginY_toMorph + samusOriginY_toBottom - 2) / 2, OAM_Y_OFS + samusOriginY_toBottom - 2, $80, 0, 0, 0, 0 ; $10 - Morphball knockback
    db OAM_Y_OFS + samusOriginY_toStand + $08, OAM_Y_OFS + samusOriginY_toStand + $10, OAM_Y_OFS + samusOriginY_toStand + $18, OAM_Y_OFS + samusOriginY_toStand + $20, OAM_Y_OFS + samusOriginY_toBottom - 2, $80, 0, 0 ; $11 - Standing bombed
    db OAM_Y_OFS + samusOriginY_toMorph, OAM_Y_OFS + (samusOriginY_toMorph + samusOriginY_toBottom - 2) / 2, OAM_Y_OFS + samusOriginY_toBottom - 2, $80, 0, 0, 0, 0 ; $12 - Morphball bombed
    db OAM_Y_OFS + samusOriginY_toStand + $08, OAM_Y_OFS + samusOriginY_toStand + $10, OAM_Y_OFS + samusOriginY_toStand + $18, OAM_Y_OFS + samusOriginY_toStand + $20, OAM_Y_OFS + samusOriginY_toBottom - 2, $80, 0, 0 ; $13 - Facing screen
    db 0, 0, 0, 0, 0, 0, 0, 0 ; $14 - Unused
    db 0, 0, 0, 0, 0, 0, 0, 0 ; $15 - Unused
    db 0, 0, 0, 0, 0, 0, 0, 0 ; $16 - Unused
    db 0, 0, 0, 0, 0, 0, 0, 0 ; $17 - Unused
    db OAM_Y_OFS + samusOriginY_toMorph, OAM_Y_OFS + (samusOriginY_toMorph + samusOriginY_toBottom - 2) / 2, OAM_Y_OFS + samusOriginY_toBottom - 2, $80, 0, 0, 0, 0 ; $18 - Being eaten by Metroid Queen
    db OAM_Y_OFS + samusOriginY_toMorph, OAM_Y_OFS + (samusOriginY_toMorph + samusOriginY_toBottom - 2) / 2, OAM_Y_OFS + samusOriginY_toBottom - 2, $80, 0, 0, 0, 0 ; $19 - In Metroid Queen's mouth
    db OAM_Y_OFS + samusOriginY_toMorph, OAM_Y_OFS + (samusOriginY_toMorph + samusOriginY_toBottom - 2) / 2, OAM_Y_OFS + samusOriginY_toBottom - 2, $80, 0, 0, 0, 0 ; $1A - Being swallowed by Metroid Queen
    db OAM_Y_OFS + samusOriginY_toMorph, OAM_Y_OFS + (samusOriginY_toMorph + samusOriginY_toBottom - 2) / 2, OAM_Y_OFS + samusOriginY_toBottom - 2, $80, 0, 0, 0, 0 ; $1B - In Metroid Queen's stomach
    db OAM_Y_OFS + samusOriginY_toMorph, OAM_Y_OFS + (samusOriginY_toMorph + samusOriginY_toBottom - 2) / 2, OAM_Y_OFS + samusOriginY_toBottom - 2, $80, 0, 0, 0, 0 ; $1C - Escaping Metroid Queen
    db OAM_Y_OFS + samusOriginY_toMorph, OAM_Y_OFS + (samusOriginY_toMorph + samusOriginY_toBottom - 2) / 2, OAM_Y_OFS + samusOriginY_toBottom - 2, $80, 0, 0, 0, 0 ; $1D - Escaped Metroid Queen
