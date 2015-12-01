#include "constants.asm"
	jr init
	jp blockingSend
	jp getChar
	jp putChar
	jp printHex
init:
	ld sp, STACK_ADDRESS
	ld a, INTERRUPT_TABLE_HIGH
	ld i, a
	call setupPio
	ld a, 03h		; Disable interrupts PIO B (Actually bidir input on port A)
	out (PIO_B_CONTROL)
	; Enable vectored interrupts
	im 2	; Interupt mode 2: vectored interrupts
	ei

	ld de, waitingSizeString
	call blockingSend
	call getChar
	ld c, a
	call getChar
	ld b, a
	ld de, sizeString
	call blockingSend
	ld a, b
	call printHex
	ld a, c
	call printHex
	ld a, 10h
	call putChar

	ld de, LOAD_ADDRESS
load_loop:
	call getChar
	call printHex
	ld (de), a
	inc de
	dec bc
	ld a,b
	or c
	jr nz, load_loop
	ld de, loadedString
	call blockingSend
	jp LOAD_ADDRESS

waitingSizeString: .string "Waiting for size"
	.int16 0
sizeString: .string "Size "
	.int16 0
loadedString: .string "Loaded OK"
	.int16 0

#include "setupPio.asm"
#include "blockingSend.asm"

; Blocking read of a character from PIO A returned in register A.
getChar:
	push af
	push hl
	ld hl, getChar_cont
	ld (INTERRUPT_VECTOR_PIO_INPUT), hl
	ld a, 83h		; Enable interrupts PIO B (Actually bidir input on port A)
	out (PIO_B_CONTROL)

getChar_loop:
	halt
	jr getChar_loop ; Not PIO input interrupt, keep waiting
getChar_cont:
	ld a, 03h		; Disable interrupts PIO B (Actually bidir input on port A)
	out (PIO_B_CONTROL)
	inc sp		; Pop the return address for the interrupt handler
	inc sp          ; since we want to return the the caller of getChar instead
	pop hl
	pop af
	in (PIO_A_DATA)
	ei
	reti


putChar:
	push hl
	ld hl, pc_didOutput
	ld (INTERRUPT_VECTOR_PIO_OUTPUT), hl
	out (PIO_A_DATA)
pc_loop:
	halt
	jr pc_loop ; Not PIO output interrupt, keep waiting
pc_didOutput:
	inc sp
	inc sp
	pop hl
	ei
	reti
	
; Print hex byte in A
printHex:
	push af
	push bc
	push de
	push hl
	ld d, a			; backup in d
	ld c, a
	ld b, 0
	srl c
	srl c
	srl c
	srl c
	ld hl, printHex_table
	add hl, bc
	ld a, (hl)
	call putChar
	ld a, d
	and 0fh
	ld c, a
	ld hl, printHex_table
	add hl, bc
	ld a, (hl)
	call putChar
	pop hl
	pop de
	pop bc
	pop af
	ret
printHex_table:
	.string "0123456789ABCDEF"

