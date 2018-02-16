;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

;===============================================================================
kernel_task:
	; zachowaj oryginalny rejestr na stosie kontekstu procesu/jądra
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

;===============================================================================
; wejście:
;	rbx - flagi zadania
;	rcx - ilość znaków w nazwie zadania
;	rsi - wskaźnik do ciągu znaków nazwy zadania
;	r11 - adres tablicy PML4 zadania
; wyjście:
;	Flaga CF jeśli brak wolnego miejsca w kolejce
;	rcx - numer PID utworzonego zadania
kernel_task_add:
	; zachowaj oryginalne rejestry
	push	rax
	push	rsi
	push	rdi
	push	r8
	push	r14
	push	r15

	; znajdź wolny wpis na liście zadań
	call	kernel_task_queue
	jc	.end

	; zachowaj wskaźnik
	push	rdi

	; pobierz wolny numer PID i zachowaj jego inkrementacje
	mov	rax,	qword [kernel_task_pid_next]
	inc	qword [kernel_task_pid_next]

	; zapisz numer PID zadania
	mov	qword [rdi + KERNEL_STRUCTURE_TASK.pid],	rax

	; zapisz adres tablicy PML4 zadania
	mov	qword [rdi + KERNEL_STRUCTURE_TASK.cr3],	r11

	; zapisz spreparowany wskaźnik szczytu stosu kontekstu zadania
	mov	rax,	KERNEL_MEMORY_STACK_KERNEL_address + KERNEL_PAGE_SIZE_byte - ( QWORD_SIZE_byte * 0x14 )
	mov	qword [rdi + KERNEL_STRUCTURE_TASK.rsp],	rax

	; zapisz informacje o ilości znaków w nazwie procesu
	mov	byte [rdi + KERNEL_STRUCTURE_TASK.length],	cl

	; zapisz nazwę zadania
	add	rdi,	KERNEL_STRUCTURE_TASK.name
	rep	movsb

	; przywróć wskaźnik
	pop	rdi

	; zwróć numer PID zadania
	mov	rcx,	qword [rdi + KERNEL_STRUCTURE_TASK.pid]

	; aktualizuj flagi zadania
	mov	word [rdi + KERNEL_STRUCTURE_TASK.flags],	bx

	; flaga, sukces
	clc

.end:
	; przywróć oryginalne rejestry
	pop	r15
	pop	r14
	pop	r8
	pop	rdi
	pop	rsi
	pop	rax

	; powrót z procedury
	ret

;===============================================================================
; wyjście:
;	Flaga CF - jeśli kolejka pełna
;	rdi - wskaźnik do wolnego miejsca w kolejce
kernel_task_queue:
	; zachowaj oryginalne rejestry
	push	rcx
	push	rdi

.wait:
	; czekaj na wolny dostęp do kolejki
	cmp	byte [kernel_task_semaphore],	TRUE
	je	.wait

	; zablokuj dostęp do kolejki
	mov	byte [kernel_task_semaphore],	TRUE

	; przeszukaj od początku kolejkę za wolnym rekordem
	mov	rdi,	qword [kernel_task_queue_address]

.restart:
	; ilość wpisów na blok
	mov	rcx,	KERNEL_STRUCTURE_BLOCK.link / KERNEL_STRUCTURE_TASK.SIZE

.next:
	; wpis wolny?
	cmp	word [rdi + KERNEL_STRUCTURE_TASK.flags],	EMPTY
	je	.found	; tak

	; przesuń wskaźnik na następny wpis
	add	rdi,	KERNEL_STRUCTURE_TASK.SIZE

	; pozostały wpisy w bloku?
	dec	rcx
	jnz	.next

	; zachowaj adres początku ostatniego bloku kolejki
	mov	rcx,	rdi	; zachowaj adres
	and	rcx,	KERNEL_PAGE_mask

	; pobierz adres następnego bloku kolejki
	mov	rdi,	qword [rcx + KERNEL_STRUCTURE_BLOCK.link]

	; powróciliśmy na początek kolejki?
	cmp	rdi,	qword [kernel_task_queue_address]
	jne	.restart	; nie

	; przygotuj następny blok do rozszerzenia kolejki
	call	kernel_page_request
	jc	.error

	; wyczyść blok i połącz z końcem kolejki
	call	kernel_page_dump
	mov	qword [rcx + KERNEL_STRUCTURE_BLOCK.link],	rdi

	; połącz koniec kolejki z początkiem
	mov	rcx,	qword [kernel_task_queue_address]
	mov	qword [rdi + KERNEL_STRUCTURE_BLOCK.link],	rcx

	; w nowym bloku automatycznie znajduje się wolny wpis
	jmp	.found

.error:
	; brak wolnego miejsca w kolejce

	; flaga, błąd
	stc

	; koniec obsługi procedury
	jmp	.end

.found:
	; zarezerwuj wpis w kolejce
	mov	word [rdi + KERNEL_STRUCTURE_TASK.flags],	KERNEL_TASK_FLAG_RESERVED

	; zwróć adres wolnego wpisu w kolejce
	mov	qword [rsp],	rdi

	; odblokuj dostęp do kolejki
	mov	byte [kernel_task_semaphore],	FALSE

	; flaga, sukces
	clc

.end:
	; przywróć oryginalne rejestry
	pop	rdi
	pop	rcx

	; powrót z procedury
	ret
