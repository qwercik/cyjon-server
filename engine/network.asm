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

; rozmiary rekordów w tablicach
VARIABLE_NETWORK_TABLE_MAX			equ	4096
VARIABLE_NETWORK_TABLE_1024			equ	1024
VARIABLE_NETWORK_TABLE_512			equ	512
VARIABLE_NETWORK_TABLE_256			equ	256
VARIABLE_NETWORK_TABLE_128			equ	128
VARIABLE_NETWORK_TABLE_64			equ	64

VARIABLE_NETWORK_FRAME_ETHERNET_SIZE		equ	0x06 + 0x06 + 0x02	; sender MAC + target MAC + Ethernet Type
VARIABLE_NETWORK_FRAME_ETHERNET_SIZE_TARGET	equ	0x06
VARIABLE_NETWORK_FRAME_ETHERNET_SIZE_SENDER	equ	0x06
VARIABLE_NETWORK_FRAME_ETHERNET_SIZE_TYPE	equ	0x02

VARIABLE_NETWORK_FRAME_ETHERNET_FIELD_TARGET	equ	0x00
VARIABLE_NETWORK_FRAME_ETHERNET_FIELD_SENDER	equ	VARIABLE_NETWORK_FRAME_ETHERNET_SIZE_TARGET
VARIABLE_NETWORK_FRAME_ETHERNET_FIELD_TYPE	equ	VARIABLE_NETWORK_FRAME_ETHERNET_SIZE_TARGET + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE_SENDER


VARIABLE_NETWORK_FRAME_ARP_SIZE			equ	0x2A
VARIABLE_NETWORK_FRAME_IP_SIZE			equ	0x14

VARIABLE_NETWORK_FRAME_IP_PROTOCOL		equ	0x00

VARIABLE_NETWORK_FRAME_MAC_DESTINATION	equ	VARIABLE_EMPTY
VARIABLE_NETWORK_FRAME_MAC_SOURCE	equ	0x0006
VARIABLE_NETWORK_FRAME_TYPE		equ	0x000C
VARIABLE_NETWORK_FRAME_TYPE_ARP		equ	0x0608
VARIABLE_NETWORK_FRAME_TYPE_IP		equ	0x0008
VARIABLE_NETWORK_FRAME_DATA		equ	0x000E
VARIABLE_NETWORK_FRAME_DATA_IP_SIZE	equ	0x000E + 0x02	; word

variable_network_i8254x_base_address	dq	VARIABLE_EMPTY
variable_network_i8254x_irq		db	VARIABLE_EMPTY
variable_network_i8254x_rx_descriptor	dq	VARIABLE_EMPTY
variable_network_i8254x_rx_cache	dq	VARIABLE_EMPTY
variable_network_i8254x_tx_cache	dq	VARIABLE_EMPTY
variable_network_i8254x_mac_address	dq	VARIABLE_EMPTY

; miejsce na pakiety przychodzące
variable_network_table_rx_max		dq	VARIABLE_EMPTY
variable_network_table_rx_1024		dq	VARIABLE_EMPTY
variable_network_table_rx_512		dq	VARIABLE_EMPTY
variable_network_table_rx_256		dq	VARIABLE_EMPTY
variable_network_table_rx_128		dq	VARIABLE_EMPTY
variable_network_table_rx_64		dq	VARIABLE_EMPTY

variable_network_enabled		db	VARIABLE_TRUE
variable_network_mac_filter		dq	0x0000FFFFFFFFFFFF

variable_network_ip			dq	0x00000000

; 64 bitowy kod
[BITS 64]

;===============================================================================
; wykrywa i inicjalizuje jedną z dostępnych kart sieciowych
; IN:
;	brak
;
; OUT:
;	brak
;
; wszystkie rejestry zachowane
network_init:
	; zachowaj oryginalne rejestry
	push	rax
	push	rbx
	push	rcx
	push	rdx

	; szukaj od początku
	xor	rbx,	rbx
	xor	rcx,	rcx
	; sprawdzaj klasę/subklasę urządzenia/kontrolera
	mov	rdx,	2

.next:
	; pobierz klasę/subklasę
	call	cyjon_pci_read

	; przesuń starszą część do młodszej
	shr	eax,	16

	; kontroler sieci?
	cmp	ax,	VARIABLE_NIC
	je	.check

.continue:
	; następne urządzenie
	inc	ecx

	; koniec urządzeń na szynie?
	cmp	ecx,	256
	jb	.next

	; następna szyna
	inc	ebx

	; zacznij przeszukiwać od początku szyny
	xor	ecx,	ecx

	; koniec szyn?
	cmp	ebx,	256
	jb	.next

	; wyłącz obsługę sieci
	mov	byte [variable_network_enabled],	VARIABLE_FALSE

.end:
	; nie znaleziono jakiegokolwiek kontrolera sieci

	; przywróć oryginalne rejestry
	pop	rdx
	pop	rcx
	pop	rbx
	pop	rax

	; powrót z procedury
	ret

.check:
	; pobierz identyfikator Firmy(Vendor) i Urządzenia(Device)
	xor	edx,	edx
	call	cyjon_pci_read

	; kontroler sieci typu i8254x?
	cmp	eax,	VARIABLE_NIC_INTEL_82540EM_PCI
	je	cyjon_network_i8254x_init

	; nieznany kontroler sieci, szukaj dalej
	jmp	.continue

