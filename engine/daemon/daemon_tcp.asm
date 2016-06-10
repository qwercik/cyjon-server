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
	.ip_source	resd	1
	.port_source	resw	1
	.port_target	resw	1
	.seq		resd	1
	.ack		resd	1
	.flag		resb	1
	.mss		resd	1
	.size		resb	1
endstruc

variable_daemon_tcp_semaphore			db	VARIABLE_FALSE

variable_daemon_tcp_cache			dq	VARIABLE_EMPTY
variable_daemon_tcp_table_port			dq	VARIABLE_EMPTY
variable_daemon_tcp_stack			dq	VARIABLE_EMPTY
variable_daemon_tcp_tmp		times 512	db	VARIABLE_EMPTY

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

	; debug
	align	0x1000
	xchg	bx,	bx

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

	; port jest wykorzystywany przez jakiś proces

	; sprawdź prośbę o nawiązanie połączenia
	mov	al,	byte [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_IP_SIZE + VARIABLE_NETWORK_FRAME_TCP_FIELD_FLAGS]
	test	al,	VARIABLE_NETWORK_FRAME_TCP_FIELD_FLAGS_SYN
	jnz	.create_connection

	; sprawdź, czy podziękowanie za nawiązanie połaczenia
	test	al,	VARIABLE_NETWORK_FRAME_TCP_FIELD_FLAGS_ACK
	jnz	.acknowledge_connection

	jmp	$

.create_connection:
	; sprawdź czy jest wolne miejsce na nawiązanie połączenia
	; tak, aktualnie stos tcp obsługuje tylko jedno połaczenie!
	; gdy tylko klient przyśle pierwsze zapytanie do działającego lokalnie serwera
	; połączenie zostanie zakończone i miejsce zwolnione
	; w przyszłości rozbuduję o mośliwość większej ilości połączeń na raz
	mov	rdi,	qword [variable_daemon_tcp_stack]
	cmp	dword [rdi + VARIABLE_DAEMON_TCP_STACK_RECORD.ip_source],	VARIABLE_EMPTY
	ja	.mismatch	; stos tcp pełny, nie nawiązuj połączenia, odrzuć pakiet

	; zachowaj wskaźnik rekordu
	push	rdi

	; zapisz adres MAC nadawcy
	mov	rax,	qword [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_FIELD_SENDER]
	and	rax,	qword [variable_network_mac_filter]
	stosq

	; zapisz adres IP nadawcy
	mov	eax,	dword [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_IP_FIELD_SENDER_IP]
	stosd

	; zapisz numer portu nadawcy
	mov	ax,	word [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_IP_SIZE + VARIABLE_NETWORK_FRAME_TCP_FIELD_PORT_SOURCE]
	stosw

	; zapisz docelowy numer portu
	mov	ax,	word [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_IP_SIZE + VARIABLE_NETWORK_FRAME_TCP_FIELD_PORT_TARGET]
	stosw

	; zapisz numer sekwencji
	mov	eax,	dword [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_IP_SIZE + VARIABLE_NETWORK_FRAME_TCP_FIELD_SEQUENCE]
	stosd

	; zapisz numer akceptacji
	mov	eax,	dword [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_IP_SIZE + VARIABLE_NETWORK_FRAME_TCP_FIELD_ACKNOWLEDGEMENT]
	stosd

	; zapisz flagi
	mov	al,	byte [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_IP_SIZE + VARIABLE_NETWORK_FRAME_TCP_FIELD_FLAGS]
	stosb

	; zapisz negocjowany rozmiar pakietu
	mov	eax,	dword [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_IP_SIZE + VARIABLE_NETWORK_FRAME_TCP_FIELD_OPTIONS_MSS]
	stosd

	; wyślij informacje o przyjęciu połączenia

	; zachowaj wskaźnik do pakietu
	push	rsi

	; skopiuj oryginalny pakiet
	mov	rdi,	variable_daemon_tcp_tmp
	movzx	rcx,	byte [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_IP_SIZE + VARIABLE_NETWORK_FRAME_TCP_FIELD_HEADER_LENGTH]
	shr	cl,	VARIABLE_DIVIDE_BY_4
	add	rcx,	VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_IP_SIZE
	rep	movsb

	; przetwórz na pakiet zwrotny
	mov	rdi,	variable_daemon_tcp_tmp

	; zamień miejscami adresy MAC w ramce Ethernet -------------------------
	mov	eax,	dword [rdi]
	mov	bx,	word [rdi + VARIABLE_DWORD_SIZE]
	xchg	eax,	dword [rdi + VARIABLE_NETWORK_FRAME_ETHERNET_FIELD_SENDER]
	xchg	bx,	word [rdi + VARIABLE_NETWORK_FRAME_ETHERNET_FIELD_SENDER + VARIABLE_DWORD_SIZE]
	mov	dword [rdi],	eax
	mov	word [rdi + VARIABLE_DWORD_SIZE],	bx

	; zamień miejscami adresy IP w ramce IP --------------------------------
	add	rdi,	VARIABLE_NETWORK_FRAME_ETHERNET_SIZE
	mov	eax,	dword [rdi + VARIABLE_NETWORK_FRAME_IP_FIELD_SENDER_IP]
	xchg	eax,	dword [rdi + VARIABLE_NETWORK_FRAME_IP_FIELD_TARGET_IP]
	mov	dword [rdi + VARIABLE_NETWORK_FRAME_IP_FIELD_SENDER_IP],	eax

	; oblicz sumę kontrolną w ramce IP
	mov	word [rdi + VARIABLE_NETWORK_FRAME_IP_FIELD_CRC],	VARIABLE_EMPTY
	mov	rcx,	VARIABLE_NETWORK_FRAME_IP_SIZE / VARIABLE_WORD_SIZE
	call	cyjon_network_checksum_create
	; zapisz
	mov	word [rdi + VARIABLE_NETWORK_FRAME_IP_FIELD_CRC],	bx

	; zamień miejscami numery portów w ramce TCP ---------------------------
	add	rdi,	VARIABLE_NETWORK_FRAME_IP_SIZE
	mov	ax,	word [rdi + VARIABLE_NETWORK_FRAME_TCP_FIELD_PORT_SOURCE]
	xchg	ax,	word [rdi + VARIABLE_NETWORK_FRAME_TCP_FIELD_PORT_TARGET]
	mov	word [rdi + VARIABLE_NETWORK_FRAME_TCP_FIELD_PORT_SOURCE],	ax

	; pobierz numer sekwencji klienta
	mov	rsi,	qword [rsp + VARIABLE_QWORD_SIZE]
	xor	eax,	eax
	xchg	eax,	dword [rsi + VARIABLE_DAEMON_TCP_STACK_RECORD.seq]	; pobierz z stosu tcp i zresetuj
	; aktualizuj numer potwierdzenia klienta i zapisz do pakietu zwrotnego
	inc	eax
	mov	dword [rdi + VARIABLE_NETWORK_FRAME_TCP_FIELD_ACKNOWLEDGEMENT],	eax
	; nasz numer sekwencji ZERO
	mov	dword [rdi + VARIABLE_NETWORK_FRAME_TCP_FIELD_SEQUENCE],	VARIABLE_EMPTY
	; zaaktualizuj rekord na stosie tcp
	mov	dword [rsi + VARIABLE_DAEMON_TCP_STACK_RECORD.ack],	eax

	jmp	$

.acknowledge_connection:
	; zatwierdź udane połączenie z klientem
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
