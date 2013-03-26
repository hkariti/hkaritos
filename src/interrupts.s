; vim:syntax=nasm

bits 16

global setup_int
global get_int
global handle_int9
global handle_int16
extern old_int9
extern old_int16

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

handle_int9:
	pushad
	xor ax, ax
	xor bx, bx
	mov bl, 8 ; buffer length
	mov al, [kb_write_idx]
	inc al	
	div bl ; real index is in ah now
	mov bl, ah
	cmp ah, [kb_read_idx] ; Check if buffer is full
	je int9_end
	in al, 0x64
	mov [kb_base + bx], al
	mov [kb_write_idx], bl
	
int9_end:
	; Send EOI to PIC
	mov al, 0x20
	out 0x20, al
	popad
	iret

handle_int16:
	pushad
	mov al, [kb_read_idx]

int16_block:
	; Wait for a key to be pressed if buffer is empty
	cmp al, [kb_write_idx]
	jne int16_end
	sti
	hlt
	jmp int16_block

int16_end:
	xor ax, ax
	xor bx, bx
	mov bl, 8 ; buffer length
	inc al	
	div bl ; real index is in ah now
	mov bl, ah
	mov al, [kb_base + bx]
	mov [kb_read_idx], bl
	popad
	iret

kb_write_idx: db 0
kb_read_idx: db 0
kb_base: db 0, 0, 0, 0, 0, 0, 0, 0
