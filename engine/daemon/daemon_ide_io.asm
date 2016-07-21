; Copyright (C) 2013-2016 Wataha.net
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

VARIABLE_DAEMON_IDE_IO_NAME_COUNT		equ	6
variable_daemon_ide_io_name			db	"ide io"

variable_daemon_ide_io_semaphore		db	VARIABLE_FALSE

VARIABLE_DAEMON_IDE_IO_CACHE_SIZE		dq	1
VARIABLE_DAEMON_IDE_IO_CACHE_STATUS_FREE	equ	VARIABLE_EMPTY
VARIABLE_DAEMON_IDE_IO_CACHE_STATUS_RESERVED	equ	0x01
VARIABLE_DAEMON_IDE_IO_CACHE_STATUS_PREPARED	equ	0x02
VARIABLE_DAEMON_IDE_IO_CACHE_STATUS_PROCESSING	equ	0x03
VARIABLE_DAEMON_IDE_IO_CACHE_STATUS_READY	equ	0x04
VARIABLE_DAEMON_IDE_IO_CACHE_ERROR_NO_ERROR	equ	VARIABLE_EMPTY
VARIABLE_DAEMON_IDE_IO_CACHE_ERROR_NO_DEVICE	equ	0x01
VARIABLE_DAEMON_IDE_IO_CACHE_ERROR_NO_LBA	equ	0x02
VARIABLE_DAEMON_IDE_IO_CACHE_ERROR_READ		equ	0x03
VARIABLE_DAEMON_IDE_IO_CACHE_ERROR_WRITE	equ	0x04

variable_daemon_ide_io_cache			dq	VARIABLE_EMPTY

struc	STRUCTURE_DAEMON_IDE_IO_CACHE
	.status		resb	1
	.error		resb	1
	.pid		resb	8
	.device		resb	1
	.lba		resb	8
	.data		resb	512
	.SIZE		resb	1
endstruc

; 64 Bitowy kod programu
[BITS 64]

daemon_ide_io:
	; czy dostępne są nośniki IDE?
	mov	rsi,	qword [variable_ide_disks]
	cmp	word [rsi],	VARIABLE_EMPTY
	je	irq64_process_end	; nie, wyłącz demona

	; rozmiar buforu
	mov	rcx,	VARIABLE_DAEMON_ETHERNET_CACHE_SIZE

.wait:
	; przydziel przestrzeń pod bufor
	call	cyjon_page_find_free_memory_physical
	cmp	rdi,	VARIABLE_EMPTY
	je	.wait	; brak miejsca, czekaj

	; zapisz adres
	call	cyjon_page_clear_few
	mov	qword [variable_daemon_ide_io_cache],	rdi

	; demon ethernet gotowy
	mov	byte [variable_daemon_ide_io_semaphore],	VARIABLE_TRUE

.find_request:
	
	jmp	$
