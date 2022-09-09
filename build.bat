@echo off
if not exist out mkdir out

echo. Assembling .asm files
rgbasm --preserve-ld -o out/game.o -i SRC/ SRC/game.asm
if errorlevel 1 goto errorASM
echo.  Success
echo.
echo. Linking .o files
rgblink -n out/M2RoS.sym -m out/M2RoS.map -o out/M2RoS.gb out/game.o
if errorlevel 1 goto errorLINK
echo.  Success
echo. 
certutil -hashfile out/M2RoS.gb MD5
echo.
fc /b Metroid2.gb out\M2RoS.gb
goto done

:errorASM
echo.
echo. Assembler Error.
echo.
goto done
:errorLINK
echo.
echo. Linker Error.
echo.

:done