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

variable_daemon_http_name			db	"network_http"
variable_daemon_http_name_count			db	12

variable_daemon_http_semaphore			db	VARIABLE_FALSE
variable_daemon_http_cache			dq	VARIABLE_EMPTY

; 64 Bitowy kod programu
[BITS 64]

daemon_http:
	; usługa sieciowa załączona?
	cmp	byte [variable_network_enabled],	VARIABLE_FALSE
	je	.stop	; nie

	; przydziel przestrzeń pod bufor
	call	cyjon_page_allocate
	cmp	rdi,	VARIABLE_EMPTY
	je	.stop	; brak miejsca

	; ustaw przestrzeń bufora i flagę dostępności
	mov	qword [variable_daemon_http_cache],	rdi
	mov	byte [variable_daemon_http_semaphore],	VARIABLE_TRUE

.restart:
	; ilość rekordów w tablicy
	mov	rcx,	VARIABLE_MEMORY_PAGE_SIZE / VARIABLE_NETWORK_TABLE_MAX
	; wskaźnik do adresu tablicy
	mov	rsi,	qword [variable_daemon_http_cache]

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

	; todo

.mismatch:
	; przesuń wkskaźnik na flagę ramki
	dec	rsi

	; ramka TCP jest nieobsługiwana, wyłącz rekord
	mov	byte [rsi],	VARIABLE_FALSE

	; przywróć licznik
	pop	rcx

	; przetwórz pozostałe rekordy
	jmp	.continue
