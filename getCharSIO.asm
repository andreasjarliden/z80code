; Reads char from SIO B (blocking) and returns in A
getChar:
getCharSIO:
	; Wait for Receive Char Available bit D0 in RR0 to be set
gcSIO_loop:
	ld a, 00h
	out (SIO_B_CONTROL)
	in (SIO_B_CONTROL)
	and 01h
	jr z, gcSIO_loop
	; Read char from SIO channel B
	in (SIO_B_DATA)
	ret



