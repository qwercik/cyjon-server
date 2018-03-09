;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

daemon_shell:
	; wyświetl znak zachęty wraz z wyczyszczeniem ekranu
	mov	rcx,	daemon_shell_prompt_end - daemon_shell_prompt
	mov	rsi,	daemon_shell_prompt
	call	kernel_video_string

.loop:
	nop
	nop
	nop

	; zatrzymaj dalsze wykonywanie kodu
	jmp	$

	;-----------------------------------------------------------------------
	; dołącz wykorzystywane dane i procedury
	;-----------------------------------------------------------------------
	%include "kernel/daemons/shell/data.asm"

	;-----------------------------------------------------------------------
	; dołącz lokalizacje
	;-----------------------------------------------------------------------
	%push
	%defstr		%$system_locale			SYSTEM_LOCALE
	%defstr		%$system_charset		SYSTEM_CHARSET
	%strcat		%$include_system_locale,	"kernel/daemons/shell/locale/", %$system_locale, ".", %$system_charset, ".asm"
	%include	%$include_system_locale
	%pop
