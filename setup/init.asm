;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

; wartości stałe
%include "setup/static.asm"

;===============================================================================
kernel_init:
	;-----------------------------------------------------------------------
	; do wyświetlania komunikatów (np. błędów)
	; musimy rozpoznać w jakim trybie jest karta graficzna: tekstowy, graficzny
	;-----------------------------------------------------------------------
%include "setup/video.asm"

	;-----------------------------------------------------------------------
	; sprawdź typ procesora
	;-----------------------------------------------------------------------
%include "setup/cpu.asm"

	; zatrzymaj dalsze wykonywanie kodu
	jmp	$

.kernel_panic:
	; zatrzymaj dalsze wykonywanie kodu
	jmp	$

;===============================================================================
; wczytaj lokalizacje
%push
	%defstr		%$system_locale			VARIABLE_SYSTEM_LOCALE
	%defstr		%$system_charset		VARIABLE_SYSTEM_CHARSET
	%strcat		%$include_system_locale,	"setup/locale/", %$system_locale, ".", %$system_charset, ".asm"
	%include	%$include_system_locale
%pop
