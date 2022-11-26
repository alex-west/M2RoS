SECTION "ROM Bank $010", ROMX[$4000], BANK[$10]

;map table for loading proper submap and samus' map position XY offset for relevant bank map library
bank_09_maps:
	INCLUDE "mapPatchTables/mapTables00.asm"
bank_0A_maps:
	INCLUDE "mapPatchTables/mapTables01.asm"
bank_0B_maps:
	INCLUDE "mapPatchTables/mapTables02.asm"
bank_0C_maps:
	INCLUDE "mapPatchTables/mapTables03.asm"
bank_0D_maps:
	INCLUDE "mapPatchTables/mapTables04.asm"
bank_0E_maps:
	INCLUDE "mapPatchTables/mapTables05.asm"
bank_0F_maps:
	INCLUDE "mapPatchTables/mapTables06.asm"

;the actual map tiles to load to Window VRAM
landing:
	INCLUDE "mapPatchTables/00Landing.asm"
fissure:
	INCLUDE "mapPatchTables/01Fissure.asm"
temple:
	INCLUDE "mapPatchTables/02Temple.asm"
lair1:
	INCLUDE "mapPatchTables/03Lair1.asm"
grotto:
	INCLUDE "mapPatchTables/04Grotto.asm"
lair2:
	INCLUDE "mapPatchTables/05Lair2.asm"
tomb:
	INCLUDE "mapPatchTables/06Tomb.asm"
lair3:
	INCLUDE "mapPatchTables/07Lair3.asm"
chasm:
	INCLUDE "mapPatchTables/08chasm.asm"
tower:
	INCLUDE "mapPatchTables/09Tower.asm"
abyss:
	INCLUDE "mapPatchTables/0aAbyss.asm"
omega:
	INCLUDE "mapPatchTables/0bOmega.asm"
hive:
	INCLUDE "mapPatchTables/0cHive.asm"
escape:
	INCLUDE "mapPatchTables/0dEscape.asm"

mapCollectionSubset:
	dw bank_09_maps, bank_0A_maps, bank_0B_maps, bank_0C_maps, bank_0D_maps, bank_0E_maps, bank_0F_maps

pauseMapTable:
	dw landing
	dw fissure
	dw temple
	dw lair1
	dw grotto
	dw lair2
	dw tomb 
	dw lair3
	dw chasm
	dw tower
	dw abyss
	dw omega
	dw hive
	dw escape

farLoadMapTiles:
		; Get screen index from coordinates
		ldh a, [hSamusYScreen]
		rl a
		rl a
		rl a
		rl a
		and $f0
		ld [samusMapY], a
		ldh a, [hSamusXScreen]
		and $0f
		ld [samusMapX], a
			;adjust index val based on direction uuuuuu
			; Right
			ld a, [doorScrollDirection]
			cp a, $01
			jr nz, .left
				ld a, [samusMapX]
				inc a
				and a, $0f
				ld [samusMapX], a
				jr .none
			.left:
			ld a, [doorScrollDirection]
			cp a, $02
			jr nz, .up
				ld a, [samusMapX]
				dec a
				and a, $0f
				ld [samusMapX], a
				jr .none
			.up:
			ld a, [doorScrollDirection]
			cp a, $04
			jr nz, .down
				ld a, [samusMapY]
				sub a, $10
				and a, $f0
				ld [samusMapY], a
				jr .none						
			.down:
			ld a, [doorScrollDirection]
			cp a, $08
			jr nz, .none
				ld a, [samusMapY]
				add a, $10
				and a, $f0
				ld [samusMapY], a
			.none:
				ld a, [samusMapY]
				ld b, a
				ld a, [samusMapX]
				add a, b
				ld [mapCollectionIndex], a
;					;debug hud view
;					ld a, [mapCollectionIndex]
;					ld [samusDispMissilesLow], a
;					ld [samusCurMissilesLow], a
	;set up map index based on currentLevelBank
	ld a, [currentLevelBank]
	sub $09
