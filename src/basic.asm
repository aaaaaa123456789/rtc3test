BasicTests:
	dw .on_test, OnTest
	dw .tick, TickTest | $8000
	dw .off_test, OffTest
	dw .write | $8000, BasicWriteTest
	dw .rollovers, RolloversTest | $8000
	dw .overflow, OverflowTest | $8000
	; ...
	dw -1

.on_test
	db "RTC on@"
.tick
	db "Tick@"
.off_test
	db "RTC off@"
.write
	db "Register writes@"
.rollovers
	db "Rollovers@"
.overflow
	db "Overflow@"

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
	cp 24
	jr nc, .random_hour
	cp c
	jr z, .random_hour
	ld c, a
.random_day
	call Random
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
	push af
	ld hl, FailString
	ld de, hTestResult
	rst Print
	ld a, " "
	ld [de], a
	call ReadRTC
	pop hl
	cp h
	ld hl, hTestResult + 5
	jr z, .control_OK
	ld a, "C"
	ld [hli], a
.control_OK
	; interrupts are disabled, so stack abuse is OK
	pop af
	add sp, -3
	cp b
	jr z, .day_OK
	ld a, "D"
	ld [hli], a
.day_OK
	pop af
	inc sp
	cp c
	jr z, .hour_OK
	ld a, "H"
	ld [hli], a
.hour_OK
	pop bc
	ld a, b
	cp d
	jr z, .minute_OK
	ld a, "M"
	ld [hli], a
.minute_OK
	ld a, c
	sub e
	jr z, .second_OK
	dec a
	jr z, .second_OK
	ld a, "S"
	ld [hli], a
.second_OK
	ld [hl], "@"
	ld a, l
	cp LOW(hTestResult + 5)
	scf
	ret nz
	ld hl, PassString
	ld de, hTestResult
	rst Print
	ld a, "@"
	ld [de], a
	and a
	ret

.random59
	call Random
	and 63
	cp 59
	jr nc, .random59
	cp l
	jr z, .random59
	ret

RolloversTest:
	xor a
	lb bc, $FF, 23
	lb de, 59, 59
	call WriteRTC
	ld a, e
	call WaitRTCTick
	jr c, .done
	call ReadRTC
	and $c1
	dec a
	jr nz, .fail
	or b
	or c
	or d
	or e
	jr z, .done
.fail
	scf
.done
	jp PassFailResult

OverflowTest:
	ld a, 1
	lb bc, $FF, 23
	lb de, 59, 59
	call WriteRTC
	ld a, e
	call WaitRTCTick
	read_RTC_register RTCDH
	and $c1
	cp $80
	jr z, .pass
	scf
.pass
	jp PassFailResult
