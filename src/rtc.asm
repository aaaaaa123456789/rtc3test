ReadRTC:
	latch_RTC
	push hl
	ld h, $a0
	ld a, RTCS
	ld [rRAMB], a
	ld e, [hl]
	inc a
	ld [rRAMB], a
	ld d, [hl]
	inc a
	ld [rRAMB], a
	ld c, [hl]
	inc a
	ld [rRAMB], a
	ld b, [hl]
	inc a
	ld [rRAMB], a
	ld a, [hl]
	pop hl
	ret

WriteRTC:
	push hl
	ld h, $a0
	ld l, a
	ld a, RTCS
	ld [rRAMB], a
	ld [hl], e
	inc a
	ld [rRAMB], a
	ld [hl], d
	inc a
	ld [rRAMB], a
	ld [hl], c
	inc a
	ld [rRAMB], a
	ld [hl], b
	inc a
	ld [rRAMB], a
	ld [hl], l
	ld a, l
	pop hl
	ret

WaitCompareRTC:
	; non-zero and carry on timeout
	ld h, a
	call WaitNextRTCTick
	sbc a
	ret nz
	ld a, h
CompareRTC:
	; in: abcde: expected RTC state
	; out: zero: RTC matches; all registers clobbered
	push bc
	push de
	ld h, a
	call ReadRTC
	sub h
	ld h, a
	ld l, e
	ld a, d
	pop de
	sub d
	or h
	ld a, l
	pop hl
	ret nz
	cp e
	ret nz
	ld a, b
	cp h
	ret nz
	ld a, c
	cp l
	ret

WaitNextRTCTick:
	read_RTC_register RTCS
WaitRTCTick:
	; in: a: current seconds
	; out: carry if timeout
	push hl
	ld hl, rRAMB
	ld [hl], RTCS
	assert !LOW(rRAMB)
.loop
	dec l
	jr z, .fail
	rst WaitVBlank
	ld h, HIGH(rRTCL)
	ld [hl], 0
	ld [hl], 1
	ld h, $a0
	cp [hl]
	jr z, .loop
	scf
.fail
	ccf
	pop hl
	ret
