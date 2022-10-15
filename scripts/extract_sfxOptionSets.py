gb2hex = lambda x: x >> 2 & ~0x3FFF | x & 0x3FFF
hex2gb = lambda x: x << 2 & ~0xFFFF | x & 0x3FFF | 0x4000
longAddressString = lambda x: "{:X}:{:X}".format(x >> 16, x & 0xFFFF)
romRead = lambda n: sum([ord(rom.read(1)) << i*8 for i in range(n)])

rom = open("M2.gb", "rb")

def outputOptionSets():
    def outputToneSweepOptionSet(label):
        address = hex2gb(rom.tell())
        a = romRead(1)
        b = romRead(1)
        c = romRead(1)
        d = romRead(2)
        
        print(f'.{label} ; ${address & 0xFFFF:X}')
        
        if a >> 3 & 1 == 0:
            print(f'    AscendingSweepOptions {a & 7}, {a >> 4 & 7}')
        else:
            print(f'    DescendingSweepOptions {a & 7}, {a >> 4 & 7}')
            
        print(f'    LengthDutyOptions ${b & 0x3F:X}, {b >> 6 & 3}')
        if c >> 3 & 1 == 0:
            print(f'    DescendingEnvelopeOptions {c & 7}, ${c >> 4 & 0xF:X}')
        else:
            print(f'    AscendingEnvelopeOptions {c & 7}, ${c >> 4 & 0xF:X}')
        
        print(f'    FrequencyOptions ${d & 0x7FF:X}, {d >> 0xE & 1}')
        print('')
        
    def outputNoiseOptionSet(label):
        address = hex2gb(rom.tell())
        a = romRead(1)
        b = romRead(1)
        c = romRead(1)
        d = romRead(1)
        
        print(f'.{label} ; ${address & 0xFFFF:X}')
        
        print(f'    LengthOptions ${a & 0x3F:X}')
        if b >> 3 & 1 == 0:
            print(f'    DescendingEnvelopeOptions {b & 7}, ${b >> 4 & 0xF:X}')
        else:
            print(f'    AscendingEnvelopeOptions {b & 7}, ${b >> 4 & 0xF:X}')
        
        print(f'    PolynomialCounterOptions {c & 7}, {c >> 3 & 1}, ${c >> 4:X}')
        print(f'    CounterControlOptions {d >> 6 & 1}')
        print('')
        
    def outputToneOptionSet(label):
        address = hex2gb(rom.tell())
        a = romRead(1)
        b = romRead(1)
        c = romRead(2)
        
        print(f'.{label} ; ${address & 0xFFFF:X}')
        
        print(f'    LengthDutyOptions ${a & 0x3F:X}, {a >> 6 & 3}')
        if b >> 3 & 1 == 0:
            print(f'    DescendingEnvelopeOptions {b & 7}, ${b >> 4 & 0xF:X}')
        else:
            print(f'    AscendingEnvelopeOptions {b & 7}, ${b >> 4 & 0xF:X}')
        
        print(f'    FrequencyOptions ${c & 0x7FF:X}, {c >> 0xE & 1}')
        print('')
    
    def outputToneSweepOptionSets():
        labels = [
            'jumping_0',
            'jumping_1',
            'jumping_2',
            'jumping_3',
            'jumping_4',
            'jumping_5',
            'hijumping_0',
            'hijumping_1',
            'hijumping_2',
            'hijumping_3',
            'hijumping_4',
            'hijumping_5',
            'hijumping_6',
            'hijumping_7',
            'screwAttacking_0',
            'screwAttacking_1',
            'screwAttacking_2',
            'screwAttacking_3',
            'screwAttacking_4',
            'screwAttacking_5',
            'screwAttacking_6',
            'screwAttacking_7',
            'screwAttacking_8',
            'screwAttacking_9',
            'screwAttacking_A',
            'screwAttacking_B',
            'screwAttacking_C',
            'screwAttacking_D',
            'standingTransition_0',
            'standingTransition_1',
            'standingTransition_2',
            'crouchingTransition_0',
            'crouchingTransition_1',
            'crouchingTransition_2',
            'morphing_0',
            'morphing_1',
            'morphing_2',
            'shootingBeam_0',
            'shootingBeam_1',
            'shootingBeam_2',
            'shootingBeam_3',
            'shootingBeam_4',
            'shootingMissile_0',
            'shootingMissile_1',
            'shootingMissile_2',
            'shootingMissile_3',
            'shootingMissile_4',
            'shootingMissile_5',
            'shootingMissile_6',
            'shootingMissile_7',
            'shootingMissile_8',
            'shootingMissile_9',
            'shootingIceBeam',
            'shootingPlasmaBeam',
            'shootingSpazerBeam',
            'pickingUpMissileDrop_0',
            'pickingUpMissileDrop_1',
            'pickingUpMissileDrop_2',
            'pickingUpMissileDrop_3',
            'pickingUpMissileDrop_4',
            'spiderBall_0',
            'spiderBall_1',
            'pickedUpEnergyDrop_0',
            'pickedUpEnergyDrop_1',
            'pickedUpEnergyDrop_2',
            'pickedUpDropEnd',
            'shotMissileDoorWithBeam_0',
            'shotMissileDoorWithBeam_1',
            'unknown10_0',
            'unknown10_1',
            'unknown10_2',
            'unknown10_3',
            'unknown10_4',
            'unknown10_5',
            'unknown10_6',
            'unknown10_7',
            'unknown10_8',
            'unknown10_9',
            'unknown10_A',
            'unused12',
            'bombLaid',
            'unused14_0',
            'unused14_1',
            'optionMissileSelect_0',
            'optionMissileSelect_1',
            'shootingWaveBeam_0',
            'shootingWaveBeam_1',
            'shootingWaveBeam_2',
            'shootingWaveBeam_3',
            'shootingWaveBeam_4',
            'largeEnergyDrop_0',
            'largeEnergyDrop_1',
            'largeEnergyDrop_2',
            'largeEnergyDrop_3',
            'largeEnergyDrop_4',
            'samusHealthChanged_0',
            'samusHealthChanged_1',
            'noMissileDudShot_0',
            'noMissileDudShot_1',
            'unknown1A_0',
            'unknown1A_1',
            'unknown1A_2',
            'unknown1A_3',
            'unknown1A_4',
            'unknown1A_5',
            'unknown1A_6',
            'metroidCry',
            'saved0',
            'saved1',
            'saved2',
            'variaSuitTransformation',
            'unpaused_0',
            'unpaused_1',
            'unpaused_2',
            'exampleA',
            'exampleB',
            'exampleC',
            'exampleD',
            'exampleE'
        ]
        
        rom.seek(gb2hex(0x45A28))
        for label in labels:
            outputToneSweepOptionSet(label)
        
    def outputNoiseOptionSets():
        labels = [
            'enemyShot',
            'enemyKilled_0',
            'enemyKilled_1',
            'unknown3',
            'shotBlockDestroyed',
            'metroidHurt_0',
            'metroidHurt_1',
            'SamusHurt_0',
            'SamusHurt_1',
            'acidDamage_0',
            'shotMissileDoor_0',
            'shotMissileDoor_1',
            'metroidQueenCry_0',
            'metroidQueenCry_1',
            'metroidQueenHurtCry_0',
            'metroidQueenHurtCry_1',
            'samusKilled_1',
            'samusKilled_2',
            'samusKilled_3',
            'bombDetonated_0',
            'bombDetonated_1',
            'metroidKilled_0',
            'metroidKilled_1',
            'unknownE_0',
            'unknownE_1',
            'clearedSaveFile_0',
            'clearedSaveFile_1',
            'footsteps_0',
            'footsteps_1',
            'unknown11_0',
            'unknown_1',
            'unknown12_0',
            'unused13_0',
            'unknown14_0',
            'unknown14_1',
            'unknown15_0',
            'unknown15_1',
            'babyMetroidClearingBlock',
            'babyMetroidCry',
            'unknown18_0',
            'unknown18_1',
            'unused19',
            'unknown1A',
            'samusKilled_0'
        ]
        
        rom.seek(gb2hex(0x45C7B))
        for label in labels:
            outputNoiseOptionSet(label)
            
    def outputToneOptionSets():
        labels = [
            'metroidQueenCry',
            'babyMetroidClearingBlock',
            'babyMetroidCry',
            'metroidQueenHurtCry',
            'unknown7'
        ]
        
        rom.seek(gb2hex(0x45D2B))
        for label in labels:
            outputToneOptionSets(label)
    
    def outputPausedOptionSets():
        rom.seek(gb2hex(0x4487C))
        outputNoiseOptionSet('frame40')
        outputNoiseOptionSet('frame3D')
        outputToneSweepOptionSet('frame3F')
        outputToneSweepOptionSet('frame3A')
        outputNoiseOptionSet('frame32')
        outputToneSweepOptionSet('frame2F')
        outputNoiseOptionSet('frame27')
        outputToneSweepOptionSet('frame24')
        
    outputToneSweepOptionSets()
    outputToneOptionSets()
    outputNoiseOptionSets()
    outputPausedOptionSets()

def main():
    outputOptionSets()

main()
