; vim:syntax=nasm

;org 0x1000

extern init
extern prompt

global get_int
global set_int

bits 16

_start:
	mov ax, 0
	mov ds, ax
	mov ss, ax

	call init
	
halt:
	cli
	hlt


setup_int:
	; Set a new handler location for the requested interrupt
	push ebp
	mov ebp, esp
	push di
	push si
	push dx
	push bx

	xor bx,bx
	mov bl, [ebp+8] ; int number
	mov si, [ebp+12] ; segment
	mov di, [ebp+16] ; offset

	shl bx, 2 ; IVT row
	mov dx, [si] ; segment
	mov [2 + bx], dx
	mov dx, [di] ; offset
	mov [0 + bx], dx

	mov ax, bx ; return value

	pop bx
	pop dx
	pop si
	pop di
	pop ebp
	o32 ret

get_int:
	; Read the location of the requeted interrupt's handler
	push ebp
	mov ebp, esp
	push di
	push si
	push dx
	push bx
	
	xor bx, bx
	mov bl, [ebp+8] ; int number
	mov si, [ebp+12] ; segment
	mov di, [ebp+16] ; offset

	shl bx, 2 ; IVT row
	mov dx, [2 + bx] ; segment
	mov [si], dx
	mov dx, [0 + bx] ; offset
	mov [di], dx
	
	mov ax, bx ; return value

	pop bx
	pop dx
	pop si
	pop di
	pop ebp
	o32 ret
