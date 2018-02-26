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

; koniec kodu inicjalizującego jądro systemu wyrównujemy do adresu pełnej strony, wypełniając przestrzeń pustymi bajtami
align	KERNEL_PAGE_SIZE_byte,	db	EMPTY

clean:
	;-----------------------------------------------------------------------
	; zwolnij przestrzeń zajętą przez procedury inicjalizacji
	;-----------------------------------------------------------------------
	%include "kernel/clean.asm"

kernel:
	; wyświetl informacje o gotowości do działania
	mov	rcx,	kernel_string_welcome_end - kernel_string_welcome
	mov	rsi,	kernel_string_welcome
	call	kernel_video_string

	; włącz przerwania
	sti

	; zatrzymaj dalsze wykonywanie kodu
	jmp	$

	;-----------------------------------------------------------------------
	; dołącz procedury tworzące ciało jądra systemu
	;-----------------------------------------------------------------------
	%include "kernel/data.asm"
	%include "kernel/page.asm"
	%include "kernel/idt.asm"
	%include "kernel/keyboard.asm"
	%include "kernel/pic.asm"
	%include "kernel/task.asm"
	%include "kernel/pci.asm"
	%include "kernel/video.asm"
	%include "kernel/font.asm"

	;-----------------------------------------------------------------------
	; dołącz sterowniki urządzeń
	;-----------------------------------------------------------------------
	%include "kernel/drivers/network/82540em.asm"

	;-----------------------------------------------------------------------
	; dołącz demony
	;-----------------------------------------------------------------------
	%include "kernel/daemons/ethernet.asm"
	%include "kernel/daemons/shell.asm"

	;-----------------------------------------------------------------------
	; dołącz biblioteki wykorzystywane przez jądro systemu i podprocesy
	;-----------------------------------------------------------------------
	%include "library/library_bit_find.asm"
	%include "library/library_page_align_up.asm"
	%include "library/library_string_compare.asm"
	%include "library/library_string_cut.asm"
	%include "library/library_string_find_word.asm"
	%include "library/library_string_trim.asm"

	;-----------------------------------------------------------------------
	; dołącz lokalizacje
	;-----------------------------------------------------------------------
	%push
	%defstr		%$system_locale			SYSTEM_LOCALE
	%defstr		%$system_charset		SYSTEM_CHARSET
	%strcat		%$include_system_locale,	"kernel/locale/", %$system_locale, ".", %$system_charset, ".asm"
	%include	%$include_system_locale
	%pop

; koniec kodu jądra systemu wyrównujemy do adresu pełnej strony, wypełniając przestrzeń pustymi bajtami
align	KERNEL_PAGE_SIZE_byte,	db	EMPTY

kernel_end:
