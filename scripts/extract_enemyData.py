# Script by Alex W
# Thanks to PJ for the lambda functions

gb2hex = lambda gb: gb >> 2 & ~0x3FFF | gb & 0x3FFF
hex2gb = lambda hex: hex << 2 & ~0xFFFF | hex & 0x3FFF | 0x4000
romRead = lambda n: sum([ord(rom.read(1)) << i*8 for i in range(n)])
readLongPointer = lambda: (romRead(1) << 16) | romRead(2)

rom = open("../Metroid2.gb", "rb")
enemyPointersBegin = gb2hex(0x0342E0)
enemyDataBegin = gb2hex(0x0350E0)
end = gb2hex(0x036244)

#Read enemy pointers and give each a name
enemyPointers = []
rom.seek(enemyPointersBegin)
bank = 9
x = 0
y = 0
while rom.tell() < enemyDataBegin:
    temp = gb2hex(0x030000+romRead(2))
    enemyPointers.append( (temp, "enemyBank{:X}_{:X}{:X}".format(bank,y,x), bank) )
    x += 1
    if x == 0x10:
        x = 0
        y += 1
        if y == 0x10:
            y = 0
            bank += 1

#Write the enemyPointerTable with label names
i = 0
bank = 9
lastBank = 0
for d in enemyPointers:
    bank = d[2]
    if(bank != lastBank):
        print("\n\n; Enemy Data Pointers for Bank {:X}".format(bank), end="")
        
    if(i%16 == 0):
        print("\n    dw ", end="")
    else:
        print(", ", end="")
        
    lastBank = bank
    print(d[1], end="")
    i += 1
print("\n")    

# Read the enemy data
print("\n\n; Enemy Data for Banks 9-F")
rom.seek(enemyDataBegin)
enemy = 0
while rom.tell() < end:

    for d in enemyPointers:
        if rom.tell() == d[0]:
            print(d[1]+": db ", end="")
    
    number = romRead(1)
    while number != 0xFF:
        print("${:02X},".format(number), end="")
        
        type = romRead(1)
        print("${:02X},".format(type), end="")
        
        xPos = romRead(1)
        print("${:02X},".format(xPos), end="")
        
        yPos = romRead(1)
        print("${:02X}, ".format(yPos), end="")
        
        number = romRead(1)
        
    print("$FF")
    enemy += 1

# EoF