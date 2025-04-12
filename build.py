import os
import subprocess
import hashlib

def run_or_exit(args, err):
    completed_process = subprocess.run(args, shell=True)
    if completed_process.returncode != 0:
        print("\n" + err + "\n")
        exit(completed_process.returncode)


if not os.path.exists('out/'):
    os.mkdir('out/')
    
print('Running scripts')
run_or_exit("python ./scripts/enemy_csv2asm.py -i ./SRC/data/enemies.csv -o ./SRC/data", "Script Error.")
run_or_exit("python ./scripts/samus_csv2asm.py -i ./SRC/samus/samus.csv -o ./SRC/samus", "Script Error.")
print('Success\n')

completed_process = subprocess.run("rgbasm -V", shell=True)
if completed_process.returncode != 0:
    print("RGBDS not detected. Downloading...")
    run_or_exit("curl -LJO \"https://github.com/gbdev/rgbds/releases/download/v0.9.0/rgbds-0.9.0-win32.zip\"", "Failed to download.")
    run_or_exit("tar -xvf rgbds-0.9.0-win32.zip", "Failed to extract RGBDS archive.")
    run_or_exit("rgbasm -V", "Unable to use downloaded RGBDS.")

print('RGBDS detected')
print('Assembling .asm files')
run_or_exit("rgbasm --preserve-ld -o out/game.o -I SRC/ SRC/game.asm", "Assembler Error.") # Use if compiling the original
#run_or_exit("rgbasm -o out/game.o -I SRC/ SRC/game.asm", "Assembler Error.") # Use if making a mod
print('Success\n')

print('Linking .o files')
run_or_exit("rgblink -n out/M2RoS.sym -m out/M2RoS.map -o out/M2RoS.gb out/game.o", "Linker Error.")
print('Success\n')

print('Fixing header')
run_or_exit("rgbfix -v out/M2RoS.gb", "RGBFIX Error.")
print('Done\n')

with open("out/M2RoS.gb", "rb") as f:
    md5_hash_generated = hashlib.md5(f.read())
print('MD5 hash: ' + md5_hash_generated.hexdigest())

try:
    with open("Metroid2.gb", "rb") as f:
        md5_hash_expected = hashlib.md5(f.read())
    if md5_hash_generated.hexdigest() == md5_hash_expected.hexdigest():
        print("Hash matches vanilla ROM.")
    else:
        print("Hash does not match vanilla ROM.")
except FileNotFoundError:
    print("Could not check hash against vanilla ROM.")
