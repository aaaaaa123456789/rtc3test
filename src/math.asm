Multiply:
	; bc = b * c
	; preserves all other registers, including af
	push af
	push hl
	ld hl, 0
	ld b, h
	srl c
.loop
	rl c
	rl b
.test
	srl a
	jr nc, .skip
	add hl, bc
.skip
	; carry is always clear here (the addition can't carry)
	jr nz, .loop
	ld b, h
	ld c, l
	pop hl
	pop af
	ret

Divide:
	; bc = bc / a; a = bc % a
	push de
	push hl
	ld h, b
	ld l, c
	ld de, 0
	scf
.shift_loop
	rl e
	add a, a
	jr nc, .shift_loop
	rra
	cpl
	inc a
	ld b, a
.high_byte_loop
	add a, h
	jr nc, .skip_high_byte
	ld h, a
	ld a, d
	add a, e
	ld d, a
.skip_high_byte
	scf
	rr b
	ld a, b
	rr e
	jr nc, .high_byte_loop
	ld c, e
	ld e, $80
	xor a
.low_byte_loop
	push hl
	add hl, bc
	jr nc, .restore
	add sp, 2
	push hl
	add a, e
.restore
	pop hl
	scf
	rr b
	rr c
	srl e
	jr nc, .low_byte_loop
	ld b, d
	ld c, e
	ld a, l
	pop hl
	pop de
	ret
