; Copyright (C) 2013-2015 Wataha.net
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

; 64 Bitowy kod programu
[BITS 64]

struc VARIABLE_TABLE_SERPENTINE_RECORD
	.PID		resq	1
	.CR3		resq	1
	.RSP		resq	1
	.FLAGS		resq	1
	.NAME		resb	32
	.ARGS		resq	1
	.SIZE		resb	1
endstruc

; następny wolny numer PID procesu
variable_multitasking_pid_value_next				dq	VARIABLE_EMPTY

variable_multitasking_serpentine_blocked			db	VARIABLE_EMPTY
variable_multitasking_serpentine_start_address			dq	VARIABLE_EMPTY
variable_multitasking_serpentine_record_active_address		dq	VARIABLE_EMPTY
variable_multitasking_serpentine_record_counter			dq	VARIABLE_EMPTY
variable_multitasking_serpentine_record_counter_left_in_page	dq	VARIABLE_EMPTY
variable_multitasking_serpentine_record_counter_handle		dq	VARIABLE_EMPTY

;===============================================================================
; procedura tworzy i dodaje jądro systemu do tablicy procesów uruchomionych
; IN:
;	brak
; OUT:
;	brak
;
; wszystkie rejestry zachowane
multitasking:
	push	rax
	push	rdi

	; przygotuj przestrzeń pod serpentynę procesów
	call	cyjon_page_allocate
	call	cyjon_page_clear

	mov	qword [variable_multitasking_serpentine_start_address],	rdi

	; utwórz pierwszy rekord w serpentynie procesów, czyli jądro systemu

	mov	qword [variable_multitasking_serpentine_record_active_address],	rdi

	mov	rax,	qword [variable_multitasking_pid_value_next]
	stosq

	; załaduj do rekordu adres tablicy PML4 jądra systemu
	mov	rax,	cr3
	stosq

	; przy pierwszym przełączeniu procesów, zostanie uzupełniony poprawną wartością
	add	rdi,	0x08	; pomiń

	; FLAGI:
	;	111b
	;	|||
	;	||rekord zajęty, 0 pusty
	;	|proces aktywny, 0 uśpiony
	;	proces zakończony, 0 działający

	; zapisz flagi procesu
	mov	rax,	11b	; rekord aktywny, zajęty
	stosq

	; ustaw nazwę procesu
	mov	al,	"k"
	stosb
	mov	al,	"e"
	stosb
	mov	al,	"r"
	stosb
	mov	al,	"n"
	stosb
	mov	al,	"e"
	stosb
	mov	al,	"l"
	stosb

	inc	qword [variable_multitasking_serpentine_record_counter]
	inc	qword [variable_multitasking_serpentine_record_counter_left_in_page]
	inc	qword [variable_multitasking_serpentine_record_counter_handle]
	inc	qword [variable_multitasking_pid_value_next]

	pop	rdi
	pop	rax

	ret

;===============================================================================
; procedura przełącza procesor na następny proces, poprzedni stan procesora zostanie zachowany na stosie kontekstu poprzedniego procesu
; IN:
;	brak
; OUT:
;	brak
;
; wszystkie rejestry zachowane
irq32:
	cli

	push	rax
	push	rbx
	push	rcx
	push	rdx
	push	rsi
	push	rdi
	push	rbp

	; rejestr RSP został już zachowany poprzez wywołanie przerwania sprzętowego IRQ0
	; push	rsp

	push	r8
	push	r9
	push	r10
	push	r11
	push	r12
	push	r13
	push	r14
	push	r15

	pushfq

	inc	qword [variable_system_microtime]

	mov	rdi,	qword [variable_multitasking_serpentine_record_active_address]
	mov	qword [rdi + VARIABLE_TABLE_SERPENTINE_RECORD.RSP],	rsp

	mov	rcx,	qword [variable_multitasking_serpentine_record_counter_left_in_page]
	mov	rdx,	qword [variable_multitasking_serpentine_record_counter_handle]

.loop:
	; flaga ACTIVE
	xor	bx,	bx

	call	cyjon_multitasking_serpentine_find_record.next_record

	inc	bx
	bt	word [rdi + VARIABLE_TABLE_SERPENTINE_RECORD.FLAGS],	bx
	jnc	.loop

.found:
	mov	qword [variable_multitasking_serpentine_record_counter_left_in_page],	rcx
	mov	qword [variable_multitasking_serpentine_record_counter_handle],	rdx
	mov	qword [variable_multitasking_serpentine_record_active_address],	rdi

	mov	rsp,	qword [rdi + VARIABLE_TABLE_SERPENTINE_RECORD.RSP]
	mov	rax,	qword [rdi + VARIABLE_TABLE_SERPENTINE_RECORD.CR3]
	mov	cr3,	rax

	mov	al,	0x20
	out	0x20,	al

	popfq

	pop	r15
	pop	r14
	pop	r13
	pop	r12
	pop	r11
	pop	r10
	pop	r9
	pop	r8

	; rejestr RSP zostanie przywrócony po zakończeniu przerwania sprzętowego IRQ0
	; pop	rsp

	pop	rbp
	pop	rdi
	pop	rsi
	pop	rdx
	pop	rcx
	pop	rbx
	pop	rax

	sti

	iretq

cyjon_multitasking_serpentine_find_record:
	mov	rdi,	qword [variable_multitasking_serpentine_start_address]

	mov	rcx,	( VARIABLE_MEMORY_PAGE_SIZE - 0x08 ) / VARIABLE_TABLE_SERPENTINE_RECORD.SIZE
	mov	rdx,	qword [variable_multitasking_serpentine_record_counter]

	jmp	.do_not_leave_me

.next_record:
	dec	rcx
	dec	rdx

	; przesuń na następny rekord
	add	rdi,	VARIABLE_TABLE_SERPENTINE_RECORD.SIZE

.do_not_leave_me:
	cmp	rdx,	VARIABLE_EMPTY
	ja	.left_something

	mov	rdi,	qword [variable_multitasking_serpentine_start_address]

	mov	rcx,	( VARIABLE_MEMORY_PAGE_SIZE - 0x08 ) / VARIABLE_TABLE_SERPENTINE_RECORD.SIZE
	mov	rdx,	qword [variable_multitasking_serpentine_record_counter]

	jmp	.in_page

.left_something:
	cmp	rcx,	VARIABLE_EMPTY
	ja	.in_page

	and	di,	0xF000
	mov	rdi,	qword [rdi + 0x0FF8]

	mov	rcx,	( VARIABLE_MEMORY_PAGE_SIZE - 0x08 ) / VARIABLE_TABLE_SERPENTINE_RECORD.SIZE

.in_page:
	bt	word [rdi + VARIABLE_TABLE_SERPENTINE_RECORD.FLAGS],	bx
	jnc	.next_record

	ret
