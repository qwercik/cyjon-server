;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

%include	"kernel/daemons/shell/config.asm"

daemon_shell:
	; wyświetl znak zachęty od nowej linii
	mov	rcx,	daemon_shell_prompt_end - daemon_shell_prompt
	mov	rsi,	daemon_shell_prompt
	call	kernel_video_string

	; pobierz polecenie
	jmp	.loop

.prompt_new_line:
	; wyświetl znak zachęty od nowej linii
	mov	rcx,	daemon_shell_prompt_end - daemon_shell_prompt_nl
	mov	rsi,	daemon_shell_prompt_nl
	call	kernel_video_string

.loop:
	; pobierz polecenie
	mov	rcx,	DAEMONS_SHELL_CACHE_SIZE_byte
	mov	rdi,	daemon_shell_cache
	call	prompt

	;~ ; jeśli linia poleceń jest pusta, wyświetl znak zachęty od nowej linii
	;~ jc	.prompt_new_line

	; pobierz nowe polecenie
	jmp	.prompt_new_line

	;-----------------------------------------------------------------------
	; dołącz wykorzystywane dane i procedury
	;-----------------------------------------------------------------------
	%include "kernel/daemons/shell/data.asm"
	%include "kernel/daemons/shell/prompt.asm"

	;-----------------------------------------------------------------------
	; dołącz lokalizacje
	;-----------------------------------------------------------------------
	%push
	%defstr		%$system_locale			SYSTEM_LOCALE
	%defstr		%$system_charset		SYSTEM_CHARSET
	%strcat		%$include_system_locale,	"kernel/daemons/shell/locale/", %$system_locale, ".", %$system_charset, ".asm"
	%include	%$include_system_locale
	%pop
