# Enemy Tilemap Collision Procedures

Rather than a data-based approach, this game just has several routines for enemies to check background collision.

Here is a list of every one of those functions, along with the collision points they test as (x,y) pairs.

## Routines to check the right side of enemies 
Return value = $11

8 routines (2 unused)

Call_002_4608 - Near, Small
- (3,-3)
- (3, 3)

02:4635 - Unused - Mid, Small
- (7,-3)
- (7, 3)

Call_002_4662 - Mid, Medium
- (7,-6)
- (7, 0)
- (7, 6)

Call_002_46ac - Far, Medium
- (11,-7)
- (11, 0)
- (11, 7)

02:46E9 - Unused - Mid, Wide
- (7,-11)
- (7, -3)
- (7,  3)
- (7, 11)

Call_002_4736 - Far, Wide
- (11,-11)
- (11. -3)
- (11,  3)
- (11, 11)

Call_002_4783 - Crawl A
- (7,-8)
- (7, 7)

Call_002_47b4 - Crawl B
- (7,-7)
- (7, 8)

## Routines to check the left side of enemies (
Return value = $44

8 functions (2 unused)

Call_002_47e1 - Near, Small
- (-3,-3)
- (-3, 3)

; 02:480E - Unused - Mid, Small
- (-7,-3)
- (-7, 3)

Call_002_483b - Mid, Medium
- (-7,-6)
- (-7, 0)
- (-7, 6)

Call_002_4885 - Far, Medium
- (-11,-7)
- (-11, 0)
- (-11, 7)

02:48C2 - Unused - Mid, Wide
- (-7,-11)
- (-7, -3)
- (-7,  3)
- (-7, 11)

Call_002_490f - Far, Wide
- (-11,-11)
- (-11, -3)
- (-11,  3)
- (-11, 11)

Call_002_495c - Crawl A
- (-9,-7)
- (-9, 8)

Call_002_498d - Crawl B
- (-9,-8)
- (-9, 7)

## Routines to check the bottom edge of enemies
Return value = $22

9 functions (2 unused)

Call_002_49ba - Near, Small
- (-3,3)
- ( 3,3)

02:49E7 - Unused - Near, Medium
- (-7,3)
- ( 0,3)
- ( 7,3)

Call_002_4a28 - Mid, Medium
- (-6,7)
- ( 0,7)
- ( 6,7)

02:4A6E - Unused - Mid, Wide
- (-11,7)
- ( -3,7)
- (  3,7)
- ( 11,7)

Call_002_4abb - One Point
- (0,11)

Call_002_4ad6 - Far, Medium
- (-7,11)
- ( 0,11)
- ( 7,11)

Call_002_4b17 - Far, Wide
- (-11,11)
- ( -3,11)
- (  3,11)
- ( 11,11)

Call_002_4b64 - Crawl A
- (-8,8)
- ( 7,8)

Call_002_4b91 - Crawl B
- (-9,8)
- ( 6,8)

## Routines to check the top edge of enemies
Return value = $88

8 functions (3 unused)

Call_002_4bc2 - Near, Small
- (-3,-3)
- ( 3,-3)

02:4BEF - Unused - Near, Medium
- (-7,-3)
- ( 0,-3)
- ( 7,-3)

Call_002_4c30 - Mid, Medium
- (-6,-7)
- ( 0,-7)
- ( 6,-7)

02:4C76 - Unused - Mid, Wide
- (-11,-7)
- ( -3,-7)
- (  3,-7)
- ( 11,-7)

02:4CC3 - Unused - Far, Medium
- (-7,-11)
- ( 0,-11)
- ( 7,-11)

Call_002_4d04 - Far, Wide
- (-11,-11)
- ( -3,-11)
- (  3,-11)
- ( 11,-11)

Call_002_4d51 - Crawl A
- (-9,-8)
- ( 6,-8)

Call_002_4d7f - Crawl B
- (-8,-8)
- ( 7,-8)