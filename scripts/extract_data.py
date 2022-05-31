# Script by Alex W
# Thanks to PJ for the lambda functions

# Tool for extracting generic tables of bytes and words from a binary file

gb2hex = lambda gb: gb >> 2 & ~0x3FFF | gb & 0x3FFF
hex2gb = lambda hex: hex << 2 & ~0xFFFF | hex & 0x3FFF | 0x4000
romRead = lambda n: sum([ord(rom.read(1)) << i*8 for i in range(n)])
readLongPointer = lambda: (romRead(1) << 16) | romRead(2)

def printBytes(numBytes, perRow):
    for x in range(0, numBytes):
        if (x % perRow) == 0:
            print("\n    db ", end="")
        print("${:02X}".format(romRead(1)), end="")
        if (((x+1) % perRow) != 0)  & (x != numBytes-1):
            print(", ", end="")
    print("\n")

def printWords(numWords, perRow):
    for x in range(0, numWords):
        if (x % perRow) == 0:
            print("\n    dw ", end="")
        print("${:04X}".format(romRead(2)), end="")
        if (((x+1) % perRow) != 0)  & (x != numWords-1):
            print(", ", end="")
    print("\n")

def printLevelBank(bankNum):
    rom.seek( gb2hex((bankNum << 16)|0x4000) )
    
    print("; Bank {:X} Level Data".format(bankNum) )
    print(";  Generated using scripts/extract_data.py")
    
    print("SECTION \"ROM Bank ${0:03X}\", ROMX[$4000], BANK[${0:X}]".format(bankNum))
    print("; Screen Data Pointers")
    printWords(0x100,16)
    
    print("; Scroll Data")
    printBytes(0x100,16)
    
    print("; Room Transition Indexes ")
    printWords(0x100,16)
    
    for screen in range(0x45, 0x80):
        print("; Screen ${:02X}00".format(screen) )
        printBytes(0x100,16)
    
#TODO: Make this take commandline arguments rather than editing these parameters every time
rom = open("../Metroid2.gb", "rb")
source = gb2hex(0x037490)
#source = 0x0D4B
length = 0x30
columns = 1

rom.seek(source)
print("; Table")
printWords(length, columns)
