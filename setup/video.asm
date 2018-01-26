;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

	; ustaw komunikat
	mov	ecx,	text_error_video_text_mode_end - text_error_video_text_mode
	mov	esi,	text_error_video_text_mode

	; czy program rozruchowy udostępnił informacje o trybie karty graficznej?
	bt	word [ebx + STATIC_STRUCTURE_MULTIBOOT_BOOT_INFORMATION.flags],	STATIC_MULTIBOOT_BOOT_INFORMATION_FLAG_BIT_VIDEO
	jne	kernel_panic	; nie, wyświetl komunikat

	; ustaw wskaźnik na tablicę SuperVGA Mode Info
	mov	edi,	dword [ebx + STATIC_STRUCTURE_MULTIBOOT_BOOT_INFORMATION.vbe_mode_info]

	;---
	; pobierz niezbędne informacie o trybie graficznym

	; rozmiar piksela (głębia kolorów) w bitach
	movzx	eax,	byte [edi + STATIC_STRUCTURE_VIDEO_SUPERVGA_MODE_INFO_BLOCK.BitsPerPixel]
	mov	dword [variable_kernel_video_depth_bit],	eax

	; ustaw komunikat
	mov	ecx,	text_error_video_color_depth_end - text_error_video_color_depth
	mov	esi,	text_error_video_color_depth

	; czy głębia kolorów jest obsługiwana?
	cmp	eax,	STATIC_VIDEO_COLOR_DEPTH_BIT
	jne	kernel_panic	; nie, wyświetl komunikat

	; adres fizyczny przestrzeni pamięci karty graficznej
	mov	eax,	dword [edi + STATIC_STRUCTURE_VIDEO_SUPERVGA_MODE_INFO_BLOCK.PhysicalVideoAddress]
	mov	dword [variable_kernel_video_base_address],	eax

	; szerokość ekranu w pikselach
	movzx	eax,	word [edi + STATIC_STRUCTURE_VIDEO_SUPERVGA_MODE_INFO_BLOCK.XResolution]
	mov	dword [variable_kernel_video_width_pixel],	eax

	; wysokość ekranu w pikselach
	movzx	eax,	word [edi + STATIC_STRUCTURE_VIDEO_SUPERVGA_MODE_INFO_BLOCK.YResolution]
	mov	dword [variable_kernel_video_height_pixel],	eax

	; szerokość ekranu w pikselach (wraz z uzupełnieniem)
	movzx	eax,	word [edi + STATIC_STRUCTURE_VIDEO_SUPERVGA_MODE_INFO_BLOCK.BytesPerScanLine]
	mov	dword [variable_kernel_video_scanline_byte],	eax

	;---
	; wykonaj podstawowe obliczenia ułatwiające zarządzanie przestrzenią pamięci karty graficznej

	; oblicz rozmiar przestrzeni pamięci karty graficznej w Bajtach
	mul	dword [variable_kernel_video_height_pixel]
	mov	dword [variable_kernel_video_size_byte],	eax

	; przelicz rozmiar przestrzeni pamięci karty graficznej na strony
	shr	eax,	STATIC_DIVIDE_BY_PAGE_SIZE
	inc	eax
	mov	dword [variable_kernel_video_size_page],	eax

	;---
	; wyczyść przestrzeń pamięci karty graficznej
	mov	eax,	VARIABLE_VIDEO_COLOR_BACKGROUND
	mov	ecx,	dword [variable_kernel_video_size_byte]
	shr	ecx,	STATIC_VIDEO_COLOR_DEPTH_SHIFT
	mov	edi,	dword [variable_kernel_video_base_address]
	rep	stosd
