;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

;===============================================================================
; wejście:
;	rcx - rozmiar ciągu
;	rsi - wskaźnik do ciągu
kernel_video_string:
	; zachowaj oryginalne rejestry
	push	rax
	push	rcx
	push	rsi

	; pobierz zdefiniowany kolor znaku
	mov	ah,	byte [kernel_video_char_color]

	; pobierz pozycje wskaźnika kursora
	mov	rdi,	qword [kernel_video_cursor_indicator]

.loop:
	; pobierz znak ASCII z ciągu
	lodsb

	; wyświetl znak ASCII na ekran
	call	kernel_video_char

	; przetworzono cały ciąg?
	dec	rcx
	jnz	.loop	; nie

	; zachowaj nową pozycję wskaźnika
	mov	qword [kernel_video_cursor_indicator],	rdi

	; ustaw kursor sprzętowy na nową pozycję
	call	kernel_video_cursor

	; przywróć oryginalne rejestry
	pop	rsi
	pop	rcx
	pop	rax

	; powrót z procedury
	ret

;===============================================================================
; wejście:
;	al - kod ASCII znaku
;	ah - kolor znaku/tła
;	rdi - wskaźnik kursora w przestrzeni pamięci ekranu
; wyjście:
;	rdi - nowa pozycja kursora w przestrzeni pamięci ekranu
kernel_video_char:
	; zachowaj oryginalne rejestry
	push	rax
	push	rcx
	push	rdx
	push	rsi

	; znak backspace?
	cmp	al,	ASCII_BACKSPACE
	jne	.no_backspace	; nie

	; wskaźnik kursora znajduje się na początku przestrzeni?
	cmp	rdi,	qword [kernel_video_base_address]
	je	.end	; tak

	xchg	bx,bx

	; cofnij wskaźnik o jeden znak i wyczyść pozycje
	sub	rdi,	VIDEO_TEXT_MODE_DEPTH_byte
	mov	byte [rdi],	ASCII_SPACE

	; koniec
	jmp	.end

.no_backspace:
	; znak nowej linii?
	cmp	al,	ASCII_NEW_LINE
	jne	.no_new_line	; nie

	; przesuń wskaźnik o szerokość linii do przodu
	add	rdi,	VIDEO_TEXT_MODE_WIDTH_char * VIDEO_TEXT_MODE_DEPTH_byte

	; cofnij wskaźnik o N znaków w aktualnej linii

	; przelicz pozycję na przesunięcie
	mov	rax,	rdi
	sub	rax,	qword [kernel_video_base_address]

	; oblicz resztę z dzielenia
	mov	cx,	VIDEO_TEXT_MODE_WIDTH_char * VIDEO_TEXT_MODE_DEPTH_byte
	xor	edx,	edx
	div	cx

	; koryguj wskaźnik o resztę z dzielenia
	sub	rdi,	rdx

	; sprawdź czy wskaźnik znalazł sie poza przestrzenią ekranu
	jmp	.check

.no_new_line:
	; zapisz znak/kolor do przestrzeni pamięci karty graficznej
	stosw

.check:
	; koniec przestrzeni pamięci?
	cmp	rdi,	VIDEO_TEXT_MODE_BASE_address + VIDEO_TEXT_MODE_SIZE_byte
	jb	.end	; nie

	; koryguj pozycje wskaźnika i zachowaj
	sub	rdi,	VIDEO_TEXT_MODE_WIDTH_char * VIDEO_TEXT_MODE_DEPTH_byte
	push	rdi

	; przesuń przestrzeń ekranu o jedną linię w górę
	mov	rdi,	qword [kernel_video_base_address]
	mov	rsi,	rdi
	add	rsi,	VIDEO_TEXT_MODE_WIDTH_char * VIDEO_TEXT_MODE_DEPTH_byte
	mov	rcx,	VIDEO_TEXT_MODE_WIDTH_char * VIDEO_TEXT_MODE_DEPTH_byte * ( VIDEO_TEXT_MODE_HEIGHT_char - 0x01 )
	rep	movsb

	; wyczyść ostatnią linię ekranu
	mov	al,	ASCII_SPACE
	mov	ah,	byte [kernel_video_char_color]
	mov	rcx,	VIDEO_TEXT_MODE_WIDTH_char
	rep	stosw

	; przywróć pozycje wskaźnika
	pop	rdi

.end:
	; przywróć oryginalne rejestry
	pop	rsi
	pop	rdx
	pop	rcx
	pop	rax

	; powrót z procedury
	ret

;===============================================================================
; przemieszcza kursor sprzętowy na pozycje wskaźnika kursora
kernel_video_cursor:
	; zachowaj oryginalne rejestry
	push	rax
	push	rcx
	push	rdx

	; oblicz przesunięcie kursora względem początku przestrzeni pamięci ekranu
	mov	rcx,	qword [kernel_video_cursor_indicator]
	sub	rcx,	qword [kernel_video_base_address]
	shr	rcx,	DIVIDE_BY_2_shift	; usuń atrybuty

	; młodszy port kursora (rejestr indeksowy VGA)
	mov	al,	0x0F
	mov	dx,	0x03D4
	out	dx,	al

	inc	dx	; 0x03D5
	mov	al,	cl
	out	dx,	al

	; starszy port kursora
	mov	al,	0x0E
	dec	dx
	out	dx,	al

	inc	dx
	mov	al,	ch
	out	dx,	al

	; przywróć oryginalne rejestry
	pop	rdx
	pop	rcx
	pop	rax

	; powrót z procedury
	ret
