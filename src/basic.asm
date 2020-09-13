BasicTests:
	dw .on_test, OnTest
	dw .tick, TickTest | $8000
	dw .off_test, OffTest
	dw .write | $8000, BasicWriteTest
	dw .increment | $8000, BasicIncrementTest | $8000
	dw .rollovers, RolloversTest | $8000
	dw .overflow, OverflowTest | $8000
	dw .overflow_stickiness | $8000, OverflowStickinessTest | $8000
	dw -1

.on_test
	db "RTC on@"
.tick
	db "Tick@"
.off_test
	db "RTC off@"
.write
	db "Register writes@"
.increment
	db "Seconds increment@"
.rollovers
	db "Rollovers@"
.overflow
	db "Overflow@"
.overflow_stickiness
	db "Overflow stickiness@"

OnTest:
	write_RTC_register RTCDH, 0
	call WaitNextRTCTick
	jp PassFailResult

TickTest:
	write_RTC_register RTCDH, 0
	ld a, RTCS
	ld [rRAMB], a
	call PrepareTimer
	latch_RTC
	ld hl, $a000
	ld b, [hl]
.wait_loop
	latch_RTC
	ld a, [hl]
	cp b
	jr z, .wait_loop
	ld b, a
	start_timer
.tick_loop
	latch_RTC
	ld a, [hl]
	cp b
	check_timer .tick_loop, nz
	ld hl, hTestResult
	call PrintTime
	cpw de, 9950
	ret c
	cpw de, 10051
	ccf
	ret

OffTest:
	write_RTC_register RTCDH, $40
	call WaitNextRTCTick
	ccf
	jp PassFailResult

BasicWriteTest:
	call ReadRTC
	ld h, a
	ld l, e
	call .random59
	ld e, a
	ld l, d
	call .random59
	ld d, a
.random_hour
	call Random
	and 31
	jr z, .random_hour
	cp 24
	jr nc, .random_hour
	cp c
	jr z, .random_hour
	ld c, a
.random_day
	call Random
	and a
	jr z, .random_day
	cp b
	jr z, .random_day
	ld b, a
	srl h
	sbc a
	inc a
	call WriteRTC
	rst WaitVBlank ;wait one frame for good measure
	push de
	push bc
	ld h, a
	call ReadRTC
	cp h
	rst CarryIfNonZero
	ld a, b
	ld b, 0
	rl b
	pop hl
	cp h
	rst CarryIfNonZero
	rl b
	ld a, c
	cp l
	rst CarryIfNonZero
	rl b
	pop hl
	ld a, d
	cp h
	rst CarryIfNonZero
	rl b
	ld a, e
	sub l
	cp 2
	ccf
	ld a, b
	rla
	jp FailedRegistersResult

.random59
	call Random
	and 63
	jr z, .random59
	cp 59
	jr nc, .random59
	cp l
	jr z, .random59
	ret

BasicIncrementTest:
	call Random
	and 63
	cp 59
	jr nc, BasicIncrementTest
	ld l, a
	write_RTC_register RTCS, a
	call WaitRTCTick
	read_RTC_register RTCS
	inc l
	cp l
	rst CarryIfNonZero
	jp PassFailResult

RolloversTest:
	xor a
	lb bc, $ff, 23
	lb de, 59, 59
	call WriteRTC
	ld a, e
	call WaitRTCTick
	jr c, .done
	call ReadRTC
	and $c1
	dec a
	or b
	or c
	or d
	or e
	rst CarryIfNonZero
.done
	jp PassFailResult

OverflowTest:
	ld a, 1
OverflowTestContinue:
	lb bc, $ff, 23
	lb de, 59, 59
	call WriteRTC
	ld a, e
	call WaitRTCTick
	read_RTC_register RTCDH
	and $c1
	cp $80
	rst CarryIfNonZero
	jp PassFailResult

OverflowStickinessTest:
	ld a, $81
	jr OverflowTestContinue
