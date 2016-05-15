; Copyright (C) 2013-2016 Wataha.net
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

; zestaw imiennych wartości stałych jądra systemu
%include	'config.asm'

%define	VARIABLE_PROGRAM_NAME		help
%define	VARIABLE_PROGRAM_VERSION	"v0.17"

; 64 Bitowy kod programu
[BITS 64]

; adresowanie względne (skoki, etykiety)
[DEFAULT REL]

; adres kodu programu w przestrzeni logicznej
[ORG VARIABLE_MEMORY_HIGH_REAL_ADDRESS]

start:
	; ustaw wskaźnik na tablice
	mov	rsi,	command_table + VARIABLE_QWORD_SIZE	; pomiń pierwszą wartość

	; pobierz rozmiar komórki 'polecenie'
	mov	r8,	qword [command_table]

	mov	ax,	VARIABLE_KERNEL_SERVICE_SCREEN_PRINT_STRING
	mov	edx,	VARIABLE_COLOR_BACKGROUND_DEFAULT

.loop:
	cmp	qword [rsi],	VARIABLE_EMPTY
	je	.end

	mov	ebx,	VARIABLE_COLOR_DEFAULT
	mov	rcx,	r8
	int	STATIC_KERNEL_SERVICE

	; zachowaj wskaźnik
	push	rsi

	; przesuń wskaźnik na opis polecenia
	mov	rsi,	qword [rsi + r8]

	; wyświetl opis polecenia
	mov	ebx,	VARIABLE_COLOR_GRAY
	mov	rcx,	VARIABLE_FULL
	int	STATIC_KERNEL_SERVICE

	; przywróć wskaźnik
	pop	rsi

	; przesuń wskaźnik na następny rekord
	add	rsi,	r8	; rozmiar komórki 'polecenie'
	add	rsi,	VARIABLE_QWORD_SIZE	; rozmiar wskaźnika do ciągu opisu

	; kontynuuj
	jmp	.loop

.end:
	; wyjdź z programu
	mov	ax,	VARIABLE_KERNEL_SERVICE_PROCESS_KILL
	int	STATIC_KERNEL_SERVICE

command_table:
	dq	7	; rozmiar komórki 'polecenie'

	db	'clear  '
	dq	text_clear

	db	'exit   '
	dq	text_exit

	db	'help   '
	dq	text_help

	db	'ps     '
	dq	text_ps

	; koniec tablicy
	dq	VARIABLE_EMPTY

; wczytaj lokalizacje programu systemu
%push
	%defstr		%$system_locale		VARIABLE_KERNEL_LOCALE
	%defstr		%$process_name		VARIABLE_PROGRAM_NAME
	%strcat		%$include_program_locale,	"software/", %$process_name, "/locale/", %$system_locale, ".asm"
	%include	%$include_program_locale
%pop
