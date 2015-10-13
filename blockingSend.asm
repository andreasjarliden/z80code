#include "constants.asm"

; DE non-empty zero terminated message to send
blockingSend:
	push af
	push de
	push hl
	; install output interrupt handler
	ld hl, didOutput
	ld (INTERRUPT_VECTOR_PIO_OUTPUT), hl
	ld a, (de)
	or a
	out (PIO_A_DATA)
bs_wait:
	halt
	jr nz, bs_wait
	pop hl
	pop de
	pop af
	ret
didOutput:
	inc de
	ld a, (de)
	or a
; TODO does not work on empty string?
	jr z, done 
	out (PIO_A_DATA)
done:
	; TODO restore INTERRUPT_VECTOR_PIO_OUTPUT
	ei
	reti
