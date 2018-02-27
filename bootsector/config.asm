;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

STATIC_BOOTSECTOR_BASE_ADDRESS	equ	0x7C00
STATIC_BOOTSECTOR_STACK_ADDRESS	equ	0x1000
STATIC_ZERO_BASE_ADDRESS	equ	0x7E00

STATIC_SECTOR_SIZE		equ	512

STATIC_KIB_SIZE			equ	1024

STATIC_ZERO_START_ADDRESS	equ	zero
STATIC_ZERO_END_ADDRESS		equ	zero_end

struc	STATIC_DISK_ADDRESS_PACKET
	.structure_size		resb	1
	.reserved		resb	1
	.count			resb	2
	.offset			resb	2
	.segment		resb	2
	.lba			resb	8
endstruc
