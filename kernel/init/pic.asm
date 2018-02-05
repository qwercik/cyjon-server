;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

	; przełącz obydwa układy w tryb inicjalizacji
	mov	al,	0x11
	out	PORT_PIC_MASTER_command,	al
	out	PORT_PIC_SLAVE_command,	al

	; przeindeksuj pic0 (master) na przerwania od 0x20 do 0x27
	mov	al,	0x20
	out	PORT_PIC_MASTER_data,	al

	; przeindeksuj pic1 (slave) na przerwania od 0x28 do 0x2F
	mov	al,	0x28
	out	PORT_PIC_SLAVE_data,	al

	; pic0 ustaw jako główny (master) i poinformuj o istnieniu pic1
	mov	al,	0x04
	out	PORT_PIC_MASTER_data,	al

	; pic1 ustaw jako pomocniczy (slave)
	mov	al,	0x02
	out	PORT_PIC_SLAVE_data,	al

	; obydwa kontrolery w tryb 8086
	mov	al,	0x01
	out	PORT_PIC_MASTER_data,	al
	out	PORT_PIC_SLAVE_data,	al

	; wyłącz wszystkie przerwania sprzętowe
	; nie powinny były być włączone, dmuchamy na zimne
	mov	al,	byte [kernel_pic_semaphore_bit + BYTE_SIZE_byte]
	out	PORT_PIC_SLAVE_data,	al	; pic1 (slave)

	mov	al,	byte [kernel_pic_semaphore_bit]
	out	PORT_PIC_MASTER_data,	al	; pic0 (master)
