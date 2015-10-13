#include "constants.asm"
	ld sp, STACK_ADDRESS
	ld a, INTERRUPT_TABLE_HIGH
	ld i, a
	call setupPio
	; Enable vectored interrupts
	im 2	; Interupt mode 2: vectored interrupts
	ei

	ld de, testString
loop:
	call blockingSend
	jp loop

testString: .string "Hello World"
	.int16 0

#include "setupPio.asm"
#include "blockingSend.asm"

