;===============================================================================
; Copyright (C) 2013+ by Andrzej Adamczyk at Wataha.net
;===============================================================================

shell_text_welcome		db	"Shell ready."
shell_text_welcome_end:

shell_text_error_command	db	ASCII_NEW_LINE, 'Command "'
shell_text_error_command_end:
shell_text_error_not_found	db	'" not found.', ASCII_NEW_LINE
shell_text_error_not_found_end:
