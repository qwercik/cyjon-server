; Copyright (C) 2013-2025 Wataha.net
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

%define VARIABLE_KERNEL_NAME			Cyjon
%define	VARIABLE_KERNEL_VERSION			"0.674"

; dostępne lokalizacje: en_US.ASCII, pl_PL.ASCII
%define	VARIABLE_KERNEL_LOCALE			en_US.ASCII

VARIABLE_KERNEL_MODE_32BIT			equ	0x20
VARIABLE_KERNEL_MODE_64BIT			equ	0x40
VARIABLE_SELECTOR_TYPE_PROCESS			equ	0x0003
VARIABLE_KERNEL_CS_SELECTOR			equ	0x0008
VARIABLE_KERNEL_DS_SELECTOR			equ	0x0010
VARIABLE_PROCESS_CS_SELECTOR			equ	0x0018
VARIABLE_PROCESS_DS_SELECTOR			equ	0x0020

VARIABLE_EFLAGS_IF				equ	0x00000200	; przerwania włączone

; adres tablic stronicowania w czasie inicjalizacji jądra systemu
VARIABLE_MEMORY_PAGING_ADDRESS			equ	0x00010000
VARIABLE_MEMORY_PAGE_SIZE			equ	0x1000
VARIABLE_MEMORY_PAGE_SIZE_IN_BITS		equ	12
VARIABLE_MEMORY_PAGE_RECORD_COUNT		equ	512
VARIABLE_MEMORY_PAGE_ALIGN			equ	0xF000
VARIABLE_MEMORY_HIGH_ADDRESS			equ	0xFFFF000000000000
VARIABLE_MEMORY_HIGH_REAL_ADDRESS		equ	0xFFFF800000000000
VARIABLE_MEMORY_HIGH_VIRTUAL_ADDRESS		equ	VARIABLE_MEMORY_HIGH_REAL_ADDRESS - VARIABLE_MEMORY_HIGH_ADDRESS
VARIABLE_MEMORY_PML4_RECORD_SIZE		equ	VARIABLE_MEMORY_HIGH_VIRTUAL_ADDRESS / 256
; adres umowny, jest to przestrzeń gdzie jądro systemu może operować na
; różnej wielkości fragmentach pamięci logicznej, gdzie pamięć fizyczna
; nie sięga
VARIABLE_MEMORY_FREE_LOGICAL_ADDRESS		equ	0x0000400000000000

VARIABLE_MEMORY_PAGE_FLAG_AVAILABLE		equ	0x01
VARIABLE_MEMORY_PAGE_FLAG_WRITE			equ	0x02
VARIABLE_MEMORY_PAGE_FLAG_USER			equ	0x04

VARIABLE_ASCII_CODE_TERMINATOR			equ	0x00
VARIABLE_ASCII_CODE_ENTER			equ	0x0D
VARIABLE_ASCII_CODE_NEWLINE			equ	0x0A
VARIABLE_ASCII_CODE_BACKSPACE			equ	0x08
VARIABLE_ASCII_CODE_TAB				equ	0x09
VARIABLE_ASCII_CODE_ESCAPE			equ	0x1B
VARIABLE_ASCII_CODE_SPACE			equ	0x20
VARIABLE_ASCII_CODE_NUMBER			equ	0x30
VARIABLE_ASCII_CODE_TILDE			equ	0x7E
VARIABLE_ASCII_CODE_DELETE			equ	0x7F
VARIABLE_ASCII_CODE_DASH_HORIZONTAL_BOLD	equ	0xC4
VARIABLE_ASCII_CODE_CROSS_BOLD			equ	0xC5
VARIABLE_ASCII_CODE_DASH_DOUBLE_HORIZONTAL	equ	0xCD
VARIABLE_ASCII_CODE_DASH_VERTICAL_BOLD		equ	0xB3
%define	VARIABLE_ASCII_CODE_RETURN		VARIABLE_ASCII_CODE_ENTER, VARIABLE_ASCII_CODE_NEWLINE, VARIABLE_ASCII_CODE_TERMINATOR

