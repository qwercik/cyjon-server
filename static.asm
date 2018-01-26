;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

;===============================================================================
; KERNEL
;===============================================================================
STATIC_KERNEL_BASE_ADDRESS				equ	0x0000000000100000

;===============================================================================
; PAGE
;===============================================================================
STATIC_PAGE_SIZE					equ	4096
STATIC_PAGE_SIZE_BITS					equ	12

;===============================================================================
; VIDEO
;===============================================================================
STATIC_VIDEO_COLOR_DEPTH_SHIFT				equ	2
STATIC_VIDEO_COLOR_DEPTH_BYTE				equ	4
STATIC_VIDEO_COLOR_DEPTH_BIT				equ	32

;===============================================================================
; DEFAULT
;===============================================================================
STATIC_TRUE						equ	1
STATIC_FALSE						equ	0

STATIC_EMPTY						equ	STATIC_FALSE

STATIC_DIVIDE_BY_2					equ	1
STATIC_DIVIDE_BY_4					equ	2
STATIC_DIVIDE_BY_8					equ	3
STATIC_DIVIDE_BY_16					equ	4
STATIC_DIVIDE_BY_32					equ	5
STATIC_DIVIDE_BY_64					equ	6
STATIC_DIVIDE_BY_128					equ	7
STATIC_DIVIDE_BY_256					equ	8
STATIC_DIVIDE_BY_512					equ	9
STATIC_DIVIDE_BY_1024					equ	10
STATIC_DIVIDE_BY_2048					equ	11
STATIC_DIVIDE_BY_4096					equ	12
STATIC_DIVIDE_BY_PAGE_SIZE				equ	STATIC_PAGE_SIZE_BITS

STATIC_MULTIPLE_BY_2					equ	1
STATIC_MULTIPLE_BY_4					equ	2
STATIC_MULTIPLE_BY_8					equ	3
STATIC_MULTIPLE_BY_16					equ	4
STATIC_MULTIPLE_BY_32					equ	5
STATIC_MULTIPLE_BY_64					equ	6
STATIC_MULTIPLE_BY_128					equ	7
STATIC_MULTIPLE_BY_256					equ	8
STATIC_MULTIPLE_BY_512					equ	9
STATIC_MULTIPLE_BY_1024					equ	10
STATIC_MULTIPLE_BY_2048					equ	11
STATIC_MULTIPLE_BY_4096					equ	12
STATIC_MULTIPLE_BY_PAGE_SIZE				equ	STATIC_PAGE_SIZE_BITS

STATIC_MOVE_HIGH_TO_AL					equ	8
STATIC_MOVE_HIGH_TO_AX					equ	16
STATIC_MOVE_HIGH_TO_EAX					equ	32
STATIC_MOVE_AL_TO_HIGH					equ	8
STATIC_MOVE_AX_TO_HIGH					equ	16
STATIC_MOVE_EAX_TO_HIGH					equ	32

STATIC_REPLACE_EAX_WITH_HIGH				equ	32

STATIC_QWORD_SIZE					equ	8
STATIC_DWORD_SIZE					equ	4
STATIC_WORD_SIZE					equ	2
STATIC_BYTE_SIZE					equ	1

STATIC_QWORD_HIGH					equ	4
STATIC_DWORD_HIGH					equ	2
STATIC_WORD_HIGH					equ	1

STATIC_QWORD_BIT_SIGN					equ	63
STATIC_DWORD_BIT_SIGN					equ	31
STATIC_WORD_BIT_SIGN					equ	15
STATIC_BYTE_BIT_SIGN					equ	7

STATIC_QWORD_MASK_HIGH					equ	0xFFFFFFFF00000000
STATIC_DWORD_MASK					equ	0x00000000FFFFFFFF
STATIC_WORD_MASK					equ	0x000000000000FFFF
STATIC_BYTE_MASK					equ	0x00000000000000FF

STATIC_SIZE_KIB						equ	1024
STATIC_SIZE_MIB						equ	STATIC_SIZE_KIB * 1024
STATIC_SIZE_GIB						equ	STATIC_SIZE_MIB * 1024
STATIC_SIZE_TIB						equ	STATIC_SIZE_GIB * 1024
