; Copyright (C) 2013-2015 Wataha.net
; All Rights Reserved
;
; LICENSE Creative Commons BY-NC-ND 4.0
; See LICENSE.TXT
;
; Main developer:
;	Andrzej (akasei) Adamczyk [e-mail: akasei from wataha.net]
;-------------------------------------------------------------------------------

; Use:
; nasm - http://www.nasm.us/

; 64 Bitowy kod programu
[BITS 64]

key_enter:
	; załaduj znak nowej linii
	mov	ax,	VARIABLE_ASCII_CODE_NEWLINE
	call	save_into_document

	add	qword [variable_document_count_of_chars],	0x01

	; aktualizuj nowy rozmiar aktualnej linii
	mov	rax,	qword [variable_cursor_position_on_line]
	mov	qword [variable_line_count_of_chars],	rax

	; wyświetl aktualną linię od początku
	sub	qword [variable_cursor_indicator],	rax
	mov	qword [variable_cursor_position_on_line],	VARIABLE_EMPTY
	mov	qword [variable_line_print_start],	VARIABLE_EMPTY

	call	update_line_on_screen

	mov	dword [variable_cursor_position],	VARIABLE_EMPTY

	; utwórz miejsce na ekranie dokumentu dla nowej linii

	mov	ecx,	dword [variable_screen_size + 0x04]
	sub	ecx,	VARIABLE_INTERFACE_MENU_HEIGHT
	sub	ecx,	1
	mov	ebx,	dword [variable_cursor_position + 0x04]
	cmp	ebx,	ecx
	je	.scroll_up

	; scroll down
	mov	ax,	0x0109
	mov	bl,	VARIABLE_FALSE	 ; w dół
	mov	ecx,	dword [variable_screen_size + 0x04]
	sub	ecx,	dword [variable_cursor_position + 0x04]
	sub	ecx,	VARIABLE_INTERFACE_HEIGHT - VARIABLE_DECREMENT
	mov	edx,	dword [variable_cursor_position + 0x04]
	add	edx,	VARIABLE_INTERFACE_HEADER_HEIGHT
	int	0x40

	add	dword [variable_cursor_position + 0x04],	0x01

	jmp	.show_new_line

.scroll_up:
	mov	ax,	0x0109
	mov	bl,	VARIABLE_TRUE	; w górę
	mov	ecx,	dword [variable_screen_size + 0x04]
	sub	rcx,	VARIABLE_INTERFACE_HEIGHT - 1
	mov	rdx,	VARIABLE_INTERFACE_HEADER_HEIGHT + 1
	int	0x40

	add	qword [variable_document_line_start],	0x01

.show_new_line:
	; pomiń znak nowej linii
	xchg	rdi,	rsi
	call	count_chars_in_line

	mov	qword [variable_cursor_indicator],	rsi
	mov	qword [variable_line_count_of_chars],	rcx
	mov	qword [variable_cursor_position_on_line],	VARIABLE_EMPTY
	call	update_line_on_screen

	jmp	start.noKey
