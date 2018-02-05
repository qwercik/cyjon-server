;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

KERNEL_BASE_address			equ	0x00100000

;===============================================================================
; MEMORY
;===============================================================================
KERNEL_MEMORY_LOW_address		equ	KERNEL_BASE_address
KERNEL_MEMORY_HIGH_address		equ	0xFFFF000000000000
KERNEL_MEMORY_HIGH_REAL_address		equ	0xFFFF800000000000
KERNEL_MEMORY_HIGH_VIRTUAL_address	equ	KERNEL_MEMORY_HIGH_REAL_address - KERNEL_MEMORY_HIGH_address

KERNEL_MEMORY_STACK_KERNEL_SIZE_byte	equ	KERNEL_PAGE_SIZE_byte * WORD_SIZE_byte
KERNEL_MEMORY_STACK_KERNEL_address	equ	KERNEL_MEMORY_HIGH_VIRTUAL_address - KERNEL_MEMORY_STACK_KERNEL_SIZE_byte

;===============================================================================
; PAGE
;===============================================================================
KERNEL_PAGE_SIZE_byte			equ	0x1000
KERNEL_PAGE_SIZE_shift			equ	12

KERNEL_PAGE_mask			equ	0xFFFFFFFFFFFFF000

KERNEL_PAGE_FLAG_AVAILABLE		equ	0x01
KERNEL_PAGE_FLAG_WRITE			equ	0x02
KERNEL_PAGE_FLAG_USER			equ	0x04
KERNEL_PAGE_FLAG_WRITE_THROUGH		equ	0x08
KERNEL_PAGE_FLAG_CACHE			equ	0x10
KERNEL_PAGE_FLAG_PAGE_SIZE		equ	0x80

KERNEL_PAGE_ROW_count			equ	512

KERNEL_PAGE_PML4_SIZE_byte		equ	KERNEL_PAGE_ROW_count * KERNEL_PAGE_PML3_SIZE_byte
KERNEL_PAGE_PML3_SIZE_byte		equ	KERNEL_PAGE_ROW_count * KERNEL_PAGE_PML2_SIZE_byte
KERNEL_PAGE_PML2_SIZE_byte		equ	KERNEL_PAGE_ROW_count * KERNEL_PAGE_PML1_SIZE_byte
KERNEL_PAGE_PML1_SIZE_byte		equ	KERNEL_PAGE_ROW_count * KERNEL_PAGE_SIZE_byte

;===============================================================================
; STRUKTURY
;===============================================================================
struc	KERNEL_STRUCTURE_GDT
	.null				resb	8
	.cs_ring0			resb	8
	.ds_ring0			resb	8
	.cs_ring3			resb	8
	.ds_ring3			resb	8
	.tss				resb	8
	.SIZE:
endstruc

struc	KERNEL_STRUCTURE_GDT_HEADER
	.limit				resb	2
	.address			resb	8
endstruc

;===============================================================================
; STAŁE POWSZECHNE
;===============================================================================
EMPTY					equ	0
MAX_UNSIGNED				equ	-1

TRUE					equ	1
FALSE					equ	0

MULTIPLE_BY_8_shift			equ	3

DIVIDE_BY_8_shift			equ	3
DIVIDE_BY_PAGE_shift			equ	KERNEL_PAGE_SIZE_shift

BYTE_SIZE_byte				equ	1
WORD_SIZE_byte				equ	2
DWORD_SIZE_byte				equ	4
QWORD_SIZE_byte				equ	8

PORT_PIC_MASTER_command			equ	0x0020
PORT_PIC_MASTER_data			equ	0x0021
PORT_PIC_SLAVE_command			equ	0x00A0
PORT_PIC_SLAVE_data			equ	0x00A1
PORT_PS2_data				equ	0x0060
PORT_PS2_command_or_status		equ	0x0064
