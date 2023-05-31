# samus.csv

The file `samus.csv` contains all of the tables in the game that are indexed by the variable `samusPose`.

The script `scripts/samus_csv2asm.py` is used to convert `samus.csv` into several `.asm` files that are included in various places in the project.

Note that there are a handful of tables that do not fill out a row for every single pose. This is undeniably bad practice, but I suppose the original devs decided to shave a few extra bytes because those rows are not relavent when being eaten by the Queen.

If you want to add a another pose-indexed table to the game, simply insert a named column using your spreadsheet software of choice to `samus.csv`, and then add the name of the column to either the `wordLists` or `byteLists` lists in `samus_csv2asm.py` (depending on whether the value is 2 bytes or 1 bytes). More sophisticated pose-indexed tables (such as `horizontalYOffset` one) will require the addition of bespoke code to the script.

Adding a new pose to the game is just a matter of adding a new row to the spreadsheet, and filling out all of the columns. Make sure in particular to have `poseJumpTable` and `drawJumpTable` reference actual labels in the game's source code, and please avoid leaving any cells blank. The unused poses `$14`-`$17` are perhaps a good place to start.

Shuffling the order of the rows in the spreadsheet should work just fine, with only a couple caveats: (a) the zeroeth pose `pose_standing` is sometimes referenced in code using `xor a` instead of `ld a, pose_standing`, and (b) the range of poses relating to being eaten by the Queen are special cased using `cp pose_beingEaten` so standard poses should not be put within that range.

Note that the `number` column in the spreadsheet is for convenience, and not referenced by any code in `samus_csv2asm.py`. It can be deleted without consequence.

Have fun adding fun, new characters to the game!
