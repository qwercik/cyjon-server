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

VARIABLE_MULTIBOOT_HEADER_ALIGN		equ	1<<0
VARIABLE_MULTIBOOT_HEADER_MEMORY_INFO	equ	1<<1	; zwróć mapę pamięci
VARIABLE_MULTIBOOT_HEADER_NO_ELF	equ	1<<16	; jądro systemu jest binarką
VARIABLE_MULTIBOOT_HEADER_FLAGS		equ	VARIABLE_MULTIBOOT_HEADER_ALIGN | VARIABLE_MULTIBOOT_HEADER_MEMORY_INFO | VARIABLE_MULTIBOOT_HEADER_NO_ELF
VARIABLE_MULTIBOOT_HEADER_MAGIC		equ	0x1BADB002
VARIABLE_MULTIBOOT_HEADER_CHECKSUM	equ	0x100000000 - ( VARIABLE_MULTIBOOT_HEADER_MAGIC + VARIABLE_MULTIBOOT_HEADER_FLAGS )

; rozpocznij tablicę Multiboot od pełnego adresu 32 bitowego
align	0x04

multiboot_header:
	dd	VARIABLE_MULTIBOOT_HEADER_MAGIC
	dd	VARIABLE_MULTIBOOT_HEADER_FLAGS
	dd	VARIABLE_MULTIBOOT_HEADER_CHECKSUM

	dd	multiboot_header
	dd	VARIABLE_KERNEL_PHYSICAL_ADDRESS
	dd	VARIABLE_EMPTY
	dd	VARIABLE_EMPTY
	dd	entry
