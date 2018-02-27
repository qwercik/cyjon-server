;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

;===============================================================================
; wejście:
;	rsi - wskaźnik do wiersza tablicy wątków
; wyjście:
;	rcx - PID nowego wątku
kernel_thread_new:
	; zachowaj oryginalne rejestry
	push	rax
	push	rbx
	push	rcx
	push	rsi
	push	rdi
	push	rbp
	push	r8
	push	r11

	; utwórz zmienną lokalną
	push	EMPTY

	; rozmiar programu w stronach
	mov	rcx,	qword [rdi + KERNEL_STRUCTURE_THREAD.limit]
	call	library_page_from_byte

	; zachowaj rozmiar przestrzeni w zmiennej lokalnej
	mov	qword [rsp],	rcx

	; zwieksz rozmiar niezbędnej przestrzeni o:
	add	rcx,	1	; tablica PML4 procesu
	add	rcx,	3	; tablice PML3,2,1 stosu kontekstu zadania
	add	rcx,	2	; przestrzeń stosu kontekstu
	add	rcx,	3	; tablice PML3,2,1 stosu zadania
	add	rcx,	1	; przestrzeń stosu
	add	rcx,	3	; tablice PML3,2,1 dla przestrzeni kodu zadania
	;-----------------------------------------------------------------------
	add	rcx,	1	; rozszerzenie kolejki zadań, gdyby ostała się pełna
	call	kernel_page_secure
	jc	.error	; brak wystarczającej ilości przestrzeni

	; poinformuj wszystkie procedury zależne, do korzystania z zarezerwowanych stron
	mov	rbp,	rcx

	; zarezerwuj przestrzeń pod tablicę PML4
	call	kernel_page_request
	call	kernel_page_dump
	mov	r11,	rdi	; zachowaj adres

	; zarejestruj w tablicach stronicowania, stos kontekstu zadania
	mov	rax,	KERNEL_MEMORY_STACK_KERNEL_address
	mov	rbx,	KERNEL_PAGE_FLAG_AVAILABLE | KERNEL_PAGE_FLAG_WRITE
	mov	rcx,	KERNEL_MEMORY_STACK_KERNEL_SIZE_byte >> DIVIDE_BY_PAGE_shift
	call	kernel_page_map_logical

	; odstaw na początek stosu kontekstu zadania, spreparowane dane powrotu z przerwania sprzętowego "kernel_task"
	mov	rdi,	qword [r8]
	and	rdi,	KERNEL_PAGE_mask	; usuń flagi rekordu tablicy PML1
	add	rdi,	KERNEL_PAGE_SIZE_byte - ( QWORD_SIZE_byte * 0x05 )	; odłóż 5 rejestrów

	; RIP
	mov	rax,	KERNEL_MEMORY_HIGH_REAL_address
	stosq

	; CS
	mov	rax,	KERNEL_STRUCTURE_GDT.cs_ring3 | 0x03
	stosq	; zapisz

	; EFLAGS
	mov	rax,	KERNEL_TASK_EFLAGS_DEFAULT
	stosq	; zapisz

	; RSP
	mov	rax,	EMPTY
	stosq	; zapisz

	; DS
	mov	rax,	KERNEL_STRUCTURE_GDT.ds_ring3 | 0x03
	stosq	; zapisz

	; mapuj przestrzeń jądra systemu
	mov	rsi,	qword [kernel_page_pml4_address]
	mov	rdi,	r11
	call	kernel_page_merge

	; przygotuj miejsce pod stos procesu
	mov	rax,	KERNEL_MEMORY_STACK_THREAD_address
	mov	rbx,	KERNEL_PAGE_FLAG_AVAILABLE | KERNEL_PAGE_FLAG_WRITE | KERNEL_PAGE_FLAG_USER
	mov	rcx,	KERNEL_MEMORY_STACK_THREAD_SIZE_byte >> DIVIDE_BY_PAGE_shift
	call	kernel_page_map_logical

	; przygotuj miejsce pod przestrzeń kodu procesu
	mov	rax,	KERNEL_MEMORY_HIGH_VIRTUAL_address
	mov	rcx,	qword [rsp]	; rozmiar w stronach z zmiennej lokalnej
	call	kernel_page_map_logical

	; przywróć wskaźnik do rekordu tablicy
	mov	rdi,	qword [rsp + QWORD_SIZE_byte * 0x04]

	; można, mapować po jednej stronie przestrzeni kodu programu i kolejno ładować kawałki kodu
	; ale na stan dzisiejszy kod poniższy jest to wystarczający

	;=======================================================================
	; wyłącz przerwania
	cli

	; przełącz stronicowanie na nowe zadanie
	mov	rax,	cr3
	mov	cr3,	r11

	; załaduj program do przestrzeni pamięci kodu nowego zadania
	mov	rcx,	qword [rdi + KERNEL_STRUCTURE_THREAD.limit]
	mov	rsi,	qword [rdi + KERNEL_STRUCTURE_THREAD.address]
	mov	rdi,	KERNEL_MEMORY_HIGH_REAL_address
	rep	movsb

	; przełącz stronicowanie na aktualny proces
	mov	cr3,	rax

	sti
	; włącz przerwania
	;=======================================================================

	; przywróć wskaźnik do rekordu tablicy
	mov	rdi,	qword [rsp + QWORD_SIZE_byte * 0x04]

	; wstaw zadanie do kolejki
	;	rbx - flagi zadania
	;	rcx - ilość znaków w nazwie zadania
	;	rsi - wskaźnik do ciągu znaków nazwy zadania
	;	r11 - adres tablicy PML4 zadania
	mov	rbx,	KERNEL_TASK_FLAG_ACTIVE
	movzx	rcx,	byte [rdi + KERNEL_STRUCTURE_THREAD.length]
	mov	rsi,	rdi
	inc	rsi
	call	kernel_task_add

	; zwolnij niewykrzystane, zarezerwowane strony
	add	qword [kernel_page_free_count],	rbp
	sub	qword [kernel_page_reserved_count],	rbp

	; zwróć numer PID utworzonego zadania
	mov	qword [rsp + QWORD_SIZE_byte * 0x06],	rcx

	; flaga, sukces
	clc

	; koniec
	jmp	.end

.error:
	; flaga, błąd
	stc

.end:
	; usuń zmienną lokalną
	add	rsp,	QWORD_SIZE_byte

	; przywróć oryginalne rejestry
	pop	r11
	pop	r8
	pop	rbp
	pop	rdi
	pop	rsi
	pop	rcx
	pop	rbx
	pop	rax

	; powrót z procedury
	ret
