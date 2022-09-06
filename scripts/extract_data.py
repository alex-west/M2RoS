# Script by Alex W
# Thanks to PJ for the lambda functions

import argparse

# Tool for extracting generic tables of bytes and words from a binary file

gb2hex = lambda gb: gb >> 2 & ~0x3FFF | gb & 0x3FFF
hex2gb = lambda hex: hex << 2 & ~0xFFFF | hex & 0x3FFF | (0x4000 if (hex >= 0x4000) else 0)
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

rom = open("../Metroid2.gb", "rb")

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('-a', '--addrmode', choices=['g', 'h'], help='use GB bank addresses or hex rom offsets')
    ap.add_argument('-o', '--outmode', choices=['b', 'w'])
    ap.add_argument('-l', '--length', type=int, help='number of bytes/words to print')
    ap.add_argument('-w', '--width', type=int, default=16, help='width of output columns (default 16)')
    ap.add_argument('source', help='source address in hex')

    args = ap.parse_args()

    args.source = int(args.source, 16)
    
    if (args.addrmode == None) | (args.addrmode == "g"):
        source = gb2hex(args.source)
    
    rom.seek(source)
    
    print("; Data: {:06X}".format( hex2gb(rom.tell()) ) )
    if (args.outmode == None) | (args.outmode == 'b'):
        printBytes(args.length, args.width)
    elif  args.outmode == 'w':
        printWords(args.length, args.width)
    print("; End Data: {:06X}".format( hex2gb(rom.tell()) ) )
    

if __name__ == "__main__":
    main()

