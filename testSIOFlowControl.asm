; Receive ring buffer
; Writing to HEAD
; Reading from TAIL
; HEAD == TAIL means empty

#include "constants.asm"
.org 8000h
  jp flowControl
#include "ringBuffer.asm"

flowControl:
  ld ix, SIO_RX_RING_BUFFER
  ld a, 0ffh
  call ringBufferPush
  ld a, 0
  call ringBufferPop
  call PRINT_HEX

	; RESET CTC0
	ld a, 03h
	out (CTC0)

	; Generate 9600 Hz from 4 MHz clock. 4M/(16*26)~=9615 Hz
	; 7=0 disable interrupts, 6=0 TIMER mode, 5=0 16 PRESCALER,  4=1 POS EDGE
	; 3=0 AUTO Start, 2=1 TIME Constant follows, 1=0 Continue, 0 = 1
	; 1001 0101 = B5
	ld a, 015h
	out (CTC0)
	; Following time constant: set counter to 26
	ld a, 26
	out (CTC0)

	;
	; Setup SIO Channel B
	;
	ld hl, sioBOutputBufferEmptyInt
	ld (INTERRUPT_VECTOR_SIO_B_OUTPUT_BUFFER_EMPTY), hl
	ld hl, sioBStatusChangeInt
	ld (INTERRUPT_VECTOR_SIO_B_STATUS_CHANGE), hl
	ld hl, sioBReceiveCharAvailableInt
	ld (INTERRUPT_VECTOR_SIO_B_RECEIVE_CHAR_AVAILABLE), hl
	ld hl, sioBSpecialReceiveConditionInt
	ld (INTERRUPT_VECTOR_SIO_B_SPECIAL_RECEIVE_CONDITION), hl

	; Channel reset WR0
	; 0001 1000
	ld a, 18h
	out (SIO_B_CONTROL)

	; Write interrupt vector to WR2
	ld a, 02h
	out (SIO_B_CONTROL)
	ld a, SIO_INTERRUPT_NR
	out (SIO_B_CONTROL)

	; Reset ext/status interrupts, Async mode, Parity, Stop bits
	ld a, 14h
	out (SIO_B_CONTROL)
	; x1 clock External sync, No parity, 1 stop bit,
	; 0000 0100
	ld a, 04h
	out (SIO_B_CONTROL)

	; WR1, Reset External/Status Interrupts
	; D7=0 Wait/Ready functions disabled
	; D4D3=10 Interrupt on all chars (par. err is a Special Receive Condition)
	; D2=1 Status affects vector enabled
	; D1=1 Transmit interrupt enable, D0=1 External Interrupts enable
	ld a, 11h
	out (SIO_B_CONTROL)
	ld a, 17h
	out (SIO_B_CONTROL)

	; WR3: 11 8 bits, 1 Auto Enable, 0000, 1 enable Rx: 1110 0001
	ld a, 03h
	out (SIO_B_CONTROL)
	ld a, 0e1h
	out (SIO_B_CONTROL)

	; WR5: 0 DTR active, 11 8 bits, 0 no break, 1 Tx Enable, 0, 1 RTS, 0
	; 1110 1010
	ld a, 05h
	out (SIO_B_CONTROL)
	ld a, 06Ah
	out (SIO_B_CONTROL)

	; WR0=1100 0000, Reset Tx underrun
	ld a, 0C0h
	out (SIO_B_CONTROL)

  ;
  ; Make a slow timer with about 1Hz
  ;

	; Install interrupt handler for CTC1
	ld hl, counter1Int
	ld (INTERRUPT_VECTOR_COUNTER1), hl
	ld a, COUNTER1_INTERRUPT_NR
	out (CTC1)
	; RESET CTC1
	ld a, 03h
	out (CTC1)

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

  ld ix, SIO_RX_RING_BUFFER
loop:
  ld a, (ix + RING_BUFFER_HEAD)
  ld b, a
  ld a, (ix + RING_BUFFER_TAIL)
  cp b
  jr z, loop

  call ringBufferPop
  ; Output received character
	out (SIO_B_DATA)

	jr outerLoop

rtsOn:
  ; enable RTS
	; WR5: 0 DTR active, 11 8 bits, 0 no break, 1 Tx Enable, 0, 1 RTS, 0
	; 1110 1010
  push af
	ld a, 05h
	out (SIO_B_CONTROL)
	ld a, 06Ah
	out (SIO_B_CONTROL)
  pop af
  ret

rtsOff:
  ; Disable RTS
	; WR5: 0 DTR active, 11 8 bits, 0 no break, 1 Tx Enable, 0, 0 RTS, 0
	; 1110 1010
  push af
	ld a, 05h
	out (SIO_B_CONTROL)
	ld a, 068h
	out (SIO_B_CONTROL)
  pop af
  ret

counter1Int:
  push af
  ld a, 1
  ld (didTick), a
  pop af
  ei
  reti

sioInt:
sioBOutputBufferEmptyInt:
  push af
  ; Reset Tx int pending, otherwise the interrupt happens directly again
  ; WR1= 00 (Null CRC reset), 101 (Reset Tx int pending ), 000 (register 0)
  ; 0011 1000, 28h
  ld a, 028h
  out (SIO_B_CONTROL)
  pop af
  ei
  reti

sioBStatusChangeInt:
  push af
  ; Reset External/Status Interrupts, otherwise the interupt happens directly again
  ; WR0= 00 (Null CRC reset), 010 (Reset Tx int pending ), 000 (register 0)
  ; 0001 0000, 10h
  ld a, 010h
  out (SIO_B_CONTROL)
  pop af
  ei
  reti

sioBReceiveCharAvailableInt:
  push af
  push ix

  ; Read received character
  in (SIO_B_DATA)

  ; Push to ring buffer
  ld ix, SIO_RX_RING_BUFFER
  call ringBufferPush

  pop ix
  pop af
  ei
  reti

sioBSpecialReceiveConditionInt:
  push af

  ; Error Reset, otherwise the interupt happens directly again
  ; WR0= 00 (Null CRC reset), 110 (Reset Error), 000 (register 0)
  ; 0011 0000, 30h
  ld a, 30h
  out (SIO_B_CONTROL)

  pop af
  ei
  reti

  starting_string: .string "<start>"
  .int8 0
  error_string: .string "<error>"
  .int8 0
  rtsOn_string: .string "RTS=ON"
  .int8 0
  rtsOff_string: .string "RTS=OFF"
  .int8 0
  didTick: .int8 0
  SIO_B_OUTPUT_FULL: .int8 0ffh


  SIO_RX_RING_BUFFER:
  .int16 09000h ; PTR
  .int8 0 ; HEAD
  .int8 0 ; TAIL
  .int8 0 ; Current SIZE
  .int8 63 ; MASK
  .int8 24 ; LOWWATER
  .int8 48 ; HIGHWATER
  .int16 rtsOn ; LOWWATER CALLBACK
  .int16 rtsOff ; HIGHWATER CALLBACK

