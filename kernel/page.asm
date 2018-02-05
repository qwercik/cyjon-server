;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

;===============================================================================
; opcjonalnie:
;	rbp - ilość stron zabezpieczonych
;		procedura będzie z nich korzystać, zarazem licznik zmniejszać
; wyjście:
;	Flaga CF - jeśli brak wolnych stron
;	rdi - wskaźnik do wolnej strony
kernel_page_request:
	; zachowaj oryginalne rejestry
	push	rax
	push	rcx
	push	rsi

	; uzyskaj wyłączny dostęp do binarnej mapy pamięci
	call	kernel_page_lock

	; czy skorzystać z stron zarezerwowanych dla nas?
	test	rbp,	rbp
	jz	.no	; nie

	; istnieją strony zabezpieczone, zmniejsz ich ilość o jedną
	dec	qword [kernel_page_reserved_count]
	dec	rbp

	; kontynuuj
	jmp	.prepared

.no:
	; czy istnieją wolne/dostępne strony do wykorzystania?
	cmp	qword [kernel_page_free_count],	EMPTY
	je	.error	; nie

	; ilość wolnych/dostępnych stron zmniejszyła się
	dec	qword [kernel_page_free_count]

.prepared:
	; ustaw wskaźniki na początek i koniec binarnej mapy pamięci
	mov	rsi,	qword [kernel_memory_map_address_start]
	mov	rdi,	qword [kernel_memory_map_address_end]

	; zwróć numer bezwzględny bitu opisującego wolną/dostępną stronę
	call	liblary_bit_find

	; zamień bezwzględny numer bitu na względny adres strony
	shl	rax,	KERNEL_PAGE_SIZE_shift

	; w binarnej mapie pamięci opisaliśmy przestrzeń zaczynającą się od adresu fizycznego KERNEL_BASE_address
	; zamień adres względny na bezwzględny
	add	rax,	KERNEL_BASE_address

	; zwróć adres strony
	mov	rdi,	rax

	; flaga, sukces
	clc

	; koniec
	jmp	.end

.error:
	; flaga, błąd
	stc

.end:
	; odblokuj dostęp do pamięci
	mov	byte [kernel_page_lock_semaphore],	FALSE

	; przywróć oryginalne rejestry i flagi
	pop	rsi
	pop	rcx
	pop	rax

	; powrót z procedury
	ret

;===============================================================================
kernel_page_lock:
	; dostęp do stron zablokowany?
	cmp	byte [kernel_page_lock_semaphore],	TRUE
	je	kernel_page_lock	; czekaj

	; zablokuj dostęp do stron
	mov	byte [kernel_page_lock_semaphore],	TRUE

	; powrót z procedury
	ret

;===============================================================================
; wejście:
;	rdi - adres strony do wyczyszczenia
kernel_page_dump:
	; zachowaj oryginalne rejestry
	push	rax
	push	rcx
	push	rdi

	; wyczyść stronę
	xor	rax,	rax
	mov	rcx,	KERNEL_PAGE_SIZE_byte / QWORD_SIZE_byte
	and	rdi,	KERNEL_PAGE_mask	; wyrównaj adres strony w dół
	rep	stosq

	; przywróć oryginalne rejestry
	pop	rdi
	pop	rcx
	pop	rax

	; powrót z procedury
	ret

;===============================================================================
; wejście:
;	rax - adres przestrzeni fizycznej do opisania w tablicach stronicowania
;	rbx - flagi rekordów tablic stronicowania
;	rcx - rozmiar przestrzeni w stronach do opisania
;	r11 - adres fizyczny tablicy PML4, w której wykonać wpis
; wyjście:
;	Flaga CF - ustawiona, jeśli wystąpił błąd
;	r8 - adres wiersza opisującego pierwszą stronę przestrzeni
; uwagi:
;	zastrzeż odpowiednią ilość stron, rbp
kernel_page_map_physical:
	; zachowaj oryginalne rejestry
	push	rcx
	push	rdx
	push	rdi
	push	r9
	push	r10
	push	r11
	push	r12
	push	r13
	push	r14
	push	r15
	push	rax

	; przygotuj podstawową ścieżkę z tablic do mapowanego adresu
	call	kernel_page_prepare
	jc	.error	; błąd, brak wolnej pamięci lub przepełniono tablicę stronicowania

	; dołącz do początku opisywanej przestrzeni, właściwości
	add	rax,	rbx

