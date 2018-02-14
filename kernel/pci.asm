;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

;============================================================================
; wejście:
;	ax - poszukiwana wartość Class & Subclass
kernel_pci_find:
	; zachowaj oryginalne rejestry
	push	rbx
	push	rcx
	push	rdx
	push	rax

	; szyna 0
	xor	ebx,	ebx
	; urządzenie 0
	xor	ecx,	ecx
	; funkcja 0
	xor	edx,	edx

.next:
	; pobierz zawartość rejestru Class & Subclass
	mov	eax,	PCI_REGISTER_CLASS_AND_SUBCLASS
	call	kernel_pci_read

	; przesuń wartość do AX
	shr	eax,	MOVE_HIGH_TO_AX

	; kontroler IDE?
	cmp	ax,	word [rsp]
	je	.found	; tak

	; następna funkcja
	inc	edx

	; koniec przegldanych funkcji?
	cmp	edx,	0x0008
	jb	.next	; nie

	; następne urządzenie na szynie
	inc	ecx

	; pierwsza funkcja urządzenia
	xor	edx,	edx

	; koniec urządzeń na danej szynie?
	cmp	ecx,	0x0020
	jb	.next	; nie

	; następna szyna
	inc	ebx

	; pierwsze urządzenie na szynie
	xor	ecx,	ecx

	; koniec dostępnych szyn?
	cmp	ebx,	0x0100
	jb	.next	; nie

.error:
	; flaga, błąd
	stc

	; koniec
	jmp	.end

.found:
	; zwróć informacje o położeniu urządzenia
	mov	qword [rsp + QWORD_SIZE_byte],	rdx
	mov	qword [rsp + QWORD_SIZE_byte * 0x02],	rcx
	mov	qword [rsp + QWORD_SIZE_byte * 0x03],	rbx

	; flaga, sukces
	clc

.end:
	; przywróć oryginalne rejestry
	pop	rax
	pop	rdx
	pop	rcx
	pop	rbx

	; powrót z procedury
	ret

;============================================================================
; wejście:
;	rax - adres rejestru do odczytu
;	bl - szyna
;	cl - urządzenie
;	dl - funkcja
; wyjście:
;	eax - odpowiedź
kernel_pci_read:
	; zachowaj oryginalne rejestry
	push	rbx
	push	rcx
	push	rdx

	; załaduj ustaw bit 31 oraz wyłącz bity 30..24
	rol	eax,	8
	or	eax,	10000000b

	; załaduj numer szyny do bitów 23..16
	rol	eax,	8
	or	al,	bl

	; załaduj numer urządzenia do bitów 15..11
	rol	eax,	5
	or	al,	cl

	; załaduj numer funkcji do bitów 10..8
	rol	eax,	3
	or	al,	dl

	; numer rejestru w bitach 7..2
	rol	eax,	6

	; wyłącz bity 1..0
	rol	eax,	2

	; poproś o informacje w danym rejestrze
	mov	dx,	0x0CF8
	out	dx,	eax	; wyślij polecenie

	; odbierz odpowiedź
	mov	dx,	0x0CFC
	in	eax,	dx

	; przywróć oryginalne rejestry
	pop	rdx
	pop	rcx
	pop	rbx

	; powrót z procedury
	ret

;============================================================================
; wejście:
;	rax - wartość
;
;	bl - szyna
;	cl - urządzenie
;	dl - funkcja/rejestr
kernel_pci_write:
	; zachowaj oryginalne rejestry
	push	rbx
	push	rcx
	push	rdx
	push	rax

	; załaduj ustaw bit 31 oraz wyłącz bity 30..24
	rol	eax,	8
	or	eax,	10000000b

	; załaduj numer szyny do bitów 23..16
	rol	eax,	8
	or	al,	bl

	; załaduj numer urządzenia do bitów 15..11
	rol	eax,	5
	or	al,	cl

	; załaduj numer funkcji do bitów 10..8
	rol	eax,	3
	or	al,	dl

	; numer rejestru w bitach 7..2
	rol	eax,	6

	; wyłącz bity 1..0
	rol	eax,	2

	; poproś o dane z rejestru
	mov	dx,	0x0CF8
	out	dx,	eax

	; przywróć wartość do wysłania
	pop	rax

	; wyślij
	mov	dx,	0x0CFC
	out	dx,	eax

	; przywróć oryginalne rejestry
	pop	rdx
	pop	rcx
	pop	rbx

	; powrót z procedury
	ret
