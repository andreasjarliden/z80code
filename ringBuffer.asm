.eq RING_BUFFER_PTR_LO 0
.eq RING_BUFFER_PTR_HI 1
.eq RING_BUFFER_HEAD 2
.eq RING_BUFFER_TAIL 3
.eq RING_BUFFER_SIZE 4
.eq RING_BUFFER_MASK 5
.eq RING_BUFFER_LOWWATER 6
.eq RING_BUFFER_HIGHWATER 7
.eq RING_BUFFER_LOWWATER_CALLBACK_LO 8
.eq RING_BUFFER_LOWWATER_CALLBACK_HI 9
.eq RING_BUFFER_HIGHWATER_CALLBACK_LO 10
.eq RING_BUFFER_HIGHWATER_CALLBACK_HI 11

; A - Character to push
; IX - pointer to ring buffer struct
ringBufferPush:
  push af
  push bc
  push hl
  ; Add received char at HEAD
  ld h, (IX+RING_BUFFER_PTR_HI)
  ld l, (IX+RING_BUFFER_PTR_LO)
  ld b, 0
  ld c, (IX+RING_BUFFER_HEAD) ; C = HEAD
  add hl, bc
  ld (hl), a

  ; Increase HEAD
  inc c
  ; HEAD=HEAD % MAX_SIZE
  ld a, (IX+RING_BUFFER_MASK)
  and c
  ; Store HEAD
  ld (IX+RING_BUFFER_HEAD), a

  ; Increase size
  inc (IX+RING_BUFFER_SIZE)

  ld a, (IX+RING_BUFFER_HIGHWATER)
  cp (IX+RING_BUFFER_SIZE)
  jr nz, ringBufferPush_skip

  ; Call HIGHWATER callback
  ld hl, ringBufferPush_skip
  push hl
  ld h, (IX+RING_BUFFER_HIGHWATER_CALLBACK_HI)
  ld l, (IX+RING_BUFFER_HIGHWATER_CALLBACK_LO)
  jp (hl)
ringBufferPush_skip:
  pop hl
  pop bc
  pop af
  ret

; IX - pointer to ring buffer struct
; pre: ring buffer not empty
; Returns in A - Popped character
ringBufferPop:
  push bc
  push hl
  ; Add received char at HEAD
  ld h, (IX+RING_BUFFER_PTR_HI)
  ld l, (IX+RING_BUFFER_PTR_LO)
  ld b, 0
  ld c, (IX+RING_BUFFER_TAIL) ; C = TAIL
  add hl, bc
  ld b, (hl) ; B = Popped character

  ; Increase TAIL
  inc c
  ; TAIL=TAIL % MAX_SIZE
  ld a, (IX+RING_BUFFER_MASK)
  and c
  ; Store TAIL
  ld (IX+RING_BUFFER_TAIL), a

  ; Decrease size
  dec (IX+RING_BUFFER_SIZE)

  ld a, (IX+RING_BUFFER_LOWWATER)
  cp (IX+RING_BUFFER_SIZE)
  jr nz, ringBufferPop_skip

  ; Call LOWWATER callback
  ld hl, ringBufferPop_skip
  push hl
  ld h, (IX+RING_BUFFER_LOWWATER_CALLBACK_HI)
  ld l, (IX+RING_BUFFER_LOWWATER_CALLBACK_LO)
  jp (hl)

ringBufferPop_skip:
  ld a, b ; A = Received character
  pop hl
  pop bc
  ret

