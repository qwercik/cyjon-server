;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

DAEMON_ETHERNET_CACHE_size		equ	1

daemon_variable_ethernet_semaphore	db	FALSE

daemon_variable_ethernet_cache		dq	EMPTY

;===============================================================================
daemon_ethernet:
	; przygotuj przestrzeń pod tablicę pakietów przychodzących
	call	kernel_page_request
	jc	.error	; błąd

	; wyczyść wszystkie rekordy w tablicy i zachowaj adres
	call	kernel_page_dump
	mov	qword [daemon_variable_ethernet_cache],	rdi

	; demon ethernet gotowy do pracy
	mov	byte [daemon_variable_ethernet_semaphore],	TRUE

.reload:
	; ustaw wskaźnik na początek tablicy
	mov	rsi,	qword [daemon_variable_ethernet_cache]

.restart:
	; ilość rekordów w tablicy
	mov	rcx,	(DAEMON_ETHERNET_CACHE_size * KERNEL_PAGE_SIZE_byte) >> DIVIDE_BY_8_shift

.loop:
	; przeszukano wszystkie rekordy?
	dec	rcx
	js	.restart	; tak, szukaj od początku

	; rekord zawiera wpis?
	cmp	qword [rsi + rcx * QWORD_SIZE_byte],	EMPTY
	je	.loop	; nie

.found:
	; pobierz wskaźnik do pakietu
	mov	rdi,	qword [rsi]

	; pakiet zawiera ramkę typu ARP?
	cmp	word [rdi + NETWORK_FRAME_ETHERNET_FIELD_TYPE],	NETWORK_FRAME_ETHERNET_FIELD_TYPE_ARP
	je	.arp	; tak

	; nie znany typ pakietu, porzuć

.clean:
	; zwolnij przestrzeń zajętą przez pakiet
	call	kernel_page_release

	; usuń wpis w buforze demona ethernet
	mov	qword [rsi],	EMPTY

	; pakiet obsłużony, przetwórz następny
	jmp	.reload

.error:
	; debug
	xchg	bx,bx

	; brak obsługi błędu (jeszcze)

	; zatrzymaj dalsze wykonywanie kodu
	jmp	$

.arp:
	; obsłużono pakiet arp
	jmp	.clean
