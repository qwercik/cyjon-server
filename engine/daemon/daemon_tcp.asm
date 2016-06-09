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

variable_daemon_tcp_name			db	"network_tcp"
variable_daemon_tcp_name_count			db	11

; obsługa pierwszych 256 portów [0..255], VARIABLE_DAEMON_TCP_PORT_RECORD.size -> Bajtów na opis jednego rekordu/portu
VARIABLE_DAEMON_TCP_PORT_TABLE_SIZE		equ	VARIABLE_MEMORY_PAGE_SIZE

struc VARIABLE_DAEMON_TCP_PORT_RECORD
	.cr3	resq	1
	.rdi	resq	1
	.size	resb	1
endstruc

struc VARIABLE_DAEMON_TCP_STACK_RECORD
	.mac_source	resq	1
	.mac_target	resq	1
	.ip_source	resd	1
	.ip_target	resd	1
	.port_source	resw	1
	.port_target	resw	1
	.seq		resd	1
	.ack		resd	1
	.flag		resw	1
	.mss		resd	1
	.size		resb	1
endstruc

variable_daemon_tcp_semaphore			db	VARIABLE_FALSE

variable_daemon_tcp_cache			dq	VARIABLE_EMPTY
variable_daemon_tcp_table_port			dq	VARIABLE_EMPTY
variable_daemon_tcp_stack			dq	VARIABLE_EMPTY

; 64 Bitowy kod programu
[BITS 64]

daemon_tcp:
	; usługa sieciowa załączona?
	cmp	byte [variable_network_enabled],	VARIABLE_FALSE
	je	.stop	; nie

	; przydziel przestrzeń pod bufor
	call	cyjon_page_allocate
	cmp	rdi,	VARIABLE_EMPTY
	je	.stop	; brak miejsca

	; ustaw przestrzeń bufora
	mov	qword [variable_daemon_tcp_cache],	rdi

	; przydziel miejsce pod tablicę portów
	call	cyjon_page_allocate
	cmp	rdi,	VARIABLE_EMPTY
	je	.stop	; brak miejsca

	; zapisz adres tablicy portów
	call	cyjon_page_clear	; wszystkie porty dostępne
	mov	qword [variable_daemon_tcp_table_port],	rdi

	; przydziel miejsce pod stos tcp
	call	cyjon_page_allocate
	cmp	rdi,	VARIABLE_EMPTY
	je	.stop	; brak miejsca

	; zapisz adres stosu tcp
	call	cyjon_page_clear
	mov	qword [variable_daemon_tcp_stack],	rdi

	; demon tcp gotowy
	mov	byte [variable_daemon_tcp_semaphore],	VARIABLE_TRUE

.restart:
	; ilość rekordów w tablicy
	mov	rcx,	VARIABLE_MEMORY_PAGE_SIZE / VARIABLE_NETWORK_TABLE_MAX
	; wskaźnik do adresu tablicy
	mov	rsi,	qword [variable_daemon_tcp_cache]

.search:
	; szukaj aktywnego rekordu
	cmp	byte [rsi],	VARIABLE_TRUE
	je	.found

.continue:
	; następny rekord
	add	rsi,	VARIABLE_NETWORK_TABLE_128
	loop	.search

	; wstrzymaj demona
	hlt

	; koniec
	jmp	.restart

.stop:
	; cdn.
	jmp	$

.found:
	; zachowaj licznik
	push	rcx

	; przesuń wkskaźnik na ramkę
	inc	rsi

	; sprawdź port docelowy pakietu
	movzx	rax,	word [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_IP_SIZE + VARIABLE_NETWORK_FRAME_TCP_FIELD_PORT_TARGET]
	xchg	al,	ah

	; port obsługiwany?
	cmp	rax,	VARIABLE_DAEMON_TCP_PORT_TABLE_SIZE / VARIABLE_DAEMON_TCP_PORT_RECORD.size
	ja	.mismatch

	; czy z portu korzysta jakiś proces?

	; oblicz przesunięcie rekordu w tablicy
	xor	rdx,	rdx
	mov	rcx,	VARIABLE_DAEMON_TCP_PORT_RECORD.size
	mul	rcx

	; sprawdź rekord tablicy portów
	mov	rdi,	qword [variable_daemon_tcp_table_port]
	cmp	qword [rdi + rax],	VARIABLE_EMPTY
	je	.mismatch	; port wolny

	; debug
	xchg	bx,	bx

	; port jest wykorzystywany przez jakiś proces
	; sprawdź prośbę o nawiązanie połączenia
	mov	al,	byte [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_IP_SIZE + VARIABLE_NETWORK_FRAME_TCP_FIELD_FLAGS]
	test	al,	VARIABLE_NETWORK_FRAME_TCP_FIELD_FLAGS_SYN
	jnz	.create_connection

	jmp	$

.create_connection:
	; sprawdź czy jest wolne miejsce na nawiązanie połączenia
	; tak, aktualnie stos tcp obsługuje tylko jedno połaczenie!
	cmp	dword [rdi + VARIABLE_DAEMON_TCP_STACK_RECORD.ip_source],	VARIABLE_EMPTY
	ja	.mismatch	; stos tcp pełny, nie nawiązuj połączenia, odrzuć pakiet

	jmp	$

.mismatch:
	; przesuń wkskaźnik na flagę ramki
	dec	rsi

	; ramka TCP jest nieobsługiwana, wyłącz rekord
	mov	byte [rsi],	VARIABLE_FALSE

	; przywróć licznik
	pop	rcx

	; przetwórz pozostałe rekordy
	jmp	.continue
