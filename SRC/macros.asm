; macros.asm

; Call a function in another bank
callFar: MACRO
    ld a, BANK(\1)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    call \1
ENDM

; Jump to a function in another bank
jpLong: MACRO
    ld a, BANK(\1)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
    jp \1
ENDM

; Switch to another bank (i.e. referencing a table in it)
switchBank: MACRO
    ld a, BANK(\1)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
ENDM