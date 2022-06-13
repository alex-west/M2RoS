; WRAM

section "WRAM Bank0", wram0[$c000]

;;;; $C000..CFFF: WRAM bank 0 ;;;
;{
OAM_MAX = $a0 ; 160 bytes -> 40 hardware sprites
wram_oamBuffer:: ds $A0 ; $C000
;$C000..9F: OAM
;{
;    + 0: Y position
;    + 1: X position
;    + 2: Tile number
;    + 3: Attributes
;         10: Palette
;         20: X flip
;         40: Y flip
;         80: Priority (set: behind background)
;}
;
;$C203: Tile Y (see $22BC)
;$C204: Tile X (see $22BC)
;$C205: Scroll Y
;$C206: Scroll X
;
;$C215: Tilemap address of ([$C204], [$C203]) (see $22BC)
;
;$C219: Game over LCD control mirror. This variable is pretty much useless, set to 0 on boot and to C3h by game over, checked for bitset 8 by $2266 (get tilemap value)
;{
;    v = emwdMsob
;
;    e: Enable LCD
;    m: Window tilemap base address. 0 = $9800, 1 = $9C00
;    w: Enable window
;    d: Tiles base address. 0 = $8800, 1 = $8000
;    M: BG tilemap base address. 0 = $9800, 1 = $9C00
;    s: Sprite size. 0 = 8x8, 1 = 8x16
;    o: Enable sprite
;    b: Enable BG. If CGB, then 0 additionally disables window regardless of w
;}
;
def spriteC300 = $C300 ;$C300..3D: Set to [$2:4FFE..503A] in $2:4DB1
;{
;    $C302/06: Set to DFh in $2:4EA1 if [$C382] = 0, set to E2h if [$C382] = 1, set to E3h if [$C382] = 2
;    $C30A/0E: Set to E1h in $2:4EA1 if [$C382] = 0
;    $C312/16/1A: XOR'd with 7 in $2:4EA1
;    $C322/2E: XOR'd with Dh in $2:4EA1
;    $C334: Set to E8h in $2:4EA1 if [$C382] = 0
;}
;$C308..37: Metroid Queen neck OAM. Ch slots of 4 bytes (Y position, X position, tile number, attributes)
;
def hitboxC360 = $C360 ;-$C363: Set to [$2:503B..3E] in $2:4DB1
;
;$C380: Cleared in $2:4DB1. Used as index in $2:4FD4
;$C381: Timer for $2:4EA1
;$C382: Set to 0 in $2:4FB9, set to 1/2/3 in $2:4EA1, stage index for $2:4EA1
;
;$C386: Set to Samus is right of enemy in $2:4F87
;
;$C390: Set to 0 in $2:5144
;$C391: Set to 20h in $2:5144
;$C392: Set to 5 in $2:513F
;
;$C3A1: LCD interrupt handler scroll X
;
;$C3A8: X position of Metroid Queen's head on screen
;$C3A9: Y position of Metroid Queen's head on screen
;$C3AA: Pointer to LCD interrupt data
;$C3AC: min(8Fh, [Y position of Metroid Queen's head on screen] + 26h])
;$C3AD: LCD interrupt Y position
;$C3AE..B6: LCD interrupt data. 4 slots of 2 bytes and a FFh terminator
;{
;    01 yy: Set scroll X and background palette.          LCD interrupt Y position = yy. End
;    02 yy: Update scroll X and background palette = 93h. LCD interrupt Y position = yy. End
;    03 yy: Disable window display.                       LCD interrupt Y position = yy. End
;    81 yy: Set scroll X and background palette.          Process next instruction
;    82 yy: Update scroll X and background palette = 93h. Process next instruction
;    83 yy: Disable window display.                       Process next instruction
;    FFh: End
;    Otherwise: Disable window display, scroll X = 0, scroll Y = 70h. End
;}
;
def queenAnimFootCounter = $C3C8 ; Metroid Queen's foot animation frame. Very similar to the head. Cleared in $3:6E36
def queenAnimFootDelay = $C3C9;

;$C3CA: Metroid Queen's head animation frame. FFh = resume previous tilemap update, 0 = disabled, 1 = frame 0, 2 = frame 1, otherwise frame 2. Cleared in $3:6E36
;
;$C3D2: LCD interrupt handler background palette
;$C3D3: Metroid Queen health
;
;$C3E0: Cleared in $3:6E36
;
;$C3EF: Set to 1 in $3:6E36 if 0 < [Metroid Queen's health] < 32h, probably an aggression flag
;
;$C3F1: Set to 1 in $3:6E36 if 0 < [Metroid Queen's health] < 64h, probably an aggression flag
;$C3F2: Metroid Queen's head lower half tilemap VRAM address low byte
;$C3F3: Metroid Queen's head lower half tilemap source address (bank 3)
;
enemySolidityIndex = $C407 ; Copy of enemySolidityIndex_canon (actually used by enemy code)
;$C408: Scroll Y three frames ago (according to $2:45CA)
;$C409: Scroll X three frames ago (according to $2:45CA)
;$C40A: Scroll Y two frames ago (according to $2:45CA)
;$C40B: Scroll X two frames ago (according to $2:45CA)
;$C40C: Scroll Y one frame ago (according to $2:45CA)
;$C40D: Scroll X one frame ago (according to $2:45CA)
;$C40E: Set to 0 if [$FFE2] < [Samus' X position on screen] else 2 by $2:45E4
;
;$C418: Set to [room bank] in $2:4000
;
;$C41B: Checked and cleared in $2:4000, 90h frame timer?
;$C41C: Cleared in $2:4000/$2:412F
;
;$C41E: Mirror of enemy Y position
;$C41F: Mirror of enemy X position
;
;$C422: Samus damage flag
;$C423: Damage boost direction
;{
;    0: Up
;    1: Up-right
;    FFh: Up-left
;}
;$C424: Samus damage
;$C425: Number of enemies
;$C426: Cleared in $2:412F/$2:4217. Incremented when number of enemies is incremented in enemy loading
;$C427: Cleared in $2:4217
;
;$C42E: Set to enemy Y position in $1:5A9A
;$C42F: Set to enemy X position in $1:5A9A
;$C430: Set to enemy sprite ID in $1:5A9A. Used as index for pointer table at $1:5AB1
;$C431: Set to XOR of enemy bytes 4/5/6 AND F0h in $1:5A9A
;$C432: Scroll Y two frames ago (according to $3:4000)
;$C433: Scroll Y one frame ago (according to $3:4000)
;$C434: Scroll X two frames ago (according to $3:4000)
;$C435: Scroll X one frame ago (according to $3:4000)
;$C436: Executes $2:412F in $2:4000 if zero, set to 1 afterwards. Flag for updating $C540..7F. Cleared when exiting Metroid Queen's room, and when loading from save
;
;$C438: Enemy handling incomplete flag. In $2:409E, if 0: sets $C439 = [number of enemies]
;$C439: Current enemy index
;
;$C44B: Request to execute $2:418C (save/load spawn/save flags). Set by doorExitStatus in the door script function
;
;$C44D: Tile Y relative to scroll Y (see $2250)
;$C44E: Tile X relative to scroll X (see $2250)
;$C450: Enemy data address in $3:422F
;$C452: Enemy data address in $2:409E
;$C454: Enemy data address in $1:5A11
;
;$C458: doorExitStatus - $2 is normal, $1 is if WARP or ENTER_QUEEN is used. Value is written to $C44B and then cleared
def previousLevelBank = $C459 ; Previous level bank --- used during door transitions to make sure that the enemySaveFlags are saved to the correct location
;
;$C45C: Used as index for table at $1:729C, value for $FFEA
;
;$C463: Metroid is hatching flag (freeze time)
;$C464: Metroid invincibility timer
;$C465: Checked and cleared in $2:4000, cleared in $2:412F
;$C466..69: Set to [$D05D..60] in $2:438F
;
;$C46D: Set to FFh in $2:412F. Value for $D06F in $2:4DD3
;
;$C474: Cleared in $2:4000
;$C475: Cleared in $2:4000
;
;$C477: Set to 6 in $2:4F97
;

; These two arrays follow the same format, but one is saved and the other is not.
def enemySpawnFlags = $C500 ;$C500..3F: Filled with FFh by $2:418C. Apparently off-screen enemy bytes for current map
def enemySaveFlags  = $C540 ;$C540..7F: Working copy of $C900 data for room bank. Apparently item/Metroid data bytes for current map
;{
;    For metroid:
;        1: Hatching
;        2: Dead
;        4: Alive
;        FFh: Not active
;    
;    For missile door:
;        1: Active
;        2: Destroyed
;        FFh: Not active
;        
;    For item:
;        1: Active
;        2: Collected
;        FFh: Not active
;
;    $1:7A6C:
;        Copies 40h bytes to $C900 + ([$C459] - 9) * 40h from $C540, only 02 and FEh are written, with 04 translated to FEh
;        Then writes out all of $C900..CABF to SRAM
;    
;    $2:418C:
;        If [$C459] != 0:
;            Copies 40h bytes to $C540 from $C900 + ([$C459] - 9) * 40h, only 02 and FEh are written, with 04/05 translated to FEh
;        Then copies 40h bytes to $C900 + ([$C459] - 9) * 40h from $C540
;    
;    $2:412F:
;        Copies 40h bytes to $C540 from $C900 + ([$C459] - 9) * 40h (verbatim)
;    
;    Read at $3:4205 (metroid checking if it should spawn?)
;}
;
;$C600..C7FF: Enemy data. 20h byte slots
;{
;    + 0: If bits 0..3 clear, collision with projectiles/bombs/Samus is enabled. If zero, sprite set is not drawn. If FFh, enemy is deleted
;    + 1: Y position. Relative to screen top boundary - 10h. Value for $FFB7 in $30EA
;    + 2: X position. Relative to screen left boundary - 8. Value for $FFB8 in $30EA
;    + 3: Sprite ID. Value for $FFB9 in $30EA
;    + 4..Ch: Enemy header
;    {
;        + 5: Flip flags. Value for $FFBF in $30EA
;        {
;            20h: X flip
;            40h: Y flip
;        }
;
;        + Ch: Health
;    }
;    
;    + 11h: Initial health
;    
;    + 1Ch: Copy of enemy's $C500 byte
;    + 1Dh: Enemy map ID. Used to $C500
;    + 1Eh: AI pointer(?)
;}
;
saveBuf_enemySaveFlags = $C900 ;$C900..CABF: Copied to/from SRAM ($B000 + [save slot] * 200h). 40h byte slots, one for each level data bank
;
;$CEC0..CFFF: Audio data
;{
;    ; Song / sound effect is requested by writing directly to $CEDC/$CEC0/$CEC7/$CFE5/$CED5/$CEDE
;    ; Audio is paused/unpaused by writing directly to $CFC7
;    ; The rest of audio data RAM is fully managed by code in bank 4
;    
;    $CEC0: Tone/sweep channel sound effect
;    {
;        $CEC0: Tone/sweep channel sound effect to play (rename to request)
;        {
;            0: Nothing
;            1: Jumping
;            2: Hi-jumping
;            3: Screw attacking
;            4: Uncrouching / turning around / landing / hurt by spike
;            5: Crouching / unmorphing
;            6: Morphing
;            7: Shooting beam
;            8: Shooting missile
;            9: Shooting ice beam
;            Ah: Shooting plasma beam
;            Bh: Shooting spazer beam
;            Ch: Picked up missile drop
;            Dh: Spider ball
;            Eh: Picked up small energy drop
;            Fh: Shot missile door with beam (maybe certain enemies too?)
;            10h: (set in $2:6A14)
;            11h: Unused
;            12h: Unused
;            13h: Bomb laid
;            14h: Unused
;            15h: Option select / missile select
;            16h: Shooting wave beam
;            17h: Picked up large energy drop
;            18h: Samus' health changed
;            19h: No missile dud shot
;            1Ah: (set in $2:6BB2 and other places in bank 2)
;            1Bh: Metroid cry
;            1Ch: Saved
;            1Dh: Varia suit transformation
;            1Eh: Unpaused
;
;            2Dh: Set in $2:79A8 (might be a hack to use 0Fh's sound effect playing routine by overflowing jump table in bank 4)
;        }
;        $CEC1: Tone/sweep channel sound effect playing
;
;        $CEC3: Tone/sweep channel sound effect timer
;    }
;
;    $CEC7: Tone channel sound effect
;    {
;        $CEC7: Tone channel sound effect to play
;        {
;            0: Nothing
;            1: Nothing
;            2: Nothing
;            3: Metroid Queen cry
;            4: Baby Metroid hatched / clearing blocks
;            5: Baby Metroid cry
;            6: Metroid Queen hurt cry
;            7: Set in $2:6540 when $FFEF % 10h = 0
;        }
;        $CEC8: Tone channel sound effect playing
;
;        $CECA: Tone channel sound effect timer
;    }
;
;    $CECE..CED4: Would be the wave channel sound effect, but is unused (only cleared) and $CEE6/$CFE5 is used instead.
;
;    $CED5: Noise channel sound effect
;    {
;        $CED5: Noise channel sound effect to play
;        {
;            FFh: Clear sound effect and disable noise channel
;            0: Nothing
;            1: Enemy shot
;            2: Enemy killed
;            3: Set in bank 2
;            4: Shot block destroyed
;            5: Metroid hurt
;            6: Samus hurt
;            7: Acid damage
;            8: Shot missile door with missile (maybe certain enemies too?)
;            9: Metroid Queen cry
;            Ah: Metroid Queen hurt cry
;            Bh: Samus killed
;            Ch: Bomb detonated
;            Dh: Metroid killed
;            Eh: Set in bank 2
;            Fh: Cleared save file
;            10h Footsteps
;            11h: Set in bank 2
;            12h: Set in bank 2
;            13h: Unused
;            14h: Set in bank 2
;            15h: Set in bank 2
;            16h: Baby Metroid hatched / clearing blocks
;            17h: Baby Metroid cry
;            18h: Set in bank 2
;            19h: Unused
;            1Ah: Set in bank 2
;        }
;        $CED6: Noise channel sound effect playing
;
;        $CED8: Noise channel sound effect timer
;    }
;
;    $CEDC: Song to play
;    {
;        0: Nothing
;        1: Baby Metroid
;        2: Metroid Queen battle
;        3: Chozo ruins
;        4: Main caves
;        5: Sub caves 1
;        6: Sub caves 2
;        7: Sub caves 3
;        8: Final caves
;        9: Metroid hive
;        Ah: Item-get
;        Bh: Metroid Queen hallway
;        Ch: Metroid battle
;        Dh: Sub caves 4
;        Eh: Earthquake
;        Fh: Killed Metroid
;        10h: Nothing
;        11h: Title
;        12h: Samus fanfare
;        13h: Reached the gunship
;        14h: Chozo ruins, same as 3
;        15h: Main caves, no intro
;        16h: Sub caves 1, no intro
;        17h: Sub caves 2, no intro
;        18h: Sub caves 3, no intro
;        19h: Final caves, same as 8
;        1Ah: Metroid hive, same as 9
;        1Bh: Item-get, same as Ah
;        1Ch: Metroid Queen hallway, same as Bh
;        1Dh: Metroid battle, same as Ch
;        1Eh: Sub caves 4, no intro
;        1Fh: Metroid hive with intro
;        20h: Missile pickup
;    }
;    $CEDD: Song playing
;    $CEDE: Isolated sound effect to play
;    {
;        1: Play item-get music
;        3: End isolated sound effect
;        5: Play missile pickup music
;        8: Fade out music
;        Eh: Play earthquake music
;        FFh: Clear isolated sound effect
;        Otherwise: nothing
;    }
;    $CEDF: Isolated sound effect playing
;    {
;        2: End isolated sound effect
;        8: Fade out music
;        Otherwise: Nothing
;    }
;
;    $CEE4: Current tone/sweep channel sound effect
;    $CEE5: Current tone channel sound effect
;    $CEE6: Low health beep / wave channel sound effect
;    {
;        0: Samus' health >= 50
;        1: Samus' health < 20
;        2: Samus' health < 30
;        3: Samus' health < 40
;        4: Samus' health < 50
;    }
;    $CEE7: Current noise channel sound effect
;
;    $CF00..60: Song processing state
;    {
;        $CF00: Transpose
;        $CF01: Instruction timer array pointer
;        $CF03: Working sound channel (1/2/3/4)
;        $CF04: Set to 1 if [$CF38] != 0 in $48A0
;        $CF05: Set to 2 if [$CF41] != 0 in $48A0
;        $CF06: Set to 3 if [$CF4A] != 0 in $48A0
;        $CF07: Set to 4 if [$CF53] != 0 in $48A0
;        $CF08: Checked to mirror $CF0B/0C to $CF10/11 in $497A
;        $CF09: Pointer to wave pattern data, 10h bytes
;        $CF0B: Working sound channel sweep / enable
;        $CF0C: Working sound channel sound length / wave pattern duty
;        $CF0D: Working sound channel envelope / volume
;        $CF0E: Working sound channel frequency / noise channel polynomial counter
;        $CF0F: Working noise channel counter control (upper byte of working sound channel frequency)
;        $CF10..23: Audio channel options (which conveniently correspond with FF10..23)
;        {
;            $CF10: Tone/sweep channel sweep
;            $CF11: Tone/sweep channel sound length / wave pattern duty
;            $CF12: Tone/sweep channel envelope
;            $CF13: Tone/sweep channel frequency
;            $CF15: Unused
;            $CF16: Tone channel sound length / wave pattern duty
;            $CF17: Tone channel envelope
;            $CF18: Tone channel frequency
;            $CF1A: Wave channel enable
;            $CF1B: Wave channel sound length
;            $CF1C: Wave channel volume (0 = mute, 20h = 100%, 40h = 50%, 60h = 25%)
;            $CF1D: Wave channel frequency
;            $CF1F: Unused
;            $CF20: Noise channel sound length
;            $CF21: Noise channel envelope
;            $CF22: Noise channel polynomial counter
;            $CF23: Noise channel counter control
;        }
;
;        $CF26: Song tone/sweep channel instruction pointer
;        $CF28: Song tone channel instruction pointer
;        $CF2A: Song wave channel instruction pointer
;        $CF2C: Song noise channel instruction pointer
;        $CF2E: A 12 frame timer
;        $CF2F..37: Working channel song processing state
;        {
;            $CF2F: Instruction pointer list, an 'instruction pointer' of 00F0 followed by pppp means to go to pppp, 0000 means end of list.
;            {
;                Instruction format:
;                    00:          End of instruction list
;                    ii:          For 9F <= ii <= F0h. Instruction timer = [[$CF01] + (ii & ~A0h)]
;                    F1 ee ss ll: For non-wave channels.
;                                     Working sound channel envelope = ee
;                                     Working sound channel sweep = ss
;                                     Working sound channel sound length / wave pattern duty = ll
;                    F1 pppp vv:  For the wave channel.
;                                     Pointer to wave pattern data = pppp
;                                     Working sound channel volume = vv
;                    F2 pppp:     Set tempo: $CF01 = pppp
;                    F3 oo:       Set transpose: $CF00 = oo. (Add oo to any played music notes)
;                    F4 nn:       Repeat from after this instruction nn times |: (sets $CF31/$CF33)
;                    F5:          Repeat :| (decrements $CF31)
;                    ii:          For ii >= F6h. Clear sound effects and song
;                    oo ii:       For 00 < oo < 9Fh:
;                        oo 01:   Mute working sound channel
;                        oo 03:   For non-noise channels. If fading out music: working sound channel envelope / volume = 8, else working sound channel envelope / volume = 66h. Set working sound channel frequency
;                        oo 05:   For non-noise channels. If fading out music: working sound channel envelope / volume = 8, else working sound channel envelope / volume = 46h. Set working sound channel frequency
;                        oo ii:   Otherwise. For non-noise channels. Working sound channel frequency = [music notes + [ii]], working sound channel envelope = [$CF35]
;                        oo ii:   Otherwise. For the noise channel:
;                                     Working sound channel sound length       = [$41BB + ii]
;                                     Working sound channel envelope           = [$41BB + ii + 1]
;                                     Working sound channel polynomial counter = [$41BB + ii + 2]
;                                     Working sound channel counter control    = [$41BB + ii + 3]
;            }
;            $CF31: Repeat count
;            $CF33: Repeat point
;            $CF34: Instruction length
;            $CF35: Sound envelope / volume
;            $CF36: Instruction timer
;            $CF37: Sound length (according to song instruction F1h)
;        }
;        $CF38..40: Tone/sweep channel song processing state
;        $CF41..49: Tone channel song processing state
;        $CF4A..52: Wave channel song processing state
;        $CF53..5B: Noise channel song processing state
;        $CF5C: Song fadeout timer. Set to D0h when initiating fading out music
;        {
;            0: Song play = isolated sound effect to play = 0, disable sound channels
;            10h: Sound envelope / volume = 13h
;            30h: Sound envelope / volume = 25h
;            70h: Sound envelope / volume = 45h. Disable noise channel. Wave channel volume = 60h
;            A0h: Sound envelope / volume = 65h
;        }
;        $CF5D: Set to tone/sweep sound envelope when fading out music. Never read
;        $CF5E: Set to tone sound envelope when fading out music. Never read
;        $CF5F: Set to wave volume when fading out music. Never read
;        $CF60: Tone channel frequency tweak. Set to 1 if [$5F30 + ([song to play] - 1) * 2] & 1 in $48A0
;    }
;    $CF61..C1: Backup of song processing state (during isolated sound effect)
;
;    $CFC5: Backup of song playing (during isolated sound effect)
;
;    $CFC7: Audio pause control
;    {
;        1: Pause (play pause sound effect, stop other music)
;        2: Unpause (play unpause sound effect)
;    }
;    $CFC8: Audio pause sound effect timer
;    $CFC9: Backup of tone/sweep channel sweep (during isolated sound effect)
;
;    $CFE3: Mirror of pointer to wave pattern data (set by song instruction F1 pppp vv)
;    $CFE5: Low health beep / wave channel sound effect to play
;    $CFE6: Low health beep / wave channel sound effect playing
;    $CFE7: Backup of low health beep sound effect playing (during isolated sound effect)
;    $CFE8:
;    $CFE9:
;    $CFEA: Unused
;    $CFEB: Cleared by $43C4, otherwise unused
;    $CFEC: Audio channel output stereo flags
;    $CFED: Backup of audio channel output stereo flags (during isolated sound effect)
;    $CFEE: 
;}
;}
;
;
;;;; $D000..DFFF: WRAM bank 1 ;;;
;{
;$D000..07: Unused
;$D008: Metatile top-left
;$D009: Metatile top-right
;$D00A: Metatile bottom-left
;$D00B: Metatile bottom-right
;$D00C: Samus' previous Y position. Used for scrolling, low byte only
;$D00D: Auto-fire cooldown counter
def doorScrollDirection = $D00E ; Door transition direction
;{
;    1: Right
;    2: Left
;    4: Up
;    8: Down
;}
;$D00F: Current damage boosting direction (set to $C423 during damage boost)
;{
;    0: Up
;    1: Up-right
;    FFh: Up-left
;}
;$D010: Counter for spin-jumping
;$D011: Nothing. Only cleared
;$D012: Value for $D060 in $31F1. Projectile direction in $1:500D
;
def samusPose = $D020 ; Samus' pose
;{
;    00: Standing
;    01: Jumping
;    02: Spin-jumping
;    03: Running (set to 83h when turning)
;    04: Crouching
;    05: Morphball
;    06: Morphball jumping
;    07: Falling
;    08: Morphball falling
;    09: Starting to jump
;    0A: Starting to spin-jump
;    0B: Spider ball rolling
;    0C: Spider ball falling
;    0D: Spider ball jumping
;    0E: Spider ball
;    0F: Knockback
;    10: Morphball knockback
;    11: Standing bombed
;    12: Morphball bombed
;    13: Facing screen
;    18: Being eaten by Metroid Queen
;    19: In Metroid Queen's mouth
;    1A: Being swallowed by Metroid Queen
;    1B: In Metroid Queen's stomach
;    1C: Escaping Metroid Queen
;    1D: Escaped Metroid Queen
;}
;
;$D022: += 3 in $08FE during door transition
;$D023: Direction of screen movement
;{
;    10: Right
;    20: Left
;    40: Up
;    80: Down
;}
;$D024: Weird air time variable, increments to 16h when falling
;
;$D026: Weird air time variable, set to 40h by $2EE3, set to 50h when escaping Metroid Queen's mouth
;$D027: Samus' previous X position
;$D029: Samus' previous Y position
def samusFacingDirection = $D02B ; Direction Samus is facing. Saved to SRAM, mirror of $D81E?
;{
;    0: Left
;    1: Right
;}
;$D02C: Samus animation counter
;
;$D032: Projectile index
;$D033: Cleared by morph
;
;$D035: Screen right velocity
;$D036: Screen left velocity
;$D037: Screen up velocity
;$D038: Screen down velocity
;$D039: Set to 0 by load title screen, otherwise unused
;
;$D03B: Samus' Y position on screen
;$D03C: Samus' X position on screen
;$D03D: Spider ball orientation
;{
;    0: In air
;    1: On bottom-left corner of ledge
;    2: On top-left corner of ledge
;    3: On left-facing wall
;    4: On bottom-right corner of ledge
;    5: On ceiling
;    6: Unused
;    7: On meet of left-facing wall and ceiling
;    8: On top-right corner of ledge
;    9: Unused
;    Ah: On floor
;    Bh: On meet of left-facing wall and floor
;    Ch: On right-facing wall
;    Dh: On meet of right-facing wall and ceiling
;    Eh: On meet of right-facing wall and floor
;    Fh: Unused
;}
;
;$D042: Spider ball translational direction
;{
;    1: Right
;    2: Left
;    4: Up
;    8: Down
;}
;
;$D044: Spider ball rotational direction
;{
;    0: Not moving
;    1: Anti-clockwise
;    2: Clockwise
;}
def samusItems = $D045 ; Samus' equipment
    def itemMask_bomb   = %00000001 ; 01: Bombs
	def itemMask_hiJump = %00000010 ; 02: Hi-jump
	def itemMask_screw  = %00000100 ; 04: Screw attack
	def itemMask_space  = %00001000 ; 08: Space jump
	def itemMask_spring = %00010000 ; 10: Spring ball
	def itemMask_spider = %00100000 ; 20: Spider ball
	def itemMask_varia  = %01000000 ; 40: Varia suit
	def itemMask_UNUSED = %10000000 ; 80: Unused
	; For BIT instructions
	def itemBit_bomb   = 0
	def itemBit_hiJump = 1
	def itemBit_screw  = 2
	def itemBit_space  = 3
	def itemBit_spring = 4
	def itemBit_spider = 5
	def itemBit_varia  = 6
	def itemBit_UNUSED = 7

def debugItemIndex = $D046 ; Debug screen selector index
;$D047: VRAM tiles update flag (see $FFB1..B6, $2BA3, $27BA)
;$D048: Cleared by $0D21
;$D049: Timer for something
;
;$D04C: Cleared by handle loading blocks due to scrolling, set to FFh in a few places. Never read
def samusActiveWeapon = $D04D ; Weapon equipped.  See also $D055
;{
;    0: Normal
;    1: Ice
;    2: Wave
;    3: Spazer
;    4: Plasma
;    8: Missile
;}
def bankRegMirror = $D04E ;Bank
def samusInvulnerableTimer = $D04F ; Invincibility timer
def samusEnergyTanks   = $D050 ; Samus' max health, in tanks,     see also $D817
def samusEnergyTanks   = $D050 ; Samus' max health, in tanks,     see also $D817
def samusCurHealthLow  = $D051 ; Samus' current health,           see also $D818/$D084
def samusCurHealthHigh = $D052 ; Samus' current health (in tanks) see also $D819/$D085

def samusCurMissilesLow  = $D053 ; Samus' missiles (low byte)     see also $D81C
def samusCurMissilesHigh = $D054 ; Samus' missiles (high byte)

def samusBeam = $D055 ; Current beam that Samus owns. See also $D04D/$D816
;{
;    0: Normal
;    1: Ice
;    2: Wave
;    3: Spazer
;    4: Plasma
;}
samusSolidityIndex = $D056 ; Samus solid block threshold
;$D057: Room sprite priority
;{
;    0: Sprites over BG
;    1: BG over sprites
;}
def currentLevelBank = $D058 ; Bank for current room
def deathAnimTimer = $D059 ; Death sequence timer
;$D05A: Base address of pixels to clear in Samus' VRAM tiles
;$D05C: $32AB acknowledgement flag. $32AB acknowledges this when it executes, cleared every in-game frame. $32AB is called by in-game and item pickup sequence.
;$D05D..60: Values for $C466..69 in $2:438F. Guess: generic collision information
;{
;    $D05D: Set to 9 if enemy bombed. Set to [$D08D] if shot. Set to FFh in $03B5
;    $D05E: Set to enemy data pointer if enemy bombed
;    $D060: Set to [$D012] if shot
;}
;
def acidContactFlag = $D062 ; Flag set every frame if Samus is touching acid.
def deathFlag = $D063 ; Dying flag
;{
;    0: Not dying
;    1: Dying
;    FFh: Dead
;}
;$D064: Used in $239C as new OAM stack pointer, set to OAM stack pointer in $04DF (in-game)
;$D065: VRAM tiles update source bank (see $FFB1..B6, $2BA3)
countdownTimerLow = $D066;  ; Generic countdown timer used for
countdownTimerHigh = $D067; ;  various events
;{
;    Decremented during v-blank interrupt handler.
;    Set to 140h on loading Samus. Whilst set, Samus can't move when facing screen and low health beep doesn't play.
;    Set to 2Fh on door fade, cleared on Dh, used as index for palette fade.
;    Set to FFh on game over, reboots on 0.
;    Set to 160h by ability-get, 60h for missile-get, 0 for refill. Whilst set, varia suit and other pickups stall.
;    Set to FFFFh on load title screen. Checked as timer for title screen flashing
;    Used in many other places in bank 5
;}
;
enemySolidityIndex_canon = $D069 ; Canonicaly copy of the enemy solid block threshold (not used by enemy code, however)
;
;$D06B: Unused. Cleared by loading save
;$D06C: Item pickup. Set to ([enemy sprite ID] - 81h) / 2 + 1 by $2:4DD3
;{
;    1: Plasma
;    2: Ice
;    3: Wave
;    4: Spazer
;    5: Bomb
;    6: Screw attack
;    7: Varia
;    8: Hi-jump
;    9: Space jump
;    Ah: Spider ball
;    Bh: Spring ball
;    Ch: Energy expansion
;    Dh: Missile expansion
;    Eh: Energy refill
;    Fh: Missile refill
;}
;$D06D: Cleared by loading save. Stop the status bar from updating
def maxOamPrevFrame = $D06E ; OAM slots used in by the previous frame
;$D06F: Mirror of $C46D? $C466?
;$D070: Mirror of $FFFC? $C467?
;$D072: Incremented by $0D21 and $08FE
def credits_textPointerLow  = $D073 ; Pointer to the working copy of the credits in SRAM. Stops being incremented when it hits the byte $F0. Character data is subtracted by $21 to adjust to almost-ASCII
def credits_textPointerHigh = $D074 ;
def credits_nextLineReady = $D076 ; Flag to indicate that the next line of the credits is ready to be uploaded

def acidDamageValue = $D077 ; Acid damage. Saved to SRAM
def spikeDamageValue = $D078 ; Spike damage. Saved to SRAM
;$D079: Flag to load characters. But also used in facing screen as a flag to check if buttons are pressed. Also an flag for selecting the clear save slot option
;$D07A: Save slot option selected
;{
;    0: Start
;    1: Clear
;}
def titleStarY = $D07B ; Star Y position
def titleStarX = $D07C ; Star X position
;$D07D: On save pillar flag
;{
;    0: Not on save pillar
;    FFh: On save pillar
;}
def bg_palette  = $D07E ; BG palette
def ob_palette0 = $D07F ; Object 0 palette
def ob_palette1 = $D080 ; Object 1 palette

def samusMaxMissilesLow  = $D081 ; Samus' max missiles, see also $D81A
def samusMaxMissilesHigh = $D082 ; Samus' max missiles (high byte)
;$D083: Earthquake timer (how long the earthquake itself lasts)
def samusDispHealthLow  = $D084 ; Samus' health for display,   see also $D051/$D818
def samusDispHealthHigh = $D085 ; Samus' energy tanks for display, see also $D052/$D819
def samusDispMissilesLow  = $D086 ; Samus' missiles for display, see also $D053/$D81C
def samusDispMissilesHigh = $D087 ; Samus' missiles for display (high byte)
;$D088: Game save cooldown timer
def metroidCountReal = $D089 ; Real number of metroids remaining (BCD)
def beamSolidityIndex = $D08A ; Projectile solid block threshold
;$D08B: Metroid Queen's room flag. 11h: In Metroid Queen's room (set by screen transition command 8)
;$D08C: Would have guessed a flag for 'can do tiles update' or 'is lag frame'
;$D08D: Value for $D05D in $31F1. Projectile type in $1:500D
def doorIndexLow  = $D08E ; Index of screen transition command set. Set to [$4300 + ([screen Y position high] * 10h + [screen X position high]) * 2] & ~800h by set up door transition
def doorIndexHigh = $D08F
;$D090: Metroid Queen eating pose
;{
;    Sets Samus pose = escaping Metroid Queen when 7, checked for 5/20h and set to 6 in in Metroid Queen's mouth
;    0: Otherwise
;    1: Samus entering mouth
;    2: Mouth closing
;    3: Mouth closed
;    4: Bombed whilst mouth closed
;    5: Samus escaping mouth
;    6: Swallowing Samus
;    7: Bombed whilst swallowing Samus
;    8: Samus escaping stomach
;    10h: Paralysed (can enter mouth)
;    20h:
;    22h: Dying
;}
def earthquakeTimer = $D091 ; Time until next Metroid earthquake. Counts down in $100h frame intervals after killing a metroid.
def currentRoomSong = $D092 ; Song for room. Used when restoring song when loading a save and after some other events
;$D093: Mirror of $D06C?
;$D094: Mirror of $FFE1?
;$D095
;$D096: Metroids remaining shuffle timer
def credits_samusAnimState = $D097 ; Samus' animation state during the credits
def gameTimeMinutes = $D098 ; In-game timer, minutes
def gameTimeHours   = $D099 ; In-game timer, hours
def metroidCountDisplayed = $D09A ; Number of Metroids remaining (displayed, not real)
;$D09B: Fade in timer. Max value of 3Fh, is set to zero when Dh reached
def credits_runAnimFrame   = $D09C ; Tracks current animation frame of run animation
def credits_runAnimCounter = $D09D ; Counts video frames between animation frames
;$D09E: Flag to play room song
def credits_scrollingDone  = $D09F ; Flag to indicate if credits stopped scrolling (allows timer to display)
def debugFlag = $D0A0 ; Activates debug pause menu and other stuff
;$D0A1: Previous low health
def gameTimeSeconds = $D0A2 ; 256-frames long (~1/14 of a minute), not 60 frames long. In-game time, but not saved
def activeSaveSlot = $D0A3 ; Save slot
;$D0A4: Show clear save slot option flag
;$D0A5: Song to play after earthquake
;$D0A6: Enable Baby Metroid cry
;$D0A7: Metroids remaining in area
;$D0A8: Set to 0 by $239C
;
;$D0F9: Used in title
;
def credits_starArray = $D600 ; ds $20 (inadvertantly, only the first $10 bytes are properly initialized)
;
def doorScriptBuffer = $D700 ; to D73F: Screen transition commands (see $5:46E5)
	def doorScriptBufferSize = $40
;

section "WRAM SaveBuffer", wramx[$d800]
;$D800..25: Save data. Data loaded from $1:4E64..89 by game mode Bh, loaded from $A008..2D + save slot * 40h by game mode Ch
;{
saveBuffer: ; $26 bytes
saveBuf_samusYPixel:  ds 1 ; $D800: Samus' Y position
saveBuf_samusYScreen: ds 1 ; $D801: Samus' Y position
saveBuf_samusXPixel:  ds 1 ; $D802: Samus' X position
saveBuf_samusXScreen: ds 1 ; $D803: Samus' X position

saveBuf_cameraYPixel:  ds 1 ; $D804: Camera Y position
saveBuf_cameraYScreen: ds 1 ; $D805: Camera Y position
saveBuf_cameraXPixel:  ds 1 ; $D806: Camera X position
saveBuf_cameraXScreen: ds 1 ; $D807: Camera X position

; Implicitly bank 6
saveBuf_enGfxSrcLow:  ds 1 ; $D808: Enemy tiles source address (low byte)
saveBuf_enGfxSrcHigh: ds 1 ; $D809: Enemy tiles source address (high byte)

saveBuf_bgGfxSrcBank: ds 1 ; $D80A: Background tiles source bank
saveBuf_bgGfxSrcLow:  ds 1 ; $D80B: Background tiles source address (low byte)
saveBuf_bgGfxSrcHigh: ds 1 ; $D80C: Background tiles source address (high byte)

; Implicitly bank 8
saveBuf_tiletableSrcLow:  ds 1 ; $D80D: Metatile definitions source address (low byte)
saveBuf_tiletableSrcHigh: ds 1 ; $D80E: Metatile definitions source address (high byte)

; Implicitly bank 8
saveBuf_collisionSrcLow:  ds 1 ; $D80F: Tile properties source address (low byte)
saveBuf_collisionSrcHigh: ds 1 ; $D810: Tile properties source address (high byte)

saveBuf_currentLevelBank: ds 1 ; $D811: Bank for current room

saveBuf_samusSolidityIndex: ds 1 ; $D812: Samus solid block threshold
saveBuf_enemySolidityIndex: ds 1 ; $D813: Enemy solid block threshold
saveBuf_beamSolidityIndex:  ds 1 ; $D814: Projectile solid block threshold

saveBuf_samusItems: ds 1 ; $D815: Samus' equipment
saveBuf_samusBeam:  ds 1 ; $D816: Samus' beam

saveBuf_samusEnergyTanks: ds 1 ; $D817: Samus' max health in energy tanks
saveBuf_samusHealthLow:   ds 1 ; $D818: Samus' current health (low byte)
saveBuf_samusHealthHigh:  ds 1 ; $D819: Samus' current health (energy tanks)

saveBuf_samusMaxMissilesLow:  ds 1 ; $D81A: Samus' max missiles (low byte)
saveBuf_samusMaxMissilesHigh: ds 1 ; $D81B: Samus' max missiles (high byte)
saveBuf_samusCurMissilesLow:  ds 1 ; $D81C: Samus' missiles (low byte)
saveBuf_samusCurMissilesHigh: ds 1 ; $D81D: Samus' missiles (high byte)

saveBuf_samusFacingDirection: ds 1 ; $D81E: Direction Samus is facing

saveBuf_acidDamageValue:  ds 1 ; $D81F: Acid damage
saveBuf_spikeDamageValue: ds 1 ; $D820: Spike damage

saveBuf_metroidCountReal: ds 1 ; $D821: Real number of Metroids remaining

saveBuf_currentRoomSong: ds 1 ; $D822: Song for room

; Frames and seconds are not saved
saveBuf_gameTimeMinutes: ds 1 ; $D823: In-game timer, minutes
saveBuf_gameTimeHours:   ds 1 ; $D824: In-game timer, hours

saveBuf_metroidCountDisplayed: ds 1 ; $D825: Number of Metroids remaining
;}

;$D900..FF: Respawning block data. 10h byte slots
;{
;    + 0: Frame counter
;    + 1: Y position
;    + 2: X position
;}

section "Tiletable Array", wramx[$da00]
tiletableArray:: ds $200 ;$DA00..DBFF: Metatile definitions
collisionArray:: ds $100 ;$DC00..FF: Tile properties. Indexed by tilemap value. Note that tilemap value < 4 is a respawning shot block
;{
;    1: Water (also causes morph ball sound effect glitch)
;    2: Half-solid floor (can jump through)
;    4: Half-solid ceiling (can fall through)
;    8: Spike
;    10h: Acid
;    20h: Shot block
;    40h: Bomb block
;    80h: Save pillar
;}
;$DD00..2F: Projectile data. 10h byte slots
;{
;    $DD00..1F: Beam slots
;    $DD20: Missile or beam slot
;    + 0: Type
;        0: Normal
;        1: Ice
;        2: Wave
;        3: Spazer
;        4: Plasma
;        7: Bomb beam? (see $2:52C6)
;        8: Missile
;        FFh: None
;    + 1: Direction
;        1: Right
;        2: Left
;        4: Up
;        8: Down
;    + 2: Y position
;    + 3: X position
;    + 4: Wave index
;    + 5: Frame counter
;}
;$DD30..5F: Bomb data. 10h byte slots
;{
;    + 0: Type
;        1: Bomb
;        2: Bomb explosion
;        FFh: None
;    + 1: Bomb timer
;    + 2: Y position
;    + 3: X position
;}
;$DD60..FF: Unused
;$DE00..FF: Metatile update entries
;{
;    + 0: VRAM background tilemap destination address. $0000 terminates update
;    + 2: Top-left tile
;    + 3: Top-right tile
;    + 4: Bottom-left tile
;    + 5: Bottom-right tile
;}
;$DF00..FF: Stack
;}