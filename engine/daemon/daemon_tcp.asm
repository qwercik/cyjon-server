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
; debug, 
VARIABLE_DAEMON_TCP_MSS_SIZE		equ	VARIABLE_MEMORY_PAGE_SIZE - VARIABLE_NETWORK_FRAME_ETHERNET_SIZE - VARIABLE_NETWORK_FRAME_IP_SIZE - VARIABLE_NETWORK_FRAME_TCP_SIZE - VARIABLE_QWORD_SIZE

; struktura rekordu opisującego zajęty port tcp
struc VARIABLE_DAEMON_TCP_PORT_RECORD
	.cr3	resq	1
	.rdi	resq	1
	.size	resb	1
endstruc

; struktura stosu tcp
struc VARIABLE_DAEMON_TCP_STACK_RECORD
	.mac_source	resb	6
	.ip_source	resb	4
	.port_source	resb	2
	.port_target	resb	2
	.seq		resb	4
	.ack		resb	4
	.flag		resb	1
	.mss		resb	4
	.size		resb	1
endstruc

; flaga, demon tcp został prawidłowo uruchomiony
variable_daemon_tcp_semaphore			db	VARIABLE_FALSE


variable_daemon_tcp_cache			dq	VARIABLE_EMPTY
variable_daemon_tcp_table_port			dq	VARIABLE_EMPTY
variable_daemon_tcp_stack			dq	VARIABLE_EMPTY

struc VARIABLE_DAEMON_TCP_PSEUDO_HEADER
	.ip_source	resb	4
	.ip_target	resb	4
	.null		resb	1
	.protocol	resb	1
	.tcp_frame_size	resb	2
	.size		resb	1
endstruc

; debug
align	0x0100

variable_daemon_tcp_pseudo_header		db	0, 0, 0, 0	; ip_source
						db	0, 0, 0, 0	; ip_target
						db	VARIABLE_EMPTY
						db	0x06	; tcp
						dw	0x0000	; tcp header + data

; demon tcp, przygotowuj w tym miejscu pakiet do wysłania (połączenia i rozłączenia)
variable_daemon_tcp_tmp		times VARIABLE_MEMORY_PAGE_SIZE	db	VARIABLE_EMPTY

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
	add	rsi,	VARIABLE_NETWORK_TABLE_MAX
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

	; oblicz pozycje rekordu/portu w tablicy
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
	cmp	al,	VARIABLE_NETWORK_FRAME_TCP_FIELD_FLAGS_SYN
	je	.create_connection

	; sprawdź, czy podziękowanie za nawiązanie połaczenia
	cmp	al,	VARIABLE_NETWORK_FRAME_TCP_FIELD_FLAGS_ACK
	je	.acknowledge_connection

	; sprawdź, czy przsład dane do procesu z danego portu
	cmp	al,	VARIABLE_NETWORK_FRAME_TCP_FIELD_FLAGS_PSH | VARIABLE_NETWORK_FRAME_TCP_FIELD_FLAGS_ACK
	je	.push_data

	; nie obsługiwany pakiet, zignoruj
	jmp	.mismatch

