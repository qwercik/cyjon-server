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
VARIABLE_NETWORK_TABLE_2048				equ	VARIABLE_MEMORY_PAGE_SIZE / 2
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
VARIABLE_NETWORK_FRAME_ETHERNET_FIELD_SENDER		equ	VARIABLE_NETWORK_FRAME_ETHERNET_FIELD_TARGET + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE_TARGET
VARIABLE_NETWORK_FRAME_ETHERNET_FIELD_TYPE		equ	VARIABLE_NETWORK_FRAME_ETHERNET_FIELD_SENDER + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE_SENDER
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
VARIABLE_NETWORK_FRAME_IP_FIELD_PROTOCOL_TCP		equ	0x06
VARIABLE_NETWORK_FRAME_IP_FIELD_CRC			equ	VARIABLE_NETWORK_FRAME_IP_FIELD_PROTOCOL + VARIABLE_NETWORK_FRAME_IP_SIZE_PROTOCOL
VARIABLE_NETWORK_FRAME_IP_FIELD_SENDER_IP		equ	VARIABLE_NETWORK_FRAME_IP_FIELD_CRC + VARIABLE_NETWORK_FRAME_IP_SIZE_CRC
VARIABLE_NETWORK_FRAME_IP_FIELD_TARGET_IP		equ	VARIABLE_NETWORK_FRAME_IP_FIELD_SENDER_IP + VARIABLE_NETWORK_FRAME_IP_SIZE_SENDER_IP
VARIABLE_NETWORK_FRAME_IP_FIELD_OPTIONS			equ	VARIABLE_NETWORK_FRAME_IP_FIELD_TARGET_IP + VARIABLE_NETWORK_FRAME_IP_SIZE_TARGET_IP

VARIABLE_NETWORK_FRAME_TCP_SIZE_PORT_SOURCE		equ	0x02
VARIABLE_NETWORK_FRAME_TCP_SIZE_PORT_TARGET		equ	0x02
VARIABLE_NETWORK_FRAME_TCP_SIZE_SEQUENCE		equ	0x04
VARIABLE_NETWORK_FRAME_TCP_SIZE_ACKNOWLEDGEMENT		equ	0x04
VARIABLE_NETWORK_FRAME_TCP_SIZE_HEADER_LENGTH		equ	0x01
VARIABLE_NETWORK_FRAME_TCP_SIZE_FLAGS			equ	0x01
VARIABLE_NETWORK_FRAME_TCP_SIZE_WINDOW_SIZE		equ	0x02
VARIABLE_NETWORK_FRAME_TCP_SIZE_CHECKSUM		equ	0x02
VARIABLE_NETWORK_FRAME_TCP_SIZE_URGENT_POINTER		equ	0x02
VARIABLE_NETWORK_FRAME_TCP_SIZE_OPTIONS			equ	0x04
VARIABLE_NETWORK_FRAME_TCP_SIZE				equ	VARIABLE_NETWORK_FRAME_TCP_SIZE_PORT_SOURCE + VARIABLE_NETWORK_FRAME_TCP_SIZE_PORT_TARGET + VARIABLE_NETWORK_FRAME_TCP_SIZE_SEQUENCE + VARIABLE_NETWORK_FRAME_TCP_SIZE_ACKNOWLEDGEMENT + VARIABLE_NETWORK_FRAME_TCP_SIZE_HEADER_LENGTH + VARIABLE_NETWORK_FRAME_TCP_SIZE_FLAGS + VARIABLE_NETWORK_FRAME_TCP_SIZE_WINDOW_SIZE + VARIABLE_NETWORK_FRAME_TCP_SIZE_CHECKSUM + VARIABLE_NETWORK_FRAME_TCP_SIZE_URGENT_POINTER
VARIABLE_NETWORK_FRAME_TCP_FIELD_PORT_SOURCE		equ	0x00
VARIABLE_NETWORK_FRAME_TCP_FIELD_PORT_TARGET		equ	VARIABLE_NETWORK_FRAME_TCP_SIZE_PORT_SOURCE
VARIABLE_NETWORK_FRAME_TCP_FIELD_SEQUENCE		equ	VARIABLE_NETWORK_FRAME_TCP_FIELD_PORT_TARGET + VARIABLE_NETWORK_FRAME_TCP_SIZE_PORT_TARGET
VARIABLE_NETWORK_FRAME_TCP_FIELD_ACKNOWLEDGEMENT	equ	VARIABLE_NETWORK_FRAME_TCP_FIELD_SEQUENCE + VARIABLE_NETWORK_FRAME_TCP_SIZE_SEQUENCE
VARIABLE_NETWORK_FRAME_TCP_FIELD_HEADER_LENGTH		equ	VARIABLE_NETWORK_FRAME_TCP_FIELD_ACKNOWLEDGEMENT + VARIABLE_NETWORK_FRAME_TCP_SIZE_ACKNOWLEDGEMENT
VARIABLE_NETWORK_FRAME_TCP_FIELD_FLAGS			equ	VARIABLE_NETWORK_FRAME_TCP_FIELD_HEADER_LENGTH + VARIABLE_NETWORK_FRAME_TCP_SIZE_HEADER_LENGTH
VARIABLE_NETWORK_FRAME_TCP_FIELD_FLAGS_FIN		equ	00000001b
VARIABLE_NETWORK_FRAME_TCP_FIELD_FLAGS_SYN		equ	00000010b
VARIABLE_NETWORK_FRAME_TCP_FIELD_FLAGS_RST		equ	00000100b
VARIABLE_NETWORK_FRAME_TCP_FIELD_FLAGS_PSH		equ	00001000b
VARIABLE_NETWORK_FRAME_TCP_FIELD_FLAGS_ACK		equ	00010000b
VARIABLE_NETWORK_FRAME_TCP_FIELD_FLAGS_URG		equ	00100000b
VARIABLE_NETWORK_FRAME_TCP_FIELD_WINDOW_SIZE		equ	VARIABLE_NETWORK_FRAME_TCP_FIELD_FLAGS + VARIABLE_NETWORK_FRAME_TCP_SIZE_FLAGS
VARIABLE_NETWORK_FRAME_TCP_FIELD_CHECKSUM		equ	VARIABLE_NETWORK_FRAME_TCP_FIELD_WINDOW_SIZE + VARIABLE_NETWORK_FRAME_TCP_SIZE_WINDOW_SIZE
VARIABLE_NETWORK_FRAME_TCP_FIELD_URGENT_POINTER		equ	VARIABLE_NETWORK_FRAME_TCP_FIELD_CHECKSUM + VARIABLE_NETWORK_FRAME_TCP_SIZE_CHECKSUM
VARIABLE_NETWORK_FRAME_TCP_FIELD_OPTIONS		equ	VARIABLE_NETWORK_FRAME_TCP_FIELD_URGENT_POINTER + VARIABLE_NETWORK_FRAME_TCP_SIZE_URGENT_POINTER
VARIABLE_NETWORK_FRAME_TCP_FIELD_OPTIONS_MSS		equ	VARIABLE_NETWORK_FRAME_TCP_FIELD_OPTIONS

struc	VARIABLE_NETWORK_PACKET
	.flag	resb	1
	.data	resb	VARIABLE_MEMORY_PAGE_SIZE - 1
	.SIZE	resb	1
endstruc

VARIABLE_NETWORK_PORT_HTTP				equ	0x5000	; 80

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

variable_network_ip			db	10, 0, 0, 1, VARIABLE_EMPTY, VARIABLE_EMPTY, VARIABLE_EMPTY, VARIABLE_EMPTY

; dla 512 portów
variable_network_port_table		dq	VARIABLE_EMPTY

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

	; tablica portów
	call	cyjon_page_allocate
	cmp	rdi,	VARIABLE_EMPTY
	je	.continue
	; nie udało się zaalokować przestrzeni pamięci pod tablicę portów,
	; tym samym nie będzie działać protokół TCP, wyłączamy dostęp do sieci

	; zapisz wskaźnik
	mov	qword [variable_network_port_table],	rdi

	; wyczyść porty (wszystkie dostępne)
	call	cyjon_page_clear

	; włącz obsługę przerwania
	mov	cx,	ax
	call	cyjon_programmable_interrupt_controller_enable_irq

	; pobierz status kontrolera sieci
	call	cyjon_network_i8254x_irq

	; koniec
	jmp	.end

;===============================================================================
; obsługa przerwania sprzętowego kontrolera sieci
; procedura odbiera pakiety od karty sieciowej
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

	; sprawdź gotowość bufora stosu ethernet
	cmp	byte [variable_daemon_ethernet_semaphore],	VARIABLE_FALSE
	je	.receive_end	; nie jest gotowy, zignoruj pakiet

	; adres przestrzeni cache karty sieciowej
	mov	rsi,	qword [variable_network_i8254x_rx_cache]
	; adres przestrzeni bufora stosu ethernet
	mov	rdi,	qword [variable_daemon_ethernet_cache_in]

	; debug
	xchg	bx,	bx

	; pobierz informacje z pola TYPE ramki Ethernet ------------------------
	mov	cx,	word [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_FIELD_TYPE]

	; jeśli wartość mniejsza od 0x0800, jest to rozmiar ramki Ethernet
	cmp	cx,	0x0800
	jb	.receive_move

	; ramka ARP ma stały rozmiar (nie posiada danych) ----------------------
	mov	cx,	VARIABLE_NETWORK_FRAME_ARP_SIZE + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE

	; sprawdź pakiet zawiera ramkę ARP
	cmp	word [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_FIELD_TYPE],	VARIABLE_NETWORK_FRAME_ETHERNET_FIELD_TYPE_ARP
	je	.receive_move

	; sprawdź pakiet pod kątem zawartości ramki IP
	cmp	word [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_FIELD_TYPE],	VARIABLE_NETWORK_FRAME_ETHERNET_FIELD_TYPE_IP
	jne	.receive_end	; przychodzący pakiet nie został rozpoznany, zignoruj

	; pobierz rozmiar ramki IP
	movzx	rcx,	word [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_IP_FIELD_TOTAL_LENGTH]
	add	rcx,	VARIABLE_NETWORK_FRAME_ETHERNET_SIZE	; dodaj rozmiar ramki Ethernet

	; sprawdź czy rozmiar pakietu jest obsługiwany
	cmp	cx,	VARIABLE_NETWORK_PACKET.SIZE - VARIABLE_BYTE_SIZE	; -1 Bajt, rozmiar flagi rekordu
	jb	.receive_move

	; przychodzący pakiet jest za duży, brak obsługi, zignoruj

.receive_end:
	; przywóć oryginalne rejestry
	pop	rdi
	pop	rsi
	pop	rdx
	pop	rcx
	pop	rbx
	pop	rax

	; poinformuj kontroler o zakończeniu przetwarzania pakietu
	mov	rsi,	qword [variable_network_i8254x_base_address]
	mov	dword [rsi + VARIABLE_NIC_INTEL_82540EM_RDH],	VARIABLE_EMPTY
	mov	dword [rsi + VARIABLE_NIC_INTEL_82540EM_RDT],	VARIABLE_TRUE

	; zresetuj deskryptor rx
	mov	rcx,	qword [variable_network_i8254x_rx_cache]
	mov	dword [variable_network_i8254x_rx_descriptor],	ecx

	; karta sieciowa gotowa do dalszej pracy
	jmp	.end

.receive_move:
	; rozmiar rekordu na stosie Ethernet
	mov	rcx,	VARIABLE_DAEMON_ETHERNET_STACK_SIZE * VARIABLE_MEMORY_PAGE_SIZE / VARIABLE_NETWORK_PACKET.SIZE

.loop:
	; szukaj wolnego miejsca w stosie Ethernet
	cmp	word [rdi + VARIABLE_NETWORK_FRAME_ETHERNET_FIELD_TYPE],	VARIABLE_EMPTY
	jne	.receive_next

	; pomiń flagę rekordu stosu Ethernet
	push	rdi
	inc	rdi

	; przenieś/kopiuj
	rep	movsb

	; ustaw flagę rekordu stosu Ethernet na gotowy
	pop	rdi
	mov	byte [rdi],	VARIABLE_TRUE

	; koniec obsługi pakietu
	jmp	.receive_end

.receive_next:
	; następny rekord
	add	rdi,	VARIABLE_NETWORK_PACKET.SIZE
	loop	.loop

	; brak miejsca na stosie Ethernet, zignoruj pakiet
	jmp	.receive_end

;===============================================================================
; wylicza sumę kontrolną fragmentu pamięci
; IN:
;	rax - wstępna suma kontrolna
;	rcx - rozmiar fragmentu w Słowach [dw]
;	rdi - wskaźnik do fragmentu pamięci
;
; OUT:
;	bx - suma kontrolna
;
; pozostałe rejestry zachowane
cyjon_network_checksum_create:
	; zachowaj oryginalne rejestry
	push	rax
	push	rcx
	push	rdi

.checksum:
	; pobierz pierwsze słowo
	movzx	rbx,	word [rdi]
	xchg	bl,	bh	; koryguj pozycje

	; dodaj do akumulatora
	add	rax,	rbx

	; przesuń wskaźnik na następne słowo
	add	rdi,	VARIABLE_WORD_SIZE

	; wykonaj operacje z pozostałymi słowami ramki ICMP
	loop	.checksum

	; koryguj sumę kontrolną o przepełnienia rejestru AX
	mov	bx,	ax
	shr	eax,	VARIABLE_MOVE_HIGH_EAX_TO_AX
	add	rbx,	rax

	; odwróć wartość i ustaw na miejsca
	not	bx
	xchg	bl,	bh

	; przywróć oryginalne rejestry
	pop	rdi
	pop	rcx
	pop	rax

	; powrót z procedury
	ret
