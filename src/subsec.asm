SubsecondTests:
	dw .short_second_write, ShortSecondWrite
	dw .long_second_write, LongSecondWrite
	dw .short_minute_write, ShortMinuteWrite
	dw .long_minute_write, LongMinuteWrite
	dw .hour_write, HourWrite
	dw .day_low_write, DayLowWrite
	dw .day_high_write, DayHighWrite
	; ...
	dw -1

.short_second_write
	db "RTCS/500@"
.long_second_write
	db "RTCS/900@"
.short_minute_write
	db "RTCM/50@"
.long_minute_write
	db "RTCM/600@"
.hour_write
	db "RTCH/200@"
.day_low_write
	db "RTCDL/800@"
.day_high_write
	db "RTCDH/300@"

ShortSecondWrite:
	write_RTC_register RTCDH, 0
	call WaitNextRTCTick ;ensure that the RTC is actually working!
	jp c, TimeoutResult
	ld a, RTCS
	ld [rRAMB], a
	call PrepareTimer
	latch_RTC
	ld hl, $a000
	ld b, [hl]
.wait
	latch_RTC
	ld a, [hl]
	cp b
	jr z, .wait
	ld b, a
	ld a, 10
	call WaitATimes50ms
	ld [hl], b
	start_timer
.check
	latch_RTC
	ld a, [hl]
	cp b
	check_timer .check, nz
	jr LongSecondWrite.done

LongSecondWrite:
	call WaitNextRTCTick
	jp c, TimeoutResult
	ld a, RTCS
	ld [rRAMB], a
	ld hl, $a000
.reject
	call Random
	and 63
	cp 58
	jr nc, .reject
	inc a
	ld b, a
	call PrepareTimer
	ld [hl], b
.wait
	latch_RTC
	ld a, [hl]
	cp b
	jr z, .wait
	ld a, 2
	call WaitATimes50ms
	ld [hl], 0
	start_timer
.check
	latch_RTC
	ld a, [hl]
	and a
	check_timer .check, nz
.done
	ld hl, hTestResult
	call PrintTime
	cpw de, 9920
	ret c
	cpw de, 10081
	ccf
	ret

; These tests are all identical. I only want to write this thing once.
___test_sub_second_register_write: MACRO
	; in: \1: register, \2: time to tick when the register is written (in 50ms increments)
	; no \@ in local labels because this is meant to be used as a function body
	call WaitNextRTCTick
	jp c, TimeoutResult
	ld a, \1
	ld [rRAMB], a
	ld hl, $a000
	ld [hl], 1
	if (\1) == RTCM
		dec a
	else
		ld a, RTCS
	endc
	ld [rRAMB], a
	call PrepareTimer
	latch_RTC
	ld b, [hl]
.wait
	latch_RTC
	ld a, [hl]
	cp b
	jr z, .wait
	ld b, a
	ld a, 20 - (\2)
	call WaitATimes50ms
	ld a, \1
	ld [rRAMB], a
	ld [hl], 0
	if (\1) == RTCM
		dec a
	else
		ld a, RTCS
	endc
	ld [rRAMB], a
	start_timer
.check
	latch_RTC
	ld a, [hl]
	cp b
	check_timer .check, nz
	ld hl, hTestResult
	call PrintTime
	cpw de, (\2) * 500 - 80
	ret c
	cpw de, (\2) * 500 + 81
	ccf
	ret
ENDM

ShortMinuteWrite:
	___test_sub_second_register_write RTCM, 1

LongMinuteWrite:
	___test_sub_second_register_write RTCM, 12

HourWrite:
	___test_sub_second_register_write RTCH, 4

DayLowWrite:
	___test_sub_second_register_write RTCDL, 16

DayHighWrite:
	___test_sub_second_register_write RTCDH, 6