.row:
	; sprawdź czy skończyły się rekordy w tablicy PML1
	cmp	r12,	KERNEL_PAGE_ROW_count
	jb	.exist	; nie

	; utwórz nową tablicę stronicowania PML1
	call	kernel_page_pml1

.exist:
	; zapisz adres mapowany do wiersza PML1[r12]
	stosq

	; przesuń adres do następnego mapowanej przestrzeni
	add	rax,	KERNEL_PAGE_SIZE_byte

	; ustaw numer następnego wiersza w tablicy PML1
	inc	r12

	; następny wiersz tablicy?
	dec	rcx
	jnz	.row	; tak

	; flaga, sukces
	clc

	; koniec
	jmp	.end

.error:
	; flaga, błąd
	stc

.end:
	; przywróć oryginalne rejestry
	pop	rax
	pop	r15
	pop	r14
	pop	r13
	pop	r12
	pop	r11
	pop	r10
	pop	r9
	pop	rdi
	pop	rdx
	pop	rcx

	; powrót z procedury
	ret

;===============================================================================
; wejście:
;	rax - adres przestrzeni fizycznej do opisania w tablicach stronicowania
;	rbx - flagi rekordów tablic stronicowania
;	r11 - adres fizyczny tablicy PML4, w której wykonać stronicowanie
; wyjście:
;	rdi - wskaźnik do rekordu w tablicy PML1, początku opisywanego obszaru fizycznego
;
;	r8 - wskaźnik następnego rekordu w tablicy PML1
;	r9 - wskaźnik następnego rekordu w tablicy PML2
;	r10 - wskaźnik następnego rekordu w tablicy PML3
;	r11 - wskaźnik następnego rekordu w tablicy PML4
;	r12 - numer następnego rekordu w tablicy PML1
;	r13 - numer następnego rekordu w tablicy PML2
;	r14 - numer następnego rekordu w tablicy PML3
;	r15 - numer następnego rekordu w tablicy PML4
kernel_page_prepare:
	; zachowaj oryginalne rejestry
	push	rax
	push	rcx
	push	rdx

	; oblicz numer rekordu w tablicy PML4 na podstawie otrzymanego adresu fizycznego/logicznego
	mov	rcx,	KERNEL_PAGE_PML3_SIZE_byte
	xor	rdx,	rdx	; wyczyść starszą część
	div	rcx

	; zapamiętaj numer rekordu tablicy PML4
	mov	r15,	rax

	; przesuń wskaźnik w tablicy PML4 na rekord
	shl	rax,	MULTIPLE_BY_8_shift	; zamień na Bajty
	add	r11,	rax

	; rekord PML4 zawiera adres tablicy PML3?
	cmp	qword [r11],	EMPTY
	je	.no_pml3

	; pobierz adres tablicy PML3 z rekordu tablicy PML4
	mov	rax,	qword [r11]
	xor	al,	al	; usuń właściwości rekordu

	; zapisz adres tablicy PML3
	mov	r10,	rax

	; kontynuuj
	jmp	.pml3

.no_pml3:
	; pobierz zarezerwowaną stronę na potrzebę utworzenia nowej tablicy
	call	kernel_page_request
	call	kernel_page_dump	; wyczyść

	; zapisz adres tablicy PML3
	mov	r10,	rdi

	; zapisz adres tablicy PML3 do rekordu tablicy PML4
	mov	qword [r11],	rdi
	or	word [r11],	bx	; ustaw właściwości rekordu tablicy PML4

.pml3:
	; ustaw numer i wskaźnik rekordu w tablicy PML4 na następny
	inc	r15
	add	r11,	QWORD_SIZE_byte

	; oblicz numer rekordu w tablicy PML4 na podstawie otrzymanego adresu fizycznego/logicznego
	mov	rax,	rdx	; przywróć resztę z dzielenia
	mov	rcx,	KERNEL_PAGE_PML2_SIZE_byte
	xor	rdx,	rdx	; wyczyść starszą część
	div	rcx

	; zapamiętaj numer rekordu
	mov	r14,	rax

	; przesuń wskaźnik w tablicy PML3 na rekord
	shl	rax,	MULTIPLE_BY_8_shift	; zamień na Bajty
	add	r10,	rax

	; rekord PML3 zawiera adres tablicy PML2?
	cmp	qword [r10],	EMPTY
	je	.no_pml2

	; pobierz adres tablicy PML2 z rekordu tablicy PML3
	mov	rax,	qword [r10]
	xor	al,	al	; usuń właściwości rekordu

	; zapisz adres tablicy PML2
	mov	r9,	rax

	; kontynuuj
	jmp	.pml2

.no_pml2:
	; pobierz zarezerwowaną stronę na potrzebę utworzenia nowej tablicy
	call	kernel_page_request
	call	kernel_page_dump	; wyczyść

	; zapisz adres tablicy PML2
	mov	r9,	rdi

	; zapisz adres tablicy PML2 do rekordu tablicy PML3
	mov	qword [r10],	rdi
	or	word [r10],	bx	; ustaw właściwości rekordu tablicy PML3

.pml2:
	; ustaw numer i wskaźnik rekordu w tablicy PML3 na następny
	inc	r14
	add	r10,	QWORD_SIZE_byte

	; oblicz numer rekordu w tablicy PML2 na podstawie otrzymanego adresu fizycznego/logicznego
	mov	rax,	rdx	; przywróć resztę z dzielenia
	mov	rcx,	KERNEL_PAGE_PML1_SIZE_byte
	xor	rdx,	rdx	; wyczyść starszą część
	div	rcx

	; zapamiętaj numer rekordu
	mov	r13,	rax

	; przesuń wskaźnik w tablicy PML2 na rekord
	shl	rax,	MULTIPLE_BY_8_shift	; zamień na Bajty
	add	r9,	rax

	; rekord PML2 zawiera adres tablicy PML1?
	cmp	qword [r9],	EMPTY
	je	.no_pml1

	; pobierz adres tablicy PML1 z rekordu tablicy PML2
	mov	rax,	qword [r9]
	xor	al,	al	; usuń właściwości rekordu

	; zapisz adres tablicy PML1
	mov	r8,	rax

	; kontynuuj
	jmp	.pml1

.no_pml1:
	; pobierz zarezerwowaną stronę na potrzebę utworzenia nowej tablicy
	call	kernel_page_request
	call	kernel_page_dump	; wyczyść

	; zapisz adres tablicy PML1
	mov	r8,	rdi

	; zapisz adres tablicy PML1 do rekordu tablicy PML2
	mov	qword [r9],	rdi
	or	word [r9],	bx	; ustaw właściwości rekordu tablicy PML2

.pml1:
	; ustaw numer i wskaźnik rekordu w tablicy PML3 na następny
	inc	r13
	add	r9,	QWORD_SIZE_byte

	; oblicz numer rekordu w tablicy PML1 na podstawie otrzymanego adresu fizycznego/logicznego
	mov	rax,	rdx	; przywróć resztę z dzielenia
	mov	rcx,	KERNEL_PAGE_SIZE_byte
	xor	rdx,	rdx	; wyczyść starszą część
	div	rcx

	; zapamiętaj numer rekordu
	mov	r12,	rax

	; przesuń wskaźnik w tablicy PML2 na rekord
	shl	rax,	MULTIPLE_BY_8_shift	; zamień na Bajty
	add	r8,	rax

	; zwróć wskaźnik do rekordu tablicy PML1
	mov	rdi,	r8

	; przywróć oryginalne rejestry
	pop	rdx
	pop	rcx
	pop	rax

	; powrót z procedury
	ret

