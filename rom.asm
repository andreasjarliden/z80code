#include "constants.asm"
	jr init

; Jump table for ROM functions
	jp blockingSend
	jp getChar
	jp putChar
	jp printHex
	jp readHex

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


	ld de, mainMenu
menu:
	call callFromMenu
	jr menu

printMainMenuHelp:
	push de
	ld de, helpString
	call blockingSend
	pop de
	ret

load:
	push af
	push bc
	push de
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
	ld a, 0ah
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
	pop de
	pop bc
	pop af
	ret

waitingSizeString: .string "Waiting for size... "
	.int8 0
sizeString: .string "Size "
	.int8 0
loadedString: .string "Loaded OK\n"
	.int8 0
syntaxErrorString: .string "Syntax Error\n"
	.int8 0
promptString: .string "> "
	.int8 0
helpString: .string "h - help\nl - load\nr - run\n"
	.int8 0
mainMenu:
	.int8 'h'
	.int16 printMainMenuHelp
	.int8 'l'
	.int16 load
	.int8 'r'
	.int16 LOAD_ADDRESS
	.int8 0		; 0 terminated

#include "setupPio.asm"
#include "blockingSend.asm"
#include "getChar.asm"
#include "putChar.asm"
#include "printHex.asm"
#include "readHex.asm"
#include "callFromMenu.asm"

