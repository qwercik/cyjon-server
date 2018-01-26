;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

;===============================================================================
kernel_video_clean:
	; zachowaj oryginalne rejestry
	push	rax
	push	rcx
	push	rdi

	; wyczyść przestrzeń pamięci karty graficznej
	mov	eax,	VARIABLE_VIDEO_COLOR_BACKGROUND
	mov	rcx,	qword [variable_kernel_video_size_byte]
	shr	rcx,	STATIC_VIDEO_COLOR_DEPTH_IN_BIT
	mov	rdi,	qword [variable_kernel_video_base_address]
	rep	stosd

	; przywróć oryginalne rejestry
	pop	rdi
	pop	rcx
	pop	rax

	; powrót z procedury
	ret

;===============================================================================
kernel_video_string:
	; powrót z procedury
	ret
