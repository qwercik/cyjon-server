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

VARIABLE_DAEMON_ETHERNET_NAME_COUNT	equ	16
variable_daemon_ethernet_name		db	"network_ethernet"

; flaga, demon ethernet został prawidłowo uruchomiony
variable_daemon_ethernet_semaphore	db	VARIABLE_FALSE

; miejsce na przetwarzane pakiety
VARIABLE_DAEMON_ETHERNET_CACHE_SIZE	equ	8	; max 256
variable_daemon_ethernet_cache_in	dq	VARIABLE_EMPTY
variable_daemon_ethernet_cache_out	dq	VARIABLE_EMPTY

struc	VARIABLE_DAEMON_ETHERNET_CACHE_OUT_RECORD
	.id	resb	1
	.size	resb	2
	.data	resb	1
endstruc

; tablica przetworzonych pakietów
VARIABLE_DAEMON_ETHERNET_STACK_SIZE	equ	1
variable_daemon_ethernet_stack		dq	VARIABLE_EMPTY

struc	VARIABLE_DAEMON_ETHERNET_STACK_RECORD
	.mac_source	resb	6
	.mac_target	resb	6
	.type		resb	2
	.SIZE		resb	1
endstruc

; przestrzeń przetwarzania pakietów do wysłania
VARIABLE_DAEMON_ETHERNET_TRANSFORM_SIZE	equ	( VARIABLE_NETWORK_PACKET.SIZE / VARIABLE_MEMORY_PAGE_SIZE ) + 1	; +1 gdyby została reszta z dzielenia
variable_daemon_ethernet_transform	dq	VARIABLE_EMPTY

; 64 Bitowy kod programu
[BITS 64]

daemon_ethernet:
	; usługa sieciowa załączona?
	cmp	byte [variable_network_enabled],	VARIABLE_FALSE
	je	.stop	; nie

	; rozmiar buforów
	mov	rcx,	VARIABLE_DAEMON_ETHERNET_CACHE_SIZE

	; przydziel przestrzeń pod bufor pakietów przychodzących
	call	cyjon_page_find_free_memory_physical
	cmp	rdi,	VARIABLE_EMPTY
	je	.stop	; brak miejsca

	; zapisz adres
	call	cyjon_page_clear
	mov	qword [variable_daemon_ethernet_cache_in],	rdi

	; przydziel przestrzeń pod bufor pakietów wychodzących
	call	cyjon_page_find_free_memory_physical
	cmp	rdi,	VARIABLE_EMPTY
	je	.stop	; brak miejsca

	; zapisz adres
	call	cyjon_page_clear
	mov	qword [variable_daemon_ethernet_cache_out],	rdi

	; przydziel przestrzeń pod stos ethernet
	call	cyjon_page_allocate
	cmp	rdi,	VARIABLE_EMPTY
	je	.stop	; brak miejsca

	; zapisz adres
	call	cyjon_page_clear
	mov	qword [variable_daemon_ethernet_stack],	rdi

	; przydziel przestrzeń pod przetwarzane pakiety
	call	cyjon_page_find_free_memory_physical
	cmp	rdi,	VARIABLE_EMPTY
	je	.stop	; brak miejsca

	; zapisz adres
	mov	qword [variable_daemon_ethernet_transform],	rdi

	; demon ethernet gotowy
	mov	byte [variable_daemon_ethernet_semaphore],	VARIABLE_TRUE

.out:
	; najpierw wyślij pakiety z bufora wyjściowego

	; ilość możliwych pakietów przechowywanych w buforze wyjściowym
	mov	rcx,	VARIABLE_DAEMON_ETHERNET_CACHE_SIZE * VARIABLE_MEMORY_PAGE_SIZE / VARIABLE_NETWORK_PACKET.SIZE

	; wskaźnik do bufora wyjściowego
	mov	rsi,	qword [variable_daemon_ethernet_cache_out]

.out_search:
	; szukaj aktywnego rekordu
	cmp	byte [rsi + VARIABLE_DAEMON_ETHERNET_CACHE_OUT_RECORD.id],	VARIABLE_EMPTY
	ja	.out_found

.out_continue:
	; następny rekord
	add	rsi,	VARIABLE_NETWORK_PACKET.SIZE
	loop	.out_search

.in:
	; wstrzymaj demona
	hlt

	; koniec
	jmp	.out

;===============================================================================
.out_found:
	; zachowaj licznik i wskaźnik do pakietu
	push	rcx
	push	rsi

	; pobierz numer rekordu stosu do którego odwołuje się pakiet
	movzx	rax,	byte [rsi + VARIABLE_DAEMON_ETHERNET_CACHE_OUT_RECORD.id]

	; przelicz na pozycję rekordu w stosie ethernet
	mov	rcx,	VARIABLE_DAEMON_ETHERNET_STACK_RECORD.SIZE
	xor	rdx,	rdx
	mul	rcx

	; przygotuj pakiet do wysłania -----------------------------------------

	; wskaźnik do przestrzeni stosu i przestrzeni wysyłania pakietów
	mov	rsi,	qword [variable_daemon_ethernet_stack]
	mov	rdi,	qword [variable_daemon_ethernet_transform]

	; ustaw nagłówek Ethernet
	mov	rcx,	VARIABLE_DAEMON_ETHERNET_STACK_RECORD.SIZE
	rep	movsb

	; dołącz do nagłówka wysyłany pakiet -----------------------------------

	; wskaźnik do rekordu pakietu do wysłania
	mov	rsi,	qword [rsp]

	; pobierz rozmiar pakietu do wysłania
	movzx	rcx,	word [rsi + VARIABLE_DAEMON_ETHERNET_CACHE_OUT_RECORD.size]
	push	rcx	; zapamiętaj

	; przesuń wskaźnik na dane pakietu
	add	rsi,	VARIABLE_DAEMON_ETHERNET_CACHE_OUT_RECORD.data

	; kopiuj
	rep	movsb

	; wyślij pakiet --------------------------------------------------------

	; ustaw wskaźnik początku pakietu do wysłania
	mov	rsi,	qword [variable_daemon_ethernet_transform]

	; przywróć rozmiar pakietu
	pop	rcx

	; koryguj o rozmiar nagłówka Ethernet
	add	rsi,	VARIABLE_NETWORK_FRAME_ETHERNET_SIZE

	; wyślij
	call	cyjon_network_i8254x_transmit_packet

	; przywróć wskaźnik do wysłanego pakietu w przestrzeni wychodzącej
	pop	rsi

.mismatch:
	; pakiet przetworzony/nieobsługiwany, wyłącz rekord
	mov	byte [rsi],	VARIABLE_EMPTY

	; przywróć licznik
	pop	rcx

	; przetwórz pozostałe rekordy
	jmp	.out_continue

.stop:
	; cdn.
	jmp	$
