;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

;===============================================================================
shell_command:
	; polecenie "clean"?
	mov	rcx,	shell_command_clean_end - shell_command_clean
	mov	rsi,	shell_command_clean
	call	library_string_compare
	jc	.fail	; nie

	; wyczyść ekran
	mov	ax,	KERNEL_SERVICE_CONSOLE_CLEAN
	int	KERNEL_SERVICE

	; koniec
	jmp	.end

.fail:
	; flaga, błąd
	stc

.end:
	; powrót z procedury
	ret
