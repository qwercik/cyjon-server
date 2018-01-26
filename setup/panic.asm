;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

;===============================================================================
; wejście:
;	ecx - ilość znaków w ciągu
;	esi - wskaźnik do ciągu/komunikatu
kernel_panic:
	; znajdujemy się trybie tekstowym?
	cmp	byte [semaphore_kernel_video_mode_text],	STATIC_TRUE
	je	.text_mode	; tak

	; wyświetl komunikat
	call	kernel_video_string

	; zatrzymaj dalsze wykonywanie kodu
	jmp	.halt

.text_mode:
	; standardowy kolor czcionki w trybie tekstowym
	mov	ah,	0x07
	; pozycja przestrzeni pamięci karty graficznej trybu tekstowego
	mov	edi,	dword [variable_kernel_video_base_address]

.loop:
	; pobierz do AL wartość z adresu pod wskaźnikiem SI, zwiększ wskaźnik SI o 1
	lodsb

	; zapisz na ekranie
	stosw

	; wyświetl następny znak ciągu
	dec	ecx
	jnz	.loop

.halt:
	; zatrzymaj dalsze wykonywanie kodu
	jmp	.halt
