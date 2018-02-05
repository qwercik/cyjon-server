;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

;===============================================================================
kernel_task:
	; zachowaj oryginalne rejestry na stos kontekstu procesu/jądra
	push	rax
	push	rbx
	push	rcx
	push	rdx
	push	rsi
	push	rdi
	push	rbp
	push	r8
	push	r9
	push	r10
	push	r11
	push	r12
	push	r13
	push	r14
	push	r15

	; zachowaj rejestry zmiennoprzecinkowe
	mov	rbp,	KERNEL_MEMORY_STACK_KERNEL_address + KERNEL_PAGE_SIZE_byte
	FXSAVE64	[rbp]

	; pobierz wskaźnik do aktualnie wykonywanego zadania
	mov	rdi,	qword [kernel_task_active]

	; zachowaj w kolejce aktualny wskaźnik stosu zadania
	mov	qword [rdi + KERNEL_STRUCTURE_TASK.rsp],	rsp

	; zachowaj w kolejce adres tablicy PML4 zadania
	mov	rax,	cr3
	mov	qword [rdi + KERNEL_STRUCTURE_TASK.cr3],	rax

	; pobierz ilość zadań pozostałych w bloku kolejki
	mov	rax,	qword [kernel_task_count_left]

	; pozostały zadania w bloku?
	cmp	rax,	EMPTY
	jne	.next	; tak

.block:
	; załaduj następny blok kolejki
	and	rdi,	KERNEL_PAGE_mask
	mov	rdi,	qword [rdi + KERNEL_STRUCTURE_BLOCK.link]

	; zresetuj ilość zadań przypadających na blok kolejki
	mov	rax,	KERNEL_STRUCTURE_BLOCK.link / KERNEL_STRUCTURE_TASK.SIZE

	; sprawdź pierwsze zadanie w bloku kolejki
	jmp	.check

.next:
	; pozostały zadania w bloku?
	dec	rax
	jz	.block	; nie

	; przesuń wskaźnik na następne zadanie
	add	rdi,	KERNEL_STRUCTURE_TASK.SIZE

.check:
	; zadanie jest aktywne?
	bt	word [rdi + KERNEL_STRUCTURE_TASK.flags],	KERNEL_TASK_FLAG_ACTIVE_bit
	jnc	.next	; nie

	; zachowaj ilość zadań pozostałych w bloku
	mov	qword [kernel_task_count_left],	rax

	; zachowaj nowy adres aktywnego zadania
	mov	qword [kernel_task_active],	rdi

	; załaduj wskaźnik stosu przywracanego zadania i adres tablicy PML4
	mov	rsp,	qword [rdi + KERNEL_STRUCTURE_TASK.rsp]
	mov	rax,	qword [rdi + KERNEL_STRUCTURE_TASK.cr3]
	mov	cr3,	rax

	; przywróć rejestry zmiennoprzecinkowe
	mov	rbp,	KERNEL_MEMORY_STACK_KERNEL_address + KERNEL_PAGE_SIZE_byte
	FXRSTOR64	[rbp]

	; poinformuj kontroler PIC o obsłużeniu przerwania sprzętowego
	mov	al,	PIC_IRQ_ACCEPT
	out	PORT_PIC_MASTER_command,	al

	; przywróć oryginalne rejestry procesu
	pop	r15
	pop	r14
	pop	r13
	pop	r12
	pop	r11
	pop	r10
	pop	r9
	pop	r8
	pop	rbp
	pop	rdi
	pop	rsi
	pop	rdx
	pop	rcx
	pop	rbx
	pop	rax

	; powrót z procedury
	iretq
