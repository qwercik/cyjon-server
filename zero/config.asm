;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

; wartości modyfikowalne =======================================================

%define	ZERO_LOCALE			en_US
%define	ZERO_CHARSET			ASCII

; uruchomić jądro systemu w trybie 32 bitowym?
%assign ZERO_PROTECTED_MODE_semaphore	0	; 1-tak, 0-nie
; załadować czcionkę Terminus? (tylko tryb tekstowy 80x25, zaimplementowano wsparcie dla ISO-8859-2)
; wszystkie znaki alfanumeryczne i interpunkcyjne + diakrytyczne pl_PL
%assign ZERO_FONT_CUSTOM_semaphore	0	; 1-tak, 0-nie
; przełącz ekran w tryb graficzny?
%assign	ZERO_VIDEO_MODE_semaphore	1	; 1-tak, 0-nie (tryb tekstowy 80x25, 16 kolorów)

ZERO_VIDEO_MODE_WIDTH_pixel	equ	640	; rozdzielczość X
ZERO_VIDEO_MODE_HEIGHT_pixel	equ	400	; rozdzielczość Y
ZERO_VIDEO_MODE_COLOR_DEPTH_bit	equ	32	; głębia kolorów

; wartości stałe ===============================================================

; tablice przekazywane informacyjnie do jądra systemu po zakończeniu programu rozruchowego
ZERO_MEMORY_MAP_address		equ	0x0500
ZERO_PAGING_address		equ	0x1000
ZERO_SUPERVGA_address		equ	0x7000

ZERO_PAGE_SIZE_byte		equ	4096

ZERO_EMPTY			equ	0x00
ZERO_MAX_UNSIGNED		equ	-1

ZERO_ASCII_TERMINATOR		equ	ZERO_EMPTY
ZERO_ASCII_NEW_LINE		equ	0x0A

ZERO_QWORD_SIZE_byte		equ	8
ZERO_DWORD_SIZE_byte		equ	4
ZERO_WORD_SIZE_byte		equ	2

struc	ZERO_STRUCTURE_VGA_INFO_BLOCK
	.VESASignature		resb	4
	.VESAVersion		resb	2
	.OEMStringPtr		resb	4
	.Capabilities		resb	4
	.VideoModePtr		resb	4
	.TotalMemory		resb	2
	.Reserved		resb	236
	.SIZE:
endstruc

struc	ZERO_STRUCTURE_MODE_INFO_BLOCK
	.ModeAttributes		resb	2
	.WinAAttributes		resb	1
	.WinBAttributes		resb	1
	.WinGranularity		resb	2
	.WinSize		resb	2
	.WinASegment		resb	2
	.WinBSegment		resb	2
	.WinFuncPtr		resb	4
	.BytesPerScanLine	resb	2
	.XResolution		resb	2
	.YResolution		resb	2
	.XCharSize		resb	1
	.YCharSize		resb	1
	.NumberOfPlanes		resb	1
	.BitsPerPixel		resb	1
	.NumberOfBanks		resb	1
	.MemoryModel		resb	1
	.BankSize		resb	1
	.NumberOfImagePages	resb	1
	.Reserved		resb	1
	.RedMaskSize		resb	1
	.RedFieldPosition	resb	1
	.GreenMaskSize		resb	1
	.GreenFieldPosition	resb	1
	.BlueMaskSize		resb	1
	.BlueFieldPosition	resb	1
	.RsvdMaskSize		resb	2
	.DirectColorModeInfo	resb	1
	.PhysicalVideoAddress	resb	4
endstruc
