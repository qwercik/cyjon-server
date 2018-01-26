;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

;===============================================================================
; MULTIBOOT
;===============================================================================
STATIC_MULTIBOOT_BOOT_INFORMATION_FLAG_BIT_MEMORY_MAP	equ	6
STATIC_MULTIBOOT_BOOT_INFORMATION_FLAG_BIT_VIDEO	equ	11

; https://www.gnu.org/software/grub/manual/multiboot/multiboot.html#Boot-information-format
struc	STATIC_STRUCTURE_MULTIBOOT_BOOT_INFORMATION
	.flags						resd	1
	.mem_lower					resd	1
	.mem_upper					resd	1
	.boot_device					resd	1
	.cmdline					resd	1
	.mods_count					resd	1
	.mods_addr					resd	1
	.syms						resb	16
	.mmap_length					resd	1
	.mmap_addr					resd	1
	.drives_length					resd	1
	.drives_addr					resd	1
	.config_table					resd	1
	.boot_loader_name				resd	1
	.apm_table					resd	1
	.vbe_control_info				resd	1
	.vbe_mode_info					resd	1
	.vbe_mode					resw	1
	.vbe_interface_seq				resw	1
	.vbe_interface_off				resw	1
	.vbe_interface_len				resw	1
	.SIZE:
endstruc

; http://www.monstersoft.com/tutorial1/VESA_intro.html#6.3
struc	STATIC_STRUCTURE_VIDEO_SUPERVGA_MODE_INFO_BLOCK
	.ModeAttributes					resb	2
	.WinAAttributes					resb	1
	.WinBAttributes					resb	1
	.WinGranularity					resb	2
	.WinSize					resb	2
	.WinASegment					resb	2
	.WinBSegment					resb	2
	.WinFuncPtr					resb	4
	.BytesPerScanLine				resb	2
	.XResolution					resb	2
	.YResolution					resb	2
	.XCharSize					resb	1
	.YCharSize					resb	1
	.NumberOfPlanes					resb	1
	.BitsPerPixel					resb	1
	.NumberOfBanks					resb	1
	.MemoryModel					resb	1
	.BankSize					resb	1
	.NumberOfImagePages				resb	1
	.Reserved					resb	1
	.RedMaskSize					resb	1
	.RedFieldPosition				resb	1
	.GreenMaskSize					resb	1
	.GreenFieldPosition				resb	1
	.BlueMaskSize					resb	1
	.BlueFieldPosition				resb	1
	.RsvdMaskSize					resb	2
	.DirectColorModeInfo				resb	1
	.PhysicalVideoAddress				resb	4
endstruc

;===============================================================================
; CPUID
;===============================================================================
STATIC_CPUID						equ	0x80000000
STATIC_CPUID_EXTENDED					equ	0x80000001
STATIC_CPUID_EXTENDED_FLAG_LM				equ	29
