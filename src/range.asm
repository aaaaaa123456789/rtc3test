RangeTests:
	dw .register_bits, RegisterBitsTest
	; ...
	dw -1

.register_bits
	db "Reg. bits@"

RegisterBitsTest:
	; turn it off just in case
	write_RTC_register RTCDH, $40
	ld hl, rRAMB ;also initializes l = 0 for error tracking
	lb bc, $a0, $1f
	ld [hl], RTCH
	call .test
	rl l
	ld [hl], RTCM
	ld c, $3f
	call .test
	rl l
	ld [hl], RTCS
	call .test
	rl l
	; ensure the second counter is 0 so we don't accidentally get a rollover when turning the RTC on
	xor a
	ld [bc], a
	ld [hl], RTCDH
	ld c, $c1
	call .test
	scf
	and $10
	or l
	jp FailedRegistersResult

.test
	; in: c: mask
	call Random
	inc a
	jr z, .test
	dec a
	jr z, .test
	ld e, a
	cpl
	ld [bc], a
	and c
	ld d, a
	ld a, [bc]
	cp d
	scf
	ret nz
	ld a, e
	ld [bc], a
	and c
	ld e, a
	ld a, [bc]
	cp e
	rst CarryIfNonZero
	ret
