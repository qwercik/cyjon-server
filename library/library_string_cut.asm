;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

;===============================================================================
; wejście:
;	al - separator
;	rcx - rozmiar ciągu/bufora/tablicy
;	rsi - wskaźnik do ciągu/bufora/tablicy
; wyjście:
;	Flaga CF - podniesiona, jeśli koniec ciągu
;	rcx - ilość znaków w ciągu
library_string_cut:
	; zachowaj oryginalne rejestry
	push	rbx
	push	rsi
	push	rcx

	; licznik
	xor	rbx,	rbx

	; pusty ciąg?
	cmp	rcx,	EMPTY
	je	.error

.loop:
	; znaleziono separator
	cmp	byte [rsi],	al
	je	.found

	; zwiększ licznik i sprawdź następny znak
	inc	rbx
	inc	rsi

	; pozostały znaki w ciągu?
	dec	rcx
	jnz	.loop	; tak

.found:
	; flaga, sukces
	clc

	; koniec
	jmp	.end

.error:
	; flaga, błąd
	stc

.end:
	; zwróć wynik
	mov	qword [rsp],	rbx

	; przywróć oryginalne rejestry
	pop	rcx
	pop	rsi
	pop	rbx

	; powrót z procedury
	ret
