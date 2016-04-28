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

; pozycja kursora na ekranie i w przestrzeni pamięci ekranu
variable_screen_cursor_indicator	dq	VARIABLE_SCREEN_TEXT_MODE_BASE_ADDRESS

; 64 Bitowy kod programu
[BITS 64]

;===============================================================================
; na podstawie współrzędnych wirtualnego kursora oblicza adres w przestrzeni pamięci ekranu
; IN:
;	rbx - pozycja kursora
;
; OUT:
;	brak
;
; wszystkie rejestry zachowane
cyjon_screen_cursor_indicator:
	; zachowaj oryginalne rejestry
	push	rax
	push	rcx
	push	rdx
	push	rbx

	; oblicz przesunięcie do określonej linii Y
	mov	rax,	VARIABLE_SCREEN_TEXT_MODE_WIDTH * VARIABLE_SCREEN_TEXT_MODE_CHAR_SIZE
	xor	rdx,	rdx
	mul	dword [rsp + VARIABLE_QWORD_HIGH]

	; ustaw wskaźnik kursora na poczatek ekranu
	mov	rdi,	VARIABLE_SCREEN_TEXT_MODE_BASE_ADDRESS
	add	rdi,	rax	; przesuń wskaźnik na obliczoną linię

	; oblicz przesunięcie do określonej kolumny X
	mov	eax,	dword [rsp]
	mov	rcx,	VARIABLE_SCREEN_TEXT_MODE_WIDTH * VARIABLE_SCREEN_TEXT_MODE_CHAR_SIZE
	mul	rcx

	; zapisz wskaźnik adresu w przestrzeni pamięci ekranu odpowiadający położeniu kursora
	add	rdi,	rax
	mov	qword [variable_screen_cursor_indicator],	rdi

	; przywróć oryginalne rejestry
	pop	rbx
	pop	rdx
	pop	rcx
	pop	rax

	; powrót z procedury
	ret

;=======================================================================
; czyści ekran na domyślny kolor tła
; IN:
;	brak
;
; OUT:
;	brak
;
; wszystkie rejestry zachowane
cyjon_screen_clear:
	; zachowaj oryginalne rejestry
	push	rax
	push	rcx
	push	rdi

	; ustaw domyślną kolorystykę i znak czyszczenia "spacja"
	mov	al,	VARIABLE_ASCII_CODE_SPACE
	mov	ah,	VARIABLE_COLOR_DEFAULT + VARIABLE_COLOR_BACKGROUND_DEFAULT

	; rozmiar przestrzeni pamięci do wyczyszczenia
	mov	rcx,	VARIABLE_SCREEN_TEXT_MODE_SIZE

	; początek przestrzeni pamięci ekranu
	mov	rdi,	VARIABLE_SCREEN_TEXT_MODE_BASE_ADDRESS

.loop:
	; wyczyść pierwszy znak
	stosw

	; zmniejsz ilość przestrzeni do przetworzenia
	dec	rcx

	; jeśli pozostały następne
	jnz	.loop	; kontynuuj

	; ustaw kursor na początek ekranu i przestrzeni pamięci ekranu
	mov	qword [variable_screen_cursor_indicator],	VARIABLE_SCREEN_TEXT_MODE_BASE_ADDRESS

	; ustaw kursor na swoją pozycję
	call	cyjon_screen_cursor_move

	; przywróć oryginalne rejestry
	pop	rdi
	pop	rcx
	pop	rax

	; powrót
	ret

;===============================================================================
; ustawia kursor w odpowiednim miejscu ekranu
; IN:
;	brak
;
; OUT:
;	brak
;
; wszystkie rejestry zachowane
cyjon_screen_cursor_move:
	; zachowaj oryginalne rejestry
	push	rax
	push	rcx
	push	rdx

	; oblicz przesunięcie kursora względem początku przestrzeni pamięci ekranu
	mov	rcx,	qword [variable_screen_cursor_indicator]
	sub	rcx,	VARIABLE_SCREEN_TEXT_MODE_BASE_ADDRESS
	shr	rcx,	1	; usuń atrybuty

	; młodszy port kursora (rejestr indeksowy VGA)
	mov	al,	0x0F
	mov	dx,	0x03D4
	out	dx,	al

	inc	dx	; 0x03D5
	mov	al,	cl
	out	dx,	al

	; starszy port kursora
	mov	al,	0x0E
	dec	dx
	out	dx,	al

	inc	dx
	mov	al,	ch
	out	dx,	al

	; przywróć oryginalne rejestry
	pop	rdx
	pop	rcx
	pop	rax

	; powrót z procedury
	ret

