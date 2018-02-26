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
	call	prompt
	jc	.restart	; brak danych

	xchg	bx,bx

	; usuń "białe znaki" z początku i końca ciągu
	call	library_string_trim
	jc	.restart	; ciąg zawierał tylko "białe znaki", zignoruj

	; zapamiętaj oryginalny rozmiar ciągu
	mov	rdx,	rcx

	; znajdź pierwszez "słowo" w ciągu
	call	library_string_find_word

	; polecenie "clean"?
	mov	rcx,	daemon_shell_command_clean_end - daemon_shell_command_clean
	mov	rsi,	daemon_shell_command_clean
	call	library_string_compare
	jc	.no_clean

	; wyczyść ekran
	call	kernel_video_clean

	; wyświetl ponownie znak zachęty
	jmp	.restart

.no_clean:
	; pobierz nowe polecenie
	jmp	.restart

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
