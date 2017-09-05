#include "constants.asm"
.org 8000h
	; Install interrupt handler for CTC0
	ld hl, counter0Int
	ld (INTERRUPT_VECTOR_COUNTER0), hl
	ld a, COUNTER0_INTERRUPT_NR
	out (CTC0)
	; RESET CTC0
	ld a, 03h
	out (CTC0)
	;ld de, starting_string
	;call BLOCKING_SEND
ctcLoop:
	; 7=1 enable interrupts, 6=0 TIMER mode, 5=1 256 PRESCALER,  4=1 POS EDGE
	; 3=0 AUTO Start, 2=1 TIME Constant follows, 1=0 Continue, 0 = 1
	; 1011 0101 = B5
	ld a, 0B5h
	out (CTC0)
	; Set counter to 255
	ld a, 25
	out (CTC0)
	halt
	ld de, tick_string
	call BLOCKING_SEND
	jr ctcLoop

counter0Int:
	ei
	reti
tick_string: .string "tick"
	.int8 0
starting_string: .string "Starting timer\n"
	.int8 0
