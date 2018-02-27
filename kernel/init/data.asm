;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

list_daemons:
	; lista demonów
	dq	daemon_ethernet	; wskaźnik wejścia
	dq	8	; ilość znaków w nazwie
	db	"ethernet"

	; koniec listy
	dq	EMPTY
