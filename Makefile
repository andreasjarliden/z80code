ASMPATH=~/working/assembler/build
ASM=${ASMPATH}/asm
HEX2H=${ASMPATH}/hex2h
HEX2I8HEX=${ASMPATH}/hex2i8hex

%.hex:%.asm
	(rm -f $@ && cpp -P $< | ${ASM} -o $@)

%.h:%.hex
	${HEX2H} $< >$@

%.pp:%.asm
	cpp -P $< $@

%.i8hex:%.hex
	${HEX2I8HEX} $< >$@

testPrintString.hex:testPrintString.asm constants.asm setupPio.asm blockingSend.asm

