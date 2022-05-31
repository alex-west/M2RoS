# Script by Alex W
# Thanks to PJ for the lambda functions

gb2hex = lambda gb: gb >> 2 & ~0x3FFF | gb & 0x3FFF
hex2gb = lambda hex: hex << 2 & ~0xFFFF | hex & 0x3FFF | 0x4000
romRead = lambda n: sum([ord(rom.read(1)) << i*8 for i in range(n)])
readLongPointer = lambda: (romRead(1) << 16) | romRead(2)

rom = open("../Metroid2.gb", "rb")
creditsBegin = gb2hex(0x067920)

rom.seek(creditsBegin)
temp = romRead(1)

print("    db \"", end="")
while temp != 0xF0:
    if temp == 0xF1: # Newline
        print("\\n\"\n    db \"", end="")
    elif temp == 0x5E: # Dashes aren't ^s
        print("-", end="")
    elif temp == 0x1B: # Colon for time
        print(":", end="")
    elif (temp > 0x20) & (temp < 0x30): # For the "The End" tilemap
        print("\",", end="")
        while (temp > 0x20) & (temp < 0x30):
            print("${:02X},".format(temp), end="")
            temp = romRead(1)
        print("\"", end="")
        rom.seek(rom.tell()-1) # Undo the previous read (because we don't have goto)
    else:
        print(bytearray.fromhex("{:X}".format(temp)).decode(), end="")
	
    temp = romRead(1)
	
print("<END>\"")

