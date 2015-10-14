#include "constants.asm"


; Sets PIO A in bidirectional mode, B in bit mode
; The input interrupt is set to PIO_INPUT_INTERRUPT_NR and the output to
; PIO_OUTPUT_INTERRUPT_NR (according to the current I register.)
setupPio:
	ld a, PIO_COMMAND_SET_BIDIRECTIONAL_MODE
	out (PIO_A_CONTROL)

	; Interrupt vector 2 for Output (PIO A)
	ld a, PIO_OUTPUT_INTERRUPT_NR
	out (PIO_A_CONTROL)

	; Interrupt vector 4 for Input (PIO B)
	ld a, PIO_INPUT_INTERRUPT_NR
	out (PIO_B_CONTROL)

	ld a, 83h		; Enable interrupts PIO A (Actually bidir output on port A)
	out (PIO_A_CONTROL)

	ld a, 83h		; Enable interrupts PIO B (Actually bidir input on port A)
	out (PIO_B_CONTROL)

	; Install inputInt and outputInt in interrupt table
	ld hl, inputInt
	ld (INTERRUPT_VECTOR_PIO_INPUT), hl
	;ld hl, outputInt
	;ld (INTERRUPT_VECTOR_PIO_OUTPUT), hl

	; TODO Bug in this bloc? Perhaps it must already be in BIT_MODE as suggested by Per. User Guide.
	ld a, 0e7h		; Enable int, HIGH, AND, No Mask follows
	;out (PIO_B_CONTROL)
;	ld a, 0ffh		; Mask all bits
;	out (PIO_B_CONTROL)

	; Set PIO B in bit mode
	ld a, PIO_COMMAND_SET_BIT_MODE	; Send 11xx (mode 3) | 1111 (set mode) to PIO Control A (IO addr 02h)
	out (PIO_B_CONTROL)
	ld a, 00h		; Next byte to PIO configures Input/Output. Set as all outputs.
	out (PIO_B_CONTROL)

	; Read from PIO_A_DATA to activate BRDY to signal that we are ready to read
	in (PIO_A_DATA)
	ret

inputInt:
	push af
	in (PIO_A_DATA)
	out (PIO_A_DATA)
	pop af
	ei
	reti

