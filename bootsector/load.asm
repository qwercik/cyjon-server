;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

	; przygotuj komunikat błędu
	mov	si,	text_stage1_error_bios

	; sprawdź czy procedura jest dostępna w aktualnej wersji BIOSu
	; http://www.ctyme.com/intr/rb-0706.htm
	mov	ah,	0x41
	mov	bx,	0x55AA	; wartość kontrolna
	int	0x13
	jc	error	; brak dostępnej procedury, wyświetl komunikat

	; sprawdź bit 0 w rejestrze CL
	bt	cx,	0
	jnc	error	; brak dostępu do funkcji 0x42, wyświetl komunikat

	; wczytaj stage2 za pomocą funkcji 0x42, przerwania 0x13
	; http://www.ctyme.com/intr/rb-0708.htm
	mov	ah,	0x42
	mov	si,	table_disk_address_packet	; o rozmiarze i miejscu docelowym opisanym za pomocą specyfikacji
	int	0x13

	; ustaw komunikat błędu
	mov	si,	text_stage1_error_read
	jnc	0x7E00	; kod stage2 wczytany bezbłędnie
