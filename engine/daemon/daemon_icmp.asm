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

VARIABLE_DAEMON_ICMP_TYPE			equ	0x00
VARIABLE_DAEMON_ICMP_TYPE_PING			equ	0x08
VARIABLE_DAEMON_ICMP_TYPE_REPLY			equ	0x00
VARIABLE_DAEMON_ICMP_CODE			equ	0x01
VARIABLE_DAEMON_ICMP_CHECKSUM			equ	0x02
VARIABLE_DAEMON_ICMP_IDENTIFIER			equ	0x04
VARIABLE_DAEMON_ICMP_SEQUENCE_NUMBER		equ	0x06
VARIABLE_DAEMON_ICMP_DATA			equ	0x08

variable_daemon_icmp_name			db	"network_icmp"
variable_daemon_icmp_name_count			db	12

variable_daemon_icmp_semaphore			db	VARIABLE_FALSE
variable_daemon_icmp_cache			dq	VARIABLE_EMPTY

; 64 Bitowy kod programu
[BITS 64]

daemon_icmp:
	; usługa sieciowa załączona?
	cmp	byte [variable_network_enabled],	VARIABLE_FALSE
	je	.stop	; nie

	; przydziel przestrzeń pod bufor
	call	cyjon_page_allocate
	cmp	rdi,	VARIABLE_EMPTY
	je	.stop	; brak miejsca

	; ustaw przestrzeń bufora i flagę dostępności
	mov	qword [variable_daemon_icmp_cache],	rdi
	mov	byte [variable_daemon_icmp_semaphore],	VARIABLE_TRUE

.restart:
	; ilość rekordów w tablicy
	mov	rcx,	VARIABLE_MEMORY_PAGE_SIZE / VARIABLE_NETWORK_TABLE_128
	; wskaźnik do adresu tablicy
	mov	rsi,	qword [variable_daemon_icmp_cache]

.search:
	; szukaj aktywnego rekordu
	cmp	byte [rsi],	VARIABLE_TRUE
	je	.found

.continue:
	; następny rekord
	add	rsi,	VARIABLE_NETWORK_TABLE_128
	loop	.search

.stop:
	; wstrzymaj demona
	hlt

	; koniec
	jmp	.restart

.found:
	; zachowaj licznik
	push	rcx

	; przesuń wkskaźnik na ramkę
	inc	rsi

	; ustaw ramkę jako odpowiedź
	mov	byte [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_IP_SIZE + VARIABLE_DAEMON_ICMP_TYPE],	VARIABLE_DAEMON_ICMP_TYPE_REPLY

	; oblicz sumę kontrolną

	; rozmiar ramki ICMP
	movzx	rcx,	word [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_IP_FIELD_TOTAL_LENGTH]
	xchg	cl,	ch
	sub	rcx,	VARIABLE_NETWORK_FRAME_IP_SIZE	; nagłówek ramki IP nie bierze udziału w obliczeniach
	push	rcx	; zachowaj
	shr	rcx,	VARIABLE_DIVIDE_BY_2	; zamień na słowa

	; wyczyść sumę kontrolną, akumulator i ustaw kopię wskaźnika do ramki
	mov	word [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_IP_SIZE + VARIABLE_DAEMON_ICMP_CHECKSUM],	VARIABLE_EMPTY
	xor	rax,	rax
	mov	rdi,	rsi

.checksum:
	; pobierz pierwsze słowo
	movzx	rbx,	word [rdi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_IP_SIZE]
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

	; zapisz sumę kontrolną ramki ICMP
	mov	word [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_IP_SIZE + VARIABLE_DAEMON_ICMP_CHECKSUM],	bx

	; zamień nadawcę i odbiorcę w ramce Ethernet
	mov	eax,	dword [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_FIELD_SENDER]
	mov	bx,	word [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_FIELD_SENDER + VARIABLE_DWORD_SIZE]
	xchg	eax,	dword [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_FIELD_TARGET]
	xchg	bx,	word [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_FIELD_TARGET + VARIABLE_DWORD_SIZE]
	mov	dword [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_FIELD_SENDER],	eax
	mov	word [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_FIELD_SENDER + VARIABLE_DWORD_SIZE],	bx

	; zamień nadawcę i odbiorcę w ramce IP
	mov	eax,	dword [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_IP_FIELD_SENDER_IP]
	xchg	eax,	dword [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_IP_FIELD_TARGET_IP]
	mov	dword [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_IP_FIELD_SENDER_IP],	eax

	; przywróć rozmiar ramki ICMP
	pop	rcx

	; oblicz rozmiar pakietu
	add	rcx,	VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_IP_SIZE
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
