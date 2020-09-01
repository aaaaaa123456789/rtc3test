; all of these macros must remain as macros (instead of functions) to ensure timing is accurate

latch_RTC: MACRO
	xor a
	ld [rRTCL], a
	inc a
	ld [rRTCL], a
ENDM

read_RTC_register: MACRO
	; \1: register to read
	; out: a: value
	if !STRCMP(STRLWR("\1"), "a")
		ld [rRAMB], a
	endc
	latch_RTC
	if STRCMP(STRLWR("\1"), "a")
		ld a, \1
		ld [rRAMB], a
	else
		; delay
		inc hl
		dec hl
	endc
	ld a, [$a000]
ENDM

write_RTC_register: MACRO
	; \1: register to write, \2: value to write
	; clobbers a except when \2 == a
	if !STRCMP(STRLWR("\2"), "a")
		push af
	endc
	if STRCMP(STRLWR("\1"), "a")
		ld a, \1
	endc
	ld [rRAMB], a
	if STRCMP(STRLWR("\2"), "a")
		if ISCONST(\2)
			if \2
				ld a, \2
			else
				xor a
			endc
		else
			ld a, \2
		endc
	else
		pop af
	endc
	ld [$a000], a
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
	ld c, a
	ldh a, [rDIV]
	push bc
	ld b, e
	ld e, c
	ld c, d
	ld d, a
	and a
	jr nz, .fix\@
	ld a, e
	and $e0
	cp b
	jr z, .fix\@
	inc c
.fix\@
	pop af
	ld b, a
	call FixTimings

.done\@
	xor a
	ldh [rTAC], a
	ldh [rIF], a
	ei
	call ConvertTimingsTo100us
ENDM
