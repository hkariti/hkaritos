; vim:syntax=nasm

global getc
global puts
global putc
global strcmp

bits 16

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;     AUXILLARY FUNCS            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

getc:
; Read and return one char from the keyboard
	mov ah, 0
	int 0x16
	o32 ret

puts:
; Print a given string to the screen
	push ebp
	mov ebp, esp
	push bx
	mov ecx, 0 ; Counter for number of characters printed

	; First arg is a pointer to the string
	mov esi, [ebp+8] 
puts_l:
; Print the string char by char until the NULL terminator
	mov ah, 0x0e
	mov bh, 0
	lodsb
	test al, al
	jz puts_end
	int 10h
	inc ecx
	jmp puts_l

puts_end:
	mov eax, ecx
	pop bx
	o32 leave
	o32 ret

putc:
	push ebp
	mov bp, sp
	push bx

	mov eax, [bp+8]
	mov ah, 0x0e
	mov bh, 0
	int 10h

	pop bx
	o32 leave
	o32 ret

strcmp:
	push ebp
	mov bp, sp

	mov esi, [bp+8]
	mov edi, [bp+12]
strcmp_l:
	mov al, [si]
	mov ah, [di]
; End when strings differ
	cmp al, ah
	jnz strcmp_end

; End when the strings end
	cmp al, 0
	jz strcmp_end

; Move one char forward
	inc di
	inc si
	jmp strcmp_l

strcmp_end:
	and eax, 0xffff ; Clear the high part of eax
	o32 leave
	o32 ret

;;;;;;;;;;;;;;;;;;;;;;;;
; Generic strings     ;;
;;;;;;;;;;;;;;;;;;;;;;;;

hello_s: db "Hello, world!"
newline_s: db 13, 10, 0
