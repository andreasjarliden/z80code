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

