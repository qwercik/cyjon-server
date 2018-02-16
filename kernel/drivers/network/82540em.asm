;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

driver_variable_nic_82540em_mmio		dq	EMPTY
driver_variable_nic_82540em_irq			db	EMPTY
driver_variable_nic_82540em_rx			dq	EMPTY
driver_variable_nic_82540em_tx			dq	EMPTY
driver_variable_nic_82540em_mac			dq	EMPTY

driver_variable_nic_82540em_promiscious_mode	db	FALSE

;===============================================================================
kernel_nic_82540em_irq:
	; wyłącz przerwania
	cli

	; zachowaj oryginalne rejestry
	push	rax
	push	rcx
	push	rsi
	push	rdi

	; pobierz status kontrolera
	mov	rdi,	qword [driver_variable_nic_82540em_mmio]
	mov	eax,	dword [rdi + NIC_82540EM_ICR]

;	jeszcze nie wysyłamy pakietów
;
;	; przerwanie wywołane przez pakiet wysyłany?
;	bt	eax,	NIC_82540EM_ICR_TXDW
;	jc	.transfer	; tak

	; przerwanie wywołane przez pakiet przychodzący?
	bt	eax,	NIC_82540EM_ICR_RXT0
	jnc	.end	; nie

	; pobierz z deskryptora pakietów przychodzących interfejsu sieciowego adres bufora przechowującego pakiet
	mov	rsi,	qword [driver_variable_nic_82540em_rx]
	mov	rsi,	qword [rsi]

	; odbieramy wszystkie pakiety? (nie interesuje nas do kogo były kierowane)
	cmp	byte [driver_variable_nic_82540em_promiscious_mode],	TRUE
	je	.receive	; tak

	; pobierz adres MAC z ramki Ethernet (docelowy)
	mov	eax,	dword [rsi + NETWORK_FRAME_ETHERNET_FIELD_TARGET + NETWORK_STRUCTURE_MAC.2]
	shl	rax,	MOVE_AX_TO_HIGH
	or	ax,	word [rsi + NETWORK_FRAME_ETHERNET_FIELD_TARGET]

	; czy pakiet jest skierowany do każdego?
	mov	rcx,	NETWORK_MAC_mask
	cmp	rax,	rcx	; NASM ERROR, jeśli wstawić tu NETWORK_MAC_mask
	je	.receive	; tak

	; czy pakiet jest skierowany do nas?
	cmp	rax,	qword [driver_variable_nic_82540em_mac]
	jne	.receive_end	; nie

.receive:
	; demon Ethernet jest gotowy?
	cmp	byte [daemon_variable_ethernet_semaphore],	FALSE
	je	.receive_end	; nie, zignoruj pakiet

	; cdn.

.receive_end:
	; poinformuj kontroler o zakończeniu przetwarzania pakietu
	mov	rdi,	qword [driver_variable_nic_82540em_mmio]
	mov	dword [rdi + NIC_82540EM_RDH],	FALSE
	mov	dword [rdi + NIC_82540EM_RDT],	TRUE

.end:
	; poinformuj kontroler PIC o obsłużeniu przerwania
	mov	cl,	byte [driver_variable_nic_82540em_irq]
	call	kernel_pic_accept

	; przywróć oryginalne rejestry
	pop	rdi
	pop	rsi
	pop	rcx
	pop	rax

	; włącz przerwania
	sti

	; powrót z przerwania sprzętowego
	iretq
