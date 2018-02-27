;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

	; załaduj czcionkę do przestrzeni BIOSu
	mov	ax,	0x1110
	mov	bx,	0x1000	; bh, wysokość znaku (16 pikseli)
	mov	cx,	256	; ilość znaków do załadowania
	xor	dx,	dx	; rozpocząć od pocżątku matrycy
	mov	bp,	font_matrix
	int	0x10
