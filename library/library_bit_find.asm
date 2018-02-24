;===============================================================================
; Copyright (C) 2013-2017 Wataha.net
; All Rights Reserved
;
; Main developer:
;	Andrzej (akasei) Adamczyk [e-mail: akasei from wataha.net]
;===============================================================================

; Use:
; nasm - http://nasm.us/

;===============================================================================
; wejście:
;	rsi - początek przestrzeni binarnej mapy pamięci
;	rdi - koniec przestrzeni binarnej mapy pamięci
; wyjście:
;	Flaga CF - błąd, jeśli ustawiona
;	rax - bezwzględny numer znalezionego bitu
library_bit_find:
	; zachowaj oryginalne rejestry
	push	rcx
	push	rdi
	push	rsi

.search:
	; sprawdź czy "pakiet" zawiera, jakiekolwiek bity
	cmp	qword [rsi],	EMPTY
	jne	.found	; znaleziono

	; sprawdź następny "pakiet"
	add	rsi,	QWORD_SIZE_byte

	; sprawdź czy przeszukaliśmy już całą binarną mapę
	cmp	rsi,	rdi
	jne	.search	; szukaj dalej

	; flaga, błąd
	stc

	; koniec
	jmp	.end

.found:
	; pobierz pozycję wolnego bitu i wyłącz go
	bsf	rax,	qword [rsi]
	btr	qword [rsi],	rax

	; oblicz bezwzględny numer pobranego bitu
	sub	rsi,	qword [rsp]

	; zamień Bajty na bity
	shl	rsi,	DIVIDE_BY_8_shift

	; zwróć sumę pozycji
	add	rax,	rsi

	; flaga, sukces
	clc

.end:
	; przywróc oryginalne rejestry
	pop	rsi
	pop	rdi
	pop	rcx

	; powrót z procedury
	ret
