;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

;===============================================================================
; KERNEL
;===============================================================================
kernel_name				db	"cyjon"
kernel_name_end:

;===============================================================================
; MEMORY
;===============================================================================
; binarna mapa pamięci
kernel_memory_map_address_start		dq	EMPTY
kernel_memory_map_address_end		dq	EMPTY

;===============================================================================
; PAGE
;===============================================================================
kernel_page_lock_semaphore		db	FALSE	; zablokowany dostęp do stron?

kernel_page_total_count			dq	EMPTY	; całkowity rozmiar wolnej przestrzeni pamięci w stronach
kernel_page_free_count			dq	EMPTY	; ilość stron wolnych
kernel_page_reserved_count		dq	EMPTY	; ilość stron zablokowanych (np. przez inny proces)

kernel_page_pml4_address		dq	EMPTY	; tablica PML4 jądra systemu

;===============================================================================
; GDT
;===============================================================================
; wszystkie newralgiczne tablice i nagłówki przechowuj wyrównane do pełnego adresu
align	QWORD_SIZE_byte,		db	EMPTY
kernel_gdt_header:
					dw	KERNEL_PAGE_SIZE_byte	; rozmiar tablicy GDT jądra systemu
					dq	EMPTY	; adres tablicy GDT jądra systemu

kernel_gdt_tss_selector			dw	KERNEL_STRUCTURE_GDT.tss

; trzymaj wszystkie newralgiczne tablice, wyrównane do pełnego adresu
align	QWORD_SIZE_byte,		db	EMPTY
kernel_gdt_tss_table:
					dd	EMPTY	; zastrzeżone
					dq	KERNEL_MEMORY_HIGH_VIRTUAL_address - KERNEL_PAGE_SIZE_byte	; RSP0
			times	92	db	EMPTY	; nie wykorzystywane
kernel_gdt_tss_table_end:

;===============================================================================
; IDT
;===============================================================================
; wszystkie newralgiczne tablice i nagłówki przechowuj wyrównane do pełnego adresu
align	QWORD_SIZE_byte,		db	EMPTY
kernel_idt_header:
					dw	KERNEL_PAGE_SIZE_byte	; rozmiar tablicy IDT jądra systemu
					dq	EMPTY	; adres tablicy IDT jądra systemu

;===============================================================================
; VIDEO
;===============================================================================
kernel_video_base_address		dq	VIDEO_TEXT_MODE_BASE_address
kernel_video_size_byte			dq	VIDEO_TEXT_MODE_SIZE_byte
kernel_video_size_page			dq	VIDEO_TEXT_MODE_SIZE_page
kernel_video_width_char			dq	VIDEO_TEXT_MODE_WIDTH_char

kernel_video_cursor_indicator		dq	VIDEO_TEXT_MODE_BASE_address

kernel_video_char_color			db	VIDEO_TEXT_MODE_COLOR_FOREGROUND_GRAY_LIGHT

;===============================================================================
; PIC
;===============================================================================
kernel_pic_semaphore_bit		dw	MAX_UNSIGNED

;===============================================================================
; TASK
;===============================================================================
kernel_task_semaphore			db	FALSE

kernel_task_queue_address		dq	EMPTY

kernel_task_count			dq	EMPTY
kernel_task_count_left			dq	EMPTY
kernel_task_active			dq	EMPTY
kernel_task_pid_next			dq	1

;===============================================================================
; NETWORK
;===============================================================================
kernel_network_rx_count			dq	EMPTY
kernel_network_tx_count			dq	EMPTY
