; Copyright (C) 2013-2016 Wataha.net
; All Rights Reserved
;
; LICENSE Creative Commons BY-NC-ND 4.0
; See LICENSE.TXT
;
; Main developer:
;	Andrzej (akasei) Adamczyk [e-mail: akasei from wataha.net]
;-------------------------------------------------------------------------------

; Use:
; nasm - http://www.nasm.us/

; 64 Bitowy kod programu
[BITS 64]

; procedura zostanie usunięta z pamięci po wykonaniu
move_included_files_to_virtual_filesystem:
	; zachowaj oryginalne rejestry
	push	rcx
	push	rdx
	push	rsi
	push	rdi

	; wskaźnik do tablicy plików
	mov	rsi,	files_table

.loop:
	; koniec tablicy plików?
	cmp	qword [rsi],	VARIABLE_EMPTY
	je	.end	; tak

	; zachowaj wskaźnik
	push	rsi

	; pobierz ilość znaków w nazwie pliku
	mov	rcx,	qword [rsi]

	; pobierz rozmiar pliku
	mov	rdx,	qword [rsi + 0x08]

	; ustaw wskaźnik na początek danych pliku
	mov	rdi,	qword [rsi + 0x10]

	; ustaw wskaźnik na nazwę pliku
	add	rsi,	0x20

	; zapisz do wirtualnego systemu plików
	call	cyjon_vfs_file_save
	jc	.error

	; przywróć wskaźnik
	pop	rsi

	; przesuń na następny rekord
	add	rsi,	qword [rsi]	; ilość znaków w nazwie pliku
	add	rsi,	0x20	; rozmiar pozostałej części rekordu

	; kontynuuj z pozostałymi plikami
	jmp	.loop

.end:
	; przywróć oryginalne rejestry
	pop	rdi
	pop	rsi
	pop	rdx
	pop	rcx

	; powrót z procedury
	ret

.error:
	jmp	$

files_table:
	; pierwszym plikiem musi być "init"
	; jądro systemu z tej tablicy uruchamia pierwszy proces
	dq	4				; ilość znaków w nazwie pliku
	dq	file_init_end - file_init	; rozmiar pliku w Bajtach
	dq	file_init			; wskaźnik początku pliku
	dq	file_init_end			; wskaźnik końca pliku
	db	'init'				; nazwa pliku

	; plik
	dq	5
	dq	file_shell_end - file_shell
	dq	file_shell
	dq	file_shell_end
	db	'shell'

	; plik
	dq	5
	dq	file_login_end - file_login
	dq	file_login
	dq	file_login_end
	db	'login'

	; plik
	dq	2
	dq	file_ps_end - file_ps
	dq	file_ps
	dq	file_ps_end
	db	'ps'

	; plik
	dq	2
	dq	file_ip_end - file_ip
	dq	file_ip
	dq	file_ip_end
	db	'ip'

	; plik
	dq	4
	dq	file_help_end - file_help
	dq	file_help
	dq	file_help_end
	db	'help'

	; plik
	dq	5
	dq	file_httpd_end - file_httpd
	dq	file_httpd
	dq	file_httpd_end
	db	'httpd'

	; plik
	dq	4
	dq	file_kill_end - file_kill
	dq	file_kill
	dq	file_kill_end
	db	'kill'

	; plik
	dq	4
	dq	file_free_end - file_free
	dq	file_free
	dq	file_free_end
	db	'free'

	; plik
	dq	1
	dq	file_x_end - file_x
	dq	file_x
	dq	file_x_end
	db	'x'

	; plik
	dq	2
	dq	file_ls_end - file_ls
	dq	file_ls
	dq	file_ls_end
	db	'ls'

	; plik
	dq	3
	dq	file_cat_end - file_cat
	dq	file_cat
	dq	file_cat_end
	db	'cat'

	; plik
	dq	10
	dq	file_readme_end - file_readme
	dq	file_readme
	dq	file_readme_end
	db	'readme.txt'

	; plik
	dq	3
	dq	file_bfi_end - file_bfi
	dq	file_bfi
	dq	file_bfi_end
	db	'bfi'

	; plik
	dq	8
	dq	file_hello_end - file_hello
	dq	file_hello
	dq	file_hello_end
	db	'hello.bf'

	; koniec tablicy plików
	dq	VARIABLE_EMPTY

file_init:		incbin	'build/init.bin'
file_init_end:

file_shell:		incbin	'build/shell.bin'
file_shell_end:

file_login:		incbin	'build/login.bin'
file_login_end:

file_ps:		incbin	'build/ps.bin'
file_ps_end:

file_ip:		incbin	'build/ip.bin'
file_ip_end:

file_help:		incbin	'build/help.bin'
file_help_end:

file_httpd:		incbin	'build/httpd.bin'
file_httpd_end:

file_kill:		incbin	'build/kill.bin'
file_kill_end:

file_free:		incbin	'build/free.bin'
file_free_end:

file_x:			incbin	'build/x.bin'
file_x_end:

file_ls:		incbin	'build/ls.bin'
file_ls_end:

file_cat:		incbin	'build/cat.bin'
file_cat_end:

file_readme:		incbin	'software/readme.txt'
file_readme_end:

file_bfi:		incbin	'build/bfi.bin'
file_bfi_end:

file_hello:		incbin	'software/hello.bf'
file_hello_end:
