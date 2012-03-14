; vim:syntax=nasm

org 0x1000

start:
	push hello_s
	call puts
	add sp, 2
	jmp prompt
	
halt:
	cli
	hlt


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;      Basic Shell Interface         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

prompt:
	push prompt_s
	call puts
	add sp, 2
; reset di
	mov di, 0x2000

	call read_line
	jmp prompt

read_line:
	call getc

; Handle special keys before printing
	cmp al, 0x08 ; Backspace
	jz handle_backspace
	cmp al, 13   ; Newline
	jz handle_newline

; Print and store as a string
rl_print:
	push ax
	call putc
	add sp, 2
	stosb
	jmp read_line
	
rl_end:
	ret
			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;       Special Keys Handlers         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

handle_backspace:
; Don't delete over the prompt
	cmp di, 0x2000
	jz read_line	
	
; Remove the last char from the screen
	push back_s
	call puts
	add sp, 2

; Remove the last char from the string
	dec di
	mov byte [di], 0

	jmp read_line

handle_newline:
; Print a newline
	push newline_s
	call puts
	add sp, 2

; Don't parse empty lines
	cmp di, 0x2000
	jz rl_end

; End the string and parse it
	mov byte [di], 0
	call parse

; End the line processing
	jmp rl_end
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;       Command Parsers             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

parse:
	mov di, cmds
p_next_cmd:
	push 0x2000
	push di
	call strcmp
	jz p_run
	add sp, 4
	
p_skip_cmd:
	cmp byte [di], 0
	jz p_skip_end
	inc di
	jmp p_skip_cmd

p_skip_end:
	inc di
	mov ax, [di]
	cmp ax, 0
	jz p_unk
	add di, 2
	jmp p_next_cmd
p_run:
	add sp, 4
	mov ax, [di+1]
	jmp ax

p_unk:
	push 0x2000
	call puts
	add sp, 2
	push unk_s
	call puts
	add sp, 2

p_end:
	ret

help_cmd:
	push help_s
	call puts
	add sp, 2
	jmp p_end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;     AUXILLARY FUNCS            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

getc:
; Read from keyboard and handle the key pressed
	mov ah, 0
	int 0x16
	ret

puts:
	mov bp, sp
	mov si, [bp+2]
puts_l:
	mov ah, 0x0e
	mov bh, 0
	lodsb
	test al, al
	jz puts_end
	int 10h
	jmp puts_l

puts_end:
	mov sp, bp
	ret

putc:
	mov bp, sp
	mov ax, [bp+2]
	mov ah, 0x0e
	mov bh, 0
	int 10h
	mov sp, bp
	ret

strcmp:
	mov bp, sp
	mov si, [bp+2]
	mov di, [bp+4]
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
	ret

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
	db "help                 Show this message", 13, 10, 0


