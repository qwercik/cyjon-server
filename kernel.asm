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

; zestaw imiennych wartości stałych
%include	"config.asm"

;-------------------------------------------------------------------------------
; 32 bitowy kod jądra systemu
;-------------------------------------------------------------------------------
[BITS 32]

; położenie kodu jądra systemu w pamięci fizycznej/logicznej
[ORG VARIABLE_KERNEL_PHYSICAL_ADDRESS]

; NAGŁÓWEK =====================================================================
header:
	; informacja dla programu rozruchowego Omega
	db	0x20	; kod jądra systemu rozpoczyna się od 32 bitowych instrukcji
; NAGŁÓWEK KONIEC ==============================================================

_start:
	; poinformuj jądro systemu o wykorzystaniu własnego programu rozruchowego
	mov	byte [variable_bootloader_own],	VARIABLE_TRUE

	; skocz do procedury przełączania procesora w tryb 64 bitowy
	jmp	entry	; plik engine/init.asm

variable_bootloader_own	db	VARIABLE_EMPTY

%include	"engine/multiboot.asm"
%include	"engine/init.asm"

; rozpocznij 64 bitowy kod jądra systemu od pełnego adresu
align	0x0100

;-------------------------------------------------------------------------------
; 64 bitowy kod jądra systemu
;-------------------------------------------------------------------------------
[BITS 64]

kernel:
	; ustaw deskryptory danych, ekstra i stosu
	mov	ax,	VARIABLE_KERNEL_DS_SELECTOR

	; podstawowe segmenty
	mov	ds,	ax	; segment danych
	mov	es,	ax	; segment ekstra
	mov	ss,	ax	; segment stosu

	; wyczyść ekran
	call	cyjon_screen_clear

	; zachowaj adres mapy pamięci
	push	rbx	; GRUB
	push	rsi	; OMEGA

	; wyświetl informacje powitalną
	mov	bl,	VARIABLE_COLOR_LIGHT_GREEN + VARIABLE_COLOR_BACKGROUND_BLACK
	mov	cl,	VARIABLE_FULL
	mov	rsi,	text_kernel_welcome
	call	cyjon_screen_print_string

	; przywróć adres mapy pamięci
	pop	rsi	; OMEGA
	pop	rbx	; GRUB

	; zarejestruj dostępną przestrzeń pamięci w Binarnej Mapie Pamięci
	call	binary_memory_map

	; utwórz własną Globalną Tablicę Deskryptorów
	call	global_descriptor_table

	; utwórz nowe tablice stronicowania dla jądra systemu
	call	recreate_paging

	; przygotuj obsługę wyjątków i przerwań procesora, przerwań użyktownika
	call	interrupt_descriptor_table

	; przemapuj numery przerwań sprzętowych pod 0x20..0x2F
	call	programmable_interrupt_controller

	; ustaw częstotliwość wywołań przerwania sprzętowego IRQ0
	call	programmable_interval_timer

	; przygotuj kolejkę procesów (nazwaną 'Serpentyna') i załaduj do niej jądro systemu
	call	multitasking

	; załaduj podstawową macierz znaków klawiatury
	call	keyboard

	; włączamy przerwania i wyjątki procesora
	sti	; tchnij życie

	; przygotuj wirtualny system plików na programy wbudowane
	call	virtual_file_system

	; inicjalizuj pierwszą dostępną kartę sieciową
	call	network_init

	; zarejestruj dołączone oprogramowanie w wirtualnym systemie plików jądra systemu
	call	move_included_files_to_virtual_filesystem

	; uruchom demona - kolekcjonera śmieci
	movzx	rcx,	byte [variable_daemon_garbage_collector_name_count]
	mov	rdx,	daemon_garbage_collector
	mov	rsi,	variable_daemon_garbage_collector_name
	call	cyjon_process_init_daemon

	; uruchom demona - protokół ethernet
	movzx	rcx,	byte [variable_daemon_ethernet_name_count]
	mov	rdx,	daemon_ethernet
	mov	rsi,	variable_daemon_ethernet_name
	call	cyjon_process_init_daemon

	; uruchom demona - protokół arp
	movzx	rcx,	byte [variable_daemon_arp_name_count]
	mov	rdx,	daemon_arp
	mov	rsi,	variable_daemon_arp_name
	call	cyjon_process_init_daemon

	; uruchom demona - protokół icmp
	movzx	rcx,	byte [variable_daemon_icmp_name_count]
	mov	rdx,	daemon_icmp
	mov	rsi,	variable_daemon_icmp_name
	call	cyjon_process_init_daemon

	; uruchom demona - protokół tcp
	movzx	rcx,	byte [variable_daemon_tcp_name_count]
	mov	rdx,	daemon_tcp
	mov	rsi,	variable_daemon_tcp_name
	call	cyjon_process_init_daemon

	; uruchom pierwszy proces "init"
	mov	rcx,	qword [files_table]	; ilość znaków w nazwie pliku
	mov	rsi,	files_table + ( VARIABLE_QWORD_SIZE * 0x04 )	; wskaźnik do nazwy pliku
	xor	rdx,	rdx	; brak argumentów
	xor	rdi,	rdi	; ^
	call	cyjon_process_init

%include	"engine/elive.asm"
%include	"engine/screen.asm"
%include	"engine/binary_memory_map.asm"
%include	"engine/paging.asm"
%include	"engine/global_descriptor_table.asm"
%include	"engine/interrupt_descriptor_table.asm"
%include	"engine/multitasking.asm"
%include	"engine/programmable_interrupt_controller.asm"
%include	"engine/programmable_interval_timer.asm"
%include	"engine/virtual_file_system.asm"
%include	"engine/keyboard.asm"
%include	"engine/services.asm"
%include	"engine/process.asm"
%include	"engine/network.asm"

%include	"engine/variables.asm"

%include	"engine/daemon/daemon_garbage_collector.asm"
%include	"engine/daemon/daemon_ethernet.asm"
%include	"engine/daemon/daemon_arp.asm"
%include	"engine/daemon/daemon_icmp.asm"
%include	"engine/daemon/daemon_tcp.asm"

%include	"engine/drivers/pci.asm"
%include	"engine/drivers/network/i8254x.asm"

; wczytaj lokalizacje jądra systemu
%push
	%defstr		%$kernel_locale			VARIABLE_KERNEL_LOCALE
	%strcat		%$include_kernel_locale,	"locale/", %$kernel_locale, ".asm"
	%include	%$include_kernel_locale
%pop

%include	"library/align_address_up_to_page.asm"
%include	"library/find_free_bit.asm"
%include	"library/compare_string.asm"

; wskaźnik końca kodu jądra wyrównaj do pełnego adresu strony
align	0x1000

; wszystkie dołączone programy zostaną zarejestrowane w wirtualnym systemie plików jądra systemu
; a poniższa przestrzeń zwolniona
%include	"engine/software.asm"

; koniec kodu jądra systemu
kernel_end:
