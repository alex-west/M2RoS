# ROM Tour
### A High-Level Look of the Game's Structure

## Bank 0
Progress: 30%

Relocatable: Yes

- Main game engine
- Samus control routines
- Common collision routines
- Door transition script interpreter
- Stubs used for jumping between banks

## Bank 1
Progress: 40%

Relocatable: Yes

- Samus metasprite data
- Samus drawing routines
- Save/load routines
- Initial savegame data
- Bomb/beam routines
- Destructible block routines
- Enemy metasprite data
- Alpha/Gamma Metroid movement routines
- Title/credits metasprite data
- Earthquake animation routine

## Bank 2
Progress: 60%

Relocatable: Yes

- Main enemy handler
- Enemy specific collision routines
- Enemy AI code

## Bank 3
Progress: 15%

Relocatable: Yes

- Enemy loading routines
- Enemy position data 
- Enemy headers
- Enemy damage table
- Enemy hitboxes
- Metroid seeking routine
- Enemy Scrolling Routine
- Queen AI
- LCD Interrupt Handler

## Bank 4
Progress: 1%

Relocatable: No

- Everything related to sound.

## Bank 5
Progress: 90%

Relocatable: Yes

- Title screen code
- Credits code
- Door transition scripts
- Title screen and ending graphics

TODO: Giving proper names to labels and some variables.

## Bank 6
Progress: 95%

Relocatable: Yes

- Graphics for the arm cannon and beams.
- Various suit graphics that get swapped in when upgrades are collected.
- Samus' power suit graphics, along with common HUD and sprite elements.
- Samus' Varia Suit graphics
- Sprite graphics for the all non-Metroid enemies, and the landing site.
- The text of the credits
- Spider ball orientation table

TODO: Converting graphics to an editable format.

## Bank 7
Progress: 95%

Relocatable: Yes

- Tile graphics for the majority of the game's areas.
- Graphics for each major item, and the item orb.
- Some common sprite graphics.

TODO: Converting graphics to an editable format.

## Bank 8
Progress: 95%

Relocatable: Yes

- Base tilemap for the Queen's head.
- Collision tables for each tileset.
- Metatile definitions for each tileset.
- Enemy graphics for the different metroid types
- A couple of spare area tilesets.
- A subroutine that checks if an earthquake should happen.
- A table of solidity thresholds for each tileset.

TODO: Converting graphics to an editable format.

## Level Data Banks
Progress: 100%

Relocatable: N/A

The last 7 banks of the game contain the game's map data. Each bank is a 16x16 screen map capable of having 59 unique screens. Rooms are arranged in these maps like tetrominos, and glued together via the door transition scripts in bank 5.

The enemy placement data is contained separately in bank 

### Bank 9
- The main caverns for the game's four main ruins.

### Bank A
- The large, free-scrolling caves with acid.
- The first underground room in the game.
- The horizontal corridors from the last cave (with the pit traps)
- A couple Metroid fight rooms.
- A screen that accidentally point to the beginning of the ROM somehow.

### Bank B
- Horizontally scrolling rooms from just about every area of the game, except for the Omega Metroids' area and the ruins' interiors
- One Omega Metroid fight room
- The second save room from the Omegas Metroid area.

### Bank C
- Vertically oriented rooms from just about every area in the game.

### Bank D
- Interiors of Ruins 1 and 2.
- Vertical rooms from the Queen's area (labs).

### Bank E
- Interiors of Ruins 3 and 4
- Horizontal rooms from the Queen's area (labs).
- Two metroid fight rooms
- The broken statue room
- The last refill room (happens to be a filler screen)

### Bank F
- The landing site from the beginning of the game (with a huge unused portion)
- The landing site from the end of the game, w/the exit from the last area
- Horizontal corridors from the introductory area
- Horizontal corridors from the Omegas' area
- The large cavern from the last area (with the sludge pit)
- The Queen's rooms (before/during/after)
