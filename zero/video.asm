;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

video:
	; pobierz informacje o SuperVGA
	mov	ax,	0x4F00
	mov	di,	zero_vga_info_block
	int	0x10

	; SuperVGA dostępne?
	cmp	ax,	0x004F
	jne	.error	; tak

	; ustaw wskaźnik na tablicę dostępnych trybów
	mov	esi,	dword [di + ZERO_STRUCTURE_VGA_INFO_BLOCK.VideoModePtr]

	; specyfikacje przetwarzanego trybu zapisuj tutaj
	mov	edi,	ZERO_SUPERVGA_address

.loop:
	; pobierz informacje o danym trybie pracy
	mov	ax,	0x4F01
	mov	cx,	word [esi]
	int	0x10

	; pobrano bezbłędnie?
	cmp	ah,	ZERO_EMPTY
	jne	.error	; nie

	; tryb posiada niezbędną szerokość w pikselach?
	cmp	word [edi + ZERO_STRUCTURE_MODE_INFO_BLOCK.XResolution],	ZERO_VIDEO_MODE_WIDTH_pixel
	jne	.leave	; nie

	; tryb posiada niezbędą wysokość w pikselach?
	cmp	word [edi + ZERO_STRUCTURE_MODE_INFO_BLOCK.YResolution],	ZERO_VIDEO_MODE_HEIGHT_pixel
	jne	.leave	; nie

	; głębia kolorów odpowiednia?
	cmp	byte [edi + ZERO_STRUCTURE_MODE_INFO_BLOCK.BitsPerPixel],	ZERO_VIDEO_MODE_COLOR_DEPTH_bit
	jne	.leave	; nie

	; odnaleziono porządany tryb graficzny, przełącz
	mov	ax,	0x4F02
	mov	bx,	word [si]
	or	bx,	0x4000	; liniowa przestrzeń pamięci
	int	0x10

	; koniec
	jmp	.end

.leave:
	; następny rekord
	add	esi,	ZERO_WORD_SIZE_byte

	; koniec tablicy?
	cmp	word [esi],	ZERO_MAX_UNSIGNED
	jne	.loop	; nie

.error:
	; przygotuj komunikat błędu
	mov	esi,	zero_error_video_text

	; wyświetl
	jmp	error

.end:
