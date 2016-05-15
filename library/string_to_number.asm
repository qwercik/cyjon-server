; Copyright (C) 2013-2016 Wataha.net
; All Rights Reserved
;
; LICENSE Creative Commons BY-NC-ND 4.0
; See LICENSE.TXT
;
; Main developer:
;	Andrzej (akasei) Adamczyk [e-mail: akasei from wataha.net]
;-------------------------------------------------------------------------------

; Use:
; nasm - http://www.nasm.us/

; 64 bitowy kod programu
[BITS 64]

;===============================================================================
; 
; IN:
;	rcx - rozmiar liczby w znakach
;	rsi - wskaźnik do ciągu cyfr
; OUT:
;	rax - liczba w postaci heksadecymalnej
;
;
; pozostałe rejestry zachowane
library_string_to_number:
	; zachowaj oryginalne rejestry
	push	rax

.find:
	; wszystko co nie jest cyfrą
	cmp	byte [rsi],	VARIABLE_LIBRARY_FFN_NUMBER_LOW
	jb	.leave
	cmp	byte [rsi],	VARIABLE_LIBRARY_FFN_NUMBER_HIGH
	ja	.leave

	; znaleziono piwerszy znak należący do słowa
	jmp	.number

.leave:
	; przesuń wskaźnik bufora na następny znak
	inc	rsi

	; kontynuuj
	loop	.find

.number:
	; sprawdź czy w bufor coś zawiera
	cmp	rcx,	0
	je	.not_found	; jeśli pusty

	; wylicz ilość znaków na liczbę

	; zachowaj adres początku
	push	rsi

	; wyczyść licznik
	xor	rax,	rax

.count:
	; sprawdź czy koniec słowa
	cmp	byte [rdi],	VARIABLE_LIBRARY_FFN_NUMBER_LOW
	jb	.ready
	cmp	byte [rdi],	VARIABLE_LIBRARY_FFN_NUMBER_HIGH
	ja	.ready

	; przesuń wskaźnik na następny znak w buforze polecenia
	inc	rsi

	; zwiększ licznik znaków przypadających na znalezione polecenie
	inc	rax

	; zliczaj dalej
	loop	.count

.ready:
	; ustaw rozmiar słowa w znakach
	mov	rcx,	rax

	; przywróć adres początku słowa
	pop	rdi

	; ustaw flagę
	stc

	; koniec
	jmp	.end

.not_found:
	; nie znaleziono słowa w ciągu znaków
	clc

.end:
	; przywróć oryginalne rejestry
	pop	rax

	; powrót z procedury
	ret
