;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

; 16 bitowy kod
[BITS 16]

real_mode:
	; wszystkie wybudzone rdzenie fizyczne/logiczne procesora trafiają tu
	xchg	bx,bx

	; wyłącz przerwania
	cli

	; wyczyść flagę DF
	cld

	; wyczyść rejestry
	xor	eax,	eax
	xor	ebx,	ebx
	xor	ecx,	ecx
	xor	edx,	edx
	xor	esi,	esi
	xor	edi,	edi
	xor	ebp,	ebp

	; ustaw adresy przestrzeni segmentów
	mov	dx,	ax
	mov	es,	ax
	mov	ss,	ax
	mov	gs,	ax
	mov	fs,	ax

	; ustaw szczyt stosu
	mov	esp,	0x00001000

	; ustaw adres przestrzeni segmentu kodu (w razie wystąpienia malfunkji)
	jmp	0x0000:.repair_cs

.repair_cs:
	; wszystkie wybudzone rdzenie fizyczne/logiczne procesora, mogą mieć wyłączoną linię A20
	; włącz

	; zatrzymaj dalsze wykonywanie kodu
	jmp	$
