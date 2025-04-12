# Script by Alex W

import argparse
import csv

autoWarning = '; This file was automatically generated from samus.csv. Please edit that file instead of this one.\n'

def csv2asm(infile, outdir):
    # All of these strings must correlate to column headings
    # Words
    wordLists = [ 'poseJumpTable', 
                  'drawJumpTable'
                ]
    # Bytes
    byteLists = [ 'bombPoseTransitionTable', 
                  'bombedFallingPoseTransitionTable', 
                  'damagePoseTransitionTable', 
                  'bgHitboxTop', 
                  'spriteHitboxTopTable', 
                  'blockReformHeightTable', 
                  'cannonYOffsetByPose', 
                  'possibleShotDirections'
                ]
    # Horizontal Collision Y-Offsets
    offsetLists = [ 'horizontalYOffsetA', 
                    'horizontalYOffsetB',
                    'horizontalYOffsetC',
                    'horizontalYOffsetD',
                    'horizontalYOffsetE',
                    'horizontalYOffsetF',
                    'horizontalYOffsetG',
                    'horizontalYOffsetH']

    # Open File
    f = open(infile)
    csvReader = csv.DictReader(f)
    
    # Initialize Tables
    poseComments = []
    poseConstants = []
    for wordType in wordLists:
        locals()[wordType] = []
    for byteType in byteLists:
        locals()[byteType] = []
    for offsetType in offsetLists:
        locals()[offsetType] = []
    
    # Read Rows
    for row in csvReader:
        poseComments.append(row['poseComments'])
        poseConstants.append(row['poseConstants'])
        for wordType in wordLists:
            locals()[wordType].append(row[wordType])
        for byteType in byteLists:
            locals()[byteType].append(row[byteType])
        for offsetType in offsetLists:
            locals()[offsetType].append(row[offsetType])
    
    # Transpose Y Offset Lists
    offsetListsList = []
    for oneList in offsetLists:
        offsetListsList.append(locals()[oneList])
    transposedOffsets = [[row[i] for row in offsetListsList] for i in range(len(offsetListsList[0]))]
    
    # Write Lists to Separate ASM files
    writeConstantsToAsm(outdir, poseConstants, 'poseConstants', poseComments)
    for wordType in wordLists:
        writeWordTableToAsm(outdir, locals()[wordType], wordType, poseComments)
    for byteType in byteLists:
        writeByteTableToAsm(outdir, locals()[byteType], byteType, poseComments)
    writeOffsetTableToAsm(outdir, transposedOffsets, 'horizontalYOffsets', poseComments)


def writeConstantsToAsm(outdir, table, fileName, comments):
    outFile = open(outdir+'/samus_'+fileName+'.asm', 'w')
    outFile.write(autoWarning)
    
    i = 0
    for item in table:
        if (item != ''):
            outFile.write('def '+item+' = ${:02X} ; '.format(i)+comments[i]+'\n')
        i += 1
    
    outFile.close()

def writeWordTableToAsm(outdir, table, fileName, comments):
    outFile = open(outdir+'/samus_'+fileName+'.asm', 'w')
    outFile.write(autoWarning)
    
    i = 0
    for item in table:
        if (item != ''):
            outFile.write('    dw '+item+' ; ${:02X} - '.format(i)+comments[i]+'\n')
        i += 1
    
    outFile.close()

def writeByteTableToAsm(outdir, table, fileName, comments):
    outFile = open(outdir+'/samus_'+fileName+'.asm', 'w')
    outFile.write(autoWarning)
    
    i = 0
    for item in table:
        if (item != ''):
            outFile.write('    db '+item+' ; ${:02X} - '.format(i)+comments[i]+'\n')
        i += 1
    
    outFile.close()

def writeOffsetTableToAsm(outdir, table, fileName, comments):
    outFile = open(outdir+'/samus_'+fileName+'.asm', 'w')
    outFile.write(autoWarning)
    
    i = 0
    for row in table:
        outFile.write('    db '+', '.join(row)+' ; ${:02X} - '.format(i)+comments[i]+'\n')
        i += 1
    
    outFile.close()

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('-i','--infile', default='samus.csv', help='Input CSV file')
    ap.add_argument('-o','--outdir', default='.', help='Output directory for the asm files')
    args = ap.parse_args()

    csv2asm(args.infile, args.outdir)

if __name__ == "__main__":
    main()
