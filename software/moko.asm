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

%include	"config.asm"

%define	VARIABLE_PROGRAM_VERSION		""

VARIABLE_CURSOR_POSITION_INIT		equ	0x0000000200000000
VARIABLE_INTERFACE_HEADER_HEIGHT	equ	2
VARIABLE_INTERFACE_MENU_HEIGHT		equ	3
VARIABLE_INTERFACE_HEIGHT		equ	VARIABLE_INTERFACE_HEADER_HEIGHT + VARIABLE_INTERFACE_MENU_HEIGHT

[BITS 64]
[DEFAULT REL]
[ORG VARIABLE_MEMORY_HIGH_REAL_ADDRESS]

start:
	; przygotowanie przestrzeni pod dokument i interfejsu
	call	initialization

.noKey:
	; pobierz znak z bufora klawiatury
	mov	ax,	0x0200
	int	0x40	; wykonaj

	cmp	ax,	VARIABLE_EMPTY	
	je	.noKey

	cmp	ax,	VARIABLE_ASCII_CODE_ENTER
	je	key_enter

	cmp	ax,	0x8002
	je	key_arrow_left

	cmp	ax,	0x8003
	je	key_arrow_right

	; sprawdź czy znak jest możliwy do wyświetlenia ------------------------

	; test pierwszy
	cmp	ax,	VARIABLE_ASCII_CODE_SPACE	; pierwszy znak z tablicy ASCII
	jb	.noKey	; jeśli mniejsze, pomiń

	; test drugi
	cmp	ax,	0x007E	; ostatni znak z tablicy ASCII
	ja	.noKey	; jeśli większe, pomiń

	; zapisz znak do dokumentu
	call	save_into_document

	inc	qword [variable_document_count_of_chars]
	inc	qword [variable_line_count_of_chars]
	inc	qword [variable_cursor_indicator]
	inc	dword [variable_cursor_position]
	inc	qword [variable_cursor_position_on_line]

	call	check_cursor
	call	update_line_on_screen

	jmp	start.noKey

%include	"software/moko/init.asm"

%include	"software/moko/key_enter.asm"
%include	"software/moko/key_arrow_left.asm"
%include	"software/moko/key_arrow_right.asm"

%include	"software/moko/save_into_document.asm"
%include	"software/moko/update_line_on_screen.asm"
%include	"software/moko/check_cursor.asm"
%include	"software/moko/count_chars_in_line.asm"
%include	"software/moko/count_chars_in_previous_line.asm"

%include	"library/align_address_up_to_page.asm"

variable_document_address_start			dq	VARIABLE_EMPTY
variable_document_address_end			dq	VARIABLE_EMPTY
variable_document_count_of_chars		dq	VARIABLE_EMPTY
variable_document_line_start			dq	VARIABLE_EMPTY
variable_line_count_of_chars			dq	VARIABLE_EMPTY
variable_line_print_start			dq	VARIABLE_EMPTY
variable_cursor_indicator			dq	VARIABLE_EMPTY
variable_cursor_position			dq	VARIABLE_CURSOR_POSITION_INIT
variable_cursor_position_on_line		dq	VARIABLE_EMPTY
variable_screen_size				dq	VARIABLE_EMPTY

variable_file_name_count_of_chars		dq	VARIABLE_EMPTY
variable_file_name_buffor	times	256	db	VARIABLE_EMPTY

text_header_default	db	"New file", VARIABLE_ASCII_CODE_TERMINATOR

text_exit_shortcut	db	'^x', 0x00
text_exit		db	' Exit  ', 0x00

stop:
