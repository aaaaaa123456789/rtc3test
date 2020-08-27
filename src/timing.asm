; all of these macros must remain as macros (instead of functions) to ensure timing is accurate

prepare_timer: MACRO
	xor a
	ldh [rTAC], a
	ld de, $20
	ld a, e
	ldh [rTMA], a
	ldh [rTIMA], a
	ld c, LOW(rDIV)
	di
ENDM

start_timer: MACRO
	ld a, 5
	ldh [rTAC], a
	ld a, [de] ;pointless read from $0020 to delay
	ld a, 0
	ldh [c], a
ENDM

check_timer: MACRO
	; \1: jump label, \2: condition to exit
	; intentionally inverted from a regular jump to highlight that the condition is negated
	; exits with de = time (in units of 0.1ms), or $FFFF if the event didn't happen in 4 seconds
	jr \2, .exit\@
	ldh a, [c]
	and a
	jr nz, \1
	ldh a, [rTIMA]
	and $e0
	cp e
	jr z, \1
	ld e, a
	inc d
	jr nz, \1
	ld de, -1
	ld c, e
	jr .done\@

.exit\@
	ldh a, [rTIMA]
	ld e, a
	ldh a, [c]
	ld c, d
	ld d, a
	call FixTimings

.done\@
	xor a
	ldh [rTAC], a
	ldh [rIF], a
	ei
	call ConvertTimingsTo100us
ENDM
