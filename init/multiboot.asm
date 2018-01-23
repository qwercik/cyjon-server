;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

; wartość, którą program rozruchowy poszukuje w pliku jądra systemu
; tym samym określając typ nagłówka multiboot
STATIC_MULTIBOOT_HEADER_MAGIC			equ	0x1BADB002	; nagłówek multiboot, wersja 1.x
; zwróć do jądra systemu informacje o:
STATIC_MULTIBOOT_HEADER_FLAG_MEMORY_MAP		equ	1 << 1	; dostępnych przestrzeniach pamięci RAM
STATIC_MULTIBOOT_HEADER_FLAG_VIDEO		equ	1 << 2	; właściwościach trybu graficznego
STATIC_MULTIBOOT_HEADER_FLAG_NO_ELF		equ	1 << 16	; poinformuj program rozruchowy o formacie pliku jądra systemu
STATIC_MULTIBOOT_HEADER_CHECKSUM		equ	0x100000000 - ( STATIC_MULTIBOOT_HEADER_MAGIC + STATIC_MULTIBOOT_HEADER_FLAG_MEMORY_MAP + STATIC_MULTIBOOT_HEADER_FLAG_VIDEO + STATIC_MULTIBOOT_HEADER_FLAG_NO_ELF )

; poproś program rozruchowy o ustawienie trybu graficznego o podanych parametrach
STATIC_MULTIBOOT_HEADER_VIDEO_MODE_TYPE		equ	STATIC_EMPTY		; tryb graficzny - liniowy
STATIC_MULTIBOOT_HEADER_VIDEO_MODE_WIDTH	equ	STATIC_VIDEO_WIDTH	; szerokość
STATIC_MULTIBOOT_HEADER_VIDEO_MODE_HEIGHT	equ	STATIC_VIDEO_HEIGHT	; wysokość
STATIC_MULTIBOOT_HEADER_VIDEO_MODE_DEPTH	equ	STATIC_VIDEO_DEPTH	; głębia kolorów

struc	STATIC_STRUCTURE_MULTIBOOT_HEADER
	.magic			resd	1
	.flags			resd	1
	.checksum		resd	1
	.header_address		resd	1
	.kernel_address		resd	1
	.unused_by_me		resd	2
	.kernel_entry		resd	1
	.video_mode_type	resd	1
	.video_mode_width	resd	1
	.video_mode_height	resd	1
	.video_mode_depth	resd	1
	.SIZE:
endstruc

.table_multiboot_header:
	; tablica nagłówka multiboot w wersji 1.x
	dd	STATIC_MULTIBOOT_HEADER_MAGIC
	dd	STATIC_MULTIBOOT_FLAG_MEMORY_MAP + STATIC_MULTIBOOT_FLAG_VIDEO + STATIC_MULTIBOOT_FLAG_NO_ELF
	dd	STATIC_MULTIBOOT_HEADER_CHECKSUM
	; informacje o jądrze systemu (pozycje w przestrzeni pamięci fizycznej, procedury wejściowe)
	dd	.table_multiboot_header
	dd	STATIC_KERNEL_BASE_ADDRESS
	dd	STATIC_EMPTY
	dd	STATIC_EMPTY
	dd	kernel_entry
	; informacje o trybie graficznym
	dd	STATIC_MULTIBOOT_HEADER_VIDEO_MODE_TYPE
	dd	STATIC_MULTIBOOT_HEADER_VIDEO_MODE_WIDTH
	dd	STATIC_MULTIBOOT_HEADER_VIDEO_MODE_HEIGHT
	dd	STATIC_MULTIBOOT_HEADER_VIDEO_MODE_DEPTH
