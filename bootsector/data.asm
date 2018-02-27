;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

text_stage1_error_cpu	db	0x0A, "Unsupported CPU.", 0x00
text_stage1_error_bios	db	0x0A, "Unsupported BIOS.", 0x00
text_stage1_error_read	db	0x0A, "Read error.",	0x00

; jeśli dołączony plik jądra do programu rozruchowego przekracza limit rozmiaru
; wyświetl komunikat i przerwij kompilacje
%if (STATIC_ZERO_END_ADDRESS - STATIC_ZERO_START_ADDRESS) > (603 * STATIC_KIB_SIZE)
	%error Attached kernel file exceeds size limit of 603 KiB.
%endif

; wylicz ilość sektorów do załadowania
%assign STATIC_ZERO_SIZE	((STATIC_ZERO_END_ADDRESS - STATIC_ZERO_START_ADDRESS) / STATIC_SECTOR_SIZE)

; jeśli wynik operacji posiada resztę z dzielenia, koryguj wynik
%if (STATIC_ZERO_END_ADDRESS - STATIC_ZERO_START_ADDRESS) % STATIC_SECTOR_SIZE > 0
	; koryguj wynik
	%assign	STATIC_ZERO_SIZE STATIC_ZERO_SIZE + 0x01
%endif

table_disk_address_packet:
	db	0x10	; rozmiar tablicy
	db	0x00	; wartość zarezerwowana
	dw	STATIC_ZERO_SIZE	; ilość sektorów do wczytania
	; gdzie zapisać odczytane dane
	dw	STATIC_ZERO_BASE_ADDRESS	; przesunięcie
	dw	0x0000	; segment
	; stage1 znajduje się w sektorze "0"
	dq	0x0000000000000001	; stage2, sektor "1"
