;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

KERNEL_BASE_address			equ	0x00100000

;===============================================================================
; PIT
;===============================================================================
KERNEL_PIT_CLOCK_hz			equ	1000

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
; PIC
;===============================================================================
KERNEL_PIC_IRQ_SHEDULER			equ	0x00
KERNEL_PIC_IRQ_KEYBOARD			equ	0x01

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
; IDT
;===============================================================================
KERNEL_IDT_IRQ_HARDWARE_offset		equ	0x20

KERNEL_IDT_IRQ_SHEDULER			equ	0x00
KERNEL_IDT_IRQ_PS2			equ	0x01

KERNEL_IDT_TYPE_EXCEPTION		equ	0x8E00
KERNEL_IDT_TYPE_IRQ			equ	0x8F00
KERNEL_IDT_TYPE_ISR			equ	0xEF00

;===============================================================================
; TASK
;===============================================================================
KERNEL_TASK_EFLAGS_IF			equ	000000000000001000000000b	; przerwania włączone
KERNEL_TASK_EFLAGS_DEFAULT		equ	KERNEL_TASK_EFLAGS_IF

KERNEL_TASK_FLAG_ACTIVE			equ	0000000000000001b	; rekord bierze czynny udział w pracy systemu
KERNEL_TASK_FLAG_CLOSED			equ	0000000000000010b	; rekord oczkuje na kolekcjonera śmieci
KERNEL_TASK_FLAG_DAEMON			equ	0000000000000100b	; rekord zawiera proces typu daemon
KERNEL_TASK_FLAG_RESERVED		equ	0000000000001000b	; rekord zarezerwowany

KERNEL_TASK_FLAG_ACTIVE_bit		equ	0
KERNEL_TASK_FLAG_CLOSED_bit		equ	1
KERNEL_TASK_FLAG_DAEMON_bit		equ	2
KERNEL_TASK_FALG_RESERVED_bit		equ	3

;===============================================================================
; STAŁE POWSZECHNE
;===============================================================================
EMPTY					equ	0
MAX_UNSIGNED				equ	-1

TRUE					equ	1
FALSE					equ	0

MULTIPLE_BY_8_shift			equ	3
MULTIPLE_BY_16_shift			equ	4

DIVIDE_BY_8_shift			equ	3
DIVIDE_BY_PAGE_shift			equ	KERNEL_PAGE_SIZE_shift

BYTE_SIZE_byte				equ	1
WORD_SIZE_byte				equ	2
DWORD_SIZE_byte				equ	4
QWORD_SIZE_byte				equ	8

MOVE_HIGH_TO_AL				equ	8
MOVE_HIGH_TO_AX				equ	16
MOVE_HIGH_TO_EAX			equ	32

PORT_PIC_MASTER_command			equ	0x0020
PORT_PIC_MASTER_data			equ	0x0021
PORT_PIT_CLOCK				equ	0x0036
PORT_PIT_CHANNEL_0_data			equ	0x0040
PORT_PIT_CHANNEL_1_data			equ	0x0041
PORT_PIT_CHANNEL_2_data			equ	0x0042
PORT_PIT_CHANNEL_4_command		equ	0x0043
PORT_PS2_data				equ	0x0060
PORT_PS2_command_or_status		equ	0x0064
PORT_PIC_SLAVE_command			equ	0x00A0
PORT_PIC_SLAVE_data			equ	0x00A1
PORT_PIT_SPEAKER			equ	0x00B6

PIT_CRYSTAL				equ	1193182	; Hz

PIC_IRQ_ACCEPT				equ	0x20

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

struc	KERNEL_STRUCTURE_GDT_OR_IDT_HEADER
	.limit				resb	2
	.address			resb	8
endstruc

struc	KERNEL_STRUCTURE_BLOCK
	.data				resb	KERNEL_PAGE_SIZE_byte - QWORD_SIZE_byte
	.link				resb	QWORD_SIZE_byte	; wskaźnik do następnego bloku danych
	.SIZE:
endstruc

struc	KERNEL_STRUCTURE_TASK
	.pid				resb	8
	.cr3				resb	8
	.rsp				resb	8
	.flags				resb	2
	.length				resb	1
	.name				resb	255
	.SIZE:
endstruc
