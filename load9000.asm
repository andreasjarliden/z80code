#include "constants.asm"
.org 9000h
	ld de, hello_world_string
	call BLOCKING_SEND
	ret
hello_world_string: .string "Hello World from 0x9000!!\n\n"
	.int8 0
