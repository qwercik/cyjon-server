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

%define	VARIABLE_PROGRAM_NAME		httpd
%define	VARIABLE_PROGRAM_VERSION	"v0.3"

VARIABLE_HTTPD_PORT_DEFAULT		equ	80

; 64 Bitowy kod programu
[BITS 64]

; adresowanie względne (skoki, etykiety)
[DEFAULT REL]

; adres kodu programu w przestrzeni logicznej
[ORG VARIABLE_MEMORY_HIGH_REAL_ADDRESS]

start:
	; wyrównaj adres przestrzeni do pełnej strony
	mov	rdi,	end
	call	library_align_address_up_to_page

	; zaalokuj przestrzeń pamięci pod zapytnia od klientów
	mov	ax,	VARIABLE_KERNEL_SERVICE_PROCESS_MEMORY_ALLOCATE
	mov	rcx,	VARIABLE_MEMORY_PAGE_SIZE / VARIABLE_MEMORY_PAGE_SIZE
	int	STATIC_KERNEL_SERVICE

	; zarezerwuj numer portu
	mov	ax,	VARIABLE_KERNEL_SERVICE_NETWORK_PORT_ASSIGN
	mov	rcx,	VARIABLE_HTTPD_PORT_DEFAULT
	int	STATIC_KERNEL_SERVICE

	; sprawdź czy port został przyznany
	cmp	rcx,	VARIABLE_EMPTY
	mov	rsi,	text_port_busy
	je	.error

	; wyświetl informacje o uruchomionym serwerze www
	mov	ax,	VARIABLE_KERNEL_SERVICE_SCREEN_PRINT_STRING
	mov	bl,	VARIABLE_COLOR_DEFAULT
	mov	rcx,	VARIABLE_FULL
	mov	dl,	VARIABLE_COLOR_BACKGROUND_DEFAULT
	mov	rsi,	text_port_start
	int	STATIC_KERNEL_SERVICE

	; numer portu
	mov	ax,	VARIABLE_KERNEL_SERVICE_SCREEN_PRINT_NUMBER
	mov	bl,	VARIABLE_COLOR_LIGHT_GREEN
	mov	cx,	0x000A
	mov	r8,	VARIABLE_HTTPD_PORT_DEFAULT
	int	STATIC_KERNEL_SERVICE

	jmp	$

.port_release:
	; zwolnij numer portu
	mov	ax,	VARIABLE_KERNEL_SERVICE_NETWORK_PORT_RELEASE
	mov	rcx,	VARIABLE_HTTPD_PORT_DEFAULT
	int	STATIC_KERNEL_SERVICE

	; koniec pracy serwera
	jmp	.end

.error:
	mov	rax,	VARIABLE_KERNEL_SERVICE_SCREEN_PRINT_STRING
	mov	bl,	VARIABLE_COLOR_DEFAULT
	mov	rcx,	VARIABLE_FULL
	mov	dl,	VARIABLE_COLOR_BACKGROUND_DEFAULT
	int	STATIC_KERNEL_SERVICE

.end:
	; zakończ proces
	mov	ax,	VARIABLE_KERNEL_SERVICE_PROCESS_END
	int	STATIC_KERNEL_SERVICE

%include	"library/align_address_up_to_page.asm"

; wczytaj lokalizacje programu systemu
%push
	%defstr		%$system_locale		VARIABLE_KERNEL_LOCALE
	%defstr		%$process_name		VARIABLE_PROGRAM_NAME
	%strcat		%$include_program_locale,	"software/", %$process_name, "/locale/", %$system_locale, ".asm"
	%include	%$include_program_locale
%pop

end:
