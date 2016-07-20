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

%define	VARIABLE_PROGRAM_NAME			x
%define	VARIABLE_PROGRAM_VERSION		"v0.1"

VARIABLE_PROGRAM_COLOR_BACKGROUND_DEFAULT	equ	0x003A6EA5

; 64 Bitowy kod programu
[BITS 64]

; adresowanie względne (skoki, etykiety)
[DEFAULT REL]

; adres kodu programu w przestrzeni logicznej
[ORG VARIABLE_MEMORY_HIGH_REAL_ADDRESS]

start:
	; wyczyść ekran na domyślny kolor
	mov	ax,	VARIABLE_KERNEL_SERVICE_VIDEO_SCREEN_CLEAR
	mov	rdx,	VARIABLE_PROGRAM_COLOR_BACKGROUND_DEFAULT
	int	STATIC_KERNEL_SERVICE

	; koniec procesu
	xor	ax,	ax
	int	STATIC_KERNEL_SERVICE
