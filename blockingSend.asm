#include "constants.asm"

; DE non-empty zero terminated message to send
blockingSend:
	push af
	push de
bs_loop:
	ld a, (de)
	or a
	jr z, bs_end
	call PUT_CHAR
	inc de
	jr bs_loop
bs_end:
	pop de
	pop af
	ret
