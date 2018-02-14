;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

driver_variable_nic_82540em_mmio		dq	EMPTY
driver_variable_nic_82540em_irq		db	EMPTY
driver_variable_nic_82540em_rx		dq	EMPTY
driver_variable_nic_82540em_tx		dq	EMPTY
driver_variable_nic_82540em_mac		dq	EMPTY

;===============================================================================
kernel_nic_82540em_irq:
	; zachowaj oryginalne rejestry
	push	rax
	push	rcx
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

	; jeszcze nie odbieramy pakietów

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
	pop	rcx
	pop	rax

	; powrót z przerwania sprzętowego
	iretq
