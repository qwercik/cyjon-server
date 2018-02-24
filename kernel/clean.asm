;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

	; oblicz ilość stron do zwolnienia
	mov	rcx,	clean - init
	shr	rcx,	DIVIDE_BY_PAGE_shift

	; zacznij od strony pod adresem
	mov	rdi,	init

.loop:
	; zwolnij stronę
	call	kernel_page_release

	; następny adres strony
	add	rdi,	KERNEL_PAGE_SIZE_byte

	; pozostały strony do zwolnienia?
	dec	rcx
	jnz	.loop	; tak
