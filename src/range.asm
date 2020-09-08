RangeTests:
	dw .all_bits_clear, AllBitsClearTest
	dw .all_bits_set, AllBitsSetTest
	dw .valid_bits, ValidBitsTest
	dw .invalid_value_tick | $8000, InvalidValueTickTest | $8000
	dw .invalid_rollovers | $8000, InvalidRolloversTest | $8000
	; ...
	dw -1

.all_bits_clear
	db "All bits clear@"
.all_bits_set
	db "All bits set@"
.valid_bits
	db "Valid bits@"
.invalid_value_tick
	db "Invalid value tick@"
.invalid_rollovers
	db "Invalid rollovers@"

AllBitsClearTest:
	write_RTC_register RTCDH, 0
	; wait for a tick to prevent unrelated bugs from affecting this test
	call WaitNextRTCTick
	xor a
	ld b, a
	ld c, a
	ld d, a
	ld e, a
	call WriteRTC
	rst WaitVBlank
	call ReadRTC
	or b
	or c
	or d
	or e
	jr AllBitsSetTest.done

AllBitsSetTest:
	write_RTC_register RTCDH, $40
	ld a, $c1
	lb bc, $ff, $1f
	lb de, $3f, $3f
	call WriteRTC
	rst WaitVBlank
	call ReadRTC
	cp $c1
	jr nz, .done
	ld a, d
	cp e
	jr nz, .done
	cp $3f
	jr nz, .done
	inc b
	jr nz, .done
	ld a, c
	cp $1f
.done
	rst CarryIfNonZero
	jp PassFailResult

ValidBitsTest:
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
	latch_RTC
	ld a, [bc]
	cp d
	scf
	ret nz
	ld a, e
	ld [bc], a
	and c
	ld e, a
	latch_RTC
	ld a, [bc]
	cp e
	rst CarryIfNonZero
	ret

InvalidValueTickTest:
	call Random
	or $fc
	inc a
	jr z, InvalidValueTickTest
	add a, 63 ;results in a value between 60 and 62
	ld e, a
	call Random
	and 3
	add a, 60
	ld d, a
	call Random
	and 7
	add a, 24
	ld c, a
	call Random
	ld b, a
	call Random
	and 1
	ld h, a
	call WriteRTC
	ld a, e
	call WaitRTCTick
	jr c, .done
	push bc
	push de
	call ReadRTC
	cp h
	pop hl
	jr nz, .failed
	inc l
	ld a, e
	cp l
	jr nz, .failed
	ld a, d
	cp h
	jr nz, .failed
	pop hl
	push hl ;so we can pop it again
	ld a, c
	cp l
	jr nz, .failed
	ld a, b
	cp h
.failed
	pop hl
	rst CarryIfNonZero
.done
	jp PassFailResult

InvalidRolloversTest:
	; ...
