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

; Switch active bank to another bank (based off of label)
switchBank: MACRO
    ld a, BANK(\1)
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
ENDM

; Switch to another bank (based off some other expression)
switchBankVar: MACRO
    ld a, \1
    ld [bankRegMirror], a
    ld [rMBC_BANK_REG], a
ENDM