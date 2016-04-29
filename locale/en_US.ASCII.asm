; Copyright (C) 2013-2016 Wataha.net
; All Rights Reserved
;
; LICENSE Creative Commons BY-NC-ND 4.0
; See LICENSE.TXT
;
; Main developer:
;	Andrzej (akasei) Adamczyk [e-mail: akasei from wataha.net]
;-------------------------------------------------------------------------------

%define	VARIABLE_PANIC	VARIABLE_ASCII_CODE_ENTER, VARIABLE_ASCII_CODE_NEWLINE, "System halted.", VARIABLE_ASCII_CODE_TERMINATOR

; Use:
; nasm - http://www.nasm.us/

text_kernel_welcome				db	"Running Cyjon OS!", VARIABLE_ASCII_CODE_ENTER, VARIABLE_ASCII_CODE_NEWLINE, VARIABLE_ASCII_CODE_TERMINATOR

; błędy jądra systemu
text_kernel_panic_binary_memory_map_fail	db	"Failed to create Binary Memory Map.", VARIABLE_PANIC
text_kernel_panic_cpu_interrupt			db	"Unhandled CPU interrupt.", VARIABLE_PANIC
text_kernel_panic_hardware_interrupt		db	"Unhandled Hardware interrupt.", VARIABLE_PANIC
text_kernel_panic_software_interrupt		db	"Process break, closed.", VARIABLE_ASCII_CODE_ENTER, VARIABLE_ASCII_CODE_NEWLINE, VARIABLE_ASCII_CODE_TERMINATOR
text_kernel_panic_gdt				db	"No free memory for GDT table.", VARIABLE_PANIC
text_kernel_panic_page_pml4			db	"PML4 table overload.", VARIABLE_PANIC

; ogólne informacje
text_binary_memory_map_available_memory		db	" Available free memory: ", VARIABLE_ASCII_CODE_TERMINATOR

; informacje sterowników
text_vfs_ready					db	" Virtual File System, ready.", VARIABLE_ASCII_CODE_RETURN
text_nic_i8254x					db	" Network controller Intel 82540EM, MAC ", VARIABLE_ASCII_CODE_TERMINATOR
