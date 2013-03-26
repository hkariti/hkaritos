; vim:syntax=nasm

;org 0x1000

extern init

global get_cs

bits 16

_start:
	mov ax, 0
	mov ds, ax
	mov ss, ax

	call init
	
halt:
	cli
	hlt


get_cs:
	mov ax, cs
	o32 ret

