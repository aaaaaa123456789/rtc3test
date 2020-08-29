BasicTests:
	dw .on_test, OnTest
	dw .tick, TickTest
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
	ld c, l
.loop
	rst WaitVBlank
	latch_RTC
	jr .delay
.delay
	cp [hl]
	scf
	ccf
	jr nz, .done
	dec b
	jr nz, .loop
	scf
.done
	jp PassFailResult

TickTest:
	; ...

OffTest:
	; ...
