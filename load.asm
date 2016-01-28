#include "constants.asm"
.org 8000h
	ld de, hello_world_string
	call BLOCKING_SEND
	ret
hello_world_string: .string "Hello World!!\n\n"
	.int8 0
