[org 0x7c00] ; Memory offset

; SECTOR 1 - BOOT SECTOR
boot_start:
	mov bp, 0x8000	; set stack far away
	mov sp, bp
	
	mov bx, 0x8000	; es:bx = 0x0000:0x8000 = 0x8000
	mov dh, 3	; Read only 3 sectors
	call disk_load

	mov bx, 0x8000+lebron_glazing
	.lebron_glazing_loop:
	call print
	inc bx
	cmp bx, 0x8000+lebron_GOAT
	call get_char
	jne .lebron_glazing_loop
	
	call get_char
	
	call switch_to_protected_mode

[bits 32]
LEBRON_INIT_PROTECTED_MODE:
	call clear_vga

	mov ebx, 0x8000+lebron_image
	call print_vga

	mov eax, 160
	mov [CURSOR], eax
	mov ebx, 0x8000+lebron_GOAT
	call print_vga

	mov eax, 80*20
	mov [CURSOR], eax
	mov ebx, 0x8000+lebron_os_logo
	call print_vga

end_of_boot:
	jmp $

%include "src/boot_print.asm"
%include "src/boot_disk.asm"
%include "src/boot_gdt.asm"
%include "src/boot_32bit.asm"

times 510 - ($-$$) db 0
dw 0xaa55

; SECTOR 2, 3, 4 - LEBRON HAIRLINE DATA
_sector_2:

lebron_glazing equ $-_sector_2
db "You are my sunshine, my only sunshine.",10,0
db "You make me happy when skies are gray.",10,0
db "You'll never know dear, how much I love you.",10,0
db "Please don't take my sunshine away...",10,0
db "Please I love you so much Lebron don't leave me.",10,0
db "I NEED YOU.",10,0

lebron_GOAT equ $-_sector_2
db 176,"// LEBRON JAMES == G.O.A.T. //",0
lebron_os_logo equ $-_sector_2
db 132," __    ____  ____  ____  ____  _   __  ",10
db 131," / /   / __/ / _ / / _ / / _ / / \ / /  ",10
db 130," / /   / __/ / _ / /   / // // /  \/ /   ",10
db 129," /___/ /___/ /___/ / /|| /___/ /_ \__/    ",10
db " OPERATING SYSTEM                           ",0

%include "src/lebron.asm" ; Lebron James image

times 512*3 - ($-_sector_2) db 0
