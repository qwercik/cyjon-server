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

%define	VARIABLE_PROGRAM_NAME		ip
%define	VARIABLE_PROGRAM_VERSION	"v0.1"

; 64 Bitowy kod programu
[BITS 64]

; adresowanie względne (skoki, etykiety)
[DEFAULT REL]

; adres kodu programu w przestrzeni logicznej
[ORG VARIABLE_MEMORY_HIGH_REAL_ADDRESS]

start:
	; pobierz przesłane argumenty
	mov	ax,	VARIABLE_KERNEL_SERVICE_PROCESS_ARGS
	mov	rdi,	end
	call	library_align_address_up_to_page
	int	STATIC_KERNEL_SERVICE

	; czy arguymenty istnieją?
	cmp	rcx,	0x02
	ja	.no_option

	; cdn.

.no_option:
	; pobierz adres IP
	mov	ax,	VARIABLE_KERNEL_SERVICE_NETWORK_IP_GET
	int	STATIC_KERNEL_SERVICE

	; sparwdź czy karta sieciowa ma ustawiony adres IP
	cmp	rbx,	VARIABLE_EMPTY
	je	.end

	; zapamiętaj
	mov	r10,	rbx

	; domyślny kolor tekstu
	mov	bl,	VARIABLE_COLOR_DEFAULT
	; liczby wyświetlaj w systemie dziesiętnym bez prefiksu
	mov	cx,	0x000A
	; domyślny kolor tła
	mov	dl,	VARIABLE_COLOR_BACKGROUND_DEFAULT
	; separator liczb
	mov	rsi,	text_dot
	; ilość liczb w adresie IP
	mov	r9,	4

.loop:
	; wyświetl adres IP
	mov	ax,	VARIABLE_KERNEL_SERVICE_SCREEN_PRINT_NUMBER
	mov	r8b,	r10b
	int	STATIC_KERNEL_SERVICE

	; wyświelono liczbę, koniec?
	dec	r9
	cmp	r9,	VARIABLE_EMPTY
	je	.end

	; wyświetl separator
	mov	ax,	VARIABLE_KERNEL_SERVICE_SCREEN_PRINT_STRING
	int	STATIC_KERNEL_SERVICE

	; następna liczba z adresu IP
	shr	r10,	8

	; kontynuuj
	jmp	.loop

.end:
	; koniec działania procesu
	mov	ax,	VARIABLE_KERNEL_SERVICE_PROCESS_KILL
	int	STATIC_KERNEL_SERVICE

%include	"library/align_address_up_to_page.asm"

text_dot	db	".", VARIABLE_ASCII_CODE_TERMINATOR

end:
