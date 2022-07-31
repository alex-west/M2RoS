Changes to allow pausing during the Metroid Queen fight:

1. In Bank 0, remove the following lines to allow pausing:
```
tryPausing: ; 00:2C79
    ; Don't try pausing unless start is pressed
    ldh a, [hInputRisingEdge]
    cp PADF_START
        ret nz
-    ; Exit if in Queen's room
-    ld a, [$d08b]
-    cp $11
-        ret z
    ; No pausing if facing the screen
    ld a, [samusPose]
    cp pose_faceScreen
        ret z
```

2. In Bank 3, add this game mode check to the queen_drawFeet function, to prevent the feet from animating when paused:
```
    ldh a, [gameMode]
    cp $08
        ret z
```
Putting it after the first if statement works well enough, and allows for the head to finish drawing if a frame was only half-drawn.

3. In Bank 3, in the function LCDCInterruptHandler, make this change to allow the palette for the bottom half of the screen to be corrected:
```
        .case_2:
            ld a, [scrollX]
            ld [rSCX], a
+           ld a, [bg_palette]
-           ld a, $93 ; FIXME: Causes palette issues if pausing is enabled
            ld [rBGP], a
        ; end case
```
Note that this comes with the minor side-effect of the palette for the lower half of the screen being updated a frame early. At 60 FPS, this isn't too noticeable, but in the future a more robust solution might be found.