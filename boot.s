; vim:syntax=nasm

;org 0x1000

extern read_line
extern parse
extern prompt

global puts
global strcmp
global putc
global getc
global _start

bits 16

_start:
	mov ax, 0
	mov ds, ax
	mov ss, ax
	push dword hello_s
	call dword puts
	add sp, 4
	
	call prompt
	
halt:
	cli
	hlt


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;     AUXILLARY FUNCS            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

getc:
; Read from keyboard and handle the key pressed
	mov ah, 0
	int 0x16
	o32 ret

puts:
	push ebp
	mov ebp, esp
	push bx

	mov esi, [ebp+8]
puts_l:
	mov ah, 0x0e
	mov bh, 0
	lodsb
	test al, al
	jz puts_end
	int 10h
	jmp puts_l

puts_end:
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
	and eax, 0x00ff ; Clear the high part of eax
	o32 leave
	o32 ret

;;;;;;;;;;;;;;;;;;;;;;;;
; Generic strings     ;;
;;;;;;;;;;;;;;;;;;;;;;;;

hello_s: db "Hello, world!"
newline_s: db 13, 10, 0


