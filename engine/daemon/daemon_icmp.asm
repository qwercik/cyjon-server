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

VARIABLE_DAEMON_ICMP_PROTOCOL			equ	0x01

text_daemon_icmp_name				db	"network_icmp"
variable_daemon_icmp_name_count			db	12

; 64 Bitowy kod programu
[BITS 64]

daemon_icmp:
	; wstrzymaj demona
	hlt

	; koniec
	jmp	daemon_arp
