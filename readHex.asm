#include "constants.asm"
; Returns 16-bit hex value in HL
readHex:
	push af
	push bc
	push de
	ld hl, 0
rh_loop:
	call GET_CHAR
	call PUT_CHAR
	; \r is line ending on Mac, \n on Unix.
	; \r\n on Windows but ignore that!
	cp CARRIAGE_RETURN
	jr z, rh_done
	cp NEWLINE
	jr z, rh_done
	ld d, h
	ld e, l
	ld hl, digitsAscii
	ld bc, 22

	cpir

	ld hl, digitsValues
	add hl, bc
	ld a, (hl)
	ld h, d
	ld l, e
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	or l
	ld  l, a
	jr rh_loop
rh_done:
	pop de
	pop bc
	pop af
	ret
digitsAscii:
	.string "0123456789abcdefABCDEF"
digitsValues:
	.int8 0fh
	.int8 0eh
	.int8 0dh
	.int8 0ch
	.int8 0bh
	.int8 0ah
	.int8 0fh
	.int8 0eh
	.int8 0dh
	.int8 0ch
	.int8 0bh
	.int8 0ah
	.int8 9
	.int8 8
	.int8 7
	.int8 6
	.int8 5
	.int8 4
	.int8 3
	.int8 2
	.int8 1
	.int8 0