VARIABLE_COLOR_BLACK				equ	0x00	; indeks
VARIABLE_COLOR_BLUE				equ	0x01
VARIABLE_COLOR_GREEN				equ	0x02
VARIABLE_COLOR_CYAN				equ	0x03
VARIABLE_COLOR_RED				equ	0x04
VARIABLE_COLOR_VIOLET				equ	0x05
VARIABLE_COLOR_BROWN				equ	0x06
VARIABLE_COLOR_LIGHT_GRAY			equ	0x07
VARIABLE_COLOR_GRAY				equ	0x08
VARIABLE_COLOR_LIGHT_BLUE			equ	0x09
VARIABLE_COLOR_LIGHT_GREEN			equ	0x0A
VARIABLE_COLOR_LIGHT_CYAN			equ	0x0B
VARIABLE_COLOR_LIGHT_RED			equ	0x0C
VARIABLE_COLOR_LIGHT_VIOLET			equ	0x0D
VARIABLE_COLOR_YELLOW				equ	0x0E
VARIABLE_COLOR_WHITE				equ	0x0F

VARIABLE_COLOR_BACKGROUND_BLACK			equ	0x00	; indeks
VARIABLE_COLOR_BACKGROUND_BLUE			equ	0x10
VARIABLE_COLOR_BACKGROUND_GREEN			equ	0x20
VARIABLE_COLOR_BACKGROUND_CYAN			equ	0x30
VARIABLE_COLOR_BACKGROUND_RED			equ	0x40
VARIABLE_COLOR_BACKGROUND_VIOLET		equ	0x50
VARIABLE_COLOR_BACKGROUND_BROWN			equ	0x60
VARIABLE_COLOR_BACKGROUND_LIGHT_GRAY		equ	0x70
; w trybie graficznym nie ma migającego tekstu, dlatego poniższe wykorzystywać z rozwagą
; to samo tyczy się oprogramowania Qemu (nawet w trybie tekstowym)
VARIABLE_COLOR_BACKGROUND_GRAY			equ	0x80	; VARIABLE_COLOR_BACKGROUND_BLACK
VARIABLE_COLOR_BACKGROUND_LIGHT_BLUE		equ	0x90	; VARIABLE_COLOR_BACKGROUND_BLUE
VARIABLE_COLOR_BACKGROUND_LIGHT_GREEN		equ	0xA0	; VARIABLE_COLOR_BACKGROUND_GREEN
VARIABLE_COLOR_BACKGROUND_LIGHT_CYAN		equ	0xB0	; VARIABLE_COLOR_BACKGROUND_CYAN
VARIABLE_COLOR_BACKGROUND_LIGHT_RED		equ	0xC0	; VARIABLE_COLOR_BACKGROUND_RED
VARIABLE_COLOR_BACKGROUND_LIGHT_VIOLET		equ	0xD0	; VARIABLE_COLOR_BACKGROUND_VIOLET
VARIABLE_COLOR_BACKGROUND_YELLOW		equ	0xE0	; VARIABLE_COLOR_BACKGROUND_BROWN
VARIABLE_COLOR_BACKGROUND_WHITE			equ	0xF0	; VARIABLE_COLOR_BACKGROUND_LIGHT_GRAY

VARIABLE_COLOR_MASK				equ	0x00FFFFFF

VARIABLE_COLOR_DEFAULT				equ	VARIABLE_COLOR_LIGHT_GRAY
VARIABLE_COLOR_BACKGROUND_DEFAULT		equ	VARIABLE_COLOR_BACKGROUND_BLACK

VARIABLE_SYSTEM_DECIMAL				equ	0x0A
VARIABLE_SYSTEM_HEXADECIMAL			equ	0x10

VARIABLE_QWORD_SIZE				equ	8
VARIABLE_DWORD_SIZE				equ	4
VARIABLE_DWORD_MASK				equ	0xFFFFFFFF
VARIABLE_WORD_SIZE				equ	2
VARIABLE_WORD_MASK				equ	0xFFFF
VARIABLE_BYTE_SIZE				equ	1
VARIABLE_BYTE_MASK				equ	0xFF

VARIABLE_QWORD_HIGH				equ	0x04
VARIABLE_DWORD_HIGH				equ	0x02
VARIABLE_WORD_HIGH				equ	0x01

VARIABLE_QWORD_SIGN				equ	63
VARIABLE_DWORD_SIGN				equ	31
VARIABLE_WORD_SIGN				equ	15
VARIABLE_BYTE_SIGN				equ	7

VARIABLE_BIT_0					equ	0

VARIABLE_DIVIDE_BY_2				equ	1
VARIABLE_DIVIDE_BY_4				equ	2
VARIABLE_DIVIDE_BY_8				equ	3
VARIABLE_DIVIDE_BY_16				equ	4
VARIABLE_DIVIDE_BY_32				equ	5
VARIABLE_DIVIDE_BY_64				equ	6
VARIABLE_DIVIDE_BY_128				equ	7
VARIABLE_DIVIDE_BY_256				equ	8
VARIABLE_DIVIDE_BY_512				equ	9
VARIABLE_DIVIDE_BY_1024				equ	10
VARIABLE_DIVIDE_BY_2048				equ	11
VARIABLE_DIVIDE_BY_4096				equ	12

VARIABLE_1024					equ	1024

VARIABLE_MULTIPLE_BY_2				equ	1
VARIABLE_MULTIPLE_BY_4				equ	2
VARIABLE_MULTIPLE_BY_8				equ	3
VARIABLE_MULTIPLE_BY_512			equ	9
VARIABLE_MULTIPLE_BY_4096			equ	12

VARIABLE_SHIFT_BY_2				equ	2
VARIABLE_SHIFT_BY_4				equ	4

VARIABLE_MOVE_HIGH_EAX_TO_AX			equ	16
VARIABLE_MOVE_HIGH_RAX_TO_EAX			equ	32

VARIABLE_MOVE_RAX_DWORD_LEFT			equ	32
VARIABLE_MOVE_RAX_WORD_LEFT			equ	16
VARIABLE_MOVE_RAX_BYTE_LEFT			equ	8

VARIABLE_PCI_CONFIG_ADDRESS			equ	0x0CF8
VARIABLE_PCI_CONFIG_DATA			equ	0x0CFC
VARIABLE_PIC_COMMAND_PORT0			equ	0x20
VARIABLE_PIC_COMMAND_PORT1			equ	0xA0
VARIABLE_PIC_DATA_PORT0				equ	0x21
VARIABLE_PIC_DATA_PORT1				equ	0xA1

VARIABLE_PIT_CLOCK_HZ				equ	1000	; Hz

VARIABLE_KEYBOARD_CACHE_SIZE			equ	16	; / 2 = 8 znaków

VARIABLE_PROCESS_LIMIT				equ	256

VARIABLE_EMPTY					equ	0
VARIABLE_FULL					equ	-1
VARIABLE_LAST_ITEM				equ	1

VARIABLE_TRUE					equ	1
VARIABLE_FALSE					equ	0

VARIABLE_INCREMENT				equ	1
VARIABLE_DECREMENT				equ	1

VARIABLE_DISK_SECTOR_SIZE			equ	9	; przesunięcie logiczne w lewo wartości 2
VARIABLE_DISK_SECTOR_SIZE_IN_BYTES		equ	0x0200

VARIABLE_CMOS_PORT_IN				equ	0x71
VARIABLE_CMOS_PORT_OUT				equ	0x70

VARIABLE_KERNEL_PHYSICAL_ADDRESS		equ	0x0000000000100000
VARIABLE_KERNEL_STACK_ADDRESS			equ	VARIABLE_MEMORY_HIGH_VIRTUAL_ADDRESS - 0x1000

STATIC_KERNEL_SERVICE				equ	0x40

VARIABLE_KERNEL_SERVICE_PROCESS			equ	0x00
VARIABLE_KERNEL_SERVICE_PROCESS_END		equ	0x0000
VARIABLE_KERNEL_SERVICE_PROCESS_NEW		equ	0x0001
VARIABLE_KERNEL_SERVICE_PROCESS_CHECK		equ	0x0002
VARIABLE_KERNEL_SERVICE_PROCESS_MEMORY_ALLOCATE	equ	0x0003
VARIABLE_KERNEL_SERVICE_PROCESS_LIST		equ	0x0004
VARIABLE_KERNEL_SERVICE_PROCESS_ARGS		equ	0x0005
VARIABLE_KERNEL_SERVICE_PROCESS_PID		equ	0x0006
VARIABLE_KERNEL_SERVICE_PROCESS_KILL		equ	0x0007
VARIABLE_KERNEL_SERVICE_PROCESS_SLEEP		equ	0x0008

VARIABLE_KERNEL_SERVICE_SCREEN			equ	0x01
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

VARIABLE_KERNEL_SERVICE_KEYBOARD		equ	0x02
VARIABLE_KERNEL_SERVICE_KEYBOARD_GET_KEY	equ	0x0200

