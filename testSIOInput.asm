
#include "constants.asm"
.org 8000h
	;
	; Setup SIO Channel B for Async IO 9600 8N1
	;

	; Channel reset WR0
	; 0001 1000
	ld a, 18h
	out (SIO_B_CONTROL)

	; WR4: Async mode, Parity, Stop bits
	ld a, 04h
	out (SIO_B_CONTROL)
	; x1 clock External sync, No parity, 1 stop bit,
	; 0000 0100
	ld a, 04h
	out (SIO_B_CONTROL)

	; WR3: 11 8 bits, 1 Auto Enable, 0000, 1 enable Rx: 1110 0001
	ld a, 03h
	out (SIO_B_CONTROL)
	ld a, 0e1h
	;ld a, 0c0h
	ld a, 0c1h
	out (SIO_B_CONTROL)

	; WR5: 0 DTR active, 11 8 bits, 0 no break, 1 Tx Enable, 0, 0 RTS, 0
	; 1110 1010
	ld a, 05h
	out (SIO_B_CONTROL)
	ld a, 068h
	out (SIO_B_CONTROL)

	; WR1
	; D7=0 Wait/Ready disabled
	; D3, D4=0, 0  Recieve interrupts disabled
	; D2=0 Status affects vector disabled
	; D1=0 Transmit interrupt disable, D0=0 External Interrupts disable
	ld a, 01h
	out (SIO_B_CONTROL)
	ld a, 00h
	out (SIO_B_CONTROL)

	; WR1 Channel A
	; D1=0 Transmit interrupt disable, D0=0 External Interrupts disable
	ld a, 01h
	out (SIO_A_CONTROL)
	ld a, 00h
	out (SIO_A_CONTROL)


	; WR5: 1 DTR active, 11 8 bits, 0 no break, 1 Tx Enable, 0, 0 RTS, 0
	; 1110 1000
	; Wait for Receive Char Available bit D0 in RR0 to be set
	ld a, 05h
	out (SIO_B_CONTROL)
	ld a, 0e8h
	out (SIO_B_CONTROL)

	; WR3: 11 8 bits, 1 Auto Enable, 0000, 1 enable Rx: 1110 0001
	ld a, 03h
;	out (SIO_B_CONTROL)
	;ld a, 0e1h
	ld a, 0e1h
;	out (SIO_B_CONTROL)

loop:
	;ld a, 20h
	;out PUT_CHAR
	ld a, 00h
	out (SIO_B_CONTROL)
	in (SIO_B_CONTROL)
	;call PRINT_HEX
	and 01h
	jr z, loop
	; Read char from SIO channel B
	in (SIO_B_DATA)
	call PUT_CHAR
	jr loop
	ret

