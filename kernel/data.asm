;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

;===============================================================================
; MEMORY
;===============================================================================
; binarna mapa pamięci
kernel_memory_map_address_start	dq	EMPTY
kernel_memory_map_address_end	dq	EMPTY

;===============================================================================
; PAGE
;===============================================================================
kernel_page_lock_semaphore	db	FALSE	; zablokowany dostęp do stron?

kernel_page_total_count		dq	EMPTY	; całkowity rozmiar wolnej przestrzeni pamięci w stronach
kernel_page_free_count		dq	EMPTY	; ilość stron wolnych
kernel_page_reserved_count	dq	EMPTY	; ilość stron zablokowanych (np. przez inny proces)

kernel_page_pml4_address	dq	EMPTY	; tablica PML4 jądra systemu

;===============================================================================
; GDT
;===============================================================================
; wszystkie newralgiczne tablice i nagłówki przechowuj wyrównane do pełnego adresu
align	QWORD_SIZE_byte,	db	EMPTY
kernel_gdt_header:
				dw	KERNEL_PAGE_SIZE_byte	; rozmiar tablicy GDT jądra systemu
				dq	EMPTY	; adres tablicy GDT jądra systemu

kernel_gdt_tss_selector		dw	KERNEL_STRUCTURE_GDT.tss

; trzymaj wszystkie newralgiczne tablice, wyrównane do pełnego adresu
align	QWORD_SIZE_byte,	db	EMPTY
kernel_gdt_tss_table:
				dd	EMPTY	; zastrzeżone
				dq	KERNEL_MEMORY_HIGH_VIRTUAL_address - KERNEL_PAGE_SIZE_byte	; RSP0
		times	92	db	EMPTY	; nie wykorzystywane
kernel_gdt_tss_table_end:

;===============================================================================
; VIDEO
;===============================================================================
kernel_video_base_address	dq	0x0B8000
kernel_video_size_byte		dq	4000
kernel_video_size_page		dq	1

;===============================================================================
; PIC
;===============================================================================
kernel_pic_semaphore_bit	dw	MAX_UNSIGNED
