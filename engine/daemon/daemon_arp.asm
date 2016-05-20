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

VARIABLE_DAEMON_ARP_HTYPE						equ	0x0100	; 0x0001
VARIABLE_DAEMON_ARP_PTYPE						equ	0x0008	; 0x0800
VARIABLE_DAEMON_ARP_HLEN						equ	0x06	; MAC
VARIABLE_DAEMON_ARP_PLEN						equ	0x04	; IP
VARIABLE_DAEMON_ARP_OPERATION_REQUEST					equ	0x01
VARIABLE_DAEMON_ARP_OPERATION_ANSWER					equ	0x02

text_daemon_arp_name							db	"network_arp"
variable_daemon_arp_name_count						db	11

;debug
align	0x0100
variable_daemon_arp_frame	times VARIABLE_NETWORK_FRAME_ARP_SIZE	db	VARIABLE_EMPTY

; 64 Bitowy kod programu
[BITS 64]

; debug
align 0x0100

daemon_arp:
	; usługa sieciowa załączona?
	cmp	byte [variable_network_enabled],	VARIABLE_FALSE
	je	.stop	; nie

	; ilość rekordów w tablicy
	mov	rcx,	VARIABLE_MEMORY_PAGE_SIZE / VARIABLE_NETWORK_TABLE_64
	; wskaźnik do adresu tablicy
	mov	rsi,	qword [variable_network_table_rx_64]

.search:
	; szukaj ramki ARP
	cmp	word [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_FIELD_TYPE],	VARIABLE_NETWORK_FRAME_ETHERNET_FIELD_TYPE_ARP
	je	.found

.continue:
	; następny rekord
	add	rsi,	VARIABLE_NETWORK_TABLE_64
	loop	.search

.stop:
	; wstrzymaj demona
	hlt

	; koniec
	jmp	daemon_arp

.found:
	; zachowaj licznik
	push	rcx

	; Hardware Type
	cmp	word [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_ARP_FIELD_HTYPE],	VARIABLE_DAEMON_ARP_HTYPE
	jne	.mismatch

	; Protocol Type
	cmp	word [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_ARP_FIELD_PTYPE],	VARIABLE_DAEMON_ARP_PTYPE
	jne	.mismatch

	; Hardware Length / HAL
	cmp	byte [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_ARP_FIELD_HAL],	VARIABLE_DAEMON_ARP_HLEN
	jne	.mismatch

	; Protocol Length / PAL
	cmp	byte [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_ARP_FIELD_PAL],	VARIABLE_DAEMON_ARP_PLEN
	jne	.mismatch

	; czy ramka dotyczny naszego IP?
	mov	rax,	qword [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_ARP_FIELD_TARGET_IP]
	and	rax,	qword [variable_network_mac_filter]
	cmp	rax,	qword [variable_network_ip]
	jne	.mismatch	; nie

	; zachowaj wskanik do oryginalnego pakietu
	push	rsi

	; skopiuj pakiet do bufora
	mov	rdi,	variable_daemon_arp_frame
	mov	rcx,	VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_ARP_SIZE
	rep	movsb

	; zamień miejscami nadawcę <> odbiorcę
	mov	rdi,	variable_daemon_arp_frame
	mov	rax,	qword [rdi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_ARP_FIELD_SENDER_MAC]
	push	rax	; zapamiętaj nadawcę
	mov	bx,	word [rdi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_ARP_FIELD_SENDER_MAC + VARIABLE_QWORD_SIZE]
	xchg	rax,	qword [rdi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_ARP_FIELD_TARGET_MAC]
	xchg	bx,	word [rdi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_ARP_FIELD_TARGET_MAC + VARIABLE_QWORD_SIZE]
	mov	word [rdi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_ARP_FIELD_SENDER_MAC + VARIABLE_QWORD_SIZE],	bx

	; zmień typ operacji na odpowiedź
	mov	word [rdi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_ARP_FIELD_OPCODE],	0x0200

	; w odpowiedzi podaj nasz adres MAC
	mov	rdx,	0xFFFF000000000000
	and	rax,	rdx
	or	rax,	qword [variable_network_i8254x_mac_address]
	mov	qword [rdi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_ARP_FIELD_SENDER_MAC],	rax

	; odpowiedź wyślij do
	pop	rax
	and	rax,	qword [variable_network_mac_filter]
	mov	qword [rdi],	rax

	; odpowiedź od
	mov	rax,	qword [variable_network_i8254x_mac_address]
	mov	dword [rdi + VARIABLE_NETWORK_FRAME_ETHERNET_FIELD_SENDER],	eax
	shr	rax,	32
	mov	word [rdi + VARIABLE_NETWORK_FRAME_ETHERNET_FIELD_SENDER + VARIABLE_DWORD_SIZE],	ax

	; wyślij
	mov	rcx,	VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_ARP_SIZE
	mov	rsi,	rdi
	call	cyjon_network_i8254x_transmit_packet

	; usuń przetworzony pakiet z bufora
	pop	rsi

.mismatch:
	; ramka ARP jest nieobsługiwana, usuń rekord
	mov	rcx,	VARIABLE_NETWORK_TABLE_64 / VARIABLE_QWORD_SIZE
	add	rsi,	VARIABLE_NETWORK_TABLE_64

.clear:
	mov	qword [rsi - VARIABLE_QWORD_SIZE],	VARIABLE_EMPTY
	sub	rsi,	VARIABLE_QWORD_SIZE
	; wyczyść pozostałą część rekordu
	loop	.clear

	; przywróć licznik
	pop	rcx

	; przetwórz pozostałe rekordy
	jmp	.continue
