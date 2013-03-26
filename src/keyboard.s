; vim:syntax=nasm

bits 16

global handle_int9
global handle_int16

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
	in al, 0x60
	cmp al, 0xe0	; Omit 0xe0 from multi-byte codes
	je int9_end
	test al, 0x80 ; Omit 'released' events
	jnz int9_end
	mov [kb_base + bx], al
	mov [kb_write_idx], bl
	
int9_end:
	; Send EOI to PIC
	mov al, 0x20
	out 0x20, al
	popad
	iret


handle_int16:
	push bx

int16_block:
	mov al, [kb_read_idx]
	; Wait for a key to be pressed if buffer is empty
	cmp al, [kb_write_idx]
	jne int16_end
	sti
	hlt
	jmp int16_block

int16_end:
	xor ah, ah
	xor bx, bx
	mov bl, 8 ; buffer length
	inc al	
	div bl ; real index is in ah now
	mov bl, ah
	mov ah, [kb_base + bx] ; read scan code
	mov [kb_read_idx], bl ; update read index
	; Convert scan code to ascii char
	mov bl, ah
	mov al, [kb_code2ascii + bx]	
	cmp al, 0
	je int16_block ; Skip keys treated as nulls
	pop bx
	iret

kb_write_idx: db 0
kb_read_idx: db 0
kb_base: db 0, 0, 0, 0, 0, 0, 0, 0
kb_code2ascii: db 00, 00, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', 0x08, 00, 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', 13, 00, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', 0x27, '`', 00, '\', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 00, 00, 00, 0x20
