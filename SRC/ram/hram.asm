section "HRAM", HRAM[$ff80]

;;;; $FF80..FFFE: Hi-RAM ;;;
hInputPressed::    ds 1 ;$FF80: Input
hInputRisingEdge:: ds 1 ;$FF81: New input
;{
;    1: A
;    2: B
;    4: Select
;    8: Start
;    10h: Right
;    20h: Left
;    40h: Up
;    80h: Down
;}
hVBlankDoneFlag:: ds 1 ;$FF82: V-blank handled flag

hUnusedHRAM_1::   ds 9 ; $FF83-$FF8B - 9 unused bytes!?
hUnusedFlag_1::   ds 1 ; $FF8C: Set to C0h by update in-game timer and wait a frame. Otherwise unused. (Likely meant to be the high byte of the OAM index.)

hOamBufferIndex:: ds 1 ; FF8D: OAM buffer index

hUnusedHRAM_2::   ds 9 ; $FF8E-$FF96 - 9 more unused bytes!?

frameCounter::    ds 1 ; $FF97: Frame counter (used by IGT, but not tied to IGT)

hTemp:: ; Temp variables? Uncertain. Don't use these names in code until we have a better understanding of them
.a:: ds 1 ;$FF98:
;{
;    Sprite tile number (see $5:4015)
;    Bomb Y position (see $30BB)
;    Projectile Y position (see $31B6)
;    Door scroll flags (see $08FE): [$4200 + [screen Y position, screen] * 16 + [screen X position, screen]]
;    Working projectile direction (see $1:500D)
;    Projectile X offset from Samus (see $1:4E8A)
;}
.b: ds 1 ;$FF99:
;{
;    Two sprite tile numbers (see $5:4000)
;    Bomb X position (see $30BB)
;    Projectile X position (see $31B6)
;    Door thing (see $08FE): [Samus' Y position] - [screen Y position] + 60h
;    Backup of interrupts enabled (see $039C)
;    Bomb Y position (see $1:53AF)
;    Working projectile Y position (see $1:500D)
;    Projectile direction (see $1:4E8A)
;}
.c: ds 1 ;$FF9A:
;{
;    Bomb X position (see $1:53AF)
;    Working projectile X position (see $1:500D)
;    Projectile Y offset from Samus (see $1:4E8A)
;}
gameMode:: ds 1 ; $FF9B ; Game mode
;{
;    0: Boot
;    1: Title screen
;    2: Loading save 2
;    3: Loading save 3
;    4: In-game
;    5: Dead
;    6: Dying
;    7: Game over
;    8: Paused
;    9: Save to SRAM
;    Ah: Unused
;    Bh: Start new game
;    Ch: Load from save
;    Dh: RET
;    Eh: RET
;    Fh: Unused. Identical to 7, set by game mode Ah
;    10h: Unused. Game cleared
;    11h: Unused. Functionally identical to 7, set by game mode 10h
;    12h: Reached the gunship
;    13h: Credits
;}

hUnusedHRAM_3:: ds 4 ; $FF9C-$FF9F - 4 unused bytes

OAM_DMA:: ds $0a ; $FFA0-$FFA9: OAM DMA routine

hMapUpdate:
.destAddrLow:  ds 1 ; $FFAA - VRAM tilemap metatile update address. $FFAA = $9800 + ([row block to update] * 32 + [column block to update]) * 2
.destAddrHigh: ds 1 ; $FFAB - (high byte)
.srcScreen:    ds 1 ; $FFAC - Map index of screen for metatile update. ($YX format)
.srcBlock:     ds 1 ; $FFAD - Screen index of block for metatile update. ($YX format)
.size:         ds 1 ; $FFAE - Number of blocks to update
.buffPtrLow:   ds 1 ; $FFAF - Stack pointer for metatile update entries (low byte)
.buffPtrHigh:  ds 1 ; $FFB0 - (high byte)

hVramTransfer:
.srcAddrLow:   ds 1 ; $FFB1: VRAM tiles update source address
.srcAddrHigh:  ds 1 ; $FFB2:
.destAddrLow:  ds 1 ; $FFB3: VRAM tiles update dest address, also source offset from $CE20 when [$D08C] is set
.destAddrHigh: ds 1 ; $FFB4:
.sizeLow:      ds 1 ; $FFB5: VRAM tiles update size
.sizeHigh:     ds 1 ; $FFB6:

;$FFB7..BB: Energy tank graphics, other stuff too though
hBeam_pLow: ; $FFB7: Working projectile pointer (low byte)
hHUD_tank1: ; $FFB7: Energy tank 1 (or E graphic)
hCollision_enY: ds 1 ;$FFB7: Working enemy Y position         in $30EA/$31F1. Two byte address of projectile slot in $1:500D.

hBeam_pHigh: ; $FFB8: Working projectile pointer (high byte)
hHUD_tank2:  ; $FFB8: Energy tank 2
hCollision_enX: ds 1 ;$FFB8: Working enemy X position         in $30EA/$31F1.

hBeam_type: ; $FFB9: Working projectile type
hHUD_tank3: ; $FFB9: Energy tank 3
hCollision_enSprite: ds 1 ;$FFB9: Working enemy sprite ID position in $30EA/$31F1. Working projectile type in $1:500D.

hBeam_waveIndex:  ; $FFBA: Working projectile wave index
hHUD_tank4:       ; $FFBA: Energy tank 4
hCollision_enTop: ds 1 ;$FFBA: Working enemy top boundary       in $30EA/$31F1. Working projectile wave index in $1:500D

hBeam_frameCouter: ; $FFBB: Working projectile frame counter
hHUD_tank5:        ; $FFBB: Energy tank 5
hCollision_enBottom: ds 1 ;$FFBB: Working enemy bottom boundary    in $30EA/$31F1. Working projectile frame counter in $1:500D
hCollision_enLeft:   ds 1 ;$FFBC: Working enemy left boundary      in $30EA/$31F1.
hCollision_enRight:  ds 1 ;$FFBD: Working enemy right boundary     in $30EA/$31F1.
hCollision_enIce:    ds 1 ;$FFBE: Working enemy ice counter
hCollision_enAttr:   ds 1 ;$FFBF: Working enemy flip flags         in $30EA/$31F1


hSamusYPixel::  ds 1 ;$FFC0: Samus' Y position (pixel)
hSamusYScreen:: ds 1 ;$FFC1: Samus' Y position (screen)
hSamusXPixel::  ds 1 ;$FFC2: Samus' X position (pixel)
hSamusXScreen:: ds 1 ;$FFC3: Samus' X position (screen)

hSpriteYPixel: ds 1 ;$FFC4: Sprite Y position (see $5:4015)
hSpriteXPixel: ds 1 ;$FFC5: Sprite X position (see $5:4015)
hSpriteId:     ds 1 ;$FFC6: Sprite set
hSpriteAttr:   ds 1 ;$FFC7: Sprite attributes (see $5:4015)

hCameraYPixel::  ds 1 ;$FFC8: Camera Y position
hCameraYScreen:: ds 1 ;$FFC9: Camera Y position
hCameraXPixel::  ds 1 ;$FFCA: Camera X position
hCameraXScreen:: ds 1 ;$FFCB: Camera X position

hMapSource: ; Coordinates of the source column/row to render to VRAM
.yPixel:  ds 1 ;$FFCC: Row to update    (in pixels)
.yScreen: ds 1 ;$FFCD  (in screens)
.xPixel:  ds 1 ;$FFCE: Column to update (in pixels)
.xScreen: ds 1 ;$FFCF  (in screens)

; $FFD0-$FFDF: Unused ??

;$FFE0..F5: Working enemy data (see $C600..C7FF)
section "HRAM part enemy local", HRAM[$FFE0]
;{
hEnemyWorkingHram:
hEnemy:
.status: ds 1 ; $FFE0 - Active, offscreen, invisible, empty
.yPos: ds 1 ; $FFE1: Enemy Y position (camera space).
.xPos: ds 1 ; $FFE2: Enemy X position (camera space).
;    {
;        Sets $C40E = 0 if less than [Samus' X position on screen] else 2 by $2:45E4.
;        $C386 = [Samus' X position on screen] >= $FFE2.
;        If [$FFE8] = 0, 3 is added, else 3 is subtracted in $2:54D2.
;        Oscillated between 36h and 37h every other frame in $2:5612.
;    }
.spriteType: ds 1 ; $FFE3: Sprite ID when first loaded, and sprite graphic
; The following three variables are XOR'd together to get the sprite attributes for display
.baseAttr: ds 1 ; $FFE4: Enemy base sprite attribute flags (first byte header). Never modified during runtime.
.attr:     ds 1 ; $FFE5: Enemy sprite attribute flags. Modified during runtime.
     ; (Set to 0 if [$FFE8] != 0 else 20h by $2:45FA. XOR'd with 20 in $2:5513)
;    {
;        10h: Palette
;        20h: X flip
;        40h: Y flip
;        80h: BG priority
;    }
.stunCounter: ds 1 ; $FFE6: Stun counter
; Values:
;  $00: Nothing
;  $10: Palette changed, but value does not increment (used for visual component of ice beam)
;  $11-$13: Stunned (increments each frame until $13, then it stops)

.generalVar: ds 1 ; $FFE7: General enemy variable. Usually a counter or a state
.directionFlags: ds 1 ; $FFE8: ; Directional flags. Logical sprite flip direction? Sets $FFE5 to 0 if non-zero else 20h by $2:45FA. Adds 3 to $FFE2 if 0 else subtracts 3 in $2:54D2. XOR'd with 1 in $2:5513
;     - Upper nybble encodes directional vulnerability flags
;         %0001xxxx - resist rightward shots
;         %0010xxxx - left
;         %0100xxxx - up
;         %1000xxxx - down
.counter: ds 1 ;    $FFE9: General enemy variable. Usually behavior counter
.state: ds 1 ; $FFEA: General enemy variable. Usually an enemy state
.iceCounter: ds 1 ; $FFEB: Frozen enemy counter
.health: ds 1 ; $FFEC: Enemy health
.dropType: ds 1 ; $FFED: Drop type: Checked for 0/1/2 in $2:4239
;    {
;        0: None
;        1: Small health
;        2: Large health
;        4 (or otherwise): missile drop
;    }
.explosionFlag: ds 1 ; $FFEE: Enemy explosion and future-drop status
; Values
; - Non-zero - Explosion happening
; - $1x - Explosion type A
; - $2x - Explosion type B
; - $x0 - No drop
; - $x1 - Small health
; - $x2 - Large health
; - $x4 - Missile drop
; $FFE9 is used as an explosion timer when exploding.
.spawnFlag: ds 1 ; $FFEF: Enemy spawn flag
.spawnNumber: ds 1 ; $FFF0: The enemy's number on the map (for respawning)
.pAI_low: ds 1 ; $FFF1: Enemy AI pointer (low byte)
.pAI_high: ds 1 ; $FFF2: Enemy AI pointer (high byte)
.yScreen: ds 1 ; $FFF3: Enemy Y position (in screens in camera-space)
.xScreen: ds 1 ; $FFF4: Enemy X position (in screens in camera-space)
.maxHealth: ds 1 ; $FFF5: Initial health value
; Determines enemy drops (used when setting the explosion flag):
; - If $FD or $FE - No drops
; - If value is even, drop missile
; - If value is >$0A, drop large health
; - Else, drop small health
; - Note: Drops have a 50% chance of happening or being nothing
;}
; $FFF6-$FFFB - Unused?
def hEnemyWramAddrLow  = $FFFC ; WRAM address of current enemy
def hEnemyWramAddrHigh = $FFFD ;  '' high byte

def hEnemy_frameCounter = $FFFE ; Generic frame counter used by enemies - Incremented every other frame
;}