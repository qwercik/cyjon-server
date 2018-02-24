;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

	; przełączono w tryb graficzny?
	test	rsi,	rsi
	jz	kernel_panic	; nie

	; tryb graficzny o głębi kolorów 32 bity?
	cmp	byte [esi + SUPERVGA_STRUCTURE_MODE_INFO_BLOCK.BitsPerPixel],	32
	jne	kernel_panic	; nie

	; pobierz adres fizyczny przestrzeni pamięci karty graficznej, zarazem początkowy wskaźnik kursora
	mov	eax,	dword [esi + SUPERVGA_STRUCTURE_MODE_INFO_BLOCK.PhysicalVideoAddress]
	mov	dword [kernel_video_base_address],	eax
	mov	dword [kernel_video_cursor_indicator],	eax

	; pobierz szerokość ekranu w pikselach
	movzx	eax,	word [esi + SUPERVGA_STRUCTURE_MODE_INFO_BLOCK.XResolution]
	mov	dword [kernel_video_width_pixel],	eax

	; pobierz wysokość ekranu w pikselach
	movzx	eax,	word [esi + SUPERVGA_STRUCTURE_MODE_INFO_BLOCK.YResolution]
	mov	dword [kernel_video_height_pixel],	eax

	; pobierz rozmiar scanline w Bajtach
	movzx	eax,	word [esi + SUPERVGA_STRUCTURE_MODE_INFO_BLOCK.BytesPerScanLine]
	mov	dword [kernel_video_scanline_byte],	eax

	; wykonaj podstawowe obliczenia ułatwiające zarządzanie przestrzenią pamięci karty graficznej

	; oblicz rozmiar przestrzeni pamięci karty graficznej w Bajtach
	mul	qword [kernel_video_height_pixel]
	mov	qword [kernel_video_size_byte],	rax

	; oblicz rozmiar przestrzeni pamięci karty graficznej w stronach
	shr	rax,	DIVIDE_BY_PAGE_shift
	inc	rax
	mov	qword [kernel_video_size_page],	rax

	; oblicz szerokość rozdzielczości w Bajtach
	mov	eax,	dword [kernel_video_width_pixel]
	mul	dword [kernel_video_pixel_byte]
	mov	dword [kernel_video_width_byte],	eax

	; oblicz rozmiar uzupełnienia scanline w Bajtach
	sub	eax,	dword [kernel_video_scanline_byte]
	not	eax
	inc	eax
	mov	dword [kernel_video_scanline_padding_byte],	eax

	; oblicz szerokość znaku dołączonej czcionki w Bajtach
	movzx	eax,	byte [kernel_font_width_pixel]
	mul	byte [kernel_video_pixel_byte]
	mov	word [kernel_video_char_width_byte],	ax

	; oblicz scanline wypełniony znakami
	movzx	eax,	byte [kernel_font_height_pixel]
	mul	dword [kernel_video_scanline_byte]
	mov	dword [kernel_video_scanline_char_byte],	eax

	; oblicz szerokość ekranu w znakach
	mov	eax,	dword [kernel_video_width_pixel]
	div	qword [kernel_font_width_pixel]
	mov	dword [kernel_video_width_char],	eax

	; oblicz wysokość ekranu w znakach
	mov	eax,	dword [kernel_video_height_pixel]
	div	qword [kernel_font_height_pixel]
	mov	dword [kernel_video_height_char],	eax
