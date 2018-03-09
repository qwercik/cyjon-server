;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

; dołącz stałe ogólnodostępne
%include "kernel/config.asm"

; 64 bitowy kod programu
[BITS 64]

; adresowanie względne
[DEFAULT REL]

; położenie kodu w pamięci logicznej
[ORG KERNEL_MEMORY_HIGH_REAL_address]

shell:
	; wyświetl powitanie
	mov	ax,	KERNEL_SERVICE_CONSOLE_STRING
	mov	rcx,	shell_text_welcome_end - shell_text_welcome
	mov	rsi,	shell_text_welcome
	int	KERNEL_SERVICE

.restart:
	; znak zachęty
	mov	rcx,	shell_text_prompt_end - shell_text_prompt
	mov	rsi,	shell_text_prompt

	; pobierz pozycje kursora
	mov	ax,	KERNEL_SERVICE_CONSOLE_CURSOR
	int	KERNEL_SERVICE

	; znajduje się na początku linii?
	test	ebx,	ebx
	jz	.no_new_line	; tak

	; znak zachęty od nowej linii
	mov	rcx,	shell_text_prompt_end - shell_text_prompt_nl
	mov	rsi,	shell_text_prompt_nl

.no_new_line:
	; wyświetl znak zachęty
	mov	ax,	KERNEL_SERVICE_CONSOLE_STRING
	int	KERNEL_SERVICE

.input:
	; pobierz polecenie
	mov	rcx,	256
	mov	rdi,	end
	call	library_input
	jc	.restart	; zwrócono pusty ciąg

	; usuń "białe znaki" z początku i końca ciągu
	call	library_string_trim
	jc	.restart	; ciąg zawierał tylko "białe znaki", zignoruj

	; znajdź pierwsze "słowo" w ciągu
	call	library_string_find_word

	; zapamiętaj rozmiar polecenia
	mov	rbx,	rcx

	; sprawdź czy polecenie obsługiwane
	call	shell_command
	jnc	.restart	; wykonano poprawnie

	; wyświetl komunikat błędu
	mov	ax,	KERNEL_SERVICE_CONSOLE_STRING
	mov	rcx,	shell_text_error_command_end - shell_text_error_command
	mov	rsi,	shell_text_error_command
	int	KERNEL_SERVICE
	;---
	mov	rcx,	rbx
	mov	rsi,	rdi
	int	KERNEL_SERVICE
	;---
	mov	rcx,	shell_text_error_not_found_end - shell_text_error_not_found
	mov	rsi,	shell_text_error_not_found
	int	KERNEL_SERVICE

	; pobierz nowe polecenie
	jmp	.restart

	;-----------------------------------------------------------------------
	; dołącz podprocedury i dane programu
	;-----------------------------------------------------------------------
	%include "software/shell/data.asm"
	%include "software/shell/command.asm"

	;-----------------------------------------------------------------------
	; dołącz biblioteki wykorzystywane przez program
	;-----------------------------------------------------------------------
	%include "library/library_input.asm"
	%include "library/library_string_compare.asm"
	%include "library/library_string_find_word.asm"
	%include "library/library_string_trim.asm"

	;-----------------------------------------------------------------------
	; dołącz lokalizacje
	;-----------------------------------------------------------------------
	%push
	%defstr		%$system_locale			SYSTEM_LOCALE
	%defstr		%$system_charset		SYSTEM_CHARSET
	%strcat		%$include_system_locale,	"software/shell/locale/", %$system_locale, ".", %$system_charset, ".asm"
	%include	%$include_system_locale
	%pop

end:
