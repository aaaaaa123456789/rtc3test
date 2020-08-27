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
	; ...

TickTest:
	; ...

OffTest:
	; ...
