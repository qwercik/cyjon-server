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
kernel_video_base_address		dq	EMPTY
kernel_video_size_byte			dq	EMPTY
kernel_video_size_page			dq	EMPTY
kernel_video_width_pixel		dq	EMPTY
kernel_video_width_byte			dq	EMPTY
kernel_video_width_char			dq	EMPTY 
kernel_video_height_pixel		dq	EMPTY
kernel_video_height_char		dq	EMPTY
kernel_video_pixel_byte			dq	DWORD_SIZE_byte
kernel_video_scanline_byte		dq	EMPTY
kernel_video_scanline_padding_byte	dq	EMPTY 
kernel_video_scanline_char_byte		dq	EMPTY
kernel_video_char_width_byte		dq	EMPTY

kernel_video_cursor_x			dq	EMPTY
kernel_video_cursor_y			dq	EMPTY
kernel_video_cursor_indicator		dq	EMPTY
kernel_video_cursor_lock_level		dq	EMPTY

kernel_video_font_color			dd	COLOR_GRAY_LIGHT	; znaku
					dd	COLOR_BLACK		; tła

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

;===============================================================================
; KEYBOARD
;===============================================================================
kernel_keyboard_semaphore		db	FALSE

kernel_keyboard_cache			dw	EMPTY, EMPTY, EMPTY, EMPTY

kernel_keyboard_key_ctrl		db	FALSE
kernel_keyboard_key_shift_left		db	FALSE
kernel_keyboard_key_shift_right		db	FALSE
kernel_keyboard_key_alt			db	FALSE

kernel_keyboard_matrix			dq	kernel_keyboard_matrix_low, kernel_keyboard_matrix_high
kernel_keyboard_matrix_low		db	0x00, 0x1B, "1234567890-=", 0x08, 0x09, "qwertyuiop[]", 0x0D, 0x1D, "asdfghjkl;", "'", "`", 0x2A, "\", "zxcvbnm,./", 0x36, 0x00, 0x38, " ", 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, "789-456+1230", 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
					db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x9D, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
kernel_keyboard_matrix_high		db	0x00, 0x1B, "!@#$%^&*()_+", 0x08, 0x09, "QWERTYUIOP{}", 0x0D, 0x00, "ASDFGHJKL:", '"', "~", 0x00, "|", "ZXCVBNM<>?", 0x00, 0x00, 0x00, " ", 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, "789-456+1230", 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
					db	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x9D, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

;===============================================================================
; THREAD
;===============================================================================
kernel_thread_table:
.shell:
	; program "shell"
	db	5
	db	"shell"
	times	255 - 5 db EMPTY
	dq	kernel_thread_file_shell
	dq	kernel_thread_file_shell_end - kernel_thread_file_shell

	; koniec tablicy
	db	EMPTY
kernel_thread_table_end:

kernel_thread_file_shell:	incbin	"build\shell"
kernel_thread_file_shell_end:
