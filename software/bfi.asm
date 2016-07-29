; Copyright (C) 2013-2016 Wataha.net
; All Rights Reserved
;
; LICENSE Creative Commons BY-NC-ND 4.0
; See LICENSE.TXT
;
; Main developer:
;	Darek (devport) Kwieciński [e-mail: kwiecinskidarek from gmail.com]
;
; Support:
;	Andrzej (akasei) Adamczyk [e-mail: akasei from wataha.net]
;
; Program name:
;	BFI - Brain Fuck Interpreter
;-------------------------------------------------------------------------------

; Use:
; 	bfi hello.bf
;
; nasm - http://www.nasm.us/

; zestaw imiennych wartości stałych jądra systemu
%include	'config.asm'

%define	VARIABLE_PROGRAM_NAME		bfi
%define	VARIABLE_PROGRAM_NAME_CHARS	3
%define	VARIABLE_PROGRAM_VERSION	"v0.1"

VARIABLE_BFI_TABLE_SIZE			equ	1024

; 64 Bitowy kod programu
[BITS 64]

; adresowanie względne (skoki, etykiety)
[DEFAULT REL]

; adres kodu programu w przestrzeni logicznej
[ORG VARIABLE_MEMORY_HIGH_REAL_ADDRESS]

start:
	; wyświetl powitanie
	mov	ax,	VARIABLE_KERNEL_SERVICE_SCREEN_PRINT_STRING
	mov	rbx,	VARIABLE_COLOR_DEFAULT
	mov	rcx,	VARIABLE_FULL
	mov	rdx,	VARIABLE_COLOR_BACKGROUND_DEFAULT
	mov	rsi,	text_hello
	int	STATIC_KERNEL_SERVICE
	
	; pobierz przesłane argumenty
	mov	ax,	VARIABLE_KERNEL_SERVICE_PROCESS_ARGS
	mov	rdi,	end
	call	library_align_address_up_to_page
	int	STATIC_KERNEL_SERVICE
		
	; czy argumenty istnieją?
	cmp	rcx,	VARIABLE_PROGRAM_NAME_CHARS
	jbe	.no_file_or_end

	; pomiń nazwę procesu w argumentach
	add	rdi,	VARIABLE_PROGRAM_NAME_CHARS
	sub	rcx,	VARIABLE_PROGRAM_NAME_CHARS

	; poszukaj argumentu
	call	library_find_first_word
	jc	.no_file_or_end	; brak argumentów
	
	; wczytaj plik do pamięci procesu
	mov	ax,	VARIABLE_KERNEL_SERVICE_VFS_FILE_READ
	mov	rsi,	end	; na koniec programu
	xchg	rsi,	rdi
	int	STATIC_KERNEL_SERVICE

	; zapisz rozmiar pliku w Bajtach
	mov	 qword [variable_script_size],	rcx
	
	; zapisz adres kodu zrodlowego
	mov	qword [variable_source_ptr],	rdi
	
	; ustawiam adres źródła
	xchg	rsi,	rdi
	
	; zapisz adres tablicy znaków do zmiennej Memory_ptr
	mov	rdi,	variable_memory
	mov	qword [variable_memory_ptr],	rdi
	
;------------------------------------------------------------------------------	
;
; procedura sprawdza na co wskazuje Memory_ptr w tablicy znaków
;
;------------------------------------------------------------------------------
.switch:
	
	; wczytaj znak
	lodsb
	
	; jezeli koniec to wyjdź z programu
	cmp	al,	VARIABLE_EMPTY
	je	.no_file_or_end

	cmp	al,	'>'
	je	.inc_pointer
	
	cmp	al,	'<'
	je	.dec_pointer
	
	cmp	al,	'+'
	je	.inc_memory
	
	cmp	al,	'-'
	je	.dec_memory
	
	cmp	al,	'.'
	je	.print_memory
	
	jmp	.switch
	

.inc_pointer:
	; zwiększ wskaźnik o 1
	inc	qword [variable_memory_ptr]
	
	; sprawdz kolejny znak
	jmp	.switch
	
.dec_pointer:
	;zmniejsz wskaźnik o 1
	dec	qword [variable_memory_ptr]

	; sprawdz kolejny znak
	jmp	.switch
	
.inc_memory:
	; zachowaj oryginalne rejestry
	push	rax
	push	rsi	

	; inkrementuj wartość komórki 
	mov	rsi,	qword [variable_memory_ptr]
	mov	al,	byte [rsi]
	inc	al
	mov	byte	[rsi], al
	
	; przywróć oryginalne rejestry
	pop rsi
	pop rax
	
	jmp	.switch
	
.dec_memory:
	; zachowaj oryginalne rejestry
	push	rax
	push	rsi
	
	; dekrementuj wartość komórki
	mov	rsi,	qword [variable_memory_ptr]
	mov	al,	byte [rsi]
	dec	al
	mov	byte [rsi],	al
	
	; przywróć oryginalne rejestry
	pop	rsi
	pop	rax
	
	jmp	.switch
	
.print_memory:
	; zachowaj oryginalne rejestry
	push	rax
	push	rbx
	push	rcx
	push	rdx
	push	rsi
	
	mov	rsi,	qword [variable_memory_ptr]
	; wyświetl zawartość komórki

	mov	r8b,	byte [rsi]
	mov	ax,	VARIABLE_KERNEL_SERVICE_SCREEN_PRINT_CHAR
	mov	rbx,	VARIABLE_COLOR_DEFAULT
	mov	rcx,	1	; po jednym znaku
	mov	rdx,	VARIABLE_COLOR_BACKGROUND_DEFAULT
	int	STATIC_KERNEL_SERVICE
			
	; przywróć oryginalne rejestry
	pop	rsi
	pop	rdx
	pop	rcx
	pop	rbx
	pop	rax
	
	jmp	.switch
	
;---------------------------------------------------------------------------
;
; Jeszcze nie zaimplementowana część dotycząca pętli 
;
;---------------------------------------------------------------------------
.open_parent:
	; jezeli w komórce mamy 0 pomiń instrukcje
	cmp al, 0
	jne .open_parent_1
	inc qword [variable_memory_ptr]
	jmp .switch
	
.open_parent_1:
	mov qword [variable_depth], 0x00
		
	jmp .switch
	
.no_file_or_end:
	; koniec procesu
	xor	ax,	ax
	int	STATIC_KERNEL_SERVICE
	
%include	'library/align_address_up_to_page.asm'
%include	'library/find_first_word.asm'

variable_source_ptr				dq	VARIABLE_EMPTY	; wskaźnik na dane wejściowe
variable_script_size				dq	VARIABLE_EMPTY	; rozmiar skryptu
variable_memory	times VARIABLE_BFI_TABLE_SIZE	db	VARIABLE_EMPTY	; tablica znaków
variable_memory_ptr				dq	VARIABLE_EMPTY	; wskaźnik w tablicy znaków
variable_iptr					dw	VARIABLE_EMPTY	; instruction pointer
variable_depth					dq	VARIABLE_EMPTY

; wczytaj lokalizacje programu systemu
%push
	%defstr		%$system_locale		VARIABLE_KERNEL_LOCALE
	%defstr		%$process_name		VARIABLE_PROGRAM_NAME
	%strcat		%$include_program_locale,	"software/", %$process_name, "/locale/", %$system_locale, ".asm"
	%include	%$include_program_locale
%pop

; koniec kodu programu
end:
