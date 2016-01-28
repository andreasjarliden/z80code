; Send byte A to terminal
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

