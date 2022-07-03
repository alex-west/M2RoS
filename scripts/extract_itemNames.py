# Script by Alex W
# Thanks to PJ for the lambda functions

gb2hex = lambda gb: gb >> 2 & ~0x3FFF | gb & 0x3FFF
hex2gb = lambda hex: hex << 2 & ~0xFFFF | hex & 0x3FFF | 0x4000
romRead = lambda n: sum([ord(rom.read(1)) << i*8 for i in range(n)])
readLongPointer = lambda: (romRead(1) << 16) | romRead(2)

rom = open("../Metroid2.gb", "rb")
namesBegin = gb2hex(0x015911)

rom.seek(namesBegin)

print("; Item Names and Messages - 01:5911\n")

# Print pointers
for itemNum in range(0,16):
    print("    dw itemName_{:02X}".format(itemNum))
print("")

# Print charmap
print("NEWCHARMAP itemNames")
for x in range(0, 26):
    # Apologies for this one-liner
    print("CHARMAP \"{0}\", ${1:02X}".format( bytearray.fromhex( "{:X}".format(x+0x41) ).decode() , x+0xC0))

print("CHARMAP \"<\", $DE")
print("CHARMAP \">\", $DF")
print("CHARMAP \" \", $FF")
print("")

# Print Item names with labels
for itemNum in range(0,16):
    print("itemName_{:02X}: db \"".format(itemNum), end="")
    for charNum in range(0,16):
        temp = romRead(1)
        if temp == 0xFF:
            print(" ", end="")
        elif temp == 0xDE:
            print("<", end="")
        elif temp == 0xDF:
            print(">", end="")
        else:
            print(bytearray.fromhex("{:X}".format(temp-(0xC0-0x41))).decode(), end="")
    print("\"")

print("\n; End of item names")

