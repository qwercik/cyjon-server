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
; procedura tworzy tablicę IDT do obsługi przerwań i wyjątków
; IN:
;	brak
; OUT:
;	brak
;
; wszystkie rejestry zachowane
interrupt_descriptor_table:
	; zachowaj oryginalne rejestry
	push	rax
	push	rbx
	push	rcx
	push	rdi

	; przygotuj miejsce na Tablicę Deskryptorów Przerwań
	call	cyjon_page_allocate	; plik: engine/paging.asm
	; wyczyść wszystkie rekordy
	call	cyjon_page_clear	; plik: engine/paging.asm

	; zapisz adres Tablicy Deskryptorów Przerwań
	mov	qword [variable_idt_structure.address],	rdi

	; utworzymy obsługę 32 wyjątków (zombi, w przyszłości utworzy się odpowiednie procedury obsługi) procesora
	mov	rax,	idt_cpu_exception
	mov	bx,	0x8E00	; typ - wyjątek procesora
	mov	rcx,	32	; wszystkie wyjątki procesora
	call	recreate_record	; utwórz

	; utworzymy obsługę 16 przerwań (zombi) sprzętowych
	; gdyby jakimś cudem wystąpiły
	; co niektóre dostaną prawidłową procedurę obsługi
	mov	rax,	idt_hardware_interrupt
	mov	bx,	VARIABLE_IDT_RECORD_TYPE_CPU	; typ - przerwanie sprzętowe
	mov	rcx,	16	; wszystkie przerwania sprzętowe
	call	recreate_record	; utwórz

	; utworzymy obsługę pozostałych 208 przerwań (zombi) programowych
	; tylko jedno z nich (przerwanie 64, 0x40) dostanie prawidłową procedurę obsługi
	mov	rax,	idt_software_interrupt
	mov	bx,	VARIABLE_IDT_RECORD_TYPE_SOFTWARE	; typ - przerwanie programowe
	mov	rcx,	208	; pozostałe rekordy w tablicy
	call	recreate_record	; utwórz

	; podłączamy poszczególne procedury obsługi przerwań/wyjątków

	;---------------------------------------------------------------

	; procedura obsługi przerwania sprzętowego zegara
	mov	rax,	irq32	; plik: engine/multitasking.asm
	mov	bx,	VARIABLE_IDT_RECORD_TYPE_HARDWARE	; typ - przerwanie sprzętowe
	mov	rcx,	1	; modyfikuj jeden rekord
	; ustaw adres rekordu
	mov	rdi,	qword [variable_idt_structure.address]
	add	rdi,	0x10 * 32	; podrekord 0
	call	recreate_record

	; procedura obsługi przerwania sprzętowego klawiatury
	mov	rax,	irq33	; plik: engine/keyboard.asm
	call	recreate_record

	;---------------------------------------------------------------

	; procedura obsługi przerwania programowego użytkownika
	mov	rax,	irq64	; plik: engine/multitasking.asm
	mov	bx,	VARIABLE_IDT_RECORD_TYPE_SOFTWARE	; typ - przerwanie sprzętowe
	; ustaw adres rekordu
	mov	rdi,	qword [variable_idt_structure.address]
	add	rdi,	0x10 * 64
	call	recreate_record

	;---------------------------------------------------------------

	; załaduj Tablicę Deskryptorów Przerwań
	lidt	[variable_idt_structure]

	; przywróć oryginalne rejestry
	pop	rdi
	pop	rcx
	pop	rbx
	pop	rax

	; powrót z przerwania
	ret

;===============================================================================
; procedura podstawowej obsługi wyjątku/przerwania procesora
; IN:
;	brak
; OUT:
;	brak
;
; wszystkie rejestry zachowane
idt_cpu_exception:
	; wyświetl informację
	mov	rsi,	text_kernel_panic_cpu_interrupt
	jmp	cyjon_screen_kernel_panic	; plik: engine/screen.asm

;===============================================================================
; procedura podstawowej obsługi przerwania sprzętowego
; IN:
;	brak
; OUT:
;	brak
;
; wszystkie rejestry zachowane
idt_hardware_interrupt:
	; wyświetl informację
	mov	rsi,	text_kernel_panic_hardware_interrupt
	jmp	cyjon_screen_kernel_panic	; plik: engine/screen.asm

