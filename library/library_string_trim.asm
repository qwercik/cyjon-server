;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

;===============================================================================
; wejście:
;	rcx	- ilość znaków w ciągu
;	rdi	- wskaźnik do ciągu
; wyjście:
;	Flaga CF - ciąg pusty
;	rcx	- ilość znaków w ciągu bez "białych" znaków
;	rdi	- wskaźnik początku ciągu bez "białych" znaków
library_string_trim:
	; zachowaj oryginalne rejestry
	push	rdi

	; ciąg pusty?
	cmp	rcx,	EMPTY
	je	.error	; tak

.loop0:
	; spacja?
	cmp	byte [rdi],	ASCII_SPACE
	je	.prefix

	; tabulator?
	cmp	byte [rdi],	ASCII_TAB
	je	.prefix

	; zachowaj wskaźnik początku ciągu bez białych znaków
	mov	qword [rsp],	rdi

	; przesuń wskaźnik na ostatni znak
	add	rdi,	rcx
	dec	rdi

.loop1:
	; spacja?
	cmp	byte [rdi],	ASCII_SPACE
	je	.suffix

	; tabulator?
	cmp	byte [rdi],	ASCII_TAB
	jne	.ready

.suffix:
	; cofnij wskaźnik na poprzedni znak
	dec	rdi

	; kontynuuj
	dec	rcx
	jnz	.loop1

	; będąc w tej fazie, pusty ciąg nie wystąpi

.ready:
	; flaga, sukces
	clc

	; koniec procedury
	jmp	.end

.prefix:
	; przesuń wskaźnik na następny znak
	inc	rdi

	; kontynuuj
	dec	rcx
	jnz	.loop0

	; pusty ciąg!

.error:
	; flaga, błąd
	stc

.end:
	; przywróć oryginalne rejestry
	pop	rdi

	; powrót z procedury
	ret
