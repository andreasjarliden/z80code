.eq	WAIT_FOR_COMMAND	1
setup:
	ld	a, WAIT_FOR_COMMAND
	ld	(state), a
loop:
	halt
	jp	loop

intHandler:
	ld	a, (state)
	cmp	a, WAIT_FOR_COMMAND
	jrz	waitingForCommand:
	cmp	a, LOAD_COMMAND
	jrz	loadCommand

waitingForCommand:
	in	a, (PIOA)
	cmp	a, LOAD_COMMAND
	jrz	isLoadCommand
	cmp	a, RUN_COMMAND
	jrz	isRunCommand
	; Unknown command, just stay in WAIT_FOR_COMMAND state
	ei
	reti
isLoadCommand:
	ld	a, LOAD_STATE
	ld	(state),a
	ei
	reti
isRunCommand:
	ld	a, RUN_STATE
	ld	(state), a
	ei
	reti

loadCommand:
	

state:
	nop
