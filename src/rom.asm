INCLUDE "hardware.asm"
INCLUDE "charmap.asm"
INCLUDE "macros.asm"
INCLUDE "timing.asm"

hTestResult EQU $ff80

SECTION "Header", ROM0[0]
INCLUDE "header.asm"

SECTION "Main", ROM0[$150]
INCLUDE "main.asm"

INCLUDE "basic.asm"
INCLUDE "font.asm"
INCLUDE "math.asm"
INCLUDE "joypad.asm"
INCLUDE "text.asm"
INCLUDE "timeconv.asm"