;===============================================================================
; opcjonalnie:
;	rbp - ilość stron zarezerwowanych (jeśli procedura ma z nich korzystać)
; wejście:
;	r8 - wskaźnik aktualnego wiersza w tablicy PML1
;	r9 - wskaźnik aktualnego wiersza w tablicy PML2
;	r10 - wskaźnik aktualnego wiersza w tablicy PML3
;	r11 - wskaźnik aktualnego wiersza w tablicy PML4
;	r12 - numer aktualnego wiersza w tablicy PML1
;	r13 - numer aktualnego wiersza w tablicy PML2
;	r14 - numer aktualnego wiersza w tablicy PML3
;	r15 - numer aktualnego wiersza w tablicy PML4
; wyjście:
;	Flaga CF, jeśli błąd
;	rdi - wskaźnik do wiersza w tablicy PML1, początku opisywanego obszaru fizycznego
;
;	r8 - wskaźnik następnego wiersza w tablicy PML1
;	r9 - wskaźnik następnego wiersza w tablicy PML2
;	r10 - wskaźnik następnego wiersza w tablicy PML3
;	r11 - wskaźnik następnego wiersza w tablicy PML4
;	r12 - numer następnego wiersza w tablicy PML1
;	r13 - numer następnego wiersza w tablicy PML2
;	r14 - numer następnego wiersza w tablicy PML3
;	r15 - numer następnego wiersza w tablicy PML4
; uwagi:
;	procedura zmniejsza licznik stron zarezerwowanych w binarnej mapie pamięci!
kernel_page_pml1:
	; sprawdź czy tablica PML2 jest pełna
	cmp	r13,	KERNEL_PAGE_ROW_count
	je	.pml3	; jeśli tak, utwórz nową tablicę PML2

	; sprawdź czy kolejny w kolejce rekord tablicy PML2 posiada adres tablicy PML1
	cmp	qword [r9],	EMPTY
	je	.pml2_create	; nie

	; pobierz adres tablicy PML1 z rekordu tablicy PML2
	mov	rdi,	qword [r9]

	; koniec
	jmp	.pml2_continue

.pml2_create:
	; przygotuj miejsce na tablicę PML1
	call	kernel_page_request
	call	kernel_page_dump	; wyczyść tablicę

	; ustaw właściwości rekordu w tablicy PML2
	or	di,	bx

	; podepnij tablice PML1 pod rekord tablicy PML2[r13]
	mov	qword [r9],	rdi

.pml2_continue:
	; usuń właściwości rekordu tablicy PML2
	and	rdi,	KERNEL_PAGE_mask

	; zwróć adres pierwszego rekordu w tablicy PML1
	mov	r8,	rdi

	; zresetuj numer przetwarzanego rekordu w tablicy PML1
	xor	r12,	r12

	; ustaw adres następnego rekordu w tablicy PML2
	add	r9,	 QWORD_SIZE_byte
	inc	r13	; ustaw numer następnego rekordu w tablicy PML2

	; powrót z procedury
	ret

.pml3:
	; sprawdź czy tablica PML3 jest pełna
	cmp	r14,	KERNEL_PAGE_ROW_count
	je	.pml4	; jeśli tak, utwórz nową tablicę PML3

	; sprawdź czy kolejny w kolejce rekord tablicy PML3 posiada adres tablicy PML2
	cmp	qword [r10],	EMPTY
	je	.pml3_create	; nie

	; pobierz adres tablicy PML2 z rekordu tablicy PML3
	mov	rdi,	qword [r10]

	; koniec
	jmp	.pml3_continue

.pml3_create:
	; przygotuj miejsce na tablicę PML2
	call	kernel_page_request
	call	kernel_page_dump	; wyczyść tablicę

	; ustaw właściwości rekordu w tablicy PML3
	or	di,	bx

	; podepnij tablice PML2 pod rekord tablicy PML3[r14]
	mov	qword [r10],	rdi

.pml3_continue:
	; usuń właściwości rekordu tablicy PML3
	and	rdi,	KERNEL_PAGE_mask

	; zwróć adres pierwszego rekordu w tablicy PML2
	mov	r9,	rdi

	; zresetuj numer przetwarzanego rekordu w tablicy PML2
	xor	r13,	r13

	; ustaw adres następnego rekordu w tablicy PML3
	add	r10,	 QWORD_SIZE_byte
	inc	r14	; ustaw numer następnego rekordu w tablicy PML3

	; powrót do procedury głównej
	jmp	kernel_page_pml1

