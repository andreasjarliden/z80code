	; Output char A via SIO channel B
putChar:
putCharSIO:
	push af
	push bc
	ld b, a
	; Check D2 of RR0 for transmit buffer empty
pcSIO_loop:
	ld a, 00h
	out (SIO_B_CONTROL)
	in (SIO_B_CONTROL)
	and 04h
	jr z, pcSIO_loop
	; Write the next byte to the SIO
	ld a, b
	out (SIO_B_DATA)
	pop bc
	pop af
	ret

