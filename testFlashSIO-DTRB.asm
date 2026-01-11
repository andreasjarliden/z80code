#include "constants.asm"
.org 8000h
  ld b, 0
loop:
  ld a, 03h
  out (SIO_B_CONTROL)
  ld a, b
  out (SIO_B_CONTROL)

  ld a, 03h
  out (SIO_B_CONTROL)
  in (SIO_B_CONTROL);
  call PRINT_HEX

  ld a, b
  add a, 1
  ld b, a
  call PRINT_HEX
  jr loop
