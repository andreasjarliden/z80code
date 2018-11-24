#include "constants.asm"
	jr init

; Jump table for ROM functions
	jp blockingSend
	jp getCharPIO
	jp putCharPIO
	jp printHex
	jp readHex
	jp getCharSIO
	jp putCharSIO

init:
	ld sp, STACK_ADDRESS
	ld a, INTERRUPT_TABLE_HIGH
	ld i, a
	call setupPio
	ld a, 03h		; Disable interrupts PIO B (Actually bidir input on port A)
	out (PIO_B_CONTROL)
	call setupSio
	; Enable vectored interrupts
	im 2	; Interupt mode 2: vectored interrupts
	ei


	ld hl, mainMenu
menu:
	call callFromMenu
	jr menu

printMainMenuHelp:
	push de
	ld de, helpString
	call blockingSend
	pop de
	ret

load8000:
	push hl
	ld hl, LOAD_ADDRESS
	call load
	pop hl
	ret

loadAnyAddress:
	ld de, askAddress_string
	call blockingSend
	call readHex
	call load
	ret

runAnyAddress:
	push de
	ld de, askAddress_string
	call blockingSend
	call readHex
	pop de
	jp (hl)	; the RET in the function at HL returns

; hl - load address
load:
	push af
	push bc
	push de
	push hl
	ld de, waitingSizeString
	call blockingSend
	call getChar
	ld c, a
	call getChar
	ld b, a
	ex de, hl
load_loop:
	call getChar
	ld (de), a
	inc de
	dec bc
	ld a,b
	or c
	jr nz, load_loop
	ld de, loadedString
	call blockingSend
	pop hl
	pop de
	pop bc
	pop af
	ret

askAddress_string: .string "Base address (hex): "
	.int8 0
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
helpString: .string "h - help\nl - load to 8000h\nm - load any address\nr - run\nt - run any address\n"
	.int8 0
mainMenu:
	.int8 'h'
	.int16 printMainMenuHelp
	.int8 'l'
	.int16 load8000
	.int8 'm'
	.int16 loadAnyAddress
	.int8 'r'
	.int16 LOAD_ADDRESS
	.int8 't'
	.int16 runAnyAddress
	.int8 0		; 0 terminated

#include "setupPio.asm"
#include "setupSio.asm"
#include "blockingSend.asm"
#include "getCharPIO.asm"
#include "putCharPIO.asm"
#include "getCharSIO.asm"
#include "putCharSIO.asm"
#include "printHex.asm"
#include "readHex.asm"
#include "callFromMenu.asm"

