;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

;===============================================================================
kernel_keyboard:
	; zachowaj oryginalne rejestry
	push	rax
	push	rdi

	; pobierz kod klawisza z bufora sprzętowego klawiatury
	xor	eax,	eax	; wyczyść akumulator
	in	al,	PORT_PS2_data

	; obsłużyć sekwencje?
	cmp	byte [kernel_keyboard_semaphore],	TRUE
	je	.alternate	; tak

	; rozpoczęto sekwencje?
	cmp	al,	KERNEL_KEYBOARD_SEQUENCE_0
	je	.sequence	; nie

	; rozpoczęto sekwencje?
	cmp	al,	KERNEL_KEYBOARD_SEQUENCE_1
	jne	.continue	; nie

.sequence:
	; zachowaj informacje o rozpoczętej sekwencji
	mov	byte [kernel_keyboard_semaphore],	TRUE

	; koniec obsługi przerwnia
	jmp	.end

.continue:
	; naciśnięto capslock?
	cmp al, KEYBOARD_SCANCODE_CAPSLOCK
	jne .no_press_capslock	; nie
	
	; zwróć do bufora programowego kod klawisza
	mov ax, KERNEL_KEYBOARD_PRESS_CAPSLOCK

	; zmień matryce klawiatury
	jmp .shift


.no_press_capslock:
	; naciśnięto lewy klawisz shift?
	cmp	al,	KEYBOARD_SCANCODE_SHIFT_LEFT
	jne	.no_press_shift_left	; nie

	; przytrzymano lewy klawisz shift?
	cmp	byte [kernel_keyboard_key_shift_left],	TRUE
	je	.end	; tak, zignoruj

	; zachowaj stan klawisza
	mov	byte [kernel_keyboard_key_shift_left],	TRUE

	; zwróć do bufora programowego kod klawisza
	mov	ax,	KERNEL_KEYBOARD_PRESS_SHIFT_LEFT

	; zmień matryce klawiatury
	jmp	.shift

.no_press_shift_left:
	; naciśnięto prawy klawisz shift?
	cmp	al,	KEYBOARD_SCANCODE_SHIFT_RIGHT
	jne	.no_press_shift_right	; nie

	; przytrzymano prawy klawisz shift?
	cmp	byte [kernel_keyboard_key_shift_right],	TRUE
	je	.end	; tak, zignoruj

	; zachowaj stan klawisza
	mov	byte [kernel_keyboard_key_shift_right],	TRUE

	; zwróć do bufora programowego kod klawisza
	mov	ax,	KERNEL_KEYBOARD_PRESS_SHIFT_RIGHT

	; zmień matryce klawiatury
	jmp	.shift

.no_press_shift_right:
	; puszczono lewy klawisz shift?
	cmp	al,	KEYBOARD_SCANCODE_SHIFT_LEFT + 0x80
	jne	.no_release_shift_left	; nie

	; zachowaj stan klawisza
	mov	byte [kernel_keyboard_key_shift_left],	FALSE

	; zwróć do bufora programowego kod klawisza
	mov	ax,	KERNEL_KEYBOARD_RELEASE_SHIFT_LEFT

	; zmień matrycę klawiatury
	jmp	.shift

.no_release_shift_left:
	; puszczono prawy klawisz shift?
	cmp	al,	KEYBOARD_SCANCODE_SHIFT_RIGHT + 0x80
	jne	.no_release_shift_right	; nie

	; zachowaj stan klawisza
	mov	byte [kernel_keyboard_key_shift_right],	FALSE

	; zwróć do bufora programowego kod klawisza
	mov	ax,	KERNEL_KEYBOARD_RELEASE_SHIFT_RIGHT

.shift:
	; podmień matryce (litery duże/małe)
	mov	rdi,	qword [kernel_keyboard_matrix]
	xchg	rdi,	qword [kernel_keyboard_matrix + QWORD_SIZE_byte]
	mov	qword [kernel_keyboard_matrix],	rdi

	; zachowaj kod klawisza w buforze programowym klawiatury
	jmp	.save

