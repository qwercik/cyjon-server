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

VARIABLE_DAEMON_TCP_IP_STACK_NAME_COUNT			equ	20
variable_daemon_tcp_ip_stack_name			db	"network tcp/ip stack"

; 64 Bitowy kod programu
[BITS 64]

daemon_tcp_ip_stack:
	jmp	$
