;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

	; przygotuj przestrzeń pod kolejkę zadań
	call	kernel_page_request

	; wyczyść i zapamiętaj adres kolejki
	call	kernel_page_dump
	mov	qword [kernel_task_queue_address],	rdi

	; połącz koniec z początkiem kolejki (RoundRobin)
	mov	qword [rdi + KERNEL_STRUCTURE_BLOCK.link],	rdi

	; zachowaj wskaźnik pierwszego rekordu
	push	rdi

	; ustaw flagę rekordu na: aktywny, demon
	or	word [rdi + KERNEL_STRUCTURE_TASK.flags],	KERNEL_TASK_FLAG_ACTIVE | KERNEL_TASK_FLAG_DAEMON

	; ustaw ilość znaków w nazwie jądra systemu
	mov	byte [rdi + KERNEL_STRUCTURE_TASK.length],	kernel_name_end - kernel_name

	; załaduj nazwę jądra systemu
	mov	rcx,	kernel_name_end - kernel_name
	mov	rsi,	kernel_name
	add	rdi,	KERNEL_STRUCTURE_TASK.name
	rep	movsb

	; przywróć wskaźnik pierwszego sektora
	pop	rdi

	; zapamiętaj wskaźnik do aktualnie wykonywanego zadania
	mov	qword [kernel_task_active],	rdi

	; ilość zadań w kolejce, zwiększyła się
	inc	qword [kernel_task_count]

	;-----------------------------------------------------------------------
	; podłącz procedurę obsługi kolejki do zegara
	mov	rax,	KERNEL_IDT_IRQ_HARDWARE_offset + KERNEL_IDT_IRQ_SHEDULER
	mov	rbx,	KERNEL_IDT_TYPE_ISR
	mov	rdi,	kernel_task
	call	kernel_idt_mount

	; odblokuj przerwanie sprzętowe zegara
	mov	rcx,	KERNEL_PIC_IRQ_SHEDULER
	call	kernel_pic_enable