.pml4:
	; sprawdź czy tablica PML4 jest pełna
	cmp	r15,	KERNEL_PAGE_ROW_count
	je	.error	; jeśli tak, utwórz nową tablicę PML5..., że jak?!

	; sprawdź czy kolejny w kolejce rekord tablicy PML4 posiada adres tablicy PML3
	cmp	qword [r11],	EMPTY
	je	.pml4_create	; nie

	; pobierz adres tablicy PML3 z rekordu tablicy PML4
	mov	rdi,	qword [r11]

	; koniec
	jmp	.pml4_continue

.pml4_create:
	; przygotuj miejsce na tablicę PML3
	call	kernel_page_request
	call	kernel_page_dump	; wyczyść tablicę

	; ustaw właściwości rekordu w tablicy PML4
	or	di,	bx

	; podepnij tablice PML3 pod rekord tablicy PML4[r15]
	mov	qword [r11],	rdi

.pml4_continue:
	; usuń właściwości rekordu tablicy PML4
	and	rdi,	KERNEL_PAGE_mask

	; zwróć adres pierwszego rekordu w tablicy PML3
	mov	r10,	rdi

	; zresetuj numer przetwarzanego rekordu w tablicy PML3
	xor	r14,	r14

	; ustaw adres następnego rekordu w tablicy PML4
	add	r11,	 QWORD_SIZE_byte
	inc	r15	; ustaw numer następnego rekordu w tablicy PML4

	; powrót do podprocedury
	jmp	.pml3

.error:
	; flaga, błąd
	stc

	; powrót z procedury
	ret

;===============================================================================
; wejście:
;	rax - adres przestrzeni logicznej do opisania w tablicach stronicowania
;	rbx - flagi rekordów tablic stronicowania
;	rcx - rozmiar przestrzeni w stronach do opisania
;	r11 - adres fizyczny tablicy PML4, w której wykonać wpis
; wyjście:
;	Flaga CF - jeśli ustawiona, błąd
;	r8 - adres rekordu opisującego pierwszą stronę przestrzeni
; uwagi:
;	zastrzeż odpowiednią ilość stron, rbp
kernel_page_map_logical:
	; zachowaj oryginalne rejestry
	push	rax
	push	rcx
	push	rdx
	push	rdi
	push	r9
	push	r10
	push	r11
	push	r12
	push	r13
	push	r14
	push	r15

	; przygotuj podstawową ścieżkę z tablic do mapowanego adresu
	call	kernel_page_prepare

.record:
	; sprawdź czy skończyły się rekordy w tablicy PML1
	cmp	r12,	KERNEL_PAGE_ROW_count
	jb	.exists	; istnieją rekordy

	; utwórz nową tablicę stronicowania PML1
	call	kernel_page_pml1

.exists:
	; rekord zajęty?
	cmp	qword [rdi],	EMPTY
	je	.no

	; przesuń wskaźnik na następny rekord
	add	rdi,	QWORD_SIZE_byte
	jmp	.continue

.no:
	; zachowaj adres rekordu tablicy PML1
	push	rdi

	; pobierz i wyczyść wolną stronę
	call	kernel_page_request
	call	kernel_page_dump

	; ustaw właściwości rekordu
	add	di,	bx

	; przywróć adres rekordu tablicy PML1
	pop	rax

	; zapisz adres przestrzeni mapowanej do rekordu tablicy PML1[r12]
	xchg	rdi,	rax
	stosq

.continue:
	; ustaw numer następnego rekordu w tablicy pml1
	inc	r12

	; kontynuuj
	dec	rcx
	jnz	.record

.end:
	; przywróć oryginalne rejestry
	pop	r15
	pop	r14
	pop	r13
	pop	r12
	pop	r11
	pop	r10
	pop	r9
	pop	rdi
	pop	rdx
	pop	rcx
	pop	rax

	; powrót z procedury
	ret

.error:
	; flaga, błąd
	stc

	; koniec
	jmp	.end
