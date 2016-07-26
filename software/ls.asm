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

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; CAŁY SYSTEM PLIKÓW DO PRZEPISANIA
; WIĘC PROGRAM TEŻ ULEGNIE ZMIANIE
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

; zestaw imiennych wartości stałych jądra systemu
%include	'config.asm'

%define	VARIABLE_PROGRAM_NAME		ls
%define	VARIABLE_PROGRAM_NAME_CHARS	2
%define	VARIABLE_PROGRAM_VERSION	"v0.1"

struc	ENTRY
	.knot_id			resq	1
	.file_size			resq	1
	.chars				resq	1
	.name				resb	1
endstruc

VARIABLE_ENTRY_TYPE_FILE	equ	0x8000
VARIABLE_ENTRY_TYPE_DIR		equ	0x4000

; 64 Bitowy kod programu
[BITS 64]

; adresowanie względne (skoki, etykiety)
[DEFAULT REL]

; adres kodu programu w przestrzeni logicznej
[ORG VARIABLE_MEMORY_HIGH_REAL_ADDRESS]

start:
	; załaduj katalog główny na koniec programu
	mov	rdi,	end

	; wczytaj plik katalog główny
	mov	ax,	VARIABLE_KERNEL_SERVICE_VFS_DIR_ROOT
	int	STATIC_KERNEL_SERVICE

	xchg	bx,bx

	; przystępujemy do wyświetlenia zawartości

	; ustaw dane przerwania
	mov	ax,	VARIABLE_KERNEL_SERVICE_SCREEN_PRINT_STRING	; al - narzędzia ekranu, ah - procedura - wyświetl ciąg tekstu znajdujący się pod adresem logicznym w rejestrze rsi, zakończony terminatorem (0x00)

	; oblicz koniec "tablicy" katalogu głównego użyszkodnika
	add	rdx,	rdi

	; ustaw wskaźnik poczatku tablicy
	mov	rsi,	rdi

.loop:
	; sprawdź czy koniec rekordów
	cmp	qword [rsi + ENTRY.file_size],	VARIABLE_EMPTY
	je	.end

	; pobierz rozmiar nazwy pliku w znakach
	movzx	rcx,	byte [rsi + ENTRY.chars]

	; załaduj kolor dla zwykłego pliku
	mov	ebx,	VARIABLE_COLOR_DEFAULT

	push	rdx
	push	rsi

	mov	edx,	VARIABLE_COLOR_BACKGROUND_DEFAULT

	; przesuń wskaźnik na ciąg znaków przedstawiający nazwe pliku
	add	rsi,	ENTRY.name
	int	STATIC_KERNEL_SERVICE	; wykonaj

	; wyświetl odstęp pomięczy nazwami
	mov	cl,	VARIABLE_FULL	; wyświetl wszystkie znaki z ciągu zakończonego terminatorem
	mov	rsi,	text_separate
	int	STATIC_KERNEL_SERVICE

	pop	rsi
	pop	rdx

.leave:
	; przesuń wskaźnik na następny rekord
	add	rsi,	56

	; wyświetl pozostałe pliki zawarte w tablicy
	jmp	.loop

.end:
	; zakończ wyświetlanie zawartości katalogu głównego użyszkodnika nową linią i karetką
	mov	edx,	VARIABLE_COLOR_BACKGROUND_DEFAULT
	mov	rsi,	text_new_line
	int	STATIC_KERNEL_SERVICE	; wykonaj

	; program kończy działanie
	mov	ax,	VARIABLE_KERNEL_SERVICE_PROCESS_END
	int	STATIC_KERNEL_SERVICE	; wykonaj

%include	'library/find_first_word.asm'
%include	'library/compare_string.asm'

variable_semaphore_all	db	VARIABLE_EMPTY

text_separate	db	'  ', VARIABLE_ASCII_CODE_TERMINATOR
text_new_line	db	VARIABLE_ASCII_CODE_ENTER, VARIABLE_ASCII_CODE_NEWLINE, VARIABLE_ASCII_CODE_TERMINATOR

end:
