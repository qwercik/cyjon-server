;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

KERNEL_BASE_address	equ	0x00100000

KERNEL_PAGE_SIZE_byte	equ	0x1000
KERNEL_PAGE_SIZE_shift	equ	12

KERNEL_PAGE_mask	equ	0xFFFFFFFFFFFFF000

;===============================================================================
; STAŁE POWSZECHNE
;===============================================================================
EMPTY			equ	0
MAX_UNSIGNED		equ	-1

TRUE			equ	1
FALSE			equ	0

DIVIDE_BY_PAGE		equ	KERNEL_PAGE_SIZE_shift

BYTE_SIZE_byte		equ	1
WORD_SIZE_byte		equ	2
DWORD_SIZE_byte		equ	4
QWORD_SIZE_byte		equ	8
