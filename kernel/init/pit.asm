;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

	; przygotuj kanał zegara
	mov	al,	PORT_PIT_CLOCK
	out	PORT_PIT_CHANNEL_4_command,	al

	; częstotliwość kryształu
	mov	eax,	PIT_CRYSTAL / KERNEL_PIT_CLOCK_hz

	; wprowadź dane do kanału zegara
	out	PORT_PIT_CHANNEL_0_data,	al	; młodsza część wyniku
	shr	ax,	MOVE_HIGH_TO_AL
	out	PORT_PIT_CHANNEL_0_data,	al	; starsza część wyniku