VARIABLE_KERNEL_SERVICE_SYSTEM			equ	0x03
VARIABLE_KERNEL_SERVICE_SYSTEM_UPTIME		equ	0x0300
VARIABLE_KERNEL_SERVICE_SYSTEM_DATE		equ	0x0301
VARIABLE_KERNEL_SERVICE_SYSTEM_MEMORY		equ	0x0302

VARIABLE_KERNEL_SERVICE_NETWORK			equ	0x04
VARIABLE_KERNEL_SERVICE_NETWORK_IP_SET		equ	0x0400
VARIABLE_KERNEL_SERVICE_NETWORK_IP_GET		equ	0x0401
VARIABLE_KERNEL_SERVICE_NETWORK_PORT_ASSIGN	equ	0x0402
VARIABLE_KERNEL_SERVICE_NETWORK_PORT_RELEASE	equ	0x0403
VARIABLE_KERNEL_SERVICE_NETWORK_ANSWER		equ	0x0404

VARIABLE_KERNEL_SERVICE_VFS			equ	0x05
VARIABLE_KERNEL_SERVICE_VFS_DIR_ROOT		equ	0x0500
VARIABLE_KERNEL_SERVICE_VFS_FILE_READ		equ	0x0501
VARIABLE_KERNEL_SERVICE_VFS_FILE_SAVE		equ	0x0502
VARIABLE_KERNEL_SERVICE_VFS_FILE_UPDATE		equ	0x0503
VARIABLE_KERNEL_SERVICE_VFS_FILE_TOUCH		equ	0x0504
VARIABLE_KERNEL_SERVICE_VFS_FILE_GET_SIZE	equ	0x0505
VARIABLE_KERNEL_SERVICE_VFS_FILE_DELETE		equ	0x0506

VARIABLE_KERNEL_SERVICE_VIDEO			equ	0x06
VARIABLE_KERNEL_SERVICE_VIDEO_INFO		equ	0x0600
VARIABLE_KERNEL_SERVICE_VIDEO_ACCESS		equ	0x0601

VARIABLE_KERNEL_SERVICE_DRIVE			equ	0x07
VARIABLE_KERNEL_SERVICE_DRIVE_LIST		equ	0x0700
VARIABLE_KERNEL_SERVICE_DRIVE_SECTOR_READ	equ	0x0701

VARIABLE_FILESYSTEM_TYPE_FILE			equ	0x8000
VARIABLE_FILESYSTEM_TYPE_DIRECTORY		equ	0x4000

VARIABLE_SCREEN_VIDEO_WIDTH			equ	640
VARIABLE_SCREEN_VIDEO_HEIGHT			equ	400

VARIABLE_SCREEN_TEXT_MODE_BASE_ADDRESS		equ	0x000B8000
VARIABLE_SCREEN_TEXT_MODE_WIDTH			equ	80
VARIABLE_SCREEN_TEXT_MODE_HEIGHT		equ	25
VARIABLE_SCREEN_TEXT_MODE_CHAR_SIZE		equ	2	; kod ASCII + atrybut
VARIABLE_SCREEN_TEXT_MODE_LINE_SIZE		equ	VARIABLE_SCREEN_TEXT_MODE_WIDTH * VARIABLE_SCREEN_TEXT_MODE_CHAR_SIZE
VARIABLE_SCREEN_TEXT_MODE_SIZE			equ	VARIABLE_SCREEN_TEXT_MODE_WIDTH * VARIABLE_SCREEN_TEXT_MODE_HEIGHT
VARIABLE_SCREEN_TEXT_MODE_SIZE_IN_BYTES		equ	VARIABLE_SCREEN_TEXT_MODE_SIZE * VARIABLE_SCREEN_TEXT_MODE_CHAR_SIZE

VARIABLE_NIC					equ	0x0200
VARIABLE_NIC_INTEL_82540EM_PCI			equ	0x100E8086

VARIABLE_IDT_RECORD_TYPE_CPU			equ	0xEF00
VARIABLE_IDT_RECORD_TYPE_HARDWARE		equ	0x8F00
VARIABLE_IDT_RECORD_TYPE_SOFTWARE		equ	0xEF00

struc VARIABLE_TABLE_SERPENTINE_RECORD
	.PID	resq	1
	.CR3	resq	1
	.RSP	resq	1
	.FLAGS	resq	1
	.NAME	resb	32
	.ARGS	resq	1
	.SIZE	resb	1
endstruc

