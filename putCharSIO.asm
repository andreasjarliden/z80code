; Output char A via SIO channel B and ring buffer
putCharSIO:
  push af
  push bc
  push de
  push ix

  ld b, a
  ld ix, SIO_TX_RING_BUFFER
putCharSIO_loop:
  call ringBufferIsFull
  jr nz, putCharSIO_1
  halt
  jr putCharSIO_loop

putCharSIO_1:
  ; Disable interrupts. Otherwise we might conclude there are characters
  ; waiting, but the tx buffer becomes empty before we can add the new
  ; character
  di 
  call ringBufferIsEmpty
  jr nz, putCharSIO_notEmpty

  ; Ring buffer is empty. If the transmitter is free as well, output the
  ; character directly.  Otherwise put it in the buffer
  ld a, 0 ; Check Read Register 0
  out (SIO_B_CONTROL)
  in (SIO_B_CONTROL)
  and 4 ; Bit 2 is Transmit Buffer Empty
  jr z, putCharSIO_notEmpty

  ld a, b
  out (SIO_B_DATA)
  jr putCharSIO_exit

putCharSIO_notEmpty:
  ld a, b
  call ringBufferPush
putCharSIO_exit:
  ei
  pop ix
  pop de
  pop bc
  pop af
  ret

