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

%define	VARIABLE_KERNEL_VERSION			"0.477"

VARIABLE_MEMORY_PAGE_SIZE			equ	0x1000
VARIABLE_MEMORY_HIGH_ADDRESS			equ	0xFFFF000000000000
VARIABLE_MEMORY_HIGH_REAL_ADDRESS		equ	0xFFFF800000000000
VARIABLE_MEMORY_HIGH_VIRTUAL_ADDRESS		equ	VARIABLE_MEMORY_HIGH_REAL_ADDRESS - VARIABLE_MEMORY_HIGH_ADDRESS
VARIABLE_MEMORY_PML4_RECORD_SIZE		equ	VARIABLE_MEMORY_HIGH_VIRTUAL_ADDRESS / 256
; adres umowny, jest to przestrzeń gdzie jądro systemu może operować na
; różnej wielkości fragmentach pamięci logicznej, gdzie pamięć fizyczna
; nie sięga
VARIABLE_MEMORY_FREE_LOGICAL_ADDRESS		equ	0x0000400000000000

VARIABLE_ASCII_CODE_TERMINATOR			equ	0x00
VARIABLE_ASCII_CODE_ENTER			equ	0x0D
VARIABLE_ASCII_CODE_NEWLINE			equ	0x0A
VARIABLE_ASCII_CODE_BACKSPACE			equ	0x08
VARIABLE_ASCII_CODE_SPACE			equ	0x20
VARIABLE_ASCII_CODE_TILDE			equ	0x7E
VARIABLE_ASCII_CODE_DELETE			equ	0x7F

VARIABLE_COLOR_BLACK				equ	0	; indeks
VARIABLE_COLOR_BLUE				equ	1
VARIABLE_COLOR_GREEN				equ	2
VARIABLE_COLOR_CYAN				equ	3
VARIABLE_COLOR_RED				equ	4
VARIABLE_COLOR_VIOLET				equ	5
VARIABLE_COLOR_BROWN				equ	6
VARIABLE_COLOR_LIGHT_GRAY			equ	7
VARIABLE_COLOR_GRAY				equ	8
VARIABLE_COLOR_LIGHT_BLUE			equ	9
VARIABLE_COLOR_LIGHT_GREEN			equ	10
VARIABLE_COLOR_LIGHT_CYAN			equ	11
VARIABLE_COLOR_LIGHT_RED			equ	12
VARIABLE_COLOR_LIGHT_VIOLET			equ	13
VARIABLE_COLOR_YELLOW				equ	14
VARIABLE_COLOR_WHITE				equ	15

VARIABLE_COLOR_DEFAULT				equ	VARIABLE_COLOR_LIGHT_GRAY
VARIABLE_COLOR_BACKGROUND_DEFAULT		equ	VARIABLE_COLOR_BLACK

%define	VARIABLE_FONT_MATRIX_DEFAULT		"font/wataha.asm"

VARIABLE_PCI_CONFIG_ADDRESS			equ	0x0CF8
VARIABLE_PCI_CONFIG_DATA			equ	0x0CFC

VARIABLE_PIT_CLOCK_HZ				equ	1000	; Hz

VARIABLE_KEYBOARD_CACHE_SIZE			equ	16	; / 2 = 8 znaków

VARIABLE_PROCESS_LIMIT				equ	256

VARIABLE_EMPTY					equ	0
VARIABLE_FULL					equ	-1

VARIABLE_TRUE					equ	1
VARIABLE_FALSE					equ	0

VARIABLE_INCREMENT				equ	1
VARIABLE_DECREMENT				equ	1

VARIABLE_DISK_SECTOR_SIZE			equ	9	; przesunięcie logiczne w lewo wartości 2

VARIABLE_CMOS_PORT_IN				equ	0x71
VARIABLE_CMOS_PORT_OUT				equ	0x70

VARIABLE_KERNEL_PHYSICAL_ADDRESS		equ	0x0000000000100000
VARIABLE_KERNEL_STACK_ADDRESS			equ	VARIABLE_MEMORY_HIGH_VIRTUAL_ADDRESS - 0x1000

VARIABLE_KERNEL_SERVICE_PROCESS_KILL		equ	0x0000
VARIABLE_KERNEL_SERVICE_PROCESS_NEW		equ	0x0001
VARIABLE_KERNEL_SERVICE_PROCESS_CHECK		equ	0x0002
VARIABLE_KERNEL_SERVICE_PROCESS_MEMORY_ALLOCATE	equ	0x0003
VARIABLE_KERNEL_SERVICE_PROCESS_LIST		equ	0x0004

VARIABLE_KERNEL_SERVICE_SCREEN_CLEAN		equ	0x0100
VARIABLE_KERNEL_SERVICE_SCREEN_PRINT_STRING	equ	0x0101
VARIABLE_KERNEL_SERVICE_SCREEN_PRINT_CHAR	equ	0x0102
VARIABLE_KERNEL_SERVICE_SCREEN_PRINT_NUMBER	equ	0x0103
VARIABLE_KERNEL_SERVICE_SCREEN_CURSOR_GET	equ	0x0104
VARIABLE_KERNEL_SERVICE_SCREEN_CURSOR_SET	equ	0x0105
VARIABLE_KERNEL_SERVICE_SCREEN_SIZE		equ	0x0106
VARIABLE_KERNEL_SERVICE_SCREEN_CURSOR_HIDE	equ	0x0107
VARIABLE_KERNEL_SERVICE_SCREEN_CURSOR_SHOW	equ	0x0108
VARIABLE_KERNEL_SERVICE_SCREEN_SCROLL		equ	0x0109

VARIABLE_KERNEL_SERVICE_KEYBOARD_GET		equ	0x0200

VARIABLE_KERNEL_SERVICE_SYSTEM_UPTIME		equ	0x0300
VARIABLE_KERNEL_SERVICE_SYSTEM_DATE		equ	0x0301
