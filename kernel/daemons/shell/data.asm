;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

daemon_shell_prompt_nl		db	ASCII_NEW_LINE
daemon_shell_prompt		db	"# "
daemon_shell_prompt_end:

daemon_shell_cache	times DAEMONS_SHELL_CACHE_SIZE_byte	db	EMPTY
