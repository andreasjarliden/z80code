; hl - pointer to menu struct
callFromMenu:
	push af
	push bc
	push de
	push hl
	ld de, menu_prompt
	call BLOCKING_SEND
	call GET_CHAR
	ld c, a			; c - entered char
cfm_loop:
	ld b, (hl)
	ld a, 0
	cp b
	jr z, cfm_syntaxError
	ld a, c
	cp b
	inc hl
	jr z, cfm_found
	inc hl
	inc hl
	jr cfm_loop
cfm_found:
	ld de, cfm_return
	push de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl
	jp (hl)
cfm_syntaxError:
	ld de, syntaxError_string
	call BLOCKING_SEND
cfm_return:
	pop hl
	pop de
	pop bc
	pop af
	ret


syntaxError_string:
	.string "Invalid entry\n"
	.int8 0
menu_prompt:
	.string "---> "
	.int8 0
found_string:
	.string "found!\n"
	.int8 0
call1_string:
	.string "Entered 1\n"
	.int8 0
callA_string:
	.string "Entered a\n"
	.int8 0

