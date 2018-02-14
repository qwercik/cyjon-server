;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

NIC_82540EM_CTRL			equ	0x0000	; Control Register
NIC_82540EM_CTRL_FD			equ	0x00000001	; Full-Duplex
NIC_82540EM_CTRL_LRST			equ	0x00000008	; Link Reset
NIC_82540EM_CTRL_ASDE			equ	0x00000020	; Auto-Speed Detection Enable
NIC_82540EM_CTRL_SLU			equ	0x00000040	; Set Link Up
NIC_82540EM_CTRL_ILOS			equ	0x00000080	; Invert Loss-of-Signal (LOS).
NIC_82540EM_CTRL_SPEED_BIT_8		equ	0x00000100	; Speed selection
NIC_82540EM_CTRL_SPEED_BIT_9		equ	0x00000200	; Speed selection
NIC_82540EM_CTRL_FRCSPD			equ	0x00000800	; Force Speed
NIC_82540EM_CTRL_FRCPLX			equ	0x00001000	; Force Duplex
NIC_82540EM_CTRL_SDP0_DATA		equ	0x00040000	; SDP0 Data Value
NIC_82540EM_CTRL_SDP1_DATA		equ	0x00080000	; SDP1 Data Value
NIC_82540EM_CTRL_ADVD3WUC		equ	0x00100000	; D3Cold Wakeup Capability Advertisement Enable
NIC_82540EM_CTRL_EN_PHY_PWR_MGMT	equ	0x00200000	; PHY Power-Management Enable
NIC_82540EM_CTRL_SDP0_IODIR		equ	0x00400000	; SDP0 Pin Directionality
NIC_82540EM_CTRL_SDP1_IODIR		equ	0x00800000	; SDP1 Pin Directionality
NIC_82540EM_CTRL_RST			equ	0x04000000	; Device Reset
NIC_82540EM_CTRL_RFCE			equ	0x08000000	; Receive Flow Control Enable
NIC_82540EM_CTRL_TFCE			equ	0x10000000	; Transmit Flow Control Enable
NIC_82540EM_CTRL_VME			equ	0x40000000	; VLAN Mode Enable
NIC_82540EM_CTRL_PHY_RST		equ	0x7FFFFFFF	; NASM ERROR => 0x80000000	; PHY Reset

NIC_82540EM_STATUS			equ	0x0008	; Device Status Register
NIC_82540EM_EERD			equ	0x0014	; EEPROM Read
NIC_82540EM_CTRLEXT			equ	0x0018	; Extended Control Register
NIC_82540EM_MDIC			equ	0x0020	; MDI Control Register
NIC_82540EM_FCAL			equ	0x0028	; Flow Control Address Low
NIC_82540EM_FCAH			equ	0x002C	; Flow Control Address High
NIC_82540EM_FCT				equ	0x0030	; Flow Control Type
NIC_82540EM_VET				equ	0x0038	; VLAN Ether Type
NIC_82540EM_ICR				equ	0x00C0	; Interrupt Cause Read
NIC_82540EM_ICR_TXDW			equ	0	; Transmit Descriptor Written Back
NIC_82540EM_ICR_RXT0			equ	7	; Receiver Timer Interrupt
NIC_82540EM_ITR				equ	0x00C4	; Interrupt Throttling Register
NIC_82540EM_ICS				equ	0x00C8	; Interrupt Cause Set Register
NIC_82540EM_IMS				equ	0x00D0	; Interrupt Mask Set/Read Register
NIC_82540EM_IMC				equ	0x00D8	; Interrupt Mask Clear

