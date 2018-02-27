;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

	; przygotuj komunikat błędu
	mov	si,	zero_error_cpu_text

	; sprawdź czy procesor obsługuje tryb 64 bitowy
	mov	eax,	0x80000000
	cpuid

	; spradź czy istnieją procedury powyżej 80000000h
	cmp	eax,	0x80000000
	jbe	error	; nie

	; pobierz informacje o procesorze i poszczególnych funkcjach
	mov	eax,	0x80000001
	cpuid

	; sprawdź 29 bit "lm" LongMode
	bt	edx,	29
	jnc	error	; brał obsługi "lm"
