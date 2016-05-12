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

VARIABLE_DAEMON_ARP_FRAME_DATA_HTYPE		equ	0x00	; 0x02
VARIABLE_DAEMON_ARP_FRAME_DATA_PTYPE		equ	0x02	; 0x02
VARIABLE_DAEMON_ARP_FRAME_DATA_HLEN		equ	0x04	; 0x01
VARIABLE_DAEMON_ARP_FRAME_DATA_PLEN		equ	0x05	; 0x01
VARIABLE_DAEMON_ARP_FRAME_DATA_OPERATION	equ	0x06	; 0x02
VARIABLE_DAEMON_ARP_FRAME_DATA_SENDER_MAC	equ	0x08	; 0x06
VARIABLE_DAEMON_ARP_FRAME_DATA_SENDER_IP	equ	0x0E	; 0x04
VARIABLE_DAEMON_ARP_FRAME_DATA_TARGET_MAC	equ	0x12	; 0x06
VARIABLE_DAEMON_ARP_FRAME_DATA_TARGET_IP	equ	0x18	; 0x04

VARIABLE_DAEMON_ARP_HTYPE			equ	0x0100	; 0x0001
VARIABLE_DAEMON_ARP_PTYPE			equ	0x0008	; 0x0800
VARIABLE_DAEMON_ARP_HLEN			equ	0x06	; MAC
VARIABLE_DAEMON_ARP_PLEN			equ	0x04	; IP
VARIABLE_DAEMON_ARP_OPERATION_REQUEST		equ	0x01
VARIABLE_DAEMON_ARP_OPERATION_ANSWER		equ	0x02

text_daemon_arp_name			db	"daemon_network_arp"
variable_daemon_arp_name_count		db	18

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
	cmp	word [rsi + VARIABLE_NETWORK_FRAME_TYPE],	VARIABLE_NETWORK_FRAME_TYPE_ARP
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
	cmp	word [rsi + VARIABLE_NETWORK_FRAME_DATA + VARIABLE_DAEMON_ARP_FRAME_DATA_HTYPE],	VARIABLE_DAEMON_ARP_HTYPE
	jne	.mismatch

	; Protocol Type
	cmp	word [rsi + VARIABLE_NETWORK_FRAME_DATA + VARIABLE_DAEMON_ARP_FRAME_DATA_PTYPE],	VARIABLE_DAEMON_ARP_PTYPE
	jne	.mismatch

	; Hardware Length / HLEN
	cmp	byte [rsi + VARIABLE_NETWORK_FRAME_DATA + VARIABLE_DAEMON_ARP_FRAME_DATA_HLEN],	VARIABLE_DAEMON_ARP_HLEN
	jne	.mismatch

	; Protocol Length / PLEN
	cmp	byte [rsi + VARIABLE_NETWORK_FRAME_DATA + VARIABLE_DAEMON_ARP_FRAME_DATA_PLEN],	VARIABLE_DAEMON_ARP_PLEN
	jne	.mismatch

	jmp	$

; debug
align 0x0100

	; rekord przetworzony, wyczyść
	jmp	.mismatch

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
