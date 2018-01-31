;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

struc	STRUCTURE_MEMORY_MAP_ROW
	.limit		resb	8
	.address	resb	8
	.type		resb	4
	.acpi		resb	4
	.SIZE:
endstruc

memory_map:
	; szukaj przestrzeni pamięci fizycznej RAM
	; w wierszu zawierającym początek przestrzeni od adresu 0x00100000

	; pobierz adres opisanej przestrzeni
	mov	rax,	qword [ebx + STRUCTURE_MEMORY_MAP_ROW.limit]

	; znaleziono?
	cmp	rax,	KERNEL_BASE_address
	je	.found	; tak

	; ustaw adres na następny wiersz tablicy
	add	ebx,	STRUCTURE_MEMORY_MAP_ROW.SIZE

	; koniec tablicy?
	cmp	qword [ebx + STRUCTURE_MEMORY_MAP_ROW.limit],	EMPTY
	jnz	memory_map	; nie, szukaj dalej

	; przygotuj komunikat
	mov	ecx,	text_error_memory_map_end - text_error_memory_map
	mov	esi,	text_error_memory_map
	jmp	kernel_panic	; wyświetl komunikat

.found:
	; zamień rozmiar na ilość dostępnych stron
	shr	rax,	DIVIDE_BY_PAGE_shift

	; resztę z dzielenia porzucamy (niepełna strona jest bezużyteczna)

	; zachowaj informację o ilości dostępnych stron
	mov	qword [kernel_page_total_count],	rax
	mov	qword [kernel_page_free_count],	rax

	; binarną mapę pamięci uzupełniamy "zestawami" stron po 64 bity, każdy
	; dla przejrzystości kodu

	; zamień
	mov	ecx,	64
	xor	edx,	edx	; wyczyść starszą część
	div	rcx

	; binarną mapę pamięci tworzymy zaraz za kodem jądra systemu
	mov	rdi,	kernel_end
	mov	qword [kernel_memory_map_address_start],	rdi	; zachowaj adres początku binarnej mapy pamięci

	; wypełnij binarną mapę pamięci "zestawami" po 64 bity, każdy
	mov	rcx,	MAX_UNSIGNED
	xchg	rcx,	rax
	rep	stosq

	; pozostałe strony, które nie utworzą całego "zestawu", musimy zarejestrować ręcznie

	; pozostały bity spoza zestawu?
	cmp	rdx,	EMPTY
	je	.prepared	; nie

	; rozpocznij od bitu nr 0 w aktualnym "zestawie"
	xor	eax,	eax

	; wyłącz wszystkie bity w aktualnym "zestawie"
	stosq

.fill:
	; włącz bit odpowiedzialny za wolną stronę
	bts	qword [rdi - QWORD_SIZE_byte],	rax

	; następny bit
	inc	rax

	; pozostały wolne strony?
	dec	dx
	jnz	.fill	; tak, uzupełnij

.prepared:
	; zachowaj adres końca binarnej mapy pamięci
	mov	qword [kernel_memory_map_address_end],	rdi

	; oznacz strony jako wykorzystane, w których znajduje się kod jądra systemu i binarna mapa pamięci

	; wylicz rozmiar wykorzystanej przestrzeni
	call	liblary_page_align_up
	sub	rdi,	KERNEL_BASE_address

	; jako, że pobierając dostępną stronę z binarnej mapy pamięci, zawsze otrzymujemy pierwszą wolną
	; możemy uprościć sposób oznaczenia pierwszych N zajętych
	mov	rcx,	rdi
	shr	rcx,	DIVIDE_BY_PAGE_shift

.remove:
	; oznacz pierwszą/N-tą stronę jako zajętą
	call	kernel_page_request

	; pozostały strony do oznaczenia?
	dec	rcx
	jnz	.remove	; tak
