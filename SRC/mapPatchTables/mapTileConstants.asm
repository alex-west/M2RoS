def start_items = $00
def total_items = $36

MAP0 = $AF ;room pattern 0
MAP1 = $9D ;room pattern 1
MAP2 = $9C ;room pattern 2
MAP3 = $AD ;room pattern 3
MAPH = $8F ;horizontal to next map
MAPV = $8F ;vertical to next map
MAPI = $91 ;accessory/item/etank
MAPM = $91 ;missile tank
MAPW = $90 ;beam upgrades, respawn so leave on map
MAPR = $93 ;refill point
MAPZ = $92 ;save zone
MAPX = $FF ;cannot enter
SHIP = $36
LEFT = $00
RIGHT = $20
TST0 = $A0
TST1 = $A1
TST2 = $A2
TST3 = $A3
TST4 = $A4
TST5 = $A5
TST6 = $A6
TST7 = $A7

;how map sprite arrays are done:
;auto-validate address:
AUTOVAL = $c0
ENDLIST = $ff
COLLECTED = $02 ;works for doors, metroids, items :D
VALIDATEBANK9 = $c9
VALIDATEBANKA = $c9
VALIDATEBANKB = $c9
VALIDATEBANKC = $c9
VALIDATEBANKD = $ca
VALIDATEBANKE = $ca
VALIDATEBANKF = $ca
;6 entries per sprite
;- SRAM-to-check high (c5-c6),
;- SRAM-to-check low (00-ff),
;- sprite's map Y coord on window
;- sprite's map X coord on window
;- sprite tile to draw
;- sprite palette to use
;example:
;AUTOVAL, $00, $28, $48, $3f, $00, ENDLIST