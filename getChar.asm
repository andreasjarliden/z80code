#include "constants.asm"
; Blocking read of a character from PIO A returned in register A.
getChar:
	push af
	push hl
	ld hl, getChar_cont
	ld (INTERRUPT_VECTOR_PIO_INPUT), hl
	ld a, 83h		; Enable interrupts PIO B (Actually bidir input on port A)
	out (PIO_B_CONTROL)

getChar_loop:
	halt
	jr getChar_loop ; Not PIO input interrupt, keep waiting
getChar_cont:
	ld a, 03h		; Disable interrupts PIO B (Actually bidir input on port A)
	out (PIO_B_CONTROL)
	inc sp		; Pop the return address for the interrupt handler
	inc sp          ; since we want to return the the caller of getChar instead
	pop hl
	pop af
	in (PIO_A_DATA)
	ei
	reti


putChar:
	push hl
	ld hl, pc_didOutput
	ld (INTERRUPT_VECTOR_PIO_OUTPUT), hl
	out (PIO_A_DATA)
pc_loop:
	halt
	jr pc_loop ; Not PIO output interrupt, keep waiting
pc_didOutput:
	inc sp
	inc sp
	pop hl
	ei
	reti
	
