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

; 64 Bitowy kod programu
[BITS 64]

;===============================================================================
; procedura/podprocedury obsługujące przerwanie programowe procesów
; IN:
;	różne
; OUT:
;	różne
;
; różne rejestry zachowane
irq64:
	; obsługa procesów?
	cmp	ah,	VARIABLE_KERNEL_SERVICE_PROCESS
	je	.process

	; obsługa ekranu?
	cmp	ah,	VARIABLE_KERNEL_SERVICE_SCREEN
	je	.screen

	; obsługa klawiatury?
	cmp	ah,	VARIABLE_KERNEL_SERVICE_KEYBOARD
	je	.keyboard



	; obsługa sieci?
	cmp	ah,	VARIABLE_KERNEL_SERVICE_NETWORK
	je	.network

	; koniec obsługi przerwania programowego
	iretq

.process:
	; proces zakończył działanie?
	cmp	al,	VARIABLE_KERNEL_SERVICE_PROCESS_END
	je	irq64_process_end

	; uruchomić nowy proces?
	cmp	al,	VARIABLE_KERNEL_SERVICE_PROCESS_NEW
	je	irq64_process_new

	; sprawdzić czy proces jest uruchomiony?
	cmp	al,	VARIABLE_KERNEL_SERVICE_PROCESS_CHECK
	je	irq64_process_check



	; pobrać listę procesów?
	cmp	al,	VARIABLE_KERNEL_SERVICE_PROCESS_LIST
	je	irq64_process_list

	; pobrać przesłane argumenty?
	cmp	al,	VARIABLE_KERNEL_SERVICE_PROCESS_ARGS
	je	irq64_process_args

	; pobrać własny numer PID?
	cmp	al,	VARIABLE_KERNEL_SERVICE_PROCESS_PID
	je	irq64_process_pid

	; zakończyć proces o podanym PID?
	cmp	al,	VARIABLE_KERNEL_SERVICE_PROCESS_KILL
	je	irq64_process_kill

	; koniec obsługi przerwania programowego
	iretq

.screen:
	; wyczyścić ekran?
	cmp	ax,	VARIABLE_KERNEL_SERVICE_SCREEN_CLEAN
	je	irq64_screen_clear

	; wyświetlić ciąg znaków?
	cmp	ax,	VARIABLE_KERNEL_SERVICE_SCREEN_PRINT_STRING
	je	irq64_screen_print_string

	; wyświetlić znak?
	cmp	ax,	VARIABLE_KERNEL_SERVICE_SCREEN_PRINT_CHAR
	je	irq64_screen_print_char

	; wyświetlić liczbę/cyfrę?
	cmp	ax,	VARIABLE_KERNEL_SERVICE_SCREEN_PRINT_NUMBER
	je	irq64_screen_print_number

	; pobrać pozycję kursora na ekranie?
	cmp	ax,	VARIABLE_KERNEL_SERVICE_SCREEN_CURSOR_GET
	je	irq64_screen_cursor_get

	; ustawić kursor na ekranie?
	cmp	ax,	VARIABLE_KERNEL_SERVICE_SCREEN_CURSOR_SET
	je	irq64_screen_cursor_set

	; koniec obsługi przerwania programowego
	iretq

.keyboard:
	; pobierz kod klawisza z bufora klawiatury?
	cmp	ax,	VARIABLE_KERNEL_SERVICE_KEYBOARD_GET_KEY
	je	irq64_keyboard_get_key

	; koniec obsługi przerwania programowego
	iretq

