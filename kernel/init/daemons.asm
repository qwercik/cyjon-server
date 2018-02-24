;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

	; ustaw wskaźnik na początek listy demonów
	mov	rsi,	list_daemons

daemons:
	; przygotuj miejsce pod tablicę PML4 demona i wyczyść wszystkie rekordy
	call	kernel_page_request
	call	kernel_page_dump

	; mapuj przestrzeń pod stos demona
	mov	rax,	KERNEL_MEMORY_STACK_KERNEL_address
	mov	rbx,	KERNEL_PAGE_FLAG_AVAILABLE | KERNEL_PAGE_FLAG_WRITE
	mov	rcx,	KERNEL_MEMORY_STACK_KERNEL_SIZE_byte >> DIVIDE_BY_PAGE_shift
	mov	r11,	rdi
	call	kernel_page_map_logical

	; odstaw na szczyt stosu demona, spreparowane dane powrotu z przerwania sprzętowego
	mov	rdi,	qword [r8]	; pobierz z wiersza tablicy PML1 adres początku przestrzeni stosu
	and	rdi,	KERNEL_PAGE_mask	; usuń flagi przestrzeni
	add	rdi,	KERNEL_PAGE_SIZE_byte - ( QWORD_SIZE_byte * 0x05 )	; odłóż 5 rejestrów

	; RIP
	lodsq	; wskaźnik wejścia demona
	stosq

	; CS, wszystkie demony pracują w przestrzeni jądra systemu
	mov	rax,	KERNEL_STRUCTURE_GDT.cs_ring0
	stosq

	; EFLAGS, wszystkie flagi wyczyszczone, przerwania włączone
	mov	rax,	KERNEL_TASK_EFLAGS_DEFAULT
	stosq

	; RSP, wskaźnik szczytu stosu, po uruchomieniu demona
	mov	rax,	KERNEL_MEMORY_STACK_KERNEL_address + KERNEL_PAGE_SIZE_byte
	stosq

	; DS
	mov	rax,	KERNEL_STRUCTURE_GDT.ds_ring0
	stosq

	; zachowaj wskaźnik listy
	push	rsi

	; mapuj przestrzeń pamięci jądra systemu do demona
	mov	rsi,	qword [kernel_page_pml4_address]
	mov	rdi,	r11
	call	kernel_page_merge

	; przywróć wskaźnik listy
	pop	rsi

	; wstaw demona do kolejki zadań
	mov	rbx,	KERNEL_TASK_FLAG_ACTIVE | KERNEL_TASK_FLAG_DAEMON
	mov	rcx,	qword [rsi]
	add	rsi,	QWORD_SIZE_byte
	call	kernel_task_add

	; przesuń wskaźnik na następny element listy
	add	rsi,	qword [rsi - QWORD_SIZE_byte]

	; koniec listy demonów?
	cmp	qword [rsi],	EMPTY
	jne	daemons	; nie