NIC_82540EM_RCTL			equ	0x0100	; Receive Control Register
NIC_82540EM_RCTL_EN			equ	0x00000002	; Receiver Enable
NIC_82540EM_RCTL_SBP			equ	0x00000004	; Store Bad Packets
NIC_82540EM_RCTL_UPE			equ	0x00000008	; Unicast Promiscuaus Enabled
NIC_82540EM_RCTL_MPE			equ	0x00000010	; Multicast Promiscuous Enabled
NIC_82540EM_RCTL_LPE			equ	0x00000020	; Long Packet Reception Enable
NIC_82540EM_RCTL_LBM_BIT_6		equ	0x00000040	; Loopback mode
NIC_82540EM_RCTL_LBM_BIT_7		equ	0x00000080	; Loopback mode
NIC_82540EM_RCTL_RDMTS_BIT_8		equ	0x00000100	; Receive Descriptor Minimum Threshold Size
NIC_82540EM_RCTL_RDMTS_BIT_9		equ	0x00000200	; Receive Descriptor Minimum Threshold Size
NIC_82540EM_RCTL_MO_BIT_12		equ	0x00001000	; Multicast Offset
NIC_82540EM_RCTL_MO_BIT_13		equ	0x00002000	; Multicast Offset
NIC_82540EM_RCTL_BAM			equ	0x00008000	; Broadcast Accept Mode
NIC_82540EM_RCTL_BSIZE_2048_BYTES	equ	0x00000000	; Receive Buffer Size
NIC_82540EM_RCTL_BSIZE_1024_BYTES	equ	0x00010000	; Receive Buffer Size
NIC_82540EM_RCTL_BSIZE_512_BYTES	equ	0x00020000	; Receive Buffer Size
NIC_82540EM_RCTL_BSIZE_256_BYTES	equ	0x00030000	; Receive Buffer Size
NIC_82540EM_RCTL_VFE			equ	0x00040000	; VLAN Filter Enable
NIC_82540EM_RCTL_CFIEN			equ	0x00080000	; Canonical Form Indicator Enable
NIC_82540EM_RCTL_CFI			equ	0x00100000	; Canonical Form Indicator bit value
NIC_82540EM_RCTL_DPF			equ	0x00400000	; Discard Pause Frames
NIC_82540EM_RCTL_PMCF			equ	0x00800000	; Pass MAC Control Frames
NIC_82540EM_RCTL_BSEX			equ	0x02000000	; Receive Buffer Size multiply by 16
NIC_82540EM_RCTL_SECRC			equ	0x04000000	; Strip Ethernet CRC from incoming packet

NIC_82540EM_TXCW			equ	0x0178	; Transmit Configuration Word
NIC_82540EM_TXCW_TXCONFIGWORD_BIT_5	equ	0x00000020	; Full Duplex
NIC_82540EM_TXCW_TXCONFIGWORD_BIT_6	equ	0x00000040	; Half Duplex
NIC_82540EM_TXCW_TXCONFIGWORD_BIT_7	equ	0x00000080	; Pause
NIC_82540EM_TXCW_TXCONFIGWORD_BIT_8	equ	0x00000100	; Pause
NIC_82540EM_TXCW_TXCONFIGWORD_BIT_12	equ	0x00001000	; Remote fault indication
NIC_82540EM_TXCW_TXCONFIGWORD_BIT_13	equ	0x00002000	; Remote fault indication
NIC_82540EM_TXCW_TXCONFIGWORD_BIT_15	equ	0x00008000	; Next page request
NIC_82540EM_TXCW_TXCONFIGWORD		equ	0x40000000	; Transmit Config Control bit
NIC_82540EM_TXCW_ANE			equ	0x80000000	; Auto-Negotiation Enable

NIC_82540EM_RXCW			equ	0x0180	; Receive Configuration Word

NIC_82540EM_TCTL			equ	0x0400	; Transmit Control Register
NIC_82540EM_TCTL_EN			equ	0x00000002	; Transmit Enable
NIC_82540EM_TCTL_PSP			equ	0x00000008	; Pad Short Packets
NIC_82540EM_TCTL_CT			equ	0x00000100	; Collision Threshold
NIC_82540EM_TCTL_COLD			equ	0x00040000	; Full-Duplex – 64-byte time
NIC_82540EM_TCTL_SWXOFF			equ	0x00400000	; Software OFF Transmission
NIC_82540EM_TCTL_RTLC			equ	0x01000000	; Re-transmit on Late Collision
NIC_82540EM_TCTL_NRTU			equ	0x02000000	; No Re-transmit on underrun (82544GC/EI only)

