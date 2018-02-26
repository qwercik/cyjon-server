;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

;===============================================================================
kernel_video_string:
	; zachowaj oryginalne rejestry
	push	rax
	push	rcx
	push	rsi

.loop:
	; koniec ciągu?
	dec	rcx
	js	.end	; tak

	; koniec ciągu? (rozpoznano TERMINATOR)
	cmp	byte [rsi],	ASCII_TERMINATOR
	je	.end	; tak

	; pobierz znak z ciągu
	xor	eax,	eax
	lodsb

	; wyświetl znak
	call	kernel_video_char

	; wyświetl pozostałe znaki z ciągu
	jmp	.loop

.end:
	; przywróć oryginalne rejestry
	pop	rsi
	pop	rcx
	pop	rax

	; powrót z procedury
	ret

;===============================================================================
; wejście:
;	rax - kod ASCII znaku
kernel_video_char:
	; zachowaj oryginalne rejestry
	push	rax
	push	rdi
	push	r8
	push	r9

	; pobierz właściwości wirtualnego kursora
	mov	rdi,	qword [kernel_video_cursor_indicator]
	mov	r8,	qword [kernel_video_cursor_x]
	mov	r9,	qword [kernel_video_cursor_y]

	; znak nowej linii?
	cmp	ax,	ASCII_NEW_LINE
	je	.new_line	; tak

	; znak backspace?
	cmp	ax,	ASCII_BACKSPACE
	je	.backspace	; tak

	; wyświetl matrycę znaku na ekran
	call	kernel_video_char_matrix

	; wirtualny kursor przemieszczono w prawo
	add	rdi,	KERNEL_FONT_WIDTH_pixel << KERNEL_VIDEO_COLOR_DEPTH_shift
	inc	r8

	; koniec wiersza?
	cmp	r8,	qword [kernel_video_width_char]
	jne	.end	; nie, koniec

	; koryguj pozycje kursora
	sub	rdi,	qword [kernel_video_width_byte]
	add	rdi,	qword [kernel_video_scanline_char_byte]

.column:
	; kursor przemieścił się na początek nowej linii
	xor	r8d,	r8d	; pozycja X
	inc	r9	; pozycja Y

	; kursor znajduje się poza ekranem?
	cmp	r9,	qword [kernel_video_height_char]
	jne	.end	; nie, koniec

	; koryguj pozycje kursora
	sub	rdi,	qword [kernel_video_scanline_char_byte]
	dec	r9	; pozycja Y

	; przewiń zawartość ekranu o linię w górę
	call	kernel_video_scroll

	; koniec
	jmp	.end

.new_line:
	; cofnij wskaźnik na początek nowej linii
	mov	rax,	KERNEL_FONT_WIDTH_pixel << KERNEL_VIDEO_COLOR_DEPTH_shift
	mul	r8	; ilość znaków w aktualnej linii
	sub	rdi,	rax	; cofnij wskaźnik
	add	rdi,	qword [kernel_video_scanline_char_byte]

	; kontynuuj
	jmp	.column

.backspace:
	; kursor na początku wiersza?
	cmp	r8,	EMPTY
	je	.return

	; koryguj pozycje wskaźnika i kursora
	sub	rdi,	KERNEL_FONT_WIDTH_pixel << KERNEL_VIDEO_COLOR_DEPTH_shift
	dec	r8

	; wyczyść pozycję znaku
	jmp	.clean

.return:
	; kusor w pierwszym wierszu?
	cmp	r9,	EMPTY
	je	.end	; tak

	; cofnij kursor o wiersz
	dec	r9

	; cofnij wskaźnik kursora o znak
	mov	rax,	qword [kernel_video_char_width_byte]
	mov	r8,	qword [kernel_video_width_char]
	dec	r8
	mul	r8
	add	rdi,	rax
	sub	rdi,	qword [kernel_video_scanline_char_byte]

.clean:
	; wyczyść pozycję znaku spacją
	mov	eax,	ASCII_SPACE
	call	kernel_video_char_matrix

