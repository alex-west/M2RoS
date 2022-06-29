spiderBallOrientationTable: ; 06:7E03 (0x1BE03)
; Given an input and a spider ball collision state, this table
;  produces a rotational direction for the spider ball.
;  - Values
;     0: Don't move
;     1: Move counter-clockwise
;     2: Move clockwise
; (Note: "clockwise" here assumes that the ball rolling inside a box)
;
;  The original table only filled in two entries per row, resulting 
; in some really awkward fiddliness if you happen to stop on a corner.
;
;  This new table fills in six entries per row, allowing for diagonal
; inputs and secondary directions where it would make sense.  I would
; have filled in all 8 valid inputs per row, but in every case I determined
; that the result would have been unintuitive.

;                     U  U        D  D                <- Inputs  States -\
;      x  R  L  x  U  R  L  x  D  R  L  x  x  x  x  x                    |
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ;    0: In air     v
    db 0, 2, 1, 0, 1, 0, 1, 0, 2, 2, 0, 0, 0, 0, 0, 0 ;    1: Outside corner: Of left-facing wall and ceiling
    db 0, 1, 2, 0, 1, 1, 0, 0, 2, 0, 2, 0, 0, 0, 0, 0 ;    2: Outside corner: Of left-facing wall and floor
    db 0, 0, 0, 0, 1, 1, 1, 0, 2, 2, 2, 0, 0, 0, 0, 0 ;    3: Flat surface:   Left-facing wall
    db 0, 2, 1, 0, 2, 2, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0 ;    4: Outside corner: Of right-facing wall and ceiling
    db 0, 2, 1, 0, 0, 2, 1, 0, 0, 2, 1, 0, 0, 0, 0, 0 ;    5: Flat surface:   Ceiling
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ;    6: Unused:         Top-left and bottom-right corners of ball in contact
    db 0, 2, 1, 0, 1, 0, 1, 0, 2, 2, 0, 0, 0, 0, 0, 0 ;    7: Inside corner:  Of left-facing wall and ceiling
    db 0, 1, 2, 0, 2, 0, 2, 0, 1, 1, 0, 0, 0, 0, 0, 0 ;    8: Outside corner: Of right-facing wall and floor
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ;    9: Unused:         Bottom-left and top-right corners of ball in contact
    db 0, 1, 2, 0, 0, 1, 2, 0, 0, 1, 2, 0, 0, 0, 0, 0 ;    A: Flat surface:   Floor
    db 0, 1, 2, 0, 1, 1, 0, 0, 2, 0, 2, 0, 0, 0, 0, 0 ;    B: Inside corner:  Of left-facing wall and floor
    db 0, 0, 0, 0, 2, 2, 2, 0, 1, 1, 1, 0, 0, 0, 0, 0 ;    C: Flat surface:   Right-facing wall
    db 0, 2, 1, 0, 2, 2, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0 ;    D: Inside corner:  Of right-facing wall and ceiling
    db 0, 1, 2, 0, 2, 0, 2, 0, 1, 1, 0, 0, 0, 0, 0, 0 ;    E: Inside corner:  Of right-facing wall and floor
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ;    F: Unused:         Embedded in solid

; Notes about the collision state:
;
;  When using the spider ball, the game checks the collision state
;   of 8 points along its perimeter. For each point that is in contact
;   with a solid surface, the following bitmasks are applied (OR'd)
;   to the spider ball's collision state:
;
; Point Bitmasks
;   0    %0001
;   1    %0010                    2 _6_ 0
;   2    %0100                     /   \
;   3    %1000                    5|   |4
;   4    %0011                     \___/
;   5    %1100                    3  7  1
;   6    %0101
;   7    %1010
;
; Notice that the bitmasks for the sides are the OR'd sum of the bitmasks their
;  adjacent corners.

; List of all changed bytes (original values are all zero):
; 0x1BE15: 01
; 0x1BE19: 01
; 0x1BE1B: 02
; 0x1BE1C: 02

; 0x1BE25: 02
; 0x1BE27: 01
; 0x1BE28: 01
; 0x1BE2D: 02

; 0x1BE38: 01
; 0x1BE39: 01
; 0x1BE3C: 02
; 0x1BE3D: 02

; 0x1BE44: 02
; 0x1BE48: 02
; 0x1BE4B: 01
; 0x1BE4D: 01

; 0x1BE58: 02
; 0x1BE59: 01
; 0x1BE5C: 02
; 0x1BE5D: 01

; 0x1BE74: 02
; 0x1BE77: 01
; 0x1BE79: 01
; 0x1BE7C: 02

; 0x1BE84: 01
; 0x1BE87: 02
; 0x1BE89: 02
; 0x1BE8C: 01

; 0x1BEA8: 01
; 0x1BEA9: 02
; 0x1BEAC: 01
; 0x1BEAD: 02

; 0x1BEB4: 01
; 0x1BEB8: 01
; 0x1BEBB: 02
; 0x1BEBD: 02

; 0x1BEC8: 02
; 0x1BEC9: 02
; 0x1BECC: 01
; 0x1BECD: 01

; 0x1BED5: 01
; 0x1BED7: 02
; 0x1BED8: 02
; 0x1BEDD: 01

; 0x1BEE5: 02
; 0x1BEE9: 02
; 0x1BEEB: 01
; 0x1BEEC: 01

; EoF