STATIC_SERPENTINE_RECORD_BIT_USED		equ	0
STATIC_SERPENTINE_RECORD_BIT_ACTIVE		equ	1
STATIC_SERPENTINE_RECORD_BIT_CLOSED		equ	2
STATIC_SERPENTINE_RECORD_BIT_DAEMON		equ	3
STATIC_SERPENTINE_RECORD_BIT_DESKTOP		equ	4
STATIC_SERPENTINE_RECORD_FLAG_USED		equ	00000001b	; rekord w serpentynie jest zajęty przez uruchomiony proces
STATIC_SERPENTINE_RECORD_FLAG_ACTIVE		equ	00000010b	; proces bierze czynny udział w pracy systemu
STATIC_SERPENTINE_RECORD_FLAG_CLOSED		equ	00000100b
STATIC_SERPENTINE_RECORD_FLAG_DAEMON		equ	00001000b
STATIC_SERPENTINE_RECORD_FLAG_DESKTOP		equ	00010000b	; proces ma bezpośredni dostęp do przestrzeni pamięci ekranu

struc	STRUCTURE_CACHE_DEFAULT
	.id	resb	8	; identyfikator
	.size	resb	8	; rozmiar danych
	.data	resb	VARIABLE_MEMORY_PAGE_SIZE - ( VARIABLE_QWORD_SIZE * 2 )
	.SIZE	resb	1
endstruc

struc	STRUCTURE_VGA_INFO_BLOCK
	.VESASignature	resb	4
	.VESAVersion	resb	2
	.OEMStringPtr	resb	4
	.Capabilities	resb	4
	.VideoModePtr	resb	4
	.TotalMemory	resb	2
	.Reserved	resb	236
endstruc

struc	STRUCTURE_MODE_INFO_BLOCK
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

VARIABLE_PERMISSION_FILE_SUID			equ	100000000000b
VARIABLE_PERMISSION_FILE_SGID			equ	010000000000b
VARIABLE_PERMISSION_FILE_STICKY			equ	001000000000b
VARIABLE_PERMISSION_FILE_USER_READ		equ	000100000000b
VARIABLE_PERMISSION_FILE_USER_WRITE		equ	000010000000b
VARIABLE_PERMISSION_FILE_USER_EXECUTE		equ	000001000000b
VARIABLE_PERMISSION_FILE_GROUP_READ		equ	000000100000b
VARIABLE_PERMISSION_FILE_GROUP_WRITE		equ	000000010000b
VARIABLE_PERMISSION_FILE_GROUP_EXECUTE		equ	000000001000b
VARIABLE_PERMISSION_FILE_OTHER_READ		equ	000000000100b
VARIABLE_PERMISSION_FILE_OTHER_WRITE		equ	000000000010b
VARIABLE_PERMISSION_FILE_OTHER_EXECUTE		equ	000000000001b
VARIABLE_PERMISSION_FILE_SUID_BIT		equ	11
VARIABLE_PERMISSION_FILE_SGID_BIT		equ	10
VARIABLE_PERMISSION_FILE_STICKY_BIT		equ	9
VARIABLE_PERMISSION_FILE_USER_READ_BIT		equ	8
VARIABLE_PERMISSION_FILE_USER_WRITE_BIT		equ	7
VARIABLE_PERMISSION_FILE_USER_EXECUTE_BIT	equ	6
VARIABLE_PERMISSION_FILE_GROUP_READ_BIT		equ	5
VARIABLE_PERMISSION_FILE_GROUP_WRITE_BIT	equ	4
VARIABLE_PERMISSION_FILE_GROUP_EXECUTE_BIT	equ	3
VARIABLE_PERMISSION_FILE_OTHER_READ_BIT		equ	2
VARIABLE_PERMISSION_FILE_OTHER_WRITE_BIT	equ	1
VARIABLE_PERMISSION_FILE_OTHER_EXECUTE_BIT	equ	0

VARIABLE_PROCESS_ERROR_NO_EXECUTE		equ	0x01
VARIABLE_PROCESS_ERROR_FILE_NOT_FOUND		equ	0x02
VARIABLE_PROCESS_ERROR_NO_FREE_MEMORY		equ	0x03

VARIABLE_VFS_ERROR_FILE_EXISTS		equ	0x01
VARIABLE_VFS_ERROR_NO_FREE_SPACE	equ	0x02
VARIABLE_VFS_ERROR_FILE_NOT_EXISTS	equ	0x03
VARIABLE_VFS_ERROR_NAME_TO_LONG		equ	0x04
VARIABLE_VFS_ERROR_NAME_TO_SHORT	equ	0x05
