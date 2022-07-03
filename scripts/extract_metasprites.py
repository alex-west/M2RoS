# Script by Alex W
# Thanks to PJ for the lambda functions

gb2hex = lambda gb: gb >> 2 & ~0x3FFF | gb & 0x3FFF
hex2gb = lambda hex: hex << 2 & ~0xFFFF | hex & 0x3FFF | 0x4000
romRead = lambda n: sum([ord(rom.read(1)) << i*8 for i in range(n)])
readLongPointer = lambda: (romRead(1) << 16) | romRead(2)

rom = open("../Metroid2.gb", "rb")

spriteSet = 3

if spriteSet == 1:
    spritePointersBegin = gb2hex(0x014000)
    spriteDataBegin = gb2hex(0x01408A)
    end = gb2hex(0x01493E)
elif spriteSet == 2:
    spritePointersBegin = gb2hex(0x015AB1)
    spriteDataBegin = gb2hex(0x015CAF)
    end = gb2hex(0x0170BA)
elif spriteSet == 3:
    spritePointersBegin = gb2hex(0x01744A)
    spriteDataBegin = gb2hex(0x017496)
    end = gb2hex(0x0179EF)

#Add each pointer to a set, and print it
rom.seek(spritePointersBegin)
print("; Sprite Pointers\n")
spritePointers = set([])
i = 0
while rom.tell() < spriteDataBegin:
    gbAddr = romRead(2)
    spritePointers.add(gbAddr)
    print("    dw sprite{:04X} ; ${:02X}".format(gbAddr, i))
    i += 1

# Read the sprite data
print("\n\n; Metasprite Data:")
rom.seek(spriteDataBegin)
sprite = 0
while rom.tell() < end:
    tempPointer = hex2gb(rom.tell()) & 0xFFFF
    if tempPointer in spritePointers:
        print("sprite{:04X}:".format(tempPointer))
    else:
        print("; 01:{:04X} - Unreferenced sprite".format(tempPointer))
    
    yPos = rom.read(1)
    while ord(yPos) != 0xFF:
        print("    db ", end="")
        print("{:},".format(int.from_bytes(yPos, byteorder='little', signed=True)).rjust(4), end="")
        
        xPos = rom.read(1)
        print("{:},".format(int.from_bytes(xPos, byteorder='little', signed=True)).rjust(4), end="")
        
        tile = romRead(1)
        print(" ${:02X}, ".format(tile), end="")
        
        attr = romRead(1)
        print("${:02X}".format(attr))
        
        yPos = rom.read(1)
        
    print("    db $FF")
    sprite += 1

'''
# EoF
'''