NIC_82540EM_TIPG			equ	0x0410	; Transmit Inter Packet Gap
NIC_82540EM_TIPG_IPGT_DEFAULT		equ	0x0000000A
NIC_82540EM_TIPG_IPGT_BIT_0		equ	0x00000001	; IPG Transmit Time
NIC_82540EM_TIPG_IPGT_BIT_1		equ	0x00000002	; IPG Transmit Time
NIC_82540EM_TIPG_IPGT_BIT_2		equ	0x00000004	; IPG Transmit Time
NIC_82540EM_TIPG_IPGT_BIT_3		equ	0x00000008	; IPG Transmit Time
NIC_82540EM_TIPG_IPGT_BIT_4		equ	0x00000010	; IPG Transmit Time
NIC_82540EM_TIPG_IPGT_BIT_5		equ	0x00000020	; IPG Transmit Time
NIC_82540EM_TIPG_IPGT_BIT_6		equ	0x00000040	; IPG Transmit Time
NIC_82540EM_TIPG_IPGT_BIT_7		equ	0x00000080	; IPG Transmit Time
NIC_82540EM_TIPG_IPGT_BIT_8		equ	0x00000100	; IPG Transmit Time
NIC_82540EM_TIPG_IPGT_BIT_9		equ	0x00000200	; IPG Transmit Time
NIC_82540EM_TIPG_IPGR1_DEFAULT		equ	0x00002000
NIC_82540EM_TIPG_IPGR1_BIT_10		equ	0x00000400	; IPG Receive Time 1
NIC_82540EM_TIPG_IPGR1_BIT_11		equ	0x00000800	; IPG Receive Time 1
NIC_82540EM_TIPG_IPGR1_BIT_12		equ	0x00001000	; IPG Receive Time 1
NIC_82540EM_TIPG_IPGR1_BIT_13		equ	0x00002000	; IPG Receive Time 1
NIC_82540EM_TIPG_IPGR1_BIT_14		equ	0x00004000	; IPG Receive Time 1
NIC_82540EM_TIPG_IPGR1_BIT_15		equ	0x00008000	; IPG Receive Time 1
NIC_82540EM_TIPG_IPGR1_BIT_16		equ	0x00010000	; IPG Receive Time 1
NIC_82540EM_TIPG_IPGR1_BIT_17		equ	0x00020000	; IPG Receive Time 1
NIC_82540EM_TIPG_IPGR1_BIT_18		equ	0x00040000	; IPG Receive Time 1
NIC_82540EM_TIPG_IPGR1_BIT_19		equ	0x00080000	; IPG Receive Time 1
NIC_82540EM_TIPG_IPGR2_DEFAULT		equ	0x00600000
NIC_82540EM_TIPG_IPGR2_BIT_20		equ	0x00100000	; IPG Receive Time 2
NIC_82540EM_TIPG_IPGR2_BIT_21		equ	0x00200000	; IPG Receive Time 2
NIC_82540EM_TIPG_IPGR2_BIT_22		equ	0x00400000	; IPG Receive Time 2
NIC_82540EM_TIPG_IPGR2_BIT_23		equ	0x00800000	; IPG Receive Time 2
NIC_82540EM_TIPG_IPGR2_BIT_24		equ	0x01000000	; IPG Receive Time 2
NIC_82540EM_TIPG_IPGR2_BIT_25		equ	0x02000000	; IPG Receive Time 2
NIC_82540EM_TIPG_IPGR2_BIT_26		equ	0x04000000	; IPG Receive Time 2
NIC_82540EM_TIPG_IPGR2_BIT_27		equ	0x08000000	; IPG Receive Time 2
NIC_82540EM_TIPG_IPGR2_BIT_28		equ	0x10000000	; IPG Receive Time 2
NIC_82540EM_TIPG_IPGR2_BIT_29		equ	0x20000000	; IPG Receive Time 2

