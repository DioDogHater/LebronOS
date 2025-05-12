[org 0x7c00] ; Memory offset

; SECTOR 1 - BOOT SECTOR

boot_start:
	mov bp, 0x8000	; set stack far away
	mov sp, bp
	
	mov bx, 0x8000	; es:bx = 0x0000:0x8000 = 0x8000
	mov dh, 3	; Read only 3 sectors
	call disk_load
	
	call clear_screen

	mov bx, 0x800
	mov es, bx

	mov bx, lebron_glazing1
	call print
	mov bx, lebron_glazing2
	call print
	mov bx, lebron_glazing3
	call print
	mov bx, lebron_glazing4
	call print
	mov bx, lebron_glazing5
	call print
	
	call get_char
	call clear_screen

	mov bx, lebron_image
	call print
	
	call get_char
	call clear_screen
	
	mov cx, 0
	.lebron_loop:
	call get_char
	mov bx, .lebron_txt
	add bx, cx
	mov al, [bx]
	mov ah, 0x0e
	int 0x10
	inc cx
	cmp cx, lebron_txt_len
	jb .dont_loop_lebron_txt
	mov cx, 0
	.dont_loop_lebron_txt:
	jmp .lebron_loop
	
	.lebron_txt: db "Lebron james is the GOAT. "
	lebron_txt_len equ $-.lebron_txt

end_of_boot:
	call get_char
	jmp end_of_boot

%include "src/boot_print.asm"
%include "src/boot_disk.asm"

extra_string:
times 510 - ($-$$) db 0
extra_string_len equ $-extra_string
dw 0xaa55

; SECTOR 2, 3, 4 - LEBRON HAIRLINE DATA
_sector_2:

lebron_glazing1 equ $-_sector_2
db "You are my sunshine, my only sunshine.",10,0
lebron_glazing2 equ $-_sector_2
db "You make me happy when skies are gray.",10,0
lebron_glazing3 equ $-_sector_2
db "You'll never know dear, how much I love you.",10,0
lebron_glazing4 equ $-_sector_2
db "Please don't take my sunshine away...",10,0
lebron_glazing5 equ $-_sector_2
db "Please I love you so much Lebron don't leave me.",10,"I NEED YOU.",10,0

%include "src/lebron.asm"

times 512*3 - ($-_sector_2) db 0
