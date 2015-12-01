#include "constants.asm"
.org 8000h
	ld de, hello_world_string
	call BLOCKING_SEND
loop:
	halt
	jr loop
hello_world_string: .string "Hello World!"
	.int16 0
