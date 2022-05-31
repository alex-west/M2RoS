# Script by Alex W
# Thanks to PJ for the lambda functions

gb2hex = lambda gb: gb >> 2 & ~0x3FFF | gb & 0x3FFF
hex2gb = lambda hex: hex << 2 & ~0xFFFF | hex & 0x3FFF | 0x4000
romRead = lambda n: sum([ord(rom.read(1)) << i*8 for i in range(n)])
readLongPointer = lambda: (romRead(1) << 16) | romRead(2)

rom = open("../Metroid2.gb", "rb")

pointersBegin = gb2hex(0x036300)
numPointers = 255
perRow = 16
headersBegin = gb2hex(0x0364FE)
headersEnd = gb2hex(0x03673A)

rom.seek(pointersBegin)
for x in range(0, numPointers):
    if (x % perRow) == 0:
        print("\n    dw ", end="")
    print("en{:04X}".format(romRead(2)), end="")
    if (((x+1) % perRow) != 0) & (x != numPointers-1):
        print(", ", end="")
print("\n")

rom.seek(headersBegin)
while rom.tell() < headersEnd:
    print("en{:04X}:\n    db ".format(rom.tell()-0x8000), end="")
    print("${:02X},".format(romRead(1)), end="")
    print("${:02X},".format(romRead(1)), end="")
    print("${:02X},".format(romRead(1)), end="")
    print("${:02X},".format(romRead(1)), end="")
    print("${:02X},".format(romRead(1)), end="")
    print("${:02X},".format(romRead(1)), end="")
    print("${:02X},".format(romRead(1)), end="")
    print("${:02X},".format(romRead(1)), end="")
    print("${:02X}".format(romRead(1)))
    print("    dw ${:04X}".format(romRead(2)))
    
    