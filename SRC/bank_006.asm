; Disassembly of "Metroid2.gb"
; This file was created with:
; mgbdis v1.4 - Game Boy ROM disassembler by Matt Currie and contributors.
; https://github.com/mattcurrie/mgbdis

SECTION "ROM Bank $006", ROMX[$4000], BANK[$6]

gfx_cannonBeam::
    db $00, $00, $00, $00, $3c, $3c, $24, $3c, $7e, $52, $7e, $7e, $4a, $7e, $4a, $7e
    db $00, $00, $f0, $f0, $1c, $ec, $1c, $f4, $ec, $f4, $1c, $ec, $f0, $f0, $00, $00
gfx_cannonMissile::
    db $00, $00, $00, $00, $00, $00, $00, $00, $db, $42, $fb, $66, $7a, $2c, $4a, $7e
    db $30, $00, $f0, $b0, $60, $e0, $70, $80, $f0, $c0, $00, $e0, $f0, $b0, $30, $00

gfx_beamIce::
    db $10, $00, $5a, $00, $24, $18, $5f, $24, $de, $24, $3c, $18, $5a, $00, $08, $00
    db $10, $00, $5a, $00, $3c, $18, $7b, $24, $fa, $24, $24, $18, $5a, $00, $08, $00
gfx_beamWave::
    db $3c, $00, $7e, $00, $e7, $00, $c3, $00, $c3, $00, $e7, $00, $7e, $00, $3c, $00
    db $3c, $00, $66, $18, $c3, $24, $81, $42, $81, $42, $c3, $24, $66, $18, $3c, $00
gfx_beamSpazer::
gfx_beamPlasma::
    db $00, $00, $00, $00, $00, $ff, $ff, $00, $ff, $00, $00, $ff, $00, $00, $00, $00
    db $18, $24, $18, $24, $18, $24, $18, $24, $18, $24, $18, $24, $18, $24, $18, $24

gfx_spinSpaceTop::
    db $00, $00, $03, $03, $07, $04, $0f, $09, $7f, $78, $ef, $9c, $ef, $be, $df, $fb
    db $3f, $3f, $4f, $78, $ff, $b0, $ff, $5e, $ff, $ff, $c1, $7f, $8c, $f3, $9e, $e1
    db $00, $00, $80, $80, $c0, $40, $f8, $38, $e4, $3c, $ec, $b4, $e6, $ba, $e2, $be
    db $00, $00, $03, $03, $0e, $0d, $14, $1b, $10, $1f, $1f, $1f, $3f, $20, $7f, $47
    db $00, $00, $e0, $e0, $10, $f0, $08, $f8, $14, $fc, $34, $ec, $fc, $c4, $f4, $ec
    db $7f, $43, $3f, $26, $1f, $1f, $09, $0f, $0e, $0b, $0f, $09, $07, $07, $00, $00
    db $f2, $3e, $dc, $7c, $e0, $e0, $dc, $bc, $d4, $6c, $b8, $78, $c0, $c0, $00, $00
gfx_spinSpaceBottom::
    db $ff, $98, $be, $ed, $4b, $7f, $77, $57, $55, $77, $34, $37, $02, $03, $01, $01
    db $9e, $e1, $8c, $f3, $c1, $ff, $fe, $7f, $fd, $65, $f8, $a8, $30, $f0, $c0, $c0
    db $c2, $fe, $c2, $fe, $e2, $be, $f4, $1c, $48, $b8, $f0, $f0, $00, $00, $00, $00
    db $fc, $8f, $f9, $9e, $fb, $9c, $fb, $dc, $b9, $fe, $b8, $ef, $7c, $5f, $3f, $2b
    db $28, $f8, $90, $70, $d8, $38, $dc, $34, $9e, $72, $1e, $fe, $3d, $fb, $fd, $e7

gfx_spinScrewTop::
    db $00, $00, $03, $03, $07, $00, $1F, $01, $3F, $20, $3F, $04, $3F, $0E, $7F, $0B
    db $3F, $3F, $4F, $78, $FF, $B0, $FF, $5E, $FF, $D3, $BF, $61, $FF, $39, $FF, $69
    db $00, $00, $A0, $80, $D0, $40, $F8, $20, $EC, $34, $EC, $B0, $EE, $B2, $E6, $BA
    db $00, $00, $03, $03, $0F, $08, $1E, $01, $30, $0F, $5F, $1F, $3F, $20, $7F, $47
    db $00, $00, $E0, $E0, $F0, $10, $78, $88, $34, $DC, $34, $EC, $FC, $C4, $F4, $6C
    db $7F, $43, $3F, $06, $1F, $03, $1F, $00, $0F, $08, $01, $00, $00, $00, $00, $00
    db $F2, $30, $D4, $70, $E1, $E0, $DE, $B0, $DC, $64, $F8, $18, $00, $00, $00, $00
gfx_spinScrewBottom::
    db $7F, $18, $7E, $2D, $4B, $3F, $77, $57, $71, $41, $34, $21, $12, $00, $08, $00
    db $EF, $D5, $DF, $A7, $DF, $AB, $DE, $37, $FD, $65, $F8, $A8, $30, $F0, $40, $40
    db $C6, $7A, $CE, $F2, $FE, $A2, $FC, $14, $48, $B8, $F0, $F0, $00, $00, $00, $00
    db $FF, $8F, $FF, $98, $FF, $90, $FF, $D3, $BF, $FA, $BF, $E7, $7B, $5D, $3F, $28
    db $E8, $F8, $F0, $70, $F8, $D8, $FC, $24, $7E, $92, $8E, $7E, $FD, $8B, $FC, $E6

gfx_spinSpaceScrewTop::
    db $00, $00, $03, $03, $06, $05, $0f, $00, $0f, $00, $1f, $04, $1b, $07, $3f, $08
    db $3f, $3f, $77, $48, $ef, $90, $ff, $5e, $7f, $ff, $c1, $7f, $8c, $f3, $9e, $e1
    db $00, $00, $a0, $80, $d0, $40, $f8, $20, $e8, $30, $ec, $b0, $e6, $ba, $e6, $ba
    db $00, $00, $03, $03, $07, $00, $1c, $03, $30, $0f, $5f, $1f, $3f, $20, $7f, $47
    db $00, $00, $e0, $e0, $f0, $10, $78, $88, $14, $fc, $34, $ec, $fc, $c4, $f4, $ec
    db $6e, $51, $5f, $62, $7f, $42, $3d, $26, $1f, $01, $07, $00, $01, $00, $00, $00
    db $fc, $1c, $fa, $08, $f4, $10, $e1, $e0, $fe, $98, $fc, $04, $f8, $38, $00, $00
gfx_spinSpaceScrewBottom::
    db $3f, $0c, $3f, $04, $3f, $24, $3b, $2a, $39, $29, $1a, $10, $09, $00, $04, $00
    db $9e, $e1, $8c, $f3, $c1, $ff, $fe, $bf, $fd, $05, $f8, $88, $70, $70, $00, $00
    db $c6, $fa, $ce, $f2, $ee, $b2, $fc, $14, $48, $b8, $f0, $f0, $00, $00, $00, $00
    db $fc, $8f, $f9, $9e, $fb, $9c, $bb, $dc, $d9, $be, $f8, $8f, $7c, $5f, $37, $2b
    db $28, $f8, $90, $70, $d8, $38, $dc, $34, $9e, $72, $1e, $f2, $3e, $e2, $fc, $f4
	
gfx_springBallTop::	
    db $00, $07, $03, $1c, $0f, $30, $1c, $63, $33, $4c, $37, $c8, $6f, $90, $6f, $90
    db $00, $e0, $c0, $38, $f0, $0c, $f8, $c6, $fc, $32, $3c, $d3, $9e, $69, $de, $29
gfx_springBallBottom::	
    db $7f, $90, $7f, $90, $3f, $c8, $3f, $4c, $1f, $63, $0f, $30, $03, $1c, $00, $07
    db $f6, $01, $f6, $01, $ec, $03, $cc, $02, $38, $06, $f0, $0c, $c0, $38, $00, $e0

; 06:4320
; Power suit and common sprite graphics
gfx_samusPowerSuit::
	include "gfx/samus/gfx_samusPowerSuit.asm"

; 06:4E20
gfx_samusVariaSuit::
	include "gfx/samus/gfx_samusVariaSuit.asm"

; 06:5920
; Enemy graphics pages -- 64 tiles each
gfx_enemiesA::   include "gfx/enemies/gfx_enemiesA.asm"
gfx_enemiesB::   include "gfx/enemies/gfx_enemiesB.asm"
gfx_enemiesC::   include "gfx/enemies/gfx_enemiesC.asm"
gfx_enemiesD::   include "gfx/enemies/gfx_enemiesD.asm"
gfx_enemiesE::   include "gfx/enemies/gfx_enemiesE.asm"
gfx_enemiesF::   include "gfx/enemies/gfx_enemiesF.asm"
gfx_arachnus::   include "gfx/enemies/gfx_arachnus.asm"
gfx_surfaceSPR:: include "gfx/enemies/gfx_surfaceSPR.asm"

; 06:7920
creditsText: ; TODO: Find the code that points to this
    include "data/credits.asm"

spiderBallOrientationTable:: ; 06:7E03
; Given an input and a collision state, this produces a rotational direction for the spider ball
; - Note that this only considers cardinal directions. Perhaps, by adding 
;  data for diagonal directions, the controls of the spider ball could be improved
;
; Values
;  0: Don't move
;  1: Move counter-clockwise
;  2: Move clockwise
;       ______________________________________________ 0: No input
;      |   ___________________________________________ 1: Right
;      |  |   ________________________________________ 2: Left
;      |  |  |   _____________________________________ 3: X: R+L
;      |  |  |  |   __________________________________ 4: Up
;      |  |  |  |  |   _______________________________ 5: R+U
;      |  |  |  |  |  |   ____________________________ 6: L+U
;      |  |  |  |  |  |  |   _________________________ 7: X: R+L+U
;      |  |  |  |  |  |  |  |   ______________________ 8: Down
;      |  |  |  |  |  |  |  |  |   ___________________ 9: D+R
;      |  |  |  |  |  |  |  |  |  |   ________________ A: L+U
;      |  |  |  |  |  |  |  |  |  |  |   _____________ B: X: R+L+U
;      |  |  |  |  |  |  |  |  |  |  |  |   __________ C: X: U+D
;      |  |  |  |  |  |  |  |  |  |  |  |  |   _______ D: X: R+U+D
;      |  |  |  |  |  |  |  |  |  |  |  |  |  |   ____ E: X: L+U+D
;      |  |  |  |  |  |  |  |  |  |  |  |  |  |  |   _ F: X: R+L+U+D
;      |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ;    0: In air
    db 0, 2, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ;    1: Outside corner: Of left-facing wall and ceiling
    db 0, 1, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0 ;    2: Outside corner: Of left-facing wall and floor
    db 0, 0, 0, 0, 1, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0 ;    3: Flat surface:   Left-facing wall
    db 0, 0, 1, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ;    4: Outside corner: Of right-facing wall and ceiling
    db 0, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ;    5: Flat surface:   Ceiling
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ;    6: Unused:         Top-left and bottom-right corners of ball in contact
    db 0, 0, 1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0 ;    7: Inside corner:  Of left-facing wall and ceiling
    db 0, 0, 2, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0 ;    8: Outside corner: Of right-facing wall and floor
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ;    9: Unused:         Bottom-left and top-right corners of ball in contact
    db 0, 1, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ;    A: Flat surface:   Floor
    db 0, 0, 2, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ;    B: Inside corner:  Of left-facing wall and floor
    db 0, 0, 0, 0, 2, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0 ;    C: Flat surface:   Right-facing wall
    db 0, 2, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0 ;    D: Inside corner:  Of right-facing wall and ceiling
    db 0, 1, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ;    E: Inside corner:  Of right-facing wall and floor
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ;    F: Unused:         Embedded in solid

; 06:7F03 - Freespace