NIC_82540EM_LEDCTL			equ	0x0E00	; LED Control
NIC_82540EM_PBA				equ	0x1000	; Packet Buffer Allocation
NIC_82540EM_RDBAL			equ	0x2800	; RX Descriptor Base Address Low
NIC_82540EM_RDBAH			equ	0x2804	; RX Descriptor Base Address High
NIC_82540EM_RDLEN			equ	0x2808	; RX Descriptor Length
NIC_82540EM_RDH				equ	0x2810	; RX Descriptor Head
NIC_82540EM_RDT				equ	0x2818	; RX Descriptor Tail
NIC_82540EM_RDTR			equ	0x2820	; RX Delay Timer Register
NIC_82540EM_RXDCTL			equ	0x3828	; RX Descriptor Control
NIC_82540EM_RADV			equ	0x282C	; RX Int. Absolute Delay Timer
NIC_82540EM_RSRPD			equ	0x2C00	; RX Small Packet Detect Interrupt
NIC_82540EM_TXDMAC			equ	0x3000	; TX DMA Control
NIC_82540EM_TDBAL			equ	0x3800	; TX Descriptor Base Address Low
NIC_82540EM_TDBAH			equ	0x3804	; TX Descriptor Base Address High
NIC_82540EM_TDLEN			equ	0x3808	; TX Descriptor Length
NIC_82540EM_TDH				equ	0x3810	; TX Descriptor Head
NIC_82540EM_TDT				equ	0x3818	; TX Descriptor Tail
NIC_82540EM_TIDV			equ	0x3820	; TX Interrupt Delay Value
NIC_82540EM_TXDCTL			equ	0x3828	; TX Descriptor Control
NIC_82540EM_TADV			equ	0x382C	; TX Absolute Interrupt Delay Value
NIC_82540EM_TSPMT			equ	0x3830	; TCP Segmentation Pad & Min Threshold
NIC_82540EM_RXCSUM			equ	0x5000	; RX Checksum Control
NIC_82540EM_MTA				equ	0x5200	; Multicast Table Array
NIC_82540EM_RA				equ	0x5400	; Receive Address

;===============================================================================
; wejście:
;	rbx - szyna
;	rcx - urządzenie
;	rdx - funkcja
driver_nic_82540em:
	; zachowaj oryginalne rejestry
	push	rax
	push	rbx
	push	rcx
	push	rsi
	push	r8
	push	r11

	; pobierz BAR0
	mov	eax,	PCI_REGISTER_BAR0
	call	kernel_pci_read

	; pobrany adres z BAR0 jest 64 bitowy?
	bt	eax,	PCI_REGISTER_BAR_FLAG_64
	jnc	.no	; nie

	; zachowaj młodszą część adresu
	push	rax

	; pobierz starszą część
	mov	eax,	PCI_REGISTER_BAR1
	call	kernel_pci_read

	; połącz z młodszą częścią adresu
	mov	dword [rsp + QWORD_HIGH_move],	eax

	; pobierz pełny adres 64 bitowy
	pop	rax

.no:
	; zachowaj adres przestrzeni kontrolera
	and	al,	0xF0	; usuń flagi
	mov	qword [driver_variable_nic_82540em_mmio],	rax

	; ustaw wskaźnik na początek przestrzeni kontrolera
	mov	rsi,	rax

	; pobierz numer przerwania kontrolera
	mov	eax,	PCI_REGISTER_IRQ
	call	kernel_pci_read

	; zachowaj numer przerwania kontrolera
	mov	byte [driver_variable_nic_82540em_irq],	al

	; mapuj przestrzeń kontrolera do tablic stronicowania jądra systemu
	mov	rax,	qword [driver_variable_nic_82540em_mmio]
	mov	rbx,	KERNEL_PAGE_FLAG_AVAILABLE | KERNEL_PAGE_FLAG_WRITE
	mov	rcx,	32	; dokumentacja, strona: 88/410, tabelka: 4-2 // The memory register space is 128K bytes. //
	mov	r11,	cr3
	call	kernel_page_map_physical

	;-----------------------------------------------------------------------
	; czy w przestrzeni rejestrów kontrolera zapisany jest adres MAC?
	cmp	dword [rsi + NIC_82540EM_RA],	EMPTY
	je	.eeprom	; nie, pobierz z EEPROM

	; pobierz i zapisz MAC kontrolera
	mov	eax,	dword [rsi + NIC_82540EM_RA]
	mov	dword [driver_variable_nic_82540em_mac],	eax
	mov	eax,	dword [rsi + NIC_82540EM_RA + STRUCTURE_MAC.4]
	mov	dword [driver_variable_nic_82540em_mac + STRUCTURE_MAC.4],	eax

	; kontynuuj
	jmp	.ready

