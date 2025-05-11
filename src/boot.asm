[org 0x7c00] ; Memory offset

mov bx, lebron_glazing
call print

mov dx, 0x8C1B
call print_hex

jmp $

; Print out string stored at bx, null-terminated
; Destroys ax, bx
print:
	pusha
	.loop:
	mov al, [bx]
	test al, al
	jz .end
	mov ah, 0x0e
	int 0x10
	inc bx
	jmp .loop
	.end:
	popa
	ret

; Print out value of dx in hexadecimal
; Destroys ax, bx, cx
print_hex:
	pusha
	mov cx, 0
	.loop:
	cmp cx, 4
	je .end
	mov ax, dx
	and al, 0x000F
	add al, 0x30
	cmp al, 0x39
	jle .alphabetical
	add al, 7
	.alphabetical:
	mov bx, HEX_OUT+5
	sub bx, cx
	mov [bx], al
	ror dx, 4
	inc cx
	jmp .loop
	.end:
	mov bx, HEX_OUT
	call print
	popa
	ret

lebron_glazing:
db "Oh lebron, lebonbon, where do I even start... You are my sunshine, my rainbows, my saviour. When I see you playing basketball, I want to join you in that blissful GOATedness...",0

HEX_OUT:
db "0x0000",0

times 510 - ($-$$) db 0
dw 0xaa55