;=======================================================================
; wyświetla znak pod adresem wskaźnika w przestrzeni pamięci ekranu
; IN:
;	al - kod ASCII znaku do wyświetlenia
;	bl - kolor znaku
;	dl - kolor tła znaku
;	rdi - wskaźnik przestrzeni pamięci ekranu dla pozycji wyświetlanego znaku
;
; OUT:
;	rdi - wskaźnik do następnego znaku w przestrzeni pamięci ekranu
;
; pozostałe rejestry zachowane
cyjon_screen_print_char:
	; zachowaj oryginalne rejestry
	push	rax
	push	rcx

	; ustaw kolor i tło znaku
	mov	ah,	bl
	add	ah,	dl

.loop:
	cmp	al,	VARIABLE_ASCII_CODE_ENTER
	je	.enter

	cmp	al,	VARIABLE_ASCII_CODE_NEWLINE
	je	.new_line

	cmp	al,	VARIABLE_ASCII_CODE_BACKSPACE
	je	.backspace

	; zapisz znak do przestrzeni pamięci ekranu
	stosw

.continue:
	; wyświetlono znak odpowiednią ilość razy?
	dec	rcx
	jnz	.loop

	; przywróć oryginalne rejestry
	pop	rcx
	pop	rax

	; powrót z procedury
	ret

.enter:
	; zachowaj oryginalne rejestry
	push	rcx
	push	rdx

	; zachowaj wskaźnik w przestrzeni pamięci
	push	rdi

	; oblicz przesunięcie względem początku przestrzeni pamięci
	sub	rdi,	VARIABLE_SCREEN_TEXT_MODE_BASE_ADDRESS
	shr	rdi,	1	; usuń atrybuty

	; oblicz rozmiar aktualnej linii
	mov	rax,	rdi
	mov	rcx,	VARIABLE_SCREEN_TEXT_MODE_WIDTH
	xor	rdx,	rdx
	div	rcx

	; przywróć przesunięcie względem poczatku przestrzeni pamięci
	pop	rdi

	; przesuń wskaźnik na początek tej linii
	shl	rdx,	1	; dodaj atrybuty
	sub	rdi,	rdx

	; przywróć oryginalne rejestry
	pop	rdx
	pop	rcx

	; koniec obsługi
	jmp	.continue

.new_line:
	; przesuń wskaźnik kursora w przestrzeni pamięci ekranu o rozmiar linii
	add	rdi,	VARIABLE_SCREEN_TEXT_MODE_WIDTH * VARIABLE_SCREEN_TEXT_MODE_CHAR_SIZE

	; koniec obsługi
	jmp	.continue

.backspace:
	; cofnij wskaźnik o rozmiar 
	sub	rdi,	VARIABLE_SCREEN_TEXT_MODE_CHAR_SIZE

	; zastąp znak w przestrzeni pamięci ekranu czystym
	mov	al,	VARIABLE_ASCII_CODE_SPACE
	mov	word [rdi],	ax

	; koniec obsługi
	jmp	.continue

;=======================================================================
; wyświetla ciąg znaków spod wskaźnika RSI, zakończony terminatorem lub ilością na podstawie rejestru RCX
; IN:
;	ebx - kolor znaku
;	rcx - ilość znaków do wyświetlenia z ciągu
;	edx - kolor tła znaku
;	rsi - wskaźnik przestrzeni pamięci ekranu dla pozycji wyświetlanego znaku
; OUT:
;	brak
;
; wszystkie rejestry zachowane
cyjon_screen_print_string:
	; zachowaj oryginalne rejestry
	push	rax
	push	rcx
	push	rsi
	push	rdi

	; pobierz wskaźnik aktualnego miejsca położenia matrycy znaku do wypisania na ekranie
	mov	rdi,	qword [variable_screen_cursor_indicator]

	; sprawdź czy wskazano ilość znaków do wyświetlenia
	cmp	rcx,	VARIABLE_EMPTY
	je	.end	; jeśli nie, zakończ działanie

