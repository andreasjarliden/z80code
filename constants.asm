#pragma once
; PIO
.eq PIO_A_DATA 00h
.eq PIO_B_DATA 01h
.eq PIO_A_CONTROL 02h
.eq PIO_B_CONTROL 03h
.eq PIO_COMMAND_SET_BIDIRECTIONAL_MODE 8fh
.eq PIO_COMMAND_SET_BIT_MODE 0cfh

; CTC
.eq CTC0 10h
.eq CTC1 11h
.eq CTC2 12h
.eq CTC3 13h

;
; Memory
;
.eq LOAD_ADDRESS 8000h
.eq STACK_ADDRESS 0ffffh
.eq INTERRUPT_TABLE 0F000h
.eq INTERRUPT_TABLE_HIGH 0F0h ; High byte of INTERRUPT_TABLE address
.eq INTERRUPT_VECTOR_0 0F000h
.eq INTERRUPT_VECTOR_2 0F002h
.eq INTERRUPT_VECTOR_4 0F004h

.eq SEND_BUFFER_START 0F100h
.eq SEND_BUFFER_END 0F1FFh

;
; Interrupts
;
.eq PIO_OUTPUT_INTERRUPT_NR 02h
.eq PIO_INPUT_INTERRUPT_NR 04h
.eq COUNTER0_INTERRUPT_NR 08h
.eq COUNTER1_INTERRUPT_NR 0Ah
.eq COUNTER2_INTERRUPT_NR 0Ch
.eq COUNTER3_INTERRUPT_NR 0Eh
.eq INTERRUPT_VECTOR_PIO_OUTPUT 0F002h
.eq INTERRUPT_VECTOR_PIO_INPUT 0F004h
.eq INTERRUPT_VECTOR_COUNTER0 0F008h
.eq INTERRUPT_VECTOR_COUNTER1 0F00Ah
.eq INTERRUPT_VECTOR_COUNTER2 0F00Ch
.eq INTERRUPT_VECTOR_COUNTER3 0F00Eh

;
; ROM functions
;
.eq BLOCKING_SEND 0002h
.eq GET_CHAR 0005h
.eq PUT_CHAR 0008h
.eq PRINT_HEX 000Bh
.eq READ_HEX 000Dh