.network:
	; ustaw adres IP?
	cmp	ax,	VARIABLE_KERNEL_SERVICE_NETWORK_IP_SET
	je	irq64_network_ip_set

	; pobierz adres IP?
	cmp	ax,	VARIABLE_KERNEL_SERVICE_NETWORK_IP_GET
	je	irq64_network_ip_get

	; zarezerwuj port na interfejsie sieciowym?
	cmp	ax,	VARIABLE_KERNEL_SERVICE_NETWORK_PORT_ASSIGN
	je	irq64_network_port_assign

	; zwolnij port na interfejsie sieciowym?
	cmp	ax,	VARIABLE_KERNEL_SERVICE_NETWORK_PORT_ASSIGN
	je	irq64_network_port_assign

	; koniec obsługi przerwania programowego
	iretq

;===============================================================================
;===============================================================================
irq64_process_end:
	; zatrzymaj aktualnie uruchomiony proces
	mov	rdi,	qword [variable_multitasking_serpentine_record_active_address]

.prepared:
	; ustaw flagę "proces zakończony", "rekord nieaktywny"
	and	byte [rdi + VARIABLE_TABLE_SERPENTINE_RECORD.FLAGS],	~STATIC_SERPENTINE_RECORD_FLAG_ACTIVE
	or	byte [rdi + VARIABLE_TABLE_SERPENTINE_RECORD.FLAGS],	STATIC_SERPENTINE_RECORD_FLAG_CLOSED

	; zakończ obsługę procesu
	hlt

	; zatrzymaj dalsze wykonywanie kodu procesu, jeśli coś poszło nie tak??
	jmp	$

;-------------------------------------------------------------------------------
irq64_process_new:
	; uruchom nowy proces
	call	cyjon_process_init

	; koniec obsługi przerwania programowego
	iretq

;-------------------------------------------------------------------------------
irq64_process_check:
	; zachowaj oryginalne rejestry
	push	rax
	push	rbx
	push	rdx
	push	rdi

	; pobierz numer PID procesu do sprawdzenia
	mov	rax,	rcx

	; załaduj adres początku serpentyny
	mov	rdi,	qword [variable_multitasking_serpentine_start_address]

	; ustal ilość rekordów na jedną stronę w serpentynie
	mov	rcx,	( VARIABLE_MEMORY_PAGE_SIZE - VARIABLE_QWORD_SIZE ) / VARIABLE_TABLE_SERPENTINE_RECORD.SIZE
	; pobierz ilość rekordów w serpentynie
	mov	rdx,	qword [variable_multitasking_serpentine_record_counter]

	; kontynuuj
	jmp	.continue

.next_record:
	; zmniejsz ilość rekordów sprawdzonych w aktualnej stronie
	dec	rcx
	; zmniejsz ilość rekordów sprawdzonych w serpentynie
	dec	rdx

	; przesuń wskaźnik adresu na następny rekord
	add	rdi,	VARIABLE_TABLE_SERPENTINE_RECORD.SIZE

.continue:
	; koniec rekordów w serpentynie? brak uruchomionego procesu o podanym PID
	cmp	rdx,	VARIABLE_EMPTY
	ja	.left_something

	; brak uruchomionego procesu o danym PID
	xor	rcx,	rcx

	; koniec
	jmp	.end

.left_something:
	; koniec rekordów na stronie serpentyny? sprawdź następną stronę
	cmp	rcx,	VARIABLE_EMPTY
	ja	.in_page

	; pobierz adres natęnej strony serpentyny
	and	di,	VARIABLE_MEMORY_PAGE_ALIGN
	mov	rdi,	qword [rdi + VARIABLE_MEMORY_PAGE_SIZE - VARIABLE_QWORD_SIZE]

	; zresetuj licznik rekordów na stronę w serpentynie
	mov	rcx,	( VARIABLE_MEMORY_PAGE_SIZE - VARIABLE_QWORD_SIZE ) / VARIABLE_TABLE_SERPENTINE_RECORD.SIZE

.in_page:
	; rekord zawiera numer PID poszukiwanego procesu?
	cmp	rax,	qword [rdi + VARIABLE_TABLE_SERPENTINE_RECORD.PID]
	jne	.next_record

	; zwróć numer PID poszukiwanego procesu - proces istnieje
	mov	rcx,	rax

.end:
	; przywróć oryginalne rejestry
	pop	rdi
	pop	rdx
	pop	rbx
	pop	rax

	; koniec obsługi przerwania programowego
	iretq

;-------------------------------------------------------------------------------
irq64_process_list:
	; zachowaj oryginalne rejestry
	push	rax
	push	rbx
	push	rcx
	push	rdx
	push	rsi
	push	r8
	push	r11
	push	rdi

	; sprawdź czy proces prosi o utworzenie tablicy w miejscu dozwolonym
	mov	rax,	VARIABLE_MEMORY_HIGH_REAL_ADDRESS
	cmp	rdi,	rax
	jb	.error

	; pobierz ilość rekordów w serpentynie
	mov	rax,	qword [variable_multitasking_serpentine_record_counter]
	; pobierz rozmiar jednego rekordu
	mov	rcx,	VARIABLE_TABLE_SERPENTINE_RECORD.SIZE
	xor	rdx,	rdx	; wyczyść starszą część
	; oblicz rozmiar przestrzeni wymagany do exportu tablicy
	mul	rcx

	; zamień na strony
	shr	rax,	VARIABLE_DIVIDE_BY_4096	; VARIABLE_MEMORY_PAGE_SIZE

	; zwiększ o jedną, jeśli proces prosi o utworzenie tablicy nie od pełnego adresu tj. 0xF000
	inc	rax
	mov	rcx,	rax	; załaduj do licznika

	; zachowaj adres docelowy tablicy
	push	rdi

	; przygotuj miejsce pod tablicę w przestrzeni porocesu
	mov	rax,	VARIABLE_MEMORY_HIGH_ADDRESS
	sub	rdi,	rax
	and	di,	VARIABLE_MEMORY_PAGE_ALIGN	; wyrównaj adres do pełnej strony
	mov	rax,	rdi	; ustaw na swoje miejsce - rax => adres
	mov	rbx,	0x07	; flagi: Użytkownik, 4 KiB, Odczyt/Zapis, Dostępna
	mov	r11,	cr3
	call	cyjon_page_map_logical_area

	; przywróć adres docelowy tablicy
	pop	rdi

	; ilość rekordów na stronę
	mov	rcx,	( VARIABLE_MEMORY_PAGE_SIZE - VARIABLE_QWORD_SIZE ) / VARIABLE_TABLE_SERPENTINE_RECORD.SIZE
	; początek tablicy serpentyny
	mov	rsi,	qword [variable_multitasking_serpentine_start_address]

	; ropocznij przeglądanie
	jmp	.page

.empty:
	; przesuń wskaźnik na następny rekord
	add	rsi,	VARIABLE_TABLE_SERPENTINE_RECORD.SIZE

.record:
	; zmniejsz ilość rekordów w stronie
	dec	rcx

.page:
	; sprawdź zostały rekordy w stronie
	cmp	rcx,	VARIABLE_EMPTY
	ja	.in_page

	; pobierz adres następnej strony/części serpentyny
	and	si,	VARIABLE_MEMORY_PAGE_ALIGN
	mov	rsi,	qword [rsi + VARIABLE_MEMORY_PAGE_SIZE - VARIABLE_QWORD_SIZE]

	; sprawdź czy istnieje dalsza część serpentyny
	cmp	rsi,	qword [variable_multitasking_serpentine_start_address]
	je	.terminate	; koniec

	; zresetuj ilość rekordów na stronę
	mov	rcx,	( VARIABLE_MEMORY_PAGE_SIZE - VARIABLE_QWORD_SIZE ) / VARIABLE_TABLE_SERPENTINE_RECORD.SIZE

.in_page:
	; sprawdź czy rekord pusty
	cmp	qword [rsi + VARIABLE_TABLE_SERPENTINE_RECORD.FLAGS],	VARIABLE_EMPTY	
	je	.empty

	; zachowaj licznik
	push	rcx

	; skopiuj rekord do tablicy procesu
	mov	rcx,	VARIABLE_TABLE_SERPENTINE_RECORD.SIZE
	rep	movsb

	; usuń informacje o PML4 rekordu
	mov	qword [rdi - VARIABLE_TABLE_SERPENTINE_RECORD.SIZE + VARIABLE_TABLE_SERPENTINE_RECORD.CR3],	VARIABLE_EMPTY
	; usuń informacje o stosie
	mov	qword [rdi - VARIABLE_TABLE_SERPENTINE_RECORD.SIZE + VARIABLE_TABLE_SERPENTINE_RECORD.RSP],	VARIABLE_EMPTY

	; przywróć licznik
	pop	rcx

	; kontynuuj przeglądanie
	jmp	.record

.terminate:
	; pusty rekord na koniec tablicy
	stosq
	stosq

	; koniec
	jmp	.end

.error:
	; nieprawidłowy adres, anulowano
	mov	qword [rsp],	VARIABLE_EMPTY

.end:
	; przywróć oryginalne rejestry
	pop	rdi
	pop	r11
	pop	r8
	pop	rsi
	pop	rdx
	pop	rcx
	pop	rbx
	pop	rax

	; koniec obsługi przerwania programowego
	iretq

;-------------------------------------------------------------------------------
irq64_process_args:
	; zachowaj oryginalne rejestry
	push	rax
	push	rbx
	push	rdx
	push	rsi
	push	rdi
	push	r8
	push	r11

	; pobierz rozmiar ciągu argumentów przesłanych do procesu
	mov	rdi,	qword [variable_multitasking_serpentine_record_active_address]
	mov	rcx,	qword [rdi + VARIABLE_TABLE_SERPENTINE_RECORD.ARGS]
	cmp	rcx,	VARIABLE_EMPTY
	je	.end	; brak argumentów przesłanych do procesu

	; przygotuj miejsce pod argumenty
	mov	rax,	qword [rsp + VARIABLE_QWORD_SIZE * 0x02]
	mov	rbx,	VARIABLE_MEMORY_HIGH_ADDRESS
	sub	rax,	rbx
	mov	rbx,	0x07	; flagi: Użytkownik, 4 KiB, Odczyt/Zapis, Dostępna
	mov	rcx,	1	; rozmiar 1 strona
	mov	r11,	cr3
	call	cyjon_page_map_logical_area

	mov	rsi,	qword [rdi + VARIABLE_TABLE_SERPENTINE_RECORD.ARGS]
	mov	rdi,	qword [rsp + VARIABLE_QWORD_SIZE * 0x02]

	; zachowaj rozmiar ciągu argumentów
	push	qword [rsi]

	; przesuń wskaźnik na początek ciągu
	add	rsi,	VARIABLE_QWORD_SIZE

	; skopiuj ciąg argumentów do pamięci procesu
	mov	rcx,	( VARIABLE_MEMORY_PAGE_SIZE - VARIABLE_QWORD_SIZE ) / VARIABLE_QWORD_SIZE
	rep	movsq

	; przywróć rozmiar ciągu argumentów
	pop	rcx

.end:
	; przywróć oryginalne rejestry
	pop	r11
	pop	r8
	pop	rdi
	pop	rsi
	pop	rdx
	pop	rbx
	pop	rax

	; koniec obsługi przerwania programowego
	iretq

;-------------------------------------------------------------------------------
irq64_process_pid:
	; zachowaj oryginalne rejestry
	push	rsi

	; załaduj własny adres rekordu
	mov	rsi,	qword [variable_multitasking_serpentine_record_active_address]
	; pobierz numer PID
	mov	rcx,	qword [rsi + VARIABLE_TABLE_SERPENTINE_RECORD.PID]

	; przywróć oryginalne rejestry
	pop	rsi

	; koniec obsługi przerwania programowego
	iretq

;-------------------------------------------------------------------------------
irq64_process_kill:
	; zachowaj oryginalne rejestry
	push	rbx
	push	rdi

	; ktoś chce ubić jądro systemu? good luck
	cmp	rcx,	VARIABLE_EMPTY
	je	.easter_egg

	; ustaw wskaźnik na początek serpentyny
	mov	rdi,	qword [variable_multitasking_serpentine_start_address]

	; ustaw liczniki
	mov	rbx,	( VARIABLE_MEMORY_PAGE_SIZE - 0x08 ) / VARIABLE_TABLE_SERPENTINE_RECORD.SIZE

	; sprawdź pierwszy rekord
	jmp	.check

.continue:
	; mniejsz ilość rekordów do przeszukania w tej części serpentyny
	dec	rbx
	jnz	.check

	; załaduj adres kontynuacji serpentyny
	and	di,	0xF000
	mov	rdi,	qword [rdi + VARIABLE_MEMORY_PAGE_SIZE - VARIABLE_QWORD_SIZE]

	; wróciliśmy do początku?
	cmp	rdi,	qword [variable_multitasking_serpentine_start_address]
	je	.lost

	; zresetuj licznik rekordów na stronę
	mov	rbx,	( VARIABLE_MEMORY_PAGE_SIZE - VARIABLE_QWORD_SIZE ) / VARIABLE_TABLE_SERPENTINE_RECORD.SIZE

.check:
	; sprawdź PID procesu (rekordu)
	cmp	qword [rdi + VARIABLE_TABLE_SERPENTINE_RECORD.PID],	rcx
	je	.found

	; przesuń wskaźnik na następny rekord
	add	rdi,	VARIABLE_TABLE_SERPENTINE_RECORD.SIZE

	; sprawdź pozostałe rekordy
	jmp	.continue

.found:
	; sprawdź czy użytkownik chce zabić demona
	mov	bx,	STATIC_SERPENTINE_RECORD_BIT_DAEMON
	bt	word [rdi + VARIABLE_TABLE_SERPENTINE_RECORD.FLAGS],	bx
	jc	.prohibited_operation

	; ustaw flagę rekordu "proces zakończony", "rekord nieaktywny"
	and	byte [rdi + VARIABLE_TABLE_SERPENTINE_RECORD.FLAGS],	~STATIC_SERPENTINE_RECORD_FLAG_ACTIVE
	or	byte [rdi + VARIABLE_TABLE_SERPENTINE_RECORD.FLAGS],	STATIC_SERPENTINE_RECORD_FLAG_CLOSED

	; proces zostanie zamknięty
	jmp	.end

.lost:
	; nie znaleziono podanej PID procesu w tablicy serpentyny
	xor	rcx,	rcx	; zwróć informacje o tym

.end:
	; przywróć oryginalne rejestry
	pop	rdi
	pop	rbx

	; koniec obsługi przerwania programowego
	iretq

.prohibited_operation:
	; wyświetl ostrzeżenie
	mov	bl,	VARIABLE_COLOR_RED
	mov	cl,	VARIABLE_FULL
	mov	dl,	VARIABLE_COLOR_BACKGROUND_DEFAULT
	mov	rsi,	text_process_prohibited_operation
	call	cyjon_screen_print_string

	; zniszcz proces
	mov	rdi,	qword [variable_multitasking_serpentine_record_active_address]
	jmp	irq64_process_end.prepared

.easter_egg:
	; wymyśli się coś ciekawego
	cli

	jmp	$

;===============================================================================
;===============================================================================
irq64_screen_clear:
	; wyczyść ekran
	call	cyjon_screen_clear

	; koniec obsługi przerwania programowego
	iretq

;-------------------------------------------------------------------------------
irq64_screen_print_string:
	; wyświetl ciąg znaków na ekranie
	call	cyjon_screen_print_string

	; koniec obsługi przerwania programowego
	iretq