.string:
	; pobierz znak z ciągu tekstu
	lodsb	; załaduj do rejestru AL Bajt pod adresem w wskaźniku RSI, zwiększ wskaźnik RSI o jeden

	; sprawdź czy koniec ciągu
	cmp	al,	VARIABLE_ASCII_CODE_TERMINATOR
	je	.end	; jeśli tak, koniec

	; zachowaj licznik
	push	rcx

	; wyświetl znak na ekranie
	mov	rcx,	1
	call	cyjon_screen_print_char

	; przywróć licznik
	pop	rcx

	; zapisz aktualną pozycję kursora w przestrzeni pamięci ekranu
	mov	qword [variable_screen_cursor_indicator],	rdi

	; sprawdź pozycje kursora
	call	cyjon_screen_cursor_position_check

	; wyświetl pozostałe znaki z ciągu
	dec	rcx
	jnz	.string

.end:
	; zapisz aktualny wskaźnik kursora
	mov	qword [variable_screen_cursor_indicator],	rdi

	; ustaw kursor na końcu wyświetlonego tekstu
	call	cyjon_screen_cursor_move

	; przywróć oryginalne rejestry
	pop	rdi
	pop	rsi
	pop	rcx
	pop	rax

	; powrót z procedury
	ret

;=======================================================================
; sprawdź pozycję kursora, czy znajduje się w przestrzeni ekranu
; IN:
;	brak
; OUT:
;	rdi - aktualny wskaźnk kursora w przestrzeni pamięci ekranu
;
; pozostałe rejestry zachowane
cyjon_screen_cursor_position_check:
	; sprawdź czy kursor znajduje się przed przestrzenią pamięci ekranu
	cmp	qword [variable_screen_cursor_indicator],	VARIABLE_SCREEN_TEXT_MODE_BASE_ADDRESS
	jae	.x_ok

	; popraw pozycje kursora, brak obsługi przewijania w tył
	mov	qword [variable_screen_cursor_indicator],	VARIABLE_SCREEN_TEXT_MODE_BASE_ADDRESS

.x_ok:
	; sprawdź czy kursor znajduje się za przestrzenią pamięci ekranu
	cmp	qword [variable_screen_cursor_indicator],	VARIABLE_SCREEN_TEXT_MODE_BASE_ADDRESS + ( VARIABLE_SCREEN_TEXT_MODE_SIZE * VARIABLE_SCREEN_TEXT_MODE_CHAR_SIZE )
	jb	.y_ok

	; kursor wyszedł poza przestrzeń pamięci ekranu, cofnij pozycję o rozmiar jednej linii
	sub	qword [variable_screen_cursor_indicator],	VARIABLE_SCREEN_TEXT_MODE_WIDTH * VARIABLE_SCREEN_TEXT_MODE_CHAR_SIZE

	; przewiń zawartość ekranu o jedną linię w górę
	call	cyjon_screen_scroll

	; zwróć wskaźnik
	mov	rdi,	qword [variable_screen_cursor_indicator]

.y_ok:
	; powrót z procedury
	ret

;=======================================================================
; przewija zawartość ekranu o jedną linię do góry
; IN:
;	brak
; OUT:
;	brak
;
; wszystkie rejestry zachowane
cyjon_screen_scroll:
	; zachowaj oryginalne rejestryl
	push	rax
	push	rbx
	push	rcx
	push	rdx
	push	rsi
	push	rdi

	; adres docelowy przesunięcia zawartości pamięci ekranu na początek
	mov	rdi,	VARIABLE_SCREEN_TEXT_MODE_BASE_ADDRESS

	; oblicz adres źródłowy przsunięcia zawartości ekranu
	mov	rsi,	VARIABLE_SCREEN_TEXT_MODE_BASE_ADDRESS
	add	rsi,	VARIABLE_SCREEN_TEXT_MODE_LINE_SIZE

	; oblicz rozmiar pamięci do przesunięcia
	mov	rcx,	VARIABLE_SCREEN_TEXT_MODE_SIZE - VARIABLE_SCREEN_TEXT_MODE_WIDTH

	; przesuń zawartość pamięci
	rep	movsw

	; wyczyść ostatnią linię
	mov	al,	VARIABLE_ASCII_CODE_SPACE
	mov	ah,	VARIABLE_COLOR_DEFAULT | VARIABLE_COLOR_BACKGROUND_DEFAULT
	mov	rcx,	VARIABLE_SCREEN_TEXT_MODE_WIDTH
	mov	rdi,	VARIABLE_SCREEN_TEXT_MODE_BASE_ADDRESS + VARIABLE_SCREEN_TEXT_MODE_SIZE_IN_BYTES - VARIABLE_SCREEN_TEXT_MODE_LINE_SIZE
	rep	stosw

	; przywróć oryginalne rejestry
	pop	rdi
	pop	rsi
	pop	rdx
	pop	rcx
	pop	rbx
	pop	rax

	; powrót z procedury
	ret

