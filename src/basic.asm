BasicTests:
	dw .on_test, OnTest
	dw .tick, TickTest | $8000
	dw .off_test, OffTest
	; ...
	dw -1

.on_test
	db "RTC on@"
.tick
	db "Tick@"
.off_test
	db "RTC off@"

OnTest:
	write_RTC_register RTCDH, 0
	read_RTC_register RTCS
	ld hl, $a000
.loop
	rst WaitVBlank
	latch_RTC
	jr .delay
.delay
	cp [hl]
	scf
	ccf
	jr nz, .done
	dec l
	jr nz, .loop
	scf
.done
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
	read_RTC_register RTCS
	ld hl, $a000
.loop
	rst WaitVBlank
	latch_RTC
	jr .delay
.delay
	cp [hl]
	scf
	jr nz, .done
	dec l
	jr nz, .loop
	and a
.done
	jp PassFailResult
