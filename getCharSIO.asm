; Reads char from SIO B (blocking) and returns in A
getCharSIO:
  push ix
  ld ix, SIO_RX_RING_BUFFER
getCharSIO_loop:
  call ringBufferIsEmpty
  jr nz, getCharSIO_charAvailable
  halt
  jr getCharSIO_loop

getCharSIO_charAvailable:
  call ringBufferPop
  pop ix
  ret
