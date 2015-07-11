myString: .string "apa apa"
	.int16 loop
.eq PIO_A_DATA 00h
.eq PIO_A_CONTROL 02h
.eq PIO_B_CONTROL 03h
.eq PIO_COMMAND_SET_BIDIRECTIONAL_MODE 8fh
.eq PIO_COMMAND_SET_BIT_MODE 0cfh
.eq INTERRUPT_TABLE F000h
.eq INTERRUPT_VECTOR_0 0F000h
.eq INTERRUPT_VECTOR_2 0F002h
.eq INTERRUPT_VECTOR_4 0F004h
.eq INTERRUPT_TABLE_HIGH 0F0h ; High byte of INTERRUPT_TABLE address
.eq LOAD_ADDRESS 8000h

	ld a, PIO_COMMAND_SET_BIDIRECTIONAL_MODE
	out (PIO_A_CONTROL)

	; Interrupt vector 4 for Input (PIO B)
	ld a, 4
	out (PIO_B_CONTROL)

	ld a, 83h		; Enable interrupts PIO B (Actually bidir input on port A)
	out (PIO_B_CONTROL)

	; Install inputInt for interupt 4
	ld hl, inputInt	;
	ld (INTERRUPT_VECTOR_4), hl

	; TODO Bug in this bloc?
	ld a, 0e7h		; Enable int, HIGH, AND, No Mask follows
	;out (PIO_B_CONTROL)
;	ld a, 0ffh		; Mask all bits
;	out (PIO_B_CONTROL)

	; Set PIO B in bit mode
	ld a, PIO_COMMAND_SET_BIT_MODE	; Send 11xx (mode 3) | 1111 (set mode) to PIO Control A (IO addr 02h)
	out (PIO_B_CONTROL)
	ld a, 00h		; Next byte to PIO configures Input/Output. Set as all outputs.
	out (PIO_B_CONTROL)

	; Enable vectored interrupts
	ld a, INTERRUPT_TABLE_HIGH
	ld i, a
	im 2	; Interupt mode 2: vectored interrupts
	ei

	; Read from PIO_A_DATA to activate BRDY to signal that we are ready to read
	in (PIO_A_DATA)
loop:
	halt
	jr loop

; TODO: This needs to be absolute or determined at runtime!
inputInt:
	in (PIO_A_DATA)
	out (PIO_A_DATA)
	ei
	reti

outputInt:
	; TODO on output
	ei
	reti
