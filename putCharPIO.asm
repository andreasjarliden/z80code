; Send byte A to PIO A
putCharPIO:
	push hl
	ld hl, pcPIO_didOutput
	ld (INTERRUPT_VECTOR_PIO_OUTPUT), hl
	out (PIO_A_DATA)
pcPIO_loop:
	halt
	jr pcPIO_loop ; Not PIO output interrupt, keep waiting
pcPIO_didOutput:
	inc sp
	inc sp
	pop hl
	ei
	reti

