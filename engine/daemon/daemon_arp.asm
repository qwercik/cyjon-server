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

VARIABLE_DAEMON_ARP_HTYPE		equ	0x0100	; 0x0001
VARIABLE_DAEMON_ARP_PTYPE		equ	0x0008	; 0x0800
VARIABLE_DAEMON_ARP_HLEN		equ	0x06	; MAC
VARIABLE_DAEMON_ARP_PLEN		equ	0x04	; IP
VARIABLE_DAEMON_ARP_OPERATION_REQUEST	equ	0x01
VARIABLE_DAEMON_ARP_OPERATION_ANSWER	equ	0x02

variable_daemon_arp_name		db	"network_arp"
variable_daemon_arp_name_count		db	11

variable_daemon_arp_semaphore		db	VARIABLE_FALSE
variable_daemon_arp_cache		dq	VARIABLE_EMPTY

; 64 Bitowy kod programu
[BITS 64]

daemon_arp:
	; usługa sieciowa załączona?
	cmp	byte [variable_network_enabled],	VARIABLE_FALSE
	je	.stop	; nie

	; przydziel przestrzeń pod bufor
	call	cyjon_page_allocate
	cmp	rdi,	VARIABLE_EMPTY
	je	.stop	; brak miejsca

	; ustaw przestrzeń bufora
	mov	qword [variable_daemon_arp_cache],	rdi

.restart:
	; ilość rekordów w tablicy
	mov	rcx,	VARIABLE_MEMORY_PAGE_SIZE / VARIABLE_NETWORK_TABLE_64
	; wskaźnik do adresu tablicy
	mov	rsi,	qword [variable_daemon_arp_cache]

.search:
	; szukaj ramki w cache
	cmp	byte [rsi],	 VARIABLE_TRUE
	je	.found

.continue:
	; następny rekord
	add	rsi,	VARIABLE_NETWORK_TABLE_64
	loop	.search

.stop:
	; wstrzymaj demona
	hlt

	; koniec
	jmp	.restart

.found:
	; przesuń wkskaźnik na ramkę
	inc	rsi

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

	; zamień miejscami nadawcę <> odbiorcę
	mov	rax,	qword [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_ARP_FIELD_SENDER_MAC]
	push	rax	; zapamiętaj nadawcę
	mov	bx,	word [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_ARP_FIELD_SENDER_MAC + VARIABLE_QWORD_SIZE]
	xchg	rax,	qword [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_ARP_FIELD_TARGET_MAC]
	xchg	bx,	word [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_ARP_FIELD_TARGET_MAC + VARIABLE_QWORD_SIZE]
	mov	word [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_ARP_FIELD_SENDER_MAC + VARIABLE_QWORD_SIZE],	bx

	; zmień typ operacji na odpowiedź
	mov	word [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_ARP_FIELD_OPCODE],	0x0200

	; w odpowiedzi podaj nasz adres MAC
	mov	rdx,	0xFFFF000000000000
	and	rax,	rdx
	or	rax,	qword [variable_network_i8254x_mac_address]
	mov	qword [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_ARP_FIELD_SENDER_MAC],	rax

	; odpowiedź wyślij do
	pop	rax
	and	rax,	qword [variable_network_mac_filter]
	mov	qword [rsi],	rax

	; odpowiedź od
	mov	rax,	qword [variable_network_i8254x_mac_address]
	mov	dword [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_FIELD_SENDER],	eax
	shr	rax,	32
	mov	word [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_FIELD_SENDER + VARIABLE_DWORD_SIZE],	ax

	; wyślij
	mov	rcx,	VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_ARP_SIZE
	call	cyjon_network_i8254x_transmit_packet

.mismatch:
	; przesuń wkskaźnik na flagę ramki
	dec	rsi

	; ramka ARP jest nieobsługiwana, wyłącz rekord
	mov	byte [rsi],	VARIABLE_FALSE

	; przywróć licznik
	pop	rcx

	; przetwórz pozostałe rekordy
	jmp	.continue
