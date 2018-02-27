;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

a20:
	;-----------------------------------------------------------------------
	; linia a20 jest odblokowana?
	call	.check
	jnc	.ready	; tak

	; spróbuj odblokować za pomocą funkcji BIOSu
	; http://www.ctyme.com/intr/rb-1336.htm
	mov	ax,	0x2401
	int	0x15

	;-----------------------------------------------------------------------
	; odblokowano?
	jnc	.ready	; tak

	; spróbuj odblokować za pomocą kontrolera klawiatury

	; wyłącz przerwania
	cli

	; poczekaj, aż klawiatura będzie gotowa przyjąć polecenie
	call    .keyboard_in

	; wyłącz klawiaturę
	mov	al,	0xAD
	out	0x64,	al

	; poczekaj, aż klawiatura będzie gotowa przyjąć polecenie
	call    .keyboard_in

	; poproś o możliwość odczytania danych z portu klawiatury
	mov     al,	0xD0
	out     0x64,	al

	; poczekaj, aż klawiatura będzie gotowa na odpowiedź
	call    .keyboard_out

	; pobierz z portu klawiatury dane
	in      al,	0x60

	; zapamiętaj
	push    ax

	; poczekaj, aż klawiatura będzie gotowa przyjąć polecenie
	call    .keyboard_in

	; poproś o możliwość zapisania danych do portu klawiatury
	mov     al,	0xD1
	out     0x64,	al

	; poczekaj, aż klawiatura będzie gotowa przyjąć polecenie
	call    .keyboard_in

	; przywróć odebrane dane
	pop     ax

	; ustaw trzeci bit rejestru AL
	or      al,	2
	out     0x60,	al

	; poczekaj, aż klawiatura będzie gotowa przyjąć polecenie
	call	.keyboard_in

	; włącz klawiaturę
	mov     al,	0xAE
	out     0x64,	al

	; poczekaj, aż klawiatura będzie gotowa przyjąć polecenie
	call    .keyboard_in

	; włącz przerwania
	sti

	;-----------------------------------------------------------------------
	; odblokowano linię a20?
	call	.check
	jnc	.ready	; tak

	; spróbuj odblokować linię a20 za pomocą FastGate

	; pobierz status z rejestru System Control Port A
	in	al,	0x92

	; sprawdź czy drugi bit jest równy zero
	test	al,	2
	jnz	.error	; nie

	; włącz 2 bit
	or	al,	2
	and	al,	0xFE
	out	0x92,	al

.error:
	; odblokowano linię a20?
	call	.check
	jnc	.ready	; tak

	; linia a20 zablokowana :(

	; przygotuj komuniakt błędu
	mov	esi,	zero_error_a20_text
	jmp	error	; wyświetl

.check:
	; zapamiętaj adres segmentu danych
	push	ds

	; ustaw semgent danych na koniec pamięci fizycznej (ograniczonej do 1 MiB)
	mov	ax,	0xFFFF
	mov	ds,	ax

	; pobierz słowo spod adresu sygnatury sektora rozruchowego
	; 0xFFFF0 + 0x7E0E = 0x107DFE - 0x100000 = 0x7DFE (pozycja sygnatury sektora rozruchowego)
	mov	ax,	word [ds:0x7E0E]

	; przywróć adres segmentu danych
	pop	ds

	; czy wartość nieoczekiwana?
	cmp	ax,	0xAA55
	jne	.check_ok	; tak

	; flaga, błąd
	stc

	; powrót z procedury
	ret

.check_ok:
	; flaga, sukces
	clc

	; powrót z procedury
	ret

.keyboard_in:
	; pobierz informacje o stanie kontrolera klawiatury
	in	al,	0x64

	; bufor wejściowy pełny?
	test	al,	2
	jnz	.keyboard_in	; tak, czekaj

	; powrót z procedury
	ret

.keyboard_out:
	; pobierz informacje o stanie kontrolera klawiatury
	in	al,	0x64

	; bufor wyjściowy pełny?
	test	al,	1
	jnz	.keyboard_out	; tak, czekaj

	; powrót z procedury
	ret

.ready:
	; linia a20 odblokowana
