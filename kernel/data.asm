;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

;===============================================================================
; VIDEO
;===============================================================================

semaphore_kernel_video_mode_text	db	STATIC_TRUE	; tryb tekstowy dostępny

; właściwości trybu tekstowego
variable_kernel_video_base_address	dq	0x00000000000B8000	; adres przestrzeni trybu tekstowego 80x25
variable_kernel_video_size_byte		dq	( 80 * 25 ) << STATIC_MULTIPLE_BY_2	; na każdy znak w trybie tekstowym przypadają dwa Bajty
variable_kernel_video_size_page		dq	( ( 80 * 25 ) << STATIC_MULTIPLE_BY_2 >> STATIC_DIVIDE_BY_PAGE_SIZE ) + 1

; właściwości trybu graficznego zostaną przypisane podczas inicjalizacji
variable_kernel_video_width_pixel	dq	STATIC_EMPTY
variable_kernel_video_height_pixel	dq	STATIC_EMPTY
variable_kernel_video_depth_bit		dq	STATIC_EMPTY
variable_kernel_video_scanline_byte	dq	STATIC_EMPTY
variable_kernel_video_pixel_byte	dq	STATIC_EMPTY
