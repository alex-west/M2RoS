# Bank 2 Status Report

TODO: Verify that code in the bank is fully relocatable.

Legend
- S - Satisfactory (possibly improvable, but low priority)
- N - Needs Work (comments, label names, etc.)
- X - Critical Errors (e.g. pointers need to be converted to labels)

| Code                    | Addr  | Status (comment)               |
|-------------------------|-------|--------------------------------|
| Core Enemy Routines     | $4000 | N                              |
| Enemy BG Collision      | $4608 | S (condense code w/macros)     |
| Misc. Blob Thrower Code | $4DB1 | N                              |
| Item Orb AI             | $4DD3 | N (WRAM vars)                  |
| Blob Thrower AI         | $4EA1 | S                              |
| Arachnus AI             | $5109 | S                              |
| Blob Projectile         | $536F | S                              |
| Glow Fly AI             | $54A1 | S                              |
| Rock Icicle AI          | $5542 | S                              |
| Common Enemy Handler    | $5630 | N (structure, labels)          |
| Crawler AI (type A)     | $57DE | N                              |
| Shared Crawler Code     | $5895 | N                              |
| Crawler AI (type B)     | $58DE | N                              |
| Skreek Projectile       | $59A6 | N (labels)                     |
| Skreek AI               | $59C7 | N                              |
| Small Bug AI            | $5ABF | S                              |
| Drivel AI               | $5AE2 | S                              |
| Drivel Projectile       | $5BD4 | S                              |
| Senjoo/Shirk AI         | $5C36 | S                              |
| Gullugg AI              | $5CE0 | S                              |
| Chute Leech AI          | $5E0B | S                              |
| Pipe Bug AI             | $5F67 | N                              |
| Skorp AI (type A)       | $60AB | N                              |
| Skorp AI (type B)       | $60F8 | N                              |
| Autrack AI              | $6145 | S                              |
| Hornoad/Hopper AI       | $61DB | S                              |
| Wallfire AI             | $62B4 | N                              |
| Gunzoo AI               | $638C | N                              |
| Autom AI                | $6540 | S                              |
| Proboscum AI            | $65D5 | N (identify states)            |
| Missile Block AI        | $6622 | N (feels unclear)              |
| Moto AI                 | $66F3 | S                              |
| Halzyn AI               | $6746 | S                              |
| Common Enemy Code       | $677C | N (purpose unclear)            |
| Septogg AI              | $6841 | S                              |
| Flitt AI (type A)       | $68A0 | N (identify states)            |
| Flitt AI (type B)       | $68FC | S                              |
| Gravitt AI              | $695F | S                              |
| Missile Door AI         | $6A14 | S                              |
| Accel Forwards          | $6A7B | S                              |
| Accel Backwards         | $6AAE | S                              |
| Unknown Function        | $6AE1 | S (good enough)                |
| Common Enemy Routines   | $6B21 | S                              |
| Baby Egg (?)            | $6B83 | N                              |
| First Alpha Metroid     | $6BB2 | N                              |
| Alpha Metroid AI        | $6C44 | N                              |
| Gamma Metroid AI        | $6F60 | N                              |
| Zeta Metroid AI         | $7276 | N                              |
| Omega Metroid AI        | $7631 | N                              |
| Normal Metroid AI       | $7A4F | N                              |
| Baby Metroid AI         | $7BE5 | N (closest of the Metroid AIs) |
| Common Enemy Code       | $7DA0 | N (function names)             |
