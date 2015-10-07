ASMPATH=~/working/assembler/build
ASM=${ASMPATH}/asm
HEX2H=${ASMPATH}/hex2h

%.hex:%.asm
	(rm -f $@ && cpp -P $< | ${ASM} >$@)

%.h:%.hex
	${HEX2H} $< >$@

%.pp:%.asm
	cpp -P $< >$@

