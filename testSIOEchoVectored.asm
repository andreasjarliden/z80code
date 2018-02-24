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
	ld hl, sioBOutputBufferEmptyInt
	ld (INTERRUPT_VECTOR_SIO_B_OUTPUT_BUFFER_EMPTY), hl
	ld hl, sioBStatusChangeInt
	ld (INTERRUPT_VECTOR_SIO_B_STATUS_CHANGE), hl
	ld hl, sioBReceiveCharAvailableInt
	ld (INTERRUPT_VECTOR_SIO_B_RECEIVE_CHAR_AVAILABLE), hl
	ld hl, sioBSpecialReceiveConditionInt
	ld (INTERRUPT_VECTOR_SIO_B_SPECIAL_RECEIVE_CONDITION), hl

start:
	; Channel reset WR0
	; 0001 1000
	ld a, 18h
	out (SIO_B_CONTROL)

	; Write interrupt vector to WR2
	ld a, 02h
	out (SIO_B_CONTROL)
	ld a, SIO_INTERRUPT_NR
	out (SIO_B_CONTROL)

	; Reset ext/status interrupts, Async mode, Parity, Stop bits
	ld a, 14h
	out (SIO_B_CONTROL)
	; x1 clock External sync, No parity, 1 stop bit,
	; 0000 0100
	ld a, 04h
	out (SIO_B_CONTROL)

	; WR5: 0 DTR active, 11 8 bits, 0 no break, 1 Tx Enable, 0, 0 RTS, 0
	; 1110 1010
	ld a, 05h
	out (SIO_B_CONTROL)
	ld a, 068h
	out (SIO_B_CONTROL)

	; WR1, Reset External/Status Interrupts
	; D7=0 Wait/Ready functions disabled
	; D4D3=10 Interrupt on all chars (par. err is a Special Receive Condition)
	; D2=1 Status affects vector enabled
	; D1=1 Transmit interrupt enable, D0=1 External Interrupts enable
	ld a, 11h
	out (SIO_B_CONTROL)
	ld a, 17h
	out (SIO_B_CONTROL)

	; WR3: 11 8 bits, 1 No Auto Enable, 0000, 1 enable Rx: 1110 0001
	ld a, 03h
	out (SIO_B_CONTROL)
	ld a, 0e1h
	ld a, 0c1h
	out (SIO_B_CONTROL)

	; WR0=1100 0000, Reset Tx underrun
	ld a, 0C0h
	out (SIO_B_CONTROL)

	ld de, starting_string
	call BLOCKING_SEND

loop:
	halt
	ld a, (ERROR)
	or a
	jr z, loop
	ld de, error_string
	call BLOCKING_SEND
	jr loop

counter0Int:
	ei
	reti
sioInt:
sioBOutputBufferEmptyInt:
	push af
	ld a, 0
	ld (SIO_B_OUTPUT_FULL), a
	pop af
	ei
	reti
sioBStatusChangeInt:
	push af
	ld a, 1
	ld (ERROR), a
	pop af
	ei
	reti
sioBReceiveCharAvailableInt:
	push af
	; No real buffering, just output it back again
	in (SIO_B_DATA)
	out (SIO_B_DATA)
	pop af
	ei
	reti
sioBSpecialReceiveConditionInt:
	push af
	ld a, 1
	ld (ERROR), a
	pop af
	ei
	reti
starting_string: .string "<start>"
	.int8 0
error_string: .string "<error>"
	.int8 0
ERROR: .int8 0
SIO_B_OUTPUT_FULL: .int8 0