.eeprom:
	; dokumentacja, strona: 248/410, tabelka: 13-7 // EEPROM Read Register //

	; odczytaj zawartość rejestru pod adresem 0x00
	mov	dword [rsi + NIC_82540EM_EERD],	0x00000001
	mov	eax,	dword [rsi + NIC_82540EM_EERD]
	shr	eax,	MOVE_HIGH_TO_AX
	; zachowaj
	mov	word [driver_variable_nic_82540em_mac + STRUCTURE_MAC.0],	ax

	; odczytaj zawartość rejestru pod adresem 0x01
	mov	dword [rsi + NIC_82540EM_EERD],	0x00000101
	mov	eax,	dword [rsi + NIC_82540EM_EERD]
	shr	eax,	MOVE_HIGH_TO_AX
	; zachowaj
	mov	word [driver_variable_nic_82540em_mac + STRUCTURE_MAC.2],	ax

	; odczytaj zawartość rejestru pod adresem 0x02
	mov	dword [rsi + NIC_82540EM_EERD],	0x00000201
	mov	eax,	dword [rsi + NIC_82540EM_EERD]
	shr	eax,	MOVE_HIGH_TO_AX
	; zachowaj
	mov	word [driver_variable_nic_82540em_mac + STRUCTURE_MAC.4],	ax

.ready:
	; wyłącz wszystkie typy przerwań na kontrolerze
	mov	dword [rsi + NIC_82540EM_IMC],	MAX_UNSIGNED	; dokumentacja, strona 312/410

	; usuń informacje o zalegających
	mov	eax,	dword [rsi + NIC_82540EM_ICR]	; dokumentacja, strona: 307/410, // As a result, reading this register implicitly acknowledges any pending interrupt events. Writing a 1b to any bit in the register also clears that bit. Writing a 0b to any bit has no effect on that bit. //

	; inicjalizuj kontroler
	call	driver_nic_82540em_setup

	; przywróć oryginalne rejestry
	pop	r11
	pop	r8
	pop	rsi
	pop	rcx
	pop	rbx
	pop	rax

	; powrót z procedury
	ret

