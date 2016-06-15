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

; 64 Bitowy kod programu
[BITS 64]

; procedura zostanie usunięta z pamięci po wykonaniu
daemons:
	; zachowaj oryginalne rejestry
	push	rcx
	push	rdx
	push	rsi

	; ustaw wskaźnik do tablicy demonów
	mov	rsi,	table_daemon

.run:
	; sprawdź czy koniec listy demonów do uruchomienia
	cmp	qword [rsi],	VARIABLE_EMPTY
	je	.end

	; ilość znaków w nazwie demona
	mov	rcx,	qword [rsi]
	; adres procedury demona
	mov	rdx,	qword [rsi + VARIABLE_QWORD_SIZE]
	; wskaźnik do nazwy demona
	add	rsi,	VARIABLE_QWORD_SIZE * 2

	; uruchom
	call	cyjon_process_init_daemon

	; następny rekord w tablicy
	add	rsi,	VARIABLE_QWORD_SIZE
	jmp	.run

.end:
	; przywróć oryginalne rejestry
	pop	rsi
	pop	rdx
	pop	rcx

	; powrót z procedury
	ret

table_daemon:
	dq	VARIABLE_DAEMON_GARBAGE_COLLECTOR_NAME_COUNT
	dq	daemon_garbage_collector
	dq	variable_daemon_garbage_collector_name

	dq	VARIABLE_DAEMON_ETHERNET_NAME_COUNT
	dq	daemon_ethernet
	dq	variable_daemon_ethernet_name

	; koniec rekordów
	dq	VARIABLE_EMPTY
