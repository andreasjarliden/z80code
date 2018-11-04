#include "constants.asm"

; Sets SIO B in Async IO mode 9600 8N1
; Interrupts NOT setup
setupSio:
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
	; Setup SIO Channel B for Async IO 9600 8N1
	;

	; Channel reset WR0
	; 0001 1000
	ld a, 18h
	out (SIO_B_CONTROL)

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
	; D1=0 Transmit interrupt disable, D0=0 External Interrupts disable
	ld a, 11h
	out (SIO_B_CONTROL)
	ld a, 00h
	out (SIO_B_CONTROL)

	ret

