;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

; zmienne, stałe, struktury
%include "kernel/config.asm"

; 64 bitowy kod jądra systemu
[BITS 64]

; położenie kodu w pamięci fizycznej
[ORG KERNEL_BASE_address]

;===============================================================================
init:
	;-----------------------------------------------------------------------
	; inicjalizuj środowisko jądra systemu
	;-----------------------------------------------------------------------
	%include "kernel/init.asm"

; koniec kodu inicjalizującego jądro systemu wyrównujemy do adresu pełnej strony, wypełniając przestrzeń pustymi bajtami
align	KERNEL_PAGE_SIZE_byte,	db	EMPTY

;===============================================================================
clean:
	; oblicz ilość stron do zwolnienia
	mov	rcx,	clean - init
	shr	rcx,	DIVIDE_BY_PAGE_shift

	; zacznij od strony pod adresem
	mov	rdi,	init

.loop:
	; zwolnij stronę
	call	kernel_page_release

	; następny adres strony
	add	rdi,	KERNEL_PAGE_SIZE_byte

	; pozostały strony do zwolnienia?
	dec	rcx
	jnz	.loop	; tak

;===============================================================================
kernel:
	; włącz przerwania
	sti

	; zatrzymaj dalsze wykonywanie kodu
	jmp	$

	;-----------------------------------------------------------------------
	; dołącz procedury tworzące ciało jądra systemu
	;-----------------------------------------------------------------------
	%include "kernel/data.asm"
	%include "kernel/page.asm"
	%include "kernel/idt.asm"
	%include "kernel/keyboard.asm"
	%include "kernel/pic.asm"
	%include "kernel/task.asm"
	%include "kernel/pci.asm"

	;-----------------------------------------------------------------------
	; dołącz sterowniki urządzeń
	;-----------------------------------------------------------------------
	%include "kernel/drivers/network/82540em.asm"

	;-----------------------------------------------------------------------
	; dołącz demony
	;-----------------------------------------------------------------------
	%include "kernel/daemons/ethernet.asm"

	;-----------------------------------------------------------------------
	; dołącz liblioteki wykorzystywane przez jądro systemu
	;-----------------------------------------------------------------------
	%include "library/library_page_align_up.asm"
	%include "library/library_bit_find.asm"

; koniec kodu jądra systemu wyrównujemy do adresu pełnej strony, wypełniając przestrzeń pustymi bajtami
align	KERNEL_PAGE_SIZE_byte,	db	EMPTY

kernel_end:
