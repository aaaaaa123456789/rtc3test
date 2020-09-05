PassFailResult:
	; loads a PASS/FAIL result based on carry (and preserves carry)
	push af
	ld hl, PassString
	jr nc, .ok
	ld hl, FailString
.ok
	ld de, hTestResult
	rst Print
	ld a, "@"
	ld [de], a
	pop af
	ret

PassString:
	db "PASS@"

FailString:
	db "FAIL@"

FailedRegistersResult:
	; in: a: bit pattern indicating failed registers (0 = RTCS, 4 = RTCDH)
	; out: result in hTestResult and carry flag
	cp 1
	ccf
	call PassFailResult
	ret nc
	adc a ;set the bit after the flags
	add a, a
	add a, a
	lb bc, 6, LOW(hTestResult + 5)
	ld d, a
	ld a, " "
	ldh [hTestResult + 4], a
	ld hl, .letters
.loop
	ld a, [hli]
	sla d
	jr nc, .skip
	ldh [c], a
	inc c
.skip
	dec b
	jr nz, .loop
	; the last bit is always set (so the terminator is written), so the carry flag is set
	ret

.letters
	db "CDHMS@"

PrintTime:
	; in: de: time (in units of 0.1ms), hl: buffer
	; preserves all but a
	push de
	inc d
	jr z, .timeout
	dec d
	push bc
	ld b, d
	ld c, e
	ld de, 4
	add hl, de
	ld e, 1
	cpw bc, 100
	jr c, .ok
	inc e
	cpw bc, 1000
	jr c, .ok
	inc e
	cpw bc, 10000
	jr c, .ok
	inc e
.ok
	add hl, de
	ld a, "@"
	ld [hld], a
	ld a, "s"
	ld [hld], a
	ld a, "m"
	ld [hld], a
	ld a, 10
	call Divide
	ld [hld], a
	ld a, "."
	ld [hld], a
.loop
	ld a, 10
	call Divide
	ld [hld], a
	dec e
	jr nz, .loop
	pop bc
	pop de
	ret

.timeout
	push hl
	ld d, h
	ld e, l
	ld hl, .timeout_string
	rst Print
	ld a, "@"
	ld [de], a
	pop hl
	pop de
	ret

.timeout_string
	db "TIMEOUT@"
