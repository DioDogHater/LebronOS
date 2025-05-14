[bits 16]
; Print out string stored at es:bx, null-terminated
print:
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
	ret

; Get a single character
; Sets al as the character pressed on the keyboard
get_char:
	mov ah, 0
	int 0x16
	ret

[bits 32]

VIDEO_MEMORY equ 0xb8000
WHITE_ON_BLACK equ 0x0f

clear_vga:
	pusha
	mov ebx, 80*25
	mov edx, VIDEO_MEMORY
	mov ax, 0
	.loop:
	mov [edx], ax
	add edx, 2
	dec ebx
	jnz .loop
	popa
	ret

newline_vga:
	pusha
	mov eax, DWORD [CURSOR]
	add eax, 80
	xor edx, edx
	mov edi, 80
	div edi
	mul edi
	dec eax
	mov DWORD [CURSOR], eax
	popa
	ret

print_vga:
	pusha
	mov ah, WHITE_ON_BLACK

	.loop:
	mov al, [ebx] 
	
	test al, al 
	jz .done
	
	cmp al, 128
	ja .image_offset

	cmp al, 10
	jne .normal_char

	.new_line:
	call newline_vga
	jmp .increment

	.image_offset:
	sub al, 128
	movzx edx, al
	add edx, DWORD [CURSOR]
	mov DWORD [CURSOR], edx
	jmp .increment
	
	.normal_char:
	mov edx, DWORD [CURSOR]
	shl edx, 1
	add edx, VIDEO_MEMORY
	mov [edx], ax

	.increment:
	inc ebx
	inc DWORD [CURSOR]
	jmp .loop

	.done:
	popa
	ret


CURSOR: dd 0
