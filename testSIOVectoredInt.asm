#include "constants.asm"
.org 8000h
	; Install interrupt handler for CTC0
	ld hl, counter0Int
	ld (INTERRUPT_VECTOR_COUNTER0), hl
	ld a, COUNTER0_INTERRUPT_NR
	out (CTC0)
	; RESET CTC0
	ld a, 03h
	out (CTC0)

	; Generate 9600 Hz from 4 MHz clock. 4M/(16*26)~=9615 Hz
	; 7=0 disable interrupts, 6=0 TIMER mode, 5=0 16 PRESCALER,  4=1 POS EDGE
	; 3=0 AUTO Start, 2=1 TIME Constant follows, 1=0 Continue, 0 = 1
	; 1001 0101 = B5
	ld a, 015h
	out (CTC0)
	; Following time constant: set counter to 26
	ld a, 26
	out (CTC0)

	;
	; Setup SIO Channel B
	;
	ld hl, sioInt
	ld (INTERRUPT_VECTOR_SIO), hl

	; Channel reset WR0
	; 0001 1000
	ld a, 18h
	out (SIO_B_CONTROL)

	; Write interrupt vector to WR2
	ld a, 02h
	out (SIO_B_CONTROL)
	ld a, SIO_INTERRUPT_NR
	out (SIO_B_CONTROL)

	; Try reading back RR2
	ld a, 02h
	out (SIO_B_CONTROL)
	in (SIO_B_CONTROL)
	call PRINT_HEX

	; Reset ext/status interrupts, Async mode, Parity, Stop bits
	ld a, 14h
	out (SIO_B_CONTROL)
	; x1 clock External sync, No parity, 1 stop bit,
	; 0000 0100
	ld a, 04h
	out (SIO_B_CONTROL)

	; WR3: 11 8 bits, 1 No Auto Enable, 0000, 1 disable Rx: 1100 0000
	ld a, 03h
	out (SIO_B_CONTROL)
	ld a, 0e1h
	out (SIO_B_CONTROL)

	; WR5: 0 DTR active, 11 8 bits, 0 no break, 1 Tx Enable, 0, 0 RTS, 0
	; 1110 1010
	ld a, 05h
	out (SIO_B_CONTROL)
	ld a, 068h
	out (SIO_B_CONTROL)


	; WR1, Reset External/Status Interrupts
	; D1=1 Transmit interrupt enable, D0=1 External Interrupts enable
	;ld a, 11h
	;out (SIO_B_CONTROL)
	;ld a, 01h
	;out (SIO_B_CONTROL)
	ld a, 11h
	out (SIO_B_CONTROL)
	ld a, 02h
	out (SIO_B_CONTROL)

	ld de, starting_string
	call BLOCKING_SEND

	; Transmit first byte to SIO
	ld hl, output_string
loop:
	ld a, (hl)
	or a
	jr z, end
	inc hl
	out (SIO_B_DATA)
	ld a, 0
	ld (status_rr0), a
wait:
	halt
	ld a, (status_rr0)
	; Check D2 of RR0 for transmit buffer empty
;	ld a, 00h
;	out (SIO_B_CONTROL)
;	in (SIO_B_CONTROL)
	and 04h
	jr z, wait
	jr loop
end:
	ret

counter0Int:
	ei
	reti
sioInt:
	push af
	ld a, 00h
	out (SIO_B_CONTROL)
	in (SIO_B_CONTROL)
	ld (status_rr0), a
	pop af
	ei
	reti
tick_string: .string "tick"
	.int8 0
starting_string: .string "Starting output"
	.int8 0
output_string: .string "Hello World!"
	.int8 0
status_rr0: .int8 0