.end:
	; zachowaj nowe właściwości kursora
	mov	qword [kernel_video_cursor_indicator],	rdi
	mov	qword [kernel_video_cursor_x],	r8
	mov	qword [kernel_video_cursor_y],	r9

	; przywróć oryginalne rejestry
	pop	r8
	pop	r9
	pop	rdi
	pop	rax

	; powrót z procedury
	ret

;===============================================================================
; wejście:
;	rax - kod ASCII znaku
;	rdi - pozycja znaku w przestrzeni pamięci ekranu
kernel_video_char_matrix:
	; zachowaj oryginalne rejestry
	push	rax
	push	rbx
	push	rcx
	push	rdx
	push	rsi
	push	rdi

	; wysokość matrycy znaku w pikselach
	mov	bl,	KERNEL_FONT_HEIGHT_pixel

	; oblicz przesunięcie względem początku tablicy ASCII
	mul	rbx

	; ustaw wskaźnik na matrycę znaku
	mov	rsi,	kernel_font_matrix
	add	rsi,	rax

	; kolor znaku i tła
	mov	rdx,	qword [kernel_video_font_color]

	; pobierz rozmiar scanline ekranu
	mov	rbp,	qword [kernel_video_scanline_byte]

.next:
	; szerokość matrycy znaku liczona od zera
	mov	cx,	KERNEL_FONT_WIDTH_pixel - 0x01

.loop:
	; piksel matrycy "zapalony"?
	bt	word [rsi],	cx
	jnc	.unset	; nie

	; wyświetl piksel o zdefiniowanym kolorze znaku
	mov	eax,	edx
	stosd

	; kontynuuj
	jmp	.continue

.unset:
	; wyświetl piksel o zdefiniowanym kolorze tła
	mov	rax,	rdx
	shr	rax,	MOVE_HIGH_TO_EAX
	stosd

.continue:
	; następny piksel z linii matrycy znaku
	dec	cl
	jns	.loop

	; przesuń wskaźnik na następną linię matrycy na ekranie
	sub	rdi,	KERNEL_FONT_WIDTH_pixel << KERNEL_VIDEO_COLOR_DEPTH_shift	; cofnij o szerokość znaku w Bajtach
	add	rdi,	rbp	; przesuń do przodu o rozmiar scanline ekranu

	; przesuń wskaźnik na następną linię matrycy znaku
	inc	rsi

	; przetworzono całą matrycę znaku?
	dec	bl
	jnz	.next	; nie, następna linia matrycy znaku

	; przywróć oryginalne rejestry
	pop	rdi
	pop	rsi
	pop	rdx
	pop	rcx
	pop	rbx
	pop	rax

	; powrót z procedury
	ret

;===============================================================================
kernel_video_cursor:


	; powrót z procedury
	ret

;===============================================================================
kernel_video_scroll:
	; zachowaj oryginalne rejestry
	push	rax
	push	rcx
	push	rdx
	push	rsi
	push	rdi

	; rozmiar przemieszczanej przestrzeni
	mov	rax,	qword [kernel_video_scanline_char_byte]
	mul	qword [kernel_video_height_char]

	; ostatnia linia jest pusta
	sub	rax,	qword [kernel_video_scanline_char_byte]

	; rozpocznij przewijanie od linii 1 do 0
	mov	rdi,	qword [kernel_video_base_address]
	mov	rsi,	rdi
	add	rsi,	qword [kernel_video_scanline_char_byte]

	; wykonaj
	mov	rcx,	rax
	shr	rcx,	KERNEL_VIDEO_COLOR_DEPTH_shift
	rep	movsd

	; wyczyść ostatnią linię
	mov	eax,	dword [kernel_video_font_color + DWORD_SIZE_byte]
	mov	rcx,	qword [kernel_video_scanline_char_byte]
	shr	rcx,	KERNEL_VIDEO_COLOR_DEPTH_shift
	rep	stosd

	; przywróć oryginalne rejestry
	pop	rdi
	pop	rsi
	pop	rdx
	pop	rcx
	pop	rax

	; powrót z procedury
	ret