;		;debug hud view
;		ld [samusCurMissilesHigh], a
;		ld [samusDispMissilesHigh], a
	add a, a
	ld e, a
		;debug
		ld [mapLevelBankIndexOffset], a
	ld d, $00
	ld hl, mapCollectionSubset
	add hl, de
		;now we have pointer to the proper map collection table to review (indexed by currentLevelBank)
		;load the value at that submap table index to hl to find the proper submap
		ld e, [hl]
		inc hl
		ld d, [hl]
		ld h, d
		ld l, e
		;correct mapCollectionSubset index by bank pointer should be in HL now
		;so now, enter table based on hSamusYScreen/hSamusXScreen
		ld d, $00
		ld a, [mapCollectionIndex]
		ld e, a
		add hl, de
			ld a, l
			ld [mapCollectionTableXY], a
			ld a, h
			ld [mapCollectionTableXY+1], a
				;now we have pointer to the proper map (indexed by mapCollectionIndex)
				;load it and prepare to read data from the map to Window VRAM targets
				ld e, [hl]
				ld d, [hl]
				ld h, d
				ld l, e

	;now load value at HL addr and double it as pointer to submap to read from
	ld a, l
	ld a, l
	add a, a
	ld e, a
	ld d, $00
	ld hl, pauseMapTable
	add hl, de	
	;hl now points to map pointer
	;
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld h, d
	ld l, e
	;
    ld de, vramDest_map2
    ld b, $00
    :
        ld a, [hl+]
        ld [de], a
        inc de
        ld a, [hl+]
        ld [de], a
        inc de
        dec b
		ld a, b
		and $0f
		cp a, $06
		jr nz, :+
			ld a, b
			and $f0
			ld b, a
			inc de
			inc de
			inc de
			inc de
			inc de
			inc de
			inc de
			inc de
			inc de
			inc de
			inc de
			inc de
		:
	ld a, b
    jr nz, :--
	;trickery - writes icon list to Window Ram that cannot be displayed on screen
	;this saves me calculation where to load this data from,
	;so it can live right after the map's tiles
	;note - hl and de should already be set up from before
	ld d, $dd
	ld e, $70
	.loadMapIconData:
		ld a, [hl+]
        ld [de], a
		cp a, $ff
		jr z, .next
		inc de
		jr .loadMapIconData
	.next:
		inc de
	ld a, $00
	ld [loadNewMapFlag], a
				;;;;;;;;;;;; experimental - Samus Locator coords update
					ld a, [mapCollectionTableXY]
					ld l, a
					ld a, [mapCollectionTableXY+1]
					add a, $01
					ld h, a
					;now we have pointer to the proper map collection table to review (indexed by currentLevelBank)
					;load the value at that submap table index to hl to find the proper submap
					ld e, [hl]
					inc hl
					ld d, [hl]
					ld a, e
					ld [mapSamusLocatorYOffset], a
				;;;;;;;;;;;; experimental - Samus Locator coords update
					ld a, [mapCollectionTableXY]
					ld l, a
					ld a, [mapCollectionTableXY+1]
					add a, $02
					ld h, a
					;now we have pointer to the proper map collection table to review (indexed by currentLevelBank)
					;load the value at that submap table index to hl to find the proper submap
					ld e, [hl]
					inc hl
					ld d, [hl]
					ld a, e
					ld [mapSamusLocatorXOffset], a
	
	ret

