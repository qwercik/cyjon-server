;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

; wartości stałe
%include "static.asm"

; konfiguracja
%include "config.asm"

; 32 bitowy kod
[BITS 32]

bootloader_entry:
	; program rozruchowy przekazuje nam władzę nad procesorem

; dołącz procedury inicjalizujące środowisko 64 bitowe jądra systemu
%include "setup/init.asm"
%include "setup/multiboot.asm"

; kod inicjalizujący, tablice, zmienne itp. zostaną zwolnione po zakończeniu pracy (zawsze to dodatkowa strona pamięci)
align STATIC_PAGE_SIZE, db STATIC_EMPTY

; 64 bitowy kod
[BITS 64]

kernel_entry:
	; zatrzymaj dalsze wykonywanie kodu
	jmp	$

; procedury i dane jądra systemu
%include "kernel/data.asm"

;===============================================================================
; wczytaj lokalizacje
%push
	%defstr		%$system_locale			VARIABLE_SYSTEM_LOCALE
	%defstr		%$system_charset		VARIABLE_SYSTEM_CHARSET
	%strcat		%$include_system_locale,	"kernel/locale/", %$system_locale, ".", %$system_charset, ".asm"
	%include	%$include_system_locale
%pop
