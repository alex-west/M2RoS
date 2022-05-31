section "HRAM", HRAM[$ff80]

;;;; $FF80..FFFE: Hi-RAM ;;;
;{
;$FF80: Input
hInputPressed::
	ds 1
;$FF81: New input
hInputRisingEdge::
	ds 1
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
;$FF82: V-blank handled flag
;
;$FF8C: Set to C0h by update in-game timer and wait a frame. Otherwise unused

; FF8D: OAM buffer index
def hOamBufferIndex = $FF8D
;
;$FF97: Frame counter
;$FF98:
;{
;    Sprite tile number (see $5:4015)
;    Bomb Y position (see $30BB)
;    Projectile Y position (see $31B6)
;    Door scroll flags (see $08FE): [$4200 + [screen Y position, screen] * 16 + [screen X position, screen]]
;    Working projectile direction (see $1:500D)
;    Projectile X offset from Samus (see $1:4E8A)
;}
;$FF99:
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
;$FF9A:
;{
;    Bomb X position (see $1:53AF)
;    Working projectile X position (see $1:500D)
;    Projectile Y offset from Samus (see $1:4E8A)
;}
def gameMode = $FF9B ; Game mode
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
;
section "HRAM OAM DMA Routine", HRAM[$ffa0]
OAM_DMA:: ds $0a ;$FFA0..A9: OAM DMA routine

;$FFAA: VRAM tilemap metatile update address. $FFAA = $9800 + ([row block to update] * 32 + [column block to update]) * 2
;$FFAC: Index of screen for metatile update. $FFAC = [row screen to update] * 16 + [column screen to update]
;$FFAD: Index of block for metatile update. $FFAD = [row block to update] * 16 + [column block to update]
;$FFAE: Number of blocks to update
;$FFAF: Stack pointer for metatile update entries

;$FFB1: VRAM tiles update source address
;$FFB2:
;$FFB3: VRAM tiles update dest address, also source offset from $CE20 when [$D08C] is set
;$FFB4:
;$FFB5: VRAM tiles update size
;$FFB6:

;$FFB7..BB: Energy tank graphics, other stuff too though

;$FFB7: Working enemy Y position         in $30EA/$31F1. Two byte address of projectile slot in $1:500D.
;$FFB8: Working enemy X position         in $30EA/$31F1.
;$FFB9: Working enemy sprite ID position in $30EA/$31F1. Working projectile type in $1:500D.
;$FFBA: Working enemy top boundary       in $30EA/$31F1. Working projectile wave index in $1:500D
;$FFBB: Working enemy bottom boundary    in $30EA/$31F1. Working projectile frame counter in $1:500D
;$FFBC: Working enemy left boundary      in $30EA/$31F1.
;$FFBD: Working enemy right boundary     in $30EA/$31F1.
;
;$FFBF: Working enemy flip flags         in $30EA/$31F1

section "HRAM part 2", HRAM[$ffc0]

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
;$FFCC: Row to update    (in pixels)
;$FFCD
;$FFCE: Column to update (in pixels)
;$FFCF
;
;$FFE0..F5: Working enemy data (see $C600..C7FF)
section "HRAM part enemy local", HRAM[$ffE0]
;{
    ds 1 ; FFE0 - ??
hEnemyYPos: ds 1 ;    $FFE1: Enemy Y position. Incremented in $2:55AC
hEnemyXPos: ds 1 ;    $FFE2: Enemy X position
;    {
;        Sets $C40E = 0 if less than [Samus' X position on screen] else 2 by $2:45E4.
;        $C386 = [Samus' X position on screen] >= $FFE2.
;        If [$FFE8] = 0, 3 is added, else 3 is subtracted in $2:54D2.
;        Oscillated between 36h and 37h every other frame in $2:5612.
;    }
;    $FFE3: Sprite ID
;    $FFE4: Set to 20h in $2:5895
;    $FFE5: Enemy flip flags. Set to 0 if [$FFE8] != 0 else 20h by $2:45FA. XOR'd with 20 in $2:5513
;    {
;        20h: X flip
;        40h: Y flip
;    }
;
;    $FFE7: Incremented in $2:514A and $2:55AC
;    $FFE8: Sets $FFE5 to 0 if non-zero else 20h by $2:45FA. Adds 3 to $FFE2 if 0 else subtracts 3 in $2:54D2. XOR'd with 1 in $2:5513
;
;   $FFE9: Enemy behavior counter (?)
;
;    $FFEC: Enemy health
;    $FFED: Checked for 0/1/2 in $2:4239
;    {
;        0: ?
;        1: Small health
;        2: Large health
;        Otherwise: missile drop
;    }
;    $FFEE: Tested in $2:4239
;    $FFEF: Compared with 3 in places in bank 2
;
;    $FFF1: Jump target via $2:5648
;}
;
;$FFFC: Enemy address in $2:409E
;$FFFE: Enemy frame counter (animation?)
;}