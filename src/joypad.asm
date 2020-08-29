ReadNextJoypad:
	ldh a, [hRandomState]
	inc a
	ldh [hRandomState], a
	rst WaitVBlank
ReadJoypad:
	push bc
	ld c, LOW(rJOYP)
	ld a, $20
	ldh [c], a
	push af
	pop af
	ld a, [c]
	cpl
	swap a
	and $f0
	ld b, a
	ld a, $10
	ldh [c], a
	push af
	pop af
	ldh a, [c]
	cpl
	and $f
	or b
	pop bc
	and a
	ret

WaitForButtonPress:
	; 0: A, 1: up, 2: down - all other buttons don't matter
	call ReadJoypad
	jr z, .released
.pressed
	call ReadNextJoypad
	jr nz, .pressed
.released
	call ReadNextJoypad
	jr z, .released
	rlca
	rlca
	cp 3
	ret c
	sub 4
	jr nz, .released
	ret