;=======================================================================
; wyświetla liczbę o podanej podstawie
; IN:
;	rax - liczba/cyfra do wyświetlenia
;	bl - kolor liczby
;	cl - podstawa liczbowa
;	ch - uzupełnienie o zera np.
;		ch=4 dla liczby 257 > (0x)0101 lub 0257
;		ch=4 dla liczby 15 > (0x)000F lub 0015
;	dl - kolor tła tło
;	rdi - wskaźnik przestrzeni pamięci ekranu dla pozycji wyświetlanej liczby
; OUT:
;	brak
;
; wszystkie rejestry zachowane
cyjon_screen_print_number:
	; zachowaj oryginalne rejestry
	push	rax
	push	rcx
	push	rdx
	push	rdi
	push	rbp
	push	r8
	push	r9
	push	r10

	; sprawdź czy podstawa liczby dozwolona
	cmp	cl,	2
	jb	.end	; brak obsługi

	; sprawdź czy podstawa liczby dozwolona
	cmp	cl,	36
	ja	.end	; brak obsługi

	; zapamiętaj kolor tła
	mov	r8,	rdx

	; wyczyść starszą część / resztę z dzielenia
	xor	rdx,	rdx

	; zapamiętaj flagi
	mov	r9w,	cx
	shr	r9,	8

	; wyczyść uzupełnienie
	xor	ch,	ch

	; utwórz stos zmiennych lokalnych
	mov	rbp,	rsp

	; zresetuj licznik cyfr
	xor	r10,	r10

	; usuń zbędne wartości
	and	rcx,	0x00000000000000FF

.loop:
	; oblicz resztę z dzielenia
	div	rcx

	; licznik cyfr
	inc	r10

	; zapisz resztę z dzielenia do zmiennych lokalnych
	push	rdx

	; wyczyść resztę z dzielenia
	xor	rdx,	rdx

	; sprawdź czy przeliczać dalej
	cmp	rax,	VARIABLE_EMPTY
	ja	.loop	; jeśli tak, powtórz działanie

	; przywróć kolor tła liczby
	mov	rdx,	r8

	; załaduj wskaźnik pozycji kursora
	mov	rdi,	qword [variable_screen_cursor_indicator]

	; wyświetlaj po jednej kopii cyfry
	mov	rcx,	1

	; sprawdź zasadność flagi
	cmp	r10,	r9
	jae	.print	; brak uzupełnienia

	; oblicz różnicę
	sub	r9,	r10

.zero_before:
	push	VARIABLE_EMPTY	; zero digit

	dec	r9
	jnz	.zero_before

.print:
	; pobierz z zmiennych lokalnych cyfrę
	pop	rax

	; przemianuj cyfrę na kod ASCII
	add	rax,	0x30

	; sprawdź czy system liczbowy powyżej podstawy 10
	cmp	al,	0x3A
	jb	.no	; jeśli nie, kontynuuj

	; koryguj kod ASCII do odpowiedniej podstawy liczbowej
	add	al,	0x07

.no:
	; wyświetl cyfrę
	call	cyjon_screen_print_char

	; sprawdź pozycje kursora
	call	cyjon_screen_cursor_position_check

	; sprawdź czy pozostały cyfry do wyświetlenia z liczby
	cmp	rsp,	rbp
	jne	.print	; jeśli tak, wyświetl pozostałe

	; zapisz nowy wskaźnik kursora
	mov	qword [variable_screen_cursor_indicator],	rdi

	; ustaw kursor na końcu wyświetlonego tekstu
	call	cyjon_screen_cursor_move

.end:
	; przywróć oryginalne rejestry
	pop	r10
	pop	r9
	pop	r8
	pop	rbp
	pop	rdi
	pop	rdx
	pop	rcx
	pop	rax

	; powrót z procedury
	ret

;=======================================================================
; wyświetla ostatni komunikat jądra
; IN:
;	rsi - wskaźnik do ciągu tekstu
;
; OUT:
;	brak
;
; wszystkie rejestry zniszczone
cyjon_screen_kernel_panic:
	; wyświetl informację o błędzie wewnętrznym jądra systemu
	mov	bl,	VARIABLE_COLOR_LIGHT_RED
	mov	rcx,	VARIABLE_FULL
	mov	dl,	VARIABLE_COLOR_BACKGROUND_DEFAULT
	call	cyjon_screen_print_string

	; zatrzymaj wykonywanie jakichkolwiek instrukcji procesora
	cli
	jmp	$
