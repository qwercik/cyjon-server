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
