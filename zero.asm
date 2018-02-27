;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

; zmienne, stałe, sposób kompilacji
%include "zero/config.asm"

; 16 bitowy kod programu rozruchowego
[BITS 16]

; wszystkie odwołania do etykiet po adresie bezpośrednim
[DEFAULT ABS]

; położenie kodu programu rozruchowego w pamięci fizycznej
[ORG 0x7E00]

zero:
	; wyczyść ekran inicjalizując ponownie tryb tekstowy 80x25
	mov	ax,	0x0003
	int	0x10

; włączyć 64 bitowy tryb procesora?
%if ZERO_PROTECTED_MODE_semaphore = 0
	;-----------------------------------------------------------------------
	; sprawdź typ procesora
	;-----------------------------------------------------------------------
	%include "zero/cpu.asm"
%endif

; włączyć spersonalizowaną czcionkę?
%if ZERO_FONT_CUSTOM_semaphore = 1
	;-----------------------------------------------------------------------
	; wczytaj spersonalizowaną macierz czcionki
	;-----------------------------------------------------------------------
	%include "zero/font.asm"
%endif

	;-----------------------------------------------------------------------
	; odblokuj dostęp do pamięci fizycznej powyżej 1 MiB
	;-----------------------------------------------------------------------
	%include "zero/a20.asm"

	;-----------------------------------------------------------------------
	; utwórz mapę pamięci
	;-----------------------------------------------------------------------
	%include "zero/memory.asm"

; włączyć spersonalizowaną czcionkę?
%if ZERO_VIDEO_MODE_semaphore = 1
	;-----------------------------------------------------------------------
	; przełącz ekran w tryb graficzny
	;-----------------------------------------------------------------------
	%include "zero/video.asm"
%endif

	;-----------------------------------------------------------------------
	; przełącz procesor w tryb 32 bitowy
	;-----------------------------------------------------------------------
	%include "zero/protected_mode.asm"

	;-----------------------------------------------------------------------
	; procedura obsługująca wyświetlanie błędów w trybie 16 bitowym
	;-----------------------------------------------------------------------
	%include "zero/error.asm"

	;-----------------------------------------------------------------------
	; zmienne, tablice
	;-----------------------------------------------------------------------
	%include "zero/data.asm"

	;-----------------------------------------------------------------------
	; dołącz lokalizacje
	;-----------------------------------------------------------------------
	%push
	%defstr		%$zero_locale			ZERO_LOCALE
	%defstr		%$zero_charset			ZERO_CHARSET
	%strcat		%$include_system_locale,	"zero/locale/", %$zero_locale, ".", %$zero_charset, ".asm"
	%include	%$include_system_locale
	%pop

; 32 bitowy kod programu rozruchowego
[BITS 32]

protected_mode:
	; ustaw deskryptory danych, ekstra i stosu
	mov	ax,	0x10
	mov	ds,	ax	; deskryptor danych
	mov	es,	ax	; deskryptor ekstra
	mov	ss,	ax	; deskryptor stosu

; włączyć 64 bitowy tryb procesora?
%if ZERO_PROTECTED_MODE_semaphore = 0
	;-----------------------------------------------------------------------
	; utwórz stronicowanie na potrzeby trybu 64 bitowego
	;-----------------------------------------------------------------------
	%include "zero/page.asm"

	;-----------------------------------------------------------------------
	; przełącz procesor w tryb 64 bitowy
	;-----------------------------------------------------------------------
	%include "zero/long_mode.asm"

; 64 bitowy kod programu rozruchowego
[BITS 64]

long_mode:
%endif

	; kopiuj kod jądra systemu w prawidłowe miejsce
	mov	ecx,	kernel_end - kernel
	mov	esi,	kernel
	mov	edi,	0x00100000
	rep	movsb

	; wyczyść wszystkie zbędne rejestry
	; (przekaż czyste środowisko pracy)
	xor	eax,	eax
	mov	ebx,	ZERO_MEMORY_MAP_address	; zwróć informacje o adresie mapy pamięci
	xor	ecx,	ecx
	xor	edx,	edx
; włączono tryb graficzny?
%if ZERO_VIDEO_MODE_semaphore = 1
	mov	esi,	ZERO_SUPERVGA_address	; zwróć informacje o adresie tablicy SuperVGA
%else
	xor	esi,	esi
%endif
	xor	edi,	edi
	xor	ebp,	ebp

; włączono 64 bitowy tryb procesora?
%if ZERO_PROTECTED_MODE_semaphore = 0
	xor	r8,	r8
	xor	r9,	r9
	xor	r10,	r10
	xor	r11,	r11
	xor	r12,	r12
	xor	r13,	r13
	xor	r14,	r14
	xor	r15,	r15
%endif

	; daleki skok do kodu jądra systemu, przekazujemy pałeczkę
	jmp	0x00100000

; dołącz kod jądra systemu
kernel:
	incbin "build\kernel"
kernel_end:

; koniec programu rozruchowego =================================================
