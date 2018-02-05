;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

;===============================================================================
kernel_keyboard:
	; zachowaj oryginalne rejestry
	push	rax

	; pobierz kod klawisza z bufora sprzętowego klawiatury
	xor	ax,	ax	; wyczyść akumulator
	in	al,	PORT_PS2_data

.end:
	; poinformuj kontroler PIC o obsłużeniu przerwania sprzętowego
	mov	al,	PIC_IRQ_ACCEPT

	; wyślij do kontrolera głównego
	out	PORT_PIC_MASTER_command,	al

	; przywróć oryginalne rejestry
	pop	rax

	; powrót z przerwania
	iretq
