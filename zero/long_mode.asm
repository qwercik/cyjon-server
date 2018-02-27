;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

	; załaduj globalną tablicę deskryptorów
	lgdt	[zero_gdt_x64_header]

	; włącz PGE, PAE oraz OSFXSR w CR4
	mov	eax,	1010100000b	; OSFXSR (bit 9), PGE (bit 7) i PAE (bit 5)
	mov	cr4,	eax

	; załaduj do CR3 adres tablicy PML4
	mov	eax,	ZERO_PAGING_address
	mov	cr3,	eax

	; włącz w rejestrze EFER MSR tryb LME (bit 9)
	mov	ecx,	0xC0000080	; numer EFER MSR
	rdmsr
	or	eax,	100000000b
	wrmsr

	; włącz stronicowanie
	mov	eax,	cr0
	or	eax,	0x80000001	; włącz PG (bit 31) i PE (bit 0)
	mov	cr0,	eax

	; skocz do 64 bitowego kodu
	jmp	0x0008:long_mode

; wszystkie tablice trzymamy pod pełnym adresem
align ZERO_QWORD_SIZE_byte
zero_gdt_x64_table:
	; deskryptor zerowy
	dq	0x0000000000000000
	; deskryptor kodu
	dw	0x0000
	dw	0x0000
	db	0x00
	db	10011000b
	db	00100000b
	db	0x00
	; deskryptor danych
	dw	0x0000
	dw	0x0000
	db	0x00
	db	10010010b
	db	00100000b
	db	0x00
zero_gdt_x64_table_end:

zero_gdt_x64_header:
	dw	zero_gdt_x64_table_end - zero_gdt_x64_table - 0x01
	dd	zero_gdt_x64_table
