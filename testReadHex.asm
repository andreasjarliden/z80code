
#include "constants.asm"
.org 8000h
	ld de, promptString
	call BLOCKING_SEND
	call readHex
	ld a, h
	call PRINT_HEX
	ld a, l
	call PRINT_HEX
	ld a, 0ah
	call PUT_CHAR
	jp 8000h

#include "readHex.asm"
promptString: .string " > "
	.int8 0
