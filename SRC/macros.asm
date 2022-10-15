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

macro SongRest
    db $01
endm

macro Echo1
    db $03
endm

macro Echo2
    db $05
endm

macro SongNote ; [note name in "[A-G]b?[2-7]" format]
    def _note   equs strsub(\1, 0, strlen(\1) - 1)
    def _octave equs strsub(\1, -1, 1)
    
    def _i_octave equ _octave - 2
    static_assert _i_octave < 6, "Invalid note octave"
    
    if strcmp("\"{_note}\"", "\"C\"") == 0
        def _i_note equ 0
    elif strcmp("\"{_note}\"", "\"Db\"") == 0
        def _i_note equ 1
    elif strcmp("\"{_note}\"", "\"D\"") == 0
        def _i_note equ 2
    elif strcmp("\"{_note}\"", "\"Eb\"") == 0
        def _i_note equ 3
    elif strcmp("\"{_note}\"", "\"E\"") == 0
        def _i_note equ 4
    elif strcmp("\"{_note}\"", "\"F\"") == 0
        def _i_note equ 5
    elif strcmp("\"{_note}\"", "\"Gb\"") == 0
        def _i_note equ 6
    elif strcmp("\"{_note}\"", "\"G\"") == 0
        def _i_note equ 7
    elif strcmp("\"{_note}\"", "\"Ab\"") == 0
        def _i_note equ 8
    elif strcmp("\"{_note}\"", "\"A\"") == 0
        def _i_note equ 9
    elif strcmp("\"{_note}\"", "\"Bb\"") == 0
        def _i_note equ $A
    elif strcmp("\"{_note}\"", "\"B\"") == 0
        def _i_note equ $B
    else
        fail "Invalid note name"
    endc
    
    db (_i_octave * $C + _i_note + 1) * 2
    
    purge _note, _octave, _i_octave, _i_note
endm

macro SongNoiseNote ; [note index]
    static_assert \1 < $2A, "Invalid noise note index"
    db \1 * 4
endm

macro SongNoteLength ; [note length index]
    static_assert \1 < $20, "Invalid note length index"
    db \1 | $A0
endm

def SongNoteLength_Hemidemisemiquaver     equs "SongNoteLength 0"
def SongNoteLength_Demisemiquaver         equs "SongNoteLength 1"
def SongNoteLength_Semiquaver             equs "SongNoteLength 2"
def SongNoteLength_Quaver                 equs "SongNoteLength 3"
def SongNoteLength_Crochet                equs "SongNoteLength 4"
def SongNoteLength_Minum                  equs "SongNoteLength 5"
def SongNoteLength_DottedSemiquaver       equs "SongNoteLength 6"
def SongNoteLength_DottedQuaver           equs "SongNoteLength 7"
def SongNoteLength_DottedCrochet          equs "SongNoteLength 8"
def SongNoteLength_TripletSemiquaver      equs "SongNoteLength 9"
def SongNoteLength_TripletQuaver          equs "SongNoteLength $A"
def SongNoteLength_Semihemidemisemiquaver equs "SongNoteLength $B"
def SongNoteLength_Semibreve              equs "SongNoteLength $C"

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
