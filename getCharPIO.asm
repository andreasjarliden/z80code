; Blocking read of a character from PIO A returned in register A.
getCharPIO:
	push af
	push hl
	ld hl, getCharPIO_cont
	ld (INTERRUPT_VECTOR_PIO_INPUT), hl
	ld a, 83h		; Enable interrupts PIO B (Actually bidir input on port A)
	out (PIO_B_CONTROL)

getCharPIO_loop:
	halt
	jr getCharPIO_loop ; Not PIO input interrupt, keep waiting
getCharPIO_cont:
	ld a, 03h		; Disable interrupts PIO B (Actually bidir input on port A)
	out (PIO_B_CONTROL)
	inc sp		; Pop the return address for the interrupt handler
	inc sp          ; since we want to return the the caller of getChar instead
	pop hl
	pop af
	in (PIO_A_DATA)
	ei
	reti
