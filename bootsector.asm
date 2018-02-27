;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

; zmienne, stałe, struktury
%include "bootsector/config.asm"

; 16 bitowy kod programu rozruchowego
[BITS 16]

; wszystkie odwołania do etykiet po adresie bezpośrednim
[DEFAULT ABS]

; położenie kodu programu rozruchowego w pamięci fizycznej
[ORG STATIC_BOOTSECTOR_BASE_ADDRESS]

;===============================================================================
bootsector:
	; wyłącz przerwania
	cli

	; ustaw adres segmentu kodu (CS) na początek pamięci fizycznej (0x0000), jeśli był nieprawidłowy (np. 0x07C0)
	jmp	0x0000:.repair_cs

.repair_cs:
	; ustaw adresy segmentów danych, ekstra i stosu na początek pamięci fizycznej
	xor	ax,	ax
	mov	ds,	ax	; segment danych
	mov	es,	ax	; segment ekstra
	mov	ss,	ax	; segment stosu

	; ustaw wskaźnik szczytu stosu na gwarantowaną wolną przestrzeń pamięci
	; a zarazem na początku wczytywanego programu rozruchowego (stage2)
	mov	sp,	STATIC_BOOTSECTOR_STACK_ADDRESS

	; włącz przerwania
	sti

	; wyłącz flagę DF
	cld

	;-----------------------------------------------------------------------
	; wczytaj drugą część programu rozruchowego
	;-----------------------------------------------------------------------
%include "bootsector/load.asm"

	;-----------------------------------------------------------------------
	; procedura obsługująca wyświetlanie błędów
	;-----------------------------------------------------------------------
%include "zero/error.asm"

	;-----------------------------------------------------------------------
	; dołącz zmienne i tablice sektora rozruchowego
	;-----------------------------------------------------------------------
%include "bootsector/data.asm"

; uzupełniamy niewykorzystaną przestrzeń
times	510 - ( $ - $$ )	db	0x00

; znacznik sektora rozruchowego
dw	0xAA55	; czysta magija ;>

; łączymy program rozruchowy w całość
zero: incbin "build/zero"
zero_end:

; wyrównaj kod programu rozruchowego do pełnego sektora
align	STATIC_SECTOR_SIZE
