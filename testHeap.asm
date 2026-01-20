#include "constants.asm"
.org 8000h

  ld bc, 42
  call malloc

  ld a, 'c'
  call PUT_CHAR
  push hl
  call printHex16
  pop hl

  ld a, 'd'
  call PUT_CHAR

  push hl
  pop ix
  ld b, (ix - 1)
  ld c, (ix - 2)
  push bc
  call printHex16
  pop bc

  ld bc, 42
  call malloc

  ld a, 'e'
  call PUT_CHAR
  push hl
  call printHex16
  pop hl

  ret

; HL = malloc(BC size in bytes)
malloc:
  push af
  push bc
  push de
  push ix
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
  ; HL = heapBlock->start
  ld h, (ix+1)
  ld l, (ix+0)

  ld a, 'a'
  call PUT_CHAR
  push hl
  call printHex16
  pop hl

  ; Write the size at heapBlock->start, add two bytes and return

  ld a, 'b'
  call PUT_CHAR
  push bc
  call printHex16
  pop bc

  ld (hl), c
  inc hl
  ld (hl), b
  inc hl

  jr malloc_ret
malloc_failed:
  ld hl, 0
malloc_ret:
  pop ix
  pop de
  pop bc
  pop af
	ret

; print 16bit hex value on stac
printHex16:
  push ix
  ld ix, 0
  add ix, sp
  push af
  ld a, (ix + 5)
  call PRINT_HEX
  ld a, (ix + 4)
  call PRINT_HEX
  pop af
  pop ix
  ret

returnedStr:
  .string "Returned block "
  .int8 0

firstHeapBlock: 
	.int16 0A000h ; start
  .int16 0100h ; size
  .int16 0000h ; next
