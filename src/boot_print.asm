; Print out string stored at es:bx, null-terminated
print:
	pusha
	.loop:
	mov al, [es:bx]
	cmp al, 0
	jz .end
	mov ah, 0x0e
	cmp al, 0x80
	jbe .normal_char
	sub al, 0x80
	mov dl, al
	mov al, ' ' 
	.space_loop:
	int 0x10
	dec dl
	jnz .space_loop
	jmp .no_carriage_return
	.normal_char:
	int 0x10
	cmp al, 10
	jne .no_carriage_return
	mov al, 13
	int 0x10
	.no_carriage_return:
	inc bx
	jmp .loop
	.end:
	popa
	ret

; Print out value of dx in hexadecimal
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
	mov ax, 0
	push es
	mov es, ax
	mov bx, HEX_OUT
	call print
	pop es
	popa
	ret

; Print out newline character
print_nl:
	pusha
	mov ah, 0x0e
	mov al, 10
	int 0x10
	mov al, 13
	int 0x10
	popa
	ret

; Clear out screen
clear_screen:
	pusha
	mov ax, 0x0700
	mov bh, 0x07
	mov cx, 0
	mov dx, 0x184F
	int 0x10	; Scroll down
	mov ah, 0x02
	mov bh, 0
	mov dx, 0
	int 0x10	; Move cursor to the top-left corner
	popa
	ret

; Get a single character
; Sets al as the character pressed on the keyboard
get_char:
	mov ah, 0
	int 0x16
	ret

HEX_OUT:
db "0x0000",0