;===============================================================================
; wejście:
;	rsi - adres przestrzeni kontrolera
driver_nic_82540em_setup:
	; zachowaj oryginalne rejestry
	push	rax
	push	rdi

	;-----------------------------------------------------------------------
	; konfiguracja pakietów przychodzących
	;-----------------------------------------------------------------------

	; przygotuj miejsce pod tablice deskryptorów pakietów przychodzących
	;-----------------------------------------------------------------------
	; jeden z rekordów tablicy deskryptorów przechowuje informacje
	; o adresie przestrzeni gdzie załadowany został pakiet przychodzący
	; dokumentacja, strona 34/410, tabela 3-1
	call	kernel_page_request
	call	kernel_page_dump

	; zachowaj informacje o adresie tablicy deskryptorów
	mov	qword [driver_variable_nic_82540em_rx],	rdi

	; załaduj adres tablicy deskryptorów do kontrolera
	mov	dword [rsi + NIC_82540EM_RDBAL],	edi
	shr	rdi,	MOVE_HIGH_TO_EAX
	mov	dword [rsi + NIC_82540EM_RDBAH],	edi

	; ustaw rozmiar bufora deskryptorów, nagłówek i limit
	; dokumentacja, strona 321/410, podpunkt 13.4.27
	; obsługujemy jeden pakiet na raz, więc ustawiamy minimalne wartości
	mov	dword [rsi + NIC_82540EM_RDLEN],	0x80	; najmniejszy możliwy rozmiar tablicy deskryptorów
	mov	dword [rsi + NIC_82540EM_RDH],	0x00	; pierwszy rekord w tablicy deskryptorów
	mov	dword [rsi + NIC_82540EM_RDT],	0x01	; za pierwszym rekordem jest koniec

	; przygotuj przestrzeń pod pakiet przychodzący
	call	kernel_page_request

	; wstaw do pierwszego rekordu w tablicy deskryptorów
	mov	rax,	qword [driver_variable_nic_82540em_rx]
	mov	qword [rax],	rdi

	; konfiguruj rejestr pakietów przychodzących
	; dokumentacja, strona 314/410, tablica 13-67
	mov	eax,	NIC_82540EM_RCTL_EN	; włącz odbiór pakietów
	or	eax,	NIC_82540EM_RCTL_SBP	; uszkodzone
	or	eax,	NIC_82540EM_RCTL_UPE	; przeznaczone tylko dla mnie
	or	eax,	NIC_82540EM_RCTL_MPE	; przeznaczone dla większości
	or	eax,	NIC_82540EM_RCTL_BAM	; przeznaczone dla wszystkich
	or	eax,	NIC_82540EM_RCTL_SECRC	; usuń CRC z końca pakietu
	mov	dword [rsi + NIC_82540EM_RCTL],	eax

	;-----------------------------------------------------------------------
	; konfiguracja pakietów wychodzących
	;-----------------------------------------------------------------------

	; przygotuj miejsce pod tablice deskryptorów pakietów wychodzących
	;-----------------------------------------------------------------------
	call	kernel_page_request
	call	kernel_page_dump

	; zachowaj informacje o adresie tablicy deskryptorów
	mov	qword [driver_variable_nic_82540em_tx],	rdi

	; załaduj adres tablicy deskryptorów do kontrolera
	mov	dword [rsi + NIC_82540EM_TDBAL],	edi
	shr	rdi,	MOVE_HIGH_TO_EAX
	mov	dword [rsi + NIC_82540EM_TDBAH],	edi

	; ustaw rozmiar bufora deskryptorów, nagłówek i limit
	; dokumentacja, strona 330/410, podpunkt 13.4.38
	; ustawiamy minimalne wartości
	mov	dword [rsi + NIC_82540EM_TDLEN],	0x80	; najmniejszy możliwy rozmiar tablicy deskryptorów
	mov	dword [rsi + NIC_82540EM_TDH],	0x00	; pierwszy rekord w tablicy deskryptorów
	mov	dword [rsi + NIC_82540EM_TDT],	0x00	; brak aktualnie deskryptorów do przetworzenia

	; przygotuj przestrzeń pod pakiet wychodzący
	call	kernel_page_request

	; wstaw do pierwszego rekordu w tablicy deskryptorów
	mov	rax,	qword [driver_variable_nic_82540em_tx]
	mov	qword [rax],	rdi
	mov	qword [rax + QWORD_SIZE_byte],	EMPTY

	; konfiguruj rejestr pakietów przychodzących
	; dokumentacja, strona 314/410, tablica 13-67
	mov	eax,	NIC_82540EM_TCTL_EN	; włącz wysyłanie pakietów
	or	eax,	NIC_82540EM_TCTL_PSP	; wypełnij pakiet do minimalnego rozmiaru 64 Bajtów
	or	eax,	NIC_82540EM_TCTL_RTLC	; Re-transmit on Late Collision
	or	eax,	NIC_82540EM_TCTL_CT	; do 15 prób wysłania pakietu przy wyjątku kolizji
	or	eax,	NIC_82540EM_TCTL_COLD	; Collision Threshold
	mov	dword [rsi + NIC_82540EM_TCTL],	eax

	; ustaw: IPGT 10, IPGR1 8, IPGR2 6
	mov	eax,	NIC_82540EM_TIPG_IPGT_DEFAULT
	or	eax,	NIC_82540EM_TIPG_IPGR1_DEFAULT
	or	eax,	NIC_82540EM_TIPG_IPGR2_DEFAULT
	mov	dword [rsi + NIC_82540EM_TIPG],	eax

	;-----------------------------------------------------------------------
	; włącz kontroler
	;-----------------------------------------------------------------------

	; wyczyść: LRST, PHY_RST, VME, ILOS, ustaw: SLU, ASDE
	mov	eax,	dword [rsi + NIC_82540EM_CTRL]
	or	eax,	NIC_82540EM_CTRL_SLU
	or	eax,	NIC_82540EM_CTRL_ASDE
	and	rax,	~NIC_82540EM_CTRL_LRST
	and	rax,	~NIC_82540EM_CTRL_ILOS
	and	rax,	~NIC_82540EM_CTRL_VME
	and	rax,	NIC_82540EM_CTRL_PHY_RST	; NASM ERROR, błąd kompilatora
	mov	dword [rsi + NIC_82540EM_CTRL],	eax

	;-----------------------------------------------------------------------
	; przywróć oryginalne rejestry
	pop	rdi
	pop	rax

	; powrót z procedury
	ret
