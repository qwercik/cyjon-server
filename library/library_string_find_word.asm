;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

;===============================================================================
; wejście:
;	rcx - rozmiar bufora
;	rdi - wskaźnik do bufora
; wyjście:
;	Flaga CF - jeśli błąd
;	rcx - rozmiar pierwszego znalezionego "słowa"
;	rdi - wskaźnik bezwzględny w ciągu do znalezionego słowa
library_string_find_word:
	; zachowaj oryginalne rejestry
	push	rax

.find:
	; pomiń spacje przed słowem
	cmp	byte [rdi],	ASCII_SPACE
	je	.leave

	; pomiń znak tabulacji przed słowem
	cmp	byte [rdi],	ASCII_TAB
	jne	.char	; znaleziono pierwszy znak należący do słowa

.leave:
	; przesuń wskaźnik bufora na następny znak
	inc	rdi

	; kontynuuj
	dec	rcx
	jnz	.find
	jz	.not_found	; ciąg pusty

.char:
	; wylicz rozmiar słowa

	; zachowaj adres początku słowa
	push	rdi

	; licznik
	xor	rax,	rax

.count:
	; sprawdź czy koniec słowa
	cmp	byte [rdi],	ASCII_SPACE
	je	.ready

	; sprawdź czy koniec słowa
	cmp	byte [rdi],	ASCII_TAB
	je	.ready

	; nieoczekiwany koniec ciągu?
	cmp	byte [rdi],	ASCII_TERMINATOR
	je	.ready

	; przesuń wskaźnik na następny znak w buforze polecenia
	inc	rdi

	; zwiększ licznik znaków przypadających na znalezione słowo
	inc	rax

	; zliczaj dalej
	dec	rcx
	jnz	.count

.ready:
	; zwróć rozmiar słowa
	mov	rcx,	rax

	; przywróć adres początku słowa
	pop	rdi

	; flaga, sukces
	clc

	; koniec
	jmp	.end

.not_found:
	; nie znaleziono słowa w ciągu znaków
	stc

.end:
	; przywróć oryginalne rejestry
	pop	rax

	; powrót z procedury
	ret