;-------------------------------------------------------------------------------
irq64_screen_print_char:
	; zachowaj oryginalne rejestry
	push	rax
	push	rcx
	push	rdi

	; załaduj znak do wyświetlenia
	mov	rax,	r8
	
	; pobierz pozycje kursora w przestrzeni pamięci ekranu
	mov	rdi,	qword [variable_screen_cursor_indicator]

.loop:
	; wyświetl znak
	call	cyjon_screen_print_char

	; zapisz aktualną pozycję kursora w przestrzeni pamięci ekranu
	mov	qword [variable_screen_cursor_indicator],	rdi

	; sprawdź pozycje kursora
	call	cyjon_screen_cursor_position_check

	; kontynuuj z pozostałą ilością powtórzeń
	loop	.loop

	; przesuń kursor na odpowiednią pozycję
	call	cyjon_screen_cursor_move

	; przywróć oryginalne rejestry
	pop	rdi
	pop	rcx
	pop	rax

	; koniec obsługi przerwania programowego
	iretq

;-------------------------------------------------------------------------------
irq64_screen_print_number:
	; zachowaj oryginalne rejestry
	push	rax
	push	rdi

	; załaduj liczbe do wyświetlenia
	mov	rax,	r8

	; wykonaj
	call	cyjon_screen_print_number

	; przywróć oryginalne rejestry
	pop	rdi
	pop	rax

	; koniec obsługi przerwania programowego
	iretq

;-------------------------------------------------------------------------------
irq64_screen_cursor_get:
	; zachowaj oryginalne rejestry
	push	rax
	push	rcx
	push	rdx

	; pobierz wskaźnik adresu kursora w przestrzeni pamięci ekranu
	mov	rax,	qword [variable_screen_cursor_indicator]
	; oblicz przesunięcie
	sub	rax,	VARIABLE_SCREEN_TEXT_MODE_BASE_ADDRESS
	; usuń atrybuty znaków
	shr	rax,	VARIABLE_DIVIDE_BY_2

	; oblicz X i Y
	mov	rcx,	VARIABLE_SCREEN_TEXT_MODE_WIDTH
	xor	rdx,	rdx
	div	rcx

	; zwróć wynik
	push	rdx
	add	dword [rsp + VARIABLE_QWORD_HIGH],	eax
	pop	rbx

	; przywróć oryginalne rejestry
	pop	rdx
	pop	rcx
	pop	rax

	; koniec obsługi przerwania programowego
	iretq

;-------------------------------------------------------------------------------
irq64_screen_cursor_set:
	; zachowaj oryginalny rejestr
	push	rdi

	; oblicz nowy wskaźnik w przestrzeni ekranu
	call	cyjon_screen_cursor_indicator

	; przywróć oryginalny rejestr
	pop	rdi

	; przesuń kursor na wskazaną pozycję
	call	cyjon_screen_cursor_move

	; koniec obsługi przerwania programowego
	iretq	

;===============================================================================
;===============================================================================
irq64_keyboard_get_key:
	; pobierz kod ASCII klawisza z bufora klawiatury
	call	cyjon_keyboard_key_read

	; koniec obsługi przerwania programowego
	iretq

;===============================================================================
;===============================================================================
irq64_network_ip_set:
	; ustaw adres IP
	mov	dword [variable_network_ip],	ebx

	; koniec obsługi przerwania programowego
	iretq

;-------------------------------------------------------------------------------
irq64_network_ip_get:
	; pobierz adres IP
	mov	ebx,	dword [variable_network_ip]

	; koniec obsługi przerwania programowego
	iretq

;-------------------------------------------------------------------------------
irq64_network_port_assign:
	

	; koniec obsługi przerwania programowego
	iretq

irq64_network_port_release:
	

	; koniec obsługi przerwania programowego
	iretq	
