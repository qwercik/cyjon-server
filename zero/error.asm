;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

error:
	; wyświetl komunikat
	mov	ah,	0x0E
	xor	bh,	bh	; strona 0

.loop:
	; wyświetl znak z ciągu
	lodsb
	int	0x10

	; koniec ciągu?
	test	al,	al
	jnz	.loop	; nie

	; zatrzymaj dalsze wykonywanie kodu
	jmp	$
