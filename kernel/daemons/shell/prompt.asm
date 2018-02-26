;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

;===============================================================================
; wejście:
;	rcx - maksymalna ilość znaków do pobrania od użytkownika
;	rdi - wskaźnik do bufora przechowującego pobrane znaki
;	r8 - ilość znaków już przebywających w buforze (zostaną wyświetlone, a kursor przemieszczony na koniec ciągu)
; wyjście:
;	Flaga CF - ciąg pusty
;	rcx - ilość pobranych znaków od użytkownika
shell_prompt:
	; zachowaj oryginalne rejestry
	push	rax
	push	rdx
	push	rdi
	push	r8

	; zapamiętaj rozmiar bufora
	push	rcx

	; wyświetl zawartość bufora, jeśli istnieje
	cmp	r8,	EMPTY
	je	.loop	; brak

	; wyświetl zawartość bufora
	xchg	rcx,	r8	; ilość znaków w buforze
	xchg	rsi,	rdi	; ustaw wskaźnik na początek bufora
	call	kernel_video_string

	; rejestry na miejsce
	xchg	rcx,	r8
	xchg	rdi,	rsi

	; zmiejsz rozmiar dostępnego bufora o wyświetloną zawartość
	sub	rcx,	r8

	; przesuń wskaźnik pozycji bufora na konieć wyświetlonej zawartości
	add	rdi,	r8

.loop:
	; pobierz klawisz
	call	kernel_keyboard_read
	jz	.loop	; brak klawisza, spróbuj raz jeszcze

	; klawisz typu Backspace?
	cmp	ax,	ASCII_BACKSPACE
	je	.key_backspace

	; klawisz typu Enter?
	cmp	ax,	ASCII_ENTER
	je	.key_enter

	; klawisz typu ESC?
	cmp	ax,	ASCII_ESCAPE
	je	.empty	; zakończ

	; znak dozwolony?

	; sprawdź czy pobrany znak jest możliwy do wyświetlenia
	cmp	rax,	ASCII_SPACE
	jb	.loop	; nie, zignoruj
	cmp	rax,	ASCII_TILDE
	ja	.loop	; nie, zignoruj

	; sprawdź czy jest dostępne miejsce w buforze
	cmp	rcx,	EMPTY
	je	.loop	; brak miejsca, zignoruj

	; zapisz znak do bufora
	stosb

	; zmniejsz rozmiar dostępnego bufora
	dec	rcx

.print:
	; wyświetl znak
	call	kernel_video_char

	; kontynuuj
	jmp	.loop

.key_backspace:
	; sprawdź czy bufor zawiera znaki
	cmp	rcx,	qword [rsp]
	je	.loop	; jeśli nie, zignoruj

	; zwieksz rozmiar dostępnego bufora
	inc	rcx

	; cofnij wskaźnik bufora na poprzednią pozycję
	dec	rdi

	; wyświetl klawisz backspace
	jmp	.print

.key_enter:
	; sprawdź czy bufor zawiera znaki
	cmp	rcx,	qword [rsp]
	je	.empty	; nie

	; oblicz rozmiar wykorzystanego bufora
	sub	qword [rsp],	rcx

	; pobierz wynik
	pop	rcx

	; flaga, sukces
	clc

	; koniec liblioteki
	jmp	.end

.empty:
	; przywróć oryginalny rozmiar bufora
	pop	rcx

	; flaga, błąd
	stc

.end:
	; przywróć oryginalne rejestry
	pop	r8
	pop	rdi
	pop	rdx
	pop	rax

	; powrót z liblioteki
	ret
