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

variable_network_i8254x_base_address				dq	VARIABLE_EMPTY
variable_network_i8254x_irq					db	VARIABLE_EMPTY
variable_network_i8254x_rx_descriptor				dq	VARIABLE_EMPTY
variable_network_i8254x_rx_cache				dq	VARIABLE_EMPTY
variable_network_i8254x_tx_cache				dq	VARIABLE_EMPTY
variable_network_i8254x_mac_address				dq	VARIABLE_EMPTY

;variable_network_semaphore					db	VARIABLE_FALSE
;variable_network_tx						dq	VARIABLE_EMPTY
;variable_network_tx_appear					db	VARIABLE_EMPTY
;variable_network_rx						dq	VARIABLE_EMPTY
;variable_network_rx_appear					db	VARIABLE_EMPTY

; 64 bitowy kod
[BITS 64]

;===============================================================================
; wykrywa i inicjalizuje jedną z dostępnych kart sieciowych
; IN:
;	brak
;
; OUT:
;	brak
;
; wszystkie rejestry zachowane
network_init:
	; zachowaj oryginalne rejestry
	push	rax
	push	rbx
	push	rcx
	push	rdx

	; szukaj od początku
	xor	rbx,	rbx
	xor	rcx,	rcx
	; sprawdzaj klasę/subklasę urządzenia/kontrolera
	mov	rdx,	2

.next:
	; pobierz klasę/subklasę
	call	cyjon_pci_read

	; przesuń starszą część do młodszej
	shr	eax,	16

	; kontroler sieci?
	cmp	ax,	VARIABLE_NIC
	je	.check

.continue:
	; następne urządzenie
	inc	ecx

	; koniec urządzeń na szynie?
	cmp	ecx,	256
	jb	.next

	; następna szyna
	inc	ebx

	; zacznij przeszukiwać od początku szyny
	xor	ecx,	ecx

	; koniec szyn?
	cmp	ebx,	256
	jb	.next

.end:
	; nie znaleziono jakiegokolwiek kontrolera sieci

	; przywróć oryginalne rejestry
	pop	rdx
	pop	rcx
	pop	rbx
	pop	rax

	; powrót z procedury
	ret

.check:
	; pobierz identyfikator Firmy(Vendor) i Urządzenia(Device)
	xor	edx,	edx
	call	cyjon_pci_read

	; kontroler sieci typu i8254x?
	cmp	eax,	VARIABLE_NIC_INTEL_82540EM_PCI
	je	cyjon_network_i8254x_init

	; nieznany kontroler sieci, szukaj dalej
	jmp	.continue

.configured:
	; podłącz procedurę obsługi przerwania kontrolera sieci
	mov	rdi,	network
	call	cyjon_interrupt_descriptor_table_isr_hardware_mount

	; włącz obsługę przerwania
	mov	cx,	ax
	call	cyjon_programmable_interrupt_controller_enable_irq

	; pobierz status kontrolera sieci
	call	cyjon_network_i8254x_irq

	; koniec
	jmp	.end

;===============================================================================
; obsługa przerwania sprzętowego kontrolera sieci
; IN:
;	brak
;
; OUT:
;	brak
;
; wszystkie rejestry zachowane
align	0x0100
network:
	; zachowaj oryginalne rejestry
	push	rax
	push	rcx
	push	rsi
	pushf

	; pobierz status kontrolera
	call	cyjon_network_i8254x_irq

	; przerwanie wywołane poprzez wysyłany pakiet? (TX)
	bt	eax,	0
	jc	.tx

	; przerwanie wywołane poprzez przychodzący pakiet? (RX)
	bt	eax,	7
	jc	.rx

.end:
	; poinformuj kontroler PIC o obsłużeniu przerwania sprzętowego
	mov	al,	0x20

	; przerwane obsługiwane w trybie kaskady?
	cmp	byte [variable_network_i8254x_irq],	8
	jb	.no_cascade

	; wyślij do kontrolera "kaskadowego"
	out	VARIABLE_PIC_COMMAND_PORT1,	al

.no_cascade:
	; wyślij do kontrolera głównego
	out	VARIABLE_PIC_COMMAND_PORT0,	al

	; przywróć oryginalne rejestry
	popf
	pop	rsi
	pop	rcx
	pop	rax

	; koniec obsługi przerwania sprzętowego
	iretq

.tx:
	; zachowaj informacje o wystąpieniu przerwania
;	mov	byte [variable_network_tx_appear],	VARIABLE_TRUE

	; czy wystąpiło jednocześnie wysłanie pakietu?
	bt	eax,	7
	jnc	.end	; nie

.rx:
	push	rax
	push	rbx
	push	rcx
	push	rdx

	; czy pakiet należy do nas?
	mov	rax,	qword [variable_network_i8254x_rx_cache]
	mov	rax,	qword [rax]
	mov	rdx,	0x0000FFFFFFFFFFFF
	and	rax,	rdx
	cmp	rax,	qword [variable_network_i8254x_mac_address]
	jne	.end_of_rx

	mov	al,	"."
	mov	bl,	VARIABLE_COLOR_WHITE
	mov	rcx,	1
	mov	dl,	VARIABLE_COLOR_BACKGROUND_DEFAULT
	call	cyjon_screen_print_char

.end_of_rx:
	pop	rdx
	pop	rcx
	pop	rbx
	pop	rax

	; poinformuj kontroler o przetworzonym pakiecie
	mov	rsi,	qword [variable_network_i8254x_base_address]
	mov	dword [rsi + VARIABLE_NIC_INTEL_82540EM_RDH],	VARIABLE_EMPTY
	mov	dword [rsi + VARIABLE_NIC_INTEL_82540EM_RDT],	VARIABLE_TRUE

	; zresetuj deskryptor rx
	mov	rcx,	qword [variable_network_i8254x_rx_cache]
	mov	dword [variable_network_i8254x_rx_descriptor],	ecx

	; sprawdź czy demon sieci jest uruchomiony
;	cmp	qword [variable_daemon_network_table_rx],	VARIABLE_EMPTY
;	je	.rx	; czekaj

	; pobierz pakiet z kontrolera sieci
;	mov	rdi,	qword [variable_daemon_network_table_rx]
;	call	cyjon_network_i8254x_receive_packet

	; pakiet obsłużony
	jmp	.end
