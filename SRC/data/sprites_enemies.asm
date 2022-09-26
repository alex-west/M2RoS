; Metasprite Data:
enSprite_none:
    db METASPRITE_END
enSprite_blankTile:
    db  -4, -4, $FF, $00
    db METASPRITE_END

enSprite_tsumuriHori_frame1:
    db  -8, -8, $B4, $00
    db  -8,  0, $B5, $00
    db   0, -8, $B6, $00
    db   0,  0, $B7, $00
    db METASPRITE_END
enSprite_tsumuriHori_frame2:
    db  -8, -8, $B4, $00
    db  -8,  0, $B5, $00
    db   0, -8, $B9, $00
    db   0,  0, $B8, $00
    db METASPRITE_END
enSprite_tsumuriVert_frame1:
    db  -8, -8, $BA, $00
    db  -8,  0, $BB, $00
    db   0, -8, $BC, $00
    db   0,  0, $BD, $00
    db METASPRITE_END
enSprite_tsumuriVert_frame2:
    db  -8, -8, $BA, $00
    db  -8,  0, $BE, $00
    db   0, -8, $BC, $00
    db   0,  0, $BF, $00
    db METASPRITE_END

enSprite_skreek_frame1:
    db  -6,-12, $C0, $00
    db  -8, -4, $C1, $00
    db  -8,  4, $C2, $00
    db   0, -4, $C3, $00
    db   0,  4, $C4, $00
    db METASPRITE_END
enSprite_skreek_frame2:
    db  -6,-12, $C5, $00
    db  -8, -4, $C6, $00
    db  -8,  4, $C7, $00
    db   0, -4, $C8, $00
    db   0,  4, $C9, $00
    db METASPRITE_END
enSprite_skreek_frame3:
    db  -6,-12, $CA, $00
    db  -8, -4, $CB, $00
    db  -8,  4, $CC, $00
    db   0, -4, $CD, $00
    db   0,  4, $CE, $00
    db METASPRITE_END
enSprite_skreek_frame4:
    db  -8,-12, $CF, $00
    db  -8, -4, $D0, $00
    db  -8,  4, $C2, $00
    db   0,-12, $D1, $00
    db   0, -4, $D2, $00
    db   0,  4, $C4, $00
    db METASPRITE_END
enSprite_skreekSpit:
    db  -4, -4, $D3, $00
    db METASPRITE_END

enSprite_drivel_frame1:
    db  -4,-16, $D4, $00
    db  -4, -8, $D5, $00
    db  -4,  0, $D5, $20
    db  -4,  8, $D4, $20
    db METASPRITE_END
enSprite_drivel_frame2:
    db  -4,-16, $D7, $00
    db  -4, -8, $D8, $00
    db  -4,  0, $D8, $20
    db  -4,  8, $D7, $20
    db   4,-16, $D6, $00
    db   4,  8, $D6, $20
    db METASPRITE_END
enSprite_drivel_frame3:
    db  -4, -8, $DA, $00
    db  -4,  0, $DA, $20
    db   4, -8, $D9, $00
    db   4,  0, $D9, $20
    db METASPRITE_END
enSprite_drivelSpit_frame1:
    db  -4, -4, $DB, $00
    db METASPRITE_END
enSprite_drivelSpit_frame2:
    db  -4, -4, $DC, $00
    db METASPRITE_END
enSprite_drivelSpit_frame3:
    db  -4, -4, $DD, $00
    db METASPRITE_END
enSprite_drivelSpit_frame4:
    db  -4, -8, $DE, $00
    db  -4,  0, $DE, $20
    db METASPRITE_END
enSprite_drivelSpit_frame5:
    db -12, -4, $DF, $00
    db -10,-10, $E0, $00
    db -10,  2, $E0, $20
    db  -4,-12, $E1, $00
    db  -4,  4, $E1, $20
    db METASPRITE_END
enSprite_drivelSpit_frame6:
    db -25, -4, $DF, $00
    db -17,-17, $E0, $00
    db -17,  9, $E0, $20
    db  -4,-20, $E1, $00
    db  -4, 12, $E1, $20
    db METASPRITE_END

enSprite_smallBug_frame1:
    db  -4, -8, $B0, $00
    db  -4,  0, $B1, $00
    db METASPRITE_END
enSprite_smallBug_frame2:
    db  -4, -8, $B2, $00
    db  -4,  0, $B3, $00
    db METASPRITE_END

enSprite_hornoad_frame1:
    db  -8,-12, $E2, $00
    db  -8, -4, $E3, $00
    db  -8,  4, $E4, $00
    db   0,-12, $E5, $00
    db   0, -4, $E6, $00
    db   0,  4, $E7, $00
    db METASPRITE_END
enSprite_hornoad_frame2:
    db  -8,-12, $E2, $00
    db  -8, -4, $E3, $00
    db  -8,  4, $E4, $00
    db   0,-12, $E5, $00
    db   0, -4, $E8, $00
    db   0,  4, $E9, $00
    db   8,  4, $EA, $00
    db METASPRITE_END

enSprite_septogg_frame1:
    db -12, -8, $EB, $00
    db -12,  0, $EB, $20
    db  -4,-12, $EC, $00
    db  -4, -4, $ED, $00
    db  -4,  4, $EC, $20
    db   4, -8, $EF, $00
    db   4,  0, $EF, $20
    db METASPRITE_END
enSprite_septogg_frame2:
    db -12, -8, $EB, $00
    db -12,  0, $EB, $20
    db  -4,-12, $EE, $00
    db  -4, -4, $ED, $00
    db  -4,  4, $EE, $20
    db   4, -8, $EF, $00
    db   4,  0, $EF, $20
    db METASPRITE_END

enSprite_senjoo:
    db  -8,-12, $B4, $00
    db  -8, -4, $B5, $00
    db  -8,  4, $B6, $00
    db   0,-12, $B7, $00
    db   0, -4, $B8, $00
    db   0,  4, $B9, $00
    db METASPRITE_END

enSprite_gawron_frame1:
    db  -8, -8, $BC, $00
    db  -8,  0, $BD, $00
    db   0, -8, $BE, $00
    db   0,  0, $BF, $00
    db METASPRITE_END
enSprite_gawron_frame2:
    db  -8, -8, $C0, $00
    db  -8,  0, $C1, $00
    db   0, -8, $BE, $00
    db   0,  0, $BF, $00
    db METASPRITE_END

enSprite_chuteLeech_frame1:
    db  -4,-12, $C2, $00
    db  -4, -4, $C3, $00
    db  -4,  4, $C2, $20
    db METASPRITE_END
enSprite_chuteLeech_frame2:
    db  -8, -8, $C5, $00
    db  -8,  0, $C5, $20
    db   0, -8, $C4, $00
    db   0,  0, $C4, $20
    db METASPRITE_END
enSprite_chuteLeech_frame3:
    db  -8, -4, $C9, $00
    db  -8,  4, $CA, $00
    db   0,-12, $C6, $00
    db   0, -4, $C7, $00
    db   0,  4, $C8, $00
    db METASPRITE_END

enSprite_gullugg_frame1:
    db -12,-16, $CB, $00
    db -12, -8, $CC, $00
    db -12,  0, $CC, $20
    db -12,  8, $CB, $20
    db  -4, -8, $CD, $00
    db  -4,  0, $CE, $00
    db   4,  0, $CF, $00
    db METASPRITE_END
enSprite_gullugg_frame2:
    db -12,-16, $D0, $00
    db -12, -8, $D1, $00
    db -12,  0, $D1, $20
    db -12,  8, $D0, $20
    db  -4, -8, $CD, $00
    db  -4,  0, $CE, $00
    db   4,  0, $CF, $00
    db METASPRITE_END
enSprite_gullugg_frame3:
    db -12, -8, $D2, $00
    db -12,  0, $D2, $20
    db  -4, -8, $CD, $00
    db  -4,  0, $CE, $00
    db   4,  0, $CF, $00
    db METASPRITE_END

enSprite_needler_frame1:
    db  -8, -8, $E6, $00
    db  -8,  0, $E7, $00
    db   0, -8, $E8, $00
    db   0,  0, $E9, $00
    db METASPRITE_END
enSprite_needler_frame2:
    db  -8, -8, $EA, $00
    db  -8,  0, $EB, $00
    db   0, -8, $EC, $00
    db   0,  0, $ED, $00
    db METASPRITE_END

enSprite_skorpVert:
    db -12, -8, $B4, $00
    db -12,  0, $B4, $00
    db  -4, -8, $B6, $00
    db  -4,  0, $B7, $00
    db   4, -8, $B8, $00
    db   4,  0, $B9, $00
    db METASPRITE_END
enSprite_skorpHori:
    db  -8,-12, $BA, $00
    db  -8, -4, $BB, $00
    db  -8,  4, $B4, $00
    db   0,-12, $BC, $00
    db   0, -4, $BD, $00
    db   0,  4, $B4, $00
    db METASPRITE_END

enSprite_glowFly_frame1:
    db -12, -4, $BE, $00
    db  -4, -4, $BF, $00
    db   4, -4, $C1, $00
    db METASPRITE_END
enSprite_glowFly_frame2:
    db -12, -4, $BE, $00
    db  -4, -4, $BF, $00
    db   4, -4, $C0, $00
    db METASPRITE_END
enSprite_glowFly_frame3:
    db  -8, -8, $C2, $00
    db  -8,  0, $C3, $00
    db   0, -8, $C4, $00
    db   0,  0, $C5, $00
    db METASPRITE_END
enSprite_glowFly_frame4:
    db  -8, -8, $C6, $00
    db  -8,  0, $C7, $00
    db   0, -8, $C8, $00
    db   0,  0, $C9, $00
    db METASPRITE_END

enSprite_rockIcicle_frame1:
    db  -4, -4, $D2, $00
    db METASPRITE_END
enSprite_rockIcicle_frame2:
    db  -4, -4, $D3, $00
    db METASPRITE_END
enSprite_rockIcicle_frame3:
    db  -8, -4, $D4, $00
    db   0, -4, $D5, $00
    db METASPRITE_END
enSprite_rockIcicle_frame4:
    db  -8, -4, $D4, $00
    db   0, -4, $D6, $00
    db METASPRITE_END

enSprite_moheekHori_frame1:
    db  -8, -8, $D7, $00
    db  -8,  0, $D8, $00
    db   0, -8, $DB, $00
    db   0,  0, $DC, $00
    db METASPRITE_END
enSprite_moheekHori_frame2:
    db  -8, -8, $D9, $00
    db  -8,  0, $DA, $00
    db   0, -8, $DB, $00
    db   0,  0, $DD, $00
    db METASPRITE_END
enSprite_moheekVert_frame1:
    db  -8, -8, $DE, $00
    db  -8,  0, $DF, $00
    db   0, -8, $E1, $00
    db   0,  0, $E2, $00
    db METASPRITE_END
enSprite_moheekVert_frame2:
    db  -8, -8, $E3, $00
    db  -8,  0, $E0, $00
    db   0, -8, $E4, $00
    db   0,  0, $E2, $00
    db METASPRITE_END

enSprite_yumee_frame1:
    db  -8, -8, $E5, $00
    db  -8,  0, $E9, $00
    db   0,  0, $EA, $00
    db METASPRITE_END
enSprite_yumee_frame2:
    db  -8, -8, $E5, $00
    db  -8,  0, $E9, $00
    db   0,  0, $EB, $00
    db METASPRITE_END
enSprite_yumee_frame3:
    db  -8, -8, $E5, $00
    db  -8,  0, $E6, $00
    db  -8,  8, $E7, $00
    db METASPRITE_END
enSprite_yumee_frame4:
    db  -8, -8, $E5, $00
    db  -8,  0, $E6, $00
    db  -8,  8, $E8, $00
    db METASPRITE_END

enSprite_flitt_frame1:
    db  -8, -8, $CA, $00
    db  -8,  0, $CB, $00
    db   0, -8, $CC, $00
    db   0,  0, $CD, $00
    db METASPRITE_END
enSprite_flitt_frame2:
    db  -8, -8, $CE, $00
    db  -8,  0, $CF, $00
    db   0, -8, $D0, $00
    db   0,  0, $D1, $00
    db METASPRITE_END

enSprite_stalagtite: ; Unused
    db  -8, -8, $EC, $00
    db  -8,  0, $ED, $00
    db   0, -4, $EE, $00
    db   8, -4, $EF, $00
    db METASPRITE_END

enSprite_octroll_frame1:
    db  -8, -8, $B4, $00
    db  -8,  0, $B4, $20
    db   0,-16, $B5, $00
    db   0, -8, $B6, $00
    db   0,  0, $B6, $20
    db   0,  8, $B5, $20
    db   8, -8, $B7, $00
    db   8,  0, $B7, $20
    db METASPRITE_END
enSprite_octroll_frame2:
    db  -8, -8, $B4, $00
    db  -8,  0, $B4, $20
    db   0,-16, $BA, $00
    db   0, -8, $B6, $00
    db   0,  0, $B6, $20
    db   0,  8, $BA, $20
    db   8, -8, $B7, $00
    db   8,  0, $B7, $20
    db METASPRITE_END
enSprite_octroll_frame3:
    db  -8, -8, $B4, $00
    db  -8,  0, $B4, $20
    db   0,-16, $B8, $00
    db   0, -8, $B9, $00
    db   0,  0, $B9, $20
    db   0,  8, $B8, $20
    db METASPRITE_END

enSprite_autrack_frame1:
    db  -8, -8, $BB, $00
    db  -8,  0, $BC, $00
    db   0, -8, $BD, $00
    db   0,  0, $BE, $00
    db METASPRITE_END
enSprite_autrack_frame2:
    db -16, -8, $BF, $00
    db -16,  0, $C0, $00
    db  -8, -8, $C1, $00
    db  -8,  0, $C2, $00
    db   0, -8, $BD, $00
    db   0,  0, $BE, $00
    db METASPRITE_END
enSprite_autrack_frame3:
    db -24, -8, $BF, $00
    db -24,  0, $C0, $00
    db -16, -8, $C3, $00
    db -16,  0, $C4, $00
    db  -8, -8, $C1, $00
    db  -8,  0, $C2, $00
    db   0, -8, $BD, $00
    db   0,  0, $BE, $00
    db METASPRITE_END
enSprite_autrack_frame4:
    db -24, -8, $C5, $00
    db -24,  0, $C0, $00
    db -16, -8, $C3, $00
    db -16,  0, $C4, $00
    db  -8, -8, $C1, $00
    db  -8,  0, $C2, $00
    db   0, -8, $BD, $00
    db   0,  0, $BE, $00
    db METASPRITE_END
enSprite_autrackShot:
    db  -4, -8, $C6, $00
    db  -4,  0, $C6, $00
    db METASPRITE_END

enSprite_autoad_frame1:
    db  -8,-12, $C8, $00
    db  -8, -4, $C9, $00
    db  -8,  4, $C8, $20
    db   0,-12, $CA, $00
    db   0, -4, $CB, $00
    db   0,  4, $CA, $20
    db METASPRITE_END
enSprite_autoad_frame2:
    db  -8,-12, $C8, $00
    db  -8, -4, $CF, $00
    db  -8,  4, $C8, $20
    db   0,-12, $CC, $00
    db   0, -4, $CD, $00
    db   0,  4, $CC, $20
    db   8,-10, $CE, $00
    db   8,  2, $CE, $20
    db METASPRITE_END

enSprite_sideAutoad_frame1:
    db -12, -8, $D0, $00
    db -12,  0, $D1, $00
    db  -4, -8, $D2, $00
    db  -4,  0, $D3, $00
    db   4, -8, $D0, $40
    db   4,  0, $D1, $40
    db METASPRITE_END
enSprite_sideAutoad_frame2:
    db -12, -8, $D0, $00
    db -12,  0, $D4, $00
    db -10,  8, $D6, $00
    db  -4, -8, $D7, $00
    db  -4,  0, $D5, $00
    db   2,  8, $D6, $40
    db   4, -8, $D0, $40
    db   4,  0, $D4, $40
    db METASPRITE_END

enSprite_wallfire_frame1:
    db -12, -4, $D8, $00
    db -12,  4, $D9, $00
    db  -4, -4, $DA, $00
    db  -4,  4, $DB, $00
    db   4, -4, $DC, $00
    db METASPRITE_END
enSprite_wallfire_frame2:
    db -12, -4, $DD, $00
    db -12,  4, $DE, $00
    db  -4, -4, $DA, $00
    db  -4,  4, $E0, $00
    db   4, -4, $DC, $00
    db METASPRITE_END
enSprite_wallfire_broken:
    db -12, -4, $E5, $00
    db  -4, -4, $E6, $00
    db   4, -4, $E7, $00
    db METASPRITE_END
enSprite_wallfireShot_frame1:
    db  -4,-12, $E1, $00
    db  -4, -4, $E2, $00
    db METASPRITE_END
enSprite_wallfireShot_frame2:
    db  -4, -4, $E3, $00
    db METASPRITE_END
enSprite_wallfireShot_frame3:
    db  -8, -4, $E4, $00
    db   0, -4, $E4, $40
    db METASPRITE_END
enSprite_wallfireShot_frame4:
    db -16, -4, $E4, $00
    db   8, -4, $E4, $40
    db METASPRITE_END

enSprite_gunzoo_frame1:
    db -12,-12, $B4, $00
    db -12, -4, $B5, $00
    db -12,  4, $B6, $00
    db  -4,-12, $B7, $00
    db  -4, -4, $B8, $00
    db  -4,  4, $B9, $00
    db   4,-12, $BA, $00
    db   4, -4, $BB, $00
    db   4,  4, $BC, $00
    db METASPRITE_END
enSprite_gunzoo_frame2:
    db -12,-12, $BD, $00
    db -12, -4, $B5, $00
    db -12,  4, $BF, $00
    db -12, 12, $C0, $00
    db  -4,-12, $B7, $00
    db  -4, -4, $CD, $00
    db  -4,  4, $C1, $00
    db  -4, 12, $C2, $00
    db   4,-12, $BA, $00
    db   4, -4, $C3, $00
    db   4,  4, $C4, $00
    db   4, 12, $C5, $00
    db METASPRITE_END
enSprite_gunzoo_frame3:
    db -12,-12, $B4, $00
    db -12, -4, $B5, $00
    db -12,  4, $BF, $00
    db -12, 12, $C0, $00
    db  -4,-12, $BE, $00
    db  -4, -4, $CD, $00
    db  -4,  4, $C1, $00
    db  -4, 12, $C2, $00
    db   4,-12, $BA, $00
    db   4, -4, $C3, $00
    db   4,  4, $C4, $00
    db   4, 12, $C5, $00
    db METASPRITE_END

enSprite_gunzooShotDiag_frame1:
    db  -4, -4, $CE, $00
    db METASPRITE_END
enSprite_gunzooShotDiag_frame2:
    db  -8, -4, $D0, $00
    db   0, -4, $CF, $00
    db METASPRITE_END
enSprite_gunzooShotDiag_frame3:
    db -16, -4, $D2, $00
    db  -8, -4, $D1, $00
    db   0, -4, $D0, $00
    db   8, -4, $CF, $00
    db METASPRITE_END

enSprite_gunzooShotHori_frame1:
    db  -4, -4, $C6, $00
    db METASPRITE_END
enSprite_gunzooShotHori_frame2:
    db  -4, -4, $C7, $00
    db  -4,  4, $C8, $00
    db METASPRITE_END
enSprite_gunzooShotHori_frame3:
    db  -8, -4, $C9, $00
    db   0, -4, $C9, $40
    db METASPRITE_END
enSprite_gunzooShotHori_frame4:
    db -20, -4, $CA, $00
    db -12, -4, $CB, $00
    db   4, -4, $CB, $40
    db  12, -4, $CA, $40
    db METASPRITE_END
enSprite_gunzooShotHori_frame5:
    db -24, -4, $CC, $00
    db  16, -4, $CC, $40
    db METASPRITE_END

enSprite_autom_frame1:
    db -12,-12, $D3, $00
    db -12, -4, $D4, $00
    db  -4,-12, $D5, $00
    db  -4, -4, $D6, $00
    db  -4,  4, $D7, $00
    db   4, -4, $D8, $00
    db METASPRITE_END
enSprite_autom_frame2:
    db -12,-12, $D3, $00
    db -12, -4, $D4, $00
    db  -4,-12, $E0, $00
    db  -4, -4, $D6, $00
    db  -4,  4, $D7, $00
    db   4, -4, $D8, $00
    db METASPRITE_END
enSprite_automShot_frame1:
    db  -4, -4, $D9, $00
    db METASPRITE_END
enSprite_automShot_frame2:
    db -12, -4, $DA, $00
    db  -4, -4, $DB, $00
    db   4, -4, $D9, $00
    db METASPRITE_END
enSprite_automShot_frame3:
    db -20, -4, $DB, $00
    db -12, -4, $DA, $00
    db  -4, -4, $DB, $00
    db   4, -4, $DA, $00
    db  12, -4, $D9, $00
    db METASPRITE_END
enSprite_automShot_frame4:
    db -20, -4, $DA, $00
    db -12, -4, $DB, $00
    db  -4, -4, $DA, $00
    db   4, -4, $DB, $00
    db  12,-12, $DC, $00
    db  12, -4, $DD, $00
    db  12,  4, $DC, $20
    db METASPRITE_END
enSprite_automShot_frame5:
    db -20, -4, $DB, $00
    db -12, -4, $DA, $00
    db  -4, -4, $DB, $00
    db   4, -4, $DA, $00
    db  12,-12, $DE, $00
    db  12, -4, $DF, $00
    db  12,  4, $DE, $20
    db METASPRITE_END

enSprite_shirk_frame1:
    db -12,-12, $E1, $00
    db -12, -4, $E2, $00
    db -12,  4, $E3, $00
    db  -4,-12, $E4, $00
    db  -4, -4, $EF, $00
    db  -4,  4, $E6, $00
    db   4,-12, $ED, $00
    db   4, -4, $EE, $00
    db   4,  4, $E9, $00
    db METASPRITE_END
enSprite_shirk_frame2:
    db -12,-12, $EA, $00
    db -12, -4, $EB, $00
    db -12,  4, $E3, $00
    db  -4,-12, $EC, $00
    db  -4, -4, $E5, $00
    db  -4,  4, $E6, $00
    db   4,-12, $E7, $00
    db   4, -4, $E8, $00
    db   4,  4, $E9, $00
    db METASPRITE_END

enSprite_moto_frame1:
    db -12,-16, $BD, $00
    db -12, -8, $BE, $00
    db -12,  0, $BF, $00
    db  -4,-16, $C0, $00
    db  -4, -8, $C1, $00
    db  -4,  0, $C2, $00
    db   4,-16, $C3, $00
    db   4, -8, $C4, $00
    db   4,  0, $C5, $00
    db METASPRITE_END
enSprite_moto_frame2:
    db -13,-16, $BD, $00
    db -13, -8, $BE, $00
    db -13,  0, $BF, $00
    db  -5,-16, $C0, $00
    db  -5, -8, $C6, $00
    db  -5,  0, $C7, $00
    db   3,-16, $C3, $00
    db   3, -8, $C8, $00
    db   3,  0, $C9, $00
    db METASPRITE_END
enSprite_moto_frame3:
    db -12,-16, $BD, $00
    db -12, -8, $BE, $00
    db -12,  0, $BF, $00
    db  -4,-16, $C0, $00
    db  -4, -8, $C6, $00
    db  -4,  0, $C7, $00
    db   4,-16, $C3, $00
    db   4, -8, $CA, $00
    db   4,  0, $CB, $00
    db METASPRITE_END

enSprite_halzyn:
    db  -8,-12, $CC, $00
    db  -8, -4, $CD, $00
    db  -8,  4, $CE, $00
    db   0,-12, $CF, $00
    db   0, -4, $D0, $00
    db   0,  4, $D1, $00
    db METASPRITE_END

enSprite_ramulken_frame1:
    db -16, -4, $D2, $00
    db  -8,-12, $D3, $00
    db  -8, -4, $D4, $00
    db  -8,  4, $D5, $00
    db   0,-12, $D6, $00
    db   0, -4, $D7, $00
    db   0,  4, $D8, $00
    db METASPRITE_END
enSprite_ramulken_frame2:
    db -16, -4, $D2, $00
    db  -8,-12, $D3, $00
    db  -8, -4, $D4, $00
    db  -8,  4, $D5, $00
    db   0,-12, $D9, $00
    db   0, -4, $DA, $00
    db   0,  4, $DB, $00
    db   8, -8, $DC, $00
    db   8,  0, $DD, $00
    db METASPRITE_END

enSprite_gravitt_frame1:
    db -16, -4, $B8, $00
    db  -8, -8, $B6, $00
    db  -8,  0, $B7, $00
    db   0, -8, $B4, $00
    db   0,  0, $B5, $00
    db METASPRITE_END
enSprite_gravitt_frame2:
    db -16, -4, $B8, $00
    db  -8, -8, $B6, $00
    db  -8,  0, $B7, $00
    db   0, -8, $B9, $00
    db   0,  0, $BA, $00
    db METASPRITE_END
enSprite_gravitt_frame3:
    db -16, -4, $B8, $00
    db  -8, -8, $B6, $00
    db  -8,  0, $B7, $00
    db   0, -8, $BB, $00
    db   0,  0, $BC, $00
    db METASPRITE_END

enSprite_proboscum_frame1:
    db  -4,-12, $E4, $00
    db  -4, -4, $E5, $00
    db  -4,  4, $E6, $00
    db   4,-12, $E7, $00
    db METASPRITE_END
enSprite_proboscum_frame2:
    db  -4,-12, $E4, $00
    db  -4, -4, $E8, $00
    db   4,-12, $E7, $00
    db   4, -4, $E9, $00
    db   4,  4, $EA, $00
    db METASPRITE_END
enSprite_proboscum_frame3:
    db  -4,-12, $E4, $00
    db  -4, -4, $EB, $00
    db   4,-12, $E7, $00
    db   4, -4, $EC, $00
    db  12, -4, $ED, $00
    db METASPRITE_END

enSprite_arachnus_frame1:
    db  -8, -8, $CB, $00
    db  -8,  0, $CC, $00
    db   0, -8, $CD, $00
    db   0,  0, $CE, $00
    db METASPRITE_END
enSprite_arachnus_frame2:
    db  -8, -8, $CD, $40
    db  -8,  0, $CB, $20
    db   0, -8, $CE, $20
    db   0,  0, $CC, $40
    db METASPRITE_END
enSprite_arachnus_frame3:
    db -16, -4, $B8, $00
    db -16,  4, $B9, $00
    db  -8,-12, $BB, $00
    db  -8, -4, $BC, $00
    db  -8,  4, $BD, $00
    db  -5,-20, $BA, $00
    db   0,-12, $BF, $00
    db   0, -4, $C0, $00
    db   0,  4, $C1, $00
    db   3,-20, $BE, $00
    db   8,-12, $C2, $00
    db   8, -4, $C3, $00
    db   8,  4, $C4, $00
    db METASPRITE_END
enSprite_arachnus_frame4:
    db -16, -4, $B8, $00
    db -16,  4, $B9, $00
    db  -8,-28, $C5, $00
    db  -8,-20, $C6, $00
    db  -8,-12, $C7, $00
    db  -8, -4, $BC, $00
    db  -8,  4, $BD, $00
    db   0,-12, $C8, $00
    db   0, -4, $C0, $00
    db   0,  4, $C1, $00
    db   8,-12, $C2, $00
    db   8, -4, $C3, $00
    db   8,  4, $C4, $00
    db METASPRITE_END
enSprite_arachnus_frame5:
    db -16,-28, $CF, $00
    db -16, -4, $B8, $00
    db -16,  4, $B9, $00
    db  -8,-28, $D0, $00
    db  -8,-20, $D1, $00
    db  -8,-12, $D2, $00
    db  -8, -4, $BC, $00
    db  -8,  4, $BD, $00
    db   0,-12, $C8, $00
    db   0, -4, $C0, $00
    db   0,  4, $C1, $00
    db   8,-12, $C2, $00
    db   8, -4, $C3, $00
    db   8,  4, $C4, $00
    db METASPRITE_END
enSprite_arachnusShot_frame1:
    db  -4, -4, $CA, $00
    db METASPRITE_END
enSprite_arachnusShot_frame2:
    db  -4, -4, $C9, $00
    db METASPRITE_END

enSprite_smallHealth_frame1:
    db  -4, -4, $92, $00
    db METASPRITE_END
enSprite_smallHealth_frame2:
    db  -4, -4, $93, $00
    db METASPRITE_END

enSprite_bigHealth_frame1:
    db  -8, -8, $94, $00
    db  -8,  0, $94, $20
    db   0, -8, $94, $40
    db   0,  0, $94, $60
    db METASPRITE_END
enSprite_bigHealth_frame2:
    db  -8, -8, $95, $00
    db  -8,  0, $95, $20
    db   0, -8, $95, $40
    db   0,  0, $95, $60
    db METASPRITE_END

enSprite_bigExplosion_frame1:
    db  -9, -4, $89, $00
    db  -4,-10, $96, $20
    db  -4,  1, $96, $20
    db   1, -4, $89, $40
    db METASPRITE_END
enSprite_bigExplosion_frame2:
    db -12, -4, $89, $00
    db -10,-10, $97, $00
    db -10,  2, $97, $20
    db  -4,-16, $96, $00
    db  -4,  4, $96, $20
    db   2,-10, $97, $40
    db   2,  2, $97, $60
    db   4, -4, $89, $20
    db METASPRITE_END
enSprite_bigExplosion_frame3:
    db -18,-18, $97, $00
    db -13, -4, $89, $00
    db  -4,-18, $96, $00
    db  -4,  5, $96, $20
    db   4,-12, $97, $40
    db   4, -4, $89, $40
    db METASPRITE_END
enSprite_bigExplosion_frame4:
    db -20,-20, $97, $00
    db -20, 11, $97, $20
    db -14, -4, $89, $00
    db  -4,-22, $96, $00
    db  -4,  8, $96, $20
    db   8,-16, $97, $40
    db  16, -4, $89, $40
    db METASPRITE_END
enSprite_bigExplosion_frame5:
    db -20, 16, $89, $00
    db -16, -4, $89, $20
    db  -4,-20, $96, $00
    db  -4, 12, $96, $20
    db  12,-16, $89, $40
    db  12, 12, $97, $60
    db METASPRITE_END
enSprite_bigExplosion_frame6:
    db  -4,-20, $96, $00
    db METASPRITE_END

enSprite_smallExplosion_frame1:
    db  -8, -8, $88, $00
    db  -8,  0, $88, $20
    db   0, -8, $88, $40
    db   0,  0, $88, $60
    db METASPRITE_END
enSprite_smallExplosion_frame2:
    db  -4, -4, $8A, $00
    db METASPRITE_END
enSprite_smallExplosion_frame3:
    db -12,-12, $85, $00
    db -12, -4, $86, $00
    db -12,  4, $85, $20
    db  -4,-12, $87, $00
    db  -4,  4, $87, $20
    db   4,-12, $85, $40
    db   4, -4, $86, $40
    db   4,  4, $85, $60
    db METASPRITE_END
enSprite_smallExplosion_frame4:
    db -16,-16, $7B, $00
    db -16, -8, $7C, $00
    db -16,  0, $7C, $20
    db -16,  8, $7B, $20
    db  -8,-16, $7D, $00
    db  -8,  8, $7D, $20
    db   0,-16, $7D, $40
    db   0,  8, $7D, $60
    db   8,-16, $7B, $40
    db   8, -8, $7C, $40
    db   8,  0, $7C, $60
    db   8,  8, $7B, $60
    db METASPRITE_END

enSprite_missileDrop_frame1:
    db  -4, -4, $99, $00
    db METASPRITE_END
enSprite_missileDrop_frame2:
    db  -4, -4, $99, $10
    db METASPRITE_END

; 01:66EF - Unreferenced sprite 0
    db  -8, -8, $B8, $00
    db   0, -8, $C8, $00
    db   8, -8, $D8, $00
    db METASPRITE_END
; 01:66FC - Unreferenced sprite 1
    db  -8, -8, $B9, $00
    db   0, -8, $C9, $00
    db   8, -8, $D9, $00
    db METASPRITE_END
; 01:6709 - Unreferenced sprite 2
    db  -8, -8, $C6, $00
    db  -8,  0, $C7, $00
    db   0, -8, $D6, $00
    db   0,  0, $D7, $00
    db METASPRITE_END
; 01:671A - Unreferenced sprite 3
    db  -8, -8, $BA, $00
    db  -8,  0, $BB, $00
    db   0, -8, $CA, $00
    db   0,  0, $CB, $00
    db METASPRITE_END
; 01:672B - Unreferenced sprite 4
    db  -8, -8, $DA, $00
    db  -8,  0, $DB, $00
    db   0, -8, $EA, $00
    db   0,  0, $EB, $00
    db METASPRITE_END
; 01:673C - Unreferenced sprite 5
    db  -8, -8, $DC, $00
    db  -8,  0, $DD, $00
    db   0, -8, $EC, $00
    db   0,  0, $ED, $00
    db METASPRITE_END
; 01:674D - Unreferenced sprite 6
    db  -8, -8, $E4, $00
    db  -8,  0, $E4, $20
    db   0,-16, $D0, $00
    db   0, -8, $D1, $00
    db   0,  0, $D1, $20
    db   0,  8, $D0, $20
    db METASPRITE_END
; 01:6766 - Unreferenced sprite 7
    db  -8, -8, $E3, $00
    db  -8,  0, $E3, $20
    db   0,-16, $D0, $00
    db   0, -8, $D1, $00
    db   0,  0, $D1, $20
    db   0,  8, $D0, $20
    db METASPRITE_END
; 01:677F - Unreferenced sprite 8
    db -12, -8, $D2, $00
    db -12,  0, $D2, $20
    db  -4, -8, $E2, $00
    db  -4,  0, $E2, $20
    db   4,-16, $E0, $00
    db   4, -8, $E1, $00
    db   4,  0, $E1, $20
    db   4,  8, $E0, $20
    db METASPRITE_END
; 01:67A0 - Unreferenced sprite 9
    db -12, -8, $B1, $00
    db -12,  0, $B2, $00
    db  -4,-16, $C0, $00
    db  -4, -8, $C1, $00
    db  -4,  0, $C2, $00
    db   4, -8, $B6, $00
    db   4,  0, $B7, $00
    db METASPRITE_END
; 01:67BD - Unreferenced sprite A
    db -12, -8, $B1, $00
    db -12,  0, $B2, $00
    db  -4,-16, $C0, $00
    db  -4, -8, $C1, $00
    db  -4,  0, $C2, $00
    db   4, -8, $B0, $00
    db   4,  0, $D5, $00
    db METASPRITE_END
; 01:67DA - Unreferenced sprite B
    db -16,-12, $B3, $00
    db  -8,-12, $C3, $00
    db  -8, -4, $C4, $00
    db  -8,  4, $C5, $00
    db   0,-12, $D3, $00
    db   0, -4, $D4, $00
    db   0,  4, $D5, $00
    db METASPRITE_END
; 01:67F7 - Unreferenced sprite C
    db -16,-12, $B3, $00
    db  -8,-12, $C3, $00
    db  -8, -4, $B4, $00
    db  -8,  4, $B5, $00
    db   0,-12, $D3, $00
    db   0, -4, $D4, $00
    db   0,  4, $D5, $00
    db METASPRITE_END
; 01:6814 - Unreferenced sprite D
    db  -4, -4, $E5, $00
    db METASPRITE_END
; 01:6819 - Unreferenced sprite E
    db  -8, -8, $BC, $00
    db  -8,  0, $BD, $00
    db   0, -8, $CC, $00
    db   0,  0, $CD, $00
    db METASPRITE_END
; 01:682A - Unreferenced sprite F
    db  -8, -8, $BE, $00
    db  -8,  0, $BF, $00
    db   0, -8, $CE, $00
    db   0,  0, $CF, $00
    db METASPRITE_END
; 01:683B - Unreferenced sprite 10
    db  -4, -8, $DE, $00
    db  -4,  0, $DE, $20
    db METASPRITE_END
; 01:6844 - Unreferenced sprite 11
    db  -8, -4, $DF, $00
    db -16, -4, $DF, $40
    db METASPRITE_END

enSprite_missileDoor:
    db -24,-23, $F4, $20
    db -16,-23, $F5, $20
    db  -8,-23, $F6, $20
    db   0,-23, $F6, $60
    db   8,-23, $F5, $60
    db  16,-23, $F4, $60
    db -24, 16, $F4, $00
    db -16, 16, $F5, $00
    db  -8, 16, $F6, $00
    db   0, 16, $F6, $40
    db   8, 16, $F5, $40
    db  16, 16, $F4, $40
    db METASPRITE_END
enSprite_missileBlock:
    db  -8, -8, $F7, $00
    db  -8,  0, $F8, $00
    db   0, -8, $F9, $00
    db   0,  0, $FA, $00
    db METASPRITE_END

enSprite_metroid_frame1:
    db -12,-16, $B4, $00
    db -12, -8, $B5, $00
    db -12,  0, $B6, $00
    db -12,  8, $B7, $00
    db  -4,-16, $C4, $00
    db  -4, -8, $C5, $00
    db  -4,  0, $C6, $00
    db  -4,  8, $C7, $00
    db   4,-16, $D4, $00
    db   4, -8, $D5, $00
    db   4,  0, $D6, $00
    db   4,  8, $D7, $00
    db METASPRITE_END
enSprite_alpha_face:
    db -12,-12, $C8, $00
    db -12, -4, $C9, $00
    db -12,  4, $CA, $00
    db  -4,-16, $D8, $00
    db  -4, -8, $D9, $00
    db  -4,  0, $DA, $00
    db  -4,  8, $DB, $00
    db   4,-12, $E8, $00
    db   4, -4, $E9, $00
    db   4,  4, $EA, $00
    db METASPRITE_END
enSprite_alpha_frame1:
    db -12,-16, $B0, $00
    db -12, -8, $B1, $00
    db -12,  0, $B2, $00
    db -12,  8, $B3, $00
    db  -4,-16, $C0, $00
    db  -4, -8, $C1, $00
    db  -4,  0, $C2, $00
    db  -4,  8, $C3, $00
    db   4, -9, $D1, $00
    db   4, -1, $D2, $00
    db   4,  7, $D3, $00
    db METASPRITE_END
enSprite_alpha_frame2:
    db -12,-16, $B0, $00
    db -12, -8, $B1, $00
    db -12,  0, $E4, $00
    db -12,  8, $E5, $00
    db  -4,-16, $B8, $00
    db  -4, -8, $B9, $00
    db  -4,  0, $E6, $00
    db  -4,  8, $E7, $00
    db   4, -8, $D1, $00
    db   4,  0, $D2, $00
    db   4,  8, $D3, $00
    db METASPRITE_END
enSprite_metroid_frame2:
    db -12,-16, $EB, $00
    db -12, -8, $EC, $00
    db -12,  0, $ED, $00
    db -12,  8, $EE, $00
    db  -4,-16, $BE, $00
    db  -4, -8, $C5, $00
    db  -4,  0, $C6, $00
    db  -4,  8, $BF, $00
    db   4,-16, $CB, $00
    db   4, -8, $CF, $00
    db   4,  0, $DF, $00
    db   4,  8, $EF, $00
    db METASPRITE_END
enSprite_metroid_frame3:
    db -12,-16, $B4, $00
    db -12, -8, $D0, $00
    db -12,  0, $DC, $00
    db -12,  8, $B7, $00
    db  -4,-16, $C4, $00
    db  -4, -8, $DD, $00
    db  -4,  0, $DE, $00
    db  -4,  8, $C7, $00
    db   4,-16, $D4, $00
    db   4, -8, $D5, $00
    db   4,  0, $D6, $00
    db   4,  8, $D7, $00
    db METASPRITE_END

enSprite_gammaBolt_frame1:
    db  -4, -4, $BE, $00
    db   4,-12, $CE, $00
    db   4, -4, $CF, $00
    db  12,-12, $BF, $00
    db METASPRITE_END
enSprite_gammaBolt_frame2:
    db  -4,-20, $ED, $00
    db  -4,-12, $EE, $00
    db  -4, -4, $EF, $00
    db METASPRITE_END
enSprite_gamma_frame1:
    db -12,-20, $B4, $00
    db -12,-12, $B5, $00
    db -12, -4, $B6, $00
    db -12,  4, $B7, $00
    db -12, 12, $B8, $00
    db  -4,-12, $C5, $00
    db  -4, -4, $C6, $00
    db  -4,  4, $C7, $00
    db  -4, 12, $C8, $00
    db   4,-20, $D4, $00
    db   4,-12, $D5, $00
    db   4, -4, $D6, $00
    db   4,  4, $D7, $00
    db   4, 12, $D8, $00
    db  12, -4, $E6, $00
    db  12,  4, $E7, $00
    db  12, 12, $E8, $00
    db METASPRITE_END
enSprite_gamma_frame2:
    db -16,-20, $B4, $00
    db -16,-12, $B5, $00
    db -16, -4, $B6, $00
    db -16,  4, $B7, $00
    db -16, 12, $B8, $00
    db  -8,-12, $C5, $00
    db  -8, -4, $BB, $00
    db  -8,  4, $BC, $00
    db  -8, 12, $BD, $00
    db   0,-20, $D4, $00
    db   0,-12, $D5, $00
    db   0, -4, $CB, $00
    db   0,  4, $CC, $00
    db   0, 12, $CD, $00
    db   8, -4, $DB, $00
    db   8,  4, $DC, $00
    db   8, 12, $DD, $00
    db  16, -4, $EB, $00
    db  16,  4, $EC, $00
    db METASPRITE_END

enSprite_gammaHusk:
    db -12,-20, $B4, $00
    db -12,-12, $B5, $00
    db -12, -4, $C4, $00
    db  -4,-12, $C5, $00
    db  -4, -4, $C6, $00
    db  -4,  4, $E5, $00
    db  -4, 12, $E0, $00
    db   4,-20, $D4, $00
    db   4,-12, $D5, $00
    db   4, -4, $D6, $00
    db   4,  4, $D7, $00
    db   4, 12, $D8, $00
    db  12, -4, $E6, $00
    db  12,  4, $E7, $00
    db  12, 12, $E8, $00
    db METASPRITE_END
enSprite_zeta_frame1:
    db -16,-12, $B0, $00
    db -16, -4, $B1, $00
    db -16,  4, $B2, $00
    db  -8,-12, $C0, $00
    db  -8, -4, $C1, $00
    db  -8,  4, $C2, $00
    db   0,-12, $D0, $00
    db   0, -4, $D1, $00
    db   0,  4, $D2, $00
    db   0, 12, $BE, $00
    db   0, 20, $BF, $00
    db   8, -4, $E1, $00
    db   8,  4, $E2, $00
    db METASPRITE_END
enSprite_zeta_frame2:
    db -16,-12, $B0, $00
    db -16, -4, $B1, $00
    db -16,  4, $B2, $00
    db  -8,-12, $C0, $00
    db  -8, -4, $C1, $00
    db  -8,  4, $C2, $00
    db   0,-12, $D0, $00
    db   0, -4, $D1, $00
    db   0,  4, $D2, $00
    db   0, 12, $CE, $00
    db   0, 20, $CF, $00
    db   8, -4, $E1, $00
    db   8,  4, $E2, $00
    db METASPRITE_END
enSprite_zeta_frame3:
    db -16,-12, $B0, $00
    db -16, -4, $B1, $00
    db -16,  4, $B2, $00
    db  -8,-12, $C0, $00
    db  -8, -4, $C1, $00
    db  -8,  4, $C2, $00
    db   0,-12, $D0, $00
    db   0, -4, $D1, $00
    db   0,  4, $D2, $00
    db   0, 12, $DE, $00
    db   0, 20, $DF, $00
    db   8, -4, $E1, $00
    db   8,  4, $E2, $00
    db METASPRITE_END
enSprite_zeta_frame4:
    db -16,-12, $B0, $00
    db -16, -4, $B1, $00
    db -16,  4, $B2, $00
    db  -8,-12, $C0, $00
    db  -8, -4, $C1, $00
    db  -8,  4, $C2, $00
    db   0,-12, $D0, $00
    db   0, -4, $D1, $00
    db   0,  4, $D2, $00
    db   0, 12, $EE, $00
    db   0, 20, $EF, $00
    db   8, -4, $E1, $00
    db   8,  4, $E2, $00
    db METASPRITE_END
