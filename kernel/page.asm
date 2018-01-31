;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

;===============================================================================
; opcjonalnie:
;	rbp - ilość stron zabezpieczonych
;		procedura będzie z nich korzystać, zarazem licznik zmniejszać
; wyjście:
;	Flaga CF - jeśli brak wolnych stron
;	rdi - wskaźnik do wolnej strony
kernel_page_request:
	; powrót z procedury
	ret