.no_release_shift_right:
	; naciśnięto lewy klawisz alt?
	cmp	al,	KEYBOARD_SCANCODE_ALT
	jne	.no_press_alt_left	; nie

	; przytrzymano lewy klawisz alt?
	cmp	al,	byte [kernel_keyboard_key_alt]
	je	.end	; tak, zignoruj

	; zachowaj stan klawisza
	mov	byte [kernel_keyboard_key_alt],	TRUE

	; zwróć do bufora programowego kod klawisza
	mov	ax,	KERNEL_KEYBOARD_PRESS_ALT

	; zachowaj kod klawisza w buforze programowym klawiatury
	jmp	.save

.no_press_alt_left:
	; puszczono lewy klawisz alt?
	cmp	al,	KEYBOARD_SCANCODE_ALT + 0x80
	jne	.no_release_alt_left	; nie

	; zachowaj stan klawisza
	mov	byte [kernel_keyboard_key_alt],	FALSE

	; zwróć do bufora programowego kod klawisza
	mov	ax,	KERNEL_KEYBOARD_RELEASE_ALT

	; zachowaj kod klawisza w buforze programowym klawiatury
	jmp	.save

.no_release_alt_left:
	; naciśnięto lewy klawisz ctrl?
	cmp	al,	KEYBOARD_SCANCODE_CTRL
	jne	.no_press_ctrl_left	; nie

	; przytrzymano lewy klawisz ctrl?
	cmp	al,	byte [kernel_keyboard_key_ctrl]
	je	.end	; tak, zignoruj

	; zachowaj stan klawisza
	mov	byte [kernel_keyboard_key_ctrl],	TRUE

	; zwróć do bufora programowego kod klawisza
	mov	ax,	KERNEL_KEYBOARD_PRESS_CTRL

	; zachowaj kod klawisza w buforze programowym klawiatury
	jmp	.save

.no_press_ctrl_left:
	; puszczono lewy klawisz ctrl?
	cmp	al,	KEYBOARD_SCANCODE_CTRL + 0x80
	jne	.no_release_ctrl_left	; nie

	; zachowaj stan klawisza
	mov	byte [kernel_keyboard_key_ctrl],	FALSE

	; zwróć do bufora programowego kod klawisza
	mov	ax,	KERNEL_KEYBOARD_RELEASE_CTRL

	; zachowaj kod klawisza w buforze programowym klawiatury
	jmp	.save

.no_release_ctrl_left:
	; pobierz wartość ASCII kodu
	mov	rdi,	qword [kernel_keyboard_matrix]
	mov	al,	byte [rdi + rax]

.save:
	; zachowaj wartość ASCII klawisza w buforze programowym
	shl	qword [kernel_keyboard_cache],	MOVE_AX_TO_HIGH
	mov	word [kernel_keyboard_cache],	ax

	; koniec obsługi kontrolera klawiatury
	jmp	.end

.alternate:
	; usuń informacje o rozpoczętej sekwencji
	mov	byte [kernel_keyboard_semaphore],	FALSE

	; brak obsługi sekwencji, zignoruj

.end:
	; poinformuj kontroler PIC o obsłużeniu przerwania sprzętowego
	mov	al,	PIC_IRQ_ACCEPT
	out	PORT_PIC_MASTER_command,	al

	; przywróć oryginalne rejestry
	pop	rdi
	pop	rax

	; powrót z przerwania
	iretq

;===============================================================================
; wyjście:
;	Flaga ZF - jeśli brak klawisza
;	ax - kod ASCII klawisza lub jego sekwencja
kernel_keyboard_read:
	; pobierz kod ASCII i usuń z bufora
	mov	ax,	word [kernel_keyboard_cache + DWORD_SIZE_byte + WORD_SIZE_byte]
	shl	qword [kernel_keyboard_cache],	MOVE_AX_TO_HIGH

	; zwróć informacje o wyniku
	test	ax,	ax

	; powrót z procedury
	ret
