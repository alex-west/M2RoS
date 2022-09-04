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


macro LengthDutyOptions ; [sound length], [wave duty]
    static_assert \1 < $40, "Invalid sound length"
    static_assert \2 < 4, "Invalid wave duty"
    
    db \1 | \2 << 6
endm

macro EnvelopeOptions ; [number of envelope sweeps], [envelope sweep direction], [initial envelope]
    static_assert \1 < 8, "Invalid number of envelope sweeps"
    static_assert \2 < 2, "Invalid envelope sweep direction"
    static_assert \3 < $10, "Invalid initial envelope"
    
    db \1 | \2 << 3 | \3 << 4
endm

macro DescendingEnvelopeOptions ; [number of envelope sweeps], [initial envelope]
    EnvelopeOptions \1, 0, \2
endm

macro AscendingEnvelopeOptions ; [number of envelope sweeps], [initial envelope]
    EnvelopeOptions \1, 1, \2
endm
    
macro FrequencyOptions ; [initial frequency], [sound stops flag]
    static_assert \1 < $800, "Invalid initial frequency"
    static_assert \2 < 2, "Invalid sound stops flag"
    
    dw \1 | \2 << $E | 1 << $F
endm

macro SweepOptions ; [number of sweeps], [sweep direction], [sweep time]
    static_assert \1 < 8, "Invalid number of sweeps"
    static_assert \2 < 2, "Invalid sweep direction"
    static_assert \3 < 8, "Invalid sweep time"
    
    db \1 | \2 << 3 | \3 << 4
endm

macro AscendingSweepOptions ; [number of sweeps], [sweep time]
    SweepOptions \1, 0, \2
endm

macro DescendingSweepOptions ; [number of sweeps], [sweep time]
    SweepOptions \1, 1, \2
endm

macro LengthOptions ; [sound length]
    static_assert \1 < $40, "Invalid sound length"
    
    db \1
endm

macro PolynomialCounterOptions ; [frequency mantissa], [counter width], [frequency exponent]
    static_assert \1 < 8, "Invalid frequency mantissa"
    static_assert \2 < 2, "Invalid counter width"
    static_assert \3 < $10, "Invalid frequency exponent"
    
    db \1 | \2 << 3 | \3 << 4
endm

macro CounterControlOptions ; [sound stops flag]
    static_assert \1 < 2, "Invalid sound stops flag"
    
    db \1 << 6 | 1 << 7
endm

macro WaveOptions ; [wave pattern data pointer], [volume], [unused]
    static_assert \1 < $10000, "Invalid wave pattern data pointer"
    static_assert \2 < 4, "Invalid volume"
    static_assert \3 < $20, "Invalid unused"
    
    dw \1
    db \2 << 5 | \3
endm

macro SongHeader ; [music note offset], [CF01], [tone/sweep channel pointer], [tone channel pointer], [wave channel pointer], [noise channel pointer]
    static_assert \1 < $100, "Invalid music note offset"
    static_assert \2 < $10000, "Invalid CF01"
    assert \3 < $10000, "Invalid tone/sweep channel pointer"
    assert \4 < $10000, "Invalid tone channel pointer"
    assert \5 < $10000, "Invalid wave channel pointer"
    assert \6 < $10000, "Invalid noise channel pointer"
    
    db \1
    dw \2, \3, \4, \5, \6
endm

macro SongEnd
    db $00
endm

macro SongMute
    db $01
endm

macro SongSpecial3
    db $03
endm

macro SongSpecial5
    db $05
endm

; TODO
macro SongNote ; [note]
    static_assert \1 < $100, "Invalid note"
    db \1
endm

macro SongNoteLength ; [note length index]
    static_assert \1 < $20, "Invalid note length index"
    db \1 | $A0
endm

macro SongOptions
    db $F1
endm

macro SongTempo ; [tempo]
    static_assert \1 < $10000, "Invalid tempo"
    db $F2
    dw \1
endm

macro SongTranspose ; [transpose]
    static_assert \1 < $100, "Invalid transpose"
    db $F3
    db \1
endm

macro SongRepeatSetup ; [repetitions]
    static_assert \1 < $100, "Invalid number of repetitions"
    db $F4
    db \1
endm

macro SongRepeat
    db $F5
endm
