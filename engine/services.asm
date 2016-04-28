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
	cmp	ah,	0x00
	je	.process

	; obsługa ekranu?
	cmp	ah,	0x01
	je	.screen

	; obsługa klawiatury?
	cmp	ah,	0x02
	je	.keyboard

.end:
	; koniec obsługi przerwania programowego
	iretq

.process:
	; proces zakończył działanie?
	cmp	al,	0x00
	je	irq64_process_end

	; uruchomić nowy proces?
	cmp	al,	0x01
	je	irq64_process_new

	; sprawdzić czy proces jest uruchomiony?
	cmp	al,	0x02
	je	irq64_process_check

	; koniec obsługi przerwania programowego
	iretq

.screen:
	; wyczyścić ekran?
	cmp	al,	0x00
	je	irq64_screen_clear

	; wyświetlić ciąg znaków?
	cmp	al,	0x01
	je	irq64_screen_print_string

	; wyświetlić znak?
	cmp	al,	0x02
	je	irq64_screen_print_char

	; wyświetlić liczbę/cyfrę?
	cmp	al,	0x03
	je	irq64_screen_print_number



	; ustawić kursor na ekranie?
	cmp	al,	0x05
	je	irq64_screen_cursor_set

	; koniec obsługi przerwania programowego
	iretq

.keyboard:
	; pobierz kod klawisza z bufora klawiatury?
	cmp	al,	0x00
	je	irq64_keyboard_get_key

	; koniec obsługi przerwania programowego
	iretq

;===============================================================================
;===============================================================================
irq64_process_end:
	; zatrzymaj aktualnie uruchomiony proces
	mov	rdi,	qword [variable_multitasking_serpentine_record_active_address]

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

; debug
align	0x0100

;-------------------------------------------------------------------------------
irq64_process_check:
	; zachowaj oryginalne rejestry
	push	rax
	push	rbx
	push	rdx
	push	rdi

	mov	rax,	rcx

	mov	rdi,	qword [variable_multitasking_serpentine_start_address]

	mov	rcx,	( VARIABLE_MEMORY_PAGE_SIZE - 0x08 ) / VARIABLE_TABLE_SERPENTINE_RECORD.SIZE
	mov	rdx,	qword [variable_multitasking_serpentine_record_counter]

	jmp	.do_not_leave_me

.next_record:
	dec	rcx
	dec	rdx

	; przesuń na następny rekord
	add	rdi,	VARIABLE_TABLE_SERPENTINE_RECORD.SIZE

.do_not_leave_me:
	cmp	rdx,	VARIABLE_EMPTY
	ja	.left_something

	; brak uruchomionego procesu o danym PID
	xor	rcx,	rcx

	jmp	.end

.left_something:
	cmp	rcx,	VARIABLE_EMPTY
	ja	.in_page

	and	di,	0xF000
	mov	rdi,	qword [rdi + 0x0FF8]

	mov	rcx,	( VARIABLE_MEMORY_PAGE_SIZE - 0x08 ) / VARIABLE_TABLE_SERPENTINE_RECORD.SIZE

.in_page:
	cmp	rax,	qword [rdi + VARIABLE_TABLE_SERPENTINE_RECORD.PID]
	jne	.next_record

	mov	rcx,	qword [rdi + VARIABLE_TABLE_SERPENTINE_RECORD.PID]

.end:
	; przywróć oryginalne rejestry
	pop	rdi
	pop	rdx
	pop	rbx
	pop	rax

	; koniec obsługi przerwania programowego
	iretq

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
irq64_screen_cursor_set:
	; oblicz nowy wskaźnik w przestrzeni ekranu
	call	cyjon_screen_cursor_indicator

	; przesuń kursor na wskazaną pozycję
	call	cyjon_screen_cursor_move

	; koniec obsługi przerwania programowego
	iretq	

;===============================================================================
irq64_keyboard_get_key:
	; pobierz kod ASCII klawisza z bufora klawiatury
	call	cyjon_keyboard_key_read

	; koniec obsługi przerwania programowego
	iretq
