;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

; zmienne, stałe, struktury
%include "kernel/config.asm"

; 64 bitowy kod jądra systemu
[BITS 64]

; położenie kodu w pamięci fizycznej
[ORG KERNEL_BASE_address]

init:
	;-----------------------------------------------------------------------
	; inicjalizuj środowisko jądra systemu
	;-----------------------------------------------------------------------
%include "kernel/init.asm"

kernel:
	; zatrzymaj dalsze wykonywanie kodu
	jmp	$

	;-----------------------------------------------------------------------
	; dołącz procedury tworzące ciało jądra systemu
	;-----------------------------------------------------------------------
%include "kernel/page.asm"
%include "kernel/data.asm"

	;-----------------------------------------------------------------------
	; dołącz liblioteki wykorzystywane przez jądro systemu
	;-----------------------------------------------------------------------
%include "liblary/liblary_page_align_up.asm"
%include "liblary/liblary_bit_find.asm"

; koniec kodu jądra systemu wyrównujemy do adresu pełnej strony, wypełniając przestrzeń pustymi bajtami
align	KERNEL_PAGE_SIZE_byte,	db	EMPTY

kernel_end:
