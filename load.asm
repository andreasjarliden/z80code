.eq PIO_B_DATA 01h
	ld a, 42h
	out (PIO_B_DATA)
loop:
	jr loop
