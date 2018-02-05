;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

	;-----------------------------------------------------------------------
	; utwórz binarną mapę pamięci za kodem jądra systemu
	; pod adresem wyrównanym do rozmiaru strony
	;-----------------------------------------------------------------------
	%include "kernel/init/memory_map.asm"

	;-----------------------------------------------------------------------
	; utwórz własną Globalną Tablicę Deskryptorów
	;-----------------------------------------------------------------------
	%include "kernel/init/gdt.asm"

	;-----------------------------------------------------------------------
	; utwórz własne tablice stronicowania
	;-----------------------------------------------------------------------
	%include "kernel/init/page.asm"

	;-----------------------------------------------------------------------
	; przemapuj kontroler przerwań sprzętowych
	;-----------------------------------------------------------------------
	%include "kernel/init/pic.asm"

	; zakończono inicjalizacje środowiska jądra systemu
	jmp	kernel

	;-----------------------------------------------------------------------
	; procedura obsługująca krytyczne błędy podczas inicjalizacji
	;-----------------------------------------------------------------------
	%include "kernel/panic.asm"

	;-----------------------------------------------------------------------
	; komunikaty
	;-----------------------------------------------------------------------
	%include "kernel/init/locale/en_US.ASCII.asm"
