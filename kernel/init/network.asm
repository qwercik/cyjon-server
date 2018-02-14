;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

	; przeszukaj magistrale PCI za kontrolerem sieci
	mov	eax,	0x0200
	call	kernel_pci_find
	jc	network_end	; nie znaleziono

	; pobierz producenta i model
	mov	eax,	PCI_REGISTER_VENDOR_AND_DEVICE
	call	kernel_pci_read

	; kontroler typu 82540EM?
	cmp	eax,	0x100E8086
	jne	network_end	; nie

	; inicjalizuj kontroler
	call	driver_nic_82540em

	; podłącz procedurę obsługi kontrolera sieciowego
	movzx	rax,	byte [driver_variable_nic_82540em_irq]
	add	al,	KERNEL_IDT_IRQ_HARDWARE_offset
	mov	rbx,	KERNEL_IDT_TYPE_IRQ
	mov	rdi,	kernel_nic_82540em_irq
	call	kernel_idt_mount

	; odblokuj przerwanie kontrolera sieciowego na kontrolerze PIC
	movzx	rcx,	byte [driver_variable_nic_82540em_irq]
	call	kernel_pic_enable

	; włącz przerwania kontrolera
	; dokumentacja, strona 311/410, podpunkt 13.4.20
	mov	rdi,	qword [driver_variable_nic_82540em_mmio]
	mov	dword [rdi + NIC_82540EM_IMS],	00000000000000011111011011011111b

	; zatrzymaj dalsze wykonywanie kodu
	jmp	network_end

	;-----------------------------------------------------------------------
	; sterownik kontrolera Intel 82540EM
	;-----------------------------------------------------------------------
	%include "kernel/init/drivers/network/82540em.asm"
