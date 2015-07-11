.eq PIO_A_DATA 00h
.eq PIO_B_DATA 01h
.eq PIO_A_CONTROL 02h
.eq PIO_B_CONTROL 03h
.eq PIO_COMMAND_SET_BIDIRECTIONAL_MODE 8fh
.eq PIO_COMMAND_SET_INPUT_MODE 4fh
.eq PIO_COMMAND_SET_OUTPUT_MODE 0fh
.eq PIO_COMMAND_SET_BIT_MODE 0cfh
.eq INTERRUPT_TABLE F000h
.eq INTERRUPT_VECTOR_0 0F000h
.eq INTERRUPT_VECTOR_2 0F002h
.eq INTERRUPT_VECTOR_4 0F004h
.eq INTERRUPT_TABLE_HIGH 0F0h ; High byte of INTERRUPT_TABLE address
.eq LOAD_ADDRESS 8000h

	; Set stack pointer
	ld sp, 0e000h

	; Set output mode for PIO B
	ld a, PIO_COMMAND_SET_OUTPUT_MODE
	out (PIO_B_CONTROL)

	; Set input mode for PIO A
	ld a, PIO_COMMAND_SET_INPUT_MODE
	out (PIO_A_CONTROL)
;
	; Set interrupt vector 2
	ld a, 2
	out (PIO_A_CONTROL)
;
	; Enable interrupts PIO A
	ld a, 83h
	out (PIO_A_CONTROL)
;
	ld hl, inputInt
	ld (INTERRUPT_VECTOR_2), hl
;
	ld a, INTERRUPT_TABLE_HIGH
	ld i, a
	im 2	; Interupt mode 2: vectored interrupts
	ei
;
	; Read from PIO_A_DATA to activate ARDY to signal that we are ready to read
	in (PIO_A_DATA)
loop:
	halt
	jr loop
;
;;.org 0020h
inputInt:
	in (PIO_A_DATA)
	out (PIO_B_DATA)
	ei
	reti
;
