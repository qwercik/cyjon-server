;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

;===============================================================================
; wejście:
;	rdi - adres
; wyjście:
;	rdi - adres wyrównany do pełnej strony
library_page_align_up:
	; utwórz zmienną lokalną
	push	rdi

	; usuń młodszą część adresu
	and	rdi,	KERNEL_PAGE_mask

	; sprawdź czy adres jest identyczny z zmienną lokalną
	cmp	rdi,	qword [rsp]
	je	.end	; jeśli tak, koniec

	; przesuń adres o jedną ramkę do przodu
	add	rdi,	KERNEL_PAGE_SIZE_byte

.end:
	; usuń zmienną lokalną
	add	rsp,	QWORD_SIZE_byte

	; powrót z procedury
	ret
