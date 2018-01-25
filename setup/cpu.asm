;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

	; ustaw komunikat
	mov	ecx,	text_error_cpu_long_mode_end - text_error_cpu_long_mode
	mov	esi,	text_error_cpu_long_mode

	; sprawdź czy procesor obsługuje tryb 64 bitowy
	mov	eax,	STATIC_CPUID	; pobierz numer najwyższej dostępnej procedury
	cpuid

	; spradź czy istnieją procedury powyżej 0x80000000
	cmp	eax,	STATIC_CPUID
	jbe	.kernel_panic

	; pobierz informacja o procesorze i poszczególnych funkcjach
	mov	eax,	STATIC_CPUID_EXTENDED
	cpuid

	; wspierany jest tryb 64 bitowy?
	bt	edx,	STATIC_CPUID_EXTENDED_FLAG_LM
	jnc	.kernel_panic