;===============================================================================
; procedura podstawowej obsługi przerwania programowego
; IN:
;	brak
; OUT:
;	brak
;
; wszystkie rejestry zachowane
idt_software_interrupt:
	; wyświetl informację
	mov	bl,	VARIABLE_COLOR_LIGHT_RED
	mov	rcx,	VARIABLE_FULL
	mov	dl,	VARIABLE_COLOR_BACKGROUND_DEFAULT
	mov	rsi,	text_kernel_panic_software_interrupt
	call	cyjon_screen_print_string

	; zatrzymaj aktualnie uruchomiony proces
	mov	rdi,	qword [variable_multitasking_serpentine_record_active_address]

	; ustaw flagę "proces zakończony", "rekord nieaktywny"
	and	byte [rdi + VARIABLE_TABLE_SERPENTINE_RECORD.FLAGS],	~STATIC_SERPENTINE_RECORD_FLAG_ACTIVE
	or	byte [rdi + VARIABLE_TABLE_SERPENTINE_RECORD.FLAGS],	STATIC_SERPENTINE_RECORD_FLAG_CLOSED

	; zakończ obsługę procesu
	sti
	hlt

	; zatrzymaj dalsze wykonywanie kodu procesu, jeśli coś poszło nie tak??
	jmp	$

;===============================================================================
; procedura tworzy/modyfikuje rekord w Tablicy Deskryptorów Przerwań
; IN:
;	rax	- adres logiczny procesury obsługi wyjątku/przerwania
;	bx	- typ: wyjątek/przerwanie(sprzętowe/programowe)
;	rcx	- ilość kolejnych rekordów o tej samej procedurze obsługi
;	rdi	- adres logiczny rekordu w Tablicy Deskryptorów Przerawń do modyfikacji
; OUT:
;	rdi	- adres kolejnego rekordu w Tablicy Deskryptorów Przerwań
;
; pozostałe rejestry zachowane
recreate_record:
	; zachowaj oryginalny rejestr
	push	rcx

.next:
	; zachowaj adres procedury obsługi
	push	rax

	; załaduj do tablicy adres obsługi wyjątku (bity 15...0)
	stosw	; zapisz zawartość rejestru AX pod adres w rejestrze RDI, zwiększ rejestr RDI o 2 Bajty

	; selektor deskryptora kodu (GDT)
	mov	ax,	0x0008
	stosw	; zapisz zawartość rejestru AX pod adres w rejestrze RDI, zwiększ rejestr RDI o 2 Bajty

	; typ: wyjątek/przerwanie(sprzętowe/programowe)
	mov	ax,	bx
	stosw	; zapisz zawartość rejestru AX pod adres w rejestrze RDI, zwiększ rejestr RDI o 2 Bajty

	; przywróć wartość zmiennej
	mov	rax,	qword [rsp]

	; przemieszczamy do ax bity 31...16 z rax
	shr	rax,	16
	stosw	; zapisz zawartość rejestru AX pod adres w rejestrze RDI, zwiększ rejestr RDI o 2 Bajty

	; przemieszczamy do eax bity 63...32 z rax
	shr	rax,	16
	stosd	; zapisz zawartość rejestru EAX pod adres w rejestrze RDI, zwiększ rejestr RDI o 4 Bajty

	; pola zastrzeżone
	xor	eax,	eax
	stosd	; zapisz zawartość rejestru EAX pod adres w rejestrze RDI, zwiększ rejestr RDI o 4 Bajty

	; przywróć adres procedury obsługi
	pop	rax

	; utwórz pozostałe rekordy
	loop	.next

	; przywróć oryginalny rejestr
	pop	rcx

	; powrót z procedury
	ret

;===============================================================================
; podpięcie procedury obsługi przerwania
; IN:
;	rax - numer przerwania, pod które podpiąć procedurę
;	rdi - adres procedury obsługi przerwania
; OUT:
;	brak
;
; wszystkie rejestry zachowane
cyjon_interrupt_descriptor_table_isr_hardware_mount:
	; zachowaj oryginalne rejestry
	push	rax
	push	rbx
	push	rcx
	push	rdi

	; ustaw na swoje miejsca
	xchg	rax,	rdi

	; oblicz przesunięcie
	shl	rdi,	4	; * 0x10
	add	rdi,	0x10 * 32
	add	rdi,	qword [variable_idt_structure.address]

	; procedura obsługi przerwania sprzętowego zegara
	mov	bx,	VARIABLE_IDT_RECORD_TYPE_HARDWARE	; typ - przerwanie sprzętowe
	mov	rcx,	1	; modyfikuj jeden rekord
	call	recreate_record

	; przywróć oryginalne rejestry
	pop	rdi
	pop	rcx
	pop	rbx
	pop	rax

	; powrót z procedury
	ret
