;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

%include	"kernel/daemons/shell/config.asm"

daemon_shell:

.restart:
	; znak zachęty
	mov	rcx,	daemon_shell_prompt_end - daemon_shell_prompt
	mov	rsi,	daemon_shell_prompt

	; kursor znajduje się na początku linii?
	cmp	qword [kernel_video_cursor_x],	EMPTY
	je	.no_new_line	; tak

	; znak zachęty od nowej linii
	mov	rcx,	daemon_shell_prompt_end - daemon_shell_prompt_nl
	mov	rsi,	daemon_shell_prompt_nl

.no_new_line:
	; wyświetl znak zachęty
	call	kernel_video_string

.input:
	; pobierz polecenie
	mov	rcx,	DAEMONS_SHELL_CACHE_SIZE_byte
	mov	rdi,	daemon_shell_cache
	call	shell_prompt
	jc	.restart	; brak danych

	; usuń "białe znaki" z początku i końca ciągu
	call	library_string_trim
	jc	.restart	; ciąg zawierał tylko "białe znaki", zignoruj

	; zapamiętaj oryginalny rozmiar ciągu
	mov	rbx,	rcx

	; znajdź pierwszez "słowo" w ciągu
	call	library_string_find_word

	; sprawdź czy polecenie obsługiwane
	call	shell_command
	jnc	.restart	; wykonano poprawnie

	; wyświetl komunikat błędu
	mov	rcx,	daemon_shell_error_command_text_end - daemon_shell_error_command_text
	mov	rsi,	daemon_shell_error_command_text
	call	kernel_video_string
	mov	rcx,	rbx
	mov	rsi,	rdi
	call	kernel_video_string
	mov	rcx,	daemon_shell_error_implementation_text_end - daemon_shell_error_implementation_text
	mov	rsi,	daemon_shell_error_implementation_text
	call	kernel_video_string

	; pobierz nowe polecenie
	jmp	.restart

	;-----------------------------------------------------------------------
	; dołącz wykorzystywane dane i procedury
	;-----------------------------------------------------------------------
	%include "kernel/daemons/shell/data.asm"
	%include "kernel/daemons/shell/prompt.asm"
	%include "kernel/daemons/shell/command.asm"

	;-----------------------------------------------------------------------
	; dołącz lokalizacje
	;-----------------------------------------------------------------------
	%push
	%defstr		%$system_locale			SYSTEM_LOCALE
	%defstr		%$system_charset		SYSTEM_CHARSET
	%strcat		%$include_system_locale,	"kernel/daemons/shell/locale/", %$system_locale, ".", %$system_charset, ".asm"
	%include	%$include_system_locale
	%pop
