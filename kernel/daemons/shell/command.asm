;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

;===============================================================================
; wejście:
shell_command:
	; polecenie "clean"?
	mov	rcx,	daemon_shell_command_clean_end - daemon_shell_command_clean
	mov	rsi,	daemon_shell_command_clean
	call	library_string_compare
	jc	.fail	; nie

	; wyczyść ekran
	call	kernel_video_clean

	; koniec
	jmp	.end

.fail:
	; flaga, błąd
	stc

.end:
	; powrót z procedury
	ret
