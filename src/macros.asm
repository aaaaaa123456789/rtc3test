cpw: MACRO
	ld a, LOW(\1)
	sub LOW(\2)
	ld a, HIGH(\1)
	sbc HIGH(\2)
ENDM
