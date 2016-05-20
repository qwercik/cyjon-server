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
VARIABLE_NETWORK_TABLE_MAX				equ	VARIABLE_MEMORY_PAGE_SIZE
VARIABLE_NETWORK_TABLE_1024				equ	VARIABLE_MEMORY_PAGE_SIZE / 4
VARIABLE_NETWORK_TABLE_512				equ	VARIABLE_MEMORY_PAGE_SIZE / 8
VARIABLE_NETWORK_TABLE_256				equ	VARIABLE_MEMORY_PAGE_SIZE / 16
VARIABLE_NETWORK_TABLE_128				equ	VARIABLE_MEMORY_PAGE_SIZE / 32
VARIABLE_NETWORK_TABLE_64				equ	VARIABLE_MEMORY_PAGE_SIZE / 64

VARIABLE_NETWORK_FRAME_ETHERNET_SIZE_TARGET		equ	0x06
VARIABLE_NETWORK_FRAME_ETHERNET_SIZE_SENDER		equ	0x06
VARIABLE_NETWORK_FRAME_ETHERNET_SIZE_TYPE		equ	0x02
VARIABLE_NETWORK_FRAME_ETHERNET_SIZE			equ	VARIABLE_NETWORK_FRAME_ETHERNET_SIZE_TARGET + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE_SENDER + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE_TYPE
VARIABLE_NETWORK_FRAME_ETHERNET_FIELD_TARGET		equ	0x00
VARIABLE_NETWORK_FRAME_ETHERNET_FIELD_SENDER		equ	VARIABLE_NETWORK_FRAME_ETHERNET_SIZE_TARGET
VARIABLE_NETWORK_FRAME_ETHERNET_FIELD_TYPE		equ	VARIABLE_NETWORK_FRAME_ETHERNET_SIZE_TARGET + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE_SENDER
VARIABLE_NETWORK_FRAME_ETHERNET_FIELD_TYPE_ARP		equ	0x0608
VARIABLE_NETWORK_FRAME_ETHERNET_FIELD_TYPE_IP		equ	0x0008

VARIABLE_NETWORK_FRAME_ARP_SIZE_HTYPE			equ	0x02
VARIABLE_NETWORK_FRAME_ARP_SIZE_PTYPE			equ	0x02
VARIABLE_NETWORK_FRAME_ARP_SIZE_HAL			equ	0x01
VARIABLE_NETWORK_FRAME_ARP_SIZE_PAL			equ	0x01
VARIABLE_NETWORK_FRAME_ARP_SIZE_OPCODE			equ	0x02
VARIABLE_NETWORK_FRAME_ARP_SIZE_SENDER_MAC		equ	0x06
VARIABLE_NETWORK_FRAME_ARP_SIZE_SENDER_IP		equ	0x04
VARIABLE_NETWORK_FRAME_ARP_SIZE_TARGET_MAC		equ	0x06
VARIABLE_NETWORK_FRAME_ARP_SIZE_TARGET_IP		equ	0x04
VARIABLE_NETWORK_FRAME_ARP_SIZE				equ	VARIABLE_NETWORK_FRAME_ARP_SIZE_HTYPE + VARIABLE_NETWORK_FRAME_ARP_SIZE_PTYPE + VARIABLE_NETWORK_FRAME_ARP_SIZE_HAL + VARIABLE_NETWORK_FRAME_ARP_SIZE_PAL + VARIABLE_NETWORK_FRAME_ARP_SIZE_OPCODE + VARIABLE_NETWORK_FRAME_ARP_SIZE_SENDER_MAC + VARIABLE_NETWORK_FRAME_ARP_SIZE_SENDER_IP + VARIABLE_NETWORK_FRAME_ARP_SIZE_TARGET_MAC + VARIABLE_NETWORK_FRAME_ARP_SIZE_TARGET_IP
VARIABLE_NETWORK_FRAME_ARP_FIELD_HTYPE			equ	0x00
VARIABLE_NETWORK_FRAME_ARP_FIELD_PTYPE			equ	VARIABLE_NETWORK_FRAME_ARP_FIELD_HTYPE + VARIABLE_NETWORK_FRAME_ARP_SIZE_HTYPE
VARIABLE_NETWORK_FRAME_ARP_FIELD_HAL			equ	VARIABLE_NETWORK_FRAME_ARP_FIELD_PTYPE + VARIABLE_NETWORK_FRAME_ARP_SIZE_PTYPE
VARIABLE_NETWORK_FRAME_ARP_FIELD_PAL			equ	VARIABLE_NETWORK_FRAME_ARP_FIELD_HAL + VARIABLE_NETWORK_FRAME_ARP_SIZE_HAL
VARIABLE_NETWORK_FRAME_ARP_FIELD_OPCODE			equ	VARIABLE_NETWORK_FRAME_ARP_FIELD_PAL + VARIABLE_NETWORK_FRAME_ARP_SIZE_PAL
VARIABLE_NETWORK_FRAME_ARP_FIELD_SENDER_MAC		equ	VARIABLE_NETWORK_FRAME_ARP_FIELD_OPCODE + VARIABLE_NETWORK_FRAME_ARP_SIZE_OPCODE
VARIABLE_NETWORK_FRAME_ARP_FIELD_SENDER_IP		equ	VARIABLE_NETWORK_FRAME_ARP_FIELD_SENDER_MAC + VARIABLE_NETWORK_FRAME_ARP_SIZE_SENDER_MAC
VARIABLE_NETWORK_FRAME_ARP_FIELD_TARGET_MAC		equ	VARIABLE_NETWORK_FRAME_ARP_FIELD_SENDER_IP + VARIABLE_NETWORK_FRAME_ARP_SIZE_SENDER_IP
VARIABLE_NETWORK_FRAME_ARP_FIELD_TARGET_IP		equ	VARIABLE_NETWORK_FRAME_ARP_FIELD_TARGET_MAC + VARIABLE_NETWORK_FRAME_ARP_SIZE_TARGET_MAC

VARIABLE_NETWORK_FRAME_IP_SIZE_VERSION_IHL		equ	0x01
VARIABLE_NETWORK_FRAME_IP_SIZE_DSCP_ECN			equ	0x01
VARIABLE_NETWORK_FRAME_IP_SIZE_TOTAL_LENGTH		equ	0x02
VARIABLE_NETWORK_FRAME_IP_SIZE_IDENTIFICATION		equ	0x02
VARIABLE_NETWORK_FRAME_IP_SIZE_FLAGS_FRAGMENT_OFFSET	equ	0x02
VARIABLE_NETWORK_FRAME_IP_SIZE_TTL			equ	0x01
VARIABLE_NETWORK_FRAME_IP_SIZE_PROTOCOL			equ	0x01
VARIABLE_NETWORK_FRAME_IP_SIZE_CRC			equ	0x02
VARIABLE_NETWORK_FRAME_IP_SIZE_SENDER_IP		equ	0x04
VARIABLE_NETWORK_FRAME_IP_SIZE_TARGET_IP		equ	0x04
VARIABLE_NETWORK_FRAME_IP_SIZE				equ	VARIABLE_NETWORK_FRAME_IP_SIZE_VERSION_IHL + VARIABLE_NETWORK_FRAME_IP_SIZE_DSCP_ECN + VARIABLE_NETWORK_FRAME_IP_SIZE_TOTAL_LENGTH + VARIABLE_NETWORK_FRAME_IP_SIZE_IDENTIFICATION + VARIABLE_NETWORK_FRAME_IP_SIZE_FLAGS_FRAGMENT_OFFSET + VARIABLE_NETWORK_FRAME_IP_SIZE_TTL + VARIABLE_NETWORK_FRAME_IP_SIZE_PROTOCOL + VARIABLE_NETWORK_FRAME_IP_SIZE_CRC + VARIABLE_NETWORK_FRAME_IP_SIZE_SENDER_IP + VARIABLE_NETWORK_FRAME_IP_SIZE_TARGET_IP
VARIABLE_NETWORK_FRAME_IP_FIELD_VERSION_IHL		equ	0x00
VARIABLE_NETWORK_FRAME_IP_FIELD_DSCP_ECN		equ	VARIABLE_NETWORK_FRAME_IP_FIELD_VERSION_IHL + VARIABLE_NETWORK_FRAME_IP_SIZE_VERSION_IHL
VARIABLE_NETWORK_FRAME_IP_FIELD_TOTAL_LENGTH		equ	VARIABLE_NETWORK_FRAME_IP_FIELD_DSCP_ECN + VARIABLE_NETWORK_FRAME_IP_SIZE_DSCP_ECN
VARIABLE_NETWORK_FRAME_IP_FIELD_IDENTIFICATION		equ	VARIABLE_NETWORK_FRAME_IP_FIELD_TOTAL_LENGTH + VARIABLE_NETWORK_FRAME_IP_SIZE_TOTAL_LENGTH
VARIABLE_NETWORK_FRAME_IP_FIELD_FLAGS_FRAGMENT_OFFSET	equ	VARIABLE_NETWORK_FRAME_IP_FIELD_IDENTIFICATION + VARIABLE_NETWORK_FRAME_IP_SIZE_IDENTIFICATION
VARIABLE_NETWORK_FRAME_IP_FIELD_TTL			equ	VARIABLE_NETWORK_FRAME_IP_FIELD_FLAGS_FRAGMENT_OFFSET + VARIABLE_NETWORK_FRAME_IP_SIZE_FLAGS_FRAGMENT_OFFSET
VARIABLE_NETWORK_FRAME_IP_FIELD_PROTOCOL		equ	VARIABLE_NETWORK_FRAME_IP_FIELD_TTL + VARIABLE_NETWORK_FRAME_IP_SIZE_TTL
VARIABLE_NETWORK_FRAME_IP_FIELD_PROTOCOL_ICMP		equ	0x01
VARIABLE_NETWORK_FRAME_IP_FIELD_CRC			equ	VARIABLE_NETWORK_FRAME_IP_FIELD_PROTOCOL + VARIABLE_NETWORK_FRAME_IP_SIZE_PROTOCOL
VARIABLE_NETWORK_FRAME_IP_FIELD_SENDER_IP		equ	VARIABLE_NETWORK_FRAME_IP_FIELD_CRC + VARIABLE_NETWORK_FRAME_IP_SIZE_CRC
VARIABLE_NETWORK_FRAME_IP_FIELD_TARGET_IP		equ	VARIABLE_NETWORK_FRAME_IP_FIELD_SENDER_IP + VARIABLE_NETWORK_FRAME_IP_SIZE_SENDER_IP
VARIABLE_NETWORK_FRAME_IP_FIELD_OPTIONS			equ	VARIABLE_NETWORK_FRAME_IP_FIELD_TARGET_IP + VARIABLE_NETWORK_FRAME_IP_SIZE_TARGET_IP

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
	cmp	word [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_FIELD_TYPE],	VARIABLE_NETWORK_FRAME_ETHERNET_FIELD_TYPE_ARP
	je	.arp

	; ramka typu IP
	cmp	word [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_FIELD_TYPE],	VARIABLE_NETWORK_FRAME_ETHERNET_FIELD_TYPE_IP
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
	mov	rbx,	VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_ARP_SIZE
	mov	rcx,	VARIABLE_MEMORY_PAGE_SIZE / VARIABLE_NETWORK_TABLE_64
	mov	rdi,	qword [variable_network_table_rx_64]

	; załaduj ramkę do bufora
	call	network_frame_move

	; koniec
	jmp	.rx_end

;-------------------------------------------------------------------------------
.ip:
	; protokół ICMP?
	cmp	byte [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_IP_FIELD_PROTOCOL],	VARIABLE_NETWORK_FRAME_IP_FIELD_PROTOCOL_ICMP
	je	.icmp

	; brak obsługi
	jmp	.rx_end

; debug
align 0x0100


.icmp:
	mov	bl,	VARIABLE_COLOR_LIGHT_GREEN
	mov	rcx,	1
	mov	dl,	VARIABLE_COLOR_BACKGROUND_DEFAULT
	mov	rsi,	text_icmp
	call	cyjon_screen_print_string

	; koniec
	jmp	.rx_end

text_icmp	db	".", VARIABLE_ASCII_CODE_TERMINATOR

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
