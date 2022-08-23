# Script by Alex W
# Thanks to PJ for the lambda functions

# Tool for extracting chr data into a binary file

gb2hex = lambda gb: gb >> 2 & ~0x3FFF | gb & 0x3FFF
hex2gb = lambda hex: hex << 2 & ~0xFFFF | hex & 0x3FFF | 0x4000
romRead = lambda n: sum([ord(rom.read(1)) << i*8 for i in range(n)])
readLongPointer = lambda: (romRead(1) << 16) | romRead(2)

def write_chr(entry):
    rom.seek(gb2hex(entry[0]))
    chr = rom.read(entry[2])
    with open("../out/chr/"+entry[1]+".chr", "wb") as f:
        f.write(chr)

gfx_list = [
            [0x055f34, "titleScreen"    ,0xA00],
            [0x056934, "creditsFont"    ,0x300],
            [0x056c34, "itemFont"       ,0x200],
            [0x056e34, "creditsNumbers" ,0x100],
            [0x056f34, "creditsSprTiles",0xF00],
            [0x057e34, "theEnd"         ,0x100],
            
            [0x064000, "cannonBeam"          ,0x20 ],
            [0x064020, "cannonMissile"       ,0x20 ],
            [0x064040, "beamIce"             ,0x20 ],
            [0x064060, "beamWave"            ,0x20 ],
            [0x064080, "beamSpazerPlasma"    ,0x20 ],
            [0x0640a0, "spinSpaceTop"        ,0x70 ],
            [0x064110, "spinSpaceBottom"     ,0x50 ],
            [0x064160, "spinScrewTop"        ,0x70 ],
            [0x0641d0, "spinScrewBottom"     ,0x50 ],
            [0x064220, "spinSpaceScrewTop"   ,0x70 ],
            [0x064290, "spinSpaceScrewBottom",0x50 ],
            [0x0642e0, "springBallTop"       ,0x20 ],
            [0x064300, "springBallBottom"    ,0x20 ],
            [0x064320, "samusPowerSuit"      ,0xB00],
            [0x064e20, "samusVariaSuit"      ,0xB00],
            [0x065920, "enemiesA"            ,0x400],
            [0x065d20, "enemiesB"            ,0x400],
            [0x066120, "enemiesC"            ,0x400],
            [0x066520, "enemiesD"            ,0x400],
            [0x066920, "enemiesE"            ,0x400],
            [0x066d20, "enemiesF"            ,0x400],
            [0x067120, "arachnus"            ,0x400],
            [0x067520, "surfaceSPR"          ,0x400],
            
            [0x074000, "plantBubbles", 0x800],
            [0x074800, "ruinsInside",  0x800],
            [0x075000, "queenBG",      0x800],
            [0x075800, "caveFirst",    0x800],
            [0x076000, "surfaceBG",    0x800],
            [0x076800, "lavaCavesA",   0x530],
            [0x076d30, "lavaCavesB",   0x530],
            [0x077260, "lavaCavesC",   0x530],
            [0x077790, "items",        0x2C0  ],
            [0x077a50, "itemOrb",      0x40   ],
            [0x077a90, "commonItems",  0x100  ],
            
            [0x0859bc, "metAlpha", 0x400],
            [0x085dbc, "metGamma", 0x400],
            [0x0861bc, "metZeta",  0x400],
            [0x0865bc, "metOmega", 0x400],
            [0x0869bc, "ruinsExt", 0x800],
            [0x0871bc, "finalLab", 0x800],
            [0x0879bc, "queenSPR", 0x500],
           ]

rom = open("../Metroid2.gb", "rb")

for thing in gfx_list:
    write_chr(thing)
    
# EoF