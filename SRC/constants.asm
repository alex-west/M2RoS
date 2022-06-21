; Constants

; Hardware related constants (not covered by hardware.inc)
rMBC_BANK_REG = $2100 ; Dunno why it just doesn't use $2000

; Samus' Gear constants
;  Bitfields
itemMask_bomb   = %00000001 ; 01: Bombs
itemMask_hiJump = %00000010 ; 02: Hi-jump
itemMask_screw  = %00000100 ; 04: Screw attack
itemMask_space  = %00001000 ; 08: Space jump
itemMask_spring = %00010000 ; 10: Spring ball
itemMask_spider = %00100000 ; 20: Spider ball
itemMask_varia  = %01000000 ; 40: Varia suit
itemMask_UNUSED = %10000000 ; 80: Unused
;  Bit Numbers
itemBit_bomb   = 0
itemBit_hiJump = 1
itemBit_screw  = 2
itemBit_space  = 3
itemBit_spring = 4
itemBit_spider = 5
itemBit_varia  = 6
itemBit_UNUSED = 7

; Collision block-type bit numbers
blockType_water = 0 ;Water (also causes morph ball sound effect glitch)
blockType_up    = 1 ;Half-solid floor (can jump through)
blockType_down  = 2 ;Half-solid ceiling (can fall through)
blockType_spike = 3 ;Spike
blockType_acid  = 4 ;Acid
blockType_shot  = 5 ;Shot block
blockType_bomb  = 6 ;Bomb block
blockType_save  = 7 ;Save pillar



