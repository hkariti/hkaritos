; vim:syntax=nasm

;org 0x1000

extern read_line

global puts
global strcmp
global putc
global getc
global _start

bits 16

_start:
	mov ax, ds
	mov ss, ax
	push dword hello_s
	call dword puts
	add sp, 4
	jmp prompt
	
halt:
	cli
	hlt


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;      Basic Shell Interface         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

prompt:
	push dword prompt_s
	call dword puts
	add sp, 4

	call dword read_line
	push eax
	call dword parse
	sub esp, 4
	jmp prompt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;       Command Parsers             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

parse:
	push ebp
	mov ebp, esp

; Skip empty commands
	mov eax, [ebp+8]
	cmp word [eax], 0
	jz p_end

	mov di, cmds
p_next_cmd:
	push edi
	push dword [ebp+8]
	call dword strcmp
	add sp, 8
	cmp al, 0
	jz p_run
	
p_skip_cmd:
	mov al, 0
	mov cx, 0xffff
	repne scasb

p_skip_end:
	mov ax, [di]
	cmp ax, 0
	jz p_unk
	add di, 2
	jmp p_next_cmd

p_run:
	mov al, 0
	mov cx, 0xffff
	repne scasb
	mov ax, [di]
	jmp ax

p_unk:
	push dword 0x2000
	call dword puts
	add sp, 4
	push dword unk_s
	call dword puts
	add sp, 4

p_end:
	o32 leave
	o32 ret

help_cmd:
	push dword help_s
	call dword puts
	add sp, 4
	jmp p_end


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
prompt_s: db "> ", 0
back_s: db 8, ' ', 8, 0

unk_s: db ": unknown command", 13, 10, 0

;;;;;;;;;;;;;;;;;;;;;;;;;
;;     Commands        ;;
;;;;;;;;;;;;;;;;;;;;;;;;;

cmds:
c_help: db "help", 0
p_help: dw help_cmd
c_exit: db "exit", 0
p_exit: dw help_cmd
c_ls: db "ls", 0
p_ls: dw help_cmd
c_unk: dw 0




help_s: db "Welcome to my shell. Commands:", 13, 10
	db "help                 Show this message", 13, 10, 0, 0,0


