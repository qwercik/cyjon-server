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

variable_network_mac_filter					dq	0x0000FFFFFFFFFFFF

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
; procedura odbiera ramki ethernet od karty sieciowej
; i zapisuje do bufora demona ethernet
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
	jc	.transfer

	; przerwanie wywołane poprzez przychodzący pakiet? (RX)
	bt	eax,	7
	jc	.receive

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

.transfer:
	; czy wystąpiło jednocześnie wysłanie pakietu?
	bt	eax,	7
	jnc	.end	; nie

; debug
; 0x102000
align 0x0100

.receive:
	push	rax
	push	rbx
	push	rcx
	push	rdx
	push	rsi
	push	rdi

	; adres przestrzeni cache karty sieciowej
	mov	rsi,	qword [variable_network_i8254x_rx_cache]

	; ramka typu ARP
	cmp	word [rsi + 0x0C],	0x0608
	je	.arp

.rx_end:
	pop	rdi
	pop	rsi
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

	; pakiet obsłużony
	jmp	.end

.arp:
	; Hardware Type / HTYPE
	cmp	word [rsi + 0x0E],	0x0100
	jne	.rx_end

	; Protocol Type / PTYPE
	cmp	word [rsi + 0x0E + 0x02],	0x0008
	jne	.rx_end

	; Hardware Length / HLEN
	cmp	byte [rsi + 0x0E + 0x04],	0x06
	jne	.rx_end

	; Protocol Length / PLEN
	cmp	byte [rsi + 0x0E + 0x05],	0x04
	jne	.rx_end

	; załaduj ramkę do bufora
	mov	rdi,	qword [variable_daemon_ethernet_table_rx_64]

	; ilość rekordów
	mov	rcx,	VARIABLE_MEMORY_PAGE_SIZE / 64

.arp_loop:
	; koniec tablicy?
	cmp	rcx,	VARIABLE_EMPTY
	je	.rx_end	; porzuć ramkę

	; pusty rekord
	cmp	qword [rdi],	VARIABLE_EMPTY
	je	.arp_found

	; następny rekord
	add	rdi,	0x40
	loop	.arp_loop

.arp_found:
	; rozmiar ramki 26 (ARP) + 2 (EtherType) + 12 (adresy MAC) Bajtów
	mov	rax,	0x28
	stosq

	; kopiuj ramkę
	mov	rcx,	rax
	rep	movsb

	; koniec obsługi
	jmp	.rx_end
