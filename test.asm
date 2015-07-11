	; Send 11xx (mode 3) | 1111 (set mode) to PIO Control A (IO addr 02h)
	ld a, 0ffh
	out (02h)	; TODO .EQ PIO_CTR_A 02; out(PIO_CTR_A)
	; Follow the set mode command with 00h to PIO Control A to configure all 8 bits as outputs
	ld a, 00h
	out (02h)
loop:
	; Send FFh to PIO Data A
	ld a, 0ffh
	out (00h)
	; Send 00h to PIO Data A
	ld a, 00h
	out (00h)
	jp loop		; TODO would like to do jp loop
