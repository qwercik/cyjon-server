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
	; utwórz tablicę deskryptorów przerwań i podłącz podstawowe procedury obsługi
	;-----------------------------------------------------------------------
	%include "kernel/init/idt.asm"

	;-----------------------------------------------------------------------
	; przemapuj kontroler przerwań sprzętowych
	;-----------------------------------------------------------------------
	%include "kernel/init/pic.asm"

	;-----------------------------------------------------------------------
	; ustaw częstotliwość wywoływania przerwania sprzętowego zegara
	;-----------------------------------------------------------------------
	%include "kernel/init/pit.asm"

	;-----------------------------------------------------------------------
	; podłącz procedurę obsługi przerwania sprzętowego klawiatury
	;-----------------------------------------------------------------------
	%include "kernel/init/keyboard.asm"

	;-----------------------------------------------------------------------
	; utwórz kolejkę zadań i dodaj na jej początek jądro systemu
	;-----------------------------------------------------------------------
	%include "kernel/init/task.asm"

	; zakończono inicjalizacje środowiska jądra systemu

	;-----------------------------------------------------------------------
	; skonfiguruj pierwszy dostępny interfejs sieciowy
	;-----------------------------------------------------------------------
	%include "kernel/init/network.asm"

network_end:
	; system gotowy do pracy, zwolnij miejsce zajęte przez procedury inicjalizacji
	jmp	clean

	;-----------------------------------------------------------------------
	; procedura obsługująca krytyczne błędy podczas inicjalizacji
	;-----------------------------------------------------------------------
	%include "kernel/panic.asm"

	;-----------------------------------------------------------------------
	; komunikaty
	;-----------------------------------------------------------------------
	%include "kernel/init/locale/en_US.ASCII.asm"
