;pause map tiles for area 1 and lair 1
	db MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX
	db MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX
	db MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAP0, MAP0, MAP0, MAP0, MAP0, MAP0, MAP0, MAP0, MAP0, MAP0, MAPX, MAPX, MAPX, MAPX
	db MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAP0, MAP0, MAP0, MAP0, MAP0, MAP0, MAP0, MAP0, MAP0, MAP0, MAPX, MAPX, MAPX, MAPX
	db MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAP0, MAP0, MAP0, MAP0, MAP1, MAP1, MAP1, MAP2, MAP0, MAP0, MAP2, MAPX, MAPX, MAPX
	db MAPX, MAPX, MAP2, MAP1, MAP1, MAP1, MAP0, MAP0, MAP2, MAP2, MAPX, MAPX, MAPX, MAP2, MAP0, MAP0, MAP1, MAP1, MAPX, MAPX
	db MAPX, MAPH, MAP2, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAP2, MAP1, MAP1, MAP1, MAP2, MAPX, MAPX, MAPX, MAP2, MAPX, MAPX
	db MAPX, MAPX, MAP2, MAPH, MAPX, MAPX, MAP2, MAP1, MAP1, MAP2, MAPX, MAPX, MAPX, MAP2, MAP1, MAP1, MAP1, MAP2, MAPX, MAPX
	db MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAP3, MAP1, MAP1, MAP2, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX
	db MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX
	db MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX
	db MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX
	db MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX
	db MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX
	db MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX
	db MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX, MAPX
;samus map sprite list
	;save and refill
	db AUTOVAL, $00, $30, $48, MAPR, $00
	db AUTOVAL, $00, $30, $68, MAPR, $00
	db AUTOVAL, $00, $48, $48, MAPZ, $00
	;items
	db VALIDATEBANKD, $22, $50, $68, MAPI, $00  ;etank
	db VALIDATEBANKD, $23, $58, $38, MAPI, $00  ;bomb
	db VALIDATEBANKC, $E0, $58, $90, MAPI, $00  ;spider
	db AUTOVAL, $00, $60, $58, MAPW, $00		;ice
	;missiles
	db VALIDATEBANKD, $20, $40, $58, MAPM, $00
	db VALIDATEBANKD, $21, $40, $68, MAPM, $00
	db VALIDATEBANKD, $3A, $58, $38, MAPM, $00
	db VALIDATEBANKD, $25, $58, $78, MAPM, $00
	db VALIDATEBANKD, $26, $58, $80, MAPM, $00
	db VALIDATEBANKD, $27, $58, $80, MAPM, $00
	db ENDLIST