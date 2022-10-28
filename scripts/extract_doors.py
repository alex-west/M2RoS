# Script adapted from:
#  http://patrickjohnston.org/ASM/ROM%20data/RoS/print%20update%20commands.py

gb2hex = lambda gb: gb >> 2 & ~0x3FFF | gb & 0x3FFF
hex2gb = lambda hex: hex << 2 & ~0xFFFF | hex & 0x3FFF | 0x4000
romRead = lambda n: sum([ord(rom.read(1)) << i*8 for i in range(n)])
readLongPointer = lambda: (romRead(1) << 16) | romRead(2)

pointerDict = { #Source Pointers (GB Bank Format)
                0x065920: "gfx_enemiesA",
                0x065D20: "gfx_enemiesB",
                0x066120: "gfx_enemiesC",
                0x066520: "gfx_enemiesD",
                0x066920: "gfx_enemiesE",
                0x066D20: "gfx_enemiesF",
                0x067120: "gfx_arachnus",
                0x067520: "gfx_surfaceSPR",
                0x074000: "gfx_plantBubbles",
                0x074800: "gfx_ruinsInside",
                0x075000: "gfx_queenBG",
                0x075800: "gfx_caveFirst",
                0x076000: "gfx_surfaceBG",
                0x076800: "gfx_lavaCavesA",
                0x076D30: "gfx_lavaCavesB",
                0x077260: "gfx_lavaCavesC",
                0x077A90: "gfx_commonItems",
                0x084000: "bg_queenHead.row1",
                0x084020: "bg_queenHead.row2",
                0x084040: "bg_queenHead.row3",
                0x084060: "bg_queenHead.row4",
                0x0859BC: "gfx_metAlpha",
                0x085DBC: "gfx_metGamma",
                0x0861BC: "gfx_metZeta",
                0x0865BC: "gfx_metOmega",
                0x0869BC: "gfx_ruinsExt",
                0x0871BC: "gfx_finalLab",
                0x0879BC: "gfx_queenSPR",
                
                # Destination Pointers
                0x8B00: "vramDest_enemies",
                0x8F00: "vramDest_commonItems",
                0x9C00: "_SCRN1",
                0x9C20: "(_SCRN1+$20)",
                0x9C40: "(_SCRN1+$40)",
                0x9C60: "(_SCRN1+$60)"
                }

rom = open("../Metroid2.gb", "rb")
doorPointersBegin = gb2hex(0x0542E5)
doorDataBegin = gb2hex(0x0546E5)
end = gb2hex(0x0555A3)
freespace = gb2hex(0x057F34)

doorPointers = []
#Read doors and give each a name
rom.seek(doorPointersBegin)
i = 0
while rom.tell() < doorDataBegin:
    temp = gb2hex(0x050000+romRead(2))
    doorPointers.append( (temp, "door{:03X}".format(i)) )
    i += 1

#Write the doorPointerTable with label names
i = 0
#print("    dw ", end="")
for d in doorPointers:
    if(i%16 == 0):
        print("\n    dw ", end="")
    else:
        print(", ", end="")

    if d[0] == freespace:
        print("bank5_freespace", end="")
    else:
        print(d[1], end="")
    i += 1
print("\n")    

#Read the transition data
srcPointerSet = set([])
destPointerSet = set([])

rom.seek(doorDataBegin)
door = 0
while rom.tell() < end:
    #print("ROM{:X}:{:X}              dx ".format(hex2gb(rom.tell()) >> 16, hex2gb(rom.tell()) & 0xFFFF), end="")
    #print("DoorNum{:03X}:".format(door))
    for d in doorPointers:
        if rom.tell() == d[0]:
            print(d[1]+":")
    
    type = romRead(1)
    while type != 0xFF:
        if type >> 4 == 0x0:
            srcPointer = readLongPointer()
            srcPointerSet.add(srcPointer)
            
            destPointer = romRead(2)
            destPointerSet.add(destPointer)
            
            moveLength = romRead(2)
            if type == 0x01:
                print("    COPY_BG {0}, {1}, ${2:04X}".format(pointerDict[srcPointer], pointerDict[destPointer], moveLength))
                #print("    COPY_BG {0:06X}, {1:04X}, {2:04X}".format(srcPointer, destPointer, moveLength))
            elif type == 0x02:
                print("    COPY_SPR {0}, {1}, ${2:04X}".format(pointerDict[srcPointer], pointerDict[destPointer], moveLength))
                #print("    COPY_SPR {0:06X}, {1:04X}, {2:04X}".format(srcPointer, destPointer, moveLength))
            else:
                print("    COPY_DATA {0}, {1}, ${2:04X}".format(pointerDict[srcPointer], pointerDict[destPointer], moveLength))
                #print("    COPY_DATA {0:06X}, {1:04X}, {2:04X}".format(srcPointer, destPointer, moveLength))
            #print("    BLOCK_COPY {0:02X},{1:02X}:{3:02X}{2:02X},{5:02X}{4:02X},{7:02X}{6:02X}".format(type, ord(rom.read(1)), ord(rom.read(1)), ord(rom.read(1)), ord(rom.read(1)), ord(rom.read(1)), ord(rom.read(1)), ord(rom.read(1))))
            
        elif type >> 4 == 0x1:
            tiletable = type&0x0F
            print("    TILETABLE ${:X}".format(tiletable))
            
        elif type >> 4 == 0x2:
            collisionTable = type&0x0F
            print("    COLLISION ${:X}".format(collisionTable))
            
        elif type >> 4 == 0x3:
            solidityTable = type&0x0F
            print("    SOLIDITY ${:X}".format(solidityTable))
            
        elif type >> 4 == 0x4:
            warpBank = type&0x0F
            temp = romRead(1)
            warpY = temp >> 4
            warpX = temp&0x0F
            #print("    WARP {:X}, {:X},{:X}".format(warpBank, warpY, warpX))
            print("    WARP ${:X}, ${:X}".format(warpBank, temp))
            
        elif type >> 4 == 0x5:
            print("    ESCAPE_QUEEN")
            
        elif type >> 4 == 0x6:
            damageAcid = romRead(1)
            damageSpike = romRead(1)
            print("    DAMAGE ${:02X}, ${:02X}".format(damageAcid, damageSpike))
            
        elif type >> 4 == 0x7:
            print("    EXIT_QUEEN")
            
        elif type >> 4 == 0x8:
            enterBank = type&0x0F
            scrollY = romRead(2)
            scrollX = romRead(2)
            samusY = romRead(2)
            samusX = romRead(2)
            print("    ENTER_QUEEN ${0:X}, ${1:04X}, ${2:04X}, ${3:04X}, ${4:04X}".format(enterBank, scrollY, scrollX, samusY, samusX))
            
        elif type >> 4 == 0x9:
            metNum = romRead(1)
            transIndex = romRead(2)
            print("    IF_MET_LESS ${0:02X}, ${1:04X}".format(metNum, transIndex))
            
        elif type >> 4 == 0xA:
            print("    FADEOUT")
            
        elif type >> 4 == 0xB:
            srcPointer = readLongPointer()
            srcPointerSet.add(srcPointer)
            
            if type == 0xB1:
                print("    LOAD_BG {:}".format(pointerDict[srcPointer]))
                #print("    LOAD_BG {0:06X}".format(srcPointer))
            elif type == 0xB2:
                print("    LOAD_SPR {:}".format(pointerDict[srcPointer]))
                #print("    LOAD_SPR {0:06X}".format(srcPointer))
            else:
                print("    UNKNOWN_LOAD {:}".format(pointerDict[srcPointer]))
        
        elif type >> 4 == 0xC:
            songIndex = type&0x0F
            print("    SONG ${:X}".format(songIndex))
            
        elif type >> 4 == 0xD:
            itemIndex = type&0x0F
            print("    ITEM ${:X}".format(itemIndex))
            
        elif type >> 4 == 0xE:
            print("    INVALID ${:X}".format(type))
        type = ord(rom.read(1))
    print("    END_DOOR\n")
    door += 1

for d in doorPointers:
    if rom.tell() == d[0]:
        print(d[1]+":")

'''
print("Source Pointers:")
for ptr in srcPointerSet:
    print("{:06X}".format( gb2hex(ptr) ))
print("Destination Pointers:")
for ptr in destPointerSet:
    print("{:04X}".format(ptr))
'''