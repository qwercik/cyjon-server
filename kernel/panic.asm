;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

kernel_panic:
	; wyświetl komunikat
	call	kernel_video_string

	; zatrzymaj dalsze wykonywanie kodu
	jmp	$
