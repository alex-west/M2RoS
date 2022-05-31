# Script by Alex W
# Thanks to PJ for the lambda functions

gb2hex = lambda gb: gb >> 2 & ~0x3FFF | gb & 0x3FFF
hex2gb = lambda hex: hex << 2 & ~0xFFFF | hex & 0x3FFF | 0x4000
romRead = lambda n: sum([ord(rom.read(1)) << i*8 for i in range(n)])
readLongPointer = lambda: (romRead(1) << 16) | romRead(2)

rom = open("../Metroid2.gb", "rb")

pointersBegin = gb2hex(0x036839)
numPointers = 255
perRow = 16
hitboxesBegin = gb2hex(0x036A37)
hitboxesEnd = gb2hex(0x036AE7)

rom.seek(pointersBegin)
for x in range(0, numPointers):
    if (x % perRow) == 0:
        print("\n    dw ", end="")
    print("hitbox{:04X}".format(romRead(2)), end="")
    if (((x+1) % perRow) != 0) & (x != numPointers-1):
        print(", ", end="")
print("\n")

rom.seek(hitboxesBegin)
while rom.tell() < hitboxesEnd:
    print("hitbox{:04X}: db".format(rom.tell()-0x8000), end="")
    
    # I just futzed with the rjust() values until the output looked good, okay?
    print("{:},".format(int.from_bytes(rom.read(1), byteorder='little', signed=True)).rjust(5), end="")
    print("{:},".format(int.from_bytes(rom.read(1), byteorder='little', signed=True)).rjust(4), end="")
    print("{:},".format(int.from_bytes(rom.read(1), byteorder='little', signed=True)).rjust(5), end="")
    print("{:}".format(int.from_bytes(rom.read(1), byteorder='little', signed=True)).rjust(3))
    