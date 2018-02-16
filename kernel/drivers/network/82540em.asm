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
	push	rbx
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

	; zwiększ licznik pakietów przychodzących
	inc	qword [kernel_network_rx_count]

	; pobierz z deskryptora pakietów przychodzących interfejsu sieciowego adres bufora przechowującego pakiet
	mov	rbx,	qword [driver_variable_nic_82540em_rx]
	mov	rbx,	qword [rbx]

	; odbieramy wszystkie pakiety? (nie interesuje nas do kogo były kierowane)
	cmp	byte [driver_variable_nic_82540em_promiscious_mode],	TRUE
	je	.receive	; tak

	; pobierz adres MAC z ramki Ethernet (docelowy)
	mov	eax,	dword [rbx + NETWORK_FRAME_ETHERNET_FIELD_TARGET + NETWORK_STRUCTURE_MAC.2]
	shl	rax,	MOVE_AX_TO_HIGH
	or	ax,	word [rbx + NETWORK_FRAME_ETHERNET_FIELD_TARGET]

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

	; odszukaj wolne miejsce w buforze demona ethernet
	mov	rsi,	qword [daemon_variable_ethernet_cache]
	mov	rcx,	(DAEMON_ETHERNET_CACHE_size * KERNEL_PAGE_SIZE_byte) >> DIVIDE_BY_8_shift

.search:
	; koniec bufora?
	dec	rcx
	js	.receive_end	; tak, porzuć pakiet

	; wolne miejsce w buforze?
	cmp	qword [rsi + rcx * QWORD_SIZE_byte],	EMPTY
	jne	.search	; nie, szukaj dalej

	; przygotuj miejsce pod pakiet
	call	kernel_page_request
	jc	.receive_end	; brak miejsca, porzuć pakiet

	; do demona ethernet przekazujemy tylko pakiety zawierające ramki ARP lub IP
	; limit ten zostanie zniesiony, gdy demon ethernet będzie potrawił więcej

	; domyślny rozmiar pakietu zawierającego ramkę ARP
	mov	rcx,	NETWORK_FRAME_ARP_SIZE + NETWORK_FRAME_ETHERNET_SIZE

	; pakiet zawiera ramkę typu ARP?
	cmp	word [rbx + NETWORK_FRAME_ETHERNET_FIELD_TYPE],	NETWORK_FRAME_ETHERNET_FIELD_TYPE_ARP
	je	.load	; tak, załaduj do bufora

	; pakiet zawiera ramkę typu IP?
	cmp	word [rbx + NETWORK_FRAME_ETHERNET_FIELD_TYPE],	NETWORK_FRAME_ETHERNET_FIELD_TYPE_IP
	jne	.receive_end	; nie, porzuć pakiet

	; ustal rozmiar pakietu
	movzx	rcx,	word [rbx + NETWORK_FRAME_ETHERNET_SIZE + NETWORK_FRAME_IP_FIELD_TOTAL_LENGTH]
	rol	cx,	REPLACE_AL_WITH_HIGH
	add	rcx,	NETWORK_FRAME_ETHERNET_SIZE

	; jeśli pakiet nie przekracza limitu obśługiwanego rozmiaru, załaduj do bufora demona ethernet
	cmp	rcx,	KERNEL_PAGE_SIZE_byte
	ja	.receive_end	; limit przekroczony, porzuć pakiet

.load:
	; zachowaj wskaźnik wpisu w buforze demona ethernet i wskaźnik docelowy pakietu
	push	rsi
	push	rdi

	; kopiuj pakiet
	mov	rsi,	rbx
	rep	movsb

	; przywróć obydwa wskaźniki
	pop	rdi
	pop	rsi

	; poinformuj demona ethernet o przekazanym pakiecie
	mov	qword [rsi],	rdi

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
	pop	rbx
	pop	rax

	; włącz przerwania
	sti

	; powrót z przerwania sprzętowego
	iretq
