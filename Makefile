all: out/M2RoS.gb

#%.2bpp: %.png
#	rgbgfx -o $@ $<

#%.1bpp: %.png
#	rgbgfx -d 1 -o $@ $<

out/game.o: SRC/game.asm SRC/bank_*.asm out
	rgbasm  -L -o out/game.o -i SRC/ SRC/game.asm

out/M2RoS.gb: out/game.o out
	rgblink -n out/M2RoS.sym -m out/M2RoS.map -o $@ $<
	#rgbfix -v -p 255 $@ #Nope

	md5sum $@

out:
	mkdir $@

clean:
#	rm -f game.o game.gb game.sym game.map
#	find . \( -iname '*.1bpp' -o -iname '*.2bpp' \) -exec rm {} +
