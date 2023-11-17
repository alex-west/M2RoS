# Enemy Headers and Enemies in RAM

## RAM
Enemies are in RAM in two places. Canonically, they are stored in an array at $C600. When it's an enemy's turn to be processed, it's information is copied to a working location in HRAM, and then copied back when finished.

Note that there are 10 bytes in each enemy's WRAM slot that are unused due to space constraints in HRAM.

## Headers
There are three types of enemy headers that are copied to WRAM when an enemy is spawned.

- Normal headers are what are used in loading in a enemy from the map, and are located in Bank 3. The Y position, X position, and sprite number are supplied by the enemy map data itself.

- Long headers are used by some enemies when spawning projectiles. The parent enemy needs to supply an X and Y position, but the sprite number is in the header itself. These headers intermingled with the enemy code in Bank 2.

- Short headers are also used by enemies to spawn projectiles. In this case, however, the sprite number and sprite attributes must also be provided by the parent enemy.

## Tabular Representation
| WRAM | HRAM | Normal | Long | Short | Purpose                   |
|------|------|--------|------|-------|---------------------------|
| C600 | E0   |    x   |   x  |   x   | Status                    |
| C601 | E1   |    x   |   x  |   x   | Y Position (camera-space) |
| C602 | E2   |    x   |   x  |   x   | X Position (camera-space) |
| C603 | E3   |    x   | 0    |   x   | Sprite Number             |
| C604 | E4   | 0      | 1    |   x   | Base Sprite Attributes    |
| C605 | E5   | 1      | 2    |   x   | Sprite Attributes         |
| C606 | E6   | 2      | 3    | 0     | Stun Counter              |
| C607 | E7   | 3      | 4    | 1     | General?                  |
| C608 | E8   | 4      | 5    | 2     | Directional Flags         |
| C609 | E9   | 5      | 6    | 3     | General?                  |
| C60A | EA   | 6      | 7    | 4     | General?                  |
| C60B | EB   | 7      | 8    | 5     | Ice Counter               |
| C60C | EC   | 8      | 9    | 6     | Health                    |
| C60D | ED   |    x   |   x  |   x   | Drop Type                 |
| C60E | EE   |    x   |   x  |   x   | Explosion Flag            |
| C60F | F3   |    x   |   x  |   x   | Y Position (screens away) |
| C610 | F4   |    x   |   x  |   x   | X Position (screens away) |
| C611 | F5   | 8      | 9    | 6     | Initial Health            |
| C612 |   x  |    x   |   x  |   x   | -                         |
| C613 |   x  |    x   |   x  |   x   | -                         |
| C614 |   x  |    x   |   x  |   x   | -                         |
| C615 |   x  |    x   |   x  |   x   | -                         |
| C616 |   x  |    x   |   x  |   x   | -                         |
| C617 |   x  |    x   |   x  |   x   | -                         |
| C618 |   x  |    x   |   x  |   x   | -                         |
| C619 |   x  |    x   |   x  |   x   | -                         |
| C61A |   x  |    x   |   x  |   x   | -                         |
| C61B |   x  |    x   |   x  |   x   | -                         |
| C61C | EF   |    x   |   x  |   x   | Spawn Flag                |
| C61D | F0   |    x   | 10   | 7     | Spawn Number              |
| C61E | F1   | 9      | 11   | 8     | AI Pointer Low            |
| C61F | F2   | 10     | 12   | 9     | AI Pointer High           |
|   x  | FC   | -      | -    | -     | WRAM Addr Low             |
|   x  | FD   | -      | -    | -     | WRAM Addr High            |

### Explanations
#### Status
Values:
- $00: Enemy is active
- $01: Enemy is offscreen
- $8x: Enemy is invisible
- $FF: Enemy slot is unused

Invalid values appear to crash the game back to the title screen.

#### Positions
The X and Y positions are in pixels relative to the camera. There are no sub-pixels. The game automatically updates the positions as the camera moves.

Enemies also have memory addresses that keep track of which screen they are on, relative to the camera. If either value is non-zero, then the enemy is considered offscreen and it's AI routine is not executed for the given frame. If the enemy is more than a couple screens away in any direction, it is automatically unloaded.

#### Sprite Number
The sprite number determines which metasprite is used to render the enemy (based on the enemy sprite pointer table), as well as which hitbox and damage value to use. Note that while the enemy type in the map data determines the initial sprite an enemy uses, enemies are free to change their displayed sprite to anything at runtime.

#### Sprite Attributes
The base sprite attributes determine the attribute flags for an enemy. They are never modified during runtime, though this mostly appears to be a matter of convention. Directly after that is a mutable version of the sprite attributes. These two values are XOR'd together at render-time to determine the visual attributes of the sprites. (The stun counter also factors into this calculation.)

#### Stun Counter
Used to have make the enemy stunned for a few frames when shot.

Values:
- $00: Default (no effect)
- $10: Palette changed, but value does not increment (used for visual component of ice beam)
- $11-$13: Stunned (increments each frame until $13, then it returns to $00)

#### Directional Flags
The upper nybble encodes directional vulnerabilities of the enemy:
- %0001xxxx - resists rightward shots
- %0010xxxx - left
- %0100xxxx - up
- %1000xxxx - down

The lower nybble is sometimes used to indicate which direction the enemy is logically going (being distinct from its visual direction).

#### General Variables
HRAM addresses $FFE7, $FFE9, and $FFEA are general purpose variables used in enemy AI routines. They tend to be counters or states of some sort.

Note: $FFE9 and $FFEA might have currently undocumented purposes in the enemy header.

#### Ice Counter
Used by the ice beam to determine how frozen an enemy is. A value of 0 indicates the enemy is unfrozen.

Odd values result in frozen enemies vulnerable to screw attack (normal behavior), while (non-zero) even values result in enemies invulnerable to screw attack (possibly unused).

#### Health

The enemy's health. The values $FD, $FE, and $FF are special cases.

The initial health of an enemy is kept because it determines what the enemy drops. It is referenced when setting the explosion flag, which in turn is referenced when setting the drop type itself.

Rules:
- If $FD or $FE - No drops, ever.
- If value is even, drop missile
- If value is >$0A, drop large health
- Else, drop small health
- Note: All drops have a 50% chance of happening or being nothing

#### Drop Type
Values:
- 0: None
- 1: Small health
- 2: Large health
- 4 (or otherwise): missile drop

#### Explosion Flag
Contains the current explosion status and the future-drop status (based on the initial health of the enemy).

Values:
- Non-zero - Explosion happening
- $1x - Explosion type A (normal death)
- $2x - Explosion type B (screw attack death)
- $x0 - No drop
- $x1 - Small health
- $x2 - Large health
- $x4 - Missile drop

Note: $FFE9 is used as an explosion timer when exploding.

#### Spawn Flag and Number
An enemy's spawn number and flag are used to keep track of whether or not a specific enemy on the current map have been killed. Enemies with spawn numbers in the range of 0x40-0x7F have their spawn flags saved when killed (e.g. metroids, items, etc.).

The are multiple possible values for spawn flags besides "dead" and "alive."
- $01 - Alive
- $02 - Permanently Dead (if spawn number is in savable range)
- $03 - Inactive and waiting for child object (i.e. a projectile) to die
- $04 - Has been seen before (used to skip Metroid intro animations)
- $05 - Has been seen before and has a child object
- $06 - Enemy projectile
- $x0 - Enemy projectile that links back to its parent object

#### AI Pointer
Points to an AI routine in bank 2.

#### WRAM Addr
A value in HRAM that points to the canonical WRAM location of the enemy being currently worked on.
