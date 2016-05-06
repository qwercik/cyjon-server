; Copyright (C) 2013-2016 Wataha.net
; All Rights Reserved
;
; LICENSE Creative Commons BY-NC-ND 4.0
; See LICENSE.TXT
;
; Main developer:
;	Andrzej (akasei) Adamczyk [e-mail: akasei from wataha.net]
;-------------------------------------------------------------------------------

%define	VARIABLE_PANIC	VARIABLE_ASCII_CODE_ENTER, VARIABLE_ASCII_CODE_NEWLINE, "System wstrzymany.", VARIABLE_ASCII_CODE_TERMINATOR

; Use:
; nasm - http://www.nasm.us/

text_kernel_welcome				db	"Uruchamiam Cyjon OS!", VARIABLE_ASCII_CODE_ENTER, VARIABLE_ASCII_CODE_NEWLINE, VARIABLE_ASCII_CODE_TERMINATOR

; błędy jądra systemu
text_kernel_panic_binary_memory_map_fail	db	"Nie udalo sie utworzyc Binarnej Mapy Pamieci.", VARIABLE_PANIC
text_kernel_panic_cpu_interrupt			db	"CPU: Nieobsluzony wyjatek.", VARIABLE_PANIC
text_kernel_panic_hardware_interrupt		db	"CPU: Nieobsluzone przerwanie sprzetowe.", VARIABLE_PANIC
text_kernel_panic_software_interrupt		db	"CPU: Niedozwolone dzialanie.", VARIABLE_ASCII_CODE_ENTER, VARIABLE_ASCII_CODE_NEWLINE, VARIABLE_ASCII_CODE_TERMINATOR
text_kernel_panic_gdt				db	"GDT: Brak wolnej przestrzeni pamieci.", VARIABLE_PANIC
text_kernel_panic_page_pml4			db	"PML4: Przepelnienie tablicy.", VARIABLE_PANIC
text_kernel_panic_sheduler_no_memory		db	"SHEDULER: Brak wolnej przestrzeni pamieci.", VARIABLE_PANIC

; ogólne informacje
text_binary_memory_map_available_memory		db	" Dostepna wolna pamiec: ", VARIABLE_ASCII_CODE_TERMINATOR

; informacje sterowników
text_vfs_ready					db	" Wirtualny system plikow, gotowy.", VARIABLE_ASCII_CODE_RETURN
text_vfs_fail					db	"VFS: Nie mozna zainicjalizowac systemu plikow.", VARIABLE_PANIC
text_vfs_no_memory				db	"VFS: Brak wystarczajacej ilosci pamieci.", VARIABLE_PANIC
text_nic_i8254x					db	" Kontroler sieci Intel 82540EM, MAC ", VARIABLE_ASCII_CODE_TERMINATOR
