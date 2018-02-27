;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

kernel_service:
	; akcja związana z konsolą?
	cmp	ah,	KERNEL_SERVICE_CONSOLE
	je	kernel_service_console

	; akcja związana z klawiaturą?
	cmp	ah,	KERNEL_SERVICE_KEYBOARD
	je	kernel_service_keyboard

	; koniec obsługi przerwania programowego
	iretq

;===============================================================================
kernel_service_console:
	; wyczyścić ekran konsoli?
	cmp	ax,	KERNEL_SERVICE_CONSOLE_CLEAN
	je	kernel_service_console_clean	; tak

	; wyświetlić ciąg znaków na konsoli?
	cmp	ax,	KERNEL_SERVICE_CONSOLE_STRING
	je	kernel_service_console_string	; tak

	; wyświetlić znak ASCII?
	cmp	ax,	KERNEL_SERVICE_CONSOLE_CHAR
	je	kernel_service_console_char	; tak

	; pobrać pozycje kursora w konsoli?
	cmp	ax,	KERNEL_SERVICE_CONSOLE_CURSOR
	je	kernel_service_console_cursor	; tak

	; koniec obsługi przerwania programowego
	iretq

;-------------------------------------------------------------------------------
kernel_service_console_clean:
	; wyświetl ciąg znaków
	call	kernel_video_clean

	; koniec obsługi przerwania programowego
	iretq

;-------------------------------------------------------------------------------
kernel_service_console_string:
	; wyświetl ciąg znaków
	call	kernel_video_string

	; koniec obsługi przerwania programowego
	iretq

;-------------------------------------------------------------------------------
kernel_service_console_char:
	; zachowaj oryginalne rejestry
	push	rax

	; wyświetl znak ASCII
	movzx	rax,	dl
	call	kernel_video_char

	; przywróć oryginalne rejestry
	pop	rax

	; koniec obsługi przerwania programowego
	iretq

;-------------------------------------------------------------------------------
kernel_service_console_cursor:
	mov	ebx,	dword [kernel_video_cursor_y]
	shl	rbx,	MOVE_EAX_TO_HIGH
	or	rbx,	qword [kernel_video_cursor_x]

	; koniec obsługi przerwania programowego
	iretq

;===============================================================================
kernel_service_keyboard:
	; pobrać kod klawisza z bufora programowego klawiatury?
	cmp	ax,	KERNEL_SERVICE_KEYBOARD_READ
	jne	.end	; nie

	; pobierz kod klawisza w bufora programowego klawiatury
	call	kernel_keyboard_read

	; pobrano kod klawisza?
	jnz	.end	; tak

	; przekaż informacje o braku
	or	qword [rsp + QWORD_SIZE_byte * 0x02],	KERNEL_TASK_EFLAGS_ZF

.end:
	; koniec obsługi przerwania programowego
	iretq
