VERSION EQU 4

INCLUDE "hardware.asm"
INCLUDE "charmap.asm"
INCLUDE "macros.asm"
INCLUDE "tmacros.asm"

hTestResult  EQU $ff80
hRandomState EQU $fffe

SECTION "Header", ROM0[0]
INCLUDE "header.asm"

SECTION "Main", ROM0[$150]
INCLUDE "main.asm"

INCLUDE "font.asm"
INCLUDE "math.asm"
INCLUDE "joypad.asm"
INCLUDE "rtc.asm"
INCLUDE "text.asm"
INCLUDE "timing.asm"
INCLUDE "wait.asm"

; Tests
INCLUDE "tests.asm"
INCLUDE "basic.asm"
INCLUDE "range.asm"
INCLUDE "subsec.asm"