enSprite_zeta_frame5:
    db -16,-12, $B0, $00
    db -16, -4, $B1, $00
    db -16,  4, $B2, $00
    db  -8,-12, $C0, $00
    db  -8, -4, $C1, $00
    db  -8,  4, $C2, $00
    db   0,-12, $D0, $00
    db   0, -4, $CA, $00
    db   0,  4, $CB, $00
    db   0, 12, $BE, $00
    db   0, 20, $BF, $00
    db   8, -4, $DA, $00
    db   8,  4, $DB, $00
    db  16, -4, $EA, $00
    db  16,  4, $EB, $00
    db METASPRITE_END
enSprite_zeta_frame6:
    db -16,-20, $B3, $00
    db -16,-12, $B9, $00
    db -16, -4, $BA, $00
    db -16,  4, $B2, $00
    db  -8,-20, $C3, $00
    db  -8,-12, $C9, $00
    db  -8, -4, $C1, $00
    db  -8,  4, $C2, $00
    db   0,-12, $D9, $00
    db   0, -4, $D1, $00
    db   0,  4, $D2, $00
    db   0, 12, $BE, $00
    db   0, 20, $BF, $00
    db   8, -4, $E1, $00
    db   8,  4, $E2, $00
    db METASPRITE_END
enSprite_zeta_frame7:
    db -16,-20, $B3, $00
    db -16,-12, $B9, $00
    db -16, -4, $BA, $00
    db -16,  4, $B2, $00
    db  -8,-20, $BB, $00
    db  -8,-12, $C9, $00
    db  -8, -4, $C1, $00
    db  -8,  4, $C2, $00
    db   0,-12, $CC, $00
    db   0, -4, $D1, $00
    db   0,  4, $D2, $00
    db   0, 12, $EE, $00
    db   0, 20, $EF, $00
    db   8, -4, $E1, $00
    db   8,  4, $E2, $00
    db METASPRITE_END
enSprite_zeta_frame8:
    db -16,-12, $B0, $00
    db -16, -4, $B1, $00
    db -16,  4, $B2, $00
    db  -8,-12, $BD, $00
    db  -8, -4, $E3, $00
    db  -8,  4, $E9, $00
    db   0,-12, $CD, $00
    db   0, -4, $D3, $00
    db   0,  4, $CB, $00
    db   0, 12, $BE, $00
    db   0, 20, $BF, $00
    db   8, -4, $DA, $00
    db   8,  4, $DB, $00
    db  16, -4, $EA, $00
    db  16,  4, $EB, $00
    db METASPRITE_END
enSprite_zeta_frame9:
    db -16,-12, $B0, $00
    db -16, -4, $B1, $00
    db -16,  4, $B2, $00
    db  -8,-12, $BD, $00
    db  -8, -4, $E3, $00
    db  -8,  4, $E9, $00
    db   0,-12, $CD, $00
    db   0, -4, $D3, $00
    db   0,  4, $CB, $00
    db   0, 12, $CE, $00
    db   0, 20, $CF, $00
    db   8, -4, $DA, $00
    db   8,  4, $DB, $00
    db  16, -4, $EA, $00
    db  16,  4, $EB, $00
    db METASPRITE_END
enSprite_zeta_frameA:
    db -16,-12, $B0, $00
    db -16, -4, $B1, $00
    db -16,  4, $B2, $00
    db  -8,-12, $BD, $00
    db  -8, -4, $E3, $00
    db  -8,  4, $E9, $00
    db   0,-12, $CD, $00
    db   0, -4, $D3, $00
    db   0,  4, $CB, $00
    db   0, 12, $DE, $00
    db   0, 20, $DF, $00
    db   8, -4, $DA, $00
    db   8,  4, $DB, $00
    db  16, -4, $EA, $00
    db  16,  4, $EB, $00
    db METASPRITE_END
enSprite_zeta_frameB:
    db -16,-12, $B0, $00
    db -16, -4, $B1, $00
    db -16,  4, $B2, $00
    db  -8,-12, $BD, $00
    db  -8, -4, $E3, $00
    db  -8,  4, $E9, $00
    db   0,-12, $CD, $00
    db   0, -4, $D3, $00
    db   0,  4, $CB, $00
    db   0, 12, $EE, $00
    db   0, 20, $EF, $00
    db   8, -4, $DA, $00
    db   8,  4, $DB, $00
    db  16, -4, $EA, $00
    db  16,  4, $EB, $00
    db METASPRITE_END
enSprite_zetaShot:
    db  -4, -4, $DC, $00
    db  -4,  4, $DD, $00
    db   4, -4, $EC, $00
    db METASPRITE_END

enSprite_omega_frame1:
    db -16,-16, $B4, $00
    db -16, -8, $B5, $00
    db  -8,-24, $C3, $00
    db  -8,-16, $C4, $00
    db  -8, -8, $C5, $00
    db  -8,  0, $C6, $00
    db  -8,  8, $C7, $00
    db   0,-16, $D4, $00
    db   0, -8, $D5, $00
    db   0,  0, $D6, $00
    db   0,  8, $D7, $00
    db   8, -8, $E5, $00
    db   8,  0, $E6, $00
    db   8,  8, $E7, $00
    db  16,  0, $C8, $00
    db  16,  8, $C9, $00
    db  16, 16, $CA, $00
    db  24,  0, $D8, $00
    db  24,  8, $D9, $00
    db  32,  0, $E8, $00
    db  32,  8, $E9, $00
    db METASPRITE_END
enSprite_omega_frame2:
    db -16,-16, $B4, $00
    db -16, -8, $B5, $00
    db  -8,-24, $C3, $00
    db  -8,-16, $C4, $00
    db  -8, -8, $C5, $00
    db  -8,  0, $C6, $00
    db  -8,  8, $C7, $00
    db   0,-16, $D4, $00
    db   0, -8, $D5, $00
    db   0,  0, $D6, $00
    db   0,  8, $D7, $00
    db   8, -8, $E5, $00
    db   8,  0, $E6, $00
    db   8,  8, $E7, $00
    db  16,  0, $C8, $00
    db  16,  8, $C9, $00
    db  16, 16, $DA, $00
    db  24,  0, $D8, $00
    db  24,  8, $D9, $00
    db  32,  0, $E8, $00
    db  32,  8, $E9, $00
    db METASPRITE_END
enSprite_omega_frame3:
    db -16,-16, $B4, $00
    db -16, -8, $B5, $00
    db  -8,-24, $B3, $00
    db  -8,-16, $C4, $00
    db  -8, -8, $C5, $00
    db  -8,  0, $C6, $00
    db  -8,  8, $C7, $00
    db   0,-16, $E4, $00
    db   0, -8, $D5, $00
    db   0,  0, $D6, $00
    db   0,  8, $D7, $00
    db   8, -8, $E5, $00
    db   8,  0, $E6, $00
    db   8,  8, $E7, $00
    db  16,  0, $C8, $00
    db  16,  8, $C9, $00
    db  16, 16, $CA, $00
    db  24,  0, $D8, $00
    db  24,  8, $D9, $00
    db  32,  0, $E8, $00
    db  32,  8, $E9, $00
    db METASPRITE_END
