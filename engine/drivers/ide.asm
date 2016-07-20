; Copyright (C) 2013-2016 Wataha.net
; All Rights Reserved
;
; LICENSE Creative Commons BY-NC-ND 4.0
; See LICENSE.TXT
;
; Driver based on BareMetal OS https://github.com/ReturnInfinity/BareMetal-OS
;
; Main developer:
;	Andrzej (akasei) Adamczyk [e-mail: akasei from wataha.net]
;-------------------------------------------------------------------------------

; Use:
; nasm - http://www.nasm.us/

VARIABLE_IDE_PRIMARY				equ	0x01F0
VARIABLE_IDE_SECONDARY				equ	0x0170

VARIABLE_IDE_MASTER				equ	0xA0
VARIABLE_IDE_SLAVE				equ	0xB0

VARIABLE_IDE_REGISTER_DATA			equ	0x00
VARIABLE_IDE_REGISTER_FEATURES			equ	0x01
VARIABLE_IDE_REGISTER_COUNTER			equ	0x02
VARIABLE_IDE_REGISTER_LBA_LOW			equ	0x03
VARIABLE_IDE_REGISTER_LBA_MIDDLE		equ	0x04
VARIABLE_IDE_REGISTER_LBA_HIGH			equ	0x05
VARIABLE_IDE_REGISTER_DRIVE			equ	0x06
VARIABLE_IDE_REGISTER_STATUS			equ	0x07
VARIABLE_IDE_REGISTER_COMMAND			equ	0x07
VARIABLE_IDE_REGISTER_COMMAND_READ_PIO_EXT	equ	0x24
VARIABLE_IDE_REGISTER_COMMAND_WRITE_PIO_EXT	equ	0x34
VARIABLE_IDE_REGISTER_COMMAND_CACHE_FLUSH_EXT	equ	0xEA
VARIABLE_IDE_REGISTER_COMMAND_IDENTIFY		equ	0xEC

VARIABLE_IDE_REGISTER_ALTERNATE			equ	0x0206
VARIABLE_IDE_REGISTER_CONTROL			equ	0x0206
VARIABLE_IDE_REGISTER_CONTROL_nIEN		equ	00000010b
VARIABLE_IDE_REGISTER_CONTROL_SRST		equ	00000100b
VARIABLE_IDE_REGISTER_CONTROL_HOB		equ	10000000b

table_ide:
	dw	0x01F0	; primary
	dw	0x0170	; secondary

; 64 Bitowy kod programu
[BITS 64]

ide_initialize:
	; ilość kontrolerów
	mov	rcx,	2

	; przetwarzaj pierwszy kontroler
	mov	rsi,	table_ide

.second_controller:
	; sprawdź napęd MASTER
	mov	bl,	VARIABLE_IDE_MASTER

	; wyłącz przerwania dla kontrolera IDEn
	mov	al,	VARIABLE_IDE_REGISTER_CONTROL_nIEN
	mov	dx,	word [rsi]
	add	dx,	VARIABLE_IDE_REGISTER_CONTROL
	out	dx,	al

.second_drive:
	; wybierz napęd podpięty pod kontroler IDEn
	mov	al,	bl
	mov	dx,	word [rsi]
	add	dx,	VARIABLE_IDE_REGISTER_DRIVE
	out	dx,	al

	; czekaj na gotowość napędu
	call	ide_wait

	; wyślij polecenie identyfikacji podpiętego urządzenia
	mov	al,	VARIABLE_IDE_REGISTER_COMMAND_IDENTIFY
	mov	dx,	word [rsi]
	add	dx,	VARIABLE_IDE_REGISTER_COMMAND
	out	dx,	al

	; czekaj na gotowość napędu
	call	ide_wait

	; sprawdź odpowiedź z podpiętego urządzenia
	in	al,	dx	; VARIABLE_IDE_REGISTER_STATUS

	; jeśli brak odpowiedzi, brak podpiętego nośnika
	cmp	al,	VARIABLE_EMPTY
	ja	.found_drive

.next_drive:
	; sprawdzono obydwa napędy?
	cmp	bl,	VARIABLE_IDE_SLAVE
	je	.next_controller

	; sprawdź czy podpięty jest drugi nośnik do tego samego kontrolera
	mov	bl,	VARIABLE_IDE_SLAVE

	; kontynuuj
	jmp	.second_drive

.next_controller:
	; następny rekod z tablicy kontrolerów
	add	rsi,	VARIABLE_WORD_SIZE

	; koniec kontrolerów?
	loop	.second_controller

.end:
	jmp	$

.found_drive:
	jmp	.next_drive

	jmp	$

; odczekaj 400ns
ide_wait:
	; zachowaj oryginalne rejestry
	push	rax
	push	rdx

	mov	rdx,	VARIABLE_IDE_PRIMARY + VARIABLE_IDE_REGISTER_ALTERNATE
	in	al,	dx

	; przywróć oryginalne rejestry
	pop	rdx
	pop	rax

	; powrót z procedury
	ret
