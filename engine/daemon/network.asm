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

; miejsce na pakiety przychodzące
variable_daemon_network_table_rx			dq	VARIABLE_EMPTY

; 64 Bitowy kod programu
[BITS 64]

daemon_network:
	; przygotuj miejsce na pakiety
	call	cyjon_page_allocate
	; zapamiętaj
	mov	qword [variable_daemon_network_table_rx],	rdi

	jmp	$
