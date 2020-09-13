WaitATimes50ms:
	; exactly what it says on the can (assumes a > 0)
	; preserves everything but af
	; 50 ms = 52428.8 cycles. This is not a nice number by any means.
	; all indicated loop timings are one cycle too long (because the last jump is not taken)
	push bc
	push hl
	ld l, a
	ld b, a
	ld c, 0
	; running total (including call): 18 cycles
.longwait
	ld a, 49
.inner
	dec a
	jr nz, .inner
	dec bc
	ld a, b
	or c
	jr nz, .longwait
	; loop total: 204 cycles (times 256 * N iterations)
	; running total: 52224 * N + 17 cycles
	; remaining: 204.8 * (N - 1) + 187.8 cycles
	ld c, l
	ld b, a ;a = 0 here
	ld a, 2
	; this weird way of dividing by 5 ensures that the time taken is a linear function of N
.divloop
	inc a
	cp 5
	jr nz, .first_div_skip
	inc b
.first_div_skip
	cp 5
	jr nz, .second_div_skip
	xor a
.second_div_skip
	dec c
	jr nz, .divloop
	; loop total: 15 cycles (times N iterations)
	; remaining: 189.8 * (N - 1) + 169.8 cycles
	; = 190 * (N - 1) + 170 - b cycles (because b = N / 5 at this point, rounded to nearest)
	dec l
	jr z, .no_extra
.extraloop
	ld a, 46
.extrainner
	dec a
	jr nz, .extrainner
	nop
	dec l
	jr nz, .extrainner
	; loop total: 190 cycles (times N - 1 iterations)
	add hl, hl ;dummy instruction to make up for the two lost cycles for jumps not taken
.no_extra
	; remaining: 166 - b cycles (b <= 51)
	ld a, 138
	sub b
	; remaining: 163 - b = a + 25 cycles
	ld b, a
	srl b
	srl b
.final_loop
	dec b
	jr nz, .final_loop
	; loop total: 4 cycles (times a & ~3 iterations)
	cpl
	and 3
	; remaining: (a ^ 3) + 18 cycles
	add a, LOW(.exit)
	ld l, a
	adc HIGH(.exit)
	sub l
	ld h, a
	jp hl
	; remaining: (old a ^ 3) + 10 cycles - exactly enough for 0-3 nops, two pops and a ret

.exit
	nop
	nop
	nop
	pop hl
	pop bc
	ret
