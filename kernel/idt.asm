;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

;===============================================================================
; domyślna obsługa wyjątków procesora i przerwań programowych
kernel_idt_exception_default:
kernel_idt_software_default:
	; Bochs debug: magic_break
	xchg	bx,bx

	; zatrzymaj dalsze wykonywanie kodu jądra systemu
	jmp	$

;===============================================================================
; domyślna obsługa przerwania sprzętowego
kernel_idt_hardware_default:
	; zachowaj oryginalne rejestry
	push	rax
	pushf

	; w teori procedura ta, nigdy nie powinna mieć miejsca

	; poinformuj kontroler PIC o obsłużeniu przerwania sprzętowego
	mov	al,	PIC_IRQ_ACCEPT

	; wyślij do kontrolera "kaskadowego"
	out	PORT_PIC_SLAVE_command,	al

	; wyślij do kontrolera głównego
	out	PORT_PIC_MASTER_command,	al

	; przywróć oryginalne rejestry
	popf
	pop	rax

	; powrót z przerwania sprzetowego
	iretq

;===============================================================================
; wejście:
;	rax - numer przerwania
;	rbx - identyfikator przerwania (wyjątek, sprzęt lub proces)
;	rdi - adres procedury obsługi przerwania
kernel_idt_irq_mount:
	; zachowaj oryginalne rejestry
	push	rax
	push	rbx
	push	rcx
	push	rdi

	; ustaw rejestry na swoje miejsca
	xchg	rax,	rdi

	; oblicz przesunięcie do rekordu numeru przerwania
	shl	rdi,	MULTIPLE_BY_16_shift
	add	rdi,	qword [kernel_idt_header + KERNEL_STRUCTURE_GDT_OR_IDT_HEADER.address]

	; procedura obsługi przerwania
	mov	rcx,	1	; podłącz procedurę obsługi pod jeden rekord
	call	kernel_idt_update_descriptor

	; przywróć oryginalne rejestry
	pop	rdi
	pop	rcx
	pop	rbx
	pop	rax

	; powrót z procedury
	ret

;===============================================================================
; wejście:
;	rax - adres logiczny procedury obsługi
;	bx - typ: wyjątek, przerwanie(sprzętowe, programowe)
;	rcx - ilość kolejnych rekordów o tej samej procedurze obsługi
;	rdi - adres rekordu do modyfikacji w Tablicy Deskryptorów Przerwań
; wyjście:
;	rdi - adres kolejnego rekordu w Tablicy Deskryptorów Przerwań
kernel_idt_update_descriptor:
	; zachowaj oryginalne rejestry
	push	rcx

.next:
	; zachowaj adres procedury obsługi
	push	rax

	; załaduj do tablicy adres obsługi wyjątku (bity 15...0)
	stosw

	; selektor deskryptora kodu (GDT), wszystkie procedury wywoływane są z uprawnieniami ring0
	mov	ax,	KERNEL_STRUCTURE_GDT.cs_ring0
	stosw

	; typ: wyjątek, przerwanie(sprzętowe, programowe)
	mov	ax,	bx
	stosw

	; przywróć adres procedury obsługi
	mov	rax,	qword [rsp]

	; przemieszczamy do ax bity 31...16
	shr	rax,	MOVE_HIGH_TO_AX
	stosw

	; przemieszczamy do eax bity 63...32
	shr	rax,	MOVE_HIGH_TO_EAX
	stosd

	; pola zastrzeżone, zostawiamy puste
	xor	eax,	eax
	stosd

	; przywróć adres procedury obsługi
	pop	rax

	; przetwórz pozostałe rekordy
	dec	rcx
	jnz	.next

	; przywróć oryginalne rejestry
	pop	rcx

	; powrót z procedury
	ret
