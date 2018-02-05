;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

	; przygotuj miejsce na tablicę PML4 jądra systemu
	call	kernel_page_request

	; wyczyść tablicę PML4 i zapamiętaj jej adres
	call	kernel_page_dump
	mov	qword [kernel_page_pml4_address],	rdi

	; mapuj w tablicach stronicowania przestrzeń pamięci fizycznej RAM opisanej w binarnej mapie pamięci
	mov	eax,	KERNEL_BASE_address	; początek przestrzeni
	; oznacz przestrzeń jako dostępną i możliwą do zapisu
	mov	ebx,	KERNEL_PAGE_FLAG_AVAILABLE | KERNEL_PAGE_FLAG_WRITE
	mov	rcx,	qword [kernel_page_total_count]	; ilość stron
	mov	r11,	rdi	; uzupełnij nową tablice stronicowania jądra systemu
	call	kernel_page_map_physical

	; utwórz stos/"stos kontekstu" dla jądra systemu na końcu pierwszej połowy przestrzeni pamięci logicznej
	; jądro systemu otrzyma pierwszą połowę przestrzeni pamięci logicznej
	; (bochs potrafi się sypać namiętnie, jeśli zrobimy na odwrót)
	mov	rax,	KERNEL_MEMORY_STACK_KERNEL_address
	mov	rcx,	KERNEL_MEMORY_STACK_KERNEL_SIZE_byte >> DIVIDE_BY_PAGE_shift
	call	kernel_page_map_logical

	; mapuj przestrzeń pamięci fizycznej karty graficznej
	mov	rax,	qword [kernel_video_base_address]
	mov	rcx,	qword [kernel_video_size_page]
	; przestrzeń pamięci karty graficznej jest tylko do zapisu
	; (da się z niej odczytać, ale infomujemy procesor, że będziemy tylko zapisywać)
	or	rbx,	KERNEL_PAGE_FLAG_WRITE_THROUGH
	call	kernel_page_map_physical

	; przeładuj stronicowanie na własne/nowo utworzone
	mov	rax,	rdi
	mov	cr3,	rax

	; ustawiamy wskaźnik szczytu stosu na koniec nowego stosu jądra systemu
	mov	rsp,	KERNEL_MEMORY_STACK_KERNEL_address + KERNEL_PAGE_SIZE_byte
