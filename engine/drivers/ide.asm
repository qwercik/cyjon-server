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
VARIABLE_IDE_REGISTER_STATUS_BIT_ERR		equ	0
VARIABLE_IDE_REGISTER_STATUS_BIT_DRQ		equ	3
VARIABLE_IDE_REGISTER_STATUS_BIT_DF		equ	5
VARIABLE_IDE_REGISTER_STATUS_BIT_BSY		equ	7
VARIABLE_IDE_REGISTER_COMMAND			equ	0x07
VARIABLE_IDE_REGISTER_COMMAND_READ_PIO_EXT	equ	0x24
VARIABLE_IDE_REGISTER_COMMAND_WRITE_PIO_EXT	equ	0x34
VARIABLE_IDE_REGISTER_COMMAND_CACHE_FLUSH_EXT	equ	0xEA
VARIABLE_IDE_REGISTER_COMMAND_IDENTIFY		equ	0xEC
VARIABLE_IDE_REGISTER_COMMAND_IDENTIFY_SIZE	equ	128

VARIABLE_IDE_REGISTER_ALTERNATE			equ	0x0206
VARIABLE_IDE_REGISTER_CONTROL			equ	0x0206
VARIABLE_IDE_REGISTER_CONTROL_nIEN		equ	00000010b
VARIABLE_IDE_REGISTER_CONTROL_SRST		equ	00000100b
VARIABLE_IDE_REGISTER_CONTROL_HOB		equ	10000000b

table_ide:
	dw	0x01F0	; primary
	; blokuję drugi kontroler, Qemu ma jakiś problem z sobą
	; Bochs działa od strzału...
	; zablokowałem też drugie urządzenie na pierwszym kontrolerze
	; debug
	;dw	0x0170	; secondary
	dw	VARIABLE_EMPTY

variable_ide_disks				dq	VARIABLE_EMPTY

struc	STRUCTURE_IDE_DISK
	.controller	resw	1
	.device		resb	1
	.something0	resb	20
	.serial		resb	20
	.something1	resb	14
	.name		resb	40
	.something2	resb	256 - 20 - 20 - 14 - 40
	.SIZE		resb	1
endstruc

variable_ide0					db	"IDE0 ", VARIABLE_ASCII_CODE_TERMINATOR
variable_ide1					db	"IDE1 ",	VARIABLE_ASCII_CODE_TERMINATOR
variable_master					db	"Master ", VARIABLE_ASCII_CODE_TERMINATOR
variable_slave					db	"Slave  ", VARIABLE_ASCII_CODE_TERMINATOR

; 64 Bitowy kod programu
[BITS 64]

ide_initialize:
	; zachowaj oryginalne rejestry
	push	rax
	push	rbx
	push	rcx
	push	rdx
	push	rsi
	push	rdi

	; przydziel przestrzeń pod specyfikacje dostępnych nośników
	call	cyjon_page_allocate

	; czekaj na przydzielenie przestrzeni
	cmp	rdi,	VARIABLE_EMPTY
	je	ide_initialize

	; zapisz
	mov	qword [variable_ide_disks],	rdi

	; przetwarzaj pierwszy kontroler
	mov	rsi,	table_ide

.second_controller:
	; sprawdź napęd MASTER
	mov	bx,	VARIABLE_IDE_MASTER

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

	; pobierz status nośnika, jeśli ZERO brak podpiętego
	cmp	al,	VARIABLE_EMPTY
	ja	.device_busy

.next_drive:
	; sprawdzono obydwa napędy?
	cmp	bl,	VARIABLE_IDE_SLAVE
	je	.next_controller

	; sprawdź czy podpięty jest drugi nośnik do tego samego kontrolera
	mov	bx,	VARIABLE_IDE_SLAVE

	; kontynuuj
	; debug
	;jmp	.second_drive

.next_controller:
	; następny rekod z tablicy kontrolerów
	add	rsi,	VARIABLE_WORD_SIZE

	; koniec kontrolerów?
	cmp	word [rsi],	VARIABLE_EMPTY
	jne	.second_controller

.end:
	; sprawdź czy znaleziono jakiekolwiek nośniki ATA
	mov	rsi,	qword [variable_ide_disks]

	; jeśli istnieje pierwszy rekord, wyświetl nagłówek
	cmp	word [rsi],	VARIABLE_EMPTY
	je	.terminate	; nie

	; wyświetl informacje o wykrytych nośnikach
	mov	rbx,	VARIABLE_COLOR_LIGHT_GREEN
	mov	rcx,	VARIABLE_FULL
	mov	rdx,	VARIABLE_COLOR_BACKGROUND_DEFAULT
	mov	rsi,	text_caution
	call	cyjon_screen_print_string
	mov	rbx,	VARIABLE_COLOR_DEFAULT
	mov	rsi,	text_ide_found
	call	cyjon_screen_print_string

	; dekoduj nazwy i numery seryjny nośników
	call	ide_decode

	; wyświetl dostępne nośniki danych
	call	ide_show_devices

.terminate:
	; przywróć oryginalne rejestry
	pop	rdi
	pop	rsi
	pop	rdx
	pop	rcx
	pop	rbx
	pop	rax

	; powrót z procedury
	ret

