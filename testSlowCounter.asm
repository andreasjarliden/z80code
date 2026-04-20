#include "constants.asm"
.org 8000h
	; Install interrupt handler for CTC1
	ld hl, counter1Int
	ld (INTERRUPT_VECTOR_COUNTER1), hl
	ld a, COUNTER1_INTERRUPT_NR
	out (CTC1)
	; RESET CTC1
	ld a, 03h
	out (CTC1)
	;ld de, starting_string
	;call BLOCKING_SEND

outerLoop:
  ld d, 50 ; outer loop counter

ctcLoop:
  ld a, 0
  ld (didTick), a
	; 7=1 enable interrupts, 6=0 TIMER mode, 5=1 256 PRESCALER,  4=1 POS EDGE
	; 3=0 AUTO Start, 2=1 TIME Constant follows, 1=0 Continue, 0 = 1
	; 1011 0101 = B5
	ld a, 0B5h
	out (CTC1)
	; Set counter to 255
	ld a, 255
	out (CTC1)
halt_loop:
	halt
  ld a, (didTick)
  cp 1
  jr nz, halt_loop

  dec d
  jr nz, ctcLoop

	ld de, tick_string
	call BLOCKING_SEND
	jr outerLoop

counter1Int:
  push af
  ld a, 1
  ld (didTick), a
  pop af
	ei
	reti
tick_string: .string "tick"
	.int8 0
didTick: .int8 0
starting_string: .string "Starting timer\n"
	.int8 0
