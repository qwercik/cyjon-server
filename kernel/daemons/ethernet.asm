;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

daemon_variable_ethernet_semaphore	db	FALSE

;===============================================================================
daemon_ethernet:
	; zatrzymaj dalsze wykonywanie kodu
	jmp	$
	
