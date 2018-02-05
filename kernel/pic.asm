;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

;===============================================================================
; wejście:
;	rcx - numer przerwania IRQ do włączenia
kernel_pic_enable:
	; zachowaj oryginalne rejestry
	push	rax

	; wyłącz bit odpowiadający za maskowanie przerwania
	btr	word [kernel_pic_semaphore_bit],	cx

	; jeśli numer przerwania sprzętowego > 7
	cmp	cx,	8
	jb	.master

	; wyłącz bit odpowiadający za maskowanie przerwania kaskadowego
	btr	word [kernel_pic_semaphore_bit],	2

.master:
	; przeładuj ustawienia kontrolera PIC
	mov	al,	byte [kernel_pic_semaphore_bit + BYTE_SIZE_byte]
	out	PORT_PIC_SLAVE_data,	al
	mov	al,	byte [kernel_pic_semaphore_bit]
	out	PORT_PIC_MASTER_data,	al

	; przywróć oryginalne rejestry
	pop	rax

	; powrót z procedury
	ret
