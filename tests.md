# Test descriptions

This document describes the tests and expected results executed by the test ROM.

* [Notation and common conventions](#notation-and-common-conventions)
* [Basic tests](#basic-tests)
* [Range tests](#range-tests)
* [Sub-second writes](#sub-second-writes)

## Notation and common conventions

The five RTC registers will be referred to as second, minute, hour, day and control; the single-letter abbreviations
S, M, H, D and C are occasionally used in test results for brevity. The control register actually contains one bit of
the day counter (as well as the on/off toggle and the overflow flag), but for simplicity it is still referred to as
the control register.

All tests that involve some sort of timing are timed using the Game Boy's timer and divider registers, and thus they
are succeptible to any inaccuracies in the Game Boy's internal clock oscillator. Therefore, all such tests have some
tolerance for measurement error. However, these tests will fail if carried out in a platform with a significantly
inaccurate clock, such as the Super Game Boy.

Some behaviors are very common in tests, and thus they are given short attribute names:

* **Conditional**: refers to a test that will only run if the previous test succeeded; otherwise, the test will be
  skipped and the result will be N/A. If two or more consecutive tests are conditional, failure of any of those tests
  will prevent subsequent conditional tests from running (until a non-conditional test is reached or until the end of
  that test suite).
* **Pass/fail**: refers to a test that will simply report a pass/fail result. Tests without this attribute will report
  additional details when run.
* **Register list**: refers to a test that will simply report a pass result if all RTC registers contain the expected
  values, but when this is not the case, it will include the list of registers in the fail result (such as `FAIL MS`).

## Basic tests

* **RTC on** (pass/fail): enables the RTC (by setting bit 6 of the control register) and waits for it to tick.
* **Tick** (conditional): evaluates the time taken between successive ticks. (expected: 1000ms, tolerance: 1ms)
* **RTC off** (pass/fail): disables the RTC and waits approximately four seconds for it to tick. The test fails if the
  RTC ticks.
* **Register writes** (register list): generates a random new RTC state (ensuring that all values are different from
  the current state and that no rollovers will happen), writes it to the RTC registers and attempts to read it back.
  The test will pass if the state read back is equal to the new state, or to the new state plus one second.
* **Seconds increment** (pass/fail, conditional): sets the seconds register to a random value (other than 59) and
  waits for it to tick. The test passes if the new value is one greater than the value that was set.
* **Rollovers** (pass/fail, conditional): sets the RTC state to 255 days, 23:59:59, and waits for it to tick. The test
  passes if the new value is 256 days, 00:00:00.
* **Overflow** (pass/fail, conditional): sets the RTC state to 511 days (without overflow), 23:59:59, and waits for it
  to tick. The test passes if the overflow flag is set after it ticks.
* **Overflow stickiness** (pass/fail, conditional): repeats the previous test, but with overflow set. The test passes
  if the overflow flag remains set after the RTC ticks.

## Range tests

All of these tests verify that the RTC registers have the range of values they should have, and that writing a value
that is out of range (both in terms of bits and in terms of the expected ranges of the registers) works correctly.

* **All bits clear** (pass/fail): writes 0 to all RTC registers and validates that 0 is read back from all of them.
  (This test will wait for an RTC tick before writing the values to ensure that the seconds register doesn't read back
  1 due to an unexpected tick.)
* **All bits set** (pass/fail): writes values to the RTC registers with all valid bits set ($3F to the seconds and
  minutes registers, $1F to the hours register, $FF to the days register and $C1 to the control register) and checks
  that the same values are read back.
* **Valid bits** (register list): tests that only valid bits in each register (bits 0-5 for the seconds and minutes
  registers, 0-4 for the hours register and 0, 6 and 7 for the control register) are readable and writable; other bits
  should always read back as 0. The test will write a random value and its complement to each register (other than the
  days register, which doesn't have invalid bits) and check whether invalid bits read back as 0 (instead of whatever
  was written). The test passes if the value read back from each register is the value that was written with invalid
  bits set to zero.
* **Invalid value tick** (pass/fail, conditional): sets the hours, minutes and seconds registers to an invalid time
  (such as 28:63:60) and waits for the RTC to tick. The test passes if the day remains the same and the time is what
  was written plus one second (28:63:61 in the example).
* **Invalid rollovers** (register list, conditional): tests rollovers where the seconds, minutes and hours registers
  roll past the maximum value that will fit in them (63 for seconds and minutes and 31 for hours); in all cases, this
  should set the affected register to zero _without_ causing the next register to increment.
* **High minutes** (pass/fail): sets the minutes register to a value between 60 and 62 and the seconds register to 59,
  and waits for the RTC to tick. The test passes if the minutes register is incremented (and the seconds become 0).
* **High hours** (pass/fail): sets the hours register to a value between 24 and 30 and the minutes and seconds
  registers to 59, and waits for the RTC to tick. The test passes if the hours register is incremented (and the
  minutes and seconds registers become 0).

## Sub-second writes

These tests check the behavior of the sub-second counter in the RTC when a register is written to. While sub-second
values cannot be inspected directly, they can be measured by waiting for the RTC to tick.

These tests are named after the register that is written to and the time remaining (in milliseconds) until the next
tick at the time of writing. For instance, the RTCS/900 test will write to the seconds register when the next tick is
900ms away (i.e., 100ms after a tick).

The tolerance is 1.5ms for all tests. The tests are:

* **RTCS/500** (expected: 1000ms)
* **RTCS/900** (expected: 1000ms)
* **RTCM/50** (expected: 50ms)
* **RTCM/600** (expected: 600ms)
* **RTCH/200** (expected: 200ms)
* **RTCDL/800** (expected: 800ms)
* **RTCDH/300** (expected: 300ms)
* **RTC off/400**: turns the RTC off 400ms before the next tick, waits roughly half a second, turns it back on and
  measures the time it takes for the RTC to tick. (expected: 400ms)
