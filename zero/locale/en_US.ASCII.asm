;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

zero_error_cpu_text			db	ZERO_ASCII_NEW_LINE, "Unsupported CPU model.", ZERO_ASCII_TERMINATOR
zero_error_memory_map_text		db	ZERO_ASCII_NEW_LINE, "Memory map error.", ZERO_ASCII_TERMINATOR
zero_error_a20_text			db	ZERO_ASCII_NEW_LINE, "Gate A20 locked.", ZERO_ASCII_TERMINATOR
zero_error_video_text			db	ZERO_ASCII_NEW_LINE, "Video mode not found.", ZERO_ASCII_TERMINATOR
