; Door macros

MACRO COPY_DATA
	db $00
	db BANK(\1), LOW(\1), HIGH(\1)
	dw \2
	dw \3
ENDM

MACRO COPY_BG
	db $01
	db BANK(\1), LOW(\1), HIGH(\1)
	dw \2
	dw \3
ENDM

MACRO COPY_SPR
	db $02
	db BANK(\1), LOW(\1), HIGH(\1)
	dw \2
	dw \3
ENDM

MACRO TILETABLE
	db $10 | (LOW(\1) & $0F)
ENDM

MACRO COLLISION
	db $20 | (LOW(\1) & $0F)
ENDM

MACRO SOLIDITY
	db $30 | (LOW(\1) & $0F)
ENDM

MACRO WARP
	db $40 | (LOW(\1) & $0F)
	db LOW(\2)
ENDM

MACRO ESCAPE_QUEEN
	db $50
ENDM

MACRO DAMAGE
	db $60, (\1), (\2)
ENDM

MACRO EXIT_QUEEN
	db $70
ENDM

MACRO ENTER_QUEEN
	db $80 | ((\1) & $0F)
	dw (\2),(\3)
	dw (\4),(\5)
ENDM

MACRO IF_MET_LESS
	db $90
	db (\1)
	dw (\2)
ENDM

MACRO FADEOUT
	db $A0
ENDM

MACRO LOAD_BG
	db $B1
	db BANK(\1), LOW(\1), HIGH(\1)
ENDM

MACRO LOAD_SPR
	db $B2
	db BANK(\1), LOW(\1), HIGH(\1)
ENDM

MACRO SONG
	db $C0 | ((\1) & $0F)
ENDM

MACRO ITEM
	db $D0 | ((\1) & $0F)
ENDM

MACRO END_DOOR
	db $FF
ENDM