#include "constants.asm"
.org 8000h

  ld bc, 42
  call malloc
  ld de, returnedStr
  call BLOCKING_SEND
  ld b, h
  ld c, l
  call printHex16
  ld a, 10h
  call PUT_CHAR
  push hl
  pop ix
  ld h, (ix - 1)
  ld l, (ix - 2)
  ld b, h
  ld c, l
  call printHex16
  ret

; hl = malloc(BC bytes)
; BC size
malloc:
  push af
  push bc
  push de
  push ix
  push hl
  ld ix, firstHeapBlock ; ix is heapBlock pointer
malloc_loop:
  ; de = heapBlock->size
  ld d, (ix+3)
  ld e, (ix+2)

  ; Is heapBlock large enough?
  ld h, b             ; hl = size 
  ld l, c
  ; hl (size) < de (block size)
  or a ; clear carry
  sbc hl, de
  jr c, malloc_fits

  ; No, heapBlock = heapBlock->next
  ld h, (ix+5)
  ld l, (ix+4)
  ; hl (heapBlock->next is 0?)
  ld a, h
  or l
  jr Z, malloc_failed; yes, jump to failed
  ; no, ix = heapBlock->next
  push hl
  pop ix

  ; repeat
  jr malloc_loop

malloc_fits:
  ; Write the size at heapBlock->start
  ld (ix+0), c
  ld (ix+1), b
  push ix
  pop ix
  ; Add 2 bytes and return that pointer
  inc hl
  inc hl
  jr malloc_ret

malloc_failed:
  ld ix, 0
malloc_ret:
  pop hl
  pop ix
  pop de
  pop bc
  pop af
	ret

; print hex value in bc
printHex16:
  push af
  ld a, b
  call PRINT_HEX
  ld a, c
  call PRINT_HEX
  pop af
  ret

returnedStr:
  .string "Returned block "
  .int8 0

firstHeapBlock: 
	.int16 0A00h ; start
  .int16 0100h ; size
  .int16 0000h ; next