.configured:
	; podłącz procedurę obsługi przerwania kontrolera sieci
	mov	rdi,	network
	call	cyjon_interrupt_descriptor_table_isr_hardware_mount

	; tablica ramek przychodzących nie większych niż 64 Bajty
	call	cyjon_page_allocate
	call	cyjon_page_clear
	mov	qword [variable_network_table_rx_64],	rdi

	; włącz obsługę przerwania
	mov	cx,	ax
	call	cyjon_programmable_interrupt_controller_enable_irq

	; pobierz status kontrolera sieci
	call	cyjon_network_i8254x_irq

	; koniec
	jmp	.end

;===============================================================================
; obsługa przerwania sprzętowego kontrolera sieci
; procedura odbiera ramki ethernet od karty sieciowej
; i zapisuje do bufora demona ethernet
; IN:
;	brak
;
; OUT:
;	brak
;
; wszystkie rejestry zachowane
network:
	; zachowaj oryginalne rejestry
	push	rax
	push	rcx
	push	rsi
	pushf

	; pobierz status kontrolera
	call	cyjon_network_i8254x_irq

	; przerwanie wywołane poprzez wysyłany pakiet? (TX)
	bt	eax,	0
	jc	.transfer

	; przerwanie wywołane poprzez przychodzący pakiet? (RX)
	bt	eax,	7
	jc	.receive

.end:
	; poinformuj kontroler PIC o obsłużeniu przerwania sprzętowego
	mov	al,	0x20

	; przerwane obsługiwane w trybie kaskady?
	cmp	byte [variable_network_i8254x_irq],	8
	jb	.no_cascade

	; wyślij do kontrolera "kaskadowego"
	out	VARIABLE_PIC_COMMAND_PORT1,	al

.no_cascade:
	; wyślij do kontrolera głównego
	out	VARIABLE_PIC_COMMAND_PORT0,	al

	; przywróć oryginalne rejestry
	popf
	pop	rsi
	pop	rcx
	pop	rax

	; koniec obsługi przerwania sprzętowego
	iretq

;-------------------------------------------------------------------------------
.transfer:
	; czy wystąpiło jednocześnie wysłanie pakietu?
	bt	eax,	7
	jnc	.end	; nie

;-------------------------------------------------------------------------------
.receive:
	; zachowaj oryginalne rejestry
	push	rax
	push	rbx
	push	rcx
	push	rdx
	push	rsi
	push	rdi

	; dostęp do karty sieciowej jest możliwy?
	cmp	byte [variable_network_enabled],	VARIABLE_FALSE
	je	.rx_end	; nie

	; adres przestrzeni cache karty sieciowej
	mov	rsi,	qword [variable_network_i8254x_rx_cache]

	; ramka typu ARP
	cmp	word [rsi + VARIABLE_NETWORK_FRAME_TYPE],	VARIABLE_NETWORK_FRAME_TYPE_ARP
	je	.arp

	; ramka typu IP
	cmp	word [rsi + VARIABLE_NETWORK_FRAME_TYPE],	VARIABLE_NETWORK_FRAME_TYPE_IP
	je	.ip

.rx_end:
	; przywóć oryginalne rejestry
	pop	rdi
	pop	rsi
	pop	rdx
	pop	rcx
	pop	rbx
	pop	rax

	; poinformuj kontroler o przetworzonym pakiecie
	mov	rsi,	qword [variable_network_i8254x_base_address]
	mov	dword [rsi + VARIABLE_NIC_INTEL_82540EM_RDH],	VARIABLE_EMPTY
	mov	dword [rsi + VARIABLE_NIC_INTEL_82540EM_RDT],	VARIABLE_TRUE

	; zresetuj deskryptor rx
	mov	rcx,	qword [variable_network_i8254x_rx_cache]
	mov	dword [variable_network_i8254x_rx_descriptor],	ecx

	; pakiet obsłużony
	jmp	.end

;-------------------------------------------------------------------------------
.arp:
	; załaduj ramkę do bufora
	mov	rax,	VARIABLE_NETWORK_TABLE_64
	mov	rbx,	VARIABLE_NETWORK_FRAME_ARP_SIZE
	mov	rcx,	VARIABLE_MEMORY_PAGE_SIZE / VARIABLE_NETWORK_TABLE_64
	mov	rdi,	qword [variable_network_table_rx_64]

	; załaduj ramkę do bufora
	call	network_frame_move

	; koniec
	jmp	.rx_end

;-------------------------------------------------------------------------------
.ip:
	; protokół ICMP?
	;cmp	byte [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_IP_PROTOCOL],	VARIABLE_DAEMON_ICMP_PROTOCOL
	;je	.icmp

	; brak obsługi
	jmp	.rx_end

.ip_move:
	; załaduj ramkę do bufora
	call	network_frame_move

	; koniec
	jmp	.rx_end

network_frame_move:
	; szukaj wolnego miejsca
	cmp	qword [rdi],	VARIABLE_EMPTY
	je	.found_empty

	; następny rekord
	add	rdi,	rax
	loop	network_frame_move

.end:
	; brak miejsca w buforze
	ret

.found_empty:
	; kopiuj
	mov	rcx,	rbx
	rep	movsb

	; koniec obsługi
	ret
