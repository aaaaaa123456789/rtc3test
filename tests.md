# Test descriptions

This document describes the tests and expected results executed by the test ROM.

* [Notation and common conventions](notation-and-common-conventions)
* [Basic tests](basic-tests)

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

## Basic tests

* **RTC on** (pass/fail): enables the RTC (by setting bit 6 of the control register) and waits for it to tick.
* **Tick** (conditional): evaluates the time taken between successive ticks. (expected: 1000ms, tolerance: 5ms)
* **RTC off** (pass/fail): disables the RTC and waits approximately four seconds for it to tick. The test fails if the
  RTC ticks.
* **Register writes** (pass/fail): generates a random new RTC state (ensuring that all values are different from the
  current state and that no rollovers will happen), writes it to the RTC registers and attempts to read it back. The
  test will pass if the state read back is equal to the new state, or to the new state plus one second. Otherwise, the
  registers that contained incorrect values will be listed.
* **Second increment** (pass/fail, conditional): sets the seconds register to a random value (other than 59) and waits
  for it to tick. The test passes if the new value is one greater than the value that was set.
* **Rollovers** (pass/fail, conditional): sets the RTC state to 255 days, 23:59:59, and waits for it to tick. The test
  passes if the new value is 256 days, 00:00:00.
* **Overflow** (pass/fail, conditional): sets the RTC state to 511 days (without overflow), 23:59:59, and waits for it
  to tick. The test passes if the overflow flag is set after it ticks.
* **Overflow stickiness** (pass/fail, conditional): repeats the previous test, but with overflow set. The test passes
  if the overflow flag remains set after the RTC ticks.
