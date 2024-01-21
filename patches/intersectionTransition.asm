; Intersection Transition
;  This is the code for a custom intersection transition that
;  allows for 4 transitions on a single screen
;  The syntax is:
;   $E0
;   $AAAA - Index of Right transition
;   $BBBB - Index of Left transition
;   $CCCC - Index of Up transition
;
;   For down it will just continue the current transition



; Change 
.doorToken_item:
    cp $d0 ; ITEM {
    jp nz, .nextToken
; To the following
.doorToken_item:
    cp $d0 ; ITEM {
    jp nz, .doorToken_intersection 
 



; Then above the .nextToken: label insert this code:

    .doorToken_intersection:
    cp $E0 ; { You can change this to anything with $EX if needed
    jp nz, .nextToken
        ; Compare the current scrolling direction
        ; 1 Right, 2 Left, 4 Up, 8 Down
        ld a, [doorScrollDirection]
        cp $1
        jr nz, .checkScrollLeft ;check if scrolling right
            jr .loadNewTransition
        .checkScrollLeft
        inc hl
        inc hl
        cp $2
        jr nz, .checkScrollUp ;check if scrolling left
            jr .loadNewTransition
        .checkScrollUp: ;check if scrolling up
        inc hl
        inc hl
        cp $4
        jr nz, .executeScrollDown
            jr .loadNewTransition
        .executeScrollDown: ;at this point the scrolling has to be down
        inc hl
        inc hl
        inc hl
            ; to save on space, we will just continue the standard transition
            jr .nextToken
    ;}

; Subroutine to load new Transition from a Transition index in the next two bytes at HL
.loadNewTransition:
    inc HL
    ; Load door index
    ld a, [hl+]
    ld [doorIndexLow], a
    ld a, [hl]
    ld [doorIndexHigh], a
    ; Execute it
    jp executeDoorScript