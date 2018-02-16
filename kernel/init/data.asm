;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

; komunikaty
%include "kernel/init/locale/en_US.ASCII.asm"

list_daemons:
	; lista demonów
	dq	daemon_ethernet	; wskaźnik wejścia
	dq	16	; ilość znaków w nazwie
	db	"network ethernet"

	; koniec listy
	dq	EMPTY
