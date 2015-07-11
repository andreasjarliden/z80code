ASMPATH=~/working/assembler/build
ASM=${ASMPATH}/asm
HEX2H=${ASMPATH}/hex2h

%.hex:%.asm
	${ASM} $< >$@

%.h:%.hex
	${HEX2H} $< >$@
