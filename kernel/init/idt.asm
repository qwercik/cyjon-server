;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

	; przygotuj miejsce na Tablicę Deskryptorów Przerwań
	call	kernel_page_request

	; wyczyść i zachowaj adres tablicy deskryptorów przewań
	call	kernel_page_dump
	mov	qword [kernel_idt_header + KERNEL_STRUCTURE_GDT_OR_IDT_HEADER.address],	rdi

	; domyślna obsługa wyjątku procesora
	mov	rax,	kernel_idt_exception_default
	mov	bx,	KERNEL_IDT_TYPE_EXCEPTION	; typ przerwania - wyjątek
	mov	rcx,	32	; mapuj wyjątki procesora 0..31
	call	kernel_idt_update_descriptor

	; domyślna obsługa przerwania sprzętowego
	mov	rax,	kernel_idt_hardware_default
	mov	bx,	KERNEL_IDT_TYPE_IRQ	; typ przerwania - sprzętowe
	mov	rcx,	16	; mapuj wszystkie przerwania sprzętowe 32..47 (0..15)
	call	kernel_idt_update_descriptor

	; domyślna obsługa przerwania programowego
	mov	rax,	kernel_idt_software_default
	mov	bx,	KERNEL_IDT_TYPE_ISR	; typ przerwania - programowe
	mov	rcx,	208	; mapuj pozostałe przerwania programowe 48..255
	call	kernel_idt_update_descriptor

	;-----------------------------------------------------------------------
	; załaduj Tablicę Deskryptorów Przerwań
	lidt	[kernel_idt_header]
