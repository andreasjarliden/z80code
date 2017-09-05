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
	; 7=0 enable interrupts, 6=0 TIMER mode, 5=0 16 PRESCALER,  4=1 POS EDGE
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
	ld de, tick_string
	call BLOCKING_SEND

	; Reset ext/status interrupts, Async mode, Parity, Stop bits
	ld a, 14h
	out (SIO_B_CONTROL)
	; x1 clock External sync, No parity, 1 stop bit,
	; 0000 0100
	ld a, 04h
	out (SIO_B_CONTROL)

	; WR3: 11 8 bits, 0 No Auto Enable, 0000, 0 disable Rx: 1100 0000
	ld a, 03h
	out (SIO_B_CONTROL)
	ld a, 0c0h
	out (SIO_B_CONTROL)

	; WR5: 0 DTR active, 11 8 bits, 0 no break, 1 Tx Enable, 0, 0 RTS, 0
	; 1110 1010
	ld a, 05h
	out (SIO_B_CONTROL)
	ld a, 068h
	out (SIO_B_CONTROL)

	; WR1, Reset External/Status Interrupts
	; Rx INT Enable, Enable External interrupts
	ld a, 11h
	out (SIO_B_CONTROL)
	ld a, 03h
	out (SIO_B_CONTROL)

	ld de, starting_string
	call BLOCKING_SEND

	; Transmit first byte to SIO
sioLoop:
	ld a, 'H'
	out (SIO_B_DATA)
	halt
	;ld de, tick_string
	;call BLOCKING_SEND
	jr sioLoop
	out (SIO_B_DATA)
	out (SIO_B_DATA)
	out (SIO_B_DATA)
	out (SIO_B_DATA)
	out (SIO_B_DATA)
	out (SIO_B_DATA)
	out (SIO_B_DATA)
	halt
	ld de, tick_string
	call BLOCKING_SEND
	ld a, 'b'
	out (SIO_B_DATA)
	jr sioLoop


counter0Int:
	ei
	reti
sioInt:
	ld a, 28h ; 0010 1000
	out (SIO_B_DATA)
	ei
	reti
tick_string: .string "tick"
	.int8 0
starting_string: .string "Starting output"
	.int8 0