.device_busy:
	; pobierz status urządzenia
	in	al,	dx

	; czy nośnik zajęty przetwarzaniem polecenia?
	bt	ax,	VARIABLE_IDE_REGISTER_STATUS_BIT_BSY
	jc	.device_busy
	; czy nośnik zajęty przetwarzaniem polecenia?
	bt	ax,	VARIABLE_IDE_REGISTER_STATUS_BIT_DRQ
	jnc	.device_busy

	; zachowaj adres kontrolera
	mov	ax,	word [rsi]
	stosw

	; zachowaj numer nośnika na kontrolerze
	mov	al,	bl
	stosb

	; zachowaj licznik kontrolerów
	push	rcx

	; zapisz strukturę informacyjną nośnika
	mov	rcx,	VARIABLE_IDE_REGISTER_COMMAND_IDENTIFY_SIZE
	mov	dx,	word [rsi]	; == VARIABLE_IDE_REGISTER_DATA
	rep	insw

	; przywróć licznik kontrolerów
	pop	rcx

	; kontynuuj z pozostałymi nośnikami
	jmp	.next_drive

;-----------------------------------------------------------------------
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

;-----------------------------------------------------------------------
; ustaw na swoje pozycje znaki
ide_decode:
	; początek tablicy
	mov	rsi,	qword [variable_ide_disks]

.next_record:
	; jeśli brak dalszych rekordów, koniec
	cmp	word [rsi],	VARIABLE_EMPTY
	je	.end

	; dekoduj nazwę nośnika
	mov	rcx,	( STRUCTURE_IDE_DISK.something2 - STRUCTURE_IDE_DISK.name ) / VARIABLE_WORD_SIZE
	add	rsi,	STRUCTURE_IDE_DISK.name

.loop_name:
	; pobierz dwa znaki z nazwy nośnika
	lodsw

	; zmień miejscami
	xchg	al,	ah

	; aktualizuj
	mov	word [rsi - VARIABLE_WORD_SIZE],	ax

	; kontynuuj z pozostałymi
	loop	.loop_name

	; dekoduj numer seryjny nośnika
	mov	rcx,	( STRUCTURE_IDE_DISK.something1 - STRUCTURE_IDE_DISK.serial ) / VARIABLE_WORD_SIZE
	sub	rsi,	STRUCTURE_IDE_DISK.something2
	add	rsi,	STRUCTURE_IDE_DISK.serial

.loop_serial:
	; pobierz dwa znaki z nazwy nośnika
	lodsw

	; zmień miejscami
	xchg	al,	ah

	; aktualizuj
	mov	word [rsi - VARIABLE_WORD_SIZE],	ax

	; kontynuuj z pozostałymi
	loop	.loop_serial

	; następny rekord
	sub	rsi,	STRUCTURE_IDE_DISK.something1
	add	rsi,	STRUCTURE_IDE_DISK.SIZE

	; kontynuuj
	jmp	.next_record

.end:
	; powrót z procedury
	ret

;-----------------------------------------------------------------------
; wyświetl podstawowe informacje o odnalezionych nośnikach
ide_show_devices:
	; wskaźnik początku tablicy
	mov	rdi,	qword [variable_ide_disks]

.loop:
	; jeśli brak następnych nośników do wyświetlenia, koniec
	cmp	word [rdi],	VARIABLE_EMPTY
	je	.end

	; przesuń kursor na poczatek listy
	mov	rbx,	VARIABLE_COLOR_DEFAULT
	mov	rcx,	VARIABLE_FULL
	mov	rsi,	text_subsub
	call	cyjon_screen_print_string

	; wyświetl informacje i kontrolerze i urządzeniu
	cmp	word [rdi + STRUCTURE_IDE_DISK.controller],	VARIABLE_IDE_PRIMARY
	jne	.secondary

	; kontroler 0
	mov	rsi,	variable_ide0
	jmp	.print_controller

.secondary:
	; kontroler 1
	mov	rsi,	variable_ide1

.print_controller:
	call	cyjon_screen_print_string

	; pozycja urządzenia w kontrolerze
	cmp	byte [rdi + STRUCTURE_IDE_DISK.device],	VARIABLE_IDE_MASTER
	jne	.slave

	; urządzenie pierwsze
	mov	rsi,	variable_master
	jmp	.print_device

.slave:
	; urządzenie drugie
	mov	rsi,	variable_slave

.print_device:
	call	cyjon_screen_print_string

	; zachowaj wskaźnik
	push	rdi

	; wyświetl nazwę nośnika ---------------------------------------
	mov	rbx,	VARIABLE_COLOR_WHITE
	mov	rcx,	STRUCTURE_IDE_DISK.something2 - STRUCTURE_IDE_DISK.name
	mov	rdx,	VARIABLE_COLOR_BACKGROUND_DEFAULT
	add	rdi,	STRUCTURE_IDE_DISK.name
	call	library_trim
	mov	rsi,	rdi
	call	cyjon_screen_print_string

	; wyświetl numer seryjny
	mov	rbx,	VARIABLE_COLOR_DEFAULT
	mov	cl,	VARIABLE_FULL
	mov	rsi,	text_ide_serial
	call	cyjon_screen_print_string

	; przywróć wskaźnik
	mov	rdi,	qword [rsp]

	; numer seryjny nośnika ----------------------------------------
	mov	rbx,	VARIABLE_COLOR_WHITE
	mov	rcx,	STRUCTURE_IDE_DISK.something1 - STRUCTURE_IDE_DISK.serial
	add	rdi,	STRUCTURE_IDE_DISK.serial
	call	library_trim
	mov	rsi,	rdi
	call	cyjon_screen_print_string

	; przesuń kursor do nowej linii
	mov	rcx,	VARIABLE_FULL
	mov	rsi,	text_return
	call	cyjon_screen_print_string

	; przywróć wskaźnik
	pop	rdi

	; przesuń wskaźnik na następny rekord tablicy
	add	rdi,	STRUCTURE_IDE_DISK.SIZE

	; kontynuuj
	jmp	.loop

.end:
	; powrót z procedury
	ret
