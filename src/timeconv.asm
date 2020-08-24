FixTimings:
	; in: e: TIMA reading (262144 Hz), d: DIV reading (16384 Hz), c: DIV rollovers (64 Hz)
	; out: cde: 24-bit count of 262144 Hz cycles
	swap e
	ld a, e
	xor d
	rra
	jr nc, .ok
	inc d
	jr nz, .clear
	inc c
	jr z, .ok
.clear
	and a
.ok
	rr c
	rept 3
		rr d
		rr e
		srl c
	endr
	rr d
	rr e
	ret

ConvertTimingsTo100us:
	; in: 24-bit count of 262144 Hz cycles in cde (or $FFFFFF for overflow)
	; out: 100us (i.e., 0.1ms) intervals in de, or $FFFF for overflow
	; this requires multiplying by 10000/262144, which reduces to 625/16384
	ld a, c
	cp $19
	jr nc, .overflow
	push hl
	push bc
	ld h, c
	ld l, d
	ld a, e
	add hl, hl
	add a, a
	jr nc, .skip1
	inc l
.skip1
	ld b, 625 - $200
	call Multiply
	add hl, bc
	ld c, e
	ld b, 625 - $200
	call Multiply
	add a, b
	jr nc, .skip2
	inc hl
.skip2
	ld c, d
	ld b, 625 - $200
	call Multiply
	add a, c
	ld c, b
	ld b, 0
	jr nc, .skip3
	inc hl
.skip3
	add hl, bc
	pop bc
	swap a
	rrca
	and 7
	; round to nearest
	rra
	adc 0
	add hl, hl
	add hl, hl
	add a, l
	ld e, a
	adc h
	sub e
	ld d, a
	pop hl
	ret

.overflow
	ld de, -1
	ret

PrintTime:
	; in: de: time (in units of 0.1ms), hl: buffer
	; preserves all but a
	push de
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
