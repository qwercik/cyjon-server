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

%define	VARIABLE_PROGRAM_NAME		free
%define	VARIABLE_PROGRAM_VERSION	"v0.6"

; 64 Bitowy kod programu
[BITS 64]

; adresowanie względne (skoki, etykiety)
[DEFAULT REL]

; adres kodu programu w przestrzeni logicznej
[ORG VARIABLE_MEMORY_HIGH_REAL_ADDRESS]

start:
	mov	ax,	VARIABLE_KERNEL_SERVICE_SCREEN_PRINT_STRING
	mov	ebx,	VARIABLE_COLOR_DEFAULT
	mov	ecx,	VARIABLE_FULL
	mov	edx,	VARIABLE_COLOR_BACKGROUND_DEFAULT
	mov	rsi,	text_header
	int	STATIC_KERNEL_SERVICE

	mov	ax,	VARIABLE_KERNEL_SERVICE_SYSTEM_MEMORY
	int	STATIC_KERNEL_SERVICE

	mov	ax,	VARIABLE_KERNEL_SERVICE_SCREEN_PRINT_NUMBER
	mov	ecx,	10	; system dziesiętny
	mov	r8,	r11
	shl	r8,	2	; *4 KiB
	mov	ebx,	VARIABLE_COLOR_DEFAULT
	mov	edx,	VARIABLE_COLOR_BACKGROUND_DEFAULT
	int	STATIC_KERNEL_SERVICE

	mov	ax,	VARIABLE_KERNEL_SERVICE_SCREEN_PRINT_STRING
	mov	ebx,	VARIABLE_COLOR_DEFAULT
	mov	rsi,	text_kib
	int	STATIC_KERNEL_SERVICE

	mov	ax,	VARIABLE_KERNEL_SERVICE_SCREEN_CURSOR_GET
	int	STATIC_KERNEL_SERVICE

	push	rbx

	mov	dword [rsp],	22	; 'used' column
	mov	rbx,	qword [rsp]

	mov	ax,	VARIABLE_KERNEL_SERVICE_SCREEN_CURSOR_SET
	int	STATIC_KERNEL_SERVICE

	mov	ax,	VARIABLE_KERNEL_SERVICE_SCREEN_PRINT_NUMBER
	mov	r8,	r11
	sub	r8,	r12
	shl	r8,	2	; *4 KiB
	mov	ebx,	VARIABLE_COLOR_DEFAULT
	int	STATIC_KERNEL_SERVICE

	mov	ax,	VARIABLE_KERNEL_SERVICE_SCREEN_PRINT_STRING
	mov	ebx,	VARIABLE_COLOR_DEFAULT
	mov	rsi,	text_kib
	int	STATIC_KERNEL_SERVICE

	mov	dword [rsp],	36	; 'free' column
	mov	rbx,	qword [rsp]

	mov	ax,	VARIABLE_KERNEL_SERVICE_SCREEN_CURSOR_SET
	int	STATIC_KERNEL_SERVICE

	mov	ax,	VARIABLE_KERNEL_SERVICE_SCREEN_PRINT_NUMBER
	mov	r8,	r12
	shl	r8,	2	; *4 KiB
	mov	ebx,	VARIABLE_COLOR_DEFAULT
	int	STATIC_KERNEL_SERVICE

	mov	ax,	VARIABLE_KERNEL_SERVICE_SCREEN_PRINT_STRING
	mov	ebx,	VARIABLE_COLOR_DEFAULT
	mov	rsi,	text_kib
	int	STATIC_KERNEL_SERVICE

	mov	dword [rsp],	50	; 'cached' column
	mov	rbx,	qword [rsp]

	mov	ax,	VARIABLE_KERNEL_SERVICE_SCREEN_CURSOR_SET
	int	STATIC_KERNEL_SERVICE

	mov	ax,	VARIABLE_KERNEL_SERVICE_SCREEN_PRINT_NUMBER
	mov	r8,	r14
	shl	r8,	2	; *4 KiB
	mov	ebx,	VARIABLE_COLOR_DEFAULT
	int	STATIC_KERNEL_SERVICE

	mov	ax,	VARIABLE_KERNEL_SERVICE_SCREEN_PRINT_STRING
	mov	ebx,	VARIABLE_COLOR_DEFAULT
	mov	rsi,	text_kib
	int	STATIC_KERNEL_SERVICE

	mov	dword [rsp],	64	; 'paged' column
	mov	rbx,	qword [rsp]

	mov	ax,	VARIABLE_KERNEL_SERVICE_SCREEN_CURSOR_SET
	int	STATIC_KERNEL_SERVICE

	mov	ax,	VARIABLE_KERNEL_SERVICE_SCREEN_PRINT_NUMBER
	mov	r8,	r15
	shl	r8,	2	; *4 KiB
	mov	ebx,	VARIABLE_COLOR_DEFAULT
	int	STATIC_KERNEL_SERVICE

	mov	ax,	VARIABLE_KERNEL_SERVICE_SCREEN_PRINT_STRING
	mov	ebx,	VARIABLE_COLOR_DEFAULT
	mov	rsi,	text_kib
	int	STATIC_KERNEL_SERVICE

	mov	rsi,	text_paragraph
	int	STATIC_KERNEL_SERVICE

	mov	ax,	VARIABLE_KERNEL_SERVICE_PROCESS_END
	int	STATIC_KERNEL_SERVICE

; wczytaj lokalizacje programu systemu
%push
	%defstr		%$system_locale		VARIABLE_KERNEL_LOCALE
	%defstr		%$process_name		VARIABLE_PROGRAM_NAME
	%strcat		%$include_program_locale,	"software/", %$process_name, "/locale/", %$system_locale, ".asm"
	%include	%$include_program_locale
%pop

text_kib	db	" KiB", VARIABLE_ASCII_CODE_TERMINATOR
text_paragraph	db	VARIABLE_ASCII_CODE_RETURN
