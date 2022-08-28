; Vertical enemy loading fix
;  This modifies the vertical enemy loading code so that it doesn't run
;  on the assumption that horizontally connected screens contain contiguous
;  data, allowing for more tightly packed enemy data. This comes at the minor
;  cost of needing to explicitly deference the adjacent screen's pointer
;  (the horizontal loading case already does this though).

;03:4135: ; Hijack point, if that's necessary for your purposes
    jp verticalCheck_hijack
    nop
    nop
    nop
    nop
hijack_return:

;------

verticalCheck_hijack: ; 03:7DAD from 03:4135
    ; Check if the left and right screen are the same, exit if so
    ld a, [rightEdge_screen]
    ld c, a
    ld a, [leftEdge_screen]
    cp c
        ret z
    ld a, c
    ; Iterate to the bottom screen (properly)
    call loadEnemy_getBankOffset
    call loadEnemy_getPointer.screen
jp hijack_return ; 03:413C