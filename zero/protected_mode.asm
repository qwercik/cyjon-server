;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

	; wyłącz obsługę wyjątków i przerwań
	cli

	; załaduj globalną tablicę deskryptorów
	lgdt	[zero_gdt_x32_header]

	; przełącz procesor w tryb chroniony
	mov	eax,	cr0
	bts	eax,	0	; włącz pierwszy bit rejestru cr0
	mov	cr0,	eax

	; skocz do 32 bitowego kodu
	jmp	long 0x0008:protected_mode

; wszystkie tablice trzymamy pod pełnym adresem
align ZERO_DWORD_SIZE_byte
zero_gdt_x32_table:
	; deskryptor zerowy
	dq	0x0000000000000000
	; deskryptor kodu
	dw	0xffff
	dw	0x0000
	db	0x00
	db	10011000b
	db	11001111b
	db	0x00
	; deskryptor danych
	dw	0xffff
	dw	0x0000
	db	0x00
	db	10010010b
	db	11001111b
	db	0x00
zero_gdt_x32_table_end:

zero_gdt_x32_header:
	dw	zero_gdt_x32_table_end - zero_gdt_x32_table - 0x01
	dd	zero_gdt_x32_table
