;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

	; przygotowanie rejestrów pod procedurę mapowania
	xor	ebx,	ebx	; pozpocznij mapowanie
	mov	edx,	0x534D4150	; ciąg znaków "SMAP", specjalna wartość wymagana przez procedurę

	; przygotuj komunikat błędu
	mov	si,	zero_error_memory_map_text

	; mapę pamięci utwórz pod adresem 0x0000:0x0500
	mov	di,	ZERO_MEMORY_MAP_address

.memory_loop:
	; pobierz informacje o przestrzeni pamięci
	mov	eax,	0xE820
	mov	ecx,	0x18	; rozmiar wiersza opisującego daną przestrzeń pamięci
	int	0x15

	; wystąpił błąd?
	jc	error	; tak

	; przesuń wskaźnik do następnego wiersza
	add	di,	0x18

	; koniec informacji o innych przestrzeniach pamięci?
	test	bx,	bx
	jnz	.memory_loop	; nie

	; tablicę zakończ pustym wierszem
	xor	al,	al
	rep	stosb
