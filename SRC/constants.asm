; Constants

; Hardware related constants (not covered by hardware.inc)
rMBC_BANK_REG = $2100 ; Dunno why it just doesn't use $2000


METASPRITE_END = $FF ; I recommend setting this to $80 (-128) if you plan on doing your own sprite editing

; Map related memory locations (fixed in each bank)
map_screenPointers = $4000 ; $200 bytes
map_scrollData     = $4200 ; $100 bytes
map_doorIndexes    = $4300 ; $200 bytes - Also contains sprite priority bits per screen
; Note: Map data starts at $4500

; Scrolling Directions (bitfields and bit numbers)
scrollDir_right = $10
scrollDir_left  = $20
scrollDir_up    = $40
scrollDir_down  = $80
scrollDirBit_right = 4
scrollDirBit_left  = 5
scrollDirBit_up    = 6
scrollDirBit_down  = 7

; Samus physics constants
samus_jumpArrayBaseOffset = $40
samus_unmorphJumpTime = $10

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

; Samus' pose constants ($D020)
include "samus/samus_poseConstants.asm"



; Queen related constants

; First and last tiles to be clear by disintegration animation
queenDeath_firstTile = $8B10
queenDeath_lastTile = $9570
queenDeath_bodyStart = $99A0
queenDeath_bodyEnd = $9A80