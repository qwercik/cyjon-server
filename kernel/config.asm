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

;===============================================================================
; PAGE
;===============================================================================
KERNEL_PAGE_SIZE_byte			equ	0x1000
KERNEL_PAGE_SIZE_shift			equ	12

KERNEL_PAGE_mask			equ	0xFFFFFFFFFFFFF000

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

DIVIDE_BY_8_shift			equ	3
DIVIDE_BY_PAGE_shift			equ	KERNEL_PAGE_SIZE_shift

BYTE_SIZE_byte				equ	1
WORD_SIZE_byte				equ	2
DWORD_SIZE_byte				equ	4
QWORD_SIZE_byte				equ	8
