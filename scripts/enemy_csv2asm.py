# Script by Alex W

import argparse
import csv

def csv2asm(infile, outdir):
    spriteFile = open(outdir+'/enemy_spritePointers.asm', 'w')
    headerFile = open(outdir+'/enemy_headerPointers.asm', 'w')
    hitboxFile = open(outdir+'/enemy_hitboxPointers.asm', 'w')
    damageFile = open(outdir+'/enemy_damageValues.asm', 'w')
    constFile = open(outdir+'/enemy_nameConstants.asm', 'w')

    spriteFile.write('; This file was automatically generated from enemies.csv. Please do not edit this directly.\n')
    headerFile.write('; This file was automatically generated from enemies.csv. Please do not edit this directly.\n')
    hitboxFile.write('; This file was automatically generated from enemies.csv. Please do not edit this directly.\n')
    damageFile.write('; This file was automatically generated from enemies.csv. Please do not edit this directly.\n')
    constFile.write('; This file was automatically generated from enemies.csv. Please do not edit this directly.\n')

    with open(infile, newline='') as f:
        i = 0
        reader = csv.reader(f)
        for row in reader:
            spriteFile.write('    dw '+row[0]+' ; '+row[6]+'\n')
            headerFile.write('    dw '+row[1]+' ; '+row[6]+'\n')
            hitboxFile.write('    dw '+row[2]+' ; '+row[6]+'\n')
            damageFile.write('    db '+row[3]+' ; '+row[6]+'\n')
            if row[4] != '':
                constFile.write('def '+row[4]+' = ${:02X} ; '.format(i)+row[6]+'\n')
            if row[5] != '':
                constFile.write('def '+row[5]+' = ${:02X} ; '.format(i)+row[6]+'\n')
            i += 1


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('-i','--infile', default='enemies.csv', help='Input CSV file')
    ap.add_argument('-o','--outdir', default='.', help='Output directory for the asm files')
    args = ap.parse_args()

    csv2asm(args.infile, args.outdir)


if __name__ == "__main__":
    main()
