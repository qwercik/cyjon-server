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

text_daemon_network_name		db	"network"
variable_daemon_network_name_count	db	7

variable_daemon_network_enabled		db	VARIABLE_FALSE

; miejsce na pakiety przychodzące
variable_daemon_network_table_rx_max	dq	VARIABLE_EMPTY
variable_daemon_network_table_rx_1024	dq	VARIABLE_EMPTY
variable_daemon_network_table_rx_512	dq	VARIABLE_EMPTY
variable_daemon_network_table_rx_256	dq	VARIABLE_EMPTY
variable_daemon_network_table_rx_128	dq	VARIABLE_EMPTY
variable_daemon_network_table_rx_64	dq	VARIABLE_EMPTY


; 64 Bitowy kod programu
[BITS 64]

daemon_network:
	; sprawdź czy pamięć jest dostępna do modyfikacji
	cmp	byte [variable_page_semaphore],	VARIABLE_TRUE
	je	daemon_network

	; zarezerwuj
	mov	byte [variable_page_semaphore],	VARIABLE_TRUE

	; sprawdź czy istnieje odpowiednia ilość stron do zainicjalizowania buforu
	cmp	qword [variable_binary_memory_map_free_pages],	6
	jb	.init_error

	; to do

.init_error:
	; odblokuj dostęp do pamięci
	mov	byte [variable_page_semaphore],	VARIABLE_FALSE

.daemon_stop:
	; zatrzymaj demona
	hlt

	; koniec
	jmp	.daemon_stop
