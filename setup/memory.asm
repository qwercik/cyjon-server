;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

	; ustaw komunikat
	mov	ecx,	text_error_memory_map_end - text_error_memory_map
	mov	esi,	text_error_memory_map

	; program rozruchowy udostępnił mapę pamięci?
	bt	dword [ebx + STATIC_STRUCTURE_MULTIBOOT_BOOT_INFORMATION.flags],	STATIC_MULTIBOOT_BOOT_INFORMATION_FLAG_BIT_MEMORY_MAP
	jnc	kernel_panic	; nie, wyświetl komunikat
