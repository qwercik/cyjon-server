;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

;===============================================================================
; PAGE
;===============================================================================
kernel_page_lock_semaphore	db	FALSE	; zablokowany dostęp do stron?

kernel_page_total_count		dq	EMPTY	; całkowity rozmiar wolnej przestrzeni pamięci w stronach
kernel_page_free_count		dq	EMPTY	; ilość stron wolnych
kernel_page_reserved_count	dq	EMPTY	; ilość stron zablokowanych (np. przez inny proces)

kernel_page_pml4_address	dq	EMPTY	; tablica PML4 jądra systemu

;===============================================================================
; MEMORY
;===============================================================================
; binarna mapa pamięci
kernel_memory_map_address_start	dq	EMPTY
kernel_memory_map_address_end	dq	EMPTY
