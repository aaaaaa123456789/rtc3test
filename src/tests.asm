; Test menus:
; - each entry contains two pointers: one to the label and one to the actual test list
; - the list ends with the .end label; no final entry is needed

Menus:
	dw .basic_tests, BasicTests
	dw .range_tests, RangeTests
	dw .subsecond_tests, SubsecondTests
.end

.basic_tests
	db "Basic tests@"
.range_tests
	db "Range tests@"
.subsecond_tests
	db "Sub-second writes@"

; Each test menu entry (defined at the top of its own file) defines the tests in order:
; SampleTests:
;   dw .first_test, FirstTest
;   dw .second_test, SecondTest
;   dw -1
; Each entry contains a pointer to the label (that will be printed in front of its result) and a
; pointer to the actual test routine. If bit 15 of the label is set (by ORing $8000 into the label),
; the label will be ended with a colon and the result will be printed on the following line. If bit
; 15 of the test routine is set, the test will be skipped (with a result of N/A) if the previous
; test either failed or was also skipped.
; The test routine returns the result message in hTestResult and carry if the test failed.
