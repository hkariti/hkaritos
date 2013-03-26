; vim:syntax=nasm

bits 16

global setup_int
global get_int

setup_int:
	; Set a new handler location for the requested interrupt
	push ebp
	mov ebp, esp
	push di
	push si
	push bx

	xor bx,bx
	mov bl, [ebp+8] ; int number
	mov si, [ebp+12] ; segment
	mov di, [ebp+16] ; offset

	shl bx, 2 ; IVT row
	mov [2 + bx], si ; segment
	mov [0 + bx], di ; offset

	mov ax, bx ; return value

	pop bx
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