.create_connection:
	; sprawdź czy jest wolne miejsce na nawiązanie połączenia
	; tak, aktualnie stos tcp obsługuje tylko jedno połaczenie! (choć rozmiar stosu pozwala na więcej)
	; gdy tylko klient przyśle pierwsze zapytanie do działającego lokalnie serwera
	; połączenie zostanie zakończone i miejsce zwolnione
	; w przyszłości rozbuduję o mośliwość większej ilości połączeń na raz
	mov	rdi,	qword [variable_daemon_tcp_stack]
	cmp	dword [rdi + VARIABLE_DAEMON_TCP_STACK_RECORD.ip_source],	VARIABLE_EMPTY
	ja	.mismatch	; stos tcp pełny, nie nawiązuj połączenia, odrzuć pakiet

	; zachowaj wskaźnik do pakietu
	push	rsi

	; zachowaj wskaźnik do rekordu stosu
	push	rdi

	; zapisz adres MAC nadawcy
	mov	eax,	dword [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_FIELD_SENDER]
	stosd
	mov	ax,	word [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_FIELD_SENDER + VARIABLE_DWORD_SIZE]
	stosw

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

	; skopiuj oryginalny pakiet
	mov	rdi,	variable_daemon_tcp_tmp
	movzx	rcx,	byte [rsi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_IP_SIZE + VARIABLE_NETWORK_FRAME_TCP_FIELD_HEADER_LENGTH]
	shr	cl,	VARIABLE_DIVIDE_BY_4
	add	rcx,	VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_IP_SIZE
	push	rcx	; zapamiętaj rozmiar pakietu
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
	xor	rax,	rax	; inicjalizacja sumy
	call	cyjon_network_checksum_create
	; zapisz
	mov	word [rdi + VARIABLE_NETWORK_FRAME_IP_FIELD_CRC],	bx

	; zamień miejscami numery portów w ramce TCP ---------------------------
	add	rdi,	VARIABLE_NETWORK_FRAME_IP_SIZE
	mov	ax,	word [rdi + VARIABLE_NETWORK_FRAME_TCP_FIELD_PORT_SOURCE]
	xchg	ax,	word [rdi + VARIABLE_NETWORK_FRAME_TCP_FIELD_PORT_TARGET]
	mov	word [rdi + VARIABLE_NETWORK_FRAME_TCP_FIELD_PORT_SOURCE],	ax

	; pobierz numer sekwencji klienta
	inc	byte [rdi + VARIABLE_NETWORK_FRAME_TCP_FIELD_SEQUENCE + ( VARIABLE_BYTE_SIZE * 3 )]
	mov	eax,	dword [rdi + VARIABLE_NETWORK_FRAME_TCP_FIELD_SEQUENCE]
	; wyślij do klienta odpowiedź w polu potwierdzenia
	mov	dword [rdi + VARIABLE_NETWORK_FRAME_TCP_FIELD_ACKNOWLEDGEMENT],	eax
	; wyślij własny numer sekwencji, czyli ZERO (przy nawiązywaniu połączenia)
	mov	dword [rdi + VARIABLE_NETWORK_FRAME_TCP_FIELD_SEQUENCE],	VARIABLE_EMPTY

	; aktualizuj rekord na stosie tcp
	mov	rsi,	qword [rsp + VARIABLE_QWORD_SIZE]
	mov	dword [rsi + VARIABLE_DAEMON_TCP_STACK_RECORD.ack],	eax
	mov	dword [rsi + VARIABLE_DAEMON_TCP_STACK_RECORD.seq],	VARIABLE_EMPTY

	; ustaw flagę SYN + ACK
	mov	byte [rdi + VARIABLE_NETWORK_FRAME_TCP_FIELD_FLAGS],	VARIABLE_NETWORK_FRAME_TCP_FIELD_FLAGS_SYN + VARIABLE_NETWORK_FRAME_TCP_FIELD_FLAGS_ACK
	mov	byte [rsi + VARIABLE_DAEMON_TCP_STACK_RECORD.flag],	VARIABLE_NETWORK_FRAME_TCP_FIELD_FLAGS_SYN + VARIABLE_NETWORK_FRAME_TCP_FIELD_FLAGS_ACK

	; poinformuj klienta, że nie przyjmujemy wiecej niż VARIABLE_DAEMON_TCP_MSS_SIZE danych w jednym pakiecie
	mov	ax,	VARIABLE_DAEMON_TCP_MSS_SIZE
	xchg	al,	ah
	mov	word [rdi + VARIABLE_NETWORK_FRAME_TCP_FIELD_OPTIONS_MSS + VARIABLE_WORD_SIZE],	ax

	; przygotuj pseudo nagłówek
	mov	rdi,	variable_daemon_tcp_pseudo_header

	; ustaw adres ip źródłowy
	mov	eax,	dword [rsi + VARIABLE_DAEMON_TCP_STACK_RECORD.ip_source]
	mov	dword [rdi + VARIABLE_DAEMON_TCP_PSEUDO_HEADER.ip_source],	eax
	; ustaw adres ip docelowy
	mov	eax,	dword [variable_network_ip]
	mov	dword [rdi + VARIABLE_DAEMON_TCP_PSEUDO_HEADER.ip_target],	eax

	; rozmiar ramki tcp
	mov	rax,	qword [rsp]
	sub	rax,	VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_IP_SIZE
	xchg	al,	ah
	mov	word [rdi + VARIABLE_DAEMON_TCP_PSEUDO_HEADER.tcp_frame_size],	ax

	; oblicz sumę kontrolną w ramce TCP

	; suma kontrolna pseudo nagłówka
	xor	rax,	rax	; inicjalizacja sumy
	mov	rcx,	VARIABLE_DAEMON_TCP_PSEUDO_HEADER.size / VARIABLE_WORD_SIZE
	call	cyjon_network_checksum_create

	; suma kontrolna ramki TCP
	mov	rdi,	variable_daemon_tcp_tmp
	add	rdi,	VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_IP_SIZE
	mov	word [rdi + VARIABLE_NETWORK_FRAME_TCP_FIELD_CHECKSUM],	VARIABLE_EMPTY
	mov	rcx,	qword [rsp]
	sub	rcx,	VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_IP_SIZE
	shr	rcx,	VARIABLE_DIVIDE_BY_2
	mov	rax,	rbx	; połącz sumy kontrolne
	; koryguj
	xchg	al,	ah
	not	ax
	call	cyjon_network_checksum_create

	; połączone sumy kontrolne
	mov	rdi,	variable_daemon_tcp_tmp
	mov	word [rdi + VARIABLE_NETWORK_FRAME_ETHERNET_SIZE + VARIABLE_NETWORK_FRAME_IP_SIZE + VARIABLE_NETWORK_FRAME_TCP_FIELD_CHECKSUM],	bx

	; wyślij odpowiedź do klienta o zgodzie na nawiązanie połączenia
	pop	rcx
	mov	rsi,	variable_daemon_tcp_tmp
	call	cyjon_network_i8254x_transmit_packet

	; usuń wskaźnik do rekordu stosu
	add	rsp,	VARIABLE_QWORD_SIZE

	; przywróć wskaźnik do pakietu
	pop	rsi

	; koniec obsługi pakietu
	jmp	.mismatch

