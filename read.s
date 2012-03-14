; vim:syntax=nasm

org 7c00h

start:
	mov al, 1
	mov ah, 2h
	mov bx, 1000h
	mov cl, 2
	mov ch, 0
	mov dl, 80h
	mov dh, 0
	int 13h
	jc read_error
	jmp bx

halt:
	cli
	hlt

read_error:
	mov si, error_s
	call puts
	jmp halt

puts:
	mov ah, 0eh
	mov bh, 0
	mov cx, 0
	mov bl, 0
	lodsb
	test al, al
	jz puts_end
	int 10h
	jmp puts

puts_end:
	ret

error_s: db "Oh no!", 0
