; vim:syntax=nasm

org 7c00h

start:
	mov ah, 2h ; Function; 2h reads sectors from drive
	mov al, 4 ; Number of sectors
	mov bx, 1000h ; Buffer pointer
	mov dl, 80h ; Drive number. 80h is the first hard drive
	mov dh, 0 ; Head
	mov ch, 0 ; Track
	mov cl, 2 ; Track/Sector
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
