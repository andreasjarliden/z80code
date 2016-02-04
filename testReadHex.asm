
#include "constants.asm"
.org 8000h
	ld de, promptString
	call BLOCKING_SEND
	call READ_HEX
	ld a, h
	call PRINT_HEX
	ld a, l
	call PRINT_HEX
	ld a, 0ah
	call PUT_CHAR
	ret

promptString: .string " > "
	.int8 0