.acknowledge_connection:
	; zachowaj wskaźnik do pakietu
	push	rsi

	; ustaw wskaźnik do stosu tcp
	mov	rdi,	qword [variable_daemon_tcp_stack]

	; sprawdź adres IP połączenia
	add	rsi,	VARIABLE_NETWORK_FRAME_ETHERNET_SIZE	; przesuń wskaźnik na ramkę IP
	mov	eax,	dword [rdi + VARIABLE_DAEMON_TCP_STACK_RECORD.ip_source]
	cmp	dword [rsi + VARIABLE_NETWORK_FRAME_IP_FIELD_SENDER_IP],	eax
	jne	.mismatch	; inne połączenie

	; sprawdź numer portu połączenia
	add	rsi,	VARIABLE_NETWORK_FRAME_IP_SIZE	; przesuń wskaźnik na ramkę TCP
	mov	ax,	word [rsi + VARIABLE_NETWORK_FRAME_TCP_FIELD_PORT_TARGET]
	cmp	word [rdi + VARIABLE_DAEMON_TCP_STACK_RECORD.port_target],	ax
	jne	.mismatch	; inny port

	; aktualizuj rekord na stosie TCP

	; zapisz numer portu nadawcy
	mov	ax,	word [rsi + VARIABLE_NETWORK_FRAME_TCP_FIELD_PORT_SOURCE]
	mov	word [rdi + VARIABLE_DAEMON_TCP_STACK_RECORD.port_source],	ax

	; zapisz numer sekwencji
	mov	eax,	dword [rsi + VARIABLE_NETWORK_FRAME_TCP_FIELD_SEQUENCE]
	mov	dword [rdi + VARIABLE_DAEMON_TCP_STACK_RECORD.seq],	eax

	; zapisz numer akceptacji
	mov	eax,	dword [rsi + VARIABLE_NETWORK_FRAME_TCP_FIELD_ACKNOWLEDGEMENT]
	mov	dword [rdi + VARIABLE_DAEMON_TCP_STACK_RECORD.ack],	eax

	; zapisz flagi
	mov	al,	byte [rsi + VARIABLE_NETWORK_FRAME_TCP_FIELD_FLAGS]
	mov	byte [rdi + VARIABLE_DAEMON_TCP_STACK_RECORD.flag],	al	

	; przywróć wskaźnik pakietu
	pop	rsi

	; zakończ obsługę pakietu
	jmp	.mismatch

.push_data:
	; debug
	xchg	bx,	bx

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
