MainMenu:
	rst ClearScreen
	coord de, 2, 0
	ld hl, .title
	rst Print
	coord de, 1, 2
	ld a, ">"
	ld [de], a
	inc e
	ld c, (Menus.end - Menus) / 4
	ld hl, Menus
.entry_loop
	ld a, [hli]
	push hl
	ld h, [hl]
	ld l, a
	rst Print
	pop hl
	inc hl
	inc hl
	inc hl
	rst NextLine
	inc e
	inc e
	dec c
	jr nz, .entry_loop
	ld hl, .bottom
	coord de, 5, 17
	rst Print
	ld bc, (Menus.end - Menus) / 4 ;b = 0 here
	rst EnableScreen
.menu_loop
	call WaitForButtonPress
	and a
	jr z, .execute
	ld l, b
	ld h, 0
	rept 5
		add hl, hl
	endr
	coord de, 1, 2
	add hl, de
	inc b
	dec a
	jr z, .got_selection
	dec b
	jr nz, .no_top_wrap
	ld b, c
.no_top_wrap
	dec b
.got_selection
	ld a, b
	cp c
	jr nz, .no_bottom_wrap
	ld b, 0
.no_bottom_wrap
	rst WaitVBlank
	ld [hl], " "
	ld l, b
	ld h, 0
	rept 5
		add hl, hl
	endr
	add hl, de
	ld [hl], ">"
	jr .menu_loop

.execute
	ld a, b
	add a, a
	add a, a
	add a, LOW(Menus)
	ld l, a
	adc HIGH(Menus)
	sub l
	ld h, a
	call RunTests
	jr MainMenu

.title
	db "MBC3 RTC test ROM@"

.bottom
	db "* Run tests@"

RunTests:
	; hl: selected menu entry
	rst ClearScreen
	ld a, [hli]
	push hl
	ld h, [hl]
	ld l, a
	call StringLength
	cpl
	sub -22 ;will clear carry
	rra
	ld e, a
	ld d, $9c
	rst Print
	rst EnableScreen
	pop hl
	inc hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	coord de, 0, 2
.test_loop
	ld a, [hli]
	push hl
	ld h, [hl]
	ld l, a
	and h
	inc a
	jr z, .done
	res 7, h
	rst WaitVBlank
	rst Print
	pop hl
	ld a, [hli]
	push hl
	add a, a
	jr nc, .same_line
	ld a, ":"
	ld [de], a
	rst NextLine
.same_line
	ld a, e
	and $e0
	or 17
	ld e, a
	ld hl, .dots
	rst Print
	pop hl
	ld a, [hli]
	push hl
	ld h, [hl]
	ld l, a
	push de
	call JumpHL
	; carry indicates the test failed
	pop de
	sbc a
	and RED ^ GREEN
	xor GREEN
	ld c, a
	inc e
	res 2, e
	rst WaitVBlank
	ld hl, .clear_dots
	rst Print
	ld hl, hTestResult
	ld a, c
	call PrintResult
	pop hl
	inc hl
	jr .test_loop

.done
	coord de, 6, 17
	ld hl, .return
	rst WaitVBlank
	rst Print
.return_loop
	call WaitForButtonPress
	and a
	jr nz, .return_loop
	jp MainMenu

.dots
	db "...@"

.clear_dots
	db "   @"

.return
	db "* Return@"

Menus:
	dw .basic_tests, BasicTests
.end

.basic_tests
	db "Basic tests@"
