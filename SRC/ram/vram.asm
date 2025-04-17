; VRAM defines

section "VRAM", vram[$8000], BANK[0]

; Sprite-only tiles - $8000 - $10 bytes/tile

def vramDest_creditsSpriteChr = $8000 ; 256 tiles

def vramDest_samus      = $8000 ; $B00 bytes
    ; Tile patch-in destinations
    def vramDest_cannon     = $8080 ; 2 tiles
    def vramDest_spinTop    = $8500 ; 7 tiles
    def vramDest_spinBottom = $8600 ; 5 tiles
    def vramDest_ballTop    = $8590 ; 2 tiles
    def vramDest_ballBottom = $8690 ; 2 tiles
    def vramDest_beam = $87E0 ; 2 tiles

; Shared Tiles - $8800
def vramDest_titleChr = $8800

def vramDest_enemies = $8B00 ; 64 tiles
    ; item orb = $8B00 ; 4 tiles
    def vramDest_item = $8B40 ; 4 tiles
    def vramDest_itemFont = $8C00 ; ? tiles
    def vramDest_commonItems = $8F00 ; 16 tiles
    
def vramDest_creditsNumbers = $8F00 ; 16 tiles

; BG Only Tiles - $9000
def vramDest_theEnd = $9000 ; 16 tiles

def vramDest_bgTiles = $9000 ; 128 tiles
    def vramDest_creditsFont = $9200 ; 32 tiles

; Background Tilemap - $9800-$9BFF - $20 bytes/row
def vramDest_queenFeet = $9A00
def vramDest_queenStatusBar = $9BE0

; Window Tilemap - $9C00-9FFF - $20 bytes/row
def vramDest_statusBar = $9C00
def vramDest_itemText  = $9C20
; Queen's head row 3
; Queen's head row 4


; Queen related constants

; First and last tiles to be clear by disintegration animation
def queenDeath_firstTile = $8B10
def queenDeath_lastTile = $9570
def queenDeath_bodyStart = $99A0
def queenDeath_bodyEnd = $9A80
