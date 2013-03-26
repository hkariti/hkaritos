; vim:syntax=nasm

bits 16

%define BUFFER_SIZE 8
%define PS2_DATA_PORT 0x60
%define PIC_CMD_PORT 0x20
%define PIC_EOI_CMD 0x20
%define F_UPPER 1

global handle_int9
global handle_int16

;;; Handle keyboard interrupts
handle_int9:
	pushad
	xor ax, ax
	xor bx, bx
	mov bl, BUFFER_SIZE
	mov al, [kb_write_idx]
	inc al	
	div bl ; real index is in ah now
	mov bl, ah
	cmp ah, [kb_read_idx] ; Check if buffer is full
	je int9_end
	in al, PS2_DATA_PORT
check_shift_caps:
	cmp al, 0x3a
	je toggle_upper
	cmp al, 0x2a
	je toggle_upper
	cmp al, 0x36
	je toggle_upper
	cmp al, 0xaa
	je toggle_upper
	cmp al, 0xb6
	je toggle_upper

process_scancode:
	cmp al, 0xe0	; Omit 0xe0 from multi-byte codes
	je int9_end
	test al, 0x80 ; Omit 'released' events
	jnz int9_end
	mov [kb_base + bx], al
	mov [kb_write_idx], bl
	jmp int9_end
	
toggle_upper:
	xor byte [kb_flags], F_UPPER
int9_end:
	; Send EOI to PIC
	mov al, PIC_EOI_CMD
	out PIC_CMD_PORT, al
	popad
	iret


;;; Read a single key from the keyboard buffer
handle_int16:
	push bx
	push si

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
	mov bl, BUFFER_SIZE
	inc al	
	div bl ; real index is in ah now
	mov bl, ah
	mov ah, [kb_base + bx] ; read scan code
	mov [kb_read_idx], bl ; update read index
	; Convert scan code to ascii char
	mov bl, ah
	mov si, kb_code2ascii
	test byte [kb_flags], F_UPPER
	jz lookup_table
	mov si, kb_code2ascii_upper
lookup_table:
	mov al, [si + bx]	
	cmp al, 0 ; Skip keys treated as nulls
	je int16_block
	pop si
	pop bx
	iret

kb_flags: db 0
kb_write_idx: db 0
kb_read_idx: db 0
kb_base: db 0, 0, 0, 0, 0, 0, 0, 0
kb_code2ascii: db 00, 00, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', 0x08, 00, 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', 13, 00, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', 0x27, '`', 00, '\', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 00, 00, 00, 0x20
kb_code2ascii_upper: db 00, 00, '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '+', 0x08, 00, 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '{', '}', 13, 00, 'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ':', '"', '~', 00, '|', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '<', '>', '?', 00, 00, 00, 0x20
