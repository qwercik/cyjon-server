;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

	;-----------------------------------------------------------------------
	; wyczyść przestrzeń pod tablice stronicowania
	xor	eax,	eax
	mov	ecx,	ZERO_PAGE_SIZE_byte * 0x06	; PML4, PML3, PML2x4
	mov	edi,	ZERO_PAGING_address
	rep	stosb

	;-----------------------------------------------------------------------
	; uzupełnij pierwszy wiersz tablicy PML4
	mov	dword [ZERO_PAGING_address],	ZERO_PAGING_address + ZERO_PAGE_SIZE_byte + 0x03

	;-----------------------------------------------------------------------
	; uzupełnij 4 wiersze tablicy PML3
	mov	dword [ZERO_PAGING_address + ZERO_PAGE_SIZE_byte],	ZERO_PAGING_address + (ZERO_PAGE_SIZE_byte * 0x02) + 0x03
	mov	dword [ZERO_PAGING_address + ZERO_PAGE_SIZE_byte + 0x08],	ZERO_PAGING_address + (ZERO_PAGE_SIZE_byte * 0x03) + 0x03
	mov	dword [ZERO_PAGING_address + ZERO_PAGE_SIZE_byte + 0x10],	ZERO_PAGING_address + (ZERO_PAGE_SIZE_byte * 0x04) + 0x03
	mov	dword [ZERO_PAGING_address + ZERO_PAGE_SIZE_byte + 0x18],	ZERO_PAGING_address + (ZERO_PAGE_SIZE_byte * 0x05) + 0x03
								;  nr wiersza ^

	;-----------------------------------------------------------------------
	; uzupełnij wszystkie wiersze tablic PML2
	mov	eax,	0x83
	mov	ecx,	2048
	mov	edi,	ZERO_PAGING_address + (ZERO_PAGE_SIZE_byte * 0x02)

.next:
	; uzupełnij
	stosd

	; przesuń wskaźnik na następny wiersz tablic
	add	edi,	ZERO_DWORD_SIZE_byte

	; mapuj następne 2 MiB przestrzeni fizycznej pamięci RAM
	add	eax,	0x00200000

	; pozostały wiersze do uzupełnienia?
	dec	ecx
	jnz	.next	; tak