pauseAdjustSpriteSetup:
VBlank_updateStatusBarPaused:
		;draw samus locator sprite
			;top n bottom
			ld a, [hCameraYScreen]
			ld b, a
			ld a, [mapSamusLocatorYOffset]
			add a, b
			rl a
			rl a
			rl a
			ld [$c000], a
			; L n R
			ld a, [hCameraXScreen]
			ld b, a
			ld a, [mapSamusLocatorXOffset]
			add a, b
			rl a
			rl a
			rl a
			ld [$c001], a
			;locator sprite tile art and palette
			ld a, $01
			ld [$c002], a
			ld a, $00
			ld [$c003], a
		;draw time hour hi tile
			ld a, [gameTimeHours]
			and $f0
			sra a
			sra a
			sra a
			sra a
			add $a0
			ld [$9c00], a
		;draw time hour lo tile
			ld a, [gameTimeHours]
			and $0f
			add $a0
			ld [$9c01], a
		;draw time colon tile
			ld a, $9e
			ld [$9c02], a
		;draw time minute hi tile
			ld a, [gameTimeMinutes]
			and $f0
			sra a
			sra a
			sra a
			sra a
			add $a0
			ld [$9c03], a
		;draw time minute hi tile
			ld a, [gameTimeMinutes]
			and $0f
			add $a0
			ld [$9c04], a
		;draw white tile between time and equip
			ld a, $af
			ld [$9c05], a
			ld [$9c06], a
		;draw white tile between time and equip behind sprite
			ld a, $af
			ld [$9c07], a
		;draw equip Samus helm sprite
			ld a, $10
			ld [$c004], a
			ld a, $40
			ld [$c005], a
			ld a, $01
			ld [$c006], a
			ld a, $00
			ld [$c007], a			
		;draw colon tile
			ld a, $9e
			ld [$9c08], a
		;draw numbers for count of remaining items to find
			ld a, [mapItemsFound]
			and a, $F0
			sra a
			sra a
			sra a
			sra a
			add a, $a0
			ld [$9c09], a
			ld a, [mapItemsFound]
			and a, $0F
			add a, $a0
			ld [$9c0a], a
		;draw tile for diagonal line separator
			ld a, $ae
			ld [$9c0b], a
		;draw tile for max items to find tens and ones
			ld a, [mapItemsTotal]
			and a, $f0
			sra a
			sra a
			sra a
			sra a
			add a, $a0
			ld [$9c0c], a					
			ld a, [mapItemsTotal]
			and a, $0f
			add a, $a0
			ld [$9c0d], a					
		;draw white tile between equip and 'roids remaining
			ld a, $af
			ld [$9c0e], a	
			ld [$9c0f], a
		;draw blank tile behind Metroid Left sprite
			ld a, $ff
			ld [$9c10], a
		;draw metroid left L sprite
			ld a, $10
			ld [$c008], a
			ld a, $88
			ld [$c009], a
			ld a, $0f
			ld [$c00a], a
			ld a, $00
			ld [$c00b], a
		;copied from bank 1 - HUD update when paused for metroid count
				ld a, [metroidLCounterDisp]
				cp $ff
				jr z, .else_E
					; Draw normal L counter (tens digit)
					and $f0
					swap a
					add $a0
					ld [$9c12], a
					; Ones digit
					ld a, [metroidLCounterDisp]
					and $0f
					add $a0
					ld [$9c13], a
					jr .next
				.else_E:
					; Draw blank L counter "--"
					ld a, $a0 ; zero
					ld [$9c12], a
					ld [$9c13], a
			.next:
		;mask message area of pause window black
			ld a, $ff
			ld [$9c20], a
			ld [$9c21], a
			ld [$9c22], a
			ld [$9c23], a
			ld [$9c24], a
			ld [$9c25], a
			ld [$9c26], a
			ld [$9c27], a
			ld [$9c28], a
			ld [$9c29], a
			ld [$9c2a], a
			ld [$9c2b], a
			ld [$9c2c], a
			ld [$9c2d], a
			ld [$9c2e], a
			ld [$9c2f], a
			ld [$9c30], a
		;draw map icons from window ram to OAM	
			;init hl to window RAM to read,
			;init de to OAM address to write,
			;start loop: read from hl+.
			;if FF stop
				;else
					;write to B (hi byte of SRAM offset to read)
					;read from hl+ write to C
					;read byte at bc. If not FF do four inc HL
						;read hl+ and write de+ four times			
			;load the read address of window RAM
			ld h, $dd
			ld l, $70
			;load the write address of sprite OAM to begin at
			ld d, $c0
			ld e, $0c
			.loopSetupMapSprites:
				;Validate that sprite should be drawn; if not skip, if so draw
					ld a, [hl+]
					ld b, a
					ld a, [hl+]
					ld c, a
					;check for endLoop value of $ff
						ld a, b
						cp a, ENDLIST
						jr z, .setupMapSpritesExit
					;check for autovalidate value of $c0
						cp a, AUTOVAL
						jr z, .itemValidated
					;if validate required, check if item has been collected (=$02)
					;if not collected, is validated so draw
						ld a, [bc]
						cp a, COLLECTED
						jr z, .isCollected
						jr .itemValidated
						;if item SRAM isn't set to COLLECTED, check working RAM
;							ld b, $c5
;							ld a, c
;							and a, $3F
;							add a, $40
;							ld c, a
;							ld a, [bc]
;							cp a, COLLECTED
;							jr nz, .itemValidated
						;if collected, remove this sprite and loop
						.isCollected:
							inc hl
							inc hl
							inc hl
							inc hl
							ld a, $ff
							ld [de], a
							inc de
							ld [de], a
							inc de
							ld [de], a
							inc de
							ld [de], a
							inc de
							jr .loopSetupMapSprites
				;at this point we are loading sprites	
				.itemValidated:
					ld a, [hl+]
					ld [de], a
					inc de
					ld a, [hl+]
					ld [de], a
					inc de
					ld a, [hl+]
					ld [de], a
					inc de
					ld a, [hl+]
					ld [de], a
					inc de
				jr .loopSetupMapSprites
			.setupMapSpritesExit:
				
	;set window
	ld a, $00
	ldh [rWY], a
ret

;sprite setup
;$C000..9F: OAM
;    + 0: Y position
;    + 1: X position
;    + 2: Tile number
;    + 3: Attributes
;         10: Palette
;         20: X flip
;         40: Y flip
;         80: Priority (set: behind background)


;loading items:
;c900-cabf is $40 bytes per bank (in debugger 4 lines), 7 banks requires through CABF
;offset is 40 * (bank-9) + c900
;if we know each value of each item, we can have an ID value associated with it that gets loaded
;id is the index to add to our entry point of c900, c940, c980, c9c0, ca00, ca40, ca80
;if that indexed value does not equal FF, do not draw the dot


;below - here, we handle the items-found counter,
;then we load the text for the appropriate item if it's not a refill
calcFoundEquipment:
		ld a, b
		cp $0e
		jr nc, .isRefill
		cp a, $05
		jr nc, .gotItem
			ld a, [samusBeam]
			cp $00
			jr nz, .notFirstBeam
			jr .doNotClearItem
		.gotItem:
			;get sram bank offset from enemy wram
				ld a, [clearItemDotLow]
				add $1d
				ld e, a
				ld a, [clearItemDotHigh]
				ld d, a
				ld a, [de]
				sub a, $40
				ld [clearItemIndex], a
			;set up bank as high byte of de
				ld a, [currentLevelBank]
				sub a, $09
				sra a
				sra a
				add a, $c9
				ld d, a
				ld [clearItemBank], a
			;loop to set up low byte of de with offset for enemy index
				ld a, [currentLevelBank]
				sub a, $09
				inc a
				and $03
				ld e, a
				;get a for loop once more
				ld a, [clearItemIndex]
				.loopCurrentCheck
					dec e
					jr z, .stopChecking
					add a, $40
					jr .loopCurrentCheck
				.stopChecking:
			;have the byte of SRAM buffer to update as 'item collected'
				ld [clearItemIndex], a
				ld e, a
				ld a, $02
				ld [de], a
		.doNotClearItem:
			ld a, [mapItemsFound]
			and $0f
			cp $09
			jr nz, .notTensOverNine
				ld a, [mapItemsFound]
				add a, $10
				and $f0
				jr .resume
			.notTensOverNine:
				ld a, [mapItemsFound]
				inc a
		.resume:
			ld [mapItemsFound], a
		.notFirstBeam:
			;fix item text for item msg and beams and equipment
			;mostly cause it don't fit nicely in that bank
			ld e, b
			dec e
			rl e
			ld d, $00
		.isRefill:
	ret
