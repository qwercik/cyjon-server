; Copyright (C) 2013-2016 Wataha.net
; All Rights Reserved
;
; LICENSE Creative Commons BY-NC-ND 4.0
; See LICENSE.TXT
;
; Main developer:
;	Andrzej (akasei) Adamczyk [e-mail: akasei from wataha.net]
;
;-------------------------------------------------------------------------------

; Use:
; nasm - http://www.nasm.us/

; Superblock [SB]
dq	0x100	; rozmiar partycji w blokach
dq	0x1000	; rozmiar bloku w Bajtach
dq	0x80	; rozmiar supła
dq	0x01	; rozmiar binarnej mapy bloków
dq	0x08	; rozmiar tablicy supłów

times 0x1000 - ( $ - $$ )	db	0x00

; Binary Block Map [BBM]
dq	0x001fffffffffffff
dq	0xffffffffffffffff
dq	0xffffffffffffffff
dq	0xffffffffffffffff

times 0x2000 - ( $ - $$ )	db	0x00

; Knots Table [KT]

; rekord 0 - root directory
dw	0x4000	; directory
dq	0x0000000000000001	; rozmiar w blokach
dq	0x0000000000000025	; rozmiar w Bajtach
dq	0x000000000000000A	; numer pierwszego bloku danych pliku
dq	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
dw	0x00, 0x00, 0x00

; rekord 1 - plik: readme.txt
dw	0x8000	; plik
dq	0x0000000000000001
dq	0x0000000000000000
dq	0x000000000000000B
dq	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
dw	0x00, 0x00, 0x00

times 0xA000 - ( $ - $$ )	db	0x00

; plik Root Directory

; rekord 0
dq	0x0000000000000000	; identyfikator supła
dw	0x0013	; rozmiar rekordu
db	0x07	; ilość znaków w nazwie pliku
db	0x02	; typ pliku "katalog"
db	'.system'

; rekord 1
dq	0x0000000000000001
dw	0x0016
db	0x0A
db	0x01
db	'readme.txt'

times 512 * 2048 - ( $ - $$ )	db	0x00
