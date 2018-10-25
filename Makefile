ASMPATH=~/working/assembler/build
ASM=${ASMPATH}/asm
HEX2H=${ASMPATH}/hex2h
HEX2I8HEX=${ASMPATH}/hex2i8hex
HEX2BIN=${ASMPATH}/hex2bin

%.hex:%.asm
	(rm -f $@ && cpp -P $< | ${ASM} -o $@)

%.h:%.hex
	${HEX2H} $< >$@

%.pp:%.asm
	cpp -P $< $@

%.i8hex:%.hex
	${HEX2I8HEX} $< >$@

%.bin:%.hex
	${HEX2BIN} $< >/tmp/program.bin && ./filesizeToBin.sh /tmp/program.bin >/tmp/size.bin && cat /tmp/size.bin /tmp/program.bin >$@

testPrintString.hex:testPrintString.asm constants.asm setupPio.asm blockingSend.asm

rom.hex: rom.asm constants.asm setupPio.asm setupSio.asm blockingSend.asm getCharPIO.asm putCharPIO.asm getCharSIO.asm putCharSIO.asm printHex.asm readHex.asm callFromMenu.asm

