;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

	; przygotuj komunikat
	mov	ecx,	text_error_gdt_end - text_error_gdt
	mov	esi,	text_error_gdt

	; zarezerwuj przestrzeń dla Globalnej Tablicy Deskryptorów
	call	kernel_page_request
	jc	kernel_panic	; błąd krytyczny

	; wyczyść tablicę GDT i zachowaj jej adres
	call	kernel_page_dump
	mov	qword [kernel_gdt_header + KERNEL_STRUCTURE_GDT_HEADER.address],	rdi

	xchg	bx,bx

	;-----------------------------------------------------------------------
	; utwórz deskryptor NULL
	xor	eax,	eax
	stosq	; zapisz

	; utwórz deskryptor kodu ring0 (CS)
	mov	rax,	0000000000100000100110000000000000000000000000000000000000000000b
	stosq	; zapisz

	; utwórz deskryptor danych/stosu ring0 (DS/SS)
	mov	rax,	0000000000100000100100100000000000000000000000000000000000000000b
	stosq	; zapisz

	; utwórz deskryptor kodu ring3 (CS)
	mov	rax,	0000000000100000111110000000000000000000000000000000000000000000b
	stosq	; zapisz

	; utwórz deskryptor danych/stosu ring3 (DS/SS)
	mov	rax,	0000000000100000111100100000000100000000000000000000000000000000b
	stosq	; zapisz

	;-----------------------------------------------------------------------
	; utwórz deskryptor TSS jądra systemu

	; rozmiar tablicy Task State Segment w Bajtach
	mov	ax,	kernel_gdt_tss_table_end - kernel_gdt_tss_table
	stosw	; zapisz

	; pobierz adres fizyczny tablicy Task State Segment
	mov	rax,	kernel_gdt_tss_table
	stosw	; zapisz (bity 15..0)
	shr	rax,	16	; przesuń starszą część rejestru EAX do AX
	stosb	; zapisz (bity 23..16)

	; zachowaj pozostałą część adresu tablicy Task State Segment
	push	rax

	; uzupełnij deskryptor Task State Segment o flagi
	mov	al,	10001001b	; P, DPL, 0, Type
	stosb	; zapisz
	xor	al,	al		; G, 0, 0, AVL, Limit (starsza część rozmiaru tablicy Task State Segment)
	stosb	; zapisz

	; przywróć pozostałą część adresu tablicy Task State Segment
	pop	rax

	; przenieś bity 31..24 do rejestru AL
	shr	rax,	8
	stosb	; zapisz (bity 31..24)

	; przenieś bity 63..32 do rejestru EAX
	shr	rax,	8
	stosd	; zapisz (bity 63..32)

	; 32 Bajty deskryptora - zastrzeżone
	xor	rax,	rax
	stosd	; zapisz

	; przeładuj Globalną Tablicę Deskryptorów
	lgdt	[kernel_gdt_header]

	; załaduj deskryptor Task State Segment
	ltr	word [kernel_gdt_tss_selector]
