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

	; pobierz pozycje kursora w przestrzeni pamięci ekranu
	mov	rdi,	qword [kernel_video_cursor_indicator]

.loop:
	; pobierz naciśnięty klawisz z bufora klawiatury
	call	kernel_keyboard_read

	; brak klawisza?
	test	ax,	ax
	jz	.loop	; zignoruj

	; klawisz enter?
	cmp	ax,	ASCII_ENTER
	je	.enter	; tak

	; klawisz backspace?
	cmp	ax,	ASCII_BACKSPACE
	je	.show	; tak

	; czy znak ASCII znajduje się w zakresie znaków interpunkcyjnych i alfabetu łacińskiego?
	cmp	ax,	ASCII_SPACE
	jb	.loop	; nie
	cmp	ax,	ASCII_TILDE
	ja	.loop	; nie

	; wyświetl
	jmp	.show

.enter:
	; zamień na znak nowej linii
	mov	ax,	ASCII_NEW_LINE

.show:
	; wyświetl klawisz na ekran
	mov	ah,	byte [kernel_video_char_color]
	call	kernel_video_char

	; zachowaj nową pozycję wskaźnika kursora w przestrzeni pamięci ekranu
	mov	qword [kernel_video_cursor_indicator],	rdi

	; aktualizuj pozycje kursora sprzętowego na ekranie
	call	kernel_video_cursor

	; zatrzymaj dalsze wykonywanie kodu
	jmp	.loop

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
	%include "kernel/video.asm"

	;-----------------------------------------------------------------------
	; dołącz sterowniki urządzeń
	;-----------------------------------------------------------------------
	%include "kernel/drivers/network/82540em.asm"

	;-----------------------------------------------------------------------
	; dołącz demony
	;-----------------------------------------------------------------------
	%include "kernel/daemons/ethernet.asm"

	;-----------------------------------------------------------------------
	; dołącz biblioteki wykorzystywane przez jądro systemu
	;-----------------------------------------------------------------------
	%include "library/library_page_align_up.asm"
	%include "library/library_bit_find.asm"

; koniec kodu jądra systemu wyrównujemy do adresu pełnej strony, wypełniając przestrzeń pustymi bajtami
align	KERNEL_PAGE_SIZE_byte,	db	EMPTY

kernel_end:
