# Bank 2 Status Report

Legend
- S - Satisfactory (possibly improvable, but low priority)
- NW - Needs Work (comments, label names, etc.)
- X - Critical Errors (e.g. pointers need to be converted to labels)

| Code                    | Addr  | Status (comment)               |
|-------------------------|-------|--------------------------------|
| Core Enemy Routines     | $4000 | S (good except for collision vars) |
| Main Enemy Loop         | $409E | S                              |
| Load Enemy Flags        | $412F | S                              |
| Save/Load Enemy Flags   | $418C | S                              |
| Deactivate All Enemies  | $4217 | S                              |
| Enemy Drop/Damage proc  | $4239 | NW (weird exit)                |
| Directional Vuln. Check | $43A9 | S                              |
| Weapon Damage Table     | $43C8 | S                              |
| Move from WRAM to HRAM  | $43D2 | S                              |
| Move from HRAM to WRAM  | $4421 | S                              |
| Delete Offscreen Enemy  | $4464 | S                              |
| Reactivate Enemy        | $44C0 | S                              |
| Deactivate Enemy        | $452E | S                              |
| Update Scroll History   | $45CA | NW (don't other functions do this too?) |
| Unused Functions        | $45E4 | S                              |
| Enemy BG Collision      | $4608 | S (condense code w/macros)     |
| Load Blob Thrower Spr.  | $4DB1 | S                              |
| Item Orb AI             | $4DD3 | S                              |
| Blob Thrower AI         | $4EA1 | S                              |
| Arachnus AI             | $5109 | S                              |
| Blob Projectile         | $536F | S                              |
| Glow Fly AI             | $54A1 | S                              |
| Rock Icicle AI          | $5542 | S                              |
| Common Enemy Handler    | $5630 | S                              |
| Crawler AI (type A)     | $57DE | S                              |
| Shared Crawler Code     | $5895 | S                              |
| Crawler AI (type B)     | $58DE | S                              |
| Skreek Projectile       | $59A6 | S                              |
| Skreek AI               | $59C7 | S                              |
| Small Bug AI            | $5ABF | S                              |
| Drivel AI               | $5AE2 | S                              |
| Drivel Projectile       | $5BD4 | S                              |
| Senjoo/Shirk AI         | $5C36 | S                              |
| Gullugg AI              | $5CE0 | S                              |
| Chute Leech AI          | $5E0B | S                              |
| Pipe Bug AI             | $5F67 | S                              |
| Skorp AI (vertical)     | $60AB | S                              |
| Skorp AI (horizontal)   | $60F8 | S                              |
| Autrack AI              | $6145 | S                              |
| Hornoad/Hopper AI       | $61DB | S                              |
| Wallfire AI             | $62B4 | S                              |
| Gunzoo AI               | $638C | S                              |
| Autom AI                | $6540 | S                              |
| Proboscum AI            | $65D5 | S                              |
| Missile Block AI        | $6622 | S                              |
| Moto AI                 | $66F3 | S                              |
| Halzyn AI               | $6746 | S                              |
| Septogg AI              | $6841 | S                              |
| Flitt AI (vanishing)    | $68A0 | S                              |
| Flitt AI (moving)       | $68FC | S                              |
| Gravitt AI              | $695F | S                              |
| Missile Door AI         | $6A14 | S                              |
| Accel Forwards          | $6A7B | S                              |
| Accel Backwards         | $6AAE | S                              |
| Unknown Function        | $6AE1 | S (good enough)                |
| Common Enemy Routines   | $6B21 | S                              |
| Musical Sting Trigger   | $6B83 | S                              |
| First Alpha Metroid     | $6BB2 | S                              |
| Alpha Metroid AI        | $6C44 | S                              |
| Gamma Metroid AI        | $6F60 | S                              |
| Zeta Metroid AI         | $7276 | S                              |
| Omega Metroid AI        | $7631 | S                              |
| Normal Metroid AI       | $7A4F | S                              |
| Baby Metroid AI         | $7BE5 | S                              |
| Common Enemy Code       | $7DA0 | S                              |