enSprite_omega_frame4:
    db -16,-16, $B4, $00
    db -16, -8, $B5, $00
    db  -8,-24, $B3, $00
    db  -8,-16, $C4, $00
    db  -8, -8, $C5, $00
    db  -8,  0, $C6, $00
    db  -8,  8, $C7, $00
    db   0,-16, $E4, $00
    db   0, -8, $D5, $00
    db   0,  0, $D6, $00
    db   0,  8, $D7, $00
    db   8, -8, $E5, $00
    db   8,  0, $E6, $00
    db   8,  8, $E7, $00
    db  16,  0, $C8, $00
    db  16,  8, $C9, $00
    db  16, 16, $DA, $00
    db  24,  0, $D8, $00
    db  24,  8, $D9, $00
    db  32,  0, $E8, $00
    db  32,  8, $E9, $00
    db METASPRITE_END
enSprite_omega_frame5:
    db -16,-16, $B4, $00
    db -16, -8, $B5, $00
    db  -8,-24, $C3, $00
    db  -8,-16, $C4, $00
    db  -8, -8, $C5, $00
    db  -8,  0, $C6, $00
    db  -8,  8, $C7, $00
    db   0,-16, $D4, $00
    db   0, -8, $D5, $00
    db   0,  0, $D6, $00
    db   0,  8, $D7, $00
    db   8, -8, $E5, $00
    db   8,  0, $E6, $00
    db   8,  8, $E7, $00
    db  16,  0, $C8, $00
    db  16,  8, $CB, $00
    db  16, 16, $DA, $00
    db  24,  8, $DB, $00
    db  24, 16, $DC, $00
    db  32,  8, $EB, $00
    db METASPRITE_END
enSprite_omega_frame6:
    db -16,-16, $B6, $00
    db -16, -8, $B7, $00
    db  -8,-24, $B8, $00
    db  -8,-16, $B9, $00
    db  -8, -8, $BA, $00
    db  -8,  0, $C6, $00
    db  -8,  8, $C7, $00
    db   0,-16, $BB, $00
    db   0, -8, $D5, $00
    db   0,  0, $D6, $00
    db   0,  8, $D7, $00
    db   8, -8, $E5, $00
    db   8,  0, $E6, $00
    db   8,  8, $E7, $00
    db  16,  0, $C8, $00
    db  16,  8, $C9, $00
    db  16, 16, $CA, $00
    db  24,  0, $D8, $00
    db  24,  8, $D9, $00
    db  32,  0, $E8, $00
    db  32,  8, $E9, $00
    db METASPRITE_END
enSprite_omega_frame7:
    db -16,-16, $B6, $00
    db -16, -8, $B7, $00
    db  -8,-24, $B8, $00
    db  -8,-16, $B9, $00
    db  -8, -8, $BA, $00
    db  -8,  0, $C6, $00
    db  -8,  8, $C7, $00
    db   0,-16, $BB, $00
    db   0, -8, $D5, $00
    db   0,  0, $D6, $00
    db   0,  8, $D7, $00
    db   8, -8, $E5, $00
    db   8,  0, $E6, $00
    db   8,  8, $E7, $00
    db  16,  0, $C8, $00
    db  16,  8, $CB, $00
    db  16, 16, $DA, $00
    db  24,  8, $DB, $00
    db  24, 16, $DC, $00
    db  32,  8, $EB, $00
    db METASPRITE_END

enSprite_omegaShot_frame1:
    db -12, -4, $BC, $00
    db -12,  4, $BD, $00
    db  -4, -4, $CC, $00
    db  -4,  4, $CD, $00
    db METASPRITE_END
enSprite_omegaShot_frame2:
    db -12, -4, $D3, $00
    db -12,  4, $E3, $00
    db  -4, -4, $CE, $00
    db  -4,  4, $CF, $00
    db METASPRITE_END
enSprite_omegaShot_frame3:
    db  -4, -8, $DD, $00
    db  -4,  0, $DE, $00
    db METASPRITE_END
enSprite_omegaShot_frame4:
    db  -4,-20, $EC, $00
    db  -4,-12, $ED, $00
    db  -4,  4, $ED, $20
    db  -4, 12, $EC, $20
    db METASPRITE_END
enSprite_omegaShot_frame5:
    db  -4,-24, $EE, $00
    db  -4, 16, $EE, $20
    db METASPRITE_END
enSprite_omegaShot_frame6:
    db  -4,-28, $EF, $00
    db  -4, 20, $EF, $20
    db METASPRITE_END
enSprite_omegaShot_frame7:
    db  -4, -4, $DF, $00
    db METASPRITE_END
enSprite_omegaShot_frame8:
    db  -4, -4, $EA, $00
    db METASPRITE_END

enSprite_egg_frame1:
    db -12,-15, $B4, $00
    db -12, -7, $B5, $00
    db -12,  1, $B4, $20
    db  -4,-14, $B6, $00
    db  -4, -6, $B7, $00
    db  -4,  2, $B6, $20
    db   4,-13, $B8, $00
    db   4, -5, $B9, $00
    db   4,  3, $B8, $20
    db METASPRITE_END
enSprite_egg_frame2:
    db -12,-12, $B4, $00
    db -12, -4, $B5, $00
    db -12,  4, $B4, $20
    db  -4,-12, $B6, $00
    db  -4, -4, $B7, $00
    db  -4,  4, $B6, $20
    db   4,-12, $B8, $00
    db   4, -4, $B9, $00
    db   4,  4, $B8, $20
    db METASPRITE_END
enSprite_egg_frame3:
    db -12, -9, $B4, $00
    db -12, -1, $B5, $00
    db -12,  7, $B4, $20
    db  -4,-10, $B6, $00
    db  -4, -2, $B7, $00
    db  -4,  6, $B6, $20
    db   4,-11, $B8, $00
    db   4, -3, $B9, $00
    db   4,  5, $B8, $20
    db METASPRITE_END

enSprite_baby_frame1:
    db  -8, -8, $B0, $00
    db  -8,  0, $B0, $20
    db   0, -8, $B1, $00
    db   0,  0, $B1, $20
    db METASPRITE_END
enSprite_baby_frame2:
    db  -8, -8, $B2, $00
    db  -8,  0, $B2, $20
    db   0, -8, $B3, $00
    db   0,  0, $B3, $20
    db METASPRITE_END

enSprite_itemOrb:
    db  -8, -8, $B0, $00
    db  -8,  0, $B1, $00
    db   0, -8, $B2, $00
    db   0,  0, $B3, $00
    db METASPRITE_END
enSprite_item:
    db  -8, -8, $B4, $00
    db  -8,  0, $B5, $00
    db   0, -8, $B6, $00
    db   0,  0, $B7, $00
    db METASPRITE_END
enSprite_energyTank:
    db  -8, -8, $AB, $00
    db  -8,  0, $AC, $00
    db   0, -8, $AD, $00
    db   0,  0, $AE, $00
    db METASPRITE_END
enSprite_missileTank:
    db  -8, -8, $F0, $00
    db  -8,  0, $F1, $00
    db   0, -8, $F2, $00
    db   0,  0, $F3, $00
    db METASPRITE_END

enSprite_energyRefill:
    db  -8, -8, $FD, $00
    db  -8,  0, $FD, $20
    db   0, -8, $FD, $40
    db   0,  0, $FD, $60
    db METASPRITE_END
enSprite_missileRefill:
    db  -8, -4, $FB, $00
    db   0, -4, $FC, $00
    db METASPRITE_END

enSprite_blob_frame1:
    db  -4, -4, $E4, $00
    db METASPRITE_END
enSprite_blob_frame2:
    db  -4, -4, $E5, $00
    db METASPRITE_END
