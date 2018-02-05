;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

	; podłącz procedure obsługi klawiatury
	mov	rax,	KERNEL_IDT_IRQ_HARDWARE_offset + KERNEL_IDT_IRQ_PS2
	mov	rbx,	KERNEL_IDT_TYPE_IRQ
	mov	rdi,	kernel_keyboard
	call	kernel_idt_mount

	; odblokuj przerwanie klawiatury na kontrolerze PIC
	mov	rcx,	KERNEL_PIC_IRQ_KEYBOARD
	call	kernel_pic_enable
