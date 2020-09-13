SubsecondTests:
	dw .short_second_write, ShortSecondWrite
	dw .long_second_write, LongSecondWrite
	; ...
	dw -1

.short_second_write
	db "RTCS/.5s@"
.long_second_write
	db "RTCS/.9s@"

ShortSecondWrite:
	write_RTC_register RTCDH, 0
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
